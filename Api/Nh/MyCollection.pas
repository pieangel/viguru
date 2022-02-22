unit MyCollection;

interface

uses
SysUtils, Classes;

 

type

TMyCollectionItem = class(TCollectionItem)
private
  FName: string;   
  FAge : integer;    

  procedure SetName(const AName: string);
  procedure SetAge(const AAge: integer);
public
  procedure AssignParameter(const AName: string; const AAge: integer); virtual;
published
  property Name: string read FName write SetName;
  property Age: integer read FAge write SetAge;
end;

 

TMyCollection = class(TCollection)
protected
  function GetItem(Index: integer): TMyCollectionItem; virtual;
  procedure SetItem(Index: integer; Value: TMyCollectionItem); virtual;
  function IndexOf(const AName: string): integer; virtual;
public
  constructor Create;
  function Add: TMyCollectionItem;
  procedure AddParameter(const AName: string; const AAge: integer);
  procedure DeleteParameter(const AName: string);

  property Items[ Index: integer ] : TMyCollectionItem read GetItem write SetItem;
end;

 

implementation

 

{ TMyCollectionItem }

 

procedure TMyCollectionItem.AssignParameter(const AName: string;
const AAge: integer);
begin
  Name := AName;
  Age := AAge;
end;

 

 

procedure TMyCollectionItem.SetAge(const AAge: integer);
begin
if FAge <> AAge then
  FAge := AAge;
end;

 

 

procedure TMyCollectionItem.SetName(const AName: string);
begin
if FName <> AName then
  FName := AName;
end;

 

{ TMyCollection }

 

function TMyCollection.Add: TMyCollectionItem;
begin
  Result := TMyCollectionItem(inherited Add);
end;

 

procedure TMyCollection.AddParameter(const AName: string;
const AAge: integer);
begin
  Add.AssignParameter(AName, AAge);
end;

 

constructor TMyCollection.Create;
begin
  inherited Create(TMyCollectionItem);
end;

 

procedure TMyCollection.DeleteParameter(const AName: string);
begin
  Items[ IndexOf(AName) ].Free;
end;

 

function TMyCollection.GetItem(Index: integer): TMyCollectionItem;
begin
  Result := TMyCollectionItem(inherited GetItem(Index));
end;

 

function TMyCollection.IndexOf(const AName: string): integer;
begin
for Result := 0 to Count - 1 do
  if Items[Result].Name = AName then
    exit;
  raise Exception.CreateFmt('Error: Parameter "%s" does not exist', [AName]);
end;

 

procedure TMyCollection.SetItem(Index: integer; Value: TMyCollectionItem);
begin
  inherited SetItem(Index, Value);
end;


end.