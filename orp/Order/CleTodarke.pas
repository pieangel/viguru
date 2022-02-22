unit CleTodarke;

interface

uses
  Classes  ,SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,

  CleOrders, CleMarkets, ClePositions, CleStrategyStore, CleQuoteTimers,

  CleOrderBeHaivors, CleOrderConsts, CleFills
  ;
const
  SignCnt = 3;
type

  TTodarkeOrderType = ( totNone, totEntry, totLiquid, totLossCut );

  TTodarkeOrder = class( TOrderBeHaivor )
  public
    //Order : TOrder;
    OrderType : TTodarkeOrderType;
    SignalSec : integer;  //
    Condition : integer;  // 1차 (0.7), 2차 (0.65), 3차 (0.6)
    //OrderBeHaivors : TOrerBeHaivors;

    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;
  end;

  TTodarkeOrders = class( TCollection )
  private
    function GetTodarkeOrder(i: integer): TTodarkeOrder;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aOrder : TOrder ) : TTodarkeOrder;
    function Find( aOrder : TOrder ): TTodarkeOrder;

    Procedure Reset;
    procedure BeHaivorEvent( Sender : TObject; aOrder : TOrder );
    procedure AllCancel;
    procedure EntryAllCancel;
    property TodarkeOrer[ i : integer] : TTodarkeOrder read GetTodarkeOrder; default;
  end;

  TSignCondition = record
    Occured   : boolean;
    Side      : integer; // 매도 수량 2배
    NO        : integer; // 0 일때 liquid 1틱
    OccurCnt  : integer; // 발생조건 카운트 2 이상이면  liquid 2틱

    hitOrder  : boolean; // 52초 진입 1호가에 대놓기 나머진 쳐서 잡음..
    Occur1Min : boolean; // 9시1분전에 3개조건 동시 될경우..수량2배
    OccurNMin : boolean; // 9시1분후에 3개존건 동시 될경우..수량2배

    Move1p    : boolean;

    OccurCross: boolean;

    Second    : integer;
    Price     : double;

    AskCnt, BidCnt : integer;

    Condition : array [0..SignCnt-1] of boolean;
    procedure Reset( bPartReset : boolean = false);
    function GetSignalevel : integer;
    function GetText : string;
    procedure Assign( con : TSignCondition );
  end;

  TSignSec = record
    Second : integer;
    Occured: boolean;
  end;

  TTodarkeSymbol = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FTodarkeOrders: TTodarkeOrders;
    FMain: boolean;
    FNumber: integer;
    FOnOrderEvent: TResultNotifyEvent;

    FLongOccuredCon : array [0..SignCnt-1] of boolean;  // 발생한 신호 저장..중복 방지
    FShortOccuredCon: array [0..SignCnt-1] of boolean;  // 발생한 신호 저장..중복 방지

    FLongOccuredCon2 : array [0..SignCnt-1] of boolean;  // 발생한 신호 저장..중복 방지
    FShortOccuredCon2: array [0..SignCnt-1] of boolean;  // 발생한 신호 저장..중복 방지

    // 매번 리셋..
    FCondition: TSignCondition;
    // 마지막에 난 신호 저장
    FLastCon: TSignCondition;
    // 하루중 젤처음 난 신호...
    FFirstCon: TSignCondition;

    FPosition: TPosition;
    FLossCut: boolean;

    FPL, FOrdPrice   : double;
    FHigh, FLow: double; // 첫신호 이후..고가 or 저자..기록
    FBSaveSignal : boolean;
    FSignalNo : integer; //  1분마다 리셋..신호 강도 변화를 알기위해

    FSignalsec : array [0..1] of integer;

    procedure DoLiquidOrder(aTO: TTodarkeOrder; aOrder: TOrder);
    function IsLossCut: boolean;
    function CheckOrderExist( aQuote : TQuote; var iQty : integer) : boolean;

    procedure CancelEntryOrder;
    procedure DoLossCut;
    procedure SaveSignal;
    procedure OnPrevLowHigh(aQuote: TQuote);
    function CheckCross(aQuote: TQuote): boolean;
    procedure ArrangeOrder;

  public
    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;

    procedure CheckTime(aQuote: TQuote);    //

    procedure OnQuote( aQuote : TQuote );
    procedure OnOrder( aOrder : TOrder );
    procedure DoOrder( aQuote : TQuote; bTodarke : boolean = true );
    procedure OnCross(aQuote: TQuote);
    procedure OnPosition( aPos : TPosition );

    procedure SetCondition( iSide, idx : integer; bCheck : boolean ); overload;
    procedure SetCondition; overload;
    // objects
    property Account : TAccount read FAccount write FAccount;
    property Position : TPosition read FPosition write FPosition;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property TodarkeOrders :  TTodarkeOrders read FTodarkeOrders write FTodarkeOrders;

    // attritbute
    property Main : boolean read FMain write FMain;
    property Number : integer read FNumber write FNumber;   // 전략 엔진에서 필요로 해서..
    property OnOrderEvent :  TResultNotifyEvent read FOnOrderEvent write FOnOrderEvent;
    property Condition : TSignCondition read FCondition write FCondition;
    property LastCon : TSignCondition read FLastCon write FLastCon;
    property FirstCon : TSignCondition read FFirstCon write FFirstCon;
    property LossCut : boolean read FLossCut write FLossCut;
  end;

  TTodarkeSymbols= class( TCollection )
  private
    FParam: TTodarkeParam;
    function GetTodarkeSymbol(i: integer): TTodarkeSymbol;

  public
    Constructor Create;
    Destructor  Destroy; override;

    function new( aSymbol : TSymbol ) : TTodarkeSymbol;

    procedure SetQty( iQty : integer );
    procedure SetLiquidSec( iSec : integer );
    procedure SetIncQty( bUse : boolean );
    procedure SetMaxCount( iQty : integer );
    procedure SetLossCutTick(iQty: integer);
    property TodarkeSymbol [ i : integer] : TTodarkeSymbol  read GetTodarkeSymbol;
    property Param : TTodarkeParam read FParam write FParam;
  end;

