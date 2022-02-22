unit CleTickRatio;

interface

uses
  Classes, SysUtils, Windows;
type


  TTickThread = class(TThread)
  private
    { Private declarations }
    FInterval : integer;
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    procedure SetTimer( iGap : integer );
  end;


implementation

uses GAppEnv;


{ TTickThread }

constructor TTickThread.Create;
begin
  Inherited Create(true);
  Priority  := tpNormal;
  FInterval := 1000;
  FreeOnTerminate := True;
end;

destructor TTickThread.Destroy;
begin
  inherited;
end;

procedure TTickThread.Execute;
begin
  while not Terminated do begin
    WaitForSingleObject(Handle, 1000);
    // to do
    gEnv.Engine.QuoteBroker.CalcAllTickRatio;
  end;
end;

procedure TTickThread.SetTimer(iGap: integer);
begin
  if iGap > 0 then
    FInterval := iGap;
end;

end.
