unit ClePaveManager;

interface

uses
  Classes, SysUtils, Math,

  CleSymbols, CleQuoteBroker, CleOrders, CleAccounts, ClePositions,

  CleDistributor,

  UObjectBase, UPriceAxis, CleHultAxis, CleReEatTrend, CleBHultEx, ClePaveOrders,
  GleConsts, GleTypes
  ;

type

  TPaveManager = class( TCollection )
  private
    FPavers: TPaveOrders;
    function GetPave(i: integer): TTradeBase;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aAccount : TAccount; aSymbol : TSymbol; aType : TOrderSpecies ) : TTradeBase;
    function Find(aAccount : TAccount; aSymbol : TSymbol; aType : TOrderSpecies ) : TTradeBase;

    procedure Delivery( aData : TObject; DataType : integer; EventType : TDistributorID );
    procedure RemvoePave( aPave : TTradeBase );

    property PaveItem[ i : integer] : TTradeBase read GetPave;

    property Pavers : TPaveOrders read FPavers;

  end;  


implementation

uses
  GAppEnv
  ;

{ TPaveManager }

constructor TPaveManager.Create;
begin
  inherited Create( TTradeBase );

  FPavers:= TPaveOrders.Create;
end;

procedure TPaveManager.Delivery(aData: TObject; DataType: integer;
  EventType: TDistributorID);
var
  I: Integer;
  aOrder : TOrder;
  aPos  : TPosition;
  aQuote : TQuote;
begin

  case DataType of
    TRD_DATA : FPavers.OnOrder( aData as TOrder, EventType );
    QTE_DATA : FPavers.OnQuote( aData as TQuote, integer( EventType ) + 256 );
    POS_DATA : FPavers.OnPosition( aData as TPosition, EventType );
  end;

  ///////////////

  for I := 0 to Count - 1 do
  begin
    if GetPave(i) = nil then Continue;

    case DataType of
      TRD_DATA :
        begin
          aOrder:= aData as TOrder;

          if (( aOrder.OrderSpecies = TOrderSpecies(GetPave(i).TradeSpecies) ) or
            ( aOrder.OrderSpecies = opNormal )) and
            ( aOrder.Account = GetPave(i).Account ) and
            ( aOrder.Symbol  = GetPave(i).Symbol ) then
            GetPave(i).OnOrder( aOrder , EventType ) ;
        end;
      QTE_DATA :
        begin
          aQuote := aData as TQuote;
          if ( aQuote.Symbol  = GetPave(i).Symbol ) then
          GetPave(i).OnQuote( aQuote, integer( EventType ) + 256 );
        end;
      POS_DATA :
        begin
          aPos := aData as TPosition;
          if( aPos.Account = GetPave(i).Account ) and
            ( aPos.Symbol  = GetPave(i).Symbol ) then
            GetPave(i).OnPosition( aPos, EventType ) ;
        end;
    end;
  end;
end;

destructor TPaveManager.Destroy;
begin
  FPavers.Free;
  inherited;
end;

function TPaveManager.Find(aAccount: TAccount; aSymbol: TSymbol;  aType : TOrderSpecies): TTradeBase;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetPave(i) <>  nil then
      if ( GetPave(i).Symbol = aSymbol ) and ( GetPave(i).Account = aAccount ) and
        ( TOrderSpecies(GetPave(i).TradeSpecies) = aType ) then
      begin
        Result := GetPave(i);
        break;
      end;
    
end;

function TPaveManager.GetPave(i: integer): TTradeBase;
begin
  if (i<0) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as TTradeBase;
end;

function TPaveManager.New(aAccount: TAccount; aSymbol: TSymbol;  aType : TOrderSpecies): TTradeBase;
begin
  Result := Find( aAccount, aSymbol, aType );
  if Result = nil then
  begin

    case aType of
      opNormal: ;
      opJarvis  : Result := TBHultEx.Create(Self );
      opPDT     : Result := TReEatTrend.Create( Self );
      opEvolHult: Result := TPriceAxis.Create( Self );
    end;
  end;
end;

procedure TPaveManager.RemvoePave(aPave: TTradeBase);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetPave(i) = aPave then
    begin
      Delete(i);
      break;
    end;
end;

end.

