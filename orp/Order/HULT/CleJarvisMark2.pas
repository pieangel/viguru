unit CleJarvisMark2;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleAccounts,

  CleSymbols, ClePositions, CleOrders, CleFills, CleFORMOrderItems,

  UObjectBase, UPaveConfig, CleQuoteTimers,

  CleDistributor, CleQuoteBroker, CleKrxSymbols,   UOscillators, UOscillatorBase,

  GleTypes, GleConsts , CleLogPL
  ;

const
  Los_ord = '400';   // 손절
  Prf_Ord = '300';   // 이익
  Pav_Ord = '200';   // 깔아놓는 주문..
  Ent_Ord = '100';   // 진입

type

  TjarvisEventType = ( jetLog, jetStop, jetPause );
  TjarvisEvent  = procedure( Sender : TObject; jetType : TjarvisEventType; stData : string ) of object;

  TJarvis2 = class(TTradeBase)
  private

    FJarvisData: TJarvisData2;

    FOrdDir: integer;
    FLosPara, {FPrfPara,} FLosOtr : boolean;  // 파라로는 이익, 손실 한번씩만 하기때문에
    FOrdCnt : integer;    // 주문회수
    FLosCnt : integer;    // 손절 카운트 --> 2번에 나누어 하기때문에  --->  지금은 안씀..
    FSaveCnt: double;     // 진입할때 건수
    FSaveVol: double;
    FCalcCnt: double;     // 계산 건수
    FCalcVol: double;

    FLimitOrdCnt : Integer;

    FLossCut : boolean;

    FLcTimer : TQuoteTimer;
    FOnPositionEvent: TObjectNotifyEvent;

    FEntryCount: integer;

    FOption: TSymbol;
    FOnJarvisEvent: TjarvisEvent;

    FOrders: TOrderList; // 깔아논 주문
    FHits  : TOrderList;

    FOrgPL  : TLogPL;
    FPara: TParabolicSignal;
    FPause: boolean;


    procedure OnLcTimer( Sender : TObject );

    procedure OnQuote( aQuote : TQuote; iData : integer ); override;
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID ); override;
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID  ); override;
    procedure OnTerm( aQuote : TQuote );

    procedure Reset;
    procedure OrderReset;

    function IsRun : boolean;
    procedure UpdateQuote(aQuote: TQuote; bTerm : boolean = false);

    procedure OnFill(aOrder : TOrder);

    procedure DoLog( stLog : string ); overload;

    procedure Save;
    function CheckEntryCondition( aQuote : TQuote ): integer;

    procedure CheckOrderState(aOrder: TOrder);
    function GetLiquidQty(iSide: integer): integer;

    procedure DoOrder(iQty, iSide: integer; dPrice: double; stDiv: string);
    procedure DoChangeOrder( aTarget : TOrder; dPrice: double; stDiv: string );
    procedure DoCancels( iSide : integer );

    function GetOrdDesc(stDiv: string): string;
    procedure CheckLiskAmt( aQuote : TQuote );

    function GetOrdPrice(iSide: integer; aQuote: TQuote): double;
    function GetOrderQty(iVolume : integer): integer;
    function GetPaveOrder : TOrder;
    procedure calcSaveCnt(aQuote: TQuote);
    procedure DoLiquid;
    procedure CalcLimitOrdCnt;
    function CheckOrderCount( iSide : integer ): integer;

    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure TestLiqFill(aQuote: TQuote; iSide :Integer);
    procedure calcSaveVol(aQuote: TQuote);

  public

    OrdNum  : integer;
    Multi   : Integer;

    constructor Create(aColl: TCollection ); override;
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol; aType : integer); override;

    function  Start : boolean;
    Procedure Stop( bCnl : boolean = true );

    // only test
    Procedure DoTest( idx :integer );
    //

    property JarvisData: TJarvisData2 read FJarvisData write FJarvisData;
    property Option : TSymbol read FOption write FOption;

    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;

    property CalcCnt    : double read FCalcCnt  write FCalcCnt;
    property SaveCnt    : double read FSaveCnt;

    property CalcVol    : double read FCalcVol  write FCalcVol;
    property SaveVol    : double read FSaveVol;

    property LimitOrdCnt: integer read FLimitOrdCnt;
    property OrdCnt: integer read FOrdCnt;
    property EntryCount : integer read FEntryCount write FEntryCount;
    property Pause : boolean read FPause write FPause;

    property Orders : TOrderList read FOrders write FOrders;
    property Para: TParabolicSignal read FPara write FPara;

    property OnJarvisEvent : TjarvisEvent read FOnJarvisEvent write FOnJarvisEvent;

  end;


  TJarvis2s = class( TCollection )
  private
    function GetJarvis(i: integer): TJarvis2;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( stCode : string ) : TJarvis2;
    function Find( aObj : TObject ) : TJarvis2;
    property Jarvis[ i : integer] : TJarvis2 read GetJarvis;
  end;

implementation

uses
  GAppEnv, GleLib;

{ TBHultAxis }

constructor TJarvis2.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 1000;
  FLcTimer.OnTimer := OnLcTimer;

  FOrders     := TOrderList.Create;
  FHits       := TOrderList.Create;

  Multi       := 1;
  Reset;

end;

destructor TJarvis2.Destroy;
begin

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  FOrders.Free;
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);
  inherited;
end;

