unit CleSsoptData;

interface
const
  MAX_INDEX = 4;
type
  TSsoptParams = record
    Index : integer;
    AllCancelClear : boolean;
    SymbolCode : string;
    OrderQty : integer;
    Slice : integer;
    LimitLS : char;
    CnlLS   : char;
    LimitIndex : integer;
    Bidlimit : array[0..4] of boolean;
    Asklimit : array[0..4] of boolean;
    AdjustLS : char;
    AdjustIndex : integer;
    PreLS : char;
    AskPre : integer;
    BidPre : integer;
    DelayAfford : integer;
    OnOff : boolean;
  end;

  TSymbolState = class
  public
    Winrate1      : array[0..MAX_INDEX-1] of string;
    Winrate2      : array[0..MAX_INDEX-1] of string;
    SymbolState1  : array[0..MAX_INDEX-1] of string;
    SymbolState2  : array[0..MAX_INDEX-1] of string;
    constructor Create;
    destructor Destroy; override;
  end;

  TToTalState = class
  public
    SSoptCon      : string;
    OrdSess       : string;
    AcpSess       : string;
    filSess       : string;
    SymbolRev     : string;
    QuoteTime     : string;
    QuoteDelay    : string;

    constructor Create;
    destructor Destroy; override;
  end;

  TLastState = class
  public
    IsAllClear    : array[0..MAX_INDEX-1] of boolean;
    SymbolCode    : array[0..MAX_INDEX-1] of string;
    OrderQty      : array[0..MAX_INDEX-1] of string;
    Slice         : array[0..MAX_INDEX-1] of string;
    IsAskHoga     : array[0..MAX_INDEX-1] of string;
    IsBidHoga     : array[0..MAX_INDEX-1] of string;
    AskPre        : array[0..MAX_INDEX-1] of string;
    BidPre        : array[0..MAX_INDEX-1] of string;
    DelayAfford   : array[0..MAX_INDEX-1] of string;
    OnOff         : array[0..MAX_INDEX-1] of integer;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TLastState }

constructor TLastState.Create;
begin

end;

destructor TLastState.Destroy;
begin

  inherited;
end;

{ TToTalState }

constructor TToTalState.Create;
begin

end;

destructor TToTalState.Destroy;
begin

  inherited;
end;

{ TSymbolState }

constructor TSymbolState.Create;
begin

end;

destructor TSymbolState.Destroy;
begin

  inherited;
end;

end.
