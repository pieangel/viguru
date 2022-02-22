unit CBoardDistributor;

interface

uses
  Classes, SysUtils ,

  COBTypes
  ;

const
  RowCount = 5;
  ColCount = 3;

type


  TBoardEnvItem = class( TCollectionItem )
  private
    FSubscriber: TObject;
    FHandler: TQtyEvent;
    FDataType: TEventType;
  public
    property Subscriber: TObject read FSubscriber;
    property DataType: TEventType read FDataType;
    property Handler: TQtyEvent read FHandler;
  end;

  TBoardEnvItems = class( TCollection )
  public
    Constructor Create;
    Destructor Destroy; override;

    function Find( Sender : TObject; etType: TEventType ) : TBoardEnvItem; overload;
    function Find( Sender : TObject ) : TBoardEnvItem; overload;
    function Find( etType: TEventType) : TBoardEnvItem; overload;
    function RegistCfg( Sender : TObject; etType: TEventType;
      Handler : TQtyEvent ) : integer;
    function BroadCast( Sender : TObject; DataObj: TObject;
      etType: TEventType; vtType : TValueType ) : integer;


    function UnRegistCfg( Sender : TObject; etType : TEventType ) : integer; overload;
    function UnRegistCfg( Sender : TObject ) : integer; overload;

  end;

implementation

{ TQtySets }



function TBoardEnvItems.BroadCast(Sender: TObject; DataObj: TObject;
  etType: TEventType; vtType: TValueType): integer;
var
  i : integer;
  aItem : TBoardEnvItem;
begin

  if DataObj = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TBoardEnvItem;
    if aItem <> nil then
    begin
      if (aItem.DataType = etType) then
        aItem.FHandler( aItem.FSubscriber, DataObj, etType, vtType );
    end;
  end;
end;



constructor TBoardEnvItems.Create;
begin
  inherited Create( TBoardEnvItem );
end;

destructor TBoardEnvItems.Destroy;
begin

  inherited;
end;

function TBoardEnvItems.Find(etType: TEventType): TBoardEnvItem;
var
  i : integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TBoardEnvItem do
      if (DataType = etType) then
      begin
        Result := Items[i] as TBoardEnvItem;
        Break;
      end;

end;

function TBoardEnvItems.Find(Sender: TObject): TBoardEnvItem;
var
  i : integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TBoardEnvItem do
      if (FSubscriber = Sender) then
      begin
        Result := Items[i] as TBoardEnvItem;
        Break;
      end;

end;

function TBoardEnvItems.Find(Sender: TObject; etType: TEventType): TBoardEnvItem;
var
  i : integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TBoardEnvItem do
      if (FSubscriber = Sender) and (FDataType = etType) then
      begin
        Result := Items[i] as TBoardEnvItem;
        Break;
      end;
end;

function TBoardEnvItems.RegistCfg(Sender: TObject; etType: TEventType;
  Handler: TQtyEvent): integer;
var
  aItem : TBoardEnvItem;
begin

  aItem := Find( Sender, etType );

  if aItem = nil then
  begin
    aItem := Add as TBoardEnvItem;
    aItem.FSubscriber := Sender;
    aItem.FHandler    := Handler;
    aItem.FDataType    := etType;
  end;

end;

function TBoardEnvItems.UnRegistCfg(Sender: TObject;
  etType: TEventType): integer;
var
  i : integer;
  aItem: TBoardEnvItem;
begin

  for i := Count-1 downto 0 do
  begin
    aItem := Find(Sender, etType );
    if aItem <> nil then
      aItem.Free;
  end;
end;

function TBoardEnvItems.UnRegistCfg(Sender: TObject): integer;
var
  aItem: TBoardEnvItem;
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
