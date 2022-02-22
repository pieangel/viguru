unit CleQuoteTimers;

interface

uses
  Classes, SysUtils, ExtCtrls,

  uCpuUsage;

type
  TQuoteTimer = class(TCollectionItem)
  private
    FEnabled: Boolean;
    FInterval: Integer; // miliseconds
    FIntervalMili: Double;

    FOnTimer: TNotifyEvent;

    FLastEventTime: TDateTime;
    FTime: TDateTime;

    procedure SetTime(const Value: TDateTime);
    procedure SetEnabled(const Value: Boolean);
    procedure SetInterval(const Value: Integer);
  public
    
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Interval: Integer read FInterval write SetInterval;
    property Time: TDateTime read FTime write SetTime;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
  end;

  TQuoteTimers = class(TCollection)
  private
    FTimer: TTimer;

    FQuoteTime: TDateTime;
    FLastFeedTime: TDateTime;
    FCpuUsage: Single;
    FCpuData: PCPUUsageData;
    FCpuRatio: single;

    function GetRealtime: Boolean;
    procedure SetRealtime(const Value: Boolean);

    procedure TimerProc(Sender: TObject);
    function GetNow: TDateTime;
    function GetCpuUsage: Single;
    function GetSysTime: TDateTime;


  public
    constructor Create;
    destructor Destroy; override;
    procedure DeleteTimer( aTimer : TQuoteTimer );

    function New: TQuoteTimer;
    procedure CalcCpuUsage;

    procedure Feed(const Value: TDateTime);
    procedure Reset(const Value: TDateTime);

    property Now: TDateTime read GetNow;
    property Realtime: Boolean read GetRealtime write SetRealtime;
    property CpuUsage : Single read GetCpuUsage;
    property CpuData  : PCPUUsageData read FCpuData write FCpuData;
    property CpuRatio : single read FCpuRatio;
  end;

function GetQuoteTime: TDateTime;
function GetQuoteDate: TDateTime;


implementation

uses GAppEnv;

const
  MILI_SECOND = 1/(24*60*60*1000);

//============================================================================//  
                             { TQuoteTimer }

procedure TQuoteTimer.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TQuoteTimer.SetInterval(const Value: Integer);
begin
  FInterval := Value;
  FIntervalMili := Value * MILI_SECOND;
end;



procedure TQuoteTimer.SetTime(const Value: TDateTime);
begin
  FTime := Value;

  if FEnabled
     and (Value - FLastEventTime > FIntervalMili)
     and Assigned(FOnTimer) then
  begin
    FOnTimer(Self);
    FLastEventTime := Value;
  end;
end;

//============================================================================//
                              { TQuoteTimers }

//---------------------------------------------------------------------< init >

procedure TQuoteTimers.CalcCpuUsage;
begin
  FCpuUsage := wsGetCpuUsage(FCpuData);
end;

constructor TQuoteTimers.Create;
begin
  inherited Create(TQuoteTimer);

    // create timer
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 10; // 10 milli second
  FTimer.OnTimer := TimerProc;

  FCpuData := wsCreateUsageCounter( gEnv.AppPid );

    // time stamp
  Reset(SysUtils.Now);
end;

procedure TQuoteTimers.DeleteTimer(aTimer: TQuoteTimer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if aTimer = Items[i] as TQuoteTimer then
    begin
      Delete(i);
      break;
    end;
end;

destructor TQuoteTimers.Destroy;
begin
  FTimer.Free;

  inherited;
end;

//------------------------------------------------------------------< control >

function TQuoteTimers.GetRealtime: Boolean;
begin
  Result := FTimer.Enabled;
end;

function TQuoteTimers.GetSysTime: TDateTime;
begin
  if gEnv.RunMode = rtSimulation then
    Result := FLastFeedTime
  else Result := SysUtils.Now;
end;

procedure TQuoteTimers.SetRealtime(const Value: Boolean);
begin
  FTimer.Enabled := Value;
end;

//---------------------------------------------------------------------< new >

function TQuoteTimers.New: TQuoteTimer;
begin
  Result := Add as TQuoteTimer;

    // default values, subject to change
  Result.Enabled := False;
  Result.Interval := 1000; // 1 sec

    // set starting time
  Result.FLastEventTime := GetNow;
end;

//--------------------------------------------------------------------< reset >

procedure TQuoteTimers.Reset(const Value: TDateTime);
var
  i: Integer;
  aTimer: TQuoteTimer;
  stDate : string;
begin
  FQuoteTime := Value;

  stDate := FormatDateTime('yyyy-mm-dd', FQuoteTime);
  FLastFeedTime := SysUtils.Now;

  for i := 0 to Count - 1 do
  begin
    aTimer := Items[i] as TQuoteTimer;
    aTimer.FTime := Value;
    aTimer.FLastEventTime := Value;
  end;
end;

//---------------------------------------------------------------------< feed >

procedure TQuoteTimers.TimerProc(Sender: TObject);
begin
  Feed(Self.Now);
end;

procedure TQuoteTimers.Feed(const Value: TDateTime);
var
  i: Integer;
begin
  FQuoteTime := Value;
  FLastFeedTime := SysUtils.Now; // time stamp

  for i := 0 to Count - 1 do
    (Items[i] as TQuoteTimer).Time := Value;
end;
//---------------------------------------------------------------------< now >


function TQuoteTimers.GetCpuUsage: Single;
begin
  FCpuRatio := wsGetCpuUsage(FCpuData);
  if FCpuRatio > 6 then
    FCpuRatio := FCpuRatio -2;
  Result := FCpuRatio;
end;

function TQuoteTimers.GetNow: TDateTime;
begin
  Result := FQuoteTime + GetSysTime - FLastFeedTime;
end;


function GetQuoteTime: TDateTime;
begin
  if gEnv.RunMode = rtSimulation then
    Result := gEnv.Engine.QuoteBroker.Timers.Now
  else
    Result := Now;
end;

function GetQuoteDate: TDateTime;
begin
  if gEnv.RunMode = rtSimulation then
    Result := GetQuoteTime-Frac(GetQuoteTime)
  else
    Result := Date();

end;


end.
