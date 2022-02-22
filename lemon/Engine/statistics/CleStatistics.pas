unit CleStatistics;

interface

uses
  Classes, Math, SysUtils;

const
  QQ_SLOT_COUNT = 20;
  QQ_SLOT_STEP = 0.05;
  MAX_CHISQ_MAP = 200;
  MAX_DF_ROWS = 100;
  MAX_DF_COLS = 100;

type
  TDFBin = class(TCollectionItem)
  private
    FFrequency: Integer; // Frequency of occurence n(i)
    FDensity: Double;    // n(i)/N
    FPercentile: Double; // accumulated percentile
      // Low-Epsion < Bin < High - Epsilon
    FHigh: Double; // low boundary of the bin
    FLow: Double;  // high boundary of the bin
  public
    procedure Put;

    property Frequency: Integer read FFrequency;
    property Density: Double read FDensity;
    property Percentile: Double read FPercentile;
    property Low: Double read FLow;
    property High: Double read FHigh;
  end;

  TDFBins = class(TCollection)
  private
    FMinValue: Double;
    FMaxValue: Double;
    FBinSize: Double;
    FMaxDensity: Double;
    procedure Put(dValue: Double);
    procedure Reset;
    procedure SetBins(dMin, dMax: Double);

    function GetBin(i: Integer): TDFBin;
  public
    constructor Create;

    property BinSize: Double read FBinSize;
    property MinValue: Double read FMinValue;
    property MaxValue: Double read FMaxValue;
    property MaxDensity: Double read FMaxDensity;
    property Bins[i:Integer]: TDFBin read GetBin; default;
  end;

  TDFDataItem = class(TCollectionItem)
  private
    FValue: Double;
  public
    property Value: Double read FValue;
  end;

  TDFData = class(TCollection)
  private
    FMin: Double;
    FMax: Double;
    FMean: Double;
    FStdDev: Double;

    procedure Reset;
    function GetValue(i: Integer): TDFDataItem;
  public
    constructor Create;

    function AddValue(dValue: Double): TDFDataItem;
    procedure CalcStat;
    function Represent: String;

    property Min: Double read FMin;
    property Max: Double read FMax;
    property Mean: Double read FMean;
    property StdDev: Double read FStdDev;
    property Values[i:Integer]: TDFDataItem read GetValue; default;
  end;

  TDFSeries = class(TCollectionItem)
  private
    FTitle: String;
    FColTitle: String;
    FRowTitle: String;

    FBins: TDFBins;
    FData: TDFData;

    FQQSlots: array[0..QQ_SLOT_COUNT-1] of Double;

    procedure Finalize;

    function GetQQSlot(i: Integer): Double;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    procedure Reset;
    procedure AddData(dValue: Double);
    procedure CalcStat;

    procedure SaveToFile(stFile: String);
    function Represent: String;

    property Title: String read FTitle write FTitle;
    property ColTitle: String read FColTitle write FColTitle;
    property RowTitle: String read FRowTitle write FRowTitle;
    property Bins: TDFBins read FBins;
    property Data: TDFData read FData;

    property QQSlots[i:Integer]: Double read GetQQSlot;
  end;

  TDFSeriesCollection = class(TCollection)
  private
    FChiSqMap: array[0..MAX_CHISQ_MAP-1, 0..MAX_CHISQ_MAP-1] of Double;
    FChiSqCount: Integer;
    FChiSqMax: Double;
    FTable: array[0..MAX_DF_COLS-1, 0..MAX_DF_ROWS-1] of TDFSeries;
    FRowCount: Integer;
    FColCount: Integer;
    function GetTable(iCol, iRow: Integer): TDFSeries;

    function GetChiSqMap(i, j: Integer): Double;
    function GetSeries(i: Integer): TDFSeries;
  public
    constructor Create;

    procedure Reset;
    function AddSeries: TDFSeries;

    function CalcChiSq(Series1, Series2: TDFSeries): Double;
    procedure SaveChiSqMapToFile(stFile: String);
    procedure MakeChiSqMap;

    procedure CalcStat;

    property ChiSqCount: Integer read FChiSqCount;
    property ChiSqMax: Double read FChiSqMax;
    property ChiSqMap[i,j:Integer]: Double read GetChiSqMap;

    property Series[i:Integer]: TDFSeries read GetSeries; default;
    property Table[iCol,iRow:Integer]: TDFSeries read GetTable;
    property RowCount: Integer read FRowCount;
    property ColCount: Integer read FColCount;
  end;


implementation

{ TDFBin }

procedure TDFBin.Put;
begin
  FFrequency := FFrequency + 1;
end;

{ TDFBins }

const
  DEF_BIN_SIZE = 0.01;
  MAX_BINS = 100;
  
