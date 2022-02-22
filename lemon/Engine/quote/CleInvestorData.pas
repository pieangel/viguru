unit CleInvestorData;

interface

uses
  Classes;

type
{ InvestorID
  1000								����ȸ�� �� ����ȸ��
  1200								����ȸ��
  3000								"�ڻ���ȸ��� ����ȸ��"
  4000								"����(�ڻ���ȸ���ǽ�Ź������ڻ���ȸ��� �з�)
  5000								����, ��������
  6000								��, ���
  7000								"����, ������ġ��ü�� �����ⱸ"
  7100								��Ÿ����
  8000								����
  9000								����ֿܱ���
  9999								��ü
}

  TInvestorData = class(TCollectionItem)
  private
    FInvestorID : string;
    FCallPut : string;
    FAskQty : integer;
    FBidQty : integer;
    FAskAmount : double;             //���� �鸸��
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
    // -- �ɼ�
    // ����
    FCallPerson : TInvestorData;
    FPutPerson  : TInvestorData;
    // ����
    FCallFinance: TInvestorData;
    FPutFinance : TInvestorData;
    // ����
    FCallForeign: TInvestorData;
    FPutForeign : TInvestorData;
    // -- �ɼ�
    // -- ����
    FFutForeign : TInvestorData;
  public
    constructor Create;
    Destructor Destroy; override;

    function New(stID, stCP : string) : TInvestorData;
    function Find(stID, stCP : string): TInvestorData;

    function GetTojaja( stCode : string) : double;
    function GetToSun: integer;
    function GetToSinglejaja( stCode : string) : double;

    property CallPerson : TInvestorData read FCallPerson;
    property PutPerson  : TInvestorData read FPutPerson;

    property CallFinance: TInvestorData read FCallFinance;
    property PutFinance : TInvestorData read FPutFinance;

    property CallForeign: TInvestorData read FCallForeign;
    property PutForeign : TInvestorData read FPutForeign;
    property FutForeign : TInvestorData read FFutForeign;

  end;

implementation

uses
  GleConsts
  ;

{ TInvestorDatas }

constructor TInvestorDatas.Create;
begin
  inherited Create(TInvestorData);

  FCallPerson := nil;
  FPutPerson  := nil;
  FCallFinance:= nil;
  FPutFinance := nil;
  FCallForeign:= nil;
  FPutForeign := nil;
  FFutForeign := nil;
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

function TInvestorDatas.GetTojaja( stCode : string): double;
var
  dSum1 , dSum2 : double;
  aData1, aData2 : TInvestorData;
begin
  Result := 0;

  if stCode = INVEST_FINANCE then
  begin
    aData1  := FCallFinance;
    aData2  := FPutFinance;
  end else
  if stCode = INVEST_FORIN then
  begin
    aData1  := FCallForeign;
    aData2  := FPutForeign;
  end else
    Exit;

  if ( FPutPerson = nil ) or ( FCallPerson = nil ) or
     ( aData1 = nil ) or ( aData2 = nil ) then
    Exit
  else begin
    dSum1   := FPutPerson.SumAmount - FCallPerson.SumAmount;
    dSum2   := aData1.SumAmount - aData2.SumAmount;
    Result  := dSum1 + dSum2;
  end;

end;

function TInvestorDatas.GetToSinglejaja(stCode: string): double;
var
  dSum1 , dSum2 : double;
  aData1, aData2 : TInvestorData;
begin
  Result := 0;

  if stCode = INVEST_FINANCE then
  begin
    aData1  := FCallFinance;
    aData2  := FPutFinance;
  end else
  if stCode = INVEST_FORIN then
  begin
    aData1  := FCallForeign;
    aData2  := FPutForeign;
  end else
    Exit;

  if ( aData1 = nil ) or ( aData2 = nil ) then
    Exit
  else
    Result  := aData1.SumAmount - aData2.SumAmount;
end;

function TInvestorDatas.GetToSun: integer;
begin
  Result := 0;
  if FFutForeign <> nil then
    Result := FFutForeign.SumQty;
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

  // ����
  if FCallPerson = nil then
    if ( stID = INVEST_PERSON ) and ( stCP = 'C' ) then
      FCallPerson := Result;

  if FPutPerson = nil then
    if ( stID = INVEST_PERSON ) and ( stCP = 'P' ) then
      FPutPerson := Result;


  if FCallFinance = nil then
    if ( stID = INVEST_FINANCE ) and ( stCP = 'C' ) then
      FCallFinance := Result;

  if FPutFinance = nil then
    if ( stID = INVEST_FINANCE ) and ( stCP = 'P' ) then
      FPutFinance := Result;


  if FCallForeign = nil then
    if ( stID = INVEST_FORIN ) and ( stCP = 'C' ) then
      FCallForeign := Result;

  if FPutForeign = nil then
    if ( stID = INVEST_FORIN ) and ( stCP = 'P' ) then
      FPutForeign := Result;


  if FFutForeign = nil then
    if ( stID = INVEST_FORIN ) and ( stCP = 'F' ) then
      FFutForeign := Result;

end;

end.