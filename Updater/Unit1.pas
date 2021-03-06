unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls,  ShellAnimations, CleParsers, Registry,

  UIni, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdFTP, IdFTPList, IdFTPCommon,
  IdAntiFreezeBase, IdAntiFreeze, IdHTTP, EnvUtil, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL
  ;

const
  Env_File  = 'Update.ini';
  RegRootKey = HKEY_LOCAL_MACHINE;

type

  TConConfig = record
    UserID    : string;
    Password  : string;
    CertPass  : string;
    SaveInput : boolean;
    RealMode  : boolean;
    // 모의...
    SaveID    : array [0..1] of string;
    SavePW    : array [0..1] of string;
    SaveCert  : array [0..1] of string;
    // 영리 아뒤/ 패스
    Save0LeeID    : string;
    Save0LeePW    : string;
    Save0LeeCode  : string;

    tUserID    : string;
    tPassword  : string;
    tCertPass  : string;
    t0LeeID    : string;
    t0LeePW    : string;
    tUseMock   : boolean;
    tUseSave   : boolean;
  end;

  TLauncherItem = record
    Target : string;
    DownLoad : boolean;
    NextVer : integer;
    Path  : string;
  end;

  TFtp  = record
    FtpIP : string;
    FtpUser : string;
    FtpPass : string;
    RemotePath : string;
    Launcherini : string;
    LocalPath : string;
    FileName  : string;

    //
    SecName : string;
    ApiDiv  : string;
    RegOpenKeyIni : string;
    CertCode  : string;
  end;

  TForm1 = class(TForm)
    Ftp: TIdFTP;
    Timer: TTimer;
    gbDown: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label_AvgSpeed: TLabel;
    Label_Count: TLabel;
    ProgressBar2: TProgressBar;
    ProgressBar1: TProgressBar;
    lbFileCnt: TLabel;
    lbFileName: TLabel;
    IdAntiFreeze1: TIdAntiFreeze;
    idh: TIdHTTP;
    gb0Lee: TGroupBox;
    lbTitle: TLabel;
    edt0LeeID: TLabeledEdit;
    edt0LeePW: TLabeledEdit;
    Button1: TButton;
    stResult: TStaticText;
    gbLogin: TGroupBox;
    edtID: TLabeledEdit;
    edtPW: TLabeledEdit;
    edtCert: TLabeledEdit;
    btnCon: TButton;
    btnExit: TButton;
    cbSaveInput: TCheckBox;
    cbMock: TCheckBox;
    Button2: TButton;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FtpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Integer);
    procedure FtpWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Integer);
    procedure FtpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure TimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edtIDKeyPress(Sender: TObject; var Key: Char);
    procedure btnExitClick(Sender: TObject);
    procedure btnConClick(Sender: TObject);
    procedure cbMockClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    Fini : TInitFile;
    FtpInfo   : TFtp;

    Launcher  : array of TLauncherItem;    
    SecName   : string; // 증권사 이름
    ExeName   : string;

      // 파일 사이즈 관련
    FAllFileSize   : int64; // 전체
    FAllFileSizing : int64; // 전체중 받은 사이즈
    FFileSize      : int64; // 파일별 사이즈

    FAllFileCnt    : integer;
    FFileCnt       : integer;
      // 시간, 속도 관련
    FStartTime     : TdateTime;
    FDownLoadList  : TStringList;


    procedure ftpInit;
    procedure loadConfigFile;

    function ServerConnect: Boolean;
    function SetUpdateList(DownloadList: TStringList): Boolean;
    function GetSizeOfFile(const FilenName: string): Longint;
    procedure StartUpdate;
    procedure FTPDownLoad;
    procedure ExecuteMainProgram;
    function FindDir(stFileName: string): string;
    procedure LoadRegedit;
    procedure SaveRegedit;
    procedure InitLogin;
    procedure LoadLoginInfo;
    procedure SaveLoginInfo;
  public
    { Public declarations }
    AppType   : string;
    ConConfig :  TConConfig;
    Param : string;
    procedure  ExeMainApp;
    function   GetSecName( bKor : boolean = true ) : string;
    function   GetAppdiv( bKor : boolean = true )  : string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ExeMainApp;
var
  sFileName : string;
  stPath    : string;
