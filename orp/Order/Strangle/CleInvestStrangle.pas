unit CleInvestStrangle;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleOrders, ClePositions, CleQuoteBroker, CleFunds, Ticks,

  CleStrategyAccounts,

  CleDistributor,  CleStrangleConfig,

  GleTypes
  ;

type



  TInvestStrangle = class
  private
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;

    FOrderCnt: integer;
    FRun: boolean;
    FLossCut: boolean;
    FOrdSide: integer;
    FParam: TInvestStrangleParam;
    FParent: TObject;
    FStgs: TList;
    FSymbol : TSymbol;
    FOnNotify: TTextNotifyEvent;
    FIvt2Plus: TOrderCons;
    FIvt1Plus: TOrderCons;
    FIvt2Minus: TOrderCons;
    FIvt1Minus: TOrderCons;
    FIsBegin: boolean;
    FHedgeCnt: integer;
    FtmpList: TList;
    FNowPL: double;
    FMinPL: double;
    FMaxPL: double;
    FIsHedge: boolean;

    procedure DoLog( stData : string );
    procedure StgAccountLog( value : string; idx : integer );
    function IsRun: boolean;
    procedure Reset( bInit : boolean = true );

    procedure DoLossCut;
    procedure SetParam(const Value: TInvestStrangleParam);
    function CheckOrder( aCon : TOrderCon; iSide: integer; d1, d2, d3 : double ): integer;
    function NextOrder(  aCon : TOrderCon; iSide: integer; d2: double): integer;
    function HedgeOrder : integer;

    procedure DoOrder( bMain : boolean = true ) ; overload;
    procedure DoOrder( aSgAcnt : TStrangleAccount; aSymbol : TSymbol; iQty, iSide : integer; bLiq :boolean = false ) ; overload;
    function GetOption(cDiv: char; dPrice: double): TSymbol;
    function CheckLiskAmt: boolean;

    procedure OnQuote( Sender : TObject );
  public
    constructor Create;
    destructor Destroy; override;

    function Start : boolean;
    Procedure Stop;

    function init( aAcnt : TAccount; aObj : TObject ) : boolean; overload;
    function init( aFund : TFund; aObj : TObject ) : boolean; overload;

    procedure OnTimer;
    procedure UpdateParam( iDiv : integer; bVal : boolean );

    property Run      : boolean read FRun;
    property LossCut  : boolean read FLossCut;
    property IsBegin  : boolean read FIsBegin;
    property IsHedge  : boolean read FIsHedge;

    property OrdSide  : integer read FOrdSide;
    property OrderCnt : integer read FOrderCnt;
    property HedgeCnt : integer read FHedgeCnt;

    property MaxPL : double read FMaxPL;
    property NowPL : double read FNowPL;
    property MinPL : double read FMinPL;

    property Param  : TInvestStrangleParam read FParam write SetParam;
    property Parent : TObject read FParent write FParent;
    property Stgs   : TList read FStgs write FStgs;
    property tmpList: TList read FtmpList write FtmpList;

    property Ivt1Plus  : TOrderCons read FIvt1Plus;
    property Ivt1Minus : TOrderCons read FIvt1Minus;
    property Ivt2Plus  : TOrderCons read FIvt2Plus;
    property Ivt2Minus : TOrderCons read FIvt2Minus;

    property OnNotify  : TTextNotifyEvent read FOnNotify write FOnNotify;
  end;


implementation

uses
  GAppEnv, GleLib, Math,
  FleInvestStrangle  ,
  CleKrxSymbols
  ;

{ TInvestStrangle }

constructor TInvestStrangle.Create;
begin
  FStgs:= TList.Create;
  FtmpList:= TList.Create;

  FIvt2Plus:= TOrderCons.Create;
  FIvt1Plus:= TOrderCons.Create;
  FIvt2Minus:= TOrderCons.Create;
  FIvt1Minus:= TOrderCons.Create;

  FIvt1Plus.Size := 5;
  FIvt1Minus.Size := 5;
  FIvt2Plus.Size := 3;
  FIvt2Minus.Size := 3;

  FIsFund := false;

end;

destructor TInvestStrangle.Destroy;
var
  I: Integer;
