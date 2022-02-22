Unit BullTrade;

interface

uses
  Classes, SysUtils, Math, mmSystem,
  CleSignals,
  GleTypes, CleOrders, CleSymbols, CleAccounts, ClePositions, CleDistributor,
  BullData, BullSystem, CleQuoteTimers, GleConsts, CleQuoteBroker, cleMarkets
  ;

const
  Meritz_MAX_ORDER_QTY = 2000;

type

    // OrderReq. 용도 : 자동주문 확인 및 주문속도 측정
  TBullOrderReqItem = class(TCollectionItem)
  private
    OrderReq    : TOrder;
    EntrySeq    : Integer;
    SendTime    : Integer;              // 주문전송시각
  end;

  TBullOrderItem = class(TCollectionItem)
  private
    Order       : TOrder;
    AceptTime   : TDateTime;
  end;

  TBullOrders = class( TAutoOrders )
  public
    SignalList  : TCollection;
    Constructor Create;
    Destructor Destroy; override;
    function CheckSameSignal(aSymbol: TSymbol;
        aOrderSide: TPositionType; dPrice: Double; bX: boolean) : boolean;
  end;

  TBullTrade = class
  private
    FAccount : TAccount;     // 계좌
    FPosition : TPosition;
    FFuture : TSymbol;
    FOption : TSymbol;
    FConfig : TBullConfig;
    FBullSystem : TBullSystem;
    FAutoTrade : Boolean;               // 자동 매매 여부

    //FOrderHandler : TOrderHandler;                        // 주문 송수신
    FOrderReqList : TCollection{TBullOrderReqItem};       // 주문전송목록
    FOrderList    : TCollection{TOrderItem};              // 신규미체결주문목록

    FOnSignalNotify : TNotifyEvent;
    FOnStatusNotify : TNotifyEvent;

    FOrderSpeed : Integer;
    FBullResult : TBullResult;

    FEntrySequence : Integer;
    FAutoTradeCount : Integer;

    FWaitOrderCount : Integer;
    FBullOrders: TBullOrders;

      // 이벤트
    procedure BullSystemNotified(Sender : TObject);
    procedure ReqChanged(Sender : TObject);
    procedure OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure FutureQuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OptionQuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID);
    procedure DoPosition(aPosition: TPosition; EventID: TDistributorID);

    procedure SetPosition;
    procedure NotifyStatusChange;
    procedure NotifySignalChange;

    procedure SetAccount(const Value: TAccount);
    procedure SetAutoTrade(const Value: Boolean);
    procedure SetConfig(const Value: TBullConfig);
    procedure SetOption(const Value: TSymbol);
    procedure ResetValues;
    procedure DoSignal;
    function FindOrderReq(iSrvAcptNo: Integer): TBullOrderReqItem;
    function FindOrder( aOrder : TOrder ) : TAutoOrder;
    function GetStatus: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeatProc;

    property Account : TAccount read FAccount write SetAccount;
    property AutoTrade : Boolean read FAutoTrade write SetAutoTrade;
    property Config : TBullConfig read FConfig write SetConfig;
    property Future : TSymbol read FFuture;
    property Option : TSymbol read FOption write SetOption;
    property BullResult : TBullResult read FBullResult;
    property OnSignalNotify : TNotifyEvent read FOnSignalNotify write FOnSignalNotify;
    property OnStatusNotify : TNotifyEvent read FOnStatusNotify write FOnStatusNotify;
    Property Status : String read GetStatus;
    // new
    property BullOrders : TBullOrders read FBullOrders write FBullOrders;

  end;

implementation

uses GAppEnv, GleLib;

const
  SECONDS_A_DAY = 24 * 60 * 60;


{ TBullTrade }

procedure TBullTrade.BeatProc;
var
  i : Integer;
  aBullOrderItem : TBullOrderItem;
  aTicket : TOrderTicket;
  aBull : TAutoOrder;
  aOrder : TOrder;
