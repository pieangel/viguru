unit CleParityTrade;

interface

uses
  Classes,SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleStrategyStore,
  CleOrderBeHaivors
  ;

type
  TParityTrade = class;

  TOrderType = (otTrend, otBid);
  TEntryType = (etNone, etUp, etDown);
  TStatusType = (stNone, stHigh, stLow);

  TParityParams = record
    Start : boolean;
    OrderQty : integer;
    OrderType : TOrderType;
    BaseGap : integer;
    LowPrice : double;
    HighPrice : double;
    Multiple : integer;
  end;


  TParityItem = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FPosition : TPosition;
    FTradeing : boolean;
  public
    property Symbol : TSymbol read FSymbol;
    property Position : TPosition read FPosition write FPosition;
    property Tradeing : boolean read FTradeing;
  end;

  TParitys = class(TCollection)
  private
    FScreenNumber : integer;
    FParam : TParityParams;
    FAccount : TAccount;
    FTrade : TParityTrade;
    FBeHaivors : TOrerBeHaivors;
    function Find(aSymbol : TSymbol) : TParityItem;
    procedure AddSymbol(aSymbol : TSymbol);
    procedure SetPosition(aPos: TPosition);
  public
    constructor Create;
    destructor Destroy; override;
    procedure DoStrangle(aType : TEntryType);
    procedure DoTrend(aType : TEntryType);
    procedure ClearOrder;
    function DoOrder(aSymbol: TSymbol; iSide, iQty: integer): TOrder;
    property Param : TParityParams read FParam write FParam;
    property Account : TAccount read FAccount write FAccount;
  end;

  TParityTrade = class(TStrategyBase)
  private
    FParitys : TParitys;
    FAvg : double;
    FStatus : TStatusType;
    FFut : TSymbol;
    FGap : integer;
    FLowClear : boolean;
    FHighClear : boolean;
    procedure SendOrder(aType : TEntryType);
    procedure CalAvg;
    function CheckData : TEntryType;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;
    procedure SetSymbol;
    procedure ClearOrder;
    procedure SetAccount(aAcnt : TAccount);
    procedure StartStop(aParam : TParityParams);
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    function GetStatus : string;
    property Avg : double read FAvg;
    property Gap : integer read FGap;
  end;


implementation

uses
  GAppEnv, GleConsts, GleLib;
{ TParityTrade }

procedure TParityTrade.CalAvg;
var
  i : integer;
  dPrice , dSum : double;
  aOptionMarket : TOptionMarket;
  aStrike, aStrike1 : TStrike;
begin
  dSum := 0;
  aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    dPrice := (aStrike.Call as TSymbol).Last - (aStrike.Put as TSymbol).Last + aStrike.StrikePrice;
    dSum := dSum + dPrice;
  end;
  FAvg := dSum / aOptionMarket.Trees.FrontMonth.Strikes.Count;
end;

function TParityTrade.CheckData: TEntryType;
var
  stLog : string;
