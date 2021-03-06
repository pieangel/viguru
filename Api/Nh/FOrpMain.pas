// 유닛 헤더  : 유닛 이름. 다른 유닛에서 사용할 때 필요 하다.  일종의 헤더 파일 역할도 한다.
unit FOrpMain;

interface

// 사용할 다른 유닛 열거  - 코드 유닛에서는 uses 를 수동으로 추가해 줘야 한다. 
uses
// 표준 유닛 자동 추가
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ToolWin, Menus, Math, Shellapi, DateUtils,

    // lemon: common
  GleTypes, GleLib, LemonEngine,
    // lemon: symbol
  DleSymbolSelect, CleQuoteTimers,
    // lemon: trade
  FleOrderList2,
    // lemon: util
  CleStorage,
    // lemon: KRX
  CleFTPConnector,   CleApiReceiver, CleAccountLoader,  CleApiManager,
  CleKrxSymbols,

  // Vi Consts
  ApiConsts,

    // app
  GAppEnv, GAppConsts, GAppForms, StreamIO, NhDataMenu,
    // app: forms
  ActiveX,
  ExtCtrls, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdFTP, IdBaseComponent, IdAntiFreezeBase,
  IdAntiFreeze, OleCtrls, IdHTTP, WRAXLib_TLB, OleServer, HDFCommAgentLib_TLB
  ;
// 주석임
{$INCLUDE define.txt}
// 상수 정의 . 상수는 굳이 형을 쓸 필요가 없다. 써도 된다.
const
  RegRootKey = HKEY_LOCAL_MACHINE;
  RegOpenKeyIni = '\SOFTWARE\NHIN\GURU\';

// 데이터 타입 
type
  TOrpMainForm = class(TForm)
    MemoLog: TMemo;
    StatusBar: TStatusBar;
    plInfo: TPanel;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    N26: TMenuItem;
    Exit2: TMenuItem;
    pb: TPaintBox;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    WRAX1: TWRAX;
    HDFCommAgent1: THDFCommAgent;
    Timer4: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Show1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure pbDblClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure pbPaint(Sender: TObject);
  private
    FSymbolCodeReqCount: Integer;
    FEngine: TLemonEngine;
    FQuoteTimer: TQuoteTimer;
    FAcntLoader: TAccountLoader;
    FCertSucces: boolean;
    FIsActive: boolean;

    procedure QuoteTimerProc(Sender: TObject);
    procedure QuoteTime(Sender: TObject; Value: TDateTime);

    procedure OrderReset( Sender : TObject; bBack : boolean; Value : Integer );
    //procedure QuoteDateChanged(Sender: TObject; Value: TDateTime);

    procedure DoLog(Sender: TObject; stLog: String);
    procedure DoTimeLog(Sender: TObject; stLog: String);
    procedure AppException(Sender: TObject; E: Exception);
    //*^^*
    procedure OnAppState( asType : TAppStatus );
    function LoadConfig : boolean;

    procedure LoadRegedit;
    procedure SaveRegedit;

    procedure SaveProfitNLoss;
    procedure BackUpWindows;

    function CheckRemainActiveOrder: boolean;

    procedure LogInEnd;

    procedure StartReqSymbolCode;
    procedure StartReqSymbolMaster;

    function CheckFileDate: boolean;
    function IsStaff: boolean;


    { Private declarations }
  public
    { Public declarations }
    m_stIni : string;
    function FindGiComponet( stName : string ) : boolean;
      // 모드별 분기
    procedure BranchMode;
    procedure StepInitSymbolLoad;
    procedure SetpRecoveryEnd;
    procedure initQ;
    procedure StepSimulation;
    procedure FillAccountPass;
    procedure OnWindowMenuClick(Sender: TObject);

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);

    property AcntLoader: TAccountLoader read FAcntLoader;

    property IsActive : boolean read FIsActive;
    // only young_lee
    property CertSucces: boolean read FCertSucces;

  end;

var
  OrpMainForm: TOrpMainForm;

function RunAsAdmin(hWnd: HWND; filename: string; Parameters: string; bNeedReg: boolean): Boolean;
// 실제 코드 
implementation
// 이 유닛에서만 사용 가능한 선언들임. 
uses CalcGreeks, CleIni, CleLog,  Registry, CleFQN,CleFormBroker, CleParsers,
  GleConsts, CleExcelLog, CleOrders,  CleSymbols,
  TLHelp32,  FAppInfo,  CleInvestorData,
  DBoardEnv,  FAccountPassWord, FServerMessage, FQryTimer
  ;                 

{$R *.dfm}
// 관리자 권한으로 실행
function RunAsAdmin(hWnd: HWND; filename: string; Parameters: string; bNeedReg: boolean): Boolean;
var

    sei: TShellExecuteInfo;
    st1, st2 : string;

begin

    st1 := ExtractFilePath( paramstr(0) )+filename;
    st2 := ExtractFilePath( paramstr(0) )+Parameters;
    ZeroMemory(@sei, SizeOf(sei));
    sei.cbSize := SizeOf(TShellExecuteInfo);
    sei.Wnd := hwnd;
    sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
    sei.lpVerb := PChar(st1);
    sei.lpFile := PChar(st2); // PAnsiChar;

    if parameters <> '' then
    begin
      sei.lpParameters := PChar(parameters); // PAnsiChar;
    end;

    sei.nShow := SW_SHOWNORMAL; //Integer;
    Result := ShellExecuteEx(@sei);

end;
//Exit : 현재 Procedure를 빠져나와 원래의 루틴으로 복귀하여 일을 처리한다.

//Abort : 현재 시점에서 모든 루틴을 종료한다.
//-----------------------------------------------------------------< init >
// 계좌 비밀 번호 채우기 
procedure TOrpMainForm.FillAccountPass;
var
  aForm : TFrmAccountPassWord;
begin

  if gEnv.UserType = utStaff then
  begin
    FEngine.SendBroker.RequestAccountData;
    Exit;
  end else
  if gEnv.UserType = utNormal then
  begin
    aForm := TFrmAccountPassWord.Create( Self );
    try
      if aForm.Open then
      begin
        // 예수금만 먼저 조회 ( 비번 맞는지 확인차 )
        FEngine.SendBroker.RequestAccountData;
      end else gEnv.SetAppStatus( asRecoveryEnd );
    finally
      aForm.Free;
    end;
  end; 
end;

function TOrpMainForm.FindGiComponet(stName: string): boolean;
var
  peList : TProcessEntry32;
  hL : THandle;
begin
  Result := False;
  peList.dwSize := SizeOf(TProcessEntry32);
  hL            := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(hL, peList) then begin
    repeat
      if CompareText(peList.szExeFile, stName) = 0 then begin
        Result := True;
        break;
      end;
    until not Process32Next(hL, peList);
  end;

  CloseHandle(hL);
