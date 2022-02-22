unit CleFills;

// Copyright(C) Eight Pines Technologies, Inc. All Rights Reserved.

// Filled Data Storage: It define the FILL object and storages of it

interface

uses
  Classes, SysUtils,
    // lemon: common
  GleLib, GleTypes, //CleOrders,
    // lemon: data
  CleAccounts, CleSymbols;

type
  TFill = class(TCollectionItem)
  private
    FFillNo: Integer;      // normally 'symbol+fillno' is unique
    FFillTime: TDateTime;  //
    FOrderNo: int64;     // (optional) default=-1,
      //
    FAccount: TAccount;    //
    FSymbol: TSymbol;      //
    FVolume: Integer;      // signed quantity
    FPrice: Double;
    FIsCheck: boolean;
    FFillTime2: string;
    FOrderSpecies: TOrderSpecies;
    //FOrder: TOrder;

    function Represent: String;        //
  public
    constructor Create(Coll: TCollection); override;

    property FillNo: Integer read FFillNo;
    property FillTime: TDateTime read FFillTime;
    property FillTime2: string read FFillTime2 write FFillTime2;
    property OrderNo: int64 read FOrderNo;
    property Account: TAccount read FAccount;
    property Symbol: TSymbol read FSymbol;
    property Volume: Integer read FVolume;
    property Price: Double read FPrice;
    property OrderSpecies : TOrderSpecies read FOrderSpecies;
        // add by seunge 20121102
    //property Order  : TOrder read FOrder write FOrder;

    property IsCheck : boolean read FIsCheck write FIsCheck;

    procedure Assign( aFill : TFill );
  end;

  TFills = class(TCollection)
  private
    function Represent: String;
    function GetFill(i: Integer): TFill;
  public
    constructor Create;

    function New(iFillNo: Integer; dtFillTime: TDateTime; stFillTime : string;iOrderNo: int64;
      aAccount: TAccount; aSymbol: TSymbol; iVolume: Integer; dPrice: Double; aSpecies : TOrderSpecies = opNormal): TFill;

    function Find( aAccount : TAccount; aSymbol : TSymbol; aNo : Integer ): TFill;

    property Fills[i:Integer]: TFill read GetFill; default;
  end;

  TFillList = class(TList)
  private
    function GetFill(i: Integer): TFill;
  public
    procedure AddFill(aFill: TFill);

    property Fills[i:Integer]: TFill read GetFill; default;
  end;

implementation

{ TFill }

procedure TFill.Assign(aFill: TFill);
begin
  FFillNo := aFill.FillNo;
  FFillTime := aFill.FFillTime;
  FOrderNo := aFill.FOrderNo;
    //
  FAccount := aFill.FAccount;
  FSymbol := aFill.FSymbol;
  FVolume := aFill.FVolume;
  FPrice := aFill.FPrice;
end;

constructor TFill.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FFillNo := 0;
  FFillTime := 0.0;
  FFillTime2:= '';
  FOrderNo := -1;
    //
  FAccount := nil;
  FSymbol := nil;
  FVolume := 0;
  FPrice := 0;
    //
  FIsCheck  := false;
  //FOrder := nil;
end;

function TFill.Represent: String;
var
  stAccount, stSymbol: String;
begin
    // account code
  if FAccount <> nil then
    stAccount := FAccount.Code
  else
    stAccount := 'nil';

    // symbol code
  if FSymbol <> nil then
    stSymbol := FSymbol.Code
  else
    stSymbol := 'nil';

    // represent
  Result := Format('(%d,%s,%d,%s,%s,%d,%.4n)',
                   [FFillNo, FormatDateTime('hh:nn:ss', FFillTime), FOrderNo,
                    stAccount, stSymbol, FVolume, FPrice]);
end;

{ TFills }

constructor TFills.Create;
begin
  inherited Create(TFill);
end;

function TFills.New(iFillNo: Integer; dtFillTime: TDateTime; stFillTime : string; iOrderNo: int64;
      aAccount: TAccount; aSymbol: TSymbol; iVolume: Integer; dPrice: Double; aSpecies : TOrderSpecies): TFill;
begin
  Result := Add as TFill;

  Result.FFillNo  := iFillNo;
  Result.FFillTime := dtFillTime;
  Result.FOrderNo   := iOrderNo;
  Result.FAccount   := aAccount;
  Result.FSymbol  := aSymbol;
  Result.FVolume  := iVolume;
  Result.FPrice   := dPrice;
  Result.FillTime2  := stFillTime;
  Result.IsCheck  := false;
  Result.FOrderSpecies := aSpecies;
end;

function TFills.Find(aAccount: TAccount; aSymbol: TSymbol; aNo: Integer): TFill;
var
  i : integer;
begin
  result := nil;
  for i := Count-1 downto 0 do
    if (Fills[i].Account = aAccount) and
      ( Fills[i].Symbol  = aSymbol)  and
      ( Fills[i].FFillNo = aNo ) then
      begin
        Result := Fills[i];
        break;
      end;       

end;

function TFills.GetFill(i: Integer): TFill;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TFill
  else
    Result := nil;
end;

function TFills.Represent: String;
var
  i: Integer;
begin
  Result := Format('Total:%d', [Count]);
  for i := 0 to Count - 1 do
    Result := Result + Format(',%d%s', [i, GetFill(i).Represent]);
end;

{ TFillList }

procedure TFillList.AddFill(
  aFill: TFill);
begin
    // no duplicate entry
  if IndexOf(aFill) < 0 then Add(aFill);
end;

function TFillList.GetFill(
  i: Integer): TFill;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TFill(Items[i])
  else
    Result := nil;
end;


end.
