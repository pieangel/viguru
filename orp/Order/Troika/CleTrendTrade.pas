unit CleTrendTrade;

interface

uses
  Classes, SysUtils, Math,

  GleTypes,

  CleSymbols, CleOrders, CleQuotebroker, CleDistributor, CleQuoteTimers,

  CleAccounts, ClePositions , CleKrxSymbols, CleInvestorData
  ;

type

  TTrendParam = record
    StartTime : TDateTime;
    EndTime   : TDateTime;

    StartTime2: TDateTime;
    EndTime2  : TDateTime;

    UseFut    : boolean;
    FutIdx    : integer;
    // 구분
    UseTrd1   : boolean;
    Trd1UseCnt: boolean;
    UseTrd2   : boolean;
    UseTrdStop: boolean;
    // 일반 추세
    OrdQty1    : integer;
    OrdCon1    : array [TPositionType] of double;
    BasePrice1 : array [TPositionType] of double;
    SymbolCnt1 : array [TPositionType] of integer;
    OrdCnt1    : array [TPositionType] of integer;
    LiqCon1    : array [TPositionType] of double;
    OtrCon1    : array [TPositionType] of double;
    // 투자자 추세
    OrdQty2    : integer;
    OrdCon2    : array [TPositionType] of double;
    BasePrice2 : array [TPositionType] of double;
    SymbolCnt2 : array [TPositionType] of integer;
    OrdCnt2    : array [TPositionType] of integer;
    LiqCon2    : array [TPositionType] of double;
    OtrCon2    : array [TPositionType] of double;
    UseCnt     : boolean;
    LiskAmt2   : double;
    // platoon 2019.02.19
    UsePlatoon : boolean;
    PlatoonPoint  : double;
    UseReverse : boolean;
  end;

  TTrendResult = class
  public
    OrdDir  : integer;
    OrdCnt  : array [TPositionType] of integer;
    MaxAmt  : double;
    MinAmt  : double;
    procedure init;
  end;

  // 주문낸 종목들
  TOrderedItem = class( TCollectionItem )
  public
    Ready  : boolean;
    Last   : double;
    Symbol : TSymbol;
    Order  : TOrder;
    LiqOrder: TOrder;
    OrdRes : TTrendResult;
    stType : TStrategyType;
    ManualQty : integer; // 수동 청산 수량..
    Reverse : boolean;
    Constructor Create( aColl : TCollection ) ; override;
  end;

  TTrendOrderEvent = procedure ( aItem : TOrderedItem; iDiv : integer ) of object;

  TOrderedItems = class( TCollection )
  private
    function GetOrdered(i: Integer): TOrderedItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aOrder : TOrder ) : TOrderedItem;
    procedure Del( aOrder: TOrder );

    property Ordered[i : Integer] : TOrderedItem read GetOrdered;
  end;

  TTrendTrade = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FRun: boolean;
    FAccount: TAccount;
    FLossCut : boolean;
    FParam: TTrendParam;

    FOrdRes2: TTrendResult;
    FOrdRes1: TTrendResult;

    FCallPerson : TInvestorData;
    FPutPerson  : TInvestorData;

    FCallFinance: TInvestorData;
    FPutFinance : TInvestorData;

    FOnTrendNotify: TTrendDataNotifyEvent;

    FOrdRes3: TTrendResult;
    FOrdRes4: TTrendResult;
    FOrders: TOrderedItems;
    FQuote: TQuote;
    FInvestCode: string;
    FOnTrendOrderEvent: TTrendOrderEvent;
    FOnTrendResultNotify: TResultNotifyEvent;
    FMulti: integer;

    FReadyItem: TOrderedItem;
    FOrdDir: integer;
    FPlatoonFlag: boolean;


    function IsRun : boolean;
    procedure Reset ;
    procedure OnQuote(aQuote: TQuote);
    procedure CheckFutTrend(aQuote: TQuote);
    procedure CheckTrend1(aQuote: TQuote);
    procedure CheckTrend1_2(aQuote: TQuote);
    procedure CheckTrend2(aQuote: TQuote);

    procedure DoLog( stLog : string );
    function DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
    function CheckInvestData : boolean;
    //procedure CheckLiquid1(aQuote: TQuote);
    //procedure CheckLiquid2(aQuote: TQuote);

    procedure CheckLiskAmt;

    function CheckLiquid1( aItem : TOrderedITem ) : boolean;
    function CheckLiquid1_2( aItem : TOrderedITem ) : boolean;
    function CheckLiquid2( aItem : TOrderedITem ) : boolean;

    function GetOrdRes(aQuote: TQuote; stType : TStrategyType): TTrendResult;
    procedure CheckLiquid( aType : TStrategyType = stTrend);
    procedure NewOrder(iQty, iSide: integer; aQuote: TQuote;
      aOrdRes: TTrendResult; dTmp: double; stType : TStrategyType);
    function GetOption(cDiv: char; dPrice: double): TQuote;
    function GetMarket(aSymbol: TSymbol): string;
    procedure Save;
    function calcLiquidGap(dAmt,dDiv : double; iSide : integer): double;
    function GetFuture: TQuote;
    procedure CheckReadyItem;
    procedure CheckReadyOrder;
    function GetUpDown: integer;
    procedure CheckPlatoon;
    function IsValidPrevData: boolean;

  public

    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;

    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;
    function Start : boolean;
    Procedure Stop;
    function DoManualOrder( iQty : integer; aItem : TOrderedItem ) : boolean;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    property Symbol  : TSymbol read FSymbol;  // 최근월물..
    property Quote   : TQuote  read FQuote;
    property Account : TAccount read FAccount;
    property Orders  : TOrderedItems read FOrders;
    //
    property Multi   : integer read FMulti write FMulti;

    property Param   : TTrendParam read FParam write FParam;
    property InvestCode : string read FInvestCode write FInvestCode;

    property OrdRes1  : TTrendResult read FOrdRes1 write FOrdRes1;
    property OrdRes2  : TTrendResult read FOrdRes2 write FOrdRes2;
    property OrdRes3  : TTrendResult read FOrdRes3 write FOrdRes3;
    property OrdRes4  : TTrendResult read FOrdRes4 write FOrdRes4;

    property ReadyItem: TOrderedItem read FReadyItem write FReadyItem;

    property Run : boolean read FRun write FRun;
    property OnTrendNotify : TTrendDataNotifyEvent read FOnTrendNotify write FOnTrendNotify;
    property OnTrendOrderEvent : TTrendOrderEvent read FOnTrendOrderEvent write FOnTrendOrderEvent;
    property OnTrendResultNotify: TResultNotifyEvent read FOnTrendResultNotify write FOnTrendResultNotify;

    property OrdDir     : integer read FOrdDir     write FOrdDir;
    property PlatoonFalg : boolean read FPlatoonFlag;  // false 면 진입 금
  end;


  TTrendTrades = class( TCollection )
  private
    function GetTrend(i: integer): TTrendTrade;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( stCode : string ) : TTrendTrade;
    function Find(  stCode : string ) : TTrendTrade;
    property Trend[ i : integer] : TTrendTrade read GetTrend;
  end;

implementation

uses
  GAppEnv, GleLib, GleConsts

  ;

{ TTrendTrade }

