unit SpreadCharter;

interface
uses Classes, Windows, Graphics, Math, SysUtils, Forms, Controls,
     //
     GleTypes,
     CleOrders, CleSymbols,
     GleConsts,
     Charters, ChartIF,
     SpreadData;

type
  TSpreadCharter = class;
  TSpreadCharterClass = class of TSpreadCharter;

  TSpreadCharter = class(TSeriesCharter)
  protected
    FSeries : TSpreadSeries;
    
    // drawing factors
    FChartColor : TColor;
    FLineWidth : Integer;

    function GetTitle : String; override;
  public
    constructor Create;
    destructor Destroy; override;

      // config
    function Config(aForm : TForm) : Boolean; override;
      // get status
    function GetDataCount : Integer; override;
    procedure GetMinMax(iStart, iEnd : Integer); override;
      // check position
    function GetDateTimeDesc(iBarIndex : Integer) : String; override;
    function SpotData(iBarIndex : Integer) : String; override;
    procedure HintData(iBarIndex : Integer; stHints : TStringList); override;
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;
      // drawing routines
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean); override;
    procedure DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                        var iLeft : Integer; bSelected : Boolean); override;
    procedure DrawXScale(const aCanvas : TCanvas; const aRect : TRect;
                         const iStart, iEnd, iBarWidth : Integer;
                         const bLine : Boolean; const aLineColor : TColor); override;
      // attributes
    property ChartColor : TColor read FChartColor write FChartColor;
    property LineWidth : Integer read FLineWidth write FLineWidth;

    property Series : TSpreadSeries read FSeries write FSeries;
  end;


implementation

{ TSpreadCharter }

constructor TSpreadCharter.Create;
begin
  FPosition := cpMainGraph;
  FScaleType := stScreen;
  FChartColor := clBlue;
  FPrecision := 2;
  FLineWidth := 1;
end;

destructor TSpreadCharter.Destroy;
begin
  inherited;
end;

//=======================< Config >===============================//

function TSpreadCharter.Config(aForm : TForm) : Boolean;
begin
  // none
end;

//=======================< Get Status >==============================//

function TSpreadCharter.GetTitle : String;
begin
  if FSeries <> nil then
    Result := FSeries.Title
  else
    Result := '';
end;

function TSpreadCharter.GetDataCount : Integer; 
begin
  if FSeries <> nil then
    Result := FSeries.Length
  else
    Result := 0;
end;



procedure TSpreadCharter.GetMinMax(iStart, iEnd : Integer);
var
  dMin, dMax, dMargin : Double;
begin
  if FSeries = nil then Exit;
  
  //-- get min/max
  if FScaleType = stScreen then
    FSeries.GetMinMax(iStart, iEnd, dMin, dMax)
  else
  if FScaleType = stEntire then
    FSeries.GetMinMax(0, FSeries.Length-1, dMin, dMax)
  else
    Exit;
  //--
  dMargin := (dMax - dMin) * 0.05;
  if Abs(dMargin) > EPSILON then
  begin
    dMax := dMax + dMargin;
    dMin := dMin - dMargin;
  end;
  //-- save
  FMin := dMin;
  FMax := dMax;
end;


//========================< Drawing Routines >========================//

procedure TSpreadCharter.DrawXScale(const aCanvas : TCanvas; const aRect : TRect;
                           const iStart, iEnd, iBarWidth : Integer;
                           const bLine : Boolean; const aLineColor : TColor);
var
  i, iLeft, iX, iY, iStep, iBase, iWidth : Integer;
  aSize : TSize;
  stText : String;
  aItem : TSpreadSeriesItem;
  aStyle : TPenStyle;
  aAxisColor : TCOlor;
  wYY, wMM, wDD, wHH, wNN, wSS, wCC,
  wYYOld, wMMOld, wDDOld, wHHOld : Word;
  cbValue : TChartBase;
  bSeparator, bExpireLine : Boolean;
