unit CleYHTrade;

interface
uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleCircularQueue,
  CleStrategyStore, CleOrderBeHaivors
  ;

type
  TYHStatus = (ysNone, ysEntry, ysEnd);

  TYHTrade = class;

  TYHParams = record
    Start : boolean;
    OrderQty : integer;
    MaxEntryCnt : integer;
    EntryRatio : integer;
    ClearRatio : integer;
    TermMin : integer;
    OpenOrder : boolean;
    LowPrice : double;
    HighPrice : double;
  end;

  TYHData = class(TCollectionItem)
  private
    FCall : TSymbol;
    FPut : TSymbol;
    FYH : double;
    FRatio : integer;
    FCallPos : TPosition;
    FPutPos : TPosition;
    FQueue : TCircularQueue;                           // 0 Index: 현재데이터 , 마지막Index : 과거데이터
    FStatus : TYHStatus;
    FRealEntryCnt : integer;
    FTerm : integer;
    FEntryCnt : integer;
    procedure SetStatus;
    function GetClearSide(iQty : integer) : integer;
    function GetPrice(iSide : integer; bCall : boolean) : double;
    function DoOrder(iQty : integer; aAcnt : TAccount; bClear : boolean) : TOrder;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;
    procedure MakeData;
    function GetStatus : string;
    property Status : TYHStatus read FStatus;
    property Call : TSymbol read FCall;
    property Put : TSymbol read FPut;
    property CallPos : TPosition read FCallPos;
    property PutPos : TPosition read FPutPos;
    property YH : double read FYH;
    property Ratio : integer read FRatio;
    property RealEntryCnt : integer read FRealEntryCnt;
  end;


  TYHs = class(TCollection)
  private
    FParam : TYHParams;
    FTermCnt : integer;
    FOpen : boolean;
    FAccount : TAccount;
    FScreenNumber : integer;
    FTrade : TYHTrade;
    FBeHaivors : TOrerBeHaivors;
    procedure ClearOrder;
    procedure OpenOrder;
    procedure CalcYH;
    function CheckRatio : boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function AddYH(aCall, aPut: TPosition; iQCnt: integer): TYHData;
    property ScreenNumber : integer read FScreenNumber;
  end;

  TYHTrade = class(TStrategyBase)
  private
    FYHs : TYHs;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    procedure SetSymbol;
    procedure SetAccount(aAcnt : TAccount);
    procedure StartStop(aParam : TYHParams);
    procedure ClearOrder;

    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    property YHs : TYHs read FYHs;
  end;

implementation
uses
  GAppenv, GleConsts;
{ TYHData }



constructor TYHData.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FStatus := ysNone;
  FQueue := nil;
end;

destructor TYHData.Destroy;
begin
  FQueue.Free;
  inherited;
end;

function TYHData.DoOrder(iQty: integer; aAcnt: TAccount; bClear : boolean): TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
  iSide : integer;
  aBe : TOrderBeHaivor;
  stLog : string;
