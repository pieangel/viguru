unit CleLayOrder;

interface

uses
  Classes, SysUtils,

  CleAccounts, CleSymbols, ClePositions, CleOrders, CleQuoteBroker,

  ClePaveOrderType, CleFrontOrder , CleQuoteTimers,

  GleTypes
  ;

type

  TLayOrder = class
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FPosition: TPosition;
    FParam: TLayOrderParam;
    FEventCount: integer;

    FReady  : boolean;
    FBaseBidPrice  : double;
    FBaseAskPrice  : double;
    FOrders: TOrderItem;
    FLogData: string;
    FOnEndNotify: TNotifyEvent;
    FMoneyStr: string;
    procedure CalcBasePrice( aQuote : TQuote );
    procedure DoWork(aQuote: TQuote);
    procedure DoInit(aQuote: TQuote);

    procedure DoLayLog( stLog : string );
    procedure OnFilled(aOrder: TOrder);
    procedure OnModified(aOrder: TOrder);
    procedure OnNewOrder(aOrder: TOrder);
    procedure OnRejected(aOrder: TOrder);
    procedure DoChnageOrder( iSide : integer );
    function FindPaveOrder(iSide: integer; dPrice : double): TOrder;


  public

    LayOrders  : TOrderItem;
    LiqOrders : TOrderItem;

    Constructor Create;
    Destructor  Destroy; override;

    procedure ApplyParam( dLossVol, dLossPer : integer; dtTime : TDateTime; iCnlHour : integer; iCnlTick : integer);
    procedure OnQuote( aQuote : TQuote );
    procedure OnOrder( aOrder : TOrder; iEventID : integer );
    procedure OnPosition( aPosition : TPosition; iEventID : integer);
    procedure OnTimer( Sender : TObject );

    procedure DoCancels( iSide : integer;  dPrice : double );

    procedure Reset;
    procedure init;

    procedure CalcDepositMoney;

    property Account : TAccount read FAccount write FAccount;
    property Symbol  : TSymbol  read FSymbol  write FSymbol;
    property Position: TPosition read FPosition write FPosition;
    property Orders : TOrderItem read FOrders write FOrders;
    //
    property EventCount : integer read FEventCount;
    property Param : TLayOrderParam read FParam write FParam;
    property LogData : string read FLogData;
    property MoneyStr : string read FMoneyStr;

    property OnEndNotify : TNotifyEvent read FOnEndNotify write FOnEndNotify;
  end;

  procedure DoRealLog( stData : string );

implementation

uses
  CleKrxSymbols, GAppEnv, GLeLib , GleConsts

  ;

{ TLayOrder }

procedure DoRealLog( stData : string );
begin

  gEnv.EnvLog( WIN_ENTRY, stData, false, 'RealHoga'  );
end;

procedure TLayOrder.ApplyParam(dLossVol, dLossPer: integer; dtTime: TDateTime; iCnlHour : integer; iCnlTick : integer);
begin
  FParam.LossVol  := dLossVol;
  FParam.LossPer  := dLossPer;
  FParam.EndTime  := dtTime;
  FParam.CnlHour  := iCnlHour;
  FParam.CnlTick  := iCnlTick;
end;

constructor TLayOrder.Create;
begin

  LayOrders := TOrderItem.Create( nil );
  LiqOrders := TOrderItem.Create( nil );

  Reset;
end;

destructor TLayOrder.Destroy;
begin
  LayOrders.Free;
  LiqOrders.Free;
  inherited;
end;

procedure TLayOrder.OnOrder(aOrder: TOrder; iEventID : integer);
begin
  case iEventID of
    // active ?? ????
    ORDER_ACCEPTED       ,
    ORDER_CHANGED        : OnNewOrder( aOrder ) ;
    // ???? ?????? ???? ?????? ???????? osActvie ?? ?????? ????..
    ORDER_CANCELED       ,
    ORDER_CONFIRMED      : OnModified( aOrder ) ;
    // ???????? ????,  ???? or ???? ????
    ORDER_REJECTED       ,
    ORDER_CONFIRMFAILED  : OnRejected( aOrder ) ;

    ORDER_FILLED         : OnFilled( aOrder ) ;
  end;

  if aOrder.State in [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed ] then
    if aOrder.GroupNo = 'P' then
    begin
      if aOrder.Side > 0 then
        LayOrders.BidOrders.Remove( aOrder)
      else
        LayOrders.AskOrders.Remove( aOrder);
    end else
    if aOrder.GroupNo = 'F' then
    begin
      if aOrder.Side > 0 then
        LiqOrders.BidOrders.Remove( aOrder)
      else
        LiqOrders.AskOrders.Remove( aOrder);
    end;
