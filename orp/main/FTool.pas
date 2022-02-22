unit FTool;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, FSetTimer,

  CleTimers, ExtCtrls
  ;

type
  TFrmTool = class(TForm)
    GroupBox1: TGroupBox;
    edtFut: TEdit;
    btnFut: TButton;
    edtCall: TEdit;
    btnStock: TButton;
    Button5: TButton;
    Button6: TButton;
    dlgOpen: TOpenDialog;
    cbFut: TCheckBox;
    cbcall: TCheckBox;
    cbput: TCheckBox;
    edtPut: TEdit;
    btnElw: TButton;
    GroupBox2: TGroupBox;
    cbMS: TCheckBox;
    edtMS: TEdit;
    udMS: TUpDown;
    Label1: TLabel;
    GroupBox3: TGroupBox;
    lvTimer: TListView;
    edtAdd: TButton;
    edtDel: TButton;
    GroupBox4: TGroupBox;
    cbVolStop: TCheckBox;
    edtVolStop: TEdit;
    Button1: TButton;
    cbFrontQt: TCheckBox;
    edtFrontQt: TEdit;
    Button8: TButton;
    edtFutSec: TEdit;
    Label2: TLabel;
    edtCallSec: TEdit;
    Label4: TLabel;
    edtPutSec: TEdit;
    Label3: TLabel;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    Button7: TButton;
    Button9: TButton;
    GroupBox5: TGroupBox;
    dlgColor: TColorDialog;
    Label5: TLabel;
    plFont: TPanel;
    btnFColor: TButton;
    Label6: TLabel;
    plBg: TPanel;
    btnBGColor: TButton;
    Label7: TLabel;
    cbSize: TComboBox;
    GroupBox6: TGroupBox;
    Label8: TLabel;
    cbHotkey: TComboBox;
    btnTime: TButton;
    cbUseAlram: TCheckBox;
    cbOnTop: TCheckBox;
    cbSCatch: TCheckBox;
    edtSCatch: TEdit;
    Button10: TButton;
    Button11: TButton;
    procedure btnFutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);


    procedure Button5Click(Sender: TObject);
    procedure cbFutClick(Sender: TObject);
    procedure edtAddClick(Sender: TObject);

    procedure edtDelClick(Sender: TObject);
    procedure lvTimerDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvTimerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure btnFColorClick(Sender: TObject);
    procedure btnTimeClick(Sender: TObject);
    procedure cbUseAlramClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    procedure SaveSound;
    procedure TimerSave;
    procedure AddTimer;
    procedure InitCurrentTime;

  end;

var
  FrmTool: TFrmTool;

implementation

uses GleLib, GAppEnv, GleTypes, Registry, GAppForms,
  FOrpMain
;

{$R *.dfm}

procedure TFrmTool.AddTimer;
var
  i: Integer;
  aTimer : TTimerItem;
  aItem : TListItem;
begin
  lvTimer.Clear;

  for i := 0 to gEnv.Engine.Timers.Count - 1 do
  begin
    aTimer := gEnv.Engine.Timers.Timers[i];

    aItem  := lvTimer.Items.Add;
    aItem.Data    := aTimer;
    aItem.SubItems.Add( aTimer.Title );
    aItem.SubItems.Add( FormatDateTime('hh:nn:ss', aTimer.Time) );
    //aItem.SubItems.Add( IntToStr( aTimer.RepeatCnt ));
    aItem.SubItems.Add( ExtractFileName( aTimer.Sound ) );

    if aTimer.SoundOn then
      aItem.Checked := true;
  end;
end;

procedure TFrmTool.btnFColorClick(Sender: TObject);
var
  iTag : integer;
begin

  iTag  := TButton( Sender ).Tag;

  if dlgColor.Execute then
  begin
    case iTag of
    10  : plFont.Color  := dlgColor.Color;
    20 : plBg.Color := dlgColor.Color;
    end;
  end;

end;

procedure TFrmTool.btnFutClick(Sender: TObject);
var
  i, iTag : Integer;
  stname : string;
