unit FUsdH1_1Min;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, CleUsdParam,  CleDistributor,

  CleFunds, CleSymbols, CleAccounts ,  CleStorage, CleUsdH1_1Min, CleUsdH1_1Min_Fund
  ;

type
  TFrmUsH1 = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    edtSymbol: TLabeledEdit;
    cbRun: TCheckBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    dtEnd: TDateTimePicker;
    dtEntend: TDateTimePicker;
    dtEntStart: TDateTimePicker;
    stTxt: TStatusBar;
    GroupBox3: TGroupBox;
    cbTrailingStop: TCheckBox;
    edtStopMax: TLabeledEdit;
    edtStopPer: TLabeledEdit;
    GroupBox2: TGroupBox;
    edtOrdQty: TLabeledEdit;
    edtEntryCnt: TLabeledEdit;
    Timer1: TTimer;
    Button2: TButton;
    cbDefault: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    cbStopLiq: TCheckBox;
    Button6: TButton;
    edtAccount: TEdit;
    edtEntPer: TLabeledEdit;
    Panel1: TPanel;
    edtE_L: TLabeledEdit;
    edtL1_L: TLabeledEdit;
    edtE_S: TLabeledEdit;
    edtL1_S: TLabeledEdit;
    Panel2: TPanel;
    Label8: TLabel;
    edtE_L2: TLabeledEdit;
    edtL_L2: TLabeledEdit;
    edtE_S2: TLabeledEdit;
    edtL_S2: TLabeledEdit;
    Label7: TLabel;
    cbEntVol: TCheckBox;
    cbLossVol: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    cbEntCnt: TCheckBox;
    cbLossCnt: TCheckBox;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbDefaultChange(Sender: TObject);
    procedure cbTrailingStopClick(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure cbStopLiqClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure edtE_LKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FSymbol : TSymbol;
    FAccount: TAccount;
    FFund   : TFund;
    FUsH1   : TUsdH1_1Min_Trend;
    FUsH1_F : TUsdH1_1Min_Trend_Fund;

    FParam: TUsdH1_1Min_Param;
    FIsFund : boolean;
    procedure Start;
    procedure Stop;
    procedure Start_Fund;
    procedure Stop_Fund;
    procedure GetParam;
    procedure SetControls(bEnable: boolean);
    function GetRect(oRect: TRect): TRect;

  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmUsH1: TFrmUsH1;

implementation

uses
  GAppEnv, GleLib, GleConsts
  ;

{$R *.dfm}

{ TFrmUsH1 }


procedure TFrmUsH1.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbRun.Checked then
        begin
          ShowMessage('?????????? ?????? ?????? ????');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.ShortCode;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;

end;

procedure TFrmUsH1.Button2Click(Sender: TObject);
begin
  GetParam;
  FUsH1.Param   := FParam;
  FUsH1_F.Param := FParam;
end;

procedure TFrmUsH1.Button6Click(Sender: TObject);
begin

  if gAccount = nil then
    gEnv.CreateAccountSelect;

  try
    gAccount.Left := GetMousePoint.X+10;
    gAccount.Top  := GetMousePoint.Y;

    if gAccount.Open then
    begin
      if ( gAccount.Selected <> nil ) then
        if gAccount.Selected is TFund then
        begin
          if FFund <> gAccount.Selected then
          begin
            FIsFund := true;
            FAccount:= nil;
            FFund   := TFund( gAccount.Selected );
            edtAccount.Text := FFund.Name;
          end;
        end else
        begin
            FIsFund := false;
            FFund   := nil;
            FAccount:= TAccount( gAccount.Selected );
            edtAccount.Text := FAccount.Name
        end;
    end;
  finally
    gAccount.Hide;
  end;

end;

procedure TFrmUsH1.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    if FIsFund then start_Fund else start
  else
    if FIsFund then stop_Fund else stop;
end;

procedure TFrmUsH1.cbStopLiqClick(Sender: TObject);
begin
  FParam.UseStopLiq := cbStopLiq.Checked;

  if ( cbRun.Checked ) and ( FUsH1 <> nil ) then
    FUsH1.Param := FParam;
  if ( cbRun.Checked ) and ( FUsH1_F <> nil ) then
    FUsH1_F.Param := FParam;
end;

procedure TFrmUsH1.cbTrailingStopClick(Sender: TObject);
begin
  FParam.UseTrailingStop :=  cbTrailingStop.Checked;

  if ( cbRun.Checked ) and ( FUsH1 <> nil ) then
    FUsH1.Param := FParam;
  if ( cbRun.Checked ) and ( FUsH1_F <> nil ) then
    FUsH1_F.Param := FParam;
end;

procedure TFrmUsH1.edtE_LKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFrmUsH1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmUsH1.FormCreate(Sender: TObject);
begin
  FAccount := nil;
  FSymbol  := nil;
  FFund    := nil;
  FIsFund  := false;

  FUsH1   := TUsdH1_1Min_Trend.Create( Self );
  FUsH1_F := TUsdH1_1Min_Trend_Fund.Create( Self );

end;

procedure TFrmUsH1.FormDestroy(Sender: TObject);
begin
  FUsH1.Free;
  FUsH1_F.Free;
end;

procedure TFrmUsH1.GetParam;
begin
  With FParam do
  begin
    Endtime     := Frac( dtEnd.Time );
    EntTime     := Frac( dtEntStart.Time );
    EntEndtime  := Frac( dtEntEnd.Time );

    OrdQty    := StrToIntDef( edtOrdQty.Text, 1 );

    case cbDefault.ItemIndex of
      2 :
        begin
          E_L       := StrToFloatDef( edtE_L.Text, 0.7);
          E_S       := StrToFloatDef( edtE_S.Text, 0.7);
          L1_L      := StrToFloatDef( edtL1_L.Text, 0.9);
          L1_S      := StrToFloatDef( edtL1_S.Text, 0.9);
          UseTotVol := true;
        end
      else begin
        E_L       := StrToFloatDef( edtE_L.Text, 0.65);
        E_S       := StrToFloatDef( edtE_S.Text, 0.65);
        L1_L      := StrToFloatDef( edtL1_L.Text, 1.0);
        L1_S      := StrToFloatDef( edtL1_S.Text, 1.0);
        UseTotVol := false;
      end;
    end;

    EntPer     := StrToFloatDef( edtEntPer.Text, 0.003 );
    EntryCnt   := StrToIntDef( edtEntryCnt.Text, 4);
    StgIdx     := cbDefault.ItemIndex;

    UseTrailingStop := cbTrailingStop.Checked;

    StopMax := StrToIntDef( edtStopMax.Text, 100000);
    StopPer := StrToIntDef( edtStopPer.Text, 30);
    UseStopLiq  := cbStopLiq.Checked;

    E_L2       := StrToFloatDef( edtE_L2.Text, 0.65);
    E_S2       := StrToFloatDef( edtE_S2.Text, 0.65);
    L1_L2      := StrToFloatDef( edtL_L2.Text, 1.0);
    L1_S2      := StrToFloatDef( edtL_S2.Text, 1.0);

    UseEntVol   := cbEntVol.Checked;
    UseEntCnt   := cbEntCnt.Checked;
    UseLossCnt  := cbLossCnt.Checked;
    UseLossVol  := cbLossVol.Checked;
  end;

end;

procedure TFrmUsH1.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aAcnt  : TAccount;
  aFund  : TFund;
  aSymbol: TSymbol;
begin

  if aStorage = nil then Exit;

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if aSymbol <> nil then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

  FIsFund := aStorage.FieldByName('IsFund').AsBooleanDef(false);
  stCode := aStorage.FieldByName('AcntCode').AsString;

  if FIsFund  then
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Find( stCode );
    if aFund <> nil then
    begin
      FIsFund  := true;
      FFund    := aFund;
      FAccount := nil;
      edtAccount.Text := FFund.Name;
    end;
  end else
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
    if aAcnt <> nil then
    begin
      FIsFund   := false;
      FFund     := nil;
      FAccount  := aAcnt;
      edtAccount.Text := FAccount.Name;
    end;
  end;

  cbDefault.ItemIndex := aStorage.FieldByName('ConIdx').AsInteger;
  if cbDefault.ItemIndex < 0 then
    cbDefault.ItemIndex := 0;  

  dtEnd.Time        := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time ) );
  dtEntStart.Time   := TDateTime(aStorage.FieldByName('EntStartTime').AsTimeDef( dtEntStart.Time ));
  dtEntEnd.Time     := TDateTime(aStorage.FieldByName('EntEndTime').AsTimeDef( dtEntend.Time ));

  edtOrdQty.Text  := aStorage.FieldByName('OrdQty').AsStringDef( edtOrdQty.Text );
  edtE_L.Text     := aStorage.FieldByName('E_L').AsStringDef(edtE_L.Text );
  edtE_S.Text     := aStorage.FieldByName('E_S').AsStringDef( edtE_S.Text );
  edtL1_L.Text    := aStorage.FieldByName('L1_L').AsStringDef( edtL1_L.Text );
  edtL1_S.Text    := aStorage.FieldByName('L1_S').AsStringDef( edtL1_S.Text );
  edtEntPer.Text    := aStorage.FieldByName('EntPer').AsStringDef( edtEntPer.Text );

  edtEntryCnt.Text:= aStorage.FieldByName('EntryCnt').AsStringDef( edtEntryCnt.Text );
  edtStopMax.Text := aStorage.FieldByName('StopMax').AsStringDef( edtStopMax.Text );
  edtStopPer.Text := aStorage.FieldByName('StopPer').AsStringDef( edtStopPer.Text );

  cbTrailingStop.Checked  := aStorage.FieldByName('UseTrailingStop').AsBoolean;
  cbStopLiq.Checked       := aStorage.FieldByName('UseStopLiq').AsBooleanDef(true) ;

  edtE_L2.Text    := aStorage.FieldByName('E_L2').AsStringDef( edtE_L2.Text );
  edtE_S2.Text    := aStorage.FieldByName('E_S2').AsStringDef( edtE_S2.Text );
  edtL_L2.Text    := aStorage.FieldByName('L1_L2').AsStringDef( edtL_L2.Text );
  edtL_S2.Text    := aStorage.FieldByName('L1_S2').AsStringDef( edtL_S2.Text );

  cbEntCnt.Checked  := aStorage.FieldByName('UseEntCnt').AsBooleanDef(cbEntCnt.Checked);
  cbEntVol.Checked  := aStorage.FieldByName('UseVolCnt').AsBooleanDef(cbEntVol.Checked);
  cbLossCnt.Checked  := aStorage.FieldByName('UseLossCnt').AsBooleanDef(cbLossCnt.Checked);
  cbLossVol.Checked  := aStorage.FieldByName('UseLossVol').AsBooleanDef(cbLossVol.Checked);


