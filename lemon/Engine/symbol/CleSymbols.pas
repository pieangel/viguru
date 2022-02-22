unit CleSymbols;

interface

uses
  Classes, SysUtils, dialogs, CleAccounts,

  CleMarketSpecs, CleFQN;

type
  TSymbol = class;

  TSymbolFindEvent = function(stCode: String): TSymbol of object;

  TOptionType = (otNone, otCall, otPut);

  TQuoteMode = (qmLive, qmDelayed, qmOffline);
  TMarketStatus = (msNormal, msBreak, msReopen, msNotice, msClosed);

  TSymbol = class(TCollectionItem)
  private
    FIsStockF: Boolean;
    FIsMMProduct: boolean;
    FAccount: TAccount;
    FHogaSpread: Integer;
    FTickRatio: Double;

    FPrevLast: Double;

    FDoSubscribe: boolean;

    FTickDelta: double;
    FLpHogaSpread: string;
    FCanOrder: boolean;
    FOptionType: TOptionType;
    FUnderlyingType: TUnderlyingType;
    FQuote: TObject;
    FDelayMs: Integer;
    FDeliveryTime: TDateTime;
    FMinDeliveryTime: TDateTime;
    FSettleDays: integer;
    FCloseDays: integer;
    FSettleDate: TDateTime;

    FSeq : integer;
    FExpectPrice : double;
    FOpenSingle : double;
    FCloseSingle : double;
    FTradeSingle : double;
    FPrevHigh: Double;
    FPrevLow: Double;
    FListLow: double;
    FListHigh: double;
    FLinkCode: string;
    FPrevOpen: double;
    FFormation: integer;
    FMake1Min: boolean;

    FTabletHigh: Double;
    FTabletLow: Double;
    FRealLowerLimit: double;
    FRealUpperLimit: double;
    FChangeSign: integer;
    FChange: Double;
    FCntRatio: double;
    FNo: integer;
    FVolRatio: double;
    FShortDayCount: integer;
    FLongDayCount: integer;
    FShortDayVolume: integer;
    FLongDayVolume: integer;
    FFillCntRatio: double;
    FFillVolRatio: double;
    FPPrevHigh: Double;
    FPPrevLast: Double;
    FPPrevLow: Double;

    function GetShortCode: String;
  protected
      // identity
    FCode: String;
    FShortCode: String; // optional
    FSpec: TMarketSpec;
      // names
    FName: String;
    FShortName: String;
    FLongName: String;
    FEngName: String;
      // price info
    FPrevClose: Double;
    FBase: Double;      // settlement price on the previous trading day
    FDayOpen: Double;
    FDayHigh: Double;
    FDayLow: Double;
    FLast: Double;
      // daily price limit
    FLimitHigh: Double; // daily price limit high
    FLimitLow: Double;  // daily price limit low
    FCBHigh: Double;    // circuit break high
    FCBLow: Double;     // circuit break low

      //
    FTradable: Boolean;
    FMarketStatus: TMarketStatus;
  published // Only in Korea
  public
  {
    PrevH : array [0..1] of double;  // 0 : D-2, 1 : D-1
    PrevL : array [0..1] of double;
    PrevC : array [0..1] of double;
  }
      // identity
    constructor Create( aColl : TCollection ); override;
    Destructor Destroy ; override;
    function PriceToStr( dPrice : double ) : string;
    function GetPrice( iSide , iTick : integer ) : double;
    property Code: String read FCode;
    property ShortCode: String read GetShortCode write FShortCode;
    property Spec: TMarketSpec read FSpec write FSpec;

      // names
    property Name: String read FName write FName;
    property ShortName: String read FShortName write FShortName;
    property LongName: String read FLongName write FLongName;
    property EngName: String read FEngName write FEngName;
      // price info
    property Base: Double read FBase write FBase;
    property PrevClose: Double read FPrevClose write FPrevClose;
    property DayOpen: Double read FDayOpen write FDayOpen;
    property DayHigh: Double read FDayHigh write FDayHigh;
    property DayLow: Double read FDayLow write FDayLow;
    property Last: Double read FLast write FLast;
    property PrevLast : Double read FPrevLast write FPrevLast;
    property PrevHigh : Double read FPrevHigh write FPrevHigh;
    property PrevLow : Double read FPrevLow write FPrevLow;
    property PrevOpen: double read FPrevOpen write FPrevOpen;

      // 전전일  only  nh
    property PPrevLast : Double read FPPrevLast write FPPrevLast;
    property PPrevHigh : Double read FPPrevHigh write FPPrevHigh;
    property PPrevLow : Double read FPPrevLow write FPPrevLow;


    property Change: Double read FChange write FChange;
    property CntRatio: double read FCntRatio write FCntRatio;
    property VolRatio: double read FVolRatio write FVolRatio;
      // 월 최고 / 최저
    property ListHigh : double read FListHigh write FListHigh;
    property ListLow  : double read FListLow  write FListLow;
      // daily price limit
    property LimitHigh: Double read FLimitHigh write FLimitHigh;
    property LimitLow: Double read FLimitLow write FLimitLow;
      // tablet 고/저
    property TabletHigh: Double read FTabletHigh write FTabletHigh;
    property TabletLow: Double read FTabletLow write FTabletLow;
      // control
    property Tradable: Boolean read FTradable write FTradable;
    property MarketStatus: TMarketStatus read FMarketStatus write FMarketStatus;

      // 선물과 주식선물 구별 용도
    property IsStockF : Boolean read FIsStockF write FIsStockF default false;

    property LpHogaSpread : string read FLpHogaSpread write FLpHogaSpread ;
    property HogaSpread : Integer read FHogaSpread write FHogaSpread ;
    property TickRatio  : Double  read FTickRatio write FTickRatio;
    property TickDelta  : double read FTickDelta write FTickDelta;

      // 시세를 요청했는지 여부
    property DoSubscribe : boolean read FDoSubscribe write FDoSubscribe;

      // ubf propertys
    property CanOrder : boolean read FCanOrder write FCanOrder;
      // use china?
    property LinkCode : string read FLinkCode write FLinkCode;

    property OptionType : TOptionType read FOptionType write FOptionType;
    property UnderlyingType : TUnderlyingType read FUnderlyingType write FUnderlyingType;
    property Quote  : TObject read FQuote write FQuote;   //
    property DelayMS : Integer read FDelayMs write FDelayMs;
    property DeliveryTime : TDateTime read FDeliveryTime write FDeliveryTime;
    property MinDeliveryTime : TDateTime  read FMinDeliveryTime write FMinDeliveryTime;

    property CloseDays : integer read FCloseDays write FCloseDays;   // 만기일까지
    property SettleDays : integer read FSettleDays write FSettleDays; // 배당일까지
    property SettleDate : TDateTime read FSettleDate write FSettleDate;

    property No  : integer read FNo write FNo;
    property Seq : integer read FSeq write FSeq;
    property ExpectPrice : double read FExpectPrice write FExpectPrice;
    property OpenSingle : double read FOpenSingle write FOpenSingle;
    property CloseSingle : double read FCloseSingle write FCloseSingle;
    property TradeSingle : double read FTradeSingle write FTradeSingle;

    property Make1Min : boolean read FMake1Min write FMake1Min;
    property RealUpperLimit : double read FRealUpperLimit write FRealUpperLimit;
    property RealLowerLimit : double read FRealLowerLimit write FRealLowerLimit;

    // 통계용 자료
    property ShortDayVolume : integer read FShortDayVolume write FShortDayVolume;
    property LongDayVolume : integer read FLongDayVolume write FLongDayVolume;
    property ShortDayCount : integer read FShortDayCount write FShortDayCount;
    property LongDayCount : integer read FLongDayCount   write FLongDayCount;
    property FillCntRatio : double read FFillCntRatio    write FFillCntRatio;
    property FillVolRatio : double read FFillVolRatio    write FFillVolRatio;


  end;

  TSymbols = class(TCollection)
  protected
  public
    function Find(stCode: String): TSymbol;
  end;

  TSymbolList = class(TStringList)
  private
    function GetSymbol(i: Integer): TSymbol;

  public
    constructor Create;

    function FindCode(stCode: String): TSymbol;
    function FindCode2( stCode : string ) : TSymbol;
    function FindLinkCode(stLinkCode: string): TSymbol;
    function FindFrmSeq( iSeq : integer ) : TSymbol;

    procedure AddSymbol(aSymbol: TSymbol);
    procedure GetList(aList: TStrings); overload;

    procedure GetList(aList: TStrings; aMarket : TMarketType ); overload;
    procedure GetList2(aList: TStrings; aMarket: TMarketType);
    procedure GetLists2( aList : TSTrings; aMarkets : TMarketTypes );
    procedure GetLists( aList : TSTrings; aMarkets : TMarketTypes );
    procedure GetListCallPut( aList : TSTrings; aMarket : TMarketType; stType : string );
    property Symbols[i:Integer]: TSymbol read GetSymbol; default;
  end;

  TSymbolCache = class(TSymbolList)
  public
    constructor Create;
    procedure AddSymbol(aSymbol: TSymbol);
  end;

    // derivative basis class

  TDerivative = class(TSymbol)
  private
    FIsNextStep: Boolean;
    FIsSettleWeek: boolean;
    FDiscretDividend: Double;
    FUnderCode: String;
    procedure SetExpDate(const Value: TDateTime);
  protected
      // underlying
    FUnderlying: TSymbol; // this is optional
      // expiration info
    FDaysToExp: Integer; // days to expiration
    FExpDate: TDateTime; // expiration date
    FExpMonth: Integer;  // 1(Jan)~12(Dec)
    FExpYear: Integer;   // expiration month
      // open interest
    FPrevOI: LongInt; // open interest on the previous trading day
    FOI: LongInt;     // open interest for today
      // market reference info -- is this right location
    FDividendRate: Double; // stock dividend rate
    FCDRate: Double;       // CD rate -- needed for option pricing model
      // misc
    FIsTopStep: Boolean;
    FProductID: String; // Korea only
  public
    function GetNextStepSymbolCode : string;
      // underlyng
    property Underlying: TSymbol read FUnderlying write FUnderlying;
      // api..
    property UnderCode: String read FUnderCode write FUnderCode;
      // expiration info
    property DaysToExp: Integer read FDaysToExp write FDaysToExp;
    property ExpDate: TDateTime read FExpDate write SetExpDate;
    property ExpMonth: Integer read FExpMonth;
    property ExpYear: Integer read FExpYear;
      // open interest info
    property PrevOI: LongInt read FPrevOI write FPrevOI;
    property OI: LongInt read FOI write FOI;
      // market reference info
    property DividendRate: Double read FDividendRate write FDividendRate;
    property CDRate: Double read FCDRate write FCDRate;
      // top step?
    property IsTopStep: Boolean read FIsTopStep write FIsTopStep;
    property IsNextStep : Boolean read FIsNextStep write FIsNextStep;
    property ProductID: String read FProductID write FProductID;

    property IsSettleWeek : boolean read FIsSettleWeek write FIsSettleWeek;
    property DiscretDividend: Double read FDiscretDividend write FDiscretDividend;
  end;

    // "Index"

  TIndex = class(TSymbol);
  TIndexes = class(TSymbols)
  private
    function GetIndex(i: Integer): TIndex;
  public
    constructor Create;
    function New(stCode: String): TIndex;
    property Indexes[i:Integer]:TIndex read GetIndex; default;
  end;
         {
  TDollar = class( TSymbol );
  TDollars = class( TSymbols )
  private
    function GetDollar(i: Integer): TDollar;
  public
    constructor Create;
    function New(stCode: String): TDollar;
    property Dollar[i:Integer]:TDollar read GetDollar; default;
  end;

  TYen = class( TSymbol );
  TYens = class( TSymbols )
  private
    function GetYen(i: Integer): TYen;
  public
    constructor Create;
    function New(stCode: String): TYen;
    property Yen[i:Integer]:TYen read GetYen; default;
  end;
         }

    // "stock"

  TStock = class(TSymbol)
  private
    FListedShares: Double;
    FTradeUnit: Integer;
      // only in Korea
    FStockType: String;
    FSectorKOSPI200: String;
    FSectorKOSPI100: String;
    FSectorKRX100: String;
    FSeqNo: String;
    FDividendRate: Double;
    FDividendPrice: Double;

  public
    property ListedShares: Double read FListedShares write FListedShares;
    property TradeUnit: Integer read FTradeUnit write FTradeUnit;
    property DividendRate: Double read FDividendRate write FDividendRate;
    property DividendPrice: Double read FDividendPrice write FDividendPrice;
      // only in Korea
    property StockType: String read FStockType write FStockType;
    property SectorKOSPI200: String read FSectorKOSPI200 write FSectorKOSPI200;
    property SectorKOSPI100: String read FSectorKOSPI100 write FSectorKOSPI200;
    property SectorKRX100: String read FSectorKRX100 write FSectorKRX100;
    property SeqNo: String read FSeqNo write FSeqNo;
  end;

  TStocks = class(TSymbols)
  private
    function GetStock(i: Integer): TStock;
  public
    constructor Create;
    function New(stCode: String): TStock;
    property Stocks[i:Integer]: TStock read GetStock; default;
  end;

    // "futures"

  TFuture = class(TDerivative);

  TFutures = class(TSymbols)
  private
    function GetFuture(i: Integer): TFuture;
  public
    constructor Create;
    function New(stCode: String): TFuture;
    property Futures[i:Integer]: TFuture read GetFuture; default;
  end;

    // "option"

  TKrxOptionGreeks = record
    Delta : double;
    Theta : double;
    Vega  : double;
    Gamma : double;
    Rho   : double;
  end;

  TOption = class(TDerivative)
  private
    FCallPut: Char; // 'C', 'P'
    FStrikeCode: String;
    FStrikePrice: Double;
    FIV: Double;
    FDelta: Double;
    FGamma: Double;
    FTheta: Double;
    FVega: Double;
    FRho : Double;

    FIsATM: Boolean;
    FThPrice: double;
    FRelativeHigh: double;
    FRelativeLow: double;
  public
    KrxGreeks: TKrxOptionGreeks;
    property CallPut: Char read FCallPut write FCallPut; // 'C', 'P'
    property StrikeCode: String read FStrikeCode write FStrikeCode;
    property StrikePrice: Double read FStrikePrice write FStrikePrice;
    property IV: Double read FIV write FIV;
    property Delta: Double read FDelta write FDelta;
    property Gamma: Double read FGamma write FGamma;
    property Theta: Double read FTheta write FTheta;
    property Vega: Double read FVega write FVega;
    property Rho: Double read FRho write FRho;
    property ThPrice: double read FThPrice write FThPrice;

    property IsATM: Boolean read FIsATM write FIsATM;
      // 상대행사가 최고/ 최저
    property RelativeHigh : double read FRelativeHigh write FRelativeHigh;
    property RelativeLow : double read FRelativeLow write FRelativeLow;
  end;

  TOptions = class(TSymbols)
  private
    function GetOption(i: Integer): TOption;
  public
    constructor Create;
    function New(stCode: String): TOption;
    property Options[i:Integer]: TOption read GetOption;
  end;

    // "spread"
  TSpread = class(TDerivative)
  private
    FFrontMonth: String;
    FBackMonth: String;
  public
    property FrontMonth: String read FFrontMonth write FFrontMonth;
    property BackMonth: String read FBackMonth write FBackMonth;
  end;

  TSpreads = class(TSymbols)
  private
    function GetSpread(i: Integer): TSpread;
  public
    constructor Create;
    function New(stCode: String): TSpread;
    property Spreads[i:Integer]: TSpread read GetSpread;
  end;

    //
  TETF = class(TSymbol);
  TBond = class(TSymbol);
  TCurrency = class(TSymbol);
  TCommodity = class( TSymbol );


  TBonds = class(TSymbols)
  private
    function GetBond(i: Integer): TBond;
  public
    constructor Create;
    function New(stCode: String): TBond;
    property Bonds[i:Integer]: TBond read GetBond;
  end;

  TCurrencies = class(TSymbols)
  private
    function GetCurrency(i: Integer): TCurrency;
  public
    constructor Create;
    function New(stCode: String): TCurrency;
    property Currencies[i:Integer]: TCurrency read GetCurrency;
  end;

  TCommodities = class(TSymbols)
  private
    function GetCommodity(i: Integer): TCommodity;
  public
    constructor Create;
    function New(stCode: String): TCommodity;
    property Commodities[i:Integer]: TCommodity read GetCommodity;
  end;


  TLp = class( TCollectionItem )
  public
    LpCode : string;
    LpName : string;
    LpIndex: integer;
    EnAble : boolean;
  end;

  TLps = class( TCollection )
  private
    function GetLp(i: Integer): TLp;
  public
    constructor Create;
    function New( LpCode, LpName: String): TLp;
    property Lps[i:Integer]: TLp read GetLp; default;
    function CheckLp( LpCode : string) : boolean;
    procedure GetLpList(aList: TStrings);
    function Find( LpCode : string ) : TLp;
  end;


    // ELW
  TELW = class(TOption)
  private
    FIssuer: String;      //
    FConvRatio: Double;   //
    FLPTradable: String; //
    FLPPosition: Double; //
    FLPCode: String;      //
    FESTime: TDateTime;   //
      // stock info
    FListedShares: Double;
    FTradeUnit: Integer;
      // only in Korea
    FStockType: String;
    FSectorKOSPI200: String;
    FSectorKOSPI100: String;
    FSectorKRX100: String;
    FSeqNo: String;

    //GI
    FParity : Double;     //패리티
    FGearing : Double;    //기어링비율
    FPremium : Double;    //손익분기율
    FCFP : Double;        //자본지지점

    FTheory : Double;     //이론가
    FDelta : Double;      //델타
    FGamma : Double;      //감마
    FTheta : Double;      //세타
    FVega : Double;       //베가
    FLow : Double;        //로우
    FIV : Double;         //내재변동성
    FLPGravity : Double;  //LP비중

  public
    property Issuer: String read FIssuer write FIssuer;
    property ConvRatio: Double read FConvRatio write FConvRatio;
    property LPTradable: String read FLPTradable write FLPTradable;
    property LPPosition: Double read FLPPosition write FLPPosition;
    property LPCode: String read FLPCode write FLPCode;
    property ESTime: TDateTime read FESTime write FESTime;
      // stock info
    property ListedShares: Double read FListedShares write FListedShares;
    property TradeUnit: Integer read FTradeUnit write FTradeUnit;
      // only in Korea
    property StockType: String read FStockType write FStockType;
    property SectorKOSPI200: String read FSectorKOSPI200 write FSectorKOSPI200;
    property SectorKOSPI100: String read FSectorKOSPI100 write FSectorKOSPI200;
    property SectorKRX100: String read FSectorKRX100 write FSectorKRX100;
    property SeqNo: String read FSeqNo write FSeqNo;
    // GI
    property Parity: Double read FParity write FParity;
    property Gearing: Double read FGearing write FGearing;
    property Premium: Double read FPremium write FPremium;
    property CFP: Double read FCFP write FCFP;
    property Theory: Double read FTheory write FTheory;
    property Delta: Double read FDelta write FDelta;
    property Gamma: Double read FGamma write FGamma;
    property Theta: Double read FTheta write FTheta;
    property Vega: Double read FVega write FVega;
    property Low: Double read FLow write FLow;
    property IV: Double read FIV write FIV;
    property LPGravity: Double read FLPGravity write FLPGravity;
  end;

  TELWs = class(TSymbols)
  private
    function GetELW(i: Integer): TELW;
  public
    constructor Create;
    function New(stCode: String): TELW;
    property ELWs[i:Integer]: TELW read GetELW;
  end;

