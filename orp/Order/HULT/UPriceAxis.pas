unit UPriceAxis;

interface

uses
  Classes, SysUtils, Math, DateUtils,

  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFrontOrder,

  UObjectBase, UPaveConfig, UPriceItem,  UFillList, CleQuoteTimers,

  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleCircularQueue,

  GleTypes, GleConsts

  ;

const
  KEEP_CNT = 2;
  CLR_ORD  = 100;
type

  TPriceAxis = class( TTradeBase )
  private
    FPriceSet: TPriceSet;
    FPaveData: TPaveData;
    FLossCut : boolean;

    FEventCount: integer;
    FReady: boolean;
    FAskIdx: integer;
    FLastIdx: integer;
    FBidIdx: integer;

    FLastTime : TDateTime;

    FAskStartIdx: integer;
    FBidStartIdx: integer;

    FAskPrice : TPriceItem2;
    FBidPrice : TPriceItem2;

    FOnPositionEvent: TObjectNotifyEvent;
    FLcTimer : TQuoteTimer;
    FOnHitOrderEvent: TTextNotifyEvent;
    FOnStopEvent : TStopEvent;

    FRemSide, FRemNet, FRemQty : integer;
    FRetryCnt : integer;
    FMinPL, FMaxPL : double;

    FOrders: TOrderItem;
    FLiqOrders: TOrderItem;
    procedure OnLcTimer( Sender : TObject );
    procedure OnQuote( aQuote : TQuote; iData : integer ); override;
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID ); override;
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID  ); override;

    function IsRun : boolean;

    procedure DoInit( aQuote : TQuote );
    procedure DoOrder(iSide: integer; dPrice: double; iIdx : integer; bClear : boolean = false);

    procedure DoLiquidOrder(iSide: integer; dPrice, dFillPrice : double; iQty, iIdx: integer;
      bClear : boolean; iTag : integer); overload;
    procedure DoLiquidOrder(aQuote: TQuote; iSide: integer; var iMove : integer; iCnt : integer = 2); overload;
    function GetLiquidPrice(aQuote: TQuote; posType: TPositionType): double;

    procedure DoFill(aOrder: TOrder);
    procedure MakePriceItem;


    procedure Reset;
    procedure FindLiqudiOrder( var aList : TList;  iNet : integer; aPrice : TPriceItem2 );

    procedure CheckLossCut(aQuote: TQuote; aType : TPositionType);
    procedure CheckBuyLossCut(aQuote: TQuote);
    procedure CheckSellLossCut(aQuote: TQuote);

    function IsOrder(aPrice: TPriceItem2): boolean;
    function GetOrderSpecies : TOrderSpecies;

    procedure DoLog; overload;
    procedure DoLog( stData : string ); overload;
    function  BHULTLossCut( iSide: integer): integer;

    procedure AddOrder( aOrder : TOrder );
    procedure CheckOrderCount;
    procedure CheckLiqOrderCount( aQuote : TQuote );
    procedure DoChangeOrder(iMove, iSide: integer);

  public

    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    procedure init( aAcnt : TAccount; aSymbol : TSymbol; aType : integer); override;

    function Start : boolean;
    Procedure Stop( bAll : boolean = true );

    property Orders   : TOrderItem read FOrders ;
    property LiqOrders   : TOrderItem read FLiqOrders ;
    property PriceSet : TPriceSet  read FPriceSet ;
    property PavData  : TPaveData  read FPaveData write FPaveData;

    property Ready    : boolean    read FReady ;  // 포석을 깔았다 / 아직 안깔았다
    property EventCount : integer read FEventCount write FEventCount;
    //
    property LastIdx  : integer read FLastIdx;
    property AskIdx   : integer read FAskIdx;
    property BidIdx   : integer read FBidIdx;

    property AskStartIdx : integer read FAskStartIdx;
    property BidStartIdx : integer read FBidStartIdx;

    property MinPL : double read FMinPL;
    property MaxPL : double read FMaxPL;

    property OnPositionEvent : TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property OnHitOrderEvent : TTextNotifyEvent read FOnHitOrderEvent write FOnHitOrderEvent;
    property OnStopEvent : TStopEvent read FOnStopEvent write FOnStopEvent;

  end;

implementation

uses
  GAppEnv, GleLib, Dialogs
  ;

{ TPriceAxis }



