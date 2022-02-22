// Api ������
unit CleApiManager;

interface

// ���� ���ֵ� 
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

// ��� ����
const
  MAX_CNT = 35;
  MAX_CNT2 = 2;
  ExSec    = 5;

  ACCOUNT_QRY = 1;
  SYMBOL_QRY  = 0;
  AUOTE_QUOTE = 2;
// ������ Ÿ�� ���� 
type

  // �ε� Ÿ�� ����
  TLoadStatsType = ( lstNone, lstSymbol, lstAccount, lstEnd );


  // ���� ���� ������ 
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

  // ���� ��û ������ 
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

  // Api ������ Ŭ����
  TApiManager = class
  private
    // ActiveX ��ü
    FApi: THDFCommAgent; // TWRAX;
    // �غ� �Ǿ��°�?
    FReady: boolean;
    // �̺�Ʈ
    FOnData: TTextNotifyEvent;

    MyList : TMyCollection;

    // ���� ���
    FQryList : TList;
    // ���� ���
    FSubList : TList;
    // ��û ��� 
    FReqList : TList;

    // Vi ��û ���
    FViReqList : TStringList;
    // Vi Req Id List - ���ǻ� ��û ���带 ��� �ִ�. 
    FViReqIdList : TStringList;

    FViSymbolCodeList : TStringList;

    // �ڵ� �ü� ��� 
    FAutoQuoteList : TList;
    // ���� Ÿ�̸�
    FQryTimer: TTimer;
    // �ڵ� Ÿ�̸� 
    FAutoTimer: TTimer;

    // Vi ���� Ÿ�̸�
    FViReqTimer: TTimer;




    // ���� ī��Ʈ �迭
    FQryCount : array [0..QRY_CNT-1] of integer;

    // �ε� ���� 
    FLoadStats: TLoadStatsType;
    // �۽� ���� ����
    FSendQryCount: integer;
    // ���� ��ü - ���� ������ �����Ѵ�.  
    FRecevier: TApiReceiver;
    // ���� ���� ī��Ʈ 
    FAccountQryCount: integer;
    // ���� ������
    FOwnIP: string;
    // ���� 
    FCount: integer;
    // ������ �ð� 
    FLastTime : TDateTime;
    // �۽� ������ 
    FApiThread: TApiRecvThread;

    // ��û ������ ���� �Լ� 
    procedure OnWRAXRecvData(ASender: TObject; DataType: Smallint; const TrCode: WideString;
                                              nRqID: Smallint; nDataSize: Integer;
                                              var szData: WideString);
    // �ǽð� ������ ���� �Լ�
    procedure OnWRAXRecvRealData(ASender: TObject; const TrCode: WideString;
                                                  const KeyValue: WideString; nRealID: Smallint;
                                                  nDataSize: Integer; const szData: WideString);
    // �α��� ����
    procedure OnWRAXReplyLogin(ASender: TObject; nResult: Smallint; const Message: WideString);
    // ���� �ٿ� ����
    procedure OnWRAXReplyFileDown(ASender: TObject; nResult: Smallint; const Message: WideString);

    // ���� ���� ����
    procedure OnWRAXConnected(Sender: TObject);
    // ���� ���� ���� 
    procedure OnWRAXDissConnected(Sender: TObject);

    // ��� ������ ���� �Լ� 
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

    // ������ �ε� �Լ�
    procedure LoadMaster(stFileName: string);
    procedure LoadMasterFromSymbolCode(stSymbolCode: string);

    // ���� �ε��� �Լ�. ���ǿ� ���� �ε����� �����ش�. 
    function QryIndex(stTr: string): integer;
    // ��û�� �߰� �Ѵ�. 
    procedure AddRequest(stTr, stData: string; iReq: integer);
    // Api ������ �̺�Ʈ 
    procedure OnApiThreadEvent( aPacket : POrderPacket );

    


  public

    // ũ��Ƽ�� ���� - ������ ����ȭ�� �ʿ� 
    CritSect: TRTLCriticalSection;

     // �ɺ� ��û �Լ�
    procedure DoRequestSymbolInfo;
    // ������
    Constructor Create( aObj : TObject ); overload;
    // �Ҹ��� 
    Destructor  Destroy; override;

    // ���� ��û �Լ�
    procedure DoConnect( iMode : integer );
    // �α��� �Լ�
    procedure DoLogIn; overload;
    // �α��� �Լ�
    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : integer;  overload;
    // ���� Ȯ�� �Լ� 
    procedure Fin;

    // ���� �ڵ� ã�� �Լ�
    function FindAccountCode( iReq : integer ): string;
    // ��û ���� �Լ�
    function DoRequest( stTr, stData : string) : integer;
    // �ֹ� ���� �Լ� 
    function DoSendOrder( aOrder : TOrder ) : string;

    // ������ ��û �Լ�
    procedure DoRequestMaster;
    // ���� ��û �Լ�
    procedure DoRequestAccout;

    // ���� �޽��� ������ �Լ�
    function GetErrorMessage( iRes : integer ) : string;
    function GetViErrorMessage( iRes : integer ) : string;
    // ���� ��¥ ��� ���� �Լ�
    function GetCurrentDate : string; overload;
    // ���� �� ¥ ��� ���� �Լ�
    function GetCurrentDate( bDate : boolean ) : TDateTime; overload;

    // ������ ��û �Լ�
    procedure RequestMaster( stUnder, stCode, stIndex : string );
    // ��û �ִ� �Լ�
    procedure PushRequest( stTrCode ,stData : string );

    procedure PushViRequest(stTrCode, stData: string );

    function RequestViData2(var aItem : TSrvSendItem): integer;

    // Vi �ɺ� �ڵ� �� û 
    procedure DoRequestSymbolCode(stMarketCode: string);

    // ������ ��û �Լ�
    function  RequestData(iTrCode: integer; stReqData: string; iSize : integer ) : integer;

    // Vi ������ ��û �Լ�
    function  DoRequestViData(stKey, stTrCode: string; stReqData, stFidData: string; rtType : TApiReqType; iSize : integer; stNext : string ) : integer;

    // ��� �Լ�
    function Subscribe( stTrCode, stData : string ) : integer;
    // ��� ���� �Լ�
    function UnSubscribe( stTrCode, stData : string ) : integer;

    // �ǽð� �ü� ��û �Լ�
    function  ReqRealTimeQuote( stTrCode, stData : string; bOn : boolean = true ) : integer;

    // Ÿ���� �̺�Ʈ �Լ�
    procedure TimeProc( Sender : TObject );
    // Ÿ�̸� �̺�Ʈ �Լ� 
    procedure TimeProc2( Sender : TObject );

    // ViReqTimer �̺�Ʈ �Լ�
    procedure TimeViReq( Sender: TObject );

    procedure MakeSymbolCodeReqList();

    procedure MakeSymbolMasterReqList();

    procedure AddSymbolMasterRequest(const stSymbolCode : string);

    // ActiveX ��ü 
    property Api: THDFCommAgent read FApi;
    // ������
    property Recevier : TApiReceiver read FRecevier;
    // ������ 
    property ApiThread: TApiRecvThread read FApiThread;

    // �غ� ����
    property Ready : boolean read FReady ;//write FReady;
    // ���i ���� ó�� �Լ�
    property OnData: TTextNotifyEvent read FOnData write FOnData;
    // ���� Ÿ�̸� �Ӽ�
    property QryTimer : TTimer read FQryTimer write FQryTimer;
    // �ڵ� Ÿ�̸� �Ӽ�
    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;


    property ViReqTimer: TTimer read FViReqTimer write FViReqTimer;

    // �ε� ���� �Ӽ�
    property LoadStats : TLoadStatsType read FLoadStats write FLoadStats;
    // ���� ������
    property OwnIP  : string read FOwnIP write FOwnIP;
    property Count  : integer read FCount ;   // ���� ī��Ʈ
    property QryList: TList read FQryList;    // �ʹ� ��ü ���� ���簡 ��ȸ�ÿ��� ���Ǵ� ����Ʈ
    property ViReqList : TStringList read FViReqList;

    // counting
    // ���� ���� ī��Ʈ
    property SendQryCount : integer read FSendQryCount;
    // ���� ���� ���� ī��Ʈ 
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

