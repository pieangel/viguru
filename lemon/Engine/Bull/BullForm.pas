unit BullForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, Grids, FileCtrl,
  GleTypes, GleConsts, CleAccounts, ClePositions, CleSymbols, CleDistributor,
  CleOrders, EnvFile, GAppConsts, CleMarkets,
  BullData, BullTrade, BullSystem, CleQuoteTimers, CleStorage;

type
  TBullSystemForm = class(TForm)
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Bevel2: TBevel;
    Label7: TLabel;
    ckE1: TCheckBox;
    ckLE_Enabled: TCheckBox;
    ckSE_Enabled: TCheckBox;
    ckTimeCancel: TCheckBox;
    edCancelTime: TEdit;
    Label10: TLabel;
    edE1P1: TEdit;
    edE1P2: TEdit;
    ckX1: TCheckBox;
    Label1: TLabel;
    ckX2: TCheckBox;
    ButtonAuto: TSpeedButton;
    ComboAccount: TComboBox;
    ComboSymbol: TComboBox;
    ButtonSymbol: TSpeedButton;
    ButtonFix: TSpeedButton;
    Timer2: TTimer;
    Label26: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ckX3: TCheckBox;
    ckE2: TCheckBox;
    edE2P1: TEdit;
    Bevel1: TBevel;
    TabConfig: TTabControl;
    StatusTrade: TStatusBar;
    GridInfo: TStringGrid;
    edNewOrderQty: TEdit;
    edMaxPosition: TEdit;
    edMaxQuoteQty: TEdit;
    edE1P3: TEdit;
    edE1P4: TEdit;
    edE1P5: TEdit;
    edE1P6: TEdit;
    edX1P1: TEdit;
    edX1P2: TEdit;
    edX2P1: TEdit;
    edX2P2: TEdit;
    cbRun: TCheckBox;
    Button1: TButton;
    cbActive: TCheckBox;
    procedure cbRunClick(Sender: TObject);
    procedure GridInfoClick(Sender: TObject);
    procedure TabConfigChange(Sender: TObject);
    procedure ButtonAutoClick(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure OnChkboxClick(Sender: TObject);
    procedure OnEditboxChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FConfig : TBullConfig;

    FAccount : TAccount;
    FOption : TSymbol;
    FFuture : TSymbol;

    FTrade : TBullTrade;             // 자동매매

    FDisplay : Boolean;
    FTimer : TQuoteTimer;
    FClear : Boolean;
    //procedure StopAll;
    //procedure GetServer;
    procedure ResultProc(Sender: TObject; bSuccess: Boolean; stMsgType, stData: String);
    //procedure SetServer;

    procedure ApplyConfig;
    procedure DisplayConfig;
    procedure GetConfig;
    function  OpenConfig(stConfig: String): Boolean;
    function  SaveConfig(stConfig: String): Boolean;
    procedure TradeStatusChanged(Sender: TObject);
    procedure CallWorkForm(Sender: TObject);
    function  GetConfigDir: String;
    procedure Stop;
    procedure UpdateConfig;
    procedure TradeSignalChanged(Sender: TObject);
    procedure MothResultProc(const S: string);
    procedure TimerTimer(Sender: TObject);


  public

    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure BullMessage( var Msg : TMessage ) ;  message WM_BULLMESSAGE;
    property Config : TBullConfig read FConfig;
  end;


var
  BullSystemForm: TBullSystemForm;

implementation

uses GleLib, GAppEnv, CleFQN;


{$R *.DFM}


// 설정 버튼
procedure TBullSystemForm.ApplyConfig;
begin
  FTrade.Config := FConfig;

    // 화면표시
  DisplayConfig;
end;

procedure TBullSystemForm.GetConfig;
begin
  with FConfig do
  begin
    EntryLong_Checked := ckLE_Enabled.Checked;
    EntryShort_Checked := ckSE_Enabled.Checked;
    EntryTimeCancel_Checked := ckTimeCancel.Checked;
      EntryCancelTime := StrToFloat(edCancelTime.Text);

    E1_Checked := ckE1.Checked;
      E1_P1 := StrToFloat(edE1P1.Text);
      E1_P2 := StrToFloat(edE1P2.Text);
      E1_P3 := StrToFloat(edE1P3.Text);
      E1_P4 := StrToFloat(edE1P4.Text);
      E1_P5 := StrToFloat(edE1P5.Text);
      E1_P6 := StrToFloat(edE1P6.Text);
    E2_Checked := ckE2.Checked;
      E2_P1 := StrToIntDef(edE2P1.Text, 0);
    X1_Checked := ckX1.Checked;
      X1_P1 := StrToFloat(edX1P1.Text);
      X1_P2 := StrToFloat(edX1P2.Text);
    X2_Checked := ckX2.Checked;
      X2_P1 := StrToFloat(edX2P1.Text);
      X2_P2 := StrToFloat(edX2P2.Text);
    X3_Checked := ckX3.Checked;

    NewOrderQty := StrToIntDef(edNewOrderQty.Text, 0);
    MaxPosition := StrToIntDef(edMaxPosition.Text, 0);
    MaxQuoteQty := StrToIntDef(edMaxQuoteQty.Text, 0);

    CButton := TabConfig.TabIndex;
  end;
end;

procedure TBullSystemForm.DisplayConfig;
begin
  FDisplay := True;
  with FConfig do
  begin
    ckLE_Enabled.Checked := EntryLong_Checked;
    ckSE_Enabled.Checked := EntryShort_Checked;
    ckTimeCancel.Checked := EntryTimeCancel_Checked;
    edCancelTime.Text := Format('%.1f', [EntryCancelTime]);

    ckE1.Checked := E1_Checked;
      edE1P1.Text := Format('%.1f', [E1_P1]);
      edE1P2.Text := Format('%.1f', [E1_P2]);
      edE1P3.Text := Format('%.1f', [E1_P3]);
      edE1P4.Text := Format('%.1f', [E1_P4]);
      edE1P5.Text := Format('%.1f', [E1_P5]);
      edE1P6.Text := Format('%.1f', [E1_P6]);
    ckE2.Checked := E2_Checked;
      edE2P1.Text := Format('%d', [E2_P1]);
    ckX1.Checked := X1_Checked;
      edX1P1.Text := Format('%.1f', [X1_P1]);
      edX1P2.Text := Format('%.1f', [X1_P2]);
    ckX2.Checked := X2_Checked;
      edX2P1.Text := Format('%.1f', [X2_P1]);
      edX2P2.Text := Format('%.1f', [X2_P2]);
    ckX3.Checked := X3_Checked;

    edNewOrderQty.Text := IntToStr(NewOrderQty);
    edMaxPosition.Text := IntToStr(MaxPosition);
    edMaxQuoteQty.Text := IntToStr(MaxQuoteQty);
  end;
  FDisplay := False;
end;

//-----------------------------------------------------------------------//
                { 설정  관리 }
//-----------------------------------------------------------------------//
function TBullSystemForm.GetConfigDir : String;
var
  stDir : String;
begin
    // 설정 하위 디렉토리
  stDir := '\'+DIR_TEMPLATE +'\'+ TPKEY_BullSystem + '\';

    // 디렉토리가 없으면 디랙토리를 생성한다
  if not DirectoryExists(gEnv.RootDir + '\'+DIR_TEMPLATE) then
    CreateDir(gEnv.RootDir + '\'+DIR_TEMPLATE);
  if not DirectoryExists(gEnv.RootDir + stDir) then
    CreateDir(gEnv.RootDir + stDir);

  Result := stDir;
end;

procedure TBullSystemForm.GridInfoClick(Sender: TObject);
begin

end;



// 개별 설정 열기
function TBullSystemForm.OpenConfig(stConfig : String) : Boolean;
var
  stDir, stFile : String;
  iVersion : Integer;
  aEnvFile : TEnvFile;
  aBinStream : TMemoryStream;
  aStrStream : TStringStream;
begin
  Result := False;

  stDir := GetConfigDir;

  //-- select template
  aEnvFile := TEnvFile.Create;
  aBinStream := TMemoryStream.Create;
  aStrStream := TStringStream.Create('');
  try
    stFile := stDir + stConfig + '.' + TEMPLATE_SUFFIX;
    if not aEnvFile.Exists(stFile) then
    begin
//      ShowMessage(Format('''%s'' 를 찾을 수 없슴-> 신규 설정',[stFile]));
      Exit;
    end;

    if aEnvFile.LoadLines(stFile) and
       (aEnvFile.Lines.Count >= 3) then
    try
      //--1. key
      if CompareStr(TPKEY_BullSystem, aEnvFile.Lines[0]) <> 0 then
      begin
        ShowMessage('잘못된 형식입니다.');
        Exit;
      end;

      //--2. version
      iVersion := StrToIntDef(aEnvFile.Lines[1], 0);
      //--3. data
        // string -> string stream
      aStrStream.Seek(0, soFromBeginning);
      aStrStream.WriteString(aEnvFile.Lines[2]);
        // string stream-> binary stream
      aBinStream.Clear;
      aBinStream.LoadFromStream(aStrStream);
      //-- load
      aBinStream.Read(FConfig, SizeOf(FConfig)); // Config 읽기
      //
      Result := True;
    except
      ShowMessage(stConfig + '을(를) 읽는중에 문제가 발생했습니다.');
    end;
  finally
    aStrStream.Free;
    aBinStream.Free;
    aEnvFile.Free;
  end;
end;

// 개별 시나리오 저장
function TBullSystemForm.SaveConfig(stConfig : String) : Boolean;
var
  aBinStream : TMemoryStream;
  aStrStream : TStringStream;
  aEnvFile : TEnvFile;
  stDir : String;
begin
  Result := False;

    // 디렉토리 확인
  stDir := GetConfigDir;

    //
  aEnvFile := TEnvFile.Create;
  aBinStream := TMemoryStream.Create;
  aStrStream := TStringStream.Create('');
  try
    try
      aEnvFile.Lines.Clear;
      //--1. key
      aEnvFile.Lines.Add(TPKEY_BullSystem);
      //--2. version
      aEnvFile.Lines.Add(IntToStr(GURU_VERSION));
      //--3. data
      aBinStream.Clear;
      aBinStream.Write(FConfig, SizeOf(FConfig)); // Config 자료 저장
      aStrStream.Seek(0, soFromBeginning);
      aBinStream.SaveToStream(aStrStream);
      aEnvFile.Lines.Add(aStrStream.DataString);
      // save
      aEnvFile.SaveLines(stDir + stConfig + '.' + TEMPLATE_SUFFIX);
      //
      Result := True;
    except
      ShowMessage(stConfig + '을(를) 저장중에 문제가 발생했습니다.');
    end;
  finally
    aBinStream.Free;
    aStrStream.Free;
    aEnvFile.Free;
  end;
end;

procedure TBullSystemForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('cbActivate').AsBoolean := cbActive.Checked;
end;

procedure TBullSystemForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  cbActive.Checked  := aStorage.FieldByName('cbActivate').AsBoolean;
end;

procedure TBullSystemForm.MothResultProc(const S: string);
begin
  StatusTrade.Panels[1].Text := FormatDateTime('hh:nn:ss', Now)+' '+ S;
end;

procedure TBullSystemForm.TabConfigChange(Sender: TObject);
var
  stConfig : String;
begin
  Stop;
  if TabConfig.TabIndex >= 0 then
  begin
    stConfig := TabConfig.Tabs[TabConfig.TabIndex];
    if Length(stConfig) > 0 then
      if OpenConfig(stConfig) then
        ApplyConfig
      else
        SaveConfig(stConfig);
  end;
  cbRun.Checked := False;
end;

procedure TBullSystemForm.Stop;
begin
  if ButtonAuto.Down then
  begin
    ButtonAuto.Down := False;
    ButtonAuto.Click;
  end;
end;

procedure TBullSystemForm.ButtonAutoClick(Sender: TObject);
begin
  if ButtonAuto.Down then
  begin
    ButtonAuto.Caption := 'Run';
    UpdateConfig;
  end
  else
  begin
    ButtonAuto.Caption := 'Stop';
    FConfig.StartStop := 0;
  end;
  FTrade.AutoTrade := ButtonAuto.Down;

  // Run 일때 Clear버튼 클릭하면... Stop Run 두번실행...
  // 그래서 클리어 이면서 스탑이면.. 제외
  if (FConfig.StartStop = 0) and (FClear) then exit;

end;

procedure TBullSystemForm.BullMessage(var Msg: TMessage);
begin
  if Msg.LParam = 100 then
  begin
    if ButtonAuto.Down then
      Exit
    else begin
      ButtonAuto.Down := true;
      ButtonAutoClick( ButtonAuto );
    end;
  end
  else begin
    if ButtonAuto.Down then
    begin
      ButtonAuto.Down := false;
      ButtonAutoClick( ButtonAuto );
    end
    else
      Exit;
  end;
end;

procedure TBullSystemForm.Button1Click(Sender: TObject);
begin
  FClear := true;
  if cbActive.Checked then
    gEnv.Engine.FormBroker.DoActivae;
  Stop;
  FTrade.BullOrders.Clear;
  FTrade.OnStatusNotify(nil);
  ButtonAuto.Down := true;
  ButtonAutoClick( ButtonAuto );
  FClear := false;
//  gEnv.Engine.FormBroker.Selected
end;


procedure TBullSystemForm.CallWorkForm(Sender : TObject);
begin
  if Sender = nil then Exit;
end;

procedure TBullSystemForm.cbRunClick(Sender: TObject);
begin
  //SetServer;
end;

// 타이머
procedure TBullSystemForm.Timer2Timer(Sender: TObject);
begin
  FTrade.BeatProc;
end;

procedure TBullSystemForm.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  Stop;
    // 계좌 변경
  FAccount := aAccount;

    // 자동매매 객체에 할당
  FTrade.Account := FAccount;
end;

procedure TBullSystemForm.ComboSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if ComboSymbol.ItemIndex = -1 then Exit;

    // get account object
  aSymbol := ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbol;

    // only option is allowed
  if (aSymbol = nil) or (aSymbol.Spec.Market <> mtOption) then Exit;

    // check dupliticity
  if FOption = aSymbol then Exit;

  Stop;
  
    // set new symbol
  FOption := aSymbol;

    // 자동매매
  FTrade.Option := FOption;

  //??gWin.Synchronize(Self, [FOption]);
end;

procedure TBullSystemForm.FormCreate(Sender: TObject);
var
  i : integer;
  aFuture : TFuture;
  FFutureMarket : TFutureMarket;
  aMarkets : TMarketTypes;
begin

  FDisplay := False;
  FClear := false;

    // populate combos
  gEnv.Engine.TradeCore.Accounts.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption, mtSpread ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists( ComboSymbol.Items , aMarkets);


  // 선물 현재가 구독 -> 선물 채널 브레이크 감시를 위함

  FFutureMarket  := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];
  aFuture := FFutureMarket.FrontMonth;

  FFuture := aFuture;

  FTrade := TBullTrade.Create;
  FTrade.OnStatusNotify := TradeStatusChanged;
  FTrade.OnSignalNotify := TradeSignalChanged;

    // init objects
  FAccount := nil;
  FOption := nil;

    // 시나리오 선택
  TabConfigChange(TabConfig);

    // '자동/수동' 버튼 초기화
  ButtonAutoClick(ButtonAuto);

    // 첫번째 계좌 선택
  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;


  with GridInfo do
  begin
    ColWidths[0] := Width div 4;
    ColWidths[1] := Width div 4;
    ColWidths[2] := Width div 2;
  end;

  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  with FTimer do
  begin
    Enabled := True;
    Interval := 100;
    OnTimer := TimerTimer;
  end;
end;

procedure TBullSystemForm.FormDestroy(Sender: TObject);
begin
  FTimer.Free;
    // free delegation objects
  FTrade.Free;
end;

procedure TBullSystemForm.FormActivate(Sender: TObject);
begin
  if (Tag <=0 ) or ( 100 <= Tag ) then
    Exit
  else
    Caption := Format('%dth Bull Set', [ Tag ] );
end;

procedure TBullSystemForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TBullSystemForm.ButtonSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, ComboSymbol);
        // apply
      ComboSymbolChange(ComboSymbol);
    end;
  finally
    gSymbol.Hide
  end;


end;

procedure TBullSystemForm.TradeSignalChanged(Sender : TObject);
var
  aChange : Double;
  stTime : String;
begin
  with GridInfo, FTrade.BullResult do
  begin
    aChange := OptionFitPrices[Last]-OptionFitPrices[Prev];

    Cells[0,0] := Format('%.3f', [OptionAvgPrices[Last]]);
    Cells[0,1] := Format('%.3f', [OptionFitPrices[Last]]);
    Cells[0,2] := Format('%.3f', [aChange]);
    Cells[0,3] := Format('%.3f', [OptionSeparation]);
    Cells[1,0] := Format('%.2f', [FutureAvgPrices[Last]]);
    Cells[1,1] := Format('%.2f', [FutureMA]);
    Cells[1,2] := Format('%.1f%%', [RealIV*100.0]);
    Cells[1,3] := Format('%.1f%%', [RealDelta*100.0]);

    if (EventKind = beFuture) and
       (abs(aChange) > FConfig.X1_P1/100.0) and
       (abs(OptionSeparation) > FConfig.X1_P2/100.0) then
    begin
      stTime := FormatDateTime('nn:ss', GetQuoteTime);
      Cells[2,3] := Cells[2,2];
      Cells[2,2] := Cells[2,1];
      Cells[2,1] := Cells[2,0];
      Cells[2,0] := Format('%s  %.3f   %.3f', [stTime, aChange, Optionseparation]);
    end;
  end;
end;

procedure TBullSystemForm.OnChkboxClick(Sender: TObject);
begin
  if FDisplay then Exit;

  UpdateConfig;
end;

procedure TBullSystemForm.UpdateConfig;
var
  stConfig : String;
begin

  GetConfig;
  ApplyConfig;
  if TabConfig.TabIndex >= 0 then
  begin
    stConfig := TabConfig.Tabs[TabConfig.TabIndex];
    if Length(stConfig) > 0 then
      SaveConfig(stConfig);
  end;
end;

procedure TBullSystemForm.OnEditboxChange(Sender: TObject);
begin
  Stop;
end;

procedure TBullSystemForm.TradeStatusChanged(Sender: TObject);
begin
  StatusTrade.Panels[0].Text := FormatDateTime('hh:nn:ss ', GetQuoteTime)+FTrade.Status;
//  StatusTrade.Panels[0].Text := FTrade.Status;
end;

// 타이머
procedure TBullSystemForm.TimerTimer(Sender: TObject);
begin
  FTrade.BeatProc;
end;

procedure TBullSystemForm.ResultProc(Sender : TObject; bSuccess : Boolean; stMsgType, stData : String);
begin
  if bSuccess then
    StatusTrade.Panels[1].Text := FormatDateTime('hh:nn:ss', Now)+' Send to Server OK'
  else
    StatusTrade.Panels[1].Text := FormatDateTime('hh:nn:ss', Now)+' Server Rejected!';
end;

end.
