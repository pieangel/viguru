unit CleConcernSymbolItems;

interface

uses
  Classes, SysUtils,

  CleSymbols

  ;
const

  TitleCount = 37;

  Titles : array [0..TitleCount-1] of string = (
  '종목코드',
  '매도5','매도4','매도3', '매도2', '매도1',
  '현재가','잔량가중',
  '매수1', '매수2', '매수3','매수4', '매수5',
  '매도5','매도4','매도3', '매도2', '매도1',
  '현재가','잔량가중',
  '매수1', '매수2', '매수3','매수4', '매수5',
  'IV', 'Delta', 'Gamma', 'Vega', 'Theta', 'Rho',
  '행사가', '전환비율', '배당금', '잔존일', '잔존1', '잔존2'
  );


  Visibles : array [0..TitleCount-1] of boolean = (
  true,
  false, false, false, true, true,
  true, true,
  true, true, false, false, false,
  false, false, false, true, true,
  true, true,
  true, true, false, false, false,
  true, true, false, false, false, false,
  true, true, true, true, true, true
  );
  {
  Sizes : array [0..TitleCount-1] of integer = (
  100
  );
  }


type

  TitleItem = record
    Title : string;
    Visible : boolean;
  end;


  TConcernItem = class( TCollectionItem )
  public
    Symbol  : TSymbol;
  end;


  TConcernItems = class( TCollection )
  private
    function GetConcnernItem(i: integer): TConcernItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aSymbol : TSymbol ) : TConcernItem;
    function Find( aSymbol : TSymbol) : TConcernItem;

    property ConcerItems[ i : integer] : TConcernItem read GetConcnernItem;
  end;


implementation

{ TConcernItems }

constructor TConcernItems.Create;
begin
  inherited Create( TConcernItem );
end;

destructor TConcernItems.Destroy;
begin

  inherited;
end;

function TConcernItems.Find(aSymbol: TSymbol): TConcernItem;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if (Items[i] as TConcernItem).Symbol = aSymbol then
    begin
      Result := Items[i] as TConcernItem;
      break;
    end;
end;

function TConcernItems.GetConcnernItem(i: integer): TConcernItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TConcernItem;
end;

function TConcernItems.New(aSymbol: TSymbol): TConcernItem;
begin
  Result := Add as TConcernItem;
  Result.Symbol := aSymbol;

end;



end.
