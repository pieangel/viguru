unit CleApiManager;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts,

  ESINApiExpLib_TLB,  CleQuoteTimers, ApiPacket,

  GleTypes
  ;

//{$INCLUDE define.txt}

const
  MAX_CNT = 35;
  MAX_CNT2 = 2;
  QRY_CNT = 2;

  ACCOUNT_QRY = 1;
  SYMBOL_QRY  = 0;
  AUOTE_QUOTE = 2;
type

  TLoadStatsType = ( lstNone, lstSymbol, lstAccount, lstEnd );

  TSrvSendItem = class( TCollectionItem )
  public
    TrCode : integer;
    Data   : string;
    Key    : string;
    Size   : integer;
    Index  : integer;

    Constructor Create( aColl : TCollection ) ; overload;
  end;

  TApiManager = class
  private
    FApi: TESINApiExp;
    FReady: boolean;
    FOnData: TTextNotifyEvent;
    FQryList : TList;
    FAutoQuoteList : TList;
    FQryTimer: TTimer;
    FAutoTimer: TTimer;

    FQryCount : array [0..QRY_CNT-1] of integer;
    FLoadStats: TLoadStatsType;
    FSendQryCount: integer;
    FRecevier: TApiReceiver;
    FAccountQryCount: integer;
    FOwnIP: string;

    procedure OnESExpServerConnect(ASender: TObject; nErrCode: Smallint; const strMessage: WideString);
    procedure OnESExpServerDisConnect(Sender: TObject);

    procedure ESApiExpESExpRecvData(ASender: TObject; nTrCode: Smallint;
                                                       const szRecvData: WideString);
    procedure ESApiExpESExpAcctList(ASender: TObject; nListCount: Smallint;
                                                       const szAcctData: WideString);
    procedure ESApiExpESExpCodeList(ASender: TObject; nListCount: Smallint;
                                                       const szCodeData: WideString);
    procedure ESINApiExpESExpAcctListByte(ASender: TObject; nListCount: Smallint;
                                                             var szAcctData: Byte);

  public
    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;

    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : integer;
    procedure Fin;

    procedure RequestAccountInfo;

    function GetEncodePassword( aAccount : TAccount ) : string;
    function GetErrorMessage( iRes : integer ) : string;
    function GetCurrentDate : string; overload;
    function GetCurrentDate( bDate : boolean ) : TDateTime; overload;

    procedure RequestMaster( stUnder, stCode, stIndex : string );
    procedure PushRequest( iTrCode : integer; stData : string; iSize : integer );
    function  RequestData(iTrCode: integer; stReqData: string; iSize : integer ) : integer;
    function  ReqRealTimeQuote(  bSet : boolean; stData : string ) : integer;
    function  ReqRealTimeOrder(  bSet : boolean; stData : string ) : integer;

    procedure TimeProc( Sender : TObject );
    procedure TimeProc2( Sender : TObject );

    property Api: TESINApiExp read FApi;
    property Recevier : TApiReceiver read FRecevier;
    property Ready : boolean read FReady ;//write FReady;
    property OnData: TTextNotifyEvent read FOnData write FOnData;
    property QryTimer : TTimer read FQryTimer write FQryTimer;
    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;
    property LoadStats : TLoadStatsType read FLoadStats write FLoadStats;
    property OwnIP  : string read FOwnIP write FOwnIP;
    // counting
    property SendQryCount : integer read FSendQryCount;
    property AccountQryCount : integer read FAccountQryCount;
  end;


implementation

uses
  GAppEnv, GleLib , SynthUtil,  Dialogs,
  FOrpMain,
  Math
  ;

{ TApiManager }

constructor TApiManager.Create(aObj: TObject);
var
  I: Integer;
