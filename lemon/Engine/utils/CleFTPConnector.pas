unit CleFTPConnector;

// FTPConnector wraps the FTP component and provides simpler interface
// for file transfer. Basic usage is following:
//  [Common]
//    0. set FTP information using TFTPConnector.ServerIP/UserName/Password
//    1. set paths using TFTPConnector.ServerPath/LocalPath(optional)
//  ['Selective' mode]
//    2. add files to the list using TFTPConnector.Files.Add()
//  ['CopyDir', 'SyncDir' Mode]
//    2. (don't need to add files)
//  [Common]
//    3. upload/download using TFTPConnector.Upload()
//    4. Check the results:
//        4.1. Upload(), Download() returns the number of files transfered.
//              if something wroing, they return '-1'
//        4.2. if TFTPConnector.OnLog is assigned a handler, the log messages
//              is delivered during the file transfer.

interface

uses
  Classes, SysUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdFTPList,
  IdExplicitTLSClientServerBase, IdFTP,
    // the following file is crucial to parse the standard FTP directory
    // listing formats, to be in 'uses' clause is enough for it to work
  IdAllFTPListParsers,

    // from Lemon
  GleTypes, GleLib;

type
    // work mode
    //  [Selective] only transfer files manually registered
    //  [CopyDir] transfer all the files in the designated directory
    //  [SyncDir] only transfer files with more recent date or files
    //                which don't exist where the file will be sent to
  TFTPMode = (fmSelective, fmCopyDir, fmSyncDir);

    // file information
  TFTPFile = class(TCollectionItem)
  private
    FName: String;
    FTransferAs: String;
      // the following are used only in 'Synchronize' mode
    FLocalTime: TDateTime;
    FRemoteTime: TDateTime;
    FExistsRemotely: Boolean;
    FExistsLocally: Boolean;
      // transfer result
    FTransfered: Boolean;
  public
    function Represent: String;

    property Name: String read FName;
    property TransferAs: String read FTransferAs;
    property LocalTime: TDateTime read FLocalTime;
    property RemoteTime: TDateTime read FRemoteTime;
    property ExistsRemotely: Boolean read FExistsRemotely;
    property ExistsLocally: Boolean read FExistsLocally;
    property Transfered: Boolean read FTransfered;
  end;

    // file list to transfer
  TFTPFiles = class(TCollection)
  private
    FNames: TStringList; // sorting purpose
    
    function GetFile(i: Integer): TFTPFile;
  public
    constructor Create;
    destructor Destroy; override;
      // used only in 'CopyDir' and 'SyncDir' mode
    function Find(stFile: String): TFTPFile;
      //
    procedure Clear;

      // populate file list
    function AddTarget(stFile: String; stTransferAs: String = ''): TFTPFile;
    function AddLocalFile(stFile: String; dtFile: TDateTime): TFTPFile;
    function AddServerFile(stFile: String; dtFile: TDateTime): TFTPFile;

      // debug information
    function Represent: String;

      // sorted item access 
    property Files[i:Integer]: TFTPFile read GetFile; default;
  end;

    // main class
  TFTPConnector = class
  private
    FFileName: string;
  protected
      // connection info
    FServerIP: String;
    FUserName: String;
    FPassword: String;

      // transfer info
    FLocalPath: String;
    FRemotePath: String;
    FFiles: TFTPFiles;

      // FTP Component
    FFTP: TIdFTP;

      // transfer status
    FLogon: Boolean;
    FLastErrorMsg: String;

      // log
    FVerbose: Boolean;
    FOnLog: TTextNotifyEvent;

      // FTP component event handler
    procedure IdFTPAfterClientLogin(Sender: TObject);
    procedure IdFTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);

      // list files locally or remotely
    function ListServerFiles: Integer;
    function ListLocalFiles: Integer;

      // verify selectively registered file: only used for 'fmSelective' mode
    procedure VerifyLocalFiles;  // used when upload
    procedure VerifyRemoteFiles; // used when download

      // protected methods
    function Connect: Boolean;
    procedure DoLog(stLog: String);
  published
  public
    constructor Create;
    destructor Destroy; override;

      // interface
    function Upload(aMode: TFTPMode): Integer;  // -1=error, else file transfer count
    function Download(aMode: TFTPMode): Integer;  // -1=error, else file transfer count
    function List: Integer;

      // connecting info
    property ServerIP: String read FServerIP write FServerIP;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;

      // transfer info: directory and files
    property RemotePath: String read FRemotePath write FRemotePath;
    property LocalPath: String read FLocalPath write FLocalPath;
    property FileName:  string read FFileName write FFileName;
    property Files: TFTPFiles read FFiles;

      // transfer status
    property LastErrorMsg: String read FLastErrorMsg;

      // log
    property Verbose: Boolean read FVerbose write FVerbose;
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
  end;

