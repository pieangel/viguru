unit CleBHultEx;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFORMOrderItems,
  UObjectBase, UPaveConfig, CleQuoteTimers,
  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleInvestorData,
  CleFunds,
  GleTypes, GleConsts
  ;

const

  Lc_ord = '0';   // ????   // OrderTag = -300
  Para_Liq_Ord = '3';        // OrderTag = -100

  Liq_Ord  = '2';    // OrderTag = 300
  Ent_Ord = '1';     // OrderTag = 0

  ENT_CNT = 0;
  ENT_FOR = 1;
  ENT_PT  = 2;

  LIQ_CNT = 4;
  LIQ_FOR = 5;
  LIQ_PT  = 6;

  STOP_LIQ = 100;

type

  TjarvisEventType = ( jetLog, jetStop );
  TjarvisEvent  = procedure( Sender : TObject; jetType : TjarvisEventType; stData : string ) of object;

  TBHultEx = class(TCollectionItem)
  private

    FJarvisData: TJarvisData;
    FSymbol : TSymbol;
    FReady : boolean;
    FLossCut : boolean;
    FOnPositionEvent: TObjectNotifyEvent;

    FMinPL, FMaxPL : double;
    FOrderItem: TOrderItem;

    FOnJarvisEvent: TjarvisEvent;
    FOrders: TOrderList;

    FAccount: TAccount;
    FParent: TObject;
    FRun: boolean;
    FOrdSide: integer;
    FIsFund : boolean;
    FFund: TFund;

    FEnterd: boolean;
    FMultiple: integer;
    //FEnterForFut: integer;
    FEnterPrice: double;
    FEntryCnt: integer;
    FNowPL: double;
    FOrderSymbol: TSymbol;
    FPositions: TList;
    FEnterForFut: integer;
    FForeignerFut: integer;
    FInit : boolean;
    FCount : integer;
    procedure OnLcTimer( Sender : TObject );

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure Reset;
    procedure OrderReset;

    function IsRun : boolean;

    procedure DoLog( stLog : string ); overload;
    procedure DoOrder( aQuote : TQuote; iDir : integer; bNext : boolean = false ); overload;
    procedure DoOrder( aQuote : TQuote; aAccount : TAccount; iQty, iSide : integer;
          bLiq : boolean = false ); overload;

    procedure DoLossCut(aQuote: TQuote; bLos : boolean = true); overload;
    procedure DoLosCut( aPos : TPosition ) ;overload;
    procedure DoLosCut( aPos : TFundPosition ); overload;
    procedure DoLossCut; overload;

    function CheckEntryCondition: integer;
    function CheckNextCondition : integer;

    function CheckLiquid(aQuote: TQuote): boolean;
    function CheckLiskAmt : boolean;

    procedure CheckOrderState(aOrder: TOrder);
    procedure OnOrder(aOrder: TOrder; EventID: TDistributorID);
    procedure OnPosition(aPosition: TPosition; EventID: TDistributorID);
    procedure OnQuote(aQuote: TQuote; iData: integer);

    function GetOrderSymbol( var iSide : integer ): TSymbol;
    function GetOption(cDiv: char; dPrice: double): TSymbol;
    procedure SavePL;

    function GetVolume: integer;
    function GetAvgPrice: double;
    function GetPL : double;

  public

    OrderCnt  : array [ TPositionType] of integer;

    constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol; aObj : TObject ; iMulti : integer = 1 ); overload;
    procedure init( aFund : TFund;    aSymbol : TSymbol; aObj : TObject ; iMulti : integer = 1); overload;
    function  Start : boolean;
    Procedure Stop( bCnl : boolean = true );

    procedure UpdateParam( iDiv : integer; bUse : boolean; Val1, Val2 : integer ) ; overload;
    procedure UpdateParam( iDiv : integer; bUse : boolean; Val1, Val2 : double  ) ; overload;

    property JarvisData: TJarvisData read FJarvisData write FJarvisData;

    property Fund    : TFund    read FFund;
    property Account : TAccount read  FAccount;
    property Parent : TObject read FParent;

    property OrderItem : TOrderItem read FOrderItem;
    property Orders : TOrderList read FOrders;
    property Positions : TList read FPositions;

    // ?ֹ??? ????
    property OrderSymbol    : TSymbol   read FOrderSymbol;

    // ???º?????
    property Run   : boolean read FRun;
    property OrdSide  : integer read FOrdSide;
    property LossCut  : boolean read FLossCut;
    property Count    : integer read FCount;
      // value
    property Enterd   : boolean read FEnterd;
    property EnterForFut : integer read FEnterForFut;
    property EnterPrice  : double  read FEnterPrice;
    property EntryCnt    : integer read FEntryCnt;
    property ForeignerFut : integer read FForeignerFut;

    property Volume      : integer read GetVolume;

    property MinPL : double read  FMinPL;
    property MaxPL : double read  FMaxPL;
    property NowPL : double read  FNowPL;
    // ?ݵ??? ????
    property Multiple : integer read FMultiple;

    property OnPositionEvent : TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property OnJarvisEvent   : TjarvisEvent read FOnJarvisEvent write FOnJarvisEvent;

  end;

  var
    RebootType : char;