end;

// 살아 남은 주문이 있는지 조사
function TOrpMainForm.CheckRemainActiveOrder : boolean;
var
  i, iVol, iCnt : integer;
  aOrder : TOrder;
  stLog : string;
  bExist: boolean;
begin
  Result := true;
  iCnt := gEnv.Engine.TradeCore.Orders.ActiveOrders.Count;

  if iCnt > 0 then
    stLog := Format('미체결 주문 : %d 개 존재 ', [ iCnt ]);

  iVol := 0;
  stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
  bExist := false;
  for i:=0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    //iVol := iVol +  gEnv.Engine.TradeCore.Positions.Positions[i].Volume;
    if gEnv.Engine.TradeCore.Positions.Positions[i].Volume <> 0 then
    begin
      stLog := stLog + Format('%s : %s 잔고 %d 존재', [ gEnv.Engine.TradeCore.Positions.Positions[i].Symbol.ShortCode,
        ifThenStr( gEnv.Engine.TradeCore.Positions.Positions[i].Volume > 0, '매수', '매도'),
        abs(gEnv.Engine.TradeCore.Positions.Positions[i].Volume)
        ]);
      stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
      bExist := true;
    end;
  end;

  if (iCnt > 0) or ( bExist ) then
  begin
    stLog  := stLog + '종료하시겠습니까?';
    if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      Result := true
    else
      Result := false;
  end;

end;

// 활성화 
procedure TOrpMainForm.FormActivate(Sender: TObject);
begin
  if ( FEngine <> nil ) and ( not FIsActive ) then
  begin
    // Timer1Timer( Timer1 );
    //Application.BringToFront;
    //Application.ActiveFormHandle
    BranchMode;
    FIsActive := true;
    gLog.Add( lkApplication,'TOrpMainForm','FormActivate','Guru Mode Start');

  end;
end;

// 폼 닫기
procedure TOrpMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
  bClose : boolean;
begin

  bClose := CheckRemainActiveOrder;
  if not bClose then
  begin
    Action := caNone;
    Exit;
  end;
    // save the working environment

  if gEnv.RecoveryEnd then
  begin
    gEnv.Engine.FormBroker.Save(ComposeFilePath([gEnv.DataDir, FILE_ENV]));
    gEnv.Engine.TradeCore.SaveFunds;
  end;

  FEngine.SendBroker.SubScribeAccount( false );
  FEngine.Api.Fin;
    // before free main form
    // free all work forms (required)
  for i := ComponentCount-1 downto 0 do
    if Components[i] is TForm then
      Components[i].Free;

  //Module.Free;
  SaveRegedit;

  FAcntLoader.Free;
  gSymbol.Free;
  gBoardEnv.Free;
    //
  FQuoteTimer.Free;
    //

  FEngine.Free;

  gLog.Free;
  gClock.Free;


  Action  := caFree;

end;

// 폼 파괴
procedure TOrpMainForm.FormDestroy(Sender: TObject);
begin
  //
  CoUninitialize;
end;

// 폼 생성
procedure TOrpMainForm.FormCreate(Sender: TObject);
var
  bValue : boolean;
  i, iParam  : integer;
  stParam : string;
  bResult : boolean;

  stLog, stMsg : string;

begin

  CoInitialize(nil);

  Application.OnException := AppException;

  Left := 0;
  Top := 0;

  FIsActive := false;

  // 앱 로그 객체 생성
  gEnv.CreateAppLog;
  // 로그 쓰레드 생성 
  gEnv.Log       := TLogThread.Create;

  // ini 파일 읽기
  if not LoadConfig then
  begin
    ShowMessage('관리자에게 문의하세요 비정상 종료합니다.');
    close;
  end;
  // 레지스트리 읽기
  LoadRegedit;

  gEnv.YoungLee := false;
  gEnv.Beta := false;

// 전처리 지시자 
{$IFDEF YOUNG_LEE}
  gEnv.YoungLee := true;
{$ENDIF}
{$IFDEF MY_GURU}
  gEnv.YoungLee := false;
  {$IFDEF Beta}
    gEnv.Beta := true;
  {$ENDIF}

{$ENDIF}


  // 인증 검사
  if ( gEnv.Beta ) and ( ParamCount <= 0 ) then
  begin
    ShowMessage('사용자 인증이 필요합니다.' );
    WinExec( 'grLauncher.exe', SW_SHOW );
    Application.Terminate;
  end;


  // 함수 포인터에 함수 할당
  // 앱 상태 함 수
  gEnv.OnState   := OnAppState;
  // 로그 함수 
  gEnv.OnLog     := DoLog;
  // 앱 실행 디렉토리
  gEnv.RootDir   := AppDir;
  // 데이터 파일 경로
  gEnv.DataDir   := ComposeFilePath([gEnv.RootDir, DIR_DATA]);
  // 출력 파일 경로 
  gEnv.OutputDir := ComposeFilePath([gEnv.RootDir, DIR_OUTPUT]);
  // 로그 경로 
  gEnv.LogDir    := ComposeFilePath([gEnv.RootDir, DIR_LOG]);
  // 시뮬레이션 경로
  gEnv.SimulDir  := ComposeFilePath([gEnv.RootDir, DIR_SIMUL]);
  // 시세 경로
  gEnv.QuoteDir  := ComposeFilePath([gEnv.RootDir, DIR_QUOTEFILES]);
  // 템플릿 경로
  gEnv.TemplateDir  := ComposeFilePath([gEnv.RootDir, DIR_TEMPLATE]);
  // 회복
  gEnv.RecoveryEnd  := false;

   {
    // 런처에서 넘어온 로그인 정보 읽기
  if gEnv.beta then
    if not gEnv.LoadLoginInfo then
    begin
      ShowMessage('로그인 정보가 없습니다.' );
      Application.Terminate;
    end;
   }

   Timer4.Enabled := false;

   FSymbolCodeReqCount := 0;
   // 엔진 포인터
  FEngine := TLemonEngine.Create;

  // 엔진 포인터 전역 변수
  gEnv.Engine := FEngine;
  // 메인 폼
  gEnv.Main   := Self;
  // 메인 보드
  gEnv.MainBoard  := nil;
  // 시간 측정 객체 생성
  gEnv.CreateTimeSpeeds;
  // 로그 설정 
  gLog.Add( lkApplication, 'TOrpMainForm', 'FormCreate', 'start' );
  // 사용자 타입
  gEnv.UserType := utNormal;
  // 자동 로그인 타이머 활성화
  Timer1.Enabled := true;
  // 도움말 힌트가 나오는 데 걸리는 시간
  Application.HintPause := 10;
  // 응용프로그램 캡션
  Caption := Format('%s Ver.%s', [Caption  , FileVersionToStr(Application.ExeName)]);