implementation

const
  SYNC_MARGIN_TIME = 1/(24*60); // = 1 minute

{ TFTPFile }

function TFTPFile.Represent: String;
begin
  Result := Format('%s as %s', [FName, FTransferAs]);
  if FExistsLocally then
    Result := Result + '/local:' + FormatDateTime('yyyy-mm-dd hh:nn', FLocalTime)
  else
    Result := Result + '/local:none';
  if FExistsRemotely then
    Result := Result + '/server:' + FormatDateTime('yyyy-mm-dd hh:nn', FRemoteTime)
  else
    Result := Result + '/server:none';
  if FTransfered then
    Result := Result + '/transfered'
  else
    Result := Result + '/not transfered';
end;

{$REGION ' class TFTPFiles '}

constructor TFTPFiles.Create;
begin
  inherited Create(TFTPFile);

  FNames := TStringList.Create;
  FNames.Sorted := True;
end;

destructor TFTPFiles.Destroy;
begin
  FNames.Free;

  inherited;
end;

procedure TFTPFiles.Clear;
begin
  FNames.Clear;

  inherited Clear;
end;

// (public)
// this is the principal function to add a file into the list
//
function TFTPFiles.AddTarget(stFile, stTransferAs: String): TFTPFile;
begin
  Result := nil;

  if Length(stFile) = 0 then Exit;

  Result := Find(stFile);

  if Result = nil then
  begin
    Result := Add as TFTPFile;
    Result.FName := stFile;
    if Length(stTransferAs) = 0 then
      Result.FTransferAs := stFile
    else
      Result.FTransferAs := stTransferAs;
    Result.FTransfered := False;
    Result.FLocalTime := 0;
    Result.FRemoteTime := 0;
    Result.FExistsRemotely := False;
    Result.FExistsLocally := False;

      // sorted list
    FNames.AddObject(Result.Name, Result);
  end;
end;

// (public)
// called only in 'CopyDir' and 'SyncDir' mode
//
function TFTPFiles.AddLocalFile(stFile: String; dtFile: TDateTime): TFTPFile;
begin
  Result := AddTarget(stFile, stFile);
  if Result <> nil then
  begin
    Result.FExistsLocally := True;
    Result.FLocalTime := dtFile;
  end;
end;

// (public)
// called only in 'CopyDir' and 'SyncDir' mode
//
function TFTPFiles.AddServerFile(stFile: String; dtFile: TDateTime): TFTPFile;
begin
  Result := AddTarget(stFile, stFile);
  if Result <> nil then
  begin
    Result.FExistsRemotely := True;
    Result.FRemoteTime := dtFile;
  end;
end;

// (public)
// find based on the full name
// when used in 'Selective' mode, it might not work (because of the path)
//
function TFTPFiles.Find(stFile: String): TFTPFile;
var
  iIndex: Integer;
begin
  iIndex := FNames.IndexOf(stFile);
  if iIndex >= 0 then
    Result := FNames.Objects[iIndex] as TFTPFile
  else
    Result := nil;
end;

// (private)
// property 'get' method for enumeration of list objects
//
function TFTPFiles.GetFile(i: Integer): TFTPFile;
begin
  if (i >= 0) and (i <= FNames.Count-1) then
    Result := FNames.Objects[i] as TFTPFile
  else
    Result := nil;
end;

// (public)
// reveal information of the object
// used in 'debug' mode
//
function TFTPFiles.Represent: String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    Result := Result + Format('%d: %s,', [i, GetFile(i).Represent]) + #$0D#$0A;
end;

{$ENDREGION}

{ TFTPConnector }

constructor TFTPConnector.Create;
begin
  FFiles := TFTPFiles.Create;
  FFTP := TIdFTP.Create(nil);
  
  FFTP.OnAfterClientLogin := IDFTPAfterClientLogin;
  FFTP.OnStatus := IDFTPStatus;

  FVerbose := False;

end;

destructor TFTPConnector.Destroy;
begin
  FFTP.Free;
  FFiles.Free;

  inherited;
