unit CleTradeBroker;

interface

uses
  Classes, SysUtils,

    // lemon: common
  GleTypes, GleConsts,
      // lemon: data
  CleTradeCore,  CleAccounts, CleOrders, CleFills, ClePositions, CleSymbols, CleFunds,
    // lemon: utils
  CleDistributor , CleQuoteTimers

  ;

{$INCLUDE define.txt}

type
  TOrderEvent = function(aOrder: TOrder): Boolean of object;
  TSendOrderEvent = function(aTicket: TOrderTicket): Integer of object;

  // gi query event
  TQueryOrderEvent = function( QueryDate, TrCode : string ) : integer of object;
  //TQueryOrderList =  function( TrCode, stAcnt, stMarket, OrdState, GunDiv, symbolCode : string;
  //    QueryDate : string = '') : integer of object;

  TTradeBroker = class
  private
      // objects: assigned
    FTradeCore: TTradeCore;
      // objects: created
    FDistributor: TDistributor;
    FForwardOrderResults: TOrderResultList;
      // events
    FOnOrderChange: TOrderEvent;
    FOnSendOrder: TSendOrderEvent;

      // logging
    FVerbose: Boolean;
    FOnLog: TTextNotifyEvent;

    FForwardAccepts : TForwardAccepts;
      //

    FNewCnt : integer;
    FChgCnt : integer;
    FCnlCnt : integer;
    procedure DoLog(stLog: String);

  public
    constructor Create;
    destructor Destroy; override;

      // subscription
    procedure Subscribe(Sender: TObject; aHandler: TDistributorEvent); overload;
    procedure Subscribe(Sender: TObject; iDataID : integer; aHandler: TDistributorEvent); overload;
    procedure Unsubscribe(Sender: TObject);
      // send order
    function Send(aTicket: TOrderTicket): Integer;

    procedure SrvReject( aOrder : TOrder; stReject, stReason : string ); overload;
    procedure SrvReject( aOrder : TOrder; stReject : string ); overload;
    procedure SrvAccept( aOrder : TOrder; iReject : integer ); overload;
    procedure SrvAccept( aOrder : TOrder; iOrdNo : int64; stReject : string ); overload;
    procedure SrvAccept( aOrder : TOrder; iOrdNo : int64 ); overload;
    procedure SrvAccept( aOrder : TOrder; iOrdNo, iErrCode : integer; stReject : string = '' ); overload;

      // process response from the exchange
    function Accept(aOrder: TOrder; bAccepted: Boolean; stRjtCode : string;
      dtGiven: TDateTime; iAbleOrdQty : integer = 0 ): TOrder;
    procedure Fill(aOrder: TOrder; dtGiven: TDateTime); overload;
    procedure Fill(aResult: TOrderResult; dtGiven: TDateTime; iAbleOrdQty : integer = 0); overload;
    procedure Fill(aOrder : TOrder; aFill: TFill ); overload;

   //procedure Position( aOrder : TOrder; aInvest: TInvestor;

    procedure AddTurnOrder(aResult: TOrderResult; dtGiven: TDateTime );
    procedure Confirm(aResult: TOrderResult; dtGiven: TDateTime; iAbleOrdQty : integer = 0); overload;
    procedure Confirm(aOrder: TOrder; dtGiven: TDateTime); overload;
    function AddPosition( aAccount : TAccount; aSymbol : TSymbol;  Side, Qty: integer; AvgPrice: double ) : TPosition;

    procedure AccountEvent( aInvest : TInvestor ; aEventID : TDistributorID);
    procedure PositionEvent( aInvestPosition : TPosition );  overload;
    procedure PositionEvent( aPosition : TPosition;aEventID : TDistributorID ); overload;
    procedure PositionEvent( aPosition : TFundPosition;aEventID : TDistributorID ); overload;
    procedure FundEvent(aData: TObject; aEventID: TDistributorID);
      // TOrders.OnNew event handler
    procedure OrderAdded(aOrder: TOrder);
      // property: assigned object
    property TradeCore: TTradeCore read FTradeCore write FTradeCore;

      // control
    property Verbose: Boolean read FVerbose write FVerbose;
      // events
    property OnOrderChange: TOrderEvent read FOnOrderChange write FOnOrderChange;
    property OnSendOrder: TSendOrderEvent read FOnSendOrder write FOnSendOrder;
    property OnLog: TTextNotifyEvent read FOnLog;
    property ForwardAccepts : TForwardAccepts read FForwardAccepts;

    procedure Clear;

  end;

implementation

uses GAppEnv, GleLib;

//-----------------------------------------------------------< create/destroy >

