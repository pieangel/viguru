unit FOrderBoard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, Buttons, ComCtrls, ImgList,  Menus, Math, Spin,
  MMSystem, DateUtils,
    // lemon: common
  GleTypes, GleLib, GleConsts,
    // lemon: data
  CleFQN, CleSymbols, CleMarkets, CleKrxSymbols, CleQuoteBroker, CleStopOrders,
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
  DBoardParams, DBoardOrder, UAlignedEdit;

{$INCLUDE define.txt}

const
  PlRow = 12;
  FeeRow = 13;

  CHKON = 100;
  CHKOFF = -100;

  TitleCnt = 4;
  TitleInfoCnt = 10;

  CheckCol  = 0;
  OrderCol  = 1;
  SymbolCol = 2;
  ChangeCol = 3;
  ColorCol  = 3;

  InFo_Last_Row = 3;
  InFo_Change_Row = 4;

  Title1 : array [0..TitleCnt-1] of string = ('','종목','','수량');
  Title2 : array [0..TitleCnt-1] of string = ('','종목','','평가');

  //TitleInfo : array [0..TitleInfoCnt-1] of string =
  //  ('시가','고가','저가','종가','전일대비','총거래량','틱가치','틱사이즈','거래소','만기일');

type

  TOrderBoardForm = class(TForm)
    PanelLeft: TPanel;
    PanelMain: TPanel;
    PanelTop: TPanel;
    SpeedButtonLeftPanel: TSpeedButton;
    SpeedButtonRightPanel: TSpeedButton;
    PopupMenuOrders: TPopupMenu;
    N6000X11: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    PanelRight: TPanel;
    N9: TMenuItem;
    FlipSide1: TMenuItem;
    FlipDirection1: TMenuItem;
    FlipSideDirection1: TMenuItem;
    PanelOrderList: TPanel;
    ComboBoAccount: TComboBox;
    tmPriceSort: TTimer;
    reFresh: TTimer;
    edtPw: TEdit;
    SpeedButton7: TSpeedButton;
    Panel5: TPanel;
    Panel9: TPanel;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    Panel10: TPanel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    cbKeyOrder: TCheckBox;
    rbMouseSelect: TRadioGroup;
    rbLastOrdCnl: TRadioGroup;
    cbOneClick: TCheckBox;
    cbDiv1000: TCheckBox;
    Timer1: TTimer;
    Panel4: TPanel;
    sgInterest: TStringGrid;
    ComboBoxUnderlyings: TComboBox;
    ComboBoxOptions: TComboBox;
    StringGridOptions: TStringGrid;
    lbAcntName: TLabel;
    UpDown1: TUpDown;
    Panel1: TPanel;
    Panel8: TPanel;
    sgAcntPL: TStringGrid;
    rgDisplay: TRadioGroup;
    sgDeposit: TStringGrid;
    TabSheet1: TTabSheet;
    Panel2: TPanel;
    Panel3: TPanel;
    LabelSymbol: TLabel;
    LabelPrice: TLabel;
    LabelTotalQty: TLabel;
    ButtonCancel: TButton;
    EditCancelQty: TEdit;
    btnLastCancel: TButton;
    cbBack: TCheckBox;
    ListViewOrders: TListView;
    CheckBox1: TCheckBox;
    PopupMenu1: TPopupMenu;
    N8: TMenuItem;
    N10: TMenuItem;

    procedure SpeedButtonLeftPanelClick(Sender: TObject);
    procedure SpeedButtonRightPanelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure FormDestroy(Sender: TObject);
    procedure StringGridOptionsMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGridOptionsMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);

    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);


    procedure listReadyDblClick(Sender: TObject);

    procedure ComboBoAccountChange(Sender: TObject);

    procedure udControlClick(Sender: TObject; Button: TUDBtnType);
    procedure ComboBoxUnderlyingsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBoxUnderlyingsKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);


    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Button1Click(Sender: TObject);

    procedure sgAcntPLDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

    procedure reFreshTimer(Sender: TObject);

    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInterestDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

    procedure sgInterestMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtPrfTickKeyPress(Sender: TObject; var Key: Char);

    procedure cbKeyOrderClick(Sender: TObject);
    procedure cbOneClickClick(Sender: TObject);
    procedure rbMouseSelectClick(Sender: TObject);


    procedure edtOpenLiskAmtKeyPress(Sender: TObject; var Key: Char);
    procedure sgQuoteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);

    procedure edtTmpQtyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure sbtnActOrdQryClick(Sender: TObject);
    procedure sbtnPosQryClick(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);

    procedure ComboBoxUnderlyingsChange(Sender: TObject);
    procedure ComboBoxOptionsChange(Sender: TObject);
    procedure StringGridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridOptionsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgInterestSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Timer1Timer(Sender: TObject);

    procedure rbLastOrdCnlClick(Sender: TObject);
    procedure rbMarketClick(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure cbDiv1000Click(Sender: TObject);
    procedure rgDisplayClick(Sender: TObject);
    procedure btnLastCancelClick(Sender: TObject);
    procedure EditCancelQtyChange(Sender: TObject);
    procedure EditCancelQtyExit(Sender: TObject);
    procedure EditCancelQtyKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonCancelClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Panel8DblClick(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);


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
    //FPointOrders : TOrderList;
      // temporary Position list -- used in 청산
    FTargetPositions: TPositionList;

      // 순서 제어 변수들.
    FLoadEnd    : boolean;
    FLeftPos    : integer;
    FResize     : boolean;
    FKeyDown    : boolean;
    FInvest     : TInvestor;
    FAccount    : TAccount;

      // 그리드 관련..
    FUfColWidth : integer;
    FUSColWidth : Integer;
    FATMRow, FSaveRow, FSymbolRow    : integer;
    FUnRow     : array [0..1] of integer;
      // 손절 금액
    FLiskAmt : double;
    FLiskChange : boolean;

    FAskCnt, FBidCnt : integer;
    FAskVol, FBidVol : integer;
    FMin  : integer;

    {todo:
    FKeyOrderMap : String;
    //FKeyOrderMapItem : TKeyOrderItem;

    procedure KeyOrderProc(Sender, Receiver, DataObj: TObject;
                       iBroadcastKind: Integer; btValue: TBroadcastType);
    procedure ObserverProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    }

    procedure ReloadSymbols;

    procedure MakeBoards; overload;
    procedure MakeBoards( iCount : integer ) ; overload;

      // init
    procedure InitControls;
    procedure SetAccount;
    procedure SetSymbol(aSymbol : TSymbol);

      // configuration
    procedure ApplyPrefs;
    procedure ApplyPrefs2;
    procedure SetWidth;
    procedure SetDefaultPrefs;
    procedure SetDefaultParams;


       // order tablet events handler
    procedure BoardNewOrder; overload;
    procedure BoardNewOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint); overload;
    procedure BoardChangeOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardLastCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardSelectCell(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardSelect(Sender: TObject);
    procedure BoardAcntSelect( aBoard : TOrderBoard );
    procedure BoardPanelClickEvent( Sender : TObject; iDiv , iTag : integer );

      // send order
    function NewOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iVolume: Integer; dPrice: Double): TOrder; overload;
    function NewOrder(aBoard: TOrderBoard; iSide ,iVolume: Integer; dPrice: Double;
      pcValue : TPriceControl = pcLimit ): TOrder; overload;

    function ChangeOrder(aBoard: TOrderBoard; aPoint1, aPoint2: TTabletPoint): Integer; overload;
    function ChangeOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iMaxQty: Integer; dPrice: Double): Integer; overload;
    function CancelOrders(aBoard: TOrderBoard; aPoint: TTabletPoint;
      iMaxQty: Integer = 0): Integer; overload;
    function CancelOrders(aTablet: TOrderTablet; aTypes: TPositionTypes ): Integer; overload;
    function CancelOrders(aBoard: TOrderBoard; aTypes: TPositionTypes): Integer; overload;
    function CancelOrders(aBoard: TOrderBoard; aPoint : TTabletPoint; aTypes: TPositionTypes): Integer; overload;

    procedure PartCancelOrder( Sender : TOrderTablet; aPoint : TTabletPoint; aTypes :  TPositionTypes );

      // board
    function NewBoard: TOrderBoard;

      // info pane

      // engine events
    procedure TradeBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure DoPosition(aPosition: TPosition; EventID: TDistributorID);
    procedure DoAbleQty(aPosition: TPosition; EventID: TDistributorID);
    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID);

    procedure OnAccount( aInvest: TInvestor; EventID: TDistributorID); overload;
    procedure OnAccount( aInvest: TInvestor); overload;
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure BoardEnvEventHander (Sender : TObject; DataObj: TObject;
      etType: TEventType; vtType : TValueType );
      // left side pane
    procedure SetPosition(aPosition: TPosition);

    procedure OtherBoardScrollToLastPrice;
    procedure SendKeyOrder( keyType :TKeyOrderType );
    procedure SendKey7to0Order(keyType : TKeyOrderType);
    procedure GetMarketAccount;
    function CancelLastOrder(aBoard: TOrderBoard): integer;
    function CancelNearOrder(aBoard: TOrderBoard; bAsk : boolean): integer;

    procedure ShowPositionVolume; overload;
    procedure ShowPositionVolume( aPosition : TPosition ); overload;
    procedure BoardEventStopOrder(vtType: TValueType; DataObj: TObject);


    procedure ClearGrid(aGrid : TStringGrid);

    function GetMonth(stCode: string): string;
    procedure MatchTablePoint(aBoard: TOrderboard; aPoint1,
      aPoint2: TTabletPoint);

    function CheckInvest: boolean;
    procedure SetFutures;
    procedure SetInfo(aBoard: TOrderBoard; bQuote: boolean = false);
    procedure BoardSetup(Sender: TObject);
    procedure UpdateTotalPl;
    procedure UpdateDeposit;
    procedure EraseGrid(aGrid: TStringGrid);
    procedure SetMainOrder(aForm: TForm);

  public
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure StandByClick( Sender, aControl : TObject );
    procedure ReLoad;
    procedure CenterAlign;
    procedure RecvSymbol(aSymbol: TSymbol);
    procedure SymbolSelect( Sender: TObject; aSymbol : TSymbol );
    procedure AddInterestSymbol(aSymbol: TSymbol; iRow: integer);

    procedure WMSymbolSelected(var msg: TMessage); message WM_SYMBOLSELECTED;
    procedure WMSelectPosition(var msg: TMessage); message WM_SELECTPOSITION;

  end;

var
  OrderBoardForm: TOrderBoardForm;

const
  SIDE_LEFT_PANEL_WIDTH = 154;
  SIDE_RIGHT_PANEL_WIDTH = 154;

implementation

uses CleQuoteTimers, CleFormBroker
  ;

//uses ControlObserver ;

{$R *.dfm}

//---------------------------------------------------------------------< init >

procedure TOrderBoardForm.FormCreate(Sender: TObject);
var
  aSymbol : TSymbol;
  i : integer;
begin
  FResize := false;
    // create objects
  FBoards := TOrderBoards.Create(Self, PanelMain, false);

  FTargetOrders := TOrderList.Create;
  //FPointOrders  := TOrderList.Create;
  FTargetPositions  := TPositionList.Create;
    // init variables
  FKeyDown        := false;
    // grid title
  InitControls;
    // get default
    // 주문창 전체 환경설정
  SetDefaultPrefs;
    // 개별 보드 환경설정
  SetDefaultParams;

  gEnv.Engine.SymbolCore.Underlyings.GetList(ComboBoxUnderlyings.Items);
  SetComboIndex(ComboBoxUnderlyings, 0);
  ComboBoxUnderlyingsChange(ComboBoxUnderlyings);
  SetFutures;
    // Account 설정
  //FAccountGroup := nil;
  FInvest   := nil;
  FAccount  := nil;
  SetAccount;
    // subscribe for trade events
  gEnv.Engine.TradeBroker.Subscribe(Self, TradeBrokerEventHandler);

  gEnv.Engine.TradeCore.StopOrders.BoardItems.RegistCfg( Self, etStop, BoardEnvEventHander );
  gBoardEnv.BroadCast.RegistCfg( Self, etQty, BoardEnvEventHander );
  gBoardEnv.BroadCast.RegistCfg( Self, etSpace, BoardEnvEventHander );
  gBoardEnv.BroadCast.RegistCfg( Self, etMain, BoardEnvEventHander );
    //
  ApplyPrefs;
    //

  FSaveRow := -1;
  FSymbolRow := -1;
  LoadEnv( nil );

  for I := 0 to FBoards.Count - 1 do
  begin
    BoardSelect( FBoards[i] );
    SetSymbol( gEnv.Engine.SymbolCore.Future );
  end;

  FLeftPos := Left;

end;

procedure TOrderBoardForm.FormActivate(Sender: TObject);
begin
  // KeyBoard
  {
  if FKeyOrderMapItem <> nil then
    FKeyOrderMapItem.Active;
  }


end;

procedure TOrderBoardForm.FormDestroy(Sender: TObject);
var
  i: Integer;
  aBoard : TOrderBoard;
begin
  gBoardEnv.BroadCast.UnRegistCfg( Self );
  // stop order 등록취소
  gEnv.Engine.TradeCore.StopOrders.BoardItems.UnRegistCfg( Self );

  for i := 0 to FBoards.Count - 1 do
    gEnv.Engine.QuoteBroker.Cancel(FBoards[i]);
    // new coding

  gEnv.Engine.TradeBroker.Unsubscribe(Self);
  gEnv.Engine.QuoteBroker.Cancel(Self);

  FTargetOrders.Free;
  //FPointOrders.Free;
  FTargetPositions.Free;
  FBoards.Free;