end;

// 파일의 만료 기간을 확인한다.
function TOrpMainForm.CheckFileDate : boolean;
var
  dtToday, dtDate, dtAdd : TDateTime;
  iDay : integer;
begin
  try
    Result  := true;
    dtDate  := EnCodeDate( 2016, 8, 1 );
    dtAdd   := IncMonth( dtDate, 2 );

    dtToDay := gEnv.Engine.Api.GetCurrentDate(true);
    gEnv.EnvLog( WIN_TEST, Format( 'Today is %s, StartDate is %s,  LastDate is %s  ', [
      FormatDateTime('yyyy-mm-dd', dtToday),
      FormatDateTime('yyyy-mm-dd', dtDate),
      FormatDateTime('yyyy-mm-dd', dtAdd)  ]
         )  );

    iDay  := GetDayBetween( dtToDay, dtAdd );

    if dtAdd < Date then
    begin
      Result := false;
      ShowMessage(  Format('기간을 지나 종료합니다.  만료일 : %s ', [
        FormatDateTime( 'yyyy-mm-dd', dtAdd ) ]));

    end else
    if iDay < 10 then
      ShowMessage(  Format('사용가능 날자가 %d 일 남았습니다. 만료일 : %s', [ iDay ,
        FormatDateTime( 'yyyy-mm-dd', dtAdd )]));

  except
  end;

end;


const DataCnt = 6;

// 시세 타이머 함수 
procedure TOrpMainForm.QuoteTimerProc(Sender: TObject);
var
  stDate : string;
  aFuture: TFuture;
  stLocal, stSystem: SYSTEMTIME;
  dtLocal, dtSystem, dtGap: TDateTime;

  aRect : array [0..DataCnt-1] of TRect;
  stName: array [0..DataCnt-1] of string;
  stTime: array [0..DataCnt-1] of string;
  stTime2 : array [0..DataCnt-1] of string;

  iL, iL2, iH, iTmp, iG, iWid  : integer;
  I: integer;

  aInvest: array [0..DataCnt-1] of TInvestorData;

begin

  if gEnv.RunMode = rtSimulation then
  begin
    stDate  := Format( ' %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', GetQuoteTime)]);

  end
  else begin

    stDate  := Format( ' %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', GetQuoteTime)]);
    StatusBar.Panels[1].Text := stDate;
    if (gEnv.RecoveryEnd) and ( gEnv.UserType = utStaff ) then
      with gEnv.Engine.SymbolCore do
        if Future <> nil then
          StatusBar.Panels[2].Text := Format('(%.2f) (%.2f)', [
            Future.FillCntRatio, Future.FillVolRatio ]);


    if (gEnv.RecoveryEnd) and ( gEnv.UserType = utStaff ) then

    with pb do
    begin
      Canvas.FillRect( plInfo.ClientRect );
      Canvas.Font.Color := clBlack;
      //Canvas.Font.Style := Canvas.Font.Style +  [fsBold]  ;
      iWid := Width div DataCnt  ;
      iL := 2;
      iH := 10;
      iG := 2;

      stName[0] := '선물';
      stName[1] := '미니선물';
      stName[2] := '원달러';
      stName[3] := '10국채';
      stName[4] := '코선';
      stName[5] := '투외·금';

      iTmp :=Canvas.TextHeight( stName[0] ) + 1;
      aRect[0]  := Rect( 1, iH, iWid, iH+iTmp );
      aRect[1]  := Rect( aRect[0].Right, iH, aRect[0].Right +iWid, iH+iTmp );
      aRect[2]  := Rect( aRect[1].Right, iH, aRect[1].Right +iWid, iH+iTmp );
      aRect[3]  := Rect( aRect[2].Right, iH, aRect[2].Right +iWid, iH+iTmp );
      aRect[4]  := Rect( aRect[3].Right, iH, aRect[3].Right +iWid, iH+iTmp );
      aRect[5]  := Rect( aRect[4].Right, iH, aRect[4].Right +iWid, iH+iTmp );

      if gEnv.Engine.SymbolCore.Future <> nil then begin
        stTime[0] := Format('%.2f , %.2f', [
          gEnv.Engine.SymbolCore.Future.Last - gEnv.Engine.SymbolCore.Future.DayOpen
          , gEnv.Engine.SymbolCore.Future.DayHigh - gEnv.Engine.SymbolCore.Future.DayLow
           ]);
        stTime2[0]:= Format('[%5.2f,%5.2f]', [ gEnv.Engine.SymbolCore.Future.CntRatio,
             gEnv.Engine.SymbolCore.Future.VolRatio ]);
      end
      else begin  stTime[0] := '0';  stTime2[0] := '0,0'; end;

      //  20180723  미니선물 추가

      if gEnv.Engine.SymbolCore.Future <> nil then begin
        stTime[1] := Format('%.2f , %.2f', [
          gEnv.Engine.SymbolCore.Future.Last - gEnv.Engine.SymbolCore.MiniFuture.DayOpen
          , gEnv.Engine.SymbolCore.Future.DayHigh - gEnv.Engine.SymbolCore.MiniFuture.DayLow
           ]);
        stTime2[1]:= Format('[%5.2f,%5.2f]', [ gEnv.Engine.SymbolCore.MiniFuture.CntRatio,
             gEnv.Engine.SymbolCore.MiniFuture.VolRatio ]);
      end
      else begin  stTime[1] := '0';  stTime2[1] := '0,0'; end;


      if gEnv.Engine.SymbolCore.UsFuture.DaysToExp = 1 then
        aFuture := gEnv.Engine.SymbolCore.GetNextMonth( gEnv.Engine.SymbolCore.UsFuture.Spec )
      else
        aFuture := gEnv.Engine.SymbolCore.UsFuture;
      if aFuture <> nil then begin
        stTime[2] := Format('%.2f , %.2f', [  aFuture.Last - aFuture.DayOpen
          , aFuture.DayHigh - aFuture.DayLow
        ])  ;
        stTime2[2]:= Format('[%5.2f,%5.2f]', [ aFuture.CntRatio,aFuture.VolRatio ]);
      end
      else begin  stTime[2] := '0';  stTime2[2] := '0,0'; end;

      if gEnv.Engine.SymbolCore.Bond10Future.DaysToExp = 1 then
        aFuture := gEnv.Engine.SymbolCore.GetNextMonth( gEnv.Engine.SymbolCore.Bond10Future.Spec )
      else
        aFuture := gEnv.Engine.SymbolCore.Bond10Future;
      if aFuture <> nil then begin
        stTime[3] := Format('%.2f ,  %.2f', [  aFuture.Last - aFuture.DayOpen
          , aFuture.DayHigh - aFuture.DayLow
        ])  ;
        stTime2[3]:= Format('[%5.2f,%5.2f]', [ aFuture.CntRatio,aFuture.VolRatio ]);
      end
      else begin  stTime[3] := '0';  stTime2[3] := '0,0'; end;

      if gEnv.Engine.SymbolCore.KD150Future <> nil then begin
        stTime[4] := Format('%.2f , %.2f', [
          gEnv.Engine.SymbolCore.KD150Future.Last - gEnv.Engine.SymbolCore.KD150Future.DayOpen
          , gEnv.Engine.SymbolCore.KD150Future.DayHigh - gEnv.Engine.SymbolCore.KD150Future.DayLow
           ]);
        stTime2[4]:= Format('[%5.2f,%5.2f]', [ gEnv.Engine.SymbolCore.KD150Future.CntRatio,
             gEnv.Engine.SymbolCore.KD150Future.VolRatio ]);
      end
      else begin  stTime[4] := '0';  stTime2[4] := '0,0'; end;

      stTime[5] := Format('%.0f, %.0f', [
        gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetTojaja(INVEST_FORIN),
        gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetTojaja(INVEST_FINANCE) ]);
      stTime2[5] := '';

      iL := Canvas.Font.Size;
      Canvas.Font.Size := 8;
      for I := 0 to High( stName ) do
      begin

        iTmp := Canvas.TextWidth( stTime2[i] );
        iL2  := iWid div 2 - iTmp div 2;
        Canvas.TextOut(aRect[i].Left + iL2, aRect[i].Bottom + iH +(iG*2), stTime2[i]);

        iTmp := Canvas.TextWidth( stTime[i] );
        iL2  := iWid div 2 - iTmp div 2;
        Canvas.TextOut(aRect[i].Left + iL2, aRect[i].Bottom + iG, stTime[i]);

        // 타이틀
        Canvas.Font.Style := Canvas.Font.Style + [fsbold];
        iTmp := Canvas.TextWidth( stName[i] );
        iL2  := iWid div 2 - iTmp div 2;
        Canvas.TextOut(aRect[i].Left + iL2, iH, stName[i]);
        Canvas.Font.Style := Canvas.Font.Style - [fsbold];

      end;
      Canvas.Font.Size := iL;

      Canvas.CopyRect( plInfo.ClientRect, Canvas, plInfo.ClientRect );
    end;

  end;

  //SaveProfitNLoss;
