unit CleApiManager;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts,

  DONGBUAPILib_TLB,  CleQuoteTimers, ApiPacket,

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
    FApi: TDongbuAPI;
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

    procedure OnServerConnect(ASender: TObject; hDongbuApi: Integer);
    procedure OnServerDisConnect(Sender: TObject);

    procedure OnRecvData(ASender: TObject; nReqID: Integer; const szMsgCode: WideString;
                                                      const szMsg: WideString;
                                                      const szData: WideString);

    procedure OnRealTimeData(ASender: TObject; const szName: WideString;
                                                        const szField: WideString;
                                                        const szData: WideString) ;
    function IsConn( stPrc : string = '' ) : boolean;

  public
    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;

    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : boolean;
    function Init( stID : string ): boolean;
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
    function  ReqRealTimeOrder(  bSet : boolean; stData : string = '') : integer;
    function  ReqAbleQty( aAccount : TAccount; stCode, stHogaType : string; iLS, iPrc : integer ) : boolean;
    function  ReqJango( aAccount : TAccount ) : boolean;


    procedure TimeProc( Sender : TObject );
    procedure TimeProc2( Sender : TObject );

    property Api: TDongbuAPI read FApi;
    property Recevier : TApiReceiver read FRecevier;
    property Ready : boolean read FReady ;//write FReady;
    property OnData: TTextNotifyEvent read FOnData write FOnData;
    property QryTimer : TTimer read FQryTimer write FQryTimer;
    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;
    property LoadStats : TLoadStatsType read FLoadStats write FLoadStats;

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
  FApi := aObj as  TDongbuAPI;

  FApi.OnConnected   := OnServerConnect;
  FApi.OnDisconnected:= OnServerDisConnect;

  FApi.OnReceiveData    :=  OnRecvData;
  FApi.OnReceiveRTData  :=  OnRealTimeData;


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


function TApiManager.DoLogIn(stID, stPW, stCert: string; iMode: integer) : boolean ;
var
  iRes : integer;
  wstID, wstPW, wstCert: widestring;
begin

  wstID := stID;
  wstPW := stPW;
  wstCert := stCert;

  gLog.Add( lkApplication, '','',  Format('?????????? : %s, %s, %s, %d', [
    stID, stPW, stCert, iMode  ])  );

  Result := FApi.Login( wstID, wstPW, wstCert, iMode );
end;
  {
procedure TApiManager.ESApiExpESExpAcctList(ASender: TObject;
  nListCount: Smallint; const szAcctData: WideString);
  var
    i, iStart : Integer;
    stData, stSub : string;
    pData : POutAccountInfo;
begin
  //ShowMessage( Format('???????? %d ,%d, %s', [   nListCount, Length( szAcctData ),   szAcctData ] ));

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
    Format('???? : %d, %s', [ nListCount, szAcctData ])) ;

end;


procedure TApiManager.ESApiExpESExpCodeList(ASender: TObject;
  nListCount: Smallint; const szCodeData: WideString);
begin

  //ShowMessage( Format('???????? %d , %s', [   nListCount, copy( szCodeData, 1, 50 )  ] ));

  if ( nListCount > 0 ) and ( szCodeData <> '' ) then
  begin
    gEnv.Engine.SymbolCore.SymbolLoader.ImportSymbolListFromApi(nListCount, szCodeData );
    //gEnv.EnvLog( WIN_GI,  Format('%d ???? ?????????? ????', [ nListCount])  );

    gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpCodeList',
        Format('%d ???? ?????????? ????', [ nListCount])
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

    ESID_5111 ,  // ??????
    ESID_5112 ,	 // ??????
    ESID_5122 ,  // ?????????? ??????
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
        if gEnv.RecoveryEnd then
           gEnv.EnvLog( WIN_TEST, Format('recovery %d(%d):%s', [ nTrCode, FAccountQryCount, szRecvData])  );
        
      end;

    AUTO_0923 : gReceiver.ParseHoga( szRecvData );  	// ???? ???? ??????
    AUTO_0921	: gReceiver.ParsePrice( szRecvData );   //  ???? ???? ??????
    AUTO_0932 : gReceiver.ParseTickArray( szRecvData );
    AUTO_0988 :
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d,%s', [ nTrCode, szRecvData]));
        gReceiver.ParseOrder( szRecvData);
      end;
    AUTO_0909 : gReceiver.ParseInvestOptData( szRecvData );

  end;

  except
    //ShowMessage( 'error : ' + szRecvData );
  end;

