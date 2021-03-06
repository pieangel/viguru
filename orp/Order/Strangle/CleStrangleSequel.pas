unit CleStrangleSequel;

interface

uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleStrategyStore, CleOrderBeHaivors
  ;
type
  THedgeStatus = (hsNone, hsUp1, hsUp2, hsUp3, hsDown1, hsDown2, hsDown3);
  TBidAskType = (baNone, baCallBid, baCallAsk, baPutBid, baPutAsk);
  THedgeType = (htNone, htAll, htLow, htHigh);

  TStrangleSequelTrade = class;

  TStrangleSequelParams = record
    Start : boolean;
    OrderQty : integer;
    UpBid : array[0..2] of double;
    UpAsk : array[0..2] of double;
    DownBid : array[0..2] of double;
    DownAsk : array[0..2] of double;
    HedgeType : THedgeType;
    LowPrice : double;
    HighPrice : double;
    LiqAmt  : double;
  end;

  TTimeOrder = class(TCollectionItem)
  private
    FSend : boolean;
    FTimeOrder : TDateTime;
  public
    property Send : boolean read FSend;
  end;

  TTimeOrders = class(TCollection)
  private
  public
    constructor Create;
    destructor Destroy; override;
    function AddTime(wH, wM, wS, wMs : Word) : TTimeOrder;
    function NextTime : TTimeOrder;
  end;

  TStrangleSequel = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FPosition : TPosition;
    FHedgeType : THedgeType;
    FTrading : boolean;
    FCallHedge : array[0..2] of boolean;
    FPutHedge : array[0..2] of boolean;
  public
    procedure SetCallPutHedge(aStatus : THedgeStatus; aType: TBidAskType);
    function GetIndex(aStatus : THedgeStatus; bAsk : boolean) : integer;
    property Symbol : TSymbol read FSymbol;
    property Position : TPosition read FPosition write FPosition;
    property Trading : boolean read FTrading;
  end;



  TStrangleSequels = class(TCollection)
  private
    FAccount : TAccount;
    FParam : TStrangleSequelParams;
    FScreenNumber : integer;
    FFut : TSymbol;
    FHedgeStatus : THedgeStatus;
    FTimeOrders : TTimeOrders;
    FCurrentTime : TTimeOrder;
    FBidAskCnt : array[0..1] of integer;
    FHedge : array[0..1] of double;
    FBidStart : boolean;
    FTradingCnt : integer;
    FTrade : TStrangleSequelTrade;
    FBeHaivors : TOrerBeHaivors;
    procedure ClearOrder;
    procedure SetHedge(dBid, dAsk : double);
    procedure InitTrading;
    function CheckTimeOrder(dEndTime : TDateTime) : boolean;
    function Find(aSymbol : TSymbol; aType : THedgeType) : TStrangleSequel;
    function DoOrder(aSymbol : TSymbol ; iSide, iQty : integer) : TOrder;
    function GetPrice(aSymbol : TSymbol; iSide : integer) : double;
    function GetSide(aType : TBidAskType) : integer;
    function GetCallPut(aType : TBidAskType) : string;
    function GetBidAskTypeDesc( aType : TBidAskType) : string;
    function CheckHedge(aQuote : TQuote) : TBidAskType;
    function SendOrder(aItem : TStrangleSequel; aType : TBidAskType; bHedge : boolean) : boolean;
    function CheckLowOrder( aItem : TStrangleSequel; bHedge : boolean) : boolean;
    function GetHedgeType(aType : THedgeType) : string;
    function GetDesc(bTrue : boolean) : string;

  public
    constructor Create;
    destructor Destroy; override;
    procedure SetOrderTime;
    procedure SetHedgeBidOrder;
    procedure SetLowPrice;
    procedure SetPosition(aPos : TPosition);
    function GetStatusDesc : string;
    function AddSymbol(aSymbol: TSymbol; aType : THedgeType) : TStrangleSequel;
    function GetTimeOrder(iIndex : integer) : TTimeOrder;
    property BidStart : boolean read FBidStart write FBidStart;
    property ScreenNumber : integer read FScreenNumber;
    property TradingCnt : integer read FTradingCnt;


  end;

  TStrangleSequelTrade = class(TStrategyBase)
  private
    FStrangleSe : TStrangleSequels;
    procedure TimeOrder;
    procedure HedgeOrder( aType : TBidAskType);
    function GetHedgeType( aCall1, aCall2 : TSymbol ) : THedgeType;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;
    procedure ClearOrder;

    procedure SetAccount(aAcnt : TAccount);
    procedure StartStop(aParam : TStrangleSequelParams);
    procedure ReSet;
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    property StrangleSe : TStrangleSequels read FStrangleSe;
  end;
