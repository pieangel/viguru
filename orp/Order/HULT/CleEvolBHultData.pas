unit CleEvolBHultData;

interface

const
  BHULT_ENV = 'bhult.ini';

type

  // 초기상태, 새로 진입, 청산됨, 끝남.
  TEvolBHultState = ( ebNone, ebNew, ebLiquid, ebEnd );

  TEntryItem = record
    Volume  : integer;
    AvgPrice: double;
    Qty     : integer;
    Run     : boolean;
  end;

  TEvolBHultData = record
    DefCnt  : integer;
    EntryCnt: integer;
    RowCnt  : integer;
    HultTick: integer;
    EntryItem : array [0..4] of TEntryItem;
    StartTime : TDateTime;
    EndTime   : TDateTime;

    //
    TargetAvg : double;
    TargetVol : integer;
    TargetSide: integer;
    EntryAvg  : double;
    AvgGap    : double;

    State : TEvolBHultState;

    procedure init;
    procedure Reset;
  end;

implementation

{ TEvolBHultData }

procedure TEvolBHultData.init;
var
  i : integer;
begin
  DefCnt  := 5;
  for I := 0 to DefCnt - 1 do
    EntryItem[i].Run  := false;

end;

procedure TEvolBHultData.Reset;
begin
  TargetAvg := 0;
  TargetVol := 0;
  TargetSide:= 0;
  EntryAvg  := 0;

  State := ebNone;
end;

end.
