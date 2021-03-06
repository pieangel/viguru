unit CleUnderStrangle;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleAccounts, CleOrders, ClePositions, CleQuoteBroker, CleFunds, Ticks,

  CleStrategyAccounts,

  CleDistributor,  CleStrangleConfig,

  GleTypes
  ;

type

  TUnderStrangle = class
  private
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;

    FParent: TObject;
    FOnNotify: TTextNotifyEvent;
    FParam: TUnderStrangleParam;
    FPuts: TSymbolList;
    FCalls: TSymbolList;
    FStgs: TList;
    FNowPL: double;
    FMinPL: double;
    FMaxPL: double;
    FIsBegin: boolean;
    FOrderCnt: integer;
    FRun: boolean;
    FLossCut: boolean;
    FOrdSide: integer;
    FUndPlus: TOrderCons;
    FUndMinus: TOrderCons;

    FSymbol : TSymbol;

    procedure SetParam(const Value: TUnderStrangleParam);
    procedure DoLog( stData : string );
    procedure StgAccountLog( value : string; idx : integer );
    function IsRun: boolean;
    procedure Reset( bInit : boolean = true );
    procedure DoLossCut;
    procedure DoOrder( bMain : boolean = true ) ; overload;
    procedure DoOrder(aSgAcnt: TStrangleAccount; aSymbol: TSymbol; iQty,
      iSide: integer; bLiq: boolean = false ); overload;
    procedure OnQuote( Sender : TObject );

    function CheckOrder( aCon : TOrderCon; iSide: integer; dGap : double ): integer;
    function CheckLiskAmt: boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function Start : boolean;
    Procedure Stop;

    function init( aAcnt : TAccount; aObj : TObject ) : boolean; overload;
    function init( aFund : TFund; aObj : TObject ) : boolean; overload;

    procedure UpdateSymbols( aCalls,  aPuts : TList );

    property Param  : TUnderStrangleParam read FParam write SetParam;
    property Parent : TObject read FParent write FParent;
    property Calls  : TSymbolList read FCalls;
    property Puts   : TSymbolList read FPuts;
    property Stgs   : TList read FStgs write FStgs;

    property MaxPL : double read FMaxPL;
    property NowPL : double read FNowPL;
    property MinPL : double read FMinPL;

    property Run      : boolean read FRun;
    property LossCut  : boolean read FLossCut;
    property IsBegin  : boolean read FIsBegin;

    property OrdSide  : integer read FOrdSide;
    property OrderCnt : integer read FOrderCnt;

    property UndPlus  : TOrderCons read FUndPlus;
    property UndMinus : TOrderCons read FUndMinus;

    property OnNotify  : TTextNotifyEvent read FOnNotify write FOnNotify;
  end;

implementation

uses
  GAppEnv, GleLib , Math,
  FleUnderStrangle
  ;

{ TUnderStrangle }

function TUnderStrangle.CheckLiskAmt: boolean;
var
  dPL : double;
  i : Integer;
  aSg : TStrangleAccount;
begin
  Result := false;
  if FParam.LiskAmt <= 0 then Exit;

  dPL := 0;
  for I := 0 to FStgs.Count - 1 do
  begin
    aSg := TStrangleAccount( FStgs.Items[i] );
    dPL := dPL + aSg.TotPL;
  end;

  FNowPL := dPL / 1000;
  FMaxPL := Max( FNowPL, FMaxPL );
  FMinPL := min( FNowPL, FMinPL );

  if dPL < (FParam.LiskAmt * -10000) then
  begin
    DoLog( Format('????  %.0f < %.0f ', [ dPL / 10000, FParam.LiskAmt ]));
    Result := true;
  end;

end;

function TUnderStrangle.CheckOrder(aCon: TOrderCon; iSide: integer;
  dGap: double): integer;
begin
  Result := 0;

  if aCon = nil then Exit;

  if (( iSide > 0 ) and ( dGap < aCon.Value )) or
    (( iSide < 0 ) and ( dGap > -aCon.Value )) then
    Exit;

  Result := iSide;
end;

