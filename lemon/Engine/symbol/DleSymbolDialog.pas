unit DleSymbolDialog;

// symbol selection dialog
// (c) All rights reserved.

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, CheckLst, ExtCtrls, Grids, ComCtrls, Menus, CommCtrl,
    // lemon: common
  GleLib, GleConsts,
    // lemon: data
  CleSymbolCore, CleSymbols, CleMarkets, CleFQN;

type
  TSymbolDialog = class(TForm)
    SpeedButton3: TSpeedButton;
    ListSelected: TListView;
    StatusBarSelected: TStatusBar;
    PageTypes: TPageControl;
    TabFutures: TTabSheet;
    Bevel1: TBevel;
    Label8: TLabel;
    ComboBoxFuturesMarkets: TComboBox;
    ListViewFutures: TListView;
    TabOptions: TTabSheet;
    Bevel2: TBevel;
    Label2: TLabel;
    Label7: TLabel;
    StringGridOptions: TStringGrid;
    HeaderControl2: THeaderControl;
    ComboBoxOptionMarkets: TComboBox;
    ComboBoxOptionMonths: TComboBox;
    TabCombi: TTabSheet;
    Label3: TLabel;
    Bevel3: TBevel;
    Label5: TLabel;
    ListCombiSymbols: TListView;
    ListViewSpread: TListView;
    ComboBoxSpreadMarkets: TComboBox;
    TabIndex: TTabSheet;
    ListViewIndex: TListView;
    TabSheet1: TTabSheet;
    Bevel5: TBevel;
    Label11: TLabel;
    ListViewStock: TListView;
    Edit1: TEdit;
    TabSheet2: TTabSheet;
    Bevel4: TBevel;
    Label9: TLabel;
    Label10: TLabel;
    StringGridELWs: TStringGrid;
    HeaderControl1: THeaderControl;
    ComboBoxELWMarkets: TComboBox;
    ComboBoxELWMonths: TComboBox;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    ButtonHelp: TButton;
    SpeedButtonRemove: TSpeedButton;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Bevel6: TBevel;
    Label4: TLabel;
    ComboBoxIndexMarkets: TComboBox;
    ComboBoxStockMarkets: TComboBox;
    Label6: TLabel;
    procedure ComboBoxMarketsChange(Sender: TObject);
    procedure ComboBoxMonthsChange(Sender: TObject);
    procedure StringGridOptionsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ListDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure StringGridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure PageTypesChange(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure ButtonMoveClick(Sender: TObject);
    procedure ListSelectedDblClick(Sender: TObject);
    procedure SymbolDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SymbolMove(Sender: TObject);
    procedure ListSelectedSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FSymbolCore: TSymbolCore;

    FSelected : TSymbol;
    FMoveSelected: TSymbol;

      // set controls
    procedure SetListViewSymbols(aListView: TListView; aMarket: TMarket);
    procedure SetStringGridOptions(aGrid: TStringGrid; aTree: TOptionTree);
    procedure SetComboBoxMonths(aComboBox: TComboBox; aMarket: TMarket);
      // select symbol
    procedure SelectSymbol(aSymbol : TSymbol);
      // get set
    procedure SetMarket(aMarket : TMarketType);
    procedure SetSymbolCore(aCore: TSymbolCore);
    function GetSelected(i:Integer) : TSymbol;
    function GetSelCount : Integer;
  public
    function Open: Boolean;
    procedure Add(aSymbol : TSymbol); // add a selected symbol
      //
    property SymbolCore: TSymbolCore read FSymbolCore write SetSymbolCore;
      // selection
    property SelCount: Integer read GetSelCount;
    property Selected: TSymbol read FSelected;
    property Selecteds[i:Integer] : TSymbol read GetSelected;
      // control
    property Market: TMarketType write SetMarket;
  end;

implementation

{$R *.DFM}

procedure TSymbolDialog.FormCreate(Sender: TObject);
begin
end;

//----------------------------------------------------------------< get/set >

function TSymbolDialog.GetSelCount: Integer;
begin
  Result := ListSelected.Items.Count;
end;

function TSymbolDialog.GetSelected(i: Integer): TSymbol;
begin
  if (i>=0) and (i < ListSelected.Items.Count) then
    Result := TSymbol(ListSelected.Items[i].Data)
  else
    Result := nil;
end;

procedure TSymbolDialog.SetSymbolCore(aCore: TSymbolCore);
begin
  if aCore = nil then Exit;

  FSymbolCore := aCore;

    // set combobox
  FSymbolCore.FutureMarkets.GetList(ComboBoxFuturesMarkets.Items);
  FSymbolCore.OptionMarkets.GetList(ComboBoxOptionMarkets.Items);
  FSymbolCore.SpreadMarkets.GetList(ComboBoxSpreadMarkets.Items);
  FSymbolCore.IndexMarkets.GetList(ComboBoxIndexMarkets.Items);
  FSymbolCore.StockMarkets.GetList(ComboBoxStockMarkets.Items);
  FSymbolCore.ELWMarkets.GetList(ComboBoxELWMarkets.Items);

    // select the first index
  SetComboIndex(ComboBoxFuturesMarkets, 0);
  SetComboIndex(ComboBoxOptionMarkets, 0);
  SetComboIndex(ComboBoxSpreadMarkets, 0);
  SetComboIndex(ComboBoxIndexMarkets, 0);
  SetComboIndex(ComboBoxStockMarkets, 0);
  SetComboIndex(ComboBoxELWMarkets, 0);

    // set symbol list
  ComboBoxMarketsChange(ComboBoxFuturesMarkets);
  ComboBoxMarketsChange(ComboBoxOptionMarkets);
  ComboBoxMarketsChange(ComboBoxSpreadMarkets);
  ComboBoxMarketsChange(ComboBoxIndexMarkets);
  ComboBoxMarketsChange(ComboBoxStockMarkets);
  ComboBoxMarketsChange(ComboBoxELWMarkets);
end;

//---------------------------------------------------------< market selection >

// (Published)
// market selected
//
procedure TSymbolDialog.ComboBoxMarketsChange(Sender: TObject);
var
  aObject: TObject;
begin
  if (Sender = nil) or not (Sender is TComboBox) then Exit;

  aObject := GetComboObject(Sender as TComboBox);
  if (aObject = nil) or not (aObject is TMarket) then Exit;

    //
  case (Sender as TComboBox).Tag of
    100: SetListViewSymbols(ListViewFutures, aObject as TMarket);
    200: SetComboBoxMonths(ComboBoxOptionMonths, aObject as TMarket);
    300: SetListViewSymbols(ListViewSpread, aObject as TMarket);
    400: SetListViewSymbols(ListViewIndex, aObject as TMarket);
    500: SetListViewSymbols(ListViewStock, aObject as TMarket);
    600: SetComboBoxMonths(ComboBoxELWMonths, aObject as TMarket);
  end;
end;

// (private)
// set listview for symbols
//
procedure TSymbolDialog.SetListViewSymbols(aListView: TListView; aMarket: TMarket);
var
  i : Integer;
  aItem : TListItem;
  aSymbol: TSymbol;
begin
  if (aListView = nil) or (aMarket = nil) then Exit;

    // clear existing symbol list
  aListView.Items.Clear;
  
    // populate listview
  for i := 0 to aMarket.Symbols.Count - 1 do
  begin
    aItem := aListView.Items.Add;
    aSymbol := aMarket.Symbols[i];

    aItem.Caption := aSymbol.Code;
    aItem.SubItems.Add(aSymbol.Name);
    aItem.Data := aSymbol;
  end;
end;

// (private)
procedure TSymbolDialog.SetComboBoxMonths(aComboBox: TComboBox; aMarket: TMarket);
begin
  if (aComboBox = nil) or (aMarket = nil)
     or not (aMarket is TOptionMarket) then Exit;

    // populate
  (aMarket as TOptionMarket).Trees.GetList(aComboBox.Items);

    // select the first month
  SetComboIndex(aComboBox, 0);

    // set option grid
  ComboBoxMonthsChange(aComboBox);
end;

// (private)
procedure TSymbolDialog.ComboBoxMonthsChange(Sender: TObject);
var
  aObject: TObject;
  aGrid: TStringGrid;
begin
  if (Sender = nil) or not (Sender is TComboBox) then Exit;

    // get selected object
  aObject := GetComboObject(Sender as TComboBox);
  if (aObject = nil) or not (aObject is TOptionTree) then Exit;

    // select string grid
  case (Sender as TComboBox).Tag of
    700: aGrid := StringGridOptions;
    800: aGrid := StringGridELWs;
    else
      Exit;
  end;

    //
  SetStringGridOptions(aGrid, aObject as TOptionTree);
end;

// (private)
procedure TSymbolDialog.SetStringGridOptions(aGrid: TStringGrid; aTree: TOptionTree);
var
  i: Integer;
  aStrike: TStrike;
begin
  if (aGrid = nil) or (aTree = nil) then Exit;

  aGrid.RowCount := aTree.Strikes.Count;

  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aStrike := aTree.Strikes[i];

      // strike price
    aGrid.Cells[1, i] := Format('%.2f', [aStrike.StrikePrice]);
      // call
    if aStrike.Call <> nil then
      aGrid.Objects[0,i] := aStrike.Call;
      // put
    if aStrike.Put <> nil then
      aGrid.Objects[2,i] := aStrike.Put;
  end;

    // todo: checking ATM routnine
end;

//---------------------------------------------------------< symbol selection >

procedure TSymbolDialog.PageTypesChange(Sender: TObject);
begin
  SelectSymbol(nil);
end;


// (published) TListView.OnSelectItem event handler
// select symbol in an ListView
//
procedure TSymbolDialog.ListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    SelectSymbol(TSymbol(Item.Data))
  else
    SelectSymbol(nil);
end;

// (published) TStringGrid.OnSelectCell event handler
// select symbol in an string grid
//
procedure TSymbolDialog.StringGridOptionsSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;
  
  if (aCol <> 1) and
     ((Sender as TStringGrid).Objects[aCol, aRow] <> nil) then
    CanSelect := True
  else
    CanSelect := False;
    
    //
  if CanSelect then
    SelectSymbol(TSymbol((Sender as TStringGrid).Objects[aCol,aRow]))
  else
    SelectSymbol(nil);
end;

// select symbol
procedure TSymbolDialog.SelectSymbol(aSymbol : TSymbol);
begin
  if aSymbol = nil then
  begin
    StatusBarSelected.SimpleText := '';
    FSelected := nil;
  end else
  begin
    StatusBarSelected.SimpleText := aSymbol.Code + ' : ' + aSymbol.Name;
    FSelected := aSymbol;
  end;
end;

//--------------------------------------------------------------------< open >

// (public)
//
function TSymbolDialog.Open: Boolean;
begin
  Result := (ShowModal = mrOK);
end;

// add to the selected symbol list
//
procedure TSymbolDialog.Add(aSymbol : TSymbol);
var
  i : Integer;
begin
  if aSymbol = nil then Exit;

    // has the same one?
  for i:=0 to ListSelected.Items.Count-1 do
    if ListSelected.Items[i].Data = aSymbol then
      Exit;
      
    //
  with ListSelected.Items.Add do
  begin
    Data := aSymbol;
    Caption := aSymbol.Code;
    SubItems.Add(aSymbol.Name);
  end;
end;

//--------------------------------------------------------------------< draw >

// 急拱 辆格
procedure TSymbolDialog.ListDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aListView : TListView;
  aSymbol : TSymbol;
begin
  if Item.Data = nil then Exit;
  //
  Rect.Bottom := Rect.Bottom-1;
  aListView := TListView(Sender);
  //
  with aListView.Canvas do
  begin
    aSymbol := TSymbol(Item.Data);
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

// 可记辆格
procedure TSymbolDialog.StringGridOptionsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aGrid: TStringGrid;
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  aGrid := Sender as TStringGrid;
  
  with aGrid.Canvas do
  begin
    Font.Name := aGrid.Font.Name;
    Font.Size := aGrid.Font.Size;

      // colors    
    if (aCol = 1) or (aGrid.Objects[aCol,aRow] = nil) then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;
    end else
    begin
      if (aCol=0) then
        Brush.Color:= SHORT_BG_COLOR
      else if (aCol=2) then
        Brush.Color:= LONG_BG_COLOR;
      Font.Color := clBlack;
    end;

      // background
    FillRect(Rect);

      // selection
    if (gdSelected in State) and
       (aGrid.Objects[aCol,aRow] = FSelected) then
    begin
      iY := Rect.Top + (Rect.Bottom - Rect.Top - 10) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - 10) div 2;
      Pen.Color := clBlue;
      Ellipse(iX,iY, iX+10, iY+10);
    end;
    //-- text
    stText := aGrid.Cells[aCol, aRow];
    if stText <> '' then
    begin
      //-- calc position
      aSize := TextExtent(stText);
      iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - aSize.cx) div 2;
      //-- put text
      TextRect(Rect, iX, iY, stText);
    end;
  end;
