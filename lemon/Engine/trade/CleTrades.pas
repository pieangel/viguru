unit CleTrades;

interface

uses
  Classes, SysUtils, Math,

  GleLib, CleMarketSpecs, CleQuoteBroker, ClePositions;

type
  TTradeLeg = class(TCollectionItem)
  protected
    FSymbol: String;
    FCoeff: Integer;
    FPosition: TPosition;
  public
    property Symbol: String read FSymbol;
    property Coeff: Integer read FCoeff;
    property Position: TPosition read FPosition write FPosition;
  end;

  TTradeLegs = class(TCollection)
  protected
    FPrevQty: Integer;
    FPrevAvgPrice: Double;
    FLastQty: Integer;
    FLastAvgPrice: Double;
    FEntryDate: TDateTime;
  public
    procedure Compose;
    procedure CalcAvgPrices;

    property PrevQty: Integer read FPrevQty;
    property PrevAvgPrice: Double read FPrevAvgPrice;
    property LastQty: Integer read FLastQty;
    property LastAvgPrice: Double read FLastAvgPrice;
    property EntryDate: TDateTime read FEntryDate write FEntryDate;
  end;

  TTradeFlatLeg = class(TTradeLeg)
  protected
    FQuote: TQuote;
  public
    property Quote: TQuote read FQuote write FQuote;
  end;

  TTradeFlatLegs = class(TTradeLegs)
  private
    FQuoteCount: Integer;
    FCurrentPrice: Double;

    function IsSpread: Boolean;
    function AddLeg(iCoeff: Integer; stSymbol: String): TTradeFlatLeg;
    function GetLeg(i: Integer): TTradeFlatLeg;
  public
    constructor Create;

    procedure CalcCurrentPrice;

    property QuoteCount: Integer read FQuoteCount;
    property CurrentPrice: Double read FCurrentPrice;
    property Legs[i:Integer]: TTradeFlatLeg read GetLeg; default;
  end;

  TTradeSpreadLeg = class(TTradeLeg);

  TTradeSpreadLegs = class(TTradeLegs)
  private
    function AddLeg(iCoeff: Integer; stSymbol: String): TTradeSpreadLeg;
    function GetLeg(i: Integer): TTradeSpreadLeg;
  public
    constructor Create;
    property Legs[i:Integer]: TTradeSpreadLeg read GetLeg; default;
  end;

  TTradeLegList = class(TList)
  private
    function GetLeg(i: Integer): TTradeLeg;
  public
    property Legs[i:Integer]: TTradeLeg read GetLeg; default;
  end;

  TTrade = class(TCollectionItem)
  private
    FSymbol: String;
    FContractSpec: TMarketSpec;
      // guide
    FDescription: String;
    FTargetPrice: Double;
    FTargetPriceStr: String;
    FStopPrice: Double;
    FStopPriceStr: String;
    FExitDate: TDateTime;
      // position info
    FEntryDate: TDateTime;

    FPrevQty: Integer;
    FLastQty: Integer;
    FPrevAvgPrice: Double;
    FLastAvgPrice: Double;
      // real-time
    FRealizedPL: Double;
    FUnrealizedPL: Double;
      // alert
    FOldPrice: Double;
    FAlertCount: Integer;
    FAlert: Boolean;
    FAlertMsg: String;
      //
    FFlatLegs: TTradeFlatLegs;
    FSpreadLegs: TTradeSpreadLegs;
    FLegs: TTradeLegList;
    function GetCaption: String;
    function GetCurrentPrice: Double;
    function GetQuoteCount: Integer;
      //
    procedure SetSymbol(const Value: String);
      // private methods
    function GetDaysBeforeExit: Integer;
    function GetDaysInPosition: Integer;
    procedure SetStopPrice(const Value: String);
    procedure SetTargetPrice(const Value: String);
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;
      //
    procedure Compose;
    function DoQuote(aQuote: TQuote): Boolean;
    function CheckAlert: Boolean;
    function ShortDesc(iLen: Integer): String;

    property Symbol: String read FSymbol write SetSymbol;
      // position quide
    property Caption: String read GetCaption;
    property Description: String read FDescription write FDescription;
    property TargetPrice: Double read FTargetPrice;
    property TargetPriceStr: String read FTargetPriceStr write SetTargetPrice;
    property StopPrice: Double read FStopPrice;
    property StopPriceStr: String read FStopPriceStr write SetStopPrice;
    property ExitDate: TDateTime read FExitDate write FExitDate;
    property DaysInPosition: Integer read GetDaysInPosition;
    property DaysBeforeExit: Integer read GetDaysBeforeExit;
      // position info
    property EntryDate: TDateTime read FEntryDate;
    property PrevQty: Integer read FPrevQty;
    property LastQty: Integer read FLastQty;
    property PrevAvgPrice: Double read FPrevAvgPrice;
    property LastAvgPrice: Double read FLastAvgPrice;
      // real-time
    property QuoteCount: Integer read GetQuoteCount;
    property CurrentPrice: Double read GetCurrentPrice;
    property UnrealizedPL: Double read FUnrealizedPL;
    property RealizedPL: Double read FRealizedPL;
      // alert
    property Alert: Boolean read FAlert;
    property AlertMsg: String read FAlertMsg;
      //
    property Legs: TTradeLegList read FLegs;
    property FlatLegs: TTradeFlatLegs read FFlatLegs;
    property SpreadLegs: TTradeSpreadLegs read FSpreadLegs;
  end;

  TTrades = class(TCollection)
  private
    function GetPL: Double;
    function GetTrade(i: Integer): TTrade; overload;
  protected
    //function Compare(aItem1, aItem2: TCollectionItem;
     // aSortIndex: Integer): Integer; override;
  public
    constructor Create;

    function AddTrade(stSymbol: String): TTrade; overload;
    function AddTrade(aPosition: TPosition): TTrade; overload;
    function FindTrade(stSymbol: String): TTrade;
    function GetTrade(stSymbol: String): TTrade; overload;
    procedure PurgeWithNoPositions;

    procedure PopulateList(aList: TStrings);

    property UnrealizedPL: Double read GetPL;
    property Trades[i:Integer]: TTrade read GetTrade; default;
  end;

