unit CleUsComp;

interface

uses
  Classes,SysUtils, DateUtils, Windows,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,  CleUsdParam,  CleCircularQueue,  CleStrategyAccounts,

  GleTypes

  ;

type

  TUsComp = class
  private
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;

    FSymbol: TSymbol;
    FOrders: TOrderList;
    FQteSymbol: TSymbol;
    FParent: TObject;
    FParam: TUs_Comp;
    FOrderCnt: integer;
    FRun: boolean;
    FAccounts: TList;
    FOrdSide: integer;
    FBongCnt: integer;
    FLossCut: boolean;
    FEntryPrice: double;
    FAvgC: TCircularQueue;

    FPosition : TPosition;
    FFundPosition : TFundPosition;
    FMoveAvgPrc: double;

    procedure Reset( binit : boolean = true );
    procedure DoLog( stData : string );

    procedure DoLossCut(aQuote: TQuote);
    procedure DoOrder( aQuote : TQuote; iDir : integer ); overload;
    procedure DoOrder( aQuote : TQuote; aAccount : TAccount; iQty: integer; bLiq : boolean = false ); overload;

    function IsRun: boolean;

    procedure UsQuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure FuturePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OnQuote(aQuote: TQuote; bOrdSymbol: boolean);
    function CheckLossCut(aQuote: TQuote): boolean;
    function GetPL: double;
    function GetVolume: integer;

  public
    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;

    function init( aData : TObject; bFund : boolean; aQuoteSymbol, aOrdSymbol : TSymbol ) : boolean;


    property Param : TUs_Comp read FParam write FParam;

    property Symbol  : TSymbol read FSymbol;           // 주문낼 종목
    property QteSymbol   : TSymbol  read FQteSymbol;   // 주문에 참조될  시세종목
    property Accounts : TList read FAccounts;
    property AvgC     : TCircularQueue read FAvgC;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;

    // 상태변수들
    property Run   : boolean read FRun;
    property LossCut  : boolean read FLossCut;
    property OrderCnt : integer read FOrderCnt;
    property BongCnt  : integer read FBongCnt;

    property OrdSide  : integer read FOrdSide;
    property EntryPrice : double read FEntryPrice;
    property MoveAvgPrc : double read FMoveAvgPrc;

    property Volume   : integer read GetVolume;
    property PL       : double read GetPL;
  end;

implementation

uses
  GAppEnv, GleLib,   CleKrxSymbols,
  Forms
  ;

{ TUsComp }

constructor TUsComp.Create(aObj: TObject);
begin
  FRun:= false;
  FOrders:= TOrderList.Create;
  FAccounts := TList.Create;

  FParent:= aObj;
  FSymbol   := nil;

  FFund     := nil;
  FAccount  := nil;
  FQteSymbol:= nil;

  FPosition := nil;
  FFundPosition := nil;

  FAvgC:= TCircularQueue.Create( 60 );
end;

destructor TUsComp.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
  FAvgC.Free;
  FAccounts.Free;
  inherited;
end;

procedure TUsComp.DoLog(stData: string);
begin
  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( 'UsComp', stData, false, FFund.Name )
  else if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( 'UsComp', stData, false, FAccount.Name );
end;



procedure TUsComp.DoLossCut(aQuote: TQuote);
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

procedure TUsComp.DoOrder(aQuote: TQuote; iDir: integer);
var
  iQty, I: Integer;
  aItem : TAccountofFund;
begin
  iQty     := FParam.OrdQty;
  FOrdSide := iDir;
  // 주문낼 종목은 FSymbol  aQuote 는 지수선물 임
  for I := 0 to FAccounts.Count - 1 do begin
    aItem := TAccountofFund( FAccounts.Items[i] );
    DoOrder( aQuote, aItem.Account, aItem.Multi * iQty );
  end;

  inc( FOrdercnt );
  FEntryPrice := FSymbol.Last;

end;

