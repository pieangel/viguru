unit FFPopupMsg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons;

type
  TFPopupMsg = class(TForm)
    RichEdit1: TRichEdit;
    Panel1: TPanel;
    Image1: TImage;
    Image2: TImage;
    lb_Time: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: Tcreateparams); override;
  end;

var
  FPopupMsg: TFPopupMsg;

  procedure PopUpMessage( stMessage : string);

implementation

uses GAppEnv;


{$R *.dfm}

//메시지 보이기
procedure PopUpMessage(stMessage : string);
begin
  //살살 줄어들기 멈추고
  with FPopupMsg do begin
    Timer1.Enabled := False;
    Timer2.Enabled := False;

    Height := 155;

    Top := Screen.WorkAreaHeight - Height;
    Left := Screen.WorkAreaWidth - Width-2{여백};

    lb_Time.Caption := FormatDateTime('hh:nn:ss:zzz',now);
    RichEdit1.Text := stMessage;

    Image1.Repaint;
    Image2.Repaint;

    Timer1.Enabled := True;

  end;
end;

procedure TFPopupMsg.CreateParams(var Params: Tcreateparams);
begin
  inherited;
  //왼도우를 Screen 영역으로 만든다. 최상위 폼으로 뛰우기 위해
  Params.WndParent := GetDesktopWindow();
end;

procedure TFPopupMsg.FormCreate(Sender: TObject);
begin
  //작업표시줄에도 안 나타나게
  SetWindowLong(self.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);

  Top := Screen.WorkAreaHeight - Height - 30{여백};
  Left := Screen.WorkAreaWidth - Width  - 10{여백};

  // 사이즈를 없애고 Show 해둔다... 그래야 포커스 이동을 막을수 있다...
  Height := 0;

  Show;
end;


procedure TFPopupMsg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;


//종료버튼
procedure TFPopupMsg.Image2Click(Sender: TObject);
begin
  Self.Height := 0;
end;


procedure TFPopupMsg.Timer2Timer(Sender: TObject);
begin
  if self.Height > 0 then self.Height := self.Height - 5;
  if self.Height > 0 then self.top := self.top + 5;
  if self.Height = 0 then Timer2.Enabled := False;
end;

procedure TFPopupMsg.Timer1Timer(Sender: TObject);
begin
  Timer2.Enabled := True; //폼 살살 사라지기
  Timer1.Enabled := False;
end;

procedure TFPopupMsg.RichEdit1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //////////////////////////////////////////////////////////////////////////////
  // 거부윈도우가 없다면 거부윈도우를 만든다
  //////////////////////////////////////////////////////////////////////////////
  {
  if g_RjtMon = nil then
     gOpenUniqueWindow(TFRjtMon, false, bNew)
  else begin
     g_RjtMon.Show;
  end;
  }
end;

end.