implementation

uses
  GAppEnv, GleLib,

  FBHult
  ;

{ TBHultAxis }


constructor TBHultEx.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FOrders     := TOrderList.Create;

  FAccount  := nil;
  FParent   := nil;
  FFund     := nil;
  FIsFund   := false;


  FOrderItem  := nil;

  FPositions:= TList.Create;

end;

destructor TBHultEx.Destroy;
begin
  FPositions.Free;
  FOrders.Free;
  inherited;
end;

procedure TBHultEx.init(aAcnt: TAccount; aSymbol : TSymbol; aObj: TObject; iMulti : integer);
begin
  FAccount  := aAcnt;
  FParent   := aObj;
  FSymbol   := aSymbol;
  FFund     := nil;
  FMultiple := iMulti;
  Reset;
end;

procedure TBHultEx.init(aFund: TFund; aSymbol : TSymbol; aObj: TObject; iMulti : integer);
begin
  FFund     := aFund;
  FParent   := aObj;
  FSymbol   := aSymbol;
  FIsFund   := true;
  FAccount  := nil;
  FMultiple := iMulti;
  Reset;
end;


function TBHultEx.CheckEntryCondition : integer;
var
  i, iVolume, iSide : integer;
  dGap : double;
  bCheck  : array [0..2] of boolean;
  stLog : string;
  aType : TPositionType;
