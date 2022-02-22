unit FBullSignal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSymbols, CleQuoteBroker, CleQuoteTimers, CleMarkets, CleFQN,

  BullSystem, BullData, BullTrade,

  GleTypes, GleConsts, GleLib, ExtCtrls, Grids
  ;

const
  SubjectCount = 11;
  Subjects : array [0..SubjectCount-1] of string =
    (
      '델타','내재변동성','괴리','적정가','평균가',
      '행사가','평균가', '적정가', '괴리', '내재변동성', '델타'
    );

  GridWidths : array [0..SubjectCount-1] of integer =
    (
      50, 50, 50, 50, 50,
      60,50, 50, 50, 50, 50
    );

  CalIdx  = 4;
  PutIdx  = 6;

type
  TFrmBullSignal = class(TForm)
    sgBull: TStringGrid;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FCallTrade  : array of TBullTrade;
    FPutTrade  : array of TBullTrade;
    FFuture: TSymbol;
    procedure initControls;
    function initObjects : integer;
    { Private declarations }
  public
    { Public declarations }

    FConfig : TBullConfig;
    procedure TradeSignalChanged(Sender: TObject);

    property Future : TSymbol read FFuture write FFuture;
  end;

var
  FrmBullSignal: TFrmBullSignal;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TFrmBullSignal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := true;
  ACtion := caFree;
end;

procedure TFrmBullSignal.FormCreate(Sender: TObject);
begin
  //
  initControls;

  initObjects;



  {
  FCallTrade := TBullTrade.Create;
  FCallTrade.OnSignalNotify := TradeSignalChanged;
  }
end;

procedure TFrmBullSignal.FormDestroy(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to sizeof(FCallTrade) do
  begin
    FCallTrade[i].OnSignalNotify  := nil;
    FCallTrade[i].Free;
  end;

  for i := 0 to sizeof(FPutTrade) do
  begin
    FPutTrade[i].OnSignalNotify  := nil;
    FPutTrade[i].Free;
  end;
end;


procedure TFrmBullSignal.initControls;
var
  i :Integer;
begin
  with sgBull do
  begin
    ColCount := SubjectCount;

    for i := 0 to SubjectCount - 1 do
    begin
      Cells[i,0]    := Subjects[i];
      ColWidths[i]  := GridWidths[i];
    end;
  end;

  with FConfig do
  begin
    E1_Checked  := true;
    E1_P1 := 0.6;
    E1_P2 := 0.5;
    E1_P3 := 2.0;
    E1_P4 := 0.3;
    E1_P5 := 0.3;
    E1_P6 := 0.9
  end;


end;

function TFrmBullSignal.initObjects : integer;
var
  aFuture : TFuture;
  aMarket : TFutureMarket;
  aMarkets : TMarketTypes;
  aOptMarket  : TOptionMarket;
  aStrike : TStrike;
  i : integer;
begin
  aMarket := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];
  aFuture := aMarket.FrontMonth;
  FFuture := aFuture;

  aOptMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  sgBull.RowCount := aOptMarket.Trees.FrontMonth.Strikes.Count + 1;
  SetLength( FCallTrade, aOptMarket.Trees.FrontMonth.Strikes.Count );
  SetLength( FPutTrade, aOptMarket.Trees.FrontMonth.Strikes.Count );

  for i := 0 to aOptMarket.Trees.FrontMonth.Strikes.Count-1 do
  begin
    aStrike := aOptMarket.Trees.FrontMonth.Strikes.Strikes[i];
    sgBull.Cells[5, i+1]  := Format('%.2f', [aStrike.StrikePrice]);
    sgBull.Objects[CalIdx, i+1]  := aStrike.Call;
    FCallTrade[i] := TBullTrade.Create;
    FCallTrade[i].OnSignalNotify := TradeSignalChanged;
    FCAllTrade[i].Account := gEnv.Engine.TradeCore.Accounts.Accounts[0];
    FCallTrade[i].Option  := aStrike.Call;
    FCallTrade[i].Config  := FConfig;

    sgBull.Objects[PutIdx, i+1]  := aStrike.Put;
    FPutTrade[i] := TBullTrade.Create;
    FPutTrade[i].OnSignalNotify := TradeSignalChanged;
    FPutTrade[i].Account := gEnv.Engine.TradeCore.Accounts.Accounts[0];
    FPutTrade[i].Option  := aStrike.Put;
    FPutTrade[i].Config  := FConfig;

  end;

  Timer1.Enabled := true;

end;


procedure TFrmBullSignal.Timer1Timer(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to sizeof(FCallTrade) do
  begin
    FCallTrade[i].BeatProc;
    FPutTrade[i].BeatProc;
  end;

end;

procedure TFrmBullSignal.TradeSignalChanged(Sender: TObject);
var
  aSymbol : TSymbol;
  iCol, iRow : integer;
  aChange : double;
  iCols : array [0..5]  of integer;
begin

  if Sender = nil then Exit;
  aSymbol := TBullTrade( Sender ).Option;

  if (aSymbol as TOption).CallPut = 'C' then
  begin
    iCol  := CalIdx;
    iCols[0]  := 0;
    iCols[1]  := 4;
    iCols[2]  := 3;
    iCols[3]  := 2;
    iCols[4]  := 1;
    iCols[5]  := 0;
  end
  else begin
    iCol  := PutIdx;
    iCols[0]  := 0;
    iCols[1]  := PutIdx;
    iCols[2]  := PutIdx+1;
    iCols[3]  := PutIdx+2;
    iCols[4]  := PutIdx+3;
    iCols[5]  := PutIdx+4;
  end;

  iRow := sgBull.Cols[iCol].IndexOfObject( aSymbol );

  if iRow < 1 then Exit;

 with sgBull, TBullTrade( Sender ).BullResult do
  begin
    Cells[iCols[1],iRow] := Format('%.3f', [OptionAvgPrices[Last]]);
    Cells[iCols[2],iRow] := Format('%.3f', [OptionFitPrices[Last]]);
    Cells[iCols[3],iRow] := Format('%.3f', [OptionSeparation]);
    Cells[iCols[4],iRow] := Format('%.1f%%', [RealIV*100.0]);
    Cells[iCols[5],iRow] := Format('%.1f%%', [RealDelta*100.0]);
  end;

end;

end.