end;

function TFTPConnector.Connect: Boolean;
begin
  with FFTP do
  begin
    AutoLogin := True;
    Host := FServerIP;
    UserName := FUserName;
    Password := FPassword;
  end;

  if FFTP.Connected then FFTP.Disconnect;

  FLogon := False;

  FFTP.Connect;

  Result := FFTP.Connected and FLogon;
end;

//-----------------------------------------------------< Verify >

// (protected)
// used in Upload() for 'Selective' mode
// verify local files (manually added)
//
procedure TFTPConnector.VerifyLocalFiles;
var
  i: Integer;
  aFile: TFTPFile;
begin
  for i := 0 to FFiles.Count - 1 do
  begin
    aFile := FFiles[i];
    aFile.FExistsLocally := FileExists(ComposeFilePath([FLocalPath,aFile.Name]));
  end;
end;

// (protected)
// called from download() in 'Selective' mode
// verify remote files (manually added)
//
procedure TFTPConnector.VerifyRemoteFiles;
var
  i: Integer;
  aFile: TFTPFile;
begin
  for i := 0 to FFiles.Count - 1 do
  begin
    aFile := FFiles[i];
    aFile.FExistsRemotely :=
               FFTP.Size(ComposeFilePath([FRemotePath, aFile.Name])) >= 0;
  end;
end;

//-----------------------------------------------------< Directory Listing >

// (protected)
// get the file list in the local path in 'CopyDir' and 'SyncDir' mode
//
function TFTPConnector.ListLocalFiles: Integer;
var
  F: TSearchRec;
begin
  Result := 0;

  if FindFirst(ComposeFilePath([FLocalPath, '*.*']), 0, F) = 0 then
  begin
     if F.Attr and faDirectory = 0 then
     begin
       FFiles.AddLocalFile(F.Name, FileDateToDateTime(F.Time));
       Inc(Result);
     end;

     while FindNext(F) = 0 do
       if F.Attr and faDirectory = 0 then
       begin
         FFiles.AddLocalFile(F.Name, FileDateToDateTime(F.Time));
         Inc(Result);
       end;
  end;

  FindClose(F);
end;

// (protected)
// get the file list in the current directory in the server
// in 'CopyDir' and 'SyncDir' mode
//
function TFTPConnector.ListServerFiles: Integer;
var
  i: Integer;
  aItem: TIdFTPListItem;
  strFileanme: string;
begin
  Result := 0;

  FFTP.List;
  strFileanme := FormatDateTime( 'yyyymmdd', Date );
  strFileanme := strFileanme+'_ssmaster.txt';
  for i := 0 to FFTP.DirectoryListing.Count - 1 do
  begin
    aItem := FFTP.DirectoryListing[i];
    //당일 날짜의 파일만 가져온다........
    if strFileanme = aItem.FileName then
    begin
      FFiles.AddServerFile(aItem.FileName, aItem.ModifiedDate);
      break;
    end;
  end;
end;

