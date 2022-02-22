unit CDistPainter;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
    // lemon: data
  GleLib, CleSymbols, CleQuoteBroker, ClePriceItems;

const
  MAX_TP_COLUMNS = 2;

type
  TDistPainter = class
  private
      // assigned objects
    FQuote: TQuote;
    FPaintBox: TPaintBox;

      // created objects
    FBitmap: TBitmap;
      // drawing factors
    FRowCount: Integer;
    FRowHeight: Integer;
    FRowSpan: Integer;
    FColCount: Integer;
    FColSpan: Integer;

    FColWidths: array[0..MAX_TP_COLUMNS-1] of Integer;
    FLefts: array[0..MAX_TP_COLUMNS-1] of Integer;
    FRights: array[0..MAX_TP_COLUMNS-1] of Integer;
    FWidth: integer;
    FHeight: integer;
    FPrice: double;
    FInfo: TPriceItem;
    FHoga: integer;
    FBPrice: boolean;
    FFilter: integer;
    
    procedure SetQuote(const Value: TQuote);

      // set routines
    procedure SetPaintBox(aBox : TPaintBox);
    procedure SetRowCount(iRowCount : Integer);

      // drawing routines
    procedure DrawBackground;
    procedure DrawTicks;

      // misc.
    procedure SetDimension;
    procedure ApplyDrawing;
    procedure PaintProc(Sender : TObject);
    procedure SetPrice(const Value: double);
    procedure SetHoga(const Value: integer);
  public
    aRect : TRect;
    constructor Create( iH, iW :integer); overload;
    destructor Destroy; override;

    procedure Update;
    procedure Resize;
    procedure UpdateSize;


    property Quote: TQuote read FQuote write SetQuote;
    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
    property RowCount: Integer read FRowCount write SetRowCount;
    property Height : integer read FHeight write FHeight;
    property Width  : integer read FWidth write FWidth;
    property Price  : double read FPrice Write SetPrice;
    property Hoga   : integer read FHoga Write SetHoga;
    property Info   : TPriceITem Read FInfo;
    property BPrice : boolean read FBPrice;
    property Filter : integer read FFilter write FFilter;

  end;

implementation

uses CleDistConst, GleTypes;

//--------------------< Create/Destroy >----------------------//

constructor TDistPainter.Create( iH, iW :integer);
begin
  FBitmap := TBitmap.Create;

  FHeight := iH;
  FWidth  := iW;

  FRowHeight := 45;
  FRowCount := 1;
  FColCount := 2;
  FColWidths[0] := 100;
  FColWidths[1] := FWidth - FColWidths[0] ;

  FInfo := nil;

  FBPrice := true;
  SetDimension;
end;

destructor TDistPainter.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TDistPainter.SetDimension;
begin
  FRowSpan := FWidth;
  FColSpan := (FRowCount) * FRowHeight; // + colume header line

  FLefts[0] := 0;
  FRights[0] := FColWidths[0];
  FLefts[1] := FRights[0];
  FRights[1] := FRights[0] + FColWidths[1];

end;
procedure TDistPainter.SetHoga(const Value: integer);
begin
  FHoga := Value;
  FBPrice := false;
  Update;
end;

//-------------------------< Set Routines >-------------------//

procedure TDistPainter.SetPaintBox(aBox : TPaintBox);
begin
  if aBox = nil then Exit;

  FPaintBox := aBox;
  FPaintBox.OnPaint := PaintProc;

  Resize;

  FPaintBox.Font.Name := '굴림체';
  FPaintBox.Font.Size := 9;
  FBitmap.Canvas.Brush.Color := BACK_COLOR;

end;

procedure TDistPainter.SetPrice(const Value: double);
var iTmp : integer;
begin
  FPrice := Value;
  FInfo := FQuote.PriceAxis.Find( FPrice, itmp);
  FBPrice := true;
  Update;  
end;

procedure TDistPainter.SetQuote(const Value: TQuote);
begin
  FQuote := Value;

  if FQuote = nil then Exit;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;

const
  MAX_ROWCOUNT = 1;
  MIN_ROWCOUNT = 1;

procedure TDistPainter.SetRowCount(iRowCount : Integer);
begin
  iRowCount := Max(Min(iRowCount, MAX_ROWCOUNT), MIN_ROWCOUNT);

  FRowCount := iRowCount;

  SetDimension;

  if FPaintBox <> nil then
    FPaintBox.Height := FColSpan + 1;
end;

//-----------------------< Drawing control Routines >-------------------------//

procedure TDistPainter.Resize;
begin
  if FPaintBox = nil then Exit;

  FBitmap.Width := FWidth;//  FPaintBox.Width;
  FBitmap.Height := FHeight;// FPaintBox.Height;

  FBitmap.Canvas.Font.Name := FPaintBox.Font.Name;
  FBitmap.Canvas.Font.Size := FPaintBox.Font.Size;
