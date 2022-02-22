unit CleStrangle;

interface
uses
  Classes, SysUtils,
  CleSymbols, CleAccounts, CleDistributor, CleQuoteBroker, GleTypes,
  CleOrders, CleMarkets, ClePositions, CleQuoteTimers, CleStrategyStore, CleOrderBeHaivors
  ;

type
  THedgeStatus = (hsNone, hsUp1, hsUp2, hsUp3, hsDown1, hsDown2, hsDown3);
  TBidAskType = (baNone, baCallBid, baCallAsk, baPutBid, baPutAsk);

  TStrangleTrade = class;
  TStrangleParams = record
    Start : boolean;
    OrderQty : integer;
    UpBid : array[0..2] of double;
    UpAsk : array[0..2] of double;
    UseUp : array[0..2] of boolean;
    DownBid : array[0..2] of double;
    DownAsk : array[0..2] of double;
    UseDown : array [0..2] of boolean;

    CalLowEnt, CalHighEnt : boolean;
    PutLowEnt, PutHighEnt : boolean;

    LowOrder : boolean;
    LowPrice : double;
    HighPrice : double;
    UseHedge : boolean;
    LossAmt  : double;
  end;

  TTimeOrder = class(TCollectionItem)
  private
    FSend : boolean;
    FTimeOrder : TDateTime;
    FEnableTag: integer;
  public
    property Send : boolean read FSend write FSend;
    property EnableTag : integer read FEnableTag write FEnableTag;
    property TimeOrder : TDateTime read FTimeOrder;
  end;

  TTimeOrders = class(TCollection)
  private
  public
    constructor Create;
    destructor Destroy; override;
    function AddTime(wH, wM, wS, wMs : Word) : TTimeOrder;
    function NextTime : TTimeOrder;
  end;

  TStrangle = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FPosition : TPosition;
    FLowOrder : Boolean;       // true : ������������, false :������������
  public
    function GetPrice(iSide : integer) : double;
    function DoOrder(iSide, iQty : integer; aAcnt : TAccount) : TOrder;
    property Symbol : TSymbol read FSymbol;
    property Position : TPosition read FPosition;
  end;

  TStrangles = class(TCollection)
  private
    FFut : TSymbol;
    FAccount : TAccount;
    FHedgeStatus : THedgeStatus;
    FParam : TStrangleParams;
    FTimeOrders : TTimeOrders;
    FCurrentTime : TTimeOrder;
    FBidAskCnt : array[0..1] of integer;
    FHedge : array[0..1] of double;
    FBidStart : boolean;
    FScreenNumber : integer;
    FTrade : TStrangleTrade;
    FBeHaivors : TOrerBeHaivors;

    procedure CheckTimeOrder(dEndTime : TDateTime);

    procedure ClearOrder;
    procedure SetHedge(dBid, dAsk : double);
    procedure SetHedgeStatus(iStatus : integer; bHedge, bUp : boolean);
    function GetSide(aType : TBidAskType) : integer;
    function GetCallPut(aType : TBidAskType) : string;
    function GetBidAskTypeDesc( aType : TBidAskType) : string;
    function CheckHedge(aQuote : TQuote; var iMultiple : integer) : TBidAskType;
    function GetHedgeMultiple( aQuote : TQuote; iIndex : integer; bHedge, bUp : boolean ) : integer;
    function SendOrder(aType : TBidAskType; bHedge : boolean; iMultiple : integer = 1) : boolean;
    function CheckLowOrder( aItem : TStrangle; bHedge : boolean) : boolean;
    function CheckEntryOrder(aItem: TStrangle;  cCP : char): boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetOrderTime; overload;
    procedure SetOrderTime( stTime : array of string ) ; overload;
    procedure SetHedgeBidOrder;
    procedure SetLowPrice;
    procedure UpdateTimeOrder( idx, ival : Integer );
    procedure UpdateUseParam( iDiv : integer ; bVal : boolean );
    procedure UpdateCallEntry( iDiv : integer ; bVal : boolean );
    procedure UpdatePutEntry( iDiv : integer ; bVal : boolean );
    procedure UpdateUpHedge( idx : integer; bVal : boolean );
    procedure UpdateDownHedge( idx : integer; bVal : boolean );
    function GetStatusDesc : string;
    function AddSymbol(aPos: TPosition) : TStrangle;
    function GetTimeOrder(iIndex : integer) : TTimeOrder;
    property BidStart : boolean read FBidStart write FBidStart;
    property ScreenNumber : integer read FScreenNumber;
    property Param : TStrangleParams read FParam write FParam;
    property CurrentTime : TTimeOrder read FCurrentTime;
  end;

  TStrangleTrade = class(TStrategyBase)
  private
    FStrangles : TStrangles;
  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;
    procedure SetSymbol;
    procedure SetAccount(aAcnt : TAccount);
    procedure StartStop(aParam : TStrangleParams);
    procedure ClearOrder;
    procedure ReSet;
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    procedure SetStopLossAmt( dAmt : double );
    procedure UpdateTimeOrder( idx, ival : Integer );
    property Strangles : TStrangles read FStrangles;
  end;

