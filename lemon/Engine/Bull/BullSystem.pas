unit BullSystem;

interface

uses
  Classes, SysUtils, Math,
  //
  //AppTypes, AppConsts, SymbolStore, Broadcaster, , PriceCentral,
  Gletypes, GleConsts, CleSymbols, CleQuoteBroker,
  CalcGreeks, BullData, CleQuoteTimers;
const
  TIMEOUT_BEAT = 1;

type

  TBullLogEvent = procedure(Sender : TObject; stLog : String) of object;

  TBullResult = record
    EventKind : TBullEventKind;
    FutureAvgPrices : array[TNavi] of Double;           // 선물 평균가
    FutureMA : Double;                                  // 선물 이동평균
    OptionAvgPrices : array[TNavi] of Double;           // 옵션 평균가
    OptionFitPrices : array[TNavi] of Double;           // 옵션 적정가
    OptionSeparation : Double;                          // 괴리 = 옵션적정가-옵션평균가
    RealIV : Double;                                    // 내재변동성
    RealDelta : Double;                                 // 델타
    SynFutures : Double;
  end;

  TBullSystem = class
  private
    FFuture : TSymbol;
    FOption : TSymbol;
    FConfig : TBullConfig;
    FOnNotify : TNotifyEvent;
    FOnLog : TBullLogEvent;

      // 결과값
    FBullResult : TBullResult;
    FBeatTime : TDateTime;              //
    FSynFutures : TSymbol;

    procedure DoNotify;
    procedure DoLog(stLog : String);
    procedure SetConfig(const Value: TBullConfig);
    procedure SetFuture(const Value: TSymbol);
    procedure SetOption(const Value: TSymbol);
    procedure ResetValues;

  public
    constructor Create;
    destructor Destroy; override;

    function FutureQuoteProc : Boolean;
    function OptionQuoteProc : Boolean;
    function BeatProc : Boolean;
    function Ready : Boolean;
    procedure Sync;

    property Config : TBullConfig read FConfig write SetConfig;
    property Future : TSymbol read FFuture write SetFuture;
    property Option : TSymbol read FOption write SetOption;
    property OnNotify : TNotifyEvent read FOnNotify write FOnNotify;
    property OnLog : TBullLogEvent read FOnLog write FOnLog;
    property BullResult : TBullResult read FBullResult;
  end;

implementation

uses CleKrxSymbols, GAppEnv;

{ TBullSystem }

constructor TBullSystem.Create;
begin
  FFuture := nil;
  FOption := nil;
  ResetValues;
  FBeatTime := GetQuoteTime;
  FSynFutures := gEnv.Engine.SymbolCore.Symbols.FindCode(KOSPI200_SYNTH_FUTURES_CODE);
end;

destructor TBullSystem.Destroy;
begin

  inherited;
end;

procedure TBullSystem.ResetValues;
begin
  with FBullResult do
  begin
    EventKind := beNone;
    FutureAvgPrices[Last] := 0;
    FutureAvgPrices[Prev] := 0;
    FutureMA := 0;
    OptionAvgPrices[Last] := 0;
    OptionAvgPrices[Prev] := 0;
    OptionFitPrices[Last] := 0;
    OptionFitPrices[Prev] := 0;
    RealIV := 0;
    RealDelta := 0;
  end;
end;

procedure TBullSystem.DoLog(stLog : String);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, stLog);
end;

procedure TBullSystem.DoNotify;
begin
  if Assigned(FOnNotify) then
    FOnNotify(Self);
end;

function TBullSystem.FutureQuoteProc : Boolean;
var
  aQuoteGap, aAvgPrice : Double;
  aQuote  : TQuote;
