unit CleEvolBHult;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleAccounts, ClePositions, CleOrders, CleFrontOrder,

  CleQuoteBroker, CleDistributor, CleQuoteTimers, CleEvolBHultData,

  CleKrxSymbols
  ;

type

  TEvolBHult = class
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FRun: boolean;
    FEvolData: TEvolBHultData;
    FBPosition: TPosition;
    FPosition: TPosition;
    FBOrders: TOrderItem;
    function IsRun : boolean;
    procedure Reset;
    procedure DoLog( stLog : string; bReal : boolean = false );
    procedure Save;

    procedure OnQuote( aQuote : TQuote );
    function DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
    function CalcLiqPrice(  aQuote : TQuote ): double;
    procedure OnState(ebType: TEvolBHultState);
  public

    OrdDir     : integer;
    EntryCount : integer;
    RowCount   : integer;
    LiqPrice   : double;

    Constructor Create;
    Destructor  Destroy; override;

    function start : boolean;
    function init( aAcnt, aBAcnt : TAccount; aSymbol : TSymbol ) : boolean;

    procedure stop ;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    property Symbol  : TSymbol read FSymbol;  // 최근월물..
    property Account : TAccount read FAccount;
    property Position  : TPosition read FPosition;
    property BPosition : TPosition read FBPosition;
    property BOrders   : TOrderItem read  FBOrders;

    property Run     : boolean read FRun ;


    property EvolData : TEvolBHultData read FEvolData write FEvolData;
  end;

implementation

uses
  GAppEnv, GleLib, GleConsts, GleTypes
  ;

{ TEvolBHult }

constructor TEvolBHult.Create;
begin

end;

destructor TEvolBHult.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

procedure TEvolBHult.DoLog(stLog: string; bReal : boolean );
begin
  if Account <> nil then
    if bReal then
      gEnv.EnvLog( WIN_TEST, stLog, false, Account.Code )
    else
      gEnv.EnvLog( WIN_LOG, stLog, false, Account.Code );
end;

function TEvolBHult.DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
var
  aTicket : TOrderTicket;
  dPrice  : double;
  stErr   : string;
  bRes    : boolean;