constructor TTrendTrade.Create( aColl : TCollection );
begin
  inherited Create( aColl );
  FRun  := false;
  FSymbol := nil;
  FAccount:= nil;
  FMulti  := 1;
  FPlatoonFlag := true;

  FOrders:= TOrderedItems.Create;
  FReadyItem:= TOrderedItem.Create( nil );

  FOrdRes1 := TTrendResult.Create;
  FOrdRes2 := TTrendResult.Create;
  FOrdRes3 := TTrendResult.Create;
  FOrdRes4 := TTrendResult.Create;
end;

destructor TTrendTrade.Destroy;
begin

  FOrdRes1.Free;
  FOrdRes2.Free;
  FOrdRes3.Free;
  FOrdRes4.Free;

  FOrders.Free;
  FReadyItem.Free;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

procedure TTrendTrade.DoLog(stLog: string);
begin
  if FAccount <> nil then
    gEnv.EnvLog( WIN_INV, stLog, false,
      Format('%s_%s', [ Account.Code, ifThenStr( FParam.UseFut,'선물','옵션')]) );
end;

function TTrendTrade.DoManualOrder(iQty: integer; aItem: TOrderedItem): boolean;
var
  iOrdQty, iTmp : integer;
  aOrder  : TOrder;
begin
  Result := false;
  if aItem = nil then Exit;

  if ( aItem.Order.State = osFilled ) and ( aItem.Order.FilledQty > 0 ) then
  begin     {
    iTmp := aItem.ManualQty + iQty;
    if iTmp > aItem.Order.FilledQty then
      iOrdQty := 0
    else if iTmp <= aItem.Order.FilledPrice then
    }
    //  iOrdQty := iQty;

    if iQty > 0 then
    begin
      aOrder  := DoOrder( iQty , -aItem.OrdRes.OrdDir, aItem.Symbol.Quote as TQuote );
      if aOrder <> nil then
      begin
        Result := true;

        DoLog( Format('추세%d %s %s 매뉴얼 청산 -> %s, %s, %.2f, %d )',
               [ ifThen( aItem.stType = stTrend, 1,2 ),  GetMarket( aItem.Symbol ),
                ifThenStr( aItem.Order.Side > 1,'매수','매도'), aOrder.Symbol.ShortCode,
                ifThenStr( aOrder.Side > 1,'매수','매도'), aOrder.Price, aOrder.OrderQty   ]));
        aItem.OrdRes.OrdDir   := 0;
        FOrders.Del( aItem.Order );
      end;
      //////////
    end;
  end;
end;

function TTrendTrade.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  Result := false;
  if (aAcnt = nil) or ( aSymbol = nil ) then Exit;

  FSymbol   := aSymbol;
  FAccount  := aAcnt;

  Result := true;
  Reset;

end;

function TTrendTrade.IsRun: boolean;
begin
  if ( not Run) or  (FAccount = nil) or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TTrendTrade.Save;
var
  stData, stFile : string;
  dTot, dFut, dOpt, dS : double;
begin
  if Account = nil then Exit;

  stFile  := Format('%s_Trend_%s_%s.csv', [ FormatDateTime('yyyy-mm-dd', gEnv.AppDate ),
      ifThenStr( FParam.UseFut,'fut','opt'),  Account.Code ] );

  dTot := dTot
      + gEnv.Engine.TradeCore.Positions.GetMarketPl( Account, dFut, dOpt, dS  );

  stData  := Format('%.0f ', [ ( dTot / 1000) - ( Account.GetFee / 1000 )] );
  gEnv.EnvLog( WIN_INV, stData, false, stFile);

end;

function TTrendTrade.IsValidPrevData : boolean;
begin
  result := false;
  if (FSymbol.PrevHigh <= PRICE_EPSILON )  or ( FSymbol.PrevLow <= PRICE_EPSILON)  then
  begin
    DoLog( Format('플래툰 데이타 이상 ,  전일고저 (%s - %s )',
      [ FSymbol.PriceToStr( FSymbol.PrevHigh)  , FSymbol.PriceToStr(FSymbol.PrevLow ) ])      );
    Exit;
  end else
  result := true;
end;

procedure TTrendTrade.CheckPlatoon;
var
  dPrev : double;
begin
  if not IsValidPrevData then Exit;

  dPrev   := FSymbol.PrevHigh  - FSymbol.PrevLow;
  if ( dPrev < 0 ) then   Exit;

  // 시작 하고 바로 결정 됨..
  if (dPrev -PRICE_EPSILON ) > FParam.PlatoonPoint  then  begin
    FPlatoonFlag := false;
    DoLog(   Format('(전일고저) %s (%s - %s) > %s  :   진입 %s ', [
      FSymbol.PriceToStr( dPrev ) , FSymbol.PriceToStr(FSymbol.PrevHigh)  , FSymbol.PriceToStr(FSymbol.PrevLow ),
      FSymbol.PriceToStr( FParam.PlatoonPoint ),  ifThenStr( FPlatoonFlag , '있음','없음')
      ]));

    if Assigned( FOnTrendNotify ) then
      FOnTrendNotify( Self, '플래툰진입금지', 2 );
  end
  else
    FPlatoonFlag := true;


end;

procedure TTrendTrade.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin
  if (not IsRun) or (DataObj = nil)  or ( Receiver <> Self ) then Exit;
  aQuote  := DataObj as TQuote;

  if DataID = 300 then
  begin
    Save;
  end else
  if (DataID = CHART_DATA) and ( FParam.UsePlatoon ) then
  begin
    CheckPlatoon;
  end;

  if ( FParam.UsePlatoon ) and ( FPlatoonFlag ) then
    CheckPlatoon;

  if ( FParam.UsePlatoon ) and ( not FPlatoonFlag ) then Exit;

  if FLossCut then Exit;

  if aQuote.AddTerm then
    OnQuote( aQuote );

  CheckLiskAmt;
  {
  // 투자자 데이터 를 통한  추세
  if FParam.UseTrd2 then
  begin
    CheckTrend2( aQuote );
    CheckLiquid( stInvestor );
  end;
  }

  CheckReadyOrder;

end;

procedure TTrendTrade.Reset;
begin
  FOrdRes1.init;
  FOrdRes2.init;
  FOrdRes3.init;
  FOrdRes4.init;

  FQuote  := nil;

  FCallPerson := nil;
  FPutPerson  := nil;
  FCallFinance:= nil;
  FPutFinance := nil;

  FLossCut  := false;
  FOrdDir     := 0;

  FPlatoonFlag := true;
end;

function TTrendTrade.Start: boolean;
begin
  Result := IsRun;
  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  FRun  := true;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, CHART_DATA, QuotePrc);
  gEnv.Engine.SendBroker.RequestSymbolInfo2( FSymbol );

  if FQuote = nil then
    Exit;

  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  DoLog('start ' );
end;

procedure TTrendTrade.Stop;
begin
  FRun  := false;
  DoLog('stop ' );
end;

procedure TTrendTrade.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aOrder : TOrder;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
    ORDER_FILLED:
      begin
        if DataObj = nil then Exit;
        aOrder  := DataObj as TOrder;

        if ( aOrder.State = osFilled ) and ( aOrder.Account = FAccount ) then
          if Assigned( FOnTrendResultNotify ) then
            FOnTrendResultNotify( aOrder, true );

      end;
  end;
end;

procedure TTrendTrade.OnQuote( aQuote : TQuote );
begin
  // 헐트헤지
 // if FParam.UseFut then
  CheckFutTrend( aQuote );
  // 옵션 추세
  //else
  //  CheckOptTrend;

  CheckLiquid;
end;

