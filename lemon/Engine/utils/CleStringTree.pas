unit CleStringTree;

interface

uses
  Classes, SysUtils;

const
  STRING_TREE_NODE_TABLE_LEN = 36; // 0~9, A~Z (case insensitive)

type
  TStringTreeNode = class;
  TStringTreeNodeTable = class;

  TStringTreeNodeTable = class
  public
    Nodes: array[0..STRING_TREE_NODE_TABLE_LEN] of TStringTreeNode; 
  end;

  TStringTreeNode = class(TCollectionItem)
  private
    FValue: Char;
    FObject: TObject;
    FLevel: Integer;
    FChildNodes: TStringTreeNodeTable;
    FString: String;
    
    procedure GetStrings(aList: TStrings);

    function GetTableIndex(cValue: Char): Integer;
  public
    constructor Create(aColl: TCollection);
    destructor Destroy; override;

    function Add(stValue: String; iLength, iLevel: Integer): TStringTreeNode;
    function Find(stValue: String; iLength, iLevel: Integer): TStringTreeNode;
    procedure Print(aList: TStrings);

    property StringValue: String read FString;
    property ObjectValue: TObject read FObject;
  end;

  TStringTree = class(TCollection)
  private
    FRootNode: TStringTreeNode;
  public
    constructor Create;

    function Add(stValue: String; aObject: TObject = nil): TStringTreeNode;
    function Find(stValue: String): TStringTreeNode;
    procedure GetList(aList: TStrings);
    procedure GetStrings(aList: TStrings);

    procedure Print(aList: TStrings);
    procedure Test(aList: TStrings);
  end;

implementation


{ TStringTreeNode }

constructor TStringTreeNode.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FValue := #0;
  FObject := nil;
  FLevel := -1;
  FChildNodes := nil;
  FString := '';
end;

destructor TStringTreeNode.Destroy;
begin
  if FChildNodes <> nil then
    FChildNodes.Free;

  inherited;
end;

function TStringTreeNode.GetTableIndex(cValue: Char): Integer;
begin
  case cValue of
    '0'..'9': Result := Ord(cValue) - Ord('0');
    'A'..'Z': Result := Ord(cValue) - Ord('A') + 10;
    else
      Result := STRING_TREE_NODE_TABLE_LEN;
  end;
end;

function TStringTreeNode.Add(stValue: String; iLength, iLevel: Integer): TStringTreeNode;
var
  iTableIndex: Integer;
  aNode: TStringTreeNode;
begin
  if iLength = iLevel then
  begin
    Result := Self;
    FString := Copy(stValue, 1, iLevel);
  end else
  if iLength > iLevel then
  begin
    if FChildNodes = nil then
      FChildNodes := TStringTreeNodeTable.Create;

    iLevel := iLevel+1;

    iTableIndex := GetTableIndex(stValue[iLevel]);
    aNode := FChildNodes.Nodes[iTableIndex];

    if aNode = nil then
    begin
      aNode := Collection.Add as TStringTreeNode;
      aNode.FValue := stValue[iLevel];
      aNode.FLevel := iLevel;

      FChildNodes.Nodes[iTableIndex] := aNode;
    end;

    Result := aNode.Add(stValue, iLength, iLevel);
  end else
    Result := nil;
end;

function TStringTreeNode.Find(stValue: String; iLength, iLevel: Integer): TStringTreeNode;
var
  iTableIndex: Integer;
  aNode: TStringTreeNode;
begin
  if iLength = iLevel then
    Result := Self
  else if iLength > iLevel then
  begin
    if FChildNodes <> nil then
    begin
      iLevel := iLevel+1;

      iTableIndex := GetTableIndex(stValue[iLevel]);
      aNode := FChildNodes.Nodes[iTableIndex];

      if aNode <> nil then
        Result := aNode.Find(stValue, iLength, iLevel)
      else
        Result := nil;
    end else
      Result := nil;
  end else
    Result := nil;
end;

procedure TStringTreeNode.Print(aList: TStrings);
var
  i: Integer;
  stLine: String;
begin
  stLine := '';
  for i := 1 to FLevel do
    stLine := stLine + '.';
  stLine := stLine + FValue + '(' + FString + ')';
  aList.Add(stLine);

  if FChildNodes <> nil then
    for i := 0 to STRING_TREE_NODE_TABLE_LEN do
      if FChildNodes.Nodes[i] <> nil then
        FChildNodes.Nodes[i].Print(aList);
end;

procedure TStringTreeNode.GetStrings(aList: TStrings);
var
  i: Integer;
  stLine: String;
begin
  if Length(FString) > 0 then
    aList.Add(FString);

  if FChildNodes <> nil then
    for i := 0 to STRING_TREE_NODE_TABLE_LEN do
      if FChildNodes.Nodes[i] <> nil then
        FChildNodes.Nodes[i].GetStrings(aList);
end;

{ TStringTree }

constructor TStringTree.Create;
begin
  inherited Create(TStringTreeNode);
end;

function TStringTree.Add(stValue: String; aObject: TObject): TStringTreeNode;
begin
  stValue := UpperCase(stValue);

  if (FRootNode = nil) or (Count = 0) then
  begin
    FRootNode := Inherited Add as TStringTreeNode;
    FRootNode.FLevel := 0;
  end;

  Result := FRootNode.Add(stValue, Length(stValue), 0);
  if Result <> nil then
    Result.FObject := aObject;
end;

function TStringTree.Find(stValue: String): TStringTreeNode;
begin
  stValue := UpperCase(stValue);

  Result := FRootNode.Find(stValue, Length(stValue), 0);
end;

procedure TStringTree.GetList(aList: TStrings);
var
  i: Integer;
  aNode: TStringTreeNode;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aNode := Items[i] as TStringTreeNode;
    if Length(aNode.FString) > 0 then
      aList.AddObject(aNode.FString, aNode.FObject);
  end;
end;

procedure TStringTree.GetStrings(aList: TStrings);
begin
  if aList = nil then Exit;

  FRootNode.GetStrings(aList);
end;

procedure TStringTree.Print(aList: TStrings);
begin
  if aList = nil then Exit;

  FRootNode.Print(aList);
end;

procedure TStringTree.Test(aList: TStrings);
begin
  if aList = nil then Exit;

  Add('1016C');
  Add('10173');
  Add('10176');
  Add('10179');
  Add('1017C');
  Add('2016C142');
  Add('2016C145');
  Add('2016C150');
  Add('30173142');
  Add('30176145');
  Add('30176150');
  Add('CLZ06');
  Add('CLF07');
  Add('CLG07');
  Add('HO');
  Add('C');
  Add('HU');


  GetList(aList);
  Print(aList);
end;

end.
