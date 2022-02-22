unit DleDateDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TDateDialog = class(TForm)
    Label1: TLabel;
    DateTimePicker: TDateTimePicker;
    ButtonOK: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure SetDate(const Value: TDateTime);
    function GetDate: TDateTime;
    { Private declarations }
  public
    function Execute: Boolean;

    property Date: TDateTime read GetDate write SetDate;
  end;

var
  DateDialog: TDateDialog;

implementation

{$R *.dfm}

procedure TDateDialog.FormCreate(Sender: TObject);
begin
  DateTimePicker.Date := Date;
end;

procedure TDateDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

function TDateDialog.Execute: Boolean;
begin
  Result := (ShowModal = mrOK);
end;

function TDateDialog.GetDate: TDateTime;
begin
  Result := DateTimePicker.Date;
end;

procedure TDateDialog.SetDate(const Value: TDateTime);
begin
  DateTimePicker.Date := Value;
end;

end.
