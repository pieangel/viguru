unit CleTodarkeSystem;

interface

uses
  classes, SysUtils, DateUtils,

  CleTodarke, CleOrderConsts, CleOrderBeHaivors, CleDistributor, CleStrategyStore,

  CleOrders, CleQuoteBroker, CleSymbols, CleQuoteTimers, CleAccounts, GleTypes ,

  ClePositions

  ;
type

  TTodarkeLogEvent = procedure( Values : TStrings; index : integer ) of Object;

  TTodarkeSystem = class( TStrategyBase )
  private
    FTimer : TQuoteTimer;
    FRun    : boolean;
    FSymbol: TSymbol;
    FQuote: TQuote;
    FMainItem: TTodarkeSymbol;
    FTodarkes: TTodarkeSymbols;
    FOnLogEvent: TTodarkeLogEvent;
    procedure OnTimeEvent( Sender : TObject );
  public

    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;

    function start( param : TTodarkeParam ) : boolean;
    procedure stop ;

    procedure init;
    procedure SetAccount(aAcnt : TAccount);
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject; DataID: Integer;
        DataObj: TObject; EventID: TDistributorID);
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    procedure UpdateParam(  param : TTodarkeParam ) ;
    procedure OnOrderEvent(Sender: TObject; Value : boolean );

    property  Todarkes : TTodarkeSymbols read FTodarkes write FTodarkes;
    property  Symbol  : TSymbol read FSymbol write FSymbol;
    property  Quote   : TQuote  read FQuote write FQuote;
    property  MainItem: TTodarkeSymbol read FMainItem write FMainItem;

    property OnLogEvent : TTodarkeLogEvent read FOnLogEvent write FOnLogEvent;
  end;

implementation

{ TTodarkeSystem }
uses
  GAppEnv , GleLib , GleConsts
  ;

constructor TTodarkeSystem.Create(aColl: TCollection; opType: TOrderSpecies);
var
  aItem :  TTodarkeSymbol;
begin
  inherited Create(aColl, opType, stTodarke, false);

  FTodarkes:= TTodarkeSymbols.Create;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 1000;
  FTimer.OnTimer  := OnTimeEvent;

  FRun := false;
end;

destructor TTodarkeSystem.Destroy;
begin
  if FTimer <> nil then
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  gEnv.Engine.QuoteBroker.Cancel( Self );
  FTimer.Enabled  := false;
  FTodarkes.Free;
  inherited;
end;

procedure TTodarkeSystem.init;
begin
  // 기본으로 선물 하나 추가
  FSymbol  := gEnv.Engine.SymbolCore.Future;
  MainItem := FTodarkes.new( FSymbol );
  MainItem.Account := Account;
  MainItem.Number  := Number;
  MainItem.OnOrderEvent := OnOrderEvent;
  //MainItem.Position.Account := Account;
  //MainItem.Position.Symbol :=  FSymbol;

  FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteBrokerEventHandler, true);
end;

procedure TTodarkeSystem.OnOrderEvent(Sender: TObject; Value: boolean);
var
  I: Integer;
  aItem : TTodarkeSymbol;
  stLog : string;
  stLst : TStringList;
begin
  if FMainItem <> ( Sender as TTodarkeSymbol ) then Exit;

  for I := 0 to FTodarkes.Count - 1 do
  begin
    aItem := FTodarkes.TodarkeSymbol[i];
    if aItem <> FMainItem then
      aItem.LastCon.Assign( FMainItem.Condition );
    aItem.DoOrder( aItem.Symbol.Quote as TQuote, Value )
  end;

  if Assigned( FOnLogEvent) then
  begin
    try
      stLog := Format('%s주문 %.2f 조건, s(%d), l(%d)', [
        ifThenStr( FmainItem.Condition.Side > 0, '매수','매도'),
        FTodarkes.Param.Condition[ FmainItem.Condition.No]   ,
        FMainItem.LastCon.AskCnt, FMainItem.LastCon.BidCnt
      ]);
      gEnv.EnvLog( WIN_TEST, stLog );
      stLst := TStringList.Create;
      stLst.Add( ifThenStr( FmainItem.Condition.Side > 0, 'L','S') );
      stLst.Add( format('%.2f',[FTodarkes.Param.Condition[ FmainItem.Condition.No]] ));
      stLst.Add( ifThenStr( FMainItem.LastCon.OccurCross,'Cross','Todarke' ));
      stLst.Add(
        ifThenStr( FmainItem.Condition.Side > 0,
        Format('BidC(%d,%.0f), AskC(%d)',[FMainItem.LastCon.BidCnt, FMainItem.LastCon.BidCnt* FTodarkes.Param.Condition[ FmainItem.Condition.No], FMainItem.LastCon.AskCnt]),
        Format('AskC(%d,%.0f), BidC(%d)',[FMainItem.LastCon.AskCnt, FMainItem.LastCon.AskCnt* FTodarkes.Param.Condition[ FmainItem.Condition.No], FMainItem.LastCon.BidCnt])));

      FOnLogEvent( stLst, stLst.Count );
    finally
      stLst.Free;
    end;
  end;

end;

procedure TTodarkeSystem.OnTimeEvent(Sender: TObject);
begin
  //if (FMainItem <> nil) and (FQuote <> nil) and (FRun) then
  //  FMainItem.CheckTime( FQuote);
end;

procedure TTodarkeSystem.QuoteBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if ( DataObj = nil ) or ( FQuote <> ( DataObj as TQuote )) then Exit;
  if FRun then
    FMainItem.CheckTime( FQuote);
end;

procedure TTodarkeSystem.QuoteProc(aQuote: TQuote; iDataID : integer);
begin
  inherited;

end;

procedure TTodarkeSystem.SetAccount(aAcnt: TAccount);
var
  I: Integer;
begin
  if aAcnt = nil then Exit;
  
  Account := aAcnt;
  for I := 0 to FTodarkes.Count - 1 do
    FTodarkes.TodarkeSymbol[i].Account := Account;
end;

function TTodarkeSystem.start(param: TTodarkeParam): boolean;
begin
  UpdateParam( param );
  FTimer.Enabled  := true;
  FRun  := true;
  Result := true;
end;

procedure TTodarkeSystem.stop;
begin
  FRun := false;
  FTimer.Enabled := false;
end;

procedure TTodarkeSystem.TradeProc(aOrder: TOrder; aPos: TPosition;
  iID: integer);
var
  I: Integer;
begin
  if aOrder.OrderSpecies <> opTodarke then Exit;

  if aPos = nil then exit;

  if iID = ORDER_FILLED then
    for I := 0 to FTodarkes.Count - 1 do
      if FTodarkes.TodarkeSymbol[i].Symbol = aOrder.Symbol then
      begin
        FTodarkes.TodarkeSymbol[i].OnPosition( aPos );
        FTodarkes.TodarkeSymbol[i].OnOrder( aOrder );
        break;
      end;

end;

procedure TTodarkeSystem.UpdateParam(param: TTodarkeParam);
var
  I: Integer;
begin
  FTodarkes.Param.Assign( param );

  for I := 0 to FTodarkes.Count - 1 do
    FTodarkes.TodarkeSymbol[i].SetCondition;
end;

end.
