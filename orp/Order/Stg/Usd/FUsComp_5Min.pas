unit FUsComp_5Min;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, CleFunds, CleSymbols , CleUsdParam,  CleUsComp,

  CleStorage, ComCtrls, StdCtrls, ExtCtrls ,

  GleTypes
  ;

type
  TFrmUsComp = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    edtSymbol: TLabeledEdit;
    cbRun: TCheckBox;
    edtAccount: TEdit;
    Button6: TButton;
    stTxt: TStatusBar;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    dtEnd: TDateTimePicker;
    dtEntend: TDateTimePicker;
    dtEntStart: TDateTimePicker;
    dtLiqStart: TDateTimePicker;
    GroupBox2: TGroupBox;
    Label8: TLabel;
    edtOrdQty: TLabeledEdit;
    Button2: TButton;
    edtEntPer: TLabeledEdit;
    edtE_C: TLabeledEdit;
    edtE_S: TLabeledEdit;
    edtEntryCnt: TLabeledEdit;
    Label1: TLabel;
    cbStopLiq: TCheckBox;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Timer1Timer(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure cbStopLiqClick(Sender: TObject);
  private
    { Private declarations }

    FSymbol : TSymbol;
    FAccount: TAccount;
    FFund   : TFund;
    FIsFund : boolean;
    FParam  : TUs_Comp;
    FFuture : TSymbol;

    FUsComp : TUsComp;

    procedure Start;
    procedure Stop;

    procedure GetParam;
    function GetRect(oRect: TRect): TRect;
    procedure SetControls(bEnable: boolean);
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure EndMessage( var Msg : TMessage ) ; message  WM_ENDMESSAGE;
  end;

var
  FrmUsComp: TFrmUsComp;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

{ TFrmUsComp }

procedure TFrmUsComp.Button1Click(Sender: TObject);
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

procedure TFrmUsComp.Button2Click(Sender: TObject);
begin
  if ( FUsComp <> nil ) and ( cbRun.Checked ) then
  begin
    GetParam;
    FUsComp.Param := FParam;
  end;
end;

procedure TFrmUsComp.Button6Click(Sender: TObject);
begin
  if cbRun.Checked then begin
    ShowMessage('?????????? ?????? ????');
    Exit;
  end;

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

procedure TFrmUsComp.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    start
  else
    stop;
end;

procedure TFrmUsComp.cbStopLiqClick(Sender: TObject);
begin
  if ( cbRun.Checked ) and ( FUsComp <> nil ) then
  begin
    FParam.UseStopLiq := cbStopLiq.Checked;
    FUscomp.Param := FParam;
  end;
end;

procedure TFrmUsComp.EndMessage(var Msg: TMessage);
begin
  if ( FUsComp <> nil ) and ( cbRun.Checked ) then
    cbRun.Checked := false;
end;

procedure TFrmUsComp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmUsComp.FormCreate(Sender: TObject);
begin

  FAccount := nil;
  FSymbol  := nil;
  FFund    := nil;

  FFuture := gEnv.Engine.SymbolCore.Future;

  FUsComp := TUsComp.Create( Self );
end;

procedure TFrmUsComp.FormDestroy(Sender: TObject);
begin
  //
  FUsComp.Free;
end;

procedure TFrmUsComp.GetParam;
begin
  with FParam do
  begin
    Endtime := Frac( dtEnd.Time );
    LiqStartTime := Frac( dtLiqstart.Time );
    EntStartTime := Frac( dtEntStart.Time );
    EntEndtime   := Frac( dtEntEnd.Time );

    OrdQty     := StrToIntDef( edtOrdQty.Text, 1 );
    EntryCnt   := StrToIntDef( edtEntryCnt.Text, 4);

    E_C := StrToFloatDef( edtE_C.Text, 0.7 );
    E_S := StrToFloatDef( edtE_S.Text, 1 );
    EntPer := StrToFloatDef( edtEntPer.Text, 0.004 );

    UseStopLiq:= cbStopLiq.Checked; 
  end;
end;

function TFrmUsComp.GetRect(oRect: TRect): TRect;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmUsComp.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aSymbol: TSymbol;
  aFund  : TFund;
  aAcnt  : TAccount;
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

  dtEnd.Time      := aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time );
  dtEntStart.Time := aStorage.FieldByName('EntStartTime').AsTimeDef( dtEntStart.Time );
  dtEntEnd.Time   := aStorage.FieldByName('EntEndTime').AsTimeDef( dtEntEnd.Time );
  dtLiqStart.Time := aStorage.FieldByName('LiqStart').AsTimeDef( dtLiqStart.Time );

  edtOrdQty.Text  := aStorage.FieldByName('OrdQty').AsStringDef( edtOrdQty.Text );
  edtOrdQty.Text  := aStorage.FieldByName('EntryCnt').AsStringDef( edtOrdQty.Text );

  edtE_C.Text     := aStorage.FieldByName('E_C').AsStringDef( edtE_C.Text );
  edtE_S.Text     := aStorage.FieldByName('E_S').AsStringDef( edtE_S.Text );
  edtEntPer.Text  := aStorage.FieldByName('EntPer').AsStringDef( edtEntPer.Text );

  cbStopLiq.Checked := aStorage.FieldByName('UseStopLiq').AsBooleanDef( true );

