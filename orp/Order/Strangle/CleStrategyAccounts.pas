unit CleStrategyAccounts;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleAccounts, ClePositions, CleOrders, CleQuotebroker,

  CleStrategyStore,

  GleTypes

  ;

type

  TStrangleAccount = class( TStrategyBase )
  private
    FNo: integer;
    FOnQuote: TNotifyEvent;
    FMulti: integer;

    function GetPosition(aSymbol : TSymbol): TPosition;
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies ;
          stType : TStrategyType; bMonth : boolean);
    destructor Destroy; override;

    procedure init( aAcnt : TAccount; iNo : integer );
    procedure AddSymbol( aSymbol : TSymbol );
    function DoOrder( aSymbol : TSymbol;  iQty, iSide : integer ) : TOrder;

    property Position[ aSymbol : TSymbol] : TPosition read GetPosition;
    property No : integer read FNo;
    property Multi : integer read FMulti write FMulti;
    property OnQuote : TNotifyEvent read FOnQuote write FOnQuote;
  end;

  TAccountofFund = class( TCollectionItem )
  private
    FMulti: integer;
    FAccount: TAccount;
  public
    Constructor Create; overload;
    procedure SetItem( aAcnt : TAccount; iMulti : integer = 1 );
    property Multi : integer read FMulti write FMulti;
    property Account : TAccount read FAccount;
  end;

implementation

uses
  GAppEnv, GleLib, CleFQN, CleKrxSymbols
  ;

{ TStrangleAccount }

procedure TStrangleAccount.AddSymbol(aSymbol: TSymbol);
begin

end;

constructor TStrangleAccount.Create(aColl: TCollection; opType: TOrderSpecies;
  stType : TStrategyType; bMonth : boolean);
begin
  inherited Create( aColl, opType, stType, bMonth );
  FMulti  := 1;
end;

destructor TStrangleAccount.Destroy;
begin

  inherited;
end;

function TStrangleAccount.DoOrder(aSymbol: TSymbol; iQty,
  iSide: integer): TOrder;
var
  aQuote  : TQuote;
  aTicket : TOrderTicket;

  dPrice  : double;
  stErr   : string;
begin
  Result := nil;
  if aSymbol.Quote = nil then Exit;
  aQuote  := aSymbol.Quote as TQuote;

  AddPosition( aSymbol );

  if iSide > 0 then
    dPrice  := TicksFromPrice( aSymbol, aQuote.Bids[0].Price, 5 )
  else
    dPrice  := TicksFromPrice( aSymbol, aQuote.Asks[0].Price, -5 );

  // ?????????? ????..
  iQty := iQty * FMulti;

  if ( not CheckPrice( aSymbol, Format('%.*f', [aSymbol.Spec.Precision,  dPrice] ),  stErr )) or
     ( iQty <= 0 ) then
  begin
    if Assigned( OnText ) then
      OnText( Format(' ???? ???? ???? : %s, %s, %s, %d, %.2f ',  [ stErr,
        Account.Code,  aSymbol.ShortCode, iQty, dPrice ]) , No );
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, aSymbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if Result <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    Result.OrderSpecies := OrderType;
  end;

end;

function TStrangleAccount.GetPosition(aSymbol : TSymbol): TPosition;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Positions.Count - 1 do
    if Positions.Positions[i].Symbol = aSymbol then
    begin
      Result := Positions.Positions[i];
      break;
    end;
end;

procedure TStrangleAccount.init(aAcnt: TAccount; iNo : integer);
begin
  Account := aAcnt;
  FNo     := iNo;
end;

procedure TStrangleAccount.QuoteProc(aQuote: TQuote; iDataID: integer);
begin
  if FNo <> 0 then Exit;
  if aQuote.LastEvent = qtTimeNSale then
    if Assigned( FOnQuote ) then
      FOnQuote( aQuote );

end;

procedure TStrangleAccount.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
begin

end;

{ TAccountofFun }

constructor TAccountofFund.Create;
begin
  inherited Create( nil );
  FMulti := 1;
  FAccount := nil;
end;

procedure TAccountofFund.SetItem(aAcnt: TAccount; iMulti: integer);
begin
  FAccount := aAcnt;
  FMulti   := iMulti;
end;

end.
