unit CleVirtualTrade;

interface
uses
  Classes, SysUtils,
  CleVirtualHult, CleSymbols, CleQuoteBroker;

type

  THults = class(TList)
  private
    FSymbol : TSymbol;
    procedure MakeHult( iGap : integer );
  public
    constructor Create;
    destructor Destroy; override;
    property Symbol : TSymbol read FSymbol;
  end;

  TVirtualTrade = class
  private
    FVirtualHult : TVirtualHult;
    FHults : THults;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DoQoute(aQuote : TQuote);
    procedure ReSet;

    procedure SetVirtualTrade;
    function GetHult( iGap : integer) : TVirtualHult;
    property Hults : THults read FHults;
    property VirtualHult : TVirtualHult read FVirtualHult;
  end;


implementation
uses
  GAppEnv;

{ TVirtualTrades }

constructor TVirtualTrade.Create;
begin
  // ∞°º∫«Ê∆Æ
  FHults := THults.Create;
  FVirtualHult := nil;
end;

destructor TVirtualTrade.Destroy;
begin
  FHults.Free;
  inherited;
end;

procedure TVirtualTrade.DoQoute(aQuote: TQuote);
var
  i : integer;
  aItem : TVirtualHult;
begin
  if aQuote.Symbol = FHults.Symbol then
  begin
    for i := 0 to FHults.Count - 1 do
    begin
      aItem := FHults.Items[i];
      aItem.DoQuote(aQuote);
    end;
  end;
end;

function TVirtualTrade.GetHult(iGap: integer): TVirtualHult;
var
  i : integer;
  aItem : TVirtualHult;
begin
  Result := nil;
  FVirtualHult := nil;
  for i := 0 to FHults.Count - 1 do
  begin
    aItem := FHults.Items[i];
    if aItem.HultPrices.Gap = iGap then
    begin
      Result := aItem;
      FVirtualHult := aItem;
      break;
    end;
  end;
end;

procedure TVirtualTrade.ReSet;
var
  i : integer;
  aItem : TVirtualHult;
begin
  FVirtualHult := nil;
  for i := 0 to FHults.Count - 1 do
  begin
    aItem := FHults.Items[i];
    aItem.ReSet;
  end;
  FHults.Clear;
end;

procedure TVirtualTrade.SetVirtualTrade;
begin

  if not gEnv.VirHultAutoMake then Exit;
  
  FVirtualHult := nil;
  FHults.MakeHult(4);
  FHults.MakeHult(5);
end;

{ THults }

constructor THults.Create;
begin
end;

destructor THults.Destroy;
begin
  inherited;
end;

procedure THults.MakeHult(iGap: integer);
var
  aHult : TVirtualHult;
begin
  FSymbol := gEnv.Engine.SymbolCore.Futures[0];
  if FSymbol = nil then exit;

  aHult := TVirtualHult.Create;
  Add(aHult);
  aHult.SetSymbol(FSymbol, iGap);
end;

end.
