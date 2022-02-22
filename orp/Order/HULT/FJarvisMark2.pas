unit FJarvisMark2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, DateUtils,

  CleSymbols, CleAccounts, CleFunds,

  ClePositions, CleQuoteTimers, CleQuoteBroker, CleKrxSymbols,

  CleStorage, UPaveConfig , GleTypes , CleJarvisMark2,

  ComCtrls, StdCtrls, ExtCtrls , Grids;



type
  TFrmJarvisMark2 = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    Panel2: TPanel;
    gbUseHul: TGroupBox;
    stTxt: TStatusBar;
    dtEndTime: TDateTimePicker;
    GroupBox3: TGroupBox;
    dtStartTime: TDateTimePicker;
    Label6: TLabel;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    edtQty: TEdit;
    udQty: TUpDown;
    edtPrfPoint: TLabeledEdit;
    Label3: TLabel;
    sgLog: TStringGrid;
    edtNum: TEdit;
    udNum: TUpDown;
    cbPlusOne: TCheckBox;
    cbPause: TCheckBox;
    Label5: TLabel;
    edtSymbol: TLabeledEdit;
    Button3: TButton;
    edtPrfPoint2: TLabeledEdit;
    GroupBox2: TGroupBox;
    cbCntRatio: TCheckBox;
    edtEntryCnt: TLabeledEdit;
    edtEntryVol: TLabeledEdit;
    cbVolRatio: TCheckBox;
    edtPara: TLabeledEdit;
    cbPara: TCheckBox;
    stCur: TStaticText;
    stCalcCnt: TStaticText;
    stParaSide: TStaticText;
    Button1: TButton;
    stVol: TStaticText;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    edtAccount: TEdit;
    Button7: TButton;
    GroupBox4: TGroupBox;
    cbProfPara: TCheckBox;
    cbProfVol: TCheckBox;
    cbProfCnt: TCheckBox;
    cbLossCnt: TCheckBox;
    cbLossVol: TCheckBox;
    cbLossPara: TCheckBox;
    Label4: TLabel;
    edtLimitAmt: TLabeledEdit;
    Panel3: TPanel;
    Label1: TLabel;
    edtPrfCnt: TLabeledEdit;
    edtPrfCntRate: TLabeledEdit;
    edtLosCntRate: TLabeledEdit;
    edtLosCnt: TLabeledEdit;
    Panel4: TPanel;
    Label7: TLabel;
    edtPrfVol: TLabeledEdit;
    edtPrfVolRate: TLabeledEdit;
    edtLosVolRate: TLabeledEdit;
    edtLosVol: TLabeledEdit;
    Label8: TLabel;
    stCalcVol: TStaticText;
    Button8: TButton;
    edtLimitPlus: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbStartClick(Sender: TObject);

    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure edtEntryCntKeyPress(Sender: TObject; var Key: Char);
    procedure cbPauseClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    { Private declarations }

    FIsFund : boolean;
    FFund   : TFund;

    FAccount    : TAccount;
    FSymbol     : TSymbol;

    FTimer   : TQuoteTimer;
    FJarvisData : TJarvisData2;

    FMax, FMin : double;
    FAutoStart : boolean;
    //FJM2 : TJarvis2;
    FJM2s: TJarvis2s;

    procedure initControls;
    procedure GetParam;

    procedure Timer1Timer(Sender: TObject);
    function GetRect(oRect: TRect): TRect;

    procedure SetControls(bEnable: boolean);
    procedure DoLog( stLog : string );
    function IsSymbol(aSymbol: TSymbol): boolean;
  public
    { Public declarations }
    procedure Stop( bCnl : boolean = true );
    procedure Start;
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
    procedure OnDisplay(Sender: TObject; Value : boolean );
    procedure OnJarvisNotify( Sender : TObject; jetType : TjarvisEventType; stData : string );
    procedure BullMessage( var Msg : TMessage ) ;  message WM_ENDMESSAGE;

  end;

var
  FrmJarvisMark2: TFrmJarvisMark2;

implementation

