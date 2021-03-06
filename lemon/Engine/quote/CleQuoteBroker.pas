unit CleQuoteBroker;

interface

uses
  Classes, SysUtils, DateUtils,

  GleTypes, CleCollections, CleCircularQueue,
  CleSymbols, CleDistributor, CleQuoteTimers, Ticks,   CleOrders, ClePriceItems

  ;

type
  TQuote = class;

  TQuoteType = (qtNone, qtMarketDepth, qtTimeNSale, qtCustom, qtUnknown);

  TQuoteEvent = function(aQuote: TQuote) : boolean of object;

  TSymbolFindEvent = function(stCode: String): TSymbol of object;

    // [Market Depth] data classes
    // 'TMarketDepths' represents only one side among 'bid' and 'ask' quotes.

  TMarketDepth = class(TCollectionItem)
  private
    FPrice: Double;   // order price
    FVolume: int64; // number of contracts
    FCnt: Integer;
    FLpVolume: int64;    // number of orders
  public
    property Price: Double read FPrice write FPrice;
    property Volume: int64 read FVolume write FVolume;
    property Cnt: Integer read FCnt write FCnt;
    property LpVolume : int64 read FLpVolume write FLpVolume;
  end;

  TMarketDepths = class(TCollection)
  private
    FVolumeTotal: int64;
    FCntTotal: Integer;
    FRealTimeAvg: double;
    FRealCount: integer;
    FRealVolSum: integer;

    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
    function GetDepth(i: Integer): TMarketDepth;
  public
    constructor Create;

    property VolumeTotal: int64 read FVolumeTotal write FVolumeTotal;
    property CntTotal: Integer read FCntTotal write FCntTotal;

    property RealTimeAvg : double read FRealTimeAvg write FRealTimeAvg;
    property RealVolSum  : integer read FRealVolSum write FRealVolSum;
    property RealCount : integer read FRealCount write FRealCount;
    property Size: Integer read GetSize write SetSize;
    property Depths[i:Integer]: TMarketDepth read GetDepth; default;
  end;



  TTimeNSale = class(TCollectionItem)
  private
      // required
    FPrice: Double;
    FVolume: int64;
    FTime: TDateTime;
      // optional I
    FSide: Integer;  // 1=long, -1=short
      // Korea only
    FDailyVolume: int64;
    FDailyAmount: Currency;
    FContinueFill: boolean;
    FLocalTime: TDateTime;
    FTick : TTickItem;
    FPrevPrice: Double;
    FContinueFillQty: int64;
    FDistTime: string;
  public
    property Price: Double read FPrice write FPrice;
    property PrevPrice : Double read FPrevPrice write FPrevPrice;
    property Volume: int64 read FVolume write FVolume;
    property Time: TDateTime read FTime write FTime;
    property LocalTime : TDateTime read FLocalTime write FLocalTime;
    property DistTime : string read FDistTime write FDistTime;
    property Side: Integer read FSide write FSide;
      //
    property DayVolume: int64 read FDailyVolume write FDailyVolume;
    property DayAmount: Currency read FDailyAmount write FDailyAmount;

    property ContinueFill : boolean read FContinueFill write FContinueFill;
    property ContinueFillQty : int64 read FContinueFillQty write FContinueFillQty;
    property Tick : TTickItem read FTick write FTick;
  end;

  TTimeNSales = class(TCollection)
  private
    FLast: TTimeNSale;
    FPrev: TTimeNSale;
    FMaxCount: Integer;
    function GetSale(i: Integer): TTimeNSale;
  public
    constructor Create;

    function New: TTimeNSale;

    property Prev: TTimeNSale read FPrev;
    property Last: TTimeNSale read FLast;
    property MaxCount: Integer read FMaxCount write FMaxCount;
    property Sales[i:Integer]: TTimeNSale read GetSale; default;

  end;


    // Quote distribution class
    // An obeject of 'TQuote' is assigned to every symbol which quote has been
    // subscribed to at least one client.


  TQuote = class(TCollectionItem)
  private
      // data objects
    FAsks: TMarketDepths;
    FBids: TMarketDepths;
    FSales: TTimeNSales;

      // distributing objects
    FDistributor: TDistributor;

      // identity
    FSymbolCode: String;
    FSymbol: TSymbol;

      // daily price info
    FOpen: Double;
    FHigh: Double;
    FLow: Double;
    FLast: Double;
    FChange: Double; // price change from yesterday close

      // daily trading info
    FDailyVolume: int64;    // accumulated daily filled volume
    FDailyAmount: Currency;   // accumulated daily trade amount
    FOpenInterest: LongInt; // open interest

      // last status
    FEventCount: Integer;
    FLastEvent: TQuoteType;
    FCustomEventID: Integer;
    FLastEventTime: TDateTime; // time keeping as local PC time
    FLastQuoteTime: TDateTime; // ????..
    FLastFillTime : TDateTime; // ????..

      // for comparison
    FLastSale: TTimeNSale;

      // event
    FOnUpdate: TNotifyEvent;

      // Korea only
    FEstFillPrice: Double;  // Estimated fill price
    FEstFillQty: Double;
    FGreeksSubscribed: Boolean;
    FFillSubscribed: Boolean;
    FHogaSubscribed: Boolean;
    FLogList: TStringList;


    FPrevBids: TMarketDepths;
    FPrevAsks: TMarketDepths;

    FAvgPrice: double;
    FPriceAxis: TPriceAxis;
    FPrevEvent: TQuoteType;
    FContinueFill: boolean;


    FExtracteOrderCnt : integer;
    FForceDistCnt     : integer;
    FOwnOrderTraceCnt : integer;
    FExtracteOrder: boolean;

    FLastData: TOrderData;
    FOwnOrderTrace: boolean;

    FAtoB: Integer;

    FPrvIndicator: Double;
    FCurIndicator: Double;
    FAclCalcSec: integer;
    FResetAclFill: boolean;
    FAccumulFill: boolean;
    FCumulSale: TCircularQueue;

    FRecovered: boolean;
    FTerms: TSTerms;
    FMakeTerm: boolean;
    FAddTerm: boolean;

    FQuoteList: TList;
    FCalcedPrevHL: boolean;
    FChangeSign: integer;
    FCntRatio: double;
    FLowChl: double;
    FHighChl: double;
    FVolRatio: double;

    procedure SetSymbol(const Value: TSymbol);
    procedure SaveContinueFills;
    procedure MakePriceAxis;

    procedure CalcRealTimeAvg;
    procedure CalcCntRatio;
    procedure CalcVolRatio;

  public

    OrderCount : integer;
    FTicks : TCollection;
    QuoteTime : string;
    MarketState : string;
    SAR : double;

    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    procedure Update(dtQuote: TDateTime; atype : integer = 0);
    procedure UpdatePv0(dtQuote : TDateTime );
    procedure UpdateCustom(dtQuote: TDateTime);
    procedure UpdateChart(iVal : integer );

    procedure CalceATRValue;
    procedure CalcePrevATR;
      // data objects
    property Asks: TMarketDepths read FAsks;
    property Bids: TMarketDepths read FBids;
    property Sales: TTimeNSales read FSales;
    property Terms: TSTerms read FTerms;
    property QuoteList : TList read FQuoteList;
    property CntRatio  : double read FCntRatio;
    property VolRatio  : double read FVolRatio;

    property AvgPrice   : double  read FAvgPrice Write FAvgPrice;

      // identity
    property SymbolCode: String read FSymbolCode ;
    property Symbol: TSymbol read FSymbol write SetSymbol;

    property Distributor: TDistributor read FDistributor;

      // symbol daily price info
    property Open: Double read FOpen write FOpen;
    property High: Double read FHigh write FHigh;
    property Low: Double read FLow write FLow;
    property Last: Double read FLast write FLast;
    property Change: Double read FChange write FChange;
      // symbol daily trading info
    property DailyVolume: int64 read FDailyVolume write FDailyVolume;
    property DailyAmount: Currency read FDailyAmount write FDailyAmount;
    property OpenInterest: LongInt read FOpenInterest write FOpenInterest;

      // quote status
    property EventCount: Integer read FEventCount;
    property LastEvent: TQuoteType read FLastEvent write FLastEvent;
    property PrevEvent: TQuoteType read FPrevEvent;
    property CustomEventID: Integer read FCustomEventID;
    property LastEventTime: TDateTime read FLastEventTime write FLastEventTime;
    property LastQuoteTime: TDateTime read FLastQuoteTime write FLastQuoteTime;
      // Korea only
    property EstFillPrice: Double read FEstFillPrice write FEstFillPrice;
    property EstFillQty: Double read FEstFillQty write FEstFillQty;
      // only  us stg
    property HighChl : double read FHighChl write FHighChl;
    property LowChl  : double read FLowChl write FLowChl;

      // Elw only
    procedure CalcHogaSpread;

    function GetTickSize( dPrice : double ) : integer;
    procedure Delivery(iType: Integer);

    property HogaSubscribed : Boolean read FHogaSubscribed write FHogaSubscribed default false;
    property FillSubscribed : Boolean read FFillSubscribed write FFillSubscribed default false;
    property GreeksSubscribed : Boolean read FGreeksSubscribed write FGreeksSubscribed default false;

      // ????????
    property PriceAxis  : TPriceAxis  read FPriceAxis write FPriceAxis;
    property LastData : TOrderData  read FLastData  write FLastData;
    property PrevAsks: TMarketDepths read FPrevAsks;
    property PrevBids: TMarketDepths read FPrevBids;
    property ContinueFill : boolean read FContinueFill;

    property Recovered: boolean read FRecovered write FRecovered;
      // ????????
    property ResetAclFill : boolean read FResetAclFill write FResetAclFill;
    property AccumulFill  : boolean read FAccumulFill write FAccumulFill;
    property AclCalcSec   : integer read FAclCalcSec write FAclCalcSec;
    property CumulSale  : TCircularQueue read FCumulSale write FCumulSale;
    property MakeTerm   : boolean read FMakeTerm write FMakeTerm;
    property AddTerm    : boolean read FAddTerm  write FAddTerm;
      //  kr api ???????? ????????..
    property CalcedPrevHL : boolean read FCalcedPrevHL write FCalcedPrevHL;
      //
      // loging
    procedure AddLog( stLog : string ) ;

      // ???? ????
    procedure SavePrevMarketDepths; overload;
    procedure SavePrevMarketDepths( bFill, bContinue : boolean); overload;
    function AnalysizeHoga: boolean;
    function AnalysizeFill( bContinueFill : boolean = false ) : boolean; overload;
    function AnalysizeFill2 : boolean; overload;
    procedure A3FillProc ;

    function ExtracteQuoteOrder( aQType : TQuoteOrderType;
          iDiffVol, iDiffCnt, iSide : integer ) : boolean;
    function ExtracteQuoteModifyOrder : boolean;
    function ExtracteFillOrder( aFType : TFillOrderType; aDepths, aDepths2,aPrevDepths, aPrevDepths2 : TMarketDepths;
            bTarget : boolean; index, iQty : integer) : boolean;

    function FindChangeHoga( var ivar : integer; iDiffVol, iDiffCnt: integer;
          aDepths, aPrevDepths : TMarketDepths ) : boolean;
    function FindNewNDisappearHoga( var ivar : integer; iDiffVol, iDiffCnt: integer;
          aDepths, aPrevDepths : TMarketDepths ) : boolean;
    function FindModifyHogas( aQType : TQuoteOrderType; aDepths, aPrevDepths : TMarketDepths; iSide : integer ) : boolean;


    procedure MakeQuoteOrderData( aQType : TQuoteOrderType; price : double;
      qty , side, index : integer; bGone : boolean = false );
    procedure MakeQuoteModifyOrderData( aQType : TQuoteOrderType; price, price2 : double;
      qty , side, index1, index2 : integer; bGone : boolean = false);
    procedure MakeFillOrderData( aFType : TFillOrderType; price, price2 : double;
          iQty , iSide , index1, index2: integer; bModify, bContinue : boolean );

    function GetCumulFill( stPrice : string ; iSide : integer ) : integer;
    procedure GetTermVolNCnt( var  lv, sv, lc , sc : array of integer;
          stPrice: string; iSide,ims : integer; aTime : TDateTime );
    //
    procedure OnTermAddEvent( Sender : TObject );
    //
    function PrcToStr( dPrice : double ) : string;
    function GetHitPrice( iSide, iTick : integer ) : double;
    procedure SaveAccumulVolume;
  end;

    // main class
    // The QuoteBorker works in both ways
    // 1. just with code(string)
    // 2. with code AND TSymbol object
  TQuoteBroker = class(TCodedCollection)
  private
      // utility objects
    FQuoteTimers: TQuoteTimers;

      // events
    FOnSubscribe: TQuoteEvent;
    FOnCancel: TQuoteEvent;
    FOnFind: TSymbolFindEvent;

      // time stamp
    FLastEventTime: TDateTime;  // PC time, real-time
    FLastQuoteTime: TDateTime;  
    FSortList: TList;
     // data(server) time, near real-time or historical
    procedure QuoteUpdated(Sender: TObject);

  public
    QuoteIndex  : integer;
    // log
    FQuote  : TQuote;
    constructor Create;
    destructor Destroy; override;

    function Subscribe(aSubscriber: TObject; aSymbol: TSymbol; aHandler: TDistributorEvent;
      bMakeTerm : boolean; spType : TSubscribePriority = sphighest): TQuote; overload;
    function Subscribe(aSubscriber: TObject; stSymbol: String; aHandler: TDistributorEvent): TQuote; overload;
    ///
    function Subscribe(aSubscriber: TObject; aSymbol: TSymbol;  iDataID : integer; aHandler: TDistributorEvent; spType : TSubscribePriority = sphighest): TQuote; overload;
    function Subscribe(aSubscriber: TObject; aSymbol: TSymbol;  aHandler: TDistributorEvent; spType : TSubscribePriority = sphighest): TQuote; overload;

    function Subscribe(aSubscriber: TObject; aSymbol: TSymbol;
      aHandler: TDistributorEvent; EvnetID: TDistributorIDs; spType : TSubscribePriority = sphighest): TQuote; overload;


    function Find(stSymbol: String): TQuote;
    function Find2(stSymbol : string ) : TQuote;

    procedure Cancel(aSubscriber: TObject; stSymbol: String); overload;
    procedure Cancel(aSubscriber: TObject; aSymbol: TSymbol); overload;
    procedure Cancel(aSubscriber: TObject); overload;
    procedure Cancel(aSubscriber: TObject; bSymbolCore : boolean); overload;

    procedure Delivery( iType : integer );

      // refresh symbol references
    procedure RefreshSymbols;

      // quote broker main events
    property OnSubscribe: TQuoteEvent read FOnSubscribe write FOnSubscribe;
    property OnCancel: TQuoteEvent read FOnCancel write FOnCancel;
    property OnFind: TSymbolFindEvent read FOnFind write FOnFind;

      // quote timer related
    property Timers: TQuoteTimers read FQuoteTimers;
    property LastQuoteTime: TDateTime read FLastQuoteTime;
    property LastEventTime: TDateTime read FLastEventTime;
      // log
      // Elw

    procedure DummyEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);


    function SubscribeTest(aSubscriber: TObject; aSymbol: TSymbol;
      aHandler: TDistributorEvent; iTrCode : integer): TQuote; overload;

    function GetSubscribeCount: integer;
    function GetQuoted(iPos: integer): TQuote;

      // Counting
    procedure ResetDelayTime;


  end;

