unit CleBootStrap;

interface

uses
  Classes, SysUtils,

  CleStatistics;

type
  TBootStrap = class
  private
    FDFList: TDFSeriesCollection;
    FSample: TDFSeries;
    FResample: TDFSeries;
    FMeans: TDFSeries;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure MakeResample;
    procedure GenerateSampleDistribution(iCount: Integer);

    property DFList: TDFSeriesCollection read FDFList;
    property Sample: TDFSeries read FSample;
    property Resample: TDFSeries read FResample;
    property Means: TDFSeries read FMeans;
  end;

implementation

{ TBootStrap }

constructor TBootStrap.Create;
begin
  FDFList := TDFSeriesCollection.Create;

  Reset;
  Randomize;
end;

destructor TBootStrap.Destroy;
begin
  FDFList.Free;

  inherited;
end;

procedure TBootStrap.Reset;
begin
  FDFList.Reset;
  
  FSample := FDFList.AddSeries;
  FSample.Title := 'Sample';
  FResample := FDFList.AddSeries;
  FResample.Title := 'Resample';
  FMeans := FDFList.AddSeries;
  FMeans.Title := 'Means';
end;

procedure TBootStrap.MakeResample;
var
  i, iIndex: Integer;
begin
  FResample.Reset;

  if FSample.Data.Count = 0 then Exit;

  for i := 0 to FSample.Data.Count - 1 do
  begin
    iIndex := Random(FSample.Data.Count);
    FResample.AddData(FSample.Data[iIndex].Value);
  end;

  FResample.Data.CalcStat;
end;

procedure TBootStrap.GenerateSampleDistribution(iCount: Integer);
var
  i: Integer;
begin
  FMeans.Reset;
  
  for i := 0 to iCount - 1 do
  begin
    MakeResample;
    //FResample.SaveToFile('ttt' + IntToStr(i));

    FMeans.AddData(FResample.Data.Mean);
  end;

  FMeans.CalcStat;
end;

end.
