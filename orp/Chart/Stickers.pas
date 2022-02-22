unit Stickers;

interface

uses Classes, Graphics, Windows, SysUtils,  
     //
     Charters, Symbolers;


type
  { stickers }

  TSticker = class(TCharter)
  protected
    FSeriesCharter : TSeriesCharter;
    FColor : TColor;
  public
    constructor Create(aSeriesCharter : TSeriesCharter);
    
    property Color : TColor read FColor write FColor;
    property SeriesCharter : TSeriesCharter read FSeriesCharter;
  end;

  { 추세선 }
  TTrendLine = class(TSticker)
  private
    FSValue, FEValue : Double;
    FSIndex, FEIndex : Integer;
    FSPoint, FEPoint : TPoint;
  public
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean ); override;

    property SIndex : Integer read FSIndex write FSIndex;
    property EIndex : Integer read FEIndex write FEIndex;
    property SValue : Double read FSValue write FSValue;
    property EValue : Double read FEValue write FEValue;
    //
    property SPoint : TPoint read FSPoint write FSPoint;
    property EPoint : TPoint read FEPoint write FEPoint;
  end;

  { 수평선 }
  THorizLine = class(TSticker)
  private
    FValue : Double;
  public
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean); override;
    property Value : Double read FValue write FValue;
  end;

  TCustomHorizLine = class(TSticker)
  private
    FValue : Double;
    FLineColor: TColor;
  public
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean); override;
    property Value : Double read FValue write FValue;
    property LineColor : TColor read FLineColor write FLineColor;
  end;

  { 수직선 }
  TVertLine = class(TSticker)
  private
    FBarIndex : Integer;
  public
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean); override;
    property BarIndex: Integer read FBarIndex write FBarIndex;
  end;

implementation

//==============================================================//
                         { TSticker }
//==============================================================//

constructor TSticker.Create(aSeriesCharter : TSeriesCharter);
begin
  FSeriesCharter := aSeriesCharter;
  FColor := clRed;
end;

//==============================================================//
                           { TTrendLine }
//==============================================================//

function TTrendLine.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
const
  HIT_RANGE = 2;
var
  P1, P2 : TPoint;
  dY, dRY : Double;
  X1, X2 : Integer;
begin
  Result := False;
  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;
  if (FSIndex <= FEIndex) and
     ((iBarIndex < FSIndex) or (iBarIndex > FEIndex)) then Exit;
  if (FSIndex > FEIndex) and
     ((iBarIndex < FEIndex) or (iBarIndex > FSIndex)) then Exit;

  //-- scale
  dRY := (aRect.Bottom - aRect.Top) / (FSeriesCharter.MaxValue - FSeriesCharter.MinValue);
  //
  P1.x := aRect.Left + (FSIndex - iStartIndex)*iBarWidth + iBarWidth div 2;
  P2.x := aRect.Left + (FEIndex - iStartIndex)*iBarWidth + iBarWidth div 2;
  P1.y := aRect.Bottom - Round((FSValue - FSeriesCharter.MinValue)*dRY);
  P2.y := aRect.Bottom - Round((FEValue - FSeriesCharter.MinValue)*dRY);
  //
  if P1.x <> P2.x then
    dY := P1.y + (iHitX-P1.x)*(P2.y-P1.y)/(P2.x-P1.x)
  else
    dY := P1.y;
  //
  if P1.x >= P2.x then
  begin
    X2 := P1.x;
    X1 := P2.x;
  end else
  begin
    X2 := P2.x;
    X1 := P1.x;
  end;
  //
  if (iHitX >= X1) and (iHitX <= X2) then
  begin
    if X1 = X2 then
      if (P1.y > P2.y) then
        Result := (iHitY >= P2.Y) and (iHitY <= P1.Y)
      else
        Result := (iHitY >= P1.Y) and (iHitY <= P2.Y)
    else
      Result := (iHitY >= dY-HIT_RANGE) and (iHitY <= dY+HIT_RANGE);
  end;
end;

procedure TTrendLine.Draw(const aCanvas : TCanvas; const aRect : TRect;
               const iStart, iEnd, iBarWidth : Integer;
               const bSelected : Boolean );
const
  SEL_WIDTH = 3;

  BOTH_IN = [2];
  BOTH_OUT = [1,4,5];
  ONE_OUT = [3,6];
