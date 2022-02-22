unit ChartData;

interface

uses Classes, SysUtils, Math,
     //
     GleTypes, ChartIF, CleSymbols, Ticks,CleDistributor, GleLib,

     CleQuoteTimers
     ;

type

  { Term }
  TTermItem = class(TCollectionItem)
  public
    T : TDateTime;
    MMIndex : Integer; // daily
    O, H, L, C : Double;
    FillVol : Double;
    AccVol : Double;
  end;

  TTerms = class(TCollection)
  private
    function GetTerm(i : Integer) : TTermItem;
  public
    constructor Create;
    //
    procedure Tick(aObj : TObject);
    procedure InsertTerm(dtValue : TDateTime; sO, sH, sL, sC : Double;
        dFillVol, dAccVol : Double);
    procedure DeletePreviousTerm(iRefDate : Integer);
    procedure MakeTodayTerms(iToday : Integer);
    //
    property Data[i:Integer] : TTermItem read GetTerm; default;
  end;

  TChartData = class(TCollectionItem)
  private
    FChartBase : TChartBase;
    FPeriod : Integer;

    FRefCount : Integer;
    FReady : Boolean;
    //
    FTicks : TTicks;
    FTerms : TTerms;
    //
    FNotifyProc : TNotifyEvent;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;
    //
    procedure Refer(aSymbol : TSymbol; cbValue : TChartBase;
      iPeriod, iCount : Integer; ReadyProc : TNotifyEvent);
    procedure Derefer;

    procedure NotifyReady;
    procedure Tick(aTick : TObject);
    //
    function FindTermByMMIndex(iMMIndex : Integer): Integer;
    //
    property ChartBase : TChartBase read FChartBase;
    property Period : Integer read FPeriod;

    property Ready : Boolean read FReady;

    property Ticks : TTicks read FTicks;
    property Terms : TTerms read FTerms;
  end;

implementation


//===============================================================//
                    { TTerms }
//===============================================================//

constructor TTerms.Create;
begin
  inherited Create(TTermItem);
end;

// insert hitory term
procedure TTerms.InsertTerm(dtValue : TDateTime; sO, sH, sL, sC : Double;
    dFillVol, dAccVol : Double);
var
  iMMIndex : Integer;
  aTerm : TTermItem;
  wHH, wNN, wSS, wCC : Word;
begin
  DecodeTime(dtValue, wHH, wNN, wSS, wCC);

  iMMIndex := (wHH - 9) * 60 + wNN;

  if Count > 0 then
    aTerm := Items[0] as TTermItem
  else
    aTerm := nil;
  //
  if (aTerm = nil) or (dtValue < aTerm.T) then
    with Insert(0) as TTermItem do
    begin
      T := dtValue;
      MMIndex := iMMIndex;
      O := sO;
      H := sH;
      L := sL;
      C := sC;
      FillVol := dFillVol;
      AccVol := dAccVol;
    end
  else
  if (Floor(dtValue) = Floor(aTerm.T)) and // same date
     (iMMIndex = aTerm.MMIndex) then // same minute
    with aTerm do
    begin
      O := sO;
      H := Max(H, sH);
      L := Min(L, sL);
      FillVol := FillVol + dFillVol;
    end;
end;

{
// insert hitory term
procedure TTerms.InsertTerm(iDate, iTime : Integer; sO, sH, sL, sC : Single;
    dFillVol, dAccVol : Double);
var
  i, iMMIndex : Integer;
  aTerm : TTermItem;
  wYY, wMM, wDD : Word;
  aTime : TDateTime;
begin
  if (iDate = 0) or (iTime = 0) then Exit;
  // iDate = mmdd
  // iIime = hhmm
  // iMMIndex = how many minutes has passed since 09:00
  //
  iMMIndex := ((iTime div 100) - 9)*60 + (iTime mod 100);
  DecodeDate(Date, wYY, wMM, wDD); // today
  if wMM * 100 + wDD < iDate then // this means last year
    wYY := wYY -1;
  aTime := EncodeDate(wYY, iDate div 100, iDate mod 100) +
           EncodeTime(iTime div 100, iTime mod 100, 0, 0);
  //
  if Count > 0 then
    aTerm := Items[0] as TTermItem
  else
    aTerm := nil;
  //
  if (aTerm = nil) or (aTime < aTerm.T) then
    with Insert(0) as TTermItem do
    begin
      T := aTime;
      MMIndex := iMMIndex;
      O := sO;
      H := sH;
      L := sL;
      C := sC;
      FillVol := dFillVol;
      AccVol := dAccVol;
    end
  else
  if (Floor(aTime) = Floor(aTerm.T)) and // same date
     (iMMIndex = aTerm.MMIndex) then // same minute
    with aTerm do
    begin
      O := sO;
      H := Max(H, sH);
      L := Min(L, sL);
      FillVol := FillVol + dFillVol;
    end;
end;
}

