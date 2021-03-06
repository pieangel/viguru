// Api 관리자
unit CleApiManager;

interface

// 포함 유닛들 
uses
  Classes, SysUtils, ExtCtrls, Windows,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts, CleOrders, CleApiRecvThread,

  WRAXLib_TLB,  CleQuoteTimers, ApiPacket,

  HDFCommAgentLib_TLB,

  MyCollection,

  GleTypes
  ;

//{$INCLUDE define.txt}

// 상수 정의
const
  MAX_CNT = 35;
  MAX_CNT2 = 2;
  ExSec    = 5;

  ACCOUNT_QRY = 1;
  SYMBOL_QRY  = 0;
  AUOTE_QUOTE = 2;
// 데이터 타입 정의 
type

  // 로드 타입 정의
  TLoadStatsType = ( lstNone, lstSymbol, lstAccount, lstEnd );


  // 서버 전송 아이템 
  TSrvSendItem = class( TCollectionItem )
  public
    TrCode : string;
    Data   : string;
    Key    : string;
    reqId  : integer;
    FidData : string;
    Size   : integer;
    Index  : integer;
    ReqType : TApiReqType;
    Requestd : boolean;

    Constructor Create( aColl : TCollection ) ; overload;
  end;

  // 서버 요청 아이템 
  TRequestItem = class( TCollectionItem )
  public
    TrCode : string;
    Data   : string;
    Index  : integer;
    Tag    : integer;

    Constructor Create( aColl : TCollection ) ; overload;
  end;

  TViRequestItem = class (TCollectionItem)
  public
    TrCode : string; // trade code
    Data : string;   // data
    Next : string;
    TryCnt : integer;  // Try count
    Complete : Boolean; // Complete or not
    ReqId : integer;  // request id
    nResult : integer; // result code
    nIndex : string; // unique id
    ReqType : TApiReqType; // Request Type
    FidData : string; // Fid Data
    constructor Create( aColl : TCollection ) ; overload;
  end;

  // Api 관리자 클래스
  TApiManager = class
  private
    // ActiveX 객체
    FApi: THDFCommAgent; // TWRAX;
    // 준비 되었는가?
    FReady: boolean;
    // 이벤트
    FOnData: TTextNotifyEvent;

    MyList : TMyCollection;

    // 질의 목록
    FQryList : TList;
    // 하위 목록
    FSubList : TList;
    // 요청 목록 
    FReqList : TList;

    // Vi 요청 목록
    FViReqList : TStringList;
    // Vi Req Id List - 증권사 요청 번흐를 담고 있다. 
    FViReqIdList : TStringList;

    FViSymbolCodeList : TStringList;

    // 자동 시세 목록 
    FAutoQuoteList : TList;
    // 질의 타이머
    FQryTimer: TTimer;
    // 자동 타이머 
    FAutoTimer: TTimer;

    // Vi 질의 타이머
    FViReqTimer: TTimer;




    // 질의 카운트 배열
    FQryCount : array [0..QRY_CNT-1] of integer;

    // 로드 상태 
    FLoadStats: TLoadStatsType;
    // 송신 쿼리 갯수
    FSendQryCount: integer;
    // 수신 객체 - 서버 수신을 관리한다.  
    FRecevier: TApiReceiver;
    // 계좌 질의 카운트 
    FAccountQryCount: integer;
    // 소유 아이피
    FOwnIP: string;
    // 갯수 
    FCount: integer;
    // 마지막 시간 
    FLastTime : TDateTime;
    // 송신 쓰레드 
    FApiThread: TApiRecvThread;

    // 요청 데이터 수신 함수 
    procedure OnWRAXRecvData(ASender: TObject; DataType: Smallint; const TrCode: WideString;
                                              nRqID: Smallint; nDataSize: Integer;
                                              var szData: WideString);
    // 실시간 데이터 수신 함수
    procedure OnWRAXRecvRealData(ASender: TObject; const TrCode: WideString;
                                                  const KeyValue: WideString; nRealID: Smallint;
                                                  nDataSize: Integer; const szData: WideString);
    // 로그인 응답
    procedure OnWRAXReplyLogin(ASender: TObject; nResult: Smallint; const Message: WideString);
    // 파일 다운 응답
    procedure OnWRAXReplyFileDown(ASender: TObject; nResult: Smallint; const Message: WideString);

    // 접속 성공 응답
    procedure OnWRAXConnected(Sender: TObject);
    // 접속 해제 응답 
    procedure OnWRAXDissConnected(Sender: TObject);

    // 쾌속 데이터 수신 함수 
    procedure ESApiExpESExpRecvData(ASender: TObject; nTrCode: Smallint;
      const szRecvData: WideString);

    procedure OnHDFCommAgentOnGetData(ASender: TObject; nType: Integer; wParam: Integer;
                                                       lParam: Integer);
    procedure OnHDFCommAgentOnRealData(ASender: TObject; nType: Integer; wParam: Integer;
                                                        lParam: Integer);
    procedure OnHDFCommAgentOnDataRecv(ASender: TObject; const sTrCode: WideString; nRqId: Integer);
    procedure OnHDFCommAgentOnGetBroadData(ASender: TObject; const sJongmokCode: WideString;
                                                            nRealType: Integer);
    procedure OnHDFCommAgentOnGetMsg(ASender: TObject; const sCode: WideString;
                                                      const sMsg: WideString);
    procedure OnHDFCommAgentOnGetMsgWithRqId(ASender: TObject; nRqId: Integer;
                                                              const sCode: WideString; 
                                                              const sMsg: WideString);

    procedure OnAccountList(const sTrCode: WideString; const nRqId: Integer);
    procedure OnSymbolCode(const sTrCode: WideString; const nRqId: Integer);
    procedure OnSymbolMaster(const sTrCode: WideString; const nRqId: Integer);



    function CheckRqResult(const nRqId : integer; const sCode, sMsg : WideString): integer;

    // 마스터 로드 함수
    procedure LoadMaster(stFileName: string);
    procedure LoadMasterFromSymbolCode(stSymbolCode: string);

    // 질의 인데스 함수. 질의에 대한 인덱스를 돌려준다. 
    function QryIndex(stTr: string): integer;
    // 요청을 추가 한다. 
    procedure AddRequest(stTr, stData: string; iReq: integer);
    // Api 쓰레드 이벤트 
    procedure OnApiThreadEvent( aPacket : POrderPacket );

    


  public

    // 크리티컬 섹션 - 쓰레드 동기화에 필요 
    CritSect: TRTLCriticalSection;

     // 심볼 요청 함수
    procedure DoRequestSymbolInfo;
    // 생성자
    Constructor Create( aObj : TObject ); overload;
    // 소멸자 
    Destructor  Destroy; override;

    // 접속 요청 함수
    procedure DoConnect( iMode : integer );
    // 로그인 함수
    procedure DoLogIn; overload;
    // 로그인 함수
    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : integer;  overload;
    // 종료 확인 함수 
    procedure Fin;

    // 계좌 코드 찾는 함수
    function FindAccountCode( iReq : integer ): string;
    // 요청 수행 함수
    function DoRequest( stTr, stData : string) : integer;
    // 주문 전송 함수 
    function DoSendOrder( aOrder : TOrder ) : string;

    // 마스터 요청 함수
    procedure DoRequestMaster;
    // 계좌 요청 함수
    procedure DoRequestAccout;

    // 오류 메시지 얻어오는 함수
    function GetErrorMessage( iRes : integer ) : string;
    function GetViErrorMessage( iRes : integer ) : string;
    // 현재 날짜 얻어 오는 함수
    function GetCurrentDate : string; overload;
    // 현재 날 짜 얻어 오는 함수
    function GetCurrentDate( bDate : boolean ) : TDateTime; overload;

    // 마스터 요청 함수
    procedure RequestMaster( stUnder, stCode, stIndex : string );
    // 요청 넣는 함수
    procedure PushRequest( stTrCode ,stData : string );

    procedure PushViRequest(stTrCode, stData: string );

    function RequestViData2(var aItem : TSrvSendItem): integer;

    // Vi 심볼 코드 요 청 
    procedure DoRequestSymbolCode(stMarketCode: string);

    // 데어터 요청 함수
    function  RequestData(iTrCode: integer; stReqData: string; iSize : integer ) : integer;

    // Vi 데이터 요청 함수
    function  DoRequestViData(stKey, stTrCode: string; stReqData, stFidData: string; rtType : TApiReqType; iSize : integer; stNext : string ) : integer;

    // 등록 함수
    function Subscribe( stTrCode, stData : string ) : integer;
    // 등록 해제 함수
    function UnSubscribe( stTrCode, stData : string ) : integer;

    // 실시간 시세 요청 함수
    function  ReqRealTimeQuote( stTrCode, stData : string; bOn : boolean = true ) : integer;

    // 타이터 이벤트 함수
    procedure TimeProc( Sender : TObject );
    // 타이머 이벤트 함수 
    procedure TimeProc2( Sender : TObject );

    // ViReqTimer 이벤트 함수
    procedure TimeViReq( Sender: TObject );

    procedure MakeSymbolCodeReqList();

    procedure MakeSymbolMasterReqList();

    procedure AddSymbolMasterRequest(const stSymbolCode : string);

    // ActiveX 객체 
    property Api: THDFCommAgent read FApi;
    // 수신자
    property Recevier : TApiReceiver read FRecevier;
    // 쓰레드 
    property ApiThread: TApiRecvThread read FApiThread;

    // 준비 상태
    property Ready : boolean read FReady ;//write FReady;
    // 데엍 도착 처리 함수
    property OnData: TTextNotifyEvent read FOnData write FOnData;
    // 질의 타이머 속성
    property QryTimer : TTimer read FQryTimer write FQryTimer;
    // 자동 타이머 속성
    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;


    property ViReqTimer: TTimer read FViReqTimer write FViReqTimer;

    // 로드 상태 속성
    property LoadStats : TLoadStatsType read FLoadStats write FLoadStats;
    // 소유 아이피
    property OwnIP  : string read FOwnIP write FOwnIP;
    property Count  : integer read FCount ;   // 접속 카운트
    property QryList: TList read FQryList;    // 초반 전체 종목 현재가 조회시에만 사용되는 리스트
    property ViReqList : TStringList read FViReqList;

    // counting
    // 질의 전송 카운트
    property SendQryCount : integer read FSendQryCount;
    // 계좌 질의 전송 카운트 
    property AccountQryCount : integer read FAccountQryCount;
  end;

