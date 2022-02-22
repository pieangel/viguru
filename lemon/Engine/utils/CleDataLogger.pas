unit CleDataLogger;

interface

uses
  Classes, SysUtils,

  CleAccounts
  ;

type

  TLogDataField = class( TCollectionItem )
  public

    Account : TAccount;
    MaxPL   : double ;
    MinPL   : double;
    PL      : double;

    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;
  end;

  TLogDataFields = class( TCollection )
  private
    function GetLogDataField(i: integer): TLogDataField;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aAcnt : TAccount ) : TLogDataField;
    function Find(aAcnt : TAccount ) : TLogDataField;

    property LogDataField[ i : integer] : TLogDataField read GetLogDataField;
  end;

  {
  TLogDataItem = class( TCollectionItem )
  public
    LogDataFields : TLogDataFields;
    LogDadte      : TDateTime;

    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;
  end;


  TLogDataItems = class( TCollection )
  private
    function GetLogDataItem(i: integer): TLogDataItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( dtDate : TDateTime ) : TLogDataItem;
    function Find(dtDate : TDateTime ) : TLogDataItem;

    property LogDataItem[ i : integer ] : TLogDataItem read GetLogDataItem;
  end;
   }


implementation

{ TLogDataField }

constructor TLogDataField.Create(aColl: TCollection);
begin
  inherited Create( aColl );

  Account := nil;
  MaxPL   := 0;
  MinPL   := 1;
  PL      := 0;
end;

destructor TLogDataField.Destroy;
begin

end;

{ TLogDataFields }

constructor TLogDataFields.Create;
begin
  inherited Create( TLogDataField );
end;

destructor TLogDataFields.Destroy;
begin

  inherited;
end;

function TLogDataFields.Find(aAcnt: TAccount): TLogDataField;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetLogDataField(i).Account = aAcnt then
    begin
      Result := GetLogDataField(i);
      break;
    end;
end;

function TLogDataFields.GetLogDataField(i: integer): TLogDataField;
begin

end;

function TLogDataFields.New(aAcnt: TAccount): TLogDataField;
begin

end;


{ TLogDataItem }

{

constructor TLogDataItem.Create(aColl: TCollection);
begin
  inherited;

end;

destructor TLogDataItem.Destroy;
begin

  inherited;
end;

{ TLogDataItems }
{

constructor TLogDataItems.Create;
begin

end;

destructor TLogDataItems.Destroy;
begin

  inherited;
end;

function TLogDataItems.Find(dtDate: TDateTime): TLogDataItem;
begin

end;

function TLogDataItems.GetLogDataItem(i: integer): TLogDataItem;
begin

end;

function TLogDataItems.New(dtDate: TDateTime): TLogDataItem;
begin

end;

}


end.