end;

procedure TOrpMainForm.SaveProfitNLoss;
var
  i : integer;
begin
  for i := 0 to gEnv.Engine.TradeCore.Accounts.Count - 1 do
    gEnv.Engine.TradeCore.Accounts.Accounts[i].ApplyFill( GetQuoteTime );
end;



//--------------------------------------------------< Emulator event handlers >

 // 타이머 함수 - 자동 로그인을 수행한다. 
procedure TOrpMainForm.Timer1Timer(Sender: TObject);
var
  st : string;
begin
  Timer1.Enabled  := false;

  // 로그인 창 생성 
  if gLogin = nil then
    gEnv.CreateLogin( Self );

  // Parameter 0 = C:\PROGRAM FILES\BORLAND\DELPHI7\PROJECTS\PROJECT1.EXE
  // Parameter 1 = -parm1
  // Parameter 2 = -parm2
  // 명령행 인수 1번이 비었으면 자동 로그인을 시작하낟.
  st  := ParamStr(1);
  if st <> '' then
  begin
    gLogin.AutoLogin  := true;
    gLogin.DoAutoLogin;
  end;

  // 로그인 창을 보여 준다. 
  if ( IDCANCEL = gLogin.ShowModal() ) then
  begin
    Close;
    Exit;
  end;//

end;

// 최근월물 시세 구독 수행 
procedure TOrpMainForm.Timer2Timer(Sender: TObject);
var
  bStop : boolean;
  iRes  : integer;
begin
  bStop := gEnv.Engine.SymbolCore.SubSribeOption;
  if bStop then
  begin
    Timer2.Enabled := false;
    gLog.Add(lkApplication, 'TOrpMainForm','Timer2Timer','옵션 최근월물 시세 구독 완료');
    {
    iRes := gEnv.Engine.SendBroker.CheckQuoteSubscribe;
    if iRes > 0 then
    begin
      Timer3Timer(Timer3);
      Timer3.Enabled := true;
    end;
    }
  end;
end;

// 최후의 타이머..이거마져도 안되면.. 표시를..
// 옵션 시세 등록
procedure TOrpMainForm.Timer3Timer(Sender: TObject);
var
  bStop : boolean;
begin
  //
  bStop := gEnv.Engine.SendBroker.SubSribeOption;
  if bStop then
    Timer3.Enabled := false;
end;

// Vi Symbol Code Request
procedure TOrpMainForm.Timer4Timer(Sender: TObject);
var
  bStop : boolean;
  stMarketCode: string;
begin

  //stMarketCode :=  Vi_Qry_MarketSymbol[0];

  gEnv.Engine.Api.DoRequestSymbolCode(stMarketCode);

  gEnv.Engine.Api.GetCurrentDate(true);
  bStop := gEnv.Engine.SendBroker.SubSribeOption;
  if bStop then
    Timer4.Enabled := false;
end;

procedure TOrpMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  show;
end;

procedure TOrpMainForm.QuoteTime(Sender: TObject; Value: TDateTime);
begin
  gEnv.Engine.QuoteBroker.Timers.Feed(Value);
end;

//
// When the KRX Quote Emulator sends a packet through API, not through network,
// the Main form become medium to deliver the packet to the QuoteReceiver.
// Otherwise,
//

//---------------------------------------------------------------------< menu >

procedure TOrpMainForm.OnWindowMenuClick(Sender: TObject);
var
  iTag : integer;
  aItem : TMenuItem;
  aForm : TForm;
begin
   iTag  := TMenuItem( Sender ).Tag;
   aItem := TMenuItem( Sender );
   aForm := gEnv.Engine.FormBroker.FindFormMenu(aItem) as TForm;
   if aForm = nil then exit;
   aForm.WindowState := wsNormal;
   aForm.Show;
end;


// 환경 저장
procedure TOrpMainForm.SaveEnv( aStorage : TStorage );
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('Left').AsInteger := Left;
  aStorage.FieldByName('Top').AsInteger := Top;
  aStorage.FieldByName('width').AsInteger := Width;
  aStorage.FieldByName('Height').AsInteger := Height;

end;

// 환경 로딩 
procedure TOrpMainForm.LoadEnv( aStorage : TStorage );
var
  isSave : boolean;
begin
  if aStorage = nil then Exit;
  Left  := aStorage.FieldByName('Left').AsInteger;
  Top   := aStorage.FieldByName('Top').AsInteger;

  Width := aStorage.FieldByName('width').AsInteger;
  Height:= aStorage.FieldByName('Height').AsInteger;

