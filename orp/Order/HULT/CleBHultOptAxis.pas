unit CleBHultOptAxis;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFrontOrder,
  UObjectBase, UPaveConfig, UPriceItem,  CleQuoteTimers,
  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleCircularQueue,
  GleTypes, GleConsts, CleStrategyStore, CleVirtualHult;

type
  TAddEntry = class(TCollectionItem)
  public
    AddPrice : double;
    SendOrder : boolean;
    Index : integer;
  end;

  TAddEntrys = class(TCollection)
  public
    constructor Create;
    destructor Destroy; override;
    function New(dPrice : double; iIndex : integer) : TAddEntry;
    function Find( dPrice : double ) : TAddEntry;
    function GetEntryItem(iIndex: integer) : TAddEntry;
    function GetHighItem(dPrice : double) : TAddEntry;
  end;

  TBHultOptAxis = class(TStrategyBase)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FOrderSymbol : TSymbol;
    FHighSymbol : TSymbol;
    FBHultData: TBHultOptData;
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

    FSuccess : boolean;
    FScreenNumber : integer;
    FRun : boolean;
    FAddEntrys : TAddEntrys;
    FHighAddEntrys : TAddEntrys;

    FHighAddEntryItem : TAddEntry;
    FAddEntryItem : TAddEntry;
    FHighPL : double;

    FFirstQty : integer;
    FHalfEntry : boolean;

    FVirtualHult : TVirtualHult;
    procedure OnLcTimer( Sender : TObject );
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    function DoOrder( aSymbol : TSymbol; iQty, iSide : integer;
      bHit  : boolean = false; bClear : boolean = false) : TOrder; overload;

    procedure Reset;

    procedure DoInit(aQuote : TQuote);
    function IsRun : boolean;
    procedure UpdateQuote(aQuote: TQuote);

    procedure DoAddEntry;
    procedure MakeAddEntry;
    procedure SetNextAddEntry;
    procedure DoHighAddEntry;


    procedure DoHalfEntry;
    procedure DoHalfCallPutBuy;
    procedure DoAllEntryHalfCallPutBuy;



    procedure DoLog;
    function BHULTLossCut( iSide: integer): integer;
  public

    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol); 
    function Start : boolean;
    Procedure Stop(bAuto : boolean = true);

    property BHultData: TBHultOptData read FBHultData write FBHultData;
    property LossCutCnt : integer read FLossCutCnt write FLossCutCnt;
    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property OrderSymbol : TSymbol read FOrderSymbol;
    property VirtualHult : TVirtualHult read FVirtualHult;
    property Run : boolean read FRun;
  end;
implementation

uses
  GAppEnv, GleLib;

{ TBHultAxis }



constructor TBHultOptAxis.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stBHultOpt, true);
  FScreenNumber := Number;
  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 1000;
  FLcTimer.OnTimer := OnLcTimer;
  FAddEntrys := TAddEntrys.Create;
  FHighAddEntrys := TAddEntrys.Create;
  Reset;
end;

destructor TBHultOptAxis.Destroy;
begin
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);

  FAddEntrys.Free;
  FHighAddEntrys.Free;
  inherited;
end;

procedure TBHultOptAxis.DoAddEntry;
var
  iSide : integer;
  stLog : string;
begin
  if (FAddEntryItem = nil) or (FVirtualHult = nil) then exit;
  if ( FVirtualHult.HultPrices.PL <= FAddEntryItem.AddPrice) and (not FAddEntryItem.SendOrder)  then
  begin
    iSide := 1;
    DoOrder(FOrderSymbol, FBHultData.OrdQty , iSide, true);
    stLog := Format('AddEntry %.0f <= %.0f', [FVirtualHult.HultPrices.PL, FAddEntryItem.AddPrice ]);
    gEnv.EnvLog(WIN_BHULT, stLog);

    SetNextAddEntry;

    if FAddEntryItem <> nil then
    begin
      stLog := Format('NextAddEntry %.0f', [ FAddEntryItem.AddPrice ]);
      gEnv.EnvLog(WIN_BHULT, stLog);
    end;
  end;
end;

procedure TBHultOptAxis.DoAllEntryHalfCallPutBuy;
var
  aSymbol : TSymbol;
