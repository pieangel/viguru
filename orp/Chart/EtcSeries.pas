unit EtcSeries;

interface

uses
  Classes, Sysutils, Math,

  CleSymbols, CleDistributor, GleTypes,  GleLib ,

  CleQuoteTimers,  ClePositions,

  ChartIF, ChartData;

type

  TEtcSeriesItem = class(TCollectionItem)
  public
    T : TDateTime;
    //-- 04/04/12 inserted
    MMIndex : Integer;
    Value : Double;
  end;

  TEtcSeries = class(TCollection)
  private
    FSymbol : TSymbol;

    FReady : Boolean;

    FTerms : TCollection;
    FTicks : TCollection;

    FOnReady : TNotifyEvent;
    FOnUpdate: TNotifyEvent;
    FPosition: TPosition;

    procedure NewTick(T: TDateTime; Value : Double);

    function GetEtcSeriesItem(i: Integer): TEtcSeriesItem;
    function GetTickCount: Integer;
    function GetTick(i: Integer): TEtcSeriesItem;
    function GetTerm(i: Integer): TEtcSeriesItem;
    function GetTermCount: Integer;

  public

    //Manage Data
    function AddData: TEtcSeriesItem;
    function AddTick: TEtcSeriesItem;
    procedure InsertTerm(dtTime : TDateTime ; dValue : Double);
    procedure ClearData;
    procedure ClearTicks;
    procedure ClearTerms;
    procedure Reset;
    procedure MakeTermMMIndex;

    procedure DeleteTerm(i : Integer); overload;
    procedure DeleteTerm(aTerm : TEtcSeriesItem); overload;

    function FindData(T: TDateTime; cbValue : TChartBase;
                  iPeriod : Integer): TEtcSeriesItem;
    function FindTerm(dtTime : TDateTime; cbValue : TChartBase;
                  iPeriod : Integer) : TEtcSeriesItem;
    function FindTermByMMIndex(iMMIndex: Integer) : Integer;
    procedure MakeTodayTerms(iToday : Integer);

    //notify
    procedure NotifyReady;

    constructor Create(ItemClass : TCollectionItemClass);
    destructor Destroy;override;

    property OnReady : TNotifyEvent read FOnReady write FOnReady;
    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;

    property Datas[i:Integer]:TEtcSeriesItem read GetEtcSeriesItem;default;
    property Terms[i:Integer]:TEtcSeriesItem read GetTerm;
    property Ticks[i:Integer]:TEtcSeriesItem read GetTick;

    property Symbol : TSymbol read FSymbol write FSymbol;
    property Position : TPosition read FPosition write FPosition;
    property Ready : Boolean read FReady write FReady;

    property TickCount : Integer read GetTickCount;
    property TermCount : Integer read GetTermCount;

  end;

implementation

{ TEtcSeries }

function TEtcSeries.AddData: TEtcSeriesItem;
begin
  Result := TEtcSeriesItem(Add);
  Result.Value := 0;
end;

procedure TEtcSeries.Reset;
begin
  FReady := False;
  Clear;
  FTerms.Clear;
  FTicks.Clear;
end;

constructor TEtcSeries.Create(ItemClass : TCollectionItemClass);
begin
  inherited Create(ItemClass);

  FReady := False;

  FTerms := TCollection.Create(TEtcSeriesItem);
  FTicks := TCollection.Create(TEtcSeriesItem);
end;

procedure TEtcSeries.ClearData;
begin
  Clear;
end;

destructor TEtcSeries.Destroy;
begin
  FTerms.Free;
  FTicks.Free;

  //if FSymbol <> nil then
  //  FSymbol.Unsubscribe(Self);

  inherited;
end;

function TEtcSeries.FindData(T: TDateTime; cbValue : TChartBase;
  iPeriod : Integer): TEtcSeriesItem;
var
  i : Integer;
  aData : TEtcSeriesItem;
  bFind : Boolean;
  wHH, wNN, wSS, wCC, wHH1, wNN1, wSS1, wCC1 : Word;
begin
  Result := nil;
  DecodeTime(T, wHH, wNN, wSS, wCC);

  for i := 0 to Count-1 do
  begin
    aData := Items[i] as TEtcSeriesItem;
    bFind := False;

    if (Floor(aData.T) = Floor(T)) then
    begin
      if (cbValue in [cbDaily, cbWeekly, cbMonthly]) then bFind := True
      else if (cbValue = cbMin) and
        ((GetMMIndex(aData.T) div iPeriod) = (GetMMIndex(T) div iPeriod)) then
        bFind := True
      else if (cbValue = cbTick) then
      begin
        DecodeTime(aData.T, wHH1, wNN1, wSS1, wCC1);
        if (wHH = wHH1) and (wNN = wNN1) then bFind := True;
      end;

      if bFind then
      begin
        Result := aData;
        break;
      end;

    end;
  end;
  {
  for i := 0 to Count-1 do
    if IsZero(Datas[i].T - T) then
    begin
      Result := Datas[i];
      break;
    end;
  }
end;

//
// (public) Request an Etc ChartData to a ChartIF
//

function TEtcSeries.GetEtcSeriesItem(i: Integer): TEtcSeriesItem;
begin
  Result := nil;

  if (i >= 0) and (i < Count) then
    Result := TEtcSeriesItem(Items[i]);
end;


procedure TEtcSeries.InsertTerm(dtTime: TDateTime; dValue: Double);
var
  aTerm : TEtcSeriesItem;
