unit CleFrontOrder;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleAccounts, ClePositions, CleOrders
  ;

type
  TOrderItem = class( TCollectionItem )
  private
    function GetAskOrder(i: integer): TOrder;
    function GetBidOrder(i: integer): TOrder;

  public
    Account : TAccount;
    Symbol  : TSymbol;
    Position: TPosition;

    AskOrders: TList;
    BidOrders: TList;

    procedure Reset;
    procedure AskAdd( aOrder : TOrder );
    procedure BidAdd( aOrder : TOrder );
    procedure OrdAdd( aOrder : TOrder );

    function FindAskOrder( aPrice : double ) : boolean;
    function FindBidOrder( aPrice : double ) : boolean;

    function FindAskOrder2( aPrice : double ) : TOrder;
    function FindBidOrder2( aPrice : double ) : TOrder;

    procedure FindAskOrders( var aList : TList; dPrice : double );
    procedure FindBidOrders( var aList : TList; dPrice : double );


    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    property AskOrder[ i : integer] :TOrder read GetAskOrder;
    property BidOrder[ i : integer] :TOrder read GetBidOrder;
  end;

  TOrderItems = class( TCollection )
  private
    function GetOrderItem(i: integer): TOrderItem;
  public
    Constructor Create;
    Destructor  Destroy; override;
    function DoCancel(aOrder: TOrder): boolean;
    procedure DoOrder( aOrder : TOrder );
    function New( aAccount : TAccount; aSymbol : TSymbol ) : TOrderItem;
    function Find( aAccount : TAccount; aSymbol : TSymbol ) : TOrderItem;
    function DoCancels(aItem: TOrderItem; iSide: integer; bAll : boolean = true): boolean; overload;
    function DoCancels(aItem: TOrderItem; iSide: integer; dPrice : double): boolean; overload;
    property OrderItems[ i : integer] : TOrderItem read GetOrderItem;
  end;


implementation

uses
  GAppEnv, GleLib, GleConsts
  ;

{ TOrderItem }

procedure TOrderItem.AskAdd(aOrder: TOrder);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

 for I := 0 to AskOrders.Count - 1 do
  begin
    pOrder := TOrder( AskOrders.Items[i]);
    if pOrder = aOrder then
      Exit;
  end;

  stFindkey := Format('%.*n',
    [ aOrder.Symbol.Spec.Precision,
      aOrder.Price
    ] );

  iLow := 0;
  iHigh:= AskOrders.Count-1;

  iPos := -1;

  if AskOrders.Count = 0 then
  begin
    AskOrders.Add( aOrder);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TOrder( AskOrders.Items[iMid] );
    if pOrder = nil then
      break;

    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

  if iPos >=0 then
    AskOrders.Insert(iPos, aOrder);

end;

procedure TOrderItem.BidAdd(aOrder: TOrder);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

  for I := 0 to BidOrders.Count - 1 do
  begin
    pOrder := TOrder( BidOrders.Items[i]);
    if pOrder = aOrder then
      Exit;
  end;

  stFindkey := Format('%.*n',
    [ aOrder.Symbol.Spec.Precision,
      aOrder.Price
    ] );

  iLow := 0;
  iHigh:= BidOrders.Count-1;

  iPos := -1;

  if BidOrders.Count = 0 then
  begin
    BidOrders.Add( aOrder);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TOrder( BidOrders.Items[iMid] );
    if pOrder = nil then
      break;

    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;

    iPos := iLow;
  end;

  if iPos >=0 then
    BidOrders.Insert( iPos, aOrder );
end;

constructor TOrderItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  Account := nil;
  Symbol  := nil;
  Position:= nil;

  AskOrders:= TList.Create;
  BidOrders:= TList.Create;
end;

destructor TOrderItem.Destroy;
begin
  AskOrders.Free;
  BidOrders.Free;
  inherited;
end;

function TOrderItem.FindAskOrder(aPrice: double): boolean;
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

  result := false;

  stFindkey := Format('%.*n',
    [ Symbol.Spec.Precision, aPrice ] );

  iLow := 0;
  iHigh:= AskOrders.Count-1;

  iPos := -1;

  if AskOrders.Count = 0 then
    Exit;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TOrder( AskOrders.Items[iMid] );
    if pOrder = nil then
      break;

    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := true;
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

end;

function TOrderItem.FindAskOrder2(aPrice: double): TOrder;
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

  result := nil;

  stFindkey := Format('%.*n',
    [ Symbol.Spec.Precision, aPrice ] );

  iLow := 0;
  iHigh:= AskOrders.Count-1;

  iPos := -1;

  if AskOrders.Count = 0 then
    Exit;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TOrder( AskOrders.Items[iMid] );
    if pOrder = nil then
      break;

    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := pOrder;
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;


