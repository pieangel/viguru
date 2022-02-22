unit FDoubleOrder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, Buttons, ComCtrls, ImgList,  Menus, Math, Spin,
  MMSystem,
    // lemon: data
  CleSymbols,
    // lemon: trade
  CleAccounts, CleOrders
  ;

type

  TQtyState = (qsSelected, qsLong, qsShort, qsData);
  // 
  TDoubleOrderForm = class(TForm)
    PanelLeft: TPanel;
    PanelMain: TPanel;
    PanelTop: TPanel;
    PanelLeftSymbol: TPanel;
    PanelRightSymbol: TPanel;
    PanelQtyLeft: TPanel;
    PanelQtyRight: TPanel;
    PanelTabletLeft: TPanel;
    PanelTabletRight: TPanel;
    PaintTabletLeft: TPaintBox;
    PaintTabletRight: TPaintBox;
    ButtonSync: TSpeedButton;
    BtnLeftPanel: TSpeedButton;
    ButtonFix: TSpeedButton;
    BtnRightPanel: TSpeedButton;
    ComboAccount: TComboBox;
    PanelDerivative: TPanel;
    GridQtyLeft: TStringGrid;
    GridQtyRight: TStringGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    GridOrderQtyLeft: TStringGrid;
    GridOrderQtyRight: TStringGrid;
    Panel4: TPanel;
    ShapeLeft: TShape;
    ShapeRight: TShape;
    PageTick: TPageControl;
    TickSheetLeft: TTabSheet;
    PaintTicksLeft: TPaintBox;
    TickSheetRight: TTabSheet;
    PaintTicksRight: TPaintBox;
    PanelSymbols: TPanel;
    Panel3: TPanel;
    LabelFut: TLabel;
    ComboFutures: TComboBox;
    EditFutures: TStaticText;
    ComboOptions: TComboBox;
    edDeliveryTime: TEdit;
    GridOptions: TStringGrid;
    PopOrdersLeft: TPopupMenu;
    N6000X11: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    PopQuote: TPopupMenu;
    N8: TMenuItem;
    C1: TMenuItem;
    PopOrdersRight: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    ComboSymbol: TComboBox;
    StatusInfo: TStatusBar;
    ButtonConfig: TSpeedButton;
    PanelUnders: TPanel;
    ComboUnders: TComboBox;
    StaticExitLeft: TStaticText;
    StaticExitRight: TStaticText;
    PanelRight: TPanel;
    Splitter1: TSplitter;
    PageDummy: TPageControl;
    TabSheet1Left: TTabSheet;
    PaintTicksLeft2: TPaintBox;
    TabSheet2Right: TTabSheet;
    PaintTicksRight2: TPaintBox;
    Panel7: TPanel;
    BtnLeftInfo: TSpeedButton;
    BtnRightInfo: TSpeedButton;
    BtnOrderList: TSpeedButton;
    PanelOrderList: TPanel;
    ListOrders: TListView;
    Panel5: TPanel;
    BtnCancel: TButton;
    EditOrderQty: TEdit;
    lblSymbol: TLabel;
    lblPrice: TLabel;
    lblQty: TLabel;
    PanelInfo: TPanel;
    GridInfo: TStringGrid;
    procedure BtnLeftPanelClick(Sender: TObject);
    procedure BtnRightPanelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboOptionsChange(Sender: TObject);
    procedure ComboUndersChange(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure ComboFuturesChange(Sender: TObject);
    procedure GridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure GridOptionsDblClick(Sender: TObject);
    procedure GridOptionsMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure GridOptionsMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GridOptionsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure GridOptionsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditFuturesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditFuturesDblClick(Sender: TObject);
    //procedure AppOnMessage(var Msg: TMsg; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonConfigClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GridQtyLeftDblClick(Sender: TObject);
    procedure GridQtyRightDblClick(Sender: TObject);
    procedure StaticExitLeftClick(Sender: TObject);
    procedure StaticExitRightClick(Sender: TObject);
    procedure GridQtyLeftClick(Sender: TObject);
    procedure GridQtyRightClick(Sender: TObject);
    procedure GridQtyDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridQtyExit(Sender: TObject);
    procedure GridQtyKeyPress(Sender: TObject; var Key: Char);
    procedure GridQtyMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GridQtyMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GridQtyLeftSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure GridQtyRightSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure GridOrderQtyLeftClick(Sender: TObject);
    procedure GridOrderQtyRightClick(Sender: TObject);
    procedure GridOrderQtyExit(Sender: TObject);
    procedure GridOrderQtyKeyPress(Sender: TObject; var Key: Char);
    procedure GridOrderQtyMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure GridOrderQtyMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GridOrderQtyLeftSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure GridOrderQtyRightSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure GridOrderQtyLeftSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: String);
    procedure GridOrderQtyRightSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: String);
    procedure GridOrderQtyLeftDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure GridOrderQtyRightDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure PopQuotePopup(Sender: TObject);
    procedure PopQuoteClick(Sender: TObject);
    procedure PopOrdersLeftClick(Sender: TObject);
    procedure PopOrdersLeftPopup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PopOrdersRightPopup(Sender: TObject);
    procedure PopOrdersRightClick(Sender: TObject);
    procedure GridInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridQtyLeftMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridQtyRightMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    
    procedure ButtonSyncClick(Sender: TObject);

    procedure BtnCancelClick(Sender: TObject);
    procedure editOrderQtyKeyPress(Sender: TObject; var Key: Char);
    procedure editOrderQtyExit(Sender: TObject);
    procedure BtnOrderListClick(Sender: TObject);
    procedure BtnLeftInfoClick(Sender: TObject);
    procedure BtnRightInfoClick(Sender: TObject);
    procedure ListOrdersMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    //procedure PanelTabletLeftResize(Sender: TObject);
    //procedure PanelTabletRightResize(Sender: TObject);
  private
    //
    FAccount : TAccount;
    FOptionMonth : TOptionMonthlyItem;


    FSymbols : array[TSideType] of TSymbol ;
    FUnderlyings : array[TSideType] of  TSymbol;
    FPositions : array[TSideType] of TPositionItem;
    FTickPainters : array[TSideType] of  TTickPainter;

    // JJB
    FTickPainters2 : array[TSideType] of  TTickPainter;

    FOrderTablets : array[TSideType] of  TOrderTablet;
    FZaprServices : array[TSideType] of TZaprService;

    FSendTime : array[TSideType] of  Integer;
    FOrderSpeed : array[TSideType] of  String ;
    FDeliveryTime : array[TSideType] of  String ;

    FTypeString: array[TPositionType] of String;
    FVisibleInfo : array[TSideType] of Boolean ;  // �¿� ���� �г� visible
    FSubscribe : array[TSideType] of Boolean ;  // Subscribe ��û �ߴ��� ����
    FPriceReady : array[TSideType] of Boolean ;  // ���簡�� update �Ǿ����� ����
    FMenuPoints : array[TSideType] of TOrderPoint ;   // �¿� �޴� Ŭ�� ����Ʈ

    // Qty
    FTickCounts : array[TSideType] of Integer; //
    FDefQty:array[TSideType] of Integer; // �⺻ �ֹ�����
    FQtyHighLightTimer :  array[TSideType] of  TTimer;        // ���� Highlight
    FQtyState : array[TSideType] of  TQtyState ;
    FClearOrder : array[TSideType] of  Boolean;
    FClearOrderQty: array[TSideType] of  Integer;
    FOrderType : array[TSideType] of  TPositionType;



    FOrderHandler : TOrderHandler;
    FConfig: TDoubleOrderConfig ;
    //
    FAccountSynchronizing : Boolean;
    //
    FSelectedFutures : TSymbol ;
    FSelectedOptions : TSymbol ;
    FOptionsSelectedSide : TSideType ;
    FFuturesSelectedSide : TSideType ;

    //
    //JJB
    FKeyOrderMap : String;
    FKeyOrderMapItem : TKeyOrderItem;
    //

    FSynFutures : TSymbol;

    // 2007.05.24

    FLastSymbol : TSymbol ;
    FLastPoint : TOrderPoint ;
    FLastOrderList : TList ;
    FLastSide : TSideType ;

    FLastSynFutures : Double ;   //  IV ��� ���� SymFutures

    // 2007.06.24
    FPrevOrderBy : array[TSideType] of TPriceOrderbyType ;

    // WinCentral
    procedure SetData(Data : TObject);
    procedure SetPersistence(Stream : TObject);
    procedure GetPersistence(Stream : TObject);
    procedure CallWorkForm(Sender : TObject);
    procedure SetDefault(Stream : TObject);
    procedure GetDefault(Stream : TObject);
    // order
    procedure DoubleNewOrder(aPoint1, aPoint2 : TOrderPoint; aSide : TSideType);
    procedure DoubleChangeOrder(aPoint1, aPoint2 : TOrderPoint; aSide : TSideType);
    procedure DoubleCancelOrder(aPoint1, aPoint2 : TOrderPoint; aSide : TSideType);
    //
    procedure NewOrder(aPType : TPositionType; iQty : Integer;
      sPrice : Double ; aSide : TSideType );
    procedure ChangeOrder(aStart, aEnd : TOrderPoint; aSide : TSideType); overload;
    procedure ChangeOrder(aStart : TOrderPoint; aSide : TSideType ;
                iMaxQty : Integer; sPrice : Double); overload;
    procedure CancelOrders(aPoint : TOrderPoint; aSide:TSideType; iMaxQty : Integer = 0 ); overload;
    procedure CancelOrders(aTypes : TPositionTypes; aSide:TSideType); overload;
    procedure ProcessOrder(aPType: TPositionType; iQty: Integer;
      sPrice: Double ; aSide : TSideType );
    // subscribe
    procedure OrderProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure PositionProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure AccountProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure QuoteProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure TickProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure KeyOrderProc(Sender, Receiver, DataObj: TObject;
                       iBroadcastKind: Integer; btValue: TBroadcastType);
    procedure ObserverProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    procedure MinPriceProc(Sender : TObject);
    procedure MaxPriceProc(Sender : TObject);
    // private
    procedure SetPriceOrder ;
    procedure SetBothAutoPriceOrder ;
    procedure SetAutoPriceOrder( aSide : TSideType ;
      aPriceOrder : TPriceOrderbyType; aTargetSide : TSideType)  ;
    function GetOtherSideOrder(aPriceOrder : TPriceOrderbyType): TPriceOrderbyType ;
    function GetPositionLeft(aPriceOrder : TPriceOrderbyType): TPositionType ;

    function MakeGridTPosition(aGrid: TStringGrid;
      aOptionMonth: TOptionMonthlyItem; bFixed: Boolean):Boolean;
    procedure AssignTPosition(DataObj: TObject);
    procedure AssignOptionPosition;
    procedure InitControls;
    procedure InitTablet(aSide : TSideType ; aPaintBox : TPaintBox ) ;
    procedure ResetOrderTablet(aSide : TSideType);
    procedure QuoteUpdate(aSide:TSideType; iBroadcastKind: Integer );
    procedure UpdateOrderLimits(aSide:TSideType);
    procedure ReqChanged(Sender : TObject);    // Method Pointer
    // Qty
    procedure SetOrderQty( stQty: String ; bRefresh : Boolean ; aSide : TSideType  );
    procedure SetExitEnable(bClearOrderFlag : Boolean; aSide : TSideType  );  // û�� ����
    procedure HighLightTimerLeft(Sender: TObject);
    procedure HighLightTimerRight(Sender: TObject);
    // Setter / Getter
    procedure SetAccount(aAccount : TAccount);
    procedure SetSymbol( aSide : TSideType ; aSymbol : TSymbol);
    procedure SetConfig( bReset : Boolean ) ;
    procedure SetPositionInfo(aSide : TSideType) ;
    function GetDefQty(aSide : TSideType) : Integer ;
    procedure SetAccountInfo;
    procedure GetOptionsInfo(aSymbol : TSymbol ; aSide : TSideType   ) ;

    procedure SetPaintSize;
    procedure InitGridInfo( aSide : TSideType) ; 

    // 2007.03.10 YHW
    procedure PopulateAccount ;

    // 2007.05.24 YHW
    procedure SetOrderList( aSide : TSideType; aSymbol : TSymbol ; aList : TList ; aPoint : TOrderPoint ) ;

    // 2007.04.21 YHW
    function GetPosition(aSide : TSideType ) : Integer ;

  public
    property OrderQty[aSide:TSideType] : Integer read GetDefQty; default;
  end;

var
  DoubleOrderForm: TDoubleOrderForm;


const
  PANEL_WIDTH = 154 ;
  PAINT_WIDTH = 290 ;
  QTY_ROW_CNT = 3 ;
  QTY_COL_CNT = 4 ;

  // �޺��ڽ��� ����� �ֹ��� ������ �ȳ��� ���� ���̷� ����� �����ȴ�.
  COMBO_MIN = 100;
  COMBO_MAX = 269;
  // �޺��� ����� ������ �Ǹ鼭 ������ư�� �г��� ��ġ ����
  CONFIG_BTN_LEFT_MIN = 180;
  CONFIG_BTN_LEFT_MAX = 349;
  // �г�
  RIGHT_PANEL_MIN = 202;
  RIGHT_PANEL_MAX = 372;

  // �۾��ڵ� :  UD_JB_001
  // ������ : �����
  // �������� : 06/11/27

  TABLET_COLOR  : array[TSideType] of TColor
           = ($00EFD2B4, $00CBACF0);


implementation

uses ControlObserver ;

{$R *.dfm}




// ----- WinCentral ----- //

procedure TDoubleOrderForm.CallWorkForm(Sender: TObject);
begin
  // when ?
  if Sender = nil then Exit;
end;

procedure TDoubleOrderForm.SetDefault(Stream: TObject);
var
  aBinStream : TMemoryStream;
  stAccount, stSymbol  : String;
  i, j, iRowCount,iLeft, iWidth, iQty: Integer;
  aRect: TRect;
  szBuf : array[0..100] of Char;
  aAccount, aSymbolLeft, aSymbolRight : TObject;
  bSync : Boolean;
begin
  // ��â open Stream.read -> set
  with Stream as TMemoryStream do
  begin

  
    //--1. Account & Symbol
    {
    Read(szBuf, 15);
    stAccount := szBuf;
    aAccount:= gTrade.AccountStore.FindAccount(Trim(stAccount));
    Read(szBuf, 9);

    stSymbol := szBuf;
    aSymbolLeft:= gPrice.SymbolStore.FindSymbol(Trim(stSymbol));
    Read(szBuf, 9);
    stSymbol := szBuf;
    aSymbolRight:= gPrice.SymbolStore.FindSymbol(Trim(stSymbol));
    }

    //--2. form config
    Read(bSync, SizeOf(Boolean));
    ButtonSync.Down := bSync;
    Read(FVisibleInfo[stLeft], SizeOf(Boolean));
    Read(FVisibleInfo[stRight], SizeOf(Boolean));

    //--3. Order qty table
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        Read(iQty, SizeOf(Integer));
        GridQtyLeft.Cells[i,j] := IntToStr(iQty);
      end;
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        Read(iQty, SizeOf(Integer));
        GridQtyRight.Cells[i,j] := IntToStr(iQty);
      end;
    GridQtyLeft.RowCount := QTY_ROW_CNT ;
    GridQtyLeft.ColCount := QTY_COL_CNT ;
    GridQtyRight.RowCount := QTY_ROW_CNT ;
    GridQtyRight.ColCount := QTY_COL_CNT ;

    //--4. Order config
    Read(FConfig.TickCnt[stLeft], SizeOf(Integer));
    Read(FConfig.FillCnt[stLeft], SizeOf(Integer));
    Read(FConfig.VisibleTicks[stLeft], SizeOf(Boolean));
    Read(FConfig.FillFilter[stLeft], SizeOf(Boolean));

    Read(FConfig.TickCnt[stRight], SizeOf(Integer));
    Read(FConfig.FillCnt[stRight], SizeOf(Integer));
    Read(FConfig.VisibleTicks[stRight], SizeOf(Boolean));
    Read(FConfig.FillFilter[stRight], SizeOf(Boolean));
    //
    Read(FConfig.VisibleUnder, SizeOf(Boolean));
    Read(FConfig.VisibleOHL, SizeOf(Boolean));
    Read(FConfig.VisibleEvalPL, SizeOf(Boolean));

    Read(FConfig.VisibleOrderAmt , SizeOf(Boolean));
    Read(FConfig.VisibleQT, SizeOf(Boolean));
    Read(FConfig.VisibleZapr, SizeOf(Boolean));
    //
    Read(FConfig.EnableQtyClick, SizeOf(Boolean));
    Read(FConfig.EnableEscape, SizeOf(Boolean));
    Read(FConfig.EnableOneFive, SizeOf(Boolean));
    Read(FConfig.EnableClearOrder, SizeOf(Boolean));
    //
    Read(FConfig.AutoScroll, SizeOf(Boolean));

    Read(FConfig.OrderRightButton, SizeOf(Boolean));
    Read(FConfig.MouseTrace, SizeOf(Boolean));
    Read(FConfig.ConfirmOrder, SizeOf(Boolean));
    //
    Read(FConfig.OrderLeft[stLeft], SizeOf(TPositionType));
    Read(FConfig.VisibleOrder[stLeft], SizeOf(Boolean));
    Read(FConfig.QtyMerge[stLeft], SizeOf(Boolean));
    Read(FConfig.PriceOrderby[stLeft], SizeOf(TPriceOrderbyType));
    Read(FConfig.QtySide[stLeft], SizeOf(TSideType));
    //
    Read(FConfig.OrderLeft[stRight], SizeOf(TPositionType));
    Read(FConfig.VisibleOrder[stRight], SizeOf(Boolean));
    Read(FConfig.QtyMerge[stRight], SizeOf(Boolean));
    Read(FConfig.PriceOrderby[stRight], SizeOf(TPriceOrderbyType));
    Read(FConfig.QtySide[stRight], SizeOf(TSideType));

    // --2007.03.18
    Read(szBuf, 8);
    FConfig.QtyFontColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.QtyBgColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.QtyFontColor[ptLong] := szBuf ;
    Read(szBuf, 8);
    FConfig.QtyBgColor[ptLong] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderFontColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderBgColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderFontColor[ptLong] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderBgColor[ptLong] := szBuf ;

  end;

  // -- Setting
  // -- 1. Form
  if FVisibleInfo[stLeft] = false then BtnLeftPanelClick(BtnLeftPanel);
  if FVisibleInfo[stRight] = false then BtnRightPanelClick(BtnLeftPanel);

  // -- 2. Config
  SetConfig(True)  ;

end;

procedure TDoubleOrderForm.GetDefault(Stream: TObject);
var
  aBinStream : TMemoryStream;
  i, j , iQty : Integer;
  stAccount, stSymbolLeft, stSymbolRight, stMapName : String;
  szBuf : array[0..100] of Char;
begin
  // â close : get -> Stream.Write
  with Stream as TMemoryStream do
  begin

    {
    //--1. Account & Symbol
    if FAccount = nil then
      stAccount := Format('%-14s', [''])
    else
      stAccount := Format('%-14s', [FAccount.FullCode]);
    if FSymbols[stLeft] = nil then
      stSymbolLeft := Format('%-8s', [''])
    else
      stSymbolLeft := Format('%-8s', [FSymbols[stLeft].Code]);
    if FSymbols[stRight] = nil then
      stSymbolRight := Format('%-8s', [''])
    else
      stSymbolRight := Format('%-8s', [FSymbols[stRight].Code]);
    StrPCopy(szBuf, stAccount);
    Write(szBuf, Length(stAccount)+1);
    StrPCopy(szBuf, stSymbolLeft);
    Write(szBuf, Length(stSymbolLeft)+1);
    StrPCopy(szBuf, stSymbolRight);
    Write(szBuf, Length(stSymbolRight)+1);
    }

    Write(ButtonSync.Down , SizeOf(Boolean));
    Write(FVisibleInfo[stLeft], SizeOf(Boolean));
    Write(FVisibleInfo[stRight], SizeOf(Boolean));

    //--3. order qty table
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        iQty := StrToIntDef(GridQtyLeft.Cells[i,j], 0);
        Write(iQty, SizeOf(Integer));
      end;
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        iQty := StrToIntDef(GridQtyRight.Cells[i,j], 0);
        Write(iQty, SizeOf(Integer));
      end;

    //--4. Order config
    Write(FConfig.TickCnt[stLeft], SizeOf(Integer));
    Write(FConfig.FillCnt[stLeft], SizeOf(Integer));
    Write(FConfig.VisibleTicks[stLeft], SizeOf(Boolean));
    Write(FConfig.FillFilter[stLeft], SizeOf(Boolean));

    Write(FConfig.TickCnt[stRight], SizeOf(Integer));
    Write(FConfig.FillCnt[stRight], SizeOf(Integer));
    Write(FConfig.VisibleTicks[stRight], SizeOf(Boolean));
    Write(FConfig.FillFilter[stRight], SizeOf(Boolean));

    //
    Write(FConfig.VisibleUnder, SizeOf(Boolean));
    Write(FConfig.VisibleOHL, SizeOf(Boolean));
    Write(FConfig.VisibleEvalPL, SizeOf(Boolean));

    Write(FConfig.VisibleOrderAmt , SizeOf(Boolean));
    Write(FConfig.VisibleQT, SizeOf(Boolean));
    Write(FConfig.VisibleZapr, SizeOf(Boolean));
    //
    Write(FConfig.EnableQtyClick, SizeOf(Boolean));
    Write(FConfig.EnableEscape, SizeOf(Boolean));
    Write(FConfig.EnableOneFive, SizeOf(Boolean));
    Write(FConfig.EnableClearOrder, SizeOf(Boolean));
    //
    Write(FConfig.AutoScroll, SizeOf(Boolean));

    Write(FConfig.OrderRightButton, SizeOf(Boolean));
    Write(FConfig.MouseTrace, SizeOf(Boolean));
    Write(FConfig.ConfirmOrder, SizeOf(Boolean));
    //
    Write(FConfig.OrderLeft[stLeft], SizeOf(TPositionType));
    Write(FConfig.VisibleOrder[stLeft], SizeOf(Boolean));
    Write(FConfig.QtyMerge[stLeft], SizeOf(Boolean));
    Write(FConfig.PriceOrderby[stLeft], SizeOf(TPriceOrderbyType));
    Write(FConfig.QtySide[stLeft], SizeOf(TSideType));
    //
    Write(FConfig.OrderLeft[stRight], SizeOf(TPositionType));
    Write(FConfig.VisibleOrder[stRight], SizeOf(Boolean));
    Write(FConfig.QtyMerge[stRight], SizeOf(Boolean));
    Write(FConfig.PriceOrderby[stRight], SizeOf(TPriceOrderbyType));
    Write(FConfig.QtySide[stRight], SizeOf(TSideType));

    // -- 2007.03.18
    StrPCopy(szBuf, FConfig.QtyFontColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.QtyBgColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.QtyFontColor[ptLong]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.QtyBgColor[ptLong]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderFontColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderBgColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderFontColor[ptLong]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderBgColor[ptLong]);
    Write(szBuf, 8 );

  end;

