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
    // 공통
    StartTime : TDateTime;
    EndTime   : TDateTime;
    UseFut    : boolean;
    // 구분
    UseTrd1   : boolean;
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
  end;

  TTrendResult = class
  public
    OrdDir  : integer;
    OrdCnt  : array [TPositionType] of integer;
    MaxAmt  : double;
    MimAmt  : double;
    procedure init;
  end;

  // 주문낸 종목들
  TOrderedItem = class( TCollectionItem )
  public
    Symbol : TSymbol;
    Order  : TOrder;
    OrdRes : TTrendResult;
    stType : TStrategyType;
    Constructor Create( aColl : TCollection ) ; override;
  end;

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

  TTrendTrade = class
  private
    FSymbol: TSymbol;
    FRun: boolean;
    FAccount: TAccount;

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

    function IsRun : boolean;
    procedure Reset ;
    procedure OnQuote(aQuote: TQuote);
    procedure CheckFutTrend(aQuote: TQuote);
    procedure CheckOptTrend;
    procedure CheckTrend1(aQuote: TQuote);
    procedure CheckTrend2(aQuote: TQuote);

    procedure DoLog( stLog : string );
    function DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
    function CheckInvestData : boolean;
    //procedure CheckLiquid1(aQuote: TQuote);
    //procedure CheckLiquid2(aQuote: TQuote);

    function CheckLiquid1( aItem : TOrderedITem ) : boolean;
    function CheckLiquid2( aItem : TOrderedITem ) : boolean;

    function GetOrdRes(aQuote: TQuote; stType : TStrategyType): TTrendResult;
    procedure CheckLiquid;

  public

    Constructor Create;
    Destructor  Destroy; override;

    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;
    function Start : boolean;
    Procedure Stop;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);


    property Symbol  : TSymbol read FSymbol;  // 최근월물..
    property Account : TAccount read FAccount;
    property Orders  : TOrderedItems read FOrders;

    property Param   : TTrendParam read FParam write FParam;

    property OrdRes1  : TTrendResult read FOrdRes1 write FOrdRes1;
    property OrdRes2  : TTrendResult read FOrdRes2 write FOrdRes2;
    property OrdRes3  : TTrendResult read FOrdRes3 write FOrdRes3;
    property OrdRes4  : TTrendResult read FOrdRes4 write FOrdRes4;

    property Run : boolean read FRun write FRun;
    property OnTrendNotify : TTrendDataNotifyEvent read FOnTrendNotify write FOnTrendNotify;
  end;

implementation

uses
  GAppEnv, GleLib, GleConsts

  ;

{ TTrendTrade }

constructor TTrendTrade.Create;
begin
  FRun  := false;
  FSymbol := nil;
  FAccount:= nil;

  FOrders:= TOrderedItems.Create;

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

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

procedure TTrendTrade.DoLog(stLog: string);
begin
  if FAccount <> nil then  
    gEnv.EnvLog( WIN_INV, stLog, false, FAccount.Code );
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

procedure TTrendTrade.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin
  if (not IsRun) or (DataObj = nil) then Exit;
  aQuote  := DataObj as TQuote;

  if Frac( FParam.StartTime ) > Frac( GetQuoteTime ) then Exit;

  if aQuote.AddTerm then
    OnQuote( aQuote );

end;

procedure TTrendTrade.Reset;
begin
  FOrdRes1.init;
  FOrdRes2.init;
  FOrdRes3.init;
  FOrdRes4.init;


  FCallPerson := nil;
  FPutPerson  := nil;
  FCallFinance:= nil;
  FPutFinance := nil;
end;

function TTrendTrade.Start: boolean;
begin
  Result := IsRun;
  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  FRun  := true;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
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
begin

end;

procedure TTrendTrade.OnQuote( aQuote : TQuote );
begin
  // 헐트헤지
  if FParam.UseFut then
    CheckFutTrend( aQuote )
  // 옵션 추세
  else
    CheckOptTrend;

  CheckLiquid;
end;

procedure TTrendTrade.CheckFutTrend( aQuote : TQuote );
begin
  // 일반 추세
  if FParam.UseTrd1 then
    CheckTrend1( aQuote );

  // 투자자 데이터 를 통한  추세
  if FParam.UseTrd2 then
    CheckTrend2( aQuote );
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
        else begin
          if aQuote.Symbol.ShortCode[1] = '2' then
            Result := FOrdRes3
          else
            Result := FOrdRes4;
        end;
      end;
  end;

