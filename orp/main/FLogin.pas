unit FLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TLogin = class(TForm)
    processCnt: TLabel;
    pBar: TProgressBar;
    Button1: TButton;
    processName: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Login: TLogin;

implementation

{$R *.dfm}

procedure TLogin.Button1Click(Sender: TObject);
begin
  Application.Terminate;
end;

end.
