unit CleFilltering;

interface
uses Classes, Dialogs, SysUtils,
  CleAccounts, CleOrders, ClePositions, CleFQN, CleSymbols
  ;



const
  STATUS = 4;
  MARKET = 7;
  ACNT_TOT = '전체';
  MarketType : array[0..MARKET-1] of string =
    ('전체', '선물옵션', '선물', '옵션', 'Call', 'Put', '주식');

  OrderStatus : array[0..STATUS-1] of string =
    ('증전접수', '전량체결', '정정확인', '취소확인');



type
  TIssueType = (itTot, itFO, itF, itO, itOC, itOP, itS);
  TFillter = class
  private
    FAccount : string;
    FMarket : TIssueType;
    FStatus : TOrderStates;
  public
    constructor Create();
    destructor Destroy; override;
    property stAccount : string read FAccount;
    property Market : TIssueType read FMarket;
    property Status : TOrderStates read FStatus;
    procedure SetFillterData( stAcc : string; iMarket : integer; aStats : TOrderStates = [] );
    function Fillter(DataObj : TObject): Boolean;
  end;
implementation

{ TFillter }

constructor TFillter.Create();
begin
  FAccount := '';
end;

destructor TFillter.Destroy;
begin

  inherited;
end;

function TFillter.Fillter(DataObj: TObject): Boolean;
var
  aOrder : TOrder;
  aPosition : TPosition;
  stCode : string;
begin
  Result := false;
  if DataObj = nil then exit;

  if DataObj is TOrder then                             //주문리스트
  begin
    aOrder := DataObj as TOrder;

    if ((aOrder.Account.Code = FAccount) or (FAccount = ACNT_TOT)) and (aOrder.State in FStatus) then
    begin
      case FMarket of
        itTot: Result := true;
        itFO:
          begin
            if aOrder.Symbol.Spec.Market in [mtFutures, mtOption] then
              Result := true;
          end;
        itF:
          begin
            if aOrder.Symbol.Spec.Market in [mtFutures] then
              Result := true;
          end;
        itO:
          begin
            if aOrder.Symbol.Spec.Market in [mtOption] then
              Result := true;
          end;
        itOC:
          begin
            if aOrder.Symbol.Spec.Market in [mtOption] then
            begin
            if aOrder.Symbol.OptionType = otCall then
                Result := true;
            end;
          end;
        itOP:
          begin
            if aOrder.Symbol.Spec.Market in [mtOption] then
               if aOrder.Symbol.OptionType = otPut then
                 Result := true;
          end;
        itS:
          begin
            if aOrder.Symbol.Spec.Market in [mtStock] then
              Result := true;
          end;
      end;
    end else
      Result := false;
  end
  else if DataObj is TPosition then                     //포지션리스트
  begin
    aPosition := DataObj as TPosition;
    if (aPosition.Account.Code = FAccount)  or (FAccount = ACNT_TOT) then
    begin
      case FMarket of
        itTot: Result := true;
        itFO:
          begin
            if aPosition.Symbol.Spec.Market in [mtFutures, mtOption] then
              Result := true;
          end;
        itF:
          begin
            if aPosition.Symbol.Spec.Market in [mtFutures] then
              Result := true;
          end;
        itO:
          begin
            if aPosition.Symbol.Spec.Market in [mtOption] then
              Result := true;
          end;
        itOC:
          begin
            if aPosition.Symbol.Spec.Market in [mtOption] then
              if aPosition.Symbol.OptionType = otCall then
                Result := true;
          end;
        itOP:
          begin
            if aPosition.Symbol.Spec.Market in [mtOption] then
              if aPosition.Symbol.OptionType = otPut then
                 Result := true;
          end;
        itS:
          begin
            if aPosition.Symbol.Spec.Market in [mtStock] then
              Result := true;
          end;
      end;
    end else
      Result := false;
  end;

end;

procedure TFillter.SetFillterData(stAcc: string; iMarket: integer;
  aStats : TOrderStates );
begin
  FAccount :=  stAcc;
  case iMarket of
  0 : FMarket := itTot;
  1 : FMarket := itFO;
  2 : FMarket := itF;
  3 : FMarket := itO;
  4 : FMarket := itOC;
  5 : FMarket := itOP;
  6 : FMarket := itS;
  end;
  FStatus := aStats;
end;

end.
