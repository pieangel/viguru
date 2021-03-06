unit DleSymbolSelect;

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
    StringGridELWTrees: TStringGrid;
    ComboBoxELWMarkets: TComboBox;
    Bevel6: TBevel;
    Label4: TLabel;
    ComboBoxIndexMarkets: TComboBox;
    ComboBoxStockMarkets: TComboBox;
    Label6: TLabel;
    StringGridELWs: TStringGrid;
    RadioButtonCall: TRadioButton;
    RadioButtonPut: TRadioButton;
    plSelected: TPanel;
    SpeedButtonRemove: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ListSelected: TListView;
    Label1: TLabel;
    Panel1: TPanel;
    ButtonHelp: TButton;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    Label10: TLabel;
    ComboBoxStockFutures: TComboBox;
    procedure StringGridELWsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridELWsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure RadioButtonCallPutClick(Sender: TObject);
    procedure StringGridELWTreesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGridELWTreesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
  private
    FSymbolCore: TSymbolCore;
    FMultiSelect : boolean;
    FSelected : TSymbol;
    FMoveSelected: TSymbol;
    procedure SelectELWSymbols(aList: TSymbolList);
    procedure SetStringGridELWTrees(aMarket: TMarket);

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
    procedure ShowMultiSelected;
    procedure SortByName;
  public
    function Open( bMulti : boolean = false ) : Boolean;

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

uses GAppEnv;

{$R *.DFM}

procedure TSymbolDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TSymbolDialog.FormCreate(Sender: TObject);
begin
  gSymbol := self;
  SetSymbolCore(gEnv.Engine.SymbolCore);

  with StringGridELWTrees do
  begin
    Cells[0,0] := 'Strike';
    Cells[1,0] := '~1m';
    Cells[2,0] := '1~3m';
    Cells[3,0] := '3~6m';
    Cells[4,0] := '6m~';
  end;

  with StringGridELWs do
  begin
    Cells[0,0] := 'Code';
    Cells[1,0] := 'Issuer';
    Cells[2,0] := 'LP';
    Cells[3,0] := 'Days';
  end;
end;

procedure TSymbolDialog.FormDestroy(Sender: TObject);
begin
  gSymbol := nil;
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


function CompareName(Data1, Data2: Pointer): Integer;
var
  Order1: TMarket absolute Data1;
  Order2: TMarket absolute Data2;
begin
  if Order1.Spec.Description > Order2.Spec.Description then
    Result := 1
  else if Order1.Spec.Description < Order2.Spec.Description then
    Result := -1
  else
    Result := 0;
end;

procedure TSymbolDialog.SortByName;
begin
  //Sort(CompareName);
end;

procedure TSymbolDialog.SetSymbolCore(aCore: TSymbolCore);
begin
  if aCore = nil then Exit;

  FSymbolCore := aCore;
    // set combobox
  FSymbolCore.FutureMarkets.GetList2(ComboBoxFuturesMarkets.Items);
  FSymbolCore.FutureMarkets.GetList3(ComboBoxStockFutures.Items);

  FSymbolCore.OptionMarkets.GetList(ComboBoxOptionMarkets.Items);
  FSymbolCore.SpreadMarkets.GetList(ComboBoxSpreadMarkets.Items);
  FSymbolCore.IndexMarkets.GetList(ComboBoxIndexMarkets.Items);
  FSymbolCore.StockMarkets.GetList(ComboBoxStockMarkets.Items);
  FSymbolCore.ELWMarkets.GetList(ComboBoxELWMarkets.Items);

    // select the first index
  SetComboIndex(ComboBoxFuturesMarkets, 0);
  SetComboIndex(ComboBoxStockFutures, 0);
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

  ComboBox_AutoWidth( ComboBoxStockFutures );
  ComboBox_AutoWidth( ComboBoxFuturesMarkets );
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
    600: SetStringGridELWTrees(aObject as TMarket);
  end;
end;

