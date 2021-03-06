unit CleMarkets;

interface

uses
  Classes, SysUtils, Math,

  CleSymbols, CleMarketSpecs;

type
    //------------------------------------------< Market >

  TMarket = class(TCollectionItem)
  protected
    FFQN: String; // fully qualified name
    FSymbols: TSymbolList;
    FSpec: TMarketSpec;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    procedure AddSymbol(aSymbol: TSymbol); virtual;

    property FQN: String read FFQN;
    property Spec: TMarketSpec read FSpec write FSpec;
    property Symbols: TSymbolList read FSymbols;
  end;

  TMarkets = class(TCollection)
  protected
    function GetMarket(i: Integer): TMarket;
  public
    function Find(stFQN: String): TMarket;

    procedure GetList(aList: TStrings);
    procedure GetList2(aList: TStrings);  // 주식선물 빼고
    procedure GetList3(aList: TStrings);  // 주식선물만

    property Markets[i:Integer]: TMarket read GetMarket;
  end;

  TMarketList = class(TStringList)
  private
    function GetMarket(i: Integer): TMarket;
  public
    procedure AddMarket(aMarket: TMarket);
    function FindMarket(stFQN: String): TMarket;
    property Markets[i:Integer]: TMarket read GetMarket; default;
  end;

    //------------------------------------------< Index Market >

  TIndexMarket = class(TMarket)
  private
    function GetIndex(i: Integer): TIndex;
  public
    property Indexes[i:Integer]: TIndex read GetIndex; default;
  end;

  TIndexMarkets = class(TMarkets)
  private
    function GetIndexMarket(i: Integer): TIndexMarket;
  public
    constructor Create;
    function New(stFQN: String): TIndexMarket;
    property IndexMarkets[i:Integer]: TIndexMarket read GetIndexMarket; default;
  end;
    {
    //------------------------------------------< Dollar Market >

  TDollarMarket = class(TMarket)
  private
    function GetDollar(i: Integer): TDollar;
  public
    property Dollar[i:Integer]: TDollar read GetDollar; default;
  end;

  TDollarMarkets = class(TMarkets)
  private
    function GetDollarMarket(i: Integer): TDollarMarket;
  public
    constructor Create;
    function New(stFQN: String): TDollarMarket;
    property DollarMarkets[i:Integer]: TDollarMarket read GetDollarMarket; default;
  end;

    //------------------------------------------< Yen Market >

  TYenMarket = class(TMarket)
  private
    function GetYen(i: Integer): TYen;
  public
    property Yen[i:Integer]: TYen read GetYen; default;
  end;

  TYenMarkets = class(TMarkets)
  private
    function GetYenMarket(i: Integer): TYenMarket;
  public
    constructor Create;
    function New(stFQN: String): TYenMarket;
    property YenMarkets[i:Integer]: TYenMarket read GetYenMarket; default;
  end;
         }
    //------------------------------------------< Stock Market >

  TStockMarket = class(TMarket)
  private
    function GetStock(i: Integer): TStock;
  public
    property Stocks[i:Integer]: TStock read GetStock; default;
  end;

  TStockMarkets = class(TMarkets)
  private
    function GetStockMarket(i: Integer): TStockMarket;
  public
    constructor Create;
    function New(stFQN: String): TStockMarket;
    property StockMarkets[i:Integer]: TStockMarket read GetStockMarket; default;
  end;

    //------------------------------------------< ETF Market >

  TETFMarket = class(TMarket)
  private
    function GetETF(i: Integer): TETF;
  public
    property ETFs[i:Integer]: TETF read GetETF; default;
  end;

  TETFMarkets = class(TMarkets)
  private
    function GetETFMarket(i: Integer): TETFMarket;
  public
    constructor Create;
    function New(stFQN: String): TETFMarket;
    property ETFMarkets[i:Integer]: TETFMarket read GetETFMarket; default;
  end;

    //------------------------------------------< Bond Market >

  TBondMarket = class(TMarket)
  private
    function GetBond(i: Integer): TBond;
  public
    property Bonds[i:Integer]: TBond read GetBond; default;
  end;

  TBondMarkets = class(TMarkets)
  private
    function GetBondMarket(i: Integer): TBondMarket;
  public
    constructor Create;
    function New(stFQN: String): TBondMarket;
    property BondMarkets[i:Integer]: TBondMarket read GetBondMarket; default;
  end;

    //------------------------------------------< Currency Market >

  TCurrencyMarket = class(TMarket)
  private
    function GetCurrency(i: Integer): TCurrency;
  public
    property Currencies[i:Integer]: TCurrency read GetCurrency; default;
  end;

  TCurrencyMarkets = class(TMarkets)
  private
    function GetCurrencyMarket(i: Integer): TCurrencyMarket;
  public
    constructor Create;
    function New(stFQN: String): TCurrencyMarket;
    property CurrencyMarkets[i:Integer]: TCurrencyMarket read GetCurrencyMarket; default;
  end;

        //------------------------------------------< Commodity Market >

  TCommodityMarket = class(TMarket)
  private
    function GetCommodity(i: Integer): TCommodity;
  public
    property Commodities[i:Integer]: TCommodity read GetCommodity; default;
  end;

  TCommodityMarkets = class(TMarkets)
  private
    function GetBondMarket(i: Integer): TCommodityMarket;
  public
    constructor Create;
    function New(stFQN: String): TCommodityMarket;
    property CommodityMarkets[i:Integer]: TCommodityMarket read GetBondMarket; default;
  end;

    //------------------------------------------< Future Market >

  TFutureMarket = class(TMarket)
  private
    FFrontMonth: TFuture;
    function GetFuture(i: Integer): TFuture;
  public
    procedure AddSymbol(aSymbol: TSymbol); override;
    function  FindNearSymbol( stCode : string ) : TSymbol; 
    property FrontMonth: TFuture read FFrontMonth write FFrontMonth;
    property Futures[i:Integer]: TFuture read GetFuture; default;
  end;

  TFutureMarkets = class(TMarkets)
  private
    function GetFutureMarket(i: Integer): TFutureMarket;
  public
    constructor Create;
    function New(stFQN: String): TFutureMarket;
    function FindPumMok( stPM : string ) : TFutureMarket;
    property FutureMarkets[i:Integer]: TFutureMarket read GetFutureMarket; default;
  end;

    //------------------------------------------< Option Market >

  TStrike = class(TCollectionItem)
  private
    FCall: TOption;
    FPut: TOption;
    FStrikePrice: Double;
    FStrikeCode: String;
  public
    property Call: TOption read FCall write FCall;
    property Put: TOption read FPut write FPut;
    property StrikePrice: Double read FStrikePrice;
    property StrikeCode: String read FStrikeCode;
  end;

  TStrikes = class(TCollection)
  private
    function AddOption(aOption: TOption): TStrike;
    function GetStrike(i: Integer): TStrike;
  public
    constructor Create;

    property Strikes[i:Integer]: TStrike read GetStrike; default;
  end;

  TOptionTree = class(TCollectionItem)
  private
    FExpDate: TDateTime;
    FExpYear: Integer;
    FExpMonth: Integer;
    FExpired: Boolean;

    FStrikes: TStrikes;
    
    procedure SetExpDate(const Value: TDateTime);
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function AddOption(aOption: TOption): TStrike;

    property ExpDate: TDateTime read FExpDate write SetExpDate;
    property ExpYear: Integer read FExpYear;
    property ExpMonth: Integer read FExpMonth;
    property Expired: Boolean read FExpired;

    property Strikes: TStrikes read FStrikes;
  end;

  TOptionTrees = class(TCollection)
  private
    FFrontMonth: TOptionTree;

    function AddOption(aOption: TOption): TOptionTree;
    function GetTree(i: Integer): TOptionTree;
  public
    constructor Create;

    function Find(dtExp: TDateTime): TOptionTree;
    procedure GetList(aList: TStrings);
    procedure GetListShort(aList: TStrings);

    property FrontMonth: TOptionTree read FFrontMonth;
    property Trees[i:Integer]: TOptionTree read GetTree; default;
  end;

  TOptionMarket = class(TMarket)
  private
    FIsSub: boolean;
  protected
    FTrees: TOptionTrees;
    function GetOption(i: Integer): TOption;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    procedure AddSymbol(aSymbol: TSymbol); override;

    property Trees: TOptionTrees read FTrees;
    property Options[i:Integer]: TOption read GetOption; default;
    // only api
    property IsSub : boolean read FIsSub write FIsSub;
  end;

  TOptionMarkets = class(TMarkets)
  private
    function GetOptionMarket(i: Integer): TOptionMarket;
  public
    constructor Create;
    function New(stFQN: String): TOptionMarket;
    property OptionMarkets[i:Integer]: TOptionMarket read GetOptionMarket; default;
  end;

  //--------------------------------------------------< ELW market definition >

  TELWStrike = class(TCollectionItem)
  public
    FCalls: TSymbolList;
    FPuts: TSymbolList;
    FStrikePrice: Double;
    FStrikeCode: String;
    FStrikeIndex: Integer;
  public
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    property Calls: TSymbolList read FCalls;
    property Puts: TSymbolList read FPuts;
    property StrikePrice: Double read FStrikePrice;
    property StrikeCode: String read FStrikeCode;
    property StrikeIndex: Integer read FStrikeIndex;
  end;

  TELWStrikes = class(TCollection)
  private
    function AddELW(aELW: TELW): TELWStrike;
    function GetStrike(i: Integer): TELWStrike;
  public
    constructor Create;

    property Strikes[i:Integer]: TELWStrike read GetStrike; default;
  end;

  TELWTree = class(TCollectionItem)
  private
    FDesc: String;
    FDaysMin: Integer;
    FDaysMax: Integer;

    FStrikes: TELWStrikes;
  public
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    function AddELW(aELW: TELW): TELWStrike;

    property Desc: String read FDesc;
    property DaysMin: Integer read FDaysMin;
    property DaysMax: Integer read FDaysMax;

    property Strikes: TELWStrikes read FStrikes;
  end;

  TELWTrees = class(TCollection)
  private
    FFrontMonth: TELWTree;

    function AddELW(aELW: TELW): TELWTree;
    function GetTree(i: Integer): TELWTree;
  public
    constructor Create;

    procedure GetList(aList: TStrings);

    property FrontMonth: TELWTree read FFrontMonth;
    property Trees[i:Integer]: TELWTree read GetTree; default;
  end;

  TELWMarket = class(TOptionMarket)
  private
    function GetELW(i: Integer): TELW;
  protected
    FELWTrees: TELWTrees;
    FStrikeCodes: TStringList;
  public
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    procedure AddSymbol(aSymbol: TSymbol); override;
    procedure MapStrikes;

    property ELWTrees: TELWTrees read FELWTrees;
    property StrikeCodes: TStringList read FStrikeCodes;

    property ELWs[i:Integer]:TELW read GetELW; default;
  end;

  TELWMarkets = class(TMarkets)
  private
    function GetELWMarket(i: Integer): TELWMarket;
  public
    constructor Create;

    function New(stFQN: String): TELWMarket;

    property ELWMarkets[i:Integer]: TELWMarket read GetELWMarket; default;
  end;

    //------------------------------------------< Spread Market >

  TSpreadMarket = class(TMarket);
  TSpreadMarkets = class(TMarkets)
  private
    function GetSpreadMarket(i: Integer): TSpreadMarket;
  public
    constructor Create;
    function New(stFQN: String): TSpreadMarket;
    property SpreadMarkets[i:Integer]: TSpreadMarket read GetSpreadMarket; default;
  end;

    //------------------------------------------< Market Groups >

  TMarketGroup = class(TCollectionItem)
  protected
    FFQN: String;
    FTitle: String;
    FRef: TSymbol;
    FIdx : integer;
    FMarkets: TMarketList;
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    property FQN : string read FFQN;
    property Ref: TSymbol read FRef;
    property Title : string read FTitle;
    property Idx : integer read FIdx;
    property Markets: TMarketList read FMarkets; 
  end;

  TMarketGroups = class(TCollection)
  private
    function GetGroup(i: Integer): TMarketGroup;
  public
    constructor Create;
    procedure AddMarket(aMarket: TMarket; stFQN, stTitle: String; aRef: TSymbol = nil);

    function Find(stFQN: String): TMarketGroup;
    procedure GetList(aList: TStrings);    
    function FindTitle(stTitle: String): TMarketGroup;
    property Groups[i:Integer]: TMarketGroup read GetGroup; default;
  end;