constructor TDFBins.Create;
begin
  inherited Create(TDFBin);
end;

function TDFBins.GetBin(i: Integer): TDFBin;
begin
  if (i>=0) and (i<=Count-1) then
    Result := Items[i] as TDFBin
  else
    Result := nil;
end;

procedure TDFBins.Reset;
begin
  FBinSize := DEF_BIN_SIZE;
  FMaxDensity := 0.0;
end;

procedure TDFBins.SetBins(dMin, dMax: Double);
var
  dBinSize: Double;
  i, iBinCount: Integer;
  aBin: TDFBin;
begin
//  if Math.IsZero(dBinSize, 1.0e-10) then Exit;

    // set bin size
  dBinSize := Power(10, Floor(log10((dMax - dMin) / MAX_BINS)-1.0));
  if Round((dMax - dMin) / dBinSize) >= MAX_BINS then
  begin
    dBinSize := dBinSize * 2.5;
    if Round((dMax - dMin) / dBinSize) >= MAX_BINS  then
      dBinSize := dBinSize * 2.0;
  end;

  FBinSize := dBinSize;

    //
  FMinValue := Floor((dMin+1.0e-10)/dBinSize) * dBinSize;
  FMaxValue := Ceil((dMax+1.0e-10)/dBinSize) * dBinSize;

  iBinCount := Round((FMaxValue - FMinValue)/FBinSize);

  for i := 1 to iBinCount do
  begin
    aBin := Add as TDFBin;
    aBin.FLow := FMinValue + (i-1) * FBinSize;
    aBin.FHigh := aBin.Low + FBinSize;
    aBin.FFrequency := 0;
    aBin.FDensity := 0;
    aBin.FPercentile := 0;
  end;
end;

procedure TDFBins.Put(dValue: Double);
var
  iBin: Integer;
  aBin: TDFBin;
begin
  iBin := Floor((dValue - FMinValue + 1.0e-10)/FBinSize);
  aBin := GetBin(iBin);

  if aBin <> nil then aBin.Put;
end;

{ TDFData }

constructor TDFData.Create;
begin
  inherited Create(TDFDataItem);
end;

function TDFData.AddValue(dValue: Double): TDFDataItem;
begin
  Result := Add as TDFDataItem;
  Result.FValue := dValue;
end;

procedure TDFData.Reset;
begin
  FMin := 0.0;
  FMax := 0.0;
end;

procedure TDFData.CalcStat;
var
  i: Integer;
  dValue: Double;
  dSum: Double;
begin
  FMin := 0.0;
  FMax := 0.0;
  FMean := 0.0;
  FStdDev := 0.0;

  if Count <= 1 then Exit;

  dSum := 0;

  for i := 0 to Count - 1 do
  begin
    dValue := GetValue(i).FValue;

    dSum := dSum + dValue;

    if i > 0 then
    begin
      FMin := Math.Min(FMin, dValue);
      FMax := Math.Max(FMax, dValue);
    end else
    begin
      FMin := dValue;
      FMax := dValue;
    end;
  end;

    // mean
  FMean := dSum / Count;

    // standard deviation
  dSum := 0.0;

  for i := 0 to Count - 1 do
  begin
    dValue := GetValue(i).FValue;
    dSum := dSum + (dValue - FMean) * (dValue - FMean);
  end;
  FStdDev := Power(dSum/(Count-1), 0.5);
end;

function TDFData.Represent: String;
begin
  Result := Format('(min=%.6f,max:%.6f,mean=%.6f,stdev=%.6f)',
                      [FMin, FMax, FMean, FStdDev]);
end;


function TDFData.GetValue(i: Integer): TDFDataItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TDFDataItem
  else
    Result := nil;
end;

{ TDFSeries }

constructor TDFSeries.Create(aColl: TCollection);
begin
  inherited;

  FBins := TDFBins.Create;
  FData := TDFData.Create;
end;

destructor TDFSeries.Destroy;
begin
  FData.Free;
  FBins.Free;

  inherited;
end;

//---------------------------------------------< New Sequence >

procedure TDFSeries.Reset;
begin
  FBins.Clear;
  FBins.Reset;

  FData.Clear;
  FData.Reset;
end;

procedure TDFSeries.AddData(dValue: Double);
begin
  FData.AddValue(dValue);
end;

procedure TDFSeries.CalcStat;
var
//  iBin: Integer;
//  aBin: TDFBin;
  i: Integer;
//  dValue: Double;
begin
  if FData.Count = 0 then Exit;

    // get min/max
  FData.CalcStat;
  if FData.Max - FData.Min < 1.0e-10 then Exit;

    // set bins
  FBins.SetBins(FData.Min, FData.Max);

    // apply data
  for i := 0 to FData.Count - 1 do
    FBins.Put(FData[i].FValue);

    // finalize
  Finalize;
