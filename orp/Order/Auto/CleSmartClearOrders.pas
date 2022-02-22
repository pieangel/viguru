unit CleSmartClearOrders;

interface

uses
  Classes, Sysutils,

  CleBaseIF, CleQuoteBroker, CleSymbols, ClePositions, CleAccounts, CleOrders, cleDistributor,

  CleFORMOrderItems,

  GleTypes, Gleconsts, GleLib

  ;

type


  TEndEventNotify = procedure ( Sender : TObject; bEnd : boolean ) of object;

  TSmartClearOrder  = class( TCollectionItem )
  private
    FPosition: TPosition;
    FOrdered: boolean;
    FSmartOrders: TOrderList;
    FOrderList: TOrderItem;
    FEndEvent: TEndEventNotify;

    function DoQuoteCheck(aQuote: TQuote): boolean;
    procedure GoOrder(iSide : integer;aQuote: TQuote);
    procedure SetPosition(const Value: TPosition);
  public
    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;
    function  DoCheck( aQuote : TQuote ) : boolean;
    function  DoOrder( aQuote : TQuote ) : boolean;
    procedure OnTradde( aOrder : TOrder );

    property Position : TPosition read FPosition write SetPosition;
    property Ordered  : boolean read FOrdered write FOrdered;
    property SmartOrders : TOrderList read FSmartOrders write FSmartOrders;
    property OrderList   : TOrderItem read FOrderList;

    property EndEvent : TEndEventNotify read FEndEvent write FEndEvent;
  end;


  TSmartClearOrders = Class( TBaseIF )
  private


  public
    constructor Create;
    destructor Destroy; override;

    function New( aPos : TPosition ) : TSmartClearOrder; overload;
    function New : TSmartClearOrder; overload;
    function Find( aPos : TPosition) : TSmartClearOrder;
    procedure Del( aPos : TPosition ); overload;
    procedure Del( aSmart : TSmartClearOrder ); overload;


    function Get( i : integer ) : TSmartClearOrder;

    procedure Init;
    procedure OnQuote( aQuote : TQuote );  virtual ;
    procedure OnTrade(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);  virtual ;
  End;

implementation

uses
  GAppEnv;

{ TSmartClearOrder }

constructor TSmartClearOrder.Create(aColl: TCollection);
begin
  inherited;
  FPosition := nil;
  FOrdered  := true;
  //FSmartOrders:= TOrderList.Create;
end;

destructor TSmartClearOrder.Destroy;
begin
  //FSmartOrders.Free;
  inherited;
end;

function TSmartClearOrder.DoCheck(aQuote: TQuote): boolean;
var
  stLog : string;
begin
  Result := false;

  // 포지션 체크
  if FPosition.Volume = 0 then
  begin
    if not FOrdered then
      if Assigned( FEndEvent ) then
      begin

        stLog := 'SmartClear Stop Position = 0 ';
        gLog.Add( lkKeyOrder,'TSmartClearOrder','DoCheck', stLog );
        FEndEvent( self, false );
      end;
    Exit;
  end;

  DoOrder( aQuote );

end;

function TSmartClearOrder.DoQuoteCheck(aQuote: TQuote): boolean;
begin
  Result := false;

end;

function TSmartClearOrder.DoOrder(aQuote: TQuote): boolean;
var
  iSide : integer;
  dGap : double;
  bOrder  : boolean;
begin
  Result := false;
  bOrder := false;
  dGap   := 0;

  // 포지션에 대해 유리한 쪽으로  호가가 뒤집혀야 되므로.
  // 매도 포지션 보유시.. 다운일때
  // 매수 포지션 보유시.. 업일때

  if FPosition.Volume < 0 then
  begin
    iSide := -1;
    dGap := aQuote.PrevAsks[0].Price - aQuote.Asks[0].Price;
     if (dGap > 0) and ( dGap > PRICE_EPSILON) then

//    dGap := FPosition.AvgPrice - aQuote.Asks[0].Price;
//    if dGap > PRICE_EPSILON then
      bOrder := true;
//    end;
  end
  else begin
    iSide := 1;
      dGap := aQuote.Bids[0].Price - aQuote.PrevBids[0].Price;
      if (dGap > 0) and ( dGap > PRICE_EPSILON) then

    //dGap  := aQuote.Bids[0].Price - FPosition.AvgPrice;
    //if (FPosition.AvgPrice > PRICE_EPSILON ) and ( dGap > PRICE_EPSILON ) then
      bOrder := true;
  end;

  if (bOrder) and ( not FOrdered ) then
    GoOrder( iSide, aQuote );
end;

procedure TSmartClearOrder.GoOrder(iSide : integer; aQuote: TQuote);
var
  aTicket: TOrderTicket;
  iVal, iVolume  : integer;
  pOrder, aOrder : TOrder;
  stTmp, stLog  : string;
  dPrice  : double;
  aList : TList;
  i: Integer;

