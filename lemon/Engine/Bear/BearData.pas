unit BearData;

interface

uses
  Classes , SysUtils,
  //
  {
  ,Broadcaster, SymbolStore, PriceCentral, AppTypes, LogCentral
  ,QuoteTimer , Globals, AccountStore, TradeCentral, PositionStore
  ,OrderStore 
  }
  //
  GleTypes, CleSymbols, GleConsts, CleQuoteTimers,
  CleTradeCore , CleAccounts , CleQuoteBroker
  , BearConfig , BearLog ;

type

  TCohesionData = record
    OrderSum : Integer ;      // 응집주문수량
    AvgPrice : Double ;       // 평균단가차이
    OrderCnt : Integer ;      // 응집건수
  end;
  
  TOrderNotifyEvent =
    procedure( aCohesionSymbol : TSymbol ; aOrderSymbol :  TSymbol ;
       aQuote : TQuote ; aCohesionPosition : TPositionType ;
       aCohesionData : TCohesionData ) of Object;

  TCurrentOrder = record
    PositionType : TPositionType ;
    OrderType : String ;
    OrderTime : TDateTime ;
    OrderQty : Integer ;
    OrderPrice : Double ;
    FillQty : Integer ;
    FillPrice : Double ;
    AvgPrice : Double ;       // 평균단가
    PrevAvgPrice : Double ;   // 직전 평균단가
    QuoteIndex : Integer ;    // 몇단계 호가인지
    OrderQuote : TQuoteUnit ;    // 주문 종목의 호가
  end;

  TFilterOrderItem = class(TCollectionItem)
  public
    AvgPrice : Double ;     // 평균단가
    PositionType : TPositionType ;
    OrderTime : TDateTime ;
    OrderQty : Integer ;
    OrderPrice : Double ;
    FillQty : Integer ;
    FillPrice : Double ;
    OrderType : String ;    // L, S, X(매수취소), Y(매도취소)
    Quote: TQuote ;    // 호가
  end;

  // 매수 처리용 1개, 매도 처리용 1개
  TFilterOrderData = class
  private 
    FFileName : String ;
    FCohesionSymbol : TSymbol ;
    FOrderSymbol : TSymbol ;    // 주문 나갈 종목 
    FOrderQuote : TQuote ;    //주문 나갈 종목의 호가
    // 
    OrderType : String ;
    PositionType : TPositionType ;

    // -- 수집건 데이터  
    StartTime : TDateTime ;   // 첫번째 데이터 시간
    LastTime : TDateTime ;    // 마지막 데이터 시간
    TimeGap : Double ;        // 첫번째 데이터와 마지막 데이터의 시간 간격
    StartPrice : Double ;     // 시작주문가격
    LastPrice : Double ;      // 종료주문가격
    OrderSum : Integer ;      // 주문합
    AvgPriceGap : Double ;    // 가격차
    BaseAvgPrice : Double ;  //  직전 평균단가 ( 주문응집의 첫번째 주문 직전의 평균단가 )
    FFilterOrders : TCollection ;
    // -- 데이터 체크 
    NewOrdered : Boolean ;    // 주문응집에 대해 신규주문이 나갔는지 여부
    IsCohesion : Boolean ;    // 응집이 맞는지 여부

    // -- Config
    FConfig : TBearConfig ;
    FSysConfig : TBearSystemConfig ; 
    //
    FOnOrderSaveNotify : TNotifyEvent;    // 주문 종목 데이터 저장
    FOnInitCohesion : TNotifyEvent ;     // 주문응집 초기화  
    FOnBearLog : TBearLogNotifyEvent ;    // 로그
    FOnNewOrder : TOrderNotifyEvent ;     // 신규 주문
    // 
    procedure AddData(aOrder : TCurrentOrder );
    procedure InitData(aOrder : TCurrentOrder );
    procedure SaveData   ;      // 응집 데이터 (종합) 저장
    procedure SaveOrders ;      // 원천 데이터 (주문건) 저장
  public
    constructor Create(aPositionType : TPositionType) ;
    destructor Destroy; override;
    procedure MakeData( aOrder : TCurrentOrder )  ;
    procedure Start( aSysConfig : TBearSystemConfig ; 
      aConfig : TBearConfig  ; aFileName : String  ) ;
    procedure Stop ;
    //
    property OnBearLog : TBearLogNotifyEvent read FOnBearLog write FOnBearLog;
    property OnOrderSaveNotify : TNotifyEvent read FOnOrderSaveNotify write FOnOrderSaveNotify ;
    property OnNewOrder : TOrderNotifyEvent read FOnNewOrder write FOnNewOrder;
    property OnInitCohesion : TNotifyEvent read FOnInitCohesion write FOnInitCohesion ;

  end;

  TOrderCohesion = class
  private
    FFileName : String ;          // 응집 데이터 저장 파일명 
    FCohesionSymbol : TSymbol ;
    FOrderSymbol : TSymbol ;
    FOrderData : array[TPositionType] of TFilterOrderData ;
    FConfig : TBearConfig ;
    FSysConfig : TBearSystemConfig ; 
    //
    FOnOrderSaveNotify : TNotifyEvent;    // 주문 종목 데이터 저장
    FOnBearLog : TBearLogNotifyEvent ;    // 로그
    FOnNewOrder : TOrderNotifyEvent ;     // 신규 주문
    FOnInitCohesion : TNotifyEvent ;     // 주문응집 초기화  
    // 
    procedure SaveHeader(bReset : Boolean ) ;   // 응집 데이터 (종합) Header 저장
    procedure OrderSaveChanged(Sender: TObject);
    procedure InitCohesionChanged(Sender: TObject);
    procedure BearLog( Sender: TObject ; 
        stTime:String ; stTitle:String ; stLog : String );
    procedure NewOrder( aCohesionSymbol : TSymbol ; aOrderSymbol :  TSymbol ;
       aQuote : TQuote ; aCohesionPosition : TPositionType ;
       aCohesionData : TCohesionData ) ; 
  public
    constructor Create ;
    destructor Destroy; override;
    procedure Start(aSysConfig : TBearSystemConfig;
      aConfig : TBearConfig ) ;
    procedure Stop ;
    function MakeData(aCurOrder : TCurrentOrder) : Boolean ;
    //
    property OnBearLog : TBearLogNotifyEvent read FOnBearLog write FOnBearLog; 
    property OnOrderSaveNotify : TNotifyEvent read FOnOrderSaveNotify write FOnOrderSaveNotify ;
    property OnNewOrder : TOrderNotifyEvent read FOnNewOrder write FOnNewOrder;
    property OnInitCohesion : TNotifyEvent read FOnInitCohesion write FOnInitCohesion ;
  end;

