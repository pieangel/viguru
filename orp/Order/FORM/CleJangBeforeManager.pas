unit CleJangBeforeManager;

interface

uses
  Classes, SysUtils,

  CleFrontOrderIF, CleQuoteBroker, CleSymbols, CleOrders, CleFORMConst, CleKrxSymbols,

  GleLib, GleTypes, GleConsts
  ;

type

  TJangBeforeManager = class( TFrontOrderIF )
  private
    FRun: boolean;
    procedure DoOrder; overload;
    procedure DoOrder( dPrice : double; iSeq, iQty , iSide : integer ); overload;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function Start: boolean; virtual;
    procedure Stop; virtual;
    procedure Reset; virtual;
    procedure Observer; virtual;
    procedure SetParam( aParam : TFORMParam ) ;

    property Run : boolean read FRun write FRun;
  end;

implementation

uses
  GAppEnv;


{ TJangBeforeManager }

constructor TJangBeforeManager.Create(aColl: TCollection);
begin
  inherited;
  FRun  := false;
end;

destructor TJangBeforeManager.Destroy;
begin

  inherited;
end;

//Constrols---------------------------------------------------------------------

procedure TJangBeforeManager.Observer;
begin

end;

procedure TJangBeforeManager.Reset;
begin
  //Stop;
end;


function TJangBeforeManager.Start : boolean;
begin
  Result := false;
  {
  if FRun then
  begin
    EnvLog( '실행중!!');
    Exit;
  end;
  }
  if Param.BasePrice < PRICE_EPSILON then
  begin
    EnvLog( Format('기준가 이상 : %f ', [ Param.BasePrice ]));
    Exit;
  end;

  if Param.OrderQty <= 0 then
  begin
    EnvLog( ' 주문 수량 이상 : ' + IntToStr( Param.OrderQty ));
    Exit;
  end;

  if ( Account = nil ) or ( Symbol = nil ) then
  begin
    EnvLog(' 계좌 or 종목 설정이 안됨 ');
    Exit;
  end;

  //FRun  := true;

  EnvLog(' 실행 ');
  DoOrder;

  Result := true;
  EnvLog('Well Done !! ');
  //Stop;

end;

procedure TJangBeforeManager.Stop;
begin

end;

//---------------------------------------------------------------------Constrols


procedure TJangBeforeManager.SetParam(aParam: TFORMParam);
begin
  Param := aParam;
end;

procedure TJangBeforeManager.DoOrder;
var
  AskPrice, BidPrice : double;
  iMod, i : integer;
begin

  //iMod := (AskPrice * 100) mod 5;
  //if iMod > 0 then

  AskPrice  := Param.AskPrice;// Param.AskShift + Param.BasePrice;
  BidPrice  := Param.BidPrice;// Param.BasePrice - Param.BidShift;

  EnvLog( Format('AskPrice : %.2f  , BidPrice : %.2f',
    [ AskPrice, BidPrice ])
    );

  DoOrder( AskPrice, 1, Param.OrderQty, -1 );
  DoOrder( BidPrice, 1, Param.OrderQty, 1 );

  for i := 1 to Param.OrderCnt - 1 do
  begin
    AskPrice := TicksFromPrice( Symbol, AskPrice, Param.OrderGap );
    BidPrice := TicksFromPrice( Symbol, BidPrice, Param.OrderGap * -1 );

    DoOrder( AskPrice, i+1, Param.OrderQty, -1 );
    DoOrder( BidPrice, i+1, Param.OrderQty, 1 );
  end;

  EnvLog( Format('AskPrice : %.2f  , BidPrice : %.2f',
    [ AskPrice, BidPrice ])
    );

end;


procedure TJangBeforeManager.DoOrder( dPrice : double; iSeq, iQty , iSide : integer );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
begin

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, Account, Symbol,
                iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderTimeType  := ManagerType;
    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'Send Order(%d th) : %s, %.2f, %d ',
      [
        iSeq,
        ifThenStr( iSide > 0 , 'L', 'S'),
        dPrice,
        iQty
      ]
      );
    EnvLog( stLog );
  end;

end;


end.
