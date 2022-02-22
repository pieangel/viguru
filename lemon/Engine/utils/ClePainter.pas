unit ClePainter;

interface

uses
  Windows, Classes, Graphics, Math, SysUtils;
  
type
  TPainter = class
  private
    FBitmap : TBitmap;

      // areas
    FLeft: Integer;
    FTop: Integer;
    FClientRect: TRect;
    FDrawRect: TRect;
    FMarginRect: TRect;

      // colors
    FBackgroundColor: TColor;
    FAxisColor: TColor;
    FScaleColor: TColor;
    FGridColor: TColor;
    FMessageColor: TColor;

      // scale parameters
    FXScaleSpacing: Integer;
    FYScaleSpacing: Integer;

      // dynamic parameters
    FXMin, FXMax, FXRatio: Double;
    FXPrec: Integer;
    FYMin, FYMax, FYRatio: Double;
    FYPrec: Integer;

      // cursor tracking
    FCursorTracking: Boolean;
    FCursorX, FCursorY: Integer;
    FTextRectL, FTextRectR: TRect;

    procedure ClearText(aCanvas: TCanvas);
    procedure DrawHairs(aCanvas: TCanvas);
    procedure DrawText(aCanvas: TCanvas);

    function GetDrawCanvas: TCanvas;

  public
    constructor Create;
    destructor Destroy; override;

      // set area
    procedure SetMargin(iLeft, iTop, iRight, iBottom: Integer);
    procedure SetDrawingArea(aRect: TRect);

      // set drawing ratio
    procedure SetXRatio(dMin, dMax: Double; dMarginRate: Double = 0.0);
    procedure SetYRatio(dMin, dMax: Double; dMarginRate: Double = 0.0);
    procedure SetRatio(dXMin, dXMax, dYMin, dYMax: Double;
      dXMargin: Double = 0.0; dYMargin: Double = 0.0);

      // conversions
    function GetXPos(dValue: Double): Integer;
    function GetYPos(dValue: Double): Integer;
    function GetYPosRev(dValue: Double): Integer;
    function GetXValue(iX: Integer): Double;
    function GetYValue(iY: Integer): Double;

      // draw
    procedure DrawBackground;
    procedure DrawMessage(stMsg: String);
    procedure DrawAxis(bXAxis: Boolean = True; bYAxis: Boolean = True);
    procedure DrawXAxis;
    procedure DrawYAxis;
    procedure DrawFrame;

    procedure Display(aCanvas: TCanvas);

      // cursor tradking
    procedure DoCursorTracking(aCanvas: TCanvas; X, Y: Integer);
    procedure StartCursorTracking(aCanvas: TCanvas; X, Y: Integer);
    procedure StopCursorTracking;

      // property: area
    property DrawCanvas: TCanvas read GetDrawCanvas;
    property DrawRect: TRect read FDrawRect;
    property MarginRect: TRect read FMarginRect;

      // property: scale parameters
    property XScaleSpacing: Integer read FXScaleSpacing write FXScaleSpacing;
    property YScaleSpacing: Integer read FYScaleSpacing write FYScaleSpacing;

      // property: colors
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor;
    property AxisColor: TColor read FAxisColor write FAxisColor;
    property ScaleColor: TColor read FScaleColor write FScaleColor;
    property GridColor: TColor read FGridColor write FGridColor;
    property MessageColor: TColor read FMessageColor write FMessageColor;
  end;

  TPainterItem = class(TCollectionItem)
  private
    FPainter: TPainter;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    property Painter: TPainter read FPainter;
  end;

  TPainters = class(TCollection)
  private
    FDisplayCount: Integer;
    FMarginRect: TRect;
    function GetPainter(i: Integer): TPainter;
  public
    constructor Create;

    procedure SetMargin(iLeft, iTop, iRight, iBottom: Integer);
    procedure SetDimension(iGraphCount: Integer; aRect: TRect);

    procedure Display(aCanvas: TCanvas);
    procedure DrawBackground;
    procedure DrawFrame;

    property Painters[i:Integer]: TPainter read GetPainter;
  end;

procedure DrawUpwardSignalArrow(aCanvas : TCanvas; iX, iY : Integer;
  stText : String; bgColor : TColor; iWidth : Integer = 6; bColor : TColor = clBlue);
