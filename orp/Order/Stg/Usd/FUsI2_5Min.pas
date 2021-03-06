unit FUsI2_5Min;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,

  CleAccounts, CleFunds, CleSymbols , CleUsdParam,CleUsIn_5min,

  CleStorage
  ;

type
  TFrmUsI2 = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    edtSymbol: TLabeledEdit;
    cbRun: TCheckBox;
    edtAccount: TEdit;
    Button6: TButton;
    stTxt: TStatusBar;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    dtEnd: TDateTimePicker;
    dtEntend: TDateTimePicker;
    dtEntStart: TDateTimePicker;
    Label5: TLabel;
    cbDefault: TComboBox;
    cbStopLiq: TCheckBox;
    GroupBox2: TGroupBox;
    edtOrdQty: TLabeledEdit;
    edtChanelIdx: TLabeledEdit;
    Button2: TButton;
    Label8: TLabel;
    dtATRLiqStart: TDateTimePicker;
    edtATRPeriod: TLabeledEdit;
    edtATRMulti: TLabeledEdit;
    edtTermCnt: TLabeledEdit;
    edtEntryCnt: TLabeledEdit;
    UpDown1: TUpDown;
    Timer1: TTimer;
    edtH: TEdit;
    edtL: TEdit;
    dtMkStart: TDateTimePicker;
    procedure Button6Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure cbRunClick(Sender: TObject);
    procedure cbDefaultChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbStopLiqClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FSymbol : TSymbol;
    FAccount: TAccount;
    FFund   : TFund;
    FIsFund : boolean;
    FParam  : TUs_I2_Param;
    FTrends : TUsIn_5Min_Trends;
    FFuture : TSymbol;
    procedure GetParam;
    function GetRect(oRect: TRect): TRect;
    procedure SetControls(bEnable: boolean);
    procedure Start;
    procedure Stop;
    procedure SetParamData;
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmUsI2: TFrmUsI2;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

procedure TFrmUsI2.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbRun.Checked then
        begin
          ShowMessage('?????????? ?????? ?????? ????');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.ShortCode;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmUsI2.Button2Click(Sender: TObject);
begin
  GetParam;
  SetParamData;
end;

procedure TFrmUsI2.Button6Click(Sender: TObject);
begin
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

procedure TFrmUsI2.cbDefaultChange(Sender: TObject);
begin
  //
end;

procedure TFrmUsI2.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    start
  else
    stop;
end;

procedure TFrmUsI2.SetParamData;
var
  I: Integer;
begin
  if  cbRun.Checked then
    for I := 0 to FTrends.Count - 1 do
    begin
      //FParam.OrdQty := FParam.OrdQty * FTrends.UsTrend[i].
      FTrends.UsTrend[i].Param  := FParam;
    end;
end;


procedure TFrmUsI2.cbStopLiqClick(Sender: TObject);
begin
  FParam.UseStopLiq := cbStopLiq.Checked;
  SetParamData;
end;

procedure TFrmUsI2.FormCreate(Sender: TObject);
begin
  FTrends := TUsIn_5Min_Trends.Create;

  FAccount := nil;
  FSymbol  := nil;
  FFund    := nil;

  FFuture := gEnv.Engine.SymbolCore.Future;
end;

procedure TFrmUsI2.Start;
var
  aTrd : TUsIn_5Min_Trend;
  I: Integer;
begin

  FTrends.Clear;
  GetParam;

  if not FIsFund then
  begin
    if ( FSymbol = nil ) or ( FAccount = nil ) then
    begin
      ShowMessage('???????? ????????. ');
      cbRun.Checked := false;
      Exit;
    end;

    aTrd  := FTrends.New( self ) ;
    aTrd.Param  := FParam;
    aTrd.init( FAccount, FFuture, FSymbol );
    aTrd.Start;


  end else begin
    if ( FSymbol = nil ) or ( FFund = nil ) then
    begin
      ShowMessage('???????? ????????. ');
      cbRun.Checked := false;
      Exit;
    end;

    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aTrd  := FTrends.New(Self);
      aTrd.Param  := FParam;
      aTrd.init( FFund.FundAccount[i], FFuture, FSymbol );
      aTrd.Multi  := FFund.FundItems.FundItem[i].Multiple ;
      aTrd.Start;
    end;
  end;

  if FTrends.Count > 0 then
  begin
    plRun.Color := clLime;
    Timer1.Enabled  := true;
    SetControls( false );
  end;
end;

procedure TFrmUsI2.SetControls( bEnable : boolean );
begin
  cbDefault.Enabled := bEnable;
  Button6.Enabled := bEnable;
  Button1.Enabled   := bEnable;
end;

procedure TFrmUsI2.Stop;
var
  I: Integer;
begin

  for I := 0 to FTrends.Count - 1 do
    FTrends.UsTrend[i].Stop;

  plRun.Color := clBtnFace;
  SetControls( true );

end;

procedure TFrmUsI2.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aSymbol: TSymbol;
  aFund  : TFund;
  aAcnt  : TAccount;
