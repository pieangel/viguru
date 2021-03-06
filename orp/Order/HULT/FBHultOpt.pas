unit FBHultOpt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math,
  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker, CleKrxSymbols, CleBHultOptAxis,
  CleStorage, UPaveConfig , GleTypes , ComCtrls, StdCtrls,
  ExtCtrls
  ;

type
  TfrmBHultOpt = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    Panel2: TPanel;
    Label3: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    edtQty: TEdit;
    UpDown1: TUpDown;
    gbUseHul: TGroupBox;
    Label6: TLabel;
    cbAllcnlNStop: TCheckBox;
    edtRiskAmt: TEdit;
    UpDown5: TUpDown;
    gbRiquid: TGroupBox;
    DateTimePicker: TDateTimePicker;
    cbAutoLiquid: TCheckBox;
    edtPrevHigh: TEdit;
    edtPrevLow: TEdit;
    edtBand: TEdit;
    edtOpen: TEdit;
    edtInput: TEdit;
    edtTerm: TEdit;
    udTerm: TUpDown;
    DateTimePicker1: TDateTimePicker;
    GroupBox1: TGroupBox;
    Label19: TLabel;
    edtHult: TEdit;
    udHult: TUpDown;
    edtHultPL: TEdit;
    stTxt: TStatusBar;
    Price: TLabel;
    edtPrice: TEdit;
    Label21: TLabel;
    edtAddEntry: TEdit;
    udAddEntry: TUpDown;
    Label22: TLabel;
    edtAddEntryCnt: TEdit;
    UdAddEntryCnt: TUpDown;
    edtCode: TEdit;
    edtPos: TEdit;
    edtHigh: TEdit;
    edtLow: TEdit;
    Label2: TLabel;
    edtQtyDiv: TEdit;
    udQtyDiv: TUpDown;
    Label4: TLabel;
    edtProfitAmt: TEdit;
    udProfitAmt: TUpDown;
    Label5: TLabel;
    Edit1: TEdit;
    udHultGap: TUpDown;
    btnApply: TButton;
    cbCalS: TCheckBox;
    btnColor: TButton;
    ColorDialog: TColorDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure btnColorClick(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FBHultOptAxis : TBHultOptAxis;
    FTimer   : TQuoteTimer;
    FBHultOptData : TBHultOptData;
    FAutoStart : boolean;
    FMax, FMin : double;
    FSymbol : TSymbol;
    FStartColor : TColor;

    procedure initControls;
    procedure GetParam;
    procedure SetBand;
    procedure Timer1Timer(Sender: TObject);
    procedure OnDisplay(Sender: TObject; Value: boolean);
  public
    { Public declarations }
    procedure Stop;
    procedure Start;
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  frmBHultOpt: TfrmBHultOpt;

implementation
uses
  GAppEnv, GleLib, CleStrategyStore;

{$R *.dfm}


procedure TfrmBHultOpt.btnApplyClick(Sender: TObject);
begin
  with FBHultOptData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    LiquidTime  :=  DateTimePicker.Time;
    RiskAmt := UpDown5.Position;
    ProfitAmt := udProfitAmt.Position;
    OptPrice := StrToFloatDef(edtPrice.Text, 0.5);
  end;
  if FBHultOptAxis <> nil then
    FBHultOptAxis.BHultData := FBHultOptData;
end;

procedure TfrmBHultOpt.btnColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FStartColor := ColorDialog.Color;
  end;
end;

procedure TfrmBHultOpt.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin
    if cbStart.Checked then
    begin
      ShowMessage('?????????? ?????? ?????? ????');
      Exit;
    end;
    FAccount := aAccount;
    FBHultOptAxis := nil;
  end;
end;

procedure TfrmBHultOpt.cbAutoLiquidClick(Sender: TObject);
begin
  FBHultOptData.UseAutoLiquid := cbAutoLiquid.Checked;
  FBHultOptData.UseAllCnlNStop := cbAllcnlNStop.Checked;
  if FBHultOptAxis <> nil then
    FBHultOptAxis.BHultData := FBHultOptData;

end;

procedure TfrmBHultOpt.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TfrmBHultOpt.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TfrmBHultOpt.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if FAccount <> nil then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TfrmBHultOpt.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TfrmBHultOpt.FormCreate(Sender: TObject);
begin
  initControls;

  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );
  
  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;
  FSymbol := gEnv.Engine.SymbolCore.Futures[0];
  SetBand;
  FAutoStart := false;