implementation
uses
  GAppEnv, GleConsts;

{ TStrangleSequelTrade }

procedure TStrangleSequelTrade.ClearOrder;
begin
  FStrangleSe.ClearOrder;
end;

constructor TStrangleSequelTrade.Create(aColl: TCollection;
  opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stStrangle2, true);
  FStrangleSe := TStrangleSequels.Create;
  FStrangleSe.FScreenNumber := Number;
  FStrangleSe.FTrade := self;
end;

destructor TStrangleSequelTrade.Destroy;
begin
  FStrangleSe.Free;
  inherited;
end;

procedure TStrangleSequelTrade.HedgeOrder( aType : TBidAskType);
var
  i, iIndex : integer;
  stCP : string;
  aItem : TStrangleSequel;
  bHedge : boolean;
begin
  if FStrangleSe.FParam.HedgeType = htNone then exit;

  stCP := FStrangleSe.GetCallPut(aType);
   {
  for i := 0 to FStrangleSe.Count - 1 do
  begin
    aItem := FStrangleSe.Items[i] as TStrangleSequel;
    if (aItem.FTrading) and ((aItem.Symbol as TOption).CallPut = stCP) then
    begin
      if FStrangleSe.FParam.HedgeType = htAll then
        FStrangleSe.SendOrder(aItem, aType, true)
      else
      begin
        if aItem.FHedgeType = FStrangleSe.FParam.HedgeType then
          FStrangleSe.SendOrder(aItem, aType, true);
      end;
    end;
  end;
   }
  case aType of
    baCallBid,
    baPutBid:
    begin
      for i := 0 to FStrangleSe.Count - 1 do                  // ???? ???? ????
      begin
        aItem := FStrangleSe.Items[i] as TStrangleSequel;
        if (aItem.FTrading) and ((aItem.Symbol as TOption).CallPut = stCP) then
        begin
          if FStrangleSe.FParam.HedgeType = htAll then
            FStrangleSe.SendOrder(aItem, aType, true)
          else
          begin
            if aItem.FHedgeType = FStrangleSe.FParam.HedgeType then
              FStrangleSe.SendOrder(aItem, aType, true);
          end;
        end;
      end;
    end;
    baCallAsk,
    baPutAsk:
    begin
      for i := 0 to FStrangleSe.Count - 1 do                  // ???? ?????? ?????? ???? ???????? ??????.
      begin
        aItem := FStrangleSe.Items[i] as TStrangleSequel;
        iIndex := aItem.GetIndex(FStrangleSe.FHedgeStatus, true);
        if stCP = 'C' then
          bHedge := aItem.FCallHedge[iIndex]
        else
          bHedge := aItem.FPutHedge[iIndex];

        if bHedge then
          FStrangleSe.SendOrder(aItem, aType, true);
      end;
    end;
  end;
end;

procedure TStrangleSequelTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  aType : TBidAskType;
  stTime : string;
  bRet : boolean;
