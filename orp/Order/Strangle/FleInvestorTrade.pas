unit FleInvestorTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, ComCtrls,
  CleInvestorTrade,  CleAccounts, CleQuoteBroker, CleStrategyStore,
  ClePositions, CleStorage
  ;

const
  COL_CNT = 4;
  GridTitle : array[0..3] of string =
                            ('구분', 'Call', 'Put', '합');

  GridTitleOpt : array[0..4] of string =
                            ('Code', '현재가', '포지션', '평균단가', '평가손익');

type
  TFrmInvestor = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    edtQty: TEdit;
    edtGap: TEdit;
    edtLow: TEdit;
    edtHigh: TEdit;
    btnClear: TButton;
    sgInvestor: TStringGrid;
    Panel2: TPanel;
    sgOpt: TStringGrid;
    rgType: TRadioGroup;
    StatusBar1: TStatusBar;
    Label4: TLabel;
    edtGrade: TEdit;
    Label5: TLabel;
    sgInfo: TStringGrid;
    cbReSet: TCheckBox;
    Label2: TLabel;
    edtEntryCnt: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgInvestorDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure rgTypeClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure cbHighClick(Sender: TObject);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtQtyChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FTrade : TInvestorTrade;
    FAccount : TAccount;
    FIsInfo : boolean;
    FAutoStart : boolean;
    procedure InitGrid;
    procedure InvestorData;
    procedure InitInfoGrid;
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmInvestor: TFrmInvestor;

implementation
uses
  GAppEnv, GleConsts, GleLib, GleTypes;
{$R *.dfm}

procedure TFrmInvestor.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmInvestor.cbHighClick(Sender: TObject);
begin
  cbStartClick(cbStart);
end;

procedure TFrmInvestor.cbStartClick(Sender: TObject);
var
  aParam : TInvestorParams;
  aType : TOrderType;
begin
  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);
  aParam.Gap := StrToFloatDef(edtGap.Text , 20);
  aParam.Grade := StrToIntDef(edtGrade.Text, 10);
  if rgType.ItemIndex = 0 then
    aType := otAsk
  else
    aType := otBid;

  aParam.OrderType := aType;
  aParam.ReSet := cbReset.Checked;
  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.1);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 1.5);
  aParam.EntryCnt := StrToIntDef(edtEntryCnt.Text, 2);
  FTrade.StartStop(aParam);
  FTrade.SetAccount(FAccount);
end;

procedure TFrmInvestor.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
  cbStart.Checked := false;
  cbStartClick(cbStart);
end;

procedure TFrmInvestor.edtQtyChange(Sender: TObject);
var
  aParam : TInvestorParams;
  aType : TOrderType;
begin
  if FTrade = nil then exit;

  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);
  aParam.Gap := StrToFloatDef(edtGap.Text , 20);
  aParam.Grade := StrToIntDef(edtGrade.Text, 10);
  if rgType.ItemIndex = 0 then
    aType := otAsk
  else
    aType := otBid;

  aParam.OrderType := aType;
  aParam.ReSet := cbReset.Checked;
  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.1);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 1.5);
  aParam.EntryCnt := StrToIntDef(edtEntryCnt.Text, 2);
  FTrade.Investors.Param := aParam;
end;

procedure TFrmInvestor.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if FAccount <> nil then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmInvestor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmInvestor.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;
  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  FTrade := TInvestorTrade.Create(aColl, opInvestor);
  FTrade.OnResult := OnDisplay;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;
  FIsInfo := false;
  FAutoStart := false;
end;

procedure TFrmInvestor.FormDestroy(Sender: TObject);
begin
  FTrade.Free;
end;

procedure TFrmInvestor.InitGrid;
var
  i : integer;
begin
  sgInvestor.Cells[0, 1] := '개인';
  sgInvestor.Cells[0, 2] := '금융';
  for i := 0 to COL_CNT - 1 do
    sgInvestor.Cells[i, 0] := GridTitle[i];

  for i := 0 to COL_CNT do
    sgOpt.Cells[i, 0] := GridTitleOpt[i];
