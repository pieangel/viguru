unit CleUsdH1_1Min;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,  CleUsdParam,

  GleTypes
  ;

type


  TUsdH1_1Min_Trend = class
  private
    FSymbol: TSymbol;
    FOrders: TOrderList;
    FParent: TObject;
    FParam: TUsdH1_1Min_Param;
    FOrderCnt: integer;
    FRun: boolean;
    FLossCut: boolean;
    FAccount: TAccount;
    FOrdSide: integer;
    FPosition: TPosition;
    FMaxOpenPL: double;
    FPrevHL: double;
    FSellStop: boolean;
    FBuyStop: boolean;
    procedure QuotePrc(Sender, Receiver: TObject;
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
  public
    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;

    property Param : TUsdH1_1Min_Param read FParam write FParam;

    property Symbol  : TSymbol read FSymbol;           // 주문낼 종목
    property Account : TAccount read FAccount;
    property Position: TPosition read FPosition;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;

    // 상태변수들
    property Run   : boolean read FRun;
    property OrderCnt : integer read FOrderCnt;
    property OrdSide  : integer read FOrdSide;
    property LossCut  : boolean read FLossCut;
    property BuyStop  : boolean read FBuyStop;
    property SellStop  : boolean read FSellStop;

    property MaxOpenPL : double read FMaxOpenPL;
    property PrevHL    : double read FPrevHL;
  end;

implementation

uses
  GAppEnv, GleLib, CleQuoteTimers , FUsdH1_1Min, CleKrxSymbols,
  Math
  ;

{ TUsdH1_1Min_Trend }

procedure TUsdH1_1Min_Trend.Reset;
begin
  FOrdSide:= 0;
  FOrders.Clear;
  FLossCut  := false;
  FMaxOpenPL:= 0;
end;

procedure TUsdH1_1Min_Trend.DoLog(stData: string);
begin
  if FAccount <> nil then
    gEnv.EnvLog( WIN_USDF, stData, false, FAccount.Name );
end;

function TUsdH1_1Min_Trend.CheckLossCut(aQuote: TQuote): boolean;
var
  dLVal, dSVal , dTmp: double;
  stTxt, stLog : string;
  iAskVal, iBidVal : integer;
begin

  Result := false;

  if FOrdSide = 0 then Exit;

  try

    dLVal := FParam.L1_L;
    dSVal := FParam.L1_S;

    if FParam.StgIdx = 2 then
    begin
      iAskVal := aQuote.Asks.CntTotal;
      iBidVal := aQuote.Bids.CntTotal;
      stTxt   := '건잔';

      if aQuote.AddTerm then
        if (FOrdSide < 0 ) and (( iBidVal * dLVal ) > iAskVal )  and
           ( aQuote.Bids.VolumeTotal > aQuote.Asks.VolumeTotal )  then begin
          Result := true;
          stLog := Format('상승가능 매도 손절 : %s (%d * %.2f) = %.2f   > %d', [
             stTxt, iBidVal , dLVal, iBidVal * dLVal, iAskVal ]);
        end
        else if ( FOrdSide > 0 ) and ( iBidVal  < (iAskVal * dSVal )) and
          ( aQuote.Asks.VolumeTotal > aQuote.Bids.VolumeTotal ) then begin
          Result := true;
          stLog := Format('하락가능 매수 손절 : %s (%d * %.2f) = %.2f   > %d', [
             stTxt, iAskVal , dLVal, iAskVal * dLVal, iBidVal ]);
        end;

      if not Result  then
      begin
        if FOrdSide > 0 then
        begin
          if FPosition.AvgPrice > 0.01 then begin
            dTmp := FPosition.AvgPrice - FPosition.AvgPrice * 1 * FParam.EntPer;
            if dTmp > aQuote.Last then begin
              Result := true;
              stLog := Format('진입가대비 하락가능 매수손절 :  %s > %s(%s)', [ aQuote.Symbol.PriceToStr( aQuote.Last ),
                aQuote.Symbol.PriceToStr( dTmp ),   aQuote.Symbol.PriceToStr( FPosition.AvgPrice )]          );
            end;
          end;
        end else
        if FOrdSide < 0 then
        begin
          if FPosition.AvgPrice > 0.01 then begin
            dTmp := FPosition.AvgPrice + FPosition.AvgPrice * 1 * FParam.EntPer;
            if dTmp < aQuote.Last then begin
              Result := true;
              stLog := Format('진입가대비 상승가능 매도손절 :  %s < %s(%s)', [ aQuote.Symbol.PriceToStr( aQuote.Last ),
                aQuote.Symbol.PriceToStr( dTmp),  aQuote.Symbol.PriceToStr( FPosition.AvgPrice )]          );
            end;
          end;
        end;
      end;

    end else begin

      if aQuote.AddTerm then
        if ( FParam.UseLossCnt ) and ( FParam.UseLossVol ) then
        begin
          iAskVal := aQuote.Asks.CntTotal;
          iBidVal := aQuote.Bids.CntTotal;
          // 총잔량 추가로 수정  2016.03.22
          // 잔량 추가로 수정  2019.11.27
          if (FOrdSide < 0 )
            and (( iBidVal * dLVal ) > iAskVal )
            and (( aQuote.Bids.VolumeTotal * FParam.L1_L2 ) > aQuote.Asks.VolumeTotal ) then begin
            Result := true;
            stLog := Format('상승가능 매도 손절 -> 건수: (%d * %.2f) = %.2f > %d  | 잔량 : (%d * %.2f) = %.2f > %d ', [
               iBidVal , dLVal, iBidVal * dLVal, iAskVal,
               aQuote.Bids.VolumeTotal, FParam.L1_L2,  aQuote.Bids.VolumeTotal * FParam.L1_L2,  aQuote.Asks.VolumeTotal
               ]);
          end
          else if ( FOrdSide > 0 )
            and ( aQuote.Bids.VolumeTotal < ( aQuote.Asks.VolumeTotal * FParam.L1_S2 ))
            and ( iBidVal  < (iAskVal * dSVal )) then begin
            Result := true;
            stLog := Format('하락가능 매수 손절-> 건수 : (%d * %.2f) = %.2f > %d | 잔량: (%d * %.2f) = %.2f > %d ' , [
               iAskVal , dSVal, iAskVal * dSVal, iBidVal,
               aQuote.Asks.VolumeTotal, FParam.L1_S2,  aQuote.Asks.VolumeTotal * FParam.L1_S2, aQuote.Bids.VolumeTotal
                ]);
          end;
        end else
        if FParam.UseLossCnt then
        begin
          iAskVal := aQuote.Asks.CntTotal;
          iBidVal := aQuote.Bids.CntTotal;
          dLVal := FParam.L1_L;
          dSVal := FParam.L1_S;
          // 총잔량 추가로 수정  2016.03.22
          // 잔량 추가로 수정  2019.11.27
          if (FOrdSide < 0 )
            and (( iBidVal * dLVal ) > iAskVal ) then begin
            Result := true;
            stLog := Format('상승가능 매도 손절 -> 건수: (%d * %.2f) = %.2f > %d ', [
               iBidVal , dLVal, iBidVal * dLVal, iAskVal
               ]);
          end
          else if ( FOrdSide > 0 )
            and ( iBidVal  < (iAskVal * dSVal )) then begin
            Result := true;
            stLog := Format('하락가능 매수 손절-> 건수 : (%d * %.2f) = %.2f > %d  ' , [
               iAskVal , dSVal, iAskVal * dSVal, iBidVal
                ]);
          end;
        end else
        if FParam.UseLossVol then
        begin
          iAskVal := aQuote.Asks.VolumeTotal;
          iBidVal := aQuote.Bids.VolumeTotal;
          dLVal := FParam.L1_L2;
          dSVal := FParam.L1_S2;
          // 총잔량 추가로 수정  2016.03.22
          // 잔량 추가로 수정  2019.11.27
          if (FOrdSide < 0 )
            and (( iBidVal * dLVal ) > iAskVal ) then begin
            Result := true;
            stLog := Format('상승가능 매도 손절 -> 잔량: (%d * %.2f) = %.2f > %d ', [
               iBidVal , dLVal, iBidVal * dLVal, iAskVal
               ]);
          end
          else if ( FOrdSide > 0 )
            and ( iBidVal  < (iAskVal * dSVal )) then begin
            Result := true;
            stLog := Format('하락가능 매수 손절-> 잔량 : (%d * %.2f) = %.2f > %d  ' , [
               iAskVal , dSVal, iAskVal * dSVal, iBidVal
                ]);
          end;
        end;
    end;   // end else begin


   {
    // 1분 종가일때로만  수정  2016.02.29
    if aQuote.AddTerm then
      if (FOrdSide < 0 ) and (( aQuote.Bids.CntTotal * dLVal ) > aQuote.Asks.CntTotal ) then begin
        Result := true;
        stLog := Format('상승가능 매도 손절 : (%d * %.2f) = %.2f   > %d', [
           aQuote.Bids.CntTotal , dLVal, aQuote.Bids.CntTotal * dLVal, aQuote.Asks.CntTotal ]);
      end
      else if ( FOrdSide > 0 ) and ( aQuote.Bids.CntTotal  < (aQuote.Asks.CntTotal * dSVal )) then begin
        Result := true;
        stLog := Format('하락가능 매수 손절 : (%d * %.2f) = %.2f   > %d', [
           aQuote.Asks.CntTotal , dLVal, aQuote.Asks.CntTotal * dLVal, aQuote.Bids.CntTotal ]);
      end;
      }

    if Result then Exit;
    //
    if FParam.UseTrailingStop then
    begin
      dTmp  :=  FMaxOpenPL *( FParam.StopPer / 100 );
      if ( FMaxOpenPL > (FParam.StopMax * abs(FPosition.Volume)) ) and
        ( FPosition.Volume <> 0 ) and ( FPosition.EntryOTE < ( FMaxOpenPL - dTmp )) then
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

function TUsdH1_1Min_Trend.CheckOrder(aQuote: TQuote): integer;
var
  iAskVal, iBidVal : integer;
  E_L, E_S : double;
begin
  Result := 0;

  if FParam.StgIdx = 2 then
  begin
    iAskVal := aQuote.Asks.VolumeTotal;
    iBidVal := aQuote.Bids.VolumeTotal;


    if (( iBidVal * FParam.E_L ) > iAskVal) and ( not FBuyStop ) and
       ( aQuote.Bids.CntTotal > aQuote.Asks.CntTotal ) then
      Result := 1
    else if (( iBidVal < ( iAskVal * FParam.E_S ))) and ( not FSellStop ) and
      ( aQuote.Asks.CntTotal > aQuote.Bids.CntTotal ) then
      Result := -1;

  end else begin
    // 둘중 하나는 체크 되어 있어야 함..
    if ( not FParam.UseEntCnt ) and ( not FParam.UseEntVol ) then Exit;

    // 둘다 체크 되어 있을때.
    if FParam.UseEntCnt and FParam.UseEntVol then
    begin
      iAskVal := aQuote.Asks.CntTotal;
      iBidVal := aQuote.Bids.CntTotal;

      if (( iBidVal * FParam.E_L ) > iAskVal)
        and (( aQuote.Bids.VolumeTotal * FParam.E_L2 ) > aQuote.Asks.VolumeTotal )
        and ( not FBuyStop ) then
        Result := 1
      else if ( iBidVal < ( iAskVal * FParam.E_S ))
        and ( aQuote.Bids.VolumeTotal < ( aQuote.Asks.VolumeTotal * FParam.E_S2 ))
        and ( not FSellStop ) then
        Result := -1;

    end else begin

      if FParam.UseEntCnt then
      begin
        iAskVal := aQuote.Asks.CntTotal;
        iBidVal := aQuote.Bids.CntTotal;
        E_L     := FParam.E_L;
        E_S     := FParam.E_S;
      end else
      begin
        iAskVal := aQuote.Asks.VolumeTotal;
        iBidVal := aQuote.Bids.VolumeTotal;
        E_L     := FParam.E_L2;
        E_S     := FParam.E_S2;
      end;

      if (( iBidVal * E_L ) > iAskVal) and ( not FBuyStop ) then
        Result := 1
      else if ( iBidVal < ( iAskVal * E_S ))  and ( not FSellStop ) then
        Result := -1;
    end;
  end;

  if Result <> 0 then
    DoLog( Format('%d th. %s 진입 조건 OK --> %.2f, %.2f ( con %.2f, %.2f, %.2f, %.2f )', [ FOrderCnt+1,
      ifThenStr( Result > 0 , '매수','매도'), aQuote.CntRatio, aquote.VolRatio,
      FParam.E_L, FParam.E_S, FParam.E_L2, FParam.E_S2 ]));
      {
  if Result <> 0 then
    DoLog( Format('%d th. %s 진입 조건 OK -->  %s bidc %d, ask : %d', [ FOrderCnt+1,
      ifThenStr( Result > 0 , '매수','매도'), stTxt,  iBidVal , iAskVal ]));

      {
  if dHL < FParam.HL then
  begin
    if (( aQuote.Bids.CntTotal * FParam.E_L ) > aQuote.Asks.CntTotal) and ( not FBuyStop ) then
      Result := 1
    else if (( aQuote.Bids.CntTotal < ( aQuote.Asks.CntTotal * FParam.E_S ))) and ( not FSellStop ) then
      Result := -1;
  end;

  if Result <> 0 then
    DoLog( Format('%d th. %s 진입 조건 OK --> HL: %.2f, bidc: %d, askc : %d', [ FOrderCnt+1,
      ifThenStr( Result > 0 , '매수','매도'), dHL,  aQuote.Bids.CntTotal , aQuote.Asks.CntTotal ]));
      }
end;

constructor TUsdH1_1Min_Trend.Create(aObj: TObject);
begin
  FRun      := false;
  FOrders   := TOrderList.Create;
  FParent   := aObj;
  FSymbol   := nil;
  FOrderCnt := 0;
  FAccount  := nil;
  FPosition := nil;
end;

destructor TUsdH1_1Min_Trend.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
  inherited;
end;



procedure TUsdH1_1Min_Trend.DoLossCut(aQuote: TQuote);
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

procedure TUsdH1_1Min_Trend.DoLossCut;
begin
  DoLossCut( nil );
end;

procedure TUsdH1_1Min_Trend.DoOrder(aQuote: TQuote; iDir: integer);
var
  iQty, I: Integer;
begin

  FOrdSide := iDir;
  iQty     := FParam.OrdQty;
  // 주문낼 종목은 FSymbol  aQuote 는 지수선물 임
  DoOrder( aQuote, FAccount, iQty );
  inc( FOrderCnt );
  FMaxOpenPL  := 0;

end;

procedure TUsdH1_1Min_Trend.DoOrder(aQuote: TQuote; aAccount: TAccount;
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

function TUsdH1_1Min_Trend.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  FAccount := aAcnt;
  FSymbol  := aSymbol;
  FPosition := gEnv.Engine.TradeCore.Positions.FindOrNew( FAccount, FSymbol );

  FSellStop:= false;
  FBuyStop := false;
  Reset;
end;

function TUsdH1_1Min_Trend.IsRun: boolean;
begin
  if ( not Run) or ( FAccount = nil ) or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TUsdH1_1Min_Trend.OnQuote(aQuote: TQuote);
var
  bTerm : boolean;
  dtNow : TDateTime;
  iDir  : integer;
begin

  if FSymbol <> aQuote.Symbol then Exit;

  FMaxOpenPL  := Max( FMaxOpenPL, FPosition.EntryOTE );

  dtNow := Frac( GetQuoteTime );
  bTerm := false;

  if aQuote.AddTerm then
    bTerm := true;

  if not IsRun then Exit;

  if dtNow >= FParam.Endtime then
  begin
    TFrmUsH1( FParent).cbRun.Checked := false;
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

procedure TUsdH1_1Min_Trend.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
    OnQuote( DataObj as TQuote );
end;

function TUsdH1_1Min_Trend.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;
  FRun := true;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc, true);

  DoLog( Format('%s TUsdH1_1Min_Trend Start', [ Symbol.Code]));
  Result := true;
end;

procedure TUsdH1_1Min_Trend.Stop;
begin
  FRun := false;
  if FParam.UseStopLiq then  
    DoLossCut;
  DoLog( 'TUsdH1_1Min_Trend  Stop' );
end;

end.
