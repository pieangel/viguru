unit CleUsIn_5min;

interface

uses
  Classes, SysUtils, DateUtils, Math,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,  CleUsdParam,

  GleConsts ,GleTypes
  ;

type

  TUsIn_5Min_Trend = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FOrders: TOrderList;
    FQteSymbol: TSymbol;
    FParent: TObject;
    FParam: TUs_I2_Param;
    FAccount: TAccount;
    FPosition: TPosition;
    FSellStop: boolean;
    FBuyStop: boolean;
    FOrderCnt: integer;
    FRun: boolean;
    FLossCut: boolean;
    FOrdSide: integer;
    FStandLow: double;
    FStandHigh: double;
    FEntBongIdx: integer;
    FBongCnt: integer;
    FATR: double;
    FEntLow: double;
    FEntHigh: double;
    FSetChanel: boolean;
    FMulti: integer;


    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure FuturePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure OnQuote(aQuote: TQuote);
    procedure Reset;
    procedure DoLog( stData : string );
    function IsRun: boolean;
    function CheckOrder(aQuote: TQuote): integer;

    procedure DoLossCut(aQuote: TQuote); overload;
    procedure DoLossCut; overload;
    procedure SetCnt(aQuote: TQuote);
    procedure DoOrder(aQuote: TQuote; iDir: integer); overload;
    procedure DoOrder(aQuote: TQuote; aAccount: TAccount;
                        iQty: integer; bLiq: boolean = false ); overload;

    function CheckLiquid(aQuote: TQuote): Boolean;

  public

    AskCnt: array [0..1] of integer;
    BidCnt: array [0..1] of integer;

    Constructor Create( aColl : TCollection) ; override;
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aQuoteSymbol, aOrdSymbol : TSymbol ) : boolean;

    property Param : TUs_I2_Param read FParam write FParam;

    property Symbol  : TSymbol read FSymbol;           // ?????? ????
    property QteSymbol   : TSymbol  read FQteSymbol;   // ?????? ??????  ????????
    property Account : TAccount read FAccount;
    property Position: TPosition read FPosition;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent write FParent;

    // ??????????
    property Run   : boolean read FRun;
    property OrderCnt : integer read FOrderCnt;
    property OrdSide  : integer read FOrdSide;
    property LossCut  : boolean read FLossCut;
    property BuyStop  : boolean read FBuyStop;
    property SellStop  : boolean read FSellStop;
    property SetChanel : boolean read FSetChanel;

    /// ??
    property StandHigh : double read FStandHigh;
    property StandLow  : double read FStandLow;

    property EntHigh : double read FEntHigh;      // ???????? ????
    property EntLow  : double read FEntLow;       // ???????? ????

    property EntBongIdx: integer read FEntBongIdx;
    property BongCnt   : integer read FBongCnt;
        // Value ????
    property ATR  : double read FATR;
    property Multi : integer read FMulti write FMulti;
  end;

  TUsIn_5Min_Trends = class( TCollection )
  private
    function GetUsTrend(i: integer): TUsIn_5Min_Trend;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aObj : TObject ) : TUsIn_5Min_Trend;
    property UsTrend[ i : integer] : TUsIn_5Min_Trend read GetUsTrend; default;

  end;

implementation

uses
  GAppEnv, GleLib  , cleKrxSymbols,
  FUsI2_5Min
  ;

{ TUsIn_5Min_Trend }

function TUsIn_5Min_Trend.CheckLiquid(aQuote: TQuote): Boolean;
var
  dVal : double;
  stLog: string;
  iPre : integer;
begin
  Result := false;

  if FOrdSide = 0 then Exit;
  if ( FEntHigh < PRICE_EPSILON ) or ( FEntLow < PRICE_EPSILON) then Exit;

  dVal := FATR * FParam.ATRMulti  ;
  iPre := aQuote.Symbol.Spec.Precision;

  if FOrdSide > 0 then
  begin

    if aQuote.Last < (FEntHigh -  dVal) then
    begin
      Result := true;
      FBuyStop := true;
      stLog  := Format('???? ???? %.*n  < ( %.*n - %.*n )',[  iPre, aQuote.Last,
          iPre, FEntHigh, iPre, dVal ]);
    end;
  end else
  begin
    if aQuote.Last > (FEntLow + dVal) then
    begin
      Result := true;
      FSellStop := true;
      stLog  := Format('???? ???? %.*n  > ( %.*n + %.*n )',[  iPre, aQuote.Last,
          iPre, FEntLow, iPre, dVal ]);
    end;
  end;

  if Result  then
    DoLog( stLog );

end;

function TUsIn_5Min_Trend.CheckOrder(aQuote: TQuote): integer;
var
  bUp, bDown : boolean;
