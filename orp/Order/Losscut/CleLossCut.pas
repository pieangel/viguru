unit CleLossCut;

interface

uses
  Classes, SysUtils,

  ClePositions, CleQuoteBroker, CleSymbols, CleDistributor,

  CleAccounts, CleOrders
  ;

type


  TLossCut  = class
  private
    FQuote: TQuote;
    FPosition: TPosition;
    FSymbol: TSymbol;
    FAccount: TAccount;
    procedure SetPosition(const Value: TPosition);
    procedure SetQuote(const Value: TQuote);
    procedure SetSymbol(const Value: TSymbol);
    procedure SetAccount(const Value: TAccount);
  public
    Constructor Create;
    Destructor Destroy;  override;

    property Position : TPosition read FPosition write SetPosition;
    property Quote    : TQuote  read  FQuote write SetQuote;
    property Symbol   : TSymbol read FSymbol write SetSymbol;
    property Account  : TAccount read FAccount write SetAccount;


    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure PositionPrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    //
    procedure Run; virtual; abstract;
    procedure Stop; virtual; abstract;
    //
    procedure CheckLossCut;  virtual;abstract;

    procedure DoQuote( aQuote : TQuote );  virtual;
    procedure DoPosition( aPosition : TPosition ); virtual;
    procedure DoOrder( aOrder : TOrder ); virtual;
  end;

implementation

uses
  GAppEnv, GleConsts;

{ TLossCut }

constructor TLossCut.Create;
begin
  FSymbol := nil;
  FQuote  := nil;
  FPosition := nil;
  gEnv.Engine.TradeBroker.Subscribe( Self, PositionPrc );
end;

destructor TLossCut.Destroy;
begin
  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

procedure TLossCut.DoOrder(aOrder: TOrder);
begin
end;

procedure TLossCut.DoPosition(aPosition: TPosition);
begin
end;

procedure TLossCut.DoQuote(aQuote: TQuote);
begin  
end;

procedure TLossCut.PositionPrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) or ( DataObj = nil )
    then Exit;

  case Integer(EventID) of
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CHANGED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,  
    ORDER_FILLED  : DoOrder( DataObj as TOrder );
      // position events

    POSITION_NEW,
    POSITION_UPDATE:  DoPosition(DataObj as TPosition);
  end;
end;

procedure TLossCut.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or ( DataObj = nil ) then Exit;
  DoQuote( DataObj as TQuote );
end;

procedure TLossCut.SetAccount(const Value: TAccount);
begin
  FAccount := Value;

  if (FAccount <> nil) and ( FSymbol <> nil ) then
    FPosition  := gEnv.Engine.TradeCore.Positions.Find( Account, Symbol );
end;

procedure TLossCut.SetPosition(const Value: TPosition);
begin
  if Value = nil then Exit;
  FPosition := Value;
end;

procedure TLossCut.SetQuote(const Value: TQuote);
begin
  FQuote := Value;
end;

procedure TLossCut.SetSymbol(const Value: TSymbol);
begin
  //if Value = nil then Exit;

  if FSymbol <> Value then
    if FSymbol <> nil then
    begin
      gEnv.Engine.QuoteBroker.Cancel( Self, FQuote.Symbol );
      FQuote  := nil;
    end;

  FSymbol := Value;
  if FSymbol <> nil then
    FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc )
  else
    FQuote := nil;

  if (FAccount <> nil) and ( FSymbol <> nil ) then
    FPosition  := gEnv.Engine.TradeCore.Positions.Find( Account, Symbol );
end;

end.