implementation

uses
  GAppEnv, GleLib, CleKrxSymbols , GleConsts  , Ticks, Math
  ;

  { TTodarkeOrders }

procedure TTodarkeOrders.AllCancel;
var
  I: Integer;
begin
  gEnv.EnvLog( WIN_TEST,
    Format('all cnl : %d', [ Count] )
  );
  for I := 0 to Count - 1 do
    if self.GetTodarkeOrder(i).OrderType <> totLossCut then
    begin
      GetTodarkeOrder(i).BeHaiverType  := btCancel;
      GetTodarkeOrder(i).BeHaivorCondition :=  bcStandBySec;
      GetTodarkeOrder(i).StandByTime := GetQuoteTime;
    end;
end;

procedure TTodarkeOrders.EntryAllCancel;
var
  I: Integer;
begin
  gEnv.EnvLog( WIN_TEST,
    Format('Entry all cnl : %d', [ Count] )
  );

  for I := 0 to Count - 1 do
    if self.GetTodarkeOrder(i).OrderType = totEntry then
    begin
      GetTodarkeOrder(i).BeHaiverType  := btCancel;
      GetTodarkeOrder(i).BeHaivorCondition :=  bcStandBySec;
      GetTodarkeOrder(i).StandByTime := GetQuoteTime;
    end;
end;

procedure TTodarkeOrders.BeHaivorEvent(Sender: TObject; aOrder: TOrder);
var
  aTO, bTO: TTodarkeOrder;
begin
  if aOrder.OrderType = otChange then
  begin
    bTO := Find( aOrder.Target );
    if bTO = nil then Exit;
    aTO := New( aOrder );
    aTO.OrderType := bTO.OrderType;
    aTO.SignalSec := bTO.SignalSec;
    aTO.Condition := bTO.Condition;
  end;

end;

constructor TTodarkeOrders.Create;
begin
  inherited Create(  TTodarkeOrder );
end;

destructor TTodarkeOrders.Destroy;
begin

  inherited;
end;



function TTodarkeOrders.Find(aOrder: TOrder): TTodarkeOrder;
var
  I: Integer;
begin
  Result := nil;
  for I := Count - 1 downto 0 do
    if GetTodarkeOrder(i).Orders.FindOrder( aOrder.OrderNo )= aOrder then
    begin
      Result := GetTodarkeOrder(i);
      Break;
    end;
end;

function TTodarkeOrders.GetTodarkeOrder(i: integer): TTodarkeOrder;
begin
  if ( i<0 ) or ( i>= Count ) then
    Result := nil
  else
    Result := Items[i] as TTodarkeOrder;
end;

function TTodarkeOrders.New(aOrder: TOrder): TTodarkeOrder;
begin
  Result := Add as TTodarkeOrder;
  //Result.Order := aOrder;
end;

procedure TTodarkeOrders.Reset;
begin
  Clear;
end;

{ TTodarkeOrder }

constructor TTodarkeOrder.Create(aColl: TCollection);
begin
  inherited Create(aColl );
  //Order := nil;
  OrderType := totNone;
  SignalSec := 0;
  Condition := 0;

  //OrderBeHaivors := TOrerBeHaivors.Create;
end;

destructor TTodarkeOrder.Destroy;
begin
  //OrderBeHaivors.Free;
  inherited;
end;

{ TTodarkeSymbol }

constructor TTodarkeSymbol.Create(aColl: TCollection);
var
  i : integer;
begin
  inherited Create( aColl );

  FTodarkeOrders:= TTodarkeOrders.Create;

  for I := 0 to SignCnt - 1 do
  begin
    FShortOccuredCon[i]  := false;
    FLongOccuredCon[i]   := false;
  end;

  FLossCut  := false;    // 손절주문 나갔는지
  FBSaveSignal  := false;// 1분마다 신호 세이브 했는지

  FLastCon.NO   := -1;
  FFirstCon.NO  := -1;
  FSignalNo     := -1;
  FSignalsec[0] := -1;
  FSignalsec[1] := 0;
  FOrdPrice     := 0;
  LastCon.Reset;
  FFirstCon.Reset;
  FPL := 0;
  FHigh := 0; FLow := 10000;
end;

destructor TTodarkeSymbol.Destroy;
begin
  FTodarkeOrders.Free;
  
  inherited;
end;

