unit DSymbol;

//==================================
//  종목선택창
//
//
//
//==================================

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, CheckLst, ExtCtrls, Grids, ComCtrls, Menus, CommCtrl,
  // App
  {
  AppTypes, AppConsts, AppUtils, Globals,
  HelpCentral, PriceCentral, SymbolStore
  }
  CleMarkets, GleConsts,
  CleSymbols, CleFQN , GleLib
  ;

type
  TSymbolSelectionMode = (smUnique, smMulti);
  //
  TSymbolDialog = class(TForm)
    Panel2: TPanel;
    PageTypes: TPageControl;
    TabFutures: TTabSheet;
    TabOptions: TTabSheet;
    GridOptions: TStringGrid;
    HeaderControl2: THeaderControl;
    TabCombi: TTabSheet;
    Label3: TLabel;
    Panel1: TPanel;
    Label1: TLabel;
    Panel3: TPanel;
    EditSelected: TEdit;
    Label2: TLabel;
    ComboOptUnders: TComboBox;
    ComboOptMonths: TComboBox;
    Label8: TLabel;
    ComboFutUnders: TComboBox;
    ListFutures: TListView;
    Label4: TLabel;
    ButtonSelect: TSpeedButton;
    ButtonUnselect: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    ButtonHelp: TButton;
    ListSelected: TListView;
    TabIndex: TTabSheet;
    ListIndex: TListView;
    ListCombi: TListView;
    ListCombiSymbols: TListView;
    BtnUp: TButton;
    BtnDown: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    ComboSpreadUnders: TComboBox;
    Label5: TLabel;

    procedure GridOptionsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ListDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure GridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
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
    procedure ComboBoxMonthsChange(Sender: TObject);
  private
    FIsForOrder : Boolean;
    FSelectionMode : TSymbolSelectionMode;

    FSelected : TSymbol;
    FMoveSelected: TSymbol;

    function GetSelected(i:Integer) : TSymbol;

    procedure PopulateCombiSymbols;
    procedure PopulateIndexSymbols;
    procedure PopulateStockSymbols;

    procedure SymbolSelect(aSymbol : TSymbol);
    procedure ComboBoxMarketsChange(Sender: TObject);
    procedure SetListViewSymbols(aListView: TListView; aMarket: TMarket);
    procedure SetComboBoxMonths(aComboBox: TComboBox; aMarket: TMarket);
    procedure ComboOptMonthsChange(Sender: TObject);
    procedure SetStringGridOptions(aGrid: TStringGrid; aTree: TOptionTree);

  public
    {
    function Open(aMode : TSymbolSelectionMode;
         UnderTypes : TUnderlyingTypes; DerivTypes : TDerivativeTypes;
         bCombi : Boolean = True; bIndex : Boolean = False;
         aComboBox : TComboBox = nil) : Boolean;  // 창 열기
    }
    function Open(aMode : TSymbolSelectionMode; aTypes : TMarketTypes;
               bOrder : Boolean; aUnderlying : TSymbol = nil; iSelectLimite : Integer = 0) : Boolean;
    procedure Add(aSymbol : TSymbol); // 선택종목 추가
    procedure SelectTab(stSymbolType : TMarketType);
    //
    function SelectCount : Integer;
    property Selected : TSymbol read FSelected;
    property Selecteds[i:Integer] : TSymbol read GetSelected;
  end;


function SelectSymbol(aForm : TForm; aTypes : TMarketTypes;
  bOrder : Boolean; aUnderly : TSymbol = nil) : TSymbol;

implementation

uses GAppEnv;

{$R *.DFM}

const
  WIDTHS : array[TSymbolSelectionMode] of Integer = (255, 576);

//---------------------< Service routines >---------------------//


function SelectSymbol(aForm : TForm; aTypes : TMarketTypes;
  bOrder : Boolean; aUnderly : TSymbol = nil) : TSymbol;  // 기초자산 선택가능
var
  aDlg : TSymbolDialog;