begin
  iTag := TButton( Sender ).Tag;
  if( dlgOpen.Execute ) then
    with dlgOpen.Files do begin
      for i := 0 to Count - 1 do
      begin
        stname := Strings[i];
      end;
    end;

  case iTag of
    1 : edtVolStop.Text  := stname;
    2 : edtFrontQt.Text  := stname;
    3 : edtSCatch.Text   := stname;
  end;

end;


procedure TFrmTool.btnTimeClick(Sender: TObject);
begin
  gEnv.Engine.FormBroker.Open(ID_CURRENT_TIME, 0)
end;

procedure TFrmTool.Button3Click(Sender: TObject);
var
  iTag : integer;
  stSound : string;
begin

  iTag := TButton( Sender ).Tag;

  case iTag of
    1 : stSound := edtVolStop.Text;
    2 : stSound := edtFrontQt.Text;
    3 : stSound := edtSCatch.Text;
  end;

  FillSoundPlay( stSound );

end;

procedure TFrmTool.Button5Click(Sender: TObject);
begin
       {
  gEnv.FillSnd[opVolStop].IsSound   := cbVolStop.Checked;
  gEnv.FillSnd[opFrontQt].IsSound   := cbFrontQt.Checked;
  gEnv.FillSnd[opSCatch].IsSound    := cbSCatch.Checked;

  gEnv.FillSnd[opVolStop].FillSnd   := edtVolStop.Text;
  gEnv.FillSnd[opFrontQt].FillSnd   := edtFrontQt.Text;
  gEnv.FillSnd[opSCatch].FillSnd   := edtSCatch.Text;


  gEnv.CurrentTimeSet.TimeBgColor := integer(plBg.Color);
  gEnv.CurrentTimeSet.TimeFontColor := integer(plFont.Color);
  gEnv.CurrentTimeSet.TimeFontSize := StrToIntDef(cbSize.Text, 20);
  gEnv.CurrentTimeSet.TimeOnTop := cbOnTop.Checked;
  gEnv.BookMarkHotkey := cbHotkey.ItemIndex + VK_F2;
  gEnv.ConConfig.MothUse := cbMoth.Checked;
           }
  close;
end;

procedure TFrmTool.Button6Click(Sender: TObject);
begin
  close;
end;

procedure TFrmTool.cbFutClick(Sender: TObject);
var
  iTag : integer;
  bEnable : boolean;
begin
  iTag    := TCheckBox( Sender ).Tag;
  bEnable := TCheckBox( Sender ).Checked;

  case iTag of
    1 :
      begin
        edtVolStop.Enabled:= bEnable ;
        Button1.Enabled:= bEnable ;
      end;
    2 :
      begin
        edtFrontQt.Enabled :=bEnable;
        Button8.Enabled:= bEnable ;
      end;
    3 :
      begin
        edtSCatch.Enabled := bEnable;
        Button10.Enabled  := bEnable;
      end;
  end;

end;


procedure TFrmTool.cbUseAlramClick(Sender: TObject);
begin
  gEnv.Engine.Timers.Enable := cbUseAlram.Checked;
  //lvTimer.Enabled := cbUseAlram.Checked;
end;

procedure TFrmTool.edtAddClick(Sender: TObject);
var
  aTimer : TFrmSetTimer;
begin
  aTimer := TFrmSetTimer.Create( Self);
  aTimer.Left := Left + Width;
  aTimer.Top  := Top;
  aTimer.Show;
end;



procedure TFrmTool.edtDelClick(Sender: TObject);
var
  aItem : TListItem;
  aTimer: TTimerItem;
begin
  aItem := lvTimer.Selected;
  if aItem = nil then Exit;

  aTimer := TTimerItem( aItem.Data );
  gEnv.Engine.Timers.DelTimer( aTimer );
  AddTimer;
end;

