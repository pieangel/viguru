unit FleYHTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids,
  CleAccounts, CleYHTrade, CleQuoteBroker, ComCtrls, CleStrategyStore;

const
  COL_CNT = 8;
  GridTitle : array[0..7] of string =
                            ('Code', '현재가', '잔고', '평가손익', '양합', 'Ratio', '횟수', '상태');

  GridWidth : array[0..7] of integer =
                            (60, 60, 50, 90, 40, 40, 35, 35);
type
  TFrmYHTrade = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    btnSymbol: TButton;
    edtQty: TEdit;
    edtEntryR: TEdit;
    edtEntryCnt: TEdit;
    Label2: TLabel;
    Label6: TLabel;
    edtClearR: TEdit;
    Label4: TLabel;
    edtTerm: TEdit;
    Label5: TLabel;
    Panel2: TPanel;
    sgOpt: TStringGrid;
    Timer1: TTimer;
    edtMaxPL: TEdit;
    StatusBar1: TStatusBar;
    edtLow: TEdit;
    edtHigh: TEdit;
    Label7: TLabel;
    cbOpen: TCheckBox;
    edtPL: TEdit;
    Label8: TLabel;
    Label11: TLabel;
    btnClear: TButton;
    Label9: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    FTrade : TYHTrade;
    FMaxLoss : Double;
    FAccount : TAccount;
    procedure InitGrid;
  public
    { Public declarations }
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmYHTrade: TFrmYHTrade;

implementation
uses
  GAppEnv, GleLib, CleQuoteTimers, GleTypes;

{$R *.dfm}

procedure TFrmYHTrade.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmYHTrade.btnSymbolClick(Sender: TObject);
begin
  cbStartClick(nil);
  FTrade.SetSymbol;
end;

procedure TFrmYHTrade.cbStartClick(Sender: TObject);
var
  aParam : TYHParams;
begin
  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);
  aParam.MaxEntryCnt := StrToIntDef(edtEntryCnt.Text, 2);
  aParam.EntryRatio := StrToIntDef(edtEntryR.Text , 50);
  aParam.ClearRatio := StrToIntDef(edtClearR.Text, 50);
  aParam.TermMin := StrToIntDef(edtTerm.Text, 115);
  aParam.OpenOrder := cbOpen.Checked;
  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.5);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 2.0);

  FTrade.StartStop(aParam);
end;

procedure TFrmYHTrade.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;
  FAccount := aAccount;
  FTrade.SetAccount(FAccount);
  cbStart.Checked := false;
  cbStartClick(cbStart);
end;

procedure TFrmYHTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmYHTrade.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  FMaxLoss := 0;
  InitGrid;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  FTrade := TYHTrade.Create(aColl, opYH);

  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );
  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;
  FTrade.OnResult := OnDisplay;
end;

procedure TFrmYHTrade.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeCore.StrategyGate.Del(FTrade);
  FTrade := nil;
end;

procedure TFrmYHTrade.InitGrid;
var
  i : integer;
begin
  for i := 0 to COL_CNT - 1 do
  begin
    sgOpt.Cells[i, 0] := GridTitle[i];
    sgOpt.ColWidths[i] := GridWidth[i];
  end;
end;

procedure TFrmYHTrade.OnDisplay(Sender: TObject; Value: boolean);
var
  i, iCol, iRow : integer;
  aQuote : TQuote;
  aItem : TYHData;
begin
  if Sender = nil then exit;

  aQuote := Sender as TQuote;
  iRow := 1;
  for i := 0 to FTrade.YHs.Count - 1 do
  begin
    aItem := FTrade.YHs.Items[i] as TYHData;
    // Call info
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aItem.Call.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.Call.Last]); inc(iCol);
    if aItem.CallPos <> nil then
    begin
      sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.CallPos.Volume]); inc(iCol);
      sgOpt.Cells[iCol, iRow] := Format('%.0n', [aItem.CallPos.EntryOTE]); inc(iCol);
    end;
    inc(iRow);

    // Put info
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aItem.Put.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.Put.Last]); inc(iCol);
    if aItem.PutPos <> nil then
    begin
      sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.PutPos.Volume]); inc(iCol);
      sgOpt.Cells[iCol, iRow] := Format('%.0n', [aItem.PutPos.EntryOTE]); inc(iCol);
    end else
    begin
      inc(iCol);
      inc(iCol);
    end;

    //YH Data
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.YH]); inc(iCol);             //양합
    sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.Ratio]); inc(iCol);            //Ratio
    sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.RealEntryCnt]); inc(iCol);     //회수
    sgOpt.Cells[iCol, iRow] := Format('%s', [aItem.GetStatus]);                   //상태
    inc(iRow);
  end;
  edtPL.Text := Format('%.0n', [FTrade.TotPL]);

  if (FMaxLoss > FTrade.TotPL) and (FTrade.TotPL < 0) then
  begin
    FMaxLoss := FTrade.TotPL;
    edtMaxPL.Text := Format('%.0n',[FMaxLoss]);
  end;
end;

procedure TFrmYHTrade.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
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

procedure TFrmYHTrade.Timer1Timer(Sender: TObject);
var
  startTime : TDateTime;
begin
  startTime := EncodeTime(8,59,58,0);
  if Frac(GetQuoteTime) > startTime then
  begin
    FTrade.SetSymbol;

    if FTrade.YHs.Count > 0 then
    begin
      Timer1.Enabled  := false;
      StatusBar1.Panels[0].Text := Format('청산시간 : %s', [FormatDateTime('hh:nn:ss', FTrade.EndTime)]);
    end;

    //btnSymbol.Enabled := false;
    //ComboAccount.Enabled := false;
  end;
end;

end.
