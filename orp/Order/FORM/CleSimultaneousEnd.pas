unit CleSimultaneousEnd;

interface

uses
  Classes, SysUtils,

  CleFrontOrderIF, CleQuoteBroker, CleSymbols, CleOrders,
  CleDistributor, CleQuoteTimers, CleKrxSymbols,

  GleLib, GleTypes, GleConsts
  ;
type

  TSimultaneousEnd = class( TFrontOrderIF )
  private
    FQuote  : TQuote;
    QuoteTime : TDateTime;
    FTimer  : TQuoteTimer;

    procedure DoOrder;
    procedure DoCancel(aOrder: TOrder);
  public
    FRun    : boolean;
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

constructor TSimultaneousEnd.Create(aColl: TCollection);
begin
  inherited;
  FQuote  := nil;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;

  FTimer.Interval := 100;
  FTimer.OnTimer  := DoTimer;
  FTimer.Enabled  := false;

  FRun  := false;
end;

destructor TSimultaneousEnd.Destroy;
begin
  FTimer.Enabled := false;
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FTimer.Free;
  inherited;
end;

procedure TSimultaneousEnd.DoTimer(Sender: TObject);
begin
  Run;
end;

//Constrols---------------------------------------------------------------------

procedure TSimultaneousEnd.Observer;
var
  i, iSu, iA, iB : integer;
  aOrder : TOrder;
  AskPrice, BidPrice : double;
  BidList, AskList   : TList;
  aExt, bExt : boolean;

begin

  AskPrice  := Param.IndexPrice + Param.Upper ;//Param.AskShift + FQuote.Asks[0].Price;
  BidPrice  := Param.IndexPrice - Param.Lower ;//FQuote.Bids[0].Price - Param.BidShift;

  try

    BidList := TList.Create;
    AskList := TList.Create;

    iA := 0; iB := 0; i:=0;

    if SelectedItem = nil then Exit;

    iSu:= (SelectedItem.AskOrders.Count -1) + (SelectedItem.BidOrders.Count -1);
    aExt := false;  bExt := false;

    while i <= iSu do
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

  finally
    AskList.Free;
    BidList.Free;
  end;
end;

procedure TSimultaneousEnd.QuoteProc(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
{
  if (Receiver <> Self) or (DataObj = nil) then Exit;

  aQuote := DataObj as TQuote;
  if aQuote <> FQuote then Exit;

  Run;
  }
end;

procedure TSimultaneousEnd.Reset;
begin

end;

procedure TSimultaneousEnd.Run;
var
  stQuote, stParam, stParam2, stLog : string;
  iRes : integer;
begin
  if (FQuote = nil) or
    ( Account = nil ) then
    begin
     EnvLog(' ∞Ë¡¬ or ¡æ∏Ò º≥¡§¿Ã æ»µ  ');
     Notify( Self, false );
     Exit;
    end;

  stQuote := FormatDateTime('hhnnsszzz', GetQuoteTime );
  stParam := FormatDateTime('hhnnsszzz', Param.CancelTime );

  iRes  := CompareStr( stQuote, stParam  );

  if (iRes >= 0) and ( not FRun ) then
  begin

    FRun := true;

    stQuote := FormatDateTime('hhnnsszzz', GetQuoteTime );
    stParam := '090000000';//FormatDateTime('hhnnsszzz', Param.StartTime );

    iRes := CompareStr( stQuote, stParam  );

    if iRes >= 0 then
    begin
      Notify( Self, false );
      stLog := Format('Stop : %s ', [ FormatDateTime( 'hh:nn:ss.zzz', GetQuoteTime )]);
      EnvLog( stLog );
      Exit;
    end;

    DoOrder;
  end;


  stQuote := FormatDateTime('hhnnsszzz', GetQuoteTime );
  stParam := FormatDateTime('hhnnsszzz', Param.StartTime );

  iRes := CompareStr( stQuote, stParam  );

  if iRes >= 0 then
  begin
    Notify( Self, false );
    stLog := Format('Stop : %s ', [ FormatDateTime( 'hh:nn:ss.zzz', GetQuoteTime )]);
    EnvLog( stLog );
  end;
 
end;


procedure TSimultaneousEnd.DoOrder;
var
  AskPrice, BidPrice,
  LimitAskPrice, LimitBidPrice : double;
  i : integer;
begin
  Observer;
end;


procedure TSimultaneousEnd.DoCancel( aOrder : TOrder );
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

function TSimultaneousEnd.Start : boolean;
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

  EnvLog( Format('StartTime : %s', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime)]) );
end;

procedure TSimultaneousEnd.Stop;
begin
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FQuote  := nil;
  FRun    := false;
  FTimer.Enabled := false;
  EnvLog( Format('StopTime : %s', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime)]) );
end;
//---------------------------------------------------------------------Constrols

end.