procedure TSymbolDialog.RadioButtonCallPutClick(Sender: TObject);
begin
  ComboBoxMarketsChange(ComboBoxELWMarkets);
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

    aItem.Caption := aSymbol.ShortCode;
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
  aComboBox.Items.Clear;
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
  ivar, i: Integer;
  aStrike: TStrike;
begin
  if (aGrid = nil) or (aTree = nil) then Exit;

  aGrid.RowCount := aTree.Strikes.Count;

  ivar  := //10;//
  FSymbolCore.GetCustomATMIndex( GetATM(FSymbolcore.Future.Last  ), 0 );

  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aStrike := aTree.Strikes[i];

    if i= ivar then
      aGrid.Objects[1,i]  := Pointer(integer( clYellow ));

      // strike price
    aGrid.Cells[1, i] := Format('%.2f', [aStrike.StrikePrice]);
      // call
    if aStrike.Call <> nil then begin
      aGrid.Objects[0,i] := aStrike.Call;
      aGrid.Cells[0,i]   := Format('%.2f', [ aStrike.Call.Last ] );
    end
    else
      aGrid.Objects[0,i] := nil;
      // put
    if aStrike.Put <> nil then begin
      aGrid.Objects[2,i] := aStrike.Put;
      aGrid.Cells[2, i]  := format('%.2f', [ aStrike.Put.Last ]);
    end
    else
      aGrid.Objects[2,i] := nil
  end;

    // todo: checking ATM routnine
end;

procedure TSymbolDialog.SetStringGridELWTrees(aMarket: TMarket);
var
  aELWMarket: TELWMarket;
  aTree: TELWTree;
  aStrike: TELWStrike;
  i, j, iCol, iRow: Integer;
begin
  if (aMarket = nil) or not (aMarket is TELWMarket) then Exit;

    // clear ELW table
  StringGridELWs.RowCount := 1;

    // map
  aELWMarket := aMarket as TELWMarket;
  aELWMarket.MapStrikes;

    // set grid
  with StringGridELWTrees do
  begin
      // delete all cells
    RowCount := 1;
    
      // set rows
    RowCount := aELWMarket.StrikeCodes.Count + 1;
      // set strikes
    for i := 0 to aELWMarket.StrikeCodes.Count - 1 do
      Cells[0, i+1] := aELWMarket.StrikeCodes[i];

      // set cells
    for i := 0 to aELWMarket.ELWTrees.Count - 1 do
    begin
      aTree := aELWMarket.ELWTrees[i];
      iCol := i+1;

      for j := 0 to aTree.Strikes.Count - 1 do
      begin
        aStrike := aTree.Strikes[j];

        iRow := aStrike.StrikeIndex + 1;
        if iRow > 0 then
        begin
          if RadioButtonCall.Checked then
          begin
            Cells[iCol, iRow] := IntToStr(aStrike.Calls.Count);
            Objects[iCol, iRow] := aStrike.Calls;
          end else
          begin
            Cells[iCol, iRow] := IntToStr(aStrike.Puts.Count);
            Objects[iCol, iRow] := aStrike.Puts;
          end;
        end;
      end;
    end;
  end;
end;

//---------------------------------------------------------< symbol selection >

procedure TSymbolDialog.PageTypesChange(Sender: TObject);
begin
  SelectSymbol(nil);
end;

procedure TSymbolDialog.Panel1Click(Sender: TObject);
begin

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
    FSelected := aSymbol;
end;

procedure TSymbolDialog.StringGridELWTreesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  CanSelect := (aCol <> 0) and (aRow <> 0)
               and ((Sender as TStringGrid).Objects[aCol, aRow] <> nil);

    //
  if CanSelect then
    SelectELWSymbols(TSymbolList((Sender as TStringGrid).Objects[aCol,aRow]));
end;

procedure TSymbolDialog.SelectELWSymbols(aList: TSymbolList);
var
  i: Integer;
  aELW: TELW;
