unit FleOrderList;

interface

uses
  Windows, Messages, SysUtils, Variants, Graphics, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CleAccounts, GleLib,
    // lemon: common
  LemonEngine,
    // lemon: trade
  CleTradeCore, CleOrders, CleTradeBroker, GleConsts,
    // lemon: utils
  CleDistributor, Menus, CleMarkets, CleFQN, Grids, Controls, Classes,
  CleStorage, CleSymbols;
const
  ORDER_COUNT = 14;
  ORDER_TITLE : array [0..ORDER_COUNT-1] of string = (
                '', '주문번호','LS','계좌', '종목명','원주문','수량',
                '주문가격','체결가격','접수','체결','취소','상태','접수시간'
                );
  ORDER_WIDTH : array [0..ORDER_COUNT-1] of integer = (
                20, 50, 40, 100, 180, 50, 50, 70, 80, 50, 50, 50, 60, 70);
type
  TFillerState = ( fsAcpt, fsFill, fsDead, fsAll);
  TMyGrid = class( TStringGrid );
  TOrderListForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    cbAcnt: TComboBox;
    popFilter: TPopupMenu;
    N1: TMenuItem;
    n2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    sgOrder: TStringGrid;
    refreshTimer: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbGroupSelect(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure sgOrderDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure refreshTimerTimer(Sender: TObject);
    procedure cbAcntSelect(Sender: TObject);
    procedure cbCodeSelect(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgOrderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgOrderDblClick(Sender: TObject);

  private
    FEngine: TLemonEngine;
    FFutureMarket: TFutureMarket;
    FState : array [TFillerState] of boolean;
    procedure SetEngine(const Value: TLemonEngine);
    procedure TradeBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  public
    FUpdate : boolean;
    FRowUpdate : integer;
    FRow : integer;
    procedure InsertLine(line : integer);
    procedure DeleteLine(line : Integer);
    procedure DrawGrid(aOrder: TOrder);
    procedure CheckOrderList(aOrder: TOrder);
    procedure ClearGrid();
    procedure OrgOrderDelete(strOrgNum : string; strCode : string);
    procedure OrderListInit();
    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
    function Find(aOrder : TOrder) : integer;
    procedure UpdateGrid(aOrder: TOrder);
    procedure DrawUpdate(ARow : integer; bDraw : boolean);
    procedure AvgPrice(aOrder : TOrder; ARow : Integer);
    property Engine: TLemonEngine read FEngine write SetEngine;
    procedure ReLoad;
  end;

var
  FrmOrderList2: TOrderListForm;


implementation

{$R *.dfm}
uses GAppEnv;
procedure TOrderListForm.AvgPrice(aOrder: TOrder; ARow: Integer);
var
  iCnt, i, iDiv : integer;
  aResult : TOrderResult;
  dTotPrice, dAvgPrice, dCnt : Double;
begin
  iCnt := aOrder.Results.Count;
  dTotPrice := 0;
  iDiv := 0;
  for i := 0 to iCnt - 1 do
  begin
    aResult := aOrder.Results.Items[i];
    if aResult.ResultType = orFilled then
    begin
      dTotPrice := dTotPrice + aResult.Price;
      inc(iDiv);
    end;
  end;
  dCnt := iDiv;
  if iDiv <> 0 then
    dAvgPrice := dTotPrice/dCnt
  else
    dAvgPrice := 0;
  sgOrder.Cells[8,ARow] :=Format('%.*n', [aOrder.Symbol.Spec.Precision,dAvgPrice]);
end;

procedure TOrderListForm.cbAcntSelect(Sender: TObject);
begin
  ClearGrid();       //그리드 초기화
  OrderListInit();   //주문리스트 초기화 및 셋팅
end;

procedure TOrderListForm.cbCodeSelect(Sender: TObject);
begin
  ClearGrid();
  OrderListInit();
end;

procedure TOrderListForm.cbGroupSelect(Sender: TObject);
begin
  ClearGrid();
  OrderListInit();
end;

procedure TOrderListForm.CheckOrderList(aOrder: TOrder);
begin
  if FState[fsAll] = false then
  begin
    if (FState[fsAcpt])then
    begin
      case aOrder.State of
        osActive: DrawGrid(aOrder);
        osFailed,
        osConfirmed:
        begin
          OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name)); //주문 삭제
          if aOrder.Target <> nil then
            OrgOrderDelete(IntToStr(aOrder.Target.OrderNo),Trim(aOrder.Symbol.Name)); //원주문 삭제
        end;
        osSrvRjt,
        osRejected,
        osFilled: OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name));  //체결시 그리드에서 active주문 삭제
      end;
    end;

    if (FState[fsfill]) and (aOrder.State = osFilled) then
        DrawGrid(aOrder);

    if (FState[fsDead]) then begin
      if aOrder.State in [osCanceled, osRejected] then
        DrawGrid(aOrder);
      end;
  end else
  begin
    case aOrder.State of
      osCanceled,
      osActive: DrawGrid(aOrder);
      osFailed,
      osSrvRjt,
      osRejected,
      osConfirmed:
      begin
        OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name)); //주문 삭제
        if aOrder.Target <> nil then
          OrgOrderDelete(IntToStr(aOrder.Target.OrderNo),Trim(aOrder.Symbol.Name)); //원주문 삭제
        DrawGrid(aOrder);
      end;

      osFilled:
      begin
        OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name));  //체결시 그리드에서 active주문 삭제
        DrawGrid(aOrder);
      end;
    end;
  end;
  sgOrder.TopRow := 1;
