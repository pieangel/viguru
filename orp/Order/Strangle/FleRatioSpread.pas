unit FleRatioSpread;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, ComCtrls,
  CleRatioSpread, CleAccounts, CleQuoteBroker, CleStrategyStore;

const
  COL_CNT = 5;
  GridTitle : array[0..4] of string =
                            ('Code', '현재가', '포지션', '평가손익', 'Trading');

  GridWidth : array[0..4] of integer =
                            (60, 60, 50, 90, 50);
type
  TFrmRatioSpread = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    ComboAccount: TComboBox;
    cbStart: TCheckBox;
    btnSymbol: TButton;
    Label1: TLabel;
    edtQty: TEdit;
    Label2: TLabel;
    edtGap: TEdit;
    edtLow: TEdit;
    edtHigh: TEdit;
    Label7: TLabel;
    Label3: TLabel;
    sgOpt: TStringGrid;
    Label4: TLabel;
    edtGrade: TEdit;
    btnClear: TButton;
    StatusBar1: TStatusBar;
    sgInfo: TStringGrid;
    Label5: TLabel;
    edtUpBid2: TEdit;
    Label6: TLabel;
    edtDownBid2: TEdit;
    Label8: TLabel;
    edtRatio: TEdit;
    edtPL: TEdit;
    Label11: TLabel;
    cbHdege: TCheckBox;
    edtFut: TEdit;
    rgEntry: TRadioGroup;
    Label9: TLabel;
    edtUpBase: TEdit;
    edtDownBase: TEdit;
    Label10: TLabel;
    Label12: TLabel;
    udUp: TUpDown;
    udDown: TUpDown;
    btnDownApply: TButton;
    btnUpApply: TButton;
    btnDownInit: TButton;
    btnUpInit: TButton;
    cbTwoSymbol: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure rgEntryClick(Sender: TObject);
    procedure btnDownApplyClick(Sender: TObject);
    procedure udUpClick(Sender: TObject; Button: TUDBtnType);
    procedure btnDownInitClick(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FTrade : TRatioSpreadTrade;
    procedure InitGrid;
    procedure DisplayInfo(aQuote : TQuote);
    procedure DisplayOpt(aQuote : TQuote);
  public
    { Public declarations }
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmRatioSpread: TFrmRatioSpread;

implementation

uses
  GAppEnv, GleLib, CleQuoteTimers, GleTypes, GleConsts;
{$R *.dfm}

procedure TFrmRatioSpread.btnDownApplyClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TButton).Tag;
  cbStartClick(cbStart);

  if iTag = 0 then       //UpBase
    FTrade.ApplyGrade(true, false)
  else
    FTrade.ApplyGrade(false, false);
end;

procedure TFrmRatioSpread.btnDownInitClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TButton).Tag;

  if iTag = 0 then
    FTrade.ApplyGrade(true, true)
  else
    FTrade.ApplyGrade(false, true);
end;

procedure TFrmRatioSpread.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmRatioSpread.btnSymbolClick(Sender: TObject);
begin
  cbStartClick(nil);
  FTrade.SetSymbol;
end;

procedure TFrmRatioSpread.cbStartClick(Sender: TObject);
var
  aParam : TRatioSpreadParams;
begin
  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);
  aParam.FutTerm := StrToFloatDef(edtGap.Text, 0.5);
  aParam.SignalGrade := StrToIntDef(edtGrade.Text , 8);
  aParam.UpBid := StrToFloatDef(edtUpBid2.Text, 0.65);
  aParam.DownBid := StrToFloatDef(edtDownBid2.Text, 0.65);
  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.1);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 1.5);
  aParam.Hedge :=  cbHdege.Checked;
  if rgEntry.ItemIndex = 0 then
    aParam.EntryType := etHedge
  else
    aParam.EntryType := etUser;
  aParam.UpBase := StrToFloatDef(edtUpBase.Text, gEnv.Engine.SymbolCore.Futures[0].Last + 1);
  aParam.DownBase := StrToFloatDef(edtDownBase.Text, gEnv.Engine.SymbolCore.Futures[0].Last - 1);
  aParam.Ratio := StrToIntDef(edtRatio.Text , 20);
  aParam.TowSymbol := cbTwoSymbol.Checked;
  FTrade.StartStop(aParam);
 
end;

procedure TFrmRatioSpread.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
  cbStart.Checked := false;
  cbStartClick(cbStart);
  FTrade.SetAccount(aAccount);
end;

procedure TFrmRatioSpread.DisplayInfo(aQuote: TQuote);
var
  i, j : integer;
  aItem : TFutGradeItem;
begin
  edtFut.Text := Format('%.2f',[aQuote.Last]);

  if FTrade.Ratios.FFutGrades[0].Count > 0 then
    sgInfo.ColCount := FTrade.Ratios.FFutGrades[0].Count
  else if FTrade.Ratios.FFutGrades[1].Count > 0 then
    sgInfo.ColCount := FTrade.Ratios.FFutGrades[1].Count;

  for i := 0 to 1 do
  begin
    for j := 0 to FTrade.Ratios.FFutGrades[i].Count - 1 do
    begin
      aItem := FTrade.Ratios.FFutGrades[i].Items[j] as TFutGradeItem;
      sgInfo.Cells[j, i] := Format('%.2f',[aItem.Price]);
      sgInfo.Objects[j, i] := aItem;
      sgInfo.ColWidths[j] := 40;
    end;
  end;
