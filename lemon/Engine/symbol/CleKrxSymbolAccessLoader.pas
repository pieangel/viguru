unit CleKrxSymbolAccessLoader;

interface

uses
  Classes, SysUtils,

  LemonEngine, CleMarketSpecs, CleSymbols,
  CleKrxSymbols,
    // lemon: imports
  MasterManager;

type
  TKRXSymbolAccessLoader = class
  private
    FEngine: TLemonEngine;
    FDBFile: String;
  public
    constructor Create(aEngine: TLemonEngine);

    procedure SetSpecs;
    procedure AddFixedSymbols;
    function Load(dtMaster: TDateTime): Boolean;

    property DBFile: String read FDBFile write FDBFile;
  end;

implementation

constructor TKRXSymbolAccessLoader.Create(aEngine: TLemonEngine);
begin
  FEngine := aEngine;
end;

procedure TKRXSymbolAccessLoader.SetSpecs;
begin
  if FEngine = nil then Exit;

  with FEngine.SymbolCore.Specs.New(FQN_KRX_INDEX) do
  begin
    RootCode := '';
    Description := 'KRX Index';
    Sector := 'Index';
    Currency := CURRENCY_WON;
    SetTick(0.01, 1, 2);
    SetPoint(1, 1);
  end;

  with FEngine.SymbolCore.Specs.New(FQN_KRX_STOCK) do
  begin
    RootCode := '';
    Description := 'KRX Stock';
    Sector := '';
    Currency := CURRENCY_WON;
    SetTick(10, 1, 0);
    SetPoint(1, 1);
  end;

  with FEngine.SymbolCore.Specs.New(FQN_KRX_BOND) do
  begin
    RootCode := '';
    Description := 'KRX Bond';
    Sector := '';
    Currency := CURRENCY_WON;
    SetTick(1, 1, 1);
    SetPoint(1, 1);
  end;

  with FEngine.SymbolCore.Specs.New(FQN_KRX_ETF) do
  begin
    RootCode := '';
    Description := 'KRX Index';
    Sector := 'Index';
    Currency := CURRENCY_WON;
    SetTick(0.01, 1, 2);
    SetPoint(1, 1);
  end;

  with FEngine.SymbolCore.Specs.New(FQN_KOSPI200_FUTURES) do
  begin
    RootCode := KOSPI200_CODE;
    Description := 'KOSPI200 Futures';
    Sector := 'Index';
    Currency := CURRENCY_WON;
    SetTick(0.05, 1, 2);
    SetPoint(500000, 1);
  end;

  with FEngine.SymbolCore.Specs.New(FQN_KOSPI200_OPTION) do
  begin
    RootCode := KOSPI200_CODE;
    Description := 'KOSPI200 Option';
    Sector := 'Index';
    Currency := CURRENCY_WON;
    SetTick(0.01, 1, 2);
    SetPoint(100000, 1);
  end;

  with FEngine.SymbolCore.Specs.New(FQN_KOSPI200_FUTURES_SPREAD) do
  begin
    RootCode := KOSPI200_CODE;
    Description := 'KOSPI200 Futures Spread';
    Sector := 'Index';
    Currency := CURRENCY_WON;
    SetTick(0.05, 1, 2);
    SetPoint(500000, 1);
  end;
  
end;

procedure TKRXSymbolAccessLoader.AddFixedSymbols;
var
  aIndex: TIndex;
begin
  if FEngine = nil then Exit;

    // KOSPI200 index
  aIndex := FEngine.SymbolCore.Indexes.New(KOSPI200_CODE);
  aIndex.Spec := FEngine.SymbolCore.Specs.Find(FQN_KRX_INDEX);
  FEngine.SymbolCore.RegisterSymbol(aIndex);
    // KOSPI200 synthetic futures
  aIndex := FEngine.SymbolCore.Indexes.New(KOSPI200_SYNTH_FUTURES_CODE);
  aIndex.Spec := FEngine.SymbolCore.Specs.Find(FQN_KRX_INDEX);
  FEngine.SymbolCore.RegisterSymbol(aIndex);

end;

