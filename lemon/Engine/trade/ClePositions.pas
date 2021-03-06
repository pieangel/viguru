unit ClePositions;


// Copyright(C) Eight Pines Technologies, Inc. All Rights Reserved.

// Position Data Storage: It define the POSITION object and storages of it

interface

uses
  Classes, Math, SysUtils,

    // lemon: common
  GleLib,
    // lemon: data
  CleMarketSpecs, CleSymbols, CleAccounts, CleOrders, CleFills,  CleFunds,
    // lemon:
  CleQuoteBroker, GleTypes
    ;

type


  TPositionHis2 = record
    Time  : TDateTime;
    AccountNo : string;
    SymbolCode: string;
    TotPL     : double;   // 총손익
    EvalPL    : double;   // 평간손익
    Fee       : double;   // 수수료
    Etc       : double;   // 기타
  end;


  TPosTraceItem2  = class( TCollectionItem )
  public
    PositionHis : TPositionHis2;
  end;

  TPosTraceItems2  = class( TCollection )
  private
    function GetPosTraceItem(i: integer): TPosTraceItem2;
  public
    LastHis     : TPositionHis2;
    Constructor Create;
    Destructor  Destroy; override;
    function New : TPosTraceItem2;
    property PosTraceItems2[ i : integer] : TPosTraceItem2 read GetPosTraceItem;
  end;

  TPosition = class(TCollectionItem)
  private
      // key
    FAccount: TAccount;
    FSymbol: TSymbol;
      // last status
    FVolume: Integer;       // last(current) volume
    FAvgPrice: Double;      // last(current) average price by entry
    FAvgPriceS: Double;     // last(current) average price by settlement
      // price & date
    FEntryDate: TDateTime;  // entry date
    FPrevVolume: Integer;   // last volume on the previous trading day
    FPrevAvgPrice: Double;  // last average price by entry on the previous trading day
      // P&L
    FEntryPL: Double;  // P&L from purchase and sale = realized P&L from average entry price
    FEntryOTE: Double; // Open trade equity = unrealized P&L from averay entry price
    FDailyPL: Double;  // Daily realized P&L = realized P&L from settlement
    FDailyOTE: Double; // Daily open trade equity = unrealized P&L from settelement
    FProfitChg: Double; //수익률
      // order & fill info
    FFills: TFillList;
    FActiveBuyOrderVolume: Integer;
    FActiveSellOrderVolume: Integer;
      // quote
    FQuote: TQuote;

    FLastPL: Double;
    FPosTrace: TPosTraceItems2;
    FTradeAmt: Double;
    FLastFill: TFill;
    FFee: double;
    //FBidParticipation: double;
    //FAskParticipation: double;

    FBidTradeAmount : double;
    FAskTradeAmount : double;
    FBidTradeAmountMax : double;
    FAskTradeAmountMax : double;
    FMaxPos : integer;
    FMaxLoss : double;
    FLastPL2: Double;

    FLiqQty: integer;
    FHadTrade: boolean;

      //
    procedure UpdateOTE;

    function GetLastPL: Double;
    procedure SetOpenPL(const Value: Double);
    function GetSide: integer;

  public
    AbleQty: array [TPositionType] of integer;
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    procedure AddFill(aFill: TFill);
    procedure DoOrder(iSide, iQty: Integer);
    procedure DoQuote(aQuote: TQuote);
    procedure SetPosition(iQty : integer; dAvgPrice, dEntryPL: Double); overload;
    ///  포지션 복사
    procedure SetPosition(iQty : integer; dAvgPrice : Double); overload;
    procedure CalcVolume( iQty : integer );
    ///
    procedure SetFixedPosition( dFiexed, dFee : double );
    procedure AddPL( dtTime : TDateTime );
    procedure CaclOpePL( dLast : double );

    // 공매도 관련
    function LiquidatableQty: Integer;
    function GetFee : double;

    function Represent: String;
      // key
    property Account: TAccount read FAccount write FAccount;
    property Symbol: TSymbol read FSymbol write FSymbol;
      // last status
    property Volume: Integer read FVolume;
    property Side  : integer read GetSide;
    property AvgPrice: Double read FAvgPrice;
    property AvgPriceS: Double read FAvgPriceS;
      // reference info
    property EntryDate: TDateTime read FEntryDate;
    property PrevVolume: Integer read FPrevVolume write FPrevVolume;
    property PrevAvgPrice: Double read FPrevAvgPrice write FPrevAvgPrice;
      // P&L
    property EntryPL: Double read FEntryPL;
    property EntryOTE: Double read FEntryOTE write SetOpenPL;
    property DailyPL: Double read FDailyPL;
    property DailyOTE: Double read FDailyOTE;
    property ProfitChg: Double read FProfitChg;
    property HadTrade : boolean read FHadTrade;


    property LastPL : Double read GetLastPL write FLastPL;

    property TradeAmt : Double read FTradeAmt write FTradeAmt;
    property Fee      : double read GetFee  write FFee;

      // order & fill info
    property Fills: TFillList read FFills;
    property LastFill: TFill  read FLastFill;
    property ActiveBuyOrderVolume: Integer read FActiveBuyOrderVolume;
    property ActiveSellOrderVolume: Integer read FActiveSellOrderVolume;
    //property BidParticipation : double read FBidParticipation;
    //property AskParticipation : double read FAskParticipation;


    property LiqQty   : integer read FLiqQty  write FLiqQty;

      // quote
    property Quote: TQuote read FQuote write FQuote;

    property PosTrace : TPosTraceItems2 read FPosTrace write FPosTrace;

    property BidTradeAmount : double read FBidTradeAmount;
    property AskTradeAmount : double read FAskTradeAmount;
    property MaxPos : integer read FMaxPos;

    property BidTradeAmountMax : double read FBidTradeAmountMax;
    property AskTradeAmountMax : double read FAskTradeAmountMax;


    procedure Assign( aPosition : TPosition ) ;
    procedure CalcVirtualPL( iNewQty: integer; aFill : TFill );
  end;


  TPositionList = class(TList)
  private
    function GetPosition(i: Integer): TPosition;
  public
    function FindPosition( aAccount : TAccount ) : TPosition; overload;
    function FindPosition(aAccount: TAccount; aSymbol: TSymbol): TPosition; overload;
    function FindPosition(aPosition: TPosition): boolean; overload;
    
    property Positions[i:Integer]: TPosition read GetPosition; default;
  end;

  TPositions = class(TCollection)
  private
    FPosList : TList;
    function GetPosition(i: Integer): TPosition;


  public
    constructor Create;
    destructor Destroy; override;
    function GetLastPosition: string;
    function Find( aSymbol : TSymbol ) : TPosition; overload;
    function Find( aAccount : TAccount ) : TPosition; overload;
    function Find(aAccount: TAccount; aSymbol: TSymbol): TPosition; overload;
    function FindOrNew(aAccount: TAccount; aSymbol: TSymbol): TPosition;
    function New(aAccount: TAccount; aSymbol: TSymbol;
      iVolume: Integer = 0; dAvgPrice: Double = 0.0;
      dtEntry: TDateTime = 0.0): TPosition;

    function New2(aAccount: TAccount; aSymbol: TSymbol;
      iVolume: Integer = 0; dAvgPrice: Double = 0.0;
      dtEntry: TDateTime = 0.0): TPosition;

    procedure UpdatePosition( aQuote : TQuote );
    function GetMarketPl(aAccount : TAccount; var dF, dOpt, dS : double ) : Double;
    function GetSymbolPL( aAccount: TAccount; aSymbol : TSymbol ) : Double;
    function GetPL( aAccount : TAccount ) : double;
    function GetOpenPL( aAccount : TAccount; var iOpen : integer ) : double;
    function GetStrategyPL : double;

    procedure GetMarketTotPl(aAccount: TAccount; var dTot, dOte, dPL : double);
    procedure GetAccountPL( aAccount : TAccount; var dOpen, dFixed, dFee : double );
    function  ReqAbleQty( aPosition : TPosition ) : integer;


    property Positions[i: Integer]: TPosition read GetPosition; default;
    property PosList : TList read FPosList write FPosList;
  end;


  TFundPosition = class( TCollectionItem )
  private
    FFund: TFund;
    FSymbol: TSymbol;
    FPositions: TPositionList;
    FEntryOTE: Double;
    FDailyPL: Double;
    FEntryPL: Double;
    FDailyOTE: Double;
    FFills: TFillList;
    FVolume: integer;
    FAvgPrice: Double;
    FTradeAmt: Double;
    FLastPL: Double;
    FActiveSellOrderVolume: Integer;
    FActiveBuyOrderVolume: Integer;
    FHadTrade: boolean;
    procedure UpdateOTE;
    function GetLastPL: Double;

  public
    constructor Create(aColl: TCollection); override;
    Destructor  Destroy; override;

    property Fund : TFund read FFund write FFund;
    property Symbol : TSymbol read FSymbol write FSymbol;

    property Positions : TPositionList read FPositions;
    property Fills: TFillList read FFills;

    property Volume : integer read FVolume;

    property EntryPL: Double read FEntryPL;
    property EntryOTE: Double read FEntryOTE;
    property AvgPrice: Double read FAvgPrice;
    property TradeAmt : Double read FTradeAmt;
    property HadTrade : boolean read FHadTrade;

    property ActiveBuyOrderVolume: Integer read FActiveBuyOrderVolume;
    property ActiveSellOrderVolume: Integer read FActiveSellOrderVolume;

    property LastPL : Double read GetLastPL write FLastPL;

    procedure AddFill(aFill: TFill);
    procedure RecoveryPos( iVolume : integer; dPrice : double);
    procedure DoOrder(iSide, iQty: Integer);
    function LiquidatableQty: Integer;

  end;

  TFundPositions = class(TCollection)
  private
    function GetFundPosition(i: Integer): TFundPosition;

  public
    constructor Create;
    destructor Destroy; override;

    //function Find(aPos  : TPosition ) : TFundPosition; overload;
    function Find(aFund : TFund; aSymbol: TSymbol): TFundPosition; overload;
    procedure GetFundPL(aFund: TFund; var dOpen, dFixed, dFee: double); overload;
    function  GetFundPL(aFund: TFund) : double; overload;
    procedure UpdatePosition( aQuote : TQuote );
    procedure DeleteFund( aFund : TFund );

    property FundPositions[i: Integer]: TFundPosition read GetFundPosition; default;
    function New(aFund: TFund; aSymbol: TSymbol): TFundPosition;

  end;

