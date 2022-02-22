unit BearTrade;

interface

uses
  Classes , SysUtils , Math 
  //
  {
  ,Broadcaster, SymbolStore, PriceCentral, AppTypes, LogCentral
  ,QuoteTimer , Globals, AccountStore, TradeCentral, PositionStore
  ,OrderStore , OrderHandler
  }
  //
  , CleSymbols, GleTypes, CleAccounts , CleQuoteBroker , CleDistributor
  , CleOrders, ClePositions , CleQuoteTimers, GleConsts , CleFQN
  , BearConfig , BearLog , BearData, CleSignals ;

type

  TBearOrderItem = class(TCollectionItem)
  public
    OrderTime : TDateTime ;     // 주문시각
    OrderItem : TOrder ;
    CancelOrdered : Boolean;    // 한번 취소 주문을 냈는지 여부
  end;

  TBearOrderQuoteItem = class(TCollectionItem)
  public
    QuoteTime : TDateTime ;   // 주문시각
    QuoteRec : TQuoteUnit ;    // 호가
  end;

  TBearOrders = class( TAutoOrders )
  public
    Constructor Create;
    Destructor Destroy; override;
  end;

  // 
  TBearTrade = class
  private 
    FConfig : TBearConfig ;
    FSysConfig : TBearSystemConfig ;
    FAccount : TAccount ;
    FCohesionSymbol : TSymbol ;
    FOrderSymbol : TSymbol ;
    FOrderQuote  : TQuoteUnit;
    //FOrderHandler : TOrderHandler;
    FPosition : TPosition ;

    FOrderCohesion : TOrderCohesion ;
    FOnBearLog : TBearLogNotifyEvent ;

    // 자동 취소를 위한 타이머
    FTimer : TQuoteTimer;
    
    // 주문 종목 데이터 저장하기 위한 변수 
    FOrderSaved : Boolean ;
    FOrderSaveStartTime : TDateTime ;
    FOrderFileName : String ;    
    
    // 0 : CohesionSymbol, 1 : OrderSymbol
    aQuoteCount : array[0..1] of Integer;
    aQuoteRec : array[0..1]  of TQuoteUnit;
    aPrevAvgPrice : array[0..1] of Double ; // 직전 평균단가
    
    //
    FOrderItemList : TCollection ;  // 주문 Item  ( TCollectionItem ) 
    FOrderReqList : TList ;         // 주문 요청  ( TOrderReqItem )
    FOrderQuoteList : TCollection ;   // 주문 종목의 호가 데이터 ( TCollectionItem )

    FBearOrders : TBearOrders;
    //
    procedure init ;
    function GetQuoteQty( aQuote : TQuote ; dPrice : double ;
        aPositionType : TPositionType  ) : Integer ;
    function CheckQuoteQty(aOrderSymbol :TSymbol ;
      dPrice : Double ; aPositionType : TPositionType ; iMaxQty : Integer  ) : Boolean ;
    function GetOrderPrice(aOrderSymbol :TSymbol ; aPositionType : TPositionType  ;
        aQuoteRec : TQuote) : Double ;
    function GetOrderPosition( aCohesionSymbol : TSymbol ;
        aOrderSymbol :TSymbol ; aCohesionPosition: TPositionType ) : TPositionType ;
    function GetPosition : Integer ;
    function GetAvgPrice( aSymbol : TSymbol ) : Double ;
    procedure QuoteOrderProcess( aRec : TCurrentOrder ) ;
    procedure QuoteCohesionProcess( aRec : TCurrentOrder ) ;
    procedure SaveOrderData( aRec : TCurrentOrder ) ;
    procedure SaveOrderHeader   ;
    //
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure ReqChanged(Sender : TObject);
    procedure OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure PositionProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID);
    procedure DoPosition(aPosition: TPosition; EventID: TDistributorID);      
    //
    procedure OrderSaveChanged(Sender: TObject);
    procedure InitCohesionChanged(Sender: TObject);
    procedure BearLog( Sender: TObject ;
        stTime:String ; stTitle:String ; stLog : String );
    procedure NewOrder(aCohesionSymbol : TSymbol ;
      aOrderSymbol :  TSymbol ; aQuoteRec : TQuote ;
      aCohesionPosition : TPositionType ; aCohesionData : TCohesionData );

    // Timer
    procedure TimerTimer(Sender: TObject);

    function IncStep(aSymbol : TSymbol ; dPrice : Double):Double;
    function DecStep(aSymbol : TSymbol ; dPrice: Double):Double;
    function FindOrder(aOrder: TOrder): TAutoOrder;

  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure Start( aSysConfig : TBearSystemConfig ; aConfig : TBearConfig );
    procedure Stop ;
    //
    property OnBearLog : TBearLogNotifyEvent read FOnBearLog write FOnBearLog;
  end;

implementation

uses GAppEnv, GleLib;

const
  LONG_ORDER = 'L' ;
  LONG_CANCEL = 'X' ; 
  SHORT_ORDER = 'S' ;
  SHORT_CANCEL = 'Y' ;

  BEAR_MAX_ORDER_QTY = 4999 ;

  PositionTypeLog : array[TPositionType] of String =
      ('Buy', 'Sell');

  
{ TBearTrade }

// ---------- << event >> ---------- //

procedure TBearTrade.OrderSaveChanged(Sender: TObject);
begin
  FOrderSaved := true ;
  FOrderSaveStartTime := GetQuoteTime;
end;

// -- 응집이 초기화 됐음을 알린다 
procedure TBearTrade.InitCohesionChanged(Sender: TObject);
var
  aOrderQuote : TBearOrderQuoteItem ;
  aQuote  : TQuote;
