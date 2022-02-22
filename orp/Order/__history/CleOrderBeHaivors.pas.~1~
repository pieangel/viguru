unit CleOrderBeHaivors;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, ClePositions , CleQuoteTimers, CleOrders,

  CleQuoteBroker
  ;

type
  TOrderBase = class( TCollectionItem )
  private
    FPosition: TPosition;
    FSymbol: TSymbol;
    FAccount: TAccount;
    FFlash: boolean;
    FNo: integer;
    FTimer: TQuoteTimer;
    FOrders: TOrderList;
    FCheckOrders: TOrderList;  
  public
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    property No     : integer read FNo write FNo;
    property Flash  : boolean read FFlash write FFlash;
    property Position : TPosition read FPosition write FPosition;
    property Account : TAccount read FAccount write FAccount;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property Timer  : TQuoteTimer read FTimer write FTimer;
    property Orders : TOrderList  read FOrders write FOrders;
    property CheckOrders : TOrderList read FCheckOrders write FCheckOrders;
  end;

  // 주문 행동 조건      몇초에,              몇초후 , 상대호가잔량 , 실시간 위치 파악
  TBeHaivorCondition = ( bcAtSec, bcAutoAtSec,bcStandBySec, bcOppQty, bcMyHoga );
  //                     정정,   취소
  TBeHaivorType      = ( btModify, btCancel );

  TBeHaivorPriceType = ( bpLast, bp1Hoga, bp2Hoga, bpOpp1Hoga, bpOpp2Hoga, bpMarket );

  // 주문 던진후..기타 정보들을 부모쪽에서 셋팅해주기 위해
  TOrderBeHaivorEvent = procedure( Sender : TObject; aOrder : TOrder ) of object;

  TOrderBeHaivor = class( TCollectionItem )
  private
    FRun : boolean;
    FBeHaivorCondition: TBeHaivorCondition;
    FOppQty: integer;
    FMyHoga: integer;
    FAtSec: integer;
    FStandByTime: TDateTime;

    FBeHaivorType: TBeHaivorType;
    FStartTime: TDateTime;
    FBeHaivorEvent: TOrderBeHaivorEvent;
    FCheckOrders: TOrderList;
    FOrders: TOrderList;
    FTimer: TQuoteTimer;
    FBeHaivorPriceType: TBeHaivorPriceType;
    FTryCount: integer;
    FValue: integer;
    function CheckCondition( aOrder: TOrder; aObj: TObject): boolean;
    function GetPrice( iSide : integer; aObj : TObject ) : double;
    function GetTypeDesc: string;
  public

    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    property Run : boolean read FRun ;
    property BeHaivorCondition : TBeHaivorCondition  read FBeHaivorCondition write FBeHaivorCondition;
    property BeHaiverType      : TBeHaivorType read FBeHaivorType write FBeHaivorType;
    property BeHaivorPriceType : TBeHaivorPriceType read FBeHaivorPriceType write FBeHaivorPriceType;
    property Value  : integer  read FValue write FValue;
    property StandByTime     : TDateTime read FStandByTime write FStandByTime;
    property StartTime      : TDateTime read FStartTime write FStartTime;

    property AtSec : integer read FAtSec write FAtSec;
    property OppQty    : integer read FOppQty write FOppQty;
    property MyHoga  : integer read FMyHoga write FMyHoga;
    property TryCount: integer read FTryCount write FTryCount;
    property BeHaivorEvent : TOrderBeHaivorEvent read FBeHaivorEvent write FBeHaivorEvent;

    property Timer  : TQuoteTimer read FTimer write FTimer;
    property Orders : TOrderList  read FOrders write FOrders;
    property CheckOrders : TOrderList read FCheckOrders write FCheckOrders;

    function NewOrder( aOrder : TOrder; bpType : TBeHaivorPriceType; bcType: TBeHaivorCondition;
         iValue : integer; iTryCnt : integer = 1 ) : boolean;

    procedure OnTimer( Sender : TObject );
    procedure DoOrder( aOrder: TOrder; aObj: TObject);
    procedure OnQuote( aQuote : TQuote );

    procedure Fin;
  end;

  TOrerBeHaivors  = class( TCollection )
  private
    function GetBeHaivor(i: integer): TOrderBeHaivor;
  public
    constructor Create;
    Destructor  Destroy; override;

    function New : TOrderBeHaivor;
    function findOrder(aOrder: TOrder): boolean;
    procedure Reset;

    property BeHaivor[ i : integer ] : TOrderBeHaivor read GetBeHaivor;
  end;