implementation

uses
  GAppEnv, GleLib , SynthUtil,  Dialogs,  CleParsers,
  FOrpMain, DateUtils,
  CleSymbols, CleMarkets, CleKrxSymbols,
  Math
  ;

{ TApiManager }

// 생성자
constructor TApiManager.Create(aObj: TObject);
var
  I: Integer;
begin
  // 준비 상태 초기화
  FReady  := false;
  // 갯수
  FCount  := 0;
  // Activex 할당
  FApi := aObj as  THDFCommAgent;

  MyList := TMyCollection.Create;


  // 이벤트 핸들러 매칭
  // 연결 응답
  //FApi.OnNetConnected := OnWRAXConnected;
  FApi.OnGetData := OnHDFCommAgentOnGetData;
  // 연결 해제 응답
  //FApi.OnNetDisconnected := OnWRAXDissConnected;
  FApi.OnRealData := OnHDFCommAgentOnRealData;
  // 데이터 수신 응답
  //FApi.OnRecvData := OnWRAXRecvData;
  FApi.OnDataRecv := OnHDFCommAgentOnDataRecv;
  // 실시간 데이터 수신 응답
  //FApi.OnRecvRealData := OnWRAXRecvRealData;
  FApi.OnGetBroadData := OnHDFCommAgentOnGetBroadData;
  // 로그인 응답
  //FApi.OnReplyLogin := OnWRAXReplyLogin;
  FApi.OnGetMsg := OnHDFCommAgentOnGetMsg;
  // 파일 다운 로드 응답 
  //FApi.OnReplyFileDown := OnWRAXReplyFileDown;
  FApi.OnGetMsgWithRqId := OnHDFCommAgentOnGetMsgWithRqId;

  // 수신자 객체 생성
  FRecevier:= TApiReceiver.Create;

  // 쓰레드 생성
  FApiThread:= TApiRecvThread.Create;
  // 쓰레드 이벤트 핸들러 연결 
  FApiThread.OnApiRecvEvent := OnApiThreadEvent;


  // 질의 리스트 생성
  FQryList := TList.Create;
  // 서브 리스트 생성
  FSubList := TList.Create;
  // 요청 리스트 생성
  FReqList := TList.Create;
  // 자동 시세 리스트 생성
  FAutoQuoteList := TList.Create;

  FViReqList := TStringList.Create;

  FViReqIdList := TStringList.Create;

  FViSymbolCodeList := TStringList.Create;

  // 질의 타이머 생성
  QryTimer  := TTimer.Create( OrpMainForm );
  QryTimer.Interval := 15;
  QryTimer.Enabled  := false;
  QryTimer.OnTimer  := TimeProc;

  FViReqTimer := TTimer.Create(OrpMainForm);
  FViReqTimer.Interval := 700;
  FViReqTimer.Enabled := false;
  FViReqTimer.OnTimer := TimeViReq;

  // 자동 타이머 생성
  FAutoTimer  := TTimer.Create( OrpMainForm );
  FAutoTimer.Interval := 200;
  FAutoTimer.Enabled  := false;
  FAutoTimer.OnTimer  := TimeProc2;

  // 질의 카운트 초기화
  for I := 0 to Qry_Cnt - 1 do
    FQryCount[i]  := 0;

  // 송신한 질의 카운트
  FSendQryCount := 0;
  // 계좌 질의 카운트
  FAccountQryCount  := 0;

  // 크리티컬 섹션 생성 
  InitializeCriticalSection(CritSect);

end;

// 파괴자
destructor TApiManager.Destroy;
begin

  // 크리티컬 섹션 파괴자
  DeleteCriticalSection(CritSect);

  MyList.Free;
  //Fin;
  // 쓰레드 종료
  FApiThread.Terminate;
  // 쓰레드 이벤트 함수 널
  FApithread.OnApiRecvEvent := nil;
  // 쓰레드 해제
  FApiThread.Free;

  FViReqIdList.Free;

  FViReqList.Free;

  FViSymbolCodeList.Free;
  
  // 요청 목록 해제
  FReqList.Free;
  // 질의 목록 해제
  FQryList.Free;
  // 하위 목록 해제
  FSubList.Free;
  // 자동 시세 목록 해제
  FAutoQuoteList.Free;
  // 수신자 객체 해제
  FRecevier.Free;
  // 부모 파괴자 호출
  inherited;
end;


procedure TApiManager.OnHDFCommAgentOnGetData(ASender: TObject; nType: Integer; wParam: Integer;
                                                       lParam: Integer);
begin

end;
procedure TApiManager.OnHDFCommAgentOnRealData(ASender: TObject; nType: Integer; wParam: Integer;
                                                        lParam: Integer);
begin

end;
procedure TApiManager.OnHDFCommAgentOnDataRecv(ASender: TObject; const sTrCode: WideString; nRqId: Integer);
var
  i : integer;
  aItem : TViRequestItem;
begin
  gLog.Add( lkApplication, 'TApiManager', 'OnDataRecv',
    Format('nRqId : %d, Code : %s',[ nRqId, sTrCode ])) ;



  if sTrCode = DefAccountList then
    OnAccountList(sTrCode, nRqId)
  else if sTrCode = DefSymbolCode then begin
    OnSymbolCode(sTrCode, nRqId);
  end
  else if sTrCode = DefSymbolMaster then
    OnSymbolMaster(sTrCode, nRqId);


  CheckRqResult(nRqId, sTrCode, '');
end;
procedure TApiManager.OnHDFCommAgentOnGetBroadData(ASender: TObject; const sJongmokCode: WideString;
                                                            nRealType: Integer);
begin

end;
procedure TApiManager.OnHDFCommAgentOnGetMsg(ASender: TObject; const sCode: WideString;
                                                      const sMsg: WideString);
begin
  CheckRqResult(0, sCode, sMsg);
end;
procedure TApiManager.OnHDFCommAgentOnGetMsgWithRqId(ASender: TObject; nRqId: Integer;
                                                              const sCode: WideString;
                                                              const sMsg: WideString);
begin
  gLog.Add( lkApplication, 'TApiManager', 'OnGetMsgWithRqId',
    Format('nRqId : %d, Code : %s, Msg : %s',[ nRqId, sCode, sMsg ])) ;
  CheckRqResult(nRqId, sCode, sMsg);
end;

function WideStringAsAnsi(const AValue: WideString): AnsiString;
begin
  SetLength(Result, Length(AValue) * SizeOf(WideChar));
  Move(PWideChar(AValue)^, PAnsiChar(Result)^, Length(Result));
end;

procedure TApiManager.OnAccountList(const sTrCode: WideString; const nRqId: Integer);
var
  stData, stNo, stName, stGubun, trCode : string;
  iCnt, iOffset, i, iStart : Integer;
  stTmp : string;
begin
  trCode := sTrCode;
  stData := FApi.CommGetAccInfo();
  iStart := 0;
  iCnt   := StrToIntDef( Copy( stData, iStart, 5 ), 0 );
  iStart := 6;
  for I := 0 to iCnt - 1 do
  begin
    stNo   := Copy( stData, iStart, Acnt_No_Len );
    iStart := iStart + Acnt_No_Len;
    stName   := Copy( stData, iStart, Acnt_Name_Len );
    iStart := iStart + Acnt_Name_Len;
    stGubun := Copy( stData, iStart, Acnt_Gubun_Len );
    iStart := iStart + Acnt_Gubun_Len;
    gEnv.Engine.TradeCore.Investors.New( trim( string( stNo )), trim( string( stName )), ''  );

    stTmp := stTmp + ' ' + stNo ;
  end;

  // 투자자 로그
  gLog.Add( lkApplication, 'TApiManager', 'OnAccountList',
    Format('계좌 : %d, %s', [ iCnt, stTmp ])) ;

end;

procedure TApiManager.OnSymbolCode(const sTrCode: WideString; const nRqId: Integer);
var
  iCnt, i : Integer;
  stData : string;
  stSymbolCode : string;
