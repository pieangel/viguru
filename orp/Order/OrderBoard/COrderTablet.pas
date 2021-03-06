unit COrderTablet;

interface

uses
  Windows, Graphics, Classes, Controls, SysUtils, Math, Dialogs, ExtCtrls, Menus, DateUtils,
    // lemon: common
  GleConsts, GleTypes,
    // lemon: data
  CleFQN, CleSymbols, CleQuoteBroker,
    // lemon: trade
  CleOrders, CleAccounts, CleStopOrders,
    // lemon: imports
  CalcGreeks, DBoardParams,  ClePriceItems,
    // App
  CleKrxSymbols;

{$INCLUDE define.txt}

const
  PRICE_EPSILON = 1.0e-8;
  DelaySec = 0.000003;

type
  TOrderTablet = class;

  TTabletAreaType = (taOrder, taStop, taFixed, taInfo, taGutter, taEtc);
  TTabletColumnType = (tcOrder, tcQuote, tcCount, tcPrice, tcGutter, tcStop);
  TTabletRowType = (trInfo, trData, trEtc);

    // 가격 컬럼 정보 표시 종류
  TIndexType = (idxMin{Min}, idxMax{Max}, idxAvg{Avg}, idxPrev );
    // trInfo 표시 데이터 타입
  TInfoType = ( itAvg {AvgPrice}, itPosition {OpenPosition}, itPL {EvalPL} ) ;

    // cell selection type
  TDataCellType = ( dcSelect, dcCancel, dcChange, dcTarget );

    // 
  TOrderDataType = (odOrder, odOrderReq );
  TOrderGraphicType = (ogNone, ogNew, ogChange, ogCancel );
  TOrderQtyActionType = (oqAdd, oqMove, oqSub);
  TOrderDrawMode = (odQuote, odPrice, odTable, odAll);

    // 가격열 정렬 : 오름차순, 내림차순, 자동
  TPriceOrientation = (poAsc, poDesc, poAuto);
    // 가격열 기준 왼쪽 오른쪽
  TSideType = (stLeft, stRight);

    // 가시영역 구분 : 가시영역보다 위, 가시영역, 밑, 전체
  TPriceVisibleType = (pvUp, pvVisible, pvDown, pvSum);

    //  QT 상태
  TOrderQTState = (qtDisabled, qtSuspended, qtActive, qtOutOfQuote);

  // 가격열 기준 왼쪽 오른쪽
  TColorType = ( ctBg, ctFont );

    // poistion in the tablet
  TTabletPoint = record
    Tablet: TOrderTablet;
    Index: Integer;               // price index
    PositionType: TPositionType;  // side
    AreaType: TTabletAreaType;   // area
    ColType: TTabletColumnType;    // column
    RowType: TTabletRowType;       // row
    Qty: Integer;                 // volume
    StopQty : integer;
    Price: Double;                // price
  end;

    // order peer
  TTabletDrawItem = class(TCollectionItem)
  public
    Order: TOrder;  // TOrder/TOrderReqItem
    StopORder : TStopORderItem;
      //
    GraphicType: TOrderGraphicType;     // none/new/change/cancel
    PositionType : TPositionType;     // long/short
    QtyActionType: TOrderQtyActionType; // add/move/sub
    FromIndex: Integer;
    ToIndex: Integer;

    Qty: Integer;
    VarQty: Integer; //
      // QT
    QTState: TOrderQTState ;
    QTIndex: Integer;
  end;

  // -- 가격열 ( tcPrice ) 데이터
  TOrderTableItem = class(TCollectionItem)
  public
    Price: Double;
    PriceDesc: String;

    OrderQty: array[TPositionType] of Integer;
    OrderVar: array[TPositionType] of Integer;
    Quotes: array[TPositionType] of Integer;
    QuoteDiffs: array[TPositionType] of Integer;
    QuoteCount: array[TPositionType] of Integer;

    QuotePosition: TPositionType;     // 가격의 잔량 Position ( 잔량 통합시 사용 )

    // -- 선행잔량 관련 데이터
    QTRefCounts: array[TPositionType] of Integer;
    QTQtys: array[TPositionType] of Integer;
    // -- IV
//    FIV : Double ;
    StopQty : array[TPositionType] of Integer;
    ClearStopQty : array[TPositionType] of Integer;
  end;

  // -- 컬럼 ( tcPrice, tcOrder.. ) 정보
  TOrderColumnItem = class(TCollectionItem)
  public
    Title : String;
    Width : Integer;
    Left, Right : Integer;
    ColType : TTabletColumnType;
    PositionType : TPositionType;
    Visible : Boolean;
    Color : TColor ;
  end;

    // events
  TTabletNotifyEvent = procedure(Sender: TOrderTablet) of object;
  TTabletSelectEvent = procedure(Sender: TOrderTablet;
                           aPoint1, aPoint2: TTabletPoint) of object;
  TTabletCacnelEvent = function(Sender: TOrderTablet; aTypes : TPositionTypes):integer of object;
  TTabletOrientationEvent = function( Sender : TOrderTablet ): TOrientationType of object;  //
  TFocusEvent = procedure( Sender : TOrderTablet; bLock : boolean ) of object;

  TPartCancelEvent  = procedure( Sender : TOrderTablet; aPoint : TTabletPoint;
          aTypes :  TPositionTypes ) of object;

  TOrderTablet = class
  private

    // ----- << Variables >> ----- //

    // -- 1. General Data Type
    // 1.1 Flag

    FReady : Boolean ;                  //
    FLowLimit, FHighLimit : Double ;    // 하한가, 상한가
    FPrevPrice, FMinPrice, FMaxPrice : Double ;     // Min, Max
    FAvgPrice, FEvalPL  : Double ;      // 평균단가 , 평가손익
    FOpenPosition : Integer ;           // 미결제약정수량

    // 1.3 View
    // data 영역 ( trData : TTabletRowType ) 그리기 시작/끝 좌표
    FDataTop, FDataBottom : Integer ;
     // 가시영역 Data(trData) row 개수, Info row 개수
    FViewTotCnt, FViewDataCnt, FViewInfoCnt : Integer ;

    // 가시 영역 FTable의 index
    // 내림차순 StartIndex < EndIndex , Price(StartIndex) < Price(EndIndex)
    // 오름차순 StartIndex < EndIndex , Price(StartIndex) > Price(EndIndex)
    FStartIndex, FEndIndex : Integer ;
    FPriceIndex : Integer ;   // 가격 index
    FPrevPriceIndex : integer;
    FFirstQuoteIndex : Integer ;  // 제1호가
    FQuoteIndexLow,FQuoteIndexHigh : Integer ;  // 호가
    // MouseDown, MouseMove 위치
    FStartX, FEndX, FStartY, FEndY : Integer ;
    // Tablet 넓이, 높이
    FWidth, FHeight : Integer ;
    FTabletWidth : Integer ;
    // Scroll
    FScrollSize : Integer ;
    FAutoScroll, FScrollLock : Boolean ;

    // -- 2. Object
    // 2.1 TCollection
    FTable: TCollection ;     // TOrderTableItem
    FDrawItems, FDrawItems2: TCollection ;  // TTabletDrawItem  order , Stop

    FColumns: TCollection ;    // TOrderColumnItem

      // 2.2 array
    FColWidths: Array[TTabletColumnType] of Integer ;
    FColVisibles: Array[TTabletColumnType] of Boolean ;
    FCols: Array[TTabletColumnType, TPositionType] of TOrderColumnItem ;
    FOrderQtySums: Array[TPositionType, TPriceVisibleType] of Integer ;  // 주문

    FStopQtySums : Array[TPositionType, TPriceVisibleType] of Integer ;  // 잔량
    FClearStopQtySums : Array[TPositionType, TPriceVisibleType] of Integer ;  // 잔량

    FQuoteSums: Array[TPositionType] of Integer ;   // 호가 - 잔량
    FQuoteCntSums: Array[TPositionType] of Integer ;   // 호가 - 건수
    FQUoteSumsGap, FQuoteCntSumsGap : integer;


    FInfoLefts : Array[TInfoType] of Integer ;      // 정보행 데이터 왼쪽 좌표
    FInfoWidths :  Array[TInfoType] of Integer ;    // 정보행 데이터 넓이

      // objects
    FSymbol: TSymbol;
    FQuote: TQuote;
    FPaintLine : TPaintBox;
    FPaintBox: TPaintBox;
    FCanvas: TCanvas;
    FBitmap: TBitmap;

      // points
    FCurrentPoint: TTabletPoint;
    FStartPoint: TTabletPoint;
    FClickPoint: TTabletPoint;
    FActionPoint: TTabletPoint;

    FOldFristQuotes : array [TPositionType] of integer;
    FFristQuotes : array [TPositionType] of integer;

      // assigned popup menu
    FPopOrders: TPopupMenu;

      // control
    FOrientationType: TOrientationType;
    FPriceAxisReversed : boolean;

    //FPriceOrientation : TPriceOrientation;   // 가격 정렬 타입 ( 오름차순, 내림차순 )

    FQuoteMerged: Boolean;                 // 잔량 컬럼 통합
    FMergedQuoteOnLeft: Boolean;   // 잔량통합시 잔량열 위치 (가격열 기준 좌우 )

    FFollowAction : Boolean; // ofData MouseDown : True, MouseUp : false
    FOrderRightButton : Boolean; // 마우스 오른쪽 버튼으로 주문 여부
    FMouseTrace : Boolean;       // 마우스 움직임 표시하기 ( 가격열과  해당 PositionType의 주문열 )

    FVisibleQT : Boolean ;        // 선행잔량


      // status
    FPositionTypes :array[TSideType] of TPositionType;  // 주문열 좌우 Position 위치

      // colors
    FTabletColor: TColor;
    FFrameColor: TColor;
    FQuoteColor: array [TPositionType, TColorType] of TColor;
    FOrderColor: array [TPositionType, TColorType] of TColor;
    FStopColor : array [TPositionType, TColorType] of TColor;

      // events

    FOnNewOrder: TTabletSelectEvent;
    FOnChangeOrder: TTabletSelectEvent;
    FOnCancelOrder: TTabletSelectEvent;
    //FOnFocusDel: TFocusEvent;
    FOnChanged: TTabletNotifyEvent;
    FOnSelectCell: TTabletSelectEvent;


    FSelected: Boolean;
    FDescending: Boolean;
    FAscending: Boolean;
    FOnOrientCount: TTabletOrientationEvent;
    FDescCount: integer;
    FAscCount: Integer;

    FLastSale : TTimeNSale;

    //FUseCtrl: TCtrlState;
    FShowForceSum: Boolean;
    FForceSumSec: Integer;
    FOnCancelOrders: TTabletCacnelEvent;

    FOnFocusDel: TFocusEvent;

    FFocusOff: boolean;

    FOwnOrderTrace: boolean;
    FAccount: TAccount;
    FOnPartCancelStandBy: TPartCancelEvent;
    FHideOwnOrderTrace: boolean;

    // 일괄 취소를 위한 주문 소트
    FAskOrders  : TStringList;
    FBidOrders  : TStringList;
    FShowMaxQty: boolean;
    FMaxQty: integer;
    FMouseSelect: boolean;
    FDbClickOrder: boolean;
    FLastOrdCnl: boolean;
    FSelectPoint: TTabletPoint;
    FOnLastCancelOrder: TTabletSelectEvent;

    FOnNewStopOrder: TTabletSelectEvent;
    FOnCancelStopORder: TTabletSelectEvent;
    FOnChangeStopOrder: TTabletSelectEvent;
    FOnCanelLastStopOrder : TTabletSelectEvent;
    FFixedHoga: boolean;
    FFontSize: integer;


    procedure SetQuote(const Value: TQuote);


    // ----- << Method >> ----- //

    // 1. General
    // 1.1 Draw

      //------(draw)-----------//

    procedure DrawCell(aCol : TOrderColumnItem; iTop, iBottom : Integer;
      BkColor : TColor; Text: String;
      FontColor: TColor = clBlack;
      Alignment : TAlignment = taRightJustify;
      bCopy : Boolean = False );

    procedure DrawCell2(aCol : TOrderColumnItem; iTop, iBottom : Integer;
      BkColor : TColor; Text: String;
      FontColor: TColor = clBlack;
      Alignment : TAlignment = taRightJustify;
      bCopy : Boolean = False;
      iLeft : integer = 0);

    procedure DrawRect(Rect : TRect; Text : String;
      BkColor, FontColor : TColor; Alignment : TAlignment);

      // drawing: elements
    procedure DrawArrow(aItem : TTabletDrawItem); // arrow
    procedure DrawArrow2(aItem: TTabletDrawItem);

    procedure DrawPriceCell(aPoint : TTabletPoint; bHighlighted : Boolean); // 'price' column cell
    procedure DrawDataCell(aPoint : TTabletPoint; bHighlighted : Boolean); // 'order' column cell
    procedure DrawDataActionCell(aPoint: TTabletPoint; bHighlighted: Boolean;
      aCellType:  TDataCellType); // 'order' column cell action
    procedure DrawDataActionCells( iIndex : integer; colType :TTabletColumnType;
      posType : TPositionType; bVerti : boolean = true );
      // drawing: info
    procedure DrawInfoCell(aRect: TRect; stText : String;
      aBkColor, aFontColor: TColor;  alignValue : TAlignment = taRightJustify ); // 'info' cell
    procedure DrawOrderSum; // order sum
    procedure DrawStopOrderSum;
    procedure DrawInfoRow;  // 'info'

    procedure DrawGrid; // grid
    procedure DrawTitle;
    procedure DrawPrice; // visible 'price' column
    procedure DrawPriceUpdate(iMinIndex, iMaxIndex : Integer); // draw 'price' column
    procedure DrawQuote; // draw quote
    procedure DrawQuoteUpdate(iMinIndex, iMaxIndex : Integer; bRefresh : Boolean); // draw quote cell
    procedure DrawQuoteLine;

    procedure DrawTable; // order columns
    procedure DrawQT(iIndex : Integer; aPosType : TPositionType); // QT
      // drawing: price column
    procedure DrawIndex( dValue: Double; idxType : TIndexType; bErase :Boolean=True );
    procedure DrawMAX(aRect : TRect; bkColor : TColor);
    procedure DrawMIN(aRect : TRect; bkColor : TColor);
    procedure DrawPrev(aRect : TRect; bkColor : TColor);
    procedure DrawAvg(aRect : TRect; bkColor : TColor);


    // DrawInfo
    // TOrderDrawMode에 따른 그리기 함수 호출
    procedure Draw(aMode : TOrderDrawMode);

    // 1.2 Calculate/Reset
    // 가시영역
    procedure RecalcView(iToIndex : Integer);
    // 주문합
    procedure ResetSum;
    procedure RecalcSum;
    // 주문표
    procedure ResetTable;
    procedure RecalcTable;



    // 1.3 Set/Get
    procedure SetSymbol(aSymbol : TSymbol);
    // 데이터 영역에서 index를 파라메터로 줬을때 해당 Y 좌표(중간값)을 리턴 
    function GetY(iIndex : Integer) : Integer;
    // 가격에 해당하는 FTable의 index 
    function FindIndex(dPrice : Double) : Integer;
    // 해당 인덱스의 FTable의 Item을 반환
    function GetTableItem(i:Integer) : TOrderTableItem;
    // 가격 셀의 Color 구하기 
    function GetPriceColor( iIndex : Integer; dValue : Double) : TColor ;
    //
    function FindDrawItem(aObj : TObject) : TTabletDrawItem;
    function FindDrawItem2(aObj : TObject) : TTabletDrawItem;
    // Property
    function GetOrderSum(aType : TPositionType) : Integer;
    //
    procedure SetColWidth(aOrderColumnType: TTabletColumnType; i : Integer);
    procedure SetColVisible(aOrderColumnType: TTabletColumnType; bVisible : Boolean);
    // aPositionType : 왼쪽열 PositionType
    procedure SetOrderSide(aLeftPositionType : TPositionType);
    
    // 평균단가 : AvgPrice
    procedure SetAvgPrice(dValue : Double ) ;
    // 평가손익 : EvalPL
    procedure SetEvalPL(dValue : Double) ;
    // 미결제약정수량 : OpenPositions
    procedure SetOpenPosition(iValue : Integer );
    // MinPrice
    procedure SetMinPrice(dValue : Double) ; 
    // MaxPrice
    procedure SetMaxPrice(dValue : Double) ; 

    // 가격열에 Index를 그려야 할지 여부 
    function DrawIndexYN( iIndex : Integer ; idxType : TIndexType ) : Boolean;   
    // Tick Value
    function GetTickValue(mtValue: TMarketType; price:Double ) : Double;

    // 1.4 Column
    // FColumns에 추가
    function AddColumn(stTitle : String; aColType : TTabletColumnType ;
      aPType : TPositionType) : TOrderColumnItem  ;
    // Long/Short 가장 바깥쪽 컬럼 ( 사용예 : 화살표 시작점 컬럼 알기 위해 )
    function GetLastColumn(aPType : TPositionType) : TOrderColumnItem ;  
    // FColumns에서 조건에 맞는  TOrderColumnItem 찾기
    function GetColumn(aColType : TTabletColumnType;
      aPType : TPositionType) : TOrderColumnItem ; overload;
    function GetColumn(aColType : TTabletColumnType) : TOrderColumnItem ; overload;
    // 컬럼 데이터 변경 : Visible에 따른 Width, Left, Right 변경
    procedure RepositionColumns;

    // 2. Event
    procedure MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Paint(Sender: TObject);
    procedure PaintLine(Sender:TObject);
    procedure DblClick(Sender: TObject);
    procedure QuoteDblClick(Sender: TObject);

    procedure ActMouseMove;

    procedure NotifyChanged;
    //function GetQtyIndex(aType: TQuoteType; iRange: Integer): Integer;

    function GetOrderColor(ptType: TPositionType; ctType: TColorType): TColor;
    function GetQuoteColor(ptType: TPositionType; ctType: TColorType): TColor;
    procedure SetOrderColor(ptType: TPositionType; ctType: TColorType;
      const Value: TColor);
    procedure SetQuoteColor(ptType: TPositionType; ctType: TColorType;
      const Value: TColor);
    procedure SetSelected(const Value: Boolean);

    procedure SetOrientationType(const Value: TOrientationType);
    procedure SetPositionType(const Value: Boolean);
    procedure SetAutoOrientation(bPut: boolean);
    function GetColWidth(aOrderColumnType: TTabletColumnType): Integer;
    procedure DrawRect2(Rect: TRect; Text: String; BkColor, FontColor: TColor;
      Alignment: TAlignment);

    function AddOrder(aOrder: TOrder) : TTabletDrawItem;
    procedure DeleteOrder( aOrder : TOrder );
    procedure SetCanvas(aPosType: TPositionType; aDist: TForceDist);

    procedure DrawRefresh(aPosType: TPositionType; aTableItem: TOrderTableItem;
      iIdx: integer);

    procedure DrawSelectCell(aPoint: TTabletPoint; bHighlighted: Boolean);
    function GetStopSum(aType: TPositionType): Integer;
    procedure DrawRect3(Rect: TRect; Text: String; BkColor, FontColor: TColor;
      Alignment: TAlignment);
    procedure DeleteDrawItem2(aObj: TObject);
    procedure DarwMovingArrow(aPoint: TTabletPoint; X, Y: Integer);
    procedure DrawPreQuoteLine;
    procedure SetFontSize(const Value: integer);
    procedure SetPrevPrice(const Value: double);

  public
    ORDER_WIDTH, DEFAULT_HEIGHT : integer;

    PriceArrange , MarketPrcSell, MarketPrcBuy : TPanel;
    ShortStopCnl , ShortAllCnl, AllCnl, LongAllCnl, LongStopCnl : TPanel;

    constructor Create;
    destructor Destroy; override;

      // init & set
    procedure Clear;
    procedure MouseClear;
    procedure InitSymbol(aSymbol : TSymbol);
    procedure SetLine(aPaintBox : TPaintBox);
    procedure SetArea(aPaintBox : TPaintBox);
    procedure SetButtons( Top1, Top2, Top3 : TPanel );
    procedure SetBottomButtons( Bot1, Bot2, Bot3, Bot4, Bot5 : TPanel );
    function GetPoint(X, Y : Integer): TTabletPoint;
    function GetIndex(dPrice: double): integer;

      // make
    procedure MakeColumns(bRefresh : Boolean);
    procedure MakeTable;

      // realtime
    procedure UpdatePrice(bDraw: Boolean = True);
    procedure UpdateQuote(bDraw: Boolean = True);
      // order
    procedure DoOrder(aOrder: TOrder; bDraw : boolean = true);
    procedure DoOrder2(aOrder: TOrder);

    function GetOrders(aType : TPositionType ): TOrder; overload;
    function GetOrders(aTypes: TPositionTypes; aList: TOrderList): Integer; overload;
    function GetOrders(aPoint: TTabletPoint; aList: TOrderList): Integer; overload;
    function GetOrders(aPoint: TTabletPoint; aTypes: TPositionTypes; aList: TOrderList): Integer; overload;

    function GetStopOrders(aPoint: TTabletPoint; aList: TList): Integer;

      // scroll
    procedure ScrollToCenter(iIndex : Integer);
    procedure ScrollToLastPrice;
    procedure ScrollPage(iDir : Integer);
    procedure ScrollLine(iLine, iDir : Integer);

    function DoStopOrderEvent( aStop : TStopOrderItem ) : boolean;

      // IV 그리기
    procedure CalcIV(U , E , R , T , TC , W : Double);
    procedure ResetClick ;

      // objects assigned
    property Symbol: TSymbol read FSymbol write SetSymbol;
    property Quote: TQuote read FQuote write SetQuote;
    property PopOrders : TPopupMenu read FPopOrders write FPopOrders;

      // data objects
    property Items[i:Integer]: TOrderTableItem read GetTableItem; default;

      // status
    property Ready: Boolean read FReady write FReady;

      // dimension
    property TabletWidth: Integer read FTabletWidth;
    property ColVisibles[aOrderColumnType: TTabletColumnType]: Boolean write SetColVisible;
    property ColWidths[aOrderColumnType: TTabletColumnType]: Integer read GetColWidth write SetColWidth;
    property QuoteMerged: Boolean read FQuoteMerged write FQuoteMerged;
    property MergedQuoteOnLeft: Boolean read FMergedQuoteOnLeft write FMergedQuoteOnLeft;
      // order trace
    property OwnOrderTrace    : boolean read FOwnOrderTrace    write FOwnOrderTrace;
    property HideOwnOrderTrace: boolean read FHideOwnOrderTrace write FHideOwnOrderTrace;
      // order
    property OrderSum[aType:TPositionType] : Integer read GetOrderSum;
    property StopSum[aType:TPositionType] : Integer read GetStopSum;

    property AvgPrice : Double read FAvgPrice write SetAvgPrice ;
    property EvalPL : Double read FEvalPL write SetEvalPL ;
    property OpenPosition : Integer read FOpenPosition write SetOpenPosition;
    property MinPrice : Double read FMinPrice write SetMinPrice ;
    property MaxPrice : Double read FMaxPrice write SetMaxPrice ;
    property PrevPrice: double read FPrevPrice write SetPrevPrice ;
    property LowLimit : double read FLowLimit;
    property HighLimit: double read FHighLimit;    // 하한가, 상한가

    property Account  : TAccount read FAccount write FAccount;

      // control
    property AutoScroll : Boolean read FAutoScroll write FAutoScroll;
    property ShowQT : Boolean read FVisibleQT write FVisibleQT;
    property TraceMouse: boolean read FMouseTrace write FMouseTrace ;
    property FixedHoga : boolean read FFixedHoga  write FFixedHoga;

    property Selected : Boolean read FSelected  write SetSelected;
      // add by seunge 2014.04.01
    property DbClickOrder : boolean read FDbClickOrder write FDbClickOrder; // 더블클릭 주문 / 원클릭주문
    property MouseSelect  : boolean read FMouseSelect write FMouseSelect;   // 마우스 위치 셀선택 / 클릭 셀선택
    property LastOrdCnl : boolean read FLastOrdCnl write FLastOrdCnl;

    property ShowMaxQty : boolean read FShowMaxQty write FShowMaxQty;
    property MaxQty : integer read FMaxQty write FMaxQty;

    property FocusOff     : boolean read FFocusOff  write FFocusOff;

    property AscCount : Integer read FAscCount write FAscCount;
    property DescCount: integer read FDescCount write FDescCount;
    property FontSize : integer read FFontSize write SetFontSize;

      // colors
    property TabletColor: TColor read FTabletColor write FTabletColor;
    property FrameColor: TColor read FFrameColor write FFrameColor;
    property QuoteColors[ptType: TPositionType; ctType: TColorType]: TColor read GetQuoteColor write SetQuoteColor ;
    property OrderColors[ptType: TPositionType; ctType: TColorType]: TColor read GetOrderColor write SetOrderColor ;

      // events
    property OnNewOrder : TTabletSelectEvent read FOnNewOrder write FOnNewOrder;
    property OnChangeOrder : TTabletSelectEvent read FOnChangeOrder write FOnChangeOrder;
    property OnCancelOrder : TTabletSelectEvent read FOnCancelOrder write FOnCancelOrder;
    property OnLastCancelOrder : TTabletSelectEvent read FOnLastCancelOrder write FOnLastCancelOrder;
    property OnChanged: TTabletNotifyEvent read FOnChanged write FOnChanged;
    property OnSelectCell: TTabletSelectEvent read FOnSelectCell write FOnSelectCell;

    property SelectPoint : TTabletPoint read FSelectPoint write FSelectPoint;
    property OnOrientCount : TTabletOrientationEvent read FOnOrientCount write FOnOrientCount;
      // stop event
    property OnNewStopOrder : TTabletSelectEvent read FOnNewStopOrder write FOnNewStopOrder;
    property OnChangeStopOrder : TTabletSelectEvent read FOnChangeStopOrder write FOnChangeStopOrder;
    property OnCancelStopOrder : TTabletSelectEvent read FOnCancelStopORder write FOnCancelStopOrder;
    property OnCanelLastStopOrder : TTabletSelectEvent read FOnCanelLastStopOrder write FOnCanelLastStopOrder;

    property OnCancelOrders :  TTabletCacnelEvent read FOnCancelOrders write FOnCancelOrders;
    property OnFocusDel : TFocusEvent read FOnFocusDel write FOnFocusDel;

    procedure RefreshDraw;
    procedure NewOrder;

    // 주문표, 주문합, 주문 그리기
    procedure RefreshTable;
  end;