begin
  // 1. 호가 데이터 초기화
  FOrderQuoteList.Clear ;
  // 2. 최종 호가
  aQuote  := FOrderSymbol.Quote as TQuote;
  if aQuote <> nil then
  begin
    FOrderQuote.Assign( aQuote );
    aOrderQuote := FOrderQuoteList.Add as TBearOrderQuoteItem  ;
    with  aOrderQuote do
    begin
      QuoteTime := GetQuoteTime;
      QuoteRec :=  FOrderQuote;
    end;
  end
  else begin
    //gEnv.OnLog( self, 'InitCohesionChanged. aQuote is nil ');
  end;

end;

// ---------- << private >> ---------- //


procedure TBearTrade.SaveOrderHeader;
var
  TF : TextFile ;
  stHeader : String ;
begin
  FOrderFileName := gEnv.LogDir + '\' +'Bear_주문종목_' + FOrderSymbol.Name + '_' +
    FormatDateTime('yyyymmdd' , GetQuoteTime  )  + '.csv' ;
  //
  stHeader := '종목코드,주문시각,구분,주문가격,주문수량,평균단가,매도2,매도2,매도1,매도1,매수1,매수1,매수2,매수2' ;
  try
    AssignFile(TF, FOrderFileName );
    Rewrite(TF);
    //
    Writeln(TF, stHeader);
    CloseFile(TF);

  except
    on E : Exception do
      gLog.Add(lkError, 'TBearTrade', 'SaveOrderHeader', '비정상종료 ' + e.Message );
  end;

end;

procedure TBearTrade.SaveOrderData(aRec: TCurrentOrder);
var
  stData : String ;
  TF : TextFile ;
  aQuote : TQuote;
begin


  try

    AssignFile(TF, FOrderFileName );
    Append(TF);

    aQuote  := FOrderSymbol.Quote as TQuote;

    stData := FOrderSymbol.Name
        + ',' +  FormatDateTime('hh:nn:ss:zzz' , GetQuoteTime )
        + ',' +  GetOrderType( aRec.PositionType, aRec.OrderQty)
        + ',' +  Format('%.2f', [ aRec.OrderPrice ])
        + ',' + IntToStr(aRec.OrderQty)
        + ',' + Format('%.3f', [ aRec.AvgPrice ])
        //
        + ',' + IntToStr( aQuote.Asks[1].Volume )
        + ',' + Format('%.2f', [aQuote.Asks[2].Price ])
        + ',' + IntToStr( aQuote.Asks[0].Volume )
        + ',' + Format('%.2f', [aQuote.Asks[0].Price])
        + ',' + Format('%.2f', [aQuote.Bids[0].Price])
        + ',' + IntToStr(aQuote.Bids[0].Volume)
        + ',' + Format('%.2f', [aQuote.Bids[1].Price])
        + ',' + IntToStr(aQuote.Bids[1].volume)
        ;

    Writeln(TF, stData);
    CloseFile(TF);
    
  except
    on E : Exception do
      gLog.Add(lkError, 'TBearTrade', 'SaveOrderData', '비정상종료 ' + e.Message );
  end;

end;

// 변수 초기화
procedure TBearTrade.init;
var
  i : Integer ; 
begin
  // 0 : CohesionSymbol, 1 : OrderSymbol
  for i := 0 to 1  do
  begin
    aQuoteCount[i] := 0 ;
    aPrevAvgPrice[i] := 0 ;
  end;
 
end;




// 평균단가 구하기 
function TBearTrade.GetAvgPrice(aSymbol: TSymbol): Double;
var
  dAvgPrice : Double ;
  dQuoteGap : Double ;
  aQuote    : TQuote;