end;

procedure TLayOrder.OnPosition(aPosition: TPosition; iEventID : integer);
begin
  case iEventID of
    POSITION_NEW        ,
    POSITION_UPDATE     :;
  end;
end;

procedure TLayOrder.OnQuote(aQuote: TQuote);
begin

  if FEventCount = 0 then begin
    CalcBasePrice( aQuote );
    DoInit( aQuote );
    inc( FEventCount );
  end
  else
    DoWork( aQuote );
end;

procedure TLayOrder.Reset;
begin
  FEventCount := 0;
  FReady  := false; // baseprice ?? ????????
  FBaseBidPrice  := 0;
  FBaseAskPrice  := 0;
  FLogData       := '';
  FMoneyStr      := '';
end;

procedure TLayOrder.CalcBasePrice( aQuote : TQuote );
begin
  if aQuote.MarketState = '40' then
  begin
    FBaseBidPrice := aQuote.Last - 5;
    FBaseAskPrice := aQuote.Last + 5;
  end
  else begin
    FBaseBidPrice := FParam.LStartPrc;
    FBaseAskPrice := FParam.SStartPrc;
  end;
end;

procedure TLayOrder.DoInit( aQuote : TQuote );
var
  I: Integer;
  dPrice  : double;
  aTicket : TOrderTicket;
  aOrder  : TOrder;
begin
  if FParam.UseL then
  begin
    dPrice  := FBaseBidPrice;
    for I := 0 to FParam.OrdCnt - 1 do
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
      aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
        gEnv.ConConfig.UserID, FAccount, FSymbol, FParam.OrdQty,
        pcLimit, dPrice, tmGTC, aTicket );

      if aOrder <> nil then
      begin
        gEnv.Engine.TradeBroker.Send( aTicket);
        LayOrders.BidAdd( aOrder );
        aOrder.GroupNo  := 'P';
        aOrder.OrderSpecies := opPave;
        DoLayLog( Format('???????? %d -> %.2f, %d', [ i, aOrder.Price, aOrder.OrderQty ]));
      end;
      dPrice  := dPrice - ( FSymbol.Spec.TickSize * FParam.OrdGap );

      if dPrice < 0.01 then
      begin
        break;
        DoLayLog( Format('???????? ?????? ???????? ???? Break -> %d, %.2f', [ i, dPrice ] ) );
      end;
    end;

  end else
  if FParam.UseSS then
  begin
    dPrice  := FBaseAskPrice;
    for I := 0 to FParam.OrdCnt - 1 do
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
      aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
        gEnv.ConConfig.UserID, FAccount, FSymbol, -FParam.OrdQty,
        pcLimit, dPrice, tmGTC, aTicket );

      if aOrder <> nil then
      begin
        gEnv.Engine.TradeBroker.Send( aTicket);
        LayOrders.AskAdd( aOrder );
        aOrder.GroupNo  := 'P';
        aOrder.OrderSpecies := opPave;
        DoLayLog( Format('???????? %d -> %.2f, %d', [ i, aOrder.Price, aOrder.OrderQty ]));
      end;
      dPrice  := dPrice + ( FSymbol.Spec.TickSize * FParam.OrdGap );

      if dPrice > FSymbol.LimitHigh then
      begin
        break;
        DoLayLog( Format('???????? ?????? ???????? ???? Break -> %d, %.2f', [ i, dPrice ] ) );
      end;
    end;
  end;

end;

procedure TLayOrder.CalcDepositMoney;
var
  I: Integer;
  dPrice  : double;
  dSum, dTmp : double;
begin
  dSum := 0; dTmp := 0;
  if FParam.UseL then
  begin
    dPrice  := FBaseBidPrice;
    for I := 0 to FParam.OrdCnt - 1 do
    begin
      dTmp  := dPrice * FParam.OrdQty * FSymbol.Spec.PointValue;
      dSum  := dSum + dTmp ;
      DoLayLog( Format('??????(%d) : %.0n += %.0n (%.2f X %d)',
        [ i, 0, dSum, dTmp, dPrice, FParam.OrdQty ] ) );
      dPrice  := dPrice - ( FSymbol.Spec.TickSize * FParam.OrdGap );

      if dPrice < 0.01 then
      begin
        break;
      end;
    end;
  end;

  FMoneyStr := Format('?????? = %.0n' , [ dSum ] );
end;

procedure TLayOrder.DoLayLog(stLog: string);
var
  stSufix : string;
