unit FlePositionListup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,
    // lemon: common
  LemonEngine,
    // lemon: trade
  CleTradeCore, ClePositions, GleConsts, CleQuoteBroker, CleAccounts,
    // lemon: utils
  CleListViewPeer, CleDistributor, CleFilltering, StdCtrls, ExtCtrls, Grids,
  CleStorage;
const
 FutPart = 0.5;
 OptPart = 2;
 DATA_FORMAT = '#,##0';
 GridTitle : array[0..12] of string =
    ('계좌번호', '계좌명', '종목코드', '종목명', '포지션', '평균단가', '평가손익',
     '수익률', '순손익', '매수', '매도','L관여','S관여');

type
  TPositionListupForm = class(TForm)
    Panel1: TPanel;
    cbAcnt: TComboBox;
    Panel2: TPanel;
    cbIssue: TComboBox;
    Panel3: TPanel;
    cbPos: TCheckBox;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    statOte: TStaticText;
    statPL: TStaticText;
    statTotPL: TStaticText;
    Timer1: TTimer;
    sgPos: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure cbAcntChange(Sender: TObject);
    procedure cbPosClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sgPosDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgPosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgPosDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure sgPosDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    FEngine: TLemonEngine;
    FAccount  : TAccount;
    FSelectRow : integer;
    FDragRow : integer;
    procedure TradeBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure SetEngine(const Value: TLemonEngine);
    procedure AddPosition( aPosition : TPosition );
    procedure UpdatePosition( aPosition : TPosition );
    procedure DeletePosition( aPosition : TPosition );
    procedure UpdateGridData(aPosition : TPosition; iRow : integer);
    procedure ClearGrid;
    procedure UpdateEntryOTE;
    function GetColor( stData : string ) : TColor;


  public
    FFillter : TFillter;
    FDataList : TList;
    property Engine: TLemonEngine read FEngine write SetEngine;
    procedure ComboBoxInit;
    procedure SetDataList;
    procedure CalcPL;
    function CheckPosition(aPosition : TPosition) : Boolean;
    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);

  end;

var
  PositionListupForm: TPositionListupForm;

implementation

uses GAppEnv, FOrderBoard, GleLib;

{$R *.dfm}

procedure TPositionListupForm.AddPosition(aPosition: TPosition);
var
  iRow : integer;
begin
  iRow := sgPos.RowCount - 1;
  insertLine( sgPos , sgPos.RowCount -1 );
  UpdateGridData(aPosition, iRow);
end;

procedure TPositionListupForm.CalcPL;
var
  i, j : integer;
  dEntryPL, dEntryOte, dTot, dFee : double;

  aAcnt : TAccount;
  dSumTot , dSumEntryOte, dSumEntryPL : double;
begin
  if FEngine = nil then exit;
  if cbAcnt.ItemIndex = 0 then
  begin
    dSumTot := 0;
    dSumEntryOte := 0;
    dSumEntryPL := 0;
    for i := 1 to cbAcnt.Items.Count - 1 do
    begin
      aAcnt := cbAcnt.Items.Objects[i] as TAccount;
      dEntryOte := 0.0;
      dEntryPL := 0.0;
      dTot := 0.0;
      dFee := 0.0;
      gEnv.Engine.TradeCore.Positions.GetMarketTotPl( aAcnt, dTot, dEntryOte, dEntryPL  );
      dSumEntryOte := dSumEntryOte + dEntryOte;
      dSumEntryPL := dSumEntryPL + dTot - aAcnt.GetFee;
      dSumTot := dSumTot + dTot;
    end;
    statOTE.Caption := Format('%.0n', [dSumEntryOte]);               //평가손익
    statPL.Caption := Format('%.0n', [dSumEntryPL]);                 //순손익(총손익 - 수수료)
    statTotPL.Caption := Format('%.0n',[dSumTot]);                   //총손익
  end else
  begin
    if FAccount = nil then exit;
    dEntryOte := 0.0;
    dEntryPL := 0.0;
    dTot := 0.0;
    dFee := 0.0;
    FEngine.TradeCore.Positions.GetMarketTotPl( FAccount, dTot, dEntryOte, dEntryPL );
    statOTE.Caption := Format('%.0n', [dEntryOte]);               //평가손익
    statPL.Caption := Format('%.0n', [dTot - FAccount.GetFee]);   //순손익(총손익 - 수수료)
    statTotPL.Caption := Format('%.0n',[dTot]);                   //총손익
  end;

  statOTE.Font.Color := GetColor(statOTE.Caption);
  statPL.Font.Color := GetColor(statPL.Caption);
  statTotPL.Font.Color := GetColor(statTotPL.Caption);
