unit FConfirmLiqMode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmLiqMode = class(TForm)
    cbConfirm: TCheckBox;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Open( stName : string; iQty : integer ) : boolean;
  end;

var
  FrmLiqMode: TFrmLiqMode;

implementation

{$R *.dfm}

{ TFrmLiqMode }

procedure TFrmLiqMode.Button1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFrmLiqMode.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TFrmLiqMode.Open(stName: string; iQty: integer): boolean;
begin
  Label4.Caption := Format('(%s) 펀드의',[ stName ]);
  Label2.Caption := Format('잔고 수량(%d) 을 주문수량으로 자동 적용', [ iQty ]);
  Result := (ShowModal = mrOK);
end;

end.