implementation

//------------------------------------------------------------------< market >
{ TMarket }

constructor TMarket.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FSymbols := TSymbolList.Create;
end;

destructor TMarket.Destroy;
begin
  FSymbols.Free;

  inherited;
end;

procedure TMarket.AddSymbol(aSymbol: TSymbol);
begin
  FSymbols.AddObject(aSymbol.Code, aSymbol);
end;

{ TMarkets }

function TMarkets.Find(stFQN: String): TMarket;
var
  i: Integer;
begin
  Result := nil;
  
  for i := 0 to Count - 1 do
    if CompareStr(stFQN, (Items[i] as TMarket).FFQN) = 0 then
    begin
      Result := Items[i] as TMarket;
      Break;
    end;
end;

procedure TMarkets.GetList(aList: TStrings);
var
  i: Integer;
  aMarket: TMarket;
begin
  for i := 0 to Count - 1 do
  begin
    aMarket := GetMarket(i);
    if aMarket.Spec <> nil then
      aList.AddObject(aMarket.Spec.Description, aMarket)
    else
      aList.AddObject(aMarket.FQN, aMarket);
  end;
end;

// 주식선물 빼고
procedure TMarkets.GetList2(aList: TStrings);
var
  i: Integer;
  aMarket: TMarket;
begin
  for i := 0 to Count - 1 do
  begin
    aMarket := GetMarket(i);
    if aMarket.Spec <> nil then begin
      if aMarket.Spec.Sector = STOCK_FUT then Continue;
      aList.AddObject(aMarket.Spec.Description, aMarket);
    end
    else
      aList.AddObject(aMarket.FQN, aMarket);
  end;

