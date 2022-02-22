unit FConcernSymbols;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls,

  CleSymbols, CleQuoteBroker, CleQuoteTimers, CleDistributor,

  CleStorage, CleConcernSymbolItems, StdCtrls, ExtCtrls
  ;

Const
  ItemIdx = 0;
  SymbolIdx = 1;

type
  TFrmConcernSymbols = class(TForm)
    sb: TStatusBar;
    sgSymbols: TStringGrid;
    Panel1: TPanel;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FStorage  : TStorage;
    procedure DefaultSet;
    procedure UpdateData(aItem: TConcernItem);
    procedure InsertCstCell(var aCol, aRow : integer; stData : string ; tag : integer = 0; tag2 : integer = 0 );

    procedure RefreshData(aRow: integer);
  public
    { Public declarations }
    CCSymbols : TConcernItems;
    TitleItems : array [0..TitleCount-1] of TitleItem;

    procedure init;

    function LoadEnv(aStorage: TStorage) : boolean;
    procedure SaveEnv(aStorage: TStorage);

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure AddSymbol(aSymbol: TSymbol);
  end;

var
  FrmConcernSymbols: TFrmConcernSymbols;

implementation

uses
  GleLib, GleTypes, CleFQN, GAppEnv;

{$R *.dfm}

procedure TFrmConcernSymbols.Button1Click(Sender: TObject);
var
  i : integer;
  aSymbol : TSymbol;
begin
  Exit;

  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open( true ) then
    begin
        //
      for i:=0 to gSymbol.ListSelected.Items.Count-1 do
        AddSymbol( TSymbol( gSymbol.ListSelected.Items[i].Data ))
    end;
  finally
    gSymbol.Hide;
  end;
end;



procedure TFrmConcernSymbols.DefaultSet;
var
  i : integer;
begin

  sgSymbols.ColCount  := TitleCount;
  sgSymbols.RowCount  := 2;
  sgSymbols.FixedRows := 1;

  for i := 0 to TitleCount - 1 do
  begin
    TitleItems[i].Title  := Titles[i];
    TitleItems[i].Visible:= Visibles[i];

    sgSymbols.Cells[i,0] := Titles[i];

    if not Visibles[i] then
      sgSymbols.ColWidths[i]  := -1;
  end;

end;

procedure TFrmConcernSymbols.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmConcernSymbols.FormCreate(Sender: TObject);
var
  bInit : boolean;
begin
  FStorage  := TStorage.Create;
  CCSymbols := TConcernItems.Create;
  gEnv.CSymbols := self;

  bInit := LoadEnv( FStorage );
  if bInit then
    DefaultSet;
  init;
end;

procedure TFrmConcernSymbols.FormDestroy(Sender: TObject);
begin
  gEnv.CSymbols := nil;
  gEnv.Engine.QuoteBroker.Cancel( Self );
  FStorage.New;
  SaveEnv( FStorage );
  FStorage.Free;
  CCSymbols.Free;
end;

procedure TFrmConcernSymbols.init;
var
  i : integer;
  aItem : TConcernItem;
begin
  for i := 0 to CCSymbols.Count - 1 do
  begin
    aItem := CCSymbols.ConcerItems[i];
    if aItem <> nil then
    begin
      if aItem.Symbol <> nil then begin
        gEnv.Engine.QuoteBroker.Subscribe( Self, aItem.Symbol, QuoteProc);
        Updatedata( aItem );
      end;
    end;
  end;
end;


procedure TFrmConcernSymbols.AddSymbol( aSymbol : TSymbol );
var
   aItem : TConcernItem;
begin
  if aSymbol = nil then Exit;

  if aSymbol.Spec.Market <> mtElw then Exit;

  aItem := CCSymbols.Find( aSymbol );
  if aItem = nil then
    aItem := CCSymbols.New( aSymbol )
  else
    Exit;

  UpdateData( aItem );
  gEnv.Engine.QuoteBroker.Subscribe( Self, aSymbol, QuoteProc);
  
end;

procedure TFrmConcernSymbols.UpdateData( aItem : TConcernItem );
var
  aRow  : integer;
  stTmp : string;
begin
  if aItem.Symbol = nil then
    Exit;

  aRow := 1;

  InsertLine( sgSymbols, aRow );

  with sgSymbols do
  begin
    Objects[ ItemIdx, aRow ] := aItem;
    Objects[ SymbolIdx, aRow ] := aItem.Symbol;
  end;

  RefreshData( aRow );
end;

procedure  TFrmConcernSymbols.RefreshData( aRow : integer );
var
  aCol : integer;
  aSymbol : TSymbol;
  aQuote : TQuote;
  stPrx : string;
