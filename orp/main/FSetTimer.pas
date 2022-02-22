unit FSetTimer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DateUtils,

  CleTimers, ComCtrls;

type
  TFrmSetTimer = class(TForm)
    Button2: TButton;
    dlgOpen: TOpenDialog;
    edtSound: TEdit;
    btnElw: TButton;
    Button3: TButton;
    Button1: TButton;
    Label4: TLabel;
    edtTitle: TEdit;
    dtTimer: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnElwClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FTimer  : TTimerItem;
    FEdit   : boolean;
  public
    { Public declarations }
    function Open( bEdit : boolean ) : boolean;
    function MakeTimer : TTimerItem;
    procedure EditTimer;
    procedure SetTimer( aTimer : TTimerItem );
  end;

var
  FrmSetTimer: TFrmSetTimer;

implementation

uses
  GAppEnv, GleLib,
  FTool;

{$R *.dfm}

procedure TFrmSetTimer.btnElwClick(Sender: TObject);
var
  i : Integer;
  stname : string;
begin

  stname := '';
  if( dlgOpen.Execute ) then
    with dlgOpen.Files do
      for i := 0 to Count - 1 do
        stname := Strings[i];

  if stname <> '' then
    edtSound.Text := stname;
end;

procedure TFrmSetTimer.Button1Click(Sender: TObject);
var
  aTimer : TTimerItem;
begin
  aTimer := MakeTimer;
  if aTimer <> nil then
    FrmTool.AddTimer;

  edtTitle.Text := 'Timer ' + IntToStr( gEnv.Engine.Timers.Count );
  edtTitle.SelectAll;
end;

procedure TFrmSetTimer.Button2Click(Sender: TObject);
begin
  if FEdit then
  begin
    EditTimer;
    ModalResult := mrOK;
  end
  else begin
    FrmTool.AddTimer;
    close;
  end;
end;

procedure TFrmSetTimer.Button3Click(Sender: TObject);
begin
  FillSoundPlay( edtSound.Text );
end;

procedure TFrmSetTimer.EditTimer;
var
  aTimer : TTimerItem;
  dtTmp  : TDateTime;
  h, m, s : word;
  stTime : string;
  bRes : boolean;
begin

  if FTimer = nil then Exit;

  try
    dtTmp := dtTimer.Time;

    if edtSound.Text <> '' then
    begin
      stTime := FormatDateTime('hhnnss', dtTmp );

      FTimer.Time  := dtTmp;
      FTimer.TimeDesc := stTime;
      FTimer.Sound := edtSound.Text;
      FTimer.Title := edtTitle.Text;
      //FTimer.RepeatCnt  := StrToIntDef( edtCnt.Text, 2);
      FTimer.IsPlay     := false;
      FTimer.Current    := 0;
      //FTimer.SoundOn  := true;
    end
    else
      ShowMessage('사운드 설정이 잘못됐음' );

  except
    ShowMessage('시간설정이 잘못됐음' );
  end;

end;

procedure TFrmSetTimer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmSetTimer.FormCreate(Sender: TObject);
var
  i : integer;
begin

  FEdit := false;
  edtTitle.Text := 'Timer ' + IntToStr( gEnv.Engine.Timers.Count );
end;

function TFrmSetTimer.MakeTimer : TTimerItem;
var
  aTimer : TTimerItem;
  dtTmp  : TDateTime;

  stTime : string;
  bRes : boolean;
begin

  Result := nil;
  try
    dtTmp := dtTimer.Time;

    if edtSound.Text <> '' then
    begin
      stTime := FormatDateTime('hhnnss', dtTmp );
      bRes   := gEnv.Engine.Timers.Find( stTime );

      if bRes then
      begin
        ShowMessage('같은 시간대 알람이 있음');
        Exit;
      end;

      Result := gEnv.Engine.Timers.New( dtTmp );
      Result.Sound := edtSound.Text;
      Result.Title := edtTitle.Text;
      Result.SoundOn  := true;
      //Result.RepeatCnt  := StrToIntDef( edtCnt.Text, 2);

    end
    else
      ShowMessage('사운드 설정이 잘못됐음' );

  except
    ShowMessage('시간설정이 잘못됐음' );
  end;

end;

function TFrmSetTimer.Open(bEdit: boolean) : boolean;
begin
  FEdit  := true;
  Result := (ShowModal = mrOK);
end;

procedure TFrmSetTimer.SetTimer(aTimer: TTimerItem);
var
  st : string;
begin
  FTimer := aTimer;
  Button1.Visible := false;
  Button2.Caption := '확인';

  edtSound.Text := FTimer.Sound;
  edtTitle.Text := FTimer.Title;
  //edtCnt.Text   := IntToStr( FTimer.RepeatCnt );

  dtTimer.Time  := FTimer.Time;
end;

end.
