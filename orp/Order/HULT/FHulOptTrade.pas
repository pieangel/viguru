unit FHulOptTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  Math,

  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker,

  CleStorage, UPaveConfig , CleHultOptAxis, GleTypes, ComCtrls, StdCtrls,
  ExtCtrls;

type
  TFrmHultOpt = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtSymbol: TEdit;
    edtQty: TEdit;
    edtGap: TEdit;
    udQty: TUpDown;
    udGap: TUpDown;
    gbUseHul: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    cbAllcnlNStop: TCheckBox;
    edtRiskAmt: TEdit;
    udRiskAmt: TUpDown;
    gbRiquid: TGroupBox;
    dtClear: TDateTimePicker;
    cbAutoLiquid: TCheckBox;
    edtQuoting: TEdit;
    udQuoting: TUpDown;
    stTxt: TStatusBar;
    Label8: TLabel;
    edtPrice: TEdit;
    edtLast: TEdit;
    rgCallPut: TRadioGroup;
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtQtyChange(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure dtClearChange(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FTimer   : TQuoteTimer;
    FData : THultOptData;
    FHultOptAxis : THultOptAxis;
    FPosition : TPosition;
    FEndTime : TDateTime;
    FAutoStart  : boolean;
    procedure initControls;
    procedure GetParam;
    procedure Timer1Timer(Sender: TObject);
  public
    { Public declarations }
    procedure Stop;
    procedure Start;
    procedure OnDisplay(Sender: TObject; Value : boolean );
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmHultOpt: TFrmHultOpt;

implementation
{$R *.dfm}
uses
  GAppEnv , GleLib, CleStrategyStore
  ;

{ TFrmHultOpt }

procedure TFrmHultOpt.cbAccountChange(Sender: TObject);
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
    FHultOptAxis := nil;
  end;
end;

procedure TFrmHultOpt.cbAutoLiquidClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TCheckBox ).Tag;

  if iTag = 0 then
    FData.UseAutoLiquid := cbAutoLiquid.Checked
  else
    FData.UseAllcnlNStop  := cbAllcnlNStop.Checked;

  if FHultOptAxis <> nil then
    FHultOptAxis.Data := FData;
end;

procedure TFrmHultOpt.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TFrmHultOpt.dtClearChange(Sender: TObject);
begin
  FData.LiquidTime  :=  dtClear.Time;
  if FHultOptAxis <> nil then
    FHultOptAxis.Data := FData;
end;

procedure TFrmHultOpt.edtQtyChange(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TEdit ).Tag;
  with FData do
  case iTag of
    0 : OrdQty  := StrToIntDef( edtQty.Text, 1 );
    1 : OrdGap  := StrToIntDef( edtGap.Text, 5 );
    2 : QuotingQty := StrTointDef( edtQuoting.Text, 2 );
    3 : OptPrice := StrToFloatDef( edtPrice.Text, 1.2 );
    4 : RiskAmt := udRiskAmt.Position;
    else Exit;
  end;

  if FHultOptAxis <> nil then
    FHultOptAxis.Data := FData;
end;

procedure TFrmHultOpt.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmHultOpt.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if FAccount <> nil then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmHultOpt.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmHultOpt.FormCreate(Sender: TObject);
begin
  initControls;
  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;
  FPosition   := nil;
  FAutoStart  := false;
end;

procedure TFrmHultOpt.FormDestroy(Sender: TObject);
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  FHultOptAxis.Free;
end;

procedure TFrmHultOpt.GetParam;
begin
  with FData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtGap.Text, 1 );
    QuotingQty := StrTointDef( edtQuoting.Text, 2 );
    OptPrice := StrToFloatDef( edtPrice.Text, 1.2 );
    UseAllcnlNStop  := cbAllcnlNStop.Checked;
    LiquidTime  :=  dtClear.Time;
    UseAutoLiquid := cbAutoLiquid.Checked;
    RiskAmt := udRiskAmt.Position;
    CallPut := rgCallPut.ItemIndex;
  end;

  if FHultOptAxis <> nil then
    FHultOptAxis.Data := FData;