implementation

uses
  GAppEnv , GleLib

  ;

{ TOrderBase }

constructor TOrderBase.Create(aColl: TCollection);
begin
  inherited;
  FPosition:= nil;
  FSymbol:=   nil;
  FAccount:=  nil;
  FFlash  :=  false;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FOrders := TOrderList.Create;
  FCheckOrders:= TOrderList.Create;
end;

destructor TOrderBase.Destroy;
begin
  FCheckOrders.Free;
  FOrders.Free;
  if FTimer <> nil then
  begin
    FTimer.Enabled  := false;
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  end;
  inherited;
end;

{ TOrderBeHaivor }

constructor TOrderBeHaivor.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FOrders := TOrderList.Create;
  FCheckOrders:= TOrderList.Create;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  TryCount := 0;
end;

destructor TOrderBeHaivor.Destroy;
begin
  FCheckOrders.Free;
  FOrders.Free;
  if FTimer <> nil then
  begin
    FTimer.Enabled  := false;
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  end;
  inherited;
end;

procedure TOrderBeHaivor.DoOrder(aOrder: TOrder; aObj: TObject);
var
  aQuote  : TQuote;
  aTicket : TOrderTicket;
  pOrder  : TOrder;
  dPrice  : double;
begin
  aQuote := aObj as TQuote;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self, aOrder.Ticket.ScreenNum, aOrder.Ticket.StrategyType );
  pOrder  := nil;

  if TryCount = 1 then
  begin
    FBeHaivorPriceType := bpMarket;
    gEnv.EnvLog( WIN_TEST,
      Format('TOrderBeHaivor.DoOrder : 시장가로 TryCnt:%d', [  TryCount])   );
  end;

  case FBeHaivorType of
    btModify:
      begin
        dPrice := GetPrice(aOrder.Side, aObj );

        if ComparePrice( aOrder.Symbol.Spec.Precision, aOrder.Price, dPrice) = 0 then
        begin
          if FBeHaivorCondition = bcStandBySec then
            FStandByTime := IncMilliSecond( FStandByTime, FValue );

          TryCount := TryCount-1;
          gEnv.EnvLog( WIN_TEST,
                  Format('TOrderBeHaivor.DoOrder(%d) : %s, 정정주문 가격동일 %.2f -> %.2f', [  TryCount,
                    FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), aOrder.Price , dPrice]));
          exit;
        end;

        if dPrice > 0.001 then
        begin
          pOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrderEx( aOrder, aOrder.ActiveQty, aOrder.PriceControl,
            dPrice, aOrder.TimeToMarket, aTicket );

        end;
      end ;
    btCancel:pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx( aOrder, aOrder.ActiveQty, aTicket);
  end;

  if pOrder <> nil then
  begin
    pOrder.OrderSpecies := aOrder.OrderSpecies;
    gEnv.Engine.TradeBroker.Send( aTicket );

    if Assigned( FBeHaivorEvent ) then
      FBeHaivorEvent( Self, pOrder );

    gEnv.EnvLog( WIN_TEST,
      Format('TOrderBeHaivor.DoOrder(%d) : %s, %s', [  TryCount,
        FormatDateTime('hh:nn:ss.zzz', GetQuoteTime),  pOrder.Represent2])
    );

    if FBeHaivorCondition = bcStandBySec then
      FStandByTime := IncMilliSecond( FStandByTime, FValue );

    TryCount := TryCount-1;
    FCheckOrders.Add( pOrder );
    FOrders.Add( pOrder );
  end;

