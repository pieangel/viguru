unit CleOrders;

// Copyright(C) Eight Pines Technologies, Inc. All Rights Reserved.

// Order Data Storage: It define the ORDER object and storages of it

interface

uses
  Classes, SysUtils, Windows,

    // lemon: common
  GleLib, GleTypes, CleFills,
    // lemon: data
  CleSymbols, CleAccounts, CleFunds;

type
    // forward declaration
  TOrder = class;
  
    {$REGION ' Comments: Order Type '}
    {
       Normal: an order to take a new position or cover old position
       Change: an order to change the price of all or a part of an previous order.
       Cancel: an order to cancel all or a part of a previous order
    }
    {$ENDREGION}
  TOrderType = (otNormal, otChange, otCancel);

    {$REGION ' Comments: Price Conrol '}
    {
       Limit: buy or sell a contract at a specified price or better.
       Market: buy or sell an asset at the bid or offer price currently available in the marketplace.
       LimitToMarket: work as a LIMIT order but changed into MARKET order at the close of the market
       BestLimit: LIMIT order with the best available 'fillable' price when the order has arrived at the market
    }
    {$ENDREGION}
  TPriceControl = (pcLimit, pcMarket, pcLimitToMarket, pcBestLimit,
                   pcFirstLimit, pcTimeOuter, pcSingle);
                   // 최우선,   시간외(오후), 단일가

    {$REGION ' Comments: Time-To-Market '}
    {
       GTC: Good-till-Canceled, continue to work in the marketplace until
         it executes or is canceled by the customer.
       FOK: Fill-or-Kill, order must execute as a complete order as soon as
         it becomes available on the market, otherwise the order is canceled.
       IOC: Immediate or Canceled, any portion that is not filled immediately
         is cancelled.
       AON: All-or-None, remain at the exchange until the entire quantity is
         available to be executed.
    }
    {$ENDREGION}
  TTimeToMarket = (tmGTC, tmFOK, tmIOC, tmFAS,
                    tmGFD, tmGTD);
                  // GTC : Good Till Cancel ( 취소할때까지 유효 )
                  // FAS : Fill And Store ( 일반적인 주문 )

                  //GFD: Good-for-day
                  //GTC: Good-till-cancelled
                  //GTD: Good-till-date


    {$REGION ' Comments: Order State '}
    {
       Ready: before any action taken
       SrvAcpt: server accepted the order, waiting for reply from the exchange
       SrvRjt: server rejected the order
       Active: the order is registered in the exchange and waiting for the following event
       Rejected: the exchange rejected the order
       Filled: the order was filled all, or partly and the rest canceled
       Canceled: the order was canceled all without any execution(fill)
       Confirmed: the change or cancel order was excuted successfully
       Failed: the change or cancel order failed to execute

     (Scenarios)
       1. NEW order
         Ready -> (SrvRjt | Rejected)
                  (SrvAcpt -> Acitve | Active)-> (Rejected | Filled | Canceled)
             'Active': (Active > 0, Filled >= 0, Canceled >= 0)
             'Filled': (Active = 0, Filled > 0, Canceled >= 0)
             'Canceled': (Active = 0, Filled = 0, Canceled > 0)
       2. CHANGE order
         Ready -> (SrvRjt | Rejected | SrvAcpt -> Rejected)
               -> (SrvAcpt -> Confirmed) ---> spawns a NEW Active order
       3. cancel order
         Ready -> (SrvRjt | Rejected | SrvAcpt -> Rejected)
               -> (SrvAcpt -> Confirmed)
    }
    {$ENDREGION}
  TOrderState = (osReady,
                   // with server
                 osSent, osSrvAcpt, osSrvRjt,
                   // with exchange
                 osActive, osRejected, osFilled, osCanceled,
                 osConfirmed, osFailed);

  TOrderStates  = set of TOrderState;

    {$REGION ' Comments: Order Ticket '}
    {
      An ORDER TICKET is used to identify the sender and and the order group
      so that only the orders the sender has registered are sent at one time.
      Whenver a order window send orders, it should:
        1. issue a ticket
        2. register orders
        3. send orders with the ticket
      The order window can identify the orders sent at different times.
    }
    {$ENDREGION}

  TOrderTicket = class(TCollectionItem)
  private
    FNo: Integer;
    FSender: TObject;
    FScreenNum : integer;
    FStrategyType : TStrategyType;
    FTag: integer;
  public
    function Represent: String;

    property No: Integer read FNo;
    property Sender: TObject read FSender;
    property ScreenNum : integer read FScreenNum;
    property StrategyType : TStrategyType read FStrategyType;
    property Tag : integer read FTag write FTag;
  end;

  TOrderTickets = class(TCollection)
  private
    FLastTicketNo: Integer;
    function GetTicket(i: Integer): TOrderTicket;
  public
    constructor Create;
    function New(aSender: TObject; iNumber : integer = 0; aType : TStrategyType = stNormal): TOrderTicket;
    property Tickets[i: Integer]: TOrderTicket read GetTicket;
  end;

    {$REGION ' Comment: Order Result '}
    {
      TOrderResultType:
        Filled: filled
        Confirmed: before identify the following cases
        ChangedOut: all or part of order volume canceled by a CHANGE order
        CanceledOut: all or part of order volume canceled by a CANCEL order
        Booted: the order itself was canceled in the exchange by some reason

      TOrderResult:
        ...
    }
    {$ENDREGION}
  TOrderResultType = (orFilled, orConfirmed, orChangedOut, orCanceledOut, orBooted);

  TOrderResult = class(TCollectionItem)
  private
    FAccount: TAccount;
    FSymbol: TSymbol;
    FOrderNo: int64;
    FResultType: TOrderResultType;
    FResultTime: TDateTime;
    FRefNo: Integer; // Filled: fill id, ChangedOut/CanceledOut: order id, Booted: reason code
    FQty: Integer;   // unsigned quantity?
    FPrice: Double;
    FSide: integer;
    FSendTerm: DWORD;
    FSent: Boolean;
    FIsChange: boolean;
    FFillTime: string;
    FRjtCode: string;
    procedure SetFillTime(const Value: string);  // fill only
  public
    procedure Assign( pSrc : TOrderResult );
    procedure SetCancelType(aOrderType: TOrderType);
    property Account: TAccount read FAccount write FAccount;
    property Symbol: TSymbol read FSymbol write FSymbol;
    property OrderNo: int64 read FOrderNo write FOrderNo;
    property ResultType: TOrderResultType read FResultType write FResultType;
    property ResultTime: TDateTime read FResultTime write FResultTime;
    property RefNo: Integer read FRefNo write FRefNo;
    property RjtCode : string read FRjtCode write FRjtCode;
    property Qty: Integer read FQty write FQty;
    property Price: Double read FPrice write FPrice;
    property Side  : integer read FSide write FSide;
      // simul
    property SendTerm : DWORD read FSendTerm write FSendTerm;
    property Sent : Boolean read FSent  write FSent;
    property IsChange : boolean read FIsChange write FIsChange;
    property FillTime : string  read FFillTime write SetFillTime;

    procedure Assgin( aRes : TOrderResult );
  end;

  TOrderResultList = class(TList)
  private
    function GetResult(i: Integer): TOrderResult;
    function GetLastResultTime: string;
  public
    property Results[i:Integer]: TOrderResult read GetResult; default;
    property LastResultTime : string read GetLastResultTime;
  end;

  TOrderResults = class(TCollection)
  private
    function GetResult(i: Integer): TOrderResult;
  public
    constructor Create;
    //function Find( iOrderNo : integer; aType: TOrderResultType ) : TOrderResult;
    function New(aAccount: TAccount; aSymbol: TSymbol; iOrderNo: int64;
      aType: TOrderResultType; dtResult: TDateTime; iRefNo: Integer;  stRjtCode : string;
      iQty: Integer; dPrice: Double; dtRecvTime : TDateTime): TOrderResult;
    property Results[i: Integer]: TOrderResult read GetResult; default;
  end;


  TForwardAccept = class(TCollectionItem)
    private
      FAccount : TAccount;
      FSymbol : TSymbol;
      FTargetNo : int64;
      FOrderNo : int64;
      FOrderQty : integer;
      FPrice : double;
      FValue: TOrderType;
      FPriceValue: TPriceControl;
      FAccepted: boolean;
      FRjtCode : string;
      FTradeTime : string;
      FAcceptTime : TDateTime;
    public
      property Accout : TAccount read FAccount;
      property Symbol : TSymbol read FSymbol;
      property TargetNo : int64 read FTargetNo;
      property OrderNo : int64 read FOrderNo;
      property OrderQty : integer read FOrderQty;
      property Price : double read FPrice;
      property Value: TOrderType read FValue;
      property PriceValue: TPriceControl read FPriceValue;
      property Accepted: boolean read FAccepted;
      property RjtCode : string read FRjtCode;
      property TradeTime : string read FTradeTime;
      property AcceptTime : TDateTime read FAcceptTime;
  end;
  TForwardAccepts = class(TCollection)
    private
      function GetForwordAccept( i: integer ) : TForwardAccept;
    public
      constructor Create;
    //function Find( iOrderNo : integer; aType: TOrderResultType ) : TOrderResult;
    function New(aAccount: TAccount; aSymbol: TSymbol; iTargetNo : int64; iOrderNo: int64;  iQty: Integer;
             dPrice: Double; otValue : TOrderType; pvValue: TPriceControl;
             bAccepted: boolean; stRjtCode : string; dtAccept: TDateTime): TForwardAccept;

    procedure Del( iTarget : int64 );
    property Forwards[i: Integer]: TForwardAccept read GetForwordAccept; default;
  end;


    {$REGION ' Comment: Order '}
    {
    }
    {$ENDREGION}
  TOrderEvent = procedure(Order: TOrder) of object;

  TOrder = class(TCollectionItem)
  private
      // (Definition)
    FDealer: String;
    FAccount: TAccount;
    FSymbol: TSymbol;

    FTarget: TOrder; // for otChange/otCancel -- target for change or cancel

    FOrderType: TOrderType;       // Normal/Change/Cancel
    FTimeToMarket: TTimeToMarket; // GTC/FOK/IOC/AON
    FPriceControl: TPriceControl; // Limit/Market/LimitToMarket/BestLimit

    FSide: Integer;       // 1=long, -1=short
    FOrderQty: Integer;   // initial order quantity (unsigned)
    FPrice: Double;
    FFilledPrice : Double;

      // (Transaction)
    FTicket: TOrderTicket;  // issue by the engine
    FOrderNo: int64;      // unique key for this order
    FLocalNo: Integer;      // ID generated by the client

    FActiveQty: Integer;    // for otNormal -- decrease as filled and/or canceled
    FFilledQty: Integer;    // for otNormal -- increase as filled
    FCanceledQty: Integer;  // for otNormal -- increase as canceled
    FConfirmedQty: Integer; // for otChange/otCancel

    FState: TOrderState;  // order status

    FRejectCode: string;    // rejected reason

    FResults: TOrderResultList; // order result: filled/changed/canceled/booted
      // (Tracking)
    FSentTime: TDateTime;
    FAcptTime: TDateTime;
      // (User Info) -- optional
    FCustomID: Integer;
      //
    FOnStateChanged: TOrderEvent;
    FOAsk: boolean;
    FModify: boolean;

    FRealQty: integer;
    FVirSentTime: DWORD;
    FVirAcptTime: DWORD;
    FIsStayVol: Boolean;
    FRemainVol: integer;
    FVirCanceledQty: Integer;
    FVirConfirmedQty: Integer;
    FVirFillQty: Integer;
    FVirActiveQty: Integer;
    FReason: string;
    FAvgPrice: double;
    FOrderSpecies: TOrderSpecies;
    FModifyCnt: integer;
    FGroupNo: string;
    //FAxisIndex: integer;
    FLastQuoteTime: TDateTime;
    FTradeTime: string;
    FOrderTimeType: TOrderTimeType;
    FKrxTime: string;
    FOwnOrder: boolean;
    FAcptLocalTime: TDateTime;
    FMeetLocalTime: TDateTime;
    FLastQuoteCount: integer;
    FMeetQuoteCount: integer;

    FGroupID: integer;
    FFills: TFillList;
    FIsAccept: boolean;
    FOriginNo: int64;
    FVirAcptSpan: integer;
    FAccFill: integer;
    FPrevOrderType: TOrderType;

    FPriceIdx: integer;
    FRatioPer : integer;    //비율양매도에서 세트 구분하기 위해서...
    FOrderTag: integer;
    FTargetIdx: integer;
    FBetweenOrder : boolean;
    FFundName: string;
    FOwnForm: TObject;
    function GetPositionType: TPositionType;
    function GetTimeToMarketDesc: String;
    procedure MarkSentTime;
      // get/set(property) functions
    function GetElapsedTime: DWORD;
    function GetOrderSpeed: DWORD;
    function GetOrderTypeDesc: String;
    function GetPriceControlDesc: String;
    function GetStateDesc: String;
    function GetRealQty: integer;
    function GetLastFillPrice: Double;
    function GetAvgPrice: double;
    procedure SetGroupID(const Value: integer);

  public

    FAcptTimeHR: DWORD;   // high resolution, ms from the Windows start
    FSentTimeHR: DWORD;   // high resolution, ms from the Windows start

    function GetFillDelay : DWORD;
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

      // order result
    procedure Sent;
    procedure SrvAcpt; overload;
    procedure SrvAcpt( iOrderNo : int64 ) ; overload;
      //
    procedure Accept( dtGiven: TDateTime);

    procedure Reject(stRjtCode, stReason: string); overload;
    procedure Reject(stRjtCode: string; dtGiven: TDateTime); overload;
    procedure Reject(iOrdNo: Integer; dtGiven: TDateTime; stRjt: string); overload;
    procedure Reject(iOrdNo, iErrNo: Integer; stRjt: string); overload;

    procedure Confirm(iConfirmedQty: Integer; dtGiven: TDateTime);
    procedure Fail(stRjtCode: string; dtGiven: TDateTime);
    procedure Cancel(iCancelQty: Integer; aResult: TOrderResult);
    procedure Change(iConfirmQty: integer; aResult : TOrderResult);
    procedure Fill(iFilledQty: Integer; dFilledPrice: Double; aResult: TOrderResult);
    procedure VirFill(iFilledQty: Integer; dFilledPrice: Double; aResult: TOrderResult);
    procedure Dead( aResult : TOrderResult );
      //
    function Represent: String;
    function Represent2 : string;
    function Represent3 : string;
    function GetOrderName : string;
    function GetLastResult( orType :TOrderResultType) : TOrderResult;
    procedure checkSound;
    procedure SetTicket( aTicket : TOrderTicket );
      // properties
    property Dealer: String read FDealer;
    property Account: TAccount read FAccount;
    property Symbol: TSymbol read FSymbol;
    property Target: TOrder read FTarget;
    property OwnForm : TObject read FOwnForm write FOwnForm;

    property OrderType: TOrderType read FOrderType write FOrderType;
    // 정정에서만 쓰인다.
    property PrevOrderType: TOrderType read FPrevOrderType write FPrevOrderType;
    property TimeToMarket: TTimeToMarket read FTimeToMarket;
    property PriceControl: TPriceControl read FPriceControl;
    property OrderTimeType : TOrderTimeType read FOrderTimeType write FOrderTimeType;
    property IsAccept : boolean read FIsAccept write FIsAccept;

    property Side: Integer read FSide;
    property OrderQty: Integer read FOrderQty Write FOrderQty;
    property Price: Double read FPrice;
    property FilledPrice: Double read FFilledPrice;
    property PositionType: TPositionType read GetPositionType;
    property AvgPrice : double read FAvgPrice write FAvgPrice;
    //property AxisIndex: integer read FAxisIndex write FAxisIndex;

      // (Transaction)
    property Ticket: TOrderTicket read FTicket;
    property OrderNo: int64 read FOrderNo write FOrderNo;
    property LocalNo: Integer read FLocalNo write FLocalNo;
    property GroupNo: string read FGroupNo write FGroupNo;
      // add by seunge 20121102
    property GroupID: integer read FGroupID write SetGroupID;
    property FundName: string read FFundName write FFundName;

    property ActiveQty: Integer read FActiveQty write FActiveQty;
    property FilledQty: Integer read FFilledQty write FFilledQty;
    property CanceledQty: Integer read FCanceledQty  write FCanceledQty;
    property ConfirmedQty: Integer read FConfirmedQty write FConfirmedQty;
    property RealQty : integer read GetRealQty write FRealQty;
    property OwnOrder: boolean read FOwnOrder write FOwnOrder;

    property State: TOrderState read FState write FState;

    property RejectCode: string read FRejectCode write FRejectCode;

    property Results: TOrderResultList read FResults;
    property Fills  : TFillList  read FFills;
    // *^^*
    // 정정 주문 플래그
    property Modify : boolean read FModify write FModify;
    // 주식에 한해서만 공매도 플래그
    property OAsk   : boolean read FOAsk write FOAsk;

      // (Tracking)
    property SentTime: TDateTime read FSentTime;
    property AcptTime: TDateTime read FAcptTime write FAcptTime;
    property ElapsedTime: DWORD read GetElapsedTime;
    property OrderSpeed: DWORD read GetOrderSpeed;
    property OrderSpecies: TOrderSpecies read FOrderSpecies write FOrderSpecies;
    property ModifyCnt: integer read FModifyCnt write FModifyCnt;

    property LastQuoteTime : TDateTime read FLastQuoteTime write FLastQuoteTime;
    property AcptLocalTime : TDateTime read FAcptLocalTime write FAcptLocalTime;    // 접숙왔을대 로컬타임
    property MeetLocalTime : TDateTime read FMeetLocalTime write FMeetLocalTime;    // 주문과 시세가 만났을때 !! ( 접수된 내 주문이 시세로 날라온시각 )
    property LastQuoteCount: integer read FLastQuoteCount write FLastQuoteCount;
    property MeetQuoteCount: integer read FMeetQuoteCount write FMeetQuoteCount;

    property TradeTime  : string read FTradeTime write FTradeTime;
    property KrxTime: string read FKrxTime write FKrxTime;


      // Simulation
    property VirSentTime : DWORD read FVirSentTime write FVirSentTime;
    property VirAcptTime : DWORD read FVirAcptTime write FVirAcptTime;
    property VirAcptSpan : integer read FVirAcptSpan write FVirAcptSpan;
    property StayVol  : integer read FRemainVol write FRemainVol;
    property AccFill  : integer read FAccFill write FAccFill;
    property IsStayVol: Boolean read FIsStayVol write FIsStayVol;
    property OriginNo : int64   read FOriginNo write FOriginNO;

    property VirFillQty : Integer read FVirFillQty write FVirFillQty;
    property VirActiveQty: Integer read FVirActiveQty write FVirActiveQty;
    property VirCanceledQty: Integer read FVirCanceledQty write FVirCanceledQty ;
    property VirConfirmedQty: Integer read FVirConfirmedQty write FVirConfirmedQty;

      // (User Info) -- optional
    property CustomID: Integer read FCustomID write FCustomID;
      // Description
    property OrderTypeDesc: String read GetOrderTypeDesc;
    property PriceControlDesc: String read GetPriceControlDesc;
    property TimeToMarketDesc: String read GetTimeToMarketDesc;
    property StateDesc: String read GetStateDesc;
    property Reason   : string read FReason write FReason;
    property RatioPer : integer read FRatioPer write FRatioPer;
      // Events
    property OnStateChanged: TOrderEvent read FOnStateChanged write FOnStateChanged;
    property LastFillPrice : Double read GetLastFillPrice; // 최종 체결가

    property PriceIdx : integer read FPriceIdx write FPriceIdx;
    property TargetIdx: integer read FTargetIdx write FTargetIdx;
    property OrderTag : integer read FOrderTag write FOrderTag;
    property BetweenOrder : boolean read FBetweenOrder write FBetweenOrder;

    procedure Assign( aOrder : TOrder );
    procedure SetMeetTime;
    procedure OrderLog;

    function  GetOrderSpecies : string;
  end;

  TOrderList = class(TList)
  private
    function GetOrder(i: Integer): TOrder;
  public
    function GetFilteredList(aList: TStrings; otValue: TOrderType;
      aAccount: TAccount; aSymbol: TSymbol): Integer; overload;
    function GetFilteredList(aList: TStrings; otValue: TOrderStates;
      aAccount: TAccount ): Integer; overload;

    function FindOrder2(iLocalNo: integer): TOrder;

    function FindOrder(iOrderNo: int64): TOrder; overload;
    function FindOrder(otValue: TOrderType; iOrderNo: int64): TOrder; overload;

    // api 주문응답보다..주문접수가 먼저왔을때..
    function FindOrder( stInvestCode : string; aSymbol : TSymbol;
      dPrice : double; iSide, iQty : integer ) : TOrder; overload;
    function FindOrder( stInvestCode : string; aSymbol : TSymbol;
      dPrice : double; iSide, iQty : integer; otValue : TOrderType ) : TOrder; overload;
    function FindOrder( stInvestCode : string; aSymbol : TSymbol; iLocalNo : integer ) : TOrder ; overload;

    procedure SortByAcptTime;
    
    property Orders[i:Integer]: TOrder read GetOrder; default;
  end;

  TOrders = class(TCollection)
  private
      // ticket
    FTickets: TOrderTickets;
    FLastTicket: TOrderTicket;
      // list
    FNewOrders: TOrderList;
    FActiveOrders: TOrderList;
    FClosedOrders: TOrderList;
    FRjtOrders: TOrderList;
      // events
    FOnNew: TOrderEvent;
    FGroupID: integer;
      // Dura
    FTotAcptCnt : integer;
    FTotDuraTime  : Double;
    {
    FActNFillOrders: TOrderList;
    FFillOrders: TOrderList;
    FAFDOrders: TOrderList;
    }


    function New: TOrder;
    function GetOrder(i: Integer): TOrder;
    procedure OrderStateChanged(aOrder: TOrder);
    function GetGroupID: integer;
  public
    constructor Create;
    destructor Destroy; override;

    function New2 : TOrder ;
    function NewNormalOrder(stDealer: String;
      aAccount: TAccount; aSymbol: TSymbol; iOrderQty: Integer;
      pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
      aTicket: TOrderTicket; bRecovery : boolean = false ): TOrder; overload;
    function NewNormalOrder(stDealer: String;
      aAccount: TAccount; aSymbol: TSymbol; iOrderQty: Integer;
      pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket
      ): TOrder; overload;
    function NewChangeOrder(aTarget: TOrder; iChangeQty: Integer;
      pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
      aTicket: TOrderTicket; bRecovery : boolean = false): TOrder;
    function NewCancelOrder(aTarget: TOrder; iCancelQty: Integer;
      aTicket: TOrderTicket; bRecovery : boolean = false): TOrder;

    function NewRecoveryOrder(stDealer: String;
      aAccount: TAccount; aSymbol: TSymbol;iSide : integer; iOrderQty: Integer;
      pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
      aTicket: TOrderTicket; iOrderNo : int64; stGroupID : string='' ): TOrder;
    function Represent: String;

      // nex method
    function NewNormalOrderEx(stDealer: String;
      aAccount: TAccount; aSymbol: TSymbol; iOrderQty: Integer;
      pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
      aTicket: TOrderTicket; bRecovery : boolean = false ): TOrder;
    function NewChangeOrderEx(aTarget: TOrder; iChangeQty: Integer;
      pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
      aTicket: TOrderTicket; bRecovery : boolean = false): TOrder;
    function NewCancelOrderEx(aTarget: TOrder; iCancelQty: Integer;
      aTicket: TOrderTicket; bRecovery : boolean = false): TOrder;

      // search
    function Find(aAccount: TAccount; aSymbol: TSymbol; iOrderNo: int64): TOrder; overload;
    function Find(aAccount: TAccount; aSymbol: string; iOrderNo: int64): TOrder; overload;
    function Find(otValue: TOrderType; iOrderNo: int64): TOrder; overload;
    function FindLocalNo(aAccount: TAccount; aSymbol: TSymbol; iLocalNo: Integer): TOrder;


    function GetFilteredList(aList: TStrings; otValue: TOrderStates;
      aAccount: TAccount ): Integer;

    function FindInvestor( aInvestor : TInvestor; aSymbol : TSymbol; iLocalNo : integer ) : TOrder;
    function FindINvestorOrder( aInvestor : TInvestor; aSymbol : TSymbol; iOrderNo : int64 ) : TOrder;

    procedure OrderReSet;
    procedure DoNotify( aOrder : TORder );

    //Dura
    procedure SetTotDuraTime( aOrder : TOrder );
    function GetTotDuraTime : integer;
      //
    property Orders[i: Integer]: TOrder read GetOrder; default;
    property NewOrders: TOrderList read FNewOrders;
    property ActiveOrders: TOrderList read FActiveOrders;
    property ClosedOrders: TOrderList read FClosedOrders;
    property RjtOrders: TOrderList read FRjtOrders;

    // 주문리스트용 orderlist
    {
    property ActNFilllOrders : TOrderList read FActNFillOrders;
    property FillOrders : TOrderList read FFillOrders;
    property AFDOrders : TOrderList read FAFDOrders;
    }



      //
    property OnNew: TOrderEvent read FOnNew write FOnNew;
      //
    property GroupID : integer read GetGroupID write FGroupID;
  end;


