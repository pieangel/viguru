unit CleLog;

interface

uses
  Classes, SysUtils, Windows,

  GleTypes;

Const
  ORDER_NO = 'O';
type

  PLogData = ^TLogData;
  TLogData = record
    LogType : char;
    stDir: String;
    stData: String;
    stFile: string;
    bMaster: boolean;
  end;

  TAppLogItem = class( TCollectionItem )
  public
    LogTime   : TDateTime;
    LogSource : string;
    LogTitle  : string;
    LogDesc   : string;
    LogData   : TObject;
  end;

  TAppLogItems = class( TCollection )
  private
    function GetLogItem(i: integer): TAppLogItem;
  public
    LogKind : TLogKind;
    BLog    : Boolean;
    Critcal : TRtlCriticalSection;

    Constructor Create;
    Destructor  Destroy; override;

    function New( lkValue : TLogKind ) : TAppLogItem;
    property LogItem[ i : integer] : TAppLogItem read GetLogItem; default;

  end;

  TLogThread = class(TThread)
  private
    { Private declarations }
    vLogData: PLogData;
    LogMutex: HWND;
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
    LogQueue: TList;

    constructor Create;
    destructor Destroy; override;

    procedure LogPushQueue(stDir, stData: String;  bMaster : boolean; stFile : string='');
    procedure LogPushQueue2(stDir, stData: String;  bMaster : boolean; stFile : string='');
    function  LogPopQueue: PLogData;
    procedure LogWriteFile; overload;
    procedure LogFileWrite(tLogDir, LogData: String; bMaster : boolean; stFile : string=''); overload;
    procedure LogFileWrite2(tLogDir, LogData: String; bMaster : boolean; stFile : string=''); 
  published
    { Published declarations }
  end;


  TAppLog = class
  public
    LogList : array [TLogKind] of TAppLogItems;

    Constructor Create;
    Destructor  Destroy; override;

    procedure LogBool( lkValue : TLogKind; bLog : boolean );
    procedure Add( lkValue : TLogKind;
                  stSource, stTitle, stDesc : String; aData : TObject = nil; bShow : boolean = true );

  end;

  var
    gAppLog  : TAppLog;

implementation

uses GAppEnv, CleQuoteTimers, CleOrders,
  Forms;

{ TLogThread }

constructor TLogThread.Create;
begin
  Inherited Create(False);
  FreeOnTerminate := True;
  LogMutex := CreateMutex(nil, False, 'LogMutex');
  LogQueue := TList.Create;

  if gEnv.RunMode = rtSimulation then
    Priority := tpNormal
  else
    Priority := tpLowest;
end;

destructor TLogThread.Destroy;
begin
  CloseHandle(LogMutex);
  Inherited Destroy;
end;

procedure TLogThread.Execute;
begin
  while not Terminated do begin
    WaitForSingleObject(Handle, 2);
    if LogQueue.Count > 0 then begin
      vLogData := LogPopQueue;
      if vLogData = nil then Continue;
      LogWriteFile;
      Dispose(vLogData);
      Application.ProcessMessages;
    end;
  end;
end;

