unit CleVirtualHult;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleSymbols, CleQuoteBroker, CleKrxSymbols;

type

  TFillType = (ftCurrent, ftOpposition);

  THultPriceItem = class(TCollectionItem)
  private
    FSide : integer;
    FQty : integer;
    FPrice : double;
    FPriceStr : string;
    FPriceIndex : integer;
  public
    property Side : integer read FSide write FSide;
    property Qty : integer read FQty write FQty;
    property Price : double read FPrice;
    property PriceStr : string read FPriceStr write FPriceStr;
    property PriceIndex : integer read FPriceIndex;
  end;


  THultPrices = class(TCollection)
  private
    FSymbol : TSymbol;
    FGap : integer;
    FVolume : integer;
    FAvgPrice : double;
    FEntryPL : double;
    FEntryOTE : double;
    FPL : double;
    FBaseItem : THultPriceItem;
    FMaxPL, FMinPL : double;

    procedure CalPL(aQuote : TQuote; dFill : double; iSide, iFillQty : integer);
    function GetPL : double;
  public
    constructor Create;
    destructor Destroy; override;

    function New(dPrice : double; iSide, iQty, iIndex : integer) : THultPriceItem;
    function Find(stPrice : string) : THultPriceItem;
    function GetPriceItem(iIndex : integer) : THultPriceItem;
    procedure FillUpdate(aQuote : TQuote; iCnt, iSide : integer);
    procedure Reset;
    procedure UpdateOTE(aQuote : TQuote);
    property Gap : integer read FGap write FGap;
    property BaseItem : THultPriceItem read FBaseItem write FBaseItem;
    property Volume : integer read FVolume;
    property AvgPrice : double read FAvgPrice;
    property EntryOTE : double read FEntryOTE;
    property EntryPL : double read FEntryPL;
    property PL : double read GetPL;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property MaxPL : double read FMaxPL;
    property MinPL : double read FMinPL;
  end;


  TVirtualHult = class
  private
    FSymbol : TSymbol;

    FHultPrices : THultPrices;
    FReady : boolean;
    FFillType : TFillType;
    procedure MakePrice;
    procedure DoInit(aQuote : TQuote);
    procedure UpdateQuote(aQuote : TQuote);

    procedure BidFill(aQuote : TQuote);
    Procedure AskFill(aQuote : TQuote);

  public
    constructor Create;
    destructor Destroy; override;

    procedure SetSymbol(aSymbol : TSymbol; iGap : integer);
    procedure SetFillType( aType : TFillType );
    procedure ReSet;
    procedure DoQuote(aQuote : TQuote);
    procedure DoFill;

    function GetPL : double;
    function GetMaxPL : double;
    function GetMinPL : double;
    function GetVolume : integer;


    property HultPrices : THultPrices read FHultPrices;
    property Ready : boolean read FReady;
    property FillType : TFillType read FFillType;
  end;





implementation
uses
  GAppEnv, GleLib, GleConsts;
{ TVirtualHult }

procedure TVirtualHult.AskFill(aQuote: TQuote);
var
  iIndex, iFillCnt : integer;
  aItem : THultPriceItem;
  dPrice : double;
begin
  iIndex := FHultPrices.BaseItem.PriceIndex;

  if FFillType = ftCurrent then
    dPrice := aQuote.Last
  else
    dPrice := aQuote.Bids[0].Price;

  iFillCnt := 0;
  while true do
  begin
    iIndex := iIndex + FHultPrices.FGap;
    aItem := FHultPrices.GetPriceItem(iIndex);
    if aItem = nil then break;

    if aItem.FPrice <= dPrice + PRICE_EPSILON then   //체결...
    begin
      inc(iFillCnt);
    end else
      break;
  end;

  if iFillCnt = 0 then exit;

  FHultPrices.FillUpdate(aQuote, iFillCnt, -1);
end;

procedure TVirtualHult.BidFill(aQuote: TQuote);
var
  iIndex, iFillCnt : integer;
  aItem : THultPriceItem;
  dPrice : double;
begin
  iIndex := FHultPrices.BaseItem.PriceIndex;


  if FFillType = ftCurrent then
    dPrice := aQuote.Last
  else
    dPrice := aQuote.Asks[0].Price;
  iFillCnt := 0;
  while true do
  begin
    iIndex := iIndex - FHultPrices.FGap;
    aItem := FHultPrices.GetPriceItem(iIndex);
    if aItem = nil then break;

    if aItem.FPrice + PRICE_EPSILON >= dPrice then   //체결...
    begin
      inc(iFillCnt);
    end else
      break;
  end;

  if iFillCnt = 0 then exit;
  FHultPrices.FillUpdate(aQuote, iFillCnt, 1);
end;

constructor TVirtualHult.Create;
begin
  FHultPrices := THultPrices.Create;
  FFillType := ftCurrent;
end;

destructor TVirtualHult.Destroy;
begin
  FHultPrices.Free;

  inherited;