end;

procedure TOrderBoardForm.FormResize(Sender: TObject);
var
  iCnt,  i: Integer;
begin
  iCnt  := 0;
  if FBoards.Count >1 then
  begin
    for i := 0 to FBoards.Count - 1 do
    begin
        inc( iCnt );
    end;
  end;

  if iCnt = 0 then iCnt := 1;

  for i := 0 to FBoards.Count - 1 do
  begin
    if not FLoadEnd then
      FBoards[i].Resize
    else begin
      FBoards[i].Resize;
    end;
  end;
end;

procedure TOrderBoardForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TOrderBoardForm.InitControls;
var
  I: Integer;
begin

  with sgInterest do
  begin
    Cells[0,4] := '지수선물';
    Cells[0,3] := '미니선물';
    Cells[0,2] := '미국달러';
{$IFDEF KR_FUT}
    Cells[0,1] := '3년 국채';
{$ELSE}
    Cells[0,1] := '코스선물';
{$ENDIF}
    Cells[0,0] := '10년국채';
  end;

  with StringGridOptions do
  begin
    Cells[0,0] := 'Call';
    Cells[1,0] := '행사가';
    Cells[2,0] := 'Put';
  end;


  sgAcntPL.Cells[0,0] := '평가손익';
  sgAcntPL.Cells[0,1] := '실현손익';
  sgAcntPL.Cells[0,2] := '총손익';

  sgDeposit.Cells[0,0]  :='평가예탁';
  sgDeposit.Cells[0,1]  :='주문가능';

  FMin  := 60;

  sgAcntPL.ColWidths[0] := 50;
  sgAcntPL.ColWidths[1] := sgAcntPL.ClientWidth - sgAcntPL.ColWidths[0]-2;

  sgDeposit.ColWidths[0]  := sgAcntPL.ColWidths[0];
  sgDeposit.ColWidths[1]  := sgAcntPL.ColWidths[1];


  FLiskChange := false;

  if gEnv.UserType = utStaff then
    edtPw.Visible := false;
end;


procedure TOrderBoardForm.listReadyDblClick(Sender: TObject);
begin
  // 대기 취소..
end;

procedure TOrderBoardForm.ReLoad;
var
  i : integer;
  aBoard : TOrderBoard;
begin
  for i := 0 to FBoards.Count - 1 do
  begin
    FSelectedBoard := FBoards[i];

    if FselectedBoard.Symbol <> nil then
      SetSymbol( FselectedBoard.Symbol );
  end;

end;

procedure TOrderBoardForm.ReloadSymbols;
begin

end;

procedure TOrderBoardForm.rgDisplayClick(Sender: TObject);
begin
  FPrefs.DataIndex  := rgDisplay.ItemIndex;
  if FPrefs.DataIndex = 0 then    // 잔고
  begin
    Timer1.Enabled  := false;
    ShowPositionVolume;
  end
  else begin            // 현재가  or 예체가
    Timer1Timer( Timer1 );
    Timer1.Enabled  := true;
  end;
end;

procedure TOrderBoardForm.SetInfo(aBoard: TOrderBoard; bQuote : boolean);
var
  aSymbol : TSymbol;
  aQuote  : TQuote;
begin
  if ( aBoard = nil ) or ( aBoard.Symbol = nil ) then Exit;

  aSymbol := aBoard.Symbol;

  if not bQuote then
  begin

    FAskCnt := 0;
    FBidCnt := 0;
    FAskVol := 0;
    FBidVol := 0;

  end;
end;

//-----------------------------------------------------------------< defaults >

procedure TOrderBoardForm.SetDefaultPrefs;
begin
  with FPrefs do
  begin
    OrderKey  := ktNone;
    RangeKey  := ktSpace;

    DbClickOrder := true;
    MouseSelect := true;
    LastOrdCnl  := false;
      // generice
    BoardCount := 2;
      // board
    AutoScroll := False;
    TraceMouse := True;

    UseKeyOrder := false;
    DataIndex   := 0;

    Colors[IDX_LONG,  IDX_ORDER, IDX_FONT] := clBlack;
    Colors[IDX_SHORT, IDX_ORDER, IDX_FONT] := clBlack;
    Colors[IDX_LONG,  IDX_QUOTE, IDX_FONT] := clBlack;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT] := clBlack;

    Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND] := $E4E2FC;
    Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND] := $F5E2DA;
    {
    Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND] := $E4E2FC;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND] := $F5E2DA;
    }
    //Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND] := clWhite;
    //Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND] := clWhite;
    Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND] := $C4C4FF;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND] := $FFC4C4;

    cbOneClick.Checked  := false;
    //cbHogaFix.Checked   := false;
    cbKeyOrder.Checked  := false;
    rbMouseSelect.ItemIndex := 0;
    rbLastOrdCnl.ItemIndex  := 1;
     {
    UsePrfLiquid   := false;
    UseLosLiquid   := false;
    PrfTick := 5;
    LosTick := 5;

    UseMarketPrc   := true;   // 자동 청산주문을 시장가로..
    LiquidTick     := 4;
    StopTick       := 1;
    FixedHoga      := false;
    }
    Show1000unit    := false;

  end;
end;


procedure TOrderBoardForm.SetDefaultParams;
begin
  with FDefParams do
  begin
    OrdHigh := 18;
    OrdWid  := 58;
    FontSize  := 9;

    MergeQuoteColumns := False;
    MergedQuoteOnLeft := True;
      // show
    ShowOrderColumn := True;
    ShowCountColumn := false;
    ShowStopColumn:= True;

    ShowTNS := False;
    TNSOnLeft := False; // default on the right
    TNSRowCount := 20;

    HideBottom  := false;
  end;
end;


//----------------------------------------------------------------------< env >

procedure TOrderBoardForm.LoadEnv(aStorage: TStorage);
var
  i, j, ii, k, iCol, iRow, iCount: Integer;
  aBoard: TOrderBoard;
  aStop : TSTopORder;
  stBoard, stTmp, stAcnt : String;
  aParams: TOrderBoardParams;
  aAcnt : TAccount;
  aOrder : TOrder;
  ColorSave : boolean;
  aSymbol : TSymbol;
begin
  if aStorage = nil then begin
    FLoadEnd := true;
    //gEnv.OnLog( self, 'load end ');
    Exit;
  end;

  stAcnt:= aStorage.FieldByName('Account').AsString ;
  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stAcnt );
  if aAcnt <> nil then
  begin
    SetComboIndex( ComboBoAccount, aAcnt );
    ComboBoAccountChange(ComboBoAccount);
  end;

  SpeedButtonLeftPanel.Down  := aStorage.FieldByName('ShowLeftPanel').AsBoolean;
  SpeedButtonRightPanel.Down := aStorage.FieldByName('ShowRightPanel').AsBoolean;

    // preferences
  FPrefs.BoardCount       := aStorage.FieldByName('Prefs.BoardCount').AsInteger;
  UpDown1.Position        := FPrefs.BoardCount;
 // MakeBoards;

  FPrefs.AutoScroll       := aStorage.FieldByName('Prefs.AutoScroll').AsBoolean;
  FPrefs.TraceMouse       := aStorage.FieldByName('Prefs.TraceMouse').AsBoolean;

  FPrefs.UseKeyOrder      := aStorage.FieldByName('Prefs.UseKeyOrder').AsBoolean;

  FPrefs.OrderKey         := TBoardKeyType( aStorage.FieldByName('Prefs.OrderKey').AsInteger );
  FPrefs.RangeKey         := TBoardKeyType( aStorage.FieldByName('Prefs.RangeKey').AsInteger );

  FPrefs.MouseSelect      := aStorage.FieldByName('Prefs.MouseSelect').AsBoolean;
  FPrefs.DbClickOrder     := aStorage.FieldByName('Prefs.DbClickOrder').AsBoolean;
  FPrefs.LastOrdCnl       := aStorage.FieldByName('Prefs.LastOrdCnl').AsBoolean;
         {
  FPrefs.PrfTick          := aStorage.FieldByName('PrfTick').AsIntegerDef(5);
  FPrefs.LosTick          := aStorage.FieldByName('LosTick').AsIntegerDef(5);

  FPrefs.UseMarketPrc     := aStorage.FieldByName('UseMarketPrc').AsBoolean;
  FPrefs.LiquidTick       := aStorage.FieldByName('LiquidTick').AsInteger;
  FPrefs.StopTick         := aStorage.FieldByName('StopTick').AsInteger;
  FPrefs.FixedHoga        := aStorage.FieldByName('FixedHoga').AsBooleanDef(false);
          }
  FPrefs.Show1000unit     := aStorage.FieldByName('Show1000Unit').AsBoolean;
  FPrefs.DataIndex        := aStorage.FieldByName('Dataindex').AsIntegerDef(0);
    // apply preferences
  ApplyPrefs;
    // boards
  // 관심종목....


  for i := 0 to FPrefs.BoardCount-1 do
  begin
    if i > FBoards.Count-1 then Break;

    aBoard := FBoards[i];
    stBoard := Format('Board[%d]', [i]);
      // symbol
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(
                          aStorage.FieldByName(stBoard + '.symbol').AsString);
    aBoard.Symbol := aSymbol;

    if aBoard.Symbol <> nil then begin
      aBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(aBoard, aBoard.Symbol,
                            QuoteBrokerEventHandler);
      aBoard.AddSymbol( aBoard.Symbol );
    end;

    if (aBoard.Symbol <> nil) and ( FAccount <> nil ) then
      aBoard.Account:= FAccount;

    if aBoard.Account <> nil then
      BoardAcntSelect( aBoard );

    aParams.OrdHigh        := aStorage.FieldByName(stBoard + '.Params.OrdHigh').AsIntegerDef(18);
    aParams.OrdWid         := aStorage.FieldByName(stBoard + '.Params.OrdWid').AsIntegerDef(58);
    aParams.FontSize       := aStorage.FieldByName(stBoard + '.Params.FontSize').AsIntegerDef(9);

    aParams.MergeQuoteColumns  := aStorage.FieldByName(stBoard + '.Params.MergeQuoteColumns').AsBooleanDef( false );
    aParams.MergedQuoteOnLeft  := aStorage.FieldByName(stBoard + '.Params.MergedQuoteOnLeft').AsBooleanDef( true );
    aParams.ShowOrderColumn    := aStorage.FieldByName(stBoard + '.Params.ShowOrderColumn').AsBooleanDef( true );
    aParams.ShowCountColumn    := aStorage.FieldByName(stBoard + '.Params.ShowCountColumn').AsBooleanDef( true );
    aParams.ShowStopColumn     := aStorage.FieldByName(stBoard + '.Params.ShowStopColumn').AsBooleanDef( true );

    aParams.ShowTNS            := aStorage.FieldByName(stBoard + '.Params.ShowTNS').AsBoolean;
    aParams.TNSOnLeft          := aStorage.FieldByName(stBoard + '.Params.TNSOnLeft').AsBoolean;
    aParams.TNSRowCount        := aStorage.FieldByName(stBoard + '.Params.TNSRowCount').AsInteger;

    aParams.HideBottom         := aStorage.FieldByName(stBoard + '.Params.HideBottom').AsBooleanDef(false);

    with aBoard.QtySet do
    begin
      SpeedButton1.Caption    := aStorage.FieldByName(stBoard + '.SpeedButton1').AsStringDef('1');
      SpeedButton2.Caption    := aStorage.FieldByName(stBoard + '.SpeedButton2').AsStringDef('2');
      SpeedButton3.Caption    := aStorage.FieldByName(stBoard + '.SpeedButton3').AsStringDef('3');
      SpeedButton4.Caption    := aStorage.FieldByName(stBoard + '.SpeedButton4').AsStringDef('4');
      SpeedButton5.Caption    := aStorage.FieldByName(stBoard + '.SpeedButton5').AsStringDef('5');

      udStopTick.Position     := aStorage.FieldByName(stBoard + '.StopTick').AsIntegerDef(1);
      cbHogaFix.Checked       := aStorage.FieldByName(stBoard + '.FixedHoga').AsBooleanDef( false );
    end;

    with aBoard.LiqSet do
    begin
      udPrfTick.Position      :=  aStorage.FieldByName(stBoard + '.PrfTick').AsIntegerDef(5);
      udLosTick.Position      :=  aStorage.FieldByName(stBoard + '.LosTick').AsIntegerDef(5);

      rbMarket.Checked        :=  aStorage.FieldByName(stBoard + '.UseMarketPrc').AsBooleanDef(true);
      if rbMarket.Checked then
        rbHoga.Checked := false
      else
        rbHoga.Checked := true;

      udLiqTick.Position      :=  aStorage.FieldByName(stBoard + '.LiquidTick').AsIntegerDef(0);
    end;

    aBoard.Params := aParams; // apply

    aBoard.Position := gEnv.Engine.TradeCore.Positions.Find(aBoard.Account , aBoard.Symbol);
    aStop  := gEnv.Engine.TradeCore.StopOrders.Find( aBoard.Account, aBoard.Symbol );
    if aStop = nil then
    begin
      aStop := gEnv.Engine.TradeCore.StopOrders.New( aBoard.Account, aBoard.Symbol );
      aStop.Invest  := FInvest;
    end;

    aBoard.StopOrder  := aStop;
    aBoard.ShowStopOrder;

    aBoard.UpdatePositionInfo;
    aBoard.UpdateOrderLimit
  end;
    // apply visibilities of panels
  SpeedButtonLeftPanelClick(SpeedButtonLeftPanel);
  SpeedButtonRightPanelClick(SpeedButtonRightPanel);
    // apply account change

    // apply orders
  for i := 0 to FPrefs.BoardCount-1 do
  begin
    if i > FBoards.Count-1 then Break;
    aBoard := FBoards[i];

    if aBoard = nil then  Continue;

    for j := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[j];

      if (aOrder.State = osActive)
        and (aOrder.Account = aBoard.Account)  then
        begin
          if (aOrder.Symbol = aBoard.Symbol) then
            aBoard.Tablet.DoOrder(aOrder);
        end;
    end;

  end;

  FLoadEnd := true;

