unit ClePrevHighLow;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, ClePositions, CleQuoteBroker,  CleOrders,  CleFills,

  CleDistributor ,  CleStrategyStore, CleQuoteTimers,   CleOrderBeHaivors,

  CleOrderConsts, GleTypes

  ;
type

  TPrevHLOrderType = ( phlNone, phlEntry, phlLiquid, phlLossCut );

  TPrevHLOrder = class( TOrderBeHaivor )
  public
    OrderType : TPrevHLOrderType;
    Constructor Create( aColl : TCollection ); override;
  end;

  TPrevHLOrders = class( TCollection )
  private
    function GetHLOrder(i: integer): TPrevHLOrder;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aOrder : TOrder ) : TPrevHLOrder;
    function Find( aOrder : TOrder ): TPrevHLOrder;

    Procedure Reset;
    procedure BeHaivorEvent( Sender : TObject; aOrder : TOrder );
    procedure AllCancel;
    procedure EntryAllCancel;
    property HLOrder[ i : integer] : TPrevHLOrder read GetHLOrder; default;
  end;

  TPrevHLs = class;

  TPrevHLSymbol = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FPosition: TPosition;
    FColl   :    TPrevHLs;
    FPrevHLOrders: TPrevHLOrders;


    FOrderEvent: TResultNotifyEvent;
    FNumber: integer;
    FMain: boolean;
    FLossCut : boolean;
    procedure SaveStatus;
    procedure ArrangeOrder;


    procedure DoLiquid( aHLOrder : TPrevHLOrder; aOrder : TOrder );
    procedure DoLossCut;
    function CheckOrderExist(aQuote: TQuote; var iQty: integer): boolean;
    procedure CancelEntryOrder;
    function IsLossCut: boolean;

  public

    FStatus : array [TNavi] of TPrevHLStatus;

    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;

    procedure CheckTime(aQuote: TQuote);    //

    procedure OnQuote( aQuote : TQuote );
    procedure OnOrder( aOrder : TOrder );
    procedure DoOrder( aQuote : TQuote; bFlag : boolean = true );
    procedure OnPosition( aPos : TPosition );

    property Account : TAccount read FAccount write FAccount;
    property Position : TPosition read FPosition write FPosition;
    property Symbol : TSymbol read FSymbol write FSymbol;

    property PrevHLOrders : TPrevHLOrders read FPrevHLOrders write FPrevHLOrders;
    property OrderEVent   : TResultNotifyEvent read FOrderEvent write FOrderEvent;

    property Main : boolean read FMain write FMain;
    property Number : integer read FNumber write FNumber;
  end;

  TPrevHLs  = class( TCollection )
  private
    FParam: TPrevHLParam;
    function GetPrevHL(i: integer): TPrevHLSymbol;

    procedure SetQty( iQty : integer );
    procedure SetLiquidSec( iSec : integer );
    procedure SetEntrySec( iSec : integer );
    procedure SetMaxCount( iQty : integer );
    procedure SetLossCutTick(iQty: integer);

  public
    Constructor Create;
    Destructor  Destroy; override;
    function new( aSymbol : TSymbol ) : TPrevHLSymbol;

    procedure SetParam( iTag, iVal : integer );

    property PrevHL[ i : integer] : TPrevHLSymbol read GetPrevHL;
    property Param : TPrevHLParam read FParam write FParam;
  end;


implementation

uses
  Ticks, GAppEnv, GleLib, CleKrxSymbols, GleConsts
  ;

{ TPrevHLSymbol }

procedure TPrevHLSymbol.CheckTime(aQuote: TQuote);
var
  dtNow : TDateTime;
begin
  dtNow := Frac( GetQuoteTime );

  with FColl.Param do
    if (Frac( StartTime ) <= dtNow) and  ( Frac( EndTime ) > dtNow ) then
      OnQuote( aQuote );
end;

