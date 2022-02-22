unit TimeSpeeds;

interface

uses
  Classes, Windows, SysUtils

  ;

type

  TTimeSpeed  = class
  private
    FFrequency: LONGLONG;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function GetBlockSpeed( llPrev , llNow : LONGLONG ) : double;
    function GetBlockUltraSpeed( llPrev, llNow : LONGLONG ) : double; 
    procedure GetNowTime( var llTmp : LONGLONG );

    property    Frequency : LONGLONG read FFrequency write FFrequency;
  end;


implementation

{ TTimeSpeed }

constructor TTimeSpeed.Create;
var
  liTmp : int64;
begin
  QueryPerformanceFrequency(liTmp);
  FFrequency := LARGE_INTEGER(liTmp).QuadPart;
end;

destructor TTimeSpeed.Destroy;
begin

  inherited;
end;

procedure TTimeSpeed.GetNowTime(var llTmp: LONGLONG);
begin
  QueryPerformanceCounter( llTmp  );
end;

function TTimeSpeed.GetBlockSpeed(llPrev, llNow: LONGLONG): double;
begin
  Result := ((llNow - llPrev ) / FFrequency ) * 1000;
end;

function TTimeSpeed.GetBlockUltraSpeed(llPrev, llNow: LONGLONG): double;
begin
  Result := ((llNow - llPrev ) / FFrequency );
end;

end.
