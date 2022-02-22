unit CSkewGraph;

interface

uses
  Classes, Math, Windows, Graphics, ExtCtrls,

    // lemon: utils
  ClePainter,
    // skew
  CSkewConsts, CSkewPoints;

type
  TSkewGraph = class
  private
    FPainter: TPainter;
      //
    FPoints: TSkewPoints;

    FPaintBox: TPaintBox;
    procedure SetPaintBox(const Value: TPaintBox);
    procedure Draw;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Refresh;

    property Points: TSkewPoints read FPoints write FPoints;
    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
  end;

implementation

{ TSkewGraph }

constructor TSkewGraph.Create;
begin
  FPainter := TPainter.Create;
  FPainter.SetMargin(50, 20, 50, 20);
  FPainter.XScaleSpacing := 60;
  FPainter.YScaleSpacing := 50;
end;


destructor TSkewGraph.Destroy;
begin
  FPainter.Free;

  inherited;
end;

procedure TSkewGraph.SetPaintBox(const Value: TPaintBox);
begin
  FPaintBox := Value;
end;

procedure TSkewGraph.Refresh;
begin
  if FPaintBox = nil then Exit;

  FPainter.SetDrawingArea(FPaintBox.ClientRect);

  Draw;
end;

procedure TSkewGraph.Draw;
var
  i, j, k, iX, iY: Integer;
  aPoint: TSkewPoint;
begin
  if (FPoints = nil) or (FPaintBox = nil) then Exit;

  try
      // draw background
    FPainter.DrawBackground;

      // draw axis

    FPainter.SetXRatio(FPoints.MinX, FPoints.MaxX);
    FPainter.SetYRatio(0.0, FPoints.MaxY);
    FPainter.DrawAxis;

      // draw chart
    with FPainter.DrawCanvas do
    for i := 0 to 1 do
      for j := 0 to 2 do
      begin
        Pen.Color := SKEW_COLORS[i*3 + j];
        
        for k := 0 to FPoints.Count - 1 do
        begin
          aPoint := FPoints[k];

          iX := FPainter.GetXPos(aPoint.X);
          iY := FPainter.GetYPos(aPoint.Values[i,j].IV);

          if k = 0 then
            MoveTo(iX, iY)
          else
            LineTo(iX, iY);
        end;
      end;
  finally
    FPainter.DrawFrame;
    FPainter.Display(FPaintBox.Canvas);
  end;
end;

end.
