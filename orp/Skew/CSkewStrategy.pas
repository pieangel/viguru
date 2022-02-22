unit CSkewStrategy;

interface

uses
  Classes, Math, SysUtils,

    // lemon:
  LemonEngine, CleSymbols, CleMarkets, CleQuoteBroker, CleDistributor,
    // lemon: KRX
  CleKRXSymbols,
    // lemon: imported
  CalcGreeks,

    // skew
  CSkewConsts, CSkewOptions, CSkewPoints;

type
  TSkewStrategy = class
  private
    FEngine: TLemonEngine;

    FEnabled: Boolean;
    FSkewTree: TSkewTree;
    FSkewPoints: TSkewPoints;
    FSkewHistories: TSkewHistories;

    FIndex: TIndex;
    FFutureMarket: TFutureMarket;
    FOptionMarket: TOptionMarket;

    FFutures: TFuture;
    FOptionTree: TOptionTree;

    FOptCalDaysToExp: Integer;
    FOptTrdDaysToExp: Integer;

    FLastQuoteTime: TDateTime;

    FIndex_Ready: Boolean;
    FFutures_Ready: Boolean;
    FATM_Ready: Boolean;
    FATM: Double;
    //FBSMBasedSPrice: Double;

    FOnUpdate: TNotifyEvent;

    procedure CalcATM(aQuote: TQuote);
  public
    constructor Create(aEngine: TLemonEngine);
    destructor Destroy; override;

    procedure DoQuote(Sender, Receiver: TObject; DataID: Integer;
    DataObj: TObject; EventID: TDistributorID);

    property Engine: TLemonEngine read FEngine write FEngine;
    
    property Points: TSkewPoints read FSkewPoints;
    property Tree: TSkewTree read FSkewTree;
    property Histories: TSkewHistories read FSkewHistories;

    property Enabled: Boolean read FEnabled;

    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

implementation

{ TSkewStrategy }

//-----------------------------------------------------------< start & finish >

constructor TSkewStrategy.Create(aEngine: TLemonEngine);
var
  i: Integer;
  aStrike: TStrike;
begin
  FSkewPoints := TSkewPoints.Create;
  FSkewTree := TSkewTree.Create;
  FSkewHistories := TSkewHistories.Create;

  FSkewPoints.Generate(MIN_SKEW_RANGE, MAX_SKEW_RANGE, SKEW_INTERVALS);

  FEngine := aEngine;
  if FEngine <> nil then
  begin
    FIndex := FEngine.SymbolCore.Symbols.FindCode(KOSPI200_CODE) as TIndex;
    FFutureMarket := FEngine.SymbolCore.Markets.FindMarket(FQN_KOSPI200_FUTURES) as TFutureMarket;
    FOptionMarket := FEngine.SymbolCore.Markets.FindMarket(FQN_KOSPI200_OPTION) as TOptionMarket;
  end else
  begin
    FIndex := nil;
    FFutureMarket := nil;
    FOptionMarket := nil;
  end;

  FEnabled := (FIndex <> nil)
              and (FFutureMarket <> nil)
              and (FFutureMarket.FrontMonth <> nil)
              and (FOptionMarket <> nil)
              and (FOptionMarket.Trees.FrontMonth <> nil)
              and (FOptionMarket.Trees.FrontMonth.Strikes.Count > 0);

  if FEnabled then
  begin
      // futures front month
    FFutures := FFutureMarket.FrontMonth;
      // option front-month symbol tree arranged by strike prices
    FOptionTree := FOptionMarket.Trees.FrontMonth;
    FSkewTree.SetTree(FOptionTree);

      // subscribe quotes
    FEngine.QuoteBroker.Subscribe(Self, FIndex, DoQuote);
    FEngine.QuoteBroker.Subscribe(Self, FFutures, DoQuote);

    for i := 0 to FOptionTree.Strikes.Count - 1 do
    begin
      aStrike := FOptionTree.Strikes[i];
      if aStrike.Call <> nil then
        FEngine.QuoteBroker.Subscribe(Self, aStrike.Call, DoQuote);
      if aStrike.Put <> nil then
        FEngine.QuoteBroker.Subscribe(Self, aStrike.Put, DoQuote);
    end;

      // number of days before expiration
    FOptCalDaysToExp := FOptionTree.Strikes[0].Call.DaysToExp;
    FOptTrdDaysToExp := Round(FEngine.Holidays.CalcDaysToExp(
                                FEngine.QuoteBroker.Timers.Now,
                                FEngine.QuoteBroker.Timers.Now + FOptCalDaysToExp,
                                rcCalDate, False));
      // subscribe
      // init
    FIndex_Ready := False;
    FFutures_Ready := False;
    FATM_Ready := False;
  end;
