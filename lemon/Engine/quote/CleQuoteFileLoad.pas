unit CleQuoteFileLoad;

interface

uses
  Classes, SysUtils, Dialogs, ExtCtrls,

  GleTypes, UMemoryMapIO, Math
  ;

const
 MAX_PACKET_SIZE = 1200;

type
  TFileLoad = class(TThread)
  private
    FData : string;
    FMapIO  : TMemoryMapIO;
    FMasterTime : TDateTime;

    procedure SetName;
    procedure ReadFile(var index: int64; pData: PChar);
    function IsErrorOccur(iRes: integer; st: string): Boolean;
    procedure syncProc;
  protected
    FOwner  : TObject;

    FileName  : string;
    FMasterLoad : boolean;
    iStep : int64;

    constructor Create( stName : string );
    destructor Destroy; override;
    procedure Execute; override;
  public
    IsLoading : boolean;
  end;

  TQuoteFileLoad = class
  private
    FFileName2, FFileName : string;
    FLoadThread : TFileLoad;
    FPlayDate : TDateTime;
    FTimer  : TTimer;

    procedure Clear;
  public
    Constructor Create( stFileName : string ); overload;
    Destructor  Destroy; override;

    procedure TimerEvent(Sender: TObject);

    procedure Start( aDate : TDateTime );
    procedure OnEndThread(Sender: TObject);
    procedure StopThread;
    property LoadThread : TFileLoad read FLoadThread;
  end;

implementation

uses
  GAppEnv, GleLib, Forms,
  FleKrxQuoteEmulation;

{ TFileLoad }

constructor TFileLoad.Create( stName : string );
begin
  inherited Create(false);

  Priority := tpNormal;
  FreeOnTerminate := false;

  FileName  := stName;
  FMasterLoad := false;

  IsLoading := true;
  FData     := '';
  FMapIO  := TMemoryMapIO.Create;
  FMasterTime := EncodeTime(8,40,0,0);
end;

destructor TFileLoad.Destroy;
begin
  FMapIO.Free;
  inherited;
end;

procedure TFileLoad.Execute;
var
  f : TextFile;  bOK : boolean;
begin
  AssignFile( f, FileName );
  {$I-}
  Reset( f );
  bOK := IsErrorOccur(IOResult, 'Reset');    // 런타임시 IO 에러 체크..
  {$I+}

  if not bOK then
  begin
    CloseFile(f);
    Exit;
  end;

  Try
    While( not Eof(f) ) do
    Begin
      if Terminated then Exit;
      {$I-}
      ReadLn( f, FData );
      if FData = '' then
        Continue;
      bOK := IsErrorOccur(IOResult, 'ReadLn');    // 런타임시 IO 에러 체크..
      {$I+}
      If not bOK then ConTinue;
      //iSize := Length( stData );

      Synchronize( SyncProc );
      //addItem( stData );
      //if FMasterLoad then break;
      Application.ProcessMessages;
    End;

  finally
    CloseFile(f);
    IsLoading := false;
  end;
end;

function TFileLoad.IsErrorOccur(iRes: integer; st: string): Boolean;
begin

  Result := true;

  if iRes <> 0 then begin
    MessageDlg('File IO Error ( '+ st + InttoStr( GetLastError ) +' ) ', mtInformation, [mbOK], 0 );
    Result := false;
  end;
end;

procedure TFileLoad.ReadFile(var index: int64; pData: PChar);
begin


end;

procedure TFileLoad.SetName;
begin

end;

procedure TFileLoad.syncProc;
var
  stTR, stData,stELW : string;
  iStart : integer;
  dtPacket, dtBase : TDateTime;
  i: Integer;