end;


procedure TPositionListupForm.cbAcntChange(Sender: TObject);
var
  aAcnt : TAccount;
  iTag : integer;
begin
  aAcnt := GetComboObject( cbAcnt ) as TAccount;
  if (cbAcnt.ItemIndex > 0) and ( aAcnt = nil )then exit;
  iTag := (Sender as TComboBox).Tag;
  if (iTag = 10) and (aAcnt = FAccount) then exit;
  FAccount := aAcnt;
  SetDataList;
end;

procedure TPositionListupForm.cbPosClick(Sender: TObject);
begin
  SetDataList;
end;

function TPositionListupForm.CheckPosition(aPosition: TPosition): Boolean;
var
  bContinue : boolean;
  stAcnt : string;
begin
  Result := false;
  if (not cbPos.Checked) and (aPosition.Volume = 0) then exit;

  if cbAcnt.ItemIndex = 0 then
    stAcnt := ACNT_TOT
  else
    stAcnt := FAccount.Code;
  FFillter.SetFillterData( stAcnt , cbIssue.ItemIndex);
  bContinue := FFillter.Fillter(aPosition);
  if not bContinue then exit;
  Result := true;
end;

procedure TPositionListupForm.ClearGrid;
var
  iRow, iCol : integer;
begin
  for iRow := 1 to sgPos.RowCount - 1 do
  begin
    sgPos.Objects[0, iRow] := nil;
    for iCol := 0 to sgPos.ColCount - 1 do
      sgPos.Cells[iCol, iRow] := '';
  end;
end;

procedure TPositionListupForm.ComboBoxInit;
var
  i : integer;
begin
  FEngine.TradeCore.Accounts.GetList(cbAcnt.Items);

  cbAcnt.Items.Insert(0, ACNT_TOT);
  if cbAcnt.Items.Count = 1 then
    cbAcnt.ItemIndex := 0
  else if cbAcnt.Items.Count > 1 then
    cbAcnt.ItemIndex := 1;

  for i := 0 to MARKET-1 do
    cbIssue.Items.Add(MarketType[i]);
  if cbIssue.Items.Count > 0 then
  begin
    cbIssue.ItemIndex := 0;
    cbAcntChange( cbAcnt );
  end;
end;

procedure TPositionListupForm.DeletePosition(aPosition: TPosition);
var
  iRow : integer;
begin
  iRow := sgPos.Cols[0].IndexOfObject(aPosition);
  if iRow < 1 then exit;
  if sgPos.RowCount <= 2 then
    ClearGrid
  else
    DeleteLine(sgPos, iRow);
end;

procedure TPositionListupForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPositionListupForm.FormCreate(Sender: TObject);
var
  i : integer;
begin
  FFillter := TFillter.Create;
  FDataList := TList.Create;
  FSelectRow := -1;
  FDragRow := -1;
  for i := 0 to sgPos.ColCount-1 do
    sgPos.Cells[i,0] := GridTitle[i];
end;

procedure TPositionListupForm.FormDestroy(Sender: TObject);
begin
  if FEngine <> nil then
  begin
    FEngine.TradeBroker.Unsubscribe(Self);
    FEngine.QuoteBroker.Cancel(Self);
  end;

  FDataList.Free;
end;

function TPositionListupForm.GetColor(stData: string): TColor;
var
  stM : string;
begin
  Result := clBlack;
  stM := Copy(stData,1,1);

  if stM = '-' then
    Result := clBlue
  else
  begin
    if stM = '0' then
      Result := clBlack
    else
      Result := clRed;
  end;
end;

procedure TPositionListupForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  cbAcnt.ItemIndex := aStorage.FieldByName('cbAcnt').AsInteger;
  cbIssue.ItemIndex := aStorage.FieldByName('cbIssue').AsInteger;
  cbAcntChange(cbAcnt);
end;

procedure TPositionListupForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('cbAcnt').AsInteger := cbAcnt.ItemIndex;
  aStorage.FieldByName('cbIssue').AsInteger := cbIssue.ItemIndex;
end;

procedure TPositionListupForm.SetDataList;
var
  aPos : TPositions;
  aPosition : TPosition;
  i, iRet : integer;
  bCon : Boolean;
