unit FPave;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,  ExtCtrls,

  CleSymbols, CleAccounts,   CleQuoteBroker,  CleDistributor, CleStorage, CleQuoteTimers,

  UPriceAxis, UPaveConfig, Grids
  ;

type
  TFrmPave = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    Label1: TLabel;
    Panel2: TPanel;
    stTxt: TStatusBar;
    Label2: TLabel;
    edtSymbol: TEdit;
    Button1: TButton;
    cbStart: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    rgAskIdx: TRadioGroup;
    rgBidIdx: TRadioGroup;
    edtQty: TEdit;
    edtGap: TEdit;
    edtCnt: TEdit;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    sgLog: TStringGrid;
    gbCatch: TGroupBox;
    Label10: TLabel;
    edtContinue: TEdit;
    udContinue: TUpDown;
    udFillVol: TUpDown;
    edtFillVol: TEdit;
    cbUseCatch: TCheckBox;
    edtLiquidateTick: TEdit;
    edtHoldTick: TEdit;
    udHoldTick: TUpDown;
    udLiquidateTick: TUpDown;
    Label13: TLabel;
    Label14: TLabel;
    edtQVol: TEdit;
    udQVol: TUpDown;
    Label15: TLabel;
    edtSpeed: TEdit;
    udSpeed: TUpDown;
    cbAutoLiquid: TCheckBox;
    DateTimePicker: TDateTimePicker;
    Label11: TLabel;
    Label6: TLabel;
    edtProfit: TEdit;
    udProfit: TUpDown;
    Label7: TLabel;
    edtMaxNet: TEdit;
    udMaxNet: TUpDown;
    Label8: TLabel;
    edtLCNet: TEdit;
    udLCNet: TUpDown;
    edtOTE: TEdit;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure edtGapChange(Sender: TObject);
    procedure rgAskIdxClick(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure cbUseCatchClick(Sender: TObject);

  private
    { Private declarations }
    FAccount : TAccount;
    FSymbol  : TSymbol;
    FPriceAxis : TPriceAxis;
    FPaveData : TPaveData;

    //FCatch : THulftCatch;
    //FCatchData : THulftCatchData;
    FTimer   : TQuoteTimer;
    FAutoStart : boolean;
    procedure initControls;

    procedure GetParam;
    procedure OnTimer(Sender : TObject);

  public
    { Public declarations }
    procedure Stop;
    procedure Start;

    // 깔려 주문 개수 조금씩 줄어준다..( 최대 포지션 - 5 );
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure PositionNotifyEvent(Sender: TObject; Value: TObject);
    procedure OnStopEvent( Vaule : boolean);
  end;

var
  FrmPave: TFrmPave;

implementation

uses
  GAppEnv, GleLib ,GleTypes,  ClePositions
  ;

{$R *.dfm}

procedure TFrmPave.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin
        if cbStart.Checked then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.Code;
          FPriceAxis       := nil;
          //FCatch           := nil;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmPave.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin
    if cbStart.Checked then
    begin
      ShowMessage('실행중에는 계좌를 바꿀수 없음');
      Exit;
    end;
    FAccount := aAccount;
    FPriceAxis := nil;
    //FCatch := nil;
  end;
end;

procedure TFrmPave.cbStartClick(Sender: TObject);
begin
  //
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TFrmPave.cbUseCatchClick(Sender: TObject);
begin
  //if FCatch <> nil then
  //  FCatch.CatchData := FCatchData;
end;

procedure TFrmPave.edtGapChange(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TEdit ).Tag;

  with FPaveData do

  case iTag of
    0 : OrdQty  := StrToIntDef( edtQty.Text, 1 );
    1 : OrdGap  := StrToIntDef( edtGap.Text, 1 );
    2 : OrdCnt  := StrTointDef( edtCnt.Text, 3 );
    3 : Profit  := StrTointDef( edtProfit.Text, 2 );
        {
    //cacth
    8 : FCatchData.ContinueCnt := StrToIntDef (edtContinue.Text, 3);
    9 : FCatchData.SpeedPer := StrToIntDef (edtSpeed.Text, 10) / 100;
    10 : FCatchData.FillVol := StrToIntDef (edtFillVol.Text, 100);
    11 : FCatchData.QVol := StrToIntDef (edtQVol.Text, 50);
    12 : FCatchData.LiquidateTick := StrToIntDef (edtLiquidateTick.Text, 2);
    13 : FCatchData.HoldTick := StrToIntDef (edtHoldTick.Text, 3);
    else Exit;
    }
  end;

  if FPriceAxis <> nil then
    FPriceAxis.PavData := FPaveData;
 {
  if FCatch <> nil then
    FCatch.CatchData := FCatchData;
  }
end;

procedure TFrmPave.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmPave.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;

end;

procedure TFrmPave.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmPave.FormCreate(Sender: TObject);
begin
  initControls;

  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;
  FAutoStart := false;
end;

procedure TFrmPave.FormDestroy(Sender: TObject);
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  gEnv.Engine.TradeCore.PaveManasger.RemvoePave(FPriceAxis);
  //gEnv.Engine.TradeCore.PaveManasger.RemvoePave(FCatch);
  //
end;

procedure TFrmPave.SaveEnv(aStorage : TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('OrderCount').AsString := edtCnt.Text;
  aStorage.FieldByName('OrderGap').AsString := edtGap.Text;
  aStorage.FieldByName('Profit').AsString := edtProfit.Text;

  aStorage.FieldByName('MaxNet').AsString := edtMaxNet.Text;
  aStorage.FieldByName('LCNet').AsString := edtLCNet.Text;

  if FSymbol <> nil then
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code
  else
    aStorage.FieldByName('SymbolCode').AsString := '';

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

  aStorage.FieldByName('ClearTime').AsString := FormatDateTime('hhnnss', DateTimePicker.Time);
  aStorage.FieldByName('LiqOTE').AsString := edtOTE.Text;
  {
  // catch
  aStorage.FieldByName('UseCatch').AsBoolean := cbUseCatch.Checked;
  aStorage.FieldByName('Continue').AsInteger  := udContinue.Position;
  aStorage.FieldByName('Speed').AsInteger  := udSpeed.Position;
  aStorage.FieldByName('FillVol').AsInteger  := udFillVol.Position;
  aStorage.FieldByName('QVol').AsInteger  := udQVol.Position;
  aStorage.FieldByName('LiquidateTick').AsInteger  := udLiquidateTick.Position;
  aStorage.FieldByName('HoldTick').AsInteger  := udHoldTick.Position;
  }

end;

procedure TFrmPave.LoadEnv(aStorage : TStorage);
var
  stCode, stTime : string;
begin
  if aStorage = nil then Exit;

  //edtCnt.Text
  UpDown3.Position := StrToIntDef(aStorage.FieldByName('OrderCount').AsString, 10);
  //edtGap.Text
  UpDown2.Position := StrToIntDef(aStorage.FieldByName('OrderGap').AsString, 3 );
  UdProfit.Position := StrToIntDef(aStorage.FieldByName('Profit').AsString, 3 );

  udMaxNet.Position := StrToIntDef( aStorage.FieldByName('MaxNet').AsString , 5);
  udLCNet.Position  := StrToIntDef( aStorage.FieldByName('LCNet').AsString , 3 );

  stTime := aStorage.FieldByName('ClearTime').AsString;

  if stTime <>'' then
  begin
    DateTimePicker.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;

  edtOTE.Text := aStorage.FieldByName('LiqOTE').AsString;

  stCode  := aStorage.FieldByName('SymbolCode').AsString;
  FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
  if FSymbol <> nil then
    edtSymbol.Text  := FSymbol.Code;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
  end;
end;

procedure TFrmPave.OnStopEvent(Vaule: boolean);
begin
  if Vaule then exit;
     {
  if FCatch <> nil then
  begin
    FCatch.Stop;
  end;
  }
end;

procedure TFrmPave.OnTimer(Sender: TObject);
begin
  if FPriceAxis = nil then exit;
  
  if FPriceAxis.Position <> nil then
  begin
    stTxt.Panels[0].Text := Format('%.0f, %.0f, %.0f', [
          FPriceAxis.Position.LastPL - FPriceAxis.Position.GetFee , FPriceAxis.MaxPL, FPriceAxis.MinPL ]);
  end;
end;

procedure TFrmPave.GetParam;
begin
  with FPaveData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtGap.Text, 1 );
    OrdCnt  := StrTointDef( edtCnt.Text, 3 );
    AskHoga := rgAskIdx.ItemIndex ;
    BidHoga := rgBidIdx.ItemIndex ;
    UseAutoLiquid := cbAutoLiquid.Checked;
    LiquidTime := DateTimePicker.Time;

    MaxNet  := StrToIntDef( edtMaxNet.Text , 5 );
    LCNet   := StrToIntDef( edtLCNet.Text, 3 );
    LiqOTE  := StrToIntDef( edtOTE.Text, 100 );
  end;
       {
  with FCatchData do
  begin
    UseCatch := cbUseCatch.Checked;
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    ContinueCnt := StrToIntDef (edtContinue.Text, 3);
    SpeedPer := StrToIntDef (edtSpeed.Text, 10) / 100;
    FillVol := StrToIntDef (edtFillVol.Text, 100);
    QVol := StrToIntDef (edtQVol.Text, 50);
    LiquidateTick := StrToIntDef (edtLiquidateTick.Text, 2);
    HoldTick := StrToIntDef (edtHoldTick.Text, 3);
  end;
  }
end;

procedure TFrmPave.initControls;
begin
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := OnTimer;

end;

procedure TFrmPave.PositionNotifyEvent(Sender, Value: TObject);
begin
  if (FPriceAxis = nil ) or ( FPriceAxis <> Sender ) then Exit;


end;

procedure TFrmPave.rgAskIdxClick(Sender: TObject);
begin
  with FPaveData do
  case (Sender as TRadioGroup).Tag of
    0 : AskHoga := (Sender as TRadioGroup).ItemIndex ;
    1 : BidHoga := (Sender as TRadioGroup).ItemIndex ;
  end;

  if FPriceAxis <> nil then
    FPriceAxis.PavData := FPaveData;
end;

procedure TFrmPave.Start;
begin
  if ( FSymbol = nil ) or ( FAccount = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  //if FPaveItem = nil then
  FPriceAxis := gEnv.Engine.TradeCore.PaveManasger.New( FAccount, FSymbol, opEvolHult) as TPriceAxis;

  if FPriceAxis <> nil then
  begin

    cbAccount.Enabled := false;
    button1.Enabled   := false;

    FPriceAxis.init( FAccount, FSymbol, integer(opEvolHult) );
    FPriceAxis.OnPositionEvent  := PositionNotifyEvent;
    FPRiceAxis.OnStopEvent := OnStopEvent;

    GetParam;
    FPriceAxis.PavData := FPaveData;
    FPriceAxis.Start;
  end;

end;

procedure TFrmPave.Stop;
begin
  cbAccount.Enabled := true;
  button1.Enabled   := true;
  if FPriceAxis <> nil then
  begin
    //FTimer.Enabled := false;
    FPriceAxis.Stop;
    FPriceAxis.OnPositionEvent  := nil;
    FPRiceAxis.OnStopEvent := nil;
  end;

end;

end.
