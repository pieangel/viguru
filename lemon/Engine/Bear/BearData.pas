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
    OrderSum : Integer ;      // �����ֹ�����
    AvgPrice : Double ;       // ��մܰ�����
    OrderCnt : Integer ;      // �����Ǽ�
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
    AvgPrice : Double ;       // ��մܰ�
    PrevAvgPrice : Double ;   // ���� ��մܰ�
    QuoteIndex : Integer ;    // ��ܰ� ȣ������
    OrderQuote : TQuoteUnit ;    // �ֹ� ������ ȣ��
  end;

  TFilterOrderItem = class(TCollectionItem)
  public
    AvgPrice : Double ;     // ��մܰ�
    PositionType : TPositionType ;
    OrderTime : TDateTime ;
    OrderQty : Integer ;
    OrderPrice : Double ;
    FillQty : Integer ;
    FillPrice : Double ;
    OrderType : String ;    // L, S, X(�ż����), Y(�ŵ����)
    Quote: TQuote ;    // ȣ��
  end;

  // �ż� ó���� 1��, �ŵ� ó���� 1��
  TFilterOrderData = class
  private 
    FFileName : String ;
    FCohesionSymbol : TSymbol ;
    FOrderSymbol : TSymbol ;    // �ֹ� ���� ���� 
    FOrderQuote : TQuote ;    //�ֹ� ���� ������ ȣ��
    // 
    OrderType : String ;
    PositionType : TPositionType ;

    // -- ������ ������  
    StartTime : TDateTime ;   // ù��° ������ �ð�
    LastTime : TDateTime ;    // ������ ������ �ð�
    TimeGap : Double ;        // ù��° �����Ϳ� ������ �������� �ð� ����
    StartPrice : Double ;     // �����ֹ�����
    LastPrice : Double ;      // �����ֹ�����
    OrderSum : Integer ;      // �ֹ���
    AvgPriceGap : Double ;    // ������
    BaseAvgPrice : Double ;  //  ���� ��մܰ� ( �ֹ������� ù��° �ֹ� ������ ��մܰ� )
    FFilterOrders : TCollection ;
    // -- ������ üũ 
    NewOrdered : Boolean ;    // �ֹ������� ���� �ű��ֹ��� �������� ����
    IsCohesion : Boolean ;    // ������ �´��� ����

    // -- Config
    FConfig : TBearConfig ;
    FSysConfig : TBearSystemConfig ; 
    //
    FOnOrderSaveNotify : TNotifyEvent;    // �ֹ� ���� ������ ����
    FOnInitCohesion : TNotifyEvent ;     // �ֹ����� �ʱ�ȭ  
    FOnBearLog : TBearLogNotifyEvent ;    // �α�
    FOnNewOrder : TOrderNotifyEvent ;     // �ű� �ֹ�
    // 
    procedure AddData(aOrder : TCurrentOrder );
    procedure InitData(aOrder : TCurrentOrder );
    procedure SaveData   ;      // ���� ������ (����) ����
    procedure SaveOrders ;      // ��õ ������ (�ֹ���) ����
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
    FFileName : String ;          // ���� ������ ���� ���ϸ� 
    FCohesionSymbol : TSymbol ;
    FOrderSymbol : TSymbol ;
    FOrderData : array[TPositionType] of TFilterOrderData ;
    FConfig : TBearConfig ;
    FSysConfig : TBearSystemConfig ; 
    //
    FOnOrderSaveNotify : TNotifyEvent;    // �ֹ� ���� ������ ����
    FOnBearLog : TBearLogNotifyEvent ;    // �α�
    FOnNewOrder : TOrderNotifyEvent ;     // �ű� �ֹ�
    FOnInitCohesion : TNotifyEvent ;     // �ֹ����� �ʱ�ȭ  
    // 
    procedure SaveHeader(bReset : Boolean ) ;   // ���� ������ (����) Header ����
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

    // ���� ������ ��մܰ�
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
  // -- ��ü �ʱ�ȭ 
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

  // -- �ڱ��ڽ� Data 1�� �߰� 
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

  // -- �ʱ�ȭ ���� �˸���. 
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

    // -- ���� ���� ���ΰ� true �϶� 
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
    
    // -- ��õ ������ ����  ���ΰ� true �϶�
    if FSysConfig.SaveOrdered = true  then
      SaveOrders ;
    
  except
    on E : Exception do
      gLog.Add(lkError, 'BearData', 'SaveData', '���������� ' + E.Message );
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
      gLog.Add(lkError, 'BearData', 'SaveOrders', '���������� ' + e.Message );
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

  // 1. ���� �ʱ�ȭ 
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
  
  // ���� ������ �̻��̰�, ���� �Ǽ� �̻��̸� ����
  // ���� ��մܰ� �̻��̸�  ����
  if( ( FConfig.CohesionTotQty <= OrderSum )
      and ( FConfig.CohesionCnt <= FFilterOrders.Count )
      and ( FConfig.CohesionAvgPrice - EPSILON < AvgPriceGap )  ) then
    SaveData ;
  
end;


