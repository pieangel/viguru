unit CleExcelLog;

interface

uses
  Classes, SysUtils
  ;

const
  LogMaxCount = 65000;

type

  TExcelLogData = record

  end;

  TExcelLog = class
  private
    FHeader : TStrings;
    FFileName : string;
    FFilePath : string;
    FIndex  : integer;
    FCount  : integer;
    FExcel : TextFile ;
    procedure UnSolveData(aList: TStrings; aTitle: String);
  public
    Constructor Create;
    Destructor Destroy; override;
    function LogInit( stFileName : string; aList : TStrings ) : boolean;  overload;
    function LogInit( stFileName : string; aTitle : String ) : boolean;  overload;
    function LogData( aList : TStrings; iCount : integer ) : boolean;  overload;
    function LogData( aData : String; iCount : integer ) : boolean;  overload;
    function LogHeader : boolean;
    function MakeLog( aList : TStrings ) : string;
  end;



implementation

uses
  GAppEnv;

{ TExcelLog }

constructor TExcelLog.Create;
begin
  FHeader := TStringList.Create;
  FIndex  := -1;
  FCount  := 0;
  FFileName := '';
  FFilePath := '';
end;

destructor TExcelLog.Destroy;
begin
  if FHeader <> nil then  
    FHeader.Free;
  inherited;
end;

function TExcelLog.LogData(aList: TStrings; iCount: integer): boolean;
var
  bRes : boolean;
  stLog : string;
  iSaveIndex : integer;
begin

  try
    iSaveIndex := FIndex;
    FIndex  := iCount div LogMaxCount;

    if iSaveIndex <> FIndex then
    begin
      bRes := LogHeader;
    end;

    inc( FCount );
    stLog := MakeLog( aList );
    gEnv.EnvLog( '', stLog, true, FFilePath );
  except

  end;

end;

function TExcelLog.LogData(aData: String; iCount: integer): boolean;
var
  bRes : boolean;
  iSaveIndex : integer;
begin

  try
    iSaveIndex := FIndex;
    FIndex  := iCount div LogMaxCount;

    if iSaveIndex <> FIndex then
    begin
      bRes := LogHeader;
    end;

    inc( FCount );
    //stLog := MakeLog( aList );
    gEnv.EnvLog( '', aData, true, FFilePath );
  except

  end;

end;

function TExcelLog.LogHeader: boolean;
var
  LogFile : string;
begin

  FFilePath := Format('%s\%s_%s_%d.csv',
    [
    gEnv.LogDir, FFileName ,
    FormatDateTime('yyyymmdd', gEnv.Engine.QuoteBroker.Timers.Now ),
    FIndex
    ]);

  try
    try
      AssignFile(FExcel, FFilePath );
      Rewrite(FExcel);
      Writeln(FExcel, MakeLog(FHeader));
    finally
      CloseFile(FExcel);
    end;
  except
  end;
end;

function TExcelLog.LogInit(stFileName, aTitle: String): boolean;
begin
  UnSolveData( FHeader, aTitle );
  FFileName := stFileName;
end;

function TExcelLog.LogInit(stFileName: string; aList: TStrings): boolean;
var
  i : integer;
begin
  for i := 0 to aList.Count - 1 do
    FHeader.Add( aList[i] );
  //FHeader := aList;
  FFileName := stFileName;
end;

function TExcelLog.MakeLog(aList: TStrings): string;
var
  i : integer;
begin
  Result := '';

  for i := 0 to aList.Count - 1 do
    if i = aList.Count-1 then
      Result := Result + aList[i]
    else
      Result := Result + aList[i]+',';
end;

procedure TExcelLog.UnSolveData(aList: TStrings; aTitle: String);
var
  iCnt, i : integer;
  stTmp : string;
begin

  iCnt := Length( aTitle );
  stTmp := '';
  for i := 1 to iCnt +1 do
    if (aTitle[i] = ',') or (aTitle[i] = #0) then
    begin
      if stTmp <> '' then
        aList.Add( stTmp);
      stTmp := '';
      Continue;
    end
    else
      stTmp := stTmp + aTitle[i];

end;

end.