procedure TUsComp.DoOrder(aQuote: TQuote; aAccount: TAccount; iQty: integer;
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
    if not bLiq then    
      Orders.Add( aOrder );
    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( bLiq, '청산', '신규' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '매수','매도'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;

end;

function TUsComp.init( aData : TObject; bFund : boolean; aQuoteSymbol,
  aOrdSymbol : TSymbol ) : boolean;
var
  I: Integer;
  aItem : TAccountofFund;
  aQuote: TQuote;
  aTerm : TSTermItem;
begin

  FPosition := nil;
  FFundPosition := nil;

  if bFund then
  begin
    FFund := aData as TFund;
    FIsFund := true;
    for I := 0 to FFund.FundItems.Count - 1 do begin
      aItem := TAccountofFund.Create;
      aItem.SetItem( FFund.FundAccount[i], FFund.FundItems[i].Multiple );
      FAccounts.Add( aItem );
    end;
  end else
  begin
    FAccount  := aData as TAccount;
    FIsFund   := false;
    aItem := TAccountofFund.Create;
    aItem.SetItem( FAccount );
    FAccounts.Add( aItem );
  end;

  FQteSymbol:= aQuoteSymbol;
  FSymbol   := aOrdSymbol;
  Reset;

  if FSymbol <> nil then
  begin
    aQuote  := FSymbol.Quote as TQuote;
    for I := 0 to aQuote.Terms.Count - 1 do
    begin
      aTerm := aQuote.Terms.XTerms[i];
      if ( aTerm.MMIndex mod 5 ) = 0  then begin
        if aQuote.Terms.PrevTerm <> nil then
          FAvgC.PushItem( aTerm.StartTime, aQuote.Terms.PrevTerm.C  );
      end;
    end;
  end;

end;

function TUsComp.IsRun: boolean;
begin
  if ( FAccounts.Count <= 0 ) or ( not FRun ) or ( FParent = nil ) or
    ( FSymbol = nil ) or ( FQteSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TUsComp.Reset( bInit : boolean );
begin
  if bInit then
  begin
    FBongCnt    := 0;
    FMoveAvgPrc := 0;
  end;

  FLossCut  := false;
  FOrders.Clear;
  FEntryPrice:= 0;
  FOrdSide:= 0;
end;

function TUsComp.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccounts.Count <= 0 ) then Exit;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FQteSymbol, FuturePrc );
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, UsQuotePrc );

  if FIsFund then
  begin
    FFundPosition := gEnv.Engine.TradeCore.FundPositions.Find( FFund, FSymbol );
    if FFundPosition = nil then
      FFundPosition := gEnv.Engine.TradeCore.FundPositions.New( FFund, FSymbol );
  end else
    FPosition := gEnv.Engine.TradeCore.Positions.FindOrNew( FAccount, FSymbol );

  FRun := true;

  DoLog( Format('%s TUsComp Start', [ FSymbol.Code]));
end;

procedure TUsComp.Stop;
begin
  FRun := false;
  DoLog( 'TUsComp Stop');
  if FParam.UseStopLiq then
    DoLossCut(nil);
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;

procedure TUsComp.FuturePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( DataObj = nil ) or ( Receiver <> Self ) then Exit;
  OnQuote( DataObj as TQuote, false );
end;


function TUsComp.GetPL: double;
begin
  if ( FIsFund ) and ( FFundPosition <> nil ) then
    Result := FFundPosition.LastPL
  else if ( not FIsFund ) and ( FPosition <> nil ) then
    Result := FPosition.LastPL
  else
    REsult := 0;
end;

function TUsComp.GetVolume: integer;
begin
  if ( FIsFund ) and ( FFundPosition <> nil ) then
    Result := FFundPosition.Volume
  else if ( not FIsFund ) and ( FPosition <> nil ) then
    Result := FPosition.Volume
  else
    REsult := 0;
end;

procedure TUsComp.UsQuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( DataObj = nil ) or ( Receiver <> Self ) then Exit;
  OnQuote( DataObj as TQuote, true );
end;

procedure TUsComp.OnQuote( aQuote : TQuote; bOrdSymbol : boolean );
var
  bTerm : boolean;
  dtNow : TDateTime;
  uQte  : TQuote;
  iDir  : integer;
  dAvg  : double;