function SortAcs(Item1, Item2: Pointer): Integer;

implementation

uses CleFQN,
  GAppEnv, GleLib, CleKrxSymbols, MMSystem, Math, GleConsts
   ;

//============================================================================//

{ TMarketDepths }


constructor TMarketDepths.Create;
begin
  inherited Create(TMarketDepth);
  FRealCount  := 0;
end;

function TMarketDepths.GetDepth(i: Integer): TMarketDepth;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TMarketDepth
  else
    Result := nil;
end;

function TMarketDepths.GetSize: Integer;
begin
  Result := Count;
end;

procedure TMarketDepths.SetSize(const Value: Integer);
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

//============================================================================//

{ TTimeNSales }

constructor TTimeNSales.Create;
begin
  inherited Create(TTimeNSale);

  FPrev := nil;
  FLast := nil;
  FMaxCount := 0;
end;

function TTimeNSales.GetSale(i: Integer): TTimeNSale;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TTimeNSale
  else
    Result := nil;
end;

function TTimeNSales.New: TTimeNSale;
begin
    // limit size
  if (FMaxCount > 0) and (Count >= FMaxCount) then
    Items[Count-1].Free;

    // insert new object
  Result := Insert(0) as TTimeNSale;

  with Result do
  begin
    FVolume := 0;
    FSide := 0; // not assigned
    FContinueFill := false;
  end;

    // store
  FPrev := FLast;
  FLast := Result;
end;

//============================================================================//

{ TQuote }
function TQuote.GetCumulFill( stPrice : string ; iSide : integer ): integer;
var
  iRes, iGap, i : integer;
  aItem : TQueueItem;
  aSale : TTimeNSale;
  aNow  : TDateTime;
  stLog , stDsc : string;
begin
  Result := 0;
  aNow   := GetQuoteTime;
  iGap   := 0;

  for i := 0 to Sales.Count - 1 do
  begin
    aSale := Sales.Sales[i];
    if aSale = nil then Continue;

    stDsc := Format('%.2f', [ aSale.Price ]);
    iGap  := GetMSBetween( aNow, aSale.LocalTime );
    if iGap > FAclCalcSec  then
      break;

    iRes  := CompareStr( stPrice, stDsc );
    if (iRes = 0) and ( iSide = aSale.Side ) then
      Result := Result + abs( aSale.Volume );
  end;

end;

function TQuote.GetHitPrice(iSide, iTick: integer): double;
begin

  Result := 0;

  if ( FAsks[0].Price < EPSILON ) or ( FBids[0].Price < EPSILON ) then
    Exit;  

  if iSide > 0 then
    Result := TicksFromPrice( FSymbol, FAsks[0].Price, iTick )
  else
    Result := TicksFromPrice( FSymbol, FBids[0].Price, -iTick );
end;

function TQuote.PrcToStr(dPrice: double): string;
begin
  Result := Format('%.*n', [ FSymbol.Spec.Precision, dPrice + 0.0 ] );
end;

procedure TQuote.GetTermVolNCnt( var  lv, sv, lc , sc : array of integer;
  stPrice: string; iSide, ims : integer ; aTime : TDateTime);
var
  iRes, i, idx, iGap : integer;
  aSale : TTimeNSale;
  stDsc : string;
begin

  //stPrice := Format('%.2f', [ Sales.Last.Price ] );
  //iSide   := Sales.Last.Side ;

  for i := 0 to Sales.Count - 1 do
  begin

    aSale := Sales.Sales[i];
    if aTime > aSale.Time then break;
    if (aSale = nil) or ( aSale.Side <> iSide ) then Continue;

    stDsc := Format('%.2f', [ aSale.Price ]);
    iGap  := GetMSBetween( Sales.Last.FTime, aSale.FTime );

    if (iGap <= ims) then
    begin
      iRes  := CompareStr( stPrice, stDsc );
      idx := 0;
    end else
    if ( iGap > ims) and ( iGap <= (ims*2))  then
    begin
      iRes  := CompareStr( stPrice, stDsc );
      idx := 1;
    end
    else
      break;

    if (iRes = 0)  then
      if iSide > 0 then
      begin
        inc( lv[idx], aSale.Volume );
        inc( lc[idx], 1 );
      end else
      begin
        inc( sv[idx], aSale.Volume );
        inc( sc[idx], 1 );
      end;
  end;

end;



function TQuote.GetTickSize( dPrice : double ) : integer;
  const EPSILON    = 0.00000001;
begin
  if dPrice > 500000.0 - EPSILON then
    Result := 1000
  else if dPrice > 100000 - EPSILON then
    Result := 500
  else if dPrice > 50000 - EPSILON then
    Result := 100
  else if dPrice > 10000 - EPSILON then
    Result := 50
  else if dPrice > 5000 - EPSILON then
    Result := 10
  else
    Result := 5;
end;

procedure TQuote.A3FillProc;
var
  iQty, i : integer;
  aDepths, aDepths2, aPrevDepths, aPrevDepths2 : TMarketDepths;
  bRes : boolean;
begin
  iQty := 0;
  for i := 0 to FSales.Count - 1 do
  begin
    if not FSales[i].ContinueFill then break;
    FSales[i].ContinueFill  := false;
    iQty  := iQty + FSales[i].Volume;
  end;

  if FSales[0].Side = -1 then begin
    aDepths := Asks;        // ???? ????
    aDepths2 := Bids;       // ??????
    aPrevDepths := FPrevAsks;     // ???? ????
    aPrevDepths2 := FPrevBids;    // ??????
  end
  else begin
    aDepths := Bids;
    aDepths2 := Asks;
    aPrevDepths := FPrevBids;
    aPrevDepths2 := FPrevAsks;
  end;

  bRes  := ExtracteFillOrder( ftSame, aDepths, aDepths2, aPrevDepths,
     aPrevDepths2, false, i, iQty );

  FContinueFill := false;

end;

procedure TQuote.AddLog(stLog: string);
var
  iPos : integer;
