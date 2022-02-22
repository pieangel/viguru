unit FSingleOrderBoard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, Buttons, ComCtrls, ImgList,  Menus, Math, Spin,
  MMSystem,
    // lemon: common
  GleTypes, GleLib, GleConsts,
    // lemon: data
  CleFQN, CleSymbols, CleMarkets, CleKrxSymbols, CleQuoteBroker,
    // lemon: trade
  CleAccounts, CleOrders, ClePositions, CleTradeBroker,
    // lemon: utils
  CleDistributor, CleStorage,
    // lemon: import
  CalcGreeks,  COBTypes,
    // app: main
  GAppEnv,
    // app: orderboard
  COrderBoard, COrderTablet,
  DBoardPrefs, DBoardParams, DBoardOrder, UAlignedEdit;

const
  PlRow = 12;
  FeeRow = 13;
  SIDE_LEFT_PANEL_WIDTH = 170;
  SIDE_RIGHT_PANEL_WIDTH = 154;

type
  TSingleOrderBoardForm = class(TForm)
    PanelLeft: TPanel;
    PanelUnders: TPanel;
    Bevel1: TBevel;
    ComboBoxUnderlyings: TComboBox;
    StaticTextUnderlying: TStaticText;
    PageControl1: TPageControl;
    TabSheetOptions: TTabSheet;
    StringGridOptions: TStringGrid;
    Panel1: TPanel;
    ComboBoxOptions: TComboBox;
    edDeliveryTime: TEdit;
    TabSheetELWs: TTabSheet;
    Panel2: TPanel;
    Label7: TLabel;
    ComboBoxELWs: TComboBox;
    StringGridELWTrees: TStringGrid;
    StringGridELWs: TStringGrid;
    TabSheet1: TTabSheet;
    lvSymbolList: TListView;
    PanelFutures: TPanel;
    LabelFut: TLabel;
    ComboBoxFutures: TComboBox;
    StaticTextFutures: TStaticText;
    PanelSpread: TPanel;
    Label3: TLabel;
    ComboBoxSpreads: TComboBox;
    StaticTextSpread: TStaticText;
    PanelMain: TPanel;
    PanelTop: TPanel;
    SpeedButtonLeftPanel: TSpeedButton;
    SpeedButtonRightPanel: TSpeedButton;
    SpeedButtonPrefs: TSpeedButton;
    ComboBoAccount: TComboBox;
    PanelRight: TPanel;
    PanelOrderList: TPanel;
    GridInfo: TStringGrid;
    pcTab: TPageControl;
    tabReady: TTabSheet;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    sgReady: TStringGrid;
    tabCancel: TTabSheet;
    Panel5: TPanel;
    LabelSymbol: TLabel;
    LabelPrice: TLabel;
    LabelTotalQty: TLabel;
    ButtonCancel: TButton;
    EditCancelQty: TEdit;
    ListViewOrders: TListView;
    PopupMenuOrders: TPopupMenu;
    N6000X11: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N9: TMenuItem;
    FlipDirection1: TMenuItem;
    FlipSide1: TMenuItem;
    FlipSideDirection1: TMenuItem;
    PopQuote: TPopupMenu;
    N8: TMenuItem;
    C1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBoxUnderlyingsChange(Sender: TObject);
    procedure ComboBoxFuturesChange(Sender: TObject);
    procedure ComboBoxSpreadsChange(Sender: TObject);
    procedure StaticTextUnderlyingMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StaticTextFuturesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StaticTextSpreadMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxOptionsChange(Sender: TObject);
    procedure ComboBoxELWsChange(Sender: TObject);
    procedure SpeedButtonLeftPanelClick(Sender: TObject);
    procedure SpeedButtonRightPanelClick(Sender: TObject);
    procedure SpeedButtonPrefsClick(Sender: TObject);
    procedure StringGridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridOptionsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGridOptionsMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGridOptionsMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GridInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
      // created objects
    FBoards: TOrderBoards;

      // configuration
    FPrefs: TOrderBoardPrefs;
    FDefParams: TOrderBoardParams;

      // selection
    FUnderlying: TSymbol; // selected underlying symbol
    FFutures: TSymbol;    // selected futures
    FSpread: TSpread;
    FUnderlyingGroup: TMarketGroup; //
    FFutureMarket: TFutureMarket;   //
    FSpreadMarket: TSpreadMarket;   //
    FOptionMarket: TOptionMarket;   //
    FELWMarket: TELWMarket;         //

      // menu related -- used when executing orders from the popup menu
    FMenuBoard: TOrderBoard;
    FMenuPoint: TTabletPoint;

      // last selected -- used in symbol selection, info window, order list
    FSelectedBoard: TOrderBoard;
    FCancelPoint: TTabletPoint;

      // temporary order list -- used in sending change and cancel orders
    FTargetOrders: TOrderList;

      // syntetic futures
    FSynFutures: TSymbol;
    FLastSynFutures : Double ;

      // 순서 제어 변수들.
    FLoadEnd    : boolean;
    FLeftPos    : integer; 

    procedure ReloadSymbols;
    procedure BoardSetup(Sender: TObject);
    procedure MakeBoards; overload;
    procedure MakeBoards( iCount : integer ) ; overload;

    procedure MinPriceProc(Sender : TObject);
    procedure MaxPriceProc(Sender : TObject);

      // init
    procedure InitControls;
    procedure SetAccount;
    procedure SetSymbol(aSymbol : TSymbol);


      // configuration
    procedure ApplyPrefs;
    procedure SetWidth;
    procedure SetDefaultPrefs;
    procedure SetDefaultParams;


       // order tablet events handler
    procedure BoardNewOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardChangeOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardSelectCell(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardSelect(Sender: TObject);
    procedure BoardAcntSelect( aBoard : TOrderBoard );

    procedure BoardReadyOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure AddReadyOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iVolume: Integer; dPrice: Double);
    procedure DisplayReadyOrder(aBoard: TOrderBoard );
    procedure SendReadyOrder;
    procedure DeleteReadyOrder( aBoard : TOrderBoard; aOrder : TOrder );
    //procedure


      // send order
    function NewOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iVolume: Integer; dPrice: Double): TOrder;
    function ChangeOrder(aBoard: TOrderBoard; aPoint1, aPoint2: TTabletPoint): Integer; overload;
    function ChangeOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iMaxQty: Integer; dPrice: Double): Integer; overload;
    function CancelOrders(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iMaxQty: Integer = 0): Integer; overload;
    function CancelOrders(aBoard: TOrderBoard; aTypes: TPositionTypes): Integer; overload;


      // board
    function NewBoard: TOrderBoard;

      // info pane
    procedure SetInfo(aBoard: TOrderBoard);
    procedure SetOptionInfo(aBoard: TOrderBoard);
    procedure SetElwInfo(aBoard: TOrderBoard);
    procedure SetAccountInfo;

      // engine events
    procedure TradeBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure DoAccount(aAccount: TAccount; EventID: TDistributorID);
    procedure DoPosition(aPosition: TPosition; EventID: TDistributorID);
    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID);
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure BoardEnvEventHander (Sender : TObject; DataObj: TBaseItem;
      etType: TEventType; vtType : TValueType );

      // left side pane
    procedure SetPosition(aPosition: TPosition);
    procedure SetOptionPositions;
    procedure SetStringGridELWs(aList: TSymbolList);
    procedure UpdateTotalPl;
    function BoardsOrientCount(Sender: TOrderTablet) : TOrientationType;
    procedure CheckOrientation(aBoard: TOrderBoard);

    procedure MatchTablePoint( aBoard : TOrderboard;
        aPoint1, aPoint2: TTabletPoint);
    procedure SetQtySet(aItem: TQtyItem);
    procedure UpdateQtySet(aData: TQtyItem; vtType: TValueType);



  public
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure SetExSymbol( aSymbol : TSymbol; aMarket : TMarketType = mtElw);
    procedure SetSymbol2(aSymbol : TSymbol; aMarket : TMarketType = mtElw);
    procedure SymbolSelect( aSymbol : TSymbol ); overload;
    procedure SymbolSelect( Sender : TObject ); overload;
    procedure QtySetSelect( Sender : TObject ); overload;
    procedure ReLoad;
    function  CheckShowOrderData( aBoard : TOrderboard ) : boolean;

  end;

var
  SingleOrderBoardForm: TSingleOrderBoardForm;

implementation

uses DleSymbolSearch, CleQuoteTimers;

{$R *.dfm}

procedure TSingleOrderBoardForm.AddReadyOrder(aBoard: TOrderBoard;
  aPoint: TTabletPoint; iVolume: Integer; dPrice: Double);
var
  aReady : TReadyOrder;
begin
  aReady := TReadyOrder( aBoard.ReadyOrder.Add );
  aReady.FPoint := aPoint;
  aReady.FVolume  := iVolume;
  aReady.FPrice   := dPrice;
  aReady.FOrder   := nil;

  DisplayReadyOrder( aBoard );

end;

procedure TSingleOrderBoardForm.ApplyPrefs;
var
  i: Integer;
  aBoard: TOrderBoard;
begin
    // reset selected reference
  if (FSelectedBoard <> nil)
     and (FSelectedBoard.Index > FPrefs.BoardCount-1) then
    FSelectedBoard := nil;

  if (FSelectedBoard <> nil)
     and (FSelectedBoard.Index > FPrefs.BoardCount-1) then
  begin
      // cancel canceling order
    if FCancelPoint.Tablet = FSelectedBoard.Tablet then
    begin
      FCancelPoint.Tablet := nil;
      ListViewOrders.Items.Clear;
    end;

      // cancel board selection
    FSelectedBoard := nil;
  end;

    // board count
  MakeBoards;

    // apply common parameters
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Tablet.AutoScroll := FPrefs.AutoScroll;
    aBoard.Tablet.TraceMouse := FPrefs.TraceMouse;
    aBoard.Tablet.ShowQT := FPrefs.ShowQT;
    aBoard.Tablet.OrderByMouseRB := FPrefs.OrderByMouseRB;
    aBoard.Tablet.OrderColors[ptLong, ctFont]  := FPrefs.Colors[IDX_LONG,  IDX_ORDER, IDX_FONT];
    aBoard.Tablet.OrderColors[ptLong, ctBG]    := FPrefs.Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND];
    aBoard.Tablet.OrderColors[ptShort, ctFont] := FPrefs.Colors[IDX_SHORT, IDX_ORDER, IDX_FONT];
    aBoard.Tablet.OrderColors[ptShort, ctBG]   := FPrefs.Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND];
    aBoard.Tablet.QuoteColors[ptLong, ctFont]  := FPrefs.Colors[IDX_LONG,  IDX_QUOTE, IDX_FONT];
    aBoard.Tablet.QuoteColors[ptLong, ctBG]    := FPrefs.Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND];
    aBoard.Tablet.QuoteColors[ptShort, ctFont] := FPrefs.Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT];
    aBoard.Tablet.QuoteColors[ptShort, ctBG]   := FPrefs.Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND];
  end;

    // adjust the form width
  SetWidth;
end;


procedure TSingleOrderBoardForm.BoardAcntSelect(aBoard: TOrderBoard);
var
  i: Integer;
  aAccount : TAccount;
  aOrder   : TOrder;
begin

  if aBoard.Account = nil then Exit;

  aBoard.Tablet.RefreshDraw;

  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = aBoard.Account)
       and (aOrder.Symbol = aBoard.Symbol) then
      aBoard.Tablet.DoOrder(aOrder);
  end;


end;

procedure TSingleOrderBoardForm.BoardCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TOrderBOard;
begin
  if (Sender = nil) or (Sender.Symbol = nil) then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order
  CancelOrders(aBoard, aPoint1)

end;

procedure TSingleOrderBoardForm.BoardChangeOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TOrderBOard;
begin
  if (Sender = nil) or (Sender.Symbol = nil) then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order
  ChangeOrder(aBoard, aPoint1, aPoint2)

end;

procedure TSingleOrderBoardForm.BoardEnvEventHander(Sender: TObject;
  DataObj: TBaseItem; etType: TEventType; vtType: TValueType);
begin
  if DataObj = nil then Exit;
  case etType of
    etQty:  UpdateQtySet( DataObj as TQtyItem, vtType );
  end;
end;

procedure TSingleOrderBoardForm.BoardNewOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TOrderBoard;
  iQty: Integer;
begin
    // check
  if (Sender = nil) or (Sender.Symbol = nil)
     or (aPoint1.AreaType <> taOrder) then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order

  NewOrder(aBoard, aPoint1, aBoard.DefQty, aPoint1.Price);

end;

procedure TSingleOrderBoardForm.BoardReadyOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TOrderBoard;
  iQty: Integer;
begin
    // check
  if (Sender = nil) or (Sender.Symbol = nil)
     or (aPoint1.AreaType <> taOrder) then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order

  AddReadyOrder(aBoard, aPoint1, aBoard.DefQty, aPoint1.Price);

end;

procedure TSingleOrderBoardForm.BoardSelect(Sender: TObject);
var
  i: Integer;
  aBoard: TOrderBoard;
begin
  if Sender = nil then Exit;

  if FSelectedBoard = Sender then Exit;

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if aBoard = Sender then
    begin
      FSelectedBoard := aBoard;
      FSelectedBoard.PanelVolumes.Color := clYellow;
      FSelectedBoard.SymbolPanel.Color  := clYellow;
      FSelectedBoard.Tablet.Selected  := true;
    end else
    begin
      aBoard.PanelVolumes.Color := clBtnFace;
      aBoard.SymbolPanel.Color  := clBtnFace;
      aBoard.Tablet.Selected  := false;
    end;
  end;

    // set info
  SetInfo(FSelectedBoard);
  if (pcTab.ActivePage = tabReady) then
    DisplayReadyOrder( FSelectedBoard );