end;

procedure TDoubleOrderForm.SetPersistence(Stream: TObject);
var
  aBinStream : TMemoryStream;
  stAccount, stSymbol  : String;
  i, j, iRowCount,iLeft, iWidth, iQty: Integer;
  aRect: TRect;
  szBuf : array[0..100] of Char;
  aAccount, aSymbolLeft, aSymbolRight : TObject;
  bSync : Boolean;
  stMapName : String ; 
begin
  // �۾����� open Stream.read -> set
  aBinStream:= Stream as TMemoryStream;
  with aBinStream do
  begin

    //--1. Account & Symbol
    Read(szBuf, 15);
    stAccount := szBuf;
    aAccount:= gTrade.AccountStore.FindAccount(Trim(stAccount));
    Read(szBuf, 9);
    stSymbol := szBuf;
    aSymbolLeft:= gPrice.SymbolStore.FindSymbol(Trim(stSymbol));
    Read(szBuf, 9);
    stSymbol := szBuf;
    aSymbolRight:= gPrice.SymbolStore.FindSymbol(Trim(stSymbol));

    //--2. form config
    Read(bSync, SizeOf(Boolean));
    ButtonSync.Down := bSync;
    Read(FVisibleInfo[stLeft], SizeOf(Boolean));
    Read(FVisibleInfo[stRight], SizeOf(Boolean));

    //--3. Order qty table
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        Read(iQty, SizeOf(Integer));
        GridQtyLeft.Cells[i,j] := IntToStr(iQty);
      end;
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        Read(iQty, SizeOf(Integer));
        GridQtyRight.Cells[i,j] := IntToStr(iQty);
      end;
    GridQtyLeft.RowCount := QTY_ROW_CNT ;
    GridQtyLeft.ColCount := QTY_COL_CNT ;
    GridQtyRight.RowCount := QTY_ROW_CNT ;
    GridQtyRight.ColCount := QTY_COL_CNT ;

    //--4. Order config
    Read(FConfig.TickCnt[stLeft], SizeOf(Integer));
    Read(FConfig.FillCnt[stLeft], SizeOf(Integer));
    Read(FConfig.VisibleTicks[stLeft], SizeOf(Boolean));
    Read(FConfig.FillFilter[stLeft], SizeOf(Boolean));

    Read(FConfig.TickCnt[stRight], SizeOf(Integer));
    Read(FConfig.FillCnt[stRight], SizeOf(Integer));
    Read(FConfig.VisibleTicks[stRight], SizeOf(Boolean));
    Read(FConfig.FillFilter[stRight], SizeOf(Boolean));

    //
    Read(FConfig.VisibleUnder, SizeOf(Boolean));
    Read(FConfig.VisibleOHL, SizeOf(Boolean));
    Read(FConfig.VisibleEvalPL, SizeOf(Boolean));

    Read(FConfig.VisibleOrderAmt , SizeOf(Boolean));
    Read(FConfig.VisibleQT, SizeOf(Boolean));
    Read(FConfig.VisibleZapr, SizeOf(Boolean));
    //
    Read(FConfig.EnableQtyClick, SizeOf(Boolean));
    Read(FConfig.EnableEscape, SizeOf(Boolean));
    Read(FConfig.EnableOneFive, SizeOf(Boolean));
    Read(FConfig.EnableClearOrder, SizeOf(Boolean));
    //
    Read(FConfig.AutoScroll, SizeOf(Boolean));

    Read(FConfig.OrderRightButton, SizeOf(Boolean));
    Read(FConfig.MouseTrace, SizeOf(Boolean));
    Read(FConfig.ConfirmOrder, SizeOf(Boolean));
    //
    Read(FConfig.OrderLeft[stLeft], SizeOf(TPositionType));
    Read(FConfig.VisibleOrder[stLeft], SizeOf(Boolean));
    Read(FConfig.QtyMerge[stLeft], SizeOf(Boolean));
    Read(FConfig.PriceOrderby[stLeft], SizeOf(TPriceOrderbyType));
    Read(FConfig.QtySide[stLeft], SizeOf(TSideType));
    //
    Read(FConfig.OrderLeft[stRight], SizeOf(TPositionType));
    Read(FConfig.VisibleOrder[stRight], SizeOf(Boolean));
    Read(FConfig.QtyMerge[stRight], SizeOf(Boolean));
    Read(FConfig.PriceOrderby[stRight], SizeOf(TPriceOrderbyType));
    Read(FConfig.QtySide[stRight], SizeOf(TSideType));

    // JJB KeyBoard
    Read(szBuf, 91);
    stMapName := szBuf;
    FKeyOrderMap := stMapName;


    // --2007.03.18
    Read(szBuf, 8);
    FConfig.QtyFontColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.QtyBgColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.QtyFontColor[ptLong] := szBuf ;
    Read(szBuf, 8);
    FConfig.QtyBgColor[ptLong] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderFontColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderBgColor[ptShort] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderFontColor[ptLong] := szBuf ;
    Read(szBuf, 8);
    FConfig.OrderBgColor[ptLong] := szBuf ;

  end;

  FKeyOrderMapItem.MapName := FKeyOrderMap;
  gKeyOrderAgent.Notify(FKeyOrderMapItem);

  if FKeyOrderMapItem <> nil then
  begin
    //FKeyOrderMapItem.Broadcaster.Subscribe(PID_KEYORDER, [btNew], Self, KeyOrderProc);
    FKeyOrderMapItem.Subscribe(PID_KEYORDER, [btNew], Self, KeyOrderProc);
  end;

  // -- Setting
  // -- 1. Form
  if FVisibleInfo[stLeft] = false then BtnLeftPanelClick(BtnLeftPanel);
  if FVisibleInfo[stRight] = false then BtnRightPanelClick(BtnLeftPanel);

  //-- 2. Symbol, Account
  if aAccount <> nil then
  begin
    // ComboAccountChnage���� SEtSymbol�� ���ֱ� ������ ���� �Ҵ�

    if aSymbolLeft <> nil then SetSymbol( stLEft, TSymbol(aSymbolLeft)) ;
    if aSymbolRight <> nil then SetSymbol(stRight, TSymbol(aSymbolRight))  ;
    //
    SetCombo(aAccount, ComboAccount);
    ComboAccountChange(ComboAccount);
  end;


  // -- 3. Config
  SetConfig(true )  ;

end;

procedure TDoubleOrderForm.GetPersistence(Stream: TObject);
var
  aBinStream : TMemoryStream;
  i, j , iQty : Integer;
  stAccount, stSymbolLeft, stSymbolRight, stMapName : String;
  szBuf : array[0..100] of Char;
begin
  // �۾����� close : get -> aBinStream.Write
  aBinStream:= Stream as TMemoryStream;
  with aBinStream do
  begin
    //--1. Account & Symbol
    if FAccount = nil then
      stAccount := Format('%-14s', [''])
    else
      stAccount := Format('%-14s', [FAccount.FullCode]);
    if FSymbols[stLeft] = nil then
      stSymbolLeft := Format('%-8s', [''])
    else
      stSymbolLeft := Format('%-8s', [FSymbols[stLeft].Code]);
    if FSymbols[stRight] = nil then
      stSymbolRight := Format('%-8s', [''])
    else
      stSymbolRight := Format('%-8s', [FSymbols[stRight].Code]);
    StrPCopy(szBuf, stAccount);
    Write(szBuf, Length(stAccount)+1);
    StrPCopy(szBuf, stSymbolLeft);
    Write(szBuf, Length(stSymbolLeft)+1);
    StrPCopy(szBuf, stSymbolRight);
    Write(szBuf, Length(stSymbolRight)+1);

    //--2. form config
    Write(ButtonSync.Down , SizeOf(Boolean));
    Write(FVisibleInfo[stLeft], SizeOf(Boolean));
    Write(FVisibleInfo[stRight], SizeOf(Boolean));

    //--3. order qty table
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        iQty := StrToIntDef(GridQtyLeft.Cells[i,j], 0);
        Write(iQty, SizeOf(Integer));
      end;
    for i:=0 to QTY_COL_CNT -1 do
      for j:=0 to QTY_ROW_CNT -1 do
      begin
        iQty := StrToIntDef(GridQtyRight.Cells[i,j], 0);
        Write(iQty, SizeOf(Integer));
      end;

    //--4. Order config
    Write(FConfig.TickCnt[stLeft], SizeOf(Integer));
    Write(FConfig.FillCnt[stLeft], SizeOf(Integer));
    Write(FConfig.VisibleTicks[stLeft], SizeOf(Boolean));
    Write(FConfig.FillFilter[stLeft], SizeOf(Boolean));

    Write(FConfig.TickCnt[stRight], SizeOf(Integer));
    Write(FConfig.FillCnt[stRight], SizeOf(Integer));
    Write(FConfig.VisibleTicks[stRight], SizeOf(Boolean));
    Write(FConfig.FillFilter[stRight], SizeOf(Boolean));

    //
    Write(FConfig.VisibleUnder, SizeOf(Boolean));
    Write(FConfig.VisibleOHL, SizeOf(Boolean));
    Write(FConfig.VisibleEvalPL, SizeOf(Boolean));

    Write(FConfig.VisibleOrderAmt , SizeOf(Boolean));
    Write(FConfig.VisibleQT, SizeOf(Boolean));
    Write(FConfig.VisibleZapr, SizeOf(Boolean));
    //
    Write(FConfig.EnableQtyClick, SizeOf(Boolean));
    Write(FConfig.EnableEscape, SizeOf(Boolean));
    Write(FConfig.EnableOneFive, SizeOf(Boolean));
    Write(FConfig.EnableClearOrder, SizeOf(Boolean));
    //
    Write(FConfig.AutoScroll, SizeOf(Boolean));

    Write(FConfig.OrderRightButton, SizeOf(Boolean));
    Write(FConfig.MouseTrace, SizeOf(Boolean));
    Write(FConfig.ConfirmOrder, SizeOf(Boolean));
    //
    Write(FConfig.OrderLeft[stLeft], SizeOf(TPositionType));
    Write(FConfig.VisibleOrder[stLeft], SizeOf(Boolean));
    Write(FConfig.QtyMerge[stLeft], SizeOf(Boolean));
    Write(FConfig.PriceOrderby[stLeft], SizeOf(TPriceOrderbyType));
    Write(FConfig.QtySide[stLeft], SizeOf(TSideType)); 
    //
    Write(FConfig.OrderLeft[stRight], SizeOf(TPositionType));
    Write(FConfig.VisibleOrder[stRight], SizeOf(Boolean));
    Write(FConfig.QtyMerge[stRight], SizeOf(Boolean));
    Write(FConfig.PriceOrderby[stRight], SizeOf(TPriceOrderbyType));
    Write(FConfig.QtySide[stRight], SizeOf(TSideType));
    
    //JJB
    FKeyOrderMap := gKeyOrderAgent.GetMapName(Self);
    stMapName := Format('%-90s', [FKeyOrderMap]);
    StrPCopy(szBuf, stMapName);
    Write(szBuf, Length(stMapName)+1);
    //

    // -- 2007.03.18
    StrPCopy(szBuf, FConfig.QtyFontColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.QtyBgColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.QtyFontColor[ptLong]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.QtyBgColor[ptLong]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderFontColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderBgColor[ptShort]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderFontColor[ptLong]);
    Write(szBuf, 8 );
    StrPCopy(szBuf, FConfig.OrderBgColor[ptLong]);
    Write(szBuf, 8 );

  end;

end;



procedure TDoubleOrderForm.SetData(Data: TObject);
begin

  if Data = nil then Exit;

  if Data is TAccount then
    SetAccount(Data as TAccount)
  else
  if Data is TSymbol then
    SetSymbol(stRight, Data as TSymbol);

end;


// ----- ORder ----- //

procedure TDoubleOrderForm.DoubleNewOrder(aPoint1, aPoint2: TOrderPoint; aSide : TSideType);
var
  stHead : String;
begin
  // FDefQty := StrToIntDef(GridOrderQtyRight.Cells[0, 0], 0);
  //
  if aPoint1.FieldType = ofOrder then
  begin
    NewOrder(aPoint1.PositionType, OrderQty[aSide], aPoint1.Price, aSide); // �ű��ֹ�
    gLog.Add(lkUser, '�����ֹ�â', '�ű��ֹ�����',
      '[' + SideTypeDescs[aSide] + '] Double Click���� �ֹ�����('
        + IntToStr(FOrderHandler.WaitCount) + ')');
  end ;
  
end;

procedure TDoubleOrderForm.NewOrder(aPType: TPositionType; iQty: Integer;
  sPrice: Double; aSide : TSideType );
var
  aReq : TOrderReqItem;
  aRevPType : TPositionType;
  iClearableQty : Integer;
begin

  Application.ProcessMessages;
  if FConfig.ConfirmOrder then
    if  MessageDlg(FTypeString[aPType] + Format('  (%.2f', [sPrice]) + ')�� �����Ͻðڽ��ϱ�?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
  //-- �ֹ�ó��

  if FClearOrder[aSide] and (FOrderType[aSide] = aPType) then
  begin
    Beep;
    Exit;
  end;

  ProcessOrder(aPType, iQty, sPrice, aSide );

  //-- �ֹ�����
  if FOrderHandler.WaitCount > 0 then
  begin
    FOrderHandler.Send;
    FSendTime[aSide] := timeGetTime;
    //
  end;

end;

procedure TDoubleOrderForm.DoubleCancelOrder(aPoint1,
  aPoint2: TOrderPoint; aSide:TSideType);
begin
  CancelOrders( aPoint1, aSide );
  gLog.Add(lkUser, '�����ֹ�â', '����ֹ�����',
         '[' + SideTypeDescs[aSide] +  '] Mouse Move�� �ֹ�����('
          + IntToStr(FOrderHandler.WaitCount) + ')');
end;

procedure TDoubleOrderForm.DoubleChangeOrder(aPoint1,
  aPoint2: TOrderPoint; aSide:TSideType);
begin
  //
  ChangeOrder(aPoint1, aPoint2, aSide);
  gLog.Add(lkUser, '�����ֹ�â', '�����ֹ�����',
         '[' + SideTypeDescs[aSide] + '] Mouse Move�� �ֹ�����('
            + IntToStr(ForderHandler.WaitCount) + ')');
end;

procedure TDoubleOrderForm.CancelOrders(aPoint: TOrderPoint;
  aSide:TSideType; iMaxQty: Integer );
var
  i, iQty : Integer;
  aList : TList;
  aOrder : TOrder;
  aReq : TOrderReqItem;
begin

  if FConfig.ConfirmOrder then
    if MessageDlg('�ֹ��� ����Ͻðڽ��ϱ�?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
  iQty := 0;
  aList := TList.Create;
  try
    if FOrderTablets[aSide].GetOrders(aList, aPoint) = 0 then Exit;
    
    //   ���ü��� ��쿡 ������ �͸� ���� ( ������ ���� ���ݰ�, ������ ���� ��쿡 )
    if  ( abs(aPoint.Price - FLastPoint.Price ) < PRICE_EPSILON )  and
      ( FLastSymbol = FOrderTablets[aSide].Symbol ) then
    begin

      iMaxQty := StrToInt(EditOrderQty.text) ;
      iQty := 0 ;

      for i:=0 to FLastOrderList.Count-1 do
      begin

        if( ListOrders.Items[i].checked ) then
        begin
          aOrder := TOrder(ListOrders.Items[i].Data);
          if aOrder.OrderType = otNew then // redundant check
          begin

            if (iMaxQty > 0) and (iQty + aOrder.UnfillQty > iMaxQty) then
            begin
              if iMaxQty = iQty then Break;
              //
              aReq := FOrderHandler.Put(aOrder, iMaxQty - iQty);
              Break;
            end else
            begin
              Inc(iQty, aOrder.UnfillQty);
              //
              aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty);
              FOrderTablets[aSide].DoOrderReq(aReq, True);
            end;

          end;
        end;

      end;

    end
    else  // -- ���ü��� �ƴ� ��� 
    begin

      for i:=0 to aList.Count-1 do
      begin
        aOrder := TOrder(aList.Items[i]);
        if aOrder.OrderType = otNew then // redundant check
        begin
          if (iMaxQty > 0) and (iQty + aOrder.UnfillQty > iMaxQty) then
          begin
            if iMaxQty = iQty then Break;
            //
            aReq := FOrderHandler.Put(aOrder, iMaxQty - iQty);
            Break;
          end else
          begin
            Inc(iQty, aOrder.UnfillQty);
            //
            aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty);
            FOrderTablets[aSide].DoOrderReq(aReq, True);
          end;
        end;
      end;

    end;

    
    if FOrderHandler.WaitCount > 0 then
    begin
      FOrderHandler.Send;
    end;

  finally
    aList.Free;
  end;
end;

procedure TDoubleOrderForm.CancelOrders(aTypes: TPositionTypes; aSide:TSideType );
var
  i, iQty : Integer;
  aList : TList;
  aOrder : TOrder;
  aReq : TOrderReqItem;
begin
  iQty := 0;
  aList := TList.Create;
  try
    if FOrderTablets[aSide].GetOrders(aList, aTypes) = 0 then Exit;
    //
    for i:=0 to aList.Count-1 do
    begin
      aOrder := TOrder(aList.Items[i]);
      if aOrder.OrderType = otNew then // redundant check
      begin
        aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty);
        FOrderTablets[aSide].DoOrderReq(aReq, True);
      end;
    end;
    //
    if FOrderHandler.WaitCount > 0 then
    begin
      FOrderHandler.Send;
    end;

  finally
    aList.Free;
  end;
end;

procedure TDoubleOrderForm.ChangeOrder(aStart: TOrderPoint; aSide : TSideType ;
  iMaxQty: Integer; sPrice: Double);
var
  i, iQty : Integer;
  aList : TList;
  aOrder : TOrder;
  aReq : TOrderReqItem;
begin
  iQty := 0;
  aList := TList.Create;
  try
    if FOrderTablets[aSide].GetOrders(aList, aStart) = 0 then Exit;
    //
    for i:=0 to aList.Count-1 do
    begin
      aOrder := TOrder(aList.Items[i]);
      if aOrder.OrderType = otNew then // redundant check
      begin
        if (iMaxQty > 0) and (iQty + aOrder.UnfillQty > iMaxQty) then
        begin
          if iMaxQty = iQty then Break;
          //
          aReq := FOrderHandler.Put(aOrder, iMaxQty - iQty, sPrice);
          Break;
        end else
        begin
          Inc(iQty, aOrder.UnfillQty);
          //
          aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty, sPrice);
          FOrderTablets[aSide].DoOrderReq(aReq, True);
        end;
      end;
    end;
    //
    if FOrderHandler.WaitCount > 0 then
    begin
      FOrderHandler.Send;
    end;

  finally
    aList.Free;
  end;

end;

procedure TDoubleOrderForm.ChangeOrder(aStart, aEnd: TOrderPoint; aSide : TSideType);
var
  i : Integer;
  aList : TList;
  aOrder : TOrder;
  aReq : TOrderReqItem;
  iMaxQty, iQty : Integer ;