end;

procedure TOrderItem.FindAskOrders(var aList: TList; dPrice : double);
var
  stFindKey, stDesKey: String;
  iCom, i: Integer;
  pOrder : TOrder;
begin

  if AskOrders.Count <= 0 then Exit;

  stFindkey := Format('%.*n',
    [ Symbol.Spec.Precision, dPrice ] );


  for i := 0 to AskOrders.Count - 1 do
  begin
    pOrder := TOrder( AskOrders.Items[i] );
    if pOrder = nil then
      Continue;
    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
  //  ???? ????????..????
  //  val := CompareStr( 'A', 'B' );
  //  Val < 0  'b' ?? ?? ????..
    iCom     := CompareStr( stFindKey,stDesKey  );
    if iCom = 0 then
      aList.Add( pOrder )
    else if iCom < 0 then
      Break;
  end;


end;

function TOrderItem.FindBidOrder(aPrice: double): boolean;
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

  result := false;

  stFindkey := Format('%.*n',
    [ Symbol.Spec.Precision, aPrice ] );

  iLow := 0;
  iHigh:= BidOrders.Count-1;

  iPos := -1;

  if BidOrders.Count = 0 then
    Exit;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TOrder( BidOrders.Items[iMid] );
    if pOrder = nil then
      break;

    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := true;
        iPos := iMid;
        break;;
      end;
    end;

    iPos := iLow;
  end;

end;

function TOrderItem.FindBidOrder2(aPrice: double): TOrder;
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

  result := nil;

  stFindkey := Format('%.*n',
    [ Symbol.Spec.Precision, aPrice ] );

  iLow := 0;
  iHigh:= BidOrders.Count-1;

  iPos := -1;

  if BidOrders.Count = 0 then
    Exit;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TOrder( BidOrders.Items[iMid] );
    if pOrder = nil then
      break;

    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := pOrder;
        iPos := iMid;
        break;;
      end;
    end;

    iPos := iLow;
  end;
end;

procedure TOrderItem.FindBidOrders(var aList: TList; dPrice: double);
var
  stFindKey, stDesKey: String;
  iCom, i: Integer;
  pOrder : TOrder;
begin

  if BidOrders.Count <= 0 then Exit;

  stFindkey := Format('%.*n',
    [ Symbol.Spec.Precision, dPrice ] );


  for i := 0 to BidOrders.Count - 1 do
  begin
    pOrder := TOrder( BidOrders.Items[i] );
    if pOrder = nil then
      Continue;
    stDesKey := Format( '%.*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
  //  ???? ????????..????
  //  val := CompareStr( 'A', 'B' );
  //  Val < 0  'b' ?? ?? ????..
    iCom     := CompareStr( stFindKey, stDesKey );
    if iCom = 0 then
      aList.Add( pOrder )
    else if iCom > 0 then
      Break;
  end;
end;


function TOrderItem.GetAskOrder(i: integer): TOrder;
begin
  if ( i<0 ) or ( i >= AskOrders.Count ) then
    Result := nil
  else
    Result := TOrder( AskOrders.Items[i] );
end;

function TOrderItem.GetBidOrder(i: integer): TOrder;
begin
  if ( i<0 ) or ( i >= BidOrders.Count ) then
    Result := nil
  else
    Result := TOrder( BidOrders.Items[i] );
end;

procedure TOrderItem.OrdAdd(aOrder: TOrder);
begin
  if aOrder.Side > 0 then
    BidAdd( aOrder )
  else if aOrder.Side < 0 then
    AskAdd( aOrder );
end;

procedure TOrderItem.Reset;
begin
  BidORders.Clear;
  AskOrders.Clear;
end;


{ TOrderItems }

constructor TOrderItems.Create;
begin
  inherited Create( TOrderItem );
end;

destructor TOrderItems.Destroy;
begin
  inherited;
end;

procedure TOrderItems.DoOrder(aOrder: TOrder);
var
  aItem : TOrderItem;
begin

  aItem := New( aOrder.Account, aOrder.Symbol );
  if aItem = nil then Exit;

  if aOrder.State = osActive then
  begin
    if aOrder.Side = 1 then
      aItem.BidAdd( aOrder )
    else
      aItem.AskAdd( aOrder );
  end
  else begin
    if aOrder.Side = 1 then
      aItem.BidOrders.Remove( aOrder )
    else
      aItem.AskOrders.Remove( aOrder );
  end;
end;

function TOrderItems.DoCancels(aItem: TOrderItem; iSide: integer; bAll : boolean): boolean;
var
  i, iSu, iCnt : integer;
  aOrder : TOrder;
  bRes : boolean;
begin

  Result := false;

  iSu := 0;
  iCnt:= 0;

  case iSide of
    0 :
      if aItem.AskOrders.Count > aItem.BidOrders.Count then
        iSu := aItem.AskOrders.Count -1
      else
        iSu := aItem.BidOrders.Count -1;
    1 : iSu := aItem.BidOrders.Count;
    -1: iSu := aItem.AskOrders.Count;
  end;

  for i := 0 to iSu do
  begin
    aOrder := nil;
    bRes   := false;
    if iSide >= 0 then begin
      if i < aItem.BidOrders.Count then
        aOrder  := TOrder( aItem.BidOrders.Items[i] );

      if aOrder <> nil then
        if ( aOrder.OrderType = otNormal ) and ( not aOrder.Modify ) and
           ( aOrder.ActiveQty > 0 ) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );

        end;
    end;

    if iSide <= 0 then begin
      aOrder := nil;
      bRes   := false;
      if i < aItem.AskOrders.Count then
        aOrder := TOrder( aItem.AskOrders.Items[i] );

      if aOrder <> nil then
        if ( aOrder.OrderType = otNormal ) and ( not aOrder.Modify ) and
           ( aOrder.ActiveQty > 0 ) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );
        end;
    end;

    if iCnt >= 10 then
      sleep(10);
  end;

  Result := false;

