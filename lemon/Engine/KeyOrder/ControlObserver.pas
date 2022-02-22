unit ControlObserver;

interface

uses Classes, SysUtils,
     //
     CleDistributor;


const
  // control ID
  CID_Action  = 401;
  CID_Notify  = 402;

  // cntrol Form Id
  CFID_EFORDER = 501;
  CFID_KBORDER = 502;
  CFID_DOORDER = 503;

  // Action
  ACID_CENTER = 601;
  ACID_MODIFYQTY = 602;  // 현재수량
  ACID_MODIFYQTYALL = 603; // 전체수량


type

  TRefreshItem = class(TCollectionItem)
  public
    Refreshed : Boolean;
  end;

  TObserverItem = class(TRefreshItem)
  public
    Desc : String;
    FORMID : Integer;
    CallTime : TDateTime;
    ActionID : Integer;
  end;

  TControlObserver = class
  private
      // created objects
    FDistributor: TDistributor;


    FObservers : TCollection;
  public
    constructor Create;
    destructor Destroy; override;

    function Notify(Sender : TObject; iCallForm, iActionID : Integer; stDesc : String) : Boolean;
    property Distributor : TDistributor read FDistributor;
  end;

var
  gCObserver : TControlObserver;

implementation

{ TControlObserver }

constructor TControlObserver.Create;
begin
  FObservers := TCollection.Create(TObserverItem);
  FDistributor:= TDistributor.Create;
end;

destructor TControlObserver.Destroy;
begin
  FObservers.Free;
  FDistributor.Free;
  inherited;
end;

function TControlObserver.Notify(Sender: TObject; iCallForm,
  iActionID: Integer; stDesc: String): Boolean;
var
  aItem : TObserverItem;
begin
  Result := True;

  aItem := FObservers.Add as TObserverItem;

  aItem.Desc := stDesc;
  aItem.FORMID := iCallForm;
  aItem.CallTime := Now;
  aItem.ActionID := iActionID;

  FDistributor.Distribute(Sender,iCallForm, aItem, MARKET_KEY)
  //FBroadcaster.Broadcast(Sender, aItem, iCallForm, btNew);
end;

end.