begin
  FDataList.Clear;

  sgPos.RowCount := 2;

  ClearGrid;

  aPos := FEngine.TradeCore.Positions;

  if aPos.PosList.Count = 0 then
  begin
    for i := 0 to aPos.Count - 1 do
    begin
      aPosition := TPosition(aPos.Items[i]);
      if cbAcnt.ItemIndex > 0 then
        if aPosition.Account <> FAccount then  Continue;

      bCon := CheckPosition(aPosition);
      if bCon then
      begin
        FDataList.Add(aPosition);
        AddPosition(aPosition);
      end;
    end;
  end else
  begin
    for i := 0 to aPos.PosList.Count - 1 do
    begin
      aPosition := aPos.PosList.Items[i];

      bCon := CheckPosition(aPosition);
      if bCon then
      begin
        FDataList.Add(aPosition);
        AddPosition(aPosition);
      end;
    end;

    for i := 0 to aPos.Count - 1 do
    begin
      aPosition := TPosition(aPos.Items[i]);
      if cbAcnt.ItemIndex > 0 then
        if aPosition.Account <> FAccount then Continue;

      bCon := CheckPosition(aPosition);

      if bCon then
      begin
        iRet := FDataList.IndexOf(aPosition);
        if iRet < 0 then
        begin
          FDataList.Add(aPosition);
          AddPosition(aPosition);
        end;
      end;
    end;
  end;
end;

procedure TPositionListupForm.SetEngine(const Value: TLemonEngine);
begin
  if Value = nil then Exit;

  FEngine := Value;
  FEngine.TradeBroker.Subscribe(Self, TradeBrokerEventHandler);

  ComboBoxInit;  // Combo 초기화
  SetDataList;   // Tlist 초기화
end;

procedure TPositionListupForm.sgPosDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i, iSelIndex, iDropIndex, iCol : integer;
  aPosition : TPosition;
  aPos : TPositions;
  aItem : TListItem;
begin
  if Sender = Source then
  begin
    try
      sgPos.MouseToCell( X, Y, iCol, FDragRow);
      if FSelectRow = FDragRow then exit;
      aPos := FEngine.TradeCore.Positions;
      iSelIndex := FSelectRow - 1;
      iDropIndex := FDragRow - 1;
      if (iSelIndex < 0) or (iSelIndex > FDataList.Count - 1)  then exit;
      if (iDropIndex < 0) or (iDropIndex > FDataList.Count - 1)  then exit;
      aPos.PosList.Clear;
      for i := 0 to FDataList.Count - 1 do
      begin
        aPosition := FDataList.Items[i];
        aPos.PosList.Add(aPosition);
      end;
      FDataList.Exchange(iSelIndex, iDropIndex);
      aPos.PosList.Exchange(iSelIndex, iDropIndex);

      //바꿔주기
      aPosition := FDataList.Items[iDropIndex];
      UpdateGridData(aPosition , FDragRow);

      aPosition := FDataList.Items[iSelIndex];
      UpdateGridData(aPosition , FSelectRow);
    finally

    end;
  end;
end;

procedure TPositionListupForm.sgPosDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = sgPos;
end;

procedure TPositionListupForm.sgPosDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt, stM : string;
  dFormat : Word;
begin

  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_RIGHT;

  with sgPos do
  begin
    stTxt := Cells[ ACol, ARow];
    if ARow < 1 then
    begin
      aBack   := clBtnFace;
      dFormat := DT_VCENTER or DT_CENTER;
    end else
    begin
      if ACol <= 3 then
        dFormat := DT_VCENTER or DT_CENTER
      else
      begin
        if (ACol in [4,6,8]) then             //4 포지션, 6 평가손익, 8 순손익
          aFont := GetColor(stTxt);

        if ACol = 7 then
        begin
          stM := Copy(stTxt, 1, 1);
          if stM = '-' then
            aFont := clBlue
          else
          begin
            if stTxt <> '0.00%' then
              aFont := clRed;
          end;
        end;

        if ACol = 9 then
            aFont := clRed;
        if ACol = 10 then
            aFont := clblue;
      end;
    end;
    if ARow = FSelectRow then
      aBack := $00F2BEB9;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TPositionListupForm.sgPosMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    ARow, ACol : integer;
begin
  sgPos.MouseToCell( X, Y, ACol, FSelectRow);
  sgPos.Repaint;
  if (ssLeft in Shift) then
    sgPos.BeginDrag(true,0);
