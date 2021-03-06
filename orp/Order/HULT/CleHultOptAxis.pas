unit CleHultOptAxis;

interface
uses
  Classes, SysUtils, Math, DateUtils,

  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFrontOrder,

  UObjectBase, UPaveConfig, UPriceItem,  UFillList, CleQuoteTimers, CleOrderPieces,

  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleCircularQueue, CleStrategyStore,

  GleTypes, GleConsts;
type

  THultOptAxis = class(TStrategyBase)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FPriceSet: TPriceSet;
    FData: THultOptData;
    FLossCut : boolean;
    FOrders: TOrderItem;
    FReady: boolean;
    FMyFills: TFillList;
    FOnPositionEvent: TObjectNotifyEvent;
    FLcTimer : TQuoteTimer;
    FSelPieces: TOrderPieces;
    FBuyPieces: TOrderPieces;

    FAskPrice : TPriceItem2;
    FBidPrice : TPriceItem2;

    FAskStartIdx: integer;
    FBidStartIdx: integer;
    FRemSide, FRemNet, FRemQty : integer;
    FScreenNumber : integer;
    FMaxPL, FMinPL : double;
    FRun : boolean;

    procedure OnLcTimer( Sender : TObject );
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    procedure DoOrder( aPrice : TPriceItem2; iQty : integer); overload;
    procedure DoOrder(iSide: integer; dPrice: double; iIdx : integer); overload;
    function IsRun : boolean;
    procedure DoInit( aQuote : TQuote );
    procedure UpdateQuote(aQuote: TQuote);
    procedure DoFill(aOrder: TOrder;  bFull : boolean = false);
    procedure MakePriceItem;
    procedure Reset;
    procedure DoOrderPiece( aQuote : TQuote; iSide : integer );
    function IsOrder(aPrice: TPriceItem2): boolean;
    function GetOrderSpecies : TOrderSpecies;
    function HULTLossCut( iSide: integer): integer;
    procedure AddPieces(aOrder1 : TOrder);
    procedure SearchSymbol;
    procedure DoLog;

    procedure SetEndIdx(aOrder : TOrder; bCancel : boolean);
  public
    //Constructor Create( aColl : TCollection ) ; override;
    //Destructor  Destroy; override;
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    procedure init( aAcnt : TAccount; aSymbol : TSymbol);
    function Start : boolean;
    Procedure Stop(bLossCut : boolean = true);
    function CheckHULTLossCut( iNet, iSide : integer ) : boolean ;
    property Orders   : TOrderItem read FOrders ;
    property PriceSet : TPriceSet  read FPriceSet ;
    property Data  : THultOptData read FData write FData;

    property Ready    : boolean    read FReady ;  // ?????? ?????? / ???? ????????
    property AskEndIdx : integer read FAskStartIdx;
    property BidEndIdx : integer read FBidStartIdx;
    property BuyPieces  : TOrderPieces read FBuyPieces;
    property SelPieces  : TOrderPieces read FSelPieces;
    property MyFills    : TFillList read FMyFills ;
    property ScreenNumber : integer read FScreenNumber;
    property Symbol : TSymbol read FSymbol;
    property MaxPL : double read FMaxPL;
    property MinPL : double read FMinPL;
    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
  end;

implementation
uses
  GAppEnv, GleLib, Dialogs, CleFQN;

{ THultAxis }

procedure THultOptAxis.AddPieces(aOrder1 : TOrder);
var
  iBidCnt, iAskCnt, i, iMax, iGap : integer;
  tgPrice, aPrice : TPRiceITem2;
  aPiece : TOrderPiece;
  aOrder : TOrder;