begin
  if aQuote = nil then Exit;

  if aQuote.Symbol <> gEnv.Engine.SymbolCore.Futures[0] then exit;

  stTime := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime);
  bRet := FStrangleSe.CheckTimeOrder(EndTime);  //???????? ?????? ????????

  if bRet then   //???????? ????.... ????
    TimeOrder;

  if (aQuote.AddTerm) and (Frac(GetQuoteTime) > StartTime) then
  begin

    aType := FStrangleSe.CheckHedge(aQuote);
    HedgeOrder(aType);
  end;

  if Assigned(OnResult) then   //????????
    OnResult(aQuote, true);

end;

procedure TStrangleSequelTrade.ReSet;
begin
  FStrangleSe.Clear;
  FStrangleSe.BidStart := false;
end;

procedure TStrangleSequelTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FStrangleSe.FAccount := aAcnt;
end;

procedure TStrangleSequelTrade.StartStop(aParam: TStrangleSequelParams);
begin
  FStrangleSe.FParam := aParam;
end;

function TStrangleSequelTrade.GetHedgeType(aCall1, aCall2: TSymbol): THedgeType;
begin
  Result := htNone;
  if aCall1.Last > aCall2.Last then
    Result := htHigh
  else
    Result := htLow;
end;

procedure TStrangleSequelTrade.TimeOrder;
var
  i : integer;
  aList : TList;
  aSymbol : TSymbol;
  aType: TBidAskType;
  bLow : boolean;
  aHedge : THedgeType;
  aItem : TStrangleSequel;
begin
  aList := TList.Create;
  GetStrangleSymbol(FStrangleSe.FParam.LowPrice, FStrangleSe.FParam.HighPrice, aList);

  FStrangleSe.InitTrading;
  FStrangleSe.FTradingCnt := aList.Count;

  for i := 0 to aList.Count - 1 do
  begin
    aSymbol := aList.Items[i];  //0, 2 -> Call   1,3 => Put
    if (i = 0)  or (i = 2) then
      aType := baCallAsk
    else
      aType := baPutAsk;

    if aList.Count = 2 then
      aHedge := FStrangleSe.FParam.HedgeType
    else if aList.Count = 4 then
    begin
      if i = 0  then
        aHedge := GetHedgeType(aSymbol, aList.Items[2])
      else if i = 1 then
        aHedge := GetHedgeType(aSymbol, aList.Items[3])
      else if i = 2 then
        aHedge := GetHedgeType(aSymbol, aList.Items[0])
      else if i = 3 then
        aHedge := GetHedgeType(aSymbol, aList.Items[1])
    end;

    aItem := FStrangleSe.AddSymbol(aSymbol, aHedge);
    FStrangleSe.SendOrder(aItem, aType, false);
  end;
  aList.Free;;
end;

procedure TStrangleSequelTrade.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
begin
  if aPos = nil then exit;
  
  case iID of
    ORDER_FILLED : FStrangleSe.SetPosition(aPos);
  end;
end;

{ TStrangleSequels }

function TStrangleSequels.AddSymbol(aSymbol: TSymbol; aType : THedgeType): TStrangleSequel;
var
  stLog : string;
begin
  stLog := Format('AddSymbol %s, %.2f, %s',[aSymbol.ShortCode, aSymbol.Last, GetHedgeType(aType) ]);
    gEnv.EnvLog(WIN_STR2, stLog);
  Result := Find(aSymbol, aType);
  if Result <> nil then exit;
  Result := Add as TStrangleSequel;
  Result.FSymbol := aSymbol;
  Result.FPosition := nil;
  Result.FTrading := true;
  Result.FHedgeType := aType;
end;