begin

  Result  := 0;

  aQuote  :=  aSymbol.Quote as TQuote;
  if aQuote = nil then
    Exit;

  dAvgPrice := 0 ;
  dQuoteGap :=  aQuote.Asks[0].Price - aQuote.Bids[0].Price;
  if Abs(dQuoteGap)< 0.05+PRICE_EPSILON then
  begin

    if ( aQuote.Asks[0].Volume + aQuote.Bids[0].Volume ) <> 0 then
    begin
      dAvgPrice := dQuoteGap * aQuote.Bids[0].Volume
                     / (aQuote.Asks[0].Volume + aQuote.Bids[0].Volume)
                    + aQuote.Bids[0].Price;  ;
    end;
  end
  else
    dAvgPrice := (aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2;
  // 
  Result := dAvgPrice ;
end;


function TBearTrade.GetOrderPosition( aCohesionSymbol : TSymbol ;
    aOrderSymbol :TSymbol ;  aCohesionPosition: TPositionType) : TPositionType;
var
  aOrderPosition : TPositionType ;
  bDirect : Boolean ; 
begin

  if ( aCohesionSymbol.Spec.Market = mtFutures ) or
     ( aCohesionSymbol.OptionType = otCall )  then
  begin

    if ( aOrderSymbol.Spec.Market = mtFutures ) or ( aOrderSymbol.OptionType = otCall ) then
      bDirect := true
    else if aOrderSymbol.OptionType = otPut then
      bDirect := false ;
    
  end
  else if ( aCohesionSymbol.OptionType = otPut ) then
  begin
    if ( aOrderSymbol.Spec.Market = mtFutures ) or ( aOrderSymbol.OptionType = otCall ) then
      bDirect := false
    else
      bDirect := true ;
  end ;

  // same direct
  if bDirect = true then
    aOrderPosition := aCohesionPosition
  else
  begin
    if aCohesionPosition = ptLong then
      aOrderPosition := ptShort
    else
      aOrderPosition := ptLong ;
  end;

  Result := aOrderPosition ;

end;


// 한틱 위 
function TBearTrade.IncStep(aSymbol : TSymbol ; dPrice: Double): Double;
var
  dResult : double ; 
begin

  dResult := 0 ;
  
   // futures
  if aSymbol.Spec.Market = mtFutures then
    dResult := dPrice + 0.05
  else
  // options
  begin
    case aSymbol.UnderlyingType of
      utKospi200 : if dPrice > 3.0 - PRICE_EPSILON then
                     dResult := dPrice + 0.05
                   else
                     dResult := dPrice + 0.01;
      utKosdaq50 : if dPrice > 5.0 - PRICE_EPSILON then
                     dResult := dPrice + 0.05
                   else
                     dResult := dPrice + 0.01;
      utStock : dResult := dPrice + aSymbol.Spec.TickSize;
    end;
  end;

  Result := dResult ; 
end;

// 한틱 및 
function TBearTrade.DecStep(aSymbol : TSymbol ; dPrice: Double): Double;
var
  dResult : double ; 
begin

  dResult := 0 ;
  
  // futures
  if aSymbol.Spec.Market = mtFutures then
    dResult := dPrice - 0.05
  else
  // options
  begin
    case aSymbol.UnderlyingType of
      utKospi200 : if dPrice > 3.0 + PRICE_EPSILON then
                     dResult := dPrice - 0.05
                   else
                     dResult := dPrice - 0.01;
      utKosdaq50 : if dPrice > 5.0 + PRICE_EPSILON then
                     dResult := dPrice - 0.05
                   else
                     dResult := dPrice - 0.01;
      utStock : dResult := dPrice - aSymbol.Spec.TickSize;
    end;
  end;

  Result := dResult ; 
end;

function TBearTrade.GetQuoteQty(aQuote: TQuote; dPrice: double;
  aPositionType : TPositionType  ): Integer;
var
  i : Integer ;
  iQty : Integer ;
  aDepths : TMarketDepths;
  //aQuoteType : TQuoteType ;
begin

  // -- 매수 주문일때 매도 잔량, 매도 주문일때 매수 잔량 
  if aPositionType = ptLong then
    aDepths := aQuote.Asks
  else
    aDepths := aQuote.Bids;

  // 
  iQty := 0 ;        
  for i := 0 to 4 do
  begin
    //if abs(dPrice -aQuote.Price[aQuoteType, i]) < PRICE_EPSILON then
    if abs(dPrice - aDepths[0].Price) < PRICE_EPSILON then
    begin
      iQty := aDepths[i].Volume;
      break ;
    end;
  end; 
  // 
  Result := iQty ;  
end;

// 호가 잔량 체크 
function TBearTrade.CheckQuoteQty(aOrderSymbol: TSymbol; dPrice: Double;
   aPositionType : TPositionType ; iMaxQty: Integer): Boolean;
var
  aQuote : TQuote ;
  dNextPrice : Double ;
  iQty, iNextQty : Integer ;
  stLog, stQuoteType : String ;
  i : Integer ; 
begin
  
  // -- 현재 호가 
  aQuote := aOrderSymbol.Quote as TQuote ;

  if aPositionType = ptLong then
  begin
    stQuoteType := ' 매도잔량' ;
    dNextPrice := IncStep( aOrderSymbol, dPrice) ;
  end
  else if aPositionType = ptShort then
  begin
     stQuoteType := ' 매수잔량' ; 
    dNextPrice := DecStep(aOrderSymbol, dPrice  )   ;
  end ;
  
  // dPrice 와  dNext 둘다 체크
  iQty := GetQuoteQty(aQuote, dPrice, aPositionType);
  iNextQty := GetQuoteQty(aQuote, dNextPrice, aPositionType);

  stLog :=
     '잔량체크 ' + PositionTypeLog[aPositionType] + stQuoteType
        + ' 1tick(' + Format('%.2f', [ dPrice ]) + ',' + IntTostr(iQty) + ')'
        + ' 2tick(' + Format('%.2f', [ dNextPrice ]) + ',' + IntTostr(iNextQty) + ')';
  //**gLog.Add(lkDebug, 'BearSystem', 'BearTrace', stLog);


  {
  stLog := 'Bid ' ;
  for i := 1 to 5 do
  begin
    stLog := stLog + ', '
      + Format('%.2f', [ aQuote.Price[qtBid, i] ])
      + ',' + IntTostr(aQuote.Qty[qtBid,i]) ;
  end;
  gLog.Add(lkDebug, 'BearSystem', 'BearTrace', stLog);

  stLog := 'Ask ' ; 
  for i := 1 to 5 do
  begin
    stLog := stLog + ', '
      + Format('%.2f', [ aQuote.Price[qtAsk, i] ])
      + ',' + IntTostr(aQuote.Qty[qtAsk,i]) ;
  end;
  gLog.Add(lkDebug, 'BearSystem', 'BearTrace', stLog);
  }

  // 작어야 true 
   if( iQty < iMaxQty ) then
    Result := true
  else
    Result := false ;
    
  {
  if( iQty < iMaxQty ) and ( iNextQty < iMaxQty) then
    Result := true
  else
    Result := false ;
  }
  
end;

function TBearTrade.GetOrderPrice(aOrderSymbol :TSymbol ;
    aPositionType : TPositionType ; aQuoteRec: TQuote): Double;
var
  dPrice : Double ;
  i : Integer ;
  aQuote : TQuote ;
  aOrderQuote : TBearOrderQuoteItem ;
  aNow : TDateTime ;
  dTimeGap : Double ; 
begin

  dPrice := 0 ;

  {
  gLog.Add(lkError, 'BearTrade', 'Price',
        '[start] '
        + IntToStr(FOrderQuoteList.Count)
        + ' [a] ' + Format('%.3f', [ aQuoteRec.Asks[0].Price ])
        + ' [b] ' + Format('%.3f', [ aQuoteRec.Bids[0].Price ] )
      );
  }

  // -- 시간차 계산  ( 응집 시작서부터의 신호가 나왔을때의 호가까지  체크 )
  if FSysConfig.OrderQuoteTimeUsed = true then
  begin

    aNow :=  GetQuoteTime ;
    for i := 0 to FOrderQuoteList.Count-1 do
    begin
      aOrderQuote := FOrderQuoteList.Items[i] as TBearOrderQuoteItem ;

      // 2007.08.08 시간 계산 오류 
      // aOrderQuote.QuoteRec.UpdateTime ->  aOrderQuote.QuoteTime
      dTimeGap := ( aNow - aOrderQuote.QuoteTime ) * 24 * 3600 * 1000 ;


      {
      gLog.Add(lkError, 'BearTrade', 'Price',
        '[i] ' + IntToStr(i)
        + ' [before] ' + Format('%.3f', [dPrice])
        + ' [gap] ' +  Format('%.0f', [dTimeGap])
        + ' [a] ' + Format('%.3f', [ aOrderQuote.QuoteRec.Asks[0].Price ])
        + ' [b] ' + Format('%.3f', [ aOrderQuote.QuoteRec.Bids[0].Price ])
      );
      }

      // -- Config에 설정한 시간차보다 작아지는 시점에 종료
      if(  dTimeGap < FSysConfig.OrderQuoteTime ) then
      begin
        if( i = 0 ) then
        begin
          //2007.08.19  매수주문 -> 매수1호가 + 1tick , 매도주문 -> 매도1호가 - 1tick
          if aPositionType = ptLong then
            dPrice := IncStep( aOrderSymbol, aOrderQuote.QuoteRec.Bids[0].Price)
          else if aPositionType = ptShort then
            dPrice := DecStep(aOrderSymbol, aOrderQuote.QuoteRec.Asks[0].Price);

          {
          if aPositionType = ptLong then
            dPrice := aOrderQuote.QuoteRec.Price[qtAsk, 1]
          else if aPositionType = ptShort then
            dPrice := aOrderQuote.QuoteRec.Price[qtBid, 1]  ;
          }
          end;
        break ;
      end;
      //
      if aPositionType = ptLong then
        dPrice := IncStep( aOrderSymbol, aOrderQuote.QuoteRec.Bids[0].Price)
      else if aPositionType = ptShort then
        dPrice := DecStep(aOrderSymbol, aOrderQuote.QuoteRec.Asks[0].Price);
      
    end;

  end
  else  // -- 바로 직전 호가 사용 
  begin

    //2007.08.19  매수주문 -> 매수1호가 + 1tick , 매도주문 -> 매도1호가 - 1tick
    if aPositionType = ptLong then
      dPrice := IncStep( aOrderSymbol, aQuoteRec.Bids[0].Price )
    else if aPositionType = ptShort then
      dPrice := DecStep(aOrderSymbol, aQuoteRec.Asks[0].Price );

    {
    // 응집시작 바로 직전 1호가
    if aPositionType = ptLong then
      dPrice := aQuoteRec.Price[qtAsk, 1]
    else if aPositionType = ptShort then
      dPrice := aQuoteRec.Price[qtBid, 1]  ;
    }
      
  end ;
  //

  if dPrice < PRICE_EPSILON then dPrice:= 0 ; 
  
  Result := dPrice ;  
end;

// 포지션 구하기
function TBearTrade.GetPosition: Integer;
var
  aFar, aNear : TPosition;
  aFarSymbol, aNearSymbol : TSymbol;
  iCurQty : Integer;
begin

  if FPosition = nil then
  begin
    Result := 0 ;
    exit ; 
  end ;

  iCurQty := 0;

  // 스프레드
  if FOrderSymbol.Spec.Market = mtSpread then
  begin
    aFarSymbol  := gEnv.Engine.SymbolCore.Symbols.FindCode( (FOrderSymbol as TSpread).BackMonth );
    aNearSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( (FOrderSymbol as TSpread).FrontMonth );

    aFar  := gEnv.Engine.TradeCore.Positions.Find( FAccount,aFarSymbol );
    aNear := gEnv.Engine.TradeCore.Positions.Find( FAccount,aNearSymbol );

    if (aFar <> nil) and (aNear <> nil) then
    begin
      if aFar.Volume * aNear.Volume < 0 then      // 근월물과 원월물의 부호가 다를때
      begin
        // 잔량
        iCurQty := Min(Abs(aFar.Volume), Abs(aNear.Volume));   // 절대값이 작은것
        if aFar.Volume < 0 then
          iCurQty := iCurQty * (-1) ;       // 부호는 원월물 
      end;
    end;
  end else
  // 일반 종목
  begin
    iCurQty := FPosition.Volume;
  end;

  Result := iCurQty ;
end;





// 응집 종목일때 호가 처리 로직
procedure TBearTrade.QuoteCohesionProcess(aRec: TCurrentOrder);
begin

  if ( Abs(aRec.OrderQty) >= FConfig.CohesionFilter ) and
        ( aRec.QuoteIndex <= FConfig.CohesionQuoteLevel )  then
  begin
    FOrderCohesion.MakeData(aRec);
  end;
   
end;

// 주문 종목일때 호가 처리 로직 
procedure TBearTrade.QuoteOrderProcess(aRec: TCurrentOrder);
var
  dTimeGap : Double ;
  aOrderQuote : TBearOrderQuoteItem ;
begin

  // 호가 데이터를 모은다.
  aOrderQuote := FOrderQuoteList.Add as TBearOrderQuoteItem  ;
  with  aOrderQuote do
  begin
    QuoteTime := GetQuoteTime;
    QuoteRec  := aRec.OrderQuote ;
  end;

  // 응집 종목 저장이 체크되어 있을 경우만 저장
  if FSysConfig.SaveCollectioned = false then exit ;

  // 주문 수량이 수량 필터 이상이고, 주문 가격이 현재 호가 몇 단계 인지
  if ( Abs(aRec.OrderQty) >= FSysConfig.OrderFilter ) and
    ( aRec.QuoteIndex <= FSysConfig.OrderQuoteLevel)  then
  begin

    // 파일 저장
    if FOrderSaved = true  then
    begin
      // 시작하고, 수집시간 이상 지났는지 체크
      // 지났으면,  FOptionSave -> false 로 변경
      dTimeGap := ( GetQuoteTime - FOrderSaveStartTime  ) * 24 * 3600 * 1000  ;
      if( dTimeGap > FSysConfig.OrderCollectionPeriod + EPSILON ) then
        FOrderSaved := false
      else
        SaveOrderData(aRec);
    end ;

  end;

end;

// 호가 수신 
procedure TBearTrade.QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aOrderPrice : Double;
  aOrderQty : Integer;
  aFillQty : Integer;
  aFillPrice : Double ;
  //
  aFillTime : TDateTime;
  aPositionType : TPositionType;
  aQType : TQuoteType;
  k : Integer;
  iIndex : Integer;
  //
  dAvgPrice : Double ;
  aRec : TCurrentOrder ;
  //
  iType : Integer ;
  aSymbol : TSymbol ;
  aQuote  : TQuote;

  iTrade : Integer ; 
begin


  if (Receiver <> Self) or (DataObj = nil) or
      not (DataObj is TQuote) {or
      not (iBroadcastKind in [PID_QUOTE]) }then
  begin
    gLog.Add(lkError, 'BearTrace', '호가정보', 'Data Integrity Failure');
    Exit;
  end;

  if ( FCohesionSymbol = nil ) and ( FOrderSymbol = nil ) then Exit;
  
  // -- 응집종목인지 주문종목인지 체크 
  aQuote := DataObj as TQuote ;
  aSymbol := aQuote.Symbol;

  if ( aSymbol = FCohesionSymbol)  then
    iType := 0
  else if ( aSymbol = FOrderSymbol) then
    iType := 1
  else
  begin
    gLog.Add(lkError, 'BearTrace', '호가정보', '해당 Symbol 없음 Failure');
    exit ;
  end;

  //
  if aQuoteCount[iType] = 0 then
  begin
    aQuoteRec[iType].Assign( FCohesionSymbol.Quote as TQuote );
    Inc(aQuoteCount[iType]);
    Exit;
  end;
  //
  aOrderPrice := 0;
  aOrderQty := 0;
  aFillQty := 0;
  aFillPrice := 0 ;
  //
  iTrade :=-1 ;
  
  try

  with aSymbol do
  begin
    if aQuote.LastEvent = qtTimeNSale then
    begin
      aOrderPrice := aQuote.Sales.Last.Price;
      aFillQty    := aQuote.Sales.Last.Volume;
      aFillTime   := aQuote.Sales.Last.Time;
{
* 매수 체결이 왔을때
* 0 : CohesionSymbol, 1 : OrderSymbol
* aQuote = 오더종목  /  오더종목의 체결이 왔을때.
* 오더종목 현재가가  이전 매도1호가보다 크거나 같을때..매도 1호가 잔량이 남았다는 야그
* 매수1호가 보다 현재가가 크다면
* 이번 체결이 발생할때의 주문수량은 체결수량, 아닌 경우가 나올수는 없지
}
      if aOrderPrice > aQuoteRec[iType].Asks[0].Price - PRICE_EPSILON then
      begin
        aPositionType := ptLong;
        if abs( aQuote.Bids[0].Price - aOrderPrice) < PRICE_EPSILON then
          aOrderQty := aFillQty + aQuote.Bids[0].Volume
        else
          aOrderQty := aFillQty ;
      end
      else if aOrderPrice < aQuoteRec[iType].Bids[0].Price + PRICE_EPSILON then // 체결가<=직전매수호가1
      begin
        aPositionType := ptShort;
        if abs( aQuote.Asks[0].Price - aOrderPrice ) < PRICE_EPSILON then
          aOrderQty := aFillQty + aQuote.Asks[0].Volume
        else
          aOrderQty := aFillQty;
      end
      else
      begin
        aQuoteRec[iType].Assign( aQuote );
        Inc(aQuoteCount[iType]);
        Exit;
      end;
      iIndex := 0;
      aFillPrice := aQuote.Sales.Last.Price;
    end
    else                // 호가
    begin
      for k:=0 to 4 do
      begin
        // Asks
        if aQuote.Asks[k].Price  < aQuoteRec[iType].Asks[k].Price -PRICE_EPSILON then
        begin
          aPositionType := ptShort;
          aOrderPrice := aQuote.Asks[k].Price;
          aOrderQty := aQuote.Asks[k].Volume;
        end
        else if aQuote.Asks[k].Price > aQuoteRec[iType].Asks[k].Price+PRICE_EPSILON then
        begin

          aPositionType := ptShort;
          aOrderPrice := aQuoteRec[iType].Asks[k].Price;
          aOrderQty := -aQuoteRec[iType].Asks[k].Volume;
        end
        else if aQuote.Asks[k].Volume <> aQuoteRec[iType].Asks[k].Volume then
        begin

          aPositionType := ptShort;
          aOrderPrice := aQuote.Asks[k].Volume;
          aOrderQty := aQuote.Asks[k].Volume - aQuoteRec[iType].Asks[k].Volume;
        end;

        if aOrderQty <> 0 then Break;

        // Bids

        if aQuote.Bids[k].Price > aQuoteRec[iType].Bids[k].Price + PRICE_EPSILON then
        begin
          aPositionType := ptLong;
          aOrderPrice := aQuote.Bids[k].Price;
          aOrderQty := aQuote.Bids[k].Volume;
        end
        else if aQuote.Bids[k].Price < aQuoteRec[iType].Bids[k].Price-PRICE_EPSILON then
        begin
          aPositionType := ptLong;
          aOrderPrice := aQuoteRec[iType].Bids[k].Price;
          aOrderQty := -aQuoteRec[iType].Bids[k].Volume;
        end
        else if aQuote.Bids[k].Volume <> aQuoteRec[iType].Bids[k].Volume then // 수량만 바뀜
        begin
          aPositionType := ptLong;
          aOrderPrice := aQuote.Bids[k].Price;
          aOrderQty := aQuote.Bids[k].Volume - aQuoteRec[iType].Bids[k].Volume;
        end;
        if aOrderQty <> 0 then break;
      end; // for k:=1 to 5 do
      iIndex := k;

    end;   // 호가
  end;     // with FSymbol

  aQuoteRec[iType].Assign( aSymbol.Quote as TQuote );    // Backup Quote
  Inc(aQuoteCount[iType]);

  // ----------  Bear 로직 ---------- //

  // 잔량을 통한 가중평균단가 구하기
  dAvgPrice := GetAvgPrice(aSymbol)  ;

  // Current 레코드로 데이터 Setting
  with aRec do
  begin
    PositionType := aPositionType ;
    OrderType := GetOrderType(aPositionType, aOrderQty)  ;
    OrderTime := GetQuoteTime;
    OrderQty := aOrderQty ;
    OrderPrice := aOrderPrice  ;
    FillQty := aFillQty ;
    FillPrice := aFillPrice ;
    AvgPrice := dAvgPrice ;
    PrevAvgPrice := aPrevAvgPrice[iType] ;
    QuoteIndex := iIndex ;
    if FCohesionSymbol = FOrderSymbol then
      OrderQuote := aQuoteRec[0]
    else
      OrderQuote := aQuoteRec[1] ;
  end;

  // 주문 종목일때 -> 저장 루틴
  if aSymbol = FOrderSymbol then
  begin
    QuoteOrderProcess(aRec) ;
  end ;

  // 응집 종목일때 -> 응집 루틴  대부분 선물
  if aSymbol = FCohesionSymbol then
  begin
    QuoteCohesionProcess(aRec) ;
  end ;


  // 평균단가를 직전 평균단가로 데이터 옮김
  aPrevAvgPrice[iType] := dAvgPrice ;

  except
    on E : Exception do
      gLog.Add(lkError, 'BearSystem', 'BearTrade', 'QuoteProc : ' + E.Message);
  end;


end;


// 주문 요청 결과 수신 
procedure TBearTrade.ReqChanged(Sender: TObject);
begin
  //
end;

// 주문 수신 
procedure TBearTrade.OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin

  if (FAccount = nil) or
     (DataObj = nil) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_SPAWN,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
      // fill events
    FILL_NEW: ;
      // position events
    POSITION_NEW,
    POSITION_UPDATE: DoPosition(DataObj as TPosition, EventID);
  end;
end;

procedure TBearTrade.DoOrder(aOrder: TOrder; EventID: TDistributorID);
var
  i : integer;
  aBear : TAutoOrder;
  aBearOrder  : TBearOrderItem;
begin

  if (aOrder.Account <> FAccount) or (aOrder.Symbol <> FOrderSymbol) then Exit;

  // -- 신규, 증전 접수 상태일 때만 체크
  if (aOrder.State = osActive) and (aOrder.OrderType = otNormal)  then
  begin
    aBear := FindOrder( aOrder );
    if aBear = nil then Exit;

    aBearOrder := FOrderItemList.Add as TBearOrderItem  ;
    with  aBearOrder do
    begin
      OrderTime := GetQuoteTime;
      OrderItem := aOrder ;
      CancelOrdered := false ;
    end;
  end else
  if aOrder.State in  [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
  begin
    FBearOrders.CheckOrderState( aOrder );
  end;

end;

function TBearTrade.FindOrder(aOrder : TOrder): TAutoOrder;
var
  i : integer;
  aBear : TAutoOrder;
begin
  Result := nil;

  for i := FBearOrders.Count -1 downto 0 do
  begin
    aBear := FBearOrders.AutoOrders[i];
    if aBear = nil then Continue;
    if not aBear.BSend then Continue;
    if aBear.Order = nil then Continue;

    if ( aBear.Order.LocalNo = aOrder.LocalNo ) then
    begin
      Result := aBear;
      break;
    end;
  end;
end;

procedure TBearTrade.DoPosition(aPosition: TPosition; EventID: TDistributorID);
var
  CanSelected : Boolean;
  stDailyPL : String;
begin

  //-- filter 1
  if aPosition = nil then
  begin
    //gLog.Add(lkError, 'BearSystem', '포지션정보', 'Data Integrity Failure');
    Exit;
  end;

  //-- filter 2 (not selected)
  if (FAccount = nil) or (FOrderSymbol = nil) then Exit;
  if (aPosition.Symbol <> FOrderSymbol)  then Exit;
  FPosition := aPosition;
end;
// -- 자동 취소 
procedure TBearTrade.TimerTimer(Sender: TObject);
var
  i : Integer ;
  aBearOrder : TBearOrderItem ;
  aOrder, aSOrder : TOrder ;
  aTicket : TOrderTicket;
  stLog : string;
begin

  // 자동 취소 true 일때만 작동
  if FConfig.CancelOrdered = false  then exit ;

  for i := 0 to FOrderItemList.Count - 1 do
  begin
    aBearOrder := FOrderItemList.Items[i] as TBearOrderItem ;
    aSOrder := aBearOrder.OrderItem ;
    if ( aSOrder.OrderType = otNormal ) and ( aSOrder.ActiveQty > 0) then
    begin

      // -- 시간차
      if ( ( (GetQuoteTime - aBearOrder.OrderTime)  * 24 * 3600 * 1000) > FConfig.CancelTime + EPSILON )
        and ( aBearOrder.CancelOrdered = false ) then
      begin


        // -- 취소주문은 로그 남기지 말것

        {
        gLog.Add(lkError, 'BearTrade', 'Cancel',
          '[원주문번호] ' +  IntToStr(aSOrder.OrderNo)  +
          ' [취소수량] ' +   IntToStr(aSOrder.ActiveQty),
          nil, false
        );
        }
        {
        BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime )  ,
            'Cancel',
            'Cancel ' +IntToStr(aOrder.AcptNo)
            + ',' + FormatDateTime('nn:ss:zzz' , aBearOrder.OrderTime )
            + ',' + IntToStr(aOrder.UnfillQty)
        );
        }

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aSOrder, aSorder.ActiveQty, aTicket );
        if aOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Send( aTicket );
          aBearOrder.CancelOrdered  := true;
        end ;
      end;

    end;
  end;
  
