unit CleVolSTrade;

interface
uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes, Math,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleStrategyStore, CleOrderBeHaivors
  ;
const
  CHANGE_INDEX = 100;

type
  TVolSTrade = class;
  TLosscutType = (ltNone, ltHigh, ltLow, ltAll);

  TVolSParam = record
    Qty : integer;
    HighPrice : double;
    LowPrice : double;

    GradeStart : integer;
    GradeGap : integer;
    GradeCount : integer;

    ChangeUp : double;
    ChangeDown : double;

    Change : integer;

    LossCut : double;
    AutoLiquid : boolean;
    LiquidTime : TDateTime;
  end;

TGradePosition = class
  public
    Call : TSymbol;
    Put : TSymbol;
    PL : array[0..1] of double;
    SumFillPrice : array[0..1] of double;
    AvgPrice : array[0..1] of double;
    FilledQty : array[0..1] of integer;
    VirtualFilliedQty : array[0..1] of integer;
    Close : boolean;
    MaxPL : integer;
    procedure Init;
  end;

  TGradeItem = class(TCollectionItem)
  private
    FEntryOTE : integer;
    FSetCnt : integer;
    FEntry : boolean;
    FCurrentIndex : integer;
    FChange : boolean;
  public
    Position : array[0..1] of TGradePosition;
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;
    procedure CalPL;
    procedure OrderFill(aOrder : TOrder);
    function CheckLossCut(dLossCut : double; iOrdQty : integer; bClear : boolean = false) : TLosscutType;

    procedure SetSymbol(aCall, aPut : TSymbol; iIndex : integer);
    function CheckOTE(iOte : integer) : boolean;
    property EntryOTE : integer read FEntryOTE write FEntryOTE;
    property Entry : boolean read FEntry write FEntry;
    property SetCnt : integer read FSetCnt write FSetCnt;
    property CurrentIndex: integer read FCurrentIndex write FCurrentIndex;
    property Change : boolean read FChange write FChange;
  end;

  TGrades = class(TCollection)
  private
    FTrade : TVolSTrade;
    FGradeItem : TGradeItem;
    FAccount : TAccount;
    FChangeItem : TGradeItem;
    function GetPrice(aSymbol : TSymbol; iSide : integer) : double;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CalPL(aQuote : TQuote);
    procedure CheckLossCut(dLossCut : double; iOrdQty : integer; bClear : boolean);
    procedure SendOrder(aAcnt : TAccount; iQty : integer; aItem : TGradeItem);
    procedure LossCutOrder( aItem : TGradeItem; aType : TLosscutType);
    function DoOrder(aAcnt : TAccount; aSymbol : TSymbol ; iSide, iQty, iOte : integer) : TOrder;
    function New( iOte, iIndex : integer; bChange : boolean) : TGradeItem;
    function Find(iOte : integer) : TGradeItem;
    property Trade : TVolSTrade read FTrade write FTrade;
    property GradeItem : TGradeItem read FGradeItem write FGradeItem;
    property ChangeItem : TGradeItem read FChangeItem write FChangeItem;
  end;

  TVolSTrade = class(TStrategyBase)
  private
    FGrades : TGrades;
    FParam : TVolSParam;
    FGradePos : TGradePosition;
    FRun : boolean;
    FBaseSum : integer;
    FMinPL, FMaxPL : double;
    procedure SetBaseSymbol;
    procedure CheckOrder;
    procedure CheckHighChange;
    procedure SetGrade;
    procedure SearchSymbol(aItem : TGradeItem; bHighChange : boolean);
    procedure CalBasePL(aQuote : TQuote);
    procedure DoLog;
    function IsPrice(dPrice1, dPrice2 : double; bHighChange : boolean) : boolean;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    procedure Start(aAcnt : TAccount);
    procedure Stop(bCheck : boolean = false);
    procedure ReSet;
    procedure LossCutOrder;
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    property Param : TVolSParam read FParam write FParam;
    property BaseSum : integer read FBaseSum;
    property GradePos : TGradePosition read FGradePos;
  end;


implementation
uses
  GAppEnv, GleLib, Dialogs, GleConsts, CleKrxSymbols;

{ TGradeItem }

procedure TGradeItem.CalPL;
var
  i : integer;