begin
  Result := False;
  if Not Ready then Exit;
  aQuote  := FFuture.Quote as TQuote;
  if aQuote = nil then Exit;

  if (aQuote.Asks[0].Volume = 0) or (aQuote.Bids[0].Volume = 0) then
    Exit;

    // 선물 평균가를 계산한다.
  aQuoteGap := aQuote.Asks[0].Price - aQuote.Bids[0].Price;
  if Abs(aQuoteGap)< 0.05+PRICE_EPSILON then
    aAvgPrice := aQuoteGap * aQuote.Bids[0].Volume
                     / (aQuote.Asks[0].Volume + aQuote.Bids[0].Volume )
                     + aQuote.Bids[0].Price
  else
    aAvgPrice := (aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2;

  with FBullResult do
  begin
    EventKind := beFuture;

    FutureAvgPrices[Prev] := FutureAvgPrices[Last];
    FutureAvgPrices[Last] := aAvgPrice;
    if FutureAvgPrices[Prev] < PRICE_EPSILON then
      FutureAvgPrices[Prev] := FutureAvgPrices[Last];
    SynFutures := FSynFutures.Last;

    OptionAvgPrices[Prev] := OptionAvgPrices[Last];

    if OptionFitPrices[Last] > PRICE_EPSILON then
    begin
      OptionFitPrices[Prev] := OptionFitPrices[Last];
      OptionFitPrices[Last] := OptionFitPrices[Prev] +
                (FutureAvgPrices[Last]-FutureAvgPrices[Prev]) * RealDelta;
    end
    else
    begin
      OptionFitPrices[Prev] := OptionAvgPrices[Last];
      OptionFitPrices[Last] := OptionAvgPrices[Last];
    end;

    OptionSeparation := OptionFitPrices[Last]-OptionAvgPrices[Last];

    if OptionFitPrices[Last] > PRICE_EPSILON then
    begin
      Result := True;
      DoNotify;
    end;
  end;
end;

function TBullSystem.OptionQuoteProc : Boolean;
var
  aQuoteGap, aAvgPrice : Double;
  aQuote  : TQuote;
begin
  Result := False;
  if Not Ready then Exit;
  aQuote  := FOption.Quote as TQuote;
  if aQuote = nil then Exit;

  if (aQuote.Asks[0].Volume = 0) or (aQuote.Bids[0].Volume = 0) then
    Exit;

  aQuoteGap := aQuote.Asks[0].Price - aQuote.Bids[0].Price;
  if Abs(aQuoteGap)< 0.01+PRICE_EPSILON then
    aAvgPrice := aQuoteGap * aQuote.Bids[0].Volume
                     / (aQuote.Asks[0].Volume + aQuote.Bids[0].Volume )
                     + aQuote.Bids[0].Price
  else
    aAvgPrice := (aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2;

  with FBullResult do
  begin
    EventKind := beOption;

    FutureAvgPrices[Prev] := FutureAvgPrices[Last];
    OptionAvgPrices[Prev] := OptionAvgPrices[Last];
    OptionAvgPrices[Last] := aAvgPrice;

    if OptionFitPrices[Last] < PRICE_EPSILON then
      OptionFitPrices[Last] := OptionAvgPrices[Last];
    OptionFitPrices[Prev] := OptionFitPrices[Last];

    OptionSeparation := OptionFitPrices[Last]-OptionAvgPrices[Last];
  end;

  Result := True;
  DoNotify;
end;

function TBullSystem.BeatProc : Boolean;
var
  U, E, R, T, TC, W : Double;
  ExpireDateTime : TDateTime;
  aTimeSpan : TDateTime;
begin
  Result := False;
//  Exit;
  if Not Ready then Exit;

  aTimeSpan := GetQuoteTime-FBeatTime;
  if aTimeSpan > TIMEOUT_BEAT /(3600*24) then
  begin
    with FBullResult do
    begin
      if (FutureAvgPrices[Last] > PRICE_EPSILON) and
         (OptionFitPrices[Last] > PRICE_EPSILON) then
      begin
        EventKind := beTimer;

        FutureAvgPrices[Prev] := FutureAvgPrices[Last];
        OptionAvgPrices[Prev] := OptionAvgPrices[Last];

          // 옵션적정가 = 옵션적정가
        OptionFitPrices[Prev] := OptionFitPrices[Last];
        OptionFitPrices[Last] := OptionFitPrices[Last] -
                          OptionSeparation * FConfig.E1_P5;
                          
        OptionSeparation := OptionFitPrices[Last]-OptionAvgPrices[Last];

          // IV, Delta
        U := FSynFutures.Last;
        E := (FOption as TOption).StrikePrice;
        R := (FOption as TOption).CDRate;
        ExpireDateTime := GetQuoteDate + (FOption as TOption).DaysToExp - 1 + EncodeTime(15,15,0,0);
        T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, rcTrdTime);
        TC := (FOption as TOption).DaysToExp / 365;


        if FOption.OptionType = otCall then
          W := 1
        else
          W := -1;

        RealIV := IV(U, E, R, T, TC, OptionAvgPrices[Last], W);
        RealDelta := Delta(U, E, R, RealIV, T, TC, W);

          // 선물 지수 이동평균
        if FutureMA < PRICE_EPSILON then
          FutureMA := FutureAvgPrices[Last]
        else
          FutureMA := FutureMA + (FutureAvgPrices[Last]-FutureMA)* FConfig.E1_P6;

        Result := True;
        DoNotify;
      end;
    end;

    FBeatTime := GetQuoteTime;
  end;
end;

procedure TBullSystem.Sync;
begin
  if Not Ready then Exit;
  with FBullResult do
  begin
    EventKind := beSync;
    OptionFitPrices[Last] := OptionAvgPrices[Last];
    OptionFitPrices[Prev] := OptionAvgPrices[Last];
    Donotify;
  end;
end;

procedure TBullSystem.SetConfig(const Value: TBullConfig);
begin
  FConfig := Value;
end;

procedure TBullSystem.SetFuture(const Value: TSymbol);
begin
  if FFuture = Value then Exit;
  FFuture := Value;
  ResetValues;
end;

procedure TBullSystem.SetOption(const Value: TSymbol);
begin
  if FOption = Value then Exit;
  FOption := Value;
  ResetValues;
end;

function TBullSystem.Ready: Boolean;
begin
  Result := (FFuture <> nil) and
            (FOption <> nil);
end;

end.