end;

procedure TOrderBoardForm.SaveEnv(aStorage: TStorage);
var
  ii,i, j, k, iCol, iRow: Integer;
  aSymbol : TSymbol;
  aBoard: TOrderBoard;
  stBoard: String;
begin
  if aStorage = nil then Exit;

    // account
  if FAccount <> nil then
    aStorage.FieldByName('Account').AsString := FAccount.Code; // account
    //
  aStorage.FieldByName('ShowLeftPanel').AsBoolean := SpeedButtonLeftPanel.Down;
  aStorage.FieldByName('ShowRightPanel').AsBoolean := SpeedButtonRightPanel.Down;
    // preferences
  aStorage.FieldByName('Prefs.BoardCount').AsInteger := FPrefs.BoardCount;

  aStorage.FieldByName('Prefs.AutoScroll').AsBoolean := FPrefs.AutoScroll;
  aStorage.FieldByName('Prefs.TraceMouse').AsBoolean := FPrefs.TraceMouse;
  aStorage.FieldByName('Prefs.UseKeyOrder').AsBoolean := FPrefs.UseKeyOrder;

  aStorage.FieldByName('Prefs.OrderKey').AsInteger  := Integer( FPrefs.OrderKey );
  aStorage.FieldByName('Prefs.RangeKey').AsInteger  := Integer( FPrefs.RangeKey );

  aStorage.FieldByName('Prefs.MouseSelect').AsBoolean   := FPrefs.MouseSelect;
  aStorage.FieldByName('Prefs.DbClickOrder').AsBoolean  := FPrefs.DbClickOrder;
  aStorage.FieldByName('Prefs.LastOrdCnl').AsBoolean    := FPrefs.LastOrdCnl;

  aStorage.FieldByName('Show1000Unit').AsBoolean  := FPrefs.Show1000unit;
  aStorage.FieldByName('Dataindex').AsInteger     := FPrefs.DataIndex;

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

    aStorage.FieldByName(stBoard + '.Params.OrdHigh').AsInteger := aBoard.Params.OrdHigh;
    aStorage.FieldByName(stBoard + '.Params.OrdWid').AsInteger := aBoard.Params.OrdWid;
    aStorage.FieldByName(stBoard + '.Params.FontSize').AsInteger := aBoard.Params.FontSize;

    aStorage.FieldByName(stBoard + '.Params.MergeQuoteColumns').AsBoolean  := aBoard.Params.MergeQuoteColumns;
    aStorage.FieldByName(stBoard + '.Params.MergedQuoteOnLeft').AsBoolean  := aBoard.Params.MergedQuoteOnLeft;
    aStorage.FieldByName(stBoard + '.Params.ShowOrderColumn').AsBoolean    := aBoard.Params.ShowOrderColumn;
    aStorage.FieldByName(stBoard + '.Params.ShowCountColumn').AsBoolean    := aBoard.Params.ShowCountColumn;
    aStorage.FieldByName(stBoard + '.Params.ShowStopColumn').AsBoolean     := aBoard.Params.ShowStopColumn;

    aStorage.FieldByName(stBoard + '.Params.ShowTNS').AsBoolean            := aBoard.Params.ShowTNS;
    aStorage.FieldByName(stBoard + '.Params.TNSOnLeft').AsBoolean          := aBoard.Params.TNSOnLeft;
    aStorage.FieldByName(stBoard + '.Params.TNSRowCount').AsInteger        := aBoard.Params.TNSRowCount;
    aStorage.FieldByName(stBoard + '.Params.HideBottom').AsBoolean         := aBoard.Params.HideBottom;

    with aBoard.QtySet do
    begin
      aStorage.FieldByName(stBoard + '.SpeedButton1').AsString := SpeedButton1.Caption;
      aStorage.FieldByName(stBoard + '.SpeedButton2').AsString := SpeedButton2.Caption;
      aStorage.FieldByName(stBoard + '.SpeedButton3').AsString := SpeedButton3.Caption;
      aStorage.FieldByName(stBoard + '.SpeedButton4').AsString := SpeedButton4.Caption;
      aStorage.FieldByName(stBoard + '.SpeedButton5').AsString := SpeedButton5.Caption;

      aStorage.FieldByName(stBoard + '.StopTick').AsInteger    := StrToIntDef(edtStopTick.Text,1 );
      aStorage.FieldByName(stBoard + '.FixedHoga').AsBoolean   := cbHogaFix.Checked;
    end;

    with aBoard.LiqSet do
    begin
      aStorage.FieldByName(stBoard + '.PrfTick').AsInteger     := StrToIntDef(edtPrfTick.Text, 5 );
      aStorage.FieldByName(stBoard + '.LosTick').AsInteger     := StrToIntDef(edtLosTick.Text, 5 );
      aStorage.FieldByName(stBoard + '.UseMarketPrc').AsBoolean:= rbMarket.Checked;
      aStorage.FieldByName(stBoard + '.LiquidTick').AsInteger  := StrToIntDef(edtLiqTick.Text, 0 );
    end;
  end;
end;

procedure TOrderBoardForm.sbtnActOrdQryClick(Sender: TObject);
begin
  if not CheckInvest then Exit;

  gEnv.Engine.SendBroker.RequestAccountFill( FInvest );
end;

procedure TOrderBoardForm.sbtnPosQryClick(Sender: TObject);
begin
  if not CheckInvest then Exit;

  gEnv.Engine.SendBroker.RequestAccountPos( FInvest );
end;


procedure TOrderBoardForm.MakeBoards;
var
  i: Integer;
  aBoard: TOrderBoard;
begin
  if FPrefs.BoardCount < FBoards.Count then
  begin
    for i := FBoards.Count-1 downto FPrefs.BoardCount do begin
      if FBoards[i].Symbol <> nil then
        gEnv.Engine.QuoteBroker.Cancel( FBoards[i], FBoards[i].Symbol  );
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

procedure TOrderBoardForm.MakeBoards(iCount: integer);
var
  i: Integer;
  aBoard: TOrderBoard;
  bSelectedDel : boolean;
  aSymbol : TSymbol;
begin
  FPrefs.BoardCount := iCount;

  if FPrefs.BoardCount < FBoards.Count then
  begin
    bSelectedDel  := false;
    for i := FBoards.Count-1 downto FPrefs.BoardCount do
    begin

      if (FSelectedBoard <> nil) and (FSelectedBoard = FBoards[i]) then
        bSelectedDel := true;
      if FBoards[i].Symbol <> nil then
        gEnv.Engine.QuoteBroker.Cancel( FBoards[i], FBoards[i].Symbol  );
      FBoards[i].Free;

    end;

    if (bSelectedDel) and (FBoards.Count > 0) then
      BoardSelect( FBoards[0] );

  end else
  if FPrefs.BoardCount > FBoards.Count then
  begin
    for i := FBoards.Count to FPrefs.BoardCount - 1 do
    begin
      aBoard := NewBoard;
      // 종목선정은..임의로
      aBoard.Symbol := FBoards[0].Symbol;
      if aBoard.Symbol <> nil then begin
        aBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(aBoard, aBoard.Symbol,
                              QuoteBrokerEventHandler);
        aBoard.AddSymbol( aBoard.Symbol );
      end;
      aBoard.Params := FDefParams;
    end;
    GetMarketAccount;
  end;

end;

//
// apply 'preferences'
//


procedure TOrderBoardForm.ApplyPrefs;
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
      // cancel board selection
    //FPointOrders.Clear;
    ListViewOrders.Items.Clear;
    CheckBox1.Checked := false;
    FSelectedBoard := nil;
  end;
    // board count
  MakeBoards;

  cbOneClick.Checked  := not FPrefs.DbClickOrder;
  if FPrefs.MouseSelect then
    rbMouseSelect.ItemIndex := 0
  else
    rbMouseselect.ItemIndex := 1;
  cbKeyOrder.Checked  := FPrefs.UseKeyOrder;

  if FPrefs.LastOrdCnl then
    rbLastOrdCnl.ItemIndex  := 0
  else
    rbLastOrdCnl.ItemIndex  := 1;

  cbDiv1000.Checked   := FPrefs.Show1000unit;

  rgDisplay.ItemIndex := FPrefs.DataIndex;

    // apply common parameters
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Tablet.AutoScroll := FPrefs.AutoScroll;
    aBoard.Tablet.TraceMouse := FPrefs.TraceMouse;

    aBoard.Tablet.DbClickOrder  := FPrefs.DbClickOrder;
    aBoard.Tablet.MouseSelect   := FPrefs.MouseSelect;
    aBoard.Tablet.LastOrdCnl    := FPrefs.LastOrdCnl;

    aBoard.Resize;
    BoardSelect( aBoard );
  end;
    // adjust the form width
  SetWidth;
end;
procedure TOrderBoardForm.ApplyPrefs2;
var
  i: Integer;
  aBoard: TOrderBoard;
begin
  FLeftPos := Left;
    // apply common parameters
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Tablet.AutoScroll := FPrefs.AutoScroll;
    aBoard.Tablet.TraceMouse := FPrefs.TraceMouse;

    aBoard.Tablet.DbClickOrder  := FPrefs.DbClickOrder;
    aBoard.Tablet.MouseSelect   := FPrefs.MouseSelect;
    aBoard.Tablet.LastOrdCnl    := FPrefs.LastOrdCnl;

    aBoard.DivUnit  := FPrefs.Show1000unit;
    aBoard.UpdatePositionInfo;
    aBoard.Resize;
    //BoardSelect( aBoard );
  end;
    // adjust the form width
  SetWidth;
end;

//
// Set(Readjust) form width
//
procedure TOrderBoardForm.SetWidth;
var
  i, iWidth: Integer;
begin

  FResize := false;

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

  FResize := true;
end;

procedure TOrderBoardForm.sgAcntPLDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ACol = 0 then
      aBack := GRID_REVER_COLOR
    else begin
      aFont := TColor( Objects[ACol, ARow]);
      dFormat := DT_RIGHT or DT_VCENTER;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;
    aRect.Right := aRect.Right -2;
    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ACol = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;

  end


end;

procedure TOrderBoardForm.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ACol = 0 then
      aBack := clBtnFace
    else begin
      if ARow = Info_Last_Row then
        aFont := TColor( Objects[ACol, Info_Change_Row])
      else aFont := TColor( Objects[ACol, ARow]);
      dFormat := DT_RIGHT or DT_VCENTER;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;
    aRect.Right := aRect.Right -2;

    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ACol = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;

  end

end;

procedure TOrderBoardForm.sgInterestDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPosition : TPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if (ACol = 0)  then
      aBack := clBtnFace;

    if ARow = FSymbolRow then
      aBack := GRID_SELECT_COLOR;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;


    aRect.Top := aRect.Top + 2;

    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    if ACol = 2 then
    begin
    //dFormat := DT_RIGHT or DT_VCENTER;
    aPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount,
                                  TSymbol(Objects[1,aRow]));

    if aPosition <> nil then
      if (aPosition.ActiveBuyOrderVolume + aPosition.ActiveSellOrderVolume) > 0 then
        begin
          Canvas.Brush.Color := $00FFE7B3;
          Canvas.Font.Color := clBlack;
        end;
    end;

    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if (ACol = 0) then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;
  end

end;

procedure TOrderBoardForm.sgInterestMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  {
  var
    ACol, ARow : integer;
    aSymbol : TSymbol;
    }
begin
        {
  FSaveRow := -1;
  sgInterest.MouseToCell( X, Y, ACol, ARow );

  if Button = mbLeft then
  begin
    if ( ARow > 0 ) and ( ACol > 0 )  then
    begin
    aSymbol := TSymbol( sgInterest.Objects[ 0, ARow] );
      if aSymbol <> nil then
      begin
        FSymbolRow := ARow;
        RecvSymbol( aSymbol );
      end;
    end;
  end;

  sgInterest.Repaint;
  }
end;

procedure TOrderBoardForm.sgInterestSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
  var
    aSymbol : TSymbol;
begin

  if ( ARow >= 0 ) then
  begin
    aSymbol := TSymbol( sgInterest.Objects[ 1, ARow] );
    if aSymbol <> nil then
    begin
      FSymbolRow := ARow;
      RecvSymbol( aSymbol );
    end;
  end;
  sgInterest.Repaint;
end;

procedure TOrderBoardForm.sgQuoteDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPosition : TPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  aBack   := clWhite;
  dFormat := DT_RIGHT or DT_VCENTER;
  aRect   := Rect;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
    begin
      aBack := clBtnFace;
      dFormat := DT_CENTER or DT_VCENTER;
    end
    else begin
      aFont := TColor( Objects[ACol, ARow]);
      aRect.Right := aRect.Right-2;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;

    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ARow = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;

  end;