procedure TJarvis2.DoCancels(iSide: integer);
var
  I: Integer;
  aOrder, aTarget : TOrder;
  aTicket: TOrderTicket;
begin

  if iSide = 0 then
  begin
    for I := FOrders.Count -1 downto 0 do
    begin
      aTarget  := FOrders.Orders[i];
      if ( aTarget.State = osActive ) and ( aTarget.Account = Account ) and
         ( aTarget.ActiveQty > 0 ) and ( not aTarget.Modify ) and ( aTarget.OrderType = otNormal ) and
         ( aTarget.OrderSpecies = opJarvis2 ) then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aTarget, aTarget.ActiveQty, aTicket );
        if aOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Send( aTicket );
          FOrders.Delete(i);
        end;
      end;
    end;
  end
  else
    for I := FOrders.Count -1 downto 0 do
    begin
      aTarget  := FOrders.Orders[i];

      if ( aTarget.State = osActive ) and ( aTarget.Side = iSide ) and ( aTarget.Account = Account ) and
         ( aTarget.ActiveQty > 0 ) and ( not aTarget.Modify ) and ( aTarget.OrderType = otNormal ) and
         ( aTarget.OrderSpecies = opJarvis2 ) then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aTarget, aTarget.ActiveQty, aTicket );
        if aOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Send( aTicket );
          FOrders.Delete(i);
        end;
      end;
    end;
end;



procedure TJarvis2.OnFill(aOrder: TOrder);
var
  stSufix,stLog : string;
  aQuote : TQuote;
  aFill : TFill;
  iOrdQty , iOrdQty2, iTmp, iTmp2: integer;
  dPrice : double;
  bDone : boolean;
begin

    aFill := Position.LastFill;
    bDone := false;
    stSufix := Format('%s ,%.2f, %d, %d ', [ SideToStr( aOrder.Side ), aOrder.FilledPrice, aOrder.FilledQty, aOrder.OrderNo ] );
    case aOrder.OrderTag of
      0, 300, 400 :
        begin
          if ( aOrder.State = osFilled )  then
          begin
            case aOrder.OrderTag of
              0   : stLog := Format('사용자 임의 체결 -> %s ', [ stSufix ] );
              300 : stLog := Format('이익 체결 -> %s ', [ stSufix ] );
              400 : stLog := Format('손실 체결 -> %s ', [ stSufix ] );
            end;

            DoLog( stLog );
            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , stLog );
            if Position.Volume = 0 then bDone := true;
          end;
        end;
      200 :  // 깔아놓은 주문 체결 -> PrfPoint
        begin
          if ( aOrder.State = osFilled )  then
          begin
            inc( FOrdCnt );
            stLog := Format('깔아놓은 주문 체결 -> %s', [ stSufix ]);
            DoLog( stLog );
            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , stLog );
            if Position.Volume = 0 then bDone := true;
          end;
        end;
      100 :  // 진입 ... 이익청산에 주믄을 대놓는다..
        begin
          if ( aOrder.State = osFilled )  then
          begin
            iOrdQty := JarvisData.OrdQty div 2;
            iTmp    := Round( FJarvisData.PrfPoint / aOrder.Symbol.Spec.TickSize );
            dPrice  := TicksFromPrice( aOrder.Symbol, aOrder.FilledPrice, iTmp * aOrder.Side );

            DoOrder( iOrdQty , -aOrder.Side ,  dPrice, Pav_Ord );
            stLog := Format('%s 체결 --> 1.th  %s 청산주문 %.2f 에 %d 계약 깔기', [
                stSufix, SidetoStr( -aOrder.Side),   dPrice,  iOrdQty ]);
            DoLog( stLog );
            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , stLog );

            // 2 번째 이익 청산에 주문 대 놓기
            if FJarvisData.PrfPoint2 > 0 then
            begin
              iOrdQty2 := (aOrder.FilledQty - iOrdQty) div 2;
              if iOrdQty2 > 0 then
              begin
                iTmp    := Round( (FJarvisData.PrfPoint + FJarvisData.PrfPoint2) / aOrder.Symbol.Spec.TickSize );
                dPrice  := TicksFromPrice( aOrder.Symbol, aOrder.FilledPrice, iTmp * aOrder.Side );

                DoOrder( iOrdQty2 , -aOrder.Side ,  dPrice, Pav_Ord );
                stLog := Format('%s 체결 --> 2.th %s 청산주문 %.2f 에 %d 계약 깔기', [
                    stSufix, SidetoStr( -aOrder.Side),   dPrice,  iOrdQty2 ]);
                DoLog( stLog );
                if Assigned( FOnJarvisEvent ) then
                  FOnJarvisEvent( Self, jetLog , stLog );
              end;
            end;
            // 2번째 이익 청산

          end;
        end;
    end;

    if bDone then
    begin
      OrderReset;
      stLog := Format('%d. th 완료 후 리셋 --> 손익 %.0f', [  FEntryCount, Position.LastPL /1000 ]);
      DoLog( stLog );
            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , stLog );
    end;
end;


function TJarvis2.CheckEntryCondition( aQuote : TQuote ) : integer;
var
  i, iSide : integer;
  bCheck :  boolean;
  stLog : string;
  iSum , iCnt : integer;
  iRes : array [0..2] of integer;

