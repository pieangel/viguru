unit CleFormTracker;

interface

uses
  Classes, SysUtils, Forms;

type
  TFormTrackerItem = class(TCollectionItem)
  private
    FForm: TForm;
    FOnDestroy: TNotifyEvent;
  end;

  TFormTracker = class(TCollection)
  private
    FOnFormDestroyed: TNotifyEvent;
    procedure FormDestroyed(Sender: TObject);
  public
    constructor Create;

    procedure AddForm(aForm: TForm);

    property OnFormDestroyed: TNotifyEvent read FOnFormDestroyed write FOnFormDestroyed;
  end;

implementation

{ TWindowTracker }

constructor TFormTracker.Create;
begin
  inherited Create(TFormTrackerItem);
end;

procedure TFormTracker.AddForm(aForm: TForm);
begin
  if aForm = nil then Exit;

  with Add as TFormTrackerItem do
  begin
    FForm := aForm;
    FOnDestroy := aForm.OnDestroy;

    aForm.OnDestroy := FormDestroyed;
  end;
end;

procedure TFormTracker.FormDestroyed(Sender: TObject);
var
  i: Integer;
  aItem: TFormTrackerItem;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TFormTrackerItem;
    if aItem.FForm = Sender then
    begin
        // notify that the form was(will be) destroyed
      if Assigned(FOnFormDestroyed) then
      try
        FOnFormDestroyed(Sender);
      finally

      end;
        // call the form's OnDestroy event handler
      try
        if Assigned(aItem.FOnDestroy) then
          aItem.FOnDestroy(Sender);
      finally

      end;
        // remove item
      Items[i].Free;
        //
      Break;
    end;
  end;
end;

end.
