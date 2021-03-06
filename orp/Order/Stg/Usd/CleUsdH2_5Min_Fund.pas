unit CleUsdH2_5Min_Fund;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,  CleUsdParam,

  GleTypes
  ;

type


  TUsdH2_5Min_Trend_Fund = class
  private
    FParam: TUsdH2_5Min_Param;
    FRun: boolean;
    FOrders: TOrderList;
    FParent: TObject;
    FSymbol: TSymbol;

    FQteSymbol: TSymbol;
    FBongCnt: integer;
    FOrderCnt: integer;
    FOrdSide: integer;
    FEntryPrice: double;
    FRange: double;
    FEntBongIdx: integer;
    FLossCut: boolean;
    FEntrySell: double;
    FEntryBuy: double;
    FPosition: TFundPosition;
    FFund: TFund;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure SymbolPrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OnQuote(aQuote: TQuote);
    procedure OnChartData( aQuote : TQuote );
    procedure Reset;
    procedure DoLog( stData : string );
    function IsRun: boolean;
    function CheckOrder(aQuote: TQuote): integer;

    procedure DoLossCut(aQuote: TQuote); overload;
    procedure DoLossCut; overload;
    procedure DoOrder( aQuote : TQuote; iDir : integer ); overload;
    procedure DoOrder( aQuote : TQuote; aAccount : TAccount; iQty: integer; bLiq : boolean = false ); overload;
    function CheckLossCut(aQuote: TQuote): boolean;
    function CheckLiquid(aQuote: TQuote): Boolean;
    

  public
    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;
    function init( aFund : TFund; aQuoteSymbol, aOrdSymbol : TSymbol ) : boolean;
    procedure CalcRange;

    property Param : TUsdH2_5Min_Param read FParam write FParam;

    property Symbol  : TSymbol read FSymbol;  // 주문낼 종목
    property QteSymbol   : TSymbol  read FQteSymbol;   // 주문에 참조될 종목
    property Fund : TFund read FFund;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;
    property Position: TFundPosition read FPosition;

    // 상태변수들
    property Run   : boolean read FRun;
    property OrderCnt : integer read FOrderCnt;
    property OrdSide  : integer read FOrdSide;
    property BongCnt  : integer read FBongCnt;
    property LossCut  : boolean read FLossCut;

    // 값
    property EntryPrice : double read FEntryPrice;
    property Range     : double read FRange;
    property EntryBuy  : double read FEntryBuy;
    property EntrySell : double read FEntrySell;
    property EntBongIdx: integer read FEntBongIdx;
  end;

implementation

uses
  GleConsts, GAppEnv, GleLib, CleQuoteTimers , FUsdH2_5Min, CleKrxSymbols
  ;

{ TUsdH2_5Min_Trend_Fund }

procedure TUsdH2_5Min_Trend_Fund.Reset;
begin
  //FBongCnt:= 0;
  FEntryPrice:= 0;
  FOrdSide:= 0;
  //FOrderCnt := 0;
  FEntBongIdx := 0;
  FOrders.Clear;
  FLossCut  := false;
end;

procedure TUsdH2_5Min_Trend_Fund.CalcRange;
begin
  if FQteSymbol = nil then Exit;

  if  FParam.E_1 <= 0 then Exit;

  FRange := ( FQteSymbol.PrevHigh - FQteSymbol.PrevLow ) / FParam.E_1;
  FEntryBuy := FQteSymbol.DayOpen + FRange;
  FEntrySell:= FQteSymbol.DayOpen - FRange;
        {
  DoLog( Format('Range : %.2f = ( %.2f - %.2f ) / %.2f --> %.2f, $.2f ', [
    FRange,  FQteSymbol.PrevHigh , FQteSymbol.PrevLow,  FParam.E_1, FEntryBuy, FEntrySell ])
    );   }

end;

constructor TUsdH2_5Min_Trend_Fund.Create(aObj: TObject);
begin
  FRun:= false;
  FOrders:= TOrderList.Create;
  FParent:= aObj;
  FSymbol:= nil;
  FPosition := nil;

  FFund:= nil;
  FQteSymbol:= nil;
end;

destructor TUsdH2_5Min_Trend_Fund.Destroy;
begin

  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  gEnv.Engine.QuoteBroker.Cancel( Self );
  inherited;
end;

function TUsdH2_5Min_Trend_Fund.IsRun : boolean;
begin
  if ( not Run) or ( FFund = nil ) or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TUsdH2_5Min_Trend_Fund.DoLog(stData: string);
begin
  if FFund <> nil then
    gEnv.EnvLog( WIN_USDF, stData, false, FFund.Name );
end;

procedure TUsdH2_5Min_Trend_Fund.DoLossCut;
begin
  DoLossCut( nil );
end;