begin
  if not IsRun then Exit;

  dtNow := Frac( now );

  if dtNow >= FParam.Endtime then
  begin
    PostMessage( TForm(FParent).Handle, WM_ENDMESSAGE, 0, 0 );
    Exit;
  end;

  if FLossCut then Exit;

  bTerm := false;
  if ( aQuote.AddTerm ) and (( aQuote.Terms.LastTerm.MMIndex mod 5 ) = 0)  then
  begin
    if not bOrdSymbol then begin
      bTerm := true;
      inc(FBongCnt);
    end else
      if aQuote.Terms.PrevTerm <> nil then
        FAvgC.PushItem( dtNow, aQuote.Terms.PrevTerm.C  );
  end;

  iDir := 0;
  uQte := FSymbol.Quote as TQuote;
  if ( dtNow >= FParam.EntStartTime ) and ( dtNow < FParam.EntEndtime ) and
    ( FOrderCnt < FParam.EntryCnt ) and ( bTerm ) and ( FOrdSide = 0 ) then
  begin
    if (FQteSymbol.Last > FQteSymbol.DayOpen ) and
      (FQteSymbol.CntRatio < FParam.E_C ) and ( FQteSymbol.CntRatio > 0 ) and
      (uQte.Asks.VolumeTotal * FParam.E_S > uQte.Bids.VolumeTotal ) then
      iDir := -1
    else if (FQteSymbol.Last < FQteSymbol.DayOpen ) and
      (FQteSymbol.CntRatio > -FParam.E_C ) and ( FQteSymbol.CntRatio < 0 ) and
      (uQte.Bids.VolumeTotal * FParam.E_S > uQte.Asks.VolumeTotal ) then
      iDir := 1;

    if (FOrderCnt > 0) and ( iDir <> 0 ) then
    begin
      dAvg := FAvgC.SumPrice / FAvgC.Count;
      if (( iDir > 0 ) and ( FSymbol.Last < dAvg )) or
         (( iDir < 0 ) and ( FSymbol.Last > dAvg )) then
        iDir := 0;
      FMoveAvgPrc := dAvg;
    end;

  end;

  if iDir <> 0 then
  begin
    DoOrder( uQte, iDir );
    Exit;
  end;

  if CheckLossCut( aQuote ) then
  begin
    DoLossCut( aQuote );
    Exit;
  end;

end;

function TUsComp.CheckLossCut( aQuote : TQuote ) : boolean;
var
  dtTime : TDateTime;
  dAvg   : double;
begin
  Result := false;
  if FOrdSide = 0 then Exit;

  dtTime  := Frac( now );

  if dtTime > FParam.LiqStartTime then
  begin
    dAvg := FAvgC.SumPrice / FAvgC.Count;
    if ( FOrdSide > 0 ) and ( FSymbol.Last < dAvg ) then
      Result := true
    else if ( FOrdSide < 0 ) and ( FSymbol.Last > dAvg ) then
      REsult := true;

    if Result then
      DoLog( Format('AVG : %s 가능으로 손절  %.2f %s %.2f', [
        ifThenStr( FOrdSide > 0, '하락','상승'),   FSymbol.Last,
        ifthenStr( FOrdSide > 0, '<', '>' ), dAvg ]));
  end;

  if not Result  then
  begin
    if ( FOrdSide < 0 ) and
       ( FSymbol.Last > ( EntryPrice + EntryPrice * 1 * FParam.EntPer) ) then
      Result := true
    else if ( FOrdSide > 0 ) and
      ( FSymbol.Last < ( EntryPrice - EntryPrice * 1 * FParam.EntPer) ) then
      Result := true;

    if Result then
      DoLog(Format('ENT : %s 가능으로 손절  %.2f %s %.2f', [
        ifThenStr( FOrdSide > 0, '하락','상승'),   FSymbol.Last,
        ifthenStr( FOrdSide > 0, '<', '>' ), EntryPrice - EntryPrice * 1 * FParam.EntPer ]));
  end;

end;

end.