implementation

uses GAppEnv, ClePositions, CleFQN, CleQuoteTimers, CleQuoteBroker;

{$REGION ' TOrderTickets '}
//===========================================================================//
                           { TOrderTicket }
//===========================================================================//

function TOrderTicket.Represent: String;
begin
  if FSender <> nil then
    Result := Format('(#%d,obj)', [FNo])
  else
    Result := Format('(#%d,nil)', [FNo]);
end;

//===========================================================================//
                           { TOrderTickets }
//===========================================================================//

constructor TOrderTickets.Create;
begin
  inherited Create(TOrderTicket);
  // 동부는 200 ~ 99999
  FLastTicketNo := 200;
end;

function TOrderTickets.GetTicket(i: Integer): TOrderTicket;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOrderTicket
  else
    Result := nil;
end;

function TOrderTickets.New(aSender: TObject; iNumber : integer; aType : TStrategyType): TOrderTicket;
begin
  Result := Add as TOrderTicket;

  Inc(FLastTicketNo);
  Result.FNo := FLastTicketNo;
  Result.FSender := aSender;
  Result.FScreenNum := iNumber;
  Result.FStrategyType := aType;
end;

{$ENDREGION}

//===========================================================================//
                               { TOrderResult }
//===========================================================================//

procedure TOrderResult.Assgin(aRes: TOrderResult);
begin
  FAccount:= aRes.FAccount;
  FSymbol:= aRes.FSymbol;
  FOrderNo:= aRes.FOrderNo;
  FResultType:= aRes.FResultType;
  FResultTime:= aRes.ResultTime;
  FRefNo:= aRes.FRefNo; // Filled: fill id, ChangedOut/CanceledOut: order id, Booted: reason code
  FQty:= aRes.FQty;   // unsigned quantity?
  FPrice:= aRes.FPrice;
  FSide:= aRes.FSide;  // fill only
