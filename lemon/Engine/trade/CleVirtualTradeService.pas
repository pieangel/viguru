unit CleVirtualTradeService;

interface

uses
  Classes, SysUtils, Windows, Math,  SyncObjs, Forms, DateUtils,
    // lemon: common
  GleTypes,   GleLib,
    // lemon: utils
  CleDistributor,  CleFills, CleQuoteTimers,
    // lemon: data
  CleSymbols, CleOrders, CleTradeBroker, CleTradeCore, CleQuoteBroker;

type
  TVirtualTradeService = class;

  TVirtualTradeFillMode = (fmFillAlways, fmFillOnQuote);

  TVirtualThreadType  = ( vtCommunicator, vtAccept, vtFill, vtFillSend );

  TVirtualTradeReceiverThread = class(TThread)
  private
    FService: TVirtualTradeService;
    FEvent  : TEvent;
    procedure DoService;
    procedure CheckTime;
  protected
    MyType  : TVirtualThreadType;
    constructor Create(aService: TVirtualTradeService);
    procedure Execute; override;
  end;

  TVirtualTradeMarket = class(TCollectionItem)
  private
      // created
    FOrders: TOrderList;
      // assigned
    FSymbol: TSymbol;
    FQuote: TQuote;
      // parameters
    FEnabled: Boolean;
    FAllowAccept: Boolean;
    FAllowFill: Boolean;
    FRejectCode: String;
    FFillMode: TVirtualTradeFillMode;

    FFillNo: Integer;

      // events
    FOnUpdate: TNotifyEvent;
    FOnQuote: TNotifyEvent;
    FOnLog: TTextNotifyEvent;
    FRtFillDelay: integer;
    FPartFill: integer;
    FPartFillEnabled: boolean;
    FPartFillRatio: integer;
    FAceptDelay: integer;
    FFillDelay: integer;
    FCommDelay: integer;
    FTraining : boolean;

    FResultList : TOrderResultList;
    FillMutex : HWND;
    OrderMutex : HWND;
    FNewOrders: TOrderList;

    procedure Accept; overload;
    procedure Accept(aOrder: TOrder; dtAcpt : TDateTime); overload;
    procedure Fill( bQuote : boolean = false );
    procedure FillSend;
    procedure AcceptSend;

    function GetStatusStr: String;

    procedure DoQuote(Sender, Receiver: TObject; DataID: Integer;
      DataObj: TObject; EventID: TDistributorID);
    procedure DoLog(stLog: String);
    procedure MakeOrderResult( bSuc : boolean;   aTarget, aOrder: TOrder; iConfirmQty : integer;aType: TOrderResultType);
    function MakeNormalOrderResult( aOrder: TOrder): TOrderResult;
    procedure MakeFill(aOrder: TOrder); overload;
    procedure MakeFill(aOrder: TOrder; dFillPrice : double; iFillQty : integer); overload;
  public
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    procedure AbortAllOrders;
    procedure FillAllOrders;

      // created
    property Orders: TOrderList read FOrders;
    property NewOrders  : TOrderList read FNewOrders;
      // assigned
    property Symbol: TSymbol read FSymbol;
    property Quote: TQuote read FQuote;
      // parameters
    property AllowAccept: Boolean read FAllowAccept write FAllowAccept;
    property AllowFill: Boolean read FAllowFill write FAllowFill;
    property RejectCode: String read FRejectCode write FRejectCode;
    property FillMode: TVirtualTradeFillMode read FFillMode write FFillMode;

    property CommDelay  : integer read FCommDelay write FCommDelay;
    property AceptDelay : integer read FAceptDelay write FAceptDelay;
    property FillDelay  : integer read FFillDelay write FFillDelay;
    property RtFillDelay: integer read FRtFillDelay write FRtFillDelay;
    property PartFillEnabled  : boolean read FPartFillEnabled write FPartFillEnabled;
    property PartFill   : integer read FPartFill write FPartFill;
    property PartFillRatio  : integer read FPartFillRatio write FPartFillRatio;
    property Training   : boolean read FTraining write FTraining;
      // events
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnQuote: TNotifyEvent read FOnQuote write FOnQuote;
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
      // misc
    property StatusStr: String read GetStatusStr;
  end;

  TVirtualTradeService = class(TCollection)
  private
      // engine objects referred
    FQuoteBroker: TQuoteBroker;
    FTradeBroker: TTradeBroker;
    FTradeCore: TTradeCore;

      // parameters
    FEnabled: Boolean;
    FAllowAccept: Boolean;
    FAllowFill: Boolean;
    FFillMode: TVirtualTradeFillMode;
    FRejectCode: String;

      // assisiting thread
    FReceiverThread: array [TVirtualThreadType] of TVirtualTradeReceiverThread;

      // events
    FOnDelete: TNotifyEvent;
    FOnAdd: TNotifyEvent;
    FOnUpdate: TNotifyEvent;
    FOnRefresh: TNotifyEvent;
    FOnQuote: TNotifyEvent;

    FOnLog: TTextNotifyEvent;

      // copy of event handler
    FSendOrderProc: TSendOrderEvent;
    FPartFillRatio: integer;
    FRtFillDelay: integer;
    FPartFill: integer;
    FPartFillEnabled: boolean;
    FAceptDelay: integer;
    FFillDelay: integer;
    FCommDelay: integer;
    FTraining : boolean;
    FNewOrders: TOrderList;

    function FindMarket(aSymbol: TSymbol): TVirtualTradeMarket;
    function GetMarket(i: Integer): TVirtualTradeMarket;
    procedure MarketLog(Sender: TObject; stLog: String);
    procedure MarketQuote(Sender: TObject);
    procedure MarketUpdate(Sender: TObject);
    procedure SetAllowAccept(const Value: Boolean);
    procedure SetAllowFill(const Value: Boolean);
    procedure SetFillMode(const Value: TVirtualTradeFillMode);
    procedure SetRejectCode(const Value: String);

    procedure CheckTime;
    procedure Accept;
    procedure Fill;
    procedure FillSend;
    procedure AcceptSend;

    function CheckRequiredObjects: Boolean;
    procedure SetTradeCore(const Value: TTradeCore);

    procedure SetEnabled(const Value: Boolean);
    procedure SetQuoteBroker(const Value: TQuoteBroker);
    procedure SetTradeBroker(const Value: TTradeBroker);

    procedure DoLog(stLog: String);
    procedure SetAceptDelay(const Value: integer);
    procedure SetCommDelay(const Value: integer);
    procedure SetFillDelay(const Value: integer);
    procedure SetPartFill(const Value: integer);
    procedure SetPartFillEnabled(const Value: boolean);
    procedure SetPartFillRatio(const Value: integer);
    procedure SetRtFillDelay(const Value: integer);
    procedure SetTraining(const Value: boolean);
  public
    FOrderNo :  integer;
    constructor Create;
    destructor Destroy; override;

    function New(aSymbol: TSymbol): TVirtualTradeMarket;
    function SendOrder(aTicket: TOrderTicket): Integer;

    procedure AbortAllOrders;
    procedure FillAllOrders;

      // referring engine objects
    property QuoteBroker: TQuoteBroker read FQuoteBroker write SetQuoteBroker;
    property TradeBroker: TTradeBroker read FTradeBroker write SetTradeBroker;
    property TradeCore: TTradeCore read FTradeCore write SetTradeCore;
    property NewOrders: TOrderList read FNewOrders;

      // parameters
    property Enabled: Boolean read FEnabled write SetEnabled;
    property AllowAccept: Boolean read FAllowAccept write SetAllowAccept;
    property AllowFill: Boolean read FAllowFill write SetAllowFill;
    property RejectCode: String read FRejectCode write SetRejectCode;
    property FillMode: TVirtualTradeFillMode read FFillMode write SetFillMode;

      //
    property CommDelay  : integer read FCommDelay write SetCommDelay;
    property AceptDelay : integer read FAceptDelay write SetAceptDelay;
    property FillDelay  : integer read FFillDelay write SetFillDelay;
    property RtFillDelay: integer read FRtFillDelay write SetRtFillDelay;
    property PartFillEnabled  : boolean read FPartFillEnabled write SetPartFillEnabled;
    property PartFill   : integer read FPartFill write SetPartFill;
    property PartFillRatio  : integer read FPartFillRatio write SetPartFillRatio;
    property Training   : boolean read FTraining write SetTraining;


      // events
    property OnAdd: TNotifyEvent read FOnAdd write FOnAdd;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
    property OnRefresh: TNotifyEvent read FOnRefresh write FOnRefresh;
    property OnQuote: TNotifyEvent read FOnQuote write FOnQuote;
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;

      // misc
    property Markets[i: Integer]: TVirtualTradeMarket read GetMarket; default;
  end;