end;

procedure TFrmRatioSpread.DisplayOpt(aQuote: TQuote);
var
  i, iCol, iRow : integer;
  aItem : TRatioSpreadItem;
  stTmp : string;
begin
  StatusBar1.Panels[0].Text := Format('청산시간 : %s', [FormatDateTime('hh:nn:ss', FTrade.EndTime)]);
  edtPL.Text := Format('%.0n', [FTrade.TotPL]);

  if FTrade.Ratios.GetUpHedge(true) then
    edtUpBid2.Color := LONG_COLOR;

  if FTrade.Ratios.GetUpHedge(false) then
    edtDownBid2.Color := SHORT_COLOR;

  iRow := 1;
  for i := 0 to FTrade.Ratios.Count - 1 do
  begin
    aItem := FTrade.Ratios.Items[i] as TRatioSpreadItem;
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aItem.Symbol.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.Symbol.Last]); inc(iCol);
    if aItem.Position <> nil then
    begin
      sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.Position.Volume]); inc(iCol);
      sgOpt.Cells[iCol, iRow] := Format('%.0n', [aItem.Position.EntryOTE]); inc(iCol);
    end;
    stTmp := '';
    if aItem.Tradeing then
      stTmp := 'Trading';
    sgOpt.Cells[iCol, iRow] := stTmp;
    inc(iRow);
  end;
end;

procedure TFrmRatioSpread.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmRatioSpread.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  FTrade := TRatioSpreadTrade.Create(aColl, opRatio);
  FTrade.OnResult := OnDisplay;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

  edtUpBase.Text := Format('%.2f',[gEnv.Engine.SymbolCore.Futures[0].Last + 1]);
  edtDownBase.Text := Format('%.2f',[gEnv.Engine.SymbolCore.Futures[0].Last - 1]);
end;

procedure TFrmRatioSpread.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeCore.StrategyGate.Del(FTrade);
  FTrade := nil;
end;

procedure TFrmRatioSpread.InitGrid;
var
  i : integer;
begin
  for i := 0 to COL_CNT - 1 do
  begin
    sgOpt.Cells[i, 0] := GridTitle[i];
    sgOpt.ColWidths[i] := GridWidth[i];
  end;
end;

procedure TFrmRatioSpread.OnDisplay(Sender: TObject; Value: boolean);
var
  aQuote : TQuote;
begin
  if Sender = nil then exit;
  aQuote := Sender as TQuote;

  DisplayInfo(aQuote);
  DisplayOpt(aQuote);
end;

procedure TFrmRatioSpread.rgEntryClick(Sender: TObject);
begin
  if rgEntry.ItemIndex = 0 then
  begin
    edtUpBase.Enabled := false;
    edtDownBase.Enabled := false;
    udUp.Enabled := false;
    udDown.Enabled := false;
    btnUpApply.Enabled := false;
    btnDownApply.Enabled := false;
    btnUpInit.Enabled := false;
    btnDownInit.Enabled := false;

    cbStartClick(cbStart);
    FTrade.ApplyGrade(true, true);
    FTrade.ApplyGrade(false, true);
  end else
  begin
    edtUpBase.Enabled := true;
    edtDownBase.Enabled := true;
    btnUpApply.Enabled := true;
    btnDownApply.Enabled := true;
    btnUpInit.Enabled := true;
    btnDownInit.Enabled := true;
    udUp.Enabled := true;
    udDown.Enabled := true;
  end;
end;

procedure TFrmRatioSpread.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  aGrade : TFutGradeItem;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  with sgInfo do
  begin
    stTxt := Cells[ ACol, ARow];
    aGrade := Objects[ACol, ARow] as TFutGradeItem;
    if aGrade <> nil then
    begin
      if aGrade.Current then
        aBack := HIGHLIGHT_COLOR
      else if aGrade.EntryOrder then
      begin
        if ARow = 0 then
          aBack := LONG_COLOR
        else
          aBack := SHORT_COLOR;
      end;
    end;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;
end;

procedure TFrmRatioSpread.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  with sgOpt do
  begin
    stTxt := Cells[ ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;
end;


procedure TFrmRatioSpread.udUpClick(Sender: TObject; Button: TUDBtnType);
var
  iTag : integer;
begin
  iTag := (Sender as TUpDown).Tag;

  if iTag = 0 then
  begin
    case Button of
      btNext: edtUpBase.Text := Format('%.2f', [StrToFloat(edtUpBase.Text) + 0.05]);
      btPrev: edtUpBase.Text := Format('%.2f', [StrToFloat(edtUpBase.Text) - 0.05]);
    end;
  end else
  begin
    case Button of
      btNext: edtDownBase.Text := Format('%.2f', [StrToFloat(edtDownBase.Text) + 0.05]);
      btPrev: edtDownBase.Text := Format('%.2f', [StrToFloat(edtDownBase.Text) - 0.05]);
    end;
  end;
end;

end.
