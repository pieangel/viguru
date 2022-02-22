unit CleQuoteParserIf;

interface

uses
  Classes,

  CleQuoteBroker, CleParsers, CleQuoteTimers;

type

  TIFQuoteParser = class
  //private

  protected
    FParser: TParser; // created
    FQuoteDate: TDateTime;
    FParseCount: Integer;
    FQuoteBroker: TQuoteBroker;

  public
    Constructor Create;
    Destructor  Destroy; override;
    procedure Parse(stData : String); virtual; abstract;

    procedure Parser( pData : PChar; iSize : Integer ); virtual; abstract;

    property QuoteDate: TDateTime read FQuoteDate write FQuoteDate;
    property QuoteBroker: TQuoteBroker read FQuoteBroker write FQuoteBroker;
    //property ParseCount : Integer read FParseCount write FParseCount;
  end;


implementation

{ TIFQuoteParser }

constructor TIFQuoteParser.Create;
begin
  FParser := TParser.Create([]);
    // init
  FQuoteDate := GetQuoteDate;
  FQuoteBroker := nil;
  FParseCount := 0;

end;

destructor TIFQuoteParser.Destroy;
begin
  FParser.Free;
  inherited;
end;

end.
