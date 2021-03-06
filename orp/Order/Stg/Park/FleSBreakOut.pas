unit FleSBreakOut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, CleFunds,  CleSymbols, CleStorage, CleParkParam, CleSBreakOut,

  StdCtrls, ExtCtrls, ComCtrls, Grids
  ;

type
  TFrmSBreakOut = class(TForm)
    plRun: TPanel;
    cbRun: TCheckBox;
    Button6: TButton;
    edtAccount: TEdit;
    stTxt: TStatusBar;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    dtEnd: TDateTimePicker;
    dtStart: TDateTimePicker;
    edtEntryCnt: TLabeledEdit;
    edtBelowPrc: TLabeledEdit;
    Button2: TButton;
    stSymbol: TStaticText;
    Timer1: TTimer;
    Button1: TButton;
    edtBasePrc: TLabeledEdit;
    edtOrdQty: TLabeledEdit;
    edtLCPer: TLabeledEdit;
    cbStopLiq: TCheckBox;
    Label1: TLabel;
    dtMorning: TDateTimePicker;
    sgLog: TStringGrid;
    procedure Button6Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbStopLiqClick(Sender: TObject);
  private
    { Private declarations }
    FIsFund : boolean;
    FAccount: TAccount;
    FFund   : TFund;
    FOss    : TList;
    FOs     : TSBreakOut;
    FParam  : TSBO_Param;
    function GetRect(oRect: TRect): TRect;
    function AddOs(aAcnt: TAccount) : TSBreakOut;
  public
    { Public declarations }
    procedure Start;
    procedure Stop;
    procedure GetParam;
    procedure SetSymbol( aSymbol : TSymbol );

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure OnTextNotify(Sender: TObject; Value: String);
  end;

var
  FrmSBreakOut: TFrmSBreakOut;

implementation

uses
  GAppEnv, GleLib  ,GleTypes,
  CleStrategyStore
  ;

{$R *.dfm}

procedure TFrmSBreakOut.Button1Click(Sender: TObject);
var
  aSymbol : TSymbol;
  aOs     : TSBreakOut;
  I: Integer;
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  if FOss.Count > 0 then begin
    aOs := TSBreakOut( FOss.Items[0] );
    aSymbol := aOs.Symbol;
  end
  else
    aSymbol := nil;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( aSymbol <> gSymbol.Selected ) then
      begin
        for I := 0 to FOss.Count - 1 do
          TSBreakOut( FOss.Items[i] ).SelectTradeSymbol( gSymbol.Selected);
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmSBreakOut.Button2Click(Sender: TObject);
var
  i : integer;
begin
  GetParam;
  for I := 0 to FOss.Count - 1 do
    TSBreakOut( FOss.Items[i] ).Param  := FParam;
end;

procedure TFrmSBreakOut.Button6Click(Sender: TObject);
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

procedure TFrmSBreakOut.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    start
  else
    stop;
end;

procedure TFrmSBreakOut.cbStopLiqClick(Sender: TObject);
var
  i : integer;
begin
  FParam.UseStopLiq := cbStopLiq.Checked;
  for I := 0 to FOss.Count - 1 do
    TSBreakOut(FOss.Items[i]).Param := FParam;

end;

procedure TFrmSBreakOut.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmSBreakOut.FormCreate(Sender: TObject);
begin
  FAccount := nil;
  FFund    := nil;
  FOss     := TList.Create;
  FOs      := nil;;
end;

procedure TFrmSBreakOut.FormDestroy(Sender: TObject);
begin
  //

  FOss.Clear;
  if FOs <> nil then  
    FOs.OnNotify := nil;
  FOs := nil;
  FOss.Free;

end;

procedure TFrmSBreakOut.GetParam;
begin

  with FParam do
  begin
    OrdQty    := StrToIntDef( edtOrdQty.Text, 1 );
    EntryCnt  := StrToIntDef( edtEntryCnt.Text, 4);
    StopPer   := StrToIntDef( edtLCPer.Text, 30);
    BasePrc   := StrToFloatDef( edtBasePrc.Text, 1.5);
    BelowPrc  := StrToFloatDef( edtBelowPrc.Text, 1.0 );
    //
    Endtime   := Frac( dtEnd.Time );
    StartTime := Frac( dtStart.Time );
    MorningTime := Frac( dtMorning.Time );

    UseStopLiq:= cbStopLiq.Checked ;
  end;

end;

procedure TFrmSBreakOut.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aAcnt  : TAccount;
  aFund  : TFund;
begin

  if aStorage = nil then Exit;

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

  dtEnd.Time        := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time ) );
  dtStart.Time      := TDateTime(aStorage.FieldByName('StartTime').AsTimeDef( dtStart.Time ));
  dtMorning.Time    := TDateTime(aStorage.FieldByName('MornigTime').AsTimeDef( dtMorning.Time ));

  edtEntryCnt.Text  := aStorage.FieldByName('EntryCnt').AsStringDef( edtEntryCnt.Text );
  edtBelowPrc.Text   := aStorage.FieldByName('BelowPrc').AsStringDef( edtBelowPrc.Text );
  edtBasePrc.Text   := aStorage.FieldByName('BasePrc').AsStringDef( edtBasePrc.Text );

  edtOrdQty.Text    := aStorage.FieldByName('OrdQty').AsStringDef( edtOrdQty.Text );
  edtLCPer.Text     := aStorage.FieldByName('LCPer').AsStringDef( edtLCPer.Text );
  cbStopLiq.Checked     := aStorage.FieldByName('UseStopLiq').AsBooleanDef( false );