end;


procedure TOrderBoardForm.ShowPositionVolume;
var
  i : integer;
  aPos : TPosition;
begin

  for i := 1 to StringGridOptions.RowCount - 1 do
  begin
    StringGridOptions.Cells[0,i]  := '';
    StringGridOptions.Cells[2,i]  := '';
  end;

  for i := 0 to sgInterest.RowCount - 1 do
    sgInterest.Cells[2,i]  := '';

  for i := 0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    aPos  := gEnv.Engine.TradeCore.Positions.Positions[i];
    ShowPositionVolume( aPos );
  end;
end;

procedure TOrderBoardForm.ShowPositionVolume(aPosition: TPosition);
var
  i: Integer;
begin

  if FPrefs.DataIndex <> 0 then Exit;

  if (aPosition = nil)
     or (aPosition.Symbol = nil)
     or (aPosition.Symbol.Spec = nil)
     {or (aPosition.Account <> FAccount)} then Exit;

  if aPosition.Account <> FAccount then Exit;

  case aPosition.Symbol.Spec.Market of
    mtFutures:
      with sginterest do
        for I := 0 to RowCount - 1 do
        begin
          if Objects[1, i] = aPosition.Symbol then
          begin
            if aPosition.HadTrade then
              Cells[2,i] := IntToStr(aPosition.Volume)
            else begin
              if aPosition.Volume = 0 then
                Cells[2,i] := ''
              else
                Cells[2,i] := IntToStr(aPosition.Volume);
            end;
            Break;
          end;
        end;

    mtOption:
      for i := 1 to StringGridOptions.RowCount - 1 do
      begin
          // call
        if StringGridOptions.Objects[0, i] = aPosition.Symbol then
        begin
          if aPosition.HadTrade then
            StringGridOptions.Cells[0,i] := IntToStr(aPosition.Volume)
          else begin
            if aPosition.Volume = 0 then
              StringGridOptions.Cells[0,i] := ''
            else
              StringGridOptions.Cells[0,i] := IntToStr(aPosition.Volume);
          end;

          Break;
        end;
          // put
        if StringGridOptions.Objects[2, i] = aPosition.Symbol then
        begin

          if aPosition.HadTrade then
            StringGridOptions.Cells[2,i] := IntToStr(aPosition.Volume)
          else begin
            if aPosition.Volume = 0 then
              StringGridOptions.Cells[2,i] := ''
            else
              StringGridOptions.Cells[2,i] := IntToStr(aPosition.Volume);
          end;

          Break;
        end;
      end;
  end;
end;

//----------------------------------------------< TOrderTablet event handlers >

//
// TOrderTablet.OnNewOrder handler
//
procedure TOrderBoardForm.BoardNewOrder(Sender: TOrderTablet;
  aPoint1, aPoint2: TTabletPoint);
var
  aBoard: TOrderBoard;
  iQty: Integer;
begin
    // check
  if (Sender = nil) or (Sender.Symbol = nil)
     or (aPoint1.AreaType <> taOrder) then Exit;

  if not CheckInvest then Exit;

  gEnv.EnvLog( WIN_TEST, format('BoardNewOrder : %d ', [ iQTy ]) );

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order

  NewOrder(aBoard, aPoint1, aBoard.DefQty, aPoint1.Price);

end;


procedure TOrderBoardForm.BoardPanelClickEvent(Sender: TObject; iDiv,
  iTag: integer);
begin
  if (Sender <> nil) and ( Sender <> FSelectedBoard) then Exit;

  case iDiv of
    1 :
      case iTag of
        1 : // 시장가 매수    ;
            NewOrder( FSelectedBoard, 1, FSelectedBoard.DefQty, 0 , pcMarket );
        -1: // 시장가 매도   ;
            NewOrder( FSelectedBoard, -1, FSelectedBoard.DefQty, 0 , pcMarket );
      end;

  end;
end;

//
// TOrderTablet.OnChangeOrder handler
//
procedure TOrderBoardForm.BoardChangeOrder(Sender: TOrderTablet; aPoint1,
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
  {
    DoEnvLog(Self, '[OrderBoard] change order(s) sent by <Mouse Move> as '
         + Format('(%s: %.2f->%.2f)', [POSITIONTYPE_DESCS[aPoint1.PositionType],
                                       aPoint1.Price, aPoint2.Price]));
                                       }
end;

procedure TOrderBoardForm.BoardEnvEventHander(Sender: TObject;
  DataObj: TObject; etType: TEventType; vtType: TValueType);
begin

  if DataObj = nil then Exit;
  case etType of
    etMain  :  SetMainOrder( DataObj as TForm );
    etSpace :  OtherBoardScrollToLastPrice;
    etStop  :
      begin
        BoardEventStopOrder( vtType, DataObj );
      end;
  end;

end;

procedure TOrderBoardForm.SetMainOrder( aForm : TForm );
begin
  if aForm = nil then Exit;

  if aForm = Self then
    PanelTop.Color := $00FFE7B3 //clBlack
  else
    PanelTop.Color := clBtnFace;
end;

procedure TOrderBoardForm.BoardEventStopOrder( vtType : TValueType; DataObj : TObject );
var
  I: Integer;
begin
  for I := 0 to FBoards.Count - 1 do
    FBoards[i].OnStopOrderEvent( Self, DataObj, vtType);
end;

procedure TOrderBoardForm.BoardLastCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TOrderBOard;
begin
  if (Sender = nil) or (Sender.Symbol = nil) then Exit;
    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  CancelLastOrder( aBoard );
end;

procedure TOrderBoardForm.BoardNewOrder;
begin
  if FSelectedBoard = nil then Exit;

  FSelectedBoard.Tablet.NewOrder;
end;

procedure TOrderBoardForm.OnAccount(aInvest: TInvestor;
  EventID: TDistributorID);
begin
  ComboBoAccount.Items.Clear;
  gEnv.Engine.TradeCore.Accounts.GetList2( ComboBoAccount.Items );

  case integer( EventID ) of

    ACCOUNT_NEW , ACCOUNT_UPDATED  :
      begin
        if FAccount <> nil then
          SetComboIndex( ComboBoAccount, FAccount )
        else
          if ComboBoAccount.Items.Count > 0 then
          begin
            ComboBoAccount.ItemIndex  := 0;
            ComboBoAccountChange( nil );
          end;
      end;
    ACCOUNT_DELETED :
      if ComboBoAccount.Items.Count > 0 then
      begin
        ComboBoAccount.ItemIndex  := 0;
        ComboBoAccountChange( nil );
      end

  end;

end;

procedure TOrderBoardForm.OnAccount(aInvest: TInvestor);
begin
  if aInvest = FInvest then
    edtPW.Text  := aInvest.PassWord;
end;

procedure TOrderBoardForm.OtherBoardScrollToLastPrice;
var
  i : integer;
begin
  for i := 0 to FBoards.Count - 1 do
    FBoards[i].Tablet.ScrollToLastPrice;
end;

//
// TOrderTablet.OnCancelOrder handler
//
procedure TOrderBoardForm.BoardAcntSelect(aBoard : TOrderBoard);
var
  i: Integer;
  aAccount : TAccount;
  aOrder   : TOrder;
  bSend    : boolean;
begin

  if aBoard.Account = nil then Exit;

  aBoard.Tablet.RefreshDraw;

  bSend := false;
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = aBoard.Account) then
       begin
         // tablet 에는   종목까지 같은거
         if (aOrder.Symbol = aBoard.Symbol) then
         begin
           aBoard.Tablet.DoOrder2(aOrder);
           bSend := true;
         end;
       end;
  end;

  if bSend then
    aBoard.Tablet.RefreshTable;

  aBoard.UpdatePositionInfo;
  aBoard.UpdateOrderLimit;

end;

procedure TOrderBoardForm.BoardCancelOrder(Sender: TOrderTablet; aPoint1,
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
  //    DoEnvLog(Self, '[OrderBoard] change order(s) sent by <Mouse Move>');
end;



procedure TOrderBoardForm.BoardSelectCell(Sender: TOrderTablet;
  aPoint1, aPoint2: TTabletPoint);
var
  i: Integer;
  aItem: TListItem;
  aOrder: TOrder;
  iSum: Integer;
  stPosition: String;
  aBoard: TOrderBoard;
  theOrders : TOrderList;
begin

  if Sender = nil then Exit;

    // get board
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  BoardSelect(aBoard);
    // set order list
  if (aPoint1.AreaType = taInfo) and ( aPoint1.RowType = trInfo ) and
     (aPoint1.ColType = tcQuote ) then
  begin
    FSelectedBoard.SetPositionVolume;
  end;

  if aPoint1.AreaType <> taOrder then Exit;
  theOrders := nil;
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
    CheckBox1.Checked := false;

    for i := 0 to theOrders.Count-1 do
    begin
      aOrder := theOrders[i];
      aItem := ListViewOrders.Items.Add;

      aItem.Data := aOrder;
        // 'Caption' is saved for 'check' mark
      aItem.Checked := false;
      aItem.SubItems.Add(IntToStr(aOrder.Side * aOrder.ActiveQty));
      aItem.SubItems.Add(IntToStr(i));
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


//--------------------------------------------------------------< send orders >

//
// send a new order
// here, iVolume is signed integer
//

function TOrderBoardForm.NewOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
  iVolume: Integer; dPrice: Double ): TOrder;
var
  aTicket: TOrderTicket;
  iRes  : integer;
begin
  Result := nil;

  if not CheckInvest then Exit;
    // check
  if (aBoard.Account = nil) or (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
      or (iVolume = 0) then
  begin
    Beep;
    Exit;
  end;
    //
  //Application.ProcessMessages;
  {
    // confirm
  if FPrefs.ConfirmOrder then
    if  MessageDlg(Format('(%s,%d,%.2f',
        [aBoard.Tablet.Symbol.Code, iVolume, dPrice]) + ')을 전송하시겠습니까?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
  }
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

    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aBoard.Account, aBoard.Tablet.Symbol,
                //iVolume, pcLimit, dPrice, tmFOK, aTicket) ;
                iVolume, pcLimit, dPrice, tmGTC, aTicket);  //



  if Result <> nil then
  begin
    Result.OwnForm  := self;                             // send the order

    iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.Engine.TradeCore.Orders.DoNotify( Result );
  end
  else
    gEnv.EnvLog( WIN_TEST, Format('NewOrder is NULL :  %d, %.2f ', [ iVolume, dPrice ])  );

    //
  if iRes > 0 then
  begin
    aBoard.SentTime := timeGetTime;
  end;
end;

function TOrderBoardForm.NewOrder(aBoard: TOrderBoard; iSide, iVolume: Integer;
  dPrice: Double; pcValue: TPriceControl): TOrder;
var
  aTicket: TOrderTicket;
  iRes  : integer;
begin
  Result := nil;

  if not CheckInvest then Exit;

    // check
  if (aBoard.Account = nil) or (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
      or (iVolume = 0) then
  begin
    Beep;
    Exit;
  end;
    //
  Application.ProcessMessages;
    // short order volume
  if iSide < 0 then
    iVolume := -iVolume;
    // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aBoard.Account, aBoard.Tablet.Symbol,
                //iVolume, pcLimit, dPrice, tmFOK, aTicket) ;
                iVolume, pcValue, dPrice, tmGTC, aTicket);  //

  Result.OwnForm  := self;
    // send the order
  iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
  gEnv.Engine.TradeCore.Orders.DoNotify( Result );

    //
  if iRes > 0 then
  begin
    aBoard.SentTime := timeGetTime;
  end;

end;

//
// send change orders
//
function TOrderBoardForm.ChangeOrder(aBoard: TOrderBoard;
  aPoint1, aPoint2: TTabletPoint): Integer;
var
  i, iOrderQty: Integer;
  pOrder, aOrder: TOrder;
  aTicket: TOrderTicket;
  iMaxQty, iQty: Integer ;
  aList : TList;

  stTmp : string;
  iSave : integer;
begin
  Result := 0;

    // check
  if  (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;
  
 {
    // confirm
  if FPrefs.ConfirmOrder then
    if  MessageDlg(
           Format('%s 주문 (%.2f -> %.2f)을 정정하시겠습니까?',
             [POSITIONTYPE_DESCS[aPoint1.PositionType],
              aPoint1.Price, aPoint2.Price]),
                    mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
   }
    // clear order list
  FTargetOrders.Clear;

    // get target orders to change
  if aBoard.Tablet.GetOrders(aPoint1, FTargetOrders) = 0 then Exit;

  try
    // send changed orders for selected orders
  if (aBoard.Tablet.Symbol = FCancelPoint.Tablet.Symbol)
     and (aPoint1.Tablet = FCancelPoint.Tablet)
     and (aPoint1.Index = FCancelPoint.Index)
     and (aPoint1.PositionType = FCancelPoint.PositionType) then
  begin

    iMaxQty := Max(0, StrToIntDef(EditCancelQty.Text, 0));
    if iMaxQty = 0 then Exit;

    iQty := 0;

    iSave := ListViewOrders.Items.Count;


    try
      aList := TList.Create;

      for I := 0 to ListViewOrders.Items.Count - 1 do
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);
          // check
        if (aOrder = nil) or (aOrder.OrderType <> otNormal) or ( aOrder.Modify )
           or (aOrder.ActiveQty = 0) then Continue;

        iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
        if iOrderQty <= 0 then Break;
        aList.Add( aORder);
      end;

      for i := 0 to aList.Count-1 do
      begin
        //if ListViewOrders.Items[i].Checked then
        //begin
      //stTmp := Format('%d, %d, %d', [ i, ListViewOrders.Items.Count, iSAve]);
      //gEnv.EnvLog( WIN_ERR, stTmp );

          aOrder := TOrder(aList.Items[i]);

          aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
            // generate order
          pOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                            aOrder, aOrder.ActiveQty, pcLimit, aPoint2.Price,
                            tmGTC, aTicket);

          if pOrder <> nil then
          begin
            pOrder.OwnForm  := self;
            gEnv.Engine.TradeBroker.Send(aTicket);
            iQty := iQty + iOrderQty;
          end;
        //end;
      end;
    finally
      aList.Free;
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
        pOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                        aOrder, aOrder.ActiveQty, pcLimit, aPoint2.Price,
                        tmGTC, aTicket);

        if pOrder <> nil then
        begin
          pOrder.OwnForm  := self;
          gEnv.Engine.TradeBroker.Send(aTicket);
        end;
        //gEnv.Engine.TradeBroker.Send(aTicket);
      end;
    end;
  end;

  except
    stTmp := Format('%d, %d, %d', [ i, ListViewOrders.Items.Count, iSAve]);
    gEnv.EnvLog( WIN_ERR, stTmp );
  end;


    // send the order
  //Result := gEnv.Engine.TradeBroker.Send(aTicket);
