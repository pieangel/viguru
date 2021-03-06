unit FleKrxQuoteEmulation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, mmsystem, ExtCtrls, IdBaseComponent, IdComponent, Buttons,
  IdUDPBase, IDGlobal, IdUDPClient, IniFiles, Math, DateUtils,

    // lemon: common
  GleTypes,  KospiPacket,  CleSymbols,  CleFills,  CleQuoteFileLoad,
    // lemon: utilities
  CleParsers, CleStorage, UMemoryMapIO,
    // lemon: imported
  StreamIO;

const
  MAX_BUFFER_SIZE = 1000;
  EMULATION_FEED_DEF_QUOTE_PORT = 5572;
  EMULATION_FEED_DEF_FILL_PORT = 5000;
  MAX_PACKET_SIZE = 1200;  // LSY 2008-03-02
  FORM_WIDTH  = 405;
  IO_WIDTH = 165;
  GAP = 30/(24*60);

  EMUL_ENV = 'emul.lsg';
type
  TEmulationFeedState = (ssNotReady, ssEnded, ssStalled,
                         ssLoading, ssReady, ssMaster, ssImporting, ssPlaying, ssPaused, ssReset);

    { Profile }
  TQuoteProfile = class(TCollectionItem)
  private
    QuoteTime: TDateTime;
    Position: Int64;
  end;

  TQuoteProfiles = class(TCollection)
  private
    FFileSize: Int64;
  public
    constructor Create;

    procedure GenerateProfiles(stFile: String);
    function FindSearchPosition(dtValue: TDateTime): Integer;

    property FileSize: Int64 read FFileSize;
  end;

    { Quote Packet }
  TSavedQuotePacket = class(TCollectionItem)
  private
    LogTime: TDateTime;
    Position: Int64;   // position in file
    PacketStr : String;
    PacketTR  : string;
    PacketTimeStr : string;
    // ?ӽ?
    iStart  : integer;
    iLen    : integer;
  end;

  TSavedQuotePackets = class(TCollection)
  private
      // load related
    LoadPosition: Int64; // loading position in file
      // search related
    SearchPosition: Int64; // position where searching started
    SearchTime: TDateTime;   // used in searching
      // play related
    StartPosition: Int64; // position where packet loading started
    PlayPosition: Int64;  // current position in file while playing
    PlayIndex: Int64;     // item index
    PlayTime: TDateTime;

    function GetPacket(i: Integer): TSavedQuotePacket;
  public
    constructor Create;

    procedure Reset;

    property Packets[i: Integer]: TSavedQuotePacket read GetPacket; default;
  end;

    { Fill Packet }
  TSavedFillPacket = class(TCollectionItem)
  public
    SN  : integer;
    LogTime: TDateTime;
    Market  : string;
    DataType: string;
    PacketStr: String;
    AceptTime: string;
  end;

  TSavedFillPackets = class(TCollection)
  private
    function GetPacket(i: Integer): TSavedFillPacket;
  public
    Test  : boolean;
    FPosition: Integer;
    constructor Create;

    procedure Reset;
    procedure Rewind;

    function Current : TSavedFillPacket;
    function Next(dtMax: TDateTime): TSavedFillPacket;
    function Prev(dtMax: TDateTime): TSavedFillPacket;
    function FindPositon( dtMax : TdateTime ) : TSavedFillPacket;
    procedure LoadFromFile(stFile: String);

    property Packets[i: Integer]: TSavedFillPacket read GetPacket; default;

  end;

    {  Load Thread }
  TQuoteFileLoadThread = class(TThread)
  private
    FFileName: String;
    FPackets: TSavedQuotePackets;
    FStockMaster: TSavedQuotePackets;
    FElwMaster  : TSavedQuotePackets;
    FFOMaster  : TSavedQuotePackets;
    FSFMaster  : TSavedQuotePackets;
    FElwInfoMaster  : TSavedQuotePackets;
    FSettleDayMaster  : TSavedQuotePackets;
    FLoading: Boolean;
  protected
    constructor Create(stFile: String; Packets: TSavedQuotePackets;
    Packets2: array of TSavedQuotePackets);
    procedure Execute; override;
  public
    property Loading: Boolean read FLoading;
  end;

    { Work Form}
  TKRXQuoteEmulationForm = class(TForm)
    DateTimePickerTime: TDateTimePicker;
    PlayTimer: TTimer;
    ButtonPlay: TBitBtn;
    ButtonPause: TBitBtn;
    ButtonStop: TBitBtn;
    ButtonGoto: TBitBtn;
    IdUDPClientQuote: TIdUDPClient;
    LoadTimer: TTimer;
    TrackBar: TTrackBar;
    StatusBar: TStatusBar;
    IdUDPClientFill: TIdUDPClient;
    Panel1: TPanel;
    DateTimePickerDate: TDateTimePicker;
    Label1: TLabel;
    Label4: TLabel;
    EditDays: TEdit;
    ButtonInit: TButton;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    EditTargetHost: TEdit;
    Label3: TLabel;
    EditQuotePort: TEdit;
    Label2: TLabel;
    EditFillPort: TEdit;
    RadioGroupMethod: TRadioGroup;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    EditSpeed: TEdit;
    RadioGroupSource: TRadioGroup;
    cbFillEnabled: TCheckBox;
    gbAccount: TGroupBox;
    udTick: TUpDown;
    edtTick: TEdit;
    ButtonTick: TBitBtn;
    cbUseS5: TCheckBox;
    Label7: TLabel;
    StartDate: TDateTimePicker;
    Label8: TLabel;
    EndDate: TDateTimePicker;
    Button1: TButton;
    lbStats: TLabel;
    Button3: TButton;
    spbSuspend: TSpeedButton;
    ResetTimer: TTimer;
    cbOnlyMaster: TCheckBox;
    edtTitle: TEdit;
    procedure ButtonInitClick(Sender: TObject);
    procedure LoadTimerProc(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonPlayClick(Sender: TObject);
    procedure PlayTimerProc(Sender: TObject);
    procedure ButtonPauseClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonGotoClick(Sender: TObject);
    procedure cbFillEnabledClick(Sender: TObject);

    procedure EditDaysChange(Sender: TObject);
    procedure EditSpeedKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ButtonTickClick(Sender: TObject);
    procedure cbUseS5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure spbSuspendClick(Sender: TObject);
    procedure ResetTimerTimer(Sender: TObject);
  private
      // objects: data
    FQuoteProfiles: TQuoteProfiles;
    FQuotePackets: TSavedQuotePackets;
    FMasterPackets:array of TSavedQuotePackets;

      // objects: threads
    FLoadThread: TQuoteFileLoadThread;

      // target information: assigned
    FQuoteFileDir: String;
    FFillFileDir: String;

      // status
    FPlayDate: TDateTime;
    FEndDate: TDateTime;
    FEndDays: integer;
    FQuoteFile: String;
    FSpeed : Double;
    FState : TEmulationFeedState;
    FPacketStartTime, FStartTime : TDateTime;

      // control flags
    FFillEnabled: Boolean;
    FAllowGoto: Boolean;
    FAllowReverse: Boolean;
    FCme : Boolean;

      // events
    FOnReset: TNotifyEvent;
    FOnLoad: TDateQueryEvent;
    FOnQuote: TTextNotifyEvent;
    FOnMaster:TTextNotifyEvent;
    FOnTime: TTimeNotifyEvent;
    FOnLog: TTextNotifyEvent;
    FOnOrderReset: TOrderResetEvent;
    FMasterLoaded: boolean;
    FReset : boolean;
    FKeyGoto : boolean;
    FTickPlay : boolean;
    FTickSent : integer;

    FQuoteFileLoad: TQuoteFileLoad;
    FSimulStats: TSimulationStatus;
    FToDay: TDateTime;

    FStorage  : TStorage;

    procedure Play;

    procedure Prepare(dtMaster: TDateTime);

    procedure StartLoading(stQuoteFile: String);
    procedure StartThread(stQuoteFile: String);
    procedure StopThread;

    procedure SetButtons(bPlay, bPause, bStop, bGoto: Boolean);

    procedure SetState(ssValue : TEmulationFeedState; stMsg: String = '');
    procedure ShowStatus;
    procedure DoLog(stLog: String);

    procedure ShowData;

    procedure ImportMaster;

    function FindFile( dtPlayDate : TDateTime) : boolean;
    procedure OnSimulationStats(tsType: TSimulationStatus);
    procedure SetStatus(index: integer; value: string);

    procedure ReSet;
    procedure ReSet2;
    procedure PrintData;
  public

    FParser : TStringList;
    FFillPackets: TSavedFillPackets;

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure SetSimulStatus(const Value: TSimulationStatus);
    procedure AddMaster( idx : integer; iSzie : integer; stData : string ; dtTime : TDateTime);
    procedure ImportFOMaster;

      // running environment
    property QuoteFileDir: String read FQuoteFileDir write FQuoteFileDir;
    property FillFileDir: String read FFilLFileDir write FFillFileDir;

    property State : TEmulationFeedState read FState write FState;
      // control flags
    property FillEnabled: Boolean read FFillEnabled write FFillEnabled;
    property AllowGoto: Boolean read FAllowGoto write FAllowGoto;
    property AllowReverse: Boolean read FAllowReverse write FAllowReverse;
    property MasterLoaded: boolean read FMasterLoaded write FMasterLoaded;

      // events
    property OnReset: TNotifyEvent read FOnReset write FOnReset;
    property OnLoad: TDateQueryEvent read FOnLoad write FOnLoad;
    property OnQuote: TTextNotifyEvent read FOnQuote write FOnQuote;
    property OnMaster: TTextNotifyEvent read FOnMaster write FOnMaster;
    property OnTime: TTimeNotifyEvent read FOnTime write FOnTime;
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
    property OnOrderReset  : TOrderResetEvent read FOnOrderReset write FOnOrderReset;

    // USE S5
    property QuoteFileLoad : TQuoteFileLoad read FQuoteFileLoad;
    property SimulStats : TSimulationStatus read FSimulStats write FSimulStats;
    property ToDay      : TDateTime read FToDay write FToday;
  end;

var
  KRXQuoteEmulationForm: TKRXQuoteEmulationForm;

implementation

uses GAppEnv, CleKRXTradeReceiver, CleAccounts, CleFQN, CleQuoteTimers,
CleSimulationConst, GleLib, GAppConsts;

{$R *.DFM}

const
  STATE_TEXTS : array[TEmulationFeedState] of String =
                     ('Not Ready','Ended', 'Stalled',
                      'Loading...', 'Ready', 'MasterImPort', 'MasterLoading..', 'Playing', 'Paused', 'ReSet');

{$REGION ' class TQuoteProfiles '}

{ TQuoteProfiles }

constructor TQuoteProfiles.Create;
begin
  inherited Create(TQuoteProfile);
end;

function TQuoteProfiles.FindSearchPosition(dtValue: TDateTime): Integer;
var
  i: Integer;
  aProfile: TQuoteProfile;
  dtCmeTime : TDateTime;
begin
  Result := 0;
  dtCmeTime := EncodeTime(5,1,0,0);
  if (dtValue >= 0) and (dtValue <= dtCmeTime) then
    dtValue := dtValue + 1;
  for i := 0 to Count - 1 do
  begin
    aProfile := Items[i] as TQuoteProfile;
    if aProfile.QuoteTime > dtValue then Break;

    Result := aProfile.Position;
  end;
end;

procedure TQuoteProfiles.GenerateProfiles(stFile: String);
const
  //SEEK_STEP = 1000000;
  SEEK_STEP = 100000;
  BUF_SIZE = 1000;
var
  stRecord: String;
  iPosition: Int64;
  dtValue, dtCmeTime : TDateTime;
  aProfile: TQuoteProfile;
  F: TextFile;
  S: TFileStream;
begin
  Clear;
  FFileSize := 0;

  if not FileExists(stFile) then Exit;

  S := TFileStream.Create(stFile, fmOpenRead);
  AssignStream(F, S);
  Reset(F);

  // end of the file
  FFileSize := S.Size;
  dtCmeTime := EncodeTime(5,1,0,0);
  try
    while not EOF(F) do
    begin
      S.Seek(SEEK_STEP, soFromCurrent);

        // discard two lines
      Readln(F, stRecord);
      if EOF(F) then Break;
      Readln(F, stRecord);
      if EOF(F) then Break;

      iPosition := S.Position;
      Readln(F, stRecord);

      if Length(stRecord) > 10 then
      begin
        {
        // ?׽?Ʈ ?? ????
        if stRecord[1] = '(' then
        begin
        try
          dtValue  := EnCodeTime( StrToInt(Copy( stRecord,2,2)),
                      StrToInt( Copy(stRecord, 4,2 )),
                      StrToINt( Copy(stRecord, 6,2 )),
                      StrToint( Copy(stRecord, 8,3 )));
          aProfile := Add as TQuoteProfile;
          aProfile.Position := iPosition;
          if (dtValue >= 0) and (dtValue <= dtCmeTime) then
            dtValue := dtValue + 1;
          aProfile.QuoteTime := dtValue;
        except
        end
        end else
        begin
          dtValue  := EnCodeTime( 7,0,0,0);
          aProfile := Add as TQuoteProfile;
          aProfile.Position := iPosition;
          if (dtValue >= 0) and (dtValue <= dtCmeTime) then
            dtValue := dtValue + 1;
          aProfile.QuoteTime := dtValue;
        end;

        // ?׽?Ʈ ?? ????
        }


        if (stRecord[3] = ':') and (stRecord[6] = ':') then
        try
          dtValue := EncodeTime(StrToIntDef(Copy(stRecord,1,2),0),
                                StrToIntDef(Copy(stRecord,4,2),0),
                                StrToIntDef(Copy(stRecord,7,2),0),
                                StrToIntDef(Copy(stRecord,10,3),0));
            //
          aProfile := Add as TQuoteProfile;
          aProfile.Position := iPosition;
          if (dtValue >= 0) and (dtValue <= dtCmeTime) then
            dtValue := dtValue + 1;
          aProfile.QuoteTime := dtValue;
        except
        end;

      end;
    end;
  finally
    CloseFile(F);
    S.Free;
  end;
end;
{$ENDREGION}

{$REGION ' class TSavedQuotePackets '}

{ TSavedQuotePackets }

constructor TSavedQuotePackets.Create;
begin
  inherited Create(TSavedQuotePacket);

  Self.Reset;
end;

function TSavedQuotePackets.GetPacket(i: Integer): TSavedQuotePacket;
var
  stTmp : string;
begin
  try
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSavedQuotePacket
  else
    Result := nil;
  except

    on E : Exception do
    begin
    //  stTmp := Format( 'i:%d, Count:%d %d', [ i, Count,  Count-i]);
    //  ShowMessage( stTmp );
    end;

  end;
end;

procedure TSavedQuotePackets.Reset;
begin
  Clear;

  LoadPosition := 0;
  SearchPosition := 0;
  SearchTime := 0;
  StartPosition := 0;
  PlayPosition := 0;
  PlayIndex := 0;
end;

{$ENDREGION}

{$REGION ' class TSavedFillPackets '}
{ TSavedFillPackets }

constructor TSavedFillPackets.Create;
begin
  inherited Create(TSavedFillPacket);
  Test  := true;
end;

function TSavedFillPackets.Current: TSavedFillPacket;
begin
  if (FPosition >= 0) and (FPosition <= Count-1) then
    Result := Items[FPosition] as TSavedFillPacket
  else
    Result := nil;
end;

function TSavedFillPackets.FindPositon(dtMax: TdateTime): TSavedFillPacket;
var
  i: Integer;
  aFillPacket: TSavedFillPacket;
begin
  Result := nil;
  FPosition := 0;

  for i := 0 to Count - 1 do
  begin
    aFillPacket := Items[i] as TSavedFillPacket;
    if aFillPacket.LogTime > dtMax then Break;

    inc(FPosition );
    //Result := aFillPacket.
  end;

end;

function TSavedFillPackets.GetPacket(i: Integer): TSavedFillPacket;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSavedFillPacket
  else
    Result := nil;
end;

//CA003-1: modified
procedure TSavedFillPackets.LoadFromFile(stFile: String);
const
  FIELD_OFFSET = 12;
var
  F: TextFile;
  stData, stTime: String;
  aPacket: TSavedFillPacket;
  aParser: TParser;
  iCnt  : integer;
begin
  Clear;
  if not FileExists(stFile) then Exit;
  try
    aParser := TParser.Create([#9]);
    AssignFile(F, stFile);
    System.Reset(F);
      // load
    while not Eof(F) do
    begin
        // readln
      Readln(F, stData);
        // decode packet
      iCnt  := aParser.Parse(stData);
      if iCnt in [6..10] then
      begin

        if Count > 0 then
          if (Items[Count-1] as TSavedFillPacket).PacketStr = Copy(aParser[5], 1, Length(aParser[5])-2) then
            Continue;

        aPacket := Add as TSavedFillPacket;

        stTime := Copy(aParser[2],12,12);
        aPacket.LogTime := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                      StrToInt(Copy(stTime,4,2)),
                                      StrToInt(Copy(stTime,7,2)),
                                      StrToInt(Copy(stTime,10,3)));
        aPacket.PacketStr := Copy(aParser[5], 1, Length(aParser[5])-2);
        if iCnt = 6 then
          aPacket.AceptTime := ''
        else
          aPacket.AceptTime := aParser[6];


      end;
    end;
  finally
    aParser.Free;
    CloseFile(F);
  end;
end;


procedure TSavedFillPackets.Reset;
begin
  FPosition := 0;
end;

procedure TSavedFillPackets.Rewind;
begin
  FPosition := 0;
end;

function TSavedFillPackets.Next(dtMax: TDateTime): TSavedFillPacket;
var
  aPacket: TSavedFillPacket;
  stFo, stLog : string;
begin
  Result := nil;

  if FPosition > Count-1 then Exit;

  if FPosition < 0 then FPosition := 0;

  aPacket := GetPacket(FPosition);

  if aPacket.LogTime <= dtMax then
  begin
    Result := aPacket;
    Inc(FPosition);
  end;
end;

function TSavedFillPackets.Prev(dtMax: TDateTime): TSavedFillPacket;
var
  aPacket: TSavedFillPacket;
  stLog : string;
begin
  Result := nil;

  if FPosition < 0 then Exit;

  aPacket := GetPacket(FPosition);

  if aPacket.LogTime >= dtMax then
  begin
    Result := aPacket;
    Dec(FPosition);
    //if FPosition < 0 then
    //  FPosition := 0;
  end;

end;

{$ENDREGION}

{$REGION ' class TQuoteFileLoadThread '}

{ TQuoteFileLoadThread }

constructor TQuoteFileLoadThread.Create(stFile: String;
  Packets: TSavedQuotePackets; Packets2: array of TSavedQuotePackets);
begin
  inherited Create(False);

  Priority := tpNormal;
  FreeOnTerminate := False;

  FFileName := stFile;
  FPackets := Packets;

  FFOMaster  :=  Packets2[0];
  FStockMaster:=  Packets2[1];
  FSettleDayMaster  := Packets2[2];
  FElwMaster  :=  Packets2[3];
  FElwInfoMaster  :=  Packets2[4];
  FSFMaster  :=  Packets2[5];

  FLoading := False;
end;

procedure TQuoteFileLoadThread.Execute;
var
  stData, stTR, stTmp : String;
  aPacket : TSavedQuotePacket;
  F: TextFile;
  S: TFileStream;
  dtPacket: TDateTime;
  dtExtTime : TDateTime;
  dtCmeTime : TDateTime;
  iStart: Integer;
begin
  inherited;
  // set flag
  FLoading := True;
  dtExtTime := GetQuoteDate + EncodeTime(15,16,0,0);
  dtCmeTime := EncodeTime(5,1,0,0);
  S := nil;

  FPackets.StartPosition := 0;
  FPackets.LoadPosition := 0;
  FPackets.PlayPosition := 0;
  
  try
    S := TFileStream.Create(FFileName, fmOpenRead);
    AssignStream(F, S);
    Reset(F);

      // search
    if FPackets.SearchPosition > 0 then
    begin
      S.Seek(FPackets.SearchPosition, soFromBeginning);
      FPackets.LoadPosition := FPackets.SearchPosition;

      while not EOF(F) do
      begin
        if Terminated then Exit;
        
          // readln
        Readln(F, stData);

        if stData = '' then continue;
          // set position value
        FPackets.StartPosition := FPackets.LoadPosition;
        FPackets.LoadPosition := FPackets.LoadPosition + Length(stData);

          // decode packet
        if stData[14] = #02 then
          iStart := 15 // all stock related data
        else
          iStart := 14; // all kospi200 index futures/options data

        if (gEnv.PacketVer = pv1) or (gEnv.PacketVer = pv2) or (gEnv.PacketVer = pv3) or ( gEnv.PacketVer = pv4 ) then
        begin

          // NH ???? ???Ϸ? ?ü?????Ÿ ?׽?Ʈ?Ҷ?..
          if ( gEnv.PacketVer = pv4 ) and ( stData[1] = '(' ) then
            iStart  := 16;

          stTR := Copy(stData, iStart, 2);
          if (CompareStr(stTR, 'A3') = 0)      // Fill
              or (CompareStr(stTR, 'G7') = 0)  // Fill & Hoga
              or (CompareStr(stTR, 'B6') = 0)  // Hoga
              or (CompareStr(stTR, 'B7') = 0)  // Elw Hoga
              or (CompareStr(stTR, 'H1') = 0)  // ????????????
              or (CompareStr(stTR, 'V1') = 0)  // ??????????????
          then
          begin

            if iStart = 16 then

              dtPacket  := EnCodeTime( StrToInt(Copy( stData,2,2)),
                        StrToInt( Copy(stData, 4,2 )),
                        StrToINt( Copy(stData, 6,2 )),
                        StrToint( Copy(stData, 8,3 )))
            else

              dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                  StrToInt(Copy(stData,4,2)),
                                  StrToInt(Copy(stData,7,2)),
                                  StrToInt(Copy(stData,10,3)));

            if (dtPacket >= 0 ) and (dtPacket <= dtCmeTime) then
              dtPacket := dtPacket + 1;
            if dtPacket >= FPackets.SearchTime then
            begin
              aPacket := FPackets.Add as TSavedQuotePacket;
              aPacket.LogTime := Frac(dtPacket);
              aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
              aPacket.Position := FPackets.LoadPosition;
              aPacket.PacketTimeStr := FormatDateTime('hh:nn:ss.zzz', aPacket.LogTime);

              FPackets.PlayPosition := aPacket.Position;
              FPackets.PlayTime := aPacket.LogTime;

              Break;
            end;
          end;
        end
        ///////////////////////////////// pv1
        else begin

          stTR := Copy(stData, iStart, 2);
          if (CompareStr(stTR, 'F1') = 0)      // KOSPI200 Futures Market-Depth & Time-and-sale
              or (CompareStr(stTR, 'O1') = 0)  // KOSPI200 Options Market-Depth & Time-and-sale
              or (CompareStr(stTR, 'I2') = 0)  // KOSPI200 Index
              or (CompareStr(stTR, 'Y2') = 0)  // KOSPI200 Index
              or (CompareStr(stTR, 'L1') = 0)  // KRX Stock Futures
              or (CompareStr(stTR, 'H1') = 0)  // KRX Stock Market-Depth
              or (CompareStr(stTR, 'h3') = 0)  // KRX ELW Market-Depth    // LSY 2008-03-02
              or (CompareStr(stTR, 'HA') = 0)  // Kosdaq Stock Market-Depth
              or (CompareStr(stTR, 'S3') = 0)  // Stock or Elw Time&Sale
              or (CompareStr(stTR, 's3') = 0)  // Stock or Elw Time&Sale
              or (CompareStr(stTR, 'ES') = 0)  // Elw Greeks Time&Sale
          then
          begin
            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                  StrToInt(Copy(stData,4,2)),
                                  StrToInt(Copy(stData,7,2)),
                                  StrToInt(Copy(stData,10,3)));
            if dtPacket >= FPackets.SearchTime then
            begin
              aPacket := FPackets.Add as TSavedQuotePacket;
              aPacket.LogTime := dtPacket;
              aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
              aPacket.Position := FPackets.LoadPosition;

              FPackets.PlayPosition := aPacket.Position;
              FPackets.PlayTime := aPacket.LogTime;

              Break;
            end;
          end;

        end; // if gEnv.
      end;
    end;

      // load
    while not Eof(F) do
    begin
      if Terminated then Exit;

      if FPackets.Count - FPackets.PlayIndex > 100000 then
      begin
        //Suspend;
        Sleep(100);
        Continue;
      end;

        // readln
      Readln(F, stData);
      if stData = '' then continue;

        // decode packet
      if stData[14] = #02 then
        iStart := 15 // all stock related data
      else
        iStart := 14; // all kospi200 index futures/options data

      if (gEnv.PacketVer = pv1) or (gEnv.PacketVer = pv2) or (gEnv.PacketVer = pv3) or ( gEnv.PacketVer = pv4 ) then
      begin
         {
        if gEnv.PacketVer = pv4 then
          if stData[1] = '(' then
            iStart := 16
          else
            iStart := 1;
         }
        stTR := Copy(stData, iStart, 2);
        if (CompareStr(stTR, 'A3') = 0)      // Fill
            or (CompareStr(stTR, 'G7') = 0)  // Fill & Hoga
            or (CompareStr(stTR, 'B6') = 0)  // Hoga
            or (CompareStr(stTR, 'B7') = 0)  // Elw Hoga
            or (CompareStr(stTR, 'C7') = 0)  // Elw Greeks
            or (CompareStr(stTR, 'H1') = 0)  // ????????????
            or (CompareStr(stTR, 'V1') = 0)  // ??????????
        then
        begin   {
          if iStart = 16 then
            dtPacket  := EnCodeTime( StrToInt(Copy( stData,2,2)),
                StrToInt( Copy(stData, 4,2 )),
                StrToINt( Copy(stData, 6,2 )),
                StrToint( Copy(stData, 8,3 )))
          else    }

            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));

          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FPackets.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FPackets.LoadPosition;
            aPacket.PacketTimeStr := FormatDateTime('hh:nn:ss.zzz', aPacket.LogTime);
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;
        FPackets.LoadPosition := FPackets.LoadPosition + Length(stData);
        //