procedure TTodarkeSymbol.DoOrder(aQuote: TQuote; bTodarke : boolean);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  dPrice  : double;
  iQty, iSec    : integer;
  aColl   : TTodarkeSymbols;
  aHaivor : TOrderBeHaivor;
  aTodark : TTodarkeOrder;
  dtTime1, dtTime2  : TDateTime;

begin
  aColl := Collection as TTodarkeSymbols;

  if LastCon.Occur1Min or LastCon.OccurNMin or (LastCon.Side < 0) then
    iQty  := aColl.Param.Qty * ifthen( aColl.Param.UseIncQTy, 2, 1)
  else
    iQty  := aColl.Param.Qty;

  if LastCon.Side > 0 then begin
    if not LastCon.hitOrder then
      dPrice := aQuote.Bids[0].Price
    else
      dPrice := aQuote.Asks[2].Price;
  end
  else begin
    if not LastCon.hitOrder then
      dPrice := aQuote.Asks[0].Price
    else
      dPrice := aQuote.Bids[2].Price;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stTodarke);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, Symbol, iQty * LastCon.Side , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opTodarke;
    gEnv.Engine.TradeBroker.Send( aTicket );

    gEnv.EnvLog( WIN_TEST,
    Format('%s Order  : %s, %s, %s, %s, %d, %.2f',
      [ ifThenStr( bTodarke, 'Entry', 'Cross'),
      FormatDateTime('hh:nn:ss.zzz', aQuote.LastQuoteTime ),
      Account.Code, Symbol.ShortCode,
      ifThenStr( aOrder.Side > 0 ,'매수', '매도'),
      aOrder.OrderQty, aOrder.Price ]));


      aTodark := TodarkeOrders.New( aOrder );
      aTodark.OrderType := totEntry;
      aTodark.SignalSec := LastCon.Second;
      aTodark.Condition := LastCon.NO;

      if bTodarke then
      begin
        iSec := 57;
        dtTime1 := Frac( GetQuoteTime );
        dtTime2 := EncodeTime( HourOf( GetQuoteTime), MinuteOf( GetQuoteTime ), iSec , 0 );
        if dtTime1 > dtTime2 then
        begin
          gEnv.EnvLog( WIN_TEST, format('시간이상 : %s > %s ',  [ GetTimeStr( dtTime1 ), GetTimeStr(dtTime2)]));
          aTodark.NewOrder( aOrder, bp1Hoga, bcAutoAtSec, 0 );
          aTodark.BeHaiverType  := btCancel;
        end else
          aTodark.NewOrder( aOrder, bp1Hoga, bcAtSec, 57 );
          //aTodark.NewOrder( aOrder, bp1Hoga, bcMyHoga, 0 );
      end
      else // 크로스
        aTodark.NewOrder( aOrder, bpMarket, bcStandBySec, 100 );
  end;

end;

procedure TTodarkeSymbol.DoLiquidOrder( aTO : TTodarkeOrder; aOrder : TOrder );
var
  iQty, i, iCnt : integer;
  aFill : TFill;
  pOrder : TOrder;
  dPrice : double;
  aQuote : TQuote;
  aTicket: TOrderTicket;
  aTodark: TTodarkeOrder;
  aColl  : TTodarkeSymbols;
begin
  aColl := Collection as TTodarkeSymbols;
  if aColl = nil then Exit;
  
  aFill := aOrder.Fills.Fills[ aOrder.Fills.Count-1 ];
  if aFill = nil then Exit;

  iQty := abs(aFill.Volume);
  if aOrder.Side > 0 then
    iQty := iQty * -1;

  aQuote := aOrder.Symbol.Quote as TQuote;

  if aOrder.Side > 0 then
    iCnt  := aQuote.Asks[0].Volume
  else
    iCnt  := aQuote.Bids[0].Volume;

  //if ( aTO.Condition = 0 ) or ( iCnt > 150 ) then
  //begin
    // 1틱 이익 호가에 대놓기..
  if LastCon.OccurCross then
  begin
    // 2틱 이익 호가에 대놓기
    if aOrder.Side > 0 then
      dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, 2 )
    else
      dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, -2 );
  end
  else begin
    if aOrder.Side > 0 then
      dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, 1 )
    else
      dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, -1 );
  end;

  // 체결 안되면 2초에 정정..으로 체결
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stTodarke);
  pOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, Symbol, iQty , pcLimit, dPrice, tmGTC, aTicket );

  if pOrder <> nil then
  begin
    pOrder.OrderSpecies := opTodarke;
    gEnv.Engine.TradeBroker.Send( aTicket );

    gEnv.EnvLog( WIN_TEST,
    Format('Liquid Order  : %s, %s, %s, %s, %d, %.2f',
      [ FormatDateTime('hh:nn:ss.zzz', aQuote.LastQuoteTime ),
      Account.Code, Symbol.ShortCode,
      ifThenStr( pOrder.Side > 0 ,'매수', '매도'),
      pOrder.OrderQty, pOrder.Price ]));

    aTodark := TodarkeOrders.New( pOrder );
    aTodark.OrderType := totLiquid;
    aTodark.SignalSec := aTO.SignalSec;
    aTodark.Condition := aTO.Condition;

    if LastCon.OccurCross then
      aTodark.NewOrder( pOrder, bpLast, bcStandBySec,20000, 2 )
    else
      aTodark.NewOrder( pOrder, bpMarket, bcAtSec, aColl.Param.LiqSec );
  end;
