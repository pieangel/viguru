unit CleSymbolCore;

interface

uses
  Classes, SysUtils, Windows,

  CleFQN, CleMarketSpecs, CleConsumerIndex,

  CleSymbols, CleMarkets, CalcGreeks, GleTypes,

  CleKrxSymbolMySQLLoader
  ;

{$INCLUDE define.txt}

type
//  TSymbolLoadEvent = function(stDate: TDateTime): Boolean of object;

  TDuraReceiveEvent = procedure (aSymbol : TSymbol ) of object;

  TSymbolCore = class
  private
      // dates
    FMasterDate: TDateTime;

      // Specifications
    FSpecs: TMarketSpecs;

      // Symbol Information
    FSymbols: TSymbolList;
      // 
    FIndexes: TIndexes;
    FStocks: TStocks;
    FFutures: TFutures;
    FOptions: TOptions;
    FSpreads: TSpreads;
    FELWs: TELWs;
      //
    FSymbolCache: TSymbolCache;
    FOnDuraReceive : TDuraReceiveEvent;

      // Market Information ( subtype.underlying.market type.exchange.country)
    FMarkets: TMarketList;
      //
    FIndexMarkets: TIndexMarkets;   // *.index.exchange.country
    FStockMarkets: TStockMarkets;   // *.stock.exchange.country
    FFutureMarkets: TFutureMarkets; // *.future.exchange.country
    FSpreadMarkets: TSpreadMarkets; // *.spread.exchange.country
    FOptionMarkets: TOptionMarkets; // *.option.exchange.country
    FETFMarkets: TETFMarkets;       // *.etf.exchange.country
    FBondMarkets: TBondMarkets;     // *.bond.exchange.country
    FELWMarkets: TELWMarkets;       // *.elw.exchange.country
    FCurrencyMarkets: TCurrencyMarkets;     // *.currency.exchange.country
    FCommodityMarkets: TCommodityMarkets;   // *.commodity.exchange.country
    //FDollarMarkets: TDollarMarkets;


      // Market Groups
    FUnderlyings: TMarketGroups;    // *.underlying.*.exchange.country
    FExchanges: TMarketGroups;

    FSynFutures: TSymbol;
    FFuture: TFuture;      // *.exchange.country

    FChartStore : TCollection;

    FCalcDr  : boolean;
    FMonthlyItem : TOptionMarket;

    FPuts: TSymbolList;
    FCalls: TSymbolList;
    FMiniFuture: TFuture;
    //FDollars: TDollars;

    FBonds: TBonds;
    FSymbolLoader: TKRXSymbolMySQLLoader;
    FCommodities: TCommodities;
    FCurrencies: TCurrencies;
    FSectors: TMarketGroups;
    FUsFuture: TFuture;
    FConsumerIndex: TConsumerIndex;
    FMiniMonthlyItem: TOptionMarket;
    FBond5Future: TFuture;
    FBond10Future: TFuture;
    FBond3Future: TFuture;
    FJpyFuture: TFuture;
    FKrxFuture: TFuture;

{$IFDEF NH_FUT}
    FKD150Future: TFuture;
{$ENDIF}

    function GetATMIndex( bMini : boolean = false ): Integer;
  public

    k200DR  : Double;
    AggereGateValue : Double;  // ????????

    constructor Create;
    destructor Destroy; override;
    procedure MarketsSort;   // ???? sort;

    procedure Reset;
//    function Load(dtMaster: TDateTime): Boolean;
    procedure RegisterSymbol(aSymbol: TSymbol);
      // date
    property MasterDate: TDateTime read FMasterDate;
      // specifications
    property Specs: TMarketSpecs read FSpecs;
      // symbols
    property Symbols: TSymbolList read FSymbols;
    property Indexes: TIndexes read FIndexes;
    //property Dollars: TDollars read FDollars;

    property Bonds: TBonds read FBonds;
    property Commodities : TCommodities read FCommodities;
    property Currencies  : TCurrencies read FCurrencies;

    property Stocks: TStocks read FStocks;
    property Futures: TFutures read FFutures;
    property Options: TOptions read FOptions;
    property Spreads: TSpreads read FSpreads;
    property ELWs: TELWs read FELWs;
      //
    property Calls : TSymbolList read FCalls;
    property Puts  : TSymbolList read FPuts;

      // cache
    property SymbolCache: TSymbolCache read FSymbolCache;

      // markets
    property Markets: TMarketList read FMarkets;
    property IndexMarkets: TIndexMarkets read FIndexMarkets;
    //property DollarMarkets: TDollarMarkets read FDollarMarkets;

    property StockMarkets: TStockMarkets read FStockMarkets;
    property FutureMarkets: TFutureMarkets read FFutureMarkets;
    property SpreadMarkets: TSpreadMarkets read FSpreadMarkets;
    property OptionMarkets: TOptionMarkets read FOptionMarkets;
    property ETFMarkets: TETFMarkets read FETFMarkets;
    property BondMarkets: TBondMarkets read FBondMarkets;
    property ELWMarkets: TELWMarkets read FELWMarkets;
    property CurrencyMarkets : TCurrencyMarkets read FCurrencyMarkets;
    property CommodityMarkets: TCommodityMarkets read FCommodityMarkets;
      // market groups
    property Underlyings: TMarketGroups read FUnderlyings;
    property Exchanges: TMarketGroups read FExchanges;
    property Sectors  : TMarketGroups read FSectors;

    property SynFutures : TSymbol read FSynFutures write FSynFutures;
    property Future     : TFuture read FFuture  write FFuture;
    property KrxFuture     : TFuture read FKrxFuture  write FKrxFuture;
    property MiniFuture : TFuture read FMiniFuture  write FMiniFuture;
    property UsFuture   : TFuture read FUsFuture write FUsFuture;
    property JpyFuture  : TFuture read FJpyFuture write FJpyFuture;
    property Bond3Future: TFuture read FBond3Future write FBond3Future;
    property Bond5Future: TFuture read FBond5Future write FBond3Future;
    property Bond10Future: TFuture read FBond10Future write FBond10Future;

