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
    OrderTime : TDateTime ;     // �ֹ��ð�
    OrderItem : TOrder ;
    CancelOrdered : Boolean;    // �ѹ� ��� �ֹ��� �´��� ����
  end;

  TBearOrderQuoteItem = class(TCollectionItem)
  public
    QuoteTime : TDateTime ;   // �ֹ��ð�
    QuoteRec : TQuoteUnit ;    // ȣ��
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

    // �ڵ� ��Ҹ� ���� Ÿ�̸�
    FTimer : TQuoteTimer;
    
    // �ֹ� ���� ������ �����ϱ� ���� ���� 
    FOrderSaved : Boolean ;
    FOrderSaveStartTime : TDateTime ;
    FOrderFileName : String ;    
    
    // 0 : CohesionSymbol, 1 : OrderSymbol
    aQuoteCount : array[0..1] of Integer;
    aQuoteRec : array[0..1]  of TQuoteUnit;
    aPrevAvgPrice : array[0..1] of Double ; // ���� ��մܰ�
    
    //
    FOrderItemList : TCollection ;  // �ֹ� Item  ( TCollectionItem ) 
    FOrderReqList : TList ;         // �ֹ� ��û  ( TOrderReqItem )
    FOrderQuoteList : TCollection ;   // �ֹ� ������ ȣ�� ������ ( TCollectionItem )

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

// -- ������ �ʱ�ȭ ������ �˸��� 
procedure TBearTrade.InitCohesionChanged(Sender: TObject);
var
  aOrderQuote : TBearOrderQuoteItem ;
  aQuote  : TQuote;
begin
  // 1. ȣ�� ������ �ʱ�ȭ
  FOrderQuoteList.Clear ;
  // 2. ���� ȣ��
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
  FOrderFileName := gEnv.LogDir + '\' +'Bear_�ֹ�����_' + FOrderSymbol.Name + '_' +
    FormatDateTime('yyyymmdd' , GetQuoteTime  )  + '.csv' ;
  //
  stHeader := '�����ڵ�,�ֹ��ð�,����,�ֹ�����,�ֹ�����,��մܰ�,�ŵ�2,�ŵ�2,�ŵ�1,�ŵ�1,�ż�1,�ż�1,�ż�2,�ż�2' ;
  try
    AssignFile(TF, FOrderFileName );
    Rewrite(TF);
    //
    Writeln(TF, stHeader);
    CloseFile(TF);

  except
    on E : Exception do
      gLog.Add(lkError, 'TBearTrade', 'SaveOrderHeader', '���������� ' + e.Message );
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
      gLog.Add(lkError, 'TBearTrade', 'SaveOrderData', '���������� ' + e.Message );
  end;

end;

// ���� �ʱ�ȭ
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




// ��մܰ� ���ϱ� 
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


// ��ƽ �� 
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

// ��ƽ �� 
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

  // -- �ż� �ֹ��϶� �ŵ� �ܷ�, �ŵ� �ֹ��϶� �ż� �ܷ� 
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

// ȣ�� �ܷ� üũ 
function TBearTrade.CheckQuoteQty(aOrderSymbol: TSymbol; dPrice: Double;
   aPositionType : TPositionType ; iMaxQty: Integer): Boolean;
var
  aQuote : TQuote ;
  dNextPrice : Double ;
  iQty, iNextQty : Integer ;
  stLog, stQuoteType : String ;
  i : Integer ; 
