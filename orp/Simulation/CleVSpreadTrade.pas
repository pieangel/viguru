unit CleVSpreadTrade;

interface

uses
  Classes, sysutils,

  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,

  CleOrders, CleMarkets, ClePositions, CleStrategyStore, CleQuoteTimers,

  CleCircularQueue

  ;
const
  Long_Sign = 1;   // 양매수및 양매도 청산
  Short_sign = -1; // 양매도및 양매수 청산
  Long_Callhedge_Sign = 100;   // 양매도 일때 헤지 콜 매수 or 풋 매도
  Long_Puthedge_Sign = 200;  // 양매도 일때 헤지 풋 매수 or 콜 매도
  Long_hedge_Liquid_Sign = -100;  // 헤지 청산

type

  TVolSpreadType = ( vsKpi, vsFut, vshedge );

  TVolSpreadParam = record
    StandardQty : integer;
    High, Low : double;
    LongHedge : double;
    procedure Assign( var aP : TVolSpreadParam );
  end;

  TDeltaNeutralSymbol = class( TCollectionItem )
  public
    side : integer;
    stdQty : integer;
    Call, Put, other : TOption;
    callQty, putQty, otherQty : integer;
    callQty2, putQty2, otherQty2 : integer;

    hgePos  : TPosition;

    constructor Create( aColl : TCollection ) ;override;
    procedure CalcQty( iDir : integer );
    procedure DoHedgeOrder( bCall : boolean );
    procedure DoHedgeLiquid;
  end;

  TDeltaNeutralSymbols = class( TCollection )
  private
    function GetDeltSymbol(i: integer): TDeltaNeutralSymbol;
  public
    LastData : array [TVolSpreadType] of double;

    Constructor Create;
    Destructor  Destroy; override;
    function New : TDeltaNeutralSymbol;
    property DeltaSymbol[ i : integer] : TDeltaNeutralSymbol read GetDeltSymbol;
  end;

  TVolSpreadTrade = class( TStrategyBase )
  private
    FLiqTimer, FTimer  : TQuoteTimer;
    FSign   : integer;   // 나가 있는 주문 방향..( 양매도 양매수 동시에 존재 못함 )
    FLongHedge : boolean;
    FShortHedge: boolean;
    FRun  : boolean;
    FLiquidList : TOrderList;
    FOnLog: TGetStrProc;
    procedure QuoteTimer( Sender : TObject );
    procedure LiquidTimer( Sender : TObject );

    procedure calcSpread;
    procedure DoSignal(iSign: integer);
    procedure DoLongOrder;
    procedure DoShortOrder;
    procedure DoOrder(aPos: TPosition); overload;
    procedure DoOrder( aDel : TDeltaNeutralSymbol ); overload;
    function DoLiquid(iSide: integer): boolean;

    procedure DoLongHedgeOrder( bCall : boolean );
    procedure DoLongHedgeLiquidOrder;

  public
    Future, vKospi : TSymbol;
    DataSum : double;
    DataCnt : integer;
    DataVal : TCircularQueue;
    LongSymbols , ShortSymbols :  TDeltaNeutralSymbols;
    vsParam : TVolSpreadParam;
    LastData  : array [TVolSpreadType] of double;

    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    function start( param : TVolSpreadParam ) : boolean;
    procedure stop ;
    function MakeCommodity : boolean;
    procedure SetAccount(aAcnt : TAccount);

    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    procedure DoAllLiquid;
    procedure DoLongHedgeLiquid;
    procedure DoLongHedge;

    property OnLog : TGetStrProc read FOnLog write FOnLog;

  end;

implementation

uses
  GAppEnv,  CleKrxSymbols
  ;

{ TVolSpreadTrade }

procedure TVolSpreadTrade.calcSpread;
var
  dAvg, dData, dData2, dVal : double;
  stLog : string;
  I : Integer;
  dHigh, dLow : double;