begin
  gLog.Add( lkApplication, 'TApiManager', 'OnSymbolCode',
    Format('응답 : %d, Code : %s', [ nRqId, sTrCode ])) ;

  iCnt := FApi.CommGetRepeatCnt(sTrCode, -1, 'OutRec1');
  for i := 0 to iCnt - 1 do begin
    stData := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '종목코드');
   
    if Copy(stData, 0, 1) <> '4' then begin
      // ShowMessage(stData);
      stSymbolCode := Trim(stData);
      AddSymbolMasterRequest(stSymbolCode);
      //LoadMasterFromSymbolCode(Trim(stData));
      //FViSymbolCodeList.AddObject(IntToStr(FViSymbolCodeList.Count), i);
    end;


  end;



  
  

end;

function TApiManager.CheckRqResult(const nRqId : integer; const sCode, sMsg : WideString): integer;
var
  i : integer;
  strData : string;
  reqIndex, idIndex : integer;
  Key : string;
begin

  if nRqId <= 0 then begin
    Result := -1;
    Exit;
  end;

  // 크리티컬 섹션 진입
  EnterCriticalSection(CritSect);

  gLog.Add( lkApplication, 'TApiManager', 'CheckRqResult ', Format(' ViReqList Count = %d, Code : %s', [ ViReqList.Count, sCode ])) ;

  try begin
    idIndex := FViReqList.IndexOf(IntToStr(nRqId));
    if idIndex >= 0 then begin
      strData := FViReqList.Values[IntToStr(nRqId)];
      FViReqList.Delete(idIndex);
    end;
  end;
  finally
    LeaveCriticalSection(CritSect)
  end;
  

  if (DefSymbolCode = sCode) and (FQryCount[0] > 0) then begin
    gLog.Add( lkApplication, 'TApiManager', 'CheckRqResult ', Format(' Symbol Code Req each :: nRqId = %d, Code : %s', [ nRqId, sCode ])) ;
  end;

  if (DefSymbolMaster = sCode) and (FQryCount[1] > 0) then begin
    gLog.Add( lkApplication, 'TApiManager', 'CheckRqResult ', Format(' Symbol Master Req each :: nRqId = %d, Code : %s', [ nRqId, sCode ])) ;
  end;

  if (DefSymbolCode = sCode) and (nRqId > 0) and (FQryCount[0] > 0) and (FQryCount[0] = Vi_Market_Cnt) then begin
    //FViReqTimer.Enabled := true;
    //gEnv.SetAppStatus( asReqSymbolMaster );
    gLog.Add( lkApplication, 'TApiManager', 'CheckRqResult ', Format(' Symbol Code Req :: nRqId = %d, Code : %s', [ nRqId, sCode ])) ;
    //gEnv.SetAppStatus( asRecoveryStart );
    //sleep(700);

    FQryCount[0] := 0;
    gEnv.SetAppStatus( asRecoveryStart );
  end ;

  {
  if (DefSymbolMaster = sCode) and (nRqId > 0) and (FQryCount[1] > 0) and (FQryCount[1] = FViSymbolCodeList.Count) then begin
    //FViReqTimer.Enabled := true;
    //gEnv.SetAppStatus( asReqSymbolMaster );
    gLog.Add( lkApplication, 'TApiManager', 'CheckRqResult ', Format(' Symbol Code Req :: nRqId = %d, Code : %s', [ nRqId, sCode ])) ;

    //gEnv.SetAppStatus( asReqSymbolMaster );
    FQryCount[1] := 0;
    gEnv.SetAppStatus( asRecoveryStart );
  end ;
  }

  if (nRqId > 0) and (QryList.Count > 0) then
    FQryTimer.Enabled := true;

  
  Result := nRqId;
end;


procedure TApiManager.OnSymbolMaster(const sTrCode: WideString; const nRqId: Integer);
var
  stSymbolCode : string;
  stEnName : string;
  stKrName : string;
  stShortKrName : string;
  stShortName : string;
  stPrev : string;
  stUpdown : string;
  stRemainDays : string;
  stLastDay : string;
  stBasePrice : string;
  stHighLimit : string;
  stLowLimit : string;
  stPreClose : string;
  stTradeUnit : string;
  stTradeTime : string;
  stClose : string;
  stOpen : string;
  stHigh : string;
  stLow : string;
  stAccAmount : string;
  stKospi200 : string;
  stExpYrMn : string;
  stStrike : string;
  stSeq : string;
  stRecentMn : string;
  stAtm : string;
  stPreOpen : string;
  stPreHigh : string;
  stPreLow : string;
  stPriceUnitBase : string;
  stHogaUnit1 : string;
  stHogaUnit2 : string;
  stKospiAtm : string;
  stShortCode : string;
  iCnt, i : integer;
begin
  gLog.Add( lkApplication, 'TApiManager', 'OnSymbolMaster',
    Format('응답 : %d, Code : %s', [ nRqId, sTrCode ])) ;
  iCnt := FApi.CommGetRepeatCnt(sTrCode, -1, 'OutRec1');
  for i := 0 to iCnt - 1 do begin
    stSymbolCode := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '단축코드');
    stSymbolCode := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '종목코드');
    stEnName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '영문종목명');
    stKrName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '한글종목명');
    stShortKrName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '종목한글약명');
    stShortName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '축약종목명');
    stPrev := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '전일대비');
    stUpdown := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '등락률');
    stRemainDays := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '잔존일수');
    stLastDay := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '최종거래일');
    stBasePrice := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '기준가격');
    stHighLimit := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '상한가');
    stLowLimit := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '하한가');
    stPreClose := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '전일종가');
    stTradeUnit := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '거래단위');
    stTradeTime := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '체결시간');
    stClose := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '현재가');
    stOpen := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '시가');
    stHigh := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '고가');
    stLow := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '저가');
    stAccAmount := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '누적거래량');
    stKospi200 := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	KOSPI200지수');
    stExpYrMn := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '만기년월');
    stStrike := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '행사가격');
    stSeq := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '조회순번');

    stRecentMn := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '최근월물구분');
    stAtm := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	ATM구분');
    stPreOpen := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	전일시가');
    stPreHigh := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '전일고가');
    stPreLow := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '전일저가');
    stPriceUnitBase := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '가격단위기준값(3.00)');
    stHogaUnit1 := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '호가단위(0.01)');
    stHogaUnit2 := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '호가단위(0.05)');
    stKospiAtm := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	KOSPI등가');



  end;



end;


// 접속 실행 함수
procedure TApiManager.DoConnect( iMode : integer );
var
  // ip, port 문자열 
  wsIP , wsPort : WideString;
  nRet : Integer;
begin

  // 유니코드를 돌려 준다.
  wsIP    := WideFormat( '%s', [
    ifThenStr( iMode = 0,  gEnv.ConConfig.TradeAddr, gEnv.ConConfig.TradeAddr2 ) ] );
  wsPort  := WideFormat( '%d', [ gEnv.ConConfig.Port ] );

  // 로그 기록 - 로그 타입 - 응용 프로그램
  gLog.Add( lkApplication, 'TApiManager','DoConnect',  Format('접속 시 : %s, %s', [  wsIP, wsPort  ])) ;

  //wsIP := '210.183.186.20';
  //wsPort := '8300';
  // 접속 처리 함수 호출
  //FApi.OConnectHost( wsIP, wsPort );
  nRet := FApi.CommInit(1);

  if nRet < 0 then begin
    gLog.Add( lkApplication, 'TApiManager','DoConnect',  '통신프로그램 실행 오류') ;
  end else begin
    gLog.Add( lkApplication, 'TApiManager','DoConnect',  '통신프로그램 성공') ;
    FReady := true;
  end;

  DoLogin;

end;

// 로그인 진행 - 폼에서 여길 먼저 호출한다. 
function TApiManager.DoLogIn(stID, stPW, stCert: string; iMode: integer) : integer ;
var
  // 결과 값, 모름
  iRes, iDiv : integer;
  //
  stDir: string;
  // 접속 되었는가?
  bConn: boolean;

begin

  Result := 0 ;

{ 모드별 분기
  // 0  : 접속 먼저
  // 1  : 접속은 됐으니 로그인 하시오
}
  // 준비 되지 않았으면
  if not FReady then
    bConn := True;
  //else begin  // 준비 된 경우
    // 로그인이 되었는가
    //if FApi.OIsLogined then
    //begin
      // 로그인 상태라 재접 속
      //gLog.Add( lkApplication, 'TWooApiIF', 'DoLogin', '로그인상태라서 재접속' );

      //iRes := MessageDlgLE( gEnv.Main, '현재 로그인중입니다. 기존 접속을 끊고 접속하시겠습니까?',
         //mtWarning, [mbYes , mbNo] );

      // mrYes,  mrOk
      //if (iRes = 0 {mrYes}) or ( iRes = 1 {mrOK} ) then
      //begin
        // 호스트 종료
        //FApi.OCloseHost;
        //sleep( 100 );
       // bConn := true;
      //end else
      //begin
       // gEnv.Main.Close;
      //  Exit;
      //end;
    //end else
    //  bConn := false;
  //end;

  gEnv.ConConfig.UserID   := stID;
  gEnv.ConConfig.Password := stPW;
  gEnv.ConConfig.CertPass := stCert;
  gEnv.ConConfig.RealMode := ifThenBool( iMode = 0, true, false );


  // 접속을 해야 하면 접속을 먼저 함
  if bConn then
    DoConnect( iMode )
  else // 접속이 필요 없으면 로그인 수행 
    DoLogIn;
end;