end;

procedure TDFSeries.Finalize;
var
  i, iQQ: Integer;
  dPercentile, dRefPcnt: Double;
  aBin: TDFBin;
begin
  if FData.Count <= 0 then Exit;

  dPercentile := 0.0;
  dRefPcnt := QQ_SLOT_STEP;
  iQQ := 0;
  FBins.FMaxDensity := 0.0;

  for i := 0 to FBins.Count - 1 do
  begin
    aBin := FBins[i];
    if aBin <> nil then
    begin
      aBin.FDensity := aBin.FFrequency / FData.Count;
      aBin.FPercentile := aBin.FDensity + dPercentile;
      dPercentile := aBin.FPercentile;

      while dPercentile > dRefPcnt - 1.0e-10 do
      begin
        if iQQ >= QQ_SLOT_COUNT then Break;

        FQQSlots[iQQ] := aBin.Low;
        dRefPcnt := dRefPcnt + QQ_SLOT_STEP;
        iQQ := iQQ + 1;
      end;

      FBins.FMaxDensity := Math.Max(FBins.FMaxDensity, aBin.Density);
    end;
  end;
end;

function TDFSeries.GetQQSlot(i: Integer): Double;
begin
  if (i >= 0) and (i <= QQ_SLOT_COUNT-1) then
    Result := FQQSlots[i]
  else
    Result := 0.0;
end;

function TDFSeries.Represent: String;
begin
  Result := '(Title=' + FTitle + ',Data=' + FData.Represent + ')';
end;

procedure TDFSeries.SaveToFile(stFile: String);
var
  F: TextFile;
  i: Integer;
begin
  AssignFile(F, stFile);
  try
    Rewrite(F);

    Writeln(F, Format('Title,%s', [FTitle]));
    Writeln(F, Format('Min,%.4f', [FData.Min]));
    Writeln(F, Format('Max,%.4f', [FData.Max]));
    Writeln(F, Format('Mean,%.4f', [FData.Mean]));
    Writeln(F, Format('Bin Size,%.4f', [FBins.BinSize]));
    Writeln(F, Format('Data Count,%d', [FData.Count]));
    Writeln(F, Format('Applied Count,%d', [FData.Count]));
    Writeln(F, Format('Max Density,%.4f', [FBins.MaxDensity]));
    Writeln(F, '[QQ Slots]');
    for i := 0 to QQ_SLOT_COUNT - 1 do
      Writeln(F, Format('QQ[%.2f],%.4f', [QQ_SLOT_STEP*(i+1), FQQSlots[i]]));
    Writeln(F, '[Distribution]');
    Writeln(F, 'Bin,Freq,Density,Percentile');
    for i := 0 to FBins.Count - 1 do
    with FBins[i] do
      Writeln(F, Format('%.4f~%.4f,%d,%.4f,%.4f',[
                               Low, High, Frequency, Density, Percentile]));

    Writeln(F, '[Source Data]');
    Writeln(F, 'Index,Value');
    for i := 0 to FData.Count - 1 do
      Writeln(F, Format('%d,%.4f', [i, FData[i].Value]));

  finally
    CloseFile(F);
  end;
end;

{ TDFSeriesCollection }

constructor TDFSeriesCollection.Create;
begin
  inherited Create(TDFSeries);
end;

function TDFSeriesCollection.AddSeries: TDFSeries;
begin
  Result := Add as TDFSeries;
end;

function TDFSeriesCollection.GetSeries(i: Integer): TDFSeries;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TDFSeries
  else
    Result := nil;
end;

function TDFSeriesCollection.GetTable(iCol, iRow: Integer): TDFSeries;
begin
  if (iCol >= 0) and (iCol <= MAX_DF_COLS-1)
     and (iRow >= 0) and (iRow <= MAX_DF_ROWS-1) then
  begin
    if FTable[iCol, iRow] = nil then
    begin
      FTable[iCol, iRow] := AddSeries;
      
      FColCount := Max(iCol+1, FColCount);
      FRowCount := Max(iRow+1, FRowCount);
    end;
      
    Result := FTable[iCol,iRow];
  end else
    Result := nil;
end;

procedure TDFSeriesCollection.Reset;
var
  iCol: Integer;
  iRow: Integer;
begin
  Clear;

  for iCol := 0 to MAX_DF_COLS - 1 do
    for iRow := 0 to MAX_DF_ROWS - 1 do
      FTable[iCol,iRow] := nil;
      
  FColCount := 0;
  FRowCount := 0;
end;

