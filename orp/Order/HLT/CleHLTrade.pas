unit CleHLTrade;

interface

uses
  Classes, SysUtils, ExtCtrls,
  GleTypes, CleAccounts, CleSymbols, CleOrders, CleQuoteBroker, CleDistributor, CleQuoteTimers,
  ClePositions
  ;


type                                                                                                      
  TParam = record
    Band : double;
    STime : TDateTime;
    ETime : TDateTime;
    LossCut : integer;
    Profit : integer;
    Term : integer;
  end;


  TConfig = record
    Account : TAccount;
    Symbol : TSymbol;
    ClearTime : TDateTime;
    Trend : boolean;
    Param : array[0..5] of TParam;
  end;

  THLInfo = class
  private
    FOrderPrice : double;
    FFillPrice : double;
    FFillQty : integer;
    FSide : integer;
    FLossTick : integer;
    FProfitTick : integer;
    FEntryOTE : double;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CalEntryOTE;
    property FillPrice : double read FFillPrice;
    property FillQty : integer read FFillQty;
    property Side : integer read FSide;
    property LossTick : integer read FLossTick;
    property ProfitTick : integer read FProfitTick;
    property EntryOTE : double read FEntryOTE;

  end;


  THLTradeItem = class(TCollectionItem)
  private
    FName : string;
    FStart : boolean;
    FBand : double;
    FSTime : TDateTime;
    FETime : TDateTime;
    FLossCut : integer;
    FProfit : integer;
    FEntryOrd : boolean;
    FClearOrd : boolean;
    FQty : integer;
    FInfo: THLInfo;
    FOrder : TOrder;
    FTimer : TQuoteTimer;
    procedure SendOrder( iQty, iSide : integer;  dPrice : double; bClear : boolean );
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    procedure CheckOrder( aQuote : TQuote );
    procedure CalInfo( aQuote : TQuote );
    procedure SetInfo(aOrder : TOrder);
    procedure CheckTimer;
    procedure ClearOrder(aQuote : TQuote; bAll : boolean);
    procedure OnTimer(Sender : TObject);
    property Name : string read FName write FName;
    property Start : boolean read FStart write FStart;
    property Band : double read FBand write FBand;
    property STime : TDateTime read FSTime write FSTime;
    property ETime : TDateTime read FETime write FETime;
    property LossCut : integer read FLossCut write FLossCut;
    property Profit : integer read FProfit write FProfit;
    property EntryOrd : boolean read FEntryOrd;
    property ClearOrd : boolean read FClearOrd;
    property Qty : integer read FQty;
    property Info : THLInfo read FInfo write FInfo;
  end;

  THLTrades = class(TCollection)
  private
    FQuote : TQuote;
    FOnResult : TResultNotifyEvent;
    FPosition : TPosition;
    procedure DoQuote;
    procedure DoTrade(aOrder : TOrder);
    procedure DoLog;
    
  public
    Config : TConfig;
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure SubScribe(aSymbol : TSymbol);
    procedure SetStart(stName : string; bStart : boolean);
    procedure ClearOrder;
    procedure OnQuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OnTradeProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    function GetIsStart : boolean;
    function GetIsParam(stName : string) : boolean;
    function Find(stName : string) : THLTradeItem; overload;
    function Find(aOrder : TOrder) : THLTradeItem; overload;
    function New(stName : string; iQty : integer; aParam : TParam) : THLTradeItem;
    function Update(stName : string; iQty : integer; aParam : TParam) : THLTradeItem;
    property OnResult : TResultNotifyEvent read FOnResult write FOnResult;
    property Position : TPosition read FPosition write FPosition;
  end;
implementation

uses
  GAppEnv, GleConsts, GleLib;


{ THLTrades }

procedure THLTrades.DoLog;
var
  stLog, stFile : string;
begin

  if FPosition = nil then
    stLog := Format('%s, 0',
                  [FormatDateTime('yyyy-mm-dd', GetQuoteTime)
                     ] )
  else
    stLog := Format('%s, %.0f',
                  [FormatDateTime('yyyy-mm-dd', GetQuoteTime),
                    (Position.LastPL - Position.GetFee)/1000 ] );
  stFile := Format('HLT_%s.csv', [Config.Account.Code]);
  gEnv.EnvLog(WIN_HL, stLog, true, stFile);
end;

procedure THLTrades.DoQuote;
var
  i : integer;
  aItem : THLTradeItem;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as THLTradeItem;
    aItem.CheckTimer;
    aItem.CalInfo(FQuote);
    aItem.ClearOrder(FQuote, false);
  end;
end;

