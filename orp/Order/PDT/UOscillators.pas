unit UOscillators;

interface

uses
  Classes, SysUtils,

  UObjectBase,

  CleSymbols, CleOrders, CleAccounts, ClePositions,

  CleDistributor,  UOscillatorBase,

  GleTypes , GleConsts

  ;

type


  TOscillators = class( TCollection )
  private
    function GetOscillator(i: integer): TTradeBase;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aAccount : TAccount; aSymbol : TSymbol; aType : TOscillatorType ) : TTradeBase;
    function Find(aAccount : TAccount; aSymbol : TSymbol; aType : TOscillatorType ) : TTradeBase;

    procedure Delivery( aData : TObject; DataType : integer; EventType : TDistributorID );
    procedure RemvoeOscillator( aPave : TTradeBase );

    property Oscillator[ i : integer] : TTradeBase read GetOscillator;
  end;


  TParaGathering = class( TCollection )
  private
    function GetPara(i: integer): TParabolicSignal;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aSymbol : TSymbol; iAcclFact : double ) : TParabolicSignal;
    function Find(aSymbol : TSymbol; iAcclFact : double) : TParabolicSignal;

    procedure Delivery( aData : TObject; DataType : integer; EventType : TDistributorID );

    property ParaItem[ i : integer] : TParabolicSignal read GetPara;
  end;

implementation

uses
  CleQuoteBroker
;

{ TOscillators }

constructor TOscillators.Create;
begin
  inherited Create( TTradeBase );
end;

procedure TOscillators.Delivery(aData: TObject; DataType: integer;
  EventType: TDistributorID);
var
  I: Integer;
  aOrder : TOrder;
  aPos  : TPosition;
  aQuote : TQuote;
begin
  for I := 0 to Count - 1 do
  begin
    if GetOscillator(i) = nil then Continue;

    case DataType of
      TRD_DATA :
        begin

        end;
      QTE_DATA :
        begin
          aQuote := aData as TQuote;
          if ( aQuote.Symbol  = GetOscillator(i).Symbol ) then
            GetOscillator(i).OnQuote( aQuote, integer( EventType)+ 256 );
        end;
        {
      POS_DATA :
        begin
          aPos := aData as TPosition;
          if( aPos.Account = GetOscillator(i).Account ) and
            ( aPos.Symbol  = GetOscillator(i).Symbol ) then
            GetOscillator(i).OnPosition( aPos, EventType ) ;
        end;
        }
    end;
  end;

end;

destructor TOscillators.Destroy;
begin

  inherited;
end;

function TOscillators.Find(aAccount: TAccount; aSymbol: TSymbol;
  aType: TOscillatorType): TTradeBase;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetOscillator(i) <>  nil then
      if ( GetOscillator(i).Symbol = aSymbol ) and ( GetOscillator(i).Account = aAccount ) and
        ( TOscillatorType(GetOscillator(i).TradeSpecies) = aType ) then
      begin
        Result := GetOscillator(i);
        break;
      end;

end;

function TOscillators.GetOscillator(i: integer): TTradeBase;
begin
  if (i<0) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as TTradeBase;
end;

function TOscillators.New(aAccount: TAccount; aSymbol: TSymbol;
  aType: TOscillatorType): TTradeBase;
begin
  Result := Find( aAccount, aSymbol, aType );
  if Result = nil then
  begin
    case aType of
      oscSAR: Result := TParabolicSignal.Create( Self ) ;
      //oscDMI: Result := TDMISiganl.Create( Self );
    end;
  end;
end;

procedure TOscillators.RemvoeOscillator(aPave: TTradeBase);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetOscillator(i) = aPave then
    begin
      Delete(i);
      break;
    end;
end;

{ TParaGathering }

constructor TParaGathering.Create;
begin
  inherited Create( TParabolicSignal );
end;

procedure TParaGathering.Delivery(aData: TObject; DataType: integer;
  EventType: TDistributorID);
var
  I: Integer;
  aOrder : TOrder;
  aPos  : TPosition;
  aQuote : TQuote;
begin
  for I := 0 to Count - 1 do
  begin
    if GetPara(i) = nil then Continue;

    case DataType of
      TRD_DATA :
        begin

        end;
      QTE_DATA :
        begin
          aQuote := aData as TQuote;
          if ( aQuote.Symbol  = GetPara(i).Symbol ) then
            GetPara(i).OnQuote( aQuote, integer( EventType)+ 256 );
        end;
        {
      POS_DATA :
        begin

        end;
        }
    end;
  end;
end;

destructor TParaGathering.Destroy;
begin

  inherited;
end;

function TParaGathering.Find(aSymbol: TSymbol;
  iAcclFact: double): TParabolicSignal;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if ( GetPara(i).Symbol = aSymbol ) and ( GetPara(i).AcclFact = iAcclFact ) then
    begin
      Result  := GetPara(i);
      break;
    end;
end;

function TParaGathering.GetPara(i: integer): TParabolicSignal;
begin
  if (i<0) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as TParabolicSignal;
end;

function TParaGathering.New(aSymbol: TSymbol;
  iAcclFact: double): TParabolicSignal;
begin
  Result  := Find( asymbol, iAcclFact );

  if Result = nil then
  begin
    Result  := Add as  TParabolicSignal;
    REsult.AcclFact := iAcclFact;
    Result.init2( aSymbol, integer(oscSAR) );
  end;
end;

end.

