unit CleSheepBuy;

interface

uses
  Classes, SysUtils, DateUtils, Math,

  CleOrderConsts, CleOrderBeHaivors, CleDistributor,

  CleOrders, CleQuoteBroker, CleSymbols, CleQuoteTimers, CleAccounts, ClePositions,

  GleTypes , GleConsts
;

type
  TSheepBuy = class( TCollectionItem )
  private
    FParam: TSheepBuyParam;
    FPut: TOption;
    FCall: TOption;
    FNumber: integer;
    FPutPos: TPosition;
    FCallPos: TPosition;

    function IsReady : boolean;
    function GetPrice(aOpt: TOption; iSide : integer): double;
    function GetQty(aPos : TPosition): integer;
  public
    Constructor Create( aCol : TCollection ) ; override;
    Destructor  Destroy ; override;

    procedure DoOrder( iSide, iQty, iNum : integer; bLiquid : boolean );
    procedure DoLiquid;
    procedure OnPosition( aPos : TPosition );

    property Call  : TOption read FCall;
    property Put   : TOption read FPut;

    property CallPos  : TPosition read FCallPos;
    property PutPos   : TPosition read FPutPos;

  end;

  TSheepBuys = class( TCollection )
  private
    FParam: TSheepBuyParam;
    FAccount: TAccount;
    FNumber: integer;
    FLastPrice: double;
    FOrderQty: array [0..1] of integer;
    FOnLogEvent: TLogEvent;
    procedure SetParam(Value: TSheepBuyParam);
    function GetSheepBuy(i: integer): TSheepBuy;
    procedure SetAccount(const Value: TAccount);
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aCall, aPut : TOption ) : TSheepBuy;
    procedure OnPosition( aPos : TPosition );
    procedure OnQuote( aQuote : TQuote );
    procedure Reset;

    property Param : TSheepBuyParam read FParam write SetParam;
    property Account : TAccount read FAccount write SetAccount;
    property SheepBuy[ i : integer] : TSheepBuy read GetSheepBuy;
    property Number : integer read FNumber write FNumber;
    property LastPrice : double read FLastPrice write FLastPrice;

    property OnLogEvent : TLogEvent read FOnLogEvent write FOnLogEvent;

    procedure DoOrder;
    procedure DoLiquid;
  end;

implementation

uses
  GAppEnv, GleLib
  ;

{ TSheepBuy }

constructor TSheepBuy.Create(aCol: TCollection);
begin
  inherited Create( aCol );
  FCall := nil;
  FPut  := nil;
end;

destructor TSheepBuy.Destroy;
begin

  inherited;
end;

procedure TSheepBuy.DoLiquid;
begin
  if not IsReady then Exit;

end;


function TSheepBuy.GetPrice( aOpt : TOption ; iSide : integer ) : double;
var
  aQuote : TQuote;
begin
  aQuote := aOpt.Quote as TQuote;

  // 매수주문이면 매도 2호가를 주문가격으로..
  if iSide > 0 then
    Result := aQuote.Asks[1].Price
  else
    Result := aquote.Bids[1].Price;
end;

function TSheepBuy.GetQty( aPos : TPosition ) : integer;
var
  aCol : TSheepBuys ;
begin
  Result := 0;
  if aPos = nil then Exit;
  if aPos.Volume = 0 then Exit;

  aCol  := Collection as TSheepBuys;
  case aCol.FParam.LiqType of
    lctClearDivN:  Result   := abs( aPos.Volume ) div aCol.FParam.LiqQty  ;
    lctMinFixNClear: Result := min( aCol.FParam.LiqQty, abs( aPos.Volume )) ;
  end;

  if Result = 0 then
    Result := abs( aPos.Volume );
end;

procedure TSheepBuy.DoOrder( iSide, iQty, iNum : integer; bLiquid : boolean );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  aAccount : TAccount;
begin
  if not IsReady then Exit;

  aAccount := (Collection as TSheepBuys).Account;

  if bLiquid then
    iQty := GetQty( FCallPos );

  if iQty > 0 then
  begin
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self , iNum, stSheepBuy );
    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
      aAccount, FCall, iQty * iSide, pcLimit, GetPrice( FCall, iSide ), tmGTC, aTicket );

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := opSheepBuy;
      gEnv.Engine.TradeBroker.Send( aTicket );

      gLog.Add( lkDebug, 'TSheepBuy','DoOrder', format('Call Order :  %s, %s, %s, %d, %.2f', [
        aAccount.Code, FCall.ShortCode,       ifThenStr( aOrder.Side > 0 ,'매수', '매도'),
        aOrder.OrderQty, aOrder.Price
        ])  );
    end;
  end
  else
      gLog.Add( lkDebug, 'TSheepBuy','DoOrder', format('Call Order failed :  %s, %s, %s, %d', [
        aAccount.Code, FCall.ShortCode,       ifThenStr( iSide > 0 ,'매수', '매도'),
        iQty
        ])  );

  if bLiquid then
    iQty := GetQty( FPutPos );

  if iQty > 0 then
  begin
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, iNum, stSheepBuy );
    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
      aAccount, FPut, iQty * iSide, pcLimit, GetPrice( FPut, iSide ), tmGTC, aTicket );

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := opSheepBuy;
      gEnv.Engine.TradeBroker.Send( aTicket );

      gLog.Add( lkDebug, 'TSheepBuy','DoOrd7er', format('Put  Order :  %s, %s, %s, %d, %.2f', [
        aAccount.Code, FCall.ShortCode,       ifThenStr( aOrder.Side > 0 ,'매수', '매도'),
        aOrder.OrderQty, aOrder.Price
        ])  );
    end;
  end
  else
      gLog.Add( lkDebug, 'TSheepBuy','DoOrder', format('Put Order failed :  %s, %s, %s, %d', [
        aAccount.Code, FCall.ShortCode,       ifThenStr( iSide > 0 ,'매수', '매도'),
        iQty
        ])  );

