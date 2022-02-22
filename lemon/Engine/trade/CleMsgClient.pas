unit CleMsgClient;

interface


uses
  Classes, SysUtils, Windows, IniFiles, mmsystem, Dialogs, WinSock, ScktComp,

    // Lemon: Common
  GleLib,
    // lemon: data
  CleAccounts, CleSymbols, CleOrders,
    // Lemon: Utils
  CleParsers, GleConsts, GleTypes, SynthUtil, KospiPacket,
    // App: common
  GAppEnv
  ;


const
  // send/rev constant
  FILL_BUF_SIZE = 4096;
  UNIT_TITLE = 'UAuto';

  PACKET_HEADER_SIZE = 23;
  POLL_MESSAGE_SIZE = 200;
  RES_NORMAL = '00';


type

  TMzMsgNotify = procedure(Sender : TObject; bSuccess : Boolean; MsgType, stData : String) of object;

  TMsgClient = class
  private
    FSocketPort: integer;
    FRcvCnt: integer;
    FSocketAddress: string;
    FSocket: TClientSocket;
    FPort: integer;
    FSocketState: TSocketState;
    FOnLog: TTextNotifyEvent;
    FOnBullMsg: TMzMsgNotify;
    FOnUbfAutoMsg: TMzMsgNotify;
    FOnArMsg: TMzMsgNotify;
    FOnPollMsg: TMzMsgNotify;

    procedure OnConnect(Sender: TObject; Socket: TCustomWinSocket) ;
    procedure OnRead(Sender: TObject; Socket: TCustomWinSocket) ;
    procedure OnDisConnect(Sender: TObject; Socket: TCustomWinSocket) ;
    procedure OnError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer) ;
    procedure OnSocketState(const ssValue: TSocketState);
    procedure SetPort(const Value: integer);
    function SendPacket(stMsgType, stData: String): Boolean;

    function SendLINK: Boolean;
    function SendPollAck: Boolean;

    procedure ProcessPacket(szPacket : PChar; iSize : Integer);
    procedure ProcessUbfPollMessage(stData: String);


  public

    FRcvBuf       : array [0..FILL_BUF_SIZE] of char;
    FClientSn     : integer;
    FFepSn        : integer;
    FLogCount     : integer;
    FServerDebugLog : boolean;
    FTime : TDateTime;                          // 마지막 처리시각

    constructor Create( iSocket : integer );
    destructor Destroy; override;

    procedure DoLog(stLog: String);    

    property Port     : integer read FPort write SetPort;
    property Socket   : TClientSocket read FSocket;
    property RcvCnt  : integer read FRcvCnt write FRcvCnt;
    property SocketState : TSocketState read FSocketState write OnSocketState;
    property SocketAddress : string read FSocketAddress;
    property SocketPort : integer read FSocketPort;
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;

    property OnBullMsg : TMzMsgNotify read FOnBullMsg write FOnBullMsg;
    property OnUbfAutoMsg : TMzMsgNotify read FOnUbfAutoMsg write FOnUbfAutoMsg;
    property OnArMsg : TMzMsgNotify read FOnArMsg write FOnArMsg;
    property OnPollMsg : TMzMsgNotify read FOnPollMsg write FOnPollMsg;


    procedure StartRecovery(iHandle, iKey: Integer);
    function LoadIniFile: Boolean;
    function SocketConnect: boolean;
    procedure SocketDisconnect;
    function SendData(stMsgType, stData: String): Boolean;

  end;

  var
    gMsgClient : TMsgClient;

implementation

uses
  CleKRXTradeReceiver;

{ TMsgClient }

constructor TMsgClient.Create(iSocket: integer);
var ivar : integer;     stName : string;
begin

  FSocketState := ssClosed;

  FSocket := TClientSocket.Create( nil);

  FRcvCnt := 0;
  FClientSn := 0;
  FFepSn    := 0;
  FLogCount := 0;
  FServerDebugLog := False;

  FSocket.OnConnect := OnConnect;
  FSocket.OnRead    := OnRead;
  FSocket.OnDisconnect  := OnDisconnect;
  FSocket.OnError       := OnError;

  gMsgClient  := self;
end;

destructor TMsgClient.Destroy;
begin
  gMsgClient  := nil;
  FSocket.Free;
  inherited;
end;

procedure TMsgClient.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    OnLog(Self, stLog);
end;


function TMsgClient.LoadIniFile: Boolean;
begin

end;