begin
  iPos := FLogList.IndexOf( stLog );
  if iPos < 0 then
    FLogList.Add( stLog );
end;

procedure TQuote.SavePrevMarketDepths(bFill, bContinue : boolean);
var iPos, i : integer;
    fItem, aItem : TPriceItem;
    dPrice, dGap, bidPrice : double;

    procedure GetAccumulFillVol;
    var
      iGap : integer;
     // stLog: string;
     // dTmp : TDateTime;
    begin
      if AclCalcSec <= 0 then
        Exit;

      iGap  := MilliSecondsBetween( FSales[0].LocalTime,  aItem.StartTime );
      //dTmp  := aItem.StartTime;

      if iGap > AclCalcSec then
      begin
        aItem.StartTime := FSales[0].LocalTime;
        aItem.AccumulVol:= FSales[0].Volume;
      end
      else begin
        inc( aItem.AccumulVol, FSales[0].Volume );
      end;
      {
      stLog := Format('%s|%s|%s|%s| %d:%d:%d ',
        [
          aItem.PriceDesc,
          FormatDateTime( 'hh:nn:ss.zzz', dTmp),
          FormatDateTime( 'hh:nn:ss.zzz', aItem.StartTime),
          FormatDateTime( 'hh:nn:ss.zzz', FSales[0].FTime),
          iGap,
          FSales[0].Volume,
          aItem.AccumulVol
        ]);
      gEnv.EnvLog( WIN_LOG, stLog);
      }
    end;
begin

  if bContinue then
  begin
    if bFill then
    begin
      aItem := FPriceAxis.Find( FSales[0].Price );
      if aItem <> nil then
        aItem.Clear;
    end;
    Exit;
  end ;


  if bFill then
  begin
    fItem := FPriceAxis.Find( FSales[0].Price );
    if fItem <> nil then
    begin
      fItem.AddFill( FSales.Last.FPrice, FSales.Last.Side,FSales.Last.Volume ,
        FSales.Last.DistTime );
    end;
  end;

  try
    for i := 0 to Asks.GetSize - 1 do
    begin

      if Asks[i].Price >= Fsymbol.LimitLow then
      begin
        aItem := FPriceAxis.Find( Asks[i].Price );
        if aItem <> nil then begin
          //if ( bFill ) and ( fItem = aItem ) then Continue;
          aItem.SetItemValue( i, -1, Asks[i].Volume, Asks[i].Cnt, QuoteTime );
          aItem.DelayMs := FSymbol.DelayMS;
        end;
      end;

      if Bids[i].Price >= FSymbol.LimitLow then
      begin
        aItem := FPriceAxis.Find( Bids[i].Price );
        if aItem <> nil then
        begin
          //if ( bFill ) and ( fItem = aItem ) then Continue;
          aItem.SetItemValue( i, 1, Bids[i].Volume, Bids[i].Cnt, QuoteTime );
          aItem.DelayMs := FSymbol.DelayMS;
        end;
      end;
    end;

  except
  end;

  dPrice  := Bids[0].Price;
  while true do
  begin
    if dPrice < FSymbol.LimitLow then
      break;
    dPrice := TicksFromPrice(FSymbol, dPrice , 1);
    if dPrice > Asks[0].Price - PRICE_EPSILON then Break;
    aItem := FPriceAxis.Find( dPrice );
    if aItem = nil then break;
    aItem.Clear;
  end;
end;

function TQuote.AnalysizeFill2: boolean;
var
  Price : double;
  iSumH, iSumV, iPrSumH, iPrSumV :Integer;
  iSumH2, iSumV2, iPrSumH2, iPrSumV2 :Integer;
  i, j, Side, Volume, iQty: integer;
  aDepths, aDepths2, aPrevDepths, aPrevDepths2 : TMarketDepths;
  bFind : boolean;
  stTmp, stPrice : string;
  aFType : TFillOrderType;
  bContinue : boolean;
begin

  bContinue := false;
  bFind := false;
  Price := FSales[0].FPrice;
  Volume:= FSales[0].Volume;

  if FSales[0].Side = -1 then begin
    aDepths := Asks;        // ???? ????
    aDepths2 := Bids;       // ??????
    aPrevDepths := FPrevAsks;     // ???? ????
    aPrevDepths2 := FPrevBids;    // ??????
  end
  else begin
    aDepths := Bids;
    aDepths2 := Asks;
    aPrevDepths := FPrevBids;
    aPrevDepths2 := FPrevAsks;
  end;

  // ???? ????..
  for i := 0 to aDepths2.GetSize - 1 do
  begin
    if aDepths2[i].Price = Price then
    begin
      bFind := true;
      break;
    end;
  end;

  if bFind then
  begin
    if (aDepths2[i].FPrice = aPrevDepths2[i].FPrice) and
       (aDepths2[i].Volume = aPrevDepths2[i].Volume) and
       (aDepths2[i].Cnt = aPrevDepths2[i].Cnt) then
    begin
      FContinueFill := true;
      FSales[0].ContinueFill  := true;
      //Log( result );
      Exit;
    end;
  end;

  // ???????? ( ???? ?????? )
  iSumH :=0; iSumV:=0; iPrSumH:=0; iPrSumV:=0;
  for i := 0 to aDepths.GetSize - 1 do
  begin
    iSumV   := iSumV + aDepths[i].Volume;
    iSumH   := iSumH + Round(aDepths[i].Price * 100 );
    iPrSumH := iPrSumH + Round(aPrevDepths[i].Price * 100 );
    iPrSumV := iPrSumV + aPrevDepths[i].Volume;
  end;

  // ??????
  iSumH2 :=0; iSumV2:=0; iPrSumH2:=0; iPrSumV2:=0;
  for i := 0 to aDepths2.GetSize - 1 do
  begin
    iSumV2    := iSumV2 + aDepths2[i].Volume;
    iSumH2    := iSumH2 + Round(aDepths2[i].Price * 100 );
    iPrSumH2  := iPrSumH2 + Round(aPrevDepths2[i].Price * 100 );
    iPrSumV2  := iPrSumV2 + aPrevDepths2[i].Volume;
  end;

  // ???? ???? little, more, same
  if ( iPrSumH2 = iSumH2 )  and ( iPrSumH = iSumH ) then
    aFType := ftLittle
  else if ( iPrSumH2 = iSumH2 ) and ( iPrSumH <> iSumH ) then
    aFType := ftLittleC
  else if ( iPrSumH2 <> iSumH2 )  and ( iPrSumH <> iSumH ) then
     aFType := ftMore
  else if ( iPrSumH2 <> iSumH2 )  and ( iPrSumH = iSumH ) then
    aFType := ftSame
  else
    Exit;


  if FContinueFill then
  begin
    iQty := 0;
    for i := 1 to FSales.Count - 1 do
    begin
      if not FSales[i].ContinueFill then break;
      iQty  := iQty + FSales[i].Volume;
    end;
    FContinueFill := false;
    Volume := Volume + iQty;
    bContinue := true;
  end;

  result  := ExtracteFillOrder( aFType, aDepths, aDepths2, aPrevDepths, aPrevDepths2, bContinue, i, Volume );

end;

function TQuote.AnalysizeHoga: boolean;
var
  iSDiffVol, iSDiffCnt, iLDiffVol, iLDiffCnt : integer;
  bFind, bFind2, bNo : boolean;
  aQType : TQuoteOrderType;


  i : integer;
  stLog : string;

  function GetQuoteOrderType : TQuoteOrderType;
  begin
    Result := NONE;
    if (iSDiffVol+iSDiffCnt+iLDiffVol+iLDiffCnt) = 0 then
      Result := All
    else if ((iSDiffVol <> 0) or ( iSDiffCnt <> 0)) and ((iLDiffVol+iLDiffCnt) = 0) then
    begin
      // ???? ????
      if (iSDiffVol > 0) and ( iSDiffCnt > 0) then
        Result := SN
      else if (iSDiffVol < 0) and ( iSDiffCnt < 0) then
        Result := SC
      else if (iSDiffVol < 0) and ( iSDiffCnt = 0) then
        Result := SPC
      else if (iSDiffVol = 0) and ( iSDiffCnt > 0) then
        Result := SPM;
    end
    else if ((iLDiffVol <> 0) or ( iLDiffCnt <> 0)) and ((iSDiffVol+iSDiffCnt) = 0) then
    begin
      // ???? ????
      if (iLDiffVol > 0) and ( iLDiffCnt > 0) then
        Result := LN
      else if (iLDiffVol < 0) and ( iLDiffCnt < 0) then
        Result := LC
      else if (iLDiffVol < 0) and ( iLDiffCnt = 0) then
        Result := LPC
      else if (iLDiffVol = 0) and ( iLDiffCnt > 0) then
        Result := LPM;
    end;
  end;
begin

  if FContinueFill then
  begin
    A3FillProc;
    Exit;
  end;

  Result := false;

  bFind := false;
  bfind2:= false;
  bNo := false;

  iSDiffVol := FAsks.FVolumeTotal - FPrevAsks.FVolumeTotal;
  iSDiffCnt := FAsks.FCntTotal -    FPrevAsks.FCntTotal;

  iLDiffVol := FBids.FVolumeTotal - FPrevBids.FVolumeTotal;
  iLDiffCnt := FBids.FCntTotal -    FPrevBids.FCntTotal;

  aQType  :=  GetQuoteOrderType;

  if aQType = none then
    Exit;

  case aQType of
    NONE: Exit;
    SN, SC, SPC: bFind  := ExtracteQuoteOrder( aQType, iSDiffVol, iSDiffCnt, -1) ;
    LN, LC, LPC: bFind  := ExtracteQuoteOrder( aQType, iLDiffVol, iLDiffCnt, 1) ;
    SPM: bFind := FindModifyHogas( aQType, FAsks, FPrevAsks, -1 );
    LPM: bFind := FindModifyHogas( aQType, FBids, FPrevBids, 1 );
    All: bFind := ExtracteQuoteModifyOrder;
  end;

  Result := bFind;
  if (aQType = All) and (not bFind) then
    bFind := false;

  Result := bFind;

end;



function TQuote.ExtracteQuoteModifyOrder : boolean;
var
  bRes : boolean;
begin
  bRes := FindModifyHogas( All, FBids, FPrevBids, 1 );
  if not bRes then
    bRes := FindModifyHogas( All, FAsks, FPrevAsks, -1 );
  Result := bRes;
end;

function TQuote.ExtracteQuoteOrder(aQType : TQuoteOrderType; iDiffVol, iDiffCnt, iSide: integer): boolean;
var
  iSumH, iSumV, iPrSumH, iPrSumV, i, j, iGapVol, iGapCnt  : integer;
  aDepths, aPrevDepths : TMarketDepths;

  bGone, bFind : boolean;
  dPrice: double;
  iQty  : integer;