// ������
constructor TApiManager.Create(aObj: TObject);
var
  I: Integer;
begin
  // �غ� ���� �ʱ�ȭ
  FReady  := false;
  // ����
  FCount  := 0;
  // Activex �Ҵ�
  FApi := aObj as  THDFCommAgent;

  MyList := TMyCollection.Create;


  // �̺�Ʈ �ڵ鷯 ��Ī
  // ���� ����
  //FApi.OnNetConnected := OnWRAXConnected;
  FApi.OnGetData := OnHDFCommAgentOnGetData;
  // ���� ���� ����
  //FApi.OnNetDisconnected := OnWRAXDissConnected;
  FApi.OnRealData := OnHDFCommAgentOnRealData;
  // ������ ���� ����
  //FApi.OnRecvData := OnWRAXRecvData;
  FApi.OnDataRecv := OnHDFCommAgentOnDataRecv;
  // �ǽð� ������ ���� ����
  //FApi.OnRecvRealData := OnWRAXRecvRealData;
  FApi.OnGetBroadData := OnHDFCommAgentOnGetBroadData;
  // �α��� ����
  //FApi.OnReplyLogin := OnWRAXReplyLogin;
  FApi.OnGetMsg := OnHDFCommAgentOnGetMsg;
  // ���� �ٿ� �ε� ���� 
  //FApi.OnReplyFileDown := OnWRAXReplyFileDown;
  FApi.OnGetMsgWithRqId := OnHDFCommAgentOnGetMsgWithRqId;

  // ������ ��ü ����
  FRecevier:= TApiReceiver.Create;

  // ������ ����
  FApiThread:= TApiRecvThread.Create;
  // ������ �̺�Ʈ �ڵ鷯 ���� 
  FApiThread.OnApiRecvEvent := OnApiThreadEvent;


  // ���� ����Ʈ ����
  FQryList := TList.Create;
  // ���� ����Ʈ ����
  FSubList := TList.Create;
  // ��û ����Ʈ ����
  FReqList := TList.Create;
  // �ڵ� �ü� ����Ʈ ����
  FAutoQuoteList := TList.Create;

  FViReqList := TStringList.Create;

  FViReqIdList := TStringList.Create;

  FViSymbolCodeList := TStringList.Create;

  // ���� Ÿ�̸� ����
  QryTimer  := TTimer.Create( OrpMainForm );
  QryTimer.Interval := 15;
  QryTimer.Enabled  := false;
  QryTimer.OnTimer  := TimeProc;

  FViReqTimer := TTimer.Create(OrpMainForm);
  FViReqTimer.Interval := 700;
  FViReqTimer.Enabled := false;
  FViReqTimer.OnTimer := TimeViReq;

  // �ڵ� Ÿ�̸� ����
  FAutoTimer  := TTimer.Create( OrpMainForm );
  FAutoTimer.Interval := 200;
  FAutoTimer.Enabled  := false;
  FAutoTimer.OnTimer  := TimeProc2;

  // ���� ī��Ʈ �ʱ�ȭ
  for I := 0 to Qry_Cnt - 1 do
    FQryCount[i]  := 0;

  // �۽��� ���� ī��Ʈ
  FSendQryCount := 0;
  // ���� ���� ī��Ʈ
  FAccountQryCount  := 0;

  // ũ��Ƽ�� ���� ���� 
  InitializeCriticalSection(CritSect);