begin
  Result := nil;
  //
  aDlg := TSymbolDialog.Create(aForm);
  try
    if aDlg.Open(smUnique, aTypes, bOrder, aUnderly) then
      Result := aDlg.Selected;
  finally
    aDlg.Free;
  end;
end;

//==============================================================//
                      { TSymbolDialog }
//==============================================================//

procedure TSymbolDialog.FormCreate(Sender: TObject);
begin
  with gEnv.Engine do
  begin

    SymbolCore.FutureMarkets.GetList( ComboFutUnders.Items );
    SymbolCore.OptionMarkets.GetList( ComboOptUnders.Items );
    SymbolCore.SpreadMarkets.GetList( ComboSpreadUnders.Items );

    SetComboIndex( ComboFutUnders, 0 );
    SetComboIndex( ComboOptUnders, 0 );
    SetComboIndex( ComboSpreadUnders, 0 );

    ComboBoxMarketsChange(  ComboFutUnders );
    ComboBoxMarketsChange(  ComboOptUnders );
    ComboBoxMarketsChange(  ComboSpreadUnders );
  end;

end;

procedure TSymbolDialog.ComboBoxMarketsChange(Sender: TObject);
var
  aObject: TObject;
begin
  if (Sender = nil) or not (Sender is TComboBox) then Exit;

  aObject := GetComboObject(Sender as TComboBox);
  if (aObject = nil) or not (aObject is TMarket) then Exit;

    //
  case (Sender as TComboBox).Tag of
    100: SetListViewSymbols(ListFutures, aObject as TMarket);
    200: SetComboBoxMonths(ComboOptMonths, aObject as TMarket);
    300: SetListViewSymbols(ListCombi, aObject as TMarket);
  end;
end;

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
    {
  case (Sender as TComboBox).Tag of
    700: aGrid := StringGridOptions;
    800: aGrid := StringGridELWs;
    else
      Exit;
  end;
  }
    //
  aGrid := GridOptions;
  SetStringGridOptions(aGrid, aObject as TOptionTree);
end;

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
      aGrid.Objects[0,i] := aStrike.Call
    else
      aGrid.Objects[0,i] := nil;
      // put
    if aStrike.Put <> nil then
      aGrid.Objects[2,i] := aStrike.Put
    else
      aGrid.Objects[2,i] := nil
  end;

    // todo: checking ATM routnine
end;


procedure TSymbolDialog.ComboOptMonthsChange(Sender: TObject);
begin

end;

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


//---------------------< Property methods >--------------------//

function TSymbolDialog.SelectCount: Integer;
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

//--------------------< Public Methods >-----------------------//

function TSymbolDialog.Open(aMode : TSymbolSelectionMode; aTypes : TMarketTypes;
  bOrder : Boolean; aUnderlying : TSymbol = nil; iSelectLimite : Integer = 0) : Boolean;
begin
  FSelectionMode := aMode;
  FIsForOrder := bOrder;
  // resize
  Width := WIDTHS[FSelectionMode];
  if aUnderlying <> nil then
  begin
    TabFutures.TabVisible := ( aUnderlying.Spec.Market <> mtStock );
    //(aUnderlying.UnderlyingType <> utStock);
    TabOptions.TabVisible := True;
    TabCombi.TabVisible := False;
    TabIndex.TabVisible := False;

    SetComboIndex(ComboFutUnders, aUnderlying );
    SetComboIndex(ComboOptUnders, aUnderlying );
    ComboFutUnders.Enabled := False;
    ComboOptUnders.Enabled := False;
  end else
  begin
    //-- Select Derivative type
    TabFutures.TabVisible := (mtFutures in aTypes);
    TabOptions.TabVisible := (mtOption in aTypes);
    TabCombi.TabVisible := (mtSpread in aTypes);
    TabIndex.TabVisible := (mtIndex in aTypes) or (mtStock in aTypes);
  end;
  //-- populate list
  if TabFutures.TabVisible then ComboBoxMarketsChange(ComboFutUnders);
  if TabOptions.TabVisible then ComboBoxMarketsChange(ComboOptUnders);
  if TabCombi.TabVisible then PopulateCombiSymbols;
  if mtIndex in aTypes then PopulateIndexSymbols;
  if mtStock in aTypes then PopulateStockSymbols;
  //--Underly
    //ComboFutUnders

    //ComboOptUnders
  //--
  Result := (ShowModal = mrOK);