end;

// 주식선물만
procedure TMarkets.GetList3(aList: TStrings);
var
  i: Integer;
  aMarket: TMarket;
begin
  for i := 0 to Count - 1 do
  begin
    aMarket := GetMarket(i);
    if aMarket.Spec <> nil then begin
      if aMarket.Spec.Sector <> STOCK_FUT then Continue;
      aList.AddObject(aMarket.Spec.Description, aMarket)
    end
    else
      aList.AddObject(aMarket.FQN, aMarket);
  end;

end;

function TMarkets.GetMarket(i: Integer): TMarket;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TMarket
  else
    Result := nil;
end;

{ TMarketList }

procedure TMarketList.AddMarket(aMarket: TMarket);
begin
  AddObject(aMarket.FQN, aMarket);
end;

function TMarketList.FindMarket(stFQN: String): TMarket;
var
  iIndex: Integer;
begin
  iIndex := IndexOf(stFQN);
  if iIndex >= 0 then
    Result := TMarket(Objects[iIndex])
  else
    Result := nil;
end;

function TMarketList.GetMarket(i: Integer): TMarket;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TMarket(Objects[i])
  else
    Result := nil;
end;

//------------------------------------------------------------< index market >

{ TIndexMarket }

function TIndexMarket.GetIndex(i: Integer): TIndex;
begin
  Result := FSymbols[i] as TIndex;