end;

procedure TfrmBHultOpt.FormDestroy(Sender: TObject);
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  FBHultOptAxis.Free;
end;

procedure TfrmBHultOpt.GetParam;
begin
  with FBHultOptData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    UseAllcnlNStop  := cbAllcnlNStop.Checked;
    LiquidTime  :=  DateTimePicker.Time;
    UseAutoLiquid := cbAutoLiquid.Checked;
    RiskAmt := UpDown5.Position;
    ProfitAmt := udProfitAmt.Position;
    OptPrice := StrToFloatDef(edtPrice.Text, 0.5);
    StartTime  :=  DateTimePicker1.Time;
    Band := StrToFloatDef(edtBand.Text, 0);
    Term := StrToIntDef(edtTerm.Text, 5);
    HultPL := UdHult.Position;
    AddEntry := udAddEntry.Position;
    AddEntryCnt := udAddEntryCnt.Position;
    QtyDiv := udQtyDiv.Position;
    HultGap := udHultGap.Position;
    HultCalS := cbCalS.Checked;
  end;

  if FBHultOptAxis <> nil then
    FBHultOptAxis.BHultData := FBHultOptData;
end;

procedure TfrmBHultOpt.initControls;
begin
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;
end;

procedure TfrmBHultOpt.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin
  if aStorage = nil then Exit;
  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;
  cbAllcnlNStop.Checked := aStorage.FieldByName('AllcnlNStop').AsBoolean;

  UpDown1.Position := StrToIntDef(aStorage.FieldByName('OrderQty').AsString, 1 );
  udHultGap.Position := StrToIntDef(aStorage.FieldByName('HultGap').AsString, 5 );

  UpDown5.Position := StrToIntDef(aStorage.FieldByName('RiskAmt').AsString, 9999 );
  udProfitAmt.Position := StrToIntDef(aStorage.FieldByName('ProfitAmt').AsString, 30000 );

  udTerm.Position := StrToIntDef(aStorage.FieldByName('Term').AsString, 5);

  edtPrice.Text :=  aStorage.FieldByName('Price').AsString;
  if edtPrice.Text = '' then
    edtPrice.Text := '0.5';

  edtInput.Text :=  aStorage.FieldByName('Input').AsString;
  if edtInput.Text = '' then
    edtInput.Text := '2.5';

  udHult.Position := StrToIntDef(aStorage.FieldByName('Hult').AsString, 400);
  udAddEntry.Position := StrToIntDef(aStorage.FieldByName('AddEntry').AsString, 100);
  udAddEntryCnt.Position := StrToIntDef(aStorage.FieldByName('AddEntryCnt').AsString, 3);
  udQtyDiv.Position := StrToIntDef(aStorage.FieldByName('QtyDiv').AsString, 1);
  cbCalS.Checked := aStorage.FieldByName('cbCalS').AsBoolean;
  FStartColor := TColor(aStorage.FieldByName('Color').AsInteger);
  if Integer(FStartColor) = 0 then
    FStartColor := clBtnFace;


  stTime := aStorage.FieldByName('ClearTime').AsString;
  if stTime <>'' then
  begin
    DateTimePicker.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;

  stTime := aStorage.FieldByName('StartTime').AsString;
  if stTime <>'' then
  begin
    DateTimePicker1.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;
  stCode  := aStorage.FieldByName('SymbolCode').AsString ;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
  end;

end;