begin
  for i := 0 to 1 do
  begin
    if (Position[i].Call <> nil) and (Position[i].Put <> nil) then
    begin
      if Position[i].Close then continue;
      Position[i].PL[0] := (Position[i].AvgPrice[0] - Position[i].Call.Last) * 500000 * Position[i].VirtualFilliedQty[0];
      Position[i].PL[1] := (Position[i].AvgPrice[1] - Position[i].Put.Last) * 500000 * Position[i].VirtualFilliedQty[1];
    end;
  end;
end;

function TGradeItem.CheckLossCut(dLossCut : double; iOrdQty : integer;
  bClear: boolean): TLosscutType;
var
  dSum, dBase : double;
  stLog : string;
  i, iQty : integer;
begin
  Result := ltNone;
  dSum := 0;
  iQty := 0;
  for i := 0 to 1 do
  begin
    if (Position[i].Call <> nil) and (Position[i].Put <> nil) then
    begin
      dSum := dSum + (Position[i].PL[0] * Position[i].FilledQty[0]) + (Position[i].PL[1] * Position[i].FilledQty[1]);
      iQty := iQty + Position[i].FilledQty[0] + Position[i].FilledQty[1];
    end;
  end;

  if bClear then
  begin
    Result := ltAll;
  end else
  begin
    if iQty < iOrdQty * 2 then exit;
    dBase := dLossCut * -10000 * iQty;
    if (dSum <= dBase) and (not Position[0].Close) and (not Position[1].Close)  then
    begin
      stLog := Format('CheckLossCut %d set, Sum = %.0f, Base = %.0f, iQty = %d',[FCurrentIndex,dSum, dBase, iQty ]);
      gEnv.EnvLog(WIN_VOLS, stLog);
      Result := ltAll;
    end;
  end;
end;

function TGradeItem.CheckOTE(iOte: integer): boolean;
begin
  Result := false;
  if (FEntry) or (iOte >= 0) then exit;
  
  if FEntryOTE >= iOte then
    Result := true;
end;

constructor TGradeItem.Create(aColl: TCollection);
var
  i : integer;
begin
  inherited Create(aColl);
  for i := 0 to 1 do
  begin
    Position[i] := TGradePosition.Create;
    Position[i].Call := nil;
    Position[i].Put := nil;
    Position[i].Close := false;
    Position[i].VirtualFilliedQty[0] := 1;
    Position[i].VirtualFilliedQty[1] := 1;
  end;
  FEntry := false;

end;

destructor TGradeItem.Destroy;
var
  i : integer;
begin
  for i := 0 to 1 do
    Position[i].Free;

  inherited;
end;

procedure TGradeItem.OrderFill(aOrder: TOrder);
var
  i : integer;
  stLog : string;
