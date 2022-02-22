unit CryptInt;

interface

uses Windows, SysUtils;

const
  // Old
  //PUBKEY = 'MIGIAoGAba6eBiRA1cviNmg1xQARONLWCf6YNfAXzngxRO2qpXpVa1/7wrm3GXvJWxjYxfxx6ST54InxZ5RmxaF22sN33rgm+75N+HFfksdA7xToeIED2oZbzno+M6o+PJliMLzwgLTGv25LNxGEwD5kEbK07I41DfrIaTQXHWfRRZX0O30CAwEAAQ==';
  // New 12월 .12일
  PUBKEY = 'MIGJAoGBALo8Jp1s8SsreKvcSaYFUr0QhjylJE0JNe8h7Dmczlaw+r2scz/gWO7ID5qxaTe04/JOY2pcel+xna1bsea37JhEZmdcnElSBbNZyj55N1AcZKhJb5HB+yORP4bA+dmo/k+oni6pDGnd/zbQea80acSCPNy6O9yn3msZbFY+RHAtAgMBAAE=';

type
  LPSTR = PAnsiChar;
  TXORType = (xtSend, xtRecv);

{ 암호화/복호화 함수}
function issacweb_encrypt(pBuf, pData : LPSTR; iLen : Integer; pKey : LPSTR) : Integer; cdecl;
function issacweb_decrypt(pBuf, pData : LPSTR; iLen : Integer; pKey : LPSTR) : Integer; cdecl;
function issacweb_hybrid_encrypt(pBuf, pData : LPSTR; iLen : Integer ; const PUBKEY ; pKey : LPSTR) : integer ; cdecl;
function errorcode_to_string(iError : Integer) : PChar; cdecl;
//function issacweb_server_decrypt(pBuf, pData : LPSTR; iLen : Integer; pKey : LPSTR) : Integer; stdcall;

{Unix용 단방향 암호화}
function crypt(pSalt , pKey : LPSTR) : LPSTR ;stdcall;
function CheckPassword(stPwd, stInput : String) : Boolean;
function EncryptPassword(stPwd, stInput : String) : String;

{ XOR하는 함수들 }
function DoXOR(szDest, szSrc : LPSTR; iSize : Integer; aType : TXORType) : LPSTR;
// function TYXORing( pdata:LPSTR; pFinal : LPSTR; isize,itype : integer):LPSTR ;

implementation

function issacweb_encrypt; external 'IssacWebCSClient.dll' name 'issacweb_encrypt';
function issacweb_decrypt; external 'IssacWebCSClient.dll' name 'issacweb_decrypt';
function issacweb_hybrid_encrypt; external 'IssacWebCSClient.dll' name 'issacweb_hybrid_encrypt';
function errorcode_to_string; external 'IssacWebCSClient.dll' name 'errorcode_to_string';

// function issacweb_server_decrypt; external 'IssacWebCSServer.dll' name 'issacweb_server_decrypt';

{Unix용 단방향 암호화 구현}
function crypt; external 'drcrypt.dll' name 'crypt';


//-----------------< utilities routines >-------------------//

function EncryptPassword(stPwd, stInput : String) : String;
var
  szKey : array [0..2] of Char;
begin
  if Length(stPWD) < 2 then Exit;
  //
  CopyMemory(@szKey[0], @stPWD[1], 2);
  Result := crypt(PChar(stInput), @szKey[0]);
end;

function CheckPassword(stPwd, stInput : String) : Boolean;
var
  szKey : array [0..2] of Char;
  stResult : String;
begin
  Result := False;

  // stInput 

  if Length(stPWD) < 2 then Exit;
  //
  CopyMemory(@szKey[0], @stPWD[1], 2);
  stResult := crypt(PChar(stInput), @szKey[0]);
  //
  Result := (CompareStr(stPWD, stResult) = 0);
end;

{
function TVersionIF.CheckPassword(stPWD : String) : Boolean;
var
  szKey : array [0..2] of Char;
  stResult : String;
begin
  Result := False;
  if Length(stPWD) < 2 then Exit;
  //
  CopyMemory(@szKey[0], @stPWD[1], 2);
  stResult := crypt(PChar(FPWD), @szKey[0]);
  //
  Result := (CompareStr(stPWD, stResult) = 0);
end;
}

{
function GenerateKey(szKey : LPSTR) : integer ;
const
  szData  = 'DATA_for_KEY';
var
  szBuffer : Array [0..255] of Char;
  szPKey : Array [0..15] of Char;
  iError : Integer;
begin
  // iError := issacweb_client_encrypt(szBuffer, PChar(szData), Length(szData), szPKey);

  if (iError < 0) then
    result := 0
  else
  begin
    CopyMemory(szKey, @szPKey[0], 16);
    result := 1;
  end;
end;
}

function DoXOR(szDest, szSrc : LPSTR; iSize : Integer; aType : TXORType) : LPSTR;
const
  Keys : array[TXORType] of Byte = ($AF, $BF);
var
  i : integer;
  iKey : Byte;
begin
  // set key
  iKey := Keys[aType];
  // do XOR
  for i:=0 to iSize-1 do
    szDest[i] := Chr(Ord(szSrc[i]) xor iKey);
  //
  Result := szDest;
end;

{
function CheckPassword(stPwd, stInput : String) : Boolean;
var
  szKey : array [0..2] of Char;
  stEncoded : String;
begin
  // encode
  CopyMemory(@szKey[0], @stPwd[1], 2);
  stEncoded := crypt(PChar(stInput), @szKey[0]);

  Result := (CompareStr(stEncoded, stPwd) = 0);
end;
}


end.