begin
  FReady  := false;
  FApi := aObj as  TESINApiExp;

  FApi.OnESExpRecvData  :=  ESApiExpESExpRecvData;
  FApi.OnESExpAcctList  :=  ESApiExpESExpAcctList;
  FApi.OnESExpCodeList  :=  ESApiExpESExpCodeList;
  //FApi.OnESExpAcctListByte  := ESINApiExpESExpAcctListByte;

  FApi.OnESExpServerConnect := OnESExpServerConnect;
  FApi.OnESExpServerDisConnect  := OnESExpServerDisConnect;

  FRecevier:= TApiReceiver.Create;

  FQryList := TList.Create;
  FAutoQuoteList := TList.Create;;

  QryTimer  := TTimer.Create( nil );
  QryTimer.Interval := 50;
  QryTimer.Enabled  := false;
  QryTimer.OnTimer  := TimeProc;


  FAutoTimer  := TTimer.Create( nil );
  FAutoTimer.Interval := 200;
  FAutoTimer.Enabled  := false;
  FAutoTimer.OnTimer  := TimeProc2;

  for I := 0 to High( FQryCount ) do
    FQryCount[i]  := 0;

  FSendQryCount := 0;
  FAccountQryCount  := 0;

end;

destructor TApiManager.Destroy;
begin
  QryTimer.Enabled  := false;
  QryTimer.Free;

  FAutoTimer.Enabled := false;
  FAutoTimer.Free;
  //Fin;
  FQryList.Free;
  FAutoQuoteList.Free;
  FRecevier.Free;
  inherited;
end;


function TApiManager.DoLogIn(stID, stPW, stCert: string; iMode: integer) : integer ;
var
  iRes : integer;
  stDir: string;
  bRes : boolean;

  wstID, wstPW, wstCert: widestring;
begin

  Result := 0;

  try
    if FApi.ESExpIsServerConnect then
    begin
      //ShowMessage('접속 !!!');
      FApi.ESExpDisConnectServer;
    end;
  except
    ShowMessage('Dll 에러 발생 다시 접속해주세요');
    gLog.Add( lkError, '','','접속 시 Dll 에러 발생 다시 접속해주세요' );
    Exit;
  end;

  stDir := ExtractFilePath( paramstr(0) );
  FApi.ESExpApiFilePath(stDir);

  try
    if gEnv.UserType = utStaff then
      bRes := FApi.ESExpSetUseStaffMode( true );

    if not bRes then
    begin
      ShowMessage('staff 접근 거부');
      gEnv.EnvLog( WIN_ERR, Format('Staff 접근 거부 : %s, %s, %s, %d', [
          stID, stPW, stCert, iMode ]));
      Exit;
    end;

  except
    ShowMessage('staff 접근 에러');
      gEnv.EnvLog( WIN_ERR, Format('Staff 접근 에러 : %s, %s, %s, %d', [
          stID, stPW, stCert, iMode ]));
    Exit;
  end;
  gLog.Add( lkApplication, '','',  Format('로그인시도 : %s, %s, %s, %d', [
    stID, stPW, stCert, iMode  ])
     )     ;
  wstID := stID;
  wstPW := stPW;
  wstCert := stCert;

  Result  :=  FApi.ESExpConnectServer( wstID, wstPW, wstCert, iMode);

end;

procedure TApiManager.ESApiExpESExpAcctList(ASender: TObject;
  nListCount: Smallint; const szAcctData: WideString);
  var
    i, iStart : Integer;
    stData, stSub : string;
    pData : POutAccountInfo;
begin
  //ShowMessage( Format('계좌수신 %d ,%d, %s', [   nListCount, Length( szAcctData ),   szAcctData ] ));

  stData  := szAcctData;

  for I := 0 to nListCount - 1 do
  begin
    iStart:= i * Len_AccountInfo + 1;
    stSub := Copy( stData, iStart, Len_AccountInfo );
    pData := POutAccountInfo( stSub );
    gEnv.Engine.TradeCore.Investors.New( trim( string( pData.Code )),
         trim( string( pData.Name )),
         trim( string( pData.Pass))  );
    //gEnv.Engine.TradeCore.CheckVirAccount;
  end;

  gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpAcctList',
    Format('계좌 : %d, %s', [ nListCount, szAcctData ])) ;

end;

procedure TApiManager.ESINApiExpESExpAcctListByte(ASender: TObject;
  nListCount: Smallint; var szAcctData: Byte);
begin
  //ShowMessage( Format('계좌수신2 %d , %s', [   nListCount,   szAcctData ] ));

  gLog.Add( lkApplication, 'TApiManager', 'ESINApiExpESExpAcctListByte',
    Format('계좌 : %d, %s', [ nListCount, szAcctData ])) ;
end;


procedure TApiManager.ESApiExpESExpCodeList(ASender: TObject;
  nListCount: Smallint; const szCodeData: WideString);
