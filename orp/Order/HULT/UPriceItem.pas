unit UPriceItem;

interface

uses
  classes, SysUtils,

  CleOrders, CleSymbols, CleQuoteBroker,

  GleTypes, GleConsts

  ;

type

  TPriceItem2 = class( TCollectionItem )
  private
    procedure SetOrderValue(iVal: integer);


  public
    Price       : double;
    PriceDesc   : string;
    Index       : integer;

    Volume      : array[TPositionType] of integer;
    VolumeDiff  : array[TPositionType] of integer;
    OrderQtySum : integer;

    PositionType : TPositionType;
    OrderList    : TOrderList;
    LastTime     : TDateTime;
    FullQty      : array[TPositionType] of boolean;
    FilledQty    : array[TPositionType] of integer;
    BHult        : boolean;



    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;

    procedure Reset;
    procedure init( i: integer; dPrice: double; stDesc : string);

    procedure AddOrder( aOrder : TOrder );
    procedure DelOrder( aOrder : TOrder );

    function OnOrder( aOrder : TOrder; iFillQty : integer =0) : boolean;

    procedure SetPriceItem( iVol : integer; aType : TPositionType );
    procedure SetPriceFill( iVol : integer);
    procedure SetSide( iSide : integer );

    function GetDesc: string;
    function IsOrder : boolean;
    function IsExistMyOrder( iSide : integer ) : boolean;

    function IsSamePrice( dPrice : double ) : boolean;
    function GetActiveOrderCount : integer;
    function GetClearOrderCount: integer;
    function GetOrderCnt : integer;

    function SideToStr: string;
    function SideToStr2: string;

    function GetPriceDesc : string;

    function OrderPieceCheck(iQty, iSide : integer) : Boolean;

    function GetOrderQtySum(iSide : integer) : integer;
    function CancelOrderCheck : boolean;
    function IsCancelOrder : boolean;
    function IsSameSide( iSide : integer ) : boolean;


  end;

  TPriceSet = class( TCollection )
  private
    FSymbol: TSymbol;
    FBidOrdCnt : integer;
    FAskOrdCnt : integer;
    FOrderQty : integer;
    function GetPriceItem(i: integer): TPriceItem2;

  public
    Constructor Create ;
    Destructor  Destroy; override;
    procedure SetOrdCnt(aOrder : TOrder; bAdd : boolean);
    procedure ReSet;
    function New( i : integer ) : TPriceItem2;

    function GetIndex( dPrice : double ) : integer; overload;
    function GetIndex( stPrice: string ) : integer; overload;
    function FindIndex(dPrice: Double): Integer;

    function Find( dPrice : double ) : integer; overload;
    function Find( stPrice: string ) : integer; overload;
    function Find2( dPrice : double ) : integer;

    property Symbol : TSymbol read FSymbol write FSymbol;
    property PriceItem[ i : integer] : TPriceItem2 read GetPriceItem;
    property BidOrdCnt : integer read FBidOrdCnt;
    property AskOrdCnt : integer read FAskOrdCnt;
    property OrderQty : integer read FOrderQty write FOrderQty;
  end;


implementation

uses
  GAppEnv, GleLib, CleQuoteTimers, Math

  ;

{ TPriceItem }


function TPriceItem2.CancelOrderCheck: boolean;
var
  i : integer;
  aOrder : TOrder;
begin
  Result := false;

  for i := 0 to OrderList.Count - 1 do
  begin
    aOrder := OrderList.Items[i];

    if (aOrder.OrderType = otNormal) and (aORder.State = osActive) then
    begin
      Result := true;
    end else
    begin
      Result := false;
      break;
    end;

  end;

end;

constructor TPriceItem2.Create(aColl: TCollection);
begin
  inherited Create( aColl );

  Reset;
end;

destructor TPriceItem2.Destroy;
begin
  OrderList.Free;
  inherited;
end;


function TPriceItem2.GetActiveOrderCount: integer;
var
  I: Integer;
  aOrder : TOrder;
begin
  Result := 0;

  for I := 0 to Orderlist.Count - 1 do
  begin
    aOrder := OrderList.Orders[i];
    if ( aOrder.OrderType = otNormal ) and ( aOrder.State = osActive ) and ( aOrder.ActiveQty > 0 ) then
      inc(Result );
  end;
end;

function TPriceItem2.GetClearOrderCount: integer;
var
  I: Integer;
  aOrder : TOrder;
begin
  Result := 0;
  {
  for I := 0 to Orderlist.Count - 1 do
  begin
    aOrder := OrderList.Orders[i];
    if ( aOrder.OrderType = otNormal ) and ( aOrder.State = osActive ) and
      ( aOrder.ActiveQty > 0 ) and ( aOrder.ClearOrder ) then
      inc(Result );
  end;
  }