begin
  Result := etNone;
  if not FParitys.Param.Start then exit;
  
  CalAvg;

  FGap := Round((FFut.Last - FAvg) * 100);

  if FStatus = stNone then
  begin
    if FGap > 0 then
      FStatus := stHigh
    else if FGap < 0 then
      FStatus := stLow;
  end;

  if FStatus = stHigh then
  begin
    if FGap <= FParitys.Param.BaseGap * -1 then
    begin
      Result := etDown;
      FStatus := stLow;
      FLowClear := true;
      stLog := Format('stLow Last = %.2f, Avg = %.2f ,Gap = %d',[FFut.Last, FAvg, FGap]);
      gEnv.EnvLog(WIN_CP, stLog);
    end;

    if FHighClear then
    begin
      if (FParitys.Param.BaseGap * FParitys.Param.Multiple <= FGap) or ( FParitys.Param.BaseGap/2 * -1 >= FGap)  then
      begin
        FHighClear := false;
        stLog := Format('청산 Last = %.2f, Avg = %.2f ,Gap = %d',[FFut.Last, FAvg, FGap]);
        gEnv.EnvLog(WIN_CP, stLog);
        FParitys.ClearOrder;
      end;
    end;
  end else if FStatus = stLow then
  begin
    if FGap >= FParitys.Param.BaseGap then
    begin
      Result := etUp;
      FStatus := stHigh;
      FHighClear := true;
      stLog := Format('stHigh Last = %.2f, Avg = %.2f ,Gap = %d',[FFut.Last, FAvg, FGap]);
      gEnv.EnvLog(WIN_CP, stLog);
    end;
    if FLowClear then
    begin
      if (FParitys.Param.BaseGap * FParitys.Param.Multiple * -1 >= FGap) or ( FParitys.Param.BaseGap/2 <= FGap) then
      begin
        FLowClear := false;
        stLog := Format('청산 Last = %.2f, Avg = %.2f ,Gap = %d',[FFut.Last, FAvg, FGap]);
        gEnv.EnvLog(WIN_CP, stLog);
        FParitys.ClearOrder;
      end;
    end;
  end;
end;

procedure TParityTrade.ClearOrder;
begin
  FParitys.ClearOrder;
end;

constructor TParityTrade.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stParity, true);
  FParitys := TParitys.Create;
  FParitys.FScreenNumber := Number;
  FParitys.FTrade := self;
  FStatus := stNone;

  FFut := gEnv.Engine.SymbolCore.Futures[0];
  FHighClear := false;
  FLowClear := false;
end;

destructor TParityTrade.Destroy;
begin
  FParitys.Free;
  inherited;
end;

function TParityTrade.GetStatus: string;
begin
  case FStatus of
    stNone: Result := 'None';
    stHigh: Result := 'stHigh';
    stLow: Result := 'stLow';
  end;
end;

procedure TParityTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  aType : TEntryType;
begin
  if aQuote = nil then Exit;
  if aQuote.Symbol <> gEnv.Engine.SymbolCore.Futures[0] then exit;
  if aQuote.LastEvent <> qtTimeNSale then exit;

  aType := CheckData;
  if aType <> etNone then
    SendOrder(aType);

  //청산주문
  if Frac(GetQuoteTime) >= EndTime  then
  begin
    FParitys.ClearOrder;
    FParitys.FParam.Start := false;
  end;

  if Assigned(OnResult) then   //화면갱신
    OnResult(aQuote, true);
end;

procedure TParityTrade.SendOrder(aType : TEntryType);
begin
  if FParitys.Param.OrderType = otTrend then
    FParitys.DoTrend(aType)
  else
    FParitys.DoStrangle(aType);
end;

procedure TParityTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FParitys.FAccount := aAcnt;
end;

procedure TParityTrade.SetSymbol;
begin

end;

procedure TParityTrade.StartStop(aParam: TParityParams);
begin
  FParitys.FParam := aParam;
end;

procedure TParityTrade.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
begin
  if aPos = nil then exit;
  case iID of
    ORDER_FILLED : FParitys.SetPosition(aPos);
  end;
end;

{ TParitys }

procedure TParitys.AddSymbol(aSymbol: TSymbol);
var
  aItem : TParityItem;
begin
  aItem := Find(aSymbol);

  if aItem = nil then
  begin
    aItem := Add as TParityItem;
    aItem.FSymbol := aSymbol;
    aItem.Position := nil;
    aItem.FTradeing := false;
  end;

end;

procedure TParitys.ClearOrder;
var
  i, iSide, iQty :integer;
  aItem : TParityItem;
  aOrder : TOrder;
  stLog : string;
begin
  if not FParam.Start then exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TParityItem;

    if aItem.Position = nil then continue;


    iQty := abs(aItem.Position.Volume);
    if iQty = 0 then continue;

    if aItem.Position.Volume > 0 then
      iSide := -1
    else
      iSide := 1;

    aOrder := DoOrder(aItem.Position.Symbol, iSide, iQty);
    if aOrder = nil then
      gEnv.EnvLog(WIN_CP, '청산실패');
  end;