begin
  if aStorage = nil then Exit;

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if aSymbol <> nil then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

  FIsFund := aStorage.FieldByName('IsFund').AsBooleanDef(false);
  stCode := aStorage.FieldByName('AcntCode').AsString;

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

  cbDefault.ItemIndex := aStorage.FieldByName('ConIdx').AsInteger;
  if cbDefault.ItemIndex < 0 then
    cbDefault.ItemIndex := 0;

  dtEnd.Time        := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time ) );
  dtEntStart.Time   := TDateTime(aStorage.FieldByName('EntStartTime').AsTimeDef( dtEntStart.Time ));
  dtEntEnd.Time     := TDateTime(aStorage.FieldByName('EntEndTime').AsTimeDef( dtEntend.Time ));
  dtMKStart.Time    := TDateTime(aStorage.FieldByName('MKStartTime').AsTimeDef( dtMKStart.Time ));

  edtOrdQty.Text  := aStorage.FieldByName('OrdQty').AsStringDef( edtOrdQty.Text );

  dtATRLiqStart.Time   := TDateTime(aStorage.FieldByName('ATRLiqStartTime').AsTimeDef( dtATRLiqStart.Time ));
  //
  edtATRPeriod.Text := aStorage.FieldByName('ATRPeriod').AsStringDef('30');
  edtATRMulti.Text  := aStorage.FieldByName('ATRMulti').AsStringDef('4') ;
  edtTermCnt.Text   := aStorage.FieldByName('TermCnt').AsStringDef('36') ;
  cbStopLiq.Checked := aStorage.FieldByName('UseStopLiq').AsBoolean; 
end;

procedure TFrmUsI2.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('IsFund').AsBoolean := FIsFund;
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

  if FSymbol <> nil then
    aStorage.FieldByName('Symbolcode').AsString     := FSymbol.Code
  else
    aStorage.FieldByName('Symbolcode').AsString    := '';

  aStorage.FieldByName('EndTime').AsFloat         := double( dtEnd.Time );
  aStorage.FieldByName('EntStartTime').AsFloat    := double( dtEntStart.Time );
  aStorage.FieldByName('EntEndTime').AsFloat      := double( dtEntEnd.Time );
  aStorage.FieldByName('MKStartTime').AsFloat      := double( dtMKStart.Time );

  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;

  aStorage.FieldByName('ATRLiqStartTime').AsFloat := double( dtATRLiqStart.Time );
  //
  aStorage.FieldByName('ATRPeriod').AsString    := edtATRPeriod.Text;
  aStorage.FieldByName('ATRMulti').AsString     := edtATRMulti.Text;
  aStorage.FieldByName('TermCnt').AsString    := edtTermCnt.Text;

  aStorage.FieldByName('UseStopLiq').AsBoolean := cbStopLiq.Checked;
  aStorage.FieldByName('ConIdx').AsInteger := cbDefault.ItemIndex;
end;

procedure TFrmUsI2.GetParam;
begin
  With FParam do
  begin
    Endtime     := Frac( dtEnd.Time );
    EntTime     := Frac( dtEntStart.Time );
    EntEndtime  := Frac( dtEntEnd.Time );
    MkStartTime := Frac( dtMkStart.Time );

    OrdQty    := StrToIntDef( edtOrdQty.Text, 1 );
    EntryCnt   := StrToIntDef( edtEntryCnt.Text, 4);
    ChanelIdx  := StrToIntDef( edtChanelIdx.Text, 12 );

    // ATR
    ATRLiqTime  := Frac( dtATRLiqStart.Time );
    TermCnt := StrToIntDef( edtTermCnt.Text, 12 );
    ATRMulti:= StrToIntDef( edtATRMulti.Text, 4 );
    CalcCnt     := StrToIntDef( edtATRPeriod.Text, 30 );
    //

    UseStopLiq  := cbStopLiq.Checked;
    StgIndex    := cbDefault.ItemIndex;
  end;
end;

function TFrmUsI2.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;
procedure TFrmUsI2.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
  var
    oRect : TRect;
begin
  if stTxt.Tag = 0 then begin
    StatusBar.Canvas.Brush.Color := clBtnFace;
    StatusBar.Canvas.Font.Color := clBlack;
  end
  else if stTxt.Tag < 0 then begin
    StatusBar.Canvas.Brush.Color := clBlue;
    StatusBar.Canvas.Font.Color := clWhite;
  end
  else if stTxt.Tag > 0 then begin
    StatusBar.Canvas.Brush.Color := clRed;
    StatusBar.Canvas.Font.Color := clWhite;
  end;

  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  DrawText( stTxt.Canvas.Handle, PChar( stTxt.Panels[0].Text ),
    Length( stTxt.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
end;

procedure TFrmUsI2.Timer1Timer(Sender: TObject);
var
  aTrd :TUsIn_5Min_Trend;
  iVol, I: Integer;
  st1, st2, st3 : string;
  dTmp : double;

begin
  iVol := 0;    dTmp := 0;
  st1  := '';
  st2  := ''; st3 := '';
  for I := 0 to FTrends.Count - 1 do
  begin
    aTrd  := FTrends.UsTrend[i];
    if ( aTrd <> nil ) and ( aTrd.Position <> nil ) then
    begin
      iVol  := aTrd.Position.Volume + iVol;
      if i = 0 then begin
        edtH.Text := Format('%.2f', [ aTrd.StandHigh]);
        edtL.Text := Format('%.2f', [ aTrd.StandLow ]);
        st1 := Format('%.2f', [ aTrd.ATR ]);
        st2 := Format('(%dth.)',  [ aTrd.OrderCnt ]);
      end;
      dTmp  := dTmp + aTrd.Position.LastPL;
    end;
  end;

  stTxt.Panels[0].Text  := IntToStr( iVol );
  stTxt.Tag := iVol;
  stTxt.Panels[1].Text := st1;
  stTxt.Panels[2].Text := Format('%s %.0f', [ st2, dTmp / 1000 ]);

end;

end.
