unit CleTradingSystems;

interface

uses
  Classes, Sysutils,

  CleMarketSpecs;

type
  TTradingSystem = class(TCollectionItem)
  private
    FSeq: Integer;
    FStrategy: String;
    FContract: String;
    FSpec: TMarketSpec;
    FRanking: Double;
    FDollarRisk: Double;
    FMargin: Double;
    FStdev: Double;
    FATR: Double;
  public
    function Represent: String;
    
    property Seq: Integer read FSeq write FSeq;
    property Strategy: String read FStrategy write FStrategy;
    property Contract: String read FContract write FContract;
    property Spec: TMarketSpec read FSpec write FSpec;
    property Ranking: Double read FRanking write FRanking;
    property DollarRisk: Double read FDollarRisk write FDollarRisk;
    property Margin: Double read FMargin write FMargin;
    property Stdev: Double read FStdev write FStdev;
    property ATR: Double read FATR write FATR;
  end;

  TTradingSystems = class(TCollection)
  public
    constructor Create;

    function New: TTradingSystem;
    function FindSeq(iSeq: Integer): TTradingSystem;
    function FindFirstSpec(aSpec: TMarketSpec): TTradingSystem;
    procedure GetList(aList: TStrings);

    function Represent: String;
  end;

implementation

{ TTradingSystem }

function TTradingSystem.Represent: String;
begin
  Result := Format('(%s,%s,%s,%.2f,%.0f,%.0f,%.2f,%.2f)',
                    [FStrategy, FContract, FSpec.FQN,
                     FRanking, FDollarRisk, FMargin, FStdev, FATR]);
end;

{ TTradingSystems }

constructor TTradingSystems.Create;
begin
  inherited Create(TTradingSystem);
end;

function TTradingSystems.New: TTradingSystem;
begin
  Result := Add as TTradingSystem;
end;

function TTradingSystems.FindSeq(iSeq: Integer): TTradingSystem;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if (Items[i] as TTradingSystem).FSeq = iSeq then
    begin
      Result := Items[i] as TTradingSystem;
      Break;
    end;
end;

function TTradingSystems.FindFirstSpec(aSpec: TMarketSpec): TTradingSystem;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if (Items[i] as TTradingSystem).FSpec = aSpec then
    begin
      Result := Items[i] as TTradingSystem;
      Break;
    end;
end;

procedure TTradingSystems.GetList(aList: TStrings);
var
  i: Integer;
  aSystem: TTradingSystem;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aSystem := Items[i] as TTradingSystem;
    aList.AddObject('('+ aSystem.Strategy + ') ' + aSystem.Contract, aSystem);
  end;

end;

function TTradingSystems.Represent: String;
var
  i: Integer;
begin
  Result := '(';
  for i := 0 to Count - 1 do
    Result := Result + (Items[i] as TTradingSystem).Represent;
  Result := Result + ')';
end;

end.
