unit CleConsumerIndex;

interface

uses
  Classes,
  CleInvestorData, UOscillators;

type
  TConsumerIndex = class
  private

    FInvestorDatas : TInvestorDatas;
    FParas: TParaGathering;

  public
    constructor Create;
    destructor Destroy; override;
    property InvestorDatas : TInvestorDatas read FInvestorDatas;
    property Paras  : TParaGathering read FParas;
    procedure Reset;
  end;



implementation

{ TConsumerIndex }

constructor TConsumerIndex.Create;
begin
  FInvestorDatas := TInvestorDatas.Create;
  FParas:= TParaGathering.Create;
end;

destructor TConsumerIndex.Destroy;
begin
  FInvestorDatas.Free;
  FParas.Free;
  inherited;
end;

procedure TConsumerIndex.Reset;
begin
  FInvestorDatas.Free;
  FInvestorDatas := TInvestorDatas.Create;

  FParas.Clear;
end;

end.