end;

destructor TSkewStrategy.Destroy;
begin
  if FEngine <> nil then
    FEngine.QuoteBroker.Cancel(Self);

  FSkewHistories.Free;
  FSkewTree.Free;
  FSkewPoints.Free;

  inherited;
end;

//--------------------------------------------------------------------< quote >

procedure TSkewStrategy.DoQuote(Sender, Receiver: TObject; DataID: Integer;
    DataObj: TObject; EventID: TDistributorID);
var
  aSkewBranch: TSkewBranch;
  aQuote: TQuote;
  i, iCallPut: Integer;
begin
  if (not FEnabled) or (DataObj = nil) or not (DataObj is TQuote) then Exit;

  aQuote := DataObj as TQuote;

  if aQuote.Symbol = nil then Exit;

    // record last time when a quote received
  FLastQuoteTime := aQuote.LastEventTime;

    // calculate
  if aQuote.Symbol is TIndex then
  begin
    if not FIndex_Ready then FIndex_Ready := True;
    CalcATM(aQuote);
  end else
  if aQuote.Symbol is TFuture then
  begin
    if not FFutures_Ready then FFutures_Ready := True;
    CalcATM(aQuote);
  end else
  if (aQuote.Symbol is TOption)
       and ((aQuote.Symbol as TOption).Underlying = FIndex)
       and ((aQuote.Symbol as TOption).DaysToExp = FOptCalDaysToExp) then
  begin
    aSkewBranch := FSkewTree.Find(aQuote.Symbol as TOption);
    if aSkewBranch = nil then Exit;

    if FATM_Ready and (FATM > 1.0e-10) then
    begin
      aSkewBranch.CalcIVs(FATM, FOptTrdDaysToExp/250, FOptCalDaysToExp/365, aQuote);

      if aSkewBranch.Call = aQuote.Symbol then
        iCallPut := IDX_CALL
      else
        iCallPut := IDX_PUT;

      for i := 0 to 2 do
        if aSkewBranch.IVs[iCallPut,i] > 1.0e-10 then
          FSkewPoints.CalcIVs(aSkewBranch.StrikePrice / FATM,
                              aSkewBranch.IVs[iCallPut, i], iCallPut, i);
    end;
  end;

    // notify
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
  // (Special Note)
  // Previously, if ATM deviates from the former set point,
  // all the options was recalculated and skew points was updated followingly.
  // This seems unnecessary because when this happens, it is calculating
  // past value of options with the new underlying which has no responsibility
  // for the former.
end;

// (Calculate Underlying(ATM) Price)
// using following prices
// .. Close price of Underlying Index
// .. Ask/Bid price of front-month futures
// .. Ask/Bid price of each three call/put options nearby ATM
// foumulae
//
procedure TSkewStrategy.CalcATM(aQuote: TQuote);
var
  dFPR: Double;
  iRemTrdDays: Integer;
begin
    ////// the following is the test code
  if aQuote.Symbol is TFuture then
  begin
    FATM := (aQuote.Asks[0].Price + aQuote.Bids[0].Price) / 2.0;
    if not FATM_Ready  then
      FATM_Ready := True 
  end;


{ // the following codes were commented for temporary test
   if not FIndex_Ready or not FFutures_Ready then Exit;
      // Average price of front month futures = (ask[1] + bid[1]) / 2
   if aQuote.Symbol is TFuture then
     dFPR := (aQuote.Asks[0].Price + aQuote.Bids[0].Price) / 2.0;

    // Here, we assume more than 10 days before the expiration,
    // only Futures derives options, closer gets the day to the expiration
    // less then 10 days, Index start to affect options.
    // On the day of expiration, we assume only Index is the sole driver
    // of options
  iRemTrdDays := Min(10, FOptTrdDaysToExp);

    // Effect-ratio driven average price between index and futures
  FATM := (FIndex.Last * (10 - iRemTrdDays) + dFPR*iRemTrdDays)/10.0;
  if not FATM_Ready then FATM_Ready := True;
}
  // (Special Note)
  // It looks unreasonable to use option prices to calculate ATM because
  // option price is the "responsive(dependent) variable" in BS model.
  // Furthermore, using index and futures price to select the options to
  // calculate ATM doesn't seem to make sense because of the following
  // confusion:
  //    (1) calculate underlying price from index and futures
  //    (2) select 6 call/put options based the value (1)
  //    (3) get final value by averaging (1) and (2)
  // here, (2) is very dependent on (1). So it's averaging the interdependent
  // cases, which is mathematically strange.
end;

end.