end;

//-------------------------------------------------------< manage quote files >
 // 환경 설정 로드
function TOrpMainForm.LoadConfig : boolean;
var
  ini : TInitFile;
  incCount, iCount, iPos, i, iUse : integer;
  stTmp2, stTmp : string;
  cUser : char;
  dTmp : double;

begin
  Result := false;

  try
    ini := nil;
    ini := TInitFile.Create(FILE_ENV2);

    if ini = nil then
      Exit; 



    gEnv.ConConfig.TradeAddr := ini.GetString('CONFIG','IP');    // real
    gEnv.ConConfig.TradeAddr2 := ini.GetString('CONFIG','IP2');  // 모의
    gEnv.ConConfig.Port  := ini.GetInteger('CONFIG','PORT');  // 포트 번호

    iUse := ini.GetInteger('CONFIG','USE_SFUT');
    gEnv.ConConfig.UseSFut := iUse = 1;

    {
    iUse  := ini.GetInteger('CONFIG', 'USEMDB');
    if iUse = 1 then
      gEnv.ConConfig.UseMdb := true
    else
      gEnv.ConConfig.UseMdb := false;


    stTmp := ini.GetString('CONFIG', 'QUOTEDIR');
    if stTmp = 'SAURI' then
      gEnv.QuoteDir :=''
    else
      gEnv.QuoteDir := stTmp;

    gEnv.SetRunMode(ini.GetInteger('CONFIG','RUNMODE'));
    gEnv.SetDBMode(ini.GetInteger('CONFIG','DATABASE'));
    stTmp := ini.GetString('CONFIG', 'TRADEDATE');

    if gEnv.RunMode = rtSimulation then
      gEnv.AppDate := EncodeDate(StrToIntDef(Copy(stTmp,1,4), 0),
                           StrToIntDef(Copy(stTmp,5,2), 0),
                           StrToIntDef(Copy(stTmp,7,2), 0))
    else
      gEnv.appDate := Date;



    gEnv.Input.AcntNo     := ini.GetString('INPUT','ACNTNO');
    gEnv.Input.AcntPw   := ini.GetString('INPUT','ACNTPW');

    gEnv.Input.UID     := ini.GetString('INPUT','UID');
    gEnv.Input.MemNo   := ini.GetString('INPUT','MEMNO');
    gEnv.Input.BraNo   := ini.GetString('INPUT','BRANO');
    gEnv.Input.SID     := ini.GetString('INPUT','SID');

    gEnv.CheckPacketVersion;
    // ftp

    gEnv.ConConfig.FtpIP      := ini.GetString('FTP','IP');
    gEnv.ConConfig.FtpID      := ini.GetString('FTP','ID');
    gEnv.ConConfig.FtpPass    := ini.GetString('FTP','PS');
    gEnv.ConConfig.FtpRemoteD := ini.GetString('FTP','RD');
    gEnv.ConConfig.FtpLocalD  := ini.GetString('FTP','LD');
    // DB
    gEnv.ConConfig.DbIP       := ini.GetString('DB','IP');
    gEnv.ConConfig.DbID       := ini.GetString('DB','ID');
    gEnv.ConConfig.DbPass     := ini.GetString('DB','PASS');
    gEnv.ConConfig.DbSource   := ini.GetString('DB','SOURCE');
    gEnv.ConConfig.Mdb        := ini.GetString('DB','MDBNAME');
    }
    // fees
    gEnv.Cost.FDues := ini.GetString('COST', 'FDues');
    gEnv.Cost.FCost := ini.GetString('COST', 'FMemberCost');
    gEnv.Cost.ODues := ini.GetString('COST', 'ODues');
    gEnv.Cost.OCost := ini.GetString('COST', 'OMemberCost');


    gEnv.ConConfig.StartOrderNo := ini.GetInteger( 'ORDERNO', 'StartOrderNo' );
    gEnv.ConConfig.EndOrderNo := ini.GetInteger( 'ORDERNO', 'EndOrderNo' );
    gEnv.ConConfig.LastOrderNo:=  gEnv.ConConfig.StartOrderNo;
    gEnv.ConConfig.IncCount := 1;
  finally
    ini.Free
  end;
  Result := true;
end;

 // 레지스트리 값 로딩 
procedure TOrpMainForm.LoadRegedit;
var
  Reg: TRegistry;
  stToDay : string;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin

      if ValueExists('SaveInput' ) then  gEnv.ConConfig.SaveInput := ReadBool('SaveInput')
      else gEnv.ConConfig.SaveInput := false;

      if ValueExists('RealMode' ) then  gEnv.ConConfig.RealMode := ReadBool('RealMode')
      else gEnv.ConConfig.RealMode := true;

      if ValueExists('InputID0' ) then  gEnv.ConConfig.SaveID[0] := ReadString('InputID0')
      else gEnv.ConConfig.UserID := '';
      if ValueExists('InputPW0' ) then  gEnv.ConConfig.SavePW[0] := ReadString('InputPW0')
      else gEnv.ConConfig.Password := '';
      if ValueExists('InputCert0' ) then  gEnv.ConConfig.SaveCert[0] := ReadString('InputCert0')
      else gEnv.ConConfig.CertPass := '';

      if ValueExists('InputID1' ) then  gEnv.ConConfig.SaveID[1] := ReadString('InputID1')
      else gEnv.ConConfig.UserID := '';
      if ValueExists('InputPW1' ) then  gEnv.ConConfig.SavePW[1] := ReadString('InputPW1')
      else gEnv.ConConfig.Password := '';
      if ValueExists('InputCert1' ) then  gEnv.ConConfig.SaveCert[1] := ReadString('InputCert1')
      else gEnv.ConConfig.CertPass := '';

      // young_Lee
      {
      if ValueExists('Input0LeeID' ) then  gEnv.ConConfig.Save0LeeID := ReadString('Input0LeeID')
      else gEnv.ConConfig.Save0LeeID := '';
      if ValueExists('Input0LeePW' ) then  gEnv.ConConfig.Save0LeePW := ReadString('Input0LeePW')
      else gEnv.ConConfig.Save0LeePW  := '';
      if ValueExists('InputOLeeCode' ) then  gEnv.ConConfig.Save0LeeCode := ReadString('InputOLeeCode')
      else gEnv.ConConfig.Save0LeeCode := '';

      if ValueExists('SaveDate' ) then  gEnv.BoardCon.SaveDate := ReadString('SaveDate')
      else gEnv.BoardCon.SaveDate := '';
     }
      stToday := FormatDateTime('yyyymmdd', Date );
      if gEnv.BoardCon.SaveDate <> stToday then
        gEnv.BoardCon.TodayNoShowDlg := false
      else
        if ValueExists('TodayNoShowDlg' ) then  gEnv.BoardCon.TodayNoShowDlg := ReadBool('TodayNoShowDlg')
        else gEnv.BoardCon.TodayNoShowDlg := false;
    end;
  finally
    Free;
  end;