// 로그인 수행
procedure TApiManager.DoLogIn;
var
  // 아이디, 비번, 인증서 
  wstID, wstPW, wstCert: widestring;
  nResult : integer;
begin

  // 로그 기록
  gLog.Add( lkApplication, 'TApiManager','DoLogIn',  Format('로그인시도 : %s, %s, %s, %s', [
    gEnv.ConConfig.UserID, gEnv.ConConfig.Password,
    gEnv.ConConfig.CertPass , ifThenStr( gEnv.ConConfig.RealMode, '리얼','모의')  ])) ;

  // 아이, 비번, 인증서 가져옴
  wstID :=  gEnv.ConConfig.UserID;
  wstPW := gEnv.ConConfig.Password;
  wstCert := gEnv.ConConfig.CertPass;

  // Api로 로그인 한다.
  //FApi.OLogin( wstID, wstPW, wstCert);
  nResult := FApi.CommLogin(wstID, wstPW, wstCert);


  if nResult > 0 then begin
    gLog.Add( lkApplication, 'TWooApiIF', 'CommLogin', '로그인 성공' ) ;
    gEnv.SetAppStatus( asConMaster );
    //DoRequestAccout;
    //DoRequestMaster;
    // 계좌 정보 요청
    FApi.CommAccInfo();
  end
  else begin
    gLog.Add( lkApplication, 'TWooApiIF', 'CommLogin', '로그인 실패'  );
    gEnv.ErrString  := '로그인 실패 ' ;
    gEnv.SetAppStatus( asError );
  end;

end;

// 요청을 추가
procedure TApiManager.AddRequest( stTr, stData : string; iReq : integer );
var
  aItem : TRequestItem;
begin
  // 요청 아이템 생성
  aItem := TRequestItem.Create( nil );
  aItem.TrCode  := stTr; // 코드
  aItem.Data    := stData;  // 데이터
  aItem.Tag     := iReq;  // 요청 번호
  FReqList.Add( aItem );
end;

function TApiManager.FindAccountCode( iReq : integer ) : string;
var
  aItem : TRequestItem;
  aIn   : ^TInputDeposit;
  I: Integer;
begin

  // 요청 리스트를 돌면서
  for I := FReqList.Count -1 downto 0 do
  begin
    // 요청 아이템 복사
    aItem := TRequestItem( FReqList.Items[i] );
    // 계좌 상태 요청 이라면 
    if ( aItem.TrCode = Qry_AcntState ) and ( aItem.Tag = iReq ) then
    begin
      // 요청 리스트에서 해당 요청을 지운다.
      FReqList.Delete(i);
      // 요청 포인터를 가져온다.
      aIn :=  @aItem.Data[1];
      Result  := trim( string( aIn.AccountNo ));
      aItem.Free;
      break;
    end;
  end;
end;

// 요청 수행 
function TApiManager.DoRequest(stTr, stData: string ) : integer;
var
  iSize : integer;
begin
  iSize   := Length( stData );
  if iSize <= 0 then
    Result := -100 ;
  //else
    // 요청 함수 호출
    //Result  := FApi.ORequestData( stTr, iSize, stData, true, false, ExSec );

  // 실패인 경우 
  if Result <= 0 then
    gLog.Add( lkError, 'TApiManager','DoRequest', Format('Error : %d (%s, %s)',[ Result, stTr, stData ] )  )
  // 성공인 경우 
  else if (Result > 0 ) and ( stTr = Qry_AcntState ) then  begin
    // 예탁금 조회 패킷엔 계좌번호가 없다는 왜 그런지...참내
    gEnv.EnvLog( WIN_TEST, Format('DoRequest (%d)(%d) : %s', [ Result, FReqList.Count, stData]) );
    // 요청 목록에 추가 
    AddRequest( stTr, stData, Result )
  end;
end;

// 계좌 요청 수행 
procedure TApiManager.DoRequestAccout;
var
  iCnt : integer;
  I: Integer;
  wstAcntNo, wstAcntName  : WideString;
  stTmp : string;
begin
  gLog.Add( lkApplication, 'TApiManager', 'DoRequestAccout', '계좌 요청' );
  // 계좌 요청 갯수
  //iCnt := FApi.OGetAccountInfCount;
  stTmp:= '';
  for I := 0 to iCnt - 1 do
  begin
    // 계좌 정보
    //FApi.OGetAccountInf( i, wstAcntNo, wstAcntName );
    // 투자자 정보
    gEnv.Engine.TradeCore.Investors.New( wstAcntNo, wstAcntName, '' );
    stTmp := stTmp + ' ' + wstAcntNo ;
  end;

  // 투자자 로그
  gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpAcctList',
    Format('계좌 : %d, %s', [ iCnt, stTmp ])) ;
end;

// 마스터 요청
procedure TApiManager.DoRequestMaster;
var
  wsFileName : string;
begin

  gLog.Add( lkApplication, 'TApiManager', 'DoRequestMaster', 'Request the Symbol Master' );
  wsFileName := gEnv.QuoteDir +'\' +FormatDateTime('yyyymmdd',Date)+'_woomaster.txt';
  //if not FileExists( wsFileName ) then
  //  FApi.OGetMasterFile( wsFileName )
  //else
  //  LoadMaster( wsFileName );
end;

{
 function CommRqData(const sTrCode: WideString; const sInputData: WideString; nLength: Integer;
                        const sPrevOrNext: WideString): Integer;
                        }
procedure TApiManager.DoRequestSymbolCode(stMarketCode: string);
var
  stInput, stNextKey : string;
begin
  stInput := stMarketCode;
  stNextKey := '';
  //RequestViData( DefSymbolCode, stInput, Length(stInput), stNextKey);
end;

// 심볼 정보 요청
procedure TApiManager.DoRequestSymbolInfo;
var
  i, j : integer;
  aSymbol : TSymbol;
  aOptMarket : TOptionMarket ;
  aFutMarket : TFutureMarket;
  aOptTree   : TOptionTree;
  aStrike    : TStrike;
  aItem : TViRequestItem;
begin
  // 선물, 옵션 최근월물만...조회
  // 조회 날리고 타이머 On 시킨다.
  gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', 'Request the Symbol Info' );
  // 선물 시장 순회
  for I := 0 to gEnv.Engine.SymbolCore.FutureMarkets.Count - 1 do
  begin
    aFutMarket := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[i];
    // 선물 시장별 코드 조회
    for j := 0 to aFutMarket.Symbols.Count - 1 do
    begin
      aSymbol := aFutMarket.Symbols.Symbols[j];
      //if aSymbol.IsStockF then break;
      if aSymbol <> nil  then
      begin
          // 요청 집어 넣기
         //PushRequest( Qry_LastPrice, aSymbol.Code );
         AddSymbolMasterRequest(aSymbol.Code);
         gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', aSymbol.Code );
      end;
      // 최근월물만 조회하기 위해
      if j >= 1 then break;
    end;
  end;

  // 옵션 심볼을 돌면서 요청 
  for j := 0 to gEnv.Engine.SymbolCore.OptionMarkets.Count - 1 do
  begin
    // 옵션 시장 가져옴
    aOptMarket  := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[j];
    // 없으면 건너 뜀 
    if aOptMarket = nil then Continue;

    // 옵션 코드 비교 
    if (CompareStr(aOptMarket.Spec.FQN, FQN_MINI_KOSPI200_OPTION) = 0) or
      (CompareStr(aOptMarket.Spec.FQN, FQN_KOSPI200_OPTION) = 0) then
    begin
      // 맨 앞에 것만 가져 옴.
      aOptTree  := aOptMarket.Trees.FrontMonth;// Trees[0];
      for I := 0 to aOptTree.Strikes.Count -1 do
      begin
        // 최근월물
        aStrike := aOptTree.Strikes.Strikes[i];
        // 최근월물 콜, 풋만 요청 
        //PushRequest( Qry_LastPrice, aStrike.Call.ShortCode );
        //PushRequest( Qry_LastPrice, aStrike.Put.ShortCode );
        AddSymbolMasterRequest(aStrike.Call.ShortCode);
        AddSymbolMasterRequest(aStrike.Put.ShortCode);
        gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', aStrike.Call.ShortCode );
        gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', aStrike.Put.ShortCode );
      end;
      // 차월 물 
          {
      aOptTree  := aOptMarket.Trees.Trees[1];
      for I := 0 to aOptTree.Strikes.Count -1 do
      begin
        aStrike := aOptTree.Strikes.Strikes[i];
        PushRequest( Qry_LastHoga, aStrike.Call.ShortCode );
        PushRequest( Qry_LastHoga, aStrike.Put.ShortCode );
      end;
      }
    end;
  end;


  {
  for i := 0 to FViReqList.Count - 1 do begin
      aItem := FViReqList.Objects[i] as TViRequestItem;



      gLog.Add( lkApplication, 'TApiManager','DoRequestSymbolInfo', Format('SymbolMaster Req : %s, %s, %s', [ aItem.TrCode, aItem.Data, aItem.nIndex ]) );


      //ShowMessage(aItem.TrCode);
    end;
    }

end;

// 주문 요청 보냄 
function TApiManager.DoSendOrder(aOrder: TOrder): string;
var
  aInvest : TInvestor;
  iSide, iPrc   : integer;
  stLog : string;