function GetOrderType( aPositionType : TPositionType ; iOrderQty : Integer ) : String ;
  
implementation

uses GAppEnv, GleLib;

const
  LONG_ORDER = 'L' ;
  LONG_CANCEL = 'X' ; 
  SHORT_ORDER = 'S' ;
  SHORT_CANCEL = 'Y' ;
  
function GetOrderType(aPositionType: TPositionType;
  iOrderQty: Integer): String;
var
  stOrder : String ;
begin
  if aPositionType = ptLong then
  begin
    if iOrderQty > 0 then
      stOrder := LONG_ORDER
    else
      stOrder := LONG_CANCEL ;
  end
  else
  begin
    if iOrderQty > 0 then
      stOrder := SHORT_ORDER 
    else
      stOrder := SHORT_CANCEL ;
  end;
  //
  Result := stOrder ;  
end;


{ TFilterOrderData }

// ----------- << private >> ----------- //

procedure TFilterOrderData.AddData(aOrder: TCurrentOrder);
var
  aFilterOrder : TFilterOrderItem ; 
  dGap : Double ;
  aQuote : TQuote;
begin

  with aOrder do
  begin
    LastTime := OrderTime ;
    LastPrice := OrderPrice ;
    OrderSum := OrderSum + abs(OrderQty) ;

    // 이전 응집의 평균단가
    if FFilterOrders.Count > 0 then
      dGap := abs( BaseAvgPrice - aOrder.AvgPrice )
    else
      dGap := 0 ;
    //

    if AvgPriceGap < dGap + EPSILON then
      AvgPriceGap := dGap ;
  end;

  // -- Data
  aFilterOrder := FFilterOrders.Add as TFilterOrderItem  ;
  aQuote  := FCohesionSymbol.Quote as TQuote; //gEnv.Engine.QuoteBroker.Find( FCohesionSymbol.Code );

  with  aFilterOrder do
  begin
    AvgPrice := aOrder.AvgPrice ;
    OrderTime := aOrder.OrderTime ;
    PositionType := aOrder.PositionType ;
    OrderType := aOrder.OrderType ;
    OrderQty := aOrder.OrderQty ;
    OrderPrice := aOrder.OrderPrice ;
    FillQty := aOrder.FillQty ;
    FillPrice := aOrder.FillPrice ;
    OrderType := aOrder.OrderType ;
    Quote := aQuote;
  end;

