unit CleRatioSTrade;

interface
uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes, Math,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleOrderBeHaivors
  ;

type
  TLosscutType = (ltNone, ltHigh, ltLow, ltAll);

  TRatioSTrade = class;

  TRatioSParam = record
    Qty : integer;
    HighPrice : double;
    LowPrice : double;

    GradeStart : integer;
    GradeGap : integer;
    GradeCount : integer;

    ChangeUp : double;
    ChangeDown : double;

    LossCut : double;
    Tick : integer;
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
    Close : boolean;
  end;

  TGradeItem = class(TCollectionItem)
  private
    FPercent : integer;
    FSetCnt : integer;
    FEntry : boolean;
    FCurrentIndex : integer;
    FTick : boolean;
  public
    Position : array[0..1] of TGradePosition;
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;
    procedure CalPL;
    procedure OrderFill(aOrder : TOrder);
    function CheckLossCut(dLossCut : double; iOrdQty : integer; bClear : boolean = false) : TLosscutType;

    procedure SetSymbol(aCall, aPut : TSymbol; iIndex : integer);
    function CheckPer(dPer : double) : boolean;
    property Percent : integer read FPercent write FPercent;
    property Entry : boolean read FEntry write FEntry;
    property SetCnt : integer read FSetCnt write FSetCnt;
    property CurrentIndex: integer read FCurrentIndex write FCurrentIndex;
    property Tick : boolean read FTick write FTick;
  end;

  TGrades = class(TCollection)
  private
    FTrade : TRatioSTrade;
    FGradeItem : TGradeItem;
    FEntryTickItem : TGradeItem;
    FAccount : TAccount;
    function GetPrice(aSymbol : TSymbol; iSide : integer) : double;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CalPL(aQuote : TQuote);
    procedure CheckLossCut(dLossCut : double; iOrdQty : integer; bClear : boolean);
    procedure SendOrder(aAcnt : TAccount; iQty : integer; aItem : TGradeItem);
    procedure LossCutOrder( aItem : TGradeItem; aType : TLosscutType);
    function DoOrder(aAcnt : TAccount; aSymbol : TSymbol ; iSide, iQty, iPer : integer) : TOrder;
    function New( iPercent, iIndex : integer; bTick : boolean) : TGradeItem;
    function Find(iPercent : integer) : TGradeItem;
    property Trade : TRatioSTrade read FTrade write FTrade;
    property GradeItem : TGradeItem read FGradeItem write FGradeItem;
    property EntryTickItem : TGradeItem read FEntryTickItem write FEntryTickItem;
  end;

  TRatioSTrade = class(TStrategyBase)
  private
    FGrades : TGrades;
    FParam : TRatioSParam;
    FBaseCall : TSymbol;
    FBasePut : TSymbol;
    FBaseSum : double;

    FCurrentSum : double;
    FRatio : double;
    FRun : boolean;
    FPL : double;
    FMinPL, FMaxPL : double;
    procedure SetBaseSymbol;
    procedure CalRatioSum;
    procedure CheckOrder;
    procedure CheckEntryTick;
    procedure SetGrade;
    procedure SearchSymbol(aItem : TGradeItem);
    procedure DoLog;
    function IsPrice(dPrice1, dPrice2 : double) : boolean;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    procedure Start(aAcnt : TAccount);
    procedure Stop(bCheck : boolean = false);
    procedure ReSet;
    procedure LossCutOrder;
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    property Param : TRatioSParam read FParam write FParam;
    property BaseCall : TSymbol read FBaseCall;
    property BasePut : TSymbol read FBasePut;
    property BaseSum : double read FBaseSum;
    property CurrentSum : double read FCurrentSum;
    property Ratio : double read FRatio;
    property PL : double read FPL;
  end;


implementation

uses
  GAppEnv, GleLib, Dialogs, GleConsts, CleKrxSymbols;
{ TRatioSTrade }

