unit CleFQN;

interface

uses
  SysUtils,

  CleParsers;

type
  // FQN = symbol@[sub-market.][underlying.].market.exchange.country

  // 마켓 타입 : 분류없음, 인덱스, 주식, 채권, ETF, 선물, 옵션, ELW, 통화, 상품, 스프레드
  TMarketType = (mtNotAssigned,
                 mtIndex, mtStock, mtBond, mtETF, mtFutures, mtOption, mtELW,
                 mtCurrency, mtCommodity, mtSpread);

  TMarketTypes = set of TMarketType;

  // 기본  타입 : kospi200, kosdaq50, 주식, 미니 코스피200, 달러, 채권, 10년 국채 
  TUnderlyingType = (utKospi200, utKosdaq50, utStock, utMiniKospi200, utDollar, utBond3, utBond10);

  TFQNParser = class(TParser)
  private
      // original FQN
    FFQN: String;

      // FQNs
    FMarketFQN: String;
    FExchangeFQN: String;
    FSymbolFQN: String;

      // Market FQN component
    FCountry: String;
    FExchange: String;
    FMarket: String;
    FUnderlying: String;
    FSubMarket: String;
    FSymbol: String;

      //
    FMarketType: TMarketType;

    procedure SetFQN(const Value: String);
  public
    constructor Create;

    property FQN: String read FFQN write SetFQN;
    
    property MarketFQN: String read FMarketFQN;
    property ExchangeFQN: String read FExchangeFQN;
    property SymbolFQN: String read FSymbolFQN;

    property Country: String read FCountry;
    property Bourse: String read FExchange;
    property Market: String read FMarket;
    property Underlying: String read FUnderlying;
    property SubMarket: String read FSubMarket;
    property Symbol: String read FSymbol;

    property MarketType: TMarketType read FMarketType;
  end;

implementation

type
  TMarketToken = record
    Market: TMarketType;
    Token: String;
  end;

const
  MARKET_TOKENS: array[0..9] of TMarketToken =
            ((Market: mtIndex;   Token: 'index'),
             (Market: mtStock;   Token: 'stock'),
             (Market: mtBond;    Token: 'bond'),
             (Market: mtETF;     Token: 'etf'),
             (Market: mtFutures; Token: 'future'),
             (Market: mtOption;  Token: 'option'),
             (Market: mtELW;     Token: 'elw'),
             (Market: mtCurrency;   Token: 'currency'),
             (Market: mtCommodity;  Token: 'commodity'),
             (Market: mtSpread;     Token: 'spread'));

constructor TFQNParser.Create;
begin
  inherited Create(['.']);
end;

procedure TFQNParser.SetFQN(const Value: String);
var
  i, iPos: Integer;
begin
    // reset
  FFQN := '';
  FExchangeFQN := '';
  FMarketFQN := '';
  FSymbolFQN := '';

  FCountry := '';
  FExchange := '';
  FMarket := '';
  FUnderlying := '';
  FSubMarket := '';
  FSymbol := '';

  FMarketType := mtNotAssigned;

    // separate symbol from FQN if any
  iPos := Pos('@', Value);
  if iPos > 0 then
  begin
    FSymbol := UpperCase(Copy(Value, 1, iPos-1));
    FMarketFQN := LowerCase(Trim(Copy(Value, iPos+1, Length(Value)-iPos)));
    FSymbolFQN := FSymbol + '@' + FMarketFQN;
    FFQN := FSymbolFQN;
  end else
  begin
    FSymbol := '';
    FSymbolFQN := '';
    FMarketFQN := LowerCase(Trim(Value));
    FFQN := FMarketFQN;
  end;

    // de-component of MarketFQN
  try
    Parse(FMarketFQN);

      // set country
    if Count >= 1 then
      FCountry := Strings[Count-1];

      // exchange code
    if Count >= 2 then
      FExchange := Strings[Count-2];

      // market
    if Count >= 3 then
    begin
      FMarket := Strings[Count-3];
      for i := Low(MARKET_TOKENS) to High(MARKET_TOKENS) do
        if CompareStr(MARKET_TOKENS[i].Token, FMarket) = 0 then
        begin
          FMarketType := MARKET_TOKENS[i].Market;
          Break;
        end;
    end;

      // underlying or submarket
    if Count >= 4 then
    case FMarketType of
      mtNotAssigned: ;
      mtIndex, mtStock, mtBond, mtETF, mtCommodity:
        for i := 4 to Count do
          FSubMarket := Strings[Count-i] + '.' + FSubMarket;
      mtFutures, mtOption, mtSpread, mtELW:
        begin
          FUnderlying := Strings[Count-4];
          if Count >= 5 then
            for i := 5 to Count do
              FSubMarket := Strings[Count-i] + '.' + FSubMarket;
        end;
    end;
  finally
  end;
end;


end.