procedure THLTrades.DoTrade(aOrder : TOrder);
var
  i: Integer;
  aItem : THLTradeItem;
begin
  aItem := Find(aOrder);
  if aItem = nil then exit;
  aItem.SetInfo(aOrder);
end;

function THLTrades.Find(aOrder: TOrder): THLTradeItem;
var
  i : integer;
  aItem : THLTradeItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as THLTradeItem;
    if aItem.FOrder = aOrder then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

procedure THLTrades.ClearOrder;
var
  i : integer;
  aItem : THLTradeItem;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as THLTradeItem;
    aItem.ClearOrder(FQuote, true);
  end;
end;

constructor THLTrades.Create;
begin
  inherited Create(THLTradeItem);
  Config.Symbol := nil;
  Config.Account := nil;
  gEnv.Engine.TradeBroker.Subscribe(self, OnTradeProc);
end;

destructor THLTrades.Destroy;
begin
  gEnv.Engine.QuoteBroker.Cancel(self, Config.Symbol);
  gEnv.Engine.TradeBroker.Unsubscribe(self);
  inherited;
end;

function THLTrades.Find(stName: string): THLTradeItem;
var
  i : integer;
  aItem : THLTradeItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as THLTradeItem;
    if aItem.FName = stName then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function THLTrades.GetIsParam(stName : string): boolean;
var
  i : integer;
  aItem : THLTradeItem;
begin
  Result := true;

  aItem := Find(stName);
  if aItem = nil then                   // 전체검색
  begin
    for i := 0 to Count - 1 do
    begin
      aItem := Items[i] as THLTradeItem;
      if (aItem.Band = 0) or (Config.Symbol.DayOpen = 0) then
      begin
        Result := false;
        break;
      end;
    end;
  end else                             //해당 Band에 대해서만..
  begin
    if (aItem.Band = 0) or (Config.Symbol.DayOpen = 0) then
      Result := false;
  end;
end;

function THLTrades.GetIsStart: boolean;
var
  i : integer;
  aItem : THLTradeItem;
begin
  Result := false;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as THLTradeItem;
    if aItem.Start then
    begin
      Result := true;
      break;
    end;
  end;
end;

function THLTrades.New(stName: string; iQty: integer; aParam : TParam): THLTradeItem;
begin
  Result := Add as THLTradeItem;
  Result.FName := stName;
  Result.FBand := aParam.Band;
  Result.FSTime := aParam.STime;
  Result.FETime := aParam.ETime;
  Result.FLossCut := aParam.LossCut;
  Result.FProfit := aParam.Profit;
  Result.FTimer.Interval := aParam.Term * 1000 * 60;
  Result.FQty := iQty;
end;

procedure THLTrades.OnQuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  aQuote: TQuote;
begin
  if DataID = 300 then
  begin
    DoLog;
    exit;
  end;

  if DataObj = nil then Exit;
  aQuote := DataObj as TQuote;

  if FQuote <> aQuote then exit;
    DoQuote;
  // 장종료전 전체 청산
  if Frac(Config.ClearTime) <= Frac(GetQuoteTime) then
    ClearOrder;

  if Assigned(OnResult) then
    OnResult(aQuote, false);
end;

procedure THLTrades.OnTradeProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
  aOrder : TOrder;
  aPos : TPosition;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;
  if DataObj = nil then exit;
  case Integer(EventID) of
    ORDER_FILLED:
    begin
      aOrder := DataObj as TOrder;
      if aOrder.OrderSpecies <> opHLT then exit;
      DoTrade(aOrder);
    end;

    POSITION_NEW,
    POSITION_UPDATE :
    begin
      aPos := DataObj as TPosition;
      if aPos.Account = Config.Account then
        FPosition := aPos;
    end;
  end;

end;

procedure THLTrades.Reset;
begin
  Clear;
end;

procedure THLTrades.SetStart(stName: string; bStart: boolean);
var
  i : integer;
  aItem : THLTradeItem;
begin
  aItem := Find(stName);
  if aItem = nil then exit;
  aItem.FStart := bStart;
end;

procedure THLTrades.SubScribe(aSymbol: TSymbol);
begin
  if aSymbol <> nil then
  begin
    if Config.Symbol <> aSymbol then
      gEnv.Engine.QuoteBroker.Cancel(self, Config.Symbol);
    FQuote := gEnv.Engine.QuoteBroker.Subscribe(self, aSymbol, OnQuoteProc);
  end;
end;

function THLTrades.Update(stName: string; iQty : integer; aParam : TParam): THLTradeItem;
var
  aItem : THLTradeItem;