end;

function TPriceItem2.SideToStr: string;
begin

  Result :='';// ifThenStr( PositionType = ptLong, '매수', '매도');
end;

function TPriceItem2.SideToStr2: string;
begin
  Result :='';// ifThenStr( PositionType = ptShort, '매수', '매도');
end;



procedure TPriceItem2.AddOrder(aOrder: TOrder);
var
  iQty : integer;
  stL, stS : string;
begin
  OrderList.Add( aOrder );

  iQty := (Collection as TPriceSet).OrderQty;
  ORderQtySum := GetOrderQtySum(aOrder.Side);


  if (aORder.Side > 0) and (OrderQtySum >= iQty) and (not FullQty[ptLong]) then
  begin
    FullQty[ptLong] := true;
    (Collection as TPriceSet).SetOrdCnt(aOrder, true);
  end else if (aORder.Side < 0) and (OrderQtySum >= iQty) and (not FullQty[ptShort]) then
  begin
    FullQty[ptShort] := true;
    (Collection as TPriceSet).SetOrdCnt(aOrder, true);
  end;


  if FullQty[ptLong] then
    stL := 'Long True'
  else
    stL := 'Long False';

  if FullQty[ptShort] then
    stS := 'Short True'
  else
    stS := 'Short False';



  gEnv.EnvLog( WIN_HULT, Format('Price Add Order : Ask = %d, Bid = %d, Sum = %d, %s, %s, %s',
      [ (Collection as TPriceSet).AskOrdCnt, (Collection as TPriceSet).BidOrdCnt, ORderQtySum, stL, stS, GetPriceDesc]));
  if OrderQtySum > iQty then
    gEnv.EnvLog(WIN_HULT, Format('Price AddOrder Sum(%d) > Qty(%d), %s',[OrderQtySum, (Collection as TPriceSet).OrderQty, GetPriceDesc ]));

end;

procedure TPriceItem2.DelOrder(aOrder: TOrder);
begin

end;

procedure TPriceItem2.init(i: integer; dPrice: double; stDesc: string);
begin
  Index := i;
  Price := dPrice;
  PriceDesc := stDesc;
end;

function TPriceItem2.IsCancelOrder: boolean;
var
  I: Integer;
begin
  Result := false;
  for I := 0 to OrderList.Count - 1 do
  begin
    if OrderList.Orders[i].OrderType = otCancel  then
     begin
      Result := true;
      break;
    end;
  end;
end;

function TPriceItem2.IsExistMyOrder(iSide: integer): boolean;
var
  I: Integer;
begin
  Result := false;
  for I := 0 to OrderList.Count - 1 do
    if (OrderList.Orders[i].State = osActive ) and ( OrderList.Orders[i].OrderType = otNormal ) and
      (OrderList.Orders[i].Side = iSide ) then
    begin
      Result := true;
      break;
    end;
end;

function TPriceItem2.IsOrder: boolean;
begin
  Result := OrderList.Count = 0;  
end;

function TPriceItem2.IsSamePrice(dPrice: double): boolean;
var
  iPre : integer;
  stPrice : string;
begin
  iPre := (Collection as TPriceSet).Symbol.Spec.Precision;
  stPrice := Format('%.*n', [ iPre, dPrice ]);
  iPre := CompareStr( PriceDesc, stPrice );

  if (PositionType = ptLong) and ( iPre <=0 ) then
    Result := true
  else if (PositionType = ptShort) and ( iPre >=0 ) then
    Result := true
  else
    Result := false;
end;

function TPriceItem2.IsSameSide(iSide: integer): boolean;
var
  I: Integer;
begin
  Result := true;
  for I := 0 to OrderList.Count - 1 do
  begin
    if OrderList.Orders[i].Side = iSide then
    begin
      Result := false;
      break;
    end;
  end;
end;

function TPriceItem2.OnOrder(aOrder: TOrder; iFillQty : integer) : boolean;
var
  I: Integer;
  stL, stS : string;
begin
  Result := false;
  for I := 0 to OrderList.Count - 1 do
  begin
    if OrderList.Orders[i] = aOrder then
      if not (aOrder.State in [osReady, osSent, osSrvAcpt, osActive]) then
      begin
        OrderList.Delete(i);
        break;
      end;
  end;

  while i <= OrderList.Count - 1 do
  begin
    if not (OrderList.Orders[i].State  in [osReady, osSent, osSrvAcpt, osActive]) then
      OrderList.Delete(i)
    else
      inc(i);
  end;

end;

function TPriceItem2.OrderPieceCheck(iQty, iSide: integer): Boolean;
var
  I, iSum : Integer;
  aOrder : TOrder;