end;

procedure TVirtualHult.DoFill;
begin

end;

procedure TVirtualHult.DoInit(aQuote : TQuote);
var
  dPrice : double;
  stPrice, stLog : string;
  aItem : THultPriceItem;
  i, iGap, BidCnt, AskCnt : Integer;
begin
if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;

  if aQuote.FTicks.Count <= 0 then exit;


  stPrice := Format('%.*n', [FSymbol.Spec.Precision, aQuote.Last]);
  FHultPrices.BaseItem := FHultPrices.Find(stPrice);

  if FHultPrices.BaseItem = nil then exit;


  BidCnt := 0;
  AskCnt := 0;
  //매도 주문 셋팅
  for i := FHultPrices.BaseItem.PriceIndex + 1 to FHultPrices.Count - 1 do
  begin
    aItem := FHultPrices.Items[i] as THultPriceItem;
    iGap := aItem.PriceIndex - FHultPrices.BaseItem.PriceIndex;

    if iGap Mod FHultPrices.Gap = 0 then
    begin
      aItem.Side := -1;
      aItem.Qty := 1;
      inc(AskCnt);
    end;
    stLog := Format('매도 Price = %.2f, Side = %d, Qty = %d', [aItem.Price, aItem.Side, aItem.Qty]);
    gEnv.EnvLog(WIN_YH, stLog);
  end;


    //매수 주문 셋팅
  for i := FHultPrices.BaseItem.PriceIndex - 1 downto 0 do
  begin
    aItem := FHultPrices.Items[i] as THultPriceItem;
    iGap := FHultPrices.BaseItem.PriceIndex - aItem.PriceIndex;

    if iGap Mod FHultPrices.Gap = 0 then
    begin
      aItem.Side := 1;
      aItem.Qty := 1;
      inc(BidCnt);
    end;
    stLog := Format('매수 Price = %.2f, Side = %d, Qty = %d', [aItem.Price, aItem.Side, aItem.Qty]);
    gEnv.EnvLog(WIN_YH, stLog);
  end;

  if (AskCnt > 0) and (BidCnt > 0) then
  begin
    FReady := true;
  end;
  stLog := Format('Doinit Gap = %d, AskCnt = %d, BidCnt = %d', [FHultPrices.Gap, AskCnt, BidCnt]);
  gEnv.EnvLog(WIN_YH, stLog);

end;

procedure TVirtualHult.DoQuote(aQuote: TQuote);
begin
  if FSymbol = nil then exit;
  if aQuote.Symbol <> FSymbol then exit;
  if aQuote.FTicks.Count <= 0 then exit;



  if FReady then
    UpdateQuote(aQuote)
  else
    DoInit(aQuote);
end;

function TVirtualHult.GetMaxPL: double;
begin
  Result := FHultPrices.MaxPL;
end;

function TVirtualHult.GetMinPL: double;
begin
  Result := FHultPrices.MinPL;
end;

function TVirtualHult.GetPL: double;
begin
  Result := FHultPrices.PL;
end;

function TVirtualHult.GetVolume: integer;
begin
  Result := FHultPrices.Volume;
end;

procedure TVirtualHult.MakePrice;
var
  dPrice : double;
  i : integer;
begin
  FHultPrices.Clear;

  dPrice := FSymbol.LimitLow;
  i := 0;
  while True do
  begin
      // add a step
    with FHultPrices.New( dPrice, 0, 0, i ) do
    begin
      dPrice := TicksFromPrice(FSymbol, dPrice, 1);
    end;
    inc(i);
    if dPrice > FSymbol.LimitHigh + PRICE_EPSILON then Break;
  end;
end;

procedure TVirtualHult.ReSet;
begin
  FReady := false;
  FHultPrices.Reset;
end;

procedure TVirtualHult.SetFillType(aType: TFillType);
begin
  FFillType := aType;
end;

procedure TVirtualHult.SetSymbol(aSymbol: TSymbol; iGap : integer);
begin
  FSymbol := aSymbol;
  FHultPrices.Gap := iGap;
  FHultPrices.Symbol := aSymbol;
  MakePrice;
end;

procedure TVirtualHult.UpdateQuote(aQuote: TQuote);
begin
  if FHultPrices.BaseItem = nil then exit;

  FHultPrices.UpdateOTE(aQuote);

  if aQuote.Last > FHultPrices.BaseItem.Price then        //매도 주문체크....
    AskFill(aQuote)
  else if aQuote.Last < FHultPrices.BaseItem.Price then   //매수 주문 체크
    BidFill(aQuote);
end;

{ THultPrices }

procedure THultPrices.CalPL(aQuote: TQuote; dFill: double; iSide, iFillQty: integer);
var
  iNewQty : integer;
