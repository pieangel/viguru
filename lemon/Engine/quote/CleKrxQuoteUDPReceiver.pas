unit CleKrxQuoteUDPReceiver;

interface

uses
  Classes, SysUtils, Windows, IniFiles, mmsystem, Dialogs, WinSock, IdGlobal,

  IdUDPServer, IdSocketHandle,
    // lemon
  LemonEngine,
  GleTypes, {CleQuoteUDPThread,} KospiPacket, SyncObjs,
  CleKrxQuoteParser;

const
  RT_BUF_SIZE = 4096;
  MAX_UDP_PORT_COUNT =  12;
  MultiCast_Port = 18000;
  UDP_Port = 50000;

type


  PUdpData = ^TUdpData;
  TUdpData = record
    Data: string;
  end; 

  ip_mreq = record
    imr_multiaddr: TInAddr;
    imr_interface: TInAddr;
  end;

  TIdSocketUnit  = class
  public

    FUdpSocket : TIdUDPServer;
    join_addr: ip_mreq;
    FAddr      : string;
    FMarket    : string;
    FPort      : integer;
    FIndex    : integer;
    FName     : string;
    FMultiCast: boolean;
    m_RcvCnt  : LongWord;
    CalcTime  : integer;

    MaxCount  : integer;
    RevCount  : integer;
    NowCount  : integer;
    DoCount   : boolean;

    TmpActive : boolean;
    Constructor Create;
    Destructor  Destroy; override;
    procedure init( Index : integer);
    procedure CalcCount;
  end;

  TIdUdpSocket = class
  public

    FUDPs: array of TIdSocketUnit;
    FEvent: TEvent;
    PortCount : integer;
    constructor Create( iCount : integer );
    destructor Destroy; override;

    procedure init();
    procedure initSimul();
    procedure DoInit;

    procedure DoCount(bStart: boolean);
    procedure DoActive( bActive : boolean; bFree : boolean = false); overload;
    procedure DoActive( bActive : boolean; index : integer ); overload;
    procedure DoStockActive( bActive : boolean ); overload;
  end;


  TUdpThread = class( TThread )
  private
    FEvent  : TEvent;
    FMutex  : HWND;
    FData   : PUdpData;

    FQueue  : TList;
    FParser : TKrxQuoteParser;
  protected
    procedure Execute; override;
    procedure SyncProc;
  public
    constructor Create( aParser: TKrxQuoteParser);
    destructor Destroy; override;

    procedure PushData( stData : string );
    function  PopData : PUdpData;

    procedure Fin;
  end;


  TKRXQuoteUDPReceiver = class
  private
    FActive: Boolean;
      //
    FEngine: TLemonEngine;
      // UDP sockets
    FSocketCount: Integer;

    FParser: TKrxQuoteParser;
      // reception status
    FPacketCount: Integer;
    FLastPacketTime: DWORD;


    FQueue  : boolean;
    FDoCount: boolean;
    UdpThread : TUdpThread;
      // control
    procedure SetActive(Value: Boolean);
    procedure TransferPacket( Packet : string; iSzie : integer );

    procedure UDPException(Sender: TObject; ABinding: TIdSocketHandle;
      const AMessage: String; const AExceptionClass: TClass);
    procedure DataReceived(Sender: TObject; ABytes: TBytes; ABinding: TIdSocketHandle);
    procedure ScoketOptChange;

  public

    FUDPs: TIdUdpSocket;

    constructor Create;
    destructor Destroy; override;
      //
    procedure Start( bUdp : boolean = false );

      // control
    property Active: Boolean read FActive write SetActive;
      // packet reception status
    property PacketCount: Integer read FPacketCount;
    property LastPacketTime: DWORD read FLastPacketTime;
    property Parser: TKrxQuoteParser read FParser write FParser;

      // Control

    function FindPortIndex(  iPort : integer ): integer; overload;
    function FindPortIndex(  stMarket : string ): integer; overload;
    procedure ControlStockSocket( bStop : boolean ) ;
    function ControlSocket( stMarket : string; bStop : boolean ) : integer;
    procedure ControlStockWaitTime( iWait : Integer ) ;
    procedure ControlDoCount( bStart : boolean; bUbf : boolean );
    procedure ParserVersion;

  end;

implementation

uses Forms, GAppEnv,
  IdStackConsts;

//-------------------< Init/Finl >-----------------------------//

procedure TKRXQuoteUDPReceiver.ControlDoCount(bStart: boolean; bUbf : boolean);
var
  i : Integer;
