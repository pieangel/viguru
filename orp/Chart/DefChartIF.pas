unit DefChartIF;

interface

uses
  Classes, ChartIF, CleSymbols;
  
type
  TDefaultChartIF = class(TChartIF)
  protected
  public
    procedure Clear; override;
    procedure Initialize; override;
    procedure Finalize; override;
    // check possible chart base unit
    function Enabled(cbValue : TChartBase) : Boolean; override;
    // check possible base period
    function GetBase(cbValue : TChartBase; iPeriod : Integer) : Integer; override;
    //
    function GetChart(Receiver : TObject; aSymbol : TSymbol;
      cbValue : TChartBase; iPeriod : Integer; iCount : Integer;
      dtStart : TDateTime) : Boolean; override;
    //
    function GetEtcChart(Receiver : TObject; aSymbol : TSymbol;
      cbValue : TChartBase; iPeriod, iCount,
      iChartType : Integer) : Boolean; override;
    //
    function GetTrend(Receiver : TObject):Boolean; override;

    function GetProgChart(Receiver : TObject; aProc: TNotifyEvent):Boolean; override;

    procedure ReleaseChart(aObj : TObject); override;
  end;

implementation

{ TChartIF }

procedure TDefaultChartIF.Clear;
begin
  inherited;

end;

function TDefaultChartIF.Enabled(cbValue: TChartBase): Boolean;
begin
  Result := True;
end;

procedure TDefaultChartIF.Finalize;
begin
  inherited;

end;

function TDefaultChartIF.GetBase(cbValue: TChartBase; iPeriod: Integer): Integer;
begin

end;

function TDefaultChartIF.GetChart(Receiver: TObject; aSymbol: TSymbol;
  cbValue: TChartBase; iPeriod, iCount: Integer; dtStart: TDateTime): Boolean;
begin
  Result := True;
end;

function TDefaultChartIF.GetEtcChart(Receiver: TObject; aSymbol: TSymbol;
  cbValue: TChartBase; iPeriod, iCount, iChartType: Integer): Boolean;
begin
  Result := True;
end;

function TDefaultChartIF.GetProgChart(Receiver: TObject; aProc: TNotifyEvent): Boolean;
begin
  Result := True;
end;

function TDefaultChartIF.GetTrend(Receiver: TObject): Boolean;
begin
  Result := True;
end;

procedure TDefaultChartIF.Initialize;
begin
  inherited;

end;

procedure TDefaultChartIF.ReleaseChart(aObj: TObject);
begin
  inherited;

end;

end.