begin

  Result := 0;

  if ( FStandHigh < PRICE_EPSILON ) or ( FStandLow < PRICE_EPSILON ) then Exit;

  if aQuote.Terms.PrevTerm = nil then Exit;

  case FParam.StgIndex  of
    0 : if ( aQuote.Terms.PrevTerm.C > FStandHigh ) and ( BidCnt[0] > AskCnt[0] ) then
          Result := 1
        else if ( aQuote.Terms.PrevTerm.C < FStandLow ) and ( BidCnt[0] < AskCnt[0] ) then
          Result := -1;
    1 : if ( aQuote.Terms.PrevTerm.C > FStandHigh ) and ( BidCnt[1] < AskCnt[1] ) then
          Result := 1
        else if ( aQuote.Terms.PrevTerm.C < FStandLow ) and ( BidCnt[1] > AskCnt[1] ) then
          Result := -1;
  end;

  if Result <> 0 then
  begin
    DoLog( Format('%d th. %s ???????? OK ---> C:%.2f, Std:%.2f, (Bidc:%d  AskC :%d)  (Bidc:%d  AskC :%d)',
        [ OrderCnt + 1, ifThenStr( Result > 0, '????','????'),
          aQuote.Terms.PrevTerm.C,  ifThenFloat( Result > 0 , FStandHigh, FStandLow ),
          BidCnt[0], AskCnt[0], BidCnt[1], AskCnt[1] ]));
    FEntLow   := aQuote.Last;
    FEntHigh  := aQuote.Last;
    FEntBongIdx := 0;
  end;
end;

constructor TUsIn_5Min_Trend.Create(aColl: TCollection );
begin
  inherited Create( aColl );

  FSymbol   := nil;
  FOrderCnt := 0;
  FAccount  := nil;
  FPosition := nil;

  FRun      := false;

  FOrders   := TOrderList.Create;
  FOrderCnt := 0;
  FBongCnt  := 0;
  FLossCut  := false;
  FStandHigh   := 0;
  FStandLow    := 10000;
  FATr         := 0;

  FMulti  := 1;

end;

destructor TUsIn_5Min_Trend.Destroy;
begin
  FOrders.Free;
  inherited;
end;

procedure TUsIn_5Min_Trend.DoLog(stData: string);
begin
  if FAccount <> nil then
    gEnv.EnvLog( WIN_USDF, stData, false, FAccount.Name );
end;

procedure TUsIn_5Min_Trend.DoOrder(aQuote: TQuote; iDir: integer);
var
  iQty, I: Integer;
begin

  FOrdSide := iDir;
  iQty     := FParam.OrdQty * FMulti ;
  DoOrder( aQuote, FAccount, iQty  );
  inc( FOrderCnt );

end;