end;

procedure TFilterOrderData.InitData(aOrder: TCurrentOrder);
var
  aFilterOrder : TFilterOrderItem ;
begin
  // -- 자체 초기화 
  with aOrder do
  begin 
    NewOrdered := false ;
    IsCohesion := false ;
    // 
    StartTime := OrderTime ;
    LastTime := OrderTime ; 
    StartPrice := OrderPrice ;
    LastPrice := OrderPrice ;
    OrderSum := abs(OrderQty) ;
    AvgPriceGap := 0 ;
    BaseAvgPrice := PrevAvgPrice ;
    //
    FOrderQuote :=  gEnv.Engine.QuoteBroker.Find( FOrderSymbol.Code );
  end;

  FFilterOrders.Clear ;

  // -- 자기자신 Data 1건 추가 
  aFilterOrder := FFilterOrders.Add as TFilterOrderItem  ;
  with  aFilterOrder do
  begin
    AvgPrice := aOrder.AvgPrice ; 
    OrderTime := aOrder.OrderTime ;
    PositionType := aOrder.PositionType ;
    OrderType := aOrder.OrderType ;
    OrderQty := aOrder.OrderQty ;
    OrderPrice := aOrder.OrderPrice ;
    FillQty := aOrder.FillQty ;
    FillPrice := aOrder.FillPrice ;
    OrderType := aOrder.OrderType ;
    Quote := gEnv.Engine.QuoteBroker.Find( FCohesionSymbol.Code );
  end;

  // -- 초기화 함을 알린다. 
  if Assigned( FOnInitCohesion ) then
    OnInitCohesion(Self);
    
end;

procedure TFilterOrderData.SaveData;
var
  TF : TextFile ;
  i : Integer ;
  stData : String ;
begin

  try

    // -- 응집 저장 여부가 true 일때 
    if FSysConfig.SaveCohesioned = true then
    begin

    TimeGap := ( LastTime - StartTime ) * 24 * 3600 * 1000  ;
    AssignFile(TF, FFileName );
    Append(TF);

    stData := FCohesionSymbol.Name
        + ',' +  FormatDateTime('hh:nn:ss:zzz' , StartTime )
        + ',' +  FormatDateTime('hh:nn:ss:zzz' , LastTime )
        + ',' +  Format('%.2f', [ TimeGap ])
        + ',' +  OrderType
        + ',' + Format('%.2f', [ StartPrice ])
        + ',' + Format('%.2f', [ LastPrice ])
        + ',' + IntToStr(OrderSum)
        + ',' + IntToStr(FFilterOrders.Count)
        + ',' + Format('%.5f', [ BaseAvgPrice ])
        + ',' + Format('%.5f', [ AvgPriceGap ])
        + ',' + Format('%.2f', [ FOrderQuote.Asks[0].Price])
        + ',' + Format('%.2f', [ FOrderQuote.Bids[0].Price ])
        ;
    Writeln(TF, stData);
    CloseFile(TF);

    end;
    
    // -- 원천 데이터 저장  여부가 true 일때
    if FSysConfig.SaveOrdered = true  then
      SaveOrders ;
    
  except
    on E : Exception do
      gLog.Add(lkError, 'BearData', 'SaveData', '비정상종료 ' + E.Message );
  end;
  