begin

  if FConfig.ConfirmOrder then
    if  MessageDlg( FTypeString[aStart.PositionType] +
                    Format('�ֹ� (%.2f -> %.2f)�� �����Ͻðڽ��ϱ�?', [aStart.Price, aEnd.Price]),
                    mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;


  aList := TList.Create;
  try
    if FOrderTablets[aSide].GetOrders(aList, aStart) = 0 then Exit;
    //

    //   ���ü��� ��쿡 ������ �͸� ���� ( ������ ���� ���ݰ�, ������ ���� ��쿡 )
    if  ( abs(aStart.Price - FLastPoint.Price ) < PRICE_EPSILON )  and
      ( FLastSymbol = FOrderTablets[aSide].Symbol ) then
    begin

      iMaxQty := StrToInt(EditOrderQty.text) ;
      iQty := 0 ;
        
      for i:=0 to FLastOrderList.Count-1 do
      begin

        if( ListOrders.Items[i].checked ) then
        begin
          aOrder := TOrder(ListOrders.Items[i].Data);

          if aOrder.OrderType = otNew then // redundant check
          begin
            // aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty, aEnd.Price);
            // FOrderTablets[aSide].DoOrderReq(aReq, True);


          if (iMaxQty > 0) and (iQty + aOrder.UnfillQty > iMaxQty) then
          begin
            if iMaxQty = iQty then Break;
            //
            aReq := FOrderHandler.Put(aOrder, iMaxQty - iQty, aEnd.Price);
            Break;
          end else
          begin
            Inc(iQty, aOrder.UnfillQty);
            //
            aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty, aEnd.Price);
            FOrderTablets[aSide].DoOrderReq(aReq, True);
          end;

          end;


        end;

      end;

    end
    // -- ���ü��� �ƴ� ���� ��ü ����
    else
    begin

      for i:=0 to aList.Count-1 do
      begin
        aOrder := TOrder(aList.Items[i]);
        if aOrder.OrderType = otNew then // redundant check
        begin
          aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty, aEnd.Price);
          FOrderTablets[aSide].DoOrderReq(aReq, True);
        end;
      end;

    end;

    //
    if FOrderHandler.WaitCount > 0 then
    begin
      FOrderHandler.Send;
    end;

  finally
    aList.Free;
  end;
end;

procedure TDoubleOrderForm.ProcessOrder(aPType: TPositionType;
  iQty: Integer; sPrice: Double; aSide : TSideType);
var
  aReq : TOrderReqItem;
  aRevPType : TPositionType;
  iClearableQty : Integer;
begin
  //-- check
  if (FAccount = nil) or (FSymbols[aSide] = nil) or
     not (aPType in [ptLong, ptShort]) or (iQty = 0) then
  begin

    {
    gLog.Add(lkDebug, '�����ֹ�', 'ProcessOrder',
      '[Account] ' + FAccount.AccountName +
      ' [Symbol] ' + FSymbols[aSide].Desc +
      ' [Qty] ' +  IntToSTr(iQty) );
    }
    
    Beep;
    Exit;
  end;
  //
  aReq := FOrderHandler.Put(FAccount, FSymbols[aSide], otNew, aPType, ptPrice, ftFAS,
                          nil, iQty, sPrice); // ������ �ű��ֹ�

  FOrderTablets[aSide].DoOrderReq(aReq, True);
  //-- ó������
  StatusInfo.Panels[1].Text := IntToStr(FOrderHandler.WaitCount);

end;


// ----- Subscribe ----- //

procedure TDoubleOrderForm.AccountProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
begin
  if (FAccount = nil) or (DataObj <> FAccount) then Exit;
  // 
  SetAccountInfo ; 
end;

procedure TDoubleOrderForm.OrderProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
var
  i : Integer;
  aOrder : TOrder;
  OrderSpeed : Integer;
  bLeft, bRight : Boolean ;
  iLeftSpeed , iRightSpeed : Integer ;
  stLeftSpeed, stRightSpeed : String ;
begin

  if (Receiver <> Self) or (DataObj = nil) or
      not (DataObj is TOrder) or
     (iBroadcastKind <> OID_ORDER) then
  begin
    gLog.Add(lkError, '�����ֹ�â', '�ֹ�����', 'Data Integrity Failure');
    Exit;
  end;

  //--  EF : ���� �����϶��� FSymbol�� üũ
  //--  DO : bLeft, bRight�� üũ 
  if FAccount = nil then exit ;

  //
  aOrder := DataObj as TOrder;
  // ���尡, ������������ �� �������� ����
  if aOrder.PriceType in [ptMarket, ptBestPrice] then Exit;

  bLeft := false ;
  bRight := false ;
  if (aOrder.Account = FAccount) and ( aOrder.Symbol = FSymbols[stLeft]) then
    bLeft := true ;
  if (aOrder.Account = FAccount) and (aOrder.Symbol = FSymbols[stRight]) then
    bRight := true ;

  // filter
  if ( bLeft = false ) and ( bRight = false ) then exit ; 

  //
  case btValue of
    btNew : // �ű��ֹ�
      begin

        // -- Tablet �׸��� 
        if aOrder.State in [osKseAcpt, osPartFill] then
        begin
          if bLeft = true then
            FOrderTablets[stLeft].DoOrder(aOrder, True);
          if bRight = true then
            FOrderTablets[stRight].DoOrder(aOrder, True);
        end ;
        //

        // -- �ֹ� �ӵ� 
        if (aOrder.State = osKseAcpt) and (aOrder.OrderType = otNew) then
        begin

          stLeftSpeed :=  FOrderSpeed[stLeft] ;
          stRightSpeed := FOrderSpeed[stRight] ;
          
          if bLeft = true then
          begin
            iLeftSpeed := timeGetTime-FSendTime[stLeft];
            if iLeftSpeed < 2000 then
              stLeftSpeed := Format('%d', [iLeftSpeed])
            else
              stLeftSpeed := FOrderSpeed[stLeft] ;
            //
            FOrderSpeed[stLeft] := stLeftSpeed ; 
          end ;
          // 
          if bRight = true then
          begin
            iRightSpeed := timeGetTime-FSendTime[stRight];
            if iRightSpeed < 2000 then
              stRightSpeed := Format('%d', [iRightSpeed])
            else
              stRightSpeed := FOrderSpeed[stRight] ;
            //
            FOrderSpeed[stRight] := stRightSpeed ;
          end ;
          //
          GridInfo.Cells[1, 12] := stLeftSpeed + ' : ' + stRightSpeed ;
        end;

      end;  // -- �ֹ� �ӵ� 
      
    btUpdate : // �ֹ�����
      begin
        if bLeft = true then
          FOrderTablets[stLeft].DoOrder(aOrder, False);
        if bRight = true then
          FOrderTablets[stRight].DoOrder(aOrder, False);
      end ;
  end;

  // 
  if bLeft = true then  UpdateOrderLimits(stLeft);
  if bRight = true then  UpdateOrderLimits(stRight);


  // 2007.05.25
  FOrderTablets[FLastSide].GetOrders(FLastOrderList, FLastPoint)  ;
  // sort - �������� ( ���� �ֽŲ����� )
  if FLastOrderList <> nil then
  begin
    FLastOrderList.Sort(CompareAcpt);
    SetOrderList( FLastSide, FLastSymbol, FLastOrderList, FLastPoint);
  end ;

end;

procedure TDoubleOrderForm.PositionProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
var
  aPosition : TPositionItem;
  CanSelected : Boolean;
  stDailyPL : String;
  bLeft, bRight : Boolean ;
begin

  bLeft := false ;
  bRight := false ;

  //-- filter 1
  if (Receiver <> Self) or (DataObj = nil) or
      not (DataObj is TPositionItem) or
     (not (iBroadcastKind in [OID_POSITION, OID_EVALPL])) then
  begin
    gLog.Add(lkError, '�����ֹ�â', '����������', 'Data Integrity Failure');
    Exit;
  end;

  //--  EF : ���� �����϶��� FSymbol�� üũ
  //--  DO : bLeft, bRight�� üũ 
  if FAccount = nil then exit ;
 
  //-- update T-position at any position
  AssignTPosition(DataObj);

  //-- get position object
  aPosition := DataObj as TPositionItem;

  //-- filter 3
  if (aPosition.Account <> FAccount) then Exit;
  if aPosition.Symbol = FSymbols[stLeft] then bLeft := true ;
  if aPosition.Symbol = FSymbols[stRight] then bRight := true ;
  if ( bLeft = false) and (bRight = false) then exit ;

  //-- Left
  if  bLeft = true  then
  begin
    if (not FSymbols[stLeft].IsCombination)
          and (aPosition.Symbol <> FSymbols[stLeft])  then Exit;

    if FSymbols[stLeft].IsCombination then
    begin
      if (FSymbols[stLeft].Farther <> aPosition.Symbol) and
        (FSymbols[stLeft].Nearest <> aPosition.Symbol) then Exit;
    end;

    FPositions[stLeft] := aPosition;
    SetPositionInfo(stLeft);
    UpdateOrderLimits(stLeft) ;
  end ;
  // -- Right
  if  bRight = true  then
  begin
    if (not FSymbols[stRight].IsCombination)
          and (aPosition.Symbol <> FSymbols[stRight])  then Exit;

    if FSymbols[stRight].IsCombination then
    begin
      if (FSymbols[stRight].Farther <> aPosition.Symbol) and
        (FSymbols[stRight].Nearest <> aPosition.Symbol) then Exit;
    end;

    FPositions[stRight] := aPosition;
    SetPositionInfo(stRight);
    UpdateOrderLimits(stRight) ;
  end ;

end;

procedure TDoubleOrderForm.QuoteUpdate(aSide: TSideType;
  iBroadcastKind: Integer);
var
  aGrid : TStringGrid ;
begin

  if (iBroadcastKind = PID_PRICE) and (not FOrderTablets[aSide].Ready) then
  begin
    ResetOrderTablet(aSide);
  end;

  //-- ���簡/ȣ�� ȭ�� ����
  case iBRoadcastKind of
    PID_PRICE:
      begin
        if FSymbols[aSide].Changed = true then
        begin
          FOrderTablets[aSide].UpdatePrice;
          FPriceReady[aSide] := true ;
        end ;
      end;
    PID_QUOTE:
      begin
        FOrderTablets[aSide].UpdateQuote;
      end;
  end;

  //
  if iBroadcastKind = PID_Price then
  begin
    if FVisibleInfo[stRight]  then
    begin

      if ( ( aSide = stLeft ) and ( BtnLeftInfo.Down = true ) )
        or ( ( aSide = stRight ) and ( BtnRightInfo.Down = true ) ) then
      begin
        with FSymbols[aSide] do
        begin
          GridInfo.Cells[1,1] := Format('%.*n', [Precision,O] ) ;
          GridInfo.Cells[1,2] := Format('%.*n', [Precision,H] ) ;
          GridInfo.Cells[1,3] := Format('%.*n', [Precision,L] ) ;
        end ;
      end;
      //

      if FSynFutures <> nil then
        GridInfo.Cells[1,0] :=  Format('%.2f', [FSynFutures.C]) ;

      {
      if FUnderlyings[aSide] = nil then
      begin
        aGrid.Cells[1,0] := ''  ;
      end
      else
      begin
        aGrid.Cells[1,0] :=
          Format('%.*n', [FUnderlyings[aSide].Precision, FUnderlyings[aSide].C]);
      end ;
      }
      //
      GetOptionsInfo(FSymbols[aSide] , aSide) ;
    end ;
  end
  else if iBroadcastKind = PID_Quote then
  begin
    if ( (FVisibleInfo[stLeft] = true) and  (FConfig.FillFilter[stLeft] = true) )  then
    begin
       FTickPainters[aSide].QuoteProc;
    end;

    if ( (FVisibleInfo[stRight] = true) and  (FConfig.FillFilter[stRight] = true) )  then
    begin
       FTickPainters2[aSide].QuoteProc;
    end;
    
  end;


end;

procedure TDoubleOrderForm.QuoteProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
var
  bLeft ,bRight : Boolean  ;
begin
  if (Receiver <> Self) or (DataObj = nil) or
      not (DataObj is TSymbol) or
      not (iBroadcastKind in [PID_PRICE, PID_QUOTE]) then
  begin
    gLog.Add(lkError, '�����ֹ�â', 'ȣ��/���簡����', 'Data Integrity Failure');
    Exit;
  end;

  // -- initialize
  bLeft := false ;
  bRight := false ;

  // -- Symbol Check
  if FSymbols[stLeft] = DataObj as TSymbol then
    bLeft := true ;
  if FSymbols[stRight] = DataObj as TSymbol then
    bRight := true ;

  // --
  if ( FSymbols[stLeft] = DataObj as TSymbol ) or
    ( FSymbols[stRight] = DataObj as TSymbol )  then
  begin
    //
    if bLeft = true then
      QuoteUpdate(stLeft, iBroadcastKind);
    if bRight = true then
      QuoteUpdate(stRight, iBroadcastKind);
    //
  end;  // if DataObj = FSymbol END

end;

procedure TDoubleOrderForm.TickProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
var
  aSymbol : TSymbol ;
  bLeft, bRight: Boolean ;
  dDeliverySec : Double;
  stLeftTime, stRightTime : String ;
  DeliveryTime : TDateTime;
begin
  //
  if ( Sender = nil) then exit ;
  if not (Sender is TSymbol) then exit ;

  bLeft := false ;
  bRight := false ;
  aSymbol := Sender as TSymbol ;
  if aSymbol = FSymbols[stLeft] then  bLeft := true ;
  if aSymbol = FSymbols[stRight] then  bRight := true ;

  // TickPainters Update;
  if FVisibleInfo[stLeft] and ( FConfig.FillFilter[stLeft]=false ) then
  begin
    if bLeft = true then
    begin
      FTickPainters[stLeft].Update;
    end;
    if bRight = true then
    begin
      FTickPainters[stRight].Update;
    end ;
  end;

  // TickPainters Update;
  if FVisibleInfo[stRight] and ( FConfig.FillFilter[stRight]=false ) then
  begin
    if bLeft = true then
    begin
      FTickPainters2[stLeft].Update;
    end;
    if bRight = true then
    begin
      FTickPainters2[stRight].Update;
    end;

  end;

  //
  stLeftTime := FDeliveryTime[stLeft] ;
  stRightTime := FDeliveryTime[stRight] ;

  if (bLeft = true) then
  begin
    if ( FPriceReady[stLeft] = true) then Inc(FTickCounts[stLeft]);

    if BtnLeftInfo.Down = true then
      GridInfo.Cells[1, 4] :=
        Format('%.0n',[( aSymbol.Ticks[0] as TFillTickItem ).AccVol ]) ;
    //
    if FSymbols[stLeft].Quote.UpdateTime > 0.1 then
    begin
      dDeliverySec := FSymbols[stLeft].DelayMs/1000.0;
      stLeftTime := Format('%.1f', [dDeliverySec]);
      FDeliveryTime[stLeft] := stLeftTime ;
    end
    else
    begin
      stLeftTime := FDeliveryTime[stLeft] ;
    end;

  end ;
  if (bRight = true) then
  begin
    if ( FPriceReady[stRight] = true )  then Inc(FTickCounts[stRight]);
    if BtnRightInfo.Down = true then
      GridInfo.Cells[1, 4] :=
        Format('%.0n',[( aSymbol.Ticks[0] as TFillTickItem ).AccVol ]) ;
    //
    if FSymbols[stRight].Quote.UpdateTime > 0.1 then
    begin
      dDeliverySec := FSymbols[stRight].DelayMs/1000.0;
      stRightTime := Format('%.1f', [dDeliverySec]);
      FDeliveryTime[stRight] := stRightTime ;
      //
      if dDeliverySec > 3.0 then
      begin
        edDeliveryTime.Font.Color := clWhite;
        edDeliveryTime.Color := clRed;
      end
      else if dDeliverySec > 1.8 then
      begin
        edDeliveryTime.Font.Color := clWindowText;
        edDeliveryTime.Color := $8080FF;
      end
      else
      begin
        edDeliveryTime.Font.Color := clWindowText;
        edDeliveryTime.Color := clWhite;
      end;
      //
      edDeliveryTime.Text := stRightTime ;
    end
    else
    begin
      stRightTime := FDeliveryTime[stRight] ;
    end;
    //

  end ;
  //
  stLeftTime := FDeliveryTime[stLeft] ;
  stRightTime := FDeliveryTime[stRight] ;

  if ( BtnLeftInfo.Down = true ) or ( BtnRightInfo.Down = true ) then
    GridInfo.Cells[1, 13] := stLeftTime + ' : ' + stRightTime ;

  // ù��° ƽ�̸� ���簡�� �߾�����
  if ( bLeft = true ) and ( FTickCounts[stLeft] <= 1 ) and
      ( FOrderTablets[stLeft].Ready = True ) then
  begin
    FOrderTablets[stLeft].MoveToPrice;
  end;

  if ( bRight = true ) and ( FTickCounts[stRight] <= 1 ) and
      ( FOrderTablets[stRight].Ready = True ) then
  begin
    FOrderTablets[stRight].MoveToPrice;
  end;
  //
end;

procedure TDoubleOrderForm.MinPriceProc(Sender: TObject);
var
  bLeft, bRight : Boolean ;
begin

  // 2007.06.19
  exit ;


  bLeft := false ;
  bRight := false ;
  if  FZaprServices[stLeft].Symbol = FSymbols[stLeft] then bLeft := true ;
  if  FZaprServices[stRight].Symbol = FSymbols[stRight] then bRight := true ;
  //
  if bLeft = true then
  begin
    if (not FConfig.VisibleZapr) or (not FZaprServices[stLeft].Ready) then
    begin
      FOrderTablets[stLeft].MinPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stLeft].MinPrice := FZaprServices[stLeft].MinPrice;
    end;
  end ;
  //
  if bRight = true then
  begin
    if (not FConfig.VisibleZapr) or (not FZaprServices[stRight].Ready) then
    begin
      FOrderTablets[stRight].MinPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stRight].MinPrice := FZaprServices[stRight].MinPrice;
    end;
  end ;

end;

procedure TDoubleOrderForm.MaxPriceProc(Sender: TObject);
var
  bLeft, bRight : Boolean ;
begin

  // 2007.06.19
  exit ;

  bLeft := false ;
  bRight := false ;
  if  FZaprServices[stLeft].Symbol = FSymbols[stLeft] then bLeft := true ;
  if  FZaprServices[stRight].Symbol = FSymbols[stRight] then bRight := true ;
  //
    if bLeft = true then
  begin
    if (not FConfig.VisibleZapr) or (not FZaprServices[stLeft].Ready) then
    begin
      FOrderTablets[stLeft].MaxPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stLeft].MaxPrice := FZaprServices[stLeft].MaxPrice;
    end;
  end ;
  //
  if bRight = true then
  begin
    if (not FConfig.VisibleZapr) or (not FZaprServices[stRight].Ready) then
    begin
      FOrderTablets[stRight].MaxPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stRight].MaxPrice := FZaprServices[stRight].MaxPrice;
    end;
  end ;
  
end;

procedure TDoubleOrderForm.ObserverProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
var
  aItem : TObserverItem;
begin
  if (Receiver <> Self) or (DataObj = nil) then
  begin
    gLog.Add(lkError, '�����ֹ�â', '������ ��Ʈ��', 'Data Integrity Failure');
    Exit;
  end;

  // ���� �ֹ��� ���� �ִ� ����
  if (iBroadcastKind = CFID_DOORDER) or
     (iBroadcastKind = CFID_EFORDER) then
  begin
    aItem := DataObj as TObserverItem;

    case aItem.ActionID of
      ACID_CENTER :
        begin
          FOrderTablets[stLeft].MoveToPrice;
          FOrderTablets[stRight].MoveToPrice;
        end;
    end;

  end;


end;



// ----- Private ----- //

function TDoubleOrderForm.MakeGridTPosition(aGrid: TStringGrid;
  aOptionMonth: TOptionMonthlyItem; bFixed: Boolean): Boolean;
var
  i, iOffset : Integer;
begin
  Result := False;

  if aGrid = nil then Exit;

  with aGrid do
  begin
    RowCount := 0;  //Reset

    if bFixed then
      iOffset := 1
    else
      iOffset := 0;

    if aOptionMonth <> nil then
    begin
      RowCount := aOptionMonth.StrikePriceCount+iOffset;
      FixedRows := iOffset;

      if bFixed then
      begin
        Cells[0,0] := 'Call';
        Cells[1,0] := '��簡';
        Cells[2,0] := 'Put';
      end;

      if gTPositionDownOrder then
        for i := 0 to aOptionMonth.StrikePriceCount-1 do
        begin
          Cells[0, i+iOffset] := '';
          Objects[0, i+iOffset] := aOptionMonth.StrikePrices[i].Symbols[otCall];
          Cells[1, i+iOffset] := aOptionMonth.StrikePrices[i].StrikeDesc;
          if bFixed then
            Objects[1, i+iOffset] := aOptionMonth.StrikePrices[i]
          else
            Objects[1, i+iOffset] := nil;
          Cells[2, i+iOffset] := '';
          Objects[2, i+iOffset] := aOptionMonth.StrikePrices[i].Symbols[otPut];
        end
      else
        for i := 0 to aOptionMonth.StrikePriceCount-1 do
        begin
          Cells[0, RowCount-1-i] := '';
          Objects[0, RowCount-1-i] := aOptionMonth.StrikePrices[i].Symbols[otCall];
          Cells[1, RowCount-1-i] := aOptionMonth.StrikePrices[i].StrikeDesc;
          if bFixed then
            Objects[1, RowCount-1-i] := aOptionMonth.StrikePrices[i]
          else
            Objects[1, RowCount-1-i] := nil;
          Cells[2, RowCount-1-i] := '';
          Objects[2, RowCount-1-i] := aOptionMonth.StrikePrices[i].Symbols[otPut];
        end;
    end else
    begin
      RowCount := 1+iOffset;
      FixedRows := iOffset;

      if bFixed then
      begin
        Cells[0,0] := 'Call';
        Cells[1,0] := '��簡';
        Cells[2,0] := 'Put';
      end;

    end;
  end;
  Result := True;
end;

procedure TDoubleOrderForm.AssignOptionPosition;
var
  i : Integer;
  aFindPosition : TPositionItem;
begin
  for i:=1 to GridOptions.RowCount-1 do
  begin
    // Init
    GridOptions.Cells[0,i]:= '';
    GridOptions.Cells[2,i]:= '';

    aFindPosition :=
      gTrade.PositionStore.FindPosition(FAccount, TSymbol(GridOptions.Objects[0,i]));

    if (aFindPosition <> nil) then
      GridOptions.Cells[0,i]:=  IntToStr(aFindPosition.CurQty);

    aFindPosition :=
      gTrade.PositionStore.FindPosition(FAccount, TSymbol(GridOptions.Objects[2,i]));

    if (aFindPosition <> nil) then
      GridOptions.Cells[2,i]:=  IntToStr(aFindPosition.CurQty);
    
  end;
