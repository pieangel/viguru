unit FleStrangle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,
  CleStrangle, CleAccounts, CleFunds, GleLib, CleQuoteBroker, CleSymbols, CleQuoteTimers,
  ComCtrls, CleStrategyStore, CleStorage;

const
  FutTitle : array[0..3] of string =
                            ('Code', '시가', '현재가', '건수비');
  OptTitle : array[0..3] of string =
                            ('Code', '현재가', '포지션', '평가손익');
  StatusTitle : array[0..5] of string =
                            ('09:01', '09:15', '10:00', '11:00', '12:00', '13:00');
  CHKON = 1;
  CHKOFF = 0;

type
  TFrmStrangle = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    cbStart: TCheckBox;
    btnSymbol: TButton;
    sgStatus: TStringGrid;
    sgOpt: TStringGrid;
    StatusBar1: TStatusBar;
    btnClear: TButton;
    Timer2: TTimer;
    GroupBox1: TGroupBox;
    edtDownBid2: TEdit;
    edtDownBid3: TEdit;
    edtDownAsk3: TEdit;
    edtDownAsk2: TEdit;
    edtDownAsk1: TEdit;
    edtDownBid1: TEdit;
    cbDownHdg1: TCheckBox;
    cbDownHdg2: TCheckBox;
    cbDownHdg3: TCheckBox;
    edtUpAsk3: TEdit;
    edtUpAsk2: TEdit;
    edtUpAsk1: TEdit;
    edtUpBid1: TEdit;
    edtUpBid2: TEdit;
    edtUpBid3: TEdit;
    cbUpHdg3: TCheckBox;
    cbUpHdg2: TCheckBox;
    cbUpHdg1: TCheckBox;
    cbLow: TCheckBox;
    cbUseHedge: TCheckBox;
    GroupBox2: TGroupBox;
    edtQty: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    edtLow: TEdit;
    Label9: TLabel;
    edtHigh: TEdit;
    Label12: TLabel;
    edtLoss: TEdit;
    Label11: TLabel;
    Button1: TButton;
    cbCallLow: TCheckBox;
    cbCallHigh: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    cbPutLow: TCheckBox;
    cbPutHigh: TCheckBox;
    sgFut: TStringGrid;
    Button2: TButton;
    sgTime: TStringGrid;
    edtAccount: TEdit;
    Button6: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgFutDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure cbStartClick(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure sgStatusDblClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure cbUpHdg1Click(Sender: TObject);
    procedure cbDownHdg1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cbLowClick(Sender: TObject);
    procedure cbUseHedgeClick(Sender: TObject);
    procedure cbCallLowClick(Sender: TObject);
    procedure cbPutLowClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure sgStatusMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgStatusMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    //FTrade : TStrangleTrade;
    FStrangles  : TList;
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;
    FParam : TStrangleParams;
    FAutoStart : boolean;
    FLoadTimer : TQuoteTimer;
    procedure InitGrid;
    procedure ClearGrid;
  public
    { Public declarations }
    UseSendTime : array [0..5] of integer;
    SendTime    : array [0..5] of string;
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmStrangle: TFrmStrangle;

implementation

uses
  GAppEnv, GleConsts, GleTypes,
  Math;
{$R *.dfm}

procedure TFrmStrangle.btnClearClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FStrangles.Count - 1 do
    TStrangleTrade( FStrangles.Items[i] ).ClearOrder;

end;

procedure TFrmStrangle.btnSymbolClick(Sender: TObject);
var
  i : integer;
begin
  for I := 0 to FStrangles.Count - 1 do
    TStrangleTrade( FStrangles.Items[i] ).SetSymbol;
end;

procedure TFrmStrangle.Button1Click(Sender: TObject);
var
  dAmt   : double;
  i : integer;
begin
  dAmt  := StrToFloatDef( edtLoss.Text, 0 );
  if dAmt <= 0 then
  begin
    ShowMessage('한도 금액 0 이상이여야함 ');
    Exit;
  end;

  for I := 0 to FStrangles.Count - 1 do
    TStrangleTrade( FStrangles.Items[i] ).SetStopLossAmt( dAmt * 1000);
end;



procedure TFrmStrangle.Button6Click(Sender: TObject);
begin
  if cbStart.Checked then
  begin
    ShowMessage('실행중에는 계좌를 바꿀수 없음');
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

procedure TFrmStrangle.cbStartClick(Sender: TObject);
var
  I: Integer;
  startTime : TDateTime;
  aItem  : TFundItem;
  aTrd   : TStrangleTrade;
  aColl : TStrategys;
begin
  // 스타트 스탑 주문수량 Enable

  FParam.Start := cbStart.Checked;
  FParam.OrderQty := StrToIntDef(edtQty.Text, 1);

  FParam.UpBid[0] := StrToFloatDef(edtUpBid1.Text, 0.7);
  FParam.UpBid[1] := StrToFloatDef(edtUpBid2.Text, 0.65);
  FParam.UpBid[2] := StrToFloatDef(edtUpBid3.Text, 0.6);

  FParam.UpAsk[0] := StrToFloatDef(edtUpAsk1.Text, 0.9);
  FParam.UpAsk[1] := StrToFloatDef(edtUpAsk2.Text, 1);
  FParam.UpAsk[2] := StrToFloatDef(edtUpAsk3.Text, 1.1);

  FParam.DownBid[0] := StrToFloatDef(edtDownBid1.Text, 0.7);
  FParam.DownBid[1] := StrToFloatDef(edtDownBid2.Text, 0.65);
  FParam.DownBid[2] := StrToFloatDef(edtDownBid3.Text, 0.6);

  FParam.DownAsk[0] := StrToFloatDef(edtDownAsk1.Text, 0.9);
  FParam.DownAsk[1] := StrToFloatDef(edtDownAsk2.Text, 1);
  FParam.DownAsk[2] := StrToFloatDef(edtDownAsk3.Text, 1.1);

  FParam.UseUp[0] := cbUpHdg1.Checked;
  FParam.UseUp[1] := cbUpHdg2.Checked;
  FParam.UseUp[2] := cbUpHdg3.Checked;

  FParam.UseDown[0] := cbDownHdg1.Checked;
  FParam.UseDown[1] := cbDownHdg2.Checked;
  FParam.UseDown[2] := cbDownHdg3.Checked;

  FParam.LowOrder := cbLow.Checked;

  FParam.CalLowEnt  := cbCallLow.Checked;
  FParam.CalHighEnt := cbCallHigh.Checked;
  FParam.PutLowEnt  := cbPutLow.Checked;
  FParam.PutHighEnt := cbPutHigh.Checked;

  FParam.LowPrice := StrToFloatDef(edtLow.Text , 0.5);
  FParam.HighPrice:= StrToFloatDef(edtHigh.Text , 2.0);
  FParam.UseHedge := cbUseHedge.Checked;
  FParam.LossAmt  := StrToFloatDef( edtLoss.Text, 200 ) * 1000;

  for I := 0 to High(UseSendTime) do
  begin
    UseSendTime[i] := CHKON;
    SendTime[i]    := sgStatus.Rows[0].Strings[i];
  end;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  if FParam.Start then
  begin
    if (FIsFund) and ( FFund <> nil ) then
    begin

      for I := 0 to FFund.FundItems.Count - 1 do
      begin
        aItem := FFund.FundItems.FundItem[i];
        aTrd  := TStrangleTrade.Create(aColl, opStrangle);
        aTrd.SetAccount( aItem.Account );
        aTrd.StartStop( FParam );
        FStrangles.Add( aTrd );
        if i =  FFund.FundItems.Count - 1 then
          aTrd.OnResult := OnDisPlay;
      end;
    end else
    if (not FIsFund) and ( FAccount <> nil ) then begin
      aTrd  := TStrangleTrade.Create(aColl, opStrangle);
      aTrd.SetAccount( FAccount );
      aTrd.StartStop( FParam );
      FStrangles.Add( aTrd );
      aTrd.OnResult := OnDisPlay;
    end;


    startTime := EncodeTime(9,0,0,0);
    if Frac(now) > startTime then
    begin
      // 초기화......
      ClearGrid;
      for I := 0 to FStrangles.Count - 1 do begin
        TStrangleTrade( FStrangles.Items[i] ).ReSet;
        TStrangleTrade( FStrangles.Items[i] ).SetSymbol;
      end;
    end;

    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.SetOrderTime( SendTime ) ;;

    if FStrangles.Count > 0 then
      for i := 0 to 5 do
        sgStatus.Objects[i, 1]:= TStrangleTrade( FStrangles.Items[0] ).Strangles.GetTimeOrder(i) as TObject;
  end else
  begin
    for I := 0 to FStrangles.Count - 1 do
    begin
      TStrangleTrade( FStrangles.Items[i] ).StartStop( FParam );
      TStrangleTrade( FStrangles.Items[i] ).OnResult  := nil;
      TStrangleTrade( FStrangles.Items[i] ).Free;
    end;
    FStrangles.Clear;
  end;

  Button1.Enabled := FParam.Start;

end;

procedure TFrmStrangle.cbUpHdg1Click(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.UpdateUpHedge( (Sender as TCheckBox).Tag, (Sender as TCheckBox).Checked );
end;

procedure TFrmStrangle.cbCallLowClick(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.UpdateCallEntry( (Sender as TCheckBox).Tag, (Sender as TCheckBox).Checked );
end;

procedure TFrmStrangle.cbPutLowClick(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.UpdatePutEntry( (Sender as TCheckBox).Tag, (Sender as TCheckBox).Checked );
end;

procedure TFrmStrangle.cbDownHdg1Click(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.UpdateDownHedge( (Sender as TCheckBox).Tag, (Sender as TCheckBox).Checked );
end;

procedure TFrmStrangle.cbUseHedgeClick(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.UpdateUseParam( 1, cbUseHedge.Checked );
end;

procedure TFrmStrangle.cbLowClick(Sender: TObject);
var
  i : integer;
begin
  if cbStart.Checked then
    for I := 0 to FStrangles.Count - 1 do
      TStrangleTrade( FStrangles.Items[i]).Strangles.UpdateUseParam( 0, cbLow.Checked );
end;     

procedure TFrmStrangle.ClearGrid;
var
  i, j : integer;
begin
  for i := 1 to sgOpt.RowCount - 1 do
  begin
    for j := 0 to sgOpt.ColCount - 1 do
      sgOpt.Cells[j,i] := '';
  end;
end;



procedure TFrmStrangle.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil )then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmStrangle.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmStrangle.FormCreate(Sender: TObject);

begin
  InitGrid;

  FIsFund := false;
  FStrangles  := TList.Create;

  //FTrade := TStrangleTrade.Create(aColl, opStrangle);
  //FTrade.OnResult := OnDisplay;

  FLoadTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLoadTimer.Interval := 500;
  FLoadTimer.Enabled  := true;
  FLoadTimer.OnTimer  := Timer1Timer;
end;

procedure TFrmStrangle.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  FLoadTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLoadTimer );
  for I := 0 to FStrangles.Count - 1 do
    gEnv.Engine.TradeCore.StrategyGate.Del(TStrangleTrade( FStrangles.Items[i] ) );
  FStrangles.Free;
end;

procedure TFrmStrangle.InitGrid;
var
  i : integer;
begin
  for i := 0 to 3 do
  begin
    //sgFut.Cells[i,0] := FutTitle[i];
    sgOpt.Cells[i,0] := OptTitle[i];
  end;

  for i := 0 to 5 do
  begin
    sgStatus.Cells[i,0] := StatusTitle[i];
  end;

  with sgTime do
  begin
    Cells[1,0]  := '시';
    Cells[2,0]  := '분';
    Cells[3,0]  := '초';

    Cells[0,1]  := '시가';
    Cells[0,2]  := '1';
    Cells[0,3]  := '2';
    Cells[0,4]  := '3';
    Cells[0,5]  := '4';
    Cells[0,6]  := '5';

    Cells[1,1]  := '9';
    Cells[1,2]  := '9';
    Cells[1,3]  := '10';
    Cells[1,4]  := '11';
    Cells[1,5]  := '12';
    Cells[1,6]  := '13';

    Cells[2,1]  := '0';
    Cells[2,2]  := '15';
    Cells[2,3]  := '0';
    Cells[2,4]  := '0';
    Cells[2,5]  := '0';
    Cells[2,6]  := '0';

    Cells[3,1]  := '1';
    Cells[3,2]  := '0';
    Cells[3,3]  := '0';
    Cells[3,4]  := '0';
    Cells[3,5]  := '0';
    Cells[3,6]  := '0';
  end;
end;

procedure TFrmStrangle.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  i,j : integer;  
  aAcnt : TAccount; aFund : TFund;
begin

  if aStorage.FieldByName('edtQty').AsString = '' then
    edtQty.Text := '1'
  else
    edtQty.Text := aStorage.FieldByName('edtQty').AsString;
  cbLow.Checked := aStorage.FieldByName('cbLow').AsBoolean;
  cbUseHedge.Checked := aStorage.FieldByName('cbUseHedge').AsBoolean;

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

  edtLoss.Text := aStorage.FieldByName('LossAmt').AsStringDef( '200');

  if aStorage.FieldByName('SaveTime').AsString = 'yes' then
    for I := 1 to sgTime.RowCount - 1 do
      for j := 1 to sgTime.ColCount - 1 do
        sgTime.Cells[j,i] := aStorage.FieldByName( Format('Cell_%d%d',[j,i]) ).AsString;
end;

procedure TFrmStrangle.OnDisplay(Sender: TObject; Value: boolean);
var
  i, iCol, iRow : integer;
  aQuote : TQuote;
  aItem : TStrangle;
  dBid, dAsk, dVal : double;
  aTrade : TStrangleTrade;
begin
  if Sender = nil then exit;

  aQuote := Sender as TQuote;

  sgFut.Cells[0,0] := aQuote.Symbol.ShortCode;
  sgFut.Cells[0,1] := Format('%.2f', [aQuote.Symbol.DayOpen ]);
  sgFut.Cells[0,2] := Format('%.2f', [aQuote.Last]);
  sgFut.Objects[0,2] := Pointer(ifThenColor( aQuote.Last < aQuote.Symbol.DayOpen, clBlue, clRed ));

  dAsk :=0; dBid :=0;
  if (aQuote.Asks.CntTotal > 0) and ( aQuote.Bids.CntTotal > 0 ) then
  begin
    dAsk := aQuote.Bids.CntTotal / aQuote.Asks.CntTotal;
    dBid := aQuote.Asks.CntTotal / aQuote.Bids.CntTotal;
  end;
  dVal  := Min( dAsk, dBid );
  sgFut.Objects[0,3] := Pointer(ifThenColor( dAsk > dBid, clBlue, clRed ));
  sgFut.Cells[0,3] := Format('%.2f', [dVal]);

  if FStrangles.Count < 0 then Exit;
  aTrade  := TStrangleTrade( FStrangles.Items[0] );
  
  sgFut.Cells[0,4] := aTrade.Strangles.GetStatusDesc;

  StatusBar1.Panels[0].Text  := Format('%.0n', [aTrade.TotPL ]);

  iRow := 1;
  for i := 0 to aTrade.Strangles.Count - 1 do
  begin
    aItem := aTrade.Strangles.Items[i] as TStrangle;
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aItem.Symbol.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.Symbol.Last]); inc(iCol);
    if aItem.Position <> nil then
    begin
      sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.Position.Volume]); inc(iCol);
      sgOpt.Cells[iCol, iRow] := Format('%.0n', [aItem.Position.EntryOTE]); inc(iCol);
    end;
    inc(iRow);
  end;

  for i := 0 to 5 do
    sgStatus.Cells[i,1] := ' ';
  {
  if sgStatus.Objects[0, 1] = nil then
  begin
    for i := 0 to 5 do
      sgStatus.Objects[i, 1]:= FTrade.Strangles.GetTimeOrder(i) as TObject;
  end;
  }
