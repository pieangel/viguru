unit CleKeyGen;

interface

uses
  Classes, SysUtils;

type
  TKeyGenerator = class
  private
    FKey: Integer;
  public
    constructor Create;

    function Issue: Integer;
  end;

implementation

{ TKeyGenerator }

constructor TKeyGenerator.Create;
begin
  FKey := 0;
end;

function TKeyGenerator.Issue: Integer;
var
  iNewKey: Integer;
begin
  iNewKey := Round(Now * 1000);
  if iNewKey <= FKey then
    FKey := FKey + 1
  else
    FKey := iNewKey;

  Result := FKey;
end;

end.
