unit CleAccounts;

// Copyright(C) Eight Pines Technologies, Inc. All Rights Reserved.

// Account Data Storage: It define the ACCOUNT object and storages of it

interface

uses
  Classes, SysUtils, GleConsts, CleFQN,

  GleTypes
  ;

const
  FACNT = 5;
  SACNT = 2;

type

  TPositionHis = record
    Time: TDateTime;
    AccountNo: string;
    TotPL: double; // 총손익
    EvalPL: double; // 평간손익
    Fee: double; // 수수료
    Etc: double; // 기타
  end;

  TPosTraceItem = class(TCollectionItem)
  public
    PositionHis: TPositionHis;
  end;

  TPosTraceItems = class(TCollection)
  private
    function GetPosTraceItem(i: integer): TPosTraceItem;
  public
    LastHis: TPositionHis;
    constructor Create;
    destructor Destroy; override;

    function New: TPosTraceItem;
    property PosTraceItems[i: integer]: TPosTraceItem read GetPosTraceItem;
  end;

  TLogData = record

  end;

  TAccount = class(TCollectionItem)
  private
    FCode: string;
    FAccountNo: string;
    FSubAccountNo: string; // used only in Korea
    FName: string;
    FNetLiq: Double;
    FAllocation: Double;
    FMarket: TMarketType;

    FDivision: integer;
    FPassWord: string;
    FInvestCode: string;
    FCountryCode: string;
    FBusinessCode: string;

    FAccountType: TAccountType;
    FBranchCode: string;
    FPosTrace: TPosTraceItems;
    FEmployeeNo: string;
    FShortCode: string;
    FDefAcnt: boolean;
    FInvestShortCode: string;
    FLogIdx: integer;
    FIsLog: boolean;
    FMinPL: double;
    FMaxPL: double;
    FMaxTime: TDateTime;
    FMinTime: TDateTime;
    FTag: integer; {
    FDeposit: double;
    FUnExcMargin: double;
    FOrderMargin: double;
    FHoldMargin: double;
    FAddMargin: double;
    FDepositOTE: double;
    FTrustMargin: double;
    FWonDaeAmt: double;
    FUnBackAmt: double;
    FFixedPL     : double;
    FLiquidPL: double; }

    function write: boolean;
    procedure SetInvestCode(const Value: string);

  public

    TradeAmt: array[TDerivativeType] of double;

    Fees: array[TDerivativeType] of Double; // 수수료

    RecoverFees: Double; // Recovery 수수료
    OpenPL: double;

    // 예수금 내역 ( 달러 )
    LiquidPL: double;
    FixedPL: double;
    Deposit: double; // 입금금액
    WonDaeAmt: double;
    DepositOTE: double; // 예탁자산평가액
    UnBackAmt: double; // 미수금액;
    EAbleAmt: double; // 주문가능금액

    TrustMargin: double; // 위탁증거금
    OrderMargin: double; // 주문증거금
    HoldMargin: double; // 유지증거금
    AddMargin: double; // 추가증거금
    MinMargin: double; // 최소증거금

    IsWriteFixedPL: boolean;

    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function Represet: string;

    function GetFee: double;
    procedure ApplyFill(aFill: TObject; iFillQty: Integer; dFillPrice: Double);
      overload;
    procedure ApplyFill(dtTime: TDateTime); overload;
    procedure RecalcMargin;
    procedure Reset;
    procedure Update(stCode, stName: string);
    procedure SetFixedPL(const Value: double);

    property Market: TMarketType read FMarket;
    property Code: string read FCode;
    property ShortCode: string read FShortCode;
    property Name: string read FName;
    property EmployeeNo: string read FEmployeeNo write FEmployeeNo;
    property PassWord: string read FPassWord write FPassWord;
    property NetLiq: Double read FNetLiq write FNetLiq;
    property Allocation: Double read FAllocation write FAllocation;
    property Division: integer read FDivision write FDivision;
    //
    property AccountType: TAccountType read FAccountType write FAccountType;
    property InvestCode: string read FInvestCode write SetInvestCode;
    property InvestShortCode: string read FInvestShortCode;
    property CountryCode: string read FCountryCode write FCountryCode;
    property BranchCode: string read FBranchCode write FBranchCode;
    //
    property DefAcnt: boolean read FDefAcnt write FDefAcnt;
    property PosTrace: TPosTraceItems read FPosTrace write FPosTrace;
    // only simul Log
    property LogIdx: integer read FLogIdx write FLogIdx;
    property Tag: integer read FTag write FTag;
  end;

  TAccountList = class(TStringList)
  private
    function GetAccount(i: Integer): TAccount;
  public
    function Represent: string;
    procedure AddAccount(aAccount: TAccount);
    procedure GetList(aList: TStrings);
    procedure GetList3(aList: TStrings);
    procedure GetList2(stList: TStrings);

    property Accounts[i: Integer]: TAccount read GetAccount; default;
    function Find(stCode: string): TAccount; overload;
    function Find(Market: integer): TAccount; overload;
    function Find2(stSymbolCode: string): TAccount;
  end;

  TAccounts = class(TCollection)
  private
    FPresentName: string;
    FPassword: string;
    function GetAccount(i: Integer): TAccount;
  public
    constructor Create;
    destructor Destroy; override;

    function New(stCode, stName: string; aMarket: TMarketType; pass: string =
      ''): TAccount; overload;
    function New(stCode, stName: string): TAccount; overload;
    function Find(stCode: string): TAccount; overload;
    function Find(Market: integer): TAccount; overload;
    function Find2(stSymbolCode: string): TAccount;

    procedure GetList(stList: TStrings);
    procedure GetList2(stList: TStrings);
    function DeleteAccount(aAcnt: TAccount): boolean;
    function GetMarketAccount(aMarket: TMarketType): TAccount; overload;
    function GetMarketAccount(aType: TAccountType): TAccount; overload;
    procedure GetMarketList(stList: TStrings; aMarket: TMarketType);
    function Represent: string;

    property Accounts[i: Integer]: TAccount read GetAccount; default;
    property PresentName: string read FPresentName write FPresentName;
    property Password: string read FPassword write FPassword;
  end;

  // Fund 전략용

  TInvestor = class(TAccount)
  private
    // 계좌들
    FAccounts: TAccounts;
    // 계 좌
    FRceAccount: TAccount;
    // 요청 여부
    FPosQueried: boolean;
    // 살아있는 주문 요청 여부
    FActOrdQueried: boolean;
    // 기록 계좌 가져오기
    function GetRecAccount: TAccount;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    property Accounts: TAccounts read FAccounts;
    property RceAccount: TAccount read GetRecAccount write FRceAccount;
    property PosQueried: boolean read FPosQueried write FPosQueried;
    property ActOrdQueried: boolean read FActOrdQueried write FActOrdQueried;
  end;

  TInvestors = class(TCollection)
  private
    //FRceAccount: TAccount;
    function GetInvestor(i: integer): TInvestor;
  public
    constructor Create;
    destructor Destroy; override;

    function New(stCode, stName: string; stPass: string = ''): TInvestor;
    function Find(stCode: string): TInvestor;
    function FindName(stName: string): TInvestor;
    function FindShort(stCode: string): TInvestor;
    function GetIndex(stCode: string): integer;
    procedure GetList(stList: TStrings);
    procedure GetList2(stList: TStrings);
    procedure Reset;

    property Investor[i: integer]: TInvestor read GetInvestor;
  end;