procedure DrawDownwardSignalArrow(aCanvas : TCanvas; iX, iY : Integer;
  stText : String; bgColor : TColor; iWidth : Integer = 6; bColor : TColor = clRed);

implementation

procedure DrawUpwardSignalArrow(aCanvas : TCanvas; iX, iY : Integer;
  stText : String; bgColor : TColor; iWidth : Integer; bColor : TColor);
var
  iHalfWidth : Integer;
  iBarHeight : Integer;
  aSize : TSize;
begin
  if aCanvas = nil then Exit;

  aCanvas.Brush.Color := bColor;
  aCanvas.Pen.Color   := bColor;
  aCanvas.Font.Color  := bColor;

  iHalfWidth := iWidth div 2;
  iBarHeight := iWidth;

  aCanvas.Polygon([Point(iX, iY),
                   Point(iX-iHalfWidth, iY+iBarHeight+1),
                   Point(iX+iHalfWidth, iY+iBarHeight+1)]);
  aCanvas.Rectangle(iX-iHalfWidth+2, iY+iBarHeight+1,
                    iX+iHalfWidth-1, iY+2*iBarHeight+1);

  aSize := aCanvas.TextExtent(stText);
  aCanvas.Brush.Color := bgColor;
  aCanvas.TextOut(iX-aSize.cx div 2, iY+2*iBarHeight+3, stText);
end;

procedure DrawDownwardSignalArrow(aCanvas : TCanvas; iX, iY : Integer;
  stText : String; bgColor : TColor; iWidth : Integer; bColor : TColor);
var
  iHalfWidth : Integer;
  iBarHeight : Integer;
  aSize : TSize;
begin
  if aCanvas = nil then Exit;

  aCanvas.Brush.Color := bColor;
  aCanvas.Pen.Color   := bColor;
  aCanvas.Font.Color  := bColor;

  iHalfWidth := iWidth div 2;
  iBarHeight := iWidth;

  aCanvas.Polygon([Point(iX, iY),
                   Point(iX-iHalfWidth, iY-iBarHeight-1),
                   Point(iX+iHalfWidth, iY-iBarHeight-1)]);
  aCanvas.Rectangle(iX-iHalfWidth+2, iY-iBarHeight-1,
                    iX+iHalfWidth-1, iY-2*iBarHeight-1);

  aSize := aCanvas.TextExtent(stText);
  aCanvas.Brush.Color := bgColor;
  aCanvas.TextOut(iX-aSize.cx div 2, iY-2*iBarHeight-3-aSize.cy, stText);
end;

{ TPainter }

constructor TPainter.Create;
begin
  FBitmap := TBitmap.Create;

  FMarginRect := Classes.Rect(50, 20, 50, 20);

  FXScaleSpacing := 60;
  FYScaleSpacing := 50;

  FBackgroundColor := clWhite;
  FAxisColor := clGray;
  FScaleColor := clBlack;
  FGridColor := clLtGray;
  FMessageColor := clRed;
end;

destructor TPainter.Destroy;
begin
  FBitmap.Free;

  inherited;
end;

function TPainter.GetDrawCanvas: TCanvas;
begin
  Result := FBitmap.Canvas;
end;

procedure TPainter.SetMargin(iLeft, iTop, iRight, iBottom: Integer);
begin
  FMarginRect.Left := iLeft;
  FMarginRect.Top := iTop;
  FMarginRect.Right := iRight;
  FMarginRect.Bottom := iBottom;
end;

procedure TPainter.SetDrawingArea(aRect: TRect);
begin
    // set bitmap dimension
  FBitmap.Width := aRect.Right - aRect.Left;
  FBitmap.Height := aRect.Bottom - aRect.Top;

    // set total drawing area
  FLeft := aRect.Left;
  FTop := aRect.Top;
  FClientRect.Left := 0;
  FClientRect.Top := 0;
  FClientRect.Right := FBitmap.Width;
  FClientRect.Bottom := FBitmap.Height;
  
    // set chart-drawing area
  FDrawRect.Left   := FClientRect.Left + FMarginRect.Left;
  FDrawRect.Top    := FClientRect.Top + FMarginRect.Top;
  FDrawRect.Right  := FClientRect.Right - FMarginRect.Right;
  FDrawRect.Bottom := FClientRect.Bottom - FMarginRect.Bottom;
