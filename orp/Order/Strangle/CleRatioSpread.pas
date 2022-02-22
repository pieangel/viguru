unit CleRatioSpread;

interface
uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleStrategyStore, CleOrderBeHaivors

  ;

type
  TGradeType = (gtDown, gtUp);
  TRatioType = (rtCall, rtPut, rtNone);
  THedgeStatus = (hsNone, hsUp2, hsDown2);
  TEntryType = (etHedge, etUser);

  TRatioSpreadTrade = class;
  TRatioSpreadParams = record
    Start : boolean;
    OrderQty : integer;
    FutTerm : double;
    SignalGrade : integer;
    LowPrice : double;
    HighPrice : double;
    Hedge : boolean;
    UpBid : double;
    DownBid : double;
    Ratio : integer;
    EntryType : TEntryType;
    UpBase : double;
    DownBase : double;
    TowSymbol : boolean;
  end;

  TFutGradeItem = class(TCollectionItem)
  private
    FPrice : double;
    FEntryOrder : boolean;
    FCurrent : boolean;
  public
    property Price : double read FPrice;
    property EntryOrder : boolean read FEntryOrder write FEntryOrder;
    property Current : boolean read FCurrent write FCurrent;
  end;

  TFutGrades = class(TCollection)
  private
    FBasePrice : double;
  public
    constructor Create;
    destructor Destroy; override;
    function New(dPrice : double) : TFutGradeItem;
    function Find(dPrice : double) : integer;
    function GetGrade(iIndex : integer) : TFutGradeItem;
    property  BasePrice : double read FBasePrice;
  end;

  TRatioSpreadItem = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FPosition : TPosition;
    FTradeing : boolean;
    FIsITM : boolean;
  public
    property Symbol : TSymbol read FSymbol;
    property Position : TPosition read FPosition write FPosition;
    property Tradeing : boolean read FTradeing;
  end;

  TRatioSpreads = class(TCollection)
  private
    FAccount : TAccount;
    FParam : TRatioSpreadParams;
    FScreenNumber : integer;
    FGrade : array[0..2] of TFutGradeItem;         //0 : 이전, 1 : 현재, 2 : 다음
    FHedge : array[0..1] of boolean;               //0 : true 상방헷지완료, 1 : true 하방 헷지 완료
    FTrade : TRatioSpreadTrade;
    FBeHaivors : TOrerBeHaivors;
    procedure InitTrading(aSymbol : TSymbol);
    procedure MakeGrade(dPrice : double ; aType : TGradeType);
    function DoOrder(aSymbol : TSymbol ; iSide, iQty : integer) : TOrder;
    function GetPrice(aSymbol : TSymbol; iSide : integer) : double;
    function GetQty(bITM : boolean; iRatio : integer) : integer;
    function GetGrade(iIndex : integer) : double;

  public
    FFutGrades : array[0..1] of TFutGrades;        // 0 : UpGrade,  1 : DownGrade
    constructor Create;
    destructor Destroy; override;
    function CheckFutPrice(aQuote : TQuote) : TRatioType;
    function CheckHedge(aQuote : TQuote) : THedgeStatus;
    procedure SetPosition(aPos : TPosition);
    procedure ClearOrder;
    procedure ApplyGrade(dTime : TDateTime; bUp, bClear : boolean);
    function HedgeOrder(hsStatus : THedgeStatus) : boolean;
    function SendOrder(iRatio : integer; aITM, aOTM : TSymbol) : boolean;
    function AddSymbol(aITM, aOTM : TSymbol) : boolean;
    function Find(aSymbol : TSymbol) : TRatioSpreadItem;
    function GetUpHedge( bUp : boolean ) : boolean;


  end;

  TRatioSpreadTrade = class(TStrategyBase)
  public
    FRatios : TRatioSpreads;
    procedure EntryOrder(bCall : boolean);
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;
    procedure SetSymbol;
    procedure ClearOrder;
    procedure SetAccount(aAcnt : TAccount);
    procedure StartStop(aParam : TRatioSpreadParams);
    procedure ApplyGrade(bUp, bClear : boolean);
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    property Ratios : TRatioSpreads read FRatios;
  end;


implementation

uses
  GAppenv, GleConsts;
{ TRatioSpreadTrade }

procedure TRatioSpreadTrade.ApplyGrade(bUp, bClear : boolean);
begin
  FRatios.ApplyGrade(StartTime, bUp, bClear);
end;

procedure TRatioSpreadTrade.ClearOrder;
begin
  FRatios.ClearOrder;
end;

constructor TRatioSpreadTrade.Create(aColl: TCollection; opType : TOrderSpecies);
begin
  inherited Create(aColl, opType, stRatio, true);
  FRatios := TRatioSpreads.Create;
  FRatios.FScreenNumber := Number;
  FRatios.FTrade := self;
end;

