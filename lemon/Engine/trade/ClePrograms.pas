unit ClePrograms;

interface

uses
  Classes, SysUtils,
    // lemon: data
  CleAccounts;

type
  TProgram = class(TCollectionItem)
  private
    FCode: String;
    FName: String;

    FAccounts: TAccountList;
  public
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    function Represent: String;

    property Code: String read FCode;
    property Name: String read FName;
    property Accounts: TAccountList read FAccounts;
  end;

  TPrograms = class(TCollection)
  private
    function GetProgram(i: Integer): TProgram;
  public
    constructor Create;

    function New(stCode, stName: String): TProgram;
    function Find(stCode: String): TProgram;

    function Represent: String;

    property Programs[i:Integer]: TProgram read GetProgram; default;
  end;

implementation

{ TProgram }

constructor TProgram.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FAccounts := TAccountList.Create;
end;

destructor TProgram.Destroy;
begin
  FAccounts.Free;

  inherited;
end;

function TProgram.Represent: String;
begin
  Result := Format('(%s,%s)', [FCode, FName]);
end;


{ TPrograms }

constructor TPrograms.Create;
begin
  inherited Create(TProgram);
end;

function TPrograms.GetProgram(i: Integer): TProgram;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TProgram
  else
    Result := nil;
end;

function TPrograms.Find(stCode: String): TProgram;
var
  i: Integer;
begin
  Result := nil;
  
  for i := 0 to Count - 1 do
    if CompareStr((Items[i] as TProgram).FCode, stCode) = 0 then
    begin
      Result := Items[i] as TProgram;
      Break;
    end;
end;

function TPrograms.New(stCode, stName: String): TProgram;
begin
  Result := Find(stCode);

  if Result = nil then
  begin
    Result := Add as TProgram;
    Result.FCode := stCode;
    Result.FName := stName;
  end;
end;

function TPrograms.Represent: String;
var
  i: Integer;
begin
  Result := '(';
  for i := 0 to Count - 1 do
    Result := Result + GetProgram(i).Represent;
  Result := Result + ')';
end;

end.
