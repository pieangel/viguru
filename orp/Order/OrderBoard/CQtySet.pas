unit CQtySet;

interface

uses
  Classes, SysUtils ,

  COBTypes
  ;

const
  RowCount = 4;
  ColCount = 3;

type


  TQtySetItem = class( TCollectionItem )
  private
    FSubscriber: TObject;
    FHandler: TQtyEvent;
    FDataType: TEventType;
  public
    property Subscriber: TObject read FSubscriber;
    property DataType: TEventType read FDataType;
    property Handler: TQtyEvent read FHandler;
  end;

  TQtySetItems = class( TCollection )
  public
    Constructor Create;
    Destructor Destroy; override;

    function Find( Sender : TObject; etType: TEventType ) : TQtySetItem; overload;
    function Find( Sender : TObject ) : TQtySetItem; overload;
    function RegistQtySet( Sender : TObject; etType: TEventType;
      Handler : TQtyEvent ) : integer;
    function BroadCast( Sender : TObject; DataObj: TBaseItem;
      etType: TEventType; vtType : TValueType ) : integer;

    function UnRegistQtySet( Sender : TObject; etType : TEventType ) : integer; overload;
    function UnRegistQtySet( Sender : TObject ) : integer; overload;

  end;

implementation

{ TQtySets }



function TQtySetItems.BroadCast(Sender: TObject; DataObj: TBaseItem;
  etType: TEventType; vtType: TValueType): integer;
var
  i : integer;
  aItem : TQtySetItem;
begin

  if DataObj = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Find( Sender, etType );

    if aItem <> nil then
      aItem.FHandler( self, DataObj, etType, vtType );
  end;

end;

constructor TQtySetItems.Create;
begin
  inherited Create( TQtySetItem );
end;

destructor TQtySetItems.Destroy;
begin

  inherited;
end;

function TQtySetItems.Find(Sender: TObject): TQtySetItem;
var
  i : integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TQtySetItem do
      if (FSubscriber = Sender) then
      begin
        Result := Items[i] as TQtySetItem;
        Break;
      end;

end;

function TQtySetItems.Find(Sender: TObject; etType: TEventType): TQtySetItem;
var
  i : integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TQtySetItem do
      if (FSubscriber = Sender) and (FDataType = etType) then
      begin
        Result := Items[i] as TQtySetItem;
        Break;
      end;
end;

function TQtySetItems.RegistQtySet(Sender: TObject; etType: TEventType;
  Handler: TQtyEvent): integer;
var
  aItem : TQtySetItem;
begin

  aItem := Find( Sender, etType );

  if aItem = nil then
  begin
    aItem := Add as TQtySetItem;
    aItem.FSubscriber := Sender;
    aItem.FHandler    := Handler;
    aItem.FDataType    := etType;
  end;

end;

function TQtySetItems.UnRegistQtySet(Sender: TObject;
  etType: TEventType): integer;
var
  i : integer;
  aItem: TQtySetItem;
begin

  for i := Count-1 downto 0 do
  begin
    aItem := Find(Sender, etType );
    if aItem <> nil then
      aItem.Free;
  end;
end;

function TQtySetItems.UnRegistQtySet(Sender: TObject): integer;
var
  aItem: TQtySetItem;
  i : integer;
begin
  for i := Count-1 downto 0 do
  begin
    aItem := Find(Sender );
    if aItem <> nil then
      aItem.Free;
  end;
end;



end.