procedure TUsdH2_5Min_Trend_Fund.DoLossCut(aQuote: TQuote);
var
  //aPos : TPosition;
  aOrd : TOrder;
  I: Integer;
begin

  for I := Orders.Count - 1 downto 0 do
  begin
    aOrd  := Orders.Orders[i];
    if (aOrd.Side = FOrdSide ) and ( aOrd.State = osFilled ) then
      DoOrder( aOrd.Symbol.Quote as TQuote , aOrd.Account, aOrd.FilledQty, true );

    Orders.Delete(i);
  end;

  FLossCut := true;
  DoLog( '청산 완료  리셋' );
  Reset;

end;

procedure TUsdH2_5Min_Trend_Fund.DoOrder(aQuote: TQuote; iDir: integer);
var
  iQty, I: Integer;
  aItem : TFundItem;
begin

  FOrdSide := iDir;
  iQty     := FParam.OrdQty;
  // 주문낼 종목은 FSymbol  aQuote 는 지수선물 임
  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aItem := FFund.FundItems.FundItem[i];
    DoOrder( FSymbol.Quote as TQuote, aItem.Account , aItem.Multiple * iQty );
  end;

  inc( FOrdercnt );
  FEntryPrice := FSymbol.Last;

end;

procedure TUsdH2_5Min_Trend_Fund.DoOrder(aQuote: TQuote; aAccount: TAccount;
  iQty: integer; bLiq: boolean);
var
  dPrice : double;
  stTxt  : string;
  aTicket: TOrderTicket;
  aOrder : TOrder;
  iSide  : integer;
begin
  if ( aAccount = nil ) then Exit;

  if bLiq then
  begin
    // 청산시
    iSide := -FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 );
  end else
  begin
    // 신규
    iSide :=  FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );
  end;

  if ( dPrice < 0.001 ) or ( iQty < 0 ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f ',  [ aAccount.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    Orders.Add( aOrder );
    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( bLiq, '청산', '신규' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '매수','매도'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;
end;

function TUsdH2_5Min_Trend_Fund.init(aFund: TFund; aQuoteSymbol,
  aOrdSymbol: TSymbol): boolean;
begin
  FFund    := aFund;
  FSymbol  := aOrdSymbol;
  FQteSymbol := aQuoteSymbol;
  Reset;
end;


function TUsdH2_5Min_Trend_Fund.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FFund = nil ) then Exit;
  FRun := true;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FQteSymbol, CHART_DATA, QuotePrc);
  gEnv.Engine.QuoteBroker.Subscribe( Self, FQteSymbol, QuotePrc);
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, SymbolPrc);
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  FPosition := gEnv.Engine.TradeCore.FundPositions.Find( FFund, FSymbol );
  if FPosition = nil then
    FPosition := gEnv.Engine.TradeCore.FundPositions.New( FFund, FSymbol );

  DoLog( Format('%s TUsdH2_5Min_Trend Start', [ Symbol.Code]));
  Result := true;
                                       //   종목, 기준날자,      개수,몇분봉,일봉
  gEnv.Engine.SendBroker.ReqChartData( FQteSymbol, incDay(Date,-1), 1, 0, '1' );

end;

procedure TUsdH2_5Min_Trend_Fund.Stop;
begin
  FRun := false;
  if FParam.UseStopLiq then  
    DoLossCut;
  DoLog( 'TUsdH2_5Min_Trend  Stop' );
end;

function TUsdH2_5Min_Trend_Fund.CheckLossCut( aQuote : TQuote ) : boolean;
var
  dParam, dVal : double;
begin
  Result := false;

  if FOrdSide = 0 then Exit;

  if OrderCnt = 1 then
    dParam := FParam.L_1
  else
    dParam := FParam.L_2;

  if FOrdSide > 0 then
  begin
    dVal := FEntryPrice - FEntryPrice * 1 * dParam;
    if dVal > aQuote.Last then
      Result := true;
  end else
  if FOrdSide < 0 then
  begin
    dVal := FEntryPrice + FEntryPrice * 1 * dParam;
    if dVal < aQuote.Last then
      Result := true;
  end;

  if Result then
    DoLog( Format('%s 손절 OK ---> L:%.2f,  E:%.2f, %.2f', [ ifthenStr( FOrdSide > 0, '매수','매도'),
      aQuote.Last, FEntryPrice, dVal ]));
end;

procedure TUsdH2_5Min_Trend_Fund.SymbolPrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
  // 손절

  if CheckLossCut(DataObj as TQuote) then
  begin
    DoLossCut(DataObj as TQuote);
    Exit;
  end;

end;