begin
  if FPosition = nil then
    Exit;
  if FPosition.Account = nil then
    Exit;

  iVolume := FPosition.Volume * -1;

  pOrder := nil;

  try

  aList := TList.Create;

  case iSide of
    1 :
      begin
        dPrice  := aQuote.Bids[0].Price;
        if FOrderList <> nil then

          FOrderList.FindAskOrders(aList, dPrice );
          //pOrder := FOrderList.FindAskOrder2( dPrice );
      end;
    -1 :
      begin
        dPrice  := aquote.Asks[0].Price;
        if FOrderList <> nil then
          FOrderList.FindBidOrders( aList, dPrice);
          //pOrder  := FOrderList.FindBidOrder2( dPrice );
      end;
  end;

  if aList.Count > 0 then
  begin
    iVal := 0;
    stTmp := '';

    for i := 0 to aList.Count - 1 do
    begin
      pOrder  := TOrder( aList.Items[i] );
      if pOrder = nil then
        Continue;

      inc( iVal, pOrder.ActiveQty );
      stTmp := stTmp + Format('%d, %s, %2f, %d |',
        [
          pOrder.OrderNo,
          ifThenStr( pOrder.Side > 1, 'L', 'S' ),
          pOrder.Price,
          pOrder.ActiveQty
        ]);
    end;

    if abs(FPosition.Volume) <= iVal then
    begin

      stLog := Format('내주문 이미 있음 - [잔고: %s, %d, %.2f]  [Order : %s ] ' +
                      '[Quote : Prev( %d, %.2f, %.2f, %d) Cur( %d, %.2f, %.2f, %d)]',
                      [
                        ifThenStr( FPosition.Volume > 0 , 'L', 'S'),
                        FPosition.Volume,
                        FPosition.AvgPrice,

                        stTmp,

                        aQuote.PrevAsks[0].Volume,
                        aQuote.PrevAsks[0].Price,
                        aquote.PrevBids[0].Price,
                        aQuote.PrevBids[0].Volume,

                        aQuote.Asks[0].Volume,
                        aQuote.Asks[0].Price,
                        aquote.Bids[0].Price,
                        aQuote.Bids[0].Volume
                      ]);

      gLog.Add( lkKeyOrder,'TSmartClearOrder','GoOrder', stLog );
      Exit;
    end
    else begin

      iVolume :=abs(FPosition.Volume)- iVal;
      if iVolume <= 0 then
        Exit;

      if iSide > 0 then
        iVolume := iVolume * -1  ;

      stLog := Format('수량 변경 %d -->%d',
        [
          FPosition.Volume * -1, iVolume
        ]);
      gLog.Add( lkKeyOrder,'TSmartClearOrder','GoOrder', stLog );
    end;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

    // create normal order
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FPosition.Account, FPosition.Symbol,
                iVolume, pcLimit, dPrice, tmGTC, aTicket);  //

  if aOrder <> nil then
  begin
    FOrdered  := true;
    aOrder.OrderSpecies := opSmartClear;
    gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.Engine.TradeCore.Orders.DoNotify( aOrder );

    //FSmartOrders.Add( aOrder );

      stLog := Format('[잔고: %s, %d, %.2f]  [Order : %s, %.2f, %d] ' +
                      '[Quote : Prev( %d, %.2f, %.2f, %d) Cur( %d, %.2f, %.2f, %d)]',
                      [
                        ifThenStr( FPosition.Volume > 0 , 'L', 'S'),
                        FPosition.Volume,
                        FPosition.AvgPrice,

                        ifThenStr( aOrder.Side > 0, 'L', 'S' ),
                        aOrder.Price,
                        iVolume,

                        aQuote.PrevAsks[0].Volume,
                        aQuote.PrevAsks[0].Price,
                        aquote.PrevBids[0].Price,
                        aQuote.PrevBids[0].Volume,

                        aQuote.Asks[0].Volume,
                        aQuote.Asks[0].Price,
                        aquote.Bids[0].Price,
                        aQuote.Bids[0].Volume
                      ]);


    //gEnv.EnvLog( WIN_TEST, stLog );
    gLog.Add( lkKeyOrder,'TSmartClearOrder','GoOrder', stLog );

    if Assigned( FEndEvent ) then
      FEndEvent( self, false );    
  end;
  finally
    aList.Free;
  end;

end;




procedure TSmartClearOrder.OnTradde(aOrder: TOrder);
var
  i : integer;
  bFind : boolean;