constructor TTradeBroker.Create;
begin
  FDistributor := TDistributor.Create;
  FForwardOrderResults := TOrderResultList.Create;
  FVerbose  := true;
  FForwardAccepts := TForwardAccepts.Create;


  FNewCnt := 0;
  FChgCnt := 0;
  FCnlCnt := 0;
end;

destructor TTradeBroker.Destroy;
begin
  FForwardOrderResults.Free;
  FForwardAccepts.Free;
  FDistributor.Free;
end;

procedure TTradeBroker.DoLog(stLog: String);
begin
  Exit;
  if Assigned(FOnLog) then
    FOnLog(Self, 'TradeBroker: ' + stLog);
end;



procedure TTradeBroker.Fill(aResult: TOrderResult; dtGiven: TDateTime; iAbleOrdQty : integer);
var
  aOrder: TOrder;
  aFill: TFill;
  aPos, aPosition: TPosition;
  bResult : boolean;

  is1, is2, is3, is4 : int64;
  dRes : double;
  stTmp : string;
  iType : integer;

  aInvestor : TInvestor;
  aInvestPosition : TPosition;

  aFundPos : TFundPosition;
  aFund    : TFund;
  bNewFundPos : boolean;
begin
  if (FTradeCore = nil) and (aResult = nil) then Exit;
    // find order
  aOrder := FTradeCore.Orders.FindINvestorOrder((aResult.Account as TInvestor), aResult.Symbol, aResult.OrderNo);
  //aOrder := FTradeCore.Orders.Find(aResult.Account, aResult.Symbol, aResult.OrderNo);

  if aOrder <> nil then
    aResult.Account := aOrder.Account
  else begin
    gEnv.EnvLog(WIN_ORD, Format('ORDER NOT FOUND:%d:%d:%d:%s',
      [aResult.OrderNo, aResult.RefNo, aResult.Qty, aResult.Account.Code  ]));
    Exit;
  end;

    // order result was faster than order accept
  if not aOrder.IsAccept then
  begin
    //FForwardOrderResults.Insert(0, aResult); // recent one in front
    Accept( aOrder, true, '', GetQuoteTime );
    //if FVerbose then
    gEnv.EnvLog(WIN_ORD, Format('FORWARD FILL SAVED:%d:%d:%d',
      [aResult.OrderNo, aResult.RefNo, aResult.Qty ]));
  end;

    // add fill object
  aFill := FTradeCore.Fills.New(aResult.RefNo, aResult.ResultTime, aResult.FillTime,
                  aOrder.OrderNo, aOrder.Account, aOrder.Symbol,
                  aOrder.Side * aResult.Qty, aResult.Price, aOrder.OrderSpecies);

  // aFill.Order := aOrder;
  aOrder.Fills.AddFill( aFill );

  if FVerbose then
    gEnv.EnvLog(WIN_ORD, Format('FILL:%d:%d:%d:%.4n:%s', [aFill.OrderNo,
                aFill.FillNo, aFill.Volume, aFill.Price,
                FormatDateTime('hh:nn:ss', dtGiven)]));

    //
  aOrder.Fill(aFill.Volume, aFill.Price , aResult);
  aOrder.Results.Add( aResult );

  aPosition := FTradeCore.Positions.Find(aFill.Account, aFill.Symbol);
  if aPosition = nil then
  begin
    aPosition := FTradeCore.Positions.New(aFill.Account, aFill.Symbol);
    FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
  end;

  aPosition.DoOrder(aOrder.Side, -Abs(aFill.Volume));
  aPosition.AddFill(aFill);

  // investor position
  aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
  if aInvestPosition = nil then
    aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
  aInvestPosition.DoOrder( aOrder.Side, -Abs(aFill.Volume) );
  aInvestPosition.AddFill( aFill );

  iType := integer(aOrder.OrderSpecies);
  FTradeCore.StrategyGate.DoFill(aFill, aOrder);

  aFill.Account.ApplyFill( aFill, aFill.Volume, aFill.Price );
  aFill.Account.RecalcMargin;

  aInvestor.ApplyFill( aFill, aFill.Volume, aFill.Price );
  aInvestor.RecalcMargin;

  // fund poistion
  aFundPos := nil;
  aFund := FTradeCore.Funds.Find( aOrder.Account);
  if aFund <> nil then
  begin
    aFundPos  := FTradeCore.FundPositions.Find( aFund, aOrder.Symbol  );
    if aFundPos = nil then begin
      aFundPos := FTradeCore.FundPositions.New( aFund, aOrder.Symbol);
      FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_NEW);
    end;

    if not aFundPos.Positions.FindPosition( aPosition ) then
      aFundPos.Positions.Add( aPosition );

    aFundPos.DoOrder(aOrder.Side, -Abs(aFill.Volume));
    aFundPos.AddFill( aFill );
    aFund.ApplyFill( aOrder.Symbol, aFill.Volume, aFill.Price );
  end ;

  FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_FILLED);

  FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_FILLED);
  FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);
  FDistributor.Distribute(Self, TRD_DATA, aFill, FILL_NEW);
  if aFundPos <> nil then
    FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_UPDATE);

  if FVerbose then
    DoLog('Queues: ' + FTradeCore.Orders.Represent);

