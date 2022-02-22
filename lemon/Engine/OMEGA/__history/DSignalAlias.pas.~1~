unit DSignalAlias;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TSignalAliasDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    EditAlias: TEdit;
    ButtonOK: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    Label3: TLabel;
    EditStrategy: TEdit;
    Label5: TLabel;
    EditDescription: TEdit;
    EditSymbol: TEdit;
    procedure ButtonOKClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
  private
    function GetAlias: String;
    function GetDescription: String;
    function GetStrategy: String;
    function GetSymbol: String;
    procedure SetAlias(const Value: String);
    procedure SetDescription(const Value: String);
    procedure SetStrategy(const Value: String);
    procedure SetSymbol(const Value: String);
    { Private declarations }
  public
    property Alias : String read GetAlias write SetAlias;
    property Description : String read GetDescription write SetDescription;
    property Strategy : String read GetStrategy write SetStrategy;
    property Symbol : String read GetSymbol write SetSymbol;
  end;

var
  SignalAliasDialog: TSignalAliasDialog;

implementation

{$R *.DFM}

procedure TSignalAliasDialog.ButtonOKClick(Sender: TObject);
begin
  if EditAlias.Text = '' then
  begin
    ShowMessage('신호명을 입력하십시오.');
    EditAlias.SetFocus;
  end else
  if EditStrategy.Text = '' then
  begin
    ShowMessage('Strategy를 입력하십시오.');
    EditStrategy.SetFocus;
  end else
  if EditSymbol.Text = '' then
  begin
    ShowMessage('종목을 입력하십시오.');
    EditSymbol.SetFocus;
  end else
//  if EditInterval.Text = '' then
//  begin
//    ShowMessage('Interval을 입력하십시오.');
//    EditInterval.SetFocus;
//  end else
    ModalResult := mrOK;
end;

function TSignalAliasDialog.GetAlias: String;
begin
  Result := EditAlias.Text;
end;

function TSignalAliasDialog.GetDescription: String;
begin
  Result := EditDescription.Text;
end;

function TSignalAliasDialog.GetStrategy: String;
begin
  Result := EditStrategy.Text;
end;

function TSignalAliasDialog.GetSymbol: String;
begin
  Result := EditSymbol.Text;
end;

procedure TSignalAliasDialog.SetAlias(const Value: String);
begin
  EditAlias.Text := Value;
end;

procedure TSignalAliasDialog.SetDescription(const Value: String);
begin
  EditDescription.Text := Value;
end;

procedure TSignalAliasDialog.SetStrategy(const Value: String);
begin
  EditStrategy.Text := Value;
end;

procedure TSignalAliasDialog.SetSymbol(const Value: String);
begin
  EditSymbol.Text := Value;
end;

procedure TSignalAliasDialog.EditChange(Sender: TObject);
begin
  EditDescription.Text := '(' + EditSymbol.Text + ', ' + EditStrategy.Text + ')';
end;

end.