constructor TPrevHLSymbol.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FColl  := aColl as TPrevHLs;

  FPrevHLOrders:= TPrevHLOrders.Create;

  FStatus[ Last ].Reset;
  FStatus[ Prev ].Reset;

  FNumber:=0;
  FMain:= false;
  FLossCut :=false;
end;

destructor TPrevHLSymbol.Destroy;
begin
  FPrevHLOrders.Free;
  inherited;
end;

procedure TPrevHLSymbol.DoLiquid(aHLOrder: TPrevHLOrder; aOrder: TOrder);
var
  iQty, i, iCnt : integer;
  aFill : TFill;
  pOrder : TOrder;
  dPrice : double;
  aQuote : TQuote;
  aTicket: TOrderTicket;
  aHL : TPrevHLOrder;
begin
  aFill := aOrder.Fills.Fills[ aOrder.Fills.Count-1 ];
  if aFill = nil then Exit;

  iQty := abs(aFill.Volume);
  if aOrder.Side > 0 then  iQty := iQty * -1;
  aQuote := aOrder.Symbol.Quote as TQuote;

  if aOrder.Side > 0 then
    dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, 1 )
  else
    dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, -1 );

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stTodarke);
  pOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, Symbol, iQty , pcLimit, dPrice, tmGTC, aTicket );

  if pOrder <> nil then
  begin
    pOrder.OrderSpecies := opTodarke;
    gEnv.Engine.TradeBroker.Send( aTicket );

    gLog.Add( lkDebug, 'TPrevHLSymbol','DoLiquid', format('%s, %s, %s, %d, %.2f', [
      Account.Code, Symbol.ShortCode,       ifThenStr( pOrder.Side > 0 ,'매수', '매도'),
      pOrder.OrderQty, pOrder.Price
      ])  );

    aHL := PrevHLOrders.New( pOrder );
    aHL.OrderType := phlLiquid;
    aHL.NewOrder( pOrder, bpMarket, bcAtSec, FColl.Param.LiqSec );
  end;

end;

procedure TPrevHLSymbol.DoLossCut;
var
  aTicket : TOrderTicket;
  aOrder, pOrder  : TOrder;
  dPrice  : double;
  iQty    : integer;
  aDepths : TMarketDepths;

  aQuote  : TQuote;
  aHLOrder: TPrevHLOrder;
begin

  iQty  := Position.Volume * -1;
  if iQty = 0 then Exit;

  aQuote := Symbol.Quote as TQuote;

  if Position.Volume > 0 then
    aDepths := aQuote.Bids
  else
    aDepths := aQuote.Asks;

  dPrice  := aDepths[2].Price;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stTodarke);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, Symbol, iQty , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opTodarke;
    gEnv.Engine.TradeBroker.Send( aTicket );

    gLog.Add( lkDebug, 'TPrevHLSymbol','DoLossCut', format('%s, %s, %s, %d, %.2f', [
      Account.Code, Symbol.ShortCode,       ifThenStr( aOrder.Side > 0 ,'매수', '매도'),
      aOrder.OrderQty, aOrder.Price
      ])  );

    aHLOrder := PrevHLOrders.New( aOrder );
    aHLOrder.OrderType := phlLossCut;

    aHLOrder.NewOrder( aOrder, bpMarket, bcStandBySec, 100 );
    FLossCut := true;
  end;
  // 손절 주문 낸후 나가 있는 주문 취소..
  PrevHLOrders.AllCancel;

end;

procedure TPrevHLSymbol.DoOrder(aQuote: TQuote; bFlag: boolean);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  dPrice  : double;
  iQty, iSec    : integer;
  aHLOrder : TPrevHLOrder; 

