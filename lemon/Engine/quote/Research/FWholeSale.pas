unit FWholeSale;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleQuoteResearch, CleQuoteBroker, CleSymbols, GleTypes, GleLib, CleStorage,
  Grids, StdCtrls, ExtCtrls
  ;
Const
  DataIdx = 0;
  Selected  = 1;
  HighLight = 2;

type
  TFrmWholeSale = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbSymbol: TComboBox;
    btnSymbol: TButton;
    edtConQty: TEdit;
    edtBefore: TEdit;
    sgInfo: TStringGrid;
    tmflash: TTimer;
    edtQty: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    edtConFill: TEdit;
    Label6: TLabel;
    Button2: TButton;
    edtGap: TEdit;
    Label5: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure edtAfterChange(Sender: TObject);
    procedure edtAfterKeyPress(Sender: TObject; var Key: Char);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmflashTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FSymbol: TSymbol;
    { Private declarations }
    procedure initControls;
    procedure SetFillter;
    procedure Clear;
    procedure Add(aItem: TQuoteResearchItem);
    procedure Update(aItem: TQuoteResearchItem);
    procedure UpdateData(aItem: TQuoteResearchItem; iRow: integer);
    procedure UpdateData2(aItem: TQuoteResearchItem; iRow: integer);
    procedure GetGapText(var stChar: string; dtTime: TQuoteResearchItem;
      iRow: integer);

  public
    { Public declarations }
    FRow   : integer;
    FQuoteResearch: TQuoteResearch;
    FFillter: TFillter;

    procedure SearchEvent( aItem : TQuoteResearchItem;  stType : TSearchType );

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    property Symbol : TSymbol read FSymbol write FSymbol;
    property Fillter : TFillter read FFillter write FFillter;
  end;

var
  FrmWholeSale: TFrmWholeSale;

implementation

uses
  CleExcelLog, GAppEnv;

{$R *.dfm}

procedure TFrmWholeSale.btnSymbolClick(Sender: TObject);
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

procedure TFrmWholeSale.Button1Click(Sender: TObject);
begin
  FQuoteResearch.Recv := false;
  Clear;
  FQuoteResearch.Recv := true;
end;

procedure TFrmWholeSale.Button2Click(Sender: TObject);
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

procedure TFrmWholeSale.cbSymbolChange(Sender: TObject);
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
    FQuoteResearch.Symbol  := FSymbol;
  end;
end;

procedure TFrmWholeSale.Clear;
var
  i : integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
  sgInfo.RowCount := 1;
end;

procedure TFrmWholeSale.edtAfterChange(Sender: TObject);
begin
  SetFillter;
end;

procedure TFrmWholeSale.edtAfterKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TFrmWholeSale.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmWholeSale.FormCreate(Sender: TObject);
begin
  FRow  := -1;

  FQuoteResearch:= TQuoteResearch.Create('xFL');
  FQuoteResearch.OnSearchEvent := SearchEvent;

  gEnv.Engine.SymbolCore.SymbolCache.GetList( cbSymbol.Items );
  if cbSymbol.Items.Count > 0 then
  begin
    cbSymbol.ItemIndex  := 0;
    cbSymbolChange( cbSymbol );
  end;

  initControls;

  SetFillter;
end;

procedure TFrmWholeSale.FormDestroy(Sender: TObject);
begin
  FQuoteResearch.Free;
end;

procedure TFrmWholeSale.initControls;
begin
  with sgInfo do
  begin
    Cells[0,0]  := '시각';

    //Cells[3,0]  := 'LS';

    Cells[1,0]  := '주문합';
    Cells[2,0]  := '취소합';
    Cells[3,0]  := '체결합';

    Cells[4,0]  := '가격';
    Cells[5,0]  := '주문';
    Cells[6,0]  := '체결';
    {
    Cells[9,0]  := 'A_O';// '주문량';
    Cells[10,0]  := 'A_C';//'취소량';
    Cells[11,0]  := 'A_F';//'체결량';
    }
    Cells[7,0]  := '매도';
    Cells[8,0]  := '매수';

    Cells[9,0]  := '연속';
    Cells[10,0]  := '시간차';

    Cells[11,0]  := 'L';
    Cells[12,0]  := 'S';
    Cells[13,0]  := 'Gap';

    ColWidths[0] := 80;

    //ColWidths[3] := 31;

    ColWidths[1] := 40;
    ColWidths[2] := 40;
    ColWidths[3] := 40;

    ColWidths[4] := 45;
    ColWidths[5] := 31;
    ColWidths[6] := 31;
    {
    ColWidths[9] := 39;
    ColWidths[10] := 39;
    ColWidths[11] := 39;
    }
    ColWidths[7] := 80;
    ColWidths[8] := 80;

    ColWidths[9] := 35;
    ColWidths[10] := 35;

    ColWidths[11] := 35;
    ColWidths[12] := 35;
    ColWidths[13] := 30;

  end;