begin

  Result := 0;

  if( OrderCnt[ptLong] >= FjarvisData.OrdCnt ) and ( OrderCnt[ ptShort] >= FJarvisData.OrdCnt ) then Exit;

  for I := 0 to High( bCheck ) do bCheck[i] := false;

  with FJarvisData do
  begin

    if ( not UseEntCntRate ) and ( not UseEntForeignQty ) and ( not UseEntPoint ) then Exit;

    if ( FSymbol.DayOpen + PRICE_EPSILON ) <  FSymbol.Last then
      iSide := 1
    else if ( FSymbol.DayOpen - PRICE_EPSILON ) > FSymbol.Last then
      iSide := -1
    else
      Exit;

    if iSide > 0 then
      aType := ptLong
    else
      aType := ptShort;

    if OrderCnt[aType] >= FJarvisData.OrdCnt then Exit;

    // iside > 0 ?̸? ?϶???
    // iside < 0 ?̸? ??????

    stLog := ifThenStr( iSide > 0 ,'?????? : ' , '?϶??? : ' );

    //----------------------------------------------------------------------------
    if UseEntCntRate then
    begin
      if ( iSide > 0 ) and ( FSymbol.CntRatio > 0 ) and ( FSymbol.CntRatio < CntRate ) then
      begin
        bCheck[0] := true;
        stLog     := Format('?Ǽ? %.2f ( %.2f ) ', [  FSymbol.CntRatio , CntRate ]) ;
      end else
      if ( iSide < 0 ) and ( FSymbol.CntRatio < 0 ) and ( abs(FSymbol.CntRatio) < CntRate ) then
      begin
        bCheck[0] := true;
        stLog     := Format('?Ǽ? %.2f ( %.2f ) ', [  FSymbol.CntRatio , CntRate ]) ;
      end
    end else
    begin
      bCheck[0]  := true;
      stLog := '?Ǽ??? ?̻???';
    end;
    //----------------------------------------------------------------------------

    if UseEntForeignQty then
    begin
      if ( iSide > 0 ) and ( ForeignerFut > ForeignQty ) then
        bCheck[1] := true
      else if ( iSide < 0 ) and ( ForeignerFut < -ForeignQty ) then
        bCheck[1] := true;

      if bCheck[1]  then
      begin
        stLog := stLog + '   ' +  Format('?ܱ??? ????  %d ( %d ) ', [  ForeignerFut , ForeignQty ]) ;
        bCheck[1] := true;
      end;
    end else
    begin
      stLog := stLog + '   ?ܱ??μ???  ?̻???';
      bCheck[1]  := true;
    end;

    //----------------------------------------------------------------------------

    if  UseEntPoint then
    begin
      dGap  := FSymbol.Last - FSymbol.DayOpen ;
      if (( iSide > 0 ) and ( dGap >= Point1 )) or
         (( iSide < 0 ) and ( dGap <= -Point1 )) then
      begin
        stLog := stLog + '   ' + Format(' Point %.2f ( %.2f ) ', [ dGap,Point1 ]) ;
        bCheck[2] := true;
      end;
    end else
    begin
      stLog := stLog + '   Point  ?̻???';
      bCheck[2]  := true;
    end;

    //----------------------------------------------------------------------------
  end;

  iVolume := 0;

  for i := 0 to High(bCheck) do
    if bCheck[i] then
      inc(iVolume );

  if (iVolume = 3) then
  begin
    Result  := iSide ;
    FEnterForFut := ForeignerFut;
    //FEnterPrice  := (FSymbol.Last + FEnterPrice ) / ( FEntryCnt + 1 ) ;
    FEnterPrice  := FSymbol.Last;

    if iSide > 0 then
      i := OrderCnt[ptLong] + 1
    else
      i := OrderCnt[ptShort] + 1;

    DoLog( Format('%d.%d. th ?? %s ?غ? -> %s ',
          [ i, EntryCnt + 1, ifThenStr( Result > 0 , '?ż?', '?ŵ?') , stLog 
          ]));
  end;
end;

function TBHultEx.CheckNextCondition: integer;
var
  dGap : double;
begin
  Result := 0;
  // 1?? ?????? ????Ʈ ??ȭ?? ???? 2?? ????
  with JarvisData do
  begin
    if not UseEntPoint then Exit;
    if Point2 < PRICE_EPSILON then  Exit;

    dGap  := FSymbol.Last - FSymbol.DayOpen ;
    if (( FOrdSide > 0 ) and ( dGap >= Point2 )) or
       (( FOrdSide < 0 ) and ( dGap <= -Point2 )) then
    begin
      DoLog(
        Format('%d.%d. th ?غ? Point2 %.2f ( %.2f ) ', [
          ifThen( FOrdSide > 0, OrderCnt[ptLong], OrderCnt[ptShort] ), EntryCnt + 1,
          dGap,Point2 ])
      );
      Result:= FOrdSide;
    end;

  end;
end;


procedure TBHultEx.DoLog(stLog: string);
begin

  if ( not FIsFund ) and ( Account <> nil ) then
    gEnv.EnvLog( WIN_BHULT, stLog, false, Account.Code)
  else if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_BHULT, stLog, false, FFund.Name );

  if Assigned( FOnJarvisEvent ) then
    FOnJarvisEvent( Self, jetLog , stLog  );

