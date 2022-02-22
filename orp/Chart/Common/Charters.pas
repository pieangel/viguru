unit Charters;

//
// Chart base
//
//
//

interface

uses Windows, Graphics, Classes, SysUtils, Forms, Math,
     //
     GleTypes, XTerms;

const
  ZERO = 1e-8;

type
  { charter base }

  TCharterPosition = (cpMainGraph, cpSubGraph);
  TYRateType  = (yrDefault, yrSame );

  TCharter = class
  private
    FCrosChart: boolean;
    FCrosChartColor: TColor;
  protected
    FTitle : String;
    FPosition : TCharterPosition;
    //
    FOnDelete : TNotifyEvent;
    FOnMove : TNotifyEvent;

    FOnAsyncUpdate : TNotifyEvent;
    FOnAsyncRefresh : TNotifyEvent;
    FOnAsyncAdd : TNotifyEvent;

    // factors saved (last used factors)
    //FDrawRect : TRect; // drawing area
    //FStartIndex, FEndIndex : Integer; // drawing range
    //FBarWidth : Integer;
    //
    function GetTitle : String; virtual;
  published
  public
    function Config(aForm : TForm) : Boolean; virtual;
    function SpotData(iBarIndex : Integer) : String; virtual;
    procedure HintData(iBarIndex : Integer; stHints : TStringList); virtual;
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; virtual;
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean ); virtual;
    procedure Draw2(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean ); virtual;
    procedure DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                        var iLeft : Integer; bSelected : Boolean); virtual;
    //
    property Title : String read GetTitle write FTitle;
    property Position : TCharterPosition read FPosition write FPosition;
    property CrosChart: boolean read FCrosChart write FCrosChart;
    property CrosChartColor : TColor read FCrosChartColor write FCrosChartColor;

    property OnDelete : TNotifyEvent read FOnDelete write FOnDelete;
    property OnMove : TNotifyEvent read FOnMove write FOnMove;
    property OnAsyncUpdate : TNotifyEvent read FOnAsyncUpdate write FOnAsyncUpdate;
    property OnAsyncRefresh : TNotifyEvent read FOnAsyncRefresh write FOnAsyncRefresh;
    property OnAsyncAdd : TNotifyEvent read FOnAsyncAdd write FOnAsyncAdd;
  end;

  { series charter }

  TScaleType = (stScreen, stEntire, stSymbol);

  TSeriesCharter = class(TCharter)
  protected
    FScaleType : TScaleType;
    FMax, FMin : Double;
    FMax2, FMin2 : Double;
    FPrecision : Integer;

    procedure RegulateYScale(var dStep : Double); virtual;
  public
    constructor Create;

    function GetDataCount : Integer; virtual;
    function GetDateTimeDesc(iBarIndex : Integer) : String; virtual;
    procedure SetMinMax(dMin, dMax : Double); virtual;
    procedure GetMinMax(iStart, iEnd : Integer); virtual;
    procedure GetMinMax2(iStart, iEnd : Integer); virtual;

    // 교차차트를 그리기 위한 확장 메서드
    procedure GetMinMaxEx(iStart, iEnd : Integer; var dMin, dMax : Double); virtual;
    procedure GetMinMaxEx2(iStart, iEnd : Integer; var dMin, dMax : Double); virtual;
    //

    procedure DrawYScale(const aCanvas : TCanvas; const aRect : TRect;
                         const bLeft, bRight, bLine : Boolean;
                         const aColor : TColor); virtual;
    procedure DrawXScale(const aCanvas : TCanvas; const aRect : TRect;
                           const iStart, iEnd, iBarWidth : Integer;
                           const bLine : Boolean; const aLineColor : TColor); virtual;
    //
    property MinValue : Double read FMin;
    property MaxValue : Double read FMax;

    property MinValue2 : Double read FMin2;
    property MaxValue2 : Double read FMax2;

    property ScaleType : TScaleType read FScaleType write FScaleType;
    property Precision : Integer read FPrecision write FPrecision;
  end;

const
  TITLE_WIDTH = 20;

implementation

//==================================================================//
                         { TCharter }
//==================================================================//

function TCharter.Config(aForm : TForm) : Boolean;
begin
  Result := False;
  // should be override by child