end;

// �ı���
destructor TApiManager.Destroy;
begin

  // ũ��Ƽ�� ���� �ı���
  DeleteCriticalSection(CritSect);

  MyList.Free;
  //Fin;
  // ������ ����
  FApiThread.Terminate;
  // ������ �̺�Ʈ �Լ� ��
  FApithread.OnApiRecvEvent := nil;
  // ������ ����
  FApiThread.Free;

  FViReqIdList.Free;

  FViReqList.Free;

  FViSymbolCodeList.Free;
  
  // ��û ��� ����
  FReqList.Free;
  // ���� ��� ����
  FQryList.Free;
  // ���� ��� ����
  FSubList.Free;
  // �ڵ� �ü� ��� ����
  FAutoQuoteList.Free;
  // ������ ��ü ����
  FRecevier.Free;
  // �θ� �ı��� ȣ��
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

  // ������ �α�
  gLog.Add( lkApplication, 'TApiManager', 'OnAccountList',
    Format('���� : %d, %s', [ iCnt, stTmp ])) ;

end;

procedure TApiManager.OnSymbolCode(const sTrCode: WideString; const nRqId: Integer);
var
  iCnt, i : Integer;
  stData : string;
  stSymbolCode : string;
begin
  gLog.Add( lkApplication, 'TApiManager', 'OnSymbolCode',
    Format('���� : %d, Code : %s', [ nRqId, sTrCode ])) ;

  iCnt := FApi.CommGetRepeatCnt(sTrCode, -1, 'OutRec1');
  for i := 0 to iCnt - 1 do begin
    stData := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ڵ�');
   
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
  aItem : TSrvSendItem;
  reqIndex, idIndex : integer;
  Key : string;
begin

  if nRqId <= 0 then begin
    Result := -1;
    Exit;
  end;

  // ũ��Ƽ�� ���� ����
  EnterCriticalSection(CritSect);

  gLog.Add( lkApplication, 'TApiManager', 'CheckRqResult ', Format(' ViReqList Count = %d, Code : %s', [ ViReqList.Count, sCode ])) ;

  try begin
    idIndex := FViReqIdList.IndexOf(IntToStr(nRqId));
    if idIndex >= 0 then begin
      aItem := FViReqIdList.Objects[idIndex] as TSrvSendItem;
      reqIndex := FViReqList.IndexOf(aItem.Key);
      if reqIndex >= 0 then begin
        ViReqList.Delete(reqIndex);
      end;
      FViReqIdList.Delete(idIndex);
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

  if (nRqId > 0) and (ViReqList.Count > 0) then
    FViReqTimer.Enabled := true;

  
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
    Format('���� : %d, Code : %s', [ nRqId, sTrCode ])) ;
  iCnt := FApi.CommGetRepeatCnt(sTrCode, -1, 'OutRec1');
  for i := 0 to iCnt - 1 do begin
    stSymbolCode := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ڵ�');
    stSymbolCode := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ڵ�');
    stEnName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���������');
    stKrName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�ѱ������');
    stShortKrName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ѱ۾��');
    stShortName := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '��������');
    stPrev := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���ϴ��');
    stUpdown := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����');
    stRemainDays := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ϼ�');
    stLastDay := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ŷ���');
    stBasePrice := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���ذ���');
    stHighLimit := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���Ѱ�');
    stLowLimit := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���Ѱ�');
    stPreClose := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '��������');
    stTradeUnit := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�ŷ�����');
    stTradeTime := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, 'ü��ð�');
    stClose := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���簡');
    stOpen := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�ð�');
    stHigh := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '����');
    stLow := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '����');
    stAccAmount := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�����ŷ���');
    stKospi200 := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	KOSPI200����');
    stExpYrMn := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '������');
    stStrike := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '��簡��');
    stSeq := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '��ȸ����');

    stRecentMn := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '�ֱٿ�������');
    stAtm := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	ATM����');
    stPreOpen := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	���Ͻð�');
    stPreHigh := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���ϰ���');
    stPreLow := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '��������');
    stPriceUnitBase := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '���ݴ������ذ�(3.00)');
    stHogaUnit1 := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, 'ȣ������(0.01)');
    stHogaUnit2 := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, 'ȣ������(0.05)');
    stKospiAtm := FApi.CommGetData(sTrCode, -1, 'OutRec1', i, '	KOSPI�');



  end;



end;


// ���� ���� �Լ�
procedure TApiManager.DoConnect( iMode : integer );
var
  // ip, port ���ڿ� 
  wsIP , wsPort : WideString;
  nRet : Integer;
