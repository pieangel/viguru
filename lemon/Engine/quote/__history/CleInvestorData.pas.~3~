unit CleInvestorData;

interface

uses
  Classes;

type
{ InvestorID
  1000								증권회사 및 선물회사
  1200								보험회사
  3000								"자산운용회사및 투자회사"
  4000								"은행(자산운용회사의신탁재산은자산운용회사로 분류)
  5000								종금, 저축은행
  6000								연, 기금
  7000								"국가, 지방자치단체및 국제기구"
  7100								기타법인
  8000								개인
  9000								비거주외국인
  9999								전체
}

  TInvestorData = class(TCollectionItem)
  private
    FInvestorID : string;
    FCallPut : string;
    FAskQty : integer;
    FBidQty : integer;
    FAskAmount : double;             //단위 백만원
    FBidAmount : double;
    FSumQty : integer;
    FSumAmount : double;
    FMaxSumQty: integer;
    FMinSumQty: integer;
    FMaxSumAmt: double;
    FMinSumAmt: double;
  public
    property AskQty : integer read FAskQty write FAskQty;
    property BidQty : integer read FBidQty write FBidQty;
    property AskAmount : double read FAskAmount write FAskAmount;
    property BidAmount : double read FBidAmount write FBidAmount;
    property InvestorID : string read FInvestorID write FInvestorID;
    property CallPut : string read FCallPut write FCallPut;
    property SumQty : integer read FSumQty write FSumQty;
    property SumAmount : double read FSumAmount write FSumAmount;

    // add by sauri 2014.09.24
    property MaxSumQty : integer read FMaxSumQty write FMaxSumQty;
    property MinSumQty : integer read FMinSumQty write FMinSumQty;
    property MaxSumAmt : double read FMaxSumAmt write FMaxSumAmt;
    property MinSumAmt : double read FMinSumAmt write FMinSumAmt;
  end;

  TInvestorDatas = class(TCollection)
  private

  public
    constructor Create;
    Destructor Destroy; override;
    function New(stID, stCP : string) : TInvestorData;
    function Find(stID, stCP : string): TInvestorData;
  end;

implementation

{ TInvestorDatas }

constructor TInvestorDatas.Create;
begin
  inherited Create(TInvestorData);
end;

destructor TInvestorDatas.Destroy;
begin

  inherited;
end;

function TInvestorDatas.Find(stID, stCP : string): TInvestorData;
var
  i: Integer;
  aItem : TInvestorData;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TInvestorData;
    if (aItem.FInvestorID = stID) and (aItem.FCallPut = stCP) then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function TInvestorDatas.New(stID, stCP : string): TInvestorData;
begin
  Result := Find(stID, stCP);
  if Result = nil then
  begin
    Result := Add as TInvestorData;
    Result.FInvestorID := stID;
    Result.FCallPut := stCP;

    Result.MaxSumQty  := 0;
    Result.MinSumQty  := 0;
    Result.MaxSumAmt  := 0;
    Result.MinSumAmt  := 0;
  end;
end;

end.
