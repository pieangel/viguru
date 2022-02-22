unit CleTickRatioControls;

interface

uses
  Classes, SysUtils,
  CleTickRatio
  ;

type

  TTickRatioControls  = class
  private
    FTickThread : TTickThread;
  public
    BTickThread : boolean;
    constructor Create;
    destructor Destroy; override;

    procedure SetThreadInterval( iInterval : integer );
    procedure Start;
    procedure Stop;
  end;

implementation

uses GAppEnv;

{ TTickRatioControls }

constructor TTickRatioControls.Create;
begin
  FTickThread := TTickThread.Create;
  //FTickThread.Suspend;
end;

destructor TTickRatioControls.Destroy;
begin

  if FTickThread <> nil then begin
    FTickThread.Suspend;
    FTickThread.Terminate;
  end;

  inherited;
end;


procedure TTickRatioControls.SetThreadInterval(iInterval: integer);
begin
  FTickThread.Suspend;
  FTickThread.SetTimer( iInterval );
  FTickThread.Resume;
end;

procedure TTickRatioControls.Start;
begin
  FTickThread.Resume;
  BTickThread := true;
end;

procedure TTickRatioControls.Stop;
begin
  if FTickThread.Suspended then
    Exit;
  FTickThread.Suspend;
  BTickThread := false;
end;

end.