end;

procedure TOrderResult.Assign(pSrc: TOrderResult);
begin
    FAccount:= pSrc.FAccount;
    FSymbol:= pSrc.FSymbol;
    FOrderNo:= pSrc.FOrderNo;
    FResultType:= pSrc.FResultType;
    FResultTime:= pSrc.FResultTime;
    FRefNo:= pSrc.FRefNo; // Filled: fill id, ChangedOut/CanceledOut: order id, Booted: reason code
    FQty:= pSrc.FQty;   // unsigned quantity?
    FPrice:= pSrc.FPrice;
    FSide:= pSrc.FSide;  // fill only
end;

procedure TOrderResult.SetCancelType(aOrderType: TOrderType);
begin
  case aOrderType of
    otNormal: FResultType := orBooted;
    otChange: FResultType := orChangedOut;
    otCancel: FResultType := orCanceledOut;
  end;
end;


procedure TOrderResult.SetFillTime(const Value: string);
begin
  FFillTime := Copy( Value, 1, Length( Value ) -1 );
end;

{$REGION ' TOrderResultList '}
//===========================================================================//
                             { TOrderResultList }
//===========================================================================//

function TOrderResultList.GetLastResultTime: string;
begin
  Result := '';
  if Count > 0 then
    if TOrderResult( Items[Count-1] ).ResultType = orFilled then
      Result := TOrderResult( Items[Count-1] ).FFillTime;

end;

function TOrderResultList.GetResult(i: Integer): TOrderResult;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TOrderResult(Items[i])
  else
    Result := nil;
end;

{$ENDREGION}

{$REGION ' TOrderResults '}
//===========================================================================//
                                { TOrderResults }
//===========================================================================//

constructor TOrderResults.Create;
begin
  inherited Create(TOrderResult);
end;

function TOrderResults.GetResult(i: Integer): TOrderResult;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOrderResult
  else
    Result := nil;
end;

function TOrderResults.New(aAccount: TAccount; aSymbol: TSymbol; iOrderNo: int64;
      aType: TOrderResultType; dtResult: TDateTime; iRefNo: Integer; stRjtCode : string;
      iQty: Integer; dPrice: Double; dtRecvTime : TDateTime): TOrderResult;
begin
  Result := Add as TOrderResult;
  Result.FAccount := aAccount;
  Result.FSymbol := aSymbol;
  Result.FOrderNo := iOrderNo;
  Result.FResultType := aType;
  Result.FQty := iQty;
  Result.FPrice := dPrice;
  Result.FRefNo := iRefNo;
  Result.FRjtCode := stRjtCode;
  Result.ResultTime := dtRecvTime;
end;

{$ENDREGION}

{$REGION ' TOrder '}
//===========================================================================//
                              { TOrder }
//===========================================================================//