end;

//-------------------------------------------------------------< subscription >

procedure TTradeBroker.Subscribe(Sender: TObject; aHandler: TDistributorEvent);
begin
  if Sender = nil then Exit;

  FDistributor.Subscribe(Sender, TRD_DATA, ANY_OBJECT, ANY_EVENT, aHandler);
end;

procedure TTradeBroker.Subscribe(Sender: TObject; iDataID: integer;
  aHandler: TDistributorEvent);
begin
  if Sender = nil then Exit;

  FDistributor.Subscribe(Sender, iDataID, ANY_OBJECT, ANY_EVENT, aHandler);
end;

procedure TTradeBroker.Unsubscribe(Sender: TObject);
begin
  FDistributor.Cancel(Sender);
end;



//---------------------------------------------------------------------< send  & query>

function TTradeBroker.Send(aTicket: TOrderTicket): Integer;
var
  Path : string;
begin
  if (aTicket <> nil)
     and Assigned(FOnSendOrder) then
  begin
    Result := FOnSendOrder(aTicket);
  end else
    Result := 0;
  {
  // ??????..?????????? ?????? ????
  if gEnv.RunMode = rtRealTrading then
  begin
    Path := Format('%s_%s',
    [
    FormatDateTime('yyyymmdd', Now ), gEnv.ConConfig.UserID
    ]);
    //gEnv.OrderNoLog( '',IntToStr( gEnv.ConConfig.LastOrderNo ) , false, Path);
  end;
  }
end;

procedure TTradeBroker.SrvAccept(aOrder: TOrder;  iOrdNo : int64; stReject: string);
begin
  if ((stReject = '') or (stReject = '0000')) and ( iOrdNo > 0 )  then begin
    aOrder.SrvAcpt( iOrdNo );
  end
  else begin
    aOrder.Reject(iOrdNo, now, stReject);
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
  end;
end;

procedure TTradeBroker.SrvAccept(aOrder: TOrder; iReject: integer);
begin
  if iReject <> 0 then begin
    //aOrder.Reject(iReject, now);
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
  end
  else
    aOrder.SrvAcpt( iReject );
end;

procedure TTradeBroker.SrvAccept(aOrder: TOrder; iOrdNo: int64);
begin
  if ( aOrder <> nil ) and ( iOrdNo >= gEnv.ConConfig.StartOrderNo ) then
    aOrder.SrvAcpt( iOrdNo )
  else
    gLog.Add( lkError, 'TTradeBroker','SrvAccept', Format('???????? ???? : %d ',  [iOrdNo]) );
end;

procedure TTradeBroker.SrvAccept(aOrder: TOrder; iOrdNo, iErrCode: integer;
  stReject: string);
begin
  if ( iOrdNo > 0 ) and ( iErrCode = 0 )  then begin
    aOrder.SrvAcpt( iOrdNo );
  end
  else begin
    aOrder.Reject(iOrdNo, now, stReject);
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
  end;
end;

procedure TTradeBroker.SrvReject(aOrder: TOrder; stReject, stReason: string);
begin
    aOrder.Reject(stReject, stReason );
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
end;

procedure TTradeBroker.SrvReject(aOrder: TOrder; stReject: string);
begin
    aOrder.Reject(stReject, now );
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
end;



//----------------------------------------------------< process order results >

// order accepted
// process after an order has been registered successfully in the exchange
//
function TTradeBroker.Accept(aOrder: TOrder; bAccepted: Boolean;
  stRjtCode : string; dtGiven: TDateTime; iAbleOrdQty : integer): TOrder;
var
  i: Integer;
  aPosition: TPosition;
  aResult: TOrderResult;
  stLog, stTime, stType,stFile, stHeader : string;
  dtSTime, dtETime, dtCTime : TDateTime;
  TF : TextFile ;
  dTot, dEntryOte, dEntryPL : double;
  aInvestor : TInvestor;
  aInvestPosition : TPosition;

  aFundPos : TFundPosition;
  aFund    : TFund;
  bNewFundPos : boolean;
