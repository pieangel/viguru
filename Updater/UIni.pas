unit UIni;

interface

uses
  Classes, SysUtils, IniFiles;

type
    TInitFile = class
    private
     { Private declarations }
    public
    pIniFile : TIniFile;
    Section : string;
    constructor Create( stFileName : string ) ;
    destructor Destory;
      // read
    function GetString( stSec : string; stKey : string ) : string;
    function GetInteger( stSec : string; stKey : string ) : integer;
    function GetDateTime( stSec : string; stKey : string ) : TDateTime;
    function GetBoolean( stSec : string; stKey : string ) : boolean;
    function GetFloat( stSec : string; stKey : string ) : single;
      // write
    procedure WriteString( stkey : string; Value : string );
    procedure WriteInteger( stKey : string; Value : Integer );
    procedure WriteDateTime( stKey : string; Value : TDateTime );

    end;
implementation


constructor TInitFile.Create( stFileName : string );
var stDir : string;
begin
    stDir := ExtractFilePath( paramstr(0) )+'env\';
    pIniFile := TIniFile.Create(stDir + stFileName );
end;

destructor TinitFile.Destory;
begin
   pIniFile.Free;
end;

function TinitFile.GetString( stSec : string; stKey : string ) : string;
begin
  result   := pIniFile.ReadString(stSec, stKey, 'SAURI');
  Trim(result);
end;



function TInitFile.GetBoolean(stSec, stKey: string): boolean;
begin
  result := pIniFile.ReadBool( stSec, stKey, false);
end;

function TInitFile.GetDateTime(stSec, stKey: string): TDateTime;
begin        
  result := StrToDateTime(
            FormatDateTime( 'yyyy/mm/dd ', now )+
            pIniFile.ReadString(stSec, stKey, '09:00:00')
            );
end;

function TInitFile.GetFloat(stSec, stKey: string): single;
begin
  result := pIniFile.ReadFloat( stSec, stKey, 0.0);
end;

function TinitFile.GetInteger( stSec : string; stKey : string ) : integer;
begin
  result   := pIniFile.ReadInteger(stSec, stKey, 0 );
end;



procedure TInitFile.WriteDateTime(stKey: string; Value: TDateTime);
begin
  pIniFile.WriteDateTime( Section, stKey, Value);
end;

procedure TInitFile.WriteInteger(stKey: string; Value: Integer);
begin
  pIniFile.WriteInteger( Section, stKey, Value );
end;

procedure TInitFile.WriteString(stkey, Value: string);
begin 
  pIniFile.WriteString( Section, stKey, Value );
end;

end.
