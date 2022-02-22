unit OrderTablet;

interface

uses
  Windows, Graphics, Classes, Controls, SysUtils, Math, Dialogs, ExtCtrls, Menus,
  //
  AppTypes, AppConsts, LogCentral,
  TradeCentral, OrderStore, SymbolStore, OrderHandler , CalcGreeks, AppUtils ;

type
                    
  // OrderTablet ����
  // ���� ���� 
  TOrderFieldType = (ofOrder, ofFixed, ofInfo, ofGut, ofEtc);
  // �ֹ�, �ܷ�, ����, ����, �ΰ�����, IV 
  TOrderColumnType = ( ocOrder, ocQty, ocPrice, ocGut,
    ocAdded {AddedService}, ocIV ) ;
  // ����, �ֹ�����~��
  TOrderRowType = ( orInfo , orData, orEtc);
  // ���� �÷� ���� ǥ�� ���� 
  TIndexType = (idxMin{Min}, idxMax{Max}, idxAvg{Avg});
  // orInfo ǥ�� ������ Ÿ��
  TInfoType = ( itAvg {AvgPrice}, itPosition {OpenPosition}, itPL {EvalPL} ) ;

  // �� ���� ����
  TDataCellType = ( dcSelect, dcCancel, dcChange, dcTarget ); 

  // ���� ����
  TOrderDataType = (odOrder, odOrderReq );
  TOrderGraphicType = (ogNone, ogNew, ogChange, ogCancel );
  TOrderQtyActionType = (oqAdd, oqMove, oqSub);
  TOrderDrawMode = (odQuote, odPrice, odTable, odAll);

  // ���ݿ� ���� : ��������, ��������, �ڵ� 
  TPriceOrderbyType = ( poAsc, poDesc, poAuto ) ;
  // ���ݿ� ���� ���� ������
  TSideType = ( stLeft, stRight );

  // ���ÿ��� ���� : ���ÿ������� ��, ���ÿ���, ��, ��ü
  TPriceVisibleType = ( pvUp, pvVisible, pvDown, pvSum );

  //  QT ���� 
  TOrderQTState = (qtDisabled, qtSuspended, qtActive, qtOutOfQuote);

  // ���ݿ� ���� ���� ������
  TColorType = ( ctBg, ctFont );

  // -- Tablet������ ��ġ
  TOrderPoint = record
    Index : Integer;
    PositionType : TPositionType;
    FieldType : TOrderFieldType;
    ColType : TOrderColumnType;
    RowType : TOrderRowType;
    Qty : Integer;
    Price : Double;
  end;

  // -- �ֹ�(TOrderItem) , �ֹ���û(TOrderReqItem) �׸��� ������
  TOrderDrawItem = class(TCollectionItem)
  public
    Target : TObject;  // TOrderItem/TOrderReqItem
    //
    DataType : TOrderDataType;           // order/orderreq
    GraphicType : TOrderGraphicType;     // none/new/change/cancel
    PositionType : TPositionType;     // long/short
    QtyActionType : TOrderQtyActionType; // add/move/sub
    FromIndex : Integer;
    ToIndex : Integer;
    Qty : Integer;

    QTState : TOrderQTState ;
    QTIndex : Integer;
  end;

  // -- ���ݿ� ( ocPrice ) ������
  TOrderTableItem = class(TCollectionItem)
  public
    Price : Double;
    PriceDesc : String;
    OrderQty,OrderVar :  array[TPositionType] of Integer ;
    Quotes,QuoteDiffs : array[TPositionType ] of Integer;
    QuotePosition : TPositionType ;     // ������ �ܷ� Position ( �ܷ� ���ս� ��� )

    // -- �����ܷ� ���� ������ 
    QTRefCounts, 
    QTQtys : array[TPositionType] of Integer;

    // -- IV
    FIV : Double ; 
  end;

  // -- �÷� ( ocPrice, ocOrder.. ) ����
  TOrderColumnItem = class(TCollectionItem)
  public
  public
    Title : String;
    Width : Integer;
    Left, Right : Integer;
    ColType : TOrderColumnType;
    PositionType : TPositionType;
    Visible : Boolean;
    Color : TColor ;
  end;

  // Event
  TOrderNotifyEvent =
    procedure(aPoint1, aPoint2 : TOrderPoint; aSideType : TSideType) of Object;

  TOrderListEvent =
    procedure(aSide : TSideType ; aSymbol : TSymbolItem ; aList : TList ; aPoint : TOrderPoint ) of Object ;


  // ��� ��Ģ
  // Index : start~ , end~
  // ���� : top~, bottom~
  // ���̰�/�Ⱥ��̰� : Visible Y/N
  // ����/�Ұ��� : Enable - Enable
  // ���� : Trace - MouseTrace
  // �̺�Ʈ : ��ü + Action - MouseUp
  // �Ϲ� �޼ҵ� : Action + ��ü  - DrawTable
  // Data Type : �빮�ڷ� ����
  // TCollection, TList, Array : -s ������
  // �ʱ�ȭ : Reset
  // �ʱ�ȭ �� �ٽ� �׸��� : RefreshXXX

  // ��ǥ�� index ���� ���� 
  // FViewTotCnt := FHeight div DEFAULT_HEIGHT  ;
  // FViewInfoCnt := 1 // orInfo ������ ������  
  // FViewDataCnt := FViewTotCnt - FViewInfoCnt ;
  // FDataTop := FViewInfoCnt * DEFAULT_HEIGHT ;  
  // FEndIndex := Max(FViewDataCnt-1  ,Min(FTable.Count-1, iToIndex));
  // FStartIndex := Max(FViewDataCnt - FViewCount + 1 , 0);
  // Y := FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT + HALF_HEIGHT;  
  // iTop :=  FDataTop + (FEndIndex-i ) * DEFAULT_HEIGHT;   

  
  TOrderTablet = class
  private

    // ----- << Variables >> ----- // 
    
    // -- 1. General Data Type 
    // 1.1 Flag
    FPriceOrderby : TPriceOrderbyType ;   // ���� ���� Ÿ�� ( ��������, �������� )
    FQtyMerge : Boolean ;                 // �ܷ� �÷� ����
    FFollowAction : Boolean ; // ofData MouseDown : True, MouseUp : false
    FOrderRightButton : Boolean ; // ���콺 ������ ��ư���� �ֹ� ����
    FMouseTrace : Boolean ;       // ���콺 ������ ǥ���ϱ� ( ���ݿ���  �ش� PositionType�� �ֹ��� )  

    FVisibleQT : Boolean ;        // �����ܷ�
    
    // 1.2 Data
    FSideType : TSideType ;   // Tablet �ڽ��� ��ġ
    FQtyMergeSide : TSideType  ;   // �ܷ����ս� �ܷ��� ��ġ (���ݿ� ���� �¿� )

    
    FReady : Boolean ;                  //
    FLowLimit, FHighLimit : Double ;    // ���Ѱ�, ���Ѱ�
    FMinPrice, FMaxPrice : Double ;     // Min, Max
    FAvgPrice, FEvalPL  : Double ;      // ��մܰ� , �򰡼���
    FOpenPosition : Integer ;           // �̰����������� 

    // 1.3 View
    // data ���� ( orData : TOrderRowType ) �׸��� ����/�� ��ǥ
    FDataTop, FDataBottom : Integer ;
     // ���ÿ��� Data(orData) row ����, Info row ����
    FViewTotCnt, FViewDataCnt, FViewInfoCnt : Integer ;

    // ���� ���� FTable�� index
    // �������� StartIndex < EndIndex , Price(StartIndex) < Price(EndIndex)
    // �������� StartIndex < EndIndex , Price(StartIndex) > Price(EndIndex)
    FStartIndex, FEndIndex : Integer ;  
    FPriceIndex : Integer ;   // ���� index
    FFirstQuoteIndex : Integer ;  // ��1ȣ��  
    FQuoteIndexLow,FQuoteIndexHigh : Integer ;  // ȣ�� 
    // MouseDown, MouseMove ��ġ
    FStartX, FEndX, FStartY, FEndY : Integer ;
    // Tablet ����, ����
    FWidth, FHeight : Integer ;
    FTabletWidth : Integer ;
    // Scroll
    FScrollSize : Integer ;
    FAutoScroll, FScrollLock : Boolean ;

    // -- 2. Object
    // 2.1 TCollection 
    FTables : TCollection ;     // TOrderTableItem
    FDrawItems : TCollection ;  // TOrderDrawItem
    FColumns : TCollection ;    // TOrderColumnItem

    // 2.2 array
    FColWidths : Array[TOrderColumnType] of Integer ;
    FColVisibles : Array[TOrderColumnType] of Boolean ;
    FCols : Array[TOrderColumnType, TPositionType] of TOrderColumnItem ;
    FOrderQtySums : Array[TPositionType, TPriceVisibleType] of Integer ;  // �ֹ�
    FQuoteSums : Array[TPositionType] of Integer ;   // ȣ�� - �ܷ�

    FOrderPostion :array[TSideType] of TPositionType ;  // �ֹ��� �¿� Position ��ġ

    FInfoLefts : Array[TInfoType] of Integer ;      // ������ ������ ���� ��ǥ
    FInfoWidths :  Array[TInfoType] of Integer ;    // ������ ������ ���� 
    
    // 2.3 General Object
    FSymbol : TSymbolItem;
    FPaintBox : TPaintBox;
    FCanvas : TCanvas;
    FBitmap : TBitmap;
    FCurrentPoint, FStartPoint : TOrderPoint ;
    FClickPoint, FActionPoint : TOrderPoint ;

    // 2.4 Menu
    FPopOrders: TPopupMenu;
    
    // 2.5 Event
    FOnChanged : TNotifyEvent ;
    FOnNewOrder, FOnChangeOrder, FOnCancelOrder : TOrderNotifyEvent ;
    FTabletColor: TColor;
    // 2007.05.24 YHW : �ֹ� ����Ʈ
    FOnOrderList : TOrderListEvent ;

    // 2007.03.19 Color
    FQuoteColor : array [TPositionType,TColorType] of TColor ;
    FOrderColor : array [TPositionType,TColorType] of TColor ;

    // 2007.05.25 IV
    FIVU , FIVE , FIVR , FIVT , FIVTC , FIVW : Double ;

    // ----- << Method >> ----- // 

    // 1. General
    // 1.1 Draw

    // TOrderColumnItem ������ ������ Rect�� ����� �׷���
    // ( bCopy : FPaintBox.Canvas copy ���� )
    procedure DrawCell(aCol : TOrderColumnItem; iTop, iBottom : Integer;
      BkColor : TColor; Text: String;
      FontColor: TColor = clBlack;
      Alignment : TAlignment = taRightJustify;
      bCopy : Boolean = False);
    // Rect�� �Ķ���ͷ� �޾� Rect�� �׸�
    procedure DrawRect(Rect : TRect; Text : String;
      BkColor, FontColor : TColor; Alignment : TAlignment);
    // ȭ��ǥ �׸���
    procedure DrawArrow(aItem : TOrderDrawItem);
    // ���� ���� ���콺 ǥ�� 
    procedure DrawPriceCell(aPoint : TOrderPoint; bHighlighted : Boolean);
    // ������(�ֹ�) ���� ���콺 ǥ��
    procedure DrawDataCell(aPoint : TOrderPoint; bHighlighted : Boolean);
    procedure DrawDataActionCell(aPoint : TOrderPoint;
      bHighlighted : Boolean; aCellType :  TDataCellType );

    // ������ �׸���
    procedure DrawInfoCell(aRect : TRect;
      stText : String ; aBkColor, aFontColor : TColor ) ;
    // �ֹ��հ� �׸���
    procedure DrawOrderSum ;
    procedure DrawInfoRow ; 

    // ���� �׸���
    procedure DrawGrid;
    // ���ÿ��� ���� �÷� �׸���   
    procedure DrawPrice; 
    // Draw Price Cell  
    procedure DrawPriceUpdate(iMinIndex, iMaxIndex : Integer);
    // ȣ�� �׸���  
    procedure DrawQuote;
    // Draw Quote Cell
    procedure DrawQuoteUpdate(iMinIndex, iMaxIndex : Integer; bRefresh : Boolean);
    // �ֹ� �÷� �׸��� 
    procedure DrawTable;

    // �����ܷ� 
    procedure DrawQT(iIndex : Integer; aPosType : TPositionType);
    // ���� �÷��� ���� ǥ��  
    procedure DrawIndex( dValue: Double; idxType : TIndexType; bErase :Boolean=True );  
    procedure DrawMAX(aRect : TRect);
    procedure DrawMIN(aRect : TRect);
    procedure DrawAvg(aRect : TRect);

    // DrawInfo
    // TOrderDrawMode�� ���� �׸��� �Լ� ȣ��  
    procedure Draw(aMode : TOrderDrawMode);
   
    // 1.2 Calculate/Reset
    // ���ÿ��� 
    procedure RecalcView(iToIndex : Integer); 
    // �ֹ��� 
    procedure ResetSum;
    procedure RecalcSum;
    // �ֹ�ǥ  
    procedure ResetTable;
    procedure RecalcTable;
    // �ֹ�ǥ, �ֹ���, �ֹ� �׸��� 
    procedure RefreshTable;


    // 1.3 Set/Get
    procedure SetSymbol(aSymbol : TSymbolItem);
    // ������ �������� index�� �Ķ���ͷ� ������ �ش� Y ��ǥ(�߰���)�� ���� 
    function GetY(iIndex : Integer) : Integer;
    // ���ݿ� �ش��ϴ� FTables�� index 
    function FindIndex(dPrice : Double) : Integer;
    // �ش� �ε����� FTables�� Item�� ��ȯ 
    function GetTableItem(i:Integer) : TOrderTableItem;
    // ���� ���� Color ���ϱ� 
    function GetPriceColor( iIndex : Integer; dValue : Double) : TColor ;
    //
    function FindDrawItem(aObj : TObject) : TOrderDrawItem;
    // Property 
    function GetOrderSum(aType : TPositionType) : Integer;
    //
    procedure SetColWidth(aOrderColumnType: TOrderColumnType; i : Integer);
    procedure SetColVisible(aOrderColumnType: TOrderColumnType; bVisible : Boolean);
    // aPositionType : ���ʿ� PositionType
    procedure SetOrderSide(aLeftPositionType : TPositionType);
    
    // ��մܰ� : AvgPrice
    procedure SetAvgPrice(dValue : Double ) ;
    // �򰡼��� : EvalPL
    procedure SetEvalPL(dValue : Double) ;
    // �̰����������� : OpenPositions
    procedure SetOpenPosition(iValue : Integer ); 
    // MinPrice
    procedure SetMinPrice(dValue : Double) ; 
    // MaxPrice
    procedure SetMaxPrice(dValue : Double) ; 

    // ���ݿ��� Index�� �׷��� ���� ���� 
    function DrawIndexYN( iIndex : Integer ; idxType : TIndexType ) : Boolean;   
    // Tick Value
    function GetTickValue( dType:TDerivativeType ; price:Double ) : Double;

    // 1.4 Column
    // FColumns�� �߰�
    function AddColumn(stTitle : String; aColType : TOrderColumnType ;
      aPType : TPositionType) : TOrderColumnItem  ;
    // Long/Short ���� �ٱ��� �÷� ( ��뿹 : ȭ��ǥ ������ �÷� �˱� ���� )
    function GetLastColumn(aPType : TPositionType) : TOrderColumnItem ;  
    // FColumns���� ���ǿ� �´�  TOrderColumnItem ã��
    function GetColumn(aColType : TOrderColumnType;
      aPType : TPositionType) : TOrderColumnItem ; overload;
    function GetColumn(aColType : TOrderColumnType) : TOrderColumnItem ; overload;
    // �÷� ������ ���� : Visible�� ���� Width, Left, Right ���� 
    procedure RepositionColumns;
   
    // 2. Event
    procedure MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Paint(Sender: TObject);
    procedure DblClick(Sender: TObject);
    procedure ActMouseMove;

    procedure NotifyChanged;
    function GetQtyIndex(aType: TQuoteType; iRange: Integer): Integer;

    function GetOrderColor(ptType: TPositionType; ctType: TColorType): TColor;
    function GetQuoteColor(ptType: TPositionType; ctType: TColorType): TColor;
    procedure SetOrderColor(ptType: TPositionType; ctType: TColorType;
      const Value: TColor);
    procedure SetQuoteColor(ptType: TPositionType; ctType: TColorType;
      const Value: TColor);



  public
    constructor Create; 
    destructor Destroy; override;

    procedure Clear;
    procedure MouseClear;
    procedure InitSymbol(aSymbol : TSymbolItem); 
    
    procedure SetArea(aPaintBox : TPaintBox);
    procedure UpdatePrice(bDraw : Boolean = True); 
    procedure UpdateQuote(bDraw : Boolean = True);
  
    procedure DoOrder(aOrder: TOrderItem; bNew: Boolean);
    procedure DoOrderReq(aOrderReq : TOrderReqItem; bNew : Boolean);

    function GetOrders(aList : TList; aTypes : TPositionTypes) : Integer; overload;
    function GetOrders(aList : TList; aPoint : TOrderPoint) : Integer; overload;
    // X,Y��ǥ�� ������ TOrderPoint�� ���� ( ���� ����� �����ؾ� �� �κ� ) 
    function GetPoint(X, Y : Integer) : TOrderPoint;
    
    procedure MoveToCenter(iIndex : Integer);
    procedure MoveToPrice;
    procedure MovePage(iDir : Integer);
    procedure MoveLine(iLine, iDir : Integer);

    // aLeftPostiionType : �ֹ����� �ż�,�ŵ� ��ġ, ���ݿ� ���� ������ Position 
    // bLeft: ocAdded�� ���ݿ� ���� ��ġ - �����̸� true
    // bQtyMerge : ȣ�� ���� 
    // bRefresh : �ٽ� �׸���
    procedure RefreshColumns(aLeftPostiionType:TPositionType ; bLeft :Boolean ;
      bQtyMerge : Boolean ; aSide : TSideType ; bRefresh : Boolean );  
    // FTables Clear �� �ٽ� add
    procedure RefreshTableItem ;

    property TabletWidth : Integer read FTabletWidth  ; 
    property TabletSide : TSideType read FSideType write FSideType ; 
    property Ready : Boolean read FReady write FReady;
    property Symbol : TSymbolItem   read FSymbol write SetSymbol;
    property Items[i:Integer] : TOrderTableItem read GetTableItem; default;
    property OrderSum[aType:TPositionType] : Integer read GetOrderSum;
    property MouseTrace : boolean read FMouseTrace write FMouseTrace ;
    property OrderRightButton : Boolean read FOrderRightButton write FOrderRightButton ;

    property OnChanged : TNotifyEvent read FOnChanged write FOnChanged;
    property OnNewOrder : TOrderNotifyEvent read FOnNewOrder write FOnNewOrder;
    property OnChangeOrder : TOrderNotifyEvent read FOnChangeOrder write FOnChangeOrder;
    property OnCancelOrder : TOrderNotifyEvent read FOnCancelOrder write FOnCancelOrder;

    property OnOrderList : TOrderListEvent read FOnOrderList write FOnOrderList ;

    property PopOrders : TPopupMenu read FPopOrders write FPopOrders;

    property ColVisibles[aOrderColumnType: TOrderColumnType] : boolean write SetColVisible ;
    property ColWidths[aOrderColumnType: TOrderColumnType] : Integer write SetColWidth;
    property PriceOrderby : TPriceOrderbyType read FPriceOrderby write FPriceOrderby ;

    property AvgPrice : Double read FAvgPrice write SetAvgPrice ;
    property EvalPL : Double read FEvalPL write SetEvalPL ;
    property OpenPosition : Integer read FOpenPosition write SetOpenPosition;
    property MinPrice : Double read FMinPrice write SetMinPrice ;
    property MaxPrice : Double read FMaxPrice write SetMaxPrice ; 

    property VisibleQT : Boolean read FVisibleQT write FVisibleQT;
    property AutoScroll : Boolean read FAutoScroll write FAutoScroll;

    // �۾��ڵ� :  UD_JB_001
    // ������ : �����
    // �������� : 06/11/27
    property TabletColor : TColor read FTabletColor write FTabletColor;

    property QuoteColor[ptType : TPositionType ; ctType : TColorType] : TColor read GetQuoteColor write SetQuoteColor ;
    property OrderColor[ptType : TPositionType ; ctType : TColorType] : TColor read GetOrderColor write SetOrderColor ;

    // IV �׸���
    procedure DrawIV(U , E , R , T , TC , W : Double);
    procedure ResetClick ; 

  end;


