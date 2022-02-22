unit CleInvestorTrade;

interface

uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes, Math,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleStrategyStore,
  CleInvestorData, CleOrderBeHaivors, cleKrxSymbols
  ;

type


  TInvestorTrade = class;
  TOrderType = (otBid, otAsk);
  TEntryType = (etNone, etCallAsk, etPutAsk , etCallBid, etPutBid );


  TInvestorParams = record
    Start : boolean;
    OrderQty : integer;
    OrderType : TOrderType;
    Gap : double;
    Grade : integer;
    LowPrice : double;
    HighPrice : double;
    ReSet : boolean;
    EntryCnt : integer;
  end;

  // 진입 간격 표시 Gap억부터 시작해서 Grade단계까지..
  // ( TInvestorParams 의 Gap과 Grade )
  TAmountGradeItem = class(TCollectionItem)
  private
    FGrade : double;
    FEntry : boolean;
    FSymbolList : TList;
    FCurrent : boolean;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;
    procedure ClearSymbol;
    property Grade : double read FGrade;
    property Entry : boolean read FEntry;
    property Current : boolean read FCurrent;
  end;

  TAmountGrades = class(TCollection)
  private
  public
    constructor Create;
    destructor Destroy; override;
  end;


  TInvestorItem = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FPosition : TPosition;
    FTradeing : boolean;
  public
    property Symbol : TSymbol read FSymbol;
    property Position : TPosition read FPosition write FPosition;
    property Tradeing : boolean read FTradeing;
  end;

  TInvestors = class(TCollection)
  private
    FScreenNumber : integer;
    FParam : TInvestorParams;
    FAccount : TAccount;
    FTrade : TInvestorTrade;
    FBeHaivors : TOrerBeHaivors;
    FEntryType : TEntryType;
    FUpEntry : integer;
    FDownEntry : integer;
    function Find(aSymbol : TSymbol) : TInvestorItem;
    procedure AddSymbol(aSymbol : TSymbol);
    function GetPrice(aSymbol: TSymbol; iSide: integer): double;
    function GetDesc(aType : TEntryType) : string;
    procedure SetPosition(aPos: TPosition);
    procedure ReSetOrder(aType : TEntryType; dSum, dPrevSum : double);

  public
    constructor Create;
    destructor Destroy; override;
    procedure DoStrangle(aTrade : TInvestorTrade; aItem : TAmountGradeItem; aType : TEntryType; dSum, dPrevSum : double);
    procedure DoBid( aTrade : TInvestorTrade; aItem : TAmountGradeItem; aType : TEntryType);
    procedure ClearOrder(bTime : boolean = true);
    function DoOrder(aSymbol: TSymbol; iSide, iQty: integer): TOrder;
    property Param : TInvestorParams read FParam write FParam;
    property Account : TAccount read FAccount write FAccount;
    property EntryType : TEntryType read FEntryType;
    property UpEntry : integer read FUpEntry write FUpEntry;
    property DownEntry : integer read FDownEntry write FDownEntry;

  end;


  TInvestorTrade = class(TStrategyBase)
  private
    FInvestors : TInvestors;
    FCallPerson : TInvestorData;
    FPutPerson : TInvestorData;
    FCallFinance : TInvestorData;
    FPutFinance : TInvestorData;

    FPrevSum : double;
    FAmountGrades : TAmountGrades;
    FMaxPL : double;
    FMinPL : double;
    FStartTime : TDateTime;
    procedure SendOrder( dSum, dPrevSum: double);
    procedure DoZeroClear(dTot : double);
    function CheckData : boolean;
    procedure DoLog;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;
    procedure SetSymbol;
    procedure ClearOrder;
    procedure SetAccount(aAcnt : TAccount);
    procedure StartStop(aParam : TInvestorParams);
    procedure InitAmountGrade;
    function AddAmountGrades( dGap : double ) : TAmountGradeItem;

    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    property Investors : TInvestors read FInvestors;
    property CallPerson : TInvestorData read FCallPerson;
    property PutPerson : TInvestorData read FPutPerson;
    property CallFinance : TInvestorData read FCallFinance;
    property PutFinance : TInvestorData read FPutFinance;

    property AmountGrades : TAmountGrades read FAmountGrades;
  end;
implementation

uses
  GAppEnv, GleConsts, GleLib;
{ TInvestorTrade }