end;

procedure TOrderListForm.ClearGrid;
var
  i, j : integer;
begin
  for i := 1 to sgOrder.RowCount - 1 do
  begin
    for j := 0 to sgOrder.ColCount - 1 do
    begin
      sgOrder.Cells[j,i] := '';
      sgOrder.Objects[0,i] := nil;
      sgOrder.Objects[1,i] := nil;
    end;
  end;
  sgOrder.RowCount := 2;
end;

procedure TOrderListForm.DeleteLine(line: Integer);
var
  i : integer;
begin
  with sgOrder do begin
    if sgOrder.RowCount = 2 then
    begin
      for i := 0 to ORDER_COUNT - 1 do
      begin
        Cells[i,line] := '';

      end;
      sgOrder.Objects[0,1] := nil;
      sgOrder.Objects[1,1] := nil;
    end else
    begin
      TMyGrid(sgOrder).DeleteRow(line);
      Rows[rowcount].Clear;
    end;
  end;
end;

procedure TOrderListForm.DrawGrid(aOrder: TOrder);
var
  iCount, iCol : Integer;
  p : TOrderResult;
  strTime, strOrderDiv : string;
  begin
    if sgOrder.Cells[1,1] <> '' then
      InsertLine(1);
    iCol := 1;
    sgOrder.Cells[iCol, 1] := IntToStr(aOrder.OrderNo);       inc(iCol);    // order no
    sgOrder.Cells[iCol, 1] := aOrder.OrderTypeDesc;           inc(iCol);    // order type

    sgOrder.Cells[iCol, 1] := aOrder.Account.Code;            inc(iCol);    // account
    sgOrder.Cells[iCol, 1] := Trim(aOrder.Symbol.Name);       inc(iCol);    // symbol
    if aOrder.Target <> nil then begin                                      // target order no
      sgOrder.Cells[iCol, 1] := IntToStr(aOrder.Target.OrderNo);
    end else begin
      sgOrder.Cells[iCol, 1] := '';
    end;                                                      inc(iCol);
    sgOrder.Cells[iCol, 1] := IntToStr(aOrder.RealQty);       inc(iCol);    // order qty
    case aOrder.PriceControl of                                             // price or price-control
    pcLimit: sgOrder.Cells[iCol, 1] := Format('%.*n', [aOrder.Symbol.Spec.Precision, aOrder.Price]);
    pcMarket,
    pcLimitToMarket,
    pcBestLimit: sgOrder.Cells[iCol, 1] := aOrder.PriceControlDesc;
    else
      sgOrder.Cells[iCol, 1] := '';
    end;                                                      inc(iCol);
    sgOrder.Cells[iCol, 1] :=  Format('%.*n', [aOrder.Symbol.Spec.Precision,aOrder.FilledPrice]);    inc(iCol);    // FillPrice
    sgOrder.Cells[iCol, 1] := IntToStr(aOrder.ActiveQty);     inc(iCol);    // active qty
    if aOrder.OrderType = otNormal then                                     // filled qty or confirmed qty
    begin
      sgOrder.Cells[iCol, 1] := IntToStr(aOrder.FilledQty);   inc(iCol);
      sgOrder.Cells[iCol, 1] := IntToStr(aOrder.CanceledQty); inc(iCol);
    end else
    begin
      sgOrder.Cells[iCol, 1] := IntToStr(aOrder.ConfirmedQty);inc(iCol);
      sgOrder.Cells[iCol, 1] := '';                           inc(iCol);
    end;

    sgOrder.Cells[iCol, 1] := aOrder.StateDesc;               inc(iCol);    // state

    if aOrder.State = osSent then
      strTime := FormatDateTime('hh:nn:ss',aOrder.SentTime)
    else if aOrder.State = osActive then
      strTime := FormatDateTime('hh:nn:ss',aOrder.AcptTime)
    else begin
      iCount := aOrder.Results.Count-1;
      if iCount >= 0 then begin
        p := TOrderResult( aOrder.Results.Items[iCount] );
        strTime := FormatDateTime('hh:nn:ss', p.ResultTime);
      end;
    end;
    sgOrder.Cells[iCol, 1] := strTime;                        inc(iCol);    // time

    sgOrder.Cells[iCol, 1] := strOrderDiv;
    sgOrder.Objects[0,1] := aOrder;
    if aOrder.Results.Count > 1 then
      sgOrder.Objects[1,1] := TObject(0);
  sgOrder.Repaint;