begin
  //-800일때 매수  FFirstQty
  if  not FHalfEntry then exit;
  if FVirtualHult = nil then exit;
  if ( FVirtualHult.HultPrices.PL <= -8000000) then
  begin
    aSymbol := nil;
    DoOrder(FOrderSymbol, FFirstQty , 1, true);

    if (FOrderSymbol as TOption).CallPut = 'C' then
      GetHighSymbol(false, 0.1, FBHultData.OptPrice, aSymbol)
    else
      GetHighSymbol(true, 0.1, FBHultData.OptPrice, aSymbol);

    if aSymbol <> nil then
      DoOrder(aSymbol, FFirstQty , 1, true);
    FHalfEntry := false;
  end;

end;

procedure TBHultOptAxis.DoHalfCallPutBuy;
var
  aSymbol : TSymbol;
begin
  //-800일때 매수  FFirstQty
  if  not FHalfEntry then exit;
  if FVirtualHult = nil then exit;
  if ( FVirtualHult.HultPrices.PL <= -8000000) then
  begin
    aSymbol := nil;
    DoOrder(FOrderSymbol, FFirstQty , 1, true);

    if (FOrderSymbol as TOption).CallPut = 'C' then
      GetHighSymbol(false, 0.1, FBHultData.OptPrice, aSymbol)
    else
      GetHighSymbol(true, 0.1, FBHultData.OptPrice, aSymbol);

    if aSymbol <> nil then
      DoOrder(aSymbol, FFirstQty , 1, true);
    FHalfEntry := false;
  end;


end;

procedure TBHultOptAxis.DoHalfEntry;
begin
  //-800일때 매수  FFirstQty
  if  not FHalfEntry then exit;
  if FVirtualHult = nil then exit;

  if ( FVirtualHult.HultPrices.PL <= -8000000) then
  begin
    DoOrder(FOrderSymbol, FFirstQty , 1, true);
    FHalfEntry := false;
  end;
end;

procedure TBHultOptAxis.DoHighAddEntry;
var
  aItem : TAddEntry;
  stLog : string;
begin
  if FVirtualHult = nil then exit;
  if FVirtualHult.HultPrices.PL >= 0 then exit;

  if FHighPL = 0 then                                           // 최고점 잡기위해서
  begin
    aItem := FHighAddEntrys.GetEntryItem(1);

    if aItem = nil then exit;
    if aItem.AddPrice >= FVirtualHult.HultPrices.PL then
    begin
      FHighPL := FVirtualHult.HultPrices.PL;
      FHighAddEntryItem := FHighAddEntrys.GetEntryItem(0);
    end;
  end else
  begin
    FHighPL := Min(FHighPL, FVirtualHult.HultPrices.PL);
    FHighAddEntryItem := FHighAddEntrys.GetHighItem(FHighPL);  // 현재 주문나갈 Item 가져오기
    if FHighAddEntryItem = nil then exit;

    if FHighAddEntryItem.AddPrice <= FVirtualHult.HultPrices.PL then
    begin
      if FHighSymbol = nil then
      begin
        if (FOrderSymbol as TOption).CallPut = 'P' then
          GetHighSymbol(true, 0.1, FBHultData.OptPrice, FHighSymbol)
        else
          GetHighSymbol(false, 0.1, FBHultData.OptPrice, FHighSymbol);
      end;

      if FHighSymbol = nil then exit;


      DoOrder(FHighSymbol, FBHultData.OrdQty, 1, true);
      FHighAddEntryItem.SendOrder := true;
      stLog := Format( 'DoHighAddEntry %s(%.2f), %.0f <= %.0f, %.0f',[FHighSymbol.ShortCode, FHighSymbol.Last,
                    FHighAddEntryItem.AddPrice, FVirtualHult.HultPrices.PL, FHighPL]);
      gEnv.EnvLog(WIN_BHULT, stLog);
    end;
  end;
end;