begin
  aCol := 0;
  aSymbol := TSymbol( sgSymbols.Objects[SymbolIdx, aRow ] );
  if aSymbol = nil then Exit;
  
  InsertCstCell( aCol, aRow, Format('%s(%s)',
     [ aSymbol.Name, aSymbol.ShortCode ] ));
  // Elw  Ask 5
  aQuote  := aSymbol.Quote as TQuote;

  if aQuote = nil then Exit;

  InsertCstCell( aCol, aRow, Format('(%d)%d|%.0f',
     [ aQuote.Asks[4].LpVolume, aQuote.Asks[4].Volume, aQuote.Asks[4].Price ] ));

  InsertCstCell( aCol, aRow, Format('(%d)%d|%.0f',
     [ aQuote.Asks[3].LpVolume, aQuote.Asks[3].Volume, aQuote.Asks[3].Price ] ));

  InsertCstCell( aCol, aRow, Format('(%d)%d|%.0f',
     [ aQuote.Asks[2].LpVolume, aQuote.Asks[2].Volume, aQuote.Asks[2].Price ] ));

  InsertCstCell( aCol, aRow, Format('(%d)%d|%.0f',
     [ aQuote.Asks[1].LpVolume, aQuote.Asks[1].Volume, aQuote.Asks[1].Price ] ));

  InsertCstCell( aCol, aRow, Format('(%d)%d|%.0f',
     [ aQuote.Asks[0].LpVolume, aQuote.Asks[0].Volume, aQuote.Asks[0].Price ] ));

  // Elw Current
  InsertCstCell( aCol, aRow, Format('%.0f', [ aQuote.Last ] ));
  InsertCstCell( aCol, aRow, Format('%.2f', [
    GetWeightAvgPrice2( aQuote.Asks[0].Price, aQuote.Bids[0].Price,
    aQuote.Asks[0].Volume, aQuote.Bids[0].Volume )
    ]));

  InsertCstCell( aCol, aRow, Format('%.0f|%d(%d)',
     [ aQuote.Bids[0].Price, aQuote.Bids[0].Volume, aQuote.Bids[0].LpVolume ] ));

  InsertCstCell( aCol, aRow, Format('%.0f|%d(%d)',
     [ aQuote.Bids[1].Price, aQuote.Bids[1].Volume, aQuote.Bids[1].LpVolume ] ));

  InsertCstCell( aCol, aRow, Format('%.0f|%d(%d)',
     [ aQuote.Bids[2].Price, aQuote.Bids[2].Volume, aQuote.Bids[2].LpVolume ] ));

  InsertCstCell( aCol, aRow, Format('%.0f|%d(%d)',
     [ aQuote.Bids[3].Price, aQuote.Bids[3].Volume, aQuote.Bids[3].LpVolume ] ));

  InsertCstCell( aCol, aRow, Format('%.0f|%d(%d)',
     [ aQuote.Bids[4].Price, aQuote.Bids[4].Volume, aQuote.Bids[4].LpVolume ] ));

  // Underlying
  if (aSymbol as TElw).Underlying.Spec.Market = mtStock  then
  begin
    stPrx := '%d|%.0f';
    aQuote  :=  (aSymbol as TElw).Underlying.Quote as TQuote;
  end
  else begin
    stPrx := '%d|%.2f';
    aQuote  :=  gEnv.Engine.SymbolCore.Future.Quote as TQuote;
  end;

  // ask  5
  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Asks[4].Volume, aQuote.Asks[4].Price ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Asks[3].Volume, aQuote.Asks[3].Price ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [  aQuote.Asks[2].Volume, aQuote.Asks[2].Price ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [  aQuote.Asks[1].Volume, aQuote.Asks[1].Price ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Asks[0].Volume, aQuote.Asks[0].Price ] ));

  InsertCstCell( aCol, aRow, Format('%.2f', [ aQuote.Last ] ));
  InsertCstCell( aCol, aRow, Format('%.2f', [
    GetWeightAvgPrice2( aQuote.Asks[0].Price, aQuote.Bids[0].Price,
    aQuote.Asks[0].Volume, aQuote.Bids[0].Volume )
    ]));

  if (aSymbol as TElw).Underlying.Spec.Market = mtStock  then
    stPrx := '%.0f|%d'
  else
    stPrx := '%.2f|%d';

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Bids[0].Price , aQuote.Bids[0].Volume ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Bids[1].Price, aQuote.Bids[1].Volume  ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Bids[2].Price, aQuote.Bids[2].Volume  ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Bids[3].Price, aQuote.Bids[3].Volume  ] ));

  InsertCstCell( aCol, aRow, Format(stPrx,
     [ aQuote.Bids[4].Price, aQuote.Bids[4].Volume  ] ));

  //  Hoga Info End..........................

  aQuote  := aSymbol.Quote as TQuote;




end;

procedure  TFrmConcernSymbols.InsertCstCell( var aCol, aRow : integer; stData : string;
  tag : integer;  tag2 : integer );
begin
  with sgSymbols do
  begin
    Cells[aCol, aRow] := stData;
  end;
  inc( aCol );
end;

function TFrmConcernSymbols.LoadEnv(aStorage: TStorage) : boolean;
begin
  Exit;
  Result := aStorage.FieldByName('IsSave').AsBoolean;

  if not Result then
    Exit;

end;

procedure TFrmConcernSymbols.QuoteProc(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  var
    aSymbol : TSymbol;
    iRow : integer;
begin
  //
  if DataObj = nil then Exit;

  aSymbol := (DataObj as TQuote).Symbol;

  iRow := sgSymbols.Cols[SymbolIdx].IndexOfObject( aSymbol );

  if iRow < 0 then Exit;

  RefreshData( iRow );

end;

procedure TFrmConcernSymbols.SaveEnv(aStorage: TStorage);
begin
end;

procedure TFrmConcernSymbols.Timer1Timer(Sender: TObject);
begin
//
end;

end.