constructor TOrder.Create(Coll: TCollection);
begin
  inherited Create(Coll);

  FResults := TOrderResultList.Create;
  FFills   := TFillList.Create;
  FModify  := false;
  FOAsk    := false;
  FModifyCnt:= 0;
  FOrderNo  := -1;
  FOrderSpecies := opNormal;
  //FAxisIndex  := -1;
  FOrderTimeType  := ottJangJung;
  FIsAccept := false;

  FAccFill  := 0;
  FOwnOrder:= true;
  FPriceIdx  := -1;

  FOrderTag:= 0;
  FTargetIdx:=-1;
  FBetweenOrder := false;
  FOwnForm  := nil;
end;

procedure TOrder.Dead(aResult: TOrderResult);
var
  stLog : string;
begin
  if FState in [osCanceled] then
  begin
    FState := osRejected;
    FRejectCode := aResult.RjtCode;
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
    FReason  := gEnv.Engine.ErrCodes.GetCodeDescription( cdTops, FRejectCode);
    stLog := Format( '[ %s ] %s | %s | %d', [FRejectCode, FReason, Represent2, FOrderNo]);
    gLog.Add( lkReject, 'TOrder', 'Dead', stLog, Self  );
  end;
end;


destructor TOrder.Destroy;
begin
  FResults.Free;
  FFills.Free;
  inherited;
end;

//-------------------------------------------------------------< order result >

procedure TOrder.Sent;
begin
  if FState = osReady then
    FState := osSent;
end;

procedure TOrder.SetGroupID(const Value: integer);
begin
  FGroupID := Value;
end;

procedure TOrder.SetMeetTime;
begin
  FMeetLocalTime  := GetQuoteTime;
  FMeetQuoteCount := (FSymbol.Quote as TQuote).EventCount;
  OrderLog;
end;

procedure TOrder.SetTicket(aTicket: TOrderTicket);
begin
  FTicket := aTicket;
  FLocalNo  := aTicket.No;
end;

procedure TOrder.SrvAcpt;
begin
  if FState = osSent then
    FState := osSrvAcpt;
end;

procedure TOrder.SrvAcpt(iOrderNo: int64);
begin
  if FState in [ osReady, osSent] then begin
    FState  := osSrvAcpt;
    FOrderNo:= iOrderNo;
    gEnv.EnvLog( WIN_ORD, format('주문응답 (%d) - %d', [ LocalNo, iOrderNo] )  );
  end
  else begin
    gEnv.EnvLog( WIN_ORD, 'Opps!! ' + intTostr( integer( FState )) + ' , ' + inttostr( iOrderNo )
      + ' ' + inttostr( FOrderNo));
  end;
end;

procedure TOrder.VirFill(iFilledQty: Integer; dFilledPrice: Double;
  aResult: TOrderResult);
begin
  if FState in [osActive] then
    FVirActiveQty := FVirActiveQty - Abs(iFilledQty);
end;

procedure TOrder.Accept( dtGiven: TDateTime);
begin
  if FState in [osReady, osSent, osSrvAcpt] then
  begin
    FState := osActive;
    FActiveQty := FOrderQty;
    FAcptTime := dtGiven;
    FAcptTimeHR := GetMMTime;
    FVirActiveQty  := FOrderQty;
    FIsAccept := true;
    FAcptLocalTime := GetQuoteTime;

    if gEnv.RecoveryEnd then
    begin
      case FOrderType of
        otNormal:
          begin
            if gEnv.OrderSpeed.OrderCount < 1 then
              gEnv.OrderSpeed.AvgAcptTime := OrderSpeed
            else
              gEnv.OrderSpeed.AvgAcptTime :=
                (gEnv.OrderSpeed.AvgAcptTime + OrderSpeed) shr 1;
            inc( gEnv.OrderSpeed.OrderCount );
          end;
        otChange:
          begin
            if gEnv.OrderSpeed.OrderChgCnt < 1 then
              gEnv.OrderSpeed.AvgChgTime := OrderSpeed
            else
              gEnv.OrderSpeed.AvgChgTime :=
                (gEnv.OrderSpeed.AvgChgTime + OrderSpeed) shr 1;
            inc( gEnv.OrderSpeed.OrderChgCnt );
          end;
        otCancel:
          begin
            if gEnv.OrderSpeed.OrderCnlCnt < 1 then
              gEnv.OrderSpeed.AvgCnlTime := OrderSpeed
            else
              gEnv.OrderSpeed.AvgCnlTime :=
                (gEnv.OrderSpeed.AvgCnlTime + OrderSpeed) shr 1;
            inc( gEnv.OrderSpeed.OrderCnlCnt );
          end;
      end;

    end;

      // notify change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
  end;
end;



procedure TOrder.Reject(stRjtCode: string; dtGiven: TDateTime);
var
  stLog : string;
  aType : TCodeDivision;
begin
  //*^^*현물 주문 땜시 osActive 추가...
  if FState in [osReady, osSent, osSrvAcpt, osActive] then
  begin

    FState := osSrvRjt;
    FRejectCode := stRjtCode;
    FModify := false;

    if Target <> nil then
      Target.Modify := false;

      // notify status change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);

    FReason  := gEnv.Engine.ErrCodes.GetCodeDescription( cdTops, FRejectCode);
    stLog := Format( '[ %s ] %s | %s ', [FRejectCode, FReason, Represent2]);
    gLog.Add( lkReject, 'TOrder', 'Reject', stLog, self  );
  end;
end;

procedure TOrder.Confirm(iConfirmedQty: Integer; dtGiven: TDateTime );
begin
  if FState in [ osSrvAcpt ,osActive] then
  begin
    FState := osConfirmed;
    FConfirmedQty := iConfirmedQty;
    FActiveQty := 0;
    FVirActiveQty := 0;
    FModify := false;
      // notify state change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
  end;
end;

procedure TOrder.Fail(stRjtCode: string; dtGiven: TDateTime);
var
  stLog : string;
begin
  if FState in [osSrvAcpt {osActive}] then
  begin
    FState := osFailed;
    FRejectCode := stRjtCode;
    FModify := false;
    if Target <> nil then
      if Target.Modify then
        Target.Modify := false;
      // notify state change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);

    FReason  := gEnv.Engine.ErrCodes.GetCodeDescription( cdTops, FRejectCode);
    stLog := Format( '[ %s ] %s | %s | %d', [FRejectCode, FReason, Represent2, FOrderNO]);
    gLog.Add( lkReject, 'TOrder', 'Fail', stLog, Self  );

  end;
end;

procedure TOrder.Fill(iFilledQty: Integer; dFilledPrice: Double; aResult: TOrderResult);
var
 stLog : string;
 dTmp : double;
begin
  if FState in [osActive] then
  begin
    aResult.Side := FSide;
    FModify := false;
 //   FResults.Add(aResult);

    dTmp := FAvgPrice;
    FActiveQty := FActiveQty - Abs(iFilledQty);
    FFilledQty := FFilledQty + Abs(iFilledQty);
    FFilledPrice := dFilledPrice;

    FVirActiveQty := FVirActiveQty - Abs( iFilledQty );

    FAvgPrice := ( FAvgPrice * (FFilledQty - aResult.Qty) + aResult.Price * aResult.Qty ) / FFilledQty;
    {
    stLog := Format('AVG :%.2f ( %.2f, Qty(%d) , Prive(%.2f), Qty(%d) ) / Qty(%d) ',
        [ FAvgPrice, dTmp, aResult.Qty, aResult.Price, aResult.Qty, fFilledQty]);
    gEnv.OnLog( self, stLog );
     }
    if FActiveQty = 0 then
    begin
      FState := osFilled;
        //
      if Assigned(FOnStateChanged) then
        FOnStateChanged(Self);
    end;
  end;
end;

procedure TOrder.Assign(aOrder: TOrder);
var
  i : integer;
  aRes, aSrc  : TOrderResult;
begin
  FDealer:= aOrder.FDealer  ;
  FAccount:= aOrder.FAccount  ;
  FSymbol:= aOrder.FSymbol  ;

  FTarget:= aOrder.FTarget  ;
  if FTarget = nil then
    FOriginNo := 0
  else
    FOriginNo := FTarget.OrderNo;

  FOrderType:= aOrder.FOrderType  ;
  FTimeToMarket:= aOrder.FTimeToMarket  ;
  FPriceControl:= aOrder.FPriceControl  ;

  FSide:= aOrder.FSide  ;
  FOrderQty:= aOrder.FOrderQty  ;
  FPrice:= aOrder.FPrice  ;
  FFilledPrice := aOrder.FFilledPrice  ;

  FTicket:= aOrder.FTicket  ;
  FOrderNo:= aOrder.FOrderNo  ;
  FLocalNo:= aOrder.FLocalNo  ;

  FActiveQty:= aOrder.FActiveQty  ;
  FFilledQty:= aOrder.FFilledQty  ;
  FCanceledQty:= aOrder.FCanceledQty  ;
  FConfirmedQty:= aOrder.FConfirmedQty  ;

  FState:= aOrder.FState  ;
  FRejectCode:= aOrder.FRejectCode  ;
  //FResults.Assign();
  {
  for i := 0 to aOrder.FResults.Count - 1 do
  begin
    aRes  := TOrderResult.Create(nil);
    aSrc  := TOrderResult( aOrder.FResults.Items[i] );
    aRes.Assign( aSrc );
    FResults.Add( aRes )
  end;
   }
  FSentTime:= aOrder.FSentTime  ;
  FAcptTime:= aOrder.FAcptTime  ;
  FAcptTimeHR:= aOrder.FAcptTimeHR  ;
  FSentTimeHR:= aOrder.FSentTimeHR  ;
  FVirAcptSpan:= aOrder.VirAcptSpan;

  FCustomID:= aOrder.FCustomID  ;
  FOnStateChanged:= aOrder.FOnStateChanged  ;
  FOAsk:= aOrder.FOAsk  ;
  FModify:= aOrder.FModify  ;
  FRealQty:= aOrder.FRealQty  ;
  FBetweenOrder := aOrder.BetweenOrder;
end;


procedure TOrder.Cancel(iCancelQty: Integer; aResult: TOrderResult);
begin
  if FState in [osSrvAcpt, osActive] then
  begin
    aResult.Side := FSide;
    //FResults.Add(aResult);
    FModify := false;
    FActiveQty := FActiveQty - iCancelQty;
    FCanceledQty := FCanceledQty + iCancelQty;

    FVirActiveQty := FVirActiveQty - iCancelQty;

    if FActiveQty = 0 then
    begin
      if FFilledQty > 0 then
        FState := osFilled
      else
        FState := osCanceled;
        // notify
      if Assigned(FOnStateChanged) then
        FOnStateChanged(Self);
    end;
  end;