const
  // column의 넓이
  //ORDER_WIDTH = 58;       // 주문 영역
  QTY_WIDTH = 50 ;        // 호가(잔량)영역
  CNT_WIDTH = 45 ;  // 호가(건수)영역
  PRICE_WIDTH = 80;       // 가격 영역
  PRICE_WIDTH_WIDE = 80;  // 호가 통합 이후

  //IV_WIDTH = 55 ;     // IV  영역
  STOP_WIDTH = 45 ;     // Stop  영역
  GUT_WIDTH = 5 ;     // Gut 영역

  OrderAreaTypeDescs : array[TTabletAreaType] of String =
                 ('주문', 'Stop', 'Fixed', '정보' , 'Gut', '기타' );
  OrderColumnTypeDescs : array[TTabletColumnType] of String =
                 ('주문','잔량','건수','가격' , 'Gut', 'Stop');
  OrderRowTypeDescs : array[TTabletRowType] of String =
                 ('정보', '데이터', '기타');
  SideTypeDescs : array[TSideType] of String =
                ( 'Left' , 'Right'   );

  FRAME_WIDTH = 2 ;

//    TABLET_COLOR  : array[TSideType] of TColor
//           = ($00EFD2B4, $00CBACF0);

implementation

uses GAppEnv, GleLib;

const

  //DEFAULT_HEIGHT = 16;
  HALF_HEIGHT = 8 ;
 
  // 주문 화살표 
  GAP = 5;
  EAR_WIDTH = GAP-1;
  HALF_GAP = 2;

  // 가격 컬럼에 정보 표시할 영역 
  INDEX_LEFT = 0 ;
  INDEX_RIGHT = 11 ;
  
  // Double Order에서 사용하는 Color
  // Data Cell Frame Color 
  GRID_COLOR = clLtGray ;
  MOUSE_COLOR = clRed ;
  SELECT_ORD_COLOR = clGreen;

  CANCEL_COLOR = $FF0080 ;
  CHANGE_COLOR = $00FF00 ;
  TARGET_COLOR = clBlack ;
  SELECT_COLOR = clRed ;

  // Font Color
  SELECTED_FONT_COLOR = clWhite ;
  UNSELECTED_FONT_COLOR = clBlack ;
  // Price Cell Color
  DARKAREA_COLOR = clBtnFace;//$E6E6E6;// clLtGray ;

  //BULL_COLOR = clRed; // LONG_BG_COLOR ;
  //BEAR_COLOR = clBlue; // SHORT_BG_COLOR ;
  BULL_COLOR = $E4E2FC; // LONG_BG_COLOR ;
  BEAR_COLOR = $F5E2DA; // SHORT_BG_COLOR

  HEADTAIL_COLOR = clWhite ;

{ TOrderTablet }


//---------------------------------------------------------------------< init >

constructor TOrderTablet.Create;
begin
  ORDER_WIDTH := 58;
  DEFAULT_HEIGHT := 18;
  FFontSize      := 9;
    // created objects
  FTable := TCollection.Create(TOrderTableItem);
  FDrawItems := TCollection.Create(TTabletDrawItem);
  FDrawItems2:= TCollection.Create(TTabletDrawItem);
  FColumns := TCollection.Create(TOrderColumnItem);
  FBitmap := TBitmap.Create;

  FAccount  :=  nil;
    // set default column widths
  FColWidths[tcGutter]:= GUT_WIDTH;
  FColWidths[tcOrder] := ORDER_WIDTH;
  FColWidths[tcQuote] := QTY_WIDTH;
  FColWidths[tcPrice] := PRICE_WIDTH;
  FColWidths[tcCount] := CNT_WIDTH ;
  FColWidths[tcStop]  := STOP_WIDTH ;
    // set default column visible
  FColVisibles[tcGutter] := True;
  FColVisibles[tcOrder] := True;
  FColVisibles[tcQuote] := True;
  FColVisibles[tcPrice] := True;
  FColVisibles[tcCount] := True;
  FColVisibles[tcStop]  := True;
    // Colors
  FTabletColor := clWhite;
  FFrameColor := clNavy;

  FQuoteColor[ptShort, ctBg] := clWhite ;
  FQuoteColor[ptShort, ctFont] := $000000 ;
  FQuoteColor[ptLong, ctBg] := clWhite ;
  FQuoteColor[ptLong, ctFont] := $000000 ;
  FOrderColor[ptShort, ctBg] := clWhite ;
  FOrderColor[ptShort, ctFont] := $000000 ;
  FOrderColor[ptLong, ctBg] := clWhite ;
  FOrderColor[ptLong, ctFont] := $000000 ;

  FStopColor[ptLong, ctBg ] :=  clWhite;
  FStopColor[ptShort, ctBg ]:=  clWhite;

    //
  FPositionTypes[stLeft] := ptShort;
  FPositionTypes[stRight] := ptLong;

  FDescCount:= 0;
  FAscCount:= 0;
  FPrevPriceIndex := -1;

  FShowMaxQty:= false;
  FMaxQty:=100;

    // control
  FOrientationType := otAsc;
  FPriceAxisReversed  := false;

  FLastSale := nil;

    // refresh
  MakeColumns(False);

  FAskOrders  := TStringList.Create;
  FAskORders.Sorted := true;
  FBidOrders  := TStringList.Create;
  FBidORders.Sorted := true;

end;

procedure TOrderTablet.DeleteOrder(aOrder: TOrder);
var
  iPr, iRes : integer;
  stLog : string;
begin
  iPr  :=  aOrder.Symbol.Spec.Precision;
  if aOrder.Side = 1 then
  begin
    iRes  := FBidOrders.IndexOf( Format('%.*n', [ iPr, aOrder.Price ]));
  end
  else begin
    iRes  := FAskOrders.IndexOf( Format('%.*n', [ iPr, aOrder.Price ]));
  end;

  if iRes < 0 then
  begin
    stLog := Format( '%s , %.2f , %d ',
      [ ifThenStr( aOrder.Side = 1, 'L', 'S'),
        aOrder.Price,
        aOrder.ActiveQty
      ]);
    gLog.Add( lKError, 'TOrderTablet', 'DeleteOrder', stLog);
  end;
end;

destructor TOrderTablet.Destroy;
begin
  FBitmap.Free;
  FColumns.Free;
  FDrawItems.Free;
  FDrawItems2.Free;
  FTable.Free;

  FAskOrders.Free;
  FBidOrders.Free;

  inherited;
end;

// ==================== << private >> ==================== //

// ----- 1.1 Draw

// TOrderColumnItem 정보(Left,Right)와 파라메터정보( Top, Bottom)를 가지고 Rect를 만들어 그려줌
// ( bCopy : FPaintBox.Canvas copy 여부 )
procedure TOrderTablet.DrawCell(aCol: TOrderColumnItem ; iTop,
  iBottom: Integer; BkColor: TColor; Text: String; FontColor: TColor;
  Alignment: TAlignment; bCopy: Boolean );
var
  iX, iY : Integer;
  aSize : TSize;
  aTextRect : TRect;
  dFormat : word;
begin
  FCanvas.Brush.Color := BkColor;
  FCanvas.Font.Color := FontColor;

  aTextRect := Rect(aCol.Left , iTop, aCol.Right, iBottom);
  FCanvas.FillRect(aTextRect);

  if Text <> '' then
  begin

    aSize := FCanvas.TextExtent(Text);
    iY := aTextRect.Top + (aTextRect.Bottom-aTextRect.Top-aSize.cy) div 2;

    case Alignment of
      taLeftJustify :  iX := aTextRect.Left + 2;
      taCenter :       iX := aTextRect.Left + (aTextRect.Right-aTextRect.Left-aSize.cx) div 2;
      taRightJustify : iX := aTextRect.Left + aTextRect.Right-aTextRect.Left-aSize.cx - 2 ;
    end;

    FCanvas.TextRect(aTextRect, iX, iY, Text);
  end;

  if bCopy then
    BitBlt( FPaintBox.Canvas.Handle,
      aTextRect.Left, aTextRect.Top ,
      aTextRect.Right - aTextRect.Left,
      iBottom - iTop,
      FCanvas.Handle,
      aTextRect.Left, aTextRect.Top , SRCCOPY);
    //FPaintBox.Canvas.CopyRect(aTextRect, FCanvas, aTextRect);

end;

procedure TOrderTablet.DrawCell2(aCol: TOrderColumnItem ; iTop,
  iBottom: Integer; BkColor: TColor; Text: String; FontColor: TColor;
  Alignment: TAlignment; bCopy: Boolean; iLeft : integer);
var
  iX, iY : Integer;
  aSize : TSize;
  aTextRect : TRect;
  dFormat : word;
begin
  FCanvas.Brush.Color := BkColor;
  FCanvas.Font.Color := FontColor;

  if Alignment = taRightJustify then
    aTextRect := Rect(aCol.Left, iTop, aCol.Right - iLeft, iBottom)
  else
    aTextRect := Rect(aCol.Left + iLeft, iTop, aCol.Right, iBottom);
  FCanvas.FillRect(aTextRect);

  if Text <> '' then
  begin

    aSize := FCanvas.TextExtent(Text);
    iY := aTextRect.Top + (aTextRect.Bottom-aTextRect.Top-aSize.cy) div 2;

    case Alignment of
      taLeftJustify :  iX := aTextRect.Left + 2;
      taCenter :       iX := aTextRect.Left + (aTextRect.Right-aTextRect.Left-aSize.cx) div 2;
      taRightJustify : iX := aTextRect.Left + aTextRect.Right-aTextRect.Left-aSize.cx - 2 ;
    end;

    FCanvas.TextRect(aTextRect, iX, iY, Text);
  end;

  if bCopy then
    BitBlt( FPaintBox.Canvas.Handle,
      aTextRect.Left, aTextRect.Top ,
      aTextRect.Right - aTextRect.Left,
      iBottom - iTop,
      FCanvas.Handle,
      aTextRect.Left, aTextRect.Top , SRCCOPY);
    //FPaintBox.Canvas.CopyRect(aTextRect, FCanvas, aTextRect);

end;

// Rect를 파라메터로 받아 Rect에 그림
procedure TOrderTablet.DrawRect(Rect: TRect; Text: String; BkColor,
  FontColor: TColor; Alignment: TAlignment);
var
  iX, iY : Integer;
  aSize : TSize;
begin
  FCanvas.Brush.Color := BkColor;
  FCanvas.Font.Color := FontColor;
  FCanvas.FillRect(Rect);
  if Text = '' then Exit;
  //
  aSize := FCanvas.TextExtent(Text);
  iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;
  case Alignment of
    taLeftJustify :  iX := Rect.Left + 2;
    taCenter :       iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    taRightJustify : iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2;
  end;
  //
  FCanvas.TextRect(Rect, iX, iY, Text);
end;

procedure TOrderTablet.DrawRect2(Rect: TRect; Text: String; BkColor,
  FontColor: TColor; Alignment: TAlignment);
var
  iX, iY : Integer;
  aSize : TSize;
begin
  FCanvas.Brush.Color := BkColor;
  FCanvas.Font.Color := FontColor;

  if Text = '' then Exit;
  //
  aSize := FCanvas.TextExtent(Text);

  iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;
  case Alignment of
    taLeftJustify :
      begin
        iX := Rect.Left + 2;
        Rect.Right  := Rect.Left + aSize.cx + 2;
      end;
    taCenter :       iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    taRightJustify :
      begin
        iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2;
        Rect.Left := iX;
      end;
  end;
  //
  FCanvas.FillRect(Rect);
  FCanvas.TextRect(Rect, iX, iY, Text);
end;

procedure TOrderTablet.DrawRect3(Rect: TRect; Text: String; BkColor,
  FontColor: TColor; Alignment: TAlignment);
var
  iX, iY : Integer;
  aSize : TSize;
begin

  FCanvas.Brush.Color := BkColor;
  FCanvas.Font.Color := FontColor;

  if Text = '' then Exit;
  //

  aSize := FCanvas.TextExtent(Text);

  iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;
  case Alignment of
    taLeftJustify :
      begin
        iX := Rect.Left + 2;
        Rect.Right  := Rect.Left + aSize.cx + 2;
      end;
    taCenter :       iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    taRightJustify :
      begin
        iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2;
        Rect.Left := iX;
      end;
  end;
  //
  FCanvas.FillRect(Rect);
  FCanvas.TextRect(Rect, iX, iY, Text);
  FCanvas.Font.Color := clBlack;


end;

procedure TOrderTablet.DrawSelectCell(aPoint: TTabletPoint;
  bHighlighted: Boolean);
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
  aDummy :  TTabletPoint;