begin
  if aOrder = nil then Exit;

  bFind := false;

  // 신규주문접수에 대한 취소주문 결정
  if (aOrder.OrderType = otNormal) and
     (aOrder.State = osActive) then
  begin
    for i:=SmartOrders.Count-1 downto 0 do
    begin
      if aOrder = SmartOrders.Orders[i] then
      begin
        bfind := true;
        gEnv.EnvLog( WIN_TEST,
          Format('Acept : %.2f, %d(%d), %d',
            [
              aOrder.Price, aOrder.OrderQty, aOrder.ActiveQty, aOrder.OrderNo
            ])
          );
        break;
      end;
    end;

    if bFind then
      FOrdered := false;

  end else
  if
    (aOrder.State in  [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed]) then  // 전량체결/죽은주문
  begin
    for i:=SmartOrders.Count-1 downto 0 do
    begin
      if aOrder = SmartOrders.Orders[i] then
      begin
        FOrdered  := false;
        SmartOrders.Delete(i);
        break;
      end;
    end;

  end;

end;

procedure TSmartClearOrder.SetPosition(const Value: TPosition);
begin
  if Value <> nil then

  FOrderList:= gEnv.Engine.FormManager.OrderItems.Find( Value.Account, Value.Symbol );
  FPosition := Value;
end;

{ TSmartClearOrders }

constructor TSmartClearOrders.Create;
begin
  inherited Create( TSmartClearOrder );
end;

procedure TSmartClearOrders.Del(aPos: TPosition);
var
  i : integer;
  aOrder : TSmartClearOrder;
begin

  if aPos = nil then
    Exit;

  for I := 0 to Count - 1 do
  begin
    aOrder  :=  Get(i );
    if aOrder = nil then
      Continue;
    if aOrder.Position = aPos then
    begin
      Delete(i);
      break;
    end;
  end;

end;

procedure TSmartClearOrders.Del( aSmart : TSmartClearOrder );
var
  i : integer;
begin

  for I := 0 to Count - 1 do
  begin
    if Get(i) = aSmart then
    begin
      Delete(i);
      break;
    end;
  end;

end;

destructor TSmartClearOrders.Destroy;
begin
//  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

function TSmartClearOrders.Find(aPos: TPosition): TSmartClearOrder;
var
  i : integer;
  aOrder : TSmartClearOrder;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    aOrder  :=  Get(i );
    if aOrder = nil then
      Continue;
    if aOrder.Position = aPos then
    begin
      Result := aOrder;
      break;
    end;
  end;
end;

function TSmartClearOrders.Get(i: integer): TSmartClearOrder;
var
  a : TObject;
begin
  a := Value[i];
  if a <> nil then
    Result := a as TSmartClearOrder
  else
    Result := nil;
end;


procedure TSmartClearOrders.Init;
begin
  gEnv.Engine.TradeBroker.Subscribe( Self, OnTrade);
end;

function TSmartClearOrders.New: TSmartClearOrder;
begin
  Result := Add as TSmartClearOrder;
end;

function TSmartClearOrders.New(aPos: TPosition): TSmartClearOrder;
begin
  if aPos = nil then
    Exit;

  Result  := Find( aPos );

  if Result = nil then
  begin
    Result := Add as TSmartClearOrder;
    Result.Position := aPos;
    REsult.FOrderList:= gEnv.Engine.FormManager.OrderItems.Find( aPos.Account, aPos.Symbol );
  end;
end;

procedure TSmartClearOrders.OnQuote(aQuote: TQuote);
var
  I: Integer;
  aOrder : TSmartClearOrder;
begin
  for I := 0 to Count - 1 do
  begin
    aOrder  :=  Get(i );
    if aOrder = nil then
      Continue;
    if aOrder.Position = nil then
      Continue;

    if (aOrder.Position.Symbol = aQuote.Symbol) and
      ( not aOrder.FOrdered )then
    begin
      aOrder.DoCheck( aQuote );
    end;
  end;
end;

procedure TSmartClearOrders.OnTrade(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
  I: Integer;
  aSmart : TSmartClearOrder;
  aOrder : TOrder;
begin
  try
    if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

    if DataObj is TOrder then
      aOrder := DataObj as TOrder
    else
      Exit;

    for I := 0 to Count - 1 do
    begin

      aSmart  :=  Get(i );
      if aSmart = nil then
        Continue;

      if ( aSmart.FPosition.Account = aOrder.Account ) and
        ( aSmart.FPosition.Symbol = aOrder.Symbol ) then

      case Integer(EventID) of
          // order events
        ORDER_SPAWN,
        ORDER_ACCEPTED,
        ORDER_REJECTED,
        ORDER_CONFIRMED,
        ORDER_CONFIRMFAILED,
        ORDER_CANCELED,
        ORDER_FILLED: aSmart.OnTradde( aOrder );
      end;
    end;

  except
  end;

end;

end.