end;

procedure TTodarkeSymbol.DoLossCut;
var
  aTicket : TOrderTicket;
  aOrder, pOrder  : TOrder;
  dPrice  : double;
  iQty    : integer;
  aDepths : TMarketDepths;
  aColl   : TTodarkeSymbols;
  aQuote  : TQuote;
  aTodark: TTodarkeOrder;
begin
  aColl := Collection as TTodarkeSymbols;
  iQty  := Position.Volume * -1;
  if iQty = 0 then Exit;

  aQuote := Symbol.Quote as TQuote;

  if Position.Volume > 0 then
    aDepths := aQuote.Bids
  else
    aDepths := aQuote.Asks;

  dPrice  := aDepths[1].Price;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stTodarke);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, Symbol, iQty , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opTodarke;
    gEnv.Engine.TradeBroker.Send( aTicket );

    gEnv.EnvLog( WIN_TEST,
    Format('Losscut : %s, %s, %s, %s, %d, %.2f',
      [ FormatDateTime('hh:nn:ss.zzz', aQuote.LastQuoteTime ),
      Account.Code, Symbol.ShortCode,
      ifThenStr( aOrder.Side > 0 ,'매수', '매도'),
      aOrder.OrderQty, aOrder.Price ]));

    aTodark := TodarkeOrders.New( aOrder );
    aTodark.OrderType := totLossCut;
    aTodark.SignalSec := 0;
    aTodark.Condition := 0;

    aTodark.NewOrder( aOrder, bpMarket, bcStandBySec, 0 );

    FLossCut := true;
  end;
  // 손절 주문 낸후 나가 있는 주문 취소..
  TodarkeOrders.AllCancel;

end;

procedure TTodarkeSymbol.OnOrder(aOrder: TOrder);
var
  aTO : TTodarkeOrder;
  stLog : string;
begin
  aTO := TodarkeOrders.Find( aOrder );
  if aTO = nil then
  begin
    gEnv.EnvLog( WIN_TEST, format('Not Find Order : %s', [ aOrder.Represent2 ] ));
    Exit;
  end;

  ArrangeOrder;

  case aTO.OrderType of
    totNone: Exit;
    totEntry: begin stLog := 'Entry'; DoLiquidOrder( aTO, aOrder ); end;
    totLiquid: stLog := 'Liquid' ;
    totLossCut:
      begin
        stLog := 'LossCut';
        if (FLossCut ) and (aOrder.State =  osFilled ) and ( Position.Volume = 0 ) then
        begin
          gEnv.EnvLog( WIN_TEST, format('complete LossCut : %s', [ Position.Represent ] ));
          FLossCut := false;
        end;
      end;
  end;

  gEnv.EnvLog( WIN_TEST,
    Format('Fill : %s, %s', [ stLog, aOrder.Represent2])
  );

end;

procedure TTodarkeSymbol.OnPosition(aPos: TPosition);
begin
  Position := aPos;
end;


function TTodarkeSymbol.IsLossCut : boolean;
var
  dPrice ,dCon,  dGap : double;
  bLong : boolean;
  aColl : TTodarkeSymbols;
begin
  Result := false;
  if Position.Volume = 0 then exit;
  if Position.Volume > 0 then
    bLong := true
  else
    bLong := false;

  dPrice  := 0;
  dGap    := 0;

  aColl := Collection as TTodarkeSymbols;
  dCon := Symbol.Spec.TickSize * aColl.FParam.LossCutTick1;

  dPrice:= Symbol.Last;
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

end;

procedure TTodarkeSymbol.SaveSignal;
var
  i : integer;
  stLog : string;
begin
  if FBSaveSignal then Exit;

  for I := 0 to SignCnt - 1 do
  begin
    FLongOccuredCon[i] := FLongOccuredCon2[i] xor FLongOccuredCon[i];
    FShortOccuredCon[i] := FShortOccuredCon2[i] xor FShortOccuredCon[i];
    FShortOccuredCon2[i] := false;
    FLongOccuredCon2[i]  := false;
  end;

  stLog := format ( ' 매도 :  oc1:%s, oc2:%s oc3:%s',  [
    ifThenStr( FShortOccuredCon[0], 'T','F'),ifThenStr( FShortOccuredCon[1], 'T','F'),
    ifThenStr( FShortOccuredCon[2], 'T','F')
    ]);

  stLog := stLog + format ( ' 매수 :   oc1:%s, oc2:%s oc3:%s',  [
    ifThenStr( FLongOccuredCon[0], 'T','F'),ifThenStr( FLongOccuredCon[1], 'T','F'),
    ifThenStr( FLongOccuredCon[2], 'T','F')
    ]);

  FCondition.Reset;
  FSignalNo := -1;
  FSignalsec[0] := -1;
  FSignalsec[1] := 0;
  FOrdPrice := 0;
  //gEnv.EnvLog(WIN_TEST, Format('리셋:%d초에 주문 %d 개 ',  [ FSignalSec[0], FSignalSec[1]]) );
  if Position <> nil then
    FPL := Position.EntryPL
  else
    FPL := 0;

 // gEnv.EnvLog( WIN_TEST, stLog );

  FBSaveSignal  := true;