begin

  if not FMouseSelect then Exit;

  if (FPaintBox = nil) or (FSymbol = nil) then Exit;
  if (aPoint.Index < FStartIndex) or (aPoint.Index > FEndIndex) then Exit;

  iTop :=  FDataTop + (FEndIndex - aPoint.Index ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

  if (aPoint.ColType in [tcOrder]) then
  begin
    aColumn := GetColumn(aPoint.ColType, aPoint.PositionType);
    if aColumn <> nil then
    with FCanvas do
    begin

      aRect := Rect(aColumn.Left-1 , iTop  , aColumn.Right + 1  , iBottom + 1 );
      //
      if  bHighlighted then
        Brush.Color := SELECT_ORD_COLOR
      else
        Brush.Color := GRID_COLOR ;
      //
      FrameRect(aRect);

      BitBlt( FPaintBox.Canvas.Handle,
        aRect.Left, aRect.Top ,
        aRect.Right - aRect.Left,
        aRect.Bottom - aRect.Top,
        FCanvas.Handle,
        aRect.Left, aRect.Top , SRCCOPY);

      //FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
    end;
  end;

  if  bHighlighted then
    aDummy.Qty := 100
  else
    aDummy.Qty := -100;

  {
  if Assigned( FOnLogEvent ) then
    FOnLogEvent( Self, aPoint, aDummy );
  }
end;

procedure TOrderTablet.DrawStopOrderSum;
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect;
begin

  if FColVisibles[tcStop] = false then exit ;

  iTop    := DEFAULT_HEIGHT ;
  iBottom := DEFAULT_HEIGHT * 2;

  // Gut - ptShort
  {
  iLeft := FCols[tcGutter, ptShort].Left  ;
  iRight := FCols[tcGutter, ptShort].Right +1  ;

  aBkColor := clBtnFace ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  // Gut - ptLong
  iLeft := FCols[tcGutter, ptLong].Left  ;
  iRight := FCols[tcGutter, ptLong].Right +1  ;

  aBkColor := clBtnFace ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  }

  // Order - 매도
  iLeft := FCols[tcStop, ptShort].Left  ;
  iRight := FCols[tcStop, ptShort].Right +1  ;

  stText := IntToStr(StopSum[ptShort]);
  //
  aBkColor := SHORT_BG_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  // Order - 매수
  iLeft := FCols[tcStop, ptLong].Left  ;
  iRight := FCols[tcStop, ptLong].Right +1  ;

  stText := IntToStr(StopSum[ptLong]);
  //
  aBkColor := LONG_BG_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;


end;

// 화살표 그리기
procedure TOrderTablet.DrawArrow(aItem: TTabletDrawItem);
var
  i, iSX, iSY, iEX, iEY : Integer; // arrow points
  iLX, iLY, iRX, iRY : Integer; // arrow ear points
  aColor : TColor;
  aSCol, aECol : TOrderColumnItem;
  //
  dX, dY, dArrowAngle, dEarAngle, dEarWidth, dLen : Double;
begin

  // No graphic or New
  if aItem.GraphicType in [ogNone, ogNew] then Exit;
  //
  FCanvas.Pen.Mode := pmCopy;


  //case aItem.DataType of
  //  odOrder :    aColor := clGreen;
  //  odOrderReq : aColor := clRed;
  //  else
  //    Exit;
  //end;
  aColor := clGreen;
  FCanvas.Pen.Color := aColor;
  FCanvas.Brush.Color := aColor;
  // get points
  iSY := GetY(aItem.FromIndex);
  iEY := GetY(aItem.ToIndex);


  if aItem.PositionType = FPositionTypes[stLeft] then
  begin
        case aItem.GraphicType of
          ogNew :    begin
                       aSCol := GetLastColumn(FPositionTypes[stLeft]);
                       aECol := GetColumn(tcOrder, FPositionTypes[stLeft]);
                       iSX := aSCol.Left + 1;
                       iEX := Min(aECol.Left + GAP, aECol.Right);
                     end;
          ogChange : begin
                       aECol := GetColumn(tcOrder, FPositionTypes[stLeft]);
                       iSX := Min(aECol.Left + GAP, aECol.Right);
                       iEX := iSX;
                     end;
          ogCancel : begin
                       aSCol := GetColumn(tcOrder, FPositionTypes[stLeft]);
                       aECol := GetLastColumn(FPositionTypes[stLeft]);
                       iSX := Min(aSCol.Left+GAP, aSCol.Right);
                       iEX := aECol.Left + 1;
                     end;
        end;
  end else
  begin
    case aItem.GraphicType of
      ogNew :   begin
                  aSCol := GetLastColumn(FPositionTypes[stRight]);
                  aECol := GetColumn(tcOrder, FPositionTypes[stRight]);

                  iSX := aSCol.Right - 3;
                  iEX := aECol.Right;
                end;
      ogChange :begin
                  aECol := GetColumn(tcOrder, FPositionTypes[stRight]);
                  iSX := Min(aECol.Left + GAP, aECol.Right);
                  iEX := iSX;
                end;
      ogCancel :begin
                  aSCol := GetColumn(tcOrder, FPositionTypes[stRight]);
                  aECol := GetLastColumn(FPositionTypes[stRight]);
                  iSX := aSCol.Right;
                  iEX := aECol.Right - 3;
                end;
    end;
  end;

  // line
  FCanvas.Rectangle(
              Rect(iSX-HALF_GAP, iSY-HALF_GAP, iSX+HALF_GAP+1, iSY+HALF_GAP+1));
  FCanvas.MoveTo(iSX, iSY);
  FCanvas.LineTo(iEX, iEY);
  // arrow

  // dX, dY, dArrowAngle, dEarWidth : Double;
  dX := iSX - iEX;
  dY := iSY - iEY;
  dEarAngle := PI / 8;
  dArrowAngle := ArcCos(dX/sqrt(dx*dx + dy*dy));

  iRX := Round(iEX + 8 * Cos(dArrowAngle-dEarAngle));
  iLX := Round(iEX + 8 * Cos(dArrowAngle+dEarAngle));
  if dY > 0 then
  begin
    iRY := Round(iEY + 8 * Sin(dArrowAngle-dEarAngle));
    iLY := Round(iEY + 8 * Sin(dArrowAngle+dEarAngle));
  end else
  begin
    iRY := Round(iEY - 8 * Sin(dArrowAngle-dEarAngle));
    iLY := Round(iEY - 8 * Sin(dArrowAngle+dEarAngle));
  end;
  // arrow
  FCanvas.Polygon([Point(iEX,iEY), Point(iLX,iLY), Point(iRX,iRY)]);

  // 화살표 사라질때..잔상 지워주기
  if aItem.GraphicType = ogChange then
  begin
    iSY := aItem.FromIndex;
    iEY := aItem.ToIndex;

    if iSY < iEY then
      for I := iSY to iEY  do
        DrawDataActionCells( i, tcOrder,  aItem.PositionType, false )
    else if iSY > iEY then
      for I := iEY to iSY do
        DrawDataActionCells( i, tcOrder,  aItem.PositionType, false );
  end else
  if aItem.GraphicType = ogCancel then
  begin
    iSY := aItem.FromIndex;
    DrawDataActionCells( iSY, tcStop,  aItem.PositionType ) ;
  end;

end;

procedure TOrderTablet.DrawArrow2(aItem: TTabletDrawItem);
var
  iSX, iSY, iEX, iEY : Integer; // arrow points
  iLX, iLY, iRX, iRY : Integer; // arrow ear points
  aColor : TColor;
  aSCol, aECol : TOrderColumnItem;
  //
  dX, dY, dArrowAngle, dEarAngle, dEarWidth, dLen : Double;
begin

  // No graphic?
  if aItem.GraphicType = ogNone then Exit;
  if (aItem.StopORder.MustClear) and
     (aITem.StopORder.pcValue = pcMarket) then Exit;
  
  //
  FCanvas.Pen.Mode := pmCopy;

  if aItem.StopORder.MustClear then
    aColor  := clGreen
  else
    aColor := clFuchsia;
  FCanvas.Pen.Color := aColor;
  FCanvas.Brush.Color := aColor;
  // get points
  iSY := GetY(aItem.FromIndex);
  iEY := GetY(aItem.ToIndex);

  aSCol := GetColumn(tcStop, aItem.PositionType);
  aECol := GetColumn(tcOrder,aItem.PositionType);
  iSX := (aSCol.Left + aSCol.Right) div 2;
  iEX := (aECol.Left + aECol.Right) div 2;

  // line
  FCanvas.Rectangle(
              Rect(iSX-HALF_GAP, iSY-HALF_GAP, iSX+HALF_GAP+1, iSY+HALF_GAP+1));
  FCanvas.MoveTo(iSX, iSY);
  FCanvas.LineTo(iEX, iEY);
  // arrow

  // dX, dY, dArrowAngle, dEarWidth : Double;
  dX := iSX - iEX;
  dY := iSY - iEY;
  dEarAngle := PI / 8;
  dArrowAngle := ArcCos(dX/sqrt(dx*dx + dy*dy));

  iRX := Round(iEX + 8 * Cos(dArrowAngle-dEarAngle));
  iLX := Round(iEX + 8 * Cos(dArrowAngle+dEarAngle));
  if dY > 0 then
  begin
    iRY := Round(iEY + 8 * Sin(dArrowAngle-dEarAngle));
    iLY := Round(iEY + 8 * Sin(dArrowAngle+dEarAngle));
  end else
  begin
    iRY := Round(iEY - 8 * Sin(dArrowAngle-dEarAngle));
    iLY := Round(iEY - 8 * Sin(dArrowAngle+dEarAngle));
  end;
  // arrow
  FCanvas.Polygon([Point(iEX,iEY), Point(iLX,iLY), Point(iRX,iRY)]);

end;


procedure TOrderTablet.DrawDataActionCell(aPoint: TTabletPoint;
  bHighlighted: Boolean; aCellType: TDataCellType);
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
  aColor : TColor ;
begin
  if (FPaintBox = nil)
     or (FSymbol = nil)
     or (aPoint.Index < FStartIndex)
     or (aPoint.Index > FEndIndex)
     or (not (aPoint.ColType in [tcOrder, tcStop])) then Exit;

    // top and bottom position
  iTop :=  FDataTop + (FEndIndex - aPoint.Index ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

    // color based on data cell type
  if aCellType = dcCancel then
    aColor := CANCEL_COLOR
  else if aCellType = dcChange then
    aColor := CHANGE_COLOR
  else if aCellType = dcTarget then
    aColor := TARGET_COLOR
  else if aCellType = dcSelect then
    aColor := SELECT_COLOR ;

    // column
  aColumn := GetColumn(aPoint.ColType, aPoint.PositionType);
  if aColumn = nil then Exit;

    // draw
  with FCanvas do
  begin
    aRect := Rect(aColumn.Left-1 , iTop, aColumn.Right + 1, iBottom +1 );

      //
    if  bHighlighted then
      Brush.Color := aColor
    else
      Brush.Color := GRID_COLOR ;

      //
    FrameRect(aRect);
    {
    BitBlt( FPaintBox.Canvas.Handle,
      aRect.Left, aRect.Top ,
      aRect.Right - aRect.Left,
      iBottom - iTop,
      FCanvas.Handle,
      aRect.Left, aRect.Top , SRCCOPY);
    }
    FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
  end;
end;

procedure TOrderTablet.DrawDataActionCells( iIndex : integer; colType :TTabletColumnType;
  posType : TPositionType; bVerti : boolean );
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
  aColor : TColor ;
begin
  if (FPaintBox = nil)
     or (FSymbol = nil)
     or (iIndex < FStartIndex)
     or (iIndex > FEndIndex)
     or (not (colType in [tcOrder, tcStop])) then Exit;
    // top and bottom position
  iTop :=  FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

    // column
  aColumn := GetColumn(colType, posType);
  if aColumn = nil then Exit;

    // draw
  with FCanvas do
  begin
    aRect := Rect(aColumn.Left-1 , iTop, aColumn.Right + 1, iBottom +1 );
    Pen.Color := GRID_COLOR ;

    if bVerti then
    begin
      // 세로 줄
      MoveTo( aRect.Left, iTop);
      LineTo( aRect.Left, iBottom );

      MoveTo( aRect.Right-1, iTop);
      LineTo( aRect.Right-1, iBottom );

    end
    else begin
      // 세로 줄
      MoveTo( aRect.Left, iTop);
      LineTo( aRect.Right, iTop );

      MoveTo( aRect.Left, iBottom);
      LineTo( aRect.Right, iBottom );
    end;
  end;
end;



// 주문영역 : taOrder
procedure TOrderTablet.DrawDataCell(aPoint: TTabletPoint;
  bHighlighted: Boolean);
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
begin

  if (FPaintBox = nil) or (FSymbol = nil) then Exit;
  if (aPoint.Index < FStartIndex) or (aPoint.Index > FEndIndex) then Exit;
  
  iTop :=  FDataTop + (FEndIndex - aPoint.Index ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

  if not FFollowAction and (aPoint.ColType in [tcOrder, tcStop]) then
  begin
    aColumn := GetColumn(aPoint.ColType, aPoint.PositionType);
    if aColumn <> nil then
    with FCanvas do
    begin

      aRect := Rect(aColumn.Left-1 , iTop  , aColumn.Right + 1  , iBottom + 1 );
      // 
      if  bHighlighted then
        Brush.Color := MOUSE_COLOR
      else
        Brush.Color := GRID_COLOR ;
      //
      FrameRect(aRect);
      {
      BitBlt( FPaintBox.Canvas.Handle,
        aRect.Left, aRect.Top ,
        aRect.Right - aRect.Left,
        aRect.Bottom - aRect.Top,
        FCanvas.Handle,
        aRect.Left, aRect.Top , SRCCOPY);
      }
      FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
    end;
  end;
end;

// Price 영역 : tcPrice & taFixed 
procedure TOrderTablet.DrawPriceCell(aPoint: TTabletPoint;
  bHighlighted: Boolean);
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
begin

  if (FPaintBox = nil) or (FSymbol = nil) then Exit;
  if (aPoint.Index < FStartIndex) or (aPoint.Index > FEndIndex) then Exit;

  //-- price
  aPriceCol := GetColumn(tcPrice);

  iTop := FDataTop + (FEndIndex - aPoint.Index ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

  if aPriceCol = nil then exit ;
  
  aRect := Rect(aPriceCol.Left -1   , iTop   , aPriceCol.Right + 1   , iBottom + 1);
  with FCanvas do
  begin

    if bHighlighted then
      Brush.Color := MOUSE_COLOR  
    else                    
      Brush.Color := GRID_COLOR ;
    // 
    FrameRect(aRect);
  end;
      {
      BitBlt( FPaintBox.Canvas.Handle,
        aRect.Left, aRect.Top ,
        aRect.Right - aRect.Left,
        aRect.Bottom - aRect.Top,
        //iBottom - iTop,
        FCanvas.Handle,
        aRect.Left, aRect.Top , SRCCOPY);
       }
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);

end;

// 주문 합계 그리기 
procedure TOrderTablet.DrawOrderSum;
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect;
begin

  if FColVisibles[tcOrder] = false then exit ;

  iTop    := 0 ;
  iBottom := DEFAULT_HEIGHT;
  // Gut - ptShort
  iLeft := FCols[tcGutter, ptShort].Left  ;
  iRight := FCols[tcGutter, ptShort].Right +1  ;

  aBkColor := clBtnFace ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  // Gut - ptLong
  iLeft := FCols[tcGutter, ptLong].Left  ;
  iRight := FCols[tcGutter, ptLong].Right +1  ;

  aBkColor := clBtnFace ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  iTop    := DEFAULT_HEIGHT ;
  iBottom := DEFAULT_HEIGHT * 2;

  // Gut - ptShort
  iLeft := FCols[tcGutter, ptShort].Left  ;
  iRight := FCols[tcGutter, ptShort].Right +1  ;

  aBkColor := clBtnFace ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  // Gut - ptLong
  iLeft := FCols[tcGutter, ptLong].Left  ;
  iRight := FCols[tcGutter, ptLong].Right +1  ;

  aBkColor := clBtnFace ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  // Order - 매도
  iLeft := FCols[tcOrder, ptShort].Left  ;
  iRight := FCols[tcOrder, ptShort].Right +1  ;

  stText := IntToStr(OrderSum[ptShort]);
  //
  aBkColor := SHORT_BG_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  // Order - 매수
  iLeft := FCols[tcOrder, ptLong].Left  ;
  iRight := FCols[tcOrder, ptLong].Right +1  ;

  stText := IntToStr(OrderSum[ptLong]);
  //
  aBkColor := LONG_BG_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  // 시장가

  iLeft := FCols[tcPrice, ptLong].Left  ;
  iRight := FCols[tcPrice, ptLong].Right +1  ;

  stText := '시장가';
  //
  aBkColor := DARKAREA_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor, taCenter ) ;



end;


procedure TOrderTablet.DrawInfoRow;
begin
  SetAvgPrice(FAvgPrice);
  //SetEvalPL(FEvalPL);
  //SetOpenPosition(FOpenPosition);
  //
  DrawOrderSum ;
  DrawStopOrderSum;
end;

procedure TOrderTablet.CalcIV(U , E , R , T , TC , W : Double);
var
  i: Integer;
begin
{
  for i := 0 to FTable.Count - 1 do
    with TOrderTableItem(FTable.Items[i]) do
      FIV := IV(U , E , R , T , TC, Price, W ) ;
}
end;


// 정보행의 셀 그리기 ( 평균단가, 평가손익, 미결제약정수량 )
procedure TOrderTablet.DrawInfoCell( aRect : TRect;
  stText : String ; aBkColor, aFontColor : TColor ;  alignValue : TAlignment) ;
  var
    iTop, iBottom : integer;
begin

  DrawRect(
    Rect( aRect.Left, aRect.Top , aRect.Right, aRect.Bottom),
      stText,aBkColor, aFontColor, alignValue );
  //
  aRect := Rect(aRect.Left -1, aRect.Top, aRect.Right , aRect.Bottom+1) ;

  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Brush.Color := GRID_COLOR ;
  FCanvas.FrameRect(aRect);
  //

  iTop := FDataTop - DEFAULT_HEIGHT ;
  iBottom := iTop + DEFAULT_HEIGHT;
  {
  BitBlt( FPaintBox.Canvas.Handle,
    aRect.Left, aRect.Top ,
    aRect.Right - aRect.Left,
    iBottom - iTop,
    FCanvas.Handle,
    aRect.Left, aRect.Top , SRCCOPY);
  }
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);


  //
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := FrameColor;
  FCanvas.Pen.Width := FRAME_WIDTH ;
  aRect :=  Rect( FPaintBox.Left, FPaintBox.Top, FPaintBox.Width, FPaintBox.Top+5) ;
  FCanvas.MoveTo(FPaintBox.Left, FPaintBox.Top);
  FCanvas.LineTo(FPaintBox.Width, FPaintBox.Top);
  {
  BitBlt( FPaintBox.Canvas.Handle,
    aRect.Left, aRect.Top ,
    aRect.Right - aRect.Left,
    iBottom - iTop,
    FCanvas.Handle,
    aRect.Left, aRect.Top , SRCCOPY);
  }
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
end;

// 가격열에 FAvgPrice그리기 
procedure TOrderTablet.DrawAvg(aRect: TRect; bkColor : TColor);
var
  iLeft : Integer ;
  stTxt : string;
begin
  FCanvas.Brush.Color := bkColor;

  if FOpenPosition > 0 then begin
    FCanvas.Font.Color := clRed;
    stTxt :='▲';
    iLeft := aRect.Right - INDEX_RIGHT-1;
  end
  else begin
    FCanvas.Font.Color := clBlue;
    stTxt :='▼';
    iLeft := aRect.Left;
  end;

  FCanvas.TextOut( iLeft, aRect.Top+2,stTxt );

end;

procedure TOrderTablet.DrawPrev(aRect: TRect; bkColor: TColor);
var
  iLeft : Integer ;
  stTmp, stTxt : string;
begin
  stTmp := FCanvas.Font.Name;

  FCanvas.Font.Name := 'Tahoma';
  FCanvas.Font.Style := FCanvas.Font.Style + [ fsbold] ;//+ [fsUnderline];
  stTxt :='C';

  iLeft := aRect.Right - INDEX_RIGHT-1;

  DrawRect(
  Rect(iLeft,aRect.Top+1, aRect.Right,aRect.Bottom),
    stTxt, bkColor, clBlack,   taLeftJustify);

  FCanvas.Font.Style := FCanvas.Font.Style - [ fsbold] ;//- [fsUnderline];
  FCanvas.Font.Name := stTmp;

end;

// 가격열에 Max값 그리기 
procedure TOrderTablet.DrawMAX(aRect: TRect; bkColor : TColor);
var
  iLeft : Integer ;
  stTmp, stTxt : string;
begin
  stTmp := FCanvas.Font.Name;

  FCanvas.Font.Name := 'Tahoma';
  FCanvas.Font.Style := FCanvas.Font.Style + [ fsbold] ;//+ [fsUnderline];
  stTxt :='H';

  iLeft := aRect.Right - INDEX_RIGHT-1;

  DrawRect(
  Rect(iLeft,aRect.Top+1, aRect.Right,aRect.Bottom),
    stTxt, bkColor, clRed,   taLeftJustify);

  FCanvas.Font.Style := FCanvas.Font.Style - [ fsbold] ;//- [fsUnderline];
  FCanvas.Font.Name := stTmp;

end;

// 가격열에 Min값 그리기 
procedure TOrderTablet.DrawMIN(aRect: TRect; bkColor : TColor);
var
  iLeft : Integer ;
  stTmp, stTxt : string;
begin

  stTmp := FCanvas.Font.Name;

  FCanvas.Font.Name  := 'Tahoma';
  FCanvas.Font.Style := FCanvas.Font.Style + [ fsbold] ;//+ [fsUnderline];
  stTxt :='L';

  iLeft := aRect.Left;

  DrawRect(
  Rect(iLeft,aRect.Top+1, aRect.Left + INDEX_RIGHT  ,aRect.Bottom),
    stTxt, bkColor, clBlue,   taLeftJustify);

  FCanvas.Font.Style := FCanvas.Font.Style - [ fsbold] ;//- [fsUnderline];
  FCanvas.Font.Name := stTmp;
end;


// 격자 그리기 
procedure TOrderTablet.DrawGrid;
var
  i, j, iX, iY, iHeight : Integer;
  aRect, aCopyRect: TRect;
begin

  iX := 0;
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Width := 1;

  FCanvas.Pen.Color := GRID_COLOR ;
  iHeight := DEFAULT_HEIGHT * (FViewTotCnt);

  // column
  for i:=0 to FColumns.Count-1 do
  begin
    with FColumns.Items[i] as TOrderColumnItem do
      if Visible then
      begin
        FCanvas.MoveTo(Right, 0);
        FCanvas.LineTo(Right, iHeight);
      end;
  end;
  FCanvas.Pen.Color := GRID_COLOR ;
  // row
  for j:=0 to FViewTotCnt do
  begin
    iY := DEFAULT_HEIGHT * j;
    FCanvas.MoveTo(0, iY);
    FCanvas.LineTo(FWidth, iY);
  end;
end;

procedure TOrderTablet.DrawTitle;
var
  i :integer;
  aItem : TOrderColumnItem;
  aRect : TRect;
begin
  for i:=0 to FColumns.Count-1 do
  begin
    aItem := TOrderColumnItem( FColumns.Items[i] );

    aRect := Rect( aItem.Left, 0, aItem.Right+1, DEFAULT_HEIGHT );
    if aItem.ColType = tcPrice then
      DrawInfoCell( aRect, '', clWhite,clBlack, taCenter )
    else
      DrawInfoCell( aRect, aItem.Title, clWhite,clBlack, taCenter ) ;
  end;


end;


// 가시영역 가격 컬럼 그리기
procedure TOrderTablet.DrawPrice;
begin
  DrawPriceUpdate(FStartIndex, FEndIndex);
  //DrawQuoteLine
end;

// 가격 컬럼 iMinIndex, iMaxIndex 만큼 그리기
procedure TOrderTablet.DrawPriceUpdate(iMinIndex, iMaxIndex: Integer);
var
  i, iTop, iBottom, iMinGap, iMaxGap : Integer;
  iRectTop, iRectBottom : Integer;
  aBkColor, aFontColor : TColor;
  
  aCol : TOrderColumnItem;
  aCopyRect : TRect;

  // index 관련 
  iMinPriceIndex, iMaxPriceIndex, iAvgPriceIndex , iPrevPriceIndex: Integer ;

  procedure DrawAutoScroll(aRect : TRect; iIndex : Integer);
  begin
    if not FAutoScroll or FScrollLock then Exit;
    // 자동 스크롤 체크 on 상태고 마우스가 주문, 스탑열에 없을때는.. 작대기 3개 표시
    if iIndex = FEndIndex then
    begin
      FCanvas.Pen.Color := clRed;

      FCanvas.MoveTo(aRect.Left+2, aRect.Top+2);
      FCanvas.LineTo(aRect.Left+7, aRect.Top+2);
      FCanvas.MoveTo(aRect.Left+2, aRect.Top+4);
      FCanvas.LineTo(aRect.Left+7, aRect.Top+4);
      FCanvas.MoveTo(aRect.Left+2, aRect.Top+6);
      FCanvas.LineTo(aRect.Left+7, aRect.Top+6);
    end else
    if iIndex = FStartIndex then
    begin
      FCanvas.Pen.Color := clBlue;

      FCanvas.MoveTo(aRect.Right-7, aRect.Bottom-3);
      FCanvas.LineTo(aRect.Right-2, aRect.Bottom-3);
      FCanvas.MoveTo(aRect.Right-7, aRect.Bottom-5);
      FCanvas.LineTo(aRect.Right-2, aRect.Bottom-5);
      FCanvas.MoveTo(aRect.Right-7, aRect.Bottom-7);
      FCanvas.LineTo(aRect.Right-2, aRect.Bottom-7);
    end;
  end;
begin



  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Mode := pmCopy;

  aCol := FCols[tcPrice, ptLong];

  iRectTop := -1;
  iRectBottom := -1;

  // index 관련
  if (FSymbol = nil) or (FSymbol.Spec = nil) then
  begin
    iMinPriceIndex := -1 ;
    iMaxPriceIndex := -1 ;
    iAvgPriceIndex := -1 ;
    iPrevPriceIndex:= -1 ;
  end
  else
  begin
    iPrevPriceIndex:= FindIndex(FSymbol.PrevClose);
    iMinPriceIndex := FindIndex(FMinPrice);
    iMaxPriceIndex := FindIndex(FMaxPrice);
    iAvgPriceIndex := FindIndex( GetTickValue(FSymbol.Spec.Market, FAvgPrice ));
  end ;

  for i:=iMaxIndex downto iMinIndex do
  begin
    if (i < 0) or (i < FStartIndex) or (i > FEndIndex) then Continue;

    iTop :=  FDataTop + (FEndIndex-i ) * DEFAULT_HEIGHT ;
    iBottom := iTop + DEFAULT_HEIGHT;

    if iRectTop < 0 then iRectTop := iTop;
    iRectBottom := Max(iBottom, iRectBottom);

    if Items[i] <> nil then
    begin
      aBkColor := GetPriceColor( i , Items[i].Price );
      //
      aFontColor := clBlack;
      //
      DrawRect(
        Rect(aCol.Left, iTop+1, aCol.Right, iBottom),
        Items[i].PriceDesc,
        aBkColor, aFontColor, taCenter);

      if i = iPrevPriceIndex  then
        DrawPrev(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBkColor );
      // -- Index
      if i = iMinPriceIndex  then
        DrawMin(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBKColor);
      if i = iMaxPriceIndex  then
        DrawMax(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBkColor);

      if i = iAvgPriceIndex  then
        DrawAvg(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBkColor );

    end;
    // -- AutoScroll
    if (i = FEndIndex) or (i = FStartIndex) then
      DrawAutoScroll(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), i);
  end;


  if (iRectTop < 0) or (iRectBottom < 0) then Exit;

  aCopyRect.Left := aCol.Left;
  aCopyRect.Right := aCol.Right;
  aCopyRect.Top := iRectTop + 1;
  aCopyRect.Bottom := iRectBottom;

  BitBlt( FPaintBox.Canvas.Handle,
    aCopyRect.Left, aCopyRect.Top ,
    aCopyRect.Right - aCopyRect.Left,
    aCopyRect.Bottom - aCopyRect.Top,
    FCanvas.Handle,
    aCopyRect.Left, aCopyRect.Top , SRCCOPY);

  //FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