end;

procedure TSingleOrderBoardForm.BoardSelectCell(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  i: Integer;
  aItem: TListItem;
  aOrder: TOrder;
  iSum: Integer;
  stPosition: String;
  aBoard: TOrderBoard;
  theOrders: TOrderList;

begin

    // check
  if Sender = nil then Exit;

    // get board
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // select board
  BoardSelect(aBoard);

    // set order list
  if (aPoint1.AreaType = taInfo) and ( aPoint1.RowType = trInfo ) and
     (aPoint1.ColType = tcQuote ) then
  begin
    aBoard.SetPositionVolume;
  end;



  if aPoint1.AreaType <> taOrder then Exit;

  try
    theOrders := TOrderList.Create;

      // save the point
    FCancelPoint := aPoint1;

      // get order list
    Sender.GetOrders(aPoint1, theOrders);

      // sort order list
    theOrders.SortByAcptTime;

      // change label
    if Sender.Symbol <> nil then    
      LabelSymbol.Caption := Sender.Symbol.Name;
    if aPoint1.PositionType = ptLong then
      stPosition := 'L'
    else
      stPosition := 'S' ;
    LabelPrice.Caption := stPosition + ' ' + Format('%.2f', [FCancelPoint.Price]) ;
    LabelPrice.Font.Color := clRed;

      // populate list view on the right side pane
    iSum := 0;
    ListViewOrders.Items.Clear;


    for i := 0 to theOrders.Count-1 do
    begin
      aOrder := theOrders[i];
      aItem := ListViewOrders.Items.Add;

      aItem.Data := aOrder;
      // 'Caption' is saved for 'check' mark

      aItem.Checked := True;
      aItem.SubItems.Add(IntToStr(aOrder.Side * aOrder.ActiveQty));
      aItem.SubItems.Add(IntToStr(aOrder.OrderNo));

        // add
      iSum := iSum + aOrder.ActiveQty;
    end;

      // set default volumes
    EditCancelQty.Text := IntToStr(iSum);
    LabelTotalQty.Caption := '/ ' + IntToStr(iSum);

      // todo: reset click?
    for i := 0 to FBoards.Count - 1 do
      if FBoards[i].Tablet <> Sender then
        FBoards[i].Tablet.ResetClick;
  finally
    theOrders.Free;
  end;


end;

procedure TSingleOrderBoardForm.BoardSetup(Sender: TObject);
var
  aDlg: TBoardParamDialog;
  aBoard: TOrderBoard;
  i: Integer;
  bChange : boolean;
begin
  if (Sender = nil) or not (Sender is TOrderBoard) then Exit;

    // select this board
  BoardSelect(Sender);

    //
  aBoard := Sender as TOrderBoard;

  bChange := false;

    //
  FLeftPos := Left;
  aDlg := TBoardParamDialog.Create(Self);
  try
    aDlg.Params := aBoard.Params;
    if aDlg.ShowModal = mrOK then
    begin
        // apply
      if aDlg.ApplyToAll then
        for i := 0 to FBoards.Count - 1 do
          FBoards[i].Params := aDlg.Params
      else begin
        if aBoard.Params.OrientaionType <> aDlg.Params.OrientaionType then
          bChange := true;
        aBoard.Params := aDlg.Params;
      end;

        // default
      if aDlg.SaveAsDefault then
        FDefParams := aDlg.Params; 
    end;
      // adjust width
    SetWidth;

    if bChange then begin
      for i := 0 to FBoards.Count- 1 do
      begin
        if FBoards[i] = aBoard then Continue;
        FBoards[i].Params := FBoards[i].Params;
      end;

    end;
  finally
    aDlg.Free;
  end;

end;

function TSingleOrderBoardForm.BoardsOrientCount(
  Sender: TOrderTablet): TOrientationType;
var
  i : integer;
  oBoard, aBoard : TOrderBoard;
  aType  : TOrientationType;
  iAuto, iAsc, iDesc : integer;
  bPut   : boolean;
begin
    // check
  Result  := otAuto;

  if Sender = nil then Exit;

    // get board
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  if aBoard.Symbol = nil then
    Exit;

  iAuto := 0; iAsc := 0;  iDesc := 0;

  for i := 0 to FBoards.Count - 1 do
  begin
    oBoard  := FBoards.Boards[i];
    if oBoard = aBoard then Continue;
    if oBoard.Symbol = nil then Continue;    

    aType := oBoard.Tablet.OrientationType;

    bPut  := false;
    if oBoard.Symbol.Spec.Market = mtOption then
      if oBoard.Symbol.Code[1] = '3' then
        bPut := true;

    case aType of
      otAuto: inc(iAuto);
      otAsc : if bPut then inc( iDesc ) else inc(iAsc);
      otDesc: if bPut then inc( iAsc ) else inc(iDesc);
    end;
  end;

  if (iAuto > 0) and (iAsc = 0) and (iDesc =0)  then
    Result  := otAuto
  else if (iAsc > 0) and (iDesc > 0) then
    Result  := otAuto
  else if (iAsc > 0) and (iDesc = 0) then
    Result  := otAsc
  else if (iAsc = 0) and (iDesc > 0) then
    Result  := otDesc
  else
    Result  := otAuto;

end;

function TSingleOrderBoardForm.CancelOrders(aBoard: TOrderBoard;
  aTypes: TPositionTypes): Integer;
var
  i, iQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
begin
  Result := 0;

    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;  

    // init
  iQty := 0;

    // clear list
  FTargetOrders.Clear;

    // get orders from the tablet
  if aBoard.Tablet.GetOrders(aTypes, FTargetOrders) = 0 then Exit;

    // generate orders
  for i := 0 to FTargetOrders.Count - 1 do
  begin
    aOrder := FTargetOrders[i];

    if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then begin
        // get a ticket
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
      gEnv.Engine.TradeBroker.Send(aTicket);
    end;
  end;

end;

function TSingleOrderBoardForm.CancelOrders(aBoard: TOrderBoard;
  aPoint: TTabletPoint; iMaxQty: Integer): Integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
begin
  Result := 0;
    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;  

    // confirm
  if FPrefs.ConfirmOrder then
    if MessageDlg('주문을 취소하시겠습니까?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;

    // init
  iQty := 0;

    // clear order list
  FTargetOrders.Clear;

    // get order list
  if aBoard.Tablet.GetOrders(aPoint, FTargetOrders) = 0 then Exit;

    // get a order ticket


    // if canceling for the selected cell, send cancel orders for
    // only selected orders
  if (aBoard.Tablet.Symbol = FCancelPoint.Tablet.Symbol)
     and (aPoint.Tablet = FCancelPoint.Tablet)
     and (aPoint.Index = FCancelPoint.Index)
     and (aPoint.PositionType = FCancelPoint.PositionType) then
  begin
    iMaxQty := Max(0, StrToIntDef(EditCancelQty.Text, 0));
    if iMaxQty = 0 then Exit;

    iQty := 0;

    for i := 0 to ListViewOrders.Items.Count-1 do
    begin
      if ListViewOrders.Items[i].Checked then
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);

          // check
        if (aOrder = nil) or (aOrder.OrderType <> otNormal)
           or (aOrder.ActiveQty = 0) then Continue;

          // calc the order volume to change
        iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
        if iOrderQty <= 0 then Break;

          // generate order
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, iOrderQty, aTicket);
        Result := gEnv.Engine.TradeBroker.Send(aTicket);

          //
        iQty := iQty + iOrderQty;
      end;
    end;
  end else
    // cancel all if it not a selected cell
  begin
    for i := 0 to FTargetOrders.Count-1 do
    begin
      aOrder := FTargetOrders[i];

      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
        Result := gEnv.Engine.TradeBroker.Send(aTicket);
      end;
    end;
  end;

end;

function TSingleOrderBoardForm.ChangeOrder(aBoard: TOrderBoard;
  aPoint: TTabletPoint; iMaxQty: Integer; dPrice: Double): Integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
begin
  Result := 0;

    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
     or (iMaxQty <= 0) then Exit;

  if aBoard.Account = nil then Exit;
    // init
  iQty := 0;

    // clear order list
  FTargetOrders.Clear;

    // get order list
  if aBoard.Tablet.GetOrders(aPoint, FTargetOrders) = 0 then Exit;

    // generage orders
  for i := 0 to FTargetOrders.Count-1 do
  begin
    aOrder := FTargetOrders[i];

      // recheck
    if (aOrder.OrderType <> otNormal) or (aOrder.State <> osActive)
       or (aOrder.ActiveQty <= 0) then Continue;

      // get change volume
    iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
    if iOrderQty <= 0 then Break;

    // get a order ticket
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      // generate order
    gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                      aOrder, iOrderQty, pcLimit, dPrice,
                      tmGTC, aTicket);
    gEnv.Engine.TradeBroker.Send(aTicket);                      

      //
    iQty := iQty + iOrderQty;
  end;

end;

function TSingleOrderBoardForm.ChangeOrder(aBoard: TOrderBoard; aPoint1,
  aPoint2: TTabletPoint): Integer;
var
  i, iOrderQty: Integer;
  aOrder: TOrder;
  aTicket: TOrderTicket;
  iMaxQty, iQty: Integer ;
begin
  Result := 0;

    // check
  if  (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;
  

    // confirm
  if FPrefs.ConfirmOrder then
    if  MessageDlg(
           Format('%s 주문 (%.2f -> %.2f)을 정정하시겠습니까?',
             [POSITIONTYPE_DESCS[aPoint1.PositionType],
              aPoint1.Price, aPoint2.Price]),
                    mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;

    // clear order list
  FTargetOrders.Clear;

    // get target orders to change
  if aBoard.Tablet.GetOrders(aPoint1, FTargetOrders) = 0 then Exit;

    // get ticket
  //aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

    // send changed orders for selected orders
  if (aBoard.Tablet.Symbol = FCancelPoint.Tablet.Symbol)
     and (aPoint1.Tablet = FCancelPoint.Tablet)
     and (aPoint1.Index = FCancelPoint.Index)
     and (aPoint1.PositionType = FCancelPoint.PositionType) then
  begin
    iMaxQty := Max(0, StrToIntDef(EditCancelQty.Text, 0));
    if iMaxQty = 0 then Exit;

    iQty := 0;

    for i := 0 to ListViewOrders.Items.Count-1 do
    begin
      if ListViewOrders.Items[i].Checked then
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);

          // check
        if (aOrder = nil) or (aOrder.OrderType <> otNormal)
           or (aOrder.ActiveQty = 0) then Continue;

          // calc the order volume to change
        iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
        if iOrderQty <= 0 then Break;

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          // generate order
        gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                          aOrder, iOrderQty, pcLimit, aPoint2.Price,
                          tmGTC, aTicket);
        gEnv.Engine.TradeBroker.Send(aTicket);
          //
        iQty := iQty + iOrderQty;
      end;
    end;
  end else
    // -- 선택셀이 아닐 경우는 전체 정정
  begin
    for i := 0 to FTargetOrders.Count-1 do
    begin
      aOrder := FTargetOrders[i];

      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                        aOrder, aOrder.ActiveQty, pcLimit, aPoint2.Price,
                        tmGTC, aTicket);
        gEnv.Engine.TradeBroker.Send(aTicket);
      end;
    end;
  end;

    // send

end;

procedure TSingleOrderBoardForm.CheckOrientation(aBoard: TOrderBoard);

var
  i : integer;
begin
  for i := 0 to FBoards.Count- 1 do
  begin
    if FBoards[i] = aBoard then Continue;
    FBoards[i].Params := FBoards[i].Params;
  end;
end;

function TSingleOrderBoardForm.CheckShowOrderData(aBoard: TOrderboard): boolean;
begin

end;

procedure TSingleOrderBoardForm.ComboBoxELWsChange(Sender: TObject);
var
  aELWMarket: TELWMarket;
  aTree: TELWTree;
  aStrike: TELWStrike;
  i: Integer;
begin
    // check
  if FELWMarket = nil then Exit;

    // get tree
  aTree := GetComboObject(ComboBoxELWs) as TELWTree;
  if aTree = nil then Exit;

    // clear ELW table
  StringGridELWs.RowCount := 1;

    // set grid
  with StringGridELWTrees do
  begin
      // delete all cells
    RowCount := 1;

      // set rows
    RowCount := aTree.Strikes.Count + 1;
      // set strikes
    for i := 0 to aTree.Strikes.Count - 1 do
    begin
      aStrike := aTree.Strikes[i];

      Cells[1, i+1] := aTree.Strikes[i].StrikeCode;

      Cells[0, i+1] := IntToStr(aStrike.Calls.Count);
      Objects[0, i+1] := aStrike.Calls;
      Cells[2, i+1] := IntToStr(aStrike.Puts.Count);
      Objects[2, i+1] := aStrike.Puts;
    end;
  end;

end;

procedure TSingleOrderBoardForm.ComboBoxFuturesChange(Sender: TObject);
var
  aFuture: TFuture;
  aPosition: TPosition;