begin
  
  // -- ���� ȣ�� 
  aQuote := aOrderSymbol.Quote as TQuote ;

  if aPositionType = ptLong then
  begin
    stQuoteType := ' �ŵ��ܷ�' ;
    dNextPrice := IncStep( aOrderSymbol, dPrice) ;
  end
  else if aPositionType = ptShort then
  begin
     stQuoteType := ' �ż��ܷ�' ; 
    dNextPrice := DecStep(aOrderSymbol, dPrice  )   ;
  end ;
  
  // dPrice ��  dNext �Ѵ� üũ
  iQty := GetQuoteQty(aQuote, dPrice, aPositionType);
  iNextQty := GetQuoteQty(aQuote, dNextPrice, aPositionType);

  stLog :=
     '�ܷ�üũ ' + PositionTypeLog[aPositionType] + stQuoteType
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

  // �۾�� true 
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

  // -- �ð��� ���  ( ���� ���ۼ������� ��ȣ�� ���������� ȣ������  üũ )
  if FSysConfig.OrderQuoteTimeUsed = true then
  begin

    aNow :=  GetQuoteTime ;
    for i := 0 to FOrderQuoteList.Count-1 do
    begin
      aOrderQuote := FOrderQuoteList.Items[i] as TBearOrderQuoteItem ;

      // 2007.08.08 �ð� ��� ���� 
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

      // -- Config�� ������ �ð������� �۾����� ������ ����
      if(  dTimeGap < FSysConfig.OrderQuoteTime ) then
      begin
        if( i = 0 ) then
        begin
          //2007.08.19  �ż��ֹ� -> �ż�1ȣ�� + 1tick , �ŵ��ֹ� -> �ŵ�1ȣ�� - 1tick
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
  else  // -- �ٷ� ���� ȣ�� ��� 
  begin

    //2007.08.19  �ż��ֹ� -> �ż�1ȣ�� + 1tick , �ŵ��ֹ� -> �ŵ�1ȣ�� - 1tick
    if aPositionType = ptLong then
      dPrice := IncStep( aOrderSymbol, aQuoteRec.Bids[0].Price )
    else if aPositionType = ptShort then
      dPrice := DecStep(aOrderSymbol, aQuoteRec.Asks[0].Price );

    {
    // �������� �ٷ� ���� 1ȣ��
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

// ������ ���ϱ�
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

  // ��������
  if FOrderSymbol.Spec.Market = mtSpread then
  begin
    aFarSymbol  := gEnv.Engine.SymbolCore.Symbols.FindCode( (FOrderSymbol as TSpread).BackMonth );
    aNearSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( (FOrderSymbol as TSpread).FrontMonth );

    aFar  := gEnv.Engine.TradeCore.Positions.Find( FAccount,aFarSymbol );
    aNear := gEnv.Engine.TradeCore.Positions.Find( FAccount,aNearSymbol );

    if (aFar <> nil) and (aNear <> nil) then
    begin
      if aFar.Volume * aNear.Volume < 0 then      // �ٿ����� �������� ��ȣ�� �ٸ���
      begin
        // �ܷ�
        iCurQty := Min(Abs(aFar.Volume), Abs(aNear.Volume));   // ���밪�� ������
        if aFar.Volume < 0 then
          iCurQty := iCurQty * (-1) ;       // ��ȣ�� ������ 
      end;
    end;
  end else
  // �Ϲ� ����
  begin
    iCurQty := FPosition.Volume;
  end;

  Result := iCurQty ;
end;





// ���� �����϶� ȣ�� ó�� ����
procedure TBearTrade.QuoteCohesionProcess(aRec: TCurrentOrder);
begin

  if ( Abs(aRec.OrderQty) >= FConfig.CohesionFilter ) and
        ( aRec.QuoteIndex <= FConfig.CohesionQuoteLevel )  then
  begin
    FOrderCohesion.MakeData(aRec);
  end;
   
end;

// �ֹ� �����϶� ȣ�� ó�� ���� 
procedure TBearTrade.QuoteOrderProcess(aRec: TCurrentOrder);
var
  dTimeGap : Double ;
  aOrderQuote : TBearOrderQuoteItem ;
begin

  // ȣ�� �����͸� ������.
  aOrderQuote := FOrderQuoteList.Add as TBearOrderQuoteItem  ;
  with  aOrderQuote do
  begin
    QuoteTime := GetQuoteTime;
    QuoteRec  := aRec.OrderQuote ;
  end;

  // ���� ���� ������ üũ�Ǿ� ���� ��츸 ����
  if FSysConfig.SaveCollectioned = false then exit ;

  // �ֹ� ������ ���� ���� �̻��̰�, �ֹ� ������ ���� ȣ�� �� �ܰ� ����
  if ( Abs(aRec.OrderQty) >= FSysConfig.OrderFilter ) and
    ( aRec.QuoteIndex <= FSysConfig.OrderQuoteLevel)  then
  begin

    // ���� ����
    if FOrderSaved = true  then
    begin
      // �����ϰ�, �����ð� �̻� �������� üũ
      // ��������,  FOptionSave -> false �� ����
      dTimeGap := ( GetQuoteTime - FOrderSaveStartTime  ) * 24 * 3600 * 1000  ;
      if( dTimeGap > FSysConfig.OrderCollectionPeriod + EPSILON ) then
        FOrderSaved := false
      else
        SaveOrderData(aRec);
    end ;

  end;

end;

// ȣ�� ���� 
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
    gLog.Add(lkError, 'BearTrace', 'ȣ������', 'Data Integrity Failure');
    Exit;
  end;

  if ( FCohesionSymbol = nil ) and ( FOrderSymbol = nil ) then Exit;
  
  // -- ������������ �ֹ��������� üũ 
  aQuote := DataObj as TQuote ;
  aSymbol := aQuote.Symbol;

  if ( aSymbol = FCohesionSymbol)  then
    iType := 0
  else if ( aSymbol = FOrderSymbol) then
    iType := 1
  else
  begin
    gLog.Add(lkError, 'BearTrace', 'ȣ������', '�ش� Symbol ���� Failure');
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
* �ż� ü���� ������
* 0 : CohesionSymbol, 1 : OrderSymbol
* aQuote = ��������  /  ���������� ü���� ������.
* �������� ���簡��  ���� �ŵ�1ȣ������ ũ�ų� ������..�ŵ� 1ȣ�� �ܷ��� ���Ҵٴ� �߱�
* �ż�1ȣ�� ���� ���簡�� ũ�ٸ�
* �̹� ü���� �߻��Ҷ��� �ֹ������� ü�����, �ƴ� ��찡 ���ü��� ����
}
      if aOrderPrice > aQuoteRec[iType].Asks[0].Price - PRICE_EPSILON then
      begin
        aPositionType := ptLong;
        if abs( aQuote.Bids[0].Price - aOrderPrice) < PRICE_EPSILON then
          aOrderQty := aFillQty + aQuote.Bids[0].Volume
        else
          aOrderQty := aFillQty ;
      end
      else if aOrderPrice < aQuoteRec[iType].Bids[0].Price + PRICE_EPSILON then // ü�ᰡ<=�����ż�ȣ��1
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
    else                // ȣ��
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
        else if aQuote.Bids[k].Volume <> aQuoteRec[iType].Bids[k].Volume then // ������ �ٲ�
        begin
          aPositionType := ptLong;
          aOrderPrice := aQuote.Bids[k].Price;
          aOrderQty := aQuote.Bids[k].Volume - aQuoteRec[iType].Bids[k].Volume;
        end;
        if aOrderQty <> 0 then break;
      end; // for k:=1 to 5 do
      iIndex := k;

    end;   // ȣ��
  end;     // with FSymbol

  aQuoteRec[iType].Assign( aSymbol.Quote as TQuote );    // Backup Quote
  Inc(aQuoteCount[iType]);

  // ----------  Bear ���� ---------- //

  // �ܷ��� ���� ������մܰ� ���ϱ�
  dAvgPrice := GetAvgPrice(aSymbol)  ;

  // Current ���ڵ�� ������ Setting
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

  // �ֹ� �����϶� -> ���� ��ƾ
  if aSymbol = FOrderSymbol then
  begin
    QuoteOrderProcess(aRec) ;
  end ;

  // ���� �����϶� -> ���� ��ƾ  ��κ� ����
  if aSymbol = FCohesionSymbol then
  begin
    QuoteCohesionProcess(aRec) ;
  end ;


  // ��մܰ��� ���� ��մܰ��� ������ �ű�
  aPrevAvgPrice[iType] := dAvgPrice ;

  except
    on E : Exception do
      gLog.Add(lkError, 'BearSystem', 'BearTrade', 'QuoteProc : ' + E.Message);
  end;


