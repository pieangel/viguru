unit CleOrderSlots;

interface

uses
  Classes, SysUtils, Math,

  CleAccounts, CleSymbols, CleOrders, ClePositions,

  CleFills, CleFORMOrderItems,

  CleDistributor, CleQuoteBroker, CleKrxSymbols,

  GleTypes, GleConsts
  ;

type

  TBHultOrderEvent = procedure( dPrice : double; iSide : Integer; dDiv : char ) of object;

  TBHultOrderSlotItem = class( TCollectionItem )
  public
    index     : integer;
    OrderDiv  : array [TPositionType] of char ; // 1 : ?Ϲ?  2 : û??
    Price     : array [TPositionType] of double;
    PriceStr  : array [TPositionType] of string;
    IsOrder   : array [TPositionType] of boolean;

    Constructor Create( aColl : TCollection ); override;
  end;

  TBHultOrderSlots  = class( TCollection )
  private
    FBasePrice: double;
    FIsFirst: boolean;

    FDone: boolean;
    FBHultOrderEvent: TBHultOrderEvent;
    FLossCut: boolean;
    FMaxOrdCnt: integer;
    FOrdCount: integer;
    FLossPrice: double;
    FLiqIndex: integer;
    FPosType: TPositionType;
    FSide: integer;
    FPL: double;
    FLastSlot: TBHultOrderSlotItem;
    function GetOrderSlot(i: integer): TBHultOrderSlotItem;
    function CheckPrice(iSide, iPre : integer; dBase, dPrice : double): boolean;
    procedure SetSide(const Value: integer);
    function GetLastSlot: TBHultOrderSlotItem;
    function GetQuoteSide(  aQuote : TQuote  ): integer;

  public
    Constructor Create;
    Destructor  Destroy; override;

    function New : TBHultOrderSlotItem;

    procedure Reset;
    procedure OnQuote( aQuote : TQuote );
    function  CheckReset( aQuote : TQuote ) : boolean;
    function  CheckLossCut( iVolume : integer; aQuote : TQuote ) : boolean;
    function  CheckLossCut2( iVolume : integer; aQuote : TQuote ) : boolean;

    property HultOrderSlot[ i  :integer] : TBHultOrderSlotItem read GetOrderSlot; default;
    property BasePrice : double read FBasePrice write FBasePrice;
    property LossPrice : double read FLossPrice write FLossPrice;
    property IsFirst   : boolean read FIsFirst write FIsFirst;

    property LastSlot  : TBHultOrderSlotItem read FLastSlot write FLastSlot;

 //   property Side      : integer read FSide;
    property Done      : boolean read FDone;  // ???? ?ֹ??? ?? ?????ִ? ????;
    property LossCut   : boolean read FLossCut write FLossCut;

    property MaxOrdCnt : integer read FMaxOrdCnt write FMaxOrdCnt;// ?ִ? ?ֹ? ????( ?Ǽ??? üũ..?????ֹ??? ???? ???? )
    property OrdCount  : integer read FOrdCount write FOrdCount;
    property LiqIndex  : integer read FLiqIndex write FLiqIndex;
    property Side      : integer read FSide write SetSide;
    property PosType   : TPositionType read FPosType;

    property PL        : double read FPL write FPL;

    property BHultOrderEvent : TBHultOrderEvent read FBHultOrderEvent write FBHultOrderEvent;

  end;

implementation

uses
  GAppEnv, GleLib;

{ TBHultOrderSlotItem }

constructor TBHultOrderSlotItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
end;

{ TBHultOrderSlots }



function TBHultOrderSlots.CheckPrice( iSide, iPre : integer; dBase, dPrice : double ): boolean;
var
  iRes : integer;
begin
  Result := false;

  if iSide > 0 then
  begin
    iRes  := ComparePrice( iPre, dBase, dPrice );
    if iRes > 0 then
      Result := true;
  end
  // ?ŵ??? ???? ??????..
  else if iSide < 0 then
  begin
    iRes  := ComparePrice( iPre, dPrice, dBase );
    if iRes > 0 then
      Result := true;
  end;

end;