begin

  //ShowMessage( Format('종목수신 %d , %s', [   nListCount, copy( szCodeData, 1, 50 )  ] ));

  if ( nListCount > 0 ) and ( szCodeData <> '' ) then
  begin
    gEnv.Engine.SymbolCore.SymbolLoader.ImportSymbolListFromApi(nListCount, szCodeData );
    //gEnv.EnvLog( WIN_GI,  Format('%d 개의 종목리스트 수신', [ nListCount])  );

    gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpCodeList',
        Format('%d 개의 종목리스트 수신', [ nListCount])
        ) ;
  end;
end;

procedure TApiManager.ESApiExpESExpRecvData(ASender: TObject; nTrCode: Smallint;
  const szRecvData: WideString);
begin
  //ShowMessage( Format( 'RecvData TR : %d   , %s', [ nTrCode, Copy( szRecvData, 1, 100)]));
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
    //ShowMessage( 'error : ' + szRecvData );
  end;

end;



procedure TApiManager.Fin;
begin
  if (FApi.ESExpIsServerConnect) then
    FApi.ESExpDisConnectServer;
end;


function TApiManager.GetEncodePassword(aAccount: TAccount): string;
begin
  REsult := '';
  if ( not FReady ) or ( aAccount = nil ) then Exit;

  //if gEnv.UserType = utNormal then
    Result := FApi.ESExpGetEncodePassword( aAccount.Code, aAccount.PassWord );
  //else
   // Result := aAccount.PassWord;

end;

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

function TApiManager.GetCurrentDate(bDate: boolean): TDateTime;
var
  stDate : string;
begin
  stDate  := FApi.ESExpGetCurrentDate;
  Result  := EncodeDate(StrToIntDef(Copy(stDate,1,4), 0),
                           StrToIntDef(Copy(stDate,5,2), 0),
                           StrToIntDef(Copy(stDate,7,2), 0))
end;

function TApiManager.GetCurrentDate: string;
begin
  Result  := FApi.ESExpGetCurrentDate;
end;


procedure TApiManager.OnESExpServerConnect(ASender: TObject; nErrCode: Smallint;  const strMessage: WideString);
var
  rtValue : TResultType;
begin

  rtValue := TResultType( nErrCode );
  if rtValue in [ rtNone] then
  begin

    gLog.Add( lkApplication, 'TApiManager', 'DoInit', Format('접속성공 %d %s',[ nErrCode, strMessage]) ) ;
    gEnv.EnvLog( WIN_TEST, Format('%d %s',[ nErrCode, strMessage]) );

    FReady := true;
    gEnv.SetAppStatus( asConMaster );
    QryTimer.Enabled  := true;

  end else
  begin
    ShowMessage( Format('접속에러(%d) : %s' , [ nErrCode,  strMessage]) );
    gLog.Add( lkApplication, 'TApiManager', 'DoInit', Format('접속에러(%d) : %s' , [ nErrCode,  strMessage]) ) ;
    gEnv.EnvLog( WIN_TEST, strMessage);
  end;
end;

procedure TApiManager.OnESExpServerDisConnect(Sender: TObject);
var
  stTmp : string;
  iRes  : integer;
begin
  FReady := false;
  gLog.Add( lkApplication, 'TApiManager', 'DoInit', '접속 종료' );
  gEnv.EnvLog( WIN_TEST, '접속 종료');  

  stTmp := '주문접속이 끊겼습니다  자동재접속하시겠습니까?';
  iRes := MessageBox(gEnv.Main.Handle, PChar(stTmp), '접속확인', MB_YESNO+MB_SYSTEMMODAL+MB_APPLMODAL	);
  if iRes = IDYES then
  begin
    gEnv.SaveLoginInfo;
    gEnv.Main.Close;
    WinExec( 'grLauncher.exe AutoConnect', SW_SHOWNORMAL );
  end
  else
  begin
    ShowMessage( '프로그램을 종료합니다' );
    gEnv.Main.Close;
  end;

end;



procedure TApiManager.PushRequest(iTrCode : integer; stData : string; iSize : integer);
var
  aItem : TSrvSendItem;