end;

procedure TTodarkeSymbol.SetCondition;
var
  aColl : TTodarkeSymbols;
  i : integer;
begin
  aColl := Collection as TTodarkeSymbols;

  for I := 0 to SignCnt - 1 do
  begin
    FLongOccuredCon[i]  := not aColl.Param.LongCondition[i];
    FShortOccuredCon[i] := not aColl.Param.ShortCondition[i];
  end;
end;

procedure TTodarkeSymbol.SetCondition(iSide, idx: integer; bCheck: boolean);
begin
  if iSide > 0 then
    FLongOccuredCon[idx] := not bCheck
  else
    FShortOccuredCon[idx]:= not bCheck;

  gEnv.EnvLog( WIN_TEST,
    Format('Setcondition : %d, %d, %s', [ iSide, idx, ifThenStr( bCheck, '중지','실행')])
  );
end;

procedure TTodarkeSymbol.ArrangeOrder;
var
  I: Integer;
  aTO : TTodarkeOrder;
begin
  for I :=  TodarkeOrders.Count - 1 downto 0 do
  begin
    aTO := TodarkeOrders.TodarkeOrer[i];
    if (not aTO.Run ) and ( aTO.CheckOrders.Count = 0 ) then
      TodarkeOrders.Delete( i );
  end;
end;


function TTodarkeSymbol.CheckOrderExist( aQuote : TQuote; var iQty : integer): boolean;
var
  I, j, iCnt: Integer;
  aTO : TTodarkeOrder;
  aOrder  : TOrder;
  dPrice  : double;
begin
  Result := false;

  //ArrangeOrder;
  // 주문이 1호가 나가 있으면 exit;
  dPrice  := ifThenFloat( FCondition.Side > 0 , aQuote.Bids[0].Price, aQuote.Asks[0].Price );

  for I := 0 to TodarkeOrders.Count - 1 do
  begin
    aTO := TodarkeOrders.TodarkeOrer[i];

    for j := 0 to aTO.CheckOrders.Count - 1 do
    begin
      aOrder  := aTO.CheckOrders.Orders[j];
      if (aOrder.State in [osReady, osSent, osSrvAcpt,osActive] )  and
       ( aOrder.OrderType = otNormal )
      then begin
        if (ComparePrice( aOrder.Symbol.Spec.Precision, aOrder.Price, dPrice ) = 0) then
          Result := true;
        if (aTO.OrderType = totEntry) and ( aOrder.Side = FCondition.Side ) then
          inc( iQty );
      end;
    end;
  end;

end;

procedure TTodarkeSymbol.CancelEntryOrder;
var
  iTarget, I, j, iCnt: Integer;
  aTO : TTodarkeOrder;
  aOrder  : TOrder;
  dPrice  : double;
begin

  iTarget := -1;

  if FCondition.Side > 0 then
    dPrice  := 500
  else
    dPrice  := 0;

  for I := 0 to TodarkeOrders.Count - 1 do
  begin
    aTO := TodarkeOrders.TodarkeOrer[i];

    for j := 0 to aTO.CheckOrders.Count - 1 do
    begin
      aOrder  := aTO.CheckOrders.Orders[j];
      if (aOrder.State in [osReady, osSent, osSrvAcpt,osActive] )  and
       ( aOrder.OrderType = otNormal )
      then begin
              if (aTO.OrderType = totEntry) and ( aOrder.Side = FCondition.Side ) then
              begin
                if FCondition.Side > 0 then begin
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
    aTO :=  TodarkeOrders.TodarkeOrer[iTarget];
    if aTO <> nil then begin
      aTO.BeHaiverType  := btCancel;
      aTO.BeHaivorCondition :=  bcStandBySec;
      aTO.StandByTime := GetQuoteTime;
      gEnv.EnvLog( WIN_TEST, '주문개수오버->취소함 ' );
    end;
  end;

end;

procedure TTodarkeSymbol.CheckTime(aQuote: TQuote);
var
  aColl : TTodarkeSymbols;
  dTmp , dtEnd, dtNow : TDateTime;
begin
  aColl := Collection as TTodarkeSymbols;

  dtNow := Frac( GetQuoteTime );
  dtEnd := EncodeTime( 15, 0, 0, 0);

  with aColl.Param do
  begin
    if (Frac( StartTime1 ) <= dtNow) and  ( Frac( EndTime1 ) > dtNow ) then  // 토닥이 타임
      OnQuote(aQuote)
    else if (Frac( EndTime1 ) <= dtNow) and  ( dtEnd > dtNow )  then // 크로스
      OnCross(aQuote );
    //if (Frac( StartTime2 ) <= dtNow) and  ( Frac( EndTime2 ) > dtNow ) then  // 토닥이 타임
    //  OnPrevLowHigh( aQuote );
  end;
end;
procedure TTodarkeSymbol.OnPrevLowHigh( aQuote : TQuote );
var
  aColl : TTodarkeSymbols;
  i, iSec  : integer;
  dt1min, dtNow : TDateTime;
  stLog : string;
  dTmp : double;
  aTerm : TSTermItem;
