unit DOrderExtractTrace;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleQuoteBroker, CleSymbols, CleTraces, CleDistributor,

  Grids, ExtCtrls, StdCtrls

  ;

const
  ColCnt = 6;
  Title : array [0..ColCnt-1] of string
    = ( '시각','종류','가격','호가','수량', '체결');

  lColor  = $0000FF;
  sColor  = $993333;
  lxColor = $CC6600;
  SxColor = $8080FF;

  DataIdx = 0;

type

  TFrmOrderExtract = class(TForm)
    Panel1: TPanel;
    sgInfo: TStringGrid;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  private

    function GetColor( aType : TOrderDivType ) : TColor;
    procedure initControls;
    procedure UpdateQuote;
    { Private declarations }
  public
    { Public declarations }
    Traces  : TTraceItems;
    Symbol  : TSymbol;
    LastData: TOrderData;
    Lines : integer;
    BWhite : boolean;
    Quote : TQuote;
    procedure AssignSymbol( aSymbol : TSymbol );

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  end;

var
  FrmOrderExtract: TFrmOrderExtract;

implementation

uses DleSymbolSelect,gAppEnv, GleLib;

{$R *.dfm}



procedure TFrmOrderExtract.AssignSymbol(aSymbol: TSymbol);
begin
  if aSymbol = nil then
    Exit;

  if Symbol = aSymbol then
    Exit;

  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( self );

  Quote := gEnv.Engine.QuoteBroker.Subscribe( Self, aSymbol, QuoteProc );

end;

procedure TFrmOrderExtract.Button1Click(Sender: TObject);
begin

  if gSymbol = nil then
  begin
    gSymbol := TSymbolDialog.Create(Self);
    gSymbol.SymbolCore  := gENv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
      AssignSymbol(gSymbol.Selected);
    end;
  finally
    gSymbol.Hide;
  end;

end;

procedure TFrmOrderExtract.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  gEnv.Engine.QuoteBroker.Cancel( self );
  Traces.Free;
  Action := caFree;
end;

procedure TFrmOrderExtract.FormCreate(Sender: TObject);
begin
  Traces  := TTraceItems.Craete;
  Symbol  := nil;
  LastData:= nil;
  Lines   := 1;
  BWhite  := false;

  initControls;
end;

function TFrmOrderExtract.GetColor(aType: TOrderDivType): TColor;
begin
  case aType of
    L: Result := lColor;
    S: Result := sColor;
    Lx: Result := lxColor;
    Sx: Result := SxColor;
    Lm: Result := clBlack;
    Sm: Result := clBlack;
    else
      Result := clBlack;
  end;
end;

procedure TFrmOrderExtract.initControls;
var
  i : integer;
begin
  sgInfo.ColCount := ColCnt;
  for i := 0 to sgInfo.ColCount-1 do
  begin
    sgInfo.Cells[i,0] := Title[i];
  end;
end;

procedure TFrmOrderExtract.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if DataObj = nil then Exit;
  if DataObj <> Quote then Exit;
  UpdateQuote;
end;

procedure TFrmOrderExtract.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    ftColor, bkColor : TColor;
    dFormat : word;
    aEx : TTraceItem;
begin

  bkColor := clWhite;
  ftColor := clBlack;
  dFormat := DT_VCENTER or DT_CENTER;

  with sgInfo do
  begin

    stTxt := Cells[ ACol, ARow ];
    case ARow  of
      0 : bkColor := clBtnFace;
      else
        begin
          aEx := TTraceItem( Objects[DataIdx, ARow]);
          if aEx = nil then Exit;

          case ACol of
            1,2,5,6 : ftColor := GetColor( aEx.OrderExtract.ODiv );
          end;

          dFormat := DT_VCENTER or DT_RIGHT;
        end;
    end;

    Canvas.Brush.Color  := bkColor;
    Canvas.Font.Color   := ftColor;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );

  end;
end;

procedure TFrmOrderExtract.UpdateQuote;
var
  aData : TOrderData;
  aTr   : TTraceItem;
  iRow, iCol  : integer;
begin

  if Quote.PriceAxis.OrderList.Count < 1 then Exit;

  aData := TOrderData(Quote.PriceAxis.OrderList.Items[0]);

  if aData = LastData then
    Exit;

  aTr := Traces.New( aData );

  iRow := 1;
  iCol := 0;

  InsertLine( sgInfo, iRow );


  with sgInfo do
  begin
    Objects[ DataIdx, iRow ] := aTr;

    Cells[ iCol, iRow] := aTr.OrderExtract.Time;
    inc( iCol );

    Cells[ iCol, iRow] := aTr.GetOrderdiv;
    inc( iCol );

    Cells[ iCol, iRow] := aTr.OrderExtract.Price;
    inc( iCol );

    Cells[ iCol, iRow] := aTr.OrderExtract.HogaLv;
    inc( iCol );

    Cells[ iCol, iRow] := IntToStr( aTr.OrderExtract.Qty );
    inc( iCol );

    Cells[ iCol, iRow] := IntToStr( aTr.OrderExtract.Volume );
    inc( iCol );

  end;

  LastData := aData;

end;

end.
