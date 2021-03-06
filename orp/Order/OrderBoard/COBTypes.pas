unit COBTypes;

interface

uses
  Classes, Graphics, Windows
  ;

const
  RowCount = 5;
  ColCount = 3;
  DefSet : //array [0..ColCount*RowCount-1] of integer
    array [0..RowCount-1, 0..ColCount-1] of integer
    = ( (1, 10, 50),
        (100,120, 150),
        (150, 200,220),
        ( 7, 9, 8),
        (0, 0,0)
    );

  IDX_LONG = 0;
  IDX_SHORT = 1;
  IDX_ORDER = 0;
  IDX_QUOTE = 1;
  IDX_FONT = 0;
  IDX_BACKGROUND = 1;


type
  // key order type
  TKeyOrderType = ( kotNewLong, kotNewLong1, kotNewShort, kotNewShort1, kot2BidAsk, kot3BidAsk, kot4BidAsk, kot5BidAsk );


  TEventType = ( etQty, etSpace, etStop, etMain );
  TValueType = ( vtAdd, vtDelete, vtUpdate );

  TBoardKeyType = ( ktNone , ktSpace, ktCtrl, ktAlt, ktEsc );


  //TCtrlState = ( csCtrl, csShift, csAlt );

  TOrderBoardPrefs = record

    OrderKey  : TBoardKeyType;
    RangeKey  : TBoardKeyType;
      // generic
    BoardCount: Integer; // number of Order Board
      // board
    AutoScroll: Boolean;     // 자동 스크롤
    TraceMouse: Boolean;     // MouseTrace : Boolean;  // 마우스 포인터 위치 행사가에 표시하기

    DbClickOrder : boolean;
    MouseSelect : boolean;   // 마우스 선택
    LastOrdCnl: boolean;

    UseKeyOrder : boolean;
    Colors: array[0..1,0..1,0..1] of TColor;

    ConfirmSetNetQty     : boolean;
    Show1000unit : boolean;
    DataIndex    : integer;
    {
    // 추가된 손절 설정들...2016.03.14
    UsePrfLiquid   : boolean;
    UseLosLiquid   : boolean;
    PrfTick, LosTick : integer;

    // 계좌 손절
    UseMarketPrc   : boolean;   // 자동 청산주문을 시장가로..
    LiquidTick     : integer;
    StopTick        : integer;
    FixedHoga    : boolean;
    }
  end;


  TBaseItem = class( TCollectionItem )
  public
    Name : string;
    State : boolean;
  end;

  TQtyItem = class( TBaseItem )
  public
    QtySet  : array [0..RowCount-1, 0..ColCount-1] of integer;
  end;

  TQtyItems = class( TCollection )
  private
    function GetQtyItem(i: integer): TQtyItem;
    function Find( stName : string ) : TQtyItem;
  public
    DefQtySet : array [0..RowCount-1, 0..ColCount-1] of integer;
    Constructor Create;
    Destructor  Destroy; override;

    procedure GetList(aList: TStrings);
    function New( stName : string ) : TQtyItem;
    function Del( aItem : TQtyItem) : boolean;
    property QtyItem[ i : integer] : TQtyItem read GetQtyItem;  default;

  end;

  TQtyEvent = procedure(Sender : TObject; DataObj: TObject;
    etType: TEventType; vtType : TValueType ) of object;
  TBoardPanelEvent = procedure( Sender : TObject; iDiv , iTag : integer ) of object;


const
  BoardKey :  array [TBoardKeyType] of word  =
        ( 0, VK_SPACE, VK_CONTROL, VK_MENU, VK_ESCAPE );


implementation

{ TQtyItems }


constructor TQtyItems.Create;
var
  i , j : integer;
  aItem : TQtyItem;
begin
  inherited Create( TQtyItem );

  aItem := New( 'Default' );

  with aItem do
    for i := 0 to ColCount - 1 do
      for j := 0 to Rowcount - 1 do
        QtySet[i,j] := DefSet[i,j];
end;

function TQtyItems.Del(aItem: TQtyItem): boolean;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    if GetQtyItem(i) = aItem then
    begin
      Delete( i );
      break;
    end;

end;

destructor TQtyItems.Destroy;
begin

  inherited;
end;


function TQtyItems.Find(stName: string): TQtyItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if GetQtyItem(i).Name = stName then
    begin
      Result := GetQtyItem(i);
      break;
    end;
    
end;

procedure TQtyItems.GetList(aList: TStrings);
var
  i: Integer;
  aItem: TQtyItem;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aItem := GetQtyItem(i);
    aList.AddObject(aItem.Name , aItem);
  end;     

end;

function TQtyItems.GetQtyItem(i: integer): TQtyItem;
begin
  if ( i<0) or ( i>=Count) then
    Result := nil
  else
    Result := Items[i] as TQtyItem;
end;

function TQtyItems.New(stName: string): TQtyItem;
begin
  Result := Find( stName );
  if Result = nil then
  begin
    Result := Add as TQtyItem;
    Result.Name := stName;
  end;
end;

end.