begin

  // �����ڵ带 ���� �ش�.
  wsIP    := WideFormat( '%s', [
    ifThenStr( iMode = 0,  gEnv.ConConfig.TradeAddr, gEnv.ConConfig.TradeAddr2 ) ] );
  wsPort  := WideFormat( '%d', [ gEnv.ConConfig.Port ] );

  // �α� ��� - �α� Ÿ�� - ���� ���α׷�
  gLog.Add( lkApplication, 'TApiManager','DoConnect',  Format('���� �� : %s, %s', [  wsIP, wsPort  ])) ;

  //wsIP := '210.183.186.20';
  //wsPort := '8300';
  // ���� ó�� �Լ� ȣ��
  //FApi.OConnectHost( wsIP, wsPort );
  nRet := FApi.CommInit(1);

  if nRet < 0 then begin
    gLog.Add( lkApplication, 'TApiManager','DoConnect',  '������α׷� ���� ����') ;
  end else begin
    gLog.Add( lkApplication, 'TApiManager','DoConnect',  '������α׷� ����') ;
    FReady := true;
  end;

  DoLogin;

end;

// �α��� ���� - ������ ���� ���� ȣ���Ѵ�. 
function TApiManager.DoLogIn(stID, stPW, stCert: string; iMode: integer) : integer ;
var
  // ��� ��, ��
  iRes, iDiv : integer;
  //
  stDir: string;
  // ���� �Ǿ��°�?
  bConn: boolean;

begin

  Result := 0 ;

{ ��庰 �б�
  // 0  : ���� ����
  // 1  : ������ ������ �α��� �Ͻÿ�
}
  // �غ� ���� �ʾ�����
  if not FReady then
    bConn := True;
  //else begin  // �غ� �� ���
    // �α����� �Ǿ��°�
    //if FApi.OIsLogined then
    //begin
      // �α��� ���¶� ���� ��
      //gLog.Add( lkApplication, 'TWooApiIF', 'DoLogin', '�α��λ��¶� ������' );

      //iRes := MessageDlgLE( gEnv.Main, '���� �α������Դϴ�. ���� ������ ���� �����Ͻðڽ��ϱ�?',
         //mtWarning, [mbYes , mbNo] );

      // mrYes,  mrOk
      //if (iRes = 0 {mrYes}) or ( iRes = 1 {mrOK} ) then
      //begin
        // ȣ��Ʈ ����
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


  // ������ �ؾ� �ϸ� ������ ���� ��
  if bConn then
    DoConnect( iMode )
  else // ������ �ʿ� ������ �α��� ���� 
    DoLogIn;
end;

// �α��� ����
procedure TApiManager.DoLogIn;
var
  // ���̵�, ���, ������ 
  wstID, wstPW, wstCert: widestring;
  nResult : integer;
begin

  // �α� ���
  gLog.Add( lkApplication, 'TApiManager','DoLogIn',  Format('�α��νõ� : %s, %s, %s, %s', [
    gEnv.ConConfig.UserID, gEnv.ConConfig.Password,
    gEnv.ConConfig.CertPass , ifThenStr( gEnv.ConConfig.RealMode, '����','����')  ])) ;

  // ����, ���, ������ ������
  wstID :=  gEnv.ConConfig.UserID;
  wstPW := gEnv.ConConfig.Password;
  wstCert := gEnv.ConConfig.CertPass;

  // Api�� �α��� �Ѵ�.
  //FApi.OLogin( wstID, wstPW, wstCert);
  nResult := FApi.CommLogin(wstID, wstPW, wstCert);


  if nResult > 0 then begin
    gLog.Add( lkApplication, 'TWooApiIF', 'CommLogin', '�α��� ����' ) ;
    gEnv.SetAppStatus( asConMaster );
    //DoRequestAccout;
    //DoRequestMaster;
    // ���� ���� ��û
    FApi.CommAccInfo();
  end
  else begin
    gLog.Add( lkApplication, 'TWooApiIF', 'CommLogin', '�α��� ����'  );
    gEnv.ErrString  := '�α��� ���� ' ;
    gEnv.SetAppStatus( asError );
  end;

end;

// ��û�� �߰�
procedure TApiManager.AddRequest( stTr, stData : string; iReq : integer );
var
  aItem : TRequestItem;
begin
  // ��û ������ ����
  aItem := TRequestItem.Create( nil );
  aItem.TrCode  := stTr; // �ڵ�
  aItem.Data    := stData;  // ������
  aItem.Tag     := iReq;  // ��û ��ȣ
  FReqList.Add( aItem );
end;

function TApiManager.FindAccountCode( iReq : integer ) : string;
var
  aItem : TRequestItem;
  aIn   : ^TInputDeposit;
  I: Integer;
begin

  // ��û ����Ʈ�� ���鼭
  for I := FReqList.Count -1 downto 0 do
  begin
    // ��û ������ ����
    aItem := TRequestItem( FReqList.Items[i] );
    // ���� ���� ��û �̶�� 
    if ( aItem.TrCode = Qry_AcntState ) and ( aItem.Tag = iReq ) then
    begin
      // ��û ����Ʈ���� �ش� ��û�� �����.
      FReqList.Delete(i);
      // ��û �����͸� �����´�.
      aIn :=  @aItem.Data[1];
      Result  := trim( string( aIn.AccountNo ));
      aItem.Free;
      break;
    end;
  end;
end;

// ��û ���� 
function TApiManager.DoRequest(stTr, stData: string ) : integer;
var
  iSize : integer;