end;


function TOrderItems.DoCancels(aItem: TOrderItem; iSide: integer;
  dPrice: double): boolean;
var
  i, iSu, iCnt : integer;
  aOrder : TOrder;
  bRes : boolean;
begin

  Result := false;

  iSu := 0;
  iCnt:= 0;

  case iSide of
    0 : begin  DoCancels( aItem, 0 , true );   Exit; end;
    1 : iSu := aItem.BidOrders.Count;
    -1: iSu := aItem.AskOrders.Count;
  end;

  for i := 0 to iSu do
  begin
    aOrder := nil;
    bRes   := false;
    if iSide >= 0 then begin
      if i < aItem.BidOrders.Count then
        aOrder  := TOrder( aItem.BidOrders.Items[i] );

      if aOrder <> nil then
        if ( aOrder.OrderType = otNormal ) and ( not aOrder.Modify ) and
           ( aOrder.ActiveQty > 0 ) and ( aOrder.Price > (dPrice - PRICE_EPSILON)) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );

        end;
    end;

    if iSide <= 0 then begin
      aOrder := nil;
      bRes   := false;
      if i < aItem.AskOrders.Count then
        aOrder := TOrder( aItem.AskOrders.Items[i] );

      if aOrder <> nil then
        if ( aOrder.OrderType = otNormal ) and ( not aOrder.Modify ) and
           ( aOrder.ActiveQty > 0 ) and ( (aOrder.Price - PRICE_EPSILON) < dPrice ) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );
        end;
    end;

    if iCnt >= 10 then
      sleep(10);
  end;

  Result := false;
end;


function TOrderItems.DoCancel(aOrder: TOrder): boolean;
var
  pOrder  : TOrder;
  stLog   : string;
  aTicket : TOrderTicket;
begin

  Result := false;
  if aOrder.ActiveQty <= 0 then Exit;
  if aOrder.State <> osActive then Exit;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  pOrder := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aOrder, aOrder.ActiveQty, aTicket);


  if pOrder <> nil then
  begin

    gEnv.Engine.TradeBroker.Send( pOrder.Ticket );
    Result := true;
    stLog := Format( 'Cancel Order : %s, %.2f, %d, %d ',
      [
        ifThenStr( pOrder.Side > 0 , 'L', 'S'),
        aOrder.Price,
        aOrder.ActiveQty,
        aOrder.OrderNo
      ]
      );
    gEnv.EnvLog( WIN_LOSS, stLog );
  end ;

end;


function TOrderItems.Find(aAccount: TAccount; aSymbol: TSymbol): TOrderItem;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if (GetOrderItem(i).Account = aAccount) and
      ( GetOrderItem(i).Symbol  = aSymbol ) then
    begin
      Result := GetOrderItem(i);
      break;
    end;
end;

function TOrderItems.GetOrderItem(i: integer): TOrderItem;
begin
  if ( i < 0 ) and ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TOrderItem;
end;

function TOrderItems.New(aAccount: TAccount; aSymbol: TSymbol): TOrderItem;
begin
  Result := Find( aAccount, aSymbol );

  if Result = nil then
  begin
    Result := Add as TOrderItem;
    Result.Account  := aAccount;
    Result.Symbol   := aSymbol;
    Result.Position := gEnv.Engine.TradeCore.Positions.FindOrNew( aAccount, aSymbol );
  end;

  if Result.Position = nil then
    Result.Position := gEnv.Engine.TradeCore.Positions.FindOrNew( aAccount, aSymbol );
end;

end.