begin
  //Call Order
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(TYHs(Collection).FTrade);

  if bClear then
  begin
    iSide := GetClearSide(FCallPos.Volume);
    iQty := abs(FCallPos.Volume);
  end else
    iSide := -1;

  if iQty <= 0 then
    Exit;

  //dPrice := GetPrice(iSide, true);
  dPrice := FCall.Last;
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aAcnt, FCall,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opYH;
    gEnv.Engine.TradeBroker.Send(aTicket);

    aBe := TYHs(Collection).FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);

    stLog := Format('Code = %s, Price = %.2f, OrderPrice = %.2f, Side = %d, Qty = %d, 양합 = %.2f, Ratio = %d, 횟수, = %d, %s',
                   [Result.Symbol.ShortCode, Result.Symbol.Last,  Result.Price, iSide, iQty, FYH, FRatio, FRealEntryCnt, GetStatus]);
    gEnv.EnvLog(WIN_YH, stLog);
  end;

  //Put Order
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(TYHs(Collection).FTrade);

  if bClear then
  begin
    iSide := GetClearSide(FPutPos.Volume);
    iQty := abs(FPutPos.Volume);
  end else
    iSide := -1;

  if iQty <= 0 then
    Exit;

  //dPrice := GetPrice(iSide, false);
  dPrice := FPut.Last;

    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aAcnt, FPut,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opYH;
    gEnv.Engine.TradeBroker.Send(aTicket);

    aBe := TYHs(Collection).FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);

    stLog := Format('Code = %s, Price = %.2f, OrderPrice = %.2f, Side = %d, Qty = %d, 양합 = %.2f, Ratio = %d, 횟수, = %d, %s',
                   [Result.Symbol.ShortCode, Result.Symbol.Last,  Result.Price, iSide, iQty, FYH, FRatio, FRealEntryCnt, GetStatus]);
    gEnv.EnvLog(WIN_YH, stLog);
  end;

  if bClear then
    inc(FRealEntryCnt);

  SetStatus;
end;

function TYHData.GetPrice(iSide: integer; bCall : boolean): double;
var
  aSymbol : TSymbol;
begin
  if bCall then
    aSymbol := FCall
  else
    aSymbol := FPut;

  if iSide = 1 then
    Result := aSymbol.LimitHigh
  else
    Result := aSymbol.LimitLow;
end;

function TYHData.GetClearSide(iQty: integer): integer;
begin
  Result := 1;
  if iQty < 0 then
    Result := 1
  else
    Result := -1;
end;

function TYHData.GetStatus: string;
begin
  case FStatus of
    ysNone : Result := 'None';
    ysEntry : Result := '진입';
    ysEnd : Result := '종료';
  end;
end;

procedure TYHData.MakeData;
var
  dPrice, dPrevPrice : double;
  stLog : string;
begin
  FYH := FCall.Last + FPut.Last;
  FQueue.PushItem(GetQuoteTime, FYH);
  dPrice := FQueue.Value[FTerm-1];
  dPrevPrice := FQueue.Value[0];
  if dPrevPrice = 0 then
    FRatio := 0
  else
    FRatio := Round((dPrice / dPrevPrice - 1) * 100);

  stLog := Format( 'Call = %.2f, Put = %.2f, 현재 = %.2f, 과거 = %.2f, Ratio = %d',
                  [FCall.Last, FPut.Last, dPrice, dPrevPrice, FRatio]);
  gEnv.EnvLog(WIN_YH, stLog);
end;

procedure TYHData.SetStatus;
begin


  if FStatus = ysNone then
    FStatus := ysEntry
  else
    FStatus := ysNone;

  if FRealEntryCnt = FEntryCnt then
    FStatus := ysEnd;    
end;

{ TYHs }

function TYHs.AddYH(aCall, aPut: TPosition; iQCnt: integer): TYHData;
begin
  if Count >= 2 then exit;

  Result := Add as TYHData;
  Result.FCall := aCall.Symbol;
  Result.FPut := aPut.Symbol;
  Result.FTerm := iQCnt;
  Result.FEntryCnt := FParam.MaxEntryCnt;
  Result.FPutPos := aPut;
  Result.FCallPos := aCall;
  if Result.FQueue = nil then
    Result.FQueue := TCircularQueue.Create(iQCnt);
end;

procedure TYHs.CalcYH;
var
  i : integer;
  aItem : TYHData;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TYHData;
    aItem.MakeData;
  end;
end;

function TYHs.CheckRatio : boolean;
var
  i : integer;
  aItem : TYHData;
begin
  Result := false;
  if not FParam.Start then exit;
  if FParam.TermMin > FTermCnt then exit;  // 1분 Term카운터 체크


  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TYHData;
    if aItem.Status = ysEnd then continue;  //진입횟수 체크

    if (aItem.Status = ysEntry) and (aItem.FRatio >= FParam.ClearRatio) then   //청산주문
    begin
      aItem.DoOrder(FParam.OrderQty, FAccount, true);
      Result := true;
    end else if (aItem.Status = ysNone) and (aItem.FRatio <= FParam.EntryRatio) then //진입주문
      aItem.DoOrder(FParam.OrderQty, FAccount, false);
  end;