end;

{ TIndexMarkets }

constructor TIndexMarkets.Create;
begin
  inherited Create(TIndexMarket);
end;

function TIndexMarkets.GetIndexMarket(i: Integer): TIndexMarket;
begin
  Result := GetMarket(i) as TIndexMarket;
end;

function TIndexMarkets.New(stFQN: String): TIndexMarket;
begin
  Result := Add as TIndexMarket;
  Result.FFQN := stFQN;
end;

//-------------------------------------------------------------< stock market >

{ TStockMarket }

function TStockMarket.GetStock(i: Integer): TStock;
begin
  Result := FSymbols[i] as TStock;
end;

{ TStockMarkets }

constructor TStockMarkets.Create;
begin
  inherited Create(TStockMarket);
end;

function TStockMarkets.GetStockMarket(i: Integer): TStockMarket;
begin
  Result := GetMarket(i) as TStockMarket;
end;

function TStockMarkets.New(stFQN: String): TStockMarket;
begin
  Result := Add as TStockMarket;
  Result.FFQN := stFQN;
end;

//---------------------------------------------------------------< ETF market >

{ TETFMarket }

function TETFMarket.GetETF(i: Integer): TETF;
begin
  Result := FSymbols[i] as TETF;
end;

{ TETFMarkets }

constructor TETFMarkets.Create;
begin
  inherited Create(TETFMarket);
end;

function TETFMarkets.GetETFMarket(i: Integer): TETFMarket;
begin
  Result := GetMarket(i) as TETFMarket;
end;

function TETFMarkets.New(stFQN: String): TETFMarket;
begin
  Result := Add as TETFMarket;
  Result.FFQN := stFQN;
end;

//--------------------------------------------------------------< bond market >

{ TBondMarket }

function TBondMarket.GetBond(i: Integer): TBond;
begin
  Result := FSymbols[i] as TBond;
end;

{ TBondMarkets }

constructor TBondMarkets.Create;
begin
  inherited Create(TBondMarket);
end;

function TBondMarkets.GetBondMarket(i: Integer): TBondMarket;
begin
  Result := GetMarket(i) as TBondMarket;
end;

function TBondMarkets.New(stFQN: String): TBondMarket;
begin
  Result := Add as TBondMarket;
  Result.FFQN := stFQN;
end;

//-----------------------------------------------------------< future market >

{ TFutureMarket }

procedure TFutureMarket.AddSymbol(aSymbol: TSymbol);
var
  aFuture: TFuture;
begin
  if not (aSymbol is TFuture) then Exit;

  inherited AddSymbol(aSymbol);

  aFuture := aSymbol as TFuture;

  if FFrontMonth = nil then
    FFrontMonth := aFuture
  else
    if Floor(aFuture.ExpDate) < Floor(FFrontMonth.ExpDate) then
      FFrontMonth := aFuture;