procedure TRatioSTrade.CalRatioSum;
begin
  if (FBaseCall = nil) or (FBasePut = nil) or (FBaseSum = 0) then exit;
  FCurrentSum := FBaseCall.Last + FBasePut.Last;
  FRatio := (FCurrentSum / FBaseSum) * 100;
end;

procedure TRatioSTrade.CheckEntryTick;
var
  iTick : integer;
  dGap, dTmp : double;
  stLog : string;
begin
  if (FGrades.EntryTickItem = nil) or (FBaseCall = nil) or (FBasePut = nil) then exit;
  if FGrades.EntryTickItem.Entry then exit;
  
  dGap := FBaseCall.Last - FBasePut.Last;
  iTick := abs(Round(dGap / FBaseCall.Spec.TickSize));
  if iTick <= FParam.Tick then
  begin
    SearchSymbol(FGrades.EntryTickItem);
    stLog := Format('CheckEntryTick %.2f, %d',[dGap, iTick, FParam.Tick]);
    gEnv.EnvLog(WIN_RATIOS, stLog);
    FGrades.SendOrder(Account, FParam.Qty, FGrades.EntryTickItem);
  end;
end;

procedure TRatioSTrade.CheckOrder;
begin
  if FGrades.GradeItem = nil then exit;
  if FGrades.GradeItem.CheckPer(FRatio) then
  begin
    if FGrades.GradeItem.Tick then exit;
    SearchSymbol(FGrades.GradeItem);
    FGrades.SendOrder(Account, FParam.Qty, FGrades.GradeItem);
  end;
end;

constructor TRatioSTrade.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stRatioS, true);
  FGrades := TGrades.Create;
  FGrades.Trade := self;
end;

destructor TRatioSTrade.Destroy;
begin
  FGrades.Free;
  inherited;
end;

procedure TRatioSTrade.DoLog;
var
  stLog, stFile : string;
begin
  stLog := Format('%s, %.0f, %.0f, %.0f',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime),  TotPL/1000, FMaxPL/1000, FMinPL/1000] );

  stFile := Format('RatioS_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_RATIOS, stLog, true, stFile);
end;

function TRatioSTrade.IsPrice(dPrice1, dPrice2: double): boolean;
var
  dSum : double;
begin
  if (dPrice1 >= FParam.ChangeDown) and (dPrice1 <= FParam.ChangeUp)
    and (dPrice2 >= FParam.ChangeDown) and (dPrice2 <= FParam.ChangeUp) then
    Result := true
  else
    Result := false;
end;

procedure TRatioSTrade.LossCutOrder;
begin
  FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, true);
  FRun := false;
  exit;
end;

procedure TRatioSTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
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
      if (FBaseCall = nil) and (FBasePut = nil) then
        SetBaseSymbol           //Base???? ????
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

  CalRatioSum;
  CheckOrder;
  FGrades.CalPL(aQuote);
  CheckEntryTick;

  FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, false);
end;

procedure TRatioSTrade.ReSet;
begin
  FBaseCall := nil;
  FBasePut := nil;
  FBaseSum := 0;
  FCurrentSum := 0;
  FRatio := 0;
  FRun := false;
  FGrades.Clear;
end;

procedure TRatioSTrade.SearchSymbol(aItem : TGradeItem);
var
  i : integer;
  aList : TList;
  aCall, aPut : TSymbol;
  bLow : boolean;
  stLog : string;
