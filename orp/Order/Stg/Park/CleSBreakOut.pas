unit CleSBreakOut;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleStrategyStore,

  CleDistributor,  CleParkParam,

  GleTypes
  ;

type

  TSBreakOut = class( TStrategyBase )
  private
    FScreenNumber : integer;
    FOrders: TOrderList;
    FParent: TObject;
    FParam: TSBO_Param;

    FOrderCnt: integer;
    FRun: boolean;
    FOrdSide: integer;
    FPrevHL: double;
    FSymbol: TSymbol;
    FSelected: boolean;
    FReady: boolean;
    FIsMain: boolean;
    FMultiple: integer;
    FLcPoint: double;
    FOnNotify: TTextNotifyEvent;

    procedure Reset;
    procedure DoLog( stData : string );
    function IsRun: boolean;

    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    function CheckOrder(aQuote: TQuote; bJang : boolean = false): integer;
    procedure DoOrder( aQuote : TQuote; iDir : integer ); overload;
    procedure DoOrder( aQuote : TQuote; aAccount : TAccount; iQty: integer; bLiq : boolean = false ); overload;

    procedure DoLossCut(aQuote: TQuote); overload;
    procedure DoLossCut; overload;
    procedure SelectTradeSymbol; overload;
    procedure OnQuote(aQuote: TQuote);
    function CheckLossCut(aQuote: TQuote): boolean;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aObj : TObject ) : boolean;
    procedure SelectTradeSymbol( aSymbol : TSymbol ); overload;
    procedure CalcLcPoint ;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;
    property Symbol : TSymbol read FSymbol;

    property Param : TSBO_Param read FParam write FParam;

    // 상태변수들
    property Run   : boolean read FRun;
    property OrderCnt : integer read FOrderCnt;
    property OrdSide  : integer read FOrdSide;
    property Selected : boolean read FSelected;
    property Ready    : boolean read FReady;

    //
    property LcPoint   : double read FLcPoint;
    property OnNotify  : TTextNotifyEvent read FOnNotify write FOnNotify;


  end;

implementation

uses
  GAppEnv,  CleKrxSymbols, GleLib, GleConsts,

  FleSBreakOut,

  Math
  ;

{ TSBreakOut }

procedure TSBreakOut.CalcLcPoint;
begin
  FLcPoint  := FSymbol.DayOpen * ( FParam.StopPer / 100 );
end;

function TSBreakOut.CheckLossCut(aQuote: TQuote): boolean;
var
  dPrice : double;
begin
  Result := false;
  if FOrdSide = 0 then Exit;

  if (Position <> nil) and ( Position.Volume <> 0 ) then
  begin
    if Position.Volume < 0 then
    begin
      dPrice  := Position.AvgPrice + LcPoint;
      if dPrice < aQuote.Last + PRICE_EPSILON then begin
        Result := true;
        DoLog( Format('매도 손절  %.2f > %.2f + %.2f', [ aQuote.Last,
          Position.AvgPrice, LcPoint ]));
      end;
    end; // 매도 손절..
  end;
end;

function TSBreakOut.CheckOrder(aQuote: TQuote; bJang : boolean): integer;
var
  stLog : string;
  iCnt  : integer;
  dLow  : double;
  bOk   : boolean;
begin
  Result := 0;
  if aQuote.Terms.PrevTerm = nil then Exit;

  bOK := false;

  if bJang then
  begin
    if aQuote.Terms.Count < 4 then Exit;

    iCnt  := aQuote.Terms.Count-3;
    dLow  := Min( aQuote.Terms.XTerms[iCnt].L,  aQuote.Terms.XTerms[iCnt-1].L );
    stLog := '2개봉 저가';

    // update by 2016.11.02  용규의 요청에 의해 시가 밑에서도 주문 나갈수 잇게.
    // if aQuote.Terms.PrevTerm.C > ( aQuote.Symbol.DayOpen - PRICE_EPSILON ) then
    bOK := true;

  end else begin
    dLow := FSymbol.DayOpen;
    stLog:= '시가';
    bOK  := true;
  end;

  if ( aQuote.Terms.PrevTerm.C > PRICE_EPSILON ) and
     ( dLow > PRICE_EPSILON ) and ( bOK ) and
     ( aQuote.Terms.PrevTerm.C + PRICE_EPSILON  < dLow ) then
      Result := -1;

  if Result <> 0 then
    DoLog( Format('%d th. 진입 조건 OK -->  종가: %.2f  < %.2f ( O:%.2f) %s', [ FOrderCnt+1,
         aQuote.Terms.PrevTerm.C, dLow, aQuote.Symbol.DayOpen,  stLog ]));

end;

constructor TSBreakOut.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stOs, true);
  FScreenNumber := Number;

  FRun      := false;
  FSelected := false;

  FOrders   := TOrderList.Create;
  FSymbol   := nil;
  FOrderCnt := 0;

end;

destructor TSBreakOut.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;

procedure TSBreakOut.DoLog(stData: string);
begin
  if Account <> nil then
  begin
    gEnv.EnvLog( WIN_PARK, stData, false, Format('%s_OS_%d', [ Account.Name, FScreenNumber ] ));
    if Assigned( FOnNotify ) then
      FOnNotify( Self, stData );
  end;