begin
    // get selected futures
  aFuture := GetComboObject(ComboBoxFutures) as TFuture;
  if aFuture = nil then Exit;

    // keep it!
  FFutures := aFuture;

    // find position
  aPosition := gEnv.Engine.TradeCore.Positions.Find( aFuture);

    //
  if aPosition <> nil then
    StaticTextFutures.Caption:= IntToStr(aPosition.Volume)
  else
    StaticTextFutures.Caption:= '0';

end;

procedure TSingleOrderBoardForm.ComboBoxOptionsChange(Sender: TObject);
var
  aTree: TOptionTree;
  i: Integer;
  aStrike: TStrike;
begin
    // get selected option month
  aTree := GetComboObject(ComboBoxOptions) as TOptionTree;
  if aTree = nil then
  begin
    StringGridOptions.RowCount := 1;
    Exit;
  end;

    // set option grid
  StringGridOptions.RowCount := aTree.Strikes.Count + 1;

    //
  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aStrike := aTree.Strikes[i];

      // strike price
    StringGridOptions.Cells[1, i+1]   := Format('%.2f', [aStrike.StrikePrice]);
    StringGridOptions.Objects[1, i+1] := aStrike;
      // call
    StringGridOptions.Cells[0,i+1] := '';
    if aStrike.Call <> nil then
      StringGridOptions.Objects[0,i+1] := aStrike.Call
    else
      StringGridOptions.Objects[0,i+1] := nil;

      // put
    StringGridOptions.Cells[2,i+1] := '';
    if aStrike.Put <> nil then
      StringGridOptions.Objects[2,i+1] := aStrike.Put
    else
      StringGridOptions.Objects[2,i+1] := nil
  end;

end;

procedure TSingleOrderBoardForm.ComboBoxSpreadsChange(Sender: TObject);
var
  aSpread: TSpread;
  aPosition: TPosition;
begin
    // get selected futures
  aSpread := GetComboObject(ComboBoxSpreads) as TSpread;
  if aSpread = nil then Exit;

    // keep it!
  FSpread := aSpread;

    // find position
  aPosition := gEnv.Engine.TradeCore.Positions.Find(aSpread);

    //
  if aPosition <> nil then
    StaticTextSpread.Caption:= IntToStr(aPosition.Volume)
  else
    StaticTextSpread.Caption:= '0';

end;

procedure TSingleOrderBoardForm.ComboBoxUnderlyingsChange(Sender: TObject);
var
  aULGroup: TMarketGroup;
  aMarket: TMarket;
  aPosition: TPosition;
  i: Integer;
begin
    // disable controls
  ComboBoxFutures.Enabled := False;
  StaticTextFutures.Enabled := False;
  ComboBoxSpreads.Enabled := False;
  StaticTextSpread.Enabled := False;
  ComboBoxOptions.Enabled := False;
  StringGridOptions.Enabled := False;
  ComboBoxELWs.Enabled := False;
  StringGridELWTrees.Enabled := False;
  StringGridELWs.Enabled := False;

    // clear controls
  ComboBoxFutures.Items.Clear;
  ComboBoxSpreads.Items.Clear;
  ComboBoxOptions.Items.Clear;
  StringGridOptions.RowCount := 1;
  ComboBoxELWs.Items.Clear;
  StringGridELWTrees.RowCount := 1;
  StringGridELWs.RowCount := 1;
  StaticTextUnderlying.Caption := '';
  StaticTextFutures.Caption := '';

    // rest selection
  FUnderlyingGroup := nil;
  FUnderlying := nil;
  FFutureMarket := nil;
  FFutures := nil;
  FSpreadMarket := nil;
  FSpread := nil;
  FOptionMarket := nil;
  FELWMarket := nil;

    // get the selected group
  aULGroup := GetComboObject(ComboBoxUnderlyings) as TMarketGroup;
  if aULGroup = nil then
  begin
    PanelFutures.Visible := False;
    PanelSpread.Visible := False;
    TabSheetOptions.TabVisible := False;
    TabSheetELWs.TabVisible := False;

    Exit;
  end;

    // keep it!
  FUnderlyingGroup := aULGroup;
  FUnderlying := aULGroup.Ref;

    // set stock position if required

  if (FUnderlying <> nil) and (FUnderlying.Spec <> nil)
     and (FUnderlying.Spec.Market = mtStock) then
  begin
      // find position
    aPosition := gEnv.Engine.TradeCore.Positions.Find(FUnderlying);

      //
    if aPosition <> nil then
      StaticTextUnderlying.Caption:= IntToStr(aPosition.Volume)
    else
      StaticTextUnderlying.Caption:= '0';
  end;

    // populate combox
  for i := 0 to aULGroup.Markets.Count - 1 do
  begin
    aMarket := aULGroup.Markets[i];

    case aMarket.Spec.Market of
      mtFutures:
        begin
          FFutureMarket := aMarket as TFutureMarket;
          aMarket.Symbols.GetList(ComboBoxFutures.Items);
          ComboBoxFutures.Enabled := True;
          StaticTextFutures.Enabled := True;
        end;
      mtSpread:
        begin
          FSpreadMarket := aMarket as TSpreadMarket;
          aMarket.Symbols.GetList(ComboBoxSpreads.Items);
          ComboBoxSpreads.Enabled := True;
          StaticTextSpread.Enabled := True;
        end;
      mtOption:
        begin
          FOptionMarket := aMarket as TOptionMarket;
          FOptionMarket.Trees.GetList(ComboBoxOptions.Items);
          ComboBoxOptions.Enabled := True;
          StringGridOptions.Enabled := True;
        end;
      mtELW:
        begin
          FELWMarket := aMarket as TELWMarket;
          FELWMarket.ELWTrees.GetList(ComboBoxELWs.Items);
          ComboBoxELWs.Enabled := True;
          StringGridELWTrees.Enabled := True;
          StringGridELWs.Enabled := True;
        end;
    end;
  end;

    //
  PanelSpread.Visible := FSpreadMarket <> nil;
  PanelFutures.Visible := FFutureMarket <> nil;
  TabSheetOptions.TabVisible := FOptionMarket <> nil;
  TabSheetELWs.TabVisible := FELWMarket <> nil;

    // select default futures
  if ComboBoxFutures.Items.Count > 0 then
  begin
    ComboBoxFutures.ItemIndex := 0;
    ComboBoxFuturesChange(ComboBoxFutures);
  end;

    // select default spread
  if ComboBoxSpreads.Items.Count > 0 then
  begin
    ComboBoxSpreads.ItemIndex := 0;
    ComboBoxSpreadsChange(ComboBoxSpreads);
  end;

    // select default option tree
  if ComboBoxOptions.Items.Count > 0 then
  begin
    ComboBoxOptions.ItemIndex := 0;
    ComboBoxOptionsChange(ComboBoxOptions);
  end;

    // select default ELW tree
  if ComboBoxELWs.Items.Count > 0 then
  begin
    ComboBoxELWs.ItemIndex := 0;
    ComboBoxELWsChange(ComboBoxELWs);
  end;

end;

procedure TSingleOrderBoardForm.DeleteReadyOrder(aBoard: TOrderBoard;
  aOrder: TOrder);
var
  i : integer;
  aReady : TReadyOrder;
begin

  for i := 0 to aBoard.ReadyOrder.Count-1 do
  begin
    aReady  := TReadyOrder( aBoard.ReadyOrder.Items[i] );
    if aReady.FOrder = aOrder then begin
      aBoard.ReadyOrder.Delete(i);
      break;
    end;
  end;


end;

procedure TSingleOrderBoardForm.DisplayReadyOrder(aBoard: TOrderBoard);
var
  i : Integer;
  aReady : TReadyOrder;
begin
  for i := 1 to sgReady.RowCount - 1 do
    sgReady.Rows[i].Clear;


  for i := 0 to aBoard.ReadyOrder.Count-1 do
  begin
    aReady := TReadyOrder( aBoard.ReadyOrder.Items[i] );
//    if aReady.FOrder <> nil then
//      Continue;
    sgReady.Objects[0, i+1] := aReady;
    sgReady.Cells[0, i+1 ]  := ifThenStr( aReady.FPoint.PositionType = ptShort ,'S', 'L');
    if aReady.FPoint.PositionType = ptShort then
      sgReady.Objects[1, i+1] := Pointer( clBlue )
    else
      sgReady.Objects[1, i+1] := Pointer( clRed );
    sgReady.Cells[1, i+1 ]  := Format( '%.*n', [ aBoard.Symbol.Spec.Precision, aReady.FPrice ] );
    sgReady.Cells[2, i+1 ]  := IntToStr( aReady.FVolume );
  end;

end;

procedure TSingleOrderBoardForm.DoAccount(aAccount: TAccount;
  EventID: TDistributorID);
begin
  SetAccountInfo;
end;

procedure TSingleOrderBoardForm.DoOrder(aOrder: TOrder;
  EventID: TDistributorID);
var
  i: Integer;
  aBoard: TOrderBoard;
  aDummy: TTabletPoint;
  stSpeed: String;
  iSpeed: Integer;

  OrderSpeed : Integer;
  bLeft, bRight : Boolean ;

  stTmp : string;
  is1, is2, is3, is4 : int64;

begin


  if {(FAccount = nil) or} (aOrder = nil)
     //or (aOrder.Account <> FAccount)
     or (aOrder.PriceControl in [pcMarket, pcBestLimit]) then Exit;


    // apply this order the every board
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if aBoard.Symbol <> aOrder.Symbol then Continue;
    if aBoard.Account<> aOrder.Account then Continue;

      // apply to the tablet
    aBoard.Tablet.DoOrder(aOrder);

      // order speed
    if (EventID in [ORDER_NEW, ORDER_SPAWN, ORDER_ACCEPTED])
      and (aOrder.OrderType = otNormal)
      and (aOrder.State = osActive) then
    begin
      stSpeed := aBoard.OrderSpeed;

      iSpeed := timeGetTime - aBoard.SentTime;

      if iSpeed < 2000 then
        stSpeed := Format('%d', [iSpeed])
      else
        stSpeed := aBoard.OrderSpeed;
        //
      aBoard.OrderSpeed := stSpeed;
        //
      if aBoard = FSelectedBoard then
        GridInfo.Cells[1, 14] := stSpeed;
    end;


      // update order limit
    aBoard.UpdateOrderLimit;

    if EventID = ORDER_ACCEPTED then
    begin
      DeleteReadyOrder( aBoard, aOrder );
    end;

      // update order list if required
    if aBoard.Tablet = FCancelPoint.Tablet then
    begin
      MatchTablePoint( aBoard, FCancelPoint, aDummy);

    end;

  end;


end;

procedure TSingleOrderBoardForm.DoPosition(aPosition: TPosition;
  EventID: TDistributorID);
var
  aBoard: TOrderBoard;
  i: Integer;
begin
  //if (FAccount = nil) or (aPosition.Account <> FAccount) then Exit;

    // update position volume on symbol list area
  SetPosition(aPosition);

    // update position info for the board
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if (aBoard.Symbol = aPosition.Symbol) and (aBoard.Account = aPosition.Account )  then
    begin
      aBoard.Position := aPosition;
      aBoard.UpdatePositionInfo;
      aBoard.UpdateOrderLimit;
      break;
    end;
  end;

  UpdateTotalPl;

end;

procedure TSingleOrderBoardForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSingleOrderBoardForm.FormCreate(Sender: TObject);
begin
    // create objects
  FBoards := TOrderBoards.Create(Self, PanelMain);
  FTargetOrders := TOrderList.Create;

    // init variables
  FLastSynFutures := 0;
    // grid title
  InitControls;

    // get default
    // 주문창 전체 환경설정
  SetDefaultPrefs;
    // 개별 보드 환경설정
  SetDefaultParams;
    // Account 설정
  SetAccount;

    // populate underlyings
  gEnv.Engine.SymbolCore.Underlyings.GetList(ComboBoxUnderlyings.Items);

    // subscribe for trade events
  gEnv.Engine.TradeBroker.Subscribe(Self, TradeBrokerEventHandler);

    // synthetic futures
  FSynFutures := gEnv.Engine.SymbolCore.Symbols.FindCode(KOSPI200_SYNTH_FUTURES_CODE);


  gBoardEnv.BroadCast.RegistCfg( Self, etQty, BoardEnvEventHander );

    // populate underlying combo
  SetComboIndex(ComboBoxUnderlyings, 0);
  ComboBoxUnderlyingsChange(ComboBoxUnderlyings);

    //
  ApplyPrefs;

    //
  LoadEnv( nil );
  FLeftPos := Left;
end;

procedure TSingleOrderBoardForm.FormDestroy(Sender: TObject);
var
  i: Integer;
  aBoard : TOrderBoard;
begin
  gBoardEnv.BroadCast.UnRegistCfg( Self );
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    if (aBoard.Params.ShowForceDist) and ( aBoard.Quote <> nil) then
      aBoard.Quote.ForceDist := false;
    if (aBoard.Params.ShowOrderData) and ( aBoard.Quote <> nil) then
      aBoard.Quote.ExtrateOrder := false;
    gEnv.Engine.QuoteBroker.Cancel(FBoards[i]);
  end;


    // new coding

  gEnv.Engine.TradeBroker.Unsubscribe(Self);
  gEnv.Engine.QuoteBroker.Cancel(Self);

  FTargetOrders.Free;
  FBoards.Free;

end;

