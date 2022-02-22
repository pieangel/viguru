unit FleHLTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Math,
  CleHLTrade, CleAccounts, GleLib, CleSymbols, Grids,
  CleStorage;

const
  HLT_NAME = 'BAND';
  COL_WIDTH : array[0..6] of integer = (50,85,85,85,85,85,85);

type
  TFrmHLTrade = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbAccount: TComboBox;
    Panel2: TPanel;
    Label2: TLabel;
    edtSymbol: TEdit;
    Button1: TButton;
    Label5: TLabel;
    edtPrevHigh: TEdit;
    Label6: TLabel;
    edtPrevLow: TEdit;
    gbBand1: TGroupBox;
    dtEnd1: TDateTimePicker;
    Label4: TLabel;
    dtStart1: TDateTimePicker;
    edtBand1: TEdit;
    edtInput1: TEdit;
    Label7: TLabel;
    edtOpen: TEdit;
    Label3: TLabel;
    edtLossCut1: TEdit;
    udL1: TUpDown;
    udP1: TUpDown;
    edtProfit1: TEdit;
    Label9: TLabel;
    Label15: TLabel;
    dtClear: TDateTimePicker;
    cbStart1: TCheckBox;
    btnStart: TButton;
    btnStop: TButton;
    gbBand2: TGroupBox;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    dtEnd2: TDateTimePicker;
    dtStart2: TDateTimePicker;
    edtBand2: TEdit;
    edtInput2: TEdit;
    edtLossCut2: TEdit;
    udL2: TUpDown;
    udP2: TUpDown;
    edtProfit2: TEdit;
    cbStart2: TCheckBox;
    gbBand3: TGroupBox;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    dtEnd3: TDateTimePicker;
    dtStart3: TDateTimePicker;
    edtBand3: TEdit;
    edtInput3: TEdit;
    edtLossCut3: TEdit;
    udL3: TUpDown;
    udP3: TUpDown;
    edtProfit3: TEdit;
    cbStart3: TCheckBox;
    gbBand4: TGroupBox;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    dtEnd4: TDateTimePicker;
    dtStart4: TDateTimePicker;
    edtBand4: TEdit;
    edtInput4: TEdit;
    edtLossCut4: TEdit;
    udL4: TUpDown;
    udP4: TUpDown;
    edtProfit4: TEdit;
    cbStart4: TCheckBox;
    gbBand5: TGroupBox;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    dtEnd5: TDateTimePicker;
    dtStart5: TDateTimePicker;
    edtBand5: TEdit;
    edtInput5: TEdit;
    edtLossCut5: TEdit;
    udL5: TUpDown;
    udP5: TUpDown;
    edtProfit5: TEdit;
    cbStart5: TCheckBox;
    gbBand6: TGroupBox;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    dtEnd6: TDateTimePicker;
    dtStart6: TDateTimePicker;
    edtBand6: TEdit;
    edtInput6: TEdit;
    edtLossCut6: TEdit;
    udL6: TUpDown;
    udP6: TUpDown;
    edtProfit6: TEdit;
    cbStart6: TCheckBox;
    sgInfo: TStringGrid;
    btnClear: TButton;
    btnApply: TButton;
    Label25: TLabel;
    edtQty: TEdit;
    UpDown13: TUpDown;
    edtTerm1: TEdit;
    Label26: TLabel;
    Label27: TLabel;
    UpDown14: TUpDown;
    Label28: TLabel;
    edtTerm2: TEdit;
    UpDown15: TUpDown;
    Label29: TLabel;
    Label30: TLabel;
    edtTerm3: TEdit;
    UpDown16: TUpDown;
    Label31: TLabel;
    Label32: TLabel;
    edtTerm4: TEdit;
    UpDown17: TUpDown;
    Label33: TLabel;
    Label34: TLabel;
    edtTerm5: TEdit;
    UpDown18: TUpDown;
    Label35: TLabel;
    Label36: TLabel;
    edtTerm6: TEdit;
    UpDown19: TUpDown;
    Label37: TLabel;
    cbTrend: TCheckBox;
    stTxt: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure cbStart1Click(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure btnClearClick(Sender: TObject);
    procedure cbTrendClick(Sender: TObject);
  private
    { Private declarations }
    FTrade : THLTrades;
    FAccount : TAccount;
    FSymbol : TSymbol;
    FMin, FMax : double;
    FAutoStart : boolean;
    
  public
    { Public declarations }
    procedure Display;
    procedure OnInfoDisplay(Sender: TObject; Value : boolean);
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmHLTrade: TFrmHLTrade;

implementation

uses
  GAppEnv, CleQuoteBroker, GleConsts;
{$R *.dfm}

procedure TFrmHLTrade.btnApplyClick(Sender: TObject);
begin
  Display;
  FTrade.Config.Account := FAccount;
  FTrade.SubScribe(FSymbol);
  FTrade.Config.Symbol := FSymbol;
  FTrade.Config.ClearTime := dtClear.DateTime;
  FTrade.Config.Trend := cbTrend.Checked;
end;

procedure TFrmHLTrade.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmHLTrade.btnStartClick(Sender: TObject);
var
  i, iTag : integer;
  bStart : boolean;
  stName : string;
begin
  if FTrade.Count = 0 then exit;
  if not FTrade.GetIsParam('') then exit;
  iTag := (Sender as TButton).Tag;

  bStart := false;
  if iTag = 0 then      //Start
    bStart := true;

  for i := 0 to FTrade.Count - 1 do
  begin
    stName := HLT_NAME+IntToStr(i);
    FTrade.SetStart(stName, bStart);
  end;

  cbStart1.Checked := bStart;
  cbStart2.Checked := bStart;
  cbStart3.Checked := bStart;
  cbStart4.Checked := bStart;
  cbStart5.Checked := bStart;
  cbStart6.Checked := bStart;
end;

procedure TFrmHLTrade.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin
        if FTrade.GetIsStart then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.Code;
          edtPrevHigh.Text := FloatToStr(FSymbol.PrevHigh);
          edtPrevLow.Text := FloatToStr(FSymbol.PrevLow);
          btnApplyClick(btnApply);
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;

end;

procedure TFrmHLTrade.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin

    if FTrade.GetIsStart then
    begin
      ShowMessage('실행중에는 계좌를 바꿀수 없음');
      Exit;
    end;
    
    FAccount := aAccount;
  end;
end;

procedure TFrmHLTrade.cbStart1Click(Sender: TObject);
var
  iTag : integer;
  bStart : boolean;
  stName : string;
begin
  if FTrade.Count = 0 then exit;


  iTag := (Sender as TCheckBox).Tag;
  bStart := (Sender as TCheckBox).Checked;
  stName := HLT_NAME+IntToStr(iTag);

  if FTrade.GetIsParam(stName) then
    FTrade.SetStart(stName, bStart)
  else
  begin
    case iTag of
      0 : cbStart1.Checked := false;
      1 : cbStart2.Checked := false;
      2 : cbStart3.Checked := false;
      3 : cbStart4.Checked := false;
      4 : cbStart5.Checked := false;
      5 : cbStart6.Checked := false;
    end;
  end;
end;

procedure TFrmHLTrade.cbTrendClick(Sender: TObject);
begin
  FTrade.Config.Trend := cbTrend.Checked;
end;

procedure TFrmHLTrade.Display;
var
  i : integer;
  dInput : double;
  stName : string;
  dPrevHigh, dPrevLow : double;
  aItem : THLTradeItem;
  iQty : integer;

begin
  if FSymbol = nil then exit;

  dPrevHigh := StrToFloatDef(edtPrevHigh.Text, 0);
  dPrevLow := StrToFloatDef(edtPrevLow.Text, 0);

  //Band1
  dInput := StrToFloatDef(edtInput1.Text,0);
  if dInput = 0 then
    edtBand1.Text := '0'
  else
    edtBand1.Text := Format('%.1f',[(dPrevHigh - dPrevLow)/dInput]);
  FTrade.Config.Param[0].Band := StrToFloatDef(edtBand1.Text,0);
  FTrade.Config.Param[0].STime := dtStart1.DateTime;
  FTrade.Config.Param[0].ETime := dtEnd1.DateTime;
  FTrade.Config.Param[0].LossCut := StrToIntDef(edtLossCut1.Text,0);
  FTrade.Config.Param[0].Profit := StrToIntDef(edtProfit1.Text,0);
  FTrade.Config.Param[0].Term := StrToIntDef(edtTerm1.Text,5);

  //Band2
  dInput := StrToFloatDef(edtInput2.Text,0);
  if dInput = 0 then
    edtBand2.Text := '0'
  else
    edtBand2.Text := Format('%.1f',[(dPrevHigh - dPrevLow)/dInput]);
  FTrade.Config.Param[1].Band := StrToFloatDef(edtBand2.Text,0);
  FTrade.Config.Param[1].STime := dtStart2.DateTime;
  FTrade.Config.Param[1].ETime := dtEnd2.DateTime;
  FTrade.Config.Param[1].LossCut := StrToIntDef(edtLossCut2.Text,0);
  FTrade.Config.Param[1].Profit := StrToIntDef(edtProfit2.Text,0);
  FTrade.Config.Param[1].Term := StrToIntDef(edtTerm2.Text,5);

  //Band3
  dInput := StrToFloatDef(edtInput3.Text,0);
  if dInput = 0 then
    edtBand3.Text := '0'
  else
    edtBand3.Text := Format('%.1f',[(dPrevHigh - dPrevLow)/dInput]);
  FTrade.Config.Param[2].Band := StrToFloatDef(edtBand3.Text,0);
  FTrade.Config.Param[2].STime := dtStart3.DateTime;
  FTrade.Config.Param[2].ETime := dtEnd3.DateTime;
  FTrade.Config.Param[2].LossCut := StrToIntDef(edtLossCut3.Text,0);
  FTrade.Config.Param[2].Profit := StrToIntDef(edtProfit3.Text,0);
  FTrade.Config.Param[2].Term := StrToIntDef(edtTerm3.Text,5);

  //Band4
  dInput := StrToFloatDef(edtInput4.Text,0);
  if dInput = 0 then
    edtBand4.Text := '0'
  else
    edtBand4.Text := Format('%.1f',[(dPrevHigh - dPrevLow)/dInput]);
  FTrade.Config.Param[3].Band := StrToFloatDef(edtBand4.Text,0);
  FTrade.Config.Param[3].STime := dtStart4.DateTime;
  FTrade.Config.Param[3].ETime := dtEnd4.DateTime;
  FTrade.Config.Param[3].LossCut := StrToIntDef(edtLossCut4.Text,0);
  FTrade.Config.Param[3].Profit := StrToIntDef(edtProfit4.Text,0);
  FTrade.Config.Param[3].Term := StrToIntDef(edtTerm4.Text,5);

  //Band5
  dInput := StrToFloatDef(edtInput5.Text,0);
  if dInput = 0 then
    edtBand5.Text := '0'
  else
    edtBand5.Text := Format('%.1f',[(dPrevHigh - dPrevLow)/dInput]);
  FTrade.Config.Param[4].Band := StrToFloatDef(edtBand5.Text,0);
  FTrade.Config.Param[4].STime := dtStart5.DateTime;
  FTrade.Config.Param[4].ETime := dtEnd5.DateTime;
  FTrade.Config.Param[4].LossCut := StrToIntDef(edtLossCut5.Text,0);
  FTrade.Config.Param[4].Profit := StrToIntDef(edtProfit5.Text,0);
  FTrade.Config.Param[4].Term := StrToIntDef(edtTerm5.Text,5);

  //Band6
  dInput := StrToFloatDef(edtInput6.Text,0);
  if dInput = 0 then
    edtBand6.Text := '0'
  else
    edtBand6.Text := Format('%.1f',[(dPrevHigh - dPrevLow)/dInput]);
  FTrade.Config.Param[5].Band := StrToFloatDef(edtBand6.Text,0);
  FTrade.Config.Param[5].STime := dtStart6.DateTime;
  FTrade.Config.Param[5].ETime := dtEnd6.DateTime;
  FTrade.Config.Param[5].LossCut := StrToIntDef(edtLossCut6.Text,0);
  FTrade.Config.Param[5].Profit := StrToIntDef(edtProfit6.Text,0);
  FTrade.Config.Param[5].Term := StrToIntDef(edtTerm5.Text,5);

  edtOpen.Text := FloatToStr(FSymbol.DayOpen);
  iQty := StrToIntDef(edtQty.Text, 1);

  if FTrade.Config.Symbol = FSymbol then
  begin
    for i := 0 to 5 do
    begin
      stName := HLT_NAME+IntToStr(i);
      FTrade.Update(stName, iQty, FTrade.Config.Param[i]);
    end;
  end else if FTrade.Config.Symbol <> FSymbol then
  begin
    FTrade.Reset;
    for i := 0 to 5 do
    begin
      stName := HLT_NAME+IntToStr(i);
      aItem := FTrade.New(stName, iQty, FTrade.Config.Param[i]);

      sgInfo.Objects[i+1,0] := aItem.Info;

    end;
  end;
end;

procedure TFrmHLTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmHLTrade.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FTrade := THLTrades.Create;
  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;
  FTrade.OnResult := OnInfoDisplay;
  for i := 0 to 6 do
    sgInfo.ColWidths[i] := COL_WIDTH[i];
  FAutoStart := false;
end;

procedure TFrmHLTrade.FormDestroy(Sender: TObject);
begin
  FTrade.Free;
end;

procedure TFrmHLTrade.LoadEnv(aStorage: TStorage);
var
  stCode : string;
begin
  if aStorage = nil then Exit;
  cbTrend.Checked := aStorage.FieldByName('cbTrend').AsBoolean;

  udL1.Position := aStorage.FieldByName('edtLossCut1').AsInteger;
  udL2.Position := aStorage.FieldByName('edtLossCut2').AsInteger;
  udL3.Position := aStorage.FieldByName('edtLossCut3').AsInteger;
  udL4.Position := aStorage.FieldByName('edtLossCut4').AsInteger;
  udL5.Position := aStorage.FieldByName('edtLossCut5').AsInteger;
  udL6.Position := aStorage.FieldByName('edtLossCut6').AsInteger;

  udP1.Position := aStorage.FieldByName('edtProfit1').AsInteger;
  udP2.Position := aStorage.FieldByName('edtProfit2').AsInteger;
  udP3.Position := aStorage.FieldByName('edtProfit3').AsInteger;
  udP4.Position := aStorage.FieldByName('edtProfit4').AsInteger;
  udP5.Position := aStorage.FieldByName('edtProfit5').AsInteger;
  udP6.Position := aStorage.FieldByName('edtProfit6').AsInteger;


  edtLossCut1.Text := aStorage.FieldByName('edtLossCut1').AsString;
  edtLossCut2.Text := aStorage.FieldByName('edtLossCut2').AsString;
  edtLossCut3.Text := aStorage.FieldByName('edtLossCut3').AsString;
  edtLossCut4.Text := aStorage.FieldByName('edtLossCut4').AsString;
  edtLossCut5.Text := aStorage.FieldByName('edtLossCut5').AsString;
  edtLossCut6.Text := aStorage.FieldByName('edtLossCut6').AsString;

  edtProfit1.Text := aStorage.FieldByName('edtProfit1').AsString;
  edtProfit2.Text := aStorage.FieldByName('edtProfit2').AsString;
  edtProfit3.Text := aStorage.FieldByName('edtProfit3').AsString;
  edtProfit4.Text := aStorage.FieldByName('edtProfit4').AsString;
  edtProfit5.Text := aStorage.FieldByName('edtProfit5').AsString;
  edtProfit6.Text := aStorage.FieldByName('edtProfit6').AsString;

  edtInPut1.Text := aStorage.FieldByName('edtInPut1').AsString;
  edtInPut2.Text := aStorage.FieldByName('edtInPut2').AsString;
  edtInPut3.Text := aStorage.FieldByName('edtInPut3').AsString;
  edtInPut4.Text := aStorage.FieldByName('edtInPut4').AsString;
  edtInPut5.Text := aStorage.FieldByName('edtInPut5').AsString;
  edtInPut6.Text := aStorage.FieldByName('edtInPut6').AsString;

  upDown14.Position := aStorage.FieldByName('edtTerm1').AsInteger;
  upDown15.Position := aStorage.FieldByName('edtTerm2').AsInteger;
  upDown16.Position := aStorage.FieldByName('edtTerm3').AsInteger;
  upDown17.Position := aStorage.FieldByName('edtTerm4').AsInteger;
  upDown18.Position := aStorage.FieldByName('edtTerm5').AsInteger;
  upDown19.Position := aStorage.FieldByName('edtTerm6').AsInteger;

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;
  if gEnv.RunMode = rtSimulation then
    FSymbol := gEnv.Engine.SymbolCore.Futures[0]
  else
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if FSymbol <> nil then
  begin
    edtSymbol.Text  := FSymbol.Code;
    edtSymbol.Text  := FSymbol.Code;
    edtPrevHigh.Text := FloatToStr(FSymbol.PrevHigh);
    edtPrevLow.Text := FloatToStr(FSymbol.PrevLow);
  end;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
    btnApplyClick(btnApply);
  end;

end;

procedure TFrmHLTrade.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('cbTrend').AsBoolean := cbTrend.Checked;

  aStorage.FieldByName('edtLossCut1').AsString := edtLossCut1.Text;
  aStorage.FieldByName('edtLossCut2').AsString := edtLossCut2.Text;
  aStorage.FieldByName('edtLossCut3').AsString := edtLossCut3.Text;
  aStorage.FieldByName('edtLossCut4').AsString := edtLossCut4.Text;
  aStorage.FieldByName('edtLossCut5').AsString := edtLossCut5.Text;
  aStorage.FieldByName('edtLossCut6').AsString := edtLossCut6.Text;


  aStorage.FieldByName('edtProfit1').AsString := edtProfit1.Text;
  aStorage.FieldByName('edtProfit2').AsString := edtProfit2.Text;
  aStorage.FieldByName('edtProfit3').AsString := edtProfit3.Text;
  aStorage.FieldByName('edtProfit4').AsString := edtProfit4.Text;
  aStorage.FieldByName('edtProfit5').AsString := edtProfit5.Text;
  aStorage.FieldByName('edtProfit6').AsString := edtProfit6.Text;


  aStorage.FieldByName('edtTerm1').AsString := edtTerm1.Text;
  aStorage.FieldByName('edtTerm2').AsString := edtTerm2.Text;
  aStorage.FieldByName('edtTerm3').AsString := edtTerm3.Text;
  aStorage.FieldByName('edtTerm4').AsString := edtTerm4.Text;
  aStorage.FieldByName('edtTerm5').AsString := edtTerm5.Text;
  aStorage.FieldByName('edtTerm6').AsString := edtTerm6.Text;


  aStorage.FieldByName('edtInPut1').AsString := edtInPut1.Text;
  aStorage.FieldByName('edtInPut2').AsString := edtInPut2.Text;
  aStorage.FieldByName('edtInPut3').AsString := edtInPut3.Text;
  aStorage.FieldByName('edtInPut4').AsString := edtInPut4.Text;
  aStorage.FieldByName('edtInPut5').AsString := edtInPut5.Text;
  aStorage.FieldByName('edtInPut6').AsString := edtInPut6.Text;

  if FSymbol <> nil then
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code
  else
    aStorage.FieldByName('SymbolCode').AsString := '';

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';
end;

procedure TFrmHLTrade.OnInfoDisplay(Sender: TObject; Value: boolean);
var
  i : integer;
  stInfo : string;
  aInfo : THLInfo;
  aItem : THLTradeItem;

  aQuote : TQuote;
begin
  if FSymbol = nil then exit;

  aQuote := Sender as TQuote;

  if (aQuote <> nil) and (aQuote.FTicks.Count > 0) and (not FAutoStart) and (gEnv.RunMode = rtSimulation) then
  begin
    FAutoStart := true;
    btnStartClick(btnStart);
  end;

  edtOpen.Text := Format('%.1f', [FSymbol.DayOpen]);
  sgInfo.Cells[0,0] := Format('%.1f', [FSymbol.Last]);
  for i := 1 to sgInfo.ColCount - 1 do
  begin
    aInfo := sgInfo.Objects[i,0] as THLInfo;
    if aInfo = nil then continue;

    stInfo := Format('%s%d(%.1f)',[HLT_NAME, i, aInfo.FillPrice]);
    sgInfo.Cells[i,0] := stInfo;
    stInfo := Format('p:%d,L:%d',[aInfo.ProfitTick, aInfo.LossTick]);
    sgInfo.Cells[i,1] := stInfo;
  end;


  if FTrade.Position <> nil then
  begin
    FMin := Min( FMin, (FTrade.Position.LastPL - FTrade.Position.GetFee) );
    FMax := Max( FMax, (FTrade.Position.LastPL - FTrade.Position.GetFee) );

    stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
          (FTrade.Position.LastPL - FTrade.Position.GetFee)/1000 , FMax/1000, FMin/1000 ]);
  end;

end;



procedure TFrmHLTrade.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  dData : double;
  aInfo : THLInfo;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;
  with sgInfo do
  begin
    stTxt := Cells[ ACol, ARow];
    aInfo := Objects[ACol, 0] as THLInfo;
    if aInfo <> nil then
    begin
      if aInfo.Side = 1 then
        aBack := LONG_COLOR
      else if aInfo.Side = -1 then
        aBack := SHORT_COLOR;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;
end;

end.


