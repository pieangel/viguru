unit FUs_In_123;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, CleFunds,
  CleSymbols, CleAccounts ,  CleStorage, CleUs_In_123, CleUs_In_123_Fund, CleUsdParam
  ;
type
  TFrmUsIn123 = class(TForm)
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
    GroupBox2: TGroupBox;
    edtOrdQty: TLabeledEdit;
    edtE_L: TLabeledEdit;
    edtE_S: TLabeledEdit;
    edtL1_S: TLabeledEdit;
    edtL1_L: TLabeledEdit;
    GroupBox3: TGroupBox;
    cbTrailingStop: TCheckBox;
    edtStopMax: TLabeledEdit;
    edtStopPer: TLabeledEdit;
    stTxt: TStatusBar;
    edtL2_L: TLabeledEdit;
    edtL2_S: TLabeledEdit;
    cbSecondLiqCon: TCheckBox;
    Label5: TLabel;
    cbDefault: TComboBox;
    Timer1: TTimer;
    Label6: TLabel;
    cbStopLiq: TCheckBox;
    edtAccount: TEdit;
    Button6: TButton;
    cbEntFilter: TCheckBox;
    cbEntFilter2: TCheckBox;
    edtCntFilter: TLabeledEdit;
    cbEntVolFilter: TCheckBox;
    edtVolFilter: TLabeledEdit;
    Button2: TButton;
    edtEntryCnt: TLabeledEdit;
    cbLossVolFillter: TCheckBox;
    edtLossVolFillter: TLabeledEdit;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure edtE_LKeyPress(Sender: TObject; var Key: Char);
    procedure edtEntryCntKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);

    procedure cbRunClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbDefaultChange(Sender: TObject);
    procedure cbTrailingStopClick(Sender: TObject);
    procedure cbSecondLiqConClick(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure cbStopLiqClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure cbEntFilterClick(Sender: TObject);
    procedure cbEntFilter2Click(Sender: TObject);
    procedure cbEntVolFilterClick(Sender: TObject);
    procedure cbLossVolFillterClick(Sender: TObject);
  private
    { Private declarations }
    FFuture, FSymbol : TSymbol;
    FAccount: TAccount;
    FFund   : TFund;
    FParam : TUs_In_123_Param;
    FUsIn  : TUs_In_123_Trend;
    FUsIn_F  : TUs_In_123_Trend_Fund;

    FIsFund : boolean;
    procedure Start;
    procedure Stop;
    procedure GetParam;
    procedure SetControls(bEnable: boolean);
    function GetRect(oRect: TRect): TRect;
    procedure SetParamData;
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmUsIn123: TFrmUsIn123;

implementation

uses
  GAppEnv, GleLib 

  ;

{$R *.dfm}

procedure TFrmUsIn123.Button1Click(Sender: TObject);
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

procedure TFrmUsIn123.Button2Click(Sender: TObject);
begin
  GetParam;
  FUsIn_F.Param := FParam;
  FUsIn.Param := FParam;
end;

procedure TFrmUsIn123.Button6Click(Sender: TObject);
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

procedure TFrmUsIn123.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    start
  else
    stop;
end;

procedure TFrmUsIn123.SetParamData;
begin
  if ( cbRun.Checked ) then
    if ( FIsFund ) and ( FUsIn_F <> nil ) then
      FUsIn_F.Param := FParam
    else if ( not FIsFund ) and ( FUsIn <> nil ) then
      FUsIn.Param := FParam;
end;

procedure TFrmUsIn123.cbSecondLiqConClick(Sender: TObject);
begin
  FParam.UseSecondLiqCon :=  cbSecondLiqCon.Checked;
  SetParamData;
end;

procedure TFrmUsIn123.cbStopLiqClick(Sender: TObject);
begin
  FParam.UseStopLiq := cbStopLiq.Checked;
  SetParamData;
end;

procedure TFrmUsIn123.cbTrailingStopClick(Sender: TObject);
begin
  FParam.UseTrailingStop :=  cbTrailingStop.Checked;
  SetParamData;
end;

procedure TFrmUsIn123.edtEntryCntKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;

procedure TFrmUsIn123.edtE_LKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFrmUsIn123.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmUsIn123.FormCreate(Sender: TObject);
begin
  FAccount := nil;
  FSymbol  := nil;
  FFuture  := nil;
  FFund    := nil;

  FUsIn  := TUs_In_123_Trend.Create( Self );
  FUsIn_F:= TUs_In_123_Trend_Fund.Create( Self );

  FFuture := gEnv.Engine.SymbolCore.Future;
end;

procedure TFrmUsIn123.FormDestroy(Sender: TObject);
begin
  FUsIn.Free;
  FUsIn_F.Free;
end;

procedure TFrmUsIn123.GetParam;
begin
  With FParam do
  begin
    Endtime     := Frac( dtEnd.Time );
    EntTime     := Frac( dtEntStart.Time );
    EntEndtime  := Frac( dtEntEnd.Time );
    UseEntFillter := cbEntFilter.Checked;
    UseEntFillter2:= cbEntFilter2.Checked;

    OrdQty    := StrToIntDef( edtOrdQty.Text, 1 );
    E_L       := StrToFloatDef( edtE_L.Text, 0.7);
    E_S       := StrToFloatDef( edtE_S.Text, 0.7);
    L1_L       := StrToFloatDef( edtL1_L.Text, 0.9);
    L1_S       := StrToFloatDef( edtL1_S.Text, 0.9);
    L2_L       := StrToFloatDef( edtL2_L.Text, 0.8);
    L2_S       := StrToFloatDef( edtL2_S.Text, 0.8);

    EntryCnt   := StrToIntDef( edtEntryCnt.Text, 4);

    UseTrailingStop := cbTrailingStop.Checked;
    UseSecondLiqCon := cbSecondLiqCon.Checked;
    StopMax := StrToIntDef( edtStopMax.Text, 100000);
    StopPer := StrToIntDef( edtStopPer.Text, 30);
    UseStopLiq  := cbStopLiq.Checked;


    UseVolFillter := cbEntVolFilter.Checked;
    CntFillter := StrToFloatDef( edtCntFilter.Text, 0.85 );
    VolFillter := StrToFloatDef( edtVolFilter.Text, 0.85 );

    UseLossVolFillter := cbLossVolFillter.Checked;
    LossVolFillter    := StrToFloatDef( edtLossVolFillter.Text, 0.9);

  end;

end;

procedure TFrmUsIn123.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aAcnt  : TAccount;
  aSymbol: TSymbol;
  aFund  : TFund;
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
  cbEntFilter.Checked := aStorage.FieldByName('UseEntFillter').AsBooleanDef( cbEntFilter.Checked );
  cbEntFilter2.Checked:= aStorage.FieldByName('UseEntFillter2').AsBooleanDef( cbEntFilter2.Checked );

  edtOrdQty.Text  := aStorage.FieldByName('OrdQty').AsStringDef( edtOrdQty.Text );
  edtE_L.Text     := aStorage.FieldByName('E_L').AsStringDef(edtE_L.Text );
  edtE_S.Text     := aStorage.FieldByName('E_S').AsStringDef( edtE_S.Text );
  edtL1_L.Text    := aStorage.FieldByName('L1_L').AsStringDef( edtL1_L.Text );
  edtL1_S.Text    := aStorage.FieldByName('L1_S').AsStringDef( edtL1_S.Text );
  edtL2_L.Text    := aStorage.FieldByName('L2_L').AsStringDef( edtL2_L.Text );
  edtL2_S.Text    := aStorage.FieldByName('L2_S').AsStringDef( edtL2_S.Text );

  edtEntryCnt.Text:= aStorage.FieldByName('EntryCnt').AsStringDef( edtEntryCnt.Text );
  edtStopMax.Text := aStorage.FieldByName('StopMax').AsStringDef( edtStopMax.Text );
  edtStopPer.Text := aStorage.FieldByName('StopPer').AsStringDef( edtStopPer.Text );

  cbSecondLiqCon.Checked  := aStorage.FieldByName('UseSecondLiqCon').AsBoolean;
  cbTrailingStop.Checked  := aStorage.FieldByName('UseTrailingStop').AsBoolean;
  cbStopLiq.Checked       := aStorage.FieldByName('UseStopLiq').AsBooleanDef(true) ;

  // add 20191125
  cbEntVolFilter.Checked  := aStorage.FieldByName('UseEntVolFillter').AsBooleanDef(cbEntVolFilter.Checked) ;
  edtCntFilter.Text := aStorage.FieldByName('CntFillter').AsStringDef( '0.85' );
  edtVolFilter.Text := aStorage.FieldByName('VolFillter').AsStringDef( '0.85' );

  cbLossVolFillter.Checked:= aStorage.FieldByName('UseLossVolFillter').AsBooleanDef(cbLossVolFillter.Checked) ;
  edtLossVolFillter.Text  := aStorage.FieldByName('LossVolFillter').AsStringDef( edtLossVolFillter.Text );

end;

procedure TFrmUsIn123.SaveEnv(aStorage: TStorage);
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
  aStorage.FieldByName('UseEntFillter').AsBoolean := cbEntFilter.Checked;
  aStorage.FieldByName('UseEntFillter2').AsBoolean := cbEntFilter2.Checked;

  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('E_L').AsString := edtE_L.Text;
  aStorage.FieldByName('E_S').AsString := edtE_S.Text;
  aStorage.FieldByName('L1_L').AsString := edtL1_L.Text;
  aStorage.FieldByName('L1_S').AsString := edtL1_S.Text;
  aStorage.FieldByName('L2_L').AsString := edtL2_L.Text;
  aStorage.FieldByName('L2_S').AsString := edtL2_S.Text;
  aStorage.FieldByName('EntryCnt').AsString := edtEntryCnt.Text;

  aStorage.FieldByName('StopMax').AsString := edtStopMax.Text;
  aStorage.FieldByName('StopPer').AsString := edtStopPer.Text;

  aStorage.FieldByName('UseSecondLiqCon').AsBoolean := cbSecondLiqCon.Checked;
  aStorage.FieldByName('UseTrailingStop').AsBoolean := cbTrailingStop.Checked;
  aStorage.FieldByName('UseStopLiq').AsBoolean := cbStopLiq.Checked;

  aStorage.FieldByName('ConIdx').AsInteger := cbDefault.ItemIndex;

  // add 20191125
  aStorage.FieldByName('UseEntVolFillter').AsBoolean  := cbEntVolFilter.Checked;
  aStorage.FieldByName('CntFillter').AsString         := edtCntFilter.Text;
  aStorage.FieldByName('VolFillter').AsString         := edtVolFilter.Text;

  aStorage.FieldByName('UseLossVolFillter').AsBoolean := cbLossVolFillter.Checked ;
  aStorage.FieldByName('LossVolFillter').AsString     := edtLossVolFillter.Text;

end;

procedure TFrmUsIn123.Start;
begin
  if not FIsFund then
  begin
    if ( FSymbol = nil ) or ( FAccount = nil ) then
    begin
      ShowMessage('???????? ????????. ');
      cbRun.Checked := false;
      Exit;
    end;

    if FUsIn <> nil then
    begin
      GetParam;
      FUsIn.Param := FParam;
      FUsIn.init( FAccount, FFuture, FSymbol );
      FUsIn.Start;
      plRun.Color := clLime;
      Timer1.Enabled  := true;
      SetControls( false );
    end;
  end else begin
    if ( FSymbol = nil ) or ( FFund = nil ) then
    begin
      ShowMessage('???????? ????????. ');
      cbRun.Checked := false;
      Exit;
    end;

    if FUsIn_F <> nil then
    begin
      GetParam;
      FUsIn_F.Param := FParam;
      FUsIn_F.init( FFund, FFuture, FSymbol );
      FUsIn_F.Start;
      plRun.Color := clLime;
      Timer1.Enabled  := true;
      SetControls( false );
    end;
  end;
end;

procedure TFrmUsIn123.SetControls( bEnable : boolean );
begin
  cbDefault.Enabled := bEnable;
  Button6.Enabled := bEnable;
  Button1.Enabled   := bEnable;
end;

procedure TFrmUsIn123.Stop;
begin
  if FIsFund then
  begin

    if FUsIn_F <> nil then
    begin
      FUsIn_F.Stop;
      plRun.Color := clBtnFace;
      SetControls( true );
    end;

  end else
  begin

    if FUsIn <> nil then
    begin
      FUsIn.Stop;
      plRun.Color := clBtnFace;
      SetControls( true );
    end;
  end;

end;

procedure TFrmUsIn123.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
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

function TFrmUsIn123.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmUsIn123.Timer1Timer(Sender: TObject);
begin
  if FIsFund then
  begin
    if ( FUsIn_F <> nil ) and ( FUsIn_F.Position <> nil ) then
    begin
      stTxt.Panels[0].Text  := IntToStr( FUsIn_F.Position.Volume );
      stTxt.Tag := FUsIn_F.Position.Volume;
      if FFuture <> nil then
        stTxt.Panels[1].Text := Format('%.2f', [ FFuture.CntRatio ] );

      stTxt.Panels[2].Text  := Format('(%d th.) %.0f, %.0f, %.0f', [ FUsIn_F.OrderCnt,
        FUsIn_F.MaxOpenPL /1000, FUsIn_F.Position.EntryOTE/1000,
        FUsIn_F.Position.LastPL / 1000 ]);
    end;
  end else
  begin
    if ( FUsIn <> nil ) and ( FUsIn.Position <> nil ) then
    begin
      stTxt.Panels[0].Text  := IntToStr( FUsIn.Position.Volume );
      stTxt.Tag := FUsIn.Position.Volume;
      if FFuture <> nil then
        stTxt.Panels[1].Text := Format('%.2f', [ FFuture.CntRatio ] );

      stTxt.Panels[2].Text  := Format('(%d th.) %.0f, %.0f, %.0f', [ FUsIN.OrderCnt,
        FUsIn.MaxOpenPL /1000, FUsIn.Position.EntryOTE/1000,
        FUsIn.Position.LastPL / 1000 ]);
    end;
  end;
end;

procedure TFrmUsIn123.cbDefaultChange(Sender: TObject);
begin
  case cbDefault.ItemIndex of
    0 :
      begin
          dtEnd.Time      := Date + EncodeTime( 15, 32,0,0);
          dtEntStart.Time := Date + EncodeTime( 9 , 3,0,0);
          dtEntEnd.Time   := Date + EncodeTime( 14, 0,0,0);
          cbEntFilter.Checked := false;
          cbEntFilter2.Checked := false;

          edtOrdQty.Text :=  '1';
          edtE_L.Text   := '0.7';
          edtE_S.Text   := '0.7';
          edtL1_L.Text  := '0.9';
          edtL1_S.Text  := '0.9';
          edtL2_L.Text  := '0.8';
          edtL2_S.Text  := '0.8';

          edtEntryCnt.Text  := '4';

          cbTrailingStop.Checked  := false;
          cbSecondLiqCon.Checked  := true;
          edtStopMax.Text := '500000';
          edtStopPer.Text := '30';
      end;
    1 :
      begin
          dtEnd.Time      := Date + EncodeTime( 15, 32,0,0);
          dtEntStart.Time := Date + EncodeTime( 9 , 2,0,0);
          dtEntEnd.Time   := Date + EncodeTime( 15,0,0,0);
          cbEntFilter.Checked := true;
          cbEntFilter2.Checked := false;

          edtOrdQty.Text :=  '1';
          edtE_L.Text   := '0.7';
          edtE_S.Text   := '0.7';
          edtL1_L.Text  := '0.9';
          edtL1_S.Text  := '0.9';
          edtL2_L.Text  := '0.8';
          edtL2_S.Text  := '0.8';

          edtEntryCnt.Text  := '3';

          cbTrailingStop.Checked  := true;
          cbSecondLiqCon.Checked  := false;
          edtStopMax.Text := '500000';
          edtStopPer.Text := '30';

      end;
    2 :
      begin
          dtEnd.Time      := Date + EncodeTime( 15, 33,0,0);
          dtEntStart.Time := Date + EncodeTime( 9 ,29,0,0);
          dtEntEnd.Time   := Date + EncodeTime( 14,50,0,0);
          cbEntFilter.Checked := true;
          cbEntFilter2.Checked := true;

          edtOrdQty.Text :=  '1';
          edtE_L.Text   := '0.6';
          edtE_S.Text   := '0.6';
          edtL1_L.Text  := '1.1';
          edtL1_S.Text  := '0.9';
          edtL2_L.Text  := '0.8';
          edtL2_S.Text  := '0.8';

          edtEntryCnt.Text  := '3';

          cbTrailingStop.Checked  := false;
          cbSecondLiqCon.Checked  := false;
          edtStopMax.Text := '500000';
          edtStopPer.Text := '30';
      end;
  end;

end;

procedure TFrmUsIn123.cbEntFilter2Click(Sender: TObject);
begin
  FParam.UseEntFillter2 :=  cbEntFilter2.Checked;
  SetParamData;
end;

procedure TFrmUsIn123.cbEntFilterClick(Sender: TObject);
begin
  FParam.UseEntFillter :=  cbEntFilter.Checked;
  SetParamData;
end;

procedure TFrmUsIn123.cbEntVolFilterClick(Sender: TObject);
begin
  FParam.UseVolFillter :=  cbEntVolFilter.Checked;
  SetParamData;
end;

// ?????? ???? ????
procedure TFrmUsIn123.cbLossVolFillterClick(Sender: TObject);
begin
  FParam.UseLossVolFillter  := cbLossVolFilLter.Checked;
  SetParamData;

end;

end.