begin
  for i := 0 to 1 do
  begin
    if aOrder.Side = -1 then                 //매도 체결
    begin
      if Position[i].Call = aOrder.Symbol then
      begin
        Position[i].SumFillPrice[0] := Position[i].SumFillPrice[0] + aOrder.FilledPrice;
        Position[i].FilledQty[0] := aOrder.FilledQty;
        if aOrder.FilledQty <> 0 then
          Position[i].AvgPrice[0] := Position[i].SumFillPrice[0];

        stLog := Format('OrderFill Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, Position[i].FilledQty[0] ]);
        gEnv.EnvLog(WIN_VOLS, stLog);
      end;

      if Position[i].Put = aOrder.Symbol then
      begin
        Position[i].SumFillPrice[1] := Position[i].SumFillPrice[1] + aOrder.FilledPrice;
        Position[i].FilledQty[1] := aOrder.FilledQty;
        if aOrder.FilledQty <> 0 then
          Position[i].AvgPrice[1] := Position[i].SumFillPrice[1];
        stLog := Format('OrderFill Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, Position[i].FilledQty[1] ]);
        gEnv.EnvLog(WIN_VOLS, stLog);
      end;
    end else                               //매수 체결 확정 손익 .....
    begin
      if Position[i].Call = aOrder.Symbol then
      begin
        Position[i].PL[0] := (Position[i].AvgPrice[0] - aOrder.FilledPrice) * 500000;
        stLog := Format('OrderFill 청산 Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, aOrder.FilledQty ]);
        gEnv.EnvLog(WIN_VOLS, stLog);
      end;

      if Position[i].Put = aOrder.Symbol then
      begin
        Position[i].PL[1] := (Position[i].AvgPrice[1] - aOrder.FilledPrice) * 500000;
        stLog := Format('OrderFill 청산 Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, aOrder.FilledQty ]);
        gEnv.EnvLog(WIN_VOLS, stLog);
      end;
    end;
  end;

end;

procedure TGradeItem.SetSymbol(aCall, aPut: TSymbol; iIndex: integer);
var
  stLog : string;
begin
  inc(FSetCnt);
  Position[iIndex].Call := aCall;
  Position[iIndex].Put := aPut;

  stLog := Format('SetSymol Set = %d, %s, %s', [FCurrentIndex, aCall.ShortCode, aPut.ShortCode]);
  gEnv.EnvLog(WIN_VOLS, stLog);
end;

{ TVosSTrade }

procedure TVolSTrade.CalBasePL(aQuote : TQuote);
begin
  if FGradePos.Call = aQuote.Symbol then
    FGradePos.PL[0] := (FGradePos.AvgPrice[0] - aQuote.Symbol.Last) * 500000 * FGradePos.VirtualFilliedQty[0];

  if FGradePos.Put = aQuote.Symbol then
    FGradePos.PL[1] := (FGradePos.AvgPrice[1] - aQuote.Symbol.Last) * 500000 * FGradePos.VirtualFilliedQty[1];

  FBaseSum := Round((FGradePos.PL[0] + FGradePos.PL[1]) /10000);

  FGradePos.MaxPL := Max( FGradePos.MaxPL, FBaseSum);
end;

procedure TVolSTrade.CheckHighChange;
var
  iSum : integer;
  stLog : string;
begin
  if FGrades.ChangeItem = nil then exit;
  if FGrades.ChangeItem.Entry then exit;
  if FGradePos.MaxPL = 0 then exit;

  iSum := FGradePos.MaxPL - FBaseSum;
  if iSum >= FParam.Change then
  begin
    SearchSymbol(FGrades.ChangeItem, true);
    stLog := Format('CheckHighChange %d, %d, %d',[FGradePos.MaxPL , FBaseSum, iSum]);
    gEnv.EnvLog(WIN_VOLS, stLog);
    FGrades.SendOrder(Account, FParam.Qty, FGrades.ChangeItem);
  end;
end;

procedure TVolSTrade.CheckOrder;
var
  stLog : string;
begin
  if FGrades.GradeItem = nil then exit;
  if FGrades.GradeItem.CheckOTE(FBaseSum) then  // 가격넣어줌......
  begin

    if FGrades.GradeItem.Change then exit;
    SearchSymbol(FGrades.GradeItem, false);
    stLog := Format('CheckOrder Grade = %d, Sum = %d', [FGrades.GradeItem.FEntryOTE, FBaseSum]);
    gEnv.EnvLog(WIN_VOLS, stLog);
    FGrades.SendOrder(Account, FParam.Qty, FGrades.GradeItem);
  end;
end;

constructor TVolSTrade.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stVolS, true);
  FGrades := TGrades.Create;
  FGradePos := TGradePosition.Create;
  FGrades.Trade := self;
end;

destructor TVolSTrade.Destroy;
begin
  FGradePos.Free;
  FGrades.Free;

  inherited;
end;

procedure TVolSTrade.DoLog;
var
  stLog, stFile : string;
begin
  stLog := Format('%s, %.0f, %.0f, %.0f',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime),  TotPL/1000, FMaxPL/1000, FMinPL/1000] );

  stFile := Format('VolS_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_VOLS, stLog, true, stFile);
end;

function TVolSTrade.IsPrice(dPrice1, dPrice2: double; bHighChange : boolean): boolean;
begin
  if bhighChange then
  begin
    if (dPrice1 >= FParam.LowPrice) and (dPrice1 <= FParam.HighPrice)
      and (dPrice2 >= FParam.LowPrice) and (dPrice2 <= FParam.HighPrice) then
      Result := true
    else
      Result := false;
  end else
  begin
    if (dPrice1 >= FParam.ChangeDown) and (dPrice1 <= FParam.ChangeUp)
      and (dPrice2 >= FParam.ChangeDown) and (dPrice2 <= FParam.ChangeUp) then
      Result := true
    else
      Result := false;
  end;

end;

procedure TVolSTrade.LossCutOrder;
begin
  FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, true);
  FRun := false;
  exit;
end;

procedure TVolSTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  i : integer;
  aItem : TGradeItem;
  aType : TLossCutType;
begin
  if iDataID = 300 then
  begin
    DoLog;
    exit;
  end;

  FMinPL := Min( FMinPL, TotPL );
  FMaxPL := Max( FMaxPL, TotPL );

  if not FRun then exit;

  if aQuote.Symbol = gEnv.Engine.SymbolCore.Futures[0] then
  begin
    if aQuote.FTicks.Count >= 1 then
    begin
      if (FGradePos.Call = nil) and (FGradePos.Put = nil) then
        SetBaseSymbol           //Base종목 선정
      else
        exit;
    end;
  end;
  if (FParam.AutoLiquid) and (Frac(GetQuoteTime) >= Frac(FParam.LiquidTime)) then
  begin
    FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, true);
    FRun := false;
    exit;
  end;

  CalBasePL(aQuote);
  FGrades.CalPL(aQuote);
  CheckOrder;

  CheckHighChange;

  FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, false);
