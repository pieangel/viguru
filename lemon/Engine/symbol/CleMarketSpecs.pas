unit CleMarketSpecs;

interface

uses
  Classes, SysUtils,

  CleFQN, CleSymbolParser, CleCollections, CleParsers;

const
  MARKET_TYPE_DESC: array[TMarketType] of String =
                 ('Not Assigned',
                  'Index', 'Stock', 'Bond', 'ETF', 'Futures', 'Options', 'ELW', 
                  'Currency', 'Commodity', 'Spread');

  SHORT_MONTHS: array[1..12] of String =
                 ('Jan','Feb','Mar','Apr','May','Jun'
                  ,'Jul','Aug','Sep','Oct','Nov','Dec');

  US_MONTH_CODES = 'FGHJKMNQUVXZ';

  STOCK_FUT = 'Stock Futures';

  CURRENCY_DOLLAR  = 301;
  CURRENCY_EURO    = 302;
  CURRENCY_WON     = 303;
  CURRENCY_YUAN    = 304;
  CURRENCY_YEN     = 305;

  {
     1,2,7 : Result := 'usa';   // 미국 시카고
   3 : Result := 'sin';       // 싱가포르
   4, 9 : Result := 'gbr';     // great britain    런던
   5 : Result := 'ger';         // 독일 베를린
   6 : Result := 'hkg';         // hong kong china
   8 : Result := 'jpn';
   10 : Result := 'bra';
   }

  COUNTRY_USA   = 'usa';
  COUNTRY_KOREA = 'kor';
  COUNTRY_SINGA = 'sin';  // 싱가포르
  COUNTRY_GERMA = 'gbr';  // 독일
  COUNTRY_HONGKONG = 'hkg';
  COUNTRY_JAPAN = 'jpn';
  COUNTRY_BRAZIL = 'bra';

  UNDER_CURRENCY = '통화';
  UNDER_INDEX    = '지수';
  UNDER_BOND     = '금리';
  UNDER_COMMODITY = '상품';
  UNDER_COMMODITY_ENERGY = '에너지';
  UNDER_COMMODITY_METAL = '금속';
  UNDER_COMMODITY_FARM = '농산';
  UNDER_COMMODITY_LIVE = '축산';
  UNDER_COMMODITY_SOFT = 'soft';