end;

procedure TFrmWholeSale.LoadEnv(aStorage: TStorage);
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
  edtBefore.Text  := aStorage.FieldByName('Before').AsString;

  edtConQty.Text  := aStorage.FieldByName('ConQty').AsString;
  edtConFill.Text := aStorage.FieldByName('ConFill').AsString;
  edtGap.Text := aStorage.FieldByName('ConGap').AsString;

  SetFillter;

end;

procedure TFrmWholeSale.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbol').AsString := FSymbol.Code;

  aStorage.FieldByName('Qty').AsString := edtQty.Text;
  aStorage.FieldByName('Before').AsString := edtBefore.Text;

  aStorage.FieldByName('ConQty').AsString:= edtConQty.Text;
  aStorage.FieldByName('ConFill').AsString  := edtConFill.Text;
  aStorage.FieldByName('ConGap').AsString  := edtGap.Text;
end;

procedure TFrmWholeSale.SearchEvent(aItem: TQuoteResearchItem;
  stType: TSearchType);
begin
  if aItem = nil then Exit;

  case stType of
    stAdd: Add( aItem );
    stUpdate: Update( aItem ) ;
  end;
end;

procedure TFrmWholeSale.Add( aItem : TQuoteResearchItem);
begin

  InsertLine( sgInfo, 1 );
  UpdateData( aItem, 1 );

  if sgInfo.RowCount > 1 then
    sgInfo.FixedRows  := 1;
end;

procedure TFrmWholeSale.UpdateData( aItem : TQuoteResearchItem; iRow : integer);
var
  iGap,iCol : integer;
  stChar, stTmp : string;

  aDesc : TQuoteDesc;
  aQuote : TQuote;
begin
  iCol := 0;
  with sgInfo do
  begin
    Objects[iCol, iRow]  := aItem;
    aDesc := aItem.Data;
    Cells[ iCol, iRow ] := FormatDateTime( 'hh:nn:ss.zzz', aItem.StartTime)  ;
    inc(iCol);


    {
    Cells[ iCol, iRow ] := aDesc.Side;
    inc(iCol);
    }
    Cells[ iCol, iRow ] := IntToStr( aDesc.BeforeAcOrd ) ;
    inc(iCol);

    Cells[ iCol, iRow ] := IntToStr( aDesc.BeforeAcCnl ) ;
    inc(iCol);

    Cells[ iCol, iRow ] := IntToStr( aDesc.BeforeAcFil ) ;
    inc(iCol);

    Cells[ iCol, iRow ] := aDesc.Price;
    inc(iCol);

    Cells[ iCol, iRow ] := aDesc.Qty;
    inc(iCol);

    Cells[ iCol, iRow ] := aDesc.FillQty;
    inc(iCol);

    aQuote  := FSymbol.Quote as TQuote;
    if aQuote <> nil then
    begin
      Cells[ iCol, iRow ] := Format('(%3.3s) %.2f', [ IntToStr(aQuote.Asks[0].Volume),
        aQuote.Asks[0].Price
        ]);
      inc(iCol);

      Cells[ iCol, iRow ] := Format('%.2f (%3.3s)', [ aQuote.Bids[0].Price, IntToStr(aQuote.Bids[0].Volume) ]);
      inc(iCol);
    end
    else begin
      Cells[ iCol, iRow ] := '';
      inc(iCol);

      Cells[ iCol, iRow ] := '';
      inc(iCol);
    end;

    if aDesc.Side = 'L' then
      Cells[ iCol, iRow ] := IntToStr( aItem.SameCnt )
    else
      Cells[ iCol, iRow ] := IntToStr( aItem.SameCnt * -1 );
    inc(iCol);

    Cells[ iCol, iRow ] := Format('%.1f', [ aDesc.TimeGap / 1000] );
    inc(iCol);

    Cells[ iCol, iRow ] := IntToStr( FQuoteResearch.LFCount );
    inc(iCol);

    Cells[ iCol, iRow ] := IntToStr( FQuoteResearch.SFCount );
    inc(iCol);
    {
    iGap := StrToIntDef( edtGap.Text, 1000 );

    if (dtTime.Data.TimeGap <= iGap) and ( aItem.Data.Side <> dtTime.Data.Side ) then
      stChar := '☜'
    else
      stChar := '';
    }
    GetGapText( stChar, aItem, iRow );
    Cells[ iCol, iRow ] := stChar;
    inc(iCol);
  end;
