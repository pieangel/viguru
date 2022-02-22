unit FSaleResearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateUtils,

  CleQuoteBroker, CleSymbols, CleQuoteResearch, GleTypes, GleLib, Grids, CleStorage,
  StdCtrls, ExtCtrls

  ;

const
  DataIdx = 0;
  Selected  = 1;
  HighLight = 2;
  BackColor = 3;
  clBack = $00E0E0E0;

type
  TFrmResearchMuch = class(TForm)
    Panel1: TPanel;
    Label3: TLabel;
    cbSymbol: TComboBox;
    btnSymbol: TButton;
    edtQty: TEdit;
    sgInfo: TStringGrid;
    cbAsc: TCheckBox;
    tmflash: TTimer;
    Button1: TButton;
    Label2: TLabel;
    edtGap: TEdit;
    edtSecond: TEdit;
    Label1: TLabel;
    cbSecond: TComboBox;
    cbNow: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtQtyChange(Sender: TObject);
    procedure cbAscClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmflashTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FSymbol: TSymbol;
    FFillter: TFillter;
    FQuoteResearch: TQuoteResearch;
    FRow : integer;
    FBackColor : array [0..1] of TColor;
    FBackWhite : boolean;
    FBackLastTime : TDateTime;
    procedure SetFillter;
    procedure initControls;
    procedure Add(aItem: TQuoteResearchItem);
    procedure UpdateData(aItem: TQuoteResearchItem; iRow: integer);
    procedure Clear;
    procedure AscSort( aList : TList );
    procedure DescSort( aList : TList );
    function GetGridBackColor( var stChar : string; dtTime: TQuoteResearchItem; iRow: integer): integer;
    procedure ClearBackGround(iRow: integer);
    function IsSameSecond(aTime, bTime: TDateTime): boolean;

    { Private declarations }
  public
    { Public declarations }
    property Symbol : TSymbol read FSymbol write FSymbol;
    property Fillter : TFillter read FFillter write FFillter;
    property QuoteResearch  : TQuoteResearch read FQuoteResearch write FQuoteResearch;

    procedure SearchEvent( aItem : TQuoteResearchItem;  stType : TSearchType );

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmResearchMuch: TFrmResearchMuch;

implementation

uses
  CleExcelLog, DleSymbolSelect, GAppEnv;

{$R *.dfm}

procedure TFrmResearchMuch.btnSymbolClick(Sender: TObject);
var
  i : integer;
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

procedure TFrmResearchMuch.Button1Click(Sender: TObject);
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

procedure TFrmResearchMuch.cbAscClick(Sender: TObject);
var
  aList : TList;
begin

  try
    aList := TList.Create;

    FQuoteResearch.Recv := false;

    if cbAsc.Checked then  // 오름차순
      DescSort( aList )
    else  // 내림차순
      AscSort( aList );

  finally
    FQuoteResearch.Recv := true;
    aList.Free;
  end;
end;

procedure TFrmResearchMuch.AscSort( aList : TList );
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

procedure TFrmResearchMuch.DescSort( aList : TList );
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

procedure TFrmResearchMuch.cbSymbolChange(Sender: TObject);
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
    FQuoteResearch.Symbol  := aSymbol;
  end;

end;


procedure TFrmResearchMuch.Clear;
var
  i : integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
  sgInfo.RowCount := 1;
end;


procedure TFrmResearchMuch.edtQtyChange(Sender: TObject);
begin
  SetFillter;
end;

procedure TFrmResearchMuch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmResearchMuch.FormCreate(Sender: TObject);
begin
  //
  FRow  := -1;
  FQuoteResearch:= TQuoteResearch.Create( 'FL' );
  FQuoteResearch.OnSearchEvent  := SearchEvent;

  gEnv.Engine.SymbolCore.SymbolCache.GetList( cbSymbol.Items );
  if cbSymbol.Items.Count > 0 then
  begin
    cbSymbol.ItemIndex  := 0;
    cbSymbolChange( cbSymbol );
  end;


  initControls;

  SetFillter;
end;

procedure TFrmResearchMuch.FormDestroy(Sender: TObject);
begin
  FQuoteResearch.Free;
  //
end;