begin
  Result := nil;

  if (FTradeCore = nil) or (aOrder = nil) then Exit;

  if FVerbose then
  begin
    if bAccepted then
      gEnv.EnvLog( WIN_ORD, Format('ACCEPT:%d:%d:%s', [aOrder.Ticket.No , aOrder.OrderNo,
                                         FormatDateTime('hh:nn:ss', dtGiven)]))
    else
      gEnv.EnvLog( WIN_ORD,Format('REJECT:%d:%d:%s', [aOrder.Ticket.No , aOrder.OrderNo,
                                         FormatDateTime('hh:nn:ss', dtGiven)]));
  end;

 	  // if the engine cannot find an order by the local order number
    // it means that the order was sent by other dealer
  if aOrder.Ticket = nil then
  begin
    gEnv.EnvLog( WIN_ORD,Format('FOREIGN ACCEPT:%d:%s', [aOrder.OrderNo,
                                   FormatDateTime('hh:nn:ss', dtGiven)]));
    Exit;
  end;

  Result := aOrder;

  if FVerbose then
  begin
    gEnv.EnvLog( WIN_ORD,Format('%s:%d:%d:%.4f', [aOrder.OrderTypeDesc, aOrder.Side,
                                   aOrder.OrderQty, aOrder.Price]));
  end;

  if bAccepted then
  begin
    if aOrder.IsAccept then Exit;       
      // update order
    aOrder.Accept( dtGiven);
      // update position
    aPosition := FTradeCore.Positions.Find(aOrder.Account, aOrder.Symbol);
    if aPosition = nil then
    begin
      aPosition := FTradeCore.Positions.New(aOrder.Account, aOrder.Symbol);
      FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
    end;

    if aOrder.OrderType <> otCancel then
    begin
      if aOrder.OrderType = otNormal then
        aPosition.DoOrder(aOrder.Side, aOrder.OrderQty);
    end;
      // notify
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_ACCEPTED);
    FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);

    if aOrder.OrderType = otNormal then
      aOrder.checkSound;

    // investor position
    aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
    aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
    if aInvestPosition = nil then
      aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
    if aOrder.OrderType = otNormal then
      aInvestPosition.DoOrder( aOrder.Side, aOrder.OrderQty );

    // fund poistion
    aFund := FTradeCore.Funds.Find( aOrder.Account);
    if aFund <> nil then
    begin
      aFundPos  := FTradeCore.FundPositions.Find( aFund, aOrder.Symbol  );
      if aFundPos = nil then begin
        aFundPos := FTradeCore.FundPositions.New( aFund, aOrder.Symbol);
        FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_NEW);
      end;

      if aOrder.OrderType = otNormal then
        aFundPos.DoOrder(aOrder.Side, aOrder.OrderQty);
      if not aFundPos.Positions.FindPosition( aPosition ) then
        aFundPos.Positions.Add( aPosition );
      FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_UPDATE);
    end ;

    FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_ACCEPTED);

  end else
  begin
    aOrder.Reject( stRjtCode, dtGiven);

{$IFDEF KR_FUT}
    if aOrder.IsAccept then
    begin
      aPosition := FTradeCore.Positions.Find(aOrder.Account, aOrder.Symbol);
      if aPosition <> nil then
      begin
        if aOrder.OrderType = otNormal then
        begin
          aPosition.DoOrder(aOrder.Side, -aOrder.OrderQty);
          FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);
        end;

        gEnv.EnvLog( WIN_ORD,Format('Rjt2 - %s:%d:%d:%.4f  - %d(%d:%d) ', [aOrder.OrderTypeDesc, aOrder.Side,
                                   aOrder.OrderQty, aOrder.Price,
                                   aPosition.Volume, aPosition.ActiveBuyOrderVolume, aPosition.ActiveSellOrderVolume  ]));
      end;

      aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
      aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
      if aInvestPosition <> nil then
        if aOrder.OrderType = otNormal then
          aInvestPosition.DoOrder( aOrder.Side, -aOrder.OrderQty );

      // fund poistion
      aFund := FTradeCore.Funds.Find( aOrder.Account);
      if aFund <> nil then
      begin
        aFundPos  := FTradeCore.FundPositions.Find( aFund, aOrder.Symbol  );
        if aFundPos <> nil then 
          if aOrder.OrderType = otNormal then
          begin
            aFundPos.DoOrder(aOrder.Side, -aOrder.OrderQty);
            FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_UPDATE);
          end;
      end ;
    end;
{$ENDIF}

    FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_REJECTED);
    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
  end;

    // process the forward order results, if any

  if FForwardOrderResults.Count > 0 then
  begin
    gEnv.EnvLog( WIN_ORD, Format('See FForwardOrderResult:%d:%d', [FForwardOrderResults.Count, aORder.OrderNo]) );
  end;

  for i := FForwardOrderResults.Count-1 downto 0 do
  begin
    aResult := FForwardOrderResults[i];
    if aResult <> nil  then
    begin
      gEnv.EnvLog( WIN_ORD,Format('Search FForwardOrderResults:%d:%d:%d:%s', [aResult.OrderNo,
                                      aResult.Qty,   integer(aResult.ResultType),
                                     FormatDateTime('hh:nn:ss', dtGiven)]));
      if aResult.OrderNo = aOrder.OrderNo then
      begin
        case aResult.ResultType of
          orFilled: Fill(aResult, Now);
          orConfirmed: Confirm(aResult, Now);
        end;

        gEnv.EnvLog( WIN_ORD,Format('FIND FForwardOrderResults:%d:%s', [aOrder.OrderNo,
                                     FormatDateTime('hh:nn:ss', dtGiven)]));
        FForwardOrderResults.Remove(aResult);
      end;
    end;
  end;