// Master Packet
        stTR := Copy(stData, iStart, 5);
        if (CompareStr(stTR, 'A0011') = 0) then
        begin
          dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));
          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FStockMaster.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FStockMaster.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;
        if (CompareStr(stTR, 'A1011') = 0) then
        begin   {
          if iStart = 1 then
            dtPacket  := EnCodeTime( 7,0,0,0 )
          else     }
            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));

          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FElwMaster.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FElwMaster.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;
        if (CompareStr(stTR, 'I7011') = 0) then
        begin

            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));
          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FElwInfoMaster.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FElwInfoMaster.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;

        if (CompareStr(stTR, 'A0014') = 0)
          or  (CompareStr(stTR, 'A0034') = 0)
        then
        begin

            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));
          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FFOMaster.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FFOMaster.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;

        if (CompareStr(stTR, 'A0015') = 0) then
        begin

            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));
          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FSFMaster.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FSFMaster.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;

        if (CompareStr(stTR, 'I5011') = 0) then
        begin

            dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));
          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FSettleDayMaster.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FSettleDayMaster.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.PacketTR := stTR;
            aPacket.iLen    := Length( stData );
          end;
        end;
        //
      end
      else begin
        stTR := Copy(stData, iStart, 2);

        if (CompareStr(stTR, 'F1') = 0)      // KOSPI200 Futures Market-Depth & Time-and-sale
              or (CompareStr(stTR, 'O1') = 0)  // KOSPI200 Options Market-Depth & Time-and-sale
              or (CompareStr(stTR, 'I2') = 0)  // KOSPI200 Index
              or (CompareStr(stTR, 'L1') = 0)  // KRX Stock Futures
              or (CompareStr(stTR, 'Y2') = 0)  // KOSPI200 Index
              or (CompareStr(stTR, 'H1') = 0)  // KRX Stock Market-Depth
              or (CompareStr(stTR, 'h3') = 0)  // KRX ELW Market-Depth  // LSY 2008-03-02
              or (CompareStr(stTR, 'HA') = 0)  // Kosdaq Stock Market-Depth
              or (CompareStr(stTR, 'S3') = 0)  // Stock Time&Sale
              or (CompareStr(stTR, 's3') = 0)  // Stock or Elw Time&Sale
              or (CompareStr(stTR, 'ES') = 0)  // Elw Greeks Time&Sale
          then
        begin
          dtPacket := EncodeTime(StrToInt(Copy(stData,1,2)),
                                 StrToInt(Copy(stData,4,2)),
                                 StrToInt(Copy(stData,7,2)),
                                 StrToInt(Copy(stData,10,3)));
          stTmp := Copy(stData, iStart, MAX_PACKET_SIZE);
          if stTmp <> '' then
          begin
            aPacket := FPackets.Add as TSavedQuotePacket;
            aPacket.LogTime := dtPacket;
            aPacket.PacketStr := Copy(stData, iStart, MAX_PACKET_SIZE);
            aPacket.Position := FPackets.LoadPosition;
            aPacket.iStart  := iStart;
            aPacket.iLen    := Length( stData );
          end;
        end;
        FPackets.LoadPosition := FPackets.LoadPosition + Length(stData);
      end;      // if gEnv.
    end;
  finally
    CloseFile(F);
    S.Free;

    FLoading := False;
    //on E:Exception do
    //  DoLog( e.Message);
  end;