end;

procedure TSBreakOut.DoLossCut(aQuote: TQuote);
var
  aPos : TPosition;
  I: Integer;
begin

  for I := 0 to Positions.Count - 1 do
  begin
    aPos  := Positions.Positions[i];
    if ( aPos <> nil ) and ( aPos.Volume <> 0 ) then
      DoOrder( aPos.Symbol.Quote as TQuote , Account, abs(aPos.Volume), true );
  end;

  DoLog( '청산 완료  리셋' );
  Reset;

end;

procedure TSBreakOut.DoLossCut;
begin
  DoLossCut( nil );
end;

procedure TSBreakOut.DoOrder(aQuote: TQuote; iDir: integer);
var
  iQty, I: Integer;
begin

  FOrdSide := iDir;
  iQty     := FParam.OrdQty;

  DoOrder( aQuote, Account, iQty );
  inc( FOrderCnt );

end;

procedure TSBreakOut.DoOrder(aQuote: TQuote; aAccount: TAccount; iQty: integer;
  bLiq: boolean);
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
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, -5 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, 5 );
  end else
  begin
    // 신규
    iSide :=  FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, 5 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, -5 );
  end;

  if ( dPrice < 0.001 ) or ( iQty = 0 ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f ',  [ aAccount.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice ]));
    Exit;
  end;

  //aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    aOrder.OrderSpecies := opOs;
    Orders.Add( aOrder );
    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( bLiq, '청산', '신규' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '매수','매도'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;

end;

function TSBreakOut.init(aAcnt: TAccount;  aObj : TObject): boolean;
begin
  Account := aAcnt;
  // 선물...
  FParent := aObj;
end;

function TSBreakOut.IsRun: boolean;
begin
  if FRun  and ( Account <> nil ) and ( FParent <> nil ) then
    Result := true
  else
    Result := false;
end;


procedure TSBreakOut.Reset;
begin
  FOrdSide:= 0;
  FOrders.Clear;
end;

procedure TSBreakOut.SelectTradeSymbol(aSymbol: TSymbol);
var
  aQuote : TQuote;
begin

  if Position <> nil then begin
    if Position.Symbol <> aSymbol then begin
      gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, Position.Symbol );
      ChangeSymbol( Position.Symbol, aSymbol );
    end;
  end
  else
    AddPosition( aSymbol );

  FSymbol := aSymbol;
  CalcLcPoint;
  (Parent as TFrmSBreakOut ).SetSymbol( aSymbol );

  aQuote := gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, aSymbol,
    gEnv.Engine.QuoteBroker.DummyEventHandler);

  if aQuote <> nil then
  begin
    aQuote.MakeTerm := true;
    aQuote.Terms.Period := 15;
  end;

  DoLog( Format(' SelectTradeSymbol  %s,  %.2f , %.2f', [ aSymbol.ShortCode, aSymbol.DayOpen, FLcPoint ])   );
end;

function TSBreakOut.Start: boolean;
begin
  Result := false;
  if {( FSymbol = nil ) or} ( Account = nil ) then Exit;
  FRun   := true;

  DoLog( 'SBreakOut Start' );
  Result := true;

  gEnv.Engine.QuoteBroker.Cancel( Self );
end;

procedure TSBreakOut.Stop;
begin
  FRun := false;

  //if Position <> nil then
  //  gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, Position.Symbol );

  if FParam.UseStopLiq then
    DoLossCut;

  DoLog( 'SBreakOut  Stop' );
end;


procedure TSBreakOut.SelectTradeSymbol;
var
  aOpt : TOption;
begin
  aOpt  := gEnv.Engine.SymbolCore.GetParkCall( FParam.BelowPrc, FParam.BasePrc, false );
  if aOpt <> nil then begin
    SelectTradeSymbol( aOpt );
    FReady := true;
  end else
  begin
    DoLog( '종목선정 실패로 중지' );
    TFrmSBreakOut( FParent).cbRun.Checked := false;
  end;
end;

procedure TSBreakOut.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
begin
  inherited;

end;

procedure TSBreakOut.QuoteProc(aQuote: TQuote; iDataID: integer);
begin
  if iDataID = 300 then
    Exit;

  if not IsRun then Exit;

  if FParam.StartTime < Frac( now ) then
    if ( not FReady )  then
      SelectTradeSymbol
    else
      OnQuote( aQuote );
end;


procedure TSBreakOut.OnQuote(aQuote: TQuote);
var
  dtNow : TDateTime;
  iDir  : integer;
  bJang : boolean;
begin

  dtNow := Frac( now );

  if dtNow >= FParam.Endtime then
  begin
    TFrmSBreakOut( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FSymbol <> aQuote.Symbol then Exit;

  if aQuote.AddTerm  then
  begin
    if dtNow < FParam.MorningTime then
      bJang := false          // 아침매도
    else bJang := true;             // 장중매도

    if ( FOrdSide = 0 ) and ( FOrderCnt < FParam.EntryCnt ) then begin
      iDir := CheckOrder( aQuote, bJang );
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir );
        Exit;
      end;
    end;
  end;  // AddTerm;

  // 손절
  if CheckLossCut(aQuote) then
  begin
    DoLossCut(aQuote);
    Exit;
  end;
end;

end.
