unit FPrevHighLow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls  ,

  CleAccounts, CleQuoteTimers, CleOrderConsts, ClePrevHLSystem, CleQuoteBroker, CleDistributor,

  CleStrategyStore, GleTypes, Grids, ExtCtrls
  ;

type
  TFrmPrevHighLow = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    GroupBox2: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label3: TLabel;
    Label23: TLabel;
    Label1: TLabel;
    dpEndTime: TDateTimePicker;
    edtEntrySec: TEdit;
    UpDown5: TUpDown;
    UpDown6: TUpDown;
    edtLiqSec: TEdit;
    edtLossTick: TEdit;
    UpDown7: TUpDown;
    edtQty: TEdit;
    UpDown8: TUpDown;
    dpstartTime: TDateTimePicker;
    edtMaxOrder: TEdit;
    UpDown9: TUpDown;
    edtVolume: TEdit;
    UpDown1: TUpDown;
    sgResult: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure edtQtyChange(Sender: TObject);
  private
    { Private declarations }
    FAccount  : TAccount;
    FPrevHL   : TPrevHLSystem;
    FTimer    : TQuoteTimer;
    procedure GetParam;
  public
    { Public declarations }
    Param     : TPrevHLParam;
    procedure OnLogEvent( Values : TStrings; index : integer ) ;
    procedure OnTimerEvent( Sender : TObject );
  end;

var
  FrmPrevHighLow: TFrmPrevHighLow;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

procedure TFrmPrevHighLow.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then begin
    Color  := clSkyBlue;
    GetParam;
    FPrevHL.start( Param );
  end
  else begin
    Color  := clBtnFace;
    FPrevHL.stop;
  end;
end;

procedure TFrmPrevHighLow.GetParam;
begin
  with Param do
  begin
    Qty := StrToIntDef( edtQty.Text, 1 );
    LossCutTick  := StrToIntdef( edtLossTick.Text, 2 );
    StartTime     := dpStartTime.DateTime;
    EndTime := dpEndTime.DateTime;

    EntrySec  := StrToInt( edtEntrySec.Text );
    LiqSec    := StrToInt( edtLiqSec.Text );
    MaxOrderCnt := StrToInt(edtMaxORder.Text );
    Volume    := StrToInt( edtVolume.Text );
  end;

  gLog.Add(lkDebug, 'TFrmPrevHighLow','GetParam', Param.GetDesc  );
end ;

procedure TFrmPrevHighLow.OnLogEvent(Values: TStrings; index: integer);
begin
  InsertLine( sgResult, 1 );
  sgResult.Cells[0, 1] := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime );

  sgResult.Cells[1,1] := Values[0];
  sgResult.Cells[2,1] := Values[1];
end;

procedure TFrmPrevHighLow.OnTimerEvent(Sender: TObject);
begin

end;

procedure TFrmPrevHighLow.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
  FPrevHL.SetAccount( FAccount);
end;

procedure TFrmPrevHighLow.edtQtyChange(Sender: TObject);
var
  iTag , iVal, i : integer;
begin
  iTag  := ( Sender as TEdit ).Tag;
  case iTag of
    0 :  iVal := StrToIntDef( edtQty.Text, upDown8.Position )  ;
    1 :  iVal := StrToIntDef( edtLiqSec.Text,  upDown6.Position ) ;
    2 :  iVal := StrToIntDef( edtMaxORder.Text, upDown9.Position );
    3 :  iVal := StrToIntDef( edtEntrySec.Text, upDown5.Position );
    4 :  iVal := StrToIntDef( edtLossTick.Text, upDown7.Position );
    5 :  iVal := StrToIntDef( edtVolume.Text, upDown1.Position );
  end;

  for I := 0 to FPrevHL.PrevHLs.Count - 1 do
    FPrevHL.PrevHLs.SetParam( iTag, iVal );

end;

procedure TFrmPrevHighLow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmPrevHighLow.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  FPrevHL := TPrevHLSystem.Create( aColl, opPrevHL );

  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

  FPrevHL.init;
  FPrevHL.OnLogEvent  := OnLogEvent;

  FTimer    := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Interval := 500;
  FTimer.OnTimer  := OnTimerEvent;
  FTimer.Enabled  := true;
end;

procedure TFrmPrevHighLow.FormDestroy(Sender: TObject);
begin
  if FTimer <> nil then
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );

  FPrevHL.stop;
  FPrevHL.Free;
end;

end.
