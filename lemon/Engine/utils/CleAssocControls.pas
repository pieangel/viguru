unit CleAssocControls;

// (introduction)
// Frequently, you need to design a UI which contains a list of items,
// and users can select an item which should be followed by enabling or disabling
// certain controls.

// (description)
// This class makes a host class object to enable or disable controls
// easier by listing the controls in advance and controlling them with a command.
//

interface

uses
  Classes, Controls;

type
  TAssociatedControlMode = (cmVisibility, cmEnability);

  TAssociatedControl = class(TCollectionItem)
  protected
    FControl: TControl;
    FMode: TAssociatedControlMode;
  end;

  TAssociatedControls = class(TCollection)
  protected
    procedure SetControls(bSwitch: Boolean);
  public
    constructor Create;

    procedure Enlist(rControls: array of TControl; aMode: TAssociatedControlMode);
    procedure Remove(rControls: array of TControl);

    property Switch: Boolean write SetControls;
  end;


implementation

{ TAssociatedControls }

constructor TAssociatedControls.Create;
begin
  inherited Create(TAssociatedControl);
end;

procedure TAssociatedControls.Enlist(rControls: array of TControl;
  aMode: TAssociatedControlMode);
var
  i: Integer;
begin
  for i := Low(rControls) to High(rControls) do
    with Add as TAssociatedControl do
    begin
      FControl := rControls[i];
      FMode := aMode;
    end;
end;

procedure TAssociatedControls.Remove(rControls: array of TControl);
var
  i, k: Integer;
begin
  for k := Low(rControls) to High(rControls) do
    for i := Count - 1 downto 0 do
      with Items[i] as TAssociatedControl do
      try
        if FControl = rControls[k] then
          Items[i].Free;
      finally

      end;
end;

procedure TAssociatedControls.SetControls(bSwitch: Boolean);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  with Items[i] as TAssociatedControl do
  try
    case FMode of
      cmVisibility: FControl.Visible := bSwitch;
      cmEnability: FControl.Enabled := bSwitch;
    end;
  finally
  end;
end;

end.