const
  SORT_DESC   = 0;
  SORT_SYMBOL = 1;
  SORT_QTY    = 2;
  SORT_PL     = 3;

implementation

{ TTradeLegs }

constructor TTradeFlatLegs.Create;
begin
  inherited Create(TTradeFlatLeg);
end;

function TTradeFlatLegs.GetLeg(i: Integer): TTradeFlatLeg;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TTradeFlatLeg
  else
    Result := nil;
end;

function TTradeFlatLegs.AddLeg(iCoeff: Integer;
  stSymbol: String): TTradeFlatLeg;
begin
  Result := Add as TTradeFlatLeg;
  Result.FCoeff := iCoeff;
  Result.FSymbol := stSymbol;
  Result.FPosition := nil;
  Result.FQuote := nil;
end;

function TTradeFlatLegs.IsSpread: Boolean;
var
  i, iSum: Integer;
begin
  Result := False;

  if Count < 2 then Exit;

  iSum := 0;
  for i := 0 to Count - 1 do
    iSum := iSum + GetLeg(i).Coeff;

  Result := (iSum = 0);
end;

procedure TTradeFlatLegs.CalcCurrentPrice;
var
  i, iQuoteCount, iCalcCount: Integer;
  aLeg: TTradeFlatLeg;
  dPrice: Double;
begin
  FCurrentPrice := 0.0;
  FQuoteCount := 0;

  iQuoteCount := 0;
  dPrice := 0.0;
  iCalcCount := 0;

  for i := 0 to Count - 1 do
  begin
    aLeg := Items[i] as TTradeFlatLeg;

    if aLeg.Quote = nil then Exit;

    Inc(iCalcCount);
    if iCalcCount = 1 then
      iQuoteCount := aLeg.Quote.EventCount
    else
      iQuoteCount := Min(iQuoteCount, aLeg.Quote.EventCount);

    dPrice := dPrice + aLeg.Coeff * aLeg.Quote.Last;
  end;

  if (iQuoteCount > 0) and (iCalcCount = Count) then
  begin
    FCurrentPrice := dPrice;
    FQuoteCount := iQuoteCount;
  end;
end;

{ TTradeLegs }

procedure TTradeLegs.CalcAvgPrices;
var
  i: Integer;
  aLeg: TTradeLeg;