end;


// 호가 컬럼 그리기
procedure TOrderTablet.DrawQuote;
begin

  DrawQuoteUpdate(FQuoteIndexLow, FQuoteIndexHigh, True);
end;

procedure TOrderTablet.DrawPreQuoteLine;
var
  iTop, iBottom, i : integer;
  aRect : TRect;
begin

  if (FOldFristQuotes[ptLong] < FStartIndex) or (FOldFristQuotes[ptLong] > FEndIndex) or
     (FOldFristQuotes[ptShort] < FStartIndex) or (FOldFristQuotes[ptShort] > FEndIndex)
     then Exit;


  FCanvas.Pen.Mode  := pmCopy;
  FCanvas.Pen.Width := 1;

  FCanvas.Pen.Color := GRID_COLOR;
  FCanvas.Brush.Color := clWhite;

  iTop :=  FDataTop + (FEndIndex-FOldFristQuotes[ptShort]) * DEFAULT_HEIGHT ;
  iBottom := iTop + DEFAULT_HEIGHT;

  aRect := Rect(0, iBottom-1, FWidth , iBottom);
  FCanvas.FillRect( aRect);

  FCanvas.MoveTo(0, iBottom);
  FCanvas.LineTo(FWidth, iBottom);

  // column
  for i:=0 to FColumns.Count-1 do
  begin
    with FColumns.Items[i] as TOrderColumnItem do
      if Visible then
      begin
        FCanvas.MoveTo(Right, iBottom-1);
        FCanvas.LineTo(Right, iBottom);
      end;
  end;


  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
end;



procedure TOrderTablet.DrawQuoteLine;
var
  iTop, iBottom, iTop2, iBottom2 : integer;
  aRect : TRect;
  I: Integer;
  aItem : TOrderColumnItem;
begin

  if (FFristQuotes[ptShort] < FStartIndex) or (FFristQuotes[ptShort] > FEndIndex)
     then Exit;

  iTop :=  FDataTop + (FEndIndex-FFristQuotes[ptShort]) * DEFAULT_HEIGHT ;
  iBottom := iTop + DEFAULT_HEIGHT;

  FPaintLine.Top    := iBottom;
  FPaintLine.Canvas.Brush.Color  := FrameColor;
  FPaintLine.Canvas.FillRect( FPaintLine.Canvas.ClipRect );
end;

// 호가 컬럼 iMinIndex, iMaxIndex 만큼 그리기
procedure TOrderTablet.DrawQuoteUpdate(iMinIndex, iMaxIndex: Integer;
  bRefresh: Boolean);
var
  iFirstIndex, iPrevH, iCurH , iWS,iWE : Integer ;
  aColumn : TOrderColumnItem ;
  aRect : TRect;
  //
  stVal : string;
  i : Integer;
  iTop, iBottom : Integer;
  aColor, bColor : TColor;
  aTableItem : TOrderTableItem;

  procedure DrawQuoteCell(aColType : TTabletColumnType; aPosType : TPositionType;
    bRefresh : Boolean);
    var
      aOppType : TPositionType;
      stTxt : string;
  begin

    if aPosType = ptLong then
      aOppType  := ptShort
    else
      aOppType  := ptLong;

    if (not bRefresh) and
       (aTableItem.QuoteDiffs[aPosType] = 0) and
       (aTableItem.QuoteDiffs[aOppType] = 0) then Exit;

    if FQuoteMerged and
      ( aTableItem.QuotePosition <> aPosType ) then exit ;

    // aColor ;= clWhite
    aColor := FQuoteColor[aPosType, ctBg] ;

    if aTableItem.Quotes[aPosType] = 0 then
      aColor := clWhite ;

    if aTableItem.Quotes[aPosType] = 0 then begin
      DrawCell( FCols[aColType,aPosType], iTop+1, iBottom, aColor,
                '', clBlack, taRightJustify, True);
    end
    else begin
      case aColType of
        tcQuote: stTxt := Format('%.0n',[aTableItem.Quotes[aPosType]*1.0]) ;
        tcCount: if aTableItem.QuoteCount[aPosType] = 0 then
                   stTxt := ''
                 else
                   stTxt := Format('%d',  [aTableItem.QuoteCount[aPosType]]);
      end;

      DrawCell( FCols[aColType, aPosType], iTop+1, iBottom, aColor,
                stTxt, FQuoteColor[aPosType, ctFont], taRightJustify, True);

    end;
  end;
begin

  if (FSymbol = nil) or (FQuote = nil) then Exit;

  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Mode := pmCopy;

  if (FQuote.Bids.Count = 0) or (FQuote.Asks.Count = 0) then Exit;

  for i:= iMinIndex to iMaxIndex do
    if (i >= FStartIndex) and (i <= FEndIndex) then
    begin
      aTableItem := Items[i];
      if aTableItem = nil then Exit;

      iTop := FDataTop + (FEndIndex-i) * DEFAULT_HEIGHT;
      iBottom := iTop + DEFAULT_HEIGHT;

      if FColVisibles[tcQuote] then
      begin
        DrawQuoteCell(tcQuote, ptShort, bRefresh); // copy included
        DrawQuoteCell(tcQuote, ptLong, bRefresh);  // copy included
      end;

      if FColVisibles[tcCount] then
      begin
        DrawQuoteCell(tcCount, ptShort, bRefresh); // copy included
        DrawQuoteCell(tcCount, ptLong, bRefresh);  // copy included
      end;
    end;

  iTop :=  DEFAULT_HEIGHT * (FViewTotCnt-2);
  iBottom := iTop + DEFAULT_HEIGHT;
  aColor  := clBtnFace;

  stVal   := Format('%d',  [FQuoteCntSums[ptShort]]);
  DrawCell( FCols[ tcCount, ptShort], iTop+1, iBottom, aColor,
            stVal, FQuoteColor[ptShort, ctFont], taRightJustify, True);

  stVal   := Format('%d',  [FQuoteSums[ptShort]]);
  DrawCell( FCols[ tcQUote, ptShort], iTop+1, iBottom, aColor,
            stVal, FQuoteColor[ptShort, ctFont], taRightJustify, True);

  stVal   := Format('%d',  [FQuoteCntSums[ptLong]]);
  DrawCell( FCols[ tcCount, ptLong], iTop+1, iBottom, aColor,
            stVal, FQuoteColor[ptLong, ctFont], taRightJustify, True);

  stVal   := Format('%d',  [FQuoteSums[ptLong]]);
  DrawCell( FCols[ tcQUote, ptLong], iTop+1, iBottom, aColor,
            stVal, FQuoteColor[ptLong, ctFont], taRightJustify, True);

  i := FQuoteCntSums[ptShort] - FQuoteCntSums[ptLong] ;
  if i > 0 then
    bColor := clRed
  else if i < 0 then
    bColor := clBlue
  else
    bColor  := clBlack;
  stVal   := Format('%d',  [ i ]);
  DrawCell( FCols[ tcPrice, ptShort], iTop+1, iBottom, aColor,
            stVal, bColor, taCenter, True);


end;

procedure TOrderTablet.SetCanvas( aPosType : TPositionType; aDist : TForceDist );
begin
  case aPosType of
    ptLong  : FCanvas.Font.Color := $3333FF;
    ptShort : FCanvas.Font.Color := $FF3333;
    else
      FCanvas.Font.Color := clBlack;
  end ;

  if  (aDist.Own) and ( FOwnOrderTrace ) and ( aDist.Order.Account = FAccount)then
  begin
    case aPosType of
      ptLong  : FCanvas.Font.Color := clGreen;
      ptShort : FCanvas.Font.Color := clPurple;
    end;
    FCanvas.Font.Style := FCanvas.Font.Style + [fsBold];
  end
  else begin
    if (ShowMaxQty) and ( aDist.Max )
      {and ( aDist.Qty >= MaxQty )} then
      FCanvas.Font.Style := FCanvas.Font.Style + [fsBold]
      {
      case aPosType of
        ptLong  : FCanvas.Font.Color := clRed;
        ptShort : FCanvas.Font.Color := clBlue;
      end;
      }
    else
      FCanvas.Font.Style := FCanvas.Font.Style - [fsBold];
  end;
end;


// 주문 컬럼 그리기
procedure TOrderTablet.DrawTable;
var
  aOrderCols, aGutCols, aQtyCols, aCntCols, aStopCols : array[TPositionType] of TOrderColumnItem;
  aPriceCol : TOrderColumnItem;
  i, iTop, iBottom, iHafe : Integer;
  stText : String;
  aCopyRect : TRect;
  aDrawItem : TTabletDrawItem;
  aPos : TPositionType;
  aColor, aBackColor, aFontColor : TColor;

begin

  if FEndIndex < 0 then exit ;
   
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Width := 1;

  //-- get columns
  aPriceCol           := GetColumn(tcPrice, ptLong);
  aOrderCols[ptShort] := GetColumn(tcOrder, ptShort);
  aOrderCols[ptLong]  := GetColumn(tcOrder, ptLong);
  aGutCols[ptShort]   := GetColumn(tcGutter, ptShort);
  aGutCols[ptLong]    := GetColumn(tcGutter, ptLong);
  aQtyCols[ptShort]   := GetColumn(tcQuote, ptShort);
  aQtyCols[ptLong]    := GetColumn(tcQuote, ptLong);
  aCntCols[ptLong]   := GetColumn(tcCount, ptLong);
  aCntCols[ptShort]   := GetColumn(tcCount, ptShort);


  iTop := FDataTop - DEFAULT_HEIGHT ;
  iBottom := iTop + DEFAULT_HEIGHT;
  //

  aCopyRect.Top := FDataTop ;
  aCopyRect.Bottom := FHeight ;
  aCopyRect.Left:= aGutCols[FPositionTypes[stLeft]].Left;
  aCopyRect.Right:= aGutCols[FPositionTypes[stRight]].Right;

  aStopCols[ptLong] := GetColumn(tcStop, ptLong);
  aStopCols[ptShort]  := GetColumn(tcStop, ptShort);
  //

  for i:=FEndIndex downto FStartIndex do
  begin
    Inc(iTop,DEFAULT_HEIGHT);
    iBottom := iTop + DEFAULT_HEIGHT;

    if FColVisibles[tcGutter] then
    begin

      DrawRect(
         Rect(aGutCols[ptShort].Left, iTop+1, aGutCols[ptShort].Right,iBottom),
              '', clBtnFace, clBlack, taRightJustify);
      DrawRect(
         Rect(aGutCols[ptLong].Left, iTop+1, aGutCols[ptLong].Right,iBottom),
              '', clBtnFace, clBlack, taRightJustify);
    end;

    // updated 2016.12.26  주문, 스탑열 배경색  FORderColor[type, ctBg] 으로 변경
    //
    if FColVisibles[tcOrder] then
    begin
        //매도주문
        if Items[i].OrderQty[ptShort] > 0 then
          stText := Format('%d',[Items[i].OrderQty[ptShort]])
        else
          stText := '';
        if Items[i].OrderVar[ptShort] > 0 then
          stText := stText + Format('+%d',[Items[i].OrderVar[ptShort]])
        else if  Items[i].OrderVar[ptShort] < 0 then
          stText := stText + Format('%d',[Items[i].OrderVar[ptShort]]);

        DrawRect(
          Rect(aOrderCols[ptShort].Left,iTop+1,aOrderCols[ptShort].Right,iBottom),
            stText, FORderColor[ptShort, ctBg] , FOrderColor[ptShort, ctFont] , taRightJustify);

        // 매수주문
        if Items[i].OrderQty[ptLong] > 0 then
          stText := Format('%d',[Items[i].OrderQty[ptLong]])
        else stText := '';
        if Items[i].OrderVar[ptLong] > 0 then
          stText := stText + Format('+%d',[Items[i].OrderVar[ptLong]])
        else if Items[i].OrderVar[ptLong] < 0 then
          stText := stText + Format('%d',[Items[i].OrderVar[ptLong]]);

        DrawRect(
        Rect(aOrderCols[ptLong].Left,iTop+1,aOrderCols[ptLong].Right,iBottom),
          stText, FOrderColor[ptLong, ctBg],  FOrderColor[ptLong, ctFont], taRightJustify);
    end ;

    if FColVisibles[tcStop] then
    begin
      // 매수 Stop 주문
      if Items[i].StopQty[ptLong] > 0 then
        stText := Format('%d',[Items[i].StopQty[ptLong]])
      else stText := '';

      DrawRect(
      Rect(aStopCols[ptLong].Left,iTop+1,aStopCols[ptLong].Right,iBottom),
        stText, FStopColor[ptLong, ctBg], FOrderColor[ptLong, ctFont] , taRightJustify);

      // 매수 Clear Stop 주문   <--- 설정에 의한 청산 스탑주문
      if Items[i].ClearStopQty[ptLong] > 0 then
        stText := Format('%d',[Items[i].ClearStopQty[ptLong]])
      else stText := '';

      DrawRect3(
      Rect(aStopCols[ptLong].Left,iTop+1,aStopCols[ptLong].Right,iBottom),
        stText, FStopColor[ptLong, ctBg], clRed , taLeftJustify);

      //매도 Stop 주문
      if Items[i].StopQty[ptShort] > 0 then
        stText := Format('%d',[Items[i].StopQty[ptShort]])
      else
        stText := '';

      DrawRect(
        Rect(aStopCols[ptShort].Left,iTop+1,aStopCols[ptShort].Right,iBottom),
          stText, FStopColor[ptShort, ctBG], FOrderColor[ptShort, ctFont] , taRightJustify);

      // 매도 Clear Stop 주문   <--- 설정에 의한 청산 스탑주문
      if Items[i].ClearStopQty[ptShort] > 0 then
        stText := Format('%d',[Items[i].ClearStopQty[ptShort]])
      else stText := '';

      DrawRect3(
      Rect(aStopCols[ptShort].Left,iTop+1,aStopCols[ptShort].Right,iBottom),
        stText, FStopColor[ptShort, ctBG],  clBlue , taLeftJustify);
    end;

    // DrawQT
    if (Items[i].QTRefCounts[ptLong] > 0) and
       (Items[i].Quotes[ptShort] = 0) then
      DrawQT(i, ptLong);
    if (Items[i].QTRefCounts[ptShort] > 0) and
       (Items[i].Quotes[ptLong] = 0) then
      DrawQT(i, ptShort);
  end;

  // 주문열이 보이지 않을때는 주문 action 화살표를 그리지 않는다.

  if FColVisibles[tcOrder] then
  begin
    for i:=0 to FDrawItems.Count-1 do
    begin
      aDrawItem := FDrawItems.Items[i] as TTabletDrawItem;
      DrawArrow(aDrawItem);
    end;
  end;

  if FColVisibles[tcStop] then
  begin
    for i:=0 to FDrawItems2.Count-1 do
    begin
      aDrawItem := FDrawItems2.Items[i] as TTabletDrawItem;
      DrawArrow2(aDrawItem);
    end;
  end;                            
  DrawDataCell(FClickPoint, True);

  BitBlt( FPaintBox.Canvas.Handle,
    aCopyRect.Left, aCopyRect.Top ,
    aCopyRect.Right - aCopyRect.Left,
    iBottom - iTop,
    FCanvas.Handle,
    aCopyRect.Left, aCopyRect.Top , SRCCOPY);
  //FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

  if FCurrentPoint.AreaType in [taGutter] then
    DrawDataCell(FCurrentPoint, False )
  else
    begin
      if FMouseTrace = true then
        DrawDataCell(FCurrentPoint, True);
    end ;

  DrawSelectCell( FSelectPoint, true );
end;




// -- 선행잔량 그리기 
procedure TOrderTablet.DrawQT(iIndex: Integer; aPosType: TPositionType);
var
  iTop, iBottom : Integer;
  aTableItem : TOrderTableItem;
  stText : String;
  aCopyRect : TRect;
begin
  if (not FVisibleQT) or
     (not FColVisibles[tcQuote]) or
     (iIndex < FStartIndex) or
     (iIndex > FEndIndex) or
     FQuoteMerged then Exit;

  iTop :=  FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;
  
  aTableItem := Items[iIndex];
  if aTableItem = nil then Exit;

  if aTableItem.QTRefCounts[aPosType] = 0 then
    stText := ''
  else
  if aTableItem.QTQtys[aPosType] = -1 then
    stText := '---'
  else
    stText := Format('%.0n', [aTableItem.QTQtys[aPosType]*1.0]);

  if  FQuoteMerged then
  begin
    case aPosType of
      ptLong :
        if aTableItem.Quotes[ptLong] = 0 then
          DrawCell(FCols[tcQuote, ptLong], iTop+1, iBottom, clWhite,
                 stText, $999999, taLeftJustify, True);
      ptShort :
        if aTableItem.Quotes[ptShort] = 0 then
          DrawCell(FCols[tcQuote, ptShort], iTop+1, iBottom, clWhite,
                 stText, $999999, taLeftJustify, True);
    end;
  end
  else
  begin 
    case aPosType of
      ptLong :
        if aTableItem.Quotes[ptShort] = 0 then
          DrawCell(FCols[tcQuote, ptShort], iTop+1, iBottom, clWhite,
                 stText, $999999, taRightJustify, True);
      ptShort :
        if aTableItem.Quotes[ptLong] = 0 then
          DrawCell(FCols[tcQuote, ptLong], iTop+1, iBottom, clWhite,
                 stText, $999999, taRightJustify, True);
    end;
  end; 

end;


// 가격 컬럼의 정보 표시 
procedure TOrderTablet.DrawIndex(dValue: Double; idxType: TIndexType;
  bErase: Boolean);
var

  iIndex : Integer ;
  iTop, iBottom : Integer;
  iLeft, iRight : Integer ;
  iLeft2, iRight2 : Integer ;
  aBkColor, aFontColor : TColor;

  aCol : TOrderColumnItem;
  aCopyRect : TRect;

  idxIndex : array[TIndexType] of Integer; 
begin

  if FSymbol = nil then exit ;

  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Mode := pmCopy;

  // 가격열에 그리기 
  aCol := FCols[tcPrice, ptLong];
  iLeft := aCol.Left + INDEX_LEFT ;
  iRight :=  iLeft + INDEX_RIGHT ;

  // get Index
  iIndex := FindIndex(dValue);
  if (iIndex < 0) or (iIndex < FStartIndex) or (iIndex > FEndIndex) then exit ;

  iTop :=  FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

  // 가격열의 color 정보와 동일하게
  aBkColor := GetPriceColor( iIndex , dValue );
  //if iIndex = FPriceIndex then
  //  aFontColor := clWhite
  //else
  aFontColor := clBlack;

  // 지우기 모드
  if bErase then
  begin

    DrawRect(
        Rect(aCol.Left, iTop+1, aCol.Right, iBottom),
        Items[iIndex].PriceDesc,
        aBkColor, aFontColor, taCenter);
    {
    // 초기화 
    DrawRect(
      Rect(iLeft, iTop+1, iRight, iBottom),
      ' ', aBkColor, aFontColor, taCenter);

    iLeft2 := aCol.Right- INDEX_RIGHT-1;
    iRight2:= aCol.Right;

    DrawRect(
      Rect(iLeft2, iTop+1, iRight2, iBottom),
      ' ', aBkColor, aFontColor, taCenter);
    }

    if idxType = idxMin then
    begin
      if DrawIndexYN(iIndex, idxMax) then
        DrawMax(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor);
      if DrawIndexYN(iIndex, idxPrev) then
        DrawPrev(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor);
      if DrawIndexYN(iIndex, idxAvg) then
        DrawAVG(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor);
    end
    else if idxType = idxMax then
    begin
      if DrawIndexYN(iIndex, idxMin) then
        DrawMin(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBKColor);
      if DrawIndexYN(iIndex, idxPrev) then
        DrawPrev(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor);
      if DrawIndexYN(iIndex, idxAvg) then
        DrawAVG(Rect(aCol.Left, iTop+1, aCol.Right , iBottom),aBKColor);
    end
    else if idxType = idxAvg then
    begin
      if DrawIndexYN(iIndex, idxMax) then
        DrawMax(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor );
      if DrawIndexYN(iIndex, idxMin) then
        DrawMin(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBKColor);
      if DrawIndexYN(iIndex, idxPrev) then
        DrawPrev(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor);
    end
    else if idxType = idxPrev then
    begin
      if DrawIndexYN(iIndex, idxMax) then
        DrawMax(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor );
      if DrawIndexYN(iIndex, idxMin) then
        DrawMin(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBKColor);
      if DrawIndexYN(iIndex, idxAvg) then
        DrawAVG(Rect(aCol.Left, iTop+1, aCol.Right , iBottom),aBKColor);
    end;

  end
  // 그리기 모드
  else
  begin
    {
     DrawRect(
        Rect(aCol.Left, iTop+1, aCol.Right, iBottom),
        Items[iIndex].PriceDesc,
        aBkColor, aFontColor, taCenter);
     }
    case idxType of
      idxMin: DrawMin(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBKColor);
      idxMax: DrawMax(Rect(aCol.Left, iTop+1, aCol.Right , iBottom), aBKColor);
      idxAvg: DrawAVG(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBkColor);
      //idxOpen: DrawOpen(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBkColor);
      idxPrev: DrawPrev(Rect(aCol.Left, iTop+1, aCol.Right, iBottom), aBkColor);
    end;

    iLeft2 := aCol.Right- INDEX_RIGHT-1;
    iRight2:= aCol.Right;

  end;

  if (iTop < 0) or (iBottom < 0) then Exit;

  aCopyRect.Left := aCol.Left;
  aCopyRect.Right := aCol.Right;
  aCopyRect.Top := iTop + 1;
  aCopyRect.Bottom := iBottom;

