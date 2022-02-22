unit FTodarke;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Grids,

  CleStrategyStore, GleTypes, CleQuoteTimers, CleOrders, GleConsts,
  CleAccounts, CleSymbols, CleQuoteBroker, CleDistributor,

  CleOrderConsts, CleTodarkeSystem
  ;

type             

  TFrmTodarke = class(TForm)
    plbg: TPanel;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    btnSymbol: TButton;
    btnClear: TButton;
    stBar: TStatusBar;
    GroupBox1: TGroupBox;
    edt1th: TEdit;
    edt2th: TEdit;
    edt3th: TEdit;
    Label2: TLabel;
    Label6: TLabel;
    dpstartTime1: TDateTimePicker;
    dpEndTime1: TDateTimePicker;
    Label7: TLabel;
    edtEntrySec: TEdit;
    Label8: TLabel;
    edtLiqSec: TEdit;
    Label9: TLabel;
    edtLossTick1: TEdit;
    UpDown1: TUpDown;
    UpDown3: TUpDown;
    UpDown4: TUpDown;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label1: TLabel;
    edtQty: TEdit;
    UpDown2: TUpDown;
    cbwithOpt: TCheckBox;
    edtMin: TEdit;
    edtMax: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    cbL1th: TCheckBox;
    cbL2th: TCheckBox;
    cbL3th: TCheckBox;
    cbS1th: TCheckBox;
    cbS2th: TCheckBox;
    cbS3th: TCheckBox;
    Panel1: TPanel;
    sgResult: TStringGrid;
    cbIncQty: TCheckBox;
    edtMaxOrder: TEdit;
    Label23: TLabel;
    UpDown9: TUpDown;
    procedure cbStartClick(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbL1thClick(Sender: TObject);
    procedure cbS1thClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure stBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure edtQtyChange(Sender: TObject);
    procedure cbIncQtyClick(Sender: TObject);
    procedure edtLiqSecChange(Sender: TObject);
    procedure edtMaxOrderChange(Sender: TObject);
    procedure edtLossTick1Change(Sender: TObject);
  private
    { Private declarations }
    FAccount  : TAccount;
    FTodarke  : TTodarkeSystem;
    FMin, FMax: double;
    FTimer    : TQuoteTimer;
    procedure GetParam;
  public
    { Public declarations }
    tParam : TTodarkeParam;
    lColor, sColor, cColor : TColor;
    procedure OnLogEvent( Values : TStrings; index : integer ) ;
    procedure OnTimerEvent( Sender : TObject );
  end;

var
  FrmTodarke: TFrmTodarke;

implementation

uses
  GAppEnv, GleLib  ;

{$R *.dfm}

procedure TFrmTodarke.GetParam;
begin
  with tParam do
  begin
    Qty := StrToIntDef( edtQty.Text, 1 );
    LossCutTick1  := StrToIntdef( edtLossTick1.Text, 2 );
    StartTime1     := dpStartTime1.DateTime;
    EndTime1 := dpEndTime1.DateTime;
    EntrySec  := StrToInt( edtEntrySec.Text );
    LiqSec    := StrToInt( edtLiqSec.Text );
    MaxOrderCnt := StrToInt(edtMaxORder.Text );

    Condition[0] := StrToFloat( edt1th.Text );
    Condition[1]  := StrToFloat( edt2th.Text );
    Condition[2]  := StrToFloat( edt3th.Text );

    LongCondition[0]  := cbL1th.Checked;
    LongCondition[1]  := cbL2th.Checked;
    LongCondition[2]  := cbL3th.Checked;

    ShortCondition[0]  := cbS1th.Checked;
    ShortCondition[1]  := cbS2th.Checked;
    ShortCondition[2]  := cbS3th.Checked;


    UseIncQty := cbIncQty.Checked;

    WithOpt := cbWithOpt.Checked;
  end;
end;


procedure TFrmTodarke.OnLogEvent( Values : TStrings; index : integer ) ;
var
  i: Integer;
begin
  //
  InsertLine( sgResult, 1 );
  sgResult.Cells[0, 1] := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime );
  for i := 0 to index - 1 do
  begin
    if (Values[i] = 'L') and ( lColor <> clRed) then
    begin
      lColor := clRed;
      stBar.Repaint;
    end;

    if (Values[i] = 'S') and ( sColor <> clBlue) then
    begin
      sColor := clBlue;
      stBar.Repaint;
    end;

    sgResult.Cells[i+1, 1] := Values[i];
  end;
end;


procedure TFrmTodarke.OnTimerEvent(Sender: TObject);
var
  i : integer;
  aQuote : TQuote;
  stTmp : string;
  aCb : TCheckBox;
  iDiv, iPrec : array [0..2] of integer;
  pColor : array [0..5] of TColor;
  aColor : TColor;