{$IFDEF NH_FUT}
    property KD150Future: TFuture read FKD150Future write FKD150Future;
{$ENDIF}

    property ConsumerIndex : TConsumerIndex read FConsumerIndex;
    property OnDuraReceive : TDuraReceiveEvent read FOnDuraReceive write FOnDuraReceive;
    property MonthlyItem : TOptionMarket read FMonthlyItem;
    property MiniMonthlyItem : TOptionMarket read FMiniMonthlyItem;

    property SymbolLoader : TKRXSymbolMySQLLoader read FSymbolLoader;

    function GetNextMonth(stFQN: string): TFuture; overload;
    function GetNextMonth( aSpec : TMarketSpec ): TFuture; overload;
        
    function GetStrikeOption(dStrikePrice: double; bCall: boolean): TOption;
    function GetCustomATMIndex( dLast : double; iMonth : integer ): Integer; overload;
    function GetCustomATMIndex( aMG: TMarketGroup; iMonth : integer ): TStrike; overload;

    procedure GetCurCallList(StrikeCount: Integer; var aList: TList); overload;
    procedure GetCurPutList(StrikeCount: Integer; var aList: TList); overload;

    procedure GetCurCallList(dAbove, dBelow : double; StrikeCount: Integer; var aList: TList; bMini :boolean = false); overload;
    procedure GetCurPutList(dAbove, dBelow  : double; StrikeCount: Integer; var aList: TList; bMini :boolean = false); overload;

    procedure GetCurCallList(dAbove: double; var aList: TList; bMini :boolean = false); overload;
    procedure GetCurPutList(dAbove : double; var aList: TList; bMini :boolean = false); overload;

    function  GetParkCall( dBelow , dPrice : double; bMini : boolean ) : TOption;

    procedure GetPriceSymbolList(dPriceLow : double; dPriceHigh : double;  bExpect : boolean; var aCall : TList; var aPut : TList);
    procedure GetOpenPriceSymbolList(dPriceLow : double; dPriceHigh : double;  bExpect : boolean; var aCall : TList; var aPut : TList);

    // ??????
    function GetCurCallVol(StrikeCount : Integer; aType : TRdCalcType ) : Double;overload;
    function GetCurPutVol(StrikeCount : Integer; aType : TRdCalcType ) : Double;overload;

    //Insert SMS
    function GetCurCallVol(StrikeCount : Integer; aType : TRdCalcType ;
      dFuturePrice : Double ; dMixRatio : Double) : Double ; overload;
    function GetCurPutVol(StrikeCount : Integer; aType : TRdCalcType ;
      dFuturePrice : Double ; dMixRatio : Double) : Double ; overload;

    // only dong bu..???? ???????? ?????? ????????.. ????;..
    function FindFutureMarket( stUnder : string ) : TFutureMarket;
    function GetSymbolInfo : boolean;
    procedure OptionPrint;
    function SubSribeOption : boolean;
    procedure GetChartData;
    procedure SubscbrideOption2;
  end;

function SortDate(Item1, Item2: Pointer): Integer;

implementation

uses GAppEnv, CleQuoteTimers, ApiPacket, ApiConsts, CleKrxSymbols,
  Math, DateUtils;

{ TSymbolCore }


constructor TSymbolCore.Create;
begin
  FSynFutures := nil;
  FFuture     := nil;
    // objects: specifications
  FSpecs := TMarketSpecs.Create;

    // objects: symbols
  FSymbols := TSymbolList.Create;
  FIndexes := TIndexes.Create;
  //FDollars := TDollars.Create;

  FBonds   := TBonds.Create;
  FStocks  := TStocks.Create;
  FFutures := TFutures.Create;
  FOptions := TOptions.Create;
  FSpreads := TSpreads.Create;
  FELWs := TELWs.Create;
  FCommodities:= TCommodities.Create;
  FCurrencies := TCurrencies.Create;

  FPuts := TSymbolList.Create;
  FCalls:= TSymbolList.Create;

  FSymbolCache := TSymbolCache.Create;

    // objects: markets
  FMarkets       := TMarketList.Create;
  FIndexMarkets  := TIndexMarkets.Create;
  //FDollarMarkets := TDollarMarkets.Create;
  FStockMarkets  := TStockMarkets.Create;
  FFutureMarkets := TFutureMarkets.Create;
  FOptionMarkets := TOptionMarkets.Create;
  FSpreadMarkets := TSpreadMarkets.Create;
  FETFMarkets    := TETFMarkets.Create;
  FBondMarkets   := TBondMarkets.Create;
  FELWMarkets    := TELWMarkets.Create;
  FCurrencyMarkets:= TCurrencyMarkets.Create;     // *.currency.exchange.country
  FCommodityMarkets:= TCommodityMarkets.Create ;   // *.commodity.exchange.country

    // objects: market groups
  FUnderlyings := TMarketGroups.Create;
  FExchanges   := TMarketGroups.Create;
  FSectors     := TMarketGroups.Create;

  FConsumerIndex := TConsumerIndex.Create;
  FSymbolLoader:= TKRXSymbolMySQLLoader.Create( nil );

  K200Dr := 0;
  AggereGateValue := 0;
  FCalcDr := false;
end;