procedure TMsgClient.StartRecovery(iHandle, iKey: Integer);
begin
    // 연결 알릴 정보

  if not LoadIniFile then
  begin
    ShowMessage('환경파일-[MsgServer] 로딩 실패!');
    Exit;
  end;
  {
  if FActive then
  begin
    gLog.Add(lkDebug, UNIT_TITLE, 'StartRecovery', '연결시도중');
      // 연결시도
    ConnectToFep;
  end
  else
  begin
    gLog.Add(lkDebug, UNIT_TITLE, '', 'Recovery Skipped!' );
    PostAppMsg(FAppHandle, FConnKey, SUCCESS);
  end;
  }
end;

procedure TMsgClient.OnConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  FRcvCnt := 0;
  FillChar(FRcvBuf, FILL_BUF_SIZE, #0);
  OnSocketState(ssConnected);

end;

function TMsgClient.SocketConnect: boolean;
begin
  if FSocket.Active then
    SocketDisconnect;

  OnSocketState(ssConnectPend);

  FSocketAddress := gEnv.ConConfig.FutureIP;
  FSocketPort := gEnv.ConConfig.MPort;

  try
    with FSocket do begin
      Address := FSocketAddress;
      Port := FSocketPort;
      Open;
    end;
  Except
    On E : Exception do
      gLog.Add( lkError, 'TMsgClient','SocketConnect', IntToStr( GetLastError) + ' | ' + E.Message );
  end;
end;

procedure TMsgClient.SocketDisconnect;
begin
  FSocket.Close;
  gLog.Add( lkApplication, 'TMsgClient','SocketDisconnect', 'Msg Server 와 연결종료' );
end;


procedure TMsgClient.OnDisConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  OnSocketState( ssClosed );
end;

procedure TMsgClient.OnError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  var stLog : string;
begin
  try
    FRcvCnt := 0;
    FillChar(FRcvBuf, FILL_BUF_SIZE, #0);
    stLog := Format('소켓에러 : %d ', [ErrorCode]);
  except
    DoLog( stLog );
    OnSocketState(ssClosed);
  end;

end;

procedure TMsgClient.OnRead(Sender: TObject; Socket: TCustomWinSocket);
var
  RcvBuffer: array[0..FILL_BUF_SIZE - 1] of Char;
  iRcvSize, iPacketLength, iFree, iStart, iHeadSize, iError: Integer;
  pComHead : PMessageHead;
  stSize   : String;
  stTmp, stTest    : string;
  cSTXType : char;

  vPacket : PStReceptPacket;
  objID : TOrder;
  ivar, iCookie : integer;
begin

  iFree := FILL_BUF_SIZE - FRcvCnt;
  iRcvSize := Socket.ReceiveBuf( FRcvBuf[FRcvCnt], iFree );

  Inc(FRcvCnt, iRcvSize);
  iStart := 0;

  while FRcvCnt >= MSG_HEADERLEN do begin
      pComHead := PMessageHead(@FRcvBuf[iStart]);
      SetString( stSize, pComHead^.stCommsize, sizeof(pComHead^.stCommSize) );
      iPacketLength := StrToIntDef(stSize,0);
      if iPacketLength <= 0 then begin
        inc(iStart);
        dec(FRcvCnt);
        Continue;
      end;

      iPacketLength := iPacketLength + FEPHEADLENGTH;

      FillChar(RcvBuffer, iPacketLength, #0);
      Move(FRcvBuf[iStart], RcvBuffer[0], iPacketLength );

      ProcessPacket( @RcvBuffer[0], iPacketLength );
      //PushQueue(TYPE_RECEIVE, iPacketLength, @RcvBuffer[0]);

      Inc(iStart, iPacketLength );
      Dec(FRcvCnt, iPacketLength );
  end;


  Move(FRcvBuf[iStart], FRcvBuf[0], FRcvCnt);
  FillChar(FRcvBuf[FRcvCnt], FILL_BUF_SIZE - FRcvCnt, #0);

end;

procedure TMsgClient.OnSocketState(const ssValue: TSocketState);
var stTmp : string;
begin
  FSocketState := ssValue;
  case ssValue of
    ssClosed:
      begin
        DoLog(stTmp + 'disconnect ');
        //SocketConnect;
      end;
    ssConnectPend: ;
    ssConnected:
      begin
        gLog.Add( lkApplication, 'TMsgClient','OnSocketState', 'Msg Server 와 연결됨' );
        SendLink;
      end;
    ssLoginPend: ;
    ssRecovering: ;
    ssOpen: ;
  end;
end;



procedure TMsgClient.SetPort(const Value: integer);
begin
  FPort := Value;
end;


function TMsgClient.SendLINK: Boolean;
begin
  Result := SendPacket( '92', '');
end;

function TMsgClient.SendPollAck: Boolean;
begin
  Result := SendPacket( '98', '');
end;

function TMsgClient.SendData( stMsgType, stData : String) : Boolean;
begin
  Result := SendPacket( stMsgType, stData);
end;

function TMsgClient.SendPacket(stMsgType, stData : String): Boolean;
var
  stText : String;
  iSize : Integer;
begin
  Inc(FClientSn);
  iSize := PACKET_HEADER_SIZE-5 + Length(stData);
  stText := Format(#02'%.4d%.7d%2s%2s%3s%4s%s',
                [iSize,
                 FClientSn,
                 stMsgType,
                 RES_NORMAL,
                 gEnv.ConConfig.UserID,
                 '>',
                 stData]);

 Result := (FSocket.Socket.SendText(stText) > 0);
 {
  if FPacketLog then
    gLog.Add(lkServer, UNIT_TITLE, 'Send', stText);
  }
  FTime := Now;
end;

procedure TMsgClient.ProcessPacket(szPacket: PChar; iSize: Integer);
var
  aHeader : PMessageHead;
  iRemain, iLen  : integer;
  MsgType, Data, Tmp, Response, stLog, Size  : string;
begin

  aHeader := @szPacket[0];

  SetString( MsgType, aHeader.stApType, sizeof( aHeader.stApType ));
  SetString( Tmp, aHeader.stLastSN, sizeof( aHeader.stLastSN ));
  SetString( Response, aHeader.stResponse, sizeof( aHeader.stResponse ));
  SetString( Size, aHeader.stCommsize, sizeof( aHeader.stCommsize ));
  iLen  := StrToInt( Size );

  iRemain := iLen -( MSG_HEADERLEN - 5 );
  iLen  :=  sizeof( PMessageHead );
  if iRemain > 0 then
    DeconvertBytes(szPacket, iLen, Data, iRemain);

  FFepSn  := StrToInt( Tmp );

  if MsgType = TYPE_LINK then
  begin
    if Response = RES_NORMAL then
    begin
      OnSocketState( ssOpen );
    end;
  end
  else if MsgType = TYPE_POLL then // poll
  begin
    SendPollAck;
  end
  else if MsgType = '01' then  // UBFAuto 설정 응답
  begin
    if Assigned(FOnUbfAutoMsg) then
      FOnUbfAutoMsg(Self, Response=RES_NORMAL, MsgType, '');
  end
  else if (MsgType = '02') or
          (MsgType = '03') then   // Bull 설정 응답
  begin
    if Assigned(FOnBullMsg) then
        FOnBullMsg(Self, Response=RES_NORMAL, MsgType, Data);
  end
  else if (MsgType = '10') or
          (MsgType = '11') or
          (MsgType = '12') then
  begin
    if Assigned(FOnArMsg) then
        FOnArMsg(Self, Response=RES_NORMAL, MsgType, Data);
  end
  else if MsgType = '20' then   // UBFAuto Poll Message
  begin
    if Assigned(FOnPollMsg) then
      FOnPollMsg(Self, Response=RES_NORMAL, MsgType, Data);

    ProcessUbfPollMessage(Data);

  end else
  begin
    //gLog.Add(lkDebug, UNIT_TITLE, '', 'Unknown Packet' );
  end;


end;

procedure TMsgClient.ProcessUbfPollMessage( stData : String );
var
  stSource, stTarget, cType, stType, stMessage : String;
begin
  stSource  := Trim(Copy(stData, 1, 3));
  stTarget  := Trim(Copy(stData, 4, 5));
  cType    := Trim(Copy(stData, 9, 1));

       if cType = '0' then stType := 'Etc'
  else if cType = '1' then stType := 'Error'
  else if cType = '2' then stType := 'Debug'
  else if cType = '3' then stType := 'Work'
  else if cType = '4' then stType := 'Log'
  else                     stType := '?????';

  if (cType = '2') and (not FServerDebugLog) then Exit;

  Inc(FLogCount);
  stMessage := Format('%05d: %s', [FLogCount,
                                   Trim(Copy(stData, 10, POLL_MESSAGE_SIZE))]);
  gLog.Add(lkWarning, stSource, stType, stMessage );
end;

end.