end;

procedure TOrderBeHaivor.Fin;
begin
  if (FTimer <> nil ) and ( FRun ) then
  begin
    FTimer.Enabled  := false;
    FRun  := false;
  end;
end;

function TOrderBeHaivor.GetPrice(iSide : integer; aObj : TObject): double;
var
  aQuote : TQuote;
  stLog : string;
begin
  aQuote  := aObj as TQuote;

  case FBeHaivorPriceType of
    bpLast: begin Result := aQuote.Last; stLog := 'Last'; end;
    bp1Hoga:begin Result := ifThenFloat(  iSide > 0, aQuote.Bids[0].Price, aQuote.Asks[0].Price )  ; stLog := '1Hoga'; end;
    bp2Hoga:begin Result := ifThenFloat(  iSide > 0, aQuote.Bids[1].Price, aQuote.Asks[1].Price )  ; stLog := '2Hoga'; end;
    bpOpp1Hoga: begin Result := ifThenFloat(  iSide < 0, aQuote.Bids[0].Price, aQuote.Asks[0].Price ); stLog := 'Opp1Hoga'; end  ;
    bpOpp2Hoga: begin Result := ifThenFloat(  iSide < 0, aQuote.Bids[1].Price, aQuote.Asks[1].Price ); stLog := 'Opp2Hoga'; end  ;
    bpMarket :begin  Result := ifThenFloat(  iSide < 0, aQuote.Bids[4].Price, aQuote.Asks[4].Price ); stLog := 'Market'; end  ;
  end;

  gEnv.EnvLog( WIN_TEST,
    Format('%s , prc:%.2f,  a:%.2f, c:%.2f, b:%.2f ',
    [ stLog, Result, aQuote.Asks[0].Price, aQuote.Last, aQuote.Bids[0].Price ])
  );

end;

function TOrderBeHaivor.NewOrder(aOrder : TOrder; bpType : TBeHaivorPriceType; bcType: TBeHaivorCondition;
         iValue : integer; iTryCnt : integer) : boolean;
begin
  Result := false;

  //if (FTimer = nil ) or ( FTimer.Enabled ) then Exit;

  FBeHaivorPriceType := bpType;
  FBeHaivorCondition := bcType;
  FBeHaivorType      := btModify;

  case FBeHaivorCondition of
    // 정확히 몇초에 실행
    bcAtSec     : FAtSec       := iValue; // 몇초에
    bcAutoAtSec : FAtSec       := iValue; // 자동정정후 몇초에 쳐라..
    // 쳐서 잡는것도 obtStnadBySec 으로 하고 ivalue 는 0 으로 한다.
    // 현재 시간이 FStandByTime 보다 크면 실행
    bcStandBySec: FStandByTime := IncMilliSecond( GetQuoteTime, iValue )  ;  // 몇초후에
    // 상대호가 잔량이 FOppQty 보다 줄어들어들면 실행( 단 내주문 2호가 이상으로 밀리면 바로 실행 )
    bcOppQty:    FOppQty     := iValue;  // 상대호가 잔량
    // 내주문이 FMyHoga 보다 크거나 같으면 실행
    bcMyHoga:     FMyHoga      := iValue;  // 내주문 위치( 1호가에 있는지 2호가에 있는지 )
  end;

  FValue      := ivalue;
  FTryCount   := iTryCnt;
  FStartTime  := GetQuoteTime;

  FTimer.Interval := 200;
  FTimer.OnTimer  := OnTimer;
  FTimer.Enabled  := true;
  FRun  := true;

  gEnv.EnvLog( WIN_TEST,
    Format( 'BeHaivor.NewOrder : %s, type:%d  con:%d, value:%d, %d',
      [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime ),
       integer( FBeHaivorType ),  integer(  FBeHaivorCondition ), iValue,
       aOrder.OrderNo])
  );
  result := true;

  aOrder.Ticket.Tag := 0;
  FCheckOrders.Add( aOrder );
  FOrders.Add( aOrder );
end;

