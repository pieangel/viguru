unit CleQuoteUDPThread;

interface

uses
  Windows, Classes, SysUtils, Messages,  WinSock, SyncObjs, DateUtils, GleTypes,
  mmsystem;

const
  WM_ASYNCSELECT = WM_USER + $0001;
  MAX_UDP_PORT_COUNT =  12;

type

  ip_mreq = record
    imr_multiaddr: TInAddr;
    imr_interface: TInAddr;
  end;

  TSocketUnit  = class
  private
    FUdpSocket: TSocket;
    join_addr: ip_mreq;
    FHandle: HWnd;
    iOptValue: Integer;
    serv_addr: TSockAddr;
    function GetHandle: HWnd;

    procedure WndProc(var Message: TMessage);
    procedure AnalysisDataPacket;
    procedure WMASyncSelect(var msg: TMessage); message WM_ASYNCSELECT;
  public
    FAddr      : string;
    FMarket    : string;
    FPort      : integer;
    FIndex    : integer;
    FMultiCast: boolean;
    m_RcvCnt  : LongWord;
    CalcTime  : integer;

    MaxCount  : integer;
    RevCount  : integer;
    NowCount  : integer;
    DoCount   : boolean;
    Constructor Create;
    Destructor Destroy; override;
    procedure init( Index, Port : integer; bMulti : boolean; Addr : string = '');
    procedure CalcCount;

    procedure UdpSocketOpen;
    procedure UdpSocketClose;
    property FR_Handle: HWnd read GetHandle;
  end;


  TUdpSocketThread = class(TThread)
  private
    { Private declarations }
    FWaitTime: integer;
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }

    FUDPs: array of TSocketUnit;
    FEvent: TEvent;
    PortCount : integer;
    constructor Create( iCount : integer );
    destructor Destroy; override;


    property WaitTime : integer read FWaitTime write FWaitTime;
    procedure AllSocketClose(bAll: boolean; index: integer = 0);
    procedure ReCreateSocket;

    procedure UdpSocketClose; overload;
    procedure UdpSocketClose( index : integer ) ; overload;
    procedure UdpSocketOpen( index : integer ); overload;
    procedure UdpSocketOpen; overload;
    procedure init;
    procedure DoCount( bStart : boolean );
  end;

implementation

uses CleKrxQuoteUDPReceiver, GAppEnv;

var wVersionRequested : word;
    WSAData: TWSAData;
{ TUdpSocketThread }


constructor TUdpSocketThread.Create( iCount : integer );
var
  i : integer;
begin
  FEvent := TEvent.Create(nil, False, False, '');
  PortCount := iCount;
  SetLength( FUdps, PortCount );
  for i := 0 to PortCount - 1 do
    FUDPs[i] := TSocketUnit.Create;

  FWaitTime := 1;
  FreeOnTerminate := True;
  inherited Create(true);
end;

destructor TUdpSocketThread.Destroy;
begin
  FEvent.Free;
  //DeallocateHWnd(FHandle);
  //FEvent.Free;
end;



procedure TUdpSocketThread.DoCount(bStart: boolean);
var
  i : integer;
begin
  if bStart then
  begin
    for i := 0 to PortCount - 1 do
    begin
      FUdps[i].CalcTime := timeGetTime;
      FUdps[i].MaxCount := 0;
      FUdps[i].NowCount := 0;
    end;
  end ;
  
  for i := 0 to PortCount - 1 do
  begin
    FUdps[i].DoCount  := bStart;
  end;
end;

procedure TUdpSocketThread.ReCreateSocket;
var
  i : integer;
begin
  for i := 0 to PortCount - 1 do
    if FUDps[i] = nil then    
      FUDPs[i] := TSocketUnit.Create;
end;

procedure TUdpSocketThread.UdpSocketClose(index: integer);
begin
  FUdps[index].UdpSocketClose;
end;

