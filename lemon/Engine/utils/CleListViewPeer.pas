unit CleListViewPeer;

// 'TListViewPeer' is a 'TListView' control wrapper to reduce
// repetitive coding for 'OwnerData' mode
// This wrapper automatically set 'OwnerData' and 'OwnerDraw' property.
// Usage flow (1):
//  (1.1) aPeer := TListViewPeerCreate(ListView1);
//  (1.2) aPeer.OnSelect := PeerSelectFunc;
//  (1.3) assign a TListView.OnData handler
//  ...
//  (1.4) aPeer.Objects := aTCollection_or_TList_object;
//  (1.5) aPeer.Map; // this calls aPeer.Refresh
//  ...
//  (1.5) aPeer.Refresh;
// Usage flow (2):
//  (2.1) inherit TListViewPeer
//  (2.2) override 'GetCount()' and 'ListViewData()'
//  ...
//  (2.3) aPeer.Objects := aTCollection_or_TList_object;
//  (2.4) aPeer.Map;
//  ...
//  (2.5) aPeer.Refresh;
interface

uses
  Classes, Windows, Controls, ComCtrls, Graphics, CommCtrl,

  CleAssocControls;

type
  TListViewPeer = class
  private
    procedure DefaultListViewDrawGridLines(ListView: TListView;
      ItemRect: TRect);
  protected
      // view controls
    FListView: TListView;

      // To get the item count, Map() will check if 'FObjectList' assigned.
      // Only an object of 'TCollection' or 'TList' should be assigned.
      // If 'FObjectList' is not assigned, it will call 'GetCount()'.
    FObjects: TObject;

      // selection
    FSelected: TObject;
    FOnSelect: TNotifyEvent;

      // controls controlled by item selection
    FControls: TAssociatedControls;

      // delayed update: to reduced the load
    FNeedUpdates: array of Boolean;
    FUpdateRequired: Boolean;

      // colors
    FFgNormalColor: TColor;
    FFgSelectedColor: TColor;
    FBgSelectedColor: TColor;
    FBgEvenColor: TColor;
    FBgOddColor: TColor;

    procedure SetListView(const Value: TListView);

    procedure ListViewData(Sender: TObject; Item: TListItem); virtual;
    procedure ListViewDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState); virtual;
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean); virtual;
    function GetCount: Integer; virtual;

    procedure ResetNeedUpdates;
  public
    constructor Create(aListView: TListView);
    destructor Destroy; override;

    procedure Map;
    procedure UpdateItem(i: Integer);
    procedure Refresh;

    procedure NeedUpdate(i: Integer);
    procedure Update;

    property ListView: TListView read FListView write SetListView;
    property Objects: TObject read FObjects write FObjects;

    property AssocCtrls: TAssociatedControls read FControls;

    property Selected: TObject read FSelected;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
  end;

implementation

{ TListviewPeer }

constructor TListViewPeer.Create(aListView: TListView);
begin
  FSelected := nil;

  FControls := TAssociatedControls.Create;

  SetListView(aListView);

  FNeedUpdates := nil;
  FUpdateRequired := False;

    // colors
  FFgNormalColor := $000000;
  FFgSelectedColor := $000000;
  FBgSelectedColor := $00F2BEB9;
  FBgEvenColor := $EEEEEE;
  FBgOddColor := $FFFFFF;
end;

destructor TListViewPeer.Destroy;
begin
  FNeedUpdates := nil;

  FControls.Free;

  inherited;
end;

procedure TListViewPeer.SetListView(const Value: TListView);
begin
  if Value = nil then Exit;

  FListView := Value;
  FListView.OwnerData := True;
  FListView.OwnerDraw := True;
  FListView.OnDrawItem := ListViewDrawItem;
  FListView.OnSelectItem := ListViewSelectItem;

  if not Assigned(FListView.OnData) then
    FListView.OnData := ListViewData;
end;

procedure TListViewPeer.Map;
var
  iCount: Integer;
begin
    // get item count
  if FObjects <> nil then
    if FObjects is TCollection then
      iCount := (FObjects as TCollection).Count
    else if FObjects is TList then
      iCount := (FObjects as TList).Count
    else if FObjects is TSTrings then
      iCount := (FObjects as TStrings).Count
    else
      iCount := GetCount

  else
    iCount := GetCount;

    // set ListView dimension and redraw
  FListView.Items.Clear;
  FListView.Items.Count := iCount;
  FListView.Refresh;

    // for delayed update
  SetLength(FNeedUpdates, iCount);
  ResetNeedUpdates;

    // turn off associated controls
  FControls.Switch := False;