var
  aPenColor, aBrushColor : TColor;
  aPenMode : TPenMode;

  P1, P2 : TPoint;
  bSIn, bEIn : Boolean;
  dRY : Double;

  procedure SetIntersection(PIn : TPoint; var POut : TPoint);
  var
    iXBound, iYBound, iXMeet, iYMeet : Integer;
    dR, dC : Double;

    aHPoint, aVPoint : TPoint;
    iXCut, iYCut : Integer;
    iX, iY : Integer;
  begin
      // get boundary (X,Y)
    if pOut.x > pIn.x then
      iXBound := aRect.Right
    else
      iXBound := aRect.Left;
    if pOut.y > pIn.y then
      iYBound := aRect.Bottom
    else
      iYBound := aRect.Top;

      //--
    if POut.x = pIn.x then
      pOut.y := iYBound
    else if pOut.y = pIn.y then
      pOut.x := iXBound
    else
    begin
      dR := (pOut.y-pIn.y)/(pOut.x-pIn.x);
      dC := pIn.y - dR * pIn.x;
      iYMeet := Round(dR*iXBound + dC);
      iXMeet := Round((iYBound - dC)/dR);
      if (iYMeet >= aRect.Top) and (iYMeet <= aRect.Bottom) then
      begin
        pOut.x := iXBound;
        pOut.y := iYMeet;
      end else
      if (iXMeet >= aRect.Left) and (iXMeet <= aRect.Right) then
      begin
        pOut.x := iXMeet;
        pOut.y := iYBound;
      end;
    end;
  end;
begin
     // copy GDI info.
  aPenColor := aCanvas.Pen.Color;
  aBrushColor := aCanvas.Brush.Color;

    //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;

    //-- scale
  dRY := (aRect.Bottom - aRect.Top) / (FSeriesCharter.MaxValue - FSeriesCharter.MinValue);
  //
    // get position
  P1.x := aRect.Left + (FSIndex - iStart)*iBarWidth + iBarWidth div 2;
  P2.x := aRect.Left + (FEIndex - iStart)*iBarWidth + iBarWidth div 2;
  P1.y := aRect.Bottom - Round((FSValue - FSeriesCharter.MinValue)*dRY);
  P2.y := aRect.Bottom - Round((FEValue - FSeriesCharter.MinValue)*dRY);

  FSPoint := P1;
  FEPoint := P2;

    // check position
  bSIn := (P1.x >= aRect.Left) and (P1.x <= aRect.Right) and
          (P1.y >= aRect.Top) and (P1.y <= aRect.Bottom);
  bEIn := (P2.x >= aRect.Left) and (P2.x <= aRect.Right) and
          (P2.y >= aRect.Top) and (P2.y <= aRect.Bottom);

    // out of boundary?
  if not bSIn and not bEIn then Exit;

    // if hung on boundary, get the point of intersection with boundary
  if bSIn and not bEIn then
    SetIntersection(P1, P2)
  else if not bSIn and bEIn then
    SetIntersection(P2, P1);

    //
  aCanvas.Pen.Color := FColor;
  aCanvas.MoveTo(P1.x, P1.y);
  aCanvas.LineTo(P2.x, P2.y);

  // selected
  if bSelected then
  begin
    aPenMode := aCanvas.Pen.Mode;
    aCanvas.Brush.Color := clWhite;
    aCanvas.Pen.Color := clWhite;
    aCanvas.Pen.Mode := pmXOR;
    aCanvas.Rectangle(
        Rect(P1.x-SEL_WIDTH, P1.y-SEL_WIDTH, P1.x+SEL_WIDTH, P1.y+SEL_WIDTH));
    aCanvas.Rectangle(
        Rect(P2.x-SEL_WIDTH, P2.y-SEL_WIDTH, P2.x+SEL_WIDTH, P2.y+SEL_WIDTH));
    aCanvas.Pen.Mode := aPenMode;
  end;

    // recover GDI info.
  aCanvas.Pen.Color := aPenColor;
  aCanvas.Brush.Color := aBrushColor;
end;

//==============================================================//
                              { THorizLine }
//==============================================================//

function THorizLine.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
const
  HIT_RANGE = 1;