end;

{$ENDREGION}

//===================================================< TKRXQuoteEmulationForm >

function TKRXQuoteEmulationForm.FindFile(dtPlayDate: TDateTime): boolean;
var
  stQuoteFile, stOrderFile : string;
begin

  Result := false;
  while dtPlayDate <= Date do
  begin
    stQuoteFile := FQuoteFileDir + '\' + FormatDateTime('yyyymmdd', dtPlayDate);
    case RadioGroupSource.ItemIndex of
      0: stQuoteFile := stQuoteFile + '_drvreal.txt';
      1: stQuoteFile := stQuoteFile + '_stkreal.txt';
      2: stQuoteFile := stQuoteFile + '_sssreal.txt';
      3: stQuoteFile := stQuoteFile + '_real.txt';
      else
        Exit;
    end;


    if FileExists(stQuoteFile) then
    begin
      if FFillEnabled then
      begin
        stOrderFile := FFillFileDir + '\' + FormatDateTime('yyyymmdd', dtPlayDate);
        stOrderFile := stOrderFile+'_kospider.txt';
        if not FileExists(stOrderFile) then
          break;
      end;
      FPlayDate := dtPlayDate;
      Dec(FEndDays);
      FQuoteFile := stQuoteFile;
      Result := true;
      Break;
    end else
    begin
      dtPlayDate := dtPlayDate + 1;
    end;
  end;