begin
  Exit;
  aColl := Collection as TTodarkeSymbols;
  iSec  := Secondof( GetQuoteTime );

  if aQuote.AddTerm then
    if (FirstCon.Side <> 0) and ( not FirstCon.Move1p ) then
    begin
      aTerm := aQuote.Terms.XTerms[ aQuote.Terms.Count-2];
      if (FirstCon.Side > 0 ) and ((aTerm.H-aTerm.L) >= 1 ) then
        FFirstCon.Move1p := true
      else if (FirstCon.Side < 0 ) and (abs(aTerm.L-aTerm.H) >= 1 ) then
        FFirstCon.Move1p := true           ;

    end;
end;



function TTodarkeSymbol.CheckCross( aQuote : TQuote ) : boolean;
var
  dGap, dPrice : double;
begin
  result := false;

  if FLastCon.OccurCross then Exit;
  // 첫진입 없음 exit;
  if FirstCon.Side = 0 then Exit;

  if FirstCon.Side > 0 then
    if FHigh < aQuote.High then
      FHigh := aQuote.High;

  if FirstCon.Side < 0 then
    if FLow > aQuote.Low then
      FLow := aQuote.Low;

  dPrice := ifThenFloat( FirstCon.Side > 0 , FHigh, FLow );
  dGap := abs( FirstCon.Price - dPrice );

  if dGap > 1 then
  begin
    FFirstCon.Move1p := true;
    Result := true;
  end;
end;

procedure TTodarkeSymbol.OnCross(aQuote: TQuote);
var
  dPrice, dGap : double;
  iGap : integer;
begin
  if (not FirstCon.Occured) or ( FirstCon.Side = 0) then Exit;

  if (Position <> nil) and (IsLossCut) and ( not FLossCut ) then
  begin
    gEnv.EnvLog( WIN_TEST,
      Format('croos 손절 : %s, %d, avg:%.2f, last:%.2f ', [ Symbol.ShortCode, Position.Volume, Position.AvgPrice, Symbol.Last])
    );
    DoLossCut;
    Exit;
  end;

  if not CheckCross( aQuote ) then Exit;

  if FirstCon.Side > 0 then
    iGap := aQuote.Asks.CntTotal - aQuote.Bids.CntTotal
  else
    iGap := aQuote.Bids.CntTotal - aQuote.Asks.CntTotal;

  if ( iGap >= 0) then
  begin
    gEnv.EnvLog( WIN_TEST,
      Format('Cross 발생 : %.2f -> %.2f  s(%d), l(%d)', [
        FirstCon.Price , ifThenFloat( FirstCon.Side > 0 , FHigh, FLow ),
        aQuote.Asks.CntTotal ,aQuote.Bids.CntTotal ])
    );

    FLastCon.Side := FirstCon.Side * -1;
    FLastCon.Price:= aQuote.Last;
    FLastCon.OccurCross  := true;
    FLastCon.hitOrder    := true;

    gEnv.EnvLog( WIN_TEST,
      Format('LastCon : %s', [FirstCon.GetText])     );
    // 주문
    if Assigned( FOnOrderEvent ) then
      FOnOrderEvent( self, false );
  end;
end;

procedure TTodarkeSymbol.OnQuote(aQuote: TQuote);
var
  aColl : TTodarkeSymbols;
  i, iSec, iQty  : integer;
  dt1min, dtNow : TDateTime;
  stLog : string;
  dTmp : double;
  aTerm : TSTermItem;
