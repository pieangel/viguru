unit SpreadData;

interface

uses
  Classes, Graphics, Math, SysUtils,
  //
  GleTypes,
  CalcGreeks, CleMarkets,
  ChartIF, Charters, XTerms, CleSymbols;

const
  MIN_INDEX = 0;
  MAX_INDEX = 1;

  MAX_COLORS = 13;

  SPREAD_COLORS : array[0..MAX_COLORS-1] of TColor =
                   (clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal,
                    clGray, clRed, clLime, clYellow, clBlue, clFuchsia, clAqua);
  SPREAD_PERIODS : array[0..3] of Integer = (1, 5, 10, 30);
  SPREAD_SCALES : array[0..1] of TScaleType = (stScreen, stEntire);

type

  TSpreadSeriesItem = class(TCollectionItem)
  public
    LastTime : TDateTime;
    MMIndex : Integer;
    Value : Double;
    Source : Double; // added by CHJ on 2003.10.28
    Defined : Boolean;
  end;

  TSpreadSeries = class(TCollectionItem)
  private
    FTitle : String;
    FUnitTitle : String;
    FChartBase : TChartBase;
    FItems : TCollection{TSpreadSeriesItem};
    FRemark : String;

    function GetLength : Integer;
    procedure SetLength(Value : Integer);
    function GetItem(i:Integer) : TSpreadSeriesItem;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    procedure Clear;
    procedure GetMinMax(iStart, iEnd : Integer; var dMin, dMax : Double);
    function DateTimeDesc(iIndex : Integer) : String;

    //-- 04/04/13 insert by sms
    function InsertItem(iIndex : Integer) : TSpreadSeriesItem;
    function DeleteItem(iIndex : Integer) : Integer;

    property Title : String read FTitle write FTitle;
    property UnitTitle : String read FUnitTitle write FUnitTitle;
    property Remark : String read FRemark write FRemark;

    property ChartBase : TChartBase read FChartBase write FChartBase;
    property Length : Integer read GetLength write SetLength;
    property Items[i:Integer] : TSpreadSeriesItem read GetItem; default;
  end;

  TSpreadSeriesStore = class(TCollection)
  private
    function GetLastTime : TDateTime;
    function GetLength : Integer;
    function GetTime(i: Integer): TDateTime;
  public
    constructor Create;

    function AddSeries : TSpreadSeries;

    //-- 04/04/13 insert by sms
    //procedure InsertItemForEachSeries(dtLast : TDateTime; iIndex : Integer);

    procedure AddLength(dtLast : TDateTime);
    procedure AddFirstLength(dtLast : TDateTime);
    function CheckTimeForAdd(dtValue : TDateTime) : Boolean;

    procedure ClearData;

    property LastTime : TDateTime read GetLastTime;
    property Length : Integer read GetLength;
    property Time[i:Integer] : TDateTime read GetTime;

  end;

  TSpreadGraphItem = class(TCollectionItem)
  private
    procedure SetSymbol(const Value: TSymbol);
  protected
    FQty : Integer;
    FPrice : Double;          // future price - add 2004.10.12 by snike
    FReady : Boolean;

    // first hand object
    FXTerms : TXTerms;

    // second hand object (references)
    FSymbol : TSymbol;
    FSeries : TSpreadSeries;
    FUnderSeries : TSpreadSeries; // used by child
    FIndexSeries : TSpreadSeries;
    FNearest : Boolean;

    // graphic related
    FUseCustomColor : Boolean;
    FColorIndex : Integer;
    FCustomColor : TColor;
    FPenWidth : Integer;

    function GetPenColor : TColor;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    procedure RecalcValue(iPriceIndex : Integer; aRdCalcType : TRdCalcType=rcCalDate); virtual;
    procedure RecalcLastValue(iPriceIndex : Integer; aRdCalcType : TRdCalcType=rcCalDate); virtual;

      // status
    property Qty : Integer read FQty write FQty;
    property Price : Double read FPrice write FPrice;
    property Ready : Boolean read FReady write FReady;

      // created object
    property XTerms : TXTerms read FXTerms;

      // referencing object
    property Symbol : TSymbol read FSymbol write SetSymbol;
    property Series : TSpreadSeries read FSeries write FSeries;
    property UnderSeries : TSpreadSeries read FUnderSeries write FUnderSeries;
    property IndexSeries : TSpreadSeries read FIndexSeries write FIndexSeries;

      // graphic related
    property UseCustomColor : Boolean read FUseCustomColor write FUseCustomColor;
    property ColorIndex : Integer read FColorIndex write FColorIndex;
    property CustomColor : TColor read FCustomColor write FCustomColor;
    property PenWidth : Integer read FPenWidth write FPenWidth;
    property PenColor : TColor read GetPenColor;
  end;

  TSpreadGraphItemClass = class of TSpreadGraphItem;

  TSpreadGraphStore = class(TCollection)
  protected
    function GetItem(i:Integer) : TSpreadGraphItem;
  public
    constructor Create(aItemClass : TSpreadGraphItemClass);

    procedure Invalidate;
    procedure Delete(aSeries : TSpreadSeries);

    property Graphs[i:Integer] : TSpreadGraphItem read GetItem;
  end;


