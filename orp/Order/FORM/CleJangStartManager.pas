unit CleJangStartManager;

interface

uses
  Classes, SysUtils,

  CleFrontOrderIF, CleQuoteBroker, CleSymbols, CleOrders,
  CleDistributor, CleQuoteTimers, CleKrxSymbols,

  GleLib, GleTypes, GleConsts

  ;

type

  TJangStartManager = class( TFrontOrderIF )
  private
    FQuote  : TQuote;
    QuoteTime : TDateTime;
    FTimer  : TQuoteTimer;
    FRun    : boolean;
    procedure DoOrder; overload;
    procedure DoOrder( dPrice : double; iSeq, iQty , iSide : integer ); overload;
    procedure DoCancel(aOrder: TOrder);
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function Start : boolean; virtual;
    procedure Stop; virtual;
    procedure Reset; virtual;
    procedure Observer; virtual;

    procedure Run;

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure DoTimer(Sender: TObject);
  end;

implementation

uses
  GAppEnv, CleFormManager;


{ TJangBeforeManager }

constructor TJangStartManager.Create(aColl: TCollection);
begin
  inherited;
  FQuote  := nil;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;

  FTimer.Interval := 100;
  FTimer.OnTimer  := DoTimer;
  FTimer.Enabled  := false;

  FRun  := false;
end;

destructor TJangStartManager.Destroy;
begin
  FTimer.Enabled := false;
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FTimer.Free;
  inherited;
end;

procedure TJangStartManager.DoTimer(Sender: TObject);
begin
  Run;
  if FRun then
    Notify( Self, false );
end;

//Constrols---------------------------------------------------------------------

procedure TJangStartManager.Observer;
var
  i, iSu, iA, iB : integer;
  aOrder : TOrder;
  AskPrice, BidPrice : double;
  BidList, AskList   : TList;
  aExt, bExt : boolean;
begin

  if (FQuote.Asks[0].Price < PRICE_EPSILON) or
     (FQuote.Bids[0].Price < PRICE_EPSILON) then
     Exit;

  AskPrice  := Param.AskShift2 + FQuote.Asks[0].Price;
  BidPrice  := FQuote.Bids[0].Price - Param.BidShift2;

  try

    if SelectedItem = nil then Exit;

    BidList := TList.Create;
    AskList := TList.Create;

    iA := 0; iB := 0; i:=0;
    iSu:= SelectedItem.AskOrders.Count  + SelectedItem.BidOrders.Count ;
    aExt := false;  bExt := false;

    try
      while i < iSu do
      begin
        if aExt and bExt then break;

        if iA < SelectedItem.AskOrders.Count then
        begin
          aOrder  := TOrder( SelectedItem.AskOrders.Items[iA]);
          if (aOrder.Price  < AskPrice + PRICE_EPSILON) and
            ( not aOrder.Modify ) and
            ( aOrder.OrderType = otNormal )  then begin
            AskList.Add( aOrder );
            inc( iA );
          end
          else aExt := true;
        end
        else aExt := true;

        if iB < SelectedItem.BidOrders.Count then
        begin
          aOrder  := TOrder( SelectedItem.BidOrders.Items[iB]);
          if (aOrder.Price + PRICE_EPSILON > BidPrice) and
            ( not aOrder.Modify )  and
            ( aOrder.OrderType = otNormal ) then begin
            BidList.Add( aOrder );
            inc( iB );
          end
          else bExt := true;
        end
        else bExt := true;

        inc( i );
      end;


      if AskList.Count > BidList.Count then
        iSu := AskList.Count-1
      else
        iSu := BidList.Count -1;

      if iSu >= 0 then
      begin
        for i := 0 to iSu do begin
          if i < AskList.Count then begin
            aOrder  := TOrder( AskList.Items[i] );
            if aOrder <> nil then
              DoCancel( aOrder );
          end;

          if i < BidList.Count then begin
            aOrder  := TOrder( BidList.Items[i] );
            if aOrder <> nil then
              DoCancel( aOrder );
          end;
        end;
      end;

    except
      gLog.Add( lkError, 'TJangStartManager', 'Observer', '');
    end;

  finally
    AskList.Free;
    BidList.Free;
  end;
end;