end;
     }


procedure TApiManager.Fin;
begin
{
aabb
  if (FApi.ESExpIsServerConnect) then
    FApi.ESExpDisConnectServer;
  }
end;


function TApiManager.GetEncodePassword(aAccount: TAccount): string;
begin

end;

function TApiManager.GetErrorMessage(iRes: integer): string;
begin
  Result := '';
  case TResultType( iRes ) of
    rtNone          : Result := '????';
    rtAutokey       : Result := '???? ???????????? key ??????';
    rtUserID        : Result := '???? ?????? ??????';
    rtUserPass      : Result := '???? ???????? ??????';
    rtCertPass      : REsult := '???????? ???????? ?? ????';
    rtSvrSendData   : Result := '???? ???? ????';
    rtSvrConnect    : Result := '???? ???? ????';
    rtSvrNoConnect  : Result := '???? ???? ????';
    rtCerTest       : Result := '???? ?????? ???????? ????';
    rtDllNoExist    : Result := 'signkorea dll ????????';
    rtTrCode        : Result := '???????? ???? TR????';
  end;
end;

function TApiManager.Init(stID: string): boolean;
begin
                                          // ???????? ???? ID, ?????? ????
  Result  := FApi.CreateDongbuAPICtrl( stID, 5,  OrpMainForm.Handle  );
end;

function TApiManager.IsConn( stPrc : string ): boolean;
begin

  if not FReady then
  begin
    gEnv.ErrString := '?????? ?????? : ' + stPrc;
    gEnv.SetAppStatus( asError );
    Result := false;
    Exit;
  end else Result := true;

end;

function TApiManager.GetCurrentDate(bDate: boolean): TDateTime;
begin

end;

function TApiManager.GetCurrentDate: string;
begin

end;
           {

procedure TApiManager.OnESExpServerConnect(ASender: TObject; nErrCode: Smallint;  const strMessage: WideString);
var
  rtValue : TResultType;
begin

  rtValue := TResultType( nErrCode );
  if rtValue in [ rtNone] then
  begin

    gLog.Add( lkApplication, 'TApiManager', 'DoInit', Format('???????? %d %s',[ nErrCode, strMessage]) ) ;
    gEnv.EnvLog( WIN_TEST, Format('%d %s',[ nErrCode, strMessage]) );

    FReady := true;
    gEnv.SetAppStatus( asConMaster );
    QryTimer.Enabled  := true;

  end else
  begin
    ShowMessage( Format('????????(%d) : %s' , [ nErrCode,  strMessage]) );
    gLog.Add( lkApplication, 'TApiManager', 'DoInit', Format('????????(%d) : %s' , [ nErrCode,  strMessage]) ) ;
    gEnv.EnvLog( WIN_TEST, strMessage);
  end;
end;

procedure TApiManager.OnESExpServerDisConnect(Sender: TObject);
var
  stTmp : string;
  iRes  : integer;
begin
  FReady := false;
  gLog.Add( lkApplication, 'TApiManager', 'DoInit', '???? ????' );
  gEnv.EnvLog( WIN_TEST, '???? ????');  

  stTmp := '?????????? ??????????  ???????????????????????';
  iRes := MessageBox(gEnv.Main.Handle, PChar(stTmp), '????????', MB_YESNO+MB_SYSTEMMODAL+MB_APPLMODAL	);
  if iRes = IDYES then
  begin
    gEnv.SaveLoginInfo;
    gEnv.Main.Close;
    WinExec( 'grLauncher.exe AutoConnect', SW_SHOWNORMAL );
  end
  else
  begin
    ShowMessage( '?????????? ??????????' );
    gEnv.Main.Close;
  end;

end;

         }

