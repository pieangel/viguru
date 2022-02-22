unit FLargeOrderForce;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls,

  CleSymbols, CleQuoteBroker, ClePriceItems, CleDistributor, CleLargeOrders,

  CleStorage, GleTypes, GleLib, Menus

  ;

type
  TLargeOrderForce = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbSymbol: TComboBox;
    btnSymbol: TButton;
    edtQty: TEdit;
    edtCnt: TEdit;
    sgInfo: TStringGrid;
    PopupMenu1: TPopupMenu;
    clear1: TMenuItem;
    Log1: TMenuItem;
    Timer1: TTimer;
    Button1: TButton;
    Button2: TButton;
    procedure btnSymbolClick(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtCntChange(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure clear1Click(Sender: TObject);
    procedure Log1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FSymbol : TSymbol;
    FQuote  : TQuote;
    procedure initControls;
    procedure Clear;
    procedure PutData(aLarge: TLargeOrder);
  public
    { Public declarations }
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure WmLargeOrder( var Msg : TMessage ) ; message  WM_CHANGEDATA;  
  end;

var
  LargeOrderForce: TLargeOrderForce;

implementation

uses
  GAppEnv, CleExcelLog;

{$R *.dfm}

procedure TLargeOrderForce.btnSymbolClick(Sender: TObject);
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



procedure TLargeOrderForce.Button1Click(Sender: TObject);
begin
  Clear;
end;

procedure TLargeOrderForce.Button2Click(Sender: TObject);
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

procedure TLargeOrderForce.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if cbSymbol.ItemIndex = -1 then Exit;

  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;

  if (aSymbol = nil) then Exit;

  if FSymbol <> aSymbol then
  begin
    gEnv.Engine.QuoteBroker.Cancel( Self );
    FQuote := nil;
    Clear;
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, aSymbol, QuoteProc );

    FSymbol := aSymbol;
  end;
end;

procedure TLargeOrderForce.Clear;
var
  i : integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
  sgInfo.RowCount := 1;
end;
procedure TLargeOrderForce.clear1Click(Sender: TObject);
begin

end;

// 조건 변경시....
procedure TLargeOrderForce.edtCntChange(Sender: TObject);
begin
  //
end;

procedure TLargeOrderForce.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TLargeOrderForce.FormCreate(Sender: TObject);
begin
  FSymbol := nil;
  FQuote  := nil;

  gEnv.Engine.SymbolCore.SymbolCache.GetList( cbSymbol.Items );
  if cbSymbol.Items.Count > 0 then
  begin
    cbSymbol.ItemIndex  := 0;
    cbSymbolChange( cbSymbol );
  end;

  initControls;


  //gEnv.LargeORder := self;
end;

procedure TLargeOrderForce.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
  //gEnv.LargeORder := nil;
end;


procedure TLargeOrderForce.initControls;
begin
  with sgInfo do
  begin


    Cells[0,0]  := '시각';
    Cells[1,0]  := 'LS';

    Cells[2,0]  := 'H';
    Cells[3,0]  := '가격';

    Cells[4,0]  := '주문수량';
    Cells[5,0]  := '잔량';

  //  Cells[5,0]  := '체결';
  //  Cells[6,0]  := '시간차';


    ColWidths[0] := 80;
    ColWidths[1] := 25;

    ColWidths[2] := 25;
    ColWidths[3] := 40;

    ColWidths[4] := 70;
    ColWidths[5] := 40;

 //   ColWidths[5] := 40;

  end;
end;

procedure TLargeOrderForce.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbol').AsString := FSymbol.Code;
end;

procedure TLargeOrderForce.LoadEnv(aStorage: TStorage);
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
    cbSymbolChange( cbSymbol );
  end;
end;

procedure TLargeOrderForce.Log1Click(Sender: TObject);
begin
 //
end;

procedure TLargeOrderForce.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    ftColor, bkColor : TColor;
    stTxt : string;
    aSize : TSize;
    iFlash, iX, iY : integer;
    aLarge : TLargeOrder;

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
      aLarge  := TLargeOrder( Objects[0, ARow]);

      if aLarge = nil then Exit;
      bLight  := aLarge.Flash;

      case ACol of
        0 : ftColor := clBlack;
        else
        begin
          if aLarge.Side = 1 then
            ftColor := clRed
          else if aLarge.Side = 2 then
            ftColor := clBlue
          else
            ftColor := clBlack;
          iX :=  Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
        end;
      end;
    end;

    if bLight then
      bkColor := clYellow;

    Canvas.Font.Color   := ftColor;
    Canvas.Brush.Color  := bkColor;

    Canvas.Font.Name    := '굴림체';
    Canvas.Font.Size    := 9;

    Canvas.FillRect( Rect );
    Canvas.TextRect(Rect, iX, iY, stTxt);   
  end;

end;

procedure TLargeOrderForce.Timer1Timer(Sender: TObject);
var
  aItem : TlargeOrder;
  i : integer;
begin
 for i :=1 to sgInfo.RowCount-1 do
  begin
    aItem := TlargeOrder( sgInfo.Objects[0, i]);
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

procedure TLargeOrderForce.WmLargeOrder(var Msg: TMessage);
begin

end;

procedure TLargeOrderForce.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;

begin

  if DataObj = nil then Exit;
  aQuote  := DataObj as TQuote;
  if aQuote.Symbol <> FSymbol then Exit;

  if not aQuote.LargeOrders.ReadMaxQty then
    Exit;

  PutData( aQuote.LargeOrders.LastLargeOrder );

end;

procedure TLargeOrderForce.PutData( aLarge : TLargeOrder );
var
  iCol, iRow : integer;
  stTmp : string;
  aType : TSideType;
begin
  if aLarge = nil then
    Exit;

  iRow := 1;
  InsertLine( sgInfo, iRow );

  iCol := 0;

  with sgInfo do
  begin
    Objects[iCol, iRow] := aLarge;
    Cells[iCol, iRow] := FormatDateTime('hh:nn:ss.zzz',  aLarge.Time);
    inc(iCol);

    aType := TSideType( aLarge.Side );
    case aType of
      stNone: Cells[iCol, iRow] := '';
      stLong: Cells[iCol, iRow] := 'L';
      stShort: Cells[iCol, iRow] :='S';
    end;
    inc( iCol );

    Cells[iCol, iRow] := IntToStr( aLarge.hoga+1 );
    inc( iCol );

    Cells[iCol, iRow] := aLarge.Price;
    inc(iCol);

    Cells[iCol, iRow] := aLarge.Position;
    inc(iCol);;

    Cells[iCol, iRow] := IntToStr( aLarge.Vol );
    inc( iCol );

    Cells[iCol, iRow] := IntTostr( aLarge.BetweenMi );
  end;

  if (sgInfo.RowCount > 1) and ( sgInfo.FixedRows < 1 ) then
    sgInfo.FixedRows  := 1;
end;




end.
