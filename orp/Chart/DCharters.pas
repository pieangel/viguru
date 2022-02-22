unit DCharters;

//
// 챠트/지표 설정
//
//

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CommCtrl,
  //
  Charters, GleConsts, ImgList, ComCtrls , Indicator , GleLib;

type
  TCharterDialog = class(TForm)
    ButtonConfig: TButton;
    Button2: TButton;
    Button1: TButton;
    ButtonDel: TButton;
    ListViewCharters: TListView;
    ImageList1: TImageList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonConfigClick(Sender: TObject);
    procedure ButtonDelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewChartersClick(Sender: TObject);
    procedure ListViewChartersDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewChartersDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ListViewChartersDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ListViewChartersDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListViewChartersData(Sender: TObject; Item: TListItem);
  private
    FDeletedCharter: TCharter;
    FIndicates: TList;
    FDelCharters: TList;
    procedure SetDelCharters(const Value: TList);

    { Private declarations }
  public
    { Public declarations }

    property DelCharters : TList read FDelCharters write SetDelCharters;
    property DeletedCharter : TCharter read FDeletedCharter;
    //property Indicates : TList read FIndicates;
    procedure RefreshList;
    procedure AddIndicator(aIndicator : TIndicator);
    procedure CopyList( aList : TList );
  end;

implementation

{$R *.DFM}
procedure ListViewDrawItem(ListView: TListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState; Statusbar : TStatusBar);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;