end;

procedure TFilterOrderData.SaveOrders;
var
  TF : TextFile ;
  i : Integer ;
  stData : String ;
begin

  try
    AssignFile(TF, FFileName );
    Append(TF);

    for i := 0 to FFilterOrders.Count - 1 do
    begin
      with FFilterOrders.Items[i] as TFilterOrderItem do
      begin
        stData := ',' + IntToStr(i)  
        + ',' +  FormatDateTime('hh:nn:ss:zzz' , OrderTime )
        + ',' 
        + ',' +  OrderType
        + ',' + Format('%.2f', [ OrderPrice ])
        + ',' 
        + ',' + IntToStr(OrderQty)
        + ','
        + ',' + Format('%.5f', [ AvgPrice ])
        + ',' + Format('%.5f', [ abs(BaseAvgPrice-AvgPrice) ])
        + ',' + IntToStr(  Quote.Asks[0].Volume )//  .Qty[qtAsk,1])
        + ',' + Format('%.2f', [ Quote.Asks[0].Price ])//    QuoteRec.Price[qtAsk, 1]])
        + ',' + Format('%.2f', [ Quote.Bids[0].Price ])
        + ',' + IntToStr(Quote.Bids[0].Volume )
        ;
      end;
      Writeln(TF, stData);

    end ;

    CloseFile(TF);
    
  except
    on E : Exception do
      gLog.Add(lkError, 'BearData', 'SaveOrders', '비정상종료 ' + e.Message );
  end;
  
end;


// ----------- << public >> ----------- //

constructor TFilterOrderData.Create(aPositionType : TPositionType);  
begin

  PositionType := aPositionType ;  
  // 
  FFilterOrders :=
    TCollection.Create(TFilterOrderItem) ;
  
end;

destructor TFilterOrderData.Destroy;
begin
  FFilterOrders.Free ; 
  //
  inherited;
end;

procedure TFilterOrderData.Start( aSysConfig : TBearSystemConfig ;
  aConfig: TBearConfig ; aFileName : String );
begin

  // 1. 변수 초기화 
  StartTime := 0 ;
  LastTime := 0 ;
  TimeGap := 0 ;
  StartPrice := 0 ;
  LastPrice := 0 ;
  OrderSum := 0 ;
  AvgPriceGap := 0 ;
  BaseAvgPrice := 0 ; 
  FFilterOrders.Clear ;

  // 2. Config
  FCohesionSymbol := aSysConfig.CohesionSymbol ;
  FOrderSymbol := aSysConfig.OrderSymbol ;
  FFileName := aFileName ;
  FConfig := aConfig ;
  FSysConfig := aSysConfig ;
  
  {
  FOnBearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime )  ,
    'Start!', 'Service Start!' );
  }  
end;

procedure TFilterOrderData.Stop;
begin
  
  // 기준 수량합 이상이고, 기준 건수 이상이면 저장
  // 기준 평균단가 이상이면  저장
  if( ( FConfig.CohesionTotQty <= OrderSum )
      and ( FConfig.CohesionCnt <= FFilterOrders.Count )
      and ( FConfig.CohesionAvgPrice - EPSILON < AvgPriceGap )  ) then
    SaveData ;
  
end;


procedure TFilterOrderData.MakeData(aOrder: TCurrentOrder);
var
  aCurCohesionData : TCohesionData ;