begin

  case iSide of
    1 :
      begin
        aDepths := FBids;
        aPrevDepths := FPrevBids;
      end;
    -1:
      begin
        aDepths := FAsks;
        aPrevDepths := FPrevAsks;
      end;
  end;

  iSumH :=0; iSumV:=0; iPrSumH:=0; iPrSumV:=0;

  for i := 0 to aDepths.GetSize - 1 do
  begin
    iSumV := iSumV + aDepths[i].Volume;
    iSumH := iSumH + Round(aDepths[i].Price * 100 );
    iPrSumH := iPrSumH + Round(aPrevDepths[i].Price * 100 );
    iPrSumV := iPrSumV + aPrevDepths[i].Volume;
  end;

  //. 1 ???????? ???? ????, ????, ???? ????
  //. 2 ???? ???? ?????? ??????. ( ???????? ???? ???? )
  //. 3 ???? ???? ?????? ?????? ???????? , ?????? ???? , ?????? ???? ??????. ( ????, ???????? )
  //. 4 ?????????? ??????, ?????? ???? ?? ???????? ????
  //. 5 ?????? price, qty ?? ???? ?????? ??????????
  i := 0;
  bFind := false;
  bGone := false;

  if iPrSumV <> iSumV then
  begin
    if iPrSumH <> iSumH then begin
      if aQType in [SN, LN] then
      begin
        //  ???????? ????
        bFind   := FindNewNDisappearHoga( i, iDiffVol, iDiffCnt, aDepths, aPrevDepths );

        if bFind then
        begin
          dPrice  := aDepths[i].Price;
          iQty  := iDiffVol
        end;
      end else
      if aQType in [SC, LC] then
      begin
          //  ?????? ????
        bFind := FindNewNDisappearHoga( i, iDiffVol, iDiffCnt, aPrevDepths, aDepths );
        if bFind then
        begin
          dPrice  := aPrevDepths[i].Price;
          iQty  := abs( iDiffVol );
          bGone := true;
        end;

      end;
      Result := bFind;

    end
    else begin
      Result := FindChangeHoga( i, iDiffVol, iDiffCnt, aDepths, aPrevDepths );
      if Result then
      begin
        dPrice  := aDepths[i].Price;
        iQty  := abs( iDiffVol );
      end;
    end;

    if Result then
      MakeQuoteOrderData( aQType, dPrice, iQty, iSide, i, bGone );

  end else
  if iPrSumV = iSumV then
    Result := false;

end;


function TQuote.FindChangeHoga( var ivar : integer; iDiffVol, iDiffCnt: integer;
  aDepths, aPrevDepths : TMarketDepths): boolean;
  var
    i, iGapVol, iGapCnt : integer;
begin
  Result := false;
  for i := 0  to aDepths.GetSize - 1 do begin
    iGapVol := aDepths[i].Volume - aPrevDepths[i].Volume;
    iGapCnt := aDepths[i].Cnt - aPrevDepths[i].Cnt;
    if (iGapVol = iDiffVol) and ( iGapCnt = iDiffCnt) then
    begin
      ivar := i;
      Result := true;
      break;
    end;
  end;
end;

function TQuote.FindModifyHogas(aQType : TQuoteOrderType; aDepths,
      aPrevDepths: TMarketDepths; iSide : integer): boolean;
var
  iSumH, iSumV, iPrSumH, iPrSumV :Integer;
  index1, index2, i, j, k, iGapVol, iGapCnt, iQty, iCount  : integer;
  bNew ,bFind, bDisap, bSame, bGone : boolean;
  iDec, iInc, iDisappear, iNew : integer;
  dPrice, dPrice2 : double;
begin
  Result := false;

  iSumH :=0; iSumV:=0; iPrSumH:=0; iPrSumV:=0;
  for i := 0 to FBids.GetSize - 1 do
  begin
    iSumV := iSumV + aDepths[i].Volume;
    iSumH := iSumH + Round(aDepths[i].Price * 100 );
    iPrSumH := iPrSumH + Round(aPrevDepths[i].Price * 100 );
    iPrSumV := iPrSumV + aPrevDepths[i].Volume;
  end;

  iDec := -1;  iInc := -1;
  iDisappear := -1; iNew := -1;
  i :=0; j:=0; k := 0; iGapVol := 0; iCount := 0;
  bGone := false;

  bFind := false;
  dPrice := 0;  dPrice2 := 0;

  //. 1 ???????? ?????????? ???????? ???? ????
  if (iSumH <> iPrSumH) then
  begin

    while (k < (aDepths.GetSize * 2 -1))  do
    begin
      if aDepths[i].Price = aPrevDepths[j].Price then
      begin
        iGapVol := aDepths[i].Volume - aPrevDepths[j].Volume ;
        if iGapVol > 0 then begin
          iInc := i;
          iCount := iGapVol;
        end
        else if iGapVol < 0 then begin
          iCount := iGapVol;
          iDec := i;
        end;

        if i < aDepths.GetSize-1 then
          inc(i);
        if j < aPrevDepths.GetSize-1 then
          inc(j);
        inc(k);
      end
      else if aDepths[i].Price > aPrevDepths[j].Price then
      begin
        if iSide = -1 then
        begin
          // disappear j th. hoag
          if iDisappear < 0 then
            iDisappear := j;
          if j < aPrevDepths.GetSize-1 then
            inc(j);
          iCount := aPrevDepths[j].Volume;
        end
        else begin
          // new i th. hoga
          if iNew < 0 then
            iNew := i;
          if i < aDepths.GetSize-1 then
            inc(i);
          iCount := aDepths[j].Volume;
        end;
      end
      else begin
        if iSide = -1 then
        begin
          // new i th. hoga
          if iNew < 0 then
            iNew := i;
          if i < aDepths.GetSize-1 then
            inc(i);
          iCount := aDepths[j].Volume;
        end
        else begin
          // disappear j th. hoag
          if iDisappear < 0 then
            iDisappear := j;
          if j < aPrevDepths.GetSize-1 then
            inc(j);
          iCount := aPrevDepths[j].Volume;
        end;
      end;
      inc(k);
    end;

    if (iInc>=0) or (iDec>=0) or ( iNew >= 0) or ( iDisappear >= 0) then
    begin
      bFind := true;

      if (iDisappear >= 0) then begin
        dPrice  := aPrevDepths[iDisappear].Price;
        index1  := iDisappear;
      end
      else if iDec >=0 then begin
        dPrice  := aDepths[iDec].Price;
        index1  := iDec;
      end;

      if iNew >= 0 then begin
        dPrice2  := aDepths[iNew].Price;
        index2   := iNew;
      end
      else if iInc >= 0 then begin
        dPrice2  := aDepths[iInc].Price;
        index2   := iInc;
      end;

      MakeQuoteModifyOrderData( aQType, dPrice, dPrice2, iCount, iSide, index1, index2, iDisappear >= 0 );

    end;
  end else
  // ???????? ????..
  begin
    for i := 0 to aDepths.GetSize - 1 do begin
      iGapVol := aDepths[i].Volume - aPrevDepths[i].Volume;
      iGapCnt := aDepths[i].Cnt    - aPrevDepths[i].Cnt;
      if (iGapVol > 0) {and ( iGapCnt > 0)} then
      begin
        iInc := i;
        iCount  := iGapVol;
        if (iDec >=0) then break;
      end else
      if (iGapVol < 0) {and ( iGapCnt < 0) }then
      begin
        iDec := i;
        iCount  := iGapVol;
        if (iInc >=0) then break;
      end;
    end;

    if (iInc>=0) or (iDec>=0) then
    begin
      bFind := true;

      if iDec>=0 then
        dPrice  := aDepths[iDec].Price;
      if iInc>=0 then
        dPrice2 := aDepths[iInc].Price;

      MakeQuoteModifyOrderData( aQType, dPrice, dPrice2, iCount, iSide, iDec, iInc );
    end;
  end;

  Result := bFind;

end;

function TQuote.FindNewNDisappearHoga(var ivar : integer; iDiffVol, iDiffCnt: integer;
  aDepths, aPrevDepths: TMarketDepths): boolean;
  var
    i, j : integer;
    bSame : boolean;
    stDesc, stSrc : string;
begin
  Result:= false;
  for i := 0 to aDepths.GetSize - 1 do begin
    bSame := false;
    Result:= false;
    stDesc  := Format('%.*n', [ FSymbol.Spec.Precision, aDepths[i].Price ]);
    for j := 0 to aDepths.GetSize - 1 do begin
      stSrc := Format('%.*n', [ FSymbol.Spec.Precision, aPrevDepths[j].Price ]);
      if (CompareStr( stDesc, stSrc ) = 0) then
      begin
        bSame := true;
        break;
      end;
    end; //  for j

    if not bSame then begin
      // ?????? ????  & ?????? ????
      ivar := i;
      Result := true;
      break;
    end;
  end;

end;


procedure TQuote.SaveAccumulVolume;
begin
  with FSymbol do
  begin
    if FSales.Last <> nil then
      if FSales.Last.Side > 0 then
      begin
        LongDayCount  := LongDayCount + 1;
        LongDayVolume := LongDayVolume + FSales.Last.Volume ;
      end else
      begin
        ShortDayCount := ShortDayCount + 1;
        ShortDayVolume:= ShortDayVolume + FSales.Last.Volume ;
      end;

    if ( LongDayCount > 0 ) and ( ShortDayCount > 0 ) then
    begin
      if LongDayCount > ShortDayCount then
        FillCntRatio := ShortDayCount / LongDayCount
      else if LongDayCount < ShortDayCount then
        FillCntRatio := LongDayCount / ShortDayCount * -1
      else
        FillCntRatio := 1;
    end else FillCntRatio := 1;

    if ( LongDayVolume > 0 ) and ( ShortDayVolume > 0 ) then
    begin
      if LongDayVolume > ShortDayVolume then
        FillVolRatio := ShortDayVolume / LongDayVolume
      else if LongDayVolume < ShortDayVolume then
        FillVolRatio := LongDayVolume / ShortDayVolume * -1
      else
        FillVolRatio := 1;
    end else FillVolRatio := 1;
  end;

end;

procedure TQuote.SaveContinueFills;
begin
  FContinueFill := true;
  FSales[0].ContinueFill  := true;
end;


procedure TQuote.SavePrevMarketDepths;
var
  i : integer;
