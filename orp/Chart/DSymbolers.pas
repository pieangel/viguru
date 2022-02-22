unit DSymbolers;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ImgList, ComCtrls, CommCtrl,


  CleSymbols, CleAccounts,
  ChartIF,
  Symbolers, Charters,
  GleConsts,
  DSymbolerCfg;

type
  TSymbolersDlg = class(TForm)
    ListViewSymbols: TListView;
    ImageList1: TImageList;
    ButtonConfig: TButton;
    Button2: TButton;
    ButtonDelete: TButton;
    ButtonHelp: TButton;
    PanelBase: TPanel;
    PanelPeriod: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewSymbolsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ButtonConfigClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ListViewSymbolsDblClick(Sender: TObject);
  private
    { Private declarations }
    FSymbolers : TList;
    FDeleteds : TList;

    procedure RefreshTopData;
    procedure RefreshList;
  public
    { Public declarations }
    procedure AddSymboler(aSymboler : TSymboler);
    function Execute : Boolean;

    property Deleteds : TList read FDeleteds write FDeleteds;
  end;

var
  SymbolersDlg: TSymbolersDlg;

implementation

{$R *.DFM}

procedure ListSymbolersDrawItem(ListView: TListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState; Statusbar : TStatusBar = nil);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aColorRect : TRect;
  aChartColor, aColor : TColor;
  aSymboler : TSymboler;
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
        else iX := iLeft + 2; // redundant coding
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);

      if (i = 6) and (Item.Data <> nil) then
      begin
        aSymboler := TSymboler(Item.Data);
        aColorRect := Classes.Rect(iLeft, Rect.Top,
           iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom);
        aColor := Brush.Color;
        Brush.Color := aSymboler.ChartColor;
        FillRect(aColorRect);
        Brush.Color := aColor;
      end;

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


procedure TSymbolersDlg.AddSymboler(aSymboler: TSymboler);
begin
  FSymbolers.Add(aSymboler);
end;

function TSymbolersDlg.Execute : Boolean;
var
  aSymboler : TSymboler;
  stBase, stPeriod : String;
begin
  RefreshList;
  RefreshTopData;

  if ShowModal = mrOk then
    Result := True
  else
    Result := False;
end;

procedure TSymbolersDlg.FormCreate(Sender: TObject);
begin
  FSymbolers := TList.Create;
  FDeleteds := TList.Create;

end;

procedure TSymbolersDlg.FormDestroy(Sender: TObject);
begin
  FSymbolers.Free;
  FDeleteds.Free;
end;

procedure TSymbolersDlg.RefreshTopData;
var
  i : Integer;
  stPeriod , stBase : String;
begin
  for i := 0 to FSymbolers.Count-1 do
  with TSymboler(FSymbolers.Items[i]) do
    if SymbolerMode = smMain then
    begin
      case XTerms.Base of
        cbTick : stBase := '틱';
        cbMin : stBase := '분';
        cbDaily : stBase := '일';
        cbWeekly : stBase := '주';
        cbMonthly : stBase := '월';
        else stBase := '';
      end;
      PanelBase.Caption := ' 단위 : '+ stBase;
      stPeriod := IntToStr(XTerms.Period);
      PanelPeriod.Caption := ' 표시 단위 : '+stPeriod;
    end;
end;


procedure TSymbolersDlg.RefreshList;
var
  i : Integer;
  aSymboler : TSymboler;
  aListItem : TListItem;
