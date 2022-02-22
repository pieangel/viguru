unit FFillLog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, CommCtrl,
  //
  AppTypes, AppConsts, AppUtils, 
  Broadcaster,
  LogCentral, WinCentral, HelpCentral, 
  TradeCentral, AccountStore, OrderStore,
  SymbolStore, ImgList, Menus, Buttons;

type

  TFillLogForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ComboAccount: TComboBox;
    ComboTradeType: TComboBox;
    ComboSymbol: TComboBox;
    ImageList1: TImageList;
    PopFills: TPopupMenu;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    N1: TMenuItem;
    A1: TMenuItem;
    ButtonHelp: TSpeedButton;
    ButtonPrint: TSpeedButton;
    ListFills: TListView;
    ButtonRecovery: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure ComboTradeTypeChange(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure PopFillsPopup(Sender: TObject);
    procedure PopOrdersClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
    procedure ListFillsData(Sender: TObject; Item: TListItem);
    procedure ListFillsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ButtonRecoveryClick(Sender: TObject);
  private
    FFills : TList;
    //
    FAccountFilter : TObject;
    FTradeTypeFilter : TTradeTypes;
    FDerivativeFilter : TDerivativeTypes;
    FSymbolFilter : TSymbolItem;
    //
    procedure InitControls;
    procedure RefreshData;
    function CheckFilter(aFill : TFillItem) : Boolean;
    //
    procedure GroupProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure FillProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    // called by WinCentral
    procedure SetPersistence(Stream : TObject);
    procedure GetPersistence(Stream : TObject);
    procedure CallWorkForm(Sender : TObject);
    //-- Form Move
    procedure WMMove(var aMsg: TMsg); message WM_MOVE;
  public
    { Public declarations }
  end;

implementation

uses FOrder, XPrinter;

{$R *.DFM}

const
  ALL_STATES = [osKseAcpt, osDead, osFullFill, osPartFill, osConfirm];


// 주문 내역에서만 사용한다.
function GetType(OrderType: TOrderType; PositionType : TPositionType) : String;
begin
  Result := '';
  //
  case OrderType of
    otNew :    case PositionType of
                 ptLong : Result := '매수주문';
                 ptShort : Result := '매도주문';
               end;
    otChange : Result := '정정주문';
    otCancel : Result := '취소주문';
  end;
end;

function ListCompare(Item1, Item2 : Pointer) : Integer;
var
  aFill1, aFill2 : TFillItem;
begin
  try
    aFill1 := TFillItem(Item1);
    aFill2 := TFillItem(Item2);

    Result := - CompareStr(FormatDateTime('hh:nn:ss',aFill1.FillTime),
      FormatDateTime('hh:nn:ss', aFill2.FillTime));

    if Result = 0 then
      Result := aFill2.Order.SrvNo - aFill1.Order.SrvNo;
  except
    Result := 0;
  end;

end;



//------------------< Called by WinCentral >-------------------------//

procedure TFillLogForm.SetPersistence(Stream : TObject);
begin
end;

procedure TFillLogForm.GetPersistence(Stream : TObject);
begin
end;

procedure TFillLogForm.CallWorkForm(Sender : TObject);
begin
  if Sender = nil then Exit;

end;

//---------------------< Engine Events >--------------------------//

// 그룹변경
procedure TFillLogForm.GroupProc(Sender, Receiver : TObject; DataObj : TObject;
              iBroadcastKind : Integer; btValue : TBroadcastType);
var
  iP : Integer;
  aGroup : TGroupItem;
  aObj : TObject;
begin
  if (Receiver <> Self) or (iBroadcastKind <> OID_GROUP) then
  begin
    gLog.Add(lkError, '계좌창', '주문정보', 'Data Integrity Failure');
    Exit;
  end;
  //
  aGroup := DataObj as TGroupItem;
  //
  if btValue = btNew then // 그룹추가
  begin
    aObj := ComboAccount.Items.Objects[ComboAccount.ItemIndex];
    ComboAccount.Items.Clear;
    gTrade.AccountStore.PopulateCombo(
                                  ComboAccount.Items, [ctAccount, ctGroup]);
    SetCombo(aObj, ComboAccount);
  end else
  begin
    iP := ComboAccount.Items.IndexOfObject(aGroup);
    if iP < 0 then Exit;
    //
    if ComboAccount.ItemIndex = iP  then
      case btValue of
        btUpdate : // 계좌내역 변경
          ComboAccountChange(ComboAccount);
        btDelete : // 그룹삭제 --> Close this window
          begin
            ShowMessage('현재조회중인 펀드가 삭제되었습니다.'#13 +
                        '주문내역 화면을 닫습니다.');
            Close;
          end;
        btRefresh : // 승수 및 명칭변경
          begin
            ComboAccount.Items.Strings[iP] := aGroup.Title;
            ComboAccount.ItemIndex := iP;
          end;
      end
    else
      case btValue of
        btUpdate : ; // 계좌내역 변경 -- no op
        btDelete : // 그룹삭제
               ComboAccount.Items.Delete(iP);
        btRefresh : // 승수 및 명칭변경
               ComboAccount.Items.Strings[iP] := aGroup.Title;
      end
  end;
end;

// (private)
// <-- called from TTraderCentral when a fill has arrived
// populate list or update list
//
procedure TFillLogForm.FillProc(Sender, Receiver : TObject; DataObj : TObject;
              iBroadcastKind : Integer; btValue : TBroadcastType);
var
  iP : Integer;
  aFill : TFillItem;
begin
  if (Receiver <> Self) or (DataObj = nil) or not (DataObj is TFillItem) or
     (iBroadcastKind <> OID_FILL) then
  begin
    gLog.Add(lkError, '체결내역창', '체결정보', 'Data Integrity Failure');
    Exit;
  end;
  //
  aFill := DataObj as TFillItem;
  //
  case btValue of
    btNew :
      if CheckFilter(aFill) then
      begin
        FFills.Insert(0, aFill);
        ListFills.Items.Insert(0);
        AddSymbolCombo2(aFill.Order.Symbol, ComboSymbol);
      end;
    btUpdate :
      if CheckFilter(aFill) then
      begin
        iP := FFills.IndexOf(aFill);
        if iP < 0 then
        begin
          FFills.Insert(0, aFill);
          ListFills.Items.Insert(0);
          AddSymbolCombo2(aFill.Order.Symbol, ComboSymbol);
        end;

        ListFills.Refresh;
      end;
    btRefresh :
      ListFills.Refresh;
  end;
end;

//--------------------< Private Methods : Helpers >-----------------//

function TFillLogForm.CheckFilter(aFill : TFillItem) : Boolean;
begin
  Result :=
     ( // 계좌
      (FAccountFilter = nil) or
      ((FAccountFilter <> nil) and (FAccountFilter is TGroupItem) and
       ((FAccountFilter as TGroupItem).Find(aFill.Order.Account) >= 0)) or
      ((FAccountFilter <> nil) and (FAccountFilter is TAccountItem) and
       (FAccountFilter = aFill.Order.Account))
     ) and
     (aFill.Order.TradeType in FTradeTypeFilter) // 매매구분
       and
     ( // 종목
      (aFill.Order.Symbol.DerivativeType in FDerivativeFilter) and
      ((FSymbolFilter = nil) or
       ((FSymbolFilter <> nil) and (aFill.Order.Symbol = FSymbolFilter)))
     );
end;

procedure TFillLogForm.RefreshData;
begin
  FFills.Clear;
  ListFills.Items.Clear;
  //
  gTrade.OrderStore.GetAllFills(Self, FillProc);
  //

  FFills.Sort(ListCompare);
  ListFills.Refresh;
end;

//-------------------------< UI Events : Form >---------------------//

procedure TFillLogForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFillLogForm.FormCreate(Sender: TObject);
begin
  //==========(Wincentral Feedback)===========//
  if gWin.OpenPeer <> nil then
  with gWin.OpenPeer do
  begin
    // OnSetData -- not used here 
    OnGetPersistence := GetPersistence;
    OnSetPersistence := SetPersistence;
    OnCallWorkForm := CallWorkForm;
  end;
  //==========================================//
  
  FFills := TList.Create;
  //
  InitControls;
  //
  with gTrade.Broadcaster do
  begin
    Subscribe(OID_Group,[btNew,btUpdate,btDelete,btRefresh], Self, GroupProc);
    SubScribe(OID_Fill, [btNew,btUpdate,btRefresh], Self, FillProc);
  end;
end;

procedure TFillLogForm.FormDestroy(Sender: TObject);
begin
  //
  gTrade.Broadcaster.Unsubscribe(Self);
  //
  FFills.Free;
  //
end;

procedure TFillLogForm.InitControls;
begin
  //-- 계좌
  gTrade.AccountStore.PopulateCombo(
                         ComboAccount.Items, [ctGroup, ctAccount]);
  ComboAccount.Items.Insert(0, '전체');
  ComboAccount.ItemIndex := 0;
  FAccountFilter := nil;
  //-- 매매구분
  ComboTradeType.ItemIndex := 0; // 전체
  FTradeTypeFilter := [ttLong, ttShort{, ttLongExit, ttShortExit}];
  //-- 종목
  ComboSymbol.ItemIndex := 0; // 전체
  FDerivativeFilter := [dtFutures, dtOptions];
  FSymbolFilter := nil;
  //--
  ComboAccountChange(ComboAccount);
end;

//----------------------< UI Events : Selectiong >----------------------//


// 계좌선택
procedure TFillLogForm.ComboAccountChange(Sender: TObject);
begin
  if ComboAccount.ItemIndex = 0 then
    FAccountFilter := nil
  else
    FAccountFilter :=
      ComboAccount.Items.Objects[ComboAccount.ItemIndex];
  //
  RefreshData;
end;

// 매매구분
procedure TFillLogForm.ComboTradeTypeChange(Sender: TObject);
begin
  case ComboTradeType.ItemIndex of
    0 : // 전체
      FTradeTypeFilter := [ttLong, ttShort];
    1 : // 신규매도
      FTradeTypeFilter := [ttShort];
    2 : // 신규매수
      FTradeTypeFilter := [ttLong];
  end;
  //
  RefreshData;
end;

// 종목구분
procedure TFillLogForm.ComboSymbolChange(Sender: TObject);
begin
  case ComboSymbol.ItemIndex of
    0 : // 전체
      begin
        FDerivativeFIlter := [dtFutures,dtOptions];
        FSymbolFilter := nil;
      end;
    1 : // 선물
      begin
        FDerivativeFilter := [dtFutures];
        FSymbolFilter := nil;
      end;
    2 : // 옵션
      begin
        FDerivativeFilter := [dtOptions];
        FSymbolFilter := nil;
      end;
    else
      begin
        FDerivativeFilter := [dtFutures, dtOptions];
        FSymbolFilter :=
           ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbolItem;
      end;
  end;
  //
  RefreshData;
end;

//---------------------< UI Events : Menu >-------------------//

procedure TFillLogForm.PopFillsPopup(Sender: TObject);
begin
  if (ListFills.Selected = nil) or
     (ListFills.Selected.Data = nil) then Abort;
end;

procedure TFillLogForm.PopOrdersClick(Sender: TObject);
var
  aFill : TFillItem;
  aForm : TForm;
begin
  if ListFills.Selected = nil then Exit;
  //
  aFill := TFillItem(ListFills.Selected.Data);
  if aFill = nil then Exit;
  //
  case (Sender as TMenuItem).Tag of
    210 : // 계좌정보
      gWin.OpenForm(ID_Account, aFill.Order.Account, nil);
    310 : ;// 종목챠트
    320 : // 종목현재가
      gWin.OpenForm(ID_PRICE, nil, aFill.Order.Symbol);
  end;
end;

procedure TFillLogForm.ButtonHelpClick(Sender: TObject);
begin
  gHelp.Show(ID_FILLLOG);
end;

procedure TFillLogForm.WMMove(var aMsg: TMsg);
begin
  gWin.ModifyWorkspace;
end;


procedure TFillLogForm.ButtonPrintClick(Sender: TObject);
begin
  NeoPrinter.PrintForm(Self);
end;

procedure TFillLogForm.ListFillsData(Sender: TObject; Item: TListItem);
var
  aFill : TFillItem;
begin
  if Item.Index > FFills.Count-1 then exit;

  aFill := TFillItem(FFills.Items[Item.Index]);

  Item.Caption := FormatDateTime('hh:nn:ss', aFill.FillTime);  // 체결시각
  Item.Data := aFill;
  Item.SubItems.Clear;

  //
  Item.SubItems.Add(aFill.Order.Account.Description);          // 계좌
  Item.SubItems.Add(aFill.Order.Symbol.Desc);                  // 종목
  if aFill.Order.PositionType = ptLong then                    // L/S
    Item.SubItems.Add('L')
  else
    Item.SubItems.Add('S');
  //
  Item.SubItems.Add(IntToStr(aFill.Order.SrvNo));              // 주문접수번호
  Item.SubItems.Add(IntToStr(aFill.FillQty));                  // 체결수량
  Item.SubItems.Add(Format('%.*f' ,
          [aFill.Order.Symbol.Precision, aFill.FillPrice] ));  // 체결가
end;

procedure TFillLogForm.ListFillsDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aRefreshItem : TRefreshItem;
  aFontColor : TColor ;
  aListView : TListView;
begin
  if Item.Data = nil then Exit;

  aListView := Sender as TListView;
  aRefreshItem := TRefreshItem(Item.Data);
  Rect.Bottom := Rect.Bottom-1;
  //
  with aListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR2;
      Font.Color := clBlack;
    end else
    if not aRefreshItem.Refreshed then
    begin
      Brush.Color := HIGHLIGHT_COLOR;
      Font.Color := clBlack;
    end else
    begin
      Font.Color := clBlack;
      if Item.Index mod 2 = 1 then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end;

    //-- background
    FillRect(Rect);

    //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;

    //-- caption
    if Item.Caption <> '' then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(aListView.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption);

    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= aListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(aListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      case aListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(aListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(aListView.Handle,i+1) - 2 - aSize.cx;
      end;

      aFontColor := Font.Color ;

      if Item.SubItems[i] = 'L' then
        Font.Color := clRed
      else if Item.SubItems[i] = 'S' then
        Font.Color := clBlue;
      
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(aListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);

      Font.Color := aFontColor;
    end;
  end;
end;

procedure TFillLogForm.ButtonRecoveryClick(Sender: TObject);
begin
  gTrade.StartRecovery;
end;

end.