end;

procedure TDoubleOrderForm.AssignTPosition(DataObj: TObject);
var
  aFutureMonth : TFutureMonthlyItem;
  aOptionMonth : TOptionMonthlyItem;
  aStrike : TStrikePriceItem;
  aPosition,aFindPosition : TPositionItem;
begin
  //
  aPosition := DataObj as TPositionItem;
  //FPosition := aPosition;
  // ���� ������ ǥ�� �ϱ�
  case aPosition.Symbol.DerivativeType of
    dtFutures:  // ���� ������ ǥ���ϱ�
      // ���õ� ���°� �ְ� ������ �̹� ������ �Ǿ� �ִ� ����
      if (aPosition.Account = FAccount) and (ComboFutures.ItemIndex >= 0) then
      begin
        aFutureMonth:=
          TFutureMonthlyItem(ComboFutures.Items.Objects[ComboFutures.ItemIndex]);

        if aPosition.Symbol = nil then exit;
        if aFutureMonth = nil then exit;

        if aPosition.Symbol = aFutureMonth.Symbol then
          EditFutures.Caption:= IntToStr(aPosition.CurQty);

        if (aPosition.OrderQtys[ptLong] + aPosition.OrderQtys[ptShort]) > 0 then
          EditFutures.Color := $00FFE7B3 
        else 
          EditFutures.Color := $00EEEEEE ;

      end;
    dtOptions: // �ɼ������� ǥ���ϱ�
    begin
      if FOptionMonth <> nil then Exit;  // �ɼ��������� ���õ��� ������ ����
      AssignOptionPosition;  // �ɼ� ������ ǥ���ϱ�
    end;
  end;
end;

procedure TDoubleOrderForm.InitTablet(aSide : TSideType ; aPaintBox : TPaintBox);
begin
  FOrderTablets[aSide] := TOrderTablet.Create ;
  FOrderTablets[aSide].OnNewOrder := DoubleNewOrder;
  FOrderTablets[aSide].OnChangeOrder := DoubleChangeOrder;
  FOrderTablets[aSide].OnCancelOrder := DoubleCancelOrder;
  FOrderTablets[aSide].TabletSide := aSide ;
  FOrderTablets[aSide].TabletColor := TABLET_COLOR[aSide];

  // 2007.05.24 �ֹ� ����Ʈ
  FOrderTablets[aSide].OnOrderList := SetOrderList ;


  // assign EFTablet
  with FOrderTablets[aSide] do
  begin

    // 2006.08.05 YHW : value EFTablet�� ����� ��ü
    SetArea(aPaintBox);
    ColWidths[ocOrder]:= ORDER_WIDTH ;
    ColWidths[ocQty]:= QTY_WIDTH ;
    ColWidths[ocPrice]:= PRICE_WIDTH ;
    ColWidths[ocAdded]:= ADDED_WIDTH ;
    ColWidths[ocGut]:= GUT_WIDTH ;
    ColWidths[ocIV] := IV_WIDTH ;

    PriceOrderby := poAsc ;
    FPrevOrderBy[aSide] :=  poAsc ; 
  end;

end;

procedure TDoubleOrderForm.InitControls;
begin

  // -- Grid Header
  with GridQtyLeft do
  begin
    Cells[0,0] :=  '1';
    Cells[1,0] :=  '10';
    Cells[2,0] :=  '50';
    Cells[3,0] :=  '100';
    Cells[0,1] :=  '120';
    Cells[1,1] :=  '150';
    Cells[2,1] :=  '200';
    Cells[3,1] :=  '220';
    Cells[0,2] :=  '250';
    Cells[1,2] :=  '300';
    Cells[2,2] :=  '0';
    Cells[3,2] :=  '0';
  end ;
  with GridQtyRight do
  begin
    Cells[0,0] :=  '1';
    Cells[1,0] :=  '10';
    Cells[2,0] :=  '50';
    Cells[3,0] :=  '100';
    Cells[0,1] :=  '120';
    Cells[1,1] :=  '150';
    Cells[2,1] :=  '200';
    Cells[3,1] :=  '220';
    Cells[0,2] :=  '250';
    Cells[1,2] :=  '300';
    Cells[2,2] :=  '0';
    Cells[3,2] :=  '0';
  end ;
  //
  with GridOptions do
  begin
    Cells[0,0] := 'Call';
    Cells[1,0] := '��簡';
    Cells[2,0] := 'Put';
  end;
  //

  with GridInfo do
  begin
    Cells[0,0] := '�ռ�����' ;
    Cells[0,1] := '��' ;
    Cells[0,2] := '��' ;
    Cells[0,3] := '��' ;
    Cells[0,4] := '�ŷ���' ;
    //
    Cells[0,5] := '��Ÿ' ;
    Cells[0,6] := '����' ;
    Cells[0,7] := '��Ÿ' ;
    Cells[0,8] := '����' ;
    Cells[0,9] := 'IV' ;
    //
    Cells[0,10] := '���ϼ���' ;
    Cells[0,11] := '����������' ;
    Cells[0,12] := '�ֹ��ð�' ;
    Cells[0,13] := '�ü�����' ;

  end;


  // -- Populate Account, Under
  // gTrade.AccountStore.PopulateCombo(ComboAccount.Items, [ctAccount]);

  PopulateAccount ;
  gPrice.SymbolStore.PopulateUnderlyings(ComboUnders.Items);
  gPrice.SymbolStore.GetRecentList(ComboSymbol.Items);

  if ( ComboSymbol.Items.Count > 0 )    then
  begin
    if ComboSymbol.Items.Objects[0] <> nil  then
    begin
      FSymbols[stLeft] := ComboSymbol.Items.Objects[0] as TSymbol;
      FSymbols[stRight] := FSymbols[stLeft] ;
    end;
  end ; 

  // -- Qty
  GridQtyLeft.Col := 0;
  GridQtyLeft.Row := 0;
  GridQtyRight.Col := 0;
  GridQtyRight.Row := 0;
  with GridQtyLeft do
  begin
    FDefQty[stLeft] := StrToIntDef(Cells[Selection.Left,Selection.Top], 0);
  end;
  with GridQtyRight do
  begin
    FDefQty[stRight] := StrToIntDef(Cells[Selection.Left,Selection.Top], 0);
  end;
  SetOrderQty(IntToStr(FDefQty[stLeft]) , true , stLeft );
  SetOrderQty(IntToStr(FDefQty[stRight]) , true , stRight );
  
end;



procedure TDoubleOrderForm.ResetOrderTablet(aSide: TSideType);
var
  stLeftDesc, stRightDesc : String ;
  aGrid : TStringGrid ;
  aOtherSide : TSideType ;
begin

  //-- �ʱ�ȭ
  FOrderTablets[aSide].Clear;
  FPositions[aSide] := nil;

  // -- ��������/�������� ����
  SetPriceOrder ;
  if FConfig.PriceOrderby[aSide] = poAuto then
  begin
     FOrderTablets[aSide].RefreshColumns(
      FConfig.OrderLeft[aSide] , false,
      FConfig.QtyMerge[aSide], FConfig.QtySide[aSide], false );
  end;

  //-- Data Table �����Ҵ�
  FOrderTablets[aSide].Symbol := FSymbols[aSide];

  //
  FOrderTablets[aSide].Ready := True ;

  // -- �ݴ���, �������� / ��������
  if aSide = stLeft then
    aOtherSide := stRight
  else
    aOtherSide := stLeft ;
  if FConfig.PriceOrderby[aOtherSide] = poAuto then
  begin
    FOrderTablets[aOtherSide].RefreshColumns(
      FConfig.OrderLeft[aOtherSide] , false,
      FConfig.QtyMerge[aOtherSide], FConfig.QtySide[aOtherSide], false );
    SetSymbol(aOtherSide, FSymbols[aOtherSide]);
  end ;
  // -- Caption --> SetSymbol�� �ű� ( ���� ���������� �ٷ� ����ǵ��� )
  {
  if FSymbols[stLeft] <> nil then
    stLeftDesc := FSymbols[stLeft].Desc
  else
    stLeftDesc := '' ;
  if FSymbols[stRight] <> nil then
    stRightDesc := FSymbols[stRight].Desc
  else
    stRightDesc := '' ;
  Caption := '�����ֹ� : ' + FAccount.AccountName + ' [' +
    stLeftDesc + '] , [' +  stRightDesc + '] '  ;
  }
  
  //-- ������ & �ֹ� �ʱ�ȭ
  gTrade.PositionStore.GetAll(Self, PositionProc);
  gTrade.OrderStore.GetAll(Self, OrderProc);

  // 
  UpdateOrderLimits(aSide);

end;

// ----- Setter/Getter ----- //

procedure TDoubleOrderForm.SetAccount(aAccount: TAccount);
begin
   if aAccount = nil then Exit;
  //
  SetCombo(aAccount, ComboAccount);
  ComboAccountChange(ComboAccount);
  // 
end;

procedure TDoubleOrderForm.SetSymbol(aSide: TSideType;
  aSymbol: TSymbol);
var
  iRow, iCol, i : Integer;
  CanSelected : Boolean;
  aGrid : TStringGrid ;
  stLeftDesc, stRightDesc : String ; 