end;

// A change or cancel order has been executed(confirmed)
//


procedure TTradeBroker.AccountEvent( aInvest : TInvestor; aEventID : TDistributorID  );
begin
  FDistributor.Distribute(Self, TRD_DATA, aInvest, aEventID);
end;

function TTradeBroker.AddPosition(aAccount: TAccount; aSymbol: TSymbol; Side,
  Qty : integer; AvgPrice: double) : TPosition;
var aPosition : TPosition;
begin
  aPosition := FTradeCore.Positions.Find( aAccount, aSymbol);
  if aPosition = nil then
  begin
    aPosition := FTradeCore.Positions.New(aAccount, aSymbol);//,        Side * Qty, AvgPrice );
  end;

  result := aPosition;
end;

procedure TTradeBroker.AddTurnOrder(aResult: TOrderResult; dtGiven: TDateTime);
begin
  FForwardOrderResults.Insert(0, aResult);
  gEnv.EnvLog(WIN_ORD, Format('FORWARD FILL SAVED:%d:%d:%d', [aResult.OrderNo, aResult.RefNo, aResult.Qty]));
end;

procedure TTradeBroker.Clear;
begin
  FForwardOrderResults.Clear;
end;

procedure TTradeBroker.Confirm(aResult: TOrderResult; dtGiven: TDateTime; iAbleOrdQty : integer);
var
  i : integer;
  aOrder : TOrder;
  aPosition: TPosition;
  stTmp: string;
  aInvestor : TInvestor;
  aInvestPosition : TPosition;

  aFundPos : TFundPosition;
  aFund    : TFund;
  bNewFundPos : boolean;