implementation

uses GAppEnv, CleKRXTradeReceiver;

{ TVirtualTradeReceiverThread }



constructor TVirtualTradeReceiverThread.Create(aService: TVirtualTradeService);
begin
  inherited Create(False);

  FEvent := TEvent.Create(nil, False, False, 'AcptThread');
  Priority := tpNormal;
  FreeOnTerminate := False;

  FService := aService;
end;

procedure TVirtualTradeReceiverThread.Execute;
begin
  while not Terminated do begin
    WaitForSingleObject(Handle, 10);
    //if not(FEvent.WaitFor(INFINITE) in [wrSignaled]) then
    //  Continue;
    // Synchronize(DoService);
    //Application.ProcessMessages;
  end;
end;

procedure TVirtualTradeReceiverThread.CheckTime;
begin

end;


procedure TVirtualTradeReceiverThread.DoService;
begin

//  case MyType of
//    vtCommunicator: FService.CheckTime;
//    vtAccept: FService.Accept;
//    vtFill:FService.Fill;
//    vtFillSend: FService.FillSend ;
//    else
//      Exit;
//  end;
end;

//--------------------------------------------------------------------------//
                         { TVirtualTradeMarket }
//--------------------------------------------------------------------------//

constructor TVirtualTradeMarket.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FillMutex := CreateMutex(nil, False, PChar('FillMetex'));
  OrderMutex:= CreateMutex(nil, False, PChar('OrderMetex'));
  FResultList := TOrderResultList.Create;
  FOrders := TOrderList.Create;
  FNewOrders:= TOrderList.Create;

  FFillNo := 2000;
end;

destructor TVirtualTradeMarket.Destroy;
begin
  FOnUpdate := nil;
  CloseHandle( FillMutex );
  CloseHandle( OrderMutex );
  FOrders.Free;
  FNewOrders.Free;
  FResultList.Free;
  inherited;
end;

// accept
procedure TVirtualTradeMarket.Accept(aOrder: TOrder; dtAcpt : TDateTime);
var
  aService: TVirtualTradeService;
  aNewOrder: TOrder;
begin
  if aOrder = nil then Exit;

  aOrder.State := osActive;
  aOrder.ActiveQty  := aOrder.OrderQty;
  aOrder.AcptTime   := dtAcpt;
  {
  gEnv.EnvLog(WIN_VIR,Format('Order(%s,%s,%s,%d,%s,%.2f) was accepted as %d st:%d.',
                 [aOrder.OrderTypeDesc, aOrder.Account.Code, aOrder.Symbol.Code,
                  aOrder.OrderQty, aOrder.PriceControlDesc, aOrder.Price,
                  aOrder.OrderNo,  integer(aOrder.State)]));    }

  FOrders.Add(aOrder);
  aOrder.Results.Add(  MakeNormalOrderResult( aOrder ));
    // notify
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
end;

procedure TVirtualTradeMarket.Accept;
var
  i, iIndex, iConfirmQty: Integer;
  aOrder, aTarget: TOrder;
  aMarket: TVirtualTradeMarket;
  dRes : DWORD;
  stLog, stDest, stSrc  : string;
  aDepth : TMarketDepths;
  bOK : boolean;
  aQuote : TQuote;
  acptTime : TDateTime;
  aRes : TOrderResult;