end;

// 다중 종목선택 추가
procedure TSymbolDialog.Add(aSymbol : TSymbol);
var
  i : Integer;
begin
  //
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

//---------------< UI Events : Init Data fields >------------//

//
//  Populate Spread Symbols
//
procedure TSymbolDialog.PopulateCombiSymbols;
var
  i : Integer;
  aItem : TListItem;
begin
  //with gPrice.SymbolStore do
  With gEnv.Engine.SymbolCore.Spreads do
  for i:=0 to Count-1 do
  begin
    aItem := ListCombi.Items.Add;
    aItem.Caption := Spreads[i].Code ;
    aItem.SubItems.Add(Spreads[i].Name);
    aItem.Data := Spreads[i];
  end;
end;

//
// Make List of Index symbols
//
procedure TSymbolDialog.PopulateIndexSymbols;
var
  i : Integer;
  aItem : TListItem;
begin
  //-- populate index symbols
  with gEnv.Engine.SymbolCore.Indexes do
  //with gPrice.SymbolStore do
  for i:=0 to Count-1 do
  begin
    aItem := ListIndex.Items.Add;
    aItem.Caption := Indexes[i].Code;
    aItem.SubItems.Add(Indexes[i].Name);
    aItem.Data := Indexes[i];
  end;
end;

procedure TSymbolDialog.PopulateStockSymbols;
var
  i : Integer;
  aItem : TListItem;
begin
  with gEnv.Engine.SymbolCore.Stocks do
  for i:=0 to Count-1 do
  begin
    aItem := ListIndex.Items.Add;
    aItem.Caption := Stocks[i].Code;
    aItem.SubItems.Add(Stocks[i].Name);
    aItem.Data := Stocks[i];
  end;
end;

const
  UNDERLYINGS : array[0..1] of TUnderlyingType = (utKospi200, utKosdaq50);



//-------------------< UI Events : Symbol Selection >-------------------//

// 종류선택
procedure TSymbolDialog.PageTypesChange(Sender: TObject);
var
  i : Integer;
begin
  SymbolSelect(nil);
  //-- unselect all
  if PageTypes.ActivePage = TabFutures then
    for i:=0 to ListFutures.Items.Count-1 do
      ListFutures.Items[i].Selected := False
  //--
  else if PageTypes.ActivePage = TabOptions then
    ComboOptMonths.SetFocus;
end;

// 선물 선택
procedure TSymbolDialog.ListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    SymbolSelect(TSymbol(Item.Data))
  else
    SymbolSelect(nil);
end;

// 옵션선택
procedure TSymbolDialog.GridOptionsSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (aCol <> 1) and
     (GridOptions.Objects[aCol, aRow] <> nil) then
    CanSelect := True
  else
    CanSelect := False;
  //
  if CanSelect then
    SymbolSelect(TSymbol(GridOptions.Objects[aCol,aRow]))
  else
    SymbolSelect(nil);
end;

// 종목 선택
procedure TSymbolDialog.SymbolSelect(aSymbol : TSymbol);
begin
  if aSymbol = nil then
  begin
    EditSelected.Text := '';
    FSelected := nil;
  end else
  begin
    EditSelected.Text := aSymbol.Code + ' : ' + aSymbol.Name;
    FSelected := aSymbol;
  end;
end;

//-------------------< UI Events : Draws >-------------------//

