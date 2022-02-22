unit CleOrderConsts;

interface

const
  ParamCnt = 3;
  SignCnt  = 4;  // 토닥이 최대 4번의 주문 기회
type

  TTodarkeParam = record
    WithOpt : boolean;
    Qty : integer;
    LossCutTick1 : integer;
    LossCutTick2 : integer;

    StartTime1 , EndTime1 : TDateTime;  // 토닥이
    StartTime2 , EndTime2 : TDateTime;  // 전고 전저

    EntrySec, EntrySec2 : integer;
    LiqSec, LiqSec2     : integer;
    LossCutSec, LossCutSec2 : integer;

    Condition : array [0..ParamCnt-1] of double;
    EnableCondition : array [0..ParamCnt-1] of boolean;
    procedure Assign( var aP : TTodarkeParam );
  end;
{
  TTodarkeState = record
    Side      : integer;
    Occured   : boolean;
    Occur1Min : boolean;  // 1분전에 발생했을때
    OccurNMin : boolean;
    IsLiquid  : boolean;
    IsLossCut : boolean;
    No        : integer;
    Condition : array [0..ParamCnt-1] of boolean; // 조건 플래그
    procedure reset( bCreate : boolean = false );
    procedure Assign( var aState : TTodarkeState );
    function GetText : string;
  end;
         }
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
  StartTime2  := aP.StartTime2;

  EndTime1    := aP.EndTime1;
  EndTime2    := aP.EndTime2;

  EntrySec    := aP.EntrySec;
  EntrySec2   := aP.EntrySec2;

  LiqSec      := aP.LiqSec;
  LiqSec2     := aP.LiqSec2;
  LossCutSec  := aP.LossCutSec;
  LossCutSec2 := aP.LossCutSec2;

  for I := 0 to paramCnt - 1 do
  begin
    Condition[i]  := aP.Condition[i];
    EnableCondition[i]  := aP.EnableCondition[i];
  end;
end;


{ TTodarkeState }
                {
procedure TTodarkeState.Assign(var aState: TTodarkeState);
begin
  Side      := aState.Side;
  Occured   := aState.Occured;
  Occur1Min := aState.Occur1Min;
  OccurNMin := aState.OccurNMin;
  IsLiquid  := aState.IsLiquid;
  IsLossCut := aState.IsLossCut;
end;

function TTodarkeState.GetText: string;
begin

end;

procedure TTodarkeState.reset( bCreate : boolean );
var
  i : integer;
begin
  Occured   := false;
  Occur1Min := false;
  OccurNMin:= false;
  IsLiquid  := false;
  IsLossCut := false;

  if bCreate then
  begin
    Side := 0;
    for i := 0 to ParamCnt - 1 do
      Condition[i]  := false;
  end;

end;     }

end.