implementation

uses
  GAppEnv, GleConsts, GleLib;

{ TStrangles }

function TStrangles.AddSymbol(aPos: TPosition): TStrangle;
begin
  if Count >= 4 then exit;
  Result := Add as TStrangle;
  Result.FSymbol := aPos.Symbol;
  Result.FPosition := aPos;
  Result.FLowOrder := true;
end;

function TStrangles.CheckHedge(aQuote: TQuote; var iMultiple : integer): TBidAskType;
var
  i : integer;
begin
  Result := baNone;
  if (not FParam.Start) then exit;
  if not FParam.UseHedge then exit;
  case  FHedgeStatus of
    hsNone:
    begin
      if (aQuote.Bids.CntTotal * FParam.UpBid[0] > aQuote.Asks.CntTotal) and ( FParam.UseUp[0] ) then             //��� 1�ܰ� �ݸż�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 0, true, true);
        Result := baCallBid;
      end else if (aQuote.Asks.CntTotal * FParam.DownBid[0] > aQuote.Bids.CntTotal) and ( FParam.UseDown[0] ) then  //�Ϲ� 1�ܰ� ǲ�ż�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 0, true, false);
        Result := baPutBid;
      end else
        FHedgeStatus := hsNone;
    end;
    hsUp1:
    begin
      if (aQuote.Bids.CntTotal * FParam.UpBid[1] > aQuote.Asks.CntTotal) and ( FParam.UseUp[1] ) then     //��� 2�ܰ� �ݸż�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 1, true, true);
        Result := baCallBid;
      end else if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[0] then    //��� 1�ܰ� �ݸŵ�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 0, false, true);
        FHedgeStatus := hsNone;
        Result := baCallAsk;
      end;
    end;

    hsUp2:
    begin
      if (aQuote.Bids.CntTotal * FParam.UpBid[2] > aQuote.Asks.CntTotal) and ( FParam.UseUp[2]) then               //��� 3�ܰ� �ݸż�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 2, true, true);
        Result := baCallBid;
      end else if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[1] then      //��� 2�ܰ� �ݸŵ�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 1, false, true);
        Result := baCallAsk;
      end;
    end;
    hsUp3:
    begin
      if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[2] then               //��� 3�ܰ� �ݸŵ�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 2, false, true);
        Result := baCallAsk;
      end;
    end;
    hsDown1:
    begin
      if (aQuote.Asks.CntTotal * FParam.DownBid[1] > aQuote.Bids.CntTotal) and ( FParam.UseDown[1] ) then             //�Ϲ� 2�ܰ� ǲ�ż�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 1, true, false);
        Result := baPutBid;
      end else if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[0] then    //�Ϲ� 1�ܰ� ǲ�ŵ�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 0, false, false);
        FHedgeStatus := hsNone;
        Result := baPutAsk;
      end;
    end;
    hsDown2:
    begin
      if (aQuote.Asks.CntTotal * FParam.DownBid[2] > aQuote.Bids.CntTotal) and ( FParam.UseDown[2]) then             //�Ϲ� 3�ܰ� ǲ�ż�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 2, true, false);
        Result    := baPutBid;
      end else if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[1] then    //�Ϲ� 2�ܰ� ǲ�ŵ�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 1, false, false);
        Result := baPutAsk;
      end;
    end;
    hsDown3:
    begin
      if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[2] then             //�Ϲ� 3�ܰ� ǲ�ŵ�
      begin
        iMultiple := GetHedgeMultiple(aQuote, 2, false, false);
        Result := baPutAsk;
      end;
    end;
  end;

  FBidAskCnt[0] := aQuote.Asks.CntTotal;
  FBidAskCnt[1] := aQuote.Bids.CntTotal;