procedure TSingleOrderBoardForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
begin
    // scroll
  if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT ,VK_HOME, VK_SPACE ] then
  begin
    case Key of
      VK_UP:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollLine(1,1);
      VK_DOWN:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollLine(1,-1);
      VK_PRIOR:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollPage(1);
      VK_NEXT:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollPage(-1);
      VK_HOME, VK_SPACE:
      begin
        for i := 0 to FBoards.Count - 1 do
          FBoards[i].Tablet.ScrollToLastPrice;
         //gCObserver.Notify(Self, CFID_DOORDER, ACID_CENTER, '중앙정렬요청');
      end;
    end;
    //
    Key := 0;
  end else
    // escape key
  if Key = VK_ESCAPE then
  begin
    if FPrefs.EnableEscKey then
    begin
        // confirm
      if FPrefs.ConfirmOrder and
       (MessageDlg('모두 주문을 취소하시겠습니까?',
          mtConfirmation, [mbOK, mbCancel], 0) <> mrOK) then
      begin
        Key := 0;
        Exit;
      end;

        // log
      //DoEnvLog(Self, '[Order Board] cancel all orders by [Escape]');

        // cancel all orders (todo: duplicate symbols)
      for i := 0 to FBoards.Count-1 do
        CancelOrders(FBoards[i], [ptLong, ptShort]);

        //
      Key := 0;
    end;
  end
  else if Key =VK_F5 then
    ReloadSymbols
  else if Key = VK_RETURN then
  begin
    if FSelectedBoard = nil then Exit;
    if not FSelectedBoard.Tablet.EnterOrder then Exit;
    SendReadyOrder;
  end
  else if Key = VK_DELETE then
  begin
    if FSelectedBoard = nil then Exit;
    FSelectedBoard.ReadyOrder.Clear;
    DisplayReadyOrder( FSelectedBoard );
  end;

  //todo: clarify later!!!

  if FPrefs.UseKey1to5 then
  begin
    if FSelectedBoard = nil then Exit;
    
    if FSelectedBoard.CheckFocus then
      Exit;

    case Key of
      Ord('Q'): FSelectedBoard.SetPositionVolume;       // 포지션 수량
      ORd('W'): FSelectedBoard.SetPositionVolume(2);    // 포지션 수량 / 2
      Ord('1'): FSelectedBoard.SetOrderVolumeToKeyBoard(1);   // 청상수량  / ..n
      Ord('2'): FSelectedBoard.SetOrderVolumeToKeyBoard(2);
      Ord('3'): FSelectedBoard.SetOrderVolumeToKeyBoard(3);
      Ord('4'): FSelectedBoard.SetOrderVolumeToKeyBoard(4);
      Ord('5'): FSelectedBoard.SetOrderVolumeToKeyBoard(5);
    end;
  end;


end;

