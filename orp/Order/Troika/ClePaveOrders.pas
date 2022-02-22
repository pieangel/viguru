unit ClePaveOrders;

interface

uses
  Classes, SysUtils  ,Windows, Forms,

  CleSymbols, CleAccounts, CleQuoteBroker ,

  CleLayOrder, FmPaveOrder, ClePaveOrderType , CleOrders, ClePositions, CleQuoteTimers,

  CleDistributor, GleConsts , GleTypes
  ;

type


  TPaveOrderItem = class( TCollectionItem )
  private
    FAccount: TAccount;
    FSymbol: TSymbol;
    FDataObj: TObject;
    FDataID: integer;
    FLayOrder: TLayOrder;
    FRun: boolean;

    procedure OnEndEvent( Sender : TObject );
  public
    Constructor Create( aColl : TCollection); override;
    Destructor  Destroy; override;

    procedure Start ;
    procedure Stop;
    procedure init(  aAccount : TAccount; aSymbol : TSymbol; aParam : TLayOrderParam );
    procedure ApplyParam( stLossVol, stLossPer : string;  dtEndTime: TDateTime ; stCnlHour : string; stCnlTick : string);

    procedure OnQuote( aQuote : TQuote; iDataID : integer );
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID );
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID);
    procedure OnTime( Sender  : TObject );

    property Symbol : TSymbol read FSymbol;
    property Account : TAccount read FAccount;
    property DataObj : TObject read FDataObj;
    property DataID : integer read FDataID;

    property Run : boolean read FRun;

    property LayOrder : TLayOrder read FLayOrder;
  end;

  TPaveOrders = class( TCollection )
  public
    Constructor Create;
    Destructor  Destroy; override;

    function Find( aAccount: TAccount; aSymbol: TSymbol ) : TPaveOrderItem; overload;
    function Find( aAccount: TAccount; aSymbol: TSymbol; aDataObj: TObject; iDataID: integer ) : TPaveOrderItem; overload;

    function New( aAccount: TAccount; aSymbol: TSymbol; aDataObj: TObject; iDataID: integer; var bNew : boolean ) : TPaveOrderItem;

    procedure DeleteItem( aAccount: TAccount; aSymbol: TSymbol; aDataObj: TObject; iDataID: integer ); overload;
    procedure DeleteItem( aDataObj: TObject ); overload;
    procedure DeleteItem( aDataObj: TPaveOrderItem ); overload;

    procedure OnQuote( aQuote : TQuote; iDataID : integer );
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID );
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID  );
  end;

implementation

uses
  GAppEnv
  ;



{ TPaveOrders }

constructor TPaveOrders.Create;
begin
  inherited Create( TPaveOrderItem );
end;