begin
  if aSymbol = nil then Exit;
  //
  gPrice.SymbolStore.UseSymbol(aSymbol);
  //
  FOrderTablets[aSide].Ready := False;
  FDeliveryTime[aSide] := '' ;

  FOrderTablets[aSide].InitSymbol(aSymbol);

  FTickPainters[aSide].Symbol := nil;
  // jjb
  FTickPainters2[aSide].Symbol := nil;

  FZaprServices[aSide].Symbol := nil;
  FPriceReady[aSide] := false ;

  // -- ���� ���� Unsubscribe
  {
  if FSymbols[stLeft] = nil  then
    gLog.Add(lkError, '�����ֹ�â', 'SetSymbol', 'left nil ' )
  else
     gLog.Add(lkError, '�����ֹ�â', 'SetSymbol', 'left ' + FSymbols[stLeft].Desc );

  if FSymbols[stRight] = nil  then
    gLog.Add(lkError, '�����ֹ�â', 'SetSymbol', 'right nil ' )
  else
     gLog.Add(lkError, '�����ֹ�â', 'SetSymbol', 'right ' + FSymbols[stRight].Desc );
  }
  
  if FSymbols[stLeft] <> FSymbols[stRight] then
  begin
    if FSymbols[aSide] <> nil then
      FSymbols[aSide].Unsubscribe(Self);
    if FUnderlyings[aSide] <> nil then
      FUnderlyings[aSide].Unsubscribe(self);
    //
    FSubscribe[aSide] := false ;
  end;

  // -- ���õ� ����
  FSymbols[aSide] := aSymbol ;
  if FSymbols[aSide].SymbolType in [stStock, stIndex] then
    FUnderlyings[aSide] := FSymbols[aSide]
  else
    FUnderlyings[aSide] := FSymbols[aSide].Underlying;
  

  // -- ���õ� ������ �Ѵ� ���� ��� 
  if FSymbols[stLeft] = FSymbols[stRight] then
  begin

    // �Ѵ� �� ���� �����϶� 
    if ( FSubscribe[stLeft] = false ) and ( FSubscribe[stRight] = false ) then
    begin
      FSymbols[aSide].Subscribe(PID_Price, [btUpdate], Self, QuoteProc);
      FSymbols[aSide].Subscribe(PID_Quote, [btUpdate], Self, QuoteProc);
      FSymbols[aSide].Subscribe(PID_TICK, [btNew], Self, TickProc) ;
      FUnderlyings[aSide].Subscribe(PID_PRICE, [btUpdate], Self, QuoteProc);
      //
      FSubscribe[stLeft] := true ;
      FSubscribe[stRight] := true ;
    end
    else    // ���� �����϶� 
    begin
      // �۾��ڵ� : UD_HW_001
      // �۾��� : 2006.12.02
      QuoteUpdate(aSide, PID_PRICE );
    end;

  end
  else    // -- �¿� ������ �ٸ� ��� 
  begin
    FSymbols[aSide].Subscribe(PID_Price, [btUpdate], Self, QuoteProc);
    FSymbols[aSide].Subscribe(PID_Quote, [btUpdate], Self, QuoteProc);
    FSymbols[aSide].Subscribe(PID_TICK, [btNew], Self, TickProc) ;
    FUnderlyings[aSide].Subscribe(PID_PRICE, [btUpdate], Self, QuoteProc);
    //
    FSubscribe[aSide] := true ;  
  end ;

  // 
  FTickPainters[aSide].Symbol := FSymbols[aSide];
  FTickPainters2[aSide].Symbol := FSymbols[aSide];


  // 2007.06.19 
  // FZaprServices[aSide].Symbol := FSymbols[aSide];

  // gWin.SetFormDefault(Self);
  // gWin.ModifyWorkspace;

  FTickCounts[aSide] := 0;

  // -- ����â
  for i := 0 to GridInfo.RowCount - 1 do
  begin
    GridInfo.Cells[1,i] := '' ;
  end;

  // 
  if FSymbols[stLeft] <> nil then
    stLeftDesc := FSymbols[stLeft].Desc
  else
    stLeftDesc := '' ;
  if FSymbols[stRight] <> nil then
    stRightDesc := FSymbols[stRight].Desc
  else
    stRightDesc := '' ;
  Caption := 'DO ' + FAccount.AccountName + ' [' +
    stLeftDesc + ', ' +  stRightDesc + ']';


  // 2007.05.25
  // reset ( �ٽ� �׷��ֱ� ���� ) 
  FLastSynFutures := 0 ;
  if( aSide = FLastSide ) then
  begin
    FLastSymbol := aSymbol ;
    FLastOrderList := TList.Create ;
    FLastPoint.Price := 0 ;
    FLastPoint.Index := -1 ; 
    //
    SetOrderList( aSide , FLastSymbol, FLastOrderList, FLastPoint) ;
  end ;

  // JJB
  case aSide of
    stLeft  : gKeyOrderAgent.SetSymbolA(Self, aSymbol);
    stRight : gKeyOrderAgent.SetSymbolB(Self, aSymbol);
  end;



  {
  if ButtonSync.Down and not(FAccountSynchronizing) and (FSymbol <> nil) then
    gWin.Synchronize(Self, [FSymbols[aSide]);
    
  FTickCount := 0;
  }

end;

function TDoubleOrderForm.GetDefQty(aSide: TSideType): Integer ;
begin
  if aSide = stLeft then
    FDefQty[stLeft] := StrToInt(GridOrderQtyLeft.Cells[0,0])  
  else if aSide = stRight then
    FDefQty[stRight] := StrToInt(GridOrderQtyRight.Cells[0,0]) ;
  //
  Result := FDefQty[aSide] ;
end;


// -- ���ݿ� �Ѵ� Auto �϶� 
procedure TDoubleOrderForm.SetBothAutoPriceOrder;
begin

  {
  // ����
  if  ( FSymbols[stRight].OptionType = stOption ) and
    ( FSymbols[stRight].OptionType = otPut )  then
  begin

    // -- �Ѵ� Put�϶��� �Ѵ� ��������
    if ( FSymbols[stLeft].OptionType = stOption ) and
        ( FSymbols[stLeft].OptionType = otPut ) then
      FOrderTablets[stLeft].PriceOrderby := poAsc
    else
      FOrderTablets[stLeft].PriceOrderby := poDesc ;

  end;
  }

end;


function TDoubleOrderForm.GetOtherSideOrder(
  aPriceOrder: TPriceOrderbyType): TPriceOrderbyType;
var
  aOrder : TPriceOrderbyType ;
begin
  if( aPriceOrder = poAsc ) then
    aOrder := poDesc
  else if( aPriceOrder = poDesc) then
    aOrder := poAsc
  else
    aOrder := poAsc ;
  //
  Result := aOrder ;
end;

function TDoubleOrderForm.GetPositionLeft(
  aPriceOrder: TPriceOrderbyType): TPositionType;
var
  aPosition : TPositionType ;
begin
  if aPriceOrder = poAsc then
    aPosition := ptShort
  else if aPriceOrder = poDesc  then
    aPosition := ptLong
  else
    aPosition := ptShort ;
  //
  Result := aPosition ;
end;

procedure TDoubleOrderForm.SetAutoPriceOrder(aSide: TSideType;
  aPriceOrder: TPriceOrderbyType; aTargetSide : TSideType) ;
begin

  if ( FSymbols[aSide].SymbolType = stFuture ) then
  begin

    if ( FSymbols[aTargetSide].SymbolType = stFuture ) then
      FOrderTablets[aTargetSide].PriceOrderby := aPriceOrder
    else if ( FSymbols[aTargetSide].SymbolType = stOption ) then
    begin
      if ( FSymbols[aTargetSide].OptionType = otPut ) then
        FOrderTablets[aTargetSide].PriceOrderby := GetOtherSideOrder(aPriceOrder)
      else
        FOrderTablets[aTargetSide].PriceOrderby := aPriceOrder ;
    end;

  end
  else  if ( FSymbols[aSide].SymbolType = stOption ) then
  begin

    if ( FSymbols[aSide].OptionType = otCall ) then
    begin

      if ( FSymbols[aTargetSide].SymbolType = stFuture ) then
        FOrderTablets[aTargetSide].PriceOrderby := aPriceOrder
      else if ( FSymbols[aTargetSide].SymbolType = stOption ) then
      begin
        if ( FSymbols[aTargetSide].OptionType = otPut ) then
          FOrderTablets[aTargetSide].PriceOrderby := GetOtherSideOrder(aPriceOrder)
        else
          FOrderTablets[aTargetSide].PriceOrderby := aPriceOrder  ;
      end;

    end
    else  if ( FSymbols[aSide].OptionType = otPut ) then
    begin

      if ( FSymbols[aTargetSide].SymbolType = stFuture ) then
        FOrderTablets[aTargetSide].PriceOrderby := GetOtherSideOrder(aPriceOrder)
      else if ( FSymbols[aTargetSide].SymbolType = stOption ) then
      begin
        if ( FSymbols[aTargetSide].OptionType = otPut ) then
          FOrderTablets[aTargetSide].PriceOrderby := aPriceOrder
        else
          FOrderTablets[aTargetSide].PriceOrderby := GetOtherSideOrder(aPriceOrder)  ;
      end;

    end;

  end;

  FOrderTablets[aSide].PriceOrderby := FConfig.PriceOrderby[aSide] ;
  FConfig.OrderLeft[aTargetSide] := GetPositionLeft(FOrderTablets[aTargetSide].PriceOrderby) ;

end;

// -- ���ݿ� ��������/��������
// -- �ٸ� ����( �����϶� ������ ���ݿ�, �������϶� ���� ���ݿ� �˱� ���� ���
procedure TDoubleOrderForm.SetPriceOrder ;
var
  aOrder : TPriceOrderbyType ;
begin

  if (FConfig.PriceOrderby[stLeft] = poAuto ) and
      ( FConfig.PriceOrderby[stRight] = poAuto ) then
  begin
    SetBothAutoPriceOrder ;
  end
  else
  begin

    if FConfig.PriceOrderby[stLeft] = poAuto then
    begin
      SetAutoPriceOrder(stRight, FConfig.PriceOrderby[stRight] , stLeft );
    end
    else if FConfig.PriceOrderby[stRight] = poAuto then
    begin
      SetAutoPriceOrder(stLeft,FConfig.PriceOrderby[stLeft] , stRight );
    end
    else
    begin
      FOrderTablets[stLeft].PriceOrderby := FConfig.PriceOrderby[stLeft] ;
      FOrderTablets[stRight].PriceOrderby := FConfig.PriceOrderby[stRight] ;
    end;
  end;



end;



// bReset true : Tablet refresh ����
// ���� Ŭ���ô� True, Persistence �� False
procedure TDoubleOrderForm.SetConfig( bReset : Boolean ) ;
var
  i: Integer;
  aList : TList;
  iQtyCount : Integer;
  iWidth, iLWidth, iRWidth : Integer ;
  aSideType : TSideType ;
  aPositionType : TPositionType ;
begin

  // �����ܷ�
  FOrderTablets[stLeft].VisibleQT := FConfig.VisibleQT;
  FOrderTablets[stRight].VisibleQT := FConfig.VisibleQT;
  // �ڵ���ũ��
  FOrderTablets[stLeft].AutoScroll := FConfig.AutoScroll;
  FOrderTablets[stRight].AutoScroll := FConfig.AutoScroll;
  // mouse point
  FOrderTablets[stLeft].MouseTrace := FConfig.MouseTrace ;
  FOrderTablets[stRight].MouseTrace := FConfig.MouseTrace ;

  // Underlying Combo
  PanelUnders.Visible := FConfig.VisibleUnder;
  if PanelUnders.Visible then
  begin
    PanelUnders.Height := 24 ;
    PanelSymbols.Height := 73 ;
  end
  else
  begin
    PanelUnders.Height := 0;
    PanelSymbols.Height := 49 ;
  end ;

  // -- FConfig�� �¿� ������ ���� �г�, ���� �г�
  // -- FTickPainters�� ���� �г��� �¿� ������ TickPainter
  // -- FTickPainters2�� ���� �г��� �¿� ������ TickPainter

  // set Ticks
  PaintTicksLeft.Visible := FConfig.VisibleTicks[stLeft];
  PaintTicksRight.Visible := FConfig.VisibleTicks[stLeft];
  FTickPainters[stLeft].RowCount := FConfig.TickCnt[stLeft] ;
  FTickPainters[stRight].RowCount := FConfig.TickCnt[stLeft] ;
  FTickPainters[stLeft].UseFilter := FConfig.FillFilter[stLeft];
  FTickPainters[stLeft].FillQty := FConfig.FillCnt[stLeft] ;
  FTickPainters[stRight].UseFilter := FConfig.FillFilter[stLeft];
  FTickPainters[stRight].FillQty := FConfig.FillCnt[stLeft] ;

  //jjb
  PaintTicksLeft2.Visible := FConfig.VisibleTicks[stRight];
  PaintTicksRight2.Visible := FConfig.VisibleTicks[stRight];
  FTickPainters2[stLeft].RowCount := FConfig.TickCnt[stRight] ;
  FTickPainters2[stRight].RowCount := FConfig.TickCnt[stRight] ;
  FTickPainters2[stLeft].UseFilter := FConfig.FillFilter[stRight];
  FTickPainters2[stLeft].FillQty := FConfig.FillCnt[stRight] ;
  FTickPainters2[stRight].UseFilter := FConfig.FillFilter[stRight];
  FTickPainters2[stRight].FillQty := FConfig.FillCnt[stRight] ;

  //jjb
  PageTick.Height := FConfig.TickCnt[stLeft] * 15 + 45{PageHeader + �ణ�� ��������};
  PageDummy.Height := FConfig.TickCnt[stRight] * 15 + 45;
  //

  // 2007.03.18 Color
  for aSideType := stLeft to stRight do
  begin
      for aPositionType := ptLong to ptShort do
      begin
        FOrderTablets[aSideType].QuoteColor[aPositionType, ctBg] :=
          StringToColor(FConfig.QtyBgColor[aPositionType]) ;
        FOrderTablets[aSideType].QuoteColor[aPositionType, ctFont ] :=
          StringToColor(FConfig.QtyFontColor[aPositionType]) ;
        //
        FOrderTablets[aSideType].OrderColor[aPositionType, ctBg ] :=
          StringToColor(FConfig.OrderBgColor[aPositionType]) ;
        FOrderTablets[aSideType].OrderColor[aPositionType, ctFont ] :=
          StringToColor(FConfig.OrderFontColor[aPositionType]) ;
      end;
  end;

  // 2007.06.24 min/max
  {
  MinPriceProc(FZaprServices[stLeft]);
  MaxPriceProc(FZaprServices[stLeft]);
  MinPriceProc(FZaprServices[stRight]);
  MaxPriceProc(FZaprServices[stRight]);
  }
  
  // order right button
  FOrderTablets[stLeft].OrderRightButton :=  FConfig.OrderRightButton ;
  FOrderTablets[stRight].OrderRightButton :=  FConfig.OrderRightButton ;

  // Tablet
  SetPriceOrder ;
  // 
  FOrderTablets[stLeft].RefreshColumns(
  FConfig.OrderLeft[stLeft] , false,
  FConfig.QtyMerge[stLeft], FConfig.QtySide[stLeft], false );
  FOrderTablets[stLeft].ColVisibles[ocOrder] :=
    FConfig.VisibleOrder[stLeft] ;
  FOrderTablets[stLeft].ColVisibles[ocIV] :=
    FConfig.VisibleIV[stLeft] ;
  FOrderTablets[stRight].RefreshColumns(
    FConfig.OrderLeft[stRight] , false,
  FConfig.QtyMerge[stRight], FConfig.QtySide[stRight], false );
  FOrderTablets[stRight].ColVisibles[ocOrder] :=
    FConfig.VisibleOrder[stRight] ;
  FOrderTablets[stRight].ColVisibles[ocIV] :=
    FConfig.VisibleIV[stRight] ;

  if FConfig.VisibleOrder[stLeft] = true then
  begin
    GridOrderQtyLeft.Visible := true ;
    StaticExitLeft.Visible := true ;
    GridQtyLeft.Visible := true ;
    ShapeLeft.Visible := true ;
  end
  else
  begin
    GridOrderQtyLeft.Visible := false ;
    StaticExitLeft.Visible := false ;
    GridQtyLeft.Visible := false ;
    ShapeLeft.Visible := false ;
  end;
  if FConfig.VisibleOrder[stRight] = true then
  begin
    GridOrderQtyRight.Visible := true ;
    StaticExitRight.Visible := true ;
    GridQtyRight.Visible := true ;
    ShapeRight.Visible := true ;
  end
  else
  begin
    GridOrderQtyRight.Visible := false ;
    StaticExitRight.Visible := false ;
    GridQtyRight.Visible := false ;
    ShapeRight.Visible := false ;
  end;

  // �����ֹ� ����
  if FOrderTablets[stLeft] <> nil then
    iLWidth := FOrderTablets[stLeft].TabletWidth
  else
    iLWidth := PAINT_WIDTH ;
  //
  if FOrderTablets[stRight] <> nil then
    iRWidth := FOrderTablets[stRight].TabletWidth
  else
    iLWidth := PAINT_WIDTH  ;
  //
  iWidth := PanelLeft.Width + PanelRight.Width + iLWidth +   iRWidth + 8 ;
  Constraints.MaxWidth := iWidth ;
  Constraints.MaxWidth := iWidth ;
  Width := iWidth ;
  PanelLeftSymbol.Width := iLWidth  ;
  PanelRightSymbol.Width := iRWidth  ;
  //
  if( ( iLWidth + iLWidth ) < ( PAINT_WIDTH* 2 )  ) then
  begin
    ComboAccount.Width := COMBO_MIN;
    ButtonConfig.Left  := CONFIG_BTN_LEFT_MIN   ;
    BtnRightPanel.Left :=  RIGHT_PANEL_MIN ;
  end
  else
  begin
    ComboAccount.Width := COMBO_MAX;
    ButtonConfig.Left  := CONFIG_BTN_LEFT_MAX ;
    BtnRightPanel.Left :=  RIGHT_PANEL_MAX;
  end;


  if bReset = true then
  begin

  // ���� �����ߴ� ���� �ٸ����� ������ ���� �����Ѱſ� ���������� ��
  // ( ==> �ֹ� ����, ��Ÿ ���� ���� �޾ƿ;� �Ǳ� ������... )
  // 2007.09.22
  if( FConfig.PriceOrderby[stLeft] = poAuto ) then
  begin
    FOrderTablets[stLeft].SetArea(PaintTabletLeft);
    SetSymbol(stLeft, FSymbols[stLeft]) ;
  end
  else
    begin
      if FOrderTablets[stLeft].PriceOrderby = FPrevOrderBy[stLeft] then
        FOrderTablets[stLeft].SetArea(PaintTabletLeft)
      else
      begin
        FOrderTablets[stLeft].SetArea(PaintTabletLeft);
        SetSymbol(stLeft, FSymbols[stLeft]);
      end ;

    end ;

  // -- Right
  if( FConfig.PriceOrderby[stRight] = poAuto ) then
  begin
    FOrderTablets[stRight].SetArea(PaintTabletRight);
    SetSymbol(stRight, FSymbols[stRight]) ;
  end
  else
  begin
    if FOrderTablets[stRight].PriceOrderby = FPrevOrderBy[stRight] then
      FOrderTablets[stRight].SetArea(PaintTabletRight)
    else
    begin
      FOrderTablets[stRight].SetArea(PaintTabletRight);
      SetSymbol(stRight, FSymbols[stRight]);
    end;
  end ;


  end ;
  


{

      // �����ܷ�
      // FOrderTablet.VisibleQT := FConfig.VisibleQT;
      // �ڵ���ũ��
      // FOrderTablet.AutoScroll := FConfig.AutoScroll;

  // mouse point
  FOrderTablets[stLeft].MouseTrace := FConfig.MouseTrace ;
  FOrderTablets[stRight].MouseTrace := FConfig.MouseTrace ;

  // Underlying Combo
  PanelUnders.Visible := FConfig.VisibleUnder;
  if PanelUnders.Visible then
  begin
    PanelUnders.Height := 24 ;
    PanelSymbols.Height := 73 ;
  end
  else
  begin
    PanelUnders.Height := 0;
    PanelSymbols.Height := 49 ;
  end ;

  // Ticks
  PaintTicksLeft.Visible := FConfig.VisibleTicks;
  FTickPainters[stLeft].RowCount := FConfig.TickCnt ;
  PaintTicksRight.Visible := FConfig.VisibleTicks;
  FTickPainters[stRight].RowCount := FConfig.TickCnt ;
  //
  FTickPainters[stLeft].UseFilter := FConfig.FillFilter;
  FTickPainters[stLeft].FillQty := FConfig.FillCnt ;
  FTickPainters[stRight].UseFilter := FConfig.FillFilter;
  FTickPainters[stRight].FillQty := FConfig.FillCnt ;
     

      // Zapr (�ɼ�������)
      // GridZapr.Visible := FConfig.VisibleZapr;
      // GridZapr.Top := PanelTPosition.Height;

      // min/max
      // MinPriceProc(FZaprService);
      // MaxPriceProc(FZaprService);

      // OHL/Kospi200
      // GridOHL.Visible := FConfig.VisibleOHL;
      // GridOHL.Top := PanelTPosition.Height;

      // apply 'ShowEvalPL'
      // SetAccountInfo;
      // SetPositionInfo;

  // order right button
  FOrderTablets[stLeft].OrderRightButton :=  FConfig.OrderRightButton ;
  FOrderTablets[stRight].OrderRightButton :=  FConfig.OrderRightButton ;

  // Tablet
  FOrderTablets[stLeft].RefreshColumns(
    FConfig.OrderLeft[stLeft] , false,
    FConfig.QtyMerge[stLeft],  FConfig.QtySide[stLeft], false );
  FOrderTablets[stLeft].ColVisibles[ocOrder] :=
    FConfig.VisibleOrder[stLeft] ;
  FOrderTablets[stRight].RefreshColumns(
    FConfig.OrderLeft[stRight] , false,
    FConfig.QtyMerge[stRight], FConfig.QtySide[stRight], false );
  FOrderTablets[stRight].ColVisibles[ocOrder] :=
    FConfig.VisibleOrder[stRight] ;

  if FConfig.VisibleOrder[stLeft] = true then
  begin
    GridOrderQtyLeft.Visible := true ;
    StaticExitLeft.Visible := true ;
    GridQtyLeft.Visible := true ;
  end
  else
  begin
    GridOrderQtyLeft.Visible := false ;
    StaticExitLeft.Visible := false ;
    GridQtyLeft.Visible := false ;
  end;
  if FConfig.VisibleOrder[stRight] = true then
  begin
    GridOrderQtyRight.Visible := true ;
    StaticExitRight.Visible := true ;
    GridQtyRight.Visible := true ;
  end
  else
  begin
    GridOrderQtyRight.Visible := false ;
    StaticExitRight.Visible := false ;
    GridQtyRight.Visible := false ;
  end;

  // �����ֹ� ����
  if FOrderTablets[stLeft] <> nil then
    iLWidth := FOrderTablets[stLeft].TabletWidth
  else
    iLWidth := PAINT_WIDTH ;
  //
  if FOrderTablets[stRight] <> nil then
    iRWidth := FOrderTablets[stRight].TabletWidth
  else
    iRWidth := PAINT_WIDTH ;
  //
  iWidth := PanelLeft.Width + PanelRight.Width + iLWidth +   iRWidth + 8 ;
  Constraints.MaxWidth := iWidth ;
  Constraints.MaxWidth := iWidth ;
  Width := iWidth ;
  PanelLeftSymbol.Width := iLWidth  ;
  PanelRightSymbol.Width := iRWidth  ;
}


end;

procedure TDoubleOrderForm.SetPositionInfo(aSide : TSideType);
var
  aFar, aNear : TPositionItem;
  iCurQty : Integer;
  dAvgPrice, dEvalPL : Double;
  
begin
  if FPositions[aSide] = nil then Exit;
  
  iCurQty := 0;
  dAvgPrice := 0;
  dEvalPL := 0;
  
  // ��������
  if FSymbols[aSide].IsCombination then
  begin
    aFar  := gTrade.PositionStore.FindPosition(FAccount, FSymbols[aSide].Farther);
    aNear := gTrade.PositionStore.FindPosition(FAccount, FSymbols[aSide].Nearest);

    if (aFar <> nil) and (aNear <> nil) then
    begin
      if aFar.CurQty * aNear.CurQty < 0 then      // �ٿ����� �������� ��ȣ�� �ٸ���
      begin
        // �ܷ�
        iCurQty := Min(Abs(aFar.CurQty), Abs(aNear.CurQty));   // ���밪�� ������
        if aFar.CurQty < 0 then
          iCurQty := iCurQty * (-1) ;       // ��ȣ�� ������

        // ��մܰ�   : ������ ��մܰ� - �ٿ��� ��մܰ�
        // �򰡼���   : ( �������� ���� ���簡 - ��մܰ� ) * �ܷ� * PointValue
        if gUseB then
        begin
          dAvgPrice := aFar.AvgPriceB - aNear.AvgPriceB ;
          dEvalPL := (FSymbols[aSide].C - dAvgPrice) * iCurQty *
              PointValues[FSymbols[aSide].UnderlyingType,
                FSymbols[aSide].DerivativeType] / 1000 ;

        end else
        begin
          dAvgPrice := aFar.AvgPrice - aNear.AvgPrice ;
          dEvalPL := (FSymbols[aSide].C - dAvgPrice) * iCurQty *
              PointValues[FSymbols[aSide].UnderlyingType,
                FSymbols[aSide].DerivativeType] / 1000 ;
        end;
      end;
    end;
  end else
  // �Ϲ� ����
  begin
    iCurQty := FPositions[aSide].CurQty;

    if gUseB then
    begin
      dAvgPrice := FPositions[aSide].AvgPriceB;
      dEvalPL := FPositions[aSide].EvalPLB/1000;
    end else
    begin
      dAvgPrice := FPositions[aSide].AvgPrice;
      dEvalPL :=  FPositions[aSide].EvalPL/1000;
    end;
  end;

  // �����ǰ� ��մܰ�, �򰡼��� dEvalPL
  FOrderTablets[aSide].OpenPosition := iCurQty; //
  FOrderTablets[aSide].AvgPrice := dAvgPrice; //
  FOrderTablets[aSide].EvalPL := dEvalPL; //

end;

procedure TDoubleOrderForm.SetAccountInfo;
var
  aDailyPL, aFee, aNetPL : Double;
begin

  if (FAccount = nil) then
  begin
    StatusInfo.Panels[3].Text := '';
    StatusInfo.Panels[5].Text := '';
    StatusInfo.Panels[7].Text := '';
  end else
  begin
    if gUseB then
      aDailyPL := FAccount.DailyPLB[dtFutures]+FAccount.DailyPLB[dtOptions]
    else
      aDailyPL := FAccount.DailyPL[dtFutures]+FAccount.DailyPL[dtOptions];
    //
    aFee := FAccount.Fees[utKospi200,dtFutures] + FAccount.Fees[utKospi200,dtOptions];
    aNetPL := aDailyPL-aFee;

    StatusInfo.Panels[3].Text := IntToStrComma(Round(aDailyPL/1000));
    StatusInfo.Panels[5].Text := IntToStrComma(Round(aFee/1000));
    StatusInfo.Panels[7].Text := IntToStrComma(Round(aNetPL/1000));
  end;

  // ���ϼ���
  GridInfo.Cells[1, 10] := IntToStrComma(Round(aDailyPL/1000));

  // ����������
  GridInfo.Cells[1, 11] := IntToStrComma(Round(aFee/1000));

  // 
  UpdateOrderLimits(stLeft);
  UpdateOrderLimits(stRight);
end;




// ----- Method Pointer ----- //

procedure TDoubleOrderForm.ReqChanged(Sender: TObject);
var
  aReq : TOrderReqItem;
begin

  if Sender = nil then Exit;
  //
  aReq := Sender as TOrderReqItem;

  //
  FOrderTablets[stLeft].DoOrderReq(aReq, False);
  FOrderTablets[stRight].DoOrderReq(aReq, False);

  StatusInfo.Panels[1].Text := IntToStr(FOrderHandler.WaitCount);

  if FOrderHandler.WaitCount = 0 then
    FOrderHandler.Clear;
  
end;

// ----- Qty ----- //

procedure TDoubleOrderForm.SetOrderQty(stQty: String; bRefresh: Boolean;
    aSide : TSideType );
var
  bMode : Boolean ;
  aOrderGrid : TStringGrid ;
begin

  if aSide= stLeft then
    aOrderGrid := GridOrderQtyLeft
  else
    aOrderGrid := GridOrderQtyRight;
  //
  bMode := false;

  // Refresh �� true�϶�
  // �Ǵ� Refresh�� false �̸� ������ ���� ���ο� ���� Ʋ����
  // Refresh���ش�.

  if bRefresh = true then
    bMode := true
  else
    if CompareStr ( trim(stQty) , trim(aOrderGrid.Cells[0,0])) <> 0  then
      bMode := true;
  //

  if bMode = true then
  begin
      FQtyState[aSide] := qsSelected ;     // ���� ���õǾ��� �� (Highlight�� state)

      FDefQty[aSide] := Abs( StrToIntDef(stQty , 0) );         // �ֹ����� Set
      aOrderGrid.Cells[0,0] := IntToStr(FDefQty[aSide]);     // �ֹ����� ȭ�鿡 Set

      if FQtyHighLightTimer[aSide] = nil then exit;            // Highlight

      if FQtyHighLightTimer[aSide].Enabled = true then
        FQtyHighLightTimer[aSide].Enabled := false;

      FQtyHighLightTimer[aSide].Enabled := true;

  end;

  {
  if FKeyOrderMapItem <> nil then
  begin
    //FKeyOrderMapItem.SymbolAQty := FDefQty;
    //FKeyOrderMapItem.SymbolBQty := FDefQty;
  end;
  }

end;

procedure TDoubleOrderForm.SetExitEnable(bClearOrderFlag: Boolean;
  aSide: TSideType);
var
  aStaticExit : TStaticText ;
begin
  if aSide = stLeft then
    aStaticExit := StaticExitLeft
  else 
    aStaticExit := StaticExitRight ;

  aStaticExit.Caption := IntToStr(FClearOrderQty[aSide]);       // û�� ��ư ����
  FClearOrder[aSide] :=  bClearOrderFlag ;           // û�� ���� flag

  //
  if FClearOrder[aSide] = true then
    aStaticExit.BorderStyle := sbsSunken       // û���ֹ��϶� ������ ����
  else
    aStaticExit.BorderStyle := sbsNone;        // û���ֹ� �ƴҶ� ����

  // 
  if ( FClearOrderQty[aSide] >0 ) and ( FOrderType[aSide] = ptLong) then
    aStaticExit.Color := $FF9090
  else if  ( FClearOrderQty[aSide] >0 ) and ( FOrderType[aSide] = ptShort) then
    aStaticExit.Color :=  $9090FF
  else if FClearOrderQty[aSide] = 0 then
    aStaticExit.Color := clGray ;

{  LONG_COLOR = $E4E2FC;
  SHORT_COLOR = $F5E2DA;}

end;

procedure TDoubleOrderForm.HighLightTimerLeft(Sender: TObject);
begin
  if FClearOrder[stLeft] = true then
    begin
      if FOrderType[stLeft] = ptLong then           // û���ֹ� - �ŵ�
        FQtyState[stLeft] := qsLong
      else
        FQtyState[stLeft] := qsShort                  // û���ֹ� - �ż�
    end
  else
    FQtyState[stLeft] := qsData;                    // û���ֹ� �ƴҶ� ( ���� )

  // ����� state�� �ѹ��� �׷���
  GridOrderQtyLeft.Cells[0,0] := GridOrderQtyLeft.Cells[0,0];
  // Timer Stop
  FQtyHighLightTimer[stLeft].Enabled := false;
end;

procedure TDoubleOrderForm.HighLightTimerRight(Sender: TObject);
begin
  if FClearOrder[stRight] = true then
    begin
      if FOrderType[stRight] = ptLong then           // û���ֹ� - �ŵ�
        FQtyState[stRight] := qsLong
      else
        FQtyState[stRight] := qsShort                  // û���ֹ� - �ż�
    end
  else
    FQtyState[stRight] := qsData;                    // û���ֹ� �ƴҶ� ( ���� )

  // ����� state�� �ѹ��� �׷���
  GridOrderQtyRight.Cells[0,0] := GridOrderQtyRight.Cells[0,0];
  // Timer Stop
  FQtyHighLightTimer[stRight].Enabled := false;
end;


procedure TDoubleOrderForm.UpdateOrderLimits(aSide: TSideType);
var
  iLongCurQty, iShortCurQty: Integer;
begin
  if (FAccount = nil) or (FSymbols[aSide] = nil) then Exit;

  if not FSymbols[aSide].IsCombination then
  begin

    iShortCurQty:=
      gTrade.PositionStore.GetMaxClearableQty(FAccount, FSymbols[aSide], ptShort);
    iLongCurQty:=
      gTrade.PositionStore.GetMaxClearableQty(FAccount, FSymbols[aSide], ptLong);
    //
    FClearOrderQty[aSide]:= iShortCurQty + iLongCurQty;        // û����� Set

    if iLongCurQty > 0 then   // ȯ��
      FOrderType[aSide] := ptShort
    else if iShortCurQty > 0 then    // ����
      FOrderType[aSide] := ptLong ;

    //
    if  FClearOrder[aSide] = true  then   //  û���ֹ� ���õ� ����
    begin
      if FClearOrderQty[aSide] = 0 then   // ������ 0�̸�
        begin
          // û���ֹ� Ǯ����
          SetExitEnable(FClearOrder[aSide], aSide);
          //  �ֹ����� 0
          SetOrderQty('0' , false, aSide );
        end
      else      // ������ 0�� �ƴϸ�
        begin
          // û���ֹ� ����
          SetExitEnable( true, aSide );
          // �ֹ������� û���������
          SetOrderQty( IntToStr(FClearOrderQty[aSide]) , false, aSide );
        end ;
    end
    else    // û���ֹ� �������� ���� ����
      SetExitEnable( false, aSide );  // û���ֹ� Ǯ�� ( û�� ��ư update ���� ȣ��)

  end
  else
  begin
    FClearOrderQty[aSide] := 0 ;
    SetExitEnable(false, aSide );
  end;

end;


// ----- EventHandler ----- //

// ----- 1. ComboBox ----- //

procedure TDoubleOrderForm.ComboUndersChange(Sender: TObject);
var
  aSymbol : TSymbol;
  aList: TStrings;
begin
  aSymbol:= ComboUnders.Items.Objects[ComboUnders.ItemIndex] as TSymbol;
  gPrice.SymbolStore.PopulateMonths(ComboOptions.Items, aSymbol, dtOptions);
  aList:= TStringList.Create;
  aList.Add(' ');
  //
  //
  if aSymbol.UnderlyingType = utStock then  // �ֽĿɼ�
  begin
    ComboFutures.Items:= aList;
    ComboFutures.Enabled:= False;
    LabelFut.Enabled:= False;
    EditFutures.Enabled:= False;
    EditFutures.Caption:= '';
  end
  else
  begin
    gPrice.SymbolStore.PopulateMonths(ComboFutures.Items, aSymbol , dtFutures);
    ComboFutures.Enabled:= True;
    LabelFut.Enabled:= True;
    EditFutures.Enabled:= True;
  end;
  //
  if ComboAccount.Items.Count <> 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;
  if ComboFutures.Items.Count <> 0 then
  begin
    ComboFutures.ItemIndex:= 0;
    ComboFuturesChange(ComboFutures);
  end;
  if ComboOptions.Items.Count <> 0 then
  begin
    ComboOptions.ItemIndex:= 0;
    ComboOptionsChange(ComboOptions);
  end;
end;


procedure TDoubleOrderForm.ComboAccountChange(Sender: TObject);
begin
  if ComboAccount.ItemIndex = -1 then
  begin
    FAccount := nil;
    Exit;
  end;

  //-- ���� ����
  FAccount := ComboAccount.Items.Objects[ComboAccount.ItemIndex] as TAccount;
  
  // -- �ʱ�ȭ
  FPositions[stLeft] := nil;
  FPositions[stRight] := nil;
  //
  EditFutures.Caption:= '0';
  //-- ����/������
  SetAccountInfo;
  
  //  
  FAccountSynchronizing := True;
  SetSymbol(stLeft,   FSymbols[stLeft]);
  SetSymbol(stRight,  FSymbols[stRight]);
  FAccountSynchronizing := False; 
  //
  if ButtonSync.Down and (FAccount <> nil) then
    gWin.Synchronize(Self, [FAccount]);

end;

procedure TDoubleOrderForm.ComboFuturesChange(Sender: TObject);
var
  i : Integer;
  aMonth : TFutureMonthlyItem;
  aFindPosition: TPositionItem;
  aSide : TSideType ; 
begin

  if ComboFutures.ItemIndex < 0 then Exit;
  //Combo�� ������ �پ� ����.
  aMonth:=  TFutureMonthlyItem(ComboFutures.Items.Objects[ComboFutures.ItemIndex]);
  if aMonth = nil then Exit;
  // if FPositions[stLeft] <> nil then
  // begin
    aFindPosition := gTrade.PositionStore.FindPosition(FAccount, aMonth.Symbol);
    if aFindPosition <> nil then
      EditFutures.Caption:= IntToStr(aFindPosition.CurQty)
    else
      EditFutures.Caption:= '0';
  // end;
  //
end;

procedure TDoubleOrderForm.ComboOptionsChange(Sender: TObject);
var
  i : Integer;
  aMonth : TOptionMonthlyItem;
begin
  // WM_RBUTTONDBLCLK
  if ComboOptions.ItemIndex < 0 then Exit;

  aMonth := TOptionMonthlyItem(ComboOptions.Items.Objects[ComboOptions.ItemIndex]);
  if aMonth = nil then Exit;

  MakeGridTPosition(GridOptions, aMonth, True);
end;



// ----- 2. Edit ----- //

procedure TDoubleOrderForm.EditFuturesDblClick(Sender: TObject);
var
  aSymbol : TSymbol ; 
begin

  // WM_RBUTTONDBLCLK
  aSymbol := TFutureMonthlyItem(ComboFutures.Items.Objects[ComboFutures.ItemIndex]).Symbol ;
  //
  SetSymbol(FFuturesSelectedSide, aSymbol);

  if ( FFuturesSelectedSide = stRight ) and ( ButtonSync.Down )
      and not(FAccountSynchronizing) and (aSymbol <> nil) then
    gWin.Synchronize(Self, [aSymbol]);

end;

procedure TDoubleOrderForm.EditFuturesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  aSymbol : TSymbol ;
begin
  if Button = mbLeft then
    FFuturesSelectedSide := stLeft
  else if Button = mbRight then
    FFuturesSelectedSide := stRight ;
  //
  aSymbol :=
    TFutureMonthlyItem(ComboFutures.Items.Objects[ComboFutures.ItemIndex]).Symbol ;
  SetSymbol(FFuturesSelectedSide, aSymbol);
  //

  if ( FFuturesSelectedSide = stRight ) and ( ButtonSync.Down )
      and not(FAccountSynchronizing) and (aSymbol <> nil) then
    gWin.Synchronize(Self, [aSymbol]);

end;

procedure TDoubleOrderForm.StaticExitLeftClick(Sender: TObject);
begin
  if ( StaticExitLeft.Caption = '') then Exit;
  //
  StaticExitLeft.SetFocus;
  if FConfig.EnableClearOrder then
    SetExitEnable( not FClearOrder[stLeft], stLeft );
  //  û������� �ֹ�����
  SetOrderQty( IntToStr(FClearOrderQty[stLeft]) , true, stLeft );
end;

procedure TDoubleOrderForm.StaticExitRightClick(Sender: TObject);
begin
  if ( StaticExitRight.Caption = '') then Exit;
  // 
  StaticExitRight.SetFocus;
  if FConfig.EnableClearOrder then
    SetExitEnable( not FClearOrder[stRight], stRight );
  //  û������� �ֹ�����
  SetOrderQty( IntToStr(FClearOrderQty[stRight]) , true , stRight);
end;

// ----- 3. Grid ----- //

procedure TDoubleOrderForm.GridOptionsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aFindPosition : TPositionItem;
begin

  with GridOptions.Canvas do
  begin
    Font.Name := GridOptions.Font.Name;
    Font.Size := GridOptions.Font.Size;
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
    if GridOptions.Cells[aCol, aRow] <> '' then
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end else
    begin
      Brush.Color := NODATA_COLOR;
    end;
    //-- background
    FillRect(Rect);
    //-- text
    stText := GridOptions.Cells[aCol, aRow];

    // 2002.09.30 Add Y.H.W
    aFindPosition :=
      gTrade.PositionStore.FindPosition(FAccount, TSymbol(GridOptions.Objects[aCol,aRow]));

    if aFindPosition <> nil then
      if (aFindPosition.OrderQtys[ptLong] + aFindPosition.OrderQtys[ptShort]) >0 then
        begin
          Brush.Color := $00FFE7B3 ;
          Font.Color := clBlack;
        end;
    // Add End

    //
    if stText <> '' then
    begin
      //-- calc position

      aSize := TextExtent(stText);
      iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - aSize.cx) div 2;
      //-- put text
      TextRect(Rect, iX, iY, stText);
    end;
  end;
  