end;

procedure TFrmUsH1.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('IsFund').AsBoolean := FIsFund;

  if FIsFund then begin
    if FFund <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FFund.Name
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end
  else begin
    if FAccount <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FAccount.Code
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbolcode').AsString     := FSymbol.Code
  else
    aStorage.FieldByName('Symbolcode').AsString    := '';

  aStorage.FieldByName('EndTime').AsFloat         := double( dtEnd.Time );
  aStorage.FieldByName('EntStartTime').AsFloat    := double( dtEntStart.Time );
  aStorage.FieldByName('EntEndTime').AsFloat      := double( dtEntEnd.Time );

  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('E_L').AsString := edtE_L.Text;
  aStorage.FieldByName('E_S').AsString := edtE_S.Text;
  aStorage.FieldByName('L1_L').AsString := edtL1_L.Text;
  aStorage.FieldByName('L1_S').AsString := edtL1_S.Text;
  aStorage.FieldByName('EntryCnt').AsString := edtEntryCnt.Text;
  aStorage.FieldByName('EntPer').AsString   := edtEntPer.Text;

  aStorage.FieldByName('StopMax').AsString := edtStopMax.Text;
  aStorage.FieldByName('StopPer').AsString := edtStopPer.Text;

  aStorage.FieldByName('UseTrailingStop').AsBoolean := cbTrailingStop.Checked;
  aStorage.FieldByName('UseStopLiq').AsBoolean := cbStopLiq.Checked;
  aStorage.FieldByName('ConIdx').AsInteger := cbDefault.ItemIndex;

  aStorage.FieldByName('E_L2').AsString     := edtE_L2.Text ;
  aStorage.FieldByName('E_S2').AsString     := edtE_S2.Text ;
  aStorage.FieldByName('L1_L2').AsString    := edtL_L2.Text ;
  aStorage.FieldByName('L1_S2').AsString    := edtL_S2.Text ;

  aStorage.FieldByName('UseEntCnt').AsBoolean   := cbEntCnt.Checked;
  aStorage.FieldByName('UseVolCnt').AsBoolean   := cbEntVol.Checked;
  aStorage.FieldByName('UseLossCnt').AsBoolean  := cbLossCnt.Checked;
  aStorage.FieldByName('UseLossVol').AsBoolean  := cbLossVol.Checked;