end;

procedure TPositionListupForm.Timer1Timer(Sender: TObject);
begin
  CalcPL;
  UpdateEntryOTE;
end;

procedure TPositionListupForm.TradeBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aPosition : TPosition;
  bCon : boolean;
  iRet : integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;
  case EventID of
    POSITION_NEW:
    begin
      aPosition := DataObj as TPosition;
      if (cbAcnt.ItemIndex > 0) and (FAccount <> aPosition.Account) then exit;
      bCon := CheckPosition(aPosition);
      if bCon then
      begin
        FDataList.Add(aPosition);
        AddPosition(DataObj as TPosition);
      end;
    end;
    POSITION_UPDATE:
    begin
      aPosition := DataObj as TPosition;
      if (cbAcnt.ItemIndex > 0) and (FAccount <> aPosition.Account) then exit;
      iRet := FdataList.IndexOf(aPosition);
      bCon := CheckPosition(aPosition);
      if (iRet = -1) and (bCon) then
      begin
        FDataList.Add(aPosition);
        AddPosition(DataObj as TPosition);
      end else
        if (aPosition.Volume = 0) and ( not bCon) then
        begin
          FDataList.Remove(aPosition);
          DeletePosition( aPosition );
        end;
      if bCon then
        UpdatePosition( DataObj as TPosition);
    end;
  end;
end;

procedure TPositionListupForm.UpdateEntryOTE;
var
  i : integer;
  aPos : TPosition;
begin
  for i := 1 to sgPos.RowCount - 1 do
  begin
    aPos := sgPos.Objects[0,i] as TPosition;
    if aPos = nil then continue;

    sgPos.Cells[6, i] := Format('%.0n', [aPos.EntryOTE]);          //평가손익
    if aPos.Volume = 0 then
      sgPos.Cells[7, i] := Format('%.2n%s', [0.00,'%'])
    else
      sgPos.Cells[7, i] := Format('%.2n%s', [aPos.ProfitChg,'%']); //수익률

    sgPos.Cells[8, i] := Format('%.0n',
    [aPos.EntryOTE + aPos.EntryPL - aPos.PosTrace.LastHis.Fee]);   //순손익
  end;
end;

procedure TPositionListupForm.UpdateGridData(aPosition: TPosition;
  iRow: integer);
var
  iPrec : integer;
begin
  iPrec := aPosition.Symbol.Spec.Precision;

  sgPos.Cells[0, iRow] := aPosition.Account.Code;                        // 계좌번호
  sgPos.Cells[1, iRow] := aPosition.Account.Name;                        // 계좌명
  sgPos.Cells[2, iRow] := aPosition.Symbol.ShortCode;                    // 종목코드
  sgPos.Cells[3, iRow] := aPosition.Symbol.Name;                         // 종목명
  sgPos.Cells[4, iRow] := IntToStr(aPosition.Volume);                    // 포지션
  sgPos.Cells[5, iRow] := Format('%.*n', [iPrec, aPosition.AvgPrice]);   // 평균단가
  sgPos.Cells[6, iRow] := Format('%.0n', [aPosition.EntryOTE]);          // 평가손익

  if aPosition.Volume = 0 then
    sgPos.Cells[7, iRow] := Format('%.2n%s', [0.00,'%'])
  else
    sgPos.Cells[7, iRow] := Format('%.2n%s', [aPosition.ProfitChg,'%']); //수익률

  sgPos.Cells[8, iRow] := Format('%.0n',
    [aPosition.EntryOTE + aPosition.EntryPL - aPosition.PosTrace.LastHis.Fee]); // 순손익

  sgPos.Cells[9, iRow] := IntToStr(aPosition.ActiveBuyOrderVolume);      // 매수미체결
  sgPos.Cells[10, iRow] := IntToStr(aPosition.ActiveSellOrderVolume);    // 매도 미체결
  sgPos.Cells[11, iRow] := Format('%.1f%s', [ aPosition.BidParticipation, '%']);
  sgPos.Cells[12, iRow] := Format('%.1f%s', [ aPosition.AskParticipation, '%']);
  sgPos.Objects[0,iRow] := TObject(aPosition);
end;

procedure TPositionListupForm.UpdatePosition(aPosition: TPosition);
var
  iRow : integer;
begin
    iRow := sgPos.Cols[0].IndexOfObject(aPosition);
  if iRow >= 1 then
    UpdateGridData(aPosition, iRow);
end;

end.