implementation

uses
  GAppEnv;

//---------------------------------------------------------------< base >

{ TSymbols }

function TSymbols.Find(stCode: String): TSymbol;
var
  i: Integer;
begin
  Result := nil;
  
  for i := 0 to Count - 1 do
    if CompareStr((Items[i] as TSymbol).Code, stCode) = 0 then
    begin
      Result := Items[i] as TSymbol;
      Break;
    end;
end;

{ TSymbolList }

constructor TSymbolList.Create;
begin
  inherited Create;

  Sorted := True;
end;

procedure TSymbolList.AddSymbol(aSymbol: TSymbol);
begin
  AddObject(aSymbol.Code, aSymbol);
end;

function TSymbolList.FindCode(stCode: String): TSymbol;
begin
  Result := GetSymbol(IndexOf(stCode));
end;

function TSymbolList.FindCode2(stCode: string): TSymbol;
var i : integer;
begin
  Result := nil;
  if stCode = '' then Exit;

  for i := 0 to Count - 1 do
    if CompareStr(GetSymbol(i).ShortCode, stCode) = 0 then
    begin
      Result := Objects[i] as TSymbol;
      Break;
    end;
end;

function TSymbolList.FindFrmSeq(iSeq: integer): TSymbol;
var i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if GetSymbol(i).Seq = iSeq then
    begin
      Result := Objects[i] as TSymbol;
      Break;
    end;

