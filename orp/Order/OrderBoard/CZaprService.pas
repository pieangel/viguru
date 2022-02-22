unit CZaprService;

//
// Zero Arbitrage (Chance) Price Range service for an options symbol
//

interface

uses
  Classes, SysUtils, Math,

    // lemon: common
  GleConsts,
    // lemon: symbol
  CleFQN, CleSymbols, CleKrxSymbols, CleMarkets,
    // lemon: quote
  CleQuoteBroker,
    // lemon: utils
  CleDistributor
  ;
    //


type
  TZaprService = class
  private
    FOption: TOption;

    FRefCall: TOption;
    FRefPut: TOption;
    FQuoteRefCall: TQuote;
    FQuoteRefPut: TQuote;

    FCall: TOption;
    FPut: TOption;
    FQuoteCall: TQuote;
    FQuotePut: TQuote;

    FKospi200: TSymbol;

    FUnderReady: Boolean;

    FRefCallReady: Boolean;
    FRefPutReady: Boolean;
    FCallReady: Boolean;
    FPutReady: Boolean;

    FUnderPrice : Double;

    FOnPriceChanged : TNotifyEvent;

    procedure SetSymbol(aSymbol: TOption);
    function GetReady : Boolean;
    procedure PrepareService;

    procedure UnderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure Subscribe;
    procedure Unsubscribe;
    function GetMinPrice : Double;
    function GetMaxPrice : Double;
  public
    constructor Create;
    destructor Destroy; override;

    property Option: TOption read FOption write SetSymbol;

    property Ready: Boolean read GetReady;

    property MinPrice: Double read GetMinPrice;
    property MaxPrice: Double read GetMaxPrice;

    property OnPriceChanged : TNotifyEvent read FOnPriceChanged write FOnPriceChanged;
  end;


implementation

uses
  GAppEnv;

constructor TZaprService.Create;
begin
  inherited;

  FOption := nil;

  FCall := nil;
  FPut := nil;
  FRefCall := nil;
  FRefPut := nil;

  FRefCallReady := False;
  FRefPutReady := False;
  FCallReady := False;
  FPutReady := False;

  FUnderReady := False;
  FUnderPrice := 0.0;

  FKospi200 := gEnv.Engine.SymbolCore.Symbols.FindCode(KOSPI200_CODE);
  if FKospi200 <> nil then
    gEnv.Engine.QuoteBroker.Subscribe(Self, FKospi200, UnderProc);
end;

destructor TZaprService.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel(Self);
    
  Unsubscribe;

  inherited;
end;

function TZaprService.GetReady;
begin
  Result := FCallReady and FPutReady and FRefCallReady and FRefPutReady;
end;

procedure TZaprService.Subscribe;
begin
  if FCall <> nil then
    FQuoteCall := gEnv.Engine.QuoteBroker.Subscribe(Self, FCall, QuoteProc);
  if FPut <> nil then
    FQuotePut := gEnv.Engine.QuoteBroker.Subscribe(Self, FPut, QuoteProc);
  if FRefCall <> nil then
    FQuoteRefCall := gEnv.Engine.QuoteBroker.Subscribe(Self, FRefCall, QuoteProc);
  if FRefPut <> nil then
    FQuoteRefPut := gEnv.Engine.QuoteBroker.Subscribe(Self, FRefPut, QuoteProc);
end;

procedure TZaprService.Unsubscribe;
begin
  if FCall <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel(Self, FCall);
    FCallReady := False;
    FCall := nil;
    FQuoteCall := nil;
  end;
  if FPut <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel(Self, FPut);
    FPutReady := False;
    FPut := nil;
    FQuotePut := nil;
  end;
  if FRefCall <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel(Self, FRefCall);
    FRefCallReady := False;
    FRefCall := nil;
    FQuoteRefCall := nil;
  end;
  if FRefPut <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel(Self, FRefPut);
    FRefPutReady := False;
    FRefPut := nil;
    FQuoteRefPut := nil;
  end;

  FOption := nil;
end;

procedure TZaprService.SetSymbol(aSymbol: TOption);
begin
  //--1. Unsubscribe
  Unsubscribe;

  //--2. Check
  if (aSymbol = nil) or (aSymbol.Underlying <> FKospi200) then
  begin
    if Assigned(FOnPriceChanged) then
      FOnPriceChanged(Self);

    Exit;
  end;

  //--3. Set Symbols
  FOption := aSymbol;

  //--4. Make service environment
  if FUnderReady then
    PrepareService;
end;

procedure TZaprService.PrepareService;
var
  aTree: TOptionTree;
  aMarket: TOptionMarket;
  i: Integer;
  aStrikeSymbol, aStrike0, aStrike1, aStrike2 : TStrike;