end;

procedure TOrderListForm.DrawUpdate(ARow: integer; bDraw : boolean);
var
  aOrder : TOrder;
  iCol, iRow, iCnt, i, j, iFillQty : integer;
  aResult : TOrderResult;
  strOrderDiv, strTime, strType, strPrice, strQty : string;
  dPrice : Double;
  bQty : boolean;
begin
  FRowUpdate := -1;
  aOrder := TOrder(sgOrder.Objects[0,ARow]);
  if aOrder = nil then exit;
  iCnt := aOrder.Results.Count;
  ARow :=  ARow + 1;
  iRow := 0;
  //bDraw = true 면 전체 // Draw = false면 특정 행 Draw
  if bDraw then
  begin
    for i := 0 to iCnt - 1 do
    begin
      bQty := true;
      aResult := aOrder.Results.Items[i];
      iCol := 8;
      if i <> 0 then
      begin
        strPrice := Format('%.*n', [aOrder.Symbol.Spec.Precision, aResult.Price]);
        for j := ARow to ARow + iRow do
        begin
          if sgOrder.Objects[0, j] = nil then
          begin
            if strPrice = sgOrder.Cells[8, j] then                       //동일가격일때 해당 행 체결수량 업데이트
            begin
              strQty := sgOrder.Cells[10, j];
              iFillQty := StrToInt(strQty);
              sgOrder.Cells[10,j] := IntToStr(iFillQty + aResult.Qty);
              bQty := false;
              break;
            end;
          end;
        end;
      end;

      if bQty then                                                    //신규행 추가
      begin
        InsertLine(ARow + iRow);
        sgOrder.Cells[iCol, ARow + iRow] :=  Format('%.*n', [aOrder.Symbol.Spec.Precision, aResult.Price]);
        inc(iCol);// FillPrice
        inc(iCol);// active qty
        if aResult.ResultType = orFilled then
          sgOrder.Cells[iCol, ARow + iRow] := IntToStr(aResult.Qty);          // filled qty or confirmed qty
        inc(iCol);

        if (aResult.ResultType = orCanceledOut) or (aResult.ResultType = orChangedOut) then
          sgOrder.Cells[iCol, ARow + iRow] := IntToStr(aResult.Qty);          // filled qty or confirmed qty
        inc(iCol);
        case aResult.ResultType of
          orFilled : strType := 'orFilled';
          orConfirmed : strType := 'orConfirmed';
          orChangedOut : strType := 'orChangedOut';
          orCanceledOut : strType := 'orCanceledOut';
          orBooted : strType := 'orBooted';
        end;
        sgOrder.Cells[iCol, ARow + iRow] := strType;                             inc(iCol);// state
        if strType = 'orFilled' then
          strTime := FormatDateTime('nn:ss', aResult.ResultTime)
        else
          strTime := FormatDateTime('hh:nn:ss', aResult.ResultTime);
        sgOrder.Cells[iCol, ARow + iRow] := strTime;                        inc(iCol);    // time
        inc(iRow);
      end;
    end;
  end else
  begin
    aResult := aOrder.Results.Items[iCnt-1];
    strPrice := Format('%.*n', [aOrder.Symbol.Spec.Precision, aResult.Price]);
    for i := ARow to  sgOrder.RowCount - 1  do
    begin
      if strPrice = sgOrder.Cells[8, i] then                       //동일가격일때 해당 행 체결수량 업데이트
      begin
        strQty := sgOrder.Cells[10, i];
        iFillQty := StrToInt(strQty);
        sgOrder.Cells[10,i] := IntToStr(iFillQty + aResult.Qty);
        FRowUpdate := i;
        AvgPrice(aOrder, ARow-1);
        exit;
      end;
      if sgOrder.Objects[0,i] <> nil then break;
    end;

    InsertLine(ARow);
    iCol := 8;
    sgOrder.Cells[iCol, ARow] :=  Format('%.*n', [aOrder.Symbol.Spec.Precision, aResult.Price]);
    inc(iCol);// FillPrice
    inc(iCol);// active qty
    if aResult.ResultType = orFilled then
      sgOrder.Cells[iCol, ARow] := IntToStr(aResult.Qty);          // filled qty or confirmed qty
    inc(iCol);

    if (aResult.ResultType = orCanceledOut) or (aResult.ResultType = orChangedOut) then
      sgOrder.Cells[iCol, ARow] := IntToStr(aResult.Qty);          // filled qty or confirmed qty
     inc(iCol);
    case aResult.ResultType of
      orFilled : strType := 'orFilled';
      orConfirmed : strType := 'orConfirmed';
      orChangedOut : strType := 'orChangedOut';
      orCanceledOut : strType := 'orCanceledOut';
      orBooted : strType := 'orBooted';
    end;
    sgOrder.Cells[iCol, ARow] := strType;                             inc(iCol);// state
    if strType = 'orFilled' then
          strTime := FormatDateTime('nn:ss', aResult.ResultTime)
        else
          strTime := FormatDateTime('hh:nn:ss', aResult.ResultTime);
    sgOrder.Cells[iCol, ARow] := strTime;                        inc(iCol);    // time
    FRowUpdate := ARow;
  end;
  AvgPrice(aOrder, ARow-1);                                                    //평균체결가 계산
