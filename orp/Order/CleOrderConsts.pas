unit CleOrderConsts;

interface

uses
  Classes, SysUtils , GleLib, CleSymbols
  ;

const
  ParamCnt = 3;
  SignCnt  = 4;  // 토닥이 최대 4번의 주문 기회
type

  TLogEvent = procedure( Values : TStrings; index : integer ) of Object;

  TTodarkeParam = record
    WithOpt : boolean;
    Qty : integer;
    LossCutTick1 : integer;
    LossCutTick2 : integer;

    StartTime1 , EndTime1 : TDateTime;  // 토닥이

    UseIncQTy : boolean;

    MaxOrderCnt : integer;
    EntrySec : integer;
    LiqSec     : integer;
    LossCutSec : integer;

    Condition : array [0..ParamCnt-1] of double;
    LongCondition : array [0..ParamCnt-1] of boolean;
    ShortCondition : array [0..ParamCnt-1] of boolean;
    procedure Assign( var aP : TTodarkeParam );
  end;

  TPrevHLParam = record
    Qty : integer;
    LossCutTick : integer;
    StartTime, EndTime : TDateTime;
    EntrySec : integer;
    LiqSec   : integer;
    Volume   : integer;
    MaxOrderCnt : integer;

    procedure Assign( var aParam : TPrevHLParam );
    function  GetDesc : string;
  end;

  TPrevHLStatus = record
    Occured : boolean;
    Side    : integer;

    Second  : integer;
    Count   : integer;

    PL      : double;
    Price   : double;

    function GetDesc : string;
    procedure Reset;
    procedure Assign( var aStatus : TPrevHLStatus );
  end;

  TLiquidQtyConditionType  = ( lctClearDivN, lctMinFixNClear  );

  TSheepBuySymbols = record
    Call : TOption;
    Put  : TOption;
  end;

  TSheepBuyParam = record
    IsUp  : boolean;
    Qty   : integer;
    MaxQty  : integer;
    FutTick : integer;
    // 청산
    LiqType : TLiquidQtyConditionType;
    LiqQty  : integer;

    SheepBuySymbols : array of TSheepBuySymbols;

    procedure Assign( var aParam : TSheepBuyParam; bAll : boolean = true );
  end;

implementation

{ TTodarkeParam }

procedure TTodarkeParam.Assign(var aP: TTodarkeParam);
var
  I: Integer;
begin
  WithOpt := aP.WithOpt;
  Qty := aP.Qty;
  LossCutTick1  := aP.LossCutTick1;
  LossCutTick2  := aP.LossCutTick2;

  StartTime1  := aP.StartTime1;
  EndTime1    := aP.EndTime1;   

  EntrySec    := aP.EntrySec;
  LiqSec      := aP.LiqSec;
  LossCutSec  := aP.LossCutSec;

  UseIncQty   := aP.UseIncQTy;
  MaxOrderCnt := aP.MaxOrderCnt;

  for I := 0 to paramCnt - 1 do
  begin
    Condition[i]  := aP.Condition[i];
    LongCondition[i]  := aP.LongCondition[i];
    ShortCondition[i] := aP.ShortCondition[i];
  end;
end;


{ TPrevHLParam }

procedure TPrevHLParam.Assign(var aParam: TPrevHLParam);
begin
  Qty         := aParam.Qty;
  LossCutTick := aParam.LossCutTick;
  StartTime   := aParam.StartTime;
  EndTime     := aParam.EndTime;
  EntrySec    := aParam.EntrySec;
  LiqSec      := aParam.LiqSec;
  MaxOrderCnt := aParam.MaxOrderCnt;
  Volume      := aParam.Volume;
end;

function TPrevHLParam.GetDesc: string;
begin
  Result := Format( 'Qty:%d, EntrySec:%d, LiqSec:%d, LossTick:%d, Max:%d, Volume:%d ',
    [ Qty, EntrySec, LiqSec, LossCutTick, MaxOrderCnt, Volume ]);
end;

{ TPrevHLStatus }

procedure TPrevHLStatus.Assign(var aStatus: TPrevHLStatus);
begin
  Occured := aStatus.Occured;
  Side    := aStatus.Side;
  Second  := aStatus.Second;
  Count   := aStatus.Count;

  PL      := aStatus.PL;
  Price   := aStatus.Price;
end;

function TPrevHLStatus.GetDesc: string;
begin
  Result := Format('Status : %s, %s, %d, %d, %.0f, %.2f', [ ifThenStr( Occured, 'O', 'X'),
    ifThenStr( Side > 0 , 'L', ifThenStr( Side < 0,'S',' ')), Second, Count, PL, Price ]);
end;

procedure TPrevHLStatus.Reset;
begin
  Occured := false;
  Side    := 0;
  Second  := 0;
  Count   := 0;

  PL      := 0;
  Price   := 0;
end;

{ TSheepBuyParam }

procedure TSheepBuyParam.Assign(var aParam: TSheepBuyParam; bAll : boolean);
var
  iCnt : integer;
  I: Integer;
begin
  IsUp  := aParam.IsUp;
  Qty   := aParam.Qty;
  MaxQty  := aParam.MaxQty;
  FutTick := aParam.FutTick;
  // 청산
  LiqType := aParam.LiqType;
  LiqQty  := aParam.LiqQty;

  if bAll then
  begin
    SheepBuySymbols := nil;
    iCnt := High(aParam.SheepBuySymbols) + 1;

    if iCnt > 0 then
    begin
      SetLength( SheepBuySymbols, iCnt );

      for I := 0 to iCnt - 1 do begin
        SheepBuySymbols[i].Call := aParam.SheepBuySymbols[i].Call;
        SheepBuySymbols[i].Put  := aParam.SheepBuySymbols[i].Put;
      end;
    end;
  end;
end;

end.