end;

procedure TDistPainter.PaintProc(Sender : TObject);
begin
  Resize;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;


procedure TDistPainter.Update;
begin
  if FQuote = nil then Exit;

  DrawTicks;
  ApplyDrawing;
end;

procedure TDistPainter.UpdateSize;
begin
  FColWidths[0] := 100;
  FColWidths[1] := FWidth - FColWidths[0] ;
  Resize;
  SetDimension;
end;

//-----------------------< Actual Drawing Routines >-------------------------//

procedure TDistPainter.DrawBackground;
var
  i, iTop : Integer;
  oRect : TRect;
  stTmp : string;
begin
  if FPaintBox = nil then Exit;

  with FBitmap.Canvas do
  begin
    Brush.Color := BACK_COLOR;
    FillRect( FPaintBox.ClientRect);
    Brush.Color := LINE_COLOR;
    //n.Color := LINE_COLOR;
    // background
    oRect := FPaintBox.ClientRect;
    aRect.Left  := oRect.Left + 1;
    aRect.Top   := oRect.Top  + 1;
    aRect.Right := oRect.Right- 1;
    aRect.Bottom:= orect.Bottom-1;

    //ameRect(FPaintBox.ClientRect);
    FrameRect( aRect );
    // grid line horizontal
    Pen.Color := LINE_COLOR;

    for i:=0 to FColCount-2 do
    begin
      MoveTo(FRights[i]+1, aRect.Top );
      LineTo(FRights[i]+1, aRect.Bottom);
    end;

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2, FRights[0]+1, aRect.Bottom-1),
            '', Dist_TITLE, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2, FRights[1]-2, aRect.Bottom-1),
            '', DIST_DATA, clBlack, taCenter);

  end;
end;

procedure TDistPainter.DrawTicks;
var
  aColor: TColor;
  stTxt, stTmp : string;
  iPrec , k, x, y, iInc, iTmp: integer;
  aDist : TForceDist;
begin
  if (FQuote = nil) or (FQuote.Symbol = nil)
     or (FQuote.Symbol.Spec = nil) then Exit;
  // data
  if not FBPrice then begin
    if FHoga < 0 then
      FInfo := FQuote.PriceAxis.Find( FQuote.Asks[ abs(FHoga)].Price, iTmp )
    else
      FInfo := FQuote.PriceAxis.Find( FQuote.Bids[ FHoga].Price, iTmp );
  end;

  if FInfo = nil then
    Exit;
  stTxt := '선택호가';
  if FInfo.Side[Last] = stLong then
    aColor := clRed
  else
    aColor := clBlue;

  iPrec := (aRect.Bottom-1) div 2;

  FBitmap.Canvas.Font.Style := FBitmap.Canvas.Font.Style + [fsBold];
  FBitmap.Canvas.Font.Size  := 11;


  stTmp := Format( '%.*n', [ FQuote.Symbol.Spec.Precision, FInfo.Price] );
  DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2, FRights[0]+1, iPrec),
            stTxt, Dist_TITLE, aColor, taCenter);
  DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, iPrec, FRights[0]+1, aRect.Bottom-1),
            stTmp, Dist_TITLE, aColor, taCenter);

  FBitmap.Canvas.Font.Style := FBitmap.Canvas.Font.Style - [fsBold];
  FBitmap.Canvas.Font.Size  := 9;

  iPrec := (aRect.Bottom-1) div 3;

  stTmp := '';
  x := FLefts[1] + 2;
  y := 3;
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2, FRights[1]-2, aRect.Bottom-1),
        '', DIST_DATA, clBlack, taCenter);
  for k := 0 to FInfo.ForceList.Count-1  do begin
    aDist := TForceDist( FInfo.ForceList.Items[k]);
    if aDist = nil then
      Continue;
    if aDist.DonNo then begin
      FBitmap.Canvas.Font.Color := clFuchsia;
    end
    else if aDist.Qty > FFilter then begin
      FBitmap.Canvas.Font.Color := clPurple;
    end
    else begin
      FBitmap.Canvas.Font.Color := clBlack;
    end;

    if (x >= (FRights[1]-2)) then begin
      x := FLefts[1] + 2;
      inc( y, iPrec );
    end;
    stTmp :=  IntToStr( aDist.Qty);
    FBitmap.Canvas.TextOut( x, y, stTmp);

    iInc := FBitmap.Canvas.TextWidth( stTmp + ' ');
    inc( x, iInc );
  end;

end;

procedure TDistPainter.ApplyDrawing;
begin
  if FPaintBox = nil then Exit;

  FPaintBox.Canvas.Draw(0,0, FBitmap);
end;

end.