begin
  Result := '';
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try

    // 투자자 코드 확인
    aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
    // 투자자 없으면 진행하지 않는다.
    if aInvest = nil then Exit;

    // 매수 / 매도 
    if aOrder.Side > 0 then
      iSide := 1
    else
      iSide := 2;

    // 주문 타입에 따른 처리
    case aOrder.OrderType of
      // 신규 주문
      otNormal:
        begin
          stLog := '신규';

          case aOrder.PriceControl of
            pcLimit:  iPrc := 1;
            pcMarket: iPrc := 2;
            pcLimitToMarket:iPrc := 3 ;
            pcBestLimit:    iPrc := 4;
          end;
          // 신규 주문 요청
          //Result := FApi.OSendNewOrder(  aInvest.Code, aInvest.PassWord, aOrder.Symbol.Code,
          //  iSide,  iPrc, 1, aOrder.OrderQty, aOrder.Price, aOrder.LocalNo );
        end;

      // 정정 주문
      otChange:
        begin
          if aOrder.Target = nil then
          begin
            gEnv.EnvLog( WIN_ERR, format('정정주문 에러 : 원주문이 없음 %s', [ aOrder.Represent3 ]));
            Exit;
          end;
          stLog := '정정';

          case aOrder.PriceControl of
            pcLimit:  iPrc := 1;
            pcMarket: iPrc := 2;
            pcLimitToMarket:iPrc := 3 ;
            pcBestLimit:    iPrc := 4;
          end;

         // Result  := FApi.OSendModiOrder(   aInvest.Code, aInvest.PassWord, aOrder.Symbol.Code,
         //   iSide, iPrc, 1, aOrder.OrderQty, aOrder.Price, IntToStr(aOrder.Target.OrderNo), aOrder.LocalNo );

        end;
      // 취소 주문
      otCancel:
        begin
          if aOrder.Target = nil then
          begin
            gEnv.EnvLog( WIN_ERR, format('취소주문  에러 : 원주문이 없음 %s', [ aOrder.Represent3 ]));
            Exit;
          end;
          stLog := '취소';

          //Result  := FApi.OSendCancelOrder( aInvest.Code, aInvest.PassWord, aOrder.Symbol.Code,
          //  iSide, aOrder.OrderQty, IntToStr(aOrder.Target.OrderNo), aOrder.LocalNo ) ;
        end ;
    end;
  finally // 예외 처리 
    gEnv.EnvLog( WIN_TEST, Format('%s:%s', [ Result, aOrder.Represent3]));
    if Result[1] = '-' then begin          
      gEnv.Engine.TradeBroker.SrvReject( aOrder, '99999', Result );
      //gLog.Add( lkReject, '','', Format('%s:%s', [ Result, aOrder.Represent3]) );
    end;
  end;
end;


procedure TApiManager.LoadMasterFromSymbolCode(stSymbolCode: string);
begin
  gLog.Add( lkApplication, 'TApiManager', 'LoadMasterFromSymbolCode', 'Load the Symbol Master From the Symbol Code' );
  if Length(stSymbolCode) < 8 then begin
    gLog.Add( lkApplication, 'TApiManager', 'LoadMasterFromSymbolCode', stSymbolCode + ' -> 심볼 코드 이상 ' );
    Exit;
  end;

  gEnv.Engine.SymbolCore.SymbolLoader.ImportMasterFromSymbolCode( stSymbolCode);

end;

// 마스터 파일 로딩 
procedure TApiManager.LoadMaster(stFileName: string);
var
  aParser : TParser;
  F: TextFile;
  stData : string;
  iCnt  : integer;
begin

  gLog.Add( lkApplication, 'TApiManager', 'LoadMaster', 'Load the Symbol Master' );
  if not FileExists( stFileName ) then
  begin
    gLog.Add( lkApplication, 'TWooApiIF', 'LoadMaster', stFileName + ' -> 파일이 없음 ' );
    Exit;
  end;

  try
    aParser := TParser.Create([',']);
    AssignFile(F, stFileName);
    System.Reset(F);

    while not Eof(F) do
    begin
        // readln
      Readln(F, stData);
        // decode packet
      iCnt  := aParser.Parse(stData);
      //gEnv.EnvLog( WIN_GI, 'M : ' +stData);
      gEnv.Engine.SymbolCore.SymbolLoader.ImportMasterFromNHApi( aParser, iCnt );
    end;

  finally
    aParser.Free;
    CloseFile(F);
    gEnv.Engine.SymbolCore.OptionPrint;
    DoRequestSymbolInfo;
    gEnv.SetAppStatus( asRecoveryStart );
  end;

end;


procedure TApiManager.ESApiExpESExpRecvData(ASender: TObject; nTrCode: Smallint;
  const szRecvData: WideString);
begin
  //ShowMessage( Format( 'RecvData TR : %d   , %s', [ nTrCode, Copy( szRecvData, 1, 100)]));
  {
  try
  case nTrCode of

    ESID_5101 ,
    ESID_5102 ,
    ESID_5103 :
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d,%139.139s', [ nTrCode, szRecvData]));
        gReceiver.ParseOrderAck( nTrCode, szRecvData);
      end;
    ESID_2007,
    ESID_2003,
    ESID_2004 :
      begin
        //gEnv.EnvLog( WIN_GI, Format('%d,%139.139s', [ nTrCode, szRecvData]));
        FQryCount[SYMBOL_QRY] := Max( 0, FQryCount[SYMBOL_QRY] -1 );
        dec( FSendQryCount );
        case nTrCode of
          ESID_2007 : gEnv.Engine.SymbolCore.SymbolLoader.ImportMasterFromKrApi( szRecvData );
          ESID_2003 : gReceiver.ParseMarketPrice( szRecvData );
          ESID_2004 : gReceiver.ParseReqHoga( szRecvData );
        end;

        if (FSendQryCount <= 5) and ( not gEnv.RecoveryEnd ) then
          gEnv.SetAppStatus( asRecoveryStart );
      end;
    ESID_1041 : gReceiver.ParseChartData( szRecvData );
    ESID_5130 : gReceiver.ParseAbleQty( szRecvData);

    ESID_5111 ,  // 실체결
    ESID_5112 ,	 // 실잔고
    ESID_5122 ,  // 예탁자산및 증거금
    ESID_5124 :
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d:%s', [ nTrCode, szRecvData])  );
        dec( FAccountQryCount );
        FQryCount[ACCOUNT_QRY] := Max( 0, FQryCount[ACCOUNT_QRY]-1 );

        case nTrCode of
          ESID_5111 : gReceiver.ParseActiveOrder( szRecvData );
          ESID_5112 : gReceiver.ParsePosition(szRecvData);
          ESID_5122 : gReceiver.ParseDeposit( szRecvData );
          ESID_5124 : gReceiver.ParseAdjustMent( szRecvData );
        end;

        if (FAccountQryCount <= 1) and ( not gEnv.RecoveryEnd ) then
          gEnv.SetAppStatus( asRecoveryEnd );
       // if gEnv.RecoveryEnd then
       //    gEnv.EnvLog( WIN_TEST, Format('recovery %d(%d):%s', [ nTrCode, FAccountQryCount, szRecvData])  );
        
      end;

    AUTO_0923 : gReceiver.ParseHoga( szRecvData );  	// 종목 호가 실시간
    AUTO_0921	: gReceiver.ParsePrice( szRecvData );   //  종목 시세 실시간
    AUTO_0932 : gReceiver.ParseTickArray( szRecvData );
    AUTO_0988 :
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d,%s', [ nTrCode, szRecvData]));
        gReceiver.ParseOrder( szRecvData);
      end;
    AUTO_0909 : gReceiver.ParseInvestOptData( szRecvData );
    AUTO_0908 : gReceiver.ParseInvestFutData( szRecvData );

  end;

  except

  end;
     }
end;



// 종료
procedure TApiManager.Fin;
begin
  //if FApi.OIsLogined then
  //  FApi.OCloseHost;
end;

// 오류 메시지
function TApiManager.GetErrorMessage(iRes: integer): string;
begin
  Result := '';
  case TResultType( iRes ) of
    rtNone          : Result := '정상';
    rtAutokey       : Result := '계좌 자동업데이트 key 미입력';
    rtUserID        : Result := '접속 아이디 미입력';
    rtUserPass      : Result := '접속 비밀번호 미입력';
    rtCertPass      : REsult := '공인인증 비밀번호 미 입력';
    rtSvrSendData   : Result := '서버 전송 오류';
    rtSvrConnect    : Result := '서버 접속 상태';
    rtSvrNoConnect  : Result := '서버 접속 오류';
    rtCerTest       : Result := '인증 데이터 가져오기 실패';
    rtDllNoExist    : Result := 'signkorea dll 파일경로';
    rtTrCode        : Result := '허용되지 않은 TR번호';
  end;
end;

function TApiManager.GetViErrorMessage(iRes: integer): string;
begin
  Result := '';
  if iRes > 0 then
    Result := '정상'
  else if iRes = -1 then
    Result := '서비스 목록에 없음'
  else if iRes = -4 then
    Result := '비밀번호 길이 오류'
  else if iRes = -3 then
    Result := '비밀번호 해쉬 작업 오류'
  else if iRes = -2 then
    Result := '로그인 되어 있지 않음'
  else
    Result := 'commapi 오류';
       
end;

// 현재 날 짜 얻기
function TApiManager.GetCurrentDate(bDate: boolean): TDateTime;
var
  stDate : string;
