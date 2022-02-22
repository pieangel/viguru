unit CleSymbolDaily;

interface

uses
  Classes, SysUtils
  ;

type

  TDBItem = class( TCollectionItem )
  public
    Date  : TDateTime;
    Code  : string;
  end;

  TDailyItem  = class(TDBItem )
  public
    High : double;
    Low  : double;
  end;

  TDailyItems = class( TCollection )
  private
    function GetDailyItem(i: integer): TDailyItem;

  public
    constructor create;
    destructor  destroy; override;

    function new( stCode : string ) : TDailyItem;
    function find( stCode : string ) : TDailyItem; 

    property DailyItem[ i : integer] : TDailyItem read GetDailyItem;
  end;



implementation

{ TDailyItems }

constructor TDailyItems.create;
begin
  inherited Create( TDailyItem );
end;

destructor TDailyItems.destroy;
begin

  inherited;
end;

function TDailyItems.find(stCode: string): TDailyItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if GetDailyItem(i).Code = stCode then
    begin
      Result := GetDailyItem(i);
      break;
    end;    
end;

function TDailyItems.GetDailyItem(i: integer): TDailyItem;
begin
  if ( i<0 ) or ( i>=Count) then
    result := nil
  else
    result := Items[i] as TDailyItem;
end;

function TDailyItems.new(stCode: string): TDailyItem;
begin
  Result := Add as TDailyItem;
  Result.Code := stCode;
end;

end.