end;

function TFutureMarket.FindNearSymbol(stCode: string): TSymbol;
var
  iY, iM, I: Integer;
  dGap, dMin : double;
  aSymbol : TFuture;
  stDate : string;
  dtDate : TDateTime;
  function _getCodeMonth( c : char ): integer;
  begin
    case c of
      'F': Result := 1;
      'G': Result := 2;
      'H': Result := 3;
      'J': Result := 4;
      'K': Result := 5;
      'M': Result := 6;
      'N': Result := 7;
      'Q': Result := 8;
      'U': Result := 9;
      'V': Result := 10;
      'X': Result := 11;
      'Z': Result := 12;
      else
        Result := 0;
    end;
  end;

begin
  try
    Result := nil;

    stDate := Copy( stCode, Length(stCode)-2, 3 );
    iY := 2000 + StrToInt( Copy(stDate, 2, 2 ));
    iM := _getCodeMonth( stDate[1] );

    dtDate  := EncodeDate( iY, iM, 1 );

    dMin := 10000;
    for I := 0 to Symbols.Count - 1 do
    begin
      aSymbol := Symbols.Symbols[i] as TFuture;
      dGap := aSymbol.ExpDate - dtDate;
      if ( dGap > 0 ) and ( dGap < dMin ) then
      begin
        Result := aSymbol;
        dMin   := dGap;
      end;
    end;
  except
    Result := nil;
  end;
end;

function TFutureMarket.GetFuture(i: Integer): TFuture;
begin
  Result := FSymbols[i] as TFuture;
end;

{ TFutureMarkets }

constructor TFutureMarkets.Create;
begin
  inherited Create(TFutureMarket);
end;

function TFutureMarkets.FindPumMok(stPM: string): TFutureMarket;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if GetFutureMarket(i).Spec.RootCode = stPM then
    begin
      Result := GetFutureMarket( i);
      break;
    end;
end;

function TFutureMarkets.GetFutureMarket(i: Integer): TFutureMarket;
begin
  Result := GetMarket(i) as TFutureMarket;
end;

function TFutureMarkets.New(stFQN: String): TFutureMarket;
begin
  Result := Add as TFutureMarket;
  Result.FFQN := stFQN;
end;

//-----------------------------------------------------------< spread market >

{ TSpreadMarkets }

constructor TSpreadMarkets.Create;
begin
  inherited Create(TSpreadMarket);
end;

function TSpreadMarkets.GetSpreadMarket(i: Integer): TSpreadMarket;
begin
  Result := GetMarket(i) as TSpreadMarket;
end;

function TSpreadMarkets.New(stFQN: String): TSpreadMarket;
begin
  Result := Add as TSpreadMarket;
  Result.FFQN := stFQN;
end;

//-----------------------------------------------------------< option market >

{ TStrikes }

constructor TStrikes.Create;
begin
  inherited Create(TStrike);
end;

function TStrikes.GetStrike(i: Integer): TStrike;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TStrike
  else
    Result := nil;
end;

function TStrikes.AddOption(aOption: TOption): TStrike;
var
  i: Integer;
  aStrike: TStrike;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aStrike := Items[i] as TStrike;

    if aOption.StrikePrice < aStrike.StrikePrice - 1.0e-10 then
    begin
      Result := Insert(i) as TStrike;
      Result.FStrikePrice := aOption.StrikePrice;
      Break;
    end else
    if aOption.StrikePrice < aStrike.StrikePrice + 1.0e-10 then
    begin
      Result := Items[i] as TStrike;
      Break;
    end;
  end;

  if Result = nil then
  begin
    Result := Add as TStrike;
    Result.FStrikePrice := aOption.StrikePrice;
  end;

  if aOption.CallPut = 'C' then
  begin
    Result.Call := aOption;
    if Result.Put <> nil then
    begin
      Result.Put.RelativeHigh := aOption.ListHigh;
      Result.Put.RelativeLow  := aOption.ListLow;

      aOption.RelativeHigh    := Result.Put.ListHigh;
      aOption.RelativeLow     := Result.Put.ListLow;
    end;
  end
  else begin
    Result.Put := aOption;
    if Result.Call <> nil then
    begin
      Result.Call.RelativeHigh := aOption.ListHigh;
      Result.Call.RelativeLow  := aOption.ListLow;

      aOption.RelativeHigh    := Result.Call.ListHigh;
      aOption.RelativeLow     := Result.Call.ListLow;
    end;
  end;
end;

{ TOptionTree }