begin
  iSize   := Length( stData );
  if iSize <= 0 then
    Result := -100 ;
  //else
    // ��û �Լ� ȣ��
    //Result  := FApi.ORequestData( stTr, iSize, stData, true, false, ExSec );

  // ������ ��� 
  if Result <= 0 then
    gLog.Add( lkError, 'TApiManager','DoRequest', Format('Error : %d (%s, %s)',[ Result, stTr, stData ] )  )
  // ������ ��� 
  else if (Result > 0 ) and ( stTr = Qry_AcntState ) then  begin
    // ��Ź�� ��ȸ ��Ŷ�� ���¹�ȣ�� ���ٴ� �� �׷���...����
    gEnv.EnvLog( WIN_TEST, Format('DoRequest (%d)(%d) : %s', [ Result, FReqList.Count, stData]) );
    // ��û ��Ͽ� �߰� 
    AddRequest( stTr, stData, Result )
  end;
end;

// ���� ��û ���� 
procedure TApiManager.DoRequestAccout;
var
  iCnt : integer;
  I: Integer;
  wstAcntNo, wstAcntName  : WideString;
  stTmp : string;
begin
  gLog.Add( lkApplication, 'TApiManager', 'DoRequestAccout', '���� ��û' );
  // ���� ��û ����
  //iCnt := FApi.OGetAccountInfCount;
  stTmp:= '';
  for I := 0 to iCnt - 1 do
  begin
    // ���� ����
    //FApi.OGetAccountInf( i, wstAcntNo, wstAcntName );
    // ������ ����
    gEnv.Engine.TradeCore.Investors.New( wstAcntNo, wstAcntName, '' );
    stTmp := stTmp + ' ' + wstAcntNo ;
  end;

  // ������ �α�
  gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpAcctList',
    Format('���� : %d, %s', [ iCnt, stTmp ])) ;
end;

// ������ ��û
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

// �ɺ� ���� ��û
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
  // ����, �ɼ� �ֱٿ�����...��ȸ
  // ��ȸ ������ Ÿ�̸� On ��Ų��.
  gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', 'Request the Symbol Info' );
  // ���� ���� ��ȸ
  for I := 0 to gEnv.Engine.SymbolCore.FutureMarkets.Count - 1 do
  begin
    aFutMarket := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[i];
    // ���� ���庰 �ڵ� ��ȸ
    for j := 0 to aFutMarket.Symbols.Count - 1 do
    begin
      aSymbol := aFutMarket.Symbols.Symbols[j];
      //if aSymbol.IsStockF then break;
      if aSymbol <> nil  then
      begin
          // ��û ���� �ֱ�
         //PushRequest( Qry_LastPrice, aSymbol.Code );
         AddSymbolMasterRequest(aSymbol.Code);
         gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', aSymbol.Code );
      end;
      // �ֱٿ����� ��ȸ�ϱ� ����
      if j >= 1 then break;
    end;
  end;

  // �ɼ� �ɺ��� ���鼭 ��û 
  for j := 0 to gEnv.Engine.SymbolCore.OptionMarkets.Count - 1 do
  begin
    // �ɼ� ���� ������
    aOptMarket  := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[j];
    // ������ �ǳ� �� 
    if aOptMarket = nil then Continue;

    // �ɼ� �ڵ� �� 
    if (CompareStr(aOptMarket.Spec.FQN, FQN_MINI_KOSPI200_OPTION) = 0) or
      (CompareStr(aOptMarket.Spec.FQN, FQN_KOSPI200_OPTION) = 0) then
    begin
      // �� �տ� �͸� ���� ��.
      aOptTree  := aOptMarket.Trees.FrontMonth;// Trees[0];
      for I := 0 to aOptTree.Strikes.Count -1 do
      begin
        // �ֱٿ���
        aStrike := aOptTree.Strikes.Strikes[i];
        // �ֱٿ��� ��, ǲ�� ��û 
        //PushRequest( Qry_LastPrice, aStrike.Call.ShortCode );
        //PushRequest( Qry_LastPrice, aStrike.Put.ShortCode );
        AddSymbolMasterRequest(aStrike.Call.ShortCode);
        AddSymbolMasterRequest(aStrike.Put.ShortCode);
        gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', aStrike.Call.ShortCode );
        gLog.Add( lkApplication, 'TApiManager', 'DoRequestSymbolInfo', aStrike.Put.ShortCode );
      end;
      // ���� �� 
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

// �ֹ� ��û ���� 
function TApiManager.DoSendOrder(aOrder: TOrder): string;
var
  aInvest : TInvestor;
  iSide, iPrc   : integer;
  stLog : string;