end;

function TStrangles.CheckLowOrder(aItem: TStrangle; bHedge : boolean): boolean;
begin
  Result := true;
  if (FParam.LowOrder) and (bHedge) then
  begin
    if not aItem.FLowOrder then     //���� ������ �ֹ� ����
      Result := false;
  end;
end;

function TStrangles.CheckEntryOrder(aItem: TStrangle;  cCP : char  ): boolean;
begin
  Result := true;
  case cCP of
    'C' :
      begin
        if (aItem.Symbol as TOption).CallPut = 'C' then
        begin
          if ((not FParam.CalLowEnt) and  ( aItem.FLowOrder )) or
             ((not FParam.CalHighEnt) and ( not aItem.FLowOrder )) then
             Result := false;
        end;
      end;
    'P' :
      begin
        if (aItem.Symbol as TOption).CallPut = 'P' then
        begin
          if ((not FParam.PutLowEnt ) and  ( aItem.FLowOrder )) or
             ((not FParam.PutHighEnt) and ( not aItem.FLowOrder )) then
             Result := false;
        end;
      end;
  end;
end;

procedure TStrangles.CheckTimeOrder( dEndTime : TDateTime);
begin
  SetHedgeBidOrder;
  // �ð� �ֱ� �ֹ�    
  if FCurrentTime <> nil then
  begin
    if Frac(GetQuoteTime) >= FCurrentTime.FTimeOrder then
    begin
      SendOrder(baCallAsk, false);
      SendOrder(baPutAsk, false);
      FCurrentTime.FSend := true;
      FCurrentTime := FTimeOrders.NextTime;
    end;
  end;

  //û���ֹ�
  if Frac(GetQuoteTime) >= dEndTime then
  begin
    ClearOrder;
    FParam.Start := false;
  end;

  // add by seunge 2015.08.26
  if FTrade.TotPL < - FTrade.FStrangles.FParam.LossAmt then
  begin
    ClearOrder;
    if FParam.Start then
      gEnv.EnvLog(WIN_STR, format('�ѵ� ���� : %.0n < %.0n' , [ FTrade.TotPL , -FTrade.FStrangles.FParam.LossAmt   ]) );
    FParam.Start := false;
  end;
end;

procedure TStrangles.ClearOrder;
var
  i, iSide, iQty :integer;
  aItem : TStrangle;
  aOrder : TOrder;
  stLog : string;
begin
  if not FParam.Start then exit;
  
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangle;
    if aItem.Position = nil then continue;


    iQty := abs(aItem.Position.Volume);  
    if iQty = 0 then continue;

    if aItem.Position.Volume > 0 then
      iSide := -1
    else
      iSide := 1;

    aOrder := aItem.DoOrder(iSide, iQty, FAccount);

    if aOrder <> nil then
    begin
      stLog := Format('%s, û��, %s, Qty = %d, Side = %d, Price = %.2f, OrderPrice = %.2f, AskCnt = %d, BidCnt = %d, Hedge = %f, Hedge = %f',
                     [GetStatusDesc, aOrder.Symbol.ShortCode, aOrder.OrderQty,
                     aOrder.Side, aOrder.Symbol.Last, aOrder.Price, FBidAskCnt[0], FBidAskCnt[1], FHedge[0], FHedge[1]]);
      gEnv.EnvLog(WIN_STR, stLog );
    end;
  end;
end;

constructor TStrangles.Create;
begin
  inherited Create(TStrangle);
  FBidStart := false;
  FHedgeStatus := hsNone;
  FParam.Start := false;
  FCurrentTime := nil;
  FTimeOrders := TTimeOrders.Create;
  FBeHaivors := TOrerBeHaivors.Create;
  FFut := gEnv.Engine.SymbolCore.Futures[0];
end;

destructor TStrangles.Destroy;
begin
  FTimeOrders.Free;
  FBeHaivors.Free;
  inherited;
end;