end;

function TSymbolList.FindLinkCode(stLinkCode: string): TSymbol;
var i : integer;
begin
  Result := nil;
  if stLinkCode = '' then Exit;

  for i := 0 to Count - 1 do
    if CompareStr(GetSymbol(i).LinkCode, stLinkCode) = 0 then
    begin
      Result := Objects[i] as TSymbol;
      Break;
    end;
end;

procedure TSymbolList.GetList(aList: TStrings);
var
  i: Integer;
  aSymbol: TSymbol;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aSymbol := GetSymbol(i);
    aList.AddObject(aSymbol.ShortCode, aSymbol);
  end;
end;

procedure TSymbolList.GetList(aList: TStrings; aMarket: TMarketType);
var
  i: Integer;
  aSymbol: TSymbol;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aSymbol := GetSymbol(i);
    if aSymbol.Spec.Market = aMarket then
      aList.AddObject(aSymbol.ShortCode, aSymbol);
  end;

end;

procedure TSymbolList.GetList2(aList: TStrings; aMarket: TMarketType);
var
  i: Integer;
  aSymbol: TSymbol;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aSymbol := GetSymbol(i);
    if aSymbol.Spec.Market = aMarket then
      aList.AddObject(aSymbol.Name, aSymbol);
  end;

end;

