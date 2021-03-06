unit CleFunds;

interface

uses
  Classes, SysUtils,

  GleTypes,  CleFills, CleSymbols, CleFQN,

  CleAccounts;

type

  TFundItem = class( TCollectionItem )
  public
    Account   : TAccount;  // ????
    Multiple  : integer;   // ?¼?..
    Ratio     : double;   // ????;
    MaxQty  , MinQty : integer;
    constructor Create(aColl: TCollection); override;
  end;


  TFundItems = class(TCollection)
  private
    function GetFundItem(i: Integer): TFundItem;
  public
    constructor Create;

    function Represent: String;
    function AddFundItem(aAccount   : TAccount ) : TFundItem;

    property FundItem[i: Integer]: TFundItem read GetFundItem; default;

    function FindMultiple( aAccount : TAccount ) : integer ;
    function Find( stCode: String): TFundItem; overload;
    function Find( aAccount : TAccount) : TFundItem; overload;
    function Find2( aAccount : TAccount) : integer; overload;
  end;

  TFund = class(TCollectionItem)
  private
    FName: String;
    FFundItems: TFundItems;
    function GetFundAccount(i: integer): TAccount;

  public
    TradeAmt    : array [TDerivativeType] of double;
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;
    
    procedure ApplyFill(aSymbol: TSymbol; iFillQty: Integer; dFillPrice: Double);
    function Represet: String;

    property Name: String read FName write FName;
    property FundItems: TFundItems read FFundItems;
    property FundAccount[ i : integer] : TAccount read GetFundAccount; default;
  end;


  TFunds = class(TCollection)
  private
    function GetFund(i: Integer): TFund;
  public
    constructor Create;

    function New(stName: String): TFund;

    function Find(stName: string): TFund; overload;
    function Find( aAccount : TAccount ) : TFund ; overload;

    procedure Remove( aFund : TFund ) ;
    procedure GetList(stList: TStrings);
    function Represent: String;
    property Funds[i:Integer]: TFund read GetFund; default;
  end;

implementation

{ TFund }

constructor TFund.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FFundItems := TFundItems.Create;
  TradeAmt[dtFutures] := 0;
  TradeAmt[dtOptions] := 0;
end;

destructor TFund.Destroy;
begin
  FFundItems.Free;
  inherited;
end;

function TFund.GetFundAccount(i: integer): TAccount;
begin
  Result := nil;

  if ( i < 0 ) or ( i >= FundItems.Count ) then
    Exit
  else
    Result := FundItems.FundItem[i].Account;

end;

function TFund.Represet: String;
begin

end;

procedure TFund.ApplyFill(aSymbol: TSymbol; iFillQty: Integer;
  dFillPrice: Double);
var
  dtType : TDerivativeType;
begin

  case aSymbol.Spec.Market of
    mtFutures: dtType := dtFutures;
    mtOption: dtType := dtOptions;
    else Exit;
  end;

  TradeAmt[dtType] := TradeAmt[dtType] +
                            abs(iFillQty) * dFillPrice * aSymbol.Spec.PointValue ;

end ;

{ TFunds }

constructor TFunds.Create;
begin
  inherited Create(TFund);
end;

function TFunds.Find(stName: string): TFund;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if GetFund(i).Name = stName then
    begin
      Result := Items[i] as TFund;
      Break;
    end;
end;

function TFunds.Find(aAccount: TAccount): TFund;
var
  i,  j: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    for j := 0 to GetFund(i).FundItems.Count - 1 do
      if GetFund(i).FundItems.FundItem[j].Account = aAccount then
      begin
        Result := Items[i] as TFund;
        Break;
      end;

    if Result <> nil then
      break;
  end;

end;

function TFunds.GetFund(i: Integer): TFund;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TFund
  else
    Result := nil;
end;

function TFunds.New(stName: String): TFund;
begin
  stName := Trim(stName);
  Result := Find( stName );
  if Result = nil then
  begin
    Result := Add as TFund;
    Result.FName := stName;
  end;
end;

procedure TFunds.GetList(stList: TStrings);
var
  i: Integer;
  aFund: TFund;
begin
  if stList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aFund := GetFund(i);
    stList.AddObject(aFund.Name, aFund);
  end;
end;


procedure TFunds.Remove(aFund: TFund);
begin

end;

function TFunds.Represent: String;
var
  i: Integer;
begin
  Result := '(';
  for i := 0 to Count - 1 do
    Result := Result + GetFund(i).Represet;
  Result := Result + ')';
end;



{ TFundItems }

function TFundItems.AddFundItem(aAccount: TAccount): TFundItem;
begin
  Result := Add as TFundItem;
  Result.Account  := aAccount;
end;

constructor TFundItems.Create;
begin
  inherited Create( TFundItem );
end;

function TFundItems.Find2(aAccount: TAccount): integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Count - 1 do
    if GetFundItem(i).Account = aAccount then
    begin
      Result := i;
      break;
    end;
end;

function TFundItems.FindMultiple(aAccount: TAccount): integer;
var
  I: Integer;
begin
  Result := 1;

  for I := 0 to Count - 1 do
    if GetFundItem(i).Account = aAccount then
    begin
      Result := (Items[i] as TFundItem).Multiple;
      break;
    end;

end;

function TFundItems.Find(aAccount: TAccount): TFundItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if GetFundItem(i).Account = aAccount then
    begin
      Result := Items[i] as TFundItem;
      break;
    end;

end;

function TFundItems.Find(stCode: String): TFundItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if GetFundItem(i).Account.Code = stCode then
    begin
      Result := Items[i] as TFundItem;
      break;
    end;
end;

function TFundItems.GetFundItem(i: Integer): TFundItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TFundItem;
end;

function TFundItems.Represent: String;
begin

end;

{ TFundItem }

constructor TFundItem.Create(aColl: TCollection);
begin
  inherited Create(aColl );

  Account   := nil;
  Multiple  := 1;

end;

end.
