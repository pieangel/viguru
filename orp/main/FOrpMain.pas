unit FOrpMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ToolWin, Menus, Math,

    // lemon: common
  GleTypes, GleLib, LemonEngine,
    // lemon: symbol
  DleSymbolSelect, CleQuoteTimers,
    // lemon: trade
  FleOrderList2,
    // lemon: util
  CleStorage, CleMySQLConnector, DleDateDialog,
    // lemon: KRX
  CleKRXOrderBroker, CleFTPConnector,   CleKRXTradeReceiver, CleAccountLoader,
  CleKrxSymbols, CleKrxSymbolMySQLLoader,
  CleKrxQuoteUDPReceiver,
    // app
  GAppEnv, GAppConsts, GAppForms, StreamIO,
    // app: forms
  FOrderBoard,

  ActiveX,
  ExtCtrls, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdFTP, IdBaseComponent, IdAntiFreezeBase,
  IdAntiFreeze
  ;

type
  TOrpMainForm = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    MemoLog: TMemo;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Help1: TMenuItem;
    Research1: TMenuItem;
    Skew1: TMenuItem;
    Exit1: TMenuItem;
    StatusBar: TStatusBar;
    OpenDialog: TOpenDialog;
    Orders1: TMenuItem;
    PositionView1: TMenuItem;
    Order1: TMenuItem;
    N3: TMenuItem;
    Order2: TMenuItem;
    OrderBoard1: TMenuItem;
    Open1: TMenuItem;
    plInfo: TPanel;
    MainConfig: TPopupMenu;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    concern: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    N26: TMenuItem;
    Exit2: TMenuItem;
    IdFTP: TIdFTP;
    N20: TMenuItem;
    StopOrderList1: TMenuItem;
    N25: TMenuItem;
    N27: TMenuItem;
    procedure MainMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N16Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    FEngine: TLemonEngine;
    FSymbolLoader: TKrxSymbolMySQLLoader;
    FAccountLoader  : TAccountLoader;

    FQuoteTimer: TQuoteTimer;
    //*^^*
    FTradeReceiver : TKRXTradeReceiver;
    FOrderBroker : TKRXOrderBroker;
    FTPCon  :  TFTPConnector;

    FPrevTime : TDateTime;
    FDelaying : Double;
    FBClose : boolean;
    //FQuoteDelays: TCollection;

    procedure QuoteTimerProc(Sender: TObject);

    procedure QuoteTime(Sender: TObject; Value: TDateTime);

    procedure FormLoad(iFormID: Integer; aStorage: TStorage; var aForm: TForm);
    procedure FormOpen(iFormID, iVar: Integer; var aForm: TForm);
    procedure FormSave(iFormID: Integer; aStorage: TStorage; aForm: TForm);
    procedure FormReLoad( iFormID : integer; aForm : TForm );

    procedure MergeQuoteFiles;
    procedure CheckQuoteFile;
    procedure ClipQuoteFile;
    procedure PeekQuoteFile;

    procedure QuoteReceived(Sender: TObject; Value: String);
    procedure MasterReceived(Sender: TObject; Value: String);
    function SymbolLoad(Sender: TObject; Value: TDateTime): Boolean;
    procedure OrderReset( Sender : TObject; bBack : boolean; Value : Integer );
    //procedure QuoteDateChanged(Sender: TObject; Value: TDateTime);
    procedure SymbolReset(Sender: TObject);
    procedure DoLog(Sender: TObject; stLog: String);
    procedure DoTimeLog(Sender: TObject; stLog: String);
    procedure AppException(Sender: TObject; E: Exception);

    //*^^*
    procedure OnLemonState( asType : TAppStatus );
    procedure OnSocketState( Value : string ; idx : integer);
    function LoadConfig : boolean;

    procedure LoadRegedit;
    procedure SaveRegedit;

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveProfitNLoss;
    procedure BackUpWindows;
    procedure OpenWins;

    function CheckRemainActiveOrder: boolean;
    function FtpSymbolLoad : boolean;
    procedure ReadOrderNo;
    function IsErrorOccur(iRes: integer; st: string): Boolean;

    { Private declarations }
  public
    { Public declarations }
    m_stIni : string;
    FQuoteReceiver: TKrxQuoteUDPReceiver;
    InfoPaint : TPaintBox;

    function FindGiComponet( stName : string ) : boolean;
      // ?????? ????
    procedure BranchMode;
    procedure StepInitSymbolLoad;
    procedure SetpRecoveryEnd;
    procedure initQ;
    procedure StepSimulation;

    procedure OnWindowMenuClick(Sender: TObject);
    procedure EventIdle(Sender: TObject; var Done: Boolean);
    procedure MessageBookMark(var Msg: TMsg; var Handled: Boolean);

    property  AccountLoader  : TAccountLoader read FAccountLoader write FAccountLoader;
    property  TradeReceiver : TKRXTradeReceiver read FTradeReceiver;
  end;

var
  OrpMainForm: TOrpMainForm;

implementation

uses CalcGreeks, CleIni, CleLog,  Registry, CleFQN,CleFormBroker,
  GleConsts, CleExcelLog, CleOrders,
  TLHelp32,  FAppInfo,
  DBoardEnv,
  FleMiniPositionList
  ;

{$R *.dfm}

//-----------------------------------------------------------------< init >

function TOrpMainForm.FindGiComponet(stName: string): boolean;
var
  peList : TProcessEntry32;
  hL : THandle;
begin
  Result := False;
  peList.dwSize := SizeOf(TProcessEntry32);
  hL            := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(hL, peList) then begin
    repeat
      if CompareText(peList.szExeFile, stName) = 0 then begin
        Result := True;
        break;
      end;
    until not Process32Next(hL, peList);
  end;

  CloseHandle(hL);
end;

function TOrpMainForm.CheckRemainActiveOrder : boolean;
var
  i, iVol, iCnt : integer;
  aOrder : TOrder;
  stLog : string;
  bExist: boolean;
begin
  Result := true;
  iCnt := gEnv.Engine.TradeCore.Orders.ActiveOrders.Count;

  if iCnt > 0 then
    stLog := Format('?????? ???? : %d ?? ???? ', [ iCnt ]);

  iVol := 0;
  stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
  bExist := false;
  for i:=0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    //iVol := iVol +  gEnv.Engine.TradeCore.Positions.Positions[i].Volume;
    if gEnv.Engine.TradeCore.Positions.Positions[i].Volume <> 0 then
    begin
      stLog := stLog + Format('%s : %s ???? %d ????', [ gEnv.Engine.TradeCore.Positions.Positions[i].Symbol.ShortCode,
        ifThenStr( gEnv.Engine.TradeCore.Positions.Positions[i].Volume > 0, '????', '????'),
        abs(gEnv.Engine.TradeCore.Positions.Positions[i].Volume)
        ]);
      stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
      bExist := true;
    end;
  end;

  if (iCnt > 0) or ( bExist ) then
  begin
    stLog  := stLog + '?????????????????';
    if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      Result := true
    else
      Result := false;
  end;

end;

procedure TOrpMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
  bClose : boolean;
begin

  bClose := CheckRemainActiveOrder;
  if not bClose then
  begin
    Action := caNone;
    Exit;
  end;
  //gEnv.Engine .stop;
  //gEnv.
    // save the working environment
  gEnv.Engine.FormBroker.Save(ComposeFilePath([gEnv.DataDir, FILE_ENV]));
    // before free main form
    // free all work forms (required)
  for i := ComponentCount-1 downto 0 do
    if Components[i] is TForm then
      Components[i].Free;

  //SaveLastOrderNo;
  SaveRegedit;

  gSymbol.Free;
  gBoardEnv.Free;
    //
  FQuoteTimer.Free;
    //

  FTradeReceiver.Free;
  FQuoteReceiver.Free;
  FSymbolLoader.Free;
  gEnv.MySQLConnector.Free;
  FEngine.Free;

  FOrderBroker.Free;

  FAccountLoader.Free;

  //FQuoteDelays.Free;

  gLog.Free;
  gClock.Free;

  Action  := caFree;

