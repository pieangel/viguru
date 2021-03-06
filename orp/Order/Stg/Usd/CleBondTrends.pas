unit CleBondTrends;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,   CleStrategyAccounts,

  GleTypes
  ;

type

  TBondTrendParam = record
    OrdQty   : integer;
    EntryCnt   : integer;

    E_C, E_S, E_S2 : double;

    UseEndLiq       : boolean;
    UseTrailingStop : boolean;
    UseFillter      : boolean;

    StopMax, StopPer : integer;
    LiskAmt  : double;

    StartTime, Start2Time, Endtime : TDateTime;
    EntEndtime : TDateTime;

    StgType : integer;
    LeftCon : integer;
    RightCon: integer;
  end;

  TBondTrends = class
  private
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;

    FParent: TObject;
    FOnNotify: TTextNotifyEvent;
    FParam: TBondTrendParam;
    FStgs: TList;
    FIsBegin: boolean;
    FNowPL: double;
    FMinPL: double;
    FOrderCnt: integer;
    FRun: boolean;
    FLossCut: boolean;
    FOrdSide: integer;
    FMaxPL: double;
    FSymbol: TSymbol;
    FUsSymbol: TSymbol;
    FMaxOpenPL: double;
    FVolume: integer;
    procedure SetParam(const Value: TBondTrendParam);
    procedure DoLog(stData: string);
    procedure StgAccountLog(value: string; idx: integer);
    procedure Reset( bInit : boolean = true );
    procedure SetSymbol;

    procedure DoLossCut;
    procedure DoOrder( iDir : integer ); overload;
    function DoOrder( aSgAcnt : TStrangleAccount; aSymbol : TSymbol; iQty, iSide : integer; bLiq :boolean = false ) : TOrder ; overload;
    function IsRun: boolean;

    function CheckLossCut( var iSep : integer ) : boolean;
    function CheckOrder( dtNow : TDateTime )   : integer;
    function CheckOrder2( dtNow : TDateTime )  : integer;
    function GetVolume: integer;

  public
    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;

    function init( aAcnt : TAccount; aObj : TObject ) : boolean; overload;
    function init( aFund : TFund; aObj : TObject ) : boolean; overload;

    procedure OnQuote( Sender : TObject );
    procedure testorder;

    property Run      : boolean read FRun;
    property LossCut  : boolean read FLossCut;
    property IsBegin  : boolean read FIsBegin;

    property OrdSide  : integer read FOrdSide;
    property OrderCnt : integer read FOrderCnt;

    property MaxPL : double read FMaxPL;
    property NowPL : double read FNowPL;
    property MinPL : double read FMinPL;
    property MaxOpenPL : double read FMaxOpenPL;
    property Volume : integer read GetVolume ;

    property Param  : TBondTrendParam read FParam write SetParam;
    property Parent : TObject read FParent write FParent;
    property Stgs   : TList read FStgs write FStgs;
    property Symbol : TSymbol read FSymbol;
    property UsSymbol : TSymbol read FUsSymbol;

    property OnNotify  : TTextNotifyEvent read FOnNotify write FOnNotify;
  end;

implementation

uses
  GAppEnv , Math, GleLib, Gleconsts,
  CleQuoteTimers,
  FleBondTrends
  ;

{ TBondTrends }

function TBondTrends.CheckLossCut( var iSep : integer ): boolean;
var
  aQuote : TQuote;
  dPL, dOpen : double;
  I , iOpen, iVol: Integer;
  aSg : TStrangleAccount;
  stLog : string;
