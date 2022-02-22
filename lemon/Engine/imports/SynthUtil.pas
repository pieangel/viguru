unit SynthUtil;

interface

uses Windows, SysUtils,Dialogs;

type
  //-- union definiton for convertine ordinary type to char buffer
  TWordUnion = packed record
    case Integer of
      1 : (wValue : SmallInt);
      2 : (cBuf : array[0..1] of Char)
    end;

  TUWordUnion = packed record
    case Integer of
      1 : (wValue : Word);
      2 : (cBuf : array[0..1] of char)
    end;

  TLongUnion = packed record
    case Integer of
      1 : (lValue : LongInt ) ;
      2 : (cBuf : array[0..3] of Char ) ;
    end;

  TULongUnion = packed record
    case Integer of
      1 : (lValue : Cardinal ) ;
      2 : (cBuf : array[0..3] of Char ) ;
    end;

  TFloatUnion = packed record
    case Integer of
      1 : (sValue : Single ) ;
      2 : (cBuf : array[0..3] of Char ) ;
    end;

  TDoubleUnion = packed record
    case Integer of
      1 : (dValue : Double ) ;
      2 : (cBuf : array[0..7] of Char ) ;
    end;

function ConvertWord (szBuffer : PChar; var iP  : Integer; wValue : SmallInt) : Boolean;
function ConvertUWord(szBuffer : PChar; var iP : Integer; wValue : Word) : Boolean;
function ConvertLong(szBuffer : PChar; var iP : Integer; lValue : LongInt) : Boolean;
function ConvertULong(szBuffer : PChar; var iP : Integer; lValue : Cardinal) : Boolean;
function ConvertFloat(szBuffer : PChar; var iP : Integer; sValue : Single) : Boolean;
function ConvertDouble(szBuffer : PChar; var iP : Integer; dValue : Double) : Boolean;
function ConvertString(szBuffer : PChar; var iP : Integer; stValue : String) : Boolean;
function ConvertBytes(szBuffer : PChar; var iP : Integer; stValue : String) : Boolean;
function ConvertByte(szBuffer : PChar; var iP : Integer; byteValue : Byte) : Boolean;

function DeconvertWord(szBuffer : PChar; var iP : Integer; var wValue : SmallInt) : Boolean;
function DeconvertUWord(szBuffer : PChar; var iP : Integer; var wValue : Word) : Boolean;
function DeconvertLong(szBuffer : PChar; var iP : Integer; var lValue : LongInt) : Boolean;
function DeconvertULong(szBuffer : PChar; var iP : Integer; var lValue : Cardinal) : Boolean;
function DeconvertFloat(szBuffer : PChar; var iP : Integer; var sValue : Single) : Boolean;
function DeconvertDouble(szBuffer : PChar; var iP : Integer; var dValue : Double) : Boolean;
function DeconvertString(szBuffer : PChar; var iP : Integer; var stValue : String) : Boolean;
function DeconvertBytes(szBuffer : PChar; var iP : Integer; var stValue : String; iLen : Integer) : Boolean;
function DeconvertByte(szBuffer : PChar; var iP : Integer; var stValue : Byte) : Boolean;

procedure MovePacket( aSource : string; var Packet : array of char );

implementation

function ConvertWord(szBuffer : PChar; var iP : Integer; wValue : SmallInt) : Boolean;
var
  recSmall : TWordUnion;
begin
  try
    recSmall.wValue := wValue;
    szBuffer[iP] := recSmall.cBuf[1];
    szBuffer[iP+1] := recSmall.cBuf[0];
    iP := iP + 2;
    Result := True;
  except
    Result := False;
  end;
end;

function ConvertUWord(szBuffer : PChar; var iP : Integer; wValue : Word) : Boolean;
var
  recWord : TUWordUnion;
begin
  try
    recWord.wValue := wValue;
    szBuffer[ip] := recWord.cBuf[1];
    szBuffer[ip+1] := recWord.cBuf[0];
    iP := iP + 2;
    Result := True;
  except
    Result:= False;
  end;
end;


function ConvertLong(szBuffer : PChar; var iP : Integer; lValue : LongInt) : Boolean;
var
  recLong : TLongUnion;