begin
  bOk := false;

  iIndex := 0;

  AcceptSend;

  if NewOrders.Count = 0 then Exit;

  while iIndex <= NewOrders.Count - 1 do
  begin
    aOrder := NewOrders[iIndex];
    if aOrder.State = osSrvAcpt then
    begin
        // process accept
      aQuote   := FQuote;
      acptTime := IncMilliSecond( aOrder.SentTime, aOrder.VirAcptSpan );

      stLog := Format('%s, Qt:%s, At:%s, St:%s, sp : %d, %d', [
        aOrder.Symbol.ShortCode,
        FormatDateTime('hh:nn:ss.zzz', aQuote.LastQuoteTime),
        FormatDateTime('hh:nn:ss.zzz', acptTime),
        FormatDateTime('hh:nn:ss.zzz', aOrder.SentTime ),
        aOrder.VirAcptSpan,
        aOrder.OrderNo
        ] );
      //gEnv.EnvLog( WIN_VIR, stLog);

      if acptTime <= aQuote.LastQuoteTime then
      begin
        // ???? ?????? ????????
        if (aQuote <> nil) and ( aOrder.OrderType <> otCancel ) then begin
          if aOrder.Side > 0 then
            aDepth  := FQuote.Bids
          else
            aDepth  := FQuote.Asks;

          stDest := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]);
          for i := 0 to aDepth.Count-1 do
          begin
            stSrc := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aDepth[i].Price]);
            if (stSrc = stDest ) then begin
              aOrder.IsStayVol  := true;
              aOrder.StayVol    := aDepth[i].Volume;

              bOk := true;
              break;
            end;
          end; // for
        end;
        {
      gEnv.EnvLog( WIN_VIR,
          format('acpt : i:%d, cnt:%d st:%d  qc:%d', [ iIndex, NewOrders.Count, integer(aOrder.State), FQuote.EventCount ])
        );                     }
        Accept(aOrder, acptTime);


      end   // if acptTime <= aQuote.LastQuoteTime then
      else begin
        inc(iIndex);
        Continue;
      end;
    end ;   //if aOrder.State = osSrvAcpt then

    if aOrder.State <> osActive then
    begin
      Inc(iIndex);
      Continue;
    end;
    // ????. ???? ????
    if aOrder.OrderType in [ otCancel, otChange] then
    begin
      iConfirmQty := 0;
      aTarget := NewOrders.FindOrder( aOrder.OriginNo );
      if aTarget = nil then
      begin
        aOrder.RejectCode := '999';
        gEnv.EnvLog(  WIN_VIR,
          format('?????? ???? ???? : %s, %s, %d', [ aOrder.Account.Code, aOrder.Symbol.ShortCode, aOrder.OriginNo] ));

        MakeOrderResult( false, aTarget, aOrder, iConfirmQty, orConfirmed );
        NewOrders.Delete(iIndex);
        Continue;
      end
      else begin

        iConfirmQty := ifThen( aTarget.ActiveQty > aOrder.ActiveQty, aOrder.ActiveQty, aTarget.ActiveQty );
        if iConfirmQty = 0 then
        begin
          aOrder.RejectCode := '999';
          gEnv.EnvLog(  WIN_VIR,
          format('???? ???? ???? ???? : %s, %s, %d, %d, %d(%d)', [ aOrder.Account.Code, aOrder.Symbol.ShortCode,
            aOrder.ActiveQty, aTarget.ActiveQty, aOrder.OrderNo, aOrder.OriginNo] ));
          MakeOrderResult( false, aTarget, aOrder, iConfirmQty, orConfirmed );
          NewOrders.Delete(iIndex);
          Continue;
        end
        else begin
          gEnv.EnvLog(  WIN_VIR,
          format('???? ???? ???? : %s, %s, %d, %d, %d(%d)', [ aOrder.Account.Code, aOrder.Symbol.ShortCode,
            aOrder.ActiveQty, aTarget.ActiveQty, aOrder.OrderNo, aOrder.OriginNo] ));
          MakeOrderResult( true, aTarget, aOrder, iConfirmQty, orConfirmed );
        end;
      end;
    end;
    Inc(iIndex);
  end;

  for I := NewOrders.Count-1 downto 0 do
  begin
    aOrder := NewOrders[i];
    if ((aOrder.ActiveQty = 0 ) and ( aOrder.State = TOrderState(8))) or
      (aOrder.RejectCode <> '' )  then
    begin
      NewOrders.Delete(i);
      //aOrder.Free;
    end;
  end;

end;


procedure TVirtualTradeMarket.MakeOrderResult( bSuc : boolean; aTarget, aOrder : TOrder; iConfirmQty : integer;  aType: TOrderResultType );
var
  aResult : TOrderResult;
  aDepth  : TMarketDepths;
  stDest, stSrc : string;
  i : integer;
begin
  aResult := TOrderResult.Create(nil);

  aResult.Account := aOrder.Account;
  aResult.Symbol := aOrder.Symbol;
  aResult.OrderNo := aOrder.OrderNo;
  aResult.ResultType := aType;
  aResult.Qty :=   iConfirmQty;
  aResult.Price := aOrder.Price;
  aResult.RefNo := 0;
  aResult.RjtCode := aOrder.RejectCode;
  aResult.ResultTime := GetQuoteTime;

  if bSuc then
  begin
    if aOrder.OrderType = otChange then
    begin

      aTarget.ActiveQty := aTarget.ActiveQty -  iConfirmQty;
      aTarget.ConfirmedQty  := iConfirmQty;
      aOrder.OrderType  := aTarget.OrderType;

      if (FQuote <> nil) and ( aOrder.OrderType <> otCancel ) then begin
        if aOrder.Side > 0 then
          aDepth  := FQuote.Bids
        else
          aDepth  := FQuote.Asks;

        stDest := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]);
        for i := 0 to aDepth.Count-1 do
        begin
          stSrc := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aDepth[i].Price]);
          if (stSrc = stDest ) then begin
            aOrder.IsStayVol  := true;
            aOrder.StayVol    := aDepth[i].Volume;
            break;
          end;
        end; // for
      end;
    end
    else if aOrder.OrderType = otCancel then
    begin
      aTarget.ActiveQty := aTarget.ActiveQty -  iConfirmQty;
      aTarget.CanceledQty  := iConfirmQty;
      if aTarget.ActiveQty = 0 then
        aTarget.State := TOrderState(7);

      aOrder.ActiveQty  := 0;
      aOrder.State  :=  TOrderState(8);
    end ;

    if aTarget.ActiveQty <=0  then
      aTarget.State := TOrderState(8);
  end ;

  aOrder.Results.Add( aResult );
  FOrders.Add( aOrder );
  //FResultList.Add( aResult );