constructor TPriceAxis.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FPriceSet := TPriceSet.Create;

  FOrders   := TORderItem.Create( nil );
  FLiqOrders:= TOrderItem.Create( nil );

  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 1000;
  FLcTimer.OnTimer := OnLcTimer;

  Reset;
end;

destructor TPriceAxis.Destroy;
begin
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);

  FOrders.Free;
  FLiqOrders.Free;

  FPriceSet.Free;
  inherited;
end;

procedure TPriceAxis.Reset;
begin
  Run  := false;
  FReady  := false;
  FLossCut:= false;

  FEventCount := 0;

  FAskIdx := -1;
  FLastIdx:= -1;
  FBidIdx := -1;

  FAskStartIdx  := -1;
  FBidStartIdx  := -1;


  FORders.Reset;
  FLiqOrders.Reset;

  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FRetryCnt := 0;
end;

procedure TPriceAxis.init(aAcnt : TAccount; aSymbol : TSymbol; aType : integer);
begin
  inherited;

  FOrders.Account := Account;
  FOrders.Symbol  := Symbol;
  FOrders.Position:= Position;

  FLiqOrders.Account := Account;
  FLiqOrders.Symbol  := Symbol;
  FLiqOrders.Position:= Position;

  MakePriceItem;
  Reset;
end;

procedure TPriceAxis.MakePriceItem;
var
  dPrice : double;
  i : integer;
begin
  FPriceSet.Clear;
  FPriceSet.Symbol  := Symbol;

  dPrice := Symbol.LimitLow;
  i := 0;

  while True do
  begin
      // add a step
    with FPriceSet.New( i ) do
    begin
      Price := dPrice;
      PriceDesc := Format('%.*n', [Symbol.Spec.Precision, dPrice]);
    end;
    dPrice := TicksFromPrice(Symbol, dPrice, 1);
    inc(i);
    if dPrice > Symbol.LimitHigh + PRICE_EPSILON then Break;
  end;
end;