end;

procedure TFrmStrangle.SaveEnv(aStorage: TStorage);
var
  I,    j: Integer;
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

  aStorage.FieldByName('edtQty').AsString := edtQty.Text;
  aStorage.FieldByName('cbLow').AsBoolean := cbLow.Checked;
  aStorage.FieldByName('cbUseHedge').AsBoolean := cbUseHedge.Checked;


  aStorage.FieldByName('LossAmt').AsString := edtLoss.Text;

  aStorage.FieldByName('SaveTime').AsString := 'yes';

  for I := 1 to sgTime.RowCount - 1 do
    for j := 1 to sgTime.ColCount - 1 do
      aStorage.FieldByName( Format('Cell_%d%d',[j,i]) ).AsString := sgTime.Cells[j,i]
end;

procedure TFrmStrangle.sgFutDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  sgGrid : TStringGrid;
  dData : double;
  aItem : TTimeOrder;
  aRect : TRect;

  procedure DrawCheck(DC:HDC;BBRect:TRect;bCheck:Boolean);
  begin
    if bCheck then
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK + DFCS_CHECKED)
    else
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK);
  end;
begin

  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  sgGrid := Sender as TStringGrid;
  with sgGrid do
  begin
    stTxt := Cells[ ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace
    else
    begin
      if Tag = 0 then
      begin
        if ACol = 0 then
          case ARow of
            2, 3 : aFont  := TColor( Objects[ACol, ARow]);
          end;

      end else
      if Tag = 1 then
      begin
        aItem := Objects[ACol, 1] as TTimeOrder;
        if aItem <> nil then
        begin
          if aItem.Send then aBack := SELECTED_COLOR2;
        end;
      end;
    end;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );

    if ( sgGrid = sgStatus ) and ( ARow > 0  )then
    begin
      arect := Rect;
      arect.Top := Rect.Top + 2;
      arect.Bottom := Rect.Bottom - 2;
      DrawCheck(Canvas.Handle, arect, UseSendTime[ACol] = CHKON );
    end;
  end;

