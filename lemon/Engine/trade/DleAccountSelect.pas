unit DleAccountSelect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CommCtrl,

  CleAccounts, CleFunds, StdCtrls, ExtCtrls, ComCtrls
  ;

type
  TFrmAcntSelect = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    rbAccount: TRadioButton;
    rbFund: TRadioButton;
    rbTotal: TRadioButton;
    Panel3: TPanel;
    cbStay: TCheckBox;
    Button1: TButton;
    lstAcnt: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure rbTotalClick(Sender: TObject);
    procedure lstAcntDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstAcntSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FSelected: TObject;
    FModal   : boolean;
    procedure UpdateData;
    procedure UpdateAccount;
    procedure UpdateFund;
  public
    { Public declarations }

    function Open: Boolean;

    property Selected: TObject read FSelected;

  end;

var
  FrmAcntSelect: TFrmAcntSelect;

implementation

uses
  GAppEnv, GleConsts
  ;

{$R *.dfm}


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
    Font.Name := '????ü';
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    begin
      Font.Color := clBlack;
      if Item.Index mod 2 = 1 then
        Brush.Color := FIXED_COLOR
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


procedure TFrmAcntSelect.Button1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
  //Result := (ShowModal = mrOK);
end;

procedure TFrmAcntSelect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFrmAcntSelect.FormCreate(Sender: TObject);
begin
  FModal  := false;
{
  gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items);
  gEnv.Engine.TradeCore.Funds.GetList( cbAccount.Items );
  }
  UpdateData;
end;

procedure TFrmAcntSelect.lstAcntDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListViewDrawItem(Sender as TListView , Item , Rect , State, nil);
end;

procedure TFrmAcntSelect.lstAcntSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  //
  if Item.Data = nil then Exit;

  FSelected := Item.Data;

  if FSelected <> nil then
  begin
    ModalResult := mrOK;
    //if not cbStay.Checked then
    //  Hide;
  end;
end;

function TFrmAcntSelect.Open: Boolean;
begin
  UpdateData;
  FModal := true;
  Result := (ShowModal = mrOK);
end;

procedure TFrmAcntSelect.rbTotalClick(Sender: TObject);
begin
  UpdateData;
end;

procedure TFrmAcntSelect.UpdateData;
begin
  lstAcnt.Items.Clear;
  if rbTotal.Checked then
  begin
    UpdateAccount;
    UpdateFund;
  end else
  if rbAccount.Checked then
    UpdateAccount
  else if rbFund.Checked then
    UpdateFund;
end;

procedure TFrmAcntSelect.UpdateAccount;
var
  I: Integer;
  aAcnt : TAccount;
  aListItem : TListItem;
begin
  for I := 0 to gEnv.Engine.TradeCore.Accounts.Count - 1 do
  begin
    aACnt := gEnv.Engine.TradeCore.Accounts.Accounts[i];
    if aAcnt = nil then Continue;
    aListItem := lstAcnt.Items.Add;
    aListItem.Caption := '';
    aListItem.SubItems.Add(aAcnt.Name);
    aListItem.SubItems.Add(aAcnt.Code);
    aListITem.Data := aAcnt;
  end;
end;

procedure TFrmAcntSelect.UpdateFund;
var
  I: Integer;
  aFund : TFund;
  aListItem : TListItem;
begin
  for I := 0 to gEnv.Engine.TradeCore.Funds.Count - 1 do
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Funds[i];
    if aFund = nil then Continue;
    aListItem := lstAcnt.Items.Add;
    aListItem.Caption := '';
    aListItem.SubItems.Add(aFund.Name);
    //aListItem.SubItems.Add(aFund.Code);
    aListITem.Data := aFund;
  end;

end;

end.