begin
  if not FRun then Exit;

  dVal := gEnv.Engine.SymbolCore.ConsumerIndex.VIX.vSpread;

  LastData[vsKpi] := dVal;
  LastData[vsFut] := gEnv.Engine.SymbolCore.Future.Last;
  // index 0 이 젤 나중데이타.
  DataVal.PushItem( GetQuoteTime, dVal);

  if DataCnt < 30 then
  begin
    inc(DataCnt);
    Exit;
  end;

  dData := DataVal.SumPrice / DataVal.Count;
  if ( DataVal.Value[0] < 0 ) and ( DataVal.Value[1] < 0 ) and ( DataVal.Value[2] <0 ) then
  begin
    if (DataVal.Value[3] < 0) and ( DataVal.Value[3] < vsParam.Low ) and  ( FSign <> Long_Sign ) then //
    begin
      DoSignal(Long_sign);// 상향예상   청산(매수) 신호
      if Assigned( FOnLog ) then
        FOnLog( format( 'L Ord %.3f , %.2f', [ LastData[vsKpi], LastData[vsFut] ] ));
    end;
  end
  else if ( DataVal.Value[0] > 0 ) and ( DataVal.Value[1] > 0 ) and ( DataVal.Value[2] > 0 ) then
  begin

    if (DataVal.Value[3] > 0)  and ( DataVal.Value[3] > vsParam.High ) then //
    begin

      if FSign <> Short_Sign then
        DoSignal(Short_Sign)// 하향예상   매도 신호
      else if (FSign = Short_Sign) and ( LastData[vsKpi] > vsParam.LongHedge ) then
      begin
      {
        if ShortSymbols.LastData[vsFut] < LastData[vsFut]  then   // vol 과 선물 동반상승
          DoSignal( Long_hedge_Sign )
        else if ShortSymbols.LastData[vsFut] > LastData[vsFut] then  // vol 업  선물 다운
          DoSignal( Short_hedge_Sign );
          }
      end
      else if(FSign = Short_Sign) and  ( LastData[vsKpi] > vsParam.LongHedge ) and FLongHedge then
      begin
        //DoSignal( Long_hedge_Liquid_Sign);
      end
      else if (FSign = Short_Sign) and  ( LastData[vsKpi] > vsParam.LongHedge ) and FShortHedge then
      begin

      end;

      if Assigned( FOnLog ) then
        FOnLog( format( 'S Ord %.3f , %.2f', [ LastData[vsKpi], LastData[vsFut] ] ));
    end;

  end;

  inc(DataCnt);

end;

constructor TVolSpreadTrade.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stVolSpread, true);

  LongSymbols  := TDeltaNeutralSymbols.Create;
  ShortSymbols := TDeltaNeutralSymbols.Create;
  FLiquidList := TOrderList.Create;

  Future  := nil;
  vKospi  := nil;
  FRun    := false;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 1000;
  FTimer.OnTimer  := QuoteTimer;

  FLiqTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FLiqTimer.Enabled  := false;
  FLiqTimer.Interval := 100;
  FLiqTimer.OnTimer  := LiquidTimer;

  Future  := gEnv.Engine.SymbolCore.Futures[0];
  vKospi  := gEnv.Engine.SymbolCore.Symbols.FindCode( KOSPI200_VOL_CODE );

  DataSum := 0;
  DataCnt := 0;
  FSign   := 0;

  DataVal := TCircularQueue.Create(4);

  LastData[vsKpi] := 0;
  LastData[vsFut] := 0;

  FShortHedge  := false;
  FLongHedge   := false;
end;

destructor TVolSpreadTrade.Destroy;
begin
  FTimer.Enabled  :=  false;
  FLiquidList.Free;
  LongSymbols.Free;
  ShortSymbols.Free;
  inherited;
end;

procedure TVolSpreadTrade.DoAllLiquid;
begin
  DoLiquid(1);
end;

function TVolSpreadTrade.DoLiquid(iSide: integer): boolean;
var
  i : integer;
  aPos : TPosition;