end;

procedure TFrmStrangle.sgStatusDblClick(Sender: TObject);
var
  pt: TPoint;
  iTmp, ACol, i,  ARow : integer;
  dtNow : TDateTime;
  aItem : TTimeOrder;
begin

  pt:= Mouse.CursorPos;
  pt:= sgStatus.ScreenToClient(pt);
  sgStatus.MouseToCell(pt.x,pt.y,ACol,ARow);

  if (ARow = 1) then   //0번째 열
  begin
    aItem := sgStatus.Objects[ACol, 1] as TTimeOrder;
    if aItem = nil then Exit;

    iTmp := UseSendTime[ACol];
    // 지금 시각과 체크할 시각 비교
    dtNow := Frac( GetQuoteTime );
    if dtNow > aItem.TimeOrder then
    begin
      ShowMessage('과거는 바꿀수 없다');
      Exit;
    end else
    begin
      if iTmp = CHKON then
        iTmp := CHKOFF
      else
        iTmp:= CHKON;
    end;

    UseSendTime[ACol] := iTmp;
    sgStatus.Invalidate;

    if cbStart.Checked then
      for I := 0 to FStrangles.Count - 1 do
        TStrangleTrade( FStrangles.Items[i] ).UpdateTimeOrder( aCol, iTmp );
  end;
