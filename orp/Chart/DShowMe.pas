unit DShowMe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, CommCtrl,
  Dialogs, StdCtrls, ComCtrls, GleConsts, GleLib, ChartCentral, Shows;

type
  TShowMeCfg = class(TForm)
    ListViewCharters: TListView;
    ButtonConfig: TButton;
    Button2: TButton;
    ButtonDel: TButton;
    Button1: TButton;
    procedure ListViewChartersClick(Sender: TObject);
    procedure ListViewChartersDblClick(Sender: TObject);
    procedure ListViewChartersDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure ButtonConfigClick(Sender: TObject);
    procedure ButtonDelClick(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    ShowMe  : TShowMes;
    procedure RefreshList;
    function Config( aItem : TShowMeItem ) : boolean ;
  end;

procedure ListViewDrawItem(ListView: TListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState; Statusbar : TStatusBar);

var
  ShowMeCfg: TShowMeCfg;

implementation

uses DShowmeParamCfg;

{$R *.dfm}

procedure TShowMeCfg.ButtonConfigClick(Sender: TObject);
var
  aItem : TShowMeItem;
begin

  if ListViewCharters.Selected = nil then Exit;
  if ListViewCharters.Selected.Index >= 0 then
  begin
    aItem := TShowMeItem(ShowMe.Items[ListViewCharters.Selected.Index]);

    if Config(aItem) then
      RefreshList;

  end;
end;

procedure TShowMeCfg.ButtonDelClick(Sender: TObject);
var
  aItem : TShowMeItem;
  iSelected : Integer;
begin
  if Assigned(ListViewCharters.Selected) then
  begin
    iSelected := ListViewCharters.Selected.Index;
    aItem := TShowMeItem(ShowMe.Items[iSelected]);
    aItem.EnAbled := false;
    RefreshList;
  end;

end;

function TShowMeCfg.Config(aItem : TShowMeItem) : boolean;
var
  aDlg : TShowMeParamCfg;
  i : integer;
begin
  Result := false;
  aDlg := TShowMeParamCfg.Create( self );
  try
    if aDlg.Open( aItem ) then
      Result := true;
  finally
    aDlg.Free;
  end;

end;

procedure TShowMeCfg.FormCreate(Sender: TObject);
begin
  //ShowMe  :=
end;

procedure TShowMeCfg.ListViewChartersClick(Sender: TObject);
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

procedure TShowMeCfg.ListViewChartersDblClick(Sender: TObject);
var
  aItem : TShowMeItem;
begin

  //if ListViewCharters.Selected.Index >= 0 then
  if Assigned(ListViewCharters.Selected) then
  begin
    if Assigned(ShowMe.Items[ListViewCharters.Selected.Index]) then
      aItem := TShowMeItem(ShowMe.Items[ListViewCharters.Selected.Index]);

    if Config(aItem) then
      RefreshList;
  end;

end;
procedure TShowMeCfg.RefreshList;
var
  i , j : Integer;
  aListItem : TListItem;
  aItem : TShowMeItem;
  stParam : String;
begin
  ListViewCharters.Items.Clear;

  for i := 0 to ShowMe.Count - 1 do
  begin
    aItem := TShowMeItem(ShowMe.Items[i]);
    if not aItem.EnAbled then Continue;

    aListItem := ListViewCharters.Items.Add;
    aListItem.Caption := aItem.Name;
    aListItem.SubItems.Add(' '+aItem.Param);
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

procedure TShowMeCfg.ListViewChartersDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListViewDrawItem(Sender as TListView , Item , Rect , State , nil);
end;

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

end.