end;

procedure TOrpMainForm.FormCreate(Sender: TObject);
var
  bValue : boolean;
  i, iParam  : integer;
  stParam : string;
  bResult : boolean;

  stLog, stMsg : string;

begin

  Application.OnException := AppException;

//  Caption := Caption + ' Ver.' + FileVersionToStr(Application.ExeName);
  Caption := Caption + ' Ver. ' + FormatDateTime('yyyy-mm-dd',
      FileDateToDateTime( FileAge( Application.ExeName )
      ));

  Left := 0;
  Top := 0;

  gEnv.CreateAppLog;
  gEnv.Log       := TLogThread.Create;

  FPrevTime := 0;
  FDelaying := 0;

  if not LoadConfig then
  begin
    ShowMessage('?????????? ?????????? ?????? ??????????.');
    close;
  end;

  LoadRegedit;

  StatusBar.Panels[2].Text := gEnv.ConConfig.FutureIP;
  GetWindowThreadProcessId(Handle, @gEnv.AppPid);


  gEnv.OnState   := OnLemonState;
  gEnv.OnSsState := OnSocketState;
  gEnv.OnLog     := DoLog;
  gEnv.RootDir   := AppDir;
  gEnv.DataDir   := ComposeFilePath([gEnv.RootDir, DIR_DATA]);
  gEnv.OutputDir := ComposeFilePath([gEnv.RootDir, DIR_OUTPUT]);
  gEnv.LogDir    := ComposeFilePath([gEnv.RootDir, DIR_LOG]);
  gEnv.SimulDir  := ComposeFilePath([gEnv.RootDir, DIR_SIMUL]);
  if gEnv.QuoteDir = '' then
    gEnv.QuoteDir  := ComposeFilePath([gEnv.RootDir, DIR_QUOTEFILES]);
  gEnv.TemplateDir  := ComposeFilePath([gEnv.RootDir, DIR_TEMPLATE]);

  FEngine := TLemonEngine.Create;

  gEnv.Engine := FEngine;

  gEnv.CreateTimeSpeeds;

  gLog.Add( lkApplication, 'TOrpMainForm', 'FormCreate', 'start' );

  BranchMode;

  DoLog( self, FormatDateTime( 'yyyy-mm-dd hh:nn:ss.zzz', GetQuoteDate ));

end;

procedure TOrpMainForm.QuoteTimerProc(Sender: TObject);
var
  stDate : string;
begin

  if gEnv.RunMode = rtSimulation then
  begin
    stDate  := Format( ' %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', GetQuoteTime)]);
    StatusBar.Panels[1].Text := stDate;
    StatusBar.Panels[2].Text := Format( 'CPU : %.0f %s', [
        gEnv.Engine.QuoteBroker.Timers.CpuUsage, '%']);
  end
  else begin
    {
    StatusBar.Panels[1].Text := Format( 'CPU : %.0f %s', [
        gEnv.Engine.QuoteBroker.Timers.CpuUsage, '%']);
    }
    stDate  := Format( ' %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', GetQuoteTime)]);
    StatusBar.Panels[1].Text := stDate;
  end;

  SaveProfitNLoss;
end;

procedure TOrpMainForm.SaveProfitNLoss;
var
  i : integer;
begin
  for i := 0 to gEnv.Engine.TradeCore.Accounts.Count - 1 do
    gEnv.Engine.TradeCore.Accounts.Accounts[i].ApplyFill( GetQuoteTime );
end;



//--------------------------------------------------< Emulator event handlers >

// reset
procedure TOrpMainForm.SymbolReset(Sender: TObject);
begin
    // once in Emulation mode, quote timers is set to quote feed mode
  gEnv.Engine.QuoteBroker.Timers.Realtime := False;

    // disable UDP receiving
  FQuoteReceiver.Active := False;

  //???? ????.....
  gEnv.CheckPacketVersion;
  FQuoteReceiver.ParserVersion;
  FQuoteReceiver.Parser.QuoteDate := GetQuoteDate;
  FQuoteReceiver.Parser.QuoteParser.QuoteDate := GetQuoteDate;

  DoLog( self, FormatDateTime( 'yyyy-mm-dd hh:nn:ss.zzz', GetQuoteDate ));

    // ???? ?????? ???? ?? ??????.
  //gEnv.Engine.FormBroker.CloseWindow;

    // clear symbol objects
  //FEngine.SymbolCore.Reset;

  //gEnv.Engine.FormBroker.Load(ComposeFilePath([gEnv.DataDir, FILE_ENV]));
end;

procedure TOrpMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  show;
end;

function TOrpMainForm.SymbolLoad(Sender: TObject; Value: TDateTime): Boolean;
begin
    // reset quote timers
  gEnv.Engine.QuoteBroker.Timers.Reset(Value);

  FSymbolLoader.AddFixedSymbols;
    // load symbols
  {
  gEnv.MySQLConnector.SetConString( false );
  Result := FSymbolLoader.Load(Value);
  }
    // todo: quote broker should reset the symbol references
  gEnv.Engine.QuoteBroker.RefreshSymbols;

    // this date setting enable the Quote Receiver set data for quote packet
  FQuoteReceiver.Parser.QuoteDate := Value;

  gEnv.AppDate  := Value;
    // enable UDP receiving
  FQuoteReceiver.Active := True;

  Result := true;

end;

procedure TOrpMainForm.QuoteTime(Sender: TObject; Value: TDateTime);
begin
  gEnv.Engine.QuoteBroker.Timers.Feed(Value);
end;

//
// When the KRX Quote Emulator sends a packet through API, not through network,
// the Main form become medium to deliver the packet to the QuoteReceiver.
// Otherwise,
//
procedure TOrpMainForm.QuoteReceived(Sender: TObject; Value: String);
begin
  FQuoteReceiver.Parser.Parse(Value)
end;

//---------------------------------------------------------------------< menu >

{$REGION ' menu... '}