begin
  Rect.Bottom := Rect.Bottom-1;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    begin
      Font.Color := clBlack;
      if Item.Index mod 2 = 1 then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end;
    //-- background
    FillRect(Rect);
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

      //if ListView.SmallImages = nil then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption);
      {
      else
        TextRect(
            Classes.Rect(Rect.Left + ListView.SmallImages.Width,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + ListView.SmallImages.Width + 2, iY, Item.Caption);
      }
    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 2 - aSize.cx;
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;

  // additional service
  if StatusBar <> nil then
  begin
    for i:=0 to StatusBar.Panels.Count-1 do
      if i < ListView.Columns.Count then
        StatusBar.Panels[i].Width := ListView_GetColumnWidth(ListView.Handle,i)
  end;


end;


procedure TCharterDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TCharterDialog.ButtonConfigClick(Sender: TObject);
var
  aCharter : TCharter;
begin
  {
  if ListCharters.ItemIndex >= 0 then
  begin
  }
  if ListViewCharters.Selected = nil then Exit;
  if ListViewCharters.Selected.Index >= 0 then
  begin
    aCharter := TCharter(FIndicates.Items[ListViewCharters.Selected.Index]);
    {
    aCharter :=
          ListCharters.Items.Objects[ListCharters.ItemIndex] as TCharter;
    }

    if aCharter.Config(Self) then
      RefreshList;
    //  ModalResult := mrOK;
  end;
end;
{
procedure TCharterDialog.ListChartersClick(Sender: TObject);
begin
  ButtonConfig.Enabled := (ListCharters.ItemIndex >= 0);
end;
}
procedure TCharterDialog.ButtonDelClick(Sender: TObject);
var
  aCharter : TCharter;
  iSelected : Integer;
begin
  if Assigned(ListViewCharters.Selected) then
  begin
    iSelected := ListViewCharters.Selected.Index;
    FDeletedCharter := TCharter(FIndicates.Items[iSelected]);
    FDelCharters.Add(FDeletedCharter);
    FIndicates.Delete(iSelected);
    RefreshList;
  end;
  {
  if ListCharters.ItemIndex >= 0 then
    FDeletedCharter := ListCharters.Items.Objects[ListCharters.ItemIndex] as TCharter;
  }
end;

procedure TCharterDialog.CopyList(aList: TList);
begin
  aList.Assign( FIndicates );
end;

procedure TCharterDialog.FormCreate(Sender: TObject);
begin
  FDeletedCharter := nil;
  FIndicates := TList.Create;
  FDelCharters := TList.Create;


end;

procedure TCharterDialog.ListViewChartersClick(Sender: TObject);
begin
  if Assigned(ListViewCharters.Selected) then
  begin
    ButtonConfig.Enabled := True;
    ButtonDel.Enabled := True;
  end else
  begin
    ButtonConfig.Enabled := False;
    ButtonDel.Enabled := False;
  end;

end;

procedure TCharterDialog.ListViewChartersData(Sender: TObject; Item: TListItem);
var
  i : integer;
  aListItem : TListItem;
  aIndicator : TIndicator;
begin      {
  i := Item.Indent;

  aIndicator := TIndicator(FIndicates.Items[i]);
  aListItem := ListViewCharters.Items.Add;
  aListItem.Data  := aindicator;
  aListItem.Caption := aIndicator.Title;
  aListItem.SubItems.Add(' '+aIndicator.ParamDesc);
  }
end;

procedure TCharterDialog.ListViewChartersDblClick(Sender: TObject);
var
  aCharter : TCharter;
begin
  //if ListViewCharters.Selected.Index >= 0 then
  if Assigned(ListViewCharters.Selected) then
  begin
    if Assigned(FIndicates.Items[ListViewCharters.Selected.Index]) then
      aCharter := TCharter(FIndicates.Items[ListViewCharters.Selected.Index]);

    if aCharter.Config(Self) then
      RefreshList;
      //ModalResult := mrOK;
  end;
end;

procedure TCharterDialog.FormDestroy(Sender: TObject);
begin
  FIndicates.Free;
  FDelCharters.Free;
end;

procedure TCharterDialog.AddIndicator(aIndicator : TIndicator);
var
  i : Integer;
  aListItem : TListItem;
begin
  //ListViewCharters.Items.Clear;
  FIndicates.Add(aIndicator);
  {
  for i := 0 to FIndicates.Count - 1 do
  with TIndicator(FIndicates.Items[i]) do
  begin
    aListItem := ListViewCharters.Items.Add;
    aListItem.Caption := Title;

  end;
  }
end;

procedure TCharterDialog.SetDelCharters(const Value: TList);
begin
  FDelCharters := Value;
end;

procedure TCharterDialog.RefreshList;
var
  i , j : Integer;
  aListItem : TListItem;
  aIndicator : TIndicator;
  stParam : String;
begin
  ListViewCharters.Items.Clear;

  for i := 0 to FIndicates.Count - 1 do
  begin
    aIndicator := TIndicator(FIndicates.Items[i]);
    aListItem := ListViewCharters.Items.Add;
    aListItem.Data  := aindicator;
    aListItem.Caption := aIndicator.Title;
    aListItem.SubItems.Add(' '+aIndicator.ParamDesc);
  end;

  if Assigned(ListViewCharters.Selected) then
  begin
    ButtonConfig.Enabled := True;
    ButtonDel.Enabled := True;
  end else
  begin
    ButtonConfig.Enabled := False;
    ButtonDel.Enabled := False;
  end;
end;

procedure TCharterDialog.ListViewChartersDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i, iSelIndex, iDropIndex : integer;
  aList : TList;
  aIndicator : TIndicator;
begin
  if Sender = Source then
  begin

    try

      aList := TList.Create;
      aList.Assign(FIndicates);

      iSelindex  := -1;
      iDropIndex := -1;

      iSelIndex  := ListViewCharters.Selected.Index;
      iDropIndex  := ListViewCharters.DropTarget.Index;

      if (iSelIndex < 0) or (iSelIndex > aList.Count - 1)  then
      begin
        aList.Free;
        exit;
      end;
      if (iDropIndex < 0) or (iDropIndex > aList.Count - 1)  then
      begin
        aList.Free;
        exit;
      end;

      aList.Exchange(iSelIndex, iDropIndex);
      FIndicates.Assign( aList );
      RefreshList;

    finally
      aList.Free;
    end;
  end;

end;

procedure TCharterDialog.ListViewChartersDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = ListViewCharters;
end;

procedure TCharterDialog.ListViewChartersDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListViewDrawItem(Sender as TListView , Item , Rect , State , nil);
end;

end.