begin
  FDoCount  := bStart;
  FUDPs.DoCount( bStart );
end;


function TKRXQuoteUDPReceiver.ControlSocket(stMarket: string; bStop: boolean) : integer;
var
  i : integer;
begin
  Result := 0;

  for i := 0 to FUdps.PortCount - 1 do
    if FUdps.FUDPs[i].FMarket = stMarket then
    begin
      if not bStop  then
        FUdps.FUdps[i].FUdpSocket.Active  := bStop
      else begin
        if not FUdps.FUdps[i].FUdpSocket.Active then begin
          FUdps.FUdps[i].init(i);
          FUdps.FUdps[i].FUdpSocket.Active  := bStop;
        end;
      end;

      inc(Result );
    end;

end;

procedure TKRXQuoteUDPReceiver.ControlStockSocket(bStop: boolean);
var
  ivar : integer;
begin
  FUdps.DoStockActive( bStop);
  //
end;

procedure TKRXQuoteUDPReceiver.ControlStockWaitTime(iWait: Integer);
var
  ivar  : integer;
begin  {
  for ivar := 0 to gEnv.UdpPort.PortCnt - 1 do
  begin
    if FUDps[ivar].FPort > 18000 then
      FUDPs[ivar].WaitTime  := iWait;
  end;
  }
end;

constructor TKRXQuoteUDPReceiver.Create;
var i : integer;
begin
  FEngine := gEnv.Engine;;

  FParser := TKrxQuoteParser.Create;

  if FEngine <> nil then begin
    FParser.QuoteBroker := FEngine.QuoteBroker;
  end;

    // initialize
  FActive := False;
  FSocketCount := 0;
  FPacketCount := 0;
  FDoCount     := false;
  FQueue       := false;


  UdpThread    := TUdpThread.Create( FParser );
end;


procedure TKRXQuoteUDPReceiver.DataReceived(Sender: TObject; ABytes: TBytes;
  ABinding: TIdSocketHandle);
var
  stData : String;
  bStock : boolean;
  stTR, stCode, stPacket : String;
  index, iPort, iSeqNo, iElapsedTime : Integer;
begin
  try
    bStock  := false;

    stData := BytesToString(aBytes);

    if UdpThread <> nil then
      UdpThread.PushData( stData );

    //FParser.Parse( stData);

    {
    index := FindPortIndex( ABinding.Port );
    if ( index >= 0) then
    begin
      inc(FUdps.FUdps[index].m_RcvCnt);
      if FUdps.FUdps[index].DoCount then
        FUdps.FUdps[index].CalcCount;
    end;
     }
  except On E:Exception do
    gLog.Add(lkDebug, 'UDP Received', '???? ???? ????', stData);
  end;


end;


destructor TKRXQuoteUDPReceiver.Destroy;
var
  i : Integer;

begin

  UdpThread.Fin;;

  FActive := false;
  FUDps.Free;
  FParser.Free;

  inherited;
end;

function TKRXQuoteUDPReceiver.FindPortIndex(stMarket: string): integer;
var
  i : integer;
begin
  Result := -1;

  for i := 0 to gEnv.UdpPortCount - 1  do
    if gEnv.UdpPort[i].MarketType = stMarket then
    begin
      Result := i;
      Break;
    end;

end;

procedure TKRXQuoteUDPReceiver.ParserVersion;
begin
  if FParser <> nil then
    FParser.Free;

  FParser := TKrxQuoteParser.Create;

  if FEngine <> nil then begin
    FParser.QuoteBroker := FEngine.QuoteBroker;
  end;
end;

function TKRXQuoteUDPReceiver.FindPortIndex(iPort: integer): integer;
var
  i : integer;
begin
  Result := -1;

  for i := 0 to gEnv.UdpPortCount - 1  do
    if gEnv.UdpPort[i].Port = iPort then
    begin
      Result := i;
      Break;
    end;

end;

procedure TKRXQuoteUDPReceiver.ScoketOptChange;
var
  i : integer;
begin
  for i := 0 to FUdps.PortCount - 1 do
  begin
    FUdps.FUDPs[i].TmpActive  := FUdps.FUDPs[i].FUdpSocket.Active;
    FUdps.FUDPs[i].FUdpSocket.Active := false;
    FUdps.FUDPs[i].FUdpSocket.ThreadedEvent := false;
    FUdps.FUDPs[i].FUdpSocket.OnUDPRead := DataReceived;
    FUdps.FUDPs[i].FUdpSocket.Active := FUdps.FUDPs[i].TmpActive;
  end;

