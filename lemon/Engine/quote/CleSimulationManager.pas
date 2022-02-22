unit CleSimulationManager;

interface

uses
  Classes, DateUtils, SysUtils, StdCtrls, Forms,

  CleQuotefileLoad,

  GleTypes, IniFiles
  ;


Const
  SimulIni = 'Simulation.ini';
  BtnWidth  = 100;
  BtnHeight = 25;
  BtnCount  = 4;

type

  TSimulWindow = record
    Name  : string;
    Index : integer;
    InitFile : string;
    MyForm : TForm;
    Desc : string;

  end;

  TSimulEnv = record
    SimulWins : array of TSimulWindow;
    TotCount  : integer;
  end;

  TSimulationManager = class
  private
    FQuoteFileLoad : TQuoteFileLoad;
    FSimulEnv: TSimulEnv;

    procedure OnBtnClick(Sender: TObject);
    procedure SetStatus(index: integer; value: string);
    procedure CheckPrint;
  public
    SimulStats : TSimulationStatus;
    StartDate  : TDateTime;
    EndDate    : TDateTime;
    ToDay      : TDateTime;

    Constructor Create;
    Destructor  Destroy; override;

    procedure OnSimulationStats( tsType : TSimulationStatus );

    procedure QuoteReceived(Sender: TObject; Value: String);
    procedure MasterReceived(Sender: TObject; Value: String);
    procedure QuoteTime(Sender: TObject; Value: TDateTime);
    procedure ResetMemory;

    procedure initConfig;
    procedure initControls;

    procedure CheckSymbolDialog;

    property SimulEnv : TSimulEnv read FSimulEnv;
    property QuotefileLoad : TQuotefileLoad read FQuoteFileLoad;
  end;

implementation

uses
  GAppEnv, FS5main, FHogaRatio, FSpread, FRSSim1Data, FELWUnder, FPriceValuation, FCPSell,
  FStatsOrderCount, FBothLong, FQuoteChange, FExpectPriceTest
  ;

{ TSimulationManager }

procedure TSimulationManager.CheckSymbolDialog;
var
  i : integer;
  stDesc : string;
begin
  for i := 0 to High(SimulEnv.SimulWins) do
  begin
    if SimulEnv.SimulWins[i].MyForm <> nil then
    begin
      stDesc := SimulEnv.SimulWins[i].Desc;
      if (SimulEnv.SimulWins[i].Name = 'HogaRatio') then
        THogaRatio(SimulEnv.SimulWins[i].MyForm).ShowSymoblSelect;

      if (SimulEnv.SimulWins[i].Name = 'Spread') then
        TSpread(SimulEnv.SimulWins[i].MyForm).ShowSymoblSelect(stDesc);

      if (SimulEnv.SimulWins[i].Name = 'RSSim1Data') then
        TRSSim1Data(SimulEnv.SimulWins[i].MyForm).ShowSymoblSelect(stDesc);

      if (SimulEnv.SimulWins[i].Name = 'ELWUnderQuote') then
        TELWUnderQuote(SimulEnv.SimulWins[i].MyForm).PreSubscribe;

      if (SimulEnv.SimulWins[i].Name = 'PriceValuation') then
        TPriceValuation(SimulEnv.SimulWins[i].MyForm).initValuation;

      // 이놈아는..선물최근월물 구독하기 위해
      if (SimulEnv.SimulWins[i].Name = 'FrmCPSell') then
        TFrmCPSell(SimulEnv.SimulWins[i].MyForm).init;

      if (SimulEnv.SimulWins[i].Name = 'StatsOrderCount') then
        TStatsOrderCount(SimulEnv.SimulWins[i].MyForm).init;

      if (SimulEnv.SimulWins[i].Name = 'FrmBothLong') then
        TFrmBothLong(SimulEnv.SimulWins[i].MyForm).Button1Click(nil);

      if (SimulEnv.SimulWins[i].Name = 'FrmQuoteChange') then
        TFrmQuoteChange(SimulEnv.SimulWins[i].MyForm).init;

      if (SimulEnv.SimulWins[i].Name = 'FrmExpectPrice') then
        TFrmExpectPrice(SimulEnv.SimulWins[i].MyForm).init;
      
    end;
  end;
end;

procedure TSimulationManager.CheckPrint;
var
  i : integer;
