unit CleSaveFrameItems;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleQuoteBroker, ClePriceItems

  ;


type
  TSaveFrameItem = class( TCollectionItem )
  private
    FPrevBids: TMarketDepths;
    FPrevAsks: TMarketDepths;
    FLastData: TOrderData;
    FFrameTime: TDateTime;
    FPriceAxis: TPriceAxis;
    FLastSale: TTimeNSale;
    FBids: TMarketDepths;
    FAsks: TMarketDepths;
    FLow: double;
    FOpen: double;
    FHigh: double;
    FLogTime: TDateTime;
    FDataIdx: integer;
    FEventCount: integer;
    FLastEvent: TQuoteType;

  public
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    procedure Assign( var bOK : boolean; aQuote : TQuote );

    property PriceAxis : TPriceAxis read FPriceAxis write FPriceAxis;
    property FrameTime : TDateTime read FFrameTime write FFrameTime;
    property LogTime : TDateTime read FLogTime write FLogTime;

    property Asks  : TMarketDepths read FAsks write FAsks;
    property Bids  : TMarketDepths read FBids write FBids;

    property Open : double read FOpen write FOpen;
    property Low  : double read FLow write FLow;
    property High : double read FHigh write FHigh;

    property PrevAsks  : TMarketDepths read FPrevAsks write FPrevAsks;
    property PrevBids  : TMarketDepths read FPrevBids write FPrevBids;

    property LastData  : TOrderData  read FLastData  write FLastData;
    property DataIdx   : integer read FDataIdx write FDataIdx;

    property LastSale  : TTimeNSale read FLastSale  write FLastSale;
    property EventCount: integer read FEventCount write FEventCount;
    property LastEvent : TQuoteType read FLastEvent write FLastEvent;
  end;

  TSaveFrameItems = class( TCollection )
  private
    function GetSaveFrameItem(i: integer): TSaveFrameItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( fTime : TDateTime ) :  TSaveFrameItem;
    function Find( fTime : TDateTime ):  TSaveFrameItem;
    property FrameItem[i : integer] : TSaveFrameItem  read GetSaveFrameItem;

  end;

  TQuoteSaveItem = class( TCollectionItem )
  public
    SaveItem  : TSaveFrameItems;
    Symbol    : TSymbol ;
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;
  end;

  TQuoteSaveItems = class( TCollection )
  private
    function GetQuoteSaveItem(i: integer): TQuoteSaveItem;
  public
    Constructor Create;
    Destructor  Destroy; override;
    function New( aSymbol : TSymbol ) : TQuoteSaveItem;
    function Find(aSymbol : TSymbol ) : TQuoteSaveItem;
    procedure DoSave( aQuote : TQuote; logTime : TDateTime );
    procedure DoDistribute(  Index : integer; dtTime : TDateTime );
    property SaveItem[i : integer] : TQuoteSaveItem  read GetQuoteSaveItem;
  end;

implementation

uses
  GAppEnv;
{ TSaveFrameItem }

procedure TSaveFrameItem.Assign(var bOK: boolean; aQuote: TQuote);
var
  aSave : TQuoteSaveItem;
  aItem : TSaveFrameITem;
  pData, aData : TOrderData;

  aPrice,pPrice : TPriceItem;
  i : integer;
  aSale : TTimeNSale;
