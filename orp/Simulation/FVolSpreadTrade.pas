unit FVolSpreadTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,

  CleOrders, ClePositions, CleStrategyStore, CleQuoteTimers,

  CleVSpreadTrade, StdCtrls, ComCtrls, Grids, ExtCtrls
  ;

type
  TFrmVolSpread = class(TForm)
    Panel1: TPanel;
    sgSymbols: TStringGrid;
    sgResult: TStringGrid;
    ComboAccount: TComboBox;
    cbRun: TCheckBox;
    stBar: TStatusBar;
    Button1: TButton;
    Button2: TButton;
    edtStdQty: TEdit;
    Button3: TButton;
    Button4: TButton;
    edtLow: TEdit;
    edtHigh: TEdit;
    edtHedge: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    FAccount  : TAccount;
    FVolSpt   : TVolSpreadTrade;
    FParam    : TVolSpreadParam;

    procedure InitGrid;
    procedure ClearGrid;
    procedure OnDisplay(const S: string);
    procedure OnCalced(Sender: TObject; Value : boolean );
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  public
    { Public declarations }
  end;

var
  FrmVolSpread: TFrmVolSpread;

implementation

uses
  GAppEnv , GleLib
  ;

{$R *.dfm}

procedure TFrmVolSpread.Button1Click(Sender: TObject);
begin
  //
  FVolSpt.DoAllLiquid;
end;

procedure TFrmVolSpread.Button3Click(Sender: TObject);
begin
  FVolSpt.DoLongHedge;
end;

procedure TFrmVolSpread.Button4Click(Sender: TObject);
begin
  FVolSpt.DoLongHedgeLiquid;
end;

procedure TFrmVolSpread.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
  begin
    FParam.StandardQty  := StrToIntDef( edtStdQty.Text, 1 );
    FParam.High         := StrToFloat( edtHigh.Text );
    FParam.Low          := StrToFloat( edtLow.Text );
    if not FVolSpt.start( FParam  ) then
      cbRun.Checked := false;
  end
  else
    FVolSpt.stop;
end;

procedure TFrmVolSpread.ClearGrid;
var
  I: Integer;
begin
  for I := 0 to sgSymbols.RowCount - 1 do
    sgSymbols.Rows[i].Clear;
end;

procedure TFrmVolSpread.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;

  FVolSpt.SetAccount(FAccount);

end;

procedure TFrmVolSpread.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmVolSpread.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  FVolSpt   := TVolSpreadTrade.Create( aColl, opVolSpread );
  FVolSpt.OnLog     := OnDisplay;
  FVolSpt.OnResult  := OnCalced;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

  if FVolSpt.vKospi <> nil then
    gEnv.Engine.QuoteBroker.Subscribe( Self, FVolSpt.vKospi, QuotePrc );

end;

procedure TFrmVolSpread.FormDestroy(Sender: TObject);
begin
  //
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;

procedure TFrmVolSpread.InitGrid;
begin

end;

procedure TFrmVolSpread.OnCalced(Sender: TObject; Value: boolean);
var
  aDel : TDeltaNeutralSymbol;
  I, iCol, iRow: Integer;
  dPrice : double;
  aQuote  : TQuote;
  d1, d2 : double;
begin
  if not Value then Exit;

  ClearGrid;

  with FVolSpt do
  begin

  sgSymbols.RowCount  :=  LongSymbols.Count + ShortSymbols.Count;

  iRow := 0;
                {
  for I := 0 to LongSymbols.Count - 1 do
  begin
    aDel  := LongSymbols.Items[i] as TDeltaNeutralSymbol;

    iCol := 0 ;
    sgSymbols.Cells[iCol, iRow] := ifthenStr( aDel.side > 0, 'L', 'S');  inc( iCol);

    sgSymbols.Cells[iCol, iRow] := aDel.Call.ShortCode;                  inc( iCol);
    sgSymbols.Cells[iCol, iRow] := aDel.Put.ShortCode;                    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Call.Last ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Put.Last ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.callQty ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.putQty ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta ] );   inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Put.Delta ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta*aDel.callQty + aDel.Put.Delta* aDel.putQty ] );

    inc( iRow);

  end;   }

  for I := 0 to ShortSymbols.Count - 1 do
  begin
    aDel  := ShortSymbols.Items[i] as TDeltaNeutralSymbol;
    iCol := 0 ;
    sgSymbols.Cells[iCol, iRow] := ifthenStr( aDel.side > 0, 'L', 'S');  inc( iCol);

    sgSymbols.Cells[iCol, iRow] := aDel.Call.ShortCode;                  inc( iCol);
    sgSymbols.Cells[iCol, iRow] := aDel.Put.ShortCode;                    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Call.Last ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Put.Last ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.callQty ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.putQty ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta ] );   inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Put.Delta ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta*aDel.callQty + aDel.Put.Delta* aDel.putQty ] );

    inc( iRow);


  end;
  end;

end;

procedure TFrmVolSpread.OnDisplay(const S: string);
begin
  InsertLine( sgResult, 1 );
  sgResult.Cells[1,1] := s;
end;

procedure TFrmVolSpread.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if DataObj <> nil then  
    FVolspt.QuoteProc( DataObj as TQuote, 0);
end;

initialization
  RegisterClass( TFrmVolSpread );

Finalization
  UnRegisterClass( TFrmVolSpread )
end.