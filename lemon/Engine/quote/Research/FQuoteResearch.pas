unit FQuoteResearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,

  CleQuoteResearch, CleQuoteBroker, CleSymbols, GleTypes, GleLib, CleStorage,

  CleExcelLog

  ;

const
  DataIdx = 0;
  Selected = 1;

type
  TFrmQuoteResearch = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbSymbol: TComboBox;
    btnSymbol: TButton;
    edtQty: TEdit;
    edtCnt: TEdit;
    edtSec: TEdit;
    sgInfo: TStringGrid;
    cbAsc: TCheckBox;
    tmflash: TTimer;
    edtTotQty: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    procedure edtSecKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure edtQtyChange(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);

    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbAscClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmflashTimer(Sender: TObject);
    procedure sgInfoDblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FSymbol: TSymbol;
    FRow   : integer;
    FQuoteResearch: array [0..1] of TQuoteResearch;
    FFillter: TFillter;
    procedure initControls;
    procedure SetFillter;
    procedure Add( aItem : TQuoteResearchItem);
    procedure Del( aItem : TQuoteResearchItem);
    procedure Update( aItem : TQuoteResearchItem);
    procedure UpdateData(aItem: TQuoteResearchItem; iRow: integer);
    procedure Clear;
    procedure AscSort(aList: TList);
    procedure DescSort(aList: TList);
    { Private declarations }
  public
    { Public declarations }

    property Symbol : TSymbol read FSymbol write FSymbol;
    property Fillter : TFillter read FFillter write FFillter;

    procedure SearchEvent( aItem : TQuoteResearchItem;  stType : TSearchType );

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

  end;

var
  FrmQuoteResearch: TFrmQuoteResearch;

implementation

uses
  DleSymbolSelect, GAppEnv;

{$R *.dfm}

procedure TFrmQuoteResearch.btnSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, cbSymbol);
        // apply
      cbSymbolChange(cbSymbol);
    end;
  finally
    gSymbol.Hide;
  end;
end;



procedure TFrmQuoteResearch.Button1Click(Sender: TObject);
var
  ExcelLog  : TExcelLog;
  i : integer;
begin
  try
    ExcelLog  := TExcelLog.Create;
    ExcelLog.LogInit( Caption, sgInfo.Rows[0] );

    for I := 1 to sgInfo.RowCount - 1 do
      ExcelLog.LogData( sginfo.Rows[i], i );

  finally
    ExcelLog.Free;
  end;
end;

procedure TFrmQuoteResearch.cbAscClick(Sender: TObject);
var
  aList : TList;
begin

  try
    aList := TList.Create;

    FQuoteResearch[0].Recv := false;
    FQuoteResearch[1].Recv := false;

    if cbAsc.Checked then  // 오름차순
      DescSort( aList )
    else  // 내림차순
      AscSort( aList );

  finally
    FQuoteResearch[0].Recv := true;
    FQuoteResearch[1].Recv := true;
    aList.Free;
  end;
end;


procedure TFrmQuoteResearch.AscSort( aList : TList );
var
  i : integer;
  aItem : TQuoteResearchItem;
begin
  // 내림 --> 오름으로..시간
  for i := 1 to sgInfo.RowCount - 1 do
  begin
    aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, i] );
    if aItem <> nil then
      aList.Add( aItem );
  end;

  Clear;

  for i := 0 to aList.Count-1 do
  begin
    aItem := TQuoteResearchItem( aList.Items[i]);
    if aItem <> nil then
      Add( aItem );
  end;

end;

procedure TFrmQuoteResearch.DescSort( aList : TList );
var
  i : integer;
  aItem : TQuoteResearchItem;
begin
  for i := 1 to sgInfo.RowCount - 1 do
  begin
    aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, i] );
    if aItem <> nil then
      aList.Add( aItem );
  end;

  Clear;

  for i := aList.Count - 1 downto 0 do
  begin
    aItem := TQuoteResearchItem( aList.Items[i]);
    if aItem <> nil then
      Add( aItem );
  end;

end;

procedure TFrmQuoteResearch.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  //
begin

  SetFillter;

  if cbSymbol.ItemIndex = -1 then Exit;

  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;

  if (aSymbol = nil) then Exit;

  if FSymbol <> aSymbol then
  begin
    Clear;
    FSymbol := aSymbol;

    FQuoteResearch[0].Symbol  := FSymbol;
    FQuoteResearch[1].Symbol  := FSymbol;
  end;
end;

procedure TFrmQuoteResearch.Clear;
var
  i : integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
  sgInfo.RowCount := 1;
end;

procedure TFrmQuoteResearch.edtQtyChange(Sender: TObject);
begin
  SetFillter;
end;