end;

procedure TVolSTrade.ReSet;
begin
  FRun := false;
  FGradePos.Init;
  FGrades.Clear;
end;

procedure TVolSTrade.SearchSymbol(aItem : TGradeItem; bHighChange : boolean);
var
  i : integer;
  aList : TList;
  aCall, aPut : TSymbol;
  bLow : boolean;
  stLog : string;
begin
  aList := TList.Create;

  if aItem = nil then exit;
  if bHighChange then
    GetStrangleSymbol(FParam.LowPrice, FParam.HighPrice, aList)
  else
    GetStrangleSymbol(FParam.ChangeDown, FParam.ChangeUp, aList);

  //종목 찾아서 주문 발주......
  if aList.Count = 2 then
  begin
    aCall := aList.Items[0];
    aPut := aList.Items[1];

    stLog := Format( 'SearchSymbol %s(%.2f), %s(%.2f), Gap = %.2f',
                  [aCall.ShortCode, aCall.Last, aPut.ShortCode, aPut.Last, aCall.Last-aPut.Last]);
    gEnv.EnvLog(WIN_VOLS, stLog);

    if IsPrice(aCall.Last, aPut.Last, bHighChange ) then
      aItem.SetSymbol(aCall, aPut, 0);
  end else if aList.Count = 4 then
  begin
    aCall := aList.Items[0];
    aPut := aList.Items[1];

    stLog := Format( 'SearchSymbol %s(%.2f), %s(%.2f), Gap = %.2f',
                  [aCall.ShortCode, aCall.Last, aPut.ShortCode, aPut.Last, aCall.Last-aPut.Last]);
    gEnv.EnvLog(WIN_VOLS, stLog);
    if IsPrice(aCall.Last, aPut.Last, bHighChange) then
      aItem.SetSymbol(aCall, aPut, 0);

    aCall := aList.Items[2];
    aPut := aList.Items[3];

    stLog := Format( 'SearchSymbol %s(%.2f), %s(%.2f), Gap = %.2f',
                  [aCall.ShortCode, aCall.Last, aPut.ShortCode, aPut.Last, aCall.Last-aPut.Last]);
    gEnv.EnvLog(WIN_VOLS, stLog);

    if IsPrice(aCall.Last, aPut.Last, bHighChange) then
      aItem.SetSymbol(aCall, aPut, 1);
  end;
  aList.Free;

end;

procedure TVolSTrade.SetBaseSymbol;
var
  bRet : boolean;
  aQuoteC, aQuoteP : TQuote;
  aCall, aPut : TSymbol;
