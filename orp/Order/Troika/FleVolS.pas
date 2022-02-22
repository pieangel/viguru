unit FleVolS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, StdCtrls, ExtCtrls,
   CleAccounts, GleLib, CleQuoteBroker, CleSymbols, CleQuoteTimers, CleStorage,
  CleStrategyStore, CleVolSTrade, ClePositions;

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
  TFrmVolS = class(TForm)
    Panel1: TPanel;
    Label2: TLabel;
    Label1: TLabel;
    Label8: TLabel;
    btnClear: TButton;
    ComboAccount: TComboBox;
    cbStart: TCheckBox;
    edtQty: TEdit;
    udQty: TUpDown;
    gbEntry: TGroupBox;
    Label7: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    edtStart: TEdit;
    udStart: TUpDown;
    edtCount: TEdit;
    udCount: TUpDown;
    udGap: TUpDown;
    edtGap: TEdit;
    GroupBox2: TGroupBox;
    Label17: TLabel;
    edtHighPL: TEdit;
    GroupBox3: TGroupBox;
    Label15: TLabel;
    edtLossCut: TEdit;
    udLosscut: TUpDown;
    dtClear: TDateTimePicker;
    cbAutoLiquid: TCheckBox;
    Panel2: TPanel;
    sgOpt: TStringGrid;
    Label3: TLabel;
    edtChange: TEdit;
    udChange: TUpDown;
    sgBase: TStringGrid;
    GroupBox1: TGroupBox;
    Label10: TLabel;
    Label9: TLabel;
    Label4: TLabel;
    Label18: TLabel;
    edtLow: TEdit;
    edtHigh: TEdit;
    edtChangeUp: TEdit;
    edtChangeDown: TEdit;
    StatusBar1: TStatusBar;
    Label19: TLabel;
    edtVPL: TEdit;
    Label16: TLabel;
    sgPos: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboAccountChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgBaseDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtQtyChange(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure edtLowKeyPress(Sender: TObject; var Key: Char);
    procedure cbStartClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure dtClearChange(Sender: TObject);
    procedure sgPosDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FTrade : TVolSTrade;
    FParam : TVolSParam;
    FTimer : TQuoteTimer;
    FAutoStart : boolean;
    procedure GetParam;
    procedure Stop;
    procedure Start;
    procedure InitGrid;
    procedure GridReSet;
    procedure SetOrder( aItem : TGradeItem);
    procedure SetVirtualSymbol( aData : TGradePosition);
    procedure DrawPos(aPos : TPosition);
  public
    { Public declarations }
    procedure OnResult(Sender: TObject; Value : boolean );
    procedure TimerTimer(Sender : TObject);
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmVolS: TFrmVolS;

implementation

uses
  GAppEnv, GleTypes, GleConsts;
{$R *.dfm}

{ TFrmVolS }

procedure TFrmVolS.btnClearClick(Sender: TObject);
begin
  if FTrade = nil then exit;
  FTrade.LossCutOrder;
end;

procedure TFrmVolS.cbAutoLiquidClick(Sender: TObject);
begin
  FParam.AutoLiquid := cbAutoLiquid.Checked;
  if FTrade <> nil then
    FTrade.Param := FParam;
end;

procedure TFrmVolS.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TFrmVolS.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;

  if (aAccount = nil) or (FAccount = aAccount) then Exit;
  FAccount := aAccount;
end;

procedure TFrmVolS.DrawPos(aPos: TPosition);
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

procedure TFrmVolS.dtClearChange(Sender: TObject);
begin
  FParam.LiquidTime := dtClear.Time;
  if FTrade <> nil then
    FTrade.Param := FParam;
end;

procedure TFrmVolS.edtLowKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.', #8]) then
    Key := #0;
end;

procedure TFrmVolS.edtQtyChange(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TEdit ).Tag;
  case iTag of
    0 : FParam.Qty  := StrToIntDef( edtQty.Text, 1 );
    1 : FParam.LowPrice := StrToFloatDef( edtLow.Text, 0.4 );
    2 : FParam.HighPrice := StrToFloatDef( edtHigh.Text, 1.0 );
    3 : FParam.ChangeDown := StrToFloatDef( edtChangeDown.Text, 0.4 );
    4 : FParam.ChangeUp := StrToFloatDef( edtChangeUp.Text, 2.0 );
    5 : ;
    6 : FParam.GradeStart := StrToIntDef( edtStart.Text, 8 );
    7 : FParam.GradeGap := StrToIntDef( edtGap.Text, 6 );
    8 : FParam.GradeCount := StrToIntDef( edtCount.Text, 4 );
    9 : FParam.Change := StrToIntDef( edtChange.Text, 7 );
    10 : FParam.LossCut := StrToFloatDef( edtLossCut.Text, 20 );
    else Exit;
  end;

  if FTrade <> nil then
    FTrade.Param := FParam;
end;

procedure TFrmVolS.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmVolS.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if FAccount <> nil then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmVolS.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmVolS.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;

  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 200;
  FTimer.OnTimer  := TimerTimer;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  FTrade := TVolSTrade.Create(aColl, opVolS);
  FTrade.OnResult := OnResult;
  gEnv.Engine.TradeCore.Accounts.GetList( comboAccount.Items );

  if comboAccount.Items.Count > 0 then
  begin
    comboAccount.ItemIndex := 0;
    comboAccountChange( comboAccount );
  end;
  FAutoStart := false;
end;

procedure TFrmVolS.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeCore.StrategyGate.Del(FTrade);
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer(FTimer);
  FTrade := nil;
end;

procedure TFrmVolS.GetParam;
begin
  with FParam do
  begin
    Qty  := StrToIntDef( edtQty.Text, 1 );
    LowPrice := StrToFloatDef( edtLow.Text, 0.4 );
    HighPrice := StrToFloatDef( edtHigh.Text, 1.0 );
    GradeStart := StrToIntDef( edtStart.Text, 110 );
    GradeGap := StrToIntDef( edtGap.Text, 10 );
    GradeCount := StrToIntDef( edtCount.Text, 4 );
    ChangeDown := StrToFloatDef( edtChangeDown.Text, 0.4 );
    ChangeUp := StrToFloatDef( edtChangeUp.Text, 2.0 );
    Change := StrToIntDef( edtChange.Text, 7 );
    LossCut := StrToFloatDef( edtLossCut.Text, 20 );
    AutoLiquid := cbAutoLiquid.Checked;
    LiquidTime := dtClear.Time;
  end;
end;

procedure TFrmVolS.GridReSet;
var
  i : integer;
begin
  for i := 1 to sgOpt.RowCount - 1 do
  begin
    sgOpt.Rows[i].Clear;
    sgOpt.Objects[0, i] := nil;
  end;

  for i := 1 to sgBase.RowCount - 1 do
  begin
    sgBase.Rows[i].Clear;
    sgBase.Objects[0,i] := nil;
  end;


  for i := 1 to sgPos.RowCount - 1 do
  begin
    sgPos.Rows[i].Clear;
    sgPos.Objects[0,i] := nil;
  end;


end;

procedure TFrmVolS.InitGrid;
var
  i : integer;
begin
  for i := 0 to sgOpt.ColCount - 1 do
  begin
    sgOpt.Cells[i,0] := OptTitle[i];
    sgOpt.ColWidths[i] := OptWidth[i];
    sgBase.Cells[i,0] := OptTitle[i];
    sgBase.ColWidths[i] := OptWidth[i];
    sgPos.Cells[i,0] := PosTitle[i];
    sgPos.ColWidths[i] := PosWidth[i];
  end;
end;

procedure TFrmVolS.LoadEnv(aStorage: TStorage);
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

  if aStorage.FieldByName('edtChangeUp').AsString = '' then
    edtChangeUp.Text := '1.0'
  else
    edtChangeUp.Text := aStorage.FieldByName('edtChangeUp').AsString;

  if aStorage.FieldByName('edtChangeDown').AsString = '' then
    edtChangeDown.Text := '0.4'
  else
    edtChangeDown.Text := aStorage.FieldByName('edtChangeDown').AsString;

  udStart.Position := StrToIntDef(aStorage.FieldByName('udStart').AsString, 110);
  udGap.Position := StrToIntDef(aStorage.FieldByName('udGap').AsString, 10);
  udCount.Position := StrToIntDef(aStorage.FieldByName('udCount').AsString, 4);

  udChange.Position := StrToIntDef(aStorage.FieldByName('udChagne').AsString, 6);

  udLosscut.Position := StrToIntDef(aStorage.FieldByName('udLosscut').AsString, 20);
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

procedure TFrmVolS.OnResult(Sender: TObject; Value: boolean);
begin
  if FTrade = nil then exit;

  if Sender is TGradePosition then
    SetVirtualSymbol(Sender as TGradePosition)
  else if Sender is TGradeItem then
    SetOrder(Sender as TGradeItem)
  else if Sender is TPosition then
    DrawPos(Sender as TPosition);
end;

procedure TFrmVolS.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('udQty').AsInteger := udQty.Position;
  aStorage.FieldByName('edtLow').AsString := edtLow.Text;
  aStorage.FieldByName('edtHigh').AsString := edtHigh.Text;

  aStorage.FieldByName('edtChangeDown').AsString := edtChangeDown.Text;
  aStorage.FieldByName('edtChangeUp').AsString := edtChangeUp.Text;
  aStorage.FieldByName('udStart').AsInteger := udStart.Position;
  aStorage.FieldByName('udGap').AsInteger := udGap.Position;
  aStorage.FieldByName('udCount').AsInteger := udCount.Position;
  aStorage.FieldByName('udChagne').AsInteger := udChange.Position;
  aStorage.FieldByName('udLosscut').AsInteger := udLosscut.Position;
  aStorage.FieldByName('cbAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('dtClear').AsString := FormatDateTime('hhnnss', dtClear.Time);

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';
end;

procedure TFrmVolS.SetOrder(aItem: TGradeItem);
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

procedure TFrmVolS.SetVirtualSymbol(aData: TGradePosition);
begin
  sgBase.Objects[0,1] := aData;
  sgBase.Cells[0, 1] := 'Call';
  sgBase.Cells[1, 1] := aData.Call.ShortCode;

  sgBase.Objects[0,2] := aData;
  sgBase.Cells[0, 2] := 'Put';
  sgBase.Cells[1, 2] := aData.Put.ShortCode;
end;

procedure TFrmVolS.sgBaseDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  sgGrid : TStringGrid;
  dData : double;
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
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;
end;

procedure TFrmVolS.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
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

procedure TFrmVolS.sgPosDrawCell(Sender: TObject; ACol, ARow: Integer;
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

procedure TFrmVolS.Start;
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
    sgOpt.RowCount := (FParam.GradeCount + 1) * 4 + 1;
    comboAccount.Enabled := false;
    gbEntry.Enabled := false;


    GetParam;
    FTrade.Param := FParam;
    FTrade.Start(FAccount);
    FTimer.Enabled := true;
  end;
end;

procedure TFrmVolS.Stop;
begin
  comboAccount.Enabled := true;
  gbEntry.Enabled := true;

  if FTrade <> nil then
    FTrade.Stop(true);
end;

procedure TFrmVolS.TimerTimer(Sender: TObject);
var
  i, iIndex : integer;
  aData : TGradePosition;
  aPos : TPosition;
begin
  if FTrade = nil then exit;


  if (FTrade.GradePos <> nil) and (FTrade.GradePos <> nil) then
  begin
    if (FTrade.GradePos.Call <> nil) and (FTrade.GradePos.Put <> nil) then
    begin
      StatusBar1.Panels[0].Text := Format('%.0n', [FTrade.TotPL/1000]);
      StatusBar1.Panels[1].Text := Format('%s(%.2f), %s(%.2f)',
            [FTrade.GradePos.Call.ShortCode, FTrade.GradePos.Call.Last, FTrade.GradePos.Put.ShortCode, FTrade.GradePos.Put.Last]);
    end;
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

  for i := 1 to sgBase.RowCount - 1 do
  begin
    aData := sgBase.Objects[0, i] as TGradePosition;
    if aData = nil then break;
    if i Mod 2 = 0 then
      iIndex := 1
    else
      iIndex := 0;
    sgBase.Cells[3,i] := Format('%.0n', [aData.PL[iIndex]]);
    sgBase.Cells[2, i] := Format('%.2f',[aData.AvgPrice[iIndex]]);
    edtHighPL.Text := Format('%d', [aData.MaxPL]);
    edtVPL.Text := Format('%d', [FTrade.BaseSum]);
  end;

  for i := 1 to sgPos.RowCount - 1 do
  begin
    aPos := sgPos.Objects[0, i] as TPosition;
    if aPos = nil then break;
    
    sgPos.Cells[3, i] := Format('%.0n', [aPos.EntryOTE]);
  end;
end;

end.