procedure TFrmQuoteResearch.edtSecKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TFrmQuoteResearch.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmQuoteResearch.FormCreate(Sender: TObject);
begin
  //
  FRow  := -1;

  FQuoteResearch[0]:= TQuoteResearch.Create('Lx');
  FQuoteResearch[0].OnSearchEvent := SearchEvent;
  FQuoteResearch[1]:= TQuoteResearch.Create('Sx');
  FQuoteResearch[1].OnSearchEvent := SearchEvent;

  gEnv.Engine.SymbolCore.SymbolCache.GetList( cbSymbol.Items );
  if cbSymbol.Items.Count > 0 then
  begin
    cbSymbol.ItemIndex  := 0;
    cbSymbolChange( cbSymbol );
  end;

  initControls;

  SetFillter;

end;

procedure TFrmQuoteResearch.initControls;
begin
  with sgInfo do
  begin
    Cells[0,0]  := '시각';
    Cells[1,0]  := '수량,건수';
    Cells[2,0]  := 'LS';
    Cells[3,0]  := '주문수량';
    ColWidths[0] := 80;
  end;

end;



procedure TFrmQuoteResearch.SetFillter;
begin
  FFillter.SisSec  := StrToIntDef( edtSec.Text, 300 );
  FFillter.SisCnt  := StrToIntDef( edtCnt.Text, 3);
  FFillter.OrdQty  := StrToIntDef( edtQty.Text, 10 );
  FFillter.TotQty  := StrToIntDef( edtTotQty.Text, 100 );
  FQuoteResearch[0].SetFillter( FFillter );
  FQuoteResearch[1].SetFillter( FFillter );
end;

procedure TFrmQuoteResearch.sgInfoDblClick(Sender: TObject);
var
  aItem : TQuoteResearchItem;
  i : integer;
  aDesc : TQuoteDesc;
begin
  aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, FRow] );
  if aItem = nil then Exit;

  for i:=0 to aItem.QuoteList.Count do
  begin
    aDesc := TQuoteDesc( aItem.QuoteList.Items[i] );

  end;
end;

procedure TFrmQuoteResearch.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    ftColor, bkColor : TColor;
    stTxt : string;
    iX, iY : integer;
    aDesc : TQuoteResearchItem;
    aSize : TSize;
    bLight  : boolean;
begin
  ftColor := clBlack;
  bkColor := clWhite;
  bLight  := false;

  with sgInfo do
  begin

    stTxt := Cells[ ACol, ARow ];
    aSize := Canvas.TextExtent(stTxt);

    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;

    if ARow = 0 then
      bkColor := clBtnFace
    else begin

      aDesc := TQuoteResearchItem( Objects[0,ARow] );

      if aDesc <> nil then
      begin
        if aDesc.Data.Side = 'L' then
          ftColor := clBlue
        else
          ftColor := clRed;

        bLight  := (aDesc.Flash) and ( ARow <=3 );
      end;

      case ACol of
        0 : ftColor := clBlack;
        3 :
          begin

            iX := Rect.Left + 2 ;
          end;
      end;
    end;

    if Integer(Objects[Selected,ARow]) = 100 then
    begin
      bkColor := clSilver;
      FRow    := ARow;
    end;

    if bLight then
      bkColor := clYellow;

    Canvas.Font.Color := ftColor;
    Canvas.Brush.Color  := bkColor;

    Canvas.Font.Name    := '굴림체';
    Canvas.Font.Size    := 9;

    Canvas.FillRect( Rect );

    Canvas.TextRect(Rect, iX, iY, stTxt);

  end;

end;

procedure TFrmQuoteResearch.sgInfoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    aRow, aCol : integer;
begin
  aRow := FRow;
  sgInfo.MouseToCell( X, Y, aCol, FRow );

  if FRow < 1 then
  begin
    FRow := aRow;
    Exit;
  end;

  sgInfo.Objects[Selected,FRow] := Pointer( 100 );

  if (aRow > 0) and ( aRow <> FRow) then
    sgInfo.Objects[Selected,aRow] := Pointer( 1 );

  InvalidateRow( sgInfo, aRow );
  InvalidateRow( sgInfo, FRow );
end;

procedure TFrmQuoteResearch.tmflashTimer(Sender: TObject);
var
  aItem : TQuoteResearchItem;
  i : integer;
begin
  // 밑에서부터
  if cbAsc.Checked then
  begin
    for i := sgInfo.RowCount-1 downto 1 do
    begin
      aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, i]);
      if aItem <> nil then
      begin
        if aItem.Flash then
        begin
          aItem.Flash := false;
          InvalidateRow( sgInfo, i );
        end
        else
          Break;
      end;
    end;

  end
  // 위에서부터
  else begin

    for i :=1 to sgInfo.RowCount-1 do
    begin
      aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, i]);
      if aItem <> nil then
      begin
        if aItem.Flash then
        begin
          aItem.Flash := false;
          InvalidateRow( sgInfo, i );
        end
        else
          Break;
      end;
    end;

  end;