end;

//
// send change orders, called from the popup menu
//
function TOrderBoardForm.ChangeOrder(aBoard: TOrderBoard; aPoint: TTabletPoint;
  iMaxQty: Integer; dPrice: Double): Integer;
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

    // send orders
  //Result := gEnv.Engine.TradeBroker.Send(aTicket);
end;



//
// send cancel order, called from TOrderTablet event handler
//

function TOrderBoardForm.CancelLastOrder( aBoard : TOrderBoard ) : integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder, pOrder: TOrder;
begin
  Result := 0;

  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;
  {
    // confirm
  if FPrefs.ConfirmOrder then
    if MessageDlg('주문을 취소하시겠습니까?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
   }
    // init
  iQty := 0;
  aOrder := nil;

  for i := gEnv.Engine.TradeCore.Orders.ActiveOrders.Count-1 downto 0 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders.Orders[i];
    if aOrder = nil then Continue;

    if ( aOrder.Symbol = aBoard.Tablet.Symbol) and
     ( aOrder.Account = aBoard.Account ) and
     ( aOrder.State = osActive ) then
     begin
      if (aOrder = nil) or (aOrder.OrderType <> otNormal)
        or (aOrder.ActiveQty = 0) then  begin
        aOrder := nil;
        Continue      ;
      end
      else
        break;
     end;
  end;


  if aORder <> nil then begin
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
    if pOrder <> nil then
      Result := gEnv.Engine.TradeBroker.Send(aTicket);
  end;


end;

function TOrderBoardForm.CancelNearOrder(aBoard: TOrderBoard; bAsk : boolean): integer;
var
  aType: TPositionType;
  aOrder: TOrder;
  aTicket: TOrderTicket;
begin
  Result := 0;
    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;

  if bAsk then
    aType := ptShort
  else
    aType := ptLong;

  aOrder := aBoard.Tablet.GetOrders( aType );

  if (aOrder <> nil) and ( aOrder.ActiveQty > 0) then
  begin
    if bAsk then
      aType := ptLong
    else
      aType := ptShort;


    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
    gEnv.Engine.TradeBroker.Send(aTicket);
  end;

end;

function TOrderBoardForm.CancelOrders(aBoard: TOrderBoard; aPoint: TTabletPoint;
  iMaxQty: Integer): Integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
  aDummy: TTabletPoint ;
  aList : TList;
begin
  Result := 0;

    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Account = nil then Exit;
        // init
  iQty := 0;

    // clear order list
  FTargetOrders.Clear;

    // get order list
  if aBoard.Tablet.GetOrders(aPoint, FTargetOrders) = 0 then Exit;
                                                   
    // get a order ticket

  if FCancelPoint.Tablet = nil then
    BoardSelectCell( aBoard.Tablet,  aPoint, aDummy );
    //FCancelPoint  := aPoint;
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


    try
      aList := TList.Create;

      for I := 0 to ListViewOrders.Items.Count - 1 do
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);
          // check
        if (aOrder = nil) or (aOrder.OrderType <> otNormal) or ( aOrder.Modify )
           or (aOrder.ActiveQty = 0) then Continue;

        iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
        if iOrderQty <= 0 then Break;
        aList.Add( aORder);
      end;

      for i := 0 to aList.Count-1 do
      begin
        //if ListViewOrders.Items[i].Checked then
        //begin
      //stTmp := Format('%d, %d, %d', [ i, ListViewOrders.Items.Count, iSAve]);
      //gEnv.EnvLog( WIN_ERR, stTmp );

          aOrder := TOrder(aList.Items[i]);

          aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          //aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aOrder, aOrder.ActiveQty, aTicket);
          Result := gEnv.Engine.TradeBroker.Send(aTicket);
            //
          iQty := iQty + iOrderQty;
        //end;
      end;
    finally
      aList.Free;
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
    // send the order
end;

//
// send cancel orders, called from the Popup menu
//
function TOrderBoardForm.CancelOrders(aBoard: TOrderBoard;
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

    // send
  //Result := gEnv.Engine.TradeBroker.Send(aTicket);
end;

function TOrderBoardForm.CancelOrders(aTablet: TOrderTablet;
  aTypes: TPositionTypes): Integer;
  var
    aBoard : TOrderBoard;
begin

  result := -1;
  aBoard := FBoards.Find(aTablet);
  if aBoard = nil then Exit;

  CancelOrders( aBoard, aTypes );

  result := 1;
end;

procedure TOrderBoardForm.CenterAlign;
var
  i : integer;
begin
  for i := 0 to FBoards.Count - 1 do
    FBoards[i].Tablet.ScrollToLastPrice;
end;

//------------------------------------------------------------< trade events >

procedure TOrderBoardForm.Timer1Timer(Sender: TObject);
var
  iCnt, i : integer;
  aSymbol : TSymbol;
  aStrike, rStrike : TStrike;
begin

  with sgInterest do
    for I := 0 to RowCount - 1 do
    begin
      aSymbol := TSymbol( Objects[1, i] );
      if aSymbol <> nil then
        Cells[2, i] := Format('%.2f', [ ifThenFloat( FPrefs.DataIndex = 1,  aSymbol.Last, aSymbol.ExpectPrice ) ]);
    end;

  if ComboBoxOptions.ItemIndex < 0 then Exit;

  rStrike := gEnv.Engine.SymbolCore.GetCustomATMIndex(  FUnderlyingGroup, ComboBoxOptions.ItemIndex );
  //FATMRow := -1;

  for i := 1 to StringGridOptions.RowCount - 1 do
  begin
    aStrike := StringGridOptions.Objects[1, i] as TStrike;
    if aStrike = rStrike then
      FATMRow := i;
    aSymbol := StringGridOptions.Objects[0, i] as TSymbol;
    if aSymbol = nil then Continue;
    StringGridOptions.Cells[0,i]  := Format('%.2f', [ ifThenFloat( FPrefs.DataIndex = 1, aSymbol.Last, aSymbol.ExpectPrice ) ] );

    aSymbol := StringGridOptions.Objects[2, i] as TSymbol;
    if aSymbol = nil then Continue;
    StringGridOptions.Cells[2,i]  := Format('%.2f', [ ifThenFloat( FPrefs.DataIndex = 1, aSymbol.Last, aSymbol.ExpectPrice ) ] );
  end;

end;

procedure TOrderBoardForm.TradeBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
      // fill events
    FILL_NEW: ;
      // position events
    POSITION_NEW,
    POSITION_UPDATE   : DoPosition(DataObj as TPosition, EventID);
    POSITION_ABLEQTY  : DoAbleQty( DataObj as TPosition, EventID );

    ACCOUNT_NEW     ,
    ACCOUNT_DELETED ,
    ACCOUNT_UPDATED : OnAccount( DataObj as Tinvestor, EventID );
    ACCOUNT_PWD     : OnAccount( DataObj as Tinvestor );

    ACCOUNT_DEPOSIT : if DataObj = FInvest then UpdateDeposit;
  end;
end;

procedure TOrderBoardForm.udControlClick(Sender: TObject; Button: TUDBtnType);
var
  i,iCount : Integer;
  aBoard : TOrderBoard;
begin
  FLeftPos  := Left;
  iCount := FBoards.Count;

  case Button of
    btNext: inc( iCount );
    btPrev:
      begin
        if FBoards.Count = 1 then
          Exit;
        dec( iCount );
      end;
  end;

  MakeBoards( iCount );

    // apply common parameters
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Tablet.AutoScroll := FPrefs.AutoScroll;
    aBoard.Tablet.TraceMouse := FPrefs.TraceMouse;
  end;

  SetWidth;

end;


procedure TOrderBoardForm.DoAbleQty(aPosition: TPosition;
  EventID: TDistributorID);
var
  I: Integer;
  aBoard : TOrderBoard;
begin

  for I := 0 to FBoards.Count - 1 do
  begin
    aBoard  := FBoards[i];
    if ( aBoard <> nil ) and ( aBoard.Position =  aPosition ) then
      aBoard.SetAbleQty( aPosition );
  end;

end;

procedure TOrderBoardForm.DoOrder(aOrder: TOrder; EventID: TDistributorID);
var
  i: Integer;
  aBoard: TOrderBoard;
  aDummy: TTabletPoint;
  stSpeed: String;
  iSpeed: Integer;

  OrderSpeed : Integer;
  bLeft, bRight : Boolean ;

  stTmp : string;
  //is1, is2, is3, is4 : int64;


  bPrf, bLos: boolean;
  iPrf, iLos, iTick: integer;
  pcValue : TPriceControl;

begin


  if {(FAccount = nil) or} (aOrder = nil)
     //or (aOrder.Account <> FAccount)
     or (aOrder.PriceControl in [pcMarket, pcBestLimit]) then Exit;


    // apply this order the every board
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if aBoard.Account<> aOrder.Account then Continue;
    if aBoard.Symbol <> aOrder.Symbol then Continue;

      // apply to the tablet
    aBoard.Tablet.DoOrder(aOrder);

      // order speed
    if (EventID in [ORDER_NEW, ORDER_CHANGED, ORDER_ACCEPTED])
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
    end;

    if (EventID in [ORDER_FILLED]) and ( aOrder.OwnForm = Self ) then
    begin

      aBoard.OnFill( aOrder );
    end;
      // update order limit
    aBoard.UpdateOrderLimit;

    if aBoard.Tablet = FCancelPoint.Tablet then
    begin
      MatchTablePoint( aBoard, FCancelPoint, aDummy);

    end;
  end;


end;


procedure TOrderBoardForm.MatchTablePoint( aBoard : TOrderboard;
  aPoint1, aPoint2: TTabletPoint);
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

  theOrders := nil;

  try
    theOrders := TOrderList.Create;

      // save the point
    FCancelPoint := aPoint1;

      // get order list
    aTablet.GetOrders(aPoint1, theOrders);

      // sort order list
    theOrders.SortByAcptTime;

      // populate list view on the right side pane
    iSum := 0;
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
    CheckBox1.Checked := false;

    for i := 0 to theOrders.Count-1 do
    begin
      aOrder := theOrders[i];
      aItem := ListViewOrders.Items.Add;

      aItem.Data := aOrder;
      // 'Caption' is saved for 'check' mark

      aItem.Checked := false;
      aItem.SubItems.Add(IntToStr(aOrder.Side * aOrder.ActiveQty));
      aItem.SubItems.Add(IntToStr(i));
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

procedure TOrderBoardForm.DoPosition(aPosition: TPosition; EventID: TDistributorID);
var
  aBoard: TOrderBoard;
  i: Integer;
begin

  if (FAccount = nil) or (aPosition.Account <> FAccount) then Exit;
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
      //break;

      //btnAbleQty.Caption := Format('가능(%d)', [ aPosition.AbleQty ]);
      //btnAbleQty.Tag     := aPosition.AbleQty;
    end;
  end;

  UpdateTotalPl;

end;

procedure TOrderBoardForm.EditCancelQtyChange(Sender: TObject);
begin
  EditCancelQtyExit( EditCancelQty );
end;

procedure TOrderBoardForm.EditCancelQtyExit(Sender: TObject);
var
  i, iCancelQty, iSumQty: Integer ;
  aOrder: TOrder ;
begin
    // if no input, set it to '0'
  if Length(Trim(EditCancelQty.Text)) = 0 then
     EditCancelQty.text := '0' ;

     // get canceling order volume
  iCancelQty := StrToIntDef(EditCancelQty.Text, 0);
  iSumQty := 0;

    // if the input value is zero, uncheck all orders

  if cbBack.Checked then
  begin
    if iCancelQty = 0 then
    begin
      for i := ListViewOrders.Items.Count - 1 downto 0 do
        ListViewOrders.Items[i].Checked := False;
    end else
      for i := ListViewOrders.Items.Count - 1 downto 0 do
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);
        if aOrder = nil then Continue;

        iSumQty := iSumQty + aOrder.ActiveQty;
          //
        if ((iSumQty -  aOrder.ActiveQty < iCancelQty ) and  (iSumQty >= iCancelQty) )
           or (iSumQty <= iCancelQty) then
          ListViewOrders.Items[i].Checked := True
        else
          ListViewOrders.Items[i].Checked := False;
      end;
  end
  else begin

    if iCancelQty = 0 then
    begin
      for i := 0 to ListViewOrders.Items.Count - 1 do
        ListViewOrders.Items[i].Checked := False;
    end else
      for i := 0 to ListViewOrders.Items.Count - 1 do
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);
        if aOrder = nil then Continue;

        iSumQty := iSumQty + aOrder.ActiveQty;
          //
        if ((iSumQty -  aOrder.ActiveQty < iCancelQty ) and  (iSumQty >= iCancelQty) )
           or (iSumQty <= iCancelQty) then
          ListViewOrders.Items[i].Checked := True
        else
          ListViewOrders.Items[i].Checked := False;
      end;
  end;