end;

function TOrderListForm.Find(aOrder : TOrder) : integer;
var
  i : integer;
  pOrder : TOrder;
begin
  Result := -1;
  for i := 1 to sgOrder.RowCount - 1 do
  begin
    pOrder := TOrder(sgOrder.Objects[0,i]);
    if pOrder = nil then continue;
    if aOrder = pOrder then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TOrderListForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TOrderListForm.FormCreate(Sender: TObject);
var
  i : integer;
begin
  FUpdate := false;
  FRowUpdate := -1;
  for i := 0 to ORDER_COUNT - 1 do
  begin
    sgOrder.Cells[i,0] := ORDER_TITLE[i];
    sgOrder.ColWidths[i] := ORDER_WIDTH[i];
  end;
end;

procedure TOrderListForm.FormDestroy(Sender: TObject);
begin
  if FEngine <> nil then
    FEngine.TradeBroker.Unsubscribe(Self);
end;

procedure TOrderListForm.InsertLine(line: integer);
begin
  with sgOrder do begin
    RowCount := Succ( RowCount );
    TMyGrid( sgOrder ).MoveRow( ( RowCount - 1 ), line );
    Rows[line].Clear;
  end;
end;

procedure TOrderListForm.N1Click(Sender: TObject);
var
  iTag, i,j : integer;
  bCheck : boolean;
  pList : TList;
  aOrder : TOrder;