end;


// 포지션 수신 
procedure TBearTrade.PositionProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aPosition : TPosition;
  CanSelected : Boolean;
  stDailyPL : String;
begin

  //-- filter 1
  if (Receiver <> Self) or (DataObj = nil) or
      not (DataObj is TPosition) then
  begin
    //gLog.Add(lkError, 'BearSystem', '포지션정보', 'Data Integrity Failure');
    Exit;
  end;

  //-- filter 2 (not selected)
  if (FAccount = nil) or (FOrderSymbol = nil) then Exit;

  //-- get position object
  aPosition := DataObj as TPosition;
   {    //??
  //-- filter 3
  if (aPosition.Account <> FAccount) then Exit;
  if (not FOrderSymbol.IsCombination) and (aPosition.Symbol <> FOrderSymbol)  then Exit;
  if FOrderSymbol.IsCombination then
  begin
    if (FOrderSymbol.Farther <> aPosition.Symbol) and
       (FOrderSymbol.Nearest <> aPosition.Symbol) then Exit;
  end;
  }
  // set position
  FPosition := aPosition;
end;




// 신규 주문 
procedure TBearTrade.NewOrder(aCohesionSymbol, aOrderSymbol: TSymbol;
  aQuoteRec: TQuote; aCohesionPosition: TPositionType ; aCohesionData : TCohesionData);
