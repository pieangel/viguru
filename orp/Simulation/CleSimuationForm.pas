unit CleSimuationForm;

interface

uses
  Classes, Forms,

  CleQuoteBroker, CleSymbols,  CleDistributor, CleStorage,

  DleSymbolSelect, CleQuoteTimers
  ;

type

  TSimulationForm = class( TForm )
  private
    //
    FSymbol : TSymbol;
    FQuote  : TQuote;
  public
    SelfDir  : string;
    SelfFile : string;

    LogCount : integer;
    LogIndex : integer;

    Storage  : TStorage;

    procedure FormCreate(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;

    procedure SaveEnv( aStorage: TStorage ); virtual;
    procedure LoadEnv( aStorage: TStorage ); virtual;


  end;

implementation


{ TSimulationForm }

procedure TSimulationForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Storage.Free;
end;

procedure TSimulationForm.FormCreate(Sender: TObject);
begin
  Storage  := TStorage.Create;
  FSymbol  := nil;
  FQuote   := nil;
end;

procedure TSimulationForm.LoadEnv(aStorage: TStorage);
begin

end;

procedure TSimulationForm.SaveEnv(aStorage: TStorage);
begin

end;

end.