procedure TOrpMainForm.MainMenuClick(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TComponent) then Exit;

  case (Sender as TComponent).Tag of
      // file
    100: OpenWins;
    999: Close;
      // skew
    201: gEnv.Engine.FormBroker.Open(ID_SKEW, 0); // skew chart
    202: gEnv.Engine.FormBroker.Open(ID_CHART, 0);
      // simulation menu form
    203: gEnv.Engine.FormBroker.Open(ID_SIMULFORM, 0);

    205: gEnv.Engine.FormBroker.Open(ID_DURATION,0);
      // trade
    304: gEnv.Engine.FormBroker.Open(ID_ORDER, 0); // simple order form
    305: gEnv.Engine.FormBroker.Open(ID_ORDERBOARD, 0); // order board
    306: gEnv.Engine.FormBroker.Open(ID_SYSTEM_ORDER, 0);
    307: gEnv.Engine.FormBroker.Open(ID_SSOPT, 0);
    308: gEnv.Engine.FormBroker.Open(ID_ARBMONITOR, 0);
    309: gEnv.Engine.FormBroker.Open(ID_QUOTING_ARB, 0);
    310: gEnv.Engine.FormBroker.Open(ID_VOL_TRADE, 0);
    311: gEnv.Engine.FormBroker.Open(ID_STRANGLE, 0);
    312: gEnv.Engine.FormBroker.Open(ID_BAN_HULT_OPT, 0);
    313: gEnv.Engine.FormBroker.Open(ID_VOL_INVESTOR, 0);
    314: gEnv.Engine.FormBroker.Open(ID_RATIOSPREAD, 0);
    315: gEnv.Engine.FormBroker.Open(ID_STRANGLESEQUEL, 0);
    316: gEnv.Engine.FormBroker.Open(ID_INVESTOR, 0);
    317: gEnv.Engine.FormBroker.Open(ID_BAN_HULT, 0);
    318: gEnv.Engine.FormBroker.Open(ID_HULT, 0);
    319: gEnv.Engine.FormBroker.Open(ID_HLT, 0);


    320: gEnv.Engine.FormBroker.Open(ID_PROTECT, 0);
    321: //gEnv.Engine.FormBroker.Open(ID_HULT_HEDGE ,0);
      gEnv.Engine.FormBroker.Open(ID_QUOTING,0);
    //322: gEnv.Engine.FormBroker.Open(ID_QUOTING,0);
    322: gEnv.Engine.FormBroker.Open(ID_SHEEP_BUY,0);
    323: gEnv.Engine.FormBroker.Open(ID_JANGJUNG,0);
    325: gEnv.Engine.FormBroker.Open(ID_SAVEPOS,0);
    326: gEnv.Engine.FormBroker.Open(ID_SIMPLE_CATCH,0);
    327: gEnv.Engine.FormBroker.Open(ID_SYNCTHESIZE,0);

    328: gEnv.Engine.FormBroker.Open(ID_RATIOS,0);
    329: gEnv.Engine.FormBroker.Open(ID_VOLS,0);
    331: gEnv.Engine.FormBroker.Open(ID_PAVE_ORDER, 0);
    332: gEnv.Engine.FormBroker.Open(ID_SHORT_HULT, 0);

    330: gEnv.Engine.FormBroker.Open(ID_MINI_POSITION_LIST, 0); // position list
    303: gEnv.Engine.FormBroker.Open(ID_POSITION_LIST, 0); // position list
    302: gEnv.Engine.FormBroker.Open(ID_ORDER_LIST, 0); // order list
    350: gEnv.Engine.FormBroker.Open(ID_STOP_LIST, 0); // stop order list
    301: gEnv.Engine.FormBroker.Open(ID_VIRTUAL_TRADE, 0);// Virtual Trade Control
      // quote
    400: gEnv.Engine.FormBroker.Open(ID_QUOTE_SELECT, 0);  //
    410: gEnv.Engine.FormBroker.Open(ID_QUOTE_SIMULATION, 0); // Quote Simulator

    412: gEnv.Engine.FormBroker.Open(ID_ORDER_EXTRACT, 0);
    411: gEnv.Engine.FormBroker.Open(ID_MANY_ORDER, 0); // Quote Request
    430: gEnv.Engine.FormBroker.Open(ID_SAME_CANCEL, 0);
    413: gEnv.Engine.FormBroker.Open(ID_WHOLESALE, 0);
    414: gEnv.Engine.FormBroker.Open(ID_FOFILLVOL, 0);
    415: gEnv.Engine.FormBroker.Open(ID_ENTRYPRICE, 0);
    416: gEnv.Engine.FormBroker.Open(ID_UPDOWN, 0);
    417: gEnv.Engine.FormBroker.Open(ID_LARGEORDER, 0);
      //    ImportMaster; // Import Master

    433: MergeQuoteFiles; // merge quote files
    434: PeekQuoteFile; // peek quote file (show a part of quote file)
    435: ClipQuoteFile; // clip quote file (clip a part of quote file and save to a file)
    436: CheckQuoteFile; // clip quote file (clip a part of quote file and save to a file)

      // bear
    420:  gEnv.Engine.FormBroker.Open(ID_BEAR, 0);
    421:  gEnv.Engine.FormBroker.Open(ID_BULL, 0);
    //422:  gEnv.Engine.FormBroker.Open(ID_AUTO, 0);
    501:
      begin
      end ;
    502: TBoardConfig.Create(self).Show;
    503: gEnv.Engine.FormBroker.Open(ID_CURRENT_TIME, 0);
    601: gEnv.Engine.FormBroker.Open(ID_MONITORING, 0);
    602: genv.Engine.FormBroker.Open(ID_HOGADIST, 0);
  end;
end;

procedure TOrpMainForm.MasterReceived(Sender: TObject; Value: String);
begin

  if gEnv.PacketVer = pv4 then
    FSymbolLoader.ImportMasterFromFilePv4( Value, gEnv.AppDate )
end;

procedure TOrpMainForm.FormOpen(iFormID, iVar: Integer; var aForm: TForm);
var
  bForm : TForm;
begin
  aForm := nil;

  if ( iFormID = ID_SIMULFORM ) and
   ( gEnv.RunMode = rtRealTrading ) then
    Exit;

  case iFormID of
    //ID_SKEW: aForm := TSkewForm.Create(Self);
    ID_SKEW:
      aForm :=TFrmAppInfo.Create( self );

    ID_ORDERBOARD: aForm := TOrderBoardForm.Create(Self);
    ID_ORDER:;
    {
      begin
        aForm := TOrderForm.Create(Self);
        (aForm as TOrderForm).Engine := gEnv.Engine;
      end;
      }
    
    ID_ORDER_LIST:
      begin
        aForm := TFrmOrderList2.Create(Self);
        //(aForm as TFrmOrderList2).Engine := gEnv.Engine;
      end;
    ID_POSITION_LIST:
      begin

      end;

    ID_MINI_POSITION_LIST:
        aForm := TFrmMiniPosList.Create(Self);


  end;
end;

procedure TOrpMainForm.FormReLoad(iFormID: integer; aForm: TForm);
begin
  case iFormID of
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).ReLoad;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).ReLoad;
        {
    ID_MINI_POSITION_LIST:
      if aForm is TFrmMiniPosList then
        (aForm as TFrmMiniPosList).ReLoad;
        }
  end;

end;

procedure TOrpMainForm.FormLoad(iFormID: Integer; aStorage: TStorage; var aForm: TForm);
var
  aItem : TForm;
begin
    // create/get form


   if (iFormID = ID_VIRTUAL_TRADE) and ( not gEnv.Simul ) then
    Exit;

  if ( iFormID = ID_SKEW ) and
   ( gEnv.RunMode = rtSimulation ) then
    Exit;

  if ( iFormID = ID_QUOTE_SIMULATION ) and ( gEnv.RunMode = rtSimulation ) then
    Exit;

  if iFormID = ID_GURU_MAIN then
  begin
    LoadEnv( aStorage );
    Exit;
  end;

  FormOpen(iFormID, 0, aForm);
    //
  if aForm = nil then Exit;

    //
  case iFormID of
    ID_SKEW: ;
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).LoadEnv(aStorage);
    ID_ORDER: ;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).LoadEnv(aStorage);

    ID_MINI_POSITION_LIST :
        if aForm is TFrmMiniPosList  then
        ( aForm as TFrmMiniPosList).LoadEnv( aStorage );
  end;
end;

procedure TOrpMainForm.FormSave(iFormID: Integer; aStorage: TStorage; aForm: TForm);
begin
    //
  if aForm = nil then Exit;

    //
  case iFormID of
    ID_SKEW: ;
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).SaveEnv(aStorage);
    ID_ORDER: ;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).SaveEnv(aStorage);

    ID_GURU_MAIN  :
      SaveEnv( aStorage );

    ID_MINI_POSITION_LIST :
        if aForm is TFrmMiniPosList  then
        ( aForm as TFrmMiniPosList).SaveEnv( aStorage );


  end;
