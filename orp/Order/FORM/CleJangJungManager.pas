unit CleJangJungManager;

interface

uses
  Classes, SysUtils,

  CleFrontOrderIF, CleQuoteBroker, CleSymbols, CleOrders,
  CleDistributor, CleQuoteTimers, CleKrxSymbols,

  GleLib, GleTypes, GleConsts

  ;

type

  TJangJungManager = class( TFrontOrderIF )
  private
    FQuote  : TQuote;
    QuoteTime : TDateTime;
    FRun    : boolean;
    FCheck  : boolean;
    FTimer  : TQuoteTimer;
    procedure DoCancel( aOrder : TOrder );
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function Start : boolean; virtual;
    procedure Stop; virtual;
    procedure Reset; virtual;
    procedure Observer; virtual;

    procedure DoTimer(Sender: TObject);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

  end;

implementation

uses
  GAppEnv, CleAccounts;

{ TJangJungManager }

constructor TJangJungManager.Create(aColl: TCollection);
begin
  inherited;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;

  FTimer.Interval := 100;
  FTimer.OnTimer  := DoTimer;
  FTimer.Enabled  := false;

  FQuote  := nil;
  FRun    := false;
  FCheck  := false;
end;

destructor TJangJungManager.Destroy;
begin
  
  FTimer.Enabled := false;
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FTimer.Free;
  inherited;
end;      


procedure TJangJungManager.DoCancel( aOrder : TOrder );
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


procedure TJangJungManager.DoTimer(Sender: TObject);
begin
  if ( FQuote = nil) or ( Account = nil ) then Exit;
  Observer;

end;

procedure TJangJungManager.Observer;
var
  iAsks, iBids, i, iSu, iA, iB : integer;
  aOrder : TOrder;
  AskPrice, BidPrice : double;
  BidList, AskList   : TList;
  aExt, bExt : boolean;

begin

  if FCheck then Exit;
  FCheck  := true;

  if (FQuote.Asks[0].Price < PRICE_EPSILON) or
     (FQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    FCheck := false;
    Exit;
  end;

  if ManagerType = ottJangJung2 then
  begin
    AskPrice  := Param.AskShift + FQuote.Asks[0].Price;
    BidPrice  := FQuote.Bids[0].Price - Param.BidShift;
  end
  else begin

    iAsks := Param.Asks;
    iBids := Param.Bids;

    if (iAsks >=1) and (iAsks <= 5) then
      AskPrice  := FQuote.Asks[iAsks-1].Price
    else if iAsks <= 0 then
      Exit
    else
      AskPrice  := TicksFromPrice( FQuote.Symbol, FQuote.Asks[0].Price, iAsks -1 );

    if (iBids >=1) and (iBids <= 5) then
      BidPrice  := FQuote.Bids[iBids-1].Price
    else if iBids <= 0 then
      Exit
    else
      BidPrice  := TicksFromPrice( FQuote.Symbol, FQuote.Bids[0].Price, -( iBids-1) );
  end;

  try

    if SelectedItem = nil then Exit;

    BidList := TList.Create;
    AskList := TList.Create;

    iA := 0; iB := 0; i:=0;
    iSu:= SelectedItem.AskOrders.Count + SelectedItem.BidOrders.Count ;
    aExt := false;  bExt := false;

    while i < iSu do
    begin
      if aExt and bExt then break;

      if iA < SelectedItem.AskOrders.Count then
      begin
        aOrder  := TOrder( SelectedItem.AskOrders.Items[iA]);
        if (aOrder.Price  < AskPrice + PRICE_EPSILON) and
          ( not aOrder.Modify ) and
          ( aOrder.OrderType = otNormal )  then
        begin
          if (aOrder.Symbol = FQuote.Symbol) and ( Account = aOrder.Account ) then
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
          ( aOrder.OrderType = otNormal ) then
        begin
          if (aOrder.Symbol = FQuote.Symbol) and ( Account = aOrder.Account ) then
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
      {
      EnvLog( Format('AskPrice : %.2f  , BidPrice : %.2f',
        [ AskPrice, BidPrice ])
      );

      EnvLog( Format('AskCnt :%d(%d)  , BidCnt :%d(%d)',
      [
        AskList.Count, TFrontManager(Collection).AskOrders.Count,
        BidList.Count, TFrontManager(Collection).BidOrders.Count ])
      );
      }
    end;

  finally
    AskList.Free;
    BidList.Free;
  end;

  FCheck  := false;

end;

procedure TJangJungManager.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

  if Receiver <> Self then Exit;
  if DataObj = nil then Exit;

  if (DataObj as TQuote) <> FQuote then Exit;
  if Account = nil then Exit;

  Observer;

end;

procedure TJangJungManager.Reset;
begin

end;


function TJangJungManager.Start: boolean;
begin
  Result := false;

  if FRun  then
  begin
    EnvLog( '실행중 ');
    result := true;
    Exit;
  end;

  if (Symbol <> nil) and ( Account <> nil ) then
  begin
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, Symbol, QuoteProc );
    Result := true;
    FRun   := true;
    FTimer.Enabled  := true;
    EnvLog( '장중 주문관리 시작 ');
    Observer;
  end
  else
    EnvLog( '종목 or 계좌 선택 ');

end;

procedure TJangJungManager.Stop;
begin
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FQuote := nil;
  FRun   := false;
  FTimer.Enabled  := false;
  EnvLog( ' 중지 ');
end;

end.