end;

// 일반 추세
procedure TTrendTrade.CheckTrend1( aQuote : TQuote );
var
  dTmp : double;
  iSide, iCnt, iQty, iLS : integer;
  aOrder  : TOrder;
  stData  : string;
  dtEndTime : TDateTime;
  aOrdRes : TTrendResult;
  aItem   : TOrderedItem;
begin

  aOrdRes := GetOrdRes( aQuote, stTrend );

  if aOrdRes.OrdDir <> 0 then
  begin
    // 주문이 나가 있는 상황이므로..청산을 체크한다.
    // CheckLiquid1( aQuote );
    Exit;
  end;

  dtEndTime := EncodeTime(14,0,0,0 );
  if Frac( GetQuoteTime ) > dtEndTime then
    Exit;
  

  iSide := 0;
  iLS   := 0;
  iQty  := FParam.OrdQty1;

  if aQuote.Bids.CntTotal > aQuote.Asks.CntTotal then
  begin
    // 선물과 콜
    if (FParam.UseFut) or ( aQuote.Symbol.ShortCode[1] ='2' )then
    begin
      iLs := 1;
      if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
      begin
        DoLog( Format('%s 추세1 매수 주문 카운트 Over %d', [
          aQuote.Symbol.ShortCode, FParam.OrdCnt1[ptLong], aOrdRes.OrdCnt[ptLong] ]));
        Exit;
      end;

      dTmp  := aQuote.Bids.CntTotal * FParam.OrdCon1[ptLong];

      if dTmp > aQuote.Asks.CntTotal then
        iSide := 1;
    end
    // 풋은 반대로
    else begin
      iLs := -1;
      if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
      begin
        DoLog( Format('%s 추세1 매도 주문 카운트 Over %d', [
          aQuote.Symbol.ShortCode, FParam.OrdCnt1[ptShort], aOrdRes.OrdCnt[ptShort] ]));
        Exit;
      end;

      dTmp  := aQuote.Bids.CntTotal * FParam.OrdCon1[ptShort];

      if dTmp > aQuote.Asks.CntTotal then
        iSide := -1;
    end;

  end else
  if aQuote.Asks.CntTotal > aQuote.Bids.CntTotal then
  begin
    // 선물과 콜
    if (FParam.UseFut) or ( aQuote.Symbol.ShortCode[1] ='2' )then
    begin
      iLs := -1;
      if FParam.OrdCnt1[ptShort] <= aOrdRes.OrdCnt[ptShort] then
      begin
        DoLog( Format('%s 추세1 매도 주문 카운트 Over %d', [
          aQuote.Symbol.ShortCode, FParam.OrdCnt1[ptShort], aOrdRes.OrdCnt[ptShort] ]));
        Exit;
      end;

      dTmp  := aQuote.Asks.CntTotal * FParam.OrdCon1[ptShort];

      if dTmp > aQuote.Bids.CntTotal then
        iSide := -1;
    end
    else begin
      iLs := 1;
      if FParam.OrdCnt1[ptLong] <= aOrdRes.OrdCnt[ptLong] then
      begin
        DoLog( Format('%s 추세1 매수 주문 카운트 Over %d', [
          aQuote.Symbol.ShortCode, FParam.OrdCnt1[ptLong], aOrdRes.OrdCnt[ptLong] ]));
        Exit;
      end;

      dTmp  := aQuote.Asks.CntTotal * FParam.OrdCon1[ptLong];

      if dTmp > aQuote.Bids.CntTotal then
        iSide := 1;

    end;
  end;

  if iSide <> 0 then
  begin
    aOrder  := DoOrder( iQty, iSide, aQuote );
    if aOrder <> nil then
    begin
      if iSide > 0 then
        inc( aOrdRes.OrdCnt[ptLong])
      else
        inc( aOrdRes.OrdCnt[ptShort]);
      aOrdRes.OrdDir := iSide;

      aItem := FOrders.New( aOrder );
      aItem.OrdRes  := aOrdRes;
      aItem.stType  := stTrend;

      DoLog( Format('%s 추세1 %s 주문 가격: %.2f, 수량: %d - %.1f > %d', [ aQuote.Symbol.ShortCode,
        ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dTmp, ifThen( iSide > 0, aQuote.Asks.CntTotal, aQuote.Bids.CntTotal ) ]));
    end;
  end;

  stData  := Format( '%s,%.0f,%d', [
    ifThenStr( iLS > 0, 'L','S' ), dTmp,
    ifThen( iLS > 0, aQuote.Asks.CntTotal, aQuote.Bids.CntTotal ) ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 1 );
end;

function TTrendTrade.CheckInvestData : boolean;
begin
  if FCallPerson = nil then
    FCallPerson := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_PERSON, 'C');
  if FPutPerson = nil then
    FPutPerson := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_PERSON, 'P');

  if FCallFinance = nil then
    FCallFinance := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_FINANCE, 'C');
  if FPutFinance = nil then
    FPutFinance := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_FINANCE, 'P');
                                                                         
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
begin

  aOrdRes := GetOrdRes( aQuote, stInvestor );

  if aOrdRes.OrdDir <> 0 then
  begin
    // 주문이 나가 있는 상황이므로..청산을 체크한다.
    // CheckLiquid2( aQuote );
    Exit;
  end;

  dtEndTime := EncodeTime(14,0,0,0 );
  if Frac( GetQuoteTime ) > dtEndTime then
    Exit;

  iSide := 0;
  iQty  := FParam.OrdQty2;

  if not CheckInvestData then Exit;

  // 억 단위임..
  dSum1 := FPutPerson.SumAmount - FCallPerson.SumAmount;
  dSum2 := FCallFinance.SumAmount - FPutPerson.SumAmount;

  dSum  := dSum1 + dSum2;

  if dSum > FParam.OrdCon2[ptLong] then
  begin

    if FParam.UseFut then
    begin
      if FParam.OrdCnt2[ptLong] <= aOrdRes.OrdCnt[ptLong] then
      begin
        DoLog( Format('%s 추세2 매수 주문 카운트 Over %d', [
          aQuote.Symbol.ShortCode, FParam.OrdCnt2[ptLong], aOrdRes.OrdCnt[ptLong] ]));
        Exit;
      end;
      iSide := 1
    end
    else begin
      // 상승일때 풋 매도
      if aQuote.Symbol.ShortCode[1] = '3' then
      begin
        if FParam.OrdCnt2[ptLong] <= aOrdRes.OrdCnt[ptLong] then
        begin
          DoLog( Format('%s 추세2 매수 주문 카운트 Over %d', [
            aQuote.Symbol.ShortCode, FParam.OrdCnt2[ptLong], aOrdRes.OrdCnt[ptLong] ]));
          Exit;
        end;
        iSide := -1
      end;
    end;
  end
  else if dSum < FParam.OrdCon2[ptShort] then
  begin
    // 콜매도 하기땜시 if 문 안씀..
    if FParam.UseFut then
    begin
      if FParam.OrdCnt2[ptShort] <= aOrdRes.OrdCnt[ptShort] then
      begin
        DoLog( Format('%s 추세2 매도 주문 카운트 Over %d', [
          aQuote.Symbol.ShortCode, FParam.OrdCnt2[ptShort], aOrdRes.OrdCnt[ptShort] ]));
        Exit;
      end;
      iSide := -1;
    end
    else begin
      if aQuote.Symbol.ShortCode[1] = '2' then
      begin
        if FParam.OrdCnt2[ptShort] <= aOrdRes.OrdCnt[ptShort] then
        begin
          DoLog( Format('%s 추세2 매도 주문 카운트 Over %d', [
            aQuote.Symbol.ShortCode, FParam.OrdCnt2[ptShort], aOrdRes.OrdCnt[ptShort] ]));
          Exit;
        end;
        iSide := -1;
      end;
    end;
  end;                         

  if iSide <> 0 then
  begin
    aOrder  := DoOrder( iQty, iSide, aQuote );
    if aOrder <> nil then
    begin
      if iSide > 0 then
        inc( aOrdRes.OrdCnt[ptLong])
      else
        inc( aOrdRes.OrdCnt[ptShort]);
      aOrdRes.OrdDir := iSide;
      aOrdRes.MaxAmt := dSum;
      aOrdRes.MimAmt := dSum;

      aItem := FOrders.New( aOrder );
      aItem.OrdRes  := aOrdRes;
      aItem.stType  := stInvestor;

      DoLog( Format('%s 추세2 %s 주문 가격: %.2f, 수량: %d - %.1f = %.1f + %.1f', [ aQuote.Symbol.ShortCode,
        ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dSum, dSum1, dSum2 ]));
    end;
  end;

  stData  := Format( '%.0f=%.0f+%.0f', [dSum ,dSum1 , dSum2 ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 2 );

end;

procedure TTrendTrade.CheckOptTrend;
var
  cList, pList : TList;
  aQuote : TQuote;
  aSymbol: TSymbol;
  I: Integer;
begin

  if  FParam.UseTrd1  then
  begin
    try
      cList  := TList.Create;
      pList  := TList.Create;
      gEnv.Engine.SymbolCore.GetCurCallList( FParam.BasePrice1[ptLong ], 0, 10, cList );
      gEnv.Engine.SymbolCore.GetCurPutList( FParam.BasePrice1[ptShort], 0, 10, pList );

      if cList.Count > 0 then
      begin
        aSymbol := TSymbol( cList.Items[0] );
        if aSymbol.Quote <> nil then
          CheckTrend1( aSymbol.Quote as TQuote );
      end;

      if pList.Count > 0 then
      begin
        aSymbol := TSymbol( pList.Items[0] );
        if aSymbol.Quote <> nil then
          CheckTrend1( aSymbol.Quote as TQuote );
      end;

    finally
      cList.Free;
      pList.Free;
    end;
  end;

  if  FParam.UseTrd2  then
  begin
    try
      cList  := TList.Create;
      pList  := TList.Create;
      gEnv.Engine.SymbolCore.GetCurCallList( FParam.BasePrice2[ptLong ], 0, 10, cList );
      gEnv.Engine.SymbolCore.GetCurPutList( FParam.BasePrice2[ptShort], 0, 10, pList );

      if cList.Count > 0 then
      begin
        aSymbol := TSymbol( cList.Items[0] );
        if aSymbol.Quote <> nil then
          CheckTrend2( aSymbol.Quote as TQuote );
      end;

      if pList.Count > 0 then
      begin
        aSymbol := TSymbol( pList.Items[0] );
        if aSymbol.Quote <> nil then
          CheckTrend2( aSymbol.Quote as TQuote );
      end;

    finally
      cList.Free;
      pList.Free;
    end;
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

  bRes   := CheckPrice( aQuote.Symbol, Format('%.*n', [aQuote.Symbol.Spec.Precision, dPrice]),
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
    gEnv.Engine.TradeBroker.Send(aTicket);

end;


procedure TTrendTrade.CheckLiquid;
var
  I: Integer;
  aItem : TOrderedItem;
  bDel  : boolean;
begin
  for I := FOrders.Count - 1 downto 0 do
  begin
    aItem := FOrders.Ordered[i];

    bDel := false;
    if aItem.stType = stTrend then
      bDel := CheckLiquid1( aItem )
    else if aItem.stType = stInvestor then
      bDel := CheckLiquid2( aItem );

    if bDel then
      FOrders.Delete(i);
  end;
end;

//procedure TTrendTrade.CheckLiquid1( aQuote : TQuote );
function TTrendTrade.CheckLiquid1( aItem : TOrderedITem ) : boolean;
var
  dTmp : double;
  aQuote : TQuote;
  aOrder : TOrder;
  stData : string;
begin

  Result := false;

  aQuote  := aItem.Symbol.Quote as TQuote;
  if aQuote = nil then Exit;

  if Frac( FParam.EndTime ) < Frac( GetQuoteTime ) then
    Result := true

  else begin

    if aItem.OrdRes.OrdDir > 0 then
    begin
      if (FParam.UseFut) or (aItem.Symbol.ShortCode[1] = '2') then
      begin
        dTmp  := aQuote.Asks.CntTotal * FParam.LiqCon1[ptLong];
        if dTmp > aQuote.Bids.CntTotal then
          Result := true;
      end
      else begin
        dTmp  := aQuote.Bids.CntTotal * FParam.LiqCon1[ptLong];
        if dTmp > aQuote.Asks.CntTotal then
          Result := true;
      end;

    end else
    begin
      if (FParam.UseFut) or (aItem.Symbol.ShortCode[1] = '2') then
      begin
        dTmp  := aQuote.Bids.CntTotal * FParam.LiqCon1[ptShort];
        if dTmp > aQuote.Asks.CntTotal then
          Result := true;
      end
      else begin
        dTmp  := aQuote.Asks.CntTotal * FParam.LiqCon1[ptShort];
        if dTmp > aQuote.Bids.CntTotal then
          Result := true;
      end;
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aItem.Order.FilledQty  , -aItem.OrdRes.OrdDir, aQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('%s 추세1 %s 청산 가격: %.2f, 수량: %d - %.1f > %d', [ aQuote.Symbol.ShortCode,
        ifThenStr( aItem.OrdRes.OrdDir > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dTmp , ifThen( aItem.OrdRes.OrdDir > 0, aQuote.Bids.CntTotal, aQuote.Asks.CntTotal ) ]));
      aItem.OrdRes.OrdDir := 0;
    end;
  end;

  stData  := Format( '* %s,%.0f,%d', [
    ifThenStr( aItem.OrdRes.OrdDir > 0, 'L','S' ), dTmp,
    ifThen( FOrdRes1.OrdDir > 0, aQuote.Bids.CntTotal, aQuote.Asks.CntTotal  ) ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 1 );

end;

//procedure TTrendTrade.CheckLiquid2( aQuote : TQuote );
function TTrendTrade.CheckLiquid2( aItem : TOrderedITem ) : boolean;
var

  dTmp , dSum1, dSum2, dGap : double;
  aQuote : TQuote;
  aOrder : TOrder;
  stData : string;
begin

  Result := false;

  aQuote  := aItem.Symbol.Quote as TQuote;
  if aQuote = nil then Exit;

  if Frac( FParam.EndTime ) < Frac( GetQuoteTime ) then
    Result := true

  else begin

    dSum1 := FPutPerson.SumAmount - FCallPerson.SumAmount;
    dSum2 := FCallFinance.SumAmount - FPutPerson.SumAmount;
    dTmp  := dSum1 + dSum2;

    FOrdRes2.MaxAmt := Max( aItem.OrdRes.MaxAmt, dTmp );
    FOrdRes2.MimAmt := Min( aItem.OrdRes.MaxAmt, dTmp );

    dGap := 0;

    if aItem.OrdRes.OrdDir > 0 then
    begin
      if dTmp < 0 then
        Result := true
      else
        if FParam.UseTrdStop then
        begin
          dGap := aItem.OrdRes.MaxAmt - dTmp;
          if dGap > FParam.OtrCon2[ptLong] then
            Result := true;
        end;
    end else
    begin
      if dTmp > 0 then
        Result := true
      else
        if FParam.UseTrdStop then
        begin
          // 풋은 상승때 매도 한것
          if (not FParam.UseFut) and ( aItem.Symbol.ShortCode[1] = '3') then
          begin
            dGap := aItem.OrdRes.MaxAmt - dTmp;
            if dGap > FParam.OtrCon2[ptLong] then
              Result := true;
          end
          else begin
            dGap := abs(dTmp - aItem.OrdRes.MimAmt);
            if dGap > FParam.OtrCon2[ptShort] then
              Result := true;
          end;
        end;
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aItem.Order.FilledQty, -aItem.OrdRes.OrdDir, aQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('%s 추세2 %s 청산 가격: %.2f, 수량: %d - %.1f = %.1f + %.1f (%.0f)', [ aQuote.Symbol.ShortCode,
        ifThenStr( aItem.OrdRes.OrdDir > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        dTmp , dSum1 , dSum2, dGap ]));
      aItem.OrdRes.OrdDir   := 0;
    end;
  end;

  stData  := Format( '%.0f=%.0f+%.0f', [dTmp ,dSum1 , dSum2 ]);

  if Assigned( FOnTrendNotify ) then
    FOnTrendNotify( Self, stData, 2 );

end;


{ TTrendResult }

procedure TTrendResult.init;
begin
  OrdDir  := 0;
  OrdCnt[ptLong]  := 0;
  OrdCnt[ptShort] := 0;
  MaxAmt := 0;
  MimAmt := 0;
end;

{ TOrderedItem }

constructor TOrderedItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  Order := nil;
  Symbol:= nil;
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

end.