procedure TSymbolList.GetListCallPut(aList: TSTrings; aMarket: TMarketType;
  stType: string);
var
  i: Integer;
  aSymbol: TSymbol;
begin
  if aList = nil then Exit;
  for i := 0 to Count - 1 do
  begin
    aSymbol := GetSymbol(i);
    if (aSymbol.Spec.Market = aMarket) and ((aSymbol as TOption).CallPut = stType)then
      aList.AddObject(aSymbol.ShortCode, aSymbol);
  end;
end;

procedure TSymbolList.GetLists(aList: TSTrings; aMarkets: TMarketTypes);
var
  i : integer;
  aSymbol : TSymbol;
begin
  if aList = nil  then Exit;

  for i := 0 to Count - 1 do
  begin
    aSymbol := GetSymbol(i);
    if aSymbol.Spec.Market in aMarkets then
      aList.AddObject( aSymbol.ShortCode, aSymbol);
  end;
end;

procedure TSymbolList.GetLists2(aList: TSTrings; aMarkets: TMarketTypes);
var
  i : integer;
  aSymbol : TSymbol;
begin
  if aList = nil  then Exit;

  for i := 0 to Count - 1 do
  begin
    aSymbol := GetSymbol(i);
    if aSymbol.Spec.Market in aMarkets then
      aList.AddObject( aSymbol.Name, aSymbol);
  end;