procedure TPaveOrders.DeleteItem(aAccount: TAccount; aSymbol: TSymbol;
  aDataObj: TObject; iDataID: integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    with Items[i] as TPaveOrderItem do
      if ( FAccount = aAccount ) and ( FSymbol = aSymbol ) and
         ( FDataObj = aDataObj ) and ( FDataID = iDataID ) then
      begin
        Delete(i);
        break;
      end;
end;

procedure TPaveOrders.DeleteItem(aDataObj: TObject);
var
  I: Integer;
begin
  for I := Count-1 downto 0 do
    with Items[i] as TPaveOrderItem do
      if ( FDataObj = aDataObj ) then
        Delete(i);
end;

procedure TPaveOrders.DeleteItem(aDataObj: TPaveOrderItem);
var
  I: Integer;
begin
  for I := Count-1 downto 0 do
    if ( Items[i] = aDataObj ) then
    begin
      Delete(i);
      break;
    end;
end;

destructor TPaveOrders.Destroy;
begin

  inherited;
end;

function TPaveOrders.Find(aAccount: TAccount; aSymbol: TSymbol;
  aDataObj: TObject; iDataID: integer): TPaveOrderItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    with Items[i] as TPaveOrderItem do
      if ( FAccount = aAccount ) and ( FSymbol = aSymbol ) and
         ( FDataObj = aDataObj ) and ( FDataID = iDataID ) then
      begin
        Result := Items[i] as TPaveOrderItem;
        break;
      end;

end;

function TPaveOrders.Find(aAccount: TAccount; aSymbol: TSymbol): TPaveOrderItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    with Items[i] as TPaveOrderItem do
      if ( FAccount = aAccount ) and ( FSymbol = aSymbol ) then
      begin
        Result := Items[i] as TPaveOrderItem;
        break;
      end;
end;

function TPaveOrders.New(aAccount: TAccount; aSymbol: TSymbol;
  aDataObj: TObject; iDataID: integer; var bNew : boolean): TPaveOrderItem;
begin
  Result  := Find( aAccount, aSymbol );

  bNew := false;
  if Result = nil then
  begin
    bNew  := true;
    Result := add as TPaveOrderItem;
    Result.FAccount := aAccount;
    Result.FSymbol  := aSymbol;
    Result.FDataObj := aDataObj;
    Result.FDataID  := iDataID;
  end;
end;

procedure TPaveOrders.OnOrder(aOrder: TOrder; EventID: TDistributorID);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    (Items[i] as  TPaveOrderItem).OnOrder( aOrder, EventID );
end;

procedure TPaveOrders.OnPosition( aPosition : TPosition; EventID : TDistributorID  );
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    (Items[i] as  TPaveOrderItem).OnPosition( aPosition, EventID );

end;

procedure TPaveOrders.OnQuote(aQuote: TQuote; iDataID: integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    (Items[i] as  TPaveOrderItem).OnQuote( aQuote, iDataID );

end;

{ TPaveOrderItem }

procedure TPaveOrderItem.ApplyParam(stLossVol, stLossPer: string;
  dtEndTime: TDateTime; stCnlHour : string; stCnlTick : string);
begin
  FLayOrder.ApplyParam( StrToInt( stLossVol ), StrToInt( stLossPer ), dtEndTime, StrToInt( stCnlHour ), StrToInt( stCnlTick ) );
end;

constructor TPaveOrderItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FRun     := false;
  FAccount := nil;
  FSymbol  := nil;
  FLayOrder:= TLayOrder.Create;

  FLayOrder.OnEndNotify := OnEndEvent;
end;

destructor TPaveOrderItem.Destroy;
begin

  FAccount := nil;
  FSymbol  := nil;

  FLayOrder.Free;

  inherited;
end;

procedure TPaveOrderItem.init( aAccount : TAccount; aSymbol : TSymbol; aParam : TLayOrderParam );
begin
  FAccount  := aAccount;
  FSymbol   := aSymbol;
  FLayOrder.Param := aParam;
  FLayOrder.Account := FAccount;
  FLayOrder.Symbol  := FSymbol;

  FLayOrder.init;

  DoLog( Format('init [%s, %s, %d] -> %s', [ FAccount.Code, FSymbol.ShortCode, FDataID,
    aParam.ParamDesc ] ));
end;

procedure TPaveOrderItem.OnEndEvent(Sender: TObject);
begin

  Stop;
  PostMessage( ( FDataObj as TForm).Handle, WM_ENDPAVEORDER,
    FDataID, 0 );
end;

procedure TPaveOrderItem.OnOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  if ( FLayOrder = nil ) then Exit;

  if (aOrder.Account = FAccount) and ( aOrder.Symbol = FSymbol ) then
    FLayOrder.OnOrder( aOrder, integer(EventID) );
end;

procedure TPaveOrderItem.OnPosition(aPosition: TPosition;
  EventID: TDistributorID);
begin
  if ( FLayOrder = nil ) then Exit;

  if ( aPosition = FLayOrder.Position ) then
    FLayOrder.OnPosition( aPosition, integer(EventID));
end;

procedure TPaveOrderItem.OnQuote(aQuote: TQuote; iDataID: integer);
begin
  if (not FRun) or ( FLayOrder = nil ) then Exit;

  if aQuote.Symbol = FSymbol then
    FLayOrder.OnQuote( aQuote );
end;

procedure TPaveOrderItem.OnTime(Sender: TObject);
var
  dtNow : TDateTime;
begin
  if (not FRun) or ( FLayOrder = nil ) then Exit;

  dtNow  := Frac( GetQuoteTime );

  if dtNow < FLayOrder.Param.EndTime then
    FLayOrder.OnTimer( Self )
  else if dtNow > FLayOrder.Param.EndTime then
  begin
    DoLog( Format('Stop --> End Time  [%s, %s, %d] ', [ FAccount.Code, FSymbol.ShortCode, FDataID ]));
    OnEndEvent( Self );
  end;
end;

procedure TPaveOrderItem.Start;
begin
  FRun  := true;
  if ( FAccount <> nil ) and ( FSymbol <> nil ) then
    DoLog( Format('Start [%s, %s, %d] ', [ FAccount.Code, FSymbol.ShortCode, FDataID ]));
end;

procedure TPaveOrderItem.Stop;
begin
  FRun := false;
  if ( FAccount <> nil ) and ( FSymbol <> nil ) then
    DoLog( Format('Stop [%s, %s, %d] ', [ FAccount.Code, FSymbol.ShortCode, FDataID ]));

  FLayOrder.DoCancels( 0, 0);
  //모든 주문 취소..
end;

end.
