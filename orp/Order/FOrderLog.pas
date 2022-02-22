unit FOrderLog;

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

  function GetType(OrderType: TOrderType; PositionType : TPositionType) : String;

type

  TOrderLogForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ComboAccount: TComboBox;
    ComboTradeType: TComboBox;
    ComboSymbol: TComboBox;
    ComboState: TComboBox;
    ListOrders: TListView;
    ImageList1: TImageList;
    PopOrders: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    N1: TMenuItem;
    A1: TMenuItem;
    ButtonHelp: TSpeedButton;
    ButtonPrint: TSpeedButton;
    ButtonRecovery: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure ComboTradeTypeChange(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure ComboStateChange(Sender: TObject);
    procedure ListOrdersData(Sender: TObject; Item: TListItem);
    procedure ListOrdersDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListOrdersDblClick(Sender: TObject);
    procedure PopOrdersPopup(Sender: TObject);
    procedure PopOrdersClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
    procedure ButtonRecoveryClick(Sender: TObject);
  private
    FOrders : TList;
    //
    FAccountFilter : TObject;
    FTradeTypeFilter : TTradeTypes;
    FDerivativeFilter : TDerivativeTypes;
    FSymbolFilter : TSymbolItem;
    FStateFilter : set of TOrderState;
    //
    procedure InitControls;
    procedure RefreshData;
    function CheckFilter(aOrder : TOrderItem) : Boolean;
    //
    procedure GroupProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure OrderProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure ResultProc(Sender, Receiver : TObject; DataObj : TObject;
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


// �ֹ� ���������� ����Ѵ�.
function GetType(OrderType: TOrderType; PositionType : TPositionType) : String;
begin
  Result := '';
  //
  case OrderType of
    otNew :    case PositionType of
                 ptLong : Result := '�ż�';
                 ptShort : Result := '�ŵ�';
               end;
    otChange : Result := '����';
    otCancel : Result := '���';
  end;
end;



//------------------< Called by WinCentral >-------------------------//

procedure TOrderLogForm.SetPersistence(Stream : TObject);
begin
end;

procedure TOrderLogForm.GetPersistence(Stream : TObject);
begin
end;

procedure TOrderLogForm.CallWorkForm(Sender : TObject);
begin
  if Sender = nil then Exit;

end;

//---------------------< Engine Events >--------------------------//

// �׷캯��
procedure TOrderLogForm.GroupProc(Sender, Receiver : TObject; DataObj : TObject;
              iBroadcastKind : Integer; btValue : TBroadcastType);
var
  iP : Integer;
  aGroup : TGroupItem;
  aObj : TObject;
begin
  if (Receiver <> Self) or (iBroadcastKind <> OID_GROUP) then
  begin
    gLog.Add(lkError, '����â', '�ֹ�����', 'Data Integrity Failure');
    Exit;
  end;
  //
  aGroup := DataObj as TGroupItem;
  //
  if btValue = btNew then // �׷��߰�
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
        btUpdate : // ���³��� ����
          ComboAccountChange(ComboAccount);
        btDelete : // �׷���� --> Close this window
          begin
            ShowMessage('������ȸ���� �ݵ尡 �����Ǿ����ϴ�.'#13 +
                        '�ֹ����� ȭ���� �ݽ��ϴ�.');
            Close;
          end;
        btRefresh : // �¼� �� ��Ī����
          begin
            ComboAccount.Items.Strings[iP] := aGroup.Title;
            ComboAccount.ItemIndex := iP;
          end;
      end
    else
      case btValue of
        btUpdate : ; // ���³��� ���� -- no op
        btDelete : // �׷����
               ComboAccount.Items.Delete(iP);
        btRefresh : // �¼� �� ��Ī����
               ComboAccount.Items.Strings[iP] := aGroup.Title;
      end
  end;
end;

// �ֹ�����
procedure TOrderLogForm.OrderProc(Sender, Receiver : TObject; DataObj : TObject;
              iBroadcastKind : Integer; btValue : TBroadcastType);
var
  iP : Integer;
  aOrder : TOrderItem;
begin
  if (Receiver <> Self) or (DataObj = nil) or not (DataObj is TOrderItem) or
     (iBroadcastKind <> OID_ORDER) then
  begin
    gLog.Add(lkError, '����â', '�ֹ�����', 'Data Integrity Failure');
    Exit;
  end;
  //
  aOrder := DataObj as TOrderItem;
  //
  case btValue of
    btNew :
      if CheckFilter(aOrder) then
      begin
        FOrders.Insert(0, aOrder);
        ListOrders.Items.Insert(0);
        AddSymbolCombo2(aOrder.Symbol, ComboSymbol);
      end;
    btUpdate :
      begin
        iP := FOrders.IndexOf(aOrder);
        if iP >= 0 then
          if not CheckFilter(aOrder) then
          begin
            //
            FOrders.Delete(iP);
            ListOrders.Items.Delete(iP);
            //-- clear following results
            while True do
            if (iP >= FOrders.Count) or
               (TObject(ListOrders.Items[iP].Data) is TOrderItem) then
               Break
            else
            begin
              FOrders.Delete(iP);
              ListOrders.Items.Delete(iP);
            end;
            ListOrders.Items.Count := FOrders.Count;
          end else
           ListOrders.Refresh
        else
        if CheckFilter(aOrder) then
        begin
          FOrders.Insert(0, aOrder);
          ListOrders.Items.Insert(0);
          AddSymbolCombo2(aOrder.Symbol, ComboSymbol);
        end;
      end;
    btRefresh :
      ListOrders.Refresh;
  end;
end;

// Ȯ��/ü��
procedure TOrderLogForm.ResultProc(Sender, Receiver : TObject; DataObj : TObject;
                    iBroadcastKind : Integer; btValue : TBroadcastType);
var
  iP : Integer;
  aResult : TOrderResultItem;
  aOrder : TOrderItem;

begin
  if (Receiver <> Self) or (DataObj = nil) or 
     not (iBroadcastKind in [OID_CONFIRM, OID_FILL]) then
  begin
    gLog.Add(lkError, '�ֹ�����â', 'Ȯ��', 'Data Integrity Failure');
    Exit;
  end;
  //
  aResult := DataObj as TOrderResultItem;
  aOrder := aResult.Order;
  //
  iP := FOrders.IndexOf(aOrder);
  if (iP < 0) or
     not ListOrders.Items[iP].Checked // collapsed
  then Exit;
  //
  case btValue of
    btNew :
      begin
        FOrders.Insert(iP+1, aResult);
        ListOrders.Items.Insert(iP+1);
      end;
    btUpdate :
      if FOrders.IndexOf(aResult) >= 0 then
        ListOrders.Refresh;
    btRefresh :
      ListOrders.Refresh;
  end;
end;


//--------------------< Private Methods : Helpers >-----------------//

function TOrderLogForm.CheckFilter(aOrder : TOrderItem) : Boolean;
begin
  Result :=
     ( // ����
      (FAccountFilter = nil) or
      ((FAccountFilter <> nil) and (FAccountFilter is TGroupItem) and
       ((FAccountFilter as TGroupItem).Find(aOrder.Account) >= 0)) or
      ((FAccountFilter <> nil) and (FAccountFilter is TAccountItem) and
       (FAccountFilter = aOrder.Account))
     ) and
     (aOrder.TradeType in FTradeTypeFilter) // �Ÿű���
       and
     ( // ����
      (aOrder.Symbol.DerivativeType in FDerivativeFilter) and
      ((FSymbolFilter = nil) or
       ((FSymbolFilter <> nil) and (aOrder.Symbol = FSymbolFilter)))
     ) and
     (aOrder.State in FStateFilter);
end;

procedure TOrderLogForm.RefreshData;
begin
  FOrders.Clear;
  ListOrders.Items.Clear;
  //
  gTrade.OrderStore.GetAll(Self, OrderProc);
  //
end;

//-------------------------< UI Events : Form >---------------------//

procedure TOrderLogForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TOrderLogForm.FormCreate(Sender: TObject);
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
  
  FOrders := TList.Create;
  //
  InitControls;
  //
  with gTrade.Broadcaster do
  begin
    Subscribe(OID_Group,[btNew,btUpdate,btDelete,btRefresh], Self, GroupProc);
    Subscribe(OID_Order,[btNew,btUpdate,btRefresh], Self, OrderProc);
    SubScribe(OID_Fill, [btNew,btUpdate,btRefresh], Self, ResultProc);
    Subscribe(OID_Confirm, [btNew,btRefresh], Self, ResultProc);
  end;
end;

procedure TOrderLogForm.FormDestroy(Sender: TObject);
begin
  //
  gTrade.Broadcaster.Unsubscribe(Self);
  //
  FOrders.Free;
  //
end;

procedure TOrderLogForm.InitControls;
begin
  //-- ����
  gTrade.AccountStore.PopulateCombo(
                         ComboAccount.Items, [ctGroup, ctAccount]);
  ComboAccount.Items.Insert(0, '��ü');
  ComboAccount.ItemIndex := 0;
  FAccountFilter := nil;
  //-- �Ÿű���
  ComboTradeType.ItemIndex := 0; // ��ü
  FTradeTypeFilter := [ttLong, ttShort{, ttLongExit, ttShortExit}];
  //-- ����
  ComboSymbol.ItemIndex := 0; // ��ü
  FDerivativeFilter := [dtFutures, dtOptions];
  FSymbolFilter := nil;
  //-- ����
  ComboState.ItemIndex := 0; // ��ü
  FStateFilter := ALL_STATES;
  //--
  ComboAccountChange(ComboAccount);
end;

//----------------------< UI Events : Selectiong >----------------------//

// ���¼���
procedure TOrderLogForm.ComboAccountChange(Sender: TObject);
begin
  if ComboAccount.ItemIndex = 0 then
    FAccountFilter := nil
  else
    FAccountFilter :=
      ComboAccount.Items.Objects[ComboAccount.ItemIndex];
  //
  RefreshData;
end;

// �Ÿű���
procedure TOrderLogForm.ComboTradeTypeChange(Sender: TObject);
begin
  case ComboTradeType.ItemIndex of
    0 : // ��ü
      FTradeTypeFilter := [ttLong, ttShort];
    1 : // �űԸŵ�
      FTradeTypeFilter := [ttShort];
    2 : // �űԸż�
      FTradeTypeFilter := [ttLong];
  end;
  //
  RefreshData;
end;

// ���񱸺�
procedure TOrderLogForm.ComboSymbolChange(Sender: TObject);
begin
  case ComboSymbol.ItemIndex of
    0 : // ��ü
      begin
        FDerivativeFIlter := [dtFutures,dtOptions];
        FSymbolFilter := nil;
      end;
    1 : // ����
      begin
        FDerivativeFilter := [dtFutures];
        FSymbolFilter := nil;
      end;
    2 : // �ɼ�
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

// ���±���
procedure TOrderLogForm.ComboStateChange(Sender: TObject);
begin
  case ComboState.ItemIndex of
    0 : // ��ü
      FStateFilter := ALL_STATES;
    1 : // ��ü��
      FStateFilter := [osKseAcpt, osPartFill];
    2 : // ����ü��
      FStateFilter := [osFullFill];
    3 : // ���Ȯ��
      FStateFilter := [osConfirm];
    4 : // osDead
      FStateFilter := [osDead];
  end;
  //
  RefreshData;
end;

//--------------------< UI Events : ListView >-----------------------//

procedure TOrderLogForm.ListOrdersData(Sender: TObject; Item: TListItem);
var
  aObj : TObject;
  i : Integer;
  dFillPrice : Double;
  stFillPrice : String ;
begin


  {
    ���� 
  // 0.����
  // 1.����
  // 2.����
  // 3.������ȣ
  // 4.����
  // 5.�ֹ���
  // 6.ü�ᷮ
  // 7.�ֹ�����
  // 8.��������

  if Item.Index >= FOrders.Count then Exit;
  //
  aObj := TObject(FOrders.Items[Item.Index]);
  //
  Item.Data := aObj;
  
  if aObj is TOrderItem then
  with aObj as TOrderItem do
  begin
    Item.Checked := (Item.Index + 1 < FOrders.Count) and
                    not (TObject(FOrders.Items[Item.Index+1]) is TOrderItem);
    // image
    if ResultCount = 0 then
      Item.ImageIndex := 0
    else
    if Item.Checked then
      Item.ImageIndex := 2
    else
      Item.ImageIndex := 1;
    //
    Item.Caption := Account.AccountName; // ����
    Item.SubItems.Add(Symbol.ShortDesc);  // �����
    Item.Subitems.Add(TypeDesc); // �ֹ�����
    if OrgOrder <> nil then // ������ȣ
      Item.SubItems.Add(Format('%d(%d)',[SrvNo,OrgOrder.SrvNo]))
    else
      Item.SubItems.Add(IntToStr(SrvNo));
    if OrderType = otCancel then // ����
      Item.SubItems.Add('')
    else
    case PriceType of
      ptMarket :    Item.SubItems.Add('M');
      ptCondition : Item.SubItems.Add(Format('C%.2f',[Price]));
      ptBestPrice : Item.SubItems.Add('B');
      else
        Item.SubItems.Add(Format('%.2f',[Price]));
    end;
    Item.SubItems.Add(IntToStr(Qty));      // �ֹ���
    Item.SubItems.Add(IntToStr(FillQty));  // ü�ᷮ
    Item.SubItems.Add(StateDesc); // �ֹ�����
    Item.SubItems.Add(PriceTypeDescs[PriceType]);
  end else
  if aObj is TConfirmItem then
  with aObj as TConfirmItem do
  begin
    Item.ImageIndex := 3;
    Item.Caption := '';
    Item.SubItems.Add('');
    if ResultType = orChange then  // ����
      Item.SubItems.Add('����')
    else
      Item.SubItems.Add('���');
    Item.SubItems.Add(IntToStr(SrvNo)); // ������ȣ
    if PriceType = ptMarket then    // ��������
      Item.SubItems.Add('���尡')
    else if ResultType = orChange then
      Item.SubItems.Add(Format('%.2f',[ConfirmPrice]))
    else
      Item.SubItems.Add('');
    Item.SubItems.Add(IntToStr(ReqQty));  // �䱸����
    Item.SubItems.Add(IntToStr(ConfirmQty)); // �� ����/��Ҽ���
    if ConfirmQty = 0 then  // ����
      Item.SubItems.Add('�źε�')
    else
      Item.SubItems.Add('Ȯ�ε�');
  end else
  if aObj is TFillItem then
  with aObj as TFillItem do
  begin
    Item.ImageIndex := 3;
    Item.Caption := '';
    Item.SubItems.Add('');
    Item.SubItems.Add('ü��');
    Item.SubItems.Add('');
    Item.SubItems.Add(Format('%.2f',[FillPrice])); // ü�ᰡ
    Item.SubItems.Add('');
    Item.SubItems.Add(IntToStr(FillQty)); // ü�����
    Item.SubItems.Add(FormatDateTime('hh:nn:ss', FillTime)); // ü��ð�
  end;
  }

  {
  // 0. ����
  // 1. �����ڵ�
  // 2. ����
  // 3. ������ȣ
  // 4. �ֹ���
  // 5. �ֹ���
  // 6. ü�ᰡ
  // 7. ü�ᷮ
  // 8. ��ü��
  // 9. �ֹ�����
  // 10. �ð�
  // 11. ��������
  
  2002.09.19 ���� YHW
  }

  if Item.Index >= FOrders.Count then Exit;
  //
  aObj := TObject(FOrders.Items[Item.Index]);
  //
  Item.Data := aObj;
  
  if aObj is TOrderItem then
  with aObj as TOrderItem do
  begin
    Item.Checked := (Item.Index + 1 < FOrders.Count) and
                    not (TObject(FOrders.Items[Item.Index+1]) is TOrderItem);
    // image
    if ResultCount = 0 then
      Item.ImageIndex := 0
    else
    if Item.Checked then
      Item.ImageIndex := 2
    else
      Item.ImageIndex := 1;
    //
    Item.Caption := Account.AccountName;                            // ����
    Item.SubItems.Add(Symbol.Code);                                 // �����ڵ�
    Item.Subitems.Add(GetType(OrderType, PositionType));            // �ֹ�����
    if OrgOrder <> nil then                                         // ������ȣ
      Item.SubItems.Add(Format('%d(%d)',[SrvNo,OrgOrder.SrvNo]))
    else
      Item.SubItems.Add(IntToStr(SrvNo));
    if OrderType = otCancel then                  // �ֹ���
      Item.SubItems.Add('')
    else
    case PriceType of
      ptMarket :    Item.SubItems.Add('M');
      ptCondition : Item.SubItems.Add(Format('C%.2f',[Price]));
      ptBestPrice : Item.SubItems.Add('B');
      else
        Item.SubItems.Add(Format('%.2f',[Price]));
    end;
    Item.SubItems.Add(IntToStr(Qty));             // �ֹ���

    if  OrderType = otCancel  then     
    begin
      Item.SubItems.Add('');      // ü�ᰡ
      Item.SubItems.Add(IntToStr(FillQty));      // ü�ᷮ
      Item.SubItems.Add('');      // ��ü��
    end
    else              // �� ��
    begin
      dFillPrice :=0 ;
      for i:=0 to ResultCount do
        if Results[i] is TFillItem then
          with Results[i] as TFillItem do
            dFillPrice := dFillPrice + ( FillPrice * FillQty)   ;

      stFillPrice := '';
      if FillQty <> 0 then
        stFillPrice := Format('%.2f',[dFillPrice / FillQty]);

      Item.SubItems.Add(stFillPrice);           // ü�ᰡ ( ü�ᷮ�� 0�̸� ����)
      Item.SubItems.Add(IntToStr(FillQty));     // ü�ᷮ
      Item.SubItems.Add(IntToStr(UnfillQty));   // ��ü��
    end;
   
    Item.SubItems.Add(StateDesc);               // �ֹ�����
    Item.SubItems.Add(FormatDateTime('hh:nn:ss', AcptTime));  // �ð� (���������ð�)           
    Item.SubItems.Add(PriceTypeDescs[PriceType]);             // ��������
    
  end else
  if aObj is TConfirmItem then
  with aObj as TConfirmItem do
  begin
    Item.ImageIndex := 3;
    Item.Caption := '';                       // ����
    Item.SubItems.Add('');                    // �����ڵ�

    if ResultType = orChange then             // ����
      Item.SubItems.Add('����Ȯ��')
    else
      Item.SubItems.Add('���Ȯ��');
    Item.SubItems.Add(IntToStr(SrvNo));       // ������ȣ
    if PriceType = ptMarket then              // �ֹ���(�������� )
      Item.SubItems.Add('���尡')
    else if ResultType = orChange then
      Item.SubItems.Add(Format('%.2f',[ConfirmPrice]))
    else
      Item.SubItems.Add('');
    Item.SubItems.Add(IntToStr(ReqQty));      // �ֹ���(�䱸����)
    Item.SubItems.Add('');                    // ü�ᰡ 
    Item.SubItems.Add(IntToStr(ConfirmQty));  // ü�ᷮ(�� ����/��Ҽ���)
    Item.SubItems.Add('');                    // ��ü��     
    if ConfirmQty = 0 then                    // �ֹ�����
      Item.SubItems.Add('�źε�')
    else
      Item.SubItems.Add('Ȯ�ε�');
    Item.SubItems.Add(FormatDateTime('hh:nn:ss', ArrivedTime));  // �ð� (�ڷ���Žð�)
    Item.SubItems.Add('');                    // ��������

  end else
  if aObj is TFillItem then
  with aObj as TFillItem do
  begin
    Item.ImageIndex := 3;
    Item.Caption := '';                     // ����
    Item.SubItems.Add('');                  // �����ڵ�
    Item.SubItems.Add('ü��');              // ����
    Item.SubItems.Add('');                  // ������ȣ
    Item.SubItems.Add('');                  // �ֹ���
    Item.SubItems.Add('');                  // �ֹ���
    Item.SubItems.Add(Format('%.2f',[FillPrice]));  // ü�ᰡ
    Item.SubItems.Add(IntToStr(FillQty)); // ü�����
    Item.SubItems.Add('');                // ��ü��
    Item.SubItems.Add('');                  // �ֹ�����
    Item.SubItems.Add(FormatDateTime('hh:nn:ss', FillTime));  // ü��ð�
    Item.SubItems.Add('');                  // ��������
  end;

end;

procedure TOrderLogForm.ListOrdersDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aRefreshItem : TRefreshItem;
  bApplyColor : Boolean;
  stText : String;
begin
  if (Item.Data = nil) or
     not (TObject(Item.Data) is TRefreshItem) then Exit;
  //
  Rect.Bottom := Rect.Bottom-1;
  aRefreshItem := TRefreshItem(Item.Data);
  //
  with ListOrders.Canvas do
  begin
      //-- background color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR2;
    end else
    begin
      if not aRefreshItem.Refreshed then
        Brush.Color := HIGHLIGHT_COLOR
      else if Item.Index mod 2 = 1 then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end;

    //-- set default font color
    if (CompareStr(Item.SubItems[8], '�����ֹ�') = 0) or
       (CompareStr(Item.SubItems[8], 'Ȯ�ε�') = 0) then
    begin
      bApplyColor := False;
      Font.Color := clGray;
    end else
    begin
      bApplyColor := True;
      Font.Color := clBlack;
    end;

    //-- background
    FillRect(Rect);
    //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    if (Item.ImageIndex >=0) and (ListOrders.SmallImages <> nil) then
    begin
      // aListView.SmallImages.BkColor := Brush.Color;
      ListOrders.SmallImages.Draw(ListOrders.Canvas, Rect.Left+1, Rect.Top,
                              Item.ImageIndex);
    end;
    //-- caption
    if Item.Caption <> '' then
      if ListOrders.SmallImages = nil then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListOrders.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption)
      else
        TextRect(
            Classes.Rect(Rect.Left + ListOrders.SmallImages.Width,
              Rect.Top, ListView_GetColumnWidth(ListOrders.Handle,0), Rect.Bottom),
            Rect.Left + ListOrders.SmallImages.Width + 2, iY, Item.Caption);
    //-- subitems
    iLeft := Rect.Left;

    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListOrders.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListOrders.Handle,i);

      stText := Item.SubItems[i];

      if stText = '' then Continue;
      aSize := TextExtent(stText);

      case ListOrders.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListOrders.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListOrders.Handle,i+1) - 2 - aSize.cx;
        else iX := iLeft + 2; // redundant coding
      end;

        // font color
      if bApplyColor then
      case i of
        1 : // order type
            if CompareStr(stText, '�ż�') = 0 then
              Font.Color := clRed
            else if CompareStr(stText, '�ŵ�') = 0 then
              Font.Color := clBlue
            else
              Font.Color := clBlack;
        8 : // status
            if CompareStr(stText, '��������') = 0 then
              Font.Color := clBlue
            else if CompareStr(stText, '�κ�ü��') = 0 then
              Font.Color := clMaroon
            else if CompareStr(stText, '����ü��') = 0 then
              Font.Color := clMaroon
            else
              Font.Color := clBlack;
        else
          Font.Color := clBlack;
      end;
          
        // put text
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListOrders.Handle,i+1), Rect.Bottom),
          iX, iY, stText);
    end;
  end;