end;

procedure TKRXQuoteEmulationForm.FormCreate(Sender: TObject);
var
  i :integer;
begin
  KRXQuoteEmulationForm := self;
    // create objects
  FParser := TStringList.Create;
  FStorage:= TStorage.Create;
  FQuotePackets := TSavedQuotePackets.Create;

  SetLength( FMasterPackets, 6);
  for i := 0 to 5 do
    FMasterPackets[i]:= TSavedQuotePackets.Create;


  FQuoteProfiles := TQuoteProfiles.Create;
  FLoadThread := nil;
  FFillPackets := TSavedFillPackets.Create;

    // initialize attributes
  FFillEnabled := False;
  FAllowGoto := True;
  FAllowReverse := True;
  FCme := False;
    //
  SetState(ssNotReady);

    // set minimum timer resolution to 1 millisecond
  TimeBeginPeriod(1);

  DateTimePickerDate.Date := gEnv.AppDate;

  FMasterLoaded := false;
  FReset := false;
  FKeyGoto := false;
  FTickPlay:= false;

  FQuoteFileLoad:= TQuoteFileLoad.Create( 'drvreal.txt' );

  LoadEnv( FStorage );
end;

procedure TKRXQuoteEmulationForm.FormDestroy(Sender: TObject);
var
  i : integer;
