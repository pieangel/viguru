unit DVolume;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmVolume = class(TForm)
    edtVolume: TEdit;
    Button1: TButton;
    procedure edtVolumeKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    function Open( stValue : string ) : boolean;
  end;

var
  FrmVolume: TFrmVolume;

implementation

{$R *.dfm}

procedure TFrmVolume.edtVolumeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8,#13]) then
    Key := #0;
end;

function TFrmVolume.Open( stValue : string ): boolean;
begin
  edtVolume.Text  := stValue;
  Result := ShowModal = mrOK;
end;

end.
