unit CleUs_In_123_Fund;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,  CleUsdParam,

  GleTypes
  ;

type


  TUs_In_123_Trend_Fund = class
  private
    FSymbol: TSymbol;
    FOrders: TOrderList;
    FQteSymbol: TSymbol;
    FParent: TObject;
    FParam: TUs_In_123_Param;

    FOrderCnt: integer;
    FRun: boolean;
    FLossCut: boolean;
    FOrdSide: integer;
    FPosition: TFundPosition;
    FMaxOpenPL: double;
    FSellStop: boolean;
    FBuyStop: boolean;
    FFund: TFund;
    FQuoteSide: integer;
    FQuoteSide2: integer;
    FQuoteSide3: integer;
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure SymbolPrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure OnQuote(aQuote: TQuote);
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
    function init( aFund: TFund; aQuoteSymbol, aOrdSymbol : TSymbol ) : boolean;

    property Param : TUs_In_123_Param read FParam write FParam;

    property Symbol  : TSymbol read FSymbol;           // 주문낼 종목
    property QteSymbol   : TSymbol  read FQteSymbol;   // 주문에 참조될  시세종목
    property Fund : TFund read FFund;
    property Position: TFundPosition read FPosition;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;

    // 상태변수들
    property Run   : boolean read FRun;
    property OrderCnt : integer read FOrderCnt;
    property OrdSide  : integer read FOrdSide;
    property LossCut  : boolean read FLossCut;
    property BuyStop  : boolean read FBuyStop;
    property SellStop  : boolean read FSellStop;

    property QuoteSide : integer read FQuoteSide;
    property QuoteSide2 : integer read FQuoteSide2;
    property QuoteSide3 : integer read FQuoteSide3;   // 원달러 잔량 필터

    //
    property MaxOpenPL : double read FMaxOpenPL;
  end;

implementation

uses
  GAppEnv, GleLib, GleConsts, CleQuoteTimers , FUs_In_123, CleKrxSymbols,
  Math
  ;

{ TUs_In_123_Trend_Fund }

procedure TUs_In_123_Trend_Fund.Reset;
begin
  FOrdSide:= 0;
  FOrders.Clear;
  FLossCut  := false;
  FMaxOpenPL  := 0;
  FQuoteSide  := 0;
  FQuoteSide2 := 0;
  FQuoteSide3 := 0;
end;

constructor TUs_In_123_Trend_Fund.Create(aObj: TObject);
begin
  FRun:= false;
  FOrders:= TOrderList.Create;
  FParent:= aObj;
  FSymbol:= nil;
  FOrderCnt := 0;
  FFund:= nil;
  FQteSymbol:= nil;

  FPosition := nil;
end;

destructor TUs_In_123_Trend_Fund.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
  inherited;
end;

procedure TUs_In_123_Trend_Fund.DoLog(stData: string);
begin
  if FFund <> nil then
    gEnv.EnvLog( WIN_USDF, stData, false, FFund.Name );
end;

function TUs_In_123_Trend_Fund.CheckLiquid(aQuote: TQuote): Boolean;
begin

end;

function TUs_In_123_Trend_Fund.CheckLossCut(aQuote: TQuote): boolean;
var
  dLVal, dSVal , dTmp: double;
  stLog : string;
begin
  Result := false;
  if FOrdSide = 0 then Exit;

  try

  dLVal := FParam.L1_L;
  dSVal := FParam.L1_S;

  if (FParam.UseSecondLiqCon) and ( FOrderCnt > 1 ) then
  begin
    dLVal := FParam.L2_L;
    dSVal := FParam.L2_S;
  end;

  if aQuote.AddTerm then
    if (FOrdSide > 0 ) and (( aQuote.Bids.CntTotal * dLVal ) > aQuote.Asks.CntTotal ) then begin
      Result := true;
      stLog := Format('선물 상승가능 매수 손절 : (%d * %.2f) = %.2f   > %d', [
         aQuote.Bids.CntTotal , dLVal, aQuote.Bids.CntTotal * dLVal, aQuote.Asks.CntTotal ]);
    end
    else if ( FOrdSide < 0 ) and ( aQuote.Bids.CntTotal  < (aQuote.Asks.CntTotal * dSVal )) then begin
      Result := true;
      stLog := Format('선물 하락가능 매도 손절 : (%d * %.2f) = %.2f   > %d', [
         aQuote.Asks.CntTotal , dLVal, aQuote.Asks.CntTotal * dLVal, aQuote.Bids.CntTotal ]);
    end;

  if Result then Exit;
  if FPosition = nil then Exit;  
  //
  if FParam.UseTrailingStop then
  begin
    dTmp  :=  FMaxOpenPL *( FParam.StopPer / 100 );
    if ( FMaxOpenPL > ( FParam.StopMax * abs(FPosition.Volume) )  ) and
      ( FPosition.Volume <> 0 ) and  ( FPosition.EntryOTE < ( FMaxOpenPL - dTmp )) then
    begin
      Result := true;
      stLog := Format('최대손익 %0n ---> %0n (%d%s 감소)', [  FMaxOpenPL, FPosition.EntryOTE,
        FParam.StopPer, '%']);

      DoLog( Format('%s 로 인한 트레일링 스탑, 이후부터 %s 주문 금지', [
        ifThenStr( FOrdSide > 0, '매수','매도'),
        ifThenStr( FOrdSide > 0, '매수','매도') ]));

      if FOrdSide > 0 then
        FBuyStop := true
      else if FOrdSide < 0 then
        FSellStop := true;

    end;
  end;

  finally
    if Result then DoLog( stLog );
  end;

end;

