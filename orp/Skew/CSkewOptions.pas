unit CSkewOptions;

interface

uses
  Classes,

    // lemon: data
  CleSymbols, CleMarkets, CleQuoteBroker,
    // lemon: imports
  CalcGreeks,
    // Skew
  CSkewConsts;

type
  TSkewBranch = class(TCollectionItem)
  private
    FStrikePrice: Double;
    FCall: TOption;
    FPut: TOption;
  public
    IVs: array[0..1,0..2] of Double;
    IVDiffs: array[0..1,0..2] of Double;

    procedure CalcIVs(U, T, TC: Double; aQuote: TQuote);
    procedure Reset;

    property StrikePrice: Double read FStrikePrice;
    property Call: TOption read FCall;
    property Put: TOption read FPut;
  end;

  TSkewTree = class(TCollection)
  private
    FOnQuote: TQuoteEvent;
    
    function GetBranch(i: Integer): TSkewBranch;
  public
    constructor Create;

    procedure SetTree(aTree: TOptionTree);
    function Find(aOption: TOption): TSkewBranch;

    property Branches[i:Integer]: TSkewBranch read GetBranch;
    property OnQuote: TQuoteEvent read FOnQuote write FOnQuote;
  end;

implementation

{ TSkewBranch }

procedure TSkewBranch.CalcIVs(U, T, TC: Double; aQuote: TQuote);
var
  W: Double;
  iCallPut: Integer;
  aOption: TOption;
begin
  if aQuote = nil then Exit;

  if aQuote.Symbol = FCall then
  begin
    W := 1;
    iCallPut := IDX_CALL;
    aOption := FCall;
  end else
  if aQuote.Symbol = FPut then
  begin
    W := -1;
    iCallPut := IDX_PUT;
    aOption := FPut;
  end else
    Exit;

  if aOption <> nil then
  begin
      // ask
    if (aQuote.Asks.Count > 0) and (aQuote.Asks[0].Price > 1.0e-10) then
      IVs[iCallPut, IDX_ASK] := CalcGreeks.IV(U, aOption.StrikePrice,
                                              aOption.CDRate, T, TC,
                                              aQuote.Asks[0].Price, W);
      // bid
    if (aQuote.Bids.Count > 0) and (aQuote.Bids[0].Price > 1.0e-10) then
      IVs[iCallPut, IDX_BID] := CalcGreeks.IV(U, aOption.StrikePrice,
                                              aOption.CDRate, T, TC,
                                              aQuote.Bids[0].Price, W);
      // fill
    if aOption.Last > 1.0e-10 then
      IVs[iCallPut, IDX_FILL] := CalcGreeks.IV(U, aOption.StrikePrice,
                                               aOption.CDRate, T, TC,
                                               aOption.Last, W);
  end;
end;


procedure TSkewBranch.Reset;
var
  i, j: Integer;
begin
  for i := 0 to 1 do
    for j := 0 to 2 do
    begin
      IVs[i,j] := 0.0;
      IVDiffs[i,j] := 0.0;
    end;
end;

{ TSkewTree }

constructor TSkewTree.Create;
begin
  inherited Create(TSkewBranch);
end;

function TSkewTree.Find(aOption: TOption): TSkewBranch;
var
  i: Integer;
  aBranch: TSkewBranch;
begin
  Result := nil;

  for i := 0 to Count-1 do
  begin
    aBranch := GetBranch(i);

    if (aBranch.FCall = aOption) or (aBranch.FPut = aOption) then
    begin
      Result := aBranch;
      Break;
    end;
  end;
end;

function TSkewTree.GetBranch(i: Integer): TSkewBranch;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSkewBranch
  else
    Result := nil;
end;

procedure TSkewTree.SetTree(aTree: TOptionTree);
var
  i: Integer;
  aBranch: TSkewBranch;
begin
  if aTree = nil then Exit;

  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aBranch := Add as TSkewBranch;

    aBranch.FStrikePrice := aTree.Strikes[i].StrikePrice;
    aBranch.FCall := aTree.Strikes[i].Call;
    aBranch.FPut := aTree.Strikes[i].Put;

    aBranch.Reset;
  end;
end;

end.