end;

procedure TFrmQuoteResearch.FormDestroy(Sender: TObject);
begin
  //
  FQuoteResearch[0].Free;
  FQuoteResearch[1].Free;
end;


procedure TFrmQuoteResearch.LoadEnv(aStorage: TStorage);
var
  aSymbol : TSymbol;
  Code  : string;
begin
  if aStorage = nil then Exit;

  Code  := aStorage.FieldByName('Symbol').AsString;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( Code );

  if aSymbol <> nil then
  begin
    AddSymbolCombo( aSymbol, cbSymbol );
    //SetComboIndex( cbSymbol, aSymbol );
    cbSymbolChange( cbSymbol );
  end;

  edtQty.Text := aStorage.FieldByName('Qty').AsString;
  edtSec.Text := aStorage.FieldByName('Sec').AsString;
  edtCnt.Text := aStorage.FieldByName('Cnt').AsString;
  edtTotQty.Text  := aStorage.FieldByName('TotQty').AsString;

  cbAsc.Checked := aStorage.FieldByName('Asc').AsBoolean;

  SetFillter;

end;

procedure TFrmQuoteResearch.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbol').AsString := FSymbol.Code;

  aStorage.FieldByName('Qty').AsString := edtQty.Text;
  aStorage.FieldByName('Sec').AsString := edtSec.Text;
  aStorage.FieldByName('Cnt').AsString := edtCnt.Text;
  aStorage.FieldByName('TotQty').AsString := edtTotQty.Text;

  aStorage.FieldByName('Asc').AsBoolean:= cbAsc.Checked;

end;

procedure TFrmQuoteResearch.SearchEvent(aItem: TQuoteResearchItem;
  stType: TSearchType);

begin
  //
  if aItem = nil then Exit;

  case stType of
    //stAdd: Add( aItem );
    stUpdate: Update( aItem ) ;
    stDel: Del( aItem );
  end;

end;

procedure TFrmQuoteResearch.Add( aItem : TQuoteResearchItem);
begin 
  if cbAsc.Checked then
  begin
    sgInfo.RowCount  :=  sgInfo.RowCount + 1;
    UpdateData( aItem, sgInfo.RowCount-1 );
  end
  else begin
    InsertLine( sgInfo, 1 );
    UpdateData( aItem, 1 );
  end;

  if sgInfo.RowCount > 1 then
    sgInfo.FixedRows  := 1;
end;

procedure TFrmQuoteResearch.Update( aItem : TQuoteResearchItem);
var
  iRow : integer;
begin
  iRow  := sgInfo.Cols[DataIdx].IndexOfObject( aItem );
  if iRow > 0 then
    UpdateData( aItem , iRow )
  else
    Add( aItem );
end;

procedure TFrmQuoteResearch.UpdateData( aItem : TQuoteResearchItem; iRow : integer);
var
  i, iCol,iCnt, iV, iSv, iQty : integer;
  stTxt, stTxt2 : string;
  aDesc : TQuoteDesc;
begin
  iCol := 0;
  with sgInfo do
  begin
    Objects[DataIdx, iRow]  := aItem;
    Cells[ iCol, iRow ] := FormatDateTime( 'hh:nn:ss.zzz', aItem.StartTime)  ;
    inc(iCol);

    iV  := 0;
    iSv := 0;
    iCnt  := 0;
    stTxt := '';   stTxt2 := '';
    for i := 0 to aItem.QuoteList.Count - 1 do
    begin
      aDesc := TQuoteDesc( aItem.QuoteList.Items[i] );
      iQTy  := StrToInt(aDesc.Qty);
      iV := iV + iQty;

      if iSv = iQTy then
      begin
        inc( iCnt );
        if iCnt > 0 then
          stTxt := stTxt2 + Format('%d(%d)', [ iSv, iCnt+1])+ ' ';
      end
      else begin
        iSv   := iQTy;
        iCnt  := 0;
        stTxt2:= stTxt;
        stTxt := stTxt + aDesc.Qty + ' ';
      end;
    end;

    Cells[ iCol, iRow ] := Format('%d,%d', [ iv, i]);
    inc(iCol);
    Cells[ iCol, iRow ] := aDesc.Side+'x';
    inc(iCol);
    Cells[ iCol, iRow ] := stTxt;
    inc(iCol);

  end;
end;

procedure TFrmQuoteResearch.Del( aItem : TQuoteResearchItem);
var
  iRow : integer;
begin
  iRow  := sgInfo.Cols[DataIdx].IndexOfObject( aItem );
  if iRow > 0 then
    DeleteLine( sgInfo, iRow );
end;

end.