begin
  if FData = '' then
    Exit;
  {
  if gEnv.PacketVer = pv4 then
  begin

    if FData[1] = '(' then
    begin
      iStart := 16;
      dtPacket  := Floor( gEnv.AppDate ) + EnCodeTime( StrToInt(Copy( FData,2,2)),
          StrToInt( Copy(FData, 4,2 )),
          StrToINt( Copy(FDAta, 6,2 )),
          StrToint( Copy(FData, 8,3 )));

      stELW :=  FormatDateTime('hh:nn:ss.zzz',  dtPacket );
      gEnv.OnLog( Self, stELW);

    end else
    begin
      iStart  := 1;
      dtPacket:= Floor(gEnv.AppDate) + EncodeTime( 7,0,0,0 );
    end;
  end else
  begin    }
      // decode packet
    if FData[14] = #02 then
      iStart := 15 // all stock related data
    else
      iStart := 14; // all kospi200 index futures/options data

    dtPacket := Floor(gEnv.AppDate) + EncodeTime(StrToInt(Copy(FData,1,2)),
                          StrToInt(Copy(FData,4,2)),
                          StrToInt(Copy(FData,7,2)),
                          StrToInt(Copy(FData,10,3)));
  //end;



  KRXQuoteEmulationForm.OnTime( self, dtPacket );
  //gSimul.QuoteTime( self, dtPacket );

  stTR := Copy(FData, iStart, 2);
  if (CompareStr(stTR, 'A3') = 0)      // Fill
      or (CompareStr(stTR, 'G7') = 0)  // Fill & Hoga
      or (CompareStr(stTR, 'B6') = 0)  // Hoga
      or (CompareStr(stTR, 'H1') = 0)  // 투자자..
      or (CompareStr(stTR, 'V1') = 0)  // 가격변동폭
  then  begin
    stData := Copy(FData, iStart, MAX_PACKET_SIZE);

    if (not FMasterLoad) and ( Frac(dtPacket) >= Frac(FMasterTime) ) then
    begin
      SusPend;
      KRXQuoteEmulationForm.ImportFOMaster;
      FMasterLoad := true;

      if KRXQuoteEmulationForm.cbOnlyMaster.Checked then
      begin
        resume;
        Terminate;
      end
      else
        KRXQuoteEmulationForm.SetSimulStatus(tsPreSuscribe);
      //gEnv.Engine.QuoteBroker.Timers.Reset( dtPacket );
    end;

    KRXQuoteEmulationForm.OnQuote( Self, stData );

    //aEmul.QuoteReceived( Self, StData );
  end
  else begin

    stTR := Copy(FData, iStart, 5);
    if (CompareStr(stTR, 'A0014') = 0)
        or  (CompareStr(stTR, 'A0034') = 0)
        or (CompareStr(stTR, 'A0015') = 0)
        or (CompareStr(stTR, 'A0011') = 0) then
    begin
      stData := Copy(FData, iStart, MAX_PACKET_SIZE);
      KRXQuoteEmulationForm.AddMaster(0,0, stData ,dtPacket);

      //gSimul.MasterReceived( Self, StData );
    end;

  end;


end;

{ TQuoteFileLoad }

procedure TQuoteFileLoad.Clear;
begin

end;

constructor TQuoteFileLoad.Create( stFileName : string );
begin

  FFileName := stFileName;
  FTimer  :=  TTimer.Create( nil );
  FTimer.Enabled  := false;
  FTimer.Interval := 1000;
  FTimer.OnTimer  := TimerEvent;

end;

destructor TQuoteFileLoad.Destroy;
begin
  FTimer.Enabled := false;;
  inherited;
end;

procedure TQuoteFileLoad.OnEndThread(Sender: TObject);
begin
  FTimer.Enabled  := true;
end;

procedure TQuoteFileLoad.StopThread;
begin
  if FLoadthread <> nil then
  begin
    FLoadthread.Terminate;
    FLoadthread.WaitFor;
    FLoadThread.Free;
    FLoadThread := nil;
  end;
end;

procedure TQuoteFileLoad.TimerEvent(Sender: TObject);
begin
  FTimer.Enabled  := false;
  KRXQuoteEmulationForm.SetSimulStatus( tsEnd );
end;

procedure TQuoteFileLoad.Start(aDate: TDateTime);
var
  stName, stName2, stName3 : string;

begin
  //if FLoadThread.FOwner = nil then Exit;
  //aEmul := FLoadThread.FOwner as TKRXQuoteEmulationForm;

  stName  := FormatDateTime('yyyymmdd_', aDate) + FFileName;
  stName  := gEnv.QuoteDir + '\' + stName;

  gEnv.AppDate  := aDate;

  if not FileExists(stName) then
  begin
    KRXQuoteEmulationForm.SetSimulStatus( tsNoFile );
  end
  else begin
    gEnv.Loader.AddFixedSymbols;
    StopThread;
    FPlayDate   := aDate;
    FLoadThread := TFileLoad.Create( stName );
    FLoadThread.OnTerminate := OnEndThread;
  end;

end;


end.
