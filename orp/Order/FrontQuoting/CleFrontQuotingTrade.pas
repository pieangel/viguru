unit CleFrontQuotingTrade;

interface

uses
  Classes, SysUtils, CleAccounts, CleSymbols, CleOrders, GAppEnv, GleTypes,
  CleVolStopManager

  ;

const
  BID = 0;
  ASK = 1;
  BID_COLOR = $E4E2FC;
  ASK_COLOR = $F5E2DA;

type
  TDataType = (dtBid, dtAsk);
  TQuoteOderSet = class(TCollectionItem)
    private
      FTotCnt : integer;
      FOrderTime : string;
      FPrice : double;
      FQty : integer;
      FGrade : integer;
      FSide : integer;
      FSymbolCode : string;
    public
      property TotCnt : integer read FTotCnt write FTotCnt;
      property OrderTime : string read FOrderTime write FOrderTime;
      property dPrice : double read FPrice write FPrice;
      property iQty : integer read FQty write FQty;
      property iGrade : integer read FGrade write FGrade;
      property iSide : integer read FSide write FSide;
      property SymbolCode : string read FSymbolCode write FSymbolCode;
  end;

  TQuoteOderSets = class(TCollection)
    private
      FAccount : TAccount;
      FSymbol : TSymbol;
      FGrade : integer;
      FHoga : integer;
      FOrdQty : integer;
      FOrdBidCnt : integer;
      FOrdAskCnt : integer;
      FTotOrdCnt : integer;
      FSide : integer;
      FFront : boolean;
      FOrdFull : boolean;
      FTimeUse : boolean;
      FStartTime : string;
      FRun : boolean;
      FDataType : TDataType;
      FVolStop : boolean;
      FVolStopOR : boolean;
      FVolStopIsQty : boolean;
      FVolStopQty : integer;
      FVolStopIsFill : boolean;
      FVolStopFill : integer;
      FPot : TJackPotItems;
      function GetOrder(i: Integer): TQuoteOderSet;
    public
      constructor Create;
      destructor Destroy; override;
      function New(dPrice: double; iQty, iGrade, iSide: integer; stCode : string): TQuoteOderSet;
      property QuoterOrd[i: Integer]: TQuoteOderSet read GetOrder;
      function SendOrder(dPrice : double; iQty, iGrade : integer): boolean;
      procedure SendVolStop( dPrice : double; iSide : integer );
      property Account : TAccount read FAccount write FAccount;
      property Symbol : TSymbol read FSymbol write FSymbol;
      property iGrade : integer read FGrade write FGrade;
      property iHoga : integer read FHoga write FHoga;
      property iOrdQty : integer read FOrdQty write FOrdQty;
      property iOrdBidCnt : integer read FOrdBidCnt write FOrdBidCnt;
      property iOrdAskCnt : integer read FOrdAskCnt write FOrdAskCnt;
      property iTotOrdCnt : integer read FTotOrdCnt write FTotOrdCnt;
      property iSide : integer read FSide write FSide;
      property bFront : boolean read FFront write FFront;
      property bOrdFull : boolean read FOrdFull write FOrdFull;
      property bTimeUse : boolean read FTimeUse write FTimeUse;
      property bRun : boolean read FRun write FRun;
      property stStartTime : string read FStartTime write FStartTime;
      property DataType : TDataType read FDataType write FDataType;
      property VolStop : boolean read FVolStop write FVolStop;
      property VolStopOR : boolean read FVolStopOR write FVolStopOR;
      property VolStopIsQty : boolean read FVolStopIsQty write FVolStopIsQty;
      property VolStopQty : integer read FVolStopQty write FVolStopQty;
      property VolStopIsFill : boolean read FVolStopIsFill write FVolStopIsFill;
      property VolStopFill : integer read FVolStopFill write FVolStopFill;
      property Pot : TJackPotItems read FPot write FPot;
      function CheckHogaQty(iQty : integer; dPrice : Double; iLS : integer; bFillOrd: boolean) : boolean;
  end;


implementation

{ TQuoteOderSet }

constructor TQuoteOderSets.Create;
begin
  inherited Create(TQuoteOderSet);
  FAccount := nil;
  FSymbol := nil;
  FGrade := 0;
  FHoga := 0;
  FOrdQty := 0;
  FOrdBidCnt := 0;
  FOrdAskCnt := 0;
  FTotOrdCnt := 0;
  FSide := 0;
  FRun := false;
  FFront := false;
  FOrdFull := false;
  FTimeUse := false;
  FPot := nil;
end;

destructor TQuoteOderSets.Destroy;
begin
  FAccount := nil;
  FSymbol := nil;

  inherited;
end;

function TQuoteOderSets.GetOrder(i: Integer): TQuoteOderSet;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TQuoteOderSet
  else
    Result := nil;
end;

function TQuoteOderSets.New(dPrice: double; iQty, iGrade, iSide: integer; stCode : string): TQuoteOderSet;
begin
  Result := Add as TQuoteOderSet;
  inc( FTotOrdCnt );
  Result.FTotCnt := FTotOrdCnt;
  Result.FOrderTime := FormatDateTime('hh:mm:ss.zzz', now);
  Result.FPrice := dPrice;
  Result.FQty := iQty;
  Result.FGrade := iGrade;
  Result.FSide := iSide;
  Result.FSymbolCode := stCode;
end;