begin

  iBidCnt := FPriceSet.BidOrdCnt;// iBidSend; // ???? ?????????? ???????? ???? ??????
  iAskCnt := FPriceSet.AskOrdCnt;// -  iAskSend; // ???? ?????????? ???????? ???? ??????
  if (FBidPrice <> nil) and (FAskPrice <> nil) then
    gEnv.EnvLog( WIN_OPTHULT,  Format('Start AddPieces :BidOrd = %d, AskOrd = %d, Index Bid = %d(%.1f), Ask = %d(%.1f)',
                                 [iBidCnt, iAskCnt, FBidPrice.Index, FBidPrice.Price, FAskPrice.Index, FAskPrice.Price])  );

    //
  if iAskCnt < FData.QuotingQty then
  begin
    //???? ????
    if FAskPrice <> nil then
    begin
      tgPrice := FPriceSet.PriceItem[FAskPrice.Index + FData.OrdGap];
      if tgPrice <> nil then
      begin
        aPiece := FSelPieces.New( -1, FAskPrice.Price );
        aPiece.FilledPrice  := FAskPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FData.OrdQty;
        gEnv.EnvLog( WIN_OPTHULT,  Format('Add New Piece(%d) Price > 0 : ???? %s  %s [%d]', [
          FSelPieces.Count,  FAskPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume])  );
      end;
    end;
  end else if iAskCnt > FData.QuotingQty then
  begin
    if FAskPrice <> nil then
    begin
      if FAskPrice.CancelOrderCheck then
      begin
        for i := 0 to FAskPrice.OrderList.Count - 1 do
        begin
          aOrder := FAskPrice.OrderList.Orders[i];
          gEnv.Engine.TradeCore.FrontOrders.DoCancel( aOrder );
          gEnv.EnvLog( WIN_OPTHULT,  Format('Cancel : ???? %s', [FAskPrice.GetPriceDesc])  );
        end;
      end else
      begin
        gEnv.EnvLog( WIN_OPTHULT,  Format('Cancel : ???? ?????? ?????? ????  %s', [FAskPrice.GetPriceDesc])  );
      end;
    end;
  end;

  if iBidCnt < FData.QuotingQty then
  begin
    //???? ????
    if FBidPrice <> nil then
    begin
      tgPrice := FPriceSet.PriceItem[FBidPrice.Index - FData.OrdGap];
      if tgPrice <> nil then
      begin
        aPiece := FBuyPieces.New( 1, FBidPrice.Price );
        aPiece.FilledPrice  := FBidPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex  := tgPrice.Index;
        aPiece.OrderQty := FData.OrdQty;
        gEnv.EnvLog( WIN_OPTHULT,  Format('Add New Piece(%d) Price > 0 : ???? %s, %s [%d]', [
          FBuyPieces.Count,  FBidPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume])  );
      end;
    end;
  end else if iBidCnt > FData.QuotingQty then
  begin
    if FBidPrice <> nil then
    begin
      if FBidPrice.CancelOrderCheck then
      begin
        for i := 0 to FBidPrice.OrderList.Count - 1 do
        begin
          aOrder := FBidPrice.OrderList.Orders[i];
          gEnv.Engine.TradeCore.FrontOrders.DoCancel( aOrder );
          gEnv.EnvLog( WIN_OPTHULT,  Format('Cancel : ???? %s', [FBidPrice.GetPriceDesc])  );
        end;
      end else
      begin
        gEnv.EnvLog( WIN_OPTHULT,  Format('Cancel : ???? ?????? ?????? ????  %s', [FBidPrice.GetPriceDesc])  );
      end;
    end;
  end;

//???? ???????? ?????? ?? ????????
  if iAskCnt >= FData.QuotingQty then
  begin
    tgPrice := FPriceSet.PriceItem[aOrder1.PriceIdx + (FData.OrdGap * FData.QuotingQty)];
    if (tgPrice <> nil) and (tgPrice.OrderList.Count > 0) then
    begin
      aOrder := tgPrice.OrderList[0];
      if aOrder.OrderType = otCancel then
      begin
        aPiece := FSelPieces.New( -1, tgPrice.Price );
        aPiece.FilledPrice  := tgPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FData.OrdQty;
        gEnv.EnvLog( WIN_OPTHULT,  Format('Add New Piece ????  iAskCnt(%d) >= QuotingCnt(%d) : %s  ]', [ iAskCnt,
                                         FData.QuotingQty, tgPrice.GetPriceDesc])  );
      end;
    end;
  end;

  if iBidCnt >= FData.QuotingQty then
  begin
    tgPrice := FPriceSet.PriceItem[aOrder1.PriceIdx - (FData.OrdGap * FData.QuotingQty)];
    if (tgPrice <> nil) and (tgPrice.OrderList.Count > 0) then
    begin
      aOrder := tgPrice.OrderList[0];
      if aOrder.OrderType = otCancel then
      begin
        aPiece := FBuyPieces.New( 1, tgPrice.Price );
        aPiece.FilledPrice  := tgPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FData.OrdQty;
        gEnv.EnvLog( WIN_OPTHULT,  Format('Add New Piece ????  iBidCnt(%d) >= QuotingCnt(%d) : %s  ]', [ iBidCnt,
                                         FData.QuotingQty, tgPrice.GetPriceDesc])  );

      end;
    end;
  end;