function TStrangles.GetBidAskTypeDesc(aType: TBidAskType): string;
begin
  Result := '';
  case aType of
    baNone: Result := '';
    baCallBid: Result := 'Call Bid';
    baCallAsk: Result := 'Call Ask';
    baPutBid: Result := 'Put Bid';
    baPutAsk: Result := 'Put Ask';
  end;
end;

function TStrangles.GetCallPut(aType: TBidAskType): string;
begin
  Result := '';
  case aType of
    baPutAsk,
    baPutBid : Result := 'P';
    baCallAsk,
    baCallBid: Result := 'C';
  end;
end;

function TStrangles.GetHedgeMultiple(aQuote : TQuote; iIndex: integer; bHedge, bUp: boolean): integer;
var
  i , iMultiple , iStatus : integer;

begin
  iMultiple := 0;
  if bHedge then                                        //�ż��ֹ�
  begin
    if bUp then                                         //Up�̸鼭 ���� �ż��϶�
    begin
      for  i := iIndex to 2 do
      begin
        if (aQuote.Bids.CntTotal * FParam.UpBid[i] > aQuote.Asks.CntTotal) and ( FParam.UseUp[i] ) then
          inc(iMultiple)
        else
          break;
      end;

      if iIndex = 2 then
        iStatus := iindex
      else
       iStatus := i - 1;

      SetHedge( aQuote.Bids.CntTotal * FParam.UpBid[iStatus], aQuote.Asks.CntTotal);
    end else                                           //Down�̸鼭 ���� �ż��϶�
    begin
      for  i := iIndex to 2 do
      begin
        if ( aQuote.Asks.CntTotal * FParam.DownBid[i] > aQuote.Bids.CntTotal ) and ( FParam.UseDown[i] ) then
          inc(iMultiple)
        else
          break;
      end;

      if iIndex = 2 then
        iStatus := iindex
      else
       iStatus := i - 1;

      SetHedge(aQuote.Asks.CntTotal * FParam.DownBid[iStatus], aQuote.Bids.CntTotal);
    end;
  end else                                              //�ŵ��ֹ�
  begin
    if bUp then                                         //Up�̸鼭  �ŵ��϶�
    begin
      for i := iIndex downto 0 do
      begin
        if aQuote.Bids.CntTotal < aQuote.Asks.CntTotal * FParam.UpAsk[i] then
          inc(iMultiple)
        else
          break;
      end;

      if iIndex = 0 then
        iStatus := 0
      else
        iStatus := i  + 1;

      SetHedge(aQuote.Bids.CntTotal, aQuote.Asks.CntTotal * FParam.UpAsk[iStatus]);
    end else                                           //Down�̸鼭 �ŵ��϶�
    begin
      for  i := iIndex downto 0 do
      begin
        if aQuote.Asks.CntTotal < aQuote.Bids.CntTotal * FParam.DownAsk[i] then
          inc(iMultiple)
        else
          break;
      end;
      if iIndex = 0 then
        iStatus := 0
      else
        iStatus := i + 1;

      SetHedge(aQuote.Asks.CntTotal, aQuote.Bids.CntTotal * FParam.DownAsk[iStatus]);
    end;
  end;

  SetHedgeStatus(iStatus, bHedge, bUp);
  Result := iMultiple;
end;

function TStrangles.GetSide(aType: TBidAskType): integer;
begin
  Result := 0;
  case aType of
    baPutAsk,
    baCallAsk : Result := -1;
    baPutBid,
    baCallBid: Result := 1;
  end;
end;

function TStrangles.GetTimeOrder(iIndex: integer): TTimeOrder;
begin
  Result := nil;
  if (FTimeOrders.Count <= iIndex) or (iIndex < 0)  then exit;
  if FTimeOrders.Count = 0 then exit;

  Result := FTimeOrders.Items[iIndex] as TTimeOrder;
end;

function TStrangles.GetStatusDesc: string;
begin
  Result := '';
  case FHedgeStatus of
    hsNone: Result := 'None';
    hsUp1: Result := '���1';
    hsUp2: Result := '���2';
    hsUp3: Result := '���3';
    hsDown1: Result := '�϶�1';
    hsDown2: Result := '�϶�2';
    hsDown3: Result := '�϶�3';
  end;
end;

function TStrangles.SendOrder(aType: TBidAskType; bHedge : boolean; iMultiple : integer): boolean;
var
  i, iSide : integer;
  stCP,stLog : string;
  aItem : TStrangle;
  aOrder : TOrder;