{
  aCopyRect.Left := iLeft;
  aCopyRect.Right := iRight ;
  aCopyRect.Top := iTop + 1;
  aCopyRect.Bottom := iBottom;

  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

  aCopyRect.Left := iLeft2;
  aCopyRect.Right := iRight2 ;
  aCopyRect.Top := iTop + 1;
  aCopyRect.Bottom := iBottom;
}
  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);
end;


// draw

procedure TOrderTablet.Draw(aMode: TOrderDrawMode);
var
  aRect: TRect;
  aColor  : TColor;
begin
  if (FSymbol = nil) or (FPaintBox = nil)  then Exit;

    //
  case aMode of
    odQuote:
          begin
            DrawQuote;
          end;
    odPrice:
          begin
            DrawPrice;
          end;
    odTable:
          begin
            //DrawGrid;
            DrawTable;
            //DrawIV;
          end;
    odAll:
          begin
              // background
            FCanvas.Brush.Color := clWhite;
            FCanvas.FillRect(Rect(0,0,FWidth,FHeight));
              // draw components
            DrawGrid;
            DrawTitle;
            DrawQuote;
            DrawPrice;
            DrawTable;
            DrawInfoRow;

            //DrawIV;
         end;
  end;
    // copy to the PaintBox

  if FSelected then
    aColor  := clRed
  else
    aColor  := GRID_COLOR;

  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := aColor;
  FCanvas.Pen.Width := FRAME_WIDTH ;
  FCanvas.Brush.Color := aColor;
  aRect :=  Rect( FPaintBox.Left, FPaintBox.Top, FPaintBox.Width, FPaintBox.Height) ;
  FCanvas.FrameRect(aRect);

  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
  DrawQuoteLine;

end;

//----------------------------------------------------------------< calculate >
                                      
// 가시영역 계산 
procedure TOrderTablet.RecalcView(iToIndex: Integer);
begin
  FEndIndex := Max(FViewDataCnt-1, Min(FTable.Count-1, iToIndex));
  FStartIndex := Max(FEndIndex - FViewDataCnt + 1 , 0);

  FEndIndex := Min(FTable.Count-1, FEndIndex);
  FStartIndex := Min(FTable.Count-1, FStartIndex);
end;

// 주문합 reset 
procedure TOrderTablet.ResetSum;
var
  i : Integer;
begin
    FOrderQtySums[ptLong, pvUp] := 0;
    FOrderQtySums[ptLong, pvVisible] := 0;
    FOrderQtySums[ptLong, pvDown] := 0;
    FOrderQtySums[ptLong, pvSum] := 0;
    FOrderQtySums[ptShort,pvUp] := 0;
    FOrderQtySums[ptShort,pvVisible] := 0;
    FOrderQtySums[ptShort,pvDown] := 0;
    FOrderQtySums[ptShort,pvSum] := 0;

    FStopQtySums[ptLong, pvUp] := 0;
    FStopQtySums[ptLong, pvVisible] := 0;
    FStopQtySums[ptLong, pvDown] := 0;
    FStopQtySums[ptLong, pvSum] := 0;
    FStopQtySums[ptShort,pvUp] := 0;
    FStopQtySums[ptShort,pvVisible] := 0;
    FStopQtySums[ptShort,pvDown] := 0;
    FStopQtySums[ptShort,pvSum] := 0;

    FClearStopQtySums[ptLong, pvUp] := 0;
    FClearStopQtySums[ptLong, pvVisible] := 0;
    FClearStopQtySums[ptLong, pvDown] := 0;
    FClearStopQtySums[ptLong, pvSum] := 0;
    FClearStopQtySums[ptShort,pvUp] := 0;
    FClearStopQtySums[ptShort,pvVisible] := 0;
    FClearStopQtySums[ptShort,pvDown] := 0;
    FClearStopQtySums[ptShort,pvSum] := 0;

end;

// 주문합계 계산
procedure TOrderTablet.RecalcSum;
var
  i : Integer;
begin
  if (FStartIndex < 0) or (FEndIndex < 0) then Exit;

  //-- clear sum
  ResetSum;
  //-- below sum
  for i := FStartIndex-1 downto 0 do
  begin
    Inc(FOrderQtySums[ptLong,pvDown], Items[i].OrderQty[ptLong]);
    Inc(FOrderQtySums[ptShort,pvDown], Items[i].OrderQty[ptShort]);

    inc(FStopQtySums[ptLong, pvDown], Items[i].StopQty[ptLong]);
    inc(FStopQtySums[ptShort, pvDown], Items[i].StopQty[ptShort]);

    inc(FClearStopQtySums[ptLong, pvDown], Items[i].ClearStopQty[ptLong]);
    inc(FClearStopQtySums[ptShort, pvDown], Items[i].ClearStopQty[ptShort]);
  end;
  //-- sum of the visible
  for i := FEndIndex downto FStartIndex do
  begin
    Inc(FOrderQtySums[ptLong, pvVisible ], Items[i].OrderQty[ptLong]);
    Inc(FOrderQtySums[ptShort, pvVisible ], Items[i].OrderQty[ptShort]);

    inc(FStopQtySums[ptLong, pvVisible], Items[i].StopQty[ptLong]);
    inc(FStopQtySums[ptShort, pvVisible], Items[i].StopQty[ptShort]);

    inc(FClearStopQtySums[ptLong, pvVisible], Items[i].ClearStopQty[ptLong]);
    inc(FClearStopQtySums[ptShort, pvVisible], Items[i].ClearStopQty[ptShort]);
  end;
  //-- above sum
  for i := FEndIndex+1 to FTable.Count-1 do
  begin
    Inc(FOrderQtySums[ptLong, pvUp], Items[i].OrderQty[ptLong]);
    Inc(FOrderQtySums[ptShort,pvUp], Items[i].OrderQty[ptShort]);

    inc(FStopQtySums[ptLong, pvUp], Items[i].StopQty[ptLong]);
    inc(FStopQtySums[ptShort, pvUp], Items[i].StopQty[ptShort]);

    inc(FClearStopQtySums[ptLong, pvUp], Items[i].ClearStopQty[ptLong]);
    inc(FClearStopQtySums[ptShort, pvUp], Items[i].ClearStopQty[ptShort]);
  end;
  //-- total
  FOrderQtySums[ptLong,pvSum] :=
    FOrderQtySums[ptLong,pvDown] + FOrderQtySums[ptLong,pvVisible]
      + FOrderQtySums[ptLong,pvUp] ;
  FOrderQtySums[ptShort,pvSum] :=
    FOrderQtySums[ptShort,pvDown] + FOrderQtySums[ptShort,pvVisible]
      + FOrderQtySums[ptShort,pvUp] ;

  FStopQtySums[ptLong,pvSum] :=
    FStopQtySums[ptLong,pvDown] + FStopQtySums[ptLong,pvVisible]
      + FStopQtySums[ptLong,pvUp] ;
  FStopQtySums[ptShort,pvSum] :=
    FStopQtySums[ptShort,pvDown] + FStopQtySums[ptShort,pvVisible]
      + FStopQtySums[ptShort,pvUp] ;

  FClearStopQtySums[ptLong,pvSum] :=
    FClearStopQtySums[ptLong,pvDown] + FClearStopQtySums[ptLong,pvVisible]
      + FClearStopQtySums[ptLong,pvUp] ;
  FClearStopQtySums[ptShort,pvSum] :=
    FClearStopQtySums[ptShort,pvDown] + FClearStopQtySums[ptShort,pvVisible]
      + FClearStopQtySums[ptShort,pvUp] ;

end;

// 주문표 reset 
procedure TOrderTablet.ResetTable;
var
  i : Integer;
begin
  for i:=0 to FTable.Count-1 do
    with TOrderTableItem(FTable.Items[i]) do
    begin
      OrderQty[ptLong] := 0; OrderQty[ptShort] := 0;
      OrderVar[ptLong] := 0; OrderVar[ptShort] := 0;
    end;
end;

//
procedure TOrderTablet.RecalcTable;
var
  i : Integer;
  st : string;
  pDraw : TTabletDrawItem;
begin
    // init table data to zeros
  ResetTable;

    // calculate order qty
  for i:=0 to FDrawItems.Count-1 do begin
    pDraw := TTabletDrawItem(FDrawItems.Items[i]);

    with pDraw do
      case QtyActionType of
        oqMove : // 정정
          begin    
            if ( FromIndex < 0) or ( ToIndex < 0) then
              Continue;
            Dec(Items[FromIndex].OrderVar[PositionType],Qty);
            Inc(Items[ToIndex].OrderVar[PositionType],Qty);

          end;
        oqSub :
          begin
            if ( FromIndex < 0)  then Continue;
            Dec(Items[FromIndex].OrderVar[PositionType], Qty);

          end;
        oqAdd :
          begin
            if ( FromIndex < 0)  then Continue;
            Inc(Items[FromIndex].OrderQty[PositionType],Qty);
            Inc(Items[FromIndex].OrderVar[PositionType],VarQty);
          end;
      end;
  end; // for

end;

procedure TOrderTablet.RefreshDraw;
begin
  Clear;
  SetOrientationType(FOrientationType);
    //
  MakeColumns(False);

    // generate table
  MakeTable;

    //-- 현재가/호가 index -> No draw
  UpdatePrice(False);
  UpdateQuote(False);

    //-- 현재가를 가운데로
  ScrollToCenter(FPriceIndex);

    // Point Rest
  FClickPoint.Index := -1;
  FSelectPoint.Index:= -1;
end;

procedure TOrderTablet.RefreshTable;
var
  stTmp : string;
  is1, is2, is3, is4, is5 : int64;
  dRes : double;
begin

  RecalcTable;    // 주문표 재계산

  RecalcSum;      // 주문합계 재계산

  //
  DrawOrderSum ;
  DrawStopOrderSum;

  Draw(odTable);

  //

end;

//--------------------------------------------------------------< orientation >

procedure TOrderTablet.SetPositionType(const Value: Boolean);
begin
  if Value then begin
    FPositionTypes[stLeft] :=  ptLong;
    FPositionTypes[stRight] := ptShort;
  end
  else begin
    FPositionTypes[stLeft] := ptShort;
    FPositionTypes[stRight] := ptLong;
  end;
end;




procedure TOrderTablet.SetAutoOrientation( bPut : boolean );
begin
  if ( AscCount = 0) and ( DescCount = 0) then
  begin
    SetPositionType( bPut );
    FPriceAxisReversed  := bPut;
  end else
  if (AscCount > 0) and ( DescCount = 0) then
  begin
    SetPositionType( bPut );
    FPriceAxisReversed  := bPut;
  end else
  if (AscCount = 0) and ( DescCount > 0) then
  begin
    SetPositionType( not bPut );
    FPriceAxisReversed  := not bPut;
  end;

end;

procedure TOrderTablet.SetOrientationType(const Value: TOrientationType);
var
  bPut : boolean;
  aType : TOrientationType;
begin
  FOrientationType := Value;

  if FSymbol = nil then Exit;

  bPut := false;
  if ((FSymbol is TOption) and ((FSymbol as TOption).CallPut = 'P'))
     or ((FSymbol is TELW) and ((FSymbol as TELW).CallPut = 'P')) then
     bPut := true;

  //SetPositionType( bPut );
  //  오름차순일 경우 가장 큰수가 맨끝으로
  case FOrientationType of
    otAuto:
      begin

        if Assigned( FOnOrientCount ) then
          aType := FOnOrientCount( Self );

        case aType of
          otAuto:
            begin
              SetPositionType( bPut );
              FPriceAxisReversed  := bPut;
            end;
          otAsc:
            begin
              if bPut then begin
                SetPositionType( bPut );
                FPriceAxisReversed := bPut;
              end
              else begin
                SetPositionType( bPut );
                FPriceAxisReversed := bPut;
              end;
            end;
          otDesc:
            begin
              if bPut then begin
                SetPositionType( false );
                FPriceAxisReversed := false
              end
              else begin
                SetPositionType( true );
                FPriceAxisReversed := true;
              end;
            end;
        end;
      end;
    otAsc:
      begin
        if bPut then begin
          SetPositionType( not bPut );
          FPriceAxisReversed := not bPut;
        end
        else begin
          SetPositionType( bPut );
          FPriceAxisReversed := bPut;
        end;
      end;
    otDesc:
      begin
        if bPut then begin
          SetPositionType( true );
          FPriceAxisReversed := true
        end
        else begin
          SetPositionType( not bPut );
          FPriceAxisReversed := true;
        end;
      end;
  end;

end;


//-------------------------------------------------------------------< symbol >

procedure TOrderTablet.SetSelected(const Value: Boolean);
begin
  FSelected := Value;
  Draw( odTable );
end;

procedure TOrderTablet.SetSymbol(aSymbol: TSymbol);
var
  dPrice : Double;
  dHigh, dLow : Double;
begin
  FSymbol := nil;
  FQuote := nil;
  
    // clear table
  Clear;
  
    // notify
  NotifyChanged;

    //
  if aSymbol = nil then Exit;

    //
  FSymbol := aSymbol;

    //
  SetOrientationType( FOrientationType );


    //
  MakeColumns(False);

    // generate table
  MakeTable;

    //-- 현재가/호가 index -> No draw
  UpdatePrice(False);
  UpdateQuote(False);

    //-- 현재가를 가운데로
  ScrollToCenter(FPriceIndex);

    // Point Rest
  FClickPoint.Index := -1;
  FSelectPoint.Index:= -1;
end;

procedure TOrderTablet.SetQuote(const Value: TQuote);
begin
  FQuote := Value;
end;

// param iIndex : FTable의 index
// return : Tablet상의 Y좌표 ( 중간점 )
function TOrderTablet.GetY(iIndex: Integer): Integer;
begin
  Result := FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT + HALF_HEIGHT;
end;

function TOrderTablet.GetIndex(dPrice: double): integer;
begin
  Result := FindIndex( dPrice );
end;
// 화면 구성에 종속적 
// param : X, Y 좌표
// return : TTabletPoint
function TOrderTablet.GetPoint(X, Y: Integer): TTabletPoint;
var
  i: Integer;
  aCol: TOrderColumnItem;
begin
  if FSymbol = nil then Exit;

  with Result do
  begin
    Tablet := Self;

      // X좌표가 tcGutter의 넓이보다 같거나 작으면 tcGutter-ptShort
    if X <= FColWidths[tcGutter] then
    begin
      ColType := tcGutter ;
      PositionType := FPositionTypes[stLeft];
    end else
    begin
      ColType := tcGutter ; // default

        // X좌표가 컬럼 정보를 넘어서면 tcGutter-ptLong
      if X > (FColumns.Items[FColumns.Count-1] as TOrderColumnItem).Right then
        PositionType := FPositionTypes[stRight] ;

      //
      for i:=0 to FColumns.Count-1 do
      begin
        aCol := FColumns.Items[i] as TOrderColumnItem;
        if not aCol.Visible then Continue;
        if (X >= aCol.Left) and (X <= aCol.Right) then
        begin
          ColType := aCol.ColType;
          PositionType := aCol.PositionType;
          Break;
        end;
      end;
    end;

      // Get Row Type
    if ( Y <= DEFAULT_HEIGHT * 2 ) or
       (( Y <= FViewTotCnt * DEFAULT_HEIGHT ) and ( Y > (FViewTotCnt - 2) * DEFAULT_HEIGHT )) then
      RowType := trInfo
    else if Y <= ( FViewTotCnt -2 ) * DEFAULT_HEIGHT then    // Info + Data 합친거
      RowType := trData
    else
      RowType := trETC;

      // Get Area Type
    if ColType = tcGutter then
      AreaType := taGutter
    else if RowType = trInfo then
      AreaType := taInfo
    else if RowType = trETC then
      AreaType := taEtc
    else if ColType = tcPrice then
      AreaType := taFixed
    else if ColType = tcOrder then
      AreaType := taOrder
    else if ColType = tcStop then
      AreaType := taStop
    else
      AreaType := taEtc ;

      // get index ( FTable의 index ) 
    if RowType = trData then
      Index := FEndIndex - ( Y div DEFAULT_HEIGHT ) + (FViewInfoCnt -2)  
    else
      Index := -1;

      // order volume & price 
    if (Index >= 0) and (Index < FTable.Count) then
    begin
      if AreaType = taOrder then
      begin
        Qty := Items[Index].OrderQty[PositionType];
      end
      else
        Qty := 0;
      Price := Items[Index].Price;

      if AreaType = taStop then
        StopQty := Items[index].StopQty[PositionType] + Items[index].ClearStopQty[PositionType]
      else
        StopQty := 0;
    end else 
    begin
      Qty := 0;
      Price := 0.0;
    end;
  end;
end;

// 해당 인덱스의 FTable의 Item을 반환 
function TOrderTablet.GetTableItem(i: Integer): TOrderTableItem;
begin
  if (i>=0) and (i<FTable.Count) then
    Result := FTable.Items[i] as TOrderTableItem 
  else
    Result := nil;
end;

// 해당 가격의 FTable index 
function TOrderTablet.FindIndex(dPrice: Double): Integer;
var
  i : Integer;
  bFind : boolean;
  stLog : string;
  p : TOrderTableItem;
begin
  Result := -1;
  //
  if (dPrice < FLowLimit - PRICE_EPSILON) or
     (dPrice > FHighLimit + PRICE_EPSILON) then
     begin
       //gEnv.OnLog(self, self.Symbol.Code + ' : 상하한가오류');
       Exit;
     end;
  //
  bFind := false;
  for i:=0 to FTable.Count-1 do
  with TOrderTableItem(FTable.Items[i]) do
    if Abs(Price - dPrice) < PRICE_EPSILON then
    begin
      Result := i;
      bFind := true;
      Break;
    end;


end;

// 해당 index(가격컬럼) 의 Color 구하기
function TOrderTablet.GetPriceColor(iIndex: Integer;
  dValue: Double): TColor;
var
  bkColor : TColor ; 
begin

  if iIndex = FPriceIndex then
  begin
    bkColor := clYellow;//$FF3333; //SELECTED_COLOR;
  end
  else
  begin
    // A > B : A > B + EPSILON
    // A >= B : A > B - EPSILON
    // A < B : A < B - EPSILON
    // A <= B : A < B + EPSILON

    // 고가보다 같거나 작고
    // 저가보다 같거나 크다
    if (dValue < FSymbol.DayHigh + PRICE_EPSILON) and
      (dValue > FSymbol.DayLow - PRICE_EPSILON) then
    begin

      // 종가가 시가보다 크고
      // 가격이 종가보다 작고 
      // 가격이 시가보다 같거나 크다.
      if (FSymbol.Last > FSymbol.DayOpen + PRICE_EPSILON) and
        (dValue < FSymbol.Last - PRICE_EPSILON) and
        (dValue > FSymbol.DayOpen - PRICE_EPSILON) then
          bkColor := BULL_COLOR

      // 종가가 시가보다 작고
      // 가격이 시가보다 같거나 작고
      // 가격이 종가보다 크다
      else if (FSymbol.Last < FSymbol.DayOpen - PRICE_EPSILON) and
        (dValue < FSymbol.DayOpen + PRICE_EPSILON) and
        (dValue > FSymbol.Last + PRICE_EPSILON) then
          bkColor := BEAR_COLOR
      else
          bkColor := HEADTAIL_COLOR  ;
    end
    else
    begin
      bkColor := DARKAREA_COLOR;
    end;
    
  end;
  // 
  Result := bkColor ; 

end;

function TOrderTablet.FindDrawItem(aObj: TObject): TTabletDrawItem;
var
  i : Integer;
begin
  Result := nil;
  //
  for i:=0 to FDrawItems.Count-1 do
  with FDrawItems.Items[i] as TTabletDrawItem do
    if Order = aObj then
    begin
      Result := FDrawItems.Items[i] as TTabletDrawItem;
      Break;
    end;
end;


function TOrderTablet.FindDrawItem2(aObj: TObject): TTabletDrawItem;
var
  i : Integer;
begin
  Result := nil;
  //
  for i:=0 to FDrawItems2.Count-1 do
  with FDrawItems2.Items[i] as TTabletDrawItem do
    if Order = aObj then
    begin
      Result := FDrawItems2.Items[i] as TTabletDrawItem;
      Break;
    end;

end;

function TOrderTablet.AddOrder(aOrder: TOrder) : TTabletDrawItem;
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pOrder : TOrder;
  stFindKey, stDesKey: String;
  aItem : TTabletDrawItem;