end;

function THultOptAxis.CheckHULTLossCut(iNet, iSide: integer): boolean;
var
  stLog : string;
begin
  Result := false;
  if Position = nil then exit;
  {
  if iNet >= FData.MaxNet then
  begin

    stLog := Format('%s, %s ???????? %d, ?????? %d (%d) ', [ FSymbol.Code,
      ifthenStr( iSide > 0 ,'????','????'),  iNet, FData.MaxNet , Position.Volume]);

    gLog.Add( lkLossCut, 'THultAxis','CheckHULTLossCut', stLog  );

    FRemSide:= iSide;
    FRemNet := Position.Volume;
    FRemQty := 0;
    Result   := true;
    FLossCut := true;
  end;
         }
end;

constructor THultOptAxis.Create(aColl: TCollection; opType : TOrderSpecies);
begin
  inherited Create(aColl, opType, stOptHult, true);

  FScreenNumber := Number;


  FPriceSet := TPriceSet.Create;

  FMyFills:= TFillList.Create;
  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 5000 * 4;
  FLcTimer.OnTimer := OnLcTimer;

  FSelPieces:= TOrderPieces.Create;
  FBuyPieces:= TOrderPieces.Create;
  Reset;
end;

destructor THultOptAxis.Destroy;
begin
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);
  FPriceSet.Free;
  FMyFills.Free;
  FSelPieces.Free;
  FBuyPieces.Free;
  inherited;
end;

procedure THultOptAxis.DoFill(aOrder: TOrder; bFull : boolean);
var
  iOrdQty, iIdx, iGap, iTgIdx, iSide : integer;
  aType : TPositionType;
  aFill : TFill;
  aFItem : TFillItem;
  stLog : string;
  dPrice : double;
  aQuote : TQuote;
  tgPrice, aPrice : TPRiceITem2;
  aPiece : TOrderPiece;
  bRes : boolean;
begin
  if Position = nil then Exit;

  aFill := TFill( Position.Fills.Last );
  if aFill = nil then Exit;
  iOrdQty := abs(aFill.Volume);

  aQuote  := FSymbol.Quote as TQuote;

  stLog := format('New Fill : %s, %s, %s, %d (%d) %s|%s|%s ', [
    FSymbol.Code, ifThenStr( aOrder.Side > 0 ,'L','S' ),
    FSymbol.PriceToStr( aFill.Price ),
    iOrdQty, aOrder.OrderNo,
    FSymbol.PriceToStr( aQuote.Asks[0].Price ),
    FSymbol.PriceToStr( aQuote.Last ),
  FSymbol.PriceToStr( aQuote.Bids[0].Price )
     ]);
  gLog.Add(lkLossCut, 'THultAxis','DoFill', stlog);

  if aOrder.Side > 0 then
    aType := ptShort
  else
    aType := ptLong;

  if aOrder.PriceIdx < 0 then begin
    iIdx := FPriceSet.GetIndex( aOrder.Price );
    aOrder.PriceIdx := iIdx;
  end;

  if aOrder.State = osFilled then
  begin
    aPrice := FPriceSet.PriceItem[ aOrder.PriceIdx ];


    if aOrder.Side > 0 then begin
      aPiece := FSelPieces.New( aOrder.Side, aOrder.Price );
      aPiece.FilledPrice  := aPrice.Price;
      tgPrice := FPriceSet.PriceItem[ aPrice.Index + FData.OrdGap ];
      if tgPrice <> nil then begin
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex      := tgPrice.Index;
        aPiece.OrderQty := FData.OrdQty;
        gEnv.EnvLog( WIN_OPTHULT,  Format('New Piece(%d) : ???? ???? %s ?? ???? ???? %s [%d]', [
          FSelPieces.Count,  aPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume  ])  );
      end;
    end
    else begin
      aPiece := FBuyPieces.New( aOrder.Side, aOrder.Price );
      aPiece.FilledPrice  := aPrice.Price;
      tgPrice := FPriceSet.PriceItem[ aPrice.Index - FData.OrdGap ];
      if tgPrice <> nil then begin
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FData.OrdQty;

        gEnv.EnvLog( WIN_OPTHULT,  Format('New Piece(%d) : ???? ???? %s ?? ???? ???? %s [%d]', [
          FBuyPieces.Count,  aPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume])  );
      end;
    end;
  end;


  // ???? ?????? ???????? clear
  if aFill.Volume > 0 then
    iSide := 1
  else
    iSide := -1;

  if (aOrder.State = osFilled) and (bFull) then
  begin
    if FMyFills.Side = iSide then
    begin
      aFItem := FMyFills.New( GetQuoteTime );
      aFItem.Price  := aFill.Price;
      aFItem.Qty    := abs(aFill.Volume);
      aFItem.Side   := iSide;
      aFItem.Index  := aOrder.PriceIdx;
      aFItem.Order  := aOrder;
      if iSide = 1 then
        aFItem.PosType:= ptLong
      else  aFItem.PosType := ptShort;
    end;
  end;

  FMyFills.Side := iSide;

  bRes := CheckHULTLossCut( FMyFills.Count, FMyFills.Side  );
  if bRes then
    Stop
  else
  begin
    DoOrderPiece( aQuote, aOrder.Side );
    if (aOrder.State = osFilled) and (bFull) then
    begin
      AddPieces(aOrder);
      DoOrderPiece( aQuote,  1 );
      DoOrderPiece( aQuote, -1 );
    end;
  end;
