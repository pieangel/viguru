unit FleParity;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  CleSymbols, CleAccounts,  CleStorage , CleDistributor, CleQuoteBroker ,
  CleOrders , ClePositions, CleFills, CleMarkets, StdCtrls, ExtCtrls, CleQuoteTimers,
  Grids, CleParityTrade, CleStrategyStore, ComCtrls;


const
  COL_CNT = 5;
  GridTitleOpt : array[0..4] of string =
                            ('Code', '현재가', '포지션', '평균단가', '평가손익');
type
  TPriceStatus = (psHigh, psLow, psHCross, psLCross, psNone);

  TFrmParity = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ComboAccount: TComboBox;
    cbStart: TCheckBox;
    edtGap: TEdit;
    Label3: TLabel;
    edtQty: TEdit;
    Label4: TLabel;
    edtStatus: TEdit;
    edtAvg: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    edtPrice: TEdit;
    btnClear: TButton;
    btnSymbol: TButton;
    Label8: TLabel;
    edtLow: TEdit;
    Label7: TLabel;
    edtHigh: TEdit;
    Label11: TLabel;
    edtPL: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    edtBase: TEdit;
    sgOpt: TStringGrid;
    rgType: TRadioGroup;
    StatusBar1: TStatusBar;
    Label9: TLabel;
    edtMultiple: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure rgTypeClick(Sender: TObject);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    FAvg : double;
    FFut : TSymbol;
    FQuote : TQuote;
    FAccount : TAccount;
    FStatus : TPriceStatus;
    FOrderList : TList;
    FEndTime : TDateTime;
    FTrade : TParityTrade;
  public
    { Public declarations }
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmParity: TFrmParity;

implementation

uses
  GAppEnv, GleLib, GleTypes;
{$R *.dfm}


procedure TFrmParity.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmParity.cbStartClick(Sender: TObject);
var
  aParam : TParityParams;
  aType : TOrderType;
begin
  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);
  aParam.BaseGap := StrToIntDef(edtBase.Text , 10);
  aParam.Multiple := StrToIntDef(edtMultiple.Text , 7);
  if rgType.ItemIndex = 0 then
    aType := otTrend
  else
    aType := otBid;
  aParam.OrderType := aType;
  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.1);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 1.5);
  FTrade.StartStop(aParam);
end;

procedure TFrmParity.ComboAccountChange(Sender: TObject);
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

procedure TFrmParity.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmParity.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
  i : integer;
begin
  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  FTrade := TParityTrade.Create(aColl, opParity);
  FTrade.OnResult := OnDisplay;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );
  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

  for i := 0 to COL_CNT - 1 do
    sgOpt.Cells[i, 0] := GridTitleOpt[i];
end;

procedure TFrmParity.FormDestroy(Sender: TObject);
begin
  FTrade.Free;
end;

procedure TFrmParity.OnDisplay(Sender: TObject; Value: boolean);
var
  i, iCol, iRow : integer;
  aPos : TPosition;
  aQuote : TQuote;
begin
  aQuote := Sender as TQuote;
  StatusBar1.Panels[0].Text := Format('청산시간 : %s', [FormatDateTime('hh:nn:ss', FTrade.EndTime)]);
  edtPL.Text := Format('%.0n', [FTrade.TotPL]);
  edtStatus.Text := FTrade.GetStatus;
  edtGap.Text := IntToStr(FTrade.Gap);
  edtAvg.Text := Format('%.2f',[FTrade.Avg]);
  edtPrice.Text := Format('%.2f',[aQuote.Last]);

  iRow := 1;
  for i := 0 to FTrade.Positions.Count - 1 do
  begin
    aPos := FTrade.Positions.Items[i] as TPosition;
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aPos.Symbol.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aPos.Symbol.Last]); inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%d', [aPos.Volume]); inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aPos.AvgPrice]); inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.0n', [aPos.EntryOTE]); inc(iCol);
    inc(iRow);
  end;
end;

procedure TFrmParity.rgTypeClick(Sender: TObject);
begin
  cbStartClick(cbStart);
end;

procedure TFrmParity.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
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

end.