const
  // column�� ����
  ORDER_WIDTH = 55;       // �ֹ� ����
  QTY_WIDTH = 55 ;        // ȣ��(�ܷ�)����
  PRICE_WIDTH = 60;       // ���� ����
  PRICE_WIDTH_WIDE = 80;  // ȣ�� ���� ���� 
  ADDED_WIDTH = 55 ;  // �ΰ� ���� ����
  IV_WIDTH = 55 ;     // IV  ���� 
  GUT_WIDTH = 5 ;     // Gut ����

  OrderFieldTypeDescs : array[TOrderFieldType] of String =
                 ('�ֹ�', 'Fixed', '����' , 'Gut', '��Ÿ' );
  OrderColumnTypeDescs : array[TOrderColumnType] of String =
                 ('�ֹ�', '�ܷ�', '����' , 'Gut', '�ΰ�����', 'IV' );
  OrderRowTypeDescs : array[TOrderRowType] of String =
                 ('����', '������', '��Ÿ');
  SideTypeDescs : array[TSideType] of String =
                ( 'Left' , 'Right'   );

  FRAME_COLOR : array[TSideType] of TColor =
    ( clNavy , clRed ) ;
  FRAME_WIDTH = 2 ;

implementation

const

  DEFAULT_HEIGHT = 16;
  HALF_HEIGHT = 8 ;
 
  // �ֹ� ȭ��ǥ 
  GAP = 5;
  EAR_WIDTH = GAP-1;
  HALF_GAP = 2;

  // ���� �÷��� ���� ǥ���� ���� 
  INDEX_LEFT = 1 ;
  INDEX_RIGHT = 7 ;
  
  // Double Order���� ����ϴ� Color
  // Data Cell Frame Color 
  GRID_COLOR = clLtGray ;
  MOUSE_COLOR = clRed ;

  CANCEL_COLOR = $FF0080 ;
  CHANGE_COLOR = $00FF00 ;
  TARGET_COLOR = clBlack ;
  SELECT_COLOR = clRed ; 

  // Font Color 
  SELECTED_FONT_COLOR = clWhite ;
  UNSELECTED_FONT_COLOR = clBlack ;
  // Price Cell Color
  DARKAREA_COLOR = clLtGray ;
  BULL_COLOR = LONG_COLOR ;
  BEAR_COLOR = SHORT_COLOR ;
  HEADTAIL_COLOR = clWhite ;

{ TOrderTablet }


// ==================== << private >> ==================== //

// ----- 1.1 Draw

// TOrderColumnItem ����(Left,Right)�� �Ķ��������( Top, Bottom)�� ������ Rect�� ����� �׷���
// ( bCopy : FPaintBox.Canvas copy ���� ) 
procedure TOrderTablet.DrawCell(aCol: TOrderColumnItem ; iTop,
  iBottom: Integer; BkColor: TColor; Text: String; FontColor: TColor;
  Alignment: TAlignment; bCopy: Boolean);
var
  iX, iY : Integer;                                     
  aSize : TSize;
  aTextRect : TRect;
begin
  FCanvas.Brush.Color := BkColor;
  FCanvas.Font.Color := FontColor;

  aTextRect := Rect(aCol.Left, iTop, aCol.Right, iBottom);
  FCanvas.FillRect(aTextRect);

  if Text <> '' then
  begin
    aSize := FCanvas.TextExtent(Text);
    iY := aTextRect.Top + (aTextRect.Bottom-aTextRect.Top-aSize.cy) div 2;
    case Alignment of
      taLeftJustify :  iX := aTextRect.Left + 2;
      taCenter :       iX := aTextRect.Left + (aTextRect.Right-aTextRect.Left-aSize.cx) div 2;
      taRightJustify : iX := aTextRect.Left + aTextRect.Right-aTextRect.Left-aSize.cx - 2;
    end;
    //
    FCanvas.TextRect(aTextRect, iX, iY, Text);
  end;

  if bCopy then
    FPaintBox.Canvas.CopyRect(aTextRect, FCanvas, aTextRect);

