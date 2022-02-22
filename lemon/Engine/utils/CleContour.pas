unit CleContour;

interface

uses
  Classes, Math;

const
  MAX_LEVELS = 20;
  MAX_X_COUNT = 100;
  MAX_Y_COUNT = 100;

type
  TContourLine = class(TCollectionItem)
  public
    X1, Y1, X2, Y2: Double;
  end;

  TContourLines = class(TCollection)
  private
    function GetLine(i: Integer): TContourLine;
  public
    constructor Create;

    function AddLine(dX1, dY1, dX2, dY2: Double): TContourLine;

    property Lines[i:Integer]: TContourLine read GetLine; default;
  end;

  TEdgeLevel = record
     Intersects: Boolean;
     X, Y: Double;
  end;

  TContourVertex = record
    X, Y, Z: Double;
    H_Edge: array[0..MAX_LEVELS-1] of TEdgeLevel;
    V_Edge: array[0..MAX_LEVELS-1] of TEdgeLevel;
    Mid_Z: Double;
  end;

  TGridContour = class
  private
    FGrid: array[0..MAX_X_COUNT-1, 0..MAX_Y_COUNT-1] of TContourVertex;
    FLevels: array[0..MAX_LEVELS-1] of Double;
    FXMin, FXStep, FYMin, FYStep: Double;
    FXCount: Integer;
    FYCount: Integer;
    FLevelCount: Integer;

    FLines: TContourLines;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetGrid(dXMin, dXMax, dXStep, dYMin, dYMax, dYStep: Double);
    procedure SetLevels(dZMin, dZMax: Double; iLevels: Integer);
    procedure SetCell(dX, dY, dZ: Double);
    procedure PlotContour;

    property Lines: TContourlines read FLines;
  end;

implementation

{ TContourLines }

function TContourLines.AddLine(dX1, dY1, dX2, dY2: Double): TContourLine;
begin
  Result := Add as TContourLine;

  Result.X1 := dX1;
  Result.Y1 := dY1;
  Result.X2 := dX2;
  Result.Y2 := dY2;
end;

constructor TContourLines.Create;
begin
  inherited Create(TContourLine);
end;

function TContourLines.GetLine(i: Integer): TContourLine;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TContourLine
  else
    Result := nil;
end;

{ TGridContour }

constructor TGridContour.Create;
begin
  FXCount := 0;
  FYCount := 0;
  FLevelCount := 0;

  FLines := TContourLines.Create;
end;

destructor TGridContour.Destroy;
begin
  FLines.Free;

  inherited;
end;

procedure TGridContour.SetGrid(dXMin, dXMax, dXStep, dYMin, dYMax,
  dYStep: Double);
var
  i, j: Integer;
begin
    // set grid sizes
  if dXStep < 1.0e-10 then dXStep := 0.001; // 0.001 is random value
  if dYStep < 1.0e-10 then dYStep := 0.001;

  FXCount := Max(0, Min(MAX_X_COUNT, Round((dXMax - dXMin)/dXStep + 1)));
  FYCount := Max(0, Min(MAX_Y_COUNT, Round((dYMax - dYMin)/dYStep + 1)));

  FXMin := dXMin; FXStep := dXStep;
  FYMin := dYMin; FYStep := dYStep;

    // initialize grid
  for i := 0 to FXCount - 1 do
    for j := 0 to FYCount - 1 do
    begin
      FGrid[i,j].X := FXMin + i * dXStep;
      FGrid[i,j].Y := FYMin + j * dYStep;
      FGrid[i,j].Z := 0.0;
      FGrid[i,j].Mid_Z := 0.0;
    end;
end;

procedure TGridContour.SetLevels(dZMin, dZMax: Double; iLevels: Integer);
var
  dStep: Double;
  i, j, k: Integer;