begin
  for i := 0 to High(SimulEnv.SimulWins) do
  begin
    if SimulEnv.SimulWins[i].MyForm <> nil then
    begin
      if (SimulEnv.SimulWins[i].Name = 'PriceValuation') then
        TPriceValuation(SimulEnv.SimulWins[i].MyForm).SaveExcel;
    end;
  end;

end;

constructor TSimulationManager.Create;
begin
  SimulStats := tsNone;
  FQuoteFileLoad := TQuoteFileLoad.Create( gEnv.FileName );
end;

destructor TSimulationManager.Destroy;
begin

  inherited;
end;

procedure TSimulationManager.SetStatus( index :integer; value : string);
begin
  FrmMain.StatusBar.Panels[index].Text := value;
end;

procedure TSimulationManager.OnSimulationStats(tsType: TSimulationStatus);
var
  bRes : boolean;
begin
  gSimul.SimulStats := tsType;
  case tsType of
    tsNone: ;
    tsStart:
      begin
        SetStatus( 1, 'start ');
        StartDate := FrmMain.StartDate.Date;
        EndDate   := FrmMain.EndDate.Date;
        ToDay     := StartDate;
        gEnv.Engine.QuoteBroker.Timers.Reset( StartDate );
        FQuoteFileLoad.Start( ToDay );
      end;
    tsEnd: OnSimulationStats( tsPrint );
    tsPreSuscribe :
      begin
        if (gEnv.BatchOneMin) or ( gEnv.BatchDay) then
        begin
            SetStatus( 1, '구독');
            gEnv.Loader.AddFixedSymbols;
            gEnv.Engine.SymbolCore.SubscribeAll( true);

            if gEnv.Engine.Operators.Param.UseSynthFut then
              gEnv.Engine.SyncFuture.Init;

            // 한순간 필요해서 만든거
            //gEnv.Engine.SymbolCore.InsertMaster;

            FQuoteFileLoad.LoadThread.Resume;
            SetStatus( 1, 'Playing');
        end
        else begin
            SetStatus( 1, '구독');
            gEnv.Loader.AddFixedSymbols;
            // 종목선택창이 필요한 경우를 체크해서 띄워준다.
            CheckSymbolDialog;
            bRes := true;//gEnv.Engine.QuoteBroker.DoSubscribe;

            if gEnv.Engine.Operators.Param.UseSynthFut then
              gEnv.Engine.SyncFuture.Init;

            if bRes then
            begin
              FQuoteFileLoad.LoadThread.Resume;
              SetStatus( 1, 'Playing');
            end
            else begin
              SetStatus( 1, '분석대상이 없음');
            end;
        end;
      end;
    tsNoFile,
    tsReStart:
      begin
        if gEnv.UseRepeat then
        begin
          if gEnv.RepeatNum <= gEnv.RepeatCnt then
          begin
            gEnv.RepeatCnt  := 0;
            SetStatus( 1, ' Next Start ');
            ToDay := IncDay( ToDay );
            if ToDay > EndDate then
              gEnv.SetSimulStatus( tsCompleteEnd )
            else
              FQuoteFileLoad.Start( ToDay );
          end // if if gEnv.RepeatNum <= gEnv.RepeatCnt then
          else begin
            inc(gEnv.RepeatCnt);
            SetStatus( 1, ' Repeat ');
            FQuoteFileLoad.Start( ToDay );
          end;
        end
        else begin
          SetStatus( 1, ' Next Start ');
          ToDay := IncDay( ToDay );
          if ToDay > EndDate then
            gEnv.SetSimulStatus( tsCompleteEnd )
          else
            FQuoteFileLoad.Start( ToDay );
        end;
      end;
    tsCompleteEnd:
      SetStatus( 1, '완료');
    tsClear:
      begin
        SetStatus( 1, 'reset');
        ResetMemory;
      end;
    tsClearEnd:
      begin
        SetStatus( 1, 'End');
        OnSimulationStats( tsReStart );
      end;
    tsPrint:
      begin
        sleep(100);
        FrmMain.StatusBar.Panels[1].Text := 'End';
        //FQuoteFileLoad.StopThread;
        // Batch true 일때 여기서 DB Insert 를 해준다.
        // 시세 파일 다읽으면 tsEnd -> tsPrint -> tsPritEnd
        if gEnv.BatchOneMin then
          gEnv.Engine.SymbolCore.InsertData;
        if gEnv.BatchDay then
          gEnv.Engine.SymbolCore.InsertDayData;
        CheckPrint;
        OnSimulationStats( tsPrintEnd );
      end;
    tsPrintEnd: OnSimulationStats( tsClear );
  end;