destructor TSymbolCore.Destroy;
begin
    // objects: market groups
  FSymbolLoader.Free;

  FUnderlyings.Free;
  FExchanges.Free;
  FSectors.Free;
    // objects: markets
  FMarkets.Free;
  FIndexMarkets.Free;
  //FDollarMarkets.Free;
  FStockMarkets.Free;
  FSpreadMarkets.Free;
  FFutureMarkets.Free;
  FOptionMarkets.Free;
  FETFMarkets.Free;
  FBondMarkets.Free;
  FELWMarkets.Free;
  FCurrencyMarkets.Free;
  FCommodityMarkets.Free;
    // objects: symbols
  FSymbolCache.Free;
  FPuts.Free;
  FCalls.Free;
  FSymbols.Free;
  FSpreads.Free;
  FStocks.Free;
  FIndexes.Free;
  //FDollars.Free;
  
  FOptions.Free;
  FFutures.Free;
  FELWs.Free;
  FBonds.Free;
  FCommodities.Free;
  FCurrencies.Free;
    // objects: specifications
  FSpecs.Free;
  FChartStore.Free;
  FConsumerIndex.Free;
  inherited;
end;


function TSymbolCore.FindFutureMarket(stUnder: string): TFutureMarket;
var
  stPM  : string;
  //aFMkt : TFutureMarket;
begin
  stPM := Copy( stUnder, 1, Length( stUnder ) - 3 );
  Result:= FutureMarkets.FindPumMok( stPM );
  //stDate  := Copy( stUnder, Length( stUnder ) - 2, 3 );
end;

procedure TSymbolCore.Reset;
begin
    // objects: symbols
  gEnv.Engine.QuoteBroker.Cancel( self );

  FCalls.Clear;
  FPuts.Clear;

  FSymbols.Clear;
  FSpreads.Clear;
  FStocks.Clear;
  FIndexes.Clear;
  FOptions.Clear;
  FFutures.Clear;
  //FDollars.Clear;
  FBonds.Clear;
    // objects: markets
  FMarkets.Clear;
  FIndexMarkets.Clear;
  FStockMarkets.Clear;
  FFutureMarkets.Clear;
  FOptionMarkets.Clear;
  FETFMarkets.Clear;
  FBondMarkets.Clear;
  //FDollarMarkets.Clear;
  FELWMarkets.Clear;
    // objects: market groups
  FUnderlyings.Clear;
  FExchanges.Clear;
end;

procedure TSymbolCore.SubscbrideOption2;
var
  I, j, iCnt, iSent: Integer;
  aOptMarket  : TOptionMarket;
  aStrike : TStrike;
begin

  for I := 0 to FOptionMarkets.Count - 1 do
  begin
    aOptMarket  := FOptionMarkets.Markets[i] as TOptionMarket;

    if (aOptMarket.FQN = FQN_KOSPI200_OPTION ) or
       (aOptMarket.FQN = FQN_MINI_KOSPI200_OPTION )  then
    begin

      for j:=0 to  aOptMarket.Trees.FrontMonth.Strikes.Count-1 do
      begin
        aStrike := aOptMarket.Trees.FrontMonth.Strikes.Strikes[j];
        gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, aStrike.Call, gEnv.Engine.QuoteBroker.DummyEventHandler);
        gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, aStrike.put, gEnv.Engine.QuoteBroker.DummyEventHandler);
      end;
    end;
  end;

end;

function TSymbolCore.SubSribeOption : boolean;
var
  I, j, iCnt, iSent: Integer;
  aOptMarket  : TOptionMarket;
  aStrike : TStrike;
begin

  j := -1;

  for I := 0 to FOptionMarkets.Count - 1 do
  begin
    aOptMarket  := FOptionMarkets.Markets[i] as TOptionMarket;
    if aOptMarket.IsSub then
      Continue;

    if (aOptMarket.FQN = FQN_KOSPI200_OPTION ) or
       (aOptMarket.FQN = FQN_MINI_KOSPI200_OPTION )  then
    begin

      iCnt := 0;
      iSent:= 0;

      for j:=0 to  aOptMarket.Trees.FrontMonth.Strikes.Count-1 do
      begin
        aStrike := aOptMarket.Trees.FrontMonth.Strikes.Strikes[j];
        if not aStrike.Call.DoSubscribe then
        begin
          gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, aStrike.Call, gEnv.Engine.QuoteBroker.DummyEventHandler);
          inc(iCnt );
        end else inc( iSent );

        if not aStrike.Put.DoSubscribe then
        begin
          gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, aStrike.put, gEnv.Engine.QuoteBroker.DummyEventHandler);
          inc( iCnt );
        end else inc( iSent );

        if iCnt >= 10 then break;
      end;
      if ( iSent = aOptMarket.Trees.FrontMonth.Strikes.Count * 2  )  then
        aOptMarket.IsSub := true;
      break;
    end;
  end;

  Result  := j < 0;

end;

procedure TSymbolCore.RegisterSymbol(aSymbol: TSymbol);
var
  aMarket: TMarket;