begin
  Result := true;

  if (aType = baNone) or (not FParam.Start) then exit;

  if iMultiple = 0 then
  begin
    gEnv.EnvLog(WIN_STR, 'iMultiple = 0');
    exit;
  end;
  
  iSide := GetSide(aType);
  stCP := GetCallPut(aType);
  if (iSide = 0) or (stCP = '') then
  begin
    gEnv.EnvLog(WIN_STR, Format('iSide = %d, CallPut = %s, %s, %s',
      [iSide, stCP, GetStatusDesc, GetBidAskTypeDesc(aType)]));
    exit;
  end;

  if (bHedge) and (not FBidStart) then
  begin
    gEnv.EnvLog(WIN_STR, '�ŵ��ֹ��Ѱǵ� �߻����ؼ� ��¡ �ź�');
    exit;
  end;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangle;
    if (aItem.Symbol as TOption).CallPut = stCP then
    begin
      if not CheckLowOrder(aItem, bHedge) then                          //�������ݸ� ��¡
        continue;

      if (not CheckEntryOrder( aItem, stCP[1] )) and ( not bHedge ) then
      begin
        stLog := Format('%s %s Entry Order Filtering', [
          ifThenStr( stCP = 'C', '��','ǲ'), ifThenStr( aItem.FLowOrder , 'Low','High')]);
        gEnv.EnvLog( WIN_STR, stLog  );
        Continue;
      end;

      aOrder := aItem.DoOrder(iSide, FParam.OrderQty * iMultiple , FAccount);

      if aOrder <> nil then
      begin
        stLog := Format('%s, %s, %s, Qty = %d, Side = %d, Price = %.2f, OrderPrice = %.2f, AskCnt = %d, BidCnt = %d, Hedge = %f, Hedge = %f',
                       [GetStatusDesc, GetBidAskTypeDesc(aType), aOrder.Symbol.ShortCode, aOrder.OrderQty,
                       aOrder.Side, aOrder.Symbol.Last, aOrder.Price, FBidAskCnt[0], FBidAskCnt[1], FHedge[0], FHedge[1]]);
        gEnv.EnvLog(WIN_STR, stLog );
      end;
      if aOrder = nil then
        Result := false;
    end;
  end;
end;

procedure TStrangles.SetHedge( dBid, dAsk : double);
begin
  FHedge[0] := dBid;
  FHedge[1] := dAsk;
end;

procedure TStrangles.SetHedgeBidOrder;
var
  aItem : TStrangle;

begin
  if FBidStart then exit;
  if Count <=0 then exit;

  aItem := Items[0] as TStrangle;

  if aItem = nil then exit;
  if aItem.Position.Fills.Count > 0 then
    FBidStart := true; 
end;

procedure TStrangles.SetHedgeStatus(iStatus: integer; bHedge, bUp : boolean);
var
  stLog : string;
begin
  if bHedge then
  begin
    if bUp then
    begin
      case iStatus of
        0 : FHedgeStatus := hsUp1;
        1 : FHedgeStatus := hsUp2;
        2 : FHedgeStatus := hsUp3;
      end;
    end else
    begin
      case iStatus of
        0 : FHedgeStatus := hsDown1;
        1 : FHedgeStatus := hsDown2;
        2 : FHedgeStatus := hsDown3;
      end;
    end;
  end else
  begin
    if bUp then
    begin
      case iStatus of
        0 : FHedgeStatus := hsNone;
        1 : FHedgeStatus := hsUp1;
        2 : FHedgeStatus := hsUp2;
      end;
    end else
    begin
      case iStatus of
        0 : FHedgeStatus := hsNone;
        1 : FHedgeStatus := hsDown1;
        2 : FHedgeStatus := hsDown2;
      end;
    end;
  end;
end;

procedure TStrangles.SetLowPrice;
var
  i, j : integer;
  aItem, aSame : TStrangle;
begin

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrangle;
    for j := 0 to Count - 1 do
    begin
      aSame := Items[j] as TStrangle;
      if (aItem <> aSame) and
         ((aItem.Symbol as TOption).CallPut = (aSame.Symbol as TOption).CallPut) then
      begin
        if aItem.Symbol.Last > 0 then
        begin
          if aItem.Symbol.Last > aSame.Symbol.Last then
            aItem.FLowOrder := false;
        end else
        begin
          if aItem.Symbol.ExpectPrice > aSame.Symbol.ExpectPrice then
            aItem.FLowOrder := false;
        end;

      end;
    end;
  end;