end;

procedure TOrder.Change(iConfirmQty: integer; aResult: TOrderResult);
begin
  if FState in [ osSrvAcpt ,osActive] then
  begin
    //FResults.Add( aResult );
    FState  := osActive;
    FModify := false;
    FActiveQty := iConfirmQty;
    FConfirmedQty := FConfirmedQty + iConfirmQty;
    FPrevOrderType  := FOrderType;
    FOrderType      := otNormal;

    FAcptTime := aResult.ResultTime;
    FAcptTimeHR := GetMMTime;
    FVirActiveQty  := FOrderQty;
    FIsAccept := true;
    FAcptLocalTime := GetQuoteTime;

    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
    {
    if FActiveQty = 0 then
    begin
      if FConfirmedQty > 0 then
        FState := osConfirmed
      else
        FState := osCanceled;
        // notify
      if Assigned(FOnStateChanged) then
        FOnStateChanged(Self);
    end;
    }
  end;
end;

procedure TOrder.checkSound;
var index : integer;
begin
  case FOrderSpecies of
    opVolStop:
      begin
        if gEnv.FillSnd[FOrderSpecies].IsSound then
          FillSoundPlay(gEnv.FillSnd[FOrderSpecies].FillSnd);
      end ;
  end;
   {
  case Symbol.Spec.Market of
    mtStock: index := 1;
    mtFutures: index := 0;
    mtElw : index := 2;
    else
      Exit;
  end;

  if not gEnv.FillSnd[index].IsSound then Exit;

  FillSoundPlay( gEnv.FillSnd[index].FillSnd );
  }
end;

//-----------------------------------------------------------------< tracking >

procedure TOrder.MarkSentTime;
begin
  FSentTime := GetQuoteTime;
  FSentTimeHR := GetMMTime;
end;


procedure TOrder.OrderLog;
var
  stLog : string;
begin
  ///
  stLog  := Format('Order Time : Acpt (a-%s, al-%s, lq-%s), gap:(%d,%d,%d)  Meet : %s  ( %.2f)',
    [
      FormatDateTime('hh:nn:ss.zzz', AcptTime ),
      FormatDateTime('hh:nn:ss.zzz', AcptLocalTime ),
      FormatDateTime('hh:nn:ss.zzz', LastQuoteTime ),
      GetMSBetween(  AcptTime,  LastQuoteTime ),
      GetMSBetween(  MeetLocalTime,  AcptLocalTime ),
      MeetQuoteCount-LastQuoteCount,
      FormatDateTime('hh:nn:ss.zzz', MeetLocalTime ), FSymbol.DelayMS / 1000
    ]);

  gEnv.EnvLog( WIN_GI, stLog);
end;


function TOrder.GetAvgPrice: double;
var
  i : integer;
  aRes : TOrderResult ;
  dTmp : double;
  stLog : string;
begin
  Result := 0;
  dTmp := 0;
  for i := 0 to Results.Count - 1 do
  begin
    aRes := Results.Results[i];
    if aRes.ResultType = orFilled then
    begin
      dTmp := Result;
      FAvgPrice := ( FAvgPrice * aRes.Qty + aRes.Price * aRes.Qty ) / fFilledQty;
    end;
  end;

end;

function TOrder.GetElapsedTime: DWORD;
begin
  Result := GetMMTime - FSentTimeHR;
end;

function TOrder.GetFillDelay: DWORD;
begin
  Result := GetMMTime - FAcptTimeHR;
end;

function TOrder.GetLastFillPrice: Double;
var
  i : Integer;
  aRes : TOrderResult;
begin
  Result := 0.0;
  //
  for i:=FResults.Count-1 to 0 do  begin
    aRes  :=  FResults.Results[i];
    if aRes.ResultType = orFilled then  begin
      Result := aRes.Price;
      Break;
    end;
  end;

end;

function TOrder.GetLastResult(orType: TOrderResultType): TOrderResult;
var i : integer;
begin
  i := FResults.Count-1;
  Result := FResults.Results[i];

  if Result = nil then
    Exit;
{
  if Result.FResultType <> orType then
    Result := nil;
 }
end;

function TOrder.GetOrderName: string;
begin
  case FSide of
    1 : Result := '매수';
    -1: Result := '매도';
  end;

  case FOrderType of
    otNormal:
      begin
        if FPrevOrderType = otChange then
          Result := Result + '정정'
        else
          Result := Result + '주문';
      end;
    otChange: Result := Result + '정정';
    otCancel: Result := Result + '취소';
  end;


  
end;

function TOrder.GetOrderSpecies: string;
begin
  case FOrderSpecies of
    opNormal: Result := 'Normal';
    opVolStop: Result := '잔량스탑';
    //opFrontQt:Result := 'FrontQt' ;
    opProtecte: Result := 'Protecte';
    //opSmartClear: Result := 'SmartClear';
    opBull: Result := 'Bull';
    //opBear: Result := 'Bear';
    //opSCatch : Result := 'S Catch';
    opStrangle : Result := 'Strangle';
    opYH : Result := 'YH';
    opRatio : Result := 'Ratio';
    opStrangle2 : Result := 'Strangle';
    opInvestor : Result := 'Investor';
  end;

  if not FOwnOrder then
    Result := 'ω ' +Result;
end;

function TOrder.GetOrderSpeed: DWORD;
begin
  Result := FAcptTimeHR - FSentTimeHR;
end;

function TOrder.GetOrderTypeDesc: String;
begin
  case FOrderType of
    otNormal:
        if FSide > 0 then
          Result := 'Buy'
        else
          Result := 'Sell';
    otChange: Result := 'Change';
    otCancel: Result := 'Cancel';
  end;
end;

function TOrder.GetPositionType: TPositionType;
begin
  if FSide > 0 then
    Result := ptLong
  else
    Result := ptShort;
end;

function TOrder.GetPriceControlDesc: String;
begin
  case FPriceControl of
    pcLimit:         Result := 'Limit';
    pcMarket:        Result := 'Market';
    pcLimitToMarket: Result := 'Limit to Market';
    pcBestLimit  :   Result := 'Best Limit';
  end;
end;

function TOrder.GetRealQty: integer;
begin
  if FActiveQty = 0 then
    Result := FOrderQty - FConfirmedQty - FCanceledQty - FFilledQty
  else
    Result := FActiveQty;
end;

function TOrder.GetTimeToMarketDesc: String;
begin
  case FTimeToMarket of
    tmGTC: Result := 'GTC';
    tmFOK: Result := 'FOK';
    tmIOC: Result := 'IOC';
    tmFAS: Result := 'FAS';
  end;
end;

function TOrder.GetStateDesc: String;
begin
  case FState of
    osReady:     Result := 'Ready';
    osSent:      Result := 'Sent';
    osSrvAcpt:   Result := 'Server Accepted';
    osSrvRjt:    Result := 'Server Rjected';
    osActive:    Result := 'Active';
    osRejected:  Result := 'Rejected';
    osFilled:    Result := 'Filled';
    osCanceled:  Result := 'Canceled';
    osConfirmed: Result := 'Confirmed';
    osFailed:    Result := 'Failed';
  end;
end;


procedure TOrder.Reject(iOrdNo: Integer; dtGiven: TDateTime; stRjt: string);
var
  stLog : string;
  aType : TCodeDivision;
begin
  //*^^*현물 주문 땜시 osActive 추가...
  if FState in [osReady, osSent, osSrvAcpt, osActive] then
  begin

    FState := osRejected;
    FRejectCode := stRjt;
    FModify := false;
    FOrderNo  := iOrdNo;

    if Target <> nil then
      Target.Modify := false;
      
      // notify status change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
    FReason  := gEnv.Engine.ErrCodes.GetCodeDescription( cdTops, FRejectCode);
    stLog := Format( '[ %s ] %s | %s ', [FRejectCode, FReason, Represent2]);
    gLog.Add( lkReject, 'TOrder', 'Reject', stLog, self  );
  end;
end;

procedure TOrder.Reject(iOrdNo, iErrNo: Integer; stRjt: string);
var
  stLog : string;
  aType : TCodeDivision;
begin
  //*^^*현물 주문 땜시 osActive 추가...
  if FState in [osReady, osSent, osSrvAcpt, osActive] then
  begin

    FState := osRejected;
    FRejectCode := IntToStr(iErrNo);
    FModify := false;
    FOrderNo  := iOrdNo;

    if Target <> nil then
      Target.Modify := false;
      
      // notify status change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
    FReason  := stRjt;//gEnv.Engine.ErrCodes.GetCodeDescription( cdTops, FRejectCode);
    stLog := Format( '[ %s ] %s | %s ', [FRejectCode, FReason, Represent2]);
    gLog.Add( lkReject, 'TOrder', 'Reject', stLog, self  );
  end;

end;

procedure TOrder.Reject(stRjtCode, stReason: string);
var
  stLog : string;
  aType : TCodeDivision;
begin
  //*^^*현물 주문 땜시 osActive 추가...
  if FState in [osReady, osSent, osSrvAcpt, osActive] then
  begin

    FState := osRejected;
    FRejectCode := stRjtCode;
    FModify := false;
    FReason  := stReason;

    if Target <> nil then
      Target.Modify := false;
      // notify status change
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);

    stLog := Format( '[ %s ] %s | %s ', [FRejectCode, FReason, Represent2]);
    gLog.Add( lkReject, 'TOrder', 'Reject', stLog, self  );
  end;

end;