constructor TOptionTree.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FStrikes := TStrikes.Create;
end;

destructor TOptionTree.Destroy;
begin
  FStrikes.Free;

  inherited;
end;

procedure TOptionTree.SetExpDate(const Value: TDateTime);
var
  wYear, wMonth, wDay: Word;
begin
  FExpDate := Floor(Value);

  DecodeDate(FExpDate, wYear, wMonth, wDay);
  FExpYear := wYear;
  FExpMonth := wMonth;

  FExpired :=  Date > FExpDate+1;
end;

function TOptionTree.AddOption(aOption: TOption): TStrike;
begin
  Result := FStrikes.AddOption(aOption);
end;

{ TOptionTrees }

constructor TOptionTrees.Create;
begin
  inherited Create(TOptionTree);
end;

function TOptionTrees.Find(dtExp: TDateTime): TOptionTree;
var
  i: Integer;
begin
  Result := nil;
  dtExp := Floor(dtExp);

  for i := 0 to Count - 1 do
    if dtExp = Floor((Items[i] as TOptionTree).ExpDate) then
    begin
      Result := Items[i] as TOptionTree;
      Break;
    end;
end;

procedure TOptionTrees.GetList(aList: TStrings);
var
  i: Integer;
  aTree: TOptionTree;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aTree := GetTree(i);
    aList.AddObject(FormatDateTime('yy-mm-dd', aTree.ExpDate), aTree);
  end;
end;

procedure TOptionTrees.GetListShort(aList: TStrings);
var
  i: Integer;
  aTree: TOptionTree;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aTree := GetTree(i);
    aList.AddObject(FormatDateTime('yy-mm', aTree.ExpDate), aTree);
  end
end;

function TOptionTrees.GetTree(i: Integer): TOptionTree;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOptionTree
  else
    Result := nil;
end;

function TOptionTrees.AddOption(aOption: TOption): TOptionTree;
var
  i, iDate, iTreeDate: Integer;
begin
  Result := nil;

  if aOption = nil then Exit;

    // find tree
  iDate := Floor(aOption.ExpDate);

  for i := 0 to Count - 1 do
  begin
    iTreeDate := Floor((Items[i] as TOptionTree).ExpDate);

    if iDate < iTreeDate then
    begin
      Result := Insert(i) as TOptionTree;
      Result.ExpDate := aOption.ExpDate;
      Break;
    end else
    if iDate = iTreeDate then
    begin
      Result := Items[i] as TOptionTree;
      Break;
    end;
  end;

  if Result = nil then
  begin
    Result := Add as TOptionTree;
    Result.ExpDate := aOption.ExpDate;
  end;

    // add option
  Result.AddOption(aOption);

    //
  if FFrontMonth = nil then
    FFrontMonth := Result
  else
    if Result.ExpDate < FFrontMonth.ExpDate then
      FFrontMonth := Result;
end;

{ TOptionMarket }

procedure TOptionMarket.AddSymbol(aSymbol: TSymbol);
begin
  inherited AddSymbol(aSymbol);

  if aSymbol is TOption then
    FTrees.AddOption(aSymbol as TOption);
end;

constructor TOptionMarket.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FIsSub := false;
  FTrees := TOptionTrees.Create;
end;

destructor TOptionMarket.Destroy;
begin
  FTrees.Free;

  inherited;
end;

function TOptionMarket.GetOption(i: Integer): TOption;
begin
  Result := FSymbols[i] as TOption;
end;

{ TOptionMarkets }

constructor TOptionMarkets.Create;
begin
  inherited Create(TOptionMarket);
end;

function TOptionMarkets.GetOptionMarket(i: Integer): TOptionMarket;
begin
  Result := GetMarket(i) as TOptionMarket;
end;

function TOptionMarkets.New(stFQN: String): TOptionMarket;
begin
  Result := Add as TOptionMarket;
  Result.FFQN := stFQN;
end;

//---------------------------------------------------------------< ELW market >

{ TELWStrike }

constructor TELWStrike.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FCalls := TSymbolList.Create;
  FPuts := TSymbolList.Create;
end;

destructor TELWStrike.Destroy;
begin
  FCalls.Free;
  FPuts.Free;

  inherited;
end;

{ TELWStrikes }

constructor TELWStrikes.Create;
begin
  inherited Create(TELWStrike);
end;

function TELWStrikes.GetStrike(i: Integer): TELWStrike;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TELWStrike
  else
    Result := nil;
end;