function TDFSeriesCollection.CalcChiSq(Series1, Series2: TDFSeries): Double;
var
  dPercentiles: array[1..2, 0..8] of Double;
  dValues: array[0..8] of Double;
  i, iQ: Integer;
  dPercentile, dObserved, dExpected, dChiSq: Double;
    // test code
  //aList: TStringList;
begin
  Result := 0.0;

  if (Series1 = nil) or (Series2 = nil) then Exit;

  for i := 0 to 8 - 1 do
  begin
    dPercentiles[1][i] := 0.0;
    dPercentiles[2][i] := 0.0;
    dValues[i] := 0.0;
  end;

  dPercentile := 0.1;
  iQ := 0;

  for i := 0 to Series1.Bins.Count - 1 do
  begin
    while Series1.Bins[i].Percentile > dPercentile - 1.0e-10 do
    begin
      dPercentiles[1][iQ] := Series1.Bins[i].Percentile;
      dValues[iQ] := Series1.Bins[i].Low;

      iQ := iQ + 1;
      dPercentile := dPercentile + 0.1;

      if iQ > 8 then Break;
    end;

    if iQ > 8 then Break;
  end;

  iQ := 0;
  for i := 0 to Series2.Bins.Count - 1 do
  begin
      while Series2.Bins[i].Low > dValues[iQ] - 1.0e-10 do
      begin
        dPercentiles[2][iQ] := Series2.Bins[i].Percentile;
        iQ := iQ + 1;

        if iQ > 8 then Break;
      end;
    if iQ > 8 then Break;
  end;

  if iQ < 8 then
    for i := iQ to 8 do
      dPercentiles[2][i] := 1.0;

  dChiSq := 0;
  for i := 0 to 7 do
  begin
    dExpected := (dPercentiles[1][i+1] - dPercentiles[1][i]) * 100.0;
    dObserved := (dPercentiles[2][i+1] - dPercentiles[2][i]) * 100.0;
    if dExpected > 1.0e-10 then
      dChiSq := dChiSq + Power(dObserved - dExpected, 2)/dExpected;
  end;

  Result := dChiSq;

    // test code // save
  {
  aList := TStringList.Create;
  try
    for i := 0 to 8 do
    begin
      if i= 0 then
        aList.Add(Format('%.4f,,%.4f,%.4f',
            [dPercentiles[1,i],dValues[i],dPercentiles[2,i]]))
      else
      begin
        dExpected := dPercentiles[1][i] - dPercentiles[1][i-1];
        dObserved := dPercentiles[2][i] - dPercentiles[2][i-1];
        if dExpected > 1.0e-10 then
          aList.Add(Format('%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f',
              [dPercentiles[1,i],dExpected,dValues[i],dPercentiles[2,i],dObserved,
               (dObserved-dExpected), (dObserved-dExpected)*(dObserved-dExpected),
               (dObserved-dExpected)*(dObserved-dExpected)/dExpected]))
        else
          aList.Add(Format('%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f',
              [dPercentiles[1,i],dExpected,dValues[i],dPercentiles[2,i],dObserved,
               (dObserved-dExpected), (dObserved-dExpected)*(dObserved-dExpected),
               0.0]))
      end;
    end;
  finally
    aList.SaveToFile('calc.'+ Series1.Title + '~' + Series2.Title + '.csv');
    aList.Free;
  end;
  }

end;

procedure TDFSeriesCollection.CalcStat;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    GetSeries(i).CalcStat;
end;

function TDFSeriesCollection.GetChiSqMap(i, j: Integer): Double;
begin
  Result := FChiSqMap[i,j];
end;

procedure TDFSeriesCollection.MakeChiSqMap;
var
  i, j: Integer;
begin
  FChiSqCount := Math.Min(Count, MAX_CHISQ_MAP);
  FChiSqMax := 0.0;

  for i := 0 to FChiSQCount - 1 do
    for j := 0 to FChiSQCount - 1 do
    begin
      FChiSqMap[i,j] := CalcChiSq(Series[i],Series[j]);
      if FChiSqMap[i,j] > FChiSqMax then
        FChiSqMax := FChiSqMap[i,j];
    end;
end;

procedure TDFSeriesCollection.SaveChiSqMapToFile(stFile: String);
var
  F: TextFile;
  i, j: Integer;
begin
  AssignFile(F, stFile);
  try
    Rewrite(F);

    for j := 0 to FChiSqCount - 1 do
      Write(F, ',' + Series[j].Title);
    Writeln(F, '');

    for i := 0 to FChiSqCount - 1 do
    begin
      Write(F, Series[i].Title);
      for j := 0 to FChiSqCount - 1 do
        Write(F, Format(',%.2f', [FChiSqMap[i,j]]));
      Writeln(F, '');
    end;
  finally
    CloseFile(F);
  end;
end;

end.