begin

  for i := 0 to Asks.GetSize - 1 do
  begin
    FPrevAsks[i].Price  := Asks[i].Price;
    FPrevAsks[i].Cnt    := Asks[i].Cnt;
    FPrevAsks[i].Volume := Asks[i].Volume;

    FPrevBids[i].Price  := Bids[i].Price;
    FPrevBids[i].Cnt    := Bids[i].Cnt;
    FPrevBids[i].Volume := Bids[i].Volume;
  end;

  FPrevAsks.FVolumeTotal  := Asks.FVolumeTotal;
  FPrevAsks.FCntTotal     := Asks.FCntTotal;

  FPrevBids.FVolumeTotal  := Bids.FVolumeTotal;
  FPrevBids.FCntTotal     := Bids.FCntTotal;
end;

procedure TQuote.MakeFillOrderData(aFType : TFillOrderType; price, price2: double; iQty, iSide , index1, index2: integer;
  bModify, bContinue : boolean);
  var
    aData : TOrderData;
    stWhat : string;
begin

  //iSide := iSide * -1;
  aData := (FPriceAxis.OrderList.Insert(0) as TOrderData );

  aData.FType  := aFType;
  aData.QType   := FL;
  aData.dPrice  := price;
  aData.dPrice2 := price2;

  aData.No   := index1 + 1;
  aData.No2  := index2 + 1;

  if aData.No = 0 then
    aData.No := 9;

  aData.Time  := FLastEventTime;
  aData.Name  := ifThenStr( bModify, 'Modify', 'New');
  aData.Price := ifThenStr( bModify,
                 Format('%.*n -> %.*n', [ Symbol.Spec.Precision, Price, Symbol.Spec.Precision, Price2]),
                 Format('%.*n', [ Symbol.Spec.Precision, Price2 ])
                 );
  aData.Qty   := IntToStr( abs(iQty) );
  aData.Side  := IfThenStr( iSide = 1,'L',  ifThenStr( iSide =0,'X', 'S'));

  if bContinue then
    aData.FillQty := IntToStr( FSales[0].ContinueFillQty )
  else
    aData.FillQty := IntToStr( FSales[0].Volume );

  aData.ContinueFill := bContinue;
  {
  if gEnv.RunMode = rtRealTrading then
    if FPriceAxis.OrderList.Count > 3000 then
      FPriceAxis.OrderList.Delete(FPriceAxis.OrderList.Count-1);
  }
  FLastData   := aData;

end;

function TQuote.ExtracteFillOrder(aFType : TFillOrderType; aDepths, aDepths2, aPrevDepths, aPrevDepths2: TMarketDepths;
  bTarget: boolean; index, iQty: integer): boolean;
  var
    iFind, iDec, i, j, k, iGapVol, iSide, iDiffvol, index2 : integer;
    bModify : boolean;
    dPrice : double;
begin
  iDiffVol := aDepths.FVolumeTotal - aPrevDepths.FVolumeTotal;
  bModify := iDiffVol < 0;
  result := false;
  iDec := -1;
  iFind := -1;

  for i := 0 to aPrevDepths2.GetSize - 1 do
    if aPrevDepths2[i].Price = FSales[0].Price then
      break;
  index2 := i;


  // ???? ???? ???? ???? ???? - ?????? ?????? ???? ????
  if aFType = ftMore then
  begin

    //if FSales[0].Volume = iQty then
      for i := 0 to aDepths.GetSize - 1 do
        if aDepths[i].Price = FSales[0].Price then
        begin
          iQty := iQty{FSales[0].Volume} + aDepths[i].Volume;
          break;
        end;

    // ????????????
    if bModify then
    begin
        i := 0; j := 0; k:= 0;
        //-------------
        while (k < (aDepths.GetSize * 2 -1))  do
        begin
          if j = index then begin
            inc( k );
            if j < aPrevDepths.GetSize-1 then
              inc( j );
            Continue;
          end;

          if aDepths[i].Price = aPrevDepths[j].Price then
          begin
            iGapVol := aDepths[i].Volume - aPrevDepths[j].Volume ;
            if iGapVol < 0 then begin
              iFind := 1;
              iDec := i;
              break;
            end;

            if i < aDepths.GetSize-1 then
              inc(i);
            if j < aPrevDepths.GetSize-1 then
              inc(j);
            inc(k);
          end
          else if aDepths[i].Price > aPrevDepths[j].Price then
          begin
            if FSales[0].Side = -1 then
              if j < aPrevDepths.GetSize-1 then
                inc(j)
            else
              if i < aDepths.GetSize-1 then
                inc(i);
          end
          else begin
            if FSales[0].Side = -1 then
              if i < aDepths.GetSize-1 then
                inc(i)
            else
              if j < aPrevDepths.GetSize-1 then
                inc(j);
          end;
          inc(k);
        end;

        //-------------
        if (iFind = 1) and (iDec >= 0) then
        begin
          dPrice  := aDepths[iDec].Price;
          MakeFillOrderData( aFType, dPrice, FSales[0].Price, iQty, FSales[0].Side,
           iDec, index2,  bModify , bTarget);
        end
        else begin
          MakeFillOrderData( aFType, 0, FSales[0].Price, iQty, FSales[0].Side,
           iDec, index2,  bModify , bTarget);
        end;
    end
    else begin
      iFind := 1;
      MakeFillOrderData(aFType, 0, FSales[0].Price, iQty, FSales[0].Side,
        -1, index2, bModify, bTarget );
    end;

  end else
  // ???? ???? ???? ???? ???? - ?????? ?????? ???? ????.
  // ?????? ???? ???? ???? - ?????????? ???? ????????
  if aFType in [ftLittle, ftSame] then
  begin
    // ????????????
    if bModify then
    begin
        iFind := -1;
        for i := 0 to aDepths.GetSize - 1 do begin
          //if i = index then Continue;
          iGapVol := aDepths[i].Volume - aPrevDepths[i].Volume;

          if (iGapVol < 0) then
          begin
            iDec := i;
            iFind := 1;
            break;
          end;
        end;

        if (iFind = 1) and (iDec >= 0) then
        begin
          dPrice  := aDepths[iDec].Price;
          MakeFillOrderData( aFType,dPrice, FSales[0].Price, iQty, FSales[0].Side,iDec, index2, bModify , bTarget);
        end
        else
          MakeFillOrderData( aFType,0, FSales[0].Price, iQty, FSales[0].Side,iDec, index2, bModify , bTarget);

    end
    else begin
      iFind := 1;
      MakeFillOrderData( aFType, 0, FSales[0].Price, iQty, FSales[0].Side,-1, index2, bModify, bTarget );
    end;
  end else
  // ?????? ???????? ????
  if aFType = ftLittleC then
  begin
    if bModify then
    begin
        i := 0; j := 0; k:= 0;
        //-------------
        while (k < (aDepths.GetSize * 2 -1))  do
        begin
          if j = index then begin
            inc( k );
            if j < aPrevDepths.GetSize-1 then
              inc( j );
            Continue;
          end;

          if aDepths[i].Price = aPrevDepths[j].Price then
          begin
            iGapVol := aDepths[i].Volume - aPrevDepths[j].Volume ;
            if iGapVol < 0 then begin
              iFind := 1;
              iDec := i;
              break;
            end;

            if i < aDepths.GetSize-1 then
              inc(i);
            if j < aPrevDepths.GetSize-1 then
              inc(j);
            inc(k);
          end
          else if aDepths[i].Price > aPrevDepths[j].Price then
          begin
            if FSales[0].Side = -1 then
              if j < aPrevDepths.GetSize-1 then
                inc(j)
            else
              if i < aDepths.GetSize-1 then
                inc(i);
          end
          else begin
            if FSales[0].Side = -1 then
              if i < aDepths.GetSize-1 then
                inc(i)
            else
              if j < aPrevDepths.GetSize-1 then
                inc(j);
          end;
          inc(k);
        end;

        //-------------
        if (iFind = 1) and (iDec >= 0) then
        begin
          dPrice  := aDepths[iDec].Price;
          MakeFillOrderData( aFType, dPrice, FSales[0].Price, iQty, FSales[0].Side,
           iDec, index2,  bModify , bTarget);
        end
        else
          MakeFillOrderData( aFType, 0, FSales[0].Price, iQty, FSales[0].Side,
            iDec, index2,  bModify , bTarget);
    end;
  end;

  Result := iFind = 1;
end;



function TQuote.AnalysizeFill( bContinueFill : boolean ) : boolean;
var
  Price : double;
  iSumH, iSumV, iPrSumH, iPrSumV :Integer;
  iSumH2, iSumV2, iPrSumH2, iPrSumV2 :Integer;
  i, j, Side, Volume, iQty: integer;
  aDepths, aDepths2, aPrevDepths, aPrevDepths2 : TMarketDepths;
  bFind : boolean;
  stTmp, stPrice : string;
  aFType : TFillOrderType;
  bContinue : boolean;
begin

  bContinue := bContinueFill;

  if bContinue then
  begin
    FContinueFill := true;
    FSales[0].ContinueFill  := true;
    {
    gEnv.OnLog( self, Format('%d, %.2f, %d', [ FSales[0].Side, FSales[0].Price,
      FSales[0].Volume ]));
      }
    Exit;
  end;

  {
  if FContinueFill then
  begin
    if FSales.Count > 1 then
    begin
      if not FSales[1].ContinueFill then
        FContinueFill := false
      else begin
        if FSales[1].Side <> FSales[0].Side then
          FContinueFill := false;
      end;
    end;
  end;
  }

  bFind := false;
  Price := FSales[0].FPrice;
  Volume:= FSales[0].Volume;

  if FSales[0].Side = -1 then begin
    aDepths := Asks;        // ???? ????
    aDepths2 := Bids;       // ??????
    aPrevDepths := FPrevAsks;     // ???? ????
    aPrevDepths2 := FPrevBids;    // ??????
  end
  else begin
    aDepths := Bids;
    aDepths2 := Asks;
    aPrevDepths := FPrevBids;
    aPrevDepths2 := FPrevAsks;
  end;

  if not FContinueFill then
  begin
    // ???????? ( ???? ?????? )
    iSumH :=0; iSumV:=0; iPrSumH:=0; iPrSumV:=0;
    for i := 0 to aDepths.GetSize - 1 do
    begin
      iSumV   := iSumV + aDepths[i].Volume;
      iSumH   := iSumH + Round(aDepths[i].Price * 100 );
      iPrSumH := iPrSumH + Round(aPrevDepths[i].Price * 100 );
      iPrSumV := iPrSumV + aPrevDepths[i].Volume;
    end;

    // ??????
    iSumH2 :=0; iSumV2:=0; iPrSumH2:=0; iPrSumV2:=0;
    for i := 0 to aDepths2.GetSize - 1 do
    begin
      iSumV2    := iSumV2 + aDepths2[i].Volume;
      iSumH2    := iSumH2 + Round(aDepths2[i].Price * 100 );
      iPrSumH2  := iPrSumH2 + Round(aPrevDepths2[i].Price * 100 );
      iPrSumV2  := iPrSumV2 + aPrevDepths2[i].Volume;
    end;

    // ???? ???? little, more, same
    if ( iPrSumH2 = iSumH2 )  and ( iPrSumH = iSumH ) then
      aFType := ftLittle
    else if ( iPrSumH2 = iSumH2 ) and ( iPrSumH <> iSumH ) then
      aFType := ftLittleC
    else if ( iPrSumH2 <> iSumH2 )  and ( iPrSumH <> iSumH ) then
       aFType := ftMore
    else if ( iPrSumH2 <> iSumH2 )  and ( iPrSumH = iSumH ) then
      aFType := ftSame
    else
      Exit;

  end
  else
    aFType := ftMore;

  if FContinueFill then
  begin
    iQty := 0;
    for i := 1 to FSales.Count - 1 do
    begin
      if not FSales[i].ContinueFill then break;
      iQty  := iQty + FSales[i].Volume;
    end;
    FContinueFill := false;
    Volume := Volume + iQty;
    FSales[0].ContinueFillQty := Volume;
    bContinue := true;
  end;

  result  := ExtracteFillOrder( aFType, aDepths, aDepths2, aPrevDepths,
     aPrevDepths2, bContinue, i, Volume );