end;

procedure TFrmUsComp.SaveEnv(aStorage: TStorage);
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
  aStorage.FieldByName('LiqStart').AsFloat        := double( dtLiqStart.Time );

  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('EntryCnt').AsString    := edtOrdQty.Text;

  aStorage.FieldByName('E_C').AsString    := edtE_C.Text;
  aStorage.FieldByName('E_S').AsString    := edtE_S.Text;
  aStorage.FieldByName('EntPer').AsString    := edtEntPer.Text;

  aStorage.FieldByName('UseStopLiq').AsBoolean := cbStopLiq.Checked;
end;

procedure TFrmUsComp.Start;
begin

  if FSymbol = nil then Exit;

  if FIsFund and ( FFund = nil ) then Exit;
  if ( not FIsFund ) and ( FAccount = nil ) then Exit;

  GetParam;
  FUsComp.Param := FParam;

  if FIsFund then
    FUsComp.init( FFund, FIsFund, FFuture, FSymbol )
  else
    FUsComp.init( FAccount, FIsFund, FFuture, FSymbol );

  FUsComp.Start;
  SetControls( false );
  Timer1.Enabled  := true;
end;

procedure TFrmUsComp.Stop;
begin
  if FUsComp <> nil then
  begin
    FUsComp.Stop;
    SetControls( true );
  end;
end;

procedure TFrmUsComp.SetControls( bEnable : boolean );
begin
  if bEnable then
    plRun.Color := clBtnFace
  else
    plRun.Color := clLime;

  Button6.Enabled := bEnable;
  Button1.Enabled   := bEnable;
end;

procedure TFrmUsComp.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
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

procedure TFrmUsComp.Timer1Timer(Sender: TObject);
var
  iVol: Integer;
begin
  iVol := 0;

  try
    if FUsComp <> nil then
      iVol := FUsComp.Volume;
    stTxt.Panels[0].Text  := IntToStr( iVol );
    stTxt.Tag := iVol;

    stTxt.Panels[1].Text := Format('%.2f, %.2f', [ FUsComp.MoveAvgPrc, FUsComp.EntryPrice ] );

    if FUsComp <> nil then
      stTxt.Panels[2].Text := Format('(%d th.) %.0f', [ FUsComp.OrderCnt , FUsComp.PL / 1000 ])
    else
      stTxt.Panels[2].Text := Format('(%d th.) %.0f',  [0, 0.0]);
  except
  end;

end;

end.
