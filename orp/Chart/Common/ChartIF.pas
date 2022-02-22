unit ChartIF;

interface

uses
  Classes,
  //
  CleSymbols;

{
const
  CID_AccTrends = 221;
  CID_Monthly   = 222;
  CID_Weekly    = 223;
  CID_Daily     = 224;
  CID_Term      = 225;
  CID_Tick      = 226;
}
const
  DAY_OFFSET = 25569; // 70 yrs
  HOUR_OFFSET = 3600/86400*9; // 9 hours
  CHART_NA_VALUE = -199999999;

type
  TChartBase = (cbTick, cbMin, cbDaily, cbWeekly, cbMonthly, cbQuote);

  TChartIF = class
  protected
  public
    procedure Clear; virtual; abstract;
    procedure Initialize; virtual; abstract;
    procedure Finalize; virtual; abstract;
    // check possible chart base unit
    function Enabled(cbValue : TChartBase) : Boolean; virtual; abstract;
    // check possible base period
    function GetBase(cbValue : TChartBase; iPeriod : Integer) : Integer; virtual; abstract;
    //
    function GetChart(Receiver : TObject; aSymbol : TSymbol;
      cbValue : TChartBase; iPeriod : Integer; iCount : Integer;
      dtStart : TDateTime) : Boolean; virtual; abstract;
    //
    function GetEtcChart(Receiver : TObject; aSymbol : TSymbol;
      cbValue : TChartBase; iPeriod, iCount,
      iChartType : Integer) : Boolean; virtual; abstract;
    //
    function GetTrend(Receiver : TObject):Boolean; virtual; abstract;

    function GetProgChart(Receiver : TObject; aProc: TNotifyEvent):Boolean; virtual; abstract;

    procedure ReleaseChart(aObj : TObject);virtual;abstract;
  end;

var
  gChartIF : TChartIF;

implementation

end.