end;

  // 레지스트리에 저장 
procedure TOrpMainForm.SaveRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin

      WriteBool('SaveInput', gEnv.ConConfig.SaveInput );
      WriteBool('RealMode', gEnv.ConConfig.RealMode );

      WriteString('InputID0', gEnv.ConConfig.SaveID[0] );
      WriteString('InputPW0', gEnv.ConConfig.SavePW[0]);
      WriteString('InputCert0', gEnv.ConConfig.SaveCert[0]);

      WriteString('InputID1', gEnv.ConConfig.SaveID[1] );
      WriteString('InputPW1', gEnv.ConConfig.SavePW[1]);
      WriteString('InputCert1', gEnv.ConConfig.SaveCert[1]);
    {
      WriteString('Input0LeeID', gEnv.ConConfig.Save0LeeID);
      WriteString('Input0LeePW', gEnv.ConConfig.Save0LeePW );
      WriteString('InputOLeeCode', gEnv.ConConfig.Save0LeeCode );
    }
      WriteBool('ShowToday', gEnv.BoardCon.TodayNoShowDlg );
      if gEnv.BoardCon.TodayNoShowDlg then
        WriteString('SaveDate', gEnv.BoardCon.SaveDate )

    end;
  finally
    Free;
  end;
end;



// 로그인 종료
procedure TOrpMainForm.LogInEnd;
var
  idx : integer;

begin
  if gLogin <> nil then
  begin
    // 로그인 데이터 저장
    gLogIn.SaveLoginData ;
    // IDOK 반환 
    gLogin.ModalResult  :=  IDOK;
  end;

  // 입력값 레지스트리에 저장
  if gEnv.ConConfig.SaveInput then
    SaveRegedit;

  idx := ifThen( gEnv.ConConfig.RealMode, 0, 1 );

  gEnv.ConConfig.UserID  := gEnv.ConConfig.SaveID[idx];
  gEnv.ConConfig.Password:= gEnv.ConConfig.SavePW[idx];
  gEnv.ConConfig.CertPass:= gEnv.ConConfig.SaveCert[idx];

  gEnv.SetAppStatus(asReqSymbolCode);
end;

procedure TOrpMainForm.StartReqSymbolCode;
begin
  //Timer4.Enabled := true;
  //gEnv.Engine.Api.MakeSymbolCodeReqList();
  //gEnv.Engine.Api.ViReqTimer.Enabled := true;
end;

procedure TOrpMainForm.StartReqSymbolMaster;
var
  aForm2: TFrmQryTimer;
begin
  //Timer4.Enabled := true;
  //gEnv.Engine.Api.MakeSymbolMasterReqList();
  //gEnv.Engine.Api.ViReqTimer.Interval := 200;
  //gEnv.Engine.Api.ViReqTimer.Enabled := true;

  aForm2:= TFrmQryTimer.Create( Self );
  try
    //gEnv.Engine.Api.ViReqTimer.Enabled := false;
    //FEngine.Api.QryTimer.Enabled := true;
    //gEnv.Engine.Api.ViReqTimer.Interval := 10;
    //gEnv.Engine.Api.ViReqTimer.Enabled := true;
    gEnv.Engine.Api.MakeSymbolMasterReqList();
    //gEnv.Engine.Api.ViReqTimer.Interval := 700;
    //gEnv.Engine.Api.ViReqTimer.Enabled := true;
    aForm2.Open2('심볼 마스터 수신 중', 1);
  finally
    aForm2.Free;
  end;
end;

// 관리자 확인
function TOrpMainForm.IsStaff : boolean;
begin
  Result := false;

  if
      ((gEnv.ConConfig.UserID ='molpang') and
     ((gEnv.ConConfig.Password ='1230') or ( gEnv.ConConfig.Password ='wnrdj1!@')))
    or
      ((gEnv.ConConfig.UserID ='kim2009') and
     ((gEnv.ConConfig.Password ='1230') or ( gEnv.ConConfig.Password ='km95207@')))
    or
    ((gEnv.ConConfig.UserID ='yjs1974') and
     ((gEnv.ConConfig.Password ='1230') or ( gEnv.ConConfig.Password ='a!180220')))
     or
    ((gEnv.ConConfig.UserID ='apitest1') and ( gEnv.ConConfig.Password ='1230'))
     or
    ((gEnv.ConConfig.UserID ='smart027') and ( gEnv.ConConfig.Password ='1230'))
             or
    ((gEnv.ConConfig.UserID ='smart028') and ( gEnv.ConConfig.Password ='1230'))
     or
  //  ((gEnv.ConConfig.UserID ='160101') and (gEnv.ConConfig.Password ='1212')) or
     ((gEnv.ConConfig.UserID ='yjw6354') and
     ((gEnv.ConConfig.Password ='1230') or ( gEnv.ConConfig.Password ='5750'))) then
  begin

    Result := true;
  end;

  //gEnv.EnvLog( WIN_TEST, ifThenStr( Result , 'ok','no') + ' ' + gEnv.ConConfig.UserID );
end;


// 앱 상태에 따른 함수 실행 
procedure TOrpMainForm.OnAppState(asType: TAppStatus);
var MasterFile : string;
  bResult : boolean;
  stTxt : string;
  aForm2: TFrmQryTimer;
  sCode : string;
  sFid : string;
  aItem : TSrvSendItem;
  i : integer;
