unit DleMonitoring;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,

  CleSymbols, CleQuoteBroker, CleMarkets,  CleInvestorData,

  GleTypes
  ;


const
  clopp = $EFEFEF;
type
  TMonitoring = class(TForm)
    GroupBox1: TGroupBox;
    lbTitle: TLabel;
    sgFut: TStringGrid;
    Timer1: TTimer;
    lbTime: TLabel;
    CheckBox1: TCheckBox;
    edtAbove: TEdit;
    edtBelow: TEdit;
    Label1: TLabel;
    sgCall: TStringGrid;
    sgPut: TStringGrid;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure sgFutDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
    FSymbol : TSymbol;
    FIndex  : integer;

    procedure UpdateQuote;
    procedure UpdateData;
  public
    { Public declarations }
    ForeignerFut : TInvestorData ;
    procedure init;
    procedure initControls;
    procedure WmQuoteUpdate(var msg: TMessage); message WM_QUOTEUPDATE;

  end;

var
  Monitoring: TMonitoring;

implementation

uses
  GAppEnv, CleQuoteTimers, GleConsts
  ;

{$R *.dfm}


procedure TMonitoring.Button1Click(Sender: TObject);
begin
  gEnv.MakeOpt1Min.Below  := StrToFloatDef( edtBelow.Text, 2.0 );
  gEnv.MakeOpt1Min.Above  := StrToFloatDef( edtAbove.Text, 0.2 );
end;

procedure TMonitoring.CheckBox1Click(Sender: TObject);
begin
  gEnv.MakeOpt1Min.Use  := CheckBox1.Checked;
end;

procedure TMonitoring.FormCreate(Sender: TObject);
begin
  initControls;
  init;

  FIndex := -1;
  gEnv.Monitor  := self;
end;

procedure TMonitoring.FormDestroy(Sender: TObject);
begin
  //if FSymbol <> nil then
  //  gEnv.Engine.QuoteBroker.Cancel( self );
  gEnv.Monitor  := nil;
end;

procedure TMonitoring.init;
var
  FutMarket :  TFutureMarket;
begin
  FutMarket := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];
  FSymbol   := FutMarket.FrontMonth;

  ForeignerFut  := nil;

  CheckBox1.Checked := gEnv.MakeOpt1Min.Use;
  edtBelow.Text     := Format('%.2f', [ gEnv.MakeOpt1Min.Below ] );
  edtAbove.Text     := Format('%.2f', [ gEnv.MakeOpt1Min.Above ] );
end;

procedure TMonitoring.initControls;
var
  i : integer;
begin
  with sgFut do
  begin
    Cells[ 1, 0] := '총잔량';
    Cells[ 2, 0] := '총건수';
    Cells[ 3, 0] := '외국선물';
    Cells[ 4, 0] := '최대/소';

    Cells[ 0, 1] := '매도';
    Cells[ 0, 2] := '매수';
    Cells[ 0, 3] := 'Net';
  end;

end;

procedure TMonitoring.UpdateData;
var
  aQuote : TQuote;
  iAskVol, iAskCnt, iBidVol, iBidCnt, i : integer;
  aSymbol : TSymbol;
 //     dTmp : array [0..2] of double;
 // i: integer;