end;

procedure TOrderBoardForm.EditCancelQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #13, #8]) then
     Key := #0;

     // 'Entry' key call OnExti event handler
  if Key = #13 then
    EditCancelQtyExit(EditCancelQty);
end;

procedure TOrderBoardForm.edtOpenLiskAmtKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;


procedure TOrderBoardForm.edtPrfTickKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;


procedure TOrderBoardForm.edtTmpQtyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

//-------------------------------------------------------------< quote evnets >



procedure TOrderBoardForm.QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
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

    //aBoard.CheckJackPotOrder( aQuote );

    case aQuote.LastEvent of
      qtTimeNSale:
        begin
            // if it's the first feed, initialize tablet
          if not aBoard.Tablet.Ready then
            aBoard.Tablet.Ready := True;

          aBoard.TNSCount := aBoard.TNSCount + 1;
            // apply to the tablet
          if aBoard.Tablet.FixedHoga then
          begin
            aBoard.Tablet.UpdatePrice( false );
            aBoard.Tablet.ScrollToLastPrice;
          end else
          begin
            //aBoard.Tablet.UpdateQuote;
            aBoard.Tablet.UpdatePrice;
          end;
          aBoard.TickPainter.Update;

          if aBoard.Position <> nil then begin
            aBoard.UpdatePositionInfo;
          end;

         //if aBoard.TNSCount <= 1 then
         //   aBoard.Tablet.ScrollToLastPrice;
        end;
      qtMarketDepth:
        begin
          aBoard.Tablet.UpdateQuote;
          aBoard.TickPainter.Update2;
        end;
      qtCustom:
        begin
          //if not aBoard.Tablet.Ready then
          //begin
          aBoard.Tablet.Symbol  := aQuote.Symbol;
          aBoard.Tablet.Quote   := aQuote;
          aBoard.Tablet.Ready   := True;
          //end;
          aBoard.Tablet.UpdateQuote;
          aBoard.Tablet.UpdatePrice( not aBoard.Tablet.FixedHoga )  ;
          aBoard.Tablet.ScrollToLastPrice;
          BoardAcntSelect( aBoard );

        end;
    end;

  end;
end;


procedure TOrderBoardForm.rbLastOrdCnlClick(Sender: TObject);
begin
  FPrefs.LastOrdCnl := rbLastOrdCnl.ItemIndex = 0;
  ApplyPrefs2;
end;

procedure TOrderBoardForm.rbMarketClick(Sender: TObject);
begin
{
  FPrefs.UseMarketPrc := rbMarket.Checked;

  gEnv.EnvLog( WIN_DEFORD, Format('%s %s 선택(%s)', [ LogTitle,
      ifThenStr( rbMarket.Checked,'시장가','상대호가'), edtLiqTick.Text  ]));
}
end;

procedure TOrderBoardForm.rbMouseSelectClick(Sender: TObject);
begin
  FPrefs.MouseSelect  := rbMouseSelect.ItemIndex = 0;
  ApplyPrefs2;
end;



procedure TOrderBoardForm.reFreshTimer(Sender: TObject);
var
  aStrike, rStrike : TStrike;
  i, iTmp :Integer;
begin
  UpdateTotalPl;
  if (FPrefs.DataIndex = 0 ) and ( FUnderlyingGroup <> nil ) and ( ComboBoxOptions.ItemIndex >= 0 ) then
  begin
    iTmp := FATMRow;
    rStrike := gEnv.Engine.SymbolCore.GetCustomATMIndex(  FUnderlyingGroup, ComboBoxOptions.ItemIndex );
    if rStrike <> nil then
      for i := 1 to StringGridOptions.RowCount - 1 do
      begin
        aStrike := StringGridOptions.Objects[1, i] as TStrike;
        if aStrike = rStrike then
          FATMRow := i;
      end;
    if iTmp <> FATMRow then StringGridOptions.Repaint;
  end;

end;

//--------------------------------------------------------------< ZAPR events >


//-------------------------------------------------------------< set position >

//
// set an individual position
//
procedure TOrderBoardForm.SetPosition(aPosition: TPosition);
begin
  ShowPositionVolume( aPosition );
end;

procedure TOrderBoardForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var
  i,iCount : Integer;
  aBoard : TOrderBoard;
begin
  FLeftPos  := Left;
  iCount := FBoards.Count;

  case Button of
    btNext: inc( iCount );
    btPrev:
      begin
        if FBoards.Count = 1 then
          Exit;
        dec( iCount );
      end;
  end;

  MakeBoards( iCount );

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Resize;
  end;

  SetWidth;
end;


procedure TOrderBoardForm.UpdateDeposit;
var
  iDiv : integer;
begin
  if FInvest = nil then Exit;

  with sgDeposit do
  begin
    iDiv  := ifThen( FPrefs.Show1000unit, 1, 1000 );
    Cells[ 1, 0 ] := FormatFloat('#,##0', FInvest.DepositOTE / iDiv );
    Cells[ 1, 1 ] := FormatFloat('#,##0', FInvest.EAbleAmt / iDiv );
  end;

end;

procedure TOrderBoardForm.UpdateTotalPl;
var
  i , j, iDiv : integer;
  aAccount : TAccount ;
  dOpen, dFixed, dFee : double;
begin

  if FAccount = nil then Exit;
  gEnv.Engine.TradeCore.Positions.GetAccountPL( FAccount, dOpen, dFixed, dFee  );

  with sgAcntPL do
  begin
    iDiv  := ifThen( FPrefs.Show1000unit, 1, 1000 );

    Cells[ 1, 0] := Format('%.*n', [ 0, dOpen / iDiv]);
    Cells[ 1, 1] := Format('%.*n', [ 0, dFixed / iDiv] );

    Cells[ 1, 2] := Format('%.*n', [ 0, (dOpen + dFixed )/iDiv] );

    Objects[1,0] := Pointer( ifThenColor( dOpen > 0, clRed,
                             ifThenColor( dOpen < 0, clBlue, clBlack )));
    Objects[1,1] := Pointer( ifThenColor( dFixed > 0, clRed,
                             ifThenColor( dFixed < 0, clBlue, clBlack )));
    //Objects[1,2] := Pointer( clBlue );

    Objects[1,2] := Pointer( ifThenColor( (dOpen + dFixed )> 0, clRed,
                             ifThenColor((dOpen + dFixed )< 0, clBlue, clBlack )));
  end;
end;

procedure TOrderBoardForm.WMSelectPosition(var msg: TMessage);
var
  aAccount : TAccount;
  aSymbol  : TSymbol;
begin

  if  msg.WParam = 0 then Exit;

  try

    aAccount:= TAccount( Pointer(msg.WParam ));
    if aAccount = nil then Exit;

    SetComboIndex( ComboBoAccount, aAccount );
    ComboBoAccountChange(ComboBoAccount);

    if  msg.LParam <> 0 then
    begin
      aSymbol := TSymbol( Pointer( msg.LParam ));
      if aSymbol <> nil then      
        RecvSymbol( aSymbol ) ;
    end;

  except
  end;

end;

procedure TOrderBoardForm.WMSymbolSelected(var msg: TMessage);
var
  aSymbol : TSymbol;
begin

  aSymbol := TSymbol( Pointer( msg.LParam ));

  if aSymbol <> nil then

  case msg.WParam of
    0 : RecvSymbol( aSymbol ) ;
    else
      AddInterestSymbol( aSymbol, msg.WParam );
  end;
end;


//-------------------------------------------------------------------< tablet >

function TOrderBoardForm.GetMonth( stCode : string ) : string;
var
  iM,iLen : integer;
  stM : string;
begin
  iLen := Length( stCode );
  iM := iLen -1;

  case stCode[iM] of
    'F' : Result := '01';
    'G' : Result := '02';
    'H' : Result := '03';
    'J' : Result := '04';
    'K' : Result := '05';
    'M' : Result := '06';
    'N' : Result := '07';
    'Q' : Result := '08';
    'U' : Result := '09';
    'Y' : Result := '10';
    'X' : Result := '11';
    'Z' : Result := '12';
  end;
end;


procedure TOrderBoardForm.AddInterestSymbol( aSymbol : TSymbol; iRow : integer );
begin
  if aSymbol <> nil then
    with sgInterest do
    begin
    Objects[ 0, iRow] := aSymbol;
                  Cells[0, iRow]    := aSymbol.Spec.Sector;
                  Cells[1, iRow]    := aSymbol.ShortCode;
                  Cells[2, iRow]    := FormatDateTime('yy', (asymbol as TDerivative).ExpDate) + ','+ GetMonth(aSymbol.ShortCode);
    end;
end;

procedure TOrderBoardForm.N10Click(Sender: TObject);
begin
  gEnv.MainBoard  := nil;
  gBoardEnv.BroadCast.BroadCast( Self, gEnv.Main, etMain, vtUpdate);
end;

procedure TOrderBoardForm.N8Click(Sender: TObject);
begin
  gBoardEnv.BroadCast.BroadCast( Self, Self, etMain, vtUpdate);
  gEnv.MainBoard  := Self;
end;

function TOrderBoardForm.NewBoard: TOrderBoard;
begin
  Result := FBoards.New;

  if Result <> nil then
  begin
    Result.OnSelect := BoardSelect;
    Result.OnPanelClickEvent  :=  BoardPanelClickEvent;
    Result.OnSymbolSelect := SymbolSelect;
    Result.OnSetup := BoardSetup;


    //Result.onc
      // popup menu for order tablet

    Result.Tablet.PopOrders := PopupMenuOrders;
      // assign event handlers
    Result.Tablet.OnNewOrder := BoardNewOrder;
    Result.Tablet.OnChangeOrder := BoardChangeOrder;
    Result.Tablet.OnCancelOrder := BoardCancelOrder;
    Result.Tablet.OnLastCancelOrder := BoardLastCancelOrder;
    Result.Tablet.OnSelectCell := BoardSelectCell;

    Result.Tablet.OnCancelOrders  := CancelOrders;

    Result.Tablet.TabletColor := $00EFD2B4;

    { todo:
    Result.ZaprService.OnMinPriceChanged := MinPriceProc;
    Result.ZaprService.OnMaxPriceChanged := MaxPriceProc;
    }
    Result.Tablet.ColWidths[tcOrder]  := Result.Tablet.ORDER_WIDTH;
    Result.Tablet.ColWidths[tcQuote]  := QTY_WIDTH;
    Result.Tablet.ColWidths[tcPrice]  := PRICE_WIDTH;
    Result.Tablet.ColWidths[tcCount ] := CNT_WIDTH;
    Result.Tablet.ColWidths[tcGutter] := GUT_WIDTH;
    Result.Tablet.ColWidths[tcStop]   := STOP_WIDTH;

    Result.Tablet.AutoScroll := FPrefs.AutoScroll;
    Result.Tablet.TraceMouse := FPrefs.TraceMouse;

    Result.Tablet.DbClickOrder  := FPrefs.DbClickOrder;
    Result.Tablet.MouseSelect   := FPrefs.MouseSelect;
    Result.Tablet.LastOrdCnl    := FPrefs.LastOrdCnl;

    Result.Tablet.OrderColors[ptLong, ctFont]  := FPrefs.Colors[IDX_LONG,  IDX_ORDER, IDX_FONT];
    Result.Tablet.OrderColors[ptLong, ctBG]    := FPrefs.Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND];
    Result.Tablet.OrderColors[ptShort, ctFont] := FPrefs.Colors[IDX_SHORT, IDX_ORDER, IDX_FONT];
    Result.Tablet.OrderColors[ptShort, ctBG]   := FPrefs.Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND];
    Result.Tablet.QuoteColors[ptLong, ctFont]  := FPrefs.Colors[IDX_LONG,  IDX_QUOTE, IDX_FONT];
    Result.Tablet.QuoteColors[ptLong, ctBG]    := FPrefs.Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND];
    Result.Tablet.QuoteColors[ptShort, ctFont] := FPrefs.Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT];
    Result.Tablet.QuoteColors[ptShort, ctBG]   := FPrefs.Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND];


    Result.SetOrderVolume(StrToIntDef( Result.QtySet.SpeedButton1.Caption, 1), True);
      // set dimension
    Result.Resize;
  end;
end;



procedure TOrderBoardForm.BoardSelect(Sender: TObject);
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
      FSelectedBoard.QtySet.Color := clYellow;//$00D8E5EE;
      FSelectedBoard.LiqSet.Color := clYellow;
      FSelectedBoard.Tablet.Selected  := true;
    end else
    begin
      aBoard.QtySet.Color :=  clBtnFace;
      aBoard.LiqSet.Color := clBtnFace;
      aBoard.Tablet.Selected  := false;
    end;

    //aBoard.QtySet.Repaint;
  end;

