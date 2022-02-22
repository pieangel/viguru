unit CleLists;

interface

uses
  Classes;

type
  TFilteredListEvent = function(aObj: TObject): Boolean of object;
  TCategorizedListEvent = function(aObj: TObject): String of object;

  TFilteredList = class(TList)
  protected
    FOnFilter: TFilteredListEvent;

    function Filter(aObj: TObject): Boolean; virtual;
    procedure DoAdd(aObj: TObject); virtual;
    procedure DoRemove(aObj: TObject); virtual;
  public
    procedure AddObject(aObj: TObject); virtual;
    procedure UpdateObject(aObj: TObject); virtual;
    procedure RemoveObject(aObj: TObject); virtual;

    property OnFilter: TFilteredListEvent read FOnFilter write FOnFilter;
  end;

  TCategorizedList = class(TFilteredList)
  private
    function GetCategory(i: Integer): String;
    function GetCategoryCount: Integer;
    function GetList(i:Integer): TList;
  protected
    FCategories: TStringList;
    FOnCategory: TCategorizedListEvent;

    function Categorize(aObj: TObject): String; virtual;
    procedure DoAdd(aObj: TObject); override;
    procedure DoRemove(aObj: TObject); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear; override;

    property CategoryCount: Integer read GetCategoryCount;
    property Categories[i:Integer]: String read GetCategory;
    property Lists[i:Integer]: TList read GetList;
    property OnCategory: TCategorizedListEvent read FOnCategory write FOnCategory;
  end;

implementation

{ TFilteredList }

function TFilteredList.Filter(aObj: TObject): Boolean;
begin
  if Assigned(FOnFilter) then
    Result := FOnFilter(aObj)
  else
    Result := False;
end;

procedure TFilteredList.DoAdd(aObj: TObject);
begin
  Add(aObj);
end;

procedure TFilteredList.DoRemove(aObj: TObject);
begin
  Remove(aObj);
end;

procedure TFilteredList.AddObject(aObj: TObject);
begin
  if (IndexOf(aObj) < 0) and Filter(aObj) then
  begin
    DoAdd(aObj);
  end;
end;

procedure TFilteredList.RemoveObject(aObj: TObject);
begin
  if IndexOf(aObj) >= 0 then
  begin
    DoRemove(aObj);
  end;
end;

procedure TFilteredList.UpdateObject(aObj: TObject);
begin
  if IndexOf(aObj) >= 0 then
  begin
    if not Filter(aObj) then
      DoRemove(aObj);
  end else
  if Filter(aObj) then
    DoAdd(aObj);
end;

{ TCategorizedList }

constructor TCategorizedList.Create;
begin
  inherited Create;

  FCategories := TStringList.Create;
  FCategories.Sorted := True;
end;

destructor TCategorizedList.Destroy;
begin
  Clear;
  FCategories.Free;

  inherited;
end;

function TCategorizedList.Categorize(aObj: TObject): String;
begin
  if Assigned(FOnCategory) then
    Result := FOnCategory(aObj)
  else
    Result := 'DEFAULT';
end;

procedure TCategorizedList.Clear;
var
  i: Integer;
begin
  for i := 0 to FCategories.Count - 1 do
    FCategories.Objects[i].Free;

  FCategories.Clear;

  inherited Clear;
end;

procedure TCategorizedList.DoAdd(aObj: TObject);
var
  iIndex: Integer;
  stCategory: String;
  aList: TList;
begin
  inherited DoAdd(aObj);

  stCategory := Categorize(aObj);
  iIndex := FCategories.IndexOf(stCategory);

  if iIndex >= 0 then
    (FCategories.Objects[iIndex] as TList).Add(aObj)
  else
  begin
    aList := TList.Create;
    aList.Add(aObj);
    FCategories.AddObject(stCategory, aList);
  end;
end;

procedure TCategorizedList.DoRemove(aObj: TObject);
var
  iIndex: Integer;
  stCategory: String;
  aList: TList;
begin
  inherited DoRemove(aObj);

  stCategory := Categorize(aObj);
  iIndex := FCategories.IndexOf(stCategory);

  if iIndex >= 0 then
  begin
    aList := FCategories.Objects[iIndex] as TList;
    aList.Remove(aObj);
    if aList.Count = 0 then
    begin
      aList.Free;
      FCategories.Delete(iIndex);
    end;
  end;
end;

function TCategorizedList.GetCategory(i: Integer): String;
begin
  if (i >= 0) and (i <= FCategories.Count-1) then
    Result := FCategories[i]
  else
    Result := '';
end;

function TCategorizedList.GetCategoryCount: Integer;
begin
  Result := FCategories.Count;
end;

function TCategorizedList.GetList(i: Integer): TList;
begin
  if (i >= 0) and (i <= FCategories.Count-1) then
    Result := FCategories.Objects[i] as TList
  else
    Result := nil;
end;

end.