implementation

uses
  dateutils, CleFills, CleSymbols, GAppEnv;

{ TAccount }

procedure TAccount.ApplyFill(aFill: TObject; iFillQty: Integer;
  dFillPrice: Double);
var
  aFillItem: TFill;
  aSymbol: TSymbol;
  dtType: TDerivativeType;
begin
  //
  if aFill = nil then
    Exit;
  //-- get basic numbers
  aFillItem := aFill as TFill;
  aSymbol := aFillItem.Symbol;

  //-- 약정누적 : 단위 춴원
  if aSymbol.Spec.Market = mtFutures then
    dtType := dtFutures
  else if aSymbol.Spec.Market = mtOption then
    dtType := dtOptions
  else
    Exit;
  {
TradeAmt := TradeAmt[dt +
     abs(iFillQty) * dFillPrice * aSymbol.Spec.PointValue / 1000.0;
     }

end;

procedure TAccount.ApplyFill(dtTime: TDateTime);
var
  stTmp: string;
var
  aItem: TPosTraceItem;
  dPL, df, dopt, dS: double;

begin

  df := 0;
  dopt := 0;
  ds := 0;
  dPL := gEnv.Engine.TradeCore.Positions.GetMarketPl(self, df, dopt, ds);
  ds := GetFee / 1000;

  if dS <= 0 then
    Exit;

  //aItem := PosTrace.New;

  with PosTrace.LastHis do
  begin
    Time := dtTime;
    TotPL := dPL / 1000;
    EvalPL := 0;
    Fee := dS;
  end;

end;

constructor TAccount.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FDefAcnt := false;
  FLogIdx := -1;
  FIsLog := false;

  FMaxPL := 0;
  FMinPL := 1;

  IsWriteFixedPL := false;
  IsWriteFixedPL := false;

  FixedPL := 0;
  OpenPL := 0;

  Deposit := 0;
  MinMargin := 0;
  OrderMargin := 0;
  HoldMargin := 0;
  AddMargin := 0;
  DepositOTE := 0;
  TrustMargin := 0;
  EAbleAmt := 0;

end;

destructor TAccount.Destroy;
begin

  inherited;
end;

function TAccount.GetFee: double;
begin
  Result := Fees[dtFutures] + Fees[dtOptions] +
    RecoverFees;
end;

procedure TAccount.RecalcMargin;
begin
  //Fees[dtFutures] := TradeAmt[dtFutures] * gEnv.Fees.FFee;
  //Fees[dtOptions] := TradeAmt[dtOptions] * gEnv.Fees.OFee;
end;

function TAccount.Represet: string;
begin
  Result := Format('(%s,%s,%.2f)', [FCode, FName, FNetLiq]);
end;

procedure TAccount.Reset;
begin

  FIsLog := false;

  FMaxPL := 0;
  FMinPL := 1;
  FMaxTime := 0;
  FMinTime := 0;

  Fees[dtFutures] := 0;
  Fees[dtOptions] := 0;

  RecoverFees := 0;

  TradeAmt[dtFutures] := 0;
  TradeAmt[dtOptions] := 0;

end;

procedure TAccount.SetFixedPL(const Value: double);
begin
  if not IsWriteFixedPL then
  begin
    FixedPL := Value;
    LiquidPL := Value;
    IsWriteFixedPL := true;
  end
  else
    LiquidPL := Value;
end;

procedure TAccount.SetInvestCode(const Value: string);
begin
  FInvestCode := Value;
  FInvestShortCode := Copy(FInvestCode, 7, 6);
end;

procedure TAccount.Update(stCode, stName: string);
begin
  FCode := stCode;
  FName := stName;
  FShortCode := Copy(stCode, 7, 6);
end;

function TAccount.write: boolean;
begin

end;

{ TAccounts }

constructor TAccounts.Create;
begin
  inherited Create(TAccount);
end;

function TAccounts.Find(stCode: string): TAccount;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if CompareStr(GetAccount(i).Code, stCode) = 0 then
    begin
      Result := Items[i] as TAccount;
      Break;
    end;
end;

function TAccounts.DeleteAccount(aAcnt: TAccount): boolean;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    if aAcnt = GetAccount(i) then
    begin
      Delete(i);
      break;
    end;
end;

destructor TAccounts.Destroy;
begin
  inherited;
end;

function TAccounts.Find(Market: integer): TAccount;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if GetAccount(i).FDivision = Market then
    begin
      Result := Items[i] as TAccount;
      Break;
    end;

end;

function TAccounts.Find2(stSymbolCode: string): TAccount;
begin
  result := nil;
end;

function TAccounts.GetAccount(i: Integer): TAccount;
begin
  if (i >= 0) and (i <= Count - 1) then
    Result := Items[i] as TAccount
  else
    Result := nil;
end;

procedure TAccounts.GetList(stList: TStrings);
var
  i: Integer;
  aAccount: TAccount;
begin
  if stList = nil then
    Exit;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);
    stList.AddObject(aAccount.Code, aAccount);
  end;