begin
  FPrevAvgPrice := 0.0;
  FLastAvgPrice := 0.0;

  for i := 0 to Count - 1 do
  begin
    aLeg := Items[i] as TTradeLeg;
    
    if aLeg.Position = nil then Continue;

    {
    if FPrevQty <> 0 then
      FPrevAvgPrice := FPrevAvgPrice + aLeg.Coeff * aLeg.Position.PrevAvgPrice;
    if FLastQty <> 0 then
      FLastAvgPrice := FLastAvgPrice + aLeg.Coeff * aLeg.Position.LastAvgPrice;
    }
  end;
end;

procedure TTradeLegs.Compose;
var
  i: Integer;
  iPrevQty, iPrevCount, iPrevValue: Integer;
  iLastQty, iLastCount, iLastValue: Integer;
  aLeg: TTradeLeg;
begin
  iPrevCount := 0;
  iPrevValue := 0;
  iLastCount := 0;
  iLastValue := 0;

  for i := 0 to Count - 1 do
  begin
    aLeg := Items[i] as TTradeLeg;

    if (aLeg.Position = nil) or (aLeg.Coeff = 0) then
    begin
      iPrevQty := 0;
      iLastQty := 0;
    end else
    begin
    {
      iPrevQty := (aLeg.Position.PrevQty
                   - aLeg.Position.PrevClaimedQty) div aLeg.Coeff;
      iLastQty := (aLeg.Position.LastQty
                   - aLeg.Position.LastClaimedQty) div aLeg.Coeff;
      }
    end;

      // Previous Qty

    Inc(iPrevCount);

    if iPrevCount = 1 then
      iPrevValue := iPrevQty
    else
    begin
      if (iPrevValue < 0) and (iPrevQty < 0) then
        iPrevValue := Max(iPrevValue, iPrevQty)
      else if (iPrevValue > 0) and (iPrevQty > 0) then
        iPrevValue := Min(iPrevValue, iPrevQty)
      else
        iPrevValue := 0;
    end;

      // Last Qty

    Inc(iLastCount);

    if iLastCount = 1 then
      iLastValue := iLastQty
    else
    begin
      if (iLastValue < 0) and (iLastQty < 0) then
        iLastValue := Max(iLastValue, iLastQty)
      else if (iLastValue > 0) and (iLastQty > 0) then
        iLastValue := Min(iLastValue, iLastQty)
      else
        iLastValue := 0;
    end;
  end;

    // set trade volume
  FPrevQty := iPrevValue;
  FLastQty := iLastValue;

    // set avg prices
  if (FPrevQty <> 0) or (FLastQty <> 0) then
  begin
    FEntryDate := Now;
      // claim quantity form position
    for i := 0 to Count - 1 do
    begin
      aLeg := Items[i] as TTradeLeg;
      if aLeg.Position = nil then Break;

      {
      FEntryDate := Min(FEntryDate, aLeg.Position.EntryDate);

      aLeg.Position.PrevClaimedQty := aLeg.Position.PrevClaimedQty + aLeg.Coeff*FPrevQty;
      aLeg.Position.LastClaimedQty := aLeg.Position.LastClaimedQty + aLeg.Coeff*FLastQty;
      }
    end;
      //
    CalcAvgPrices;
  end else
  begin
    FPrevAvgPrice := 0.0;
    FLastAvgPrice := 0.0;
    FEntryDate := 0.0;
  end;
end;


{ TTradeSpreadLegs }

constructor TTradeSpreadLegs.Create;
begin
  inherited Create(TTradeSpreadLeg);
end;

function TTradeSpreadLegs.GetLeg(i: Integer): TTradeSpreadLeg;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TTradeSpreadLeg
  else
    Result := nil;
end;

function TTradeSpreadLegs.AddLeg(iCoeff: Integer;
  stSymbol: String): TTradeSpreadLeg;
begin
  Result := Add as TTradeSpreadLeg;
  Result.FCoeff := iCoeff;
  Result.FSymbol := stSymbol;
  Result.FPosition := nil;
end;

{ TTradeLegList }

function TTradeLegList.GetLeg(i: Integer): TTradeLeg;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TTradeSpreadLeg(Items[i]) 
  else
    Result := nil;
end;