implementation

uses GAppEnv, CleFQN, CleQuoteTimers;


{ TPosition }

procedure TPosition.AddPL(dtTime: TDateTime);
var
stTmp : string;
var
  aItem : TPosTraceItem2;
begin

  with PosTrace.LastHis do
  begin
    Time  := dtTime;
    TotPL := LastPL / 1000;
    EvalPL:= 0;
    Fee   := GetFee;
  end;              
end;

procedure TPosition.Assign(aPosition: TPosition);
var
  i : integer;
  aFill, aSrc : TFill;
begin

  FVolume   := aPosition.Volume;
  FAvgPrice:= aPosition.FAvgPrice  ;
  FAvgPriceS:= aPosition.FAvgPriceS  ;

  FEntryDate:= aPosition.FEntryDate  ;
  FPrevVolume:= aPosition.FPrevVolume  ;
  FPrevAvgPrice:= aPosition.FPrevAvgPrice  ;
    // P&L
  FEntryPL:= aPosition.FEntryPL  ;
  FEntryOTE:= aPosition.FEntryOTE  ;
  FDailyPL:= aPosition.FDailyPL  ;
  FDailyOTE:= aPosition.FDailyOTE  ;

  FActiveBuyOrderVolume:= aPosition.FActiveBuyOrderVolume  ;
  FActiveSellOrderVolume:= aPosition.FActiveSellOrderVolume  ;

  FTradeAmt:= aPosition.TradeAmt;
  FFee:=      aPosition.Fee;
  AbleQty[ptLong] := aPosition.AbleQty[ptLong];
  AbleQty[ptShort] := aPosition.AbleQty[ptShort];

  FHadTrade:=aPosition.HadTrade;
    // quote
  FQuote:= aPosition.FQuote  ;