begin
  if FBullSystem.BeatProc then
    DoSignal;

  if (not FAutoTrade) or
     (FAccount = nil) or
     (FOption = nil) then Exit;

    // 시간 취소 점검

  for i:=FOrderList.Count-1 downto 0 do
  begin
    aBullOrderItem := FOrderList.Items[i] as TBullOrderItem;

      // 시간취소만 점검
    if FConfig.EntryTimeCancel_Checked then
    begin
      if aBullOrderItem.Order.State <> osActive then
      begin
        aBullOrderItem.Free;
      end else
      if (GetQuoteTime - aBullOrderItem.AceptTime) > FConfig.EntryCancelTime/SECONDS_A_DAY then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aBullORderItem.Order,
          aBullOrderItem.Order.ActiveQty, aTicket );
        if aOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Send( aTicket );
          gLog.Add( lkDebug, 'BullTrade', 'Cancel', Format('%s: %s, %d %d',[ aBullOrderItem.Order.Symbol.ShortCode,
            ifthenStr( aOrder.Side = 1, '매수', '매도'),aBullOrderItem.Order.OrderNo, FPosition.Volume]) );
          aBullOrderItem.Free;
        end;
      end;
    end;
  end;



end;

procedure TBullTrade.BullSystemNotified(Sender: TObject);
begin

end;

constructor TBullTrade.Create;
var
  i : integer;
  aFuture : TFuture;
  FFutureMarket : TFutureMarket;
begin
  FAccount := nil;
  FPosition := nil;
  BullOrders := TBullOrders.Create;

   // 선물 호가 구독
  FFutureMarket  := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];
  aFuture := FFutureMarket.FrontMonth;

  FFuture := aFuture;
  FOption := nil;
  FBullSystem := TBullSystem.Create;
  FBullSystem.Future := FFuture;
  FBullSystem.OnNotify := BullSystemNotified;

  FAutoTrade := False;

  FOrderReqList := TCollection.Create(TBullOrderReqItem);
  FOrderList := TCollection.Create(TBullOrderItem);
  FOrderSpeed := 0;
  FEntrySequence := 0;
  FAutoTradeCount := 0;

  if FFuture <> nil then
  begin
    gEnv.Engine.QuoteBroker.Subscribe( self, FFuture, FutureQuoteProc);
  end;

    // 계좌 관련 구독
  gEnv.Engine.TradeBroker.Subscribe( self,OrderProc );

  FWaitOrderCount := 0;

end;

destructor TBullTrade.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel( self );
  gEnv.Engine.TradeBroker.Unsubscribe( self );

  FBullSystem.Free;

  FOrderReqList.Free;
  FOrderList.Free;
  BullOrders.Free;

  inherited;
end;



procedure TBullTrade.DoSignal;
var
  aChg : Double;
  aGap : Double;
  bSignal, xSignal : Boolean;
  aOrderSide : TPositionType;
  aQtyWeight : Double;
  iNewOrderQty, iOrderQty, iActive, iPos : Integer;
  dPrice : Double;
  aOrder : TOrder;
  aTicket : TOrderTicket;
  stText, stSignal, stOrderSide : String;
  iORd, iCurQty : Integer;
  aSignal : TSignalItem;
  aBull   : TAutoOrder;