procedure TUsIn_5Min_Trend.DoOrder(aQuote: TQuote; aAccount: TAccount;
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
    // ??????
    iSide := -FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 );
  end else
  begin
    // ????
    iSide :=  FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );
  end;

  if ( dPrice < 0.001 ) or ( iQty < 0 ) then
  begin
    DoLog( Format(' ???? ???? ???? : %s, %s, %d, %.2f ',  [ aAccount.Code,
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
        ifThenStr( bLiq, '????', '????' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '????','????'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;

end;

procedure TUsIn_5Min_Trend.DoLossCut(aQuote: TQuote);
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
  DoLog( '???? ????  ????' );
  Reset;

end;

procedure TUsIn_5Min_Trend.DoLossCut;
begin
  DoLossCut( nil );
end;

function TUsIn_5Min_Trend.init(aAcnt: TAccount; aQuoteSymbol,
  aOrdSymbol: TSymbol): boolean;
begin
  FAccount := aAcnt;
  FSymbol  := aOrdSymbol;
  FQteSymbol := aQuoteSymbol;

  Reset;
end;

function TUsIn_5Min_Trend.IsRun: boolean;
begin
  if ( not Run) or ( FAccount = nil ) or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TUsIn_5Min_Trend.OnQuote(aQuote: TQuote);
begin

end;

procedure TUsIn_5Min_Trend.FuturePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil )  or  (DataID = CHART_DATA) then Exit;
  SetCnt( DataObj as TQuote );
end;

procedure TUsIn_5Min_Trend.Reset;
begin

  FOrdSide  := 0;
  FEntBongIdx := 0;
  FOrders.Clear;
  FEntBongIdx  := 0;

  FLossCut:= false;
  FEntLow := 0;
  FEntHigh:= 0;

  FStandLow := 10000;
  FStandHigh:= 0;
end;

function TUsIn_5Min_Trend.Start: boolean;
var
  iTmp, iAdd : integer;
  aQuote : TQuote;
  I : Integer;
  aItem : TSTermItem;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;
  FRun := true;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, CHART_DATA, QuotePrc);
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc, true);

  gEnv.Engine.QuoteBroker.Subscribe( Self, FQteSymbol, FuturePrc);  // ????... Us_i3 ??????.
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  FPosition := gEnv.Engine.TradeCore.Positions.FindOrNew( FAccount, FSymbol );

  DoLog( Format('%s TUsIn_5Min_Trend Start', [ Symbol.Code]));
  Result := true;

  FSellStop   := false;
  FSellStop   := false;
  FSetChanel  := false;
  BidCnt[0] := 0;
  BidCnt[1] := 0;

  AskCnt[0] := 0;
  AskCnt[1] := 0;


  if  Frac(now) <  FParam.MkStartTime then
    iAdd := 0
  else begin
    iTmp  := MinutesBetween( Frac(now) ,  FParam.MkStartTime ) +1;
    iAdd  := iTmp div 5;

    aQuote  := FSymbol.Quote as TQuote;

    for I := 0 to aQuote.Terms.Count - 1 do
    begin
      aItem := aQuote.Terms.XTerms[i];
      if (Date + FParam.MKStartTime) > aItem.StartTime then Continue;

      if ( aItem.MMIndex mod 5 ) = 0 then
      begin
        inc(FBongCnt);
        inc(FEntBongIdx);
        FStandHigh := Max( aItem.H, FStandHigh );
        FStandLow  := Min( aItem.L, FStandLow  );

        if FBongCnt >= FParam.ChanelIdx then
        begin
          FSetChanel := true;
          break;
        end;
      end;
    end;  // for
  end;

end;

procedure TUsIn_5Min_Trend.Stop;
begin
  FRun := false;
  if FParam.UseStopLiq then
    DoLossCut;
  DoLog( 'TUsIn_5Min_Trend  Stop' );
end;

procedure TUsIn_5Min_Trend.SetCnt( aQuote : TQuote );
begin
  BidCnt[FParam.StgIndex] := aQuote.Bids.CntTotal;
  AskCnt[FParam.StgIndex] := aQuote.Asks.CntTotal;
end;

// ?????? ????
procedure TUsIn_5Min_Trend.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  bTerm : boolean;
  dtNow : TDateTime;
  iDir  : integer;
  aQuote: TQuote;
begin

  if ( Receiver <> Self ) or ( DataObj = nil ) then   Exit;
           {
  if (DataID = CHART_DATA) and ( not FSetChanel ) then
  begin
    // ???? ????
    FStandHigh  := aQuote.HighChl;
    FStandLow   := aQuote.LowChl;
    FSetChanel  := true;

    DoLog( Format('?????? ???? ????????  H : %.2f  L : %.2f', [
      FStandHigh, FStandLow] ));
    Exit;
  end;        }

  aQuote  := DataObj as TQuote;

  dtNow := Frac( Now );
  bTerm := false;

  if aQuote.AddTerm then  // 5???? ??????????
  begin
    FATR := aQuote.Terms.ATR[1];
    if ( aQuote.Terms.LastTerm.MMIndex mod 5 ) = 0 then
    begin
      bTerm := true;
      inc(FBongCnt);
      inc(FEntBongIdx);

      if (FBongCnt = FParam.ChanelIdx) and ( not FSetChanel ) then
      begin
        FStandHigh  := aQuote.High;
        FStandLow   := aQuote.Low;
        FSetChanel  := true;

        DoLog( Format('???????? ?????? %d  -->  H : %.2f  L : %.2f', [  FParam.ChanelIdx,
          FStandHigh, FStandLow] ));
      end;
    end;
  end;

  SetCnt( aQuote );

  if FOrdSide <> 0 then
  begin
    FEntHigh := Max( FEntHigh, aQuote.Last );
    FEntLow  := Min( FEntLow,  aQuote.Last );
  end;

  if not IsRun then Exit;
  if dtNow < FParam.EntTime then Exit;
  if dtNow > FParam.Endtime then
  begin
    TFrmUsI2( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;

  if ( dtNow > FParam.EntTime ) and
     ( dtNow < FParam.EntEndtime ) and
    ( FOrdSide = 0 ) and  ( bTerm ) and
    ( FOrderCnt < 2 ) then
  begin
    iDir  := CheckOrder( aQuote );
    if iDir <> 0 then begin
      DoOrder( aQuote, iDir );
      Exit;
    end;
  end;

  if FOrdSide = 0  then Exit;
    // ????????
  if (( dtNow >= FParam.ATRLiqTime ) or ( EntBongIdx > FParam.TermCnt ))  then
  begin
    // ??????..????
    if CheckLiquid( aQuote )  then
    begin
      DoLossCut( aQuote );
      Exit;
    end;
  end;

  if bTerm then
  begin
    iDir  := CheckOrder( aQuote );
    if (iDir + FOrdSide) = 0 then
    begin
      DoLossCut( aQuote );
      if ( FOrderCnt < 2 ) then
      begin
        CheckOrder( aQuote );
        DoOrder( aQuote, iDir );
      end;
    end;
  end;

end;

procedure TUsIn_5Min_Trend.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

end;

{ TUsIn_5Min_Trends }

constructor TUsIn_5Min_Trends.Create;
begin
  inherited Create( TUsIn_5Min_Trend );
  
end;

destructor TUsIn_5Min_Trends.Destroy;
begin

  inherited;
end;

function TUsIn_5Min_Trends.GetUsTrend(i: integer): TUsIn_5Min_Trend;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TUsIn_5Min_Trend;
end;

function TUsIn_5Min_Trends.New( aObj : TObject ): TUsIn_5Min_Trend;
begin
  Result := Add as TUsIn_5Min_Trend;
  Result.Parent := aObj;
end;

end.