begin
{
  stDate  := FApi.ESExpGetCurrentDate;
  Result  := EncodeDate(StrToIntDef(Copy(stDate,1,4), 0),
                           StrToIntDef(Copy(stDate,5,2), 0),
                           StrToIntDef(Copy(stDate,7,2), 0))
                           }
end;

// 현재 날짜 얻기 
function TApiManager.GetCurrentDate: string;
begin
//  Result  := FApi.ESExpGetCurrentDate;
end;


// 쓰레드 이벤트 핸들러
procedure TApiManager.OnApiThreadEvent(aPacket: POrderPacket);
begin
  case TApiRealType(aPacket.iDiv) of
    // 선믈 호가
    atFutHoga : FRecevier.ParseFutHoga( string(aPacket.Packet) );
    // 선물 가격
    atFutExec : FRecevier.ParseFutPrice( string(aPacket.Packet) );
    // 옵션 호가
    atOptHoga : FRecevier.ParseOptHoga( string(aPacket.Packet) );
    // 옵션 시세
    atOptExec : FRecevier.ParseOptPrice( string(aPacket.Packet) );
    // 주문
    atOrder :   FRecevier.ParseOrder( string(aPacket.Packet) );
    // 선물 투자
    atFutInvest : FRecevier.ParseInvestFutData( string(aPacket.Packet) );
    // 옵션 투자
    atOptInvest : FRecevier.ParseInvestOptData( string(aPacket.Packet) );
    // 주식 선물 호가
    atStockFutHoga : FRecevier.ParseStockFutHoga(string(aPacket.Packet));
    // 주식 선물 시세 
    atStockFutExec : FRecevier.ParseFutPrice( string(aPacket.Packet) );
  end;
end;

// 접속 응답 
procedure TApiManager.OnWRAXConnected(Sender: TObject);
begin
  inc( FCount );
  FReady := true;
  gLog.Add( lkApplication, 'TApiManager', 'OnWRAXConnected', Format('%d th 접속 로그인 시도 ', [ FCount] ) );
  DoLogin;
end;

// 접속 해제 응답 
procedure TApiManager.OnWRAXDissConnected(Sender: TObject);
var
  stTmp : string;
  iRes  : integer;
begin
  FReady := false;
  gLog.Add( lkApplication, 'TApiManager', 'DoInit', '접속 종료' );
  //gEnv.EnvLog( WIN_TEST, '접속 종료');

  stTmp := '주문접속이 끊겼습니다';//  자동재접속하시겠습니까?';
  {
  iRes := MessageBox(gEnv.Main.Handle, PChar(stTmp), '접속확인', MB_YESNO+MB_SYSTEMMODAL+MB_APPLMODAL	);
  if iRes = IDYES then
  begin
    gEnv.SaveLoginInfo;
    gEnv.Main.Close;
    WinExec( 'grLauncher.exe AutoConnect', SW_SHOWNORMAL );
  end
  else
  begin
  }
    ShowMessage( stTmp );//'프로그램을 종료합니다' );
    gEnv.Main.Close;
  //end;

end;

// 데이터 수신 함수 
procedure TApiManager.OnWRAXRecvData(ASender: TObject; DataType: Smallint;
  const TrCode: WideString; nRqID: Smallint; nDataSize: Integer;
  var szData: WideString);
  var
    stTr , stData : string;
begin

  if TrCode <> Qry_LastPrice then
    gEnv.EnvLog( WIN_PACKET, Format('Recv %s : (%d:%d)%s', [ TrCode, nRqID, nDataSize, szData]));

  case DataType of
    68 : if (TrCode = Rsp_NewOrder) or ( TrCode = Rsp_CnlOrder ) or (  TrCode = Rsp_ModOrder ) then
           gEnv.EnvLog( WIN_PACKET, Format('%s : (%d)%s', [ TrCode,  nDataSize, szData]));
    77 : ;//  gLog.Add( lkWarning, '','', Format( 'M : %s, %d, %s', [ TrCode, nRqID, szData ]) );
    82 : Exit;
    69 :
      begin
        gLog.Add( lkError, '','', Format( 'E : %s, %d, %s', [ TrCode, nRqID, szData ]) );
        Exit;
      end;
  end;

  stTr  := TrCode;

  if ((TrCode = Rsp_NewOrder) or ( TrCode = Rsp_CnlOrder ) or (  TrCode = Rsp_ModOrder ))
    and ( DataType = 68) then
    gReceiver.ParseOrderAck( 0, szData )
  else if TrCode = Qry_AbleOrdCnt then
  else if TrCode = Qry_OrdList then
    gReceiver.ParseActiveOrder( szData )
  else if TrCode = Qry_OrdDetList then
  else if TrCode = Qry_OrdReject then
  else if TrCode = Qry_AcntPos then begin
    gReceiver.ParsePosition( szData );
    if  not gEnv.RecoveryEnd then
      gEnv.SetAppStatus( asRecoveryEnd );
  end
  else if TrCode = Qry_AcntState then
  begin
    if DataType = 68 then
      gReceiver.ParseAdjustMent(nRqID, szData );
  end
  else if TrCode = Qry_LastPrice then
  begin
    EnterCriticalSection(CritSect);
    dec( FQryCount[Qry_Cnt-3] );
    if FQryCount[Qry_Cnt-3] < 0 then
      FQryCount[Qry_Cnt-3] := 0;
    LeaveCriticalSection(CritSect);
    gReceiver.ParseMarketPrice( szData );
  end
  else if TrCode = Qry_LastHoga then
  begin
    EnterCriticalSection(CritSect);
    dec( FQryCount[Qry_Cnt-2] );
    if FQryCount[Qry_Cnt-2] < 0 then
      FQryCount[Qry_Cnt-2] := 0;
    LeaveCriticalSection(CritSect);
    gReceiver.ParseReqHoga( szData );
  end
  else if TrCode = Qry_SymbolInfo2 then
    gReceiver.parseSymbolInfo2( szData )
  else Exit;
end;

// 실시간 수신 핸들러 - 데이터를 받으면 쓰레드가 처리한다. 
procedure TApiManager.OnWRAXRecvRealData(ASender: TObject; const TrCode,
  KeyValue: WideString; nRealID: Smallint; nDataSize: Integer;
  const szData: WideString);
  var
    iType : integer;
begin

  iType := -1;
  if TrCode = Real_Order then
    iType := integer( atOrder )
  else if TrCode = Real_FutHoga then
    iType := integer( atFutHoga )
  else if TrCode = Real_FutExec then
    iType := integer( atFutExec )
  else if TrCode = Real_Stock_FutHoga then
    iType := integer( atStockFutHoga)
  else if TrCode = Real_Stock_FutExec then
    iType := integer(atStockFutExec)
  else if TrCode = Real_OptHoga then
    iType := integer( atOptHoga )
  else if TrCode = Real_OptExec then
    iType := integer( atOptExec )
  else if TrCode = Real_FutInvest then
    iType := integer( atFutInvest )
  else if TrCode = Real_OptInvest then
    iType := integer( atOptInvest )
  else
    gEnv.EnvLog( WIN_GI, string(szData) );

 {
  case TApiRealType(iType) of
    atFutHoga : FRecevier.ParseFutHoga( szData );
    atFutExec : FRecevier.ParseFutPrice( szData );
    atOptHoga : FRecevier.ParseOptHoga( szData );
    atOptExec : FRecevier.ParseOptPrice( szData );
    atOrder :   FRecevier.ParseOrder( szData );
    atFutInvest : FRecevier.ParseInvestFutData( szData );
    atOptInvest : FRecevier.ParseInvestOptData( szData );
  end;

  Exit;
   }
  if iType >= 0 then
    FApiThread.PushData( nDataSize, iType, PChar(string(szData))) ;


end;

procedure TApiManager.OnWRAXReplyFileDown(ASender: TObject; nResult: Smallint;
  const Message: WideString);
begin
  if nResult = 1 then begin
    gLog.Add( lkApplication, 'TApiManager', 'WRAXReplyLogin', '마스터 요청 성공' ) ;
    DoRequestMaster;
  end
  else begin
    gLog.Add( lkApplication, 'TApiManager', 'WRAXReplyLogin', '마스터 요청 실패 : ' + Message );
    gEnv.ErrString  := '마스터 요청 실패 : ' + Message;
    gEnv.SetAppStatus( asError );
  end
end;

// 로그인 결과 핸들러.
// 로그인 성공하면 계좌를 요청하고 심볼 마스터를 요청한다. 
procedure TApiManager.OnWRAXReplyLogin(ASender: TObject; nResult: Smallint;
  const Message: WideString);
begin
  if nResult = 1 then begin
    gLog.Add( lkApplication, 'TWooApiIF', 'WRAXReplyLogin', '로그인 성공' ) ;
    gEnv.SetAppStatus( asConMaster );
    DoRequestAccout;
    DoRequestMaster;
  end
  else begin
    gLog.Add( lkApplication, 'TWooApiIF', 'WRAXReplyLogin', '로그인 실패 : ' + Message );
    gEnv.ErrString  := '로그인 실패 : ' + Message ;
    gEnv.SetAppStatus( asError );
  end;
end;

procedure TApiManager.PushRequest(stTrCode, stData: string);
var
  aItem : TSrvSendItem;