destructor TRatioSpreadTrade.Destroy;
begin
  FRatios.Free;
  inherited;
end;

procedure TRatioSpreadTrade.EntryOrder(bCall: boolean);
var
  aITM, aOTM : TSymbol;
  iRatio : integer;
  stLog : string;
begin
  aITM := nil;
  aOTM := nil;

  iRatio := GetRatioSymbol(bCall, FRatios.FParam.LowPrice, FRatios.FParam.HighPrice, FRatios.FParam.Ratio, aITM, aOTM);
  if (aITM = nil) or (aOTM = nil) then
  begin
    stLog := '종목 가져오기 실패 SetRatioSymbol';
    gEnv.EnvLog(WIN_RATIO, stLog );
    exit;
  end
  else
    stLog := Format('Code = %s, %s, Price = %.2f, %.2f, iRatio = %d', [aITM.ShortCode, aOTM.ShortCode, aITM.Last, aOTM.Last, iRatio]);

  gEnv.EnvLog(WIN_RATIO, stLog );
  FRatios.SendOrder(iRatio, aITM, aOTM);
end;

procedure TRatioSpreadTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  rtType : TRatioType;
  stTime, stLog : string;

  bCall, bRet : boolean;
  iRatio : integer;
  hsStatus : THedgeStatus;
begin
  if aQuote = nil then Exit;
  if aQuote.Symbol <> gEnv.Engine.SymbolCore.Futures[0] then exit;
  stTime := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime);
  if aQuote.LastEvent <> qtTimeNSale then exit;

  //헷지 주문
  hsStatus := FRatios.CheckHedge(aQuote);


  // 단계별 주문
  rtType := FRatios.CheckFutPrice(aQuote);
  if rtType <> rtNone then
  begin
    case rtType of
      rtCall: bCall := true;
      rtPut: bCall := false;
    end;

    if FRatios.FParam.TowSymbol then
       EntryOrder( bCall )
    else
    begin
       EntryOrder( true );
       EntryOrder( false );
    end;
   end;

  if hsStatus <> hsNone then
    bRet := FRatios.HedgeOrder(hsStatus);

   //청산주문
  if Frac(GetQuoteTime) >= EndTime  then
  begin
    FRatios.ClearOrder;
    FRatios.FParam.Start := false;
  end;

  if Assigned(OnResult) then   //화면갱신
    OnResult(aQuote, true);
end;

procedure TRatioSpreadTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FRatios.FAccount := aAcnt;
end;

procedure TRatioSpreadTrade.SetSymbol;
begin

end;

procedure TRatioSpreadTrade.StartStop(aParam: TRatioSpreadParams);
begin
  FRatios.FParam := aParam;
end;

procedure TRatioSpreadTrade.TradeProc(aOrder: TOrder; aPos : TPosition; iID: integer);
begin
  if aPos = nil then exit;
  
  case iID of
    ORDER_FILLED : FRatios.SetPosition(aPos);
  end;

end;

{ TRatioSpreads }

function TRatioSpreads.AddSymbol(aITM, aOTM: TSymbol): boolean;
var
  aItem : TRatioSpreadItem;
begin
  InitTrading(aITM);
  aItem := Find(aITM);
  if aItem = nil then
  begin
    aItem := Add as TRatioSpreadItem;
    aItem.FSymbol := aITM;
    aItem.FPosition := nil;
  end;
  aItem.FTradeing := true;
  aItem.FIsITM := true;


  aItem := Find(aOTM);
  if aItem = nil then
  begin
    aItem := Add as TRatioSpreadItem;
    aItem.FSymbol := aOTM;
    aItem.FPosition := nil;
    end;
  aItem.FTradeing := true;
  aItem.FIsITM := false;
end;

procedure TRatioSpreads.ApplyGrade(dTime : TDateTime; bUp, bClear : boolean);
begin
  if bClear then
  begin
    if bUp then
      FFutGrades[0].Clear
    else
      FFutGrades[1].Clear;
  end else
  begin
    if bUp then
    begin
      FFutGrades[0].Clear;
      MakeGrade( FParam.UpBase , gtUp);
    end else
    begin
      FFutGrades[1].Clear;
      MakeGrade( FParam.DownBase , gtDown);
    end;
  end;
end;

function TRatioSpreads.CheckFutPrice(aQuote: TQuote): TRatioType;
var
  dGap : double;
  dPrice : double;
  aItem : TFutGradeItem;
  i : integer;
  bFind : boolean;