procedure TSingleOrderBoardForm.FormResize(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FBoards.Count - 1 do
    FBoards[i].Resize;
end;

procedure TSingleOrderBoardForm.GridInfoDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  aAlignment : TAlignment;
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  Grid: TStringGrid;
begin
  Grid := Sender as TStringGrid;
  
  with Grid.Canvas do
  begin
    Font.Name := Grid.Font.Name;
    Font.Size := Grid.Font.Size;
    
      // get text
    stText := Grid.Cells[ACol, ARow];

      // set colors & text alignment
    case ACol of
      0 :  // Fixed
        begin
          Brush.Color := NODATA_COLOR;
          Font.Color := clBlack;
          aAlignment := taLeftJustify;
        end;
      1 :  // Value
        begin
          Brush.Color := clWhite;
          Font.Color := clBlack;
          aAlignment := taRightJustify;
        end;
    end;

      // background
    FillRect(Rect);

      // check
    if stText = '' then Exit;

      // calc position
    aSize := TextExtent(stText);
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;

      // x-axis position based on text alignment
    case aAlignment of
      taLeftJustify :  iX := Rect.Left + 2;
      taCenter :       iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
      taRightJustify : iX := Rect.Left + Rect.Right-Rect.Left - 2 - aSize.cx;
    end;

      // draw text
    TextRect(Rect, iX, iY, stText);
  end;

end;

procedure TSingleOrderBoardForm.InitControls;
begin
  with StringGridOptions do
  begin
    Cells[0,0] := 'Call';
    Cells[1,0] := '행사가';
    Cells[2,0] := 'Put';
  end;
    //
  with GridInfo do
  begin
    Cells[0,0] := '합성선물' ;
    Cells[0,1] := '종목코드';
    Cells[0,2] := '시' ;
    Cells[0,3] := '고' ;
    Cells[0,4] := '저' ;

    Cells[0,5] := '종' ;
    Cells[0,6] := '거래량' ;
    Cells[0,7] := '델타' ;
    Cells[0,8] := '감마' ;
    Cells[0,9] := '세타' ;

    Cells[0,10] := '베가' ;
    Cells[0,11] := 'IV' ;
    Cells[0,12] := '당일손익' ;
    Cells[0,13] := '추정수수료' ;
    Cells[0,14] := '주문시간' ;

    Cells[0,15] := '시세지연';

  end;
    //
  with StringGridELWTrees do
  begin
    Cells[0,0] := 'Call';
    Cells[1,0] := '행사가';
    Cells[2,0] := 'Put';
  end;
    //
  with StringGridELWs do
  begin
    Cells[0,0] := 'Issuer';
    Cells[1,0] := 'LP';
    Cells[2,0] := 'Days';
    Cells[3,0] := 'Pos';
  end;

  with sgReady do
  begin
    Cells[0,0] := '구분';
    Cells[1,0] := '가격';
    Cells[2,0] := '수량';
  end;
end;

procedure TSingleOrderBoardForm.LoadEnv(aStorage: TStorage);
var
  i, j, k, iCol, iRow, iCount: Integer;
  aBoard: TOrderBoard;
  stBoard, stTmp : String;
  aParams: TOrderBoardParams;
  aOrder : TOrder;
begin
  if aStorage = nil then begin
    FLoadEnd := true;
    Exit;
  end;  

    //
  SpeedButtonLeftPanel.Down  := aStorage.FieldByName('ShowLeftPanel').AsBoolean;
  SpeedButtonRightPanel.Down := aStorage.FieldByName('ShowRightPanel').AsBoolean;

    // preferences
  FPrefs.BoardCount       := aStorage.FieldByName('Prefs.BoardCount').AsInteger;
  MakeBoards;

  FPrefs.ConfirmOrder     := aStorage.FieldByName('Prefs.ConfirmOrder').AsBoolean;
  FPrefs.EnableClearOrder := aStorage.FieldByName('Prefs.EnabledClearOrder').AsBoolean;
  FPrefs.EnableEscKey     := aStorage.FieldByName('Prefs.EnabledEscKey').AsBoolean;
  FPrefs.AutoScroll       := aStorage.FieldByName('Prefs.AutoScroll').AsBoolean;
  FPrefs.TraceMouse       := aStorage.FieldByName('Prefs.TraceMouse').AsBoolean;
  FPrefs.OrderByMouseRB   := aStorage.FieldByName('Prefs.OrderByMouseRB').AsBoolean;
  FPrefs.ShowZapr         := aStorage.FieldByName('Prefs.ShowZapr').AsBoolean;
  FPrefs.ShowQT           := aStorage.FieldByName('Prefs.ShowQT').AsBoolean;
  FPrefs.UseKey1to5       := aStorage.FieldByName('Prefs.UseKey1to5').AsBoolean;
  for i := 0 to 1 do
    for j := 0 to 1 do
      for k := 0 to 1 do
         FPrefs.Colors[i,j,k] := aStorage.FieldByName(Format('Prefs.Colors[%d,%d,%d]',[i,j,k])).AsInteger;

    // default params
  FDefParams.ShowTNS            := aStorage.FieldByName('DefParams.ShowTNS').AsBoolean;
  FDefParams.TNSOnLeft          := aStorage.FieldByName('DefParams.TNSOnLeft').AsBoolean;
  FDefParams.TNSRowCount        := aStorage.FieldByName('DefParams.TNSRowCount').AsInteger;
  FDefParams.UseTNSVolumeFilter := aStorage.FieldByName('DefParams.UseTNSVolumeFilter').AsBoolean;
  FDefParams.TNSVolumeThreshold := aStorage.FieldByName('DefParams.TNSVolumeThreshold').AsInteger;
  FDefParams.OrientaionType     := TOrientationType(aStorage.FieldByName('DefParams.OrientationType').AsInteger);

  FDefParams.MergeQuoteColumns  := aStorage.FieldByName('DefParams.MergeQuoteColumns').AsBoolean;
  FDefParams.MergedQuoteOnLeft  := aStorage.FieldByName('DefParams.MergedQuoteOnLeft').AsBoolean;
  FDefParams.ShowOrderColumn    := aStorage.FieldByName('DefParams.ShowOrderColumn').AsBoolean;
  FDefParams.ShowIVColumn       := aStorage.FieldByName('DefParams.ShowIVColumn').AsBoolean;
  FDefParams.ShowForceDist      := aStorage.FieldByName('DefParams.ShowForceDist').AsBoolean;
  FDefParams.FillterOrderQty    := aStorage.FieldByName('DefParams.FillterOrderQty').AsInteger;
  FDefParams.FillterOrderHoga   := aStorage.FieldByName('DefParams.FillterOrderHoga').AsInteger;

    // boards
  for i := 0 to FPrefs.BoardCount-1 do
  begin
    if i > FBoards.Count-1 then Break;

    aBoard := FBoards[i];
    stBoard := Format('Board[%d]', [i]);
      // symbol
    aBoard.Symbol := gEnv.Engine.SymbolCore.Symbols.FindCode(
                          aStorage.FieldByName(stBoard + '.symbol').AsString);

    if aBoard.Symbol <> nil then
      aBoard.Account:=
        gEnv.Engine.TradeCore.Accounts.GetMarketAccount( aBoard.Symbol.Spec.Market);

    if aBoard.Account <> nil then
      BoardAcntSelect( aBoard );

    if aBoard.Symbol <> nil then begin
      aBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(aBoard, aBoard.Symbol,
                            QuoteBrokerEventHandler);
      //if aBoard.Symbol.Spec.Market = mtElw then
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol( aboard.Symbol );
      aBoard.AddSymbol( aBoard.Symbol );
    end;

    //  qty set
    stTmp := aStorage.FieldByName(stBoard + '.QtySetName').AsString;
    aBoard.SetQtyCombol( stTmp );

      // parameters
    aParams.ShowTNS            := aStorage.FieldByName(stBoard + '.Params.ShowTNS').AsBoolean;
    aParams.TNSOnLeft          := aStorage.FieldByName(stBoard + '.Params.TNSOnLeft').AsBoolean;
    aParams.TNSRowCount        := aStorage.FieldByName(stBoard + '.Params.TNSRowCount').AsInteger;
    aParams.UseTNSVolumeFilter := aStorage.FieldByName(stBoard + '.Params.UseTNSVolumeFilter').AsBoolean;
    aParams.TNSVolumeThreshold := aStorage.FieldByName(stBoard + '.Params.TNSVolumeThreshold').AsInteger;
    aParams.OrientaionType     := TOrientationType( aStorage.FieldByName(stBoard + '.Params.OrientationType').AsInteger);

    aParams.MergeQuoteColumns  := aStorage.FieldByName(stBoard + '.Params.MergeQuoteColumns').AsBoolean;
    aParams.MergedQuoteOnLeft  := aStorage.FieldByName(stBoard + '.Params.MergedQuoteOnLeft').AsBoolean;
    aParams.ShowOrderColumn    := aStorage.FieldByName(stBoard + '.Params.ShowOrderColumn').AsBoolean;
    aParams.ShowIVColumn       := aStorage.FieldByName(stBoard + '.Params.ShowIVColumn').AsBoolean;
    aParams.ShowOrderData      := aStorage.FieldByName(stBoard + '.Params.ShowOrderData').AsBoolean;
    aParams.ShowOrderCount     := aStorage.FieldByName(stBoard + '.Params.ShowOrderCount').AsInteger;
    aParams.ShowForceDist      := aStorage.FieldByName(stBoard + '.Params.ShowForceDist').AsBoolean;
    aParams.FillterOrderQty    := aStorage.FieldByName(stBoard + '.Params.FillterOrderQty').AsInteger;
    aParams.FillterOrderHoga    := aStorage.FieldByName(stBoard + '.Params.FillterOrderHoga').AsInteger;


    // add
    aParams.TNSPosition        := aStorage.FieldByName(stBoard + 'DefParams.TNSPosition').AsInteger;
    aParams.ShowAccumulFillBar := aStorage.FieldByName(stBoard + 'DefParams.ShowAccumulFillBar').AsBoolean;
    aParams.ShowLpVolumeColumn := aStorage.FieldByName(stBoard + 'DefParams.ShowLpVolumeColumn').AsBoolean;
    aParams.EnterOrdered       := aStorage.FieldByName(stBoard + 'DefParams.EnterOrdered').AsBoolean;



    aBoard.Params := aParams; // apply
    {
      // order volumes
    for iCol := 0 to aBoard.StringGridVolumes.ColCount - 1 do
      for iRow := 0 to aBoard.StringGridVolumes.RowCount - 1 do
        aBoard.StringGridVolumes.Cells[iCol,iRow] :=
          aStorage.FieldByName(stBoard + Format('.Volumes[%d,%d]', [iCol, iRow])).AsString;
    }
    aBoard.Position := gEnv.Engine.TradeCore.Positions.Find(aBoard.Account , aBoard.Symbol);
    aBoard.UpdatePositionInfo;
    aBoard.UpdateOrderLimit
  end;
    // apply visibilities of panels
  SpeedButtonLeftPanelClick(SpeedButtonLeftPanel);
  SpeedButtonRightPanelClick(SpeedButtonRightPanel);
    // apply account change

    // apply preferences
  ApplyPrefs;

    // apply orders
  for i := 0 to FPrefs.BoardCount-1 do
  begin
    if i > FBoards.Count-1 then Break;
    aBoard := FBoards[i];

    if aBoard = nil  then
      Continue;

    for j := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[j];

      if (aOrder.State = osActive)
         and (aOrder.Account = aBoard.Account)
         and (aOrder.Symbol = aBoard.Symbol) then
        aBoard.Tablet.DoOrder(aOrder);
    end;

  end;

  FLoadEnd := true;

end;

procedure TSingleOrderBoardForm.MakeBoards;
var
  i: Integer;
  aBoard: TOrderBoard;
begin
  if FPrefs.BoardCount < FBoards.Count then
  begin
    for i := FBoards.Count-1 downto FPrefs.BoardCount do
      FBoards[i].Free;
  end else
  if FPrefs.BoardCount > FBoards.Count then
    for i := FBoards.Count to FPrefs.BoardCount - 1 do
    begin
      aBoard := NewBoard;
      aBoard.Params := FDefParams;
    end;

end;

procedure TSingleOrderBoardForm.MakeBoards(iCount: integer);
var
  i: Integer;
  aBoard: TOrderBoard;
begin
  FPrefs.BoardCount := iCount;

  if FPrefs.BoardCount < FBoards.Count then
  begin
    for i := FBoards.Count-1 downto FPrefs.BoardCount do
    begin

      if (FBoards[i].Params.ShowForceDist) and ( FBoards[i].Quote <> nil) then
        FBoards[i].Quote.ForceDist := false;
      if (FBoards[i].Params.ShowOrderData) and ( FBoards[i].Quote <> nil) then
        FBoards[i].Quote.ExtrateOrder := false;

      FBoards[i].Free;
    end;
  end else
  if FPrefs.BoardCount > FBoards.Count then
    for i := FBoards.Count to FPrefs.BoardCount - 1 do
    begin
      aBoard := NewBoard;
      aBoard.Params := FDefParams;
    end;

end;

procedure TSingleOrderBoardForm.MatchTablePoint(aBoard: TOrderboard; aPoint1,
  aPoint2: TTabletPoint);
var
  i: Integer;
  aItem: TListItem;
  aOrder: TOrder;
  iSum: Integer;
  stPosition: String;
  aTablet : TOrderTablet;
  theOrders: TOrderList;

  stTmp : string;
  is1, is2, is3, is4 : int64;

begin


  aTablet := aBoard.Tablet;
    // set order list
  if (aPoint1.AreaType = taInfo) and ( aPoint1.RowType = trInfo ) and
     (aPoint1.ColType = tcQuote ) then
  begin
    aBoard.SetPositionVolume;
  end;

  if aPoint1.AreaType <> taOrder then Exit;


  try
    theOrders := TOrderList.Create;

      // save the point
    FCancelPoint := aPoint1;

      // get order list
    aTablet.GetOrders(aPoint1, theOrders);

      // sort order list
    theOrders.SortByAcptTime;

      // change label
    if aTablet.Symbol <> nil then
      LabelSymbol.Caption := aTablet.Symbol.Name;
    if aPoint1.PositionType = ptLong then
      stPosition := 'L'
    else
      stPosition := 'S' ;
    LabelPrice.Caption := stPosition + ' ' + Format('%.2f', [FCancelPoint.Price]) ;
    LabelPrice.Font.Color := clRed;

      // populate list view on the right side pane
    iSum := 0;
    ListViewOrders.Items.Clear;



    for i := 0 to theOrders.Count-1 do
    begin
      aOrder := theOrders[i];
      aItem := ListViewOrders.Items.Add;

      aItem.Data := aOrder;
      // 'Caption' is saved for 'check' mark

      aItem.Checked := True;
      aItem.SubItems.Add(IntToStr(aOrder.Side * aOrder.ActiveQty));
      aItem.SubItems.Add(IntToStr(aOrder.OrderNo));

        // add
      iSum := iSum + aOrder.ActiveQty;
    end;

      // set default volumes
    EditCancelQty.Text := IntToStr(iSum);
    LabelTotalQty.Caption := '/ ' + IntToStr(iSum);

      // todo: reset click?
    for i := 0 to FBoards.Count - 1 do
      if FBoards[i].Tablet <> aTablet then
        FBoards[i].Tablet.ResetClick;
  finally
    theOrders.Free;
  end;


end;

procedure TSingleOrderBoardForm.MaxPriceProc(Sender: TObject);
begin

end;

procedure TSingleOrderBoardForm.MinPriceProc(Sender: TObject);
begin

end;

function TSingleOrderBoardForm.NewBoard: TOrderBoard;
begin
  Result := FBoards.New;

  if Result <> nil then
  begin
    Result.OnSelect := BoardSelect;
    Result.OnSetup := BoardSetup;
    Result.OnSetSymbol  := SymbolSelect;
    Result.OnSymbolSelect := SymbolSelect;
    Result.OnQtySelect    := QtySetSelect;
    Result.initQtyCombo;
      // popup menu for order tablet
    Result.Tablet.PopOrders := PopupMenuOrders;

      // assign event handlers
    Result.Tablet.OnNewOrder := BoardNewOrder;
    Result.Tablet.OnChangeOrder := BoardChangeOrder;
    Result.Tablet.OnCancelOrder := BoardCancelOrder;
    Result.Tablet.OnSelectCell := BoardSelectCell;
    Result.Tablet.OnOrientCount := BoardsOrientCount;

    Result.Tablet.OnReadyOrder  := BoardReadyOrder;
    Result.Tablet.TabletColor := $00EFD2B4;

    { todo:
    Result.ZaprService.OnMinPriceChanged := MinPriceProc;
    Result.ZaprService.OnMaxPriceChanged := MaxPriceProc;
    }
    Result.Tablet.ColWidths[tcOrder]  := ORDER_WIDTH;
    Result.Tablet.ColWidths[tcQuote]  := QTY_WIDTH;
    Result.Tablet.ColWidths[tcPrice]  := PRICE_WIDTH;
    Result.Tablet.ColWidths[tcAdded]  := ADDED_WIDTH;
    Result.Tablet.ColWidths[tcGutter] := GUT_WIDTH;
    Result.Tablet.ColWidths[tcIV]     := IV_WIDTH;

    Result.Tablet.OrderByMouseRB := FPrefs.OrderByMouseRB;
    Result.Tablet.AutoScroll := FPrefs.AutoScroll;
    Result.Tablet.OrientationType := FDefParams.OrientaionType;

    Result.SpeedButtonPrefs.Glyph := SpeedButtonPrefs.Glyph;
      // board: set default order volume
    Result.SetOrderVolume(StrToIntDef(Result.StringGridVolumes.Cells[0,0], 0), True);
      // set dimension
    Result.Resize;
  end;

end;

function TSingleOrderBoardForm.NewOrder(aBoard: TOrderBoard;
  aPoint: TTabletPoint; iVolume: Integer; dPrice: Double): TOrder;
var
  aTicket: TOrderTicket;
  iRes  : integer;
begin
  Result := nil;

    // check
  if (aBoard.Account = nil) or (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
      or (iVolume = 0) then
  begin
    Beep;
    Exit;
  end;

    //
  Application.ProcessMessages;

    // confirm
  if FPrefs.ConfirmOrder then
    if  MessageDlg(Format('(%s,%d,%.2f',
        [aBoard.Tablet.Symbol.Code, iVolume, dPrice]) + ')을 전송하시겠습니까?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;

    // check if 'clearorder' flag set
  if aBoard.ClearOrder and (aBoard.OrderType = aPoint.PositionType) then
  begin
    Beep;
    Exit;
  end;

    // short order volume
  if aPoint.PositionType = ptShort then
    iVolume := -iVolume;

    // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          {
  if aReady <> nil then
    aReady
           }
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, aBoard.Account, aBoard.Tablet.Symbol,
                iVolume, pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);

    //
  if iRes > 0 then
  begin
    aBoard.SentTime := timeGetTime;
  end;


end;

procedure TSingleOrderBoardForm.QtySetSelect(Sender: TObject);

var
  aBoard : TOrderBoard;
  aItem  : TQtyItem;
begin
  aBoard  := Sender as TOrderBoard;
  if aBoard = nil then Exit;

  aItem := GetcomboObject( aBoard.GetQtyCombo ) as TQtyItem;

  aBoard.SetQtySet( aItem );
end;

procedure TSingleOrderBoardForm.QuoteBrokerEventHandler(Sender,
  Receiver: TObject; DataID: Integer; DataObj: TObject;
  EventID: TDistributorID);
var
  i: Integer;
  aBoard: TOrderBoard;
  stTime: String;
  aQuote: TQuote;
begin
  if DataObj = nil then Exit;

  aQuote := DataObj as TQuote;

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if aBoard.Quote <> aQuote then Continue;

    case aQuote.LastEvent of
      qtTimeNSale:
        begin
            // if it's the first feed, initialize tablet
          if not aBoard.Tablet.Ready then
            aBoard.Tablet.Ready := True;

            //
          aBoard.TNSCount := aBoard.TNSCount + 1;

            // apply to the tablet
          aBoard.Tablet.UpdateQuote;
          aBoard.Tablet.UpdatePrice;
          aBoard.TickPainter.Update;
          aBoard.HogaPainter.Update;
          if aBoard.Position <> nil then begin
            //aBoard.Position.DoQuote( aBoard.Quote );
            aBoard.UpdateEvalPL;
            UpdateTotalPl;
          end;

          if aBoard.TNSCount <= 1 then
            aBoard.Tablet.ScrollToLastPrice;

            // display info
          if aBoard = FSelectedBoard then
          begin
              // O,H,L
            if (aQuote.Symbol <> nil) and (aQuote.Symbol.Spec <> nil) then
            begin
              GridInfo.Cells[1,2] := Format('%.*n', [aQuote.Symbol.Spec.Precision, aQuote.Open]);
              GridInfo.Cells[1,3] := Format('%.*n', [aQuote.Symbol.Spec.Precision, aQuote.High]);
              GridInfo.Cells[1,4] := Format('%.*n', [aQuote.Symbol.Spec.Precision, aQuote.Low]);
              GridInfo.Cells[1,5] := Format('%.*n', [aQuote.Symbol.Spec.Precision, aQuote.Last]);

              GridInfo.Cells[1,15] := Format('%.1f', [aQuote.Symbol.DelayMS / 1000.0]);

            end;
              // time & sale
            if aQuote.Sales.Last <> nil then
              GridInfo.Cells[1, 6] := Format('%.0n',[aQuote.Sales.Last.DayVolume*1.0]);

        end;

        end;
      qtMarketDepth:
        begin
          aBoard.Tablet.UpdateQuote;
          aBoard.TickPainter.Update2;
          aBoard.HogaPainter.Update;
        end;
    end;

    if aBoard = FSelectedBoard then
    begin
      if aQuote.Symbol.Spec.Market = mtElw then
        SetInfo( aBoard )
      else if aQuote.Symbol.Spec.Market = mtOption then
        SetOptionInfo(aBoard);
    end;
  end;

end;

procedure TSingleOrderBoardForm.ReLoad;
begin

end;

procedure TSingleOrderBoardForm.ReloadSymbols;
begin
    // reload underlyings
  ComboBoxUnderlyings.Items.Clear;
  gEnv.Engine.SymbolCore.Underlyings.GetList(ComboBoxUnderlyings.Items);

    // populate underlying combo and select
  SetComboIndex(ComboBoxUnderlyings, 0);
  ComboBoxUnderlyingsChange(ComboBoxUnderlyings);
end;

procedure TSingleOrderBoardForm.SaveEnv(aStorage: TStorage);
var
  i, j, k, iCol, iRow: Integer;
  aBoard: TOrderBoard;
  stBoard: String;
begin
  if aStorage = nil then Exit;

    // account
  //if FAccount <> nil then
   // aStorage.FieldByName('Account').AsString := FAccount.Code; // account
    //
  aStorage.FieldByName('ShowLeftPanel').AsBoolean := SpeedButtonLeftPanel.Down;
  aStorage.FieldByName('ShowRightPanel').AsBoolean := SpeedButtonRightPanel.Down;
    // preferences
  aStorage.FieldByName('Prefs.BoardCount').AsInteger := FPrefs.BoardCount;
  aStorage.FieldByName('Prefs.ConfirmOrder').AsBoolean := FPrefs.ConfirmOrder;
  aStorage.FieldByName('Prefs.EnabledClearOrder').AsBoolean := FPrefs.EnableClearOrder;
  aStorage.FieldByName('Prefs.EnabledEscKey').AsBoolean := FPrefs.EnableEscKey;
  aStorage.FieldByName('Prefs.AutoScroll').AsBoolean := FPrefs.AutoScroll;
  aStorage.FieldByName('Prefs.TraceMouse').AsBoolean := FPrefs.TraceMouse;
  aStorage.FieldByName('Prefs.OrderByMouseRB').AsBoolean := FPrefs.OrderByMouseRB;
  aStorage.FieldByName('Prefs.ShowZapr').AsBoolean := FPrefs.ShowZapr;
  aStorage.FieldByName('Prefs.ShowQT').AsBoolean := FPrefs.ShowQT;
  aStorage.FieldByName('Prefs.UseKey1to5').AsBoolean := FPrefs.UseKey1to5;
  for i := 0 to 1 do
    for j := 0 to 1 do
      for k := 0 to 1 do
        aStorage.FieldByName(Format('Prefs.Colors[%d,%d,%d]',[i,j,k])).AsInteger := FPrefs.Colors[i,j,k];
    // default params
  aStorage.FieldByName('DefParams.ShowTNS').AsBoolean := FDefParams.ShowTNS;
  aStorage.FieldByName('DefParams.TNSOnLeft').AsBoolean := FDefParams.TNSOnLeft;
  aStorage.FieldByName('DefParams.TNSRowCount').AsInteger := FDefParams.TNSRowCount;
  aStorage.FieldByName('DefParams.UseTNSVolumeFilter').AsBoolean := FDefParams.UseTNSVolumeFilter;
  aStorage.FieldByName('DefParams.TNSVolumeThreshold').AsInteger := FDefParams.TNSVolumeThreshold;
  aStorage.FieldByName('DefParams.OrientationType').AsInteger := Integer( FDefParams.OrientaionType );

  aStorage.FieldByName('DefParams.MergeQuoteColumns').AsBoolean := FDefParams.MergeQuoteColumns;
  aStorage.FieldByName('DefParams.MergedQuoteOnLeft').AsBoolean := FDefParams.MergedQuoteOnLeft;
  aStorage.FieldByName('DefParams.ShowOrderColumn').AsBoolean := FDefParams.ShowOrderColumn;
  aStorage.FieldByName('DefParams.ShowIVColumn').AsBoolean := FDefParams.ShowIVColumn;
  aStorage.FieldByName('DefParams.ShowForceDist').AsBoolean := FDefParams.ShowForceDist;
  aStorage.FieldByName('DefParams.FillterOrderQty').AsInteger := FDefParams.FillterOrderQty;
  aStorage.FieldByName('DefParams.FillterOrderHoga').AsInteger := FDefParams.FillterOrderHoga;
    // boards
  aStorage.FieldByName('boards.count').AsInteger := FBoards.Count; // number of boards
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    stBoard := Format('Board[%d]', [i]);

    if (aBoard <> nil) and (aBoard.Symbol <> nil) then
      aStorage.FieldByName(stBoard + '.symbol').AsString := aBoard.Symbol.Code
    else
      aStorage.FieldByName(stBoard + '.symbol').AsString := '';

    if (aBoard <> nil) and (aBoard.Account <> nil) then
      aStorage.FieldByName(stBoard + '.Account').AsString := aBoard.Account.Code
    else
      aStorage.FieldByName(stBoard + '.Account').AsString := '';

    aStorage.FieldByName(stBoard + '.QtySetName').AsString := aBoard.GetQtySetName;

      // parameters
    aStorage.FieldByName(stBoard + '.Params.ShowTNS').AsBoolean            := aBoard.Params.ShowTNS;
    aStorage.FieldByName(stBoard + '.Params.TNSOnLeft').AsBoolean          := aBoard.Params.TNSOnLeft;
    aStorage.FieldByName(stBoard + '.Params.TNSRowCount').AsInteger        := aBoard.Params.TNSRowCount;
    aStorage.FieldByName(stBoard + '.Params.UseTNSVolumeFilter').AsBoolean := aBoard.Params.UseTNSVolumeFilter;
    aStorage.FieldByName(stBoard + '.Params.TNSVolumeThreshold').AsInteger := aBoard.Params.TNSVolumeThreshold;
    aStorage.FieldByName(stBoard + '.Params.OrientationType').AsInteger    := Integer( aBoard.Params.OrientaionType );

    aStorage.FieldByName(stBoard + '.Params.MergeQuoteColumns').AsBoolean  := aBoard.Params.MergeQuoteColumns;
    aStorage.FieldByName(stBoard + '.Params.MergedQuoteOnLeft').AsBoolean  := aBoard.Params.MergedQuoteOnLeft;
    aStorage.FieldByName(stBoard + '.Params.ShowOrderColumn').AsBoolean    := aBoard.Params.ShowOrderColumn;
    aStorage.FieldByName(stBoard + '.Params.ShowIVColumn').AsBoolean       := aBoard.Params.ShowIVColumn;
    aStorage.FieldByName(stBoard + '.Params.ShowOrderData').AsBoolean      := aBoard.Params.ShowOrderData;
    aStorage.FieldByName(stBoard + '.Params.ShowOrderCount').AsInteger     := aBoard.Params.ShowOrderCount;
    aStorage.FieldByName(stBoard + '.Params.ShowForceDist').AsBoolean      := aBoard.Params.ShowForceDist;
    aStorage.FieldByName(stBoard + '.Params.FillterOrderQty').AsInteger    := aBoard.Params.FillterOrderQty;
    aStorage.FieldByName(stBoard + '.Params.FillterOrderHoga').AsInteger   := aBoard.Params.FillterOrderHoga;
      // add
    aStorage.FieldByName(stBoard + 'DefParams.TNSPosition').AsInteger       := aBoard.Params.TNSPosition;
    aStorage.FieldByName(stBoard + 'DefParams.ShowAccumulFillBar').AsBoolean:= aBoard.Params.ShowAccumulFillBar;
    aStorage.FieldByName(stBoard + 'DefParams.ShowLpVolumeColumn').AsBoolean:= aBoard.Params.ShowLpVolumeColumn ;
    aStorage.FieldByName(stBoard + 'DefParams.EnterOrdered').AsBoolean      := aBoard.Params.EnterOrdered;

    {
      // order volumes
    for iCol := 0 to aBoard.StringGridVolumes.ColCount - 1 do
      for iRow := 0 to aBoard.StringGridVolumes.RowCount - 1 do
        aStorage.FieldByName(
             stBoard + Format('.Volumes[%d,%d]', [iCol, iRow])).AsString :=
           aBoard.StringGridVolumes.Cells[iCol,iRow];
           }
  end;

end;

procedure TSingleOrderBoardForm.SendReadyOrder;
var
  i : integer;
  aReady  : TReadyOrder;
  aOrder  : TOrder;
begin
  for i := 0 to FSelectedBoard.ReadyOrder.Count - 1 do
  begin
    aOrder  := nil;
    aReady  := TReadyOrder(FSelectedBoard.ReadyOrder.Items[i]);
    if aReady = nil then Continue;
    if aReady.FOrder <> nil then Continue;
    aOrder := NewOrder( FSelectedBoard, aReady.FPoint, aReady.FVolume, aReady.FPrice );
    if aOrder = nil then Continue;
    aReady.FOrder := aOrder;
    //gEnv.OnLog( self, aOrder.Represent );
    break;
  end;


end;

procedure TSingleOrderBoardForm.SetAccount;
begin
  ComboBoAccount.AddItem( gEnv.Engine.TradeCore.Accounts.PresentName, nil );
  ComboBoAccount.ItemIndex  := 0;
end;

procedure TSingleOrderBoardForm.SetAccountInfo;
begin

end;

procedure TSingleOrderBoardForm.SetDefaultParams;
begin
  with FDefParams do
  begin
      // time & sales
    ShowTNS := False;
    TNSOnLeft := False; // default on the right
    TNSRowCount := 20;
    UseTNSVolumeFilter := False;
    TNSVolumeThreshold := 10;
    TNSPosition := 0;
      // orientation

    OrientaionType  := otAuto;

    MergeQuoteColumns := False;
    MergedQuoteOnLeft := True;
      // show
    ShowOrderColumn := True;
    ShowIVColumn := False;
      // elw option
    ShowAccumulFillBar  := false;
    EnterOrdered  := false;
    ShowLpVolumeColumn  := false;

      // 세력분석
    ShowOrderData := false;
    ShowOrderCount := 20;
    ShowForceDist := false;
    FillterOrderQty := 0;
    FillterOrderHoga := 3;
  end;
end;

procedure TSingleOrderBoardForm.SetDefaultPrefs;
begin

  with FPrefs do
  begin
      // generice
    BoardCount := 1;
      // order
    ConfirmOrder := False;
    EnableClearOrder := True;
    EnableEscKey := True;
      // board
    AutoScroll := False;
    TraceMouse := True;
    OrderByMouseRB := True;
    ShowZapr := False;
    ShowQT := False;
    UseKey1to5 := True;
      // colors
    Colors[IDX_LONG,  IDX_ORDER, IDX_FONT] := clBlack;
    Colors[IDX_SHORT, IDX_ORDER, IDX_FONT] := clBlack;
    Colors[IDX_LONG,  IDX_QUOTE, IDX_FONT] := clBlack;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT] := clBlack;
    {
    Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND] := $E4E2FC;
    Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND] := $F5E2DA;
    Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND] := $E4E2FC;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND] := $F5E2DA;
    }
    Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND] := clWhite;
    Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND] := clWhite;
    Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND] := $C4C4FF;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND] := $FFC4C4;
  end;