function TInvestorTrade.AddAmountGrades(dGap: double) : TAmountGradeItem;
var
  stLog : string;
begin
  if dGap < 0 then
    Result := FAmountGrades.Insert(0) as TAmountGradeItem
  else
    Result := FAmountGrades.Add as TAmountGradeItem;
  Result.FGrade := dGap;
  stLog := Format('단계 = %.0f',[dGap]);
  gEnv.EnvLog(WIN_INV, stLog);
end;

function TInvestorTrade.CheckData : boolean;
var
  dSum, dSum1, dTot : double;
  stLog : string;
begin
  Result := false;
  dSum := FPutPerson.SumAmount - FCallPerson.SumAmount;
  dSum1 := FCallFinance.SumAmount - FPutFinance.SumAmount;
  dTot := dSum + dSum1;


  if FInvestors.FParam.Start then
  begin
    if FInvestors.Param.ReSet  then
      DoZeroClear(dTot);

    SendOrder(dTot, FPrevSum);
  end;
  {
  stLog := Format('CheckData Prev = %f,  dSum = %f', [FPrevSum, dTot]);
  gEnv.EnvLog(WIN_INV, stLog); }
  FPrevSum := dTot;
  Result := true;
end;

procedure TInvestorTrade.ClearOrder;
begin
  FInvestors.ClearOrder;
end;

constructor TInvestorTrade.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stInvestor, true);
  FInvestors := TInvestors.Create();
  FInvestors.FScreenNumber := Number;
  FInvestors.FTrade := self;
  FCallPerson := nil;
  FPutPerson := nil;
  FAmountGrades := TAmountGrades.Create;
  FStartTime := EncodeTime(9,0,40,0);
end;

destructor TInvestorTrade.Destroy;
begin
  FInvestors.Free;
  FAmountGrades.Free;
  inherited;
end;

procedure TInvestorTrade.DoLog;
var
  stLog, stFile : string;
begin
  stLog := Format('%s, %.0f, %.0f, %.0f',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime),  TotPL/1000, FMaxPL/1000, FMinPL/1000] );

  stFile := Format('Investor_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_INV, stLog, true, stFile);
end;

procedure TInvestorTrade.DoZeroClear(dTot: double);
var
  stLog : string;
begin
  if FInvestors.EntryType = etPutAsk  then      // Sum + 이면 etPutAsk,  Sum - 이면 etCallAsk
  begin
    if dTot <= 0 then
    begin
      stLog := Format('DoZeroClear 청산 PrevSum = %f, dSum = %f', [FPrevSum, dTot]);
      gEnv.EnvLog(WIN_INV, stLog);
      FInvestors.ClearOrder(false);
      InitAmountGrade;
    end;
  end else if FInvestors.EntryType = etCallAsk then
  begin
    if dTot >= 0 then
    begin
      stLog := Format('DoZeroClear 청산 PrevSum = %f, dSum = %f', [FPrevSum, dTot]);
      gEnv.EnvLog(WIN_INV, stLog);
      FInvestors.ClearOrder(false);
      InitAmountGrade;
    end;
  end;
end;

procedure TInvestorTrade.InitAmountGrade;
var
  i : integer;
  aItem : TAmountGradeItem;
begin
  FPrevSum := 0;
  for i := 0 to FAmountGrades.Count - 1 do
  begin
    aItem := FAmountGrades.Items[i] as TAmountGradeItem;
    aItem.ClearSymbol;
  end;
end;

procedure TInvestorTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  bRet : boolean;
  stTime : string;
begin
  if iDataID = 300 then
  begin
    DoLog;
    exit;
  end;
  FMinPL := Min( FMinPL, TotPL );
  FMaxPL := Max( FMaxPL, TotPL );

  bRet := false;
  if aQuote = nil then Exit;
  if aQuote.Symbol <> gEnv.Engine.SymbolCore.Futures[0] then exit;
  if aQuote.LastEvent <> qtTimeNSale then exit;

  if Frac(FStartTime) > Frac(GetQuoteTime) then exit;

  if FCallPerson = nil then
    FCallPerson := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_PERSON, 'C');
  if FPutPerson = nil then
    FPutPerson := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_PERSON, 'P');

 if FCallFinance = nil then
    FCallFinance := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_FINANCE, 'C');
  if FPutFinance = nil then
    FPutFinance := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_FINANCE, 'P');

  if (FCallPerson <> nil) and (FPutPerson <> nil) and (FCallFinance <> nil) and (FPutFinance <> nil) then
  begin
    stTime := FormatdateTime('hh:nn:ss.zzz', GetQuoteTime);
    bRet := CheckData;
  end;

  //청산주문
  if Frac(GetQuoteTime) >= EndTime  then
  begin
    if FInvestors.FParam.Start then
      FInvestors.ClearOrder;
  end;

  if Assigned(OnResult) then   //화면갱신
    OnResult(aQuote, bRet);
