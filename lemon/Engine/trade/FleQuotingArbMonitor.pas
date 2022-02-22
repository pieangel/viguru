unit FleQuotingArbMonitor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids,
  CleSymbols, CleQuotingArb, CleAccounts, CleMarkets;

const
  SetColCnt = 7;
  DetailColCnt = 9;
  SetTitle : array [0..SetColCnt-1] of string =
    ('구분','LS','시각','그룹','수량','확정손익','처리구분');
  SetWidth : array [0..SetColCnt-1] of integer = (45 , 30 , 80, 50, 65, 90, 65);
  DetailTitle : array [0..DetailColCnt-1] of string =
    ('',' ', '체결시각','종목코드','LS','체결수량','체결가', '체결번호', '주문번호');
  DetailWidth : array [0..DetailColCnt-1] of integer = (0, 28, 80,60, 30, 65, 50, 65, 60 );

  DataCol = 2;
  FillCol = 3;
  ExpandCol = 1;
type
  TFrmQuotingArb = class(TForm)
    Panel4: TPanel;
    plFill: TPanel;
    Panel1: TPanel;
    lbAcntName: TLabel;
    lblTotGroup: TLabel;
    lblWinRate: TLabel;
    lblFixedPL: TLabel;
    lbFCLR: TLabel;
    lbBox: TLabel;
    lbFCP: TLabel;
    lbFCLRcnt: TLabel;
    lbBOXcnt: TLabel;
    lbFPCcnt: TLabel;
    cbAccount: TComboBox;
    sgOption: TStringGrid;
    sgFut: TStringGrid;
    btnFill: TButton;
    Panel3: TPanel;
    sgData: TStringGrid;
    Panel2: TPanel;
    sgBasket: TStringGrid;
    Splitter1: TSplitter;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgBasketDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgDataDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure cbAccountChange(Sender: TObject);
    procedure sgBasketSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgDataDblClick(Sender: TObject);
    procedure sgFutDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgOptionDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnFillClick(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FBasketRow : integer;
    FDataRow : integer;
    FSelectGroup : TQuotingArbGroup;
    FSuccessCnt : integer;
    FTotFixedPL : double;
    FBasketCnt : array[0..2] of integer;             //FCLR , FCP, BOX
    FBasketPL : array[0..2] of double;               //FCLR , FCP, BOX
    FNoSound : Boolean;
    procedure InitControl;
    procedure AddBasket(aItem : TQuotingArbGroup);
    procedure DrawData(iRow : integer);
    procedure DrawFill;
    procedure ClearData;
    procedure ClearBasket;
    procedure ClearPosition;
    procedure DeleteRow(iRow : integer );
    procedure GetBasket;
    procedure SetDetail(iRow : integer);
    procedure DispalyTotal;
    procedure DrawStrike;
    procedure DrawPosition(aItem: TQuotingArbGroup);
  public
    { Public declarations }
    procedure OnArbEnd( aData : TObject );
  end;

var
  FrmQuotingArb: TFrmQuotingArb;

implementation

uses
  GAppEnv, Glelib, GleTypes, CleQuoteTimers, CleFQN, GleConsts;
{$R *.dfm}

procedure TFrmQuotingArb.AddBasket(aItem: TQuotingArbGroup);
var
  iCol : integer;
  bSelect : boolean;
begin
  InsertLine( sgBasket , 1 );
  iCol := 0;
  sgBasket.Cells[iCol, 1] := ArbTypeName[aItem.ArbType];                          inc(iCol);   //구분
  sgBasket.Cells[iCol, 1] := aItem.LS;                                            inc(iCol);   //LS
  sgBasket.Cells[iCol, 1] := FormatDateTime('hh:nn:ss.zzz', aItem.StartFillTime); inc(iCol);   //시각
  sgBasket.Cells[iCol, 1] := Format('%d',[aItem.BasketID]);                       inc(iCol);   //그룹
  sgBasket.Cells[iCol, 1] := Format('%d',[aItem.Qty]);                            inc(iCol);   //수량
  sgBasket.Cells[iCol, 1] := Format('%m',[aItem.PixedPL]);                        inc(iCol);   //확정손익
  sgBasket.Cells[iCol, 1] := aItem.GetResult;                                                  //처리구분

  sgBasket.Objects[DataCol, 1] := aItem;

  FTotFixedPL := FTotFixedPL + aItem.PixedPL;

  case aItem.ArbType of
    atFCLR:
    begin
      inc(FBasketCnt[0]) ;
      FBasketPL[0] := FBasketPL[0] + aItem.PixedPL;
    end;

    atFCP:
    begin
      inc(FBasketCnt[1]);
      FBasketPL[1] := FBasketPL[1] + aItem.PixedPL;
    end;
    atBox:
    begin
      inc(FBasketCnt[2]);
      FBasketPL[2] := FBasketPL[2] + aItem.PixedPL;
    end;
  end;


  if aItem.Success then
    inc(FSuccessCnt);
  DispalyTotal;

  bSelect := true;
  if FBasketRow = 1 then
  begin
    sgBasket.TopRow := 1;
    inc(FBasketRow);
    sgBasketSelectCell(sgBasket, 0,1, bSelect);
  end
  else if FBasketRow > 1 then
  begin
    sgBasketSelectCell(sgBasket, 0, FBasketRow+ 1, bSelect);
  end;

  //포지션
  DrawPosition(aItem);

  if (not FNoSound ) then
     FillSoundPlay( 'fill.wav');

end;

procedure TFrmQuotingArb.btnFillClick(Sender: TObject);
begin
  if btnFill.Caption = '<<' then
  begin
    btnFill.Caption := '>>';
    plFill.Visible := true;
    Width := Width + plFill.Width;
  end else
  begin
    btnFill.Caption := '<<';
    plFill.Visible := false;
    Width := Width - plFill.Width;
  end;
end;

procedure TFrmQuotingArb.cbAccountChange(Sender: TObject);
var
  i : integer;
  aAcnt : TAccount;
begin
  aAcnt := TAccount( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
  if aAcnt = nil then Exit;
  if FAccount <> aAcnt then
  begin
    FSuccessCnt := 0;
    FTotFixedPL := 0;
    for i := 0 to 2 do
      FBasketCnt[i] := 0;
    FAccount := aAcnt;
    lbAcntName.Caption := FAccount.Name;
    ClearBasket;
    ClearData;
    ClearPosition;
    GetBasket;
    DispalyTotal;
  end;
end;

procedure TFrmQuotingArb.ClearBasket;
var
  i: Integer;
begin
  for I := 1 to sgBasket.RowCount - 1 do
    sgBasket.Rows[i].Clear;
  sgBasket.RowCount := 2;

  for i := 0 to 2 do
  begin
    FBasketCnt[i] := 0;
    FBasketPL[i] := 0;
  end;
end;

procedure TFrmQuotingArb.ClearData;
var
  i: Integer;
begin
  for I := 1 to sgData.RowCount - 1 do
  begin
    sgData.Rows[i].Clear;
  end;
end;

procedure TFrmQuotingArb.ClearPosition;
var
  i : integer;
begin
  sgFut.Cells[1, 0] := '';

  for i := 1 to sgOption.RowCount - 1 do
  begin
    sgOption.Cells[0, i] := '';
    sgOption.Cells[2, i] := '';
  end;

end;

procedure TFrmQuotingArb.DeleteRow( iRow: integer);
var
  i: Integer;
  aData: TQuotingArbData;
begin
  aData := sgData.Objects[DataCol, iRow] as TQuotingArbData;
  if aData = nil then exit;

  for i := 0 to aData.FillDatas.Count - 1 do
    DeleteLine(sgData, iRow);
end;

procedure TFrmQuotingArb.DispalyTotal;
var
  iWinRate, iWin : integer;
begin
  lblFixedPL.Caption := Format( '확정손익: %12m 원', [FTotFixedPL] );
  lblTotGroup.Caption := Format( '총그룹수: %d', [sgBasket.RowCount-2] );
  iWinRate := 0;
  iWin := FSuccessCnt;
  if iWin <> 0 then
    iWinRate := Round(iWin/(sgBasket.RowCount-1)*100);
  lblWinRate.Caption := Format( '승률: %d%% ( %d/%d )', [ iWinRate, iWin, sgBasket.RowCount-2 ] );

  lbFCLR.Caption := Format('CLR: %12m 원',[FBasketPL[0]]);
  lbFCLRcnt.Caption := Format('%d' ,[FBasketCnt[0]]);

  lbBOX.Caption := Format('BOX: %12m 원',[FBasketPL[2]]);
  lbBOXcnt.Caption := Format('%d' ,[FBasketCnt[2]]);

  lbFCP.Caption := Format('FCP: %12m 원',[FBasketPL[1]]);
  lbFPCcnt.Caption := Format('%d' ,[FBasketCnt[1]]);
end;

procedure TFrmQuotingArb.DrawPosition(aItem: TQuotingArbGroup);
var
  i, iRow, iSide, iQty : integer;
  aData : TQuotingArbData;
  aOption : TOption;
begin
  for i := 0 to  aItem.DataCnt - 1 do
  begin
    aData := aItem.FQuotingArbDatas[i];
    if aData.LS = 'L' then
      iSide :=  1
    else
      iSide := -1;

    case aData.Symbol.Spec.Market of
      mtFutures:
      begin
        iQty := StrToIntDef(sgFut.Cells[1,0],0);
        sgFut.Cells[1,0] := Format('%d', [iQty + (aData.FillQty * iSide)]);
      end;
      mtOption:
      begin
        for iRow := 1 to sgOption.RowCount - 1 do
        begin
          if aData.Symbol = sgOption.Objects[0, iRow] then
          begin
            iQty := StrToIntDef(sgOption.Cells[0,iRow],0);
            sgOption.Cells[0,iRow] := Format('%d', [iQty + (aData.FillQty * iSide)]);
            break;
          end;

          if aData.Symbol = sgOption.Objects[2, iRow] then
          begin
            iQty := StrToIntDef(sgOption.Cells[2,iRow],0);
            sgOption.Cells[2,iRow] := Format('%d', [iQty + (aData.FillQty * iSide)]);
            break;
          end;
        end; //for
      end;
    end; //case
  end; //for
end;

procedure TFrmQuotingArb.DrawData(iRow : integer);
var
  i, iCol : integer;
  aData : TQuotingArbData;
  aItem : TQuotingArbGroup;
begin
  aItem := sgBasket.Objects[DataCol, iRow] as TQuotingArbGroup;
  if aItem = nil then exit;
  FSelectGroup := aItem;

  ClearData;

  for i := 0 to  aItem.DataCnt - 1 do
  begin
    aData := aItem.FQuotingArbDatas[i];
    iCol := 1;
    iRow := i + 1;
    sgData.Cells[iCol, iRow] := ' ';                                                  inc(iCol);  //확장
    sgData.Cells[iCol, iRow] := FormatDateTime('hh:nn:ss.zzz', aData.LastFillTime);   inc(iCol);  //체결시각
    sgData.Cells[iCol, iRow] := aData.Symbol.ShortCode;                               inc(iCol);  //종목코드
    sgData.Cells[iCol, iRow] := aData.LS;                                             inc(iCol);  //LS
    sgData.Cells[iCol, iRow] := Format('%d',[aData.FillQty]);                         inc(iCol);  //체결수량
    sgData.Cells[iCol, iRow] := Format('%.2f',[aData.AvgPrice]);                      inc(iCol);  //체결가
    aData.Detail := false;
    sgData.Objects[DataCol, iRow] := aData;
  end;
end;

procedure TFrmQuotingArb.DrawFill;
var
  i, j, iCol, iFill, iRow : integer;
  aFill : TQuotingArbFill;
  aData: TQuotingArbData;
begin
  ClearData;
  if FSelectGroup = nil then exit;
  iRow := 0;
  for i := 0 to FSelectGroup.DataCnt - 1 do
  begin
    aData := FSelectGroup.FQuotingArbDatas[i];
    inc(iRow);
    iCol := 1;
    sgData.Cells[iCol, iRow] := ' ';                                                inc(iCol);  //확장
    sgData.Cells[iCol, iRow] := FormatDateTime('hh:nn:ss.zzz', aData.LastFillTime); inc(iCol);  //체결시각
    sgData.Cells[iCol, iRow] := aData.Symbol.ShortCode;                             inc(iCol);  //종목코드
    sgData.Cells[iCol, iRow] := aData.LS;                                           inc(iCol);  //LS
    sgData.Cells[iCol, iRow] := Format('%d',[aData.FillQty]);                       inc(iCol);  //체결수량
    sgData.Cells[iCol, iRow] := Format('%.2f',[aData.AvgPrice]);                    inc(iCol);  //체결가
    sgData.Objects[DataCol, iRow] := aData;
    if aData.Detail then
    begin
      for j := 0 to aData.FillDatas.Count - 1 do
      begin
        aFill := aData.FillDatas.Items[j] as TQuotingArbFill;
        iCol := 1;
        inc(iRow);
        sgData.Cells[iCol, iRow] := '';                                                inc(iCol);  //확장
        sgData.Cells[iCol, iRow] := FormatDateTime('hh:nn:ss.zzz', aFill.FillTime);    inc(iCol);  //체결시각
        sgData.Cells[iCol, iRow] := '';                                                inc(iCol);  //종목코드
        sgData.Cells[iCol, iRow] := aFill.LS;                                          inc(iCol);  //LS
        sgData.Cells[iCol, iRow] := Format('%d',[aFill.FillQty]);                      inc(iCol);  //체결수량
        sgData.Cells[iCol, iRow] := Format('%.2f',[aFill.FillPrice]);                  inc(iCol);  //체결가
        sgData.Cells[iCol, iRow] := Format('%d',[aFill.FillNo]);                       inc(iCol);  //체결번호
        sgData.Cells[iCol, iRow] := Format('%d',[aFill.OrderNo]);                      inc(iCol);  //주문번호
        sgData.Objects[FillCol, iRow] := aFill;
      end;
    end;
  end;
end;

procedure TFrmQuotingArb.DrawStrike;
var
  i : integer;
  aStrike: TStrike;
  aOptionMarket : TOptionMarket;
begin
  aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];

  sgOption.RowCount := aOptionMarket.Trees.FrontMonth.Strikes.Count + 1;
  for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    sgOption.Cells[1, i+1]   := Format('%.2f', [aStrike.StrikePrice]);
    sgOption.Objects[0, i+1] := aStrike.Call as TSymbol;
    sgOption.Objects[2, i+1] := aStrike.Put as TSymbol;
  end;
end;

procedure TFrmQuotingArb.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmQuotingArb.FormCreate(Sender: TObject);
begin
  InitControl;
  FBasketRow := -1;
  FDataRow := -1;
  FSelectGroup := nil;

  gEnv.Engine.TradeCore.Accounts.GetList3( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex  := 0;
    cbAccountChange( nil );
  end;
  gEnv.Engine.TradeCore.QuotingArbGroups.OnArbEnd := OnArbEnd;
end;

procedure TFrmQuotingArb.FormDestroy(Sender: TObject);
begin
//
end;

procedure TFrmQuotingArb.GetBasket;
var
  i : integer;
  aItem : TQuotingArbGroup;
begin
  FNoSound := true;
  for i := 0 to gEnv.Engine.TradeCore.QuotingArbGroups.Count -1 do
  begin
    aItem := gEnv.Engine.TradeCore.QuotingArbGroups.Items[i] as TQuotingArbGroup;

    if (FAccount = aItem.Account) and (aItem.BasketEnd) then
      AddBasket(aItem);
  end;
  FNoSound := false;
end;

procedure TFrmQuotingArb.InitControl;
var
  i : integer;
begin
  sgBasket.ColCount := SetColCnt;
  for i := 0 to SetColCnt - 1 do
  begin
    sgBasket.Cells[i,0] := SetTitle[i];
    sgBasket.ColWidths[i] := SetWidth[i];
  end;

  sgData.ColCount := DetailColCnt;
  for i := 0 to DetailColCnt - 1 do
  begin
    sgData.Cells[i,0] := DetailTitle[i];
    sgData.ColWidths[i] := DetailWidth[i];
  end;

  sgOption.Cells[0,0] := 'Call';                     
  sgOption.Cells[1,0] := '행사가';
  sgOption.Cells[2,0] := 'Put';

  sgFut.Cells[0,0] := '선물';
  sgFut.ColWidths[0] := 45;
  sgFut.ColWidths[1] := sgFut.ColWidths[0]*2;
  for i := 0 to 2 do
    sgOption.ColWidths[i] := 45;
  DrawStrike;
end;

procedure TFrmQuotingArb.OnArbEnd(aData: TObject);
var
  aItem : TQuotingArbGroup;
begin
  FNoSound := false;
  if aData = nil then exit;
  aItem := aData as TQuotingArbGroup;
  if FAccount = aItem.Account then
    AddBasket(aItem);
end;

procedure TFrmQuotingArb.SetDetail(iRow: integer);
var
  aData : TQuotingArbData;
begin
  aData := sgData.Objects[DataCol, iRow] as TQuotingArbData;
  if aData = nil then exit;
  if aData.Detail then
    aData.Detail := false
  else
    aData.Detail := true;
end;

procedure TFrmQuotingArb.sgBasketDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  clFont , clBack : TColor;
  stTxt : string;
  dFormat : Word;
  aRect : TRect;
begin
  //
  clBack := clWhite;
  clFont := clBlack;
  dFormat := DT_VCENTER or DT_RIGHT;
  with TStringGrid( Sender ) do
  begin
    aRect := Rect;
    aRect.Top   := aRect.Top + 1;

    stTxt := Cells[ACol, ARow];

    if ARow = 0 then
    begin
      clBack := clBtnFace;
      dFormat := DT_VCENTER or DT_CENTER;
    end
    else begin
      if ARow = FBasketRow then
          clBack := $00F2BEB9;
      aRect.Right := aRect.Right -1;
    end;

    if ACol in [0, 1, 2, 6] then
      dFormat := DT_VCENTER or DT_CENTER;

    Canvas.Font.Color   := clFont;
    Canvas.Brush.Color  := clBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );
  end;
end;

procedure TFrmQuotingArb.sgBasketSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  tmp : integer;
begin
  tmp := FBasketRow;
  if FBasketRow = ARow then exit;
  FBasketRow := ARow;
  InvalidateRow( sgBasket, tmp );
  InvalidateRow( sgBasket, FBasketRow );
  DrawData(ARow);
end;

procedure TFrmQuotingArb.sgDataDblClick(Sender: TObject);
var
  aData : TQuotingArbData;
begin
  aData := sgData.Objects[DataCol, FDataRow] as TQuotingArbData;
  if aData = nil then exit;
  if aData.Detail then
    aData.Detail := false
  else
    aData.Detail := true;
  DrawFill;
  sgData.Invalidate;
end;

procedure TFrmQuotingArb.sgDataDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  clFont , clBack : TColor;
  stTxt : string;
  dFormat : Word;
  aRect, aBox : TRect;
  iTmp : integer;
  aData : TQuotingArbData;
  aFill : TQuotingArbFill;
begin
  //
  clBack := clWhite;
  clFont := clBlack;
  dFormat := DT_VCENTER or DT_RIGHT;
  with TStringGrid( Sender ) do
  begin

    aRect := Rect;
    aRect.Top   := aRect.Top + 1;

    stTxt := Cells[ACol, ARow];

    if ARow = 0 then
    begin
      clBack := clBtnFace;
      dFormat := DT_VCENTER or DT_CENTER;
    end
    else begin
      if ARow = FDataRow then
        clBack := $00F2BEB9;
      aRect.Right := aRect.Right -1;
    end;
    Canvas.Font.Color   := clFont;
    Canvas.Brush.Color  := clBack;
    Canvas.FillRect( Rect);
    
    if (ExpandCol = ACol) and (ARow >= 1) then
    begin
      aData := Objects[DataCol, ARow] as TQuotingArbData;
      if (aData <> nil) and (aData.FillDatas.Count > 0) then
      begin

        Canvas.Pen.Mode := pmCopy;
        Canvas.Pen.Color := clBlack;
        Canvas.Pen.Width := 1 ;

        aBox := Classes.Rect(aRect.Left+7, aRect.Top+2, aRect.Right-7, aRect.Bottom-2);
        Canvas.Rectangle(aBox);

        iTmp := Round((aBox.Top + aBox.Bottom) Div 2);
        Canvas.MoveTo(aBox.Left + 2, iTmp);
        Canvas.LineTo(aBox.Right - 2, iTmp);

        if not aData.Detail then
        begin
          iTmp := Round((aBox.Right + aBox.Left) Div 2);
          Canvas.MoveTo(iTmp, aBox.Top + 2);
          Canvas.LineTo(iTmp, aBox.Bottom  - 2);
        end;
      end;
    end;
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );
  end;
