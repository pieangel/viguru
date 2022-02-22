unit Signals;

interface

uses
  Classes, SysUtils,

  SystemIF;
  
type
  TSignals = class(TList)
  private
    FEvents : TList;

    FOnAdd : TSignalEvent;
    FOnUpdate : TSignalEvent;
    FOnRemoving : TSignalEvent;
    FOnRemoved : TSignalEvent;
    FOnPositionChange : TSignalEvent;

    FOnOrder : TSignalOrderEvent;

    function GetSignal(i:Integer) : TSignalItem;
    function GetEvent(i:Integer) : TSignalEventItem;
    function GetEventCount : Integer;

    procedure SignalAdd(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalUpdate(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalRemoving(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalRemoved(Sender : TSystemIF; aSignal : TSignalItem);
    procedure PositionChange(Sender : TSystemIF; aSignal : TSignalItem);
    procedure NewOrder(Sender : TSystemIF; aEvent : TSignalEventItem);
  public
    constructor Create;
    destructor Destroy; override;

    function Find(stTitle : String) : TSignalItem;
    procedure AddIF(aSystemIF : TSystemIF);

    property Signals[i:Integer] : TSignalItem read GetSignal; default;
    property Events[i:Integer] : TSignalEventItem read GetEvent;
    property EventCount : Integer read GetEventCount;

    property OnAdd : TSignalEvent read FOnAdd write FOnAdd;
    property OnUpdate : TSignalEvent read FOnUpdate write FOnUpdate;
    property OnRemoving : TSignalEvent read FOnRemoving write FOnRemoving;
    property OnRemoved : TSignalEvent read FOnRemoved write FOnRemoved;

    property OnPositionChange : TSignalEvent read FOnPositionChange write FOnPositionChange;
    property OnOrder : TSignalOrderEvent read FOnOrder write FOnOrder;
  end;


implementation

{ TSignals }

constructor TSignals.Create;
begin
  inherited;

  FEvents := TList.Create;
end;

destructor TSignals.Destroy;
begin
  FEvents.Free;

  inherited;
end;

//
// Public methods
//

function TSignals.Find(stTitle : String) : TSignalItem;
var
  i : Integer;
begin
  Result := nil;

  for i:=0 to Count-1 do
    if CompareStr(Signals[i].Title, stTitle) = 0 then
    begin
      Result := Signals[i];
      Break;
    end;
end;

procedure TSignals.AddIF(aSystemIF : TSystemIF);
begin
  if aSystemIF = nil then Exit;

  aSystemIF.GetSignals(Self);

  aSystemIF.OnSignalAdd := SignalAdd;
  aSystemIF.OnSignalUpdate := SignalUpdate;
  aSystemIF.OnSignalRemoving := SignalRemoving;
  aSystemIF.OnSignalRemoved := SignalRemoved;
  aSystemIF.OnPositionChange := PositionChange;
  aSystemIF.OnOrder := NewOrder;
end;

//
// SystemIF Event Handlers
//

procedure TSignals.SignalAdd(Sender : TSystemIF; aSignal : TSignalItem);
begin
  if (Sender = nil) or (aSignal = nil) then Exit;

  Add(aSignal);

  if Assigned(FOnAdd) then
    FOnAdd(Sender, aSignal);
end;

procedure TSignals.SignalUpdate(Sender : TSystemIF; aSignal : TSignalItem);
begin
  if (Sender = nil) or (aSignal = nil) then Exit;

  if Assigned(FOnUpdate) then
    FOnUpdate(Sender, aSignal);
end;

procedure TSignals.SignalRemoving(Sender : TSystemIF; aSignal : TSignalItem);
begin
  if (Sender = nil) or (aSignal = nil) then Exit;

  Remove(aSignal);

  if Assigned(FOnRemoving) then
    FOnRemoving(Sender, aSignal);
end;

procedure TSignals.SignalRemoved(Sender : TSystemIF; aSignal : TSignalItem);
begin
  if Assigned(FOnRemoved) then                  
    FOnRemoved(Sender, nil);
end;

procedure TSignals.PositionChange(Sender : TSystemIF; aSignal : TSignalItem);
begin
  if (Sender = nil) or (aSignal = nil) then Exit;

  if Assigned(FOnPositionChange) then
    FOnPositionChange(Sender, aSignal);
end;

procedure TSignals.NewOrder(Sender : TSystemIF; aEvent : TSignalEventItem);
begin
  if (Sender = nil) or (aEvent = nil) then Exit;

  FEvents.Insert(0, aEvent);

  if Assigned(FOnOrder) then
    FOnOrder(Sender, aEvent);
end;

//
// Miscellaneous
//

function TSignals.GetSignal(i:Integer) : TSignalItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TSignalItem(Items[i])
  else
    Result := nil;
end;

function TSignals.GetEvent(i:Integer) : TSignalEventItem;
begin
  if (i >= 0) and (i <= FEvents.Count-1) then
    Result := TSignalEventItem(FEvents.Items[i])
  else
    Result := nil;
end;

function TSignals.GetEventCount : Integer;
begin
  Result := FEvents.Count;
end;


end.