end;

procedure TBHultEx.DoLossCut(aQuote: TQuote; bLos : boolean);
var
  I: Integer;
begin

  for I := Positions.Count - 1 downto 0 do
    DoLosCut( TPosition( Positions.Items[i] ));

  FLossCut := bLos;
  DoLog( 'û?? ?Ϸ?  ????' );
  OrderReset;

end;

procedure TBHultEx.DoLosCut(aPos: TPosition);
begin
  if ( aPos = nil ) or ( aPos.Volume = 0 ) or ( aPos.Symbol.Quote = nil ) then Exit;

  if FIsFund then begin
    if FFund.FundItems.Find2( aPos.Account ) < 0 then Exit;
  end
  else begin
    if aPos.Account <> FAccount then Exit;
  end;

  DoOrder( aPos.Symbol.Quote as TQuote , aPos.Account, abs(aPos.Volume), aPos.Side * -1, true );
end;

procedure TBHultEx.DoLosCut(aPos: TFundPosition);
begin

end;

procedure TBHultEx.DoLossCut;
begin
    DoLossCut( nil );
end;

procedure TBHultEx.DoOrder(aQuote: TQuote; iDir: integer; bNext : boolean);
var
  iQty, I, iSide: Integer;
  aType : TPositionType;
  aSymbol : TSymbol;
  aItem : TFundItem;
begin

  FOrdSide := iDir;
  iQty     := FJarvisData.OrdQty * FMultiple;

  if iDir > 0 then
    aType := ptLong
  else
    aType := ptShort;
  // ???? ????..
  iSide   := 0;

  if ( bNext ) and ( FOrderSymbol <> nil ) then
  begin
    aSymbol := FOrderSymbol;
    GetOrderSymbol( iSide );
  end
  else begin
    aSymbol := GetOrderSymbol( iSide );

    if aSymbol = nil then
    begin
      DoLog( Format('%s  ???????? ???? ', [ ifThenStr( FOrdSide > 0, '????', '?϶?')]));
      Exit;
    end;

    if aSymbol.Quote = nil then
    begin
      DoLog( Format('%s  ???? ???? ???? - %s ', [ ifThenStr( FOrdSide > 0, '????', '?϶?'),
        aSymbol.ShortCode  ]));
      Exit;
    end;

    if iSide = 0 then
    begin
      DoLog( Format('%s  ?ֹ????? ???? - %s ', [ ifThenStr( FOrdSide > 0, '????', '?϶?'),
        aSymbol.ShortCode  ]));
      Exit;
    end;
    FOrderSymbol := aSymbol;
  end;

  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aItem := FFund.FundItems.FundItem[i];
      DoOrder( aSymbol.Quote as TQuote, aItem.Account , iQty * aItem.Multiple , iSide );
    end;
  end else
    DoOrder( aSymbol.Quote as TQuote, FAccount, iQty, iSide );

  if ( not FEnterd ) and ( FEntryCnt = 0 ) then
    FEnterd     := true;
  inc( FEntryCnt );
  if not bNext  then
    inc( OrderCnt[aType] );

end;

function TBHultEx.GetOption(cDiv: char; dPrice: double): TSymbol;
var
  arList : TList;
  aSymbol: TSymbol;
begin
  try
    Result := nil;
    arList  := TList.Create;

    if cDiv = 'C' then
      gEnv.Engine.SymbolCore.GetCurCallList( dPrice, 0, 5, arList, FJarvisData.SubMakDiv = 1 )
    else
      gEnv.Engine.SymbolCore.GetCurPutList( dPrice, 0, 5, arList, FJarvisData.SubMakDiv = 1 );

    if arList.Count > 0 then
    begin
      Result := TSymbol( arList.Items[0] );
    end;
  finally
    arList.free;
  end;
end;

function TBHultEx.GetOrderSymbol( var iSide : integer ) : TSymbol;
var
  cDiv : char;