end;

procedure TOrderLogForm.ListOrdersDblClick(Sender: TObject);
var
  aOrder : TOrderItem;
  aListItem : TListITem;
  i, iP : Integer;
begin
  if (ListOrders.Selected = nil) or (ListOrders.Selected.Data = nil) then Exit;
  //
  aListItem := ListOrders.Selected;
  if not (TObject(aListItem.Data) is TOrderItem) then Exit;
  //
  aOrder := TOrderItem(aListItem.Data);
  if aOrder.ResultCount = 0 then Exit;
  //
  aListItem.Checked := (aListItem.Index + 1 < FOrders.Count) and
                not (TObject(FOrders.Items[aListItem.Index+1]) is TOrderItem);
  //
  iP := FOrders.IndexOf(aOrder)+1;
  //
  if not aListItem.Checked then // collapsed -> expanded
  begin
    aListItem.ImageIndex := 2;
    for i := 0 to aOrder.ResultCount-1 do
    begin
      FOrders.Insert(iP, aOrder.Results[i]);
      ListOrders.Items.Insert(iP);
    end;
  end else // expanded -> collapsed
  begin
    aListItem.ImageIndex := 1;
    while True do
    if (iP >= FOrders.Count) or
       (TObject(ListOrders.Items[iP].Data) is TOrderItem) then
       Break
    else
    begin
      FOrders.Delete(iP);
      ListOrders.Items.Delete(iP);
    end;
  end;
  //
  ListOrders.Items.Count := FOrders.Count;
  ListOrders.Refresh;