begin
  // '' : 정상 접속   'AutoConnect' : 재접속
  if AppType = '' then
    sFileName := ExeName + ' Login'
  else
    sFileName := ExeName + ' ' + AppType;

  stPath := ExtractFilePath( paramstr(0) )+ExeName;
  if FileExists(stPath) then  WinExec( PChar(sFileName), SW_SHOW )
    else  ShowMessage(stPath+' : 실행파일을 찾을수가 없습니다.');

end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  //
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Launcher := nil;
  FDownLoadList.Free;
  Action := cafree;

end;


procedure TForm1.FormCreate(Sender: TObject);
var
  stIconPath : string;
begin

  if ParamCount > 0 then
    AppType := ParamStr(1)
  else AppType := '';
  // ftp 접속 정보및  업데이트 목록을 가져온다.
  FIni  := TInitFile.Create(Env_File);
  loadConfigFile;
  // 아이콘 생성..
  {
  stIconPath  := ExtractFilePath( paramstr(0) ) + Format('GURU_%s_%s.ico', [  GetSecName( false ), GetAppdiv(false) ]);


  ShowMessage(stIconPath);
  try
  if FileExists( stIconPath ) then
    Icon.LoadFromFile( stIconPath );
  except
    ShowMessage('aa');
  end;
  ShowMessage('LoadRegedit');
  }
  LoadRegedit;

  lbTitle.Caption := Format('%s %s %s', [ GetSecName ,
         GetAppdiv,   lbTitle.Caption ]);;
  InitLogin;

end;

procedure TForm1.ftpInit;
begin

  Ftp.Host      := FtpInfo.FtpIP;
  Ftp.UserName  := FtpInfo.FtpUser;
  Ftp.Password  := FtpInfo.FtpPass;

end;

procedure TForm1.InitLogin;
begin

  cbSaveInput.Checked := ConConfig.SaveInput;
  cbMock.Checked      := not ConConfig.RealMode;

  if cbSaveInput.Checked then
  begin
    edt0LeeID.Text  := ConConfig.Save0LeeID;
    edt0LeePW.Text  := ConConfig.Save0LeePW;
  end;

  edtID.Text    := '';
  edtPW.Text    := '';
  edtCert.Text  := '';
end;

function TForm1.ServerConnect :Boolean;
begin
   try
      Ftp.AutoLogin := true;
      Ftp.Connect;
   except on E:Exception do
   end;

   if Ftp.Connected then result := true
   else result := false;
end;

procedure TForm1.StartUpdate;
begin

   if ServerConnect then begin      // 서버 접속
      FDownLoadList.Clear;
      if SetUpdateList(FDownLoadList) then begin   // 업데이트 목록 받아옴.
         Show;                                     // 파일 전송량을 보여주기 위해
         FTPDownLoad;
      end;
   end;
end;

// 응용프로그램을 실행한다.
procedure TForm1.btnConClick(Sender: TObject);
var
  iMode : integer;
  function CheckEmpty( aEdt : TLabeledEdit ) : boolean;
  begin
    if aEdt.Text = '' then begin
      Result := false;
      aEdt.SetFocus;
    end else Result := true;
  end;

begin
  if not CheckEmpty( edtID ) then Exit;
  if not CheckEmpty( edtPW ) then Exit;

  ConConfig.t0LeeID    := edt0LeeID.Text;
  ConConfig.t0LeePW    := edt0LeePW.Text;
  ConConfig.tUserID    := edtID.Text;
  ConConfig.tPassword  :=  edtPW.Text;
  ConConfig.tCertPass  := edtCert.Text;
  ConConfig.tUseMock   := cbMock.Checked;
  ConConfig.tUseSave   := cbSaveInput.Checked;

  SaveLoginInfo;


  gbDown.Left := gbLogin.Left;
  gbLogin.Visible := false;
  gbDown.Visible  := true;

  Button1.Enabled := false;

  ftpInit;
  FDownLoadList := TStringList.Create;
  Timer.Enabled := true;
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  strs : TStringList;
  aParser : TParser;
  stID, s, stDate : string;
  iCnt, iCode : integer;