function TOrder.Represent: String;
begin
  Result := Format('(%s,%s,%s', [FDealer, FAccount.Code, FSymbol.Code])
            + Format(',%s,%s,%s', [OrderTypeDesc, TimeToMarketDesc, PriceControlDesc])
            + Format(',%d,%d,%.4f', [FSide, FOrderQty, FPrice])
            + Format(',%d,%d,%s,%s', [FOrderNo, FLocalNo, FRejectCode, StateDesc])
            + Format(',%d:%d:%d:%d', [FActiveQty, FFilledQty, FCanceledQty, FConfirmedQty])
            + Format(',%s,%s,%d,%d', [
                  FormatDateTime('hh:nn:ss', FSentTime),
                  FormatDateTime('hh:nn:ss', FAcptTime),
                  FAcptTimeHR, FSentTimeHR]);
  if FTarget <> nil then
    Result := Result + Format(',N/X#%d', [FTarget.OrderNo]);
  if FTicket <> nil then
    Result := Result + Format(',Tkt#%d', [FTicket.No]);
  Result := Result + Format(',R:%d,C#%d)', [FResults.Count,FCustomID]);
end;


function TOrder.Represent2: string;
begin
  Result := Format('(%s,%s,%s', [FDealer, FAccount.Code, FSymbol.Code])
            + Format(',%s,%s,%s', [OrderTypeDesc, TimeToMarketDesc, PriceControlDesc])
            + Format(',%d,%d,%.4f,%d,%d,%d', [FSide, FOrderQty, FPrice, FOrderNo,FLocalNo, integer(FState)])
end;

function TOrder.Represent3: string;
begin
  Result :=  Format('(%s, %s ', [ FAccount.Code, FSymbol.ShortCode]) + GetOrderName +
      Format('%d(%d), %s, %d', [ FActiveQty, FOrderQty,  FSymbol.PriceToStr( Price ), FOrderNo ]) +
      GetStateDesc  ;
end;

{$ENDREGION}

{$REGION ' TOrderList '}
//===========================================================================//
                              { TOrderList }
//===========================================================================//

function TOrderList.FindOrder(iOrderNo: int64): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aOrder := TOrder(Items[i]);
    if aOrder.OrderNo = iOrderNo then
    begin
      Result := aOrder;
      Break;
    end;
  end;
end;

function TOrderList.FindOrder(otValue: TOrderType; iOrderNo: int64): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aOrder := TOrder(Items[i]);
    if (aOrder.OrderType = otValue) and (aOrder.OrderNo = iOrderNo) then
    begin
      Result := aOrder;
      Break;
    end;
  end;
end;

function TOrderList.FindOrder(stInvestCode: string; aSymbol: TSymbol;
  dPrice: double; iSide, iQty: integer): TOrder;
var
  I: Integer;
  aOrder : TOrder;
  stPrice, stCmpPrice ,stCode : string;

begin
  Result := nil;
  stPrice := Format('%.*f',[ aSymbol.Spec.Precision, dPrice + 0.0 ]);
  for I := 0 to Count - 1 do
  begin
    aOrder  := TOrder( Items[i] );
    if (aOrder.OrderNo < 0 ) and ( aOrder.State in [ osReady, osSent]) then
    begin

      stCmpPrice := Format('%.*f',[ aSymbol.Spec.Precision, aOrder.Price + 0.0 ]);

      if (aOrder.Side = iSide ) and
        ( aOrder.OrderQty = iQty ) and
        ( aOrder.Account.InvestCode = stInvestCode ) and
        ( aOrder.Symbol = aSymbol ) and
        ( CompareStr( stPrice, stCmpPrice ) = 0 ) then
        begin
          Result := aOrder;
          break;
        end;
    end;

  end;
end;

function TOrderList.FindOrder(stInvestCode: string; aSymbol: TSymbol;
  dPrice: double; iSide, iQty: integer; otValue: TOrderType): TOrder;
var
  I: Integer;
  aOrder : TOrder;
  stPrice, stCmpPrice ,stCode : string;

begin
  Result := nil;
  stPrice := Format('%.*f',[ aSymbol.Spec.Precision, dPrice + 0.0 ]);
  for I := 0 to Count - 1 do
  begin
    aOrder  := TOrder( Items[i] );
    if (aOrder.OrderNo < 0 ) and ( aOrder.State in [ osReady, osSent]) then
    begin

      stCmpPrice := Format('%.*f',[ aSymbol.Spec.Precision, aOrder.Price + 0.0 ]);

      if (aOrder.Side = iSide ) and
        ( aOrder.OrderQty = iQty ) and
        ( aOrder.Account.InvestCode = stInvestCode ) and
        ( aOrder.Symbol = aSymbol ) and
        ( CompareStr( stPrice, stCmpPrice ) = 0 ) and
        ( otValue = aOrder.OrderType ) then
        begin
          Result := aOrder;
          break;
        end;
    end;

  end;

end;

function TOrderList.FindOrder(stInvestCode: string; aSymbol: TSymbol;
  iLocalNo: integer): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aOrder := TOrder(Items[i]);
    if (aOrder.LocalNo = iLocalNo) and ( aOrder.Symbol = aSymbol ) and
       (aOrder.Account.InvestCode = stInvestCode ) and ( aOrder.State in [ osReady, osSent]) then
    begin
      Result := aOrder;
      Break;
    end;
  end

end;

function TOrderList.FindOrder2(iLocalNo: integer): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aOrder := TOrder(Items[i]);
    if (aOrder.LocalNo = iLocalNo) then
    begin
      Result := aOrder;
      Break;
    end;
  end

end;

function TOrderList.GetFilteredList(aList: TStrings; otValue: TOrderType;
  aAccount: TAccount; aSymbol: TSymbol): Integer;
var
  i: Integer;
  aOrder: TOrder;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aOrder := GetOrder(i);

    if (aOrder.OrderType = otValue)
       and (aOrder.Account = aAccount)
       and (aOrder.Symbol = aSymbol) then
    begin
      aList.AddObject(IntToStr(aOrder.OrderNo), aOrder);
    end;
  end;
end;

function TOrderList.GetFilteredList(aList: TStrings; otValue: TOrderStates;
  aAccount: TAccount): Integer;
var
  i: Integer;
  aOrder: TOrder;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aOrder := GetOrder(i);

    if (aOrder.State in otValue)
       and (aOrder.Account = aAccount) then
    begin
      aList.AddObject(IntToStr(aOrder.OrderNo), aOrder);
    end;
  end;

end;

function TOrderList.GetOrder(i: Integer): TOrder;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := TOrder(Items[i])
  else
    Result := nil;
end;

function CompareAcptTime(Data1, Data2: Pointer): Integer;
var
  Order1: TOrder absolute Data1;
  Order2: TOrder absolute Data2;
begin
  if Order1.AcptTime > Order2.AcptTime then
    Result := 1
  else if Order1.AcptTime < Order2.AcptTime then
    Result := -1
  else
    Result := 0;
end;

procedure TOrderList.SortByAcptTime;
begin
  Sort(CompareAcptTime);
end;

{$ENDREGION}


//===========================================================================//
                                { TOrders }
//===========================================================================//

constructor TOrders.Create;
begin
  inherited Create(TOrder);

  FNewOrders := TOrderList.Create;
  FActiveOrders := TOrderList.Create;
  FClosedOrders := TOrderList.Create;
  FRjtOrders := TOrderList.Create;
  {
  FActNFillOrders := TOrderList.Create;
  FFillOrders := TOrderList.Create;
  FAFDOrders := TOrderList.Create;
  }
  FGroupID  := 0;
  FTotAcptCnt := 0;
  FTotDuraTime := 0;
end;

destructor TOrders.Destroy;
begin
  FNewOrders.Free;
  FActiveOrders.Free;
  FClosedOrders.Free;
  FRjtOrders.Free;
  {
  FActNFillOrders.Free;
  FFillOrders.Free;
  FAFDOrders.Free;
   }
  inherited;
end;

procedure TOrders.DoNotify( aOrder : TORder );
begin
  if Assigned(FOnNew) then
    FOnNew(aOrder);
end;

//---------------------------------------------------------------< new orders >

function TOrders.New: TOrder;
begin
  Result := Add as TOrder;
  Result.FOnStateChanged := OrderStateChanged;
end;

function TOrders.New2: TOrder;
begin
  Result := Add as TOrder;
  Result.FOnStateChanged := OrderStateChanged;
end;

function TOrders.NewNormalOrder(stDealer: String; aAccount: TAccount;
  aSymbol: TSymbol; iOrderQty: Integer; pcValue: TPriceControl; dPrice: Double;
  tmValue: TTimeToMarket; aTicket: TOrderTicket; bRecovery : boolean): TOrder;
  var
  aQuote : TQuote;
  stLog : string;
begin
  Result := nil;

  if (aAccount = nil) or (aSymbol = nil) or (iOrderQty = 0) then Exit;

  Result := New;

  Result.FDealer := stDealer;
  Result.FAccount := aAccount;
  Result.FSymbol := aSymbol;

  Result.FTarget := nil;

  Result.FOrderType := otNormal;
  Result.FPriceControl := pcValue;
  Result.FTimeToMarket := tmValue;

  Result.FOrderQty := Abs(iOrderQty);
  Result.FSide := iOrderQty div Result.FOrderQty;
  Result.FPrice := dPrice;

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo ;

  if bRecovery then begin
    Result.FState := osSent;
  end
  else begin
    Result.FState := osReady;
  end;

  Result.FOrderNo := -1;

  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;

  Result.FRejectCode := '';

  Result.FAcptTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

  Result.FCustomID := -1;

  aQuote  := aSymbol.Quote as TQuote;
  if aQuote <> nil then
  begin
    //Result.AxisIndex  := aQuote.PriceAxis.FindIndex(dPrice);
    Result.LastQuoteTime  := aQuote.LastQuoteTime;
    {
    stLog := Format('Order( %.2f) : now : %s ( %s ), %d', [
      Result.Price,
      FormatDateTime('hh:nn:ss.zzz', now),
      FormatDateTime('hh:nn:ss.zzz', Result.LastQuoteTime),
      Result.OrderQty
      ]);
    gEnv.DoLog( WIN_TEST, stLog);
    }
  end;
    // add to the queue
  FNewOrders.Add(Result);

    // notify
  if Assigned(FOnNew) then
    FOnNew(Result);
end;