end;

// Rect�� �Ķ���ͷ� �޾� Rect�� �׸�
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

// ȭ��ǥ �׸��� 
procedure TOrderTablet.DrawArrow(aItem: TOrderDrawItem);
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
  //
  FCanvas.Pen.Mode := pmCopy;
  case aItem.DataType of
    odOrder :    aColor := clGreen;
    odOrderReq : aColor := clRed;
    else
      Exit;
  end;
  FCanvas.Pen.Color := aColor;
  FCanvas.Brush.Color := aColor;
  // get points
  iSY := GetY(aItem.FromIndex);
  iEY := GetY(aItem.ToIndex);

  if aItem.PositionType = FOrderPostion[stLeft] then
  begin
        case aItem.GraphicType of
          ogNew :    begin
                       aSCol := GetLastColumn(FOrderPostion[stLeft]);
                       aECol := GetColumn(ocOrder, FOrderPostion[stLeft]);
                       iSX := aSCol.Left + 1;
                       iEX := Min(aECol.Left + GAP, aECol.Right);
                     end;
          ogChange : begin
                       aECol := GetColumn(ocOrder, FOrderPostion[stLeft]);
                       iSX := Min(aECol.Left + GAP, aECol.Right);
                       iEX := iSX;
                     end;
          ogCancel : begin
                       aSCol := GetColumn(ocOrder, FOrderPostion[stLeft]);
                       aECol := GetLastColumn(FOrderPostion[stLeft]);
                       iSX := Min(aSCol.Left+GAP, aSCol.Right);
                       iEX := aECol.Left + 1;
                     end;
        end;
  end
  else 
    begin 
      case aItem.GraphicType of
        ogNew :   begin
                    aSCol := GetLastColumn(FOrderPostion[stRight]);
                    aECol := GetColumn(ocOrder, FOrderPostion[stRight]);

                    iSX := aSCol.Right - 3;
                    iEX := aECol.Right;
                  end;
        ogChange :begin
                    aECol := GetColumn(ocOrder, FOrderPostion[stRight]);
                    iSX := Min(aECol.Left + GAP, aECol.Right);
                    iEX := iSX;
                  end;
        ogCancel :begin
                    aSCol := GetColumn(ocOrder, FOrderPostion[stRight]);
                    aECol := GetLastColumn(FOrderPostion[stRight]);
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
end;


procedure TOrderTablet.DrawDataActionCell(aPoint: TOrderPoint;
  bHighlighted: Boolean; aCellType: TDataCellType);
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
  aColor : TColor ; 
begin

  if (FPaintBox = nil) or (FSymbol = nil) then Exit;
  if (aPoint.Index < FStartIndex) or (aPoint.Index > FEndIndex) then Exit;
  
  iTop :=  FDataTop + (FEndIndex - aPoint.Index ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;
  // 
  if aCellType = dcCancel then
    aColor := CANCEL_COLOR
  else if aCellType = dcChange then
    aColor := CHANGE_COLOR
  else if aCellType = dcTarget then
    aColor := TARGET_COLOR
  else if aCellType = dcSelect then
    aColor := SELECT_COLOR ;    

  
  if (aPoint.ColType in [ocOrder]) then
  begin

    aColumn := GetColumn(aPoint.ColType, aPoint.PositionType);
    if aColumn <> nil then
    with FCanvas do
    begin

      aRect := Rect(aColumn.Left-1 , iTop  , aColumn.Right + 1  , iBottom + 1 );
      // 
      if  bHighlighted then
        Brush.Color := aColor
      else
        Brush.Color := GRID_COLOR ;
      // 
      FrameRect(aRect);
      FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
    end ; 

 

  end;
  
end;

// �ֹ����� : ofOrder   
procedure TOrderTablet.DrawDataCell(aPoint: TOrderPoint;
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

  if not FFollowAction and (aPoint.ColType in [ocOrder]) then
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
      FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
      
    end;
  end;
end;

// Price ���� : ocPrice & ofFixed 
procedure TOrderTablet.DrawPriceCell(aPoint: TOrderPoint;
  bHighlighted: Boolean);
var
  aPriceCol, aColumn : TOrderColumnItem;
  iTop, iBottom : Integer;
  aRect : TRect;
begin

  if (FPaintBox = nil) or (FSymbol = nil) then Exit;
  if (aPoint.Index < FStartIndex) or (aPoint.Index > FEndIndex) then Exit;

  //-- price
  aPriceCol := GetColumn(ocPrice);
  
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
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);

end;

// �ֹ� �հ� �׸��� 
procedure TOrderTablet.DrawOrderSum;
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect;  
begin

  if FColVisibles[ocOrder] = false then exit ; 

  // Gut - ptShort
  iLeft := FCols[ocGut, ptShort].Left  ;
  iRight := FCols[ocGut, ptShort].Right +1  ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ;
  aBkColor := clWhite ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  // Gut - ptLong 
  iLeft := FCols[ocGut, ptLong].Left  ;
  iRight := FCols[ocGut, ptLong].Right +1  ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ;
  aBkColor := clWhite ;
  aFontColor := clBlack;
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  // Order - �ŵ�
  iLeft := FCols[ocOrder, ptShort].Left  ;
  iRight := FCols[ocOrder, ptShort].Right +1  ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ; 
  stText := IntToStr(OrderSum[ptShort]); 
  // 
  aBkColor := SHORT_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  
  // Order - �ż�
  iLeft := FCols[ocOrder, ptLong].Left  ;
  iRight := FCols[ocOrder, ptLong].Right +1  ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ; 
  stText := IntToStr(OrderSum[ptLong]); 
  // 
  aBkColor := LONG_COLOR ;
  aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;
  
end;


procedure TOrderTablet.DrawInfoRow;
begin
  SetAvgPrice(FAvgPrice);
  SetEvalPL(FEvalPL);
  SetOpenPosition(FOpenPosition);
  // 
  DrawOrderSum ;
end;



procedure TOrderTablet.DrawIV(U , E , R , T , TC , W : Double);
var
  aIV, dPrice : Double ;
  i : Integer ;
  iTop,  iBottom : Integer ;
  iRectTop, iRectBottom : Integer ;
  aFontColor, aBkColor : TColor ;
  aCopyRect : TRect;
  aCol : TOrderColumnItem ;
  stText : String ;
begin

  aCol := GetColumn( ocIV ) ;

  FIVU := U ;
  FIVE := E ;
  FIVR := R ;
  FIVT := T ;
  FIVTC := TC ;
  FIVW := W ;
  
  //
  for i := 0 to FTables.Count - 1 do
  with TOrderTableItem(FTables.Items[i]) do
  begin
    dPrice := Price ;
    aIV := IV(U , E , R , T , TC, dPrice, W ) ;
    FIV := aIV ;
  end;

  iRectTop := 0 ;
  iRectBottom := 0 ; 
  for i:=FStartIndex  to FEndIndex do
  begin
    
    iTop :=  FDataTop + (FEndIndex-i ) * DEFAULT_HEIGHT ;
    iBottom := iTop + DEFAULT_HEIGHT;

    if iRectTop < 0 then iRectTop := iTop;
    iRectBottom := Max(iBottom, iRectBottom);

    if Items[i] <> nil then
    begin
      aFontColor := clBlack;
      aBkColor := clWhite ; 
      //

      // -- �ɼ��϶��� ǥ��
      if FSymbol.SymbolType <> stOption then
        stText := ''
      else
        stText := Format('%.3f', [Items[i].FIV]) ;
      //
      
      DrawRect(
        Rect(aCol.Left, iTop+1, aCol.Right, iBottom),
        stText ,
        aBkColor, aFontColor, taCenter);
    end; 

  end;

  if (iRectTop < 0) or (iRectBottom < 0) then Exit;

  aCopyRect.Left := aCol.Left;
  aCopyRect.Right := aCol.Right;
  aCopyRect.Top := iRectTop + 1;
  aCopyRect.Bottom := iRectBottom;

  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

end;


// �������� �� �׸��� ( ��մܰ�, �򰡼���, �̰����������� )
procedure TOrderTablet.DrawInfoCell( aRect : TRect;
  stText : String ; aBkColor, aFontColor : TColor ) ;
begin

  DrawRect(
    Rect( aRect.Left, aRect.Top , aRect.Right, aRect.Bottom),
      stText,aBkColor, aFontColor, taRightJustify );
  //
  aRect := Rect(aRect.Left -1, aRect.Top, aRect.Right , aRect.Bottom+1) ;

  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Brush.Color := GRID_COLOR ;
  FCanvas.FrameRect(aRect);
  //
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);

  //
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := FRAME_COLOR[FSideType]  ;
  FCanvas.Pen.Width := FRAME_WIDTH ;
  aRect :=  Rect( FPaintBox.Left, FPaintBox.Top, FPaintBox.Width, FPaintBox.Top+5) ;
  FCanvas.MoveTo(FPaintBox.Left, FPaintBox.Top);
  FCanvas.LineTo(FPaintBox.Width, FPaintBox.Top);
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);

  {
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := FRAME_COLOR[FSideType]  ;
  FCanvas.Pen.Width := FRAME_WIDTH ;
  FCanvas.Brush.Color := FRAME_COLOR[FSideType]  ;
  aRect :=  Rect( FPaintBox.Left, FPaintBox.Top, FPaintBox.Width, FPaintBox.Height) ;
  FCanvas.FrameRect(aRect);
    // FCanvas.MoveTo(FPaintBox.Width, FPaintBox.Top);
    // FCanvas.LineTo(FPaintBox.Width, FPaintBox.Height);
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
  } 

end;

// ���ݿ��� FAvgPrice�׸��� 
procedure TOrderTablet.DrawAvg(aRect: TRect);
var
  iLeft , iRight, iHeight : Integer ;
begin
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := clBlack;
  FCanvas.Pen.Width := 1;

  iLeft  :=   aRect.Left+2 ;
  iRight :=  iLeft + 6 ;
  iHeight :=  aRect.Top+7 ; 

  FCanvas.MoveTo(iLeft , iHeight );
  FCanvas.LineTo(iRight , iHeight );
  FCanvas.MoveTo(iLeft , iHeight+2 );
  FCanvas.LineTo(iRight , iHeight+2 );
end; 

// ���ݿ��� Max�� �׸��� 
procedure TOrderTablet.DrawMAX(aRect: TRect);
begin
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := clRed;
  FCanvas.brush.Color := clRed;
     
  FCanvas.Polygon([Point(aRect.Left + 4, aRect.Top + 2),
      Point(aRect.Left + 2, aRect.Top + 6),
      Point(aRect.Left + 6, aRect.Top + 6)]);
end;

// ���ݿ��� Min�� �׸��� 
procedure TOrderTablet.DrawMIN(aRect: TRect);
begin
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := clBlack;
  FCanvas.Brush.Color := clBlack;

  FCanvas.Polygon([Point(aRect.Left + 4, aRect.Bottom - 2),
      Point(aRect.Left + 2, aRect.Bottom - 6),
      Point(aRect.Left + 6, aRect.Bottom - 6)]);
end;


// ���� �׸��� 
procedure TOrderTablet.DrawGrid;
var
  i, j, iX, iY, iHeight : Integer;
  aCopyRect: TRect;
begin

  iX := 0;
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Width := 1;
  
  FCanvas.Pen.Color := GRID_COLOR ; 
  iHeight := DEFAULT_HEIGHT * (FViewTotCnt); 

  // column
  for i:=0 to FColumns.Count-1 do
  with FColumns.Items[i] as TOrderColumnItem do
    if Visible then
    begin
      FCanvas.MoveTo(Right, 0);
      FCanvas.LineTo(Right, iHeight);
    end;
  // row
  for j:=0 to FViewTotCnt do
  begin
    iY := DEFAULT_HEIGHT * j;
    FCanvas.MoveTo(0, iY);
    FCanvas.LineTo(FWidth, iY);
  end;

end;


// ���ÿ��� ���� �÷� �׸���
procedure TOrderTablet.DrawPrice;
begin
  DrawPriceUpdate(FStartIndex, FEndIndex);  