begin
  FIvt2Plus.Free;
  FIvt1Plus.Free;
  FIvt2Minus.Free;
  FIvt1Minus.Free;

  FtmpList.Free;

  for I := FStgs.Count-1 downto 0 do
    TObject(FStgs.Items[i]).Free;
  FStgs.Free;
  inherited;
end;

procedure TInvestStrangle.DoLog(stData: string);
begin

  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_STR2, stData, false, FFund.Name )
  else if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( WIN_STR2, stData, false, FAccount.Name );
       
  if Assigned( FOnNotify ) then
    FOnNotify( Self, stData );
  
end;

function TInvestStrangle.init(aAcnt: TAccount; aObj: TObject): boolean;
var
  aItem : TStrangleAccount;
begin
  FStgs.Clear;
  aItem := TStrangleAccount.Create( gEnv.Engine.TradeCore.StrategyGate.GetStrategys,
    opStrangle2, stStrangle2, false );
  aItem.init( aAcnt, 0 );
  aItem.OnQuote := OnQuote;
  FStgs.Add( aItem );

  aItem.OnText := StgAccountLog;
  FAccount := aAcnt;
  FIsFund  := false;

  FParent := aObj;
  Reset;
end;

function TInvestStrangle.init(aFund: TFund; aObj: TObject): boolean;
var
  I: Integer;
  aItem : TStrangleAccount;
begin

  FStgs.Clear;
  for I := 0 to aFund.FundItems.Count - 1 do
  begin
    aItem := TStrangleAccount.Create( gEnv.Engine.TradeCore.StrategyGate.GetStrategys,
      opStrangle2, stStrangle2, false );
    aItem.init( aFund.FundAccount[i], i );
    aItem.OnQuote := OnQuote;
    aItem.OnText  := StgAccountLog;
    FStgs.Add( aItem );
  end;
  FFund   := aFund;
  FIsFund := true;
  FParent := aObj;
  Reset;

end;

function TInvestStrangle.IsRun: boolean;
begin
  if ( FStgs.Count <= 0 ) or ( not FRun ) or ( FParent = nil ) then
    Result := false
  else
    Result := true;
end;


function TInvestStrangle.CheckOrder( aCon : TOrderCon; iSide: integer; d1, d2, d3 : double ) : integer;
begin
  Result := 0;

  if aCon = nil then Exit;

  if (( iSide > 0 ) and ( d1 < aCon.Value )) or
    (( iSide < 0 ) and ( d1 > -aCon.Value )) then
    Exit;

  if FParam.UseInvest then
  begin
    if iSide > 0 then
      if d2 < 0 then Exit;
    if iSide < 0 then
      if d2 > 0 then Exit;
  end;

  if FParam.UseCnt then
  begin
    if iSide > 0 then
      if d3 < 0 then Exit;
    if iSide < 0 then
      if d3 > 0 then Exit;
  end;

  Result := iSide;
end;

function TInvestStrangle.NextOrder( aCon : TOrderCon; iSide: integer; d2 : double ) : integer;
begin
  Result := 0;
  if aCon = nil then Exit;

  if (( iSide > 0 ) and ( d2 < aCon.Value )) or
    (( iSide < 0 ) and ( d2 > -aCon.Value )) then
    Exit;

  Result := iSide;
end;

function TInvestStrangle.HedgeOrder: integer;
var
  dPL : double;
  i, iVol, iOpen : Integer;
  aSg : TStrangleAccount;
begin
  Result := 0;
  if  not FParam.useHedge then Exit;

  if FParam.RvsAmt <= 0 then Exit;

  dPL := 0;    iOpen := 0;  iVol := 0;
  for I := 0 to FStgs.Count - 1 do
  begin
    aSg := TStrangleAccount( FStgs.Items[i] );
    dPL := dPL + aSg.Positions.GetOpenPL( aSg.Account, iOpen) ;
    ivol:= iVol + aSg.Multi;
  end;

  if dPL < (FParam.RvsAmt * iVol * -10000) then
  begin
    DoLog( Format('Hedge  %.0f < %.0f ', [ dPL / 10000, FParam.RvsAmt * iVol * FParam.OrdQty ]));
    Result := FOrdSide * -1;
  end;
end;

procedure TInvestStrangle.OnQuote(Sender : TObject);
begin
  //OnTimer;
end;