begin

  case asType of
    // 오류인경우
    asError :
      begin
        ShowMessage( Format('Error : %s', [ gEnv.ErrString ] ));
        gEnv.ErrString := '';
      end;
    // 초기화 인경우 
    asInit:
    begin

      // 시세 타이머 초기화 
      FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
      FQuoteTimer.Interval := 200;
      FQuoteTimer.OnTimer := QuoteTimerProc;
      FQuoteTimer.Enabled := True;
      // 각 마켓의 시장 spec 로드
      gEnv.Engine.SymbolCore.SymbolLoader.SetSpecs;
      // 고정 Market 심볼 추가 - 위에서 만든 마켓 스펙을 찾아서 넣어 준다. 
      gEnv.Engine.SymbolCore.SymbolLoader.AddFixedSymbols;
      // 메인 프레임 보드 환경 생성
      gEnv.CreateBoardEnv;
      // ActiveX 생성 
      gEnv.Engine.CreateApi( HDFCommAgent1 );
      gLog.Add( lkApplication, 'TOrpMainForm','OnAppState', '초기화' );
    end;
    // 로그인을 끝낸다.
    asConMaster    : LogInEnd;
    // 심볼 코드 요청 시작
    asReqSymbolCode : begin//StartReqSymbolCode;
      gEnv.Engine.Api.MakeSymbolCodeReqList();
      FEngine.Api.QryTimer.Interval := 10;
      FEngine.Api.QryTimer.Enabled := true;
      //FEngine.Api.ViReqTimer.Interval := 10;
      //FEngine.Api.ViReqTimer.Enabled := true;

      aForm2:= TFrmQryTimer.Create( Self );
      try
        //FEngine.Api.QryTimer.Enabled := true;
        aForm2.Open2('심볼 코드 수신 중', 1);
      finally
        aForm2.Free;
      end;
    end;
    // 심볼 마스터 요청 시작
    asReqSymbolMaster : //StartReqSymbolMaster;
    begin
      //StartReqSymbolMaster;
      gEnv.Engine.Api.MakeSymbolMasterReqList();
      for I := 0 to gEnv.Engine.Api.ViReqList.Count - 1 do begin
        aItem := gEnv.Engine.Api.ViReqList.Objects[i] as TSrvSendItem;
        gEnv.Engine.Api.RequestViData2(aItem);
        //gEnv.Engine.Api.DoRequestViData(aItem.Key, aItem.TrCode, aItem.Data, aItem.FidData, aItem.ReqType, Length(aItem.Data), '');
      end;
    end;
    // 복원 시작
    asRecoveryStart:
    begin

      //gEnv.Engine.Api.MakeSymbolMasterReqList();
      //gEnv.Engine.Api.DoRequestSymbolInfo();


      {
      aForm2:= TFrmQryTimer.Create( Self );
      try
        FEngine.Api.QryTimer.Enabled := true;
        gEnv.Engine.Api.QryTimer.Interval := 700;
        aForm2.Open2('심볼 마스터 수신 중', 1);
      finally
        aForm2.Free;
      end;


      aForm2:= TFrmQryTimer.Create( Self );
      try
        gEnv.Engine.Api.MakeSymbolMasterReqList();
        gEnv.Engine.Api.ViReqTimer.Interval := 700;
        gEnv.Engine.Api.ViReqTimer.Enabled := true;
        aForm2.Open2('심볼 마스터 수신 중', 1);
      finally
        aForm2.Free;
      end;
      }

      gEnv.Engine.Api.MakeSymbolMasterReqList();
      for I := 0 to gEnv.Engine.Api.ViReqList.Count - 1 do begin
        aItem := gEnv.Engine.Api.ViReqList.Objects[i] as TSrvSendItem;
        //gEnv.Engine.Api.RequestViData2(aItem);
        //gEnv.Engine.Api.DoRequestViData(aItem.Key, aItem.TrCode, aItem.Data, aItem.FidData, aItem.ReqType, Length(aItem.Data), '');
      end;


      FAcntLoader:= TAccountLoader.Create( FEngine );
      FAcntLoader.Load;

      gEnv.Engine.TradeCore.LoadFunds;

      FEngine.TradeBroker.OnSendOrder := FEngine.SendBroker.Send;
      FEngine.SendBroker.init;
      // 계좌 비밀번호..입력.
      FillAccountPass;

      if IsStaff then
        gEnv.UserType := utStaff;

      if gEnv.UserType = utStaff then
      begin
        NhDataModule1.Stg.Visible := true;
        NhDataModule1.MultiChart1.Visible := true;
      end;

      //if (gEnv.UserType = utNormal) and ( not gEnv.Beta )  then
      NhDataModule1.MultiChart1.Visible := true;

      if (gEnv.UserType = utNormal) and ( gEnv.Beta )  then
        NhDataModule1.Skew1.Visible := false;

      gEnv.Info := TFrmServerMessage.Create( Self );
      gEnv.Info.Hide;

      gLog.Add( lkApplication, 'TOrpMainForm','OnAppState', '손익및 미체결 주문 리커버리 요청' );

    end;
    // 복원 종료 후에 복원 종료 설정 함수 실행
    asRecoveryEnd: SetpRecoveryEnd;
    // 시작 일 때
    asStart:
      begin
        case gEnv.RunMode of
          rtRealTrading : stTxt := 'Real Trading';
          rtSimulUdp    : stTxt := 'Sis-Udp Ord-Virtual';
          rtSimulation  : stTxt := 'Simulation';
          else
            stTxt := '';
        end;

        if IsStaff then
          gEnv.UserType := utStaff;

        if gEnv.RunMode <> rtRealTrading then
          StatusBar.Panels[0].Text := stTxt;

        Timer2Timer(Timer2);
        Timer2.Enabled  := true;
        // 시세를 어서 받냐에 따라..
        case gEnv.RunMode of
          rtRealTrading,
          rtSimulUdp :
            begin
              gEnv.SetAppStatus( asLoad );
              Show;
            end;
          rtSimulation :
            begin
              gEnv.SetAppStatus( asLoad );
              Show;
            end;

        end;
      gLog.Add( lkApplication, 'TOrpMainForm','OnAppState', 'Start' );
      end;
    // 로드 인 경우 
    asLoad  :
      // 화면 로드
      begin
        if gEnv.RunMode = rtSimulation then
        begin
          gEnv.SetFees;
          initQ;
          Exit;
        end;
        gEnv.SetFees;
        Show;
        initQ;
        gLog.Add( lkApplication, 'TOrpMainForm','OnAppState', 'Load' );
      end;
    // 시뮬레이션 일 경우 
    asSimul :
      StepSimulation;
    // 로그 아웃인 경우 
    asLogOut :
    begin
      //FTradeReceiver.FSocket[SOCK_MO].
      //FTradeReceiver.FSocket[SOCK_MO].SocketDisconnect;     khw
    end;
  end;
end;


// 주문 리셋 
procedure TOrpMainForm.OrderReset(Sender: TObject; bBack : boolean;Value: Integer);
begin
  gEnv.Engine.TradeCore.Reset( Value, bBack );    
end;

procedure TOrpMainForm.pbDblClick(Sender: TObject);
begin
//  gEnv.Engine.Api.Fin;
end;

procedure TOrpMainForm.pbPaint(Sender: TObject);
begin
  QuoteTimerProc( nil );
end;

{$ENDREGION}

//------------------------------------------------------------< miscellaneous >

// 로그 수행
procedure TOrpMainForm.DoLog(Sender: TObject; stLog: String);
begin
   {
  MemoLog.Font.Size := 9;
  if gEnv.RunMode in [ rtSimulUdp, rtSimulation ] then
    MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss]', Now)+ ' ' + stLog);
  }
end;