end;

procedure TSingleOrderBoardForm.SetElwInfo(aBoard: TOrderBoard);
var
  aElw : TElw;
  stName  : string;
  U , E , R , T , TC , W : Double;
  ExpireDateTime: TDateTime;
  aIV, bIV : Double;
begin
  aElw  := aBoard.Symbol as TELW;

  if aElw.Underlying <> nil then
  begin
    U := aElw.Underlying.Last;
    E := aElw.StrikePrice;
    if gEnv.Engine.SymbolCore.Future <> nil then
      R := gEnv.Engine.SymbolCore.Future.CDRate
    else
      R := 0;


    ExpireDateTime := Floor(gEnv.Engine.QuoteBroker.Timers.Now)
                         + aElw.DaysToExp - 1 + EncodeTime(15,15,0,0);
    T := gEnv.Engine.Holidays.CalcDaysToExp(gEnv.Engine.QuoteBroker.Timers.Now,
                                            ExpireDateTime, rcCalTime);
    TC := aElw.DaysToExp / 365;

    if aElw.CallPut = 'C' then
      W := 1
    else
      W := -1;
    aIV :=       IV(U, E, R, T, TC, aElw.Last, W ) ;        
  end
  else aIV  := 0.0;

  with GridInfo do
  begin

    Cells[0,7] := '틱델타' ;
    Cells[0,8] := '틱비율' ;
    Cells[0,9] := 'IV-K' ;
    Cells[0,10] := 'IV' ;
    Cells[0,11] := 'LP' ;
    //
    Cells[0,12] := '잔존일수' ;
    Cells[0,13] := 'LP비중' ;
    Cells[0,14] := '주문시간' ;
    Cells[0,15] := '시세지연' ;

    Cells[1,5] := Format('%.*n', [aElw.Spec.Precision, aElw.Last]);
    Cells[1,7] := Format('%.3f', [aElw.TickDelta]);
    Cells[1,8] := Format('%.3f', [aElw.TickRatio]);
    Cells[1,9] := Format('%.2f', [aElw.IV]);
    Cells[1,10] := Format('%.2f', [aIV]);
    stName  :=  TLP(gEnv.Engine.SymbolCore.LPs.Find( aElw.LPCode )).LpName;
    if Length( stName ) > 8 then
      stName  := Copy( stName , 1, 8 );
    Cells[1,11] := stName;
    //
    Cells[1,12] := IntToStr( aElw.DaysToExp );
    Cells[1,13] := Format('%.2f%s', [aElw.LPGravity,'%']);


  end;


end;

procedure TSingleOrderBoardForm.SetExSymbol(aSymbol: TSymbol;
  aMarket: TMarketType);
var
  aUnderlying : TSymbol;
  i, iUnder: Integer;
  aOrder: TOrder;
  aGrid : TStringGrid ;
  stLeftDesc, stRightDesc : String ;  