begin
  Result := rtNone;
  //상승 체크
  bFind := false;
  for i := 0 to FFutGrades[0].Count - 1 do
  begin
    aItem := FFutGrades[0].Items[i] as TFutGradeItem;
    aItem.Current := false;
    if aItem.Price <= aQuote.Last then
    begin
      if not aItem.FEntryOrder then
      begin
        aItem.FEntryOrder := true;
        Result := rtCall;
      end;
    end;

    if (aItem.Price <= aQuote.Last) and ( aItem.Price + FParam.FutTerm > aQuote.Last )
        and ( not bFind ) then
    begin
      aItem.Current := true;
      bFind := true;
    end;
  end;

  //하락 체크
  bFind := false;
  for i := 0 to FFutGrades[1].Count - 1 do
  begin
    aItem := FFutGrades[1].Items[i] as TFutGradeItem;
    aItem.Current := false;
    if aItem.Price >= aQuote.Last then
    begin
      if not aItem.FEntryOrder then
      begin
        aItem.FEntryOrder := true;
        Result := rtPut;
      end;
    end;

    if (aItem.Price >= aQuote.Last) and ( aItem.Price - FParam.FutTerm < aQuote.Last )
        and ( not bFind ) then
    begin
      aItem.Current := true;
      bFind := true;
    end;
  end;
end;

function TRatioSpreads.CheckHedge(aQuote: TQuote): THedgeStatus;
var
  i : integer;
  stLog : string;
begin
  Result := hsNone;
  if not FParam.Start then exit;

  if (aQuote.Bids.CntTotal * FParam.UpBid > aQuote.Asks.CntTotal) and (not FHedge[0]) then        //상방 2단계 ITM콜매수
  begin
    FHedge[0] := true;
    Result := hsUp2;
    FHedge[0] := true;

    if FParam.EntryType = etHedge then
      MakeGrade(aQuote.Last, gtUp);
    stLog := Format('상방헷징 BidCnt = %d, Bid = %.2f > Ask = %d',
                    [aQuote.Bids.CntTotal, aQuote.Bids.CntTotal * FParam.UpBid, aQuote.Asks.CntTotal]);
    gEnv.EnvLog(WIN_RATIO, stLog);
  end
  else if (aQuote.Asks.CntTotal * FParam.DownBid > aQuote.Bids.CntTotal) and (not FHedge[1]) then //하방 2단계 ITM풋매수
  begin
    FHedge[1] := true;
    Result := hsDown2;
    FHedge[1] := true;
    if FParam.EntryType = etHedge then
      MakeGrade(aQuote.Last, gtDown);
    stLog := Format('하방헷징 AskCnt = %d, Ask = %.2f > Bid = %d',
                     [ aQuote.Asks.CntTotal, aQuote.Asks.CntTotal * FParam.DownBid, aQuote.Bids.CntTotal]);
    gEnv.EnvLog(WIN_RATIO, stLog);
  end;
end;

procedure TRatioSpreads.ClearOrder;
var
  i, iSide, iQty :integer;
  aItem : TRatioSpreadItem;
  aOrder : TOrder;
  stLog : string;
  aPos : TPosition;
  bClear : boolean;
begin
  if not FParam.Start then exit;

  bClear := false;
  for i := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
  begin
    aPos := gEnv.Engine.TradeCore.Positions.Items[i] as TPosition;

    if aPos.Volume <> 0 then
    begin
      bClear := true;
      break;
    end;
  end;

  if not bClear then exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRatioSpreadItem;

    if aItem.Position = nil then continue;
      iQty := abs(aItem.Position.Volume);
    if iQty = 0 then continue;

    if aItem.Position.Volume > 0 then
      iSide := -1
    else
      iSide := 1;

    aOrder := DoOrder(aItem.Position.Symbol, iSide, iQty);
    if aOrder = nil then
      gEnv.EnvLog(WIN_RATIO, '청산실패');
  end;

end;

constructor TRatioSpreads.Create;
begin
  inherited Create(TRatioSpreadItem);
  FParam.Start := false;
  FFutGrades[0] := TFutGrades.Create;
  FFutGrades[1] := TFutGrades.Create;
  FBeHaivors := TOrerBeHaivors.Create;
end;

destructor TRatioSpreads.Destroy;
begin
  FFutGrades[0].Free;
  FFutGrades[1].Free;
  FBeHaivors.Free;
  inherited;
end;

function TRatioSpreads.DoOrder(aSymbol: TSymbol; iSide, iQty: integer) : TOrder;
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
    Result.OrderSpecies := opRatio;
    gEnv.Engine.TradeBroker.Send(aTicket);

    aBe := FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);


    stLog := Format('Order Code = %s, Qty = %d, Price = %.2f', [Result.Symbol.ShortCode, Result.OrderQty, Result.Price]);
    gEnv.EnvLog(WIN_RATIO, stLog);
  end;
end;

function TRatioSpreads.Find(aSymbol: TSymbol): TRatioSpreadItem;
var
  i: Integer;
  aItem : TRatioSpreadItem;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRatioSpreadItem;
    if aItem.Symbol = aSymbol then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function TRatioSpreads.GetGrade(iIndex: integer): double;