begin
  if FOption = nil then Exit;

    // find a market
  aMarket := gEnv.Engine.SymbolCore.OptionMarkets.Find(FQN_KOSPI200_OPTION) as TOptionMarket;
  if aMarket = nil then Exit;

    // find the tree
  aTree := nil;

  for i := 0 to aMarket.Trees.Count - 1 do
    with aMarket.Trees[i] do
    if (ExpYear = FOption.ExpYear) and (ExpMonth = FOption.ExpMonth) then
    begin
      aTree := aMarket.Trees[i];
      Break;
    end;
    
  if aTree = nil then Exit;

    // find other class with the same strike price
  aStrikeSymbol := nil;
  
  for i:=0 to aTree.Strikes.Count-1 do
    if Abs(FOption.StrikePrice - aTree.Strikes[i].StrikePrice)
               < EPSILON then
    begin
      aStrikeSymbol := aTree.Strikes[i];
      FCall := aStrikeSymbol.Call;
      FPut := aStrikeSymbol.Put;

      Break;
    end;
    
  if aStrikeSymbol = nil then Exit;

  //  find two nearest strike prices to Kospi200 close price
  aStrike0 := nil;
  aStrike1 := nil;
  aStrike2 := nil;
  
  for i:=0 to aTree.Strikes.Count-1 do
  begin
    aStrike2 := aTree.Strikes[i];
    if aStrike2.StrikePrice > FUnderPrice then
    begin
      if i > 0 then
      begin
        //--1. find referece stike price
        aStrike1 := aTree.Strikes[i-1];
        if aStrikeSymbol = aStrike1 then
          aStrike0 := aStrike2
        else
        if aStrikeSymbol = aStrike2 then
          aStrike0 := aStrike1
        else
        if (aStrike2.StrikePrice-FUnderPrice) <
                                 (FUnderPrice-aStrike1.StrikePrice) then
          aStrike0 := aStrike1
        else
          aStrike0 := aStrike2;
      end;

      //--2. set referece symbols
      FRefCall := aStrike0.Call;
      FRefPut := aStrike0.Put;

      //--3. subscribe
      Subscribe;

      Break;
    end;
  end;
end;

procedure TZaprService.UnderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if FKospi200 = nil then Exit;

  FUnderPrice := FKospi200.Last;

  if (FUnderPrice > 1) and (not FUnderReady) then
  begin
    FUnderReady := True;

    if FOption <> nil then
    begin
      FUnderReady := True;
      PrepareService;
    end;
  end;
end;

procedure TZaprService.QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aSymbol : TSymbol;
begin
  if (DataObj = nil) or (not (DataObj is TSymbol)) then Exit;

  aSymbol := DataObj as TSymbol;


  if (not FCallReady) and (aSymbol = FCall) then
    FCallReady := True;
  if (not FPutReady) and (aSymbol = FPut) then
    FPutReady := True;
  if (not FRefCallReady) and (aSymbol = FRefCall) then
    FRefCallReady := True;
  if (not FRefPutReady) and (aSymbol = FRefPut) then
    FRefPutReady := True;

  if GetReady then
    if Assigned(FOnPriceChanged) then
      FOnPriceChanged(Self);
end;

function TZaprService.GetMinPrice : Double;
begin
  case FOption.CallPut of
    'C' :
      Result := // combinated future
              FRefCall.StrikePrice + FQuoteRefCall.Bids[0].Price
                                   - FQuoteRefPut.Asks[0].Price +
                //
              FQuotePut.Bids[0].Price - FOption.StrikePrice;
    'P' :
      Result := FOption.StrikePrice + FQuoteCall.Bids[0].Price -
              // combinated future
              (FRefCall.StrikePrice + FQuoteRefCall.Asks[0].Price
                                    - FQuoteRefPut.Bids[0].Price);
  end;

  Result := Max(0, Result);
end;

function TZaprService.GetMaxPrice : Double;
begin
  case FOption.CallPut of
    'C' :
      Result := // combinated future
              FRefCall.StrikePrice + FQuoteRefCall.Asks[0].Price
                                   - FQuoteRefPut.Bids[0].Price +
              //
              FQuotePut.Asks[0].Price - FOption.StrikePrice;
    'P' :
      Result := FOption.StrikePrice + FQuoteCall.Asks[0].Price -
              // combinated future
              (FRefCall.StrikePrice + FQuoteRefCall.Bids[0].Price
                                   - FQuoteRefPut.Asks[0].Price);
  end;

  Result := Max(0, Result);
end;

end.