end;

function TSheepBuy.IsReady: boolean;
var
  aAccount : TAccount;
begin
  Result := false;
  aAccount := (Collection as TSheepBuys).Account;
  if ( FCall = nil ) or ( FPut = nil ) or ( aAccount = nil ) then
    Exit;

  Result := true;
end;


procedure TSheepBuy.OnPosition(aPos: TPosition);
begin
  if aPos.Symbol = FCall then
    FCallPos := aPos;

  if aPos.Symbol = FPut then
    FPutPos  := aPos;
end;

{ TSheepBuys }

constructor TSheepBuys.Create;
begin
  inherited Create( TSheepBuy );
  FLastPrice  := -1;
end;

destructor TSheepBuys.Destroy;
begin

  inherited;
end;

procedure TSheepBuys.DoLiquid;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    GetSheepBuy(i).DoOrder( -1, FParam.Qty, FNumber, true );
end;

procedure TSheepBuys.DoOrder;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    GetSheepBuy(i).DoOrder( 1, FParam.Qty, FNumber, false );

  if FParam.IsUp then  
    FOrderQty[0] := FOrderQty[0] + FParam.Qty
  else
    FOrderQty[1] := FOrderQty[1] + FParam.Qty
end;

function TSheepBuys.GetSheepBuy(i: integer): TSheepBuy;
begin
  if ( i<0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TSheepBuy;
end;

function TSheepBuys.New(aCall, aPut: TOption): TSheepBuy;
begin
  Result := Add as TSheepBuy;
  Result.FPut   := aPut;
  Result.FCall  := aCall;
end;

procedure TSheepBuys.OnPosition(aPos: TPosition);
var
  I: Integer;
begin
  if aPos.Account = FAccount then
    for I := 0 to Count - 1 do
      GetSheepBuy(i).OnPosition( aPos );
end;

procedure TSheepBuys.OnQuote(aQuote: TQuote);
var
  iUp, idx, iGap : integer;
  stList : TStringList;
begin
  if aQuote.Last <= 0.001 then Exit;

  if FLastPrice < 0 then
    FLastPrice := aQuote.Last
  else begin
    iGap := Round( (aQuote.Last - FLastPrice)/ aQuote.Symbol.Spec.TickSize );
    iUp := 0;
    if (FParam.IsUp) and ( iGap > 0 ) and ( iGap >= FParam.FutTick ) then begin
      iUp := 1; idx := 0;
    end
    else if (not FParam.IsUp) and ( iGap < 0 ) and ( abs(iGap) >= FParam.FutTick ) then begin
      iUp := -1; idx := 1;
    end;

    if (iUp <> 0) and ( FOrderQty[idx] < FParam.MaxQty ) then
    begin
      try
        gLog.Add( lkDebug, 'TSheepBuys','OnQuote', Format('New Order : %s, %d = %.2f - %.2f, %d', [
          ifThenStr( FParam.IsUp,'상승','하락'), iGap, aQuote.Last, FlastPrice, FOrderQty[idx]
          ]) );
        DoOrder;

        stList  := TStringList.Create;
        stList.Add( FormatDateTime('hh:nn:ss.zzz', GetQuoteTime) );
        stList.Add( ifThenStr( FParam.IsUp,'상승','하락') );
        stList.Add( Format('%.2f', [ FLastPrice] ));
        stList.Add( Format('%.2f', [ aQuote.Last] ));
        stList.Add( IntToStr(FOrderQty[idx]) );
        FLastPrice := aQuote.Last;

        if Assigned( FOnLogEvent ) then
          FOnLogEvent( stList, stList.Count );
      finally
        stList.Free;
      end;
    end;
  end;
end;

procedure TSheepBuys.Reset;
begin
  FLastPrice  := -1;
  FOrderQty[0]   := 0;
  FOrderQty[1]   := 0;
end;

procedure TSheepBuys.SetAccount(const Value: TAccount);
begin
  FAccount := Value;
end;

procedure TSheepBuys.SetParam( Value: TSheepBuyParam);
begin
  FParam.Assign( Value );
end;

end.
