unit SystemIF;

interface

uses
  Classes, SysUtils,  GleTypes,

  EtcTypes;

type
  TSignalItem = class;
  TSignalEventItem = class;
  TSystemIF = class;

  TSignalEvent = procedure(Sender : TSystemIF; aSignal : TSignalItem) of object;
  TSignalChangeEvent = procedure(Sender : TSystemIF; aSignal : TSignalItem; aSymbol : TObject) of object;
  TSignalOrderEvent = procedure(Sender : TSystemIF; aEvent : TSignalEventItem) of object;

  TSignalItem = class(TCollectionItem)
  protected
    FRefCount : Integer;

    FTitle : String;
    FSource : String;
    FDescription : String;

    FLastTime : TDateTime;
    FPosition : Integer;
  public
    constructor Create(aColl : TCollection); override;

    procedure Refer;
    procedure Derefer;

    property RefCount : Integer read FRefCount;
    property Title : String read FTitle write FTitle;
    property Source : String read FSource write FSource;
    property Description : String read FDescription write FDescription;

    property LastTime : TDateTime read FLastTime write FLastTime;
    property Position : Integer read FPosition write FPosition;
  end;

  TSignalEventItem = class(TCollectionItem)
  protected
    FSignal : TSignalItem;
    FEventTime : TDateTime;
    FQty : Integer;
    FRemark : String;
  public
    property Signal : TSignalItem read FSignal;
    property EventTime : TDateTime read FEventTime;
    property Qty : Integer read FQty;
    property Remark : String read FRemark;
  end;

  TSystemIF = class

  protected
    FEvents : TCollection; // TSignalEventItem

    FOnLastTime : TNotifyEvent;
    FLastTime : TDateTime;

    FDescription : String;

    FOnSignalAdd : TSignalEvent;
    FOnSignalUpdate : TSignalEvent;
    FOnSignalRemoving : TSignalEvent;
    FOnSignalRemoved : TSignalEvent;

    FOnPositionChange : TSignalEvent;
    FOnSymbolChange: TSignalChangeEvent;

    FOnOrder : TSignalOrderEvent;

    FOnLog : TTextNotifyEvent;

    procedure DoLog(stLog : String);
    function AddEvent(aSignal : TSignalItem; iQty : Integer; stOrder : String) : TSignalEventItem;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Initialize; virtual;
    procedure Synchronize; virtual;
    procedure Finalize; virtual;

    procedure GetSignals(aList : TList); virtual;

    property Description : String read FDescription;

      // last time
    property OnLastTime : TNotifyEvent read FOnLastTime write FOnLastTime;
    property LastTime : TDateTime read FLastTime;
      // signal alias related events
    property OnSignalAdd : TSignalEvent read FOnSignalAdd write FOnSignalAdd;
    property OnSignalUpdate : TSignalEvent read FOnSignalUpdate write FOnSignalUpdate;
    property OnSignalRemoving : TSignalEvent read FOnSignalRemoving write FOnSignalRemoving;
    property OnSignalRemoved : TSignalEvent read FOnSignalRemoved write FOnSignalRemoved;
      // position change
    property OnPositionChange : TSignalEvent read FOnPositionChange write FOnPositionChange;
      // Symbol Change
    property OnSymbolChange : TSignalChangeEvent read FOnSymbolChange write FOnSymbolChange;
      // filled order event used for trigger order
    property OnOrder : TSignalOrderEvent read FOnOrder write FOnOrder;
      //
    property OnLog : TTextNotifyEvent read FOnLog write FOnLog;
  end;

implementation

//===============================================================//
                     { TSignalItem }
//===============================================================//

constructor TSignalItem.Create(aColl : TCollection);
begin
  inherited Create(aColl);

  FLastTime := Now;
  FRefCount := 0;
  FPosition := 0;
end;

procedure TSignalItem.Refer;
begin
  Inc(FRefCount);
end;

procedure TSignalItem.Derefer;
begin
  Dec(FRefCount);
end;

//===============================================================//
                     { TSystemIF }
//===============================================================//


constructor TSystemIF.Create;
begin
  FEvents := TCollection.Create(TSignalEventItem);
end;

destructor TSystemIF.Destroy;
begin
  FEvents.Free;

  inherited;
end;

function TSystemIF.AddEvent(aSignal : TSignalItem; iQty : Integer;
   stOrder : String) : TSignalEventItem;
begin
  Result := FEvents.Insert(0) as TSignalEventItem;

  Result.FSignal := aSignal;
  Result.FEventTime := Now;
  Result.FQty := iQty;
  Result.FRemark := stOrder;
end;

procedure TSystemIF.Initialize;
begin
  // should be overrided by child
end;

procedure TSystemIF.Synchronize;
begin
  // should be overrided by child
end;

procedure TSystemIF.Finalize;
begin
  // should be overrided by child
end;

procedure TSystemIF.GetSignals(aList: TList);
begin
  // should be overrided by child
end;

procedure TSystemIF.DoLog(stLog : String);
begin
  if Assigned(FOnLog) then
    FOnLog(self, stLog);
end;

end.