end;

procedure TPosition.CaclOpePL(dLast: double);
var
  dPriceDiff: Double;
begin

    FEntryOTE := FVolume * (dLast - FAvgPrice) * FSymbol.Spec.PointValue;
    FDailyOTE := FVolume * (dLast - FAvgPriceS) * FSymbol.Spec.PointValue;
    if FAvgPrice <> 0 then
    begin
      if FVolume > 0 then
        FProfitChg := ((dLast - FAvgPrice)/(FAvgPrice)) * 100   //수익률 계산
      else
        FProfitChg := ((FAvgPrice - dLast)/(FAvgPrice)) * 100;   //수익률 계산
    end;

end;

procedure TPosition.CalcVirtualPL(iNewQty: integer; aFill : TFill);
var
  idx : TOrderSpecies;
  ivol: integer;
begin
  {

  if FVolume = 0 then   // 새로운 방향으로 잔고..
  begin
    PosKind[aFill.OrderSpecies].AvgPrice := aFill.Price;
    PosKind[aFill.OrderSpecies].Volumes := iNewQty;
  end else  begin

    if PosKind[opSCatch].Volumes <> 0 then
    begin
        // reversal
      if PosKind[opSCatch].Volumes * iNewQty < 0 then    // 반대 방향으로
      begin
        PosKind[opSCatch].AvgPrice := aFill.Price;
      end else
        // covered
      if iNewQty = 0 then     // 상쇄
      begin
        PosKind[opSCatch].AvgPrice := 0;
        PosKind[opSCatch].
        PosKind[opSCatch].Volumes  := 0;
      end else
        // grow in the same direction
      if Abs(iNewQty) > Abs(FVolume) then       // 같은 방향으로   잔고 커질때.
      begin

      end else
      begin                       // 같은 방향으로   잔고 작이질때.

      end;
    end;
  end;

   }


end;

procedure TPosition.CalcVolume(iQty: integer);
begin
  FVolume := FVolume + iQty;
end;

constructor TPosition.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FFills := TFillList.Create;

    // initialize
  FAccount := nil;
  FSymbol := nil;
  FVolume := 0;
  FAvgPrice := 0.0;
  FAvgPriceS := 0.0;
  FEntryDate := 0.0;
  FPrevVolume := 0;
  FPrevAvgPrice := 0;
  FEntryPL := 0.0;
  FEntryOTE := 0.0;
  FProfitChg := 0.0;
  FDailyPL := 0.0;
  FDailyOTE := 0.0;
  FActiveBuyOrderVolume := 0;
  FActiveSellOrderVolume := 0;

  FBidTradeAmount := 0;
  FAskTradeAmount := 0;
  FBidTradeAmountMax := 0;
  FAskTradeAmountMax := 0;
  FMaxLoss := 0;

  FPosTrace:= TPosTraceItems2.Create;
  FLastFill := nil;
  
  FHadTrade   := false;