begin
  iTag :=  TMenuItem( Sender ).Tag;

  bCheck := not TMenuItem( Sender ).Checked;
  TMenuItem( Sender ).Checked := bCheck;

  case iTag of
  0 :
    begin
      if bCheck then
      begin
        N4.Checked := false;
        FState[fsAll] := false;
      end;
      FState[fsAcpt] := bCheck;
    end;
  10:
    begin
      if bCheck then
      begin
        N4.Checked := false;
        FState[fsAll] := false;
      end;
      FState[fsFill] := bCheck;
    end;
  20:
    begin
      if bCheck then
      begin
        N4.Checked := false;
        FState[fsAll] := false;
      end;
      FState[fsDead] := bCheck;
    end;
  30:
    begin
      if bCheck then
      begin
        N1.Checked := false;
        N2.Checked := false;
        N3.Checked := false;
        FState[fsAcpt] := false;
        FState[fsFill] := false;
        FState[fsDead] := false;
      end;
      FState[fsAll] := bCheck;
    end;
  end;
  ClearGrid();
  OrderListInit();
end;

procedure TOrderListForm.OrderListInit;
var
  i, j, iCnt : integer;
  aOrder : TOrder;
  strCode, strAcnt : string;
  pList : TList;
  aResult : TOrderResult;
begin
  // 해당 주문리스트 화면에 디스플레이
  sgOrder.PerForm(WM_SETREDRAW,0,0);
  for i := 0 to FEngine.TradeCore.Orders.Count - 1 do
  begin
    aOrder := TOrder(FEngine.TradeCore.Orders.Items[i]);
    strAcnt := cbAcnt.Items.Strings[cbAcnt.ItemIndex];
    if strAcnt <> aOrder.Account.Code then continue;
    CheckOrderList(aOrder);
  end;
  sgOrder.PerForm(WM_SETREDRAW,1,0);
  sgOrder.Repaint;
end;

procedure TOrderListForm.OrgOrderDelete(strOrgNum: string; strCode : string);
var
  i : integer;
begin
  for i := 0 to sgOrder.RowCount - 1 do
  begin
    if (sgOrder.Cells[1,i] = strOrgNum) and (sgOrder.Cells[4,i] = strCode)  then
    begin
        DeleteLine(i);
        break;
    end;
  end;
end;

procedure TOrderListForm.refreshTimerTimer(Sender: TObject);
begin
  if FRowUpdate >0 then
  begin
    FRowUpdate := -1;
    Fupdate := false;
    sgOrder.Repaint;
  end;
end;

procedure TOrderListForm.ReLoad;
begin
  //SetEngine( gEnv.Engine );

  if FEngine = nil then exit;
  cbAcnt.Clear;
  FEngine.TradeCore.Accounts.GetList(cbAcnt.Items);

  if cbAcnt.Items.Count > 0 then
    cbAcnt.ItemIndex := 0;
  ClearGrid;
  OrderListInit;
end;

procedure TOrderListForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('ComboAcnt').AsInteger := cbAcnt.ItemIndex;
end;

procedure TOrderListForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  cbAcnt.ItemIndex := aStorage.FieldByName('ComboAcnt').AsInteger;
end;


procedure TOrderListForm.sgOrderDblClick(Sender: TObject);
var
  iCnt : integer;
  aOrder : TOrder;
  iExpand : integer;
  i: Integer;
