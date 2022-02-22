unit CleImportCode;

interface

uses
  Classes, SysUtils,

  GleTypes, CleIni
  ;

Const
  ErrorCode    = 'TopsErrCode.ini';

type
  TImportCode = class( TCollectionItem )
  private
    FErrCode: string;
    FCodeDiv: TCodeDivision;
    FErrDesc: string;
  public
    property CodeDiv  : TCodeDivision read FCodeDiv write FCodeDiv;
    property ErrCode  : string  read FErrCode write FErrCode;
    property ErrDesc  : string   read FErrDesc write FErrDesc;
  end;

  TImportCodes  = class( TCollection )
  private
    FDivision: TCodeDivision;
    function GetCodes(i: integer): TImportCode;
  public
    property Division : TCodeDivision read FDivision write FDivision;

    Constructor Create;
    destructor  Destroy; override;
    property Codes[ i : integer] : TImportCode read GetCodes ; default;

    function GetCode( stCode: string ) : TImportCode;
    function New( stCode : string ) : TImportCode;
  end;

  TErrCodeManager = class
  public
    ImportCodes : array [TCodeDivision] of  TImportCodes ;

    Constructor Create;
    Destructor  Destroy; override;

    function LoadIni : boolean;
    function GetCodeDescription( CodeDiv : TCodeDivision; Code : string ) : string;
    function New( CodeDiv : TCodeDivision; stCode, stDesc : string ) : TImportCode;
    procedure Log;
  end;

implementation

uses GAppEnv;

{ TImportCodes }

constructor TImportCodes.Create;
begin
  inherited Create( TImportCode );
end;

destructor TImportCodes.Destroy;
begin

  inherited;
end;


function TImportCodes.GetCode(stCode: string): TImportCode;
var
  i : integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if Codes[i].FErrCode = stCode then
    begin
      Result := Codes[i];
      Break;
    end;

end;

function TImportCodes.GetCodes(i: integer): TImportCode;
begin
  if ( i >= 0) and ( i < Count ) then
    Result := Items[i] as TImportCode
  else
    Result := nil;
end;

function TImportCodes.New(stCode: string): TImportCode;
begin
  Result := Add as TImportCode;
  Result.FErrCode := stCode;
end;

{ TErrCodeManager }

constructor TErrCodeManager.Create;
var
  i : TCodeDivision;
begin
  for i := cdTops to cdLimit do
  begin
    ImportCodes[i] := TImportCodes.Create;
    ImportCodes[i].Division := i;
  end;
end;

destructor TErrCodeManager.Destroy;
var
  i : TCodeDivision;
begin
  for i := cdTops to cdLimit do
    ImportCodes[i].Free;
  inherited;
end;

function TErrCodeManager.GetCodeDescription(CodeDiv: TCodeDivision;
  Code: string): string;
var
  aCode : TImportCode;
begin
  aCode := ImportCodes[ CodeDiv ].GetCode( Code );
  if aCode <> nil then
    Result := aCode.FErrDesc
  else
    Result := '';
end;

function TErrCodeManager.New(CodeDiv: TCodeDivision; stCode, stDesc : string ): TImportCode;
var
  stTmp : string;
begin
  Result := ImportCodes[ CodeDiv ].New( stCode );
  Result.CodeDiv  := CodeDiv;
  Result.FErrDesc := stDesc;
end;

function TErrCodeManager.LoadIni: boolean;
var
  ini : TInitFile;
  stSection , stCode, stDesc : string;
  i, iCnt : integer;
begin

  Result := false;

  try
    ini := TInitFile.Create(ErrorCode);
    //TOPS Error Code
    stSection := 'TOPS';
    for i := 9001 to 9999 do
    begin
      stCode := Format('NET%.2d',[i]);
      stDesc := ini.GetString(stSection, stCode);
      if stDesc = 'SAURI' then continue;
      New( cdTops, stCode, stDesc );
    end;
  finally
    ini.Free
  end;
  Result := true;
end;

procedure TErrCodeManager.Log;
var
  stParam : string;
  i : TCodeDivision;
  j : integer;
  aCode : TImportCode;
begin
  //for i := cdTops to cdLimit do
  //begin
  for j := 0 to ImportCodes[cdTops].Count - 1 do
  begin
    aCode := ImportCodes[cdTops].Codes[j];
    stParam :=  Format( ' aCode.Code = %d , aCode.Desc = %s',
      [
      aCode.FErrCode ,
      aCode.FErrDesc]);

    gEnv.OnLog( self, stParam);
  end;
  //end;
end;

end.