end;

destructor TPosition.Destroy;
begin
  FFills.Free;
  FPosTrace.Free;
  inherited;
end;

procedure TPosition.AddFill(aFill: TFill);
var
  iNewQty: Integer;
  dtType : TDerivativeType;
  dSellOte, dBuyOte : double;
begin
  if (aFill = nil) or (aFill.Volume = 0) then Exit;

    // add to the list
  FFills.AddFill(aFill);
  FLastFill := aFill;

    // TFill.Volume has SIGN, be cautious
  iNewQty := FVolume + aFill.Volume;


    // brand-new
  if FVolume = 0 then
  begin
    FAvgPrice  := aFill.Price;
    FAvgPriceS := aFill.Price;
  end else
    // reversal
  if FVolume * iNewQty < 0 then
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin

      FEntryPL := FEntryPL
                  + (aFill.Price - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;

      FDailyPL := FDailyPL
                  + (aFill.Price - FAvgPriceS) * FVolume * FSymbol.Spec.PointValue;
    end;
      // new start
    FAvgPrice  := aFill.Price;
    FAvgPriceS := aFill.Price;
  end else
    // covered
  if iNewQty = 0 then
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin
      FEntryPL := FEntryPL
                  + (aFill.Price - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;
      FDailyPL := FDailyPL
                  + (aFill.Price - FAvgPriceS) * FVolume * FSymbol.Spec.PointValue;
    end;

    FAvgPrice := 0.0;
    FAvgPriceS := 0.0;
  end else
    // grow in the same direction
  if Abs(iNewQty) > Abs(FVolume) then
  begin
    FAvgPrice := (FAvgPrice * FVolume + aFill.Price * aFill.Volume) / iNewQty;
    FAvgPriceS := (FAvgPriceS * FVolume + aFill.Price * aFill.Volume) / iNewQty;
  end else
    // reduced
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin
      FEntryPL := FEntryPL
                  + (aFill.Price - FAvgPrice) * -aFill.Volume * FSymbol.Spec.PointValue;
      FDailyPL := FDailyPL
                  + (aFill.Price - FAvgPriceS) * -aFill.Volume * FSymbol.Spec.PointValue;
    end;
  end;

  FVolume := iNewQty;

  TradeAmt := TradeAmt +
      abs(aFill.Volume) * aFill.Price * FSymbol.Spec.PointValue / 1000.0;


  if aFill.Volume > 0 then
    FBidTradeAmount := FBidTradeAmount + (aFill.Price * abs(aFill.Volume) * FSymbol.Spec.PointValue)/1000
  else
    FAskTradeAmount := FAskTradeAmount + (aFill.Price * abs(aFill.Volume) * FSymbol.Spec.PointValue)/1000;


  FMaxPos := max( FMaxPos, abs(FVolume));

  if Symbol.Spec.Market = mtFutures then
    FFee := TradeAmt * gEnv.Fees.FFee
  else if Symbol.Spec.Market = mtOption then
    FFee := TradeAmt * gEnv.Fees.OFee;

  UpdateOTE;
end;

procedure TPosition.DoOrder(iSide, iQty: Integer);
var
  stLog : string;
  aQuote : TQuote;
begin
  if iSide = 1 then
    FActiveBuyOrderVolume := Max(0, FActiveBuyOrderVolume + iQty)
  else
  if iSide = -1 then
    FActiveSellOrderVolume := Max(0, FActiveSellOrderVolume + iQty);
  FHadTrade := true;
end;

function TPosition.Represent: String;
begin
  Result := Format('(%s,%s,%d,%.4n,%d,%.4n)',
                    [FAccount.Code, FSymbol.Code,
                     FPrevVolume, FPrevAvgPrice, FVolume, FAvgPrice]);
  // you could add more debug info
end;

procedure TPosition.SetFixedPosition(dFiexed, dFee: double);
begin

end;

procedure TPosition.SetOpenPL(const Value: Double);
begin
  FEntryOTE := Value;
end;

procedure TPosition.SetPosition(iQty: integer; dAvgPrice: Double);
begin
  FVolume := iQty;
  FAvgPrice := dAvgPrice;
end;

procedure TPosition.SetPosition(iQty : integer; dAvgPrice, dEntryPL: Double);
begin
  FVolume := iQty;
  if dAvgPrice > 0 then
    FAvgPrice := dAvgPrice
  else
    FAvgPrice := 0;
  FEntryPL := dEntryPL;
end;



function TPosition.LiquidatableQty: Integer;
begin
  if FVolume > 0 then
    Result := Max(0, FVolume - FActiveSellOrderVolume)
  else
  if FVolume < 0 then
    Result := - Max(0, Abs(FVolume) - FActiveBuyOrderVolume)
  else
    Result := 0;
end;

procedure TPosition.DoQuote(aQuote: TQuote);
begin
  FQuote  := aQuote;
  UpdateOTE;
end;                        

function TPosition.GetFee: double;
begin
  Result := FFee;
end;

function TPosition.GetLastPL: Double;
begin
  Result := FEntryPL + FEntryOTE;
end;


function TPosition.GetSide: integer;
begin
  if Volume > 0 then
    Result := 1
  else if Volume < 0 then
    Result := -1
  else
    Result := 0;
end;

procedure TPosition.UpdateOTE;
var
  dPriceDiff: Double;
begin
  if (FQuote = nil) then
    FQuote := gEnv.Engine.QuoteBroker.Find( FSymbol.Code);
  if FQuote = nil then
    Exit;
  if (FQuote.EventCount > 0)
     and (FSymbol.Spec <> nil) then
  begin
    FEntryOTE := FVolume * (FQuote.Last - FAvgPrice) * FSymbol.Spec.PointValue;
    FDailyOTE := FVolume * (FQuote.Last - FAvgPriceS) * FSymbol.Spec.PointValue;
    if FAvgPrice <> 0 then
    begin
      if FVolume > 0 then
        FProfitChg := ((FQuote.Last - FAvgPrice)/(FAvgPrice)) * 100   //수익률 계산
      else
        FProfitChg := ((FAvgPrice - FQuote.Last)/(FAvgPrice)) * 100;   //수익률 계산
    end;
  end;


  if FMaxLoss > LastPL then
  begin
    FMaxLoss := LastPL;
    FBidTradeAmountMax := FBidTradeAmount;
    FAskTradeAmountMax := FAskTradeAmount;

    if FVolume > 0 then
      FAskTradeAmountMax := FAskTradeAmountMax + (FSymbol.Last * abs(FVolume) * FSymbol.Spec.PointValue)/1000
    else if FVolume < 0 then
      FBidTradeAmountMax := FBidTradeAmountMax + (FSymbol.Last * abs(FVolume) * FSymbol.Spec.PointValue)/1000;
  end;
end;

{ TPositions }

function TPositions.New2(aAccount: TAccount; aSymbol: TSymbol; iVolume: Integer;
  dAvgPrice: Double; dtEntry: TDateTime): TPosition;
begin
  Result := nil;

  if (aAccount = nil) or (aSymbol = nil) then Exit;

  Result := Find(aAccount, aSymbol);

  if Result = nil then
  begin
    Result := Add as TPosition;
    Result.FAccount := aAccount;
    Result.FSymbol := aSymbol;
  end;

  if iVolume <> 0 then
  begin
    Result.FVolume := iVolume;
    Result.FAvgPrice := dAvgPrice;
    Result.FAvgPriceS := aSymbol.Base;
  end;

end;

function TPositions.ReqAbleQty(aPosition: TPosition): integer;
var
  aInvestPosition : TPosition ;
  aInvest : TInvestor;
  stPrice : string;
begin
  Result := 0;

  aInvest := gEnv.Engine.TradeCore.Investors.Find( aPosition.Account.InvestCode );
  if aInvest = nil then Exit;
  if aInvest.PassWord = '' then Exit;

  aInvestPosition := FindOrNew( aInvest, aPosition.Symbol );

  stPrice := IntToStr( Round( aPosition.Symbol.Last * 100  ));
  gEnv.Engine.SendBroker.RequestAccountAbleQty( aInvest, aPosition.Symbol,  1, 1, stPrice );  // 매수
  gEnv.Engine.SendBroker.RequestAccountAbleQty( aInvest, aPosition.Symbol, -1, 1, stPrice );  // 매도

end;

procedure TPositions.UpdatePosition(aQuote: TQuote);
var
  i: Integer;
  aPosition: TPosition;
begin

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Symbol = aQuote.Symbol ) then
      aPosition.DoQuote( aQuote);
  end;

end;

constructor TPositions.Create;
begin
  inherited Create(TPosition);
  FPosList := TList.Create;
end;

function TPositions.GetPL(aAccount: TAccount): double;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := 0;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if aPosition = nil then
      Continue;

    if (aPosition.Account = aAccount) then
      Result := Result + aPosition.LastPL;
  end;
end;

function TPositions.GetPosition(i: Integer): TPosition;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TPosition
  else
    Result := nil;
end;

function TPositions.GetStrategyPL: double;
var
  i : integer;
  aPos : TPosition;
  dTot : double;
begin
  dTot := 0;
  for i := 0 to Count - 1 do
  begin
    aPos := GetPosition(i);
    dTot := dTot + aPos.EntryOTE + aPos.EntryPL;
  end;
  Result := dTot;
end;

function TPositions.GetSymbolPL(aAccount: TAccount; aSymbol: TSymbol): Double;
var
  i: Integer;
  aPosition: TPosition;
  dS, dF, dOpt, dTot : double;
begin
  dTot := 0;

  dS :=0;
  dF :=0;
  dOpt:=0;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount) and ( aPosition.Symbol = aSymbol ) then
    begin
      case aPosition.Symbol.Spec.Market of
        mtStock, mtBond, mtETF, mtELW : dS  := dS + aPosition.EntryOTE + aPosition.EntryPL;
        mtFutures : dF := dF + aPosition.EntryOTE + aPosition.EntryPL;
        mtOption : dOpt := dOpt + aPosition.EntryOTE + aPosition.EntryPL ;
      end;
      break;
    end;
  end;

  dTot := dS + dOpt + dF ;// dFee;
  Result := dTot;