begin
  Result := false;
  iSum := 0;
  for I := 0 to Orderlist.Count - 1 do
  begin
    aOrder := OrderList.Orders[i];

    if ( aOrder.OrderType = otNormal ) and ( aOrder.State = osActive ) and  ( aOrder.ActiveQty > 0 ) then
      iSum := iSum + aOrder.ActiveQty
    else if ( aOrder.OrderType = otNormal ) and ( aOrder.State in [osReady, osSent, osSrvAcpt] ) then
      iSum := iSum + aOrder.OrderQty;
  end;

  if iSum + iQty <= (Collection as TPriceSet).OrderQty then
    Result := true
  else
  begin
    gEnv.EnvLog(WIN_HULT, Format('IsOrderPiece %.1f, %d, %d, %s', [Price, iSum , iQty, GetPriceDesc]));
  end;
end;

procedure TPriceItem2.Reset;
begin
  Index := -1;
  Price := 0;
  PriceDesc := '';
  Volume[ptLong]  := 0;
  Volume[ptShort] := 0;
  VolumeDiff[ptLong]  := 0;
  VolumeDiff[ptShort] := 0;
  OrderQtySum := 0;
  FullQty[ptLong] := false;
  FullQty[ptShort] := false;
  FilledQty[ptLong] := 0;
  FilledQty[ptShort] := 0;
  BHult := false;

  if OrderList <> nil then  
    OrderList.Free;
  OrderList := TOrderList.Create;
end;

procedure TPriceItem2.SetPriceFill(iVol: integer);
var
  I: Integer;
  aOrder : TOrder;
begin
  {
  for I := 0 to OrderList.Count - 1 do
  begin
    aOrder  := OrderList.Orders[i];
    if aOrder.RemainVol > 0  then begin
      aOrder.RemainVol := max( 0, aOrder.RemainVol -iVol );
      gLog.Add( lkLossCut, 'TPriceItem','SetPriceFill', Format('%s, Rv:%d, Aq:%d, %d', [
        GetDesc,  aOrder.RemainVol,  aOrder.ActiveQty, aOrder.OrderNo
        ]) );
    end;
  end;
  }
end;

procedure TPriceItem2.SetPriceItem(iVol: integer; aType: TPositionType);
begin
  PositionType  := aType;
  VolumeDiff[ aType] := iVol - Volume[aType];
  Volume[aType]      := iVol;
  LastTime           := GetQuoteTime;

  if (OrderList.Count > 0) and ( iVol > 0 ) then
    SetOrderValue( iVol );
end;

procedure TPriceItem2.SetSide(iSide: integer);
begin
  if iSide > 0 then
    PositionType := ptLong
  else
    PositionType := ptShort;
end;

procedure TPriceItem2.SetOrderValue( iVal : integer );
var
  I, iGap: Integer;
  aOrder : TOrder;
  bStart : boolean;
begin
  for I := 0 to OrderList.Count - 1 do
  begin
    bStart := false;
    aOrder  := OrderList.Orders[i];
    {
    if not aOrder.IsRemainVol  then begin
      aOrder.RemainVol := iVal;
      aOrder.IsRemainVol  := true;
      aOrder.PrevVol   := iVal;
      iGap := 0;
      bstart := true;
    end
    else begin
      iGap := aOrder.PrevVol - iVal;
      aOrder.PrevVol := iVal;
      if iGap > 0 then
        aOrder.RemainVol := Max( 0, aORder.RemainVol - iGap );
    end;

    gEnv.EnvLog( WIN_GI, Format('잔량 : %s | %d, %d, %d, %s ',
      [ aOrder.SimpleRepresent, aOrder.RemainVol, iGap+ival, iVal, ifThenStr( bstart,'sta', 'ing') ]), false, aOrder.Symbol.Code );
      }
  end;
end;

function TPriceItem2.GetDesc : string;
begin
  Result := Format('%s,%s,%d,%d ', [ PriceDesc,
    ifThenStr( PositionType = ptLong, '매수', '매도'), Volume[PositionType] ,
    OrderList.Count
    ]);
end;

function TPriceItem2.GetOrderCnt: integer;
var
  I: Integer;
  aOrder : TOrder;
begin
  Result := 0;

  for I := 0 to Orderlist.Count - 1 do
  begin
    aOrder := OrderList.Orders[i];
    if (aOrder.State in [osReady, osSent, osSrvAcpt, osActive]) then
    begin
      inc(Result );
    end;
  end;
end;

function TPriceItem2.GetOrderQtySum(iSide: integer): integer;
var
  i : integer;
  aOrder : TOrder;