begin
  for I := 0 to Positions.Count - 1 do
  begin
    aPos  := Positions.Positions[i];
    if aPos.Volume = 0 then Continue;
    DoOrder( aPos );
  end;

  FLiqTimer.Enabled := true;

  result := true;
end;

procedure TVolSpreadTrade.DoLongHedge;
begin

  if FSign <> Short_Sign then Exit;

  if ShortSymbols.LastData[vsFut] < LastData[vsFut]  then   // vol 과 선물 동반상승
    DoSignal( Long_Callhedge_Sign )
  else if ShortSymbols.LastData[vsFut] > LastData[vsFut] then  // vol 업  선물 다운
    DoSignal( Long_Puthedge_Sign );

end;

procedure TVolSpreadTrade.DoLongHedgeLiquid;
begin
  if FSign <> Short_Sign then Exit;

  if not FLongHedge then Exit;

  DoSignal( Long_Hedge_Liquid_sign );

end;

procedure TVolSpreadTrade.DoLongHedgeLiquidOrder;
begin

end;

procedure TVolSpreadTrade.DoLongHedgeOrder(bCall: boolean);
var
  I: Integer;
  aSymbol : TSymbol;
  aDel  : TDeltaNeutralSymbol;
begin
  for I := 0 to ShortSymbols.Count - 1 do
  begin
    aDel := ShortSymbols.DeltaSymbol[i];

  end;

end;

procedure TVolSpreadTrade.DoLongOrder;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  aSymbol : TSymbol;
  aItem   : TDeltaNeutralSymbol;

  dDelta, dPrice  : double;
  iQty, I: Integer;
begin
    //
  DoLiquid(-1);

  Exit;

  for I := 0 to LongSymbols.Count - 1 do
  begin
    aItem  := TDeltaNeutralSymbol( LongSymbols.Items[i] );
    aSymbol := aItem.Call;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self, Number, stVolSpread);
    dPrice  := (aItem.Call.Quote as TQuote).Asks[0].Price;
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aSymbol,
         aItem.callQty, pcLimit, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      gEnv.Engine.TradeBroker.Send( aTicket);
      AddOrder( aOrder );
      aOrder.OrderSpecies := opVolSpread;
    end;

    aSymbol := aItem.Put;
    dPrice  := (aItem.Put.Quote as TQuote).Asks[0].Price;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self,Number, stVolSpread);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aSymbol,
         aItem.putQty, pcLimit, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      gEnv.Engine.TradeBroker.Send( aTicket);
      AddOrder( aOrder );
      aOrder.OrderSpecies := opVolSpread;
    end;

  end;

end;

procedure TVolSpreadTrade.DoOrder(aDel: TDeltaNeutralSymbol);
var
  iSide, iQty, iChange : integer;
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  dPrice  : double;
begin

  if not FRun then Exit;
  
  iChange := aDel.callQty - aDel.callQty2;

  if iChange <> 0 then
  begin

    if aDel.side < 0  then  // 양매도라면
    begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs( iChange );
        dPrice  := (aDel.Call.Quote as TQuote).Asks[0].Price;
      end
      else begin
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Call.Quote as TQuote).Bids[0].Price;
      end;
    end else begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Call.Quote as TQuote).Bids[0].Price;
      end
      else begin
        iQty  := abs(iChange);
        dPrice  := (aDel.Call.Quote as TQuote).Asks[0].Price;
      end;
    end;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self,Number, stVolSpread);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aDel.Call as TSymbol,
         iQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);

    if Assigned( FOnLog ) then
      FOnLog( format( 'hedge %s, ', [ aOrder.Represent2 ] ));
  end;

  iChange := aDel.putQty - aDel.putQty2;

  if iChange <> 0 then
  begin
    if aDel.side < 0  then  // 양매도라면
    begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs( iChange );
        dPrice  := (aDel.Put.Quote as TQuote).Asks[0].Price;
      end
      else begin
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Put.Quote as TQuote).Bids[0].Price;
      end;
    end else begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Put.Quote as TQuote).Bids[0].Price;
      end
      else begin
        iQty  := abs(iChange);
        dPrice  := (aDel.Put.Quote as TQuote).Asks[0].Price;
      end;
    end;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self,Number, stVolSpread);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aDel.Put as TSymbol,
         iQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);

  end;