procedure TfrmBHultOpt.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('UseAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('AllcnlNStop').AsBoolean := cbAllcnlNStop.Checked;
  aStorage.FieldByName('OrderQty').AsString := edtQty.Text;
  aStorage.FieldByName('HultGap').AsInteger := udHultGap.Position;
  aStorage.FieldByName('RiskAmt').AsInteger := UpDown5.Position;
  aStorage.FieldByName('ProfitAmt').AsInteger := udProfitAmt.Position;

  aStorage.FieldByName('Term').AsString := edtTerm.Text;
  aStorage.FieldByName('Input').AsString := edtInput.Text;
  aStorage.FieldByName('Price').AsString := edtPrice.Text;

  aStorage.FieldByName('StartTime').AsString := FormatDateTime('hhnnss', DateTimePicker1.Time);
  aStorage.FieldByName('ClearTime').AsString := FormatDateTime('hhnnss', DateTimePicker.Time);

  aStorage.FieldByName('Hult').AsInteger := udHult.Position;
  aStorage.FieldByName('AddEntry').AsInteger := udAddEntry.Position;
  aStorage.FieldByName('AddEntryCnt').AsInteger := udAddEntryCnt.Position;
  aStorage.FieldByName('QtyDiv').AsInteger := udQtyDiv.Position;
  aStorage.FieldByName('cbCalS').AsBoolean := cbCalS.Checked;
  aStorage.FieldByName('Color').AsInteger := integer(FStartColor);

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';
end;

procedure TfrmBHultOpt.SetBand;
var
  dInput : double;
begin
  if FSymbol = nil then exit;

  dInput := StrToFloatDef(edtInput.Text,0);
  edtPrevHigh.Text := Format('%.1f', [FSymbol.PrevHigh]);
  edtPrevLow.Text := Format('%.1f', [FSymbol.PrevLow]);
  if dInput = 0 then
    edtBand.Text := '0'
  else
    edtBand.Text := Format('%.1f',[(FSymbol.PrevHigh - FSymbol.PrevLow)/dInput]);

end;
procedure TfrmBHultOpt.OnDisplay(Sender: TObject; Value: boolean);
begin
  if Value then
    Panel1.Color := FStartColor
  else
    Panel1.Color := clbtnFace;
end;

procedure TfrmBHultOpt.Start;
var
  aColl : TStrategys;
begin
  if ( FSymbol = nil ) or ( FAccount = nil ) then
  begin
    ShowMessage('???????? ????????. ');
    cbStart.Checked := false;
    Exit;
  end;
  if FBHultOptAxis = nil then
  begin
    aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
    FBHultOptAxis := TBHultOptAxis.Create(aColl, opBHultOpt);
    FBHultOptAxis.OnResult := OnDisplay;
    SetBand;
  end;


  if FBHultOptAxis <> nil then
  begin
    cbAccount.Enabled := false;
    udHultGap.Enabled := false;

    FBHultOptAxis.init( FAccount, FSymbol );
    GetParam;
    FBHultOptAxis.BHultData := FBHultOptData;
    FBHultOptAxis.Start;
    FTimer.Enabled := true;
  end;

end;

procedure TfrmBHultOpt.Stop;
begin
  cbAccount.Enabled := true;
  udHultGap.Enabled := true;

  if FBHultOptAxis <> nil then
  begin
    FBHultOptAxis.Stop(false);
    FBHultOptAxis.OnResult := nil;
    FBHultOptAxis.Free;
    FBHultOptAxis := nil;
  end;
end;

procedure TfrmBHultOpt.Timer1Timer(Sender: TObject);
begin
  if FBHultOptAxis = nil then exit;

  if FBHultOptAxis.VirtualHult <> nil then
  begin
    edtHultPL.Text := Format('%.0f', [ (FBHultOptAxis.VirtualHult.HultPrices.PL) /1000]);
    edtPos.Text := IntToStr(FBhultOptAxis.VirtualHult.HultPrices.Volume);
    edtHigh.Text := Format('%.0f', [ (FBHultOptAxis.VirtualHult.HultPrices.MaxPL) /1000]);
    edtLow.Text := Format('%.0f', [ (FBHultOptAxis.VirtualHult.HultPrices.MinPL) /1000]);
  end;

  if FBHultOptAxis.Position <> nil then
  begin
    FMin := Min( FMin, (FBHultOptAxis.TotPL) );
    FMax := Max( FMax, (FBHultOptAxis.TotPL) );

    stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
          FBHultOptAxis.TotPL/1000 , FMax/1000, FMin/1000]);
    stTxt.Panels[0].Text := Format('%d', [FBHultOptAxis.Position.Volume]);
  end;

  if FSymbol <> nil then
    edtOpen.Text := Format('%.1f', [FSymbol.DayOpen]);

  if FBHultOptAxis.OrderSymbol <> nil then
    edtCode.Text := FBHultOptAxis.OrderSymbol.ShortCode;

  if FBHultOptAxis.Run then
    Panel1.Color := FStartColor;
end;

end.