end;

procedure TInvestorTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FInvestors.Account := aAcnt;
end;

procedure TInvestorTrade.SendOrder(dSum, dPrevSum: double);
var
  i, iIndex : integer;
  aItem : TAmountGradeItem;
  bFind : boolean;
  dPrev : double;
begin
  bFind := false;
  case FInvestors.Param.OrderType of
    otBid:
    begin
      for i := 0 to FAmountGrades.Count - 1 do
      begin
        aItem := FAmountGrades.Items[i] as TAmountGradeItem;
        aItem.FCurrent := false;
        if aItem.FGrade = 0 then continue;
        if dSum > 0 then
        begin
          if aItem.FGrade < 0 then continue;
          if (aItem.FGrade <= dSum) and (not aItem.Entry) then     //
            FInvestors.DoStrangle(self, aItem, etPutBid, dSum, dPrevSum);

          if (dSum >= FInvestors.Param.Gap) and (aItem.FGrade + FInvestors.Param.Gap > dSum) and (not bFind) then
          begin
            aItem.FCurrent := true;
            bFind := true;
          end;

        end else
        begin
          if aItem.FGrade > 0 then continue;
          if (aItem.FGrade >= dSum) and (not aItem.Entry) then     //
            FInvestors.DoStrangle(self, aItem, etCallBid, dSum, dPrevSum);

          if (dSum <= FInvestors.Param.Gap * -1) and (aItem.FGrade >= dSum) and (not bFind) then
          begin
            aItem.FCurrent := true;
            bFind := true;
          end;
        end;
      end;
    end;
    otAsk:
    begin
      for i := 0 to FAmountGrades.Count - 1 do
      begin
        aItem := FAmountGrades.Items[i] as TAmountGradeItem;
        aItem.FCurrent := false;
        if aItem.FGrade = 0 then continue;
        if dSum > 0 then
        begin
          if aItem.FGrade < 0 then continue;
          if (aItem.FGrade <= dSum) and (not aItem.Entry) then     //
            FInvestors.DoStrangle(self, aItem, etPutAsk, dSum, dPrevSum);

          if (dSum >= FInvestors.Param.Gap) and (aItem.FGrade + FInvestors.Param.Gap > dSum) and (not bFind) then
          begin
            aItem.FCurrent := true;
            bFind := true;
          end;

        end else
        begin
          if aItem.FGrade > 0 then continue;
          if (aItem.FGrade >= dSum) and (not aItem.Entry) then     //
            FInvestors.DoStrangle(self, aItem, etCallAsk, dSum, dPrevSum);

          if (dSum <= FInvestors.Param.Gap * -1) and (aItem.FGrade >= dSum) and (not bFind) then
          begin
            aItem.FCurrent := true;
            bFind := true;
          end;
        end;

      end;

    end;
  end;
end;

procedure TInvestorTrade.SetSymbol;
begin

end;

procedure TInvestorTrade.StartStop(aParam: TInvestorParams);
begin
  FInvestors.FParam := aParam;
end;

procedure TInvestorTrade.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
begin
  if aPos = nil then exit;

  case iID of
    ORDER_FILLED : FInvestors.SetPosition(aPos);
  end;
end;

{ TInvestors }

procedure TInvestors.AddSymbol(aSymbol: TSymbol);
var
  aItem : TInvestorItem;
begin
  aItem := Find(aSymbol);

  if aItem = nil then
  begin
    aItem := Add as TInvestorItem;
    aItem.FSymbol := aSymbol;
    aItem.Position := nil;
    aItem.FTradeing := false;
  end;
end;

procedure TInvestors.SetPosition(aPos: TPosition);
var
  i : integer;
  aItem : TInvestorItem;
begin
  if aPos = nil then exit;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TInvestorItem;
    if aItem.FSymbol = aPos.Symbol then
    begin
      aItem.Position := aPos;
      break;
    end;
  end;
