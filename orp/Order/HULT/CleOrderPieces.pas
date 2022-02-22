unit CleOrderPieces;

interface

uses
  Classes, SysUtils,

  CleOrders, CleQuoteBroker, CleSymbols,

  GleLib, GleConsts, GleTypes

  ;

type

  //
  TOrderPiece = class( TCollectionItem )
  public
    FilledPrice : double;
    FilledIndex : integer;
    OrderIndex  : integer;
    OrderPrice   : double;
    Side        : integer;
    OrderQty    : integer;
    Constructor Create( aColl : TCollection ) ; override;
    function IsInHoga( iIndex : integer ) : boolean; overload;
    function IsInHoga( aQuote : TQuote ) : boolean; overload;
  end;

  TOrderPieces = class( TCollection )
  private
    function GetPiece(i: integer): TOrderPiece;

  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( iSide : integer;dPrice : double ) : TOrderPiece;
    property OrderPiece[ i : integer] : TOrderPiece read GetPiece;
  end;

implementation

uses
  GAppEnv
  ;

{ TOrderPiece }

constructor TOrderPiece.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  Side  := 0;
  OrderIndex  := -1;
  FilledPrice := 0;
  FilledIndex := -1;
  OrderPrice  := 0;
end;

function TOrderPiece.IsInHoga(iIndex : integer): boolean;
begin
  Result := false;

  if Side > 0 then
  begin
    if  iIndex > OrderIndex then
      Result := true;
  end
  else if Side < 0 then
    if iIndex < OrderIndex then
      Result := true;
end;

function TOrderPiece.IsInHoga(aQuote: TQuote): boolean;
begin
  Result := false;

  if Side > 0 then
  begin
    if ( aQuote.Bids[0].Price > (OrderPrice + 0.01)) then
      Result := true;
  end
  else if Side < 0 then
    if ((aQuote.Asks[0].Price + 0.01 ) < OrderPrice) then
      Result := true;
end;

{ TOrderPieces }

constructor TOrderPieces.Create;
begin
  inherited Create( TOrderPiece )
end;

destructor TOrderPieces.Destroy;
begin
  inherited;
end;

function TOrderPieces.GetPiece(i: integer): TOrderPiece;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TOrderPiece;
end;

function TOrderPieces.New(iSide : integer; dPrice: double): TOrderPiece;
begin
  Result := Insert(0) as TOrderPiece;
  Result.FilledPrice  := dPrice;
  Result.Side := iSide * -1;


end;

end.