function TOrders.NewRecoveryOrder(stDealer: String; aAccount: TAccount;
  aSymbol: TSymbol; iSide : integer; iOrderQty: Integer; pcValue: TPriceControl; dPrice: Double;
  tmValue: TTimeToMarket; aTicket: TOrderTicket; iOrderNo: int64; stGroupID : string): TOrder;
  var
  pPos : TPosition;
  bAsk : boolean;
begin
  Result := nil;

  if (aAccount = nil) or (aSymbol = nil) then Exit;

  Result := New;

  Result.FDealer := stDealer;
  Result.FAccount := aAccount;
  Result.FSymbol := aSymbol;

  Result.FTarget := nil;

  Result.FOrderType := otNormal;
  Result.FPriceControl := pcValue;
  Result.FTimeToMarket := tmValue;

  Result.FOrderQty := Abs(iOrderQty);
  Result.FSide := iSide;
  Result.FPrice := dPrice;

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo;

  Result.FOrderNo := iOrderNo ;

  Result.GroupNo := stGroupID;

  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;

  Result.FState := osSent;

  Result.FRejectCode := '';

  Result.FAcptTime := 0;
  Result.FSentTime := 0;
    // add to the queue
  FNewOrders.Add(Result);

    // notify
  if Assigned(FOnNew) then
    FOnNew(Result);

end;


function TOrders.NewChangeOrder(aTarget: TOrder; iChangeQty: Integer;
  pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
  aTicket: TOrderTicket; bRecovery : boolean): TOrder;
  var
    aQuote : TQuote;
    stLog : string;
begin
  Result := nil;

  if (aTarget = nil)
     or (aTarget.State <> osActive)
     or (iChangeQty <= 0) then Exit;

  Result := New;

  Result.FDealer  := aTarget.Dealer;
  Result.FAccount := aTarget.Account;
  Result.FSymbol  := aTarget.Symbol;

  Result.FTarget := aTarget;

  Result.FOrderType := otChange;
  Result.FPriceControl := pcValue;
  Result.FTimeToMarket := tmGTC; // default: Good-till-cancel

  Result.FOrderQty := Abs(iChangeQty);
  Result.FSide := aTarget.Side;
  Result.FPrice := dPrice;

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo ;

  if bRecovery then begin
    Result.FState := osSent;
  end
  else begin           
    Result.FState := osReady;
  end;

  Result.FOrderNo := -1;

  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;    

  Result.FRejectCode := '';

  Result.FAcptTime := 0;
  Result.FSentTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

    // client info
  Result.FCustomID := aTarget.CustomID;
  Result.FOAsk := aTarget.OAsk;
  Result.Target.Modify := true;

  aQuote  := Result.FSymbol.Quote as TQuote;
  if aQuote <> nil then
  begin
    //Result.AxisIndex  := aQuote.PriceAxis.FindIndex(dPrice);
    Result.LastQuoteTime  := aQuote.LastQuoteTime;
    {
    stLog := Format('change( %.2f) : now : %s ( %s ), %d', [
      Result.Price,
      FormatDateTime('hh:nn:ss.zzz', now),
      FormatDateTime('hh:nn:ss.zzz', Result.LastQuoteTime),
      Result.OrderQty
      ]);
    gEnv.DoLog( WIN_TEST, stLog);
    }
  end;

  if aTarget <> nil then
  begin
    Result.GroupNo  := aTarget.GroupNo;
    Result.GroupID  := aTarget.GroupID;
    Result.FundName := aTarget.FundName;
  end;
    // add to the queue
  FNewOrders.Add(Result);

    // notify
  if Assigned(FOnNew) then
    FOnNew(Result);
end;

function TOrders.NewChangeOrderEx(aTarget: TOrder; iChangeQty: Integer;
  pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
  aTicket: TOrderTicket; bRecovery: boolean): TOrder;
  var
    aQuote : TQuote;
    stLog : string;
begin
  Result := nil;

  if (aTarget = nil)
     or (aTarget.State <> osActive)
     or (iChangeQty <= 0) then Exit;

  Result := New;

  Result.FDealer  := aTarget.Dealer;
  Result.FAccount := aTarget.Account;
  Result.FSymbol  := aTarget.Symbol;

  Result.FTarget := aTarget;

  Result.FOrderType := otChange;
  Result.FPriceControl := pcValue;
  Result.FTimeToMarket := tmGTC; // default: Good-till-cancel

  Result.FOrderQty := Abs(iChangeQty);
  Result.FSide := aTarget.Side;
  Result.FPrice := dPrice;

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo ;

  if bRecovery then begin
    Result.FState := osSent;
  end
  else begin           
    Result.FState := osReady;
  end;

  Result.FOrderNo := -1;

  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;    

  Result.FRejectCode := '';

  Result.FAcptTime := 0;
  Result.FSentTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

    // client info
  Result.FCustomID := aTarget.CustomID;
  Result.FOAsk := aTarget.OAsk;
  Result.Target.Modify := true;

  aQuote  := Result.FSymbol.Quote as TQuote;
  if aQuote <> nil then
  begin
    //Result.AxisIndex  := aQuote.PriceAxis.FindIndex(dPrice);
    Result.LastQuoteTime  := aQuote.LastQuoteTime;
    {
    stLog := Format('change( %.2f) : now : %s ( %s ), %d', [
      Result.Price,
      FormatDateTime('hh:nn:ss.zzz', now),
      FormatDateTime('hh:nn:ss.zzz', Result.LastQuoteTime),
      Result.OrderQty
      ]);
    gEnv.DoLog( WIN_TEST, stLog);
    }
  end;



  if aTarget <> nil then
  begin
    Result.GroupNo  := aTarget.GroupNo;
    Result.GroupID  := aTarget.GroupID;
  end;
    // add to the queue
  FNewOrders.Add(Result);

end;

function TOrders.NewNormalOrder(stDealer: String; aAccount: TAccount;
  aSymbol: TSymbol; iOrderQty: Integer; pcValue: TPriceControl; dPrice: Double;
  tmValue: TTimeToMarket): TOrder;
  var
    aQuote : TQuote;
    stLog : string;
begin
  Result := nil;

  if (aAccount = nil) or (aSymbol = nil) or (iOrderQty = 0) then Exit;

  Result := New;

  Result.FDealer := stDealer;
  Result.FAccount := aAccount;
  Result.FSymbol := aSymbol;

  Result.FTarget := nil;

  Result.FOrderType := otNormal;
  Result.FPriceControl := pcValue;
  Result.FTimeToMarket := tmValue;

  Result.FOrderQty := Abs(iOrderQty);
  Result.FSide := iOrderQty div Result.FOrderQty;
  Result.FPrice := dPrice;
  Result.FState := osReady;
  Result.FOrderNo := -1;

  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;

  Result.FRejectCode := '';

  Result.FAcptTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

  aQuote  := aSymbol.Quote as TQuote;
  if aQuote <> nil then
  begin
    //Result.AxisIndex  := aQuote.PriceAxis.FindIndex(dPrice);
    Result.LastQuoteTime  := aQuote.LastQuoteTime;
    {
    stLog := Format('Order : %s ( %s )', [
      FormatDateTime('hh:nn:ss.zzz', now),
      FormatDateTime('hh:nn:ss.zzz', Result.LastQuoteTime)
      ]);
    gEnv.DoLog( WIN_TEST, stLog);
    }
  end;


  Result.FCustomID := -1;
  Result.OAsk := false;
    // add to the queue


end;

function TOrders.NewNormalOrderEx(stDealer: String; aAccount: TAccount;
  aSymbol: TSymbol; iOrderQty: Integer; pcValue: TPriceControl; dPrice: Double;
  tmValue: TTimeToMarket; aTicket: TOrderTicket; bRecovery: boolean): TOrder;
  var
  aQuote : TQuote;
  stLog : string;
begin
  Result := nil;

  if (aAccount = nil) or (aSymbol = nil) or (iOrderQty = 0) then Exit;

  Result := New;

  Result.FDealer := stDealer;
  Result.FAccount:= aAccount;
  Result.FSymbol := aSymbol;

  Result.FTarget := nil;

  Result.FOrderType := otNormal;
  Result.FPriceControl := pcValue;
  Result.FTimeToMarket := tmValue;

  Result.FOrderQty := Abs(iOrderQty);
  Result.FSide := iOrderQty div Result.FOrderQty;
  Result.FPrice := dPrice;

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo ;

  if bRecovery then begin
    Result.FState := osSent;
  end
  else begin
    Result.FState := osReady;
  end;

  Result.FOrderNo := -1;

  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;

  Result.FRejectCode := '';

  Result.FAcptTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

  Result.FCustomID := -1;
  aQuote  := aSymbol.Quote as TQuote;
  if aQuote <> nil then
  begin
    //Result.AxisIndex  := aQuote.PriceAxis.FindIndex(dPrice);
    Result.LastQuoteTime  := aQuote.LastQuoteTime;
  end;
    // add to the queue
  FNewOrders.Add(Result);

end;

function TOrders.NewCancelOrder(aTarget: TOrder; iCancelQty: Integer;
  aTicket: TOrderTicket; bRecovery : boolean): TOrder;
begin

  Result := nil;

  if (aTarget = nil) or (iCancelQty <= 0) then Exit;

  Result := New;

  Result.FDealer  := aTarget.Dealer;
  Result.FAccount := aTarget.Account;
  Result.FSymbol  := aTarget.Symbol;

  Result.FTarget := aTarget;

  Result.FOrderType := otCancel;
  Result.FPriceControl := pcLimit; // not used
  Result.FTimeToMarket := tmGTC; // default: Good-till-cancel

  Result.FOrderQty := Abs(iCancelQty);
  Result.FSide := aTarget.Side;
  Result.FPrice := 0.0; // not used

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo;

  if bRecovery then begin
    Result.FState := osSent;
  end
  else begin
    Result.FState := osReady;
  end;

  Result.FOrderNo := -1;
  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;

  Result.FRejectCode := '';
  Result.FAcptTime := 0;
  Result.FSentTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

    // client info
  Result.FCustomID := -1;
  Result.FOAsk := aTarget.OAsk;
  Result.Target.Modify := true;

  if aTarget <> nil then
  begin
    Result.GroupNo  := aTarget.GroupNo;
    Result.GroupID  := aTarget.GroupID;
    //Result.AxisIndex:= aTarget.AxisIndex;
  end;

    // add to the queue
  FNewOrders.Add(Result);

  //gEnv.DoLog( WIN_TEST, Result.Represent );
    // notify
  if Assigned(FOnNew) then
    FOnNew(Result);
