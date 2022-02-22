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

    // -- �ֹ� ����
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

  // 1. Config �����ϱ�
  UpdateConfig ;

  // 2. ����
  Stop;

end;

procedure TBearSetForm.ApplyConfig;
begin
  DisplayConfig;
end;

// ȭ���� ������ ��� ���Ͽ� ���� 
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
    // ���� ���� ���丮
  stDir := '\'+DIR_TEMPLATE + '\' + TPKEY_BearSystem + '\';

    // ���丮�� ������ ���丮�� �����Ѵ�
  if not DirectoryExists(gEnv.RootDir + '\'+DIR_TEMPLATE ) then
    CreateDir(gEnv.RootDir + '\'+DIR_TEMPLATE);
  if not DirectoryExists(gEnv.RootDir + stDir) then
    CreateDir(gEnv.RootDir + stDir);

  Result := stDir;
end;



// Config ������ ȭ�鿡 ������
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

    // -- �ֹ� ����
    EditOrderCollectionPeriod.Text := Format('%.0f', [OrderCollectionPeriod]); // �����ð�
    EditOrderQuoteLevel.Text := IntToStr(OrderQuoteLevel);  // ȣ������
    EditOrderFilter.Text := IntToStr(OrderFilter) ;         //  ��������

    CheckOrderQuoteTime.Checked := OrderQuoteTimeUsed ;   // �ֹ� �������ϴ� ���
    EditOrderQuoteTime.Text :=  Format('%.0f', [OrderQuoteTime]); // �ֹ� ȣ�� ���ð�

    CheckQuoteJamSkip.Checked :=  QuoteJamSkipUsed ; // ������ �ڵ� Skip ��뿩��
    EditQuoteJamSkipTime.Text :=  Format('%.0f', [QuoteJamSkipTime]); // �ڵ� Skip ������ �ð�

    // -- ��Ÿ
    CheckSaveCohesion.Checked :=  SaveCohesioned ;  // ���������� ����
    CheckSaveOrder.Checked := SaveOrdered ;   // ��õ������ ����
    CheckSaveCollection.Checked := SaveCollectioned ; // �ֹ� ���� ����
  end;

  // --
  with FConfig do
  begin
    // -- �ֹ� ����
    CheckLongOrder.Checked := LongOrdered ;     // �ż��ֹ�?
    CheckShortOrder.Checked := ShortOrdered ;   // �ŵ��ֹ�?
    CheckCancelOrder.Checked := CancelOrdered ; // �ڵ����? 
    EditCancelTime.Text :=  Format('%.0f', [CancelTime]); // ��ҽð�     
    EditOrderQty.Text := IntToStr(OrderQty) ;       // �ֹ�����
    EditMaxPosition.Text := IntTostr(MaxPosition);  // �ֹ��ѵ� ( ������ ) 
    EditMaxQuoteQty.Text := IntTostr(MaxQuoteQty);  // �ִ�ȣ���ܷ�

    // -- ���� ����
    EditCohesionFilter.Text := IntToStr(CohesionFilter) ;   // ��������
    EditCohesionPeriod.Text := Format('%.0f', [CohesionPeriod]);  // ���ӽð�
    EditCohesionTotQty.Text := IntToStr(CohesionTotQty) ;   // �Ѽ���
    EditCohesionCnt.Text := IntToStr(CohesionCnt) ; // �Ǽ�
    EditCohesionQuoteLevel.Text := IntToStr(CohesionQuoteLevel);  // ȣ�� ����
    EditCohesionAvgPrice.Text := Format('%.3f', [CohesionAvgPrice]);  // ������ ( ��մܰ� )
  end ;

  FDisplay := False;
  
end;


// ȭ�� ������ Config�� ����
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

    // -- �ֹ� ����
    OrderCollectionPeriod := StrToFloat(EditOrderCollectionPeriod.Text);  // �����ð�
    OrderQuoteLevel := StrToInt(EditOrderQuoteLevel.Text);  // ȣ������
    OrderFilter := StrToInt(EditOrderFilter.Text);  // �������� 

    OrderQuoteTimeUsed := CheckOrderQuoteTime.Checked ;  // �ֹ� �������ϴ� ���
    OrderQuoteTime := StrToFloat( EditOrderQuoteTime.Text );   // �ֹ� ȣ�� ���ð�

    QuoteJamSkipUsed := CheckQuoteJamSkip.Checked ;  // ������ �ڵ� ���� ��뿩��
    QuoteJamSkipTime := StrToFloat( EditQuoteJamSkipTime.Text); // �����̽� �ڵ� ���� �ð�

    // -- ��Ÿ
    SaveCohesioned := CheckSaveCohesion.Checked ;  // ���������� ����   
    SaveOrdered := CheckSaveOrder.Checked ; // ��õ ������ ����
    SaveCollectioned :=  CheckSaveCollection.Checked ;   // �ֹ� ���� ����
  end;

  with FConfig do
  begin

    // -- �ֹ� ����
    LongOrdered := CheckLongOrder.Checked ;     // �ż��ֹ�?
    ShortOrdered :=  CheckShortOrder.Checked ;  // �ŵ��ֹ�?
    CancelOrdered := CheckCancelOrder.Checked ; // �ڵ����?  
    CancelTime := StrToFloat(EditCancelTime.Text);  // ��ҽð�
    OrderQty := StrToInt(EditOrderQty.Text);        // �ֹ�����
    MaxPosition := StrToInt(EditMaxPosition.Text);  // �ֹ��ѵ� ( ������ )
    MaxQuoteQty := StrToInt(EditMaxQuoteQty.Text);  // �ִ�ȣ���ܷ� 

    // -- ���� ����
    CohesionFilter := StrToInt(EditCohesionFilter.Text) ; // ��������
    CohesionPeriod := StrToFloat(EditCohesionPeriod.Text) ; // ���ӽð�
    CohesionTotQty := StrToInt(EditCohesionTotQty.Text) ; // �Ѽ���
    CohesionCnt := StrToInt(EditCohesionCnt.Text) ; // �Ǽ� 
    CohesionQuoteLevel := StrToInt(EditCohesionQuoteLevel.Text);  // ȣ������  
    CohesionAvgPrice := StrToFloat(EditCohesionAvgPrice.Text);  // ������ ( ��մܰ� )

  end;
  
end;


// ���� ���� ���Ͽ��� ���� 
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
      ShowMessage(Format('''%s'' �� ã�� �� ����-> �ű� ����',[stFile]));
      Exit;
    end;

    if aEnvFile.LoadLines(stFile) and
       (aEnvFile.Lines.Count >= 3) then
    try

      //--1. key
      if CompareStr(TPKEY_BearSystem, aEnvFile.Lines[0]) <> 0 then
      begin
        ShowMessage('�߸��� �����Դϴ�.');
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
      aBinStream.Read(FConfig, SizeOf(FConfig)); // Config �б�

      //
      Result := True;
    except
      ShowMessage(stConfig + '��(��) �д��߿� ������ �߻��߽��ϴ�.');
    end;
  finally
    aStrStream.Free;
    aBinStream.Free;
    aEnvFile.Free;
  end;
end;



// ���� ���� ���Ϸ� ���� 
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

  // ���丮 Ȯ��
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

      aBinStream.Write(FConfig, SizeOf(FConfig)); // Config �ڷ� ����

      aStrStream.Seek(0, soFromBeginning);
      aBinStream.SaveToStream(aStrStream);
      aEnvFile.Lines.Add(aStrStream.DataString);
      // save
      aEnvFile.SaveLines(stDir + stConfig + '.' + TEMPLATE_SUFFIX);
      //
      Result := True;
    except
      ShowMessage(stConfig + '��(��) �����߿� ������ �߻��߽��ϴ�.');
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
  // 2. ���� �ʱ�ȭ
  FDisplay := False;
  ButtonSync.Down := false ;
  // 3. ComboBox ä��� ( ����, ���� )
  FAccountGroup := nil;
  gEnv.Engine.TradeCore.AccountGroups.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption, mtSpread ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( ComboCohesionSymbol.Items, aMarkets );
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( ComboOrderSymbol.Items, aMarkets );

  // 4. ���� �ҷ�����
  TabConfigChange(TabConfig);
  // 5. ��ü ����
  FBearTrade := TBearTrade.Create ;
  FBearTrade.OnBearLog := BearLogAdd  ;
  // 6. �α�
  FBearLog := TLogPainter.Create ;
  FBearLog.RowCount := 15 ;
  FBearLog.PaintBox := PaintLog ;
  // 7. '�ڵ�/����' ��ư �ʱ�ȭ
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

    // -- üũ
    if FSysConfig.Account = nil then
    begin
      ShowMessage('���¸� �����ϼ���');
      ButtonAuto.Down := false ; 
      exit;
    end;
    if FSysConfig.CohesionSymbol = nil then
    begin
      ShowMessage('���� ������ �����ϼ���');
      ButtonAuto.Down := false ; 
      exit;
    end;
    if FSysConfig.OrderSymbol = nil then
    begin
      ShowMessage('�ֹ� ������ �����ϼ���');
      ButtonAuto.Down := false ;
      exit;
    end;

    // -- ���� 
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

  // ��,�� ���¸� ���Ѵ�.
  aAccount  := FAccountGroup.Accounts.GetMarketAccount( atFO );
  if (aAccount = nil) or (FSysConfig.Account = aAccount) then Exit;
  // ���� ����
  FSysConfig.Account := aAccount;

  // FDisplay�� �ƴҶ� Save & Stop
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
  
  // 2007.08.04 ���� ������ ���� 
  // gWin.Synchronize(Self, [FCohesionSymbol]);

  // FDisplay�� �ƴҶ� Save & Stop
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
  // FDisplay�� �ƴҶ� Save & Stop
  ConfigChange ;

end;


end.