end;

function TOrpMainForm.FtpSymbolLoad: boolean;
var
  stSourceFile, stTargetFile: String;
begin

  with IdFTP do
  begin
    AutoLogin := True;
    Host := gEnv.ConConfig.FtpIP;
    UserName := gEnv.ConConfig.FtpID;
    Password := gEnv.ConConfig.FtpPass;
  end;

  stSourceFile := FormatDateTime('yyyymmdd',gEnv.AppDate)+'_drvmaster.txt';
  //stTargetFile := gEnv.RootDir + '\quotefiles\' + stSourceFile;
  stTargetFile := gEnv.QuoteDir +'\' + stSourceFile;

  gEnv.MySQLConnector.SetConString( false );
  // FSymbolLoader.LoadOptionDaily( gEnv.AppDate ) ;

  if FileExists(stTargetFile) then
  begin

     Result := FSymbolLoader.MasterFileLoad(stTargetFile);
  end
  else
  begin
    if IdFTP.Connected then
      IdFTP.Disconnect;
      // connect
    IdFTP.Connect;

      // get file
    if IdFTP.Connected then
    begin
      IdFTP.Get(stSourceFile, stTargetFile, True);
      if FileExists(stTargetFile) then
        Result := FSymbolLoader.MasterFileLoad(stTargetFile)
      else
      begin
        gEnv.EnvLog(WIN_ERR, 'Master File down failed!');
        Result := false;
      end;
      //FSymbolLoader.SaveOptionDaily( gEnv.AppDate );
    end;

    // disconnect
    if IdFTP.Connected then
      IdFTP.Disconnect;
  end;
end;

procedure TOrpMainForm.SaveEnv( aStorage : TStorage );
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('Left').AsInteger := Left;
  aStorage.FieldByName('Top').AsInteger := Top;
  aStorage.FieldByName('width').AsInteger := Width;
  aStorage.FieldByName('Height').AsInteger := Height;
  case WindowState of
    wsNormal: aStorage.FieldByName('WindowState').AsInteger := 0;
    wsMinimized: aStorage.FieldByName('WindowState').AsInteger := 1;
    wsMaximized: aStorage.FieldByName('WindowState').AsInteger := 2;
  end;

  with gEnv do
  begin
    aStorage.FieldByName('IsSave').AsBoolean  := true;
    aStorage.FieldByName('Display').AsBoolean  := QuoteSpeed.Display;
    aStorage.FieldByName('MinSec').AsFloat  := QuoteSpeed.MinSec;
    aStorage.FieldByName('MaxSec').AsFloat  := QuoteSpeed.MaxSec;
    aStorage.FieldByName('Interval').AsInteger  := QuoteSpeed.Interval;

    aStorage.FieldByName('FutColor').AsInteger  := QuoteSpeed.FutColor;
    aStorage.FieldByName('CalColor').AsInteger  := QuoteSpeed.CalColor;
    aStorage.FieldByName('PutColor').AsInteger  := QuoteSpeed.PutColor;

    aStorage.FieldByName('FutUseSound').AsBoolean  := QuoteSpeed.FutUseSound;
    aStorage.FieldByName('CallUseSound').AsBoolean  := QuoteSpeed.CallUseSound;
    aStorage.FieldByName('PutUseSound').AsBoolean  := QuoteSpeed.PutUseSound;

    aStorage.FieldByName('FutSound').AsString   := QuoteSpeed.FutSound;
    aStorage.FieldByName('CallSound').AsString  := QuoteSpeed.CallSound;
    aStorage.FieldByName('PutSound').AsString   := QuoteSpeed.PutSound;
    aStorage.FieldByName('ShiftVal').AsFloat    := QuoteSpeed.ShiftVal;

    aStorage.FieldByName('TimeFontSize').AsInteger  := CurrentTimeSet.TimeFontSize;
    aStorage.FieldByName('TimeFontColor').AsInteger := CurrentTimeSet.TimeFontColor;
    aStorage.FieldByName('TimeBgColor').AsInteger   := CurrentTimeSet.TimeBgColor;
    aStorage.FieldByName('TimeOnTop').AsBoolean     := CurrentTimeSet.TimeOnTop;
    aStorage.FieldByName('BookMarkHotkey').AsInteger   := BookMarkHotkey;

  end;

end;

procedure TOrpMainForm.LoadEnv( aStorage : TStorage );
var
  isSave : boolean;
begin

  if aStorage = nil then Exit;

  Left  := aStorage.FieldByName('Left').AsInteger;
  Top   := aStorage.FieldByName('Top').AsInteger;

  Width := aStorage.FieldByName('width').AsInteger;
  Height:= aStorage.FieldByName('Height').AsInteger;

  with gEnv do
  begin
    isSave  := aStorage.FieldByName('IsSave').AsBoolean;
    if isSave then
    begin
      QuoteSpeed.Display  := aStorage.FieldByName('Display').AsBoolean;
      QuoteSpeed.MinSec   := aStorage.FieldByName('MinSec').AsFloat;
      QuoteSpeed.MaxSec   := aStorage.FieldByName('MaxSec').AsFloat;
      QuoteSpeed.Interval := aStorage.FieldByName('Interval').AsInteger;

      QuoteSpeed.FutColor := aStorage.FieldByName('FutColor').AsInteger;
      QuoteSpeed.CalColor := aStorage.FieldByName('CalColor').AsInteger;
      QuoteSpeed.PutColor := aStorage.FieldByName('PutColor').AsInteger;

      QuoteSpeed.FutUseSound := aStorage.FieldByName('FutUseSound').AsBoolean;
      QuoteSpeed.CallUseSound := aStorage.FieldByName('CallUseSound').AsBoolean;
      QuoteSpeed.PutUseSound := aStorage.FieldByName('PutUseSound').AsBoolean;

      QuoteSpeed.FutSound := aStorage.FieldByName('FutSound').AsString;
      QuoteSpeed.CallSound:= aStorage.FieldByName('CallSound').AsString;
      QuoteSpeed.PutSound := aStorage.FieldByName('PutSound').AsString;
      QuoteSpeed.ShiftVal := aStorage.FieldByName('ShiftVal').AsFloat;
    end
    else begin
      QuoteSpeed.Display  := false;
      QuoteSpeed.MinSec   := 0.3;
      QuoteSpeed.MaxSec   := 3;
      QuoteSpeed.Interval := 500;

      QuoteSpeed.FutColor := integer( clBlack );
      QuoteSpeed.CalColor := integer( clRed );
      QuoteSpeed.PutColor := integer( clBlue );

      QuoteSpeed.FutUseSound := false;
      QuoteSpeed.CallUseSound := false;
      QuoteSpeed.PutUseSound := false;
      QuoteSpeed.ShiftVal := 0.5;
    end;

    CurrentTimeSet.TimeFontSize  := aStorage.FieldByName('TimeFontSize').AsInteger;
    CurrentTimeSet.TimeFontColor := aStorage.FieldByName('TimeFontColor').AsInteger;
    CurrentTimeSet.TimeBgColor   := aStorage.FieldByName('TimeBgColor').AsInteger;
    CurrentTimeSet.TimeOnTop     := aStorage.FieldByName('TimeOnTop').AsBoolean;
    if CurrentTimeSet.TimeFontSize = 0 then
    begin
      CurrentTimeSet.TimeFontSize := 20;
      CurrentTimeSet.TimeFontColor := integer(clwhite);
      CurrentTimeSet.TimeBgColor := integer(clBlack);
      CurrentTimeSet.TimeOnTop := false;
    end;

    BookMarkHotkey := aStorage.FieldByName('BookMarkHotkey').AsInteger;
    if BookMarkHotkey = 0 then
      BookMarkHotkey := VK_F2;

  end;
