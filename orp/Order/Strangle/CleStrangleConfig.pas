unit CleStrangleConfig;

interface

uses
  Classes
  ;

type

  TOrderMethodType = ( omBuy, omSell, omSpBuy, omSpSell );

  TInvestStrangleParam = record
    OrdQty     : integer;
    EntryCnt   : integer;
    LiskAmt, RvsAmt    : double;    //  단위 : 만

    Endtime : TDateTime;
    StartTime : TDateTime;

    UseCnt : boolean;
    UseInvest: boolean;
    UseLiq   : boolean;
    UseHedge : boolean;

    OrderMethod : TOrderMethodType;

    Ivt1Code, Ivt2Code : string;

    Ivt1Plue  : array [0..4] of boolean;
    Ivt1Value : array [0..4] of double;
    Ivt1Minus : array [0..4] of boolean;

    Ivt2Plue  : array [0..4] of boolean;
    Ivt2Value : array [0..4] of double;
    Ivt2Minus : array [0..4] of boolean;
  end;

  TUnderStrangleParam = record
    OrdQty     : integer;
    EntryCnt   : integer;
    LiskAmt    : double;          // 단위 : 만

    Endtime : TDateTime;
    StartTime : TDateTime;

    UseLiq   : boolean;
    OrderMethod : TOrderMethodType;

    UndPlus  : array [0..4] of boolean;
    UndValue : array [0..4] of double;
    UndMinus : array [0..4] of boolean;
  end;


  TOrderCon = class( TCollectionItem )
  public
    Value   : double;
    Checked : boolean;
    Ordered : boolean;
  end;

  TOrderCons = class( TCollection )
  private
    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
    function GetLevel(i: Integer): TOrderCon;
  public
    constructor Create;
    property Size: Integer read GetSize write SetSize;
    property Level[i:Integer]: TOrderCon read GetLevel; default;

    function GetNextLv : TOrderCon;
    function GetOrderedCnt : integer;
  end;

implementation

{ TOrderCons }

constructor TOrderCons.Create;
begin
  inherited Create( TOrderCon );
end;

function TOrderCons.GetLevel(i: Integer): TOrderCon;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOrderCon
  else
    Result := nil;
end;

function TOrderCons.GetNextLv: TOrderCon;
var
  I, itmp : Integer;
  aCon : TOrderCon;
begin
  Result := nil;

  itmp := 0;

  for I := 0 to Count - 1 do
  begin
    aCon := GetLevel(i);
    if ( aCon.Checked ) and ( aCon.Ordered ) then
      if i > itmp then
        itmp := i;
  end;

  for I := 0 to Count - 1 do
  begin
    aCon  := GetLevel(i);
    if ( aCon.Checked ) and ( not aCon.Ordered ) and ( itmp <= i ) then
    begin
      Result := aCon;
      break;
    end;
  end;
    
end;

function TOrderCons.GetOrderedCnt: integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if GetLevel(i).Ordered then
      inc(Result);
end;

function TOrderCons.GetSize: Integer;
begin
  Result := Count;
end;

procedure TOrderCons.SetSize(const Value: Integer);
var
  i: Integer;
begin
  if Value > 0 then
    if Value > Count then
    begin
      for i := Count to Value-1 do Add;
    end else
    if Value < Count then
    begin
      for i := Count-1 downto Value do Items[i].Free;
    end
end;

end.
