unit EnvUtil;

interface

uses Classes, SysUtils, Math;

function EnvXOR(szDest, szSrc : PChar; iSize : Integer) : PChar;
function EnvRead(stFile : String; aList : TStrings) : Boolean;
function EnvWrite(stFile : String; aList : TStrings) : Boolean;


procedure utDecodeFlat( var szMsg; iSize: integer );
procedure utEncodeFlat( var szMsg; iSize: integer );

implementation

uses SynthUtil, CryptInt;

const
  ENV_KEY : Byte = $EF;
  MAX_BUFFER = 10240;

function EnvXOR(szDest, szSrc : PChar; iSize : Integer) : PChar;
var
  i : integer;
begin
  // do XOR
  for i:=0 to iSize-1 do
    szDest[i] := Chr(Ord(szSrc[i]) xor ENV_KEY);
  //
  Result := szDest;
end;

function EnvRead(stFile : String; aList : TStrings) : Boolean;
var
  aFileStream : TFileStream;
  szBuffer : array[0..MAX_BUFFER] of Char;
  iP, iBytesRead, iDataLen: Integer;
  lSize : LongInt;
  stData, stValue : String;
begin
  Result := False;
  //
  if not FileExists(stFile) or (aList = nil) then Exit; // Full Path
  //
  try
    aFileStream := nil;
    aFileStream := TFileStream.Create(stFile, fmOpenRead);

    while aFileStream.Position < aFileStream.Size-1 do
    begin
      //--1. get size
      iBytesRead := aFileStream.Read(szBuffer, 4); // size
      if iBytesRead < 4 then // end of file
        Break;

      EnvXOR(szBuffer, szBuffer, 4);
      iP := 0;
      DeconvertLong(szBuffer, iP, lSize);
      if lSize < 0 then // fatal error
        Exit;

      //--2. get data
      stData := ''; iDataLen := 0;
      while iDataLen < lSize do
      begin
        iBytesRead := aFileStream.Read(szBuffer, Min(MAX_BUFFER, lSize-iDataLen));
        if iBytesRead = 0 then
          Break;
        EnvXOR(szBuffer, szBuffer, iBytesRead);
        iP := 0;
        DeconvertBytes(szBuffer, iP, stValue, iBytesRead);
        stData := stData + stValue;
        iDataLen := iDataLen + iBytesRead;
      end;

      //--3. register data
      aList.Add(stData);
    end;

    Result := True;
  finally
    if aFileStream <> nil then
      aFileStream.Free;
  end;
end;

{
function EnvRead(stFile : String; aList : TStrings) : Boolean;
var
  iFileHandle : Integer;
  iFileLength: Integer;
  iBytesRead: Integer;
  szBuffer : array[0..50000] of Char;

  iP : Integer;
  lSize : LongInt;
  stValue : String;
begin
  Result := False;
  iFileHandle := -1;
  //
  if not FileExists(stFile) or (aList = nil) then Exit; // Full Path
  //
  try
    // load all data into memory
    iFileHandle := FileOpen(stFile, fmOpenRead);
    iFileLength := FileSeek(iFileHandle,0,2);
    FileSeek(iFileHandle,0,0);

    iBytesRead := FileRead(iFileHandle, szBuffer, iFileLength);
  finally
    if iFileHandle > -1 then
      FileClose(iFileHandle);
  end;

  //
  try
    // do XOR
    EnvXOR(szBuffer, szBuffer, iBytesRead);
    //
    iP := 0;
    while (iP <= iFileLength-4) do
    begin
      DeconvertLong(szBuffer, iP, lSize);
      DeconvertBytes(szBuffer, iP, stValue, lSize);
      aList.Add(stValue);
    end;
    //
    Result := True;
  finally
    //
  end;
end;
}

function EnvWrite(stFile : String; aList : TStrings) : Boolean;
var
  iFileHandle: Integer;
  szBuffer : array[0..MAX_BUFFER] of Char;
  i, iP : Integer;
begin
  Result := False;
  //
  if aList = nil then Exit;
  //
  if FileExists(stFile) then
    DeleteFile(stFile);

  //
  iFileHandle := FileCreate(stFile);
  if iFileHandle = -1 then Exit;
  //
  try
    for i:=0 to aList.Count - 1 do
    begin
      iP := 0;
      ConvertLong(szBuffer, iP, Length(aList.Strings[i]));
      ConvertBytes(szBuffer, iP, aList.Strings[i]);
      EnvXOR(szBuffer, szBuffer, iP);
      FileWrite(iFileHandle, szBuffer, iP);
    end;
    //
    Result := True;
  finally
    FileClose(iFileHandle);
  end;
end;


procedure utEncodeFlat( var szMsg; iSize: integer );
begin
  asm
    push esi
    push edi
    mov esi, eax
    mov ecx, edx
    cmp ecx, 0
    je  @@doexit
  @@dowork:
    dec ecx
    mov al, [esi+ecx]
    ror al, 5
    mov [esi+ecx], al
    cmp ecx, 0
    ja @@dowork
  @@doexit:
    pop edi
    pop esi
  end;
end;

procedure utDecodeFlat( var szMsg; iSize: integer );
begin
  asm
    push esi
    push edi
    mov esi, eax
    mov ecx, edx
    cmp ecx, 0
    je  @@doexit
  @@dowork:
    dec ecx
    mov al, [esi+ecx]
    rol al, 5
    mov [esi+ecx], al
    cmp ecx, 0
    ja @@dowork
  @@doexit:
    pop edi
    pop esi
  end;
end;

end.