begin
  try
    btnCon.Enabled  := false;
    Button1.Enabled := false;
    strs := TStringList.Create;

    stResult.Caption  := '인증완료 몇분 소요될수 있습니다.';

    strs.Values['code']    := FtpInfo.CertCode;
    strs.Values['user_id'] := edt0LeeID.Text;
    strs.Values['user_pw'] := edt0LeePW.Text;

    //s := idh.Post('https://service.ylrms.com:124/auth', strs);
    s := idh.Post('http://service.ylrms.com/auth', strs);

    aParser := TParser.Create([',']);
    iCnt := aparser.Parse( s );

    if iCnt <= 0 then
    begin
      stResult.Caption  := ('통신에 문제 발생 다시 시도해주세요' ) ;
      Exit;
    end;
    iCode := StrToInt(trim( aParser[0] ));

    if iCnt < 2 then
      stDate := ''
    else
      stDate := aParser[1];

    case iCode of
      0 :
        begin
          stResult.Caption  := Format('인증 성공 , %s 까지 사용가능', [ stDAte ]) ;
          stID  := trim( aParser[2] );

          ConConfig.Save0LeeID  := edt0LeeID.Text;
          ConConfig.Save0LeePW  := edt0LeePW.Text;

          if cbMock.Checked then
          begin
            if stID = ConConfig.SaveID[1] then
            begin
              edtID.Text  := ConConfig.SaveID[1];
              edtPW.Text    := ConConfig.SavePW[1];
              edtCert.Text  := ConConfig.SaveCert[1];
            end
            else edtID.text  := stID;
          end
          else begin
            if stID = ConConfig.SaveID[0] then
            begin
              edtID.Text  := ConConfig.SaveID[0];
              edtPW.Text  := ConConfig.SavePW[0];
              edtCert.Text  := ConConfig.SaveCert[0];
            end else edtID.text  := stID;
          end;

          btnCon.Enabled := true;
          btnExit.Enabled:= true;

        end;

      1 : stResult.Caption  := '솔루션 코드 에러';
      2 : stResult.Caption  := '아이디 없음';
      3 : stResult.Caption  := '비밀번호 에러';
      4 : stResult.Caption  := Format('사용기간 만료, %s 까지 사용가능', [ stDAte ]) ;
      5 : stResult.Caption  := '기타 에러';
    end;

  finally
    Button1.Enabled := true;
    aParser.Free;
    strs.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //
  Ftp.Abort;
  Ftp.Disconnect;
  gbLogin.Visible := true;
  gbDown.Visible  := false;
  //if fstream <> nil then fstream.Free;

end;

procedure TForm1.cbMockClick(Sender: TObject);
var
  stID : string;
begin
  stID  := edtID.Text;
  if cbSaveInput.Checked then
    if cbMock.Checked then
    begin
      if stID = ConConfig.SaveID[1] then
      begin
        edtID.Text  := ConConfig.SaveID[1];
        edtPW.Text    := ConConfig.SavePW[1];
        edtCert.Text  := ConConfig.SaveCert[1];
      end
      else edtID.text  := stID;
    end
    else begin
      if stID = ConConfig.SaveID[0] then
      begin
        edtID.Text  := ConConfig.SaveID[0];
        edtPW.Text  := ConConfig.SavePW[0];
        edtCert.Text  := ConConfig.SaveCert[0];
      end else edtID.text  := stID;
    end;

end;

procedure TForm1.edtIDKeyPress(Sender: TObject; var Key: Char);
var
  iLen : integer;
