unit CleAutoStopOrders;

interface

uses
  Classes, SysUtils,

  CleAccounts, CleOrders, CleSymbols, ClePositions,

  CleQuoteBroker, CleFills,

  CleStopOrders,

  GleTypes

  ;

type

  TNewAutoStopOrderEvent =  function( Sender : TObject; dPrice : double; iQty , iSide, iTick: integer ) : TStopOrderItem of Object;

  TAutoStopOrder = class( TCollectionItem )
  private
    FUseLos: boolean;

    FUsePrf: boolean;
    FPrfTick: integer;
    FLosTick: integer;
    FPosition: TPosition;
    FStopOrder: TStopOrder;
    FOrdTick: integer;
    FUseMarket: boolean;
    FNewAutoStopOrderEvent: TNewAutoStopOrderEvent;
    FPrfStop: TStopOrderItem;
    FLosStop: TStopOrderItem;

    procedure SetPosition(const Value: TPosition);
    procedure DoStopOrder(aOrder: TOrder);
    procedure DoEachStopOrder(aOrder: TOrder);
  public
    Constructor Create( aColl : TCollection ); override;
    //Destructor  Destroy; override;

    procedure OnFill( aOrder : TOrder );
    procedure OnQuote( aQuote: TQuote );
    procedure OnStop( aStop : TStopOrderITem );

    procedure SetParam(  bAvg, bPrf, bLos, bMarket : boolean;  iPrf, iLos, iTick : integer );


    property Position : TPosition read FPosition write SetPosition;
    property StopOrder: TStopOrder read FStopOrder write FStopOrder;


    property UsePrf : boolean read FUsePrf;
    property UseLos : boolean read FUseLos;
    property PrfTick: integer read FPrfTick;
    property LosTick: integer read FLosTick;

    property UseMarket : boolean read FUseMarket;
    property OrdTick   : integer read FOrdTick;

    property PrfStop : TStopOrderItem read FPrfStop;
    property LosStop : TStopOrderItem read FLosStop;

    property NewAutoStopOrderEvent : TNewAutoStopOrderEvent read FNewAutoStopOrderEvent write FNewAutoStopOrderEvent;
  end;
                         {
  TAutoStopOrders = class( TCollection )
  private
    FOnStopOrderEvent: TStopOrderEvent;
    function GetStopOrder(i: integer): TStopOrder;
  public
    Constructor Create ;
    Destructor  Destroy; override;
    function New( aAccount : TAccount ; aSymbol : TSymbol ) : TAutoStopOrder;
    function Find(  aAccount : TAccount ; aSymbol : TSymbol ) : TAutoStopOrder;

    procedure DoQuote( aQuote : TQuote );

    property StopOrder[ i : integer] : TStopOrder read GetStopOrder;
  end;
            }
implementation

uses
  GAppEnv, GleLib, GleConsts, CleKrxSymbols
  ;

{ TAutoStopOrders }

constructor TAutoStopOrder.Create;
begin
  inherited Create( aColl );

  FPrfStop := nil;
  FLosStop := nil;

  FUseLos := false;
  FUsePrf := false;
  FPrfTick:=5;
  FLosTick:=5;
end;


procedure TAutoStopOrder.OnFill(aOrder: TOrder);
begin

  if ( not FUseLos ) and ( not FUsePrf ) then Exit;

  if FPosition = nil then
    FPosition := gEnv.Engine.TradeCore.Positions.Find( aOrder.Account, aOrder.Symbol )
  else if ( FPosition.Symbol <> aOrder.Symbol ) or
          ( FPosition.Account <> aOrder.Account) then
          Exit;
  // ???? 0
  if ( FPosition = nil ) or ( FPosition.Volume = 0 ) or ( FStopOrder = nil ) then Exit;
  // ???? ????
  if (( FPosition.Volume > 0 ) and ( aOrder.Side < 0 )) or
     (( FPosition.Volume < 0 ) and ( aOrder.Side > 0 )) then Exit;

  if ( FStopOrder.Account <> aOrder.Account ) or ( FStopOrder.Symbol <> aOrder.Symbol ) then
  begin
    gEnv.EnvLog( WIN_TEST, Format('object is error %s <> %s,  %s <> %s', [
     FStopOrder.Account.Code, aOrder.Account.Code, FStopOrder.Symbol.ShortCode , aOrder.Symbol.ShortCode])    );
    Exit;
  end;

  DoStopOrder( aOrder );