begin
  if (aSymbol = nil) or (FBoards.Count = 0) then Exit;
  if FBoards.Count <> 2 then begin
    SetSymbol( aSymbol );
    Exit;
  end;
  // 보드카운트가 2일때만...ㅋㅋㅋ
  //if FBoards[1].Symbol = aSymbol then Exit;

  if aMarket in  [mtFutures, mtOption] then
    aUnderlying := (aSymbol as TDerivative).Underlying
  else begin
    aUnderlying := (aSymbol as TELW).Underlying ;
    if aUnderlying = nil then Exit;

    // 기초자산에 대한 처리...
    //
    iUnder  := 0;
    if FBoards[iUnder].Symbol <> nil then
      gEnv.Engine.QuoteBroker.Cancel(FBoards[iUnder], FBoards[iUnder].Symbol);

    FBoards[iUnder].Tablet.Ready := False;
    FBoards[iUnder].DeliveryTime := '';
      // 계좌 처리 먼저 한다...
    FBoards[iUnder].Account :=
      gEnv.Engine.TradeCore.Accounts.GetMarketAccount( aUnderlying.Spec.Market);

      // set symbol and subscribe
    FBoards[iUnder].Symbol := aUnderlying;
    FBoards[iUnder].Quote := gEnv.Engine.QuoteBroker.Subscribe( FBoards[iUnder], aUnderlying,
                              QuoteBrokerEventHandler);
    FBoards[iUnder].AddSymbol( aUnderlying );
      // assign position
    FBoards[iUnder].Position := gEnv.Engine.TradeCore.Positions.Find(FBoards[iUnder].Account , aUnderlying);

      // apply orders
    for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

      if (aOrder.State = osActive)
         and (aOrder.Account = FBoards[iUnder].Account)
         and (aOrder.Symbol = FBoards[iUnder].Symbol) then
        FBoards[iUnder].Tablet.DoOrder(aOrder);
    end;

      // update order limite
    FBoards[iUnder].UpdatePositionInfo;
    FBoards[iUnder].UpdateOrderLimit;
      // fill count
    FBoards[iUnder].TNSCount := 0;
      //
    FBoards[iUnder].Resize;
      // if quote has been subscribed somewhere else
    if (FBoards[iUnder].Quote <> nil)
       and (FBoards[iUnder].Quote.EventCount > 0) then
      QuoteBrokerEventHandler(FBoards[iUnder].Quote, Self, 0, FBoards[iUnder].Quote, 0);
  end;

  // 파생상품에 대한 처리...
  //      
  BoardSelect(FBoards[1]);
    // unsubscribe
  if FSelectedBoard.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel(FSelectedBoard, FSelectedBoard.Symbol);
    //
  FSelectedBoard.Tablet.Ready := False;
  FSelectedBoard.DeliveryTime := '';

    // 계좌 처리 먼저 한다...
  FSelectedBoard.Account :=
    gEnv.Engine.TradeCore.Accounts.GetMarketAccount( aSymbol.Spec.Market);

    // set symbol and subscribe
  FSelectedBoard.Symbol := aSymbol;
  FSelectedBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(FSelectedBoard, aSymbol,
                            QuoteBrokerEventHandler);
  FSelectedBoard.AddSymbol( aSymbol );
    // assign position
  FSelectedBoard.Position := gEnv.Engine.TradeCore.Positions.Find(FSelectedBoard.Account , aSymbol);

    // apply orders
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = FSelectedBoard.Account)
       and (aOrder.Symbol = FSelectedBoard.Symbol) then
      FSelectedBoard.Tablet.DoOrder(aOrder);
  end;

    // update order limite
  FSelectedBoard.UpdatePositionInfo;
  FSelectedBoard.UpdateOrderLimit;
    // fill count
  FSelectedBoard.TNSCount := 0;

    // clear info window
  for i := 0 to GridInfo.RowCount - 1 do
  begin
    GridInfo.Cells[1,i] := '' ;
  end;

    //
  FLastSynFutures := 0;

    //
  FSelectedBoard.Resize;

    // if quote has been subscribed somewhere else
  if (FSelectedBoard.Quote <> nil)
     and (FSelectedBoard.Quote.EventCount > 0) then
    QuoteBrokerEventHandler(FSelectedBoard.Quote, Self, 0, FSelectedBoard.Quote, 0);

end;

procedure TSingleOrderBoardForm.SetInfo(aBoard: TOrderBoard);
var
  i: Integer;
begin
    // synthetic futures
  if (aBoard.Tablet.Symbol <> nil) and (  aBoard.Tablet.Symbol.Spec.Market in [mtElw, mtStock] ) then
  begin
    if aBoard.Tablet.Symbol.Spec.Market = mtElw then begin
      GridInfo.Cells[0,0] := '기초자산';
      GridInfo.Cells[1,0] := (aBoard.Tablet.Symbol as TElw).Underlying.Name;
      GridInfo.Cells[1,1] := aBoard.Tablet.Symbol.ShortCode;
    end
    else begin
      GridInfo.Cells[0,0] := '종목명';
      GridInfo.Cells[1,0] := aBoard.Tablet.Symbol.Name;
      GridInfo.Cells[1,1] := aBoard.Tablet.Symbol.ShortCode;
    end;
  end
  else begin
    GridInfo.Cells[0,0] := '합성선물';
    if FSynFutures <> nil then
      GridInfo.Cells[1,0] := Format('%.2f', [FSynFutures.Last])
    else
      GridInfo.Cells[1,0] := '';

    if (aBoard.Tablet.Symbol <> nil) then
      GridInfo.Cells[1,1] := aBoard.Tablet.Symbol.Code
    else
      GridInfo.Cells[1,1] := '';
  end;

  with GridInfo do
  begin
    Cells[0,7] := '델타' ;
    Cells[0,8] := '감마' ;
    Cells[0,9] := '세타' ;
    Cells[0,10] := '베가' ;
    Cells[0,11] := 'IV' ;
    //
    Cells[0,12] := '당일손익' ;
    Cells[0,13] := '추정수수료' ;
    Cells[0,14] := '주문시간' ;
    Cells[0,15] := '시세지연' ;
  end;

    // price range
  if (aBoard <> nil) and (aBoard.Tablet.Symbol <> nil)
      and (aBoard.Tablet.Symbol.Spec <> nil) then
  begin
    with aBoard.Tablet.Symbol do
    begin
      GridInfo.Cells[1,2] := Format('%.*n', [Spec.Precision, DayOpen]);
      GridInfo.Cells[1,3] := Format('%.*n', [Spec.Precision, DayHigh]);
      GridInfo.Cells[1,4] := Format('%.*n', [Spec.Precision, DayLow]);
      GridInfo.Cells[1,5] := Format('%.*n', [Spec.Precision, Last]);
    end;
      // if it's option
    if aBoard.Tablet.Symbol.Spec.Market = mtOption then
      SetOptionInfo(aBoard)
    else if aBoard.Tablet.Symbol.Spec.Market = mtElw then
      SetElwInfo( aBoard)
    else if (aBoard.Tablet.Symbol.Spec.Market = mtFutures) and
      ( not aBoard.Tablet.Symbol.IsStockF ) then
      GridInfo.Cells[1,0] := Format('%.2f', [FSynFutures.Last])
    else begin
      for i := 6 to GridInfo.RowCount-2 do
        GridInfo.Cells[1,i] := '';
    end;
    GridInfo.Cells[1,15] := '';
  end else
  begin
    GridInfo.Cells[1,2] := '';
    GridInfo.Cells[1,3] := '';
    GridInfo.Cells[1,4] := '';
  end;

    // trade volume
  if (aBoard <> nil) and (aBoard.Tablet.Quote <> nil)
     and (aBoard.Tablet.Quote.Sales.Last <> nil) then
    GridInfo.Cells[1, 6] := Format('%.0n',[aBoard.Tablet.Quote.Sales.Last.DayVolume*1.0])
  else
    GridInfo.Cells[1, 6] := '';

end;

procedure TSingleOrderBoardForm.SetOptionInfo(aBoard: TOrderBoard);
var
  anOption: TOption;
  U , E , R , T , TC , W : Double;
  ExpireDateTime: TDateTime;
  dDelta, aIV, dGamma, dTheta, dVega : Double ;
  aGrid : TStringGrid ;
  aElw : TElw;
  stTxt : string;
begin
    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) or
     (aBoard.Tablet.Symbol.Spec = nil) or
     (aBoard.Tablet.Symbol.Spec.Market <> mtOption) then Exit;

    // get option object
  anOption := aBoard.Tablet.Symbol as TOption;

  try
      // get parameters
    U := FSynFutures.Last;
    E := anOption.StrikePrice;
    R := anOption.CDRate;

    ExpireDateTime := GetQuoteDate
                         + anOption.DaysToExp - 1 + EncodeTime(15,15,0,0);

    //stTxt := Format( '%s ', [FormatDateTime(' hh : mm : ss ', ExpireDateTime )]);
    T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime,
                                            ExpireDateTime, rcTrdTime);
    TC := anOption.DaysToExp / 365;

    if anOption.CallPut = 'C' then
      W := 1
    else
      W := -1;

    with GridInfo do begin
      Cells[0,7] := '델타' ;
      Cells[0,8] := '감마' ;
      Cells[0,9] := '세타' ;
      Cells[0,10] := '베가' ;
      Cells[0,11] := 'IV' ;
      //
      Cells[0,12] := '당일손익' ;
      Cells[0,13] := '추정수수료' ;
      Cells[0,14] := '주문시간' ;
      Cells[0,15] := '시세지연' ;
    end;
                  {
    aElw.Underlying.Last;
    aElw.StrikePrice;
    aElw.CDRate;
    gEnv.Engine.Holidays.CalcDaysToExp( gEnv.Engine.QuoteBroker.Timers.Now,
         ExpireDateTime ,
        }


      // calc greek values
    aIV :=       IV(U, E, R, T, TC, anOption.Last, W ) ;
    dDelta := Delta(U, E, R, aIV, T, TC, W ) ;
    dGamma := Gamma(U, E, R, aIV, T, TC )  ;
    dTheta := Theta(U, E, R, aIV, T, TC,
                      gEnv.Engine.Holidays.WorkingDaysInYear, W ) ;
    dVega :=  Vega (U, E, R, aIV, T, TC, W ) ;

      // show
    with GridInfo do
    begin
      Cells[1,0] := Format('%.2f', [FSynFutures.Last]);
      Cells[1,7] := Format('%.3f', [dDelta]);
      Cells[1,8] := Format('%.3f', [dGamma]);
      Cells[1,9] := Format('%.3f', [dTheta]);
      Cells[1,10] := Format('%.3f', [dVega]);
      Cells[1,11] := Format('%.3f', [aIV]) ;
    end;

      // if the change of the systhetic futures prices is more than 0.02
    if Abs(FSynFutures.Last - FLastSynFutures) > ( 0.02 + PRICE_EPSILON) then
    begin
      aBoard.Tablet.CalcIV(U, E, R, T, TC, W);
      FLastSynFutures := FSynFutures.Last;
    end;
  except
    //
  end;

end;

procedure TSingleOrderBoardForm.SetOptionPositions;
begin

end;

procedure TSingleOrderBoardForm.SetPosition(aPosition: TPosition);
var
  aFuture: TFuture;
  aOptionTree: TOptionTree;
  i: Integer;
begin
  if (aPosition = nil)
     or (aPosition.Symbol = nil)
     or (aPosition.Symbol.Spec = nil)
     {or (aPosition.Account <> FAccount)} then Exit;

  case aPosition.Symbol.Spec.Market of
    mtStock:
      if (FUnderlying <> nil) and (FUnderlying = aPosition.Symbol) then
      begin
        StaticTextUnderlying.Caption := IntToStr(aPosition.Volume);
      end;
    mtFutures:
      if (FFutures <> nil) and (FFutures = aPosition.Symbol) then
      begin
        StaticTextFutures.Caption := IntToStr(aPosition.Volume);

        if (aPosition.ActiveBuyOrderVolume + aPosition.ActiveSellOrderVolume) > 0 then
          StaticTextFutures.Color := $00FFE7B3
        else
          StaticTextFutures.Color := $00EEEEEE;
      end;
    mtSpread:
      if (FSpread <> nil) and (FSpread = aPosition.Symbol) then
      begin
        StaticTextSpread.Caption := IntToStr(aPosition.Volume);

        if (aPosition.ActiveBuyOrderVolume + aPosition.ActiveSellOrderVolume) > 0 then
          StaticTextSpread.Color := $00FFE7B3
        else
          StaticTextSpread.Color := $00EEEEEE;
      end;
    mtOption:
      for i := 1 to StringGridOptions.RowCount - 1 do
      begin
          // call
        if StringGridOptions.Objects[0, i] = aPosition.Symbol then
        begin
          StringGridOptions.Cells[0,i] := IntToStr(aPosition.Volume);
          Break;
        end;
          // put
        if StringGridOptions.Objects[2, i] = aPosition.Symbol then
        begin
          StringGridOptions.Cells[2,i] := IntToStr(aPosition.Volume);
          Break;
        end;
      end;
    mtELW:
      for i := 1 to StringGridELWs.RowCount - 1 do
      begin
        if StringGridELWs.Objects[0, i] = aPosition.Symbol then
        begin
          StringGridELWs.Cells[3,i] := IntToStr(aPosition.Volume);
          Break;
        end;
      end;
  end;

end;

procedure TSingleOrderBoardForm.SetQtySet(aItem: TQtyItem);
begin

end;

procedure TSingleOrderBoardForm.SetStringGridELWs(aList: TSymbolList);
var
  i: Integer;
  aELW: TELW;
  aPosition: TPosition;
begin
  if aList = nil then Exit;

  with StringGridELWs do
  begin
      // clear
    RowCount := 1;
      // set row count
    RowCount := aList.Count+1;

      // set symbols
    for i := 0 to aList.Count - 1 do
    begin
      aELW := aList[i] as TELW;

      Cells[0,i+1] := aELW.Issuer;
      Cells[1,i+1] := aELW.LPCode;
      Cells[2,i+1] := IntToStr(aELW.DaysToExp);

        // set position volume
      aPosition := gEnv.Engine.TradeCore.Positions.Find(aELW);
      if aPosition <> nil then
        Cells[3,i+1] := IntToStr(aPosition.Volume)
      else
        Cells[3,i+1] := '';

        // set objects
      Objects[0, i+1] := aELW;
      Objects[1, i+1] := aELW;
      Objects[2, i+1] := aELW;
      Objects[3, i+1] := aELW;
    end;
  end;

end;

procedure TSingleOrderBoardForm.SetSymbol(aSymbol: TSymbol);
var
  iRow, iCol, i: Integer;
  aOrder: TOrder;
  CanSelected : Boolean;
  aGrid : TStringGrid ;
  stLeftDesc, stRightDesc : String ;
  aAcnt   : TAccount;
begin
  if (aSymbol = nil) or (FBoards.Count = 0) then Exit;

  if FSelectedBoard = nil then
    BoardSelect(FBoards[0]);

    // check still
  if FSelectedBoard = nil then Exit;

    // add to the cache
  gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(aSymbol);

    // unsubscribe
  if FSelectedBoard.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel(FSelectedBoard, FSelectedBoard.Symbol);

    //
  FSelectedBoard.Tablet.Ready := False;
  FSelectedBoard.DeliveryTime := '';

    // 계좌 처리 먼저 한다...
  FSelectedBoard.Account  :=
    gEnv.Engine.TradeCore.Accounts.GetMarketAccount( aSymbol.Spec.Market);

    // set symbol and subscribe
  FSelectedBoard.Symbol := aSymbol;
  FSelectedBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(FSelectedBoard, aSymbol,
                            QuoteBrokerEventHandler);
  FSelectedBoard.AddSymbol( aSymbol );

  if FSelectedBoard.Account = nil then Exit;
    // assign position
  FSelectedBoard.Position := gEnv.Engine.TradeCore.Positions.Find(FSelectedBoard.Account , aSymbol);

    // apply orders
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = FSelectedBoard.Account)
       and (aOrder.Symbol = FSelectedBoard.Symbol) then
      FSelectedBoard.Tablet.DoOrder(aOrder);
  end;

    // update order limite
  FSelectedBoard.UpdatePositionInfo;
  FSelectedBoard.UpdateOrderLimit;

    // fill count
  FSelectedBoard.TNSCount := 0;

    // clear info window
  for i := 0 to GridInfo.RowCount - 1 do
  begin
    GridInfo.Cells[1,i] := '' ;
  end;

    //
  FLastSynFutures := 0;

    //
  FSelectedBoard.Resize;

    // if quote has been subscribed somewhere else
  if (FSelectedBoard.Quote <> nil)
     and (FSelectedBoard.Quote.EventCount > 0) then
    QuoteBrokerEventHandler(FSelectedBoard.Quote, Self, 0, FSelectedBoard.Quote, 0);