function TStrangleSequels.CheckHedge(aQuote: TQuote): TBidAskType;
begin
  Result := baNone;
  if (not FParam.Start) then exit;
  case  FHedgeStatus of
    hsNone:
    begin
      if aQuote.Bids.CntTotal * FParam.UpBid[0] > aQuote.Asks.CntTotal then             //???? 1???? ??????
      begin
        FHedgeStatus := hsUp1;
        SetHedge( aQuote.Bids.CntTotal * FParam.UpBid[0], aQuote.Asks.CntTotal);
        Result := baCallBid;
      end else if aQuote.Asks.CntTotal * FParam.DownBid[0] > aQuote.Bids.CntTotal then  //???? 1???? ??????
      begin
        FHedgeStatus := hsDown1;
        SetHedge(aQuote.Asks.CntTotal * FParam.DownBid[0], aQuote.Bids.CntTotal);
        Result := baPutBid;
      end else
        FHedgeStatus := hsNone;
    end;
    hsUp1:
    begin
      if aQuote.Bids.CntTotal * FParam.UpBid[1] > aQuote.Asks.CntTotal then             //???? 2???? ??????
      begin
        FHedgeStatus := hsUp2;
        SetHedge( aQuote.Bids.CntTotal * FParam.UpBid[1], aQuote.Asks.CntTotal);
        Result := baCallBid;
      end else if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[0] then    //???? 1???? ??????
      begin
        FHedgeStatus := hsNone;
        SetHedge(aQuote.Bids.CntTotal, aQuote.Asks.CntTotal * FParam.UpAsk[0]);
        Result := baCallAsk;
      end;
    end;

    hsUp2:
    begin
      if aQuote.Bids.CntTotal * FParam.UpBid[2] > aQuote.Asks.CntTotal then               //???? 3???? ??????
      begin
        FHedgeStatus := hsUp3;
        SetHedge( aQuote.Bids.CntTotal * FParam.UpBid[2], aQuote.Asks.CntTotal);
        Result := baCallBid;
      end else if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[1] then      //???? 2???? ??????
      begin
        FHedgeStatus := hsUp1;
        SetHedge(aQuote.Bids.CntTotal, aQuote.Asks.CntTotal * FParam.UpAsk[1]);
        Result := baCallAsk;
      end;
    end;
    hsUp3:
    begin
      if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[2] then               //???? 3???? ??????
      begin
        FHedgeStatus := hsUp2;
        SetHedge(aQuote.Bids.CntTotal, aQuote.Asks.CntTotal * FParam.UpAsk[2]);
        Result := baCallAsk;
      end;
    end;
    hsDown1:
    begin
      if aQuote.Asks.CntTotal * FParam.DownBid[1] > aQuote.Bids.CntTotal then             //???? 2???? ??????
      begin
        FHedgeStatus := hsDown2;
        SetHedge(aQuote.Asks.CntTotal * FParam.DownBid[1], aQuote.Bids.CntTotal);
        Result := baPutBid;
      end else if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[0] then    //???? 1???? ??????
      begin
        FHedgeStatus := hsNone;
        SetHedge(aQuote.Asks.CntTotal, aQuote.Bids.CntTotal * FParam.DownAsk[0]);
        Result := baPutAsk;
      end;
    end;
    hsDown2:
    begin
      if aQuote.Asks.CntTotal * FParam.DownBid[2] > aQuote.Bids.CntTotal then             //???? 3???? ??????
      begin
        FHedgeStatus := hsDown3;
        SetHedge(aQuote.Asks.CntTotal * FParam.DownBid[2], aQuote.Bids.CntTotal);
        Result := baPutBid;
      end else if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[1] then    //???? 2???? ??????
      begin
        FHedgeStatus := hsDown1;
        SetHedge(aQuote.Asks.CntTotal, aQuote.Bids.CntTotal * FParam.DownAsk[1]);
        Result := baPutAsk;
      end;
    end;
    hsDown3:
    begin
      if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[2] then             //???? 3???? ??????
      begin
        FHedgeStatus := hsDown2;
        SetHedge(aQuote.Asks.CntTotal, aQuote.Bids.CntTotal * FParam.DownAsk[2]);
        Result := baPutAsk;
      end;
    end;
  end;
  FBidAskCnt[0] := aQuote.Asks.CntTotal;
  FBidAskCnt[1] := aQuote.Bids.CntTotal;
end;