procedure TFrmResearchMuch.initControls;
begin
  with sgInfo do
  begin
    Cells[0,0]  := '시각';
    Cells[1,0]  := 'LS';

    Cells[2,0]  := '주문량';
    Cells[3,0]  := '가격';
    Cells[4,0]  := '체결량';
    Cells[5,0]  := '시간차';

    Cells[6,0]  := 'L';
    Cells[7,0]  := 'S';

    Cells[8,0]  := 'Gap';

    ColWidths[0] := 80;

    ColWidths[1] := 25;
    ColWidths[2] := 37;
    ColWidths[3] := 47;
    ColWidths[4] := 37;
    ColWidths[5] := 37;

    ColWidths[6] := 35;
    ColWidths[7] := 35;

    ColWidths[8] := 25;

  end;

  FBackColor[0] := clWhite;
  FBackColor[1] := clBack;
  FBackWhite  := true;
end;


procedure TFrmResearchMuch.LoadEnv(aStorage: TStorage);
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

  cbAsc.Checked := aStorage.FieldByName('Asc').AsBoolean;
  edtGap.Text := aStorage.FieldByName('Gap').AsString;
  if edtGap.Text = '' then
    edtGap.Text := '1000';

  cbSecond.ItemIndex := aStorage.FieldByName('Sec').AsInteger;
  if cbSecond.ItemIndex < 0 then
    cbSecond.ItemIndex  := 0;

  cbNow.Checked := aStorage.FieldByName('Now').AsBoolean;

  SetFillter;
end;

procedure TFrmResearchMuch.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbol').AsString := FSymbol.Code;

  aStorage.FieldByName('Qty').AsString := edtQty.Text;
  aStorage.FieldByName('Asc').AsBoolean:= cbAsc.Checked;
  aStorage.FieldByName('Gap').AsString:= edtGap.Text;
  aStorage.FieldByName('Sec').AsInteger:= cbSecond.ItemIndex;
  aStorage.FieldByName('Now').AsBoolean := cbNow.Checked;

end;

procedure TFrmResearchMuch.SearchEvent(aItem: TQuoteResearchItem;
  stType: TSearchType);
begin
  if aItem = nil then Exit;
  Add( aItem );
end;

procedure TFrmResearchMuch.Add( aItem : TQuoteResearchItem);
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


procedure TFrmResearchMuch.UpdateData( aItem : TQuoteResearchItem; iRow : integer);
var
  i, iCol,iCnt, iV, iSv, iQty : integer;
  stTxt, stTxt2 : string;
  aDesc : TQuoteDesc;
begin
  iCol := 0;
  stTxt2 := '';
  with sgInfo do
  begin
    aDesc := aItem.Data;
    Objects[DataIdx, iRow]  := aItem;
    Objects[BackColor, iRow]:= Pointer( GetGridBackColor( stTxt2, aItem, iRow ) );

    Cells[ iCol, iRow ] := FormatDateTime( 'hh:nn:ss.zzz', aItem.StartTime)  ;
    inc(iCol);

    Cells[ iCol, iRow ] := aDesc.Side;
    inc(iCol);
    Cells[ iCol, iRow ] := aDesc.Qty;
    inc(iCol);
    Cells[ iCol, iRow ] := aDesc.Price;
    inc(iCol);

    Cells[ iCol, iRow ] := aDesc.FillQty;
    inc(iCol);

    Cells[ iCol, iRow ] := Format('%.1f', [ aDesc.TimeGap / 1000] );
    inc(iCol);

    Cells[ iCol, iRow ] := IntToStr( FQuoteResearch.LFCount );
    inc(iCol);

    Cells[ iCol, iRow ] := IntToStr( FQuoteResearch.SFCount );
    inc(iCol);

    Cells[ iCol, iRow ] := stTxt2;
    inc(iCol);

  end;
end;

function TFrmResearchMuch.GetGridBackColor( var stChar : string; dtTime : TQuoteResearchItem;
  iRow : integer ) : integer;
var
  aItem : TQuoteResearchItem;
  iGap, iRes : integer;
  bRes : boolean;
begin
  Result := 0;

  if sgInFo.RowCount = 2 then
  begin
    FBackLastTime := dtTime.StartTime;
    Exit;
  end;

  aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, iRow+1] );
  if aItem = nil then Exit;

  // 초단위 리턴
  if cbNow.Checked then
  begin

    case cbSecond.ItemIndex of
      0 : iRes := 60;
      1 : iRes := 30;
      2 : iRes := 20;
      3 : iRes := 10;
    end;

    iGap := SecondsBetween( dtTime.StartTime, FBackLastTime );

    if iGap < iRes then
    else begin
      FBackWhite := not FBackWhite;
      FBackLastTime := dtTime.StartTime;
    end;
  end
  else begin

    if (HourOf( aItem.StartTime )  = HourOf( dtTime.StartTime )) and
      (MinuteOf( aItem.StartTime ) = MinuteOf( dtTime.StartTime )) then
    begin
      if cbSecond.ItemIndex <> 0 then
      begin
        bRes := IsSameSecond( dtTime.StartTime , aItem.StartTime );
        if not bRes then
          FBackWhite := not FBackWhite;
      end;
    end
    else
      FBackWhite := not FBackWhite;
  end;

  if FBackWhite then
    Result := 0
  else
    Result := 1;

  iGap := StrToIntDef( edtGap.Text, 1000 );

  if (dtTime.Data.TimeGap <= iGap) and ( aItem.Data.Side <> dtTime.Data.Side ) then
    stChar := '☜'
  else
    stChar := '';