end;

// ????????
procedure TVirtualTradeMarket.MakeFill( aOrder : TOrder);
var
  aResult : TOrderResult;
  dPrice  : double;
begin
  aResult := TOrderResult.Create(nil);

  if aOrder.Side > 0 then
    dPrice  := FQuote.Asks[0].Price
  else
    dPrice  := FQuote.Bids[0].Price;

  Inc(FFillNo);

  aResult.Account := aOrder.Account;
  aResult.Symbol := aOrder.Symbol;
  aResult.OrderNo := aOrder.OrderNo;
  aResult.ResultType := orFilled;
  aResult.Qty := aOrder.ActiveQty;
  aResult.Price := dPrice;
  aResult.RefNo := FFillNo;
  aResult.RjtCode := aOrder.RejectCode;
  aResult.ResultTime := GetQuoteTime;

  FResultList.Add( aResult );

  aOrder.ActiveQty := 0;
  aOrder.State  := osFilled;

end;

// ???? ????
procedure TVirtualTradeMarket.MakeFill(aOrder: TOrder; dFillPrice: double;
  iFillQty: integer);
var
  aResult : TOrderResult;
  dPrice  : double;
  iQty : integer;
begin

  iQty  := ifThen(aOrder.ActiveQty < iFillQty, aOrder.ActiveQty, iFillQty );
  aResult := TOrderResult.Create(nil);

  Inc(FFillNo);

  aResult.Account := aOrder.Account;
  aResult.Symbol := aOrder.Symbol;
  aResult.OrderNo := aOrder.OrderNo;
  aResult.ResultType := orFilled;
  aResult.Qty := iQTy;
  aResult.Price := dFillPrice;
  aResult.RefNo := FFillNo;
  aResult.RjtCode := aOrder.RejectCode;
  aResult.ResultTime := GetQuoteTime;

  FResultList.Add( aResult );

  aOrder.ActiveQty  := aOrder.ActiveQty - iQty;
  aORder.FilledQty  := iQty;

  if aOrder.ActiveQty = 0 then
    aOrder.State := osFilled;

end;

function TVirtualTradeMarket.MakeNormalOrderResult(
  aOrder: TOrder): TOrderResult;
begin
  Result := TOrderResult.Create(nil);

  Result.Account := aOrder.Account;
  Result.Symbol := aOrder.Symbol;
  Result.OrderNo := aOrder.OrderNo;
  Result.ResultType := orBooted;
  Result.Qty :=   aOrder.OrderQty;
  Result.Price := aOrder.Price;
  Result.RefNo := 0;
  Result.RjtCode := aOrder.RejectCode;
  Result.ResultTime := GetQuoteTime;
end;


procedure TVirtualTradeMarket.AcceptSend;
var
  I: Integer;
  aOrder , rOrder : TOrder;
  aService: TVirtualTradeService;
  aRes  : TOrderResult;
  dtResult : TDateTime;
begin
  i := 0;
  aService := Collection as TVirtualTradeService;

  while i <= FOrders.Count - 1 do
  begin
    aOrder  := FOrders.Orders[i];
    if FQuote.LastQuoteTime >= aOrder.AcptTime then
    begin

      rOrder  := aService.TradeCore.Orders.Find( aOrder.Account, aOrder.Symbol, aOrder.OrderNo );
      if rOrder = nil then
      begin
        gEnv.EnvLog( WIN_VIR,
          Format('AcceptSend Err  not find real Order %s, %s, %d', [ aOrder.Account.Code, aOrder.Symbol.ShortCode, aOrder.OrderNo ])
        );
        inc(i);
        Continue;
      end;

      rOrder.TradeTime:= FormatDateTime('hhnnsszz', aOrder.AcptTime );
      //aService.FTradeBroker.Accept( rOrder, true, aOrder.RejectCode, aOrder.AcptTime );
      rOrder.Results.Add( aOrder.Results.Results[ aOrder.Results.Count-1 ] )    ;
      aService.FTradeBroker.Confirm( rOrder, aORder.AcptTime );
      gEnv.EnvLog( WIN_VIR,
        Format('AcceptSend : %s, %s, %d (???????? : %s,  ???????? : %s)', [ aOrder.Account.Code, aOrder.Symbol.ShortCode, aOrder.OrderNo,
          FormatDateTime('hh:nn:ss.zzz', FQuote.LastQuoteTime ),
          FormatDateTime('hh:nn:ss.zzz', aOrder.AcptTime )
         ])
      );
      //aOrder.Free;
      FOrders.Delete(i);
      continue;
    end;

    inc(i);
  end;

  i := 0;
  while i <= FResultList.Count-1 do
  begin
    aRes  := FResultList.Results[i];
    dtResult  := IncMilliSecond( aRes.ResultTime, 20);
    if FQuote.LastQuoteTime >= dtResult then
    begin

      case aRes.ResultType of
        orFilled: aService.FTradeBroker.Fill( aRes, GetQuoteTime );
        //orConfirmed: aService.FTradeBroker.Confirm( aRes, GetQuoteTime);
      end;
       {
      gEnv.EnvLog( WIN_VIR,
        Format('ResultSend : %s, %s, %d (%s:%s)', [ aRes.Account.Code, aRes.Symbol.ShortCode, aRes.OrderNo,
          FormatDateTime('hh:nn:ss.zzz', FQuote.LastQuoteTime ),
          FormatDateTime('hh:nn:ss.zzz', aRes.ResultTime )
         ])
      );    }

      FResultList.Delete(i);
      continue;
    end;
    inc(i);
  end;
  
