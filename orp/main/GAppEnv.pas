unit GAppEnv;

interface

uses
    // delphi libraries
  Classes, SysUtils,    Windows, Messages, Math, Forms,
    // lemon: common
  GleTypes,
  LemonEngine,
  CleSymbols, CleMySQLConnector, 

  CleLog,
  FFPopupMsg, FServerMessage,

  TimeSpeeds,
  FLogin,
  DleSymbolselect,
  DleAccountSelect,
  CBoardEnv  ,

  EnvUtil
  ;

type
  TInputData = record
    // new add woori fut
    UID : string;
    AcntNo : string;
    AcntPw : string;
    MemNo  : string;    // 회원번호
    BraNo  : string;    // 지점번호
    SID    : string     // 서버 ID
  end;



  TConConfig = record

    UserName  : string;
    UserID    : string;
    Password  : string;
    CertPass  : string;
    SaveInput : boolean;
    // 마지막 접속..
    RealMode  : boolean;

    // 모의...
    SaveID    : array [0..1] of string;
    SavePW    : array [0..1] of string;
    SaveCert  : array [0..1] of string;
    // 영리 아뒤/ 패스
    {
    Save0LeeID    : string;
    Save0LeePW    : string;
    Save0LeeCode  : string;
    // 임시....
    tUserID    : string;
    tPassword  : string;
    tCertPass  : string;
    t0LeeID    : string;
    t0LeePW    : string;
    tUseMock   : boolean;
    tUseSave   : boolean;
    }

    // 주식선물 사용할지
    UseSFut   : boolean;

    ApType    : string;
    // ftp
    FtpIP     : string;
    FtpID     : string;
    FtpPass   : string;
    FtpRemoteD: string;
    FtpLocalD : string;
    // DB
    DbIP      : string;
    DbID      : string;
    DbPass    : string;
    DbSource  : string;
    Mdb       : string;
    UseMdb    : boolean;

    StartOrderNo : int64;
    EndOrderNo   : int64;
    LastOrderNo  : int64;

    LastDate     : TDateTime;
    IncCount     : integer;
    //
    SisAddr      : string;
    TradeAddr    : string;
    TradeAddr2   : string;
    MacAddr      : string;
    Port         : integer;
   {
    UdpDuraPort : integer;
    UdpDuraIP : string;
    }
  end;

  TFillSound = record
    FillSnd : string;
    IsSound : boolean;
    DelayMs : double;
  end;

  TRunModeType = ( rtRealTrading, rtSimulUdp , rtSimulation );
  TUserType   =  ( utBeta, utNormal, utStaff, utAdmin  );

  // 차세대 이전, 차세대
  TPacketVersion  = ( pv0, pv1, pv2, pv3, pv4 );

  TDistributeType = record
    Used  : boolean;
    MS    : integer;
  end;


  TOrderSpeed = record
    AvgAcptTime : DWORD;
    AvgChgTime  : DWORD;
    AvgCnlTime  : DWORD;
    OrderCount  : integer;
    OrderCnlCnt : integer;
    OrderChgCnt : integer;
  end;

  TBoardCon = record
    SaveDate  : string;
    TodayNoShowDlg : boolean;
  end;

  TUdpPort  = record
    Port    : integer;
    Use     : boolean;
    UseMulti: boolean;
    MultiIP : string;
    Name    : string;
    MarketType : string;
  end;

  TCost = record
    FDues : string;
    FCost : string;
    ODues : string;
    OCost : string;
  end;

  TFees = record
    FFee  : double;
    OFee  : double;
  end;

  TAppEnv = record
    Main  : TForm;
    //
    MainBoard : TForm;

    YoungLee : boolean;
    Beta     : boolean;
    Simul : boolean;
    Engine: TLemonEngine;
    Log   : TLogThread;

    PacketVer : TPacketVersion;
    AppPid: DWord;

    Cost    : TCost;
    Fees    : TFees;

    UserType  : TUserType;
    RunMode : TRunModeType;
    UseVFEP : boolean;
    AppDate : TDateTime;
    PrevAppDate : TDateTime;
    DBMode  : boolean;

    OrderSpeed  : TOrderSpeed;
    BoardCon : TBoardCon;

    Trade : TObject;
    Info  : TFrmServerMessage;

    LogInOut : char;

    LogDir : string;
    RootDir: String;   // application root directory
    DataDir: String;   // application data directory
    OutputDir: String; // application output directory
    ApiRootDir : string;
    QuoteDir: string;
    TemplateDir : string;
    SimulDir  : string;
    ErrString : string;

    Input : TInputData;
    ConConfig : TConConfig;

    SaveID : array [0..2] of string;
    SavePW : array [0..2] of string;
    SaveCert : array [0..2] of string;

    // 0 : fut sis delay
    // 1 : call sis dealy , 2 : put sis dealy
    // 3 : 잔량스탑 , 4 : 프런트쿼팅
    FillSnd   : array [TOrderSpecies] of TFillSound;

    //MySQLConnector: TMySQLConnector;

    // 프로시져(함수) 포인터
    OnLog: TTextNotifyEvent; // event for log
    // 프로시져(함수) 포인터
    OnState : TAsNotifyEvent;
    // 윈도우 핸들
    AnyHandle: HWND;

    RecoveryEnd : boolean;
    StopGroupID : integer;
    
    procedure SetAppStatus(const Value: TAppStatus);
    procedure SimulationReady;
    procedure DoLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
    procedure EnvLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
    procedure OrderNoLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
    procedure FreeLog;
    procedure ShowMsg( stType , stMsg : string; bLog : boolean = true );
    procedure AppMsg( stType , stMsg : string );

    procedure SetRunMode( iMode : integer );
    procedure SetDBMode(iMode: integer);
    procedure CreateAppLog;
    procedure CreateTimeSpeeds;
    procedure CreateSymbolSelect;
    procedure CreateAccountSelect;
    procedure CreateLogin(aObj : TObject);
    procedure CreateBoardEnv;
    procedure SetFees;
    function  CheckPacketVersion : boolean;
             {
    function LoadLoginInfo : boolean;
    procedure SaveLoginInfo;
              }
    function GetStopGroupID: integer;
  end;