uses
  GAppEnv, GleLib,
  CleFQN;{ CleStrategyStore, CleVirtualHult; }

{$R *.dfm}

{ TFrmBHult }

procedure TFrmJarvisMark2.BullMessage(var Msg: TMessage);
begin
  cbStart.Checked := false;
end;

procedure TFrmJarvisMark2.Button2Click(Sender: TObject);
var
  I: Integer;
begin

  if not cbStart.Checked then Exit;
  if FJM2s.Count <= 0 then Exit;

  case ( Sender as TButton).Tag of
    0 :
      with FJarvisData do
      begin
        StartTime   := dtStartTime.Time;
        EndTime     := dtEndTime.Time;
      end;
    1 :
      with FJarvisData do
      begin
        OrdQty    := StrToInt( edtQty.Text );
        EntryCnt  := StrToFloat( edtEntryCnt.Text );

        PrfPoint  := StrToFloat( edtPrfPoint.Text );
        PrfCnt    := StrToFloat( edtPrfCnt.Text );
        PrfCntRate:= StrToInt( edtPrfCntRate.Text );

        LosCnt    := StrToFloat( edtLosCnt.Text );
        LosCntRate:= StrToInt( edtLosCntRate.Text );
        LiskAmt   := StrToInt( edtLimitAmt.Text );
        PlusAmt   := StrToInt( edtLimitPlus.Text );
        LimitNum  := StrToInt( edtNum.Text );

        UseOne    := cbPlusOne.Checked;

        // 20190323 추가
        UseEntryCnt := cbCntRatio.Checked;
        UseEntryVol := cbVolRatio.Checked;
        UseEntryPara:= cbPara.Checked;
        EntryVol    := StrToFloat( edtEntryVol.Text );
        PrfPoint2   := StrToFloatDef( edtPrfPoint2.Text, 0 );
        //

        // 20190515 추가
        UseProfCnt  := cbProfCnt.Checked;
        UseProfPara := cbProfPara.Checked;
        UseLossCnt  := cbLossCnt.Checked;
        UseLossPara := cbLossPara.Checked;

         // 20191117 추가
        UseProfVol  := cbProfVol.Checked;
        UseLossVol  := cbLossVol.Checked;
        LosVol      := StrToFloat( edtLosVol.Text );
        PrfVol      := StrToFloat( edtPrfVol.Text );
        LosVolRate  := StrToInt( edtLosVolRate.Text );
        PrfVolRate  := StrToInt( edtPrfVolRate.Text );
        
      end;
  end;

  for I := 0 to FJM2s.Count - 1 do
    FJM2s.Jarvis[i].JarvisData := FJarvisData;

end;

function TFrmJarvisMark2.IsSymbol( aSymbol : TSymbol ) : boolean;
begin
  REsult := true;

  if aSymbol = gEnv.Engine.SymbolCore.Future then
    Exit
  else if aSymbol = gEnv.Engine.SymbolCore.MiniFuture then
    Exit
  else if aSymbol = gEnv.Engine.SymbolCore.Bond10Future then
    Exit
  else if aSymbol= gEnv.Engine.SymbolCore.UsFuture then
    Exit
  else if aSymbol = gEnv.Engine.SymbolCore.KD150Future then
    Exit;

  Result := false;

end;

procedure TFrmJarvisMark2.Button3Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;
  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbStart.Checked then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin

          if gSymbol.Selected.Spec.Market = mtOption then
          begin
            ShowMessage('옵션은 선택할수 없음');
            Exit;
          end;

          if not IsSymbol( gSymbol.Selected ) then
          begin
            ShowMessage('해당종목은 선택할수 없음');
            Exit;
          end;

          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.ShortCode;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmJarvisMark2.Button4Click(Sender: TObject);
var
  i : Integer;
begin
  if cbStart.Checked then
    for I := 0 to FJM2s.Count - 1 do
      FJM2s.Jarvis[i].DoTest( 1 );
end;