begin
  ListViewSymbols.Items.Clear;
  for i := 0 to FSymbolers.Count-1 do
  begin
    aSymboler := TSymboler(FSymbolers.Items[i]);
    aListItem := ListViewSymbols.Items.Add;
    aListItem.Data := aSymboler;

    if aSymboler.SymbolerMode = smMain then
      aListItem.SubItems.Add('주')
    else
      aListItem.SubItems.Add('부');

    if aSymboler.DataXTerms.Symbol = nil then
      aListItem.SubItems.Add('N/A')
    else
      aListItem.SubItems.Add(aSymboler.DataXTerms.Symbol.Code);

    case aSymboler.ChartStyle of
      ssOHLC : aListItem.SubItems.Add('OHLC');
      ssCandle : aListItem.SubItems.Add('CANDLE');
      ssLine : aListItem.SubItems.Add('LINE');
    end;

    case aSymboler.Position of
      cpMainGraph : aListItem.SubItems.Add('기본');
      cpSubGraph : aListItem.SubItems.Add('부속');
    end;

    case aSymboler.ScaleType of
      stScreen : aListItem.SubItems.Add('화면');
      stEntire : aListItem.SubItems.Add('전체');
      stSymbol : aListItem.SubItems.Add('종목');
    end;

    if aSymboler.ShowFill then
      aListItem.SubItems.Add('Y')
    else
      aListItem.SubItems.Add('N');

    aListItem.SubItems.Add(' ');

  end;


end;

procedure TSymbolersDlg.ListViewSymbolsDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListSymbolersDrawItem(Sender as TListView, Item, Rect, State);
end;

procedure TSymbolersDlg.ButtonConfigClick(Sender: TObject);
var
  i : Integer;
  aSymboler, aUseSymboler : TSymboler;
  aPreSymbol : TSymbol;
  aDlg : TSymbolerConfig;
  aPosition : TCharterPosition;
  bViewFill : Boolean;

begin
  if (ListViewSymbols.Selected = nil) or
        (ListViewSymbols.Selected.Data = nil) then Exit;

  aSymboler := TSymboler(ListViewSymbols.Selected.Data);
  aPosition := aSymboler.Position;
  aPreSymbol := aSymboler.DataXTerms.Symbol;

  if aPreSymbol = nil then Exit;

  bViewFill := aSymboler.ShowFill;

  aDlg := TSymbolerConfig.Create(Self);
  try
    for i := 0 to aSymboler.UsedSymbols.Count-1 do
      aDlg.AddUsedSymbol(TSymbol(aSymboler.UsedSymbols.Items[i]));

    if aDlg.Execute(aSymboler) then
    begin
      for i := 0 to FSymbolers.Count-1 do
      begin
        aUseSymboler := TSymboler(FSymbolers.Items[i]);
        if aUseSymboler.UsedSymbols.IndexOf(aSymboler.DataXTerms.Symbol)<0 then
          aUseSymboler.UsedSymbols.Insert(0, aSymboler.DataXTerms.Symbol);
      end;         //다른 곳에서도...

      //if aSymboler.UsedSymbols.IndexOf(aSymboler.DataXTerms.Symbol)<0 then
      //  aSymboler.UsedSymbols.Insert(0, aSymboler.DataXTerms.Symbol);

      if (aPosition <> aSymboler.Position) and Assigned(aSymboler.OnMove) then
        aSymboler.OnMove(aSymboler);

      if bViewFill <> aSymboler.ShowFill then
      begin
        if aSymboler.ShowFill then
          aSymboler.GetFill
        else
          aSymboler.ClearFill;
      end;

      RefreshTopData;
      RefreshList;
    end;

  finally
    aDlg.free;
  end;
end;

procedure TSymbolersDlg.ButtonDeleteClick(Sender: TObject);
var
  aSymboler : TSymboler;
begin
  if (ListViewSymbols.Selected = nil) or
        (ListViewSymbols.Selected.Data = nil) then Exit;

  aSymboler := TSymboler(ListViewSymbols.Selected.Data);

  if aSymboler.SymbolerMode = smMain then
  begin
    ShowMessage('주 종목을 삭제 할 수 없습니다');
    Exit;
  end;

  FDeleteds.Add(aSymboler);
  FSymbolers.Delete(ListViewSymbols.Selected.Index);
  RefreshList;
end;

procedure TSymbolersDlg.ListViewSymbolsDblClick(Sender: TObject);
begin
  ButtonConfigClick(ButtonConfig);
end;


end.