procedure TBHultOptAxis.DoInit(aQuote: TQuote);
var
  i, iIndex, idx: integer;
  aPrice, aBase : TPriceItem2;
  stTime, stLog : string;
  iSide, iQty : integer;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;

  if aQuote.FTicks.Count <= 0  then exit;
  if FVirtualHult = nil then exit;

  if Frac(FBHultData.StartTime) > Frac(GetQuoteTime) then exit;

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
          iSide := 1;
        end else
          FHLTSignal := false;
      end else
      begin
        if aQuote.Symbol.DayOpen - FBHultData.Band >= aQuote.Symbol.Last then
        begin
          FHLTSignal := true;
          stLog := Format('DoInit O - B = %.1f >= %.1f', [aQuote.Symbol.DayOpen - FBHultData.Band, aQuote.Symbol.Last]);
          gEnv.EnvLog(WIN_BHULT, stLog);
          iSide := -1;
        end else
          FHLTSignal := false;
      end;
    end;
  end;
  if not FHLTSignal then exit;
  //////////////////////////////////////
  if FVirtualHult.HultPrices.PL > FBHultData.HultPL * -10000  then
  begin
    //stLog := Format('DoInit %.0f > %0.f', [FHultPosition.LastPL - FHultPosition.GetFee, FBHultData.HultPL * -10000]);
    //gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end else
  begin
    iQty := abs(FVirtualHult.HultPrices.Volume Div FBHultData.QtyDiv);
    if iQty <= 0 then exit;
    if aQuote.Symbol.DayOpen + FBHultData.Band <= aQuote.Symbol.Last then
      iSide := 1
    else
      iSide := -1;

    FOrderSymbol := nil;
    if iSide > 0 then
      GetHighSymbol(true, 0.1, FBHultData.OptPrice, FOrderSymbol)
    else
      GetHighSymbol(false, 0.1, FBHultData.OptPrice, FOrderSymbol);


    if FOrderSymbol = nil then
    begin
      stLog := Format('FOrderSymbol = nil %.2f' , [FBHultData.OptPrice]);
      gEnv.EnvLog(WIN_BHULT, stLog);
      exit;
    end;


    iSide := 1;
    iQty := iQty * FBHultData.OrdQty;
    if FBHultData.QtyDiv =  1 then
      FFirstQty := iQty Div 2;
    //주문발주....
    DoOrder(FOrderSymbol, iQty , iSide, true);
    FReady := true;

    stLog := Format('DoInit Start %s(%.2f), Qty = %d, %.0f <= %0.f', [FOrderSymbol.ShortCode, FOrderSymbol.Last, iQty,
                                FVirtualHult.HultPrices.PL, FBHultData.HultPL * -10000]);
    gEnv.EnvLog(WIN_BHULT, stLog);
  end;
end;



procedure TBHultOptAxis.DoLog;
var
  stLog, stFile : string;
  iQty : integer;
begin
  if Position = nil then
    iQty := 0
  else
    iQty := Position.MaxPos;

  stLog := Format('%s, %d, %.0f, %.0f, %.0f, %d',
                  [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap,
                    (TotPL)/1000, FMaxPL/1000, FMinPL/1000, iQty] );

  stFile := Format('BanHultOpt_%s.csv', [Account.Code]);

  gEnv.EnvLog(WIN_BHULT, stLog, true, stFile);
end;

function TBHultOptAxis.DoOrder(aSymbol : TSymbol; iQty, iSide: integer; bHit,
  bClear: boolean): TOrder;
var
  aTicket : TOrderTicket;
  dPrice : double;
  aQuote : TQuote;
  idx : integer;

  iMax, i : integer;
  iCnt : integer;
  aOrder : TOrder;
  tgType : TPositionType;
begin
  if aSymbol = nil then exit;
  if iQty <= 0 then  Exit;

  if bHit then
  begin
    aQuote  := aSymbol.Quote as TQuote;
    if iSide > 0 then
      dPrice  := TicksFromPrice( aSymbol, aQuote.Asks[0].Price, 10 )
    else
      dPrice  := TicksFromPrice( aSymbol, aQuote.Bids[0].Price, -10 );
  end
  else dPrice := aQuote.Last;

  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  Result := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, aSymbol,
    iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if Result <> nil then
  begin
    Result.OrderSpecies := opBhultOpt;
    gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.EnvLog(WIN_BHULT, Format('주문 : %s', [ Result.Represent2 ]) ) ;
  end;