end;

procedure TStrangles.SetOrderTime(stTime: array of string);
var
  iCnt : integer;
  aItem : TStrangle;
  I: Integer;
  wH, wM : word;
begin
  iCnt  := High( stTime );
  FTimeOrders.Clear;

  for I := 0 to iCnt  do
  begin
    wH  := StrToInt( Copy( stTime[i], 1, 2 ) );
    wM  := StrToInt( Copy( stTime[i], 4, 2 ) );
    FTimeOrders.AddTime( wH, wM, 0, 0);
  end;

  FCurrentTime := FTimeOrders.NextTime;

end;

procedure TStrangles.SetOrderTime;
var
  aItem : TStrangle;
begin
  if Count <= 0 then exit;

  aItem := Items[0] as TStrangle;

  if FTimeOrders.Count = 0 then
  begin
    FTimeOrders.AddTime(9,0,2,0);
    FTimeOrders.AddTime(9,15,0,0);
    FTimeOrders.AddTime(10,0,0,0);
    FTimeOrders.AddTime(11,0,0,0);
    FTimeOrders.AddTime(12,0,0,0);
    FTimeOrders.AddTime(13,0,0,0);
  end;
  FCurrentTime := FTimeOrders.NextTime;
end;

procedure TStrangles.UpdateUpHedge(idx: integer; bVal: boolean);
begin
  FParam.UseUp[idx] := bVal;
end;

procedure TStrangles.UpdateUseParam(iDiv: integer; bVal: boolean);
begin
  case iDiv of
    0 : FParam.LowOrder := bVal;
    1 : FParam.UseHedge := bVal;
    else Exit;
  end;
end;

procedure TStrangles.UpdateCallEntry(iDiv: integer; bVal: boolean);
begin
  // call        tag : 0 -> L   1 -> H
  case iDiv of
    0 : FParam.CalLowEnt  := bVal ;
    1 : FParam.CalHighEnt  := bVal;
  end;
end;

procedure TStrangles.UpdateDownHedge(idx: integer; bVal: boolean);
begin
  FParam.UseDown[idx] := bVal;
end;

procedure TStrangles.UpdatePutEntry(iDiv: integer; bVal: boolean);
begin
  // Put        tag : 0 -> L   1 -> H
  case iDiv of
    0 : FParam.PutLowEnt   := bVal ;
    1 : FParam.PUtHighEnt  := bVal;
  end;
end;

procedure TStrangles.UpdateTimeOrder( idx, ival : Integer );
var
  i : integer;
  aItem : TTimeOrder;
begin

  with FTimeOrders.Items[idx] as TTimeOrder do
    EnableTag := ival;
  FCurrentTime := FTimeOrders.NextTime;
end;

{ TStrangle }

function TStrangle.DoOrder(iSide, iQty: integer; aAcnt : TAccount) : TOrder;
var
  aTicket: TOrderTicket;
  aQuote : TQuote;
  dPrice : double;
  aBe : TOrderBeHaivor;
begin
    // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(TStrangles(Collection).FTrade);
  
  if iQty <= 0 then
    Exit;

  //dPrice := GetPrice(iSide);
  dPrice := FSymbol.Last;
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, aAcnt, FSymbol,
                iSide * iQty , pcLimit, dPrice, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opStrangle;
    gEnv.Engine.TradeBroker.Send(aTicket);
    aBe := TStrangles(Collection).FBeHaivors.New;
    aBe.NewOrder(Result, bpOpp2Hoga, bcStandBySec, 2000, 2);
  end;

end;

function TStrangle.GetPrice(iSide: integer): double;
begin
  if iSide = 1 then
    Result := FSymbol.LimitHigh
  else
    Result := FSymbol.LimitLow;

  if Result = 0 then      //9�� �ֹ��϶� ȣ������ ���°�� ����ü�ᰡ�� �ֹ�
  begin
  if iSide = 1 then
    Result := FSymbol.ExpectPrice + 0.1
  else
    Result := FSymbol.ExpectPrice - 0.1;
  end;
end;

{ TTimeOrders }

