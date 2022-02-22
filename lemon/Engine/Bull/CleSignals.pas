unit CleSignals;

interface

uses
  Classes, SysUtils, Windows,

  CleOrders, CleSymbols, ClePositions,

  GleTypes
  ;

type
  TAutoType = ( atBear, atBull );

  TSignalItem = class( TCollectionITem )
  public
    OrderSide : TPositionType;
    OrderQty  : integer;
    OrderPrice : double;
    Symbol     : TSymbol;
    XSignal    : boolean;   //청산 신호
    {
    FutureAvgPrices : array[TNavi] of Double;           // 선물 평균가
    OptionAvgPrices : array[TNavi] of Double;           // 옵션 평균가
    RealIV : Double;                                    // 내재변동성
    RealDelta : Double;                                 // 델타
    SynFutures : Double;
    OccurTime  : TDateTime;
    }
  end;

  TAutoOrder = class( TCollectionItem )
  private
    FOrder: TOrder;
    FSignal: TSignalItem;
    FAcptTime: TDateTime;
    FEtrySeq: integer;
    FBSend: Boolean;
  public
    property Signal : TSignalItem read FSignal write FSignal;
    property Order  : TOrder read FOrder write FOrder;
    property EtrySeq: integer read FEtrySeq write FEtrySeq;
    property AcptTime : TDateTime read FAcptTime write FAcptTime;
    property BSend    : Boolean read FBSend write FBSend;
  end;

  TAutoOrders = class( TCollection )
  private
    FAutoType: TAutoType;
    function GetAutoOrder(i: integer): TAutoOrder;
  public
    ActOrdQty : array [0..1] of integer;
    Constructor Create;
    Destructor Destroy; override;

    property AutoType : TAutoType read FAutoType write FAutoType;
    property AutoOrders[ i : integer] : TAutoOrder read GetAutoOrder;

    function New( aOrder : TOrder ) : TAutoOrder;
    function CheckSelfFillOrder( aSymbol : TSymbol;  aOrderSide : TPositionType;
      dPrice : Double; iQty : integer ) : boolean;
    function CheckMaxPosition( aPosition  : TPosition; iMaxNet : integer; aOrder : TOrder;var iActive : integer )
      : boolean ;
    function CheckSameSignal( aSymbol : TSymbol;  aOrderSide : TPositionType;
      dPrice : Double; bX : boolean ) : boolean; virtual; abstract;

    procedure CheckOrderState( aOrder : TOrder );
    procedure DeleteOrder ( aAuto : TAutoOrder );
    procedure GetAutoOrderPos( aSymbol : TSymbol );

  end;

implementation

uses GAppEnv, GleLib;

{ TAutoOrders }

function TAutoOrders.CheckMaxPosition(aPosition: TPosition; iMaxNet: integer;
  aOrder: TOrder; var iActive: integer): boolean;
 var
    i, iNet, iPos, iTmp : integer;
    aAuto : TAutoOrder;
    stTxt, stLog, stCode : string;
begin

  stTxt := ifThenStr( FAutoType = atBear , 'Bear', 'Bull');

  Result := false;
  iNet    := 0;

  if aPosition <> nil then begin
    iNet  := aPosition.Volume;
    stCode := aPosition.Symbol.Code;
  end;

  // 미접수 주문 수량  + : 매수주문 , - : 매도주문

  for i := 0 to Count - 1 do
  begin
    aAuto := AutoOrders[i];
    if aAuto = nil then Continue;
    if aPosition <> nil then
      if aPosition.Symbol <> aAuto.Order.Symbol then Continue;

    iTmp := 0;
    case aAuto.Order.State of
      osActive : iTmp := aAuto.Order.ActiveQty;
      osSent, osReady, osSrvAcpt  : iTmp := aAuto.Order.OrderQty;
      else
        Continue;
    end;

    if aAuto.Order.Side = aOrder.Side then
      iActive := iActive + itmp;
    {
    stLog := Format('%s: %s active : %d  Net : %d   %d | %s', [ aAuto.Order.Symbol.Code,
      ifThenStr( aAuto.Order.Side = 1, '매수', '매도'),
      iActive, iNet, aAuto.Order.OrderNo , stCode
      ]);
    gLog.Add( lkDebug, stTxt, 'CheckMaxPosition1', stLog );


     if aAuto.Order.Side > 0 then
       inc(iQty[0], iTmp )
     else
       inc(iQty[1], iTmp );
     }
  end;

  if aOrder.Side < 0 then
    iActive := iActive * (-1);
  // 현재 포지션

  iPos := abs(iNet + iActive );

  {
  stLog := Format('%s: %s, Max :%d  iPos :%d := abs(%d + %d)', [ aOrder.Symbol.Code,
    ifThenStr( aAuto.Order.Side = 1, '매수', '매도'),
    iMaxNet, iPos, iNet, iActive
    ]);
  gLog.Add( lkDebug, stTxt, 'Ordered', stLog );
  }
  if iPos > iMaxNet then
    Exit
  else
    Result := true;

