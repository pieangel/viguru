unit FCurrentTime;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls,

  CleStorage
  ;

type
  TFrmCurrentTime = class(TForm)
    Timer1: TTimer;
    plTime: TPanel;
    popMenu: TPopupMenu;
    N1: TMenuItem;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N1Click(Sender: TObject);
    procedure plTimeDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FMini : boolean;
    FHi   : integer;
    procedure SetMini;
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmCurrentTime: TFrmCurrentTime;

implementation

{$R *.dfm}
uses
  CleQuoteTimers, FTool, gAppEnv;

procedure TFrmCurrentTime.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmCurrentTime.FormCreate(Sender: TObject);
begin
  FHi   := GetSystemMetrics( SM_CYCAPTION ) ;
  FMini := false;
end;



procedure TFrmCurrentTime.N1Click(Sender: TObject);
begin
  TFrmTool.Create(self).Show;
end;

procedure TFrmCurrentTime.plTimeDblClick(Sender: TObject);
begin
  FMini := not FMini;
  SetMini;
end;



procedure TFrmCurrentTime.SetMini;
var
  iTop : integer;
begin
  iTop := Top;
  if FMini then begin

    Height  := Height - FHi;
    BorderStyle  := bsNone;
    Top  := iTop + FHi;
  end
  else begin
    Height  := Height + FHi;
    BorderStyle := bsSizeable;
    Top  := iTop - FHi;
  end;

end;

procedure TFrmCurrentTime.Timer1Timer(Sender: TObject);
begin
  plTime.Color := TColor(gEnv.CurrentTimeSet.TimeBgColor);
  plTime.Font.Color := TColor(gEnv.CurrentTimeSet.TimeFontColor);
  plTime.Font.Size := gEnv.CurrentTimeSet.TimeFontSize;
  plTime.Font.Style := plTime.Font.Style + [fsBold];

  if gEnv.CurrentTimeSet.TimeOnTop then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;

  plTime.Caption := FormatDateTime('AM/PM HH:NN:SS', GetQuoteTime);
end;


procedure TFrmCurrentTime.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  FMini := aStorage.FieldByName('FMini').AsBoolean;
  SetMini;
end;

procedure TFrmCurrentTime.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('FMini').AsBoolean := FMini;
end;

end.