begin

  iQty  := FColl.Param.Qty;
  dPrice  := ifThenFloat( FStatus[Prev].Side > 0 , aQuote.Bids[0].Price, aQuote.Asks[0].Price );

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stTodarke);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, Symbol, iQty * FStatus[Prev].Side , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opPrevHL;
    gEnv.Engine.TradeBroker.Send( aTicket );

    gLog.Add( lkDebug, 'TPrevHLSymbol','DoOrder', format('%s, %s, %s, %d, %.2f', [
      Account.Code, Symbol.ShortCode,       ifThenStr( aOrder.Side > 0 ,'매수', '매도'),
      aOrder.OrderQty, aOrder.Price
      ])  );


    aHLOrder  := PrevHLOrders.New( aOrder );
    aHLOrder.OrderType  := phlEntry;
    aHLOrder.NewOrder( aOrder, bp1Hoga, bcAtSec, 59 );
    aHLOrder.BeHaiverType := btCancel;
  end;

end;

procedure TPrevHLSymbol.OnOrder(aOrder: TOrder);
var
  aHLOrder  : TPrevHLOrder;
  stLog     : string;
begin
  aHLOrder  := PrevHLOrders.Find( aOrder );
  if aHLOrder = nil then
  begin
    gLog.Add( lkDebug,'TPrevHLSymbol','OnOrder', format('Not Find Order : %s', [ aOrder.Represent2 ] ));
    Exit;
  end;

  case aHLOrder.OrderType of
    phlNone: Exit;
    phlEntry: begin stLog := 'Entry'; DoLiquid( aHLOrder, aOrder ); end;
    phlLiquid: stLog := 'Liquid';
    phlLossCut:
      begin
        stLog := 'LossCut';
        if (FLossCut ) and ( aOrder.State = osFilled ) and ( Position.Volume = 0 ) then
          FLossCut := false;
      end ;
  end;

  gLog.Add( lkDebug, 'TPrevHLSymbol','OnOrder', format('%s fill : %s', [ stLog, aOrder.Represent2]) );
  ArrangeOrder;
end;

procedure TPrevHLSymbol.ArrangeOrder;
var
  I: Integer;
  aHLOrder  : TPrevHLOrder;
begin
  for I :=  PrevHLOrders.Count - 1 downto 0 do
  begin
    aHLOrder := PrevHLOrders.HLOrder[i];
    if (not aHLOrder.Run ) and ( aHLOrder.CheckOrders.Count = 0 ) then
      PrevHLOrders.Delete( i );
  end;
end;

procedure TPrevHLSymbol.OnPosition(aPos: TPosition);
begin
  Position := aPos;
end;

procedure TPrevHLSymbol.SaveStatus;
begin
  FStatus[Prev].Reset;
  FStatus[Last].Reset;
  if Position <> nil then
    FStatus[Last].PL := Position.EntryPL;
end;

function TPrevHLSymbol.IsLossCut : boolean;
var
  dPrice ,dCon,  dGap : double;
  bLong : boolean;
  aQuote : TQuote;
  ilv : integer;
begin
  Result := false;
  if Position.Volume = 0 then exit;
  if Position.Volume > 0 then
    bLong := true
  else
    bLong := false;

  dPrice  := 0;
  dGap    := 0;

  dCon := Symbol.Spec.TickSize * FColl.Param.LossCutTick;

  dPrice:= Symbol.Last;

  ilv := 1;
  aQuote  := Symbol.Quote as TQuote;

  if bLong then
  begin
    dGap  := Position.AvgPrice - dPrice;
    if dGap > dCon + PRICE_EPSILON  then
      Result := true;
  end
  else begin
    dGap  := dPrice - Position.AvgPrice;
    if dGap > dCon + PRICE_EPSILON  then
      Result := true;
  end;

  if not Result then
  begin
    ilv := 2;

    dCon := Symbol.Spec.TickSize ;

    if bLong then
    begin
      dPrice  := aQuote.Bids[0].Price;
      dGap  := Position.AvgPrice - dPrice;
      if (dGap > dCon + PRICE_EPSILON)  and
        (aQuote.Bids[0].Volume < aQuote.Asks[0].Volume ) and
        (aQuote.Bids[0].Volume < FColl.Param.Volume ) then
        Result := true;
    end
    else begin
      dPrice  := aQuote.Asks[0].Price;
      dGap  := dPrice - Position.AvgPrice;
      if (dGap > dCon + PRICE_EPSILON) and
        ( aQuote.Asks[0].Volume < aQuote.Bids[0].Volume ) and
        ( aQuote.Asks[0].Volume < FColl.Param.Volume )  then
        Result := true;
    end;
  end;

  if Result then
  begin
    gLog.Add( lkDebug, 'TPrevHLSymbol','IsLossCut',
      format('lv:%d %s손절 avg:%.2f, %.2f(%d), %.2f, %.2f(%d)', [ iLv, ifThenStr( bLong,'매수','매도'),
        Position.AvgPrice,  aQuote.Asks[0].Price, aQuote.Asks[0].Volume,  aQuote.Last,
        aQuote.Bids[0].Price, aQuote.Bids[0].Volume ])
     );
  end;