function TUs_In_123_Trend_Fund.CheckOrder(aQuote: TQuote): integer;
begin
  Result := 0;

  if (( aQuote.Bids.CntTotal * FParam.E_L ) > aQuote.Asks.CntTotal ) and ( not FSellStop ) then
    Result := -1
  else if (( aQuote.Bids.CntTotal < ( aQuote.Asks.CntTotal * FParam.E_S ))) and ( not FBuyStop ) then
    Result := 1;

  if Result <> 0 then
  begin
    if FParam.UseEntFillter then
      if Result <> FQuoteSide  then
      begin
        Result := 0;
        Exit;
      end;

    if FParam.UseEntFillter2 then
      if Result <> FQuoteSide2  then
      begin
        Result := 0;
        Exit;
      end;

    if FParam.UseVolFillter then
      if Result <> FQuoteSide3  then
      begin
        Result := 0;
        Exit;
      end;

    DoLog( Format('%d th. %s 진입 조건 OK --> L:%d, S:%d (건필:%s, %.2f) (잔필:%s, %.2f) ', [ FOrderCnt+1,
      ifThenStr( Result > 0 , '매수','매도'),  aQuote.Bids.CntTotal , aQuote.Asks.CntTotal,
      ifThenStr( FParam.UseEntFillter , 'On','Off'), FSymbol.CntRatio,
      ifThenStr( FParam.UseVolFillter , 'On','Off'), FSymbol.VolRatio
       ]));
  end;

end;



procedure TUs_In_123_Trend_Fund.DoLossCut(aQuote: TQuote);
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

procedure TUs_In_123_Trend_Fund.DoLossCut;
begin
  DoLossCut( nil );
end;

procedure TUs_In_123_Trend_Fund.DoOrder(aQuote: TQuote; aAccount: TAccount;
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

procedure TUs_In_123_Trend_Fund.DoOrder(aQuote: TQuote; iDir: integer);
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
    DoOrder( FSymbol.Quote as TQuote, aItem.Account, aItem.Multiple * iQty );
  end;

  inc( FOrderCnt );
  FMaxOpenPL  := 0;
end;

function TUs_In_123_Trend_Fund.init(aFund: TFund; aQuoteSymbol,
  aOrdSymbol: TSymbol): boolean;
begin
  FFund := aFund;
  FSymbol  := aOrdSymbol;
  FQteSymbol := aQuoteSymbol;

  FPosition := gEnv.Engine.TradeCore.FundPositions.Find( aFund, FSymbol );
  if FPosition = nil then
    FPosition := gEnv.Engine.TradeCore.FundPositions.New( aFund, FSymbol );

  FSellStop:= false;
  FBuyStop := false;

  Reset;
end;

function TUs_In_123_Trend_Fund.IsRun: boolean;
begin
  if ( not Run) or ( FFund = nil ) or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TUs_In_123_Trend_Fund.OnQuote(aQuote: TQuote);
var
  bTerm : boolean;
  dtNow : TDateTime;
  iDir  : integer;
begin

  FMaxOpenPL  := Max( FMaxOpenPL, FPosition.EntryOTE );

  dtNow := Frac( GetQuoteTime );
  bTerm := false;

  if aQuote.AddTerm then
    bTerm := true;

  if not IsRun then Exit;

  if dtNow >= FParam.Endtime then
  begin
    TFrmUsIn123( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;

  // 진입    // 재진입
  if (( dtNow >= FParam.EntTime ) and ( dtNow < FParam.EntEndtime ) and ( OrderCnt < FParam.EntryCnt )) then
    if ( FOrdSide = 0) and (bTerm) then
    begin
      iDir := CheckOrder( aQuote );
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir );
        Exit;
      end;
    end;

  // 손절
  if CheckLossCut(aQuote) then
  begin
    DoLossCut(aQuote);
    Exit;
  end;

end;

function TUs_In_123_Trend_Fund.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FFund = nil ) then Exit;
  FRun := true;

  gEnv.Engine.QuoteBroker.Cancel( Self );

  gEnv.Engine.QuoteBroker.Subscribe( Self, FQteSymbol, QuotePrc);
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, SymbolPrc);

  DoLog( Format('%s TUs_In_123_Trend Start', [ Symbol.Code]));
  Result := true;
end;

procedure TUs_In_123_Trend_Fund.Stop;
begin
  FRun := false;
  if FParam.UseStopLiq then  
    DoLossCut;
  DoLog( 'TUs_In_123_Trend  Stop' );
end;

//  원달러 시세..
procedure TUs_In_123_Trend_Fund.SymbolPrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
  aQuote  := DataObj as TQuote;
  if aQuote.Symbol = FSymbol then
  begin
    if (FSymbol.CntRatio < FParam.CntFillter) and ( FSymbol.CntRatio > 0 ) then
      FQuoteSide := 1
    else if (abs(FSymbol.CntRatio) < FParam.CntFillter) and ( FSymbol.CntRatio < 0 ) then
      FQuoteSide := -1
    else
      FQuoteSide := 0;

    if FSymbol.Last > FSymbol.DayOpen  then
      FQuoteSide2 := 1
    else if FSymbol.Last < FSymbol.DayOpen then
      FQuoteSide2 := -1
    else
      FQuoteSide2 := 0;

    if (FSymbol.VolRatio < FParam.VolFillter) and ( FSymbol.VolRatio > 0 ) then
      FQuoteSide3 := 1
    else if (abs(FSymbol.VolRatio) < FParam.VolFillter) and ( FSymbol.VolRatio < 0 ) then
      FQuoteSide3 := -1
    else
      FQuoteSide3 := 0;      
  end;

end;

procedure TUs_In_123_Trend_Fund.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
  OnQuote( DataObj as TQuote );
end;

end.