end;


procedure TFrmWholeSale.GetGapText( var stChar : string; dtTime : TQuoteResearchItem;
  iRow : integer );
var
  aItem : TQuoteResearchItem;
  iGap, iRes : integer;
  bRes : boolean;
begin

  aItem := TQuoteResearchItem( sgInfo.Objects[DataIdx, iRow+1] );
  if aItem = nil then Exit;

  iGap := StrToIntDef( edtGap.Text, 1000 );

  if (dtTime.Data.TimeGap <= iGap) and ( aItem.Data.Side <> dtTime.Data.Side ) then
    stChar := '☜'
  else
    stChar := '';

end;

procedure TFrmWholeSale.Update( aItem : TQuoteResearchItem);
var
  iRow : integer;
begin
  iRow  := sgInfo.Cols[DataIdx].IndexOfObject( aItem );
  if iRow > 0 then
    UpdateData2( aItem , iRow )  ;
end;
procedure TFrmWholeSale.UpdateData2( aItem : TQuoteResearchItem; iRow : integer);
var
  iCol : integer;
  stTmp : string;
  aDesc : TQuoteDesc;
  aQuote : TQuote;
begin
  iCol := 0;
  with sgInfo do
  begin
    Objects[iCol, iRow]  := aItem;
    aDesc := aItem.Data;


    Cells[ 1, iRow ] := IntToStr( aDesc.BeforeAcOrd ) ;
    Cells[ 2, iRow ] := IntToStr( aDesc.BeforeAcCnl ) ;
    Cells[ 3, iRow ] := IntToStr( aDesc.BeforeAcFil ) ;

    //Cells[ 14, iRow ] := IntToStr( aItem.SameCnt );

  end;
end;



procedure TFrmWholeSale.SetFillter;
begin
  FFillter.ConQty   := StrToIntDef( edtConQty.Text, 10);
  FFillter.ConFillQty := StrToIntDef( edtConFill.Text, 10);
  FFillter.OrdQty := StrToIntDef( edtQty.Text, 1 );
  FFillter.BeforSec := StrToIntDef( edtBefore.Text, 1000);

  FQuoteResearch.SetFillter( FFillter );
end;

procedure TFrmWholeSale.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    ftColor, bkColor : TColor;
    stTxt : string;
    aSize : TSize;
    iX, iY : integer;
    aDesc : TQuoteResearchItem;
    bBold, bLight: boolean;
begin
  ftColor := clBlack;
  bkColor := clWhite;
  bLight  := false;
  bBold   := false;
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
          ftColor := clRed
        else
          ftColor := clBlue;

        bLight := (aDesc.Flash) and ( ARow <=3 );
        bBold  := aDesc.ContinueFill;
      end;

      case ACol of
        0 : ftColor := clBlack;
        7 :
          begin

            bkcolor := $F5E2DA;
            ftColor := clBlack;
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
        8 :
          begin
            bkColor := $E4E2FC ;
            ftColor := clBlack;
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end
        else
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
    begin
      if aDesc <> nil then
      begin
        if aDesc.Data.Side = 'S' then
          bkColor := $F5E2DA
        else
          bkColor :=  $E4E2FC;
      end
      else
      bkColor := clYellow;
    end;

    Canvas.Font.Color := ftColor;
    Canvas.Brush.Color  := bkColor;

    Canvas.Font.Name    := '굴림체';
    Canvas.Font.Size    := 9;
     {
    if bBold then
      Canvas.Font.Style :=  Canvas.Font.Style + [fsBold]
    else
      Canvas.Font.Style :=  Canvas.Font.Style - [fsBold];
    }
    Canvas.FillRect( Rect );

    Canvas.TextRect(Rect, iX, iY, stTxt);

  end;
end;

procedure TFrmWholeSale.sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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

procedure TFrmWholeSale.tmflashTimer(Sender: TObject);
var
  aItem : TQuoteResearchItem;
  i : integer;
begin
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

end.
