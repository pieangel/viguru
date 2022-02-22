unit CleSheepBuySystem;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSheepBuy, CleOrderConsts, CleDistributor,

  CleStrategyStore,

  CleOrders, CleQuoteBroker, CleSymbols, CleQuoteTimers, CleAccounts, GleTypes ,

  ClePositions , Gleconsts
;

type

  TSheepBuySystem = class( TStrategyBase )
  private
    FSymbol: TSymbol;
    FSheepBuys: TSheepBuys;
    FRun: boolean;
    FOnPosEvent: TNotifyEvent;
    FOnLogEvent: TLogEvent;
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject; DataID: Integer;
        DataObj: TObject; EventID: TDistributorID);
    function IsReady: boolean;

  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;

    procedure init;
    procedure SetAccount(aAcnt : TAccount);
    procedure LogEvent( Values : TStrings; index : integer );
    procedure DoLiquid; 

    function start( param : TSheepBuyParam ) : boolean;
    procedure stop ;

    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    property Symbol : TSymbol read FSymbol write FSymbol;
    property SheepBuys : TSheepBuys read FSheepBuys;
    property Run : boolean read FRun write FRun;

    property OnPosEvent : TNotifyEvent read FOnPosEvent write FOnPosEvent;
    property OnLogEvent : TLogEvent read FOnLogEvent write FOnLogEvent;
  end;

implementation

uses
  GAppEnv, GleLib
  ;

{ TSheepBuySystem }

constructor TSheepBuySystem.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stSheepBuy, false);
  FSheepBuys:= TSheepBuys.Create;
  FSheepBuys.OnLogEvent := LogEvent;
  FRun  := false;
end;

destructor TSheepBuySystem.Destroy;
begin
  FSheepBuys.Free;
  inherited;
end;

procedure TSheepBuySystem.DoLiquid;
begin
  if not FRun then Exit;
  FSheepBuys.DoLiquid;
end;

procedure TSheepBuySystem.init;
begin
  FSymbol := gEnv.Engine.SymbolCore.Future;
  FSheepBuys.Number := Number;
end;

procedure TSheepBuySystem.QuoteBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin
  if not FRun then Exit;
  if DataObj = nil then Exit;
  aQuote := DataObj as TQuote;
  FSheepBuys.OnQuote( aQuote);
end;

procedure TSheepBuySystem.QuoteProc(aQuote: TQuote; iDataID : integer);
begin
  inherited;

end;

procedure TSheepBuySystem.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FSheepBuys.Account := aAcnt;
end;

function TSheepBuySystem.IsReady : boolean;
begin
  if (FSymbol <> nil ) and ( FSheepBuys.Account <> nil ) then
    Result := true
  else
    Result := false;
end;

procedure TSheepBuySystem.LogEvent(Values: TStrings; index: integer);
begin
  if Assigned( FOnLogEvent ) then
    FOnLogEvent( Values, index );
end;

function TSheepBuySystem.start(param: TSheepBuyParam): boolean;
var
  iCnt : integer;
  I: Integer;
begin
  if not IsReady then begin
    Result := false;
    Exit;
  end;

  iCnt  := High( Param.SheepBuySymbols ) + 1;

  if iCnt <= 0 then
  begin
    Result := false;
    Exit;
  end;

  FSheepBuys.Clear;
  FSheepBuys.Param  := Param;

  for I := 0 to iCnt - 1 do
    FSheepBuys.New( Param.SheepBuySymbols[i].Call, Param.SheepBuySymbols[i].Put );

  FRun := true;
  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteBrokerEventHandler ) ;

  Result := true;
end;

procedure TSheepBuySystem.stop;
begin
  FRun := false;
  FSheepBuys.Reset;
  gEnv.Engine.QuoteBroker.Cancel( Self, FSymbol );
end;

procedure TSheepBuySystem.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
var
  I: Integer;
begin
  if aOrder.OrderSpecies <> opSheepBuy then Exit;

  if aPos = nil then exit;

  if iID = ORDER_FILLED then begin
    SheepBuys.OnPosition( aPos );

    if Assigned( FOnPosEvent ) then
      FOnPosEvent( aPos );
  end;

end;

end.