procedure DoEnvLog(Sender: TObject; stLog: String);
procedure AddLog( lkValue : TLogKind;
                  stSource, stTitle, stDesc : String; iLogLevel : Integer = 0);


var
  gEnv  : TAppEnv;
  gUseB : Boolean = False;
  gLog  : TAppLog;
  gClock  : TTimeSpeed;
  gSymbol : TSymbolDialog;
  gAccount: TFrmAcntSelect;
  gBoardEnv : TBoardEnv;
  gLogin    : TFrmLogin;

const
  KRX_FQN ='krx.kr';

  WIN_LOG ='win';

  WIN_ORD ='ord';
  WIN_TEST='test';
  WIN_GI  ='Gi';

  WIN_VIR ='vir';
  WIN_TS  ='TS';
  WIN_PACKET = 'Packet';
  WIN_LINK  = 'Link';

  WIN_SIS   = 'sis';

  //
  WIN_DEBUG = 'Debug';
  WIN_ERR   = 'Err';
  WIN_APP   = 'App';
  WIN_KEYORD= 'KeyOrd';
  WIN_WARN  = 'Warn';
  WIN_RJT   = 'Rjt';
  WIN_LOSS  = 'Loss';
  WIN_REC   = 'Rec';

  //
  WIN_TRDSTOP = 'TrdStop';
  WIN_JJUNG2 = 'JJUNG2';
  WIN_JPOS  = 'JPOS';
  WIN_SIMUBAO = 'SimulBAO';
  WIN_ENTRY = 'Entry';
  WIN_RISK = 'Risk';
  WIN_CATCH = 'Ctch';
  WIN_ARB = 'Arb';
  WIN_STR = 'Strangle';
  WIN_YH = 'YH';
  WIN_CP = 'Parity';
  WIN_RATIO = 'Ratio';
  WIN_STR2 = 'Strangle2';
  WIN_STR3 = 'Strangle3';
  WIN_INV = 'Investor';
  WIN_REPORT = 'Report';
  WIN_HL = 'HL';
  WIN_HULT = 'HULT';
  WIN_RATIOS = 'RatioS';
  WIN_TREND = 'trend';

  WIN_BHULT = 'BanHULT';
  WIN_JIK_HULT = 'JikJinHult';
  WIN_WOOK = 'Wook';
  WIN_SHORTHULT = 'ShortHult';
  WIN_DEFORD = 'OrderBoard';
  WIN_FUNDORD = 'FundOrderBoard';
  WIN_USDF = 'UsdFut';

  WIN_MC  = 'MC';
  WIN_PARK = 'PARK';

