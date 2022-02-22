unit CleParsers;

interface

uses
  Classes, SysUtils;

type
  TCharSet = set of Char;
  
  TParser = class(TStringList)
  private
    FDelimiters: TCharSet;
  public
    constructor Create(Delimiters: TCharSet);

    function Parse(stText: String): Integer; overload;
    function Parse(stText: String; aSizes: array of Integer): Integer; overload;
    function ParseVar(stText: String): Integer;

    property Delimiters: TCharSet read FDelimiters write FDelimiters;
  end;

  TCSVSeqParser = class
  private
    FHandle : TextFile;
    FFields : TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    function OpenFile(stFile : String) : Boolean;
    procedure CloseFile;
    function EndOfFile : Boolean;
    procedure ParseNext;

    property Fields : TStringList read FFields;
  end;

function ParseCSV(stText : String; Tokens : TStringList) : Integer;
function ParseDirPath(stPath : String; stDirs : TStringList) : Integer;

function ParseDateMMDDYYYY(stDate: String): TDateTime;
function ParseDateYYYYMMDD(stDate: String): TDateTime;
function ParseDateYYMMDD(stDate: String): TDateTime;

implementation



function ParseCSV(stText : String; Tokens : TStringList) : Integer;
var
  i : Integer;
  stToken : String;
begin
  Tokens.Clear;
  stToken := '';

  for i:=1 to Length(stText) do
    case stText[i] of
      ',', #10 :
        begin
          Tokens.Add(stToken);
          stToken := '';
        end;
      else
        stToken := stToken + stText[i];
    end;

  if Length(stToken) > 0 then
    Tokens.Add(stToken);

  Result := Tokens.Count;
end;

function ParseDirPath(stPath : String; stDirs : TStringList) : Integer;
var
  i : Integer;
  stDir : String;
begin
  stDir := '';

  for i := 1 to Length(stPath) do
    case stPath[i] of
      '/','\' :
          if Length(stDir) > 0 then
          begin
            stDirs.Add(stDir);
            stDir := '';
          end;
      else
        stDir := stDir + stPath[i];
    end;

  if Length(stDir) > 0 then
    stDirs.Add(stDir);

  Result := stDirs.Count;
end;

//---------------------------------------------------------------< Parse Date >

function ParseDateMMDDYYYY(stDate: String): TDateTime;
var
  stValues: array[0..2] of String;
  i, iLen, iP: Integer;
begin
  for i := 0 to 2 do
    stValues[i] := '';

  iLen := Length(stDate);
  iP := 0;

  for i := 1 to iLen do
    case stDate[i] of
      '/': Inc(iP);
      else
        stValues[iP] := stValues[iP] + stDate[i];
    end;

  try
    Result := EncodeDate(StrToIntDef(stValues[2], 0),
                         StrToIntDef(stValues[0], 0),
                         StrToIntDef(stValues[1], 0));
  except
    Result := 0.0;
  end;
end;

function ParseDateYYYYMMDD(stDate: String): TDateTime;
begin
  try
    Result := EncodeDate(StrToIntDef(Copy(stDate,1,4), 0),
                         StrToIntDef(Copy(stDate,5,2), 0),
                         StrToIntDef(Copy(stDate,7,2), 0));
  except
    Result := 0.0;
  end;
end;

const
  ZERO_TEMPLATE = '000000';

function ParseDateYYMMDD(stDate: String): TDateTime;
var
  wYear, wMonth, wDay: Word;
begin
  try
    stDate := Copy(ZERO_TEMPLATE, 1, 6 - Length(stDate)) + stDate;

    wYear  := StrToIntDef(Copy(stDate,1,2), 0);
    wMonth := StrToIntDef(Copy(stDate,3,2), 0);
    wDay   := StrToIntDef(Copy(stDate,5,2), 0);
    if wYear < 70 then
      wYear := wYear + 2000
    else
      wYear := wYear + 1900;

    Result := EncodeDate(wYear, wMonth, wDay);
  except
    Result := 0.0;
  end;
end;


//----------------------------------------------------------< Standard Parser >

{ TParser }

constructor TParser.Create(Delimiters: TCharSet);
begin
  FDelimiters := Delimiters;

  inherited Create;
end;

function TParser.Parse(stText: String): Integer;
var
  i : Integer;
  stToken : String;
begin
  Clear;

  stToken := '';

  for i:=1 to Length(stText) do
  begin
    if stText[i] in FDelimiters then
    begin
      Add(stToken);
      stToken := '';
    end else
      stToken := stToken + stText[i];
  end;

  if Length(stToken) > 0 then
    Add(stToken);

  Result := Count;
end;

function TParser.Parse(stText : String; aSizes : array of Integer) : Integer;
var
  i, iLen, iP : Integer;
begin
  Result := 0;

    // reset
  Clear;

    // validates
  iLen := Length(stText);
  if iLen = 0 then Exit;

    // start parsing
  iP := 1;
  for i:=0 to High(aSizes) do
    if iP+aSizes[i] <= iLen+1 then
    begin
      Add(Copy(stText, iP, aSizes[i]));
      iP := iP + aSizes[i];
    end;

    //
  Result:= Count;
end;

function TParser.ParseVar(stText: String): Integer;
var
  i : Integer;
  stToken : String;
begin
  Clear;

  stToken := '';

  for i:=1 to Length(stText) do
  begin
    if stText[i] in FDelimiters then
    begin
      if Length(stToken) > 0 then
      begin
        Add(stToken);
        stToken := '';
      end;
    end else
      stToken := stToken + stText[i];
  end;

  if Length(stToken) > 0 then
    Add(stToken);

  Result := Count;
end;

//------------------------------------------------------------< CSV parser >

{ TCSVSeqParser }

constructor TCSVSeqParser.Create;
begin
  FFields := TStringList.Create;
end;

destructor TCSVSeqParser.Destroy;
begin
  FFields.Free;

  inherited;
end;

function TCSVSeqParser.OpenFile(stFile: String): Boolean;
begin
  Result := False;

  if not FileExists(stFile) then Exit;

  try
    AssignFile(FHandle, stFile);
    Reset(FHandle);

    Result := True;
  except

  end;
end;

procedure TCSVSeqParser.ParseNext;
var
  stLine : String;
begin
  FFields.Clear;

  try
    System.Readln(FHandle, stLine);
    ParseCSV(stLine, FFields);
  finally

  end;
end;

function TCSVSeqParser.EndOfFile: Boolean;
begin
  Result := EOF(FHandle);
end;

procedure TCSVSeqParser.CloseFile;
begin
  try
    System.CloseFile(FHandle);
  except

  end;
end;


end.
