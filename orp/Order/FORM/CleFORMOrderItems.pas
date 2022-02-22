unit CleFORMOrderItems;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleAccounts, ClePositions, CleOrders
  ;

type
  TOrderItem = class( TCollectionItem )
  public
    Account : TAccount;
    Symbol  : TSymbol;
    Position: TPosition;

    AskOrders: TList;
    BidOrders: TList;

    procedure AskAdd( aOrder : TOrder );
    procedure BidAdd( aOrder : TOrder );

    function FindAskOrder( aPrice : double ) : boolean;
    function FindBidOrder( aPrice : double ) : boolean;

    function FindAskOrder2( aPrice : double ) : TOrder;
    function FindBidOrder2( aPrice : double ) : TOrder;

    procedure FindAskOrders( var aList : TList; dPrice : double );
    procedure FindBidOrders( var aList : TList; dPrice : double );


    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;
  end;

  TOrderItems = class( TCollection )
  private
    function GetOrderItem(i: integer): TOrderItem;
  public
    Constructor Create;
    Destructor  Destroy; override;
    function New( aAccount : TAccount; aSymbol : TSymbol ) : TOrderItem;
    function Find( aAccount : TAccount; aSymbol : TSymbol ) : TOrderItem;

    property OrderItems[ i : integer] : TOrderItem read GetOrderItem;
  end;


implementation

uses
  GAppEnv;

{ TOrderItem }

procedure TOrderItem.AskAdd(aOrder: TOrder);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
begin

  stFindkey := Format('%*n',
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

    stDesKey := Format( '%*n',
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

  stFindkey := Format('%*n',
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

    stDesKey := Format( '%*n',
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

  stFindkey := Format('%.2f',
    [ aPrice
    ] );

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

    stDesKey := Format( '%*n',
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

  stFindkey := Format('%.2f',
    [ aPrice
    ] );

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

    stDesKey := Format( '%*n',
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

  stFindkey := Format('%.2f',
    [ dPrice ] );


  for i := 0 to AskOrders.Count - 1 do
  begin
    pOrder := TOrder( AskOrders.Items[i] );
    if pOrder = nil then
      Continue;
    stDesKey := Format( '%*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
  //  ÀÚ²Ù ±î¸Ô´Â´ç..Á¨Àå
  //  val := CompareStr( 'A', 'B' );
  //  Val < 0  'b' °¡ ´õ Å©´Ù..
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

  stFindkey := Format('%.2f',
    [ aPrice ] );

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

    stDesKey := Format( '%*n',
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

  stFindkey := Format('%.2f',
    [ aPrice ] );

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

    stDesKey := Format( '%*n',
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

  stFindkey := Format('%.2f',
    [ dPrice ] );


  for i := 0 to BidOrders.Count - 1 do
  begin
    pOrder := TOrder( BidOrders.Items[i] );
    if pOrder = nil then
      Continue;
    stDesKey := Format( '%*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
  //  ÀÚ²Ù ±î¸Ô´Â´ç..Á¨Àå
  //  val := CompareStr( 'A', 'B' );
  //  Val < 0  'b' °¡ ´õ Å©´Ù..
    iCom     := CompareStr( stFindKey, stDesKey );
    if iCom = 0 then
      aList.Add( pOrder )
    else if iCom > 0 then
      Break;
  end;

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