end;

destructor TPositions.Destroy;
begin
  FPosList.Free;
  inherited;
end;

function TPositions.Find(aAccount: TAccount; aSymbol: TSymbol): TPosition;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := nil;

  if aAccount = nil then Exit;


  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount)
       and (aPosition.Symbol = aSymbol) then
    begin
      Result := aPosition;
      Break;
    end;
  end;
end;

function TPositions.Find(aSymbol: TSymbol): TPosition;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Symbol = aSymbol) then
    begin
      Result := aPosition;
      Break;
    end;
  end;

end;

function TPositions.Find(aAccount: TAccount): TPosition;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount) then
    begin
      Result := aPosition;
      Break;
    end;
  end;


end;

function TPositions.FindOrNew(aAccount: TAccount; aSymbol: TSymbol): TPosition;
begin
  Result := Find(aAccount, aSymbol);
  if Result = nil then
    Result := New(aAccount, aSymbol);
end;

function TPositions.New(aAccount: TAccount; aSymbol: TSymbol;
  iVolume: Integer; dAvgPrice: Double; dtEntry: TDateTime): TPosition;
begin
  Result := nil;

  if (aAccount = nil) or (aSymbol = nil) then Exit;

  Result := Find(aAccount, aSymbol);

  if Result = nil then
  begin
    Result := Add as TPosition;
    Result.FAccount := aAccount;
    Result.FSymbol := aSymbol;


    if iVolume <> 0 then
    begin
      Result.FPrevVolume := iVolume;
      Result.FPrevAvgPrice := dAvgPrice;
      Result.FEntryDate := dtEntry;
      Result.FVolume := iVolume;
      Result.FAvgPrice := dAvgPrice;
      Result.FAvgPriceS := aSymbol.Base;
    end;
  end;