procedure TTrendTrade.CheckFutTrend( aQuote : TQuote );
begin
  // 일반 추세
  if FParam.UseTrd1 then begin
    if FParam.Trd1UseCnt then
      CheckTrend1( aQuote )
    else
      CheckTrend1_2( aQuote );
  end;

  // 투자자 데이터 를 통한  추세
  if FParam.UseTrd2 then
  begin
    CheckTrend2( aQuote );
    CheckReadyItem ;
  end;

end;

function TTrendTrade.GetOrdRes( aQuote : TQuote; stType : TStrategyType ) : TTrendResult;
begin
  // 선물일때
  // trend1 : ordRes1 , trend2 : ordres2
  // 옵션일때
  // trend1 call : ordRes1 , trend1 put : ordres2
  // trend2 call : ordRes3 , trend2 put : ordres4

  case stType of
    stTrend:
      begin
        if FParam.UseFut then
          Result := FOrdRes1
        else begin
          if aQuote.Symbol.ShortCode[1] = '2' then
            Result := FOrdRes1
          else
            Result := FOrdRes2;
        end;
      end;
    stInvestor:
      begin
        if FParam.UseFut then
          Result := FOrdRes2
        else begin  // 상승의 경우들.. (투자자에서만 )
          if ((aQuote.Symbol.ShortCode[1] = '3') and ( not FParam.UseReverse ))
              or
             ((aQuote.Symbol.ShortCode[1] = '2') and (FParam.UseReverse )) then
            Result := FOrdRes4
          else
            Result := FOrdRes3;
        end;
      end;
  end;

end;

function TTrendTrade.GetOption( cDiv : char; dPrice : double) : TQuote;
var
  arList : TList;
  aSymbol: TSymbol;
begin
  try
    Result := nil;
    arList  := TList.Create;

    if cDiv = 'C' then
      gEnv.Engine.SymbolCore.GetCurCallList( dPrice, 0, 10, arList, FParam.FutIdx = 1 )
    else
      gEnv.Engine.SymbolCore.GetCurPutList( dPrice, 0, 10, arList, FParam.FutIdx = 1 );

    if arList.Count > 0 then
    begin
      aSymbol := TSymbol( arList.Items[0] );
      if aSymbol.Quote <> nil then
        Result := aSymbol.Quote as TQuote ;
    end;
  finally
    arList.free;
  end;
end;

function TTrendTrade.GetFuture : TQuote;
begin
  case FParam.FutIdx of
    0 : Result  := gEnv.Engine.SymbolCore.Future.Quote as TQuote;
    1 : Result  := gEnv.Engine.SymbolCore.MiniFuture.Quote as TQuote;
    else Result := nil;
  end;
end;

// 일반 추세 1  - 건수
procedure TTrendTrade.CheckTrend1( aQuote : TQuote );
var
  dTmp : double;
  iSide, iCnt, iQty, iLS : integer;
  aOrder  : TOrder;
  stData, stTmp  : string;

  dtEndTime : TDateTime;
  aOrdRes : TTrendResult;
  aItem   : TOrderedItem;