end;

function TCharter.SpotData(iBarIndex : Integer) : String;
begin
  Result := '';
  // should be override by child
end;

procedure TCharter.HintData(iBarIndex : Integer; stHints : TStringList);
begin
  // should be override by child
end;

function TCharter.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
begin
  Result := False;
  // should be override by child
end;

procedure TCharter.Draw(const aCanvas : TCanvas; const aRect : TRect;
                        const iStart, iEnd, iBarWidth : Integer;
                        const bSelected : Boolean);
begin
  // should be overrided by child of this class
end;

procedure TCharter.Draw2(const aCanvas: TCanvas; const aRect: TRect;
  const iStart, iEnd, iBarWidth: Integer; const bSelected: Boolean);
begin

end;

procedure TCharter.DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                             var iLeft : Integer; bSelected : Boolean);
begin
  // should be overrided by child of this class
end;

function TCharter.GetTitle : String;
begin
  Result := FTitle;
end;

//==================================================================//
                         { TSeriesCharter }
//==================================================================//

constructor TSeriesCharter.Create;
begin
  FPrecision := 2;
end;

procedure TSeriesCharter.SetMinMax(dMin, dMax : Double);
begin
  FMin := dMin;
  FMax := dMax;
end;

procedure TSeriesCharter.GetMinMax(iStart, iEnd : Integer);
begin
  // should be overrided by child
end;

procedure TSeriesCharter.GetMinMax2(iStart, iEnd: Integer);
begin

end;

procedure TSeriesCharter.GetMinMaxEx(iStart, iEnd: Integer; var dMin,
  dMax: Double);
begin

end;

procedure TSeriesCharter.GetMinMaxEx2(iStart, iEnd: Integer; var dMin,
  dMax: Double);
begin

end;

function TSeriesCharter.GetDateTimeDesc(iBarIndex : Integer) : String;
begin
  // should be overrided by child
end;

function TSeriesCharter.GetDataCount : Integer;
begin
  // should be overrided by child
end;

procedure TSeriesCharter.RegulateYScale(var dStep : Double);
begin
  // should be overrided by child optionally
end;

procedure TSeriesCharter.DrawXScale(const aCanvas : TCanvas; const aRect : TRect;
                           const iStart, iEnd, iBarWidth : Integer;
                           const bLine : Boolean; const aLineColor : TColor);
begin
  // should be overrided by child
end;

procedure TSeriesCharter.DrawYScale(const aCanvas : TCanvas; const aRect : TRect;
                               const bLeft, bRight, bLine : Boolean;
                               const aColor : TColor);
var
  i, iY, iTxtUpper, iTxtBelow : Integer;
  dRY, dScale : Double;
  aAxisColor : TColor;
  aStyle : TPenStyle;

  aSize : TSize;
  iTextHeight, iOrder, iNormal, iStep, iInStep, iPrecision : Integer;
  dCount, dStep, dInStep, dDiv : Double;
  iMultiple : Integer;

  procedure PutHair(dValue : Double);
  begin
    if bLeft then
    begin
      aCanvas.MoveTo(aRect.Left, iY);
      aCanvas.LineTo(aRect.Left-2, iY);
    end;
    if bRight then
    begin
      aCanvas.MoveTo(aRect.Right, iY);
      aCanvas.LineTo(aRect.Right+3, iY);
    end;
  end;

  procedure PutScale(dValue : Double);
  var
    aSize : TSize;
    stScale : String;
  begin
    stScale := Format('%.*n', [iPrecision, dValue]);
    aSize := aCanvas.TextExtent(stScale);
    iTxtUpper := iY - aSize.cy div 2;
    iTxtBelow := iY + aSize.cy div 2;
    //
    if bLeft then
    begin
      aCanvas.MoveTo(aRect.Left, iY);
      aCanvas.LineTo(aRect.Left-4, iY);

      if (iTxtUpper > aRect.Top - TITLE_WIDTH) and (iTxtBelow < aRect.Bottom) then
        aCanvas.TextOut(aRect.Left - aSize.cx - 5, iTxtUpper, stScale);
    end;

    if bRight then
    begin
      aCanvas.MoveTo(aRect.Right, iY);
      aCanvas.LineTo(aRect.Right+5, iY);

      if (iTxtUpper > aRect.Top - TITLE_WIDTH) and (iTxtBelow < aRect.Bottom) then
        aCanvas.TextOut(aRect.Right + 5, iTxtUpper, stScale);
    end;

    if bLine then
    begin
      aCanvas.Pen.Style := psDot;
      aCanvas.Pen.Color := aColor;
      aCanvas.Pen.Width := 1;
      //
      aCanvas.MoveTo(aRect.Left, iY);
      aCanvas.LineTo(aRect.Right, iY);
      //
      aCanvas.Pen.Style := psSolid;
      aCanvas.Pen.Color := aAxisColor;
    end;
  end;