end;

procedure TOrderBoardForm.BoardSetup(Sender: TObject);
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
               //
  FLeftPos := Left;
  aDlg := TBoardParamDialog.Create(Self);

  try
    aDlg.Params := FSelectedBoard.Params;
    if aDlg.ShowModal = mrOK then
    begin
      FSelectedBoard.Params := aDlg.Params;
      SetWidth;
    end;

  finally
    aDlg.Free;
  end;
end;

procedure TOrderBoardForm.btnLastCancelClick(Sender: TObject);
var
  aBoard: TOrderBoard;
  aTicket: TOrderTicket;
  aOrder: TOrder;
  i, iMaxQty, iQty, iOrderQty: Integer;
  aList : TList;
begin

  if FCancelPoint.Tablet = nil then Exit;

    // find board
  aBoard := FBoards.Find(FCancelPoint.Tablet);
  if aBoard = nil then Exit;
    // init
  iQty := 0;

  try
    aList := TList.Create;

    //
    for i := ListViewOrders.Items.Count - 1 downto 0 do
    begin
      aOrder := TOrder(ListViewOrders.Items[i].Data);
      if aOrder <> nil then
        aList.Add( aOrder );
      if aList.Count > 0 then
        break;
    end;


    for i := 0 to aList.Count - 1 do
    begin
      aOrder  := TOrder( aList.Items[i]) ;
      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
          // generage cancel order
        if iOrderQty > 0 then  begin
          aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, iOrderQty, aTicket);
          gEnv.Engine.TradeBroker.Send(aTicket);
        end;
      end;
    end;

  finally
    aList.Free;
  end;

end;

//------------------------------------------------------------------< select >

procedure TOrderBoardForm.SetAccount;
begin
  gEnv.Engine.TradeCore.Accounts.GetList2( ComboBoAccount.Items );
  if ComboBoAccount.Items.Count > 0 then
  begin
    ComboBoAccount.ItemIndex  := 0;
    ComboBoAccountChange( nil );
    ComboBox_AutoWidth( ComboBoAccount );
  end;
end;

procedure TOrderBoardForm.SetFutures;
var
  i, j : integer;
  aSymbol : TSymbol;
  aFutMarket  : TFutureMarket;
begin

  with sgInterest, gEnv.Engine.SymbolCore do
  begin

    j := 1;
    if Future <> nil then
    begin
      Objects[1,RowCount-j]  := Future;
      Objects[2,i] := Pointer($00EEEEEE);
      Cells[  1,RowCount-j]  := Copy( Future.ShortCode, 1, 5 );
      Cells[  2,Rowcount-j]  := '';
    end;
    inc(j);

    if MiniFuture <> nil then
    begin
      Objects[1,RowCount-j]  := MiniFuture;
      Objects[2,i] := Pointer($00EEEEEE);
      Cells[  1,RowCount-j]  := Copy( MiniFuture.ShortCode, 1, 5 );
      Cells[  2,Rowcount-j]  := '';
    end;
    inc(j);

    if UsFuture <> nil then
    begin
      Objects[1,RowCount-j]  := UsFuture;
      Objects[2,i] := Pointer($00EEEEEE);
      Cells[  1,RowCount-j]  := Copy( UsFuture.ShortCode, 1, 5 );
      Cells[  2,Rowcount-j]  := '';
    end;
    inc(j);

    //

{$IFDEF KR_FUT}
    if Bond3Future <> nil then
    begin
      Objects[1,RowCount-j]  := Bond3Future;
      Objects[2,i] := Pointer($00EEEEEE);
      Cells[  1,RowCount-j]  := Copy( Bond3Future.ShortCode, 1, 5 );
      Cells[  2,Rowcount-j]  := '';
    end;
{$ELSE}
    if KD150Future <> nil then
    begin
      Objects[1,RowCount-j]  := KD150Future;
      Objects[2,i] := Pointer($00EEEEEE);
      Cells[  1,RowCount-j]  := Copy( KD150Future.ShortCode, 1, 5 );
      Cells[  2,Rowcount-j]  := '';
    end;
{$ENDIF}

    inc(j);

    if Bond10Future <> nil then
    begin
      Objects[1,RowCount-j]  := Bond10Future;
      Objects[2,i] := Pointer($00EEEEEE);
      Cells[  1,RowCount-j]  := Copy( Bond10Future.ShortCode, 1, 5 );
      Cells[  2,Rowcount-j]  := '';
    end;
    inc(j);

  end;
end;

procedure TOrderBoardForm.SetSymbol(aSymbol: TSymbol);
var
  iRow, iCol, i: Integer;
  aOrder: TOrder;
  bSend , CanSelected : Boolean;
  aGrid : TStringGrid ;
  stLeftDesc, stRightDesc : String ;
  aAcnt   : TAccount;
  aTmp : TSymbol;
  aStop : TStopOrder;
begin

  FLeftPos := Left;
  if (aSymbol = nil) or (FBoards.Count = 0) then Exit;

  if FSelectedBoard = nil then
    BoardSelect(FBoards[0]);

    // check still
  if FSelectedBoard = nil then Exit;
    // unsubscribe
  if FSelectedBoard.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel(FSelectedBoard, FSelectedBoard.Symbol);
    //
  FSelectedBoard.Tablet.Ready := False;
  FSelectedBoard.DeliveryTime := '';

    // 계좌 처리 먼저 한다...
  FSelectedBoard.Account  := FAccount;
    // set symbol and subscribe
  aTmp := FSelectedBoard.Symbol;
  FSelectedBoard.Symbol := aSymbol;
  FSelectedBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(FSelectedBoard, aSymbol,
                            QuoteBrokerEventHandler);

  SetInfo( FSelectedBoard );

  if (aTmp <> aSymbol) then
    SetWidth;

  if FSelectedBoard.Account = nil then Exit;
    // assign position
  //sgSymbolPL.Rows[1].Clear;
  FSelectedBoard.Position := gEnv.Engine.TradeCore.Positions.FindOrNew(FSelectedBoard.Account , aSymbol);
    // apply orders


  bSEnd := false;
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = FSelectedBoard.Account) then
       begin
         if (aOrder.Symbol = FSelectedBoard.Symbol) then
         begin
           FSelectedBoard.Tablet.DoOrder2(aOrder);
           bSend := true;
         end;
       end;
  end;

  if bSend then
    FSelectedBoard.Tablet.RefreshTable;

    // update order limite
  FSelectedBoard.UpdatePositionInfo;
  FSelectedBoard.UpdateOrderLimit;

    // fill count
  FSelectedBoard.TNSCount := 0;

    //
  FSelectedBoard.Resize;

    // if quote has been subscribed somewhere else
  if (FSelectedBoard.Quote <> nil) then
  begin
    FSelectedBoard.Quote.LastEvent  := qtCustom;//qtTimeNSale;
    QuoteBrokerEventHandler(FSelectedBoard.Quote, Self, 0, FSelectedBoard.Quote, 0);
  end;

  {todo:
  case aSide of
    stLeft  : gKeyOrderAgent.SetSymbolA(Self, aSymbol);
    stRight : gKeyOrderAgent.SetSymbolB(Self, aSymbol);
  end;
  }

  aStop := gEnv.Engine.TradeCore.StopOrders.Find( FSelectedBoard.Account, aSymbol );
  //if FSelectedBoard.StopOrder = nil then
  if aStop = nil then
  begin
    aStop := gEnv.Engine.TradeCore.StopOrders.New( FSelectedBoard.Account, aSymbol );
    aStop.Invest  := FInvest;
  end;
  FSelectedBoard.StopOrder  := aStop;
  FSelectedBoard.ShowStopOrder;

  //cbAcntLisk.Checked  := false;
  //CheckOrientation( FSelectedBoard );
end;


//-----------------------------------------------------------< select account >