begin

  iNewQty := FVolume + iFillQty;   

  if FVolume = 0 then
  begin
    FAvgPrice  := dFill;
  end else
  begin
    if FVolume * iNewQty < 0 then                 //잔고 방향이 바뀔때
    begin
      // P&L
      if FSymbol.Spec <> nil then
        FEntryPL := FEntryPL + (dFill - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;
      // new start
      FAvgPrice  := dFill;
    end else if iNewQty = 0 then                  // 잔고 = 0
    begin
      // P&L
      if FSymbol.Spec <> nil then
        FEntryPL := FEntryPL
                  + (dFill - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;

      FAvgPrice := 0.0;
    end else if Abs(iNewQty) > Abs(FVolume) then   // 잔고 증가
    begin
      FAvgPrice := (FAvgPrice * FVolume + dFill * iFillQty) / iNewQty;
    end else                                       // 잔고 감소
    begin
      // P&L
      if FSymbol.Spec <> nil then
        FEntryPL := FEntryPL  + (dFill - FAvgPrice) * -iFillQty * FSymbol.Spec.PointValue;
    end;
  end;

  FVolume := iNewQty;
  UpdateOTE(aQuote);
end;

constructor THultPrices.Create;
begin
  inherited Create(THultPriceItem);
end;

destructor THultPrices.Destroy;
begin

  inherited;
end;

procedure THultPrices.FillUpdate(aQuote : TQuote; iCnt, iSide : integer);
var
  i : integer;
  aItem : THultPriceItem;
  stLog : string;
begin
  if iSide = -1 then
  begin
    for i := 1 to iCnt do
    begin
      aItem := GetPriceItem(FBaseItem.PriceIndex + (i * FGap));        //매도주문 지우기
      if aItem = nil then exit;
      aItem.Side := 0;
      aItem.Qty := 0;
      //손익 계산 추가해야됨....
      CalPL(aQuote, aItem.FPrice , iSide, -1);
    end;

    FBaseItem := GetPriceItem(FBaseItem.PriceIndex + (iCnt * FGap));
    for i := iCnt downto 1 do                                           //매수주문 채우기
    begin
      aItem := GetPriceItem(FBaseItem.PriceIndex - (i * FGap));
      if aItem = nil then exit;
      aItem.Side := 1;
      aItem.Qty := 1;
    end;
  end else if iSide = 1 then
  begin
    for i := 1 to iCnt do
    begin
      aItem := GetPriceItem(FBaseItem.PriceIndex - (i * FGap));         //매수주문 지우기
      if aItem = nil then exit;
      aItem.Side := 0;
      aItem.Qty := 0;
      //손익 계산 추가해야됨....
     {
      stLog := Format('매수주문 지우기 %.2f, Side = %d, Qty = %d', [aItem.Price, aItem.Side, aITem.Qty]);
      gEnv.EnvLog(WIN_YH, stLog);
                                  }
      CalPL(aQuote, aItem.FPrice , iSide, 1);
    end;

    FBaseItem := GetPriceItem(FBaseItem.PriceIndex - (iCnt * FGap));
    for i := iCnt downto 1 do                                           // 매도주문 채우기
    begin
      aItem := GetPriceItem(FBaseItem.PriceIndex + (i * FGap));
      if aItem = nil then exit;
      aItem.Side := -1;
      aItem.Qty := 1;
      {
      stLog := Format('매도주문 채우기 %.2f, Side = %d, Qty = %d', [aItem.Price, aItem.Side, aITem.Qty]);
      gEnv.EnvLog(WIN_YH, stLog);   }
    end;
  end;
end;

function THultPrices.Find(stPrice: string): THultPriceItem;
var
  i: Integer;
  aItem : THultPriceItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as THultPriceItem;
    if stPrice = aItem.PriceStr then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function THultPrices.GetPL: double;
begin
  Result := FEntryPL + FEntryOTE;
end;

function THultPrices.GetPriceItem(iIndex: integer): THultPriceItem;
begin
  Result := nil;
  if (iIndex < 0) or (Count <= iIndex) then exit;
  Result := Items[iIndex] as THultPriceItem;

end;

function THultPrices.New(dPrice: double; iSide, iQty,
  iIndex: integer): THultPriceItem;
begin
  Result := Add as THultPriceItem;
  Result.FSide := iSide;
  Result.FQty := iQty;
  Result.FPriceIndex := iIndex;
  Result.FPrice := dPrice;
  Result.PriceStr := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
end;

procedure THultPrices.Reset;
begin
  FBaseItem := nil;
  FSymbol := nil;
  FAvgPrice := 0;
  FVolume := 0;
  FEntryPL := 0;
  FEntryOTE := 0;
  FPL := 0;
  FMaxPL := 0;
  FMinPL := 0;
  Clear;
end;

procedure THultPrices.UpdateOTE(aQuote: TQuote);
begin
  FEntryOTE := FVolume * (aQuote.Last - FAvgPrice) * FSymbol.Spec.PointValue;
  FMaxPL := Max(FMaxPL, PL);
  FMinPL := Min(FMinPL, PL);
end;

end.
