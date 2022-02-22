unit FServerMessage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, CommCtrl,
  Dialogs, ComCtrls,

  GleTypes
  ;

type
  TFrmServerMessage = class(TForm)
    lvLog: TListView;
    procedure lvLogDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure UpdateLog(iKind: integer; bNew: boolean = false );
    { Private declarations }
  public
    { Public declarations }
    procedure WMALogArrived(var msg: TMessage); message WM_LOGARRIVED;
  end;

var
  FrmServerMessage: TFrmServerMessage;

implementation

uses
  GAppEnv,CleLog,GleConsts
  ;


{$R *.dfm}

procedure TFrmServerMessage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFrmServerMessage.lvLogDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  ListView : TListView;
begin

  if (Item.Data = nil) then Exit;
  //
  Rect.Bottom := Rect.Bottom-1;       ;
  ListView := Sender as TListView;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clBlack;
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
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption);
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
        else iX := iLeft + 2; // redundant coding
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;

end;

procedure TFrmServerMessage.WMALogArrived(var msg: TMessage);
begin
  UpdateLog( msg.WParam );
end;

procedure TFrmServerMessage.UpdateLog( iKind : integer; bNew : boolean);
var
  stLine : string;
  aColor : TColor;
  iLast, i : integer;
  aItem : TAppLogItem;
  aList : TListItem;
  aKind : TLogKind;
begin

  if gAppLog = nil then Exit;

  if aKind = lkDebug then
  begin
    lvLog.Items.Count := 0;
    lvLog.Invalidate;
    Exit;
  end;

  if bNew then
  begin
    //lvLog.Items.Clear;
    lvLog.Items.Count := gAppLog.LogList[ lkError ].Count;
    lvLog.Invalidate;
  end else
  begin
    aList := lvLog.Items.Insert(0);
    aItem := gAppLog.LogList[ lkError ].LogItem[0];
    if aItem = nil then Exit;
    
    aList.Data  := aItem;
    aList.Caption := FormatDateTime( 'hh:nn:ss', aItem.LogTime );

    aList.SubItems.Add( aItem.LogTitle );
    aList.SubItems.Add( aItem.LogDesc );
    lvLog.Refresh;
  end;

  if lvLog.Items.Count > 0 then
  begin
    lvLog.Selected := lvLog.Items[0];
    lvLog.ItemFocused := lvLog.Items[0];
  end;

end;


end.