procedure TUsdH2_5Min_Trend_Fund.QuotePrc(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;

  if DataID = CHART_DATA then
    OnChartData( DataObj as TQuote )
  else
    OnQuote( DataObj as TQuote );
end;

function TUsdH2_5Min_Trend_Fund.CheckLiquid( aQuote : TQuote ) : Boolean;
begin
  Result := false;

  if ( FOrdSide < 0 ) and ( aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.R_1 ) and
     ( FSymbol.Last > FSymbol.DayOpen ) then REsult := true
  else if ( FOrdSide > 0 ) and ( aQuote.Bids.CntTotal * FParam.R_1 > aQuote.Asks.CntTotal  ) and
     ( FSymbol.Last < FSymbol.DayOpen ) then REsult := true;

  if Result  then
    DoLog( Format('%s 청산 조건 OK --> L:%.2f, O:%.2f, BidC:%d, AskC:%d,  %.2f', [
      ifThenStr( FOrdSide > 0, '매수','매도'),
      FSymbol.Last , FSymbol.DayOpen, aQuote.Bids.CntTotal , aQuote.Asks.CntTotal , FParam.R_1 ]));
end;

function TUsdH2_5Min_Trend_Fund.CheckOrder( aQuote : TQuote ) : integer;
var
  uQuote : TQuote;
begin
  Result := 0;
  try
  uQuote  := FSymbol.Quote as TQuote;
  case OrderCnt of
    0 :
      begin
        // 선물의 움직임의 반대로 원달러 주문..
        if (aQuote.Last > ( aQuote.Open + FRange )) and ( aQuote.Bids.CntTotal > aQuote.Asks.CntTotal )  and
           ( uQuote.Asks.CntTotal * 0.85 > uQuote.Bids.CntTotal )  then
          Result := -1
        else if  ((aQuote.Open - FRange) >  aQuote.Last) and ( aQuote.Bids.CntTotal < aQuote.Asks.CntTotal ) and
            ( uQuote.Bids.CntTotal * 0.85 > uQuote.Asks.CntTotal ) then
          Result := 1    ;
      end;
    1 :
      begin
        if (FSymbol.Last <  FSymbol.DayOpen ) and (( aQuote.Bids.CntTotal * FParam.E_2 )> aQuote.Asks.CntTotal ) then
          Result := -1
        else if  (FSymbol.DayOpen < FSymbol.Last) and (( aQuote.Asks.CntTotal * FParam.E_2 )> aQuote.Bids.CntTotal ) then
          Result := 1    ;
      end;
    else Exit;
  end;

  if Result <> 0 then
  begin
    if OrderCnt = 0 then
      FEntBongIdx :=  FBongCnt;

    DoLog( Format('%d th. %s 주문조건 OK ---> L:%.2f, O:%.2f, R:%.2f, Bidc:%d  AskC :%d',
        [ OrderCnt + 1, ifThenStr( Result > 0, '매수','매도'),
          FSymbol.DayOpen , FSymbol.Last, FRange,  aQuote.Bids.CntTotal , aQuote.Asks.CntTotal ]));
  end;

  except
  end;
end;

procedure TUsdH2_5Min_Trend_Fund.OnChartData(aQuote: TQuote);
begin
  CalcRange;
end;

procedure TUsdH2_5Min_Trend_Fund.OnQuote(aQuote: TQuote);
var
  bTerm : boolean;
  dtNow : TDateTime;
  iDir  : integer;
begin

  dtNow := Frac( now );
  bTerm := false;

  if aQuote.AddTerm then  // 5분봉 사용이므로
    if ( aQuote.Terms.LastTerm.MMIndex mod 5 ) = 0 then
    begin
      bTerm := true;
      inc(FBongCnt);     
    end;

  if not IsRun then Exit;
  if dtNow < FParam.StartTime then Exit;
  if dtNow >= FParam.Endtime then
  begin
    TFrmUsH2( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;

  CalcRange;

  // 진입    // 재진입
  if (( dtNow >= FParam.EntTime ) and ( dtNow < FParam.EntEndtime ) and ( OrderCnt = 0 )) or
    (( FEntBongIdx > 0 ) and (( FBongCnt - FEntBongIdx ) > 6) and ( OrderCnt = 1) and ( FBongCnt < 60 ))
  then
    if ( FOrdSide = 0) and (bTerm) then
    begin
      iDir := CheckOrder( aQuote );
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir );
        Exit;
      end;
    end;

  if FOrdSide = 0  then Exit;

    // 청산시작
  if (( dtNow >= FParam.LiqStTime ) and ( dtNow < FParam.LiqEndTime ) and ( FOrdSide <> 0 ))  then
  begin
    // 5분봉 종가로 수정 2016.02.29
    if CheckLiquid( aQuote ) and (bTerm) then
    begin
      DoLossCut( aQuote );
      Exit;
    end;
  end;

end;

procedure TUsdH2_5Min_Trend_Fund.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

end;

end.
