unit CleBHultAxis;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,

  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFrontOrder,

  UObjectBase, UPaveConfig, UPriceItem,  CleQuoteTimers,

  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleCircularQueue,

  GleTypes, GleConsts, CleStrategyStore;

type

  TClearOrder = class(TCollectionItem)
  public
    Price : double;
    OrgPrice : double;
    OrgIndex : integer;
    Side : integer;
    Qty : integer;
  end;

  TBHultPrice = class(TCollectionItem)
  public
    PriceItem : TPriceItem2;
    SendOrder : boolean;
    ClearOrder : boolean;
    Index : integer;
    ClearOrders : TCollection;
    constructor Create(aCol : TCollection ); override;
    destructor Destroy; override;
  end;


  TBHultPrices = class(TCollection)
  private
    FBaseIndex : integer;
    FCurrentIndex : integer;
    FMaxIndex : integer;
    FNewIndex : integer;
    FClearIndex : integer;
    FSide : integer;
    FClearing : boolean;
    FSuccess : boolean;
    function GetPriceItem(i: integer): TBHultPrice;
  public
    Constructor Create ;
    Destructor  Destroy; override;
    procedure ReSet(iStart, iEnd : integer);
    procedure SetIndex(iBase, iCurrent, iSide : integer; bSend : boolean);
    procedure SetCurrentIndex( dPrice : double );
    function New( aPrice : TPriceItem2) : TBHultPrice;


    function GetBasePrice : TBHultPrice;
    function GetCurrentPrice : TBHultPrice;
    function GetMaxPrice : TBHultPrice;
    function GetNextPrice : TBHultPrice;
    function GetClearPrice : TBHultPrice;

    property BHultPrice[ i : integer] : TBHultPrice read GetPriceItem;
    property BaseIndex : integer read FBaseIndex write FBaseIndex;
    property CurrentIndex : integer read FCurrentIndex write FCurrentIndex;
    property MaxIndex : integer read FMaxIndex;
    property NewIndex : integer read FNewIndex write FNewIndex;
    property ClearIndex : integer read FClearIndex write FClearIndex;
    property Side : integer read FSide write FSide;
    property Clearing : boolean read FClearing write FClearing;
    property Success : boolean read FSuccess write FSuccess;


  end;

  TBHultAxis = class(TStrategyBase)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FBHultData: TBHultData;
    FPriceSet: TPriceSet;
    FReady : boolean;
    FLossCut : boolean;
    FLcTimer : TQuoteTimer;
    FOnPositionEvent: TObjectNotifyEvent;
    FRemSide, FRemNet, FRemQty : integer;
    FRetryCnt : integer;
    FLossCutCnt : integer;
    FTermCnt : integer;
    FHLTSignal : boolean;

    FMinPL, FMaxPL : double;
    FMinTime, FMaxTime : TDateTime;
    FBHultPrices : TBHultPrices;
    FStartIndex : integer;
    FBidOrders : TList;
    FAskOrders : TList;
    FLost : integer;
    FWin : integer;
    FRemainLost : integer;
    FSuccess : boolean;
    FScreenNumber : integer;
    FRun : boolean;
    FHultPosition : TPosition;
    procedure OnLcTimer( Sender : TObject );
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    function DoOrder( aBHult : TBHultPrice; iQty, iSide : integer;
      bHit  : boolean = false; bClear : boolean = false) : TOrder; overload;

    procedure Reset;
    procedure MakePriceItem;
    procedure DoInit(aQuote : TQuote);
    function IsRun : boolean;
    procedure UpdateQuote(aQuote: TQuote);

    procedure MakeClearOrder(aBHult : TBHultPrice; iSide : integer);
    procedure InitClearOrder(aBHult : TBHultPrice; iSide : integer);

    procedure DoBanQuote(aQuote : TQuote);
    procedure DoFill(aOrder : TOrder);

    procedure CheckActiveOrder(aOrder : TOrder; EventID: TDistributorID);
    procedure CancelLossCut(aOrder : TOrder);
    procedure ClearOrder;

    procedure DoLog;
    function BHULTLossCut( iSide: integer): integer;
  public

    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol); 
    function Start : boolean;
    Procedure Stop;

    property BHultData: TBHultData read FBHultData write FBHultData;
    property BHultPrices : TBHultPrices read FBHultPrices;
    property LossCutCnt : integer read FLossCutCnt write FLossCutCnt;
    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property Lost : integer read FLost;
    property Win : integer read FWin;
    property RemainLost : integer read FRemainLost;
    property HultPosition : TPosition read FHultPosition;
  end;
implementation

uses
  GAppEnv, GleLib;

{ TBHultAxis }

procedure TBHultAxis.CancelLossCut(aOrder : TOrder);
var
  iSide, iQty : integer;
  aItem : TBHultPrice;