end;

// ���� �÷� iMinIndex, iMaxIndex ��ŭ �׸���
procedure TOrderTablet.DrawPriceUpdate(iMinIndex, iMaxIndex: Integer);
var
  i, iTop, iBottom : Integer;
  iRectTop, iRectBottom : Integer;
  aBkColor, aFontColor : TColor;
  
  aCol : TOrderColumnItem;
  aCopyRect : TRect;

  // index ���� 
  iMinPriceIndex, iMaxPriceIndex, iAvgPriceIndex : Integer ;

  procedure DrawAutoScroll(aRect : TRect; iIndex : Integer);
  begin
    if not FAutoScroll or FScrollLock then Exit;

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

  aCol := FCols[ocPrice, ptLong];

  iRectTop := -1;
  iRectBottom := -1;

  // index ����
  if FSymbol = nil then
  begin
    iMinPriceIndex := -1 ;
    iMaxPriceIndex := -1 ;
    iAvgPriceIndex := -1 ;
  end
  else
  begin
    iMinPriceIndex := FindIndex(FMinPrice);
    iMaxPriceIndex := FindIndex(FMaxPrice);
    iAvgPriceIndex := FindIndex( GetTickValue(FSymbol.DerivativeType, FAvgPrice ));
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
      if i = FPriceIndex then
        aFontColor := clWhite
      else
        aFontColor := clBlack;
      // 
      DrawRect(
        Rect(aCol.Left, iTop+1, aCol.Right, iBottom),
        Items[i].PriceDesc,
        aBkColor, aFontColor, taCenter);

      // -- Index
      if i = iMinPriceIndex  then
        DrawMin(Rect(aCol.Left, iTop+1, aCol.Right, iBottom));
      if i = iMaxPriceIndex  then
        DrawMax(Rect(aCol.Left, iTop+1, aCol.Right, iBottom));
      if i = iAvgPriceIndex  then
        DrawAvg(Rect(aCol.Left, iTop+1, aCol.Right, iBottom));

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

  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

end;


// ȣ�� �÷� �׸��� 
procedure TOrderTablet.DrawQuote;
begin
  DrawQuoteUpdate(FQuoteIndexLow, FQuoteIndexHigh, True);
end;

// ȣ�� �÷� iMinIndex, iMaxIndex ��ŭ �׸���
procedure TOrderTablet.DrawQuoteUpdate(iMinIndex, iMaxIndex: Integer;
  bRefresh: Boolean);
var
  iFirstIndex, iPrevH, iCurH , iWS,iWE : Integer ;
  aColumn : TOrderColumnItem ;
  dBid, dAsk : Double ;
  aRect : TRect;
  //
  i : Integer;
  iTop, iBottom : Integer;
  aColor : TColor;
  aTableItem : TOrderTableItem;

  procedure DrawQuoteCell(aColType : TOrderColumnType; aPosType : TPositionType;
    bRefresh : Boolean);
  begin

    if (not bRefresh) and
       (aTableItem.QuoteDiffs[aPosType] = 0) then Exit;

    if ( FQtyMerge = true )  and
      ( aTableItem.QuotePosition <> aPosType ) then exit ;
    
    // aColor ;= clWhite 
    aColor := FQuoteColor[aPosType, ctBg] ;

    if aTableItem.Quotes[aPosType] = 0 then
      aColor := clWhite ;

    if aTableItem.Quotes[aPosType] = 0 then
      DrawCell( FCols[aColType,aPosType], iTop+1, iBottom, aColor,
                '', clBlack, taRightJustify, True)
    else
      DrawCell( FCols[aColType, aPosType], iTop+1, iBottom, aColor,
                Format('%.0n',[aTableItem.Quotes[aPosType]*1.0]),
                FQuoteColor[aPosType, ctFont], taRightJustify, True);
  end;

begin

  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Mode := pmCopy;

  dBid := FSymbol.Quote.Price[qtBid,1] ;
  FSymbol.IncStep(dBid) ;
  dAsk := FSymbol.Quote.Price[qtAsk,1]  ;


  for i:= iMinIndex to iMaxIndex do
    if (i >= FStartIndex) and (i <= FEndIndex) then
    begin
      aTableItem := Items[i];
      if aTableItem = nil then Exit;

      iTop := FDataTop + (FEndIndex-i) * DEFAULT_HEIGHT;
      iBottom := iTop + DEFAULT_HEIGHT;

      if FColVisibles[ocQty] then
      begin
        DrawQuoteCell(ocQty, ptShort, bRefresh); // copy included
        DrawQuoteCell(ocQty, ptLong, bRefresh);  // copy included
      end;

    end;
  //

  // �ܷ����� & 1ȣ�� �ŵ��� 1ȣ�� �ż��� 1ƽ ���� �϶� (�پ����� ���)
  // ���м� �׸���
  {
  if ( FQtyMerge = true ) then
  begin

    if ( dAsk  > dBid - PRICE_EPSILON ) and
        ( dBid > dAsk  - PRICE_EPSILON )  then
    begin

      iFirstIndex := FindIndex(dAsk) ;

      // �ش� �ε����� FTables�� Item�� ��ȯ
      aColumn := GetColumn(ocQty, ptLong);
      if aColumn = nil then aColumn := GetColumn(ocQty, ptShort)  ;
      if aColumn = nil then exit ;

      iWS := aColumn.Left ;
      iWE := aColumn.Right  ;

      //
      FCanvas.Pen.Mode := pmCopy;
      FCanvas.Pen.Width := 1;
      FCanvas.Pen.Color := GRID_COLOR ;
      iPrevH := FDataTop + (FEndIndex - FFirstQuoteIndex ) * DEFAULT_HEIGHT + DEFAULT_HEIGHT ;
      FCanvas.MoveTo(iWS , iPrevH);
      FCanvas.LineTo(iWE, iPrevH);
      aRect := Rect(iWS, iPrevH + 5, iWE , iPrevH- 5 );
      FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);
      //
      FCanvas.Pen.Mode := pmCopy;
      FCanvas.Pen.Color := clGreen;
      FCanvas.Pen.Width := 1 ;
      iCurH := FDataTop + (FEndIndex - iFirstIndex ) * DEFAULT_HEIGHT + DEFAULT_HEIGHT ;
      FCanvas.MoveTo(iWS , iCurH);
      FCanvas.LineTo(iWE, iCurH);
      aRect := Rect(iWS, iCurH + 5, iWE , iCurH - 5 );
      FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);

      FFirstQuoteIndex := iFirstIndex ;

    end;
  end ;
  }


end;


// �ֹ� �÷� �׸���  
procedure TOrderTablet.DrawTable;
var
  aOrderCols, aGutCols, aQtyCols : array[TPositionType] of TOrderColumnItem;
  aPriceCol : TOrderColumnItem;
  i, iTop, iBottom : Integer;
  stText : String;
  aCopyRect : TRect;
  aDrawItem : TOrderDrawItem;
begin

  if FEndIndex < 0 then exit ;
   
  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Width := 1;

  //-- get columns
  aPriceCol := GetColumn(ocPrice, ptLong);
  aOrderCols[ptShort] := GetColumn(ocOrder, ptShort);
  aOrderCols[ptLong] := GetColumn(ocOrder, ptLong);
  aGutCols[ptShort] := GetColumn(ocGut, ptShort);
  aGutCols[ptLong] := GetColumn(ocGut, ptLong);
  aQtyCols[ptShort] := GetColumn(ocQty, ptShort);
  aQtyCols[ptLong] := GetColumn(ocQty, ptLong);

  iTop := FDataTop - DEFAULT_HEIGHT ;
  iBottom := iTop + DEFAULT_HEIGHT;
  //

  aCopyRect.Top := FDataTop ;
  aCopyRect.Bottom := FHeight ; 
  aCopyRect.Left:= aGutCols[FOrderPostion[stLeft]].Left;
  aCopyRect.Right:= aGutCols[FOrderPostion[stRight]].Right;
  //

  for i:=FEndIndex downto FStartIndex do
  begin
    Inc(iTop,DEFAULT_HEIGHT);
    iBottom := iTop + DEFAULT_HEIGHT;

    if FColVisibles[ocGut] then
    begin

      // �۾��ڵ� :  UD_JB_001
      // ������ : �����
      // �������� : 06/11/27

      DrawRect(
         Rect(aGutCols[ptShort].Left, iTop+1, aGutCols[ptShort].Right,iBottom),
              '', clWhite, clBlack, taRightJustify);
      DrawRect(
         Rect(aGutCols[ptLong].Left, iTop+1, aGutCols[ptLong].Right,iBottom),
              '', clWhite, clBlack, taRightJustify);
    end;


    //
    if FColVisibles[ocOrder] then
    begin 
        //�ŵ��ֹ�
        if Items[i].OrderQty[ptShort] > 0 then
          stText := Format('%d',[Items[i].OrderQty[ptShort]])
        else
          stText := '';
        if Items[i].OrderVar[ptShort] <> 0 then
          stText := stText + Format('(%d)',[Items[i].OrderVar[ptShort]]);
        DrawRect(
          Rect(aOrderCols[ptShort].Left,iTop+1,aOrderCols[ptShort].Right,iBottom),
             stText, aOrderCols[ptShort].Color ,
             FOrderColor[ptShort, ctFont] , taRightJustify);

        // �ż��ֹ�
        if Items[i].OrderQty[ptLong] > 0 then
          stText := Format('%d',[Items[i].OrderQty[ptLong]])
        else stText := '';
        if Items[i].OrderVar[ptLong] <> 0 then
          stText := stText + Format('(%d)',[Items[i].OrderVar[ptLong]]);
        DrawRect(
          Rect(aOrderCols[ptLong].Left,iTop+1,aOrderCols[ptLong].Right,iBottom),
            stText, aOrderCols[ptLong].Color,
            FOrderColor[ptLong, ctFont] , taRightJustify);

    end ;

    // DrawQT
    if (Items[i].QTRefCounts[ptLong] > 0) and
       (Items[i].Quotes[ptShort] = 0) then
      DrawQT(i, ptLong);
    if (Items[i].QTRefCounts[ptShort] > 0) and
       (Items[i].Quotes[ptLong] = 0) then
      DrawQT(i, ptShort);

  end;


  // �۾��ڵ� : UD_HW_001
  // �۾��� : 2006.12.03
  // �ֹ����� ������ �������� �ֹ� action ȭ��ǥ�� �׸��� �ʴ´�. 
  //-- draw graphic
  {
  // 2007.06.04 
  if FColVisibles[ocOrder] then
  begin
    for i:=0 to FDrawItems.Count-1 do
    begin
      aDrawItem := FDrawItems.Items[i] as TOrderDrawItem;
      DrawArrow(aDrawItem);
    end;
  end;
  }

  // 2007.06.04
  DrawDataCell(FClickPoint, True);

  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

  if FCurrentPoint.FieldType in [ofGut] then
    DrawDataCell(FCurrentPoint, False )
  else
    begin
      if FMouseTrace = true then
        DrawDataCell(FCurrentPoint, True);
    end ; 

end;


// -- �����ܷ� �׸��� 
procedure TOrderTablet.DrawQT(iIndex: Integer; aPosType: TPositionType);
var
  iTop, iBottom : Integer;
  aTableItem : TOrderTableItem;
  stText : String;
  aCopyRect : TRect;
begin
  if (not FVisibleQT) or
     (not FColVisibles[ocQty]) or
     (iIndex < FStartIndex) or
     (iIndex > FEndIndex) or
     (FQtyMerge = true ) then Exit;

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

  if  FQtyMerge then
  begin
    case aPosType of
      ptLong :
        if aTableItem.Quotes[ptLong] = 0 then
          DrawCell(FCols[ocQty, ptLong], iTop+1, iBottom, clWhite,
                 stText, $999999, taLeftJustify, True);
      ptShort :
        if aTableItem.Quotes[ptShort] = 0 then
          DrawCell(FCols[ocQty, ptShort], iTop+1, iBottom, clWhite,
                 stText, $999999, taLeftJustify, True);
    end;
  end
  else
  begin 
    case aPosType of
      ptLong :
        if aTableItem.Quotes[ptShort] = 0 then
          DrawCell(FCols[ocQty, ptShort], iTop+1, iBottom, clWhite,
                 stText, $999999, taRightJustify, True);
      ptShort :
        if aTableItem.Quotes[ptLong] = 0 then
          DrawCell(FCols[ocQty, ptLong], iTop+1, iBottom, clWhite,
                 stText, $999999, taRightJustify, True);
    end;
  end; 

