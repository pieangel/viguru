unit FQuoteTrace;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ComCtrls, ExtCtrls, Math,

  CleSymbols, CleQuoteBroker, ClePriceItems

  ;


const
  ColCnt  = 6;
  RowCnt  = 50;
  DataIdx = 0;
  Title : array [0..ColCnt-1] of string = ( '시간','LS','호가','가격','주문','체결' );
  ColWidth : array [0..ColCnt-1] of integer = ( 80, 30, 50, 100, 40, 40 );

  lColor  = $0000FF;
  sColor  = $993333;
  lxColor = $FFFF33;// $CC6600;
  SxColor = $0066FF;//$8080FF;

type
  TQuoteTrace = class(TForm)
    Panel1: TPanel;
    DateTimePickerTime: TDateTimePicker;
    ButtonGoto: TBitBtn;
    cbSymbol: TComboBox;
    sgInfo: TStringGrid;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    edtCnt: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtQty: TEdit;
    edtHoga: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbSymbolChange(Sender: TObject);
    procedure ButtonGotoClick(Sender: TObject);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtCntExit(Sender: TObject);
    procedure edtCntKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure edtQtyExit(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FSymbol : TSymbol;
    FQuote  : TQuote;
    FTime   : TDateTime;

    FRow    : integer;
    FStart, FEnd : integer;
    FRowCnt : integer;
    FOffset : integer;
    procedure initControls;
    procedure UpdateData( bPrev : boolean = false);
    procedure PutData(aData: TOrderData; iRow : integer);
    function  GetColor(stType: string): TColor;
    procedure ClearGrid;
    function FindData : integer;
    function CheckFilltering(aData: TOrderData): boolean;
    { Private declarations }
  public
    { Public declarations }
    OrdQty  : integer;
    OrdHoga : integer;
    OrdDiv  : string;

  end;

var
  QuoteTrace: TQuoteTrace;

implementation

uses
  GAppEnv, GleLib, GleTypes;

{$R *.dfm}


procedure TQuoteTrace.Button1Click(Sender: TObject);
begin
// log
end;

procedure TQuoteTrace.ButtonGotoClick(Sender: TObject);
var
  iRes : integer;
begin
  FTime := Frac(DateTimePickerTime.Time);
  iRes := FindData;
  if iRes < 0 then
    Exit;

  FStart := iRes;
  UpdateData;
end;

function TQuoteTrace.FindData : integer;
var
  i : integer;
  iH, iL, iM, iCom : integer;
  aData : TOrderData;
  src, desc : string;
begin
  Result := -1;
  if FQuote = nil then Exit;

  iL  := 0;
  iH  := FQuote.PriceAxis.OrderList.Count-1;

  src := FormatDateTime('hh:mm:ss', FTime );

  while iL <= iH do
  begin

    iM := ( iL + iH ) shr 1;
    aData := TOrderData( FQuote.PriceAxis.OrderList.Items[iM]);

    if aData = nil then
      break;

    desc := FormatDateTime('hh:mm:ss', aData.Time );
    iCom     := CompareStr( desc, src );

    if iCom > 0 then
      iL  := iM + 1
    else begin
      iH := iM -1;
      if iCom = 0 then
      begin
        Result := iM;
      end;
    end;

  end;

  if Result = -1 then
  begin
    if FQuote.PriceAxis.OrderList.Count-1 = iM then
      Result  := FQuote.PriceAxis.OrderList.Count-1;

    if iM = 0 then
      Result := 0;
  end;

end;





procedure TQuoteTrace.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if cbSymbol.ItemIndex < 0 then Exit;

  aSymbol := TSymbol( GetComboObject( cbSymbol ));
  if aSymbol <> nil then
  begin
    if FSymbol = aSymbol then Exit;

    FSymbol := aSymbol;
    if FSymbol.Quote <> nil then
    begin
      FQuote := FSymbol.Quote as TQuote;
      FStart := FQuote.PriceAxis.OrderList.Count-1;
      FEnd   := FStart - FRowCnt;
      UpdateData;
    end;
  end;

end;

procedure TQuoteTrace.edtCntExit(Sender: TObject);
var
  iCnt : integer;
begin
  iCnt := StrTointDef( edtCnt.Text, -1 );

  if (iCnt > 0 ) and ( iCnt <> FRowCnt ) then
  begin
    FRowCnt := iCnt;
    UpdateData;
  end;

end;

procedure TQuoteTrace.edtCntKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TQuoteTrace.edtQtyExit(Sender: TObject);
begin
  OrdHoga := StrToIntDef( edtHoga.Text, OrdHoga );
  OrdQty  := StrToIntDef( edtQty.Text, OrdQty );
  //OrdDiv  := edtDiv.Text;
  UpdateData;
end;

procedure TQuoteTrace.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TQuoteTrace.FormCreate(Sender: TObject);
begin

  FStart := 0;
  FEnd   := 0;
  FRow   := -1;
  FRowCnt := RowCnt;

  initControls;

  UpdateData;
end;

procedure TQuoteTrace.initControls;
var
  I: integer;
begin
  with sgInfo do
  begin
    ColCount  := ColCnt;
    RowCount  := StrToIntDef( edtCnt.Text, 50);

    for I := 0 to ColCnt - 1 do
    begin
      Cells[i,0]  := Title[i];
      ColWidths[i] := ColWidth[i];
    end;
  end;
  {

  gEnv.Engine.SymbolCore.SymbolCache.GetList( cbSymbol.Items );

  if cbSymbol.Items.Count > 0 then
  begin
    cbSymbol.ItemIndex  := 0;
    cbSymbolChange( nil );
  end;
  }
  OrdQty := StrToIntDef( edtQty.Text, 20);
  OrdHoga:= StrToIntDef( edtHoga.Text, 5 );

end;

procedure TQuoteTrace.ClearGrid;
var
  i :integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
end;

procedure TQuoteTrace.UpdateData( bPrev : boolean );
var
  aData : TOrderData;
  i, j, iH, iSa : integer;
  bContinue : boolean;
begin
  if FQuote = nil then Exit;

  ClearGrid;

  sgInfo.RowCount   := FRowCnt + 1;
  sgInfo.FixedRows  := 1;

  if bPrev then
  begin
      i := FStart;
      j := FRowCnt;
      while i >= 0 do
      begin
        if i > (FQuote.PriceAxis.OrderList.Count-1) then
        begin
          dec( i );
          break;
        end;

        if j < 1 then
        begin
          //inc( i );
          break;
        end;

        aData := TOrderData( FQuote.PriceAxis.OrderList.Items[i] );

        if aData <> nil then
        begin
          bContinue := CheckFilltering( aData );
          if not bContinue then
          begin
            inc( i );
            Continue;
          end;
          dec( j );
        end;
        inc( i );
      end;


      FStart := i;
      i := FStart;
      j := 1;
      while i >= 0 do
      begin
        if i < 0 then break;
        if j > FRowCnt then break;

        aData := TOrderData( FQuote.PriceAxis.OrderList.Items[i] );

        if aData <> nil then
        begin

          bContinue := CheckFilltering( aData );
          if not bContinue then
          begin
            dec( i );
            Continue;
          end;

          PutData( aData, j );
          inc( j );
        end;
        dec( i );
      end;

      FOffset := FStart - i;



  end
  else begin

      i := FStart;
      j := 1;
      while i >= 0 do
      begin
        if i < 0 then break;
        if j > FRowCnt then break;

        aData := TOrderData( FQuote.PriceAxis.OrderList.Items[i] );

        if aData <> nil then
        begin

          bContinue := CheckFilltering( aData );
          if not bContinue then
          begin
            dec( i );
            Continue;
          end;

          PutData( aData, j );
          inc( j );
        end;
        dec( i );
      end;

      FOffset := FStart - i;
  end;

end;

function TQuoteTrace.CheckFilltering( aData : TOrderData ) : boolean;
var
  iH : integer;
begin
  result := false;

  if StrToInt(aData.Qty) < OrdQty then
    Exit;

  if aData.QType in [ SN,SC,LN,LC,LPC,SPC] then
    iH  := aData.No + 1
  else if aData.QType = FL then
  begin
    if aData.Name[1] = 'N' then
      iH := aData.No2 + 1
    else
      iH := aData.No2 + 1;
  end
  else
    iH := aData.No2+1 ;

  if iH > OrdHoga then
    Exit;
 {
  if OrdDiv <> '' then
    if aData.GetOrderState <> OrdDiv then
      Exit;
}
  Result := true;

end;


procedure TQuoteTrace.PutData( aData : TOrderData; iRow : integer );
var
  iH, iCol : integer;
  stTmp : string;
begin

  iCol  := 0;

  with sgInfo do
  begin
    Objects[ DataIdx , iRow ] := aData;
    Cells[iCol, iRow] := FormatDateTime( 'HH:MM:SS.zzz', aData.Time );
    inc( iCol );

    Cells[iCol, iRow] := aData.GetOrderState;
    inc( iCol );

    if aData.QType in [ SN,SC,LN,LC,LPC,SPC] then
      stTmp  := IntToStr( aData.No + 1 )
    else if aData.QType = FL then
    begin
      if aData.Name[1] = 'N' then
        stTmp := IntToStr( aData.No2 + 1 )
      else
        stTmp := Format('%d->%d', [ aData.No+1, aData.No2+1 ]);
    end
    else
      stTmp := Format('%d->%d', [ aData.No+1, aData.No2+1 ]);

    Cells[iCol, iRow] := stTmp;
    inc( iCol );

    Cells[iCol, iRow] := aData.Price;
    inc( iCol );

    Cells[iCol, iRow] := aData.Qty;
    inc( iCol );

    Cells[iCol, iRow] := aData.FillQty;
  end;
end;

function TQuoteTrace.GetColor( stType : string ) : TColor;
begin
  if stType = 'L' then
    Result := lColor
  else if stType = 'S' then
    Result := sColor
  else if stType = 'Lx' then
    Result := lxColor
  else if stType = 'Sx' then
    Result := SxColor
  else if stType = 'Lc' then
    Result := clBlack
  else if stType = 'Sc' then
    Result := clBlack
  else
    Result := clBlack;
end;


procedure TQuoteTrace.sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    ACol : integer;
begin
  sgInfo.MouseToCell( X, Y, ACol, FRow );
  sgInfo.Repaint;
end;

// prev
procedure TQuoteTrace.SpeedButton1Click(Sender: TObject);
begin
  //
  if FQuote = nil then Exit;
  if FStart = (FQuote.PriceAxis.OrderList.Count-1 )  then Exit;

  //FStart := Min( FQuote.PriceAxis.OrderList.Count-1 , FStart );

  UpdateData( true );
end;

// next
procedure TQuoteTrace.SpeedButton2Click(Sender: TObject);
begin
  if FQuote = nil then Exit;

  FStart := Max( 0, FStart - FOffset );

  UpdateData;

end;

procedure TQuoteTrace.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    ftColor, bkColor : TColor;
    stTxt : string;
    iX, iY : integer;
    aSize : TSize;
    aData : TOrderData;
begin
  bkColor := clWhite;
  ftColor := clBlack;

  with sgInfo do
  begin
    stTxt := Cells[ ACol, ARow ];
    aSize := Canvas.TextExtent(stTxt);

    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;

    if ARow = 0 then
      bkColor := clBtnFace
    else begin
      aData := TOrderData( Objects[DataIdx, ARow] );
      if aData = nil then Exit;

      case ACol of
        1,2,3,4,5:
          begin
            ftColor := GetColor( aData.GetOrderState );
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
        else

      end;

      if ARow = FRow then
        bkColor := $00F2BEB9;
    end;

    Canvas.Brush.Color  := bkColor;
    Canvas.Font.Color   := ftColor;
    Canvas.FillRect( Rect );

    Canvas.TextRect(Rect, iX, iY, stTxt);
  end;

end;


end.