//
// select account
//
procedure TOrderBoardForm.ComboBoAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  i : integer;
begin
  //
  aAccount  := GetComboObject( ComboBoAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin
    FAccount := aAccount;
    GetMarketAccount;
    lbAcntName.Caption  := FAccount.Name;
       {
    if cbAcntLisk.Checked then
      cbAcntLisk.Checked := false;

    if FSymbol <> nil then
      LogTitle  := Format('%s, %s',[ FAccount.Name, FSymbol.ShortCode ] )
    else
      LogTitle  := Format('%s, %s',[ FAccount.Name, '' ] );
      }
  end;
end;

procedure TOrderBoardForm.ClearGrid( aGrid : TStringGrid );
var
  I: Integer;
begin
  for I := 1 to aGrid.RowCount - 1 do
    aGrid.Rows[i].Clear;

  case aGrid.Tag of
    0 : aGrid.ColWidths[ChangeCol]  := FUfColWidth;
    1 : aGrid.ColWidths[ChangeCol]  := FUSColWidth;
  end;

  aGrid.RowCount := 2;
end;

procedure TOrderBoardForm.EraseGrid( aGrid : TStringGrid );
var
  I: Integer;
begin
  for i := 1 to aGrid.RowCount - 1 do
  begin
    aGrid.Cells[0,i]  := '';
    aGrid.Cells[2,i]  := '';
  end;

  with sgInterest do
    for I := 0 to RowCount - 1 do
      Cells[2,i]  := '';
end;

procedure TOrderBoardForm.GetMarketAccount;
var
  i : integer;
  aStop : TStopOrder;
  aPos  : TPosition;
  aInvest: TInvestor;
begin

  EraseGrid( StringGridOptions );

  aInvest := gEnv.Engine.TradeCore.Investors.Find( FAccount.InvestCode );
  if aInvest <> nil then
  begin
    FInvest := aInvest;
    edtPw.Text  := aInvest.PassWord;
    UpdateDeposit;
  end;

  for i := 0 to FBoards.Count - 1 do
  begin
    if FBoards[i].Symbol <> nil then
    begin
      FBoards[i].Account  := FAccount;
      FBoards[i].Position :=
        gEnv.Engine.TradeCore.Positions.FindOrNew( FBoards[i].Account, FBoards[i].Symbol );
      BoardAcntSelect( FBoards[i] );

      aStop := gEnv.Engine.TradeCore.StopOrders.Find( FBoards[i].Account, FBoards[i].Symbol );
      if aStop = nil then
      begin
        aStop := gEnv.Engine.TradeCore.StopOrders.New( FBoards[i].Account, FBoards[i].Symbol );
        aStop.Invest  := FInvest;
      end;
      FBoards[i].StopOrder := aStop;
      FBoards[i].ShowStopOrder;
    end;
  end;

  for I := 0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    aPos := gEnv.Engine.TradeCore.Positions.Positions[i];
    if aPos.Account = FAccount then
      SetPosition( aPos );
  end;

  UpdateTotalPl;
end;

//--------------------------------------------------------< populates symbols >

//
// select underlying
//
procedure TOrderBoardForm.ComboBoxOptionsChange(Sender: TObject);
var
  aTree: TOptionTree;
  i, iCnt: Integer;
  rStrike, aStrike: TStrike;
begin
    // get selected option month
  rStrike := gEnv.Engine.SymbolCore.GetCustomATMIndex(  FUnderlyingGroup, ComboBoxOptions.ItemIndex );
  FATMRow := -1;

  aTree := GetComboObject(ComboBoxOptions) as TOptionTree;
  if aTree = nil then
  begin
    StringGridOptions.RowCount := 1;
    Exit;
  end;

    // set option grid
  StringGridOptions.RowCount := aTree.Strikes.Count + 1;
  if StringGridOptions.RowCount > 1 then
    StringGridOptions.FixedRows := 1;

    //
  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aStrike := aTree.Strikes[i];

    if aStrike = rStrike then
      FATMRow := i+1;
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

  if FATMRow > 0 then
  begin
    iCnt := (StringGridOptions.Height div StringGridOptions.DefaultRowHeight) div 2;
    StringGridOptions.TopRow  := Max(0, FATMRow - iCnt);
  end;

  if FPrefs.DataIndex = 0 then    // 잔고
    ShowPositionVolume
  else
    Timer1Timer( Timer1 );

   
end;

procedure TOrderBoardForm.ComboBoxUnderlyingsChange(Sender: TObject);
var
  aULGroup: TMarketGroup;
  aMarket: TMarket;
  aPosition: TPosition;
  i: Integer;
begin
  //
  ComboBoxOptions.Enabled := False;
  StringGridOptions.Enabled := False;

  StringGridOptions.RowCount := 1;
  ComboBoxOptions.Items.Clear;

  FUnderlyingGroup  := nil;

    // get the selected group
  aULGroup := GetComboObject(ComboBoxUnderlyings) as TMarketGroup;
  if aULGroup = nil then
    Exit;

  FUnderlyingGroup  := aULGroup;

  for i := 0 to aULGroup.Markets.Count - 1 do
  begin
    aMarket := aULGroup.Markets[i];

    case aMarket.Spec.Market of
      mtOption:
        begin
          FOptionMarket := aMarket as TOptionMarket;
          FOptionMarket.Trees.GetListShort(ComboBoxOptions.Items);
          ComboBoxOptions.Enabled := True;
          StringGridOptions.Enabled := True;
        end;
    end;
  end;

    // select default option tree
  if ComboBoxOptions.Items.Count > 0 then
  begin
    ComboBoxOptions.ItemIndex := 0;
    ComboBoxOptionsChange(ComboBoxOptions);
  end;


end;

procedure TOrderBoardForm.ComboBoxUnderlyingsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  Exit;
end;

procedure TOrderBoardForm.ComboBoxUnderlyingsKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := #0;
end;

procedure TOrderBoardForm.StringGridOptionsDrawCell(Sender: TObject; ACol,
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

    if gdFixed in State then
    begin
      Brush.Color := FIXED_COLOR;
      Font.Color := clBlack;
    end else
    if aCol = 1 then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;

      if FATMRow = ARow then
        Brush.Color := clYellow;
    end else
    if [gdSelected, gdFocused] <= State then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    if StringGridOptions.Cells[aCol, aRow] <> '' then
    begin

      if (FPrefs.DataIndex = 0) or ( ARow = 0) then
      begin
        Brush.Color := clWhite;
        Font.Color := clBlack;
      end
      else begin
        Brush.Color := NODATA_COLOR;
        Font.Color := clBlack;
      end;

    end else
    begin
      Brush.Color := NODATA_COLOR;
    end;
      // background

      // text
    stText := StringGridOptions.Cells[aCol, aRow];

    aPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount,
                                  TSymbol(StringGridOptions.Objects[aCol,aRow]));

    if aPosition <> nil then
      if (aPosition.ActiveBuyOrderVolume + aPosition.ActiveSellOrderVolume) > 0 then
        begin
          Brush.Color := $00FFE7B3;
          Font.Color := clBlack;
        end;

    FillRect(Rect);
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

procedure TOrderBoardForm.StringGridOptionsMouseDown(Sender: TObject;
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
  RecvSymbol(  aOption );

end;

procedure TOrderBoardForm.StringGridOptionsMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;

procedure TOrderBoardForm.StringGridOptionsMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;


procedure TOrderBoardForm.SymbolSelect(Sender: TObject; aSymbol : TSymbol );
var
  aBoard: TOrderBOard;
begin
  aBoard  := Sender as TOrderBoard;
  if aBoard = nil then Exit;
  if aSymbol = nil then Exit;

  SetSymbol( aSymbol );
end;

//---------------------------------------------------------< symbol selection >

//
// select a futures
//
procedure TOrderBoardForm.StandByClick(Sender, aControl : TObject);
var
  aBoard : TOrderBoard;
  iLS : integer;
begin
  aBoard  := Sender as TOrderBoard;
  if aBoard = nil then Exit;

  iLS :=  TSpeedButton( aControl ).GroupIndex;

end;

procedure TOrderBoardForm.SpeedButton7Click(Sender: TObject);
var
  I: Integer;
  aBoard : TOrderBoard;
begin
  if (FInvest = nil) then Exit;
  if edtPW.Text = '' then
  begin
    ShowMessage('비밀번호를 입력하세요');
    Exit;
  end;

  FInvest.PassWord  := edtPW.Text;

  for I := 0 to FBoards.Count - 1 do
  begin
    aBoard  := FBoards[i];
    if aBoard.Position <> nil then
      gEnv.Engine.TradeCore.InvestorPositions.ReqAbleQty( aBoard.Position );
  end;

  gEnv.Engine.SendBroker.RequestAccountAdjustMent( FInvest );

end;

procedure TOrderBoardForm.SpeedButtonLeftPanelClick(Sender: TObject);
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

procedure TOrderBoardForm.SpeedButtonRightPanelClick(Sender: TObject);
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

//-----------------------------------------------------------------------<?


procedure TOrderBoardForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
  stTmp : string;
begin
    // scroll
  if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT  ] then
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

    end;    //

    Key := 0;
  end else
    // escape key

  if (BoardKey[FPrefs.RangeKey] <> 0) and (Key = BoardKey[FPrefs.RangeKey]) then
  begin
    gBoardEnv.BroadCast.BroadCast( Self, Self, etSpace, vtUpdate);
    //OtherBoardScrollToLastPrice;
  end;

  if FPrefs.UseKeyOrder then
  begin
    if FSelectedBoard = nil then Exit;

    if FKeyDown then Exit;
    FKeyDown  := true;

    if Key = BoardKey[FPrefs.OrderKey]  then
    begin
      //if not FKeyDown then
      BoardNewOrder;
    end
    //gEnv.OnLog( self, stTmp );
    //gLog.Add( lkKeyOrder, '',IntToStr( key ) , sttmp);
  end;


  key := 0;
end;

procedure TOrderBoardForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FKeyDown := false;
end;

procedure TOrderBoardForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollLine(1,-1);
end;

procedure TOrderBoardForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
       if FSelectedBoard <> nil then
         FSelectedBoard.Tablet.ScrollLine(1,1);
end;

procedure TOrderBoardForm.SendKey7to0Order(keyType: TKeyOrderType);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  iQty, iRes, iSide    : integer;
  aBoard  : TOrderBoard;
  dAskPrice, dBidPrice  : double;
begin

  if FSelectedBoard = nil then Exit;

  if (FSelectedBoard.Symbol = nil) or (FselectedBoard.Quote = nil) or
    ( FSelectedBoard.Account = nil) or ( FSelectedBoard.DefQty = 0 ) then
  begin
    Beep;
    gLog.Add( lkKeyOrder, 'TOrderBoardForm', 'SendKey7to0Order', 'Object is nil ');
    Exit;
  end;
                                                            
  iQty  :=  FselectedBoard.DefQty;

  case keyType of
    kot2BidAsk:
      begin
        dAskPrice  := FSelectedBoard.Quote.Asks[1].Price;
        dBidPrice  := FSelectedBoard.Quote.Bids[1].Price;
      end ;
    kot3BidAsk:
      begin
        dAskPrice  := FSelectedBoard.Quote.Asks[2].Price;
        dBidPrice  := FSelectedBoard.Quote.Bids[2].Price;
      end ;
    kot4BidAsk:
      begin
        dAskPrice  := FSelectedBoard.Quote.Asks[3].Price;
        dBidPrice  := FSelectedBoard.Quote.Bids[3].Price;
      end;
    kot5BidAsk:
      begin
        dAskPrice  := FSelectedBoard.Quote.Asks[4].Price;
        dBidPrice  := FSelectedBoard.Quote.Bids[4].Price;
      end ;
  end;

  if (FSelectedBoard.Symbol.LimitHigh < dAskPrice) or
      (FSelectedBoard.Symbol.LimitLow > dBidPrice) then
      exit;

  //매수주문
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    // create normal order
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FselectedBoard.Account, FselectedBoard.Tablet.Symbol,
                iQty , pcLimit, dBidPrice, tmGTC, aTicket);  //


  iRes := -1;
  if aOrder <> nil then
    iRes := gEnv.Engine.TradeBroker.Send(aTicket);
  if iRes > 0 then
    FSelectedBoard.SentTime := timeGetTime;


  //매도주문
  aTicket := nil;
  aOrder := nil;
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    // create normal order
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FselectedBoard.Account, FselectedBoard.Tablet.Symbol,
                iQty * -1, pcLimit, dAskPrice, tmGTC, aTicket);  //
  iRes := -1;
  if aOrder <> nil then
    iRes := gEnv.Engine.TradeBroker.Send(aTicket);
  if iRes > 0 then
    FSelectedBoard.SentTime := timeGetTime;
end;

procedure TOrderBoardForm.SendKeyOrder( keyType :TKeyOrderType );
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  iQty, iRes, iSide    : integer;
  aBoard  : TOrderBoard;
  dPrice  : double;
begin

  if FSelectedBoard = nil then Exit;

  if (FSelectedBoard.Symbol = nil) or (FselectedBoard.Quote = nil) or
    ( FSelectedBoard.Account = nil) or ( FSelectedBoard.DefQty = 0 ) then
  begin
    Beep;
    gLog.Add( lkKeyOrder, 'TOrderBoardForm', 'SendKeyOrder', 'Object is nil ');
    Exit;
  end;

  iQty  :=  FselectedBoard.DefQty;

  case keyType of
    kotNewLong:
      begin
        iSide := 1;
        dPrice  := FSelectedBoard.Quote.Asks[0].Price;
      end ;
    kotNewLong1:
      begin
        iSide := 1;
        dPrice  := TicksFromPrice( FselectedBoard.Symbol, FSelectedBoard.Quote.Asks[0].Price, -1 );
      end ;
    kotNewShort:
      begin
        iSide := -1;
        dPrice  := FSelectedBoard.Quote.Bids[0].Price;
      end;
    kotNewShort1:
      begin
        iSide := -1;
        dPrice  := TicksFromPrice( FselectedBoard.Symbol, FSelectedBoard.Quote.Bids[0].Price, 1 );
      end ;
  end;


  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    // create normal order
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, FselectedBoard.Account, FselectedBoard.Tablet.Symbol,
                iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  iRes := -1;
  if aOrder <> nil then
    iRes := gEnv.Engine.TradeBroker.Send(aTicket);

    //
  if iRes > 0 then
  begin
    FSelectedBoard.SentTime := timeGetTime;
  end;

end;

//---------------------------------------------------------------< popup menu >

//
procedure TOrderBoardForm.Panel8DblClick(Sender: TObject);
begin
  //

end;

procedure TOrderBoardForm.PartCancelOrder(Sender: TOrderTablet;
  aPoint: TTabletPoint; aTypes: TPositionTypes);
  var
    aBoard : TOrderBoard;
begin
  
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  CancelOrders( aBoard, aPoint, aTypes );
end;


procedure TOrderBoardForm.PopupMenu1Popup(Sender: TObject);
begin
  if gEnv.MainBoard = Self then
    N10.Visible := true
  else
    N10.Visible := false;
end;

//
// send cancel order by button click
//

procedure TOrderBoardForm.Button1Click(Sender: TObject);
begin

  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
   // gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      RecvSymbol(  gSymbol.Selected );
    end;
  finally
    gSymbol.Hide
  end;

end;

procedure TOrderBoardForm.ButtonCancelClick(Sender: TObject);
var
  aBoard: TOrderBoard;
  aTicket: TOrderTicket;
  aOrder: TOrder;
  i, iMaxQty, iQty, iOrderQty: Integer;
  aList : TList;
begin


  if FCancelPoint.Tablet = nil then Exit;

    // get max qty
  iMaxQty := StrToIntDef(EditCancelQty.Text, 0);
  if iMaxQty <= 0 then Exit;

    // find board
  aBoard := FBoards.Find(FCancelPoint.Tablet);
  if aBoard = nil then Exit;

    // init
  iQty := 0;

  try
    aList := TList.Create;

    //
    for i := 0 to ListViewOrders.Items.Count - 1 do
      if ListViewOrders.Items[i].Checked then
      begin
        aOrder := TOrder(ListViewOrders.Items[i].Data);
        if aOrder <> nil then
          aList.Add( aOrder );
      end;


    for i := 0 to aList.Count - 1 do
    begin
      aOrder  := TOrder( aList.Items[i]) ;
      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
          // generage cancel order
        if iOrderQty > 0 then  begin
          aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, iOrderQty, aTicket);
          gEnv.Engine.TradeBroker.Send(aTicket);
        end;
      end;
    end;

  finally
    aList.Free;
  end;


end;

procedure TOrderBoardForm.RecvSymbol( aSymbol : TSymbol );
begin
  if aSymbol <> nil then
  begin
    SetSymbol( aSymbol );
  end;
end;


function TOrderBoardForm.CancelOrders(aBoard: TOrderBoard; aPoint: TTabletPoint;
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
  if aBoard.Tablet.GetOrders(aPoint, aTypes, FTargetOrders) = 0 then Exit;

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


procedure TOrderBoardForm.cbDiv1000Click(Sender: TObject);
begin
  FPrefs.Show1000unit := cbDiv1000.Checked;
  UpdateTotalPl;
  UpdateDeposit;
  ApplyPrefs2;
end;

procedure TOrderBoardForm.cbKeyOrderClick(Sender: TObject);
begin
  if cbKeyOrder.Checked then
  begin
    rbMouseSelect.Enabled := true;
    Label3.Caption  := '정렬 : Alt Key';
  end
  else begin
    rbMouseSelect.Enabled := false;
    Label3.Caption  := '정렬 : Space bar';
  end;

  with FPrefs do
  begin
    UseKeyOrder := cbKeyOrder.Checked;
    if UseKeyOrder then
    begin
      OrderKey := ktSpace;
      RangeKey := ktAlt;
    end
    else begin
      OrderKey := ktNone;
      RangeKey := ktSpace;
    end;
  end;
end;

procedure TOrderBoardForm.cbOneClickClick(Sender: TObject);
begin
  FPrefs.DbClickOrder := not cbOneClick.Checked;
  ApplyPrefs2;
end;



procedure TOrderBoardForm.CheckBox1Click(Sender: TObject);
var
  i, iSum: Integer;
  aOrder: TOrder;
begin
  iSum := 0;

  for i:=0 to ListViewOrders.Items.Count-1 do
  begin
    ListViewOrders.Items[i].Checked := CheckBox1.Checked;

    if ListViewOrders.Items[i].Checked  then
    begin
      aOrder := TOrder(ListViewOrders.Items[i].Data);
      iSum := iSum + aOrder.ActiveQty;
    end;
  end;
    //
  EditCancelQty.Text := IntToStr(iSum);

end;

function TOrderBoardForm.CheckInvest : boolean;
begin
  Result := true;

  if gEnv.UserType = utStaff then Exit;

  if ( FInvest = nil ) or
     ( FInvest.PassWord = '' ) then
  begin
    Result := false;
    ShowMessage('계좌 비밀번호 입력하세요');
    edtPW.SetFocus;
    Exit;
  end;
end;



end.
