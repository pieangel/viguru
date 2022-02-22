unit CleLargeOrders;

interface

uses
  Classes,  SysUtils,  DateUtils,

  CleQuoteTimers

  ;

type
  TLargeOrder = class( TCollectionItem )
  public
    //Order : TOrderData;
    Time     : TDateTime;
    BetweenMi: int64;
    Side     : integer;
    Vol      : integer;
    Qty      : integer;
    FillQty  : integer;
    hoga     : integer;
    Price    : string;
    Position : string;
    Flash    : boolean;
  end;

  TLargeOrders  = class( TCollection )
  private
    FLastTime : TDateTime;

    FReadMaxQty: boolean;
    function GetLargeOrder(i: integer): TLargeOrder;
    procedure SetReadMaxQty(const Value: boolean);

 // published
  public
    Constructor Create;
    Destructor  Destroy; override;
    function New( dtTime : string ) : TLargeOrder;
    function LastLargeOrder : TLargeOrder;

    property LargeOrders[i: integer] : TLargeOrder read GetLargeOrder;
    property ReadMaxQty : boolean read FReadMaxQty write SetReadMaxQty;
  end;


implementation


{ TLargeOrders }

constructor TLargeOrders.Create;
begin
  inherited Create( TLargeOrder );

  ReadMaxQty := false;
end;

destructor TLargeOrders.Destroy;
begin

  inherited;
end;

function TLargeOrders.GetLargeOrder(i: integer): TLargeOrder;
begin
  if ( i<0 ) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as TLargeOrder;
end;

function TLargeOrders.LastLargeOrder: TLargeOrder;
begin
  if Count <= 0 then
    Result := nil
  else begin
    Result := Items[Count-1] as TLargeOrder;
    ReadMaxQty  := false;
  end;
end;

function TLargeOrders.New(dtTime : string): TLargeOrder;
begin
  Result := Add as TLargeOrder;
  Result.Time  := GetQuotedate
                 + EncodeTime(StrToInt(Copy(dtTime,1,2)), // hour
                              StrToInt(Copy(dtTime,3,2)), // min
                              StrToInt(Copy(dtTime,5,2)), // sec
                              StrToInt(Copy(dtTime,7,2)) *10 ); // msec}
  if Count = 1 then
    Result.BetweenMi  := 0
  else
    Result.BetweenMi  := MilliSecondsBetween( Result.Time, FLastTime );

  FLastTime := Result.Time;
  ReadMaxQty := true;
  Result.Flash := true;
end;


procedure TLargeOrders.SetReadMaxQty(const Value: boolean);
begin
  FReadMaxQty := Value;
end;

end.