end;

procedure TPositions.GetAccountPL(aAccount: TAccount; var dOpen, dFixed,
  dFee: double);
var
  i: Integer;
  aPosition: TPosition;
begin
  dOpen := 0.0;  dFixed := 0.0;  dFee := 0.0;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount) then
    begin
      dOpen := dOpen + aPosition.EntryOTE ;
      dFixed:= dFixed + aPosition.EntryPL ;
      dFee  := dFee + aPosition.Fee;
    end;
  end;

  dFixed  := dFixed + aAccount.FixedPL;
end;

function TPositions.GetLastPosition : string;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := '';

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if aPosition <> nil then
      Result  := Result + aPosition.Symbol.Code + ':' + IntToStr( aPosition.Volume ) + '  ';
  end;
end;

function TPositions.GetMarketPl(aAccount : TAccount; var dF, dOpt, dS: double): Double;
var
  i: Integer;
  aPosition: TPosition;
  dTot : double;
begin
  dTot := 0;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if aPosition = nil then
      Continue;

    aPosition.AddPL( GetQuoteTime );

    if (aPosition.Account = aAccount) then
    begin
      case aPosition.Symbol.Spec.Market of
        mtStock, mtBond, mtETF, mtELW : dS  := dS + aPosition.EntryOTE + aPosition.EntryPL;
        mtFutures : dF := dF + aPosition.EntryOTE + aPosition.EntryPL;
        mtOption : dOpt := dOpt + aPosition.EntryOTE + aPosition.EntryPL ;
      end;
    end;
  end;

  dTot := dS + dOpt + dF ;// dFee;
  Result := dTot;
end;

procedure TPositions.GetMarketTotPl(aAccount: TAccount; var dTot, dOte,
  dPL : double);
var
  i: Integer;
  aPosition: TPosition;
begin
  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount) then
    begin
     dTot := dTot + aPosition.EntryOTE + aPosition.EntryPL ;
     dOte := dOte + aPosition.EntryOTE;
     dPL := dPL + aPosition.EntryPL;
     //dFee := dFee + aPosition.Fees;
    end;
  end;
end;

function TPositions.GetOpenPL(aAccount: TAccount; var iOpen : integer ): double;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := 0;
  iOpen  := 0;
  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if aPosition = nil then
      Continue;

    if (aPosition.Account = aAccount) then
    begin
      Result := Result + aPosition.EntryOTE;
      inc( iOpen,  aPosition.Volume );
    end;
  end;

end;

{ TPosTraceItems2 }

constructor TPosTraceItems2.Create;
begin
  inherited Create( TPosTraceItem2 );
end;

destructor TPosTraceItems2.Destroy;
begin

  inherited;
end;

function TPosTraceItems2.GetPosTraceItem(i: integer): TPosTraceItem2;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TPosTraceItem2;
end;