end;

procedure TAccounts.GetList2(stList: TStrings);
var
  i: Integer;
  aAccount: TAccount;
begin
  if stList = nil then
    Exit;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);
    stList.AddObject(aAccount.Code + ' ' + aAccount.Name, aAccount);
  end;

end;

function TAccounts.GetMarketAccount(aMarket: TMarketType): TAccount;
var
  i: Integer;
  aAccount: TAccount;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);

    case aMarket of
      mtStock, mtBond, mtETF, mtELW:
        if aAccount.AccountType = atStock then
          Result := aAccount;

      mtFutures, mtOption, mtSpread:
        if aAccount.AccountType = atFO then
          Result := aAccount;
    end;

    if Result <> nil then
      Break;
  end;

end;

function TAccounts.GetMarketAccount(aType: TAccountType): TAccount;
var
  i: Integer;
  aAccount: TAccount;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);
    if aAccount.AccountType = aType then
    begin
      Result := aAccount;
      break;
    end;
  end;

end;

procedure TAccounts.GetMarketList(stList: TStrings; aMarket: TMarketType);
var
  i: Integer;
  aAccount: TAccount;
begin
  if stList = nil then
    Exit;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);

    case aMarket of
      mtStock, mtBond, mtETF, mtELW:
        if aAccount.AccountType = atStock then
          stList.AddObject(aAccount.Code, aAccount);

      mtFutures, mtOption, mtSpread:
        if aAccount.AccountType = atFO then
          stList.AddObject(aAccount.Code, aAccount);
    end;

  end;