end;

procedure THultOptAxis.DoInit(aQuote: TQuote);
var
  I, iAskIdx, iBidIdx: Integer;
  dLastAskPrice, dLastBidPrice : double;
  AskPrice, BidPrice : double;
  aItem : TPriceItem2;

  function IsLAskimited : boolean;
  begin
    if (FSymbol.LimitHigh > dLastAskPrice + EPSILON ) and (aQuote.Asks[0].Price + EPSILON < dLastAskPrice ) then
      Result := false
    else
      Result := true;
  end;

  function IsBidLimited : boolean;
  begin
    if (FSymbol.LimitLow <  dLastBidPrice + EPSILON ) and (aQuote.Bids[0].Price + EPSILON > dLastBidPrice ) then
      Result := false
    else
      Result := true;
  end;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;

  if aQuote.FTicks.Count <= 0 then exit;

  // ???? ??????....
  if FSymbol = nil then
    SearchSymbol;
  if not IsRun then exit;

  aQuote := FSymbol.Quote as TQuote;
  AskPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Last, FData.OrdGap );
  BidPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Last, -FData.OrdGap );

  gLog.Add( lkLossCut, 'THultAxis','DoInit', Format('Index  : %s <- %s | %s -> %s cnt:%d',
    [
      aQuote.Symbol.PriceToStr( AskPrice ),
      aQuote.Symbol.PriceToStr( aQuote.Asks[0].Price ),
      aQuote.Symbol.PriceToStr( aQuote.Bids[0].Price ),
      aQuote.Symbol.PriceToStr( BidPrice ),
      FPriceSet.Count-1
    ]));

  for I := 0 to FData.QuotingQty - 1 do
  begin
    dLastAskPrice := IfThenFloat( i=0, AskPrice,  TicksFromPrice( FSymbol, dLastAskPrice, FData.OrdGap ));
    dLastBidPrice := IfThenFloat( i=0, BidPrice,  TicksFromPrice( FSymbol, dLastBidPrice, -FData.OrdGap ));

    if (IsLAskimited or IsBidLimited) and (i = 0) then
    begin
      FAskStartIdx := -1;
      FBidStartIdx := -1;
      FSymbol := nil;
      break;
    end;

    iAskIdx := FPriceSet.GetIndex( dLastAskPrice );
    if iAskIdx >= 0 then begin
      gEnv.EnvLog( WIN_OPTHULT, Format('???? : %d, %s, %d, %d', [ i, FSymbol.PriceToStr( dLastAskPrice ), iAskIdx, FData.OrdGap ])  );
      DoOrder( -1, dLastAskPrice, iAskIdx );
      FAskPrice := FPriceSet.PriceItem[iAskIdx];
      if FAskStartIdx < 0 then
        FAskStartIdx := iAskIdx;
    end;

    iBidIdx := FPriceSet.GetIndex( dLastBidPrice );
    if iBidIdx >= 0 then begin
      gEnv.EnvLog( WIN_OPTHULT, Format('???? : %d, %s, %d, %d', [ i, FSymbol.PriceToStr( dLastAskPrice ), iBidIdx, FData.OrdGap ])  );
      DoOrder( 1, dLastBidPrice, iBidIdx  );
      FBidPrice := FPriceSet.PriceItem[iBidIdx];
      if FBidStartIdx < 0 then
        FBidStartIdx := iBidIdx;
    end;
  end;
  if ( FAskStartIdx >= 0 ) and  ( FBidStartIdx >= 0 ) then
    FReady := true
  else
  begin
    //gEnv.EnvLog( WIN_OPTHULT, Format('Start Index Error FAskStartIdx = %d, FBidStartIdx = %d ', [FAskStartIdx, FBidStartIdx]) );
    //stop;
    //ShowMessage( 'End Index Error ' );
  end;