end;

function TBHultOptAxis.BHULTLossCut(iSide: integer): integer;
var
  stLog : string;
  aTicket : TOrderTicket;
  aOrder : TOrder;
  aPrice : TPriceItem2;
  dPrice : double;
  iQty, i : integer;
  aPos : TPosition;
begin
  Result := 0;

  aPos := gEnv.Engine.TradeCore.Positions.Find(FAccount, FOrderSymbol);
  if aPos <> nil then
  begin
    if aPos.Volume > 0 then
    begin
      iSide := -1;
      dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
    end else
    begin
      iSide := 1;
      dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
    end;

    iQty := abs(aPos.Volume);
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, aPos.Symbol,
    iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := opNormal;
      gEnv.Engine.TradeBroker.Send(aTicket);

      stLog := Format('Ban_Hult정리 %s',[aOrder.Represent2]);
      gEnv.EnvLog(WIN_BHULT, stLog);
    end;
  end;

  {
  for i := 0 to Positions.Count - 1 do
  begin
    aPos := Positions.Items[i] as TPosition;
    if aPos.Volume <> 0 then
    begin
      //손절.... 해주자
      if aPos.Volume > 0 then
      begin
        iSide := -1;
        dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
      end else
      begin
        iSide := 1;
        dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
      end;

      iQty := abs(aPos.Volume);
      aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
      aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, aPos.Symbol,
      iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

      if aOrder <> nil then
      begin
        aOrder.OrderSpecies := opBHultopt;
        gEnv.Engine.TradeBroker.Send(aTicket);

        stLog := Format('Ban_Hult정리 %s',[aOrder.Represent2]);
        gEnv.EnvLog(WIN_BHULT, stLog);
      end;
    end;
  end;
  }
end;

procedure TBHultOptAxis.init(aAcnt: TAccount; aSymbol: TSymbol);
begin
  inherited;
  FSymbol := aSymbol;
  FAccount := aAcnt;
  Account := aAcnt;
  Reset;

end;

