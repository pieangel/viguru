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
                              ( '���簡' ,
                                'ȣ��1' , 'ȣ��2', 'ȣ��3', 'ȣ��4', 'ȣ��5',
                                '�ݴ�ȣ��1', '���尡');
  AT_MARKET_INDEX = 6;

implementation

end.