end;


// ���� �÷��� ���� ǥ�� 
procedure TOrderTablet.DrawIndex(dValue: Double; idxType: TIndexType;
  bErase: Boolean);
var

  iIndex : Integer ;
  iTop, iBottom : Integer;
  iLeft, iRight : Integer ; 
  aBkColor, aFontColor : TColor;

  aCol : TOrderColumnItem;
  aCopyRect : TRect;

  idxIndex : array[TIndexType] of Integer; 
begin

  if FSymbol = nil then exit ;

  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Mode := pmCopy;

  // ���ݿ��� �׸��� 
  aCol := FCols[ocPrice, ptLong];
  iLeft := aCol.Left + INDEX_LEFT ;  
  iRight :=  iLeft + INDEX_RIGHT ;

  // get Index
  iIndex := FindIndex(dValue);      
  if (iIndex < 0) or (iIndex < FStartIndex) or (iIndex > FEndIndex) then exit ;

  iTop :=  FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT;
  iBottom := iTop + DEFAULT_HEIGHT;

  // ���ݿ��� color ������ �����ϰ� 
  aBkColor := GetPriceColor( iIndex , dValue );
  if iIndex = FPriceIndex then
    aFontColor := clWhite
  else
    aFontColor := clBlack;

  // ����� ��� 
  if bErase then
  begin

    // �ʱ�ȭ 
    DrawRect(
      Rect(iLeft, iTop+1, iRight, iBottom),
      ' ', aBkColor, aFontColor, taCenter);
    
    // �ڱⰡ �׸��� �ܿ�.. �ٸ� �����ʹ� �ٽ� �׷���� �� 
    if idxType = idxMin then
    begin
      if DrawIndexYN(iIndex, idxAvg) then   
        DrawAVG(Rect(iLeft, iTop+1, iRight , iBottom));
      if DrawIndexYN(iIndex, idxMax) then
        DrawMax(Rect(iLeft, iTop+1, iRight , iBottom));
    end
    else if idxType = idxMax then
    begin
      if DrawIndexYN(iIndex, idxAvg) then
        DrawAVG(Rect(iLeft, iTop+1, iRight , iBottom));
      if DrawIndexYN(iIndex, idxMin) then
        DrawMin(Rect(iLeft, iTop+1, iRight, iBottom));
    end
    else if idxType = idxAvg then
    begin
      if DrawIndexYN(iIndex, idxMax) then
        DrawMax(Rect(iLeft, iTop+1, iRight , iBottom));
      if DrawIndexYN(iIndex, idxMin) then
        DrawMin(Rect(iLeft, iTop+1, iRight, iBottom));
    end; 

  end
  // �׸��� ��� 
  else
  begin

    if idxType = idxMin then
      DrawMin(Rect(iLeft, iTop+1, iRight, iBottom))
    else if idxType = idxMax then
      DrawMax(Rect(iLeft, iTop+1, iRight , iBottom)) 
    else if idxType = idxAvg then
      DrawAVG(Rect(iLeft, iTop+1, iRight , iBottom));

  end;

  if (iTop < 0) or (iBottom < 0) then Exit;

  aCopyRect.Left := iLeft;
  aCopyRect.Right := iRight ;
  aCopyRect.Top := iTop + 1;
  aCopyRect.Bottom := iBottom;
  
  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);
end;


// TOrderDrawMode�� ���� �׸��� �Լ� ȣ�� 
procedure TOrderTablet.Draw(aMode: TOrderDrawMode);
var
  aRect : TRect ;
begin
  if (FSymbol = nil) or (FPaintBox = nil)  then Exit;
  //
  case aMode of
    odQuote : begin
                DrawQuote;
              end;
    odPrice : begin
                DrawPrice;
              end;
    odTable : begin
                DrawGrid;
                DrawTable;
                DrawIV(FIVU , FIVE , FIVR , FIVT , FIVTC , FIVW ) ; 
              end;
    odAll :   begin
                FCanvas.Brush.Color := clWhite;
                FCanvas.FillRect(Rect(0,0,FWidth,FHeight));

                // -- Draw
                DrawGrid;
                DrawQuote;
                DrawPrice;
                DrawTable;
                DrawInfoRow ;
                DrawIV(FIVU , FIVE , FIVR , FIVT , FIVTC , FIVW ) ; 
            end;
  end;

  

  FCanvas.Pen.Mode := pmCopy;
  FCanvas.Pen.Color := FRAME_COLOR[FSideType]  ;
  FCanvas.Pen.Width := FRAME_WIDTH ;
  FCanvas.Brush.Color := FRAME_COLOR[FSideType]  ;
  aRect :=  Rect( FPaintBox.Left, FPaintBox.Top, FPaintBox.Width, FPaintBox.Height) ;
  FCanvas.FrameRect(aRect);
    // FCanvas.MoveTo(FPaintBox.Width, FPaintBox.Top);
    // FCanvas.LineTo(FPaintBox.Width, FPaintBox.Height);
  FPaintBox.Canvas.CopyRect(aRect, FCanvas, aRect);

  
end;


// ----- Calculate/Reset  

// ���ÿ��� ��� 
procedure TOrderTablet.RecalcView(iToIndex: Integer);
begin
  FEndIndex := Max(FViewDataCnt-1  ,Min(FTables.Count-1, iToIndex));
  FStartIndex := Max(FEndIndex - FViewDataCnt + 1 , 0); 
end;

// �ֹ��� reset 
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
end;

// �ֹ��հ� ��� 
procedure TOrderTablet.RecalcSum;
var
  i : Integer;
begin
  //-- clear sum
  ResetSum;
  //-- below sum
  for i := FStartIndex-1 downto 0 do
  begin
    Inc(FOrderQtySums[ptLong,pvDown], Items[i].OrderQty[ptLong]);
    Inc(FOrderQtySums[ptShort,pvDown], Items[i].OrderQty[ptShort]);
  end;
  //-- sum of the visible
  for i := FEndIndex downto FStartIndex do
  begin
    Inc(FOrderQtySums[ptLong, pvVisible ], Items[i].OrderQty[ptLong]);
    Inc(FOrderQtySums[ptShort, pvVisible ], Items[i].OrderQty[ptShort]);
  end;
  //-- above sum
  for i := FEndIndex+1 to FTables.Count-1 do
  begin
    Inc(FOrderQtySums[ptLong, pvUp], Items[i].OrderQty[ptLong]);
    Inc(FOrderQtySums[ptShort,pvUp], Items[i].OrderQty[ptShort]);
  end;
  //-- total
  FOrderQtySums[ptLong,pvSum] :=
    FOrderQtySums[ptLong,pvDown] + FOrderQtySums[ptLong,pvVisible] 
      + FOrderQtySums[ptLong,pvUp] ; 
  FOrderQtySums[ptShort,pvSum] :=
    FOrderQtySums[ptShort,pvDown] + FOrderQtySums[ptShort,pvVisible]
      + FOrderQtySums[ptShort,pvUp] ; 
end;

// �ֹ�ǥ reset 
procedure TOrderTablet.ResetTable;
var
  i : Integer;
begin
  for i:=0 to FTables.Count-1 do
  with TOrderTableItem(FTables.Items[i]) do
  begin
    OrderQty[ptLong] := 0; OrderQty[ptShort] := 0;
    OrderVar[ptLong] := 0; OrderVar[ptShort] := 0;
  end;
end;

// 
procedure TOrderTablet.RecalcTable;
var
  i : Integer;
begin
  //-- init table data to zeros
  ResetTable;

  //--
  for i:=0 to FDrawItems.Count-1 do
  with FDrawItems.Items[i] as TOrderDrawItem do
    case QtyActionType of
      oqMove : // ����
              begin
                Dec(Items[FromIndex].OrderVar[PositionType],Qty);
                Inc(Items[ToIndex].OrderVar[PositionType],Qty);
              end;
      oqSub : Dec(Items[FromIndex].OrderVar[PositionType], Qty);
      oqAdd :
        case DataType of
          odOrder :    Inc(Items[FromIndex].OrderQty[PositionType],Qty);
          odOrderReq : Inc(Items[FromIndex].OrderVar[PositionType],Qty);
        end;
    end;
end;

procedure TOrderTablet.RefreshTable;
begin
  RecalcTable;    // �ֹ�ǥ ����
  RecalcSum;      // �ֹ��հ� ����   
  //
  DrawOrderSum ; 
  Draw(odTable);
  //
end;





// ----- 1.3 Set/Get

procedure TOrderTablet.SetSymbol(aSymbol: TSymbolItem);
var
  dPrice : Double;
  dHigh, dLow : Double;
begin
  //-- �ֹ�ǥ ����
  Clear;
  //
  NotifyChanged;
  //
  if aSymbol = nil then Exit;
  //-- ���� �Ҵ�
  FSymbol := aSymbol;
  //-- �ֹ�ǥ ����
  RefreshTableItem ;

  //-- ���簡/ȣ�� index -> No draw
  UpdatePrice(False);
  UpdateQuote(False);
  //-- ���簡�� �����
  MoveToCenter(FPriceIndex);

  // -- Point Rest
  FClickPoint.Index := -1 ; 

end;


// param iIndex : FTables�� index
// return : Tablet���� Y��ǥ ( �߰��� ) 
function TOrderTablet.GetY(iIndex: Integer): Integer;
begin 
  Result := FDataTop + (FEndIndex - iIndex ) * DEFAULT_HEIGHT + HALF_HEIGHT; 
end;

// ȭ�� ������ ������ 
// param : X, Y ��ǥ
// return : TOrderPoint
function TOrderTablet.GetPoint(X, Y: Integer): TOrderPoint;
var
  i : Integer;
  aCol : TOrderColumnItem ;
begin
  if FSymbol = nil then Exit;

  with Result do
  begin

    // X��ǥ�� ocGut�� ���̺��� ���ų� ������ ocGut-ptShort 
    if X <= FColWidths[ocGut] then
    begin
      ColType := ocGut ;
      PositionType := FOrderPostion[stLeft];
    end else
    begin
      ColType := ocGut ; // default

      // X��ǥ�� �÷� ������ �Ѿ�� ocGut-ptLong  
      if X > (FColumns.Items[FColumns.Count-1] as TOrderColumnItem).Right then
        PositionType := FOrderPostion[stRight] ;
      
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
    if Y <= DEFAULT_HEIGHT then 
      RowType := orInfo 
    else if Y <= ( FViewTotCnt ) * DEFAULT_HEIGHT then    // Info + Data ��ģ�� 
      RowType := orData  
    else
      RowType := orEtc;

    // Get Field Type
    // 2007.05.21  ocIV -> ofFixed  
    if ColType = ocGut then
      FieldType := ofGut
    else if RowType = orInfo then
      FieldType := ofInfo   
    else if RowType = orEtc then
      FieldType := ofEtc
    else if ColType in [ocPrice, ocAdded, ocIV] then
      FieldType := ofFixed
    else if ColType = ocOrder then
      FieldType := ofOrder
    else
      FieldType := ofEtc ;

    // get index ( FTables�� index ) 
    if RowType = orData then
      Index := FEndIndex - ( Y div DEFAULT_HEIGHT ) + FViewInfoCnt  
    else
      Index := -1;
      
    // �ֹ�����, ���� 
    if (Index >= 0) and (Index < FTables.Count) then
    begin
      if FieldType = ofOrder then
        Qty := Items[Index].OrderQty[PositionType]    
      else
        Qty := 0;
      Price := Items[Index].Price;
    end else 
    begin
      Qty := 0;
      Price := 0.0;
    end;

  end;
end;

// �ش� �ε����� FTables�� Item�� ��ȯ 
function TOrderTablet.GetTableItem(i: Integer): TOrderTableItem;
begin
  if (i>=0) and (i<FTables.Count) then
    Result := FTables.Items[i] as TOrderTableItem 
  else
    Result := nil;
end;

// �ش� ������ FTables index 
function TOrderTablet.FindIndex(dPrice: Double): Integer;
var
  i : Integer;