begin
  if aList = nil then Exit;

  with StringGridELWs do
  begin
      // clear
    RowCount := 1;
      // set row count
    RowCount := aList.Count+1;

      // set symbols
    for i := 0 to aList.Count - 1 do
    begin
      aELW := aList[i] as TELW;

      Cells[0,i+1] := aELW.ShortCode;
      Cells[1,i+1] := aELW.Issuer;
      Cells[2,i+1] := aELW.LPCode;
      Cells[3,i+1] := IntToStr(aELW.DaysToExp);

      Objects[0, i+1] := aELW;
      Objects[1, i+1] := aELW;
      Objects[2, i+1] := aELW;
      Objects[3, i+1] := aELW;
    end;
  end;
end;

procedure TSymbolDialog.StringGridELWsSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  aELW: TELW;
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  CanSelect := (aRow <> 0)
               and((Sender as TStringGrid).Objects[aCol, aRow] <> nil);

    //
  if CanSelect then
  begin
    aELW := (Sender as TStringGrid).Objects[aCol,aRow] as TELW;
    SelectSymbol(aELW);
    //Add(aELW.Underlying);
  end else
    SelectSymbol(nil);
end;


//--------------------------------------------------------------------< open >

// (public)
//
procedure TSymbolDialog.ShowMultiSelected;
begin
  if FMultiSelect then
  begin
    Height := 537;
    plSelected.Visible := true;
  end
  else begin
    Height := 537 - plSelected.Height;
    plSelected.Visible := false;
  end;

end;

function TSymbolDialog.Open( bMulti : boolean ): Boolean;
begin
  FMultiSelect  := bMulti;
  //FSelected := nil;
  ListViewFutures.ItemIndex := -1;
  ShowMultiSelected;
  ListSelected.Clear;
  ComboBoxMonthsChange(ComboBoxOptionMonths);
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
    Caption := aSymbol.ShortCode;
    SubItems.Add(aSymbol.Name);
  end;
end;

//--------------------------------------------------------------------< draw >

// ???? ????
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

// ????????
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

      // selection
    if (gdSelected in State) and
       (aGrid.Objects[aCol,aRow] = FSelected) then
    begin
    {
      iY := Rect.Top + (Rect.Bottom - Rect.Top - 10) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - 10) div 2;
      Pen.Color := clBlue;
      Ellipse(iX,iY, iX+10, iY+10);
      }
      if (aCol=0) then
        Brush.Color:= clBlue
      else if (aCol=2) then
        Brush.Color:= clRed;
      Font.Color := clwhite;
    end;

    if (aCol = 1) and ( aGrid.Objects[1,ARow] <> nil ) then
      Brush.Color := TColor(integer(aGrid.Objects[1,ARow]));

      // background
    FillRect(Rect);

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

// ELW Trees
procedure TSymbolDialog.StringGridELWTreesDrawCell(Sender: TObject; ACol,
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
    if (aCol = 0) or (aRow = 0)  then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;
    end else
    begin
      if gdSelected in State then
      begin
        Brush.Color := clBlue;
        Font.Color := clWhite;
      end else
      begin
        if RadioButtonCall.Checked then
          Brush.Color:= LONG_BG_COLOR
        else
          Brush.Color:= SHORT_BG_COLOR;

        Font.Color := clBlack;
      end;
    end;

      // background
    FillRect(Rect);

      // draw text
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

procedure TSymbolDialog.StringGridELWsDrawCell(Sender: TObject; ACol,
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
    if aRow = 0 then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;
    end else
    begin
      if gdSelected in State then
      begin
        Brush.Color := clBlue;
        Font.Color := clWhite;
      end else
      begin
        Brush.Color := clWhite;
        Font.Color := clBlack;
      end;
    end;

      // background
    FillRect(Rect);

      // draw text
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
  if not FMultiSelect then
    ModalResult := mrOK
  else
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
  ListSelected.Items[iMove].Caption:= aTempSymbol.ShortCode;
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
