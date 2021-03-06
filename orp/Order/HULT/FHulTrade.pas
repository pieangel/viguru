unit FHulTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Math,

  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker, CleFunds,

  CleStorage, UPaveConfig , CleHultAxis, GleTypes, Grids


  ;

type
  TFrmHulTrade = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    Panel2: TPanel;
    Label2: TLabel;
    edtSymbol: TEdit;
    Button1: TButton;
    gbUseHul: TGroupBox;
    cbAllcnlNStop: TCheckBox;
    gbRiquid: TGroupBox;
    DateTimePicker: TDateTimePicker;
    cbAutoLiquid: TCheckBox;
    stTxt: TStatusBar;
    Label6: TLabel;
    edtRiskAmt: TEdit;
    UpDown5: TUpDown;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    edtQty: TEdit;
    UpDown1: TUpDown;
    Label4: TLabel;
    edtGap: TEdit;
    UpDown2: TUpDown;
    Label5: TLabel;
    edtQuoting: TEdit;
    udQuoting: TUpDown;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    edtSPos: TEdit;
    udSPos: TUpDown;
    Label8: TLabel;
    edtEPos: TEdit;
    udEPos: TUpDown;
    cbUseBetween: TCheckBox;
    Label9: TLabel;
    edtSTick: TEdit;
    udSTick: TUpDown;
    btnApply: TButton;
    ColorDialog: TColorDialog;
    cbPause: TCheckBox;
    DateTimePicker1: TDateTimePicker;
    btnColor: TButton;
    Button6: TButton;
    edtAccount: TEdit;
    cbPlatoon: TCheckBox;
    procedure FormCreate(Sender: TObject);

    procedure Button1Click(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure edtGapKeyPress(Sender: TObject; var Key: Char);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure cbPauseClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure cbPlatoonClick(Sender: TObject);

  private
    { Private declarations }
    FAccount : TAccount;
    FSymbol  : TSymbol;
    FTimer   : TQuoteTimer;
    FHultData : THultData;
    //FHultAxis : THultAxis;
    FHults     : TList;
    FMax, FMin : double;
    FPosition : TPosition;
    FEndTime : TDateTime;
    FAutoStart  : boolean;
    FStartColor : TColor;

    FIsFund : boolean;
    FFund   : TFund;
    procedure initControls;
    procedure GetParam;
    procedure Timer1Timer(Sender: TObject);
  public
    { Public declarations }
    procedure Stop;
    procedure Start;

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmHulTrade: TFrmHulTrade;

implementation

uses
  GAppEnv , GleLib, CleStrategyStore
  ;

{$R *.dfm}

procedure TFrmHulTrade.btnApplyClick(Sender: TObject);
var
  i : integer;
begin
  GetParam;
  for I := 0 to FHults.Count - 1 do
    THultAxis( FHults.Items[i] ).HultData  := FHultData;
end;

procedure TFrmHulTrade.btnColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FStartColor := ColorDialog.Color;
  end;
end;

procedure TFrmHulTrade.Button1Click(Sender: TObject);
begin

  if cbStart.Checked then
  begin
    ShowMessage('?????????? ?????? ?????? ????');
  end;

  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin
        FSymbol := gSymbol.Selected;
        edtSymbol.Text  := FSymbol.Code;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;



procedure TFrmHulTrade.Button6Click(Sender: TObject);
begin
  if cbStart.Checked then
  begin
    ShowMessage('?????????? ?????? ?????? ????');
    Exit;
  end;

  if gAccount = nil then
    gEnv.CreateAccountSelect;  

  try
    gAccount.Left := GetMousePoint.X+10;
    gAccount.Top  := GetMousePoint.Y;

    if gAccount.Open then
    begin
      if ( gAccount.Selected <> nil ) then
        if gAccount.Selected is TFund then
        begin
          if FFund <> gAccount.Selected then
          begin
            FIsFund := true;
            FAccount:= nil;
            FFund   := TFund( gAccount.Selected );
            edtAccount.Text := FFund.Name;
          end;
        end else
        begin
            FIsFund := false;
            FFund   := nil;
            FAccount:= TAccount( gAccount.Selected );
            edtAccount.Text := FAccount.Name
        end;
    end;
  finally
    gAccount.Hide;
  end;

end;

procedure TFrmHulTrade.cbAutoLiquidClick(Sender: TObject);
var
  i, iTag : integer;
begin
  iTag := (Sender as TCheckBox ).Tag;

  if iTag = 0 then
    FHultData.UseAutoLiquid := cbAutoLiquid.Checked
  else if iTag = 1 then
    FHultData.UseAllcnlNStop  := cbAllcnlNStop.Checked
  else if iTag = 2 then
  begin
    FHultData.UseBetween := cbUseBetween.Checked;

    if FHultData.UseBetween then
      GroupBox2.Enabled := false
    else
    begin
      GroupBox2.Enabled := true;
      for I := 0 to FHults.Count - 1 do
        THultAxis( FHults.Items[i] ).DoBetweenCancel;
    end;
  end;

  for I := 0 to FHults.Count - 1 do
    THultAxis( FHults.Items[i] ).HultData  := FHultdata;
end;

procedure TFrmHulTrade.cbPauseClick(Sender: TObject);
var
  i : integer;
begin
  FHultData.UsePause := cbPause.Checked;

  for I := 0 to FHults.Count - 1 do
  begin
    THultAxis( FHults.Items[i] ).HultData  := FHultData;
    THultAxis( FHults.Items[i] ).Pause;
  end;
end;

procedure TFrmHulTrade.cbPlatoonClick(Sender: TObject);
var
  i : integer;
begin

  if cbStart.Checked then
  begin
    ShowMessage('?????????? ???? ???? ');
    Exit;
  end;

  FHultData.UsePlatoon := cbPlatoon.Checked;
  for I := 0 to FHults.Count - 1 do
    THultAxis( FHults.Items[i] ).HultData  := FHultdata;
end;

procedure TFrmHulTrade.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TFrmHulTrade.edtGapKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmHulTrade.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmHulTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmHulTrade.FormCreate(Sender: TObject);
begin
  initControls;

  FHults     := TList.Create ;

  FPosition   := nil;
  FAutoStart  := false;
end;

procedure TFrmHulTrade.FormDestroy(Sender: TObject);
begin

  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );

  if FHults <> nil then
  begin
    FHults.Clear;
    FHults.Free;
  end;
