unit CleDistributor;

// This class is used to distribute an event to subscribing client objects.
// The keys for subscription are 'Subscriber', 'DataID', 'DataObj'.

interface

uses
  Classes, GleTypes, SysUtils, DateUtils,

  GleLib, CleQuoteTimers, GleConsts;

type
  TDistributorID = 0..255;
  TDistributorIDs = set of TDistributorID;

const
  ANY_EVENT: TDistributorIDs = [];
  //
  MARKET_KEY   = 254;

  ANY_OBJECT: TObject = nil;

  DISTRIBUTE_CAP = 8;

type
  TDistributorEvent = procedure(Sender, Receiver: TObject; DataID: Integer;
    DataObj: TObject; EventID: TDistributorID) of object;

  TDistributorItem = class(TCollectionItem)
  private
    FSubscriber: TObject;
    FDataID: Integer;
    FDataObj: TObject;
    FEventIDs: TDistributorIDs;
    FHandler: TDistributorEvent;
    FPriorityType: TSubscribePriority;
    FLastSendTime: TDateTime;
  public
    property Subscriber: TObject read FSubscriber;
    property DataID: Integer read FDataID;
    property DataObj: TObject read FDataObj;
    property EventIDs: TDistributorIDs read FEventIDs write FEventIDs;
    property Handler: TDistributorEvent read FHandler;
    property PriortyType : TSubscribePriority read FPriorityType write FPriorityType;
    property LastSendTime : TDateTime read FLastSendTime write FLastSendTime;
  end;

  TDistributor = class(TCollection)
  private
    FTimer : TQuoteTimer;
    function NormalInsert(spType: TSubscribePriority): TDistributorItem;
  public
    constructor Create;

    function Subscribe(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject;
      EventIDs: TDistributorIDs; aHandler: TDistributorEvent; spType : TSubscribePriority = spHighest): TDistributorItem;

    function Find(aSubscriber: TObject; iDataID: Integer;
      aDataObj: TObject): TDistributorItem;
    function Distribute(aSender: TObject; iDataID: Integer; aDataObj: TObject;
      anEventID: TDistributorID): Integer;

    function Distribute2(aSender: TObject; iDataID: Integer; aDataObj: TObject;
      anEventID: TDistributorID): Integer;

    function Deliver(aSender, aReceiver: TObject; iDataID: Integer;
      aDataObj: TObject; anEventID: TDistributorID): Boolean;
    procedure Cancel(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject;
      anEventID: TDistributorID); overload;
    procedure Cancel(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject); overload;
    procedure Cancel(aSubscriber: TObject; iDataID: Integer); overload;
    procedure Cancel(aSubscriber: TObject); overload;

    //procedure TimerTimer(Sender: TObject);
  end;

implementation

uses GAppEnv, CleQuoteBroker, ClePrograms, ClePositions, CleOrders, CleFills;

{ TDistributor }

constructor TDistributor.Create;
begin
  inherited Create(TDistributorItem);
end;

//------------------------------------------------------------< subscription >

function TDistributor.NormalInsert( spType : TSubscribePriority ) : TDistributorItem;
var
  i, j :integer;
  bFind : boolean;
begin
  Result := nil;
  bFind  := false;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if FPriorityType >= spType then
      begin
        bFind := true;
        break;
      end;

  if not bFind then
    Result := Add as TDistributorItem
  else
    Result := Insert(i) as TDistributorItem;

end;

function TDistributor.Subscribe(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject; EventIDs: TDistributorIDs;
  aHandler: TDistributorEvent; spType : TSubscribePriority): TDistributorItem;
