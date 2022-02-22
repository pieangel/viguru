unit FShortHult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker, CleKrxSymbols,
  CleStorage, UPaveConfig , GleTypes, CleFunds, CleShortHultAxis;

type
  TFrmShortHult = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label17: TLabel;
    edtSymbol: TEdit;
    Button1: TButton;
    edtQty: TEdit;
    edtGap: TEdit;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    gbUseHul: TGroupBox;
    Label6: TLabel;
    Label8: TLabel;
    cbAllcnlNStop: TCheckBox;
    edtRiskAmt: TEdit;
    edtProfitAmt: TEdit;
    cbAutoLiquid: TCheckBox;
    DateTimePicker: TDateTimePicker;
    edtClearPos: TEdit;
    udClearPos: TUpDown;
    stTxt: TStatusBar;
    Panel3: TPanel;
    cbAPI: TCheckBox;
    Button2: TButton;
    Label10: TLabel;
    edtSPoint: TEdit;
    edtOpen: TEdit;
    ColorDialog: TColorDialog;
    btnColor: TButton;
    Label1: TLabel;
    edtQtyLimit: TEdit;
    Button6: TButton;
    edtAccount: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbAllcnlNStopClick(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FSymbol  : TSymbol;
    FTimer   : TQuoteTimer;
    //
    FData : TShortHultData;
    //FShortHultAxis : TShortHultAxis;
    FShortHults: TList;
    FMax, FMin : double;
    FAutoStart : boolean;
    FStartColor : TColor;

    FIsFund : boolean;
    FFund   : TFund;
    procedure initControls;
    procedure GetParam;

    procedure Timer1Timer(Sender: TObject);
  public
    { Public declarations }
    procedure Stop( bCnl : boolean = true );
    procedure Start;
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmShortHult: TFrmShortHult;

implementation

uses
  GAppEnv, GleLib, CleStrategyStore;
{$R *.dfm}

procedure TFrmShortHult.btnColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FStartColor := ColorDialog.Color;
  end;
end;

procedure TFrmShortHult.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbStart.Checked then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.Code;
          //FShortHultAxis := nil;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmShortHult.Button2Click(Sender: TObject);
var
  i : integer;
begin
  GetParam;
  for I := 0 to FShortHults.Count - 1 do
    TShortHultAxis( FShortHults.Items[i] ).Data  := FData;
end;

procedure TFrmShortHult.Button6Click(Sender: TObject);
begin
  if cbStart.Checked then
  begin
    ShowMessage('실행중에는 계좌를 바꿀수 없음');
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

procedure TFrmShortHult.cbAllcnlNStopClick(Sender: TObject);
var
  i : integer;
begin
  FData.UseAutoLiquid := cbAutoLiquid.Checked;
  FData.UseAllCnlNStop := cbAllcnlNStop.Checked;
  //FData.UseBaseLast := cbBaseLast.Checked;

  for I := 0 to FShortHults.Count - 1 do
    TShortHultAxis( FShortHults.Items[i] ).Data  := FData;
end;

procedure TFrmShortHult.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop( false );
end;

procedure TFrmShortHult.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmShortHult.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
        cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmShortHult.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmShortHult.FormCreate(Sender: TObject);
begin
  initControls;

  FShortHults := TList.Create;

  FAutoStart := false;
end;

procedure TFrmShortHult.FormDestroy(Sender: TObject);
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );

  if FShortHults <> nil then
  begin
    FShortHults.Clear;
    FShortHults.Free;
  end;
end;

procedure TFrmShortHult.GetParam;
begin
  with FData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtGap.Text, 5 );
    ClearPos := udClearPos.Position;
    UseAllcnlNStop  := cbAllcnlNStop.Checked;
    LiquidTime  :=  DateTimePicker.Time;
    UseAutoLiquid := cbAutoLiquid.Checked;
    RiskAmt   := StrToFloatDef( edtRiskAmt.Text, 500 );
    ProfitAmt := StrToFloatDef( edtProfitAmt.Text, 3000 );
    QtyLimit  := StrToIntDef( edtQtyLimit.Text, 30 );
    UseAPI := cbAPI.Checked;
    SPoint := StrToFloatDef(edtSPoint.Text, 0);
  end;
                      {
  for I := 0 to FShortHults.Count - 1 do
    TShortHultAxis( FShortHults.Items[i] ).Data  := FData;
    }
end;

procedure TFrmShortHult.initControls;
begin
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;
end;

procedure TFrmShortHult.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
  aFund : TFund;
  aAcnt : TAccount;