end;

procedure TVolSpreadTrade.DoOrder(aPos: TPosition);
var
  aTicket : TOrderTicket;
  dPrice  : double;
  iQty: Integer;
  aOrder : TOrder;
begin

  iQty := aPos.Volume * -1;
  if iQty = 0 then Exit;

  if iQty > 0 then
    dPrice  := (aPos.Symbol.Quote as TQuote).Bids[0].Price
  else
    dPrice  := (aPos.Symbol.Quote as TQuote).Asks[0].Price;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self,Number, stVolSpread);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aPos.Symbol,
       iQty, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket);
    AddOrder( aOrder );
    aOrder.OrderSpecies := opVolSpread;
    FLiquidList.Add( aOrder);
  end;
end;

procedure TVolSpreadTrade.DoShortOrder;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  aSymbol : TSymbol;
  aItem   : TDeltaNeutralSymbol;

  dDelta, dPrice  : double;
  iQty, I: Integer;

begin

  DoLiquid(1);
        //
  for I := 0 to ShortSymbols.Count - 1 do
  begin

    aItem  := TDeltaNeutralSymbol( ShortSymbols.Items[i] );
    aSymbol := aItem.Call;
    dPrice  := (aItem.Call.Quote as TQuote).Bids[0].Price;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self,Number, stVolSpread);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aSymbol,
         -aItem.callQty, pcLimit, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      gEnv.Engine.TradeBroker.Send( aTicket);
      AddOrder( aOrder );
      aOrder.OrderSpecies := opVolSpread;
    end;

    aSymbol := aItem.Put;
    dPrice  := (aItem.Put.Quote as TQuote).Bids[0].Price;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self,Number, stVolSpread);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, Account, aSymbol,
         -aItem.callQty, pcLimit, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      gEnv.Engine.TradeBroker.Send( aTicket);
      AddOrder( aOrder );
      aOrder.OrderSpecies := opVolSpread;
    end;
  end;

  ShortSymbols.LastData[vsKpi]  := LastData[vsKpi];
  ShortSymbols.LastData[vsFut]  := LastData[vsFut];

end;

procedure TVolSpreadTrade.DoSignal(iSign: integer);
begin
  case iSign of
    Long_Sign   :
      begin
        FSign := iSign;
        DoLongOrder;
      end;
    Short_sign  :   // 양매도
      begin
        FSign := iSign;
        DoShortOrder;
      end;
    Long_Callhedge_Sign : // 양매도중 콜매수 로 헤지
      begin
        DoLongHedgeOrder( true );
      end;
    Long_PutHedge_Sign : // 양매도중 풋매수 로 헤지
      begin
        DoLongHedgeOrder( false );
      end;
    Long_hedge_Liquid_Sign : // 양매도 콜매수 헤지 청산
      begin
        DoLongHedgeLiquidOrder
      end;
  end;

end;

procedure TVolSpreadTrade.LiquidTimer(Sender: TObject);
var
  I: Integer;
  pOrder, aOrder : TOrder;
  aQuote : TQuote;
  dPrice : double;
  aTicket: TOrderTicket;