begin

  if aQuote = nil then Exit;

  aQuote.LastEvent  := FLastEvent;
  aQuote.Bids.VolumeTotal := FBids.VolumeTotal;
  aQuote.Bids.CntTotal    := FBids.CntTotal;

  aQuote.Asks.VolumeTotal := FAsks.VolumeTotal;
  aQuote.Asks.CntTotal    := FAsks.CntTotal;

  aQuote.PrevBids.VolumeTotal := FPrevBids.VolumeTotal;
  aQuote.PrevBids.CntTotal    := FPrevBids.CntTotal;

  aQuote.PrevAsks.VolumeTotal := FPrevAsks.VolumeTotal;
  aQuote.PrevAsks.CntTotal    := FPrevAsks.CntTotal;

  aQuote.Open := FOpen;
  aQuote.High := FHigh;
  aQuote.Low  := FLow;

  for i := 0 to aQuote.Asks.Size - 1 do
  begin
    aQuote.PrevAsks[i].Price  := FPrevAsks[i].Price;
    aQuote.PrevAsks[i].Volume := FPrevAsks[i].Volume;
    aQuote.PrevAsks[i].Cnt    := FPrevAsks[i].Cnt;

    aQuote.Asks[i].Price      := FAsks[i].Price;
    aQuote.Asks[i].Volume     := FAsks[i].Volume;
    aQuote.Asks[i].Cnt        := FAsks[i].Cnt;

    aQuote.PrevBids[i].Price  := FPrevBids[i].Price;
    aQuote.PrevBids[i].Volume := FPrevBids[i].Volume;
    aQuote.PrevBids[i].Cnt    := FPrevBids[i].Cnt;

    aQuote.Bids[i].Price      := FBids[i].Price;
    aQuote.Bids[i].Volume     := FBids[i].Volume;
    aQuote.Bids[i].Cnt        := FBids[i].Cnt;
  end;

  for i:=0 to PriceAxis.Count-1 do
  begin
    pPrice := PriceAxis.Prices[i];
    aPrice := aQuote.PriceAxis.Find( pPrice.Price );
    pPrice.Assign( aPrice );
  end;

  aQuote.EventCount := FEventCount;
  aQuote.PriceAxis.DataIdx  :=  (aQuote.PriceAxis.OrderList.Count -1) - FDataIdx;

  if FlastSale.Price > 0.001 then
  begin
    aQuote.Sales.Clear;
    aSale := aQuote.Sales.New;
    aSale.Price := FLastSale.Price;
    aSale.Volume  := FLastSale.Volume;
    aSale.PrevPrice := FLastSale.PrevPrice;
    aSale.DayVolume := FLastSale.DayVolume;
    aSale.Time      := FLastSale.Time;
    aSale.Side      := FLastSale.Side;
    aSale.DayAmount := FLastSale.DayAmount;
    aSale.LocalTime := FLastSale.LocalTime;
  end;

  aQuote.LastData.Free;
  aQuote.LastData := TOrderData.Create( nil );

  if LastData <> nil then
    with aQuote.LastData do
    begin
      Name  := LastData.Name;
      Own   :=  LastData.Own;
      Price :=  LastData.Price;
      Qty   := LastData.Qty;
      Side  := LastData.Side;
      Time  := LastData.Time;
      Condition := LastData.Condition;
      QType := LastData.QType;
      No    := LastData.No;
      No2   := LastData.No2;
      FType := LastData.FType;
      BGone := LastData.BGone;
      FillQty := LastData.FillQty;
      ContinueFill  := LastData.ContinueFill;
    end;

  bOK := true;
end;

constructor TSaveFrameItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );

  FPrevBids:= TMarketDepths.Create;
  FPrevAsks:= TMarketDepths.Create;

  FBids:= TMarketDepths.Create;
  FAsks:= TMarketDepths.Create;

  FPriceAxis:= TPriceAxis.Create;
  FLastData:= TOrderData.Create( nil );
  FLastSale:= TTimeNSale.Create( nil );

end;

destructor TSaveFrameItem.Destroy;
begin
  FPrevBids.Free;
  FPrevAsks.Free;

  FBids.Free;
  FAsks.Free;

  FPriceAxis.Free;
  FLastData.Free;
  FLastSale.Free;
  inherited;
end;

{ TSaveFrameItems }

constructor TSaveFrameItems.Create;
begin
  inherited Create( TSaveFrameItem );
end;

destructor TSaveFrameItems.Destroy;
begin

  inherited;
end;

function TSaveFrameItems.Find(fTime: TDateTime): TSaveFrameItem;
var
  i : integer;
  aItem : TSaveFrameItem;
  aTime : TDateTime;
  stLog : string;