end;

procedure TVirtualTradeMarket.Fill( bQuote : boolean );
var
  i, j, iIndex, iFilled, iActive, iVol, iCalc, iPriorQty, iRemain, iConfirmQty: Integer;
  aOrder,aNewOrder, aTarget : TOrder;
  acptTime : TDateTime;
  aQuote   : TQuote;
  aService: TVirtualTradeService;
  aMarketDepths: TMarketDepths;
  dRes  : DWORD;
  aResult : TOrderResult;
  aFill   : TFill;
  bFilled, bOK : boolean;
  stDest, stSrc, stLog : string;
  aDepth : TmarketDepths;
begin
  ////////////////////////////////////////////////////////////////////////////////////////////

  iIndex := 0;

  AcceptSend;

  if NewOrders.Count = 0 then Exit;

  while iIndex <= NewOrders.Count - 1 do
  begin
    aOrder := NewOrders[iIndex];
    if aOrder.State = osSrvAcpt then
    begin
        // process accept
      aQuote   := FQuote;
      acptTime := IncMilliSecond( aOrder.SentTime, aOrder.VirAcptSpan );

      stLog := Format('%s, ????????:%s, ??????????:%s, ????????????:%s, sp : %d, %d', [
        aOrder.Symbol.ShortCode,
        FormatDateTime('hh:nn:ss.zzz', aQuote.LastQuoteTime),
        FormatDateTime('hh:nn:ss.zzz', acptTime),
        FormatDateTime('hh:nn:ss.zzz', aOrder.SentTime ),
        aOrder.VirAcptSpan,
        aOrder.OrderNo
        ] );
      gEnv.EnvLog( WIN_VIR, stLog);

      if acptTime <= aQuote.LastQuoteTime then
      begin
        // ???? ?????? ????????
        if (aQuote <> nil) and ( aOrder.OrderType <> otCancel ) then begin
          if aOrder.Side > 0 then
            aDepth  := FQuote.Bids
          else
            aDepth  := FQuote.Asks;

          stDest := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]);
          for i := 0 to aDepth.Count-1 do
          begin
            stSrc := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aDepth[i].Price]);
            if (stSrc = stDest ) then begin
              aOrder.IsStayVol  := true;
              aOrder.StayVol    := aDepth[i].Volume;

              bOk := true;
              break;
            end;
          end; // for
        end;
        gEnv.EnvLog( WIN_VIR,
          format('acpt : i:%d, cnt:%d st:%d  qc:%d', [ iIndex, NewOrders.Count, integer(aOrder.State), FQuote.EventCount ])
        );
        Accept(aOrder, acptTime);


      end   // if acptTime <= aQuote.LastQuoteTime then
      else begin
        inc(iIndex);
        Continue;
      end;
    end ;   //if aOrder.State = osSrvAcpt then

    if aOrder.State <> osActive then
    begin
      Inc(iIndex);
      Continue;
    end;
    // ????. ???? ????
    if aOrder.OrderType in [ otCancel, otChange] then
    begin
      iConfirmQty := 0;
      aTarget := NewOrders.FindOrder( aOrder.OriginNo );
      if aTarget = nil then
      begin
        aOrder.RejectCode := '999';
        gEnv.EnvLog(  WIN_VIR,
          format('?????? ???? ???? : %s, %s, %d', [ aOrder.Account.Code, aOrder.Symbol.ShortCode, aOrder.OriginNo] ));

        MakeOrderResult( false, aTarget, aOrder, iConfirmQty, orConfirmed );
        NewOrders.Delete(iIndex);
        Continue;
      end
      else begin

        iConfirmQty := ifThen( aTarget.ActiveQty > aOrder.ActiveQty, aOrder.ActiveQty, aTarget.ActiveQty );
        if iConfirmQty = 0 then
        begin
          aOrder.RejectCode := '999';
          gEnv.EnvLog(  WIN_VIR,
          format('???? ???? ???? ???? : %s, %s, %d, %d, %d(%d)', [ aOrder.Account.Code, aOrder.Symbol.ShortCode,
            aOrder.ActiveQty, aTarget.ActiveQty, aOrder.OrderNo, aOrder.OriginNo] ));
          MakeOrderResult( false, aTarget, aOrder, iConfirmQty, orConfirmed );
          NewOrders.Delete(iIndex);
          Continue;
        end
        else begin
          gEnv.EnvLog(  WIN_VIR,
          format('???? ???? ???? : %s, %s, %d, %d, %d(%d)', [ aOrder.Account.Code, aOrder.Symbol.ShortCode,
            aOrder.ActiveQty, aTarget.ActiveQty, aOrder.OrderNo, aOrder.OriginNo] ));
          MakeOrderResult( true, aTarget, aOrder, iConfirmQty, orConfirmed );
        end;
      end;
    end;

    if aOrder.OrderType <> otNormal then
      Continue;

  /////////////////////////////////////////////////////////////////////////////////////////////
    // ???? ????
    if not bQuote then  // ???? ?????? ????
    begin

      if FQuote.LastQuoteTime < aOrder.AcptTime then
      begin
        inc(iIndex);
        continue;
      end;

      case aOrder.PriceControl of
        pcMarket:
          begin
            gEnv.EnvLog( WIN_VIR, Format('?????????? : %s, %s ', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), aOrder.Represent2])
            );
            MakeFill( aOrder );
            NewOrders.Delete(iIndex);
            Continue;
          end;
        else begin
          if (( aOrder.Side > 0 ) and ( (aOrder.Price+0.001) >= FQuote.Asks[0].Price ) and ( FQuote.Asks[0].Price > 0.01) ) or
            (( aOrder.Side < 0 ) and ( aOrder.Price <= (FQuote.Bids[0].Price+0.001)))  then
          begin
            gEnv.EnvLog( WIN_VIR, Format('?????? ???? ???? ???? : : %s, %s ', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), aOrder.Represent2])
            );
            MakeFill( aOrder );
            NewOrders.Delete(iIndex);
            Continue;
          end;
        end;
      end;

      iPriorQty := aOrder.StayVol - aOrder.AccFill;
      iRemain := 0;

      if aOrder.Side > 0 then
        aDepth  := FQuote.Bids
      else
        aDepth  := FQuote.Asks;

      stDest := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]);
      for i := 0 to aDepth.Count-1 do
      begin
        stSrc := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aDepth[i].Price]);
        if (stSrc = stDest ) then begin
          iRemain := aDepth[i].Volume;
          break;
        end;
      end; // for

      if iRemain < iPriorQty then
      begin
        aOrder.AccFill  := 0;
        aOrder.StayVol  := iRemain;
      end;
      // ?? ???????? ???? ????
    end
    else begin  // ???? ???? ????

      if FQuote.LastQuoteTime < aOrder.AcptTime then
      begin
        inc(iIndex);
        continue;
      end;

      case aOrder.PriceControl of
        pcMarket:
          begin
            gEnv.EnvLog( WIN_VIR, Format('?????????? : %s, %s ', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), aOrder.Represent2])
            );
            MakeFill( aOrder );

            NewOrders.Delete(iIndex);
            Continue;
          end;
        else begin
          if (( aOrder.Side > 0 ) and ( (aOrder.Price+0.001) >= FQuote.Asks[0].Price ) and ( FQuote.Asks[0].Price > 0.01) ) or
            (( aOrder.Side < 0 ) and ( aOrder.Price <= (FQuote.Bids[0].Price+0.001) ))  then
          begin
            gEnv.EnvLog( WIN_VIR, Format('?????? ???? ???? ???? : : %s, %s ', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), aOrder.Represent2])
            );
            MakeFill( aOrder );
            NewOrders.Delete(iIndex);
            Continue;
          end
          else begin
            stDest := Format('%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]);
            stSrc := Format('%.*n', [ aOrder.Symbol.Spec.Precision, FQuote.Last]);
            if stDest = stSrc then
            begin
              aOrder.AccFill  := aOrder.AccFill + FQuote.Sales.Last.Volume;
              if aOrder.AccFill >  aOrder.StayVol then
              begin
                gEnv.EnvLog( WIN_VIR, Format('?????? ???????? ???? ???? ?????? : : %s, %s ',
                [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime), aOrder.Represent2])
                );
                MakeFill( aOrder, FQuote.Last,aOrder.AccFill - aOrder.StayVol  );

              end;
            end; // if stDest = stSrc then
          end;

        end;
      end;

    end;
     Inc(iIndex);
  end;

  for I := NewOrders.Count-1 downto 0 do
  begin
    aOrder := NewOrders[i];
    if ((aOrder.ActiveQty = 0 ) and
      (( aOrder.State = TOrderState(8)) or  ( aOrder.State = TOrderState(7)) or ( aOrder.State = osFilled))) or
      (aOrder.RejectCode <> '' )  then
    begin
      NewOrders.Delete(i);
      //aOrder.Free;
    end;
  end;