begin
  if aSymbol = nil then Exit;

    // add to symbol list
  if FSymbols.IndexOfObject(aSymbol) < 0 then
    FSymbols.AddObject(aSymbol.Code, aSymbol);

    // ???? ?????? ?????? ????.
  if aSymbol.Spec <> nil then
  begin

    aMarket := FMarkets.FindMarket(aSymbol.Spec.FQN);

    if aMarket = nil then
    begin
      // ???? ?????? ?????? ????.
      case aSymbol.Spec.Market of
        mtIndex:   aMarket := FIndexMarkets.New(aSymbol.Spec.FQN);
        mtStock:   aMarket := FStockMarkets.New(aSymbol.Spec.FQN);
        mtBond:    aMarket := FBondMarkets.New(aSymbol.Spec.FQN);
        mtETF:     aMarket := FETFMarkets.New(aSymbol.Spec.FQN);
        mtFutures: aMarket := FFutureMarkets.New(aSymbol.Spec.FQN);
        mtOption:  aMarket := FOptionMarkets.New(aSymbol.Spec.FQN);
        mtSpread:  aMarket := FSpreadMarkets.New(aSymbol.Spec.FQN);

        mtCurrency:  aMarket := FCurrencyMarkets.New(aSymbol.Spec.FQN);
        mtCommodity:  aMarket := FCommodityMarkets.New(aSymbol.Spec.FQN);
        else
          Exit;
      end;
      // ???? ?????? ???? ????.
      aMarket.Spec := aSymbol.Spec;
      // ???? ?????? ?????? ????.
      FMarkets.AddMarket(aMarket);
        // ???? ????
      if aMarket.Spec.Market in [mtFutures, mtOption, mtSpread, mtELW] then
      begin
        // ???????? ?????? ?????? ???? ???? ?????? ?????? ???? ?????? ?????? ?????? ????.
        if (aSymbol as TDerivative).Underlying <> nil then
          FUnderlyings.AddMarket(aMarket,
                                 aSymbol.Spec.SubMarket
                                 + aSymbol.Spec.Underlying
                                 + '.' + aSymbol.Spec.Exchange
                                 + '.' + aSymbol.Spec.Country,
                                 (aSymbol as TDerivative).Underlying.Name,
                                 (aSymbol as TDerivative).Underlying);
      end;


      // ???? ?????? ?????? ????. 
      FExchanges.AddMarket(aMarket,
                           aSymbol.Spec.Exchange + '.' + aSymbol.Spec.Country,
                           aSymbol.Spec.Exchange);
    end;
    // ?????? ?????? ?????? ????. 
    aMarket.AddSymbol(aSymbol);
  end;
end;

function TSymbolCore.GetATMIndex( bMini : boolean ) : Integer;
var
  i, iATM : Integer;
  MaxDiff : Double;
  dLast : double;
  aMonthItem : TOptionMarket;
begin

  if bMini  then
    aMonthItem := FMiniMonthlyItem
  else
    aMonthItem := FMonthlyItem;

  if (aMonthItem = nil) or (aMonthItem.Trees.FrontMonth.Strikes.Count = 0 ) then
  begin
    Result := -1;
    Exit;
  end;

  if bMini  then
    dLast := gEnv.Engine.SymbolCore.MiniFuture.Last
  else
    dLast := gEnv.Engine.SymbolCore.Future.Last    ;

  iATM := -1;
  MaxDiff := 100000000.0;          // big number
  for i:=0 to aMonthItem.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    if Abs(aMonthItem.Trees.FrontMonth.Strikes.Strikes[i].StrikePrice - dLast) < MaxDiff
    then
    begin
      MaxDiff := Abs(aMonthItem.Trees.FrontMonth.Strikes.Strikes[i].StrikePrice - dLast);
      iATM := i;
    end
    else
      Break;
  end;
  Result := iATM;

end;

procedure TSymbolCore.GetCurCallList(StrikeCount: Integer;
  var aList : TList);
  var
    i, iATM, iEnd, iCount : Integer;
begin
  aList.Clear;
  iATM := GetATMIndex;
  if iATM < 0 then
    Exit;

  iCount := 0;
  iEnd := Min(iATM+StrikeCount-1, FMonthlyItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iATM to iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    aList.Add( call);
  end;

end;


procedure TSymbolCore.GetCurPutList(StrikeCount: Integer;
  var aList : TList);
  var
    i, iATM, iEnd, iCount : Integer;
begin
  aList.Clear;

  iATM := GetATMIndex;
  if iATM < 0 then
    Exit;

  iCount := 0;
  iEnd := Max(0, iATM-StrikeCount+1);


  for i:=iATM downto iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
    aList.Add( put);

end;

function TSymbolCore.GetCurCallVol(StrikeCount: Integer;
  aType: TRdCalcType): Double;
var
  i, iATM, iEnd, iCount : Integer;
  dIVSum : Double;
  CurCallVol : Double;

  OptPrice : Double;            // ????????
  U : Double;                   // ????????????
  E : Double;                    // ??????
  R : Double;                   // CD Rate
  T : Double;                   // ????????
  TC : Double;                  // ?????????? ????????
  W : Double;                   // Call=1, Put=-1
  ExpireDateTime : TDateTime;
begin
  //-- ATM strike price
  iATM := GetATMIndex;
  if iATM < 0 then
  begin
    Result := 0;
    Exit;
  end;

  // Call ??????????????????
  dIVSum := 0.0;
  iCount := 0;

  iEnd := Min(iATM+StrikeCount-1, FMonthlyItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iATM to iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    U := gEnv.Engine.SymbolCore.Future.Last;
    //U := gEnv.Engine.SyncFuture.FSynFutures.Last;
    E := StrikePrice;
    R := Call.CDRate;
    ExpireDateTime := GetQuoteDate + Call.DaysToExp - 1 + EncodeTime(15,45,0,0);
    T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, aType);
    TC := Call.DaysToExp/365;
    OptPrice := Call.Last;
    W := 1;

    dIVSum := dIVSum + IV(U, E, R, T, TC, OptPrice, W);
    Inc(iCount);
  end;

  CurCallVol := dIVSum / iCount;
  //
  Result := CurCallVol;

end;


function TSymbolCore.GetCurPutVol(StrikeCount: Integer;
  aType: TRdCalcType): Double;
var
  i, iATM, iEnd, iCount : Integer;
  dIVSum, dTmp : Double;
  CurPutVol : Double;

  OptPrice : Double;            // ????????
  U : Double;                   // ????????????
  E : Double;                    // ??????
  R : Double;                   // CD Rate
  T : Double;                   // ????????
  TC : Double;                  // ?????????? ????????
  W : Double;                   // Call=1, Put=-1
  ExpireDateTime : TDateTime;
begin
  //-- ATM strike price
  iATM := GetATMIndex;
  if iATM < 0 then
  begin
    Result := 0;
    Exit;
  end;

  // Put ??????????????????
  dIVSum := 0.0;
  iCount := 0;
  iEnd := Max(0, iATM-StrikeCount+1);

  dTmp := 0;

  for i:=iATM downto iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin

    U := gEnv.Engine.SymbolCore.Future.Last;
    //U := gEnv.Engine.SyncFuture.FSynFutures.Last;
    E := StrikePrice;
    R := Put.CDRate;
    ExpireDateTime := GetQuoteDate + Put.DaysToExp - 1 + EncodeTime(15,45,0,0);
    T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, aType);
    TC := Put.DaysToExp/365;
    OptPrice := Put.Last;
    W := -1;

    dTmp := IV(U, E, R, T, TC, OptPrice, W);
    dIVSum := dIVSum + dTmp;
    Inc(iCount);

    gEnv.EnvLog( WIN_TEST,
      Format('%.2f, %.2f, %.4f', [ StrikePrice, OptPrice, dTmp ])
    );
  end;

  CurPutVol := dIVSum / iCount;

  gEnv.EnvLog( WIN_TEST,
      Format('put iv : %.4f', [ CurPutVol ])
    );
  //
  Result := CurPutVol;