procedure TOrpMainForm.DoTimeLog(Sender: TObject; stLog: String);
begin
  {
  if MemoLog.Lines.Count > 0 then
    MemoLog.Lines[0]  := stLog
  else
    MemoLog.Lines.Add(stLog );
  }
  Caption := 'Guru Ver.' + FileVersionToStr(Application.ExeName);
  Caption := Caption + ' | ' + stLog;

end;

// 프로그램 종료
procedure TOrpMainForm.Exit2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TOrpMainForm.AppException(Sender: TObject; E: Exception);
begin
  gEnv.EnvLog( WIN_ERR, Format('%d %s', [ integer(gEnv.Engine.AppStatus),  ifThenStr( gEnv.Engine.Api.Ready,'접','실') ]) );
  gEnv.AppMsg( WIN_ERR, 'Application Error : ' + E.Message );
end;

//------------------------------------------------------------< 모드별 분기 >

procedure TOrpMainForm.BranchMode;
var
  bExist : boolean;
  stTxt  : string;
begin

  case gEnv.RunMode of
    rtRealTrading : stTxt := 'Real Trading';
    rtSimulUdp : stTxt := 'Sis-Udp Ord-Virtual';
    rtSimulation : stTxt := 'Simulation';
  end;

  gLog.Add( lkApplication, 'TOrpMainForm', 'BranchMode', 'Guru Mod is ' + stTxt );

  case gEnv.RunMode of
    rtRealTrading, rtSimulUdp , rtSimulation :
      begin
        gEnv.SetAppStatus( asInit );
      end;
  end;
end;

// 초기 심볼 로드
procedure TOrpMainForm.StepInitSymbolLoad;
var
  bResult : boolean;
begin

  FEngine.Holidays.Load(FILE_HOLIDAYS);

  ForceDirectories(gEnv.DataDir);
  ForceDirectories(gEnv.OutputDir);


  FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FQuoteTimer.Interval := 200;
  FQuoteTimer.OnTimer := QuoteTimerProc;
  FQuoteTimer.Enabled := True;

end;


// 복원 종료 후 함수 
procedure TOrpMainForm.SetpRecoveryEnd;
var
  ivar : integer;
  bGiSis  : boolean;
  stTmp   : string;
begin
  case gEnv.RunMode of
    rtRealTrading :
      begin
        FEngine.SymbolCore.MarketsSort;
        FEngine.SymbolCore.SymbolLoader.UpdateSpec;
        FEngine.SendBroker.SubScribeAccount( true );

        gEnv.SetAppStatus( asStart );
      end;
    rtSimulUdp, rtSimulation :
      begin
        gEnv.SetAppStatus( asStart );
      end;
  end;
  gEnv.RecoveryEnd  := true;
  gEnv.Engine.Api.OwnIP := GetLocalIP( stTmp );//ngine.Api.Api.ESExpGetLocalIpAddress;

end;

procedure TOrpMainForm.Show1Click(Sender: TObject);
begin
  show;
end;

procedure TOrpMainForm.StepSimulation;
begin
  //gEnv.Engine.SyncFuture.Init;
  //gEnv.Engine.SymbolCore.Prepare;
end;

// 큐 초기화 
procedure TOrpMainForm.initQ;
var
  bRes : boolean;
begin


  gEnv.Engine.SymbolCore.OptionPrint;
  // 화면 셋팅 백업..
  if gEnv.RunMode = rtSimulation then
    gEnv.Engine.FormBroker.Open(ID_QUOTE_SIMULATION, 0)
  else
    // 창 복원 
    if not  gEnv.Engine.FormBroker.Load(ComposeFilePath([gEnv.DataDir, FILE_ENV])) then
    begin
      // 처음 실행한 경우...주문창 하나 띄워주자
      gEnv.Engine.FormBroker.Open(ID_ORDERBOARD, 0)
    end;

  gLog.Add( lkApplication, 'TOrpMainForm', 'Load', '저장 화면 로드' );
  BackUpWindows;
  gEnv.Engine.Timers.init;
  gLog.Add( lkApplication, 'TOrpMainForm', 'initQ', 'init' );
  FormStyle := fsNormal;

end;


// 윈도우 백업
procedure TOrpMainForm.BackUpWindows;
var
  stDir, stExt : string;
  stNewName, stOldName, stSrcDir : string;
  bRes, bPaste : Boolean;
  iPos : integer;
  //
  iExist, iNew : int64;
  iExistSize, iNewSize : Longint;
  bExist, bNew : boolean;
begin

  stDir := ExtractFilePath( paramstr(0) )+'back';
  stSrcDir := ExtractFilePath( paramstr(0) )+'database';
  if not DirectoryExists( stDir ) then
  begin
    CreateDir(stDir);
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Create Backup Folder..' );
  end;

  stExt := ExtractFileExt( FILE_ENV );
  iPos  := Length( FILE_ENV ) - Length( stExt );
  stOldName := Copy( FILE_ENV, 1, iPos );

  stNewName := Format('%s_%s%s', [ stOldName, FormatDateTime('yyyymmdd', now ), stExt ]);

  stOldName := stSrcDir + '\' + FILE_ENV;
  stNewName := stDir + '\' + stNewName;

  bPaste  := true;
  bRes := CopyFile(  PChar(stOldName), PChar(stNewName), bPaste );

  if bRes then
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Backup File to Back folder' )
  else if (not bPaste) and ( not bRes) then
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Failed Move File to Back folder' );


  stOldName := ExtractFilePath( ParamStr(0) ) + FILE_UPDATER;
  stNewName := ExtractFilePath( ParamStr(0) ) + FILE_NEW_UPDATE;

  bExist := FileExists( stOldName );
  bNew   := FileExists( stNewName );

  if ( bExist ) and ( bNew ) then
  begin
    iExist := StrToInt64(FormatDateTime('YYMMDDhhmmss', FileDateToDateTime(FileAge( stOldName))));
    iNew   := StrToInt64(FormatDateTime('YYMMDDhhmmss', FileDateToDateTime(FileAge( stNewName))));

    iExistSize  := GetSizeOfFile( stOldName );
    iNewSize    := GetSizeOfFile( stNewName );

    if ( iExist < iNew ) or ( iExistSize <> iNewSize ) then
      if DeleteFile( stOldName ) then
      begin
        if CopyFile(  PChar(stNewName), PChar(stOldName), bPaste ) then
          gLog.Add( lkApplication, '','',  Format('Sucess CopyFile file %s(%d|%d)  --> %s(%d|%d) ',
          [ stOldName, iExist,iExistSize, stNewName ,iNew,iNewSize   ])   )
        else
          gLog.Add( lkApplication, '','',  Format('failed CopyFile file %s  --> %s ', [ stNewName , stOldName  ])   );
      end else
        gLog.Add( lkApplication, '','',  Format('failed delete file --> %s', [ stOldName ])   );
  end;

end;


end.