begin
  //--0. check
    if aCanvas = nil then Exit;
    if (Abs(FMax - FMin) < 0.00001) or (FMax < FMin) then Exit;

  //--1. get text height
    aSize := aCanvas.TextExtent('9');
    iTextHeight := aSize.cy;
    if iTextHeight <= 0 then Exit;

  //--2. how many scales?
    dCount := (aRect.Bottom - aRect.Top + 1) / iTextHeight / 2.5;
    if dCount < 1.0 then Exit;
    dStep := (FMax - FMin) / dCount;

  //--4. Check Min. Y Unit
    RegulateYScale(dStep);

  //--3. Regulate scale
    iOrder := Floor(Log10(dStep));
    dDiv := Power(10, iOrder-2);
    iNormal := Round(dStep / dDiv);

    if iOrder >= 0 then
      iPrecision := 0
    else
      iPrecision := Abs(iOrder);

    if iNormal < 150 then
    begin
      iStep := 100; iInStep := 50;
    end else
    if iNormal < 225 then
    begin
      iStep := 200; iInStep := 100;
    end else
    if iNormal < 375 then
    begin
      iStep := 250; iInStep := 250;
      if iOrder <= 0 then Inc(iPrecision);
    end else
    if iNormal < 750 then
    begin
      iStep := 500; iInStep := 100;
    end else
    begin
      iStep := 1000; iInStep := 500;
    end;
    dStep := iStep * dDiv;
    dInStep := iInStep * dDiv;

  //--5. save GDI
    aAxisColor := aCanvas.Pen.Color;
    aStyle := aCanvas.Pen.Style;
  //
  //--6. Draw scales
    dRY := (aRect.Bottom - aRect.Top) / (FMax - FMin);
    if (0 > FMin) and (0 < FMax) then
    begin
      iY := aRect.Bottom - Round((0-FMin)*dRY);
      //
      PutScale(0);
    end;
    //-- up scale
    if FMax > 0 then
    begin
      //-- removed (sms)
      //dScale := dInStep;

      //-- newly inserted part
      if FMin > 0 then
      begin
        iMultiple := Floor(FMin / dInStep);
        dScale := dInStep * iMultiple;
      end else
        dScale := dInStep;
      //--

      while dScale < FMax do
      begin
        iY := aRect.Bottom - Round((dScale-FMin)*dRY);
        if dScale > FMin then PutHair(dScale);
        dScale := dScale + dInStep;
      end;

      //-- removed (sms)
      //dScale := dStep;

      //-- newly inserted part
      if FMin > 0 then
      begin
        iMultiple := Floor(FMin / dStep);
        dScale := dStep * iMultiple;
      end else
        dScale := dStep;
      //--

      while dScale < FMax do
      begin
        iY := aRect.Bottom - Round((dScale-FMin)*dRY);
        if dScale > FMin then PutScale(dScale);
        dScale := dScale + dStep;
      end;
    end;
    //-- down scale
    if FMin < 0 then
    begin
      //-- removed (sms)
      //dScale := dInStep;

      //-- newly inserted part
      if FMax < 0 then
      begin
        iMultiple := Ceil(FMax / dInStep); //FMax(-), dInStep(+), multiple(-)
        dScale := dInStep * iMultiple;
      end else
        dScale := -dInStep;

      while dScale > FMin do
      begin
        iY := aRect.Bottom - Round((dScale-FMin)*dRY);
        if dScale < FMax then PutHair(dScale);
        dScale := dScale - dInStep;
      end;

      //-- removed (sms)
      //dScale := dStep;

      //-- newly inserted part
      if FMax < 0 then
      begin
        iMultiple := Ceil(FMax / dStep);
        dScale := dStep * iMultiple;
      end else
        dScale := - dStep;

      while dScale > FMin do
      begin
        iY := aRect.Bottom - Round((dScale-FMin)*dRY);
        if dScale < FMax then PutScale(dScale);
        dScale := dScale - dStep;
      end;
    end;
  //--7. Restore GDI values
    aCanvas.Pen.Style := aStyle;
    aCanvas.Pen.Color := aAxisColor;
