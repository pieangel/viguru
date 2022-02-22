unit CleSimulationConst;

interface

Const
  SimulIni = 'Simulation.ini';
  BtnWidth  = 137;
  BtnHeight = 33;
  BtnCount  = 8;
  LogMaxCount = 65000;     // excel max row - 2003 ver.
  PRICE_EPSILON = 0.001;

type
  TSimulWindow = record
    Name  : string;
    Index : integer;
    InitFile : string;
  end;

  TQuoteOper = record
    Back : boolean;
  end;

  TSimulEnv = record
    SimulWins : array of TSimulWindow;
    TotCount  : integer;
    QuoteOp   : TQuoteOper;
  end;

var
  gSimulEnv : TSimulEnv;

implementation

end.