//procedure LoadEnv(stFile: String);
//procedure SaveEnv(stFile: String);

implementation



{ TAppEnv }

procedure TAppEnv.AppMsg(stType, stMsg: string);
begin
  PopupMessage( stMsg );
  EnvLog( WIN_ERR, stMsg );
end;

function TAppEnv.CheckPacketVersion: boolean;
var
  dtDate, dtDate1, dtDate2, dtDate3 : TDateTime;
  stDate, stDate1 : string;
begin
  dtDate  := EncodeDate(2009, 3, 22);
  dtDate1 := EncodeDate(2014, 2, 28);
  dtDate2 := EncodeDate(2014, 8, 31);
  dtDate3 := EncodeDate(2015, 6, 15);
  stDate  := FormatDateTime( 'yyyy-mm-dd hh:mm:ss', Floor(AppDate));
  stDate1 := FormatDateTime( 'yyyy-mm-dd hh:mm:ss', dtDate1);
  if Floor(AppDate) < dtDate then
    PacketVer := pv0
  else if (Floor(AppDate) >= dtDate) and (Floor(AppDate) <= dtDate1) then
    PacketVer := pv1
  else if (Floor(AppDate) > dtDate1) and (Floor(AppDate) <= dtDate2) then
    PacketVer := pv2
  else if (Floor(AppDate) > dtDate2) and (Floor(AppDate) < dtDate3) then
    PacketVer := pv3
  else if (Floor(AppDate) >= dtDate3) then
    PacketVer := pv4;
end;

procedure TAppEnv.CreateAppLog;
begin
  gLog  := TAppLog.Create;
end;

procedure TAppEnv.CreateBoardEnv;
begin
  gBoardEnv := TBoardEnv.Create;
  StopGroupID := 100;
end;

procedure TAppEnv.CreateLogin( aObj : TObject );
begin
  gLogIn := TFrmLogin.Create(aObj as TComponent);
end;

procedure TAppEnv.CreateSymbolSelect;
begin
  gSymbol := TSymbolDialog.Create(nil);
end;

procedure TAppEnv.CreateAccountSelect;
begin
  gAccount := TFrmAcntSelect.Create(nil);
  //gAccount.Hide;
end;

procedure TAppEnv.CreateTimeSpeeds;
begin
  gClock  := TTimeSpeed.Create;
end;

procedure TAppEnv.DoLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
begin
  gEnv.EnvLog( stDir, stData, bmaster, stFile);
end;

procedure TAppEnv.FreeLog;
begin
  Log.Terminate;
  Log.LogQueue.Free;
end;

function TAppEnv.GetStopGroupID: integer;
begin
  StopGroupID := StopGroupID + 1;
  Result := StopGroupID;