//  szBuff : array[0..3] of char;
begin
  try
    recLong.lValue := lValue;
    szBuffer[iP] := recLong.cBuf[3];
    szBuffer[iP+1] := recLong.cBuf[2];
    szBuffer[iP+2] := recLong.cBuf[1];
    szBuffer[iP+3] := recLong.cBuf[0];
    iP := iP + 4;
    Result := True;
  except
    Result := False;
  end;
end;

function ConvertULong(szBuffer : PChar; var iP : Integer; lValue : Cardinal) : Boolean;
var
  recLong : TULongUnion;
//  szBuff : array[0..3] of char;
begin
  try
    recLong.lValue := lValue;
    szBuffer[iP] := recLong.cBuf[3];
    szBuffer[iP+1] := recLong.cBuf[2];
    szBuffer[iP+2] := recLong.cBuf[1];
    szBuffer[iP+3] := recLong.cBuf[0];
    iP := iP + 4;
    Result := True;
  except
    Result := False;
  end;
end;

function ConvertFloat(szBuffer : PChar; var iP : Integer; sValue : Single) : Boolean;
var
  recFloat : TFloatUnion;
//  szBuff : array[0..3] of char;
begin
  try
    recFloat.sValue := sValue;
    szBuffer[iP]   := recFloat.cBuf[3];
    szBuffer[iP+1] := recFloat.cBuf[2];
    szBuffer[iP+2] := recFloat.cBuf[1];
    szBuffer[iP+3] := recFloat.cBuf[0];
    iP := iP + 4;
    Result := True;
  except
    Result := False;
  end;
end;

function ConvertDouble(szBuffer : PChar; var iP : Integer; dValue : Double) : Boolean;
var
  recDouble : TDoubleUnion;
//  szBuff : array[0..7] of char;
begin
  try
    recDouble.dValue := dValue;
    szBuffer[iP]   := recDouble.cBuf[7];
    szBuffer[iP+1] := recDouble.cBuf[6];
    szBuffer[iP+2] := recDouble.cBuf[5];
    szBuffer[iP+3] := recDouble.cBuf[4];
    szBuffer[iP+4] := recDouble.cBuf[3];
    szBuffer[iP+5] := recDouble.cBuf[2];
    szBuffer[iP+6] := recDouble.cBuf[1];
    szBuffer[iP+7] := recDouble.cBuf[0];
    iP := iP + 8;
    Result := True;
  except
    Result := False;
  end;
end;

function ConvertString(szBuffer : PChar; var iP : Integer; stValue : String) : Boolean;
var
//  i : integer;
  iSize : SmallInt;
begin
  try
    iSize := Length(stValue);
    ConvertWord(szBuffer, iP, iSize);

    CopyMemory(szBuffer+iP,@stValue[1], Length(stValue));
    iP := iP + Length(stValue) ;
    Result := True;
  except
    Result := False;
  end;
end;

function ConvertBytes(szBuffer : PChar; var iP : Integer; stValue : String) : Boolean;
var
  iSize : Integer;
begin
  try
    iSize := Length(stValue);

    CopyMemory(szBuffer + iP, @stValue[1], iSize);

    iP := iP + iSize;

    Result := True;
  except
    Result := False;
  end;
end;

// -----------------------------------------------------------------------------
//
//
function ConvertByte(szBuffer : PChar; var iP : Integer; byteValue : Byte) : Boolean;
begin
  try
    CopyMemory(szBuffer + iP, @byteValue, 1);

    iP := iP + 1;

    Result := True;
  except
    Result := False;
  end;
end;


function DeConvertWord(szBuffer : PChar; var iP : Integer; var wValue : SmallInt) : Boolean;
var
  recSmallInt : TWordUnion;
//  i : integer;
begin
  try
    recSmallInt.cBuf[0] := szBuffer[iP+1];
    recSmallInt.cBuf[1] := szBuffer[iP+0];

    wValue := recSmallInt.wValue;
    iP := iP + 2;
    Result := True;
  except
    Result := False;
  end;
end;

function DeconvertUWord(szBuffer : PChar; var iP : Integer; var wValue : Word) : Boolean;
var
  recSmallInt : TUWordUnion;
begin
  try
    recSmallInt.cBuf[0] := szBuffer[iP+1];
    recSmallInt.cBuf[1] := szBuffer[iP+0];

    wValue := recSmallInt.wValue;
    iP := iP + 2;
    Result := True;
  except;
    Result := False;
  end;