end;

procedure TAutoStopOrder.OnQuote(aQuote: TQuote);
begin

end;

procedure TAutoStopOrder.OnStop(aStop: TStopOrderITem);
begin
  if PrfStop = aStop then
    FPrfStop := nil;

  if FLosStop = aStop then
    FLosStop := nil;
end;

procedure TAutoStopOrder.SetParam(bAvg, bPrf, bLos, bMarket : boolean;
                                   iPrf, iLos, iTick : integer);
begin
  FUsePrf     := bPrf;
  FUseLos     := bLos;
  FPrfTick    := iPrf;
  FLosTick    := iLos;

  FUseMarket  := bMarket;
  FOrdTick    := iTick;
end;

procedure TAutoStopOrder.SetPosition(const Value: TPosition);
begin
  FPosition := Value;
end;

const
EPSILON = 1.0e-10;

procedure TAutoStopOrder.DoStopOrder( aOrder : TOrder );
var
  aFill : TFill;
  iIncQty, iQty  : integer;
  dAvgPrc, dPrfPrc, dLosPrc: double;
  iSide : integer;
  stSrc, StDec : string;
  aStop : TStopOrderItem;
begin

  aFill := TFill( aOrder.Fills.Last );

  iQty  := abs( aFill.Volume );
  iIncQty := 0;

  dAvgPrc := Round( FPosition.AvgPrice / aOrder.Symbol.Spec.TickSize + EPSILON) *
                  aOrder.Symbol.Spec.TickSize;

  if FPosition.Volume > 0 then begin
    dLosPrc := dAvgPrc  - ( aOrder.Symbol.Spec.TickSize * FLosTick );
    dPrfPrc := dAvgPrc  + ( aOrder.Symbol.Spec.TickSize * FPrfTick );
    iSide  := -1;
  end
  else begin
    dPrfPrc := dAvgPrc  - ( aOrder.Symbol.Spec.TickSize * FPrfTick );
    dLosPrc := dAvgPrc  + ( aOrder.Symbol.Spec.TickSize * FLosTick );
    iSide  := 1;
  end;

  // ????...
  if FUsePrf then
  begin
    if (FPrfStop <> nil ) and ( FPrfStop.Side = iSide ) then begin
      iIncQty := FPrfStop.OrdQty;
      FStopOrder.Cancel( FPrfStop );
      FPrfStop := nil;
    end
    else
      iIncQty := 0;

    iQty  := abs( aFill.Volume ) + iIncQty;
    if iQty > abs( FPosition.Volume ) then
      iQty :=  abs( FPosition.Volume );

    aStop := nil;
    if Assigned( FNewAutoStopOrderEvent ) then
      aStop := FNewAutoStopOrderEvent( Self, dPrfPrc, iQty, iSide, FOrdTick );
    if aStop = nil then Exit;

    if FUseMarket then
      aStop.pcValue := pcMarket
    else
      aStop.pcValue := pcLimit;

    aStop.GroupID := aFill.FillNo;
    FPrfStop := aStop;
  end;

  // ????...
  if FUseLos then
  begin
    if ( FLosStop <> nil ) and ( FLosStop.Side = iSide ) then begin
      iIncQty := FLosStop.OrdQty;
      FStopOrder.Cancel( FLosStop );
      FLosStop := nil;
    end
    else
      iIncQty := 0;

    iQty  := abs( aFill.Volume ) + iIncQty;
    if iQty > abs( FPosition.Volume ) then
      iQty :=  abs( FPosition.Volume );

    aStop := nil;
    if Assigned( FNewAutoStopOrderEvent ) then
      aStop := FNewAutoStopOrderEvent( Self, dLosPrc, iQty, iSide, FOrdTick );
    if aStop = nil then Exit;

    if FUseMarket then
      aStop.pcValue := pcMarket
    else
      aStop.pcValue := pcLimit;

    aStop.GroupID := aFill.FillNo;
    FLosStop := aStop;
  end;

end;

procedure TAutoStopOrder.DoEachStopOrder( aOrder : TOrder );
begin

end;

end.