end;

procedure TYHs.ClearOrder;
var
  i : integer;
  aItem : TYHData;
begin
  if not FParam.Start then exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TYHData;
    if aItem.Status = ysEntry then
      aItem.DoOrder(FParam.OrderQty, FAccount, true);
  end;
end;

constructor TYHs.Create;
begin
  inherited Create(TYHData);
  FTermCnt := 0;
  FOpen := false;
  FBeHaivors := TOrerBeHaivors.Create;
end;

destructor TYHs.Destroy;
begin
  FBeHaivors.Free;
  inherited;
end;

procedure TYHs.OpenOrder;
var
  i : integer;
  aItem : TYHData;
begin
  if not FParam.Start then exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TYHData;
    if aItem.Status = ysNone then
      aItem.DoOrder(FParam.OrderQty, FAccount, false);
  end;
end;

{ TYHTrade }

procedure TYHTrade.ClearOrder;
begin
  FYHs.ClearOrder;
end;

constructor TYHTrade.Create(aColl: TCollection; opType : TOrderSpecies);
begin
  inherited Create(aColl, opType, stYH, true);
  FYHs := TYHs.Create;
  FYHs.FScreenNumber := Number;
  FYHs.FTrade := self;
end;

destructor TYHTrade.Destroy;
begin
  FYHs.Free;
  inherited;
end;

procedure TYHTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  stTime : string;
  bRet : boolean;
begin
  if aQuote = nil then exit;
  if aQuote.Symbol <> gEnv.Engine.SymbolCore.Futures[0] then exit;

  stTime := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime);
  if FYHs.FParam.OpenOrder then                //시가 진입 주문 체크
  begin
    if (not FYHs.FOpen) and (Frac(GetQuoteTime) >= StartTime) then
    begin
      FYHs.OpenOrder;
      FYHs.FOpen := true;
    end;
  end;


  if (aQuote.AddTerm) and (Frac(GetQuoteTime) > StartTime) then
  begin
    // 양합 구하기
    inc(FYHs.FTermCnt);
    FYHs.CalcYH;

    // Ratio 맞으면 진입 주문 or Clear 주문
    bRet := FYHs.CheckRatio;

    //청산주문
    if Frac(GetQuoteTime) >= EndTime  then
    begin
      FYHs.ClearOrder;
      FYHs.FParam.Start := false;
    end;
  end;

  if Assigned(OnResult) then   //화면갱신
    OnResult(aQuote, bRet);

end;

procedure TYHTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FYHs.FAccount := aAcnt;
end;

procedure TYHTrade.SetSymbol;
var
  i, iCnt, iIndex : integer;
  aPos, aPos1 : TPosition;
  bRet : boolean;
begin
  bRet := SymbolSelect(FYHs.FParam.LowPrice, FYHs.FParam.HighPrice);

  if not bRet then
  begin
    gEnv.EnvLog(WIN_YH, '포지션설정실패');
    exit;
  end;

  iCnt := Positions.Count Div 2;
  iIndex := 0;
  for i := 0 to iCnt - 1 do
  begin
    aPos := Positions.Items[iIndex] as TPosition;
    inc(iIndex);
    aPos1 := Positions.Items[iIndex] as TPosition;
    inc(iIndex);
    FYHs.AddYH(aPos, aPos1, FYHs.FParam.TermMin + 1);
  end;
end;

procedure TYHTrade.StartStop(aParam : TYHParams);
begin
  FYHs.FParam := aParam;
end;

procedure TYHTrade.TradeProc(aOrder: TOrder; aPos : TPosition; iID: integer);
begin

end;

end.