end;

procedure TInvestors.ClearOrder(bTime : boolean);
var
  i, iSide, iQty :integer;
  aItem : TInvestorItem;
  aOrder : TOrder;
  stLog : string;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TInvestorItem;
    if aItem.Position = nil then continue;
    iQty := abs(aItem.Position.Volume);
    if iQty = 0 then continue;
    if aItem.Position.Volume > 0 then
      iSide := -1
    else
      iSide := 1;
    aOrder := DoOrder(aItem.Position.Symbol, iSide, iQty);
    stLog := Format('[ClearOrder] %s, Qty = %d, Side = %d',[aOrder.Symbol.ShortCode, aOrder.OrderQty, aOrder.Side]);
    gEnv.EnvLog(WIN_INV, stLog);
    if aOrder = nil then
      gEnv.EnvLog(WIN_INV, '청산실패');
  end;

  if bTime then
    FParam.Start := false
  else
  begin
    if FEntryType = etPutAsk then
      inc(FUpEntry)
    else if FEntryType = etCallAsk then
      inc(FDownEntry);

    FEntryType := etNone;
  end;

end;

constructor TInvestors.Create;
begin
  inherited Create(TInvestorItem);
  FParam.Start := false;
  FEntryType := etNone;
  FBeHaivors := TOrerBeHaivors.Create;
  FDownEntry := 0;
  FUpEntry := 0;
end;

destructor TInvestors.Destroy;
begin
  FBeHaivors.Free;
  inherited;
end;

function TInvestors.DoOrder(aSymbol: TSymbol; iSide, iQty: integer): TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
  stLog : string;
  aBe : TOrderBeHaivor;
begin
    // issue an order ticket
  aTicket :=  gEnv.Engine.TradeCore.StrategyGate.GetTicket(FTrade);
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
    Result.OrderSpecies := opInvestor;
    gEnv.Engine.TradeBroker.Send(aTicket);
    aBe := FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);
    stLog := Format('[Order] Code = %s, Qty = %d, Price = %.2f', [Result.Symbol.ShortCode, Result.OrderQty, Result.Price]);
    gEnv.EnvLog(WIN_INV, stLog);
  end;
end;

procedure TInvestors.DoStrangle(aTrade : TInvestorTrade; aItem : TAmountGradeItem; aType : TEntryType; dSum, dPrevSum : double);
var
  iSide : integer;
  aITM, aOTM : TSymbol;
  bRet : boolean;
  aOrder : TOrder;
  stLog : string;
begin
  aITM := nil;
  aOTM := nil;
  case aType of
    etCallBid :
    begin
      //Put ITM, Call OTM
      iSide := 1;
      aTrade.GetInvestSymbol(false, FParam.LowPrice, FParam.HighPrice, aITM, aOTM );
    end;
    etPutBid :
    begin
      //Call ITM, Put OTM
      iSide := 1;
      aTrade.GetInvestSymbol(true, FParam.LowPrice, FParam.HighPrice, aITM, aOTM );
    end;
    etCallAsk :
    begin
      //Call ITM, Put OTM
      //ReSetOrder(aType, dSum, dPrevSum);
      if FDownEntry >= Param.EntryCnt then exit;
      FEntryType := aType;
      iSide := -1;
      aTrade.GetInvestSymbol(true, FParam.LowPrice, FParam.HighPrice, aITM, aOTM );
    end;
    etPutAsk:
    begin
      //Put ITM, Call OTM
      //ReSetOrder(aType, dSum, dPrevSum);
      if FUpEntry >= Param.EntryCnt then exit;
      FEntryType := aType;
      iSide := -1;
      aTrade.GetInvestSymbol(false, FParam.LowPrice, FParam.HighPrice, aITM, aOTM );
    end;

  end;
  if (aITM = nil) or (aOTM = nil) then exit;

  AddSymbol(aITM);
  AddSymbol(aOTM);

  aOrder := DoOrder(aITM, iSide, FParam.OrderQty);

  if aOrder <> nil then
  begin
    aItem.FSymbolList.Add(aITM);
    aItem.FEntry := true;
    stLog := Format('DoStrangle Code = %s, Desc = %s, iSide = %d, Count = %d, aItemGrade = %.2f, %.0f, Price = %.2f',
      [aITM.ShortCode, GetDesc(aType), iSide, aItem.FSymbolList.Count, aItem.FGrade, dSum, aITM.Last]);
    gEnv.EnvLog(WIN_INV, stLog);
  end;

  aOrder := DoOrder(aOTM, iSide, FParam.OrderQty);
  if aOrder <> nil then
  begin
    aItem.FSymbolList.Add(aOTM);
    aItem.FEntry := true;
    stLog := Format('DoStrangle Code = %s, Desc = %s, iSide = %d, Count = %d, aItemGrade = %.2f, Price = %.2f',
      [aOTM.ShortCode, GetDesc(aType), iSide, aItem.FSymbolList.Count, aItem.FGrade, aOTM.Last]);

    gEnv.EnvLog(WIN_INV, stLog);
  end;