function TStrangleSequels.CheckLowOrder(aItem: TStrangleSequel;
  bHedge: boolean): boolean;
begin

end;

function TStrangleSequels.CheckTimeOrder(dEndTime: TDateTime) : boolean;
begin
  Result := false;
  SetHedgeBidOrder;
  // ???? ???? ????
  if FCurrentTime <> nil then
  begin
    if Frac(GetQuoteTime) >= FCurrentTime.FTimeOrder then
    begin
      Result := true;
      FCurrentTime.FSend := true;
      FCurrentTime := FTimeOrders.NextTime;
    end;
  end;

  //????????
  if Frac(GetQuoteTime) >= dEndTime then
  begin
    ClearOrder;
    FParam.Start := false;
  end;
end;

procedure TStrangleSequels.ClearOrder;
var
  i, iSide, iQty :integer;
  aItem : TStrangleSequel;
  aOrder : TOrder;
  stLog : string;
begin
  if not FParam.Start then exit;
  
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangleSequel;
    if aItem.Position = nil then continue;


    iQty := abs(aItem.Position.Volume);  
    if iQty = 0 then continue;

    if aItem.Position.Volume > 0 then
      iSide := -1
    else
      iSide := 1;

    aOrder := DoOrder(aItem.Symbol, iSide, iQty);

    if aOrder <> nil then
    begin
      stLog := Format('%s, ????, %s, Qty = %d, Side = %d, Price = %.2f, OrderPrice = %.2f, AskCnt = %d, BidCnt = %d, Hedge = %f, Hedge = %f',
                     [GetStatusDesc, aOrder.Symbol.ShortCode, aOrder.OrderQty,
                     aOrder.Side, aOrder.Symbol.Last, aOrder.Price, FBidAskCnt[0], FBidAskCnt[1], FHedge[0], FHedge[1]]);
      gEnv.EnvLog(WIN_STR2, stLog );
    end;
  end;

end;

constructor TStrangleSequels.Create;
begin
  inherited Create(TStrangleSequel);
  FParam.Start := false;
  FHedgeStatus := hsNone;
  FParam.Start := false;
  FTradingCnt := 0;
  FTimeOrders := TTimeOrders.Create;
  SetOrderTime;
  FCurrentTime := FTimeOrders.NextTime;
  FBeHaivors := TOrerBeHaivors.Create;
end;

destructor TStrangleSequels.Destroy;
begin
  FTimeOrders.Free;
  FBeHaivors.Free;
  inherited;
end;

function TStrangleSequels.DoOrder(aSymbol: TSymbol; iSide,
  iQty: integer): TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
  aBe : TOrderBeHaivor;
  stLog : string;
begin
    // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(FTrade);

  if iQty <= 0 then
    Exit;

  //dPrice := GetPrice(aSymbol, iSide);
  dPrice := aSymbol.Last;
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FAccount, aSymbol,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opStrangle2;
    gEnv.Engine.TradeBroker.Send(aTicket);

    aBe := FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);
  end;
end;

function TStrangleSequels.Find(aSymbol: TSymbol; aType : THedgeType): TStrangleSequel;
var
  i : integer;
  aItem : TStrangleSequel;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangleSequel;
    if aItem.Symbol = aSymbol then
    begin
      Result := aItem;
      aItem.FTrading := true;
      aItem.FHedgeType := aType;
      break;
    end;
  end;

end;

function TStrangleSequels.GetBidAskTypeDesc(aType: TBidAskType): string;
begin
  Result := '';
  case aType of
    baNone: Result := '';
    baCallBid: Result := 'Call Bid';
    baCallAsk: Result := 'Call Ask';
    baPutBid: Result := 'Put Bid';
    baPutAsk: Result := 'Put Ask';
  end;
end;

function TStrangleSequels.GetCallPut(aType: TBidAskType): string;
begin
  Result := '';
  case aType of
    baPutAsk,
    baPutBid : Result := 'P';
    baCallAsk,
    baCallBid: Result := 'C';
  end;