begin
  Result := 0;
  for i := 0 to OrderList.Count - 1 do
  begin
    aOrder := OrderList.Items[i];
    // 부분체결일때... 다른방향 주문이 들어올수도 있따
    if (aOrder.OrderType = otNormal) and (aOrder.Side = iSide)  then
      Result := Result + aOrder.OrderQty;
  end;

end;

function TPriceItem2.GetPriceDesc: string;
var
  i, iSum : integer;
  aOrder : TOrder;
  stLog, stTmp : string;
begin
  iSum := 0;
  for i := 0 to  OrderList.Count - 1 do
  begin
    aOrder := OrderList.Items[i];
    if aOrder.State = osActive then
      iSum := iSum + aOrder.ActiveQty
    else if aOrder.State in [osReady, osSent, osSrvAcpt] then
      iSum := iSum + aOrder.OrderQty;
    stLog := stLog + Format('(%d)Satae = %s, Qty = %d, ActiveQty = %d, Side = %d, No = %d, %s **' ,
              [i, aOrder.StateDesc, aOrder.OrderQty, aOrder.ActiveQty, aOrder.Side, aOrder.OrderNo, aOrder.OrderTypeDesc]);
  end;

  Result := Format('%.1f, %d(%d), %s, %s',[Price, iSum, OrderList.Count, stTmp, stLog]);

end;

{ TPriceSet }

constructor TPriceSet.Create;
begin
  inherited Create( TPriceItem2 );
  FBidOrdCnt := 0;
  FAskOrdCnt := 0;
end;

destructor TPriceSet.Destroy;
begin

  inherited;
end;

function TPriceSet.Find(stPrice: string): integer;
var
  iLow, iHigh, iMid, iCom : integer;
  aPrice : TPriceItem2;
  stFindKey, stDesKey: String;
begin
  result := -1;

  stFindkey := stPrice;

  iLow := 0;
  iHigh:= Count-1;

  if Count = 0 then
    Exit;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    aPrice := GetPriceItem(iMid);
    if aPrice = nil then
      break;

    stDesKey := aPrice.PriceDesc;
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := iMid;
        break;;
      end;
    end;
  end;
end;

function TPriceSet.Find2(dPrice: double): integer;
var
  stPrice : string;
  i: Integer;
  aItem : TPriceItem2;
begin
  Result := -1;
  stPrice := Format('%.*n', [ Symbol.Spec.Precision, dPrice ]);
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TPriceItem2;
    if aItem.PriceDesc = stPrice then
    begin
      Result := i;
      break;
    end;
  end;
end;


function TPriceSet.FindIndex(dPrice: Double): Integer;
var
  i : Integer;

begin
  Result := -1;
  //
  if (dPrice < (Items[0] as TPriceItem2).Price - PRICE_EPSILON) or
     (dPrice > (Items[Count - 1] as TPriceItem2).Price + PRICE_EPSILON) then
     begin
       //gEnv.OnLog(self, self.Symbol.Code + ' : 상하한가오류');
       Exit;
     end;
  //

  for i:=0 to Count-1 do
  with (Items[i] as TPriceItem2) do
    if Abs(Price - dPrice) < PRICE_EPSILON then
    begin
      Result := i;
      Break;
    end;

end;

function TPriceSet.Find(dPrice: double): integer;
begin
  Result := Find( Format('%.*n', [ Symbol.Spec.Precision, dPrice ]));
end;

function TPriceSet.GetIndex(stPrice: string): integer;
begin
  Result := Find( stPrice );
end;

function TPriceSet.GetIndex(dPrice: double): integer;
begin
  Result := Find( dPrice );
end;

function TPriceSet.GetPriceItem(i: integer): TPriceItem2;
begin
  if (i<0) or ( i>= Count ) then
    Result := nil
  else
    Result := Items[i] as TPriceItem2;
end;

function TPriceSet.New(i: integer): TPriceItem2;
begin
  Result := Add as TPriceItem2;
  Result.Index  := i;
end;

procedure TPriceSet.ReSet;
begin
  FBidOrdCnt := 0;
  FAskOrdCnt := 0;
end;

procedure TPriceSet.SetOrdCnt(aOrder: TOrder; bAdd: boolean);
begin
  if bAdd then
  begin
    if aOrder.Side = 1 then
      inc(FBidOrdCnt)
    else
      inc(FAskOrdCnt);
  end else
  begin
    if aOrder.Side = 1 then
      dec(FBidOrdCnt)
    else
      dec(FAskOrdCnt);
  end;

  //gEnv.EnvLog(WIN_UPDOWN, Format('SerOrdCnt Bid = %d, Ask = %d',[FBidOrdCnt, FAskOrdCnt]));
end;

end.