begin
  FStorage.New;
  SaveEnv( FStorage );
  FStorage.Free;
    // clear a previously set minimum timer resolution
  TimeEndPeriod(1);

    // release thread
  StopThread;

  for i := 0 to 5 do
    FMasterPackets[i].Free;

  FParser.Free;
    // release objects
  FFillPackets.Free;
  FQuoteProfiles.Free;
  FQuotePackets.Free;
end;

procedure TKRXQuoteEmulationForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  dSpeed : Double;
begin
 if Key in [VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_SPACE, VK_F5 ] then
  begin
    case Key of
      VK_F5:
        begin
          if FState = ssPaused then
            ButtonTickClick( ButtonTick );
        end;
      VK_UP:
      begin
        ButtonPauseClick( ButtonPause );
        dSpeed := StrToFloatDef(EditSpeed.Text, 1);
        FSpeed := dSpeed + 1;
        EditSpeed.Text := FloatToStr( FSpeed );
        ButtonPlayClick( ButtonPlay );
      end;

      VK_DOWN:
      begin
        dSpeed := StrToFloatDef(EditSpeed.Text, 1);
        if dSpeed = 1 then
          FSpeed := dSpeed
        else
        begin
          ButtonPauseClick( ButtonPause );
          FSpeed := dSpeed - 1;
          EditSpeed.Text := FloatToStr( FSpeed );
          ButtonPlayClick( ButtonPlay );
        end;
      end;

      VK_LEFT:
      begin
        if FState = ssPlaying then
        begin
          ButtonPauseClick( ButtonPause );
          DateTimePickerTime.Time := FQuotePackets.PlayTime - GAP;
          FKeyGoto := true;
          ButtonGotoClick( ButtonGoto );
        end else
        begin
          if FQuotePackets.PlayTime <> 0 then
          begin
            DateTimePickerTime.Time := FQuotePackets.PlayTime - GAP;
            ButtonGotoClick( ButtonGoto );
          end;
        end;
      end;

      VK_RIGHT:
      begin
        if FState = ssPlaying then
        begin
          ButtonPauseClick( ButtonPause );
          DateTimePickerTime.Time := FQuotePackets.PlayTime + GAP;
          FKeyGoto := true;
          ButtonGotoClick( ButtonGoto );
        end else
        begin
          if FQuotePackets.PlayTime <> 0 then
          begin
            DateTimePickerTime.Time := FQuotePackets.PlayTime + GAP;
            ButtonGotoClick( ButtonGoto );
          end;
        end;
      end;

      VK_SPACE:
      begin
        if (ButtonPlay.Visible) and (ButtonPlay.Enabled) then
          ButtonPlayClick( ButtonPlay )
        else if (ButtonPause.Visible) and (ButtonPause.Enabled) then
          ButtonPauseClick( ButtonPause );
      end;
    end;
  end;
  Key := 0;
end;


procedure TKRXQuoteEmulationForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if not aStorage.Load(ComposeFilePath([gEnv.DataDir, EMUL_ENV])) then
    Exit;
  aStorage.First;

  Left  := aStorage.FieldByName('Left').AsInteger ;
  Top   := aStorage.FieldByName('Top').AsInteger;

  StartDate.Date  := TDateTime( aStorage.FieldByName('StartDate').AsFloat );
  EndDate.Date    := TDateTime( aStorage.FieldByName('EndDate').AsFloat );
  cbUseS5.Checked := aStorage.FieldByName('UseS5').AsBoolean ;

  cbOnlyMaster.Checked  := aStorage.FieldByName('UseOnlyMaster').AsBoolean ;
  edtTitle.Text     := aStorage.FieldByName('simulTitle').AsString ;
end;

procedure TKRXQuoteEmulationForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.Clear;
  aStorage.New;

  aStorage.FieldByName('Left').AsInteger := Left;
  aStorage.FieldByName('Top').AsInteger := Top;

  aStorage.FieldByName('StartDate').AsFloat := StartDate.Date;
  aStorage.FieldByName('EndDate').AsFloat   := EndDate.Date;
  aStorage.FieldByName('UseS5').AsBoolean   := cbUseS5.Checked;
  aStorage.FieldByName('UseOnlyMaster').AsBoolean := cbOnlyMaster.Checked;

  aStorage.FieldByName('simulTitle').AsString := edtTitle.Text;


  aStorage.Save( ComposeFilePath([gEnv.DataDir, EMUL_ENV]) );
end;

//-----------------------------------------------------------------< prepare >

procedure TKRXQuoteEmulationForm.ButtonInitClick(Sender: TObject);
begin
    // reset environment

  gEnv.Engine.QuoteBroker.Timers.Reset( DateTimePickerDate.DateTime );

  if Assigned(FOnReset) then
    FOnReset(Self);
    //
  Prepare(Floor(DateTimePickerDate.Date));

end;

procedure TKRXQuoteEmulationForm.Prepare(dtMaster: TDateTime);
var
  stOrderFile, stQuoteFile: String;
