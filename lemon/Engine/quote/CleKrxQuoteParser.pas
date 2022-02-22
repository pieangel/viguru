unit CleKrxQuoteParser;

interface

uses Classes, SysUtils, Windows, Dialogs,

    // lemon:
  CleQuoteBroker, CleSymbols, CleQuoteParserIF,
    // Lemon: utilities
  CleParsers,  GleConsts,
  CleKrxSymbols,
  CleFQn
    //

  ;

const
  MARKET_DEPTH_SIZE = 5;
  
type
  TKRXQuoteParser = class
  private
    FQuoteDate: TDateTime; // assigned
    FQuoteBroker: TQuoteBroker; // assigned
    FQuoteParser: TIFQuoteParser; // created
    FParseCount: Integer;
    procedure SetQuoteBroker(const Value: TQuoteBroker);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse( stData : string );

    property QuoteDate: TDateTime read FQuoteDate write FQuoteDate;
    property QuoteBroker: TQuoteBroker read FQuoteBroker write SetQuoteBroker;
    property QuoteParser: TIFQuoteParser read FQuoteParser write FQuoteParser;
    property ParseCount : Integer read FParseCount;
  end;

implementation

uses GleTypes, GAppEnv, GleLib, CleQuoteTimers;

//-----------------------------------------------------------------<init>

constructor TKRXQuoteParser.Create;
var
  stLog : string;
begin
    // init
  FQuoteDate := gEnv.AppDate;//GetQuoteDate;
  gEnv.EnvLog( WIN_TEST, 'TKRXQuoteParser.Create :' +  FormatDateTime('yyyy-mm-dd ', FQuoteDate) );
  FQuoteBroker := nil;
  FParseCount := 0;

  FQuoteParser  := nil; //TQuoteParserPv4.Create;  // 2015. 6. 15 º¯°æ
  stLog := 'QuoteParser Ver Pv4';

  gLog.Add( lkApplication, 'TKRXQuoteParser', 'Create', stLog );
end;

destructor TKRXQuoteParser.Destroy;
begin
  FQuoteParser.Free;
  inherited;
end;


procedure TKRXQuoteParser.Parse(stData: string);
begin

  if gEnv.RunMode = rtSimulation then
    if FQuoteDate <> GetQuoteDate then
    begin
      FQuoteDate := GetQuoteDate;
      gEnv.EnvLog( WIN_TEST, 'TKRXQuoteParser.Parse :' +  FormatDateTime('yyyy-mm-dd ', FQuoteDate) );
    end;

  FQuoteParser.Parse( stData );
end;

procedure TKRXQuoteParser.SetQuoteBroker(const Value: TQuoteBroker);
begin
  FQuoteParser.QuoteBroker  := Value;
  //FQuoteBroker := Value;
end;

end.