end;

procedure TFrmInvestor.InitInfoGrid;
var
  i: Integer;
  dGap : double;
  aItem : TAmountGradeItem;
begin
  sgInfo.ColCount := FTrade.Investors.Param.Grade;
  for i := 0 to sgInfo.ColCount - 1 do
  begin
    dGap := FTrade.Investors.Param.Gap * (i + 1);
    sgInfo.Cells[i, 1] := Format('%.0n', [dGap]);
    sgInfo.ColWidths[i] := Round(sgInfo.Width / sgInfo.ColCount) - 1;
    aItem := FTrade.AddAmountGrades(dGap * -1);
    sgInfo.Objects[i,1] := aItem;
  end;

  aItem := FTrade.AddAmountGrades(0);

  for i := 0 to sgInfo.ColCount - 1 do
  begin
    dGap := FTrade.Investors.Param.Gap * (i + 1);
    sgInfo.Cells[i, 0] := Format('%.0n', [dGap]);
    aItem := FTrade.AddAmountGrades(dGap);
    sgInfo.Objects[i,0] := aItem;
  end;
end;

procedure TFrmInvestor.InvestorData;
var
  dSum, dSum1 : double;
begin
  dSum := 0;
  dSum1 := 0;
  if (FTrade.CallPerson <> nil) and (FTrade.PutPerson <> nil) then
  begin
    dSum := FTrade.PutPerson.SumAmount - FTrade.CallPerson.SumAmount;
    sgInvestor.Cells[1,1] := Format('%.0n', [FTrade.CallPerson.SumAmount]);
    sgInvestor.Cells[2,1] := Format('%.0n', [FTrade.PutPerson.SumAmount]);
    sgInvestor.Cells[3,1] := Format('%.0n', [dSum]);
  end;

  if (FTrade.CallFinance <> nil) and (FTrade.PutFinance <> nil) then
  begin
    dSum1 := FTrade.CallFinance.SumAmount - FTrade.PutFinance.SumAmount;
    sgInvestor.Cells[1,2] := Format('%.0n', [FTrade.CallFinance.SumAmount]);
    sgInvestor.Cells[2,2] := Format('%.0n', [FTrade.PutFinance.SumAmount]);
    sgInvestor.Cells[3,2] := Format('%.0n', [dSum1]);
  end;

  if (FTrade.PutPerson <> nil) and (FTrade.CallPerson <> nil) and (FTrade.CallFinance <> nil) and (FTrade.PutFinance <> nil) then
  begin
    sgInvestor.Cells[4,2] := Format('%.0n',[dSum + dSum1]);
  end;
end;

procedure TFrmInvestor.LoadEnv(aStorage: TStorage);
var
  stCode : string;
begin
  if aStorage = nil then Exit;
  if aStorage.FieldByName('edtQty').AsString = '' then
    edtQty.Text := '1'
  else
    edtQty.Text := aStorage.FieldByName('edtQty').AsString;

  if aStorage.FieldByName('edtGap').AsString = '' then
    edtGap.Text := '20'
  else
    edtGap.Text := aStorage.FieldByName('edtGap').AsString;

  if aStorage.FieldByName('edtGrade').AsString = '' then
    edtGrade.Text := '10'
  else
    edtGrade.Text := aStorage.FieldByName('edtGrade').AsString;
  rgType.ItemIndex := aStorage.FieldByName('rgType').AsInteger;

  if aStorage.FieldByName('edtLow').AsString = '' then
    edtLow.Text := '0.4'
  else
    edtLow.Text := aStorage.FieldByName('edtLow').AsString;

  if aStorage.FieldByName('edtHigh').AsString = '' then
    edtHigh.Text := '1.0'
  else
    edtHigh.Text := aStorage.FieldByName('edtHigh').AsString;

  cbReSet.Checked := aStorage.FieldByName('cbReSet').AsBoolean;

  if aStorage.FieldByName('edtEntryCnt').AsString = '' then
    edtEntryCnt.Text := '2'
  else
    edtEntryCnt.Text := aStorage.FieldByName('edtEntryCnt').AsString;


  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( comboAccount, FAccount );
    ComboAccountChange(comboAccount);
  end;
