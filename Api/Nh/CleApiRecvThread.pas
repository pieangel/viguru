unit CleApiRecvThread;

interface

uses
  Classes,
  Windows, SyncObjs, SysUtils,

  ApiConsts
  ;

type

  // �ֹ� ��Ŷ
  POrderPacket = ^TOrderPacket;
  // �ֹ� ��Ŷ 
  TOrderPacket = record
    Size  : Integer;
    iDiv  : integer;
    Packet: array of Char;
  end;

  // �̺�Ʈ �Լ�
  TApiRecvEvent = procedure( aPacket : POrderPacket ) of Object;

  // ������ ��ü 
  TApiRecvThread = class(TThread)
  private
    { Private declarations }
    FEvent  : TEvent;
    FMutex  : HWND;
    FQueue  : TList;
    FData   : POrderPacket;
    FOnApiRecvEvent: TApiRecvEvent;
  protected
    procedure Execute; override;
    procedure SyncProc;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PushData( iSize, iDiv : integer;   pData : PChar );
    function  PopData : POrderPacket;

    property OnApiRecvEvent : TApiRecvEvent read FOnApiRecvEvent write FOnApiRecvEvent;
  end;

implementation

uses
  Forms
  ;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TApiRecvThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TApiRecvThread }
// ������ ������ 
constructor TApiRecvThread.Create;
begin

  FEvent  := TEvent.Create( nil, False, False, '');
  FMutex  := CreateMuTex( nil, false, '' );
  FQueue  := TList.Create;
  FreeOnTerminate := True;

  inherited Create(true);
  Priority  := tpNormal;

  FOnApiRecvEvent := nil;

  Resume;
end;

// ������ �ı��� 
destructor TApiRecvThread.Destroy;
begin
  FQueue.Free;
  CloseHandle( FMutex );
  FEvent.Free;
  //inherited;
end;

// ������ ���� �Լ� 
procedure TApiRecvThread.Execute;
begin
  while not Terminated do
  begin

    // ���Ѵ�� ��ٸ�
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

// ť���� ������ ������ 
function TApiRecvThread.PopData: POrderPacket;
begin
  Result := nil;
  WaitForSingleObject( FMutex, INFINITE );
  Result  := POrderPacket( FQueue.Items[0] );
  FQueue.Delete(0);
  ReleaseMutex( FMutex );
end;

// ť�� ������ �ֱ� 
procedure TApiRecvThread.PushData(iSize, iDiv: integer; pData: PChar);
var
  vCommonData: POrderPacket;
begin
  New(vCommonData);
  vCommonData.Size := iSize;
  vCommonData.iDiv := iDiv;
  SetLength(vCommonData.Packet, iSize);
  Move(pData[0], (vCommonData.Packet)[0], iSize);

  WaitForSingleObject(FMutex, INFINITE);
  FQueue.Add(vCommonData);
  ReleaseMutex(FMutex);

  FEvent.SetEvent;
end;

procedure TApiRecvThread.SyncProc;
begin
  if (FData <> nil) and ( not Terminated ) then
    if Assigned( FOnApiRecvEvent ) then
      FOnApiRecvEvent( FData );

end;

end.
