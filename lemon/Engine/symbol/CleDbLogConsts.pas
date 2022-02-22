unit CleDbLogConsts;

interface

type

  TDbLogType = ( dblOneMin );

  TDBLogItem = class
  public
    LogType : TDBLogType;
    Time    : TDateTime;
    Code    : string;
  end;

  TOneMin  = class( TDBLogItem )
  public
    O, H, L, C, Ask, Bid, Qty : double;

  end;



implementation

end.