type

  // Option TickSize Depth;

  TTSizeDepth = class( TCollectionItem )
  public
    StartPrc : double;
    EndPrc : double;
    Size  : double;
  end;

  TTSizeDepths = class( TCollection )
  private
    function GetDepth(i: Integer): TTSizeDepth;
    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
    procedure inc;
  public
    constructor Create;
    function New :  TTSizeDepth;
    property Size: Integer read GetSize write SetSize;
    property Depths[i:Integer]: TTSizeDepth read GetDepth; default;
  end;

  // 시장 특성 (Market Specification)
  TMarketSpec = class(TCollectionItem)
  private
    FViMarketName: String; // Vi 마켓 이름
      // identification name
    FFQN: String;  // fully qualified name

      // FQN components
    FCountry: String;  // 국가
    FExchange: String; // 거래소
    FMarket: TMarketType; // 마켓 타입 
    FUnderlying: String;

      // basic info
    FRootCode: String; // 루트 코드
    FDescription: String;  // 설명
    FSector: String; // 섹터
    FCurrency: Integer; // 통화

      // point value
    FContractSize: Double; // for derivatives, in cash markets, it's '1'  계약단위
    FPriceQuote: Double;    // a unit currency 0.01 = cent if 'currency' is Dolloar  // 통화 단위
    FPointValue: Double;    // value for '1.0' as price = ContractSize * CurrencyUnit // 포인트 가치

      // minimum price movement(it's not fixed in Korean market)
    FTickSize: Double;   // actual tick size, if 'Fraction' > 0, TickSize = 1 / FFraction  틱 크기
    FFraction: Integer;  // 1, 4, 8, 16, 32, 64, 128   // 프랙션
    FTickValue: Double;  // = FTickSize * FPointValue // 틱 가치
    FPrecision: Integer; // floating point precision  // 부동 소수 자리수

      // expiration months
    FContractMonths: array[1..12] of Boolean;  // 만료 월 

      // temporary
    FSpreadATR: Double;
    FFlatATR: Double;
    FSubMarket: string;
    FFormation: integer;
    FAdjustVal: double;
    FTSizes: TTSizeDepths;

    FPriceCrt: TObject;
    FIsUpdate: boolean;

      // (later)
    //FTopStep: Integer; // month
    // expiration info: last trading day, ...
    // margin info: initial margin, maintenance margin, spread margin....

    function GetMonth(i: Integer): Boolean;
    procedure SetMonth(i: Integer; const Value: Boolean);
    procedure SetMarket(const Value: TMarketType);
  public
    constructor Create(aColl: TCollection); override;
    Destructor  Destroy; override;

    procedure SetTick(dTickSize: Double; iFraction, iPrecision: Integer);
    procedure SetPoint(dContractSize: Double; dPriceQuote: Double; iFormat : integer = 0 );
    // use dongbu...
    procedure SetTickValue(dTickValue: Double);
    procedure SetTickDongBu(dTickSize, dAdjValue: Double);
    procedure SetSector( stValue : string);
    function Represent: String;
    function GetMarketType : char;
    function NextPrice( dPrice : double; iSign : integer ) : double;

    property ViMarketName: String read FViMarketName;

    property FQN: String read FFQN write FFQN;

    property Country: String read FCountry;
    property Exchange: String read FExchange;
    property Market: TMarketType read FMarket write SetMarket;
    property Underlying: String read FUnderlying;
    property SubMarket : string read FSubMarket;

    property RootCode: String read FRootCode write FRootCode;
    property Description: String read FDescription write FDescription;
    property Sector: String read FSector write FSector ;
    //property SectorID : string read FSectorID write FSEctorID;
    property Currency: Integer read FCurrency write FCurrency;

    property ContractSize: Double read FContractSize;
    property PriceQuote: Double read FPriceQuote;
    property PointValue: Double read FPointValue;
    property Formation : integer read FFormation; // 표시진법

    property TickSize: Double read FTickSize;
    property Fraction: Integer read FFraction;
    property TickValue: Double read FTickValue;

    property Precision: Integer read FPrecision write FPrecision;
    property AdjustVal: double read  FAdjustVal write FAdjustVal;
    property ContractMonths[i:Integer]: Boolean read GetMonth write SetMonth;

    property TSizes : TTSizeDepths read FTSizes;
    property PriceCrt : TObject read FPriceCrt write FPriceCrt;

      // temporary
    property FlatATR: Double read FFlatATR;
    property SpreadATR: Double read FSpreadATR;
       //(later)
      // only dong bu
    property IsUpdate : boolean read FIsUpdate write FIsUpdate;
  end;

  TMarketSpecs = class(TCodedCollection)
  private
    FDefault: TMarketSpec;
    FFQNParser: TFQNParser;
    FSymbolParser: TSymbolParser;

    function GetSpec(i: Integer): TMarketSpec;
  public
    constructor Create;
    destructor Destroy; override;

    function New(stFQN: String): TMarketSpec;
    function Find(stFQN: String): TMarketSpec;
    function Find2(stPM: String): TMarketSpec;
      // temporary until find a good architecture
    function FindByUSSymbol(stSymbol: String): TMarketSpec;

    function Represent: String;

    property Specs[i: Integer]: TMarketSpec read GetSpec; default;
  end;

function GetPMItemName( stItem : string ) : string;
function GetPMItemMarket( stItem : string ) : string;

implementation

uses
  GleLib, GleConsts
  ;

{ TMarketSpec }

// 마켓 스펙 클래스
constructor TMarketSpec.Create(aColl: TCollection);
var
  i: Integer;
begin
  inherited Create(aColl);

  FViMarketName := '';

  FFQN := '*';

  FMarket := mtNotAssigned;
  FRootCode := 'Not Assigned';
  FDescription := 'Not Assigend';

  FCountry := 'Not Assigned';
  FExchange := 'Not Assigned';
  FSector := 'Not Assigned';
  FCurrency := 0;
  FSubMarket  := '*';

  FContractSize := 1;
  FPriceQuote := 1.0;
  FPointValue := 1.0;

  FTickSize := 1.0;
  FFraction := 1;
  FTickValue := 1.0;

  FPrecision := 0;
  //FSEctorID  := '';

  for i := 1 to 12 do
    FContractMonths[i] := False;

  FTSizes:= TTSizeDepths.Create;
  FPriceCrt  := nil;
  FIsUpdate  := false;
end;

destructor TMarketSpec.Destroy;
begin
  FTSizes.Free;
  inherited;
end;

function TMarketSpec.GetMarketType: char;
begin
  Result := ' ';
  case FMarket of
    mtStock : Result := 'S';
    mtFutures : Result := 'F';
    mtOption : Result := 'O';
    mtELW : Result := 'E';
  end;