begin

  // 연속 시간 안에 들어갈 때
  {
  gLog.Add(lkDebug, 'BearTrade', 'QuoteProc',  ' [time] ' +
      FloatToSTr(( aOrder.OrderTime- LastTime ) * 24 * 3600 * 1000));
  }

  if  ( aOrder.OrderTime- LastTime ) * 24 * 3600 * 1000 < FConfig.CohesionPeriod + EPSILON then
  begin

    // 데이터 추가
    AddData(aOrder) ;

   {
   gLog.Add(lkDebug, 'BearTrade', '응집체크 ',
          ifThenStr( PositionType = ptLong, '매도', '매수')
          + '[OrderSum] ' + IntToSTr(OrderSum)
          + '[CohesionCnt] ' + IntToStr(FFilterOrders.Count )
          +  '[AvgPrice] ' + FloatToStr(aOrder.AvgPrice)
    );
    }

    // 주문 응집인지 안 순간 true
    if( ( FConfig.CohesionTotQty <= OrderSum )
        and ( FConfig.CohesionCnt <= FFilterOrders.Count )
        and ( FConfig.CohesionAvgPrice - EPSILON < AvgPriceGap )
        and ( IsCohesion = false ) ) then
    begin

      {
      FOnBearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime )  ,
          '응집!',
          '응집! ' + PositionTypeDescs[PositionType]
          + '[B] ' + Format('%.2f', [ FOrderQuoteRec.Price[qtBid,1] ])+ ':'
          + IntToStr( FOrderQuoteRec.Qty[qtBid,1] )   +   ' '
          +  '[A] ' +  Format('%.2f', [ FOrderQuoteRec.Price[qtAsk,1] ]) + ':'
          + IntToStr( FOrderQuoteRec.Qty[qtAsk,1] )
      ;
      }

      // 주문 종목 저장 시작
      if Assigned( FOnOrderSaveNotify ) then
        OnOrderSaveNotify(Self);

      with aCurCohesionData do
      begin
        OrderSum := Self.OrderSum ;
        AvgPrice := Self.AvgPriceGap ;
        OrderCnt :=  Self.FFilterOrders.Count ;
      end;

      // 응집종목, 주문종목, 응집시작시 호가정보, 포지션 타입, 현재응집상태
      FOnNewOrder( FCohesionSymbol, FOrderSymbol,
          FOrderQuote, PositionType, aCurCohesionData    );

      IsCohesion := true ;

    end;

  end
  else
  begin

    // 기준 수량합 이상이고
    // 기준 건수 이상이고,
    // 기준 평균단가 이상이면  저장
    if( ( FConfig.CohesionTotQty <= OrderSum )
        and ( FConfig.CohesionCnt <= FFilterOrders.Count )
        and ( FConfig.CohesionAvgPrice - EPSILON < AvgPriceGap )  ) then
    begin

      {
      FOnBearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime )  ,
          '응집!', '응집종료 ' + PositionTypeDescs[PositionType]   );
      }

      SaveData ;
    end;

    // 데이터 초기화
    InitData(aOrder);

  end;

end;



{ TOrderCohesion }

// ----------- << private >> ----------- //

procedure TOrderCohesion.SaveHeader(bReset: Boolean);
var
  TF : TextFile ;
  stHeader : String ;
begin

  FFileName := gEnv.LogDir + '\' + 'Bear_응집종목_' + FCohesionSymbol.Name + '_' +
    FormatDateTime('yyyymmdd' , GetQuoteTime  )  + '.csv' ;
  stHeader := '종목코드,시작시각,종료시각,시간간격,구분,시작주문,종료주문,주문합,건수' +
    ',평균단가,평균단가차이,매도1,매도1,매수1,매수1' ;
  try
    AssignFile(TF, FFileName );
    if bReset = true then
      Rewrite(TF)
    else
      Append(TF);
    //
    Writeln(TF, stHeader);
    CloseFile(TF);

  except
    on E : Exception do
      gLog.Add(lkError, 'BearData', 'SaveHeader', '비정상종료 ' + e.Message);
  end;

end;