end;

function TOrders.NewCancelOrderEx(aTarget: TOrder; iCancelQty: Integer;
  aTicket: TOrderTicket; bRecovery: boolean): TOrder;
begin
  Result := nil;

  if (aTarget = nil) or (iCancelQty <= 0) then Exit;

  Result := New;

  Result.FDealer  := aTarget.Dealer;
  Result.FAccount := aTarget.Account;
  Result.FSymbol  := aTarget.Symbol;



  Result.FTarget := aTarget;

  Result.FOrderType := otCancel;
  Result.FPriceControl := pcLimit; // not used
  Result.FTimeToMarket := tmGTC; // default: Good-till-cancel

  Result.FOrderQty := Abs(iCancelQty);
  Result.FSide := aTarget.Side;
  Result.FPrice := 0.0; // not used
  Result.FPrice := aTarget.Price;

  Result.FTicket := aTicket;
  Result.FLocalNo := aTicket.FNo;

  if bRecovery then begin
    Result.FState := osSent;
  end
  else begin
    Result.FState := osReady;
  end;

  Result.FOrderNo := -1;
  Result.FActiveQty := 0;
  Result.FFilledQty := 0;
  Result.FCanceledQty := 0;
  Result.FConfirmedQty := 0;

  Result.FRejectCode := '';
  Result.FAcptTime := 0;
  Result.FSentTime := 0;
  Result.FVirSentTime := GetMMTime;
  Result.MarkSentTime;

    // client info
  Result.FCustomID := -1;
  Result.FOAsk := aTarget.OAsk;
  Result.Target.Modify := true;

  if aTarget <> nil then
  begin
    Result.GroupNo  := aTarget.GroupNo;
    Result.GroupID  := aTarget.GroupID;
    //Result.AxisIndex:= aTarget.AxisIndex;
  end;

    // add to the queue
  FNewOrders.Add(Result);
end;

procedure TOrders.OrderReSet;
begin
  FNewOrders.Clear;
  FActiveOrders.Clear;
  FClosedOrders.Clear;
  FRjtOrders.Clear;
end;

procedure TOrders.OrderStateChanged(aOrder: TOrder);
var index : integer;
begin
  if aOrder = nil then Exit;

    // remove from the old queue
  case aOrder.State of
    osReady: ; // irrelevant
    osSrvAcpt: ; // keep in the same queue
    osSrvRjt, osActive: FNewOrders.Remove(aOrder);
    osRejected:
      begin
        FNewOrders.Remove(aOrder);
        FActiveOrders.Remove(aOrder);
        gEnv.Engine.FormManager.DoOrder( aOrder );
        gEnv.Engine.TradeCore.FrontOrders.DoOrder( aOrder );
        //FActNFillOrders.Remove(aOrder);
        //FAFDOrders.Add(aORder);
      end;
    osFilled, osCanceled, osConfirmed, osFailed:
      begin
        FNewOrders.Remove(aOrder);
        FActiveOrders.Remove(aOrder);
        gEnv.Engine.FormManager.DoOrder( aOrder );
        {
        if aOrder.State <> osFilled then
          FActNFillOrders.Remove(aOrder);
        //FAFDOrders.Add(aORder);
        }
        gEnv.Engine.TradeCore.FrontOrders.DoOrder( aOrder );
      end;
  end;

    // add to the new queue
  case aOrder.State of
    osActive:
      begin
         FActiveOrders.Add(aOrder);
         gEnv.Engine.FormManager.DoOrder( aOrder );
         gEnv.Engine.TradeCore.FrontOrders.DoOrder( aOrder );
         {
         FActNFillOrders.Add(aOrder);
         FAFDOrders.Add(aOrder);
         }
      end;
    {osFilled,} osCanceled, osConfirmed: FClosedOrders.Add(aOrder);
    osSrvRjt, osRejected, osFailed: begin
      FRjtOrders.Add(aOrder);
      FClosedOrders.Add(aOrder);
      gEnv.Engine.FormManager.DoOrder( aOrder );
      gEnv.Engine.TradeCore.FrontOrders.DoOrder( aOrder );
    end;
  end;
    //
    {
  case aOrder.State of
    osFilled :
      begin
        FFillOrders.Add( aOrder );
      end;
  end;
  }
end;

function TOrders.Find(aAccount: TAccount; aSymbol: TSymbol;
  iOrderNo: int64): TOrder;
var
  i: Integer;
  aOrder: TOrder;
  stLog : string;
begin
  Result := nil;

    // the search should be backward (don't change this order)
  for i := Count-1 downto 0 do
  begin
    aOrder := GetOrder(i);

    if (aOrder.Account = aAccount)
       and (aOrder.Symbol = aSymbol)
       and (aOrder.OrderNo = iOrderNo) then
    begin
      Result := Items[i] as TOrder;
      Break;
    end;
  end;

end;

function TOrders.Find(otValue: TOrderType; iOrderNo: int64): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aOrder := TOrder(Items[i]);
    if (aOrder.OrderType = otValue) and (aOrder.OrderNo = iOrderNo) then
    begin
      Result := aOrder;
      Break;
    end;
  end;
end;

function TOrders.FindInvestor(aInvestor: TInvestor; aSymbol: TSymbol;
  iLocalNo: integer): TOrder;
var
  I: Integer;
  aOrder  : TOrder;
begin
  for I := Count-1 downto 0 do
  begin
    aOrder  := GetORder(i);
    if ( aOrder.Account.InvestCode = aInvestor.Code )
       and (aOrder.Symbol = aSymbol)
       and (aOrder.LocalNo = iLocalNo) then
    begin
      Result := Items[i] as TOrder;
      Break;
    end;
  end;
end;

function TOrders.FindINvestorOrder(aInvestor: TInvestor; aSymbol: TSymbol;
  iOrderNo: int64): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;
    // the search should be backward (don't change this order)
  for i := Count-1 downto 0 do
  begin
    aOrder := GetOrder(i);
    if (aOrder.Account.InvestCode = aInvestor.Code )
       and (aOrder.Symbol = aSymbol )
       and (aOrder.OrderNo = iOrderNo) then
    begin
      Result := Items[i] as TOrder;
      Break;
    end;
  end;

end;

function TOrders.Find(aAccount : TAccount; aSymbol: string; iOrderNo: int64): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

    // the search should be backward (don't change this order)
  for i := Count-1 downto 0 do
  begin
    aOrder := GetOrder(i);
    if (aOrder.Account = aAccount)
       and (aOrder.Symbol.Code = aSymbol)
       and (aOrder.OrderNo = iOrderNo) then
    begin
      Result := Items[i] as TOrder;
      Break;
    end;
  end;

end;

function TOrders.FindLocalNo(aAccount: TAccount; aSymbol: TSymbol;
  iLocalNo: Integer): TOrder;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := nil;

    // the search should be backward (don't change this order)
  for i := Count-1 downto 0 do
  begin
    aOrder := GetOrder(i);
    if (aOrder.Account = aAccount)
       and (aOrder.Symbol = aSymbol)
       and (aOrder.LocalNo = iLocalNo) then
    begin
      Result := Items[i] as TOrder;
      Break;
    end;
  end;
end;

function TOrders.Represent: String;
begin
  Result := Format('(new:%d, active:%d, done:%d, rejected:%d)',
                       [FNewOrders.Count, FActiveOrders.Count,
                        FClosedOrders.Count, FRjtOrders.Count]);
end;



procedure TOrders.SetTotDuraTime(aOrder: TOrder);
begin
  FTotDuraTime := FTotDuraTime + (aOrder.FAcptTimeHR - aOrder.FSentTimeHR);
    inc(FTotAcptCnt);
end;

function TOrders.GetFilteredList(aList: TStrings; otValue: TOrderStates;
  aAccount: TAccount): Integer;
var
  i: Integer;
  aOrder: TOrder;
begin
  if aList = nil then Exit;

  for i := 0 to Count - 1 do
  begin
    aOrder := Orders[i];

    if (aOrder.State in otValue) then begin
      aList.AddObject(IntToStr(aOrder.OrderNo), aOrder);
    end;
  end;
end;

function TOrders.GetGroupID: integer;
begin
  inc(FGroupID);
  Result := FGroupID;
end;

function TOrders.GetOrder(i: Integer): TOrder;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOrder
  else
    Result := nil;
end;


function TOrders.GetTotDuraTime: integer;
begin
  if FtotAcptCnt = 0 then
    Result := 0
  else
    Result := Round(FTotDuraTime / FTotAcptCnt);
end;

{ TForwardConfirms }

constructor TForwardAccepts.Create;
begin
  inherited Create(TForwardAccept);
end;

procedure TForwardAccepts.Del(iTarget : int64);
var
  i : integer;
  aForward : TForwardAccept;
begin
  for i := 0 to Count - 1 do
  begin
    aForward := Items[i] as TForwardAccept;
    if aForward.TargetNo = iTarget then
    begin
      Delete(i);
      break;
    end;
  end;
end;

function TForwardAccepts.GetForwordAccept(i: integer): TForwardAccept;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TForwardAccept
  else
    Result := nil;
end;

function TForwardAccepts.New(aAccount: TAccount; aSymbol: TSymbol;
  iTargetNo : int64; iOrderNo: int64; iQty: Integer; dPrice: Double;
  otValue: TOrderType; pvValue: TPriceControl; bAccepted: boolean; stRjtCode : string;
  dtAccept: TDateTime): TForwardAccept;
begin
  Result := Add as TForwardAccept;
  Result.FAccount := aAccount;
  Result.FSymbol := aSymbol;
  Result.FTargetNo := iTargetNo;
  Result.FOrderNo := iOrderNo;
  Result.FOrderQty := iQty;
  Result.FPrice := dPrice;
  Result.FValue := otValue;
  Result.FPriceValue := pvValue;
  Result.FAccepted := bAccepted;
  Result.FRjtCode := stRjtCode;
  Result.FAcceptTime := dtAccept;
end;



end.