end;

procedure THultOptAxis.DoLog;
var
  stLog, stFile : string;
begin
  if Position = nil then
    stLog := Format('%s, %s, %d, %d, %d, %d, %d', [FormatDateTime(' yyyy-mm-dd', GetQuoteTime), '' ,
                FData.OrdGap, 0, 0, 0, 0])
  else
    stLog := Format('%s, %s, %d, %.0f, %.0f, %.0f, %d', [FormatDateTime(' yyyy-mm-dd', GetQuoteTime), Position.Symbol.ShortCode,
                FData.OrdGap, (Position.LastPL - Position.GetFee)/1000, MaxPL/1000, MinPL/1000, Position.MaxPos]);

  stFile := Format('OptHult_%s.csv', [FAccount.Code]);
  gEnv.EnvLog(WIN_OPTHULT, stLog, true, stFile);
end;

procedure THultOptAxis.DoOrder(iSide: integer; dPrice: double; iIdx: integer);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
  aPos : TPosition;
  aPrice : TPriceItem2;
  iMax : integer;
begin
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);

  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, Account, FSymbol,
                FData.OrdQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := GetOrderSpecies;

    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'Send Order : %s, %s, %s, %d, %d ',
      [
        FSymbol.Code,
        ifThenStr( iSide > 0 , 'L', 'S'),
        FSymbol.PriceToStr( dPrice ),
        FData.OrdQty, iIdx
      ]
      );

    gEnv.EnvLog( WIN_OPTHULT, Format('???? : %s', [ aOrder.Represent2 ]) , false, FSymbol.Code);
    gLog.Add(lkLossCut, 'TPriceAxis','DoOrder', stLog );

    aPrice  := FPriceSet.PriceItem[iIdx];
    if aPrice <> nil then
    begin
      aPrice.AddOrder( aOrder );
      aOrder.PriceIdx := iIdx;
    end;
  end;
end;

procedure THultOptAxis.DoOrder(aPrice: TPriceItem2; iQty : integer);
var
  iMax, i : integer;
  iCnt, iLiqQty, iLiqQty2, iSide : integer;
  aOrder : TOrder;
  tgType : TPositionType;
  aTicket : TOrderTicket;
begin
  if aPrice.PositionType = ptLong then
    iSide := 1
  else
    iSide := -1;

  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, FSymbol,
    iQty * iSide, pcLimit, aPrice.Price, tmGTC, aTicket);
  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := GetOrderSpecies;
    aPrice.AddOrder( aOrder );
    aOrder.PriceIdx := aPrice.Index;
    gEnv.Engine.TradeBroker.Send(aTicket);
    SetEndIdx(aOrder, false);
  end;
  //gEnv.EnvLog( WIN_OPTHULT, Format('???? : %s', [ aOrder.Represent2 ]) , false, FSymbol.Code);
end;

procedure THultOptAxis.DoOrderPiece(aQuote: TQuote; iSide: integer);
var
  iIndex: Integer;
  aPiece : TOrderPiece;
  aPrice : TPriceItem2;
