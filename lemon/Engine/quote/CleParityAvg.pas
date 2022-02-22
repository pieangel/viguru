unit CleParityAvg;

interface

uses
  Classes, SysUtils,
  CleMarkets, CleSymbols, CleQuoteBroker, CleQuoteTimers, CleKrxSymbols, Ticks;

type
  TParityAvg = class
  private
    FLast : double;
    FQuote : TQuote;
    FSymbol : TSymbol;
    FTimer  : TQuoteTimer;
    FInit : boolean;
    procedure CalAvg;
  public
    constructor Create;
    destructor Destroy; override;
    procedure initSymbols;
    procedure OnCalParityTimer( Sender : TObject );
    property Last : double read FLast write FLast;
  end;

implementation
uses
  GAppEnv, GleTypes;

{ TParityAvg }

procedure TParityAvg.CalAvg;
var
  i : integer;
  dPrice , dSum : double;
  aOptionMarket : TOptionMarket;
  aStrike : TStrike;
  aTick : TTickITem;
  tstart : TDateTime;
begin

  if not FInit then
  begin
    initSymbols;
    Exit;
  end;

  Exit;

  tstart := GetQuoteDate + EncodeTime(9,5,0,0);

  if GetQuoteTime < tstart then exit;


  dSum := 0;
  aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];

  if aOptionMarket = nil then exit;
  
  for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    dPrice := (aStrike.Call as TSymbol).Last - (aStrike.Put as TSymbol).Last + aStrike.StrikePrice;
    dSum := dSum + dPrice;
  end;

  FLast := dSum / aOptionMarket.Trees.FrontMonth.Strikes.Count;



  if FQuote = nil then
    FQuote := gEnv.Engine.QuoteBroker.Find( KOSPI200_PARITY_CODE );

  //FSyncQuote.up

  if FQuote <> nil then
  begin
    FQuote.LastEvent := qtTimeNSale;
    aTick := TTickITem( FQuote.FTicks.Add);
    aTick.T := GetQuoteTime;
    aTick.C := FLast;
    aTick.FillVol := 0;
    aTick.AccVol  := 0;
    aTick.Side    := 1;

    FQuote.Change := FLast - FQuote.Last;
    FQuote.Last := FLast;
    if FQuote.High < FLast then
      Fquote.High := FLast;
    if FQuote.Low > FLast then
      FQuote.Low := FLast;

    if FQuote.FTicks.Count = 1 then
    begin
      FQuote.Open := FLast;
      FQuote.High := FLast;
      FQuote.Low  := FLast;
    end;
    FQuote.Distributor.Distribute(FQuote, 0, FQuote, 0);
  end;
end;

constructor TParityAvg.Create;
begin
  FInit := false;
end;

destructor TParityAvg.Destroy;
begin

  inherited;
end;

procedure TParityAvg.initSymbols;
begin
  FSymbol := gEnv.Engine.SymbolCore.Indexes.Find( KOSPI200_PARITY_CODE );
  if FSymbol <> nil  then
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( self, FSymbol,
      gEnv.Engine.QuoteBroker.DummyEventHandler, spIdle)
  else
    FQuote  := nil;

  if FTimer = nil then
  begin
    FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
    FTimer.Interval := 1000;
    FTimer.OnTimer  := OnCalParityTimer;
    FTimer.Enabled  := true;
  end
  else
    FTimer.Enabled  := true;


  FInit := true;
end;

procedure TParityAvg.OnCalParityTimer(Sender: TObject);
begin
  CalAvg;
end;

end.