end;

function TSymbolList.GetSymbol(i: Integer): TSymbol;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TSymbol(Objects[i])
  else
    Result := nil;
end;

{ TSymbolCache }

constructor TSymbolCache.Create;
begin
   inherited Create;

   Sorted := False;
end;

procedure TSymbolCache.AddSymbol(aSymbol: TSymbol);
var
  iP : Integer;
begin
  if aSymbol = nil then Exit;
  //
  iP := IndexOfObject(aSymbol);
  if iP > 0 then
    Move(iP, 0)
  else
  if IP < 0 then
    InsertObject(0, aSymbol.Name, aSymbol);
end;


//---------------------------------------------------------------< derivative >

{ TDerivative }

function TDerivative.GetNextStepSymbolCode: string;
var bNextYear : boolean;
  cYear : char;
begin
  if Code[1] = '4'  then Exit;

  Result := Copy( Code, 1, 3);
  bNextYear := true;
  if ExpMonth in [3,6,9] then bNextYear := false;

  if not bNextYear then begin
    if ExpMonth = 9 then
      Result := Copy( Code,1, 4 ) +'C'
    else Result := Copy( Code,1, 4 ) + IntToStr( ExpMonth + 3);
  end
  else begin
    cYear  := Code[4];
    Result := Format('%s%s%s', [ Copy(Code,1,3), Char(word(cYear) + 1), IntToStr(3)]);
  end;