end;


// �ֹ� ��û ��� ���� 
procedure TBearTrade.ReqChanged(Sender: TObject);
begin
  //
end;

// �ֹ� ���� 
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

  // -- �ű�, ���� ���� ������ ���� üũ
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
  if aOrder.State in  [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // ����ü��/�����ֹ�
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
    //gLog.Add(lkError, 'BearSystem', '����������', 'Data Integrity Failure');
    Exit;
  end;

  //-- filter 2 (not selected)
  if (FAccount = nil) or (FOrderSymbol = nil) then Exit;
  if (aPosition.Symbol <> FOrderSymbol)  then Exit;
  FPosition := aPosition;
end;
// -- �ڵ� ��� 
procedure TBearTrade.TimerTimer(Sender: TObject);
var
  i : Integer ;
  aBearOrder : TBearOrderItem ;
  aOrder, aSOrder : TOrder ;
  aTicket : TOrderTicket;
  stLog : string;
begin

  // �ڵ� ��� true �϶��� �۵�
  if FConfig.CancelOrdered = false  then exit ;

  for i := 0 to FOrderItemList.Count - 1 do
  begin
    aBearOrder := FOrderItemList.Items[i] as TBearOrderItem ;
    aSOrder := aBearOrder.OrderItem ;
    if ( aSOrder.OrderType = otNormal ) and ( aSOrder.ActiveQty > 0) then
    begin

      // -- �ð���
      if ( ( (GetQuoteTime - aBearOrder.OrderTime)  * 24 * 3600 * 1000) > FConfig.CancelTime + EPSILON )
        and ( aBearOrder.CancelOrdered = false ) then
      begin


        // -- ����ֹ��� �α� ������ ����

        {
        gLog.Add(lkError, 'BearTrade', 'Cancel',
          '[���ֹ���ȣ] ' +  IntToStr(aSOrder.OrderNo)  +
          ' [��Ҽ���] ' +   IntToStr(aSOrder.ActiveQty),
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


// ������ ���� 
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
    //gLog.Add(lkError, 'BearSystem', '����������', 'Data Integrity Failure');
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




// �ű� �ֹ� 
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

  // -- ���� check
  if ( FAccount = nil )or ( aCohesionSymbol = nil  )
      or ( aOrderSymbol = nil ) or ( FConfig.OrderQty = 0  ) then
  begin

    gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�',
        '���� , ���� �̻�'
        + ' [Q] ' + IntToStr( FConfig.OrderQty)
    );

    exit ;
  end;

  // -- ������ ���ϱ�
  iPosition := GetPosition ;

  // -- �ֹ����� ���ϱ� 
  aPositionType := GetOrderPosition(aCohesionSymbol,aOrderSymbol, aCohesionPosition) ;

  // -- �ż� -> ���� : �ŵ� 1ȣ��  
  // -- �ŵ� -> ���� : �ż� 1ȣ��
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


  // -- 1. ������ �ð� üũ
  if ( FSysConfig.QuoteJamSkipUsed = true ) and
      (  aOrderSymbol.DelayMs > FSysConfig.QuoteJamSkipTime ) then
  begin

    //**

    gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�',
        '�����̽ð� �ʰ� '
        + ' [�ð�] ' + IntToStr(aOrderSymbol.DelayMs )
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '���� ' +   IntToStr(aOrderSymbol.DelayMs )  + ' '
      + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit ;
  end;

  // -- 2. �ֹ� ���� üũ
  if (  (FConfig.LongOrdered = false) and  ( aPositionType = ptLong ) )
    or (  (FConfig.ShortOrdered = false) and  (aPositionType = ptShort)  ) then
  begin
     //**

     gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�',
      ' �ֹ�����Ұ�! ' +  ifThenStr( aPositionType = ptLong,'�ż�','�ŵ�')
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '�ֹ����� ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit ;
  end;

   // -- 3. �ֹ� ���� üũ
  if iOrderQty <= 0   then
  begin
     //**

    gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�',
      ' �ֹ�����! [OrderQty] ' +  IntToStr(iOrderQty)
      + ' [iPosition] ' + IntToStr(iPosition) + ' [MaxPosition] ' + IntToStr(FConfig.MaxPosition)
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '�ֹ����� ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit;
  end;

  // -- 4. �ִ� �ܷ� üũ

  if CheckQuoteQty(aOrderSymbol, dPrice, aPositionType,
           FConfig.MaxQuoteQty ) = false then
  begin
    //**

    gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�', ' ȣ���ܷ��ʰ�! ' );
    //
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '�ܷ��ʰ� ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    Beep;
    exit ;
  end;
      

  // -- 5. �ֹ��� üũ
  if abs(dPrice) <= PRICE_EPSILON   then
  begin
    //**

    gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�',
      ' �ֹ����̻�! [P] ' +  Format('%.2f', [ dPrice ])
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '�ֹ��� ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
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

  // -- 6. ������ �ʰ� üũ
  iActive := 0;
  if not (FBearOrders.CheckMaxPosition( FPosition, FConfig.MaxPosition, aOrder, iActive )) then
  begin
    gLog.Add(lkDebug, 'BearTrade', '�ֹ��Ұ�',
      ' �������ʰ�! ' + ifThenStr( aPositionType = ptLong, '�ż�', '�ŵ�')
       + ' [P] ' + IntToStr(iPosition)
       + ' [Q] ' + IntTostr(iCur)
    );
    BearLog( Self, FormatDateTime('nn:ss:zzz' , GetQuoteTime ) , 'O',
     '������ ' + PositionTypeLog[aPositionType] + ' ' + Format('%.2f', [ dPrice ])
      + ',' +  IntToStr(iOrderQty)
      + ' [' + IntToStr(aCohesionData.OrderSum) + ',' + IntToStr(aCohesionData.OrderCnt)
      + ',' +  Format('%.3f', [ aCohesionData.AvgPrice ]) + ']'
    );

    FBearOrders.DeleteOrder( aBear );
    Beep;
    Exit;
  end;

  // -- 7.   ���� ��� �ֹ� ���..
  FBearOrders.CheckSelfFillOrder( aOrderSymbol, aPositionType, dPrice, iOrderQty ) ;

  // �ű� �ֹ� !
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

  // �ֹ� ��û ����Ʈ�� �߰�
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

  // 1. ���� (������) 
  Stop ;

  // 2. ����, ���� �Ҵ�
  FAccount := aSysConfig.Account ;
  FCohesionSymbol := aSysConfig.CohesionSymbol ;
  FOrderSymbol := aSysConfig.OrderSymbol ;

  FSysConfig := aSysConfig ; 
  FConfig := aConfig ;
                                        
  // 3. ���� �ʱ�ȭ
  init ;

  // 4. ���� ���� ( �ֹ� ���� )
  SaveOrderHeader ;
  
  // 5. ���� ������, �ֹ� ���� ����
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

  // 8. Timer ���� ( �ڵ� ��� �����Ҷ���  )
  if FConfig.CancelOrdered = true then
  begin
    if FTimer = nil then
    begin
      FTimer := gEnv.Engine.QuoteBroker.Timers.New;    // 100 ms�� ����
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
