unit FFundName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  CleFunds
  ;

type
  TFrmFundName = class(TForm)
    edtFundName: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    FFund  : TFund;
    MakeFund : boolean;
  public
    { Public declarations }
    function NewOpen : Boolean;
    function ChangeOpen( aFund: TFund ) : Boolean;

    property Fund  : TFund read FFund;
  end;

var
  FrmFundName: TFrmFundName;

implementation

uses
  GAppEnv
  ;

{$R *.dfm}

{ TFrmFundName }

procedure TFrmFundName.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFrmFundName.btnOKClick(Sender: TObject);
begin

  if edtFundName.Text = '' then
  begin
    ShowMessage('편드명을 입력하세요');
    Exit;
  end;

  if MakeFund then
    FFund := gEnv.Engine.TradeCore.Funds.New(edtFundName.Text)
  else
    if FFund <> nil then    
      FFund.Name  :=  edtFundName.Text;

  if FFund = nil then
    ModalREsult := mrCancel
  else
    ModalResult := mrOK;
end;

function TFrmFundName.ChangeOpen(aFund: TFund): Boolean;
begin
  if aFund = nil then Exit;

  Caption := '편드명 바꾸기';
  FFund := aFund;
  MakeFund  := false;
  edtFundName.Text := aFund.Name;
  Result := (ShowModal = mrOK);
end;

function TFrmFundName.NewOpen: Boolean;
begin
  Caption := '새펀드 만들기';
  FFund  := nil;
  MakeFund  := true;

  Result := (ShowModal = mrOK);
end;

end.