end;

procedure TSymbolCore.GetCurCallList(dAbove, dBelow : double; StrikeCount: Integer;
  var aList: TList; bMini :boolean);
  var
    i, iATM, iEnd, iCount : Integer;
    aMonthItem : TOptionMarket;
begin
  aList.Clear;
  iATM := GetATMIndex( bMini );
  if iATM < 0 then
    Exit;

  iCount := 0;

  if bMini  then
    aMonthItem := FMiniMonthlyItem
  else
    aMonthItem := FMonthlyItem;

  if (aMonthItem = nil) or (aMonthItem.Trees.FrontMonth.Strikes.Count = 0 ) then
    Exit;

  iEnd := aMonthItem.Trees.FrontMonth.Strikes.Count-1;
  // Min(iATM+StrikeCount-1, aMonthItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iATM to iEnd do
  with aMonthItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin

    if StrikeCount <= aList.Count then
      break;

    if (call.Last <= dAbove) and ( call.Last >= dBelow) then
      aList.Add( call);
  end;

end;

procedure TSymbolCore.GetCurPutList(dAbove, dBelow : double; StrikeCount: Integer;
  var aList: TList; bMini :boolean);
  var
    i, iATM, iEnd, iCount : Integer;
    aMonthItem : TOptionMarket;
begin
  aList.Clear;

  iATM := GetATMIndex( bMini );
  if iATM < 0 then
    Exit;

  if bMini  then
    aMonthItem := FMiniMonthlyItem
  else
    aMonthItem := FMonthlyItem;

  if (aMonthItem = nil) or (aMonthItem.Trees.FrontMonth.Strikes.Count = 0 ) then
    Exit;

  iCount := 0;
  iEnd := 0;//Max(0, iATM-StrikeCount+1);


  for i:=iATM downto iEnd do
  with aMonthItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    if aList.Count >= StrikeCount then
      break;
    if ( put.Last <= dAbove ) and ( put.Last >= dBelow ) then
      aList.Add( put);
  end;
end;

function TSymbolCore.GetParkCall(dBelow, dPrice: double;
  bMini: boolean): TOption;
  var
    i, iCount, idx : Integer;
    dVal : double;
    aMonthItem : TOptionMarket;
    dCall : array [0..1] of double;
begin
  Result := nil;

  if bMini  then
    aMonthItem := FMiniMonthlyItem
  else
    aMonthItem := FMonthlyItem;

  if (aMonthItem = nil) or (aMonthItem.Trees.FrontMonth.Strikes.Count = 0 ) then
    Exit;

  iCount := aMonthItem.Trees.FrontMonth.Strikes.Count;
  dVal   := 10000;
  idx    := -1;

  for i:= iCount-1 downto 0 do
  with aMonthItem.Trees.FrontMonth.Strikes.Strikes[i] do
    if ( Call.DayOpen <= dBelow ) and ( dVal >  abs( Call.DayOpen - dPrice )) then
    begin
      dVal  :=  abs( Call.DayOpen - dPrice );
      idx   := i;
    end;
    // ????..
  if idx >= 0 then
  begin
    // idx - 1  ???? ??????
    // idx
    // idx + 1  ???? ??????.
    dCall[0] := 0;
    dCall[1] := 100;

    if idx - 1 >= 0  then
      dCall[1]  := aMonthItem.Trees.FrontMonth.Strikes.Strikes[idx-1].Call.DayOpen;
    if idx + 1 < iCount then
      dCall[0]  := aMonthItem.Trees.FrontMonth.Strikes.Strikes[idx+1].Call.DayOpen;
    Result      := aMonthItem.Trees.FrontMonth.Strikes.Strikes[idx].Call;

    gEnv.EnvLog( WIN_TEST, Format(' ?????? ???? %s, %.2f < %.2f < %.2f',
      [ Result.ShortCode, dCall[0], Result.DayOpen, dCall[1] ])   );

    if ( dCall[0] < Result.DayOpen ) and ( Result.DayOpen < dCall[1] ) then
    else
      Result := nil;
  end;

end;


function TSymbolCore.GetCurCallVol(StrikeCount: Integer; aType: TRdCalcType;
  dFuturePrice, dMixRatio: Double): Double;
begin

end;


procedure TSymbolCore.GetChartData;
var
  dtDate  : TDateTime;
begin

  dtDate := Date;// IncDay( Date, -1 );
  // staff ????..??????..????????
  if Future <> nil then
    gEnv.Engine.SendBroker.ReqChartData( Future, dtDate, 100 , 1, '5' );

  if UsFuture <> nil then
    gEnv.Engine.SendBroker.ReqChartData( UsFuture, dtDate, 100 , 1, '5' );

  if Bond10Future <> nil then
    gEnv.Engine.SendBroker.ReqChartData( Bond10Future, dtDate, 100 , 1, '5' );