end;

function TInvestors.Find(aSymbol: TSymbol): TInvestorItem;
var
  i : integer;
  aItem : TInvestorItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TInvestorItem;
    if aItem.Symbol = aSymbol then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

procedure TInvestors.DoBid(aTrade : TInvestorTrade; aItem : TAmountGradeItem; aType : TEntryType);
var
  iSide : integer;
  aSymbol : TSymbol;
  bRet : boolean;
  aOrder : TOrder;
  stLog : string;
begin
  aSymbol := nil;
  case aType of
    etCallAsk,
    etPutAsk:
    begin
      if aItem.FSymbolList.Count = 1 then
        aSymbol := aItem.FSymbolList.Items[0];
      iSide := -1;
    end;
    etCallBid :
    begin
      bRet := aTrade.GetHighSymbol( true , FParam.LowPrice, FParam.HighPrice, aSymbol);
      iSide := 1;
    end;
    etPutBid:
    begin
      bRet := aTrade.GetHighSymbol( false , FParam.LowPrice, FParam.HighPrice, aSymbol);
      iSide := 1;
    end;
  end;

  if aSymbol = nil then exit;

  AddSymbol(aSymbol);
  aOrder := DoOrder(aSymbol, iSide, FParam.OrderQty);

  if aOrder <> nil then
  begin
    if iSide = 1 then
    begin
      aItem.FSymbolList.Add(aSymbol);
      aItem.FEntry := true;
    end else
    begin
      aItem.FSymbolList.Clear;
      aItem.FEntry := false;
    end;

    stLog := Format('DoBid Code = %s, Desc = %s, iSide = %d, Count = %d, aItemGrade = %.2f, Price = %.2f',
      [aSymbol.ShortCode, GetDesc(aType), iSide, aItem.FSymbolList.Count, aItem.FGrade, aSymbol.Last]);

    gEnv.EnvLog(WIN_INV, stLog);
  end;
end;

function TInvestors.GetDesc(aType: TEntryType): string;
begin
  case aType of
    etNone: Result := 'None';
    etCallAsk: Result := 'Call 매도';
    etPutAsk: Result := 'Put 매도';
    etCallBid: Result := 'Call 매수';
    etPutBid: Result := 'Put 매수';
  end;
end;

function TInvestors.GetPrice(aSymbol: TSymbol; iSide: integer): double;
begin
  if iSide = 1 then
    Result := TicksFromPrice( aSymbol, aSymbol.LAst, 20 )
  else
    Result := TicksFromPrice( aSymbol, aSymbol.LAst, -20 );
end;

procedure TInvestors.ReSetOrder(aType: TEntryType; dSum, dPrevSum : double);
var
  stLog : string;
begin
  if FEntryType = etNone then exit;
  if not Param.ReSet then exit;

  if (FEntryType <> aType) then
  begin
    //현재 잔고  다 청산........
    stLog := Format('ReSet 청산 PrevSum = %f, dSum = %f', [dPrevSum, dSum]);
    gEnv.EnvLog(WIN_INV, stLog);
    ClearOrder(false);
    FTrade.InitAmountGrade;
  end;
end;

{ TAmountGrades }

constructor TAmountGrades.Create;
begin
  inherited Create(TAmountGradeItem);
end;

destructor TAmountGrades.Destroy;
begin

  inherited;
end;

{ TAmountGradeItem }

procedure TAmountGradeItem.ClearSymbol;
begin
  FSymbolList.Clear;
  FEntry := false;
end;

constructor TAmountGradeItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FSymbolList := TList.Create;
  FEntry := false;
end;

destructor TAmountGradeItem.Destroy;
begin
  FSymbolList.Free;
  inherited;
end;

end.