end;

function DeconvertLong(szBuffer : PChar; var iP : Integer; var lValue : LongInt) : Boolean;
var
  recLong : TLongUnion;
//  i : Integer;
begin
  try
    //CopyMemory(@recLong.cBuf[0], szBuffer+iP, 4);
    recLong.cBuf[0] := szBuffer[iP+3];
    recLong.cBuf[1] := szBuffer[iP+2];
    recLong.cBuf[2] := szBuffer[iP+1];
    recLong.cBuf[3] := szBuffer[iP+0];
    iP := iP+4;
    lValue := recLong.lValue;
    Result := True;
  except
    Result := False;
  end;
end;

function DeconvertULong(szBuffer : PChar; var iP : Integer; var lValue : Cardinal) : Boolean;
var
  recLong : TULongUnion;
//  i : Integer;
begin
  try
    //CopyMemory(@recLong.cBuf[0], szBuffer+iP, 4);
    recLong.cBuf[0] := szBuffer[iP+3];
    recLong.cBuf[1] := szBuffer[iP+2];
    recLong.cBuf[2] := szBuffer[iP+1];
    recLong.cBuf[3] := szBuffer[iP+0];
    iP := iP+4;
    lValue := recLong.lValue;
    Result := True;
  except
    Result := False;
  end;
end;

function DeconvertFloat(szBuffer : PChar; var iP : Integer; var sValue : Single) : Boolean;
var
  recFloat : TFloatUnion;
//  i : Integer;
begin
  try
    //CopyMemory(@recLong.cBuf[0], szBuffer+iP, 4);
    recFloat.cBuf[0] := szBuffer[iP+3];
    recFloat.cBuf[1] := szBuffer[iP+2];
    recFloat.cBuf[2] := szBuffer[iP+1];
    recFloat.cBuf[3] := szBuffer[iP+0];
    iP := iP+4;
    sValue := recFloat.sValue;
    Result := True;
  except
    Result := False;
  end;
end;

function DeconvertDouble(szBuffer : PChar; var iP : Integer; var dValue : Double) : Boolean;
var
  recDouble : TDoubleUnion;
//  i : Integer;
begin
  try
    //CopyMemory(@recLong.cBuf[0], szBuffer+iP, 4);
    recDouble.cBuf[0] := szBuffer[iP+7];
    recDouble.cBuf[1] := szBuffer[iP+6];
    recDouble.cBuf[2] := szBuffer[iP+5];
    recDouble.cBuf[3] := szBuffer[iP+4];
    recDouble.cBuf[4] := szBuffer[iP+3];
    recDouble.cBuf[5] := szBuffer[iP+2];
    recDouble.cBuf[6] := szBuffer[iP+1];
    recDouble.cBuf[7] := szBuffer[iP+0];
    iP := iP+8;
    dValue := recDouble.dValue;
    Result := True;
  except
    Result := False;
  end;
end;



function DeConvertString(szBuffer : PChar; var iP : Integer; var stValue : String) : Boolean;
var
  iSize : SmallInt;
begin
  Result := False;
  iSize := 0;
  try
    if not DeconvertWord(szBuffer, iP, iSize) then Exit;

    SetLength(stValue, iSize);
    CopyMemory(@stValue[1], szBuffer+iP,iSize);

    iP := iP + iSize;
    Result := True;
  except
    Result := False;
  end;
end;

function DeConvertBytes(szBuffer : PChar; var iP : Integer; var stValue : String; iLen : Integer) : Boolean;
begin
  try
    SetLength(stValue, iLen);
    CopyMemory(@stValue[1], szBuffer + iP, iLen);
    iP := iP + iLen;
    Result := True;
  except
    Result := False;
  end;
end;


function DeconvertByte(szBuffer : PChar; var iP : Integer; var stValue : Byte) : Boolean;
begin
  try
    CopyMemory(@stValue, szBuffer + iP, 1);
    Inc(iP); 
    Result := True;
  except
    Result := False;
  end;
end;

procedure MovePacket( aSource : string; var Packet : array of char );
var pSize : integer;
begin
  pSize := sizeof( Packet );
  Move( aSource[1], Packet[0], pSize );
end;

end.