end;

procedure TSymbolCore.GetCurCallList(dAbove: double; var aList: TList;
  bMini: boolean);
  var
    i,iEnd : Integer;
    aMonthItem : TOptionMarket;
begin
  aList.Clear;


  if bMini  then
    aMonthItem := FMiniMonthlyItem
  else
    aMonthItem := FMonthlyItem;

  if (aMonthItem = nil) or (aMonthItem.Trees.FrontMonth.Strikes.Count = 0 ) then
    Exit;

  iEnd := aMonthItem.Trees.FrontMonth.Strikes.Count-1;
  // Min(iATM+StrikeCount-1, aMonthItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iEnd downto 0 do
  with aMonthItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    aList.Add( call);
    // dAbove ???? ????..
    if (call.Last > dAbove) then
      break;
  end;

end;

procedure TSymbolCore.GetCurPutList(dAbove: double; var aList: TList;
  bMini: boolean);
  var
    i,iEnd : Integer;
    aMonthItem : TOptionMarket;
begin
  aList.Clear;


  if bMini  then
    aMonthItem := FMiniMonthlyItem
  else
    aMonthItem := FMonthlyItem;

  if (aMonthItem = nil) or (aMonthItem.Trees.FrontMonth.Strikes.Count = 0 ) then
    Exit;

  iEnd := aMonthItem.Trees.FrontMonth.Strikes.Count-1;
  // Min(iATM+StrikeCount-1, aMonthItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=0 to iEnd do
  with aMonthItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    aList.Add( put);
    // dAbove ???? ????..
    if (put.Last > dAbove) then
      break;
  end;

end;

function TSymbolCore.GetCurPutVol(StrikeCount: Integer; aType: TRdCalcType;
  dFuturePrice, dMixRatio: Double): Double;
begin

end;


function TSymbolCore.GetCustomATMIndex(aMG: TMarketGroup;
  iMonth: integer): TStrike;
var
  i, iATM : Integer;
  MaxDiff : Double;
  aMonthlyItem : TOptionMarket;
  dLast : double;
  aMarket: TMarket;
  aStk : TStrike;