begin
  aOrder := nil;
  xSignal := false;

  with FBullSystem.BullResult, FConfig do
  begin
    if (FAccount = nil) then Exit;
    if (OptionFitPrices[Prev] < PRICE_EPSILON) or
       (Abs(RealDelta) < PRICE_EPSILON) then
      Exit;

    aChg := OptionFitPrices[Last]-OptionFitPrices[Prev];
    aGap := Min(3,OptionSeparation);

    // E1 Signal Check
    bSignal := False;
    if (FConfig.E1_Checked) and
       (E1_P1 > PRICE_EPSILON) and
       (E1_P2 > PRICE_EPSILON) and
       (E1_P3 > PRICE_EPSILON) and
       (E1_P4 > PRICE_EPSILON) and
       (E1_P5 > PRICE_EPSILON) and
       (E1_P6 > PRICE_EPSILON) and
       (EventKind = beFuture) then
    begin
      if FPosition = nil then
        iCurQty := 0
      else
        iCurQty := FPosition.Volume;

      if (aChg > FConfig.E1_P1/100.0) and
         (aGap > FConfig.E1_P2/100.0) and
         ( (FOption.Quote as TQuote).Asks[0].Volume < FConfig.MaxQuoteQty) then
      begin
        if E2_Checked then
          iNewOrderQty := NewOrderQty
        else
        begin
          aQtyWeight := Max(1, Abs(aGap)/(FConfig.E1_P3*0.01));
          iNewOrderQty := Floor(NewOrderQty * aQtyWeight);
        end;

        iOrderQty := Min(Meritz_MAX_ORDER_QTY,
                          Min(MaxPosition-iCurQty, iNewOrderQty));
        if iOrderQty > 0  then
        begin
          bSignal := True;
          aOrderSide := ptLong;
          dPrice := Floor((OptionFitPrices[Prev]+(aChg*2.0+aGap)/3.0*FConfig.E1_P6-(FConfig.E1_P4/100.0))*100.0)/100.0;
          // E1_P6 이 클수록   E1_P4가 클수록
          stText  := Format('Long %.2f : %.2f = %.2f + ( %.5f * 2.0 + %.5f ) / 3.0 * %.2f - ( %.2f / 100.0 )) * 100 )/ 100',
              [ (FOption.Quote as TQuote).Bids[0].Price, dPrice,  OptionFitPrices[Prev] , aChg , aGap, FConfig.E1_P6, FConfig.E1_P4 ]);
          gEnv.EnvLog( WIN_DEBUG, stText);
        end;
      end else
      if (aChg < -FConfig.E1_P1/100.0) and
         (aGap < -FConfig.E1_P2/100.0) and
         ((FOption.Quote as TQuote).Bids[0].Volume < FConfig.MaxQuoteQty) then
      begin
        if E2_Checked then
          iNewOrderQty := NewOrderQty
        else
        begin
          aQtyWeight := Max(1, Abs(aGap)/(FConfig.E1_P3*0.01));
          iNewOrderQty := Floor(NewOrderQty * aQtyWeight);
        end;

        iOrderQty := Min(Meritz_MAX_ORDER_QTY,
                          Min(MaxPosition+iCurQty, iNewOrderQty));
        if iOrderQty > 0  then
        begin
          bSignal := True;
          aOrderSide := ptShort;
          dPrice := Ceil((OptionFitPrices[Prev]+(aChg*2.0+aGap)/3.0*FConfig.E1_P6+(FConfig.E1_P4/100.0))*100.0)/100.0;

          stText  := Format('Shot %.2f, : %.2f = %.2f + ( %.5f * 2.0 + %.5f ) / 3.0 * %.2f - ( %.2f / 100.0 )) * 100 )/ 100',
              [  (FOption.Quote as TQuote).Asks[0].Price,  dPrice,  OptionFitPrices[Prev] , aChg , aGap, FConfig.E1_P6, FConfig.E1_P4 ]);
          gEnv.EnvLog( WIN_DEBUG, stText );
        end;
      end;
    end;


    // X1 Signal Check : 청산 시그널
    if (not bSignal) and
       (FPosition <> nil) and
       (FPosition.Volume <> 0) and
       (FConfig.X1_Checked) and
       (X1_P1 > PRICE_EPSILON) and
       (X1_P2 > PRICE_EPSILON) and
       (EventKind = beFuture) then
    begin
      if (aChg > FConfig.X1_P1/100.0) and
         (aGap > FConfig.X1_P2/100.0) and
         (FPosition.Volume < 0) then
      begin
        bSignal := True;
        xSignal := true;
        aOrderSide := ptLong;
        iOrderQty := Min(FConfig.NewOrderQty, Abs(FPosition.Volume));
        dPrice := Floor(OptionFitPrices[Last]*100.0)/100.0;
      end
      else
      if (aChg < -FConfig.E1_P1/100.0) and
         (aGap < -FConfig.X1_P2/100.0) and
         (FPosition.Volume > 0) then
      begin
        bSignal := True;
        xSignal := true;
        aOrderSide := ptShort;
        iOrderQty := Min(FConfig.NewOrderQty, Abs(FPosition.Volume));
        dPrice := Ceil(OptionFitPrices[Last]*100.0)/100.0;
      end;
    end;

    if (bSignal) and
       (FAutoTrade) and
       (FWaitOrderCount < 2) and
       (dPrice < 3.0-PRICE_EPSILON) and      // 2007-02-07 주문가격<3.0 필터링 추가
       ((aOrderSide = ptLong) and (FConfig.EntryLong_Checked) or
        (aOrderSide = ptShort) and (FConfig.EntryShort_Checked)) then
    begin

      // check same signal
      if (BullOrders.CheckSameSignal( FOption, aOrderSide, dPrice, xSignal )) then
      begin
        stText  := Format('%s : %s, %.*n, %s', [
          FOption.ShortCode,  ifThenStr( aOrderSide = ptLong, '매수', '매도'),
          FOption.Spec.Precision, dPrice,
          ifThenStr( xSignal = true, '청산', '일반' )
          ]);
        gLog.Add( lkDebug, 'BullTrade', 'SameSignal', stText );
        stText := '';
        Exit;
      end;

      // 미리 주문과 신호를 생성한다.
      stSignal  := Format('%s : %s, %.*n, %s  | %.*n | %.*n | %.*n |  %.3f, %.3f, %.3f', [
        FOption.ShortCode,  ifThenStr( aOrderSide = ptLong, '매수', '매도'),
        FOption.Spec.Precision, dPrice,
        ifThenStr( xSignal = true, '청산', '일반' ),
        FOption.Spec.Precision, (FOption.Quote as TQuote).Asks[0].Price,
        FOption.Spec.Precision, (FOption.Quote as TQuote).Last,
        FOption.Spec.Precision, (FOption.Quote as TQuote).Bids[0].Price ,

        // 가격 발생 조건들
        OptionFitPrices[Prev], aChg*2.0,  aGap
        ]);
      gEnv.DoLog( WIN_TEST, 'BullTrade | OccurSignal ' + stSignal );
      stText := '';

      iOrd  := abs( iOrderQty );
      if aOrderSide = ptShort then
        iOrd  := iOrd * (-1);

      aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', FAccount, FOption,
        iOrd, pcLimit, dPrice, tmFAS  );

      if aOrder = nil then Exit;

      aBull   := BullOrders.New( aOrder );
      // 시그널 저장
      aSignal := TSignalItem( BullOrders.SignalList.Add );
      aSignal.OrderSide := aOrderSide;
      aSignal.OrderQty  := iOrderQty;
      aSignal.OrderPrice:= dPrice;
      aSignal.Symbol    := FOption;
      aSignal.XSignal   := xSignal;
      aBull.Signal      := aSignal;

      iActive := 0;
      if not (BullOrders.CheckMaxPosition( FPosition, MaxPosition, aOrder, iActive )) then
      begin
        if FPosition <> nil then
        begin
          stText  := Format('%s : %s, Net: %d, Active :%d  Qty : %d', [
            FPosition.Symbol.ShortCode,  ifThenStr( aOrderSide = ptLong, '매수', '매도'),
            FPosition.Volume , iActive, iOrderQty
            ]);
          gLog.Add( lkDebug, 'BullTrade', 'MaxPosition', stText );
          stText := '';
        end;
        BullOrders.DeleteOrder( aBull );
        Exit;
      end;

      // 자전 대상 주문 취소..
      BullOrders.CheckSelfFillOrder( FOption, aOrderSide, dPrice, iOrderQty ) ;
        // 주문 내기
      Inc(FEntrySequence);
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
      aOrder.SetTicket( aTicket );
      gEnv.Engine.TradeCore.Orders.NewOrders.Add( aOrder );

      if aOrder <> nil then
      begin
          // 주문 전송

        gEnv.Engine.TradeBroker.Send( aTicket );
        Beep;

        aOrder.OrderSpecies := opBull;
        aBull.EtrySeq := FEntrySequence;
        aBull.BSend := true;

        Inc(FWaitOrderCount);
          // 자동매매회수 증가
        Inc(FAutoTradeCount);
      end;

    end;

    if (bSignal) and ( aOrder <> nil ) then
    begin
      if aOrderSide = ptLong then
        stOrderSide := 'L'
      else
        stOrderSide := 'S';

      if FPosition = nil then
        iPos :=0
      else
        iPos := FPosition.Volume;

      stText := Format('신호 : %s | %.3f,%.3f, pos : %d 주문:%s,%d,%.2f, 상태(F:%.3f-%.3f, OA:%.4f-%.4f, OF:%.4f-%.4f, IV:%.4f, Delta:%.4f, SF:%.2f  )', [
                            stSignal,
                            aChg*100.0,
                            aGap*100.0,
                            iPos,
                            stOrderSide,
                            iOrderQty,
                            dPrice,
                            FutureAvgPrices[Prev],
                            FutureAvgPrices[Last],
                            OptionAvgPrices[Prev],
                            OptionAvgPrices[Last],
                            OptionFitPrices[Prev],
                            OptionFitPrices[Last],
                            RealIV,
                            RealDelta,
                            SynFutures
                             ]);
      gLog.Add(lkDebug, 'BullTrade', 'NewOrder', stText);

    end;

    if (Abs(aChg) > 0.001) or
       (Abs(aGap) > 0.001) then
      NotifySignalChange;
  end;