begin
  aColl := Collection as TTodarkeSymbols;
  iSec  := Secondof( GetQuoteTime );

  CheckCross( aQuote );

  for I := 0 to TodarkeOrders.Count - 1 do
    TodarkeOrders.TodarkeOrer[i].OnQuote( aQuote );

  if (Position <> nil) and (IsLossCut) and ( not FLossCut ) then
  begin
    gEnv.EnvLog( WIN_TEST,
      Format('손절 : %s, %d, avg:%.2f, last:%.2f ', [ Symbol.ShortCode, Position.Volume, Position.AvgPrice, Symbol.Last])
    );
    DoLossCut;
    Exit;
  end;

  if (iSec in [52..59]) then
  else if iSec in [10, 11] then begin SaveSignal; Exit; end
  else Exit;

  FCondition.Reset( true );
  FBSaveSignal  := false;
  // 매수 신호
  if aQuote.Bids.CntTotal > aQuote.Asks.CntTotal then
  begin
    for I := 0 to ParamCnt - 1 do
      begin
        dTmp := aQuote.Bids.CntTotal * aColl.Param.Condition[i];
        if dTmp >  aQuote.Asks.CntTotal then
        begin
          FCondition.Condition[i] := true;
          FCondition.Side  := 1;
          FCondition.NO    := i;
          FCondition.Occured := true;
          FCondition.Price   := aQuote.Last;
          FCondition.AskCnt  := aQuote.Asks.CntTotal;
          FCondition.BidCnt  := aquote.Bids.CntTotal;
          inc(FCondition.OccurCnt);
        end
        else break;
      end;
    end
  // 매도 신호
  else if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal then
  begin
    for I := 0 to ParamCnt - 1 do
    begin
      dTmp := aQuote.Asks.CntTotal * aColl.Param.Condition[i];
      if dTmp >  aQuote.Bids.CntTotal then
      begin
        FCondition.Condition[i]    := true;
        FCondition.Side  := -1;
        FCondition.NO    := i;
        FCondition.Occured := true;
        FCondition.Price   := aQuote.Last;
        FCondition.AskCnt  := aQuote.Asks.CntTotal;
        FCondition.BidCnt  := aquote.Bids.CntTotal;
        inc(FCondition.OccurCnt);
      end
      else break;
    end;
  end;

  if FCondition.Occured then
  begin
    // 같은 신호 ... exit
    if (FCondition.Side > 0) then begin
      if FLongOccuredCon[ FCondition.NO ] then Exit;
    end else
    if ( FCondition.Side < 0 ) then  begin
      if FShortOccuredCon[ FCondition.NO ] then Exit;
    end;

    // 손절주문이 나갔으면 안되지
    if FLossCut then Exit;

    // 같은초에 여러번 주문 (3번 허용 )
    if FSignalSec[0] = iSec then
    begin
      if FSignalSec[1] >= 1 then
      begin
        //gEnv.EnvLog( WIN_TEST, Format('%d초에 주문 %d 개 Exit ',  [ FSignalSec[0], FSignalSec[1]]) );
        Exit;
      end
    end
    else
      FSignalSec[1] := 0;

    // 현재 평가손익이 - 이면 들어가지 말자
    if  (Position <> nil ) and
        (Position.EntryOTE < 0 ) then
    begin
      gEnv.EnvLog( WIN_TEST, format('평가손익 마이너스  진입 Exit : %f, %d', [ Position.EntryOTE, iSec])  );
      Exit;
    end;

    if  (Position <> nil ) and ( iSec >= 58 ) and
        (FPL >= Position.EntryPL )   then
    begin
      //gEnv.EnvLog( WIN_TEST, format('실현손익 마이너스  진입 Exit : %f->%f, %d', [ FPL, FPosition.EntryPL, iSec])  );
      Exit;
    end;
    // 신호가 강도가 줄면..주문 안냄  0.6 -> 0.65는 괜찮지만  0.65->0.7은..거시기하지
    if (FSignalNo  > -1 ) then
      if (FSignalNo > FCondition.NO ) and  (FCondition.NO = 0) then
      begin
        if FSignalNo = 1 then
        begin
          gEnv.EnvLog( WIN_TEST, format('신호 감속으로 Exit : %d -> %d', [FSignalNo, FCondition.NO ] ));
          Exit;
        end;
        if FSignalNo = 2 then begin
          gEnv.EnvLog( WIN_TEST, format('신호 급감속으로 Exit : %d -> %d', [FSignalNo, FCondition.NO ] ));
          TodarkeOrders.EntryAllCancel;
          Exit;
        end;
      end;

    if (FCondition.Side > 0) and (FOrdPrice <> 0 ) then
    begin
      if (aQuote.Bids[0].Price + 0.001) < FOrdPrice then
      begin
        gEnv.EnvLog( WIN_TEST,  format('가격하락으로 Exit : %.2f->%.2f', [ FOrdPrice, aQuote.Bids[0].Price])  );
        Exit;
      end;
    end
    else if (FCondition.Side < 0) and (FOrdPrice <> 0 ) then
    begin
      if (aQuote.Asks[0].Price > ( FOrdPrice + 0.001 )) then
      begin
        gEnv.EnvLog( WIN_TEST,  format('가격상승으로 Exit : %.2f->%.2f', [ FOrdPrice, aQuote.Asks[0].Price])  );
        Exit;
      end;
    end;

    iQty := 0;
    if CheckOrderExist( aQuote, iQty ) then Exit;
    //if Position = nil then iPos := 0
    //else iPos := abs( Position.Volume );
    if iQty  >= aColl.Param.MaxOrderCnt then
    begin
      //gEnv.EnvLog( WIN_TEST, format('주문개수 오버 취소 ㄱㄱ..  Exit : %d', [iQty ] ));
      CancelEntryOrder;
    end;

    dt1Min  := EncodeTime(9,0,1,0 );
    dtNow   := Frac(GetQuoteTime);
    FCondition.Second := iSec;

    // 3개조건 동시 만족
    if  FCondition.No = 2  then
      if  dtNow < dt1Min then  // 1분전에 3조건 동시 만족
        FCondition.Occur1Min := true
      else                     // 3조건 동시 만족
        FCondition.OccurNMin := true;

    LastCon.Assign( FCondition );
    if FirstCon.Side = 0 then
    begin
      FirstCon.Assign( FCondition );
      if aQuote.Terms.LastTerm <> nil then
        FFirstCon.Price := aQuote.Terms.LastTerm.O
      else
        FFirstCon.Price := aQuote.Last;
    end;

    gEnv.EnvLog( WIN_TEST,
      Format('LastCon : %s, s(%d) l(%d) ', [Lastcon.GetText ,
      aQuote.Asks.CntTotal,aQuote.Bids.CntTotal])     );
    // 주문
    if Assigned( FOnOrderEvent ) then
      FOnOrderEvent( self, true );

    if FCondition.Side > 0 then
      FOrdPrice := aQuote.Bids[0].Price
    else
      FOrdPrice := aQuote.Asks[0].Price;

    FSignalNo := FCondition.NO;
    FSignalsec[0]:= isec;
    FSignalsec[1]:= FSignalsec[1] + 1;

    gEnv.EnvLog(WIN_TEST, Format('after :%d초에 주문 %d 개 ',  [ FSignalSec[0], FSignalSec[1]]) );

    // 신호 저장
    if (FCondition.Side > 0) then
    begin
      //FLongSignSecOccured[i].Occured := true;
      FLongOccuredCon2[ FCondition.NO]:= true;
      {
      stLog := format ( '매수 : sso1:%s, sso2:%s, sso3:%s, sso4:%s,  oc1:%s, oc2:%s oc3:%s',  [
        ifThenStr( FLongSignSecOccured[0].Occured, 'T','F'),ifThenStr( FLongSignSecOccured[1].Occured, 'T','F'),
        ifThenStr( FLongSignSecOccured[2].Occured, 'T','F'),ifThenStr( FLongSignSecOccured[3].Occured, 'T','F'),
        ifThenStr( FLongOccuredCon2[0], 'T','F'),ifThenStr( FLongOccuredCon2[1], 'T','F'),
        ifThenStr( FLongOccuredCon2[2], 'T','F')
        ]);
        }
    end
    else if ( FCondition.Side < 0 ) then
    begin
      //FShortSignSecOccured[i].Occured := true;
      FShortOccuredCon2[ FCondition.NO]:= true;
      {
      stLog := format ( '매도 : sso1:%s, sso2:%s, sso3:%s, sso4:%s,  oc1:%s, oc2:%s oc3:%s',  [
        ifThenStr( FShortSignSecOccured[0].Occured, 'T','F'),ifThenStr( FShortSignSecOccured[1].Occured, 'T','F'),
        ifThenStr( FShortSignSecOccured[2].Occured, 'T','F'),ifThenStr( FShortSignSecOccured[3].Occured, 'T','F'),
        ifThenStr( FShortOccuredCon2[0], 'T','F'),ifThenStr( FShortOccuredCon2[1], 'T','F'),
        ifThenStr( FShortOccuredCon2[2], 'T','F')
        ]);
        }
    end;
  end;