function TELWStrikes.AddELW(aELW: TELW): TELWStrike;
var
  i: Integer;
  aStrike: TELWStrike;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aStrike := Items[i] as TELWStrike;

    if aELW.StrikePrice < aStrike.StrikePrice - 1.0e-10 then
    begin
      Result := Insert(i) as TELWStrike;
        // set strike price
      Result.FStrikePrice := aELW.StrikePrice;
        // set strike code
      if (aELW.Underlying <> nil) and (aELW.Underlying.Spec <> nil) then
        Result.FStrikeCode := Format('%.*n', [aELW.Underlying.Spec.Precision,
                                              aELW.StrikePrice])
      else
        Result.FStrikeCode := Format('%.2n', [aELW.StrikePrice]);

      Break;
    end else
    if aELW.StrikePrice < aStrike.StrikePrice + 1.0e-10 then
    begin
      Result := Items[i] as TELWStrike;
      Break;
    end;
  end;

  if Result = nil then
  begin
    Result := Add as TELWStrike;
      // set strike price
    Result.FStrikePrice := aELW.StrikePrice;
      // set strike code
    if (aELW.Underlying <> nil) and (aELW.Underlying.Spec <> nil) then
      Result.FStrikeCode := Format('%.*n', [aELW.Underlying.Spec.Precision,
                                            aELW.StrikePrice])
    else
      Result.FStrikeCode := Format('%.2n', [aELW.StrikePrice]);
  end;

    // add to the list
  if aELW.CallPut = 'C' then
    Result.Calls.AddSymbol(aELW)
  else
    Result.Puts.AddSymbol(aELW);
end;


{ TELWTree }

constructor TELWTree.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FStrikes := TELWStrikes.Create;
end;

destructor TELWTree.Destroy;
begin
  FStrikes.Free;

  inherited;
end;

function TELWTree.AddELW(aELW: TELW): TELWStrike;
begin
  Result := FStrikes.AddELW(aELW);
end;

{ TELWTrees }

constructor TELWTrees.Create;
begin
  inherited Create(TELWTree);

    // days <= 1 month
  FFrontMonth := Add as TELWTree;
  with FFrontMonth do
  begin
    FDesc := '~ 1 month';
    FDaysMin := 0;
    FDaysMax := 30;
  end;
    // 1 month < days <= 3 month
  with Add as TELWTree do
  begin
    FDesc := '1 ~ 3 months';
    FDaysMin := 31;
    FDaysMax := 90;
  end;
    // 3 month < days <= 6 month
  with Add as TELWTree do
  begin
    FDesc := '3 ~ 6 months';
    FDaysMin := 91;
    FDaysMax := 180;
  end;
    // 6 months < days
  with Add as TELWTree do
  begin
    FDesc := '6 months ~';
    FDaysMin := 181;
    FDaysMax := 999999;
  end;
end;

procedure TELWTrees.GetList(aList: TStrings);
var
  i: Integer;
  aTree: TELWTree;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aTree := GetTree(i);

    aList.AddObject(aTree.Desc, aTree);
  end;
end;

function TELWTrees.GetTree(i: Integer): TELWTree;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TELWTree
  else
    Result := nil;
end;

function TELWTrees.AddELW(aELW: TELW): TELWTree;
var
  i: Integer;
  aTree: TELWTree;
begin
  for i := 0 to Count - 1 do
  begin
    aTree := GetTree(i);

    if (aELW.DaysToExp >= aTree.DaysMin)
       and (aELW.DaysToExp <= aTree.DaysMax) then
    begin
      aTree.AddELW(aELW);
      Break;
    end;
  end;
end;


{ TELWMarket }

procedure TELWMarket.AddSymbol(aSymbol: TSymbol);
begin
  inherited AddSymbol(aSymbol);

  if aSymbol is TELW then
    FELWTrees.AddELW(aSymbol as TELW);
end;

constructor TELWMarket.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FELWTrees := TELWTrees.Create;
  FStrikeCodes := TStringList.Create;
  FStrikeCodes.Sorted := True;
end;

destructor TELWMarket.Destroy;
begin
  FStrikeCodes.Free;
  FELWTrees.Free;;

  inherited;
end;

function TELWMarket.GetELW(i: Integer): TELW;
begin
  Result := FSymbols[i] as TELW;
end;

procedure TELWMarket.MapStrikes;
var
  i, j: Integer;
  aTree: TELWTree;
  aStrike: TELWStrike;