function TKRXSymbolAccessLoader.Load(dtMaster: TDateTime): Boolean;
var
  aMasterManager : TMasterManager;
  aRecord : TMasterRecord;
  stCode: String;
  theKOSPI200, aSymbol: TSymbol;
  i: Integer;
  bNew: Boolean;
begin
  Result := False;
  if FEngine = nil then Exit;

  if Length(FDBFile) = 0 then Exit;

  theKospi200 := FEngine.SymbolCore.Symbols.FindCode(KOSPI200_CODE);

  try
      // Parser
    aMasterManager := TMasterManager.Create(FDBFile);
    if aMasterManager.GetMaster(FormatDateTime('yyyy-mm-dd', dtMaster)) = 0 then Exit;

    for i:=0 to aMasterManager.Records.Count-1 do
    begin
      aRecord := aMasterManager.Records[i];

      stCode := Trim(aRecord.Code);
      if Length(stCode) = 0 then Continue;

        // futures code
      if stCode = '1' then
        stCode := Copy(stCode,1,5);

        // check if it is already registered
      aSymbol := FEngine.SymbolCore.Symbols.FindCode(stCode);
      if aSymbol = nil then
      begin
        bNew := True;
          // create symbol object based on the type
        case stCode[1] of
          '1' :
            begin
              aSymbol := FEngine.SymbolCore.Futures.New(Copy(stCode,1,5));
              aSymbol.Spec := FEngine.SymbolCore.Specs.Find(FQN_KOSPI200_FUTURES);
            end;
          '2' :
            begin
              aSymbol := FEngine.SymbolCore.Options.New(stCode);
              aSymbol.Spec := FEngine.SymbolCore.Specs.Find(FQN_KOSPI200_OPTION);
              (aSymbol as TOption).CallPut := 'C';
            end;
          '3' :
            begin
              aSymbol := FEngine.SymbolCore.Options.New(stCode);
              aSymbol.Spec := FEngine.SymbolCore.Specs.Find(FQN_KOSPI200_OPTION);
              (aSymbol as TOption).CallPut := 'P';
            end;
          '4' :
            begin
              aSymbol := FEngine.SymbolCore.Spreads.New(stCode);
              aSymbol.Spec := FEngine.SymbolCore.Specs.Find(FQN_KOSPI200_FUTURES_SPREAD);
              (aSymbol as TSpread).FrontMonth := '101'+Copy(stCode,4,2);
              (aSymbol as TSpread).BackMonth := '101'+Copy(stCode,6,2);
            end;
          else
            Continue;
        end;
      end else
        bNew := False;

        ////-- common --////
      with aSymbol do
      begin
          // names
        ShortName := Trim(aRecord.ShortDesc);
        Name := ShortName;
        LongName := ShortName;
        EngName := ShortName;
          // price info
        PrevClose := aRecord.PrevClose;
        Base    := aRecord.BasePrice;
        DayOpen := Base; // updated once after open
        DayHigh := Base; // updated during the day
        DayLow  := Base; // updated during the day
        Last    := Base; // updated during the day
          // daily price limit
        LimitHigh := aRecord.HighLimit;
        LimitLow  := aRecord.LowLimit;
        CBHigh    := aRecord.CbHigh;
        CBLow     := aRecord.CbLow;
          // control
        Tradable := True;
      end;

        ////-- derivative --////
      with aSymbol as TDerivative do
      begin
          // fundamental
        Underlying := theKOSPI200;
          // expiration info
        DaysToExp := Round(aRecord.RemDays);
        ExpDate := dtMaster + DaysToExp - 1;
          // open interest
        PrevOI    := Round(aRecord.PrevOpenPositions);
        OI        := PrevOI; // updated during the day
          // market reference
        DividendRate := aRecord.DividendRate;
        CDRate       := aRecord.CdRate;
      end;

        ////-- option --////
      if aSymbol is TOption then
      with aSymbol as TOption do
      begin
        StrikePrice := aRecord.StrikePrice;
        IsATM := aRecord.IsATM;
        IV := aRecord.PrevIV;
      end;

        // register
      if bNew then
        FEngine.SymbolCore.RegisterSymbol(aSymbol);
    end; // end of for..loop

    Result := True ;
  finally
    aMasterManager.Free ;
  end;
  //
end;


end.