function TOrderBeHaivor.GetTypeDesc : string;
begin
  case FBeHaivorCondition of
    bcAtSec:  Result := 'AtSec';
    bcAutoAtSec: Result := 'AutoAtSec';
    bcStandBySec: Result := 'StandBySec';
    bcOppQty: Result := 'OppQty';
    bcMyHoga: Result := 'MyHoga';
  end;
end;


function TOrderBeHaivor.CheckCondition( aOrder: TOrder; aObj : TObject ) : boolean;
var
  iSec : integer;
  stLog  : string;
  aQuote : TQuote;

  function IsChange : boolean;
  begin
    if aOrder.Side > 0 then
      iSec  := ComparePrice( aQuote.Symbol.Spec.Precision, aOrder.Price, aQuote.Bids[0].Price )
    else
      iSec  := ComparePrice( aQuote.Symbol.Spec.Precision, aQuote.Asks[0].Price, aOrder.Price );

    if (iSec < 0) then
    begin
      Result := true;
      stLog := Format( '%s : %s->%s, %.2f->%.2f ', [  GetTypeDesc,
        FormatDateTime('hh:nn:ss.zzz', GetQuoteTime),  FormatDateTime('hh:nn:ss.zzz', FStartTime),
        aOrder.Price, IfThenFloat( aOrder.Side > 0 , aQuote.Bids[0].Price, aQuote.Asks[0].Price) ]);
    end;
  end;

begin
  Result := false;
  aQuote  := aObj as TQuote;

  case FBeHaivorCondition of
    bcAtSec:
      begin
        iSec  := Secondof( GetQuoteTime );
        if iSec = FAtSec then
          Result := true;
        stLog := Format('AtSec(%d) : now is %s(%s)-%d', [ FAtSec, FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), FormatDateTime('hh:nn:ss.zzz', FStartTime) , aOrder.OrderNo ]);
      end;
    bcAutoAtsec:
      begin
        iSec  := Secondof( GetQuoteTime );
        if iSec = FAtSec then begin
          Result := true;
          stLog := Format('AutoAtSec(%d) : now is %s(%s)-%d', [ FAtSec, FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), FormatDateTime('hh:nn:ss.zzz', FStartTime) , aOrder.OrderNo ]);
        end
        else begin
          Result := IsChange;
          if Result then TryCount := 2;   //하나 올려줘야 치는 주문을 아니낸다
        end;
      end;
    bcStandBySec:
      begin
        if frac( GetQuoteTime ) >= frac( FStandByTime ) then
          Result := true;
        stLog := Format('StandBySec : %s>=%s(%s) ', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), FormatDateTime('hh:nn:ss.zzz', FStandByTime), FormatDateTime('hh:nn:ss.zzz', FStartTime)  ]);
      end;
    bcMyHoga, bcOppQty:
      begin
        Result := IsChange;

        if (FBeHaivorCondition = bcOppQty) and (not Result) then
        begin
          if aOrder.Side > 0 then
            iSec  := aQuote.Asks[0].Volume
          else
            iSec  := aQuote.Bids[0].Volume;

          if iSec < FOppQty then
          begin
            Result := true;
            stLog := Format( 'OppQty : %s->%s, %d(%d)',     [
              FormatDateTime('hh:nn:ss.zzz', GetQuoteTime),  FormatDateTime('hh:nn:ss.zzz', FStartTime),
              iSec, FOppQty
              ]);
          end;
        end;
      end;
  end;

  if Result then
    gEnv.EnvLog(WIN_TEST, 'CheckCondition : '+ ifThenStr(Result,'true  ', 'false  ')+stLog);
end;

procedure TOrderBeHaivor.OnQuote(aQuote: TQuote);
var
  aOrder : TOrder;
  I: Integer;
  bFin, bRes : boolean;
