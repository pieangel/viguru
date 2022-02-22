unit CleParkParam;

interface

type
  TSBO_Param = record
    OrdQty    : integer;
    EntryCnt  : integer;
    StopPer   : integer;
    BasePrc   : double;
    BelowPrc  : double;
    //
    Endtime   : TDateTime;
    StartTime : TDateTime;
    MorningTime : TDateTime;

    UseStopLiq: boolean;
  end;

implementation

end.