procedure TFilterOrderData.MakeData(aOrder: TCurrentOrder);
var
  aCurCohesionData : TCohesionData ;
begin

  // ���� �ð� �ȿ� �� ��
  {
  gLog.Add(lkDebug, 'BearTrade', 'QuoteProc',  ' [time] ' +
      FloatToSTr(( aOrder.OrderTime- LastTime ) * 24 * 3600 * 1000));
  }

  if  ( aOrder.OrderTime- LastTime ) * 24 * 3600 * 1000 < FConfig.CohesionPeriod + EPSILON then
  begin

    // ������ �߰�
    AddData(aOrder) ;

   {
   gLog.Add(lkDebug, 'BearTrade', '����üũ ',
          ifThenStr( PositionType = ptLong, '�ŵ�', '�ż�')
          + '[OrderSum] ' + IntToSTr(OrderSum)
          + '[CohesionCnt] ' + IntToStr(FFilterOrders.Count )
          +  '[AvgPrice] ' + FloatToStr(aOrder.AvgPrice)
    );
    }

    // �ֹ� �������� �� ���� true
    if( ( FConfig.CohesionTotQty <= OrderSum )
        and ( FConfig.CohesionCnt <= FFilterOrders.Count )
        and ( FConfig.CohesionAvgPrice - EPSILON < AvgPriceGap )
        and ( IsCohesion = false ) ) then
    begin

      {
      FOnBearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime )  ,
          '����!',
          '����! ' + PositionTypeDescs[PositionType]
          + '[B] ' + Format('%.2f', [ FOrderQuoteRec.Price[qtBid,1] ])+ ':'
          + IntToStr( FOrderQuoteRec.Qty[qtBid,1] )   +   ' '
          +  '[A] ' +  Format('%.2f', [ FOrderQuoteRec.Price[qtAsk,1] ]) + ':'
          + IntToStr( FOrderQuoteRec.Qty[qtAsk,1] )
      ;
      }

      // �ֹ� ���� ���� ����
      if Assigned( FOnOrderSaveNotify ) then
        OnOrderSaveNotify(Self);

      with aCurCohesionData do
      begin
        OrderSum := Self.OrderSum ;
        AvgPrice := Self.AvgPriceGap ;
        OrderCnt :=  Self.FFilterOrders.Count ;
      end;

      // ��������, �ֹ�����, �������۽� ȣ������, ������ Ÿ��, ������������
      FOnNewOrder( FCohesionSymbol, FOrderSymbol,
          FOrderQuote, PositionType, aCurCohesionData    );

      IsCohesion := true ;

    end;

  end
  else
  begin

    // ���� ������ �̻��̰�
    // ���� �Ǽ� �̻��̰�,
    // ���� ��մܰ� �̻��̸�  ����
    if( ( FConfig.CohesionTotQty <= OrderSum )
        and ( FConfig.CohesionCnt <= FFilterOrders.Count )
        and ( FConfig.CohesionAvgPrice - EPSILON < AvgPriceGap )  ) then
    begin

      {
      FOnBearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime )  ,
          '����!', '�������� ' + PositionTypeDescs[PositionType]   );
      }

      SaveData ;
    end;

    // ������ �ʱ�ȭ
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

  FFileName := gEnv.LogDir + '\' + 'Bear_��������_' + FCohesionSymbol.Name + '_' +
    FormatDateTime('yyyymmdd' , GetQuoteTime  )  + '.csv' ;
  stHeader := '�����ڵ�,���۽ð�,����ð�,�ð�����,����,�����ֹ�,�����ֹ�,�ֹ���,�Ǽ�' +
    ',��մܰ�,��մܰ�����,�ŵ�1,�ŵ�1,�ż�1,�ż�1' ;
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
      gLog.Add(lkError, 'BearData', 'SaveHeader', '���������� ' + e.Message);
  end;

end;

procedure TOrderCohesion.OrderSaveChanged(Sender: TObject);
begin
  // ���� �̺�Ʈ�� �÷��� ( BullTrade ) 
  if Assigned(FOnOrderSaveNotify) then
    FOnOrderSaveNotify(Self);
end;

procedure TOrderCohesion.InitCohesionChanged(Sender: TObject);
begin
  // ���� �̺�Ʈ�� �÷��� ( BullTrade )
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



// -- Start ��ư ��������
procedure TOrderCohesion.Start( aSysConfig : TBearSystemConfig;
  aConfig: TBearConfig);
begin
  // 1. ���� �Ҵ�
  FCohesionSymbol := aSysConfig.CohesionSymbol ;
  FOrderSymbol :=  aSysConfig.OrderSymbol ;
  FConfig := aConfig ;
  FSysConfig := aSysConfig ; 
  
  // 2. ���� ��� ����
  SaveHeader(true);
   
  // 3. �ż�/�ŵ� ���� ����
  FOrderData[ptLong].Start(aSysConfig,aConfig, FFileName)  ;
  FOrderData[ptShort].Start(aSysConfig,aConfig, FFileName) ;

end;

// -- Stop ��ư �������� 
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

// -- �����Ͱ� ���´�.
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