function TPriceAxis.IsRun: boolean;
begin
  if ( not Run ) or ( Symbol = nil ) or ( Account = nil ) or ( Orders = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TPriceAxis.OnLcTimer(Sender: TObject);
begin
  inc(FReTryCnt);
  FRemQty := FRemQty + BHULTLossCut( FRemSide );
  gEnv.EnvLog(WIN_HULFT, Format( 'LcTimer Time :%d, %d -> %d',
        [ FRemSide, FRemNet, FRemQty ] ) );

  if FReTryCnt >= RETRY_CNT then
  begin
    FLcTimer.Enabled := false;
    FLossCut := false;
    gEnv.EnvLog(WIN_HULFT, Format( 'LcTimer Stop RetryCnt :%d, %d -> %d (%d), %d',
        [ FRemSide, FRemNet, FRemQty,  Position.Volume, FRetryCnt  ] ) );
  end;

end;

procedure TPriceAxis.OnOrder(aOrder: TOrder; EventID: TDistributorID);
var
  aPrice : TPriceItem2;
  idx : integer;
  I: Integer;
  bFind : boolean;
  stLog : string;
  bFull, bCancel : boolean;
  iQty : integer;
begin


  // 인덱스..
  if aOrder.PriceIdx < 0 then
  begin
    idx := FPriceSet.Find( aOrder.Price);
    if idx >= 0 then
      aOrder.PriceIdx  := idx
    else begin
      DoLog( format('Not Found Order : %s', [ aOrder.Represent2  ]));
      Exit;
    end;
    aOrder.OrderSpecies := GetOrderSpecies;
  end;

  case EventID of
    ORDER_FILLED  :
      begin
        DoLog( Format('Fill : %s ', [ aOrder.Represent2 ]));
        DoFill( aOrder );
      end;
    ORDER_ACCEPTED: DoLog( Format('Acpt : %s ', [ aOrder.Represent2 ]));
  end;


  if not (aOrder.State in [osReady, osSent, osSrvAcpt, osActive]) then
  begin
    if aOrder.OrderTag = CLR_ORD then
    begin
      if aOrder.Side > 0 then
        FLiqOrders.BidOrders.Remove( aOrder)
      else
        FLiqOrders.AskOrders.Remove( aOrder);
    end else
    begin
      if aOrder.Side > 0 then
        FOrders.BidOrders.Remove( aOrder)
      else
        FOrders.AskOrders.Remove( aOrder);
    end;
  end;

  case EventID of
    ORDER_FILLED  :  CheckOrderCount;
  end;
end;

procedure TPriceAxis.OnPosition(aPosition: TPosition; EventID: TDistributorID);
begin
  if not IsRun then Exit;

  if aPosition = Position then
    if Assigned( FOnPositionEvent ) then
      FOnPositionEvent( Self, aPosition );
end;

procedure TPriceAxis.OnQuote(aQuote: TQuote; iData : integer);
var
  iNn, iQty : integer;
  TradeAmt : double;
var
  dtStart : TdateTime;
begin

  if iData = 300 then
  begin
    DoLog;
    Exit;
  end;

  if not IsRun then Exit;
  if ( Symbol <> aQuote.Symbol ) then Exit;

  dtStart := EncodeTime( 9, 0, 10, 0 );

  FMinPL := Min( FMinPL, (Position.LastPL - Position.GetFee) );
  FMaxPL := Max( FMaxPL, (Position.LastPL - Position.GetFee) );

  if (not FReady) and ( dtStart < Frac( GetQuoteTime ))  then
    DoInit( aQuote ) ;

  CheckLiqOrderCount( aQuote );

end;

procedure TPriceAxis.CheckLiqOrderCount( aQuote : TQuote );
var
  iSide ,iMove, iCnt : integer;
begin
  iMove := 0;
  // 평가손익이 + 일때
  if (Position.EntryOTE > (FPaveData.LiqOTE )  ) and ( abs(Position.Volume) >= FPaveData.LCNet )  then
  begin
    if Position.Volume > 0 then
      iSide := -1
    else
      iSide := 1;

    DoLog( Format(' 평가손익 손절 -> 잔고 %d 개 , 평가손익 %.0f  (%d)', [ Position.Volume,
      Position.EntryOTE, iCnt ] ));
    DoLiquidOrder( aQuote, iSide , iMove );
    if iMove > 0 then
      DoChangeOrder( iMove, iSide );
  end;

  iCnt := 0;
  if abs(Position.Volume) > FPaveData.MaxNet then
  begin
    if Position.Volume > 0 then
      iCnt := LiqOrders.AskOrders.Count -1
    else
      iCnt := LiqOrders.BidOrders.Count -1;

    iSide := ifThen( Position.Volume > 0 , -1, 1 ) ;

    if iCnt > 0 then
    begin
      DoLog( Format(' 잔고기준 손절 -> 잔고 %d 개 , 평가손익 %.0f  (%d)', [ Position.Volume,
        Position.EntryOTE, iCnt ] ));
      DoLiquidOrder( aQuote, iSide , iMove, iCnt );
      if iMove > 0 then
        DoChangeOrder( iMove, iSide );
    end;
  end;
end;


procedure TPriceAxis.DoLiquidOrder( aQuote : TQuote;  iSide : integer ; var iMove : integer; iCnt : integer  );
var
  dPrice : double;
  i, ivolume : integer;
  aOrder, pOrder : TOrder;
  stLog   : string;
  aTicket : TOrderTicket;

  function IsLimited : boolean;
  begin
    if (Symbol.LimitHigh > dPrice + EPSILON ) and (Symbol.LimitLow <  dPrice + EPSILON) then
      Result := false
    else
      Result := true;
  end;

begin

  if iSide > 0 then
  begin

    for I := FLiqOrders.BidOrders.Count - 1 downto iCnt do
    begin
      aOrder  := FLiqOrders.BidOrder[i];
      if aOrder = nil then Continue;

      if ( aOrder.OrderType = otNormal ) and ( aOrder.State = osActive ) and ( not aOrder.Modify )  and
         ( aOrder.ActiveQty > 0 ) then
      begin

        DoLog( Format('매도 청산(%d) : 주문가 %s  청산 %s [%s]',
         [ FLiqOrders.BidOrders.Count,  Symbol.PriceToStr( aOrder.Price ),
          Symbol.PriceToStr( dPrice ), aOrder.Represent2 ]) );

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aOrder, aOrder.ActiveQty, aTicket);
        if pOrder <> nil then
          gEnv.Engine.TradeBroker.Send(aTicket);

        FLiqORders.BidOrders.Remove( aOrder );

        inc( iMove );
      end;
    end;
  end else
  if iSide < 0 then
  begin

    for I := FLiqOrders.AskOrders.Count - 1 downto iCnt do
    begin
      aOrder  := FLiqOrders.AskOrder[i];
      if aOrder = nil then Continue;

      if ( aOrder.OrderType = otNormal ) and ( aOrder.State = osActive ) and ( not aOrder.Modify ) and
         ( aOrder.ActiveQty > 0 ) then
      begin

          DoLog( Format('매수 청산(%d) : 주문가 %s  청산 %s [%s]',
           [ FLiqOrders.AskOrders.Count,
             Symbol.PriceToStr( aOrder.Price ), Symbol.PriceToStr( dPrice ), aOrder.Represent2 ]));

          aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aOrder, aOrder.ActiveQty, aTicket);
          if pOrder <> nil then
            gEnv.Engine.TradeBroker.Send(aTicket);

          FLiqORders.AskOrders.Remove( aOrder );
          inc( iMove );
      end;
    end;
  end;

  if iMove > 0 then
  begin

    if iSide > 0 then
      dPrice  := TicksFromPrice( Symbol, aQuote.Asks[0].Price , 4  )
    else
      dPrice  := TicksFromPrice( Symbol, aQuote.Bids[0].Price , -4  );

    if IsLimited then Exit;

    ivolume := iMove;

    if iVolume <= 0 then
    begin
      DoLog( Format('엇 수량 에러..잔고 : %d,  청산주문 카운트 %d : %d ',
        [ Position.Volume,  FLiqOrders.BidOrders.Count,
          FLiqOrders.AskOrders.Count ] ));
      Exit;
    end;

    if iSide < 0 then
      iVolume := iVolume * -1;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
    aORder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                  gEnv.ConConfig.UserID, Account, Symbol,
                  iVolume, pcLimit, dPrice, tmGTC, aTicket);  //

    if aOrder <> nil then
    begin
      aOrder.OrderTag := -100;
      gEnv.Engine.TradeBroker.Send(aTicket);
      //gEnv.Engine.TradeCore.Orders.DoNotify( Result );
    end;
  end;