implementation

uses GleLib, GAppEnv;


{ TSpreadStore }

procedure TSpreadSeriesStore.AddFirstLength(dtLast: TDateTime);
var
  i , iLength : Integer;
  aSeries : TSpreadSeries;
  bZeroCount : Boolean;
begin
  bZeroCount := True;
  for i:=0 to Count-1 do
  begin
    aSeries := Items[i] as TSpreadSeries;
    if aSeries.Length <> 0 then
      bZeroCount := False;
  end;

  //All SpreadSeries Must be Zero Count
  if not(bZeroCount) then Exit;

  for i:=0 to Count-1 do
  begin
    aSeries := Items[i] as TSpreadSeries;
    aSeries.Length := aSeries.Length+1;
    iLength := aSeries.Length;
    if iLength = 1 then
    begin
      aSeries[iLength-1].LastTime := dtLast;
      aSeries[iLength-1].MMIndex := GetMMIndex(dtLast);
      aSeries[iLength-1].Value := 0.0;
      aSeries[iLength-1].Source := 0.0;
      aSeries[iLength-1].Defined := False;
    end;
  end;
end;

procedure TSpreadSeriesStore.AddLength(dtLast : TDateTime);
var
  i, iLength : Integer;
  aSeries : TSpreadSeries;
begin
  for i:=0 to Count-1 do
  begin
    aSeries := Items[i] as TSpreadSeries;
    aSeries.Length := aSeries.Length+1;
    iLength := aSeries.Length;

//    gLog.Add(lkDebug, 'addlength', aSeries.Title, IntToStr(aSeries.Length));
      // modifed by CHJ 2003.6.20
    if iLength > 0 then
    begin
      aSeries[iLength-1].LastTime := dtLast;
      aSeries[iLength-1].MMIndex := GetMMIndex(dtLast);
    end;
    if iLength > 1 then
    begin
      aSeries[iLength-1].Value := aSeries[iLength-2].Value;
      aSeries[iLength-1].Source := aSeries[iLength-2].Source;
      aSeries[iLength-1].Defined := aSeries[iLength-2].Defined;
    end;
    //if iLength > 1 then
    //begin
    //  aSeries[iLength-1].LastTime := dtLast;
    //  aSeries[iLength-1].MMIndex := AppTypes.GetMMIndex(dtLast);
    //  aSeries[iLength-1].Value := aSeries[iLength-2].Value;
    //  aSeries[iLength-1].Defined := aSeries[iLength-2].Defined;
    //end;
  end;
end;

{
procedure TSpreadSeriesStore.InsertItemForEachSeries(dtLast : TDateTime;
  iIndex : Integer);
var
  i : Integer;
  aSeries : TSpreadSeries;
  aItem : TSpreadSeriesItem;
begin
  for i := 0 to Count-1 do
  begin
    aSeries := Items[i] as TSpreadSeries;

    aItem := aSeries.InsertItem(iIndex);

    if aItem = nil then break;

    aItem.LastTime := dtLast;
    aItem.MMIndex := AppTypes.GetMMIndex(dtLast);
    aItem.Value := 0.0;
    aItem.Source := 0.0;
    aItem.Defined := False;
  end;
end;
}