begin
    // clear codes
  FStrikeCodes.Clear;

    // generate codes
  for i := 0 to FELWTrees.Count - 1 do
  begin
    aTree := FELWTrees[i];

    for j := 0 to aTree.Strikes.Count - 1 do
    begin
      aStrike := aTree.Strikes[j];

      if FStrikeCodes.IndexOf(aStrike.StrikeCode) < 0 then
        FStrikeCodes.Add(aStrike.StrikeCode);
    end;
  end;

    // set index
  for i := 0 to FELWTrees.Count - 1 do
  begin
    aTree := FELWTrees[i];

    for j := 0 to aTree.Strikes.Count - 1 do
    begin
      aStrike := aTree.Strikes[j];

      aStrike.FStrikeIndex := FStrikeCodes.IndexOf(aStrike.StrikeCode);
    end;
  end;
end;


{ TELWMarkets }

constructor TELWMarkets.Create;
begin
  inherited Create(TELWMarket);
end;

function TELWMarkets.GetELWMarket(i: Integer): TELWMarket;
begin
  Result := GetMarket(i) as TELWMarket;
end;

function TELWMarkets.New(stFQN: String): TELWMarket;
begin
  Result := Add as TELWMarket;
  Result.FFQN := stFQN;
end;

//-------------------------------------------------------------< market group >

{ TMarketGroup }

constructor TMarketGroup.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FMarkets := TMarketList.Create;
  FIdx := -1;
  FRef := nil;
  FFQN := '';
  FTitle := '';
end;

destructor TMarketGroup.Destroy;
begin
  FMarkets.Free;

  inherited;
end;

{ TMarketGroups }



constructor TMarketGroups.Create;
begin
  inherited Create(TMarketGroup);
end;

function TMarketGroups.GetGroup(i: Integer): TMarketGroup;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TMarketGroup
  else
    Result := nil;
end;

procedure TMarketGroups.GetList(aList: TStrings);
var
  i: Integer;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
    aList.AddObject((Items[i] as TMarketGroup).FTitle, Items[i]);
end;

function TMarketGroups.Find(stFQN: String): TMarketGroup;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if CompareStr(stFQN, (Items[i] as TMarketGroup).FFQN) = 0 then
    begin
      Result := Items[i] as TMarketGroup;
      Break;
    end;
end;

function TMarketGroups.FindTitle(stTitle: String): TMarketGroup;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if CompareStr(stTitle, (Items[i] as TMarketGroup).FTitle) = 0 then
    begin
      Result := Items[i] as TMarketGroup;
      Break;
    end;
end;

procedure TMarketGroups.AddMarket(aMarket: TMarket; stFQN, stTitle: String;
  aRef: TSymbol);
var
  aGroup: TMarketGroup;
begin
  aGroup := Find(stFQN);

  if aGroup = nil then
  begin
    aGroup := Add as TMarketGroup;
    aGroup.FFQN := stFQN;
    aGroup.FTitle := stTitle;
    aGroup.FRef := aRef;
  end;

  aGroup.Markets.AddMarket(aMarket);
end;


{ TDollarMarket }

  {
function TDollarMarket.GetDollar(i: Integer): TDollar;
begin
  Result := FSymbols[i] as TDollar;
end;
   }
{ TDollarMarkets }
   {
constructor TDollarMarkets.Create;
begin
  inherited Create(TDollarMarket);
end;

function TDollarMarkets.GetDollarMarket(i: Integer): TDollarMarket;
begin
  Result := GetMarket(i) as TDollarMarket;
end;

function TDollarMarkets.New(stFQN: String): TDollarMarket;
begin
  Result := Add as TDollarMarket;
  Result.FFQN := stFQN;
end;
   }
{ TCurrencyMarket }

function TCurrencyMarket.GetCurrency(i: Integer): TCurrency;
begin
  Result := FSymbols[i] as TCurrency;
end;

{ TCurrencyMarkets }

constructor TCurrencyMarkets.Create;
begin
  inherited Create(TCurrencyMarket);
end;

function TCurrencyMarkets.GetCurrencyMarket(i: Integer): TCurrencyMarket;
begin
  Result := GetMarket(i) as TCurrencyMarket;
end;

function TCurrencyMarkets.New(stFQN: String): TCurrencyMarket;
begin
  Result := Add as TCurrencyMarket;
  Result.FFQN := stFQN;
end;

{ TCommodityMarket }

function TCommodityMarket.GetCommodity(i: Integer): TCommodity;
begin
  Result := FSymbols[i] as TCommodity;
end;

{ TCommodityMarkets }

constructor TCommodityMarkets.Create;
begin
  inherited Create(TCommodityMarket);
end;

function TCommodityMarkets.GetBondMarket(i: Integer): TCommodityMarket;
begin
  Result := GetMarket(i) as TCommodityMarket;
end;

function TCommodityMarkets.New(stFQN: String): TCommodityMarket;
begin
  Result := Add as TCommodityMarket;
  Result.FFQN := stFQN;
end;



end.