end;

constructor TParitys.Create;
begin
  inherited Create(TParityItem);
  FParam.Start := false;
  FBeHaivors := TOrerBeHaivors.Create;
end;

destructor TParitys.Destroy;
begin
  FBeHaivors.Free;
  inherited;
end;

function TParitys.DoOrder(aSymbol: TSymbol; iSide, iQty: integer): TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
  stLog : string;
  aBe : TOrderBeHaivor;
begin
  Result := nil;
    // issue an order ticket
  aTicket :=  gEnv.Engine.TradeCore.StrategyGate.GetTicket(FTrade);
  if iQty <= 0 then
    Exit;

  //dPrice := GetPrice(aSymbol, iSide);
  dPrice := aSymbol.Last;
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FAccount, aSymbol,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opParity;
    gEnv.Engine.TradeBroker.Send(aTicket);

    aBe := FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);

    stLog := Format('[Order] Code = %s, Qty = %d, Price = %.2f', [Result.Symbol.ShortCode, Result.OrderQty, Result.Price]);
    gEnv.EnvLog(WIN_CP, stLog);
  end;

end;

procedure TParitys.DoStrangle(aType : TEntryType);
var
  aITM, aOTM : TSymbol;
begin
case aType of
    etUp:
    begin
      //선물 상승 = 콜 ITM, 풋 OTM
      FTrade.GetInvestSymbol(true, FParam.LowPrice, FParam.HighPrice, aITM, aOTM );
      DoOrder(aITM, 1, FParam.OrderQty);
      DoOrder(aOTM, 1, FParam.OrderQty);
      AddSymbol(aITM);
      AddSymbol(aOTM);
    end;
    etDown:
    begin
      //선물 하락 =  풋 ITM, 콜 OTM
      FTrade.GetInvestSymbol(false, FParam.LowPrice, FParam.HighPrice, aITM, aOTM );
      DoOrder(aITM, 1, FParam.OrderQty);
      DoOrder(aOTM, 1, FParam.OrderQty);
      AddSymbol(aITM);
      AddSymbol(aOTM);
    end;
  end;
end;

procedure TParitys.DoTrend(aType : TEntryType);
var
  aCall, aPut : TSymbol;
begin
  case aType of
    etUp:
    begin
      //선물 상승 = 콜 매수 + 풋 매도
      FTrade.GetInvestSymbol(true, FParam.LowPrice, FParam.HighPrice, aCall, aPut );
      DoOrder(aCall, 1, FParam.OrderQty);
      AddSymbol(aCall);
      FTrade.GetInvestSymbol(false, FParam.LowPrice, FParam.HighPrice, aPut, aCall );
      DoOrder(aPut, -1, FParam.OrderQty);
      AddSymbol(aPut);

    end;
    etDown:
    begin
      //선물 하락 = 콜 매도 + 풋 매수
      FTrade.GetInvestSymbol(true, FParam.LowPrice, FParam.HighPrice, aCall, aPut );
      DoOrder(aCall, -1, FParam.OrderQty);
      AddSymbol(aCall);
      FTrade.GetInvestSymbol(false, FParam.LowPrice, FParam.HighPrice, aPut, aCall );
      DoOrder(aPut, 1, FParam.OrderQty);
      AddSymbol(aPut);
    end;
  end;


end;

function TParitys.Find(aSymbol: TSymbol): TParityItem;
var
  i : integer;
  aItem : TParityItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TParityItem;
    if aItem.Symbol = aSymbol then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

procedure TParitys.SetPosition(aPos: TPosition);
var
  i : integer;
  aItem : TParityItem;
begin
  if aPos = nil then exit;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TParityItem;
    if aItem.FSymbol = aPos.Symbol then
    begin
      aItem.Position := aPos;
      break;
    end;
  end;

end;

end.