end;


procedure TVirtualTradeMarket.FillSend;
begin
end;     

procedure TVirtualTradeMarket.AbortAllOrders;
var
  aService: TVirtualTradeService;
  i: Integer;
  aOrder: TOrder;
begin
{
  aService := Collection as TVirtualTradeService;

  if aService.TradeBroker <> nil then
  begin
    for i := 0 to FOrders.Count - 1 do
    begin
      aOrder := FOrders[i];

      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        aService.TradeBroker.Confirm(
                aService.TradeCore.OrderResults.New(
                  aOrder.Account, aOrder.Symbol, aOrder.OrderNo,
                  orConfirmed, GetQuoteTime, StrToIntDef(FRejectCode, 0),  FRejectCode,
                  aOrder.ActiveQty, 0.0, GetQuoteTime), GetQuoteTime);
          // log
        DoLog(Format('Order# %d for %s has been aborted', [aOrder.OrderNo,
                        aOrder.Symbol.Code]));
      end;
    end;
  end;

    //
  FOrders.Clear;

    // notify
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
  }
end;

procedure TVirtualTradeMarket.FillAllOrders;  {
var
  aService: TVirtualTradeService;
  i: Integer;
  aOrder: TOrder;    }
begin         {
  aService := Collection as TVirtualTradeService;

  if aService.TradeBroker <> nil then
  begin
    for i := 0 to FOrders.Count - 1 do
    begin
      aOrder := FOrders[i];

      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        aService.TradeBroker.Fill(
                aService.TradeCore.OrderResults.New(
                  aOrder.Account, aOrder.Symbol, aOrder.OrderNo,
                  orFilled, GetQuoteTime, FFillNo, '',
                  aOrder.ActiveQty, aOrder.Price, GetQuoteTime), GetQuoteTime);
        Inc(FFillNo);
          // log
        DoLog(Format('Order# %d for %s has been filled', [aOrder.OrderNo,
                        aOrder.Symbol.Code]));
      end;
    end;
  end;

    //
  FOrders.Clear;
  
    // notify
  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
    }
end;



procedure TVirtualTradeMarket.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, stLog);
end;

procedure TVirtualTradeMarket.DoQuote(Sender, Receiver: TObject; DataID: Integer;
    DataObj: TObject; EventID: TDistributorID);
var
  aQuote: TQuote;
begin
  if (FSymbol = nil) or (DataObj = nil) or not (DataObj is TQuote) then Exit;

  aQuote := DataObj as TQuote;

  if aQuote.Symbol <> FSymbol then Exit;

    // fill logic
  if aQuote.LastEvent in [qtMarketDepth, qtTimeNSale] then
  begin
    Fill( aQuote.LastEvent = qtTimeNSale );
  end;

    // notify
  if Assigned(FOnQuote) then
    FOnQuote(Self);