end;

{ TTodarkeSymbols }

constructor TTodarkeSymbols.Create;
begin
  inherited Create( TTodarkeSymbol );
end;

destructor TTodarkeSymbols.Destroy;
begin

  inherited;
end;

function TTodarkeSymbols.GetTodarkeSymbol(i: integer): TTodarkeSymbol;
begin
  if (i<0) or (i>=Count) then
    Result := nil
  else
    Result := Items[i] as TTodarkeSymbol;
end;

function TTodarkeSymbols.new(aSymbol: TSymbol): TTodarkeSymbol;
begin
  Result := Add as TTodarkeSymbol;
  Result.Symbol := aSymbol;
end;

procedure TTodarkeSymbols.SetIncQty(bUse: boolean);
begin
  Fparam.UseIncQTy  := bUse;
end;

procedure TTodarkeSymbols.SetLiquidSec(iSec: integer);
begin
  FParam.LiqSec := iSec;
end;

procedure TTodarkeSymbols.SetMaxCount(iQty: integer);
begin
  FParam.MaxOrderCnt  := iQty;
end;

procedure TTodarkeSymbols.SetLossCutTick(iQty: integer);
begin
  FParam.LossCutTick1   := iQty;
end;


procedure TTodarkeSymbols.SetQty(iQty: integer);
begin
  FParam.Qty  := iQty;
end;

{ TSignCondition }

procedure TSignCondition.Assign( con: TSignCondition);
var
  I: Integer;
begin
  OccurCnt  := con.OccurCnt;
  Side      := con.Side;
  Occured   := con.Occured;
  No        := con.NO;
  for I := 0 to SignCnt - 1 do
    Condition[i]  := con.Condition[i];

  hitOrder  := con.hitOrder;
  Occur1Min := con.Occur1Min;
  OccurNMin := con.OccurNMin;
  Second    := Con.Second;
  Price     := con.Price;

  OccurCross:= Con.OccurCross;
  AskCnt:=Con.AskCnt;
  BidCnt:=con.BidCnt;
  Move1p := con.Move1p;
end;

function TSignCondition.GetSignalevel: integer;
begin

end;

function TSignCondition.GetText: string;
begin
  Result := Format('side:%d, No:%d, con1:%s con2:%s, Con3:%s, Sec : %d,  %s',
    [
      Side, No, ifThenStr( Condition[0], 'T','F'),
      ifThenStr( Condition[1], 'T','F'),
      ifThenStr( Condition[2], 'T','F'), Second,
      ifThenStr( OccurCross, 'Cross','')
    ]);
end;

procedure TSignCondition.Reset( bPartReset : boolean );
var
  I: Integer;
begin
  OccurCnt  := 0;
  Side      := 0;
  Occured   := false;

  No        := -1;

  for I := 0 to SignCnt - 1 do
    Condition[i]  := false;

  hitOrder  := false;
  Occur1Min := false;
  OccurNMin := false;

  Second    := 0;
  Price     := 0;

  OccurCross  := false;

  AskCnt:=0;
  BidCnt:= 0;
  Move1p  := false;
end;

end.