procedure TInvestStrangle.OnTimer;
var
  dtNow : TDateTime;
  iSide, iSide2, iDir  : integer;
  bJang : boolean;
  d1, d2, d3 : double;
  aCon  : TOrderCon;
begin

  dtNow := Frac( now );
  if not IsRun then Exit;

  if dtNow < FParam.StartTime then Exit;

  if dtNow > FParam.Endtime then
  begin
    TFrmInvestStrangle( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;

  d1 := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetTojaja( FParam.Ivt1Code );
  d2 := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetToSinglejaja( FParam.Ivt2Code );
  d3 := gEnv.Engine.SymbolCore.Future.CntRatio;

  iSide := ifThen( d1 > 0, 1,
           ifThen( d1 < 0, -1, 0) );
  if iSide = 0 then Exit;

  if iSide > 0 then
    aCon  := FIvt1Plus.GetNextLv
  else
    aCon  := FIvt1Minus.GetNextLv;

  // ???? ????..
  if ( FOrdSide = 0 ) and ( not FIsBegin ) and ( FOrderCnt < FParam.EntryCnt ) then
  begin
    iDir  := CheckOrder( aCon, iSide, d1, d2, d3 );
    if iDir <> 0 then
    begin
      DoLog( Format('???????? : %s ( %.0f, %.0f, %.2f )', [ ifThenStr( iDir > 0,'????????','????????'),
        d1, d2, d3]));
      // ????
      FIsBegin := true;
      FOrdSide := iDir;
      DoOrder;
      aCon.Ordered  := true;
      inc( FOrderCnt );
    end;
  end
  else begin
    if ( FOrdSide = iSide ) and ( FOrderCnt < FParam.EntryCnt ) then
    begin
      // 1. ????????   -----------------------------------------------------------
      iDir := CheckOrder( aCon, iSide, d1, d2, d3 );
      if iDir <> 0 then begin
        DoLog( Format('%d. ???????? : %s ( %.0f, %.0f, %.2f )', [ FOrderCnt+1, ifThenStr( iDir > 0,'????????','????????'),
          d1, d2, d3]));
        // ???? ????
        DoOrder;
        aCon.Ordered  := true;
        inc( FOrderCnt );
      end;

      // 2. ????.. ---------------------------------------------------------------
      if (FParam.OrderMethod in [ omBuy, omSell ]) and ( FOrderCnt < FParam.EntryCnt )  then
      begin
        iSide2 := ifThen( d2 > 0, 1,
                  ifThen( d2 < 0, -1, 0) );
        // ?????? ????????..
        if FOrdSide + iSide2 = 0 then
        begin
          if iSide2 > 0 then
            aCon  := FIvt2Plus.GetNextLv
          else
            aCon  := FIvt2Minus.GetNextLv;

          iDir  := NextOrder( aCon, iSide2, d2 );
          if iDir <> 0 then
          begin
            DoLog( Format('%d. ???? : %s ( %.0f, %.0f )', [ FHedgeCnt+1, ifThenStr( iDir > 0,'????????','????????'),
              d1, d2 ]));
            DoOrder( false );
            aCon.Ordered := true;
            inc( FHedgeCnt );
            inc( FOrderCnt );
          end;
        end;

        // ???????? ?????? ???? ????..
        if (not FIsHedge)  then
        begin
          iDir := HedgeOrder;
          if iDir <> 0 then
          begin
            FIsHedge := true;
            //DoLog( Format('%d. ???? : %s ( %.0f, %.0f )', [ FHedgeCnt+1, ifThenStr( iDir > 0,'????????','????????'),
            //  d1, d2 ]));
            DoOrder( false );
            inc( FOrderCnt );
            inc( FHedgeCnt );
          end;
        end;
      end;
    end
    // 3. ????  ------------------------------------------------------------------
    else if ( FOrdSide <> 0 ) and  (FOrdSide + iSide = 0 ) then
    begin
      DoLog( '???? ???? ???? ');
      DoLossCut;
      FLossCut := false;
    end;
  end;

  if CheckLiskAmt then
    DoLossCut;
  // ???? ????...
end;

function TInvestStrangle.CheckLiskAmt : boolean;
var
  dPL : double;
  iVol, i : Integer;
  aSg : TStrangleAccount;
begin
  Result := false;
  if FParam.LiskAmt <= 0 then Exit;

  dPL := 0;  iVol := 0;
  for I := 0 to FStgs.Count - 1 do
  begin
    aSg := TStrangleAccount( FStgs.Items[i] );
    dPL := dPL + aSg.TotPL;
    iVol:= iVol + aSg.Multi;
  end;

  FNowPL := dPL / 1000;
  FMaxPL := Max( FNowPL, FMaxPL );
  FMinPL := min( FNowPL, FMinPL );

  if dPL < (FParam.LiskAmt * iVol *  -10000) then
  begin
    Result := true;
    DoLog( Format('????  %.0f < %.0f ', [ dPL / 10000, FParam.LiskAmt * iVol * -1 ]));
  end;

end;

procedure TInvestStrangle.Reset( bInit : boolean );
var
  i : integer;
begin

  if bInit then begin
    FLossCut  := false;
    FIsHedge  := false;
    FNowPL:= 0;
    FMinPL:= 0;
    FMaxPL:= 0;

    FOrderCnt := 0;
    FHedgeCnt := 0;
  end;

  FOrdSide  := 0;
  FIsBegin  := false;

  for I := 0 to FIvt1Plus.Size - 1 do
  begin
    FIvt1Plus[i].Ordered  := false;
    FIvt1Minus[i].Ordered := false;
  end;

  for I := 0 to FIvt2Plus.Size - 1 do
  begin
    FIvt2Plus[i].Ordered  := false;
    FIvt2Minus[i].Ordered := false;
  end;
end;

procedure TInvestStrangle.SetParam(const Value: TInvestStrangleParam);
var
  i : integer;
begin
  FParam := Value;

  for I := 0 to FIvt1Plus.Size - 1 do
  begin
    FIvt1Plus[i].Checked   := FParam.Ivt1Plue[i];
    FIvt1Minus[i].Checked  := FParam.Ivt1Minus[i];

    FIvt1Plus[i].Value     := FParam.Ivt1Value[i];
    FIvt1Minus[i].Value     := FParam.Ivt1Value[i];
  end;

  for I := 0 to FIvt2Plus.Size - 1 do
  begin
    FIvt2Plus[i].Checked   := FParam.Ivt2Plue[i];
    FIvt2Minus[i].Checked  := FParam.Ivt2Minus[i];

    FIvt2Plus[i].Value     := FParam.Ivt2Value[i];
    FIvt2Minus[i].Value     := FParam.Ivt2Value[i];
  end;
end;

function TInvestStrangle.Start: boolean;
begin
  Result := false;
  FSymbol := gEnv.Engine.SymbolCore.Future;

  if ( FSymbol = nil ) or ( FStgs.Count <= 0) then Exit;

  FRun := true;
  Result := true;

  DoLog( '?????? ??????  Start' );

end;

procedure TInvestStrangle.StgAccountLog(value: string; idx: integer);
begin
  DoLog( Value );
end;

procedure TInvestStrangle.Stop;
begin
  FRun := false;
  if FParam.UseLiq then
    DoLossCut;

  DoLog( '?????? ??????  Stop' );
end;


procedure TInvestStrangle.UpdateParam(iDiv: integer; bVal: boolean);
begin
 case iDiv of
  0 : FParam.UseLiq := bVal ;
  1 : FParam.UseInvest  := bVal ;
  2 : FParam.UseCnt := bVal ;
  3 : FParam.useHedge := bVal ;
 end;
end;

procedure TInvestStrangle.DoLossCut;
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

  DoLog( '???? ????  ????' );

  FLossCut := true;
  Reset(false);
end;


procedure TInvestStrangle.DoOrder(aSgAcnt: TStrangleAccount; aSymbol : TSymbol;
  iQty, iSide : integer; bLiq : boolean );
var
  aOrder : TOrder;
begin
  aOrder  := aSgAcnt.DoOrder( aSymbol, iQty, iSide );
  if aOrder <> nil then
    DoLog( Format('%s ???? : %s', [  ifThenStr( bLiq , '????','????'), aOrder.Represent3 ]))
  else
    DoLog( Format('%s ???????? : %s, %s, %s, %d', [ ifThenStr( bLiq , '????','????'),
      aSgAcnt.Account.Name, aSymbol.ShortCode,
      ifThenStr( iSide > 0, '????','????')  , iQty    ]));
end;

function TInvestStrangle.GetOption( cDiv : char; dPrice : double) : TSymbol;
var
  arList : TList;
  aSymbol: TSymbol;
begin
  try
    Result := nil;
    arList  := TList.Create;

    if cDiv = 'C' then
      gEnv.Engine.SymbolCore.GetCurCallList( dPrice, 0, 10, arList )
    else
      gEnv.Engine.SymbolCore.GetCurPutList( dPrice, 0, 10, arList );

    if arList.Count > 0 then
      Result := TSymbol( arList.Items[0] );
  finally
    arList.free;
  end;
end;



procedure TInvestStrangle.DoOrder( bMain : boolean );
var
  cDiv : char;
  dPrice : double;
  aSymbol, aSymbol2: TSymbol;
  arList : TList;

  I: Integer;

  aAcnt : TStrangleAccount;
begin
  // ???? ????????.
  if FOrdSide = 0 then Exit;  

  case FParam.OrderMethod of
    omBuy   :
      begin
        if bMain then
        begin
          if FOrdSide > 0 then
            cDiv := 'C'
          else
            cDiv := 'P';

          if FOrderCnt = 0 then
            dPrice := 0.7
          else
            dPrice := 1.0;

          aSymbol := GetOption( cDiv, dPrice );
        end
        else begin
          if FOrdSide > 0 then
            cDiv := 'P'
          else
            cDiv := 'C';

          if FHedgeCnt = 0 then
            dPrice := 0.7
          else
            dPrice := 1.0;

          aSymbol := GetOption( cDiv, dPrice );
        end;
      end ;
    omSell  :
      begin
        if bMain then 
        begin
          if FOrdSide > 0 then
            cDiv := 'P'
          else
            cDiv := 'C';
          aSymbol := GetOption( cDiv, 1.0 );
        end else
        begin
          if FOrdSide > 0 then
            cDiv := 'C'
          else
            cDiv := 'P';
          aSymbol := GetOption( cDiv, 1.0 );
        end;
      end;
    omSpBuy :
      try
        arList  := TList.Create;
        if FOrdSide > 0 then
          gEnv.Engine.SymbolCore.GetCurCallList( 0.7, arList )
        else
          gEnv.Engine.SymbolCore.GetCurPutList( 0.7, arList );

        if arList.Count >= 2 then
        begin
          aSymbol  := TSymbol( arList.Items[ arList.Count-1 ] );    // ???? ????
          aSymbol2 := TSymbol( arList.Items[ arList.Count-2 ] );    // ???? ????
        end;
      finally
        arList.free;
      end;

    omSpSell:
        if FOrdSide > 0 then
        begin
          aSymbol  := GetOption( 'P', 1.0 );
          aSymbol2 := GetOption( 'C', 0.7 );
        end else
        begin
          aSymbol  := GetOption( 'C', 1.0 );
          aSymbol2 := GetOption( 'P', 0.7 );
        end;
  end;

  case FParam.OrderMethod of
    omBuy, omSell:
      if aSymbol = nil then
      begin
        DoLog( '???????? ????');
        Exit;
      end;
    omSpBuy, omSpSell:
      if (aSymbol = nil) or ( aSymbol2 = nil ) then
      begin
        DoLog( '???????? ????');
        Exit;
      end;
  end;

  // ???? Add
  for I := 0 to FStgs.Count - 1 do
  begin
    aAcnt  := TStrangleAccount( FStgs.Items[i] );

    case FParam.OrderMethod of
      omBuy : DoOrder( aAcnt, aSymbol, FParam.OrdQty, 1);
      omSell: DoOrder( aAcnt, aSymbol, FParam.OrdQty, -1);
      omSpBuy:
        begin
          DoOrder( aAcnt, aSymbol, FParam.OrdQty, 1);
          DoOrder( aAcnt, aSymbol2, FParam.OrdQty, -1);
        end;
      omSpSell:
        begin
          DoOrder( aAcnt, aSymbol, FParam.OrdQty, -1);
          DoOrder( aAcnt, aSymbol2, FParam.OrdQty, -1);
        end;
    end;
    // ????
  end;

end;


end.