end;

procedure TPrevHLSymbol.OnQuote(aQuote: TQuote);
var
  i, iSec, iQty : integer;
  aTerm : TSTermItem;
begin

  if (Position <> nil) and (IsLossCut) and ( not FLossCut ) then
  begin
    DoLossCut;
    Exit;
  end;

  for I := 0 to FPrevHLOrders.Count - 1 do  FPrevHLOrders.HLOrder[i].OnQuote( aQuote );
  iSec  := Secondof( GetQuoteTime );

  if ( iSec in [FColl.Param.EntrySec..59] ) then
  else if ( iSec in [10..11] ) then begin SaveStatus; exit; end
  else Exit;

  i := aQuote.Terms.Count-2;  if i<0 then Exit;
  aTerm := aQuote.Terms.XTerms[i];

  if aTerm.IsPlus <> aQuote.Terms.LastTerm.IsPlus  then begin
    gLog.Add( lkDebug, 'TPrevHLSymbol','OnQuote', format('직전%s봉 현재%s봉', [
      ifThenStr( aTerm.IsPlus ,'양','음') , ifThenStr( aQuote.Terms.LastTerm.IsPlus ,'양','음') ]) );
    Exit;
  end;

  if (aTerm.H + 0.001) < aQuote.Last  then
    FStatus[Last].Side  := 1
  else if aTerm.L > (aQuote.Last+0.001) then
    FStatus[Last].Side  := -1
  else
    FStatus[Last].Side  := 0;

  if FStatus[Last].Side <> 0 then FStatus[Last].Occured := true
  else Exit;

  if FStatus[Last].Second = iSec then if FStatus[Last].Count > 1 then
  begin
    gLog.Add( lkDebug, 'TPrevHLSymbol','OnQuote', format('주문개수제한 %d, %d', [ FStatus[Last].Second , FStatus[Last].Count  ]) );
    Exit;
  end else FStatus[Last].Count := 0;

  if FLossCut then Exit;

  if  Position <> nil  then
  begin
    if Position.EntryOTE < 0 then begin
      //gLog.Add( lkDebug, 'TPrevHLSymbol','OnQuote', format('평가손익 마이너스 %.0f, %d', [ Position.EntryOTE, iSec ]) );
      Exit;
    end;
    if (iSec >= 58 ) and ( FStatus[Last].PL >= Position.EntryPL ) then  begin
      //gLog.Add( lkDebug, 'TPrevHLSymbol','OnQuote', format('실현손익 마이너스 %.0f >= %.0f, %d', [ FStatus[Last].PL ,Position.EntryPL, iSec ]) );
      Exit;
    end;
  end
  else if iSec >= 59 then Exit;

  if ( FStatus[Last].Side > 0 ) and ( FStatus[Last].Price > 0 ) then
  begin
    if (aQuote.Bids[0].Price + 0.001) < FStatus[Last].Price then
      Exit;
  end
  else if ( FStatus[Last].Side < 0 ) and ( FStatus[Last].Price > 0 ) then
  begin
    if (aQuote.Asks[0].Price > ( FStatus[Last].Price + 0.001 )) then
      Exit;
  end;

  iQty := 0;
  if CheckOrderExist( aQuote, iQty ) then Exit;
  if iQty  >= FColl.Param.MaxOrderCnt then
    CancelEntryOrder;

  FStatus[Last].Second := iSec;
  FStatus[Last].Count  := FStatus[Last].Count + 1;
  FStatus[Prev].Assign( FStatus[Last] );
  gLog.Add( lkDebug, 'TPrevHLSymbol','OnQuote', FStatus[last].GetDesc  );

  if Assigned( FOrderEvent ) then
    FOrderEvent( self, true );

