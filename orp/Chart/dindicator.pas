unit DIndicator;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  //
  Indicator, GleConsts, ComCtrls;

type
  TIndicatorDialog = class(TForm)
    ButtonOK: TButton;
    Button2: TButton;
    Button1: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListIndicators: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListIndicatorsDblClick(Sender: TObject);
  private
    FSelected : TIndicatorClass;
  public
    property Selected : TIndicatorClass read FSelected;
  end;

implementation

{$R *.DFM}

procedure TIndicatorDialog.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  with ListIndicators.Items do
  begin
    Clear;
    for i:=0 to gIndicatorList.Count-1 do
    with gIndicatorList.Items[i] as TIndicatorListItem do
      AddObject(Title, gIndicatorList.Items[i]);
  end;
end;

procedure TIndicatorDialog.ButtonOKClick(Sender: TObject);
begin
  if ListIndicators.ItemIndex < 0 then Exit;
  //
  with ListIndicators.Items.Objects[
             ListIndicators.ItemIndex] as TIndicatorListItem do
    FSelected := IndicatorClass;
  //
  ModalResult := mrOK;
end;

procedure TIndicatorDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TIndicatorDialog.ListIndicatorsDblClick(Sender: TObject);
begin
  ButtonOKClick(ButtonOK);
end;

end.