begin
  for I := FliquidList.Count - 1 downto 0 do
  begin
    aOrder := FLiquidList.Orders[i];
    if ( aOrder.State = osActive ) and ( aOrder.ActiveQty > 0 ) and
      ( aOrder.OrderSpecies = opVolSpread ) then
    begin
      aQuote  := TQuote( aOrder.Symbol.Quote );

      if aOrder.Side > 0 then
        dPrice  := aQuote.Bids[0].Price
      else
        dPrice  := aQuote.Asks[0].Price;

      if abs(aOrder.Price - dPrice) >= 0.01 then
      begin
        aTicket:= gEnv.Engine.TradeCore.OrderTickets.New( self ,Number, stVolSpread);
        pOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrderEx( aOrder, aOrder.ActiveQty,
            pcLimit, dPrice, tmGTC, aTicket );

        if aOrder.Side > 0 then
          dPrice  := aQuote.Asks[1].Price
        else
          dPrice  := aQuote.Bids[1].Price;

        if pOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Send( aTicket);
          pOrder.OrderSpecies  := opVolSpread;
        end;
        //FLiquidList.Delete(i);
      end;
    end
    else if  aOrder.OrderSpecies <> opVolSpread  then
      FLiquidList.Delete(i)
    else if  aOrder.State in [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed ]  then
      FLiquidList.Delete(i);
  end;

  if FliquidList.Count = 0 then
    FLiqTimer.Enabled := false;
end;


function TVolSpreadTrade.MakeCommodity: boolean;
var
  clist, plist : TList;
  I, j, imod, iCnt: Integer;
  aOpt, aOpt2, aOpt3, aTmp : TOption;
  dTmp , dLow : double;
  aItem :TDeltaNeutralSymbol;
begin
  try
    cList := TList.Create;
    pList := Tlist.Create;

    dLow := 0.3;
    gEnv.Engine.SymbolCore.GetCurCallList( 3.0, dLow, 10, cList);
    gEnv.Engine.SymbolCore.GetCurPutList(  3.0, dLow, 10, pList);

    // 양매도 + 콜매도
    for I := 0 to pList.Count - 1 do
    begin
      aOpt  := TOption( pList.Items[i] );
      aTmp  := nil;
      dLow  := 100;
      for j := 0 to cList.Count - 1 do
      begin
        aOpt2 := TOption( cList.Items[j] );
        if (dLow > abs(aOpt.Last - aOpt2.Last)) then
        begin
          dLow := abs(aOpt.Last - aOpt2.Last);
          aTmp := aOpt2;
        end;
      end;

      if aTmp = nil then continue;

      aOpt2 := aTmp;
      aOpt3 := aOpt2;

      aItem := ShortSymbols.New;
      aItem.side  := -1;
      aItem.Call  := aOpt2;
      aItem.Put   := aOpt;
      aItem.other := aOpt3;
      aItem.stdQty  := vsParam.StandardQty;

      //aItem.CalcQty( aItem.stdQty) ;
    end;
    // 양매수 + 콜매수
    for I := 0 to cList.Count - 1 do
    begin
      aOpt  := TOption( cList.Items[i] );
      aTmp  := nil;
      dLow  := 100;
      for j := 0 to pList.Count - 1 do
      begin
        aOpt2 := TOption( pList.Items[j] );
        if (dLow > abs(aOpt.Last - aOpt2.Last)) then
        begin
          dLow := abs(aOpt.Last - aOpt2.Last);
          aTmp := aOpt2;
        end;
      end;

      if aTmp = nil then continue;
      aOpt2 := aTmp;
      aOpt3 := aOpt;

      aItem := longSymbols.New;
      aItem.side  := 1;
      aItem.Call  := aOpt;
      aItem.Put   := aOpt2;
      aItem.other := aOpt3;
      aItem.stdQty  := vsParam.StandardQty;
      aItem.CalcQty( aItem.stdQty) ;
    end;
  finally
    cList.Free;
    pList.Free;
  end;

  if (longSymbols.Count <=0)  or ( shortSymbols.Count <= 0) then
    result := false
  else
    result := true;
end;

procedure TVolSpreadTrade.QuoteTimer(Sender: TObject);
var
  aDel : TDeltaNeutralSymbol;
  I: Integer;
  d1, d2 : double;
begin

  aDel := nil;

  for I := 0 to LongSymbols.Count - 1 do
  begin
    aDel  := LongSymbols.Items[i] as TDeltaNeutralSymbol;
    aDel.CalcQty( aDel.stdQty );
    //DoOrder( aDel);
  end;

  for I := 0 to ShortSymbols.Count - 1 do
  begin
    aDel  := ShortSymbols.Items[i] as TDeltaNeutralSymbol;
    aDel.CalcQty( aDel.stdQty );