begin

  Result := nil;

  if aMG = nil then Exit;
  aMonthlyItem  := nil;
  dLast := -1;

  for I := 0 to aMG.Markets.Count - 1 do
  begin
    aMarket := aMG.Markets.Markets[i];

    case aMarket.Spec.Market of
      mtFutures: dLast  := aMarket.Symbols.Symbols[iMonth].Last;
      mtOption : aMonthlyItem  := aMarket as TOptionMarket  ;
    end;
  end;

  if (aMonthlyItem = nil) or ((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Count= 0 )
    or ( dLast < 0.001 ) then
    Exit;

  iATm := -1;
  MaxDiff := 100000000.0;          // big number
  for i:=(aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Count - 1 downto 0 do
  begin
    if Abs((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[i].StrikePrice - dLast) < MaxDiff
    then
    begin
      MaxDiff := Abs((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[i].StrikePrice - dLast);
      iATm    := i;
    end;
    //else
    //  Break;
  end;
  Result := (aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[iATM];

end;

function TSymbolCore.GetNextMonth(stFQN: string): TFuture;
var
  i : integer;
  aFutMarket : TFutureMarket;
begin
  Result := nil;

  for I := 0 to FutureMarkets.Count - 1 do
  begin
    aFutMarket := FutureMarkets.FutureMarkets[i];
    if (aFutMarket.FQN = stFQN) and ( aFutMarket.Symbols.Count > 1 )  then
      Result := aFutMarket.Futures[1];
  end;

end;

function TSymbolCore.GetNextMonth(aSpec: TMarketSpec): TFuture;
begin
  Result := GetNextMonth( aSpec.FQN );
end;

function TSymbolCore.GetCustomATMIndex(dLast: double; iMonth : integer): Integer;
var
  i, iATM : Integer;
  MaxDiff : Double;
  aMonthlyItem : TOptionMarket;
begin
  aMonthlyItem := OptionMarkets.OptionMarkets[0];

  if (aMonthlyItem = nil) or ((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Count= 0 ) then
  begin
    Result := -1;
    Exit;
  end;

  iATM := -1;
  MaxDiff := 100000000.0;          // big number
  for i:=(aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Count - 1 downto 0 do
  begin
    if Abs((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[i].StrikePrice - dLast) < MaxDiff
    then
    begin
      MaxDiff := Abs((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[i].StrikePrice - dLast);
      iATM := i;
    end;
    //else
    //  Break;
  end;
  Result := iATM;
end;


procedure TSymbolCore.GetOpenPriceSymbolList(dPriceLow, dPriceHigh: double;
  bExpect: boolean; var aCall, aPut: TList);
var
  i : integer;
  aOptionMarket : TOptionMarket;
  aStrike : TStrike;
  aSymbol : TSymbol;
  dPrice : double;
  stLog : string;
begin
  aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    aSymbol := aStrike.Call as TSymbol;
    dPrice := aSymbol.DayOpen;

    if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
      aCall.Add(aSymbol);

    stLog := Format('Open %s, %.2f', [aSymbol.ShortCode, dPrice]);


    aSymbol := aStrike.Put as TSymbol;
    dPrice := aSymbol.DayOpen;

    stLog := Format('%s, %s, %.2f', [stLog, aSymbol.ShortCode, dPrice]);
    //gEnv.EnvLog(WIN_RATIOS, stLog);
    if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
      aPut.Add(aSymbol);
  end;
end;





procedure TSymbolCore.GetPriceSymbolList(dPriceLow: double; dPriceHigh : double; bExpect : boolean;
  var aCall, aPut: TList);
var
  i : integer;
  aOptionMarket : TOptionMarket;
  aStrike : TStrike;
  aSymbol : TSymbol;
  dPrice : double;
  stLog : string;
begin
  if bExpect then
  begin
    aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
    for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
    begin
      aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
      aSymbol := aStrike.Call as TSymbol;
      dPrice := aSymbol.ExpectPrice;
      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aCall.Add(aSymbol);

      aSymbol := aStrike.Put as TSymbol;
      dPrice := aSymbol.ExpectPrice;
      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aPut.Add(aSymbol);
    end;
  end else
  begin
    aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
    for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
    begin
      aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
      aSymbol := aStrike.Call as TSymbol;
      dPrice := aSymbol.Last;

      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aCall.Add(aSymbol);

      stLog := Format('Open %s, %.2f', [aSymbol.ShortCode, dPrice]);

      aSymbol := aStrike.Put as TSymbol;
      dPrice := aSymbol.Last;


      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aPut.Add(aSymbol);
      stLog := Format('%s, %s, %.2f', [stLog, aSymbol.ShortCode, dPrice]);
      //gEnv.EnvLog(WIN_RATIOS, stLog);
    end;
  end;
end;

function TSymbolCore.GetStrikeOption(dStrikePrice: double;
  bCall: boolean): TOption;
  var
    i : integer;
    aStrike : TStrike;
    stSrc, stDsc : string;
    FOptionMarket : TOptionMarket;
begin
  Result := nil;
  FOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  if FOptionMarket = nil then Exit;  

  stSrc := Format('%.2f', [ dStrikePrice ] );

  for i := 0 to FOptionMarket.Trees.FrontMonth.Strikes.Count-1 do
  begin
    aStrike := FOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    stDsc := Format('%.2f', [ aStrike.StrikePrice ] );

    if CompareStr( stDsc, stSrc ) = 0 then
    begin
      if bCall then
        Result := aStrike.Put
      else
        Result := aStrike.Call;

      break;
    end;
  end;
end;
function TSymbolCore.GetSymbolInfo: boolean;
var
  I: Integer;
  aSymbol : TSymbol;
  stUnder, stData : string;
begin
 {
  Result := false;

  for I := 0 to FSymbols.Count - 1 do
  begin
    aSymbol := FSymbols.Symbols[i];
    if (aSymbol is TIndex) or
      (aSymbol is TBond ) or
      (aSymbol is TDollar) then Continue;

    case aSymbol.UnderlyingType of
      utKospi200: stUnder := K2I;
      utMiniKospi200: stUnder := MKI;
      utDollar: stUnder := USD;
      utBond3: stUnder := BM3;
      utBond10: stUnder := BM5;
      else continue;
    end;
    // 3, 12, 4
    stData := Format('%3.3s%12.12s%-4.4d', [ stUnder, aSymbol.Code, aSymbol.Seq ]);

   // if not gEnv.Engine.Api.RequestSymbolInfo( REQ_SYMBOL_INF, i, stData ) then
   //   gEnv.EnvLog( WIN_TEST, '???? ???????? : '+ IntToStr(i) +','+stData );
    if not gEnv.Engine.Api.RequestSymbolInfo( REQ_SYMBOL_LIMIT, i, stData ) then
      gEnv.EnvLog( WIN_TEST, '???? ???????????? : '+ IntToStr(i) +','+stData );

    if (i mod 20 ) = 0 then sleep(1);
  end;

  Result := true;
  }
end;


function SortDate(Item1, Item2: Pointer): Integer;
var
  iDate1 , iDate2 : integer;
begin
  iDate1 := Floor( TFuture( Item1).ExpDate );
  iDate2 := Floor( TFuture( Item2).ExpDate );

  if iDate1 < iDate2 then
    Result := 1
  else if iDate1 > iDate2 then
    Result := -1
  else
    Result := 0;
end;

procedure TSymbolCore.MarketsSort;
var
  i : integer;
  aFutMarket : TFutureMarket;
  aOptMarket : TOptionMarket;
begin
  for I := 0 to FutureMarkets.Count - 1 do
  begin
    aFutMarket := FutureMarkets.FutureMarkets[i];

    if aFutMarket.FQN = FQN_KOSPI200_FUTURES then
      FFuture := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_MINI_KOSPI200_FUTURES then
      FMiniFuture := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_KRX300_FUTURES then
      FKrxFuture := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_YEN_FUTURES then
      FJpyFuture := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_DOLLAR_FUTURES then
      FUsFuture := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_BOND3_FUTURES then
      FBond3Future  := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_BOND5_FUTURES then
      FBond5Future  := aFutMarket.FrontMonth
    else if aFutMarket.FQN = FQN_BOND10_FUTURES then
      FBond10Future  := aFutMarket.FrontMonth;

{$IFDEF NH_FUT}
    if aFutMarket.FQN = FQN_KOSDAQ150_FUTURES then
      FKD150Future := aFutMarket.FrontMonth;
{$ENDIF}
  end;

  //??????, ???? ???????? ????.

  if FUsFuture <> nil then
    if FUsFuture.DaysToExp = 1 then
      FUsFuture := GetNextMonth( FUsFuture.Spec );

  if FBond10Future <> nil then
    if FBond10Future.DaysToExp = 1 then
      FBond10Future := GetNextMonth( FBond10Future.Spec );

  if FBond3Future <> nil then
    if FBond3Future.DaysToExp = 1 then
      FBond3Future := GetNextMonth( FBond3Future.Spec );

{$ifdef DEBUG}
{$ENDIF}

  if FFuture <> nil then  begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FFuture, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('????????     : %s, %s', [ FFuture.ShortCode, FFuture.Name])   );
  end;

  if FKRxFuture <> nil then  begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FKRxFuture, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('KRX300????     : %s, %s', [ FKRxFuture.ShortCode, FKRxFuture.Name])   );
  end;

  if FMiniFuture <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FMiniFuture, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('???????????? : %s, %s', [ FMiniFuture.ShortCode, FMiniFuture.Name])   );
  end;

  if FUsFuture <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FUsFuture, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('????????     : %s, %s', [ FUsFuture.ShortCode, FUsFuture.Name])   );
  end;

  if FJpyFuture <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FJpyFuture, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('??????       : %s, %s', [ FJpyFuture.ShortCode, FJpyFuture.Name])   );
  end;

  if FBond3Future <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FBond3Future, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('3????        : %s, %s', [ FBond3Future.ShortCode, FBond3Future.Name])   );
  end;

  if FBond5Future <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FBond5Future, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('5????        : %s, %s', [ FBond5Future.ShortCode, FBond5Future.Name])   );
  end;

  if FBond10Future <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FBond10Future, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('10????       : %s, %s', [ FBond10Future.ShortCode, FBond10Future.Name])   );
  end;

{$IFDEF NH_FUT}
  if FKD150Future <> nil then begin
    gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
      FKD150Future, gEnv.Engine.QuoteBroker.DummyEventHandler, true  );
    gEnv.EnvLog( WIN_TEST, Format('KD150        : %s, %s', [ FKD150Future.ShortCode, FKD150Future.Name])   );
  end;
{$ENDIF}

  for I := 0 to OptionMarkets.Count - 1 do
  begin
    aOptMarket  := OptionMarkets.OptionMarkets[i];
    if aOptMarket.FQN = FQN_KOSPI200_OPTION then
      FMonthlyItem      := aOptMarket
    else if aOptMarket.FQN = FQN_MINI_KOSPI200_OPTION then
      FMiniMonthlyItem  := aOptMarket;
  end;

  gEnv.Engine.SendBroker.ReqInvestData( 'K2I', 'O');
  gEnv.Engine.SendBroker.ReqInvestData( 'K2I', 'F');
  