begin
  Result := '';
  if not FReady then
  begin
    gEnv.ErrString := '������ ������';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try

    // ������ �ڵ� Ȯ��
    aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
    // ������ ������ �������� �ʴ´�.
    if aInvest = nil then Exit;

    // �ż� / �ŵ� 
    if aOrder.Side > 0 then
      iSide := 1
    else
      iSide := 2;

    // �ֹ� Ÿ�Կ� ���� ó��
    case aOrder.OrderType of
      // �ű� �ֹ�
      otNormal:
        begin
          stLog := '�ű�';

          case aOrder.PriceControl of
            pcLimit:  iPrc := 1;
            pcMarket: iPrc := 2;
            pcLimitToMarket:iPrc := 3 ;
            pcBestLimit:    iPrc := 4;
          end;
          // �ű� �ֹ� ��û
          //Result := FApi.OSendNewOrder(  aInvest.Code, aInvest.PassWord, aOrder.Symbol.Code,
          //  iSide,  iPrc, 1, aOrder.OrderQty, aOrder.Price, aOrder.LocalNo );
        end;

      // ���� �ֹ�
      otChange:
        begin
          if aOrder.Target = nil then
          begin
            gEnv.EnvLog( WIN_ERR, format('�����ֹ� ���� : ���ֹ��� ���� %s', [ aOrder.Represent3 ]));
            Exit;
          end;
          stLog := '����';

          case aOrder.PriceControl of
            pcLimit:  iPrc := 1;
            pcMarket: iPrc := 2;
            pcLimitToMarket:iPrc := 3 ;
            pcBestLimit:    iPrc := 4;
          end;

         // Result  := FApi.OSendModiOrder(   aInvest.Code, aInvest.PassWord, aOrder.Symbol.Code,
         //   iSide, iPrc, 1, aOrder.OrderQty, aOrder.Price, IntToStr(aOrder.Target.OrderNo), aOrder.LocalNo );

        end;
      // ��� �ֹ�
      otCancel:
        begin
          if aOrder.Target = nil then
          begin
            gEnv.EnvLog( WIN_ERR, format('����ֹ�  ���� : ���ֹ��� ���� %s', [ aOrder.Represent3 ]));
            Exit;
          end;
          stLog := '���';

          //Result  := FApi.OSendCancelOrder( aInvest.Code, aInvest.PassWord, aOrder.Symbol.Code,
          //  iSide, aOrder.OrderQty, IntToStr(aOrder.Target.OrderNo), aOrder.LocalNo ) ;
        end ;
    end;
  finally // ���� ó�� 
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
    gLog.Add( lkApplication, 'TApiManager', 'LoadMasterFromSymbolCode', stSymbolCode + ' -> �ɺ� �ڵ� �̻� ' );
    Exit;
  end;

  gEnv.Engine.SymbolCore.SymbolLoader.ImportMasterFromSymbolCode( stSymbolCode);

end;

// ������ ���� �ε� 
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
    gLog.Add( lkApplication, 'TWooApiIF', 'LoadMaster', stFileName + ' -> ������ ���� ' );
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

    ESID_5111 ,  // ��ü��
    ESID_5112 ,	 // ���ܰ�
    ESID_5122 ,  // ��Ź�ڻ�� ���ű�
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

    AUTO_0923 : gReceiver.ParseHoga( szRecvData );  	// ���� ȣ�� �ǽð�
    AUTO_0921	: gReceiver.ParsePrice( szRecvData );   //  ���� �ü� �ǽð�
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



// ����
procedure TApiManager.Fin;
begin
  //if FApi.OIsLogined then
  //  FApi.OCloseHost;
end;

// ���� �޽���
function TApiManager.GetErrorMessage(iRes: integer): string;
begin
  Result := '';
  case TResultType( iRes ) of
    rtNone          : Result := '����';
    rtAutokey       : Result := '���� �ڵ�������Ʈ key ���Է�';
    rtUserID        : Result := '���� ���̵� ���Է�';
    rtUserPass      : Result := '���� ��й�ȣ ���Է�';
    rtCertPass      : REsult := '�������� ��й�ȣ �� �Է�';
    rtSvrSendData   : Result := '���� ���� ����';
    rtSvrConnect    : Result := '���� ���� ����';
    rtSvrNoConnect  : Result := '���� ���� ����';
    rtCerTest       : Result := '���� ������ �������� ����';
    rtDllNoExist    : Result := 'signkorea dll ���ϰ��';
    rtTrCode        : Result := '������ ���� TR��ȣ';
  end;
end;

function TApiManager.GetViErrorMessage(iRes: integer): string;
begin
  Result := '';
  if iRes > 0 then
    Result := '����'
  else if iRes = -1 then
    Result := '���� ��Ͽ� ����'
  else if iRes = -4 then
    Result := '��й�ȣ ���� ����'
  else if iRes = -3 then
    Result := '��й�ȣ �ؽ� �۾� ����'
  else if iRes = -2 then
    Result := '�α��� �Ǿ� ���� ����'
  else
    Result := 'commapi ����';
       
end;

// ���� �� ¥ ���
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

// ���� ��¥ ��� 
function TApiManager.GetCurrentDate: string;
begin
//  Result  := FApi.ESExpGetCurrentDate;
end;


// ������ �̺�Ʈ �ڵ鷯
procedure TApiManager.OnApiThreadEvent(aPacket: POrderPacket);
begin
  case TApiRealType(aPacket.iDiv) of
    // ���� ȣ��
    atFutHoga : FRecevier.ParseFutHoga( string(aPacket.Packet) );
    // ���� ����
    atFutExec : FRecevier.ParseFutPrice( string(aPacket.Packet) );
    // �ɼ� ȣ��
    atOptHoga : FRecevier.ParseOptHoga( string(aPacket.Packet) );
    // �ɼ� �ü�
    atOptExec : FRecevier.ParseOptPrice( string(aPacket.Packet) );
    // �ֹ�
    atOrder :   FRecevier.ParseOrder( string(aPacket.Packet) );
    // ���� ����
    atFutInvest : FRecevier.ParseInvestFutData( string(aPacket.Packet) );
    // �ɼ� ����
    atOptInvest : FRecevier.ParseInvestOptData( string(aPacket.Packet) );
    // �ֽ� ���� ȣ��
    atStockFutHoga : FRecevier.ParseStockFutHoga(string(aPacket.Packet));
    // �ֽ� ���� �ü� 
    atStockFutExec : FRecevier.ParseFutPrice( string(aPacket.Packet) );
  end;
end;

// ���� ���� 
procedure TApiManager.OnWRAXConnected(Sender: TObject);
begin
  inc( FCount );
  FReady := true;
  gLog.Add( lkApplication, 'TApiManager', 'OnWRAXConnected', Format('%d th ���� �α��� �õ� ', [ FCount] ) );
  DoLogin;