begin
  Result := nil;

  if FJarvisData.MarketDiv = 0 then
  begin
    if FJarvisData.SubMakDiv = 0 then
      Result  := FSymbol
    else
      Result  := gEnv.Engine.SymbolCore.MiniFuture;
    iSide := FOrdSide;
  end else
  begin

    if FJarvisData.UseBuy then
    begin
      if FOrdSide > 0 then
        cDiv := 'C'
      else
        cDiv := 'P';
      iSide := 1;
    end else
    begin
      if FOrdSide > 0 then
        cDiv := 'P'
      else
        cDiv := 'C';
      iSide := -1;
    end;
    Result := GetOption( cDiv, FJarvisData.BelowPrc );
  end;

end;

procedure TBHultEx.DoOrder(aQuote: TQuote; aAccount: TAccount; iQty, iSide : integer;
  bLiq: boolean);
var
  dPrice : double;
  stErr  : string;
  aTicket: TOrderTicket;
  aOrder : TOrder;
  bRes   : boolean;
begin
  if ( aAccount = nil ) then Exit;
  // ?ű?
  if iSide > 0 then
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
  else
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );

  bRes   := CheckPrice( aQuote.Symbol, Format('%.*f', [aQuote.Symbol.Spec.Precision, dPrice]),
    stErr );

  if (iQty = 0 ) or ( not bRes ) then
  begin
    DoLog( Format(' ?ֹ? ???? ?̻? : %s, %s, %d, %.2f - %s',  [ Account.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice, stErr ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    aOrder.OrderSpecies := opJarvis;
    Orders.Add( aOrder );
    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( bLiq, 'û??', '?ű?' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '?ż?','?ŵ?'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;

end;


function TBHultEx.IsRun: boolean;
var
  st4, st1, st2, st3 : string;
begin

  if ( not FRun ) or ( FSymbol = nil ) or ( FParent = nil ) then
    Result := false
  else begin
    if (( FIsFund ) and ( FFund <> nil )) or
       (( not FIsFund ) and ( FAccount <> nil )) then
      Result := true
    else
      Result := false;
  end;

  if (FCount < 30) and ( FCount > 0 ) and ( not Result ) then
  begin
    st1 := '';  st2 := ''; st3 := ''; st4 := '';
    if not FRun then st1 := 'Fun = false';
    if FSymbol = nil then st2 := 'Symbol = nil';
    if FParent = nil then st3 := 'Parent = nil';
    if FAccount = nil then st4:= 'Acnt = nil';    

    gEnv.EnvLog( WIN_BHULT,
      Format('%s, %s, %s, %s, %s ', [
        ifThenStr( FIsFund , 'Fund', 'Acnt'),
        st1, st2, st3, st4
        ]));
  end;

end;


procedure TBHultEx.OnLcTimer(Sender: TObject);
begin
end;

procedure TBHultEx.OnOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  // normal ?? ?????? ?о??????츦 ?????ؼ?
  if aOrder.OrderSpecies <> opJarvis then exit;

  if FIsFund then begin
    if FFund.FundItems.Find2( aOrder.Account ) < 0 then Exit;
  end
  else begin
    if aOrder.Account <> FAccount then Exit;
  end;

  CheckOrderState( aOrder );
end;

procedure  TBHultEx.CheckOrderState( aOrder : TOrder ) ;
begin
  if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // ????ü??/?????ֹ?
    FOrders.Remove( aOrder );
end;

procedure TBHultEx.OnPosition(aPosition: TPosition; EventID: TDistributorID);
begin
  if aPosition.Symbol <> FOrderSymbol then Exit;
  if FPositions.IndexOf( aPosition ) >= 0 then Exit;

  if FIsFund then begin
    if FFund.FundItems.Find2( aPosition.Account ) < 0 then Exit;
  end
  else begin
    if ( aPosition.Account <> FAccount ) then  Exit;
  end;

  FPositions.Add( aPosition );
end;


function TBHultEx.GetAvgPrice: double;
begin

end;
function TBHultEx.GetVolume: integer;
var
  I: Integer;
begin
  Result := 0;
  try
    for I := 0 to FPositions.Count - 1 do
      Result := Result + TPosition(FPositions.Items[i]).Volume ;
  except
    Result := 0;
  end;
end;
function TBHultEx.GetPL: double;

var
  I: Integer;
begin
  Result := 0;
  try
    for I := 0 to FPositions.Count - 1 do
      Result := Result + TPosition(FPositions.Items[i]).LastPL ;
  except
    Result := 0;
  end;
end;

procedure TBHultEx.SavePL;
var
  dPL : double;
begin
  dPL := 0;

  if FIsFund then
    dPL := gEnv.Engine.TradeCore.FundPositions.GetFundPL( FFund )
  else
    dPL := gEnv.Engine.TradeCore.Positions.GetPL( FAccount );

  FMaxPL  := Max( FMaxPL, dPL );
  FMinPL  := Min( FMinPL, dPL );
  FNowPL  := dPL;
end;

procedure TBHultEx.OnQuote(aQuote: TQuote; iData: integer);
var
  dtNow : TDateTime;
  bTerm : boolean;
  iDir  : integer;
  st1   : string;
begin
  try

  st1 := '1';

  if aQuote.LastEvent = qtTimeNSale then
    inc( FCount );

  try
    SavePL;
  except
    if FCount < 30 then gEnv.EnvLog( WIN_BHULT, 'save pl error' );
  end;

  st1 := '2';

  if not IsRun then Exit;
  // ?????? 30 ?? ?????? ??ü?? ??????
  FForeignerFut  := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetToSun;

  if ( FForeignerFut <> 0 ) and ( not FInit ) then
  begin
    DoLog( Format( '?ܱ??? ???? : %d', [  FForeignerFut ]));
    FInit := true;
  end;

  st1 := '3';

  dtNow := Frac( Now );
  bTerm := false;

  if aQuote.AddTerm then
    bTerm := true;

  if dtNow >= FJarvisData.Endtime then
  begin
    DoLog('?????? ?ð?');
    TFrmBHult( FParent).cbStart.Checked := false;
    Exit;
  end;

  st1 := '4';

  if FLossCut then Exit;
  // ????
  if( dtNow >= FJarvisData.StartTime ) then    // ???۽ð?
  begin
    if ( FOrdSide = 0 )  and  ( not FEnterd )  then
    begin
      iDir  := CheckEntryCondition;
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir );
        Exit;
      end;
    end else
    if ( FOrdSide <> 0 ) and ( FEnterd ) and ( EntryCnt = 1 ) then
    begin
      iDir  := CheckNextCondition;
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir, true );
        Exit;
      end;
    end;
  end;

  st1 := '5';

  if FOrdSide = 0  then Exit;
  // ????
  if CheckLiquid( aQuote ) then
  begin
    DoLossCut( aQuote, false );
    Exit;
  end;

  if CheckLiskAmt then
    DoLossCut( aQuote );

  except
    if FCount < 30 then gEnv.EnvLog( WIN_BHULT, st1 +  '  onQuote error' );
  end;
end;

procedure TBHultEx.OrderReset;
begin
  FOrders.Clear;
//  FPositions.Clear;

  FOrderSymbol:= nil;
  FEnterForFut:= 0;
  FEnterPrice := 0;
  FEntryCnt   := 0;
  FEnterd     := false;
  FOrdSide    := 0;
end;

procedure TBHultEx.Reset;
begin
  fRun    := false;
  FReady  := false;
  FLossCut:= false;
  FInit   := false;
  FCount  := 0;

  FOrdSide := 0;
  FForeignerFut:=  0;
  OrderCnt[ ptLong] := 0;
  OrderCnt[ ptShort]:= 0;
  FMinPL  := 0; FMaxPL  := 0;

  FOrders.Clear;
  FPositions.Clear;

  OrderReset;

end;

function TBHultEx.Start: boolean;
begin
  Result := false;
  if FIsFund then
    if ( FFund = nil ) or ( FSymbol = nil ) then Exit;
  if not FIsFund then
    if ( FAccount = nil ) or ( FSymbol = nil ) then Exit;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  if gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc ) = nil then Exit;
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  DoLog( ifThenStr( FIsFund, 'Fund', 'Account' ) + '  Bamboo Start' );

  FRun   := true;
  Result := true;

end;

procedure TBHultEx.Stop( bCnl : boolean = true );
begin
  FRun := false;
{
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
}
  if FJarvisData.UseStopLiq then
    DoLossCut;

  DoLog( ifThenStr( FIsFund, 'Fund', 'Account' ) + '  Bamboo Stop' );
end;


procedure TBHultEx.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aOrder : TOrder;
begin
  if not IsRun then Exit;

  if  ( Receiver <> Self ) or ( DataObj = nil ) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED      : OnOrder( DataObj as TOrder, EventID );
    POSITION_NEW,
    POSITION_UPDATE   : OnPosition( DataObj as TPosition, EventID );

  end;

end;

procedure TBHultEx.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
    OnQuote( DataObj as TQuote, DataID );
end;


function TBHultEx.CheckLiquid( aQuote : TQuote ) : boolean;
var
  i, iVolume, iSide : integer;
  dGap , dPrice: double;
  bCheck  : array [0..2] of boolean;
  stLog : string;
begin

  Result := false;

  for I := 0 to High( bCheck ) do bCheck[i] := false;

  with FJarvisData do
  begin

    if ( not UseLiqCntRate ) and ( not UseLiqForeignQty ) and ( not UseLiqPoint ) then Exit;

    stLog := ifThenStr( iSide > 0 ,'????û?? : ' , '?϶?û?? : ' );
    //----------------------------------------------------------------------------
    if UseLiqCntRate then
    begin
      if ( FOrdSide > 0 ) and ( FSymbol.CntRatio < 0 ) and ( abs(FSymbol.CntRatio) < LiqCntRate ) then
      begin
        bCheck[0] := true;
        stLog     := Format('?Ǽ? %.2f ( %.2f ) ', [  FSymbol.CntRatio , LiqCntRate ]) ;
      end else
      if ( FOrdSide < 0 ) and ( FSymbol.CntRatio > 0 ) and ( FSymbol.CntRatio < LiqCntRate ) then
      begin
        bCheck[0] := true;
        stLog     := Format('?Ǽ? %.2f ( %.2f ) ', [  FSymbol.CntRatio , LiqCntRate ]) ;
      end;
    end else
    begin
      if LiqUseAnd then bCheck[0]  := true;
      stLog := '?Ǽ??? ?̻???';
    end;
    //----------------------------------------------------------------------------

    if UseLiqForeignQty then
    begin

      if FOrdSide > 0 then
        FEnterForFut  := Max( FEnterForFut, ForeignerFut)
      else if FOrdSide < 0 then
        FEnterForFut  := Min( FEnterForFut, ForeignerFut);

      dGap  := FEnterForFut - ( FEnterForFut * LiqForeignPer );
      if  FOrdSide > 0 then
      begin
        if ForeignerFut < dGap  then
          bCheck[1] := true
        else if ForeignerFut < 0 then
          bCheck[1] := true;
      end else
      if FOrdSide < 0 then
      begin
        if ForeignerFut > dGap then
          bCheck[1] := true
        else if ForeignerFut > 0 then
          bCheck[1] := true;
      end;

      if bCheck[1]  then
      begin
        stLog := stLog + '   ' +  Format('?ܱ??? ????  %d ( %.1f < %d ) ', [  ForeignerFut , dGap, FEnterForFut ]) ;
        bCheck[1] := true;
      end;

    end else
    begin
      stLog := stLog + '   ?ܱ??μ???  ?̻???';
      if LiqUseAnd then bCheck[1]  := true;
    end;

    //----------------------------------------------------------------------------

    if  UseLiqPoint then
    begin

      if FEnterPrice > PRICE_EPSILON then
      begin

        if FOrdSide > 0 then begin
          FEnterPrice := Max( FSymbol.Last , FEnterPrice );
          dGap := FEnterPrice - FSymbol.Last;
        end
        else if FOrdSide < 0 then begin
          FEnterPrice := Min( FSymbol.Last , FEnterPrice );
          dGap := FSymbol.Last - FEnterPrice;
        end;

        if dGap > LiqPoint then
        begin
          stLog := stLog + '   ' + Format(' Point %.2f = %.2f <-- %.2f ) ', [ dGap, FSymbol.Last ,FEnterPrice ]) ;
          bCheck[2] := true;
        end;
      end;
    end else
    begin
      stLog := stLog + '   Point  ?̻???';
      if LiqUseAnd then bCheck[2]  := true;
    end;

    //----------------------------------------------------------------------------
  end;

  iVolume := 0;

  for i := 0 to High(bCheck)-1 do
    if bCheck[i] then
      inc(iVolume );

  if ((iVolume = 3) and ( FJarvisData.LiqUseAnd ))  or
    (( iVolume > 0) and ( not FJarvisData.LiqUseAnd )) then
  begin
    Result  := true;
    DoLog( Format('%s %s %s ',  [ ifThenStr( FOrdSide > 0 , '?ż?', '?ŵ?') ,
      stLog , ifThenStr( FjarvisData.LiqUseAnd, '(And)', '(Or)' )
       ]));
  end;

end;

function TBHultEx.CheckLiskAmt: boolean;
var
  I: Integer;
begin

  Result := false;

  if FNowPL < 0 then
    if -FJarvisData.LiskAmt > FNowPL then
    begin
      Result := true;
      DoLog( Format('?ѵ??ʰ? (%.0f < %.0f ) ',  [ FNowPL/1000, -FJarvisData.LiskAmt  ]));
    end;
end;

procedure TBHultEx.UpdateParam(iDiv : integer; bUse : boolean; Val1, Val2: integer);
begin
  with FJarvisData do
  case iDiv of
    ENT_CNT :
      begin
        UseEntCntRate := bUse;
        CntRate       := Val1;        
      end ;
    ENT_FOR :
      begin
        UseEntForeignQty  := bUse;
        ForeignQty        := Val1;
      end ;
    ENT_PT  :
      begin
        UseEntPoint := bUse;
        Point1      := Val1; Point2 := Val2;
      end ;

    LIQ_CNT :
      begin
        UseLiqCntRate := bUse;
        LIqCntRate    := Val1;
      end ;
    LIQ_FOR :
      begin
        UseLiqForeignQty  := bUse;
        LiqForeignPer     := Val1;
      end ;
    LIQ_PT  :
      begin
        UseLiqPoint := bUse;
        LiqPoint    := Val1;
      end ;
    STOP_LIQ  : UseStopLiq := bUse;
  end;
end;


procedure TBHultEx.UpdateParam(iDiv: integer; bUse : boolean; Val1, Val2: double);
begin
  with FJarvisData do
  case iDiv of
    ENT_CNT :
      begin
        UseEntCntRate := bUse;
        CntRate       := Val1;        
      end ;
    ENT_FOR : ;

    ENT_PT  :
      begin
        UseEntPoint := bUse;
        Point1      := Val1; Point2 := Val2;
      end ;

    LIQ_CNT :
      begin
        UseLiqCntRate := bUse;
        LIqCntRate    := Val1;
      end ;
    LIQ_FOR :
      begin
        UseLiqForeignQty  := bUse;
        LiqForeignPer     := Val1;
      end ;
    LIQ_PT  :
      begin
        UseLiqPoint := bUse;
        LiqPoint    := Val1;
      end ;
    STOP_LIQ  : UseStopLiq := bUse;
  end;
end;




end.