function TPosTraceItems2.New: TPosTraceItem2;
begin
  Result := Add as TPosTraceItem2;
end;

{ TPositionList }

function TPositionList.FindPosition(aAccount: TAccount): TPosition;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := nil;

  if aAccount = nil then Exit;


  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount) then
    begin
      Result := aPosition;
      Break;
    end;
  end;

end;

function TPositionList.FindPosition(aAccount: TAccount;
  aSymbol: TSymbol): TPosition;
var
  i: Integer;
  aPosition: TPosition;
begin
  Result := nil;

  if aAccount = nil then Exit;


  for i := 0 to Count - 1 do
  begin
    aPosition := GetPosition(i);
    if (aPosition.Account = aAccount)
       and (aPosition.Symbol = aSymbol) then
    begin
      Result := aPosition;
      Break;
    end;
  end;

end;

function TPositionList.FindPosition(aPosition: TPosition): boolean;
var
  i: Integer;
begin
  Result := false;

  for i := 0 to Count - 1 do
  begin
    if GetPosition(i) = aPosition then
    begin
      Result := true;
      Break;
    end;
  end;              
end;

function TPositionList.GetPosition(i: Integer): TPosition;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TPosition(Items[i])
  else
    Result := nil;
end;

{ TFundPositon }

procedure TFundPosition.AddFill(aFill: TFill);
var
  iNewQty: Integer;
  dtType : TDerivativeType;
  dSellOte, dBuyOte : double;