begin
  if not FRun then Exit;
  bFin := true;

  for i := 0 to FCheckOrders.Count - 1 do
  begin
    aOrder  := FCheckOrders.Orders[i];
    if (aOrder.State = osAcTive) and ( aOrder.ActiveQty > 0 ) and
      (not aOrder.Modify) and ( aOrder.OrderType = otNormal ) then
    begin
      aQuote  := aOrder.Symbol.Quote as TQuote;
      if TryCount = 0  then
      begin
        gEnv.EnvLog( WIN_TEST, 'TryCount is 0 왜 체결 안되지');
        Continue;
      end;
      bRes  := CheckCondition( aOrder, aOrder.Symbol.Quote );

      if bRes then
        DoOrder( aOrder, aQuote );

      bFin := false;
    end;  // aOrder.State
  end;

  if (bFin) and ( FCheckOrders.Count = 0) then
  begin
    FRun  := false;
    FTimer.Enabled  := false;
    gEnv.EnvLog( WIN_TEST,
      Format('behaivor close  now:%s %s', [  FormatDateTime('hh:nn:ss.zzz', GetQuoteTime),  FormatDateTime('hh:nn:ss.zzz', FStartTime)])
    );
  end;
end;

procedure TOrderBeHaivor.OnTimer(Sender: TObject);
var
  aQuote : TQuote;
  aOrder : TOrder;
  I: Integer;
  bFin, bRes : boolean;
begin

  if not FRun then Exit;

  for I := FCheckOrders.Count - 1 downto 0 do
  begin
    aOrder := FCheckOrders.Orders[i];

    if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed ] then
    begin
      FCheckOrders.Delete(i);
        gEnv.EnvLog( WIN_TEST,
          format('TOrderBeHaivor.OnTimer2 delete order : %s', [ aOrder.Represent2 ]));
      Continue;
    end;
  end;

  bFin := true;

  for i := 0 to FCheckOrders.Count - 1 do
  begin
    aOrder  := FCheckOrders.Orders[i];
    if (aOrder.State = osAcTive) and ( aOrder.ActiveQty > 0 ) and
      (not aOrder.Modify) and ( aOrder.OrderType = otNormal ) then
    begin
      aQuote  := aOrder.Symbol.Quote as TQuote;
      if TryCount = 0  then
      begin
        gEnv.EnvLog( WIN_TEST, 'TryCount is 0 왜 체결 안되지');
        Continue;
      end;
      bRes  := CheckCondition( aOrder, aOrder.Symbol.Quote );

      if bRes then
        DoOrder( aOrder, aQuote );

      bFin := false;
    end;  // aOrder.State
  end;

  if (bFin) and ( FCheckOrders.Count = 0) then
  begin
    FRun  := false;
    FTimer.Enabled  := false;
    gEnv.EnvLog( WIN_TEST,
      Format('behaivor close  now:%s %s', [  FormatDateTime('hh:nn:ss.zzz', GetQuoteTime),  FormatDateTime('hh:nn:ss.zzz', FStartTime)])
    );
  end;
end;


{ TOrerBeHaivors }

constructor TOrerBeHaivors.Create;
begin
  inherited Create( TOrderBeHaivor );
end;

destructor TOrerBeHaivors.Destroy;
begin

  inherited;
end;

function TOrerBeHaivors.GetBeHaivor(i: integer): TOrderBeHaivor;
begin
  if (i<0) or (i>=Count) then
    Result := nil
  else
    Result := Items[i] as TOrderBeHaivor;
end;

function TOrerBeHaivors.New: TOrderBeHaivor;
begin
  Result := Add as TOrderBeHaivor;
end;

procedure TOrerBeHaivors.Reset;
var
  i : integer;
begin
  for I := 0 to Count - 1 do
    Clear;
end;

function TOrerBeHaivors.findOrder( aOrder : TOrder ) : boolean;
var
  I: Integer;
  aBH : TOrderBeHaivor;
  j: Integer;
begin
  Result := false;

  for I := 0 to Count - 1 do
  begin
    aBH := GetBeHaivor(i);
    for j := 0 to aBH.Orders.Count - 1 do
      if aBH.Orders.Orders[j] = aOrder then
      begin
        Result := true;
        break;
      end;
  end;

end;


end.