{ TTrade }

procedure TTrade.SetStopPrice(const Value: String);
begin
  FStopPriceStr := Trim(Value);
  FStopPrice := StrToFrac(FStopPriceStr);
end;

procedure TTrade.SetSymbol(const Value: String);
var
  i, iSpaceCnt, iCoeff: Integer;
  stToken: String;
begin
  FSymbol := UpperCase(Trim(Value));

  FFlatLegs.Clear;
  FSpreadLegs.Clear;

    // parsing and generate FLAT leg

  stToken := '';
  iSpaceCnt := 0;
  iCoeff := 1;

  for i := 0 to Length(Value) do
  case Value[i] of
    '-', '+' : // symbol separator
      begin
        iSpaceCnt := 0;
        stToken := Trim(stToken);
        if Length(stToken) > 0 then
        begin
          FLegs.Add(FFlatLegs.AddLeg(iCoeff, stToken));
          stToken := '';
        end;
          //
        if Value[i] = '-' then
          iCoeff := -1
        else
          iCoeff := 1;
      end;
    '*': // coeff separator
      begin
        iSpaceCnt := 0;
        stToken := Trim(stToken);
        if Length(stToken) > 0 then
        begin
          iCoeff := iCoeff * StrToIntDef(stToken, 1);
          stToken := '';
        end;
      end;
    ' ':
      begin
        Inc(iSpaceCnt);
        if (iSpaceCnt = 1) and (Length(stToken) > 0) then
          stToken := stToken + Value[i];
      end;
    else
      begin
        iSpaceCnt := 0;
        stToken := stToken + Value[i];
      end;
  end;
    //
  stToken := Trim(stToken);
  if Length(stToken) > 0 then
    FLegs.Add(FFlatLegs.AddLeg(iCoeff, stToken));

    // generate SPREAD leg
  if FFlatLegs.IsSpread then
  begin
    case FFlatLegs.Count of
      2: // 2 legs spread (A-B)
        if (FFlatLegs[0].Coeff = 1) and (FFlatLegs[1].Coeff = -1) then
          FLegs.Add(
            FSpreadLegs.AddLeg(1, FFlatLegs[0].Symbol + '-' + FFlatLegs[1].Symbol));
      3: // 3 legs sprerad, butterfly (A-2*B+C)
        if (FFlatLegs[0].Coeff = 1)
           and (FFlatLegs[1].Coeff = -2)
           and (FFlatLegs[2].Coeff = 1) then
        begin
          FLegs.Add(
            FSpreadLegs.AddLeg(1, FFlatLegs[0].Symbol + '-' + FFlatLegs[1].Symbol));
          FLegs.Add(
            FSpreadLegs.AddLeg(-1, FFlatLegs[1].Symbol + '-' + FFlatLegs[2].Symbol));
        end;
      4: // 4 legs, (A-B-C+D)
        if (FFlatLegs[0].Coeff = 1) and (FFlatLegs[1].Coeff = -1)
           and (FFlatLegs[2].Coeff = -1) and (FFlatLegs[3].Coeff = 1)  then
        begin
          FLegs.Add(
            FSpreadLegs.AddLeg(1, FFlatLegs[0].Symbol + '-' + FFlatLegs[1].Symbol));
          FLegs.Add(
            FSpreadLegs.AddLeg(-1, FFlatLegs[2].Symbol + '-' + FFlatLegs[3].Symbol));
        end;
    end;
  end;
end;

procedure TTrade.Compose;
begin
    // compose
  FFlatLegs.Compose;
  FSpreadLegs.Compose;

    // summary
  FPrevQty := FFlatLegs.PrevQty + FSpreadLegs.PrevQty;
  if FPrevQty <> 0 then
    FPrevAvgPrice := (FFlatLegs.PrevQty * FFlatLegs.PrevAvgPrice
                     + FSpreadLegs.PrevQty * FSpreadLegs.PrevAvgPrice) / FPrevQty
  else
    FPrevAvgPrice := 0.0;

  FLastQty := FFlatLegs.LastQty + FSpreadLegs.LastQty;
  if FLastQty <> 0 then
    FLastAvgPrice := (FFlatLegs.LastQty * FFlatLegs.LastAvgPrice
                     + FSpreadLegs.LastQty * FSpreadLegs.LastAvgPrice) / FLastQty
  else
    FLastAvgPrice := 0.0;

  if (FFlatLegs.EntryDate < 1.0) and (FSpreadLegs.EntryDate < 1.0) then
    FEntryDate := 0.0
  else if (FFlatLegs.EntryDate > 1.0) and (FSpreadLegs.EntryDate > 1.0) then
    FEntryDate := Min(FFlatLegs.EntryDate, FSpreadLegs.EntryDate)
  else if FFlatLegs.EntryDate > 1.0 then
    FEntryDate := FFlatLegs.EntryDate
  else
    FEntryDate := FSpreadLegs.EntryDate;
