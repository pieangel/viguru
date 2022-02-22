unit CleTransactions;

interface

uses
  Classes, SysUtils,

  GleLib;

type

  TTransaction = class(TCollectionItem)
  private
    //F_SeqNo: Integer; // unique number to identify transaction
      //
    FAccount: String;
    FSymbol: String;
    FVolume: Integer;
    FPrice: Double;
    FPriceStr: String;
    FFillTime: TDateTime;
      // optional
    FTicketNo: String;
    FRemark: String;
      // get/set functions
    procedure SetPrice(const Value: String);
  public
    property Account: String read FAccount write FAccount;
    property Symbol: String read FSymbol write FSymbol;
    property Volume: Integer read FVolume write FVolume;
    property Price: Double read FPrice write FPrice;
    property PriceStr: String read FPriceStr write SetPrice;
    property FillTime: TDateTime read FFillTime write FFillTime;
    property TicketNo: String read FTicketNo write FTicketNo;
    property Remark: String read FRemark write FRemark;
  end;

  TTransactions = class(TCollection)
  private
    function GetTransaction(i: Integer): TTransaction;
  public
    constructor Create;

    function FindTransaction(stTicketNo: String): TTransaction;
    function NewTransaction: TTransaction;

    property Transactions[i:Integer]: TTransaction read GetTransaction; default;
  end;

  TTransactionList = class(TList)
  private
    FBuyQty: Integer;
    FBuyAPS: Double;
    FSellQty: Integer;
    FSellAPS: Double;
  private
    function GetTransaction(i: Integer): TTransaction;
  public
    procedure AddTransaction(aTransaction: TTransaction);
    procedure Summarize;

    property BuyQty: Integer read FBuyQty;
    property BuyAPS: Double read FBuyAPS;
    property SellQty: Integer read FSellQty;
    property SellAPS: Double read FSellAPS;

    property Transactions[i:Integer]: TTransaction read GetTransaction; default;
  end;

implementation

{ TTransaction }

procedure TTransaction.SetPrice(const Value: String);
begin
  FPriceStr := Value;
  FPrice := StrToFrac(FPriceStr);
end;

{ TTransactions }

constructor TTransactions.Create;
begin
  inherited Create(TTransaction);
end;

function TTransactions.FindTransaction(
  stTicketNo: String): TTransaction;
var
  i: Integer;
  aTransaction: TTransaction;
begin
  stTicketNo := UpperCase(Trim(stTicketNo));

  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aTransaction := GetTransaction(i);
    if CompareStr(aTransaction.FTicketNo, stTicketNo) = 0 then
    begin
      Result := aTransaction;
      Break;
    end;
  end;
end;

function TTransactions.NewTransaction: TTransaction;
begin
  Result := Add as TTransaction;
end;

function TTransactions.GetTransaction(i: Integer): TTransaction;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TTransaction
  else
    Result := nil;
end;

{ TTransactionList }

procedure TTransactionList.AddTransaction(
  aTransaction: TTransaction);
begin
    // no duplicate entry
  if IndexOf(aTransaction) < 0 then Add(aTransaction);
end;

function TTransactionList.GetTransaction(
  i: Integer): TTransaction;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TTransaction(Items[i])
  else
    Result := nil;
end;

procedure TTransactionList.Summarize;
var
  dBuySum, dSellSum: Double;
  i: Integer;
  aTransaction: TTransaction;
begin
  FBuyQty := 0;
  FBuyAPS := 0.0;
  FSellQty := 0;
  FSellAPS := 0.0;

  dBuySum := 0.0;
  dSellSum := 0.0;

  if Count = 0 then Exit;

  for i := 0 to Count - 1 do
  begin
    aTransaction := GetTransaction(i);
      // buy side
    if aTransaction.Volume > 0 then
    begin
      FBuyQty := FBuyQty + aTransaction.Volume;
      dBuySum := dBuySum + (aTransaction.Volume * aTransaction.Price);
    end else
      // sell side
    if aTransaction.Volume < 0 then
    begin
      FSellQty := FSellQty + Abs(aTransaction.Volume);
      dSellSum := dSellSum +
                    (Abs(aTransaction.Volume) * aTransaction.Price);
    end;
  end;

  if FBuyQty > 0 then FBuyAPS := dBuySum / FBuyQty;
  if FSellQty > 0 then FSellAPS := dSellSum / FSellQty;
end;

end.