end;

// ���� ���� ���� 
procedure TApiManager.OnWRAXDissConnected(Sender: TObject);
var
  stTmp : string;
  iRes  : integer;
begin
  FReady := false;
  gLog.Add( lkApplication, 'TApiManager', 'DoInit', '���� ����' );
  //gEnv.EnvLog( WIN_TEST, '���� ����');

  stTmp := '�ֹ������� ������ϴ�';//  �ڵ��������Ͻðڽ��ϱ�?';
  {
  iRes := MessageBox(gEnv.Main.Handle, PChar(stTmp), '����Ȯ��', MB_YESNO+MB_SYSTEMMODAL+MB_APPLMODAL	);
  if iRes = IDYES then
  begin
    gEnv.SaveLoginInfo;
    gEnv.Main.Close;
    WinExec( 'grLauncher.exe AutoConnect', SW_SHOWNORMAL );
  end
  else
  begin
  }
    ShowMessage( stTmp );//'���α׷��� �����մϴ�' );
    gEnv.Main.Close;
  //end;

end;

// ������ ���� �Լ� 
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

// �ǽð� ���� �ڵ鷯 - �����͸� ������ �����尡 ó���Ѵ�. 
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
    gLog.Add( lkApplication, 'TApiManager', 'WRAXReplyLogin', '������ ��û ����' ) ;
    DoRequestMaster;
  end
  else begin
    gLog.Add( lkApplication, 'TApiManager', 'WRAXReplyLogin', '������ ��û ���� : ' + Message );
    gEnv.ErrString  := '������ ��û ���� : ' + Message;
    gEnv.SetAppStatus( asError );
  end
end;

// �α��� ��� �ڵ鷯.
// �α��� �����ϸ� ���¸� ��û�ϰ� �ɺ� �����͸� ��û�Ѵ�. 
procedure TApiManager.OnWRAXReplyLogin(ASender: TObject; nResult: Smallint;
  const Message: WideString);
begin
  if nResult = 1 then begin
    gLog.Add( lkApplication, 'TWooApiIF', 'WRAXReplyLogin', '�α��� ����' ) ;
    gEnv.SetAppStatus( asConMaster );
    DoRequestAccout;
    DoRequestMaster;
  end
  else begin
    gLog.Add( lkApplication, 'TWooApiIF', 'WRAXReplyLogin', '�α��� ���� : ' + Message );
    gEnv.ErrString  := '�α��� ���� : ' + Message ;
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
    gEnv.ErrString := '������ ������';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
 //   Result := FApi.ESExpSendTrData( iTrCode, stReqData, iSize);
    if Result = 0  then
      gEnv.EnvLog( WIN_PACKET, Format('%d ��û ���� : %s', [ iTrCode, stReqData]) )
    else
      gEnv.EnvLog( WIN_PACKET, Format('%d ��û ���� : %d %s:%s', [ iTrCode, Result, stReqData , GetErrorMessage( Result ) ]) );
  except
    Result := -1;
    gEnv.EnvLog( WIN_PACKET, Format('%d ��û ���� : %s', [ iTrCode,stReqData]) );
  end;
end;

// function  RequestViData(stTrCode: string; stReqData: string; iSize : integer; stNext : string ) : integer
function  TApiManager.DoRequestViData(stKey, stTrCode: string; stReqData, stFidData: string; rtType : TApiReqType; iSize : integer; stNext : string ) : integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '������ ������';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
    if rtType = rtTr then
      Result := FApi.CommRqData( stTrCode, stReqData, Length(stReqData), stNext)
    else
      Result := FApi.CommFIDRqData( stTrCode, stReqData, stFidData, iSize, stNext);

    if Result > 0  then begin
      //gEnv.EnvLog( WIN_PACKET, Format('%s ��û ���� : %s', [ aItem.TrCode, aItem.Data]) );
      gLog.Add( lkApplication, 'TApiManager','DoRequestViData', Format('��û ���� : nRqId = %d , TrCode = %s, Data = %s',[ Result, stTrCode, stReqData ] )  );
      
    end
    else
      //gEnv.EnvLog( WIN_PACKET, Format('%s ��û ���� : %d %s:%s', [ aItem.TrCode, Result, aItem.Data , GetViErrorMessage( Result ) ]) );
      gLog.Add( lkApplication, 'TApiManager','DoRequestViData', Format('��û ����: nRqId = %d , TrCode = %s, Data = %s',[ Result, stTrCode, stReqData ] )  );
  except
    Result := -1;
    //gEnv.EnvLog( WIN_PACKET, Format('%s ��û ���� : %s', [ aItem.TrCode,aItem.Data]) );
    gLog.Add( lkApplication, 'TApiManager','DoRequestViData', Format('��û ����: nRqId = %d , TrCode = %s, Data = %s',[ Result, stTrCode, stReqData ] )  );
  end;
end;

function TApiManager.RequestViData2(var aItem : TSrvSendItem): integer;
var
  stReqId : string;