end;

procedure TPainter.DrawBackground;
begin
  with FBitmap.Canvas do
  begin
    Brush.Color := FBackgroundColor;
    FillRect(FClientRect);
  end;
end;

procedure TPainter.DrawFrame;
begin
  with FBitmap.Canvas do
  begin
    Brush.Color := FAxisColor;
    FrameRect(
      Rect(FDrawRect.Left-1,FDrawRect.Top-1,
           FDrawRect.Right+1,FDrawRect.Bottom+1));
  end;
end;

procedure TPainter.DrawMessage(stMsg: String);
begin
  with FBitmap.Canvas do
  begin
    Font.Color := FMessageColor;
    TextOut(FDrawRect.Left+10,FDrawRect.Top+10, stMsg);
  end;
end;

procedure TPainter.SetRatio(dXMin, dXMax, dYMin, dYMax,
  dXMargin, dYMargin: Double);
begin
  SetXRatio(dXMin, dXMax, dXMargin);
  SetYRatio(dYMin, dYMax, dYMargin);
end;

procedure TPainter.SetXRatio(dMin, dMax, dMarginRate: Double);
var
  dMargin: Double;
begin
  if dMarginRate > 1.0e-4 then
  begin
    dMargin := (dMax - dMin) * dMarginRate;

    if dMargin < 1.0e-10 then
    begin
      dMax := 0.05;
      dMin := -0.05;
    end else
    begin
      dMax := dMax + dMargin;
      dMin := dMin - dMargin;
    end;
  end;

  FXMax := dMax;
  FXMin := dMin;

  if not Math.IsZero(dMax - dMin, 1.0e-10) then
    FXRatio := (FDrawRect.Right - FDrawRect.Left) / (dMax - dMin)
  else
    FXRatio := 0.0;
end;

procedure TPainter.SetYRatio(dMin, dMax, dMarginRate: Double);
var
  dMargin: Double;
begin
  if dMarginRate > 1.0e-4 then
  begin
    dMargin := (dMax - dMin) * dMarginRate;

    if dMargin < 1.0e-10 then
    begin
      dMax := 0.05;
      dMin := -0.05;
    end else
    begin
      dMax := dMax + dMargin;
      dMin := dMin - dMargin;
    end;
  end;

  FYMax := dMax;
  FYMin := dMin;

  if not Math.IsZero(dMax - dMin, 1.0e-10) then
    FYRatio := (FDrawRect.Bottom - FDrawRect.Top) / (dMax - dMin)
  else
    FYRatio := 0;
end;

procedure TPainter.DrawAxis(bXAxis, bYAxis: Boolean);
begin
  if bXAxis then DrawXAxis;
  if bYAxis then DrawYAxis;
end;

procedure TPainter.DrawXAxis;
var
  dValue, dStep, dScale: Double;
  iX: Integer;
  aSize: TSize;
  stText: String;
begin
  with FBitmap.Canvas do
  begin
      // Draw Y-axis
    dValue := (FXMax - FXMin) / (FDrawRect.Right-FDrawRect.Left-2) * FXScaleSpacing;
    if dValue < 1.0e-10 then Exit;
    FXPrec := Ceil(Log10(dValue));
    dStep := Power(10, FXPrec);
    if dStep / 10 > dValue then
    begin
      dStep := dStep / 10; Dec(FXPrec);
    end else
    if dStep / 5 > dValue then
    begin
      dStep := dStep / 5; Dec(FXPrec);
    end else
    if dStep / 2 > dValue then
    begin
      dStep := dStep / 2; Dec(FXPrec);
    end;
    dScale := dStep * Round(FXMin/dStep);
    if dScale < FXMin then
     dScale := dScale + dStep;

    FXPrec := Max(0, -FXPrec);

    Brush.Color := FBackgroundColor;
    Pen.Color := FGridColor;
    Pen.Width := 1;
    Font.Color := FScaleColor;

    while dScale < FXMax do
    begin
      Pen.Color := clLtGray;
      iX := FDrawRect.Left + Round((dScale-FXMin)*FXRatio) + 1;
        // grid line
      MoveTo(iX, FDrawRect.Bottom + 5);
      LineTo(iX, FDrawRect.Top);
        // scale text
      stText := Format('%.*f', [FXPrec, dScale]);
      aSize := TextExtent(stText);
      TextOut(iX, FDrawRect.Bottom+5, stText);

      dScale := dScale + dStep;
    end;
  end;