begin

  Result := 0;

  // And 조건에서 Or 조건으로 수정 20190424
  for I := 0 to High(iRes)  do
    iRes[i] := 0;
  iCnt := 0;   iSum := 0;
  //1.  건수 체크
  if FJarvisData.UseEntryCnt then
  begin
    inc( iCnt );
    if ( aQuote.CntRatio > 0 )  and ( aQuote.CntRatio <= FJarvisData.EntryCnt ) then
      iRes[0] := 1
    else if ( aQuote.CntRatio < 0 ) and  ( abs(aQuote.CntRatio) <= FJarvisData.EntryCnt ) then
      iRes[0] := -1;

    stLog := Format('건수체크: %s -> (%d , %d) ,  (%.2f , %.2f) ', [
      ifThenStr( iRes[0] = 1, '매수',  ifThenStr( iRes[0] = -1,  '매도', 'No') ),
      aQuote.Bids.CntTotal , aQuote.Asks.CntTotal ,  aQuote.CntRatio,  FJarvisData.EntryCnt ]);
  end;

  //2. 잔량 체크
  if FJarvisData.UseEntryVol then
  begin
    inc( iCnt );
    if ( aQuote.VolRatio  > 0 )  and ( aQuote.VolRatio <= FJarvisData.EntryVol  ) then
      iRes[1] := 1
    else if ( aQuote.VolRatio < 0 ) and  ( abs(aQuote.VolRatio) <= FJarvisData.EntryVol ) then
      iRes[1] := -1;


    stLog := stLog + ' | ' + Format('잔량체크: %s -> (%d , %d) ,  (%.2f , %.2f) ', [
      ifThenStr( iRes[1] = 1, '매수',  ifThenStr( iRes[1] = -1,  '매도', 'No') ),
      aQuote.Bids.VolumeTotal , aQuote.Asks.VolumeTotal ,  aQuote.VolRatio,  FJarvisData.EntryVol ]);
  end;

  //3. Para
  if FJarvisData.UseEntryPara then begin
    inc( iCnt );
    iRes[2] := FPara.Side;
    stLog := stLog + ' | ' + Format('Para 체크: %s -> %d ' , [
        ifThenStr( iRes[2] = 1, '매수',  ifThenStr( iRes[2] = -1,  '매도', 'No')  )
        , FPara.Side
        ]);
  end;

  for I := 0 to High(iRes)  do
    iSum := iSum + iRes[i];

  if ( iCnt > 0 ) then
  begin
    if iSum = iCnt then
      Result := 1
    else if iSum = ( iCnt * -1 ) then
      Result := -1;
  end;

  // debug log
  DoLog( Format('%d = %d : %d ( %s ) ', [ Result, iSum, iCnt,  stLog ]) );

  if Result <> 0 then
  begin
    Result := CheckOrderCount( Result );
    if Result = 0 then Exit;
    
    inc(FEntryCount);

    FSaveCnt  :=  abs(aQuote.CntRatio);
    FSaveVol  :=  abs(aQuote.VolRatio);

    DoLog( Format('%d th %s 진입 %.2f  %.2f', [ FEntryCount ,
      ifThenStr( Result = 1, '매수', '매도') ,
      FSaveCnt,  FSaveVol
       ]));
  end;

end;

procedure TJarvis2.DoLog(stLog: string);
begin
  if Account <> nil then
    gEnv.EnvLog( WIN_BHULT, stLog, false, Account.Code);
end;

procedure TJarvis2.init(aAcnt : TAccount; aSymbol : TSymbol; aType : integer);
begin
  inherited ;//init( aAcnt, aSymbol, integer(opJarvis2) );
{
  FParaSymbol := aParaSymbol;

  FPara := gEnv.Engine.SymbolCore.ConsumerIndex.Paras.New( FParaSymbol, FJarvisData.AfValue );
  FHult := gEnv.Engine.VirtualTrade.GetHult( FJarvisData.TargetTick );
 }

  FPara := gEnv.Engine.SymbolCore.ConsumerIndex.Paras.New( aSymbol, FJarvisData.ParaVal );
  FOrgPL:= TLogPL.Create(5, FJarvisData.LiskAmt, 50 );
  FOrgPL.Reset;
  Reset;

  CalcLimitOrdCnt;
end;

procedure TJarvis2.CalcLimitOrdCnt;
var
  iQty : integer;
begin

  iQty := FJarvisData.OrdQty;
  FLimitOrdCnt  := 0;
  while iQty > 0 do
  begin
    iQty := iQty div 2;
    inc( FLimitOrdCnt );
  end;
  
  inc( FLimitOrdCnt );

  FLimitOrdCnt  := 3;
end;

function TJarvis2.IsRun: boolean;
begin
  if ( not Run ) or ( Symbol = nil ) or ( Account = nil ) then
    Result := false
  else
    Result := true;
end;

function TJarvis2.GetOrdDesc( stDiv : string ) : string;
begin
  if Los_ord = stDiv then
    Result := '손절'
  else if Prf_Ord = stDiv then
    Result := '이익'
  else if Pav_Ord =stDiv then
    Result := '이익 깔기'
  else if Ent_Ord = stDiv then
    Result := '진입'
  else Result := '';
end;

function TJarvis2.GetOrderQty(iVolume : integer): integer;
var
  iSide : integer;
  I, iTmp, iActive: Integer;
  aOrder : TOrder;