end;

procedure TDerivative.SetExpDate(const Value: TDateTime);
var
  wYear, wMonth, wDay: Word;
begin
  FExpDate := Value;

  DecodeDate(Value, wYear, wMonth, wDay);

  FExpMonth := wMonth;
  FExpYear := wYear;
end;

//---------------------------------------------------------------< index >

{ TIndexes }

constructor TIndexes.Create;
begin
  inherited Create(TIndex);
end;

function TIndexes.GetIndex(i: Integer): TIndex;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TIndex
  else
    Result := nil;
end;

function TIndexes.New(stCode: String): TIndex;
begin
  Result := Add as TIndex;
  Result.FCode := stCode;
end;

//---------------------------------------------------------------< stock >

{ TStocks }

constructor TStocks.Create;
begin
  inherited Create(TStock)
end;

function TStocks.GetStock(i: Integer): TStock;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TStock
  else
    Result := nil;
end;

function TStocks.New(stCode: String): TStock;
begin
  Result := Add as TStock;
  Result.FCode := stCode;
end;

//---------------------------------------------------------------< futures >

{ TFutures }

constructor TFutures.Create;
begin
  inherited Create(TFuture);
end;

function TFutures.GetFuture(i: Integer): TFuture;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TFuture
  else
    Result := nil;