end;

function TVirtualTradeMarket.GetStatusStr: String;
begin
  if FEnabled
     and (FSymbol <> nil)
     and (FQuote <> nil)
     and (FQuote.EventCount > 0) then
  begin
    Result := 'Active'
  end else
    Result := 'Inactive';
end;

//--------------------------------------------------------------------------//
                          { TVirtualTradeService }
//--------------------------------------------------------------------------//

constructor TVirtualTradeService.Create;
begin
  inherited Create(TVirtualTradeMarket);

  FReceiverThread[vtCommunicator] := TVirtualTradeReceiverThread.Create(Self);
  FReceiverThread[vtCommunicator].MyType  := vtCommunicator;

  FReceiverThread[vtAccept] := TVirtualTradeReceiverThread.Create(Self);
  FReceiverThread[vtAccept].MyType  := vtAccept;

  FReceiverThread[vtFill] := TVirtualTradeReceiverThread.Create(Self);
  FReceiverThread[vtFill].MyType  := vtFill;

  FReceiverThread[vtFillSend] := TVirtualTradeReceiverThread.Create(Self);
  FReceiverThread[vtFillSend].MyType  := vtFillSend;

  FOrderNo := 1000;

  FNewOrders:= TOrderList.Create;

end;

destructor TVirtualTradeService.Destroy;
var
  i: Integer;
begin
  if FQuoteBroker <> nil then
    for i := 0 to Count - 1 do
      FQuoteBroker.Cancel(Items[i]);


  FNewOrders.Free;
    // stop thread
  if FReceiverThread[vtCommunicator] <> nil then
  begin
    FReceiverThread[vtCommunicator].Terminate;
    FReceiverThread[vtCommunicator].FEvent.SetEvent;
    FReceiverThread[vtCommunicator].WaitFor;
    FReceiverThread[vtCommunicator].FEvent.Free;
    FReceiverThread[vtCommunicator].Free;
    FReceiverThread[vtCommunicator] := nil;
  end;

    if FReceiverThread[vtAccept] <> nil then
  begin
    FReceiverThread[vtAccept].Terminate;
    FReceiverThread[vtAccept].FEvent.SetEvent;
    FReceiverThread[vtAccept].WaitFor;
    FReceiverThread[vtAccept].FEvent.Free;
    FReceiverThread[vtAccept].Free;
    FReceiverThread[vtAccept] := nil;
  end;

  if FReceiverThread[vtFill] <> nil then
  begin
    FReceiverThread[vtFill].Terminate;
    FReceiverThread[vtFill].FEvent.SetEvent;
    FReceiverThread[vtFill].WaitFor;
    FReceiverThread[vtFill].FEvent.Free;
    FReceiverThread[vtFill].Free;
    FReceiverThread[vtFill] := nil;
  end;

  if FReceiverThread[vtFillSend] <> nil then
  begin
    FReceiverThread[vtFillSend].Terminate;
    FReceiverThread[vtFillSend].FEvent.SetEvent;
    FReceiverThread[vtFillSend].WaitFor;
    FReceiverThread[vtFillSend].FEvent.Free;
    FReceiverThread[vtFillSend].Free;
    FReceiverThread[vtFillSend] := nil;
  end;

  inherited;
end;

function TVirtualTradeService.GetMarket(i: Integer): TVirtualTradeMarket;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TVirtualTradeMarket
  else
    Result := nil;
end;

procedure TVirtualTradeService.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, stLog);
end;

//---------------------------------------------------------------< find & new >

function TVirtualTradeService.FindMarket(aSymbol: TSymbol): TVirtualTradeMarket;
var
  i: Integer;
  aMarket: TVirtualTradeMarket;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aMarket := Items[i] as TVirtualTradeMarket;
    if (aMarket <> nil) and (aMarket.Symbol = aSymbol) then
    begin
      Result := aMarket;
      Break;
    end;
  end;

end;

function TVirtualTradeService.New(aSymbol: TSymbol): TVirtualTradeMarket;
begin
  Result := Add as TVirtualTradeMarket;

  Result.FSymbol := aSymbol;
  Result.FEnabled := FEnabled;
  Result.FAllowAccept := FAllowAccept;
  Result.FAllowFill := FAllowFill;
  Result.FRejectCode := FRejectCode;
  Result.FFillMode := FFillMode;

  Result.FPartFillRatio   := FPartFillRatio;
  Result.FRtFillDelay     := FRtFillDelay;
  Result.FPartFill        := FPartFill;
  Result.FPartFillEnabled := FPartFillEnabled;
  Result.FAceptDelay      := FAceptDelay;
  Result.FFillDelay       := FFillDelay;
  Result.FCommDelay       := FCommDelay;
  Result.FTraining        := FTraining;

  if FQuoteBroker <> nil then
    Result.FQuote := FQuoteBroker.Subscribe(Result, aSymbol, Result.DoQuote);

  Result.FOnUpdate := MarketUpdate;
  Result.FOnQuote := MarketQuote;
  Result.FOnLog := MarketLog;

    // notify
  if Assigned(FOnAdd) then
    FOnAdd(Result);
end;

//------------------------------------------------------------< market events >

procedure TVirtualTradeService.MarketUpdate(Sender: TObject);
begin
  if Assigned(FOnUpdate) then
    FOnUpdate(Sender);
end;

procedure TVirtualTradeService.MarketQuote(Sender: TObject);
begin
  if Assigned(FOnQuote) then
    FOnQuote(Sender);
end;

procedure TVirtualTradeService.MarketLog(Sender: TObject; stLog: String);
begin
  DoLog(stLog);
end;

//------------------------------------------------------------------< control >

procedure TVirtualTradeService.SetEnabled(const Value: Boolean);
var
  i: Integer;
begin
  if not CheckRequiredObjects then Exit;

  FEnabled := Value;

  if FEnabled then
  begin
    FSendOrderProc := FTradeBroker.OnSendOrder;
    FTradeBroker.OnSendOrder := SendOrder;
  end else
  begin
    FTradeBroker.OnSendOrder := FSendOrderProc;
  end;

  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FAllowAccept := FAllowAccept;