end;

function TAccounts.New(stCode, stName: string): TAccount;
begin
  if stCode = '' then
  begin
    Result := nil;
    Exit;
  end;

  Result := Find(stCode);

  if Result = nil then
  begin
    Result := Add as TAccount;
    Result.FCode := stCode;
    //Result.FShortCode := Copy( stCode, 7, 6 );
    Result.FName := stName;
    Result.TradeAmt[dtFutures] := 0.0;
    Result.Fees[dtFutures] := 0.0;
    Result.TradeAmt[dtOptions] := 0.0;
    Result.Fees[dtOptions] := 0.0;
    Result.PosTrace := TPosTraceItems.Create;
    //gEnv.Engine.TradeCore.Accounts.AddAccount( Result );
  end;

end;

function TAccounts.New(stCode, stName: string; aMarket: TMarketType; pass:
  string): TAccount;
begin

  if stCode = '' then
  begin
    Result := nil;
    Exit;
  end;

  Result := Find(stCode);

  if Result = nil then
  begin
    Result := Add as TAccount;
    Result.FCode := stCode;
    Result.FName := stName;
    Result.FMarket := aMarket;
    Result.FPassWord := pass;

    Result.FShortCode := Copy(stCode, 7, 6);

    Result.TradeAmt[dtFutures] := 0.0;
    Result.Fees[dtFutures] := 0.0;
    Result.TradeAmt[dtOptions] := 0.0;
    Result.Fees[dtOptions] := 0.0;

    Result.PosTrace := TPosTraceItems.Create;

    gEnv.Engine.TradeCore.Accounts.AddAccount(Result);
  end;

end;

function TAccounts.Represent: string;
var
  i: Integer;
begin
  Result := '(';
  for i := 0 to Count - 1 do
    Result := Result + GetAccount(i).Represet;
  Result := Result + ')';
end;

{ TAccountList }

procedure TAccountList.AddAccount(aAccount: TAccount);
begin
  if (aAccount <> nil) and (IndexOfObject(aAccount) < 0) then
    AddObject(aAccount.Name, aAccount);
end;

function TAccountList.Find(stCode: string): TAccount;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if CompareStr(GetAccount(i).Code, stCode) = 0 then
    begin
      Result := Objects[i] as TAccount;
      Break;
    end;

end;

function TAccountList.Find(Market: integer): TAccount;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if GetAccount(i).FDivision = Market then
    begin
      Result := Objects[i] as TAccount;
      Break;
    end;

end;

function TAccountList.Find2(stSymbolCode: string): TAccount;
begin

end;

function TAccountList.GetAccount(i: Integer): TAccount;
begin
  if (i >= 0) and (i <= Count - 1) then
    Result := TAccount(Objects[i])
  else
    Result := nil;
end;

procedure TAccountList.GetList(aList: TStrings);
var
  i: Integer;
  aAccount: TAccount;
begin
  if aList = nil then
    Exit;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);
    aList.AddObject(aAccount.Name, aAccount);
  end;
end;

