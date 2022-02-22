unit FleWebBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw;

type
  TWebBrowserForm = class(TForm)
    WebBrowser: TWebBrowser;
  private
    { Private declarations }
  public
    procedure Open(stURL: String);
  end;

var
  WebBrowserForm: TWebBrowserForm;

implementation

{$R *.dfm}

{ TTWebBrowserForm }

procedure TWebBrowserForm.Open(stURL: String);
begin
  Caption := stURL;
  //WebBrowser.Color := clWhite;
  WebBrowser.Navigate(stURL);
end;

end.