end;

function TFrmResearchMuch.IsSameSecond( aTime, bTime : TDateTime ) : boolean;
var
  iTo, iFrom, iSec, iSec2: integer;
begin

  iSec  := SecondOf( aTime );
  iSec2 := SecondOf( bTime );

  case cbSecond.ItemIndex of
    1 :
      begin
        if ((iSec2 >= 0) and ( iSec2 < 30 )) and
          (( iSec >= 0 ) and ( iSec < 30 )) then
          Result := true
        else if((iSec2 >= 30 ) and (iSec2 <= 59) ) and
          (( iSec >= 30 ) and (iSec2 <= 59)) then
          Result := true
        else
          Result := false;
      end;
    2 :
      begin
        if ((iSec2 >= 0) and ( iSec2 < 20 )) and
          (( iSec >= 0 ) and ( iSec < 20 )) then
          Result := true
        else if((iSec2 >= 20) and ( iSec2 < 40 )) and
          (( iSec >= 20 ) and ( iSec < 40 )) then
          Result := true
        else if(( iSec2 >= 40) and ( iSec2 <= 59) )  and
          (( iSec >= 40 ) and ( iSec <= 59) )  then
          Result := true
        else
          Result := false;
      end;
    3 :
      begin
        if ((iSec2 >= 0) and ( iSec2 < 10 )) and
          (( iSec >= 0 ) and ( iSec < 10 )) then
          Result := true
        else if((iSec2 >= 10) and ( iSec2 < 20 )) and
          (( iSec >= 10 ) and ( iSec < 20 )) then
          Result := true
        else if((iSec2 >= 20) and ( iSec2 < 30 )) and
          (( iSec >= 20 ) and ( iSec < 30 )) then
          Result := true
        else if((iSec2 >= 30) and ( iSec2 < 40 )) and
          (( iSec >= 30 ) and ( iSec < 40 )) then
          Result := true
        else if((iSec2 >= 40) and ( iSec2 < 50 )) and
          (( iSec >= 40 ) and ( iSec < 50 )) then
          Result := true
        else if( (iSec2 >= 50) and ( iSec2 <= 59))  and
          ((iSec >= 50)  and ( iSec <= 59 ))  then
          Result := true
        else
          Result := false;
      end;
  end;

end;

procedure TFrmResearchMuch.ClearBackGround( iRow : integer );
var
  iVal, I: Integer;
  aItem : TQuoteResearchItem;
begin
  iRow := iRow + 1;

  for I := iRow to sgInfo.RowCount - 1 do
  begin
    iVal := Integer(sgInfo.Objects[BackColor, i]);
    if iVal = 100 then begin
      sgInfo.Objects[BackColor, i] := Pointer( 0);
      InvalidateRow( sgInfo, i );
    end
    else break;
  end;

end;


procedure TFrmResearchMuch.SetFillter;
begin
  FFillter.OrdQty  := StrToIntDef( edtQty.Text, 70 );
  FQuoteResearch.SetFillter( FFillter );
end;

procedure TFrmResearchMuch.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    ftColor, bkColor : TColor;
    stTxt : string;
    aSize : TSize;
    iBack, iX, iY : integer;
    aDesc : TQuoteResearchItem;
    bLight: boolean;
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

      iBack := Integer( Objects[BackColor, ARow ]);
      bkColor := FBackColor[iBack];

      aDesc := TQuoteResearchItem( Objects[0,ARow] );

      if aDesc <> nil then
      begin
        if aDesc.Data.Side = 'L' then
          ftColor := clRed
        else
          ftColor := clBlue;

        bLight := (aDesc.Flash) and ( ARow <=3 );

      end;

      case ACol of
        0 : ftColor := clBlack;
        1,2,3,4,5,6 :
          begin
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
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

procedure TFrmResearchMuch.sgInfoMouseDown(Sender: TObject;
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



procedure TFrmResearchMuch.tmflashTimer(Sender: TObject);
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

end.