begin
  if aStorage = nil then Exit;
  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;
  cbAllcnlNStop.Checked := aStorage.FieldByName('AllcnlNStop').AsBoolean;
  UpDown1.Position := StrToIntDef(aStorage.FieldByName('OrderQty').AsString, 1 );
  UpDown2.Position := StrToIntDef(aStorage.FieldByName('OrderGap').AsString, 3 );
  udClearPos.Position := StrToIntDef(aStorage.FieldByName('ClearPos').AsString, 2 );

  edtRiskAmt.Text  := aStorage.FieldByName('RiskAmt').AsString;
  edtProfitAmt.Text:= aStorage.FieldByName('ProfitAmt').AsString;
  edtQtyLimit.Text:= aStorage.FieldByName('QtyLimit').AsString;

  cbAPI.Checked := aStorage.FieldByName('UseAPI').AsBoolean;

  edtSPoint.Text := aStorage.FieldByName('SPoint').AsString;

  FStartColor := TColor(aStorage.FieldByName('Color').AsInteger);
  if Integer(FStartColor) = 0 then
    FStartColor := clBtnFace;

  stCode := aStorage.FieldByName('HultAccount').AsString;
  stTime := aStorage.FieldByName('ClearTime').AsString;
  if stTime <>'' then
  begin
    DateTimePicker.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;

  if gEnv.RunMode = rtSimulation then
  begin
    FSymbol := gEnv.Engine.SymbolCore.Futures[0];   
  end else
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
  if FSymbol <> nil then
  begin
    edtSymbol.Text  := FSymbol.Code;
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

end;

procedure TFrmShortHult.OnDisplay(Sender: TObject; Value: boolean);
begin
  if Value then
    Panel1.Color := FStartColor
  else
    Panel1.Color := clbtnFace;
end;

procedure TFrmShortHult.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('UseAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('AllcnlNStop').AsBoolean := cbAllcnlNStop.Checked;
  aStorage.FieldByName('OrderQty').AsString := edtQty.Text;
  aStorage.FieldByName('OrderGap').AsString := edtGap.Text;
  aStorage.FieldByName('ClearPos').AsInteger := udClearPos.Position;

  aStorage.FieldByName('RiskAmt').AsString   := edtRiskAmt.Text;
  aStorage.FieldByName('ProfitAmt').AsString := edtProfitAmt.Text;
  aStorage.FieldByName('QtyLimit').AsString  := edtQtyLimit.Text;

  aStorage.FieldByName('SPoint').AsString := edtSPoint.Text;
  aStorage.FieldByName('Color').AsInteger := integer(FStartColor);

  aStorage.FieldByName('UseAPI').AsBoolean := cbAPI.Checked;

  aStorage.FieldByName('ClearTime').AsString := FormatDateTime('hhnnss', DateTimePicker.Time);

  if FSymbol <> nil then
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code
  else
    aStorage.FieldByName('SymbolCode').AsString := '';

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
end;

procedure TFrmShortHult.Start;
var
  aColl : TStrategys;
  aHult : TShortHultAxis;
  i : integer;
  aAcnt : TAccount;
begin
  if ( FSymbol = nil ) or
     (( not FIsFund ) and  ( FAccount = nil )) or
     (( FIsFund ) and  ( FFund = nil )) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  FShortHults.Clear;
  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  GetParam;

  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aAcnt := FFund.FundAccount[i];
      aHult := TShortHultAxis.Create(aColl, opShortHult);
      if i = 0 then      
        aHult.OnResult := OnDisplay;
      FShortHults.Add( aHult );
      aHult.init( aAcnt, FSymbol);
      aHult.Data := FData;
      aHult.Start;
    end;
  end else
  begin
    aHult := TShortHultAxis.Create(aColl, opHult);
    aHult.OnResult := OnDisplay;
    FShortHults.Add( aHult );
    aHult.init( FAccount, FSymbol);
    aHult.Data := FData;
    aHult.Start;
  end;

  if FShortHults.Count > 0 then
  begin
    Button6.Enabled := false;
    button1.Enabled   := false;
    FTimer.Enabled := true;
  end;
end;

procedure TFrmShortHult.Stop(bCnl: boolean);
var
  i : integer;
begin
  Button6.Enabled := true;
  button1.Enabled   := true;

  for I := FShortHults.Count - 1 downto 0 do
  begin
    TShortHultAxis( FShortHults.Items[i] ).Stop( false );
    TShortHultAxis( FShortHults.Items[i] ).OnResult  := nil;
    TShortHultAxis( FShortHults.Items[i] ).Free;
  end;

  FShortHults.Clear;
end;

procedure TFrmShortHult.Timer1Timer(Sender: TObject);
var
  aAsk, aBid, aBase : TShortHultPrice;
  aShortHult : TShortHultAxis;
begin
  if FShortHults.Count = 0 then exit;

  aShortHult :=  TShortHultAxis( FShortHults.Items[0] );
  if aShortHult.Position <> nil then
  begin
    aBase := aShortHult.ShortHultPrices.BasePrice;
    aAsk := aShortHult.ShortHultPrices.GetItem(0);
    aBid := aShortHult.ShortHultPrices.GetItem(aShortHult.ShortHultPrices.Count-1);

    if (aBase <> nil) and (aAsk <> nil) and (aBid <> nil) then
      Panel3.Caption := Format('%.2f -- %.2f -- %.2f', [aAsk.Price, aBase.Price, aBid.Price]);

    if aShortHult.Position <> nil then
    begin
      stTxt.Panels[0].Text  := Format('%d', [aShortHult.Position.Volume]);

      stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
      (aShortHult.Position.LastPL - aShortHult.Position.GetFee)/1000 , aShortHult.MaxPL/1000, aShortHult.MinPL/1000]);
    end;

    if FSymbol <> nil then
      edtOpen.Text := Format('%.2f', [FSymbol.DayOpen]);
  end;

  if aShortHult.Run then
    Panel1.Color := FStartColor;
end;

end.
