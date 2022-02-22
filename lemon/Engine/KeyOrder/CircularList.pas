unit CircularList;


interface

uses
  CleSymbols, Gletypes, CleQuoteBroker,
  KOrderConst,  SysUtils;

type
  TCircularList = class
  private
    FDatas : array of TSimpleSymbol;
    FArraySize : Integer;
    FStart : Integer;
    FEnd : Integer;
    FIndex : Integer;

    function GetSize: Integer;

    function GetData(iIndex: Integer): TSimpleSymbol;
    function GetSimpleSymbol: TSimpleSymbol;

  public
    constructor Create(iSize:Integer);
    destructor Destroy; override;

    function Dump : String;

    procedure Add(aData : TSymbol);

    property Size : Integer read GetSize;
    property EndIndex : Integer read FEnd;
    property StartIndex : Integer read FStart;
    property Item[iIndex: Integer] : TSimpleSymbol read GetData; default;
    property Symbol : TSimpleSymbol read GetSimpleSymbol;
  end;

implementation

{ TCircularList }

constructor TCircularList.Create(iSize: Integer);
begin
  FArraySize := iSize;
  SetLength(FDatas, FArraySize);
  FStart := -1;
  FEnd := -1;
  FIndex := -1;
end;

destructor TCircularList.Destroy;
begin

  inherited;
end;

procedure TCircularList.Add(aData: TSymbol);
var
  i : Integer;
begin
  if FStart = -1 then  // no data
  begin
    FStart := 0;
    FEnd := 0;
  end
  else
  begin
    FEnd := (FEnd+1) mod FArraySize;
    if FEnd = FStart then // data full
      FStart := (FStart+1) mod FArraySize;
  end;

  with FDatas[FEnd] do
  begin
    // 종목에서 사용할 데이터들만 input
    Code := aData.Code;
    Precision := aData.Spec.Precision;
    C := aData.Last;
    RecvTime := Now;

    Quote.Assign( aData.Quote as TQuote);

  end;
end;

function TCircularList.GetData(iIndex: Integer): TSimpleSymbol;
var
  iDataIndex : Integer;
begin
  iDataIndex := (FStart+iIndex) mod FArraySize;
  Result := FDatas[iDataIndex];
end;

function TCircularList.GetSize: Integer;
begin
  if FStart = -1 then Result := 0
  else Result := (FEnd-FStart + FArraySize) mod FArraySize + 1;
end;

function TCircularList.GetSimpleSymbol: TSimpleSymbol;
begin
  Result := FDatas[FStart];
end;

function TCircularList.Dump: String;
var
  i : Integer;
begin
  Result := 'Queue Dump : ';

  for i:= 0 to GetSize-1 do
    Result := Result + Format('[%d,%s,%.2f/%.2f]' ,
                [i,
                 FormatDateTime('nn:ss.zzz', GetData(i).RecvTime),
                 GetData(i).Quote.Asks[0].Price,
                 GetData(i).Quote.Bids[0].Price ]);
end;

end.