begin
  if (aFill = nil) or (aFill.Volume = 0) then Exit;
    // add to the list
  FFills.AddFill(aFill);
    // TFill.Volume has SIGN, be cautious
  iNewQty := FVolume + aFill.Volume;               
    // brand-new
  if FVolume = 0 then
  begin
    FAvgPrice  := aFill.Price;
  end else
    // reversal
  if FVolume * iNewQty < 0 then
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin

      FEntryPL := FEntryPL
                  + (aFill.Price - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;

    end;
      // new start
    FAvgPrice  := aFill.Price;

  end else
    // covered
  if iNewQty = 0 then
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin
      FEntryPL := FEntryPL
                  + (aFill.Price - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;
    end;

    FAvgPrice := 0.0;

  end else
    // grow in the same direction
  if Abs(iNewQty) > Abs(FVolume) then
  begin
    FAvgPrice := (FAvgPrice * FVolume + aFill.Price * aFill.Volume) / iNewQty;
  end else
    // reduced
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin
      FEntryPL := FEntryPL
                  + (aFill.Price - FAvgPrice) * -aFill.Volume * FSymbol.Spec.PointValue;
    end;
  end;

  FVolume := iNewQty;

  FTradeAmt := TradeAmt +
      abs(aFill.Volume) * aFill.Price * FSymbol.Spec.PointValue;
  UpdateOTE;
end;

procedure TFundPosition.RecoveryPos(iVolume: integer; dPrice: double);
var
  iNewQty: Integer;
  dtType : TDerivativeType;
  dSellOte, dBuyOte : double;
begin
  if iVolume = 0 then Exit;

    // TFill.Volume has SIGN, be cautious
  iNewQty := FVolume + IVolume;
    // brand-new
  if FVolume = 0 then
  begin
    FAvgPrice  := dPrice;
  end else
    // reversal
  if FVolume * iNewQty < 0 then
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin

      FEntryPL := FEntryPL
                  + (dPrice - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;

    end;
      // new start
    FAvgPrice  := dPrice;

  end else
    // covered
  if iNewQty = 0 then
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin
      FEntryPL := FEntryPL
                  + (dPrice - FAvgPrice) * FVolume * FSymbol.Spec.PointValue;
    end;

    FAvgPrice := 0.0;

  end else
    // grow in the same direction
  if Abs(iNewQty) > Abs(FVolume) then
  begin
    FAvgPrice := (FAvgPrice * FVolume + dPrice * iVolume) / iNewQty;
  end else
    // reduced
  begin
      // P&L
    if FSymbol.Spec <> nil then
    begin
      FEntryPL := FEntryPL
                  + (dPrice - FAvgPrice) * -iVolume * FSymbol.Spec.PointValue;
    end;
  end;

  FVolume := iNewQty;
  FTradeAmt := TradeAmt + abs(iVolume) * dPrice * FSymbol.Spec.PointValue;
  //UpdateOTE;

end;

procedure TFundPosition.DoOrder(iSide, iQty: Integer);
begin
  if iSide = 1 then
    FActiveBuyOrderVolume := Max(0, FActiveBuyOrderVolume + iQty)
  else
  if iSide = -1 then
    FActiveSellOrderVolume := Max(0, FActiveSellOrderVolume + iQty);

  FHadTrade := true;
end;

function TFundPosition.LiquidatableQty: Integer;
var
  iActSell, iActBuy, i : integer;
  aPos : TPosition;
  aItem: TFundItem;
  iVal, iMin2, iMin : integer;
begin

  Result := 0;
  iMin := 10;

  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aItem := FFund.FundItems.FundItem[i];
    iMin  := Min( iMin , aItem.Multiple );
  end;

  iMin2 := 100000;  iVal := 0;
  for I := 0 to FPositions.Count - 1 do
  begin
    aPos  := FPositions.Positions[i];
    if ( ( aPos.Volume mod iMin ) = 0) {and ( aPos.Volume <> 0 )} then
    begin
      iVal  := abs( aPos.Volume );
      if iVal < iMin2 then
      begin
        iMin2    := iVal;
        Result   := aPos.Volume;
      end;
    end;
  end;

end;

constructor TFundPosition.Create( aColl : TCollection );
begin
  inherited Create(aColl);

  FFills := TFillList.Create;
  FPositions := TPositionList.Create;

  FSymbol := nil;
  FVolume := 0;
  FAvgPrice := 0.0;
  FEntryPL := 0.0;
  FEntryOTE := 0.0;

  FDailyPL := 0.0;
  FDailyOTE := 0.0;

  FHadTrade := false;

end;

procedure TFundPosition.UpdateOTE;
var
  aQuote : TQuote;
begin
  if FSymbol.Quote = nil then Exit;

  aQuote  := FSymbol.Quote as TQuote;

  if (aQuote.EventCount > 0)
     and (FSymbol.Spec <> nil) then
    FEntryOTE := FVolume * (aQuote.Last - FAvgPrice) * FSymbol.Spec.PointValue;
end;

destructor TFundPosition.Destroy;
begin
  FFills.Free;
  FPositions.Free;
  inherited;
end;

function TFundPosition.GetLastPL: Double;
begin
  Result := FEntryPL + FEntryOTE;
end;



{ TFundPositions }

constructor TFundPositions.Create;
begin
  inherited Create( TFundPosition );
end;

procedure TFundPositions.DeleteFund(aFund: TFund);
var
  I: Integer;
  aPosition: TFundPosition;
begin
  for I := Count-1 downto 0 do
  begin
    aPosition := GetFundPosition(i);
    if ( aPosition <> nil ) and ( aPosition.FFund = aFund ) then
      Delete(i);
  end;

end;

destructor TFundPositions.Destroy;
begin

  inherited;
end;

procedure TFundPositions.GetFundPL(aFund: TFund; var dOpen, dFixed,
  dFee: double);
var
  i: Integer;
  aPosition: TFundPosition;
  aPos : TPosition;
  j: Integer;
begin
  dOpen := 0.0;  dFixed := 0.0;  dFee := 0.0;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetFundPosition(i);
    if (aPosition.Fund = aFund) then
    begin
      for j := 0 to aPosition.Positions.Count - 1 do
      begin
        aPos  := TPosition( aPosition.Positions.Positions[j] );
        dOpen := dOpen + aPos.EntryOTE ;
        dFixed:= dFixed + aPos.EntryPL ;
      end;
    end;
  end;

  for j := 0 to aFund.FundItems.Count - 1 do
  begin
    dFixed  := dFixed + aFund.FundAccount[j].FixedPL;
    dFee    := dFee + + aFund.FundAccount[j].GetFee;
  end;

end;
                               {
function TFundPositions.Find(aPos: TPosition): TFundPosition;
var
  I, j: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    for j := 0 to GetFundPosition(i).Positions.Count - 1 do
      if GetFundPosition(i).Positions.Positions[j] = aPos then
      begin
        Result := GetFundPosition(i);
        break;
      end;
    if Result <> nil then
      break;
  end;
end;
             }
function TFundPositions.Find(aFund: TFund; aSymbol: TSymbol): TFundPosition;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if ( GetFundPosition(i).Fund = aFund ) and ( GetFundPosition(i).Symbol = aSymbol ) then
    begin
      Result := GetFundPosition(i);
      break;
    end;
end;

function TFundPositions.GetFundPL(aFund: TFund): double;
var
  i: Integer;
  aPosition: TFundPosition;
  aPos : TPosition;
  j: Integer;
begin
  Result := 0.0;

  for i := 0 to Count - 1 do
  begin
    aPosition := GetFundPosition(i);
    if (aPosition.Fund = aFund) then
    begin
      for j := 0 to aPosition.Positions.Count - 1 do
      begin
        aPos  := TPosition( aPosition.Positions.Positions[j] );
        Result  := Result + aPos.LastPL;
      end;
    end;
  end;
end;

function TFundPositions.GetFundPosition(i: Integer): TFundPosition;
begin
  if ( i< 0) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TFundPosition;
end;

procedure TFundPositions.UpdatePosition(aQuote: TQuote);
var
  i: Integer;
  aPosition: TFundPosition;
begin

  for i := 0 to Count - 1 do
  begin
    aPosition := GetFundPosition(i);
    if (aPosition.Symbol = aQuote.Symbol ) then
      aPosition.UpdateOTE;
  end;      

end;

function TFundPositions.New(aFund: TFund; aSymbol: TSymbol): TFundPosition;
begin
  Result := Add as TFundPosition;
  Result.FFund  := aFund;
  Result.Symbol := aSymbol;
end;

end.