procedure TUdpSocketThread.UdpSocketOpen;
var
  i : integer;
begin
  for i := 0 to PortCount - 1 do
    FUdps[i].UdpSocketOpen;
end;

procedure TUdpSocketThread.UdpSocketClose;
var
  i : integer;
begin
  for i := 0 to PortCount - 1 do
    FUdps[i].UdpSocketClose;
end;

procedure TUdpSocketThread.AllSocketClose( bAll : boolean;  index : integer );
var
  i : integer;
begin
  if bAll then
  begin
    UdpSocketClose;
    for i := 0 to PortCount - 1 do
    begin
      FUDPs[i].Free;
      FUDPs[i] := nil;
    end;
  end
  else begin
    FUDPs[0].UdpSocketClose;
    FUDPs[0].Free;
    FUDPs[0] := nil;
  end;
end;


procedure TUdpSocketThread.Execute;
var
  i : integer;
begin
  while not Terminated do begin
    WaitForSingleObject(Handle, FWaitTime) ;

    for i := 0 to PortCount - 1 do
      FUDPs[i].AnalysisDataPacket;

    //FEvent.WaitFor(FWaitTime);
    //AnalysisDataPacket;
    {
    if not(FEvent.WaitFor(INFINITE) in [wrSignaled]) then
      Continue;
    AnalysisDataPacket;
    }
    //Synchronize( AnalysisDataPacket );
    //Synchronize( syncProc );
  end;
end;

procedure TUdpSocketThread.init;
var
  i : integer;
begin
  for i := 0 to PortCount - 1 do
    FUdps[i].init( i, gEnv.UdpPort[i].Port, true,
      gEnv.UdpPort[i].MultiIP );
end;

procedure TUdpSocketThread.UdpSocketOpen(index: integer);
begin
  FUdps[index].UdpSocketOpen;
end;

{ TSocketUnit }

procedure TSocketUnit.AnalysisDataPacket;
var
  iRet: Integer;
  buf: array[0..(1024*128)-1] of Char;
  stLog, stData: String;
begin

  iRet := recv(FUdpSocket, buf[0], SizeOf(buf), 0);
  if iRet < 0 then
    Exit;

  if DoCount then
    CalcCount;

  if gThread <> nil then
    if fMulticast then
      gThread.PushQueue( iRet, PChar(@buf[1]) )
    else begin
      gThread.PushQueue( iRet, PChar(@buf) );
      {
      if FPort = 5516 then
      begin
        SetString( stLog, buf+2, 7 );
        gEnv.DoLog( WIN_QUOTE, Format( '%s : %s', [
           FormatDateTime('nn:ss:zzz', now),  stLog ]));
      end;
      }
    end;
end;

procedure TSocketUnit.CalcCount;
var
  iMax, iNow, iTmp : integer;

begin

  iTmp  :=  timeGetTime;

  if iTmp - CalcTime > 1000 then
  begin
    if RevCount > MaxCount then MaxCount := RevCount;
    NowCount  := RevCount;
    RevCount  := 0;
    CalcTime  := timeGetTime;
  end
  else
    inc( RevCount );

end;

constructor TSocketUnit.Create;
begin

  FAddr := '';
  FPort := 0;
  FIndex := -1;
  FMultiCast := false;
  m_RcvCnt := 0;

  CalcTime  :=-1;
  MaxCount  := -1;

  DoCount   := false;

  RevCount  := 0;
  NowCount  := 0;
  CalcTime  := timeGetTime;
end;

destructor TSocketUnit.Destroy;
begin
  DeallocateHWnd( FR_Handle );
  inherited;
end;

function TSocketUnit.GetHandle: HWnd;
begin
  if FHandle = 0 then
    FHandle := AllocateHwnd(WndProc);
  Result := FHandle;
end;

procedure TSocketUnit.init(Index, Port: integer; bMulti: boolean; Addr: string);
begin
  FPort := Port;
  FIndex:= Index;
  FMultiCast  := bMulti;
  FAddr := Addr;

  UdpSocketOpen;