begin
  bRet := GetRatioSBase(FParam.LowPrice, FParam.HighPrice, aCall, aPut, 0);

  if bRet then
  begin
    aQuoteC := aCall.Quote as TQuote;
    aQuoteP := aPut.Quote as TQuote;
    if (aQuoteC.FTicks.Count > 0) and (aQuoteP.FTicks.Count > 0) then
    begin
      if (aQuoteC.Bids[0].Price < PRICE_EPSILON) or (aQuoteP.Bids[0].Price < PRICE_EPSILON) then
        exit;

      AddPosition(aCall);
      AddPosition(aPut);

      FGradePos.Call := aCall;
      FGradePos.Put := aPut;

      FGradePos.AvgPrice[0] := aQuoteC.Bids[0].Price;
      FGradePos.AvgPrice[1] := aQuoteP.Bids[0].Price;
      FGradePos.FilledQty[0] := FParam.Qty;
      FGradePos.FilledQty[1] := FParam.Qty;

      CalBasePL(aQuoteC);
      CalBasePL(aQuoteP);

      if Assigned(OnResult) then
        OnResult(FGradePos, true);

      gEnv.EnvLog(WIN_VOLS, Format('SetBaseSymbol %s(%.2f), Cnt = %d, %s(%.2f), Cnt = %d',
      [aCall.ShortCode, aCall.Last, aQuoteC.FTicks.Count,
      aPut.ShortCode, aPut.Last, aQuoteP.FTicks.Count ] ));
    end;
  end;
end;

procedure TVolSTrade.SetGrade;
var
  i, iOte : integer;
  aItem : TGradeItem;
begin
  iOte := FParam.GradeStart;
  for i := 0 to FParam.GradeCount - 1 do
  begin
    aItem := FGrades.New(iOte, i, false);
    iOte := iOte + FParam.GradeGap;
  end;

  FGrades.New(FParam.Change, FGrades.Count, true);
end;

procedure TVolSTrade.Start(aAcnt: TAccount);
begin
  ReSet;
  Account := aAcnt;
  SetGrade;
  FRun := true;
end;

procedure TVolSTrade.Stop(bCheck : boolean);
begin
  FRun := false;
  if not bCheck then
    FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, true);
end;

procedure TVolSTrade.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
var
  aItem : TGradeItem;
begin
  case iID of
    ORDER_FILLED :
    begin
      aItem := FGrades.Find(aOrder.RatioPer);

      if (aItem <> nil) and (aOrder.State = osFilled) then
        aItem.OrderFill(aOrder);

      if aPos <> nil then
      begin
        if Assigned(OnResult) then
          OnResult(aPos, true);
      end;  
    end;
  end;
end;

{ TGrades }
procedure TGrades.CalPL(aQuote: TQuote);
var
  i : integer;
  aItem : TGradeItem;
begin
  if FGradeItem = nil then exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TGradeItem;
    aItem.CalPL;
  end;
end;

procedure TGrades.CheckLossCut(dLossCut : double; iOrdQty : integer; bClear: boolean);
var
  i : integer;
  aItem : TGradeItem;
  aType : TLossCutType;
begin
  if FGradeItem = nil then exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TGradeItem;
    aType := aItem.CheckLossCut(dLossCut, iOrdQty, bClear);
    LossCutOrder(aItem, aType);
  end;

end;

constructor TGrades.Create;

begin
  inherited Create(TGradeItem);
end;

destructor TGrades.Destroy;
begin

  inherited;
end;

function TGrades.DoOrder(aAcnt: TAccount; aSymbol: TSymbol; iSide, iQty,
  iOte: integer): TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
  stLog : string;
begin
    // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(FTrade);
  if iQty <= 0 then
    Exit;
  dPrice := GetPrice(aSymbol, iSide);
  // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aAcnt, aSymbol,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opVolS;
    Result.RatioPer := iOte;
    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format('DoOrder %s(%.2f), %d, %d%',[Result.Symbol.ShortCode, Result.Symbol.Last, Result.Side, GradeItem.EntryOTE]);
    gEnv.EnvLog(WIN_VOLS, stLog);
  end;

end;

function TGrades.Find(iOte: integer): TGradeItem;
var
  i : integer;
  aItem : TGradeItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TGradeItem;
    if aItem.EntryOTE = iOte then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

function TGrades.GetPrice(aSymbol: TSymbol; iSide: integer): double;
begin
  Result  := TicksFromPrice( aSymbol, aSymbol.Last, 10 * iSide );
end;

