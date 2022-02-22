unit GuruAutoConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TGuruAuto = class(TForm)
    StatusBar1: TStatusBar;
    btOFF: TButton;
    btON: TButton;
    procedure btONClick(Sender: TObject);
    procedure btOFFClick(Sender: TObject);
  private
    procedure ResultProc(Sender: TObject; bSuccess: Boolean; stMsgType,
      stData: String);
    procedure SetServer(bOn: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GuruAuto: TGuruAuto;

implementation

uses CleMsgClient, GleLib;

{$R *.dfm}

procedure TGuruAuto.btOFFClick(Sender: TObject);
begin
  SetServer(False);
end;

procedure TGuruAuto.btONClick(Sender: TObject);
begin
  SetServer(True);
end;

procedure TGuruAuto.SetServer(bOn : Boolean);
var
  stData : String;
begin
  if gMsgClient = nil then
  begin
    ShowMessage( 'gMzMsgClient is nil');
    Exit;
  end;

  stData := Format('%1s', [BoolToChar(bOn)]);

  gMsgClient.OnUbfAutoMsg := ResultProc;
  if gMsgClient.SendData('01', stData) then
    Statusbar1.Panels[0].Text := FormatDateTime('hh:nn:ss', Now)+' Send to Server...'
  else
    Statusbar1.Panels[0].Text := FormatDateTime('hh:nn:ss', Now)+' Server Closed!';

end;

procedure TGuruAuto.ResultProc(Sender : TObject; bSuccess : Boolean; stMsgType, stData : String);
begin
  if bSuccess then
    Statusbar1.Panels[0].Text := FormatDateTime('hh:nn:ss', Now)+' Send to Server OK'
  else
    Statusbar1.Panels[0].Text := FormatDateTime('hh:nn:ss', Now)+' Server Rejected!'
end;end.
