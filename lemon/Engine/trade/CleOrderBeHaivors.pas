unit CleOrderBeHaivors;

interface

uses
  Classes,

  CleSymbols, CleAccounts, ClePositions , CleQuoteTimers, CleOrders

  ;

type
  TOrderBase = class( TCollectionItem )
  private
    FPosition: TPosition;
    FSymbol: TSymbol;
    FAccount: TAccount;
    FFlash: boolean;
    FNo: integer;
    FTimer: TQuoteTimer;
    FOrders: TOrderList;

  public
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    property No     : integer read FNo write FNo;
    property Flash  : boolean read FFlash write FFlash;
    property Position : TPosition read FPosition write FPosition;
    property Account : TAccount read FAccount write FAccount;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property Timer  : TQuoteTimer read FTimer write FTimer;
    property Orders : TOrderList  read FOrders write FOrders;

    //procedure DoLiquid; virtual; abstract;
    //procedure DoOrder; virtual; abstract;

  end;

implementation

{ TOrderBase }

constructor TOrderBase.Create(aColl: TCollection);
begin
  inherited;
  FPosition:= nil;
  FSymbol:=   nil;
  FAccount:=  nil;
  FFlash  :=  false;

  FTimer  := nil;
  FOrders := TOrderList.Create;
end;

destructor TOrderBase.Destroy;
begin
  FOrders.Free;
  inherited;
end;

end.