begin
  if (FRow < 0) then exit;

  aOrder := TOrder(sgOrder.Objects[0,FRow]);
  if aOrder = nil then exit;
  if aOrder.Results.Count > 0 then
  begin
    iExpand := Integer(sgOrder.Objects[1,FRow]);
    if iExpand = 0 then
    begin
      sgOrder.Objects[1,FRow] := TObject(1);
      DrawUpdate(FRow, true);
    end
    else if iExpand = 1 then
    begin
      sgOrder.Objects[1,FRow] := TObject(0);
      iCnt := aOrder.Results.Count;

      for i := FRow to sgOrder.RowCount - 1 do
      begin
        iCnt := sgOrder.RowCount;
        if FRow = iCnt-1 then break;
        if sgOrder.Cells[6,FRow + 1] <> '' then break;           //다음주문전까지 Delete
        DeleteLine(FRow + 1);
        sgOrder.Repaint;
      end;
    end;
  end;
end;

procedure TOrderListForm.sgOrderDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  strData : string;
  rRect, rRect1 : TRect;
  dtFormat : Word;
  iLeft, iRight, iHeight, iRow : integer;
  aOrder : TOrder;
  iExpand : integer;
begin
  strData := sgOrder.Cells[ACol, ARow];
  dtFormat := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  sgOrder.Canvas.Font.Color :=  clBlack;

  if ACol in [6,7,8,9,10,11] then
  begin
    dtFormat := DT_RIGHT;
    rRect.Right := rRect.Right - 5 ;
  end;

  if ACol = 2 then  //Type
  begin
    if strData = 'Buy' then
      sgOrder.Canvas.Font.Color :=  clRed
    else if strData = 'Sell' then
      sgOrder.Canvas.Font.Color :=  clBlue;
  end;

  if FRowUpdate = ARow then
  begin
    sgOrder.Canvas.Font.Style := sgOrder.Canvas.Font.Style + [ fsBold ];
    sgOrder.Canvas.Brush.Color :=  clWebYellow;
  end else
  begin
    sgOrder.Canvas.Brush.Color :=  clwhite;
    if (( ARow mod 2 ) = 0 ) and (ARow > 0) then
    sgOrder.Canvas.Brush.Color :=  $F0F0F0;
  end;

  sgOrder.Canvas.FillRect(Rect);
  rRect.Top := rRect.Top + 5;
  DrawText( sgOrder.Canvas.Handle,  PChar( strData ), Length( strData ), rRect, dtFormat );

  aOrder := TOrder(sgOrder.Objects[0, ARow]);
  if aOrder = nil then exit;
  if (aOrder.Results.Count > 0) then
  begin
    if (ACol = 0) and (ARow > 0) then
    begin
      sgOrder.Canvas.Pen.Color := clBlue;
      // 사각형
      sgOrder.Canvas.MoveTo(Rect.Left + 4,Rect.Top + 4);
      sgOrder.Canvas.LineTo(Rect.Right - 4, Rect.Top + 4);
      sgOrder.Canvas.LineTo(Rect.Right - 4, Rect.Bottom - 4);
      sgOrder.Canvas.LineTo(Rect.Left + 4, Rect.Bottom - 4);
      sgOrder.Canvas.LineTo(Rect.Left + 4, Rect.Top + 4);
      iExpand := Integer(sgOrder.Objects[1,ARow]);
      if iExpand = 0 then
      begin
        // 세로
        iLeft := (Rect.Right - Rect.Left) Div 2;
        sgOrder.Canvas.MoveTo(iLeft,Rect.Top + 6);
        sgOrder.Canvas.LineTo(iLeft, Rect.Bottom - 5);
      end;

      // 가로
      iRight := (sgOrder.RowHeights[ARow]) Div 2;
      iRight := Rect.Top + iRight;
      sgOrder.Canvas.MoveTo(Rect.Left + 6, iRight );
      sgOrder.Canvas.LineTo(Rect.Right - 5, iRight);
    end;
  end;