begin
  Result := nil;

  if iSide > 0 then
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
  else
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );

  bRes   := CheckPrice( aQuote.Symbol, Format('%.*n', [aQuote.Symbol.Spec.Precision, dPrice]),
    stErr );

  if (iQty = 0 ) or ( not bRes ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f - %s',  [ Account.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice, stErr ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if Result <> nil then
  begin
    Result.OrderSpecies := opEvolBHult;
    //if Result.Symbol.ShortCode[1] = '1' then
    //  DoLog( Format('주문 만든 시간 %s ', [ FormatDateTime( 'hh:nn:ss.zzz', Result.SentTime ) ]));
    gEnv.Engine.TradeBroker.Send(aTicket);
  end
end;

function TEvolBHult.init(aAcnt, aBAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  Result := false;
  if (aAcnt = nil) or (aBAcnt = nil) or ( aSymbol = nil ) then Exit;

  FSymbol   := aSymbol;
  FAccount  := aAcnt;

  FBPosition:= gEnv.Engine.TradeCore.Positions.FindOrNew( aBAcnt, aSymbol );
  FPosition := gEnv.Engine.TradeCore.Positions.FindOrNew( aAcnt, aSymbol );

  Result := true;
  Reset;
end;

function TEvolBHult.IsRun: boolean;
begin
  if ( not Run) or ( FBPosition = nil ) or ( FPosition = nil ) or
    (FAccount = nil) or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TEvolBHult.OnState( ebType : TEvolBHultState );
var
  stData : string;
begin
  FEvolData.State := ebType;

  case ebType of
    ebNone : stData := '초기화';
    ebNew: stData := '진입' ;
    ebLiquid: stData := '청산';
    ebEnd: stData := '끝';
  end;

  DoLog( stData + ' 로 상태 변화됨 ' );

end;

function TEvolBHult.CalcLiqPrice( aQuote : TQuote ) : double;
var
  iVol, iTmp : integer;
  dAvg, dTmp, dAddTick, dBasePrice : double;
  I: integer;
  aOrder : TOrder;
  bCalc : boolean;
begin

  Result := -1;
  bCalc := false;


  if abs( FPosition.Volume ) = 1 then
  begin
    Result := TicksFromPrice( FSymbol, aQuote.Last,  10 * -1 * FEvolData.TargetSide );
    bCalc  := true;
    dAddTick  := 0;
  end
  else begin
    dAddTick := 0.1;
    iVol := FEvolData.TargetVol - abs( FBPosition.Volume );
    // 헐트 잔고가 줄었을때부터 계산한다...
    // 체결 가격을 알아야 하기땜시 헐트의 OrderItem 을 찾는다.
    if FBOrders = nil then
      FBOrders  := gEnv.Engine.TradeCore.FrontOrders.Find( FBPosition.Account, FSymbol );
    if FBOrders = nil then Exit;

    // 매수일때
    if FPosition.Volume > 0 then
      aOrder  := FBOrders.BidOrder[0]
    else
      aOrder  := FBOrders.AskOrder[0];

    if aOrder = nil then Exit;
    // 체결 가격으로 쓸 가격...
    dBasePrice  := aOrder.Price;
    dTmp  := FBPosition.AvgPrice;

    for I := 0 to iVol - 1 do
    begin
      Result  := ( (abs(FBPosition.Volume) + i) * dTmp + dBasePrice ) / (abs( FBPosition.Volume ) + i+ 1);
      dTmp  := Result;
      dBasePrice  := TicksFromPrice( FSymbol, dBasePrice, FEvolData.TargetSide * FEvolData.HultTick    );
      bCalc := true;
    end;

    if bCalc then
      DoLog( Format('BHult 잔고 :%d, Avg %.3f, 예상 %.3f , Hult 잔고 : %d  평균가 : %.3f, 타켓잔고  %d,  basePrice : %.2f  ', [
        FPosition.Volume, FPosition.AvgPrice, Result,
        FBPosition.Volume, FBPosition.AvgPrice, FEvolData.TargetVol, aOrder.Price
        ]));
    // Target 의 예상 평균단가를 구한다.
  end;

  aOrder  := nil;

  if Result > FSymbol.LimitLow then
    if OrdDir > 0 then
    begin
      // 2틱 더한것보다 작으면..청산..
      if Result > aQuote.Last + dAddTick  then
        aOrder  := DoOrder( 1, -OrdDir, aQuote );
    end else
    if OrdDir < 0 then
    begin
      if Result < aQuote.Last - dAddTick  then
        aOrder := DoOrder( 1, -OrdDir, aQuote )
    end;

  if aOrder <> nil then
  begin
    dec( Rowcount );
    OnState( ebLiquid );

    DoLog( Format( '%d.%d %s 청산 -> LiqPrc %.2f , Cur : %.2f   ', [
      EntryCount, RowCount, ifThenStr( OrdDir > 0 ,'매수', '매도'),
      Result, aQuote.Last
    ]));

    LiqPrice  := Result;
    if Rowcount = 0 then
    begin
      // 완전 청산된 상태...
      OrdDir  := 0;
      OnState( ebEnd );
    end;

  end;
end;

procedure TEvolBHult.OnQuote(aQuote: TQuote);
var
  dGap  : double;
  stLog : string;
  aOrder: TOrder;
begin

  if (EntryCount >= FEvolData.EntryCnt ) and ( OrdDir = 0 ) then
  begin
    // 매수, 매도 합해서 하루에   FEvolData.EntryCnt 번만 진입한다.
    DoLog( Format('진입 최대치 초과 %d > %d ', [ EntryCount, FEvolData.EntryCnt ] ) );
    Exit;
  end;

  // 진입 체크.....

  if FEvolData.State in [ ebNone, ebNew, ebEnd ] then
  begin
    if (abs(FBPosition.Volume) >= FEvolData.EntryItem[RowCount].Volume)  then
    begin
      dGap := abs( FBPosition.AvgPrice - aQuote.Last );

      if( RowCount < FEvolData.DefCnt ) and                   // 한번 진입하면 최대 5차레 주문 낸다.
        ( dGap >= FEvolData.EntryItem[ RowCount].AvgPrice) and
        ( FEvolData.EntryItem[RowCount].Run ) then
      begin
        FEvolData.TargetVol := abs( FBPosition.Volume );
        FEvolData.TargetSide:= FBPosition.Volume div FBPosition.Volume;
        FEvolData.TargetAvg := FBPosition.AvgPrice;

        aOrder := DoOrder( FEvolData.EntryItem[ RowCount ].Qty, FBPosition.Volume * -1, aQuote );

        if (OrdDir = 0) and ( FPosition.Volume = 0 ) then
        begin
          OrdDir  := aOrder.Side;
          inc(EntryCount);
        end;

        inc( RowCount );
        OnState( ebNew );

        DoLog( Format( '%d.%d  %s 주문 -> 잔고 (%d > %d ) and  ( %.3f >= %.3f )  현재가 %.2f  ', [
          EntryCount, RowCount, ifThenStr( FBPosition.Volume > 0, '매도','매수'),
          FEvolData.EntryItem[RowCount].Volume, abs(FBPosition.Volume),
          dGap, FEvolData.EntryItem[RowCount].AvgPrice , aQuote.Last
          ]));
      end;
    end;
  end else
  if FEvolData.State = ebLiquid then
  begin
    if ( abs(FBPosition.Volume) >= FEvolData.EntryItem[RowCount].Volume ) then
    begin
      // 매수 재진입
      if ( OrdDir > 0 ) and  ( LiqPrice > Symbol.LimitLow ) and
         ( LiqPrice <= aQuote.Last ) then
      begin
        FEvolData.TargetVol := abs( FBPosition.Volume );
        FEvolData.TargetSide:= -1;
        FEvolData.TargetAvg := FBPosition.AvgPrice;

        aOrder := DoOrder( FEvolData.EntryItem[ RowCount ].Qty, 1, aQuote );

        inc( RowCount );
        OnState( ebNew );

        DoLog( Format( '%d.%d  %s 재진입 -> 잔고 (%d > %d ) and  ( %.3f >= %.3f ) 평균단가 %.3f  예상가: %.2f, 현재가 %.2f  ', [
          EntryCount, RowCount, ifThenStr( FBPosition.Volume > 0, '매도','매수'),
          FEvolData.EntryItem[RowCount].Volume, abs(FBPosition.Volume),
          dGap, FEvolData.EntryItem[RowCount].AvgPrice , aQuote.Last
          ]));
      end else
      // 매도 재진입
      if ( OrdDir < 0 ) and ( LiqPrice > Symbol.LimitLow ) and
         ( LiqPrice >= aQuote.Last ) then
      begin
        FEvolData.TargetVol := abs( FBPosition.Volume );
        FEvolData.TargetSide:= 1;
        FEvolData.TargetAvg := FBPosition.AvgPrice;

        aOrder := DoOrder( FEvolData.EntryItem[ RowCount ].Qty, -1, aQuote );

        inc( RowCount );
        OnState( ebNew );

        DoLog( Format( '%d.%d  %s 재진입 -> 잔고 (%d > %d ) and  ( %.3f >= %.3f ) 평균단가 %.3f  예상가: %.2f, 현재가 %.2f  ', [
          EntryCount, RowCount, ifThenStr( FBPosition.Volume > 0, '매도','매수'),
          FEvolData.EntryItem[RowCount].Volume, abs(FBPosition.Volume),
          dGap, FEvolData.EntryItem[RowCount].AvgPrice , aQuote.Last
          ]));
      end;
    end;


    dGap :=  abs( LiqPrice - FBPosition.AvgPrice) ;
    if ( abs(FBPosition.Volume) >= FEvolData.EntryItem[RowCount].Volume ) and
       ( FEvolData.AvgGap > dGap ) then
    begin
      FEvolData.TargetVol := abs( FBPosition.Volume );
      FEvolData.TargetSide:= FBPosition.Volume div FBPosition.Volume;
      FEvolData.TargetAvg := FBPosition.AvgPrice;

      aOrder := DoOrder( FEvolData.EntryItem[ RowCount ].Qty, FBPosition.Volume * -1, aQuote );

      inc( RowCount );
      OnState( ebNew );

      DoLog( Format( '%d.%d  %s 주문 -> 잔고 (%d > %d ) and  ( %.3f >= %.3f ) 평균단가 %.3f  현재가 %.2f  ', [
        EntryCount, RowCount, ifThenStr( FBPosition.Volume > 0, '매도','매수'),
        FEvolData.EntryItem[RowCount].Volume, abs(FBPosition.Volume),
        dGap, FEvolData.EntryItem[RowCount].AvgPrice , aQuote.Last
        ]));
    end;
  end;

  // 청산 체크
  if FPosition.Volume <> 0 then
  begin
    CalcLiqPrice( aQuote );
  end;

end;

procedure TEvolBHult.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if not IsRun then Exit;

  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;  

  if DataID = 300 then
  begin
    Save;
    Exit;
  end;

  OnQuote( DataObj as TQuote );

end;

procedure TEvolBHult.Reset;
begin
  EntryCount  := 0;
  RowCount    := 0;
  FEvolData.Reset;
  LiqPrice    := -1;
  OrdDir      := 0;
  FBOrders    := nil;
end;

function TEvolBHult.start: boolean;
begin

  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  Result := IsRun;
  FRun   := true;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  DoLog('start ' );

end;

procedure TEvolBHult.stop;
begin
  FRun := false;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TEvolBHult.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if not IsRun then Exit;

  if ( Receiver <> Sender ) or ( DataObj = nil ) then Exit;

  if (integer( EventID ) = POSITION_UPDATE) and
    ( RowCount = abs( FPosition.Volume )) and ( FPosition = DataObj ) then
  begin
    FEvolData.EntryAvg  := FPosition.AvgPrice;
    FEvolData.AvgGap    := abs( FEvolData.EntryAvg - FEvolData.TargetAvg );
    DoLog( Format( 'Set Evol BHult AvgPrice %.3f  차이는 %.2f  잔고는 %d )',
      [ FPosition.AvgPrice, FEvolData.AvgGap, FPosition.Volume ]));
  end;

end;

procedure TEvolBHult.Save;
begin

end;

end.