begin
  if (FTradeCore = nil) or (aResult = nil) then Exit;

  aOrder := FTradeCore.Orders.FindINvestorOrder( (aResult.Account as TInvestor), aResult.Symbol, aResult.OrderNo);
  //aOrder := FTradeCore.Orders.Find(aResult.Account, aResult.Symbol, aResult.OrderNo);
  if aOrder = nil then Exit;
  aResult.Account := aOrder.Account;

  aResult.SetCancelType(aOrder.OrderType);

  if FVerbose then
    gEnv.EnvLog(WIN_ORD, Format('CONFIRM:%d:%d:%d:%s', [aResult.OrderNo,
                aResult.Qty, aResult.RefNo,
                FormatDateTime('hh:nn:ss', dtGiven)]));

    // handle based on the order type
  case aOrder.OrderType of
    otNormal:
      begin
        if aResult.RjtCode = '' then
        begin
          aOrder.Accept( dtGiven);
          // update position
          aPosition := FTradeCore.Positions.Find(aOrder.Account, aOrder.Symbol);
          if aPosition = nil then
          begin
            aPosition := FTradeCore.Positions.New(aOrder.Account, aOrder.Symbol);
            FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
          end;

          aPosition.DoOrder(aOrder.Side, aOrder.OrderQty);
            // notify
          FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_ACCEPTED);
          FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);

          // investor position
          aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
          aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
          if aInvestPosition = nil then
            aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
          aInvestPosition.DoOrder( aOrder.Side, aOrder.OrderQty );
          //

          // fund poistion
          aFund := FTradeCore.Funds.Find( aOrder.Account);
          if aFund <> nil then
          begin
            aFundPos  := FTradeCore.FundPositions.Find( aFund, aOrder.Symbol  );
            if aFundPos = nil then begin
              aFundPos := FTradeCore.FundPositions.New( aFund, aOrder.Symbol);
              FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_NEW);
            end;

            if not aFundPos.Positions.FindPosition( aPosition ) then
              aFundPos.Positions.Add( aPosition );
          end ;

        end
        else begin
          aOrder.Reject( aResult.RjtCode, dtGiven);
          FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
        end;
      end;

      // the confirmation for the change order incurs following
      // 1. set the change order as osConfirmed
      // 2. decrease 'active(outstanding)' qty from the target order,
      //    if 'active' aty is down to zero, it is marked as osCanceled or
      //    or osFilled if it was filled at least partly
      // 3. create new order and copy from the target order
      // 4. notify
    otChange:
      if aResult.Qty > 0 then
      begin
          // there is no update for the position
          // set order

        aOrder.Target.Cancel(aResult.Qty, aResult);
        aOrder.Change( aResult.Qty, aResult );
        //aOrder.Target.DoQuote( qpDelete );
        FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_CHANGED);
        FTradeCore.StrategyGate.DoOrder(aOrder.Target, ORDER_CANCELED);

        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CHANGED);
        FDistributor.Distribute(Self, TRD_DATA, aOrder.Target, ORDER_CANCELED);
      end else
      begin
        aOrder.Fail(aResult.RjtCode , dtGiven);
        FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_CONFIRMFAILED);
        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CONFIRMFAILED);
      end;

      // the confirmation for the cancel order incurs following
      // 1. set the change order as osConfirmed
      // 2. decrease 'active(outstanding)' qty from the target order,
      //    if 'active' aty is down to zero, it is marked as osCanceled or
      //    or osFilled if it was filled at least partly
      // 3. notify
    otCancel:
      if aResult.Qty > 0 then
      begin
          // update position
        aPosition := FTradeCore.Positions.Find(aOrder.Account, aOrder.Symbol);
        if aPosition = nil then
        begin
          aPosition := FTradeCore.Positions.New(aOrder.Account, aOrder.Symbol);
          FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
        end;

        aPosition.DoOrder(aOrder.Target.Side, -aResult.Qty);
          // update order
        aOrder.Confirm(aResult.Qty, dtGiven);
          // update target order
        aOrder.Target.Cancel(aResult.Qty, aResult);
          //aOrder.Target.DoQuote( qpDelete );
          // notify to clients
        FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_CONFIRMED);
        FTradeCore.StrategyGate.DoOrder(aOrder.Target, ORDER_CANCELED);
        
        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CONFIRMED);
        FDistributor.Distribute(Self, TRD_DATA, aOrder.Target, ORDER_CANCELED);
        FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);

          // investor position
        aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
        aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
        if aInvestPosition = nil then
          aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
        aInvestPosition.DoOrder( aOrder.Target.Side, -aResult.Qty );

        // fund poistion
        aFund := FTradeCore.Funds.Find( aOrder.Account);
        if aFund <> nil then
        begin
          aFundPos  := FTradeCore.FundPositions.Find( aFund, aOrder.Symbol  );
          if aFundPos = nil then begin
            aFundPos := FTradeCore.FundPositions.New( aFund, aOrder.Symbol);
            FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_NEW);
          end;
          aFundPos.DoOrder(aOrder.Target.Side, -aResult.Qty);
          if not aFundPos.Positions.FindPosition( aPosition ) then
            aFundPos.Positions.Add( aPosition );
          FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_UPDATE);
        end ;
        //
      end else
      begin
        aOrder.Fail(aResult.RjtCode, dtGiven);
        FTradeCore.StrategyGate.DoOrder(aOrder, ORDER_CONFIRMFAILED);
        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CONFIRMFAILED);
      end;
  end;

  // ????????, ?????????? ????????..
  if ( aOrder.State = osActive ) and ( aORder.OrderType = otNormal ) then
    for i := FForwardOrderResults.Count-1 downto 0 do
    begin
      aResult := FForwardOrderResults[i];
      if aResult.OrderNo = aOrder.OrderNo then
      begin
        case aResult.ResultType of
          orFilled: Fill(aResult, GetQuoteTime);
          //orConfirmed: Confirm(aResult, GetQuoteTime);
        end;
             
        gEnv.EnvLog( WIN_ORD,Format('FIND FForwardOrderResults:%d:%s', [aOrder.OrderNo,
                                     FormatDateTime('hh:nn:ss', dtGiven)]));
        FForwardOrderResults.Remove(aResult);
      end;
    end;

end;

procedure TTradeBroker.Confirm(aOrder: TOrder; dtGiven: TDateTime);
var
  i : integer;
  aResult: TOrderResult;
  aPosition: TPosition;
  stTmp: string;
  aInvestor : TInvestor;
  aInvestPosition : TPosition;