end;

procedure TQuote.MakeQuoteModifyOrderData(aQType: TQuoteOrderType; price,
  price2: double; qty, side, index1, index2: integer; bGone : boolean = false);
  var
    aData : TOrderData;
    stWhat : string;
begin

  case aQType of
    NONE: stWhat := 'None';
    SN, LN: stWhat := 'New';
    SC, LC, SPC, LPC: stWhat := 'Cancle' ;
    LPM, SPM, All: stWhat := 'Modify' ;
  end;

  aData := (FPriceAxis.OrderList.Insert(0) as TOrderData );
  aData.No     := index1 + 1;
  aData.No2    := index2 + 1;

  if aData.No = 0 then
    aData.No := 9;

  if aData.No2 = 0 then
    aData.No2  := 9;

  aData.QType   := aQType;
  aData.dPrice  := price;
  aData.dPrice2 := price2;
  aData.BGone   := bGone;

  aData.Time  := FLastEventTime;
  aData.Name  := stWhat;

  aData.Price := Format('%.*n -> %.*n', [ Symbol.Spec.Precision, Price,
                  Symbol.Spec.Precision, Price2]);
  aData.Qty   := IntToStr( abs(qty) );
  aData.Side  := IfThenStr( Side = 1,'L',  ifThenStr( Side =0,'X', 'S'));
  aData.FillQty := '';

  aData.ContinueFill := false;

  FLastData   := aData; 

end;

procedure TQuote.MakeQuoteOrderData(aQType: TQuoteOrderType; price: double; qty,
  side, index: integer; bGone : boolean);
  var
    aData : TOrderData;
    stWhat : string;
begin
  case aQType of
    NONE: stWhat := 'None';
    SN, LN: stWhat := 'New';
    SC, LC, SPC, LPC: stWhat := 'Cancle' ;
    LPM, SPM, All: stWhat := 'Modify' ;
  end;

  aData := (FPriceAxis.OrderList.Insert(0) as TOrderData );
  {
  if index >= 5 then
    index := -1
  }
  aData.No2  := index + 1;
  aData.QType := aQtype;
  aData.dPrice  := price;
  aData.dPrice2 := 0;;
  aData.BGone  := bGone;

  aData.Time  := FLastEventTime;
  aData.Name  := stWhat;
  aData.Price := Format('%.*n', [ Symbol.Spec.Precision, Price]);
  aData.Qty   := IntToStr( abs(qty) );
  aData.Side  := IfThenStr( Side = 1,'L',  ifThenStr( Side =0,'X', 'S'));
  aData.FillQty := '';

  aData.ContinueFill := false;

  FLastData := aData;

end;


procedure TQuote.CalcCntRatio;
var
  d1, d2, dVal : double;
begin
  if ( FAsks.CntTotal = 0 ) or ( FBids.CntTotal = 0 ) then
    FCntRatio := 0.0
  else begin
    d1  := FAsks.CntTotal / FBids.CntTotal;
    d2  := FBids.CntTotal / FAsks.CntTotal;
    FCntRatio:= min( d1, d2 );
    if FAsks.CntTotal > FBids.CntTotal then
      FCntRatio := FCntRatio * -1;
  end;

  FSymbol.CntRatio := FCntRatio;

end;

procedure TQuote.CalcVolRatio;
var
  d1, d2, dVal : double;
begin
  if ( FAsks.VolumeTotal = 0 ) or ( FBids.VolumeTotal = 0 ) then
    FVolRatio := 0
  else begin
    d1  := FAsks.VolumeTotal / FBids.VolumeTotal;
    d2  := FBids.VolumeTotal / FAsks.VolumeTotal;
    FVolRatio:= min( d1, d2 );
    if FAsks.VolumeTotal > FBids.VolumeTotal then
      FVolRatio := FVolRatio * -1;
  end;

  FSymbol.VolRatio := FVolRatio;
end;

procedure TQuote.CalceATRValue;
var
  j,i,k, iD, iCnt: integer;
  aItem , aPrvItem : TSTermItem;
  dtTime : TDateTime;
  a, b, d, tr, atr, tr2,
  H, L, C, pC : double;
  wHH, wMM, wSS, wCC : word;
begin    {
  try

      dtTime := FTerms.XTerms[0].StartTime;
      H := -1;
      L := 1000000;
      C := 0;
      j := 0;
      for I := 0 to FTerms.Count - 1 do
      begin
        aItem := FTerms.XTerms[i];
        iD  := DaysBetween( aItem.StartTime, dtTime );
        DecodeTime(aItem.StartTime, wHH, wMM, wSS, wCC);

        // ???????? ????..???? 1???? ?????? ??????
        if ( iD > 0) and ( wHH = 1 ) then
        begin
          // ???? ??????..
          FSymbol.PrevH[j]  := H;
          FSymbol.PrevL[j]  := L;
          FSymbol.PrevC[j]  := C;

          dtTime := aItem.StartTime;
          inc( j );

          if j > 1 then
          begin
            FSymbol.DawnOpen  := aItem.O;
            Break;
          end;
          H := -1;
          L := 1000000;
        end;
        // ??, ??, ?? ????..
        if aItem.H > H then
          H := aItem.H;
        if aItem.L < L then
          L := aItem.L;
        C := aItem.C;
      end;

  finally
    FTerms.Clear;
    FCalcedPrevHL := true;
  end;  }
end;

procedure TQuote.CalcePrevATR;
var
  j,i,k, iD, iCnt: integer;
  aItem , aPrvItem : TSTermItem;
  dtTime : TDateTime;
  a,b, c, r, trSum : double;
begin
                    {
  if FCalcedATR then Exit;

  // ???? 50?? ???? ???????? ATR ?? ??????.

  for I := 0 to Terms.Count - 1 do
  begin

    k := i-1;  if k < 0 then k := 0;

    aItem   := Terms.XTerms[i];
    aPrvItem:= Terms.XTerms[k];

    a := aItem.H - aItem.L;
    b := abs( aPrvItem.C - aItem.H );
    c := abs( aPrvItem.C - aItem.L );

    r:= max( max( a,b ), c );
    trSum := trSum + r;
    inc( iCnt );

    FtrQ.PushItem( now, r);
    if FtrQ.Full then    
      FATR := FtrQ.SumPrice / FtrQ.MaxCount
    else
      FATR := FtrQ.SumPrice / iCnt ;
  end;
          }
end;

procedure TQuote.CalcHogaSpread;
var
  AskPrice, BidPrice : double;
  HogaGap, i, iTickSize : integer;
begin

  if (Asks.Count = 0) or ( Bids.Count = 0) then Exit;

  AskPrice := Asks[0].Price;
  BidPrice := Bids[0].Price;

  if (AskPrice = 0) or (BidPrice = 0) then
  begin
    FSymbol.HogaSpread := -1;
    Exit;
  end;

  iTickSize := GetTickSize( AskPrice );
  HogaGap   := Round((AskPrice - BidPrice ) + 0.1);
  if iTickSize = GetTickSize( BidPrice ) then
  begin
    FSymbol.HogaSpread := HogaGap div iTickSize;
  end
  else begin
    i := 1;
    while ( AskPrice = TicksFromPrice( FSymbol, BidPrice, i ))  do
    begin
      inc(i);
    end;
    FSymbol.HogaSpread := i;
  end;

  // LP Hoga Spread
  AskPrice := 0;
  BidPrice := 0;

  for i := 0 to Asks.GetSize - 1 do
  begin
    if Asks[i].LpVolume > 0 then begin
      AskPrice  := Asks[i].Price;
      break;
    end;
  end;

  for i := 0 to Asks.GetSize - 1 do
  begin
    if Bids[i].LpVolume > 0 then begin
      BidPrice  := Bids[i].Price;
      break;
    end;
  end;

  if (AskPrice = 0) and (BidPrice = 0) then
  begin
    FSymbol.LpHogaSpread := 'X';
    Exit;
  end else
  if AskPrice = 0 then  begin
    FSymbol.LpHogaSpread := 'L';
    Exit;
  end else
  if BidPrice = 0 then begin
    FSymbol.LpHogaSpread := 'S';
    Exit;
  end;               

  iTickSize := GetTickSize( AskPrice );
  HogaGap   := Round((AskPrice - BidPrice ) + 0.1);
  if iTickSize = GetTickSize( BidPrice ) then
  begin
    if iTickSize <> 0 then
      FSymbol.LpHogaSpread := IntToStr( HogaGap div iTickSize )
    else
      FSymbol.LpHogaSpread := '0';
  end
  else begin
    i := 1;
    while ( AskPrice = TicksFromPrice( FSymbol, BidPrice, i ))  do
    begin
      inc(i);
    end;
    FSymbol.LpHogaSpread := IntToStr( i );
  end;

end;

procedure TQuote.CalcRealTimeAvg;
var
  askTmp, bidTmp : double;
  askSum, bidSum, i : Integer;
begin

  try
    askSum := 0;   bidSum := 0;
    for I := 1 to Asks.GetSize - 1 do
    begin
      askSum  := askSum + Asks[i].Volume;
      bidSum  := bidSum + Bids[i].Volume;
    end;

    if (askSum > 0 ) then
    begin
      askTmp  := Asks.FRealTimeAvg;
      inc( Asks.FRealCount );
      Asks.RealVolSum := askSum;
      Asks.FRealTimeAvg := askTmp + ( askSum / 4 - askTmp ) / Asks.RealCount;
    end;

    if ( bidSum > 0) then
    begin
      bidTmp  := Bids.FRealTimeAvg;
      inc( Bids.FRealCount );
      Bids.RealVolSum := bidSum;
      Bids.FRealTimeAvg := bidTmp + ( bidSum / 4 - bidTmp ) / Bids.RealCount;
    end;
  except
  end;
