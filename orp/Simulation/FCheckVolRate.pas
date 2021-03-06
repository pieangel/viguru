unit FCheckVolRate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleQuoteBroker, CleSymbols, CleDistributor
  ;

type

  TDataUnit = class( TCollectionItem )
  public
    Quote  : TQuote;

    bidSum : integer;
    bidCnt : integer;
    bidAvg : double;

    procedure init;
  end;

  TCheckVolRate = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Calls , Puts : TList;
  public
    { Public declarations }
    Datas : TCollection;
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  end;

var
  CheckVolRate: TCheckVolRate;

implementation

uses
  GAppEnv , GleLib
  ;

{$R *.dfm}

procedure TCheckVolRate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TCheckVolRate.FormCreate(Sender: TObject);
var
  I: Integer;
  aSymbol : TSymbol;
  aUnit : TDataUnit;
begin
  Calls := TList.Create;
  Puts  := TList.Create;
  Datas := TCollection.Create( TDataUnit );

  gEnv.Engine.SymbolCore.GetCurCallList( 1.0, 0.02, 10, Calls );
  gEnv.Engine.SymbolCore.GetCurPutList( 1.0, 0.02, 10, Puts );

  for I := 0 to Calls.Count - 1 do
  begin
    aUnit :=Datas.Add as TDataUnit;
    aSymbol := TSymbol( Calls.Items[i] );
    aUnit.Quote := gEnv.Engine.QuoteBroker.Subscribe( self, aSymbol, QuoteProc );
    aUnit.init;
  end;

  for I := 0 to Puts.Count - 1 do
  begin
    aUnit :=Datas.Add as TDataUnit;
    aSymbol := TSymbol( Puts.Items[i] );
    aUnit.Quote := gEnv.Engine.QuoteBroker.Subscribe( self, aSymbol, QuoteProc );
    aUnit.init;
  end;

end;

procedure TCheckVolRate.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );

  Datas.Free;
  Calls.Free;
  Puts.Free;
end;

procedure TCheckVolRate.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
    aUnit : TDataUnit;
    I: Integer;
    bFind : boolean;
    bidTmp: double;
    stData : string;
begin

  if ( DataObj = nil ) or ( Receiver <> Self ) then Exit;

  aQuote  := DataObj as TQuote;

  if aQuote.LastEvent  = qtMarketDepth then
  begin
    bFind := false;
    for I := 0 to Datas.Count - 1 do
    begin
      aUnit := TDataUnit( Datas.Items[i] );

      if aUnit.Quote = aQuote then
      begin
        bFind := true;
        break;
      end;

    end;

    if not bFind then Exit;

    with aUnit do
    begin
      bidSum := 0;
      for I := 1 to aQuote.Asks.Size - 1 do
        bidSum  := bidSum + aQuote.Bids[i].Volume;

      if ( bidSum > 0) then
        bidAvg := bidSum / 4;

    end;

    stData := Format('%.2f, %d, %.1f, %.1f, %.1f,  %.1f, %s, %s', [  aQuote.Last,
      aQuote.Bids[0].Volume, aQuote.Bids.RealTimeAvg * 0.7, aUnit.bidAvg * 0.7,
        aQuote.Bids.RealTimeAvg, aUnit.bidAvg ,
        ifThenStr( aQuote.Bids[0].Volume > aQuote.Bids.RealTimeAvg * 0.7, '????','????'),
        ifThenStr( aQuote.Bids[0].Volume > aUnit.bidAvg * 0.7, '????','????')
         ]);

    if aQuote.Last < 0.7 then
      gEnv.EnvLog( WIN_LOG, stData, false, aQuote.Symbol.ShortCode + '_VolRate' );

  end;

end;

{ TDataUnit }

procedure TDataUnit.init;
begin
    bidSum := 0;
    bidCnt := 0;
    bidAvg := 0;
end;


initialization
  RegisterClass( TCheckVolRate );
Finalization
  UnRegisterClass( TCheckVolRate )

end.