begin
  if (FTradeCore = nil) or (aOrder = nil) then Exit;

  aResult := aOrder.Results.Results[ aOrder.Results.Count-1 ];
  if aResult = nil then Exit;  

  aResult.SetCancelType(aOrder.OrderType);
  if FVerbose then
    gEnv.EnvLog(WIN_ORD, Format('CONFIRM:%d:%d:%d:%s', [aResult.OrderNo,
                aResult.Qty, aResult.RefNo,
                FormatDateTime('hh:nn:ss', dtGiven)]));

    // handle based on the order type
  case aOrder.OrderType of
    otNormal:
      begin
        if aResult.RjtCode = '' then
        begin
          aOrder.Accept( dtGiven);
          // update position
          aPosition := FTradeCore.Positions.Find(aOrder.Account, aOrder.Symbol);
          if aPosition = nil then
          begin
            aPosition := FTradeCore.Positions.New(aOrder.Account, aOrder.Symbol);
            FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
          end;

          aPosition.DoOrder(aOrder.Side, aOrder.OrderQty);
            // notify
          FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_ACCEPTED);
          FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);

          // investor position
          aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
          aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
          if aInvestPosition = nil then
            aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
          aInvestPosition.DoOrder( aOrder.Side, aOrder.OrderQty );
          //
        end
        else begin
          aOrder.Reject( aResult.RjtCode, dtGiven);
          FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_REJECTED);
        end;
      end;

      // the confirmation for the change order incurs following
      // 1. set the change order as osConfirmed
      // 2. decrease 'active(outstanding)' qty from the target order,
      //    if 'active' aty is down to zero, it is marked as osCanceled or
      //    or osFilled if it was filled at least partly
      // 3. create new order and copy from the target order
      // 4. notify
    otChange:
      if aResult.Qty > 0 then
      begin
          // there is no update for the position
          // set order

        aOrder.Target.Cancel(aResult.Qty, aResult);
        aOrder.Change( aResult.Qty, aResult );
        //aOrder.Target.DoQuote( qpDelete );

        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CHANGED);
        FDistributor.Distribute(Self, TRD_DATA, aOrder.Target, ORDER_CANCELED);
      end else
      begin
        aOrder.Fail(aResult.RjtCode , dtGiven);
        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CONFIRMFAILED);
      end;

      // the confirmation for the cancel order incurs following
      // 1. set the change order as osConfirmed
      // 2. decrease 'active(outstanding)' qty from the target order,
      //    if 'active' aty is down to zero, it is marked as osCanceled or
      //    or osFilled if it was filled at least partly
      // 3. notify
    otCancel:
      if aResult.Qty > 0 then
      begin
          // update position
        aPosition := FTradeCore.Positions.Find(aResult.Account, aResult.Symbol);
        if aPosition = nil then
        begin
          aPosition := FTradeCore.Positions.New(aResult.Account, aResult.Symbol);
          FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
        end;

        aPosition.DoOrder(aOrder.Target.Side, -aResult.Qty);
          // update order
        aOrder.Confirm(aResult.Qty, dtGiven);
          // update target order
        aOrder.Target.Cancel(aResult.Qty, aResult);
        //aOrder.Target.DoQuote( qpDelete );
          // notify to clients
        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CONFIRMED);
        FDistributor.Distribute(Self, TRD_DATA, aOrder.Target, ORDER_CANCELED);
        FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);

        // investor position
        aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
        aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
        if aInvestPosition = nil then
          aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
        aInvestPosition.DoOrder( aOrder.Target.Side, -aResult.Qty );
        //
      end else
      begin
        aOrder.Fail(aResult.RjtCode, dtGiven);
        FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_CONFIRMFAILED);
      end;
  end;

  // ????????, ?????????? ????????..
  if ( aOrder.State = osActive ) and ( aORder.OrderType = otNormal ) then
    for i := FForwardOrderResults.Count-1 downto 0 do
    begin
      aResult := FForwardOrderResults[i];
      if aResult.OrderNo = aOrder.OrderNo then
      begin
        case aResult.ResultType of
          orFilled: Fill(aResult, GetQuoteTime);
          //orConfirmed: Confirm(aResult, GetQuoteTime);
        end;
             
        gEnv.EnvLog( WIN_ORD,Format('FIND FForwardOrderResults:%d:%s', [aOrder.OrderNo,
                                     FormatDateTime('hh:nn:ss', dtGiven)]));
        FForwardOrderResults.Remove(aResult);
      end;
    end;


    //
  if FVerbose then
    DoLog('Queues: ' + FTradeCore.Orders.Represent);
end;

// An order has been executed (filled)
//
procedure TTradeBroker.Fill(aOrder: TOrder; dtGiven: TDateTime);
var
  aResult: TOrderResult;
  aFill: TFill;
  aPosition: TPosition;
  bResult : boolean;

  is1, is2, is3, is4 : int64;
  dRes : double;
  stTmp : string;
  iType : integer;

  aInvestor : TInvestor;
  aInvestPosition : TPosition;