end;

procedure TPriceAxis.DoChangeOrder( iMove,  iSide : integer );
var
  dPrice : double;
  i , iCnt: integer;
  pOrder, aOrder, bOrder : TOrder;
  tgPrice : TPriceItem2;
  stLog   : string;
  aTicket : TOrderTicket;

begin

  iCnt  := 0;
  // 매수주문 ( 매도잔고 청산)
  if iSide > 0 then
  begin
    aOrder  := FOrders.BidOrder[0];
    if aOrder = nil then Exit;

    tgPrice := FPriceSet.PriceItem[ aOrder.PriceIdx + FPaveData.OrdGap ];
    if tgPrice = nil then Exit;

    if FLiqOrders.BidOrders.Count <= 0 then
      dPrice  := Symbol.Last
    else begin
      bOrder  := FLiqORders.BidOrder[ FLiqOrders.BidOrders.Count -1 ];
      if bOrder = nil then Exit;
      dPrice  := bOrder.Price;
    end;

    DoLog( format( '매수 주문채우기 %s 부터 %s 까지  ',
       [ Symbol.PriceToStr( aOrder.Price ), Symbol.PriceToStr( dPrice ) ]));

    while tgPrice.Price < dPrice do
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
      pOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                  gEnv.ConConfig.UserID, Account, Symbol,
                  aOrder.OrderQty * aOrder.Side , pcLimit, tgPrice.Price, tmGTC, aTicket);
      pOrder.PriceIdx     := tgPrice.Index ;

      gEnv.Engine.TradeBroker.Send(pOrder.Ticket);
      AddOrder( pOrder );

      DoLog( Format('%d(%d) 매수 주문 %s, %d' ,
       [ iCnt, FOrders.BidOrders.Count,  Symbol.PriceToStr( pOrder.Price ), pOrder.OrderQty ]) );

      inc( iCnt );
      if iCnt > 10  then
        break;

      tgPrice := FPriceSet.PriceItem[ aOrder.PriceIdx + (FPaveData.OrdGap * (iCnt +1) ) ];
      if tgPrice = nil then
        break;
    end;
  end else
  // 매도주문 ( 매수잔고 청산)
  if iSide < 0 then
  begin

    aOrder  := FOrders.AskOrder[0];
    if aOrder = nil then Exit;

    tgPrice := FPriceSet.PriceItem[ aOrder.PriceIdx - FPaveData.OrdGap ];
    if tgPrice = nil then Exit;
    iCnt  := 0;

    if FLiqOrders.AskOrders.Count <= 0 then
      dPrice  := Symbol.Last
    else begin
      bOrder  := FLiqORders.AskOrder[ FLiqOrders.AskOrders.Count -1 ];
      if bOrder = nil then Exit;
      dPrice  := bOrder.Price;
    end;

    DoLog( format( '매도 주문채우기 %s 부터 %s 까지  ',
       [ Symbol.PriceToStr( aOrder.Price ), Symbol.PriceToStr( dPrice ) ]));

    while tgPrice.Price > dPrice do
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
      pOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                  gEnv.ConConfig.UserID, Account, Symbol,
                  aOrder.OrderQty * aOrder.Side , pcLimit, tgPrice.Price, tmGTC, aTicket);
      pOrder.PriceIdx     := tgPrice.Index ;

      gEnv.Engine.TradeBroker.Send(pOrder.Ticket);
      AddOrder( pOrder );

      DoLog( Format('%d(%d) 매도 주문 %s, %d' ,
       [ iCnt, FOrders.AskOrders.Count,  Symbol.PriceToStr( pOrder.Price ), pOrder.OrderQty ]) );

      inc( iCnt );
      if iCnt > 10  then
        break;

      tgPrice := FPriceSet.PriceItem[ aOrder.PriceIdx - ( FPaveData.OrdGap * (iCnt + 1) )  ];
      if tgPrice = nil then
        break;
    end;
  end

