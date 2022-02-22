unit CleConsumerIndex;

interface

uses
  Classes,
  VolatilityKOSPIIndex, CleInvestorData, UOscillators;

type
  TConsumerIndex = class
  private
    FVIX: TVolatilityIndex;
    FInvestorDatas : TInvestorDatas;
    FParas: TParaGathering;
  public
    constructor Create;
    destructor Destroy; override;
    property VIX       : TVolatilityIndex read FVIX;
    property InvestorDatas : TInvestorDatas read FInvestorDatas;
    property Paras  : TParaGathering read FParas;

    procedure Reset;
  end;



implementation

{ TConsumerIndex }

constructor TConsumerIndex.Create;
begin
  FVIX:= TVolatilityIndex.Create;
  FInvestorDatas := TInvestorDatas.Create;
  FParas:= TParaGathering.Create;
end;

destructor TConsumerIndex.Destroy;
begin
  FParas.Free;
  FVIX.Free;
  FInvestorDatas.Free;
  inherited;
end;

procedure TConsumerIndex.Reset;
begin
  FVIX.Free;
  FInvestorDatas.Free;

  FVIX:= TVolatilityIndex.Create;
  FInvestorDatas := TInvestorDatas.Create; 
  FParas.Clear;
end;

end.