end;


constructor TQuote.Create(aColl: TCollection);
begin
  inherited Create(aColl);

    // data
  FAsks := TMarketDepths.Create;
  FBids := TMarketDepths.Create;

  FPrevBids:= TMarketDepths.Create;
  FPrevAsks:= TMarketDepths.Create;

  //FPriceInfos:= TPriceInfos.Create;
  FPriceAxis:= TPriceAxis.Create;
  FTerms    := TSTerms.Create;
  FTerms.OnAdd  := OnTermAddEvent;

  FSales := TTimeNSales.Create;
        //
  FDistributor := TDistributor.Create;
    // identity
  FSymbolCode := '';
  FSymbol := nil;

    // daily price info
  FOpen := 0;
  FHigh := 0;
  FLow := 0;
  FLast := 0;
  FChange := 0;

  FLowChl := 0;
  FHighChl:= 0;
    // daily trading info
  FDailyVolume := 0;
  FDailyAmount := 0;
  FOpenInterest := 0;

    // status
  FEventCount := 0;
  FLastEvent := qtNone;
  FLastEventTime := 0;
  FLastQuoteTime := 0;
  FCustomEventID := 0;
  {
  FGi  := TGiExpertControl.Create(nil);
  FGi.OnReceiveData   := OnReceiveData;
  FGi.OnReceiveRTData := OnReceiveRTData;
  }
  FLastSale := nil;

  FContinueFill  := false;
  FRecovered     := false;
  FAddTerm       := false;
  FMakeTerm      := false;

  OrderCount  := 5;

  FExtracteOrderCnt := 0;
  FForceDistCnt     := 0;
  FOwnOrderTraceCnt := 0;

  FTicks := TCollection.Create( TTickItem);
  // use simulation
  FQuoteList:= TList.Create;
  MarketState := '10';

  FCalcedPrevHL := false;

  //FCumulSale:= TCircularQueue.Create( 100 );
end;

procedure TQuote.Delivery(iType: Integer);
begin
  FDistributor.Distribute2(Self, iType, Self, 0);
end;

destructor TQuote.Destroy;
begin
  FQuoteList.Free;
  FTerms.Free;
  FDistributor.Free;
  //FCumulSale.Free;
  FAsks.Free;
  FBids.Free;
  FSales.Free;

  FPrevBids.Free;
  FPrevAsks.Free;
  //FPriceInfos.Free;
  FPriceAxis.Free;
  FTicks.Free;

  inherited;
end;


procedure TQuote.SetSymbol(const Value: TSymbol);
var
  stLog : string;
  iRes  : integer;
  bRes  : boolean;
begin
  if Value = nil  then
    Exit;

  FSymbol := Value;
  FPriceAxis.Prec := 5;//Value.Spec.Precision;
  FPriceAxis.TickSize := Value.Spec.TickSize;
  FPriceAxis.Symbol   := value;
  FTerms.Symbol := Value;

  if FSymbol.Spec.Market in [mtStock, mtElw] then begin
    FAsks.Size := 10;
    FBids.Size := 10;
  end
  else if (FSymbol.Spec.Market = mtFutures) and (FSymbol.IsStockF)then begin
    FAsks.Size := 10;
    FBids.Size := 10;
    FPrevAsks.Size := 10;
    FPrevBids.Size := 10;

  end
  else begin
    FAsks.Size := 5;
    FBids.Size := 5;
    FPrevAsks.Size := 5;
    FPrevBids.Size := 5;
  end;


end;

procedure TQuote.Update(dtQuote: TDateTime; atype : integer);
var
  iStep : integer;
  bRes  : boolean;
  aTick : TTickITem;
  stTmp : string;
  stLog : string;
  //aItem : TQueueItem;
begin

  Inc(FEventCount);

  bRes  := true;

  FLastEventTime := GetQuoteTime;
  FLastQuoteTime := dtQuote;

  FPrevEvent  := FLastEvent;
  FAddTerm    := false;

    // last sale changed
  if (FSales.Last <> nil) and (FSales.Last <> FLastSale) then
  begin
    FLastFillTime := dtQuote;
    FLastEvent := qtTimeNSale;
    FLastSale := FSales.Last;

    if FSymbol <> nil then
    begin
      FSymbol.Last := FLastSale.Price;
      FSymbol.DayOpen := FOpen;
      FSymbol.DayHigh := FHigh;
      FSymbol.DayLow  := FLow;

      aTick   := TTickITem( FTicks.Add );
      aTick.T := Sales.Last.Time;// LocalTime;
      aTick.C := Last;
      aTick.FillVol := Sales.Last.Volume;
      aTick.AccVol  := DailyVolume;
      aTick.Side    := FLastSale.Side;
      aTick.AskPrice:= Asks[0].Price;
      aTick.BidPrice:= Bids[0].Price;

      if FMakeTerm then FTerms.NewTick(aTick)
      else if FSymbol.Make1Min then FTerms.NewTick(aTick);
    end;

    gEnv.Engine.TradeCore.Positions.UpdatePosition( Self );
    gEnv.Engine.TradeCore.InvestorPositions.UpdatePosition( Self );
    gEnv.Engine.TradeCore.FundPositions.UpdatePosition( Self );
    gEnv.Engine.TradeCore.StrategyGate.UpdatePosition( Self );

    {
    if (FSymbol.Spec.Market in [ mtFutures, mtOption]) and  (not FSymbol.IsStockF) then
    begin
      SavePrevMarketDepths( true, atype = 1 );
    end;
    }
  end else
  begin
    FLastEvent := qtMarketDepth;
    {
    if (FSymbol.Spec.Market in [ mtFutures, mtOption]) and  (not FSymbol.IsStockF) then
      SavePrevMarketDepths( false, atype = 1 );
      }
  end;

  CalcCntRatio;
  CalcVolRatio;
  //CalcRealTimeAvg;
    // notify to the QuoteBroker
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);

  gEnv.Engine.TradeCore.StopOrders.DoQuote( Self  );
  gEnv.Engine.TradeCore.StrategyGate.DoQuote(self, 0);
  gEnv.Engine.SymbolCore.ConsumerIndex.Paras.Delivery( Self, QTE_DATA, 0 );
  
  FDistributor.Distribute(Self, 0, Self, 0);
end;

procedure TQuote.OnTermAddEvent(Sender: TObject);
begin
  FAddTerm  := true;
end;

procedure TQuote.UpdateChart(iVal : integer );
begin
//  gEnv.Engine.TradeCore.StrategyGate.DoQuote(self, CHART_DATA);
  FDistributor.Distribute(Self, CHART_DATA , Self, iVal);
end;

procedure TQuote.UpdateCustom(dtQuote: TDateTime);
begin
  Inc(FEventCount);
  FLastEventTime := Now;

  FLastQuoteTime := dtQuote;
  FLastEvent := qtCustom;

  Last := FSymbol.Last;
  Open := Fsymbol.DayOpen;
  Low  := FSymbol.DayLow;
  High := FSymbol.DayHigh;

  gEnv.Engine.TradeCore.Positions.UpdatePosition( Self );
  gEnv.Engine.TradeCore.InvestorPositions.UpdatePosition( Self );
  gEnv.Engine.TradeCore.FundPositions.UpdatePosition( Self );

   // notify to the QuoteBroker
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);

    // notify
  FDistributor.Distribute(Self, 0, Self, 0);
end;



procedure TQuote.UpdatePv0(dtQuote: TDateTime);
var
  iStep : integer;
  bRes  : boolean;
  aTick : TTickITem;
begin

  Inc(FEventCount);

  bRes  := true;
  FLastEventTime := GetQuoteTime;
  FLastQuoteTime := dtQuote;
  FPrevEvent  := FLastEvent;

    // last sale changed
  if (FSales.Last <> nil) and (FSales.Last <> FLastSale) then
  begin
    FLastFillTime := dtQuote;
    FLastEvent := qtTimeNSale;
    FLastSale := FSales.Last;

    if FSymbol <> nil then
    begin
      FSymbol.Last := FLastSale.Price;
      FSymbol.DayOpen := FOpen;
      FSymbol.DayHigh := FHigh;
      FSymbol.DayLow  := FLow;

      aTick := TTickITem( FTicks.Add );
      aTick.T := Sales.Last.LocalTime;
      aTick.C := Last;
      aTick.FillVol := Sales.Last.Volume;
      aTick.AccVol  := DailyVolume;

      if (FLastQuoteTime > 0.1)  then
      begin
        FSymbol.DeliveryTime := Frac( FLastEventTime - FLastQuoteTime );

        if FSymbol.DeliveryTime < FSymbol.MinDeliveryTime then
          FSymbol.MinDeliveryTime := FSymbol.DeliveryTime;
        FSymbol.DelayMs := Round((FSymbol.DeliveryTime-FSymbol.MinDeliveryTime) * 24 * 3600 * 1000);
      end;
    end;

    gEnv.Engine.TradeCore.Positions.UpdatePosition( Self );

  end else
  begin
    FLastQuoteTime := dtQuote;
    FLastEvent := qtMarketDepth;
  end;

    // notify to the QuoteBroker
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);

  FDistributor.Distribute(Self, 0, Self, 0);

end;

//============================================================================//

{ TQuoteBroker }

//---------------------------------------------------------------------< init >

function SortAcs(Item1, Item2: Pointer): Integer;
  var
  iValue   : double;
  iValue2  : double;
begin
              {
  iValue  := (( Item1 as TQuote ).Symbol ).TickRatio;
  iValue2 := (( Item2 as TQuote ).Symbol ).TickRatio;
  }
  iValue := TQuote( Item2 ).Symbol.TickRatio;
  iValue2:= TQuote( Item1 ).Symbol.TickRatio;

  if iValue > iValue2 then
    Result := 1
  else if iValue = iValue2 then
    Result := 0
  else
    Result := -1;
end;

procedure TQuoteBroker.Cancel(aSubscriber: TObject; bSymbolCore: boolean);
var
  i: Integer;
  aQuote: TQuote;
begin
  for i := Count - 1 downto 0 do
  begin
    aQuote := Items[i] as TQuote;
    aQuote.FDistributor.Cancel(aSubscriber);

    if aQuote.FDistributor.Count = 0 then
    begin
      if Assigned(FOnCancel) then
        FOnCancel(aQuote);

      aQuote.Free;
    end;
  end;

  FSortList.Clear;

end;


constructor TQuoteBroker.Create;
var
  i : integer;