begin
  aItem := Find(stName);
  if aItem = nil then exit;
  aItem.FBand := aParam.Band;
  aItem.FSTime := aParam.STime;
  aItem.FETime := aParam.ETime;
  aItem.FLossCut := aParam.LossCut;
  aItem.FProfit := aParam.Profit;
  aItem.FTimer.Interval := aParam.Term * 1000 * 60;
  aItem.FQty := iQty;
end;

{ THLTradeItem }

procedure THLTradeItem.CalInfo( aQuote : TQuote );
var
  dGap, dPrice : double;
  stLog : string;

begin
  if FOrder = nil then exit;
  if FInfo.FSide = 0 then exit;
  if FClearOrd then exit;
  if not FStart then exit;

  if FInfo.FSide = 1 then    // 상승이면 이익
  begin
    dPrice := aQuote.Bids[0].Price;
    dGap := dPrice - FInfo.FFillPrice;
  end else                   //하락이면 이익
  begin
    dPrice := aQuote.Asks[0].Price;
    dGap := FInfo.FFillPrice - dPrice;
  end;

  if dGap > 0 then
  begin
    FInfo.FProfitTick := Round( dGap / aQuote.Symbol.Spec.TickSize );
    FInfo.FLossTick := 0;
  end else if dGap < 0 then
  begin
    FInfo.FProfitTick := 0;
    FInfo.FLossTick := abs(Round( dGap / aQuote.Symbol.Spec.TickSize ));
  end else
  begin
    FInfo.FProfitTick := 0;
    FInfo.FLossTick := 0;
  end;

  stLog := Format('CalInof %s, %s, dGap = %.1f, Fill = %.1f, Last = %.1f, ProfitTick = %d, LossTick = %d',
              [aQuote.Symbol.Name, FName, dGap, FInfo.FFillPrice, dPrice, FInfo.FProfitTick, FInfo.FLossTick]);
  //gEnv.EnvLog(WIN_HL, stLog);
end;

procedure THLTradeItem.CheckOrder( aQuote : TQuote );
var
  iSide : integer;
  aSymbol : TSymbol;
  dPrice, dUp, dDown: double;
  stLog : string;
  aConfig : TConfig;
begin
  if aQuote = nil then exit;
  if not FStart then exit;

  aSymbol := aQuote.Symbol;


  dUp := aSymbol.DayOpen + FBand;
  dDown := aSymbol.DayOpen - FBand;
  stLog := Format('CheckOrder %s, %s, %s, 현재가 = %.1f, 상승 = %.1f, 다운 = %.1f',
                [FName, FormatDateTime('hh:nn:ss', GetQuoteTime), aSymbol.Name, aQuote.Last, dUp, dDown ]);
  //gEnv.EnvLog(WIN_HL, stLog);

  aConfig := (Collection as THLTrades).Config;
  if (Frac(GetQuoteTime) > Frac(FSTime)) and  (Frac(GetQuoteTime) < Frac(FETime)) then
  begin
    //진입주문
    if not FEntryOrd then
    begin
      if (aQuote.Last >= aSymbol.DayOpen + FBand) then
      begin
        if aConfig.Trend then                     //추세면 매수
        begin
          dPrice := aQuote.Symbol.LimitHigh;
          iSide := 1;
        end else
        begin
          dPrice := aQuote.Symbol.LimitLow;
          iSide := -1;
        end;
        stLog := Format('EntryOrder %d %s, %s, %.1f >= %.1f',[iSide, aSymbol.Name, FName, aQuote.Last, aSymbol.DayOpen + FBand]);
        gEnv.EnvLog(WIN_HL, stLog);
        SendOrder(FQty, iSide, dPrice, false);
        FEntryOrd := true;
      end else if (aQuote.Last <= aSymbol.DayOpen - FBand) then
      begin
        if aConfig.Trend then                     //추세면 매도
        begin
          dPrice := aQuote.Symbol.LimitLow;
          iSide := -1;
        end else
        begin
          dPrice := aQuote.Symbol.LimitHigh;
          iSide := 1;
        end;


        stLog := Format('EntryOrder %d %s, %s, %.1f <= %.1f',[iSide, aSymbol.Name, FName, aQuote.Last, aSymbol.DayOpen - FBand]);
        gEnv.EnvLog(WIN_HL, stLog);
        SendOrder(FQty, iSide, dPrice, false);
        FEntryOrd := true;
      end;
    end;
  end;
end;

procedure THLTradeItem.CheckTimer;
var
  dtTime : TDateTime;
  stLog : string;