end;

procedure TFrmQuotingArb.sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  tmp : integer;
begin
  tmp := FDataRow;
  if (FDataRow <> ARow) then
  begin
    FDataRow := ARow;
    InvalidateRow( sgData, tmp );
    InvalidateRow( sgData, FDataRow );
  end;

  if ACol = ExpandCol then
    SetDetail(ARow);

  if (FDataRow <> ARow) or (ACol = ExpandCol) then
  begin
    DrawFill;
    sgData.Invalidate;
  end;

end;

procedure TFrmQuotingArb.sgFutDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  clFont , clBack : TColor;
  stTxt : string;
  dFormat : Word;
  aRect : TRect;
begin
  clBack := clWhite;
  clFont := clBlack;
  dFormat := DT_VCENTER or DT_RIGHT;
  with TStringGrid( Sender ) do
  begin
    aRect := Rect;
    aRect.Top   := aRect.Top + 1;

    stTxt := Cells[ACol, ARow];

    if ACol = 0 then
      clBack := clBtnFace;

    if ACol = 1 then
      clBack := clCream;

    dFormat := DT_VCENTER or DT_CENTER;
    Canvas.Font.Color   := clFont;
    Canvas.Brush.Color  := clBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );
  end;
end;

procedure TFrmQuotingArb.sgOptionDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  clFont , clBack : TColor;
  stTxt : string;
  dFormat : Word;
  aRect : TRect;
begin
  clBack := clWhite;
  clFont := clBlack;
  dFormat := DT_VCENTER or DT_RIGHT;
  with TStringGrid( Sender ) do
  begin
    aRect := Rect;
    aRect.Top   := aRect.Top + 1;

    if ARow = 0 then
      clBack := clBtnFace
    else
    begin
      if ACol = 1 then
        clBack := clBtnFace
      else
        clBack := clCream;
    end;
    
    stTxt := Cells[ACol, ARow];
    dFormat := DT_VCENTER or DT_CENTER;
    Canvas.Font.Color   := clFont;
    Canvas.Brush.Color  := clBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );
  end;

end;

end.