end;

procedure TDoubleOrderForm.GridOptionsMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;

procedure TDoubleOrderForm.GridOptionsMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;

procedure TDoubleOrderForm.GridOptionsDblClick(Sender: TObject);
begin
  SetSymbol(FOptionsSelectedSide, FSelectedOptions);
  //
  if ( FOptionsSelectedSide = stRight ) and ( ButtonSync.Down )
      and not(FAccountSynchronizing) and (FSelectedOptions <> nil) then
    gWin.Synchronize(Self, [FSelectedOptions]);

end;

procedure TDoubleOrderForm.GridOptionsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iCol, iRow : Integer;
  bSelected : Boolean;
begin
  bSelected := True;
  GridOptions.MouseToCell(X,Y, iCol, iRow);

  if (iCol = -1) or (iRow = -1) then Exit;

  // �۾��ڵ� : UD_HW_002
  // �۾��� : 2007.01.06
  // bug fix : ���� and -> or 
  // ù��° ���̰ų�, ��簡 ǥ�õǴ� �κ��� ���õ��� �ʵ��� ��
  // TSymbol �� �ƴ� ��� ���õ��� �ʵ��� �� 
  if (iCol = 1) or (iRow = 0) then exit;
  if not( GridOptions.Objects[iCol,iRow] is TSymbol ) then exit ;
  
  GridOptions.Col := iCol;
  GridOptions.Row := iRow;

  // -- 1. Side
  if Button = mbLeft then
    FOptionsSelectedSide := stLeft
  else if Button = mbRight then
    FOptionsSelectedSide := stRight ;

  // �۾��ڵ� : UD_HW_001
  // �۾��� : 2006.12.03
  // GridOptionsSelectCell���� �����ߴ� ����� GridOptionsMouseDown���� ����
  // -- 2. Symbol Item
  FSelectedOptions := TSymbol(GridOptions.Objects[iCol,iRow]);
  if FSelectedOptions = nil then exit ;

  // -- 3. SetSymbol 
  SetSymbol(FOptionsSelectedSide, FSelectedOptions);

  //
  if ( FOptionsSelectedSide = stRight ) and ( ButtonSync.Down )
      and not(FAccountSynchronizing) and (FSelectedOptions <> nil) then
    gWin.Synchronize(Self, [FSelectedOptions]);

end;

procedure TDoubleOrderForm.GridOptionsSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  aGrid: TStringGrid;
begin

  // �۾��ڵ� : UD_HW_001
  // �۾��� : 2006.12.03
  // �� Procedure���� ���ߴ� action�� GridOptionsMouseDown���� �Ѳ����� ����
  {
  aGrid:= Sender as TStringGrid;
  if (aCol <> 1) and (aRow <> 0) then
    CanSelect := True
  else
    CanSelect := False;
  //

  if CanSelect then
  begin
    FSelectedOptions := TSymbol(aGrid.Objects[aCol,aRow]);
  end ;
  }
end;

procedure TDoubleOrderForm.GridQtyLeftDblClick(Sender: TObject);
var
  aDlg : TDoubleOrderConfigQtyDialog;
  i, j  : Integer;
begin

  aDlg := TDoubleOrderConfigQtyDialog.Create(nil);

  try

    GridQtyLeft.ColCount := QTY_COL_CNT ;
    GridQtyLeft.RowCount := QTY_ROW_CNT ;

    for i:= 0 to GridQtyLeft.ColCount do
      for j:= 0 to GridQtyLeft.RowCount do
        aDlg.Qty[i,j] := StrToIntDef(GridQtyLeft.Cells[i,j], 0);
    //

    if aDlg.ShowModal = mrOK then
    begin
      
      for i:= 0 to GridQtyLeft.ColCount - 1 do
        for j:= 0 to GridQtyLeft.RowCount - 1 do
          GridQtyLeft.Cells[i, j] := IntToStr(aDlg.Qty[i,j]);
      // 
    end;

  finally
    aDlg.Free;
  end;
end;

procedure TDoubleOrderForm.GridQtyRightDblClick(Sender: TObject);
var
  aDlg : TDoubleOrderConfigQtyDialog;
  i, j  : Integer;
begin

  aDlg := TDoubleOrderConfigQtyDialog.Create(nil);

  try

    GridQtyRight.ColCount :=  QTY_COL_CNT ;
    GridQtyRight.RowCount :=  QTY_ROW_CNT ;

    for i:= 0 to GridQtyRight.ColCount - 1 do
      for j:= 0 to GridQtyRight.RowCount - 1 do
        aDlg.Qty[i,j] := StrToIntDef(GridQtyRight.Cells[i,j], 0);
    //

    if aDlg.ShowModal = mrOK then
    begin

      for i:= 0 to GridQtyRight.ColCount - 1 do
        for j:= 0 to GridQtyRight.RowCount - 1 do 
          GridQtyRight.Cells[i, j] := IntToStr(aDlg.Qty[i,j]);
      //

    end;
    
  finally
    aDlg.Free;
  end;
end;

procedure TDoubleOrderForm.GridQtyLeftClick(Sender: TObject);
begin
  //û����� Ǯ����
  SetExitEnable( false , stLeft);
  // Ŭ���� ����
  SetOrderQty( GridQtyLeft.Cells[GridQtyLeft.Col ,GridQtyLeft.Row ]
    , true, stLeft );
end;

procedure TDoubleOrderForm.GridQtyRightClick(Sender: TObject);
begin
  //û����� Ǯ����
  SetExitEnable( false , stRight);
  // Ŭ���� ����
  SetOrderQty( GridQtyRight.Cells[GridQtyRight.Col ,GridQtyRight.Row ]
    , true, stRight );
end;

procedure TDoubleOrderForm.GridQtyLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //
  if Button = mbRight then
  begin
    GridQtyLeftDblClick(GridQtyLeft);
  end ;
end;

procedure TDoubleOrderForm.GridQtyRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    GridQtyRightDblClick(GridQtyRight);
  end ;
end;

procedure TDoubleOrderForm.GridQtyDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iLeft, iTop : Integer;
  stValue : String;
  aCanvas : TCanvas;
  aSize : TSize;
  aGrid : TStringGrid;
begin

  aGrid:= (Sender as TStringGrid);
  aCanvas := aGrid.Canvas;
  stValue := aGrid.Cells[aCol, aRow];
  //-- color
  if gdFixed in State then
  begin
    aCanvas.Font.Color := clBlue;
    aCanvas.Brush.Color := clYellow;
  end
  else
  if gdSelected in State then
  begin
    aCanvas.Font.Color := clBlack;
    aCanvas.Brush.Color := clWhite;
  end
  else
  begin
    aCanvas.Font.Color := clBlack;
    aCanvas.Brush.Color := clWhite;
  end;

  //-- bg
  aCanvas.FillRect(Rect);
  //-- draw
  aSize := aCanvas.TextExtent(stValue);
  iLeft := (Rect.Right-Rect.Left-aSize.cx) div 2 + Rect.Left;
  iTop := (Rect.Bottom-Rect.Top-aSize.cy) div 2 + Rect.Top;
  aCanvas.TextRect(Rect, iLeft, iTop, stValue);
end;


procedure TDoubleOrderForm.GridQtyExit(Sender: TObject);
var
  aGrid: TStringGrid;
  iRow, iCol: Integer;
begin
  aGrid:= (Sender as TStringGrid);

  for iCol:=0 to aGrid.ColCount-1 do
    for iRow:=0 to aGrid.RowCount-1 do
      aGrid.Cells[iCol, iRow]:= IntToStr(StrToIntDef(Trim(aGrid.Cells[iCol,iRow]),0));
end;

procedure TDoubleOrderForm.GridQtyKeyPress(Sender: TObject; var Key: Char);
var
  aGrid: TStringGrid;
begin 
  aGrid:= (Sender as TStringGrid);
  if ((Key < '0') or (Key > '9')) and (Key <> #13)  then Key:=#0;
end;

procedure TDoubleOrderForm.GridQtyMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TDoubleOrderForm.GridQtyMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TDoubleOrderForm.GridQtyLeftSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  iNum : Integer;
  aGrid : TStringGrid;
begin

  if FClearOrder[stLeft] = False then
  begin
    aGrid:= (Sender as TStringGrid);
    aGrid.Cells[aCol, aRow] := Trim(aGrid.Cells[aCol, aRow]);
    iNum := StrToIntDef(GridQtyLeft.Cells[aCol, aRow], 0);
    SetOrderQty( IntToStr(iNum) , true, stLeft );         // GridQty ���õ� ��
  end;
  CanSelect := True;

end;

procedure TDoubleOrderForm.GridQtyRightSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  iNum : Integer;
  aGrid : TStringGrid;
begin

  if FClearOrder[stRight] = False then
  begin
    aGrid:= (Sender as TStringGrid);
    aGrid.Cells[aCol, aRow] := Trim(aGrid.Cells[aCol, aRow]);
    iNum := StrToIntDef(GridQtyRight.Cells[aCol, aRow], 0);
    SetOrderQty( IntToStr(iNum) , true , stRight );         // GridQty ���õ� ��
  end;
  CanSelect := True;

end;

procedure TDoubleOrderForm.GridOrderQtyLeftClick(Sender: TObject);
begin
  SetExitEnable(  false, stLeft );
end;

procedure TDoubleOrderForm.GridOrderQtyRightClick(Sender: TObject);
begin
  SetExitEnable(  false, stRight );
end;



procedure TDoubleOrderForm.GridOrderQtyExit(Sender: TObject);
var
  aGrid: TStringGrid;
  iRow, iCol: Integer;
begin
  aGrid:= (Sender as TStringGrid);
  for iCol:=0 to aGrid.ColCount-1 do
    for iRow:=0 to aGrid.RowCount-1 do
      aGrid.Cells[iCol, iRow]:= IntToStr(StrToIntDef(Trim(aGrid.Cells[iCol,iRow]),0));
end;

procedure TDoubleOrderForm.GridOrderQtyKeyPress(Sender: TObject;
  var Key: Char);
var
  aGrid: TStringGrid;
begin
  aGrid:= (Sender as TStringGrid);
  if ((Key < '0') or (Key > '9')) and (Key <> #13)  then Key:=#0;
end;

procedure TDoubleOrderForm.GridOrderQtyMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TDoubleOrderForm.GridOrderQtyMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TDoubleOrderForm.GridOrderQtyLeftSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SetExitEnable(  false, stLeft );
end;

procedure TDoubleOrderForm.GridOrderQtyRightSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SetExitEnable(  false, stRight );
end;

procedure TDoubleOrderForm.GridOrderQtyLeftSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: String);
var
  iNum : Integer;
begin

  // ����
  iNum := StrToIntDef(GridOrderQtyLeft.Cells[aCol, aRow], 0);
  // û����� Ǯ����
  SetExitEnable( false, stLeft );
  //
  if iNum > 0 then
    FDefQty[stLeft] := iNum
  else
    FDefQty[stLeft] := 0;
  //
  gWin.ModifyWorkspace;
end;

procedure TDoubleOrderForm.GridOrderQtyRightSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: String);
var
  iNum : Integer;
begin
  // ����
  iNum := StrToIntDef(GridOrderQtyRight.Cells[aCol, aRow], 0);
  // û����� Ǯ����
  SetExitEnable( false, stRight ) ;
  //
  if iNum > 0 then
    FDefQty[stRight] := iNum
  else
    FDefQty[stRight] := 0;
  //
  gWin.ModifyWorkspace;
end;

procedure TDoubleOrderForm.GridOrderQtyLeftDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iLeft, iTop : Integer;
  stValue : String;
  aCanvas : TCanvas;
  aSize : TSize;
  aGrid : TStringGrid;
begin

  aGrid:= (Sender as TStringGrid);
  aCanvas := GridOrderQtyLeft.Canvas;
  stValue := GridOrderQtyLeft.Cells[aCol, aRow];
  //-- color

  case FQtyState[stLeft] of
    qsSelected :
      begin
        aCanvas.Font.Color := clWhite ;
        aCanvas.Brush.Color := clBlue ;
      end;
    qsLong :
      begin
        if CompareStr(Trim(stValue), '0') = 0  then
        begin
          aCanvas.Font.Color := clBlack;
          aCanvas.Brush.Color := clYellow;
        end else
        begin
          aCanvas.Font.Color := clBlack ;
          aCanvas.Brush.Color := $FF9090 ;
        end;
      end;
    qsShort :
      begin
        if CompareStr(Trim(stValue), '0') = 0 then
        begin
          aCanvas.Font.Color := clBlack;
          aCanvas.Brush.Color := clYellow;
        end else
        begin
          aCanvas.Font.Color := clBlack ;
          aCanvas.Brush.Color := $9090FF  ;
        end;
      end;
    qsData :
      begin
        aCanvas.Font.Color := clBlack ;
        aCanvas.Brush.Color := clWhite ;
      end;
  end;
  
  //-- bg
  aCanvas.FillRect(Rect);
  //-- draw
  aSize := aCanvas.TextExtent(stValue);
  iLeft := (Rect.Right-Rect.Left-aSize.cx) div 2 + Rect.Left;
  iTop := (Rect.Bottom-Rect.Top-aSize.cy) div 2 + Rect.Top;
  aCanvas.TextRect(Rect, iLeft, iTop, stValue);
 
end;

procedure TDoubleOrderForm.GridOrderQtyRightDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iLeft, iTop : Integer;
  stValue : String;
  aCanvas : TCanvas;
  aSize : TSize;
  aGrid : TStringGrid;