begin
  if FTimer.Enabled then exit;
  dtTime := GetQuoteTime;

  if Frac(FSTime) <= Frac(dtTime) then
  begin
    FTimer.Enabled := true;
    stLog := Format('Timer %s, STime = %s, CTime = %s, Interval %d',
                   [FName, FormatDateTime('hh;nn:ss', FSTime), FormatDateTime('hh;nn:ss', dtTime), FTimer.Interval ]);
    //gEnv.EnvLog(WIN_HL, stLog);
  end;
end;

procedure THLTradeItem.ClearOrder(aQuote : TQuote; bAll : boolean);
var
  iSide : integer;
  dPrice : double;
  stLog : string;
  aSymbol : TSymbol;
begin
  if aQuote = nil then exit;
  //청산주문
  if (not FClearOrd) and FEntryOrd then
  begin
    if FOrder = nil then exit;
    if FInfo.FSide = 0 then exit;

    aSymbol := aQuote.Symbol;
    if FInfo.FSide = 1 then                     //매도청산
    begin
      iSide := -1;
      dPrice := aQuote.Symbol.LimitLow;
    end else                                    //매수청산
    begin
      iSide := 1;
      dPrice := aQuote.Symbol.LimitHigh;
    end;

    if bAll then
    begin
      stLog := Format('버튼&청산시간 ClearOrder %s, %s, %d',[aSymbol.Name, FName, iSide]);
      gEnv.EnvLog(WIN_HL, stLog);
      SendOrder(FInfo.FFillQty, iSide, dPrice, true);
      FClearOrd := true;
    end else
    begin
      if FProfit <= FInfo.FProfitTick then         //이익 청산
      begin
        stLog := Format('이익 ClearOrder %s, %s, %d, %d <= %d',[aSymbol.Name, FName, iSide, FProfit, FInfo.FProfitTick ]);
        gEnv.EnvLog(WIN_HL, stLog);
        SendOrder(FInfo.FFillQty, iSide, dPrice, true);
        FClearOrd := true;
      end else if FLossCut <= FInfo.FLossTick then // 손실 청산
      begin
        stLog := Format('손실 ClearOrder %s, %s, %d, %d <= %d',[aSymbol.Name, FName, iSide, FLossCut, FInfo.FLossTick]);
        gEnv.EnvLog(WIN_HL, stLog);
        SendOrder(FOrder.FilledQty, iSide, dPrice, true);
        FClearOrd := true;
      end;
    end;
  end;
end;

constructor THLTradeItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FInfo := THLInfo.Create;
  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.OnTimer := OnTimer;

  FOrder := nil;
  FEntryOrd := false;
  FClearOrd := false;
end;

destructor THLTradeItem.Destroy;
begin
  FInfo.Free;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer(FTimer);
  inherited;
end;

procedure THLTradeItem.OnTimer(Sender: TObject);
var
  aQuote : TQuote;
begin
  aQuote := (Collection as THLTrades).FQuote;
  CheckOrder(aQuote);
end;

procedure THLTradeItem.SendOrder(iQty, iSide: integer; dPrice: double; bClear: boolean);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
  aAccount : TAccount;
  aSymbol : TSymbol;
begin

  aAccount := (Collection as THLTrades).Config.Account;
  aSymbol := (Collection as THLTrades).Config.Symbol;
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aAccount, aSymbol,
                iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opHLT;
    FOrder := aOrder;
    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'HLT Send Order : %s, %s, %s, %d ',
      [
        aSymbol.Code,
        ifThenStr( iSide > 0 , 'L', 'S'),
        aSymbol.PriceToStr( dPrice ),
        iQty
      ]
      );

    gEnv.EnvLog(WIN_HL , stLog);
    //gEnv.EnvLog( WIN_HL, Format('주문 : %s', [ aOrder.SimpleRepresent ]) , false, aSymbol.Code);
  end;
end;

procedure THLTradeItem.SetInfo(aOrder : TOrder);
begin
  FInfo.FOrderPrice := aOrder.Price;
  FInfo.FFillPrice := aOrder.FilledPrice;
  FInfo.FFillQty := aOrder.FilledQty;
  FInfo.FSide := aOrder.Side;
  FInfo.CalEntryOTE;
end;

{ THLInfo }

procedure THLInfo.CalEntryOTE;
begin
  //EntryOTE := 
end;

constructor THLInfo.Create;
begin
    FOrderPrice := 0;
    FFillPrice := 0;
    FFillQty := 0;
    FSide := 0;
    FLossTick := 0;
    FProfitTick := 0;
    FEntryOTE := 0;
end;

destructor THLInfo.Destroy;
begin

  inherited;
end;

end.