procedure TLogThread.LogFileWrite(tLogDir, LogData: String; bMaster : boolean; stFile : string='');
  function IsFileUse(fName: String): Boolean;
  var
    HFile: THandle;
  begin
    Result := false;
    if not FileExists(fName) then exit;
    HFile := CreateFile(PChar(fName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    Result := (HFile = INVALID_HANDLE_VALUE);
    if not Result then begin
      try
        //Memo_Log.Lines.Add('Value = ' + IntToStr(HFile));
      finally
        CloseHandle(HFile);
      end;
    end;
  end;
var
  OutFile: TextFile;
  stDate, tStr, LogDir, LogFileName: String;
begin
  if bMaster then
  begin
    LogFileName := stFile;//tLogDir;
    tStr := LogData;
  end else
  begin
    stDate  := FormatDateTime('YYYYMMDD',GetQuoteTime);
    if Trim(tLogDir) = '' then
      LogDir := ExtractFilePath(ParamStr(0))+'DataLog\'
    else
      LogDir := ExtractFilePath(ParamStr(0))+'Log\'+ stDate + '\';

    tStr := LogData;

    if not DirectoryExists(LogDir) then CreateDir(LogDir);

    if stFile = '' then
      LogFileName := stDate+'_'+tLogDir
    else
      LogFileName := stDate+'_'+tLogDir +'_'+stFile;

    LogFileName := LogDir + LogFileName + '.log';
  end;

  try
    if not IsFileUse(LogFileName) then begin
    {$I-}
      AssignFile(OutFile, LogFileName);
      try
        if Not FileExists(LogFileName) then
          ReWrite(OutFile)
        else Append(OutFile);
        Writeln(OutFile,tStr);
      finally
        CloseFile(OutFile);
      end;
    {$I+}
    end;
  Except
    on E : Exception do
      gLog.Add( lkError, 'TLogThread','LogFileWrite', tLogDir + ' : ' + E.Message );
  end;

end;

procedure TLogThread.LogFileWrite2(tLogDir, LogData: String; bMaster: boolean;
  stFile: string);
  function IsFileUse(fName: String): Boolean;
  var
    HFile: THandle;
  begin
    Result := false;
    if not FileExists(fName) then exit;
    HFile := CreateFile(PChar(fName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    Result := (HFile = INVALID_HANDLE_VALUE);
    if not Result then begin
      try
        //Memo_Log.Lines.Add('Value = ' + IntToStr(HFile));
      finally
        CloseHandle(HFile);
      end;
    end;
  end;
var
  OutFile: TextFile;
  tStr, LogDir, LogFileName: String;
begin
  if bMaster then
  begin
    LogFileName := stFile;//tLogDir;
    tStr := LogData;
  end else
  begin
    if Trim(tLogDir) = '' then
      LogDir := ExtractFilePath(ParamStr(0))+'DataLog\'
    else
      LogDir := ExtractFilePath(ParamStr(0))+ Trim(tLogDir) + '\';

    tStr := LogData;

    if not DirectoryExists(LogDir) then CreateDir(LogDir);

    if stFile = '' then
      LogFileName := FormatDateTime('YYYYMMDD',GetQuoteTime)
    else
      LogFileName := stFile;

    if (tLogDir ='./log/sis') or ( tLogDir = './log/win') then
      LogFileName := LogDir + LogFileName + '.csv'
    else
      LogFileName := LogDir + LogFileName + '.log';
  end;

  try

    if not IsFileUse(LogFileName) then begin
      AssignFile(OutFile, LogFileName);
      ReWrite(OutFile);
      try
        Writeln(OutFile,tStr);
      finally
        CloseFile(OutFile);
      end;
    end;
  Except
  end;
end;

function TLogThread.LogPopQueue: PLogData;
var
  vResult: PLogData;
begin
  Result := nil;

  if LogQueue.Count < 1 then exit;
  New(Result);
  vResult := PLogData(LogQueue.Items[0]);
  WaitForSingleObject(LogMutex, INFINITE);
  LogQueue.Delete(0);
  ReleaseMutex(LogMutex);
  Result := vResult;

end;

procedure TLogThread.LogPushQueue(stDir, stData: String; bMaster : boolean; stFile : string);
var
  vLogData: PLogData;
  stTmp: string;
  fMS : Single;
begin
  if bMaster then
    stTmp := stData
  else begin
    if (stDir ='./log/sis') or ( stDir = './log/win') then
      stTmp := Format('%s, %s', [ FormatDateTime('H:NN:SS.Z', GetQuoteTime), stData ])
    else begin
      if stData = '' then
        stTmp := Format('%s', [ FormatDateTime('HH:NN:SS.ZZZ', GetQuoteTime) ])
      else
        stTmp := Format('%s, %s', [ FormatDateTime('HH:NN:SS.ZZZ', GetQuoteTime), stData ]);
    end;
  end;

  New(vLogData);
  vLogData.stDir := stDir;
  vLogData.stData := stTmp;
  vLogData.bMaster := bMaster;
  vLogData.stFile := stFile;

  WaitForSingleObject(LogMutex, INFINITE);
  LogQueue.Add(vLogData);
  ReleaseMutex(LogMutex);
end;

procedure TLogThread.LogPushQueue2(stDir, stData: String; bMaster: boolean;
  stFile: string);
var
  vLogData: PLogData;
  stTmp: string;
  fMS : Single;
begin
{
  if bMaster then
    stTmp := stData
  else begin
    if (stDir ='./log/sis') or ( stDir = './log/win') then
      stTmp := Format('%s, %s', [ FormatDateTime('H:NN:SS.Z', GetQuoteTime), stData ])
    else
      stTmp := Format('%s, %s', [ FormatDateTime('HH:NN:SS.ZZZ', GetQuoteTime), stData ]);
  end;
  }
  New(vLogData);
  vLogData.LogType := ORDER_NO;
  vLogData.stDir := stDir;
  vLogData.stData := stData;
  vLogData.bMaster := bMaster;
  vLogData.stFile := stFile;

  WaitForSingleObject(LogMutex, INFINITE);
  LogQueue.Add(vLogData);
  ReleaseMutex(LogMutex);
end;

procedure TLogThread.LogWriteFile;
begin
  case vLogData.LogType of
    ORDER_NO :
      LogFileWrite2(vLogData.stDir, vLogData.stData, vLogData.bMaster, vLogData.stFile); //파일로 쓰기..;
    else
      LogFileWrite(vLogData.stDir, vLogData.stData, vLogData.bMaster, vLogData.stFile); //파일로 쓰기..
  end;

end;
{ TAppLog }
// 로그 추가
procedure TAppLog.Add(lkValue: TLogKind; stSource, stTitle, stDesc: String;
  aData: TObject; bShow : boolean);
var
  aItem : TAppLogItem;
  stLog, stFolder  : string;
  aMsg  : Cardinal;
  aOrder  : TOrder;
begin

  aItem := LogList[lkValue].New( lkValue );
  aItem.LogSource := stSource;
  aItem.LogTitle  := stTitle;
  aItem.LogDesc   := stDesc;
  aItem.LogData   := aData;

  case lkValue of
    lkError:       stFolder  := WIN_ERR;
    lkDebug:       stFolder  := WIN_DEBUG;
    lkKeyOrder:    stFolder  := WIN_KEYORD;
    lkApplication: stFolder  := WIN_APP;
    lkWarning:     stFolder  := WIN_WARN;
    lkReject:      stFolder  := WIN_RJT;
    lkLossCut:     stFolder  := WIN_LOSS;
  end;

  if (gEnv.Info <> nil) and
     (( lkValue = lkError ) or ( lkValue = lkReject ) or ( lkValue = lkWarning)) then
  begin
    PostMessage( gEnv.Info.Handle, WM_LOGARRIVED, Integer( lkValue ), 0);
    gEnv.Info.Show;
  end;

  if lkValue = lkKeyOrder then
    stLog := Format( '%s', [ stDesc ] )
  else
    stLog := Format( '%-15.15s | %-15.15s | %s', [ stSource, stTitle, stDesc ] );

  if lkValue = lkReject then
  begin
    aOrder := nil;
    if aData <> nil then
      aOrder  := aData as TOrder;

    if aOrder <> nil then
    begin
      if (aOrder.RejectCode <> '') then
        gEnv.ShowMsg( stFolder, stLog, false );
    end;
  end;

  if lkValue in [ lkError, lkApplication, lkKeyOrder, lkLossCut, lkReject, lkDebug ] then
    gEnv.EnvLog( stFolder, stLog )
  else if LogList[lkValue].BLog then
    gEnv.DoLog(stFolder, stLog);
end;

constructor TAppLog.Create;
var
  lki : TLogKind;
begin
  for lki := lkApplication to lkReject do
    LogList[lki]  := TAppLogItems.Create;
  gAppLog := self;
end;

destructor TAppLog.Destroy;
var
  lki : TLogKind;
begin
  gAppLog := nil;
  for lki := lkApplication to lkReject do
    LogList[lki].Free;
  inherited;
end;



procedure TAppLog.LogBool(lkValue : TLogKind; bLog: boolean);
begin
  LogList[ lkValue ].BLog := bLog;
end;


{ TAppLogItems }

constructor TAppLogItems.Create;
begin
  inherited Create( TAppLogItem );
  BLog  := True;
  InitializeCriticalSection( Critcal );
end;

destructor TAppLogItems.Destroy;
begin
  DeleteCriticalSection( Critcal );
  inherited;
end;

function TAppLogItems.GetLogItem(i: integer): TAppLogItem;
begin
  if ( i<0 ) and ( i>=Count) then
    Result := nil
  else
    Result  := Items[i] as TAppLogItem;
end;

function TAppLogItems.New(lkValue: TLogKind): TAppLogItem;
begin
  EnterCriticalSection(Critcal);
  LogKind := lkValue;
  Result  := Insert(0) as TAppLogItem;
  Result.LogTime  :=  GetQuoteTime;
  LeaveCriticalSection(Critcal)
end;

end.