begin

  if ForeignerFut = nil then
    ForeignerFut := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_FORIN, 'F');

  aQuote  := FSymbol.Quote as TQuote;

  if aQuote.Symbol <> FSymbol then Exit;

  iAskVol  := aQuote.Asks.VolumeTotal;
  iAskCnt  := aQuote.Asks.CntTotal;

  iBidVol  := aQuote.Bids.VolumeTotal;
  iBidCnt  := aQuote.Bids.CntTotal;
{
  dTmp[0] := 0.7;
  dTmp[1] := 0.65;
  dTmp[2] := 0.6;
 }
  with sgFut do
  begin


    Cells[ 1,1] := IntToStr( iAskVol );
    Cells[ 1,2] := IntToStr( iBidVol );
    Cells[ 1,3] := IntToStr( iBidVol - iAskVol );

    Cells[ 2,1] := IntToStr( iAskCnt );
    Cells[ 2,2] := IntToStr( iBidCnt );
    Cells[ 2,3] := IntToStr( iBidCnt - iAskCnt );

    if ForeignerFut <> nil then
    begin
      Cells[ 3,1] := IntToStr( ForeignerFut.AskQty );
      Cells[ 3,2] := IntToStr( ForeignerFut.BidQty );
      Cells[ 3,3] := IntToStr( ForeignerFut.BidQty - ForeignerFut.AskQty );

      Cells[ 4,1] := IntToStr( ForeignerFut.MaxSumQty );
      Cells[ 4,2] := IntToStr( ForeignerFut.MinSumQty );
    end;
{
    for i := 0 to 3 - 1 do
    begin
      Cells[ i+2,1] := Format('%.1f', [ iAskCnt*dTmp[i] -iBidCnt  ] );
      Cells[ i+2,2] := Format('%.1f', [ iBidCnt*dTmp[i]- iAskCnt  ] );
      Cells[ i+2,3] := Format('%.1f', [ (iBidCnt - iAskCnt*dTmp[i]) - (iAskCnt - iBidCnt*dTmp[i]) ] );
    end;
 }
    lbTime.Caption := FormatDateTime( 'hh:nn:ss', GetQuoteTime );
  end;

  if gEnv.Engine.SymbolCore.Calls.Count > 0 then
  begin
  //  sgCall.RowCount := gEnv.Engine.SymbolCore.Calls.Count;

    for I := 0 to gEnv.Engine.SymbolCore.Calls.Count - 1 do
    begin
      aSymbol := gEnv.Engine.SymbolCore.Calls.Symbols[i];
      sgCall.Cells[0,i] := aSymbol.ShortCode;
      sgCall.Cells[1,i] := Format('%.2f->%.2f', [ aSymbol.DayOpen, aSymbol.Last ]);
    end;
  end;


  if gEnv.Engine.SymbolCore.Puts.Count > 0 then
  begin
  //  sgPut.RowCount := gEnv.Engine.SymbolCore.Puts.Count;

    for I := 0 to gEnv.Engine.SymbolCore.Puts.Count - 1 do
    begin
      aSymbol := gEnv.Engine.SymbolCore.Puts.Symbols[i];
      sgPut.Cells[0,i] := aSymbol.ShortCode;
      sgPut.Cells[1,i] := Format('%.2f->%.2f', [ aSymbol.DayOpen, aSymbol.Last ]);
    end;
  end;

end;

procedure TMonitoring.sgFutDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aFont, aBack : TColor;
    stTxt : string;
    dFormat : Word;
    rRect : TRect;
    bFormat : boolean;

  function GetColor : TColor;
  var
    iVal  : double;
  begin
    iVal  := StrToFloatDef( sgFut.Cells[ACol, ARow] , 0 );
    if iVal > 0 then
      Result := clRed
    else if iVal < 0 then
      Result := clBlue
    else
      Result := clBlack;
  end;
begin

  bFormat := false;
  dFormat := DT_CENTER or DT_VCENTER;
  aFont := clBlack;
  aBack := clWhite;
  rRect := Rect;

  with sgFut do
  begin
    stTxt := Cells[ ACol, ARow ];

    if ( ARow = 0 ) or ( ACol = 0 ) then
      aBack := clBtnFace
    else begin
      bFormat := true;
      dFormat := DT_RIGHT or DT_VCENTER;
      aBack := clWhite;
      if ARow = 1 then
        aFont := clBlue
      else if ARow = 2 then
        aFont := clRed
      else if ARow = 3 then
        aFont := GetColor;

      if ( ACol = 4 )  then
      begin
        if ARow = 1 then
          aFont := clRed;
        if aRow = 2 then
          aFont := clBlue;
      end;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect );

    if (bFormat) and ( stTxt <> '') then
      stTxt := Format( '%.*n', [0,StrToFloat( stTxt )]);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );

  end;

end;


procedure TMonitoring.Timer1Timer(Sender: TObject);
begin
  //UpdateData;
end;

procedure TMonitoring.UpdateQuote;
begin
  UpdateData;

end;

procedure TMonitoring.WmQuoteUpdate(var msg: TMessage);
begin
  UpdateQuote;
end;

end.