end;

procedure TSimulationManager.QuoteReceived(Sender: TObject; Value: String);
begin
  FrmMain.QuoteReceiver.Parser.Parse( Value);
end;

procedure TSimulationManager.MasterReceived(Sender: TObject; Value: String);
begin
  gEnv.Loader.ImportMasterFromFile( Value, gEnv.AppDate);
end;

procedure TSimulationManager.QuoteTime(Sender: TObject; Value: TDateTime);
begin
  gEnv.Engine.QuoteBroker.Timers.Feed( Trunc(ToDay) + Value );
end;

procedure TSimulationManager.ResetMemory;
begin

  if gEnv.Engine.Operators.Param.UseSynthFut then
  begin

  gEnv.Engine.SyncFuture.ReSetIndicator;
  gEnv.Engine.SyncFuture.ReSet;

  end;

  gEnv.Engine.QuoteBroker.Reset;
  gEnv.Engine.TradeCore.Orders.OrderReSet;
  gEnv.Engine.TradeCore.Clear;
  gEnv.Engine.TradeBroker.Clear;

  gEnv.Engine.SymbolCore.Reset;

  gEnv.Engine.QuoteBroker.ResetSubs;

  if gSymbol <> nil then
    gSymbol.Free;


  gEnv.Engine.QuoteBroker.Clear;
  gEnv.SetSimulStatus( tsClearEnd );

  gEnv.Engine.SymbolCore.subCount := 0;
end;


///////////////////////
///
///
procedure TSimulationManager.initConfig;
var
  ini : TIniFile;
  stDir : string;
  i, iCount : integer;
begin

  stDir := ExtractFilePath( paramstr(0) ) + 'env\';

  try
    ini := TIniFile.Create( stDir + SimulIni );

    iCount := ini.ReadInteger('Simulation', 'Count', 0 );

    if iCount > 0 then
      SetLength( FSimulEnv.SimulWins, iCount );

    FSimulEnv.TotCount  := iCount;

    gLog.Add(lkDebug, 'TSimulationMain', 'initConfig', 'TotCount : ' + IntToStr( iCount ) );

    with FSimulEnv do
      for i := 0 to iCount - 1 do
      begin
        stDir := 'Simul'+IntToStr(i+1);
        SimulWins[i].Name := ini.ReadString('Simulation', stDir, '');
        SimulWins[i].Index:= i;
        SimulWins[i].InitFile := SimulWins[i].Name + '.ini';
        stDir := 'Desc' + IntTostr(i+1);
        SimulWins[i].Desc := ini.ReadString('Simulation', stDir, '');


        gLog.Add(lkDebug, 'TSimulationMain', 'initConfig', 'TotCount : ' + IntToStr( iCount ) );
      end;
  finally
    ini.Free;
  end;

end;


procedure TSimulationManager.initControls;
var
  iLeft, iTop, i, j, iCol : integer;
  pBtn  : TButton;
begin
  initConfig;

  iTop := 8;  iLeft := 8; iCol := 1;  j := 0;

  with SimulEnv do
    for i := 0 to TotCount - 1 do
    begin    

      if i >= (BtnCount * iCol )then
      begin
        iLeft := (BtnWidth * iCol ) + 20;
        inc( iCol );
        iTop  := 8;
        j := 0;
      end;

      pBtn  := TButton.Create( FrmMain.Panel3 );
      pBtn.Parent := FrmMain.Panel3;
      pBtn.Caption  := SimulWins[i].Desc;
      pBtn.Tag      := SimulWins[i].Index;
      pBtn.Width    := BtnWidth;
      pBtn.Height   := BtnHeight;
      pBtn.Top      := iTop + ( j * (BtnHeight + 8) );
      pBtn.Left     := iLeft;

      pBtn.OnClick  := OnBtnClick;

      inc( j );
    end;

end;

procedure TSimulationManager.OnBtnClick(Sender: TObject);
var
  iTag : integer;
  aFC : TFormClass;
  aF  : TForm;
begin
  iTag  := TButton( Sender ).Tag;
  aFC := TFormClass( GetClass( 'T'+SimulEnv.SimulWins[iTag].Name ));
  try
    if aFC <> nil then
    begin
      aF := aFC.Create( FrmMain.Panel3 );
      aF.Show;
      SimulEnv.SimulWins[iTag].MyForm := aF;
    end;
  except
  end;

end;

end.
