unit ClePrevHLSystem;

interface

uses
  Classes, SysUtils, DateUtils,

  ClePrevHighLow, CleOrderConsts, CleOrderBeHaivors, CleDistributor,

  CleStrategyStore,

  CleOrders, CleQuoteBroker, CleSymbols, CleQuoteTimers, CleAccounts, GleTypes ,

  ClePositions
;

type

  TPrevHLLogEvent = procedure( Values : TStrings; index : integer ) of Object;

  TPrevHLSystem = class( TStrategyBase )
  private
    FTimer : TQuoteTimer;
    FRun    : boolean;
    FSymbol: TSymbol;
    FQuote: TQuote;
    FMainItem: TPrevHLSymbol;
    FOnLogEvent: TPrevHLLogEvent;
    FPrevHLs: TPrevHLs;
    procedure OnTimeEvent( Sender : TObject );
  public

    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;

    function start( param : TPrevHLParam ) : boolean;
    procedure stop ;

    procedure init;
    procedure SetAccount(aAcnt : TAccount);
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject; DataID: Integer;
        DataObj: TObject; EventID: TDistributorID);
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    procedure UpdateParam(  param : TPrevHLParam ) ;
    procedure OnOrderEvent(Sender: TObject; Value : boolean );

    property  PrevHLs : TPrevHLs read FPrevHLs write FPrevHLs;
    property  Symbol  : TSymbol read FSymbol write FSymbol;
    property  Quote   : TQuote  read FQuote write FQuote;
    property  MainItem: TPrevHLSymbol read FMainItem write FMainItem;

    property OnLogEvent : TPrevHLLogEvent read FOnLogEvent write FOnLogEvent;

  end;


implementation

uses
  GAppEnv, Gleconsts , GleLib
  ;
{ TPrevHLSystem }

constructor TPrevHLSystem.Create(aColl: TCollection; opType: TOrderSpecies);
var
  aItem :  TPrevHLOrder;
begin
  inherited Create(aColl, opType, stTodarke, false);

  FPrevHLs:= TPrevHLs.Create;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 1000;
  FTimer.OnTimer  := OnTimeEvent;

  FRun := false;

end;

destructor TPrevHLSystem.Destroy;
begin
  if FTimer <> nil then
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  gEnv.Engine.QuoteBroker.Cancel( Self );
  FTimer.Enabled  := false;
  FPrevHLs.Free;
  inherited;
end;

procedure TPrevHLSystem.init;
begin
  FSymbol  := gEnv.Engine.SymbolCore.Future;
  MainItem := FPrevHLs.new( FSymbol );
  MainItem.Account := Account;
  MainItem.Number  := Number;
  MainItem.OrderEvent := OnOrderEvent;

  FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteBrokerEventHandler, true);
end;

procedure TPrevHLSystem.OnOrderEvent(Sender: TObject; Value: boolean);
var
  I: Integer;
  aItem : TPrevHLSymbol;
  stLst : TStringList;
  aQuote : TQuote;
begin
  if FMainItem <> ( Sender as TPrevHLSymbol ) then Exit;

  for I := 0 to FPrevHLs.Count - 1 do
  begin
    aItem := FPrevHLs.PrevHL[i];
    if aItem <> FMainItem then
      aItem.FStatus[prev].Assign( FMainItem.FStatus[Prev] );
    aItem.DoOrder( aItem.Symbol.Quote as TQuote, Value );

    if Assigned( FOnLogEvent ) then
      try
        with aItem do
        begin
          stLst := TStringList.Create;
          aQuote  := Symbol.Quote as TQuote;
          stLst.Add( ifThenStr( FStatus[Prev].Side > 0,'L','S') );
          stLst.Add( format('%s, %.2f', [Symbol.ShortCode,
            ifThenFloat( FStatus[Prev].Side > 0 , aQuote.Bids[0].Price, aQuote.Asks[0].Price )]));
        end;
        FOnLogEvent( stLst, stLst.Count );
        gLog.Add( lkDebug, 'TPrevHLSystem','OnOrderEvent', stLst[0]+' ' +stLst[1]);
      finally
        stLst.Free;
      end;
  end;

end;

procedure TPrevHLSystem.OnTimeEvent(Sender: TObject);
begin

end;

procedure TPrevHLSystem.QuoteBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if ( DataObj = nil ) or ( FQuote <> ( DataObj as TQuote )) then Exit;
  if FRun then
    FMainItem.CheckTime( FQuote);
end;

procedure TPrevHLSystem.QuoteProc(aQuote: TQuote; iDataID : integer);
begin
  inherited;

end;

procedure TPrevHLSystem.SetAccount(aAcnt: TAccount);
var
  I: Integer;
begin
  if aAcnt = nil then Exit;
  
  Account := aAcnt;
  for I := 0 to FPrevHLs.Count - 1 do
    FPrevHLs.PrevHL[i].Account  := Account;

  gLog.Add( lkDebug, 'TPrevHLSystem','SetAccount', aAcnt.Code );
end;

function TPrevHLSystem.start(param: TPrevHLParam): boolean;
begin
  UpdateParam( param );
  FTimer.Enabled  := true;
  FRun  := true;
  Result := true;
  gLog.Add( lkDebug, 'TPrevHLSystem','start', '');
end;

procedure TPrevHLSystem.stop;
begin
  FRun := false;
  FTimer.Enabled := false;
  gLog.Add( lkDebug, 'TPrevHLSystem','stop', '');
end;

procedure TPrevHLSystem.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
var
  I: Integer;
begin
  if aOrder.OrderSpecies <> opPrevHL then Exit;

  if aPos = nil then exit;

  if iID = ORDER_FILLED then
    for I := 0 to FPrevHLs.Count - 1 do
      if FPrevHLs.PrevHL[i].Symbol = aOrder.Symbol then
      begin
        FPrevHLs.PrevHL[i].OnPosition( aPos );
        FPrevHLs.PrevHL[i].OnOrder( aOrder );
        break;
      end;     
end;

procedure TPrevHLSystem.UpdateParam(param: TPrevHLParam);
begin
  FPrevHLs.Param.Assign( param );
end;

end.
