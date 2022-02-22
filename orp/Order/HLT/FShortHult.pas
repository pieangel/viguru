unit FShortHult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker, CleKrxSymbols,
  CleStorage, UPaveConfig , GleTypes, CleShortHultAxis;

type
  TFrmShortHult = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure cbAllcnlNStopClick(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FSymbol  : TSymbol;
    FTimer   : TQuoteTimer;
    //
    FData : TShortHultData;
    FShortHultAxis : TShortHultAxis;
    FMax, FMin : double;
    FAutoStart : boolean;
    FStartColor : TColor;

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
          FShortHultAxis := nil;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmShortHult.Button2Click(Sender: TObject);
begin
  GetParam;
  if FShortHultAxis <> nil then
    FShortHultAxis.Data := FData;
end;

procedure TFrmShortHult.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin
    if cbStart.Checked then
    begin
      ShowMessage('실행중에는 계좌를 바꿀수 없음');
      Exit;
    end;
    FAccount := aAccount;
    FShortHultAxis := nil;
  end;
end;

procedure TFrmShortHult.cbAllcnlNStopClick(Sender: TObject);
begin
  FData.UseAutoLiquid := cbAutoLiquid.Checked;
  FData.UseAllCnlNStop := cbAllcnlNStop.Checked;
  //FData.UseBaseLast := cbBaseLast.Checked;

  if FShortHultAxis <> nil then
    FShortHultAxis.Data := FData;
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
  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );
  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

  FAutoStart := false;
end;

procedure TFrmShortHult.FormDestroy(Sender: TObject);
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  FShortHultAxis.Free;
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

  if FShortHultAxis <> nil then
    FShortHultAxis.Data := FData;
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
    {
    if (FSymbol as TFuture).DaysToExp = 1 then
      DateTimePicker.Time := EncodeTime(14,45,0,0)
    else
      DateTimePicker.Time := EncodeTime(15,0,0,0);
     }

  end else
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
  if FSymbol <> nil then
  begin
    edtSymbol.Text  := FSymbol.Code;
  end;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
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

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';
end;

procedure TFrmShortHult.Start;
var
  aColl : TStrategys;
begin
  if ( FSymbol = nil ) or ( FAccount = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if FShortHultAxis = nil then
  begin
    aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
    FShortHultAxis := TShortHultAxis.Create(aColl, opShortHult);
    FShortHultAxis.OnResult := OnDisplay;
  end;

  if FShortHultAxis <> nil then
  begin
    cbAccount.Enabled := false;
    button1.Enabled   := false;
    FShortHultAxis.init( FAccount, FSymbol );
    GetParam;
    FShortHultAxis.Data := FData;
    FShortHultAxis.Start;
    FTimer.Enabled := true;
  end;
end;

procedure TFrmShortHult.Stop(bCnl: boolean);
begin
  cbAccount.Enabled := true;
  button1.Enabled   := true;

  if FShortHultAxis <> nil then
  begin
    FShortHultAxis.Stop( bCnl );
    FShortHultAxis.OnResult := nil;
    FShortHultAxis.Free;
    FShortHultAxis := nil;
  end;
end;

procedure TFrmShortHult.Timer1Timer(Sender: TObject);
var
  aAsk, aBid, aBase : TShortHultPrice;
begin
  if FShortHultAxis = nil then exit;

  aBase := FShortHultAxis.ShortHultPrices.BasePrice;
  aAsk := FShortHultAxis.ShortHultPrices.GetItem(0);
  aBid := FShortHultAxis.ShortHultPrices.GetItem(FShortHultAxis.ShortHultPrices.Count-1);

  if (aBase <> nil) and (aAsk <> nil) and (aBid <> nil) then
    Panel3.Caption := Format('%.2f -- %.2f -- %.2f', [aAsk.Price, aBase.Price, aBid.Price]);

  if FShortHultAxis.Position <> nil then
  begin
    stTxt.Panels[0].Text  := Format('%d', [FShortHultAxis.Position.Volume]);

    stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
    (FShortHultAxis.Position.LastPL - FShortHultAxis.Position.GetFee)/1000 , FShortHultAxis.MaxPL/1000, FShortHultAxis.MinPL/1000]);
  end;

  if FSymbol <> nil then
    edtOpen.Text := Format('%.2f', [FSymbol.DayOpen]);

  if FShortHultAxis.Run then
    Panel1.Color := FStartColor;
end;

end.