end;

procedure TKRXQuoteUDPReceiver.Start( bUdp : boolean );
var
  bMulti  : boolean;
  i: Integer;
begin

  FSocketCount  := 0;

  FUDps := TIdUdpSocket.Create( gEnv.UdpPortCount );
  FUDPs.init;
  for i := 0 to gEnv.UdpPortCount-1 do
  begin
    FUDps.FUDPs[i].FUdpSocket.OnUDPRead :=DataReceived;
    FUDps.FUDPs[i].FUdpSocket.OnUDPException  := UDPException;
    FUDps.FUDPs[i].FUdpSocket.ThreadedEvent := true;
    inc(FSocketCount);

    if (gEnv.Simul) and ( bUdp ) then
      FUDps.FUDPs[i].FUdpSocket.Active := false;

  end;
  FActive := true;

end;


procedure TKRXQuoteUDPReceiver.SetActive(Value : Boolean);
var
  i: Integer;
begin
 { FActive := Value;

  for i:=0 to FSocketCount-1 do
    FUDPs[i].Active := FActive;
    }
end;

procedure TKRXQuoteUDPReceiver.TransferPacket(Packet: string; iSzie: integer);
begin
  if FActive then
    FParser.Parse( Packet );
end;

procedure TKRXQuoteUDPReceiver.UDPException(Sender: TObject;
  ABinding: TIdSocketHandle; const AMessage: String;
  const AExceptionClass: TClass);
begin
  gLog.Add( lkError, 'TKRXQuoteUDPReceiver', 'UDPException', AMessage );
end;


{ TIdUdpSocket }

procedure TIdSocketUnit.CalcCount;
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

constructor TIdSocketUnit.Create;
begin

  FMarket    := '';
  FPort      := 0;
  FIndex    := -1;
  FMultiCast:= false;
  m_RcvCnt  := 0;
  CalcTime  := 0;
  MaxCount  := 0;
  RevCount  := 0;
  DoCount   := false;


end;


destructor TIdSocketUnit.Destroy;
begin
  if FUdpSocket.Active then
    FUdpSocket.Active := false;
  inherited;
end;

procedure TIdSocketUnit.init(Index : integer);
var
  optval : integer;
begin

  try
    FIndex := Index;
    FPort  := gEnv.UdpPort[Index].Port;

    FMultiCast  := gEnv.UdpPort[Index].UseMulti;
    FUdpSocket.DefaultPort := FPort;
    FName       := gEnv.UdpPort[Index].Name;
    FMarket     := gEnv.UdpPort[Index].MarketType;

    optval := 1;
    FUdpSocket.Binding.SetSockOpt(Id_SOL_SOCKET, Id_SO_REUSEADDR, integer(@optval) );

    if setsockopt(FUdpSocket.Binding.Handle, SOL_SOCKET, SO_REUSEADDR, @optval, sizeof(optval)) = SOCKET_ERROR then
      raise Exception.Create('setsockopt SO_REUSEADDR Error!! ' + IntToStr(WSAGetLastError));

    if FMultiCast then begin
      join_addr.imr_multiaddr.S_addr := inet_addr(PChar(gEnv.UdpPort[Index].MultiIP));
      join_addr.imr_interface.S_addr := inet_addr(PChar(gEnv.ConConfig.SisAddr ));//INADDR_ANY;
      if (setsockopt(FUdpSocket.Binding.Handle, IPPROTO_IP, IP_ADD_MEMBERSHIP,
         PChar(@join_addr), SizeOf(join_addr)) = SOCKET_ERROR) then
        raise Exception.Create('setsockopt IP_ADD_MEMBERSHIP Error!! ' + IntToStr(WSAGetLastError));
    end;
    //else if (Port <> 5592) then

    FUdpSocket.Active  := gEnv.UdpPort[Index].Use;

  except
    on E : Exception do
      gLog.Add( lkError, 'TIdSocketUnit', 'init',
        E.Message + '( Port : '+ IntToStr(FPort) + ') , ' + IntToStr(GetLastError) +')' );
  end;

end;


procedure TIdUdpSocket.DoStockActive(bActive: boolean);

var
  i : integer;
begin
  for i := 0 to PortCount - 1 do
  begin
    if not FUdps[i].FMultiCast then Continue;
    if (bActive)  then
      FUdps[i].init(i);
    FUdps[i].FUdpSocket.Active  := bActive;
  end;