function TTimeOrders.AddTime(wH, wM, wS, wMs: Word): TTimeOrder;
var
  stLog : string;
  dtTime: TDateTime;
begin
  Result := Add as TTimeOrder;

  Result.FTimeOrder := EnCodeTime(wH, wM, wS, wMs);
  Result.EnableTag  := 1;

  dtTime  := Frac( GetQuoteTime );

  if dtTime >= Result.FTimeOrder then
    Result.FSend := true
  else
    Result.FSend := false;
end;

constructor TTimeOrders.Create;
begin
  inherited Create(TTimeOrder);
end;

destructor TTimeOrders.Destroy;
begin

  inherited;
end;

function TTimeOrders.NextTime: TTimeOrder;
var
  i : integer;
  aItem : TTimeOrder;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TTimeOrder;
    if (not aItem.FSend) and ( aItem.EnableTag = 1 ) then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

{ TStrangleTrade }

procedure TStrangleTrade.ClearOrder;
begin
  FStrangles.ClearOrder;
end;

constructor TStrangleTrade.Create(aColl: TCollection; opType : TOrderSpecies);
begin
  inherited Create(aColl, opType, stStrangle, true);
  FStrangles := TStrangles.Create;
  FStrangles.FScreenNumber := Number;
  FStrangles.FTrade := self;
end;

destructor TStrangleTrade.Destroy;
begin
  FStrangles.Free;
  inherited;
end;

procedure TStrangleTrade.QuoteProc(aQuote: TQuote; iDataID : integer);
var
  aType : TBidAskType;
  stTime : string;
  iMultiple : integer;
begin
  if aQuote = nil then Exit;

  if aQuote.Symbol <> gEnv.Engine.SymbolCore.Futures[0] then exit;

  stTime := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime);
  FStrangles.CheckTimeOrder(EndTime);  //�ð��ֱ� �ֹ��� û���ֹ�

  if (aQuote.AddTerm) and (Frac(GetQuoteTime) > StartTime) then
  begin
    aType := FStrangles.CheckHedge(aQuote, iMultiple);            // �ŵ��ż��ѰǼ� �� 1�������϶���
    if not FStrangles.SendOrder(aType, true, iMultiple) then      //�ֹ�����
      gEnv.EnvLog(WIN_STR, 'TStrange Send Order Failed');
  end;

  if Assigned(OnResult) then   //ȭ�鰻��
    OnResult(aQuote, true);
end;

procedure TStrangleTrade.ReSet;
begin
  FStrangles.Clear;
  FStrangles.BidStart := false;
end;

procedure TStrangleTrade.SetAccount(aAcnt: TAccount);
begin
  Account := aAcnt;
  FStrangles.FAccount := aAcnt;
end;

procedure TStrangleTrade.SetStopLossAmt(dAmt: double);
begin
  gEnv.EnvLog(WIN_STR, Format('�ѵ��ݾ׼��� %.0n -> %.0n ', [ FStrangles.FParam.LossAmt, dAmt ]) );
  FStrangles.FParam.LossAmt := dAmt;
end;

procedure TStrangleTrade.SetSymbol;
var
  i : integer;
  aPos, aPos1 : TPosition;
  bRet : boolean;
  aList : TList;
begin

  aList := TList.Create;
  GetPosition(aList);

  if aList.Count = 0 then
  begin
     bRet := SymbolSelect(FStrangles.FParam.LowPrice, FStrangles.FParam.HighPrice);

    if not bRet then
    begin
      gEnv.EnvLog(WIN_STR, '�����Ǽ�������');
      exit;
    end;
    GetPosition(aList);
  end;

  for i := 0 to aList.Count - 1 do
  begin
    aPos := aList.Items[i];
    FStrangles.AddSymbol(aPos);
  end;

  aList.Free;
  //FStrangles.SetOrderTime;   //�ð� ����
  FStrangles.SetLowPrice;
end;

procedure TStrangleTrade.StartStop(aParam: TStrangleParams);
begin
  FStrangles.FParam := aParam;
end;

procedure TStrangleTrade.TradeProc(aOrder: TOrder; aPos : TPosition;  iID: integer);
begin

end;

procedure TStrangleTrade.UpdateTimeOrder(  idx, ival : Integer );
begin
  FStrangles.UpdateTimeOrder( idx, ival );
end;



end.