begin
  Result := Find(aSubscriber, iDataID, aDataObj);

  if Result = nil then
  begin
    if spType = spHighest then
      Result := Insert(0) as TDistributorItem
    else if spType = spNormal then begin
      Result := NormalInsert( spType );
      if Result = nil then
        Result := Add as TDistributorItem;
    end
    else if (spType = spLowest) or ( spType = spIdle) then
      Result := Add as TDistributorItem;

    Result.FSubscriber := aSubscriber;
    Result.FDataID := iDataID;
    Result.FDataObj := aDataObj;
    Result.FEventIDs := EventIDs;
    Result.FHandler := aHandler;
    Result.FPriorityType  := spType;
    Result.LastSendTime := 0;
  end else
    Result.FEventIDs := Result.FEventIDs + EventIDs;
end;

//--------------------------------------------------------------------< find >

function TDistributor.Find(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject): TDistributorItem;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if (FSubscriber = aSubscriber)
         and (FDataID = iDataID)
         and (FDataObj = aDataObj) then
      begin
        Result := Items[i] as TDistributorItem;
        Break;
      end;
end;

//---------------------------------------------------< distribute or deliver >

function TDistributor.Distribute(aSender: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID): Integer;
var
  i: Integer;
  stLog : string;

begin
  Result := 0;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if (iDataID = FDataID)
         and ((FDataObj = ANY_OBJECT) or (FDataObj = aDataObj))
         and ((FEventIDs = ANY_EVENT) or (anEventID in FEventIDs)) then
      try
        if Assigned( FHandler ) then
          FHandler(aSender, FSubscriber, iDataID, aDataObj, anEventID) ;
        //else
        Inc(Result);
      except
         {
        stLog := Format( '%d : %s , %d(%d)', [
          iDataID,
          (Items[i] as TDistributorItem).FSubscriber.ClassName,
          Count, i
          ]);

        gEnv.EnvLog( WIN_ERR, stLog);
        //gLog.Add( lkError, 'TDistributor', 'Distribute', stLog );

         }
      end;
end;

function TDistributor.Distribute2(aSender: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID): Integer;
var
  i: Integer;
  stLog : string;
begin
  Result := 0;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if ((FDataObj = ANY_OBJECT) or (FDataObj = aDataObj)) and
         ((FEventIDs = ANY_EVENT) or (anEventID in FEventIDs)) then
      try
        FHandler(aSender, FSubscriber, iDataID, aDataObj, anEventID) ;
        Inc(Result);
      except
        stLog := Format( '%d : %s , %d(%d)', [
          iDataID,
          (Items[i] as TDistributorItem).FSubscriber.ClassName,
          Count, i
          ]);
      end;
end;


function TDistributor.Deliver(aSender, aReceiver: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID): Boolean;
var
  i: Integer;
begin
  Result := False;


  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if (aReceiver = FSubscriber)
         and (iDataID = FDataID)
         and ((FDataObj = ANY_OBJECT) or (FDataObj = aDataObj))
         and ((FEventIDs = ANY_EVENT) or (anEventID in FEventIDs)) then
      try
        FHandler(aSender, FSubscriber, iDataID, aDataObj, anEventID);
        Result := True;
      finally

      end;
end;

//------------------------------------------------------------------< cancel >

procedure TDistributor.Cancel(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID);
var
  aItem: TDistributorItem;
begin
  aItem := Find(aSubscriber, iDataID, aDataObj);
  if aItem <> nil then
    aItem.FEventIDs := aItem.FEventIDs - [anEventID];
end;

procedure TDistributor.Cancel(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject);
var
  aItem: TDistributorItem;
begin
  aItem := Find(aSubscriber, iDataID, aDataObj);
  if aItem <> nil then
    aItem.Free;
end;

procedure TDistributor.Cancel(aSubscriber: TObject; iDataID: Integer);
var
  i: Integer;
begin
  for i := Count-1 downto 0 do
    with Items[i] as TDistributorItem do
      if (FSubscriber = aSubscriber)
         and (FDataID = iDataID) then
        Items[i].Free;
end;

procedure TDistributor.Cancel(aSubscriber: TObject);
var
  i: Integer;
begin
  for i := Count-1 downto 0 do
    with Items[i] as TDistributorItem do
      if FSubscriber = aSubscriber then
        Items[i].Free;
end;

end.