procedure TApiManager.OnRealTimeData(ASender: TObject; const szName, szField,
  szData: WideString);
begin

  if szName = R_SC0 then
    gReceiver.ParsePrice( szData )
  else if szName = R_SH0 then
    gReceiver.ParseHoga( szData )
  else if szName = R_OC0 then
    gReceiver.ParseOptionPrice( szData )
  else if szName = R_OH0 then
    gReceiver.ParseOptionHoga( szData )
  else if szName = R_XF2 then
    gReceiver.ParseOrder( szData)
  else if szName = R_XF3 then
    gEnv.EnvLog( WIN_GI, szData);

end;

procedure TApiManager.OnRecvData(ASender: TObject; nReqID: Integer;
  const szMsgCode, szMsg, szData: WideString);
begin
  gEnv.EnvLog( WIN_TEST,
    Format('%d, %s, %s, %s', [ nReqID, szMsgCode, szMsg, szData ])
    );
end;

procedure TApiManager.OnServerConnect(ASender: TObject; hDongbuApi: Integer);
begin
  if ASender = nil then Exit;

  if hDongbuApi = INVALID_HANDLE_VALUE then
  begin
    gLog.Add( lkError, 'TApiManager','OnServerConnect', '???? API ???????? ??????' );
    gEnv.ErrString  :=  '???? API ???????? ??????';
    gEnv.OnState( asError );
    Exit;
  end;

  gEnv.AnyHandle  := hDongbuApi;

  if not FApi.InitCtrl( gEnv.AnyHandle, OrpMainForm.Handle  ) then
  begin
    gLog.Add( lkError, 'TApiManager','OnServerConnect', '???? API ???????? ??????' );
    gEnv.ErrString  :=  '???? API ???????? ??????';
    gEnv.OnState( asError );
  end else
  begin
    FReady := true;
    gEnv.SetAppStatus( asConMaster );
    QryTimer.Enabled  := true;
  end;
end;

procedure TApiManager.OnServerDisConnect(Sender: TObject);
begin
  gEnv.AnyHandle  := 0;
  gLog.Add( lkError, 'TApiManager','OnServerDisConnect', '???? API ????' );
end;

procedure TApiManager.PushRequest(iTrCode : integer; stData : string; iSize : integer);
var
  aItem : TSrvSendItem;
begin

  case iTrCode of
    ESID_5101 ,
    ESID_5102 ,   // ?????? ???? ??????..?????? ?????? ???????? ????..
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



const
  ACC_LEN = 32;

procedure TApiManager.RequestAccountInfo;
var
  stData, stSub : string;
  iStart, iLen,  i, iCnt, iOffset : integer;
  pData : POutAccountInfo;
begin
  stData := FApi.GetAccountList(1);
  iOffset := 3;

  iCnt   := StrToIntDef( Copy( stData, 1, iOffset ), 0 );

  for I := 0 to iCnt - 1 do
  begin
    iStart  := i* Len_AccountInfo + iOffset + 1;
    stSub   := Copy( stData, iStart, Len_AccountInfo );
    pData   := POutAccountInfo( stSub );
    gEnv.Engine.TradeCore.Investors.New( trim( string( pData.Code )),
         trim( string( pData.Name ))  );
  end;

  gLog.Add( lkApplication, 'TApiManager', 'RequestAccountInfo',
    Format('???? : %d, %s', [ iCnt, stData ])) ;

  if iCnt <= 0 then
  begin
    gEnv.ErrString  := '?????? ?????? ????????';
    gEnv.SetAppStatus( asError);
  end
  else
    gEnv.SetAppStatus( asRecoveryStart );
end;

