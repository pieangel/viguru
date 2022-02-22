unit FSystemOrder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Menus, Buttons, Grids, CommCtrl, TlHelp32,
  MMSystem,
  // App
  {
  LogCentral,
  AppUtils,  } CleSymbols, GleTypes, cleOrders,GleConsts, CleAccounts, CleFunds,
  SystemIF, OmegaIF,{ TradeCentral,   }
  // data
  Signals, SignalLinks, SignalTargets , {WinCentral , }DSignalConfig,{ Globals,
  XPrinter, HelpCentral, }ImgList{, accountStore, Broadcaster};


type
  TSystemOrderViewType = (vtTarget, vtLink, vtSignal, vtEvent, vtOrder, vtTargetCur);
  TSystemOrderViewTypes = set of TSystemOrderViewType;

  TSystemOrderForm = class(TForm)
    PopLink: TPopupMenu;
    MenuAdd: TMenuItem;
    N2: TMenuItem;
    MenuLinkEdit: TMenuItem;
    MenuLinkDelete: TMenuItem;
    PageSystemOrder: TPageControl;
    TabSheet2: TTabSheet;
    StatusBar: TStatusBar;
    Panel5: TPanel;
    Panel1: TPanel;
    ButtonSave: TSpeedButton;
    ButtonPrint: TSpeedButton;
    ButtonHelp: TSpeedButton;
    SpeedButton1: TSpeedButton;
    BtnConfig: TSpeedButton;
    CheckOrderConnected: TCheckBox;
    CheckDetail: TCheckBox;
    ListTarget: TListView;
    Splitter1: TSplitter;
    TabSheet5: TTabSheet;
    Panel3: TPanel;
    Panel4: TPanel;
    ButtonLinkAdd: TSpeedButton;
    ButtonLinkEdit: TSpeedButton;
    ButtonLinkDelete: TSpeedButton;
    ListLink: TListView;
    Panel6: TPanel;
    ListSignal: TListView;
    Label1: TLabel;
    Splitter2: TSplitter;
    PopSignal: TPopupMenu;
    MenuSignalEdit: TMenuItem;
    MenuSignalDelete: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PopTarget: TPopupMenu;
    MenuTargetEdit: TMenuItem;
    MenuTargetDelete: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    ButtonSync: TSpeedButton;
    ButtonTarget: TSpeedButton;
    TabSheet1: TTabSheet;
    Panel7: TPanel;
    Panel9: TPanel;
    Bevel2: TBevel;
    Label2: TLabel;
    ListOrder: TListView;
    Splitter3: TSplitter;
    Bevel3: TBevel;
    Label3: TLabel;
    ClearTimer: TTimer;
    ButtonSignalAdd: TSpeedButton;
    ButtonSignalEdit: TSpeedButton;
    ButtonSignalDelete: TSpeedButton;
    Bevel4: TBevel;
    PopOrder: TPopupMenu;
    MenuOrder: TMenuItem;
    MenuEFOrder: TMenuItem;
    N3: TMenuItem;
    MenuAccount: TMenuItem;
    MenuOrderList: TMenuItem;
    MenuFillList: TMenuItem;
    N1: TMenuItem;
    MenuCancel: TMenuItem;
    ButtonCancelAll: TSpeedButton;
    ButtonClear: TSpeedButton;
    N4: TMenuItem;
    MenuTargetClear: TMenuItem;
    ImageList1: TImageList;
    ListEvent: TListView;
    MemoLog: TRichEdit;
    ButtonRecovery: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SignalClick(Sender: TObject);
    procedure ListTargetData(Sender: TObject; Item: TListItem);
    procedure ListLinkData(Sender: TObject; Item: TListItem);
    procedure ListSignalData(Sender: TObject; Item: TListItem);
    procedure ListDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListTargetDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);

    procedure SpeedButton1Click(Sender: TObject);
    procedure PopTargetClick(Sender: TObject);
    procedure ListLinkSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListSignalSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure CheckDetailClick(Sender: TObject);
    procedure BtnConfigClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ListLinkDblClick(Sender: TObject);
    procedure ListSignalDblClick(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
    procedure PopLinkClick(Sender: TObject);
    procedure ButtonLinkClick(Sender: TObject);
    procedure ButtonSyncClick(Sender: TObject);
    procedure ButtonTargetClick(Sender: TObject);
    procedure ListEventData(Sender: TObject; Item: TListItem);
    procedure ListOrderData(Sender: TObject; Item: TListItem);
    procedure ClearTimerTimer(Sender: TObject);
    procedure ListOrderDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure PopOrderClick(Sender: TObject);
    procedure PopOrderPopup(Sender: TObject);
    procedure ButtonCancelAllClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure PopTargetPopup(Sender: TObject);
    procedure CheckOrderConnectedClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonRecoveryClick(Sender: TObject);
    procedure ListTargetSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListTargetDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FOmegaIF : TOmegaIF;
    FSignals : TSignals;
    FLinks : TSignalLinks;
    FTargets : TSignalTargets;

    FTargetView : TList{TSignalTargetItem, TSignalLinkItem};
    FDetailView : Boolean;

    procedure ActOnLink(iActIndex : Integer; aListActive : TListView);
    //-- event handlers
      // TOmegaIF events
    procedure LastTimeProc(Sender : TObject);
      // FSignals events
    procedure SignalAdd(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalUpdate(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalRemoved(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalRemoving(Sender : TSystemIF; aSignal : TSignalItem);
    procedure PositionChange(Sender : TSystemIF; aSignal : TSignalItem);
    procedure SignalChange(Sender : TSystemIF; aSignal : TSignalItem; aSymbol : TObject);
    procedure NewOrder(Sender : TSystemIF; aEvent : TSignalEventItem);
      // FTargets events
    procedure TargetUpdate(Sender : TObject);
    procedure ChasingUpdate(Sender : TObject);
      //  accalias event
//    procedure AccAliasProc(Sender, Receiver : TObject; DataObj : TObject;
//      iBroadcastKind : Integer; btValue : TBroadcastType);   LSY 2008-01-02

    //-- misc
    procedure RefreshView(Values : TSystemOrderViewTypes);
    procedure MakeTargetView;
    procedure DoLog(Sender: TObject; stLog: String);
    procedure DoNotify(aEvent : TSignalEventItem);
    procedure SetClearTimer(bEnabled : Boolean);
  public
    { Public declarations }
  end;

var
  SystemOrderForm : TSystemOrderForm;

implementation

{$R *.DFM}

uses FleOrder, DSignalNotify, GAppEnv;

const
  SIGNAL_CONFIG_FILE = 'signalcfg.gsu';

//=====================================================================//
//                         Initialize / Finalize                       //
//=====================================================================//

procedure TSystemOrderForm.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  //==========(Wincentral Feedback)===========//
  {
  if gWin.OpenPeer <> nil then
  with gWin.OpenPeer do
  begin
    //OnSetData := SetData;
    //OnGetPersistence := GetPersistence;
    //OnSetPersistence := SetPersistence;
    //OnCallWorkForm := CallWorkForm;

    IsPersistent := False; // Don't want to be saved in a workspace
  end;
  }
  //==========================================//

  //--1. Create Objects
    //--1.2 signal sources
    FOmegaIF := TOmegaIF.Create; // signals is loaded here.
    FOmegaIF.OnLastTime := LastTimeProc;
    FOmegaIF.OnLog := DoLog; //

    //--1.3 secondary signal source (proxy for all signal sources)
    FSignals := TSignals.Create; // signals are loaded here
      // get signal list
    FSignals.AddIF(FOmegaIF); // signals are gathered from all source here
      // position related
    FSignals.OnAdd := SignalAdd;
    FSignals.OnUpdate := SignalUpdate;
    FSignals.OnRemoved := SignalRemoved;
    FSignals.OnRemoving := SignalRemoving;
    FSignals.OnPositionChange := PositionChange;
    FSignals.OnSignalChange   := SignalChange;

      // order related
    FSignals.OnOrder := NewOrder;

    //--1.4 data manipulators
    FTargetView := TList.Create{TSignalTargetItem, TSignalLinkItem};

    FTargets := TSignalTargets.Create; // TSignalTargetItem
    FTargets.OnLog := DoLog;
    FTargets.OnUpdate := TargetUpdate;
    FTargets.OnChasingUpdate := ChasingUpdate;
    //FTargets.OnAutoTargetState := SetAutoTargetting ;

    FLinks := TSignalLinks.Create; // TSignalLinkItem
    FLinks.Signals := FSignals;
    FLinks.LoadLinks; // account-signal links are loaded here

    for i:=0 to FLinks.Count-1 do
      FTargets.AddLink(FLinks[i]);

  //--2. Make Views
    RefreshView([vtSignal, vtLink, vtTarget]);

  //--3. Connect to the sources
   FOmegaIF.Initialize;
   LastTimeProc(FOmegaIF);

  //--4. Connect to the sources
  CheckOrderConnected.Checked := FTargets.ChasingConfig.Auto;

    //.. logging
    //DoLog(self,'시스템주문 >> 시작');
    //.. logging

  //--5. Set clear timer
  SetClearTimer(FTargets.ChasingConfig.ForcedClear);
  //
//  gTrade.Broadcaster.Subscribe(OID_AccAlias,[btRefresh], Self, AccAliasProc);
end;

procedure TSystemOrderForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

  SystemOrderForm := nil;
end;

procedure TSystemOrderForm.FormDestroy(Sender: TObject);
begin
  //.. logging
  //DoLog(self, '시스템주문 >> 종료');
  //.. logging

  //// 1. file save
  // FLinks.SaveLinks;  // link 저장  commented by CHJ on 2004.5.28

  // 2. free
  gEnv.Engine.TradeBroker.Unsubscribe( self );

  FOmegaIF.Free;
  FTargets.Free;
  FLinks.Free;
  FSignals.Free;
end;

//=====================================================================//
//                          Manage Signal Alias                        //
//=====================================================================//

// (published)
// Popup menu item or A menu button was clicked for the Signal Pane
//
procedure TSystemOrderForm.SignalClick(Sender: TObject);
begin
  if Sender = nil then Exit;

  case (Sender as TComponent).Tag of
    100 : // add
      FOmegaIF.AddSignal;
    200 : // edit
      if ListSignal.Selected <> nil then
        FOmegaIF.EditSignal(TORSignalItem(ListSignal.Selected.Data));
    300 : // delete
      if ListSignal.Selected <> nil then
        FOmegaIF.RemoveSignal(TORSignalItem(ListSignal.Selected.Data));
  end;
end;

procedure TSystemOrderForm.ListSignalDblClick(Sender: TObject);
begin
  SignalClick( ButtonSignalEdit);
end;

//=====================================================================//
//                          Manage Links                               //
//=====================================================================//

procedure TSystemOrderForm.PopTargetPopup(Sender: TObject);
var
  aObject : TObject;
  aTarget : TSignalTargetItem;
begin
  if (ListTarget.Selected <> nil) and (ListTarget.Selected.Data <> nil) then
  begin
    aObject := TObject(ListTarget.Selected.Data);

    MenuTargetEdit.Visible := (aObject is TSignalLinkItem);
    MenuTargetDelete.Visible := MenuTargetEdit.Visible;
    if aObject is TSignalTargetItem then
    begin
      aTarget := aObject as TSignalTargetItem;
      MenuTargetClear.Visible := (aTarget.Position <> nil) and
                                 (aTarget.Position.Volume <> 0);
    end else
      MenuTargetClear.Visible := False;
  end else
  begin
    MenuTargetEdit.Visible := False;
    MenuTargetDelete.Visible := False;
    MenuTargetClear.Visible := False;
  end;
end;

procedure TSystemOrderForm.PopTargetClick(Sender: TObject);
begin
  if Sender = nil then Exit;

  case (Sender as TComponent).Tag of
    100, 200, 300 : ActOnLink((Sender as TComponent).Tag, ListTarget);
    400 : // clear position
      if (ListTarget.Selected <> nil) and
         (ListTarget.Selected.Data <> nil) and
         (TObject(ListTarget.Selected.Data) is TSignalTargetItem) then
      begin
        TSignalTargetItem(ListTarget.Selected.Data).ClearPosition;
      end;
  end;
end;

procedure TSystemOrderForm.PopLinkClick(Sender: TObject);
begin
  if Sender = nil then Exit;

  ActOnLink((Sender as TComponent).Tag, ListLink);
end;

//
// Manage Signal-account Link
//
procedure TSystemOrderForm.ButtonLinkClick(Sender: TObject);
begin
  ActOnLink((Sender as TComponent).Tag, ListLink);
end;

procedure TSystemOrderForm.ActOnLink(iActIndex : Integer; aListActive : TListView);
var
  aSymbol : TSymbol;
  aLink : TSignalLinkItem;

  aAccount : TAccount;
  aFund    : TFund;
  aSignal : TSignalItem;

  function IsChange : boolean;
  begin
    Result := false;
    if aSymbol <> aLink.Symbol then Result := true;

    if ( not Result ) and ( aAccount <> aLink.Account ) then
      Result := true;

    if ( not Result ) and ( aSignal <> aLink.Signal ) then
      Result := true;

    if ( not Result ) and ( aFund <> aLink.Fund ) then
      Result := true;
  end;

begin
  //
  if CheckOrderConnected.Checked then
  begin
    ShowMessage('자동주문이 활성화 되어 있습니다. ' + #13 +
                '연결설정하시려면 ''자동주문'' 체크박스를 체크하지 마십시오.');
    Exit;
  end;
  //
    
  case iActIndex of
    100 : // add
      begin
        aLink := FLinks.NewLink;

        if aLink <> nil then
        begin
          //-- apply to target
          FTargets.AddLink(aLink);

          //-- update target view
          RefreshView([vtLink, vtTarget]);
        end;
      end;
    200 : // edit
      if (aListActive.Selected <> nil) and
         (TObject(aListActive.Selected.Data) is TSignalLinkItem) then
      begin
        aLink := TSignalLinkItem(aListActive.Selected.Data);
        // 수정전 세이브..
        aSymbol   := aLink.Symbol;
        aAccount  := aLink.Account;
        aSignal   := aLink.Signal;
        aFund     := aLink.Fund;

        if FLinks.EditLink(aLink) then
        begin
          if IsChange then begin
            aLink.RemoveLink;
            FTargets.AddLink(aLink);
          end
          else begin
            if aSymbol = nil then
              FTargets.AddLink(aLink)
            else
              aLink.UpdatePosition;
          end;
          RefreshView([vtLink, vtTarget]);
        end;
      end;
    300 : // delete
      if (aListActive.Selected <> nil) and
         (TObject(aListActive.Selected.Data) is TSignalLinkItem) then
      begin
        aLink := TSignalLinkItem(aListActive.Selected.Data);

        FLinks.RemoveLink(aLink);

        RefreshView([vtLink, vtTarget]);
      end;
  end;

  // save
  FLinks.SaveLinks;
end;

//=================================================================//
//                           Manage Orders                         //
//=================================================================//

// (published)
// Cancel all pending orders
//
procedure TSystemOrderForm.ButtonCancelAllClick(Sender: TObject);
begin
  if mrYes = MessageDlg('시스템 주문으로 낸 주문만 모두 취소합니다.'#13 +
                        '주문을 모두 취소하시겠습니까?', mtConfirmation,
                        [mbYes, mbNo], 0) then
  begin
      //.. logging
      DoLog(self,'사용자 >> 사용자 주문 전체 취소');
      //.. logging
    FTargets.CancelAllOrders;
  end;
end;

//=================================================================//
//                           TOmegaIF Events                       //
//=================================================================//

procedure TSystemOrderForm.LastTimeProc(Sender : TObject);
begin
  StatusBar.Panels[0].Text := 'MultiChart[' +
                           FormatDateTime('hh:nn:ss', FOmegaIF.LastTime) + ']';
end;

//=================================================================//
//                           TSignals Events                       //
//=================================================================//

// (private)
// A signal alias is added
//
procedure TSystemOrderForm.SignalChange(Sender: TSystemIF; aSignal: TSignalItem;
  aSymbol: TObject);
var
  I: Integer;
  aLink : TSignalLinkItem;
begin

  for I := 0 to FLinks.Count - 1 do
  begin
    aLink := FLinks.Links[i];
    if aLink.Signal = aSignal then
    begin
      if aLink.Symbol <> aSymbol then
      begin
        aLink.Symbol  := aSymbol as TSymbol;
        aLink.RemoveLink;
        FTargets.AddLink(aLink);
      end else
        aLink.UpdatePosition;
    end;
  end;

  RefreshView([vtLink, vtTarget]);
  FLinks.SaveLinks;
end;

procedure TSystemOrderForm.SignalAdd(Sender : TSystemIF; aSignal: TSignalItem);
begin
  if aSignal = nil then Exit;

  RefreshView([vtSignal]);
end;

// (private)
//
procedure TSystemOrderForm.SignalUpdate(Sender : TSystemIF; aSignal: TSignalItem);
begin
  if aSignal = nil then Exit;

  RefreshView([vtSignal, vtLink, vtTarget]);
end;

procedure TSystemOrderForm.SignalRemoved(Sender : TSystemIF; aSignal: TSignalItem);
begin
  RefreshView([vtSignal]);
end;

procedure TSystemOrderForm.SignalRemoving(Sender : TSystemIF; aSignal: TSignalItem);
begin
  if aSignal = nil then Exit;

  FLinks.RemoveLink(aSignal); // targetting is triggered here

  RefreshView([vtLink, vtTarget]);
end;

// (priate)
// <-- called from TSignals.OnPositionChange
// update signal positions of targets
//
procedure TSystemOrderForm.PositionChange(Sender : TSystemIF; aSignal: TSignalItem);
begin
  if aSignal = nil then Exit;

  // udate signal list
  RefreshView([vtSignal]);

  FLinks.UpdatePosition(aSignal); //--> TargetUpdate
end;

// (private)
// <-- called from TSignals.OnOrder
// put order if the automatic order checked
//
procedure TSystemOrderForm.NewOrder(Sender : TSystemIF; aEvent : TSignalEventItem);
var
  iMatchedCount : Integer;
begin
  if (aEvent = nil) or (aEvent.Signal = nil) then Exit;

    //.. logging
    //DoLog(self,'시스템주문 >> 신규주문 Event' +
    //                     ' : ' + aEvent.Signal.Title + ' : ' + aEvent.Remark);
    //.. logging
  //
  RefreshView([vtEvent]);
  //
  if CheckOrderConnected.Checked then
  begin
      //.. logging
      //DoLog(self,'시스템주문 >> 자동주문 시도 : ' +
      //                     aEvent.Signal.Title + ' : ' + aEvent.Remark);
      //.. logging
    //
    try
      DoNotify(aEvent);
    except
      //DoLog(self,'시스템주문 >> 알림 실패 : ' +
      //                     aEvent.Signal.Title + ' : ' + aEvent.Remark);
    end;

    //--
    iMatchedCount := FLinks.NewOrder(aEvent); //--> ChasingUpdate

      //.. logging
     // DoLog(self,'시스템주문 >> 주문 연결 : ' + IntToStr(iMatchedCount) + ' 건');
      //.. logging
  end;
end;

//=======================================================================//
//                      TSignalTargets Events                            //
//=======================================================================//

procedure TSystemOrderForm.TargetUpdate(Sender : TObject);
begin
  RefreshView([vtTarget]);
end;

procedure TSystemOrderForm.Timer1Timer(Sender: TObject);
begin
  //
  if ListTarget.Items.Count > 0 then
    RefreshView( [vtTargetCur]);
end;

procedure TSystemOrderForm.ChasingUpdate(Sender : TObject);
begin
  RefreshView([vtOrder]);
end;

//=======================================================================//
//                      Control Targetting                               //
//=======================================================================//

procedure TSystemOrderForm.CheckOrderConnectedClick(Sender: TObject);
begin
    //.. logging
    if CheckOrderConnected.Checked then
      DoLog(self,'사용자 >> 자동주문 ON')
    else
      DoLog(self,'사용자 >> 자동주문 OFF');
    //.. logging
  FTargets.AutoChasing := CheckOrderConnected.Checked;
end;

//=======================================================================//
//                      Manage Views                                     //
//=======================================================================//

// (private)
// Make target view
//
procedure TSystemOrderForm.MakeTargetView;
var
  i, j : Integer;
begin
  FTargetView.Clear;
  for i:=0 to FTargets.Count-1 do
  begin
    FTargetView.Add(FTargets[i]);
    if FDetailView = true then
      begin
        for j:=0 to FTargets[i].Links.Count-1 do
          FTargetView.Add(FTargets[i].Links.Items[j]);
      end;
  end;
end;


// (parivate)
// Control Refresh
//
procedure TSystemOrderForm.RefreshView(Values : TSystemOrderViewTypes);
begin
  if vtTargetCur in Values then
  begin
    //UpdateTargetview;
    ListTarget.Refresh;
  end;
  //-- target pane
  if vtTarget in Values then
  begin
    MakeTargetView;
    ListTarget.Items.Count := FTargetView.Count;
    ListTarget.Refresh;
  end;
  //-- link pane
  if vtLink in Values then
  begin
    ListLink.Items.Count := FLinks.Count;
    ListLink.Refresh;
  end;
  //-- signal pane
  if vtSignal in Values then
  begin
    ListSignal.Items.Count := FSignals.Count;
    ListSignal.Refresh;
  end;
  //-- fill order event pane
  if vtEvent in Values then
  begin
    ListEvent.Items.Count := FSignals.EventCount;
    ListEvent.Refresh;
  end;
  //-- chasing pane
  if vtOrder in Values then
  begin
    ListOrder.Items.Count := FTargets.OrderCount;
    ListOrder.Refresh;
  end;
end;

// (published)
// OnData Handler for Target ListView
//
procedure TSystemOrderForm.ListTargetData(Sender: TObject;
  Item: TListItem);
var
  aTargetItem : TSignalTargetItem;
  aLinkItem : TSignalLinkItem;
begin
  if Item.Index > FTargetView.Count-1 then Exit;

  if TObject(FTargetView.Items[Item.Index]) is TSignalTargetItem then
  begin
    aTargetItem := TSignalTargetItem(FTargetView.Items[Item.Index]);
    // 계좌
    Item.Caption := aTargetItem.AccountName    ;

    Item.Data := aTargetItem;
    Item.SubItems.Clear;
    // 종목
    if aTargetItem.Symbol <> nil then
      Item.SubItems.Add(aTargetItem.Symbol.ShortCode )
    else
      Item.SubItems.Add('Error');
    // 포지션 & 평균단가
    if aTargetItem.IsPosition <> nil then
    begin
      // 포지션 수량
      if aTargetItem.Volume <> 0 then
        Item.SubItems.Add(IntToSTr(aTargetItem.Volume) )
      else
        Item.SubItems.Add('');
      // 평균단가
      if aTargetItem.Symbol <> nil then
      begin
        Item.SubItems.Add(Format('%.*n', [aTargetItem.Symbol.Spec.Precision,
                                         aTargetItem.AvgPrice])) // 평균단가
      end else
      begin
        Item.SubItems.Add('NA');
      end;
    end else
    begin
      Item.SubItems.Add('');
      Item.SubItems.Add('');
    end;
    // 종목 현재가
      if aTargetItem.Symbol <> nil then
        Item.SubItems.Add(Format('%.*n', [aTargetItem.Symbol.Spec.Precision,
                                          aTargetItem.Symbol.Last]))
      else
        Item.SubItems.Add('NA');
    // 평가손익, 매도주문수량, 매수주문수량
    if aTargetItem.IsPosition <> nil then
    begin
      // 평가손익
      Item.SubItems.Add(Format('%.0n',[aTargetItem.EntryOTE]));
      // 매도주문수량
      if aTargetItem.ActiveSellOrderVolume > 0 then
        Item.SubItems.Add(Format('%d',[aTargetItem.ActiveSellOrderVolume]))
      else
        Item.SubItems.Add('');
      // 매수주문수량
      if aTargetItem.ActiveBuyOrderVolume > 0  then
      Item.SubItems.Add(Format('%d',[aTargetItem.ActiveBuyOrderVolume]))
      else
        Item.SubItems.Add('');
    end else
    begin
      Item.SubItems.Add('');
      Item.SubItems.Add('');
      Item.SubItems.Add('');
    end;

    // 목표
    Item.SubItems.Add(IntToStr(aTargetItem.TargetQty));
  end else
  if TObject(FTargetView.Items[Item.Index]) is TSignalLinkItem then
  begin
    aLinkItem := TSignalLinkItem(FTargetView.Items[Item.Index]);
    Item.Data := aLinkItem;

    // 계좌
    Item.Caption := '';
    Item.Data := aLinkItem;
    // 종목
    Item.SubItems.Add('');
    // 포지션
    Item.SubItems.Add('');
    // 평균단가
    Item.SubItems.Add('');
    // 현재가
    Item.SubItems.Add('');
    //평균단가
    Item.SubItems.Add('');
    //매도수량
    Item.SubItems.Add('');
    // 목표
    // Item.SubItems.Add(IntToStr(aLinkItem.Position));
    //매수수량
    Item.SubItems.Add('');
    // 신호
    Item.SubItems.Add(aLinkItem.Signal.Title);
    // 신호포지션
    Item.SubItems.Add(IntToStr(aLinkItem.Signal.Position));
    // 승수
    Item.SubItems.Add(IntToStr(aLinkItem.Multiplier));
  end;

   {
   0 : 계좌 140
   1 : 종목 80
   2 : 포지션 55
   3 : 주문 55
   4 : 신호 100
   5 : 신호포지션 80
   6 : 승수 45
   7 : 목표수량 75

  if TObject(FTargetView.Items[Item.Index]) is TSignalTargetItem then
  begin
    aTargetItem := TSignalTargetItem(FTargetView.Items[Item.Index]);
    Item.Caption := aTargetItem.Account.Description;
    Item.Data := aTargetItem;
    Item.SubItems.Clear;
    if aTargetItem.Symbol <> nil then
      Item.SubItems.Add(aTargetItem.Symbol.Code)
    else
      Item.SubItems.Add('Error');
    Item.SubItems.Add(IntToStr(aTargetItem.PositionQty));
    if aTargetItem.OrderReqQty <> 0 then
      Item.SubItems.Add(Format('%d(%d)', [aTargetItem.OrderQty,aTargetItem.OrderReqQty]))
    else
      Item.SubItems.Add(IntToStr(aTargetItem.OrderQty));
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add(IntToStr(aTargetItem.TargetQty));
  end else
  if TObject(FTargetView.Items[Item.Index]) is TSignalLinkItem then
  begin
    aLinkItem := TSignalLinkItem(FTargetView.Items[Item.Index]);
    Item.Caption := '';
    Item.Data := aLinkItem;
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add(aLinkItem.Signal.Title);
    Item.SubItems.Add(IntToStr(aLinkItem.Signal.Position));
    Item.SubItems.Add(IntToStr(aLinkItem.Multiplier));
    Item.SubItems.Add(IntToStr(aLinkItem.Position));
  end;
   }


end;

procedure TSystemOrderForm.ListTargetDblClick(Sender: TObject);
var
  aList : TListView;
  iIndex : integer;
  aItem : TListItem;
  aDlg : TOrderForm;
  aTarget : TSignalTargetItem;
begin

  aList := Sender as TListView;
  iIndex := aList.ItemIndex;


  aTarget := TSignalTargetItem(FTargetView.Items[iIndex]);
  //aTarget := TSignalTargetItem(aItem.Data);
  aDlg := TOrderForm.Create(nil);




  //aTarget := TSignalTargetItem(aItem.Data);
  //aDlg.Target := TSignalTargetItem(aItem.Data);
  aDlg.Target := aTarget;
  aDlg.Engine := gEnv.Engine;
  aDlg.Show;
end;

// (published)
// OnData Handler for Link ListView
//
procedure TSystemOrderForm.ListLinkData(Sender: TObject; Item: TListItem);
var
  aLinkItem : TSignalLinkItem;
begin
  if Item.Index > FLinks.Count-1 then Exit;

  aLinkItem := FLinks[Item.Index];
  if aLinkItem = nil then Exit;
  if aLinkItem.IsFund then
  Item.Caption := aLinkItem.Fund.Name
  else
  Item.Caption := aLinkItem.Account.Name;

  Item.Data := aLinkItem;
  Item.SubItems.Clear;
  if aLinkItem.Symbol = nil then
    Item.SubItems.Add('n/a')
  else
    Item.SubItems.Add(aLinkItem.Symbol.ShortCode);
  Item.SubItems.Add(aLinkItem.Signal.Title);
  Item.SubItems.Add(IntToStr(aLinkItem.Multiplier));
end;

// (published)
// OnData Handler for SingalAlias ListView
//
procedure TSystemOrderForm.ListSignalData(Sender: TObject;
  Item: TListItem);
var
  aSignal : TSignalItem;
begin
  if Item.Index > FSignals.Count-1 then Exit;

  aSignal := FSignals[Item.Index];
  Item.Caption := aSignal.Title;
  Item.Data := aSignal;
  Item.SubItems.Clear;
  Item.SubItems.Add(IntToStr(aSignal.Position));
  Item.SubItems.Add(aSignal.Source);
  Item.SubItems.Add(aSignal.Description);
end;

// (published)
// OnData Handler for Event ListView
//
procedure TSystemOrderForm.ListEventData(Sender: TObject; Item: TListItem);
var
  aEvent : TSignalEventItem;
begin
  if Item.Index > FSignals.EventCount-1 then Exit;

  aEvent := FSignals.Events[Item.Index];
  Item.Caption := FormatDateTime('hh:nn:ss', aEvent.EventTime);
  Item.Data := aEvent;
  Item.SubItems.Clear;
  Item.SubItems.Add(aEvent.Signal.Title);
  Item.SubItems.Add(aEvent.Remark);
end;

// (published)
// OnData Handler for Order ListView
//
procedure TSystemOrderForm.ListOrderData(Sender: TObject; Item: TListItem);
var
  aChasing : TChasingItem;
  iSign : Integer;
begin
  if Item.Index > FTargets.OrderCount-1 then Exit;

  aChasing := FTargets.Orders[Item.Index];
  Item.Caption := FormatDateTime('hh:nn:ss', aChasing.IssuedTime);
  Item.Data := aChasing;
  try
    Item.SubItems.Clear;
    if aChasing.Actor = nil then
      Item.SubItems.Add('사용자')
    else
      Item.SubItems.Add(aChasing.Actor.Title);
    // Item.SubItems.Add(aChasing.Account.AccountDesc);
    Item.SubItems.Add(aChasing.Account.Name);    // LSY 2008-01-02
    Item.SubItems.Add(aChasing.Symbol.Name);
  except
    Item.SubItems.Clear;
    Item.SubItems.Add('NA');
    Item.SubItems.Add('NA');
    Item.SubItems.Add('NA');
  end;
  if aChasing.Order = nil then
  begin
    Item.SubItems.Add(IntToStr(aChasing.Qty)); // 주문수량
    Item.SubItems.Add(''); // 주문가
    Item.SubItems.Add(''); // 체결수량
    Item.SubItems.Add(''); // 체결가
  end else
  begin
    if aChasing.Order.PositionType = ptLong then
      iSign := 1
    else
      iSign := -1;
    Item.SubItems.Add(IntToStr(iSign * aChasing.Order.OrderQty)); // 주문수량
    case aChasing.Order.PriceControl of

      pcLimit,  pcLimitToMarket :
        Item.SubItems.Add(Format('%.*n', [aChasing.Order.Symbol.Spec.Precision,
                                          aChasing.Order.Price]));// 주문가
      pcBestLimit:   Item.SubItems.Add('최유리');
      pcMarket   : Item.SubItems.Add('시장가');
    end;
    if aChasing.State in [csFullFill, csPartFill] then
    begin
      Item.SubItems.Add(IntToStr(iSign * aChasing.Order.FilledQty)); // 체결수량
      Item.SubItems.Add(Format('%.*n', [aChasing.Order.Symbol.Spec.Precision,
                                        aChasing.FillPrice])) // 체결가
    end else
    begin
      Item.SubItems.Add('');// 체결수량
      Item.SubItems.Add('');// 체결가
    end;
  end;
  Item.SubItems.Add(aChasing.StateDesc);
end;


//================================================================//
//                     ListView Draw                              //
//================================================================//

procedure TSystemOrderForm.ListDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  ListView : TListView;
  aChasing : TChasingItem;
begin
  ListView := Sender as TListView;
  Rect.Bottom := Rect.Bottom-1;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR2;
    end else
    if Item.Data <> nil then
    begin
      if Item.Index mod 2 = 1 then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end else
    begin
      Brush.Color := clWhite;
    end;
    Font.Color := clBlack;

    //-- background
    FillRect(Rect);

    //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;

    if Item.Caption <> '' then
      TextRect(
          Classes.Rect(0,
            Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
          Rect.Left + 2, iY, Item.Caption);

    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      // position
      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 2 - aSize.cx;
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;
end;

procedure TSystemOrderForm.ListOrderDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  ListView : TListView;
  aChasing : TChasingItem;
begin
  ListView := Sender as TListView;
  Rect.Bottom := Rect.Bottom-1;
  if (Item.Data <> nil) and (TObject(Item.Data) is TChasingItem) then
    aChasing := TChasingItem(Item.Data)
  else
    Exit;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR2;
    end else
    if Item.Data <> nil then
    begin
      if Item.Index mod 2 = 1 then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end else
    begin
      Brush.Color := clWhite;
    end;
    case aChasing.State of
      csWaitingAccept,
      csWaitingFill,
      csPartFill   : Font.Color := clBlue;
      csRejected,
      csManual     : Font.Color := clRed;
      csCancel     : Font.Color := clGray;
      csFullFill   : Font.Color := clBlack;
      else Font.Color := clBlack;
    end;

    //-- background
    FillRect(Rect);

    //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;

    if Item.Caption <> '' then
      TextRect(
          Classes.Rect(0,
            Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
          Rect.Left + 2, iY, Item.Caption);

    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      // position
      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 2 - aSize.cx;
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;
end;

procedure TSystemOrderForm.ListTargetDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  ListView : TListView;
  aLink : TSignalLinkItem;
  stText : String;
begin
  ListView := Sender as TListView;
  Rect.Bottom := Rect.Bottom-1;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := $00F2BEB9; // SELECTED_COLOR;
    end else
    if Item.Data <> nil then
    begin
      if TObject(Item.Data) is TSignalTargetItem then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end else
    begin
      Brush.Color := clWhite;
    end;
    Font.Color := clBlack;
    //-- background
    FillRect(Rect);
  end;

  with ListView.Canvas do
  if TObject(Item.Data) is TSignalTargetItem then
  begin
    //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;

    if Item.Caption <> '' then
      TextRect(
          Classes.Rect(0,
            Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
          Rect.Left + 2, iY, Item.Caption);
    {
    if (Item.ImageIndex >=0) and (ListView.SmallImages <> nil) then
    begin
      // aListView.SmallImages.BkColor := Brush.Color;
      ListView.SmallImages.Draw(ListView.Canvas, Rect.Left+1, Rect.Top,
                              Item.ImageIndex);
    end;
    //-- caption
    if Item.Caption <> '' then
      if ListView.SmallImages = nil then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption)
      else
        TextRect(
            Classes.Rect(Rect.Left + ListView.SmallImages.Width,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + ListView.SmallImages.Width + 2, iY, Item.Caption);
    }
    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);
      Font.Color := clBlack;
      // color

      if i in [1,4,7] then
        begin
          if Item.Subitems[i] = '0' then
            Font.Color := clBlack
          else if Pos('-', Item.SubItems[i]) > 0 then
            Font.Color := clBlue
          else
            Font.Color := clRed
        end
      else if  ( i = 5 ) then
        Font.Color := clBlue
      else if ( i= 6 ) then
        Font.Color := clRed
      else
        Font.Color := clBlack;

      // position
      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 2 - aSize.cx;
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end else
  if (Item.Data <> nil) and (TObject(Item.Data) is TSignalLinkItem) then
  begin
    aLink := TSignalLinkItem(Item.Data);

    // make string
    stText := Format('%10s: %3s, %3sx, %3s',
                        [aLink.Signal.Title,
                         Format('%d', [aLink.Signal.Position]),
                         Format('%d', [aLink.Multiplier]),
                         Format('%d', [aLink.Position])]);
    //
    aSize := TextExtent(stText);
    iX := Rect.Right - aSize.cx - 5;
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    //
    Font.Color := clBlack;
    TextRect(Rect, iX, iY, stText);
  end;
end;

procedure TSystemOrderForm.ListTargetSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
end;

//====================================================================//
//                    Miscellaneous                                   //
//====================================================================//

procedure TSystemOrderForm.DoLog(Sender: TObject; stLog: String);
var
  aColor : TColor;
  stLine : String;
begin
    // color
  if Pos('시스템주문', stLog) > 0 then
    aColor := clGray
  else if Pos('사용자', stLog) > 0 then
    aColor := clBlue
  else if Pos('자동주문', stLog) > 0 then
    aColor := clPurple
  else if Pos('주문추적', stLog) > 0 then
    aColor := clRed
  else if Pos('OmegaIF', stLog) > 0 then
    aColor := clNavy
  else if Pos('MultiChart', stLog) > 0 then
    aColor := clTeal
  else
    aColor := clBlack;

    // write to screen
  stLine := '[' + FormatDateTime('hh:nn:ss', Time) + '] ' + stLog;
  MemoLog.Lines.Insert(0, stLine);
  MemoLog.SelStart := 0;
  MemoLog.SelLength := Length(stLine);
  MemoLog.SelAttributes.Color := aColor;
  MemoLog.SelLength := 0;

    // write to log file
  stLine  := Format('%s : %s , %s ', [ '시스템주문', FormatDateTime('hh:nn:ss', Time), stLog]);
  gEnv.EnvLog( WIN_MC, stLine);

end;

procedure TSystemOrderForm.DoNotify(aEvent : TSignalEventItem);
var
  szBuf : array[0..1000] of Char;
  aDlg : TSignalNotifyDialog;
begin
  if FTargets.ChasingConfig.NotifySignal then
  begin
    aDlg := TSignalNotifyDialog.Create(Self);
    aDlg.Event := aEvent;
    aDlg.Show;
  end;
  
  if FTargets.ChasingConfig.UseSound and
     FileExists(FTargets.ChasingConfig.SoundFile) then
    PlaySound(StrPCopy(szBuf, FTargets.ChasingConfig.SoundFile), 0,
              SND_ASYNC + SND_FILENAME + SND_NODEFAULT);
end;


procedure TSystemOrderForm.SpeedButton1Click(Sender: TObject);
begin
{$ifdef DEBUG}
  FOmegaIF.DumpSyncs;
{$endif}
end;

//==================================================================//
//                        List Selet (--> Button control)           //
//==================================================================//

procedure TSystemOrderForm.ListLinkSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  bEnabled : Boolean;
begin

  bEnabled := (ListLink.Selected <> nil) and
              (ListLink.Selected.Data <> nil);
  ButtonLinkEdit.Enabled := bEnabled;
  ButtonLinkDelete.Enabled := bEnabled;
  MenuLinkEdit.Visible := bEnabled;
  MenuLinkDelete.Visible := bEnabled;

end;

procedure TSystemOrderForm.ListSignalSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  bEnabled : Boolean;
begin
  bEnabled := (ListSignal.Selected <> nil) and
              (ListSignal.Selected.Data <> nil);
  ButtonSignalEdit.Enabled := bEnabled;
  ButtonSignalDelete.Enabled := bEnabled;
  MenuSignalEdit.Visible := bEnabled;
  MenuSignalDelete.Visible := bEnabled;
end;

//====================================================================//
//                     Tool Buttons & Check Boxes Events              //
//====================================================================//

procedure TSystemOrderForm.CheckDetailClick(Sender: TObject);
begin
  FDetailView := CheckDetail.Checked ;
  RefreshView([vtTarget]);
end;

procedure TSystemOrderForm.BtnConfigClick(Sender: TObject);
begin
  FTargets.ConfigChasing;

  SetClearTimer(FTargets.ChasingConfig.ForcedClear);
end;

procedure TSystemOrderForm.ButtonSaveClick(Sender: TObject);
var
  aDlg : TSaveDialog ;
  stFileName : String ;
begin

  try 
  aDlg := TSaveDialog.Create(Application.MainForm);
  aDlg.Filter := '*.txt';
  aDlg.DefaultExt := 'txt';

  if aDlg.Execute then
    begin
    stFileName := aDlg.FileName ;
    MemoLog.Lines.SaveToFile(stFileName);
    end;
  aDlg.Free ;

  Except

  end;

end;

procedure TSystemOrderForm.ListLinkDblClick(Sender: TObject);
begin
  ButtonLinkClick(ButtonLinkEdit);
end;

procedure TSystemOrderForm.ButtonPrintClick(Sender: TObject);
begin
  //NeoPrinter.PrintForm(Self);
end;


procedure TSystemOrderForm.ButtonSyncClick(Sender: TObject);
begin
  FOmegaIF.Synchronize;
end;

procedure TSystemOrderForm.ButtonTargetClick(Sender: TObject);
begin
  if mrYes = MessageDlg('보유 미체결 수량을 신호합계와 맞추기 위한'#13 +
                        '주문을 냅니다. 진행하시기 전에 TradeStation을'#13 +
                        '한번 더 확인하시기 바랍니다.'#13 +
                        '진행하시겠습니까?', mtConfirmation,
                         [mbYes, mbNo], 0) then
  begin
      //.. logging
      DoLog(self,'사용자 >> 신호합계 적용');
      //.. logging
    FTargets.TargetPositions; //--> ChasingUpdate
  end;
end;

procedure TSystemOrderForm.ButtonClearClick(Sender: TObject);
begin
  if mrYes = MessageDlg('신호와 연결된 포지션을 모두 청산합니다.'#13 +
                        '진행하시겠습니까?', mtConfirmation,
                         [mbYes, mbNo], 0) then
  begin
    //.. logging
    DoLog(self,'사용자 >> 포지션 청산');
    //.. logging
    FTargets.ClearAllPositions;
  end;
end;

//------------------------< Work on forced clear >---------------------------//

function GetPCTime : Integer;
var
  wHour, wMin, wSec, wMSec : Word;
begin
  DecodeTime(Time, wHour, wMin, wSec, wMSec);
  Result := wHour * 60 + wMin;
end;

procedure TSystemOrderForm.ClearTimerTimer(Sender: TObject);
begin
  // check if condition for clearing has been satisfied
  if GetPCTime >= FTargets.ChasingConfig.CloseHour * 60 +
                FTargets.ChasingConfig.CloseMin  then
  begin
    ClearTimer.Enabled := False;

    if CheckOrderConnected.Checked then
    begin
      // turn off auto
      CheckOrderConnected.Checked := False;

        //.. logging
        DoLog(self,'자동주문 >> 장마감전 강제 청산');
        //.. logging
      FTargets.ClearAllPositions;
    end;
  end;
end;

// (private)
// Set clear timer
//
procedure TSystemOrderForm.SetClearTimer(bEnabled : Boolean);
begin
  if ClearTimer.Enabled <> bEnabled then
  begin
    // set timer
    if not bEnabled then
    begin
      ClearTimer.Enabled := False;
    end else
    begin
      if GetPCTime < FTargets.ChasingConfig.CloseHour * 60 +
                   FTargets.ChasingConfig.CloseMin  then
      begin
        ClearTimer.Enabled := True;
      end;
    end;
  end;

  // display status
  if ClearTimer.Enabled then
  begin
    StatusBar.Panels[1].Text :=
           Format('강제청산@%d:%d', [FTargets.ChasingConfig.CloseHour,
                                     FTargets.ChasingConfig.CloseMin]);
      //.. logging
      DoLog(self,'사용자 >> 강제청산 ON');
      //.. logging
  end else
  begin
    StatusBar.Panels[1].Text := '';
      //.. logging
      DoLog(self,'사용자 >> 강제청산 OFF');
      //.. logging
  end;
end;


procedure TSystemOrderForm.PopOrderClick(Sender: TObject);
var
  aChasing : TChasingItem;
  aForm : TForm;
begin
  if Sender = nil then Exit;
  //??
 {
  case (Sender as TMenuItem).Tag of
    100 : // 단순주문
      if (ListOrder.Selected <> nil) and (ListOrder.Selected.Data <> nil) then
      begin
        aChasing := TChasingItem(ListOrder.Selected.Data);
        aForm := gWin.OpenForm(ID_ORDER, nil, nil);
        if aForm <> nil then
        with aForm as TOrderForm do
          case aChasing.State of
            csRejected : //--> new order
                  begin
                    OrderType := otNew;
                    if aChasing.Qty > 0 then
                      TradeType := ttLong
                    else
                      TradeType := ttShort;
                    Account := aChasing.Account;
                    Symbol := aChasing.Symbol;
                    Qty := Abs(aChasing.Qty);
                  end;
            csManual, csWaitingFill, csPartFill :
                  begin
                    OrderType := otChange;
                    Account := aChasing.Account;
                    Symbol := aChasing.Symbol;
                    OrgOrder := aChasing.Order;
                    Qty := Abs(aChasing.Qty);
                  end;
          end; //..case
      end; //.. if
    200 : // EF 주문
      if (ListOrder.Selected <> nil) and (ListOrder.Selected.Data <> nil) then
      begin
        aChasing := TChasingItem(ListOrder.Selected.Data);
        gWin.OpenForm(ID_EFORDER, aChasing.Account, aChasing.Symbol);
      end;
    300 : // 계좌정보
      if (ListOrder.Selected <> nil) and (ListOrder.Selected.Data <> nil) then
      begin
        aChasing := TChasingItem(ListOrder.Selected.Data);
        gWin.OpenForm(ID_ACCOUNT, aChasing.Account, nil);
      end;
    400 : // 주문내역
      gWin.OpenForm(ID_OrderLog, nil, nil);
    500 : // 체결내역
      gWin.OpenForm(ID_FillLog, nil, nil);
    600 : // 주문 취소
      if (ListOrder.Selected <> nil) and (ListOrder.Selected.Data <> nil) then
      begin
        aChasing := TChasingItem(ListOrder.Selected.Data);
        aChasing.Owner.CancelOrder(aChasing);
      end;
  end;     }
end;

procedure TSystemOrderForm.PopOrderPopup(Sender: TObject);
var
  aChasing : TChasingItem;
  bEnabled : Boolean;
begin
  if (ListOrder.Selected <> nil) and (ListOrder.Selected.Data <> nil) then
  begin
    aChasing := TChasingItem(ListOrder.Selected.Data);

    MenuAccount.Visible := True;
    MenuOrder.Visible :=
         (aChasing.State in [csRejected, csManual, csWaitingFill, csPartFill]);
    MenuEFOrder.Visible := MenuOrder.Visible;
    MenuCancel.Visible := (aChasing.Order <> nil) and
                          (aChasing.Order.State = osActive);
  end else
  begin
    MenuAccount.Visible := True;
    MenuOrder.Visible := False;
    MenuEFOrder.Visible := False;
    MenuCancel.Visible := False;
  end;
end;


procedure TSystemOrderForm.ButtonHelpClick(Sender: TObject);
begin
  //gHelp.Show(ID_SYSTEMORDER);
end;

procedure TSystemOrderForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  
  if CheckOrderConnected.Checked then
    CanClose := (MessageDlg(
                       '자동주문이 선택되어 있습니다. 그래도 닫으시겠습니까?',
                        mtConfirmation, [mbYes, mbNo], 0) = mrYes);
end;

procedure TSystemOrderForm.ButtonRecoveryClick(Sender: TObject);
begin
  //??
  //gTrade.StartRecovery;
end;

{    LSY 2008-01-02
procedure TSystemOrderForm.AccAliasProc(Sender, Receiver : TObject; DataObj : TObject;
      iBroadcastKind : Integer; btValue : TBroadcastType);
var
  i : integer;
begin
  if (Receiver <> Self) or (iBroadcastKind <> OID_AccAlias) then
  begin
    gLog.Add(lkWarning, '계좌창', '계좌별명갱신','Data Integrity Failure');
    Exit;
  end;

  for i:=0 to ListTarget.Items.Count-1 do
    if TSignalTargetItem(ListTarget.Items[i]).Account <> nil then
       ListTarget.Items[i].Caption := TSignalTargetItem(ListTarget.Items[i]).Account.Description
    else
       ListTarget.Items[i].Caption := '';
  ListTarget.Refresh;

  for i:=0 to FLinks.Count-1 do
    ListLink.Items[i].Caption := TSignalLinkItem(FLinks.Items[i]).Account.Description;
  ListLink.Refresh;

  for i:=0 to FTargets.OrderCount-1 do
    //ListOrder.Items[i].Subitems[1] := TChasingItem(FTargets.Orders[i]).Account.AccountDesc;
    ListOrder.Items[i].Subitems[1] := TChasingItem(FTargets.Orders[i]).Account.AccountName; //LSY 2008-01-02
  ListOrder.Refresh;
end;  }

end.