end;

function TMarketSpec.GetMonth(i: Integer): Boolean;
begin
  if i in [1..12] then
    Result := FContractMonths[i]
  else
    Result := False;
end;

function TMarketSpec.NextPrice(dPrice: double; iSign: integer): double;
var
  i : integer;
  aD: TTSizeDepth;
begin
  Result := dPrice;

  if iSign > 0 then begin
    for I := FTSizes.Count - 1 downto 0 do
    begin
      aD  := FTSizes.Depths[i];
      if Result > aD.StartPrc - EPSILON then
      begin
        Result  := Result + aD.Size;
        break;
      end;
    end;
  end else
  begin
    for I := 0 to FTSizes.Count - 1 do
    begin
      aD  := FTSizes.Depths[i];
      if Result < aD.EndPrc + EPSILON then
      begin
        Result  := Result - aD.Size;
        break;
      end;
    end;
  end;

end;

procedure TMarketSpec.SetPoint(dContractSize, dPriceQuote: Double; iFormat : integer);
begin
  FContractSize := dContractSize;
  FPriceQuote := dPriceQuote;
  FPointValue := FContractSize * FPriceQuote;
  FFormation  := iFormat;
end;

procedure TMarketSpec.SetSector(stValue: string);
begin
  FSector := stValue;
end;

procedure TMarketSpec.SetTick(dTickSize: Double; iFraction,
  iPrecision: Integer);
begin
  FPrecision := iPrecision;
  FFraction := iFraction;

  if iFraction > 1 then
    FTickSize := 1.0 / FFraction
  else
    FTickSize := dTickSize;

  FTickValue := FTickSize * FPointValue;
end;



procedure TMarketSpec.SetTickDongBu(dTickSize, dAdjValue: Double);
var
  i : integer;
begin

  if dAdjValue = 0 then
    FAdjustVal := 1
  else
    FAdjustVal  := dAdjValue;

  FTickSize  := dTickSize / FAdjustVal;
  FTickValue := FTickSize * FPointValue;

  FPrecision  := GetPrecision( FTickSize );

end;

procedure TMarketSpec.SetTickValue(dTickValue: Double);
begin
  FTickValue  := dTickValue;
  if FTickSize = 0 then
    FPointValue := FTickValue
  else
    FPointValue := FTickValue / FTickSize;
  FIsUpdate   := true;
end;

procedure TMarketSpec.SetMarket(const Value: TMarketType);
begin
  FMarket := Value;
end;

procedure TMarketSpec.SetMonth(i: Integer; const Value: Boolean);
begin
  if i in [1..12] then
    FContractMonths[i] := Value;
end;

function TMarketSpec.Represent: String;
var
  i: Integer;
begin
  Result := Format('(%s,%s,%s,%s', [FFQN, FCountry, FExchange, MARKET_TYPE_DESC[FMarket]])
            + Format(',%s,%s,%s,%d', [FRootCode, FDescription, FSector, FCurrency])
            + Format(',%.0n,%.2f,%.2n', [FContractSize, FPriceQuote, FPointValue])
            + Format(',%.*f,%d,%.2f,', [FPrecision, FTickSize, FFraction, FTickValue]);
  for i := 1 to 12 do
    if FContractMonths[i] then
      Result := Result + '|' + SHORT_MONTHS[i];
  Result := Result + ')';
end;


{ TMarketSpecs }

constructor TMarketSpecs.Create;
begin
  inherited Create(TMarketSpec);

  FFQNParser := TFQNParser.Create;
  FSymbolParser := TSymbolParser.Create;

  FDefault := New('*.*.*');
  FDefault.FDescription := 'Default';
  FDefault.FUnderlying := '';
  FDefault.SetPoint(1, 1);
  FDefault.SetTick(0.01, 1, 2);


end;

destructor TMarketSpecs.Destroy;
begin
  FSymbolParser.Free;
  FFQNParser.Free;

  inherited;
end;

// 마켓 스펙을 생성한다. 
function TMarketSpecs.New(stFQN: String): TMarketSpec;
begin
  Result := Add(stFQN) as TMarketSpec;

  FFQNParser.FQN := stFQN;

  Result.FFQN := FFQNParser.MarketFQN;
  Result.FCountry := FFQNParser.Country;
  Result.FExchange := FFQNParser.Bourse;
  Result.FMarket := FFQNParser.MarketType;
  Result.FUnderlying := FFQNParser.Underlying;
  Result.FSubMarket  := FFQNParser.SubMarket;