// (public)
// make file list from local and server using the path informations
// it was designed mostly for 'debug'
//
function TFTPConnector.List: Integer;
begin
  Result := 0;
  FFiles.Clear;

  try
    if Connect then
    begin
      if FVerbose then
      begin
        DoLog('Local directory is ''' + FLocalPath + '''');
        DoLog('Changing server directory to ''' + FRemotePath + '''');
      end;

        // change the current directory in the server
      FFTP.ChangeDir(FRemotePath);

      if FVerbose then
      begin
        DoLog('Current server directory is ''' + FFTP.RetrieveCurrentDir + '''');
      end;

        // list local directory
      ListLocalFiles;
        // list server directory
      ListServerFiles;
        // disconnect
      FFTP.Disconnect;
    end;

    Result := FFiles.Count;
  except
    on E: Exception do
    begin
      FLastErrorMsg := E.Message;
    end;
  end;
end;

// (public)
// upload files to the server
//
function TFTPConnector.Upload(aMode: TFTPMode): Integer;
var
  i: Integer;
  aFile: TFTPFile;
begin
  Result := 0;
  aFile := nil;

  try
      // get file
    if Connect then
    begin
        // preparation
      case aMode of
        fmSelective:
            VerifyLocalFiles; // check file existence
        fmCopyDir,
        fmSyncDir:
          begin
              // log
            if FVerbose then
            begin
              DoLog('Local directory is ''' + FLocalPath + '''');
              DoLog('Changing server directory to ''' + FRemotePath + '''');
            end;

              // change the current directory in the server
            FFTP.ChangeDir(FRemotePath);

              // log
            if FVerbose then
            begin
              DoLog('Current server directory is ''' + FFTP.RetrieveCurrentDir + '''');
            end;

            FFiles.Clear;
            ListLocalFiles;
            ListServerFiles;
          end;
      end; // end of 'case' statement

        // transfer files
      for i := 0 to FFiles.Count - 1 do
      try
        aFile := FFiles[i];

        if aFile.ExistsLocally then
        begin
            // check file condition
          if (aMode = fmSyncDir)
             and (aFile.ExistsRemotely)
             and (aFile.LocalTime < aFile.RemoteTime + SYNC_MARGIN_TIME) then
          begin
            if FVerbose then
              DoLog(aFile.Name + ' does not need to sychronize. Skipped');

            Continue;
          end;

          if FVerbose then
            DoLog('Uploading ' + aFile.Name);

            // actual transfer
          FFtp.Put(ComposeFilePath([FLocalPath, aFile.Name]),
                   ComposeFilePath([FRemotePath, aFile.TransferAs]));
          aFile.FTransfered := True;
          Inc(Result);
        end else
        if aMode = fmSelective then
        begin
          DoLog(aFile.Name + ' does not exist. Skipped.');
        end;
      except
        DoLog('Uploading failed for ' + aFile.Name);
      end;

        // disconnect after uploading
      FFTP.Disconnect;
    end else
    begin
      Result := -1;
      FLastErrorMsg := 'connection or login failure';
    end;
  except
    on E: Exception do
    begin
      Result := -1;
      FLastErrorMsg := E.Message;
    end;
  end;
end;

// (public)
//  download files from the server
//
function TFTPConnector.Download(aMode: TFTPMode): Integer;
var
  i: Integer;
  aFile: TFTPFile;
  strFileanme : string;
begin
  Result := 0;
  aFile := nil;



  try
      // get file
    if Connect then
    begin
        // preparation
        {
      case aMode of
        fmSelective: VerifyRemoteFiles; // check file existence
        fmCopyDir,
        fmSyncDir:
          begin
              // log
            if FVerbose then
            begin
              DoLog('Local directory is ''' + FLocalPath + '''');
              DoLog('Changing server directory to ''' + FRemotePath + '''');
            end;

              // change the current directory in the server
            FFTP.ChangeDir(FRemotePath);

              // log
            if FVerbose then
            begin
              DoLog('Current server directory is ''' + FFTP.RetrieveCurrentDir + '''');
            end;

            FFiles.Clear;
            ListLocalFiles;
            ListServerFiles;
          end;
      end; // end of 'case' statement
        }

      FFiles.AddServerFile(FFileName, now);
        // transfer files
      for i := 0 to FFiles.Count - 1 do
      try
        aFile := FFiles[i];

        if aFile.ExistsRemotely then
        begin
            // check file condition
          if (aMode = fmSyncDir)
             and (aFile.ExistsLocally)
             and (aFile.LocalTime + SYNC_MARGIN_TIME > aFile.RemoteTime) then
          begin
            if FVerbose then
              DoLog(aFile.Name + ' does not need to synchronize. Skipped.');

            Continue;
          end;

          if FVerbose then
            DoLog('Downloading ' + aFile.Name);

            // actual transfer
          FFtp.Get(ComposeFilePath([RemotePath, aFile.Name]),
                   ComposeFilePath([FLocalPath, aFile.TransferAs]), True);
          aFile.FTransfered := True;
          Inc(Result);
        end else
        if aMode = fmSelective then
        begin
          DoLog(aFile.Name + ' does not exist. Skipped');
        end;
      except
        DoLog('Downloading failed for ' + aFile.Name);
      end;

      FFTP.Disconnect;
    end else
    begin
      Result := -1;
      FLastErrorMsg := 'connection or login failure';
    end;
  except
    on E: Exception do
    begin
      Result := -1;
      FLastErrorMsg := E.Message;
    end;
  end;
end;

//-------------------------------------------------< TIdFTP event handlers >

procedure TFTPConnector.IdFTPAfterClientLogin(Sender: TObject);
begin
  FLogon := True;
end;

procedure TFTPConnector.IdFTPStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  DoLog(AStatusText);
end;

procedure TFTPConnector.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    OnLog(Self, 'FTP: ' + stLog);
end;


end.