constructor TUnderStrangle.Create;
begin
  FPuts := TSymbolList.Create;
  FCalls:= TSymbolList.Create;

  FStgs:= TList.Create;

  FUndPlus:= TOrderCons.Create;
  FUndMinus:= TOrderCons.Create;

  FUndPlus.Size := 5;
  FUndMinus.Size  := 5;

  FIsFund := false;
end;

destructor TUnderStrangle.Destroy;
begin
  FUndPlus.Free;
  FUndMinus.Free;
  FStgs.Free;
  FPuts.Free;
  FCalls.Free;
  inherited;
end;

procedure TUnderStrangle.DoLog(stData: string);
begin

  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_STR3, stData, false, FFund.Name )
  else if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( WIN_STR3, stData, false, FAccount.Name );

  if Assigned( FOnNotify ) then
    FOnNotify( Self, stData );
end;

function TUnderStrangle.init(aAcnt: TAccount; aObj: TObject): boolean;
var
  aItem : TStrangleAccount;
begin
  FStgs.Clear;
  aItem := TStrangleAccount.Create( gEnv.Engine.TradeCore.StrategyGate.GetStrategys,
    opStrangle3, stStrangle3, true );
  aItem.init( aAcnt, 0 );
  aItem.OnQuote := OnQuote;
  FStgs.Add( aItem );
  aItem.OnText := StgAccountLog;

  FAccount := aAcnt;
  FIsFund  := false;

  FParent := aObj;
  Reset;

end;

function TUnderStrangle.init(aFund: TFund; aObj: TObject): boolean;
var
  I: Integer;
  aItem : TStrangleAccount;
begin
  FStgs.Clear;
  for I := 0 to aFund.FundItems.Count - 1 do
  begin
    aItem := TStrangleAccount.Create( gEnv.Engine.TradeCore.StrategyGate.GetStrategys,
      opStrangle3, stStrangle3, true );
    aItem.init( aFund.FundAccount[i], i );
    aItem.OnQuote := OnQuote;
    FStgs.Add( aItem );
    aItem.OnText := StgAccountLog;
  end;

  FFund   := aFund;
  FIsFund := true;

  FParent := aObj;
  Reset;

end;

function TUnderStrangle.IsRun: boolean;
begin
  if ( FStgs.Count <= 0 ) or ( not FRun ) or ( FParent = nil ) or
    ( FCalls.Count <= 0 ) or ( FPuts.Count <= 0 )  then
    Result := false
  else
    Result := true;
end;

procedure TUnderStrangle.OnQuote(Sender: TObject);
var
  dtNow : TDateTime;
  iSide, iSide2, iDir  : integer;
  bJang : boolean;
  dGap  : double;
  aCon  : TOrderCon;
begin
  dtNow := Frac( now );
  if not IsRun then Exit;

  if dtNow < FParam.StartTime then Exit;

  if dtNow > FParam.Endtime then
  begin
    TFrmUnderStrangle( FParent).cbRun.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;

  dGap := FSymbol.Last - FSymbol.DayOpen;
  iSide := ifThen( dGap > 0, 1,
           ifThen( dGap < 0, -1, 0 ));
  if iSide = 0 then Exit;
  if iSide > 0 then
    aCon := FUndPlus.GetNextLv
  else
    aCon := FUndMinus.GetNextLv;

  // ????????.
  if ( FOrderCnt < FParam.EntryCnt ) then

  if ( FOrdSide = 0 ) and ( not FIsBegin )  then
  begin
    iDir := CheckOrder( aCon, iSide, dGap );
    if iDir <> 0 then
    begin
      DoLog( Format('???????? : %s ( %.2f, %.2f, %.2f )', [ ifThenStr( iDir > 0,'????????','????????'),
        FSymbol.DayOpen , FSymbol.Last, dGap]));
      // ????
      FIsBegin := true;
      FOrdSide := iDir;
      DoOrder;
      aCon.Ordered  := true;
      inc( FOrderCnt );
    end;
  end else
  begin
  // ????????
    if FOrdSide = iSide  then
    begin
      iDir := CheckOrder( aCon, iSide, dGap );
      if iDir <> 0 then
      begin
        DoLog( Format('%d. ???????? : %s ( %.2f, %.2f, %.2f )', [ FOrderCnt+1, ifThenStr( iDir > 0,'????????','????????'),
          FSymbol.DayOpen , FSymbol.Last, dGap]));
        // ????
        DoOrder;
        aCon.Ordered  := true;
        inc( FOrderCnt );
      end;
    end else
    if FOrdSide + iSide = 0 then
    begin
      DoLog( '???? ???? ???? ');
      DoLossCut;
      FLossCut := false;
    end;
  end;

  if CheckLiskAmt then
    DoLossCut;