end;

procedure TFrmUsH1.Start;
begin

  if ( FSymbol = nil ) or  ( FAccount = nil ) then
  begin
    ShowMessage('???????? ????????. ');
    cbRun.Checked := false;
    Exit;
  end;

  if FUsH1 <> nil then
  begin
    GetParam;
    FUsH1.Param := FParam;
    FUsH1.init( FAccount, FSymbol );
    FUsH1.Start;
    plRun.Color := clLime;
    Timer1.Enabled  := true;
    SetControls( false );
  end;
end;

procedure TFrmUsH1.SetControls( bEnable : boolean );
begin
  cbDefault.Enabled := bEnable;
  Button6.Enabled   := bEnable;
  Button1.Enabled   := bEnable;
end;


procedure TFrmUsH1.Stop;
begin
  if FUsH1 <> nil then
  begin
    FUsH1.Stop;
    plRun.Color := clBtnFace;
    SetControls( true );
  end;
end;

procedure TFrmUsH1.Start_Fund;
begin
  if ( FSymbol = nil ) or  ( FFund = nil ) then
  begin
    ShowMessage('???????? ????????. ');
    cbRun.Checked := false;
    Exit;
  end;

  if FUsH1 <> nil then
  begin
    GetParam;
    FUsH1_F.Param := FParam;
    FUsH1_F.init( FFund, FSymbol );
    FUsH1_F.Start;
    plRun.Color := clLime;
    Timer1.Enabled  := true;
    SetControls( false );
  end;
