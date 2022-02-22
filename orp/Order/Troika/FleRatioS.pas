unit FleRatioS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Grids,
  CleAccounts, GleLib, CleQuoteBroker, CleSymbols, CleQuoteTimers, CleStorage,
  CleStrategyStore, CleRatioSTrade, ClePositions;

const
  OptTitle : array[0..3] of string =
                            ('Set', 'Code', '체결가', '손익');
  OptWidth : array[0..3] of integer =
                            (40, 60, 55, 80);
  PosTitle : array[0..3] of string =
                            ('Code', '포지션', '평균단가', '평가손익');
  PosWidth : array[0..3] of integer =
                            (60, 40, 55, 80);

type
  TFrmRatioS = class(TForm)
    Panel1: TPanel;
    btnClear: TButton;
    ComboAccount: TComboBox;
    cbStart: TCheckBox;
    Label2: TLabel;
    Panel2: TPanel;
    sgOpt: TStringGrid;
    Label1: TLabel;
    edtQty: TEdit;
    udQty: TUpDown;
    Label3: TLabel;
    edtCSum: TEdit;
    Label4: TLabel;
    edtBase: TEdit;
    Label5: TLabel;
    edtPercent: TEdit;
    Label6: TLabel;
    Label8: TLabel;
    gbEntry: TGroupBox;
    Label7: TLabel;
    edtStart: TEdit;
    udStart: TUpDown;
    Label13: TLabel;
    edtCount: TEdit;
    udCount: TUpDown;
    Label11: TLabel;
    Label12: TLabel;
    udGap: TUpDown;
    edtGap: TEdit;
    Label14: TLabel;
    GroupBox3: TGroupBox;
    Label15: TLabel;
    edtLossCut: TEdit;
    udLosscut: TUpDown;
    dtClear: TDateTimePicker;
    cbAutoLiquid: TCheckBox;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    Label10: TLabel;
    edtLow: TEdit;
    Label9: TLabel;
    edtHigh: TEdit;
    edtChangeUp: TEdit;
    Label17: TLabel;
    edtChangeDown: TEdit;
    Label18: TLabel;
    edtTick: TEdit;
    udTick: TUpDown;
    Label19: TLabel;
    Label16: TLabel;
    sgPos: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure edtQtyChange(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure cbStartClick(Sender: TObject);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtLowKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure dtClearChange(Sender: TObject);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure sgPosDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    //FTrade : TStrangleTrade;
    FAccount : TAccount;

    FTrade : TRatioSTrade;
    FParam : TRatioSParam;
    FTimer : TQuoteTimer;
    FAutoStart : boolean;
    procedure GetParam;
    procedure Stop;
    procedure Start;
    procedure InitGrid;
    procedure GridReSet;
    procedure SetOrder( aItem : TGradeItem);
    procedure DrawPos(aPos : TPosition);
    
  public
    { Public declarations }
    procedure OnResult(Sender: TObject; Value : boolean );
    procedure TimerTimer(Sender : TObject);
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmRatioS: TFrmRatioS;

implementation

uses
  GAppEnv, GleTypes, GleConsts;
{$R *.dfm}

procedure TFrmRatioS.btnClearClick(Sender: TObject);
begin
  if FTrade = nil then exit;
  FTrade.LossCutOrder;
end;

procedure TFrmRatioS.cbAutoLiquidClick(Sender: TObject);
begin
  FParam.AutoLiquid := cbAutoLiquid.Checked;
  if FTrade <> nil then
    FTrade.Param := FParam;
end;

procedure TFrmRatioS.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TFrmRatioS.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;

  if (aAccount = nil) or (FAccount = aAccount) then Exit;
  FAccount := aAccount;
end;

procedure TFrmRatioS.DrawPos(aPos: TPosition);
var
  i, iRow : integer;
  aData : TPosition;
  bFind : boolean;
begin
  if aPos = nil then exit;
  
  for i := 1 to sgPos.RowCount - 1 do
  begin
    if sgPos.Objects[0,i] = nil then
    begin
      iRow := i;
      break;
    end else if sgPos.Objects[0, i] = aPos then
    begin
      iRow := i;
      break;
    end;
  end;

  sgPos.Objects[0,iRow] := aPos;
  sgPos.Cells[0, iRow] := aPos.Symbol.ShortCode;
  sgPos.Cells[1, iRow] := IntToStr(aPos.Volume);
  sgPos.Cells[2, iRow] := Format('%.*n', [aPos.Symbol.Spec.Precision, aPos.AvgPrice]);
  sgPos.Cells[3, iRow] := Format('%.0n', [aPos.EntryOTE]);
end;

procedure TFrmRatioS.dtClearChange(Sender: TObject);
begin
  FParam.LiquidTime := dtClear.Time;
  if FTrade <> nil then
    FTrade.Param := FParam;
end;

procedure TFrmRatioS.edtLowKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.', #8]) then
    Key := #0;
end;

procedure TFrmRatioS.edtQtyChange(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TEdit ).Tag;
  case iTag of
    0 : FParam.Qty  := StrToIntDef( edtQty.Text, 1 );
    1 : FParam.LowPrice := StrToFloatDef( edtLow.Text, 0.4 );
    2 : FParam.HighPrice := StrToFloatDef( edtHigh.Text, 1.0 );
    3 : FParam.GradeStart := StrToIntDef( edtStart.Text, 110 );
    4 : FParam.GradeGap := StrToIntDef( edtGap.Text, 10 );
    5 : FParam.GradeCount := StrToIntDef( edtCount.Text, 4 );
    6 : FParam.ChangeUp := StrToFloatDef( edtChangeUp.Text, 2.0 );
    7 : FParam.ChangeDown := StrToFloatDef( edtChangeDown.Text, 0.4 );
    8 : FParam.LossCut := StrToFloatDef( edtLossCut.Text, 10 );
    10 : FParam.Tick := StrToIntDef( edtTick.Text, 10 );
    else Exit;
  end;

  if FTrade <> nil then
    FTrade.Param := FParam;
end;

procedure TFrmRatioS.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmRatioS.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if FAccount <> nil then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmRatioS.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmRatioS.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;

  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 200;
  FTimer.OnTimer  := TimerTimer;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  FTrade := TRatioSTrade.Create(aColl, opRatioS);
  FTrade.OnResult := OnResult;
  gEnv.Engine.TradeCore.Accounts.GetList( comboAccount.Items );

  if comboAccount.Items.Count > 0 then
  begin
    comboAccount.ItemIndex := 0;
    comboAccountChange( comboAccount );
  end;
  FAutoStart := false;
end;

procedure TFrmRatioS.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeCore.StrategyGate.Del(FTrade);
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer(FTimer);
  FTrade := nil;
end;

procedure TFrmRatioS.GetParam;
begin
  with FParam do
  begin
    Qty  := StrToIntDef( edtQty.Text, 1 );
    LowPrice := StrToFloatDef( edtLow.Text, 0.4 );
    HighPrice := StrToFloatDef( edtHigh.Text, 1.0 );
    GradeStart := StrToIntDef( edtStart.Text, 110 );
    GradeGap := StrToIntDef( edtGap.Text, 10 );
    GradeCount := StrToIntDef( edtCount.Text, 4 );
    ChangeUp := StrToFloatDef( edtChangeUp.Text, 2.0 );
    ChangeDown := StrToFloatDef( edtChangeDown.Text, 0.4 );
    LossCut := StrToFloatDef( edtLossCut.Text, 10 );
    Tick := StrToIntDef( edtTick.Text, 10 );
    AutoLiquid := cbAutoLiquid.Checked;
    LiquidTime := dtClear.Time;
  end;
end;

procedure TFrmRatioS.GridReSet;
var
  i : integer;
begin
  for i := 1 to sgOpt.RowCount - 1 do
  begin
    sgOpt.Rows[i].Clear;
    sgOpt.Objects[0, i] := nil;
  end;

  for i := 1 to sgPos.RowCount - 1 do
  begin
    sgPos.Rows[i].Clear;
    sgPos.Objects[0, i] := nil;
  end;
end;

procedure TFrmRatioS.InitGrid;
var
  i : integer;
begin
  for i := 0 to sgOpt.ColCount - 1 do
  begin
    sgOpt.Cells[i,0] := OptTitle[i];
    sgOpt.ColWidths[i] := OptWidth[i];

    sgPos.Cells[i,0] := PosTitle[i];
    sgPos.ColWidths[i] := PosWidth[i];
  end;
end;

procedure TFrmRatioS.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin
  if aStorage = nil then Exit;
  udQty.Position := StrToIntDef(aStorage.FieldByName('udQty').AsString, 1);

  if aStorage.FieldByName('edtLow').AsString = '' then
    edtLow.Text := '0.4'
  else
    edtLow.Text := aStorage.FieldByName('edtLow').AsString;

  if aStorage.FieldByName('edtHigh').AsString = '' then
    edtHigh.Text := '1.0'
  else
    edtHigh.Text := aStorage.FieldByName('edtHigh').AsString;

  udStart.Position := StrToIntDef(aStorage.FieldByName('udStart').AsString, 110);
  udGap.Position := StrToIntDef(aStorage.FieldByName('udGap').AsString, 10);
  udCount.Position := StrToIntDef(aStorage.FieldByName('udCount').AsString, 4);

  if aStorage.FieldByName('edtChangeUp').AsString = '' then
    edtChangeUp.Text := '2.0'
  else
    edtChangeUp.Text := aStorage.FieldByName('edtChangeUp').AsString;

  if aStorage.FieldByName('edtChangeDown').AsString = '' then
    edtChangeDown.Text := '0.4'
  else
    edtChangeDown.Text := aStorage.FieldByName('edtChangeDown').AsString;

  udLosscut.Position := StrToIntDef(aStorage.FieldByName('udLosscut').AsString, 10);


  udTick.Position := StrToIntDef(aStorage.FieldByName('udTick').AsString, 10);

  cbAutoLiquid.Checked := aStorage.FieldByName('cbAutoLiquid').AsBoolean;

  stTime := aStorage.FieldByName('dtClear').AsString;

  if stTime <>'' then
  begin
    dtClear.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( comboAccount, FAccount );
    ComboAccountChange(comboAccount);
  end;

end;

procedure TFrmRatioS.OnResult(Sender: TObject; Value: boolean);
var
  i, iIndex : integer;
  aData : TGradePosition;
begin
  if FTrade = nil then exit;

  if Sender is TGradeItem then
    SetOrder(Sender as TGradeItem)
  else if (Sender is TPosition) then
    DrawPos(Sender as TPosition);
end;

procedure TFrmRatioS.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('udQty').AsInteger := udQty.Position;
  aStorage.FieldByName('edtLow').AsString := edtLow.Text;
  aStorage.FieldByName('edtHigh').AsString := edtHigh.Text;

  aStorage.FieldByName('udTick').AsInteger :=  udTick.Position; 
  aStorage.FieldByName('udStart').AsInteger := udStart.Position;
  aStorage.FieldByName('udGap').AsInteger := udGap.Position;
  aStorage.FieldByName('udCount').AsInteger := udCount.Position;

  aStorage.FieldByName('edtChangeUp').AsString := edtChangeUp.Text;
  aStorage.FieldByName('edtChangeDown').AsString := edtChangeDown.Text;

  aStorage.FieldByName('udLosscut').AsInteger := udLosscut.Position;


  aStorage.FieldByName('cbAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('dtClear').AsString := FormatDateTime('hhnnss', dtClear.Time);

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';
end;

procedure TFrmRatioS.SetOrder(aItem: TGradeItem);
var
  i, iRow : integer;
begin
  for i := 1 to sgOpt.RowCount - 1 do
  begin
    if sgOpt.Objects[0,i] = nil then
    begin
      iRow := i;
      break;
    end;
  end;

  if (aItem.Position[0].Call <> nil) and ( aItem.Position[0].Put <> nil) then
  begin
    sgOpt.Objects[0,iRow] := aItem.Position[0];
    sgOpt.Cells[0, iRow] := Format('%d Set',[aItem.CurrentIndex]);
    sgOpt.Cells[1, iRow] := aItem.Position[0].Call.ShortCode;

    inc(iRow);
    sgOpt.Objects[0,iRow] := aItem.Position[0];
    sgOpt.Cells[0, iRow] := Format('%d Set',[aItem.CurrentIndex]);
    sgOpt.Cells[1, iRow] := aItem.Position[0].Put.ShortCode;
    inc(iRow);
  end;


  if (aItem.Position[1].Call <> nil) and ( aItem.Position[1].Put <> nil) then
  begin
    sgOpt.Objects[0,iRow] := aItem.Position[1];
    sgOpt.Cells[0, iRow] := Format('%d Set',[aItem.CurrentIndex]);
    sgOpt.Cells[1, iRow] := aItem.Position[1].Call.ShortCode;

    inc(iRow);
    sgOpt.Objects[0,iRow] := aItem.Position[1];
    sgOpt.Cells[0, iRow] := Format('%d Set',[aItem.CurrentIndex]);
    sgOpt.Cells[1, iRow] := aItem.Position[1].Put.ShortCode;
  end;


end;

procedure TFrmRatioS.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  sgGrid : TStringGrid;
  dData : double;
  aItem : TGradePosition;
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
      if ARow Mod 2 = 0 then
        aBack := SHORT_COLOR
      else
        aBack := LONG_COLOR;

      if ACol in [2,3] then
        dFormat := DT_VCENTER or DT_RIGHT;

      if ACol = 2 then
      begin
        aItem := sgOpt.Objects[0, ARow] as TGradePosition;
        if aItem <> nil then
        begin
          if aItem.Close then
            aBack := HIGHLIGHT_COLOR;
        end;
      end;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TFrmRatioS.sgPosDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  sgGrid : TStringGrid;
  dData : double;
  aPos : TPosition;
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
      aPos := Objects[0, ARow] as TPosition;

      if aPos <> nil then
      begin
        if ACol = 2 then
          dFormat := DT_VCENTER or DT_RIGHT;

        if ACol = 1 then
        begin
          dFormat := DT_VCENTER or DT_RIGHT;
          if aPos.Volume > 0 then
            aFont := clRed
          else if aPos.Volume < 0 then
            aFont := clBlue;
        end;

        if ACol = 3 then
        begin
          dFormat := DT_VCENTER or DT_RIGHT;
          if aPos.EntryOTE > 0 then
            aFont := clRed
          else if aPos.EntryOTE < 0 then
            aFont := clBlue;
        end;
      end;
    end;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TFrmRatioS.Start;
begin
  if FAccount = nil  then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if FTrade <> nil then
  begin
    GridReSet;
    sgOpt.RowCount := (FParam.GradeCount+1) * 4 + 1;
    comboAccount.Enabled := false;
    gbEntry.Enabled := false;

    GetParam;
    FTrade.Param := FParam;
    FTrade.Start(FAccount);
    FTimer.Enabled := true;
  end;
end;

procedure TFrmRatioS.Stop;
begin
  comboAccount.Enabled := true;
  gbEntry.Enabled := true;

  if FTrade <> nil then
    FTrade.Stop(true);
end;

procedure TFrmRatioS.TimerTimer(Sender: TObject);
var
  i, iIndex : integer;
  aData : TGradePosition;
  aPos : TPosition;
begin
  if FTrade = nil then exit;

  edtCSum.Text := Format('%.2f',[FTrade.CurrentSum]);
  edtBase.Text := Format('%.2f',[FTrade.BaseSum]);
  edtPercent.Text := Format('%.2f',[FTrade.Ratio]);

  if (FTrade.BaseCall <> nil) and (FTrade.BasePut <> nil) then
  begin
    StatusBar1.Panels[0].Text := Format('%.0n', [FTrade.TotPL / 1000]);
    StatusBar1.Panels[1].Text := Format('%s(%.2f), %s(%.2f)',
          [FTrade.BaseCall.ShortCode, FTrade.BaseCall.Last, FTrade.BasePut.ShortCode, FTrade.BasePut.Last]);
  end;

  for i := 1 to sgOpt.RowCount - 1 do
  begin
    aData := sgOpt.Objects[0, i] as TGradePosition;
    if aData = nil then break;

    if i Mod 2 = 0 then
      iIndex := 1
    else
      iIndex := 0;


    sgOpt.Cells[3,i] := Format('%.0n', [aData.PL[iIndex]]);
    sgOpt.Cells[2, i] := Format('%.2f',[aData.AvgPrice[iIndex]]);
  end;


  for i := 1 to sgPos.RowCount - 1 do
  begin
    aPos := sgPos.Objects[0, i] as TPosition;
    if aPos = nil then break;
    
    sgPos.Cells[3, i] := Format('%.0n', [aPos.EntryOTE]);
  end;

end;

end.