begin
  {
  aItem := FBHultPrices.GetBasePrice;

  if (aItem <> nil) and (aOrder.ClearOrder) then
  begin

    if (aOrder.Side < 0) and (FAskOrders.Count = 0) then
    begin
      iSide := -1;
      iQty := abs(Position.Volume[ptLong]);
      DoOrder(aItem, iQty, iSide, true, true );
      inc(FLossCutCnt);
    end else if (aOrder.Side > 0) and (FBidOrders.Count = 0) then
    begin
      iSide := 1;
      iQty := abs(Position.Volume[ptShort]);
      DoOrder(aItem, iQty, iSide, true, true );
      inc(FLossCutCnt);
    end;
  end;  }
end;

procedure TBHultAxis.CheckActiveOrder(aOrder: TOrder; EventID: TDistributorID);
var
  iIndex : integer;
  stLog : string;
begin
 { if (EventID = ORDER_ACCEPTED) then
  begin
    if (aOrder.OrderType = otNormal) and (aOrder.ClearOrder) and (aOrder.State = osActive) and ( aOrder.ActiveQty > 0 ) then
    begin
      if aOrder.Side > 0  then
        FBidOrders.Add(aOrder)
      else
        FAskOrders.Add(aOrder);
      stLog := Format('ActiveOrder A:%d B:%d, %d, %.1f, %d, %d', [FAskOrders.Count, FBidOrders.Count, aOrder.OrderNo, aOrder.Price, aOrder.Side, aOrder.ActiveQty]);
      gEnv.EnvLog(WIN_BHULT, stLog);
    end;
  end;
  iIndex := 0;
  while iIndex <= FBidOrders.Count -1 do
  begin
    aOrder := FBidOrders.Items[iIndex];
    if (aOrder.State <> osActive) then
      FBidOrders.Delete(iIndex)
    else
      inc(iIndex);
  end;


  iIndex := 0;
  while iIndex <= FAskOrders.Count -1 do
  begin
    aOrder := FAskOrders.Items[iIndex];
    if (aOrder.State <> osActive) then
      FAskOrders.Delete(iIndex)
    else
      inc(iIndex);
  end;  }
end;

procedure TBHultAxis.ClearOrder;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  dPrice : double;
  stLog   : string;
  iLiqQty : integer;
  iSide : integer;
begin

  if Position = nil then exit;

  {if Position.Volume = 0 then exit;

  if Position.Volume > 0 then
    iSide := -1
  else
    iSide := 1;

  if iLiqQty > 0 then
  begin

    if iSide = 1 then
      dPrice := Symbol.LimitHigh
    else
      dPrice := Symbol.LimitLow;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                  gEnv.ConConfig.UserID, Account, Symbol,
                  iLiqQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.ClearOrder := true;
      if Symbol.Spec.Exchange = SANG_EX then
        aOrder.OffsetFlag := cofCloseToday
      else
        aOrder.OffsetFlag := cofClose;
      aOrder.OrderSpecies := opBHult;



      gEnv.Engine.TradeBroker.Send(aTicket);
      stLog := Format( 'Clear Order : %s, %s, %s, %d',
        [
          Symbol.Code,
          ifThenStr( iSide > 0 , 'L', 'S'),
          Symbol.PriceToStr( dPrice ),
          iLiqQty
        ]
        );

      gEnv.EnvLog(WIN_BHULT , stLog);
    end;
  end;     }
end;

constructor TBHultAxis.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stBHult);

  FScreenNumber := Number;

  FPriceSet := TPriceSet.Create;

  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 1000;
  FLcTimer.OnTimer := OnLcTimer;


  FBHultPrices := TBHultPrices.Create;
  FBidOrders := TList.Create;
  FAskOrders := TList.Create;
  Reset;
end;

destructor TBHultAxis.Destroy;
begin
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);
  FPriceSet.Free;
  FBHultPrices.Free;
  FBidOrders.Free;
  FAskOrders.Free;
  inherited;
end;



procedure TBHultAxis.DoBanQuote(aQuote: TQuote);
var
  aItem, aBase, aCur, aNew, aClear  : TBHultPrice;
  iSide : integer;
  stLog : string;