end;

procedure TFrmHulTrade.GetParam;
begin
  with FHultData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtGap.Text, 1 );
    UseAllcnlNStop  := cbAllcnlNStop.Checked;
    LiquidTime  :=  DateTimePicker.Time;
    UseAutoLiquid := cbAutoLiquid.Checked;
    QuotingQty := StrTointDef( edtQuoting.Text, 5 );
    RiskAmt := UpDown5.Position;
    UseBetween := cbUseBetween.Checked;
    UsePlatoon := cbPlatoon.Checked;
    SPos := udSPos.Position;
    EPos := udEPos.Position;
    STick := udSTick.Position;
    StartTime := DateTimePicker1.Time;
  end;
        {
  for I := 0 to FHults.Count - 1 do
    THultAxis( FHults.Items[i] ).HultData  := FHultData;
    }
end;

procedure TFrmHulTrade.initControls;
begin
  FStartColor := clBtnFace;
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;
end;

procedure TFrmHulTrade.SaveEnv(aStorage: TStorage);
var
  stLog, stFile : string;
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('UseAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('UseAllcnlNStop').AsBoolean := cbAllcnlNStop.Checked;
  aStorage.FieldByName('RiskAmt').AsInteger := UpDown5.Position;
  aStorage.FieldByName('OrderGap').AsString := edtGap.Text;
  aStorage.FieldByName('QuotingQty').AsString := edtQuoting.Text;
  aStorage.FieldByName('dtClear').AsString := FormatDateTime('hhnnss', DateTimePicker.Time);
  aStorage.FieldByName('dtStart').AsString := FormatDateTime('hhnnss', DateTimePicker1.Time);

  aStorage.FieldByName('UseBetween').AsBoolean := cbUseBetween.Checked;
  aStorage.FieldByName('UsePlatoon').AsBoolean := cbPlatoon.Checked;
  aStorage.FieldByName('SPos').AsInteger := udSPos.Position;
  aStorage.FieldByName('EPos').AsInteger := udEPos.Position;
  aStorage.FieldByName('STick').AsInteger := udSTick.Position;

  aStorage.FieldByName('OrdQty').AsString := edtQty.Text;
  aStorage.FieldByName('Color').AsInteger := integer(FStartColor);

  aStorage.FieldByName('IsFund').AsBoolean := FIsFund;

  if FSymbol <> nil then
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code
  else
    aStorage.FieldByName('SymbolCode').AsString := '';  

  if FIsFund then begin
    if FFund <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FFund.Name
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end
  else begin
    if FAccount <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FAccount.Code
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end;

end;

procedure TFrmHulTrade.LoadEnv(aStorage: TStorage);
var
  stCode,stTime : string;
  aFund : TFund;
  aAcnt : TAccount;
begin
  if aStorage = nil then Exit;

  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;

  //edtGap.Text
  UpDown2.Position := StrToIntDef(aStorage.FieldByName('OrderGap').AsString, 3 );
  Updown1.Position := StrToIntDef( aStorage.FieldByName('OrdQty').AsString , 1 );
  udQuoting.Position := StrToIntDef(aStorage.FieldByName('QuotingQty').AsString, 5 );

  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;
  cbAllcnlNStop.Checked := aStorage.FieldByName('UseAllcnlNStop').AsBoolean;
  UpDown5.Position := StrToIntDef(aStorage.FieldByName('RiskAmt').AsString, 1000 );

  cbUseBetween.Checked := aStorage.FieldByName('UseBetween').AsBoolean;
  cbPlatoon.Checked    := aStorage.FieldByName('UsePlatoon').AsBooleanDef( cbPlatoon.Checked );
  udSPos.Position := StrToIntDef(aStorage.FieldByName('SPos').AsString, 6 );
  udEPos.Position := StrToIntDef(aStorage.FieldByName('EPos').AsString, 0 );
  udSTick.Position := StrToIntDef(aStorage.FieldByName('STick').AsString, 0 );
  FStartColor := TColor(aStorage.FieldByName('Color').AsInteger);
  if Integer(FStartColor) = 0 then
    FStartColor := clBtnFace;

  stTime := aStorage.FieldByName('dtClear').AsString;
  if stTime <>'' then
  begin
    DateTimePicker.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;
  stTime := aStorage.FieldByName('dtStart').AsString;
  if stTime <>'' then
  begin
    DateTimePicker1.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;
  stCode  := aStorage.FieldByName('SymbolCode').AsString ;
  if gEnv.RunMode = rtSimulation then
    FSymbol := gEnv.Engine.SymbolCore.Futures[0]
  else
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if FSymbol <> nil then
   edtSymbol.Text  := FSymbol.Code;

  FIsFund := aStorage.FieldByName('IsFund').AsBooleanDef(false);
  stCode  := aStorage.FieldByName('AcntCode').AsString;

  if FIsFund  then
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Find( stCode );
    if aFund <> nil then
    begin
      FIsFund  := true;
      FFund    := aFund;
      FAccount := nil;
      edtAccount.Text := FFund.Name;
    end;
  end else
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
    if aAcnt <> nil then
    begin
      FIsFund   := false;
      FFund     := nil;
      FAccount  := aAcnt;
      edtAccount.Text := FAccount.Name;
    end;
  end;
end;

procedure TFrmHulTrade.OnDisplay(Sender: TObject; Value: boolean);
begin
  if Value then
    Panel1.Color := FStartColor
  else
    Panel1.Color := clbtnFace;
end;

procedure TFrmHulTrade.Start;
var
  aColl : TStrategys;
  aHult : THultAxis;
  i : integer;
  aAcnt : TAccount;
begin
  if ( FSymbol = nil ) or
     (( not FIsFund ) and  ( FAccount = nil )) or
     (( FIsFund ) and  ( FFund = nil )) then
  begin
    ShowMessage('???????? ????????. ');
    cbStart.Checked := false;
    Exit;
  end;

  FHults.Clear;
  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  GetParam;

  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aAcnt := FFund.FundAccount[i];
      aHult := THultAxis.Create(aColl, opHult);
      aHult.OnResult := OnDisplay;
      FHults.Add( aHult );
      aHult.init( aAcnt, FSymbol);
      aHult.HultData := FHultData;
      aHult.Start;
    end;
  end else
  begin
    aHult := THultAxis.Create(aColl, opHult);
    aHult.OnResult := OnDisplay;
    FHults.Add( aHult );
    aHult.init( FAccount, FSymbol);
    aHult.HultData := FHultData;
    aHult.Start;
  end;

  if FHults.Count > 0 then
  begin
    //cbAccount.Enabled := false;
    button1.Enabled   := false;
    GroupBox1.Enabled := false;
    FTimer.Enabled := true;
  end;

end;

procedure TFrmHulTrade.Stop;
var
  i : integer;
begin
  //cbAccount.Enabled := true;
  button1.Enabled   := true;
  GroupBox1.Enabled := true;

  for I := FHults.Count - 1 downto 0 do
  begin
    THultAxis( FHults.Items[i] ).Stop( false );
    THultAxis( FHults.Items[i] ).OnResult  := nil;
    THultAxis( FHults.Items[i] ).Free;
  end;

  FHults.Clear;
end;

procedure TFrmHulTrade.Timer1Timer(Sender: TObject);
var
  stLog : string;
  aItem : THultAxis;
  bRun  : boolean;
  dOpenPL, dTotPL : double;
  iMax, ivol, I, iCnt : Integer;
begin
  if FHults.Count = 0 then exit;

  dOpenPL := 0; dTotPL := 0;   ivol := 0;   iMax := 0;  bRun := false;

  for I := 0 to FHults.Count - 1 do
  begin
    aItem := THultAxis( FHults.Items[i] );
    if ( aItem <> nil ) and ( aItem.Position <> nil ) then
    begin
      dOpenPL := dOpenPL + aItem.Position.EntryOTE;
      dTotPL  := dTotPL  + aItem.Position.LastPL;
      iVol    := iVol    + aItem.Position.Volume;
      iMax    := iMax    + aItem.Position.MaxPos;
      bRun := aItem.Run;
    end;
  end;


  stTxt.Panels[0].Text := Format('%d, %d', [ iVol, iMax ]);

  FMin := Min( FMin, dTotPL );
  FMax := Max( FMax, dTotPL );

  stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
        dTotPL/1000 , FMax/1000, FMin/1000 ]);

// ?????? ????
  aItem := THultAxis( FHults.Items[0] );
  if aItem <> nil then begin
    if not aItem.PlatoonFalg then
      stTxt.Panels[1].Text := '?????? ????????';
  end;

  if bRun then
    Panel1.Color := FStartColor;
end;

end.