//    if FSign = -1 then
//      DoOrder( aDel);
  end;

  if Assigned( OnResult ) then
    OnResult( self, aDel <> nil );

end;


procedure TVolSpreadTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
end;

function TVolSpreadTrade.start(param: TVolSpreadParam): boolean;
begin

  vsParam.Assign( param );
  FRun := MakeCommodity;
  FTimer.Enabled := true;
  result := FRun;
end;

procedure TVolSpreadTrade.stop;
begin
  FRun := false;
end;

procedure TVolSpreadTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
begin
  calcSpread;
end;

procedure TVolSpreadTrade.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
begin

end;



{ TDeltaNeutralSymbols }

constructor TDeltaNeutralSymbols.Create;
begin
  inherited Create( TDeltaNeutralSymbol );
  LastData[vsKpi] := 0;
  LastData[vsFut] := 0;
end;

destructor TDeltaNeutralSymbols.Destroy;
begin

  inherited;
end;

function TDeltaNeutralSymbols.GetDeltSymbol(i: integer): TDeltaNeutralSymbol;
begin
  if (i<0) or (i>=Count) then
    result  := nil
  else
    result  := Items[i] as  TDeltaNeutralSymbol;
end;

function TDeltaNeutralSymbols.New: TDeltaNeutralSymbol;
begin
  Result := Add as TDeltaNeutralSymbol;
end;

{ TDeltaNeutralSymbol }

procedure TDeltaNeutralSymbol.CalcQty(iDir: integer);
var
  aQuote  : TQuote;
  dS, d1, d2, d3, dTmp, dPrice  : double;

begin
  if (Call = nil ) or ( put = nil ) or ( other = nil ) then
    Exit;

  aQuote  := call.Quote as TQuote;
  dPrice  := ( aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;
  if dPrice <= 0 then
    dPrice:= call.Last;
  gEnv.Engine.SyncFuture.SymbolDelta2( aQuote, dPrice );

  aQuote  := put.Quote as TQuote;
  dPrice  := ( aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;
  if dPrice <= 0 then
    dPrice:= put.Last;
  gEnv.Engine.SyncFuture.SymbolDelta2( aQuote, dPrice );

  ds  := abs( put.Delta ) + abs( call.Delta );
  if ds = 0 then Exit;

  d1  := call.Delta / ds ;
  d2  := abs( put.Delta) / ds ;

  callqty2 := callQty;
  putQty2  := putQty;
  otherQty2:= otherQty2;

  if d1 > d2 then
  begin
    callQty := stdQty;
    dTmp := (d1 * stdQty) / d2;
    putQty  := Round(dTmp );
    if putQty < callQty then
      putQty := callQty
  end
  else begin
    putQty    := stdQty;
    dTmp := (d2 * stdQty ) / d1;
    callQty    := Round( dTmp );
    if callQty < callQty then
      callQty := putQty;
  end;

  ds  := put.Delta * putQty + call.Delta * callQty;

  if iDir < 0 then // 델타합을 - 로
  begin

  end
  else begin       // 델타합을 + 로

  end;

  otherQty  := callQty;

end;

constructor TDeltaNeutralSymbol.Create(aColl: TCollection);
begin
  inherited Create( aColl );

  Call := nil;
  Put  := nil;
  other:= nil;

  callQty := 0;
  putQty  := 0;
  otherQty:= 0;

end;

procedure TDeltaNeutralSymbol.DoHedgeLiquid;
begin

end;

procedure TDeltaNeutralSymbol.DoHedgeOrder(bCall: boolean);
var
  aSymbol : TSymbol;
begin


end;

{ TVolSpreadParam }

procedure TVolSpreadParam.Assign(var aP: TVolSpreadParam);
begin
  StandardQty := aP.StandardQty;
  High        := aP.High;
  Low         := ap.Low;
  LongHedge   := ap.LongHedge;
end;

end.