end;

{$ENDREGION}

//-------------------------------------------------------< manage quote files >

{$REGION ' manage quote files... '}


function TOrpMainForm.LoadConfig : boolean;
var
  ini : TInitFile;
  incCount, iCount, iPos, i, iUse : integer;
  stTmp2, stTmp : string;
  cUser : char;
  dTmp : double;

begin
  Result := false;

  try
    ini := nil;
    ini := TInitFile.Create(FILE_ENV2);

    if ini = nil then
      Exit;

    gEnv.ConConfig.FutureIP   := ini.GetString('CONFIG','F_IP');
    gEnv.ConConfig.OrderPort  := ini.GetInteger('CONFIG','OrdPort');

    gEnv.ConConfig.UserID     := ini.GetString('CONFIG','USERID');
    gEnv.ConConfig.Password   := ini.GetString('CONFIG','PASSWORD');
    gEnv.ConConfig.ApType := ini.GetString('CONFIG','APTYPE') ;
    
    gEnv.ConConfig.SisAddr    := ini.GetString('CONFIG','SisAddr');
    gEnv.ConConfig.TradeAddr2    := ini.GetString('CONFIG','TradeAddr2');


    iUse  := ini.GetInteger('CONFIG', 'USEMDB');
    if iUse = 1 then
      gEnv.ConConfig.UseMdb := true
    else
      gEnv.ConConfig.UseMdb := false;


    stTmp := ini.GetString('CONFIG', 'QUOTEDIR');
    if stTmp = 'SAURI' then
      gEnv.QuoteDir :=''
    else
      gEnv.QuoteDir := stTmp;

    gEnv.SetRunMode(ini.GetInteger('CONFIG','RUNMODE'));
    gEnv.SetDBMode(ini.GetInteger('CONFIG','DATABASE'));
    stTmp := ini.GetString('CONFIG', 'TRADEDATE');

    if gEnv.RunMode = rtSimulation then
      gEnv.AppDate := EncodeDate(StrToIntDef(Copy(stTmp,1,4), 0),
                           StrToIntDef(Copy(stTmp,5,2), 0),
                           StrToIntDef(Copy(stTmp,7,2), 0))
    else
      gEnv.appDate := Date;

    gEnv.VirHultAutoMake    := ini.GetBoolean('CONFIG', 'VirtualHult');

    gEnv.Input.AcntNo     := ini.GetString('INPUT','ACNTNO');
    gEnv.Input.AcntPw   := ini.GetString('INPUT','ACNTPW');

    gEnv.Input.UID     := ini.GetString('INPUT','UID');
    gEnv.Input.MemNo   := ini.GetString('INPUT','MEMNO');
    gEnv.Input.BraNo   := ini.GetString('INPUT','BRANO');
    gEnv.Input.SID     := ini.GetString('INPUT','SID');

    gEnv.CheckPacketVersion;
    // ftp

    gEnv.ConConfig.FtpIP      := ini.GetString('FTP','IP');
    gEnv.ConConfig.FtpID      := ini.GetString('FTP','ID');
    gEnv.ConConfig.FtpPass    := ini.GetString('FTP','PS');
    gEnv.ConConfig.FtpRemoteD := ini.GetString('FTP','RD');
    gEnv.ConConfig.FtpLocalD  := ini.GetString('FTP','LD');
    // DB
    gEnv.ConConfig.DbIP       := ini.GetString('DB','IP');
    gEnv.ConConfig.DbID       := ini.GetString('DB','ID');
    gEnv.ConConfig.DbPass     := ini.GetString('DB','PASS');
    gEnv.ConConfig.DbSource   := ini.GetString('DB','SOURCE');
    gEnv.ConConfig.Mdb        := ini.GetString('DB','MDBNAME');

    // QUOTE_DB
    gEnv.ConConfig.Q_DbIP       := ini.GetString('QUOTEDB','IP');
    gEnv.ConConfig.Q_DbID       := ini.GetString('QUOTEDB','ID');
    gEnv.ConConfig.Q_DbPass     := ini.GetString('QUOTEDB','PASS');
    gEnv.ConConfig.Q_DbSource   := ini.GetString('QUOTEDB','SOURCE');

    // fees
    gEnv.Cost.FDues := ini.GetString('COST', 'FDues');
    gEnv.Cost.FCost := ini.GetString('COST', 'FMemberCost');
    gEnv.Cost.ODues := ini.GetString('COST', 'ODues');
    gEnv.Cost.OCost := ini.GetString('COST', 'OMemberCost');

    // udp port read
    iCount  := ini.GetInteger('UDP', 'COUNT');


    if iCount > 0 then
    begin
      gEnv.UdpPortCount := iCount;
      SetLength( gEnv.UdpPort, iCount );
      for i := 0 to iCount - 1 do begin
        stTmp := 'UDP_'+IntToStr(i);
        gEnv.UdpPort[i].Port      := ini.GetInteger( stTmp, 'Port' );
        gEnv.UdpPort[i].MultiIP   := ini.GetString(stTmp, 'MULTIIP');
        gEnv.UdpPort[i].UseMulti  := ini.GetBoolean(stTmp,'USEMULTI');
        gEnv.UdpPort[i].Use       := ini.GetBoolean(stTmp,'USE');
        gEnv.UdpPort[i].Name      := ini.GetString(stTmp, 'NAME');
        gEnv.UdpPort[i].MarketType:= ini.GetString(stTmp,'TYPE');
      end;
    end;

    gEnv.ConConfig.StartOrderNo := ini.GetInteger( 'ORDERNO', 'StartOrderNo' );
    gEnv.ConConfig.EndOrderNo := ini.GetInteger( 'ORDERNO', 'EndOrderNo' );
    gEnv.ConConfig.LastOrderNo:=  gEnv.ConConfig.StartOrderNo;
    gEnv.ConConfig.IncCount := 1;
    
    if gEnv.RunMode = rtRealTrading then
    begin
      ReadOrderNo;
      stTmp := stTmp + ' | ' + IntToStr( gEnv.ConConfig.LastOrderNo );
      gEnv.EnvLog( WIN_PACKET, stTmp );
    end;

  finally
    ini.Free
  end;
  Result := true;
end;

procedure TOrpMainForm.ReadOrderNo;
var
  f : TextFile;  bOK : boolean;
  stData, FileName : string;
  bExist : boolean;
begin
  FileName := ExtractFilePath(ParamStr(0))+'DataLog\';
  FileName := FileName + FormatDateTime('YYYYMMDD',GetQuoteTime) + '_'+gEnv.ConConfig.UserID + '.log';

  bExist  := FileExists(FileName);

  if not bExist then
    Exit;

  AssignFile( f, FileName );
  {$I-}
  Reset( f );
  bOK := IsErrorOccur(IOResult, 'Reset');    // ???????? IO ???? ????..
  {$I+}

  if not bOK then
  begin
    CloseFile(f);
    Exit;
  end;

  Try
    While( not Eoln(f) ) do
    Begin
      {$I-}
      ReadLn( f, stData );
      bOK := IsErrorOccur(IOResult, 'ReadLn');    // ???????? IO ???? ????..
      {$I+}
      If not bOK then ConTinue;

      gEnv.ConConfig.LastOrderNo := StrToIntDef( stData, gEnv.ConConfig.LastOrderNo );
    End;

  finally
    CloseFile(f);
  end;
end;