end;

procedure TOrderListForm.sgOrderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  iCol, iRow, iCnt : integer;
  aOrder : TOrder;
  iExpand : integer;
  i: Integer;
begin
  sgOrder.MouseToCell(X,Y, iCol, iRow);
  FRow := iRow;
  if (iRow < 0) then exit;
end;

procedure TOrderListForm.SetEngine(const Value: TLemonEngine);
begin
  if Value = nil then Exit;

  FEngine := Value;
  FEngine.TradeBroker.Subscribe(Self, TradeBrokerEventHandler);
  FState[fsAcpt] := true;
  FEngine.TradeCore.Accounts.GetList(cbAcnt.Items);
  if cbAcnt.Items.Count > 0 then
    cbAcnt.ItemIndex := 0;

  OrderListInit();
end;

procedure TOrderListForm.TradeBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iID, i, iCnt : Integer;
  aOrder, aOrgOrder : TOrder;
  pList : TList;
  strAcnt, a : string;
  aResult : TOrderResult;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  if Integer(EventID) in [101..107] then  begin
    aOrder := TOrder(DataObj);
    if aOrder = nil then exit;
    strAcnt := cbAcnt.Items.Strings[cbAcnt.ItemIndex];
    if strAcnt <> aOrder.Account.Code then exit;
    FRowUpdate := 1;

    iCnt := aOrder.Results.Count;
    if iCnt > 0 then
    begin
      aResult := aOrder.Results.Items[iCnt-1];
      case aResult.ResultType of
        orFilled :
        begin
          if (aOrder.OrderQty <> aResult.Qty) then
          begin
            UpdateGrid(aOrder);
          end;
        end;
        orChangedOut,
        orCanceledOut :
        begin
          if aOrder.State <> osFilled then
            UpdateGrid(aOrder);
        end;
      end;
    end;
    CheckOrderList(aOrder);
  end;
end;

procedure TOrderListForm.UpdateGrid(aOrder: TOrder);
var
  iExpand, iRow, iRRow, iCnt : integer;
  i: Integer;
  aResult : TOrderResult;
begin
  iRow := Find(aOrder);

  iCnt := aOrder.Results.Count;
  if iRow = -1  then
  begin
    iRow := 0;
  end else
  begin
    iExpand := Integer(sgOrder.Objects[1,iRow]);

    if iExpand = 1 then
    begin
      aResult := aOrder.Results.Items[iCnt-1];
      DrawUpdate(iRow,false);
      FUpdate := true;
    end else if iExpand = 0 then
    begin
      aResult := aOrder.Results.Items[iCnt-1];
      if (aOrder.State = osActive) and (aResult.ResultType = orFilled) then
        OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name));
      AvgPrice(aOrder, iRow);
      FRowUpdate := iRow;
      FUpdate := true;
    end;
  end;

  if aOrder.State = osFilled then  //부분체결이 전체체결이 될때
  begin
    if iExpand = 1 then            //전체체결시 확장된 Result Delete
    begin
      for i := iRow to sgOrder.RowCount - 1 do
      begin
        if sgOrder.Objects[0,iRow + 1] <> nil then break;           //다음주문전까지 Delete
        DeleteLine(iRow+1);
        sgOrder.Repaint;
      end;
    end;
    sgOrder.Objects[1,iRow] := nil;
    sgOrder.Objects[0,iRow] := nil;
    if FState[fsAll] = false then
    begin
      if (FState[fsAcpt])then
        OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name));  //체결시 그리드에서 active주문 삭제
      if (FState[fsfill]) then
        DrawGrid(aOrder);
    end else
    begin
      OrgOrderDelete(IntToStr(aOrder.OrderNo),Trim(aOrder.Symbol.Name));
      DrawGrid(aOrder);
    end;
  end;

  if aOrder.State = osCanceled then
  begin
    sgOrder.Objects[1,iRow] := nil;
    sgOrder.Objects[0,iRow] := nil;
  end;

  sgOrder.TopRow := 1;
end;

end.