function TApiManager.RequestData(iTrCode: integer; stReqData: string; iSize : integer): integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '?????? ??????';
    gEnv.SetAppStatus( asError );
    Exit;
  end;
 {
 aabb
  try
    Result := FApi.ESExpSendTrData( iTrCode, stReqData, iSize);
    if Result = 0  then
      gEnv.EnvLog( WIN_PACKET, Format('%d ???? ???? : %s', [ iTrCode, stReqData]) )
    else
      gEnv.EnvLog( WIN_PACKET, Format('%d ???? ???? : %d %s:%s', [ iTrCode, Result, stReqData , GetErrorMessage( Result ) ]) );
  except
    Result := -1;
    gEnv.EnvLog( WIN_PACKET, Format('%d ???? ???? : %s', [ iTrCode,stReqData]) );
  end;
  }
end;


function TApiManager.ReqAbleQty(aAccount: TAccount; stCode, stHogaType: string;
  iLS, iPrc: integer): boolean;
  var
    stPrx : string;
begin
  stPrx := 'ReqAbleQty';
  if not IsConn( stPrx )  then Exit;

  REsult := FApi.ReqAbleQty( aAccount.Code, aAccount.PassWord, stCode, iLS, iPrc, stHogaType );

  gEnv.EnvLog( WIN_TEST, Format('%s ???? %s : %s', [ stPrx, ifThenStr( Result,'????','????'),
     Format('%s, %d, %d', [ stCode, iLS, iPrc ])
     ]) )
end;

function TApiManager.ReqJango(aAccount: TAccount): boolean;
var
  stPrx : string;
begin

  stPrx := 'ReqJango';
  if not IsConn( stPrx )  then Exit;

  if ( aAccount = nil ) or ( aAccount.PassWord = '' ) then
  begin
    gEnv.EnvLog( WIN_ERR, '???? ???? ???? - ???? ????' );
    Exit;
  end;

  Result  := FApi.ReqJango( aAccount.Code );

  gEnv.EnvLog( WIN_TEST, Format('%s ???? %s : %s', [ stPrx, ifThenStr( Result,'????','????'),
     aAccount.Code
     ]) )
end;

function TApiManager.ReqRealTimeOrder( bSet: boolean; stData: string): integer;
var
  bRes : boolean;
begin
  if not FReady then
  begin
    gEnv.ErrString := '?????? ??????';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  bRes := FApi.ReqRealtimeData( ifThen( bSet, ID_ADVICE_RT, ID_UNADVICE_RT ),
     R_XF2, stData );

  if bRes then
    gEnv.EnvLog( WIN_TEST, Format('???????? %s ???? : %s', [ ifThenSTr( bSet, '????','????????'), stData]) )
  else
    gEnv.EnvLog( WIN_PACKET, Format('???????? ???? ???? : %s', [ stData]) );
end;

function TApiManager.ReqRealTimeQuote(bSet: boolean;  stData: string): integer;
var
  bRes1, bRes2 : boolean;
  iVal : integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '?????? ??????';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  iVal := ifThen( bSet, ID_ADVICE_RT, ID_UNADVICE_RT );

  if stData[1] = '1' then
  begin
    bRes1 := FApi.ReqRealtimeData( iVal, R_SC0, stData );
    bRes2 := FApi.ReqRealtimeData( iVal, R_SH0, stData) ;
  end else
  begin
    bRes1 := FApi.ReqRealtimeData( iVal, R_OC0, stData );
    bRes2 := FApi.ReqRealtimeData( iVal, R_OH0, stData) ;
  end;

  if bRes1 then
    gEnv.EnvLog( WIN_TEST, Format('?????? %s ???? : %s', [ ifThenSTr( bSet, '????','????????'), stData]) )
  else
    gEnv.EnvLog( WIN_PACKET, Format('?????? ???? ???? : %s', [ stData]) );

  if bRes2 then
    gEnv.EnvLog( WIN_TEST, Format('?? ?? %s ???? : %s', [ ifThenSTr( bSet, '????','????????'), stData]) )
  else
    gEnv.EnvLog( WIN_PACKET, Format('?? ?? ???? ???? : %s', [ stData]) );
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
  // - ?? ???? ?????? ????
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
        ESID_5111,   // ??????
        ESID_5112,	 // ??????
        ESID_5122,
        ESID_5124 :  idx := ACCOUNT_QRY; // ?????????? ??????
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