procedure TOrderCohesion.OrderSaveChanged(Sender: TObject);
begin
  // 상위 이벤트로 올려줌 ( BullTrade ) 
  if Assigned(FOnOrderSaveNotify) then
    FOnOrderSaveNotify(Self);
end;

procedure TOrderCohesion.InitCohesionChanged(Sender: TObject);
begin
  // 상위 이벤트로 올려줌 ( BullTrade )
  if Assigned(FOnInitCohesion) then
    FOnInitCohesion(Self);
end;

procedure TOrderCohesion.BearLog(Sender: TObject; stTime, stTitle,
  stLog: String);
begin

  if Assigned(FOnBearLog) = true then
    FOnBearLog( Self, stTime  ,  stTitle,  stLog ); 
    
end;


procedure TOrderCohesion.NewOrder(aCohesionSymbol, aOrderSymbol: TSymbol;
  aQuote : TQuote; aCohesionPosition: TPositionType; aCohesionData : TCohesionData);
begin
  //
  if Assigned(FOnNewOrder) = true then
    FOnNewOrder( aCohesionSymbol, aOrderSymbol,
      aQuote,  aCohesionPosition, aCohesionData );
  
end;

// ----------- << public >> ----------- //



constructor TOrderCohesion.Create; 
begin

  FOrderData[ptLong] := TFilterOrderData.Create(ptLong) ;
  FOrderData[ptLong].OnOrderSaveNotify := OrderSaveChanged ;
  FOrderData[ptLong].OnBearLog := BearLog ;
  FOrderData[ptLong].OnNewOrder := NewOrder ;
  FOrderData[ptLong].OnInitCohesion := InitCohesionChanged ; 
  // 
  FOrderData[ptShort] := TFilterOrderData.Create(ptShort) ;
  FOrderData[ptShort].OnOrderSaveNotify := OrderSaveChanged ;
  FOrderData[ptShort].OnBearLog := BearLog ;
  FOrderData[ptShort].OnNewOrder := NewOrder ;
  FOrderData[ptShort].OnInitCohesion := InitCohesionChanged ; 
  
end;

destructor TOrderCohesion.Destroy;
begin

  if FOrderData[ptLong] <> nil then
    FOrderData[ptLong].Free ;
  if FOrderData[ptShort] <> nil then
    FOrderData[ptShort].Free ;
  // 
  inherited;
end;



// -- Start 버튼 눌렀을때
procedure TOrderCohesion.Start( aSysConfig : TBearSystemConfig;
  aConfig: TBearConfig);
begin
  // 1. 변수 할당
  FCohesionSymbol := aSysConfig.CohesionSymbol ;
  FOrderSymbol :=  aSysConfig.OrderSymbol ;
  FConfig := aConfig ;
  FSysConfig := aSysConfig ; 
  
  // 2. 파일 헤더 저장
  SaveHeader(true);
   
  // 3. 매수/매도 서비스 시작
  FOrderData[ptLong].Start(aSysConfig,aConfig, FFileName)  ;
  FOrderData[ptShort].Start(aSysConfig,aConfig, FFileName) ;

end;

// -- Stop 버튼 눌렀을때 
procedure TOrderCohesion.Stop;
begin

  if FOrderData[ptLong].LastTime < FOrderData[ptShort].LastTime  then
  begin
    FOrderData[ptLong].Stop ;
    FOrderData[ptShort].Stop ;
  end
  else
  begin
    FOrderData[ptShort].Stop ;
    FOrderData[ptLong].Stop ;
  end;
  
end;

// -- 데이터가 들어온다.
function TOrderCohesion.MakeData(aCurOrder: TCurrentOrder): Boolean;
var
  stType : String ;
begin

  stType := aCurOrder.OrderType ; 
  if(  ( stType = 'L' )  or   ( stType = 'Y' ) ) then
  begin
    FOrderData[ptLong].MakeData(aCurOrder)  ;
  end
  else  // S or X ( Long Cancel )
  begin
    FOrderData[ptShort].MakeData(aCurOrder);
  end ;

end;




end.