begin
  aList := TList.Create;

  if aItem = nil then exit;
  GetStrangleSymbol(FParam.ChangeDown, FParam.ChangeUp, aList);
  //???? ?????? ???? ????......
  if aList.Count = 2 then
  begin
    aCall := aList.Items[0];
    aPut := aList.Items[1];

    stLog := Format( 'SearchSymbol %s(%.2f), %s(%.2f), Gap = %.2f',
                  [aCall.ShortCode, aCall.Last, aPut.ShortCode, aPut.Last, aCall.Last-aPut.Last]);
    gEnv.EnvLog(WIN_RATIOS, stLog);

    if IsPrice(aCall.Last, aPut.Last) then
      aItem.SetSymbol(aCall, aPut, 0);
  end else if aList.Count = 4 then
  begin
    aCall := aList.Items[0];
    aPut := aList.Items[1];

    stLog := Format( 'SearchSymbol %s(%.2f), %s(%.2f), Gap = %.2f',
                  [aCall.ShortCode, aCall.Last, aPut.ShortCode, aPut.Last, aCall.Last-aPut.Last]);
    gEnv.EnvLog(WIN_RATIOS, stLog);
    if IsPrice(aCall.Last, aPut.Last) then
      aItem.SetSymbol(aCall, aPut, 0);

    aCall := aList.Items[2];
    aPut := aList.Items[3];

    stLog := Format( 'SearchSymbol %s(%.2f), %s(%.2f), Gap = %.2f',
                  [aCall.ShortCode, aCall.Last, aPut.ShortCode, aPut.Last, aCall.Last-aPut.Last]);
    gEnv.EnvLog(WIN_RATIOS, stLog);

    if IsPrice(aCall.Last, aPut.Last) then
      aItem.SetSymbol(aCall, aPut, 1);
  end;
  aList.Free;
end;

procedure TRatioSTrade.SetBaseSymbol;
var
  bRet : boolean;
  aQuoteC, aQuoteP : TQuote;
begin
  bRet := GetRatioSBase(FParam.LowPrice, FParam.HighPrice, FBaseCall, FBasePut, 0);

  if bRet then
  begin
    aQuoteC := FBaseCall.Quote as TQuote;
    aQuoteP := FBasePut.Quote as TQuote;
    if (aQuoteC.FTicks.Count > 0) and (aQuoteP.FTicks.Count > 0) then
    begin
      if (aQuoteC.Bids[0].Price < PRICE_EPSILON) or (aQuoteP.Bids[0].Price < PRICE_EPSILON) then
      begin
        FBaseCall := nil;
        FBasePut := nil;
        exit;
      end;

      AddPosition(FBaseCall);
      AddPosition(FBasePut);
      FBaseSum := FBaseCall.Last + FBasePut.Last;
      gEnv.EnvLog(WIN_RATIOS, Format('SetBaseSymbol %s(%.2f), Cnt = %d, %s(%.2f), Cnt = %d',
      [FBaseCall.ShortCode, FBaseCall.Last, aQuoteC.FTicks.Count,
      FBasePut.ShortCode, FBasePut.Last, aQuoteP.FTicks.Count ] ));
    end else
    begin
      FBaseCall := nil;
      FBasePut := nil;
    end;
  end
  else
  begin
    FBaseCall := nil;
    FBasePut := nil;
    //gEnv.EnvLog(WIN_RATIOS, 'Base???? ????');
  end;
end;

procedure TRatioSTrade.SetGrade;
var
  i, iPer : integer;
  aItem : TGradeItem;
begin
  iPer := FParam.GradeStart;
  for i := 0 to FParam.GradeCount - 1 do
  begin
    aItem := FGrades.New(iPer, i, false);
    iPer := iPer + FParam.GradeGap;
  end;
  FGrades.New(FParam.Tick, FGrades.Count, true);
end;

procedure TRatioSTrade.Start(aAcnt : TAccount);
begin
  ReSet;
  Account := aAcnt;
  SetGrade;
  FRun := true;
end;

procedure TRatioSTrade.Stop(bCheck : boolean);
begin
  FRun := false;

  if not bCheck then
    FGrades.CheckLossCut(FParam.LossCut, FParam.Qty, true);
end;

procedure TRatioSTrade.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
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

  for i := 0 to Count -1 do
  begin
    aItem := Items[i] as TGradeItem;
    aItem.CalPL;
  end;

end;