end;

function TBullTrade.FindOrder(aOrder : TOrder): TAutoOrder;
var
  i : integer;
  aBull : TAutoOrder;
begin
  Result := nil;

  for i := FBullOrders.Count -1 downto 0 do
  begin
    aBull := FBullOrders.AutoOrders[i];
    if aBull = nil then Continue;
    if not aBull.BSend then Continue;
    if aBull.Order = nil then Continue;

    if ( aBull.Order.LocalNo = aOrder.LocalNo ) then
    begin
      Result := aBull;
      break;
    end;
  end;


end;

function TBullTrade.FindOrderReq(iSrvAcptNo : Integer) : TBullOrderReqItem;
var
  i : Integer;
  aItem : TBullOrderReqItem;
begin
  Result := nil;

  for i := 0 to FOrderReqList.Count-1 do
  begin
    aItem := FOrderReqList.Items[i] as TBullOrderReqItem;
    if (aItem.OrderReq <> nil) and (aItem.OrderReq.OrderNo = iSrvAcptNo) then
    begin
      Result := aItem;
      Break;
    end;
  end;
end;

procedure TBullTrade.FutureQuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if FBullSystem.FutureQuoteProc then
    DoSignal;
end;

procedure TBullTrade.NotifySignalChange;
begin
  FBullResult := FBullSystem.BullResult;
  if Assigned(FOnSignalNotify) then
    FOnSignalNotify(Self);
