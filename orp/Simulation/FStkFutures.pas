unit FStkFutures;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleQuoteBroker, CleSymbols, GleTypes, CleDistributor,
  CleQuoteTimers, cleExcelLog, StdCtrls,
  ExtCtrls

  ;

const
  stTitle = '시간,체결가,수량, 잔량,매도,매수,잔량,잔량,매도,매수,잔량,체결가,수량';

type

  TStkFItem = class( TCollectionItem )
  public
    ExcelLog  : TExcelLog;
    Symbol    : TSymbol;
    Underlying: TSymbol;
    Index     : integer;
    LastData  : string;

    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

  end;


  TStkFutures = class(TForm)
    Panel1: TPanel;
    lbstkf: TListBox;
    Panel2: TPanel;
    lbUnder: TListBox;
    btnAdd: TButton;
    btnAllDel: TButton;
    CheckBox1: TCheckBox;
    procedure lbstkfDblClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnAllDelClick(Sender: TObject);
  private
    FIndex : integer;
    function findDerSymbol(aSymbol: TSymbol): TSymbol;
    procedure LogData(aLog : TStkfItem ;stLog: string);
    procedure DeleteItem(aSymbol: TSymbol);
    function FindLog(aSymbol: TSymbol): TStkfItem;
    { Private declarations }
  public
    { Public declarations }
    LastData : string;
    Logs  : TCollection;
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  end;

var
  StkFutures: TStkFutures;

implementation

uses
  GAppEnv, DleSymbolSelect, CleFQN;

{$R *.dfm}



procedure TStkFutures.btnAddClick(Sender: TObject);
var
  aUnderlying : TSymbol;
  aITem : TStkfItem;
  idx : integer;
  stName : string;
begin

  if gSymbol = nil then
  begin
    gSymbol := TSymbolDialog.Create(Self);
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin

      if gSymbol.Selected <> nil then
      begin

        idx := lbStkf.Items.IndexOfObject( gSymbol.Selected );

        if idx >=0 then
          Exit;

        lbStkf.AddItem( gSymbol.Selected.ShortCode, gSymbol.Selected );
        aUnderlying := (gSymbol.Selected as TDerivative).Underlying;
        gEnv.Engine.QuoteBroker.Subscribe( Self, gSymbol.Selected, QuoteProc );
        if aUnderlying <> nil then begin
          lbUnder.AddItem( aUnderlying.ShortCode, aUnderlying );
          gEnv.Engine.QuoteBroker.Subscribe( Self, aUnderlying, QuoteProc );
        end;

        aItem := TStkfItem( Logs.Add );
        aItem.Symbol := gSymbol.Selected;
        aItem.Underlying  := aUnderlying;

        stName  := Format('주식선물호가비교_%s', [ aUnderlying.Name ]);
        aItem.ExcelLog.LogInit( stName, stTitle);

        //aItem.
      end;

    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TStkFutures.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TStkFutures.FormCreate(Sender: TObject);
var
  stTitle : string;
begin
  LastData := '';
  Logs  := TCollection.Create( TStkfItem );

  {
  stTitle := '시간,체결가,수량, 잔량,매도,매수,잔량,잔량,매도,매수,잔량,체결가,수량';
  ExcelLog.LogInit('주식선물호가비교', stTitle);
  }

end;

procedure TStkFutures.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;