begin
    // reset
  PlayTimer.Enabled := False;

  StopThread;

  FQuotePackets.Reset;
  FFillPackets.Reset;

    // load symbol master
  if (not Assigned(FOnLoad)) or (not FOnLoad(Self, dtMaster)) then
  begin
    SetState(ssStalled, 'Failed to load the master.');
    Exit;
  end;

   // quote file path
  stQuoteFile := FQuoteFileDir + '\' + FormatDateTime('yyyymmdd', dtMaster);
  case RadioGroupSource.ItemIndex of
    0: stQuoteFile := stQuoteFile + '_drvreal.txt';
    1: stQuoteFile := stQuoteFile + '_stkreal.txt';
    2: stQuoteFile := stQuoteFile + '_sssreal.txt';
    3: stQuoteFile := stQuoteFile + '_real.txt';
    else
      Exit;
  end;

  FQuoteFile := stQuoteFile;

    // check: file exists?
  if not FileExists(stQuoteFile) then
  begin
    SetState(ssStalled, 'The quote file ' + stQuoteFile + ' does not exist!');
    Exit;
  end;

    // make file profile
  FQuoteProfiles.GenerateProfiles(stQuoteFile);


    // check: file is empty?
  if FQuoteProfiles.FileSize = 0 then
  begin
    SetState(ssStalled, 'The file is empty!');
    Exit;
  end else
  begin
    DoLog(Format('Quote Profile: %d with the file size %d',
                      [FQuoteProfiles.Count, FQuoteProfiles.FileSize]));
  end;
    // load fill
  if FFillEnabled then
  begin
    FFillPackets.Clear;
    stOrderFile := FFillFileDir + '\' + FormatDateTime('yyyymmdd', dtMaster);
    stOrderFile := stOrderFile+'_kospider.txt';
    FFillPackets.LoadFromFile( stOrderFile );
    FFillPackets.Reset;
  end;
    // state = loading
  SetState(ssLoading);
    // start loading thread
  StartLoading(stQuoteFile);
end;

procedure TKRXQuoteEmulationForm.ReSet2;
begin
  gEnv.Engine.FormBroker.Save(ComposeFilePath([gEnv.DataDir, FILE_ENV]));

end;


procedure TKRXQuoteEmulationForm.ResetTimerTimer(Sender: TObject);
begin
  /// ?α? üũ..
  if gEnv.Log.LogPopQueue = nil then
  begin
    ResetTimer.Enabled := false;
    OnSimulationStats( tsPrintEnd );
  end;
end;

procedure TKRXQuoteEmulationForm.ReSet;
var
  i : integer;
  stDay : string;
begin

  gEnv.Engine.FormBroker.ResetCloseWindow;
  LoadTimer.Enabled := False;
  FPlayDate := ToDay;

  stDay := FormatDateTime('yyyy-mm-dd', ToDay);
  DateTimePickerDate.DateTime := FPlayDate;
  gEnv.AppDate  := FPlayDate;
  gEnv.Engine.QuoteBroker.Timers.Reset( DateTimePickerDate.DateTime );


  if Assigned(FOnReset) then
    FOnReset(Self);
  for i := 0 to 4 do
    FMasterPackets[i].Clear;

  FReSet := true;
  FCme := false;
  FMasterLoaded := false;
  FQuoteProfiles.Clear;

  gEnv.Engine.TradeCore.Orders.OrderReSet;
  gEnv.Engine.TradeCore.Clear;
  gEnv.Engine.TradeBroker.Clear;

  gEnv.Engine.SymbolCore.Reset;
  gEnv.Engine.SyncFuture.ReSetIndicator;
  gEnv.Engine.SyncFuture.ReSet;
  gEnv.Engine.QuoteBroker.Clear;

  gEnv.Engine.SymbolCore.ConsumerIndex.Reset;
  gEnv.Engine.VirtualTrade.ReSet;
  Sleep(3000);
end;


procedure TKRXQuoteEmulationForm.ShowData;
var
  stLog : string;
begin


  // all ?ʱ?ȭ
  with gEnv.Engine do
  begin
    TradeCore.OrderTickets.Clear;
    TradeCore.Positions.Clear;
    Tradecore.Orders.ActiveOrders.Clear;
    TradeCore.Orders.ClosedOrders.Clear;
    tradeCore.Orders.RjtOrders.Clear;
    TradeCore.Fills.Clear;
    TradeCore.OrderResults.Clear;
    TradeCore.Orders.Clear;
  end;



  // ȭ?? ?ʱ?ȭ
  gEnv.Engine.FormBroker.ReLoad;
end;


procedure TKRXQuoteEmulationForm.StartLoading(stQuoteFile: String);
begin
    // create a new thread to load packets
  StartThread(stQuoteFile);

    // start the load timer
  LoadTimer.Enabled := True;
end;

procedure TKRXQuoteEmulationForm.StartThread(stQuoteFile: String);
begin
  FLoadThread := TQuoteFileLoadThread.Create(stQuoteFile, FQuotePackets, FMasterPackets);
end;

procedure TKRXQuoteEmulationForm.StopThread;
begin
  if FLoadThread <> nil then
  begin
    FLoadThread.Terminate;
    FLoadThread.WaitFor;
    FLoadThread.Free;
    FLoadThread := nil;
  end;
end;

procedure TKRXQuoteEmulationForm.LoadTimerProc(Sender: TObject);
begin
  ShowStatus;

  if FQuotePackets.LoadPosition >= FQuoteProfiles.FileSize-1 then
  begin
    StopThread;
    LoadTimer.Enabled := False;
  end;

  if (FState = ssLoading) and (FQuotePackets.Count > 0) then
  begin
    if FMasterLoaded then
      SetState(ssReady)
    else begin
      SetState(ssMaster);
      ImportMaster;
    end;

    if FReSet then                              //ReSet
    begin
      SetState(ssReSet);
      DateTimePickerTime.DateTime := EncodeTime(9,0,0,0);
      ButtonGotoClick( ButtonGoto);
      FReSet := false;
    end;

    if FKeyGoto then                             //KeyDown
    begin
      ButtonPlayClick( ButtonPlay );
      FKeyGoto := false;
    end;
  end;

  if (FState = ssReset) and (FQuotePackets.Count > 0) then
    ButtonPlayClick( ButtonPlay );

  Application.ProcessMessages;
end;


procedure TKRXQuoteEmulationForm.ImportMaster;
begin
  if FState = ssImporting then Exit;
  SetState(ssImporting);
  ImportFOMaster;
  FMasterLoaded := true;
  SetState(ssLoading);
  gEnv.SimulationReady;
end;

procedure TKRXQuoteEmulationForm.ImportFOMaster;
var
  i,j: Integer;
  pPacket : TSavedQuotePacket;
begin
  for j := 0 to 5  do
    for i := 0 to FMasterPackets[j].Count - 1 do
    begin
      pPacket := FMasterPackets[j].GetPacket(i);
      FOnMaster(Self, pPacket.PacketStr);
    end;
  FOnMaster( Self, '99999');
end;
//--------------------------------------------------------------------< play >

// starts to send quotes
procedure TKRXQuoteEmulationForm.ButtonPlayClick(Sender: TObject);
begin
  if FState = ssReady then
  begin
    FPlayDate := Floor(DateTimePickerDate.Date);
    FEndDate := FPlayDate + StrToIntDef(EditDays.Text, 1) - 1;
  end;

  FFillPackets.Test := true;

  //gEnv.Engine.QuoteBroker.BackQuote;
  gSimulEnv.QuoteOp.Back := false;

  Play;
end;

procedure TKRXQuoteEmulationForm.Play;
var
  iPort : Integer;
  aPacket : TSavedQuotePacket;
