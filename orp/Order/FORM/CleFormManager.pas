unit CleFormManager;

interface

uses
  Classes, SysUtils,

  CleAccounts, CleSymbols,

  CleOrders ,   ClePositions, CleFORMOrderItems,

  GleTypes, GleConsts
  ;

type



  TFrontManager = class
  private
    FAskOrders: TList;
    FBidOrders: TList;
    FOrderItems: TOrderItems;
    FSelectedItem: TOrderItem;

  public

    FAccount  : TAccount;
    FSymbol   : TSymbol;

    Constructor Create;
    Destructor  Destroy; override;

    property OrderItems : TOrderItems read FOrderItems write FOrderItems;
    property SelectedItem : TOrderItem read FSelectedItem write FSelectedItem;

    procedure DoOrder( aOrder : TOrder );
    procedure ReSet;

    // ?ϰ?????
    function BatchCancel( aAccount: TAccount; aSymbol : TSymbol;
      aCnlType : TBatchCancelType = bctAll ; dPrice : double = 0 ) : boolean;
    function DoCancels( aItem : TOrderItem; iSide : integer ) : boolean; overload;
    function DoCancels( aItem : TOrderItem; iSide, iCount : integer ) : boolean; overload;
    function DoCancels( aItem : TOrderItem; iSide : integer; dPrice : double ) : boolean; overload;
    function DoCancel( aOrder : TOrder ) : boolean;
  end;

implementation

uses
  GAppEnv, GleLib;

{ TFrontManager }

constructor TFrontManager.Create;
begin

  FOrderItems := TOrderItems.Create;
  SelectedItem:= nil;

  FAccount := nil;
  FSymbol  := nil;
end;


destructor TFrontManager.Destroy;
begin
  FOrderItems.Free;
  inherited;
end;

function TFrontManager.DoCancel(aOrder: TOrder): boolean;
var
  aTicket : TOrderTicket;
  pOrder  : TOrder;
  stLog   : string;
begin

  Result := false;
  if aOrder.ActiveQty <= 0 then Exit;

  if aOrder.Modify then Exit;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder(
    aOrder, aOrder.ActiveQty, aTicket );

  if pOrder <> nil then
  begin

    gEnv.Engine.TradeBroker.Send( aTicket );
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

function TFrontManager.DoCancels(aItem: TOrderItem; iSide,
  iCount: integer): boolean;
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
        if ( not aOrder.Modify ) and
           ( aOrder.OrderType = otNormal ) and
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
        if ( not aOrder.Modify ) and
           ( aOrder.OrderType = otNormal ) and
           ( aOrder.ActiveQty > 0 ) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );
        end;
    end;

    if iCnt >= iCount then
      break;
  end;

  if iCnt > 0 then
    Result := true;

end;

function TFrontManager.DoCancels(aItem: TOrderItem; iSide: integer): boolean;
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

  gEnv.EnvLog( WIN_TEST, 'DoCancels : ' + InTToStr( iSu ) );

  for i := 0 to iSu do
  begin
    aOrder := nil;
    bRes   := false;
    if iSide >= 0 then begin
      if i < aItem.BidOrders.Count then
        aOrder  := TOrder( aItem.BidOrders.Items[i] );

      if aOrder <> nil then
        if ( not aOrder.Modify ) and
           ( aOrder.OrderType = otNormal ) and
           ( aOrder.ActiveQty > 0 ) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );

          gEnv.EnvLog( WIN_TEST, Format('DoCancels : %s, %d %d %d %d' ,[ ifThenStr( bRes, '????','????'),
            i, iSu ,iCnt,  aItem.BidOrders.Count]) );
        end;
    end;

    if iSide <= 0 then begin
      aOrder := nil;
      bRes   := false;
      if i < aItem.AskOrders.Count then
        aOrder := TOrder( aItem.AskOrders.Items[i] );

      if aOrder <> nil then
        if ( not aOrder.Modify ) and
           ( aOrder.OrderType = otNormal ) and
           ( aOrder.ActiveQty > 0 ) then
        begin
          bRes := DoCancel( aOrder );
          if bRes then
            inc( iCnt );
        end;
    end;

  end;

  if iCnt > 0 then
    Result := true;

end;

// shift cancel
function TFrontManager.DoCancels(aItem: TOrderItem; iSide: integer;
  dPrice: double): boolean;
var
  i, iCnt : integer;
  aOrder : TOrder;
  bRes : boolean;
begin

  Result := false;  

  iCnt:= 0;

  try

    if iSide = 0  then Exit;

    if iSide < 0 then begin
      for i := 0 to aItem.AskOrders.Count -1 do
      begin
        aOrder := nil;
        bRes   := false;
        aOrder  := TOrder( aItem.AskOrders.Items[i]);
        if aOrder <> nil then
          if (aOrder.Price  < dPrice + PRICE_EPSILON) and
            ( not aOrder.Modify ) and
            ( aOrder.OrderType = otNormal )  then
          begin
            bRes := DoCancel( aOrder );
            if bres  then          
              inc( iCnt );
          end ;      


      end;
    end
    else begin
      for i := 0 to aItem.BidOrders.Count -1 do      
      begin 
        aOrder := nil;
        bRes   := false;
        aOrder  := TOrder( aItem.BidOrders.Items[i]);
        if aOrder <> nil then      
          if (aOrder.Price + PRICE_EPSILON > dPrice) and
            ( not aOrder.Modify ) and
            ( aOrder.OrderType = otNormal )  then
          begin
            bRes := DoCancel( aOrder );
            if bres  then          
              inc( iCnt );
          end ; 
      end;    
    end;

  finally
    if iCnt > 0 then
      Result := true;
  end;  

end;

function TFrontManager.BatchCancel(aAccount: TAccount; aSymbol: TSymbol;
  aCnlType: TBatchCancelType; dPrice: double): boolean;
var
  aItem : TOrderItem;
  iSide : integer;
begin

  Result := false;

  if ( aAccount = nil ) or ( aSymbol = nil ) then
    Exit;

  aItem := FOrderItems.Find( aAccount, aSymbol);
  if aItem = nil then Exit;

  case aCnltype of
    bctAll: iSide := 0;
    bctAskAll, bctAskShift: iSide := -1 ;
    bctBidAll, bctBidShift: iSide := 1 ;
  end;

  case aCnltype of
    bctAll,
    bctAskAll,
    bctBidAll: Result := DoCancels( aItem, iSide );
    bctAskShift,
    bctBidShift:  Result := DoCancels( aItem, iSide, dPrice );
  end;

end;

procedure TFrontManager.DoOrder(aOrder: TOrder);
var
  aItem : TOrderItem;
begin
{
  if (aOrder.Account <> FAccount) or
   (aOrder.Symbol <> FSymbol ) then Exit;
}
  aItem := FOrderItems.New( aOrder.Account, aOrder.Symbol );
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


procedure TFrontManager.ReSet;
var
  i : integer;
  aOrder : TOrder;
begin
  FBidOrders.Clear;
  FAskOrders.Clear;

  if ( FAccount = nil ) or ( FSymbol = nil ) then Exit;

  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];
    if aOrder = nil then Continue;

    if (aOrder.State = osActive)
       and (aOrder.Account = FAccount)
       and (aOrder.Symbol = FSymbol) then
       DoOrder( aOrder );
  end;

end;


end.