function TSpreadSeriesStore.CheckTimeForAdd(dtValue : TDateTime) : Boolean;
var
  dtLast : TDateTime;
begin
  if Count = 0 then
    Result := False
  else
  if GetLength = 0 then
    Result := True
  else
  begin
    dtLast := GetLastTime;

    Result := (Floor(dtValue) > Floor(dtLast)) or // next day
              (GetMMIndex(dtValue) > GetMMIndex(dtLast)); // next period
  end;
end;

function TSpreadSeriesStore.GetLastTime : TDateTime;
var
  aSeries : TSpreadSeries;
begin
  Result := 0.0;

  if Count > 0 then
  begin
    aSeries:= Items[0] as TSpreadSeries; // representative
    if aSeries.Length > 0 then
      Result := aSeries[aSeries.Length-1].LastTime;
  end;
end;

function TSpreadSeriesStore.GetLength : Integer;
var
  aSeries : TSpreadSeries;
begin
  Result := 0;

  if Count > 0 then
  begin
    aSeries:= Items[0] as TSpreadSeries; // representative
    Result := aSeries.Length;
  end;
end;

function TSpreadSeriesStore.AddSeries: TSpreadSeries;
begin
  Result := Add as TSpreadSeries;
end;

procedure TSpreadSeriesStore.ClearData;
var
  i : Integer;
begin
  for i:=0 to Count-1 do
    (Items[i] as TSpreadSeries).Clear;
end;

constructor TSpreadSeriesStore.Create;
begin
  inherited Create(TSpreadSeries);
end;

{ TSpreadSeries }

procedure TSpreadSeries.Clear;
begin
  FItems.Clear;
end;

constructor TSpreadSeries.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FTitle := '';
  FUnitTitle := '';
  FRemark := '';
  FChartBase := cbMin;

  FItems := TCollection.Create(TSpreadSeriesItem);
end;

destructor TSpreadSeries.Destroy;
begin
  FItems.Free;

  inherited;
end;

function TSpreadSeries.GetItem(i: Integer): TSpreadSeriesItem;
begin
  if (i>=0) and (i< FItems.Count) then
    Result := FItems.Items[i] as TSpreadSeriesItem
  else
    Result := nil;
end;

function TSpreadSeries.GetLength: Integer;
begin
  Result := FItems.Count;
end;

procedure TSpreadSeries.GetMinMax(iStart, iEnd: Integer; var dMin,
  dMax: Double);
var
  i : Integer;
  dMn, dMx : Double;
  iCount : Integer;
begin
  dMn := 0.0;
  dMx := 0.0;
  dMin := 0.0;
  dMax := 0.0;
  //
  if (iStart > iEnd) or
     (iStart < 0) or (iStart > Length-1) or
     (iEnd < 0) or (iEnd > Length-1) then Exit;

  iCount := 0;
  for i:=iStart to iEnd do
  with Items[i] as TSpreadSeriesItem do
  if Defined {and (Value > EPSILON)} then
  begin
    if iCount > 0 then
    begin
      dMn := Min(dMn, Value);
      dMx := Max(dMx, Value);
    end else
    begin
      dMn := Value;
      dMx := Value;
    end;
    Inc(iCount);
  end;
  //
  dMin := dMn;
  dMax := dMx;
end;

function TSpreadSeries.DateTimeDesc(iIndex : Integer) : String;
var
  aItem : TSpreadSeriesItem;
begin
  aItem := Items[iIndex];
  Result := '';

  if aItem <> nil then
  case FChartBase of
    cbMonthly :
      Result := FormatDateTime('yyyy"년"mm"월"', aItem.LastTime);
    cbDaily, cbWeekly :
      Result := FormatDateTime('mm"월"dd"일"', aItem.LastTime);
    cbMin :
      Result := FormatDateTime('hh"시"nn"분"', aItem.LastTime);
    cbTick :
      Result := FormatDateTime('hh"시"nn"분"ss"초"', aItem.LastTime);
  end;