procedure TGrades.CheckLossCut(dLossCut : double; iOrdQty : integer; bClear : boolean);
var
  i : integer;
  aItem : TGradeItem;
  aType : TLossCutType;
begin
  if FGradeItem = nil then exit;

  for i := 0 to Count -1 do
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

function TGrades.DoOrder(aAcnt : TAccount; aSymbol: TSymbol; iSide, iQty, iPer: integer): TOrder;
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
    Result.OrderSpecies := opRatioS;
    Result.RatioPer := iPer;
    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format('DoOrder %s(%.2f), %d, %d%',[Result.Symbol.ShortCode, Result.Symbol.Last, Result.Side, GradeItem.Percent]);
    gEnv.EnvLog(WIN_RATIOS, stLog);
  end;
end;

function TGrades.Find(iPercent : integer): TGradeItem;
var
  i : integer;
  aItem : TGradeItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TGradeItem;
    if aItem.Percent = iPercent then
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
        DoOrder(FAccount, aItem.Position[0].Call, 1, aItem.Position[0].FilledQty[0], aItem.Percent);
        DoOrder(FAccount, aItem.Position[0].Put, 1, aItem.Position[0].FilledQty[1], aItem.Percent);
        aItem.Position[0].Close := true;
      end;
    end;
    ltLow:
    begin
      if aItem.Position[1].Close then exit;
      if (aItem.Position[1].Call <> nil) and (aItem.Position[1].Put <> nil) then
      begin
        DoOrder(FAccount, aItem.Position[1].Call, 1, aItem.Position[1].FilledQty[0], aItem.Percent);
        DoOrder(FAccount, aItem.Position[1].Put, 1, aItem.Position[1].FilledQty[1], aItem.Percent);
        aItem.Position[1].Close := true;
      end;
    end;
    ltAll:
    begin
      if not aItem.Position[0].Close then
      begin
        if (aItem.Position[0].Call <> nil) and (aItem.Position[0].Put <> nil) then
        begin
          DoOrder(FAccount, aItem.Position[0].Call, 1, aItem.Position[0].FilledQty[0], aItem.Percent);
          DoOrder(FAccount, aItem.Position[0].Put, 1, aItem.Position[0].FilledQty[1], aItem.Percent);
          aItem.Position[0].Close := true;
        end;
      end;
      if not aItem.Position[1].Close then
      begin
        if (aItem.Position[1].Call <> nil) and (aItem.Position[1].Put <> nil) then
        begin
          DoOrder(FAccount, aItem.Position[1].Call, 1, aItem.Position[1].FilledQty[0], aItem.Percent);
          DoOrder(FAccount, aItem.Position[1].Put, 1, aItem.Position[1].FilledQty[1], aItem.Percent);
          aItem.Position[1].Close := true;
        end;
      end;
    end;
  end;
end;

function TGrades.New(iPercent, iIndex : integer; bTick : boolean): TGradeItem;
var
  i : integer;
  aItem : TGradeItem;
begin
  Result := Add as TGradeItem;
  Result.CurrentIndex := iIndex;
  Result.FEntry := false;
  Result.SetCnt := 0;
  Result.Percent := iPercent;
  Result.Tick := bTick;
  if bTick then
    FEntryTickItem := Result
  else
  begin
    if Count = 1 then
      FGradeItem := Result;
  end;
end;

procedure TGrades.SendOrder(aAcnt: TAccount; iQty : Integer; aItem : TGradeItem);
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
  gEnv.EnvLog(WIN_RATIOS, stLog);
  for i := 0 to 1 do
  begin
    aCall := aItem.Position[i].Call;
    aPut := aItem.Position[i].Put;
    aItem.Entry := true;
    iIndex := aItem.CurrentIndex;
    if (aCall <> nil) and (aPut <> nil) then
    begin
      DoOrder(aAcnt, aCall, -1, iQty, aItem.Percent);
      DoOrder(aAcnt, aPut, -1, iQty, aItem.Percent);
      bRet := true;
    end;
  end;

  if bRet then
  begin
    if Assigned(FTrade.OnResult) then
      FTrade.OnResult(aItem, false);
  end;

  if not aItem.Tick then
  begin
    if iIndex + 1 < Count then
      FGradeItem := Items[iIndex +1] as TGradeItem;
  end;
