unit DleSelectionCat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CategoryButtons, StdCtrls;

type
  TCategoricalSelectionDialog = class(TForm)
    CategoryButtons: TCategoryButtons;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FSelected: Integer;

    procedure ButtonClick(Sender: TObject);
  public
    procedure Clear;
    procedure AddSelection(stCategory, stSelection: String; iKeyNo: Integer);

    function Execute: Boolean;

    property Selected: Integer read FSelected;
  end;

var
  CategoricalSelectionDialog: TCategoricalSelectionDialog;

implementation

{$R *.dfm}

{ TCategoricalSelectionDialog }

//---------------------------------------------------------------------< init >

procedure TCategoricalSelectionDialog.FormCreate(Sender: TObject);
begin
  Clear;
end;


procedure TCategoricalSelectionDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TCategoricalSelectionDialog.Clear;
begin
  CategoryButtons.Categories.Clear;
end;

//----------------------------------------------------------------------< add >

procedure TCategoricalSelectionDialog.AddSelection(stCategory,
  stSelection: String; iKeyNo: Integer);
var
  aCategory: TButtonCategory;
  i: Integer;
begin
  aCategory := nil;

    // find the category
  for i := 0 to CategoryButtons.Categories.Count - 1 do
    if CompareStr(stCategory, CategoryButtons.Categories[i].Caption) = 0 then
    begin
      aCategory := CategoryButtons.Categories[i];
      Break;
    end;

    // if none, add the category
  if aCategory = nil then
  begin
    aCategory := CategoryButtons.Categories.Add;
    aCategory.Caption := stCategory;
  end;

    // Add item
  with aCategory.Items.Add do
  begin
    Caption := stSelection;
    OnClick := ButtonClick;
    ImageIndex := iKeyNo;
  end;
end;

//----------------------------------------------------------------< selection >

procedure TCategoricalSelectionDialog.ButtonClick(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TCategoryButtons) then Exit;

  FSelected := (Sender as TCategoryButtons).SelectedItem.ImageIndex;
  
  ModalResult := mrOK;
end;

function TCategoricalSelectionDialog.Execute: Boolean;
begin
  Result := (ShowModal = mrOK);
end;

end.

// $00DBE1E2