procedure TFrmTool.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmTool.FormCreate(Sender: TObject);
begin
 {
  edtVolStop.Text := gEnv.FillSnd[opVolStop].FillSnd;
  edtFrontQt.Text := gEnv.FillSnd[opFrontQt].FillSnd;
  edtSCatch.Text  := gEnv.FillSnd[opSCatch].FillSnd;

  cbVolStop.Checked :=  gEnv.FillSnd[opVolStop].IsSound;
  cbFrontQt.Checked :=  gEnv.FillSnd[opFrontQt].IsSound;
  cbSCatch.Checked  := gEnv.FillSnd[opSCatch].IsSound;
   }
  cbFutClick( cbVolStop );
  cbFutClick( cbFrontQt );
  {
  cbMS.Checked  := gEnv.DistType.Used;
  udMS.Position := gEnv.DistType.MS;
  }
  AddTimer;
  cbUseAlram.Checked  := gEnv.Engine.Timers.Enable;
  InitCurrentTime;
  FrmTool := self;

  { khw
  if OrpMainForm.TradeReceiver.FSocket[4].SocketState = ssConnected then
  begin
    btnMothCon.Enabled := false;
    btnMothDis.Enabled := true;
  end
  else begin
    btnMothCon.Enabled := true;
    btnMothDis.Enabled := false;
  end;
  }
end;

procedure TFrmTool.FormDestroy(Sender: TObject);
begin
  FrmTool:= nil;

end;

procedure TFrmTool.InitCurrentTime;
begin
  plFont.Color := TColor(gEnv.CurrentTimeSet.TimeFontColor);
  plBg.Color := TColor(gEnv.CurrentTimeSet.TimeBgColor);
  cbSize.ItemIndex := gEnv.CurrentTimeSet.TimeFontSize - 1;
  cbOnTop.Checked := gEnv.CurrentTimeSet.TimeOnTop;
  cbHotKey.ItemIndex := gEnv.BookMarkHotkey - VK_F2;
end;

procedure TFrmTool.lvTimerDblClick(Sender: TObject);
var
  aItem : TListItem;
  aTimer: TTimerItem;
  aDlg : TFrmSetTimer;
begin
  //lvTimer.ite

  aItem := lvTimer.Items[ lvTimer.ItemIndex ];//lvTimer.Selected;
  if aItem = nil then Exit;
  aTimer := TTimerItem( aItem.Data );

  try
    aDlg := TFrmSetTimer.Create( Self);
    aDlg.Left := Left + Width;
    aDlg.Top  := Top;
    aDlg.SetTimer( aTimer );

    if aDlg.Open( true ) then
      AddTimer;
  finally
    aDlg.Free;
  end;

end;



procedure TFrmTool.lvTimerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    aItem : TListItem;
    aTimer: TTimerItem;
begin
  aItem := TCustomListView(lvTimer).GetItemAt(x,y);
  if aItem = nil then Exit;

  aTimer := TTimerItem( aItem.Data );
  if aTimer = nil then Exit;

  aTimer.SoundOn  := aItem.Checked;
end;

procedure TFrmTool.SaveSound;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin
      {
      WriteString('FutFillSnd', gEnv.FillSnd[0].FillSnd);
      WriteBool('bFutSound', gEnv.FillSnd[0].IsSound);
      WriteString('StockFillSnd', gEnv.FillSnd[1].FillSnd);
      WriteBool('bStockSound', gEnv.FillSnd[1].IsSound);
      WriteString('ElwFillSnd', gEnv.FillSnd[2].FillSnd);
      WriteBool('bElwSound', gEnv.FillSnd[2].IsSound);
      }
      WriteString('iMS', edtMS.Text );
      WriteBool('bMS', cbMS.Checked );
    end;

  finally
    Free;
  end;       
end;

procedure TFrmTool.TimerSave;
var
  i: Integer;
  aTimer : TTimerItem;
  aItem : TListItem;
begin

  for i := 0 to lvTimer.Items.Count -1 do
  begin
    aItem :=  lvTimer.Items[i];
    aTimer:= TTimerItem( aItem.Data );
    if aTimer = nil then
      Continue;
    aTimer.SoundOn  := aItem.Checked;
  end;
end;

end.