begin
  Result := -1;
  // 
  if (dPrice < FLowLimit - PRICE_EPSILON) or
     (dPrice > FHighLimit + PRICE_EPSILON) then Exit;
  //
  for i:=0 to FTables.Count-1 do
  with TOrderTableItem(FTables.Items[i]) do
    if Abs(Price - dPrice) < PRICE_EPSILON then
    begin
      Result := i;
      Break;
    end;

end;

// �ش� index(�����÷�) �� Color ���ϱ� 
function TOrderTablet.GetPriceColor(iIndex: Integer;
  dValue: Double): TColor;
var
  bkColor : TColor ; 
begin

  if iIndex = FPriceIndex then
  begin
    bkColor := SELECTED_COLOR;
  end
  else
  begin
    // A > B : A > B + EPSILON
    // A >= B : A > B - EPSILON
    // A < B : A < B - EPSILON
    // A <= B : A < B + EPSILON

    // ������ ���ų� �۰�
    // �������� ���ų� ũ��
    if (dValue < FSymbol.H + PRICE_EPSILON) and
      (dValue > FSymbol.L - PRICE_EPSILON) then
    begin

      // ������ �ð����� ũ��
      // ������ �������� �۰� 
      // ������ �ð����� ���ų� ũ��.   
      if (FSymbol.C > FSymbol.O + PRICE_EPSILON) and
        (dValue < FSymbol.C - PRICE_EPSILON) and
        (dValue > FSymbol.O - PRICE_EPSILON) then
          bkColor := BULL_COLOR

      // ������ �ð����� �۰�
      // ������ �ð����� ���ų� �۰�
      // ������ �������� ũ��  
      else if (FSymbol.C < FSymbol.O - PRICE_EPSILON) and
        (dValue < FSymbol.O + PRICE_EPSILON) and
        (dValue > FSymbol.C + PRICE_EPSILON) then
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

function TOrderTablet.FindDrawItem(aObj: TObject): TOrderDrawItem;
var
  i : Integer;
begin
  Result := nil;
  //
  for i:=0 to FDrawItems.Count-1 do
  with FDrawItems.Items[i] as TOrderDrawItem do
    if Target = aObj then
    begin
      Result := FDrawItems.Items[i] as TOrderDrawItem;
      Break;
    end;
end;


function TOrderTablet.GetOrderSum(aType: TPositionType): Integer;
begin
  Result := FOrderQtySums[aType, pvSum]; 
end;

procedure TOrderTablet.SetColWidth(aOrderColumnType: TOrderColumnType;
  i: Integer);
begin
  FColWidths[aOrderColumnType]:= i;
  RepositionColumns;
  // 
  Draw(odAll);
end;