begin
  Result := false;
  iSep := 0;

  try

  dOpen := 0;
  dPL   := 0;  iOpen := 0;  ivol := 0;

  for I := 0 to FStgs.Count - 1 do begin
    aSg :=  TStrangleAccount( FStgs.Items[i]);
    dOpen := dOpen + ( aSg.Positions.GetOpenPL( aSg.Account, iOpen ) / 1000 );
    dPL   := dPL + ( aSg.TotPL / 1000 );
    iVol := iVol + aSg.Multi;
  end;

  FNowPL := dPL;
  FMaxPL := Max( FNowPL, FMaxPL );
  FMinPL := min( FNowPL, FMinPL );
  FMaxOpenPL  := Max( FMaxOPenPL, dOpen );

  if (FOrdSide = 0) or ( FSymbol.Quote = nil ) then Exit;
  aQuote  := FSymbol.Quote as TQuote;

  if ( FOrdSide > 0 ) and
    ( aQuote.Asks.VolumeTotal > aQuote.Bids.VolumeTotal ) and
    ( aQuote.Asks.CntTotal > aQuote.Bids.CntTotal ) then
    Result := true
  else if ( FOrdSide < 0 ) and
    ( aQuote.Bids.VolumeTotal > aQuote.Asks.VolumeTotal ) and
    ( aQuote.Bids.CntTotal > aQuote.Asks.CntTotal ) then
    Result := true;

  if Result then begin
    iSep := 1;
    stLog := Format('%s ???? --> (%d | %d)  (%d | %d)', [
      ifThenStr( FOrdSide > 0, '????','????'),
      aQuote.Asks.VolumeTotal , aQuote.Bids.VolumeTotal ,
      aQuote.Asks.CntTotal, aQuote.Bids.CntTotal ]);

  end;

  if not Result then
    if FParam.UseTrailingStop then
    begin
      dPL  :=  FMaxOpenPL *( FParam.StopPer / 100 );
      if ( FMaxOpenPL > (FParam.StopMax * 10 * FParam.OrdQty  * iVol ) ) and
         ( dOpen < ( FMaxOpenPL - dPL )) then
      begin
        Result := true;
        iSep   := 2;
        stLog := Format('???????? %0n ---> %0n (%d%s ????)', [  FMaxOpenPL, dOpen,
          FParam.StopPer, '%']);
      end;
    end;

  if not Result then begin
    if FParam.LiskAmt <= 0 then Exit;

    if FNowPL < (FParam.LiskAmt * iVol * FParam.OrdQty *  -10) then
    begin
      Result := true;
      iSep  := 3;
      stLog := Format('????  %.0f < %.0f ', [ FNowPL, FParam.LiskAmt * iVol * FParam.OrdQty *  -10 ]);
    end;
  end;

  finally
    if Result then DoLog( stLog );
  end;

end;

function TBondTrends.CheckOrder( dtNow : TDateTime ): integer;
var
  iSide : integer;
  d1, d2 : double;
  aQuote : TQuote;
begin
  // ???? 1
  Result := 0;
  if ( OrderCnt >= FParam.EntryCnt) or (FSymbol.Quote = nil) then Exit;
  aQuote  := FSymbol.Quote as TQuote;

  case FOrderCnt of
    0 :
        if ( dtNow >= FParam.StartTime ) and  ( dtNow <  FParam.EntEndtime) then
        begin
          d1 := ifThenFloat( FParam.LeftCon = 0 , FUsSymbol.DayOpen, FUsSymbol.Last );
          d2 := ifThenFloat( FParam.RightCon= 0 , FUsSymbol.DayOpen, FUsSymbol.PrevClose );

          if ( d1 < PRICE_EPSILON ) or ( d2 < PRICE_EPSILON ) then Exit;

          if (( aQuote.Bids.CntTotal * FParam.E_C) > aQuote.Asks.CntTotal ) and
             (( aQuote.Bids.VolumeTotal * FParam.E_S) > aQuote.Asks.VolumeTotal ) then
          begin
            if FParam.UseFillter then begin
              if (( d1 + PRICE_EPSILON ) < d2 ) then
                Result := 1
            end else
              Result := 1;
          end else
          if (( aQuote.Asks.CntTotal * FParam.E_C) > aQuote.Bids.CntTotal ) and
             (( aQuote.Asks.VolumeTotal * FParam.E_S ) > aQuote.Bids.VolumeTotal ) then
          begin
            if FParam.UseFillter then begin
              if ( d1 > ( d2 + PRICE_EPSILON )) then
                Result := -1
            end else
              Result := -1;
          end;

          if Result <> 0 then
            DoLog( Format('%d.th %s???? --> %s , %s , ????:%.2f, ????:%.2f ', [
              FOrderCnt+1, ifThenStr( Result > 0,'????','????'),
              FUsSymbol.PriceToStr(d1), FUsSymbol.PriceToStr(d2),
              FSymbol.CntRatio, FSymbol.VolRatio    ]));

        end;
    else begin
        if ( dtNow >= FParam.Start2Time ) and  ( dtNow <  FParam.EntEndtime) then
        begin
          if (( aQuote.Bids.VolumeTotal * FParam.E_S2) > aQuote.Asks.VolumeTotal ) then
            Result := 1
          else if (( aQuote.Asks.VolumeTotal * FParam.E_S2 ) > aQuote.Bids.VolumeTotal ) then
            Result := -1;

          if Result <> 0 then
            DoLog( Format('%d.th %s???? -->????:%.2f, ????:%.2f ', [
              FOrderCnt+1, ifThenStr( Result > 0,'????','????'),
              FSymbol.CntRatio, FSymbol.VolRatio     ]));
        end;
    end;
  end;

