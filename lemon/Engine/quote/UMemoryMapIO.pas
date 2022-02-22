unit UMemoryMapIO;

interface

uses
  Windows, SysUtils, Classes;

type

  TMemoryMapIO = class
  private
    FFileHandle: THandle;
    FMapHandle: THandle;
    FIoFile: string;
  public
    constructor Create;
    Destructor Destroy ; override;

    function CreateMemoryMapIO( var iStep: integer; stFile : string ) : PChar;
    procedure Clear;
    // handle
    property FileHandle : THandle read FFileHandle;
    property MapHandle  : THandle read FMapHandle;

    property IoFile     : string read FIoFile;

  end;

implementation

{ TMemoryMapIO }

procedure TMemoryMapIO.Clear;
begin
  FIoFile := '';
  CloseHandle( FMapHandle );
  CloseHandle( FFileHandle );
  FFileHandle := INVALID_HANDLE_VALUE;
  FMapHandle  := INVALID_HANDLE_VALUE;
end;

constructor TMemoryMapIO.Create;
begin
  FFileHandle := INVALID_HANDLE_VALUE;
  FMapHandle  := INVALID_HANDLE_VALUE;
end;

function TMemoryMapIO.CreateMemoryMapIO(var iStep: integer; stFile: string): PChar;
var
  dwSize : DWORD;
begin
  result := nil;

  // 1 . 파일 유무 체크
  if stFile = '' then
  begin
    iStep := 1;
    Exit;
  end;
  FIoFile := stFile;
  if not FileExists( FIoFile ) then
    Exit;

  // 2. 파일 핸들 얻는다.
  FFileHandle :=
  CreateFile( PChar(FIoFile), GENERIC_READ, 0,
          nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,
          0);
  if FFileHandle = INVALID_HANDLE_VALUE then
  begin
    iStep := 2;
    Exit;
  end;
  dwSize  := GetFileSize( FFileHandle, nil );

  // 3. 메모리맵 생성
  FMapHandle  :=
  CreateFileMapping(FFileHandle, nil , PAGE_READONLY, 0, dwSize, nil);
  if FMapHandle = INVALID_HANDLE_VALUE then
  begin
    iStep := 3;
    Exit;
  end;

  // 4. 매모립맵 과 파일 연결
  Result :=
  PChar( MapViewOfFile( FMapHandle, FILE_MAP_READ, 0, 0, dwSize));
  if Result = nil then
  begin
    iStep := 4;
    Exit;
  end;

end;

destructor TMemoryMapIO.Destroy;
begin
  CloseHandle( FMapHandle );
  CloseHandle( FFileHandle );
  inherited;
end;

end.