begin
  if FState in [ssReady, ssPaused, ssReset] then
  begin
    if RadioGroupMethod.ItemIndex = 1 then
    begin
        // get port number
      iPort := StrToIntDef(EditQuotePort.Text, 0);
      if (EditTargetHost.Text = '') or (iPort <= 0) then
      begin
        DoLog('Target Host or Port Invalid!');
        Exit;
      end;

        // set UDP socket
      IDUDPClientQuote.Host := EditTargetHost.Text;
      IDUDPClientQuote.Port := iPort;
    end;

      //CA003-1: new
    if FFillEnabled then
    begin
      if RadioGroupMethod.ItemIndex = 1 then
      begin
        iPort := StrToIntDef(EditFillPort.Text, 0);
        if (iPort <= 0) then
        begin
          DoLog('Fill Port is invalid');
          Exit;
        end;

        IDUDPClientFill.Host := EditTargetHost.Text;
        IDUDPClientFill.Port := iPort;
      end;
    end;

      // get speed
    FSpeed := StrToFloatDef(EditSpeed.Text, 1);

      // set times
    aPacket          := FQuotePackets[FQuotePackets.PlayIndex];
    if aPacket = nil then Exit;
    
    FPacketStartTime := aPacket.LogTime;
    FStartTime := Now;

      // state = playing
    SetState(ssPlaying);

      // go!
    PlayTimer.Enabled := True;
  end;
end;

procedure TKRXQuoteEmulationForm.PlayTimerProc(Sender: TObject);
var
  aPacket : TSavedQuotePacket;
  aFillPacket: TSavedFillPacket;
  MaxTime: TDateTime;
  stData, stText : string;
  iGap, iTickCnt : integer;
  bFind : boolean;
  dtCmeTime : TDateTime;
begin
  MaxTime := (Now-FStartTime) * FSpeed + FPacketStartTime;

  iTickCnt  := StrToIntDef( edtTick.Text, 1 );
  dtCmeTime := EncodeTime(5,1,0,0);
  //100000

  while (FQuotePackets.PlayIndex < FQuotePackets.Count) do
  begin
    aPacket := FQuotePackets[FQuotePackets.PlayIndex];
    if aPacket = nil then
      break;
      // check time
    if aPacket.LogTime > MaxTime then Break;

    while True do
    begin
      aFillPacket := FFillPackets.Next(aPacket.LogTime);
      if aFillPacket = nil then Break;
      stData  := aFillPacket.PacketStr;
      gReceiver.DataReceived( stData, aFillPacket.AceptTime );
    end;
       // set packet

    if RadioGroupMethod.ItemIndex = 0 then
    begin
      if Assigned(FOnQuote) then
      begin
        FOnQuote(Self, aPacket.PacketStr);
      end;
    end else
      IDUDPClientQuote.SendBuffer(ToBytes(aPacket.PacketStr));

      // notify time (packt log time)
    if Assigned(FOnTime) then
      FOnTime(Self, FPlayDate + aPacket.LogTime);

      // clear packet str(clear memory)
    aPacket.PacketStr := '';
      // goto next packet
    FQuotePackets.PlayIndex := FQuotePackets.PlayIndex + 1;
    FQuotePackets.PlayPosition := aPacket.Position;
    FQuotePackets.PlayTime := aPacket.LogTime;

    //Application.ProcessMessages;
    if FTickPlay then begin
      inc( FTickSent );
      if FTickSent >= iTickCnt then begin
        FTickPlay := false;
        ButtonPauseClick( nil );
        break;
      end;
    end;

    if (aPacket.LogTime < dtCmeTime) and (not FCme) then
    begin
      FPacketStartTime := 0;
      FStartTime := Now;
      FCme := true;
      break;
    end;
  end;        // while end

  ShowStatus;

  Application.ProcessMessages;

  if FLoadThread = nil then Exit;

    // play has finished
  if (not FLoadThread.Loading)
      and (FQuotePackets.PlayIndex = FQuotePackets.Count) then
  begin
    FPlayDate := FPlayDate + 1;
    if FEndDays > 1 then
    begin
      bFind := FindFile( FPlayDate );
      if bFind then
      begin
        ReSet;
        Prepare(FPlayDate);
      end;
    end;
  end;

end;

// pauses sending quotes
procedure TKRXQuoteEmulationForm.ButtonPauseClick(Sender: TObject);
begin
  SetState(ssPaused);

  PlayTimer.Enabled := False;
end;

// stop sending quotes
procedure TKRXQuoteEmulationForm.ButtonStopClick(Sender: TObject);
begin
    // stop playing
  PlayTimer.Enabled := False;
  
    // stop loading
  StopThread;

    // start from the initial position or end 
  if FAllowReverse then
  begin
    //FQuotePackets.Reset;
    //SetState(ssLoading);
    Prepare(DateTimePickerDate.Date);
  end else
  begin
    SetState(ssEnded);
  end;
end;

procedure TKRXQuoteEmulationForm.ButtonTickClick(Sender: TObject);
begin
  FTickPlay := true;
  FTickSent := 0;

  if FState = ssReady then
  begin
    FPlayDate := Floor(DateTimePickerDate.Date);
    FEndDate := FPlayDate + StrToIntDef(EditDays.Text, 1) - 1;
  end;

  FFillPackets.Test := true;

  gSimulEnv.QuoteOp.Back := false;

  Play;
end;

procedure TKRXQuoteEmulationForm.cbFillEnabledClick(Sender: TObject);
begin
  FFillEnabled  := cbFillEnabled.Checked;

  if FFillEnabled then
    Width := FORM_WIDTH + IO_WIDTH
  else
    Width := FORM_WIDTH;

  gbAccount.Visible := FFillEnabled;
end;

procedure TKRXQuoteEmulationForm.cbUseS5Click(Sender: TObject);
begin
  ButtonInit.Enabled := not cbUseS5.Checked;
  gbAccount.Enabled := cbUseS5.Checked;
end;

// jump in the quotes
procedure TKRXQuoteEmulationForm.AddMaster(idx, iSzie: integer; stData: string; dtTime : TDateTime);
var
  aPacket : TSavedQuotePacket;
begin
  if FMasterPackets[idx] <> nil then
  begin
    aPacket := FMasterPackets[idx].Add as TSavedQuotePacket;
    aPacket.LogTime   := dtTime;
    aPacket.PacketStr := stData;
    aPacket.iLen      := Length( stData );
  end;

end;

procedure TKRXQuoteEmulationForm.Button1Click(Sender: TObject);
begin
  SetSimulStatus( tsStart );
end;

procedure TKRXQuoteEmulationForm.Button2Click(Sender: TObject);
begin

  if spbSuspend.Down then
  begin
    // -- ????
    //Self.Color := clBtnFace ;
    spbSuspend.Caption := 'Resume';
    FQuotefileLoad.LoadThread.Suspend;

  end
  else
  begin
    //Self.Color := clSkyBlue ;
    spbSuspend.Caption := 'Suspend';
    FQuotefileLoad.LoadThread.Resume;
  end;

end;

procedure TKRXQuoteEmulationForm.Button3Click(Sender: TObject);
begin
  FQuoteFileLoad.LoadThread.Terminate;
end;

procedure TKRXQuoteEmulationForm.ButtonGotoClick(Sender: TObject);
var
  i : integer;
  aFillPacket: TSavedFillPacket;
  nowTime : TDateTime;
  bBack : boolean;
  inState : TEmulationFeedState;
