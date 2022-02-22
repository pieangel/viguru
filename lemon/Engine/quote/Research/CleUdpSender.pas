unit CleUdpSender;

interface

uses
  Classes, IdUDPClient, windows, syncobjs, IdGlobal, SynthUtil, SysUtils,
  KospiPacket, CleOrders, UUdpPacket;

type

  TUdpSender = class(TThread)
  private
    FEvent: TEvent;
    FUdpSocket : TIdUDPClient;
    FData : PUdpOrdDuration;
    procedure SendData( stData : string );
  protected
    procedure Execute ; override;
  public
    FMutex   : HWND;
    FQueue        : TList;
    constructor Create;
    destructor Destroy;override;

    procedure MakeUdpPacket( aOrder : TOrder );
    function PopQueue: PUdpOrdDuration;
    procedure SetConfig( stIP : string; iPort : integer);
  end;

implementation
uses
  GAppEnv;

{ TUdpSender }

constructor TUdpSender.Create;
begin
  FreeOnTerminate := True;
  FEvent  := TEvent.Create( nil, False, False, '');
  FMutex := CreateMutex( nil, False, PChar('UdpSender') );
  FQueue := TList.Create;
  inherited Create( true );
  Priority  := tpLower;
  FEvent.SetEvent;
  Resume;
end;

destructor TUdpSender.Destroy;
var
  i : integer;
begin
  FQueue.Free;
  CloseHandle(FMutex);
  FEvent.Free;
  FUdpSocket.Free;
  inherited;
end;

procedure TUdpSender.Execute;
var
  stData : string;
begin
  while not Terminated do
  begin
    if not(FEvent.WaitFor(INFINITE) in [wrSignaled]) then  Continue;
    while FQueue.Count > 0 do
    begin
      FData := PopQueue;
      if FData <> nil then
      begin
        SetString( stData, PChar(@FData.DataType[0]), LenOrdDuration );
        SendData( stData );
        Sleep(10);
        Dispose(FData);
      end;
    end;
  end;
end;

procedure TUdpSender.MakeUdpPacket(aOrder: TOrder);
var
  i : integer;
  stData, stTmp : string;
  pData : PUdpOrdDuration;
  dSpend : DWORD;
begin
  if aOrder = nil then exit;
  New(pData);
  MovePacket('DURA', pData.DataType );
  stTmp := FormatDateTime('hhnnsszzz', aOrder.SentTime);
  MovePacket(stTmp, pData.OrdSendTime);
  dSpend := aOrder.FAcptTimeHR - aOrder.FSentTimeHR;
  MovePacket( Format('%5.5d', [dSpend]) , pData.DuraTime );
  MovePacket( Format('%2.2s', [gEnv.ConConfig.UserID]) , pData.UserID );
  MovePacket( Format('%12.12s', [aOrder.Symbol.Code]) , pData.SymbolCode );
  MovePacket( Format('%12.12s', [aOrder.Account.Code]) , pData.AccountCode );
  MovePacket( Format('%10.10d', [aOrder.OrderNo]) , pData.OrderNo );
  case aOrder.OrderType of
    otNormal: pData.OrderType := '0';
    otChange: pData.OrderType := '1';
    otCancel: pData.OrderType := '2';
  end;

  WaitForSingleObject(FMutex, INFINITE);
  FQueue.Add(pData);
  ReleaseMutex(FMutex);
  FEvent.SetEvent;
end;

function TUdpSender.PopQueue: PUdpOrdDuration;
begin
  WaitForSingleObject(FMutex, INFINITE);
  Result := PUdpOrdDuration(FQueue.Items[0]);
  FQueue.Delete(0);
  ReleaseMutex(FMutex);
end;

procedure TUdpSender.SendData( stData : string);
var
  i : integer;
  stLog : string;
begin
  try
    if FUdpSocket.Port = -1 then exit;
    FUdpSocket.SendBuffer(ToBytes(stData));
  except
    On E:Exception do
    begin
      stLog := Format('UdpSender SendData => %s',[E.Message]);
      gEnv.EnvLog(WIN_ERR, stLog);
    end;
  end;
end;

procedure TUdpSender.SetConfig(stIP: string; iPort : integer);
begin
  FUdpSocket := TIdUDPClient.Create;
  FUdpSocket.Host := stIP;
  FUdpSocket.Port := iPort;
  FUdpSocket.BroadcastEnabled := true;
end;

end.