begin
  Result := nil;

  stFindkey := Format('%*n',
    [ aOrder.Symbol.Spec.Precision,
      aOrder.Price
    ] );

  iLow := 0;
  iHigh:= FDrawItems.Count-1;

  iPos := -1;

  if FDrawItems.Count = 0 then
  begin
    Result  := FDrawItems.Add as TTabletDrawItem;
    REsult.Order  := aOrder;
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pOrder := TTabletDrawItem( FDrawItems.Items[iMid] ).Order;
    if pOrder = nil then
      break;

    stDesKey := Format( '%*n',
     [ pOrder.Symbol.Spec.Precision,
       pOrder.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

  if iPos >=0 then
  begin
    Result := FDrawItems.Insert(iPos) as TTabletDrawItem;// inse .Insert(iPos, aOrder);
    REsult.Order  := aOrder;
  end;

{
  for i := 0 to FDrawItems.Count - 1 do
  begin
    aItem := TTabletDrawItem( FDrawItems.Items[i] );
    if aItem.Order <> nil then
      gEnv.DoLog( WIN_TEST, Format( '%d : %.2f', [ i, aItem.Order.Price ])  );
  end;
  gEnv.EnvLog( WIN_TEST, '' );
 }

end;


function TOrderTablet.GetOrderSum(aType: TPositionType): Integer;
begin
  Result := FOrderQtySums[aType, pvSum];
end;

procedure TOrderTablet.SetColWidth(aOrderColumnType: TTabletColumnType;
  i: Integer);
begin
  FColWidths[aOrderColumnType]:= i;
  RepositionColumns;
  // 
  Draw(odAll);
end;



procedure TOrderTablet.SetColVisible(aOrderColumnType: TTabletColumnType;
  bVisible: Boolean);
begin
  FColVisibles[aOrderColumnType] := bVisible ;
  RepositionColumns ;
  //
  Draw(odAll); 
end;


procedure TOrderTablet.SetOrderSide(aLeftPositionType: TPositionType);
var
  aRightPositionType : TPositionType ; 
begin
  if aLeftPositionType = ptLong then
    aRightPositionType := ptShort
  else
    aRightPositionType := ptLong ;
  // 
  FPositionTypes[stLeft] := aLeftPositionType ;
  FPositionTypes[stRight] := aRightPositionType ;
end;



//------------------------------------------------------------------< column >

  // add column
function TOrderTablet.AddColumn(stTitle: String; aColType: TTabletColumnType;
  aPType: TPositionType): TOrderColumnItem;
begin
  Result := FColumns.Add as TOrderColumnItem;

  with Result do
  begin
    Title := stTitle;
    PositionType := aPType;
    ColType := aColType;
    Left := 0;
    Right := 0;
    Visible := False;
    Color := clWhite; // background color
    Width := FColWidths[aColType];
  end;
end;

// Long/Short 가장 바깥쪽 컬럼 ( 사용예 : 화살표 시작점 컬럼 알기 위해 )
function TOrderTablet.GetLastColumn(aPType: TPositionType): TOrderColumnItem;
var
  i : Integer;
  aCol : TOrderColumnItem ;
begin
  Result := nil;

  if aPType = FPositionTypes[stLeft] then
    for i:=0 to FColumns.Count-1 do
    begin
      aCol := FColumns.Items[i] as TOrderColumnItem ;
      if aCol.Visible and (aCol.PositionType = aPType) then
      begin
        Result := aCol;
        Break;
      end;
    end
  else
    for i:=FColumns.Count-1 downto 0 do
    begin
      aCol := FColumns.Items[i] as TOrderColumnItem ;
      if aCol.Visible and (aCol.PositionType = aPType) then
      begin
        Result := aCol;
        Break;
      end;
    end
end;

// FColumns에서 조건에 맞는  TOrderColumnItem 찾기 
function TOrderTablet.GetColumn(aColType: TTabletColumnType;
  aPType: TPositionType): TOrderColumnItem;
var
  i : Integer;
  aCol : TOrderColumnItem ;
begin
  Result := nil;
  
  for i:=0 to FColumns.Count-1 do
  begin
    aCol := FColumns.Items[i] as TOrderColumnItem;
    if (aCol.ColType = aColType) and (aCol.PositionType = aPType) then
    begin
      Result := aCol;
      Break;
    end;
  end
end;

function TOrderTablet.GetColumn(aColType: TTabletColumnType): TOrderColumnItem;
var
  i : Integer;
  aCol : TOrderColumnItem ;
begin
   Result := nil;
  
  for i:=0 to FColumns.Count-1 do
  begin
    aCol := FColumns.Items[i] as TOrderColumnItem;
    if (aCol.ColType = aColType) then
    begin
      Result := aCol;
      Break;
    end;
  end ;
end;

function TOrderTablet.GetColWidth(aOrderColumnType: TTabletColumnType): Integer;
begin
  Result := FColWidths[ aOrderColumnType ];
end;

// FColumns에서 조건에 맞는  TOrderColumnItem 찾기
procedure TOrderTablet.RepositionColumns;
var
  i, iLeft : Integer;
  aCol : TOrderColumnItem;
  bStart, bEnd : Boolean ;
  iStart, iEnd, iWidth, iCellWidth : Integer ;
begin

  FTabletWidth := 0 ;

  iLeft := 0 ;
  bStart := false ;
  bEnd := false ;
  iStart :=0 ;
  iEnd := 0 ; 
  
  //-- reposition
  for i:=0 to FColumns.Count-1 do
  begin
    aCol := FColumns.Items[i] as TOrderColumnItem;
    aCol.Visible := FColVisibles[aCol.ColType];
    if aCol.Visible then
    begin
      aCol.Width := FColWidths[aCol.ColType];
      aCol.Left := iLeft;
      aCol.Right := iLeft + aCol.Width - 1;

      FTabletWidth := FTabletWidth + FColWidths[aCol.ColType] ;

      // 주문열 사이의 넓이를 구하기 위해서 
      if  aCol.ColType = tcOrder  then
      begin
        if bStart = true then
        begin
          iEnd := aCol.Left ;  
          bEnd := true ;
        end
        else
        begin
          iStart := aCol.Right ;  
          bStart := true ; 
        end; 
      end;

      iLeft := iLeft + aCol.Width;
    end else
      aCol.Width := 0;
  end;

  // 주문열 보이지 않을때
  if bEnd = false then
  begin
    iEnd := iLeft ;
  end;
  iWidth := iEnd - iStart ;
  iCellWidth :=  ( iWidth div 3 )  ;
  //
  FInfoLefts[itPosition] := iStart+1 ;
  FInfoWidths[itPosition] :=  iCellWidth  ;
  FInfoLefts[itAvg] := iStart + iCellWidth  ;
  FInfoWidths[itAvg] := iCellWidth  ;
  FInfoLefts[itPL] := iStart + 2* iCellWidth;
  FInfoWidths[itPL] := iWidth - 2*iCellWidth ;

end;

procedure TOrderTablet.MakeColumns(bRefresh: Boolean);
begin
    // clear
  FColumns.Clear;
    // column: left 'gutter'
  FCols[tcGutter, FPositionTypes[stLeft]] := AddColumn('',     tcGutter, FPositionTypes[stLeft]);
    // column: left 'Stop' column
  FCols[tcStop,  FPositionTypes[stLeft]] := AddColumn('STOP', tcStop, FPositionTypes[stLeft]);
    // column: left 'order' column
  FCols[tcOrder,  FPositionTypes[stLeft]] := AddColumn('주문', tcOrder, FPositionTypes[stLeft]);
    // column: left 'quote' column
  if FQuoteMerged then
  begin
    if FMergedQuoteOnLeft then
    begin
      FCols[tcCount,  FPositionTypes[stLeft]] := AddColumn('건수', tcCount, FPositionTypes[stLeft]);
      FCols[tcQuote,  FPositionTypes[stLeft]] := AddColumn('잔량', tcQuote, FPositionTypes[stLeft]);
    end;
  end else begin
    FCols[tcCount,  FPositionTypes[stLeft]] := AddColumn('건수', tcCount, FPositionTypes[stLeft]);
    FCols[tcQuote,  FPositionTypes[stLeft]] := AddColumn('잔량', tcQuote,   FPositionTypes[stLeft]);
  end;
    // column: center 'price' column
  FCols[tcPrice, FPositionTypes[stLeft]] := AddColumn('호가', tcPrice, FPositionTypes[stLeft]);
  FCols[tcPrice, FPositionTypes[stRight]] := FCols[tcPrice, FPositionTypes[stLeft]];

    // column: right 'quote' column
  if FQuoteMerged then
  begin
    if not FMergedQuoteOnLeft then
    begin
      FCols[tcQuote, FPositionTypes[stRight]] := AddColumn('잔량', tcQuote, FPositionTypes[stRight]);
      FCols[tcCount, FPositionTypes[stRight]] := AddColumn('건수', tcCount, FPositionTypes[stRight]);

      FCols[tcCount, FPositionTypes[stLeft]]  := FCols[tcCount, FPositionTypes[stRight]];
      FCols[tcQuote, FPositionTypes[stLeft]]  := FCols[tcQuote, FPositionTypes[stRight]];
    end else
    begin
      FCols[tcCount, FPositionTypes[stRight]] := FCols[tcCount, FPositionTypes[stLeft]];
      FCols[tcQuote, FPositionTypes[stRight]] := FCols[tcQuote, FPositionTypes[stLeft]];
    end;
  end else
  begin
    FCols[tcQuote, FPositionTypes[stRight]] := AddColumn('잔량', tcQuote, FPositionTypes[stRight]);
    FCols[tcCount, FPositionTypes[stRight]] := AddColumn('건수', tcCount, FPositionTypes[stRight]);
  end;
    // column: right 'order' column
  FCols[tcOrder, FPositionTypes[stRight]] := AddColumn('주문', tcOrder, FPositionTypes[stRight]);
  // column: right 'order' column
  FCols[tcStop, FPositionTypes[stRight]] := AddColumn('STOP', tcStop, FPositionTypes[stRight]);

    // column: right 'gutter' column
  FCols[tcGutter,   FPositionTypes[stRight]]  := AddColumn('',     tcGutter,   FPositionTypes[stRight]);

    // colors
  FCols[tcOrder, ptShort].Color := FOrderColor[ptShort, ctBg] ;
  FCols[tcOrder, ptLong].Color := FOrderColor[ptLong, ctBg] ;

  FCols[tcStop, ptShort].Color := FStopColor[ptShort, ctBg] ;
  FCols[tcStop, ptLong].Color  := FStopColor[ptLong, ctBg] ;

    // set position of columns
  RepositionColumns;
    // draw
  if bRefresh then
    Draw(odAll);
end;



//--------------------------------------------------------------------< table >

// make table
procedure TOrderTablet.MakeTable;
var
  dTmp, dPrice : Double;

begin
  if (FSymbol = nil) or (FSymbol.Spec = nil) then Exit;

    // clear table
  FTable.Clear;

    // set high/low limit
  if FSymbol.Spec.Market in [mtStock, mtELW] then
  begin
    FHighLimit := TicksFromPrice(FSymbol, FSymbol.Base,  100);
    FLowLimit :=  Max(TicksFromPrice(FSymbol, FSymbol.Base, - 100), 5);
  end else
  begin
    FHighLimit:= FSymbol.LimitHigh;
    FLowLimit := FSymbol.LimitLow;
  end;

    // make table
  if not FPriceAxisReversed then
  begin
    dPrice := FLowLimit;

    while True do
    begin
        // add a step
      with FTable.Add as TOrderTableItem do
      begin
        Price := dPrice;
        PriceDesc := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
      end;

        // increase one step
      dPrice := TicksFromPrice(FSymbol, dPrice, 1);

        // check upper limit
      if dPrice > FHighLimit + PRICE_EPSILON then Break;
    end;
  end else
  begin
    dPrice := FHighLimit;

    while True do
    begin
        // add step
      with FTable.Add as TOrderTableItem do
      begin
        Price := dPrice;
        PriceDesc := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
      end;

        // decrease one step
      dPrice := TicksFromPrice(FSymbol, dPrice, -1);

        // check lower limit
      if dPrice < FLowLimit - PRICE_EPSILON then Break;
    end;
  end;
end;

// ----- 2. Event

//---------------------------------------------------------< TPaintBox events >

procedure TOrderTablet.Paint(Sender: TObject);
begin
  Draw(odAll);
end;

procedure TOrderTablet.PaintLine(Sender: TObject);
begin
  DrawQuoteLine;
end;

procedure TOrderTablet.QuoteDblClick(Sender: TObject);
var
  aPoint: TPoint;
  aTabletPoint, aDummy: TTabletPoint;
begin

  if not DbClickOrder then Exit;
    // get point
  GetCursorPos(aPoint);
  //GetFocus;
  aPoint := FPaintBox.ScreenToClient(aPoint);
  aTabletPoint := GetPoint(aPoint.X, aPoint.Y);
    // do action
  case aTabletPoint.AreaType of
    taFixed: // move the double-click price to the center
      if aTabletPoint.Index > -1 then
        ScrollToCenter(aTabletPoint.Index);
    taOrder:
      if (aTabletPoint.ColType = tcOrder) and ( not FOrderRightButton ) then
      begin
        DblClick(FPaintBox);
        gLog.Add( lkKeyOrder, 'TOrderTablet', 'MouseDown', Format('Order Double Click : %.2f, %s ', [
          aTabletPoint.Price,
          ifThenStr( aTabletPoint.PositionType = ptLong, 'L', 'S' )]) ) ;
      end;
    taStop :
      begin
        DblClick(FPaintBox);
        gLog.Add( lkKeyOrder, 'TOrderTablet', 'MouseDown', Format('Stop Double Click : %.2f, %s ', [
          aTabletPoint.Price,
          ifThenStr( aTabletPoint.PositionType = ptLong, 'L', 'S' )]) ) ;
      end;

  end;

end;

procedure TOrderTablet.ActMouseMove;
var
  aPoint : TPoint;
begin
  GetCursorPos(aPoint);
  aPoint := FPaintBox.ScreenToClient(aPoint);

  MouseMove(FPaintBox, [], aPoint.X, aPoint.Y);
end;

//-------------------------------------------------------------< double click >

procedure TOrderTablet.DblClick(Sender: TObject);
var
  aPoint: TPoint;
  aTabletPoint, aDummy: TTabletPoint;
begin
    // get point
  GetCursorPos(aPoint);
  //GetFocus;
  aPoint := FPaintBox.ScreenToClient(aPoint);
  aTabletPoint := GetPoint(aPoint.X, aPoint.Y);
    // do action
  case aTabletPoint.AreaType of
    taFixed: // move the double-click price to the center
      if aTabletPoint.Index > -1 then
        ScrollToCenter(aTabletPoint.Index);
    taOrder:  // put an order
      begin

        if (aTabletPoint.Index < FStartIndex)
           or (aTabletPoint.Index > FEndIndex) then Exit;
           // new order
        if Assigned(FOnNewOrder) then
          FOnNewOrder(Self, aTabletPoint, aDummy);
      end;
    taStop :
      begin
        if (aTabletPoint.Index < FStartIndex)
           or (aTabletPoint.Index > FEndIndex) then Exit;
        if Assigned(FOnNewStopOrder) then
          FOnNewStopOrder(self, aTabletPoint, aDummy);
      end;
  end;
end;


//----------------------------------------------------------------< drag-drop >

procedure TOrderTablet.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  aPoint, aDummy: TTabletPoint;
  stLog : string;
begin
  aPoint := GetPoint(X,Y);
  FFollowAction := False;

  if  aPoint.AreaType = taOrder then
  begin
    if (aPoint.Qty > 0) then
    begin
      FFollowAction := True;
      FStartX := X;
      FStartY := Y;
      FEndX := X;
      FEndY := Y;
      FStartPoint := aPoint;
    end;

    if Button = mbRight then
    begin
      // send orders
      // 우클릭 주문이면

      if FOrderRightButton then
      begin
        DblClick(FPaintBox);

        stLog := Format('Right Click : %.2f, %s ', [
          aPoint.Price,
          ifThenStr( aPoint.PositionType = ptLong, 'L', 'S' )

        ]);
        gLog.Add( lkKeyOrder, 'TOrderTablet', 'MouseDown', stLog ) ;

        FPaintBox.PopupMenu := nil;
      end
      else   begin
        // 오른쪽 마우스 주문 취소
        if not FLastOrdCnl then
        begin
          if Assigned(FOnCancelOrder) then
            FOnCancelOrder(Self, FStartPoint, aDummy);
        end;
      end;

    end
    else if Button = mbLeft then
    begin

      if not FOrderRightButton then
      begin
        if not DbClickOrder then
        begin
          DblClick(FPaintBox);

          stLog := Format('One Click : %.2f, %s ', [
            aPoint.Price,
            ifThenStr( aPoint.PositionType = ptLong, 'L', 'S' )          ]);
          gLog.Add( lkKeyOrder, 'TOrderTablet', 'MouseDown', stLog ) ;
        end;
      end;
    end;


  end  // taOrder
  else  if (aPoint.AreaType = taStop) then
  begin
    if aPoint.StopQty > 0  then
    begin
      FFollowAction := True;
      FStartX := X;
      FStartY := Y;
      FEndX := X;
      FEndY := Y;
      FStartPoint := aPoint;
    end ;

    /////////////////////////////////////////////////////////////////

    if Button = mbRight then
    begin
      // 오른쪽 마우스 주문 취소
      if not FLastOrdCnl then
      begin
        if ( Assigned(FOnCancelStopOrder)) then
          FOnCancelStopOrder(Self, FStartPoint, aDummy);
      end;

    end
    else if Button = mbLeft then
    begin
        if not DbClickOrder then
        begin
          DblClick(FPaintBox);

          stLog := Format('One Click : %.2f, %s ', [
            aPoint.Price,
            ifThenStr( aPoint.PositionType = ptLong, 'L', 'S' )          ]);
          gLog.Add( lkKeyOrder, 'TOrderTablet', 'MouseDown', stLog ) ;
        end;
    end;

    /////////////////////////////////////////////////////////////////

  end;

  //^^**
  if Assigned(FOnSelectCell) then
     FOnSelectCell(Self, aPoint, aDummy);

  if  aPoint.AreaType in [taOrder, taStop] then
  begin
    DrawSelectCell(FSelectPoint, False);
    DrawSelectCell(aPoint, True);
    FSelectPoint := aPoint;
  end;

  if (Button = mbRight ) and ( FLastOrdCnl )  then
  begin
    if Assigned(FOnLastCancelOrder) then
      FOnLastCancelOrder(Self, FStartPoint, aDummy);

    if ( Assigned(FOnCanelLastStopOrder))  then
      FOnCanelLastStopOrder(Self, FStartPoint, aDummy);
  end;


end;


procedure TOrderTablet.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  aPoint : TTabletPoint;
  aCopyRect : TRect;
  aCol : TOrderColumnItem;
  bOldScrollLock : Boolean;
  stTmp : string;
begin

  if Assigned( FOnFocusDel ) and ( FPaintBox.Tag = 0 ) then
    FOnFocusDel( Self, FFocusOff );

  //
  aPoint := GetPoint(X,Y);
  bOldScrollLock := FScrollLock;

  // Cursor
  if  ( aPoint.AreaType in [ taOrder, taStop] ) then
  begin
    FPaintBox.Cursor := crHandPoint;
    FScrollLock := True;
  end else
  begin
    FPaintBox.Cursor := crArrow;
    FScrollLock := False
  end;

  // ScrollLock
  if bOldScrollLock <> FScrollLock then
    DrawPrice;

  //-- trace mouse moving by highlighted price
  if (aPoint.AreaType in [taOrder, taStop, taFixed]) then
  begin

    // 마우스 움직임 표시가 true 일때
    if FMouseTrace = true then
    begin
      // 가격 컬럼에 그리기
      if FCurrentPoint.Index <> aPoint.Index then
      begin
        DrawPriceCell(FCurrentPoint, False);
        DrawPriceCell(aPoint, True);
      end;

      // Data 컬럼에 그리기
      if (FCurrentPoint.Index <> aPoint.Index) or
        (FCurrentPoint.ColType <> aPoint.ColType) then
      begin
         DrawDataCell(FCurrentPoint, False);
         DrawDataCell(aPoint, True);

        if (aPoint.Index = FSelectPoint.Index) or
          (aPoint.Index = FSelectPoint.Index-1) or
          (aPoint.Index = FSelectPoint.Index+1) or
          (FCurrentPoint.Index = FSelectPoint.Index) or
          (FCurrentPoint.Index = FSelectPoint.Index-1) or
          (FCurrentPoint.Index = FSelectPoint.Index+1) then
          DrawSelectCell(FSelectPoint, true);
      end ;
      //
    end ;
    FCurrentPoint := aPoint;
    DrawQuoteLine;
  end else  // outside
  begin
    if FMouseTrace = true then
    begin
      DrawPriceCell(FCurrentPoint, False);
      DrawDataCell(FCurrentPoint, False);
      DrawQuoteLine;
    end;
    FCurrentPoint.Index := -1;
  end;

  //-- follow change or cancel
  if FFollowAction then
  begin

    if (aPoint.AreaType in [taFixed, taEtc, taInfo ]) or
       (aPoint.PositionType <> FStartPoint.PositionType) or
       ((FStartPoint.AreaType in [taOrder]) and (aPoint.AreaType = taInfo)) or
       //((FStartPoint.AreaType in [taStop]) and (aPoint.AreaType = taInfo)) or
       ((FStartPoint.ColType = tcPrice) and (aPoint.ColType = tcOrder))
       //or ((FStartPoint.ColType = tcPrice) and (aPoint.ColType = tcStop))
    then
      Exit;

///////////////////////////////
   //DarwMovingArrow( aPoint, X, Y );
////////////////////////

    DrawDataActionCell(FClickPoint, True, dcSelect);
    DrawDataActionCell(FActionPoint, False, dcTarget);
    FActionPoint := aPoint ;
    DrawDataActionCell(FActionPoint, True, dcTarget );

    //-- cancel orders
    if aPoint.AreaType in [taGutter] then
    begin
      DrawDataActionCell(FStartPoint, True, dcCancel );
    end
    //-- chance orders
    else if (FStartPoint.ColType = aPoint.ColType) and
      (FStartPoint.Index <> aPoint.Index) then
    begin
     DrawDataActionCell(FStartPoint, True, dcChange );
    end ;

    FEndX := X;
    FEndY := Y;

  end;
end;

procedure TOrderTablet.DarwMovingArrow( aPoint : TTabletPoint; X, Y: Integer );
var
  aSCol, aECol : TOrderColumnItem;
  iLeft, iRight, iTop, ibottom : integer;
  aRect : TRect;
begin
    FCanvas.Pen.width := 1;
    FCanvas.Pen.Mode := pmNot;

    FCanvas.Pen.Color:= clRed;
    FCanvas.MoveTo(FStartX, FStartY);
    FCanvas.LineTo(FEndX, FEndY);

    FCanvas.Pen.Color:= clRed;
    FCanvas.MoveTo(FStartX, FStartY);
    FCanvas.LineTo(X, Y);

    if aPoint.PositionType = FPositionTypes[stLeft] then begin
      aSCol := GetLastColumn(FPositionTypes[stLeft]);
      aECol := GetColumn(tcOrder, FPositionTypes[stLeft]);
    end
    else begin
      aSCol := GetColumn(tcOrder, FPositionTypes[stRight]);
      aECol := GetLastColumn(FPositionTypes[stRight]);
    end;

    iLeft  := aSCol.Left;
    iRight := aECol.Right;
    iTop   := FDataTop;
    iBottom := DEFAULT_HEIGHT * (FViewTotCnt-1);

    aRect :=  Rect( iLeft, iTop, iRight,  iBottom) ;
    FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
end;


procedure TOrderTablet.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  aPoint, aDummy: TTabletPoint;
  stLog : string;
begin
    // dragging mouse
  if FFollowAction then
  begin
    // Draw(odAll); // refresh
    stLog := '';


    FFollowAction := False;

      // get the information on the point
    aPoint := GetPoint(FEndX, FEndY);
      //
    if (aPoint.AreaType in [taFixed, taEtc]) or
       (aPoint.PositionType <> FStartPoint.PositionType) or
       ((FStartPoint.AreaType = taOrder) and (aPoint.AreaType = taInfo)) or
       ((FStartPoint.AreaType = taStop) and (aPoint.AreaType = taInfo))
    then
    begin
      if FFixedHoga then
      begin
        UpdatePrice( false );
        UpdateQuote;
        ScrollToLastPrice;
      end;
      Exit;
    end;


    stLog := Format('%.2f, %s ', [
            aPoint.Price,
            ifThenStr( aPoint.PositionType = ptLong, 'L', 'S' )          ]);

    if ( aPoint.AreaType in [taStop] ) and (FStartPoint.AreaType = taOrder) then
    begin
      stLog := '취소2 : ' + stLog;
      if ( FStartPoint.ColType  = tcOrder ) and  Assigned(FOnCancelOrder) then
        FOnCancelOrder(Self, FStartPoint, aDummy);
    end else
      // action to cancel orders in a cell (horizontal move)
    if aPoint.AreaType in [taGutter] then
    begin

      stLog := '취소 : ' + stLog;
      if ( FStartPoint.ColType  = tcOrder ) and  Assigned(FOnCancelOrder) then
        FOnCancelOrder(Self, FStartPoint, aDummy);

      if ( FStartPoint.ColType  = tcStop ) and ( Assigned(FOnCancelStopOrder)) then
        FOnCancelStopOrder(Self, FStartPoint, aDummy);

    end else
      // action to change orders in a cell (vertical move)
    if (FStartPoint.ColType = aPoint.ColType) and
       (FStartPoint.Index <> aPoint.Index) then
    begin
      stLog := Format('정정 : %.2f -> %s', [ FStartPoint.Price, stLog ] ) ;
      if ( FStartPoint.ColType  = tcOrder ) and Assigned(FOnChangeOrder) then
        FOnChangeOrder(Self, FStartPoint, aPoint) ;
      if ( FStartPoint.ColType  = tcStop ) and ( Assigned(FOnChangeStopOrder)) then
        FOnChangeStopOrder(Self, FStartPoint, aPoint);
    end else
      // -- etc ( drag 이면서 cancel, change 아닐때
    begin
      if Assigned(FOnSelectCell) then
        FOnSelectCell(Self, aPoint, aDummy);
    end;

    if FFixedHoga then
    begin
      UpdatePrice( false );
      UpdateQuote;
      ScrollToLastPrice;
    end;
  end else
  begin
    aPoint := GetPoint(X,Y);

    if (aPoint.AreaType = taInfo) and
      ( aPoint.ColType  = tcOrder) and
      ( aPoint.RowType  = trInfo ) then
      begin

      end;
  end;

  if stLog <> '' then
    gLog.Add( lkKeyOrder, 'TOrderTablet', 'MouseUp', stLog ) ;

    //
  if aPoint.AreaType in [taOrder, taStop ] then
  begin
    DrawDataActionCell(FClickPoint, False, dcSelect );
    DrawDataActionCell(aPoint, True, dcSelect);

    if (aPoint.AreaType in [taOrder, taStop]) and (aPoint.Index <> FSelectPoint.Index) then
      DrawSelectCell(FSelectPoint, False);

    FClickPoint :=  aPoint;
  end;
end;

procedure TOrderTablet.NewOrder;
var
  aPoint, aDummy : TTabletPoint;
begin
  if FMouseSelect then
    aPoint := FSelectPoint
  else
    aPoint := FCurrentPoint;

  case aPoint.AreaType of
    taOrder:  // put an order
      begin
        if (aPoint.Index < FStartIndex)
           or (aPoint.Index > FEndIndex) then Exit;

           // new order
        if Assigned(FOnNewOrder) then
          FOnNewOrder(Self, aPoint, aDummy);
      end;
  end;

end;

procedure TOrderTablet.NotifyChanged;
begin

  // Draw
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

// ==================== << public >> ==================== //

//
procedure TOrderTablet.Clear;
var
  i : Integer;
begin
  // created objects
  FDrawItems.Clear;
  FDrawItems2.Clear;
  FTable.Clear;

  FAskOrders.Clear;
  FBidOrders.Clear;

  // clear summary
  ResetSum;

  // drawing factors : data
  FStartIndex := -1;
  FEndIndex := -1;
  FPriceIndex := -1;
  FPrevPriceIndex := -1;

  FQuoteIndexLow  := -1;
  FQuoteIndexHigh := -1;
  FQuoteSums[ptLong] := 0;
  FQuoteSums[ptShort] := 0;
  FQuoteCntSums[ptLong] := 0;
  FQuoteCntSums[ptShort]  := 0;
  FQUoteSumsGap := 0; FQuoteCntSumsGap := 0;

  FFristQuotes[ptLong]  := -1;
  FFristQuotes[ptShort] := -1;
  FOldFristQuotes[ptLong]  := -1;
  FOldFristQuotes[ptShort] := -1;

  FLowLimit := 0 ;
  FHighLimit := 0 ;
  FMinPrice := 0 ;
  FMaxPrice := 0 ;
  FAvgPrice := 0 ;
  FEvalPL := 0 ;
  FOpenPosition := 0 ;

  //-- clear screen
  FPaintBox.Refresh;
end; 

// 
procedure TOrderTablet.MouseClear;
begin
  if FCurrentPoint.Index <> -1 then
  begin
    DrawPriceCell(FCurrentPoint, False);
    DrawDataCell(FCurrentPoint, False);
    FCurrentPoint.Index := -1;
  end;
end;

procedure TOrderTablet.SetArea(aPaintBox: TPaintBox);
var
  aRect : TRect ;
  iW : integer;
  iTop : integer;
begin

  FPaintBox := aPaintBox;
  FWidth := aPaintBox.Width;
  FHeight := aPaintBox.Height;

  FPaintLine.Width  := FWidth;
  FPaintLine.Left   := aPaintBox.Left;

  //-- clear screen
  FPaintBox.Refresh;

  with FPaintBox do
  begin
    OnDblClick := QuoteDblClick;
    OnMouseDown := MouseDown;
    OnMouseMove := MouseMove;
    OnMouseUp := MouseUp;
    OnPaint := Paint;
  end;
  //
  //FFontSize := 9;
  FBitmap.Width := FWidth;
  FBitmap.Height := FHeight;
  FCanvas := FBitmap.Canvas;
  FCanvas.Font.Name := '굴림체';
  FCanvas.Font.Size := FFontSize;
  //
  FViewTotCnt := FHeight div DEFAULT_HEIGHT  ;
  FViewInfoCnt := 4  ;  // trInfo 개수로 맞춰줌
  FViewDataCnt := FViewTotCnt - FViewInfoCnt ;
  FDataTop := 2 * DEFAULT_HEIGHT ;

  if FSymbol <> nil then
  begin
    RecalcView(FEndIndex);
    RecalcSum;
    Draw(odAll);
  end;
  //  버튼 배치...

  with PriceArrange do
  begin
    Left := FCols[tcPrice, ptShort].Left  ;
    Top  := 0;
    Width:= FCols[tcPrice, ptShort].Width ;
    Height :=  DEFAULT_HEIGHT;
  end;
  // :=
  with MarketPrcSell do
  begin
    Left := FCols[tcCount, ptShort].Left;
    Top  := DEFAULT_HEIGHT ;
    Width := FCols[tcCount, ptShort].Width +  FCols[tcQuote, ptShort].Width -1;
    Height := DEFAULT_HEIGHT;
    // 국내는...시장가 안보이게
    Visible:= false;
    Enabled:= false;
  end;

  with MarketPrcBuy do
  begin
    Left := FCols[tcQuote, ptLong].Left;
    Top  := DEFAULT_HEIGHT ;
    Width := FCols[tcCount, ptLong].Width +  FCols[tcQuote, ptLong].Width -1;
    Height := DEFAULT_HEIGHT;
    // 국내는...시장가 안보이게
    Visible:= false;
    Enabled:= false;
  end;

  //ShortStopCnl , ShortAllCnl, AllCnl, LongAllCnl, LongStopCnl
  iTop :=  DEFAULT_HEIGHT * (FViewTotCnt-1);

  with ShortStopCnl do
  begin
    Left := FCols[tcStop, ptShort].Left  ;
    Top  := iTop;
    Width:= FCols[tcStop, ptShort].Width ;
    Height :=  DEFAULT_HEIGHT;
  end;

  with ShortAllCnl do
  begin
    Left := FCols[tcOrder, ptShort].Left  ;
    Top  := iTop;
    Width:= FCols[tcOrder, ptShort].Width ;
    Height :=  DEFAULT_HEIGHT;
  end;

  with AllCnl do
  begin
    Left := FCols[tcPrice, ptShort].Left  ;
    Top  := iTop;
    Width:= FCols[tcPrice, ptShort].Width ;
    Height :=  DEFAULT_HEIGHT;
  end;


  with LongStopCnl do
  begin
    Left := FCols[tcStop, ptLong].Left  ;
    Top  := iTop;
    Width:= FCols[tcStop, ptShort].Width ;
    Height :=  DEFAULT_HEIGHT;
  end;

  with LongAllCnl do
  begin
    Left := FCols[tcOrder, ptLong].Left  ;
    Top  := iTop;
    Width:= FCols[tcOrder, ptShort].Width ;
    Height :=  DEFAULT_HEIGHT;
  end;

end;

//--------------------------------------------------------------------< quote >

procedure TOrderTablet.UpdatePrice(bDraw: Boolean);
var
  iOldIndex : Integer;

  function IsEqual( x, y : double ) : boolean;
  begin
    Result  := ((x - PRICE_EPSILON ) <= y ) and ( y <= (x + PRICE_EPSILON));
  end;

begin
  if (FSymbol = nil) or (FSymbol.Spec = nil) then Exit;

  iOldIndex := FPriceIndex;

  if FSymbol.Last > PRICE_EPSILON then
    FPriceIndex := FindIndex(FSymbol.Last)
  else
  begin
    if FSymbol.Spec.Market = mtSpread then
      FPriceIndex := FindIndex(FSymbol.Last)
    else
      FPriceIndex := FindIndex(FSymbol.Base);
  end;

  if not IsEqual( FPrevPrice, FSymbol.PrevClose ) then PrevPrice := FSymbol.PrevClose;
  if not IsEqual( FMinPrice, FSymbol.DayLow ) then MinPrice := FSymbol.DayLow;
  if not IsEqual( FMaxPrice, FSymbol.DayHigh ) then MaxPrice := FSymbol.DayHigh;

  //-- draw
  if bDraw then
  begin

    DrawPriceUpdate(Min(FPriceIndex, iOldIndex),
                    Max(FPriceIndex, iOldIndex));

  end;
end;


// QuoteProc에서 호가 들어왔을때 호출됨  
procedure TOrderTablet.UpdateQuote(bDraw: Boolean);
var
  iNewMin, iNewMax, iTotMin, iTotMax, iOldMin, iOldMax : Integer;
  aTableItem : TOrderTableItem;
  i, iQuoteIndex : Integer;
  iScrollSteps : Integer;

  // Quotes는 0을, QuoteDiffs는 (-1) * Quotes 를 넣어줌
  procedure ResetQuoteField(aColType : TTabletColumnType; aPosType : TPositionType);
  begin
    with aTableItem do
    if Quotes[aPosType] > 0 then
    begin
      QuoteDiffs[aPosType] := -Quotes[aPosType];
      Quotes[aPosType] := 0;
      QuoteCount[aPosType]  := 0;
    end;
  end;

  //
  procedure SetQuoteField(aColType : TTabletColumnType; aPosType : TPositionType;
     iValue, iCnt : Integer);
  begin
    with aTableItem do
    begin
      QuotePosition := aPosType ;   // PostionType
      Quotes[aPosType] := iValue;
      QuoteDiffs[aPosType] := QuoteDiffs[aPosType] + iValue;
      QuoteCount[aPosType] := iCnt;
    end;
  end;

begin
  //
  if (FSymbol = nil) or (FQuote = nil) then exit;

  //-- 1. reset quote fields
  if FQuoteIndexLow < FQuoteIndexHigh then
  for i := FQuoteIndexLow to FQuoteIndexHigh do
  begin
    aTableItem := Items[i];
    if aTableItem = nil then Continue;

    ResetQuoteField(tcQuote, ptLong);
    ResetQuoteField(tcQuote, ptShort);
  end;
  FQuoteSums[ptLong] := 0;
  FQuoteSums[ptShort] := 0;

  FQuoteCntSums[ptLong] := 0;
  FQuoteCntSums[ptShort]  := 0;

  FQUoteSumsGap :=0; FQuoteCntSumsGap := 0;


  //-- 2. Set new quote
  iNewMin := FTable.Count-1;
  iNewMax := 0;

  // get indices
    // BID part

  for i := 0 to FQuote.Bids.Count - 1 do
  begin
    iQuoteIndex := FindIndex(FQuote.Bids[i].Price);

    aTableItem := Items[iQuoteIndex];
    if aTableItem <> nil then
    begin
      iNewMin := Min(iNewMin, iQuoteIndex);
      iNewMax := Max(iNewMax, iQuoteIndex);
      SetQuoteField(tcQuote, ptLong, FQuote.Bids[i].Volume, FQuote.Bids[i].Cnt );
    end;

    if i = 0 then
    begin
      FOldFristQuotes[ptLong] := FFristQuotes[ptLong];
      FFristQuotes[ptLong]    := iQuoteIndex;
    end;      //

    iQuoteIndex := FindIndex(FQuote.Asks[i].Price);
    aTableItem := Items[iQuoteIndex];
    if aTableItem <> nil then
    begin
      iNewMin := Min(iNewMin, iQuoteIndex);
      iNewMax := Max(iNewMax, iQuoteIndex);
      SetQuoteField(tcQuote, ptShort, FQuote.Asks[i].Volume, FQuote.Asks[i].Cnt);
    end;

    if i = 0 then
    begin
      FOldFristQuotes[ptShort] := FFristQuotes[ptShort];
      FFristQuotes[ptShort]    := iQuoteIndex;
    end;
  end;

  FQuoteCntSums[ptShort]  := FQuote.Asks.CntTotal;
  FQuoteCntSums[ptLong ]  := FQuote.Bids.CntTotal;
  FQuoteSums[ptShort]     := FQuote.Asks.VolumeTotal;
  FQuoteSums[ptLong]      := FQuote.Bids.VolumeTotal;
  FQUoteSumsGap     := FQuoteSums[ptShort]  - FQuoteSums[ptLong];
  FQuoteCntSumsGap  := FQuoteCntSums[ptShort]- FQuoteCntSums[ptLong];
  //-- 3. Get Total min/max
  // iNewMin : 호가(매수, 매도 합쳐서) 중에서 가장 작은 FTable index
  // iNewMax : 호가(매수, 매도 합쳐서) 중에서 가장 큰 FTable index
  // FQuoteIndexLow
  // FQuoteIndexHigh
  // iTotMin :  Min(iNewMin, FQuoteIndexLow) 
  // iTotMax :  Max(iNewMax, FQuoteIndexHigh)  
  if iNewMin < iNewMax then
  begin
    if FQuoteIndexLow < FQuoteIndexHigh then
    begin
      iTotMin := Min(iNewMin, FQuoteIndexLow);
      iTotMax := Max(iNewMax, FQuoteIndexHigh);
    end else
    begin
      iTotMin := iNewMin;
      iTotMax := iNewMax;
    end; 
    iOldMin := FQuoteIndexLow;
    iOldMax := FQuoteIndexHigh;
    FQuoteIndexLow  := iNewMin;
    FQuoteIndexHigh := iNewMax;
  end else
  begin
    iOldMin := FQuoteIndexLow;
    iOldMax := FQuoteIndexHigh;
    iTotMin := FQuoteIndexLow;
    iTotMax := FQuoteIndexHigh;
  end;

  //-- 4. Check for scroll (화면 이동이 일어나는지 체크 )

  iScrollSteps := 0;
  if iNewMin <= iNewMax then
    if FAutoScroll and (not FScrollLock) then
    begin
      if (iOldMin <= FEndIndex) and (iOldMin >= FStartIndex) and
         (iOldMax <= FEndIndex) and (iOldMax >= FStartIndex) then
      begin
        if iNewMax > FEndIndex then
          iScrollSteps := iNewMax - FEndIndex
        else
        if iNewMin < FStartIndex then
          iScrollSteps := iNewMin - FStartIndex;
      end;
    end;

  //-- 5. Draw changed cell

  if bDraw then
  begin
    if iScrollSteps <> 0 then
    begin
      ScrollLine(iScrollSteps, 1);
    end
    else begin
      DrawQuoteUpdate(iTotMin, iTotMax, False);
      DrawQuoteLine;
    end;
  end;
  //--5. clear differences

  for i:=iTotMin to iTotMax do
  begin
    aTableItem := Items[i];
    if aTableItem = nil then Exit;

    aTableItem.QuoteDiffs[ptLong]  := 0;
    aTableItem.QuoteDiffs[ptShort] := 0;

    // -- QT START
    with aTableItem do
    begin
      if QTRefCounts[ptShort] > 0 then
      begin
        if (Quotes[ptShort] > 0) and
           ((Quotes[ptShort] < QTQtys[ptShort]+OrderQty[ptShort]) or
            (QTQtys[ptShort] = -1)) then
        begin
          QTQtys[ptshort] := Max(0, Quotes[ptShort]-OrderQty[ptShort]);
          DrawQT(aTableItem.Index, ptShort);
        end;
      end;

      if QTRefCounts[ptLong] > 0 then
      begin
        if (Quotes[ptLong] > 0) and
           ((Quotes[ptLong] < QTQtys[ptLong]+OrderQty[ptLong]) or
            (QTQtys[ptLong] = -1))then
        begin
          QTQtys[ptLong] := Max(0, Quotes[ptLong]-OrderQty[ptLong]);
          DrawQT(aTableItem.Index, ptLong);
        end;
      end;
    end;
    // -- QT END

  end;

end;

//--------------------------------------------------------------------< order >

procedure TOrderTablet.DoOrder(aOrder: TOrder; bDraw : boolean);
var
  aDrawItem: TTabletDrawItem;
  aTableItem : TOrderTableItem;
  iQty: Integer;
  bNew: Boolean;
begin
  if aOrder = nil then Exit;    // if not Ready the ???

    // find
  aDrawItem := FindDrawItem(aOrder);
  bNew := aDrawItem <> nil;
    // if no record, create one if the order state is proper
  if aDrawItem = nil then
  begin
    if aOrder.State in [osReady,osSent, osSrvAcpt, osActive] then
    begin
      aDrawItem := FDrawItems.Add as TTabletDrawItem;
      bNew := True;
//      AddOrder( aOrder );
    end else
      Exit
  end;

    //
  case aOrder.State of
    osReady,
    osSent,
    osSrvAcpt:
      with aDrawItem do
      begin
        Order := aOrder;
        VarQty := aOrder.OrderQty;
        Qty := 0;
        //

        case aOrder.OrderType of
          otNormal:
            begin
              GraphicType := ogNew;
              FromIndex := FindIndex(aOrder.Price);
              ToIndex := FromIndex;
              //
              PositionType := aOrder.PositionType;
              QtyActionType := oqAdd;
            end;
          otChange:
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogChange;
              QtyActionType := oqMove;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FindIndex(aOrder.Price);
            end;
          otCancel:
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogCancel;
              QtyActionType := oqSub;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FromIndex;
            end;
        end; //..case..


      end; //..with..
    osActive:
    begin
      with aDrawItem do
      begin
        Order := aOrder;
        Qty := aOrder.ActiveQty;
        VarQty := 0;
        //
        case aOrder.OrderType of
          otNormal:
            begin
              GraphicType := ogNone;
              PositionType := aOrder.PositionType;
              QtyActionType := oqAdd;
              FromIndex := FindIndex(aOrder.Price);
              ToIndex := FromIndex;

              // -- QT STart
              //--1. batch input
              if (not FReady) or (FSymbol = nil) then
              begin // batch
                QTState := qtDisabled;
                QTIndex := -1;
              end else
              //--2. genuine new order or new order from change order
              if bNew or (QTState = qtSuspended) then
              begin // new order
                QTIndex := FromIndex;
                if QTIndex >= 0 then
                begin
                  Items[QTIndex].QTQtys[aOrder.PositionType] :=
                         Max(0,
                             Items[QTIndex].Quotes[aOrder.PositionType] -
                             aOrder.ActiveQty);
                  Inc(Items[QTIndex].QTRefCounts[aOrder.PositionType]);
                  QTState := qtActive;

                  if Items[QTIndex].QTQtys[aOrder.PositionType] = 0 then
                  begin
                    if (QTIndex < FQuoteIndexLow) or (QTIndex > FQuoteIndexHigh) then
                      Items[QTIndex].QTQtys[aOrder.PositionType] := -1; // out of quote

                  end;

                  DrawQT(QTIndex, aOrder.PositionType);
                end else
                  QTState := qtDisabled;
              end;
              // -- QT END

            end;
          otChange:
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogChange;
              QtyActionType := oqMove;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FindIndex(aOrder.Price);

              // -- QT START
              QTState := qtSuspended;
              QTIndex := -1;
              // -- QT END

            end;
          otCancel :
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogCancel;
              QtyActionType := oqSub;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FromIndex;

              // -- QT START
              QTState := qtDisabled;
              QTIndex := -1;
              // -- QT END

            end;
          //if (aOrder.ActiveQty > 0 ) and ( aOrder.FilledQty > 0) then

        end;
      end; //..case..
      end;
    else
    begin
      // -- QT START
      if aDrawItem.QTState = qtActive  then
        if aDrawItem.QTIndex >= 0 then
        begin
          Dec(Items[aDrawItem.QTIndex].QTRefCounts[aDrawItem.PositionType]);
          if Items[aDrawItem.QTIndex].QTRefCounts[aDrawItem.PositionType] = 0 then
            DrawQT(aDrawItem.QTIndex, aDrawItem.PositionType);

          aTableItem := Items[aDrawItem.QTIndex];
          DrawRefresh( aOrder.PositionType, aTableItem, aDrawItem.QTIndex );
        end;
      // -- QT END
      aDrawItem.Free;

    end;
  end;

    //
  if bDraw then
    RefreshTable;

    //
  NotifyChanged;

end;


procedure TOrderTablet.DoOrder2(aOrder: TOrder);
var
  aDrawItem: TTabletDrawItem;
  aTableItem : TOrderTableItem;
  iQty: Integer;
  bNew: Boolean;
begin
  if aOrder = nil then Exit;    // if not Ready the ???

    // find
  aDrawItem := FindDrawItem(aOrder);
  bNew := aDrawItem <> nil;
    // if no record, create one if the order state is proper
  if aDrawItem = nil then
  begin
    if aOrder.State in [osReady,osSent, osSrvAcpt, osActive] then
    begin
      aDrawItem := FDrawItems.Add as TTabletDrawItem;
      bNew := True;
    end else
      Exit
  end;

    //
  case aOrder.State of
    osReady,
    osSent,
    osSrvAcpt:
      with aDrawItem do
      begin
        Order := aOrder;
        VarQty := aOrder.OrderQty;
        Qty := 0;
        //

        case aOrder.OrderType of
          otNormal:
            begin
              GraphicType := ogNew;
              FromIndex := FindIndex(aOrder.Price);
              ToIndex := FromIndex;
              //
              PositionType := aOrder.PositionType;
              QtyActionType := oqAdd;
            end;
          otChange:
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogChange;
              QtyActionType := oqMove;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FindIndex(aOrder.Price);
            end;
          otCancel:
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogCancel;
              QtyActionType := oqSub;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FromIndex;
            end;
        end; //..case..

      end; //..with..
    osActive:
      begin
      with aDrawItem do
      begin
        Order := aOrder;
        Qty := aOrder.ActiveQty;
        VarQty := 0;
        //
        case aOrder.OrderType of
          otNormal:
            begin
              GraphicType := ogNone;
              PositionType := aOrder.PositionType;
              QtyActionType := oqAdd;
              FromIndex := FindIndex(aOrder.Price);
              ToIndex := FromIndex;

              // -- QT STart
              //--1. batch input
              if (not FReady) or (FSymbol = nil) then
              begin // batch
                QTState := qtDisabled;
                QTIndex := -1;
              end else
              //--2. genuine new order or new order from change order
              if bNew or (QTState = qtSuspended) then
              begin // new order
                QTIndex := FromIndex;
                if QTIndex >= 0 then
                begin
                  Items[QTIndex].QTQtys[aOrder.PositionType] :=
                         Max(0,
                             Items[QTIndex].Quotes[aOrder.PositionType] -
                             aOrder.ActiveQty);
                  Inc(Items[QTIndex].QTRefCounts[aOrder.PositionType]);
                  QTState := qtActive;

                  if Items[QTIndex].QTQtys[aOrder.PositionType] = 0 then
                  begin
                    if (QTIndex < FQuoteIndexLow) or (QTIndex > FQuoteIndexHigh) then
                      Items[QTIndex].QTQtys[aOrder.PositionType] := -1; // out of quote

                  end;

                  DrawQT(QTIndex, aOrder.PositionType);
                end else
                  QTState := qtDisabled;
              end;
              // -- QT END

            end;
          otChange:
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogChange;
              QtyActionType := oqMove;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FindIndex(aOrder.Price);

              // -- QT START
              QTState := qtSuspended;
              QTIndex := -1;
              // -- QT END

            end;
          otCancel :
            begin
              PositionType := aOrder.Target.PositionType;
              GraphicType := ogCancel;
              QtyActionType := oqSub;
              FromIndex := FindIndex(aOrder.Target.Price);
              ToIndex := FromIndex;

              // -- QT START
              QTState := qtDisabled;
              QTIndex := -1;
              // -- QT END

            end;
          //if (aOrder.ActiveQty > 0 ) and ( aOrder.FilledQty > 0) then

        end;

      end; //..case..

    end;
    else
    begin
      // -- QT START
      if aDrawItem.QTState = qtActive  then
        if aDrawItem.QTIndex >= 0 then
        begin
          Dec(Items[aDrawItem.QTIndex].QTRefCounts[aDrawItem.PositionType]);
          if Items[aDrawItem.QTIndex].QTRefCounts[aDrawItem.PositionType] = 0 then
            DrawQT(aDrawItem.QTIndex, aDrawItem.PositionType);
        end;
      // -- QT END
      aDrawItem.Free;

    end;
  end;

    //
  //RefreshTable;

    //
  NotifyChanged;

end;


function TOrderTablet.DoStopOrderEvent(aStop: TStopOrderItem): boolean;
var
  aItem: TOrderTableItem;
  aType : TPositionType;

  aDrawItem : TTabletDrawItem;
begin
  Result := false;
  aItem := GetTableItem( aStop.Index );

  if aItem = nil then
    Exit;

  case aStop.Side of
    1 : aType := ptLong;
    -1: aType := ptShort;
    else Exit;
  end;

  if aStop.soType = soNew then
  begin
    aDrawItem := FindDrawItem2(aStop);
    if aDrawItem = nil then
      aDrawItem := FDrawItems2.Add as TTabletDrawItem;

    if aStop.MustClear then
    begin
      aItem.ClearStopQty[ aType ] := aItem.ClearStopQty[ aType ] + aStop.OrdQty;
      FClearStopQtySums[aType,pvSum] := FClearStopQtySums[aType,pvSum] + aStop.OrdQty;
    end
    else begin
      aItem.StopQty[ aType ] := aItem.StopQty[ aType ] + aStop.OrdQty;
      FStopQtySums[aType,pvSum] := FStopQtySums[aType,pvSum] + aStop.OrdQty;
    end;

    aDrawItem.StopOrder := aStop;
    aDrawItem.VarQty    := aStop.OrdQty;

    with aDrawItem do
    begin
      if aStop.Side > 0 then
        PositionType := ptLong
      else
        Positiontype := ptshort;
      GraphicType := ogChange;
      QtyActionType := oqMove;
      FromIndex := FindIndex(aStop.Price);
      ToIndex := FindIndex(aStop.TargetPrice );
    end;

  end else
  if aStop.soType = soCancel then
  begin
    if aStop.MustClear then
    begin
      aItem.ClearStopQty[ aType ] := Max( 0, aItem.ClearStopQty[ aType ] - aStop.OrdQty );
      FClearStopQtySums[aType,pvSum] := Max(0, FClearStopQtySums[aType,pvSum] - aStop.OrdQty );
    end
    else begin
      aItem.StopQty[ aType ] := Max( 0, aItem.StopQty[ aType ] - aStop.OrdQty );
      FStopQtySums[aType,pvSum] := Max(0, FStopQtySums[aType,pvSum] - aStop.OrdQty );
    end;
   {
    if FStopChange then
      FStopChangeQty := FStopChangeQty + aStop.OrdQty;
    }
    DeleteDrawItem2( aStop );

  end;

  Draw( odTable );
  DrawStopOrderSum;

  Result := true;


end;

procedure TOrderTablet.DeleteDrawItem2(aObj: TObject);
var
  i : Integer;
begin
  //
  for i:=0 to FDrawItems2.Count-1 do
  with FDrawItems2.Items[i] as TTabletDrawItem do
    if StopOrder = aObj then
    begin
      FDrawItems2.Delete(i);
      Break;
    end;

end;

procedure TOrderTablet.DrawRefresh(aPosType : TPositionType;  aTableItem : TOrderTableItem;
  iIdx : integer );
var
  iTop, iBottom : integer;
begin

  if (iIdx >= FStartIndex) and (iIdx <= FEndIndex) then
  begin
    iTop := FDataTop + (FEndIndex-iIdx) * DEFAULT_HEIGHT;
    iBottom := iTop + DEFAULT_HEIGHT;
  end;

end;

//-----------------------------------------------------------< get order list >

// (public)                \
// get orders from one or both sides
//
function TOrderTablet.GetOrders(aTypes: TPositionTypes; aList: TOrderList): Integer;
var
  i : Integer;
begin
  Result := 0;
    //
  if aList = nil then Exit;
    //
  aList.Clear;
    //
  for i:=0 to FDrawItems.Count-1 do
  with FDrawItems.Items[i] as TTabletDrawItem do
    if (GraphicType = ogNone) //ie. OrderType = otNew
       and (Order <> nil)
       and (Order.State = osActive)
       and (PositionType in aTypes) then
    begin
      aList.Add(Order);
    end;
  //
  Result := aList.Count;
end;

function TOrderTablet.GetOrders(aType : TPositionType ): TOrder;
var
  i : Integer;
  dPrice  : double;
  aOrder  : TOrder;
begin

  REsult := nil;

  if FQuote = nil then Exit;

  dPrice := 0;
  case aType of
    ptLong: dPrice := FQuote.Symbol.LimitLow;
    ptShort:dPrice := FQuote.Symbol.LimitHigh;
  end;

  if dPrice < 0.001 then Exit;

  if aType = ptLong then
  begin

    for i:=0 to FDrawItems.Count-1 do
    with FDrawItems.Items[i] as TTabletDrawItem do
      if (GraphicType = ogNone) //ie. OrderType = otNew
         and (Order <> nil)
         and (Order.State = osActive)
         and (PositionType = aType)
         {and (Order.Price < dPrice)} then
      begin
        if Order.Price > dPrice then
        begin
          Result := Order;
          dPrice := Result.Price;
        end;
      end;
  end
  else begin
    for i:=0 to FDrawItems.Count-1 do
    with FDrawItems.Items[i] as TTabletDrawItem do
      if (GraphicType = ogNone) //ie. OrderType = otNew
         and (Order <> nil)
         and (Order.State = osActive)
         and (PositionType = aType)
         {and (Order.Price < dPrice)} then
      begin
        if Order.Price < dPrice then
        begin
          Result := Order;
          dPrice := Order.Price;
        end;
      end;

  end;

end;
// (public)
// get order list from a cell in the tablet
//
function TOrderTablet.GetOrders(aPoint: TTabletPoint; aList: TOrderList): Integer;
var
  i : Integer;
  pItem : TTabletDrawItem;
begin
  Result := 0;
    //
  if aList = nil then Exit;
  aList.Clear;
    //
  case aPoint.RowType of
    trData :
      for i:=0 to FDrawItems.Count-1 do  begin
        pItem := FDrawItems.Items[i] as TTabletDrawItem;
        //with FDrawItems.Items[i] as TTabletDrawItem do
        with pItem do
          if (FromIndex = aPoint.Index)
             and (PositionType = aPoint.PositionType)
             and (Order <> nil)
             and (Order.State = osActive)
             and (GraphicType = ogNone) then //ie. OrderType = otNew
          begin
            aList.Add(Order);
          end;

      end;
  end;
    //
  Result := aList.Count;
end;

//------------------------------------------------------------------< scroll >

procedure TOrderTablet.ScrollLine(iLine, iDir: Integer);
begin
  if FSymbol = nil then Exit;
  //
  RecalcView(FEndIndex + iDir * iLine);
  RecalcSum;
  //
  ActMouseMove;
  Draw(odAll);
end;

procedure TOrderTablet.ScrollPage(iDir: Integer);
begin
  if FSymbol = nil then Exit;
  //
  RecalcView(FEndIndex + iDir * FViewDataCnt);
  RecalcSum;
  //
  ActMouseMove;
  Draw(odAll);
end;

procedure TOrderTablet.ScrollToCenter(iIndex: Integer);
begin
  if FSymbol = nil then Exit;
  //
  RecalcView( iIndex + FViewDataCnt div 2);
  RecalcSum;
  //
  ActMouseMove;
  Draw(odAll);
end;

procedure TOrderTablet.ScrollToLastPrice;
begin
  if FPaintBox = nil then Exit;
  // 현재가 고정 시  포커스 이동을 없애기 위해..
  FPaintBox.Tag := -1;
  ScrollToCenter(FPriceIndex);
  // 현재가 고정 시  포커스 이동을 없애기 위해..
  FPaintBox.Tag := 0;
end;

//----------------------------------------------------------------< avg price >

// 평균단가
procedure TOrderTablet.SetAvgPrice(dValue: Double);
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect;
begin
  if (FSymbol = nil) or (FSymbol.Spec = nil) then exit ;

  // 1. reset 
  DrawIndex(GetTickValue(FSymbol.Spec.Market, FAvgPrice), idxAvg, true) ;

  // 2. set new value
  FAvgPrice := dValue ;
  {
  // 3. trInfo행 그리기
  iLeft := FInfoLefts[itAvg]  ;
  iRight := iLeft + FInfoWidths[itAvg] ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ;
  if FSymbol.Spec.Market in [mtOption, mtFutures] then
    stText := Format('%.*n', [ FSymbol.Spec.Precision +1 , FAvgPrice])
  else
    stText := Format('%.*n', [ FSymbol.Spec.Precision , FAvgPrice]) ;

  if FOpenPosition > 0 then  //
  begin
    aBkColor := clWhite;; //SHORT_BG_COLOR ;
    aFontColor :=  clRed; //clRed
  end
  else if FOpenPosition < 0 then
  begin
    aBkColor :=clWhite ; //LONG_BG_COLOR ;
    aFontColor := clBlue; //clBlack;
  end
  else Begin
    aBkColor := clWhite;
    aFontColor := clBlack; //clBlack;
  end ;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ;
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  }
  // 4. 가격열에 Index 그리기
  DrawIndex(GetTickValue(FSymbol.Spec.Market, FAvgPrice), idxAvg, false ) ;

end;

procedure TOrderTablet.SetBottomButtons(Bot1, Bot2, Bot3, Bot4, Bot5: TPanel);
begin
  ShortStopCnl := Bot1;
  ShortAllCnl  := Bot2;
  AllCnl  := Bot3;
  LongAllCnl   := Bot4;
  LongStopCnl  := Bot5;
end;

procedure TOrderTablet.SetButtons(Top1, Top2, Top3: TPanel);
begin
  MarketPrcSell := Top1;
  PriceArrange  := Top2;
  MarketPrcBuy  := Top3;
end;

// 평가손익
procedure TOrderTablet.SetEvalPL(dValue: Double);
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect; 
begin
  // 1. value
  FEvalPL := dValue ;
  
  // 2. trInfo행 그리기
  iLeft := FInfoLefts[itPL]  ;
  iRight := iLeft + FInfoWidths[itPL] ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ; 
  stText :=  Format('%.n', [FEvalPL]) ;
  //
  aFontColor := clWhite ;
  if dValue > 0 then  //
    aBkColor := clRed
  else if dValue < 0 then
    aBkColor := clBlue
  else begin
    aBKColor := clWhite;
    aFontColor := clBlack ;
  end;
      //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;  
end;

procedure TOrderTablet.SetFontSize(const Value: integer);
begin
  FFontSize := Value;
  //FPaintBox.Canvas.Font.Size  := FFontSize;
  FCanvas.Font.Size := FFontSize;
end;

procedure TOrderTablet.SetLine(aPaintBox: TPaintBox);
begin
  FPaintLine  := aPaintBox;
  FPaintLine.Height := 1;
  FPaintLine.OnPaint := PaintLine;
end;

// 미결제 약정수량
procedure TOrderTablet.SetOpenPosition(iValue: Integer);
begin
  // 1. value
  FOpenPosition := iValue ;
end;

procedure TOrderTablet.SetPrevPrice(const Value: double);
begin
  DrawIndex(FPrevPrice, idxPrev, true) ;
  FPrevPrice := Value;
  DrawIndex(FPrevPrice, idxPrev, false) ;
end;


// ZaprService - MaxPrice 
procedure TOrderTablet.SetMaxPrice(dValue: Double);
begin
  DrawIndex(FMaxPrice, idxMax, true) ;
  FMaxPrice := dValue ;
  DrawIndex(FMaxPrice, idxMax, false) ;
end;

// ZaprService - MinPrice 
procedure TOrderTablet.SetMinPrice(dValue: Double);
begin
  DrawIndex(FMinPrice, idxMin, true) ;
  FMinPrice := dValue ;
  DrawIndex(FMinPrice, idxMin, False) ;
end;



// iIndex 와 실제 idxType의 값의 index를 구해 비교해서 같으면 true, 다르면 false  
function TOrderTablet.DrawIndexYN(iIndex: Integer;
  idxType: TIndexType): Boolean;
var
  dValue : double ;
  i : Integer ;
begin
  Result := False ;

  if (FSymbol = nil) or (FSymbol.Spec = nil) then Exit;

    //
  if idxType = idxAvg then 
    dValue := GetTickValue(FSymbol.Spec.Market, FAvgPrice) 
  else if idxType = idxMin then
    dValue := FMinPrice
  else if idxType = idxMax then
    dValue := FMaxPrice
  else if idxType = idxPrev then
    dValue := FPrevPrice;

    //
  i := FindIndex(dValue);      // get Index

    //
  if iIndex = i then
    Result := true ;
end;

// 파생상품별 TickValue
function TOrderTablet.GetTickValue(mtValue: TMarketType;
  price: Double): Double;
var
  aTickValue: Double;
begin
  Result := 0;

    //
  if (mtValue = mtOption) and ( price < 3.0-PRICE_EPSILON) then
    aTickValue := 0.01
  else
    if FSymbol <> nil then    
      aTickValue := FSymbol.Spec.TickSize
    else
      aTickValue := 0.1;

    //
  Result :=   Round(price/aTickValue+epsilon)*aTickValue;
end;

procedure TOrderTablet.InitSymbol(aSymbol: TSymbol);
var
  dPrice : Double;
  dHigh, dLow : Double;
begin
  //-- 주문표 삭제
  Clear;
  //
  NotifyChanged;
  //
  if aSymbol = nil then Exit;
  //-- 종목 할당
  FSymbol := aSymbol;
  MakeTable;
end;



{
function TOrderTablet.GetQtyIndex(aType: TQuoteType ; iRange : Integer ): Integer;
var
  dPrice : Double ;
begin
  dPrice := FSymbol.Quote.Price[aType,iRange] ;
  Result := FindIndex(dPrice);
end;
}

//--------------------------------------------------------------------< misc >

function TOrderTablet.GetOrderColor(ptType: TPositionType;
  ctType: TColorType): TColor;
begin
  Result := FOrderColor[ptType, ctType] ;
end;

function TOrderTablet.GetOrders(aPoint: TTabletPoint; aTypes: TPositionTypes;
  aList: TOrderList): Integer;
var
  i : Integer;
  pItem : TTabletDrawItem;
begin
  Result := 0;
    //
  if aList = nil then Exit;
  aList.Clear;
    //
  case aPoint.RowType of
    trData :
      for i:=0 to FDrawItems.Count-1 do  begin
        pItem := FDrawItems.Items[i] as TTabletDrawItem;

        if aPoint.PositionType = ptLong then
        begin
          if pItem.Order <> nil then
            if (pItem.PositionType = aPoint.PositionType) and
              ( pItem.Order.State = osActive ) and
              ( pItem.GraphicType = ogNone ) and
              ( pItem.Order.Price + PRICE_EPSILON >= aPoint.Price )
              then
            begin
              aList.Add(pItem.Order);
            end;
        end
        else begin

          if pItem.Order <> nil then
            if (pItem.PositionType = aPoint.PositionType) and
              ( pItem.Order.State = osActive ) and
              ( pItem.GraphicType = ogNone ) and
              ( pItem.Order.Price <= aPoint.Price + PRICE_EPSILON)then
            begin
              aList.Add(pItem.Order);
            end;

        end;
      end;
  end;
    //
  Result := aList.Count;

end;



procedure TOrderTablet.SetOrderColor(ptType: TPositionType; ctType: TColorType;
  const Value: TColor);
begin
  FOrderColor[ptType, ctType] := Value ;
end;

function TOrderTablet.GetQuoteColor(ptType: TPositionType;
  ctType: TColorType): TColor;
begin
  Result := FQuotecolor[ptType, ctType] ;
end;

function TOrderTablet.GetStopOrders(aPoint: TTabletPoint;
  aList: TList): Integer;
var
  i : Integer;
  pItem : TTabletDrawItem;
begin
  Result := 0;
    //
  if aList = nil then Exit;
  aList.Clear;
    //
  case aPoint.RowType of
    trData :
      for i:=0 to FDrawItems2.Count-1 do  begin
        pItem := FDrawItems2.Items[i] as TTabletDrawItem;
        //with FDrawItems.Items[i] as TTabletDrawItem do
        with pItem do
          if (FromIndex = aPoint.Index)
             and (PositionType = aPoint.PositionType)
             and (StopOrder <> nil)
             and (StopOrder.soType = soNew)
            { and (GraphicType = ogNone) }then //ie. OrderType = otNew
          begin
            aList.Add(StopOrder);
          end;

      end;
  end;
    //
  Result := aList.Count;

end;

function TOrderTablet.GetStopSum(aType: TPositionType): Integer;
begin
  Result := FStopQtySums[aType, pvSum] + FClearStopQtySums[ aType, pvSum];
end;

procedure TOrderTablet.SetQuoteColor(ptType: TPositionType; ctType: TColorType;
  const Value: TColor);
begin
  FQuotecolor[ptType, ctType] := Value ; 
end;

procedure TOrderTablet.ResetClick;
begin
  DrawDataActionCell(FClickPoint, False, dcSelect);
  FClickPoint.Index := -1 ;
end;

end.