end;

procedure TPainter.DrawYAxis;
var
  dValue, dStep, dScale: Double;
  iY: Integer;
  aSize: TSize;
  stText: String;
begin
  with FBitmap.Canvas do
  begin
      // Draw Y-axis
    dValue := (FYMax - FYMin) / (FDrawRect.Bottom-FDrawRect.Top-2) * FYScaleSpacing;
    if dValue < 1.0e-10 then Exit;

    FYPrec := Ceil(Log10(dValue));
    dStep := Power(10, FYPrec);
    if dStep / 10 > dValue then
    begin
      dStep := dStep / 10; Dec(FYPrec);
    end else
    if dStep / 5 > dValue then
    begin
      dStep := dStep / 5; Dec(FYPrec);
    end else
    if dStep / 2 > dValue then
    begin
      dStep := dStep / 2; Dec(FYPrec);
    end;
    dScale := dStep * Round(FYMin/dStep);
    if dScale < FYMin then
      dScale := dScale + dStep;
    FYPrec := Max(0, -FYPrec);

    Brush.Color := FBackgroundColor;
    Pen.Color := FGridColor;
    Pen.Width := 1;
    Font.Color := FScaleColor;
    
    while dScale < FYMax do
    begin
      iY := FDrawRect.Bottom - Round((dScale-FYMin)*FYRatio)-1;
      stText := Format('%.*f', [FYPrec, dScale]);
      aSize := TextExtent(stText);
      TextOut(FDrawRect.Left - aSize.cx - 10, iY - aSize.cy div 2, stText);
      MoveTo(FDrawRect.Left - 5, iY);
      LineTo(FDrawRect.Right + 5, iY);
      TextOut(FDrawRect.Right + 10, iY - aSize.cy div 2, stText);

      dScale := dScale + dStep;
    end;
  end;
end;

function TPainter.GetXPos(dValue: Double): Integer;
begin
  Result := Round((dValue-FXMin)*FXRatio) + FDrawRect.Left;
end;

function TPainter.GetYPos(dValue: Double): Integer;
begin
  Result := FDrawRect.Bottom - Round((dValue-FYMin)*FYRatio);
end;

function TPainter.GetYPosRev(dValue: Double): Integer;
begin
  Result := Round((dValue-FYMin)*FYRatio) + FDrawRect.Top;
end;

procedure TPainter.Display(aCanvas: TCanvas);
begin
  aCanvas.Draw(FLeft, FTop, FBitmap);
end;

procedure TPainter.DrawHairs(aCanvas: TCanvas);
begin
  with aCanvas do
  begin
    Pen.Color := $FFFF00;
    Pen.Width := 1;
    Pen.Mode := pmXOR;
    MoveTo(FDrawRect.Left, FCursorY); LineTo(FDrawRect.Right, FCursorY);
    MoveTo(FCursorX, FDrawRect.Top); LineTo(FCursorX, FDrawRect.Bottom);
    Pen.Mode := pmCopy;
  end;
end;

procedure TPainter.DrawText(aCanvas: TCanvas);
var
  stText: String;
  aSize: TSize;
begin
  with aCanvas do
  begin
    stText := Format('%.*f', [FYPrec+2, GetYValue(FCursorY)]);
    aSize := TextExtent(stText);

    FTextRectL.Left := FDrawRect.Left - 10 - aSize.cx;
    FTextRectL.Right := FTextRectL.Left + aSize.cx;
    FTextRectL.Top := FCursorY - aSize.cy div 2;
    FTextRectL.Bottom := FTextRectL.Top + aSize.cy;

    FTextRectR.Left := FDrawRect.Right + 10;
    FTextRectR.Right := FTextRectR.Right + aSize.cx;
    FTextRectR.Top := FCursorY - aSize.cy div 2;
    FTextRectR.Bottom := FTextRectR.Top + aSize.cy;

    Brush.Color := clBlue;
    Font.Color := clWhite;
    TextOut(FTextRectL.Left, FTextRectL.Top, stText);
    TextOut(FTextRectR.Left, FTextRectR.Top, stText);
  end;
end;

