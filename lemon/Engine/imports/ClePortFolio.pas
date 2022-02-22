unit ClePortFolio;

interface

uses
  Classes, SysUtils,  DateUtils,

  CleSymbols, CleDistributor, CleQuoteTimers,

  CleOrders, CleAccounts, ClePositions, CleFills
  ;

type

  // snap - shot
  TPortFolio = class( TCollectionItem )
  private
  {
    FClosedOrders: TList;
    FRjtOrders: TList;
    FActiveOrders: TList;
    }
    FClosedOrders: TCollection;
    FRjtOrders: TCollection;
    FActiveOrders: TCollection;

    FPortFolioPos: integer;
    FDataTime: TDateTime;
    FPositionFrag: TCollection;

    FOrdersCount: integer;
    FPositionsCount: integer;
    FTicketCount: integer;
    FFillCount: integer;
    FResultCount: integer;

  public
    constructor Create(aColl: TCollection); override;
    Destructor Destroy ; override;

    property PortFolioPos : integer read FPortFolioPos;
    property DataTime     : TDateTime read FDataTime;

    property ActiveOrders : TCollection read FActiveOrders;
    property ClosedOrders : TCollection read FClosedOrders;
    property RjtOrders    : TCollection read FRjtOrders;
    property PositionFrag : TCollection read FPositionFrag;

    property OrdersCount  : integer read FOrdersCount;
    property PositionsCount  : integer read FPositionsCount;
    property TicketCount  : integer read FTicketCount;
    property FillCount    : integer read FFillCount;
    property ResultCount  : integer read FResultCount;

    procedure Reset;
    {
    property ActiveOrders : TList read FActiveOrders;
    property ClosedOrders : TList read FClosedOrders;
    property RjtOrders    : TList read FRjtOrders;
    }
    //property PlFrage      : TPlFragMent read FPlFrage;
  end;

  TPortFolios  = class( TCollection )
  private
    FPos: integer;
    FOrders: TCollection;
    FFills: TCollection;
    FResults: TCollection;
    FLoading: boolean;
    function GetPortFolio(i: integer): TPortFolio;
  public
    Constructor Create;
    Destructor Destroy; override;

    function New( aPos : integer ) : TPortFolio;
    function Find( aPos: integer ) : TPortFolio;
    function Prev( aPos: integer ) : TPortFolio;
    function Next( aPos: integer ) : TPortFolio;

    property PortFolios[i : integer] : TPortFolio read GetPortFolio; default;
    property Pos : integer read FPos;

    procedure PrePareIo(aPos: Integer; stAcnt, stCode : string );
    procedure Arrange;

    property Fills  : TCollection read FFills;
    property Orders : TCollection read FOrders;
    property Results: TCollection read FResults;
    property Loading: boolean read FLoading write FLoading;

    function GetLastPosition : string;
    procedure Reset;
  end;



implementation

uses GAppEnv, FleKrxQuoteEmulation;

{ TPortFolios }


{ TPortFolios }



constructor TPortFolios.Create;
begin
  inherited Create( TPortFolio );
  FOrders:= TCollection.Create( TOrder );
  FFills:= TCollection.Create( TFill );
  FResults:= TCollection.Create( TOrderResult );
  FPos  := 0;
end;

destructor TPortFolios.Destroy;
begin
  FOrders.Free;
  FFills.Free;
  FResults.Free;
  inherited;
end;

function TPortFolios.Find(aPos: integer): TPortFolio;
var
  i, iLast: Integer;
  aFolio : TPortFolio;
begin
  Result := nil;

  iLast := Count -1;
  if iLast >= 0 then
  begin
    aFolio  := TPortFolio( Items[iLast] );
    if aFolio.FPortFolioPos < aPos then
    begin
      Result := aFolio;
      Exit;
    end;
  end;


  for i := 0 to Count - 1 do begin
    aFolio  := TPortFolio( Items[i] );//PortFolios[i];
    if aFolio.FPortFolioPos > aPos then
    begin
      if i = 0 then
        Result  := TPortFolio( Items[0] )
      else
        Result := TPortFolio( Items[i-1] );
      break;
    end;
  end;

end;

function TPortFolios.GetLastPosition: string;
var
  aFolio : TPortFolio;
  i : integer;
  aPos : TPosition;
begin
  if Count = 0 then
    Exit;

  aFolio  := TPortFolio( Items[ Count-1 ]);
  for i := 0 to  aFolio.FPositionFrag.Count -1 do
  begin
    aPos  := TPosition( aFolio.FPositionFrag.Items[i] );
    Result  := Result + aPos.Symbol.Code + ':' + IntToStr( aPos.Volume ) + '  ';
  end;

end;

function TPortFolios.GetPortFolio(i: integer): TPortFolio;
begin
  if (i >= 0) and ( i < Count-1 ) then
    Result := PortFolios[i]
  else
    Result := nil;
end;

function TPortFolios.New(aPos: integer): TPortFolio;
begin
  Result  := Add as TPortFolio;

  Result.FPortFolioPos  := aPos;

end;

function TPortFolios.Next(aPos: integer): TPortFolio;
var
  aPortFolio: TPortFolio;
  stLog : string;
begin
  Result := nil;

  if FPos > Count-1 then Exit;

  aPortFolio := GetPortFolio(FPos);

  if aPortFolio.FPortFolioPos <= aPos then
  begin
    Result := aPortFolio;
    Inc(FPos);
  end;