end;

function TMarketSpecs.Find(stFQN: String): TMarketSpec;
var
  iPos: Integer;
begin
  stFQN := LowerCase(Trim(stFQN));

  iPos := FSortedList.IndexOf(stFQN);
  if iPos >= 0 then
    Result := SortedItems[iPos] as TMarketSpec
  else
    Result := nil;
end;

function TMarketSpecs.Find2(stPM: String): TMarketSpec;
var
  st : string;
  iPos, i : Integer;
  aSpec : TMarketSpec;
begin
  Result := nil;
  stPM := LowerCase(Trim(stPM));
  for i := 0 to Count - 1 do
  begin
    aSpec := GetSpec(i);
    iPos := Pos('.', aSpec.FFQN );
    st  := Copy( aSpec.FFQN, 1, iPos -1 );
    if (CompareStr(st, stPM ) = 0)  then
    begin
      Result := aSpec;
      Break;
    end;
  end;
end;

function TMarketSpecs.FindByUSSymbol(stSymbol: String): TMarketSpec;
var
  i, iPos: Integer;
  aSpec: TMarketSpec;
  aMarket: TMarketType;
begin
  Result := FDefault;

  iPos := Pos('-', stSymbol);
  if iPos > 0 then
    stSymbol := Copy(stSymbol, 1, iPos-1);

  if (FSymbolParser.ParseTradeStationSymbol(stSymbol))
     and (Length(FSymbolParser.Category) > 0) then
  begin
    case FSymbolParser.Category[1] of
      'E': aMarket := mtStock;
      'F': aMarket := mtFutures;
      'C','P': aMarket := mtOption;
      else
        aMarket := mtNotAssigned;
    end;

    case aMarket of
      mtStock:
        for i := 0 to Count - 1 do
        begin
          aSpec := GetSpec(i);
          if (CompareStr(aSpec.Country, COUNTRY_USA) = 0)
             and (aSpec.Market = mtStock) then
          begin
            Result := aSpec;
            Break;
          end;
        end;
      mtFutures, mtOption:
        for i := 0 to Count - 1 do
        begin
          aSpec := GetSpec(i);
          if (CompareStr(aSpec.RootCode, FSymbolParser.RootCode) = 0)
             and (aSpec.Market = aMarket) then
          begin
            Result := aSpec;
            Break;
          end;
        end;
    end;
  end;
end;

function TMarketSpecs.GetSpec(i: Integer): TMarketSpec;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := SortedItems[i] as TMarketSpec
  else
    Result := nil;
end;

function TMarketSpecs.Represent: String;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to Count - 1 do
    Result := Result + Format('%d:%s', [i, GetSpec(i).Represent]);
end;


function GetPMItemName( stItem : string ) : string;
var
  iTag : integer;
begin
  iTag  := StrToInt( stItem );

  case iTag of
   1 : Result := UNDER_CURRENCY;
   2 : Result := UNDER_INDEX;
   3 : Result := UNDER_BOND;
   4 : Result := UNDER_COMMODITY_ENERGY;
   5 : Result := UNDER_COMMODITY_METAL;
   6 : Result := UNDER_COMMODITY_FARM;
   7 : Result := UNDER_COMMODITY_LIVE;
   9 : Result := UNDER_COMMODITY_SOFT;
  end;
end;    

function GetPMItemMarket( stItem : string ) : string;
var
  iTag : integer;
begin
  iTag  := StrToInt( stItem );

  case iTag of
   1 : Result := 'Currency';
   2 : Result := 'Index';
   3 : Result := 'Bond';
   else  Result := 'Commodity';
  end;

end;

{ TTSizeDepths }

constructor TTSizeDepths.Create;
begin
  inherited Create( TTSizeDepth );
end;

function TTSizeDepths.GetDepth(i: Integer): TTSizeDepth;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TTSizeDepth
  else
    Result := nil;
end;

function TTSizeDepths.GetSize: Integer;
begin
  Result := Count;
end;

procedure TTSizeDepths.inc;
begin

end;

function TTSizeDepths.New: TTSizeDepth;
begin
  Result  := Add as TTSizeDepth;
end;

procedure TTSizeDepths.SetSize(const Value: Integer);
var
  i: Integer;
begin
  if Value > 0 then
    if Value > Count then
    begin
      for i := Count to Value-1 do Add;
    end else
    if Value < Count then
    begin
      for i := Count-1 downto Value do Items[i].Free;
    end;

end;

end.