function TBHultOrderSlots.CheckReset(aQuote: TQuote): boolean;
begin
{
  Result := false;

  if FPosType = ptLong then
  begin
    Result  := CheckPrice( 1, aQuote.Symbol.Spec.Precision, FBasePrice, a
  end;
  }
end;

function TBHultOrderSlots.CheckLossCut(iVolume : integer; aQuote: TQuote): boolean;
var
  iRes : integer;
  dPrice : double;
begin
  Result := false;

  if iVolume = 0 then Exit;
  if ( aQuote.Bids[0].Price < PRICE_EPSILON )  or ( aQuote.Asks[0].Price < PRICE_EPSILON ) then
    Exit;

  case FLiqIndex of
    0 :  // LossPrice ??..?Ǵ?
      begin
        if iVolume > 0 then
        begin
          Result := CheckPrice( 1, aQuote.Symbol.Spec.Precision, FLossPrice, aQuote.Bids[0].Price );
        end
        // ?ŵ??? ???? ??????..
        else if iVolume < 0 then
        begin
          Result := CheckPrice( -1, aQuote.Symbol.Spec.Precision, FLossPrice, aQuote.Asks[0].Price );
        end;
      end;
    1, 2 :  // Para ?ݴ???ȣ ??..basePrice ?? ?Ǵ?
      begin
        if iVolume > 0 then
        begin
          Result := CheckPrice( 1, aQuote.Symbol.Spec.Precision, FBasePrice, aQuote.Bids[0].Price );
        end
        // ?ŵ??? ???? ??????..
        else if iVolume < 0 then
        begin
          Result := CheckPrice( -1, aQuote.Symbol.Spec.Precision, FBasePrice, aQuote.Asks[0].Price );
        end;

      end;
    else Exit;
  end;   

 {

  case FLiqIndex of
    0 : dPrice  := FLossPrice;
    else dPrice := FBasePrice;
  end;

  if FPosType = ptLong then
  begin
    Result := CheckPrice( 1, aQuote.Symbol.Spec.Precision, dPrice, aQuote.Bids[0].Price );
  end
  // ?ŵ??? ???? ??????..
  else if FPosType = ptShort  then
  begin
    Result := CheckPrice( -1, aQuote.Symbol.Spec.Precision, dPrice, aQuote.Asks[0].Price );
  end;
    }

end;

function TBHultOrderSlots.CheckLossCut2(iVolume: integer;aQuote: TQuote): boolean;
var
  iRes : integer;
begin
  Result := false;

  if iVolume = 0 then Exit;

  if ( aQuote.Bids[0].Price < PRICE_EPSILON )  or ( aQuote.Asks[0].Price < PRICE_EPSILON ) then
    Exit;

  case FLiqIndex of
    2 :  // LossPrice ??..?Ǵ?
      begin
        if iVolume > 0 then
        begin
          Result := CheckPrice( 1, aQuote.Symbol.Spec.Precision, FLossPrice, aQuote.Bids[0].Price );
        end
        // ?ŵ??? ???? ??????..
        else if iVolume < 0 then
        begin
          Result := CheckPrice( -1, aQuote.Symbol.Spec.Precision, FLossPrice, aQuote.Asks[0].Price );
        end;
      end;
  end;
end;

constructor TBHultOrderSlots.Create;
begin
  inherited Create( TBHultOrderSlotItem );
  FIsFirst  := true;
  FLiqIndex := 0;
  FLastSlot := nil;
end;

destructor TBHultOrderSlots.Destroy;
begin

  inherited;
end;


function TBHultOrderSlots.GetLastSlot: TBHultOrderSlotItem;
begin
  if Count <= 0 then
    Result  := nil
  else
    Result  := Items[Count-1] as TBHultOrderSlotItem;
end;

function TBHultOrderSlots.GetOrderSlot(i: integer): TBHultOrderSlotItem;
begin
  if ( i< 0 ) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as  TBHultOrderSlotItem;
end;


function TBHultOrderSlots.New: TBHultOrderSlotItem;
begin
  Result := Add as TBHultOrderSlotItem;
  FLastSlot := Result;
end;

procedure TBHultOrderSlots.OnQuote( aQuote: TQuote);
var
  I, iSide, iRes : Integer;
  aSlot : TBHultOrderSlotItem;
  bLiq  : boolean;
  dLast : double;
  aType : TPositionType;
  cmpPrice : double;
begin

  if FDone then Exit;

  dLast := aQuote.Symbol.Last;

  if (FBasePrice < PRICE_EPSILON) or ( dLast < PRICE_EPSILON ) then
  begin
    gEnv.EnvLog( WIN_BHULT, 'No Setting Basee price');
    Exit;
  end;

  iSide := GetQuoteSide( aQuote );

  if iSide = 0 then Exit;

  if iSide > 0 then
    aType := ptLong
  else
    aType := ptShort;  

  if aQuote.Symbol.ShortCode[1] = '3' then
  begin
    if aType = FPosType then Exit;
  end
  else begin
    if aType <> FPosType then  Exit;
  end;

  for I := 0 to Count - 1 do
  begin
    aSlot := GetOrderSlot( i );
    if aSlot.IsOrder[aType] then  continue;      

    // û?? ?ֹ?
    if aSlot.OrderDiv[aType] = '2' then
    begin
      // ????, ????, ?????? ?ܰ???ŭ
      //aSlot.Price, -1 , '2'
      FDone  := true;
      if (Assigned( FBHultOrderEvent )) and ( FOrdCount < FMaxOrdCnt )  then
      begin
        FBHultOrderEvent( aSlot.Price[aType], -iSide, aSlot.OrderDiv[aType] );
        inc( FOrdCount );
        gEnv.EnvLog( WIN_BHULT, Format( '%d ??° %s ?ֹ? ?????´?  : %.2f -> %.2f (%d | %d ) ',  [
            aSlot.index, ifThenStr( iSide > 0, '?ż?','?ŵ?'), FBasePrice, aSlot.Price[aType],
            FOrdCount, FMaxOrdCnt
            ])  );
      end;
    end
    // ġ?? ?ֹ?
    else begin     

      if iSide > 0 then
        iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, aQuote.Asks[0].Price, aSlot.Price[aType] )
      else
        iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, aSlot.Price[aType], aQuote.Bids[0].Price );

      if iRes >= 0 then
      begin
        //aQuote.Asks[3].Price, 1, '1'
        if (Assigned( FBHultOrderEvent )) and ( FOrdCount < FMaxOrdCnt ) then
        begin
          if iSide > 0  then
            FBHultOrderEvent( aQuote.Asks[3].Price, iSide, aSlot.OrderDiv[aType] )
          else
            FBHultOrderEvent( aQuote.Bids[3].Price, iSide, aSlot.OrderDiv[aType] );

          //FBHultOrderEvent( aSlot.Price[aType], iSide, aSlot.OrderDiv[aType] );
          aSlot.IsOrder[aType]  := true;
          inc( FOrdCount );

          gEnv.EnvLog( WIN_BHULT, Format( '%d ??° %s ?ֹ? : %.2f -> %.2f,  (%d | %d )',  [
            aSlot.index, ifThenStr( iSide > 0, '?ż?','?ŵ?'), FBasePrice, dLast,
            FOrdCount, FMaxOrdCnt
            ])  );
          break;
        end;
        // ?ֹ?
      end
      else begin
        break;
      end;

    end;
  end;
end;

function TBHultOrderSlots.GetQuoteSide( aQuote : TQuote ) : integer;
var
  iRes  : integer;
begin
  Result := 0;

  iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, aQuote.Bids[0].Price , FBasePrice );

  if iRes > 0 then
    Result := 1
  else begin
    iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, FBasePrice, aQuote.Asks[0].Price );
    if iRes > 0 then
      Result := -1;
  end;

end;

procedure TBHultOrderSlots.Reset;
begin
  Clear;
  FBasePrice  := 0;
  //FSide       := 0;
  FDone       := false;
  FLossCut    := false;
  FMaxOrdCnt  := 0;
  FOrdCount   := 0;
  FLossPrice  := 0;
  FLastSlot := nil;
end;

procedure TBHultOrderSlots.SetSide(const Value: integer);
begin
  FSide := Value;
  if FSide > 0 then
    FPosType := ptLong
  else
    FPosType := ptShort;
end;

end.