end;


function TPrevHLSymbol.CheckOrderExist( aQuote : TQuote; var iQty : integer): boolean;
var
  I, j, iCnt: Integer;
  aHL : TPrevHLORder;
  aOrder  : TOrder;
  dPrice  : double;
begin
  Result := false;

  //ArrangeOrder;
  // 주문이 1호가 나가 있으면 exit;
  dPrice  := ifThenFloat( FStatus[Last].Side > 0 , aQuote.Bids[0].Price, aQuote.Asks[0].Price );

  for I := 0 to PrevHLOrders.Count - 1 do
  begin
    aHL := PrevHLOrders.HLOrder[i];

    for j := 0 to aHL.CheckOrders.Count - 1 do
    begin
      aOrder  := aHL.CheckOrders.Orders[j];
      if (aOrder.State in [osReady, osSent, osSrvAcpt,osActive] )  and
       ( aOrder.OrderType = otNormal )
      then begin
        if (ComparePrice( aOrder.Symbol.Spec.Precision, aOrder.Price, dPrice ) = 0) then
          Result := true;
        if (aHL.OrderType = phlEntry) and ( aOrder.Side = FStatus[Last].Side ) then
          inc( iQty );
      end;
    end;
  end;
end;

procedure TPrevHLSymbol.CancelEntryOrder;
var
  iTarget, I, j, iCnt: Integer;
  aHL : TPrevHLOrder;
  aOrder  : TOrder;
  dPrice  : double;
begin

  iTarget := -1;

  if FStatus[prev].Side > 0 then
    dPrice  := 500
  else
    dPrice  := 0;

  for I := 0 to PrevHLOrders.Count - 1 do
  begin
    aHL := PrevHLOrders.HLOrder[i];

    for j := 0 to aHL.CheckOrders.Count - 1 do
    begin
      aOrder  := aHL.CheckOrders.Orders[j];
      if (aOrder.State in [osReady, osSent, osSrvAcpt,osActive] )  and
       ( aOrder.OrderType = otNormal )
      then begin
              if (aHL.OrderType = phlEntry) and ( aOrder.Side = FStatus[prev].Side ) then
              begin
                if FStatus[prev].Side > 0 then begin
                  if aOrder.Price < dPrice then begin
                    iTarget  := i;
                    dPrice   := aORder.Price;
                  end;
                end
                else begin
                  if aOrder.Price > dPrice then begin
                    iTarget := i;
                    dPrice  := aOrder.Price;
                  end;
                end;
              end;
      end;
    end;
  end;

  if iTarget >= 0 then
  begin
    aHL :=  PrevHLOrders.HLOrder[iTarget];
    if aHL <> nil then begin
      aHL.BeHaiverType  := btCancel;
      aHL.BeHaivorCondition :=  bcStandBySec;
      aHL.StandByTime := GetQuoteTime;
      aHL.OnQuote( FSymbol.Quote as TQuote);
      //gEnv.EnvLog( WIN_TEST, '주문개수오버->취소함 ' );
    end;
  end;

end    ;

{ TPrevHLs }