begin
  ///////////////////////잔고 없을때////////////////////////////
  aBase := FBHultPrices.GetBasePrice;
  if aBase = nil then exit;
  if Position.Volume = 0 then
  begin
    aItem := FBHultPrices.BHultPrice[FBHultPrices.BaseIndex + 1];
    if aItem <> nil then
    begin
      if (aQuote.Asks[0].Price + PRICE_EPSILON >= aItem.PriceItem.Price) and (not aItem.SendOrder) then
      begin
        stLog := Format('DoBanQuote 매수 B:%.1f C:%.1f, (%.1f)%.1f(%.1f) ', [aBase.PriceItem.Price, aItem.PriceItem.Price,
                    aQuote.Asks[0].Price,aQuote.Last ,aQuote.Bids[0].Price]);
            gEnv.EnvLog(WIN_BHULT, stLog);
        DoOrder(aItem, FBHultData.OrdQty, 1, true );
        FStartIndex := FBHultPrices.BaseIndex;
      end;
    end;

    aItem := FBHultPrices.BHultPrice[FBHultPrices.BaseIndex - 1];
    if aItem <> nil then
    begin
      if (aQuote.Bids[0].Price <= aItem.PriceItem.Price + PRICE_EPSILON) and (not aItem.SendOrder) then
      begin
        stLog := Format('DoBanQuote 매도 B:%.1f C:%.1f, (%.1f)%.1f(%.1f) ', [aBase.PriceItem.Price, aItem.PriceItem.Price,
                     aQuote.Asks[0].Price,aQuote.Last ,aQuote.Bids[0].Price]);
            gEnv.EnvLog(WIN_BHULT, stLog);
        DoOrder(aItem, FBHultData.OrdQty, -1, true );
        FStartIndex := FBHultPrices.BaseIndex;
      end;
    end;
  end;


  ///////////////////////매수잔고 있을때////////////////////////////
  if Position.Volume > 0 then
  begin
    FBHultPrices.SetCurrentIndex(aQuote.Asks[0].Price);

    aNew := FBHultPrices.BHultPrice[FBHultPrices.NewIndex];

    if aNew <> nil then
    begin
      if (aNew.PriceItem.Price <= aQuote.Asks[0].Price + PRICE_EPSILON) and (not aNew.SendOrder) then
      begin
        stLog := Format('DoBanQuote 신규매수 N(%.1f) <= A(%.1f), Last = %.1f', [aNew.PriceItem.Price, aQuote.Asks[0].Price, aQuote.Last]);
        gEnv.EnvLog(WIN_BHULT, stLog);
        DoOrder(aNew, FBHultData.OrdQty, 1, true );
      end;
    end;

    aClear := FBHultPrices.BHultPrice[FBHultPrices.ClearIndex];
    if aClear <> nil then
    begin
      if (aClear.PriceItem.Price + PRICE_EPSILON >= aQuote.Bids[0].Price) and (aClear.ClearOrders.Count > 0) then
      begin
        stLog := Format('DoBanQuote 청산매도 C(%.1f) >= B(%.1f), Last = %.1f', [aClear.PriceItem.Price, aQuote.Bids[0].Price, aQuote.Last ]);
        gEnv.EnvLog(WIN_BHULT, stLog);

        DoOrder(aClear, FBHultData.OrdQty, -1, true, true );
      end;
    end;
  end;

   ///////////////////////매도잔고 있을때////////////////////////////
  if Position.Volume < 0 then
  begin
    FBHultPrices.SetCurrentIndex(aQuote.Bids[0].Price);

    aNew := FBHultPrices.BHultPrice[FBHultPrices.NewIndex];

    if aNew <> nil then
    begin
      if (aNew.PriceItem.Price + PRICE_EPSILON >= aQuote.Bids[0].Price) and (not aNew.SendOrder) then
      begin
        stLog := Format('DoBanQuote 신규매도 N(%.1f) >= B(%.1f), Last = %.1f', [aNew.PriceItem.Price, aQuote.Bids[0].Price, aQuote.Last]);
        gEnv.EnvLog(WIN_BHULT, stLog);
        DoOrder(aNew, FBHultData.OrdQty, -1, true );
      end;
    end;

    aClear := FBHultPrices.BHultPrice[FBHultPrices.ClearIndex];
    if aClear <> nil then
    begin
      if (aClear.PriceItem.Price <= aQuote.Asks[0].Price + PRICE_EPSILON) and (aClear.ClearOrders.Count > 0) then
      begin
        stLog := Format('DoBanQuote 청산매수 C(%.1f) <= A(%.1f), Last = %.1f', [aClear.PriceItem.Price, aQuote.Asks[0].Price, aQuote.Last]);
        gEnv.EnvLog(WIN_BHULT, stLog);
        DoOrder(aClear, FBHultData.OrdQty, 1, true, true );
      end;
    end;
  end;
end;

procedure TBHultAxis.DoFill(aOrder: TOrder);
var
  stLog : string;
  aBHult : TBHultPrice;
  aQuote : TQuote;
  aFill : TFill;
  iOrdQty : integer;