// 선물 종목
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

      if (aSymbol.Spec.Market <> mtIndex) and (not aSymbol.CanOrder) then
        Font.Color := DISABLED_COLOR
      else
        Font.Color := clWhite;
    end else
    begin
      Brush.Color := clWhite;

      if (aSymbol.Spec.Market <> mtIndex) and (not aSymbol.CanOrder) then
        Font.Color := DISABLED_COLOR
      else
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

// 옵션종목
procedure TSymbolDialog.GridOptionsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
begin
  with GridOptions.Canvas do
  begin
    Font.Name := GridOptions.Font.Name;
    Font.Size := GridOptions.Font.Size;
    if (aCol = 1) or
       ((GridOptions.Objects[aCol,aRow] <> nil) and
         not TSymbol(GridOptions.Objects[aCol,aRow]).CanOrder) then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;
    end else
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end;

    // 기초자산 현재가 근처의 값
    if (aCol=1) and (GridOptions.Objects[aCol, aRow] <> nil) then
    begin
      Brush.Color:= SELECTED_COLOR;
      Font.Color:= clWhite;
    end
    else if (aCol=0) then
      Brush.Color:= SHORT_COLOR
    else if (aCol=2) then
      Brush.Color:= LONG_COLOR;

    //-- background
    FillRect(Rect);
    //-- selection
    if (gdSelected in State) and
       (GridOptions.Objects[aCol,aRow] = FSelected) then
    begin
      iY := Rect.Top + (Rect.Bottom - Rect.Top - 10) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - 10) div 2;
      Pen.Color := clBlue;
      Ellipse(iX,iY, iX+10, iY+10);
    end;
    //-- text
    stText := GridOptions.Cells[aCol, aRow];
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
  if (FSelected = nil) and (ListSelected.Items.Count = 0) and
     (FSelectionMode = smUnique ) then
  begin
    ShowMessage('선택된 종목이 없습니다.');
    Exit;
  end else
  if FIsForOrder and not FSelected.CanOrder then
  begin
    ShowMessage('선택된 종목은 사용자가 주문을 하지 못하도록 하였습니다.');
    Exit;
  end;
  //
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
  //gHelp.Show(ID_SYMBOL);
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
  ButtonMoveClick(ButtonUnselect);
end;

procedure TSymbolDialog.SymbolDblClick(Sender: TObject);
begin
  if FSelectionMode = smUnique then
    ButtonOkClick(ButtonOK)
  else
    ButtonMoveClick(ButtonSelect);
end;



procedure TSymbolDialog.SymbolMove(Sender: TObject);
var
  iFlag, iMove: Integer;
  aTempSymbol: TSymbol;
  //
  iDir : Integer; // dir = direction
begin
  //--1. Check select count
  if ListSelected.SelCount <> 1 then Exit;
  //--2. Get selected
  iFlag:= ListSelected.Selected.Index;
  //--3. Get New Position
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
  //--4. Swap
  aTempSymbol:= ListSelected.Items[iFlag].Data;
  ListSelected.Items[iFlag].Data := ListSelected.Items[iMove].Data;
  ListSelected.Items[iFlag].Caption := ListSelected.Items[iMove].Caption;
  ListSelected.Items[iFlag].SubItems[0] := ListSelected.Items[iMove].SubItems[0];
  ListSelected.Items[iMove].Data:= aTempSymbol;
  ListSelected.Items[iMove].Caption:= aTempSymbol.Code;
  ListSelected.Items[iMove].SubItems[0]:= aTempSymbol.Name;
  //--5. set selected & focused
  ListSelected.Items[iMove].Selected := True;
  ListSelected.Items[iMove].Focused := True;
  //--6. redraw
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


procedure TSymbolDialog.SelectTab(stSymbolType: TMarketType);
begin
  case stSymbolType of
    mtFutures : PageTypes.ActivePageIndex := 0;
    mtOption : PageTypes.ActivePageIndex := 1;
    mtSpread : PageTypes.ActivePageIndex := 2;
    mtIndex : PageTypes.ActivePageIndex := 3;
  end;
end;

end.