end;

function TStrangleSequels.GetDesc(bTrue: boolean): string;
begin
  if bTrue then
    Result := 'True'
  else
    Result := 'False';
end;

function TStrangleSequels.GetHedgeType(aType : THedgeType): string;
begin
  Result := 'None';
  case aType of
    htNone: Result := 'None';
    htAll: Result := 'All';
    htLow: Result := 'Low';
    htHigh: Result := 'High';
  end;
end;

function TStrangleSequels.GetPrice(aSymbol: TSymbol; iSide: integer): double;
begin
  if iSide = 1 then
    Result := aSymbol.LimitHigh
  else
    Result := aSymbol.LimitLow;
end;

function TStrangleSequels.GetSide(aType: TBidAskType): integer;
begin
  Result := 0;
  case aType of
    baPutAsk,
    baCallAsk : Result := -1;
    baPutBid,
    baCallBid: Result := 1;
  end;
end;

function TStrangleSequels.GetStatusDesc: string;
begin
  Result := '';
  case FHedgeStatus of
    hsNone: Result := 'None';
    hsUp1: Result := '????1';
    hsUp2: Result := '????2';
    hsUp3: Result := '????3';
    hsDown1: Result := '????1';
    hsDown2: Result := '????2';
    hsDown3: Result := '????3';
  end;
end;

function TStrangleSequels.GetTimeOrder(iIndex: integer): TTimeOrder;
begin
  Result := nil;
  if (FTimeOrders.Count <= iIndex) or (iIndex < 0)  then exit;
  if FTimeOrders.Count = 0 then exit;

  Result := FTimeOrders.Items[iIndex] as TTimeOrder;
end;

procedure TStrangleSequels.InitTrading;
var
  i : integer;
  aItem : TStrangleSequel;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangleSequel;
    aItem.FTrading := false;
  end;
end;

function TStrangleSequels.SendOrder(aItem : TStrangleSequel; aType: TBidAskType;
  bHedge: boolean): boolean;
var
  i, iSide : integer;
  stCP, stLog, stTmp : string;
  aOrder : TOrder;
  aSymbol : TSymbol;
begin
  Result := true;
  if (aType = baNone) or (not FParam.Start) then exit;

  aSymbol := aItem.Symbol;
  iSide := GetSide(aType);
  stCP := GetCallPut(aType);
  if (iSide = 0) or (stCP = '') then
  begin
    gEnv.EnvLog(WIN_STR2, Format('iSide = %d, CallPut = %s, %s, %s',
      [iSide, stCP, GetStatusDesc, GetBidAskTypeDesc(aType)]));
    exit;
  end;

  if (bHedge) and (not FBidStart) then
  begin
    stLog := Format('code = %s ?????????????? ?????????? ???? ???? ',[aSymbol.ShortCode]);
    gEnv.EnvLog(WIN_STR2, stLog);
    exit;
  end;

  aOrder := DoOrder(aSymbol, iSide ,FParam.OrderQty);

  if aOrder <> nil then
  begin
    stTmp := '';
    if bHedge then
    begin
      // ???? ????
      aItem.SetCallPutHedge(FHedgeStatus, aType);
      stLog := Format('%s, %s, %s, Qty = %d, Side = %d, Price = %.2f, OrderPrice = %.2f, AskCnt = %d, BidCnt = %d, Hedge = %f, Hedge = %f'
                       +' Cal1 = %s, Cal2 = %s, Cal3 = %s, Put1 = %s, Put2 = %s, Put3 = %s',
                       [GetStatusDesc, GetBidAskTypeDesc(aType), aOrder.Symbol.ShortCode, aOrder.OrderQty,
                       aOrder.Side, aOrder.Symbol.Last, aOrder.Price, FBidAskCnt[0], FBidAskCnt[1], FHedge[0], FHedge[1],
                       GetDesc(aItem.FCallHedge[0]), GetDesc(aItem.FCallHedge[1]), GetDesc(aItem.FCallHedge[2]),
                       GetDesc(aItem.FPutHedge[0]), GetDesc(aItem.FPutHedge[1]), GetDesc(aItem.FPutHedge[2])]);
      gEnv.EnvLog(WIN_STR2, stLog );
      stTmp := 'Hedge';
    end;

    stLog := Format('%s Order Code = %s, Qty = %d, Price = %.2f', [stTmp, aOrder.Symbol.ShortCode, aOrder.OrderQty, aOrder.Price]);
    gEnv.EnvLog(WIN_STR2, stLog);
  end;