begin
  if iLevels < 1 then iLevels := 2;

  dStep := (dZMax - dZMin) / iLevels;
  if dStep < 1.0e-10 then dStep := 0.001; // random values

  FLevelCount := iLevels - 1;

  for i := 0 to FLevelCount-1 do
    FLevels[i] := dZMin + (i+1) * dStep;

  for i := 0 to FXCount - 1 do
    for j := 0 to FYCount - 1 do
      for k := 0 to FLevelCount - 1 do
      begin
        FGrid[i,j].H_Edge[k].Intersects := False;
        FGrid[i,j].V_Edge[k].Intersects := False;
      end;
end;

procedure TGridContour.SetCell(dX, dY, dZ: Double);
var
  iX, iY: Integer;
begin
  iX := Round((dX - FXMin)/FXStep);
  iY := Round((dY - FYMin)/FYStep);

  if (iX >= 0) and (iX <= FXCount-1)
     and (iY >= 0) and (iY <= FYCount-1) then
    FGrid[iX,iY].Z := dZ;
end;

procedure TGridContour.PlotContour;
var
  iX, iY, iZ: Integer;
  dZ1, dZ2, dDelta: Double;
begin
  FLines.Clear;

    // check edges
  for iX := 0 to FXCount - 1 do
    for iY := 0 to FYCount - 1 do
    begin
        // h-edge
      if iX < FXCount-1 then
      begin
        dZ1 := Min(FGrid[iX,iY].Z, FGrid[iX+1,iY].Z);
        dZ2 := Max(FGrid[iX,iY].Z, FGrid[iX+1,iY].Z);

        for iZ := 0 to FLevelCount - 1 do
          if (FLevels[iZ] > dZ1 - 1.0e-10) and (FLevels[iZ] < dZ2 -1.0e-10) then
          begin
            FGrid[iX,iY].H_Edge[iZ].Intersects := True;
            FGrid[iX,iY].H_Edge[iZ].Y := FGrid[iX,iY].Y;
            dDelta := (FLevels[iZ] - dZ1)/(dZ2-dZ1) * FXStep;
            if FGrid[iX+1,iY].Z > FGrid[iX,iY].Z then
              FGrid[iX,iY].H_Edge[iZ].X := FGrid[iX,iY].X + dDelta
            else
              FGrid[iX,iY].H_Edge[iZ].X := FGrid[iX+1,iY].X - dDelta;
          end;
      end;

        // v-edge
      if iY < FYCount-1 then
      begin
        dZ1 := Min(FGrid[iX,iY].Z, FGrid[iX,iY+1].Z);
        dZ2 := Max(FGrid[iX,iY].Z, FGrid[iX,iY+1].Z);

        for iZ := 0 to FLevelCount - 1 do
          if (FLevels[iZ] > dZ1 - 1.0e-10) and (FLevels[iZ] < dZ2 -1.0e-10) then
          begin
            FGrid[iX,iY].V_Edge[iZ].Intersects := True;
            FGrid[iX,iY].V_Edge[iZ].X := FGrid[iX,iY].X;
            dDelta := (FLevels[iZ] - dZ1)/(dZ2-dZ1) * FYStep;
            if FGrid[iX,iY+1].Z > FGrid[iX,iY].Z then
              FGrid[iX,iY].V_Edge[iZ].Y := FGrid[iX,iY].Y + dDelta
            else
              FGrid[iX,iY].V_Edge[iZ].Y := FGrid[iX,iY+1].Y - dDelta;
          end;
      end;

        // middle point
      FGrid[iX,iY].Mid_Z := (FGrid[iX,iY].Z + FGrid[iX+1,iY].Z
                             + FGrid[iX,iY+1].Z + FGrid[iX+1, iY+1].Z) / 4.0;
    end;

    // generate contour lines
  for iX := 0 to FXCount - 2 do
    for iY := 0 to FYCount - 2 do
      for iZ := 0 to FLevelCount - 1 do
      begin
          // top
        if FGrid[iX,iY].H_Edge[iZ].Intersects then
        begin
          if FGrid[iX,iY].V_Edge[iZ].Intersects
             and FGrid[iX+1,iY].V_Edge[iZ].Intersects then
          begin
            if (FGrid[iX,iY].Z < FGrid[iX+1,iY].Z)
               and (FLevels[iZ] < FGrid[iX,iY].Mid_Z) then
            begin
              FLines.AddLine(FGrid[iX,iY].H_Edge[iZ].X,
                             FGrid[iX,iY].H_Edge[iZ].Y,
                             FGrid[iX,iY].V_Edge[iZ].X,
                             FGrid[iX,iY].V_Edge[iZ].Y);
              FLines.AddLine(FGrid[iX,iY+1].H_Edge[iZ].X,
                             FGrid[iX,iY+1].H_Edge[iZ].Y,
                             FGrid[iX+1,iY].V_Edge[iZ].X,
                             FGrid[iX+1,iY].V_Edge[iZ].Y);
            end else
            begin
              FLines.AddLine(FGrid[iX,iY].H_Edge[iZ].X,
                             FGrid[iX,iY].H_Edge[iZ].Y,
                             FGrid[iX+1,iY].V_Edge[iZ].X,
                             FGrid[iX+1,iY].V_Edge[iZ].Y);
              FLines.AddLine(FGrid[iX,iY].V_Edge[iZ].X,
                             FGrid[iX,iY].V_Edge[iZ].Y,
                             FGrid[iX,iY+1].H_Edge[iZ].X,
                             FGrid[iX,iY+1].H_Edge[iZ].Y);
            end;
          end else
          if FGrid[iX,iY].V_Edge[iZ].Intersects then
            FLines.AddLine(FGrid[iX,iY].H_Edge[iZ].X,
                           FGrid[iX,iY].H_Edge[iZ].Y,
                           FGrid[iX,iY].V_Edge[iZ].X,
                           FGrid[iX,iY].V_Edge[iZ].Y)
          else if FGrid[iX,iY+1].H_Edge[iZ].Intersects then
            FLines.AddLine(FGrid[iX,iY].H_Edge[iZ].X,
                           FGrid[iX,iY].H_Edge[iZ].Y,
                           FGrid[iX,iY+1].H_Edge[iZ].X,
                           FGrid[iX,iY+1].H_Edge[iZ].Y)
          else if FGrid[iX+1,iY].V_Edge[iZ].Intersects then
            FLines.AddLine(FGrid[iX,iY].H_Edge[iZ].X,
                           FGrid[iX,iY].H_Edge[iZ].Y,
                           FGrid[iX+1,iY].V_Edge[iZ].X,
                           FGrid[iX+1,iY].V_Edge[iZ].Y);
        end else
        if FGrid[iX,iY].V_Edge[iZ].Intersects then
        begin
          if FGrid[iX+1,iY].V_Edge[iZ].Intersects then
            FLines.AddLine(FGrid[iX,iY].V_Edge[iZ].X,
                           FGrid[iX,iY].V_Edge[iZ].Y,
                           FGrid[iX+1,iY].V_Edge[iZ].X,
                           FGrid[iX+1,iY].V_Edge[iZ].Y)
          else
          if FGrid[iX,iY+1].H_Edge[iZ].Intersects then
            FLines.AddLine(FGrid[iX,iY].V_Edge[iZ].X,
                           FGrid[iX,iY].V_Edge[iZ].Y,
                           FGrid[iX,iY+1].H_Edge[iZ].X,
                           FGrid[iX,iY+1].H_Edge[iZ].Y);
        end else
        if FGrid[iX,iY+1].H_Edge[iZ].Intersects then
          if FGrid[iX+1,iY].V_Edge[iZ].Intersects then
            FLines.AddLine(FGrid[iX,iY+1].H_Edge[iZ].X,
                           FGrid[iX,iY+1].H_Edge[iZ].Y,
                           FGrid[iX+1,iY].V_Edge[iZ].X,
                           FGrid[iX+1,iY].V_Edge[iZ].Y);
      end;
end;


end.
