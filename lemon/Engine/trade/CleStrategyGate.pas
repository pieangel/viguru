unit CleStrategyGate;

interface

uses
  Classes,
  CleStrategyStore, GleTypes, CleAccounts, CleSymbols, CleFills, CleQuoteBroker,
  CleOrders
  ;

type
  TStrategyGate = class
  private
    FStore : TStrategyStore;
    function GetOrderSpecies( iType : integer ): TOrderSpecies;

    //TOrderSpecies
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdatePosition( aQuote : TQuote );
    procedure DoQuote(aQuote : TQuote; iDataID : integer);
    function DoOrder(aOrder : TOrder; iID : integer) : boolean;
    function DoFill( aFill : TFill; aOrder : TOrder) : boolean;
    function GetStrategys : TStrategys;
    function GetTicket( aBase : TStrategyBase ) : TOrderTicket;
    procedure Del( aBase : TStrategyBase);
    procedure Report;
    procedure Reset;
  end;

implementation

uses
  GAppEnv;

{ TStrategyGate }

function TStrategyGate.DoOrder(aOrder : TOrder; iID : integer): boolean;
begin
  Result := false;
  if aOrder.Ticket.StrategyType = stNormal then exit;
  Result := FStore.DoOrder(iID, aOrder);

end;

procedure TStrategyGate.DoQuote(aQuote: TQuote; iDataID: integer);
begin
  FStore.DoQuote(aQuote, iDataID);
end;

function TStrategyGate.DoFill(aFill : TFill;  aOrder : TOrder) : boolean;
begin
  Result := false;
  if aOrder.Ticket.StrategyType = stNormal then exit;

  FStore.DoFill(aOrder , aFill);
end;



constructor TStrategyGate.Create;
begin
  FStore := TStrategyStore.Create;
end;

procedure TStrategyGate.Del(aBase : TStrategyBase);
begin
  FStore.Del(aBase);
end;

destructor TStrategyGate.Destroy;
begin
  FStore.Free;
  inherited;
end;

function TStrategyGate.GetStrategys: TStrategys;
begin
  Result := FStore.GetStrategys;
end;

function TStrategyGate.GetTicket(aBase: TStrategyBase): TOrderTicket;
begin
  if aBase = nil then
    Result := nil
  else
    Result := gEnv.Engine.TradeCore.OrderTickets.New(Self, aBase.Number, aBase.StrategyType);
end;

procedure TStrategyGate.Report;
begin
  FStore.Report;  
end;

procedure TStrategyGate.Reset;
begin
  FStore.Strategys.Clear;
end;

function TStrategyGate.GetOrderSpecies(iType: integer): TOrderSpecies;
begin
  //TOrderSpecies = ( opNormal, opVolStop, opProtecte, opBull, opStrangle, opYH );
  Result := opNormal;
  if (iType < 0 )  or  ( integer(High(TOrderSpecies)) < itype) then
    Result := opNormal
  else
    Result := TOrderSpecies( iType );
{
  case iType of
    0 : Result := opNormal;
    1 : Result := opVolStop;
    2 : Result := opProtecte;
    3 : Result := opBull;
    4 : Result := opStrangle;
    5 : Result := opYH;
    6 : Result := opRatio;
    7 : Result := opStrangle2;
    8 : Result := opVolSpread;
  end;
  }
end;

procedure TStrategyGate.UpdatePosition(aQuote: TQuote);
begin
  FStore.UpdatePosition(aQuote);
end;

end.