end;



procedure TStrangleSequels.SetHedge(dBid, dAsk: double);
begin
  FHedge[0] := dBid;
  FHedge[1] := dAsk;
end;

procedure TStrangleSequels.SetHedgeBidOrder;
var
  aItem : TStrangleSequel;
begin
  if FBidStart then exit;
  if Count <=0 then exit;

  aItem := Items[0] as TStrangleSequel;

  if aItem = nil then exit;
  if aItem.Position <> nil then
    FBidStart := true; 
end;

procedure TStrangleSequels.SetLowPrice;
begin

end;

procedure TStrangleSequels.SetOrderTime;
begin
  if FTimeOrders.Count = 0 then
  begin
    FTimeOrders.AddTime(9,1,0,0);
    FTimeOrders.AddTime(9,30,0,0);
    FTimeOrders.AddTime(10,10,0,0);
    FTimeOrders.AddTime(10,30,0,0);
    FTimeOrders.AddTime(11,30,0,0);
    FTimeOrders.AddTime(12,30,0,0);
  end;
  FCurrentTime := FTimeOrders.NextTime;
end;

procedure TStrangleSequels.SetPosition(aPos: TPosition);
var
  i : integer;
  aItem : TStrangleSequel;
begin
  if aPos = nil then exit;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangleSequel;
    if aItem.FSymbol = aPos.Symbol then
    begin
      aItem.Position := aPos;
      break;
    end;
  end;
end;

{ TTimeOrders }

function TTimeOrders.AddTime(wH, wM, wS, wMs: Word): TTimeOrder;
begin
  Result := Add as TTimeOrder;

  Result.FTimeOrder := EnCodeTime(wH, wM, wS, wMs);

  if Frac(GetQuoteTime) >= Result.FTimeOrder then
    Result.FSend := true
  else
    Result.FSend := false;
end;

constructor TTimeOrders.Create;
begin
  inherited Create(TTimeOrder);
end;

destructor TTimeOrders.Destroy;
begin

  inherited;
end;

function TTimeOrders.NextTime: TTimeOrder;
var
  i : integer;
  aItem : TTimeOrder;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TTimeOrder;
    if not aItem.FSend then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

{ TStrangleSequel }

function TStrangleSequel.GetIndex(aStatus: THedgeStatus; bAsk : boolean) : integer;
begin
  Result := -1;
  case aStatus of
    hsUp1: Result := 0;
    hsUp2: Result := 1;
    hsUp3: Result := 2;
    hsDown1: Result := 0;
    hsDown2: Result := 1;
    hsDown3: Result := 2;
  end;
  if bAsk then
    Result := Result + 1;    //?????? ??????????
end;

procedure TStrangleSequel.SetCallPutHedge(aStatus : THedgeStatus; aType: TBidAskType);
var
  iIndex : integer;
  bAsk : boolean;
begin
  case aType of
    baCallAsk,
    baPutAsk: bAsk := true;
    baPutBid,
    baCallBid : bAsk := false;
  end;
  iIndex := GetIndex(aStatus, bAsk);
  case aType of
    baPutAsk: FPutHedge[iIndex] := false;
    baPutBid : FPutHedge[iIndex] := true;
    baCallAsk : FCallHedge[iIndex] := false;
    baCallBid : FCallHedge[iIndex] := true;
  end;
end;

end.