begin
  iLen  := Length( (Sender as TLabeledEdit ).Text );
  if (iLen > 7 ) and ( key <> #8 )  then
    Key := #0;
end;

procedure TForm1.ExecuteMainProgram;
begin         {
   if FileExists(FExecFile) then WinExec(PChar(FExecFile), SW_SHOW)
   else  ShowMessage('응용 로그램을 찾을수가 없습니다.');
   }
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
   TTimer(Sender).Enabled := False;
   StartUpdate;
   ExeMainApp;
   //TTimer(Sender).Enabled := true;
   Close;
end;

function TForm1.FindDir( stFileName : string ) : string;
var
  I: Integer;
begin
  Result := ExtractFilePath( paramstr(0) );
  for I := 0 to High( Launcher ) do
    if (Launcher[i].Target = stFileName) then
    begin
      Result := Result+Launcher[i].Path;
      Break;
    end;
end;

// 업데이트 목록을 가져온다.
function TForm1.SetUpdateList(DownloadList : TStringList) : Boolean;
var
   i           : integer;
   ARecord     : TidFTPListItem;
   stdir, sFileName   : string;
   iFtpFile    : int64;
   iMyComFile  : int64;
   sl          : TStringList;
begin
   FAllFileSize := 0;
   FAllFileCnt  := 0;

   if not Assigned(DownloadList) then begin
      result := false;
      Exit;
   end;

   if not Ftp.Connected then begin
      result := false;
      Exit;
   end;

   Ftp.ChangeDir( FtpInfo.RemotePath );

   sl := TStringList.Create;
   sl.Clear;

   Ftp.List(sl);



   for i := 0 to sl.Count - 1 do begin
      ARecord := Ftp.DirectoryListing.Items[i];
      if not (ARecord.ItemType = ditDirectory) then begin
         sFileName := ARecord.FileName;
         // 파일마다..놓이는 위치가 틀리기땜시..
         sFileName := FindDir( sFileName )+ sFileName;
         if FileExists(sFileName) then begin
            iFtpFile    := StrToInt64(FormatDateTime('YYMMDDhhmmss', ARecord.ModifiedDate));
            iMyComFile  := StrToInt64(FormatDateTime('YYMMDDhhmmss', FileDateToDateTime(FileAge( sFileName))));
            if ( iFtpFile > iMycomFile) or (ARecord.Size <> GetSizeOfFile(sFileName)) then begin
               DownloadList.AddObject(ARecord.FileName, ARecord );
               FAllFileSize := FAllFileSize + ARecord.Size;       // 전체 다운로드 용량 계산
            end;
         end
         else begin
            DownloadList.AddObject(ARecord.FileName, ARecord );
            FAllFileSize := FAllFileSize + ARecord.Size;          // 전체 다운로드 용량 계산
         end;
      end; //if not (ItemType = ditDirectory)
   end;
   if DownLoadList.Count > 0 then begin
      result := True;
   end
   else result := False;
   sl.Free;
end;

// 파일 사이즈 알아내기
function TForm1.GetAppdiv( bKor : boolean ): string;
begin
  if bKor then
    case FtpInfo.ApiDiv[1] of
      '1' : Result := '해외';
      '0' : Result := '국내';
    end
  else
    case FtpInfo.ApiDiv[1] of
      '1' : Result := 'Ex';
      '0' : Result := 'kr';
    end;

end;

function TForm1.GetSecName( bKor : boolean ): string;
begin

  if bKor then
    case FtpInfo.SecName[1] of
      'A' : Result := 'KR선물';
      'B' : Result := '동부증권';
    end
  else
    case FtpInfo.SecName[1] of
      'A' : Result := 'krfut';
      'B' : Result := 'Dongbu';
    end;
end;

function TForm1.GetSizeOfFile(const FilenName:string) : Longint;
var
   FHandle : Integer;
begin
   if FileExists(FilenName) then begin
      FHandle := FileOpen(FilenName, fmOpenRead+fmShareDenyNone);
      Result  := GetFileSize(FHandle, nil); // GetFileSize는 Win32API
      FileClose(FHandle);
   end
   else Result  := 0;
end;

//파일다운
procedure TForm1.FTPDownLoad;
var
   i, FHandle  : integer;
   ARecord     : TidFTPListItem;
   stTmp, sFileName   : string;
   fstream : TFileSTream;
begin

   if not Ftp.Connected then exit;
   Ftp.TransferType := ftBinary;

   //Animate.Visible := True;
   lbFilecnt.Caption  := Format('(0/%d)', [  FDownLoadList.Count ]);
   FFileCnt           := 0;
   ProgressBar2.Max := FAllFileSize;

   for i := 0 to FDownLoadList.Count - 1 do begin
      ARecord :=  TidFTPListItem( FDownLoadList.Objects[i] );//  Ftp.DirectoryListing.Items[i];
      FFileSize := ARecord.Size;
      sFileName := FindDir( ARecord.FileName )+ ARecord.FileName;
      if FileExists(sFileName) then begin
         FileSetAttr(sFileName, faArchive);
      end;
      lbFileName.Caption  := ARecord.FileName;
//      fstream := nil;
//      fstream := TFileStream.Create( sFileName, fmCreate);

      //Ftp.Get(ARecord.FileName, fstream);
      Ftp.Get(ARecord.FileName, sFileName, True);
      FHandle  := FileOpen(sFileName, fmOpenReadWrite);
      FileSetDate(FHandle, DAteTimeToFileDate(ARecord.ModifiedDate));
      FileClose(FHandle);
//      fstream.Free;
   end;
   ProgressBar2.Position := 0;

   //Animate.Active    := False;
   //Animate.Visible   := False;
end;


procedure TForm1.FtpWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Integer);
var
   dAvgSpeed               : Double;
   sAvgSpeed               : String;
   TotalTime               : TDateTime;
   wHour, wMin, wSec, wmSec: Word;
   dSec                    : Double;