procedure TStkFutures.btnAllDelClick(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
  lbstkf.Clear;
  lbUnder.Clear;
  Logs.Clear;
end;

procedure TStkFutures.DeleteItem( aSymbol : TSymbol );
var
  i : integer;
begin
  for i := 0 to Logs.Count - 1 do
    if TStkfItem( Logs.Items[i]).Symbol = aSymbol then
    begin
      Logs.Delete(i);
      break;
    end;
end;

procedure TStkFutures.lbstkfDblClick(Sender: TObject);
  var
    index : integer;
    aSymbol : TSymbol;
    aUnderlying : TSymbol;
begin
  index := lbstkf.ItemIndex;
  if index < 0 then
    Exit;

  aSymbol := lbstkf.Items.Objects[index] as TSymbol;
  if aSymbol <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel( Self, aSymbol);
    aUnderlying := (aSymbol as TDerivative).Underlying;
    if aUnderlying <> nil then
      gEnv.Engine.QuoteBroker.Cancel( Self, aUnderlying);

    DeleteItem( aSymbol );

  end;
  lbstkf.Items.Delete(index);
  index := lbUnder.Items.IndexOfObject( aUnderlying );
  if index >-1 then
    lbUnder.Items.Delete( index );

end;

function  TStkFutures.findDerSymbol( aSymbol : TSymbol ) : TSymbol;
var
  i : integer;
  bSymbol : Tsymbol;
begin
  Result := nil;

  for I := 0 to lbStkf.Items.Count - 1 do
  begin
    bSymbol := TSymbol( lbStkf.Items.Objects[i] );
    if bSymbol <> nil then
    begin
      if (bSymbol as TDerivative).Underlying = aSymbol then begin
        Result := bSymbol;
        break;
      end;
    end;

  end;

end;



procedure TStkFutures.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote, aQuote2 : TQuote;
    aSymbol : TSymbol;
    index : integer;
    stLog , stDummy: string;
    bF, bF2 : boolean;
    aLog : TStkfItem;
begin
  if DataObj = nil then Exit;
  aQuote := DataObj as TQuote;

  bF := false;
  bF2:= false;

  index := -1;
  if aQuote.Symbol.Spec.Market = mtFutures then
  begin
    index := lbstkf.Items.IndexOfObject( aQuote.Symbol);
    aQuote2 := (aQuote.Symbol as TDerivative).Underlying.Quote as TQuote;
    if aQuote.LastEvent = qtTimeNSale then
      bF := true;
  end
  else if aQuote.Symbol.Spec.Market = mtStock then begin
    if aQuote.LastEvent = qtTimeNSale then
      bF2 := true;
    index := lbUnder.Items.IndexOfObject( aQuote.Symbol );
    aQuote2 := aQuote;
    aSymbol := findDerSymbol( aQuote.Symbol );
    if aSymbol = nil then Exit;

    aQuote := aSymbol.Quote as TQuote;

  end;

  if index < 0 then Exit;

  if (aQuote = nil) or (aQuote2 = nil) then Exit;

  if not CheckBox1.Checked then Exit;

  stLog := Format('%d,%.0f,%.0f,%d,' +
                  '%d,%.0f,%.0f,%d',
                  [
                    aQuote.Asks[0].Volume,
                    aQuote.Asks[0].Price,
                    aQuote.Bids[0].Price,
                    aQuote.Bids[0].Volume,

                    aQuote2.Asks[0].Volume,
                    aQuote2.Asks[0].Price,
                    aQuote2.Bids[0].Price,
                    aQuote2.Bids[0].Volume

                  ]);

  aLog  := FindLog( aQuote.Symbol );
  if aLog = nil then Exit;

  if aLog.LastData = stLog then Exit;
  aLog.LastData := stLog;

  if (bF) or (bF2) then
  begin
    stDummy := Format('%.0f, %d', [
      aQuote.Sales.Last.Price,
      aQuote.Sales.Last.Volume
      ]);
    if bF then
      stLog := stDummy+','+stLog+',0,0'
    else
      stLog := '0,0,'+stLog+','+stDummy;
  end
  else
    stLog := '0,0,'+stLog+',0,0';

  stLog := FormatDateTime('[hh:nn:ss.zzz],' , GetQuoteTime) + stLog;

  LogData( aLog, stLog );

end;


function TStkFutures.FindLog( aSymbol : TSymbol ) : TStkfItem;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Logs.Count - 1 do
    if TStkfItem( Logs.Items[i]).Symbol = aSymbol then
    begin
      Result :=  TStkfItem( Logs.Items[i]);
      break;
    end;

end;

procedure TStkFutures.LogData( aLog : TStkfItem ; stLog : string);
begin

  aLog.ExcelLog.LogData( stLog, aLog.Index );
  inc( aLog.Index );
end;


{ TStkFItem }

constructor TStkFItem.Create(aColl: TCollection);
begin
  inherited;
  ExcelLog  := TExcelLog.Create;
  Symbol    := nil;
  Underlying:= nil;
  Index     := 0;
  LastData  := '';
end;

destructor TStkFItem.Destroy;
begin
  ExcelLog.Free;
  inherited;
end;

initialization
  RegisterClass( TStkFutures );

Finalization
  UnRegisterClass( TStkFutures )

end.