end;

{
procedure TSeriesCharter.DrawYScale(const aCanvas : TCanvas; const aRect : TRect;
                                    const bLeft, bRight, bLine : Boolean;
                                    const aColor : TColor);
const
  MULTIPLES : array[0..2] of Double = (2, 2.5, 2);
var
  i, iCount, iY, iTxtUpper, iTxtBelow : Integer;
  dDist, dStep, dRY, dScale : Double;
  aAxisColor : TColor;
  aStyle : TPenStyle;

  procedure PutScale(dValue : Double);
  var
    aSize : TSize;
    stScale : String;
  begin
    stScale := Format('%.*n', [FPrecision, dValue]);
    aSize := aCanvas.TextExtent(stScale);
    iTxtUpper := iY - aSize.cy div 2;
    iTxtBelow := iY + aSize.cy div 2;
    //
    if bLeft then
    begin
      aCanvas.MoveTo(aRect.Left, iY);
      aCanvas.LineTo(aRect.Left-4, iY);
      //
      if (iTxtUpper > aRect.Top - TITLE_WIDTH) and (iTxtBelow < aRect.Bottom) then
        aCanvas.TextOut(aRect.Left - aSize.cx - 5, iTxtUpper, stScale);
    end;
    if bRight then
    begin
      aCanvas.MoveTo(aRect.Right, iY);
      aCanvas.LineTo(aRect.Right+5, iY);
      //
      if (iTxtUpper > aRect.Top - TITLE_WIDTH) and (iTxtBelow < aRect.Bottom) then
        aCanvas.TextOut(aRect.Right + 5, iTxtUpper, stScale);
    end;
    if bLine then
    begin
      aCanvas.Pen.Style := psDot;
      aCanvas.Pen.Color := aColor;
      //
      aCanvas.MoveTo(aRect.Left, iY);
      aCanvas.LineTo(aRect.Right, iY);
      //
      aCanvas.Pen.Style := psSolid;
      aCanvas.Pen.Color := aAxisColor;
    end;
  end;
begin
  if (Abs(FMax - FMin) < 0.00001) or (FMax < FMin) then Exit;
  //-- how many scales?
  iCount := (aRect.Bottom - aRect.Top + 1) div 20;
  if iCount = 0 then Exit;
  //--
  dDist := (FMax - FMin) / iCount;
  //-- calc step
  dStep := 0.00001;
  i := 0;
  while dStep < dDist do
  begin
    dStep := dStep * MULTIPLES[i mod 3];
    Inc(i);
  end;
  //-- save GDI
  aAxisColor := aCanvas.Pen.Color;
  aStyle := aCanvas.Pen.Style;
  //
  //-- 0 line
  dRY := (aRect.Bottom - aRect.Top) / (FMax - FMin);
  if (0 > FMin) and (0 < FMax) then
  begin
    iY := aRect.Bottom - Round((0-FMin)*dRY);
    //
    PutScale(0);
  end;
  //-- up scale
  dScale := dStep;
  if FMax > 0 then
    while dScale < FMax do
    begin
      iY := aRect.Bottom - Round((dScale-FMin)*dRY);
      if dScale > FMin then PutScale(dScale);
      dScale := dScale + dStep;
    end;
  //-- down scale
  dScale := dStep;
  if FMin < 0 then
    while dScale > FMin do
    begin
      iY := aRect.Bottom - Round((dScale-FMin)*dRY);
      if dScale < FMax then PutScale(dScale);
      dScale := dScale - dStep;
    end;
  //
  aCanvas.Pen.Style := aStyle;
  aCanvas.Pen.Color := aAxisColor;
end;
}

end.
