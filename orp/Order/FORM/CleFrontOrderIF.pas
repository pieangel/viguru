unit CleFrontOrderIF;

interface

uses
  Classes, Sysutils,

  CleFORMConst, CleAccounts, CleSymbols, CleFORMOrderItems,

  GleTypes
  ;

type

  TFrontOrderIF = class( TCollectionItem )
  private
    FManagerType: TOrderTimeType;
    FOrderList: TList;
    FParam: TFORMParam;
    FOnLog: TTextNotifyEvent;
    FSymbol: TSymbol;
    FAccount: TAccount;
    FOnEvent: TResultNotifyEvent;

    FSelectedItem: TOrderItem;
    FUseMoth: boolean;
    procedure SetParam(const Value: TFORMParam);
    procedure SetSymbol(const Value: TSymbol);
    procedure SetAccount(const Value: TAccount);
    procedure SetUseMoth(const Value: boolean);

  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function Start: boolean; virtual; abstract;
    procedure Stop; virtual; abstract;
    procedure Reset; virtual; abstract;
    procedure Observer; virtual; abstract;

    property Symbol : TSymbol read FSymbol write SetSymbol;
    property Account : TAccount read FAccount write SetAccount;

    property SelectedItem   : TOrderItem read FSelectedItem write FSelectedItem;
    property ManagerType : TOrderTimeType read FManagerType write FManagerType;
    property OrderList   : TList  read FOrderList write FOrderList;
    property Param       : TFORMParam read FParam write SetParam;
    property OnLog       : TTextNotifyEvent read FOnLog write FOnLog;
    property OnEvent     : TResultNotifyEvent read FOnEvent write FOnEvent;

    procedure EnvLog( value : string );
    procedure Notify( Sender : TObject; value : boolean );
  end;

implementation

uses
  CleFormManager, GAppEnv;


{ TFrontOrderManager }


constructor TFrontOrderIF.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FOrderList  := TList.Create;
  FSelectedItem  := nil;

  FUseMoth  := false;
end;

destructor TFrontOrderIF.Destroy;
begin
  FOrderList.Free;
  inherited;
end;


procedure TFrontOrderIF.EnvLog(value: string);
begin
  if Assigned( FOnLog ) then
    FOnLog( Self, value );
end;


procedure TFrontOrderIF.Notify(Sender: TObject; value: boolean);
begin
  if Assigned( FOnEvent ) then
    FOnEvent( Sender, Value );
end;

procedure TFrontOrderIF.SetAccount(const Value: TAccount);
begin
  FSelectedItem := TFrontManager(Collection).OrderItems.New( Value, FSymbol );
  FAccount := Value;
end;

procedure TFrontOrderIF.SetParam(const Value: TFORMParam);
var
  stLog : string;
begin

  FParam.BasePrice := Value.BasePrice;
  FParam.AskPrice  := Value.AskPrice;
  FParam.BidPrice  := Value.BidPrice;

  FParam.OrderGap  := Value.OrderGap;
  FParam.OrderQty  := Value.OrderQty;
  FParam.OrderCnt  := Value.OrderCnt;
  FParam.BidShift  := Value.BidShift;
  FParam.AskShift  := Value.AskShift;
  FParam.StartTime := Value.StartTime;

  FParam.BasisH    := Value.BasisH;
  FParam.BasisL    := Value.BasisL;
  FParam.BasisA    := Value.BasisA;

  FParam.ExUpDown  := Value.ExUpDown;
  FParam.ExUpDownP := Value.ExUpDownP;
  Fparam.ExIndex   := Value.ExIndex;

  Fparam.Upper := Value.Upper;
  Fparam.Lower := Value.Lower;
  Fparam.Delay := Value.Delay;

  Fparam.AskShift2 := Value.AskShift2;
  Fparam.BidShift2 := Value.BidShift2;

  Fparam.CancelTime  := Value.CancelTime;
  Fparam.StartTime   := Value.StartTime;

  FParam.IndexPrice  := Value.IndexPrice;

  FParam.Asks := Value.Asks;
  FParam.Bids := Value.Bids;
  FParam.AskPos := Value.AskPos;
  FParam.BidPos := Value.BidPos;
  FParam.OldVer := Value.OldVer;

  //stLog :=
  {
  if Assigned( FOnLog ) then
    FOnLog( Self, stLog );
  }
end;

procedure TFrontOrderIF.SetSymbol(const Value: TSymbol);
begin
  SelectedItem := TFrontManager(Collection).OrderItems.New( FAccount, Value );
  FSymbol := Value;
end;

procedure TFrontOrderIF.SetUseMoth(const Value: boolean);
var
  stLog : string;
begin
  FUseMoth := Value;

  case FManagerType of
    ottJangBefore: stLog := 'JangBefore';
    ottJangStart:  stLog := 'ottJangStart';
    otSimulEndJust:stLog := 'otSimulEndJust';
    ottJangJung2: stLog := 'ottJangJung2';
    ottJangJung: stLog := 'ottJangJung';
    ottOrdManager: stLog := 'ottOrdManager';
    else
      stLog := '';
  end;

  if Value then
    stLog := stLog + ' Use Moth '
  else
    stLog := stLog + ' Not Use Moth';

  gEnv.EnvLog( WIN_TEST, stLog);
end;

end.