begin

  case iTrCode of
    ESID_5101 ,
    ESID_5102 ,   // 주문만 바로 보내고..나머지 조회는 카운팅을 한당..
    ESID_5103 : RequestData( iTrCode, stData, iSize );
    AUTO_0921, AUTO_0932, AUTO_0923 :
      begin
        aItem := TSrvSendItem.Create( nil );
        aItem.TrCode  := iTrCode;
        aItem.Data    := stData;
        aItem.Size    := iSize;
        FAutoQuoteList.Insert(0, aItem );
      end
    else
      begin
        aItem := TSrvSendItem.Create( nil );
        aItem.TrCode  := iTrCode;
        aItem.Data    := stData;
        aItem.Size    := iSize;
        FQryList.Insert(0, aItem );

        inc( FSendQryCount );

        case iTrCode of
          ESID_5124,
          ESID_5112,
          ESID_5111 : inc( FAccountQryCount );
        end;


      end;
  end;
end;




procedure TApiManager.RequestAccountInfo;
begin

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
    Result := FApi.ESExpSendTrData( iTrCode, stReqData, iSize);
    if Result = 0  then
      gEnv.EnvLog( WIN_PACKET, Format('%d 요청 성공 : %s', [ iTrCode, stReqData]) )
    else
      gEnv.EnvLog( WIN_PACKET, Format('%d 요청 실패 : %d %s:%s', [ iTrCode, Result, stReqData , GetErrorMessage( Result ) ]) );
  except
    Result := -1;
    gEnv.EnvLog( WIN_PACKET, Format('%d 요청 에러 : %s', [ iTrCode,stReqData]) );
  end;
end;


function TApiManager.ReqRealTimeOrder( bSet: boolean; stData: string): integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  Result := FApi.ESExpSetAutoUpdate( bSet, True, stData );

  if  Result = 0 then
    gEnv.EnvLog( WIN_PACKET, Format('계좌 자동 요청 성공 : %s', [ stData]) )
  else
    gEnv.EnvLog( WIN_PACKET, Format('계좌 자동 요청 실패 : %s', [ stData]) );

end;

function TApiManager.ReqRealTimeQuote(bSet: boolean;  stData: string): integer;
begin
 if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  Result := FApi.ESExpSetAutoUpdate( bSet, false, stData );

  if Result = 0 then
    //gEnv.EnvLog( WIN_TEST, Format('시세 %s 성공 : %s', [ ifThenSTr( bSet, '구독','구독취소'), stData]) )
  else
    gEnv.EnvLog( WIN_PACKET, Format('시세 자동 실패 : %s', [ stData]) );
end;


procedure TApiManager.RequestMaster(stUnder, stCode, stIndex: string );
var
  Buffer  : array of char;
  aData   : PReqSymbolMaster;

  stData  : string;

begin
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-3s', [ stUnder ]),  aData.AssetsID );
  MovePacket( Format('%-12.12s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4s',   [ stIndex]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );
  PushRequest( ESID_2007, stData,  Sizeof( TReqSymbolMaster ));

end;

procedure TApiManager.TimeProc(Sender: TObject);
var
  aItem : TSrvSendItem;
  I, iCnt, idx : Integer;
begin

  if FQryList.Count <= 0 then  Exit;

  try
    iCnt := 0;
    for I := FQryList.Count - 1 downto 0 do
    begin

      aItem := TSrvSendItem(  FQryList.Items[i] );
      if aItem = nil then Continue;

      idx := -1;
      case aItem.TrCode of
        ESID_2007, ESID_2003, ESID_2004 : idx :=  SYMBOL_QRY;
        ESID_5111,   // 실체결
        ESID_5112,	 // 실잔고
        ESID_5122,
        ESID_5124 :  idx := ACCOUNT_QRY; // 예탁자산및 증거금
      end;

      if idx >= 0 then
        if FQryCount[idx] > MAX_CNT then
          break;

      RequestData( aItem.TrCode, aItem.Data, aitem.Size );

      if idx >= 0 then
        inc(FQryCount[idx]);

      FQryList.Delete(i);
      aItem.Free;
    end;

  finally
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

      ReqRealTimeQuote( true, aItem.Data );

      FAutoQuoteList.Delete(i);
      aItem.Free;
      inc( iCnt );
    end;

  except
  end;

end;

{ TSrvSendItem }

constructor TSrvSendItem.Create(aColl: TCollection);
begin
  TrCode := -1;
  Data   := '';
  Index  := - 1;
  Key    := '';
end;

end.