end;



procedure TPriceAxis.DoLog;
var
  stLog, stFile : string;
begin
  stLog := Format('%s, %.0f, %.0f, %.0f, %d',
                  [FormatDateTime('yyyy-mm-dd', GetQuoteTime),
                    Position.LastPL - Position.GetFee, FMaxPL, FMinPL, Position.MaxPos]);
  stFile := Format('EvolHulft_%s.csv', [ Account.Code]);
  gEnv.EnvLog(WIN_HULFT, stLog, true, stFile);
end;

procedure TPriceAxis.DoLog( stData : string );
begin
  if Account <> nil then
    gEnv.EnvLog( WIN_HULFT, stData, false, Account.Code);
end;

function TPriceAxis.Start : boolean;
begin
  Result := false;
  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  Run := true;
  //gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, Symbol,
  //  gEnv.Engine.QuoteBroker.DummyEventHandler);

  gLog.Add( lkLossCut, 'TPriceAxis','Start', Symbol.Code );
end;

procedure TPriceAxis.Stop( bAll : boolean );
begin
  Run := false;

  if Assigned(OnStopEvent) then
    OnStopEvent(Run);

  //gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, Symbol );
  gLog.Add( lkLossCut, 'TPriceAxis','Stop', Symbol.Code );
  gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );

  if FLossCut then
  begin
    if (FRemNet - FRemQty ) > 0  then
    begin
      gEnv.EnvLog(WIN_HULFT, Format( 'LcTimer 시작 :%d, %d -> %d',
        [ FRemSide, FRemNet, FRemQty ] ) );
      FLcTimer.Enabled := true;
    end;
  end;

end;

function TPriceAxis.IsOrder(aPrice: TPriceItem2): boolean;
var
  idx, iRe : Integer;
begin
  Result := false;
  if aPrice.PositionType = ptLong then
    idx := abs( FBidStartIdx - aPrice.Index )
  else
    idx := abs( FAskStartIdx - aPrice.Index );
  iRe := idx mod FpaveData.OrdGap;
  if iRe = 0 then
    Result := true;
end;

procedure TPriceAxis.DoInit( aQuote : TQuote );
var
  iAsks, iBids,I, iAskIdx, iBidIdx: Integer;
  dLastAskPrice, dLastBidPrice : double;
  AskPrice, BidPrice : double;
  aItem : TPriceItem2;

  function IsLAskimited : boolean;
  begin
    if (Symbol.LimitHigh > dLastAskPrice + EPSILON ) and (aQuote.Asks[0].Price + EPSILON < dLastAskPrice ) then
      Result := false
    else
      Result := true;
  end;

  function IsBidLimited : boolean;
  begin
    if (Symbol.LimitLow <  dLastBidPrice + EPSILON ) and (aQuote.Bids[0].Price + EPSILON > dLastBidPrice ) then
      Result := false
    else
      Result := true;
  end;