begin
  // ???? ???????? SelPiece ???? ????????.
  iIndex := 0;


  if iSide > 0 then
  begin
    while iIndex <= FSelPieces.Count - 1 do
    begin
      aPiece  := FSelPieces.OrderPiece[iIndex];
      aPrice  := FPriceSet.PriceItem[ aPiece.OrderIndex ];

      if aPrice <> nil then
         gEnv.EnvLog(WIN_OPTHULT, Format('DoOrderPiece ???? idx = %d, Cnt = %d',[aPiece.OrderIndex, aPrice.OrderList.Count]) );


      if ( aPrice <> nil ) and
         ( IsOrder( aPrice )) and ( aPrice.OrderList.Count = 0) then
      begin
        // ?????? ?????? ???????? ??????
        aPrice.PositionType := ptShort;
        DoOrder( aPrice, aPiece.OrderQty );

        gEnv.EnvLog( WIN_OPTHULT, Format( 'Ord Piece(%d) : ???? %s -> %s ,%d : %s', [ FSelPieces.Count,
          FSymbol.PriceToStr( aPiece.FilledPrice), FSymbol.PriceToStr( aPiece.OrderPrice),
          aPiece.OrderIndex, aPrice.PriceDesc])  );

        FSelPieces.Delete(iIndex);
      end else
        inc(iIndex);
    end;
  end
  else begin
    while iIndex <= FBuyPieces.Count-1 do
    begin
      aPiece  := FBuyPieces.OrderPiece[iIndex];
      aPrice  := FPriceSet.PriceItem[ aPiece.OrderIndex ];

      if aPrice <> nil then
         gEnv.EnvLog(WIN_OPTHULT, Format('DoOrderPiece ???? idx = %d, Cnt = %d, Price = %.2f',[aPiece.OrderIndex, aPrice.OrderList.Count, aPrice.Price]) );

      if ( aPrice <> nil ) and
         ( IsOrder( aPrice )) and ( aPrice.OrderList.Count = 0) then
      begin
        // ?????? ?????? ???????? ??????
        aPrice.PositionType := ptLong;
        DoOrder( aPrice, aPiece.OrderQty );

        gEnv.EnvLog( WIN_OPTHULT, Format( 'Ord Piece(%d) : ???? %s -> %s ,%d : %s', [ FBuyPieces.Count,
          FSymbol.PriceToStr( aPiece.FilledPrice), FSymbol.PriceToStr( aPiece.OrderPrice),
          aPiece.OrderIndex, aPrice.PriceDesc])  );

        FBuyPieces.Delete(iIndex);
      end else
        inc(iIndex);
    end;
  end;
end;

function THultOptAxis.GetOrderSpecies: TOrderSpecies;
begin
  Result := opOptHult
end;

function THultOptAxis.HULTLossCut(iSide: integer): integer;
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
    //????.... ??????
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
      stLog := Format('OptHult???? %s',[aOrder.Represent2]);
      gEnv.EnvLog(WIN_OPTHULT, stLog);
      aOrder.OrderSpecies := GetOrderSpecies;
      gEnv.Engine.TradeBroker.Send(aTicket);
      end;
  end;
  Result := 0;
end;

procedure THultOptAxis.init(aAcnt: TAccount; aSymbol: TSymbol);
begin
  FAccount := aACnt;
  Account := FAccount;
  Reset;
end;

function THultOptAxis.IsOrder(aPrice: TPriceItem2): boolean;
var
  idx, iRe : Integer;
begin
  Result := false;
  if aPrice.PositionType = ptLong then
    idx := abs( FBidStartIdx - aPrice.Index )
  else
    idx := abs( FAskStartIdx - aPrice.Index );
  iRe := idx mod FData.OrdGap;
  if iRe = 0 then
    Result := true;
end;

function THultOptAxis.IsRun: boolean;
begin

  if ( not FRun ) or ( FSymbol = nil ) or ( FAccount = nil ) or ( Orders = nil ) then
    Result := false
  else
    Result := true;

end;

procedure THultOptAxis.MakePriceItem;
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

procedure THultOptAxis.OnLcTimer(Sender: TObject);
begin
  if Position = nil then exit;
  if Position.Volume = 0 then
  begin
    //FLcTimer.Enabled := false;
    //FLossCut := false;
    gLog.Add( lkLossCut, '','', Format( 'LcTimer Stop :%d, %d -> %d (%d)',
        [ FRemSide, FRemNet, FRemQty,  Position.Volume ] ) );
    Exit;
  end;

  FRemQty := FRemQty + HULTLossCut( FRemSide );
  gLog.Add( lkLossCut, '','', Format( 'LcTimer Time :%d, %d -> %d',
        [ FRemSide, FRemNet, FRemQty ] ) );
end;

procedure THultOptAxis.QuoteProc(aQuote: TQuote; iDataID : integer);
begin

  if iDataID = 300 then
  begin
    DoLog;
    exit;
  end;

  if not FReady then
    DoInit( aQuote )
  else
    UpdateQuote( aQuote );
end;

procedure THultOptAxis.Reset;
begin
  FRun := false;
  FReady  := false;
  FLossCut:= false;
  FAskStartIdx  := -1;
  FBidStartIdx  := -1;
  FMyFills.Clear;
  FSelPieces.Clear;
  FBuyPieces.Clear;
  FPriceSet.ReSet;

  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FOrders := nil;
  FSymbol := nil;
end;

procedure THultOptAxis.SearchSymbol;
var
  stLog : string;
  bCall : boolean;