begin

  with tParam do
  begin

  Condition[0] := StrToFloatDef( edt1th.Text , 0.7);
  Condition[1]  := StrToFloatDef( edt2th.Text, 0.65 );
  Condition[2]  := StrToFloatDef( edt3th.Text, 0.6 );

  aQuote  := gEnv.Engine.SymbolCore.Future.Quote as TQuote;

  if aQuote.Bids.CntTotal > aQuote.Asks.CntTotal then
    aColor := clRed
  else
    aColor := clBlue;

  iDiv[0]  := 255 - ( aColor and $FF );
  iDiv[1]  := 255 - ( (aColor and $FF00)shr 8 );
  iDiv[2]  := 255 - ( (aColor and $FF0000)shr 16 );

  iPrec[0]  := iDiv[0] div 5;
  iPrec[1]  := iDiv[1] div 5;
  iPrec[2]  := iDiv[2] div 5;

  // 선물 그라데이션
  for i := 0 to 5 - 1 do
    pColor[i]  :=  RGB(  255 - ( i*iPrec[0] ),
        255 - ( i * iPrec[1] ),
        255 - ( i * iPrec[2] ));

  for I := 0 to 3 - 1 do
  begin
    if aQuote.Bids.CntTotal > aQuote.Asks.CntTotal then
    begin
      case i of
        0 : aCB := cbL1th;
        1 : aCB := cbL2th;
        2 : aCB := cbL3th;
      end;
      if aQuote.Bids.CntTotal * Condition[i] > aQuote.Asks.CntTotal then
        aCB.Color := pColor[i+1]
      else
        aCB.Color := clbtnFace;
    end
    else begin
      case i of
        0 : aCB := cbS1th;
        1 : aCB := cbS2th;
        2 : aCB := cbS3th;
      end;
      if aQuote.Asks.CntTotal * Condition[i] > aQuote.Bids.CntTotal then
        aCB.Color := pColor[i+1]
      else
        aCB.Color := clbtnFace;
    end;
  end;
  end;

  if FTodarke = nil then Exit;

  if ( FTodarke.MainItem.FirstCon.OccurCross ) and ( cColor <> clLime ) then
  begin
    cColor := clLime;
    stBar.Repaint;
  end;

  stBar.Panels[3].Text  := Format('교차 : %s  AskC(%.*n) | BidC(%.*n)', [
    ifThenStr( FTodarke.MainItem.FirstCon.Move1p, 'On', 'Of' ),
    0, aQuote.Asks.CntTotal+0.1, 0, aQuote.Bids.CntTotal+0.1]);

end;

procedure TFrmTodarke.stBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  case Panel.Index of
    0 : StatusBar.Canvas.Brush.Color := sColor;
    1 : StatusBar.Canvas.Brush.Color := lColor;
    2 : StatusBar.Canvas.Brush.Color := cColor;
  end;
  StatusBar.Canvas.FillRect( Rect );
end;

procedure TFrmTodarke.cbIncQtyClick(Sender: TObject);
begin
  with  TCheckBox( Sender ) do
    FTodarke.Todarkes.SetIncQty(  Checked );
end;

procedure TFrmTodarke.cbL1thClick(Sender: TObject);
var
  i, iTag : integer;
  bCheck : boolean;
begin
  with  TCheckBox( Sender ) do
    for I := 0 to FTodarke.Todarkes.Count - 1 do
      FTodarke.Todarkes.TodarkeSymbol[i].SetCondition( 1, Tag, Checked );
end;

procedure TFrmTodarke.cbS1thClick(Sender: TObject);
var
  i, iTag : integer;
  bCheck : boolean;
begin
  with  TCheckBox( Sender ) do
    for I := 0 to FTodarke.Todarkes.Count - 1 do
      FTodarke.Todarkes.TodarkeSymbol[i].SetCondition( -1, Tag, Checked );
end;

procedure TFrmTodarke.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then begin
    plbg.Color  := clYellow;
    GetParam;
    FTodarke.start( tParam );
  end
  else begin
    plbg.Color  := clBtnFace;
    FTodarke.stop;
  end;

  FMin  := StrToFloat( edtMin.Text );
  FMax  := StrToFloat( edtMax.Text );
end;

procedure TFrmTodarke.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
  FTodarke.SetAccount( FAccount);

end;

procedure TFrmTodarke.edtLiqSecChange(Sender: TObject);
var
  iQty, i : integer;
begin
  iQty := UpDown1.Position;
  if (iQty > 1) and ( iQty < 5) then
    for i:= 0 to FTodarke.Todarkes.Count-1 do
      FTodarke.Todarkes.SetLiquidSec(iQty);
end;

procedure TFrmTodarke.edtLossTick1Change(Sender: TObject);
var
  iQty, i : integer;
begin
  iQty := UpDown4.Position;
  if (iQty > 0) and ( iQty < 5) then
    for i:= 0 to FTodarke.Todarkes.Count-1 do
      FTodarke.Todarkes.SetMaxCount( iQty );

end;

procedure TFrmTodarke.edtMaxOrderChange(Sender: TObject);
var
  iQty, i : integer;
begin
  iQty := UpDown9.Position;
  if (iQty > 0) and ( iQty < 5) then
    for i:= 0 to FTodarke.Todarkes.Count-1 do
      FTodarke.Todarkes.SetMaxCount( iQty );
end;

procedure TFrmTodarke.edtQtyChange(Sender: TObject);
var
  iQty, i : integer;
begin
  iQty := UpDown2.Position;
  if (iQty > 0) and ( iQty < 5) then
    for i:= 0 to FTodarke.Todarkes.Count-1 do
      FTodarke.Todarkes.SetQty( iQty );
end;

procedure TFrmTodarke.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmTodarke.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  FTodarke := TTodarkeSystem.Create( aColl, opTodarke );

  //FTodarke.OnResult := OnDisplay;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

  FTodarke.init;
  FTodarke.OnLogEvent  := OnLogEvent;

  sgResult.Cells[0,0] := '시각';
  sgResult.Cells[1,0] := 'LS';
  sgResult.Cells[2,0] := '조건';
  sgResult.Cells[3,0] := '구분';
  sgResult.Cells[4,0] := '내용';

  FTimer    := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Interval := 500;
  FTimer.OnTimer  := OnTimerEvent;
  FTimer.Enabled  := true;

  lColor := clBtnFace;
  sColor := clBtnFace;
  cColor := clBtnFace;
end;


procedure TFrmTodarke.FormDestroy(Sender: TObject);
begin
  if FTimer <> nil then
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  FTodarke.stop;
  FTodarke.Free;
end;

end.