procedure TJangStartManager.QuoteProc(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aQuote : TQuote;
begin
  if (Receiver <> Self) or (DataObj = nil) then Exit;

  aQuote := DataObj as TQuote;
  if aQuote <> FQuote then Exit;

  Run;
end;

procedure TJangStartManager.Reset;
begin

end;

procedure TJangStartManager.Run;
var
  stQuote, stParam, stLog : string;
  iRes : integer;
begin
  if (FQuote = nil) or
    ( Account = nil ) then
    begin
     //EnvLog(' ∞Ë¡¬ or ¡æ∏Ò º≥¡§¿Ã æ»µ  ');
     //Notify( Self, false );
     Exit;
    end;

  stQuote := FormatDateTime('hhnnsszzz', FQuote.LastEventTime );
  stParam := FormatDateTime('hhnnsszzz', Param.StartTime );

  iRes  := CompareStr( stQuote, stParam  );

  if (FQuote.Asks[0].Price < PRICE_EPSILON) or
     (FQuote.Bids[0].Price < PRICE_EPSILON) then
     Exit;

  if (iRes >= 0) and ( not FRun) then
  begin
    FRun  := true;
    stLog := Format('StartTime : %s', [stQuote]);
    EnvLog( stLog );
    DoOrder;
    //Notify( Self, false );
  end;
end;


procedure TJangStartManager.DoOrder;
var
  AskPrice, BidPrice,
  LimitAskPrice, LimitBidPrice : double;
  i : integer;
begin
  Observer;

  AskPrice  := Param.AskShift2 + FQuote.Asks[0].Price;
  BidPrice  := FQuote.Bids[0].Price - Param.BidShift2;

  EnvLog( Format('AskPrice : %.2f  , BidPrice : %.2f',
    [ AskPrice, BidPrice ])
    );

  if SelectedItem = nil then Exit;

  {
  if SelectedItem.AskOrders.Count > 0 then
    LimitAskPrice := TOrder( SelectedItem.AskOrders.Items[0] ).Price
  else
  }
    LimitAskPrice := FQuote.Symbol.LimitHigh;

  {
  if SelectedItem.BidOrders.Count > 0 then
    LimitBidPrice := TOrder( SelectedItem.BidOrders.Items[0] ).Price
  else
  }
    LimitBidPrice := FQuote.Symbol.LimitLow;

  EnvLog( Format('LimitAskPrice : %.2f  , LimitBidPrice : %.2f',
    [ LimitAskPrice, LimitBidPrice ])
    );

  if LimitAskPrice > AskPrice + PRICE_EPSILON then
    DoOrder( AskPrice, 1, Param.OrderQty, -1 );

  if LimitBidPrice + PRICE_EPSILON < BidPrice  then
    DoOrder( BidPrice, 1, Param.OrderQty, 1 );

  for i := 1 to Param.OrderCnt - 1 do
  begin
    AskPrice := TicksFromPrice( Symbol, AskPrice, Param.OrderGap );
    BidPrice := TicksFromPrice( Symbol, BidPrice, Param.OrderGap * -1 );

    if LimitAskPrice > AskPrice + PRICE_EPSILON then
      if not SelectedItem.FindAskOrder( AskPrice ) then
        DoOrder( AskPrice, i+1, Param.OrderQty, -1 )
      else
        EnvLog( Format('Duplic AskOrd : %.2f , %d',
        [ AskPrice, Param.OrderQty ])
        );

    if LimitBidPrice + PRICE_EPSILON < BidPrice  then
      if not SelectedItem.FindBidOrder( BidPrice ) then
        DoOrder( BidPrice, i+1, Param.OrderQty, 1 )
      else
        EnvLog( Format('Duplic BidOrd : %.2f , %d',
        [ BidPrice, Param.OrderQty ])
        );
  end;

  EnvLog( Format('AskPrice : %.2f  , BidPrice : %.2f',
    [ AskPrice, BidPrice ])
    );

end;





procedure TJangStartManager.DoOrder( dPrice : double; iSeq, iQty , iSide : integer );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
begin
  // check..
  if iSide > 0 then
  begin
    if dPrice + PRICE_EPSILON > FQuote.Bids[0].Price then
      Exit;
  end
  else begin
    if dPrice < FQuote.Asks[0].Price + PRICE_EPSILON then
      Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, Account, Symbol,
                iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'Send Order(%d th) : %s, %.2f, %d ',
      [
        iSeq,
        ifThenStr( iSide > 0 , 'L', 'S'),
        dPrice,
        iQty
      ]
      );
    EnvLog( stLog );
  end;

end;


procedure TJangStartManager.DoCancel( aOrder : TOrder );
var
  aTicket : TOrderTicket;
  pOrder  : TOrder;
  stLog   : string;
begin

  if aOrder.ActiveQty <= 0 then Exit;

  if aOrder.Modify then Exit;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder(
    aOrder, aOrder.ActiveQty, aTicket );

  if pOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket );
    stLog := Format( 'Cancel Order : %s, %.2f, %d, %d ',
      [
        ifThenStr( pOrder.Side > 0 , 'L', 'S'),
        aOrder.Price,
        aOrder.ActiveQty,
        aOrder.OrderNo
      ]
      );
    EnvLog( stLog );
  end ;
end;

function TJangStartManager.Start : boolean;
begin

  Result := false;

  if Symbol <> nil then
    FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, Symbol, QuoteProc );

  if (FQuote = nil) or
    ( Account = nil ) then
    begin
     EnvLog(' ∞Ë¡¬ or ¡æ∏Ò º≥¡§¿Ã æ»µ  ');
     //Notify( Self, false );
     Exit;
    end;

  FTimer.Enabled := true;
  Result := true;
end;

procedure TJangStartManager.Stop;
begin
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FQuote  := nil;
  FRun    := false;
  FTimer.Enabled := false;
end;
//---------------------------------------------------------------------Constrols

end.

