unit LemonEngine;

interface

uses
  Classes,

  CleSymbolCore, CleQuoteBroker, CleHolidays,
  CleTradeCore, CleTradeBroker,
  CleFormBroker, CleKRXOrderBroker,

  GleTypes,
  CleImportCode,
  CleFormManager,
  CleTimers,
  CleApiManager
  ;

type
  TLemonEngine = class
  private
    FAppStatus: TAppStatus;
    //FSyncFuture: TSyntheticFuturesService;

    FErrCodes: TErrCodeManager;
    FFormManager: TFrontManager;
    FTimers: TTimerItems;
    FApi: TApiManager;

  protected
      // core objects
    FSymbolCore: TSymbolCore;
    FTradeCore: TTradeCore;
    FQuoteBroker: TQuoteBroker;
    FTradeBroker: TTradeBroker;
    FSendBroker: TKRXOrderBroker;
    FHolidays: THolidays;
      // env objects
    FFormBroker: TFormBroker;
      // utility objects

  public
    constructor Create;
    destructor Destroy; override;
    
    procedure CreateApi( aObj : TObject );
      // core objects
    property SymbolCore: TSymbolCore read FSymbolCore;
    property QuoteBroker: TQuoteBroker read FQuoteBroker;
    property TradeCore: TTradeCore read FTradeCore;
    property TradeBroker: TTradeBroker read FTradeBroker;
    property SendBroker : TKRXOrderBroker read FSendBroker ;
    property Holidays: THolidays read FHolidays;

    //property SyncFuture : TSyntheticFuturesService read FSyncFuture write FSyncFuture;
    property FormManager: TFrontManager read FFormManager write FFormManager;
      // env objects
    property FormBroker: TFormBroker read FFormBroker;

      // utility objects
    property AppStatus : TAppStatus read FAppStatus write FAppStatus;

    property ErrCodes  : TErrCodeManager read FErrCodes;
    property Api       : TApiManager read FApi;
    property Timers    : TTimerItems read FTimers;



  end;

implementation

{ TLemonEngine }

constructor TLemonEngine.Create;
begin
  FApi  := nil;
  FSymbolCore := TSymbolCore.Create;
  FQuoteBroker := TQuoteBroker.Create;
  FHolidays := THolidays.Create;
  FTradeCore := TTradeCore.Create;
  FTradeBroker := TTradeBroker.Create;
  FSendBroker  := TKRXOrderBroker.Create;

  FFormBroker := TFormBroker.Create;

  FTradeCore.Orders.OnNew := FTradeBroker.OrderAdded;
    //
  FQuoteBroker.OnFind := FSymbolCore.Symbols.FindCode;
  FTradeBroker.TradeCore := FTradeCore;
  FFormManager:= TFrontManager.Create;

  FErrCodes   := TErrCodeManager.Create;
  FErrCodes.LoadIni;

  FTimers:= TTimerItems.Create;
  Appstatus := asNone;
end;


procedure TLemonEngine.CreateApi(aObj: TObject);
begin
  FApi  := TApiManager.Create( aObj );
end;

destructor TLemonEngine.Destroy;
begin
  FTimers.Free;
  FErrCodes.Free;

  FFormBroker.Free;

  FSendBroker.Free;
  FTradeBroker.Free;
  FTradeCore.Free;
  FHolidays.Free;
  FFormManager.Free;
  FQuoteBroker.Free;
  FSymbolCore.Free;

  if FApi <> nil then
    FApi.Free;
  inherited;
end;


end.