end;

constructor TTrade.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  //FComments := TPlannerComments.Create;
  FFlatLegs := TTradeFlatLegs.Create;
  FSpreadLegs := TTradeSpreadLegs.Create;
  FLegs := TTradeLegList.Create;

  FAlertCount := 0;
end;

destructor TTrade.Destroy;
begin
  FLegs.Free;
  FSpreadLegs.Free;
  FFlatLegs.Free;
  //FComments.Free;

  inherited;
end;

function TTrade.DoQuote(aQuote: TQuote): Boolean;
var
  i: Integer;
  dPriceDiff: Double;
begin
  Result := False;
  FAlert := False;

  for i := 0 to FFlatLegs.Count - 1 do
  begin
    if FFlatLegs[i].Quote = aQuote then
    begin
      FOldPrice := FFlatLegs.CurrentPrice;

      FFlatLegs.CalcCurrentPrice;

      FAlertMsg := '';
      FAlert := CheckAlert;

      Result := True;
      Break;
    end;
  end;

  if Result and (FFlatLegs.QuoteCount > 0) then
  begin
    dPriceDiff := FFlatLegs.CurrentPrice - FLastAvgPrice;

    if FContractSpec <> nil then
    begin
      FUnrealizedPL := FLastQty * dPriceDiff * FContractSpec.PointValue;
    end else
    begin
      FUnrealizedPL := FLastQty * dPriceDiff * 1.0;
    end;
  end;
end;

function TTrade.GetQuoteCount: Integer;
begin
  Result := FFlatLegs.QuoteCount;
end;

function TTrade.GetCaption: String;
begin
  if Length(FDescription) > 0 then
    Result := FDescription
  else
    Result := FSymbol;
end;

function TTrade.GetCurrentPrice: Double;
begin
  Result := FFlatLegs.CurrentPrice;
end;

function TTrade.GetDaysBeforeExit: Integer;
begin
  if FExitDate > 1.0 then
    Result := Floor(FExitDate) - Floor(Date)
  else
    Result := 0;
end;

function TTrade.GetDaysInPosition: Integer;
begin
  if FEntryDate > 1.0 then
    Result := Floor(Date) - Floor(FEntryDate)
  else
    Result := 0;
end;

procedure TTrade.SetTargetPrice(const Value: String);
begin
  FTargetPriceStr := Trim(Value);
  FTargetPrice := StrToFrac(FTargetPriceStr);
end;

function TTrade.ShortDesc(iLen: Integer): String;
begin
  if Length(FDescription) <= iLen then
    Result := FDescription
  else
    Result := Copy(FDescription, 1, iLen) + '...';
end;

function TTrade.CheckAlert: Boolean;
var
  dNewPrice: Double;
begin
  Result := False;

  if FFlatLegs.QuoteCount > 1 then
  begin
    Inc(FAlertCount);
    if FAlertCount <= 1 then Exit;

    dNewPrice := FFlatLegs.CurrentPrice;

    if FLastQty > 0 then
    begin
      if (Length(FTargetPriceStr) > 0) and
         (FOldPrice < FTargetPrice - 1.0e-10) and
         (dNewPrice > FTargetPrice - 1.0e-10) then
      begin
        FAlertMsg := 'Target Price reached';
        Result := True;
      end else
      if (Length(FStopPriceStr) > 0) and
         (FOldPrice > FStopPrice + 1.0e-10) and
         (dNewPrice < FStopPrice + 1.0e-10) then
      begin
        FAlertMsg := 'Stop Price reached';
        Result := True;
      end;
    end
    else if FLastQty < 0 then
    begin
      if (Length(FStopPriceStr) > 0) and
         (FOldPrice < FStopPrice - 1.0e-10) and
         (dNewPrice > FStopPrice - 1.0e-10) then
      begin
        FAlertMsg := 'Stop Price reached';
        Result := True;
      end else
      if (Length(FTargetPriceStr) > 0) and
         (FOldPrice > FTargetPrice + 1.0e-10) and
         (dNewPrice < FTargetPrice + 1.0e-10) then
      begin
        FAlertMsg := 'Target Price reached';
        Result := True;
      end;
    end;
  end;
