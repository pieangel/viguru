unit SignalData;

interface

type
  TPriceIndexRange = -1..6;

  TChasingConfig = record
    // put order automatically
    Auto : Boolean;
    // order price
    PriceNew    : TPriceIndexRange;
    PriceChange : TPriceIndexRange;
    PriceLast   : TPriceIndexRange;
    // order follow-up
    TimeOut : Integer;
    MaxRetryCount : Integer;
    // clear at the end of the day
    ForcedClear : Boolean;
    CloseHour : Integer;
    CloseMin : Integer;
    // notify
    NotifyPosition : Boolean;
    NotifySignal : Boolean;
    UseSound : Boolean;
    SoundFile : String;
  end;

const
  MAX_INDEX = 7;
  PriceIndices : array[0..MAX_INDEX] of TPriceIndexRange = (0,1,2,3,4,5,-1,6);
  PriceIndexDescs : array[0..MAX_INDEX] of String =
                              ( '현재가' ,
                                '호가1' , '호가2', '호가3', '호가4', '호가5',
                                '반대호가1', '시장가');
  AT_MARKET_INDEX = 6;

implementation

end.