end;

procedure TSingleOrderBoardForm.SetSymbol2(aSymbol: TSymbol;
  aMarket: TMarketType);
var
  iRow, iCol, i: Integer;
  aOrder: TOrder;
  CanSelected : Boolean;
  aGrid : TStringGrid ;
  stLeftDesc, stRightDesc : String ;
begin
  if (aSymbol = nil) or (FBoards.Count = 0) then Exit;

  if FSelectedBoard = nil then
    BoardSelect(FBoards[0]);

    // check still
  if FSelectedBoard = nil then Exit;

    // add to the cache
  gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(aSymbol);

    // unsubscribe
  if FSelectedBoard.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel(FSelectedBoard, FSelectedBoard.Symbol);

    //
  FSelectedBoard.Tablet.Ready := False;
  FSelectedBoard.DeliveryTime := '';

    // 계좌 처리 먼저 한다...
  FSelectedBoard.Account  :=
    gEnv.Engine.TradeCore.Accounts.GetMarketAccount( aSymbol.Spec.Market);

    // set symbol and subscribe
  FSelectedBoard.Symbol := aSymbol;
  FSelectedBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(FSelectedBoard, aSymbol,
                            QuoteBrokerEventHandler);
  FSelectedBoard.AddSymbol( aSymbol );

  if FSelectedBoard.Account = nil then Exit;

    // assign position
  FSelectedBoard.Position := gEnv.Engine.TradeCore.Positions.Find(FSelectedBoard.Account , aSymbol);

    // apply orders
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = FSelectedBoard.Account)
       and (aOrder.Symbol = FSelectedBoard.Symbol) then
      FSelectedBoard.Tablet.DoOrder(aOrder);
  end;

    // update order limite
  FSelectedBoard.UpdatePositionInfo;
  FSelectedBoard.UpdateOrderLimit;

    // fill count
  FSelectedBoard.TNSCount := 0;

    // clear info window
  for i := 0 to GridInfo.RowCount - 1 do
  begin
    GridInfo.Cells[1,i] := '' ;
  end;

    //
  FLastSynFutures := 0;

    //
  FSelectedBoard.Resize;

    // if quote has been subscribed somewhere else
  if (FSelectedBoard.Quote <> nil)
     and (FSelectedBoard.Quote.EventCount > 0) then
    QuoteBrokerEventHandler(FSelectedBoard.Quote, Self, 0, FSelectedBoard.Quote, 0);

end;

procedure TSingleOrderBoardForm.SetWidth;
var
  i, iWidth: Integer;
begin

  iWidth := 0;

  if SpeedButtonLeftPanel.Down then
    iWidth := iWidth + SIDE_LEFT_PANEL_WIDTH;


  for i := 0 to FBoards.Count - 1 do
  begin
    iWidth := iWidth + FBoards[i].Width;
  end;

  if SpeedButtonRightPanel.Down then
    iWidth := iWidth + SIDE_RIGHT_PANEL_WIDTH;


  ClientWidth := iWidth;
  Left  := FLeftPos;

end;

procedure TSingleOrderBoardForm.SpeedButtonLeftPanelClick(Sender: TObject);
begin

    // control size
  if SpeedButtonLeftPanel.Down then begin
    PanelLeft.Width := SIDE_LEFT_PANEL_WIDTH ;
    if FLoadEnd then
      FLeftPos  := Left - SIDE_LEFT_PANEL_WIDTH
    else
      FLeftPos  := Left;
  end
  else begin
    PanelLeft.Width := 0;
    if FLoadEnd then
      FLeftPos  := Left + SIDE_LEFT_PANEL_WIDTH
    else
      FLeftPos  := Left;
  end;


    // set form width
  SetWidth;
end;

procedure TSingleOrderBoardForm.SpeedButtonPrefsClick(Sender: TObject);

var
  aDlg: TBoardPrefDialog;
  i: Integer;
begin
  aDlg := TBoardPrefDialog.Create(Self);
  FLeftPos := Left;
  try
    aDlg.Prefs := FPrefs;

    if aDlg.Open( true ) then
    begin
      FPrefs:= aDlg.Prefs;
        // apply
      ApplyPrefs;
    end;
  finally
    aDlg.Free;
  end;
end;

procedure TSingleOrderBoardForm.SpeedButtonRightPanelClick(Sender: TObject);
begin
    // control size
  FLeftPos  := Left;
  if SpeedButtonRightPanel.Down then
    PanelRight.Width := SIDE_RIGHT_PANEL_WIDTH
  else
    PanelRight.Width := 0;

    // set form width
  SetWidth;
end;

procedure TSingleOrderBoardForm.StaticTextFuturesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  aFuture: TFuture;
begin
    // get selected future
  aFuture := GetComboObject(ComboBoxFutures) as TFuture;
    // set to the last selected board
  if aFuture = nil then
    Exit;
    // 기초자산이 k200 이 아닌종목에 대해서 처리
  if aFuture.IsStockF then
    SetExSymbol(aFuture, mtFutures)
  else
    SetSymbol(aFuture);

end;

procedure TSingleOrderBoardForm.StaticTextSpreadMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  aSpread: TSpread;
begin
    // get selected future
  aSpread := GetComboObject(ComboBoxSpreads) as TSpread;

    // set to the last selected board
  if aSpread <> nil then
    SetSymbol(aSpread);
end;

procedure TSingleOrderBoardForm.StaticTextUnderlyingMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  aULGroup: TMarketGroup;
begin
    // get the selected group
  aULGroup := GetComboObject(ComboBoxUnderlyings) as TMarketGroup;
  if aULGroup = nil then Exit;

    // set
  if (aULGroup.Ref <> nil) and (aULGroup.Ref.Spec <> nil)
     and (aULGroup.Ref.Spec.Market = mtStock) then
    SetSymbol(aULGroup.Ref);

end;

procedure TSingleOrderBoardForm.StringGridOptionsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aPosition : TPosition;
begin
  with StringGridOptions.Canvas do
  begin
    Font.Name := StringGridOptions.Font.Name;
    Font.Size := StringGridOptions.Font.Size;
    //
    if gdFixed in State then
    begin
      Brush.Color := FIXED_COLOR;
      Font.Color := clBlack;
    end else
    if aCol = 1 then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;
    end else
    if [gdSelected, gdFocused] <= State then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    if StringGridOptions.Cells[aCol, aRow] <> '' then
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end else
    begin
      Brush.Color := NODATA_COLOR;
    end;
      // background
    FillRect(Rect);
      // text
    stText := StringGridOptions.Cells[aCol, aRow];

    aPosition := gEnv.Engine.TradeCore.Positions.Find( TSymbol(StringGridOptions.Objects[aCol,aRow]));

    if aPosition <> nil then
      if (aPosition.ActiveBuyOrderVolume + aPosition.ActiveSellOrderVolume) > 0 then
        begin
          Brush.Color := $00FFE7B3;
          Font.Color := clBlack;
        end;
      //
    if stText <> '' then
    begin
        // calc position
      aSize := TextExtent(stText);
      iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - aSize.cx) div 2;
        // put text
      TextRect(Rect, iX, iY, stText);
    end;
  end;

end;

procedure TSingleOrderBoardForm.StringGridOptionsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iCol, iRow: Integer;
  aOption: TOption;
begin
    // get col & row
  StringGridOptions.MouseToCell(X,Y, iCol, iRow);
  if (iCol = -1) or (iRow = -1)
     or (iCol = 1) or (iRow = 0)
     or not (StringGridOptions.Objects[iCol,iRow] is TSymbol) then Exit;

    // set selection on the grid
  StringGridOptions.Col := iCol;
  StringGridOptions.Row := iRow;

    // get selected option
  aOption := StringGridOptions.Objects[iCol,iRow] as TOption;
  if aOption = nil then Exit;

    // set symbol
  SetSymbol(aOption);

end;

procedure TSingleOrderBoardForm.StringGridOptionsMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;

procedure TSingleOrderBoardForm.StringGridOptionsMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;

procedure TSingleOrderBoardForm.SymbolSelect(aSymbol: TSymbol);
var
  aItem : TListItem;
  oSymbol : TSymbol;
  I: Integer;
  Code   : string;
begin
  for I := 0 to lvSymbolList.Items.Count - 1 do
  begin
    aItem := lvSymbolList.Items[i];
    oSymbol :=  TSymbol( aItem.Data );
    if aSymbol = oSymbol then begin
      Exit;
    end;
  end;

  if lvSymbolList.Items.Count >= 15 then
    lvSymbolList.Items.Delete(lvSymbolList.Items.Count-1);

  aItem := lvSymbolList.Items.Insert(0) ;
  aItem.Data  := aSymbol;
  aItem.Caption := aSymbol.ShortName;

  if aSymbol.Spec.Market in [mtElw, mtStock] then  
    Code  := aSymbol.ShortCode
  else
    Code  := aSymbol.Code;

  aItem.SubItems.Add( Code );

end;

procedure TSingleOrderBoardForm.SymbolSelect(Sender: TObject);

var
  i: Integer;
  aBoard: TOrderBOard;
  aSymbol : TSymbol;
  aOrder   : TOrder;
begin
  aBoard  := Sender as TOrderBoard;
  if aBoard = nil then Exit;

  aSymbol := GetComboObject( aBoard.GetSymbolCombo ) as TSymbol;
  if aSymbol = nil then Exit;

  SetSymbol( aSymbol );
end;

procedure TSingleOrderBoardForm.TradeBrokerEventHandler(Sender,
  Receiver: TObject; DataID: Integer; DataObj: TObject;
  EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_SPAWN,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
      // fill events
    FILL_NEW: ;
      // position events
    POSITION_NEW,
    POSITION_UPDATE: DoPosition(DataObj as TPosition, EventID);
  end;

end;

procedure TSingleOrderBoardForm.UpdateQtySet(aData: TQtyItem;
  vtType: TValueType);
var
  i : integer;
  aBoard : TOrderBoard;
  aItem  : TQtyItem;
begin

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard  := FBoards[i];
    if aBoard = nil then Continue;

    if aBoard.QtyItem = nil then Continue;

    aItem := aBoard.QtyItem;

    case vtType of
      vtAdd, vtUpdate:
        begin
          aBoard.UpdateQtyCombo( aItem );
          aBoard.SetQtySet( aItem );
        end;
      vtDelete:
        begin
          aBoard.DeleteQtySet( aData );
        end;
    end;
  end;


end;

procedure TSingleOrderBoardForm.UpdateTotalPl;
var
  i , j : integer;
  aAccount : TAccount ;
  aPosition : TPosition;
  dFut , dOpt , dS, dTot : double;  // 평가손익
  dFPl, dOPl, dSPl , dTPl : double; // 실현손익

  stFee, stPl : string;
begin
  dFut := 0.0;
  dOpt := 0.0;
  dTot := 0.0;
  dS   := 0.0;
  dFPl := 0.0;
  dOPl := 0.0;
  dSPl := 0.0;
  dTPl := 0.0;


  for i := 0 to gEnv.Engine.TradeCore.Accounts.Count - 1 do
  begin
    aAccount := gEnv.Engine.TradeCore.Accounts.Accounts[i];
    dTot := dTot
      + gEnv.Engine.TradeCore.Positions.GetMarketPl( aAccount, dFut, dOpt, dS  );
  end;

  stPl  := Format( '%10.0n', [ dTot / 1000 ]);// - aAccount.GetFee ]);
  stFee := Format( '%5.0n', [ aAccount.GetFee / 1000]);
  Caption := 'SO  PL : ' + stPl +'    Fee : ' + stFee;    

  if FSelectedBoard <> nil then
  begin

    if FSelectedBoard.Symbol <> nil then
    begin
      if FSelectedBoard.Symbol.Spec.Market <> mtElw then
      begin
        GridInfo.Cells[1,PlRow] := Format('%.0n', [dTot / 1000]);
        GridInfo.Cells[1,FeeRow] := Format('%.0n', [aAccount.GetFee / 1000]);
      end;
    end;
  end;
end;

end.