end;

procedure TFrmUsH1.Stop_Fund;
begin
  if FUsH1_F <> nil then
  begin
    FUsH1_F.Stop;
    plRun.Color := clBtnFace;
    SetControls( true );
  end;
end;

procedure TFrmUsH1.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
  var
    oRect : TRect;
begin
  if stTxt.Tag = 0 then begin
    StatusBar.Canvas.Brush.Color := clBtnFace;
    StatusBar.Canvas.Font.Color := clBlack;
  end
  else if stTxt.Tag < 0 then begin
    StatusBar.Canvas.Brush.Color := clBlue;
    StatusBar.Canvas.Font.Color := clWhite;
  end
  else if stTxt.Tag > 0 then begin
    StatusBar.Canvas.Brush.Color := clRed;
    StatusBar.Canvas.Font.Color := clWhite;
  end;

  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  DrawText( stTxt.Canvas.Handle, PChar( stTxt.Panels[0].Text ),
    Length( stTxt.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
end;

function TFrmUsH1.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmUsH1.Timer1Timer(Sender: TObject);
begin

  if FIsFund then
  begin
    if ( FUsH1_F <> nil ) and ( FUsH1_F.Position <> nil ) then
    begin
      stTxt.Panels[0].Text  := IntToStr( FUsH1_F.Position.Volume );
      stTxt.Tag := FUsH1_F.Position.Volume;
      stTxt.Panels[1].Text := Format('%.2f, %.2f', [ FUsH1_F.Position.Symbol.CntRatio,
        FUsH1_F.Position.Symbol.VolRatio ] );

      stTxt.Panels[2].Text  := Format('(%d th.) %.0f, %.0f, %.0f', [ FUsH1_F.OrderCnt,
        FUsH1_F.MaxOpenPL /1000, FUsH1_F.Position.EntryOTE/1000,
        FUsH1_F.Position.LastPL / 1000 ]);
    end;
  end
  else begin
    if ( FUsH1 <> nil ) and ( FUsH1.Position <> nil ) then
    begin
      stTxt.Panels[0].Text  := IntToStr( FUsH1.Position.Volume );
      stTxt.Tag := FUsH1.Position.Volume;
      stTxt.Panels[1].Text := Format('%.2f, %.2f', [ FUsH1.Position.Symbol.CntRatio,
        FUsH1.Position.Symbol.VolRatio ] );

      stTxt.Panels[2].Text  := Format('(%d th.) %.0f, %.0f, %.0f', [ FUsH1.OrderCnt,
        FUsH1.MaxOpenPL /1000, FUsH1.Position.EntryOTE/1000,
        FUsH1.Position.LastPL / 1000 ]);
    end;
  end;
end;

procedure TFrmUsH1.cbDefaultChange(Sender: TObject);
begin
  case cbDefault.ItemIndex of
    0 :
      begin
          dtEnd.Time      := Date + EncodeTime( 15,25,0,0);
          dtEntStart.Time := Date + EncodeTime( 10,50,0,0);
          dtEntEnd.Time   := Date + EncodeTime( 15,10,0,0);

          edtL1_L.Text    := '1.0';
          edtL1_S.Text    := '1.0';

          edtE_L.Text     := '0.65';
          edtE_S.Text     := '0.65';

      end;
    1 :
      begin
          dtEnd.Time      := Date + EncodeTime( 15,20,0,0);
          dtEntStart.Time := Date + EncodeTime( 9 , 3,0,0);
          dtEntEnd.Time   := Date + EncodeTime( 15,0,0,0);

          edtL1_L.Text    := '1.0';
          edtL1_S.Text    := '1.0';

          edtE_L.Text     := '0.65';
          edtE_S.Text     := '0.65';
      end;
    2 : //  20160302  ????
      begin
          dtEnd.Time      := Date + EncodeTime( 15,29,0,0);
          dtEntStart.Time := Date + EncodeTime(  9, 3,0,0);
          dtEntEnd.Time   := Date + EncodeTime( 14,00,0,0);

          edtL1_L.Text    := '0.9';
          edtL1_S.Text    := '0.9';

          edtE_L.Text     := '0.66';
          edtE_S.Text     := '0.66';
      end;
  end;
end;

end.