begin

  FReady := true;

  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;

  iAsks := FPaveData.AskHoga ;
  iBids := FPaveData.BidHoga ;

  AskPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Last, FPaveData.OrdGap div 2 );
  BidPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Last, -FPaveData.OrdGap div 2 );

  gLog.Add( lkLossCut, 'TPriceAxis','DoInit', Format('Index  : %s <- %s | %s -> %s cnt:%d',
    [
      aQuote.Symbol.PriceToStr( AskPrice ),
      aQuote.Symbol.PriceToStr( aQuote.Asks[0].Price ),
      aQuote.Symbol.PriceToStr( aQuote.Bids[0].Price ),
      aQuote.Symbol.PriceToStr( BidPrice ),
      FPriceSet.Count-1
    ]));

  for I := 0 to FPaveData.OrdCnt - 1 do
  begin
    dLastAskPrice := IfThenFloat( i=0, AskPrice,  TicksFromPrice( Symbol, dLastAskPrice, FPaveData.OrdGap ));
    if not IsLAskimited  then begin
      iAskIdx := FPriceSet.GetIndex( dLastAskPrice );
      if iAskIdx >= 0 then begin
        FAskPrice := FPriceSet.PriceItem[iAskIdx];
        DoOrder( -1, dLastAskPrice, iAskIdx );

        if FAskStartIdx < 0 then
          FAskStartIdx := iAskIdx;
      end;
    end;

    dLastBidPrice := IfThenFloat( i=0, BidPrice,  TicksFromPrice( Symbol, dLastBidPrice, -FPaveData.OrdGap ));
    if not IsBidLimited  then begin
      iBidIdx := FPriceSet.GetIndex( dLastBidPrice );
      if iBidIdx >= 0 then begin
        FBidPrice := FPriceSet.PriceItem[iBidIdx];
        DoOrder( 1, dLastBidPrice, iBidIdx  );
        if FBidStartIdx < 0 then
          FBidStartIdx := iBidIdx;
      end;
    end;
  end;

  if ( FAskStartIdx >= 0 ) and  ( FBidStartIdx >= 0 ) then
  begin
    FReady := true;
  end else
    ShowMessage( 'Start Index Error ' );         
end;

procedure TPriceAxis.DoOrder( iSide : integer;  dPrice : double; iIdx : integer; bClear : boolean );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
  aPos : TPosition;
  aPrice : TPriceItem2;
  iMax : integer;
  iLiqQty , iLiqQty2, iQty : integer;
begin

  iQty  :=  FPaveData.OrdQty;

  if (Account=nil) or (Symbol=nil)  or ( dPrice <= 0.1 ) or ( iQty <= 0) then
  begin
    DoLog( Format( 'DoOrder_Account or Symbol is Null or %.2f  , %d', [ dPrice, iQty ] ));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, Account, Symbol,
                iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin

    aOrder.OrderSpecies := GetOrderSpecies;
    // 인자 하나 만들기 귀찮아서..
    if bClear then
    begin
      // 일반 주문 깔 Index
      aOrder.OrderTag     := CLR_ORD;// 청산을 목적으로  주문..
      aOrder.TargetIdx    := iIdx;
      iIdx := FPriceSet.GetIndex( Symbol.PriceToStr( dPrice ));
      // 내 주문 Index
      aOrder.PriceIdx     := iIdx;
    end
    else
      aOrder.PriceIdx     := iIdx;

    gEnv.Engine.TradeBroker.Send(aTicket);

    stLog := Format( 'Send Order : %s ',  [ aOrder.Represent2   ]   );

    DoLog( stLog );
    AddOrder( aOrder );
  end;
end;


procedure TPriceAxis.FindLiqudiOrder(var aList: TList; iNet : integer; aPrice: TPriceItem2);
begin

end;

procedure TPriceAxis.DoLiquidOrder( iSide : integer;  dPrice, dFillPrice  : double; iQty, iIdx : integer;
    bClear : boolean; iTag : integer );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
  aPos : TPosition;
  aPrice : TPriceItem2;
  iMax, i : integer;
  aFill : TFillItem;