end;

procedure TFrmSBreakOut.OnTextNotify(Sender: TObject; Value: String);
begin
  //
  if Sender <> FOs then Exit;
  
  InsertLine( sgLog, 1 );

  with sgLog do
  begin
    Cells[0,1]  := FormatDateTime('hh:nn:ss', now );
    Cells[1,1]  := Value;
  end;
end;

procedure TFrmSBreakOut.SaveEnv(aStorage: TStorage);
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

  aStorage.FieldByName('EndTime').AsFloat         := double( dtEnd.Time );
  aStorage.FieldByName('StartTime').AsFloat       := double( dtStart.Time );
  aStorage.FieldByName('MornigTime').AsFloat      := double( dtMorning.Time );

  aStorage.FieldByName('EntryCnt').AsString := edtEntryCnt.Text;
  aStorage.FieldByName('BasePrc').AsString  := edtBasePrc.Text;
  aStorage.FieldByName('BelowPrc').AsString := edtBelowPrc.Text;

  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('LCPer').AsString     := edtLCPer.Text;
  aStorage.FieldByName('UseStopLiq').AsBoolean   := cbStopLiq.Checked;

end;

procedure TFrmSBreakOut.SetSymbol(aSymbol: TSymbol);
begin
  stSymbol.Caption  := aSymbol.ShortCode;
  stTxt.Panels[1].Text  := Format('%.2f', [ aSymbol.DayOpen ] );
end;

function TFrmSBreakOut.AddOs( aAcnt : TAccount ):TSBreakOut ;
var
  aColl : TStrategys;
  bOk   : boolean;
begin
  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  
  Result := TSBreakOut.Create(aColl, opOs);
  Result.Param := FParam;
  Result.init( aAcnt, Self );
  //Result.Start;
  FOss.Add( Result );
end;

procedure TFrmSBreakOut.Start;
var
  I: Integer;
  aAcnt : TAccount;
  aOs   : TSBreakOut;
begin

  FOss.Clear;
  if FOs <> nil then  
    FOs.OnNotify := nil;
  FOs := nil;

  if FIsFund then
  begin

    if ( FFund = nil ) then
    begin
      ShowMessage(' ?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;

    GetParam;

    for I := FFund.FundItems.Count - 1 downto 0 do
    begin
      aAcnt := FFund.FundAccount[i];
      FOs   := AddOs( aAcnt );
    end;
  end else begin

    if ( FAccount = nil ) then
    begin
      ShowMessage('?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FOs := AddOs( FAccount );
  end;

  if FOs <> nil then
    FOs.OnNotify  := OnTextNotify;

  for I := 0 to FOss.Count - 1 do
    TSBreakOut(FOss.Items[i]).Start;

  plRun.Color := clSkyBlue;
end;

procedure TFrmSBreakOut.Stop;
var
  i : integer;
begin
  for I := 0 to FOss.Count - 1 do
  begin
    TSBreakOut(FOss.Items[i]).Stop;
  //  TSBreakOut(FOss.Items[i]).Free;
  end;
  plRun.Color := clBtnFace;
end;


function TFrmSBreakOut.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmSBreakOut.stTxtDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
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

procedure TFrmSBreakOut.Timer1Timer(Sender: TObject);
var
  aAvgPrc, dLcPrc,  dOpenPL, dTotPL : double;
  ivol, I, iCnt : Integer;
  aItem : TSBreakOut;
begin

  dOpenPL := 0; dTotPL := 0;   ivol := 0;   aAvgPrc := 0;
  dLcPrc  := 0;  iCnt := 0;
  for I := 0 to FOss.Count - 1 do
  begin

    aItem := TSBreakOut( FOss.Items[i]);
    if ( aItem <> nil ) and ( aItem.Position <> nil ) then
    begin
      dOpenPL := dOpenPL + aItem.Position.EntryOTE;
      dTotPL  := dTotPL  + aItem.Position.LastPL;
      iVol    := iVol    + aItem.Position.Volume;
      iCnt    := aItem.OrderCnt;

      dLcPrc  := aItem.Position.AvgPrice + aItem.LcPoint;
      aAvgPrc := aItem.Position.AvgPrice;

    end;
  end;

  if i <= 0 then Exit;  

  stTxt.Panels[0].Text  := IntToStr( iVol);
  stTxt.Tag := iVol;

  stTxt.Panels[1].Text  := Format('%.2f (%.2f)', [ aAvgPrc,
    aAvgPrc +  dLcPrc  ] );

  stTxt.Panels[2].Text  := Format('(%d th.) %.0f, %.0f', [
    iCnt, dOpenPL /1000, dTotPL/1000 ]);

end;

end.