procedure TOrderTablet.SetColVisible(aOrderColumnType: TOrderColumnType;
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
  FOrderPostion[stLeft] := aLeftPositionType ;
  FOrderPostion[stRight] := aRightPositionType ;    
end;



// ----- 1.4 Column

// FColumns�� �߰� 
function TOrderTablet.AddColumn(stTitle: String;
  aColType: TOrderColumnType; aPType: TPositionType): TOrderColumnItem;
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

// Long/Short ���� �ٱ��� �÷� ( ��뿹 : ȭ��ǥ ������ �÷� �˱� ���� ) 
function TOrderTablet.GetLastColumn(
  aPType: TPositionType): TOrderColumnItem;
var
  i : Integer;
  aCol : TOrderColumnItem ;
begin
  Result := nil;

  if aPType = FOrderPostion[stLeft] then
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

// FColumns���� ���ǿ� �´�  TOrderColumnItem ã�� 
function TOrderTablet.GetColumn(aColType: TOrderColumnType;
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

function TOrderTablet.GetColumn(aColType: TOrderColumnType): TOrderColumnItem;
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




// FColumns���� ���ǿ� �´�  TOrderColumnItem ã��  
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

      // �ֹ��� ������ ���̸� ���ϱ� ���ؼ� 
      if  aCol.ColType = ocOrder  then
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

  // �ֹ��� ������ ������ 
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

procedure TOrderTablet.RefreshColumns(aLeftPostiionType:TPositionType ;
      bLeft :Boolean ; bQtyMerge : Boolean ; aSide : TSideType ;
      bRefresh : Boolean );
var
  aLeftOrder, aRightOrder : TPositionType ;
begin

  // Order Left/Right 
  SetOrderSide(aLeftPostiionType) ;
  
  // �ܷ� �÷� ���� ����
  FQtyMerge := bQtyMerge ;
  FQtyMergeSide := aSide ;
  
  { // -- ���ս� ���� �������� �ʴ´�  
  if FQtyMerge = true then
    FColWidths[ocPrice] := PRICE_WIDTH_WIDE    // ȣ�� ���յǸ� ���ݿ� �а�
  else
    FColWidths[ocPrice] := PRICE_WIDTH ;
  }
  
  // reset
  FColumns.Clear ;

  // add columns
  // -- Left ( ���ݿ� ���� ���� ) 
  FCols[ocGut,   FOrderPostion[stLeft]] := AddColumn('',     ocGut,   FOrderPostion[stLeft]);
  FCols[ocOrder, FOrderPostion[stLeft]] := AddColumn('�ֹ�', ocOrder, FOrderPostion[stLeft] );

  if FQtyMerge = true  then    
  begin
    if FQtyMergeSide = stLeft then
      FCols[ocQty,   FOrderPostion[stLeft]] :=
        AddColumn('�ܷ�', ocQty,   FOrderPostion[stLeft] );
  end
  else
  begin
    FCols[ocQty,   FOrderPostion[stLeft]] := AddColumn('�ܷ�', ocQty,   FOrderPostion[stLeft] );
  end ;

  FCols[ocPrice, FOrderPostion[stLeft]] := AddColumn('ȣ��', ocPrice, FOrderPostion[stLeft]);
  // -- Right ( ���ݿ� ���� ������ )
  FCols[ocPrice, FOrderPostion[stRight]]  := FCols[ocPrice, FOrderPostion[stLeft]];
  //

  // �ܷ� �����̸� ���ʿ� ���� �״�� ���
  if ( FQtyMerge = true) then
  begin
    if FQtyMergeSide = stRight then
    begin
      FCols[ocQty,   FOrderPostion[stRight]]  := AddColumn('�ܷ�', ocQty,   FOrderPostion[stRight]);
      FCols[ocQty,   FOrderPostion[stLeft]]  := FCols[ocQty, FOrderPostion[stRight]]  ;
    end
    else
    begin
      FCols[ocQty,   FOrderPostion[stRight]]  := FCols[ocQty, FOrderPostion[stLeft]]  ;
    end;
  end
  else
  begin                        // �ܷ� ���� �ƴϸ� ���� �߰�
    FCols[ocQty,   FOrderPostion[stRight]]  := AddColumn('�ܷ�', ocQty,   FOrderPostion[stRight]);
  end ; 
  //

  FCols[ocOrder, FOrderPostion[stRight]]  := AddColumn('�ֹ�', ocOrder, FOrderPostion[stRight]);

  // 2007.05.21  IV
  FCols[ocIV, FOrderPostion[stLeft]] := AddColumn('IV', ocIV, FOrderPostion[stLeft]);
  FCols[ocIV, FOrderPostion[stRight]]  := FCols[ocIV, FOrderPostion[stLeft]];

  FCols[ocGut,   FOrderPostion[stRight]]  := AddColumn('',     ocGut,   FOrderPostion[stRight]);

  // FCols[ocOrder, ptLong].Color := LONG_COLOR ;
  // FCols[ocOrder, ptShort].Color := SHORT_COLOR ;

  FCols[ocOrder, ptShort].Color := FOrderColor[ptShort, ctBg] ;
  FCols[ocOrder, ptLong].Color := FOrderColor[ptLong, ctBg] ;


  // set position of columns
  RepositionColumns;

  if bRefresh = true then 
    Draw(odAll);
  
end;


 // FTables Clear �� �ٽ� add 
procedure TOrderTablet.RefreshTableItem;
var
  dPrice : Double;
begin 
  //
  FTables.Clear ;
  // 
  case FSymbol.UnderlyingType of
    utKospi200 :
      begin

        if FPriceOrderby = poAsc then   // �������� 
        begin 
          dPrice := FSymbol.LowLimit;
          while True do
          begin
            with FTables.Add as TOrderTableItem do
            begin
              Price := dPrice;
              PriceDesc := Format('%.*n', [FSymbol.Precision, dPrice]);
            end;
            FSymbol.IncStep(dPrice);
            if dPrice > FSymbol.HighLimit + PRICE_EPSILON then Break;
          end;

          FLowLimit := FSymbol.LowLimit;
          FHighLimit := FSymbol.HighLimit;
        end
        else    // �������� 
        begin
          dPrice := FSymbol.HighLimit;
          while True do
          begin
            with FTables.Add as TOrderTableItem do
            begin
              Price := dPrice;
              PriceDesc := Format('%.*n', [FSymbol.Precision, dPrice]);
            end;
            FSymbol.DecStep(dPrice);
            if dPrice < FSymbol.LowLimit - PRICE_EPSILON then Break;
          end;

          FLowLimit := FSymbol.LowLimit;
          FHighLimit := FSymbol.HighLimit;
          
        end; 
        
      end;
    utStock :
      begin
        FHighLimit := FSymbol.BasePrice + 100 * FSymbol.PriceUnit;
        FLowLimit :=
           Min(FSymbol.BasePrice - 100 * FSymbol.PriceUnit, FSymbol.PriceUnit);

        if FPriceOrderby = poAsc then   // �������� 
        begin 
          dPrice := 0;
          while True do
          begin
            dPrice := dPrice + FSymbol.PriceUnit;
            if dPrice < FLowLimit - PRICE_EPSILON then
              Continue
            else if dPrice > FHighLimit + PRICE_EPSILON then
              Break;
            with FTables.Add as TOrderTableItem do
            begin
              Price := dPrice;
              PriceDesc := Format('%.*n', [FSymbol.Precision, dPrice]);
            end;
          end;
        end
        else    // �������� 
        begin
          dPrice := FHighLimit ; 
          while True do
          begin
            dPrice := dPrice - FSymbol.PriceUnit;
            if dPrice <  FLowLimit - PRICE_EPSILON then
              Break ;
            // 
            with FTables.Add as TOrderTableItem do
            begin
              Price := dPrice;
              PriceDesc := Format('%.*n', [FSymbol.Precision, dPrice]);
            end;
          end;           

        end; 
       
      end;
  end;
  
end;




// ----- 2. Event

procedure TOrderTablet.Paint(Sender: TObject);
begin
  Draw(odAll);
end;

procedure TOrderTablet.ActMouseMove;
var
  aPoint : TPoint;
begin
  GetCursorPos(aPoint);
  aPoint := FPaintBox.ScreenToClient(aPoint);

  MouseMove(FPaintBox, [], aPoint.X, aPoint.Y); 
end; 

procedure TOrderTablet.DblClick(Sender: TObject);
var
  aPoint : TPoint;
  aOrderPoint, aDummy : TOrderPoint; 
begin

  GetCursorPos(aPoint);
  aPoint := FPaintBox.ScreenToClient(aPoint);
  aOrderPoint := GetPoint(aPoint.X, aPoint.Y);
  //
  case aOrderPoint.FieldType of
    ofFixed : // move the double-click price to the center
      if aOrderPoint.Index > -1 then MoveToCenter(aOrderPoint.Index);
    ofOrder :  // put an order
      begin
        if (aOrderPoint.Index < FStartIndex) or (aOrderPoint.Index > FEndIndex) then Exit;
        if Assigned(FOnNewOrder) then  FOnNewOrder(aOrderPoint, aDummy, FSideType );
      end;
  end;
  
end;

procedure TOrderTablet.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  aPoint : TOrderPoint;
  aCopyRect : TRect;
  aCol : TOrderColumnItem ;
  aList : TList ; 
begin

  aPoint := GetPoint(X,Y);
  FFollowAction := False ;

  // 2007.06.04 YHW
  if(  aPoint.FieldType = ofOrder ) then
  begin

    if(  aPoint.Qty > 0) then
    begin
      FFollowAction := True;
      FStartX := X; FStartY := Y;
      FEndX := X; FEndY := Y;
      FStartPoint := aPoint;
    end ;

    if ( Button = mbRight ) then
    begin

      // �ֹ������� �ϵ��� ��
      if ( FOrderRightButton = true ) then
      begin
        DblClick(FPaintBox) ;
        FPaintBox.PopupMenu := nil ;
      end
      // �޴������� ��
      else
      begin
        FPaintBox.PopupMenu := FPopOrders ;
      end ;

    end ; 

  end;

  {
  case aPoint.FieldType of
    ofOrder :
      if aPoint.Qty > 0 then
      begin
        FFollowAction := True;
        FStartX := X; FStartY := Y;
        FEndX := X; FEndY := Y;
        FStartPoint := aPoint;
        with FCanvas do
        begin
          Brush.Color := clWhite;
          Pen.Mode := pmCopy;
          Pen.Color := clRed; // Blue
          Pen.Width := 1;
          Ellipse(X-3,Y-3,X+3,Y+3);
        end;
        aCopyRect := Rect(FStartX-3, FStartY-3, FStartX+3, FEndY+3);
        FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);
      end;
  end;

  // 2006.07.15 YHW start Config�� ���� pop menu or order
  if  ( aPoint.FieldType = ofOrder ) then
  begin

  end;

  }





end;


procedure TOrderTablet.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  aPoint : TOrderPoint;
  aCopyRect : TRect;
  aCol : TOrderColumnItem;
  bOldScrollLock : Boolean;
begin
  if (not (ssLeft in Shift)) and FFollowAction then
    FFollowAction:= False;
  //
  aPoint := GetPoint(X,Y);
  bOldScrollLock := FScrollLock;
  
  // Cursor 
  if  ( aPoint.FieldType in [ ofOrder] ) then
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
  if (aPoint.FieldType in [ofOrder, ofFixed]) then
  begin

    // ���콺 ������ ǥ�ð� true �϶�
    if FMouseTrace = true then
    begin
      // ���� �÷��� �׸��� 
      if FCurrentPoint.Index <> aPoint.Index then
      begin
        DrawPriceCell(FCurrentPoint, False);
        DrawPriceCell(aPoint, True);
      end;

      // Data �÷��� �׸��� 
      if (FCurrentPoint.Index <> aPoint.Index) or
        (FCurrentPoint.ColType <> aPoint.ColType) then
      begin
         DrawDataCell(FCurrentPoint, False);
         DrawDataCell(aPoint, True);
      end ;
      //
    end ;
    FCurrentPoint := aPoint;

  end else  // outside
  begin
    if FMouseTrace = true then
    begin
      DrawPriceCell(FCurrentPoint, False);
      DrawDataCell(FCurrentPoint, False);
    end;
    FCurrentPoint.Index := -1;
  end;

  //-- follow change or cancel
  if FFollowAction then
  begin

    if (aPoint.FieldType in [ofFixed, ofEtc, ofInfo ]) or
       (aPoint.PositionType <> FStartPoint.PositionType) or
       ((FStartPoint.FieldType in [ofOrder]) and (aPoint.FieldType = ofInfo)) or
       ((FStartPoint.ColType = ocPrice) and (aPoint.ColType = ocOrder))
    then Exit;

    
    DrawDataActionCell(FClickPoint, True, dcSelect);
    DrawDataActionCell(FActionPoint, False, dcTarget);
    FActionPoint := aPoint ;
    DrawDataActionCell(FActionPoint, True, dcTarget );


    //-- cancel orders
    if aPoint.FieldType in [ofGut] then
    begin
      DrawDataActionCell(FStartPoint, True, dcCancel );
    end
    //-- chance orders
    else if (FStartPoint.ColType = aPoint.ColType) and
      (FStartPoint.Index <> aPoint.Index) then
    begin
     DrawDataActionCell(FStartPoint, True, dcChange );
    end ;

    FEndX := X; FEndY := Y;

  end;
  
end;


procedure TOrderTablet.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  aPoint, aDummy : TOrderPoint;
  aList : TList ;
  boolOrderList : Boolean ;
begin

  boolOrderList := false ;

  if FFollowAction then
  begin

    // Draw(odAll); // refresh

    
    FFollowAction := False;
    //
    aPoint := GetPoint(FEndX, FEndY);

    if (aPoint.FieldType in [ofFixed, ofEtc]) or
       (aPoint.PositionType <> FStartPoint.PositionType) or
       ((FStartPoint.FieldType in [ofOrder]) and (aPoint.FieldType = ofInfo)) 
    then Exit;

    //-- cancelling orders
    if aPoint.FieldType in [ofGut] then
    begin
      if Assigned(FOnCancelOrder) then
        FOnCancelOrder(FStartPoint, aDummy, FSideType);
    end

    //-- changing orders
    else if (FStartPoint.ColType = aPoint.ColType) and
       (FStartPoint.Index <> aPoint.Index) then
    begin
      if Assigned(FOnChangeOrder) then
        FOnChangeOrder(FStartPoint, aPoint, FSideType)
    end

    // -- etc ( drag �̸鼭 cancel, change �ƴҶ�
    else
    begin
      boolOrderList := true ;
    end;

  end
  else  // drag �ƴҶ�  ( Ŭ�� ��ġ �˾Ƴ� ) 
  begin
    aPoint := GetPoint(X,Y);
    boolOrderList := true ;
  end;

  if ( boolOrderList = true ) and (  aPoint.FieldType = ofOrder ) then
  begin

    DrawDataActionCell(FClickPoint, False, dcSelect );
    DrawDataActionCell(aPoint, True, dcSelect);
    FClickPoint :=  aPoint ;

    // --  �ֹ� �������� �̾ƿ´�.
    aList := TList.Create;
    GetOrders(aList, aPoint)  ;
    // sort - �������� ( ���� �ֽŲ����� )
    aList.Sort(CompareAcpt);

    if Assigned(FOnOrderList) then  FOnOrderList( FSideType, FSymbol, aList, aPoint );
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
  FTables.Clear;

  // clear summary
  ResetSum;

  // drawing factors : data
  FStartIndex := -1;
  FEndIndex := -1;
  FPriceIndex := -1;

  FQuoteIndexLow  := -1;
  FQuoteIndexHigh := -1;
  FQuoteSums[ptLong] := 0;
  FQuoteSums[ptShort] := 0;

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

// 
procedure TOrderTablet.SetArea(aPaintBox: TPaintBox);
var
  aRect : TRect ;
begin

  FPaintBox := aPaintBox;
  FWidth := aPaintBox.Width;
  FHeight := aPaintBox.Height;

  //-- clear screen
  FPaintBox.Refresh;

  with FPaintBox do
  begin
    OnDblClick := DblClick;
    OnMouseDown := MouseDown;
    OnMouseMove := MouseMove;
    OnMouseUp := MouseUp;
    OnPaint := Paint;
  end;
                       
  //
  FBitmap.Width := FWidth;
  FBitmap.Height := FHeight;
  FCanvas := FBitmap.Canvas;
  FCanvas.Font.Name := '����';
  FCanvas.Font.Size := 10;
  //
  FViewTotCnt := FHeight div DEFAULT_HEIGHT  ;
  FViewInfoCnt := 1  ;  // orInfo ������ ������
  FViewDataCnt := FViewTotCnt - FViewInfoCnt ;
  FDataTop := FViewInfoCnt * DEFAULT_HEIGHT ; 

  if FSymbol <> nil then
  begin
    RecalcView(FEndIndex);
    RecalcSum;
    Draw(odAll);
  end;
  
end;


// ----- Quote & Price  

// QuoteProc���� ���簡 �������� ȣ���
procedure TOrderTablet.UpdatePrice(bDraw: Boolean);
var
  iOldIndex : Integer;
begin
  if FSymbol = nil then Exit;

  iOldIndex := FPriceIndex;

  if FSymbol.C > PRICE_EPSILON then
    FPriceIndex := FindIndex(FSymbol.C)
  else
  begin
    if FSymbol.IsCombination then
      FPriceIndex := FindIndex(FSymbol.C)
    else
      FPriceIndex := FindIndex(FSymbol.BasePrice);
  end;

  //-- draw
  if bDraw then
  begin
    DrawPriceUpdate(Min(FPriceIndex, iOldIndex),
                    Max(FPriceIndex, iOldIndex));
  end;

end;


// QuoteProc���� ȣ�� �������� ȣ���  
procedure TOrderTablet.UpdateQuote(bDraw: Boolean);
var
  iNewMin, iNewMax, iTotMin, iTotMax, iOldMin, iOldMax : Integer;
  aTableItem : TOrderTableItem;
  i, iQuoteIndex : Integer;
  iScrollSteps : Integer;

  // Quotes�� 0��, QuoteDiffs�� (-1) * Quotes �� �־���
  procedure ResetQuoteField(aColType : TOrderColumnType; aPosType : TPositionType);
  begin
    with aTableItem do
    if Quotes[aPosType] > 0 then
    begin
      QuoteDiffs[aPosType] := -Quotes[aPosType];
      Quotes[aPosType] := 0;
    end;
  end;

  // 
  procedure SetQuoteField(aColType : TOrderColumnType; aPosType : TPositionType;
     iValue : Integer);
  begin
    with aTableItem do
    begin
      QuotePosition := aPosType ;   // PostionType    
      Quotes[aPosType] := iValue;
      QuoteDiffs[aPosType] := QuoteDiffs[aPosType] + iValue;
    end;
  end;
  
begin
  //
  if FSymbol = nil then exit;

  //-- 1. reset quote fields 
  if FQuoteIndexLow < FQuoteIndexHigh then
  for i := FQuoteIndexLow to FQuoteIndexHigh do
  begin
    aTableItem := Items[i];
    if aTableItem = nil then Continue;

    ResetQuoteField(ocQty, ptLong);
    ResetQuoteField(ocQty, ptShort);
  end; 
  FQuoteSums[ptLong] := 0;
  FQuoteSums[ptShort] := 0;

  //-- 2. Set new quote
  iNewMin := FTables.Count-1;
  iNewMax := 0;     

  // get indices
  for i:=1 to 5 do
  begin
    // BID part
    FQuoteSums[ptLong] := FQuoteSums[ptLong] + FSymbol.Quote.Qty[qtBid, i];
    iQuoteIndex := FindIndex(FSymbol.Quote.Price[qtBid,i]);
    aTableItem := Items[iQuoteIndex];
    if aTableItem <> nil then
    begin
      iNewMin := Min(iNewMin, iQuoteIndex);
      iNewMax := Max(iNewMax, iQuoteIndex);

      SetQuoteField(ocQty, ptLong, FSymbol.Quote.Qty[qtBid, i]);
    end;

    // ASK part
    FQuoteSums[ptShort] := FQuoteSums[ptShort] + FSymbol.Quote.Qty[qtAsk, i];
    iQuoteIndex := FindIndex(FSymbol.Quote.Price[qtAsk,i]);
    aTableItem := Items[iQuoteIndex];
    if aTableItem <> nil then
    begin
      iNewMin := Min(iNewMin, iQuoteIndex);
      iNewMax := Max(iNewMax, iQuoteIndex); 
      SetQuoteField(ocQty, ptShort, FSymbol.Quote.Qty[qtAsk, i]);
    end;
  end;

  //-- 3. Get Total min/max
  // iNewMin : ȣ��(�ż�, �ŵ� ���ļ�) �߿��� ���� ���� FTables index 
  // iNewMax : ȣ��(�ż�, �ŵ� ���ļ�) �߿��� ���� ū FTables index
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

  //-- 4. Check for scroll (ȭ�� �̵��� �Ͼ���� üũ ) 
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
      MoveLine(iScrollSteps, 1);
    end
    else
      DrawQuoteUpdate(iTotMin, iTotMax, False);
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

procedure TOrderTablet.DoOrder(aOrder: TOrderItem; bNew: Boolean);
var
  aDrawItem : TOrderDrawItem;
  iQty : Integer;
begin
  if aOrder = nil then Exit;

  // �۾��ڵ� : UD_HW_001
  // �۾��� : 2006.11.30 
  if FReady = false then exit ;
  //
  if bNew then
  begin
    // 2�� ���� ������
    aDrawItem := FindDrawItem(aOrder);
    if aDrawItem = nil then aDrawItem := FDrawItems.Add as TOrderDrawItem ;
  end
  else
    aDrawItem := FindDrawItem(aOrder);
  //
  if aDrawItem = nil then Exit;
  //
  if not (aOrder.State in [osKseAcpt, osPartFill]) then
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
  end else
  with aDrawItem do
  begin
    DataType := odOrder;
    Target := aOrder;
    Qty := aOrder.UnfillQty;
    //
    case aOrder.OrderType of
      otNew :
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
                         aOrder.UnfillQty);
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
      otChange :
        begin
          PositionType := aOrder.OrgOrder.PositionType;
          GraphicType := ogChange;
          QtyActionType := oqMove;
          FromIndex := FindIndex(aOrder.OrgOrder.Price);
          ToIndex := FindIndex(aOrder.Price);

          // -- QT START
          QTState := qtSuspended;
          QTIndex := -1;
          // -- QT END 
        end;
      otCancel :
        begin
          PositionType := aOrder.OrgOrder.PositionType;
          GraphicType := ogCancel;
          QtyActionType := oqSub;
          FromIndex := FindIndex(aOrder.OrgOrder.Price);
          ToIndex := FromIndex;

          // -- QT START
          QTState := qtDisabled;
          QTIndex := -1;
          // -- QT END 
        end;
    end; //..case..
  end; //..with..
  //
  RefreshTable;
  //
  NotifyChanged;