end;

function TFutures.New(stCode: String): TFuture;
begin
  Result := Add as TFuture;
  Result.FCode := stCode;
end;

//---------------------------------------------------------------< option >

{ TOptions }

constructor TOptions.Create;
begin
  inherited Create(TOption);
end;

function TOptions.GetOption(i: Integer): TOption;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOption
  else
    Result := nil;
end;

function TOptions.New(stCode: String): TOption;
begin
  Result := Add as TOption;

  Result.FCode := stCode;
end;

//---------------------------------------------------------------< spread >

{ TSpreads }

constructor TSpreads.Create;
begin
  inherited Create(TSpread);
end;

function TSpreads.GetSpread(i: Integer): TSpread;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSpread
  else
    Result := nil;
end;

function TSpreads.New(stCode: String): TSpread;
begin
  Result := Add as TSpread;

  Result.FCode := stCode;
end;

//----------------------------------------------------------------------< ELW >

{ TELWs }

constructor TELWs.Create;
begin
  inherited Create(TELW);
end;

function TELWs.GetELW(i: Integer): TELW;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TELW
  else
    Result := nil;
end;

function TELWs.New(stCode: String): TELW;
begin
  Result := Add as TELW;

  Result.FCode := stCode;
end;


{ TSymbol }

constructor TSymbol.Create( aColl : TCollection );
begin
  inherited Create( aColl );

  FDelayMs  := 0;
  FMinDeliveryTime := 3;
  FDeliveryTime := 0;
  DoSubscribe   := false;
  FMake1Min := false;

  FShortDayCount  := 0;
  FLongDayCount   := 0;
  FShortDayVolume := 0;
  FLongDayVolume  := 0;

  FIsStockF := false;