end;

procedure TSpreadSeries.SetLength(Value: Integer);
var
  i : Integer;

  procedure AddItem;
  begin
    with FItems.Add as TSpreadSeriesItem do
    begin
      LastTime := 0.0;
      MMIndex := 0;
      Value := 0.0;
      Defined := False;
    end;
  end;
begin
  if Value < 0 then Exit;
  if Value = FItems.Count then Exit;

  if Value = 0 then
    FItems.Clear
  else
  if Value > FItems.Count then
  for i:=0 to Value-FItems.Count-1 do
    AddItem
  else
  if Value < FItems.Count-1 then
  for i:=FItems.Count-1 downto Value do
    FItems.Items[i].Free;
end;

function TSpreadSeries.InsertItem(iIndex : Integer): TSpreadSeriesItem;
begin
  Result := nil;

  if iIndex < 0 then Exit;

  try
    Result := FItems.Insert(iIndex) as TSpreadSeriesItem;
  except
  end;
end;

function TSpreadSeries.DeleteItem(iIndex: Integer): Integer;
begin
  Result := -1;

  if (iIndex < 0) or (iIndex > FItems.Count-1) then Exit;

  try
    FItems.Delete(iIndex);
  except
  end;
  Result := iIndex;
end;



{ TVolGraphITem }

constructor TSpreadGraphItem.Create(aColl: TCollection);
var
  i : Integer;
begin
  inherited Create(aColl);

  FXTerms := TXTerms.Create;
  FReady := False;
  FNearest := True;

end;

destructor TSpreadGraphItem.Destroy;
begin
  FXTerms.Free;

  inherited;
end;

function TSpreadGraphItem.GetPenColor : TColor;
begin
  if UseCustomColor then
    Result := CustomColor
  else
  begin
    Result := SPREAD_COLORS[ColorIndex];
  end;
end;

procedure TSpreadGraphItem.RecalcValue(iPriceIndex : Integer; aRdCalcType : TRdCalcType);
begin
  // should be overrided by child
end;

procedure TSpreadGraphItem.RecalcLastValue(iPriceIndex : Integer; aRdCalcType : TRdCalcType);
begin
  // should be overrided by child
end;



{ TSpreadGraphStore }

constructor TSpreadGraphStore.Create(aItemClass : TSpreadGraphItemClass);
begin
  inherited Create(aItemClass);
end;

procedure TSpreadGraphStore.Delete(aSeries: TSpreadSeries);
var
  i : Integer;
begin
  if aSeries = nil then Exit;

  for i:=0 to Count-1 do
    if Graphs[i].Series = aSeries then
    begin
      Graphs[i].Free;
      Break;
    end;
end;

function TSpreadGraphStore.GetItem(i: Integer): TSpreadGraphItem;
begin
  if (i>=0) and (i<=Count-1) then
    Result := Items[i] as TSpreadGraphItem
  else
    Result := nil;
end;

procedure TSpreadGraphStore.Invalidate;
var
  i : Integer;
begin
  for i:=0 to Count-1 do
    Graphs[i].FReady := False;
end;


function TSpreadSeriesStore.GetTime(i: Integer): TDateTime;
var
  aSeries : TSpreadSeries;
begin
  Result := 0.0;

  if Count >0 then
  begin
    aSeries := Items[0] as TSpreadSeries;
    if (aSeries.Length > i) and (i >= 0) then
      Result := aSeries[i].LastTime;
  end;

end;

procedure TSpreadGraphItem.SetSymbol(const Value: TSymbol);
var
  FOptionMarket : TOptionMarket;
  i : integer;
  aStrike : TStrike;
begin
  FSymbol := Value;

  FOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  FNearest  := false;

  if FOptionMarket <> nil then
    for i := 0 to FOptionMarket.Trees.FrontMonth.Strikes.Count-1 do
    begin
      aStrike := FOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
      if (aStrike.Call = FSymbol) or ( aStrike.Put = FSymbol) then
      begin
        FNearest  := true;
        break;
      end;
    end;

end;

end.