procedure TAccountList.GetList2(stList: TStrings);
var
  i: Integer;
  aAccount: TAccount;
begin
  if stList = nil then
    Exit;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);
    stList.AddObject(aAccount.Code + ' ' + aAccount.Name, aAccount);
  end;
end;

procedure TAccountList.GetList3(aList: TStrings);
var
  i: Integer;
  aAccount: TAccount;
begin
  if aList = nil then
    Exit;

  for i := 0 to Count - 1 do
  begin
    aAccount := GetAccount(i);
    aList.AddObject(aAccount.Code, aAccount);
  end;

end;

function TAccountList.Represent: string;
var
  i: Integer;
begin
  Result := '(';

  for i := 0 to Count - 1 do
    if i > 0 then
      Result := Result + ',' + GetAccount(i).Code
    else
      Result := Result + GetAccount(i).Code;

  Result := Result + ')';
end;

{ TPosTraceItems }

constructor TPosTraceItems.Create;
begin
  inherited Create(TPosTraceItem);
end;

destructor TPosTraceItems.Destroy;
begin

  inherited;
end;

function TPosTraceItems.GetPosTraceItem(i: integer): TPosTraceItem;
begin
  if (i < 0) or (i >= Count) then
    Result := nil
  else
    Result := Items[i] as TPosTraceItem;
end;

function TPosTraceItems.New: TPosTraceItem;
begin
  Result := Add as TPosTraceItem;
end;

{ TInvestors }

{ TInvestor }

constructor TInvestor.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FAccounts := TAccounts.Create;
  FRceAccount := nil;

  FPosQueried := false;
  FActOrdQueried := false;
end;

destructor TInvestor.Destroy;
begin
  FAccounts.Free;
  inherited;
end;

function TInvestor.GetRecAccount: TAccount;
begin
  Result := FRceAccount;
end;

{ TInvetstors }

function TInvestors.New(stCode, stName: string; stPass: string): TInvestor;
begin

  if Find(stCode) = nil then
  begin
    Result := Add as TInvestor;
    Result.FCode := stCode;
    Result.FName := stName;
    Result.FInvestCode := stCode;
    Result.PassWord := stPass;

    Result.TradeAmt[dtFutures] := 0.0;
    Result.Fees[dtFutures] := 0.0;
    Result.TradeAmt[dtOptions] := 0.0;
    Result.Fees[dtOptions] := 0.0;
    Result.PosTrace := TPosTraceItems.Create;
  end;
end;

procedure TInvestors.Reset;
var
  I, j: Integer;
begin
  for I := 0 to Count - 1 do
    for j := 0 to GetInvestor(i).Accounts.Count - 1 do
      GetInvestor(i).Accounts.Accounts[j].Reset;
end;

constructor TInvestors.Create;
begin
  inherited Create(TInvestor);
end;

destructor TInvestors.Destroy;
begin

  inherited;
end;

function TInvestors.Find(stCode: string): TInvestor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetInvestor(i).Code = stCode then
    begin
      Result := GetInvestor(i);
      break;
    end;
end;

function TInvestors.FindName(stName: string): TInvestor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetInvestor(i).Name = stName then
    begin
      Result := GetInvestor(i);
      break;
    end;

end;

function TInvestors.FindShort(stCode: string): TInvestor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetInvestor(i).ShortCode = stCode then
    begin
      Result := GetInvestor(i);
      break;
    end;
end;

function TInvestors.GetIndex(stCode: string): integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if GetInvestor(i).Code = stCode then
    begin
      Result := i;
      break;
    end;
end;

function TInvestors.GetInvestor(i: integer): TInvestor;
begin
  if (i < 0) or (i >= Count) then
    Result := nil
  else
    Result := Items[i] as TInvestor;
end;

procedure TInvestors.GetList(stList: TStrings);
var
  i: Integer;
begin
  if stList = nil then
    Exit;
  for i := 0 to Count - 1 do
    stList.AddObject(GetInvestor(i).Code, GetInvestor(i));
end;

procedure TInvestors.GetList2(stList: TStrings);
var
  i: Integer;
begin
  if stList = nil then
    Exit;
  for i := 0 to Count - 1 do
    stList.AddObject(GetInvestor(i).Code + ' ' + GetInvestor(i).Name,
      GetInvestor(i));

end;

end.
