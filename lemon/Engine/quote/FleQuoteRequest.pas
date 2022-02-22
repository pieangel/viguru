unit FleQuoteRequest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids,
  CleQuoteBroker,CleFQN, StdCtrls, Buttons, CleSymbols
  ;

const
  QUOTE_COUNT = 6;
  QUOTE_TITLE : array [0..QUOTE_COUNT-1] of string = (
                'No', '종목명', '종목코드','체결','호가', '민감도');
  QUOTE_WIDTH : array [0..QUOTE_COUNT-1] of integer = ( 30, 125, 65, 50, 50, 50 );

type
  TfrmQuote = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    sgData: TStringGrid;
    btnRe: TBitBtn;
    refreshTimer: TTimer;
    btnUpdate: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnReClick(Sender: TObject);
    procedure refreshTimerTimer(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure sgDataDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  private
    { Private declarations }
    FQuoteBroker: TQuoteBroker; // assigned
  public
    { Public declarations }
    FLast : Boolean;
    procedure DrawQuote();
  end;

var
  frmQuote: TfrmQuote;

implementation

uses
  GAppEnv;
{$R *.dfm}

procedure TfrmQuote.FormCreate(Sender: TObject);
var
  i : integer;
begin
  FQuoteBroker := gEnv.Engine.QuoteBroker;
  for i := 0 to QUOTE_COUNT - 1 do
  begin
    sgData.Cells[ i, 0 ] := QUOTE_TITLE[i];
    sgData.ColWidths[i] :=  QUOTE_WIDTH[i];
  end;
  FLast := false;
  DrawQuote;
end;

procedure TfrmQuote.refreshTimerTimer(Sender: TObject);
var
  iCol : integer;
begin
  FLast := false;
  DrawQuote;
  if FLast then
    btnReClick(self)
  else
  begin
    sgData.RowCount := 2;
    iCol := 0;
    sgData.Cells[iCol , 1] := '' ;  inc(iCol);
    sgData.Cells[iCol , 1] := '' ;  inc(iCol);
    sgData.Cells[iCol , 1] := '' ;  inc(iCol);
    sgData.Cells[iCol , 1] := '' ;  inc(iCol);
    sgData.Cells[iCol , 1] := '' ;  inc(iCol);
    sgData.Cells[iCol , 1] := '' ;
    refreshTimer.Enabled := false;
  end;
end;

procedure TfrmQuote.sgDataDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  strData : string;
  rRect : TRect;
  dtFormat : Word;
begin
  strData := sgData.Cells[ACol, ARow];
  dtFormat := DT_CENTER or DT_VCENTER;
  rRect := Rect;

  sgData.Canvas.FillRect(Rect);
  rRect.Top := rRect.Top + 5;
  DrawText( sgData.Canvas.Handle,  PChar( strData ), Length( strData ), rRect, dtFormat );
end;

procedure TfrmQuote.btnReClick(Sender: TObject);
var
  i : integer;
  aSymbol : TSymbol;
begin
  for i := 1 to sgData.RowCount -1 do
  begin
    aSymbol := TSymbol(sgData.Objects[0, i]);
    if aSymbol = nil then continue;

    if aSymbol.Spec.Market = mtStock then
      gEnv.Engine.QuoteBroker.ReSubscribe(self,aSymbol,gEnv.Engine.QuoteBroker.DummyEventHandler)
    else
      gEnv.Engine.QuoteBroker.ReSubscribeElw(self,aSymbol,gEnv.Engine.QuoteBroker.DummyEventHandler);
    Application.ProcessMessages;
  end;
  refreshTimer.Enabled := true;
end;

procedure TfrmQuote.btnUpdateClick(Sender: TObject);
var
  i : integer;
begin
  for i := 1 to sgData.RowCount - 1 do
    sgData.Rows[i].Clear;
  sgData.RowCount := 1;
  DrawQuote;
end;

procedure TfrmQuote.DrawQuote;
var
  iCol, iRow, i : integer;
  aQuote : TQuote;
  stBool : string;
begin
  iRow := 1;
  for i := 0 to FQuoteBroker.Count - 1 do
  begin
    iCol := 0;
    aQuote := TQuote(FQuoteBroker.Items[i]);
     //mtStock, mtBond, mtETF, mtFutures, mtOption, mtELW
    if aQuote.Symbol.ShortCode = '' then exit;
    if (aQuote.FillSubscribed) and (aQuote.HogaSubscribed) then continue;
    if aQuote.Symbol.Spec.Market = mtELW then
      if (aQuote.FillSubscribed) and (aQuote.GreeksSubscribed) and (aQuote.HogaSubscribed) then continue;

    sgData.RowCount := iRow + 1;
    sgData.Cells[ iCol, iRow] := IntToStr(iRow);             inc(iCol);   //종목명
    sgData.Cells[ iCol, iRow] := aQuote.Symbol.Name;         inc(iCol);   //종목명
    sgData.Cells[ iCol, iRow] := aQuote.Symbol.ShortCode;    inc(iCol);   //종목코드
    if aQuote.FillSubscribed then stBool := '성공'
    else stBool := '실패';
    sgData.Cells[ iCol, iRow] := stBool;    inc(iCol);                    //체결
    if aQuote.HogaSubscribed then stBool := '성공'
    else stBool := '실패';
    sgData.Cells[ iCol, iRow] := stBool;    inc(iCol);                    //호가
    if aQuote.Symbol.Spec.Market = mtELW then
    begin
      if aQuote.GreeksSubscribed then stBool := '성공'
      else stBool := '실패';
      sgData.Cells[ iCol, iRow] := stBool;                                //민감도
    end;
    sgData.Objects[0,iRow] := aQuote.Symbol;
    inc(iRow);
    FLast := true;
  end;
end;

end.
