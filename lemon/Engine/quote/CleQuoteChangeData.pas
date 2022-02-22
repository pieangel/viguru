unit CleQuoteChangeData;

interface

const
  CTCH_STOP  = '0';
  CTCH_START = '1';
  CTCH_UPDATE= '3';

type

  TCatchConfig = record
    StartStop : char;
    Nms  : integer;

    FillSum : integer;
    FillCnt : integer;
    UseRemVol : boolean;
    OrderQty: integer;
    MaxQuoteQty: integer;
  end;

implementation

end.