function TOrpMainForm.IsErrorOccur(iRes: integer; st: string): Boolean;
begin

  Result := true;

  if iRes <> 0 then begin
    MessageDlg('Order No File IO Error ( '+ st + InttoStr( GetLastError ) +' ) ', mtInformation, [mbOK], 0 );
    Result := false;
  end;
end;



procedure TOrpMainForm.LoadRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin

      if ValueExists('UseVolStop' ) then  gEnv.FillSnd[opVolStop].IsSound := ReadBool('UseVolStop')
      else gEnv.FillSnd[opVolStop].IsSound := false;

      if ValueExists('VolStopSound' ) then  gEnv.FillSnd[opVolStop].FillSnd := ReadString('VolStopSound')
      else gEnv.FillSnd[opVolStop].FillSnd := '';

      if ValueExists('UseBatchCnl') then gEnv.ConConfig.UseBatch  := ReadBool('UseBatchCnl')
      else gEnv.ConConfig.UseBatch  := false;
      if ValueExists('BatchInterval') then gEnv.ConConfig.BatchInterval := ReadInteger('BatchInterval')
      else gEnv.ConConfig.BatchInterval := 200 ;
      if ValueExists('BatchCount') then gEnv.ConConfig.BatchCount := ReadInteger('BatchCount')
      else gEnv.ConConfig.BatchCount := 6;

      if ValueExists('MakeOpt1MinUse') then gEnv.MakeOpt1Min.Use  := ReadBool('MakeOpt1MinUse')
      else gEnv.MakeOpt1Min.Use  := false;
      if ValueExists('MakeOpt1MinAbove') then gEnv.MakeOpt1Min.Above := ReadFloat('MakeOpt1MinAbove')
      else gEnv.MakeOpt1Min.Above  := 0.2 ;
      if ValueExists('MakeOpt1MinBelow') then gEnv.MakeOpt1Min.Below := ReadFloat('MakeOpt1MinBelow')
      else gEnv.MakeOpt1Min.Below  := 2.0;
    end;
  finally
    Free;
  end;
end;


procedure TOrpMainForm.SaveRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin

      WriteBool('UseVolStop', gEnv.FillSnd[opVolStop].IsSound );
      WriteString('VolStopSound', gEnv.FillSnd[opVolStop].FillSnd );
      WriteBool('UseBatchCnl', gEnv.ConConfig.UseBatch);
      WriteInteger('BatchInterval', gEnv.ConConfig.BatchInterval);
      WriteInteger('BatchCount', gEnv.ConConfig.BatchCount);

      WriteBool('MakeOpt1MinUse', gEnv.MakeOpt1Min.Use );
      WriteFloat('MakeOpt1MinAbove', gEnv.MakeOpt1Min.Above );
      WriteFloat('MakeOpt1MinBelow', gEnv.MakeOpt1Min.Below );
    end;
  finally
    Free;
  end;
end;

procedure TOrpMainForm.MergeQuoteFiles;
var
  aDateDlg: TDateDialog;
  stDate, stFOFile, stSEFile, stUniFile: String;
  FR1, FR2, FW: TextFile;
  stLine1, stLine2: String;
  bCheck: Boolean;
  stDir: String;
begin
    // get date
  aDateDlg := nil;
  try
    aDateDlg := TDateDialog.Create(Self);
    aDateDlg.Date := Date;

    if aDateDlg.Execute then
      stDate := FormatDateTime('yyyymmdd', aDateDlg.Date)
    else
      Exit;
  finally
    aDateDlg.Free;
  end;

    // file names
  stDir := ComposeFilePath([gEnv.RootDir, DIR_QUOTEFILES]);
  stFOFile := ComposeFilePath([stDir, stDate + '_drvreal.txt']);
  stSEFile := ComposeFilePath([stDir, stDate + '_sssreal.txt']);
  stUniFile := ComposeFilePath([stDir, stDate + '_real.txt']);

  try
      // check source files
    if not FileExists(stFOFile) or (not FileExists(stSEFile)) then
    begin
      DoLog(Self, 'Merge: One or all source files missing on that day.!');
      Exit;
    end;

      // check target file
    if FileExists(stUniFile)
       and (mrNo = MessageDlg('The merged file already exists. Overwrite?',
                              mtWarning, [mbYes, mbNo], 0)) then
      Exit;

      //
    try
      AssignFile(FR1, stFOFile);
      AssignFile(FR2, stSEFile);
      AssignFile(FW, stUniFile);

      Reset(FR1);
      Reset(FR2);
      Rewrite(FW);

      stLine2 := '';

      while not EOF(FR1) do
      begin
        Readln(FR1, stLine1);

        if Length(stLine2) > 0 then
        begin
          if CompareStr(stLine1, stLine2) > 0 then
          begin
            Writeln(FW, stLine2);
            stLine2 := '';

            bCheck := True;
          end else
            bCheck := False;
        end else
          bCheck := True;

        if bCheck then
          while not EOF(FR2) do
          begin
            Readln(FR2, stLine2);

            if CompareStr(stLine1, stLine2) > 0 then
            begin
              Writeln(FW, stLine2);
            end else
              Break;
          end;

        Writeln(FW, stLine1);
      end;

      if Length(stLine2) > 0 then
        Writeln(FW, stLine2);

    finally
      CloseFile(FR1);
      CloseFile(FR2);
      CloseFile(FW);
    end;
  finally
    DoLog(Self, 'Merge: Finished');
  end;
end;

procedure TOrpMainForm.MessageBookMark(var Msg: TMsg; var Handled: Boolean);
begin
  //if (Msg.message = WM_KEYDOWN) and (Integer(Msg.wParam) = gEnv.BookMarkHotkey)then
  //  gEnv.EnvLog(WIN_BOOKMARK, '');
end;

procedure TOrpMainForm.N16Click(Sender: TObject);
var
  i, iTag : integer;
  ExcelLog  : TExcelLog;
  aList : TStrings;
  stIO, stFillDir, stIoFile : string;
  F: TextFile;
begin

  iTag  := TMenuItem( Sender ).Tag;
  case iTag of
    0 :
      begin

      end;
    10 :
      begin
        {
        try

          aList := TStringList.Create;
          ExcelLog  := TExcelLog.Create;
          aList.Add('????');
          aList.Add('FutDelay');
          aList.Add('CalDelay');
          aList.Add('PutDelay');
          ExcelLog.LogInit( 'QuoteDelay',aList );

          for iTag := 0 to FQuoteDelays.Count - 1 do
          begin
            aItem := TQuoteDelayItem( FQuoteDelays.Items[iTag] );
            if aItem <> nil then begin
              aList.Clear;
              aItem.GetStrings( aList );
              ExcelLog.LogData( aList, iTag );
            end;
          end;

        finally
          ExcelLog.Free;
          aList.Free;
        end;
        }
      end;
    20 : gEnv.Engine.QuoteBroker.ResetDelayTime;
    40, 50, 60 :
      begin
        case iTag of
          40 : FTradeReceiver.FSocket[SEND_SOCK].SocketDisconnect;     
          50 : FTradeReceiver.FSocket[RECV_SOCK].SocketDisconnect;
          60 : FTradeReceiver.FSocket[FILL_SOCK].SocketDisconnect;
   
        end;
      end;
    70 : ;
      //FTradeReceiver.FSocket[SEND_SOCK].LogOut;

  end;// end case

end;


procedure TOrpMainForm.OnLemonState(asType: TAppStatus);
var MasterFile : string;
  bResult : boolean;
  stTxt : string;