end;

procedure TFrmHultOpt.initControls;
begin
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;
end;

procedure TFrmHultOpt.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin
  if aStorage = nil then Exit;

  udQty.Position := StrToIntDef(aStorage.FieldByName('Qty').AsString, 1 );
  udGap.Position := StrToIntDef(aStorage.FieldByName('OrderGap').AsString, 3 );
  udQuoting.Position := StrToIntDef(aStorage.FieldByName('QuotingQty').AsString, 5 );

  if aStorage.FieldByName('Price').AsString = '' then
    edtPrice.Text := '1.2'
  else
    edtPrice.Text := aStorage.FieldByName('Price').AsString;

  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;

  stTime := aStorage.FieldByName('dtClear').AsString;

  if stTime <>'' then
  begin
    dtClear.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;

  udRiskAmt.Position := StrToIntDef(aStorage.FieldByName('RiskAmt').AsString, 1000 );

  cbAllcnlNStop.Checked := aStorage.FieldByName('UseAllcnlNStop').AsBoolean;
  rgCallPut.ItemIndex := aStorage.FieldByName('CallPut').AsInteger;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
  end;

end;

procedure TFrmHultOpt.OnDisplay(Sender: TObject; Value: boolean);
begin

end;

procedure TFrmHultOpt.SaveEnv(aStorage: TStorage);
begin
if aStorage = nil then Exit;

  aStorage.FieldByName('Qty').AsString := edtQty.Text;
  aStorage.FieldByName('OrderGap').AsString := edtGap.Text;
  aStorage.FieldByName('QuotingQty').AsString := edtQuoting.Text;
  aStorage.FieldByName('Price').AsString := edtPrice.Text;
  aStorage.FieldByName('UseAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('dtClear').AsString := FormatDateTime('hhnnss', dtClear.Time);
  aStorage.FieldByName('RiskAmt').AsInteger := udRiskAmt.Position;
  aStorage.FieldByName('UseAllcnlNStop').AsBoolean := cbAllcnlNStop.Checked;
  aStorage.FieldByName('CallPut').AsInteger := rgCallPut.ItemIndex;
  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';
end;

procedure TFrmHultOpt.Start;
var
  aColl : TStrategys;
begin
  if FAccount = nil then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;
  if FHultOptAxis = nil then
  begin
    aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
    FHultOptAxis := THultOptAxis.Create(aColl, opOptHult);
    FHultOptAxis.OnResult := OnDisplay;
  end;


  if THultOptAxis <> nil then
  begin
    cbAccount.Enabled := false;

    FHultOptAxis.init( FAccount, nil );

    GetParam;
    FHultOptAxis.Data := FData;
    FHultOptAxis.Start;
    FTimer.Enabled := true;
  end;

end;

procedure TFrmHultOpt.Stop;
begin
  cbAccount.Enabled := true;

  if FHultOptAxis <> nil then
  begin
    FHultOptAxis.Stop(false);
    FHultOptAxis.OnResult := nil;
    FHultOptAxis.Free;
    FHultOptAxis := nil;
  end;
end;

procedure TFrmHultOpt.Timer1Timer(Sender: TObject);
begin
  if FHultOptAxis = nil then exit;
  if FHultOptAxis.Position <> nil then
  begin
    stTxt.Panels[0].Text := Format('%s, %d, %d', [ ifthenStr( FHultOptAxis.MyFills.Side > 0,'L','S'),
    FHultOptAxis.MyFills.Count, FHultOptAxis.Position.MaxPos ]);

    stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
          (FHultOptAxis.Position.LastPL - FHultOptAxis.Position.GetFee)/1000 , FHultOptAxis.MaxPL/1000, FHultOptAxis.MinPL/1000 ]);
  end;

  if FHultOptAxis.Symbol <> nil then
  begin
    edtSymbol.Text := FHultOptAxis.Symbol.ShortCode;
    edtLast.Text := Format('%.2f', [FHultOptAxis.Symbol.Last]);
  end;
end;

end.