end;

procedure TBullTrade.NotifyStatusChange;
begin
  if Assigned(FOnStatusNotify) then
    FOnStatusNotify(Self);
end;

procedure TBullTrade.OptionQuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if FBullSystem.OptionQuoteProc then
    DoSignal;
end;

procedure TBullTrade.OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if (FAccount = nil) or
     (FOption = nil) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CHANGED,
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


procedure TBullTrade.DoOrder(aOrder: TOrder; EventID: TDistributorID);
var
  aBull : TAutoOrder;
  aBullOrderItem : TBullOrderItem;
  i : Integer;
  stText : string;
begin
  if aOrder = nil then Exit;
  
  if aOrder.Symbol <> FOption then Exit;

  aBull := FindOrder( aOrder );
  if aBull = nil then Exit;

  // 신규주문접수에 대한 취소주문 결정
  if (aOrder.OrderType = otNormal) and
     (aOrder.State = osActive) and
     (EventID = ORDER_ACCEPTED) then
  begin
    Dec(FWaitOrderCount);

    with FOrderList.Add as TBullOrderItem do
    begin
      AceptTime := GetQuoteTime;
      Order := aOrder;
    end;

    //aOrder.VirAcptTime :=  GetQuoteTime;
    FOrderSpeed := timeGetTime- aOrder.VirSentTime;

    Beep;

    stText := Format('주문속도 = %d ms, 신규대기=%d', [FOrderSpeed, FWaitOrderCount]);
    gLog.Add(lkDebug, 'BullTrade', 'OrderProc', stText);
  end else
  if aOrder.State in  [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
  begin
      // 취소 대기 목록 삭제
    for i:=FOrderList.Count-1 downto 0 do
    begin
      aBullOrderItem := FOrderList.Items[i] as TBullOrderItem;
      if aBullOrderItem.Order = aOrder then
      begin
        aBullOrderItem.Free;
        Break;
      end;
    end;
    BullOrders.CheckOrderState( aOrder );
  end;
  NotifyStatusChange;

end;

procedure TBullTrade.DoPosition(aPosition: TPosition; EventID: TDistributorID);
var
  stText : string;
begin
  if (FAccount = nil) or (FOption = nil) then Exit;
  if (FAccount = aPosition.Account) and (FOption = aPosition.Symbol) then
  begin
    FPosition := aPosition;
  end; //...ifend;
end;


procedure TBullTrade.ReqChanged(Sender: TObject);
begin

end;

procedure TBullTrade.SetAccount(const Value: TACcount);
begin
  if FAccount = Value then Exit;
  FAccount := Value;

    // 목록 초기화
  ResetValues;
    // 포지션 확인
  SetPosition;
end;

procedure TBullTrade.SetAutoTrade(const Value: Boolean);
begin
  FAutoTrade := Value;

  NotifyStatusChange;
end;

procedure TBullTrade.SetConfig(const Value: TBullConfig);
begin
  FConfig := Value;
  FBullSystem.Config := Value;

  NotifyStatusChange;
end;

procedure TBullTrade.SetOption(const Value: TSymbol);
begin
  if FOption = Value then Exit;

  if FOption <> nil then
    gEnv.Engine.QuoteBroker.Cancel( self,  FOption );

  FOption := Value;
  ResetValues;
  SetPosition;
  FBullSystem.Option := Value;
  gEnv.Engine.QuoteBroker.Subscribe( self, FOption,OptionQuoteProc );

  NotifyStatusChange;
end;

procedure TBullTrade.SetPosition;
begin
  if (FAccount = nil) or (FOption=nil) then
  begin
    gLog.Add(lkError, 'TBullTrade', 'SetPosition', '(FAccount = nil) or (FOption=nil)');
    Exit;
  end;

  FPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, FOption );