end;

procedure TPortFolios.PrePareIo(aPos: Integer; stAcnt, stCode : string );
var
  i : integer;
  aDest, aSrc  : TOrder;
  aAccount  : TAccount;
  aSymbol   : TSymbol;
  aFolio    : TPortFolio;
  aSrcp, aDestp : TPosition;
begin
  FPos  := aPos;

  aAccount  := gEnv.Engine.TradeCore.Accounts.Find( stAcnt );
  aSymbol   := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if (aAccount = nil ) or ( aSymbol = nil ) then Exit;

  aFolio := New( FPos );

  aFolio.FOrdersCount := gEnv.Engine.TradeCore.Orders.Count;
  aFolio.FPositionsCount  := gEnv.Engine.TradeCore.Positions.Count;
  aFolio.FTicketCount := gEnv.Engine.TradeCore.OrderTickets.Count;
  aFolio.FResultCount := gEnv.Engine.TradeCore.OrderResults.Count;
  aFolio.FFillCount   := gEnv.Engine.TradeCore.Fills.Count;

  // active order
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aSrc  := gEnv.Engine.TradeCore.Orders.ActiveOrders.Orders[i];
    aDest := aFolio.FActiveOrders.Add as TOrder;
    aDest.Assign( aSrc );
  end;
  {
  for i := 0 to gEnv.Engine.TradeCore.Orders.ClosedOrders.Count - 1 do
  begin
    aSrc  := gEnv.Engine.TradeCore.Orders.ClosedOrders.Orders[i];
    aDest := aFolio.FClosedOrders.Add as TOrder;
    aDest.Assign( aSrc );
  end;

  for i := 0 to gEnv.Engine.TradeCore.Orders.RjtOrders.Count - 1 do
  begin
    aSrc  := gEnv.Engine.TradeCore.Orders.RjtOrders.Orders[i];
    aDest := aFolio.FRjtOrders.Add as TOrder;
    aDest.Assign( aSrc );
  end;
  }
  for i := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
  begin
    aSrcp   := gEnv.Engine.TradeCore.Positions.Positions[i];
    aDestp  := aFolio.FPositionFrag.Add as TPosition;
    aDestp.Assign( aSrcp );
  end;
end;

procedure TPortFolios.Arrange;
var
  i : integer;
  aDest, aSrc  : TOrder;
  aFolio    : TPortFolio;
  aDestF, aSrcF : TFill;
  aDestR, aSrcR : TOrderResult;
begin
  //Exit;
  for i := 0 to gEnv.Engine.TradeCore.Orders.Count - 1 do
  begin
    aSrc  := gEnv.Engine.TradeCore.Orders.Orders[i];
    aDest := FOrders.Add as TOrder;
    aDest.Assign( aSrc );
  end;

  for i := 0 to gEnv.Engine.TradeCore.Fills.Count - 1 do
  begin
    aSrcF  := gEnv.Engine.TradeCore.Fills.Fills[i];
    aDestF := FFills.Add as TFill;
    aDestF.Assign( aSrcF );
  end;

  for i := 0 to gEnv.Engine.TradeCore.OrderResults.Count - 1 do
  begin
    aSrcR  := gEnv.Engine.TradeCore.OrderResults.Results[i];
    aDestR := TOrderResult( FResults.Add );
    aDestR.Assign( aSrcR );
  end;

end;

function TPortFolios.Prev(aPos: integer): TPortFolio;
var
  aPortFolio: TPortFolio;
  stLog : string;
begin
  Result := nil;

  if FPos < 0 then Exit;

  aPortFolio := GetPortFolio(FPos);

  if aPortFolio.FPortFolioPos >= aPos then
  begin
    Result := aPortFolio;
    dec(FPos);
  end;

end;


procedure TPortFolios.Reset;
var
  i : integer;
  aFolio : TPortFolio;
begin
  gEnv.Engine.TradeCore.Clear;
  gEnv.Engine.TradeBroker.Clear;

  FOrders.Clear;
  FFills.Clear;
  FResults.Clear;

  for i := 0 to Count - 1 do
  begin
    aFolio  := TPortFolio( Items[i] );
    aFolio.Reset;
  end;

  Clear;
end;

{ TPortFolio }

constructor TPortFolio.Create(aColl: TCollection);
begin
  inherited Create(aColl);
{
  FClosedOrders := TList.Create;
  FRjtOrders    := TList.Create;
  FActiveOrders := TList.Create;
  }
  FClosedOrders := TCollection.Create( TOrder );
  FRjtOrders    := TCollection.Create( TOrder );
  FActiveOrders := TCollection.Create( TOrder );
  FPositionFrag := TCollection.Create( TPosition );



  FOrdersCount:= 0;
  FPositionsCount:= 0;
  FTicketCount  := 0;
  FFillCount:= 0;
  FResultCount:= 0;
end;

destructor TPortFolio.Destroy;
begin
  FClosedOrders.Free;
  FRjtOrders.Free;

  FActiveOrders.Free;
  FPositionFrag.Free;

  inherited;
end;

procedure TPortFolio.Reset;
begin
  FClosedOrders.clear;
  FRjtOrders.clear;

  FActiveOrders.clear;
  FPositionFrag.clear;
end;

end.