end;

procedure TVirtualTradeService.SetAceptDelay(const Value: integer);
var
  i: Integer;
begin
  FAceptDelay := Value;
    for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).AceptDelay := FAceptDelay;
end;

procedure TVirtualTradeService.SetAllowAccept(const Value: Boolean);
var
  i: Integer;
begin
  FAllowAccept := Value;

  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FAllowAccept := FAllowAccept;
end;

procedure TVirtualTradeService.SetAllowFill(const Value: Boolean);
var
  i: Integer;
begin
  FAllowFill := Value;

  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FAllowFill := FAllowFill;
end;

procedure TVirtualTradeService.SetCommDelay(const Value: integer);
var
  i: Integer;
begin
  FCommDelay := Value;
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).CommDelay := FCommDelay;
end;

procedure TVirtualTradeService.SetFillDelay(const Value: integer);
var
  i: Integer;
begin
  FFillDelay := Value;
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FillDelay := FFillDelay;
end;

procedure TVirtualTradeService.SetFillMode(const Value: TVirtualTradeFillMode);
var
  i: Integer;
begin
  FFillMode := Value;

  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FFillMode := FFillMode;
end;

procedure TVirtualTradeService.SetPartFill(const Value: integer);
var
  i: Integer;
begin
  FPartFill := Value;
    for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).PartFill := FPartFill;
end;

procedure TVirtualTradeService.SetPartFillEnabled(const Value: boolean);
var
  i: Integer;
begin
  FPartFillEnabled := Value;
      for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).PartFillEnabled := FPartFillEnabled;
end;

procedure TVirtualTradeService.SetPartFillRatio(const Value: integer);
var
  i: Integer;
begin
  FPartFillRatio := Value;
      for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).PartFillRatio := FPartFillRatio;
end;

procedure TVirtualTradeService.SetTraining(const Value: boolean);
var
  i: Integer;
begin
  FTraining := Value;
      for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FTraining := FTraining;
end;

procedure TVirtualTradeService.SetRejectCode(const Value: String);
var
  i: Integer;
begin
  FRejectCode := Value;

  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FRejectCode := FRejectCode;
end;

procedure TVirtualTradeService.SetRtFillDelay(const Value: integer);
var
  i: Integer;
begin
  FRtFillDelay := Value;
        for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).RtFillDelay := FRtFillDelay;
end;

//--------------------------------------------------------------------< set >

procedure TVirtualTradeService.SetQuoteBroker(const Value: TQuoteBroker);
begin
  FQuoteBroker := Value;
end;

procedure TVirtualTradeService.SetTradeBroker(const Value: TTradeBroker);
begin
  FTradeBroker := Value;
end;

procedure TVirtualTradeService.SetTradeCore(const Value: TTradeCore);
begin
  FTradeCore := Value;
end;



//---------------------------------------------------------------< send order >

function TVirtualTradeService.CheckRequiredObjects: Boolean;
begin
  Result := (FQuoteBroker <> nil)
            and (FTradeBroker <> nil)
            and (FTradeCore <> nil);
end;



function TVirtualTradeService.SendOrder(aTicket: TOrderTicket): Integer;
var
  i: Integer;
  nOrder, aOrder: TOrder;
begin
  Result := 0;

  if not CheckRequiredObjects then Exit;

  for i := 0 to FTradeCore.Orders.NewOrders.Count - 1 do
  begin
    aOrder := FTradeCore.Orders.NewOrders[i];

    if (aOrder.State = osReady) and (aOrder.Ticket = aTicket) then
    begin
      nOrder  := TOrder.Create( nil );
      aOrder.Sent;
      nOrder.Assign( aOrder );
      NewOrders.Add( nOrder );
      gEnv.EnvLog( WIN_VIR,
        format('new order add : %s, %d', [ aOrder.Represent2, NewOrders.Count ])
      );
      Inc(Result);
      CheckTime;
    end;
  end;
end;

procedure TVirtualTradeService.CheckTime;
var
  i, iIndex: Integer;
  aOrder: TOrder;
  aMarket: TVirtualTradeMarket;

  dRes  : DWORD;
  stLog : string;
begin
  if not CheckRequiredObjects then Exit;

  iIndex := 0;

  if NewOrders.Count = 0 then Exit;

  while iIndex <= NewOrders.Count - 1 do
  begin
    aOrder := NewOrders[iIndex];
    if aOrder.State = osSent then
    begin
      aMarket := FindMarket(aOrder.Symbol);
      if aMarket = nil then
        aMarket := New(aOrder.Symbol);

      FOrderNo  := FOrderNo + 1;
      aOrder.OrderNo  := FOrderNo;
      gReceiver.OnSrvAccept( aOrder.LocalNo, aOrder.OrderNo, aOrder.RejectCode );
      gEnv.EnvLog( WIN_VIR,
        format('new order OnSrvAccept : %d, %d, %s, %s, %d', [ aOrder.LocalNo, aOrder.OrderNo, aOrder.RejectCode,
        aOrder.Represent2, NewOrders.Count ])
      );
      aOrder.State  := osSrvAcpt;
      aMarket.NewOrders.Add( aOrder);
      NewOrders.Delete(iIndex);
      Continue;
    end;
    Inc(iIndex);
  end;
end;

procedure TVirtualTradeService.Accept;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).Accept;
end;



procedure TVirtualTradeService.AcceptSend;

var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).AcceptSend;
end;

// called by the thread to make it asynchronized
procedure TVirtualTradeService.Fill;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).Fill;

  //FReceiverThread[vtFillSend].FEvent.SetEvent;
end;

procedure TVirtualTradeService.AbortAllOrders;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).AbortAllOrders;
end;

procedure TVirtualTradeService.FillAllOrders;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FillAllOrders;
end;

procedure TVirtualTradeService.FillSend;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    (Items[i] as TVirtualTradeMarket).FillSend;

end;

end.