end;

procedure TBullTrade.ResetValues;
begin
  FOrderReqList.Clear;
  FOrderList.Clear;
  FBullOrders.Clear;
end;

function TBullTrade.GetStatus: String;
begin
 // BullOrders.Get
  if FOption <> nil then
    BullOrders.GetAutoOrderPos( FOption );
  {
  if FPosition <> nil then
    if FPosition.Volume > 0 then
      BullOrders.ActOrdQty[0] := BullOrders.ActOrdQty[0] + FPosition.Volume
    else if FPosition.Volume < 0 then
      BullOrders.ActOrdQty[1] := BullOrders.ActOrdQty[1] + abs(FPosition.Volume);
  }
  Result := Format('%d, %d, %d, (%d|%d)', [
      FAutoTradeCount, FOrderList.Count, FOrderSpeed,
      BullOrders.ActOrdQty[1], BullOrders.ActOrdQty[0]

      ]);
end;

{ TBullOrders }


constructor TBullOrders.Create;
begin
  AutoType := atBull;
  SignalList  :=  TCollection.Create( TSignalItem );
  inherited;
end;

destructor TBullOrders.Destroy;
begin
  SignalList.Free;
  inherited;
end;

function TBullOrders.CheckSameSignal(aSymbol: TSymbol;
  aOrderSide: TPositionType; dPrice: Double; bX: boolean): boolean;
var
  i  : integer;
  aSignal : TSignalItem ;
  stSrc, stDest : string;
begin
  Result := false;
  stDest  := Format( '%.*n', [ aSymbol.Spec.Precision, dPrice ] );

  for i := SignalList.Count-1 downto 0 do
  begin
    // 일단 종목, 방향, 가격 만 비교..
    aSignal := TSignalItem( SignalList.Items[i] );
    stSrc := Format( '%.*n', [ aSymbol.Spec.Precision, aSignal.OrderPrice ] );
    if ( aSignal.Symbol = aSymbol ) and
       ( aSignal.OrderSide = aOrderSide ) and
       ( CompareStr( stSrc, stDest ) = 0 ) and
       ( aSignal.XSignal = bX) then
    begin
      Result := true;
      break;
    end;

    Break;

  end;

end;



end.