begin

  if Position  = nil then exit;

  if FBHultData.UseMaxPos then
  begin
    if Position.Volume = 0 then exit;

    {  승패
    if (Position.Volume[ptLong] >= FBHultData.MaxPos + FLost) or (Position.Volume[ptShort] >= FBHultData.MaxPos + FLost) then
    begin
       if not FSuccess then
         FRemainLost := FLost + FBHultData.LostCnt;
       FSuccess := true;

    end;

    if (FRemainLost = FLost) and (FSuccess) then
    begin
      if Position.Side > 0 then
      begin
        FRemNet := Position.Side;
        FRemSide := 1;
      end else
      begin
        FRemNet := abs(Position.Side);
        FRemSide := -1;
      end;
      FLossCut := true;
      Stop;
      stLog := Format('MaxPos 오버 Bid = %d, Ask = %d, %d', [Position.Volume[ptLong], Position.Volume[ptShort], FBHultData.MaxPos ]);
      gEnv.EnvLog(WIN_BHULT, stLog);
      exit;
    end;

    }
     {
    //연승..이면서 손익, +일때 스탑
    if (FWin - 1 = FBHultData.MaxPos) and (Position.EntryPLSum - Position.GetFee > 5000)  then
    begin
      if Position.Side > 0 then
      begin
        FRemNet := Position.Side;
        FRemSide := 1;
      end else
      begin
        FRemNet := abs(Position.Side);
        FRemSide := -1;
      end;
      FLossCut := true;
      Stop;
      stLog := Format('MaxPos 연승 Bid = %d, Ask = %d, %d, %d', [Position.Volume[ptLong], Position.Volume[ptShort], FBHultData.MaxPos, FWin ]);
      gEnv.EnvLog(WIN_BHULT, stLog);
      exit;
    end;   }
  end;
end;

procedure TBHultAxis.DoInit(aQuote: TQuote);
var
  i, iIndex, idx: integer;
  aPrice, aBase : TPriceItem2;
  aBHult : TBHultPrice;
  stTime, stLog : string;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;

  if aQuote.FTicks.Count <= 0  then exit;

  if Frac(FBHultData.StartTime) > Frac(GetQuoteTime) then exit;

  if FHultPosition = nil then
    FHultPosition := gEnv.Engine.TradeCore.Positions.Find( FBHultData.HultAccount, FSymbol);

  if FHultPosition = nil then exit;
  


  //HLT 신호 잡아서 가자...............
  if aQuote.AddTerm then
  begin
    inc(FTermCnt);
    if FTermCnt = FBHultData.Term then
    begin
      stTime := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime);
      stLog := Format('DoInit %s', [stTime]);
      gEnv.EnvLog(WIN_BHULT, stLog);
      FTermCnt := 0;
      // 조건 맞으면..... FHLTSignal true


      if aQuote.Symbol.DayOpen < aQuote.Symbol.Last then
      begin
        if aQuote.Symbol.DayOpen + FBHultData.Band <= aQuote.Symbol.Last then
        begin
          FHLTSignal := true;
          stLog := Format('DoInit O + B = %.1f <= %.1f', [aQuote.Symbol.DayOpen + FBHultData.Band, aQuote.Symbol.Last]);
          gEnv.EnvLog(WIN_BHULT, stLog);
        end else
          FHLTSignal := false;
      end else
      begin
        if aQuote.Symbol.DayOpen - FBHultData.Band >= aQuote.Symbol.Last then
        begin
          FHLTSignal := true;
          stLog := Format('DoInit O - B = %.1f >= %.1f', [aQuote.Symbol.DayOpen - FBHultData.Band, aQuote.Symbol.Last]);
          gEnv.EnvLog(WIN_BHULT, stLog);
        end else
          FHLTSignal := false;
      end;
    end;
  end;
  if not FHLTSignal then exit;
  //////////////////////////////////////


  //HLT신호로만 주문...
  {    // 금액까지 체크
  if FHultPosition.LastPL - FHultPosition.GetFee > FBHultData.HultPL * -10000  then
  begin
    //stLog := Format('DoInit %.0f > %0.f', [FHultPosition.LastPL - FHultPosition.GetFee, FBHultData.HultPL * -10000]);
    //gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end else
  begin
    stLog := Format('DoInit Start %.0f <= %0.f', [FHultPosition.LastPL - FHultPosition.GetFee, FBHultData.HultPL * -10000]);
    gEnv.EnvLog(WIN_BHULT, stLog);

    //주문발주....

    FReady := true;
  end;
         }


  idx := FPriceSet.GetIndex(aQuote.Last);
  aBase := FPriceSet.PriceItem[idx];

  if aBase <> nil then
  begin
    iIndex := aBase.Index;
    for i := aBase.Index to FPriceSet.Count - 1 do
    begin
      aPrice := FPriceSet.PriceItem[i];
      if iIndex = i then
      begin
        aPrice.BHult := true;
        iIndex := iIndex + FBHultData.OrdGap;
      end else
        aPrice.BHult := false;
    end;

    iIndex := aBase.Index;
    for i := aBase.Index downto 0 do
    begin
      aPrice := FPriceSet.PriceItem[i];
      if iIndex = i then
      begin
        aPrice.BHult := true;
        iIndex := iIndex - FBHultData.OrdGap;
      end else
        aPrice.BHult := false;
    end;

    for i := 0 to FPriceSet.Count - 1 do
    begin
      aPrice := FPriceSet.PriceItem[i];
      if aPrice.BHult then
        aBHult := FBHultPrices.New(aPrice);

      if aBase = aPrice then
      begin
        FBHultPrices.FBaseIndex := FBHultPrices.Count - 1;
        FBHultPrices.FCurrentIndex := FBHultPrices.Count - 1;
        FBHultPrices.FMaxIndex := FBHultPrices.Count - 1;
        aBHult.SendOrder := true;
      end;
    end;
    FReady := true;
    gEnv.EnvLog(WIN_BHULT, Format('DoInit BasePrice = %.1f, base index = %d',[aBase.Price, FBHultPrices.FBaseIndex]));
  end else
  begin
    gEnv.EnvLog(WIN_BHULT, 'BasePrice 설정실패');
    stop;
    ShowMessage('BasePrice 설정실패');
  end;