end;

{ TTrades }

constructor TTrades.Create;
begin
  inherited Create(TTrade);
end;

function TTrades.FindTrade(stSymbol: String): TTrade;
var
  i: Integer;
begin
  Result := nil;
  //stSymbol := RegulateCode(stSymbol);

  for i := 0 to Count - 1 do
    if CompareStr(GetTrade(i).Symbol, stSymbol) = 0 then
    begin
      Result := GetTrade(i);
      Break;
    end;
end;

function TTrades.GetTrade(stSymbol: String): TTrade;
begin
  Result := FindTrade(stSymbol);
  if Result = nil then
    Result := AddTrade(stSymbol);
end;

function TTrades.GetPL: Double;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to Count - 1 do
    Result := Result + GetTrade(i).UnrealizedPL;
end;


procedure TTrades.PopulateList(aList: TStrings);
var
  i: Integer;
  aTrade: TTrade;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aTrade := GetTrade(i);
    aList.AddObject(aTrade.Caption, aTrade);
  end;
end;

procedure TTrades.PurgeWithNoPositions;
var
  i: Integer;
begin
  for i := Count-1 downto 0 do
    if GetTrade(i).LastQty = 0 then
      GetTrade(i).Free;
end;

function TTrades.GetTrade(i: Integer): TTrade;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TTrade
  else
    Result := nil;
end;

function TTrades.AddTrade(stSymbol: String): TTrade;
begin
  //stSymbol := RegulateCode(stSymbol);
  Result := Add as TTrade;
  Result.SetSymbol(stSymbol);
end;

function TTrades.AddTrade(aPosition: TPosition): TTrade;
begin
  Result := nil;

  {
    // it's already there
  if FindTrade(aPosition.SymbolCode) <> nil then Exit;

  Result := GetTrade(aPosition.SymbolCode);

  Result.Description := aPosition.SymbolCode;
  Result.ExitDate := Now;
  }
   {
  if (aPosition.Commodity <> nil)
     and (Result.FlatLegs.Count > 1) then
  begin
    if aPosition.LastQty > 0 then
    begin
      Result.StopPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             - aPosition.Commodity.SpreadATR]);
      Result.TargetPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             + aPosition.Commodity.SpreadATR])
    end
    else if aPosition.LastQty < 0 then
    begin
      Result.StopPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             + aPosition.Commodity.SpreadATR]);
      Result.TargetPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             - aPosition.Commodity.SpreadATR])
    end;
  end else
  begin
    if aPosition.LastQty > 0 then
    begin
      Result.StopPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             - aPosition.Commodity.FlatATR]);
      Result.TargetPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             + aPosition.Commodity.FlatATR])
    end
    else if aPosition.LastQty < 0 then
    begin
      Result.StopPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             + aPosition.Commodity.FlatATR]);
      Result.TargetPriceStr
         := Format('%.4f', [aPosition.LastAvgPrice
                             - aPosition.Commodity.FlatATR])
    end;
  end;
  }
end;

{
function TTrades.Compare(aItem1, aItem2: TCollectionItem;
  aSortIndex: Integer): Integer;
var
  Trade1: TTrade absolute aItem1;
  Trade2: TTrade absolute aItem2;
begin
  case aSortIndex of
    SORT_DESC:   Result := CompareStr(Trade1.Description, Trade2.Description);
    SORT_SYMBOL: Result := CompareStr(Trade1.Symbol, Trade2.Symbol);
    SORT_QTY:    Result := Trade1.LastQty - Trade2.LastQty;
    SORT_PL:     Result := Round(Trade1.UnrealizedPL - Trade2.UnrealizedPL);
    else
      Result := 0;
  end;
end;
}

end.