end;

procedure TFrmStrangle.sgStatusMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  sgStatus.EditorMode := false;
  sgStatus.Options    := sgStatus.Options - [ goEditing ];
end;

procedure TFrmStrangle.sgStatusMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    aCol, aRow : integer;
begin
  sgStatus.MouseToCell( X, Y, aCol, aRow);

  with sgStatus do
    if  ( aRow = 0 ) then
    begin
      Options     := Options + [ goEditing ];
      EditorMode  := true;
    end else begin
      EditorMode  := true;
      Options     := Options - [ goEditing ];
    end;
end;

procedure TFrmStrangle.Timer1Timer(Sender: TObject);
var
  startTime : TDateTime;
  st : string;
  i : integer;
  aTrd : TStrangleTrade;
begin
  startTime := EncodeTime(8,59,58,0);
  if Frac(GetQuoteTime) > startTime then
  begin
    ClearGrid;

    for I := 0 to FStrangles.Count - 1 do
    begin
      aTrd  :=  TStrangleTrade( FStrangles.Items[i] );
      aTrd.ReSet;
      aTrd.SetSymbol;

      if i = FStrangles.Count-1 then

      if aTrd.Strangles.Count > 0 then
      begin
        if aTrd.Strangles.CurrentTime <> nil then
          st := FormatDateTime('hh:nn:ss', aTrd.Strangles.CurrentTime.TimeOrder )
        else
          st := '0';
        FLoadTimer.Enabled  := false;
        StatusBar1.Panels[1].Text := Format('Next : %s ,  청산 : %s',
          [ st, FormatDateTime('hh:nn:ss', aTrd.EndTime)]) ;
      end;
    end;
    //btnSymbol.Enabled := false;
    //ComboAccount.Enabled := false;
  end;

end;

procedure TFrmStrangle.Timer2Timer(Sender: TObject);
var
  startTime : TDateTime;
  st : string;
  aTrd : TStrangleTrade;
begin
  startTime := EncodeTime(8,59,58,0);
  if Frac(GetQuoteTime) > startTime then
  begin
    aTrd  := nil;
    if FStrangles.Count > 0 then
      aTrd  := TStrangleTrade( FStrangles.Items[ FStrangles.Count-1 ] );

    if aTrd <> nil then
      if aTrd.Strangles.Count > 0 then
      begin
        if aTrd.Strangles.CurrentTime <> nil then
          st := FormatDateTime('hh:nn:ss', aTrd.Strangles.CurrentTime.TimeOrder )
        else
          st := '0';

        StatusBar1.Panels[1].Text := Format('Next : %s ,  청산 : %s',
          [ st, FormatDateTime('hh:nn:ss', aTrd.EndTime)]) ;
      end;
  end;

end;

end.