end;

function TBondTrends.CheckOrder2( dtNow : TDateTime ): integer;
var
  aQuote : TQuote;
  d1, d2 : double;
begin
  // ???? 2
  Result := 0;
  if ( OrderCnt >= FParam.EntryCnt) or (FSymbol.Quote = nil) then Exit;
  aQuote  := FSymbol.Quote as TQuote;

  if ( dtNow >= FParam.StartTime ) and  ( dtNow <  FParam.EntEndtime) then
  begin
    d1 := ifThenFloat( FParam.LeftCon = 0 , FUsSymbol.DayOpen, FUsSymbol.Last );
    d2 := ifThenFloat( FParam.RightCon= 0 , FUsSymbol.DayOpen, FUsSymbol.PrevClose );

    if ( d1 < PRICE_EPSILON ) or ( d2 < PRICE_EPSILON ) then Exit;

    if (( aQuote.Bids.CntTotal * FParam.E_C) > aQuote.Asks.CntTotal ) and
       (( aQuote.Bids.VolumeTotal * FParam.E_S) > aQuote.Asks.VolumeTotal ) then
    begin
      if FParam.UseFillter then begin
        if (( d1 + PRICE_EPSILON ) < d2 ) then
          Result := 1
      end else
        Result := 1;
    end else
    if (( aQuote.Asks.CntTotal * FParam.E_C) > aQuote.Bids.CntTotal ) and
       (( aQuote.Asks.VolumeTotal * FParam.E_S ) > aQuote.Bids.VolumeTotal ) then
    begin
      if FParam.UseFillter then begin
        if ( d1 > ( d2 + PRICE_EPSILON )) then
          Result := -1
      end else
        Result := -1;
    end;

    if Result <> 0 then
      DoLog( Format('%d.th %s???? --> %s , %s , ????:%.2f, ????:%.2f ', [
        FOrderCnt+1, ifThenStr( Result > 0,'????','????'),
        FUsSymbol.PriceToStr(d1), FUsSymbol.PriceToStr(d2),
        FSymbol.CntRatio, FSymbol.VolRatio  ]));
  end;
end;


constructor TBondTrends.Create(aObj: TObject);
begin
  FStgs:= TList.Create;

  FSymbol   := nil;
  FUsSymbol := nil;
end;

destructor TBondTrends.Destroy;
var
  i : Integer;
begin

  for I := FStgs.Count-1 downto 0 do
    TObject(FStgs.Items[i]).Free;
  FStgs.Free;
  inherited;
end;

procedure TBondTrends.StgAccountLog(value: string; idx: integer);
begin
  DoLog( Value );