function TQuoteOderSets.CheckHogaQty(iQty: integer;dPrice : Double; iLS : integer; bFillOrd: boolean): boolean;
var
  i, iTotQty : integer;
  aOrder : TOrder;
  bOrder : boolean;
  stPrice , stOrdPrice : string;

begin
  Result := false;

  if (iLS = 1) and (FOrdBidCnt = 0) then exit;
  if (iLS = -1) and (FOrdAskCnt = 0) then exit;


  iTotQty := 0;
  bOrder := true;

  if bFillOrd then                                         //주문채우기 체크시
  begin
    for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do   //미체결주문 체크
    begin
      aOrder := TOrder(gEnv.Engine.TradeCore.Orders.ActiveOrders.Items[i]);

      stPrice :=  Format('%2f', [dPrice]);
      stOrdPrice := Format('%2f', [aOrder.Price]);
      if (iLS = 1) and (aOrder.Side = 1) then             //매수주문체크
      begin
        if stPrice = stOrdPrice then
          iTotQty := iTotQty + aOrder.OrderQty;
      end;


      if (iLS = -1) and (aOrder.Side = -1) then            //매도주문체크
      begin
        if stPrice = stOrdPrice then
          iTotQty := iTotQty + aOrder.OrderQty;
      end;
    end;

    for i := 0 to gEnv.Engine.TradeCore.Orders.NewOrders.Count - 1 do      // 보낸주문 체크
    begin
      aOrder := TOrder(gEnv.Engine.TradeCore.Orders.NewOrders.Items[i]);

      stPrice :=  Format('%2f', [dPrice]);
      stOrdPrice := Format('%2f', [aOrder.Price]);
      if (iLS = 1) and (aOrder.Side = 1) then             //매수주문체크
      begin
        if stPrice = stOrdPrice then
          iTotQty := iTotQty + aOrder.OrderQty;
      end;

      if (iLS = -1)and (aOrder.Side = -1) then            //매도주문체크
      begin
        if stPrice = stOrdPrice then
          iTotQty := iTotQty + aOrder.OrderQty;
      end;
    end;

    if iTotQty >= FOrdQty then
      bOrder := false;

    if iTotQty < FOrdQty then
    begin
      FOrdQty := FOrdQty - iTotQty;
      bOrder := true;
    end;


  end else                                                //주문채우기 체크 안햇을때
  begin
    for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do    //미체결 주문 체크
    begin
      aOrder := TOrder(gEnv.Engine.TradeCore.Orders.ActiveOrders.Items[i]);

      stPrice :=  Format('%2f', [dPrice]);
      stOrdPrice := Format('%2f', [aOrder.Price]);
      if (iLS = 1) and (aOrder.Side = 1) then             //매수주문체크
      begin
        if stPrice = stOrdPrice then
        begin
          bOrder := false;
          break;
        end;
      end;

      if (iLS = -1)and (aOrder.Side = -1) then            //매도주문체크
      begin
        if stPrice = stOrdPrice then
        begin
          bOrder := false;
          break;
        end;
      end;
    end;


    for i := 0 to gEnv.Engine.TradeCore.Orders.NewOrders.Count - 1 do         // 보낸주문체크
    begin
      aOrder := TOrder(gEnv.Engine.TradeCore.Orders.NewOrders.Items[i]);

      stPrice :=  Format('%2f', [dPrice]);
      stOrdPrice := Format('%2f', [aOrder.Price]);
      if (iLS = 1) and (aOrder.Side = 1) then             //매수주문체크
      begin
        if stPrice = stOrdPrice then
        begin
          bOrder := false;
          break;
        end;
      end;

      if (iLS = -1)and (aOrder.Side = -1) then            //매도주문체크
      begin
        if stPrice = stOrdPrice then
        begin
          bOrder := false;
          break;
        end;
      end;
    end;


  end;


  if (iQty < FHoga) and (bOrder) then
    Result := true;

end;

function TQuoteOderSets.SendOrder(dPrice : double; iQty, iGrade : integer) : boolean;
var
  aTicket: TOrderTicket;
  pcValue: TPriceControl;
  tmValue: TTimeToMarket;
  iRet : integer;
  aOrder : TOrder;
begin
  Result := false;
  if FAccount = nil then exit;
  if FSymbol = nil then exit;

  if dPrice <= 0 then exit;

  pcValue := pcLimit;
  tmValue := tmGTC;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, FSymbol,
     FSide * FOrdQty, pcValue, dPrice, tmValue, aTicket);
  aOrder.OrderSpecies := opFrontQt;

  if aOrder <> nil then
  begin
    iRet := gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.Engine.TradeCore.Orders.DoNotify( aOrder );
    SendVolStop( dPrice, FSide );
  end;

  if iRet = 0 then
  begin
    Result := false;
    exit;
  end else
    Result := true;
  if FSide = 1 then
    Dec(FOrdBidCnt)
  else
    Dec(FOrdAskCnt);
  New(dPrice, iQty, iGrade, FSide, aOrder.Symbol.ShortCode);
end;

procedure TQuoteOderSets.SendVolStop(dPrice: double; iSide : integer);
begin
  if (FVolStop) and (FPot <> nil) then
    FPot.OrderBoard.SendStandByOrder( dPrice, FVolStopOR, FVolStopIsQty, FVolStopIsFill,
                                iSide * -1, FVolStopQty, FVolStopFill, FOrdQty );
end;

end.
