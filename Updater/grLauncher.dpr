program grLauncher;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  UIni in 'UIni.pas',
  CleFTPConnector in 'CleFTPConnector.pas',
  EnvUtil in '..\lemon\Engine\utils\EnvUtil.pas',
  CleParsers in '..\lemon\Engine\utils\CleParsers.pas',
  SynthUtil in '..\lemon\Engine\imports\SynthUtil.pas',
  CryptInt in '..\lemon\Engine\utils\CryptInt.pas';

{$R *.res}
{$R gr_uac.RES}


begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  if Form1.AppType = 'AutoConnect' then
  begin
    Application.ShowMainForm  := false;
    Form1.ExeMainApp;
    Application.Terminate;
  end;
  Application.Run;


end.