begin
  if FAccount = nil then exit;
  FSymbol := nil;

  if FData.CallPut = 0 then
    bCall := true
  else
    bCall := false;

  GetHighSymbol(bCall, 0, FData.OptPrice, FSymbol);

  if FSymbol <> nil then
  begin
    if (FSymbol.Quote as TQuote).FTicks.Count <= 0 then
    begin
      FSymbol := nil;
      exit;
    end;
    stLog := Format('SearchSymbol %s(%.2f)',[FSymbol.ShortCode, FSymbol.Last]);
    gEnv.EnvLog(WIN_OPTHULT, stLog);
    AddPosition(FSymbol);


    if gEnv.RunMode = rtSimulation then
    begin
      if (FSymbol as TOption).DaysToExp = 1 then
        FData.LiquidTime := EnCodeTime(14, 45, 0 ,0)
      else
        FData.LiquidTime := EnCodeTime(15, 0, 0 ,0);
    end;
    
    FOrders := gEnv.Engine.TradeCore.FrontOrders.New( FAccount, FSymbol );
    MakePriceItem;
  end;
end;

procedure THultOptAxis.SetEndIdx(aOrder: TOrder; bCancel: boolean);
var
  i, iIndex : integer;
  aPrice : TPriceItem2;
  aOrder1 : TOrder;
  stData : string;
begin
  if bCancel then
  begin
    stData := '????';
    if aOrder.Side > 0 then
    begin
      iIndex := aOrder.PriceIdx;
      if FBidPrice.Index <> aOrder.PriceIdx then
      begin
        gEnv.EnvLog(WIN_OPTHULT, Format('SetEndIdx ???? Price = %d(%.1f), Order = %d(%.1f)', [FBidPrice.Index, FBidPrice.Price, aOrder.PriceIdx, aOrder.Price] ));
        exit;
      end;

      while true do
      begin
        aPrice := FPriceSet.PriceItem[iIndex];
        if aPrice = nil then break;
        if aPrice.OrderList.Count > 0 then
        begin
          aOrder1 := aPrice.OrderList[0];
          if aOrder1.Side = aOrder.Side then
          begin
            FBidPrice := aPrice;
            break;
          end else
          begin
            //FBidPrice := FPriceSet.PriceItem[aOrder1.PriceIdx - FHultData.OrdGap];
            break;
          end;
        end;
        iIndex := iIndex + FData.OrdGap;
      end;
    end else
    begin
      iIndex := aOrder.PriceIdx;

      if FAskPrice.Index < aOrder.PriceIdx then
      begin
        gEnv.EnvLog(WIN_OPTHULT, Format('???? Price = %d(%.1f), Order = %d(%.1f)', [FAskPrice.Index, FAskPrice.Price, aOrder.PriceIdx, aOrder.Price] ));
        exit;
      end;

      while true do
      begin
        aPrice := FPriceSet.PriceItem[iIndex];
        if aPrice = nil then break;
        if aPrice.OrderList.Count > 0 then
        begin
          aOrder1 := aPrice.OrderList[0];
          if aOrder1.Side = aOrder.Side then
          begin
            FAskPrice := aPrice;
            break;
          end else
          begin           //???????? ?????? ???????? ???? ?????? ???????? ?????????? ???????? ????????
            //FAskPrice := FPriceSet.PriceItem[aOrder1.PriceIdx + FHultData.OrdGap];
            break;
          end;
        end;
        iIndex := iIndex - FData.OrdGap;
      end;
    end;
  end else
  begin
    stData := '????';
    if aOrder.Side > 0 then
    begin
      if FBidPrice.Index > aOrder.PriceIdx then
        FBidPrice := FPriceSet.PriceItem[aOrder.PriceIdx];
    end else
    begin
      if FAskPrice.Index < aOrder.PriceIdx then
        FAskPrice := FPriceSet.PriceItem[aOrder.PriceIdx];
    end;
  end;

  {
  if (FBidPrice <> nil) and (FAskPrice <> nil) then
    gEnv.EnvLog( WIN_OPTHULT,  Format('SetEndIdx :BidOrd = %d, AskOrd = %d, Index Bid = %d(%.1f), Ask = %d(%.1f), %s',
                                 [FPriceSEt.BidOrdCnt, FPriceSet.AskOrdCnt, FBidPrice.Index, FBidPrice.Price, FAskPrice.Index, FAskPrice.Price, stData])  );
                                 }
end;