var
  iY : Integer;
  dRY : Double;
begin
  Result := False;
  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;
  //-- scale
  dRY := (aRect.Bottom - aRect.Top) / (FSeriesCharter.MaxValue - FSeriesCharter.MinValue);
  //
  iY := aRect.Bottom - Round((FValue - FSeriesCharter.MinValue)*dRY);
  //
  if (iHitY >= iY-HIT_RANGE) and (iHitY <= iY+HIT_RANGE) then
    Result := True;
end;

procedure THorizLine.Draw(const aCanvas : TCanvas; const aRect : TRect;
               const iStart, iEnd, iBarWidth : Integer;
               const bSelected : Boolean);
const
  SEL_WIDTH = 3;
var
  aPenColor, aBrushColor, aFontColor : TColor;
  iFontSize : Integer;
  aPenMode : TPenMode;

  iX, iY : Integer;
  dRY : Double;

  stText : String;
  aSize : TSize;
begin
  aPenColor   := aCanvas.Pen.Color;
  aBrushColor := aCanvas.Brush.Color;
  //aFontColor  := aCanvas.Font.Color;

  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;

  //-- scale
  dRY := (aRect.Bottom - aRect.Top) / (FSeriesCharter.MaxValue - FSeriesCharter.MinValue);

  //
  with aCanvas do
  begin
    iY := aRect.Bottom - Round((FValue - FSeriesCharter.MinValue)*dRY);
    if (iY > aRect.Top) and (iY < aRect.Bottom) then
    begin
      Pen.Color := FColor;
      MoveTo(aRect.Left+1, iY);
      LineTo(aRect.Right, iY);
      // selected
      if bSelected then
      begin
        aPenMode := aCanvas.Pen.Mode;
        aCanvas.Brush.Color := clWhite;
        aCanvas.Pen.Color := clWhite;
        aCanvas.Pen.Mode := pmXOR;
        aCanvas.Rectangle(
            Rect(aRect.Left+1, iY-SEL_WIDTH, aRect.Left+1+2*SEL_WIDTH, iY+SEL_WIDTH));
        aCanvas.Rectangle(
            Rect(aRect.Right-2*SEL_WIDTH, iY-SEL_WIDTH, aRect.Right, iY+SEL_WIDTH));
        aCanvas.Pen.Mode := aPenMode;
      end;
      // put text

      Font.Color := FColor;
      stText := Format('%.2f', [FValue]);
      aSize := TextExtent(stText);
      iX := aRect.Right - aSize.cx -5;
      iY := iY - aSize.cy - 1;
      TextOut(iX, iY, stText);

    end;
  end;
  //
  aCanvas.Pen.Color := aPenColor;
  aCanvas.Brush.Color := aBrushColor;
  //aCanvas.Font.Color := aFontColor;
end;

//==============================================================//
                              { TVertLine }
//==============================================================//

function TVertLine.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
const
  HIT_RANGE = 1;
var
  iX : Integer;
begin
  Result := False;

  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;

  iX := aRect.Left + (FBarIndex - iStartIndex)*iBarWidth + iBarWidth div 2;
  Result := (iHitX >= iX - HIT_RANGE) and (iHitX <= iX+HIT_RANGE);
end;

procedure TVertLine.Draw(const aCanvas : TCanvas; const aRect : TRect;
               const iStart, iEnd, iBarWidth : Integer;
               const bSelected : Boolean);
const
  SEL_WIDTH = 3;
var
  aPenColor, aBrushColor, aFontColor : TColor;
  iFontSize : Integer;
  aPenMode : TPenMode;

  iX, iY : Integer;

  stText : String;
  aSize : TSize;