var
  aOrder : TOrder;
  aBear  : TAutoOrder;
  dPrice : double ;
  iPosition, iActive : Integer ;
  aPositionType : TPositionType ;
  iCur, iOrderQty : Integer ;
  aTicket : TOrderTicket;
  stText : string;

begin

  // -- 종목 check
  if ( FAccount = nil )or ( aCohesionSymbol = nil  )
      or ( aOrderSymbol = nil ) or ( FConfig.OrderQty = 0  ) then
  begin

    gLog.Add(lkDebug, 'BearTrade', '주문불가',
        '종목 , 계좌 이상'
        + ' [Q] ' + IntToStr( FConfig.OrderQty)
    );

    exit ;
  end;

  // -- 포지션 구하기
  iPosition := GetPosition ;

  // -- 주문방향 구하기 
  aPositionType := GetOrderPosition(aCohesionSymbol,aOrderSymbol, aCohesionPosition) ;

  // -- 매수 -> 가격 : 매도 1호가  
  // -- 매도 -> 가격 : 매수 1호가
  dPrice := GetOrderPrice( aOrderSymbol, aPositionType, aQuoteRec );
  if aPositionType = ptLong then
  begin
    iOrderQty := Min(BEAR_MAX_ORDER_QTY,
      Min(FConfig.MaxPosition-iPosition, FConfig.OrderQty));
    iCur := iOrderQty ;
  end
  else if aPositionType = ptShort then
  begin
    iOrderQty := Min(BEAR_MAX_ORDER_QTY,
      Min(FConfig.MaxPosition+iPosition, FConfig.OrderQty));
    iCur := (-1) * iOrderQty ;
  end;


  // -- 1. 딜레이 시간 체크
  if ( FSysConfig.QuoteJamSkipUsed = true ) and
      (  aOrderSymbol.DelayMs > FSysConfig.QuoteJamSkipTime ) then
  begin

    //**

    gLog.Add(lkDebug, 'BearTrade', '주문불가',
        '딜레이시간 초과 '
        + ' [시간] ' + IntToStr(aOrderSymbol.DelayMs )
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '지연 ' +   IntToStr(aOrderSymbol.DelayMs )  + ' '
      + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit ;
  end;

  // -- 2. 주문 방향 체크
  if (  (FConfig.LongOrdered = false) and  ( aPositionType = ptLong ) )
    or (  (FConfig.ShortOrdered = false) and  (aPositionType = ptShort)  ) then
  begin
     //**

     gLog.Add(lkDebug, 'BearTrade', '주문불가',
      ' 주문방향불가! ' +  ifThenStr( aPositionType = ptLong,'매수','매도')
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '주문방향 ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit ;
  end;

   // -- 3. 주문 수량 체크
  if iOrderQty <= 0   then
  begin
     //**

    gLog.Add(lkDebug, 'BearTrade', '주문불가',
      ' 주문수량! [OrderQty] ' +  IntToStr(iOrderQty)
      + ' [iPosition] ' + IntToStr(iPosition) + ' [MaxPosition] ' + IntToStr(FConfig.MaxPosition)
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '주문수량 ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit;
  end;

  // -- 4. 최대 잔량 체크

  if CheckQuoteQty(aOrderSymbol, dPrice, aPositionType,
           FConfig.MaxQuoteQty ) = false then
  begin
    //**

    gLog.Add(lkDebug, 'BearTrade', '주문불가', ' 호가잔량초과! ' );
    //
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '잔량초과 ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit ;
  end;
      

  // -- 5. 주문가 체크
  if abs(dPrice) <= PRICE_EPSILON   then
  begin
    //**

    gLog.Add(lkDebug, 'BearTrade', '주문불가',
      ' 주문가이상! [P] ' +  Format('%.2f', [ dPrice ])
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '주문가 ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit;
  end;

  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', FAccount, aOrderSymbol,
    iCur, pcLimit, dPrice, tmFAS  );

  aOrder.OrderSpecies := opBear;    

  if aOrder = nil then
  begin
    Beep;
    Exit;
  end;
  aBear := FBearOrders.New( aOrder );

  // -- 6. 포지션 초과 체크
  iActive := 0;
  if not (FBearOrders.CheckMaxPosition( FPosition, FConfig.MaxPosition, aOrder, iActive )) then
  begin
    gLog.Add(lkDebug, 'BearTrade', '주문불가',
      ' 포지션초과! ' + ifThenStr( aPositionType = ptLong, '매수', '매도')
       + ' [P] ' + IntToStr(iPosition)
       + ' [Q] ' + IntTostr(iCur)
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '포지션 ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    FBearOrders.DeleteOrder( aBear );
    Beep;
    Exit;
  end;

  // -- 7.   자전 대상 주문 취소..
  FBearOrders.CheckSelfFillOrder( aOrderSymbol, aPositionType, dPrice, iOrderQty ) ;

  // 신규 주문 !
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  aOrder.SetTicket( aTicket );
  gEnv.Engine.TradeCore.Orders.NewOrders.Add( aOrder );


  BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
  );
  Beep;

  if FPosition <> nil then
    iActive := FPosition.Volume
  else
    iActive := 0;
  stText :=  'Pos = ' + IntToStr( iActive ) + '  ' +
     PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']';
  gLog.Add( lkDebug, 'BearTrade', 'NewOrder', stText );
  gEnv.DoLog( WIN_DEBUG, '');

  // 주문 요청 리스트에 추가
  //FOrderReqList.Add(aOrder);
  gEnv.Engine.TradeBroker.Send( aTicket );
  aBear.BSend := true;



end;

procedure TBearTrade.BearLog(Sender: TObject; stTime, stTitle, stLog: String);
begin
  if Assigned(FOnBearLog) = true then
    FOnBearLog( Self, stTime  ,  stTitle,  stLog ); 
end;

// ----------- << public >> ---------- //





constructor TBearTrade.Create;
begin

  FOrderCohesion := TOrderCohesion.Create ;
  FOrderCohesion.OnOrderSaveNotify := OrderSaveChanged ;
  FOrderCohesion.OnBearLog := BearLog ;
  FOrderCohesion.OnNewOrder := NewOrder ;
  FOrderCohesion.OnInitCohesion := InitCohesionChanged ;
  //
  FBearOrders := TBearOrders.Create;

  gEnv.Engine.TradeBroker.Subscribe( self, OrderProc);  // order position
  //
  FOrderItemList := TCollection.Create(TBearOrderItem) ;
  FOrderReqList := TList.Create ;
  FOrderQuoteList := TCollection.Create(TBearOrderQuoteItem) ;

  FOrderQuote  := TQuoteUnit.Create;
  aQuoteRec[0] := TQuoteUnit.Create;
  aQuoteRec[1] := TQuoteUnit.Create;

  end;



destructor TBearTrade.Destroy;
begin
  // 1. Stop ( FCohesionSymbol, FOrderSymbol Unsubscribe ) 
  Stop ;
  FOrderQuote.Free;
  aQuoteRec[0].Free;
  aQuoteRec[1].Free;
  // 2. unsubscribe
  gEnv.Engine.TradeBroker.Unsubscribe( self );

  // 3. Free
  if FOrderCohesion <> nil then
    FOrderCohesion.Free ;

  FOrderItemList.Free ;
  FOrderReqList.Free;
  FOrderQuoteList.Free ;

  FBearOrders.Free;
  // 
  inherited;
end;



procedure TBearTrade.Start( aSysConfig : TBearSystemConfig ; aConfig : TBearConfig );
var
  i : integer;
begin

  try

  // 1. 정지 (기존꺼) 
  Stop ;

  // 2. 계좌, 종목 할당
  FAccount := aSysConfig.Account ;
  FCohesionSymbol := aSysConfig.CohesionSymbol ;
  FOrderSymbol := aSysConfig.OrderSymbol ;

  FSysConfig := aSysConfig ; 
  FConfig := aConfig ;
                                        
  // 3. 변수 초기화
  init ;

  // 4. 파일 저장 ( 주문 종목 )
  SaveOrderHeader ;
  
  // 5. 현재 포지션, 주문 내역 수신
  for i := 0 to  gEnv.Engine.TradeCore.Positions.Count -1 do
    OrderProc( nil, self, 0, gEnv.Engine.TradeCore.Positions.Positions[i], 109 );
  for i := 0 to gEnv.Engine.TradeCore.Orders.Count - 1 do
    ORderProc( nil, self, 0, gEnv.Engine.TradeCore.Orders.Orders[i], 111 );

  // 6. Subscribe
  gEnv.Engine.QuoteBroker.Subscribe( self, FCohesionSymbol, QuoteProc );
  if FCohesionSymbol <> FOrderSymbol then
    gEnv.Engine.QuoteBroker.Subscribe( self, FOrderSymbol, QuoteProc );

  // 7. Cohesion Start
  FOrderCohesion.Start(aSysConfig , aConfig  );

  // 8. Timer 가동 ( 자동 취소 가능할때만  )
  if FConfig.CancelOrdered = true then
  begin
    if FTimer = nil then
    begin
      FTimer := gEnv.Engine.QuoteBroker.Timers.New;    // 100 ms로 고정
      with FTimer do
      begin
        Enabled := True;
        Interval := 100  ;
        OnTimer := TimerTimer;
      end;
    end
    else
      FTimer.Enabled  := True;
  end;

  except 
    on E : Exception do
      gLog.Add(lkError, 'BearTrade', 'Start',  E.Message);
  end;
  
end;

procedure TBearTrade.Stop;
begin
  //
  try

  // -- UnSubscribe
  gEnv.Engine.QuoteBroker.Cancel( self );
  // -- Stop 
  if FOrderCohesion <> nil then
    FOrderCohesion.Stop;

  // -- Timer Stop
  if FTimer <> nil then
    FTimer.Enabled := false ;

  except
    on E : Exception do
      gLog.Add(lkError, 'BearTrade', 'Start', E.Message);
  end;
end;



{ TBearOrders }

constructor TBearOrders.Create;
begin
  AutoType := atBear;
  inherited;
end;

destructor TBearOrders.Destroy;
begin

  inherited;
end;

end.