begin
  if FSeries = nil then Exit;
  if (iStart > iEnd) or
     (iStart < 0) or (iStart > FSeries.Length-1) or
     (iEnd < 0) or (iEnd > FSeries.Length-1) then Exit;

  //
  aStyle := aCanvas.Pen.Style;
  aAxisColor := aCanvas.Pen.Color;
  //
  iY := aRect.Bottom+5;
  iStep := 50 div iBarWidth;
  //
  iLeft := aRect.Left;
  iWidth := 0;
  iBase := iStart;
  wMMOld := 0;
  wDDOld := 0;
  //
  cbValue := FSeries.ChartBase;
  //
  for i:=iStart to iEnd do
  begin
    //-- Date Seperator and expire line?

    DecodeDate(FSeries[i].LastTime, wYY, wMM, wDD);
    DecodeTime(FSeries[i].LastTime, wHH, wNN, wSS, wCC);

    bExpireLine := False;
    case cbValue of
      cbTick : bSeparator := (wHH <> wHHOld);
      cbMin : bSeparator := (wYY <> wYYOld) or (wMM <> wMMOld) or (wDD <> wDDOld);
      cbDaily :
          begin
            bSeparator := (wYY <> wYYOld) or (wMM <> wMMOld);
            bExpireLine := false;//gPrice.ExpireDates.IsRightOn(FSeries[i].LastTime);
          end;
      cbWeekly,
      cbMonthly : bSeparator := (wYY <> wYYOld);
    end;

    //-- draw hour/date/year separator
    if bSeparator then
    begin
      // Date Separator
      aCanvas.Pen.Style := psDot;
      aCanvas.Pen.Color := aAxisColor;
      //
      case cbValue of
        cbTick :    stText := IntToStr(wHH)+ 'i';
        cbMin :     stText := IntToStr(wMM) + '/' + IntToStr(wDD);
        cbDaily :   stText := IntToStr(wYY) + '/' + IntToStr(wMM);
        cbWeekly,
        cbMonthly : stText := IntToStr(wYY);
      end;
      
      aSize := aCanvas.TextExtent(stText);
      //
      iX := aRect.Left + (i-iStart) * iBarWidth;
      //-- delete a scale preceded
      if (iLeft + iWidth) >= iX then
        aCanvas.FillRect(Rect(iLeft, iY, iLeft+iWidth, iY + aSize.cy));
      //-- date line
      if wDDOld <> 0 then
      begin
        aCanvas.MoveTo(iX, aRect.Top);
        aCanvas.LineTo(iX, aRect.Bottom);
        iBase := i;
      end;
      //-- put date text
      aCanvas.TextOut(iX, iY, stText);
      iLeft := iX;
      iWidth := aSize.cx;
      //
      wYYOld := wYY;
      wMMOld := wMM;
      wDDOld := wDD;
      wHHOld := wHH;
    end;
    //-- draw expire date line
    if bExpireLine then
    begin
      aCanvas.Pen.Style := psDot;
      aCanvas.Pen.Color := clRed;
      //
      iX := aRect.Left + (i-iStart) * iBarWidth;
      //
      aCanvas.MoveTo(iX, aRect.Top);
      aCanvas.LineTo(iX, aRect.Bottom);
    end;
    //
    if (i <> iBase) and ((i-iBase) mod iStep = 0) then
    begin
      iX := aRect.Left + (i-iStart)*iBarWidth;
      //
      case cbValue of
        cbTick :    stText := FormatDateTime('nn:ss', FSeries[i].LastTime);
        cbMin :     stText := FormatDateTime('hh:nn', FSeries[i].LastTime);
        cbDaily :   stText := IntToStr(wDD);
        cbWeekly :  stText := IntToStr(wMM)+'/'+IntToStr(wDD);
        cbMonthly : stText := IntToStr(wMM);
      end;

      aSize := aCanvas.TextExtent(stText);
      //
      aCanvas.Pen.Style := psSolid;
      aCanvas.Pen.Color := aAxisColor;
      //
      aCanvas.MoveTo(iX, aRect.Bottom);
      aCanvas.LineTo(iX, iY);
      //
      if bLine then
      begin
        aCanvas.Pen.Style := psDot;
        aCanvas.Pen.Color := aLineColor;
        //
        aCanvas.MoveTo(iX, aRect.Top);
        aCanvas.LineTo(iX, aRect.Bottom);
      end;
      //
      aCanvas.TextOut(iX, iY, stText);
      //
      iLeft := iX;
      iWidth := aSize.cx;
    end;
  end;
  //
  aCanvas.Pen.Style := aStyle;
  aCanvas.Pen.Color := aAxisColor;
end;

procedure TSpreadCharter.DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                                   var iLeft : Integer; bSelected : Boolean);
var
  stTitle : String;
  aSize : TSize;
  aFontColor : TColor;
  aFontStyle : TFontStyles;
begin
  if FSeries = nil then Exit;

  //
  aFontColor := aCanvas.Font.Color;
  aFontStyle := aCanvas.Font.Style;
  //
  if FSeries.Length > 0 then
    stTitle := GetTitle +
      Format('=%.*f%s%s', [FPrecision,
        FSeries[FSeries.Length-1].Value, FSeries.UnitTitle, FSeries.Remark])
  else
    stTitle := GetTitle + '=NA';
  //
  aCanvas.Font.Color := FChartColor;
  if bSelected then
    aCanvas.Font.Style := aCanvas.Font.Style + [fsBold];
  aSize := aCanvas.TextExtent(stTitle);
  aCanvas.TextOut(iLeft+5, aRect.Top - aSize.cy, stTitle);
  //
  iLeft := iLeft + 5 + aSize.cx;
  //
  aCanvas.Font.Color := aFontColor;
  aCanvas.Font.Style := aFontStyle;
end;

procedure TSpreadCharter.Draw(const aCanvas : TCanvas; const aRect : TRect;
          const iStart, iEnd, iBarWidth : Integer; const bSelected : Boolean);
const
  SEL_WIDTH = 3;
