unit DKMoniter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ExtCtrls, ComCtrls, StdCtrls, Commctrl,
  KeyOrderAgent, GleConsts

  ;


type
  TKMoniterDlg = class(TForm)
    ListLog: TListView;
    ListOpens: TListView;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    ImageList1: TImageList;
    EditSymbolA: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EditSymbolB: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListOpensDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListOpensSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    FSelectItem : TKeyOrderItem;

    procedure KeyLogProc(Sender : TObject; Key: Word; Shift: TShiftState; strAction : String);
  public
    { Public declarations }
  end;

var
  KMoniterDlg: TKMoniterDlg;

implementation

{$R *.dfm}

{ TKMoniterDlg }

procedure TKMoniterDlg.KeyLogProc(Sender: TObject; Key: Word;
  Shift: TShiftState; strAction: String);
var
  aList : TList;
  i : Integer;
  aItem : TKeyOrderItem;
  aListItem : TListItem;
begin

  try
  
    aListItem := ListLog.Items.Insert(0);
    aListItem.Caption := (Sender as TKeyOrderItem).KeyOrderMap;
    aListItem.SubItems.Add(strAction); // 파일이름

    if FSelectItem <> nil then
    begin
      EditSymbolA.Text := IntToStr(FSelectItem.SymbolAQty);
      EditSymbolB.Text := IntToStr(FSelectItem.SymbolBQty);
    end;


  finally

  end;


end;

procedure TKMoniterDlg.FormCreate(Sender: TObject);
var
  aList : TList;
  i : Integer;
  aItem : TKeyOrderItem;
  aListItem : TListItem;
begin
  aList := TList.Create;

  try
    gKeyOrderAgent.GetOpenList(aList);

    if aList.Count <= 0 then Exit;

    ListOpens.Items.Clear;

    for i:= 0 to aList.Count-1 do
    begin
      aItem := TKeyOrderItem( aList.Items[i] );

      aItem.OnLog := KeyLogProc;

      aListItem := ListOpens.Items.Add;
      aListItem.Data := aItem;
      aListItem.Caption := (aItem.Sender as TForm).Caption;
      aListItem.SubItems.Add(aItem.MapName); // 파일이름

      aItem.OnLog := KeyLogProc;
    end;


  finally
   aList.Free;
  end;


end;


procedure TKMoniterDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TKMoniterDlg.ListOpensDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aListView : TListView;
begin
  //
  Rect.Bottom := Rect.Bottom-1;
  aListView := TListView(Sender);
  //
  with aListView.Canvas do
  begin
    //-- colors
    if State >= [odSelected, odFocused] then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end;
    //--
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iLeft := Rect.Left;
    //-- background
    FillRect(Rect);
    //-- caption
    TextRect(
        Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,0), Rect.Bottom),
        Rect.Left + 2, iY, Item.Caption);
    //
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= aListView.Columns.Count then Break;
      //
//      iLeft := iLeft + aListView.Columns[i].Width;
      iLeft := iLeft + ListView_GetColumnWidth(aListView.Handle,i);
      //
      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);
      //
      case aListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft + (ListView_GetColumnWidth(aListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft + ListView_GetColumnWidth(aListView.Handle,i+1) - 2 - aSize.cx;
        else iX := iLeft + 2;
      end;
      TextRect(
          Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;


end;

procedure TKMoniterDlg.ListOpensSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin

  if ListOpens.Selected = nil then Exit;

  FSelectItem := TKeyOrderItem( ListOpens.Selected.Data );

  EditSymbolA.Text := IntToStr(FSelectItem.SymbolAQty);
  EditSymbolB.Text := IntToStr(FSelectItem.SymbolBQty);
end;

end.
