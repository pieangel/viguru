unit CleStrategyBase;

interface
uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleStrategyStore, CleOrders, CleQuoteBroker, GleTypes,
  CleQuoteTimers 
  ;

type
  TStrategyBase = class
  private

  public
    FStrategy : TStrategyItem;
    FStartTime : TDateTime;
    FEndTime : TDateTime;
    FAccount : TAccount;
    FOrderType : TOrderSpecies;
    FOnResult : TResultNotifyEvent;

    constructor Create(opType : TOrderSpecies);
    destructor Destroy; override;
    procedure SetAccount(aAcnt : TAccount); virtual;
    function GetPrice( iSide : integer; aQuote : TQuote ) : double;
    function DoOrder( iSide, iQty : integer; aSymbol : TSymbol ) : TOrder;
    function SymbolSelect( dLow, dHigh: double) : boolean;
  end;

implementation

uses
  GAppEnv;

{ TStrategyBase }

constructor TStrategyBase.Create( opType : TOrderSpecies );
begin
  inherited Create;
  FOrderType := opType;
  FStartTime := EnCodeTime(9,0,1,0);
  FEndTime := EnCodeTime(14,40,0,0);
  FStrategy := nil;
  FAccount := nil;
end;

destructor TStrategyBase.Destroy;
begin

  inherited;
end;

function TStrategyBase.DoOrder(iSide, iQty: integer; aSymbol : TSymbol): TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
begin
  Result := nil;
  {
  // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  if iQty <= 0 then
    Exit;

  dPrice := GetPrice(iSide, aSymbol.Quote as TQuote);
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FAccount, aSymbol,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := FStrategy.OrderType;
    gEnv.Engine.TradeBroker.Send(aTicket);
    FStrategy.AddOrder(Result);
  end;
   }
end;

function TStrategyBase.GetPrice(iSide: integer; aQuote : TQuote): double;
begin
  {
  if iSide = 1 then
    Result := aQuote.Asks[4].Price
  else
    Result := aQuote.Bids[4].Price;
    }
end;

procedure TStrategyBase.SetAccount(aAcnt: TAccount);
begin
  FAccount := aAcnt;
  FStrategy := gEnv.Engine.TradeCore.StrategyGate.AddStrategy(0, FOrderType, FAccount);
end;

function TStrategyBase.SymbolSelect(dLow, dHigh: double) : boolean;
var
  i, j : integer;
  aC, aP, aMinSymbol : TSymbol;
  dC, dP, dMin, dGap : double;
  stLog : string;
  aCall, aPut : TList;
  bExpect : boolean;

begin
  aCall := TList.Create;
  aPut := TList.Create;

  if Frac(GetQuoteTime) < FStartTime then
    bExpect := true
  else
    bExpect := false;

  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, bExpect, aCall, aPut);  //현재가

    // 데이터 체크
  if not bExpect then
  begin
    for i := 0 to aCall.Count - 1 do
    begin
      aC := aCall.Items[i];
      if (aC.Quote as TQuote).Sales.Count <= 2 then
        exit;
    end;

    for i := 0 to aPut.Count - 1 do
    begin
      aP := aPut.Items[i];
      if (aC.Quote as TQuote).Sales.Count <= 2 then
        exit;
    end;
  end;


  for i := 0 to aCall.Count - 1 do
  begin
    aC := aCall.Items[i];
    aMinSymbol := nil;
    dMin := 1000;
    if bExpect then
      dC := aC.ExpectPrice
    else
      dC := aC.Last;

    for j := aPut.Count - 1 downto 0 do
    begin
      aP := aPut.Items[j];
      if bExpect then
        dP := aP.ExpectPrice
      else
        dP := aP.Last;

      dGap := dC - dP;
      if dGap < 0 then
        dGap := dGap * -1;


      stLog := Format('Code = %s, %.2f, Code = %s, %.2f, Gap = %.2f, Call = %d, Put = %d',
        [aC.ShortCode, dC, aP.ShortCode, dP, dGap, aCall.Count, aPut.Count]);
      gEnv.EnvLog(WIN_STR, stLog);

      if dMin > dGap then
      begin
        dMin := dGap;
        aMinSymbol := aP;
      end;
    end;
    if aMinSymbol = nil then continue;
    if FStrategy = nil then continue;
    FStrategy.AddPosition(aC, aMinSymbol);

    if (aC as TOption).DaysToExp = 1 then
      FEndTime := EnCodeTime(14, 40, 0 ,0)
    else
      FEndTime := EnCodeTime(15, 0, 0, 0);
  end;

  if FStrategy.Positions.Count = 0 then
    Result := false
  else
    Result := true;

  aCall.Free;
  aPut.Free;
end;

end.
