unit CleTradeSM;

interface

//{$define MzMemArea }
{$define SMMemArea }

uses
  Classes, SysUtils, ScktComp, WinSock,

  CleTradeIF, NextGenKospiPacket,

  GleConsts, GleTypes, GleLib, SynthUtil

  ;

type

  TSMSocketThread = class( TSocketThread )
  private  {
    FSocketState: TSocketState;
    procedure OnSocketState(ssValue: TSocketState);  }
  public
    procedure initSocket(stType :  string); override;
    procedure initCommonHeader; override;

    function MakeFEPCommonHead( iSize : integer;
      stDataCnt : string ) : TCommonHead;  overload; override;
    function MakeFEPCommonHead( cType : char;
      stDataCnt : string ) : TCommonHead;  overload; override;


    procedure ProcessTradePacket(szPacket: PChar; iSize: Integer;
      iSockDiv : integer);override;

    procedure SendLink; override;

    function SendTrade(iSize, iCount, iSeq: integer;
      stPacket: string): boolean; override;

    procedure OnConnect(Sender: TObject; aSocket: TCustomWinSocket) ; override;
    procedure OnRead(Sender: TObject; aSocket: TCustomWinSocket) ;    override;

   // property SocketState : TSocketState read FSocketState write OnSocketState;
  end;

implementation

uses
  GAppEnv, CleKRXTradeReceiver;

{ TSMSocketThread }


procedure TSMSocketThread.initCommonHeader;
begin

  case SockDiv of
    SEND_SOCK : ConType := DATA;
    RECV_SOCK : ConType := LINK;
    FILL_SOCK : ConType := LINK;
  end;

{$ifdef SMMemArea}
  FillChar( CommonHead, LenCommonHead, ' ' );
  MovePacket( ConType , CommonHead.TrCode );
  MovePacket( ApType, CommonHead.FepCode );
  MovePacket( Format('%9.9d', [ FFepSn ] ), CommonHead.SeqNo );
{$endif}

end;

procedure TSMSocketThread.SendLink;
var iSize, iHeadSize : integer;
  pComHead : TCommonHead;
  Buffer: array of Char ;
begin
  // 92;..
  pComHead := MakeFEPCommonHead( LenCommonHead, ConType );

  SetLength(Buffer, LenCommonHead );
  Move(pComHead, Buffer[0], LenCommonHead);
  PushQueue( TYPE_SEND, LenCommonHead, @Buffer[0]);
end;

function TSMSocketThread.SendTrade(iSize, iCount, iSeq: integer;
  stPacket: string): boolean;
var
  iTotSize : integer;
  pComHead : TCommonHead;
  Buffer   : array of char;
begin
  inc(FFepSn);
  iTotSize := LenCommonHead + iSize  ;

  pComHead := MakeFEPCommonHead( iTotSize, DATA );

  SetLength(Buffer, iTotSize );
  Move(pComHead, Buffer[0], LenCommonHead);
  Move(stPacket[1], Buffer[LenCommonHead], iSize);
  PushQueue( TYPE_SEND, iTotSize, @Buffer[0]);
end;

function TSMSocketThread.MakeFEPCommonHead(iSize: integer;
  stDataCnt: string): TCommonHead;
begin
{$ifdef SMMemArea}
  Result := CommonHead;
  //MovePacket( Format('%2.2d', [iSize-2]),  Result.stSize );
  Move( iSize , Result.stSize, 2 );
  MovePacket( stDataCnt, Result.TrCode );
  MovePacket( Format('%9.9d', [ FFepSn ] ), Result.SeqNo );
{$endif}
end;

procedure TSMSocketThread.initSocket(stType: string);
begin
  ApType := stType;
  initCommonHeader;
end;

function TSMSocketThread.MakeFEPCommonHead(cType: char;
  stDataCnt: string): TCommonHead;
begin

end;


procedure TSMSocketThread.OnConnect(Sender: TObject; aSocket: TCustomWinSocket);
var
  bNodelay : boolean;
  iRes : integer;
