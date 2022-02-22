unit DSignalConfig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls , {AppUtils,} Buttons,
  //
  CleQuoteTimers,
  {Broadcaster, , AppConsts} SignalData;

type

  TSignalConfigDialog = class(TForm)
    ButtonOK: TButton;
    ButtonCancel: TButton;
    GroupBox1: TGroupBox;
    ComboNew: TComboBox;
    Label1: TLabel;
    Label5: TLabel;
    ComboChange: TComboBox;
    ComboLast: TComboBox;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    EditTimeOut: TEdit;
    EditMaxCount: TEdit;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    ComboCloseHour: TComboBox;
    Label7: TLabel;
    ComboCloseMin: TComboBox;
    Label8: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    ButtonHelp: TButton;
    CheckClear: TCheckBox;
    GroupBox4: TGroupBox;
    CheckSignal: TCheckBox;
    CheckSound: TCheckBox;
    Label10: TLabel;
    ButtonOpen: TSpeedButton;
    OpenDialog1: TOpenDialog;
    EditFile: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    LabelTime: TLabel;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NumberLimitKeyPress(Sender: TObject; var Key: Char);
    procedure CheckClearClick(Sender: TObject);
    procedure CheckSoundClick(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
  private
    FConfig : TChasingConfig;
    FQuoteTimer: TQuoteTimer;

    procedure SetConfig(aConfig : TChasingConfig);
    procedure QuoteTimerProc(Sender : TObject);
  public
    property Config : TChasingConfig read FConfig write SetConfig;
  end;

implementation

uses GAppEnv;



{$R *.DFM}

procedure TSignalConfigDialog.ButtonOKClick(Sender: TObject);
  procedure MessageNFocus(aControl : TWinControl; stMsg : String);
  begin
    ShowMessage(stMsg);
    if aControl.CanFocus then
      aControl.SetFocus;
  end;
begin
  // get values
  with FConfig do
  begin
    // order price
    PriceNew    := PriceIndices[ComboNew.ItemIndex];
    PriceChange := PriceIndices[ComboChange.ItemIndex];
    PriceLast   := PriceIndices[ComboLast.ItemIndex];
    // order follow-up
    TimeOut     := StrToIntDef(EditTimeOut.Text, 0);
    MaxRetryCount := StrToIntDef(EditMaxCount.Text, 0);
    // forced clear
    ForcedClear := CheckClear.Checked;
    CloseHour   := StrToIntDef(ComboCloseHour.Text, 15);
    CloseMin    := StrToIntDef(ComboCloseMin.Text, 0);
    // notify
    //NotifyPosition := CheckPosition.Checked;
    NotifySignal := CheckSignal.Checked;
    UseSound := CheckSound.Checked;
    SoundFile := EditFile.Text;
  end;

  // check values
  with FConfig do
  begin
    ComboCloseHour.Text := IntToStr(CloseHour);
    ComboCloseMin.Text := IntToStr(CloseMin);

    if ForcedClear and (not CloseHour in [9..16]) then
      MessageNFocus(ComboCloseHour, '종료 시간을 확인하십시오.')
    else
    if ForcedClear and (not CloseMin in [0..59]) then
      MessageNFocus(ComboCloseMin, '종료 분을 확인하십시오.')
    else
    if ForcedClear and (CloseHour * 100 + CloseMin > 1520) then
      MessageNFocus(ComboCloseHour, '15시 20분 이전을 선택하십시오.')
    else
    if TimeOut < 2 then
      MessageNFocus(EditTimeOut, '대기시간은 2초 이상입니다.')
    else
    if not MaxRetryCount in [1..100] then
      MessageNFocus(EditMaxCount, '정정횟수는 1회 이상 100회 이하입니다.')
    else
      ModalResult := mrOK;
  end;
end;


procedure TSignalConfigDialog.SetConfig(aConfig: TChasingConfig);
  procedure SetIndex(aCombo : TComboBox; iRange : TPriceIndexRange);
  var
    i : Integer;
  begin
    for i:=0 to MAX_INDEX do
      if iRange = PriceIndices[i] then
      begin
        aCombo.ItemIndex := i;
        Break;
      end;
  end;
begin
  FConfig := aConfig;

  // order price
  SetIndex(ComboNew,    FConfig.PriceNew);
  SetIndex(ComboChange, FConfig.PriceChange);
  SetIndex(ComboLast,   FConfig.PriceLast);

  // order follow up
  EditTimeOut.Text :=  IntToStr(FConfig.TimeOut);
  EditMaxCount.Text := IntToStr(FConfig.MaxRetryCount);

  // clear at the end of the day
  CheckClear.Checked := FConfig.ForcedClear;
  ComboCloseHour.Text := IntToStr(FConfig.CloseHour);
  ComboCloseMin.Text := IntToStr(FConfig.CloseMin);
  CheckClearClick(CheckClear);
  
  // notify option
  //CheckPosition.Checked := FConfig.NotifyPosition;
  CheckSignal.Checked := FConfig.NotifySignal;
  CheckSound.Checked := FConfig.UseSound;
  EditFile.Text := FConfig.SoundFile;
  CheckSoundClick(CheckSound);
end;

procedure TSignalConfigDialog.FormCreate(Sender: TObject);
var
  i : Integer ;
begin
  for i:=0 to MAX_INDEX do
  begin
    ComboNew.Items.Add(PriceIndexDescs[i]);
    ComboChange.Items.Add(PriceIndexDescs[i]);
    ComboLast.Items.Add(PriceIndexDescs[i]);
  end;

  FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FQuoteTimer.Interval := 1000;
  FQuoteTimer.OnTimer := QuoteTimerProc;
  FQuoteTimer.Enabled := True;
end;

procedure TSignalConfigDialog.FormDestroy(Sender: TObject);
begin
  FQuoteTimer.Enabled := false;
end;

procedure TSignalConfigDialog.QuoteTimerProc(Sender : TObject);
begin
  LabelTime.Caption := FormatDateTime('hh:nn:ss', Time);
end;

procedure TSignalConfigDialog.NumberLimitKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ((Key < '0') or (Key > '9')) and (Key <> #13)  then Key:=#0;
end;

procedure TSignalConfigDialog.CheckClearClick(Sender: TObject);
begin
  ComboCloseHour.Enabled := CheckClear.Checked;
  ComboCloseMin.Enabled := CheckClear.Checked;
end;

procedure TSignalConfigDialog.CheckSoundClick(Sender: TObject);
begin
  EditFile.Enabled := CheckSound.Checked;
  ButtonOpen.Enabled := CheckSound.Checked;
end;

procedure TSignalConfigDialog.ButtonOpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditFile.Text := OpenDialog1.FileName;
end;


procedure TSignalConfigDialog.ButtonHelpClick(Sender: TObject);
begin
  //gHelp.Show(ID_SYSTEMORDER);
end;

end.