end;

procedure TBondTrends.DoLog(stData: string);
var
  st : string;
begin

  st := ifThenStr( FParam.StgType = 0, '_TR', '_IN');

  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_RATIO, stData, false, FFund.Name+st )
  else if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( WIN_RATIO, stData, false, FAccount.Name+st );
       
  if Assigned( FOnNotify ) then
    FOnNotify( Self, stData );

end;

procedure TBondTrends.DoLossCut;
var
  i, j : Integer;
  aSg : TStrangleAccount;
  aPos: TPosition;
begin

  for I := 0 to FStgs.Count - 1 do
  begin
    aSg := TStrangleAccount( FStgs.Items[i] );
    for j := 0 to aSg.Positions.Count - 1 do
    begin
      aPos  := aSg.Positions.Positions[j];
      if ( aPos <> nil ) and ( aPos.Volume <> 0 ) then
        DoOrder( aSg, aPos.Symbol, abs(aPos.Volume), -aPos.Side, true );
    end;
  end;

  Reset(false);
  FLossCut := true;
  DoLog( '???? ????  ????' );
end;

function TBondTrends.DoOrder(aSgAcnt: TStrangleAccount; aSymbol: TSymbol; iQty,
  iSide: integer; bLiq: boolean) : TOrder;
begin
  Result  := aSgAcnt.DoOrder( aSymbol, iQty, iSide );
  if Result <> nil then
    DoLog( Format('%s ???? : %s', [  ifThenStr( bLiq , '????','????'), Result.Represent3 ]))
  else
    DoLog( Format('%s ???????? : %s, %s, %s, %d', [ ifThenStr( bLiq , '????','????'),
      aSgAcnt.Account.Name, aSymbol.ShortCode,
      ifThenStr( iSide > 0, '????','????')  , iQty    ]));
end;

function TBondTrends.GetVolume: integer;
var
  i   : integer;
  aSg : TStrangleAccount;
begin

  Result := 0;
  for I := 0 to FStgs.Count - 1 do begin
    aSg :=  TStrangleAccount( FStgs.Items[i]);
    aSg.Positions.GetOpenPL( aSg.Account, Result )    ;
  end;
end;

procedure TBondTrends.DoOrder(iDir: integer);
var
  I: Integer;
  bOk : boolean;
begin
  // ??????
  bOK := false;
  for I := 0 to FStgs.Count - 1 do
    if (DoOrder( TStrangleAccount( FStgs.Items[i] ),  FSymbol, FParam.OrdQty, iDir ) <> nil )  then
      bOK := true;

  if bOK then
  begin
    FOrdSide := iDir;
    inc( FOrderCnt );
  end;

end;

procedure TBondTrends.SetSymbol;
var
  aSymbol : TSymbol;
begin
  if gEnv.Engine.SymbolCore.Bond10Future <> nil then
  begin
    if gEnv.Engine.SymbolCore.Bond10Future.DaysToExp = 1 then begin
      FSymbol := gEnv.Engine.SymbolCore.GetNextMonth( gEnv.Engine.SymbolCore.Bond10Future.Spec );
      // ???????? ?????????? ?????? ???? ?????? ????.
      if FSymbol <> nil then
        gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,  FSymbol,
            gEnv.Engine.QuoteBroker.DummyEventHandler  );
    end else
      FSymbol := gEnv.Engine.SymbolCore.Bond10Future;
  end ;

  if gEnv.Engine.SymbolCore.UsFuture <> nil then
  begin
    if gEnv.Engine.SymbolCore.UsFuture.DaysToExp = 1 then begin
      FUsSymbol := gEnv.Engine.SymbolCore.GetNextMonth( gEnv.Engine.SymbolCore.UsFuture.Spec );
      // ???????? ?????????? ?????? ???? ?????? ????.
      if FUsSymbol <> nil then
        gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,  FUsSymbol,
            gEnv.Engine.QuoteBroker.DummyEventHandler  );
    end else
      FUsSymbol := gEnv.Engine.SymbolCore.UsFuture;
  end;
