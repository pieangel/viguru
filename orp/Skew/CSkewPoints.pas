unit CSkewPoints;

interface

uses
  Classes, Math,

  CSkewConsts;

const
  MAX_POINTS = 100;
  MAX_HISTORIES = 100000;
  DEF_BAND_WIDTH = 0.02;

type
  TKernelType = (ktTriangular, ktEpanechnikov, ktBiweight, ktTriweight, ktMunaf,
                 ktGaussian, ktCosinus);

  TSkewValue = class
  private
    FDenominator: Double;
    FNumerator: Double;
      //
    FIV: Double;
      //
    FTrnCount: Integer;
    FTrnMin: Double;
    FTrnMax: Double;
    FTrnAvg: Double;
  public
    constructor Create;

    procedure Copy(Source: TSkewValue);
    procedure CalcIV(dIVRef, w: Double; bTrain: Boolean);

    property IV: Double read FIV;
    property TrnMin: Double read FTrnMin;
    property TrnMax: Double read FTrnMax;
    property TrnAvg: Double read FTrnAvg;
  end;

  TSkewPoint = class(TCollectionItem)
  private
    FX: Double;
      //
    procedure Copy(Source: TSkewPoint);
  public
    Values: array[0..1, 0..2] of TSkewValue;

    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    property X: Double read FX;
  end;

  TSkewPoints = class(TCollection)
  private
    FKernelType: TKernelType;
    FBandWidth: Double;

    FMinX: Double;
    FMaxX: Double;
    FMaxY: Double;

    function GetValue(dX: Double; iCallPut, iBidAsk: Integer): Double;
    function GetPoint(i: Integer): TSkewPoint;
  public
    constructor Create;

    procedure Generate(dPrice1, dPrice2: Double; iIntervals: Integer);
    procedure CalcIVs(dX, dIVRef: Double; iCallPut, iBidAsk: Integer;
      bTrain: Boolean = False);

    property Values[dX:Double;iCallPut, iBidAsk:Integer]: Double read GetValue; 
    property Points[i:Integer]: TSkewPoint read GetPoint; default;

    property MinX: Double read FMinX;
    property MaxX: Double read FMaxX;
    property MaxY: Double read FMaxY;
    
    property KernelType: TKernelType read FKernelType write FKernelType;
    property BandWidth: Double read FBandWidth write FBandWidth;
  end;

  TSkewHistories = class
  private
    FSkewPoints: TSkewPoints;
    FTable: array[0..MAX_POINTS-1, 0..MAX_HISTORIES-1] of TSkewPoint;
    FPoints: Integer;
    FHistories: Integer;
    procedure Copy(Source: TSkewPoints);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

implementation

{ TSkewValue }

constructor TSkewValue.Create;
begin
  FDenominator := 0.0;
  FNumerator := 0.0;
  FIV := 0.0;
  FTrnMin := 0.0;
  FTrnMax := 0.0;
  FTrnAvg := 0.0;
end;

procedure TSkewValue.Copy(Source: TSkewValue);
begin
  if Source = nil then Exit;

  FDenominator := Source.FDenominator;
  FNumerator := Source.FNumerator;
  FIV := Source.FIV;
  FTrnMin := Source.FTrnMin;
  FTrnMax := Source.FTrnMax;
  FTrnAvg := Source.FTrnAvg;
end;

procedure TSkewValue.CalcIV(dIVRef, w: Double; bTrain: Boolean);
begin
  FNumerator := 0.99 * FNumerator + 0.01 * Min(dIVRef, MAX_IV) * w;
  FDenominator := 0.99 * FDenominator + 0.01 * w;
  FIV := FNumerator / FDenominator;

  if bTrain then
  begin
    if FTrnCount = 0 then
    begin
      FTrnMin := FIV;
      FTrnMax := FIV;
      FTrnAvg := FIV;
    end else
    begin
      FTrnMin := Math.Min(FTrnMin, FIV);
      FTrnMax := Math.Max(FTrnMax, FIV);
      FTrnAvg := 0.99 * FTrnAvg + 0.01 * FIV;
    end;

    Inc(FTrnCount);
  end;
end;

{ TSkewPoint }

constructor TSkewPoint.Create(aColl: TCollection);
var
  i, j: Integer;
begin
  inherited Create(aColl);

  for i := 0 to 1 do
    for j := 0 to 2 do
      Values[i,j] := TSkewValue.Create;
end;

destructor TSkewPoint.Destroy;
var
  i, j: Integer;
begin
  for i := 0 to 1 do
    for j := 0 to 2 do
      Values[i,j].Free;

  inherited;
end;

procedure TSkewPoint.Copy(Source: TSkewPoint);
var
  i, j: Integer;
begin
  if Source = nil then Exit;

  FX := Source.FX;

  for i := 0 to 1 do
    for j := 0 to 2 do
      Values[i,j].Copy(Source.Values[i,j]);
