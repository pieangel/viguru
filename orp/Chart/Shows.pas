unit Shows;

interface

uses
  Classes, SysUtils, Graphics,

  CleStorage
  ;

type

  TShowMeName = ( snFill );
  TShowMeItem = class( TCollectionItem )
  public
    EnAbled : boolean;
    Name   : string;
    SType  : TShowMeName;
    Param  : string;
    AskColor  : TColor;
    BidColor  : TColor;
    OffSet    : integer;
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

  end;

  TShowMes  = class( TCollection )
  private
    function GetItem(i: integer): TShowMeItem;
  published
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( stName : string ) : TShowMeItem ;
    function Find( stName : string ): TShowMeItem;  overload;
    function Find( sType: TShowMeName ): TShowMeItem;  overload;
    property ShowMe[i : integer] : TShowMeItem read GetItem; default;
  end;

implementation

uses
  GAppEnv;

{ TShowMes }

constructor TShowMes.Create;
begin
  inherited Create( TShowMeItem );
end;

destructor TShowMes.Destroy;
begin

  inherited;
end;

function TShowMes.Find(sType: TShowMeName): TShowMeItem;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if GetItem(i).SType = sType then
    begin
      Result := GetItem(i);
      break;
    end;

end;

function TShowMes.Find(stName: string): TShowMeItem;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if GetItem(i).Name = stName then
    begin
      Result := GetItem(i);
      break;
    end;
end;

function TShowMes.GetItem(i: integer): TShowMeItem;
begin
  if ( i >=0 ) and ( i < Count ) then
    Result := Items[i] as TShowMeItem
  else
    Result := nil;
end;

function TShowMes.New(stName: string): TShowMeItem;
begin
  Result := Add as TShowMeItem;
  Result.Name := stName;
end;

{ TShowMeItem }

procedure TShowMeItem.LoadEnv(aStorage: TStorage);
var
  bSave : boolean;
begin
  if aStorage = nil then Exit;

  bSave := aStorage.FieldByName(Name+'Save').AsBoolean;
  if bSave then
  begin
    EnAbled  := aStorage.FieldByName(Name+'EnAbled').AsBoolean;
    Param    := aStorage.FieldByName(Name+'Param').AsString;
    AskColor := TColor( aStorage.FieldByName(Name+'AskColor').AsInteger );
    BidColor := TColor( aStorage.FieldByName(Name+'BidColor').AsInteger );
    OffSet   := aStorage.FieldByName(Name+'OffSet').AsInteger;
  end
  else  begin
    EnAbled  := false;
    Param    := '';
    AskColor := clBlue;
    BidColor := clRed;
    OffSet   := 1;
  end;

  {

  if SType = snFill then
  begin
    aAccount := gEnv.Engine.TradeCore.Accounts.Find( Trim(Param));
    gChart.SetAccount( aAccount );
  end
  else begin

  end;
  }
end;

procedure TShowMeItem.SaveEnv(aStorage: TStorage);
var
  stName : string;
begin
  if aStorage = nil then Exit;

 aStorage.FieldByName(Name+'Save').AsBoolean := true;
 aStorage.FieldByName(Name+'EnAbled').AsBoolean   := EnAbled;
 aStorage.FieldByName(Name+'Param').AsString   := Param;
 aStorage.FieldByName(Name+'AskColor').AsInteger   := Integer( AskColor );
 aStorage.FieldByName(Name+'BidColor').AsInteger   := Integer( BidColor );
 aStorage.FieldByName(Name+'OffSet').AsInteger   := OffSet;

end;


end.