begin
  if not FReady then
  begin
    gEnv.ErrString := '������ ������';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
    if aItem.ReqType = rtTr then
      Result := FApi.CommRqData( aItem.TrCode, aItem.Data, Length(aItem.Data), '')
    else
      Result := FApi.CommFIDRqData( aItem.TrCode, aItem.Data, aItem.FidData, aItem.Size, '');

    if Result > 0  then begin
      //gEnv.EnvLog( WIN_PACKET, Format('%s ��û ���� : %s', [ aItem.TrCode, aItem.Data]) );
      gLog.Add( lkApplication, 'TApiManager','RequestViData2', Format('��û ���� : nRqId = %d , TrCode = %s, Data = %s',[ Result, aItem.TrCode, aItem.Data ] )  );
      aItem.reqId := Result;
      FViReqIdList.AddObject(IntToStr(Result), aItem);
    end
    else
      //gEnv.EnvLog( WIN_PACKET, Format('%s ��û ���� : %d %s:%s', [ aItem.TrCode, Result, aItem.Data , GetViErrorMessage( Result ) ]) );
      gLog.Add( lkApplication, 'TApiManager','RequestViData2', Format('��û ����: nRqId = %d , TrCode = %s, Data = %s',[ Result, aItem.TrCode, aItem.Data ] )  );
  except
    Result := -1;
    //gEnv.EnvLog( WIN_PACKET, Format('%s ��û ���� : %s', [ aItem.TrCode,aItem.Data]) );
    gLog.Add( lkApplication, 'TApiManager','RequestViData2', Format('��û ����: nRqId = %d , TrCode = %s, Data = %s',[ Result, aItem.TrCode, aItem.Data ] )  );
  end;
end;

function TApiManager.ReqRealTimeQuote(stTrCode, stData : string; bOn : boolean): integer;
begin
  Result := -1;
  if not FReady then
  begin
    gEnv.ErrString := '������ ������';
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
  // - �� �ٿ� ������ ����
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

// ��û ����� ���� ������ ����ؼ� ��û�� �Ѵ�. 
procedure TApiManager.TimeViReq( Sender: TObject );
var
  aItem : TSrvSendItem;
  I,  iRes : Integer;
  stTmp, sData, sFid : string;
begin
  // ����� ��� ������ ���� ������.
  if FViReqList.Count <= 0 then  begin
    Exit;
  end;

  // ũ��Ƽ�� ���� ����
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
      gEnv.EnvLog( WIN_ERR, Format('��ȸ ���� : [%d,%d] ', [i, FViReqList.Count]))
    end;
  end;
  finally
    LeaveCriticalSection(CritSect)
  end;
end;

// Ÿ�̸� ó�� �Լ�
// �߰��� Exit�� ȣ���ص� finally �� �׻� ȣ�� �ȴ�. 
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

    // ũ��Ƽ�� ���� ����
    EnterCriticalSection(CritSect);

    curIndex := FQryList.Count - 1;

    //for I := FQryList.Count - 1 downto 0 do
    //begin

      // ���� �Ը� �����ؼ� ������
      aItem := TSrvSendItem(  FQryList.Items[curIndex] );
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
      // Ư�� ���� ȸ���� 3���̻��� �� ó��
      if FQryCount[aItem.Index] >= 3 then
      begin
        iRes := SecondsBetween( now, FlastTime );
        // MilliSecondsBetween( now, FlastTime );
        // ������ ��ȸ �ð��� ���� �ð��� ���̰� ���� �䱸�ð����� ���� ���� �Լ� ����
        if iRes < ExSec then begin
          gEnv.EnvLog(WIN_Err, Format('Exit      [%d,%d](%d) (%s, %s)',[
            i, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] ) );
          Exit  ;
        end
        else
          gEnv.EnvLog( WIN_TEST, format('�ð� �ʰ��� �ٽ� ��ȸ %s -> %s [%d, %d]' , [
            FormatDateTime('hh:nn:ss.zzz', FLastTime), FormatDateTime('hh:nn:ss.zzz', now),
            FQryCount[aItem.Index],  FQryList.Count
             ]) );
      end;
      }

      if (aItem.TrCode = '') or (aItem.Data = '') then Exit;

      index := aItem.Index;

      //stTmp := Format('[%d,%d](%d) (%s, %s)',[
      //   i, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] ) ;

      // ��û ����
      iRes := DoRequestViData(aItem.Key, aItem.TrCode, aItem.Data, aItem.FidData, aItem.ReqType, aItem.Size,  '');

      gEnv.EnvLog( WIN_ERR, Format('Result = %d [%d,%d](%d) (%s, %s)',[ iRes,
         curIndex, FQryList.Count,  FQryCount[aItem.Index] , aItem.TrCode, aItem.Data ] )  );

      // ������ ��� 
      if iRes > 0 then begin


        FLastTime := now;
        // ���� ������ ���� ���� ȸ���� ���� ��Ų��.
        // Ư�� ���Ǹ� �� �� ���� �ߴ°��� ����Ѵ�.
        inc(FQryCount[aItem.Index]);
        FQryList.Delete(curIndex);
        aItem.Free;
        aItem := nil;
      end;
    //end;

    except
      if aItem <> nil then
      gEnv.EnvLog( WIN_ERR, Format('�ϰ� ��ȸ ���� : %d [%d,%d](%d) (%s, %s)', [
        iRes, curIndex, FQryList.Count, FQryCount[aItem.Index], aITem.TrCode, aItem.Data])
        )
      else
         gEnv.EnvLog( WIN_ERR, Format('�ϰ� ��ȸ ���� : [%d,%d] ', [
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
      -1 : stErr := '�������� �ʴ� �ǽð�';
      -2 : stErr := '�ǽð� Ű ���� �̻�';
      -3 : stErr := '�̹� ��ϵǾ� �ִ� �ǽð�';
      -4: stErr := '������ ��Ͻÿ� ���� �߻�';
      else stErr := '��Ÿ ����';
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
    //FQryList.Insert(0, aItem );
    FViReqList.AddObject(aItem.Key, aItem);
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