begin
  aItem := TSrvSendItem.Create( nil );
  aItem.TrCode  := stTrCode;
  aItem.Data    := stData;
  aItem.Index   := QryIndex(stTrCode);
  aItem.Size    := length( stData );
  FQryList.Insert(0, aItem );
  //FQryList.Add( aItem );

end;

{
TViRequestItem = class (TCollectionItem)
  public
    TrCode : string; // trade code
    Data : string;   // data
    TryCnt : integer;  // Try count
    Complete : Boolean; // Complete or not
    ReqId : integer;  // request id
    nResult : integer; // result code
    constructor Create( aColl : TCollection ) ; overload;
  end;}
procedure TApiManager.PushViRequest(stTrCode, stData: string);
var
  aItem : TViRequestItem;
begin
  aItem := TViRequestItem.Create( nil );
  aItem.TrCode  := stTrCode;
  aItem.Data    := stData;
  aItem.TryCnt  := 0;
  aItem.Complete := false;
  aItem.ReqId := -1;
  aItem.nResult := 0;

  if FViReqList.Count > 0 then
    FViReqList.AddObject(IntToStr(FViReqList.Count - 1), aItem )
  else
    FViReqList.AddObject(IntToStr(0), aItem );
  //FQryList.Add( aItem );

end;


function TApiManager.RequestData(iTrCode: integer; stReqData: string; iSize : integer): integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
 //   Result := FApi.ESExpSendTrData( iTrCode, stReqData, iSize);
    if Result = 0  then
      gEnv.EnvLog( WIN_PACKET, Format('%d 요청 성공 : %s', [ iTrCode, stReqData]) )
    else
      gEnv.EnvLog( WIN_PACKET, Format('%d 요청 실패 : %d %s:%s', [ iTrCode, Result, stReqData , GetErrorMessage( Result ) ]) );
  except
    Result := -1;
    gEnv.EnvLog( WIN_PACKET, Format('%d 요청 에러 : %s', [ iTrCode,stReqData]) );
  end;
end;

// function  RequestViData(stTrCode: string; stReqData: string; iSize : integer; stNext : string ) : integer
function  TApiManager.DoRequestViData(stKey, stTrCode: string; stReqData, stFidData: string; rtType : TApiReqType; iSize : integer; stNext : string ) : integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
    if rtType = rtTr then
      Result := FApi.CommRqData( stTrCode, stReqData, Length(stReqData), stNext)
    else
      Result := FApi.CommFIDRqData( stTrCode, stReqData, stFidData, iSize, stNext);

    if Result > 0  then begin
      //gEnv.EnvLog( WIN_PACKET, Format('%s 요청 성공 : %s', [ aItem.TrCode, aItem.Data]) );
      gLog.Add( lkApplication, 'TApiManager','DoRequestViData', Format('요청 성공 : nRqId = %d , TrCode = %s, Data = %s',[ Result, stTrCode, stReqData ] )  );
      FViReqList.Values[IntToStr(Result)] := stTrCode + ':' + stReqData;
    end
    else
      //gEnv.EnvLog( WIN_PACKET, Format('%s 요청 실패 : %d %s:%s', [ aItem.TrCode, Result, aItem.Data , GetViErrorMessage( Result ) ]) );
      gLog.Add( lkApplication, 'TApiManager','DoRequestViData', Format('요청 실패: nRqId = %d , TrCode = %s, Data = %s',[ Result, stTrCode, stReqData ] )  );
  except
    Result := -1;
    //gEnv.EnvLog( WIN_PACKET, Format('%s 요청 에러 : %s', [ aItem.TrCode,aItem.Data]) );
    gLog.Add( lkApplication, 'TApiManager','DoRequestViData', Format('요청 오류: nRqId = %d , TrCode = %s, Data = %s',[ Result, stTrCode, stReqData ] )  );
  end;
end;

function TApiManager.RequestViData2(var aItem : TSrvSendItem): integer;
var
  stReqId : string;
begin
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
    if aItem.ReqType = rtTr then
      Result := FApi.CommRqData( aItem.TrCode, aItem.Data, Length(aItem.Data), '')
    else
      Result := FApi.CommFIDRqData( aItem.TrCode, aItem.Data, aItem.FidData, aItem.Size, '');

    if Result > 0  then begin
      //gEnv.EnvLog( WIN_PACKET, Format('%s 요청 성공 : %s', [ aItem.TrCode, aItem.Data]) );
      gLog.Add( lkApplication, 'TApiManager','RequestViData2', Format('요청 성공 : nRqId = %d , TrCode = %s, Data = %s',[ Result, aItem.TrCode, aItem.Data ] )  );
      aItem.reqId := Result;
      FViReqIdList.AddObject(IntToStr(Result), aItem);
    end
    else
      //gEnv.EnvLog( WIN_PACKET, Format('%s 요청 실패 : %d %s:%s', [ aItem.TrCode, Result, aItem.Data , GetViErrorMessage( Result ) ]) );
      gLog.Add( lkApplication, 'TApiManager','RequestViData2', Format('요청 실패: nRqId = %d , TrCode = %s, Data = %s',[ Result, aItem.TrCode, aItem.Data ] )  );
  except
    Result := -1;
    //gEnv.EnvLog( WIN_PACKET, Format('%s 요청 에러 : %s', [ aItem.TrCode,aItem.Data]) );
    gLog.Add( lkApplication, 'TApiManager','RequestViData2', Format('요청 오류: nRqId = %d , TrCode = %s, Data = %s',[ Result, aItem.TrCode, aItem.Data ] )  );
  end;
end;

function TApiManager.ReqRealTimeQuote(stTrCode, stData : string; bOn : boolean): integer;
begin
  Result := -1;
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  if bOn then
    Result := Subscribe( stTrCode, stData )
  else
    Result := UnSubscribe( stTrCode, stData );
end;


procedure TApiManager.RequestMaster(stUnder, stCode, stIndex: string );
var
  Buffer  : array of char;
 // aData   : PReqSymbolMaster;

  stData  : string;