begin
  if ( FAccount <> nil ) and ( FSymbol <> nil ) then
    stSufix := FAccount.Code+'_'+FSymbol.ShortCode
  else
    stSufix := '';

  DoLog( stLog, stSufix );
end;

function TLayOrder.FindPaveOrder( iSide : integer; dPrice : double ) : TOrder;
var
  I: Integer;
  stFindkey, stDesKey : string;
  aOrder : TOrder;
begin
  Result := nil;

  stFindkey := Format('%.*n', [ FSymbol.Spec.Precision, dPrice ] );

  if iSide > 0 then
  begin
    for I := 0 to FOrders.BidOrders.Count - 1 do
    begin
      aOrder  := FOrders.BidOrder[i];
      if aOrder = nil then Continue;

      if aOrder.Price < (dPrice - PRICE_EPSILON) then
        break
      else begin
        stDesKey := Format( '%.*n',[ FSymbol.Spec.Precision,  aOrder.Price  ] );
        if CompareStr( stDesKey, stFindKey ) = 0 then
        begin
          Result := aOrder;
          break;
        end;
      end;
    end;
  end;

end;

procedure TLayOrder.DoWork( aQuote : TQuote );
var
  I, iRes: Integer;
  pOrder, aOrder, lOrder  : TOrder;
  aTicket : TOrderTicket;
  dComp, dPrice : double;
  tmpList : TList;
  bOrder, bCond : boolean;
begin
  if Position = nil then Exit;

  try
    bCond   := false;
    //dComp := aQuote.Bids.RealTimeAvg * ( FParam.LossPer / 100 );
    dComp := aQuote.Bids.RealVolSum / 4 * ( FParam.LossPer / 100 );
    if (( dComp > aQuote.Bids[0].Volume) or     // ???? 1
       ( aQuote.Bids[0].Volume < FParam.LossVol )) and  //????2
       ( aQuote.Bids[0].Volume > 0 ) then
      bCond := true;

    FLogData  := Format('%.2f -> %.2f | %d < %.0f, %d, %d', [
      aQuote.Symbol.ExpectPrice, aQuote.Symbol.Last,
      aQuote.Bids[0].Volume, dComp,
      LayOrders.BidOrders.Count, LiqOrders.AskOrders.Count]);


    for I := 0 to LiqOrders.AskOrders.Count - 1 do
    begin
      aOrder  := LiqOrders.AskOrder[i];

      if ( aOrder.State = osActive) and ( aOrder.OrderType = otNormal ) and
        ( aOrder.ActiveQty > 0 ) and ( not aOrder.Modify ) and ( aOrder.GroupNo = 'F') then
      begin

        bOrder := false;
        iRes   := ComparePrice( aOrder.Symbol.Spec.Precision, aOrder.Price , aQuote.Asks[0].Price );

        if (bCond) and ( iRes <= 0) then
        begin
          // ???? ?????? ???? ???? 1?????? ???????? ??????..?????? ???? ??????.
          lOrder  := FindPaveOrder( 1, aQuote.Bids[0].Price );
          if lOrder <> nil then
          begin
            DoLayLog( Format('???? 1???? %.2f ?? ???????? ???? ????' +
                             '%.2f, %d, F:%d, %d', [
                             aQuote.Bids[0].Price, lOrder.Price, lOrder.ActiveQty,
                             lOrder.FilledQty, lOrder.OrderNo
                             ]));
            continue;
          end;
          bOrder := true;
          dPrice := aQuote.Bids[0].Price;
        end else
        if iRes > 0 then
        begin
          bOrder := true;
          dPrice := aQuote.Asks[0].Price;
        end;

        ///--------------------------------------------------------------------------

        if bOrder then
        begin
          aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
          pOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrderEx( aOrder, aOrder.ActiveQty,
            pcLimit, dPrice, tmGTC, aTicket );
          if pOrder <> nil then
          begin
            pOrder.OrderSpecies := opPave;
            pOrder.GroupNo      := 'F';
            gEnv.Engine.TradeBroker.Send( aTicket );
            // ???? ?????? ????????  LiqOrders.add ????.
            DoLayLog( Format('????????(iRes = %d) %s,%.2f, %d, %d --> %.2f, %d  [ A1:%.2f, B1:%.2f, %d, < %.1f <-- %.1f ', [
                iRes, ifthenStr( aOrder.Side > 0, 'L', 'S' ), aOrder.Price, aOrder.ActiveQty, aOrder.OrderNo,
                pOrder.Price, pOrder.OrderQty,
                aQuote.Asks[0].Price, aQuote.Bids[0].Price, aQuote.Bids[0].Volume, dComp, aQuote.Bids.RealVolSum / 4
              ]));
          end;
        end; // if bOrder then
      end;
    end;

  finally
  end;
