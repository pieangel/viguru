unit CleOtherData;

interface

uses
  Classes, SysUtils,

  CleSymbols

  ;

type



  TOtherDataIF = class( TCollectionItem )
  public
    Flash   : boolean;
    Symbol  : TSymbol;
    DataType: string;
    EntryTime : TDateTime;
    Constructor Create( aColl : TCollection ) ; override;
  end;

  TEntryPrice = Class( TOtherDataIF )
  public
    Side  : char;
    Sign  : char;
    ASkVol  : integer;
    BidVol  : integer;
    AskPrice   : double;
    BidPrice   : double;

    function GetText : string ;
  End;

  TUpDownPrice = Class( TOtherDataIF )
  public
    Side  : char;

    ASkVol  : integer;
    BidVol  : integer;
    AskPrice   : double;
    BidPrice   : double;
    function GetText : string;
  End;


  TOtherDataType  = ( odtEntry, odtUpDown );
  TOtherDataUpdate = procedure( aData : TOtherDataIF ) of object;


  TOtherData = class( TCollection )
  private
    FUpdateEvent: TOtherDataUpdate;
    FDataType: TOtherDataType;
    function GetData(i: integer): TOtherDataIF;

    procedure SetEvent(const Value: TOtherDataUpdate);

  public
    Constructor Craete( odtType : TOtherDataType ) ; overload;
    Destructor  Destroy; override;

    function New( aSymbol : TSymbol ) : TOtherDataIF;
    function Find( aSymbol: TSymbol ) : TOtherDataIF;

    property DataType : TOtherDataType read FDataType write FDataType;
    property OtherData[ i : integer ] : TOtherDataIF read GetData;
    //property UpdateEvent : TOtherDataUpdate read FUpdateEvent write FUpdateEvent;
    property UpdateEvent : TOtherDataUpdate read FUpdateEvent write SetEvent;
  end;

  TOtherDataItem = class( TCollectionItem )
  public
    OtherData  : TOtherData;
    constructor Create(aColl: TCollection ); override;
    Destructor  Destroy; override;
    procedure init( aType :  TOtherDataType );
  end;


  TOthers = class( TCollection )
  public
    Constructor Create;
    Destructor  Destroy; override;

    function Find( odtType : TOtherDataType ) : TOtherData;
  end;


implementation

uses
  GAppEnv;

{ TEntris }

constructor TOtherData.Craete( odtType : TOtherDataType );
begin
  case odtType of
    odtEntry: inherited Create( TEntryPrice );
    odtUpDown: inherited Create( TUpDownPrice );
  end;

  FDataType := odtType;
end;

destructor TOtherData.Destroy;
begin

  inherited;
end;

function TOtherData.Find(aSymbol: TSymbol): TOtherDataIF;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if GetData(i).Symbol = aSymbol then
    begin
      Result := GetData(i);
      Break;
    end;
end;

function TOtherData.GetData(i: integer): TOtherDataIF;
begin
  if ( i<0 ) or ( i>=Count) then
    Result := nil
  else
    Result := Items[i] as TOtherDataIF;
end;



function TOtherData.New(aSymbol: TSymbol): TOtherDataIF;
begin
  Result := Add as TOtherDataIF;
  Result.Symbol := aSymbol;
end;


procedure TOtherData.SetEvent(const Value: TOtherDataUpdate);
begin
{
  case FDataType of
    odtEntry: gEnv.EnvLog( WIN_TEST, 'odtEntry');
    odtUpDown: gEnv.EnvLog( WIN_TEST, 'odtUpDown');
  end;
  }
  FUpdateEvent := Value;
end;

{ TOtherDataIF }

constructor TOtherDataIF.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  Flash := true;
end;

{ TUpDownPrice }

function TUpDownPrice.GetText: string;
begin
  Result := Format(' Time : %s' +
                   ' LS : %s' +
                   ' 매도잔량 : %d' +
                   ' 매수잔량 : %d' +
                   ' 매도가 : %.2f' +
                   ' 매수가 : %.2f',
                   [
                     FormatDateTime('hh:nn:ss.zz', EntryTime),
                     Side,
                     AskVol,
                     BidVol,
                     AskPrice,
                     BidPrice
                   ]);
end;

{ TEntryPrice }

function TEntryPrice.GetText: string;
begin
  Result := Format(' Time : %s' +
                   ' Type : %s' +
                   ' LS : %s' +
                   ' 구분 : %s ' +
                   ' 매도잔량 : %d' +
                   ' 매도가 : %.2f' +
                   ' 매수가 : %.2f' +
                   ' 매수잔량 : %d',
                   [
                     FormatDateTime('hh:nn:ss.zz', EntryTime),
                     DataType,
                     Side,
                     Sign,
                     AskVol,
                     AskPrice,
                     BidPrice,
                     BidVol
                   ]);
end;

{ TOtherDataItem }

constructor TOtherDataItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
end;

destructor TOtherDataItem.Destroy;
begin
  OtherData.Free;
  inherited;
end;

procedure TOtherDataItem.init(aType: TOtherDataType);
begin
  OtherData := TOtherData.Craete( aType );
end;

{ TOthers }

constructor TOthers.Create;
var
  aItem : TOtherDataItem;
begin
  inherited Create( TOtherDataItem );
  aItem := Add as TOtherDataItem;
  aItem.init( odtEntry);

  aItem := Add as TOtherDataItem;
  aItem.init( odtUpDown);
end;

destructor TOthers.Destroy;
begin

  inherited;
end;

function TOthers.Find(odtType: TOtherDataType): TOtherData;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if ( Items[i] as TOtherDataItem).OtherData.DataType = odtType then
    begin
      Result := ( Items[i] as TOtherDataItem).OtherData;
      break;
    end;
end;

end.