begin

  case asType of
    asError :
      begin
        ShowMessage( Format('Error : %s', [ gEnv.ErrString ] ));
        gEnv.ErrString := '';
      end;
    asInit:
    begin
      StepInitSymbolLoad;
    end;
    asConMaster :
    begin
      FTradeReceiver.startConnect( SEND_SOCK );
    end;
    asConFut:
    begin
      FTradeReceiver.startConnect( SEND_SOCK );
    end;
    asRecoveryEnd: SetpRecoveryEnd;
    asStart:
      begin
        case gEnv.RunMode of
          rtRealTrading : stTxt := 'Real Trading';
          rtSimulUdp : stTxt := 'Sis-Udp Ord-Virtual';
          rtSimulation : stTxt := 'Simulation';
          else
            stTxt := '';
        end;

        if gEnv.RunMode <> rtRealTrading then
          StatusBar.Panels[0].Text := stTxt;

        // ?????? ???? ?????? ????..
        case gEnv.RunMode of
          rtRealTrading,
          rtSimulUdp :
            begin
              gEnv.SetAppStatus( asLoad );
              Show;
            end;
          rtSimulation :
            begin
              gEnv.SetAppStatus( asLoad );
              Show;
            end;

        end;
      end;
    asLoad  :
      // ???? ????
      begin
        if gEnv.RunMode = rtSimulation then
        begin
          gEnv.SetFees;
          initQ;
          Exit;
        end;
        gEnv.SetFees;
        initQ;
      end;
    asSimul :
      StepSimulation;
    asLogOut :
    begin
      //FTradeReceiver.FSocket[SOCK_MO].
      //FTradeReceiver.FSocket[SOCK_MO].SocketDisconnect;     khw
    end;
  end;
end;


procedure TOrpMainForm.OnSocketState(Value: string; idx : integer);
begin
  if gEnv.RunMode = rtRealTrading then
  begin
    StatusBar.Panels[idx].Text  := Value;

    { khw
    if idx = 2 then
    begin
      if TradeReceiver.FSocket[4].SocketState = ssConnected then
      begin
        btnMothCon.Enabled := false;
        btnMothDis.Enabled := true;
      end
      else begin
        btnMothCon.Enabled := true;
        btnMothDis.Enabled := false;
      end;
    end;
         }
  end;
end;

procedure TOrpMainForm.OnWindowMenuClick(Sender: TObject);
var
  iTag : integer;
  aItem : TMenuItem;
  aForm : TForm;
begin
   iTag  := TMenuItem( Sender ).Tag;
   aItem := TMenuItem( Sender );
   aForm := gEnv.Engine.FormBroker.FindFormMenu(aItem) as TForm;
   if aForm = nil then exit;
   aForm.WindowState := wsNormal;
   aForm.Show;
end;


procedure TOrpMainForm.OrderReset(Sender: TObject; bBack : boolean;Value: Integer);
begin
  gEnv.Engine.TradeCore.Reset( Value, bBack );    
end;

procedure TOrpMainForm.PeekQuoteFile;
var
  F: TextFile;
  iCount: Integer;
  stLine, stAscii: String;
  i: Integer;
  stFile: String;
begin
    // get file name
  if OpenDialog.Execute then
    stFile := OpenDialog.FileName
  else
    Exit;

    // check file
  if not FileExists(stFile) then
  begin
    DoLog(Self, 'Peek: No file found');
    Exit;
  end;

  AssignFile(F, stFile);
  try
    Reset(F);

    iCount := 0;
    while not EOF(F) do
    begin
      Readln(F, stLine);
      Inc(iCount);
      if Length(stLine) > 100 then
        DoLog(Self,  Format('Peek[%d]->%s...$', [iCount, Copy(stLine, 1, 100)]))
      else
        DoLog(Self,  Format('Peek[%d]->%s$', [iCount, Copy(stLine, 1, 100)]));
      if iCount > 100 then Break;

      //stAscii := '';
      //for i := 1 to Length(stLine) do
      //  stAscii := stAscii + stLine[i] + Format('(%d)',[Ord(stLine[i])]);
      //DoLog(Self, 'Ascii:' + stAscii);
    end;
  finally
    CloseFile(F);
  end;
end;

procedure TOrpMainForm.ClipQuoteFile;
var
  FR, FW: TextFile;
  iCount: Integer;
  stLine, stAscii: String;
  i: Integer;
  stFile: String;
begin
    // get file name
  if OpenDialog.Execute then
    stFile := OpenDialog.FileName
  else
    Exit;

    // check file
  if not FileExists(stFile) then
  begin
    DoLog(Self, 'Clip: No file found');
    Exit;
  end;

  AssignFile(FR, stFile);
  AssignFile(FW, stFile + '.clip.txt');
  try
    Reset(FR);
    Rewrite(FW);

    iCount := 0;
    while not EOF(FR) do
    begin
      Readln(FR, stLine);
      Writeln(FW, Copy(stLine, 1, 20));
      Inc(iCount);
      if iCount > 10000 then Break;
    end;

    DoLog(Self, 'Clip: Finished');
  finally
    CloseFile(FR);
    CloseFile(FW);
  end;
end;



procedure TOrpMainForm.CheckQuoteFile;
var
  FR: TextFile;
  iCount: Integer;
  stLine, stAscii: String;
  i: Integer;
  stFile: String;
begin
    // get file name
  if OpenDialog.Execute then
    stFile := OpenDialog.FileName
  else
    Exit;

    // check file
  if not FileExists(stFile) then
  begin
    DoLog(Self, 'Check: No file found');
    Exit;
  end;

  AssignFile(FR, stFile);
  try
    Reset(FR);

    iCount := 0;
    while not EOF(FR) do
    begin
      Readln(FR, stLine);

      Inc(iCount);
      if (stLine[3] <> ':') or (stLine[6] <> ':') then
      begin
        DoLog(Self, Format('Check[%d]-abnormal: %s', [iCount, stLine]));
        Exit;
      end;
    end;

    DoLog(Self, Format('Check: Finished %d lines',[iCount]));
  finally
    CloseFile(FR);
  end;
end;

{$ENDREGION}

//------------------------------------------------------------< miscellaneous >

procedure TOrpMainForm.DoLog(Sender: TObject; stLog: String);
begin
   {
  MemoLog.Font.Size := 9;
  if gEnv.RunMode in [ rtSimulUdp, rtSimulation ] then
    MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss]', Now)+ ' ' + stLog);
  }
end;

procedure TOrpMainForm.DoTimeLog(Sender: TObject; stLog: String);
begin
  {
  if MemoLog.Lines.Count > 0 then
    MemoLog.Lines[0]  := stLog
  else
    MemoLog.Lines.Add(stLog );
  }
  //Caption := 'Guru Ver.' + FileVersionToStr(Application.ExeName);
  //Caption := Caption + ' | ' + stLog;

end;

procedure TOrpMainForm.EventIdle(Sender: TObject; var Done: Boolean);
begin
  //SaveLastOrderNo;
end;

procedure TOrpMainForm.Exit2Click(Sender: TObject);
begin
  Application.Terminate;
end;



procedure TOrpMainForm.AppException(Sender: TObject; E: Exception);
begin
  gEnv.AppMsg( WIN_ERR, 'Application Error : ' + E.Message );
end;

//------------------------------------------------------------< ?????? ???? >

procedure TOrpMainForm.BranchMode;
var
  bExist : boolean;
  stTxt  : string;
begin

  case gEnv.RunMode of
    rtRealTrading : stTxt := 'Real Trading';
    rtSimulUdp : stTxt := 'Sis-Udp Ord-Virtual';
    rtSimulation : stTxt := 'Simulation';
  end;

  gLog.Add( lkApplication, 'TOrpMainForm', 'Mode', 'Guru Mod is ' + stTxt );

  case gEnv.RunMode of
    rtRealTrading, rtSimulUdp , rtSimulation :
      begin
        gEnv.SetAppStatus( asInit );
      end;
  end;