begin
  if Count > 0 then
    Result := Items[0] as TSaveFrameItem
  else
    Result := nil;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TSaveFrameItem;
    aTime := aItem.LogTime ;

    stLog := Format('%d: %s|%s',
      [
        i,

        FormatDateTime('hh:nn:ss.zzz', aTime),
        FormatDateTime('hh:nn:ss.zzz', fTime)
      ]);
    gEnv.EnvLog( WIN_TEST, stLog);

    if aTime > fTime then Break;
    Result := aItem;
  end;
end;

function TSaveFrameItems.GetSaveFrameItem(i: integer): TSaveFrameItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TSaveFrameItem;
end;

function TSaveFrameItems.New(fTime: TDateTime): TSaveFrameItem;
begin
  Result := Add as TSaveFrameItem;
  Result.FFrameTime := fTime;
end;

{ TQuoteSaveItem }

constructor TQuoteSaveItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  SaveItem := TSaveFrameItems.Create;

end;

destructor TQuoteSaveItem.Destroy;
begin
  SaveItem.Free;
  inherited;
end;

{ TQuoteSaveItems }

constructor TQuoteSaveItems.Create;
begin
  inherited Create(  TQuoteSaveItem );
end;

destructor TQuoteSaveItems.Destroy;
begin

  inherited;
end;

procedure TQuoteSaveItems.DoDistribute( Index : integer; dtTime : TDateTime );
var
  i : integer;
  aQuote : TQuote;
  aSave : TQuoteSaveItem;
  aItem : TSaveFrameItem;
  bOK : boolean;
  stLog : string;
begin
  for i := 0 to Count - 1 do
  begin
    bOK := false;
    aSave := SaveItem[i];
    aQuote := aSave.Symbol.Quote as TQuote;
    aItem  := aSave.SaveItem.FrameItem[Index];
    if aItem = nil then Continue;

    stLog := Format('%d:%s, %s|%s|%s',
      [
        i,
        aSave.Symbol.ShortCode,
        FormatDateTime('hh:nn:ss.zzz', dtTime),
        FormatDateTime('hh:nn:ss.zzz', aItem.FFrameTime),
        FormatDateTime('hh:nn:ss.zzz', aItem.FLogtime)
      ]);

    gEnv.EnvLog( WIN_TEST, stLog);

    aItem.Assign(bOK, aQuote );
    if bOK then
      aquote.Update2( dtTime );
  end;
end;

procedure TQuoteSaveItems.DoSave(aQuote: TQuote; logTime : TDateTime);
var
  aSave : TQuoteSaveItem;
  aItem : TSaveFrameITem;

  aPrice,pPrice : TPriceItem;
  i : integer;
  stLog : string;