end;

{ TSkewPoints }

constructor TSkewPoints.Create;
begin
  inherited Create(TSkewPoint);

  FBandWidth := DEF_BAND_WIDTH;
  FKernelType := ktEpanechnikov;

end;

function TSkewPoints.GetPoint(i: Integer): TSkewPoint;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSkewPoint
  else
    Result := nil;
end;

procedure TSkewPoints.Generate(dPrice1, dPrice2: Double; iIntervals: Integer);
var
  i, iPoints: Integer;
  dBase, dStep: Double;
begin
    // clear calculation points
  Clear;

    // reset range
  FMinX := 0.8;
  FMaxX := 1.2;
  FMaxY := 0.01;

    // check
  if (iIntervals < 1) or (Abs(dPrice2-dPrice1) < 1.0e-10)  then Exit;

    // get number of calc. points
  iPoints := Min(MAX_POINTS, iIntervals + 1);

    // get base and step
  FMinX := Min(dPrice1, dPrice2);
  FMaxX := Max(dPrice1, dPrice2);

  dBase := FMinX;

  dStep := Abs(dPrice2 - dPrice1) / iPoints;

    // generate calc. points
  for i := 0 to iPoints - 1 do
  begin
    with Add as TSkewPoint do
    begin
      FX := dBase + i* dStep;
    end;
  end;
end;

procedure TSkewPoints.CalcIVs(dX, dIVRef: Double; iCallPut, iBidAsk: Integer;
  bTrain: Boolean);
var
  i: Integer;
  u, w: Double;
  aPoint: TSkewPoint;
begin
  for i := 0 to Count - 1 do
  begin
    aPoint := GetPoint(i);

      // x-axis 
    u := (dX - aPoint.X) / FBandWidth;

      // get weight based the kernel type
    if (abs(u) > 1) and (FKernelType <> ktGaussian) then
    begin
      w := 0;
      Continue;
    end;

    case FKernelType of
      ktTriangular:   w := 1 - abs(u);
      ktEpanechnikov: w := 0.75 * (1 - u*u);
      ktBiweight:     w := 0.9375 * Math.Power(1 - u*u, 2);
      ktTriweight:    w := 1.09375 * Math.Power(1 - u*u, 3);
      ktMunaf:        w := 1.23046875 * Math.Power(1 - u*u, 4);
      ktGaussian:     w := 0.398942280401433
                            * Math.Power(2.71828182845904523536, -u*u*0.5);
      ktCosinus:      w := 0.78539816339744830961566084581988
                             * cos(1.5707963267948966192313216916398 * u);
    end;

      // calc IV(weighted average)
    if (w > 0) then
    begin
      aPoint.Values[iCallPut, iBidAsk].CalcIV(dIVRef, w, bTrain);

      FMaxY := Max(FMaxY, aPoint.Values[iCallPut, iBidAsk].IV);
    end;
  end;
end;

function TSkewPoints.GetValue(dX: Double; iCallPut, iBidAsk: Integer): Double;
var
  i: Integer;
  Point1, Point2: TSkewPoint;
  X1, X2, IV1, IV2: Double;
begin
  Result := 0.0;

  for i := 0 to Count - 2 do
  begin
    Point1 := GetPoint(i);
    Point2 := GetPoint(i+1);
    X1 := Point1.FX;
    X2 := Point2.FX;
    IV1 := Point1.Values[iCallPut, iBidAsk].IV;
    IV2 := Point2.Values[iCallPut, iBidAsk].IV;

    if (dX > X1) and (dX < X2) then
    begin
      if IV1 < SKEW_EPSILON then
        Result := IV2
      else if IV2 < SKEW_EPSILON then
        Result := IV1
      else
        Result := (IV1 * (X2 - dX) + IV2 * (dX - X1)) / (X2 - X1);

      Break;
    end;
  end;
end;

{ TSkewHistories }

constructor TSkewHistories.Create;
begin
  FSkewPoints := TSkewPoints.Create;
  FHistories := 0;
  FPoints := 0;
end;

destructor TSkewHistories.Destroy;
begin
  FSkewPoints.Free;

  inherited;
end;

procedure TSkewHistories.Clear;
begin
  FSkewPoints.Clear;
  FHistories := 0;
  FPoints := 0;
end;

procedure TSkewHistories.Copy(Source: TSkewPoints);
var
  i: Integer;
  aPoint: TSkewPoint;
begin
  if (Source = nil) or (FHistories >= MAX_HISTORIES) then Exit;

  if FHistories = 0 then
    FPoints := Source.Count;

  for i := 0 to Source.Count - 1 do
  begin
    aPoint := FSkewPoints.Add as TSkewPoint;
    aPoint.Copy(Source[i]);
    FTable[i, FHistories] := aPoint;
  end;

  Inc(FHistories);
end;

end.