procedure TPainter.ClearText(aCanvas: TCanvas);
begin
  with aCanvas do
  begin
    CopyRect(FTextRectL, FBitmap.Canvas, FTextRectL);
    CopyRect(FTextRectR, FBitmap.Canvas, FTextRectR);
  end;
end;

function TPainter.GetXValue(iX: Integer): Double;
begin
  if FXRatio > 1.0e-10 then
    Result := (iX-FDrawRect.Left)/FXRatio + FXMin
  else
    Result := 0;
end;

function TPainter.GetYValue(iY: Integer): Double;
begin
  if FYRatio > 1.0e-10 then
    Result := (FDrawRect.Bottom-iY)/FYRatio + FYMin
  else
    Result := 0.0;
end;

procedure TPainter.StartCursorTracking(aCanvas: TCanvas; X, Y: Integer);
begin
  if (X > FDrawRect.Left) and (X < FDrawRect.Right) and
     (Y > FDrawRect.Top) and (Y < FDrawRect.Bottom) then
  begin
    FCursorTracking := True;
    FCursorX := X;
    FCursorY := Y;
    DrawHairs(aCanvas);
    DrawText(aCanvas);
  end;
end;

procedure TPainter.DoCursorTracking(aCanvas: TCanvas; X, Y: Integer);
begin
  if FCursorTracking then
  begin
    DrawHairs(aCanvas);
    FCursorX := X;
    FCursorY := Y;
    DrawHairs(aCanvas);
    ClearText(aCanvas);
    DrawText(aCanvas);
  end;
end;

procedure TPainter.StopCursorTracking;
begin
  FCursorTracking := False;
end;


{ TPainterItem }

constructor TPainterItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FPainter := TPainter.Create;
end;

destructor TPainterItem.Destroy;
begin
  FPainter.Free;

  inherited;
end;

{ TPainters }

constructor TPainters.Create;
begin
  inherited Create(TPainterItem);

  FDisplayCount := 0;
end;

procedure TPainters.SetMargin(iLeft, iTop, iRight, iBottom: Integer);
begin
  FMarginRect.Left := iLeft;
  FMarginRect.Top := iTop;
  FMarginRect.Right := iRight;
  FMarginRect.Bottom := iBottom;
end;

procedure TPainters.SetDimension(iGraphCount: Integer; aRect: TRect);
var
  iCol, iRow: Integer;
  iWidth, iHeight: Integer;
  iDivision: Integer;
  aPainter: TPainter;
begin
    // get display count
  FDisplayCount := 1;
  iDivision := 1;
  while FDisplayCount < iGraphCount do
  begin
    Inc(iDivision);
    FDisplayCount := iDivision * iDivision;
  end;

    // generate painter as needed
  if FDisplayCount > Count then
    while FDisplayCount > Count do
       Add;

    //
  iWidth := (aRect.Right - aRect.Left) div iDivision;
  iHeight := (aRect.Bottom - aRect.Top) div iDivision;
  
  for iCol := 0 to iDivision - 1 do
    for iRow := 0 to iDivision - 1 do
    begin
      aPainter := (Items[iRow*iDivision + iCol] as TPainterItem).Painter;

      aPainter.SetMargin(FMarginRect.Left, FMarginRect.Top,
                         FMarginRect.Right, FMarginRect.Bottom);
      aPainter.SetDrawingArea(Classes.Rect(aRect.Left + iCol*iWidth,
                                           aRect.Top + iRow*iHeight,
                                           aRect.Left + (iCol+1)*iWidth,
                                           aRect.Top + (iRow+1)*iHeight));
    end;
end;

procedure TPainters.DrawBackground;
var
  i: Integer;
begin
  for i := 0 to FDisplayCount - 1 do
    GetPainter(i).DrawBackground;
end;

procedure TPainters.DrawFrame;
var
  i: Integer;
begin
  for i := 0 to FDisplayCount - 1 do
    GetPainter(i).DrawFrame;
end;

procedure TPainters.Display(aCanvas: TCanvas);
var
  i: Integer;
begin
  for i := 0 to FDisplayCount - 1 do
    GetPainter(i).Display(aCanvas);
end;

function TPainters.GetPainter(i: Integer): TPainter;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := (Items[i] as TPainterItem).Painter
  else
    Result := nil;
end;

end.