begin
  if FState in [ssReady, ssPaused, ssReset] then
  begin
      // stop loading
    StopThread;
    inState := FState;

    FQuotePackets.Reset;
    FQuotePackets.SearchTime := Frac(DateTimePickerTime.Time);
    FQuotePackets.SearchPosition :=
              FQuoteProfiles.FindSearchPosition(FQuotePackets.SearchTime);

    if FReset then
      SetState(ssReset)
    else
      SetState(ssLoading);

    StartLoading(FQuoteFile);

    nowTime := GetQuotetime;
    //SetQuoteTime( nil );
    gEnv.Engine.QuoteBroker.Timers.Reset( GetQuoteDate + FQuotePackets.SearchTime);

    {
    if (GetQuoteTime < nowTime) and ( inState = ssPaused)  then
      gSimulEnv.QuoteOp.Back  := true;

    if FFillEnabled then
    begin

      FFillPackets.FindPositon(Frac(DateTimePickerTime.Time) );

      if Assigned( FOnOrderReset) then
        FOnOrderReset( self, bBack, FFillPackets.FPosition );

    end;   // if FFillEnabled then

    }

  end;
end;

//-------------------------------------------------------------------< status >

procedure TKRXQuoteEmulationForm.SetButtons(bPlay, bPause, bStop, bGoto: Boolean);
begin
  ButtonPlay.Enabled := bPlay;
  ButtonPause.Enabled := bPause;
  ButtonStop.Enabled := bStop;
  ButtonGoto.Enabled := bGoto and FAllowGoto;
  ButtonTick.Enabled := bPlay;

  case FState of
    ssNotReady,
    ssStalled,
    ssEnded,
    ssLoading,
    ssImporting,
    ssMaster :
    begin
      ButtonPlay.Visible := true;
      ButtonPause.Visible := false;
    end;

    ssPlaying :
    begin
      ButtonPlay.Visible := false;
      ButtonPause.Visible := true;
    end;
    ssPaused :
    begin
      ButtonPlay.Visible := true;
      ButtonPause.Visible := false;
    end;
  end;
end;

procedure TKRXQuoteEmulationForm.SetState(ssValue : TEmulationFeedState;
  stMsg: String);
begin
  FState := ssValue;

  case FState of
    ssNotReady,
    ssStalled,
    ssEnded,
    ssLoading,
    ssImporting,
    ssMaster :
      begin
        SetButtons(False, False, False, False);
       // btnAdd.Enabled  := true;
      end;
    ssReady:   SetButtons(True, False, False, True);
    ssPlaying:  SetButtons(False, True, True, False);
    ssPaused:   SetButtons(True, False, True, True);
  end;

  ShowStatus;

  if Length(stMsg) <> 0 then
    DoLog(stMsg);
end;

procedure TKRXQuoteEmulationForm.ShowStatus;
begin
    // action status
  StatusBar.Panels[0].Text := STATE_TEXTS[FState];

  if FQuoteProfiles.FileSize > 0 then
  begin
      // playing time
    if FState in [ssPlaying, ssPaused] then
      StatusBar.Panels[1].Text :=
                 FormatDateTime('hh:nn:ss.zzz', FQuotePackets.PlayTime)
    else
      StatusBar.Panels[1].Text := '';
      // playing status
    StatusBar.Panels[2].Text :=
                 Format('%d/%d', [FQuotePackets.PlayIndex, FQuotePackets.Count]);
      // loading status
    StatusBar.Panels[3].Text :=
                 Format('%d M/%d M', [FQuotePackets.LoadPosition div 1000000,
                                  FQuoteProfiles.FileSize div 1000000]);

      // track bar
    TrackBar.Position :=
                 Round((FQuotePackets.PlayPosition / FQuoteProfiles.FileSize) * 1000);
    TrackBar.SelStart :=
                 Round((FQuotePackets.StartPosition / FQuoteProfiles.FileSize) * 1000);
    TrackBar.SelEnd :=
                 Round((FQuotePackets.LoadPosition / FQuoteProfiles.FileSize) * 1000);
  end;
end;

procedure TKRXQuoteEmulationForm.spbSuspendClick(Sender: TObject);
begin

  if spbSuspend.Down then
  begin
    // -- ????
    //Self.Color := clBtnFace ;
    spbSuspend.Caption := 'Resume';
    FQuotefileLoad.LoadThread.Suspend;

  end
  else
  begin
    //Self.Color := clSkyBlue ;
    spbSuspend.Caption := 'Suspend';
    FQuotefileLoad.LoadThread.Resume;
  end;
end;

//----------------------------------------------------------------------< log >

procedure TKRXQuoteEmulationForm.DoLog(stLog: String);
begin
  gLog.Add( lkApplication, 'TKRXQuoteEmulationForm', '', stLog);
  {
  if Assigned(FOnLog) then
    FOnLog(Self, 'KRX Quote Emulator: ' + stLog);
    }
end;


procedure TKRXQuoteEmulationForm.EditDaysChange(Sender: TObject);
begin
  FEndDays := StrToIntDef(EditDays.Text, 1);
end;

procedure TKRXQuoteEmulationForm.EditSpeedKeyPress(Sender: TObject;
  var Key: Char);
begin
 if not (Key in ['0'..'9','.', #13, #8]) then
     Key := #0;
end;



procedure TKRXQuoteEmulationForm.SetSimulStatus(const Value: TSimulationStatus);
begin
  SimulStats :=  Value;
  OnSimulationStats( Value );
end;

procedure TKRXQuoteEmulationForm.OnSimulationStats(tsType: TSimulationStatus);
var
  bRes : boolean;
  stDate : string;
begin

  SimulStats := tsType;
  case tsType of
    tsNone: ;
    tsStart:
      begin
        SetStatus( 1, 'start ');
        ToDay     := StartDate.Date;
        gEnv.AppDate := ToDay;
        gEnv.Engine.QuoteBroker.Timers.Reset( Trunc(StartDate.Date ));
        FQuoteFileLoad.Start( ToDay );
      end;
    tsEnd:
      begin
        // ?ü? ???? ?? ????????..?? ȭ?? ?α??? ???? 300 ?? ???????ش?.
        gEnv.Engine.QuoteBroker.Delivery( 300 );
        OnSimulationStats( tsPrint );
      end;
    tsPreSuscribe :
      begin
        SetStatus( 1, '????');
        gEnv.SimulationReady;
        FQuoteFileLoad.LoadThread.Resume;
      end;
    tsNoFile,
    tsReStart:
      begin
        SetStatus( 1, ' Next Start ');
        ToDay := IncDay( ToDay );
        if ToDay > EndDate.Date then
          SetSimulStatus( tsCompleteEnd )
        else begin
          //OnSimulationStats( tsClear );
          SetStatus( 1, 'End');
          ReSet;
          FQuoteFileLoad.Start( ToDay );
        end;
      end;
    tsCompleteEnd:
      SetStatus( 1, '?Ϸ?');
    tsClear:
      begin
        SetStatus( 1, 'Clear');
        ReSet;
        SetSimulStatus( tsClearEnd );
      end;
    tsClearEnd:
      begin
        SetStatus( 1, 'ClearEnd');
        OnSimulationStats( tsReStart );
      end;
    tsPrint:
      begin
        //sleep(100);
        SetStatus(1, 'Print' );
        PrintData;
        ResetTimer.Enabled := true;
      end;
    tsPrintEnd:
      begin
        Reset2;
        SetStatus(1, 'PrintEnd' );
        OnSimulationStats( tsReStart );
      end;
  end;
end;

procedure TKRXQuoteEmulationForm.SetStatus( index :integer; value : string);
begin
  lbStats.Caption := '???? : ' +value;
end;


procedure TKRXQuoteEmulationForm.PrintData;
begin
  gEnv.Engine.TradeCore.AccountPrint(edtTitle.Text);
  //gEnv.Engine.SymbolCore.OptionPrint;
    
end;

end.