function TBHultOptAxis.IsRun: boolean;
begin
  if ( not FRun ) or ( FSymbol = nil ) or ( Account = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TBHultOptAxis.MakeAddEntry;
var
  i, iCnt : integer;
  aItem : TAddEntry;
  dPrice, dPrice1 : double;
begin
  dPrice := (FBHultData.HultPL + FBHultData.AddEntry) * -10000;
  dPrice1 := FBHultData.HultPL * -10000;
  FHighPL := 0;
  for i := 0 to FBHultData.AddEntryCnt - 1 do
  begin
    FAddEntrys.New(dPrice, i);
    FHighAddEntrys.New(dPrice1, i);
    dPrice := dPrice + (FBHultData.AddEntry * -10000);
    dPrice1 := dPrice1 + (FBHultData.AddEntry * -10000);
  end;

  if FAddEntrys.Count > 0 then
    FAddEntryItem := FAddEntrys.Items[0] as TAddEntry;
end;

procedure TBHultOptAxis.OnLcTimer(Sender: TObject);
begin

end;

procedure TBHultOptAxis.QuoteProc(aQuote: TQuote; iDataID: integer);
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


  if FBHultData.HultCalS then
    FVirtualHult.DoQuote(aQuote);
end;

procedure TBHultOptAxis.Reset;
begin
  FRun := false;
  FReady  := false;
  FLossCut:= false;
  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FRetryCnt := 0;
  FLossCutCnt := 0;
  FSuccess := false;
  FTermCnt := 0;
  FHLTSignal := false;
  FAddEntrys.Clear;
  FHighAddEntrys.Clear;
  FAddEntryItem := nil;
  FHighAddEntryItem := nil;
  FOrderSymbol := nil;
  FHighSymbol := nil;
  FFirstQty := 0;
  FHalfEntry := true;
end;

procedure TBHultOptAxis.SetNextAddEntry;
var
  iIndex : integer;
begin
  if FAddEntryItem = nil then exit;

  iIndex := FAddEntryItem.Index + 1;
  if iIndex >= FAddEntrys.Count then
    FAddEntryItem := nil
  else
    FAddEntryItem := FAddEntrys.Items[iIndex] as TAddEntry;
end;

function TBHultOptAxis.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;

  if FBHultData.HultCalS then
  begin
    FVirtualHult := TVirtualHult.Create;
    FVirtualHult.SetSymbol(Fsymbol, FBHultData.HultGap);
  end else
    FVirtualHult := gEnv.Engine.VirtualTrade.GetHult(FBHultData.HultGap);

  if FVirtualHult = nil then exit;
  FRun := true;
  MakeAddEntry;

  if Assigned(OnResult) then
    OnResult(self, FRun);
  gEnv.EnvLog(WIN_BHULT, Format('BHult Start %s, %d', [FSymbol.Code, FBHultData.OrdGap]) );
end;

procedure TBHultOptAxis.Stop(bAuto : boolean);
begin
  FRun := false;
  gEnv.EnvLog(WIN_BHULT, Format('BHult Stop %s, %d', [FSymbol.Code, FBHultData.OrdGap]) );
  // 손절 넣자....

  if FBHultData.HultCalS then
    FVirtualHult.Free;

  if Assigned(OnResult) then
    OnResult(self, FRun);    
  if bAuto then
    BHULTLossCut(1);
end;


procedure TBHultOptAxis.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
begin
  if not IsRun then Exit;
  if aOrder.OrderSpecies <> opBHultOpt then exit;
end;

procedure TBHultOptAxis.UpdateQuote(aQuote: TQuote);
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

  if Position <> nil then
  begin
    if (FBHultData.UseAllcnlNStop) and (TotPL <= FBHultData.RiskAmt * -10000) then
    begin
      Stop;
      stLog := Format('일일한도 오버 %.0f', [TotPL]);
      gEnv.EnvLog(WIN_BHULT, stLog);
      exit;
    end;

    if (FBHultData.UseAllcnlNStop) and (TotPL >= FBHultData.ProfitAmt * 10000) then
    begin
      Stop;
      stLog := Format('이익청산 %.0f', [TotPL]);
      gEnv.EnvLog(WIN_BHULT, stLog);
      exit;
    end;
  end;
  // 추세 전략
  DoAddEntry;

  //양매수 전략
  {
  DoAddEntry;
  DoHighAddEntry;
   }

  //절반 절반 추세
  //DoHalfEntry;

  //절반추세, 절반 양매수
  //DoHalfCallPutBuy;
end;

{ TAddEntrys }

constructor TAddEntrys.Create;
begin
  inherited Create(TAddEntry);
end;

destructor TAddEntrys.Destroy;
begin

  inherited;
end;

function TAddEntrys.Find(dPrice: double): TAddEntry;
var
  i : integer;
  aItem : TAddEntry;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if dPrice = aItem.AddPrice then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

function TAddEntrys.GetEntryItem(iIndex: integer): TAddEntry;
begin
  Result := nil;
  if (iIndex < 0) or (Count <= iIndex) then exit;

  Result := Items[iIndex] as TAddEntry;
end;

function TAddEntrys.GetHighItem(dPrice: double): TAddEntry;
var
  i, iCur : integer;
  aItem, aItem1 : TAddEntry;
begin
  Result := nil;
  for i := 0 to Count - 1 do        //현재 위치를 찾자
  begin
    aItem := GetEntryItem(i);
    aItem1 := GetEntryItem(i+1);

    if (aItem = nil) or (aItem1 = nil)  then
      exit;

    if (aItem.AddPrice >= dPrice) and (aItem1.AddPrice < dPrice) then
    begin
      iCur := i - 1;
      break;
    end;
  end;


  for i := iCur downto 0 do            //현재위치에서 아래로 주문 안나간 Item 찾기
  begin
    aItem := GetEntryItem(i);

    if aItem <> nil then
    begin
      if not aItem.SendOrder then
      begin
        Result := aItem;
        break;
      end;
    end;
  end;
end;

function TAddEntrys.New(dPrice : double; iIndex : integer): TAddEntry;
begin
  Result := Find(dPrice);
  if Result = nil then
  begin
    Result := Add as TAddEntry;
    Result.AddPrice := dPrice;
    Result.SendOrder := false;
    Result.Index := iIndex;
  end;
end;

end.