begin
  inherited Create(TQuote);

  FQuoteTimers := TQuoteTimers.Create;
  FQuoteTimers.Realtime := ( gEnv.RunMode <> rtSimulation );

  FLastEventTime := 0.0;
  FLastQuoteTime := 0.0;

  FSortList := TList.Create;

  QuoteIndex  := 0;
  //Quotes := TQuoteUnit.Create;
end;

procedure TQuoteBroker.Delivery(iType: integer);
var
  i : integer;
  aQuote : TQuote;
begin
  for i := 0 to Count - 1 do
  begin
    aQuote := Items[i] as TQuote;
    aQuote.Delivery( 300 );
  end;
end;

destructor TQuoteBroker.Destroy;
begin

  FSortList.Free;
  FQuoteTimers.Free;
  //Quotes.Free;

  inherited;
end;



procedure TQuoteBroker.DummyEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  //
end;

procedure TQuoteBroker.RefreshSymbols;
var
  i: Integer;
  aQuote: TQuote;
begin
  if Assigned(FOnFind) then
    for i := 0 to Count - 1 do
    begin
      aQuote := Items[i] as TQuote;
      aQuote.FSymbol := OnFind(aQuote.FSymbolCode);
    end;
end;

procedure TQuoteBroker.ResetDelayTime;
var
  i : integer;
  aQuote : TQuote;
begin
  for i := 0 to Count - 1 do
  begin
    aQuote := Items[i] as TQuote;
    aQuote.Symbol.MinDeliveryTime := 3;
  end;
end;

//---------------------------------------------------------------------< find >

function TQuoteBroker.Find(stSymbol: String): TQuote;
var
  iPos: Integer;
begin
  Result := nil;

  stSymbol := UpperCase(Trim(stSymbol));

  iPos := FSortedList.IndexOf(stSymbol);
  if iPos >= 0 then
    Result := FSortedList.Objects[iPos] as TQuote;
end;

function TQuoteBroker.Find2(stSymbol: string): TQuote;
begin
end;

function TQuoteBroker.GetSubscribeCount : integer;
begin
  Result := FSortedList.Count;
end;


procedure TQuote.MakePriceAxis;
var
  HighLimit, LowLimit, dPrice  : Double;

begin

  FPriceAxis.Clear;

  HighLimit := FSymbol.LimitHigh ;
  LowLimit  := FSymbol.LimitLow  ;

  dPrice := LowLimit;

  //if (FSymbol.Spec.Market = mtOption) and ( FSymbol.Code[1] = '3') then
  //  dPrice :=

  while True do
  begin
    FPriceAxis.New( dPrice );
    dPrice := TicksFromPrice(FSymbol, dPrice, 1);
    if dPrice > HighLimit - PRICE_EPSILON then Break;
  end;

end;

function TQuoteBroker.GetQuoted( iPos : integer) : TQuote;
begin
  Result := FSortedList.Objects[iPos] as TQuote;
end;

//-------------------------------------------------------------< quote update >

procedure TQuoteBroker.QuoteUpdated(Sender: TObject);
var
  aQuote: TQuote;
  iSec  : integer;
begin
  aQuote := Sender as TQuote;
  if aQuote <> nil then
  begin
    FLastEventTime := aQuote.LastEventTime;
//    FLastQuoteTime := aQuote.LastQuoteTime;
  end;
end;

//---------------------------------------------------------------< subscribe >

function TQuoteBroker.Subscribe(aSubscriber: TObject; stSymbol: String;
  aHandler: TDistributorEvent): TQuote;
var
  stCode: String;
begin
  Result := Find(stSymbol);

  if Result = nil then
  begin
    stCode := UpperCase(Trim(stSymbol));
    Result := Add(stCode) as TQuote;
    Result.FSymbolCode := stCode;
    Result.FOnUpdate := QuoteUpdated;

      // find symbol object (optional)
    if Assigned(FOnFind) then
      Result.Symbol := OnFind(stCode);

    Result.Symbol.Quote := Result;
      // if necessary, subscribe to quote provider(brokerage server or else)
    if Assigned(FOnSubscribe) then
      FOnSubscribe(Result);
  end;

  Result.FDistributor.Subscribe(aSubscriber, 0, Result, ANY_EVENT, aHandler);
end;

function TQuoteBroker.Subscribe(aSubscriber: TObject; aSymbol: TSymbol;
  aHandler: TDistributorEvent; spType : TSubscribePriority): TQuote;
var
  stCode: String;
begin
  Result := nil;

  if aSymbol = nil then Exit;

  Result := Find(aSymbol.Code);

  if Result = nil then
  begin
    stCode := UpperCase(Trim(aSymbol.Code));
    Result := Add(stCode) as TQuote;
    Result.FSymbolCode := stCode;
    //Result.SetSymbol( aSymbol );
    Result.Symbol := aSymbol;
    Result.Symbol.Quote := Result;
    Result.FOnUpdate := QuoteUpdated;
    // if necessary, subscribe to quote provider(brokerage server or else)
    if Assigned(FOnSubscribe) then
      if not FOnSubscribe(Result) then
      begin
        Result.Symbol.Quote := nil;
        Result.Free;
        Exit;
      end;
  end;

  Result.FDistributor.Subscribe(aSubscriber, 0, Result, ANY_EVENT, aHandler, spType);
end;

function TQuoteBroker.Subscribe(aSubscriber: TObject; aSymbol: TSymbol;
  aHandler: TDistributorEvent; EvnetID: TDistributorIDs;
  spType: TSubscribePriority): TQuote;
var
  stCode: String;
begin
  Result := nil;

  if aSymbol = nil then Exit;

  Result := Find(aSymbol.Code);

  if Result = nil then
  begin
    stCode := UpperCase(Trim(aSymbol.Code));
    Result := Add(stCode) as TQuote;
    Result.FSymbolCode := stCode;
    //Result.SetSymbol( aSymbol );
    Result.Symbol := aSymbol;
    Result.Symbol.Quote := Result;
    Result.FOnUpdate := QuoteUpdated;

    // if necessary, subscribe to quote provider(brokerage server or else)
    if Assigned(FOnSubscribe) then
      FOnSubscribe(Result);
  end;

  //Result.FDistributor.Subscribe(aSubscriber, 0, Result, TICK_EVENTS, aHandler, spType);

end;

function TQuoteBroker.Subscribe(aSubscriber: TObject; aSymbol: TSymbol;
  iDataID: integer; aHandler: TDistributorEvent;
  spType: TSubscribePriority): TQuote;
var
  stCode: String;
begin
  Result := nil;

  if aSymbol = nil then Exit;

  Result := Find(aSymbol.Code);

  if Result = nil then
  begin
    stCode := UpperCase(Trim(aSymbol.Code));
    Result := Add(stCode) as TQuote;
    Result.FSymbolCode := stCode;
    //Result.SetSymbol( aSymbol );
    Result.Symbol := aSymbol;
    Result.Symbol.Quote := Result;
    Result.FOnUpdate := QuoteUpdated;
    // if necessary, subscribe to quote provider(brokerage server or else)
    if Assigned(FOnSubscribe) then
      FOnSubscribe(Result);

  end;

  Result.FDistributor.Subscribe(aSubscriber, iDataID, Result, ANY_EVENT, aHandler, spType);

end;

function TQuoteBroker.Subscribe(aSubscriber: TObject; aSymbol: TSymbol;
  aHandler: TDistributorEvent; bMakeTerm: boolean; spType : TSubscribePriority): TQuote;
var
  stCode: String;
begin
  Result := nil;

  if aSymbol = nil then Exit;

  Result := Find(aSymbol.Code);

  if Result = nil then
  begin
    stCode := UpperCase(Trim(aSymbol.Code));
    Result := Add(stCode) as TQuote;
    Result.FSymbolCode := stCode;
    //Result.SetSymbol( aSymbol );
    Result.Symbol := aSymbol;
    Result.Symbol.Quote := Result;
    Result.FOnUpdate := QuoteUpdated;

    // if necessary, subscribe to quote provider(brokerage server or else)
    if Assigned(FOnSubscribe) then
      FOnSubscribe(Result);
  end;

  if not Result.MakeTerm then
    Result.MakeTerm := bMakeTerm;

  if gEnv.Engine.SymbolCore.Futures[0] = aSymbol then    //???????????? ???? ??????
    Result.MakeTerm := true;

  Result.FDistributor.Subscribe(aSubscriber, 0, Result, ANY_EVENT, aHandler, spType);

end;


function TQuoteBroker.SubscribeTest(aSubscriber: TObject; aSymbol: TSymbol;
  aHandler: TDistributorEvent; iTrCode : integer): TQuote;
var
  stCode: String;
begin
  Result := nil;

  if aSymbol = nil then Exit;

  Result := Find(aSymbol.Code);

  if Result = nil then
  begin
    stCode := UpperCase(Trim(aSymbol.Code));
    Result := Add(stCode) as TQuote;
    Result.FSymbolCode := stCode;
    Result.Symbol := aSymbol;
    Result.FOnUpdate := QuoteUpdated;
  end;

  if iTrCode = 9 then
    FSortList.Add( Result );

  Result.FDistributor.Subscribe(aSubscriber, 0, Result, ANY_EVENT, aHandler);
end;

//------------------------------------------------------------------< cancel >

procedure TQuoteBroker.Cancel(aSubscriber: TObject; stSymbol: String);
var
  aQuote: TQuote;
begin
  aQuote := Find(stSymbol);

  if aQuote <> nil then
  begin
    aQuote.FDistributor.Cancel(aSubscriber, 0, aQuote);

    if aQuote.FDistributor.Count = 0 then
    begin
      if Assigned(FOnCancel) then
        FOnCancel(aQuote);

      aQuote.Free;
    end;
  end;
end;

procedure TQuoteBroker.Cancel(aSubscriber: TObject; aSymbol: TSymbol);
var
  aQuote: TQuote;
begin
  if (aSubscriber = nil) or (aSymbol = nil) then Exit;

  aQuote := Find(aSymbol.Code);

  if aQuote <> nil then
  begin
    aQuote.FDistributor.Cancel(aSubscriber, 0, aQuote);

    if aQuote.FDistributor.Count = 0 then
    begin
      if Assigned(FOnCancel) then
        FOnCancel(aQuote);

      aQuote.Free;
    end;
  end;
end;

procedure TQuoteBroker.Cancel(aSubscriber: TObject);
var
  i: Integer;
  aQuote: TQuote;
begin
  for i := Count - 1 downto 0 do
  begin
    aQuote := Items[i] as TQuote;
    aQuote.FDistributor.Cancel(aSubscriber);

    if aQuote.FDistributor.Count = 0 then
    begin
      if Assigned(FOnCancel) then
        FOnCancel(aQuote);

      aQuote.Free;
    end;
  end;
end;

{ TPrevMarketDepths }

end.