begin


  aSave := Find( aQuote.Symbol );
  if aSave = nil then Exit;
  aItem := aSave.SaveItem.New( aQuote.LastQuoteTime );
  aItem.LogTime := logTime;
  {
  stLog := Format('%d : %s, %s ',
  [
    aSave.SaveItem.Count,
    FormatDateTime( 'hh:nn:ss.zzz', aQuote.LastQuoteTime ),
    FormatDateTime( 'hh:nn:ss.zzz', aQuote.LastEventTime )
  ]);
  gEnv.EnvLog( WIN_SIS, stLog);
  }

  aItem.LastEvent      := aQuote.LastEvent;

  aItem.FPrevBids.Size := aQuote.Bids.Size ;
  aItem.FBids.Size     := aQuote.Bids.Size;
  aItem.FPrevBids.VolumeTotal  := aQuote.PrevBids.VolumeTotal;
  aItem.FPrevBids.CntTotal     := aQuote.PrevBids.CntTotal;

  aItem.FPrevAsks.Size  := aQuote.Asks.Size ;
  aItem.FAsks.Size      := aQuote.Asks.Size;
  aItem.FPrevAsks.VolumeTotal  := aQuote.PrevAsks.VolumeTotal;
  aItem.FPrevAsks.CntTotal     := aQuote.PrevAsks.CntTotal;

  aItem.Open := aQuote.Open;
  aItem.High := aQuote.High;
  aItem.Low  := aQuote.Low;

  for i := 0 to aQuote.Asks.Size - 1 do
  begin
    aItem.FPrevAsks[i].Price  := aQuote.PrevAsks[i].Price;
    aItem.FPrevAsks[i].Volume := aQuote.PrevAsks[i].Volume;
    aItem.FPrevAsks[i].Cnt    := aQuote.PrevAsks[i].Cnt;

    aItem.FAsks[i].Price  := aQuote.Asks[i].Price;
    aItem.FAsks[i].Volume := aQuote.Asks[i].Volume;
    aItem.FAsks[i].Cnt    := aQuote.Asks[i].Cnt;

    if aQuote.Asks[i].Price > 0.001 then
    begin
      pPrice  := aQuote.PriceAxis.Find(aQuote.Asks[i].Price);
      aPrice  := aItem.PriceAxis.New(aQuote.Asks[i].Price);
      pPrice.Assign(aPrice);
    end;
    //aPrice.

    aItem.FPrevBids[i].Price  := aQuote.PrevBids[i].Price;
    aItem.FPrevBids[i].Volume := aQuote.PrevBids[i].Volume;
    aItem.FPrevBids[i].Cnt    := aQuote.PrevBids[i].Cnt;

    aItem.FBids[i].Price  := aQuote.Bids[i].Price;
    aItem.FBids[i].Volume := aQuote.Bids[i].Volume;
    aItem.FBids[i].Cnt    := aQuote.Bids[i].Cnt;

    if aQuote.Bids[i].Price > 0.001 then
    begin
      pPrice  := aQuote.PriceAxis.Find(aQuote.Bids[i].Price);
      aPrice  := aItem.PriceAxis.New(aQuote.Bids[i].Price);
      pPrice.Assign(aPrice);
    end;
  end;

  if aQuote.Sales.Count > 0 then
  begin
    aItem.FLastSale.Price := aQuote.Sales.Last.Price;
    aItem.FLastSale.PrevPrice := aQuote.Sales.Last.PrevPrice;
    aItem.FLastSale.Volume    := aQuote.Sales.Last.Volume;
    aItem.FLastSale.LocalTime := aQuote.Sales.Last.LocalTime;
    aItem.FLastSale.DayVolume := aquote.Sales.Last.DayVolume;
    aItem.FLastSale.Time      := aQuote.Sales.Last.Time;
    aItem.FLastSale.Side      := aQuote.Sales.Last.Side;
    aItem.FLastSale.DayAmount := aQuote.Sales.Last.DayAmount;

  end;

  if aQuote.LastData <> nil then
    with aQuote.LastData do
    begin
      aItem.LastData.Name:= Name;
      aItem.LastData.Own:= Own;
      aItem.LastData.Price:= Price;
      aItem.LastData.Qty:= Qty;
      aItem.LastData.Side:= Side;
      aItem.LastData.Time:= Time;
      aItem.LastData.Condition:= Condition;
      aItem.LastData.QType:= QType;
      aItem.LastData.No:= No;
      aItem.LastData.No2:= No2;
      aItem.LastData.FType:= FType;
      aItem.LastData.BGone:= BGone;
      aItem.LastData.FillQty:= FillQty;
      aItem.LastData.ContinueFill:= ContinueFill;
    end;

  aItem.FDataIdx := aQuote.PriceAxis.OrderList.Count -1;
  aItem.EventCount  := aQuote.EventCount;
  //aItem.

end;

function TQuoteSaveItems.Find(aSymbol: TSymbol): TQuoteSaveItem;
var
  i : integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if GetQuoteSaveItem(i).Symbol = aSymbol then
    begin
      Result := GetQuoteSaveItem(i);
      break;
    end;
end;

function TQuoteSaveItems.GetQuoteSaveItem(i: integer): TQuoteSaveItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TQuoteSaveItem;
end;

function TQuoteSaveItems.New(aSymbol: TSymbol): TQuoteSaveItem;
begin
  Result := Add as TQuoteSaveItem;
  Result.Symbol := aSymbol;
end;

end.