end;

destructor TSymbol.Destroy;
begin

  inherited;
end;


function TSymbol.GetPrice(iSide, iTick: integer): double;
begin
  // 상대호가..


end;

function TSymbol.GetShortCode: String;
begin
  if gEnv.PacketVer = pv0 then
    Result := Code
  else
    Result := FShortCode;
end;

function TSymbol.PriceToStr(dPrice: double): string;
begin
  Result := Format('%.*n', [ Spec.Precision, dPrice + 0.0 ] );
end;

{ TLps }

constructor TLps.Create;
begin    
  inherited Create( TLp );
end;

function TLps.Find(LpCode: string): TLp;
var
  aLp : TLp;
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aLp := GetLp(i);
    if aLp.LpCode = LpCode then
    begin
      Result := aLp;
      break;
    end;
  end;

end;

function TLps.GetLp(i: Integer): TLp;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TLp
  else
    Result := nil;
end;

function TLps.New(LpCode, LpName: String): TLp;
begin
  Result := nil;

  Result := Add as TLp;
  Result.LpCode := LpCode;
  Result.LpName := LpName;
  Result.Index  := Count-1;
  Result.EnAble := false;

end;

function TLps.CheckLp(LpCode: string): boolean;
var
  aLp : TLp;
  i: Integer;
begin
  Result := true;
  for i := 0 to Count - 1 do
  begin
    aLp := GetLp(i);
    if aLp.LpCode = LpCode then
    begin
      aLp.EnAble  := true;
      Result := false;
      break;
    end;
  end;
end;

procedure TLps.GetLpList(aList: TStrings);
var
  i: Integer;
begin
  if aList = nil then Exit;
  for i := 0 to Count - 1 do begin
    if not Lps[i].EnAble then
      Continue;
    aList.AddObject(Lps[i].LpName, Lps[i]);
  end;
end;

{ TBonds }

constructor TBonds.Create;
begin
  inherited Create(TBond);
end;

function TBonds.GetBond(i: Integer): TBond;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TBond
  else
    Result := nil;
end;

function TBonds.New(stCode: String): TBond;
begin
  Result := Add as TBond;        
  Result.FCode := stCode;
end;

{ TDollars }

  {
constructor TDollars.Create;
begin
  inherited Create(TDollar);
end;

function TDollars.GetDollar(i: Integer): TDollar;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TDollar
  else
    Result := nil;
end;

function TDollars.New(stCode: String): TDollar;
begin
  Result := Add as TDollar;
  Result.FCode := stCode;
end;
   }


{ TCurrencys }

constructor TCurrencies.Create;
begin
  inherited Create(TCurrency);
end;

function TCurrencies.GetCurrency(i: Integer): TCurrency;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TCurrency
  else
    Result := nil;
end;

function TCurrencies.New(stCode: String): TCurrency;
begin
  Result := Add as TCurrency;
  Result.FCode := stCode;
end;

{ TCommodiitys }

constructor TCommodities.Create;
begin
  inherited Create(TCommodity);
end;

function TCommodities.GetCommodity(i: Integer): TCommodity;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TCommodity
  else
    Result := nil;
end;

function TCommodities.New(stCode: String): TCommodity;
begin
  Result := Add as TCommodity;
  Result.FCode := stCode;
end;

end.