end;

procedure TUnderStrangle.Reset(bInit: boolean);
var
  i : integer;
begin

  if bInit then begin
    FLossCut  := false;
    FNowPL:= 0;
    FMinPL:= 0;
    FMaxPL:= 0;

    FOrderCnt := 0;
  end;

  FOrdSide  := 0;
  FIsBegin  := false;

  for I := 0 to FUndPlus.Size - 1 do
  begin
    FUndPlus[i].Ordered  := false;
    FUndMinus[i].Ordered := false;
  end;

end;

procedure TUnderStrangle.SetParam(const Value: TUnderStrangleParam);
var
  i : integer;
begin
  FParam := Value;

  for I := 0 to FUndPlus.Size - 1 do
  begin
    FUndPlus[i].Checked   := FParam.UndPlus[i];
    FUndMinus[i].Checked  := FParam.UndMinus[i];

    FUndPlus[i].Value     := FParam.UndValue[i];
    FUndMinus[i].Value     := FParam.UndValue[i];
  end;
end;

procedure TUnderStrangle.StgAccountLog(value: string; idx: integer);
begin
  DoLog( Value );
end;

function TUnderStrangle.Start: boolean;
begin
  Result := false;
  FSymbol := gEnv.Engine.SymbolCore.Future;

  if ( FSymbol = nil ) or ( FStgs.Count <= 0) then Exit;

  FRun := true;
  Result := true;
end;

procedure TUnderStrangle.Stop;
begin
  FRun := false;
  if FParam.UseLiq then
    DoLossCut;

  DoLog( '?????? ??????  Stop' );
end;

procedure TUnderStrangle.DoLossCut;
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


procedure TUnderStrangle.DoOrder(bMain: boolean);
var
  i, j : integer;
  aAcnt : TStrangleAccount;
  aSymbol : TSymbol;
begin

  if FOrdSide = 0 then Exit;
  
  // ???? Add
  for j := 0 to FStgs.Count - 1 do
  begin
    aAcnt  := TStrangleAccount( FStgs.Items[j] );

    case FParam.OrderMethod of
      omBuy :
        begin
          for I := 0 to FCalls.Count - 1 do
            DoOrder( aAcnt, FCalls.Symbols[i], FParam.OrdQty, 1);
          for I := 0 to FPuts.Count - 1 do
            DoOrder( aACnt, FPuts.Symbols[i], FParam.OrdQty, 1);
        end;
      omSell:
        begin
          for I := 0 to FCalls.Count - 1 do
            DoOrder( aAcnt, FCalls.Symbols[i], FParam.OrdQty, -1);
          for I := 0 to FPuts.Count - 1 do
            DoOrder( aACnt, FPuts.Symbols[i], FParam.OrdQty, -1);
        end;
    end;
    // ????
  end;
end;

procedure TUnderStrangle.DoOrder(aSgAcnt: TStrangleAccount; aSymbol : TSymbol;
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

procedure TUnderStrangle.UpdateSymbols(aCalls, aPuts: TList);
var
  i : integer;
  aSymbol : TSymbol;
begin
  FPuts.Clear;
  FCalls.Clear;
    
  for I := 0 to aCalls.Count - 1 do
  begin
    aSymbol := TSymbol( aCalls.Items[i] );
    FCalls.AddSymbol( aSymbol );
  end;

  for I := 0 to aPuts.Count - 1 do
  begin
    aSymbol := TSymbol( aPuts.Items[i] );
    FPuts.AddSymbol( aSymbol );
  end;
  
end;

end.