end;

procedure TAutoOrders.CheckOrderState(aOrder: TOrder);
var
  i : integer;
  aAuto : TAutoOrder;
begin
  for i := Count - 1 downto 0 do
  begin
    aAuto := AutoOrders[i];
    if aAuto = nil then Continue;
    if not aAuto.BSend then Continue;
    if aAuto.Order = aOrder then
    begin
      aAuto.Free;
      break;
    end;
  end;

end;


function TAutoOrders.CheckSelfFillOrder(aSymbol: TSymbol;
  aOrderSide: TPositionType; dPrice: Double; iQty: integer): boolean;
 var
    iActive, i, iSide : integer;
    aAuto : TAutoOrder;
    stSrc, stDest, stLog : string;
    aTicket : TOrderTicket;
    aOrder : TOrder;
begin

  stDest  := Format( '%.*n', [ aSymbol.Spec.Precision, dPrice ] );
  iActive := 0;

  case aOrderSide of
    ptLong: iSide := 1;
    ptShort:iSide := -1 ;
  end;

  for i :=Count - 1 downto 0 do
  begin
    aAuto := AutoOrders[i];
    if aAuto = nil then Continue;
    if not aAuto.BSend then Continue;
    
    if aAuto.Order.State <> osActive then Continue;
    if aSymbol <> aAuto.Order.Symbol then Continue;
    if (iSide + aAuto.Order.Side) <> 0 then Continue;

    stSrc := Format( '%.*n', [ aSymbol.Spec.Precision, aAuto.Order.Price ] );
    // 자전..  1 개 이상 있음 어케하지?.
    if (CompareStr( stSrc, stDest ) = 0) then
    begin
      if aAuto.Order.ActiveQty > 0 then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder(
          aAuto.Order, aAuto.Order.ActiveQty, aTicket );
        if aOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Send( aTicket );             //
          aAuto.Free;

          stLog := Format('%s, %d, %s, %.*n, %d',[
            aAuto.Order.Symbol.ShortCode,
            aAuto.Order.OrderNo,
            ifThenStr( aAuto.Order.Side = 1 , '매수', '매도'),
            aAuto.Order.Symbol.Spec.Precision,
            aAuto.Order.Price,
            aAuto.Order.ActiveQty
            ]);
          gLog.Add( lkDebug, ifThenStr( FAutoType = atBear , 'Bear', 'Bull'), '자전체크', stLog );

        end;
      end;
    end;    // if compare

  end;


end;

constructor TAutoOrders.Create;
begin
  inherited Create( TAutoOrder );
  ActOrdQty[0]  := 0;
  ActOrdQty[1]  := 0;
end;

procedure TAutoOrders.DeleteOrder(aAuto: TAutoOrder);
var
  i :Integer;
  oAuto : TAutoOrder;
begin
  for I := Count -1 downto 0 do
  begin
    oAuto := AutoOrders[i];
    if (oAuto = aAuto) and ( not oAuto.BSend ) then
    begin
      Delete(i);
      break;
    end;
  end;

end;

destructor TAutoOrders.Destroy;
begin

  inherited;
end;

function TAutoOrders.GetAutoOrder(i: integer): TAutoOrder;
begin
  if ( i < 0 ) and ( i >= Count ) then
    Result := nil
  else
    Result  := Items[i] as TAutoOrder;
end;

procedure TAutoOrders.GetAutoOrderPos( aSymbol : TSymbol );
var
  i : integer;
  aAuto : TAutoOrder;
begin
  ActOrdQty[0]  := 0;
  ActOrdQty[1]  := 0;

  for i := Count - 1 downto 0 do
  begin
    aAuto := AutoOrders[i];
    if aAuto = nil then Continue;
    if aAuto.Order = nil then continue;

    if aAuto.Order.Symbol = aSymbol then
    begin
      if aAuto.Order.Side > 0 then
        ActOrdQty[0]  := ActOrdQty[0] + aAuto.Order.ActiveQty
      else
        ActOrdQty[1]  := ActOrdQty[1] + aAuto.Order.ActiveQty;
    end;
  end;

end;

function TAutoOrders.New(aOrder: TOrder): TAutoOrder;
begin
  Result  := Add as TAutoOrder;
  Result.FOrder := aOrder;
  Result.FBSend := false;
end;

end.