begin
{
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-3s', [ stUnder ]),  aData.AssetsID );
  MovePacket( Format('%-12.12s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4s',   [ stIndex]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );
  PushRequest( ESID_2007, stData,  Sizeof( TReqSymbolMaster ));
   }
end;



function TApiManager.QryIndex(stTr: string): integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Qry_Cnt - 1 do
    if Vi_Qry_TrCode[i] = stTr then
    begin
      Result := i;
      Break;
    end;
end;

// 요청 목록이 남아 있으면 계속해서 요청을 한다. 
procedure TApiManager.TimeViReq( Sender: TObject );
var
  aItem : TSrvSendItem;
  I,  iRes : Integer;
  stTmp, sData, sFid : string;
begin
  // 목록이 비어 있으면 빠져 나간다.
  if FViReqList.Count <= 0 then  begin
    Exit;
  end;

  // 크리티컬 섹션 진입
  EnterCriticalSection(CritSect);

  try begin
    try begin
      iRes := -1;
      i := FViReqList.Count - 1;
      aItem := FViReqList.Objects[i] as TSrvSendItem;

      if not aItem.Requestd then begin
        iRes := RequestViData2(aItem);
        ViReqTimer.Enabled := false;
      end;
      if iRes > 0 then begin
        inc(FQryCount[aItem.Index]);
        aItem.Requestd := true;
      end;
    end;
    except
      gEnv.EnvLog( WIN_ERR, Format('조회 에러 : [%d,%d] ', [i, FViReqList.Count]))
    end;
  end;
  finally
    LeaveCriticalSection(CritSect)
  end;
end;

// 타이머 처리 함수
// 중간에 Exit을 호출해도 finally 는 항상 호출 된다. 
procedure TApiManager.TimeProc(Sender: TObject);
var
  aItem : TSrvSendItem;
  I,  iRes, index, curIndex : Integer;
  stTmp : string;
begin

  if FQryList.Count <= 0 then  Exit;

  try
    try

    QryTimer.Enabled := false;

    // 크리티컬 섹션 진입
    EnterCriticalSection(CritSect);

    //curIndex := FQryList.Count - 1;

    for I := FQryList.Count - 1 downto 0 do
    begin

      // 질의 함목 복사해서 가져옴
      aItem := TSrvSendItem(  FQryList.Items[i] );
      if aItem = nil then Exit;

     // gEnv.EnvLog( WIN_ERR, Format('start = %d [%d,%d](%d) (%s, %s) ',[ 999,
      //   i, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] )  );

      if aItem.Index < 0 then
      begin
        gLog.Add( lkError, 'TApiManager','TimeProc', Format('Index Error : %d (%s, %s)',[ aItem.Index, aItem.TrCode, aItem.Data ] )  );
        FQryList.Delete(curIndex);
        aItem.Free;
        Exit;
      end;

      {
      // 특정 질의 회수가 3번이상일 때 처리
      if FQryCount[aItem.Index] >= 3 then
      begin
        iRes := SecondsBetween( now, FlastTime );
        // MilliSecondsBetween( now, FlastTime );
        // 마지막 조회 시간과 현재 시간의 차이가 응답 요구시간보다 작을 때는 함수 종료
        if iRes < ExSec then begin
          gEnv.EnvLog(WIN_Err, Format('Exit      [%d,%d](%d) (%s, %s)',[
            i, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] ) );
          Exit  ;
        end
        else
          gEnv.EnvLog( WIN_TEST, format('시간 초과로 다시 조회 %s -> %s [%d, %d]' , [
            FormatDateTime('hh:nn:ss.zzz', FLastTime), FormatDateTime('hh:nn:ss.zzz', now),
            FQryCount[aItem.Index],  FQryList.Count
             ]) );
      end;
      }

      if (aItem.TrCode = '') or (aItem.Data = '') then Exit;

      index := aItem.Index;

      //stTmp := Format('[%d,%d](%d) (%s, %s)',[
      //   i, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] ) ;

      // 요청 수행
      iRes := DoRequestViData(aItem.Key, aItem.TrCode, aItem.Data, aItem.FidData, aItem.ReqType, aItem.Size,  '');

      gEnv.EnvLog( WIN_ERR, Format('Result = %d [%d,%d](%d) (%s, %s)',[ iRes,
         curIndex, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] )  );

      // 성공한 경우 
      if iRes > 0 then begin


        FLastTime := now;
        // 질의 종류에 따른 질의 회수를 증가 시킨다.
        // 특정 질의를 몇 번 수행 했는가를 기록한다.
        inc(FQryCount[aItem.Index]);
        //FQryList.Delete(i);
        aItem.Free;
        aItem := nil;
      end;
    end;

    except
      if aItem <> nil then
      gEnv.EnvLog( WIN_ERR, Format('일괄 조회 에러 : %d [%d,%d](%d) (%s, %s)', [
        iRes, curIndex, FQryList.Count, FQryCount[aItem.Index], aITem.TrCode, aItem.Data])
        )
      else
         gEnv.EnvLog( WIN_ERR, Format('일괄 조회 에러 : [%d,%d] ', [
        curIndex, FQryList.Count])
        )
    end;
  finally
    LeaveCriticalSection(CritSect);
    if not QryTimer.Enabled then
      QryTimer.Enabled := true;
    //gEnv.EnvLog( WIN_ERR, 'finally');
  end;

end;


procedure TApiManager.TimeProc2(Sender: TObject);
var
  aItem : TSrvSendItem;
  I, iCnt, idx : Integer;
begin

  if FAutoQuoteList.Count <= 0 then  Exit;

  try
    iCnt := 0;
    for I := FAutoQuoteList.Count - 1 downto 0 do
    begin

      aItem := TSrvSendItem(  FAutoQuoteList.Items[i] );
      if aItem = nil then Continue;

      if iCnt >= MAX_CNT2 then
        break;

      //ReqRealTimeQuote( true, aItem.Data );

      FAutoQuoteList.Delete(i);
      aItem.Free;
      inc( iCnt );
    end;

  except
  end;

end;


function TApiManager.Subscribe(stTrCode, stData: string): integer;
var
  stErr: string;
  aItem :TRequestItem;

begin

  //Result  := FApi.ORegistRealData( stTrCode, stData );

  if Result < 0 then begin
    case Result of
      -1 : stErr := '존재하지 않는 실시간';
      -2 : stErr := '실시간 키 값이 이상';
      -3 : stErr := '이미 등록되어 있는 실시간';
      -4: stErr := '서버에 등록시에 문제 발생';
      else stErr := '기타 에러';
    end;
    gLog.Add( lkError, '','', Format('ORegistRealData Error : %d(%s), %s, %s', [ Result, stErr, stTrCode, stData ])  )
  end
  else begin
    aItem := TRequestItem.Create( nil );
    aItem.TrCode  := stTrCode;
    aItem.Data    := stData;
    aItem.Tag     := Result;
    FSubList.Add( aItem );

    gEnv.EnvLog( WIN_TEST, Format('  Sub  : %s, %s, %d(%d)', [ stTrCode, stData, Result, FSubList.Count ])  );
  end;

end;

function TApiManager.UnSubscribe(stTrCode, stData: string): integer;
var
  I: Integer;
  aItem : TRequestItem;
begin

  for I := 0 to FSubList.Count - 1 do
  begin
    aItem := TRequestItem( FSubList.Items[i] );
    if ( aItem.TrCode = stTrCode ) and ( aItem.Data = stData )  then
    begin

      //if FApi.OUnregistRealData( aItem.Tag) then
        //gEnv.EnvLog(WIN_TEST, Format('UnSub : %s, %s, %d', [stTrCode, stData, aItem.Tag ]) )
      //else
      //  gLog.Add( lkError, '','', Format('UnSub Error : %s, %s, %d', [ stTrCode, stData, aItem.Tag ]) );

      FSubList.Delete(i);
      aItem.Free;
      break;
    end;
  end;

end;

procedure TApiManager.MakeSymbolCodeReqList();
var 
  i : integer;
  aItem : TSrvSendItem;
  sCode : string;
begin
  for I := 0 to Vi_Market_Cnt - 1 do begin
    aItem := TSrvSendItem.Create( nil );
    aItem.TrCode  := DefSymbolCode;
    aItem.Data    := Vi_MarketSymbol[i];
    aItem.ReqType := rtTr;
    aItem.Index   := QryIndex(DefSymbolCode);
    aItem.Size    := length( aItem.Data );
    aItem.Key     := Vi_MarketSymbol[i];
    FQryList.Insert(0, aItem );
    //FViReqList.AddObject(aItem.Key, aItem);
  end;

  for i := 0 to FQryList.Count - 1 do begin
    aItem := FQryList[i];
  end;

end;

procedure TApiManager.MakeSymbolMasterReqList();
var
  i : integer;
  aItem : TSrvSendItem;
  sCode : string;
  sFid  : string;
begin
  // if Symbol Code list is empty, Stop the execution.
  if FViSymbolCodeList.Count = 0 then begin
    gEnv.SetAppStatus( asError );
    Exit;
  end;
  for I := 0 to FViSymbolCodeList.Count - 1 do begin
    aItem := TSrvSendItem.Create( nil );
    aItem.TrCode  := DefSymbolMaster;

    aItem.Data    := FViSymbolCodeList.Strings[i] + '40100';
    sFid := '000001002003004005006007008009010011012013014015016017018019' +
            '020021022023024025026027028029030031032033034035036037038039' +
            '040041042043044045046047048049050051052053054055056057058059' +
            '060061062063064065066067068069070071072073074075076077078079' +
            '080081082083084085086087088089090091092093094095096097098099' +
            '100101102103104105106107108109110111112113114115116117118119' +
            '120121122123124125126127128129130131132133134135136137138139' +
            '140141142143144145146147148149150151152153154155156157158159' +
            '160161162163164165166167168169170171172173174175176177178179' +
            '180181182183184185186187188189190191192193194195196197198199' +
            '200201202203';

    aItem.FidData := sFid;
    aItem.Index  := QryIndex(DefSymbolMaster);
    aItem.ReqType  := rtFid;
    aItem.Size    := length( aItem.Data );
    aItem.Key := FViSymbolCodeList.Strings[i];
    //FQryList.Insert(0, aItem );
    FViReqList.AddObject(aItem.Key, aItem);
  end;


end;

procedure TApiManager.AddSymbolMasterRequest(const stSymbolCode : string);
var
  i : integer;
  aItem : TSrvSendItem;
  sCode : string;
  sFid  : string;
begin

  // if Symbol Code list is empty, Stop the execution.
  if Length(stSymbolCode) < 8 then begin
    Exit;
  end;

  {
  aItem := TSrvSendItem.Create( nil );
  aItem.TrCode  := DefSymbolMaster;
  aItem.Data    := stSymbolCode + '40001';
  sFid := '000001002003004005006007008009010011012013014015016017018019' +
            '020021022023024025026027028029030031032033034035036037038039' +
            '040041042043044045046047048049050051052053054055056057058059' +
            '060061062063064065066067068069070071072073074075076077078079' +
            '080081082083084085086087088089090091092093094095096097098099' +
            '100101102103104105106107108109110111112113114115116117118119' +
            '120121122123124125126127128129130131132133134135136137138139' +
            '140141142143144145146147148149150151152153154155156157158159' +
            '160161162163164165166167168169170171172173174175176177178179' +
            '180181182183184185186187188189190191192193194195196197198199' +
            '200201202203204205206207208209210211212213214215216217218219' +
            '220221222223224225226227228229230231232';
  aItem.FidData := sFid;
  aItem.Index  := QryIndex(DefSymbolMaster);
  aItem.ReqType  := rtFid;
  aItem.Size    := length( aItem.Data );
  //FQryList.Insert(0, aItem );
  //FViReqList.AddObject(IntToStr(FViReqList.Count - 1), aItem);
  }
  FViSymbolCodeList.Add(stSymbolCode);
end;

{ TSrvSendItem }

constructor TSrvSendItem.Create(aColl: TCollection);
begin
  TrCode := '';
  Data   := '';
  Index  := - 1;
  Key    := '';
end;

{ TRequestItem }

constructor TRequestItem.Create(aColl: TCollection);
begin
  TrCode := '';
  Data   := '';
  Index  := - 1;
  Tag    := 0;
end;

{ TViRequestItem }
{
TrCode : string; // trade code
    Data : string;   // data
    Next : string;
    TryCnt : integer;  // Try count
    Complete : Boolean; // Complete or not
    ReqId : integer;  // request id
    nResult : integer; // result code
    }
constructor TViRequestItem.Create(aColl: TCollection);
begin
  TrCode := '';
  Data   := '';
  Next   := '';
  TryCnt  := - 1;
  Complete := false;
  nResult := 0;
  ReqId  := -1;
  FidData := '';
end;


end.