end;

  {
function TAppEnv.LoadLoginInfo : boolean;

var fs: TFileStream; r:TReader;
    stFileName, st0ID, st0PW, stUID, stPswd, stCert: string;
    szBuf: array[0..255] of char;
begin
  Result := false;
  stFileName := gEnv.RootDir + '\LoginInfo.dat';

  if not FileExists( stFileName ) then Exit;
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

    Result := true;

  finally
    if Assigned(r) then
      r.Free;
    if Assigned(fs) then
      fs.Free;

    if FileExists( stFileName ) then
      DeleteFile( PChar(stFileName) );


         
  end;
end;

procedure TAppEnv.SaveLoginInfo;
var stFileName : string; fs: TFileStream; w: TWriter;
     stTmp: string; szBuf:array[0..255] of char;
begin
  stFileName := 'LoginInfo.dat';      // 저장될 파일명

  stTmp := Format( '%-16s%-16s%-16s%-16s%-16s',  [
    ConConfig.Save0LeeID,
    ConConfig.Save0LeePW,
    ConConfig.UserID,
    ConConfig.Password,
    ConConfig.CertPass  ]);
  try
    if FileExists( stFileName ) then
      DeleteFile( PChar(stFileName) );

    fs := TFileStream.Create( stFileName, fmCreate );
    w := TWriter.Create( fs, 1024 );

  // 사용자아이디 패스워드를 암호화하고 파일에 저장한다
    move( stTmp[1], szBuf[0], 80 );
    utEncodeFlat( szBuf[0], 80 );
    w.Write( szBuf[0], 80 );
    w.WriteBoolean( not ConConfig.RealMode );
    w.WriteBoolean( ConConfig.SaveInput );

  finally
    if Assigned(w) then
      w.Free;
    if Assigned(fs) then
      fs.Free;
  end;

end;
  }

procedure TAppEnv.OrderNoLog(stDir, stData: String; bMaster: boolean;
  stFile: string);
begin
  Log.LogPushQueue2(stDir, stData, bMaster, stFile);
end;

procedure TAppEnv.EnvLog(stDir, stData: String; bMaster: boolean;
  stFile: string);
begin
  Log.LogPushQueue(stDir, stData, bMaster, stFile);
end;

procedure TAppEnv.SetAppStatus(const Value: TAppStatus);
begin
  // Assigned 함수는 매개 변수가 참조하는 포인터 또는 프로시저가 할당되어 있는지 검사하는 함수.
  if Assigned( OnState ) then
    if Engine.AppStatus <> Value then
    begin
      if Engine.AppStatus = asLoad then
        Exit;

      Engine.AppStatus :=  Value;
      OnState( Value );
    end;
end;


procedure TAppEnv.SetRunMode(iMode: integer);
begin
  case iMode of
    0 : RunMode := rtRealTrading;
    1 : RunMode := rtSimulUdp;
    2 : RunMode := rtSimulation;
  end;

  if iMode in [1..2] then
    Simul := true
  else
    Simul := false;

end;

procedure TAppEnv.SetDBMode(iMode: integer);
begin
  case iMode of
    0 : DBMode  := true;
    1 : DBMode  := false;
  end;
end;

// 거래세 
procedure TAppEnv.SetFees;
begin
  // env 파일에는 퍼센트값 읽어옴.. 뒤에 천을 곱하는 이유는..거래대금을 /1000 으로 계산하기 때문에
  Fees.FFee :=  (StrToFloatDef( Cost.FDues,0.0 ) + StrToFloatDef( Cost.FCost,0.0 ))
        / 100.0 * 1000.0;
  Fees.OFee :=  (StrToFloatDef( Cost.ODues,0.0 ) + StrToFloatDef( Cost.OCost,0.0 ))
        / 100.0 * 1000.0;

  try
//    gEnv.EnvLog( WIN_APP, Format('수수료 -->  Fut : %.4f , Opt : %.4f', [ Fees.FFee, Fees.OFee ] ));
  except
  end;
end;

procedure TAppEnv.ShowMsg(stType, stMsg: string; bLog : boolean);
begin
  PopupMessage( stMsg );
  if bLog then
    DoLog( stType, stMsg );
end;

procedure TAppEnv.SimulationReady;
begin
  OnState( asSimul );
end;


procedure DoEnvLog(Sender: TObject; stLog: String);
begin
  if Assigned(gEnv.OnLog) then
    gEnv.OnLog(Sender, stLog);
end;


procedure AddLog( lkValue : TLogKind;
                  stSource, stTitle, stDesc : String; iLogLevel : Integer = 0);
begin

end;


end.