{$IFDEF KR_FUT}
  for I := 0 to Symbols.Count - 1 do
    Symbols.Symbols[i].No := i;

  GetChartData;

{$ENDIF}

end;

procedure TSymbolCore.OptionPrint;
var

  aTree: TOptionTree;
  j,i: Integer;
  aStrike: TStrike;
  stData : string;
  aFutMarket : TFutureMarket;
  aOptMarket : TOptionMarket;
  aGroup : TMarketGroup;
  aSymbol : TSymbol;
  aMarket : TMarket;
begin

  exit;

  for I := 0 to Underlyings.Count - 1 do
  begin
    aGroup := Underlyings.Groups[i];
    for j := 0 to aGroup.Markets.Count - 1 do
    begin
      aMarket := aGroup.Markets.Markets[j];
      stData  := Format('Under %d(%d), %s, %s, %s ', [
        i,j, aMarket.FQN, aMarket.Spec.FQN, aGroup.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );

  for I := 0 to Exchanges.Count - 1 do
  begin
    aGroup := Exchanges.Groups[i];
    for j := 0 to aGroup.Markets.Count - 1 do
    begin
      aMarket := aGroup.Markets.Markets[j];
      stData  := Format('Exchanges %d(%d), %s, %s, %s ', [
        i,j, aMarket.FQN, aMarket.Spec.FQN, aGroup.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );

  for I := 0 to Sectors.Count - 1 do
  begin
    aGroup := Sectors.Groups[i];
    for j := 0 to aGroup.Markets.Count - 1 do
    begin
      aMarket := aGroup.Markets.Markets[j];
      stData  := Format('Sectors %d(%d), %s, %s, %s ', [
        i,j, aMarket.FQN, aMarket.Spec.FQN, aGroup.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );

  for I := 0 to FutureMarkets.Count - 1 do
  begin
    aFutMarket := FutureMarkets.FutureMarkets[i];
    for j := 0 to aFutMarket.Symbols.Count - 1 do
    begin
      aSymbol := aFutMarket.Symbols.Symbols[j];
      stData  := Format('fut %d(%d), %s, %s, (%s) ', [
        i,j, aSymbol.ShortCode, aSymbol.Name, aSymbol.Spec.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );

  for I := 0 to optionMarkets.Count - 1 do
  begin
    aOptMarket := optionMarkets.OptionMarkets[i];
    for j := 0 to aOptMarket.Symbols.Count - 1 do
    begin
      aSymbol := aOptMarket.Symbols.Symbols[j];
      stData  := Format('opt %d(%d), %s, %s, (%s) ', [
        i,j, aSymbol.ShortCode, aSymbol.Name, aSymbol.Spec.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  {
  gEnv.EnvLog( WIN_TEST, FormatDateTime('yyyy-mm-dd', GetQuoteTime )
    , true, '????2 ????.csv');

  gEnv.EnvLog( WIN_TEST, FormatDateTime('yyyy-mm-dd', GetQuoteTime )
    , true, '???????? ??????.csv');
  }
  {
  for j := 0 to OptionMarkets.Count - 1 do
  begin

    aTree := OptionMarkets.OptionMarkets[j].Trees.FrontMonth;
    for i := 0 to aTree.Strikes.Count - 1 do
    begin
      aStrike := aTree.Strikes[i];
      stData  := Format('%d(%d) %.2f, %.2f, %.2f, %.2f,' +
                        '%.2f,' +
                        '%.2f, %.2f, %.2f, %.2f, %s',
                        [ j,i,
                          aStrike.Call.PrevOpen,
                          aStrike.Call.PrevHigh,
                          aStrike.Call.PrevLow,
                          astrike.Call.Last,
                          astrike.StrikePrice ,
                          aStrike.Put.PrevOpen,
                          aStrike.Put.PrevHigh,
                          aStrike.Put.PrevLow,
                          astrike.Put.Last,
                          aStrike.Call.Spec.FQN
                        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;
  }
end;





end.