constructor TPrevHLs.Create;
begin
  inherited Create( TPrevHLSymbol );
end;

destructor TPrevHLs.Destroy;
begin

  inherited;
end;

function TPrevHLs.GetPrevHL(i: integer): TPrevHLSymbol;
begin
  if ( i<0 ) or ( i>= Count ) then
    Result := nil
  else
    Result := Items[i] as TPrevHLSymbol;
end;

function TPrevHLs.new(aSymbol: TSymbol): TPrevHLSymbol;
begin
  Result := Add as TPrevHLSymbol;
  Result.Symbol := aSymbol;
end;

procedure TPrevHLs.SetEntrySec(iSec: integer);
begin
  FParam.EntrySec := iSec;
end;

procedure TPrevHLs.SetLiquidSec(iSec: integer);
begin
  FParam.LiqSec := iSec;
end;

procedure TPrevHLs.SetLossCutTick(iQty: integer);
begin
  FParam.LossCutTick  := iQty;
end;

procedure TPrevHLs.SetMaxCount(iQty: integer);
begin
  FParam.MaxOrderCnt  := iQty;
end;

procedure TPrevHLs.SetQty(iQty: integer);
begin
  FParam.Qty  := iQty;
end;

procedure TPrevHLs.SetParam(iTag, iVal : integer);
begin
  case iTag of
    0 : SetQty(iVal);
    1 : SetLiquidSec(iVal);
    2 : SetMaxCount(iVal);
    3 : SetEntrySec(iVal);
    4 : SetLossCutTick(iVal);
    5 : FParam.Volume := iVal;
  end;
end;



{ TPrevHLOrder }

constructor TPrevHLOrder.Create(aColl: TCollection);
begin
  inherited Create(aColl );
  OrderType := phlNone;
end;

{ TPrevHLOrders }

procedure TPrevHLOrders.AllCancel;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if self.GetHLOrder(i).OrderType <> phlLossCut then
    begin
      GetHLOrder(i).BeHaiverType  := btCancel;
      GetHLOrder(i).BeHaivorCondition :=  bcStandBySec;
      GetHLOrder(i).StandByTime := GetQuoteTime;
     // GetHLOrder(i).OnQuote( nil );
    end;
  gLog.Add( lkDebug , 'TPrevHLOrders','AllCancel', '' );
end;

procedure TPrevHLOrders.BeHaivorEvent(Sender: TObject; aOrder: TOrder);
begin

end;

constructor TPrevHLOrders.Create;
begin
  inherited Create( TPrevHLOrder );
end;

destructor TPrevHLOrders.Destroy;
begin

  inherited;
end;

procedure TPrevHLOrders.EntryAllCancel;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetHLOrder(i).OrderType = phlEntry then
    begin
      GetHLOrder(i).BeHaiverType  := btCancel;
      GetHLOrder(i).BeHaivorCondition :=  bcStandBySec;
      GetHLOrder(i).StandByTime := GetQuoteTime;
      GetHLOrder(i).OnQuote( nil );
    end;
  gLog.Add( lkDebug , 'TPrevHLOrders','EntryAllCancel', '' );
end;

function TPrevHLOrders.Find(aOrder: TOrder): TPrevHLOrder;
var
  I: Integer;
begin
  Result := nil;
  for I := Count - 1 downto 0 do
    if GetHLOrder(i).Orders.FindOrder( aOrder.OrderNo )= aOrder then
    begin
      Result := GetHLOrder(i);
      Break;
    end;

end;

function TPrevHLOrders.GetHLOrder(i: integer): TPrevHLOrder;
begin
  if (i<0) or ( i>=Count) then
    result := nil
  else
    result := Items[i] as TPrevHLOrder;
end;

function TPrevHLOrders.New(aOrder: TOrder): TPrevHLOrder;
begin
  Result := Add as TPrevHLOrder;
end;

procedure TPrevHLOrders.Reset;
begin
  Clear;
end;

end.
