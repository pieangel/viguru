unit CleBaseIF;

interface

uses
  Classes,

  CleSymbols, CleQuoteBroker, CleDistributor
  ;

type

  TBaseIF = class( TCollection )
  private

    function GetValue(i: integer): TCollectionItem;

  public
    Name  : string;
    procedure OnQuote( aQuote : TQuote );  virtual ; abstract;
    procedure OnTrade(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);  virtual ; abstract;

    constructor Create(aItemClass: TCollectionItemClass);
    destructor Destroy; override;

    property Value[ i : integer] : TCollectionItem read GetValue;
  end;


implementation

{ TBaseIF }



{ TBaseIF }

constructor TBaseIF.Create(aItemClass: TCollectionItemClass);
begin
  inherited Create(aItemClass);

end;

destructor TBaseIF.Destroy;
begin

  inherited;
end;

function TBaseIF.GetValue(i: integer): TCollectionItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TCollectionItem
  else
    Result := nil;
end;

end.