procedure TGrades.LossCutOrder(aItem: TGradeItem; aType: TLosscutType);
begin
  if not aItem.Entry then exit;

  case aType of
    ltHigh:
    begin
      if aItem.Position[0].Close then exit;
      if (aItem.Position[0].Call <> nil) and (aItem.Position[0].Put <> nil) then
      begin
        DoOrder(FAccount, aItem.Position[0].Call, 1, aItem.Position[0].FilledQty[0], aItem.EntryOTE);
        DoOrder(FAccount, aItem.Position[0].Put, 1, aItem.Position[0].FilledQty[1], aItem.EntryOTE);
        aItem.Position[0].Close := true;
      end;
    end;
    ltLow:
    begin
      if aItem.Position[1].Close then exit;
      if (aItem.Position[1].Call <> nil) and (aItem.Position[1].Put <> nil) then
      begin
        DoOrder(FAccount, aItem.Position[1].Call, 1, aItem.Position[1].FilledQty[0], aItem.EntryOTE);
        DoOrder(FAccount, aItem.Position[1].Put, 1, aItem.Position[1].FilledQty[1], aItem.EntryOTE);
        aItem.Position[1].Close := true;
      end;
    end;
    ltAll:
    begin
      if not aItem.Position[0].Close then
      begin
        if (aItem.Position[0].Call <> nil) and (aItem.Position[0].Put <> nil) then
        begin
          DoOrder(FAccount, aItem.Position[0].Call, 1, aItem.Position[0].FilledQty[0], aItem.EntryOTE);
          DoOrder(FAccount, aItem.Position[0].Put, 1, aItem.Position[0].FilledQty[1], aItem.EntryOTE);
          aItem.Position[0].Close := true;
        end;
      end;
      if not aItem.Position[1].Close then
      begin
        if (aItem.Position[1].Call <> nil) and (aItem.Position[1].Put <> nil) then
        begin
          DoOrder(FAccount, aItem.Position[1].Call, 1, aItem.Position[1].FilledQty[0], aItem.EntryOTE);
          DoOrder(FAccount, aItem.Position[1].Put, 1, aItem.Position[1].FilledQty[1], aItem.EntryOTE);
          aItem.Position[1].Close := true;
        end;
      end;
    end;
  end;
end;

function TGrades.New(iOte, iIndex: integer; bChange : boolean): TGradeItem;
var
  i : integer;
  aItem : TGradeItem;
begin
  Result := Add as TGradeItem;
  Result.CurrentIndex := iIndex;
  Result.FEntry := false;
  Result.SetCnt := 0;
  Result.Change := bChange;

  if bChange then
  begin
    Result.EntryOTE := iOte;
    FChangeItem := Result;      //고점대비...
  end else
  begin
    Result.EntryOTE := iOte * -1;
    if Count = 1 then
      FGradeItem := Result;
  end;
end;

procedure TGrades.SendOrder(aAcnt: TAccount; iQty: integer; aItem : TGradeItem);
var
  i, iIndex : integer;
  aCall, aPut : TSymbol;
  bRet : boolean;
  stLog : string;
begin
  if aItem = nil then exit;
  FAccount := aAcnt;
  bRet := false;

  stLog := Format('SendOrder %d', [aItem.CurrentIndex]);
  gEnv.EnvLog(WIN_VOLS, stLog);
  for i := 0 to 1 do
  begin
    aCall := aItem.Position[i].Call;
    aPut := aItem.Position[i].Put;
    aItem.Entry := true;
    iIndex := aItem.CurrentIndex;
    if (aCall <> nil) and (aPut <> nil) then
    begin
      DoOrder(aAcnt, aCall, -1, iQty, aItem.EntryOTE);
      DoOrder(aAcnt, aPut, -1, iQty, aItem.EntryOTE);
      bRet := true;
    end;
  end;

  if bRet then
  begin
    if Assigned(FTrade.OnResult) then
      FTrade.OnResult(aItem, false);
  end;

  if not aItem.Change then
  begin
    if iIndex + 1 < Count then
      FGradeItem := Items[iIndex +1] as TGradeItem;
  end;
end;

{ TGradePosition }

procedure TGradePosition.Init;
var
  i : integer;
begin
  Call := nil;
  Put := nil;
  for i := 0 to 1 do
  begin
    PL[i] := 0;
    SumFillPrice[i] := 0;
    AvgPrice[i] := 0;
    FilledQty[i] := 0;
    VirtualFilliedQty[i] := 1;
  end;
  Close := false;
end;

end.