begin
  if FTerms.Count > 0 then
    aTerm := FTerms.Items[0] as TEtcSeriesItem
  else
    aTerm := nil;

  if (aTerm = nil) or (dtTime < aTerm.T) then
  with FTerms.Insert(0) as TEtcSeriesItem do
  begin
    T := dtTime;
    Value := dValue;
  end;

end;

procedure TEtcSeries.NewTick(T: TDateTime; Value: Double);
var
  aEtcItem : TEtcSeriesItem;

begin
  if Count <= 0 then Exit;

  aEtcItem := Datas[Count-1] as TEtcSeriesItem;

  aEtcItem.Value := Value;

  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
  {
  if IsZero(aEtcItem.T-T) then
  begin
    aEtcItem.Value := Value;
  end;
  }
end;

procedure TEtcSeries.NotifyReady;
begin
  //TyChartIF -> Self
  FReady := True;
  if Assigned(FOnReady) then
    FOnReady(Self);
end;

function TEtcSeries.FindTerm(dtTime: TDateTime; cbValue : TChartBase;
  iPeriod : Integer): TEtcSeriesItem;
var
  i, iMMIndex : Integer;
  aTerm : TEtcSeriesItem;
  wHH, wNN, wSS, wCC, wHH1, wNN1, wSS1, wCC1 : Word;
  bFind : Boolean;
begin
  Result := nil;

  for i := FTerms.Count-1 downto 0 do
  //for i := 0 to FTerms.Count-1 do
  begin
    aTerm := FTerms.Items[i] as TEtcSeriesItem;
    bFind := False;

    if (Floor(aTerm.T) = Floor(dtTime)) then
    begin
      if (cbValue in [cbDaily, cbWeekly, cbMonthly]) then bFind := True
      else if ((GetMMIndex(aTerm.T) div iPeriod) =
            (GetMMIndex(dtTime) div iPeriod)) then bFind := True;

      if bFind then
      begin
        Result := FTerms.Items[i] as TEtcSeriesItem;
{$ifdef Debug}
//      gLog.Add(lkDebug, 'Find',IntToStr(i),FormatDateTime('HH:NN',Result.T));
{$endif}
        break;
      end;
    end;
  end;

  (*
  DecodeTime(dtTime, wHH, wNN, wSS, wCC);

  Result := nil;
  for i := 0 to FTerms.Count-1 do
  begin
    aTerm := FTerms.Items[i] as TEtcSeriesItem;

    if Floor(aTerm.T) = Floor(dtTime) then
    begin
      DecodeTime(aTerm.T, wHH1, wNN1, wSS1, wCC1);
      if (wHH = wHH1) and (wNN = wNN1) then
      begin
        Result := FTerms.Items[i] as TEtcSeriesItem;
        break;
      end;
    end;

    {
    if IsZero(aTerm.T - dtTime) then
    begin
      Result := FTerms.Items[i] as TEtcSeriesItem;
      break;
    end;
    }
  end;
  *)
end;

function TEtcSeries.GetTickCount: Integer;
begin
  Result := FTicks.Count;
end;

function TEtcSeries.GetTick(i: Integer): TEtcSeriesItem;
begin
  Result := TEtcSeriesItem(FTicks.Items[i]);
end;

function TEtcSeries.GetTerm(i: Integer): TEtcSeriesItem;
begin
  if (i < 0) or (i > FTerms.Count-1) then Result := nil;

  Result := FTerms.Items[i] as TEtcSeriesItem;
end;


function TEtcSeries.AddTick: TEtcSeriesItem;
begin
  Result := TEtcSeriesItem(FTicks.Add);
end;

procedure TEtcSeries.ClearTicks;
begin
  FTicks.Clear;
end;

procedure TEtcSeries.DeleteTerm(aTerm: TEtcSeriesItem);
begin
  if aTerm.Index < 0 then Exit;
  FTerms.Delete(aTerm.Index);
end;

procedure TEtcSeries.MakeTermMMIndex;
var
  i : Integer;
begin
  for i := 0 to FTerms.Count-1 do
    TEtcSeriesItem(FTerms.Items[i]).MMIndex :=
      GetMMIndex(TEtcSeriesItem(FTerms.Items[i]).T);

end;

function TEtcSeries.FindTermByMMIndex(iMMIndex: Integer): Integer;
var
  i : Integer;
  aItem : TEtcSeriesItem;
begin
  Result := -1;
  for i := 0 to FTerms.Count-1 do
  begin
    aItem := FTerms.Items[i] as TEtcSeriesItem;
    if aItem.MMIndex = iMMIndex then
    begin
      Result := i;
      break;
    end
    else if aItem.MMIndex > iMMIndex then
      break;
  end;

end;


function TEtcSeries.GetTermCount: Integer;
begin
  Result := FTerms.Count;
end;

procedure TEtcSeries.DeleteTerm(i: Integer);
begin
  FTerms.Delete(i);
end;

procedure TEtcSeries.ClearTerms;
begin
  FTerms.Clear;
end;

procedure TEtcSeries.MakeTodayTerms(iToday: Integer);
var
  i, iMMIndex : Integer;
begin
  //-- delete before day
  for i := TermCount-1 downto 0 do
    if Terms[i].T < iToday then
      FTerms.Delete(i);

  //--
  if FTerms.Count > 0 then
  begin
    iMMIndex := GetMMIndex((FTerms.Items[0] as TEtcSeriesItem).T);

    for i := iMMIndex-1 downto 0 do
      InsertTerm(Floor(GetQuoteDate) + GetTimeByMMIndex(i), 0.0);
  end;
end;

end.