begin
   dAvgSpeed   := 0;
   TotalTime   :=  Now - FStartTime;
   DecodeTime(TotalTime, wHour, wMin, wSec, wmSec);
   wSec := wHour * 3600 + wMin * 60 + wSec;
   dSec := wSec + wmSec / 1000;

   if dSec > 0 then dAvgSpeed := (AWorkCount / 1024) / dSec;

   sAvgSpeed := FormatFloat('0.00 KB/s', dAvgSpeed);
   case AWorkMode of
      wmRead: Label_AvgSpeed.Caption := sAvgSpeed;
   end;

   ProgressBar1.Position   := AWorkCount;
   ProgressBar2.Position   := FAllFileSizing + AWorkCount;
   Label_Count.Caption := Format('%d Byte',[ AWorkCount]);
   Application.ProcessMessages;
end;

procedure TForm1.FtpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Integer);
begin
   ProgressBar1.Position := 0;
   FStartTime  := Now;
  if AWorkCountMax > 0 then
     ProgressBar1.Max := AWorkCountMax
  else
     ProgressBar1.Max := FFileSize;
end;

procedure TForm1.FtpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
var
  i : integer;
begin
   FAllFileSizing := FAllFileSizing + FFileSize;
   FStartTime  := 0;
   ProgressBar1.Position := 0;
   inc(FFileCnt);
   lbFilecnt.Caption  := Format('(%d/%d)', [ FFileCnt, FDownLoadList.Count ]);
end;

procedure TForm1.loadConfigFile;
var
  s, d, stTmp, stSection : string;
  aIni : TInitFile;
  I, iCnt: Integer;
begin
  // FTP
  stSection  := 'TITLE';
  FtpInfo.SecName   := FIni.GetString(stSection,'SEC');
  FtpInfo.ApiDiv    := FIni.GetString(stSection,'DIV');
  FtpInfo.RegOpenKeyIni    := FIni.GetString(stSection,'RegKeyIni');
  FtpInfo.CertCode         := FIni.GetString(stSection,'CertCode');

  stSection  := 'FTP';
  FtpInfo.FtpIP      := FIni.GetString(stSection,'IP');
  FtpInfo.FtpUser    := FIni.GetString(stSection,'ID');
  FtpInfo.FtpPass    := 'update';//FIni.GetString(stSection,'PS');

  FtpInfo.RemotePath := FIni.GetString(stSection,'Remote');
  FtpInfo.LocalPath  := FIni.GetString(stSection,'LocalPath');

  FtpInfo.FileName   := FIni.GetString(stSection,'iniFile');;
  ExeName            := FIni.GetString(stSection,'exeName');;

  cbMock.Visible  := FIni.GetInteger('Config','ShowMock') = 1;

  // 현재의 버전 정보를 읽어온다....
  iCnt  := Fini.GetInteger( 'Update', 'COUNT');
  SetLength( Launcher , icnt );

  for I := 1 to iCnt  do
  begin
    stSection := 'Update'+IntToStr(i);
    Launcher[i-1].Target  := FIni.GetString(stSection,'FileName');;
    Launcher[i-1].Path := Fini.GetString( stSection, 'Path');
  end;

  FIni.Free;

end;

procedure TForm1.LoadRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(FtpInfo.RegOpenKeyIni, True) then begin
   // if OpenKey(RegOpenKeyIni, True) then begin

      if ValueExists('SaveInput' ) then  ConConfig.SaveInput := ReadBool('SaveInput')
      else ConConfig.SaveInput := false;
      if ValueExists('RealMode' ) then  ConConfig.RealMode := ReadBool('RealMode')
      else ConConfig.RealMode := true;

      if ValueExists('InputID0' ) then  ConConfig.SaveID[0] := ReadString('InputID0')
      else ConConfig.UserID := '';
      if ValueExists('InputPW0' ) then  ConConfig.SavePW[0] := ReadString('InputPW0')
      else ConConfig.Password := '';
      if ValueExists('InputCert0' ) then  ConConfig.SaveCert[0] := ReadString('InputCert0')
      else ConConfig.CertPass := '';

      if ValueExists('InputID1' ) then  ConConfig.SaveID[1] := ReadString('InputID1')
      else ConConfig.UserID := '';
      if ValueExists('InputPW1' ) then  ConConfig.SavePW[1] := ReadString('InputPW1')
      else ConConfig.Password := '';
      if ValueExists('InputCert1' ) then  ConConfig.SaveCert[1] := ReadString('InputCert1')
      else ConConfig.CertPass := '';

      // young_Lee
      if ValueExists('Input0LeeID' ) then  ConConfig.Save0LeeID := ReadString('Input0LeeID')
      else ConConfig.Save0LeeID := '';
      if ValueExists('Input0LeePW' ) then  ConConfig.Save0LeePW := ReadString('Input0LeePW')
      else ConConfig.Save0LeePW  := '';
      if ValueExists('InputOLeeCode' ) then  ConConfig.Save0LeeCode := ReadString('InputOLeeCode')
      else ConConfig.Save0LeeCode := '';
    end;
  finally
    Free;
  end;
