unit FMode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmMode = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Open : boolean;
  end;

var
  FrmMode: TFrmMode;

implementation

{$R *.dfm}

{ TTFrmMode }

procedure TFrmMode.Button1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFrmMode.Button2Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

function TFrmMode.Open: boolean;
begin
  result := (ShowModal = mrOK);
end;

end.