begin

  aGrid:= (Sender as TStringGrid);
  aCanvas := GridOrderQtyRight.Canvas;
  stValue := GridOrderQtyRight.Cells[aCol, aRow];
  //-- color

  case FQtyState[stRight] of
    qsSelected :
      begin
        aCanvas.Font.Color := clWhite ;
        aCanvas.Brush.Color := clBlue ;
      end;
    qsLong :
      begin
        if CompareStr(Trim(stValue), '0') = 0  then
        begin
          aCanvas.Font.Color := clBlack;
          aCanvas.Brush.Color := clYellow;
        end else
        begin
          aCanvas.Font.Color := clBlack ;
          aCanvas.Brush.Color := $FF9090 ;
        end;
      end;
    qsShort :
      begin
        if CompareStr(Trim(stValue), '0') = 0 then
        begin
          aCanvas.Font.Color := clBlack;
          aCanvas.Brush.Color := clYellow;
        end else
        begin
          aCanvas.Font.Color := clBlack ;
          aCanvas.Brush.Color := $9090FF  ;
        end;
      end;
    qsData :
      begin
        aCanvas.Font.Color := clBlack ;
        aCanvas.Brush.Color := clWhite ;
      end;
  end;
  
  //-- bg
  aCanvas.FillRect(Rect);
  //-- draw
  aSize := aCanvas.TextExtent(stValue);
  iLeft := (Rect.Right-Rect.Left-aSize.cx) div 2 + Rect.Left;
  iTop := (Rect.Bottom-Rect.Top-aSize.cy) div 2 + Rect.Top;
  aCanvas.TextRect(Rect, iLeft, iTop, stValue);

end;

procedure TDoubleOrderForm.GridInfoDrawCell(Sender: TObject; ACol,
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

    case ACol of
      0 :  // Fixed 
        begin
          Brush.Color := NODATA_COLOR ;
          Font.Color := clBlack;
          aAlignment := taLeftJustify;
        end;
      1 :  // Value 
        begin
          Brush.Color := clWhite ;
          Font.Color := clBlack;
          aAlignment := taRightJustify;
        end;
    end;

    //-- background
    FillRect(Rect);
    //-- text
    if stText = '' then Exit;
    //-- calc position
    aSize := TextExtent(stText);
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    //-- put text
    case aAlignment of
      taLeftJustify :  iX := Rect.Left + 2;
      taCenter :       iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
      taRightJustify : iX := Rect.Left + Rect.Right-Rect.Left - 2 - aSize.cx;
    end;

    TextRect(Rect, iX, iY, stText);
  end;
  
end;



// ----- 4. Button ----- //



procedure TDoubleOrderForm.BtnLeftPanelClick(Sender: TObject);
var
  aRect: TRect;
  iLeft, iWidth : Integer;
begin
  aRect:= BoundsRect;
  if PanelLeft.WIDTH < PANEL_WIDTH then
  begin
    PanelLeft.WIDTH := PANEL_WIDTH ;
    iLeft := aRect.Left - PANEL_WIDTH;
    BtnLeftPanel.Caption:= '>>';
    BtnLeftPanel.Down := false ;
    FVisibleInfo[stLeft] := true ;
  end else
  begin
    PanelLeft.WIDTH := 0 ;
    iLeft := aRect.Left + PANEL_WIDTH;
    BtnLeftPanel.Caption:= '<<';
    BtnLeftPanel.Down := true ;
    FVisibleInfo[stLeft] := false ;
  end;
  Constraints.MaxWidth := 0;
  Constraints.MinWidth := 0;
  aRect.Left := iLeft;
  BoundsRect:= aRect;
  //
  iWidth := aRect.Right - aRect.Left;
  Constraints.MaxWidth := iWidth;
  Constraints.MinWidth := iWidth; 
end;





procedure TDoubleOrderForm.BtnRightPanelClick(Sender: TObject);
var
  aRect: TRect;
  iRight, iWidth : Integer;
begin
  aRect:= BoundsRect;
  if PanelRight.WIDTH < PANEL_WIDTH then
  begin
    PanelRight.WIDTH := PANEL_WIDTH ;
    iRight := aRect.Right + PANEL_WIDTH;
    BtnRightPanel.Caption:= '<<';
    BtnRightPanel.Down := false ;
    FVisibleInfo[stRight] := true ;
  end else
  begin
    PanelRight.WIDTH := 0 ;
    iRight := aRect.Right - PANEL_WIDTH;
    BtnRightPanel.Caption:= '>>';
    BtnRightPanel.Down := True  ; 
    FVisibleInfo[stRight] := false ;
  end;
  Constraints.MaxWidth := 0;
  Constraints.MinWidth := 0;
  aRect.Right := iRight;
  BoundsRect:= aRect;
  //
  iWidth := aRect.Right - aRect.Left;
  Constraints.MaxWidth := iWidth;
  Constraints.MinWidth := iWidth;
end;

procedure TDoubleOrderForm.ButtonConfigClick(Sender: TObject);
var                              

  i: Integer;
  aDlg: TDoubleOrderConfigDialog ;
  iQtyCount : Integer;
  iWidth, iLWidth, iRWidth : Integer ;
begin

  aDlg:= TDoubleOrderConfigDialog.Create(Self);

  FPrevOrderBy[stLeft] :=  FOrderTablets[stLeft].PriceOrderby ;
  FPrevOrderBy[stRight] :=  FOrderTablets[stRight].PriceOrderby ;

  try
    aDlg.Config := FConfig;

    if aDlg.ShowModal = mrOK then
    begin
      FConfig:= aDlg.Config;

      //
      SetConfig(True );

      // modify workspace
      gWin.SetFormDefault(Self);
      gWin.ModifyWorkspace;

    end;
  finally
    aDlg.Free;
  end;

end;

procedure TDoubleOrderForm.ButtonSyncClick(Sender: TObject);
begin
  gWin.ModifyWorkspace; 
end;

// ----- 5. Form ----- //

procedure TDoubleOrderForm.FormCreate(Sender: TObject);
var
  aSymbol: TSymbol;
  aSideType : TSideType ;
  aPositionType : TPositionType ;
begin

  //==========(Wincentral Feedback)===========//
  if gWin.OpenPeer <> nil then
  with gWin.OpenPeer do
  begin
    OnSetData := SetData;
    OnGetPersistence := GetPersistence;
    OnSetPersistence := SetPersistence;
    OnCallWorkForm := CallWorkForm;
    OnSetDefault:= SetDefault;
    OnGetDefault:= GetDefault;

    Pin := ButtonFix;
  end;

  // Variables �ʱ�ȭ 
  FSubscribe[stLeft] := False ;
  FSubscribe[stRight] := False ; 
  FAccountSynchronizing := False;
  FVisibleInfo[stLeft] := true ;
  FVisibleInfo[stRight] := true ;
  FTickCounts[stLeft] := 0;
  FTickCounts[stRight] := 0;
  FLastSynFutures := 0 ;
  

  // FTickPainters 
  FTickPainters[stLeft] := TTickPainter.Create;
  FTickPainters[stLeft].PaintBox := PaintTicksLeft ;
  FTickPainters[stLeft].RowCount := 20 ;
  FTickPainters[stLeft].FillQty := 1 ;

  FTickPainters[stRight] := TTickPainter.Create;
  FTickPainters[stRight].PaintBox := PaintTicksRight ;
  FTickPainters[stRight].RowCount := 20 ;
  FTickPainters[stRight].FillQty := 1 ;

  //jjb
  FTickPainters2[stLeft] := TTickPainter.Create;
  FTickPainters2[stLeft].PaintBox := PaintTicksLeft2 ;
  FTickPainters2[stLeft].RowCount := 20 ;
  FTickPainters2[stLeft].FillQty := 1 ;

  FTickPainters2[stRight] := TTickPainter.Create;
  FTickPainters2[stRight].PaintBox := PaintTicksRight2 ;
  FTickPainters2[stRight].RowCount := 20 ;
  FTickPainters2[stRight].FillQty := 1 ;


  // FQtyHighLightTimer
  FQtyHighLightTimer[stLeft] := TTimer.Create(nil);
  FQtyHighLightTimer[stLeft].Interval := 500;
  FQtyHighLightTimer[stLeft].OnTimer :=  HighLightTimerLeft ;
  FQtyHighLightTimer[stLeft].Enabled := false;
  FQtyHighLightTimer[stRight] := TTimer.Create(nil);
  FQtyHighLightTimer[stRight].Interval := 500;
  FQtyHighLightTimer[stRight].OnTimer :=  HighLightTimerRight ;
  FQtyHighLightTimer[stRight].Enabled := false;

  // OrderHandler
  FOrderHandler := TOrderHandler.Create(gTrade);
  FOrderHandler.OnChanged := ReqChanged;

  // gTrade.Broadcaster
  with gTrade.Broadcaster do
  begin
    Subscribe(OID_Order,[btNew,btUpdate], Self, OrderProc);
    Subscribe(OID_Position,[btNew,btUpdate], Self, PositionProc);
    Subscribe(OID_Account,[btUpdate], Self, AccountProc);
    Subscribe(OID_EVALPL,[btUpdate], Self, PositionProc);  // �򰡼���
  end;

  //-- ȭ���ʱ�ȭ
  // GridQtyLeft, GridQtyRight, GridOptions, GridInfoLeft, GridInfoRight
  // ComboAccount, ComboUnders, ComboSymbol( FSymbols[stLeft], FSymbols[stRight])
  // FDefQty
  InitControls;

  //-- Tablet
  // TOrderTablet Create, ColWidth 
  InitTablet(stLeft, PaintTabletLeft );
  InitTablet(stRight, PaintTabletRight );
  FOrderTablets[stLeft].PopOrders := PopOrdersLeft ;
  FOrderTablets[stRight].PopOrders := PopOrdersRight ;

  // �ΰ� ����
  FZaprServices[stLeft] := TZaprService.Create;
  FZaprServices[stLeft].OnMinPriceChanged := MinPriceProc;
  FZaprServices[stLeft].OnMaxPriceChanged := MaxPriceProc;
  FZaprServices[stRight] := TZaprService.Create;
  FZaprServices[stRight].OnMinPriceChanged := MinPriceProc;
  FZaprServices[stRight].OnMaxPriceChanged := MaxPriceProc;

  // -- ����â  FConfig
  with FConfig do
  begin
    EnableQtyClick := False ;      // ������ ����Ŭ��  ( ��� ���� )

    VisibleUnder := False ;       // �����ڻ�
    OrderRightButton := True ;    // ������ �ֹ�

    VisibleEvalPL := True;
    VisibleOrderAmt := False;
    VisibleOHL := True;
    VisibleTicks[stLeft] := True;
    VisibleTicks[stRight] := True;
    FillFilter[stLeft] := false ;
    FillFilter[stRight] := false ;

    VisibleQT := False ;  // FOrderTablet.EnableQT;
    VisibleZapr := False;
    VisibleOrder[stLeft] := True ;
    VisibleOrder[stRight] := True ;
    //
    TickCnt[stLeft] := FTickPainters[stLeft].RowCount;
    TickCnt[stRight] := FTickPainters2[stLeft].RowCount;
    FillCnt[stLeft] := FTickPainters[stLeft].RowCount;
    FillCnt[stRight] := FTickPainters2[stLeft].RowCount;

    AutoScroll := True ;  // FOrderTablet.AutoScroll;
    //
    EnableEscape := True ;              // ESC
    EnableOneFive := True ;             // 1~5 Ű
    //
    OrderLeft[stLeft] := ptShort ;
    OrderLeft[stRight] := ptShort ;
    PriceOrderby[stLeft] := poAsc ;
    PriceOrderby[stRight] := poAsc ;
    QtyMerge[stLeft] := false ;
    QtyMerge[stRight] := false ;

    // --  ����
    QtyFontColor[ptShort] := '$000000' ;
    QtyFontColor[ptLong] := '$000000' ;
    OrderFontColor[ptShort] := '$000000' ;
    OrderFontColor[ptLong] := '$000000' ;

    QtyBgColor[ptShort] := '$F5E2DA' ;
    QtyBgColor[ptLong] := '$E4E2FC' ;
    OrderBgColor[ptShort] := '$F5E2DA' ;
    OrderBgColor[ptLong] := '$E4E2FC' ;

    //-- set DoubleOrder
    // -- 1. �����ڻ� ( �Ⱥ��̰� )
    PanelUnders.Visible := VisibleUnder;
    PanelUnders.Height := 0;
    PanelSymbols.Height := 49 ;

    // -- 2. ���콺 ������ �ֹ� ( �����ϵ��� )
    FOrderTablets[stLeft].OrderRightButton :=  OrderRightButton ;
    FOrderTablets[stRight].OrderRightButton :=  OrderRightButton ;
    // �ڵ���ũ��
    FOrderTablets[stLeft].AutoScroll := AutoScroll;
    FOrderTablets[stRight].AutoScroll := AutoScroll;

  end;

  //-- ComboUnders �ʱ�ȭ
  if ComboUnders.Items.Count <> 0 then
  begin
    ComboUnders.ItemIndex := 0;
    ComboUndersChange(ComboUnders);
  end;

  
  //-- KeyBorad
  FKeyOrderMapItem:= gKeyOrderAgent.SetKeyOrder(Self, FSymbols[stLeft], FSymbols[stRight], FAccount);

  gCObserver.Broadcaster.Subscribe(CFID_DOORDER, [btNew], Self, ObserverProc);
  gCObserver.Broadcaster.Subscribe(CFID_EFORDER, [btNew], Self, ObserverProc);

  PanelTabletLeft.Color := TABLET_COLOR[stLeft];
  PanelTabletRight.Color := TABLET_COLOR[stRight];

  FSynFutures := gPrice.SymbolStore.FindSymbol(K200_SYNFUT1_CODE);

  // 2007.05.30 ������ �г� ���� ���̵��� ����
  BtnRightInfoClick(BtnRightInfo); 
end;

procedure TDoubleOrderForm.FormDestroy(Sender: TObject);
begin
  //
  gWin.ModifyWorkspace;

  // Symbol
  if FSymbols[stLeft] <> nil then
    FSymbols[stLeft].Unsubscribe(Self);
  if FSymbols[stRight] <> nil then
    FSymbols[stRight].Unsubscribe(Self);

  // Underlying
  if FUnderlyings[stLeft] <> nil then
    FUnderlyings[stLeft].UnSubscribe(Self);
  if FUnderlyings[stRight] <> nil then
    FUnderlyings[stRight].UnSubscribe(Self);

  // gTrade
  gTrade.Broadcaster.Unsubscribe(Self);

  // Timer
  FQtyHighLightTimer[stLeft].Enabled := false ;
  FQtyHighLightTimer[stLeft].Free ;
  FQtyHighLightTimer[stRight].Enabled := false ;
  FQtyHighLightTimer[stRight].Free ;

  // TickPainter
  FTickPainters[stLeft].Free;
  FTickPainters[stRight].Free;

  FTickPainters2[stLeft].Free;
  FTickPainters2[stRight].Free;


  // ZaprService
  FZaprServices[stLeft].Free;
  FZaprServices[stRight].Free;
  // OrderTablet
  FOrderTablets[stLeft].Free;
  FOrderTablets[stRight].Free;
  // obj 
  FOrderHandler.Free;
  // KeyBoard 
  FKeyOrderMapItem.Unsubscribe(Self);
  gKeyOrderAgent.Remove(FKeyOrderMapItem);

  gCObserver.Broadcaster.UnSubscribe(Self);
  
end;

procedure TDoubleOrderForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //
  {  -- redundancy 
  if FSymbols[stLeft] <> nil then
    FSymbols[stLeft].Unsubscribe(Self);
  if FSymbols[stRight] <> nil then
    FSymbols[stRight].Unsubscribe(Self);
  }
  //
  Action := caFree;
end;


function TDoubleOrderForm.GetPosition(aSide : TSideType ): Integer;
var
  aFar, aNear : TPositionItem;
  iCurQty : Integer;
begin

  iCurQty := 0 ;
  
  // ��������
  if FSymbols[aSide].IsCombination then
  begin
    aFar  := gTrade.PositionStore.FindPosition(FAccount, FSymbols[aSide].Farther);
    aNear := gTrade.PositionStore.FindPosition(FAccount, FSymbols[aSide].Nearest);

    if (aFar <> nil) and (aNear <> nil) then
    begin
      if aFar.CurQty * aNear.CurQty < 0 then      // �ٿ����� �������� ��ȣ�� �ٸ���
      begin
        // �ܷ�
        iCurQty := Min(Abs(aFar.CurQty), Abs(aNear.CurQty));   // ���밪�� ������
        if aFar.CurQty < 0 then
          iCurQty := iCurQty * (-1) ;       // ��ȣ�� ������
      end;
    end;
  end else
  // �Ϲ� ����
  begin
    if FPositions[aSide] <> nil  then
      iCurQty := FPositions[aSide].CurQty;
  end;

  Result := abs(iCurQty) ; 

end;






procedure TDoubleOrderForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  //
  if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT ,VK_HOME, VK_SPACE ] then
  begin
    case Key of
      VK_UP    :
        begin
        FOrderTablets[stLeft].MoveLine(1, 1);
        FOrderTablets[stRight].MoveLine(1, 1);
        end ;
      VK_DOWN  :
        begin
        FOrderTablets[stLeft].MoveLine(1,-1);
        FOrderTablets[stRight].MoveLine(1,-1);
        end ; 
      VK_PRIOR :
        begin
        FOrderTablets[stLeft].MovePage(1);
        FOrderTablets[stRight].MovePage(1);
        end ; 
      VK_NEXT  :
        begin
        FOrderTablets[stLeft].MovePage(-1);
        FOrderTablets[stRight].MovePage(-1);
        end ; 
      VK_HOME, VK_SPACE :
      begin
         gCObserver.Notify(Self, CFID_DOORDER, ACID_CENTER, '�߾����Ŀ�û');
        // FOrderTablets[stLeft].MoveToPrice;
        // FOrderTablets[stRight].MoveToPrice;
      end;
    end;
    //
    Key := 0;
  end ;

  if Key = VK_ESCAPE then
  begin
    if FConfig.EnableEscape then
    begin

      if FConfig.ConfirmOrder and
       (MessageDlg('�� ���� ��� �ֹ��� ��ü ����Ͻðڽ��ϱ�?',
          mtConfirmation, [mbOK, mbCancel], 0) <> mrOK) then
      begin
        Key := 0;
        Exit;
      end;

      gLog.Add(lkUser, '�����ֹ�â', '�ֹ���ü���', 'Esc Key�� ��ü ���');
      if FSymbols[stLeft] =  FSymbols[stRight] then
      begin   // ���� �����϶��� �Ѱ������� �ֹ� �������� �Ѵ�. 
        CancelOrders([ptLong,ptShort], stLeft); 
      end
      else
      begin   // �ٸ� �����϶��� �Ѵ� ���
        CancelOrders([ptLong,ptShort], stLeft);
        CancelOrders([ptLong,ptShort], stRight);
      end; 
      Key := 0;
    end;
  end;
  //

  if FConfig.EnableOneFive then
  begin

    case Key of
      Ord('Q') :
        begin
          if FSymbols[stLeft] <> nil then
          begin
            // û����� Ǯ����
            SetExitEnable( false, stLeft );
            // �ֹ������� ����������
            SetOrderQty( IntToStr(GetPosition(stLeft)) , true, stLeft );
          end ;
          if FSymbols[stRight] <> nil then
          begin
            // û����� Ǯ����
            SetExitEnable( false, stRight );
            //  �ֹ������� ����������  
            SetOrderQty( IntToStr(GetPosition(stRight))  , true, stRight  );
          end ;

        end;
      Ord('1') :
        begin

          // 2007.05.25  EditOrderQty �� ��Ŀ���� �� ���� ��쿡�� Ÿ�� �ʵ��� �Ѵ�.
          if( EditOrderQty.Focused = true ) then exit ;

          if ( StaticExitLeft.Caption <> '') and ( GridOrderQtyLeft.Visible = true)  then
          begin
            StaticExitLeft.SetFocus;
            SetExitEnable( not FClearOrder[stLeft], stLeft );
            // û������� �ֹ�����
            SetOrderQty( IntToStr(FClearOrderQty[stLeft]) , true, stLeft );
          end;
          if ( StaticExitRight.Caption <> '') and ( GridOrderQtyRight.Visible = true) then
          begin
            StaticExitRight.SetFocus;
            SetExitEnable( not FClearOrder[stRight], stRight  );
            // û������� �ֹ�����
            SetOrderQty( IntToStr(FClearOrderQty[stRight]) , true, stRight );
          end;

        end;
      Ord('2')..Ord('4') :
        begin

          // 2007.05.25  EditOrderQty �� ��Ŀ���� �� ���� ��쿡�� Ÿ�� �ʵ��� �Ѵ�.
          if( EditOrderQty.Focused = true ) then exit ;

          if ( StaticExitLeft.Caption <> '') then
          begin
            // û����� Ǯ����
            SetExitEnable( false, stLeft );
            //  û�����/2 �� �ֹ�����
            SetOrderQty( IntToStr(FClearOrderQty[stLeft] div (Key-Ord('0'))),
              true, stLeft );
          end;
          if ( StaticExitRight.Caption <> '') then
          begin
            // û����� Ǯ����
            SetExitEnable( false, stRight );
            //  û�����/2 �� �ֹ�����
            SetOrderQty( IntToStr(FClearOrderQty[stRight] div (Key-Ord('0'))),
              true, stRight );
          end;
          
        end;
    end;
  end;

  gKeyOrderAgent.KeyNotify(Self, Key, Shift);
end;

procedure TDoubleOrderForm.FormResize(Sender: TObject);
begin
  //
  //FOrderTablets[stLeft].SetArea(PaintTabletLeft);
  //FOrderTablets[stRight].SetArea(PaintTabletRight);

  SetPaintSize;
end;


// ----- 6. PopMenu ----- //

procedure TDoubleOrderForm.PopQuotePopup(Sender: TObject);
begin
  //
end;

procedure TDoubleOrderForm.PopulateAccount;
var
  i : Integer ;