end;


procedure TSocketUnit.UdpSocketClose;
begin
  WSAASyncSelect(FUdpSocket , FR_Handle, WM_ASYNCSELECT, 0);
  closesocket(FUdpSocket);
end;

procedure TSocketUnit.UdpSocketOpen;
begin
  FUdpSocket := socket(PF_INET, SOCK_DGRAM, 0);
  if (FUdpSocket = INVALID_SOCKET) then
    raise Exception.Create('Socket Create Error!! ' + IntToStr(WSAGetLastError));

  iOptValue := 1;
  if (setsockopt(FUdpSocket, SOL_SOCKET, SO_REUSEADDR, PChar(@iOptValue), SizeOf(iOptValue)) = SOCKET_ERROR) then
    raise Exception.Create('setsockopt SO_REUSEADDR Error!! ' + IntToStr(WSAGetLastError));

  serv_addr.sin_family := AF_INET;
  serv_addr.sin_addr.S_addr := htonl(INADDR_ANY);
  serv_addr.sin_port := htons(FPort);



  // Multicast UDP socket
  if FMultiCast then begin
    join_addr.imr_multiaddr.S_addr := inet_addr(PChar(FAddr));
    join_addr.imr_interface.S_addr := inet_addr(PChar( gEnv.ConConfig.SisAddr ));//INADDR_ANY;
    if (setsockopt(FUdpSocket, IPPROTO_IP, IP_ADD_MEMBERSHIP, PChar(@join_addr), SizeOf(join_addr)) = SOCKET_ERROR) then
      raise Exception.Create('setsockopt IP_ADD_MEMBERSHIP Error!! ' + IntToStr(WSAGetLastError));
  end;

  if (bind(FUdpSocket, serv_addr, SizeOf(serv_addr)) = INVALID_SOCKET) then
    raise Exception.Create('Socket bind Error!! ' + IntToStr(WSAGetLastError));

  iOptValue := 1024 * 128;
  if (setsockopt(FUdpSocket, SOL_SOCKET, SO_RCVBUF, PChar(@iOptValue), SizeOf(iOptValue)) = SOCKET_ERROR) then
     raise Exception.Create('setsockopt SO_RCVBUF Error!! ' + IntToStr(WSAGetLastError));

  if (WSAASyncSelect(FUdpSocket, FR_Handle, WM_ASYNCSELECT, FD_READ) <> 0) then begin
    closesocket(FUdpSocket);
    WSACleanup;
    raise Exception.Create('WSAASyncSelect() Error!!   ' + IntToStr( WSAGetLastError ));
  end;
end;

procedure TSocketUnit.WMASyncSelect(var msg: TMessage);
var
  buf: array[0..(1024*128)-1] of Char;
  stData: String;
begin
  case LoWord(msg.lParam) of
    FD_READ:
    begin
      inc(m_RcvCnt);
      if gEnv.Switch <> nil then
      begin
        if not gEnv.Switch.QuoteNodes.Nodes( 0, 0 ).OnOff then begin
          recv(FUdpSocket, buf[0], SizeOf(buf), 0);
          Exit;
        end;
        gEnv.Switch.QuoteNodes.Nodes( 0, 0 ).CalcDelayTime(0);
      end;

      //FEvent.SetEvent;
      //AnalysisDataPacket;
    end;
    FD_CLOSE:
    begin
      UdpSocketClose;
    end;
  end;
end;

procedure TSocketUnit.WndProc(var Message: TMessage);
begin
  try
  Dispatch(Message);
  except
  end;
end;

initialization

  wVersionRequested := MAKEWORD(2,2); //Load Winsock 2.2 Dll
  if (WSAStartup(wVersionRequested, WSAData) <> 0) then
    raise Exception.Create('WSAStartup() Error!!');

finalization

  WSACleanUp;

end.
