unit FleStrangleSequel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, StdCtrls, ExtCtrls,
  CleQuoteBroker, CleSymbols, CleQuoteTimers,
  CleStrategyStore, CleStrangleSequel, CleAccounts, GleLib;

const
  FutTitle : array[0..3] of string =
                            ('Code', '현재가', '매도건수', '매수건수');
  OptTitle : array[0..4] of string =
                            ('Code', '현재가', '포지션', '평가손익', 'Trading');
  StatusTitle : array[0..5] of string =
                            ('09:01', '09:30', '10:10', '10:30', '11:30', '12:30');

type
  TFrmStrangleSequel = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    btnSymbol: TButton;
    edtQty: TEdit;
    edtStatus: TEdit;
    edtUpBid1: TEdit;
    edtUpBid2: TEdit;
    edtUpBid3: TEdit;
    edtUpAsk1: TEdit;
    edtUpAsk2: TEdit;
    edtUpAsk3: TEdit;
    edtDownBid1: TEdit;
    edtDownAsk1: TEdit;
    edtDownBid2: TEdit;
    edtDownAsk2: TEdit;
    edtDownBid3: TEdit;
    edtDownAsk3: TEdit;
    edtLow: TEdit;
    edtHigh: TEdit;
    edtPL: TEdit;
    btnClear: TButton;
    Panel2: TPanel;
    sgStatus: TStringGrid;
    sgFut: TStringGrid;
    sgOpt: TStringGrid;
    StatusBar1: TStatusBar;
    rgHedge: TRadioGroup;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure sgFutDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure rgHedgeClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    FTrade : TStrangleSequelTrade;
    FAccount : TAccount;
    procedure InitGrid;
    procedure ClearGrid;
  public
    { Public declarations }
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmStrangleSequel: TFrmStrangleSequel;

implementation
uses
  GAppEnv, GleConsts, GleTypes;

{$R *.dfm}

procedure TFrmStrangleSequel.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmStrangleSequel.cbStartClick(Sender: TObject);
var
  aParam : TStrangleSequelParams;
begin
  // 스타트 스탑 주문수량 Enable

  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);

  aParam.UpBid[0] := StrToFloatDef(edtUpBid1.Text, 0.7);
  aParam.UpBid[1] := StrToFloatDef(edtUpBid2.Text, 0.65);
  aParam.UpBid[2] := StrToFloatDef(edtUpBid3.Text, 0.6);

  aParam.UpAsk[0] := StrToFloatDef(edtUpAsk1.Text, 0.9);
  aParam.UpAsk[1] := StrToFloatDef(edtUpAsk2.Text, 1);
  aParam.UpAsk[2] := StrToFloatDef(edtUpAsk3.Text, 1.1);

  aParam.DownBid[0] := StrToFloatDef(edtDownBid1.Text, 0.7);
  aParam.DownBid[1] := StrToFloatDef(edtDownBid2.Text, 0.65);
  aParam.DownBid[2] := StrToFloatDef(edtDownBid3.Text, 0.6);

  aParam.DownAsk[0] := StrToFloatDef(edtDownAsk1.Text, 0.9);
  aParam.DownAsk[1] := StrToFloatDef(edtDownAsk2.Text, 1);
  aParam.DownAsk[2] := StrToFloatDef(edtDownAsk3.Text, 1.1);
  aParam.HedgeType := htNone;
  case rgHedge.ItemIndex of
    0 :  aParam.HedgeType := htNone;
    1 :  aParam.HedgeType := htAll;
    2 :  aParam.HedgeType := htHigh;
    3 :  aParam.HedgeType := htLow;
  end;
  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.5);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 2.0);
  FTrade.StartStop(aParam);
end;

procedure TFrmStrangleSequel.ClearGrid;
var
  i, j : integer;
begin
  for i := 1 to sgOpt.RowCount - 1 do
  begin
    for j := 0 to sgOpt.ColCount - 1 do
      sgOpt.Cells[j,i] := '';
  end;
end;

procedure TFrmStrangleSequel.ComboAccountChange(Sender: TObject);
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

  // 초기화......
  ClearGrid;
  FTrade.ReSet;
end;

procedure TFrmStrangleSequel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmStrangleSequel.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  FTrade := TStrangleSequelTrade.Create(aColl, opStrangle2);
  FTrade.OnResult := OnDisplay;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;
end;

procedure TFrmStrangleSequel.FormDestroy(Sender: TObject);
begin
  FTrade.Free;
end;

procedure TFrmStrangleSequel.InitGrid;
var
  i : integer;
begin
  for i := 0 to 3 do
    sgFut.Cells[i,0] := FutTitle[i];

  for i := 0 to 4 do
    sgOpt.Cells[i,0] := OptTitle[i];
  for i := 0 to 5 do
    sgStatus.Cells[i,0] := StatusTitle[i];
end;

procedure TFrmStrangleSequel.OnDisplay(Sender: TObject; Value: boolean);
var
  i, iCol, iRow : integer;
  aQuote : TQuote;
  stTmp : string;
  aItem : TStrangleSequel;
begin
  if Sender = nil then exit;

  aQuote := Sender as TQuote;

  sgFut.Cells[0,1] := aQuote.Symbol.ShortCode;
  sgFut.Cells[1,1] := Format('%.2f', [aQuote.Last]);
  sgFut.Cells[2,1] := Format('%d', [aQuote.Asks.CntTotal]);
  sgFut.Cells[3,1] := Format('%d', [aQuote.Bids.CntTotal]);

  edtStatus.Text := FTrade.StrangleSe.GetStatusDesc;
  edtPL.Text := Format('%.0n', [FTrade.TotPL]);

  iRow := 1;
  for i := 0 to FTrade.StrangleSe.Count - 1 do
  begin
    aItem := FTrade.StrangleSe.Items[i] as TStrangleSequel;
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aItem.Symbol.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.Symbol.Last]); inc(iCol);
    if aItem.Position <> nil then
    begin
      sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.Position.Volume]); inc(iCol);
      sgOpt.Cells[iCol, iRow] := Format('%.0n', [aItem.Position.EntryOTE]); inc(iCol);
    end else
    begin
      inc(iCol);
      inc(iCol);
    end;

    stTmp := '';
    if aItem.Trading then
      stTmp := 'Trading';

    sgOpt.Cells[iCol, iRow] := stTmp;
    inc(iRow);
  end;

  for i := 0 to 5 do
    sgStatus.Cells[i,1] := ' ';

  if sgStatus.Objects[0, 1] = nil then
  begin
    for i := 0 to 5 do
      sgStatus.Objects[i, 1]:= FTrade.StrangleSe.GetTimeOrder(i) as TObject;
  end;

  StatusBar1.Panels[0].Text := Format('청산시간 : %s', [FormatDateTime('hh:nn:ss', FTrade.EndTime)]);

end;

procedure TFrmStrangleSequel.rgHedgeClick(Sender: TObject);
begin
  cbStartClick(cbStart);
end;

procedure TFrmStrangleSequel.sgFutDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  sgGrid : TStringGrid;
  dData : double;
  aItem : TTimeOrder;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  sgGrid := Sender as TStringGrid;
  with sgGrid do
  begin
    stTxt := Cells[ ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace
    else
    begin
      if Tag = 1 then
      begin
        aItem := Objects[ACol, 1] as TTimeOrder;
        if aItem <> nil then
        begin
          if aItem.Send then aBack := SELECTED_COLOR2;
        end;
      end;
    end;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

end.