end;


procedure TLayOrder.DoCancels(iSide: integer; dPrice: double);
begin
  gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, iSide, dPrice );

  DoLayLog( Format(' ???? %s %.2f', [ ifthenStr(iSide > 0,'L',
      ifThenStr( iSide < 0,'S','All')), dPrice ]));
end;


procedure TLayOrder.DoChnageOrder( iSide : integer );
var
  i : integer;
  aOrder : TOrder;
begin
  if iSide > 0 then
  begin
      for I := 0 to LiqOrders.AskOrders.Count - 1 do
      begin
        aOrder  := LiqOrders.AskOrder[i];

        if ( aOrder.State = osActive) and ( aOrder.OrderType = otNormal ) and
          ( aOrder.ActiveQty > 0 ) and ( not aOrder.Modify ) and ( aOrder.GroupNo = 'F') then
        begin
        {
          dFilledPrc  := TicksFromPrice( aOrder.Symbol, aOrder.Price, -1 );
          iRes  := ComparePrice( FSymbol.Spec.Precision,  dFilledPrc, aQuote.Bids[0].Price );
        }


        end;
      end;
  end else
  begin

  end;
end;

procedure TLayOrder.init;
begin
  FOrders   := gEnv.Engine.TradeCore.FrontOrders.New( FAccount, FSymbol );
  FPosition := FOrders.Position ;
end;


//////////////////////////////////////////////////////////////////////////////////
///
procedure TLayOrder.OnNewOrder( aOrder : TOrder) ;
var
  aQuote : TQuote;
  I, iRes: Integer;
  stData, stSufix : string;
begin

  stSufix := Format('???? : %s %s %.2f, %d, %d,(%d)', [
      aOrder.Symbol.ShortCode, ifThenStr( aOrder.Side > 0,'????','????'),
      aOrder.Price, aOrder.OrderQty, aOrder.OrderNo, integer( aORder.OrderSpecies) ]);

  if aOrder.Symbol.Quote = nil then Exit;
  aQuote  := aOrder.Symbol.Quote as TQuote;

  if aOrder.OrderSpecies = opPave then
  begin
    if ( aOrder.GroupNo = 'F') and ( aOrder.PrevOrderType = otChange ) then
      LiqOrders.OrdAdd( aOrder );
    ////////////////////////////////// ///////////////////////////////////////////////////////////////////////
    ///  ???? ????

    if aOrder.Side > 0 then
      for I := 0 to aQuote.Bids.Size - 1 do
      begin
        iRes := ComparePrice( 2, aOrder.Price, aQuote.Bids[i].Price );
        if iRes = 0 then
        begin
          stSufix := stSufix + Format(' %d ???? ???? %d', [ i+1, aQuote.Bids[i].Volume  ]);
          break;
        end;
      end;

    if aOrder.Side < 0 then
      for I := 0 to aQuote.Asks.Size - 1 do
      begin
        iRes := ComparePrice( 2, aOrder.Price, aQuote.Asks[i].Price );
        if iRes = 0 then
        begin
          stSufix := stSufix + Format(' %d ???? ???? %d', [ i+1, aQuote.Bids[i].Volume  ]);
          break;
        end;
      end;

    DoLayLog( stSufix );
    ///  End ???? ????
    ////////////////////////////////// ///////////////////////////////////////////////////////////////////////
  end
  else if aOrder.OrderSpecies = opNormal then
    LayOrders.OrdAdd( aOrder );
    // ???? ???? ?????? ???? ???????? ???? ?????? ????.

  DoRealLog( '???? : ' + stSufix + Format(' [ %d,%d | %d,%d ] ', [
    aQuote.Asks.CntTotal, aQuote.Asks.VolumeTotal, aQuote.Bids.VolumeTotal, aQuote.Bids.CntTotal ]));
end;

// ???? ?????? ???? ?????? ???????? osActvie ?? ?????? ????..
procedure TLayOrder.OnModified( aOrder : TOrder) ;
begin
  // ??..?????? ???????? ????
end;

// ???????? ????,  ???? or ???? ????
procedure TLayOrder.OnRejected( aOrder : TOrder) ;
begin

  DoLayLog( Format('Rejected --> %s, %s, %.2f, %d, %d', [
    aOrder.GroupNo, ifThenStr( aOrder.Side > 0, 'L', 'S'), aOrder.Price,
    aOrder.OrderQty, aOrder.OrderNo ] ));