end;

procedure TOrpMainForm.StepInitSymbolLoad;
var
  bResult : boolean;
begin
  FEngine.FormBroker.OnOpen := FormOpen;
  FEngine.FormBroker.OnLoad := FormLoad;
  FEngine.FormBroker.OnSave := FormSave;
  FEngine.FormBroker.OnReLoad := FormReLoad;

  FEngine.Holidays.Load(FILE_HOLIDAYS);

  ForceDirectories(gEnv.DataDir);
  ForceDirectories(gEnv.OutputDir);
  OpenDialog.InitialDir := gEnv.RootDir;

  FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FQuoteTimer.Interval := 200;
  FQuoteTimer.OnTimer := QuoteTimerProc;
  FQuoteTimer.Enabled := True;

  gEnv.MySQLConnector := TMySQLConnector.Create;
  gEnv.MySQLConnector.Server := gEnv.ConConfig.DbIP;
  gEnv.MySQLConnector.DB := gEnv.ConConfig.DbSource;
  gEnv.MySQLConnector.User := gEnv.ConConfig.DbID;
  gEnv.MySQLConnector.Password := gEnv.ConConfig.DbPass;
  gEnv.MySQLConnector.Mdb := gEnv.ConConfig.Mdb;

  FSymbolLoader   := TKrxSymbolMySQLLoader.Create(FEngine, gEnv.MySQLConnector);
  FAccountLoader  :=  TAccountLoader.Create(FEngine, gEnv.MySQLConnector );

  gEnv.MySQLConnector.SetConString( false );
  bResult := FAccountLoader.Load;

  if not bResult then begin
    ShowMessage( ' ???? ???? ???? !!! ' +  FormatDateTime( 'YYYY-MM-DD', gEnv.AppDate) );
    Application.Terminate;
  end;

  gLog.Add( lkApplication, 'TOrpMainForm', 'Load', '???? ?????? ????' );

  case gEnv.RunMode of
    rtRealTrading, rtSimulUdp , rtSimulation :
      begin
        FSymbolLoader.SetSpecs;

        if gEnv.RunMode = rtSimulation then begin
          gEnv.MySQLConnector.SetConString( false );
          gEnv.Engine.QuoteBroker.Timers.Realtime := False;
          gEnv.Engine.QuoteBroker.Timers.Reset(gEnv.AppDate);
          gEnv.SetAppStatus( asRecoveryEnd );
          //bResult := FSymbolLoader.Load( gEnv.AppDate );
        end
        else begin
          bResult := FtpSymbolLoad;
        end;

        if not bResult then begin
          ShowMessage( ' ???? ?????? ???? !!! ' +  FormatDateTime( 'YYYY-MM-DD', gEnv.AppDate) );
          Application.Terminate;
          gEnv.SetAppStatus( asError );
        end
        else begin

          gLog.Add( lkApplication, 'TOrpMainForm', 'Load',
              '?????????? ?????? ????' );
          //---------------------------------------
          FTradeReceiver := TKRXTradeReceiver.Create;
          FTradeReceiver.TradeDate  := GetQuoteDate;

          if gEnv.RunMode = rtRealTrading then
          begin
            gEnv.SetAppStatus( asConMaster );
          end else
          begin
            gEnv.SetAppStatus( asRecoveryEnd );
          end;

          //-----------------------------------------
        end;
      end;
  end;
end;


procedure TOrpMainForm.SetpRecoveryEnd;
var
  ivar : integer;
  bGiSis  : boolean;
begin
  case gEnv.RunMode of
    rtRealTrading :
      begin
        FOrderBroker := TKRXOrderBroker.Create;

        FEngine.TradeBroker.OnSendOrder := FOrderBroker.Send;
        FOrderBroker.OnFOTrade    := FTradeReceiver.FSocket[SEND_SOCK].SendTrade;

        FQuoteReceiver := TKrxQuoteUDPReceiver.Create;
        FQuoteReceiver.Start( gEnv.RunMode = rtSimulation ) ;
        FQuoteReceiver.Parser.QuoteDate := gEnv.AppDate;
        gEnv.SetAppStatus( asStart );
      end;
    rtSimulUdp, rtSimulation :
      begin
        FOrderBroker := TKRXOrderBroker.Create;

        FQuoteReceiver := TKrxQuoteUDPReceiver.Create;
        FQuoteReceiver.Start( gEnv.RunMode = rtSimulation ) ;
        FQuoteReceiver.Parser.QuoteDate := gEnv.AppDate;

        gEnv.SetAppStatus( asStart );
      end;
  end;
end;

procedure TOrpMainForm.Show1Click(Sender: TObject);
begin
  show;
end;

procedure TOrpMainForm.StepSimulation;
begin
  gEnv.Engine.SyncFuture.Init;
  gEnv.Engine.SymbolCore.Prepare;
end;

procedure TOrpMainForm.initQ;
begin

  gEnv.Engine.CreateSyncFuture;

  if gEnv.RunMode <> rtSimulation then
    gEnv.Engine.SyncFuture.Init;
  gLog.Add( lkApplication, 'TOrpMainForm', 'Load', '???? ???? ????' );

  gEnv.CreateBoardEnv;


  // ???? ???? ????..

  if gEnv.RunMode <> rtSimulation then
  begin
    gEnv.Engine.SymbolCore.Prepare;
  end;

  if gEnv.RunMode = rtSimulation then
    gEnv.Engine.FormBroker.Open(ID_QUOTE_SIMULATION, 0)
  else
    gEnv.Engine.FormBroker.Load(ComposeFilePath([gEnv.DataDir, FILE_ENV]));
  BackUpWindows;
  gEnv.Engine.Timers.init;

end;


procedure TOrpMainForm.BackUpWindows;
var
  stDir, stExt : string;
  stNewName, stOldName, stSrcDir : string;
  bRes, bPaste : Boolean;
  iPos : integer;
begin
  stDir := ExtractFilePath( paramstr(0) )+'back';
  stSrcDir := ExtractFilePath( paramstr(0) )+'database';
  if not DirectoryExists( stDir ) then
  begin
    CreateDir(stDir);
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Create Backup Folder..' );
  end;

  stExt := ExtractFileExt( FILE_ENV );
  iPos  := Length( FILE_ENV ) - Length( stExt );
  stOldName := Copy( FILE_ENV, 1, iPos );

  stNewName := Format('%s_%s%s', [ stOldName, FormatDateTime('yyyymmdd', now ), stExt ]);

  stOldName := stSrcDir + '\' + FILE_ENV;
  stNewName := stDir + '\' + stNewName;

  bPaste  := true;
  bRes := CopyFile(  PChar(stOldName), PChar(stNewName), bPaste );

  if bRes then
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Backup File to Back folder' )
  else if (not bPaste) and ( not bRes) then
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Failed Move File to Back folder' );
end;


procedure TOrpMainForm.OpenWins;
var
  stName, stFile, stDir : string;

begin
  stDir := ExtractFilePath( paramstr(0) )+'back';

  if not DirectoryExists( stDir ) then
    stDir := ExtractFilePath( paramstr(0) ) ;

  OpenDialog.InitialDir := stDir;

  if OpenDialog.Execute then
    stFile := OpenDialog.FileName;


  if stFile <> '' then
  begin
    stName := ExtractFileName( stFile );
    if MessageDlg(stName + ' ?????? ???????? ?????????????',
          mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;

    gEnv.Engine.FormBroker.CloseWindow;
    gEnv.Engine.FormBroker.Load(stFile);
  end;

end;

end.

