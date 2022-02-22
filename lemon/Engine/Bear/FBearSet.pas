unit FBearSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, ComCtrls
  //
  ,EnvFile, CleAccounts, CleSymbols, GleConsts, GleTypes, GleLib, GAppConsts

  //
  ,CleStorage, BearTrade, BearConfig, BearLog
  ;

type

  TBearSetForm = class(TForm)
    ButtonAuto: TSpeedButton;
    ComboAccount: TComboBox;
    ComboCohesionSymbol: TComboBox;
    CheckLongOrder: TCheckBox;
    CheckShortOrder: TCheckBox;
    CheckCancelOrder: TCheckBox;
    editCancelTime: TEdit;
    Label10: TLabel;
    ComboOrderSymbol: TComboBox;
    BtnCohesionSymbol: TSpeedButton;
    BtnOrderSymbol: TSpeedButton;
    EditCohesionFilter: TEdit;
    EditCohesionPeriod: TEdit;
    EditCohesionTotQty: TEdit;
    EditCohesionCnt: TEdit;
    EditCohesionQuoteLevel: TEdit;
    EditCohesionAvgPrice: TEdit;
    Bevel3: TBevel;
    EditOrderCollectionPeriod: TEdit;
    EditOrderQuoteLevel: TEdit;
    EditOrderFilter: TEdit;
    Bevel1: TBevel;
    EditOrderQty: TEdit;
    EditMaxPosition: TEdit;
    CheckSaveCohesion: TCheckBox;
    GridInfo: TStringGrid;
    TabConfig: TTabControl;
    StatusTrade: TStatusBar;
    EditMaxQuoteQty: TEdit;
    CheckSaveOrder: TCheckBox;
    CheckSaveCollection: TCheckBox;
    PaintLog: TPaintBox;
    ButtonFix: TSpeedButton;
    ButtonSync: TSpeedButton;
    EditOrderQuoteTime: TEdit;
    CheckOrderQuoteTime: TCheckBox;
    CheckQuoteJamSkip: TCheckBox;
    EditQuoteJamSkipTime: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure TabConfigChange(Sender: TObject);
    procedure CheckLongOrderClick(Sender: TObject);
    procedure CheckShortOrderClick(Sender: TObject);
    procedure CheckCancelOrderClick(Sender: TObject);
    procedure BtnCohesionSymbolClick(Sender: TObject);
    procedure BtnOrderSymbolClick(Sender: TObject);
    procedure ComboCohesionSymbolChange(Sender: TObject);
    procedure ComboOrderSymbolChange(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure ButtonAutoClick(Sender: TObject);
    procedure CheckSaveCohesionClick(Sender: TObject);
    procedure CheckSaveOrderClick(Sender: TObject);
    procedure CheckSaveCollectionClick(Sender: TObject);
    procedure ButtonSyncClick(Sender: TObject);
    procedure CheckQuoteJamSkipClick(Sender: TObject);
    procedure OnEditboxChange(Sender: TObject);
   
  private
    FAccountGroup : TAccountGroup; 
    FConfig : TBearConfig ;
    FSysConfig : TBearSystemConfig ; 
    FDisplay : Boolean;
    FBearLog : TLogPainter  ;
    FBearTrade : TBearTrade ;
    //
    procedure ConfigChange ;
    function  GetConfigDir: String;
    procedure ApplyConfig;
    procedure DisplayConfig;
    procedure GetConfig;
    procedure UpdateConfig;
    function  OpenConfig(stConfig: String): Boolean;
    function  SaveConfig(stConfig: String): Boolean;
    // WinCentral
    procedure SetData(Data : TObject);
    //
    procedure Stop ;
    //
    procedure BearLogAdd(Sender: TObject;
        stTime:String ; stTitle:String ; stLog : String );
    //
    procedure SetPersistence(Stream : TObject);
    procedure GetPersistence(Stream : TObject);

  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  BearSetForm: TBearSetForm;
  procedure OrderSymbolCombo(aSymbol : TSymbol; aCombo : TComboBox);

implementation

uses GAppEnv, CleFQN;

{$R *.dfm}

procedure OrderSymbolCombo(aSymbol : TSymbol; aCombo : TComboBox);
var
  iP : Integer;
begin
  if (aSymbol = nil) or (aCombo = nil) then Exit;
  //
  iP := aCombo.Items.IndexOfObject(aSymbol);
  if iP > 0 then aCombo.Items.Move(iP, 0) ;
  aCombo.ItemIndex := 0;
end;

// ---------- << Method Poiner >> ---------- //

procedure TBearSetForm.BearLogAdd(Sender: TObject; stTime, stTitle,
  stLog: String);
begin
    FBearLog.addLog(stTime, stTitle, stLog );
end;

procedure TBearSetForm.SetData(Data: TObject);
begin
  //
  if Data = nil then Exit;
  //
  if Data is TAccount then
  begin
    FSysConfig.Account := Data as TAccount ;
    SetComboIndex(ComboAccount, FSysConfig.Account );
    ComboAccountChange(ComboAccount);
  end
  else if Data is TSymbol then
  begin
    FSysConfig.OrderSymbol := Data as TSymbol ;
    SetComboIndex(ComboOrderSymbol, FSysConfig.OrderSymbol );
    ComboOrderSymbolChange(ComboOrderSymbol);
  end ;

end;

procedure TBearSetForm.SetPersistence(Stream: TObject);
var
  szBuf : array[0..100] of Char;
  stAccount, stSymbol  : String;
  aBinStream : TMemoryStream;
begin

  aBinStream:= Stream as TMemoryStream;
  with aBinStream, FSysConfig do
  begin
    Read(szBuf, 15);
    stAccount := szBuf;
    Account:=  gEnv.Engine.TradeCore.Accounts.Find( Trim(stAccount));
    Read(szBuf, 9);
    stSymbol := szBuf;
    CohesionSymbol:= gEnv.Engine.SymbolCore.Symbols.FindCode( Trim(stSymbol) );
    Read(szBuf, 9);
    stSymbol := szBuf;
    OrderSymbol:= gEnv.Engine.SymbolCore.Symbols.FindCode( Trim(stSymbol) );
    //
    Read(OrderCollectionPeriod, SizeOf(Double));
    Read(OrderQuoteLevel, SizeOf(Integer));
    Read(OrderFilter, SizeOf(Integer));

    Read(OrderQuoteTimeUsed, SizeOf(Boolean));
    Read(OrderQuoteTime, SizeOf(Double));
    Read(QuoteJamSkipUsed, SizeOf(Boolean));
    Read(QuoteJamSkipTime, SizeOf(Double));

    Read(SaveOrdered, SizeOf(Boolean));
    Read(SaveCohesioned, SizeOf(Boolean));
    Read(SaveCollectioned, SizeOf(Boolean)); 
  end;
  //
  DisplayConfig ;
end;

procedure TBearSetForm.GetPersistence(Stream: TObject);
var
  stAccount, stCohesionSymbol, stOrderSymbol : String;
  szBuf : array[0..100] of Char;
  aBinStream : TMemoryStream;
begin

  GetConfig ;
  //
  aBinStream:= Stream as TMemoryStream;
  with aBinStream, FSysConfig do
  begin
    if Account = nil then
      stAccount := Format('%-14s', [''])
    else
      stAccount := Format('%-14s', [Account.Code]);
    if CohesionSymbol = nil then
      stCohesionSymbol := Format('%-8s', [''])
    else
      stCohesionSymbol := Format('%-8s', [CohesionSymbol.Code]);
    if OrderSymbol = nil then
      stOrderSymbol := Format('%-8s', [''])
    else
      stOrderSymbol := Format('%-8s', [OrderSymbol.Code]);
    //
    StrPCopy(szBuf, stAccount);
    Write(szBuf, Length(stAccount)+1);
    StrPCopy(szBuf, stCohesionSymbol);
    Write(szBuf, Length(stCohesionSymbol)+1);
    StrPCopy(szBuf, stOrderSymbol);
    Write(szBuf, Length(stOrderSymbol)+1);

    // -- 주문 종목
    Write(OrderCollectionPeriod, SizeOf(Double));
    Write(OrderQuoteLevel, SizeOf(Integer));
    Write(OrderFilter, SizeOf(Integer));

    Write(OrderQuoteTimeUsed, SizeOf(Boolean));
    Write(OrderQuoteTime, SizeOf(Double));
    Write(QuoteJamSkipUsed, SizeOf(Boolean));
    Write(QuoteJamSkipTime, SizeOf(Double));

    Write(SaveOrdered, SizeOf(Boolean));
    Write(SaveCohesioned, SizeOf(Boolean));
    Write(SaveCollectioned, SizeOf(Boolean));

  end;

end;

procedure TBearSetForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  with FSysConfig do
  begin
    FAccountGroup := gEnv.Engine.TradeCore.AccountGroups.Find2(
       aStorage.FieldByName('AccountNo').AsString) ;
    if FAccountGroup <> nil then
      Account := FAccountGroup.Accounts.Find( aStorage.FieldByName('AccountNo').AsString );

    CohesionSymbol :=
      gEnv.Engine.SymbolCore.Symbols.FindCode( aStorage.FieldByName('CohesionSymbol').AsString );

    if CohesionSymbol <> nil then
      AddSymbolCombo(CohesionSymbol, ComboCohesionSymbol);

    OrderSymbol :=
      gEnv.Engine.SymbolCore.Symbols.FindCode( aStorage.FieldByName('OrderSymbol').AsString );

    if OrderSymbol <> nil then
      AddSymbolCombo(OrderSymbol, ComboOrderSymbol);


    OrderCollectionPeriod := aStorage.FieldByName('OrderCollectionPeriod').AsFloat;
    OrderQuoteLevel := aStorage.FieldByName('OrderQuoteLevel').AsInteger;
    OrderFilter := aStorage.FieldByName('OrderFilter').AsInteger;

    OrderQuoteTimeUsed  := aStorage.FieldByName('OrderQuoteTimeUsed').AsBoolean;
    OrderQuoteTime  := aStorage.FieldByName('OrderQuoteTime').AsFloat;
    QuoteJamSkipUsed:= aStorage.FieldByName('QuoteJamSkipUsed').AsBoolean;
    QuoteJamSkipTime  := aStorage.FieldByName('QuoteJamSkipTime').AsFloat ;

    SaveOrdered := aStorage.FieldByName('SaveOrdered').AsBoolean;
    SaveCohesioned  := aStorage.FieldByName('SaveCohesioned').AsBoolean ;
    SaveCollectioned  := aStorage.FieldByName('SaveCollectioned').AsBoolean ;
  end;

  DisplayConfig ;

end;

// ---------- << private >> ---------- //

procedure TBearSetForm.Stop;
begin
  if ButtonAuto.Down then
  begin
    ButtonAuto.Down := False;
    ButtonAuto.Click;
  end; 
end;

procedure TBearSetForm.ConfigChange;
begin
  if FDisplay then Exit;

  // 1. Config 저장하기
  UpdateConfig ;

  // 2. 멈춤
  Stop;

end;

procedure TBearSetForm.ApplyConfig;
begin
  DisplayConfig;
end;

// 화면의 내용을 담아 파일에 저장 
procedure TBearSetForm.UpdateConfig;
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


function TBearSetForm.GetConfigDir: String;
var
  stDir : String;
begin
    // 설정 하위 디렉토리
  stDir := '\'+DIR_TEMPLATE + '\' + TPKEY_BearSystem + '\';

    // 디렉토리가 없으면 디랙토리를 생성한다
  if not DirectoryExists(gEnv.RootDir + '\'+DIR_TEMPLATE ) then
    CreateDir(gEnv.RootDir + '\'+DIR_TEMPLATE);
  if not DirectoryExists(gEnv.RootDir + stDir) then
    CreateDir(gEnv.RootDir + stDir);

  Result := stDir;
end;



// Config 내용을 화면에 보여줌
procedure TBearSetForm.DisplayConfig;
var
  i, iPOs : integer;
begin

  FDisplay := True ;

  // --
  with FSysConfig do
  begin
    SetComboIndex(ComboAccount, FAccountGroup);
    ComboAccountChange(ComboAccount);
    SetComboIndex( ComboCohesionSymbol, CohesionSymbol);
    ComboCohesionSymbolChange(ComboCohesionSymbol);
    SetComboIndex(ComboOrderSymbol, OrderSymbol);
    ComboOrderSymbolChange(ComboOrderSymbol);

    // -- 주문 종목
    EditOrderCollectionPeriod.Text := Format('%.0f', [OrderCollectionPeriod]); // 수집시간
    EditOrderQuoteLevel.Text := IntToStr(OrderQuoteLevel);  // 호가레벨
    EditOrderFilter.Text := IntToStr(OrderFilter) ;         //  수량필터

    CheckOrderQuoteTime.Checked := OrderQuoteTimeUsed ;   // 주문 가격정하는 방법
    EditOrderQuoteTime.Text :=  Format('%.0f', [OrderQuoteTime]); // 주문 호가 사용시간

    CheckQuoteJamSkip.Checked :=  QuoteJamSkipUsed ; // 딜레이 자동 Skip 사용여부
    EditQuoteJamSkipTime.Text :=  Format('%.0f', [QuoteJamSkipTime]); // 자동 Skip 딜레이 시간

    // -- 기타
    CheckSaveCohesion.Checked :=  SaveCohesioned ;  // 응집데이터 저장
    CheckSaveOrder.Checked := SaveOrdered ;   // 원천데이터 저장
    CheckSaveCollection.Checked := SaveCollectioned ; // 주문 종목 저장
  end;

  // --
  with FConfig do
  begin
    // -- 주문 정보
    CheckLongOrder.Checked := LongOrdered ;     // 매수주문?
    CheckShortOrder.Checked := ShortOrdered ;   // 매도주문?
    CheckCancelOrder.Checked := CancelOrdered ; // 자동취소? 
    EditCancelTime.Text :=  Format('%.0f', [CancelTime]); // 취소시간     
    EditOrderQty.Text := IntToStr(OrderQty) ;       // 주문수량
    EditMaxPosition.Text := IntTostr(MaxPosition);  // 주문한도 ( 포지션 ) 
    EditMaxQuoteQty.Text := IntTostr(MaxQuoteQty);  // 최대호가잔량

    // -- 응집 종목
    EditCohesionFilter.Text := IntToStr(CohesionFilter) ;   // 수량필터
    EditCohesionPeriod.Text := Format('%.0f', [CohesionPeriod]);  // 연속시간
    EditCohesionTotQty.Text := IntToStr(CohesionTotQty) ;   // 총수량
    EditCohesionCnt.Text := IntToStr(CohesionCnt) ; // 건수
    EditCohesionQuoteLevel.Text := IntToStr(CohesionQuoteLevel);  // 호가 레벨
    EditCohesionAvgPrice.Text := Format('%.3f', [CohesionAvgPrice]);  // 가격차 ( 평균단가 )
  end ;

  FDisplay := False;
  
end;


// 화면 설정을 Config에 넣음
procedure TBearSetForm.GetConfig;
begin

  with FSysConfig do
  begin
    if (ComboAccount.ItemIndex > -1) and ( FAccountGroup <> nil) then
      Account :=  FAccountGroup.Accounts.GetMarketAccount( atFO );
        //ComboAccount.Items.Objects[ComboAccount.ItemIndex] as TAccount;
    if ComboCohesionSymbol.ItemIndex > -1 then
      CohesionSymbol :=
        ComboCohesionSymbol.Items.Objects[ComboCohesionSymbol.ItemIndex] as TSymbol;
    if ComboOrderSymbol.ItemIndex > -1 then
      OrderSymbol :=
        ComboOrderSymbol.Items.Objects[ComboOrderSymbol.ItemIndex] as TSymbol;

    // -- 주문 종목
    OrderCollectionPeriod := StrToFloat(EditOrderCollectionPeriod.Text);  // 수집시간
    OrderQuoteLevel := StrToInt(EditOrderQuoteLevel.Text);  // 호가레벨
    OrderFilter := StrToInt(EditOrderFilter.Text);  // 수량필터 

    OrderQuoteTimeUsed := CheckOrderQuoteTime.Checked ;  // 주문 가격정하는 방법
    OrderQuoteTime := StrToFloat( EditOrderQuoteTime.Text );   // 주문 호가 사용시간

    QuoteJamSkipUsed := CheckQuoteJamSkip.Checked ;  // 딜레이 자동 중지 사용여부
    QuoteJamSkipTime := StrToFloat( EditQuoteJamSkipTime.Text); // 딜레이시 자동 중지 시간

    // -- 기타
    SaveCohesioned := CheckSaveCohesion.Checked ;  // 응집데이터 저장   
    SaveOrdered := CheckSaveOrder.Checked ; // 원천 데이터 저장
    SaveCollectioned :=  CheckSaveCollection.Checked ;   // 주문 종목 저장
  end;

  with FConfig do
  begin

    // -- 주문 정보
    LongOrdered := CheckLongOrder.Checked ;     // 매수주문?
    ShortOrdered :=  CheckShortOrder.Checked ;  // 매도주문?
    CancelOrdered := CheckCancelOrder.Checked ; // 자동취소?  
    CancelTime := StrToFloat(EditCancelTime.Text);  // 취소시간
    OrderQty := StrToInt(EditOrderQty.Text);        // 주문수량
    MaxPosition := StrToInt(EditMaxPosition.Text);  // 주문한도 ( 포지션 )
    MaxQuoteQty := StrToInt(EditMaxQuoteQty.Text);  // 최대호가잔량 

    // -- 응집 종목
    CohesionFilter := StrToInt(EditCohesionFilter.Text) ; // 수량필터
    CohesionPeriod := StrToFloat(EditCohesionPeriod.Text) ; // 연속시간
    CohesionTotQty := StrToInt(EditCohesionTotQty.Text) ; // 총수량
    CohesionCnt := StrToInt(EditCohesionCnt.Text) ; // 건수 
    CohesionQuoteLevel := StrToInt(EditCohesionQuoteLevel.Text);  // 호가레벨  
    CohesionAvgPrice := StrToFloat(EditCohesionAvgPrice.Text);  // 가격차 ( 평균단가 )

  end;
  
end;


// 개별 설정 파일에서 열기 
function TBearSetForm.OpenConfig(stConfig: String): Boolean;
var
  stDir, stFile : String;
  iVersion : Integer;
  aEnvFile : TEnvFile;
  aBinStream : TMemoryStream;
  aStrStream : TStringStream;
  stAccount, stCohesionSymbol, stOrderSymbol : String;
  szBuf : array[0..100] of Char;
begin
  Result := False;

  stDir := GetConfigDir;

  //-- select template
  aEnvFile := TEnvFile.Create;
  aBinStream := TMemoryStream.Create;
  aStrStream := TStringStream.Create('');
  try
    stFile := '\'+stDir + stConfig + '.' + TEMPLATE_SUFFIX;
    if not aEnvFile.Exists(stFile) then
    begin
      ShowMessage(Format('''%s'' 를 찾을 수 없슴-> 신규 설정',[stFile]));
      Exit;
    end;

    if aEnvFile.LoadLines(stFile) and
       (aEnvFile.Lines.Count >= 3) then
    try

      //--1. key
      if CompareStr(TPKEY_BearSystem, aEnvFile.Lines[0]) <> 0 then
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



// 개별 설정 파일로 저장 
function TBearSetForm.SaveConfig(stConfig: String): Boolean;
var
  aBinStream : TMemoryStream;
  aStrStream : TStringStream;
  aEnvFile : TEnvFile;
  stDir : String;
  stAccount, stCohesionSymbol, stOrderSymbol  : String;
  szBuf : array[0..100] of Char;
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
      aEnvFile.Lines.Add(TPKEY_BearSystem);
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



procedure TBearSetForm.SaveEnv(aStorage: TStorage);
begin

  if aStorage = nil then Exit;

  GetConfig ;

  with FSysConfig do
  begin
    if Account = nil then
      aStorage.FieldByName('AccountNo').AsString := ''
    else
      aStorage.FieldByName('AccountNo').AsString := Account.Code;

    if CohesionSymbol = nil then
      aStorage.FieldByName('CohesionSymbol').AsString := ''
    else
      aStorage.FieldByName('CohesionSymbol').AsString := CohesionSymbol.Code;

    if OrderSymbol = nil then
      aStorage.FieldByName('OrderSymbol').AsString := ''
    else
      aStorage.FieldByName('OrderSymbol').AsString := OrderSymbol.Code;

    aStorage.FieldByName('OrderCollectionPeriod').AsFloat := OrderCollectionPeriod;
    aStorage.FieldByName('OrderQuoteLevel').AsInteger := OrderQuoteLevel;
    aStorage.FieldByName('OrderFilter').AsInteger := OrderFilter;

    aStorage.FieldByName('OrderQuoteTimeUsed').AsBoolean := OrderQuoteTimeUsed;
    aStorage.FieldByName('OrderQuoteTime').AsFloat := OrderQuoteTime;
    aStorage.FieldByName('QuoteJamSkipUsed').AsBoolean := QuoteJamSkipUsed;
    aStorage.FieldByName('QuoteJamSkipTime').AsFloat := QuoteJamSkipTime;

    aStorage.FieldByName('SaveOrdered').AsBoolean := SaveOrdered;
    aStorage.FieldByName('SaveCohesioned').AsBoolean := SaveCohesioned;
    aStorage.FieldByName('SaveCollectioned').AsBoolean := SaveCollectioned;
  end;


end;

// ---------- << event >> ---------- //

procedure TBearSetForm.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
begin

  // 1. WinCentral
  //??
  {
  if gWin.OpenPeer <> nil then
  with gWin.OpenPeer do
  begin
    OnSetData := SetData;
    OnGetPersistence := GetPersistence;
    OnSetPersistence := SetPersistence;
    //
    Pin := ButtonFix;
  end;
  }
  // 2. 변수 초기화
  FDisplay := False;
  ButtonSync.Down := false ;
  // 3. ComboBox 채우기 ( 계좌, 종목 )
  FAccountGroup := nil;
  gEnv.Engine.TradeCore.AccountGroups.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption, mtSpread ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( ComboCohesionSymbol.Items, aMarkets );
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( ComboOrderSymbol.Items, aMarkets );

  // 4. 설정 불러오기
  TabConfigChange(TabConfig);
  // 5. 객체 생성
  FBearTrade := TBearTrade.Create ;
  FBearTrade.OnBearLog := BearLogAdd  ;
  // 6. 로그
  FBearLog := TLogPainter.Create ;
  FBearLog.RowCount := 15 ;
  FBearLog.PaintBox := PaintLog ;
  // 7. '자동/수동' 버튼 초기화
  ButtonAutoClick(ButtonAuto);

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;


end;

procedure TBearSetForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;  
end;

procedure TBearSetForm.FormDestroy(Sender: TObject);
begin
  try
  
  if FBearTrade <> nil then
    FBearTrade.Free ;
  if FBearLog <> nil then
    FBearLog.Free ;
  
  except
    on E : Exception do
      gLog.Add(lkError, 'BearSystem', 'BearForm', 'FormDestroy' + E.Message);
  end;
  
end;

procedure TBearSetForm.ButtonAutoClick(Sender: TObject);
begin


  if ButtonAuto.Down then
  begin

    // -- 체크
    if FSysConfig.Account = nil then
    begin
      ShowMessage('계좌를 선택하세요');
      ButtonAuto.Down := false ; 
      exit;
    end;
    if FSysConfig.CohesionSymbol = nil then
    begin
      ShowMessage('응집 종목을 선택하세요');
      ButtonAuto.Down := false ; 
      exit;
    end;
    if FSysConfig.OrderSymbol = nil then
    begin
      ShowMessage('주문 종목을 선택하세요');
      ButtonAuto.Down := false ;
      exit;
    end;

    // -- 로직 
    Self.Color := clSkyBlue ;
    ButtonAuto.Caption := 'Run';
    UpdateConfig;
    FBearTrade.Start(FSysConfig, FConfig);

  end
  else
  begin
    Self.Color := clBtnFace ;
    ButtonAuto.Caption := 'Stop';
    FBearTrade.Stop ;

  end;

end;

procedure TBearSetForm.ButtonSyncClick(Sender: TObject);
begin
  //??gWin.ModifyWorkspace;
end;

procedure TBearSetForm.TabConfigChange(Sender: TObject);
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
        updateConfig ;
  end;
end;

procedure TBearSetForm.OnEditboxChange(Sender: TObject);
begin
  Stop ; 
end;

procedure TBearSetForm.CheckLongOrderClick(Sender: TObject);
begin
  ConfigChange ;
end;

procedure TBearSetForm.CheckQuoteJamSkipClick(Sender: TObject);
begin
  ConfigChange ;
end;

procedure TBearSetForm.CheckSaveCohesionClick(Sender: TObject);
begin
  ConfigChange ;
end;

procedure TBearSetForm.CheckSaveCollectionClick(Sender: TObject);
begin
  ConfigChange ;
end;

procedure TBearSetForm.CheckSaveOrderClick(Sender: TObject);
begin
  ConfigChange ;
end;

procedure TBearSetForm.CheckShortOrderClick(Sender: TObject);
begin
  ConfigChange ;
end;

procedure TBearSetForm.CheckCancelOrderClick(Sender: TObject);
begin
  ConfigChange  ;
end;




procedure TBearSetForm.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  aMarkets  : TMarketTypes;
  aGroup  : TAccountGroup;
begin

  aGroup  := GetComboObject( ComboAccount ) as TAccountGroup;
  if aGroup = nil then Exit;

  if aGroup = FAccountGroup then
    Exit;

  FAccountGroup := aGroup;

  // 선,옵 계좌를 구한다.
  aAccount  := FAccountGroup.Accounts.GetMarketAccount( atFO );
  if (aAccount = nil) or (FSysConfig.Account = aAccount) then Exit;
  // 계좌 변경
  FSysConfig.Account := aAccount;

  // FDisplay가 아닐때 Save & Stop
  ConfigChange ;

end;


procedure TBearSetForm.BtnCohesionSymbolClick(Sender: TObject);
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
      AddSymbolCombo(gSymbol.Selected, ComboCohesionSymbol);
        // apply
      ComboCohesionSymbolChange(ComboCohesionSymbol);
    end;
  finally
    gSymbol.Hide;
  end;

end;

procedure TBearSetForm.BtnOrderSymbolClick(Sender: TObject);
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
      AddSymbolCombo(gSymbol.Selected, ComboOrderSymbol);
        // apply
      ComboOrderSymbolChange(ComboOrderSymbol);
    end;
  finally
    gSymbol.Hide
  end;

end;


procedure TBearSetForm.ComboCohesionSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if ComboCohesionSymbol.ItemIndex = -1 then Exit;
  // get account object
  aSymbol := ComboCohesionSymbol.Items.Objects[ComboCohesionSymbol.ItemIndex] as TSymbol;

  if (aSymbol = nil) then Exit;
  // check dupliticity
  if FSysConfig.CohesionSymbol = aSymbol then Exit;

  // set new symbol
  FSysConfig.CohesionSymbol := aSymbol;

  OrderSymbolCombo(aSymbol, ComboCohesionSymbol);
  
  // 2007.08.04 응집 종목은 예외 
  // gWin.Synchronize(Self, [FCohesionSymbol]);

  // FDisplay가 아닐때 Save & Stop
  ConfigChange ;

end;


procedure TBearSetForm.ComboOrderSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if ComboOrderSymbol.ItemIndex = -1 then Exit;
  // get account object
  aSymbol := ComboOrderSymbol.Items.Objects[ComboOrderSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;
  // check dupliticity
  if FSysConfig.OrderSymbol = aSymbol then Exit;

  // set new symbol
  FSysConfig.OrderSymbol := aSymbol;

  OrderSymbolCombo(aSymbol, ComboOrderSymbol);
  {
  if ( ButtonSync.Down = true) and (FSysConfig.OrderSymbol <> nil)
      and ( FDisplay = false ) then
    gWin.Synchronize(Self, [FSysConfig.OrderSymbol]);
  }
  // FDisplay가 아닐때 Save & Stop
  ConfigChange ;

end;


end.