end;


procedure TLayOrder.OnTimer(Sender: TObject);
var
  dtNow, dtComp , dtComp2, dPrice : TDateTime;
begin
  //
  dtNow  := Frac( GetQuoteTime );
  dtComp := EncodeTime( FParam.CnlHour, 58, 0, 0 );
  dtComp2:= EncodeTime( FParam.CnlHour, 58, 58, 0 );

  if ( dtNow > dtComp ) and ( dtNow < dtComp2 ) then
  begin
    dPrice  := TicksFromPrice( FSymbol, FSymbol.ExpectPrice, -FParam.CnlTick ) ;
    DoCancels( 1, dPrice );
  end;

end;

procedure TLayOrder.OnFilled( aOrder : TOrder ) ;
var
  dPrice : double;
  aResult : TOrderResult;
  pOrder  : TOrder;
  aTicket : TOrderTicket;
  stSufix, stData : string;
  aQuote  : TQuote;
  I, idx: Integer;
begin

  aResult := aOrder.GetLastResult( orFilled );
  if aResult = nil then Exit;

  stSufix := Format('???? : %s %s %.2f, %d, %d, (%d)', [
     aOrder.Symbol.ShortCode, ifThenStr( aOrder.Side > 0,'????','????'),
      aResult.Price, aResult.Qty, aOrder.OrderNo, integer( aORder.OrderSpecies) ]);

  if aOrder.GroupNo = 'P' then
  begin
    if aOrder.Side > 0 then
      dPrice  := TicksFromPrice( aOrder.Symbol, aResult.Price, 1 )
    else
      dPrice  := TicksFromPrice( aOrder.Symbol, aResult.Price, -1 );

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
    pOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID, aOrder.Account,
      aOrder.Symbol, -aResult.Qty, pcLimit, dPrice, tmGTC, aTicket );

    if pOrder <> nil then
    begin
      gEnv.Engine.TradeBroker.Send( aTicket );
      pOrder.OrderSpecies := opPave;
      pOrder.GroupNo      := 'F';
      LiqOrders.OrdAdd( pOrder);

      DoLayLog( Format('???? ???? %s --> ???????? %s, %.2f, %d', [  stSufix,
        ifThenStr( pOrder.Side > 0, 'L','S'), pOrder.Price, pOrder.OrderQty]));
    end;


    // ???? ???????? ????.
    // ??????????
  end else
  if aOrder.GroupNo = 'F' then
  begin
    DoLayLog( Format('???????? %s', [ stSufix ]));
  end;

  //if aOrder.OrderSpecies = opPave then
  //begin
    try

      if aOrder.GroupNo = 'P' then
      begin
        aQuote  := aORder.Symbol.Quote as TQuote;
        if aQuote = nil then Exit;
        idx := -1;

        if aOrder.Side > 0 then
        begin
          for I := 0 to aQuote.Bids.Size - 1 do
            if (aQuote.Bids[i].Price < (aOrder.Price - PRICE_EPSILON) ) then
            begin
              idx := i - 1;
              if idx < 0 then
                idx := 0;
              Break;
            end;
          if idx >= 0 then
            DoRealLog( stSufix + Format(' %d ???? %.2f [%d,%d] [ %d,%d | %d,%d ] ', [
              idx+1,  aQuote.Bids[idx].Price, aQuote.Bids[idx].Volume, aQuote.Bids[idx].Cnt,
              aQuote.Asks.CntTotal, aQuote.Asks.VolumeTotal, aQuote.Bids.VolumeTotal, aQuote.Bids.CntTotal ]))
          else
            DoRealLog( stSufix + Format('  [ %d,%d | %d,%d ] ', [
              aQuote.Asks.CntTotal, aQuote.Asks.VolumeTotal, aQuote.Bids.VolumeTotal, aQuote.Bids.CntTotal ]));
        end else
        if aOrder.Side < 0 then
        begin

        end;
      end else  ///   if aOrder.GroupNo = 'P' then
      begin
        aQuote  := aORder.Symbol.Quote as TQuote;
        if aQuote = nil then Exit;
            DoRealLog( stSufix + Format('  [ %d,%d | %d,%d ] ', [
              aQuote.Asks.CntTotal, aQuote.Asks.VolumeTotal, aQuote.Bids.VolumeTotal, aQuote.Bids.CntTotal ]));
      end;
      ///

    except
    end;
  //end;
end;

end.
