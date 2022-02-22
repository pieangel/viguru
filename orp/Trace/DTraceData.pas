unit DTraceData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, ComCtrls,

  CleTraceConst, CleAccounts, ClePositions, StdCtrls, GleLib

  ;

type
  TTraceData = class(TForm)
    pageTrace: TPageControl;
    tsOrder: TTabSheet;
    tsPL: TTabSheet;
    Panel1: TPanel;
    sgPL: TStringGrid;
    TimerPL: TTimer;
    cbAcnt: TComboBox;
    procedure TimerPLTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbAcntChange(Sender: TObject);
  private
    FPlLogCount : integer;
    FAccount    : TAccount;
    procedure UpdatePl;
    procedure initcontrols;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TraceData: TTraceData;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TTraceData.cbAcntChange(Sender: TObject);
var
  aAcnt : TAccount;
begin
  aAcnt := TAccount( GetComboObject( cbAcnt ) );

  if aAcnt = nil then Exit;

  if aAcnt = FAccount then Exit;

  FAccount := aAcnt;

  FPlLogCount := 0;

  UpdatePl;

end;

procedure TTraceData.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TTraceData.FormCreate(Sender: TObject);
begin
  FAccount := nil;
  initcontrols;
end;

procedure TTraceData.initcontrols;
var
  i : integer;
begin
  with sgPl do
    for i := 0 to ColCount - 1 do
    begin
      Cells[i,0]  := plTiltes[i];
      ColWidths[i]:= 50;
    end;

  sgPl.RowCount   := 2;
  sgPl.FixedRows  := 1;

  FPlLogCount := 0;

  gEnv.Engine.TradeCore.Accounts.GetList( cbAcnt.Items );

  if cbAcnt.Items.Count > 0 then
  begin
    cbAcnt.ItemIndex  := 0;
    cbAcntChange( nil );
  end;

end;

procedure TTraceData.TimerPLTimer(Sender: TObject);
begin
  UpdatePl;
end;

procedure TTraceData.UpdatePl;
var
  iRow, iCol, i : integer;
  aItem : TPosTraceItem;
begin
  //
  if FAccount = nil then Exit;

  if FPlLogCount >= FAccount.PosTrace.Count then Exit;

  for i := FPlLogCount to FAccount.PosTrace.Count-1 do
  begin
    aItem := FAccount.PosTrace.PosTraceItems[i];
    if aItem = nil then Continue;

    iCol := 0;  iRow := 1;

    InsertLine( sgPL, iRow );
    sgPL.Objects[ iCol, iRow ] := aItem;

    with sgPL do
    begin
      Cells[iCol, iRow] := FormatDateTime('HH:NN:SS', aItem.PositionHis.Time );
      inc( iCol );
      Cells[iCol, iRow] := Format('%.0n', [ aItem.PositionHis.TotPL ] );
      inc( iCol );
      Cells[iCol, iRow] := Format('%.0n', [ aItem.PositionHis.Fee ] );
      inc( iCol );
      Cells[iCol, iRow] := Format('%.0n', [ aItem.PositionHis.TotPL - aItem.PositionHis.Fee ] );
      inc( iCol );
      Cells[iCol, iRow] := Format('%.0n', [ aItem.PositionHis.EvalPL ] );
    end;
  end;

  FPlLogCount :=  FAccount.PosTrace.Count;

end;

end.