procedure TFrmJarvisMark2.Button5Click(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FJM2s.Count - 1 do
      FJM2s.Jarvis[i].DoTest( 2 );
end;

procedure TFrmJarvisMark2.Button6Click(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FJM2s.Count - 1 do
      FJM2s.Jarvis[i].DoTest( 3 );
end;


procedure TFrmJarvisMark2.Button8Click(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FJM2s.Count - 1 do
      FJM2s.Jarvis[i].DoTest( 4 );
end;


procedure TFrmJarvisMark2.Button7Click(Sender: TObject);
begin
  if cbStart.Checked then begin
    ShowMessage('실행중에는 바꿀수 없음');
    Exit;
  end;

  if gAccount = nil then
    gEnv.CreateAccountSelect;

  try
    gAccount.Left := GetMousePoint.X+10;
    gAccount.Top  := GetMousePoint.Y;

    if gAccount.Open then
    begin
      if ( gAccount.Selected <> nil ) then

        if gAccount.Selected is TFund then
        begin
          if FFund <> gAccount.Selected then
          begin
            FIsFund := true;
            FAccount:= nil;
            FFund   := TFund( gAccount.Selected );
            edtAccount.Text := FFund.Name;
          end;
        end else
        begin

            FIsFund := false;
            FFund   := nil;
            FAccount:= TAccount( gAccount.Selected );
            edtAccount.Text := FAccount.Name
        end;
    end;
  finally
    gAccount.Hide;
  end;
end;



procedure TFrmJarvisMark2.cbPauseClick(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FJM2s.Count - 1 do
      FJM2s.Jarvis[i].Pause := cbPause.Checked;
end;

procedure TFrmJarvisMark2.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop( false );
end;

procedure TFrmJarvisMark2.DoLog(stLog: string);
begin
  InsertLine( sgLog, 1 );
  sgLog.Cells[0, 1] := FormatDateTime('hh:nn:ss', GetQuoteTime );
  sgLog.Cells[1, 1] := stLog;
end;

procedure TFrmJarvisMark2.edtEntryCntKeyPress(Sender: TObject; var Key: Char);
begin
  // 숫자. 소수점, 백스페이스
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0;
end;

procedure TFrmJarvisMark2.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmJarvisMark2.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
        cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmJarvisMark2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmJarvisMark2.FormCreate(Sender: TObject);
begin
  initControls;

  FAccount := nil;
  FFund    := nil;
  FIsFund  := false;

  //FJM2 := TJarvis2.Create( nil );
  FJM2s:= TJarvis2s.Create;
  //FSymbol := TSymbol( gEnv.Engine.SymbolCore.Future );

end;

procedure TFrmJarvisMark2.FormDestroy(Sender: TObject);
var
  stLog : string;
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  //gEnv.Engine.TradeCore.PaveManasger.RemvoePave( FJM2 );
  FJM2s.Free;
end;

procedure TFrmJarvisMark2.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

procedure TFrmJarvisMark2.GetParam;
begin

  with FJarvisData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );

    ParaVal := StrToFloat( edtPara.Text );

    // 20190323 추가
    UseEntryCnt := cbCntRatio.Checked;
    UseEntryVol := cbVolRatio.Checked;
    UseEntryPara:= cbPara.Checked;
    EntryVol  := StrToFloat( edtEntryVol.Text );
    PrfPoint2 := StrToFloat( edtPrfPoint2.Text );
    //

    EntryCnt  := StrToFloat( edtEntryCnt.Text );
    PrfPoint  := StrToFloat( edtPrfPoint.Text );
    PrfCnt    := StrToFloat( edtPrfCnt.Text );
    PrfCntRate:= StrToInt( edtPrfCntRate.Text );

    LosCnt    := StrToFloat( edtLosCnt.Text );
    LosCntRate:= StrToInt( edtLosCntRate.Text );
    LiskAmt   := StrToInt( edtLimitAmt.Text );
    PlusAmt   := StrToInt( edtLimitPlus.Text );

    LimitNum  := StrToInt( edtNum.Text );

    UseOne    := cbPlusOne.Checked;

    StartTime   := dtStartTime.Time;
    EndTime     := dtEndTime.Time;

    // 20190323 추가
    UseEntryCnt := cbCntRatio.Checked;
    UseEntryVol := cbVolRatio.Checked;
    UseEntryPara:= cbPara.Checked;
    EntryVol    := StrToFloat( edtEntryVol.Text );
    PrfPoint2   := StrToFloatDef( edtPrfPoint2.Text, 0 );
    //

    // 20190515 추가
    UseProfCnt  := cbProfCnt.Checked;
    UseProfPara := cbProfPara.Checked;
    UseLossCnt  := cbLossCnt.Checked;
    UseLossPara := cbLossPara.Checked;

     // 20191117 추가
    UseProfVol  := cbProfVol.Checked;
    UseLossVol  := cbLossVol.Checked;
    LosVol      := StrToFloat( edtLosVol.Text );
    PrfVol      := StrToFloat( edtPrfVol.Text );
    LosVolRate  := StrToInt( edtLosVolRate.Text );
    PrfVolRate  := StrToInt( edtPrfVolRate.Text );
  end;

end;

procedure TFrmJarvisMark2.OnDisplay(Sender: TObject; Value: boolean);
begin
end;

procedure TFrmJarvisMark2.OnJarvisNotify(Sender: TObject; jetType: TjarvisEventType;
  stData: string);
begin
  if FJM2s.Count <= 0 then Exit;

  if FJM2s.Find( Sender )= nil then Exit;

  case jetType of
    jetLog : DoLog( stData ) ;
    jetStop: PostMessage( Handle, WM_ENDMESSAGE, 0, 0 );
    jetPause:
      begin
        cbPause.Checked := true;
        DoLog( stData ) ;
      end;
  end;

end;

procedure TFrmJarvisMark2.initControls;
begin
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;

  FAutoStart := false;
end;

procedure TFrmJarvisMark2.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
  dtTime : TDateTime;
  aSymbol: TSymbol;

  aFund  : TFund;
  aAcnt  : TAccount;
begin
  if aStorage = nil then Exit;

  FIsFund := aStorage.FieldByName('IsFund').AsBooleanDef(false);
  stCode := aStorage.FieldByName('AcntCode').AsString;

  if FIsFund  then
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Find( stCode );
    if aFund <> nil then
    begin
      FIsFund  := true;
      FFund    := aFund;
      FAccount := nil;
      edtAccount.Text := FFund.Name;
    end;
  end else
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
    if aAcnt <> nil then
    begin
      FIsFund   := false;
      FFund     := nil;
      FAccount  := aAcnt;
      edtAccount.Text := FAccount.Name;
    end;
  end;


  stCode  := aStorage.FieldByName('SymbolCode').AsString ;
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if (aSymbol <> nil) and ( IsSymbol( aSymbol )) then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

  // 기본
  udQty.Position    := StrToIntDef(aStorage.FieldByName('OrderQty').AsString, 2 );
  //
  edtEntryCnt.Text  := aStorage.FieldByName('EntryCnt').AsStringDef('0.65');
  edtPara.Text      := aStorage.FieldByName('ParaVal').AsStringDef('0.01');

  edtPrfPoint.Text  := aStorage.FieldByName('PrfPoint').AsStringDef('1');
  edtPrfCnt.Text    := aStorage.FieldByName('PrfCnt').AsStringDef('0.25');
  edtPrfCntRate.Text:= aStorage.FieldByName('PrfCntRate').AsStringDef('60');

  edtLosCnt.Text    := aStorage.FieldByName('LosCnt').AsStringDef('0.8');
  edtLosCntRate.Text:= aStorage.FieldByName('LosCntRate').AsStringDef('60');
  edtLimitAmt.Text  := aStorage.FieldByName('LimitAmt').AsStringDef('200');
  edtLimitPlus.Text := aStorage.FieldByName('LimitPlus').AsStringDef('200');
  udNum.Position    := StrToInt( aStorage.FieldByName('EntryNum').AsStringDef('2'));
  cbPlusOne.Checked := aStorage.FieldByName('PlusOne').AsBoolean;

    // 20190323 추가
  cbCntRatio.Checked  := aStorage.FieldByName('UseEntryCnt').AsBooleanDef( cbCntRatio.Checked );
  cbVolRatio.Checked  := aStorage.FieldByName('UseEntryVol').AsBooleanDef( cbVolRatio.Checked );
  cbPara.Checked      := aStorage.FieldByName('UseEntryPara').AsBooleanDef( cbPara.Checked );
  edtEntryVol.Text    := aStorage.FieldByName('EntryVol').AsStringDef( edtEntryVol.Text );
  edtPrfPoint2.Text   := aStorage.FieldByName('PrfPoint2').AsStringDef( edtPrfPoint2.Text );

    // 20190515  추가
  cbProfCnt.Checked   :=  aStorage.FieldByName('UseProfCnt').AsBooleanDef( cbProfCnt.Checked );
  cbProfPara.Checked  :=  aStorage.FieldByName('UseProfPara').AsBooleanDef( cbProfPara.Checked );
  cbLossCnt.Checked   :=  aStorage.FieldByName('UseLossCnt').AsBooleanDef(cbLossCnt.Checked );
  cbLossPara.Checked  :=  aStorage.FieldByName('UseLossPara').AsBooleanDef( cbLossPara.Checked );

  // 시간
  //dtTime  := Double( EncodeTime( 9, 15, 0, 0 ));
  dtStartTime.Time  := TDateTime(aStorage.FieldByName('StartTime').AsTimeDef(dtTime) );
  //dtTime  := Double( EncodeTime( 3, 0, 0, 0 ));
  dtEndTime.Time    := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtTime ) );

    // 20191104 추가
  cbProfVol.Checked  :=  aStorage.FieldByName('UseProfVol').AsBooleanDef( cbProfVol.Checked );
  cbLossVol.Checked  :=  aStorage.FieldByName('UseLossVol').AsBooleanDef( cbLossVol.Checked );
  edtPrfVol.Text     :=  aStorage.FieldByName('PrfVol').AsStringDef( edtPrfVol.Text );
  edtPrfVolRate.Text :=  aStorage.FieldByName('PrfVolRate').AsStringDef( edtPrfVolRate.Text );
  edtLosVol.Text     :=  aStorage.FieldByName('LosVol').AsStringDef( edtLosVol.Text );
  edtLosVolRate.Text :=  aStorage.FieldByName('LosVolRate').AsStringDef( edtLosVolRate.Text );


end;

procedure TFrmJarvisMark2.SaveEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin

  if aStorage = nil then Exit;
  // Main
  aStorage.FieldByName('IsFund').AsBoolean := FIsFund;
  if FIsFund then begin
    if FFund <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FFund.Name
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end
  else begin
    if FAccount <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FAccount.Code
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbolcode').AsString     := FSymbol.Code
  else
    aStorage.FieldByName('Symbolcode').AsString    := '';
  // 기본
  aStorage.FieldByName('OrderQty').AsString := edtQty.Text;

  // 조건
  aStorage.FieldByName('EntryCnt').AsString := edtEntryCnt.Text;
  aStorage.FieldByName('ParaVal').AsString  := edtPara.Text;

  aStorage.FieldByName('PrfPoint').AsString := edtPrfPoint.Text;
  aStorage.FieldByName('PrfCnt').AsString := edtPrfCnt.Text;
  aStorage.FieldByName('PrfCntRate').AsString := edtPrfCntRate.Text;

  aStorage.FieldByName('LosCnt').AsString := edtLosCnt.Text;
  aStorage.FieldByName('LosCntRate').AsString := edtLosCntRate.Text;
  aStorage.FieldByName('LimitAmt').AsString := edtLimitAmt.Text;
  aStorage.FieldByName('LimitPlus').AsString := edtLimitPlus.Text;
  aStorage.FieldByName('EntryNum').AsString := edtNum.Text;
  aStorage.FieldByName('PlusOne').AsBoolean := cbPlusOne.Checked;

    // 20190323 추가
  aStorage.FieldByName('UseEntryCnt').AsBoolean := cbCntRatio.Checked;
  aStorage.FieldByName('UseEntryVol').AsBoolean := cbVolRatio.Checked;
  aStorage.FieldByName('UseEntryPara').AsBoolean:= cbPara.Checked;
  aStorage.FieldByName('EntryVol').AsString     := edtEntryVol.Text ;
  aStorage.FieldByName('PrfPoint2').AsString    := edtPrfPoint2.Text;

    // 20190515  추가
  aStorage.FieldByName('UseProfCnt').AsBoolean := cbProfCnt.Checked;
  aStorage.FieldByName('UseProfPara').AsBoolean := cbProfPara.Checked;
  aStorage.FieldByName('UseLossCnt').AsBoolean := cbLossCnt.Checked;
  aStorage.FieldByName('UseLossPara').AsBoolean := cbLossPara.Checked;

  // 시간
  aStorage.FieldByName('StartTime').AsFloat	:= double( dtStartTime.Time );
  aStorage.FieldByName('EndTime').AsFloat	:= double( dtEndTime.Time );

    // 20191104 추가
  aStorage.FieldByName('UseProfVol').AsBoolean  := cbProfVol.Checked ;
  aStorage.FieldByName('UseLossVol').AsBoolean  := cbLossVol.Checked ;
  aStorage.FieldByName('PrfVol').AsString       := edtPrfVol.Text ;
  aStorage.FieldByName('PrfVolRate').AsString   := edtPrfVolRate.Text ;
  aStorage.FieldByName('LosVol').AsString       := edtLosVol.Text ;
  aStorage.FieldByName('LosVolRate').AsString   := edtLosVolRate.Text ;
end;

procedure TFrmJarvisMark2.SetControls( bEnable : boolean );
begin
  button7.Enabled   := bEnable;
  Button3.Enabled   := bEnable;
  cbPause.Visible   := not bEnable;

  if bEnable then
  begin
    Panel1.Color  := clBtnFAce   ;
    GroupBox3.Color := clBtnFAce;
  end
  else begin
    GroupBox3.Color := clSilver;
    Panel1.Color  := clSkyBlue;
  end;
end;

procedure TFrmJarvisMark2.Start;
var
  i : integer;
  aItem : TJarvis2;
begin

  if FIsFund then
  begin
    if ( FFund = nil ) then
    begin
      ShowMessage(' 펀드를 선택하세요');
      cbStart.Checked := false;
      Exit;
    end;
  end else
  begin
    if ( FAccount = nil ) then
    begin
      ShowMessage('계좌를 선택하세요');
      cbStart.Checked := false;
      Exit;
    end;
  end;

  if ( FSymbol = nil ) then
  begin
    ShowMessage('종목을 선택하세 ');
    cbStart.Checked := false;
    Exit;
  end;

  //if FSymbol = nil then FSymbol := TSymbol( gEnv.Engine.SymbolCore.Futures);
  FJM2s.Clear;
  GetParam;

  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aItem  := FJM2s.New('');
      aItem.JarvisData  := FJarvisData;
      aItem.init( FFund.FundAccount[i], FSymbol, integer(opJarvis2));
      aItem.Multi  := FFund.FundItems[i].Multiple;
      aItem.OnJarvisEvent  := OnJarvisNotify;
      aItem.Start;
    end;
  end else
  begin
      aItem  := FJM2s.New('');
      aItem.JarvisData  := FJarvisData;
      aItem.init( FAccount, FSymbol, integer(opJarvis2));
      aItem.OnJarvisEvent  := OnJarvisNotify;
      aItem.Start;
  end;

  if FJM2s.Count > 0 then
  begin
    SetControls( false );
    FTimer.Enabled := true;
  end;
end;

procedure TFrmJarvisMark2.Stop( bCnl : boolean = true );
var
  I: Integer;
begin
  SetControls( true );

  for I := 0 to FJM2s.Count - 1 do
  begin
    FJM2s.Jarvis[i].Stop( bCnl );
    FJM2s.Jarvis[i].OnJarvisEvent := nil;
  end;

end;

procedure TFrmJarvisMark2.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
  var
    oRect : TRect;
begin
  //
  if stTxt.Tag = 0 then begin
    StatusBar.Canvas.Brush.Color := clBtnFace;
    StatusBar.Canvas.Font.Color := clBlack;
  end
  else if stTxt.Tag < 0 then begin
    StatusBar.Canvas.Brush.Color := clBlue;
    StatusBar.Canvas.Font.Color := clWhite;
  end
  else if stTxt.Tag > 0 then begin
    StatusBar.Canvas.Brush.Color := clRed;
    StatusBar.Canvas.Font.Color := clWhite;
  end;

  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect(Rect);
  DrawText( stTxt.Canvas.Handle, PChar( stTxt.Panels[0].Text ),
    Length( stTxt.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
end;

function TFrmJarvisMark2.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top+1, oRect.Right, oRect.Bottom );
end;

procedure TFrmJarvisMark2.Timer1Timer(Sender: TObject);
var
  dBase, dCur, dNext, dLoss, dGap,  dPL,
  d1, d2 : double;
  iIdx, iGap  : integer;
  //aSlot : TBHultOrderSlotItem;
  aType : TPositionType;
  ftColor, bkColor : TColor;
  aQuote : TQuote;
  itmp, I: Integer;
  aItem : TJarvis2;
begin

  if (FSymbol = nil ) then exit;

  bkColor := clBtnFace;

  if FSymbol.Quote <> nil then
  begin
    aQuote  := FSymbol.Quote as TQuote;
    dGap  := 0;

    if ( aQuote.Asks.CntTotal = 0 ) or ( aQuote.Bids.CntTotal = 0 ) then
      dGap := 0
    else begin
      dGap := aQuote.CntRatio;
      bkColor := ifThenColor( aQuote.Asks.CntTotal > aQuote.Bids.CntTotal, clBlue, clRed );
    end;

    stCur.Caption := Format('%.2f', [ abs( dGap ) ] );
    stCur.Color   := bkColor;

    dGap := 0;    bkColor := clBtnFace;
    if ( aQuote.Asks.VolumeTotal = 0 ) or ( aQuote.Bids.VolumeTotal = 0 ) then
      dGap := 0
    else begin
      dGap := aQuote.VolRatio;
      bkColor := ifThenColor( aQuote.Asks.VolumeTotal > aQuote.Bids.VolumeTotal, clBlue, clRed );
    end;

    stVol.Caption := Format('%.2f', [ abs( dGap ) ] );
    stVol.Color   := bkColor;

  end;

  //if FJM2 <> nil then
  if FJM2s.Count > 0 then
  begin
    iTmp := 0;        dPL := 0.0;
    for I := 0 to FJM2s.Count - 1 do
    begin

      bkColor := clBtnFace;
      aItem := FJM2s.Jarvis[i];

      if aItem = nil then Continue;

      if i = 0 then
      begin
        if aItem.Para <> nil then
          bkColor := ifThenColor( aItem.Para.Side = 0, clBtnFace,  ifThenColor( aItem.Para.Side > 0, clRed, clBlue ));
        stParaSide.Color  := bkColor;

        stCalcCnt.Caption := Format('%.2f', [ aItem.SaveCnt ]);
        stCalcVol.Caption := Format('%.2f', [ aITem.SaveVol ]);

        stTxt.Panels[1].Text := Format('[%d,%d] %d(%d)', [ aItem.EntryCount, aItem.OrdNum ,
          aItem.LimitOrdCnt, aItem.OrdCnt  ]);
      end;

      if aItem.Position <> nil then
      begin
        iTmp := iTmp + aItem.Position.Volume;
        dPL  := dPL + ( aItem.Position.LastPL - aItem.Position.GetFee );
      end;
    end;

    stTxt.Panels[0].Text  := IntToStr( iTmp );
    stTxt.Tag := iTmp;

    FMin := Min( FMin, dPL );
    FMax := Max( FMax, dPL );

    stTxt.Panels[2].Text := Format('%.0f, %.0f, %.0f', [ dPL/1000 , FMax/1000, FMin/1000]);
  end;

end;

end.