end;


function TListViewPeer.GetCount: Integer;
begin
  Result := 0; // should be overrided by derived classes
end;

procedure TListViewPeer.Refresh;
begin
  FListView.Refresh;

  if FUpdateRequired then ResetNeedUpdates;
end;

procedure TListViewPeer.NeedUpdate(i: Integer);
begin
  if (FNeedUpdates <> nil)
     and (i >= Low(FNeedUpdates))
     and (i <= High(FNeedUpdates)) then
  begin
    FNeedUpdates[i] := True;
    FUpdateRequired := True;
  end;
end;

procedure TListViewPeer.ResetNeedUpdates;
var
  i: Integer;
begin
  FUpdateRequired := False;

  if (FNeedUpdates <> nil) and (Length(FNeedUpdates) > 0) then
    for i := Low(FNeedUpdates) to High(FNeedUpdates) do
      FNeedUpdates[i] := False;
end;

procedure TListViewPeer.Update;
var
  i: Integer;
begin
  if FUpdateRequired then
  begin
    if (FNeedUpdates <> nil) and (Length(FNeedUpdates) > 0) then
      for i := Low(FNeedUpdates) to High(FNeedUpdates) do
        if FNeedUpdates[i] then
        begin
          UpdateItem(i);
          FNeedUpdates[i] := False;
        end;
        
    FUpdateRequired := False;
  end;
end;

procedure TListViewPeer.UpdateItem(i: Integer);
var
  aItem: TListItem;
  aState: TOwnerDrawState;
begin
  aItem := FListView.Items[i];
  aState := [];
  if aItem.Focused then aState := aState + [odFocused];
  if aItem.Selected then aState := aState + [odSelected];

  ListViewDrawItem(FListView, aItem, aItem.DisplayRect(drBounds), aState);
end;

procedure TListViewPeer.ListViewData(Sender: TObject;
  Item: TListItem);
begin
  // should be overrided by client
end;

procedure TListViewPeer.ListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    FSelected := TObject(Item.Data)
  else
    FSelected := nil;

  FControls.Switch := Selected;

    // notify
  if Assigned(FOnSelect) then
    FOnSelect(Self);
end;

procedure TListViewPeer.ListViewDrawItem(
  Sender: TCustomListView; Item: TListItem; Rect: TRect;
  State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
begin
  if (FListView = nil) or (Sender <> FListView) then Exit;

  Rect.Bottom := Rect.Bottom-1;
  //
  with FListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := FBgSelectedColor;
      Font.Color := FFgSelectedColor;
    end else
    begin
      Font.Color := FFgNormalColor;
      if Item.Index mod 2 = 1 then
        Brush.Color := FBgEvenColor
      else
        Brush.Color := FBgOddColor;
    end;
      //-- background
    FillRect(Rect);
      // grid lines
    DefaultListViewDrawGridLines(ListView, Rect);

      //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    if (Item.ImageIndex >=0) and (ListView.SmallImages <> nil) then
    begin
      // aListView.SmallImages.BkColor := Brush.Color;
      ListView.SmallImages.Draw(ListView.Canvas, Rect.Left+1, Rect.Top,
                              Item.ImageIndex);
    end;

      //-- caption
    if Item.Caption <> '' then
      if ListView.SmallImages = nil then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 5, iY, Item.Caption)
      else
        TextRect(
            Classes.Rect(Rect.Left + ListView.SmallImages.Width,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + ListView.SmallImages.Width + 5, iY, Item.Caption);
    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 5;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 5 - aSize.cx;
        else iX := iLeft + 2; // redundant coding
      end;
      TextRect(
          Classes.Rect(iLeft+1, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;
end;

procedure TListViewPeer.DefaultListViewDrawGridLines(ListView: TListView; ItemRect: TRect);
var
  i, iRight : Integer;
begin
  //
  with ListView.Canvas do
  begin
    iRight := ListView.ClientRect.Left;
    Pen.Color := clLtGray;
    Pen.Width := 1;

    for i:=0 to ListView.Columns.Count-1 do
    begin
      iRight := iRight + ListView_GetColumnWidth(ListView.Handle,i);
      MoveTo(iRight, ItemRect.Top);
      LineTo(iRight, ItemRect.Bottom);
    end;
  end;
end;


end.