begin
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, Account, Symbol,
                iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin

    aOrder.OrderSpecies := GetOrderSpecies;

    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'Send Liquid Order : %s, %s, (%s:%s), %d, idx:%d %s ',
      [
        Symbol.Code,
        ifThenStr( iSide > 0 , 'L', 'S'),
        Symbol.PriceToStr( Symbol.Last ),
        Symbol.PriceToStr( dPrice ),
        iQty, iIdx,  ifthenStr( bClear,'청산','Not 청산')
      ]
      );

    gEnv.EnvLog( WIN_HULFT , Format('청산 : %s ', [ aOrder.Represent2 ] ), false, Symbol.Code);
      {
    aPrice  := FPriceSet.PriceItem[iIdx];
    if aPrice <> nil then
    begin

      iMax := iQty;
      for I := 0 to aPrice.OrderList.Count - 1 do begin
        aOrder  := aPrice.OrderList.Orders[i];
        if (aOrder.State = osActive) and ( aOrder.OrderType = otNormal ) and
          ( not aOrder.ClearOrder)  then
          begin
            DoCancel( aOrder );
          end;
      end;

      aPrice.AddOrder( aOrder );
      aOrder.PriceIdx := iIdx;
      //aOrder.RemainVol:= aPrice.Volume[ aPrice.PositionType];
    end;    }
  end
  else
    stLog := Format( 'Send Liquid Order Error : %s, %s, (%s:%s), %d, idx:%d %s ',
      [
        Symbol.Code,
        ifThenStr( iSide > 0 , 'L', 'S'),
        Symbol.PriceToStr( Symbol.Last ),
        Symbol.PriceToStr( dPrice ),
        iQty, iIdx,  ifthenStr( bClear,'청산','Not 청산')
      ]
      );
  gLog.Add(lkLossCut, 'TPriceAxis','DoLiquidOrder', stLog );
end;


procedure TPriceAxis.DoFill(aOrder: TOrder);
var
  iOrdQty, iIdx, iGap, iTgIdx : integer;
  aFill : TFill;
  stLog : string;
  dPrice : double;
  aQuote : TQuote;
  tgPrice, aPrice : TPriceItem2;
  bRes : boolean;
begin
  if not IsRun then
    Exit;

  aFill := TFill( Position.Fills.Last );
  if aFill = nil then Exit;
  iOrdQty := abs(aFill.Volume);

  aQuote  := Symbol.Quote as TQuote;

  stLog := format('New Fill : %s, (%s)%s, %s, %d (%d) %s|%s|%s ', [
    Symbol.Code, ifThenStr( aOrder.Side > 0 ,'L','S' ),
    Symbol.PriceToStr( aOrder.Price ),
    Symbol.PriceToStr( aFill.Price ),
    iOrdQty, aOrder.OrderNo,
    Symbol.PriceToStr( aQuote.Asks[0].Price ),
    Symbol.PriceToStr( aQuote.Last ),
    Symbol.PriceToStr( aQuote.Bids[0].Price )
     ]);
  gLog.Add( lkLossCut,'TPriceAxis', 'DoFill', stlog );

  if aOrder.PriceIdx < 0 then begin
    iIdx := FPriceSet.GetIndex( aFill.Price );
    aOrder.PriceIdx := iIdx;
  end;

  //  일반 주문 체결 되면..
  //  일반 주문의 Priceidx 를 청산주문의 TargetIdx 에 대입
  //  청산주문이 체결 되면 TargetIdx 에 일반 주문을 대 놓는다..
  //  TargetIdx 를 이용해 peices 를 사용안한당..

  if aOrder.OrderTag > -100 then  
    if aOrder.OrderTag <> CLR_ORD then
    begin
      dPrice := TicksFromPrice( Symbol, aOrder.Price, FPaveData.Profit * aOrder.Side );
      //aPrice := FPriceSet.PriceItem[ iTgIdx ];
      // 청산 주문 낼때는 일반 주문의 인덱스를 인자로 -> TargetIdx 를 채워야 하기때문에
      DoOrder( aOrder.Side * -1, dPrice, aOrder.PriceIdx, true );
    end
    else begin
      iTgIdx := aOrder.TargetIdx;
      if (iTgIdx >= 0) and ( aOrder.OrderTag = CLR_ORD ) then
      begin
        aPrice := FPriceSet.PriceItem[ iTgIdx ];
        dPrice := aPrice.Price;
        iIdx   := FPriceSet.GetIndex( Symbol.PriceToStr( dPrice ));
        DoOrder( aOrder.Side * -1, dPrice, iIdx  );
      end;
    end;

end;

procedure TPriceAxis.CheckOrderCount;
var
  iCnt, idx : integer;
  aOrder   : TOrder;
  aPrice   : TPriceItem2;
