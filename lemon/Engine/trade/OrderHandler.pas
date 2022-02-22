unit OrderHandler;

interface

uses Classes,
     //
     GleTypes,
     CleAccounts, ClePositions, CleOrders,
     CleSymbols
     ;

type

  TOrderHandler = class
  private

    FOrderReqs : TList;
    FOnChanged : TNotifyEvent;

    function GetWaitCount : Integer;
    procedure StateChanged(aObj : TObject);
    function GetReq(i:Integer) : TOrderReqItem;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure Send;
    procedure Clear;
    function Count : Integer;
    //
    // 단순주문
    function Put(aAccount : TAccount; aSymbol : TSymbol;
                 aOrderType : TOrderType; aPositionType : TPositionType;
                 aPriceType : TPriceControl; aFillType : TTimeToMarket;
                 aOrgOrder : TOrder;
                 iQty : Integer; sPrice : Single;
                 bArbitrage : Boolean = False) : TOrderReqItem; overload;
    // 취소주문
    function Put(aOrder : TOrder; iCancelQty : Integer) : TOrderReqItem; overload;
    // 정정주문
    function Put(aOrder : TOrder; iQty : Integer;
               sPrice : Single) : TOrderReqItem; overload;
    function Put(aOrder : TOrder; ptValue : TPriceControl; iQty : Integer;
               dPrice : Double) : TOrderReqItem; overload;
    //
    property OnChanged : TNotifyEvent read FOnChanged write FOnChanged;
    property WaitCount : Integer read GetWaitCount;

    property Reqs[i:Integer] : TOrderReqItem read GetReq;
  end;
implementation

{ TOrderHandler }

//----< Private methods : receiving the result of order requests >--------//

procedure TOrderHandler.StateChanged(aObj: TObject);
begin
  if aObj = nil then Exit;
  // notify to the client
  if Assigned(FOnChanged) then
    FOnChanged(aObj as TOrderReqItem);
end;

//---------------------< Public Methods : General >-------------------//

function TOrderHandler.Count : Integer;
begin
  Result := FOrderReqs.Count;
end;

// initialize order requests
procedure TOrderHandler.Clear;
begin
  //-- delete local list
  FOrderReqs.Clear;
end;

// trigger sending order requests
procedure TOrderHandler.Send;
var
  i : Integer;
begin
  // send all to send!!!
  for i:=0 to FOrderReqs.Count-1 do
  with TOrderReqItem(FOrderReqs.Items[i]) do
    if State = rsNew then
      FTradeCentral.PutReq(TOrderReqItem(FOrderReqs.Items[i]));
  // if any which passed the check, trigger sending
  if WaitCount > 0 then
    FTradeCentral.TriggerSendingOrder;
end;

//-------< Public Methods : Order request in variant ways >-------------//

// 취소주문
function TOrderHandler.Put(aOrder : TOrder; iCancelQty : Integer) : TOrderReqItem;
begin
  Result := FTradeCentral.AddReq;
  with Result do
  begin
    Account := aOrder.Account;
    Symbol := aOrder.Symbol;
    OrderType := otCancel; // 취소주문
    PositionType := aOrder.PositionType; // redundant
    OrgOrder := aOrder;
    PriceType := aOrder.PriceControl; // redundant
    FillType := ftFAS; // redundant
    Qty := iCancelQty;     // 취소수량
    Price := 0.0;
    //
    Sender := Self;
    RecProc := StateChanged;
    Data := nil;
  end;
  //--
  FOrderReqs.Add(Result);
end;

// 정정주문
function TOrderHandler.Put(aOrder : TOrder; iQty : Integer;
           sPrice : Single) : TOrderReqItem;
begin
  Result := FTradeCentral.AddReq;
  with Result do
  begin
    Account := aOrder.Account;
    Symbol := aOrder.Symbol;
    OrderType := otChange; // 정정주문
    PositionType := aOrder.PositionType; // redundant
    OrgOrder := aOrder;
    PriceType := ptPrice; // redundant
    FillType := ftFAS; // redundant
    Qty := iQty;     // 정정수량
    Price := sPrice;
    //
    Sender := Self;
    RecProc := StateChanged;
    Data := nil;
  end;
  //--
  FOrderReqs.Add(Result);
end;

function TOrderHandler.Put(aOrder : TOrder; ptValue : TPriceControl; iQty : Integer;
               dPrice : Double) : TOrderReqItem;
begin
  Result := nil;
  
  if aOrder = nil then Exit;

  Result := FTradeCentral.AddReq;
  with Result do
  begin
    Account := aOrder.Account;
    Symbol := aOrder.Symbol;
    OrderType := otChange; // 정정주문
    PositionType := aOrder.PositionType; // redundant
    OrgOrder := aOrder;
    PriceType := ptValue;
    FillType := ftFAS; // redundant
    Qty := iQty;     // 정정수량
    Price := dPrice;
    //
    Sender := Self;
    RecProc := StateChanged;
    Data := nil;
  end;
  //--
  FOrderReqs.Add(Result);
end;

// 단순주문
function TOrderHandler.Put(aAccount : TAccount; aSymbol : TSymbol;
              aOrderType : TOrderType; aPositionType : TPositionType;
              aPriceType : TPriceControl; aFillType : TTimeToMarket;
              aOrgOrder : TOrder;
              iQty : Integer; sPrice : Single;
              bArbitrage : Boolean) : TOrderReqItem;
begin
  Result := FTradeCentral.AddReq;
  with Result do
  begin
    Account := aAccount;
    Symbol := aSymbol;
    OrderType := aOrderType;
    PositionType := aPositionType;
    OrgOrder := aOrgOrder;
    PriceType := aPriceType;
    FillType := aFillType;
    Qty := iQty;
    case aPriceType of
      pcLimit,  pcBestLimit : Price := sPrice;
      pcMarket : Price := 0.0;
    end;
    //
    IsArbitrage := bArbitrage;
    //
    Sender := Self;
    RecProc := StateChanged;
    Data := nil;
  end;
  //--
  FOrderReqs.Add(Result);
end;

//----------------------< Init / final >-------------------------//

constructor TOrderHandler.Create;
begin
  //
  FOrderReqs := TList.Create;
end;

destructor TOrderHandler.Destroy;
begin

  FOrderReqs.Free;

  inherited;
end;

//---------------------< property methods >----------------------//

function TOrderHandler.GetWaitCount: Integer;
var
  i : Integer;
begin
  Result := 0;
  //
  for i:=0 to FOrderReqs.Count-1 do
    with TOrderReqItem(FOrderReqs.Items[i]) do
      if IsDoing then
        Inc(Result);
end;


function TOrderHandler.GetReq(i:Integer) : TOrderReqItem;
begin
  if (i >= 0) and (i <= FOrderReqs.Count-1) then
    Result := TOrderReqItem(FOrderReqs.Items[i])
  else
    Result := nil;
end;

end.