begin
  aPenColor   := aCanvas.Pen.Color;
  aBrushColor := aCanvas.Brush.Color;
  //aFontColor  := aCanvas.Font.Color;

  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;

  iX := aRect.Left + (FBarIndex - iStart) * iBarWidth + iBarWidth div 2;

  aCanvas.Pen.Color := FColor;
  aCanvas.MoveTo(iX, aRect.Bottom);
  aCanvas.LineTo(iX, aRect.Top);

  if bSelected then
  begin
    aPenMode := aCanvas.Pen.Mode;
    aCanvas.Brush.Color := clWhite;
    aCanvas.Pen.Color := clWhite;
    aCanvas.Pen.Mode := pmXOR;
    aCanvas.Rectangle(
        Rect(iX-SEL_WIDTH, aRect.Top+1, iX+SEL_WIDTH, aRect.Top+1+2*SEL_WIDTH));
    aCanvas.Rectangle(
        Rect(iX-SEL_WIDTH, aRect.Bottom-2*SEL_WIDTH, iX+SEL_WIDTH, aRect.Bottom));
    aCanvas.Pen.Mode := aPenMode;
  end;
  
    // put text
  {
  aCanvas.Font.Color := FColor;
  stText := FSeriesCharter.GetDateTimeDesc(FBarIndex);
  aSize := aCanvas.TextExtent(stText);
  iY := aRect.Bottom - aSize.cy - 1;
  aCanvas.TextOut(iX+1, iY, stText);
  }
    //
  aCanvas.Pen.Color := aPenColor;
  aCanvas.Brush.Color := aBrushColor;
  //aCanvas.Font.Color := aFontColor;
end;

{ TCustomHorizLine }

procedure TCustomHorizLine.Draw(const aCanvas: TCanvas; const aRect: TRect;
  const iStart, iEnd, iBarWidth: Integer; const bSelected: Boolean);
const
  SEL_WIDTH = 3;
var
  aPenColor, aBrushColor, aFontColor : TColor;
  iFontSize : Integer;
  aPenMode : TPenMode;

  iX, iY : Integer;
  dRY : Double;

  stText : String;
  aSize : TSize;
begin
  aPenColor   := aCanvas.Pen.Color;
  aBrushColor := aCanvas.Brush.Color;
  aFontColor  := aCanvas.Font.Color;

  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;

  //-- scale
  dRY := (aRect.Bottom - aRect.Top) / (FSeriesCharter.MaxValue - FSeriesCharter.MinValue);

  //
  with aCanvas do
  begin
    iY := aRect.Bottom - Round((FValue - FSeriesCharter.MinValue)*dRY);
    if (iY > aRect.Top) and (iY < aRect.Bottom) then
    begin
      Pen.Color := FLineColor;
      MoveTo(aRect.Left+1, iY);
      LineTo(aRect.Right, iY);
      // selected
      if bSelected then
      begin
        aPenMode := aCanvas.Pen.Mode;
        aCanvas.Brush.Color := clWhite;
        aCanvas.Pen.Color := clWhite;
        aCanvas.Pen.Mode := pmXOR;
        aCanvas.Rectangle(
            Rect(aRect.Left+1, iY-SEL_WIDTH, aRect.Left+1+2*SEL_WIDTH, iY+SEL_WIDTH));
        aCanvas.Rectangle(
            Rect(aRect.Right-2*SEL_WIDTH, iY-SEL_WIDTH, aRect.Right, iY+SEL_WIDTH));
        aCanvas.Pen.Mode := aPenMode;
      end;
      // put text

      Font.Color := FColor;
      stText := Format('%.2f', [FValue]);
      aSize := TextExtent(stText);
      iX := aRect.Right - aSize.cx -5;
      iY := iY - aSize.cy - 1;
      TextOut(iX, iY, stText);

    end;
  end;
  //
  aCanvas.Pen.Color := aPenColor;
  aCanvas.Brush.Color := aBrushColor;
  aCanvas.Font.Color := aFontColor;

end;

function TCustomHorizLine.Hit(const iHitX, iHitY: Integer; const aRect: TRect;
  const iStartIndex, iBarIndex, iBarWidth: Integer): Boolean;
const
  HIT_RANGE = 1;
var
  iY : Integer;
  dRY : Double;
begin
  Result := False;
  //-- check the data range
  if (Abs(FSeriesCharter.MaxValue - FSeriesCharter.MinValue) < ZERO) or
     (aRect.Top >= aRect.Bottom) then Exit;
  //-- scale
  dRY := (aRect.Bottom - aRect.Top) / (FSeriesCharter.MaxValue - FSeriesCharter.MinValue);
  //
  iY := aRect.Bottom - Round((FValue - FSeriesCharter.MinValue)*dRY);
  //
  if (iHitY >= iY-HIT_RANGE) and (iHitY <= iY+HIT_RANGE) then
    Result := True;

end;

end.