var
  dRY : Double;
  iStep, iCnt, // for drawing selected
  i, iX, iY : Integer;
  iDrawCount : Integer;

  iWidth : Integer;
  aBrushColor, aFontColor, aPenColor : TColor;
  aPenMode : TPenMode;
begin
  if FSeries = nil then Exit;
  // unacceptable condition
  if (iStart > iEnd) or
     (iStart < 0) or (iStart > FSeries.Length-1) or
     (iEnd < 0) or (iEnd > FSeries.Length-1) then Exit;
  //-- Ratio
  if Abs(FMax-FMin) < ZERO then Exit;
  //
  dRY := (aRect.Bottom - aRect.Top)/(FMax - FMin);
  //--
  iStep := 50 div iBarWidth;
  iCnt := 0;
  iDrawCount := 0;
  //--
  aBrushColor := aCanvas.Brush.Color;
  aFontColor := aCanvas.Font.Color;
  aPenColor := aCanvas.Pen.Color;

  //-- data
  for i:=iStart to iEnd do
  with FSeries[i] do
  begin
    Inc(iCnt);
    if not Defined then Continue;
    
    aCanvas.Pen.Color := FChartColor;
    iWidth := aCanvas.Pen.Width;
    aCanvas.Pen.Width := FLineWidth;
    
    iX := (i-iStart)*iBarWidth + aRect.Left+1;
    iY := aRect.Bottom - Round((Value - FMin)*dRY);
    if iDrawCount > 0 then
      aCanvas.LineTo(iX, iY)
    else
      aCanvas.MoveTo(iX, iY);

    aCanvas.Pen.Width := iWidth;
    
    Inc(iDrawCount);
    // selected
    if bSelected then
    begin
      if iCnt mod iStep = 0 then
      begin
        aPenMode := aCanvas.Pen.Mode;
        aCanvas.Brush.Color := clWhite;
        aCanvas.Pen.Mode := pmXOR;
        aCanvas.Pen.Color := clWhite;
        aCanvas.Rectangle(
            Rect(iX-SEL_WIDTH, iY-SEL_WIDTH, iX+SEL_WIDTH, iY+SEL_WIDTH));
        aCanvas.Pen.Mode := aPenMode;
      end;
    end;
  end;
  //--
  aCanvas.Brush.Color := aBrushColor;
  aCanvas.Font.Color := aFontColor;
  aCanvas.Pen.Color := aPenColor;
end;

//=====================< Check Position >=============================//

// (public)
// Get the date/time description at a point
//
function TSpreadCharter.GetDateTimeDesc(iBarIndex : Integer) : String;
begin
  if FSeries <> nil then
    Result := FSeries.DateTimeDesc(iBarIndex)
  else
    Result := '';
end;

// (public)
// Get the description at a point
//
function TSpreadCharter.SpotData(iBarIndex : Integer) : String;
begin
  if FSeries = nil then
    Result := ''
  else
  if (iBarIndex >=0) and (iBarIndex <= FSeries.Length-1) then
    Result := Format('%s:%.2f%s',
                     [GetTitle, FSeries[iBarIndex].Value, FSeries.UnitTitle]);
end;

// (public)
// Get the hint description at a point
//
procedure TSpreadCharter.HintData(iBarIndex : Integer; stHints : TStringList);
begin
  if (FSeries <> nil)
     and (iBarIndex >=0) and (iBarIndex <= FSeries.Length-1)
     and (stHints <> nil) then
    stHints.Add(Format('%s=%.2f%s',
                     [GetTitle, FSeries[iBarIndex].Value, FSeries.UnitTitle]));
end;


// (public)
// Check if this charter selected
//
function TSpreadCharter.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
  const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
const
  HIT_RANGE = 2;
var
  iX, iY, iYC, iX2, iYC2 : Integer;
  dRY : Double;
begin
  Result := False;
  //
  if FSeries = nil then Exit;
  if (iBarIndex < 0) or (iBarIndex > FSeries.Length-1) then Exit;
  if Abs(FMax-FMin) < ZERO then Exit;
  //-- Ratio
  dRY := (aRect.Bottom - aRect.Top)/(FMax - FMin);
  //--
  iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
  iYC := aRect.Bottom - Round((FSeries[iBarIndex].Value - FMin)*dRY);

  if iBarIndex < FSeries.Length-1 then
  begin
    iX2 := (iBarIndex + 1 - iStartIndex) * iBarWidth + aRect.Left + 1;
    iYC2 := aRect.Bottom - Round((FSeries[iBarIndex+1].Value - FMin)*dRY);
  end else
  begin
    iX2 := iX;
    iYC2 := iYC;
  end;
  //
  if (iHitX >= iX) and (iHitX <= iX2) then
  begin
    if iX <> iX2 then
      iY := Round(iYC + (iHitX-iX)*(iYC2-iYC)/(iX2-iX))
    else
      iY := iYC;
    //
    if (iHitY <= iY + HIT_RANGE) and (iHitY >= iY - HIT_RANGE) then
      Result := True;
  end;
end;

end.
