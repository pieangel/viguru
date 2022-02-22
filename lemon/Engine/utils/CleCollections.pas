unit CleCollections;

interface

uses
  Classes;

type
  // 'TCodedCollection' maintaines a 'TStringList' object inside
  // and hide 'Add()' and 'Insert()' of TCollection.
  // The new Add() and Insert() get a string code as a parameter, which
  // is registered in the StringList object and by which the StringList object
  // is automatically sorted.
  TCodedCollection = class(TCollection)
  protected
    FSortedList: TStringList;


    function GetSortedItem(i: Integer): TCollectionItem;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  public
    constructor Create(aItemClass: TCollectionItemClass);
    destructor Destroy; override;

    function Add(Code: String): TCollectionItem;
    function Insert(Index: Integer; Code: String): TCollectionItem;
    //function Find(Code: String): TCollectionItem;

    property SortedItems[i:Integer]: TCollectionItem read GetSortedItem;
  end;

  // TSortedCollection is to be inherited by collection classes
  // which need to be sorted in any order.
  // Any child class of this class should override 'Compare(...)' function.
  // When sort, use 'Sort(...)' procedure.
  // The property 'SortedItems' represent sorted items.
const
  SORT_ASCENDING  = 1;
  SORT_DESCENDING = -1;

type
  TSortedCollection = class(TCollection)
  protected

    FSortIndex: Integer;
    FSortDirection: Integer;

    function GetSortedItem(i: Integer): TCollectionItem;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    function Compare(aItem1, aItem2: TCollectionItem;
      aSortIndex: Integer): Integer; virtual;
  public
    FSortedList: TList;
    constructor Create(aItemClass: TCollectionItemClass);
    destructor Destroy; override;



    procedure SortInit;
    procedure Sort(iSortIndex: Integer); virtual;

    property SortIndex: Integer read FSortIndex;
    property SortDirection: Integer read FSortDirection;
    property SortedItems[i:Integer]: TCollectionItem read GetSortedItem;
  end;

implementation

uses CleSymbols, CleQuoteBroker;

{ TCodedCollection }

constructor TCodedCollection.Create(aItemClass: TCollectionItemClass);
begin
  inherited Create(aItemClass);

  FSortedList := TStringList.Create;
  FSortedList.Sorted := True;


end;

destructor TCodedCollection.Destroy;
begin
  FSortedList.Free;

  inherited;
end;

function TCodedCollection.GetSortedItem(i: Integer): TCollectionItem;
begin
  if (i >= 0) and (i <= FSortedList.Count-1) then
    Result := FSortedList.Objects[i] as TCollectionItem
  else
    Result := nil;
end;

function TCodedCollection.Add(Code: String): TCollectionItem;
begin
  Result := inherited Add;
  FSortedList.AddObject(Code, Result);
end;

function TCodedCollection.Insert(Index: Integer; Code: String): TCollectionItem;
begin
  Result := inherited Insert(Index);
  FSortedList.AddObject(Code, Result);
end;

procedure TCodedCollection.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
var
  iPos: Integer;
begin
  inherited;

  case Action of
    cnAdded: ;
    cnExtracting,
    cnDeleting:
      begin
        iPos := FSortedList.IndexOfObject(Item);
        if iPos >= 0 then
          FSortedList.Delete(iPos);
      end;
  end;
end;

{ TSortedCollection }

constructor TSortedCollection.Create(aItemClass: TCollectionItemClass);
begin
  inherited Create(aItemClass);

  FSortedList := TList.Create;
  FSortIndex := -1;
  FSortDirection := SORT_ASCENDING;
end;

destructor TSortedCollection.Destroy;
begin
  FSortedList.Free;

  inherited;
end;

function TSortedCollection.GetSortedItem(i: Integer): TCollectionItem;
begin
  if (i >= 0) and (i <= FSortedList.Count-1) then
    Result := TCollectionItem(FSortedList.Items[i])
  else
    Result := nil;
end;

procedure TSortedCollection.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;

  case Action of
    cnAdded: FSortedList.Add(Item);
    cnExtracting,
    cnDeleting: FSortedList.Remove(Item);
  end;
end;

function TSortedCollection.Compare(aItem1, aItem2: TCollectionItem;
  aSortIndex: Integer): Integer;
  var
  iValue   : double;
  iValue2  : double;
begin

  iValue  := (( aItem1 as TQuote ).Symbol ).TickRatio;
  iValue2 := (( aItem2 as TQuote ).Symbol ).TickRatio;

  if iValue > iValue2 then
    Result := 1
  else if iValue = iValue2 then
    Result := 0
  else
    Result := -1;

  {
  Result := Round(
              ( (aItem1 as TQuote ).Symbol ).TickRatio  -
              ( (aItem2 as TQuote ).Symbol ).TickRatio
              );//  TickRatio;
              }
{
  if dResult > 0 then
    Result := 1
  else if dResult < 0 then
    Result := -1
  else
    Result := 0;
 }
end;

var
  aSortedCollection: TSortedCollection;

function ListSortCompare(Item1, Item2: Pointer): Integer;
var
  aItem1 : TCollectionItem absolute Item1;
  aItem2 : TCollectionItem absolute Item2;
begin
  if aSortedCollection <> nil then
    Result := aSortedCollection.Compare(aItem1, aItem2, aSortedCollection.SortIndex)
               * aSortedCollection.SortDirection
  else
    Result := 0;
end;

procedure TSortedCollection.Sort(iSortIndex: Integer);
begin
  if iSortIndex <> FSortIndex then
  begin
    FSortIndex := iSortIndex;
    FSortDirection := SORT_ASCENDING;
  end else
  begin
    if FSortDirection = SORT_ASCENDING then
      FSortDirection := SORT_DESCENDING
    else
      FSortDirection := SORT_ASCENDING;
  end;

  aSortedCollection := Self;

  FSortedList.Sort(ListSortCompare);
end;

procedure TSortedCollection.SortInit;
begin
  FSortIndex := SORT_ASCENDING;
end;

end.