end;

procedure TOrderTablet.DoOrderReq(aOrderReq: TOrderReqItem; bNew: Boolean);
var
  aDrawItem : TOrderDrawItem;
begin
  if aOrderReq = nil then Exit;
  //
  if bNew then
    aDrawItem := FDrawItems.Add as TOrderDrawItem
  else
    aDrawItem := FindDrawItem(aOrderReq);
  //
  if aDrawItem = nil then Exit;
  //
  if aOrderReq.IsDone then
    aDrawItem.Free
  else
  with aDrawItem do
  begin
    DataType := odOrderReq;
    Target := aOrderReq;
    Qty := aOrderReq.Qty;
    //
    case aOrderReq.OrderType of
      otNew :
        begin
          GraphicType := ogNew;
          FromIndex := FindIndex(aOrderReq.Price);
          ToIndex := FromIndex;
          //
          PositionType := aOrderReq.PositionType;
          QtyActionType := oqAdd;
        end;
      otChange :
        begin
          PositionType := aOrderReq.OrgOrder.PositionType;
          GraphicType := ogChange;
          QtyActionType := oqMove;
          FromIndex := FindIndex(aOrderReq.OrgOrder.Price);
          ToIndex := FindIndex(aOrderReq.Price);
        end;
      otCancel :
        begin
          PositionType := aOrderReq.OrgOrder.PositionType;
          GraphicType := ogCancel;
          QtyActionType := oqSub;
          FromIndex := FindIndex(aOrderReq.OrgOrder.Price);
          ToIndex := FromIndex;
        end;
    end; //..case..
  end; //..with..
  //
  RefreshTable;
  //
  NotifyChanged;

end; 


// ----- Get
 
function TOrderTablet.GetOrders(aList: TList;
  aTypes: TPositionTypes): Integer;
var
  i : Integer;
begin
  Result := 0;
  //
  if aList = nil then Exit;
  aList.Clear;
  //
  for i:=0 to FDrawItems.Count-1 do
  with FDrawItems.Items[i] as TOrderDrawItem do
    if (DataType = odOrder) and
       (GraphicType = ogNone) and //ie. OrderType = otNew
       (PositionType in aTypes) then
    begin
      aList.Add(Target as TOrderItem);
    end;
  //
  Result := aList.Count;
end;




function TOrderTablet.GetOrders(aList: TList;
  aPoint: TOrderPoint): Integer;
var
  i : Integer;
begin
  Result := 0;
  //
  if aList = nil then Exit;
  aList.Clear;
  //
  case aPoint.RowType of 
    orData :
      for i:=0 to FDrawItems.Count-1 do
      with FDrawItems.Items[i] as TOrderDrawItem do
        if (FromIndex = aPoint.Index) and
           (PositionType = aPoint.PositionType) and
           (DataType = odOrder) and
           (GraphicType = ogNone) then //ie. OrderType = otNew
        begin
          aList.Add(Target as TOrderItem);
        end;
  end;
  //
  Result := aList.Count;
end;

// ----- Move 

procedure TOrderTablet.MoveLine(iLine, iDir: Integer);
begin
  if FSymbol = nil then Exit;
  //
  RecalcView(FEndIndex + iDir * iLine);
  RecalcSum;
  //
  ActMouseMove;
  Draw(odAll);
end;

procedure TOrderTablet.MovePage(iDir: Integer);
begin
  if FSymbol = nil then Exit;
  //
  RecalcView(FEndIndex + iDir * FViewDataCnt);
  RecalcSum;
  //
  ActMouseMove;
  Draw(odAll);
end; 

procedure TOrderTablet.MoveToCenter(iIndex: Integer);
begin
  if FSymbol = nil then Exit;
  // 
  RecalcView( iIndex + FViewDataCnt div 2);
  RecalcSum;
  //
  ActMouseMove;
  Draw(odAll);
end;

procedure TOrderTablet.MoveToPrice;
begin
    MoveToCenter(FPriceIndex);
end;


constructor TOrderTablet.Create;
begin
  // created objects 
  FTables := TCollection.Create(TOrderTableItem);
  FDrawItems := TCollection.Create(TOrderDrawItem);
  FColumns := TCollection.Create(TOrderColumnItem);
  FBitmap := TBitmap.Create;

  // set default column widths 
  FColWidths[ocGut] := GUT_WIDTH;
  FColWidths[ocOrder] := ORDER_WIDTH; 
  FColWidths[ocQty] := QTY_WIDTH;
  FColWidths[ocPrice] := PRICE_WIDTH;
  FColWidths[ocAdded] := ADDED_WIDTH  ;
  // 2007.05.21  IV
  FColWidths[ocIV] := IV_WIDTH ;
  
  // set default column visible 
  FColVisibles[ocGut] := true  ; 
  FColVisibles[ocOrder] := True;
  FColVisibles[ocQty] := True;
  FColVisibles[ocPrice] := True;
  FColVisibles[ocAdded] := False ;
  // 2007.05.21  IV
  FColVisibles[ocIV] := False ;

  // -- 2007.03.21 Color
  FQuoteColor[ptShort, ctBg] := SHORT_COLOR ;
  FQuoteColor[ptShort, ctFont] := $000000 ;
  FQuoteColor[ptLong, ctBg] := LONG_COLOR ;
  FQuoteColor[ptLong, ctFont] := $000000 ;
  FOrderColor[ptShort, ctBg] := SHORT_COLOR ;
  FOrderColor[ptShort, ctFont] := $000000 ;
  FOrderColor[ptLong, ctBg] := LONG_COLOR ;
  FOrderColor[ptLong, ctFont] := $000000 ;

  
  RefreshColumns( ptShort , false,  false, stLeft, false );
  
end;

destructor TOrderTablet.Destroy;
begin
  FTables.Free;
  FDrawItems.Free;
  FColumns.Free;
  FBitmap.Free;
  
  inherited;
end;



// ��մܰ�
procedure TOrderTablet.SetAvgPrice(dValue: Double);
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect;  
begin

  if  FSymbol = nil then exit ;

  // 1. reset 
  DrawIndex(GetTickValue(FSymbol.DerivativeType, FAvgPrice), idxAvg, true) ;

  // 2. set new value
  FAvgPrice := dValue ;

  // 3. orInfo�� �׸���
  iLeft := FInfoLefts[itAvg]  ;
  iRight := iLeft + FInfoWidths[itAvg] ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ; 
  stText := Format('%.3f', [FAvgPrice]) ;

  if FOpenPosition > 0 then  //
  begin
    aBkColor := clRed; //SHORT_COLOR ;
    aFontColor := clWhite; //clRed
  end
  else if FOpenPosition < 0 then
  begin
    aBkColor := clBlue; //LONG_COLOR ;
    aFontColor := clWhite; //clBlack;
  end
  else Begin
    aBkColor := clWhite;
    aFontColor := clBlack; //clBlack;
  end ;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;

  // 4. ���ݿ��� Index �׸���
  DrawIndex(GetTickValue(FSymbol.DerivativeType, FAvgPrice), idxAvg, false ) ;

end;

// �򰡼���
procedure TOrderTablet.SetEvalPL(dValue: Double);
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect : TRect; 
begin
  // 1. value
  FEvalPL := dValue ;
  
  // 2. orInfo�� �׸���
  iLeft := FInfoLefts[itPL]  ;
  iRight := iLeft + FInfoWidths[itPL] ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ; 
  stText :=  Format('%.n', [FEvalPL]) ;
  //
  aBkColor := clWhite ;
  if dValue < 0 then  //
    aFontColor := clRed
  else
    aFontColor := clBlack;
  //
  aCopyRect := Rect( iLeft, iTop, iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;  
end;

// �̰��� �������� 
procedure TOrderTablet.SetOpenPosition(iValue: Integer);
var
  iLeft, iTop, iRight, iBottom : Integer ;
  stText : String ;
  aBkColor, aFontColor : TColor ;
  aCopyRect :  TRect ; 
begin
  // 1. value
  FOpenPosition := iValue ; 

  // 2. orInfo�� �׸���
  iLeft := FInfoLefts[itPosition]  ;
  iRight := iLeft + FInfoWidths[itPosition] ;
  iTop := 0 ;
  iBottom := DEFAULT_HEIGHT ;
  stText :=  IntToStr(FOpenPosition) ;
  //
  if FOpenPosition > 0 then  //
  begin
    aBkColor := clRed; //SHORT_COLOR ;
    aFontColor := clWhite; //clRed
  end
  else if FOpenPosition < 0 then
  begin
    aBkColor := clBlue; //LONG_COLOR ;
    aFontColor := clWhite; //clBlack;
  end
  else Begin
    aBkColor := clWhite;
    aFontColor := clBlack; //clBlack;
  end ;
  //
  aCopyRect := Rect( iLeft, iTop , iRight, iBottom ) ; 
  DrawInfoCell( aCopyRect, stText, aBkColor,aFontColor ) ;  
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



// iIndex �� ���� idxType�� ���� index�� ���� ���ؼ� ������ true, �ٸ��� false  
function TOrderTablet.DrawIndexYN(iIndex: Integer;
  idxType: TIndexType): Boolean;
var
  dValue : double ;
  i : Integer ;
begin

  Result := false ;
  // 
  if idxType = idxAvg then 
    dValue := GetTickValue(FSymbol.DerivativeType, FAvgPrice) 
  else if idxType = idxMin then
    dValue := FMinPrice
  else if idxType = idxMax then
    dValue := FMaxPrice ;
  // 
  i := FindIndex(dValue);      // get Index 
  //   
  if iIndex = i then
    Result := true ; 
  // 
end;

// �Ļ���ǰ�� TickValue
function TOrderTablet.GetTickValue(dType: TDerivativeType;
  price: Double): Double;
var
  aTickValue : double  ;
begin
  Result := 0;
  // 
  if (dType = dtOptions) and ( price <3.0-PRICE_EPSILON) then
    aTickValue := 0.01 
  else
    aTickValue := 0.05;
  //
  Result :=   Round(price/aTickValue+epsilon)*aTickValue;
end;

procedure TOrderTablet.InitSymbol(aSymbol: TSymbolItem);
var
  dPrice : Double;
  dHigh, dLow : Double;
begin
  //-- �ֹ�ǥ ����
  Clear;
  //
  NotifyChanged;
  //
  if aSymbol = nil then Exit;
  //-- ���� �Ҵ�
  FSymbol := aSymbol;
  RefreshTableItem ;

end;

function TOrderTablet.GetQtyIndex(aType: TQuoteType ; iRange : Integer ): Integer;
var
  dPrice : Double ; 
begin
  dPrice := FSymbol.Quote.Price[aType,iRange] ;
  Result := FindIndex(dPrice);
end;



function TOrderTablet.GetOrderColor(ptType: TPositionType;
  ctType: TColorType): TColor;
begin
  Result := FOrderColor[ptType, ctType] ;
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