begin
  Result := 0;
  if FGrade[iIndex] = nil then exit;
  Result := FGrade[iIndex].Price;
end;

function TRatioSpreads.GetPrice(aSymbol: TSymbol; iSide : integer): double;
begin
  if iSide = 1 then
    Result := aSymbol.LimitHigh
  else
    Result := aSymbol.LimitLow;
end;

function TRatioSpreads.GetQty(bITM: boolean; iRatio : integer): integer;
begin
  if bITM then
    Result := FParam.OrderQty
  else
    Result := FParam.OrderQty * iRatio;
end;

function TRatioSpreads.GetUpHedge(bUp: boolean): boolean;
begin
  if bUp then
    Result := FHedge[0]
  else
    Result := FHedge[1];    
end;

function TRatioSpreads.HedgeOrder(hsStatus : THedgeStatus) : boolean;
var
  i, iSide, iQty :integer;
  aItem : TRatioSpreadItem;
  aOrder : TOrder;
  stLog : string;
  stCP : string;
begin
  Result := false;
  if not FParam.Start then exit;
  if not FParam.Hedge then exit;

  case hsStatus of
    hsUp2: stCP := 'C';
    hsDown2: stCP := 'P';
  end;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRatioSpreadItem;

    if (aItem.FTradeing) and (aItem.FIsITM) and ((aItem.Symbol as TOption).CallPut = stCP) then  //마지막주문 ITM 인 종목 헷징
    begin
      iQty := FParam.OrderQty;
      iSide := 1;

      aOrder := DoOrder(aItem.Symbol, iSide, iQty);
      if aOrder = nil then
        gEnv.EnvLog(WIN_RATIO, '헷지실패')
      else
      begin
        stLog := Format('Hedge %s, Price = %.2f', [aItem.Symbol.ShortCode, aOrder.Price]);
        gEnv.EnvLog(WIN_RATIO, stLog);
        Result := true;
      end;
    end;
  end;
end;

procedure TRatioSpreads.InitTrading( aSymbol : TSymbol );
var
  i: Integer;
  aItem : TRatioSpreadItem;
begin

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRatioSpreadItem;
    if (aSymbol as TOption).CallPut <> (aItem.FSymbol as TOption).CallPut then continue;

    aItem.FTradeing := false;
    aItem.FIsITM := false;
  end;
end;

procedure TRatioSpreads.MakeGrade(dPrice: double; aType: TGradeType);
var
  i : integer;
begin
  case aType of
    gtDown:
    begin
      FFutGrades[1].FBasePrice := dPrice;
      for i := 0 to FParam.SignalGrade - 1 do
        FFutGrades[1].New(dPrice - (FParam.FutTerm * i));
    end;
    gtUp:
    begin
      FFutGrades[0].FBasePrice := dPrice;
      for i := 0 to FParam.SignalGrade - 1 do
        FFutGrades[0].New(dPrice + (FParam.FutTerm * i));
    end;
  end;
end;

function TRatioSpreads.SendOrder(iRatio : integer; aITM, aOTM : TSymbol) : boolean;
var
  i, iSide, iQty : integer;
  aItem : TFutGradeItem;
  stLog, stSend : string;
begin
  if not FParam.Start then exit;
  AddSymbol(aITM, aOTM);

  //내가 주문
  iSide := 1;
  iQty := GetQty(true, iRatio);
  DoOrder(aITM, iSide, iQty);

  //외가 주문
  iSide := -1;
  iQty := GetQty(false, iRatio);
  DoOrder(aOTM, iSide, iQty);
end;

procedure TRatioSpreads.SetPosition(aPos: TPosition);
var
  i : integer;
  aItem : TRatioSpreadItem;
begin
  if aPos = nil then exit;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRatioSpreadItem;
    if aItem.FSymbol = aPos.Symbol then
    begin
      aItem.Position := aPos;
      break;
    end;
  end;
end;

{ TFutGrades }

function TFutGrades.New(dPrice: double): TFutGradeItem;
begin
  Result := Add as TFutGradeItem;
  Result.FPrice := dPrice;
  Result.FEntryOrder := false;
  Result.FCurrent := false;
end;

constructor TFutGrades.Create;
begin
  inherited Create(TFutGradeItem);
end;

destructor TFutGrades.Destroy;
begin

  inherited;
end;

function TFutGrades.Find(dPrice: double): integer;
var
  i : integer;
  aItem : TFutGradeItem;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TFutGradeItem;
    if dPrice <= aItem.FPrice then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TFutGrades.GetGrade(iIndex: integer): TFutGradeItem;
begin
  Result := nil;
  if (iIndex < 0) or (iIndex > Count - 1) then exit;

  Result := Items[iIndex] as TFutGradeItem;

end;

{ TFutGradeItem }



{ TRatioSpreadItem }

end.