begin
  // gTrade.AccountStore.PopulateCombo(ComboAccount.Items, [ctAccount]);

  for i:=0 to gTrade.AccountStore.AccountCount-1 do
    ComboAccount.Items.AddObject(
      gTrade.AccountStore.Accounts[i].AccountName,
        gTrade.AccountStore.Accounts[i]);

end;

procedure TDoubleOrderForm.PopQuoteClick(Sender: TObject);
var
  aParams : TWorkFormParams;
begin
  if FSelectedOptions = nil then Exit;
  case (Sender as TMenuItem).Tag of
    110:
    begin
      with aParams do
      begin
        Object1 := FSelectedOptions;
        LongValue1 := 3;
      end;
      gWin.OpenForm(Self, ID_Price, aParams); // ���簡â
      //aForm:= gWin.OpenForm(ID_Price, nil, FSElectedOption); // ���簡
      //(aForm as TPriceForm).StatusIndex:= 3;
    end;
    120:  gWin.OpenForm(ID_Chart,nil,FSelectedOptions);   // ��Ʈâ
  end;
end;


procedure TDoubleOrderForm.PopOrdersLeftClick(Sender: TObject);
var
  aDlg : TDoubleOrderDialog;
begin
  //
  case (Sender as TMenuItem).Tag of
    100 : // item fixed
      NewOrder(FMenuPoints[stLeft].PositionType, FDefQty[stLeft],
        FMenuPoints[stLeft].Price, stLeft); // �ű��ֹ�
    200 : // order by dialog
      begin
        aDlg := TDoubleOrderDialog.Create(Self);
        try
          if aDlg.Open(FAccount, FSymbols[stLeft], FMenuPoints[stLeft].PositionType,
                otNew, 0, FMenuPoints[stLeft].Price ) then
            NewOrder(FMenuPoints[stLeft].PositionType, aDlg.Qty, aDlg.Price, stLeft );
        finally
          aDlg.Free;
        end;
      end;
    300 : // change order
      begin
        aDlg := TDoubleOrderDialog.Create(Self);
        try
          if aDlg.Open( FAccount, FSymbols[stLeft], FMenuPoints[stLeft].PositionType,
                otChange, FMenuPoints[stLeft].Qty, FMenuPoints[stLeft].Price) then
            ChangeOrder(FMenuPoints[stLeft], stLeft, aDlg.Qty, aDlg.Price  );
        finally
          aDlg.Free;
        end;
      end;
    400 : // cancel an order partly
      begin
        try
          aDlg := TDoubleOrderDialog.Create(Self);
          if aDlg.Open(FAccount, FSymbols[stLeft], FMenuPoints[stLeft].PositionType,
                otCancel, FMenuPoints[stLeft].Qty, FMenuPoints[stLeft].Price ) then
            CancelOrders(FMenuPoints[stLeft], stLeft, aDlg.Qty);
        finally
          aDlg.Free;
        end;
      end;
    500 : // cancel all an order
       // �ֹ����
       CancelOrders(FMenuPoints[stLeft], stLeft) ;
    900 : // one side cancel all
       // �ֹ����
       CancelOrders([FMenuPoints[stLeft].PositionType], stLeft ) ;
    1000 : // cancel all orders
       // �ֹ����
       CancelOrders([ptLong, ptShort], stLeft) ;
  end;

end;

procedure TDoubleOrderForm.PopOrdersLeftPopup(Sender: TObject);
var
  aPoint : TPoint;
  aOrderPoint : TOrderPoint;
  stHead : String;
begin
  if (FAccount = nil) or (FSymbols[stLeft] = nil) then Abort;
  //
  GetCursorPos(aPoint);
  aPoint := PaintTabletLeft.ScreenToClient(aPoint);
  //
  aOrderPoint := FOrderTablets[stLeft].GetPoint(aPoint.X, aPoint.Y);
  if not (aOrderPoint.FieldType = ofOrder ) then Abort;
  //
  FMenuPoints[stLeft] := aOrderPoint;
  // change menu caption
  stHead := PositionTypeDescs[aOrderPoint.PositionType];
  //
  PopOrdersLeft.Items[0].Caption :=
    stHead + Format('%.2f X %d(&1)',[aOrderPoint.Price, FDefQty[stLeft] ]);
  PopOrdersLeft.Items[0].Enabled := true ;    // ��� ���� ������
  //
  PopOrdersLeft.Items[1].Caption := stHead + '�ֹ�(&2)...';
  PopOrdersLeft.Items[1].Enabled := true ;    // ��� ���� ������
  PopOrdersLeft.Items[2].Caption := '����(&3)...';
  PopOrdersLeft.Items[2].Enabled := FMenuPoints[stLeft].Qty > 0;
  PopOrdersLeft.Items[3].Caption := '�Ϻ����(&4)...';
  PopOrdersLeft.Items[3].Enabled := FMenuPoints[stLeft].Qty > 0;
  PopOrdersLeft.Items[4].Caption := '�������(&5)...';
  PopOrdersLeft.Items[4].Enabled := FMenuPoints[stLeft].Qty > 0;
  PopOrdersLeft.Items[6].Caption := stHead + '�ֹ� �������(&S)...';
  PopOrdersLeft.Items[7].Caption := '�ֹ� �������(&A)...';
end;

procedure TDoubleOrderForm.PopOrdersRightPopup(Sender: TObject);
var
  aPoint : TPoint;
  aOrderPoint : TOrderPoint;
  stHead : String;
begin
    if (FAccount = nil) or (FSymbols[stRight] = nil) then Abort;
  //
  GetCursorPos(aPoint);
  aPoint := PaintTabletRight.ScreenToClient(aPoint);
  //
  aOrderPoint := FOrderTablets[stRight].GetPoint(aPoint.X, aPoint.Y);
  if not (aOrderPoint.FieldType = ofOrder ) then Abort;
  //
  FMenuPoints[stRight] := aOrderPoint;
  // change menu caption
  stHead := PositionTypeDescs[aOrderPoint.PositionType];
  //
  PopOrdersRight.Items[0].Caption :=
    stHead + Format('%.2f X %d(&1)',[aOrderPoint.Price, FDefQty[stRight] ]);
  PopOrdersRight.Items[0].Enabled := true ;    // ��� ���� ������
  //
  PopOrdersRight.Items[1].Caption := stHead + '�ֹ�(&2)...';
  PopOrdersRight.Items[1].Enabled := true ;    // ��� ���� ������
  PopOrdersRight.Items[2].Caption := '����(&3)...';
  PopOrdersRight.Items[2].Enabled := FMenuPoints[stRight].Qty > 0;
  PopOrdersRight.Items[3].Caption := '�Ϻ����(&4)...';
  PopOrdersRight.Items[3].Enabled := FMenuPoints[stRight].Qty > 0;
  PopOrdersRight.Items[4].Caption := '�������(&5)...';
  PopOrdersRight.Items[4].Enabled := FMenuPoints[stRight].Qty > 0;
  PopOrdersRight.Items[6].Caption := stHead + '�ֹ� �������(&S)...';
  PopOrdersRight.Items[7].Caption := '�ֹ� �������(&A)...';
end;

procedure TDoubleOrderForm.PopOrdersRightClick(Sender: TObject);
var
  aDlg : TDoubleOrderDialog;
begin
  //
  case (Sender as TMenuItem).Tag of
    100 : // item fixed
      NewOrder(FMenuPoints[stRight].PositionType, FDefQty[stRight],
        FMenuPoints[stRight].Price, stRight); // �ű��ֹ�
    200 : // order by dialog
      begin
        aDlg := TDoubleOrderDialog.Create(Self);
        try 
          if aDlg.Open(FAccount, FSymbols[stRight], FMenuPoints[stRight].PositionType,
                otNew, 0, FMenuPoints[stRight].Price ) then
            NewOrder(FMenuPoints[stRight].PositionType, aDlg.Qty, aDlg.Price, stRight );
        finally
          aDlg.Free;
        end;
      end;
    300 : // change order
      begin
        aDlg := TDoubleOrderDialog.Create(Self);
        try
          if aDlg.Open( FAccount, FSymbols[stRight], FMenuPoints[stRight].PositionType,
                otChange, FMenuPoints[stRight].Qty, FMenuPoints[stRight].Price) then
            ChangeOrder(FMenuPoints[stRight], stRight, aDlg.Qty, aDlg.Price  );
        finally
          aDlg.Free;
        end;
      end;
    400 : // cancel an order partly
      begin
        try
          aDlg := TDoubleOrderDialog.Create(Self);
          if aDlg.Open(FAccount, FSymbols[stRight], FMenuPoints[stRight].PositionType,
                otCancel, FMenuPoints[stRight].Qty, FMenuPoints[stRight].Price ) then
            CancelOrders(FMenuPoints[stRight], stRight, aDlg.Qty);
        finally
          aDlg.Free;
        end;
      end;
    500 : // cancel all an order
       // �ֹ����
       CancelOrders(FMenuPoints[stRight], stRight) ;
    900 : // one side cancel all
       // �ֹ����
       CancelOrders([FMenuPoints[stRight].PositionType], stRight ) ;
    1000 : // cancel all orders
       // �ֹ����
       CancelOrders([ptLong, ptShort], stRight) ;
  end;
end;


{
procedure TDoubleOrderForm.AppOnMessage(var Msg: TMsg;
  var Handled: Boolean);
begin


  // FFuturesHandle := EditFutures.Handle ;
  // FOptionsHandle := GridOptions.Handle ;

  if ( Msg.message = WM_RBUTTONDBLCLK ) then
  begin

    if(Msg.hwnd =  self.GridOptions.Handle  )   then
    begin
        gLog.Add(lkError, '�����ֹ�', 'AppOnMessage', '[message] GridOptions ' );
        //
        GridOptionsDblClick(GridOptions);
    end
    else if (Msg.hwnd = self.EditFutures.Handle ) then
    begin
        gLog.Add(lkError, '�����ֹ�', 'AppOnMessage', '[message] EditFutures ' );
        // 
        EditFuturesDblClick( EditFutures); 
    end;
    
  end ;
  
  // -- ? 
  Handled := false ; 
  
end;
}

procedure TDoubleOrderForm.GetOptionsInfo(aSymbol : TSymbol ;
    aSide : TSideType ) ;
var
  U , E , R , T , TC , W : Double;
  ExpireDateTime: TDateTime;
  dDelta, aIV, dGamma, dTheta, dVega : Double ;
  aGrid : TStringGrid ;
begin
  //
  if aSymbol = nil then exit ; 
  if aSymbol.SymbolType <> stOption then Exit;
  if FSynFutures = nil then Exit;

  try
    U := FSynFutures.C;
    E := aSymbol.StrikePrice;
    R := aSymbol.CDRate;
    ExpireDateTime := GetQuoteDate + aSymbol.RemDays - 1 + EncodeTime(15,15,0,0);
    //ExpireDateTime := gServerInfo.StdDate + aSymbol.RemDays - 1 + EncodeTime(15, 15, 0, 0);
    T := gPrice.Holidays.CalcRemainDays(GetQuoteTime, ExpireDateTime, rcTrdTime);
    //T := gPrice.Holidays.CalcRemainDays(Now , ExpireDateTime , aCalcType);
    TC := aSymbol.RemDays / 365;

    if aSymbol.OptionType = otCall then
      W := 1
    else
      W := -1;

    //
    aIV :=       IV(U, E, R, T, TC, aSymbol.C, W ) ;
    dDelta := Delta(U, E, R, aIV, T, TC, W ) ;
    dGamma := Gamma(U, E, R, aIV, T, TC )  ;
    dTheta := Theta(U, E, R, aIV, T, TC, gPrice.Holidays.WorkingDaysInYear, W ) ;
    dVega :=  Vega (U, E, R, aIV, T, TC, W ) ;

    // Format('%.2f' ,[ThValues[ptLong , m]]);

    // GridInfoLeft.Cells[1,5] := Format('%.*n', [FSymbol.Precision, FSymbol.C])  ;

    if ( ( aSide = stLeft ) and ( BtnLeftInfo.Down = true )) or
      ( ( aSide = stRight ) and ( BtnRightInfo.Down = true )) then
    begin
      with GridInfo do
      begin
        Cells[1,5] := Format('%.3f', [dDelta]);
        Cells[1,6] := Format('%.3f', [dGamma]);
        Cells[1,7] := Format('%.3f', [dTheta]);
        Cells[1,8] := Format('%.3f', [dVega]);
        Cells[1,9] := Format('%.3f', [aIV]) ;
      end;
    end;
    //


    // -- 2007.05.25 �ռ����� ���� 0.1���� Ŭ ��츸
    if abs( FSynFutures.C - FLastSynFutures ) > ( 0.02 + PRICE_EPSILON ) then
    begin 
      // -- 2007.05.21 IV �ʵ� �׷���
      FOrderTablets[aSide].DrawIV( U , E , R , T , TC , W ) ;
      FLastSynFutures := FSynFutures.C ;
    end;


  except
    on E : Exception do
      gLog.Add(lkError, '�����ֹ�â', 'GetOptionsInfo', E.Message);
  end;

end;





procedure TDoubleOrderForm.FormActivate(Sender: TObject);
begin
  // KeyBoard 
  if FKeyOrderMapItem <> nil then
    FKeyOrderMapItem.Active;
end;

procedure TDoubleOrderForm.KeyOrderProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
var
  aKeyOrderItem : TKeyOrderItem;
begin
  if (Receiver <> Self) or (DataObj = nil) then
  begin
    gLog.Add(lkError, '�����ֹ�â', 'KeyOrder Proc', 'Data Integrity Failure');
    Exit;
  end;


  aKeyOrderItem := DataObj as TKeyOrderItem;

  if iBroadcastKind = PID_KEYORDER then
  begin
    SetOrderQty( IntToStr( aKeyOrderItem.SymbolAQty ), False, stLeft );
    SetOrderQty( IntToStr( aKeyOrderItem.SymbolBQty ), False, stRight );
  end;

end;

const
  MARGIN_RECT = 5;

procedure TDoubleOrderForm.SetPaintSize;
begin
  PaintTabletLeft.Top := MARGIN_RECT;
  PaintTabletLeft.Height :=  PanelTabletLeft.Height - (MARGIN_RECT*2);

  if FOrderTablets[stLeft] <> nil then
    FOrderTablets[stLeft].SetArea(PaintTabletLeft)  ;

  //
  PaintTabletRight.Top := MARGIN_RECT;
  PaintTabletRight.Height :=  PanelTabletRight.Height - (MARGIN_RECT*2);

  if FOrderTablets[stRight] <> nil then
    FOrderTablets[stRight].SetArea(PaintTabletRight)  ;
end;



// -- ��� ��ư ( �����Ѱ� ����ϱ� )
procedure TDoubleOrderForm.BtnCancelClick(Sender: TObject);
var
  i : Integer ;
  aOrder : TOrder ;
  aReq : TOrderReqItem;
  iMaxQty, iQty : Integer ; 
begin


  iMaxQty := StrToInt(EditOrderQty.text) ;
  iQty := 0 ;

  for i := 0 to FLastOrderList.Count - 1 do
  begin

    if( ListOrders.Items[i].checked ) then
    begin

        aOrder := TOrder(ListOrders.Items[i].Data) ;
        if aOrder.OrderType = otNew then // redundant check
        begin
        
          if (iMaxQty > 0) and (iQty + aOrder.UnfillQty > iMaxQty) then
          begin
            if iMaxQty = iQty then Break;
            //
            aReq := FOrderHandler.Put(aOrder, iMaxQty - iQty);
            Break;
          end else
          begin
            Inc(iQty, aOrder.UnfillQty);
            //
            aReq := FOrderHandler.Put(aOrder, aOrder.UnfillQty);
            FOrderTablets[FLastSide].DoOrderReq(aReq, True);
          end;

        end;

    end;  // -- checked

  end;  // -- for


  if FOrderHandler.WaitCount > 0 then
  begin
    FOrderHandler.Send;
  end;

end;


// -- �ֹ� ����
procedure TDoubleOrderForm.SetOrderList( aSide : TSideType; aSymbol : TSymbol ; aList: TList; aPoint: TOrderPoint);
var
  i  : Integer ;
  aItem : TListItem ;
  aOrder : TOrder;
  aSign : String ;
  iSum , iQty : Integer ;
  stPosition : String ;
begin
  //
  FLastPoint := aPoint ;
  FLastSymbol := aSymbol ;
  FLastOrderList := aList ;
  FLastSide := aSide ;
  //
  lblSymbol.Caption := FLastSymbol.Desc ;
  if FLastPoint.PositionType = ptLong then
    stPosition := 'L'
  else
    stPosition := 'S' ;
  lblPrice.Caption := stPosition + ' ' + Format('%.2f', [FLastPoint.Price]) ;
  lblPrice.Font.Color := clRed ; 

  iSum := 0 ;
  ListOrders.Items.Clear ;
  for i := 0 to aList.Count-1 do
  begin
      aOrder := TOrder(aList.Items[i]);
      aItem := ListOrders.Items.Add ;
      // aItem.Caption := IntToStr(i);
      // aItem.SubItems.Add(IntToStr(aOrder.AcptNo)) ;
      if aOrder.PositionType = ptLong then
        aSign := '+'
      else
        aSign := '-' ;
      iQty := aOrder.UnfillQty ;
      aItem.SubItems.Add(aSign + IntToStr(iQty)) ;
      aItem.SubItems.Add(IntToStr(aOrder.AcptNo)) ; 
      aItem.Data :=  aOrder ;
      aItem.checked := true ; 

      iSum := iSum + iQty ;
  end;

  editOrderQty.Text := IntToStr(iSum);
  lblQty.Caption := '/ ' + IntToStr(iSum);

  // 
  if( aSide = stLeft ) then
    FOrderTablets[stRight].ResetClick
  else
    FOrderTablets[stLeft].ResetClick ;

end;


// -- ��Ŀ�� �̵���
procedure TDoubleOrderForm.editOrderQtyExit(Sender: TObject);
var
  i : Integer ;
  iQty  : Integer ;
  iSum : Integer ;
  aOrder : TOrder ;
begin
  //

  if(  Trim(editOrderQty.text) = '') then editOrderQty.text := '0' ; 

  iQty := StrToInt( editOrderQty.text );
  iSum := 0 ;

  if( iQty = 0 ) then
  begin
    for i := 0 to FLastOrderList.Count - 1 do
      ListOrders.Items[i].checked := false ;
  end
  else
  begin

    for i := 0 to FLastOrderList.Count - 1 do
    begin
      aOrder := TOrder(ListOrders.Items[i].Data) ;
      iSum := iSum + aOrder.UnfillQty ;
      //
      if (  ((( iSum -  aOrder.UnfillQty ) < iQty ) and  (iSum >= iQty) )
          or ( iSum <= iQty ) ) then
        ListOrders.Items[i].checked := true
      else
        ListOrders.Items[i].checked := false ;
      //
    end;  // -- for

  end;




end;

procedure TDoubleOrderForm.editOrderQtyKeyPress(Sender: TObject; var Key: Char);
begin
  //
 if ((Key < '0') or (Key > '9')) and (Key <> #13) and ( Key <>#8)  then Key:=#0;

 if( Key = #13  ) then
 begin
    editOrderQtyExit( editOrderQty) ;
 end;

end;


// -- �� ��ư�� ����� �ƴ϶� ������ �������� ����

// -- ����â �߰�
procedure TDoubleOrderForm.BtnOrderListClick(Sender: TObject);
begin
  BtnOrderList.Down := true ;
  PanelOrderList.Visible := true ;
  PanelInfo.Visible := false ;
end;


procedure TDoubleOrderForm.InitGridInfo(aSide: TSideType);
var
  i : Integer ;
begin

  if FSymbols[aSide] = nil then exit ;
  
  with FSymbols[aSide] do
  begin
    GridInfo.Cells[1,1] := Format('%.*n', [Precision,O] ) ;
    GridInfo.Cells[1,2] := Format('%.*n', [Precision,H] ) ;
    GridInfo.Cells[1,3] := Format('%.*n', [Precision,L] ) ;

    if Ticks[0] <> nil then
      GridInfo.Cells[1, 4] :=
        Format('%.0n',[(Ticks[0] as TFillTickItem ).AccVol ]) ;
  end ;

  if FSynFutures <> nil then
    GridInfo.Cells[1,0] :=  Format('%.2f', [FSynFutures.C]) ;

  for i := 0 to 9 do
  begin
    GridInfo.Cells[1,i] := '' ;
  end;

  GetOptionsInfo(FSymbols[aSide], aSide );

end;

// -- L ��ư Ŭ��
procedure TDoubleOrderForm.BtnLeftInfoClick(Sender: TObject);
begin
  BtnLeftInfo.Down := true ;
  BtnRightInfo.Down := false ;
  PanelInfo.Visible := true ;
  PanelOrderList.Visible := false ;
  //
  InitGridInfo(stLeft);
end;

// -- R ��ư Ŭ��
procedure TDoubleOrderForm.BtnRightInfoClick(Sender: TObject);
begin
  BtnRightInfo.Down := true ;
  BtnLeftInfo.Down := false ;
  PanelInfo.Visible := true  ;
  PanelOrderList.Visible := false ;
  //
  InitGridInfo(stRight);
end;

// -- �ֹ� ���� Ŭ��
procedure TDoubleOrderForm.ListOrdersMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i  : Integer ;
  aOrder : TOrder;
  iSum , iQty : Integer ;
begin
  //
  iSum := 0 ;
  for i:=0 to FLastOrderList.Count-1 do
  begin
    if( ListOrders.Items[i].checked ) then
    begin
      aOrder := TOrder(ListOrders.Items[i].Data);
      iSum := iSum + aOrder.UnfillQty ;
    end;
  end;
  editOrderQty.Text := IntToStr(iSum);
end;



end.
