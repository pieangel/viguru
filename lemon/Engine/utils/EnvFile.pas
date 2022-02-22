unit EnvFile;

interface

uses Classes, SysUtils;

type
  TEnvFile = class
  protected
    FLines : TStringList;
    FStream : TMemoryStream;
  public
    constructor Create;
    destructor Destroy; override;

    function Exists(stFile : String) : Boolean;
    function Delete(stFile : String) : Boolean;

    function LoadLines(stFile : String) : Boolean;
    function SaveLines(stFile : String) : Boolean; 
    function LoadStream(stFile : String) : Boolean;
    function SaveStream(stFile : String) : Boolean;

    property Lines : TStringList read FLines;
    property Stream : TMemoryStream read FStream;
  end;

implementation

uses GAppEnv, EnvUtil;

constructor TEnvFile.Create;
begin
  FLines := TStringList.Create;
  FStream := TMemoryStream.Create;
end;

destructor TEnvFile.Destroy;
begin
  FLines.Free;
  FStream.Free;

  inherited;
end;

function TEnvFile.Exists(stFile : String) : Boolean;
begin
  Result := FileExists(gEnv.RootDir + stFile);
end;

function TEnvFile.Delete(stFile : String) : Boolean;
begin
  Result := DeleteFile(gEnv.RootDir + stFile);
end;

function TEnvFile.LoadLines(stFile : String) : Boolean;
begin
  FLines.Clear;
  Result := EnvRead(gEnv.RootDir + stFile, FLines);
end;

function TEnvFile.SaveLines(stFile : String) : Boolean;
begin
  Result := EnvWrite(gEnv.RootDir + stFile, FLines);
end;

function TEnvFile.LoadStream(stFile : String) : Boolean;
var
  aStrStream : TStringStream;
begin
  Result := False;
  if not Exists(stFile) then Exit;
  //
  aStrStream := TStringStream.Create('');
  try
    FLines.Clear;
    FStream.Clear;
    Result := LoadLines(stFile);
    if Result and (FLines.Count > 0) then
    begin
      aStrStream.WriteString(FLines[0]);
      FStream.LoadFromStream(aStrStream);
    end;
  finally
    aStrStream.Free;
  end;
end;

function TEnvFile.SaveStream(stFile : String) : Boolean;
var
  aStrStream : TStringStream;
begin
  aStrStream := TStringStream.Create('');
  try
    try
      FStream.SaveToStream(aStrStream);
      FLines.Clear;
      FLines.Add(aStrStream.DataString);
      Result := SaveLines(stFile);
    except
      Result := False;
    end;
  finally
    aStrStream.Free;
  end;
end;

end.