end;

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
      Position[i].PL[0] := (Position[i].AvgPrice[0] - Position[i].Call.Last) * 500000 * Position[i].FilledQty[0];
      Position[i].PL[1] := (Position[i].AvgPrice[1] - Position[i].Put.Last) * 500000 * Position[i].FilledQty[1];
    end;
  end;
end;

function TGradeItem.CheckLossCut(dLossCut : double; iOrdQty : integer; bClear : boolean) : TLosscutType;
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
      dSum := dSum + Position[i].PL[0] + Position[i].PL[1];
      iQty := iQty + Position[i].FilledQty[0] + Position[i].FilledQty[1];
    end;
  end;

  if bClear then
  begin
    Result := ltAll;
  end else
  begin
    if iQty <  iOrdQty * 2 then exit;
    dBase := dLossCut * -10000 * iQty;
    if (dSum <= dBase) and (not Position[0].Close) and (not Position[1].Close)  then
    begin
      stLog := Format('CheckLossCut Low %d set, Sum = %.0f, Base = %.0f, iQty = %d',[FCurrentIndex,dSum, dBase, iQty ]);
      gEnv.EnvLog(WIN_RATIOS, stLog);
      Result := ltAll;  
    end;
  end;
end;

function TGradeItem.CheckPer(dPer: double): boolean;
begin
  Result := false;
  if FEntry then exit;

  if FPercent <= dPer then
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
    if aOrder.Side = -1 then                 //???? ????
    begin
      if Position[i].Call = aOrder.Symbol then
      begin
        Position[i].SumFillPrice[0] := Position[i].SumFillPrice[0] + aOrder.FilledPrice;
        Position[i].FilledQty[0] := aOrder.FilledQty;
        if aOrder.FilledQty <> 0 then
          Position[i].AvgPrice[0] := Position[i].SumFillPrice[0];

        stLog := Format('OrderFill Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, Position[i].FilledQty[0] ]);
        gEnv.EnvLog(WIN_RATIOS, stLog);
      end;

      if Position[i].Put = aOrder.Symbol then
      begin
        Position[i].SumFillPrice[1] := Position[i].SumFillPrice[1] + aOrder.FilledPrice;
        Position[i].FilledQty[1] := aOrder.FilledQty;
        if aOrder.FilledQty <> 0 then
          Position[i].AvgPrice[1] := Position[i].SumFillPrice[1];
        stLog := Format('OrderFill Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, Position[i].FilledQty[1] ]);
        gEnv.EnvLog(WIN_RATIOS, stLog);
      end;
    end else                               //???? ???? ???? ???? .....
    begin
      if Position[i].Call = aOrder.Symbol then
      begin
        Position[i].PL[0] := (Position[i].AvgPrice[0] - aOrder.FilledPrice) * 500000 * aOrder.FilledQty;
        stLog := Format('OrderFill ???? Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, aOrder.FilledQty ]);
        gEnv.EnvLog(WIN_RATIOS, stLog);
      end;

      if Position[i].Put = aOrder.Symbol then
      begin
        Position[i].PL[1] := (Position[i].AvgPrice[1] - aOrder.FilledPrice) * 500000 * aOrder.FilledQty;
        stLog := Format('OrderFill ???? Set = %d, %s, %.2f, Qty = %d', [FCurrentIndex, aOrder.Symbol.ShortCode, aOrder.FilledPrice, aOrder.FilledQty ]);
        gEnv.EnvLog(WIN_RATIOS, stLog);
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
  gEnv.EnvLog(WIN_RATIOS, stLog);
end;

end.