begin
  if (FTradeCore = nil) and (aOrder = nil) then Exit;

    // find order
  aResult := aOrder.Results[aOrder.Results.Count-1];

    // order result was faster than order accept
  if not aOrder.IsAccept then
  begin
    FForwardOrderResults.Insert(0, aResult); // recent one in front

    //if FVerbose then
    gEnv.EnvLog(WIN_ORD, Format('FORWARD FILL SAVED:%d:%d:%d', [aResult.OrderNo, aResult.RefNo, aResult.Qty]));
  end else
  begin
      // add fill object
    aFill := FTradeCore.Fills.New(aResult.RefNo, aResult.ResultTime, aResult.FillTime,
                    aOrder.OrderNo, aOrder.Account, aOrder.Symbol,
                    aOrder.Side * aResult.Qty, aResult.Price, aOrder.OrderSpecies);

    // aFill.Order := aOrder;
    aOrder.Fills.AddFill( aFill );

    if FVerbose then
      gEnv.EnvLog(WIN_ORD, Format('FILL:%d:%d:%d:%.4n:%s', [aFill.OrderNo,
                  aFill.FillNo, aFill.Volume, aFill.Price,
                  FormatDateTime('hh:nn:ss', dtGiven)]));

      //
    aOrder.Fill(aFill.Volume, aFill.Price , aResult);

    aPosition := FTradeCore.Positions.Find(aFill.Account, aFill.Symbol);
    if aPosition = nil then
    begin
      aPosition := FTradeCore.Positions.New(aFill.Account, aFill.Symbol);
      FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
    end;

    aPosition.DoOrder(aOrder.Side, -Abs(aFill.Volume));
    aPosition.AddFill(aFill);

    // investor position
    aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
    aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
    if aInvestPosition = nil then
      aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );
    aInvestPosition.DoOrder( aOrder.Side, -Abs(aFill.Volume) );
    aInvestPosition.AddFill( aFill );

    iType := integer(aOrder.OrderSpecies);

    aFill.Account.ApplyFill( aFill, aFill.Volume, aFill.Price );
    aFill.Account.RecalcMargin;

    aInvestor.ApplyFill( aFill, aFill.Volume, aFill.Price );
    aInvestor.RecalcMargin;

    FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_FILLED);
    FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);
    FDistributor.Distribute(Self, TRD_DATA, aFill, FILL_NEW);

    if FVerbose then
      DoLog('Queues: ' + FTradeCore.Orders.Represent);
  end;
end;

procedure TTradeBroker.Fill(aOrder : TOrder; aFill: TFill);
var
  aPosition : TPosition;
  iType : integer;

  aInvestor : TInvestor;
  aInvestPosition : TPosition;
begin
  aPosition := FTradeCore.Positions.Find( aOrder.Account, aOrder.Symbol );
  if aPosition = nil then
  begin
    aPosition := FTradeCore.Positions.New(aOrder.Account, aOrder.Symbol);
    FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_NEW);
  end;

  aPosition.DoOrder(aOrder.Side, -Abs(aFill.Volume));
  aPosition.AddFill(aFill);

  aInvestor := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  aInvestPosition := FTradeCore.InvestorPositions.Find( aInvestor, aOrder.Symbol );
  if aInvestPosition = nil then
    aInvestPosition := FTradeCore.InvestorPositions.New( aInvestor, aOrder.Symbol );

  aInvestPosition.DoOrder( aOrder.Side, -Abs(aFill.Volume) );
  aInvestPosition.AddFill( aFill );

  iType := integer(aOrder.OrderSpecies);

  aFill.Account.ApplyFill( aFill, aFill.Volume, aFill.Price );
  aFill.Account.RecalcMargin;

  aInvestor.ApplyFill( aFill, aFill.Volume, aFill.Price );
  aInvestor.RecalcMargin;

  FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_FILLED);
  FDistributor.Distribute(Self, TRD_DATA, aFill, FILL_NEW);
  FDistributor.Distribute(Self, TRD_DATA, aPosition, POSITION_UPDATE);

  //aOrder.checkSound;
end;

procedure TTradeBroker.OrderAdded(aOrder: TOrder);
begin
  FDistributor.Distribute(Self, TRD_DATA, aOrder, ORDER_NEW);
end;


procedure TTradeBroker.PositionEvent(aPosition: TPosition;
  aEventID: TDistributorID);
begin
  FDistributor.Distribute(Self, TRD_DATA, aPosition, aEventID);
end;

procedure TTradeBroker.PositionEvent(aInvestPosition: TPosition);
begin
  FDistributor.Distribute(Self, TRD_DATA, aInvestPosition, POSITION_ABLEQTY);
end;

procedure TTradeBroker.PositionEvent(aPosition: TFundPosition;
  aEventID: TDistributorID);
begin
  FDistributor.Distribute(Self, FPOS_DATA, aPosition, aEventID);
end;


procedure TTradeBroker.FundEvent(aData: TObject; aEventID: TDistributorID);
begin
  FDistributor.Distribute(Self, FUND_DATA, aData, aEventID);
end;


end.