end;

//---------------------< UI Events : Menu >-------------------//

procedure TOrderLogForm.PopOrdersPopup(Sender: TObject);
begin
  if (ListOrders.Selected = nil) or
     (ListOrders.Selected.Data = nil) or
     not (TObject(ListOrders.Selected.Data) is TOrderItem) or
     (TOrderItem(ListOrders.Selected.Data).UnfillQty = 0) then Abort;
end;

procedure TOrderLogForm.PopOrdersClick(Sender: TObject);
var
  aOrder : TOrderItem;
  aForm : TForm;
begin
  if ListOrders.Selected = nil then Exit;
  //
  aOrder := TOrderItem(ListOrders.Selected.Data);
  if aOrder = nil then Exit;
  //
  case (Sender as TMenuItem).Tag of
    110 : // �ֹ�����
      if aOrder.UnfillQty > 0 then
      begin
        aForm := gWin.OpenForm(ID_ORDER, nil, nil);
        if aForm <> nil then
        with aForm as TOrderForm do
        begin
          OrderType := otChange;
          Account := aOrder.Account;
          Symbol := aOrder.Symbol;
          OrgOrder := aOrder;
        end;
      end;
    120 : // �ֹ����
      if aOrder.UnfillQty > 0 then
      begin
        aForm := gWin.OpenForm(ID_ORDER, nil, nil);
        if aForm <> nil then
        with aForm as TOrderForm do
        begin
          OrderType := otCancel;
          Account := aOrder.Account;
          Symbol := aOrder.Symbol;
          OrgOrder := aOrder;
        end;
      end;
    210 : // ��������
      gWin.OpenForm(ID_Account, aOrder.Account, nil);
    310 : ;// ����íƮ
    320 : ;// �������簡
  end;
end;

procedure TOrderLogForm.ButtonHelpClick(Sender: TObject);
begin
  gHelp.Show(ID_ORDERLOG);
end;

procedure TOrderLogForm.WMMove(var aMsg: TMsg);
begin
  gWin.ModifyWorkspace;
end;


procedure TOrderLogForm.ButtonPrintClick(Sender: TObject);
begin
  NeoPrinter.PrintForm(Self);
end;

procedure TOrderLogForm.ButtonRecoveryClick(Sender: TObject);
begin
  gTrade.StartRecovery;
end;

end.