end;

function TBondTrends.init(aAcnt: TAccount; aObj: TObject): boolean;
var
  aItem : TStrangleAccount;
begin
  FStgs.Clear;
  aItem := TStrangleAccount.Create( gEnv.Engine.TradeCore.StrategyGate.GetStrategys,
    opBondTrend, stBondTrend, true );
  aItem.init( aAcnt, 0 );
  aItem.OnQuote := OnQuote;
  FStgs.Add( aItem );

  aItem.OnText := StgAccountLog;
  FAccount := aAcnt;
  FIsFund  := false;
  FParent := aObj;

  SetSymbol;
  Reset;

end;

function TBondTrends.init(aFund: TFund; aObj: TObject): boolean;
var
  I: Integer;
  aItem : TStrangleAccount;
begin
  FStgs.Clear;

  for I := 0 to aFund.FundItems.Count - 1 do
  begin
    aItem := TStrangleAccount.Create( gEnv.Engine.TradeCore.StrategyGate.GetStrategys,
      opBondTrend, stBondTrend, true );
    aItem.init( aFund.FundAccount[i], i );
    aItem.OnQuote := OnQuote;
    aItem.OnText  := StgAccountLog;
    FStgs.Add( aItem );
  end;

  FFund   := aFund;
  FIsFund := true;
  FParent := aObj;
  SetSymbol;
  Reset;

end;


function TBondTrends.IsRun: boolean;
begin
  if ( FStgs.Count <= 0 ) or ( not FRun ) or ( FParent = nil ) or
    ( FSymbol = nil ) or ( FUsSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TBondTrends.OnQuote( Sender : TObject);
var
  aQuote : TQuote;
  bTerm  : boolean;
  dtNow  : TDateTime;
  iDir, iStep   : Integer;
begin
  if not IsRun then Exit;
  if Sender = nil then Exit;
  aQuote  := Sender as TQuote;
  // ???? ????..????
  dtNow := Frac( GetQuoteTime );

  if dtNow < FParam.StartTime then Exit;

  if dtNow > FParam.Endtime then
  begin
    TFrmBondTrends( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;
  // ????????
  bTerm := aQuote.AddTerm;
  if (bTerm) and ( FOrdSide = 0 ) then
  begin
    case FParam.StgType of
      0 : iDir := CheckOrder( dtNow ) ;
      1 : iDir := CheckOrder2( dtNow ) ;
    end;

    if iDir <> 0 then
    begin
      DoOrder( iDir );
      Exit;
    end;
  end;

  if CheckLossCut( iStep ) then
  begin
    DoLossCut;
    if iStep = 1 then
      FLossCut := false;
  end;

end;

procedure TBondTrends.Reset(bInit: boolean);
begin
  if bInit then begin
    FLossCut  := false;

    FNowPL:= 0;
    FMinPL:= 0;
    FMaxPL:= 0;

    FOrderCnt := 0;
    FVolume   := 0;
  end;

  FOrdSide  := 0;
  FMaxOpenPL:= 0;

end;

procedure TBondTrends.SetParam(const Value: TBondTrendParam);
begin
  FParam := Value;
end;

function TBondTrends.Start: boolean;
begin
  Result := false;

  if ( FSymbol = nil ) or ( FUsSymbol = nil ) or ( FStgs.Count <= 0) then Exit;

  FRun := true;
  Result := true;

  DoLog( Format('%s (%s) Start', [ FSymbol.ShortCode, FUsSymbol.ShortCode ])   );

end;

procedure TBondTrends.Stop;
begin
  FRun := false;
  if FParam.UseEndLiq then
    DoLossCut;

  DoLog(  Format('%s (%s) Stop', [ FSymbol.ShortCode, FUsSymbol.ShortCode ])   );
end;

procedure TBondTrends.testorder;
begin
  DoOrder(1);
end;

end.