begin

  DoLog( format('Order State Buy : %d(%d), Sell : %d(%d)', [
    FOrders.BidOrders.Count, FLiqORders.BidOrders.Count,
    FOrders.AskOrders.Count, FLiqOrders.AskOrders.Count ] ));
  {
  if FLiqOrders.AskOrders.Count >= FPaveData.MaxNet then
  begin
    // 출동..
  end else
  begin
  }
    // on -> off
    // 매수 청산주문이 없고  , 깔린 매수 주문이 하나라면..
  if FLiqOrders.BidOrders.Count = 0 then
    if FOrders.BidOrders.Count = 1 then
    begin
      aOrder  := FOrders.BidOrder[0];
      idx := aOrder.PriceIdx  - FPaveData.OrdGap;
      if idx >=0  then begin
        aPrice  := FPriceSet.PriceItem[idx];
        DoOrder(1, aPrice.Price, idx );
      end;
    end;
  //end;
 {
  if FLiqOrders.BidOrders.Count >= FPaveData.MaxNet then
  begin

  end else
  }
  if FLiqOrders.AskOrders.Count = 0 then
    if FOrders.AskOrders.Count = 1 then
    begin
      aOrder  := FOrders.AskOrder[0];
      idx := aOrder.PriceIdx  + FPaveData.OrdGap;
      if idx >=0  then begin
        aPrice  := FPriceSet.PriceItem[idx];
        DoOrder(-1, aPrice.Price, idx );
      end;
    end;

end;

procedure TPriceAxis.CheckLossCut( aQuote : TQuote; aType : TPositionType );
begin
  // 매도일때 매수 체크
  if aType = ptShort then
    CheckBuyLossCut( aQuote )
  // 매수일때 매도 체크
  else if aType = ptLong then
    CheckSellLossCut( aQuote );
end;

procedure TPriceAxis.AddOrder(aOrder: TOrder);
begin

  if aOrder.OrderTag = CLR_ORD then
  begin
    if aOrder.Side > 0 then
      FLiqOrders.BidAdd( aOrder )
    else
      FLiqOrders.AskAdd( aOrder );
  end
  else begin
    if aOrder.Side > 0 then
      FOrders.BidAdd( aOrder )
    else
      FOrders.AskAdd( aOrder );
  end;

end;


function TPriceAxis.BHULTLossCut(iSide: integer): integer;
var
  stLog : string;
  i, iLiqQty, iLiqQty2, iCnt : integer;
  aOrder : TOrder;
  arList : TList;
  aPrice : TPriceItem2;
begin

end;

procedure TPriceAxis.CheckBuyLossCut( aQuote : TQuote );
var
  dPrice : double;
  I, idx, iTick, iTick2 : Integer;
  aOrder : TOrder;
  stLog : string;

  tgPrice : TPriceItem2;
begin

end;

procedure TPriceAxis.CheckSellLossCut( aQuote : TQuote );
var
  dPrice : double;
  I, idx, iTick, iTick2 : Integer;
  aOrder : TOrder;
  stLog : string;
  tgPrice : TPriceItem2;
begin

end;

function TPriceAxis.GetLiquidPrice( aQuote : TQuote ; posType : TPositionType ) : double;
var
  aType : TPositionType;
  bHit : boolean;
  stLog : string;
begin
  if PosType = ptLong then
    aType := ptShort
  else
    aType := ptLong;
  {
  bHit := false;
  stLog := '';
  if (Position.EntryOTE[ aType ] < 0) and ( Position.Volume[aType] > 0 ) then
  begin
    if (abs( Position.AvgPrice[ aType] - aQuote.Last ) / Symbol.Spec.TickSize ) > FPaveData.LossCut then begin
      Result := TicksFromPrice( Symbol, aQuote.Last,  ifThen( PosType = ptLong, 2, -2 ));
      bHit   := true;
    end
    else
      Result := ifThenFloat( PosType = ptLong,  aQuote.Bids[0].Price, aQuote.Asks[0].Price );
  end
  else
    Result := ifThenFloat( PosType = ptLong,  aQuote.Bids[0].Price, aQuote.Asks[0].Price );

  stLog := Format('%s %s  pl : %.0f  lossTick( %d / %d ), prc (%s / %s )',
    [
     ifThenStr( aType = ptLong,'매도주문','매수주문'),
     ifThenStr( bHit,'친다','깐다'),
     Position.EntryOTE[ aType ],
     (abs( Position.AvgPrice[ aType] - aQuote.Last ) / Symbol.Spec.TickSize ) , FPaveData.LossCut,
     Symbol.PriceToStr(Result), Symbol.PriceToStr( aQuote.Last )
    ]);

  gLog.Add(lkLossCut, 'TPriceAxis','GetLiquidPrice', stLog);  }
end;



function TPriceAxis.GetOrderSpecies: TOrderSpecies;
begin
  Result := opEvolHult;
end;

end.