end;


procedure TForm1.SaveRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(FtpInfo.RegOpenKeyIni, True) then begin

      WriteBool('SaveInput', ConConfig.SaveInput );
      WriteBool('RealMode',  ConConfig.RealMode );

      WriteString('InputID0', ConConfig.SaveID[0] );
      WriteString('InputPW0', ConConfig.SavePW[0]);
      WriteString('InputCert0', ConConfig.SaveCert[0]);

      WriteString('InputID1', ConConfig.SaveID[1] );
      WriteString('InputPW1', ConConfig.SavePW[1]);
      WriteString('InputCert1', ConConfig.SaveCert[1]);

      WriteString('Input0LeeID', ConConfig.Save0LeeID);
      WriteString('Input0LeePW', ConConfig.Save0LeePW );
      WriteString('InputOLeeCode', ConConfig.Save0LeeCode );
    end;
  finally
    Free;
  end;
end;

procedure TForm1.LoadLoginInfo;

var fs: TFileStream; r:TReader;
    stFileName, st0ID, st0PW, stUID, stPswd, stCert: string;
    szBuf: array[0..255] of char;
begin
  stFileName := 'LoginInfo.dat';
  try
    fs := TFileStream.Create( stFileName, fmOpenRead );
    r := TReader.Create( fs, 1024 );

    r.Read( szBuf[0], 80 );
    utDecodeFlat( szBuf[0], 80 );
    st0ID   := Trim(Copy(szBuf,0, 16 ));
    st0PW   := Trim(Copy(szBuf,16, 16));
    stUID   := Trim(Copy(szBuf,32, 16));
    stPswd  := Trim(Copy(szBuf,48, 16));
    stCert  := Trim(Copy(szBuf,64, 16));

    ConConfig.t0LeeID    := st0ID;
    ConConfig.t0LeePW    := st0PW;
    ConConfig.tUserID    := stUID;
    ConConfig.tPassword  := stPswd;
    ConConfig.tCertPass  := stCert;
    ConConfig.tUseMock   := r.ReadBoolean;
    ConConfig.tUseSave   := r.ReadBoolean;
        
  finally
    if Assigned(r) then
      r.Free;
    if Assigned(fs) then
      fs.Free;
  end;
end;

procedure TForm1.SaveLoginInfo;
var stFileName : string; fs: TFileStream; w: TWriter;
   stPath,  stTmp: string; szBuf:array[0..255] of char;
begin

  stFileName := 'LoginInfo.dat';      // 저장될 파일명
  stPath := ExtractFilePath( paramstr(0) )+stFileName;

  stTmp := Format( '%-16s%-16s%-16s%-16s%-16s',  [
    ConConfig.t0LeeID,
    ConConfig.t0LeePW,
    ConConfig.tUserID,
    ConConfig.tPassword,
    ConConfig.tCertPass  ]);
  try
    if FileExists( stPath ) then
      DeleteFile( PChar(stPath) );

    fs := TFileStream.Create( stPath, fmCreate );
    w := TWriter.Create( fs, 1024 );

  // 사용자아이디 패스워드를 암호화하고 파일에 저장한다
    move( stTmp[1], szBuf[0], 80 );
    utEncodeFlat( szBuf[0], 80 );
    w.Write( szBuf[0], 80 );
    w.WriteBoolean( ConConfig.tUseMock );
    w.WriteBoolean( ConConfig.tUseSave );

  finally
    if Assigned(w) then
      w.Free;
    if Assigned(fs) then
      fs.Free;
  end;

end;

end.