// real-time update
procedure TTerms.Tick(aObj : TObject);
var
  iMMIndex : Integer;
  wHH, wMM, wSS, wCC : Word;
  aTerm : TTermItem;
  aTick : TFillTickItem;
begin
  aTick := aObj as TFillTickItem;
  //
  DecodeTime(aTick.T, wHH, wMM, wSS, wCC);
  iMMIndex := (wHH - 9)*60 + wMM;
  //
  if Count = 0 then
    aTerm := nil
  else
    aTerm := Items[Count-1] as TTermItem;
  //
  if (aTerm = nil) or (aTerm.MMIndex < iMMIndex) then
  with Add as TTermItem do
  begin
    T := Date + EncodeTime(wHH, wMM, 0, 0); // today
    MMIndex := iMMIndex;
    O := aTick.C;
    H := aTick.C;
    L := aTick.C;
    C := aTick.C;
    FillVol := aTick.FillVol;
    AccVol := aTick.AccVol;
  end else
  if (aTerm.MMIndex = iMMIndex) and (aTick.AccVol > aTerm.AccVol) then
  with aTerm do
  begin
    H := Max(H, aTick.C);
    L := Min(L, aTick.C);
    C := aTick.C;
    FillVol := FillVol + aTick.FillVol;
    AccVol := aTick.AccVol;
  end;
end;

function TTerms.GetTerm(i : Integer) : TTermItem;
begin
  if (i>=0) and (i<Count) then
    Result := Items[i] as TTermItem
  else
    Result := nil;
end;


//===============================================================//
                    { TChartData }
//===============================================================//

constructor TChartData.Create;
begin
  FTicks := TTicks.Create;
  FTerms := TTerms.Create;
  //
  FRefCount := 0;
  FReady := False;
end;

destructor TChartData.Destroy;
begin
  FTerms.Free;
  FTicks.Free;

  inherited;
end;

//------------------< tick >-----------------------//

procedure TChartData.Tick(aTick : TObject);
begin
  FTicks.Tick(aTick);
  FTerms.Tick(aTick);
end;

//-----------------< client >----------------------//

procedure TChartData.NotifyReady;
begin
  FReady := True;
  // Add by jaebeom
  FRefCount := 1;
  //
  if FRefCount <= 0 then
    Free
  else
  if Assigned(FNotifyProc) then
    FNotifyProc(Self);
end;

//==============================================================//
//==============================================================//

procedure TChartData.Derefer;
begin
  if FReady then
    Free
  else
    Dec(FRefCount);
end;

procedure TChartData.Refer(aSymbol : TSymbol; cbValue : TChartBase;
  iPeriod, iCount : Integer; ReadyProc: TNotifyEvent);
var
  iMultiple, iMinPeriod : Integer;
begin
  // from here
  FNotifyProc := ReadyProc;

  //
  NotifyReady;

  {if FReady then
    NotifyReady
  else
  begin
    iMinPeriod := gChartIF.GetBase(cbValue, iPeriod);
    iMultiple := iPeriod div iMinPeriod;
    FChartBase := cbValue;
    FPeriod := iMinPeriod;

    gChartIF.GetChart(Self, aSymbol, FChartBase, FPeriod, iCount * iMultiple, 0);

    Inc(FRefCount);
  end;}
end;

function TChartData.FindTermByMMIndex(iMMIndex: Integer): Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to FTerms.Count-1 do
    if FTerms[i].MMIndex = iMMIndex then
    begin
      Result := i;
      break;
    end else if FTerms[i].MMIndex > iMMIndex then
      break;
end;

procedure TTerms.DeletePreviousTerm(iRefDate: Integer);
var
  i : Integer;
begin
  for i := Count-1 downto 0 do
    if Data[i].T < iRefDate then
      Delete(i);
end;

procedure TTerms.MakeTodayTerms(iToday: Integer);
var
  i, iMMIndex : Integer;
begin
  iMMIndex := -1;

  if Count > 0 then
  begin
    iMMIndex := Data[0].MMIndex;
  end;

  for i := iMMIndex-1 downto 0 do
    InsertTerm(Floor(GetQuoteDate) + GetTimeByMMIndex(i),
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

end;

end.
