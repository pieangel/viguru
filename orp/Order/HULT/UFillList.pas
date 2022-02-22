unit UFillList;

interface

uses
  Classes, SysUtils, DateUtils,

  CleOrders, CleFills, CleQuoteBroker,

  GleTypes, GleConsts, GleLib

  ;

type

  TFillItem = class( TCollectionItem )
  public
    Time  : TDateTime;
    Price : double;
    Qty   : integer;
    Side  : integer;
    Index : integer;
    PosType : TPositionType;
    Order : TOrder;
  end;

  TFillList = class( TCollection )
  private
    FSide: integer;
    FLastItem: TFillItem;
    function GetFillItem(i: integer): TFillItem;
    procedure SetSide(const Value: integer);
    function GetItem: TFillItem;
  public
    constructor Create;
    Destructor  Destroy; override;

    function New( dtTime : TDateTime ) : TFillItem;
    function GetDistance( nTime : TDateTime ) : integer;

    property FillItem[ i : integer] : TFillItem read GetFillItem;
    property Side : integer read FSide write SetSide;
    property LastItem : TFillItem read GetItem write FLastItem;
  end;


implementation

{ TFillList }

constructor TFillList.Create;
begin
  inherited Create( TFillItem );
end;

destructor TFillList.Destroy;
begin

  inherited;
end;

function TFillList.GetDistance(nTime: TDateTime): integer;
begin
  if Count = 0 then Result := -1
  else
    Result := MilliSecondsBetween( nTime, GetFillItem(Count-1).Time );
end;

function TFillList.GetFillItem(i: integer): TFillItem;
begin
  if ( i<0 ) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as TFillItem;
end;

function TFillList.GetItem: TFillItem;
begin
  Result := FLastItem;
end;

function TFillList.New(dtTime: TDateTime): TFillItem;
begin
  Result := Add as TFillItem;
  Result.Time := dtTime;
  Result.Order  := nil;
  FLastItem := Result;
end;

procedure TFillList.SetSide(const Value: integer);
begin
  if FSide <> Value then
    Clear;

  FSide := Value;
end;

end.