begin

  bNodelay := true;
  iRes  := setsockopt(Socket.Socket.SocketHandle, IPPROTO_TCP, TCP_NODELAY,
    PChar(@bNodelay), SizeOf(bNodelay));

  if iRes = SOCKET_ERROR then
    raise Exception.Create('setsockopt TCP_NODELAY Error!! ' + IntToStr(WSAGetLastError));

 // iRes := SetSockOpt(Socket.Socket.SocketHandle, SO_KEEPALIVE, &Val,sizeof(int))

  RcvCnt := 0;
  FillChar(FRcvBuf, FILL_BUF_SIZE, #0);
  //OnSocketState(ssConnected);

end;

procedure TSMSocketThread.OnRead(Sender: TObject; aSocket: TCustomWinSocket);
var
  RcvBuffer: array[0..FILL_BUF_SIZE - 1] of Char;
  iRcvSize, iPacketLength, iFree, iStart, iHeadSize, iError: Integer;
  pComHead : PCommonHead;
  stSize   : String;
  stTmp, stTest, stPacket    : string;
  cSTXType : char;

  vPacket : PStReceptPacket;
  ivar, iCookie : integer;
begin

  iFree := FILL_BUF_SIZE - RcvCnt;
  iRcvSize := aSocket.ReceiveBuf( FRcvBuf[RcvCnt], iFree );

 // if (gEnv.BPacket) and ( iRcvSize > HEADLENGTH2 ) then begin

    stPacket := Format('RECV[%d]:%s , %d,%d',[ SockDiv, FRcvBuf , RcvCnt, iRcvSize]);
    gEnv.EnvLog( WIN_PACKET, stPacket);
 {
  end
  else if (gEnv.BPacket) and ( iRcvSize <= HEADLENGTH2 ) then begin
    stPacket := Format('RECV[%d]:%s , %d,%d',[ SockDiv, FRcvBuf , RcvCnt, iRcvSize]);
    gEnv.DoLog( WIN_LINK, stPacket);
  end;
  }
  RcvCnt := RcvCnt + iRcvSize;
  iStart := 0;

  try

    while RcvCnt >= HEADLENGTH2 do begin
      pComHead := PCommonHead(@FRcvBuf[iStart]);
      {$ifdef MzMemArea}
        SetString( stSize, pComHead^.CommonSize, sizeof(pComHead^.CommonSize) );
        iPacketLength := StrToIntDef(stSize,0);
      {$endif}
      {$ifdef SMMemArea}
        Move( pComHead^.stSize, iPacketLength, 2 );
      {$endif}

      iPacketLength := iPacketLength + 2;

      if iPacketLength > RcvCnt then break;

      FillChar(RcvBuffer, iPacketLength, #0);
      Move(FRcvBuf[iStart], RcvBuffer[0], iPacketLength );

      PushQueue(TYPE_RECEIVE, iPacketLength, @RcvBuffer[0]);
      {
      stPacket := Format('RECV[%d]:%s , %d,%d',[ SockDiv, RcvBuffer , RcvCnt, iRcvSize]);
      gEnv.EnvLog( WIN_LINK, stPacket);
      }
      Inc(iStart, iPacketLength );
      RcvCnt  := RcvCnt - iPacketLength;
    end;

  Except
    on E : Exception do begin
      stTest := Format('%s', [ FRcvBuf ]);
      gLog.Add( lkError, 'TSocketThread', 'OnRead',
        Format( 'RcvCnt : %d iPacketLength : %d iStart : %d %d  %s', [RcvCnt,  iPacketLength, iStart, iFree,
        stTest]) );
    end;
  end;

  Move(FRcvBuf[iStart], FRcvBuf[0], RcvCnt);
  FillChar(FRcvBuf[RcvCnt], FILL_BUF_SIZE - RcvCnt, #0);

end;
               {
procedure TSMSocketThread.OnSocketState(ssValue: TSocketState);
var stTmp : string;
begin
  SocketState := ssValue;
  case ssValue of
    ssClosed:
      begin
        inc( FCount );

        case SockDiv of
          SEND_SOCK: ConType := DATA;
          RECV_SOCK: ConType := LINK;
          FILL_SOCK: ConType := LINK;
        end;

        gLog.Add( lkError, 'TSocketThread','OnSocketState','Order DisConnect', nil, true );
        gEnv.DoLog( WIN_LINK, Format('Socket Close[%d]', [ SockDiv]));
        if SockDiv <> SOCK_RE then
        begin
          gEnv.ShowMsg( WIN_ERR, 'Order DisConnect : '+IntToStr( SockDiv ), false );
          gEnv.SetSocketState( 'DisConnected '+IntToStr( SockDiv ) + '!!');
        end;

        if (SockDiv = SOCK_RE) and (gReceiver.FAcptSN = -1) then
        begin
          //ShowMessage( 'RECOVERY Failed' );
          //Application.Terminate;
        end;
      end;
    ssConnectPend: ;
    ssConnected:
      begin
        gEnv.SetSocketState( 'Connected');
        if SockDiv <> SEND_SOCK then
          SendLink;
        {
        if FILL_SOCK = SockDiv then
        begin
          if gEnv.RunMode = rtRealTrading then
            gEnv.SetAppStatus( asRecoveryEnd );
        end;
        }
        {
      end;
    ssLoginPend: ;
    ssRecovering: ;
    ssOpen:
      if gEnv.RunMode = rtRealTrading then
        gEnv.SetAppStatus( asRecoveryEnd );
  end;


end;
      }
procedure TSMSocketThread.ProcessTradePacket(szPacket: PChar; iSize,
  iSockDiv: integer);
var
  i, iDataCnt, iTotDataSize, iDataSize, SeqNo, iStart, iResponse,
    iResponse2, iLocalNo : Integer;
  stTime, stReject, stText, stResCode, stMsgCode, stData : String;
  pHeader : PStReceptPacket;
  pRecover : PRecovery;
  stApType, stTmp, stMarket, stLog, stID, stDataCnt, stAcptSN  : string;
begin
{$ifdef SMMemArea}

  pHeader := @szPacket[0];

  SetString( stData, pHeader.stCommonHead.TrCode, Sizeof( pHeader.stCommonHead.TrCode ));
  SetString( stResCode, pHeader.stCommonHead.Response, Sizeof( pHeader.stCommonHead.Response ));
  iResponse := StrToIntDef( stResCode , 0 );
  SetString( stAcptSn, pHeader.stCommonHead.SeqNo, sizeof( pHeader.stCommonHead.SeqNo ));
  SeqNo := StrToInt( stAcptSn );

  if stData = DATA then
  begin
    if SockDiv = SEND_SOCK then
      if iResponse <> 0 then begin
        iLocalNo := StrToInt( string( pHeader.stUnionPak.StKseAcpt.MemArea.LocalNo ));
        gReceiver.OnSrvAccept( iLocalNo, iResponse);
        Exit;
      end;

    iDataSize :=  iSize - LenCommonHead ;
    SetString( stTmp, szPacket+ ( LenCommonHead  ),  iDataSize );

    stMsgCode := '';
    stTime    := '';
    gReceiver.DataReceived(stTmp, stTime, stResCode, stMsgCode);

  end else
  if stData = 'LIOK' then
  begin
    FFepSn := SeqNo;
    ConType:= RESN;

    if (iResponse = 0) then
      SendLink
    else begin
      stTmp := Format( '%s faill : %d, %d', [ stDataCnt, SockDiv, iResponse ] );
      gLog.Add( lkError,'TSMSocketThread','ProcessTradePacket', stTmp );
      SocketDisconnect;
    end;
  end else
  if stData = REOK then
  begin
    OnSocketState( ssOpen );
  end;
{$endif}

end;

end.