function THultOptAxis.Start: boolean;
begin
  Result := false;
  if FAccount = nil  then Exit;
  FRun := true;

  //AddPosition(FSymbol);
  {gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, FSymbol,
    gEnv.Engine.QuoteBroker.DummyEventHandler);}

  //gLog.Add( lkLossCut, 'THulAxis','Start', FSymbol.Code );
end;

procedure THultOptAxis.Stop(bLossCut : boolean);
var
  iQty, iMaxQty, iTotQty : integer;
begin
  FRun := false;

  if FSymbol <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, FSymbol );
    gLog.Add( lkLossCut, 'THulAxis','Stop', FSymbol.Code );
  end;

  if FOrders <> nil then
    gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );


  if bLossCut then
    HULTLossCut(1);
  FSymbol := nil;
  {
  if FLossCut then
    if Position.Volume <> 0  then
    begin
      gLog.Add( lkLossCut, '','', Format( 'LcTimer ???? :%d, %d -> %d',
        [ FRemSide, FRemNet, FRemQty ] ) );
      //FLcTimer.Enabled := true;
    end;}

end;

procedure THultOptAxis.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
var
  aPrice : TPriceItem2;
  idx : integer;
  I, iQty: Integer;
  bFind, bFull, bCancel : boolean;
  stLog : string;
begin
  if not IsRun then Exit;
  if aOrder.PriceIdx >= 0 then
  begin
    aPrice  := FPriceSet.PriceItem[aOrder.PriceIdx];
  end else
  begin
    idx := FPriceSet.Find( aOrder.Price);
    if idx >= 0 then
    begin
      aOrder.PriceIdx  := idx;
      aPrice  := FPriceSet.PriceItem[aOrder.PriceIdx];
    end;

    aOrder.OrderSpecies := GetOrderSpecies;
    if aPrice <> nil then
      aPrice.AddOrder( aOrder );
  end;

  iQty := 0;
  if (iID = ORDER_FILLED) and (Position <> nil) then
    iQty := TFill( Position.Fills.Last ).Volume;

  bFull := false;
  if aPrice <> nil then
    bFull := aPrice.OnOrder( aOrder, iQty );

  bCancel := false;
  if (iID = ORDER_CANCELED) then
    bCancel := true;

  SetEndIdx(aOrder, bCancel);

  if iID = ORDER_FILLED then begin
    gEnv.EnvLog( WIN_OPTHULT, Format('???? : %s ', [ aOrder.Represent2 ]));
    DoFill( aOrder, bFull );
  end
  else if iID = ORDER_ACCEPTED then
    gEnv.EnvLog( WIN_OPTHULT, Format('???? : %s ',[aOrder.Represent2 ]));
end;

procedure THultOptAxis.UpdateQuote(aQuote: TQuote);
var
  stTime, stTime1 : string;
  dPL : double;
begin

  if Position <> nil then
  begin
    FMinPL := Min( FMinPL, (Position.LastPL - Position.GetFee) );
    FMaxPL := Max( FMaxPL, (Position.LastPL - Position.GetFee) );
  end;

  if not IsRun then Exit;
  if aQuote.Symbol = gEnv.Engine.SymbolCore.Futures[0] then exit;
  stTime := FormatDateTime('hh:mm:ss.zzz', FData.LiquidTime);
  stTime1 := FormatDateTime('hh:mm:ss.zzz', GetQuoteTime);
  if (FData.UseAutoLiquid) and (Frac(FData.LiquidTime) <= Frac(GetQuoteTime)) then
  begin
    if Position <> nil then
    begin
      if Position.Volume > 0 then
      begin
        FRemNet := Position.Volume;
        FRemSide := 1;
      end else
      begin
        FRemNet := abs(Position.Volume);
        FRemSide := -1;
      end;
    end;
    FLossCut := true;
    Stop;
  end;

  if Position <> nil then
  begin
    dPL := (Position.LastPL - Position.GetFee)/1000;
    if (FData.UseAllCnlNStop) and (dPL <= FData.RiskAmt * -1 ) then
    begin
      if Position.Volume > 0 then
      begin
        FRemNet := Position.Volume;
        FRemSide := 1;
      end else
      begin if Position.Volume < 0 then
        FRemNet := abs(Position.Volume);
        FRemSide := -1;
      end;
      FLossCut := true;
      Stop;
    end;
  end;

  DoOrderPiece( aQuote, 1 );
  DoOrderPiece( aQuote, -1 );
end;

end.