end;

{ TIdUdpSocket }

constructor TIdUdpSocket.Create(iCount: integer);
var
  i : Integer;
begin
  PortCount := iCount;
  SetLength( FUdps, PortCount );
  for i := 0 to PortCount - 1 do
  begin
    FUDPs[i]  :=  TIdSocketUnit.Create;
    FUDPs[i].FUdpSocket := TIdUDPServer.Create( nil );
  end;
end;

destructor TIdUdpSocket.Destroy;
var
  i : integer;
begin

  for i := 0 to PortCount - 1 do
    FUdps[i].Free;

  inherited;
end;

procedure TIdUdpSocket.init;
var
  i : integer;
  bMulti : boolean;
  stMsg : string;
begin

  try
    for i := 0 to PortCount - 1 do
      FUdps[i].init( i);
  except
    stMsg := Format('[%d] Binding Error - UDP', [ Fudps[i].FPort ]);
    gLog.Add(lkError, 'TIdUdpSocket', 'init', stMsg );
  end;

end;

procedure TIdUdpSocket.initSimul;
var
  i : integer;
  bMulti : boolean;
begin
{
  for i := 0 to PortCount - 1 do
  begin
    FUdps[i].init( i, 5575, false,
      gEnv.UdpPort.MultiIP );
  end;
 }

end;

procedure TIdUdpSocket.DoActive(bActive: boolean; bFree : boolean);
var
  i : integer;
begin
  for i := 0 to PortCount - 1 do
  begin

    if FUdps[i].FUdpSocket.Active  then
      FUdps[i].FUdpSocket.Active  := bActive;

    if bFree then
      FUdps[i].FUdpSocket.Free;
  end;

end;

procedure TIdUdpSocket.DoActive(bActive: boolean; index: integer);
begin                                        
  FUdps[index].FUdpSocket.Active  := bActive;
end;

procedure TIdUdpSocket.DoCount(bStart: boolean);
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
  end;

  for i := 0 to PortCount - 1 do
  begin
    FUdps[i].DoCount  := bStart;
  end;

end;


procedure TIdUdpSocket.DoInit;
var
  index, i : integer;
begin
  //Exit;
  index := -1;
  for i := 0 to PortCount - 1 do
  begin
    DoActive( gEnv.UdpPort[i].Use, i );
  end;
    {
    if FUdps[i].FPort = 5592 then
    begin
      index := i;
      break;
    end;

  DoStockActive( false );
  if (index >=0) then
    DoActive( false, index );
    }
end;

{ TUdpThread }

constructor TUdpThread.Create( aParser: TKrxQuoteParser );
begin

  FParser := aParser;
  FEvent  := TEvent.Create( nil, False, False, '');
  FMutex  := CreateMuTex( nil, false, '' );
  FQueue  := TList.Create;
  FreeOnTerminate := True;
  inherited Create(true);
  Priority  := tpNormal;
  Resume;
end;

destructor TUdpThread.Destroy;
begin
  FParser := nil;
  FQueue.Free;
  CloseHandle( FMutex );
  FEvent.Free;

  inherited;
end;

procedure TUdpThread.Execute;
begin

  while not Terminated do
  begin

    if not( FEvent.WaitFor( INFINITE ) in [wrSignaled] ) then Continue;

    while FQueue.Count > 0 do begin
      FData := PopData;
      if FData <> nil then begin
        Synchronize( SyncProc );
        Dispose( FData );
      end;

      Application.ProcessMessages;
    end;
  end;
end;

procedure TUdpThread.Fin;
begin            
  Terminate;
  FParser := nil;
end;

function TUdpThread.PopData: PUdpData;
begin
  Result := nil;
  WaitForSingleObject( FMutex, INFINITE );
  Result  := PUdpData( FQueue.Items[0] );
  FQueue.Delete(0);
  ReleaseMutex( FMutex );
end;

procedure TUdpThread.PushData(stData : string);
var
  vData : PUdpData;
begin
  New( vData );
  vData.Data  := stData;
  WaitForSingleObject( FMutex, INFINITE );
  FQueue.Add( vData );
  ReleaseMutex( FMutex );
  FEvent.SetEvent
end;

procedure TUdpThread.SyncProc;
begin
  if ( FParser <> nil ) and ( FData <> nil ) then
  begin
   FParser.Parse( FData.Data );
  end;
end;

end.