begin

  try

  if Frac( FParam.StartTime ) > Frac( GetQuoteTime ) then Exit;

  dtEndTime := Frac( FParam.EndTime );
  if Frac( GetQuoteTime ) > dtEndTime then
    Exit;

  iSide := 0;
  iLS   := 0;
  iQty  := FParam.OrdQty1;

  /////////////////////////////////////////////////////////////////////////////
  ///   상승
  ///
  if FQuote.Bids.CntTotal > FQuote.Asks.CntTotal then
  begin
    if (FParam.UseFut) then
    begin

      aQuote  := GetFuture;
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir <> 0 then Exit;

        if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
          DoLog( Format('상승 추세1 선물 매수 주문 카운트 Over %d', [  aOrdRes.OrdCnt[ptLong] ]))
        else begin

          dTmp  := FQuote.Bids.CntTotal * FParam.OrdCon1[ptLong];
          if dTmp > FQuote.Asks.CntTotal then begin
            NewOrder( iQty, 1, aQuote, aOrdRes, dTmp, stTrend);
            DoLog( Format('상승 추세1 선물 매수 주문 -> 매수건수 * %.2f  > 매도건수 ( %.1f(%d) >  %d )',
              [ FParam.OrdCon1[ptLong], dTmp, FQuote.Bids.CntTotal, FQuote.Asks.CntTotal    ]));
          end;

        end;
      end;
    end
    else begin

      // 콜매수(0.7),
      aQuote := GetOption('C',FParam.BasePrice1[ptLong]);
      if (aQuote <> nil)  and (( aQuote.Symbol.ShortCode[1] = '2') or ( aQuote.Symbol.ShortCode[1] = '1')) then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
            DoLog( Format('상승 추세1 콜 매수 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
          else begin
            dTmp  := FQuote.Bids.CntTotal * FParam.OrdCon1[ptLong];
            if dTmp > FQuote.Asks.CntTotal then begin
              NewOrder( iQty, 1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('상승 추세1 콜 매수 주문 -> 매수건수 * %.2f  > 매도건수 ( %.1f(%d) >  %d )',
              [ FParam.OrdCon1[ptLong], dTmp, FQuote.Bids.CntTotal, FQuote.Asks.CntTotal    ]));
            end;
          end;
        end;
      end;
      // 풋매도(1);
      aQuote := GetOption('P',FParam.BasePrice1[ptShort]);
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
            DoLog( Format('상승 추세1 풋 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptShort] ]))
          else begin
            dTmp  := FQuote.Bids.CntTotal * FParam.OrdCon1[ptShort];
            if dTmp > FQuote.Asks.CntTotal then begin
              NewOrder( iQty, -1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('상승 추세1 풋 매도 주문 -> 매수건수 * %.2f  > 매도건수 ( %.1f(%d) >  %d )',
              [ FParam.OrdCon1[ptShort], dTmp, FQuote.Bids.CntTotal, FQuote.Asks.CntTotal    ]));
            end;
          end;
        end;
      end;

    end;

  end else
  /////////////////////////////////////////////////////////////////////////////
  ///   하락
  ///
  if FQuote.Asks.CntTotal > FQuote.Bids.CntTotal then
  begin
    if (FParam.UseFut) then
    begin
      aQuote  := GetFuture;
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir <> 0 then Exit;
        if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
          DoLog( Format('하락 추세1 선물 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
        else begin
          dTmp  := FQuote.Asks.CntTotal * FParam.OrdCon1[ptShort];
          if dTmp > FQuote.Bids.CntTotal then begin
            NewOrder( iQty, -1, aQuote, aOrdRes, dTmp , stTrend);
            DoLog( Format('하락 추세1 선물 매도 주문 -> 매도건수 * %.2f  > 매수건수 ( %.1f(%d) >  %d )',
            [ FParam.OrdCon1[ptShort], dTmp, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal ]));
          end;
        end;
      end;
    end
    else begin
      // 콜매도
      aQuote := GetOption('C',FParam.BasePrice1[ptShort]);
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
            DoLog( Format('하락 추세1 콜 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptShort] ]))
          else begin
            dTmp  := FQuote.Asks.CntTotal * FParam.OrdCon1[ptShort];
            if dTmp > FQuote.Bids.CntTotal then begin
              NewOrder( iQty, -1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('하락 추세1 콜 매도 주문 -> 매도건수 * %.2f  > 매수건수 ( %.1f(%d) >  %d )',
              [ FParam.OrdCon1[ptShort], dTmp, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal    ]));
            end;
          end;
        end;
      end;

      // 풋매수
      aQuote := GetOption('P',FParam.BasePrice1[ptLong]);
      if (aQuote <> nil) and ( aQuote.Symbol.ShortCode[1] = '3')  then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
            DoLog( Format('하락 추세1 풋 매수 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
          else begin
            dTmp  := FQuote.Asks.CntTotal * FParam.OrdCon1[ptLong];
            if dTmp > FQuote.Bids.CntTotal then begin
              NewOrder( iQty, 1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('하락 추세1 풋 매수 주문 -> 매도건수 * %.2f  > 매수건수 ( %.1f(%d) >  %d )',
              [ FParam.OrdCon1[ptLong], dTmp, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal  ]));
            end;
          end;
        end;
      end;

    end;
  end;


  finally

  if FQuote.Bids.CntTotal > FQuote.Asks.CntTotal then begin
    iLs  := 1;
    if FQuote.Bids.CntTotal = 0 then
      stTmp := '1'
    else
      stTmp := Format('%.2f', [  FQuote.Asks.CntTotal/ FQuote.Bids.CntTotal  ])
  end
  else begin
    iLs := -1;
    if FQuote.Asks.CntTotal = 0 then
      stTmp := '1'
    else
      stTmp := Format('%.2f', [  FQuote.Bids.CntTotal/ FQuote.Asks.CntTotal  ])
  end;


  stData  := Format( '%s, %s, [ %d,%d ]', [ ifThenStr( iLS > 0, '상승','하락' ),   stTmp,
    FQuote.Bids.CntTotal ,FQuote.Asks.CntTotal ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 1 );

  end;

end;

// 잔량
procedure TTrendTrade.CheckTrend1_2(aQuote: TQuote);
var
  dTmp : double;
  iCnt, iQty : integer;
  aOrder  : TOrder;
  stData, stTmp  : string;

  dtEndTime : TDateTime;
  aOrdRes : TTrendResult;
  aItem   : TOrderedItem;
begin

  try

  if Frac( FParam.StartTime ) > Frac( GetQuoteTime ) then Exit;

  dtEndTime := Frac( FParam.EndTime );
  if Frac( GetQuoteTime ) > dtEndTime then
    Exit;

  iQty  := FParam.OrdQty1;

  dTmp  := FQuote.Bids.VolumeTotal - FQuote.Asks.VolumeTotal;

  /////////////////////////////////////////////////////////////////////////////
  ///   상승
  ///
  if dTmp > 0 then
  begin
    if (FParam.UseFut) then
    begin

      aQuote  := GetFuture;
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir <> 0 then Exit;

        if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
          DoLog( Format('상승 추세1 선물 매수 주문 카운트 Over %d', [  aOrdRes.OrdCnt[ptLong] ]))
        else begin

            if dTmp > FParam.OrdCon1[ptLong] then begin
              NewOrder( iQty, 1, aQuote, aOrdRes, dTmp, stTrend);
              DoLog( Format('상승 추세1 선물 매수 주문(잔량) -> %.0f < (%.0f  = %d - %d )',
                [ FParam.OrdCon1[ptLong], dTmp, FQuote.Bids.VolumeTotal, FQuote.Asks.VolumeTotal   ]));
            end;

        end;
      end;
    end
    else begin
      // 콜매수(0.7),  그리드에서 매수 조건
      aQuote := GetOption('C',FParam.BasePrice1[ptLong]);
      if (aQuote <> nil)  and (( aQuote.Symbol.ShortCode[1] = '2') or ( aQuote.Symbol.ShortCode[1] = '1')) then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
            DoLog( Format('상승 추세1 콜 매수 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
          else begin
            if dTmp > FParam.OrdCon1[ptLong] then begin
              NewOrder( iQty, 1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('상승 추세1 콜 매수 주문(잔량) -> %.0f < (%.0f  = %d - %d )',
                [ FParam.OrdCon1[ptLong], dTmp, FQuote.Bids.VolumeTotal, FQuote.Asks.VolumeTotal   ]));
            end;
          end;
        end;
      end;
      // 풋매도(1);   그리드에서 매도 조건
      aQuote := GetOption('P',FParam.BasePrice1[ptShort]);
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
            DoLog( Format('상승 추세1 풋 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptShort] ]))
          else begin
            if dTmp > FParam.OrdCon1[ptShort] then begin
              NewOrder( iQty, -1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('상승 추세1 풋 매도 주문(잔량) -> %.0f < (%.0f  = %d - %d )',
              [ FParam.OrdCon1[ptShort], dTmp, FQuote.Bids.VolumeTotal, FQuote.Asks.VolumeTotal     ]));
            end;
          end;
        end;
      end;

    end;

  end else
  /////////////////////////////////////////////////////////////////////////////
  ///   하락
  ///
  if dTmp < 0 then
  begin
    if (FParam.UseFut) then
    begin
      aQuote  := GetFuture;
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir <> 0 then Exit;
        if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
          DoLog( Format('하락 추세1 선물 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
        else begin

          if abs(dTmp) > FParam.OrdCon1[ptShort] then begin
            NewOrder( iQty, -1, aQuote, aOrdRes, dTmp , stTrend);
            DoLog( Format('하락 추세1 선물 매도 주문(잔량) -> %.0f < (%.0f  = %d - %d )',
            [ FParam.OrdCon1[ptShort], abs(dTmp), FQuote.Asks.VolumeTotal, FQuote.Bids.VolumeTotal ]));
          end;
        end;
      end;
    end
    else begin
      // 콜매도
      aQuote := GetOption('C',FParam.BasePrice1[ptShort]);
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
            DoLog( Format('하락 추세1 콜 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptShort] ]))
          else begin
            if abs(dTmp) > FParam.OrdCon1[ptShort] then begin
              NewOrder( iQty, -1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('하락 추세1 콜  매도 주문(잔량) -> %.0f < (%.0f  = %d - %d )',
            [ FParam.OrdCon1[ptShort], abs(dTmp), FQuote.Asks.VolumeTotal, FQuote.Bids.VolumeTotal ]));
            end;
          end;
        end;
      end;

      // 풋매수
      aQuote := GetOption('P',FParam.BasePrice1[ptLong]);
      if (aQuote <> nil) and ( aQuote.Symbol.ShortCode[1] = '3')  then
      begin
        aOrdRes := GetOrdRes( aQuote, stTrend );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
            DoLog( Format('하락 추세1 풋 매수 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
          else begin
           if abs(dTmp) > FParam.OrdCon1[ptShort] then begin
              NewOrder( iQty, 1, aQuote, aOrdRes, dTmp, stTrend );
              DoLog( Format('하락 추세1 풋  매수 주문(잔량) -> %.0f < (%.0f  = %d - %d )',
            [ FParam.OrdCon1[ptLong], abs(dTmp), FQuote.Asks.VolumeTotal, FQuote.Bids.VolumeTotal ]));
            end;
          end;
        end;
      end;

    end;
  end;


  finally

  stData  := Format( '%s, %.0f, [ %d,%d ]', [ ifThenStr( dTmp > 0, '상승','하락' ),   dTmp,
    FQuote.Bids.VolumeTotal, FQuote.Asks.VolumeTotal  ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 1 );

  end;

end;



procedure TTrendTrade.NewOrder( iQty, iSide : integer; aQuote : TQuote;
   aOrdRes : TTrendResult; dTmp : double; stType : TStrategyType );
var
  aOrder : TOrder;
  aItem  : TOrderedItem;
begin
  // aQuote 는 주문낼 종목
  // FQuote 는 최근월물
  // Fund 를 위해 승수 추가..


  if iSide <> 0 then
  begin

    if stType = stInvestor  then
    begin

      aOrdRes.OrdDir  := iSide;
      aOrdRes.MaxAmt := dTmp;
      aOrdRes.MinAmt := dTmp;

      FReadyItem.Ready  := true;
      FReadyItem.Symbol := aQuote.Symbol;
      FReadyItem.OrdRes := aOrdRes;
      FReadyItem.stType := stType;
      FReadyItem.Last   := FQuote.Last;
      FReadyItem.Reverse:= FParam.UseReverse;

      if Assigned( FOnTrendOrderEvent ) then
        FOnTrendOrderEvent( FReadyItem, 100 );

      FOrdDir := iSide;
    end else
    begin

      aOrder  := DoOrder( iQty * FMulti , iSide, aQuote );
      if aOrder <> nil then
      begin
        if iSide > 0 then
          inc( aOrdRes.OrdCnt[ptLong])
        else
          inc( aOrdRes.OrdCnt[ptShort]);
        aOrdRes.OrdDir := iSide;

        aItem := FOrders.New( aOrder );
        aItem.OrdRes  := aOrdRes;
        aItem.stType  := stType;

        if Assigned( FOnTrendOrderEvent ) then
          FOnTrendOrderEvent( aItem, 1 );

        DoLog( Format('%s, %s 추세%d %s 주문 가격: %.2f, 수량: %d - %.1f > %d', [
          aOrder.Account.Name, aQuote.Symbol.ShortCode,  ifThen( stType = stTrend, 1, 2 ),
          ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
          dTmp, ifThen( iSide > 0, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal ) ]));
      end;
    end;
  end;

end;

function TTrendTrade.CheckInvestData : boolean;
begin
  if FCallPerson = nil then
    FCallPerson := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_PERSON, 'C');
  if FPutPerson = nil then
    FPutPerson := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_PERSON, 'P');

  if FCallFinance = nil then
    FCallFinance := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(FInvestCode, 'C');
  if FPutFinance = nil then
    FPutFinance := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(FInvestCode, 'P');
                                                                         
  if ( FCallPerson = nil ) or ( FPutPerson = nil ) or
    ( FCallFinance = nil ) or ( FPutFinance = nil ) then
    Result := false
  else
    Result := true;

end;

// 투자자를 통한 추세
procedure TTrendTrade.CheckTrend2( aQuote : TQuote );
var
  dTmp : double;
  iSide, iCnt, iQty, iLs : integer;
  aOrder  : TOrder;

  dSum, dSum1 , dSum2 : double;
  stData : string;
  dtEndTime : TDateTime;
  aOrdRes : TTrendResult;
  aItem   : TOrderedItem;
  bUp, bDown : boolean;
begin
  try

  if Frac( FParam.StartTime2 ) > Frac( GetQuoteTime ) then Exit;

  dtEndTime := Frac( FParam.EndTime2 );
  if Frac( GetQuoteTime ) > dtEndTime then
    Exit;



  iSide := 0;
  iQty  := FParam.OrdQty2;

  dSum  := 0;
  dSum1 := 0;
  dSum2 := 0;

  if not CheckInvestData then Exit;

  // 억 단위임..
  dSum1 := FPutPerson.SumAmount - FCallPerson.SumAmount;
  dSum2 := FCallFinance.SumAmount - FPutFinance.SumAmount;

  dSum  := dSum1 + dSum2;

  if not FParam.UseCnt then
  begin
    bUp   := true;
    bDown := true;
  end else
  begin
    bUp   := false;
    bDown := false;
    if FQuote.Bids.CntTotal > FQuote.Asks.CntTotal  then
      bUp := true
    else if FQuote.Bids.CntTotal < FQuote.Asks.CntTotal then
      bDown := true;
  end;


  if (dSum > FParam.OrdCon2[ptLong]) and ( bUp ) then
  begin

    if FParam.UseFut then
    begin
      aQuote  := GetFuture;
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stInvestor );
        if aOrdRes.OrdDir <> 0 then Exit;
        if FParam.OrdCnt2[ptLong] <= aOrdRes.OrdCnt[ptLong] then
          DoLog( Format('상승 추세2 선물 매수 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptLong] ]))
        else begin
          NewOrder( iQty, 1, aQuote, aOrdRes, dSum, stInvestor );
          DoLog( Format('상승 추세2 선물 매수 주문 -> 투자자 %.1f = %.1f + %.1f  ( 건수 : %d > %d ) ',
                [ dSum, dSum1, dSum2, FQuote.Bids.CntTotal , FQuote.Asks.CntTotal ]));
        end;
      end;
    end
    else begin

      if FParam.UseReverse then     // 상승일때 반대로 콜 매도
        aQuote := GetOption('C',FParam.BasePrice2[ptShort])
      else                          // 상승일때 풋 매도
        aQuote := GetOption('P',FParam.BasePrice2[ptShort]);

      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stInvestor );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt2[ptLong] <= aOrdRes.OrdCnt[ptLong] then
            DoLog( Format('상승 추세2 %s 매도 주문 카운트 Over %d', [
              ifThenStr( FParam.UseReverse, '반대로 콜','풋'),   aOrdRes.OrdCnt[ptLong] ]))
          else begin
            NewOrder( iQty, -1, aQuote, aOrdRes, dSum, stInvestor );
            DoLog( Format('상승 추세2 %s 매도 주문 -> 투자자 %.1f = %.1f + %.1f ( 건수 : %d > %d ) ',
              [ ifThenStr( FParam.UseReverse, '반대로 콜','풋'),
                dSum, dSum1, dSum2, FQuote.Bids.CntTotal , FQuote.Asks.CntTotal ]));
          end;
        end;
      end;
      ///////////////////////////////////////////////////////////////////////
    end;
  end
  else if (dSum < FParam.OrdCon2[ptShort]) and ( bDown) then
  begin
    if FParam.UseFut then
    begin

      aQuote  := GetFuture;
      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stInvestor );
        if aOrdRes.OrdDir <> 0 then Exit;
        if FParam.OrdCnt2[ptShort] <= aOrdRes.OrdCnt[ptShort] then
          DoLog( Format('하락  추세2 선물 매도 주문 카운트 Over %d', [ aOrdRes.OrdCnt[ptShort] ]))
        else begin
          NewOrder( iQty, -1, aQuote, aOrdRes, dSum, stInvestor );
          DoLog( Format('하락 추세2 선물 매도 주문 -> 투자자 %.1f = %.1f + %.1f  ( 건수 : %d < %d ) ',
                [ dSum, dSum1, dSum2, FQuote.Bids.CntTotal , FQuote.Asks.CntTotal ]));
        end;
      end;

    end
    else begin

      if FParam.UseReverse then   // 하락일때 반대로 풋 매도
        aQuote := GetOption('P',FParam.BasePrice2[ptShort])
      else                        // 하락일때 콜매도
        aQuote := GetOption('C',FParam.BasePrice2[ptShort]);

      if aQuote <> nil then
      begin
        aOrdRes := GetOrdRes( aQuote, stInvestor );
        if aOrdRes.OrdDir = 0 then
        begin
          if FParam.OrdCnt2[ptShort] <= aOrdRes.OrdCnt[ptShort] then
            DoLog( Format('하락 추세2 %s 매도 주문 카운트 Over %d', [
              ifThenStr( FParam.UseReverse, '반대로 풋','콜'), aOrdRes.OrdCnt[ptShort] ]))
          else begin
            NewOrder( iQty, -1, aQuote, aOrdRes, dSum, stInvestor );
            DoLog( Format('하락 추세2 %s 매도 주문 -> 투자자 %.1f = %.1f + %.1f  ( 건수 : %d < %d ) ',
              [ ifThenStr( FParam.UseReverse, '반대로 풋','콜'),
                dSum, dSum1, dSum2, FQuote.Bids.CntTotal , FQuote.Asks.CntTotal ]));
          end;
        end;
      end;
      ////////////////////////////////////////////////////////////////////////////
    end;
  end;

  finally
    stData  := Format( '%.0f=%.0f+%.0f', [dSum ,dSum1 , dSum2 ]);
    if Assigned( FOnTrendNotify ) then
      FOnTrendNotify( Self, stData, 2 );
  end;


end;

function TTrendTrade.DoOrder( iQty, iSide : integer; aQuote : TQuote ) : TOrder;
var
  aTicket : TOrderTicket;
  dPrice  : double;
  stErr   : string;
  bRes    : boolean;
begin
  Result := nil;

  if iSide > 0 then
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
  else
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );

  bRes   := CheckPrice( aQuote.Symbol, Format('%.*f', [aQuote.Symbol.Spec.Precision, dPrice]),
    stErr );

  if (iQty = 0 ) or ( not bRes ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f - %s',  [ Account.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice, stErr ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if Result <> nil then
  begin
    Result.OrderSpecies := opTrend;
    //if Result.Symbol.ShortCode[1] = '1' then
    //  DoLog( Format('주문 만든 시간 %s ', [ FormatDateTime( 'hh:nn:ss.zzz', Result.SentTime ) ]));
    gEnv.Engine.TradeBroker.Send(aTicket);
  end;

end;


procedure TTrendTrade.CheckLiquid( aType : TStrategyType );
var
  I: Integer;
  aItem : TOrderedItem;
  bDel  : boolean;
begin
  for I := FOrders.Count - 1 downto 0 do
  begin
    aItem := FOrders.Ordered[i];

    //if aItem.stType <> aType then
    //  continue;

    bDel := false;
    if (aItem.stType = stTrend) and ( FParam.UseTrd1) then
    begin
      if FParam.Trd1UseCnt then      
        bDel := CheckLiquid1( aItem )
      else
        bDel := CheckLiquid1_2(aItem );
    end
    else if (aItem.stType = stInvestor) and ( FParam.UseTrd2) then
      bDel := CheckLiquid2( aItem );

    if bDel then
    begin
      if Assigned( FOnTrendOrderEvent ) then
        FOnTrendOrderEvent( aItem, -1 );
      FOrders.Delete(i);
    end;
  end;
end;

  function TTrendTrade.GetMarket( aSymbol : TSymbol ) : string;
  begin
    case aSymbol.ShortCode[1] of
      '1': result := '선물';
      '2': result := '콜';
      '3': result := '풋';
    end;
  end;

//procedure TTrendTrade.CheckLiquid1( aQuote : TQuote );
function TTrendTrade.CheckLiquid1( aItem : TOrderedITem ) : boolean;
var
  dTmp : double;
  aOrder : TOrder;
  stData : string;
begin

  Result := false;

  if Frac( FParam.EndTime ) < Frac( GetQuoteTime ) then
    Result := true

  else begin

    if aItem.OrdRes.OrdDir > 0 then
    begin
      if (FParam.UseFut) or ( aItem.Symbol.ShortCode[1] = '2')  then
      begin
        dTmp  := FQuote.Asks.CntTotal * FParam.LiqCon1[ptLong];
        if dTmp > FQuote.Bids.CntTotal then begin
          Result := true;
          DoLog( Format('추세1 %s 매수 청산 -> 매도건수 * %.2f  > 매수건수 ( %.1f(%d) >  %d )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptLong], dTmp, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal   ]));
        end;
      end
      else begin
        dTmp  := FQuote.Bids.CntTotal * FParam.LiqCon1[ptLong];
        if dTmp > FQuote.Asks.CntTotal then begin
          Result := true;
          DoLog( Format('추세1 %s 매수 청산 -> 매수건수 * %.2f  > 매도건수 ( %.1f(%d) >  %d )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptLong], dTmp, FQuote.Bids.CntTotal, FQuote.Asks.CntTotal    ]));
        end;
      end;

    end else
    begin
      if (FParam.UseFut) or (aItem.Symbol.ShortCode[1] = '2') then
      begin
        dTmp  := FQuote.Bids.CntTotal * FParam.LiqCon1[ptShort];
        if dTmp > FQuote.Asks.CntTotal then begin
          Result := true;
          DoLog( Format('추세1 %s 매도 청산 -> 매수건수 * %.2f  > 매도건수 ( %.1f(%d) >  %d )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptShort], dTmp, FQuote.Bids.CntTotal, FQuote.Asks.CntTotal   ]));
        end;
      end
      else begin
        dTmp  := FQuote.Asks.CntTotal * FParam.LiqCon1[ptShort];
        if dTmp > FQuote.Bids.CntTotal then begin
          Result := true;
          DoLog( Format('추세1 %s 매도 청산 -> 매도건수 * %.2f  > 매수건수 ( %.1f(%d) >  %d )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptShort], dTmp, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal   ]));
        end;
      end;
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aItem.Order.FilledQty  , -aItem.OrdRes.OrdDir, aItem.Symbol.Quote as TQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('%s 추세1 %s 청산 가격: %.2f, 수량: %d - %.1f > %d', [ aItem.Symbol.ShortCode,
        ifThenStr( aItem.OrdRes.OrdDir > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dTmp , ifThen( aItem.OrdRes.OrdDir > 0, FQuote.Bids.CntTotal, FQuote.Asks.CntTotal ) ]));
      aItem.OrdRes.OrdDir := 0;
      aItem.LiqOrder  := aOrder;
    end else
      Result := false;
  end;
 {
  stData  := Format( '* %s,%.0f,%d', [
    ifThenStr( aItem.OrdRes.OrdDir > 0, 'L','S' ), dTmp,
    ifThen( FOrdRes1.OrdDir > 0, aQuote.Bids.CntTotal, aQuote.Asks.CntTotal  ) ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 1 );
  }
end;


function TTrendTrade.CheckLiquid1_2(aItem: TOrderedITem): boolean;
var
  dTmp : double;
  aOrder : TOrder;
  stData : string;
begin

  Result := false;

  if Frac( FParam.EndTime ) < Frac( GetQuoteTime ) then
    Result := true

  else begin

    if aItem.OrdRes.OrdDir > 0 then
    begin
      if (FParam.UseFut) or ( aItem.Symbol.ShortCode[1] = '2')  then
      begin
        dTmp  := FQuote.Asks.VolumeTotal - FQuote.Bids.VolumeTotal;
        if dTmp > FParam.LiqCon1[ptLong] then begin
          Result := true;
          DoLog( Format('추세1 %s 매수 청산 -> 잔량 차  %.0f > %.0f = %d - %d )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptLong], dTmp, FQuote.Asks.VolumeTotal , FQuote.Bids.VolumeTotal  ]));
        end;
      end
      else begin
        // 하락시 풋매수 들어갔을때...
        dTmp  := FQuote.Bids.VolumeTotal - FQuote.Asks.VolumeTotal;
        if dTmp > FParam.LiqCon1[ptLong] then begin
          Result := true;
          DoLog( Format('추세1 %s 매수 청산 -> 잔량차  %.0f > %.0f = %d - %d  )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptLong], dTmp, FQuote.Bids.VolumeTotal , FQuote.Asks.VolumeTotal   ]));
        end;
      end;

    end else
    begin
      if (FParam.UseFut) or (aItem.Symbol.ShortCode[1] = '2') then
      begin
        dTmp  := FQuote.Bids.VolumeTotal - FQuote.Asks.VolumeTotal;
        if dTmp > FParam.LiqCon1[ptShort] then  begin
          Result := true;
          DoLog( Format('추세1 %s 매도 청산 ->  잔량차  %.0f > %.0f = %d - %d  )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptShort], dTmp, FQuote.Bids.VolumeTotal , FQuote.Asks.VolumeTotal  ]));
        end;

      end
      else begin
        // 상승시 풋 매도
        dTmp  := FQuote.Asks.VolumeTotal - FQuote.Bids.VolumeTotal;
        if dTmp > FParam.LiqCon1[ptShort] then begin
          Result := true;
          DoLog( Format('추세1 %s 매도 청산 -> 잔량차 %.0f > %.0f = %d - %d  )',
            [ GetMarket( aItem.Symbol ), FParam.LiqCon1[ptShort], dTmp, FQuote.Asks.VolumeTotal , FQuote.Bids.VolumeTotal  ]));
        end;

      end;
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aItem.Order.FilledQty  , -aItem.OrdRes.OrdDir, aItem.Symbol.Quote as TQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('%s 추세1 %s 청산 가격: %.2f, 수량: %d -> %.0f = %d - %d (Ask-Bid) ', [ aItem.Symbol.ShortCode,
        ifThenStr( aItem.OrdRes.OrdDir > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dTmp , FQuote.Asks.VolumeTotal , FQuote.Bids.VolumeTotal ]));
      aItem.OrdRes.OrdDir := 0;
      aItem.LiqOrder  := aOrder;
    end else
      Result := false;
  end;

end;

const
  ComAmt = 15;

procedure TTrendTrade.CheckReadyItem;
var
  dTmp : double;
  bInit: boolean;
begin

  if ( FReadyItem.Ready ) and ( FReadyItem.Symbol <> nil ) and
     ( FQuote <> nil ) and ( FPutPerson <> nil ) and (  FCallFinance <> nil ) then
  begin

//-------------------------------------------------------------------------------
    dTmp :=  FPutPerson.SumAmount - FCallPerson.SumAmount +
           FCallFinance.SumAmount - FPutFinance.SumAmount;

    bInit := false;
    // 주문 준비중에  청산신호 나면 초기화.
    if FReadyItem.OrdRes.OrdDir > 0 then
    begin
      // 상승일때
      if (( FReadyItem.OrdRes.MaxAmt - ComAmt ) > dTmp )  or ( dTmp < 0 ) then
        bInit := true
    end else
    if FReadyItem.OrdRes.OrdDir < 0  then
    begin
      if ((FReadyItem.Symbol.ShortCode[1] = '3') and ( not FReadyItem.Reverse ))
          or
         ((FReadyItem.Symbol.ShortCode[1] = '2') and ( FReadyItem.Reverse ))
      then
      begin
        // 상승일때
        if (( FReadyItem.OrdRes.MaxAmt - ComAmt ) > dTmp )  or ( dTmp < 0 ) then
          bInit := true
      end else
      begin
        // 하락일때
        if (( FReadyItem.OrdRes.MaxAmt + ComAmt ) < dTmp )  or ( dTmp > 0 ) then
          bInit := true
      end;
    end;
//-------------------------------------------------------------------------------
    if bInit then
    begin

      FReadyItem.Last := FQuote.Last;
      if Assigned( FOnTrendOrderEvent ) then
        FOnTrendOrderEvent( FReadyItem, -100 );

      FReadyItem.Ready := false;
      FReadyItem.Symbol:= nil;
      FReadyItem.Reverse:= false;
      FReadyItem.OrdRes.init;
    end;

  end;
end;

function TTrendTrade.GetUpDown : integer;
begin
  if FReadyItem.OrdRes.OrdDir > 0 then
    Result := 1
  else
  if FReadyItem.OrdRes.OrdDir < 0  then
  begin
    if ((FReadyItem.Symbol.ShortCode[1] = '3') and ( not FReadyItem.Reverse ))
         or
       ((FReadyItem.Symbol.ShortCode[1] = '2') and ( FReadyItem.Reverse ))then
      Result := 1
    else
      Result := -1;
  end;
end;

procedure TTrendTrade.CheckReadyOrder;
var
  dGap : double;
  aOrder : TOrder;
  aItem  : TOrderedItem;
  bOrder : boolean;
begin
  if ( FReadyItem.Ready ) and ( FReadyItem.Symbol <> nil ) and ( FQuote <> nil ) then
  begin
    bOrder := false;
    dGap := FReadyItem.Last - FQuote.Last;
    if  (GetUpDown > 0) and (abs(dGap) >= 0) and ( dGap < 0 ) then
    begin
      bOrder := true;
    end else
    if  (GetUpDown < 0) and (dGap >= 0)  then
    begin
      bOrder := true;
    end;

    if bOrder then
    begin
      aOrder  := DoOrder( FParam.OrdQty2 * FMulti, FReadyItem.OrdRes.OrdDir, FReadyItem.Symbol.Quote as TQuote );
      if aOrder <> nil then
      begin
        if GetUpDown > 0 then
          inc( FReadyItem.OrdRes.OrdCnt[ptLong])
        else
          inc( FReadyItem.OrdRes.OrdCnt[ptShort]);
        aItem := FOrders.New( aOrder );
        aItem.OrdRes  := FReadyItem.OrdRes;
        aItem.stType  := FReadyItem.stType;
        aItem.Reverse := FReadyItem.Reverse;

        if Assigned( FOnTrendOrderEvent ) then
          FOnTrendOrderEvent( aItem, 1 );

        DoLog( Format('%s 추세%d %s 주문 가격: %.2f, 수량: %d - %.1f > %d', [ FReadyItem.Symbol.ShortCode,
          ifThen( FReadyItem.stType = stTrend, 1, 2 ),
          ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
          FReadyItem.OrdRes.MaxAmt, ifThen( aOrder.Side > 0, FQuote.Asks.CntTotal, FQuote.Bids.CntTotal ) ]));

        // 초기화
        FReadyItem.Ready := false;
        FReadyItem.Symbol:= nil;
        FReadyItem.Reverse := false;
      end;
    end;
  end;
end;

function TTrendTrade.calcLiquidGap( dAmt, dDiv : double; iSide : integer ) : double;
var
  iMod, iDiv : integer;
begin

  if iSide > 0 then
    iDiv := abs(floor(dAmt / dDiv))
  else
    iDiv := abs(ceil(dAmt / dDiv));

  iMod := Max(iDiv - 1, 0 );

  Result := iMod * dDiv * iSide ;
end;

//procedure TTrendTrade.CheckLiquid2( aQuote : TQuote );
function TTrendTrade.CheckLiquid2( aItem : TOrderedITem ) : boolean;
var

  dTmp , dSum1, dSum2, dGap, dVal : double;
  aQuote : TQuote;
  aOrder : TOrder;
  stData : string;
begin

  Result := false;

  aQuote  := aItem.Symbol.Quote as TQuote;
  if aQuote = nil then Exit;

  if Frac( FParam.EndTime2 ) < Frac( GetQuoteTime ) then
    Result := true

  else begin

    dSum1 := FPutPerson.SumAmount - FCallPerson.SumAmount;
    dSum2 := FCallFinance.SumAmount - FPutFinance.SumAmount;
    dTmp  := dSum1 + dSum2;

    //dVal := Max( aItem.OrdRes.MaxAmt, dTmp );
    //dVal := Min( aItem.OrdRes.MinAmt, dTmp );

    aItem.OrdRes.MaxAmt := Max( aItem.OrdRes.MaxAmt, dTmp );
    aItem.OrdRes.MinAmt := Min( aItem.OrdRes.MinAmt, dTmp );

    dGap := 0;

    if aItem.OrdRes.OrdDir > 0 then
    begin
      if dTmp < 0 then
        Result := true
      else
        if FParam.UseTrdStop then
        begin
          dGap := calcLiquidGap( aItem.OrdRes.MaxAmt,FParam.OtrCon2[ptLong], 1 );
          if dGap > dTmp then
            Result := true;
          {
          dGap := aItem.OrdRes.MaxAmt - dTmp;
          //dGap := dTmp - aItem.OrdRes.MaxAmt;
          if dGap > FParam.OtrCon2[ptLong] then
            Result := true;
          }
        end;
    end else
    begin
      // 상승장에서 .. 풋매도,
      if ((aItem.Symbol.ShortCode[1] = '3') and ( not aItem.Reverse ))
        or
        ((aItem.Symbol.ShortCode[1] = '2') and ( aItem.Reverse )) then
      begin
        if dTmp < 0 then
          Result := true
        else
          if FParam.UseTrdStop then
          begin
            dGap := calcLiquidGap( aItem.OrdRes.MaxAmt,FParam.OtrCon2[ptShort], 1 );
            if dGap > dTmp then
              Result := true;
              {
            dGap := aItem.OrdRes.MaxAmt - dTmp;
            //dGap := dTmp - aItem.OrdRes.MaxAmt;
            if dGap > FParam.OtrCon2[ptShort] then
              Result := true;
              }
          end;
      end
      // 하락장에서 .. 선물매도 or 콜매도
      else begin
        if dTmp > 0 then
          Result := true
        else begin
          if FParam.UseTrdStop then
          begin
            dGap := calcLiquidGap( aItem.OrdRes.MinAmt,FParam.OtrCon2[ptShort], -1 );
            if dGap < dTmp then
              Result := true;
              {
            dGap := abs(dTmp - aItem.OrdRes.MinAmt);
            //dGap := abs(dTmp - aItem.OrdRes.MinAmt);
            if dGap > FParam.OtrCon2[ptShort] then
              Result := true;
              }
          end;
        end;
      end;
      //////
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aItem.Order.FilledQty, -aItem.OrdRes.OrdDir, aQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('추세2 %s %s 청산 -> %.1f = %.1f + %.1f )',
             [ GetMarket( aItem.Symbol ), ifThenStr( aItem.Order.Side > 1,'매수','매도'),
               dTmp  , dSum1 , dSum2   ]));

      DoLog( Format('%s 추세2 %s 청산 가격: %.2f, 수량: %d - %.1f = %.1f + %.1f (%.0f)', [ aQuote.Symbol.ShortCode,
        ifThenStr( aItem.OrdRes.OrdDir > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dTmp , dSum1 , dSum2, dGap ]));
      aItem.OrdRes.OrdDir   := 0;
      aItem.LiqOrder  := aOrder;
    end else
      Result := false;
  end;

  stData  := Format( '%.0f=%.0f+%.0f', [dTmp ,dSum1 , dSum2 ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 2 );

end;


procedure TTrendTrade.CheckLiskAmt;
var
  dPL, dSum1, dSum2, dTmp : double;
  I: Integer;
  aQuote: TQuote;
  aItem : TOrderedItem;
  bDel  : boolean;
  aOrder: TOrder;
begin

  if not FParam.UseTrd2  then Exit;
  dPL := gEnv.Engine.TradeCore.Positions.GetPL( FAccount );

  // 추세1, 2 구분해야 하지만 일단은 추세2( 투자자 ) 만 주문 나간다고 생각하고 계산
  if dPL < 0 then
    if (-FParam.LiskAmt2 * FParam.OrdQty2 * FMulti ) >  dPL then
    begin

      dSum1 := FPutPerson.SumAmount - FCallPerson.SumAmount;
      dSum2 := FCallFinance.SumAmount - FPutFinance.SumAmount;
      dTmp  := dSum1 + dSum2;

      for I := FOrders.Count - 1 downto 0 do
      begin
        aItem := FOrders.Ordered[i];

        if aItem = nil then Continue;

        aQuote  := aItem.Symbol.Quote as TQuote;
        if aQuote = nil then Continue;

        aOrder  := DoOrder( aItem.Order.FilledQty, -aItem.OrdRes.OrdDir, aQuote );
        if aOrder <> nil then
        begin
          DoLog( Format('투자자 한도초과로 (%.0f) ,  %s %s 청산 -> %.1f = %.1f + %.1f )',
                 [ dPL/1000, GetMarket( aItem.Symbol ), ifThenStr( aItem.Order.Side > 1,'매수','매도'),
                   dTmp  , dSum1 , dSum2   ]));

          aItem.OrdRes.OrdDir   := 0;
          aItem.LiqOrder  := aOrder;

          if Assigned( FOnTrendOrderEvent ) then
            FOnTrendOrderEvent( aItem, -1 );
          FOrders.Delete(i);
        end;
      end;

      FLossCut := true;
    end;


end;

{ TTrendResult }

procedure TTrendResult.init;
begin
  OrdDir  := 0;
  OrdCnt[ptLong]  := 0;
  OrdCnt[ptShort] := 0;
  MaxAmt := 0;
  MinAmt := 0;

end;

{ TOrderedItem }

constructor TOrderedItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  Order := nil;
  LiqOrder  := nil;
  Symbol:= nil;
  ManualQty := 0;
  Reverse := false;
end;

{ TOrderedItems }

constructor TOrderedItems.Create;
begin
  inherited Create( TOrderedItem );
end;

procedure TOrderedItems.Del(aOrder: TOrder);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetOrdered(i).Order = aOrder then
    begin
      Delete(i);
      break;
    end;
end;

destructor TOrderedItems.Destroy;
begin

  inherited;
end;

function TOrderedItems.GetOrdered(i: Integer): TOrderedItem;
begin
  if (i<0) or ( i>= Count) then
    Result := nil
  else
    Result := Items[i] as TOrderedItem;
end;

function TOrderedItems.New(aOrder: TOrder): TOrderedItem;
begin
  Result := Add as TOrderedItem;
  Result.Order  := aOrder;
  Result.Symbol := aOrder.Symbol;
end;

{ TTrendTrades }

constructor TTrendTrades.Create;
begin
  inherited Create( TTrendTrade );
end;

destructor TTrendTrades.Destroy;
begin

  inherited;
end;

function TTrendTrades.Find(stCode: string): TTrendTrade;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetTrend(i).InvestCode = stCode then
    begin
      Result := GetTrend(i);
      break;
    end;
end;

function TTrendTrades.GetTrend(i: integer): TTrendTrade;
begin
  if (i<0) or (i>=Count) then
    Result := nil
  else
    Result := Items[i] as TTrendTrade;

end;

function TTrendTrades.New(stCode: string): TTrendTrade;
begin
  Result := Add as TTrendTrade;
  Result.InvestCode := stCode;
end;

end.