end;



procedure TBHultAxis.DoLog;
var
  stLog, stFile : string;
begin
  //날짜, Gap, 순손익, 최대손익, 최대손실, 최대잔고
  {
  stLog := Format('%s, %d, %.0f, %s, %.0f, %s, %.0f, %d, %d, %d',
                  [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap,
                    Position.EntryPLSum - Position.GetFee, FormatDateTime('hh:mm:ss', FMaxTime),  FMaxPL,
                    FormatDateTime('hh:mm:ss', FMinTime), FMinPL, Position.MaxPos, FLost, FRemainLost]);
   }
//날짜, Gap, 순손익, 최대손익, 최대손실, 최대잔고

  if Position = nil then
  begin
    stLog := Format('%s, %d, 0, 0, 0, 0',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap] );
  end else
  begin
    stLog := Format('%s, %d, %.0f, %.0f, %.0f, %d',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap,
                      (Position.LastPL - Position.GetFee)/1000, FMaxPL/1000, FMinPL/1000, Position.MaxPos] );
  end;
  stFile := Format('BanHultLoss_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_BHULT, stLog, true, stFile);
end;

function TBHultAxis.DoOrder(aBHult : TBHultPrice; iQty, iSide: integer; bHit,
  bClear: boolean): TOrder;
var
  aTicket : TOrderTicket;
  aPrice : TPriceItem2;
  dPrice : double;
  aQuote : TQuote;
  idx : integer;

  iMax, i : integer;
  iCnt : integer;
  aOrder : TOrder;
  tgType : TPositionType;
begin
  Result := nil;
  idx := aBHult.PriceItem.Index;
  aPrice := FPriceSet.PriceItem[ idx ];
  if (aPrice = nil) or ( iQty <= 0) then  Exit;

  if bHit then
  begin
    aQuote  := FSymbol.Quote as TQuote;
    if iSide > 0 then
      dPrice  := TicksFromPrice( FSymbol, aQuote.Asks[0].Price, 10 )
    else
      dPrice  := TicksFromPrice( FSymbol, aQuote.Bids[0].Price, -10 );
  end
  else dPrice := aPrice.Price;

  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  Result := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, FSymbol,
    iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if Result <> nil then
  begin
    Result.OrderSpecies := opBhult;
    aPrice.AddOrder( Result );
    Result.PriceIdx := aPrice.Index;
    gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.EnvLog(WIN_BHULT, Format('주문 : %s', [ Result.Represent2 ]) ) ;
    if not bClear then
    begin
      FBHultPrices.SetIndex(FBHultPrices.BaseIndex, aBHult.Index, iSide, true);
      MakeClearOrder(aBHult, iSide);
    end else if bHit and bClear then
      InitClearOrder(aBHult, iSide);

    Result.PriceIdx := idx;
  end;
end;

function TBHultAxis.BHULTLossCut(iSide: integer): integer;
var
  stLog : string;
  aTicket : TOrderTicket;
  aOrder : TOrder;
  aPrice : TPriceItem2;
  dPrice : double;
  iQty : integer;
begin
  Result := 0;
  if Position = nil then exit;

  if Position.Volume <> 0 then
  begin
    //손절.... 해주자
    if Position.Volume > 0 then
    begin
      iSide := -1;
      dPrice := TicksFromPrice( FSymbol, FSymbol.Last, 10 * iSide );
    end else
    begin
      iSide := 1;
      dPrice := TicksFromPrice( FSymbol, FSymbol.Last, 10 * iSide );
    end;

    iQty := abs(Position.Volume);
    aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, FSymbol,
    iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := opBHult;
      gEnv.Engine.TradeBroker.Send(aTicket);

      stLog := Format('Ban_Hult정리 %s',[aOrder.Represent2]);
      gEnv.EnvLog(WIN_BHULT, stLog);
    end;
  end;
  Result := 0;
end;

procedure TBHultAxis.init(aAcnt: TAccount; aSymbol: TSymbol);
begin
  inherited;
  FSymbol := aSymbol;
  FAccount := aAcnt;
  Account := aAcnt;
  MakePriceItem;
  Reset;
end;

procedure TBHultAxis.InitClearOrder(aBHult: TBHultPrice; iSide : integer);
var
  aPrice : TBHultPrice;
  aClear : TClearOrder;
  stLog : string;
begin
  if aBHult.ClearOrders.Count <= 0 then exit;           //청산주문없애고... 해당원주문 SendOrder false로
  aClear := aBHult.ClearOrders.Items[0] as TClearOrder;
  aBHult.ClearOrders.Clear;

  inc(FLost);
  FWin := 0;

  if iSide > 0 then   //청산 매수
  begin
    FBHultPrices.NewIndex := aBHult.Index - 1;
    FBHultPrices.ClearIndex := aBHult.Index + 1;
  end else
  begin
    FBHultPrices.NewIndex := aBHult.Index + 1;
    FBHultPrices.ClearIndex := aBHult.Index - 1;
  end;

  aPrice := FBHultPrices.BHultPrice[aClear.OrgIndex];
  if aPrice <> nil then
  begin
    aPrice.SendOrder := false;
  end else
  begin
    stLog := Format('청산주문 InitClearOrder SendOrder 이상 Side = %d, New = %d, C = %d, Clear = %d'
              ,[iSide, FBHultPrices.NewIndex, aBHult.Index, FBHultPrices.ClearIndex ]);
    gEnv.EnvLog(WIN_BHULT, stLog);
  end;


  stLog := Format('청산주문 InitClearOrder Side = %d, New = %d, C = %d, Clear = %d'
              ,[iSide, FBHultPrices.NewIndex, aBHult.Index, FBHultPrices.ClearIndex ]);
  gEnv.EnvLog(WIN_BHULT, stLog);
end;

function TBHultAxis.IsRun: boolean;
begin
  if ( not FRun ) or ( FSymbol = nil ) or ( Account = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TBHultAxis.MakeClearOrder(aBHult: TBHultPrice; iSide : integer);
var
  aPrice : TBHultPrice;
  aClear : TClearOrder;
  stLog : string;
begin
  aBHult.SendOrder := true;

  inc(FWin);
  aPrice := nil;
  if iSide > 0 then   //신규 매수
  begin
    FBHultPrices.NewIndex := aBHult.Index + 1;
    FBHultPrices.ClearIndex := aBHult.Index - 1;
    aPrice := FBHultPrices.BHultPrice[FBHultPrices.ClearIndex];
  end else
  begin
    FBHultPrices.NewIndex := aBHult.Index - 1;
    FBHultPrices.ClearIndex := aBHult.Index + 1;
    aPrice := FBHultPrices.BHultPrice[FBHultPrices.ClearIndex];
  end;

  if aPrice <> nil then
  begin
    aClear := aPrice.ClearOrders.Add as TClearOrder;
    aClear.OrgPrice := aBHult.PriceItem.Price;
    aClear.OrgIndex := aBHult.Index;
    aClear.Side := iSide;
  end else
  begin
    stLog := Format('MakeClearOrder 청산주문 이상,  Side = %d, New = %d, C = %d, Clear = %d'
              ,[iSide, FBHultPrices.NewIndex, aBHult.Index, FBHultPrices.ClearIndex ]);
    gEnv.EnvLog(WIN_BHULT, stLog);
  end;
  stLog := Format('신규주문 MakeClearOrder Side = %d, New = %d, C = %d, Clear = %d'
              ,[iSide, FBHultPrices.NewIndex, aBHult.Index, FBHultPrices.ClearIndex ]);
  gEnv.EnvLog(WIN_BHULT, stLog);
end;

procedure TBHultAxis.MakePriceItem;
var
  dPrice : double;
  i : integer;
begin
  FPriceSet.Clear;
  FPriceSet.Symbol  := FSymbol;

  dPrice := FSymbol.LimitLow;
  i := 0;

  while True do
  begin
      // add a step
    with FPriceSet.New( i ) do
    begin
      Price := dPrice;
      PriceDesc := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
    end;
    dPrice := TicksFromPrice(FSymbol, dPrice, 1);
    inc(i);
    if dPrice > FSymbol.LimitHigh + PRICE_EPSILON then Break;
  end;

end;

procedure TBHultAxis.OnLcTimer(Sender: TObject);
begin
           {
  if Position.Side = 0 then begin
    if Position <> nil then
    begin
      if (Position.Volume[ptLong] > 0) or (Position.Volume[ptShort] > 0 ) then
        gEnv.ShowMsg( WIN_ERR, '청산 수량이 남았음' );
    end;
    FLcTimer.Enabled := false;
    FLossCut := false;
    gEnv.EnvLog(WIN_HULT, Format( 'LcTimer Stop :%d, %d -> %d (%d|%d)',
        [ FRemSide, FRemNet, FRemQty,  Position.Volume[ptLong],Position.Volume[ptShort]  ] ) );
    Exit;
  end;
           }  {
  inc(FReTryCnt);
  FRemQty := FRemQty + BHULTLossCut( FRemSide );
  gEnv.EnvLog(WIN_HULT, Format( 'LcTimer Time :%d, %d -> %d',
        [ FRemSide, FRemNet, FRemQty ] ) );

  if FReTryCnt >= RETRY_CNT then
  begin
    FLcTimer.Enabled := false;
    FLossCut := false;
    gEnv.EnvLog(WIN_HULT, Format( 'LcTimer Stop RetryCnt :%d, %d -> %d (%d|%d), %d',
        [ FRemSide, FRemNet, FRemQty,  Position.Volume[ptLong],Position.Volume[ptShort], FRetryCnt  ] ) );
  end;   }
end;

procedure TBHultAxis.QuoteProc(aQuote: TQuote; iDataID: integer);
begin
  if iDataID = 300 then
  begin
    DoLog;
    exit;
  end;

  if not IsRun then Exit;
  if ( FSymbol <> aQuote.Symbol ) then Exit;

  if not FReady then
    DoInit( aQuote )
  else
    UpdateQuote( aQuote );

end;

procedure TBHultAxis.Reset;
begin
  FRun := false;
  FReady  := false;
  FLossCut:= false;

  FPriceSet.ReSet;

  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FRetryCnt := 0;
  FBHultPrices.Clear;
  FBHultPrices.Clearing := false;
  FBHultPrices.Success := false;
  FBHultPrices.Side := 0;

  FBHultPrices.NewIndex := -1;
  FBHultPrices.ClearIndex := -1;

  FBidOrders.Clear;
  FAskOrders.Clear;
  FLossCutCnt := 0;
  FLost := 0;
  FWin := 0;
  FRemainLost := 0;
  FSuccess := false;
  FTermCnt := 0;
  FHLTSignal := false;
  FHultPosition := nil;
end;

function TBHultAxis.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;

  FRun := true;
  AddPosition(FSymbol);
  gEnv.EnvLog(WIN_BHULT, Format('BHult Start %s, %d', [FSymbol.Code, FBHultData.OrdGap]) );
end;

procedure TBHultAxis.Stop;
begin
  FRun := false;
  gEnv.EnvLog(WIN_BHULT, Format('BHult Stop %s, %d', [FSymbol.Code, FBHultData.OrdGap]) );
  // 손절 넣자....
  BHULTLossCut(1);
end;


procedure TBHultAxis.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
begin
  if not IsRun then Exit;
  if aOrder.OrderSpecies <> opBHult then exit;
  if iID in [ORDER_FILLED] then
    DoFill( aOrder );
end;

procedure TBHultAxis.UpdateQuote(aQuote: TQuote);
var
  stTime, stTime1 : string;
  stLog : string;
  dOTE : array[0..1] of double;
  dPL : double;
begin

  if Position <> nil then
  begin
    FMinPL := Min( FMinPL, (Position.LastPL - Position.GetFee) );
    FMaxPL := Max( FMaxPL, (Position.LastPL - Position.GetFee) );
  end;

  if not IsRun then Exit;
  stTime := FormatDateTime('hh:mm:ss.zzz', FBHultData.LiquidTime);
  stTime1 := FormatDateTime('hh:mm:ss.zzz', GetQuoteTime);
  if (FBHultData.UseAutoLiquid) and (Frac(FBHultData.LiquidTime) <= Frac(GetQuoteTime)) then
  begin
    Stop;
    stLog := Format('청산시간 %s <= %s', [stTime, stTime1]);
    gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end;


  if (FBHultData.UseAllcnlNStop) and ((Position.LastPL - Position.GetFee) <= FBHultData.RiskAmt * -10000) then
  begin
    Stop;
    stLog := Format('일일한도 오버 %.0f', [Position.LastPL - Position.GetFee]);
    gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end;

  if (FBHultData.UseAllcnlNStop) and (Position.LastPL - Position.GetFee >= FBHultData.ProfitAmt * 10000) then
  begin
    Stop;
    stLog := Format('일일이익 청산 %.0f', [Position.LastPL - Position.GetFee]);
    gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end;

  //DoBanQuote(aQuote);

end;

{ TBHultPrices }

constructor TBHultPrices.Create;
begin
  inherited Create( TBHultPrice );

  FBaseIndex := 0;
  FCurrentIndex := 0;
  FMaxIndex := 0;
  FSide := 0;
  FClearing := false;
  FSuccess := false;
end;

destructor TBHultPrices.Destroy;
begin

  inherited;
end;

procedure TBHultPrices.SetCurrentIndex( dPrice : double );
var
  aItem, aNext : TBHultPrice;
  i: Integer;
  stLog : string;
begin
  if FSide > 0 then
  begin
    aItem := BHultPrice[FCurrentIndex];
    if aItem = nil then exit;
    if aItem.PriceItem.Price <= dPrice then
    begin
      for i := FCurrentIndex to count - 1 do
      begin
        aItem := BHultPrice[i];
        aNext := BHultPrice[i + 1];

        if (aItem = nil) or (aNext = nil) then exit;

        if (aItem.PriceItem.Price <= dPrice) and ( aNext.PriceItem.Price > dPrice) then
        begin
          FCurrentIndex := i;
          break;
        end;
      end;
    end else
    begin
      for i := FCurrentIndex downto FBaseIndex do
      begin
        aItem := BHultPrice[i];
        aNext := BHultPrice[i - 1];

        if (aItem = nil) or (aNext = nil) then exit;
        if (aItem.PriceItem.Price >= dPrice) and ( aNext.PriceItem.Price < dPrice)  then
        begin
          FCurrentIndex := i;
          break;
        end;
      end;
    end;
  end else if FSide < 0 then
  begin
    aItem := BHultPrice[FCurrentIndex];

    if aItem = nil then exit;
    if aItem.PriceItem.Price >= dPrice then
    begin
      for i := FCurrentIndex downto 0 do
      begin
        aItem := BHultPrice[i];
        aNext := BHultPrice[i - 1];
        if (aItem = nil) or (aNext = nil) then exit;
        if (aItem.PriceItem.Price >= dPrice) and ( aNext.PriceItem.Price < dPrice)  then
        begin
          FCurrentIndex := i;
          break;
        end;
      end;
    end else
    begin
      for i := FCurrentIndex to FBaseIndex do
      begin
        aItem := BHultPrice[i];
        aNext := BHultPrice[i + 1];
        if (aItem = nil) or (aNext = nil) then exit;
        if (aItem.PriceItem.Price <= dPrice) and ( aNext.PriceItem.Price > dPrice)  then
        begin
          FCurrentIndex := i;
          break;
        end;
      end;
    end;
  end;
end;

function TBHultPrices.GetBasePrice: TBHultPrice;
begin
  Result := BHultPrice[FBaseIndex];
end;

function TBHultPrices.GetClearPrice: TBHultPrice;
begin
  Result := BHultPrice[FClearIndex];
end;

function TBHultPrices.GetCurrentPrice: TBHultPrice;
begin
  Result := BHultPrice[FCurrentIndex];
end;

function TBHultPrices.GetMaxPrice: TBHultPrice;
begin
  Result := BHultPrice[FMaxIndex];
end;

function TBHultPrices.GetNextPrice: TBHultPrice;
begin
  Result := BHultPrice[FNewIndex];
end;

function TBHultPrices.GetPriceItem(i: integer): TBHultPrice;
begin
  if (i<0) or ( i>= Count ) then
    Result := nil
  else
    Result := Items[i] as TBHultPrice;
end;

function TBHultPrices.New(aPrice : TPriceItem2): TBHultPrice;
begin
  Result := Add as TBHultPrice;
  Result.PriceItem := aPrice;
  Result.SendOrder := false;
  Result.Index := Count - 1;
end;

procedure TBHultPrices.ReSet(iStart, iEnd: integer);
var
  i : integer;
  aItem : TBHultPrice;
begin
  for i := iStart to iEnd do
  begin
    aItem := BHultPrice[i] ;
    if aItem <> nil then
      aItem.SendOrder := false;
  end;
end;

procedure TBHultPrices.SetIndex(iBase, iCurrent, iSide: integer; bSend : boolean);
begin

  FBaseIndex := iBase;
  FCurrentIndex := iCurrent;
  FSide := iSide;

  if FSide = 0 then
    FMaxIndex := FBaseIndex
  else if FSide > 0 then
    FMaxIndex := Max( FMaxIndex, FCurrentIndex)
  else if FSide < 0 then
    FMaxIndex := Min( FMaxIndex, FCurrentIndex);
end;

{ TBHultPrice }

constructor TBHultPrice.Create(aCol: TCollection);
begin
  inherited Create( aCol );
  ClearOrders := TCollection.Create(TClearOrder);
end;

destructor TBHultPrice.Destroy;
begin
  ClearOrders.Free;
  inherited;
end;

end.