begin
  Result := 0;
  if iVolume = 0 then Exit;
  iSide := ifThen( iVolume > 0, 1, -1 );

  iActive := 0;
  for I := 0 to FHits.Count - 1 do
  begin
    aOrder  := FHits.Orders[i];
    if aOrder = nil then Continue;
    if (aOrder.Side = iSide) or ( aOrder.Account <> Account ) or
       (aOrder.Symbol <> Symbol) then continue;

    iTmp := 0;
    case aOrder.State of
      osActive : iTmp := aOrder.ActiveQty;
      osSent, osReady, osSrvAcpt  : iTmp := aOrder.OrderQty;
      else
        Continue;
    end;
    iActive := iActive + abs(iTmp);
  end;

  if iActive > 0 then begin
    if iActive >= abs( iVolume ) then
      Exit
    else
      Result := abs(iVolume ) - iActive;
  end
  else
    Result := abs( iVolume );
end;

procedure TJarvis2.DoOrder( iQty, iSide : integer; dPrice : double; stDiv : string );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
begin

  if ( dPrice < PRICE_EPSILON ) or ( iQty <= 0 ) then
  begin
    DoLog( Format(' 엇 !! %s 주문 인자 이상  %.2f, %d %s ', [
      ifThenStr( iSide > 0 , '매수','매도'),  dPrice, iQty, stDiv  ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, Symbol,
  iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opJarvis2;
    aOrder.OrderTag := StrToInt( stDiv );

    gEnv.Engine.TradeBroker.Send(aTicket);
    if stDiv = Pav_Ord then
      FOrders.Add( aOrder )
    else begin
      FHits.Add( aOrder );
      inc( FOrdCnt );
      if stDiv = Los_Ord then
        inc( FLosCnt)  ;
    end;

    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog , Format('%s 주문 %s %.2f %d', [
        GetOrdDesc(stDiv),
        ifThenStr( iSide > 0, 'L','S'), aOrder.Price, aOrder.OrderQty ])  );

    DoLog( Format('Send Order(%s) : %s, %s, %s, %.2f, %d', [ stDiv, Account.Code, Symbol.ShortCode,
      ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty ]));
  end;
end;

procedure TJarvis2.DoChangeOrder(aTarget: TOrder; dPrice: double;
  stDiv: string);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
begin

  if ( dPrice < PRICE_EPSILON ) or ( aTarget.ActiveQty <= 0 ) then
  begin
    DoLog( Format(' 엇 !! %s 정정 주문 인자 이상  %.2f, %d (%d) %s ', [
      ifThenStr( aTarget.Side > 0 , '매수','매도'),  dPrice, aTarget.ActiveQty, aTarget.OrderNo, stDiv  ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrder( aTarget, aTarget.ActiveQty, pcLimit,
    dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opJarvis2;
    aOrder.OrderTag := StrToInt( stDiv );

    gEnv.Engine.TradeBroker.Send(aTicket);
    if stDiv = Pav_Ord then
      FOrders.Add( aOrder )
    else begin
      FHits.Add( aOrder );
      inc( FOrdCnt );
      if stDiv = Los_Ord then
        inc( FLosCnt);
    end;

    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog , Format('%s 정정주문 %s %.2f %d', [
        GetOrdDesc(stDiv),
        ifThenStr( aOrder.Side > 0, 'L','S'), aOrder.Price, aOrder.OrderQty ])  );

    DoLog( Format('Send Change Order(%s) : %s, %s, %s, %.2f, %d (%d) ', [ stDiv, Account.Code, Symbol.ShortCode,
      ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty, aTarget.OrderNo ]));
  end;

end;

procedure TJarvis2.OnLcTimer(Sender: TObject);
begin
end;

procedure TJarvis2.OnOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  if not IsRun then Exit;
  if aOrder.Account <> Account then Exit;
  if aOrder.Symbol <> Symbol then Exit;
  
  // normal 은 손으로 털었을경우를 대비해서
  if not (aOrder.OrderSpecies in [ opNormal, opJarvis2 ]) then exit;

  if EventID in [ORDER_FILLED] then
    OnFill( aOrder );

  CheckOrderState( aOrder );
end;

procedure  TJarvis2.CheckOrderState( aOrder : TOrder ) ;
begin
  if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
    FOrders.Remove( aOrder );

  if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
    FHits.Remove( aOrder );
end;


function TJarvis2.GetLiquidQty( iSide : integer ) : integer;
var
  iTmp, I, iActive: Integer;
  aOrder  : TOrder;
begin

  Result := 0;
  if iSide = 0 then Exit;

  if iSide > 0 then
    iSide := 1
  else iSide := -1;

  iActive := 0;

  for I := 0 to FOrders.Count - 1 do
  begin
    aOrder  := FOrders.Orders[i];
    if (aORder = nil ) or ( aOrder.Side <> iSide ) or ( aOrder.OrderSpecies = opJarvis2 ) then Continue;

    iTmp := 0;
    case aOrder.State of
      osActive : iTmp := aOrder.ActiveQty;
      osSent, osReady, osSrvAcpt  : iTmp := aOrder.OrderQty;
      else
        Continue;
    end;

    iActive := iActive + itmp;
  end;

  if Position.Volume > 0 then
    Result := Position.Volume - iActive
  else
    Result := Position.Volume + iActive;

end;

procedure TJarvis2.OnPosition(aPosition: TPosition; EventID: TDistributorID);
begin

end;

procedure TJarvis2.OnQuote(aQuote: TQuote; iData: integer);
var
  dFut, dOpt, ds, dTot : double;
begin
  if iData = 300 then
    save;

  if not IsRun then Exit;

  if aQuote.Symbol <> Symbol then Exit;

  if frac(FJarvisData.StartTime) > frac(GetQuoteTime) then
    Exit; 

  if Account <> nil then
  begin
    dFut := 0; dOpt :=0; ds :=0;
    dTot  := gEnv.Engine.TradeCore.Positions.GetMarketPl( Account, dFut, dOpt, dS  );
    FOrgPL.OnPL( dTot - Account.GetFee );
  end;

  if FLossCut then Exit;
  if FPause then Exit;  

  if aQuote.AddTerm then
  begin
    OnTerm( aQuote );  // 진입과 파라 청산
    UpdateQuote( aQuote, true );
  end
  else
    UpdateQuote( aQuote );
end;

procedure TJarvis2.OnTerm(aQuote: TQuote);
var
  dPrice : double;

begin

  if (FOrdDir = 0) and ( Position.Volume = 0 )  then
  begin
    FOrdDir :=  CheckEntryCondition( aQuote );
    if FOrdDir <> 0 then
    begin

      dPrice  := GetOrdPrice( FOrdDir, aQuote );
      DoOrder( FJarvisData.OrdQty * Multi , FOrdDir, dPrice, Ent_Ord );
      inc( OrdNum );
      {
      if FOrdDir > 0 then
        inc( OrdNum[0] )
      else
        inc( OrdNum[1] );
      }
    end;
  end;
end;

function TJarvis2.CheckOrderCount( iSide : integer ) : integer;
begin

  Result := 0;

  if OrdNum < FJarvisData.LimitNum then
    Result := iSide
  else begin
    if (FJarvisData.UseOne) and ( Position.LastPL < 0 ) and
       (OrdNum < (FJarvisData.LimitNum + 1)) then
      Result := iSide;
  end;

end;

function TJarvis2.GetOrdPrice( iSide: integer; aQuote : TQuote ) : double;
begin

  Result := 0.0;
  if iSide = 0 then Exit;

  Result := TicksFromPrice( aQuote.Symbol, aQuote.Last, iSide * 10 );
  if iSide > 0 then
    Result  := aQuote.Asks[4].Price
  else
    Result  := aQuote.Bids[4].Price;
end;

function TJarvis2.GetPaveOrder: TOrder;
var
  aOrder : TOrder;
begin
  Result := nil;
  aOrder  := FORders.Orders[0];
  if ( aOrder <> nil ) and
       ( aOrder.State = osActive ) and ( aOrder.OrderType = otNormal ) and
       ( aOrder.OrderSpecies = opJarvis2 ) and ( not aOrder.Modify ) and
       ( aOrder.ActiveQty > 0 ) then
       Result := aOrder;
end;

procedure TJarvis2.OrderReset;
begin
  FLosPara := false;
  //FPrfPara := false;
  FLosOtr  := false;
  FOrdDir  := 0;
  FOrdCnt  := 0;
  FSaveCnt := 1;
  FSaveVol := 1;
  FCalcCnt := 1;
  FCalcVol := 1;
  FLosCnt  := 0;

  FOrders.Clear;
  FHits.Clear;
end;

procedure TJarvis2.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil )  then Exit;
  OnQuote( DataObj as TQuote, DataID );
end;

procedure TJarvis2.Save;
{
var
  stData, stFile : string;
  dTot, dFut, dOpt, dS : double;
  }
begin
         {
  if Account = nil then Exit;
  if Account.IsLog then Exit;
  Account.IsLog := true;

  FOrgPL.Fin;   
  Account.LogStr  := Format(',%.0f, %.0f, %.0f, '+
                             '%.0f,,%.0f,,%.0f,,%.0f,,%.0f,,'  ,
    [
    FOrgPL.NowPL / 1000, FOrgPL.MaxPL / 1000 , FOrgPL.MinPL / 1000,
    FOrgPL.PL[0],FOrgPL.PL[1],FOrgPL.PL[2],FOrgPL.PL[3], FOrgPL.PL[4]
    ])
    }
end;

procedure TJarvis2.Reset;
begin
  Run := false;

  FLossCut:= false;
  FPause  := false;
  OrderReset;
  FEntryCount := 0;

  OrdNum  := 0;

end;

function TJarvis2.Start: boolean;
begin
  Result := false;
  if ( Symbol = nil ) or ( Account = nil )  then Exit;

  Run := true;
  FOrgPL.Run := true;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  gEnv.Engine.QuoteBroker.Subscribe( Self, Symbol, QuotePrc ) ;
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  DoLog( Format('JM2 Start %s ', [Account.Code ]) );
end;

procedure TJarvis2.Stop( bCnl : boolean = true );
begin
  Run := false;
  if Account <> nil then
    DoLog( Format('JM2 Stop %s ', [ Account.Code ]) );
  DoLiquid;
end;


procedure TJarvis2.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: OnOrder(DataObj as TOrder, EventID);
      // position events
    POSITION_NEW,
    POSITION_UPDATE   : OnPosition(DataObj as TPosition, EventID);

  end;

end;

procedure TJarvis2.UpdateQuote(aQuote: TQuote; bTerm : boolean);
var
  stDiv, stLog : string;
  dCnt, dVol, dPrice, dPL : double;
  iQty, iTmp : integer;
  aTarget : TOrder;
  bAll, bLiq : boolean;

  bRes : array [0..1] of boolean;
  bRes2: array [0..2] of boolean;
begin

  if (Frac(FJarvisData.EndTime) <= Frac(GetQuoteTime)) then
  begin
    Stop;
    stLog := Format('시간끝 now : %s >= %s', [
      FormatDateTime('hh:nn:ss', GetQuoteTime),
      FormatDateTime('hh:nn:ss', FJarvisData.EndTime )
       ] );
    DoLog( stLog);
    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog ,  stLog );
    exit;
  end;

  if Position = nil then Exit;
  if Position.Volume = 0 then Exit;

  CheckLiskAmt( aQuote );
  if FLossCut then Exit;
  if FOrdDir = 0 then Exit;

  if ( not FJarvisData.UseProfCnt )
    and ( not FJarvisData.UseProfPara )
    and ( not FJarvisData.UseProfVol )
    and ( not FJarvisData.UseLossCnt )
    and ( not FJarvisData.UseLossPara )
    and ( not FJarvisData.UseLossVol ) then
    Exit;

  calcSaveCnt( aQuote );
  calcSaveVol( aQuote );
  {-----------------------------------------------------------------------------
  1. 평가손익이 + 일때
    a. 1포인트 이익 절반 ( 미리 대 놓는다 );
    b. para 반대 신호 절반 ( 1분 )  -- 한번만..
    c. 0.25 이하 전부청산  ( 실시간 )
    d. para 반대  and  건수 60% 일대 전부 청산 ( 1분 )
  2. 평가손익 - 일때
    a. para 반대 신호 절반 or 나머지( 1분 )  -- 한번만..
    b. 건수 60% 절반 or 0.8 일때 전부( 실시간 )

  3. 첫번째 청산일때는 ( FOrdCnt = 0 ) 1.a 주문을 이용한다.( 정정을 하란 애기)
    예외는.. 1.c  1.d
  -----------------------------------------------------------------------------}
  dPL := Position.EntryOTE / 1000.0;
  bLiq:= false;   bAll := false;

  dCnt  := abs( aQuote.Symbol.CntRatio );
  dVol  := abs( aQuote.Symbol.VolRatio );

  bRes2[0] := false; bRes2[1] := false; bRes2[2] := false;      

  if dPL > 0 then
  begin
    stDiv    := Prf_Ord;
    // 1. b
    {
    if ( bTerm ) and ( not FPrfPara) and (( FPara.Side + FOrdDir ) = 0) then
    begin
      bLiq     := true;
      FPrfPara := true;
      stLog := Format('파라에 의한 이익 청산 (%d th) 잔량 %d 건수 ( %.2f, %.2f , %.2f )', [
        FOrdCnt, Position.Volume, FSaveCnt, dCnt, aQuote.Last ]);
    end;
    }
    // 1.c  한방 청산
    // 20191117  잔량도 추가

    // 둘중에 하나는 반드시 체크 되어 있어야 함..
    if (not bLiq) and (FJarvisData.UseProfCnt or FJarvisData.UseProfVol) then
    begin
      bRes[0] := false;  bRes[1] := false;
      if  FJarvisData.UseProfCnt then
      begin
        if dCnt <= FJarvisData.PrfCnt then
          bRes[0] := true;
      end else bRes[0] := true;

      if FJarvisData.UseProfVol then
      begin
        if dVol <= FjarvisData.PrfVol then
          bRes[1] := true;
      end else bRes[1] := true;

      if bRes[0] and bRes[1] then
      begin
        bLiq := true;
        bAll := true;

        if Assigned( FOnJarvisEvent ) then
          FOnJarvisEvent( Self, jetPause , 'Pause' );

        stLog := Format('최소건수/잔량 의한 이익 전량 청산 (%d th) 잔량 %d 건수 ( %.2f -> %.2f  %.2f -> %.2f , %.2f )', [
          FOrdCnt, Position.Volume, FSaveCnt, dCnt, FSaveVol, dVol, aQuote.Last ]    );
      end;
    end;

    // 1.d ( 2019 05 15  건수와 파라 설정에 따라 따로 체크 )
    if (not bLiq) and bTerm then
    begin
      // 셋중 하나는 체크 되어 있어야 함.. -------------------------------------
      if ( FJarvisData.UseProfCnt ) or ( FJarvisData.UseProfPara ) or ( FJarvisData.UseProfVol ) then
      begin

        // 건수 비율 체크
        if  FJarvisData.UseProfCnt  then
        begin
          FCalcCnt  := FSaveCnt + FSaveCnt * (FJarvisData.PrfCntRate / 100);
          if dCnt > FCalcCnt then
            bRes2[0] := true;
        end else
          bRes2[0] := true;
        // 추가 옵션 20191117
        if FJarvisData.UseProfVol then
        begin
          FCalcVol  := FSaveVol + FSaveVol * (FJarvisData.PrfVolRate / 100);
          if dVol > FCalcVol then
            bRes2[1] := true;
        end else
          bRes2[1] := true;

        // 파라 체크
        if FJarvisData.UseProfPara then
        begin
          if (( FPara.Side + FOrdDir ) = 0) then
            bRes2[2] := true;
        end else
          bRes2[2] := true;

        //if (bTerm ) and (( FPara.Side + FOrdDir ) = 0) and ( dCnt > FCalcCnt ) then
        if bRes2[0] and bRes2[1] and bRes2[2] then
        begin
          bLiq := true;
          bAll := true;
          stLog := Format('건수/잔량비, para(%d) 변화에 의한 이익 전량 청산 (%d th) 잔량 %d 건수 (%.2f -> %.2f,  %.2f -> %.2f , %.2f )', [
            FPara.Side,
            FOrdCnt, Position.Volume, dCnt,  FCalcCnt,  dVol, FCalcVol, aQuote.Last ]);
        end;
      end;
      //------------------------------------------------------------------------
    end;
  end else
  if dPL < 0 then
  begin
    stDiv := Los_Ord;
    {
    if ( bTerm ) and ( not FLosPara) and (( FPara.Side + FOrdDir ) = 0) then
    begin
      bLiq     := true;
      FLosPara := true;

      stLog := Format('파라에 의한 손실 청산(%d.%dth) 잔량 %d 건수 ( %.2f, %.2f , %.2f )', [
        FOrdCnt, FLosCnt, Position.Volume, FSaveCnt, dCnt, aQuote.Last ]);
    end;
    if (not bLiq) and ( not FLosOtr) then
    }

    // 셋중 하나라도 체크 되어 있어야 한다.
    if ( FJarvisData.UseLossCnt ) or ( FJarvisData.UseLossPara ) or ( FJarvisData.UseLossVol ) then
    begin
      //if bTerm and ( not FLosOtr ) then
      if bTerm and ( not bLiq ) then
      begin
        if FJarvisData.UseLossCnt then
        begin
          FCalcCnt  := FSaveCnt + FSaveCnt * (FJarvisData.LosCntRate / 100);
          // 진입대비 비율 or 설정한 건수보다 클때..
          if ( dCnt > FCalcCnt ) or ( dCnt > FJarvisData.LosCnt ) then
            bRes2[0] := true;
        end else
          bRes2[0] := true;

        if FJarvisData.UseLossVol then
        begin
          FCalcVol  := FSaveVol + FSaveVol * (FJarvisData.LosVolRate / 100);
          // 진입대비 비율 or 설정한 건수보다 클때..
          if ( dVol > FCalcVol ) or ( dVol > FJarvisData.LosVol ) then
            bRes2[1] := true;
        end else
          bRes2[1] := true;

        if FJarvisData.UseLossPara then
        begin
          if (( FPara.Side + FOrdDir ) = 0) then
            bRes2[2] := true;
        end else
          bRes2[2] := true;

        if bRes2[0] and bRes2[1] and bRes2[2] then
        begin
          bLiq    := true;
          FLosOtr := true;
          bAll    := true;
          stLog := Format('건수/잔비 para(%d) 변화에 의한 손실 청산(%d %d th) 잔량 %d 건수 ( %.2f -> %.2f,  %.2f -> %.2f , %.2f )', [
          FPara.Side,
          FOrdCnt, FLosCnt, Position.Volume, FCalcCnt, dCnt, FCalcVol, dVol, aQuote.Last ]);
        end;
      end;
    end;
    {
     20190515 주석 위 처리로 대제 ( 건수, 파라 따로 조건 처리 )
    if ( bTerm ) and ( not FLosOtr) and (( FPara.Side + FOrdDir ) = 0) then
    begin
      FCalcCnt  := FSaveCnt + FSaveCnt * (FJarvisData.LosCntRate / 100);
      if ( dCnt > FCalcCnt ) or ( dCnt > FJarvisData.LosCnt ) then
      begin
        bLiq    := true;
        FLosOtr := true;
        bAll    := true;
        stLog := Format('건수비 상승에 의한 손실 청산(%d %d th) 잔량 %d 건수 ( %.2f, %.2f , %.2f )', [
        FOrdCnt, FLosCnt, Position.Volume, FCalcCnt, dCnt, aQuote.Last ]);
      end;
    end;
    }
  end;

  ////////////////////////////////////////////////////////////////////////////////
  ///  청산 실행
  ///  첫번째 청산일때는 ( FOrdCnt = 0 ) 1.a 주문을 이용한다.( 정정을 하란 애기)
  ///  예외는.. 1.c  1.d
  if( stLog <> '') then
    DoLog( Format('liq debug - %s', [stLog]));

  if (bLiq) and ( FLimitOrdCnt >= FOrdCnt ) then
  begin
    DoLog( stLog );
    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog ,  stLog );

    dPrice  := GetOrdPrice( -FOrdDir, aQuote );
    aTarget := GetPaveOrder;
    iQty  := GetOrderQty(Position.Volume);

    if iQty > 0 then
    begin
      DoOrder( iQty, -FOrdDir, dPrice, stDiv );
    end;

    {
    if (FOrdCnt = 1) and ( aTarget <> nil) then
    begin
      DoChangeOrder( aTarget, dPrice, stDiv );
      // 1.c  or 1.d
      if bAll then
      begin
        iQty  := abs(Position.Volume) - aTarget.ActiveQty;
        if iQty > 0 then
        begin
          DoOrder( iQty, -FOrdDir, dPrice, stDiv );
          DoLog('들어가자 마자 전부 청산 ');
        end;
      end;


    end
    else begin
      iTmp  := GetOrderQty(Position.Volume);

      if (( stDiv = Los_Ord ) and ( FLosCnt > 0 )) or bAll then
        iQty := iTmp
      else
        iQty := iTmp div 2;

      if iQty = 0 then
      begin
        bAll := true;
        iQty := iTmp;
      end;

      DoOrder( iQty, -FOrdDir, dPrice, stDiv );
    end;
    }
    if (bAll) {or ( FLosCnt >= 2 )}  then
    begin
      DoCancels( 0 );
      FOrdDir := 0;
    end;

  end;
end;

procedure TJarvis2.DoLiquid;
var
  aQuote : TQuote;
  dPrice : double;
  iSide  : integer;
begin
  if Position = nil then Exit;
  if Position.Volume = 0 then Exit;

  aQuote  := Position.Symbol.Quote as TQuote;
  dPrice  := GetOrdPrice( -FOrdDir, aQuote );

  DoOrder( abs( Position.Volume ), -FOrdDir , dPrice, Los_Ord );
  DoCancels( 0 );
end;

/////////

procedure TJarvis2.calcSaveVol( aQuote : TQuote );
var
  dDiv : double;
begin
  dDiv := abs( aQuote.VolRatio );
  if( dDiv > PRICE_EPSILON )then
    FSaveVol  := Min( FSaveVol, dDiv );
end;

procedure TJarvis2.calcSaveCnt( aQuote : TQuote );
var
  dDiv : double;
begin
  dDiv := FSaveCnt;
  if FOrdDir > 0 then
  begin
    if aQuote.Bids.CntTotal > 0 then
      dDiv := aQuote.Asks.CntTotal /  aQuote.Bids.CntTotal;
  end else
  if FOrdDir < 0 then
  begin
    if aQuote.Asks.CntTotal > 0 then
      dDiv := aQuote.Bids.CntTotal /  aQuote.Asks.CntTotal;
  end;
  FSaveCnt  := Min( FSaveCnt, dDiv );
end;

procedure TJarvis2.CheckLiskAmt( aQuote : TQuote );
var
  dPL: double;
  stLog : string;
begin
  if gEnv.RunMode = rtSimulation then Exit;

  dPL := gEnv.Engine.TradeCore.Positions.GetPL( Account ) / 10000;

  if dPL < 0 then begin
    if -FJarvisData.LiskAmt > dPL then
    begin
      Stop;
      FLossCut := true;
      stLog := Format('손익 한도초과로 (%.0f) ',  [ dPL * 10]);
      DoLog( stLog );
      if Assigned( FOnJarvisEvent ) then
        FOnJarvisEvent( Self, jetLog ,  stLog );
    end;
  end else
  begin
    if dPL > 0 then
      if (JarvisData.PlusAmt < dPL) and ( JarvisData.PlusAmt > 1 ) then
      begin
        Stop;
        FLossCut := true;
        stLog := Format('손익 이익초과로 (%.0f) ',  [ dPL * 10]);
        DoLog( stLog );
        if Assigned( FOnJarvisEvent ) then
          FOnJarvisEvent( Self, jetLog ,  stLog );
      end;
  end;
end;

procedure TJarvis2.TestLiqFill( aQuote : TQuote; iSide :Integer );
var
  iOrdQty, iOrdQty2 , iTmp : Integer;
  dFillPrice , dPrice : double;
  stLog : string;
begin
  if FJarvisData.PrfPoint2 > 0 then
  begin
    dFillPrice:= aQuote.Last;
    iOrdQty  := FJarvisData.OrdQty div 2;
    iOrdQty2 := (FJarvisData.OrdQty - iOrdQty) div 2;
    if iOrdQty2 > 0 then
    begin
      iTmp    := Round( (FJarvisData.PrfPoint + FJarvisData.PrfPoint2) / aQuote.Symbol.Spec.TickSize );
      dPrice  := TicksFromPrice( aQuote.Symbol, dFillPrice, iTmp * iSide );

      //DoOrder( iOrdQty , -aOrder.Side ,  dPrice, Pav_Ord );
      stLog := Format(' 체결%s  --> 2.th %s 청산주문 %.2f 에 %d 계약 깔기', [
          aQuote.Symbol.PriceToStr( dFillPrice ),
          SidetoStr( -iSide),   dPrice,  iOrdQty2 ]);
      DoLog( stLog );
      if Assigned( FOnJarvisEvent ) then
        FOnJarvisEvent( Self, jetLog , stLog );
    end;
  end;
end;

procedure TJarvis2.DoTest( idx : integer );
begin
  if ( not run ) or ( Symbol = nil ) then Exit;
  case idx of
    1 : CheckEntryCondition( Symbol.Quote as TQuote  );
    2 : TestLiqFill( Symbol.Quote as TQuote, 1  ) ;
    3 : TestLiqFill( Symbol.Quote as TQuote, -1  ) ;
    4 : UpdateQuote( Symbol.Quote as TQuote, true  ) ;
  end;

end;

{ TJarvis2s }

constructor TJarvis2s.Create;
begin
  inherited create( TJarvis2 );
end;

destructor TJarvis2s.Destroy;
begin

  inherited;
end;

function TJarvis2s.Find(aObj : TObject): TJarvis2;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[i] = aObj then
    begin
      Result := Items[i] as TJarvis2 ;
      break;
    end;
end;

function TJarvis2s.GetJarvis(i: integer): TJarvis2;
begin
  if (i<0) or (i>=Count) then
    Result := nil
  else
    Result := Items[i] as TJarvis2;
end;


function TJarvis2s.New(stCode: string): TJarvis2;
begin
  Result := Add as TJarvis2;
//  Result.InvestCode := stCode;
end;

end.