end;


//--------------< UI Events : Buttons >----------------//

procedure TSymbolDialog.ButtonOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TSymbolDialog.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TSymbolDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ButtonCancelClick(ButtonCancel);
end;

procedure TSymbolDialog.ButtonHelpClick(Sender: TObject);
begin
//  gHelp.Show(ID_SYMBOL);
end;

//--------------< UI Events : Move >-----------------------//

procedure TSymbolDialog.ButtonMoveClick(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    100 : // select an item
      Add(FSelected);
    200 : // unselect an item
      if ListSelected.Selected <> nil then
        ListSelected.Selected.Free;
    300 : // unselect all
      ListSelected.Items.Clear;
  end;
end;

procedure TSymbolDialog.ListSelectedDblClick(Sender: TObject);
begin
  ButtonMoveClick(SpeedButtonRemove);
end;

procedure TSymbolDialog.SymbolDblClick(Sender: TObject);
begin
  Add(FSelected);
end;

procedure TSymbolDialog.SymbolMove(Sender: TObject);
var
  iFlag, iMove: Integer;
  aTempSymbol: TSymbol;
  //
  iDir : Integer; // dir = direction
begin
    // 1. Check select count
  if ListSelected.SelCount <> 1 then Exit;

    // 2. Get selected
  iFlag:= ListSelected.Selected.Index;

    // 3. Get New Position
  case (Sender as TComponent).Tag of
    700: iDir := - 1;  // Up
    800: iDir := +1;   // Down
    else iDir := -1; // redundant
  end;
  if ((iDir < 0) and (iFlag > 0)) or
     ((iDir > 0) and (iFlag < ListSelected.Items.Count-1)) then
    iMove := iFlag + iDir
  else
    Exit;
    
    // 4. Swap
  aTempSymbol:= ListSelected.Items[iFlag].Data;
  ListSelected.Items[iFlag].Data := ListSelected.Items[iMove].Data;
  ListSelected.Items[iFlag].Caption := ListSelected.Items[iMove].Caption;
  ListSelected.Items[iFlag].SubItems[0] := ListSelected.Items[iMove].SubItems[0];
  ListSelected.Items[iMove].Data:= aTempSymbol;
  ListSelected.Items[iMove].Caption:= aTempSymbol.Code;
  ListSelected.Items[iMove].SubItems[0]:= aTempSymbol.Name;

    // 5. set selected & focused
  ListSelected.Items[iMove].Selected := True;
  ListSelected.Items[iMove].Focused := True;

    // 6. redraw
  ListSelected.Refresh;
end;

procedure TSymbolDialog.ListSelectedSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    FMoveSelected:= TSymbol(Item.Data)
  else
    FMoveSelected:= nil;
end;

procedure TSymbolDialog.SetMarket(aMarket: TMarketType);
begin
  case aMarket of
    //mtNotAssigned: ;
    //mtBond: PageTypes.ActivePageIndex := ;
    //mtETF: PageTypes.ActivePageIndex := ;
    mtFutures: PageTypes.ActivePageIndex := 0;
    mtOption:  PageTypes.ActivePageIndex := 1;
    mtSpread:  PageTypes.ActivePageIndex := 2;
    mtIndex:   PageTypes.ActivePageIndex := 3;
    mtStock:   PageTypes.ActivePageIndex := 4;
    mtELW:     PageTypes.ActivePageIndex := 5;
  end;
end;

end.