end;

procedure TFrmInvestor.OnDisplay(Sender: TObject; Value: boolean);
var
  i, iCol, iRow : integer;
  aPos : TPosition;
  dGap : double;
  aItem : TAmountGradeItem;
begin
  if (not FIsInfo) and (FTrade.Investors.Param.Start)  then
  begin
    InitInfoGrid;
    FIsInfo := true;
  end;

  if Value then
    InvestorData;

  StatusBar1.Panels[0].Text := Format('%.0n', [FTrade.TotPL/1000]);
  StatusBar1.Panels[1].Text := Format('(%d, %d), 청산시간 : %s',
                   [FTrade.Investors.UpEntry, FTrade.Investors.DownEntry, FormatDateTime('hh:nn:ss', FTrade.EndTime)]);

  iRow := 1;
  for i := 0 to FTrade.Positions.Count - 1 do
  begin
    aPos := FTrade.Positions.Items[i] as TPosition;
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aPos.Symbol.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aPos.Symbol.Last]); inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%d', [aPos.Volume]); inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aPos.AvgPrice]); inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.0n', [aPos.EntryOTE]); inc(iCol);
    inc(iRow);
  end;

  if FIsInfo then
  begin
    for i := 0 to sgInfo.ColCount - 1 do
    begin
      aItem := sgInfo.Objects[i, 0] as TAmountGradeItem;
      sgInfo.Cells[i,0] := Format('%.0n', [aItem.Grade]);

      aItem := sgInfo.Objects[i, 1] as TAmountGradeItem;
      sgInfo.Cells[i,1] := Format('%.0n', [aItem.Grade]);
    end;
  end;
end;

procedure TFrmInvestor.rgTypeClick(Sender: TObject);
begin
  cbStartClick(cbStart);
end;

procedure TFrmInvestor.SaveEnv(aStorage: TStorage);
begin
  aStorage.FieldByName('edtQty').AsString := edtQty.Text;
  aStorage.FieldByName('edtGap').AsString := edtGap.Text;
  aStorage.FieldByName('edtGrade').AsString := edtGrade.Text;
  aStorage.FieldByName('rgType').AsInteger := rgType.ItemIndex;

  aStorage.FieldByName('cbReSet').AsBoolean := cbReSet.Checked;
  aStorage.FieldByName('edtLow').AsString := edtLow.Text;
  aStorage.FieldByName('edtHigh').AsString := edtHigh.Text;
  aStorage.FieldByName('edtEntryCnt').AsString := edtEntryCnt.Text;


  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code;
end;

procedure TFrmInvestor.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  aGrade : TAmountGradeItem;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  with sgInfo do
  begin
    stTxt := Cells[ ACol, ARow];
    aGrade := Objects[ACol, ARow] as TAmountGradeItem;
    if aGrade <> nil then
    begin
      if aGrade.Current then
        aBack := HIGHLIGHT_COLOR
      else if aGrade.Entry then
      begin
        if ARow = 0 then
          aBack := LONG_COLOR
        else
          aBack := SHORT_COLOR;
      end;
    end;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TFrmInvestor.sgInvestorDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  with sgInvestor do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
      aBack := clBtnFace
    else
    begin
      if ACol >= 1 then
      begin
        dFormat := DT_VCENTER or DT_RIGHT;
        if ACol = 1 then
          aBack := SHORT_COLOR
        else if ACol = 2 then
          aBack := LONG_COLOR;
      end;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TFrmInvestor.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
begin
  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  with sgOpt do
  begin
    stTxt := Cells[ ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);
    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

end.
