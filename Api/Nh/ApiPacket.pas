unit ApiPacket;

interface

type
  // 공통현재가 시세     Qry_LastPrice = 'FZQ12010'
  TQuerySymbolInfo = record
    ChnageSign  : char;
    KrxCode : array [0..31] of char;
    Code    : array [0..31] of char;
    EngCode : array [0..31] of char;

    KorName : array [0..29] of char;
    EngName : array [0..29] of char;

    Last    : array [0..15] of char;
    Base    : array [0..15] of char;  // 기준가
    Change  : array [0..15] of char;
    UdRate  : array [0..15] of char;

    AskPrice  : array [0..15] of char;
    BidPrice  : array [0..15] of char;
    Volume    : array [0..9] of char;
    PrevVolume: array [0..9] of char;
    Ammout    : array [0..15] of char;
    PrevAmt   : array [0..15] of char;

    OpenInter : array [0..9] of char;
    OpenInterSign  : char;
    OpenInterChange : array [0..9] of char;

    PureOpenInter : array [0..9] of char;
    PureOpenInterSign  : char;
    PureOpenInterChange : array [0..9] of char;

    Highest  : array [0..15] of char;
    HighestDate  : array [0..7] of char;
    Lowest   : array [0..15] of char;
    LowestDate : array [0..7] of char;
    UpperLimit  : array [0..15] of char;
    LowerLimit  : array [0..15] of char;

    Open: array [0..15] of char;
    High: array [0..15] of char;
    Low : array [0..15] of char;
    PrevLast : array [0..15] of char;

    LastTradeDate : array [0..7] of char;
    RemainDays  : array [0..4] of char;
    Filler  : array [0..385] of char;

  end;

  // 20180915  종목정보 조회 ( 전일 전전일 시고저 - 요청 사항 )
  TQuerySymbolInfoUnit = record
    TradeDate : array [0..7] of char;
    Open: array [0..15] of char;
    High: array [0..15] of char;
    Low : array [0..15] of char;
    Last : array [0..15] of char;
    Volume  : array [0..15] of char;
  end;

  TQuerySymbolInfo2 = record
    filler : char;
    Code    : array [0..7] of char;
    info    : TQuerySymbolInfoUnit;
    info2   : TQuerySymbolInfoUnit;
    info3   : TQuerySymbolInfoUnit;
  end;


  TCommonAskUnit = record
    Cnt : array [0..9] of char;
    Volume  : array [0..9] of char;
    Price   : array [0..15] of char;
  end;

  TCommonBidUnit = record
    Price   : array [0..15] of char;
    Cnt : array [0..9] of char;
    Volume  : array [0..9] of char;
  end;

  TQuerySymbolHoga = record
    KrxCode : array [0..31] of char;
    Code    : array [0..31] of char;
    EngCode : array [0..31] of char;

    KorName : array [0..29] of char;
    EngName : array [0..29] of char;

    ChnageSign  : char;
    Last    : array [0..15] of char;
    Change  : array [0..15] of char;
    UdRate  : array [0..15] of char;

    Volume    : array [0..9] of char;
    PrevClose : array [0..15] of char;
    HogaTime  : array [0..7] of char;

    AskHoga   : array [0..4] of TCommonAskUnit; // 매도는 5 --> 1 호가 순
    BidHoga   : array [0..4] of TCommonBidUnit; // 매수는 1 --> 5 호가 순으로

    AskTotCnt : array [0..9] of char;
    AskTotVolume  : array [0..9] of char;
    SunBidVolume  : array [0..9] of char;
    BidTotVolume  : array [0..9] of char;
    BidTotCnt : array [0..9] of char;
  end;

  TWooFutHogaUnit = record
    AskPrice  : array [0..9] of char;
    BidPrice  : array [0..9] of char;
    AskVolume : array [0..5] of char;
    BidVolume : array [0..5] of char;
  end;

  //  선물/스프레드 호가 시세   Real_FutHoga = 'SB_FUT_HOGA';
  TWooFutHoga = record
    TrCode  : array [0..3] of char;          //  선물:F1H0, 스프레드:F1H0
    Code    : array [0..31] of char;
    Hoga1   : TWooFutHogaUnit;
    HogaTime: array [0..7] of char;
    Hoga2   : TWooFutHogaUnit;
    Hoga3   : TWooFutHogaUnit;
    TotAskVol : array [0..5] of char;
    TotBidVol : array [0..5] of char;
    Hoga4   : TWooFutHogaUnit;
    Hoga5   : TWooFutHogaUnit;
    // 왜 잔량이랑 건수를 분리해놓은건지...알수가 없네
    AskCnt1 : array [0..3] of char;
    AskCnt2 : array [0..3] of char;
    AskCnt3 : array [0..3] of char;
    AskCnt4 : array [0..3] of char;
    AskCnt5 : array [0..3] of char;
    TotAskCnt : array [0..4] of char;

    BidCnt1 : array [0..3] of char;
    BidCnt2 : array [0..3] of char;
    BidCnt3 : array [0..3] of char;
    BidCnt4 : array [0..3] of char;
    BidCnt5 : array [0..3] of char;
    TotBidCnt : array [0..4] of char;

    ChangeSign  : char;
    Change  : array [0..8] of char;
    UpDownRate  : array [0..5] of char;
  end;

  TWooOptHogaUnit = record
    AskPrice  : array [0..8] of char;
    BidPrice  : array [0..8] of char;
    AskVolume : array [0..6] of char;
    BidVolume : array [0..6] of char;
  end;

  // 실시간 옵션 호가 Real_OptHoga = 'SB_OPT_HOGA';
  TWooOptHoga = record
    TrCode  : array [0..3] of char;                    // 옵션:O1H0
    Code    : array [0..31] of char;
    Hoga1   : TWooOptHogaUnit;
    HogaTime: array [0..7] of char;
    Hoga2   : TWooOptHogaUnit;
    Hoga3   : TWooOptHogaUnit;
    TotAskVol : array [0..6] of char;
    TotBidVol : array [0..6] of char;
    Hoga4   : TWooOptHogaUnit;
    Hoga5   : TWooOptHogaUnit;
    // 왜 잔량이랑 건수를 분리해놓은건지...알수가 없네
    AskCnt1 : array [0..3] of char;
    AskCnt2 : array [0..3] of char;
    AskCnt3 : array [0..3] of char;
    AskCnt4 : array [0..3] of char;
    AskCnt5 : array [0..3] of char;
    TotAskCnt : array [0..4] of char;

    BidCnt1 : array [0..3] of char;
    BidCnt2 : array [0..3] of char;
    BidCnt3 : array [0..3] of char;
    BidCnt4 : array [0..3] of char;
    BidCnt5 : array [0..3] of char;
    TotBidCnt : array [0..4] of char;

    ChangeSign  : char;
    Change  : array [0..8] of char;
    UpDownRate  : array [0..5] of char;
  end;

  // 실시간 주식선물 호가     SB_STOCK_FUT_HOGA
  TWooStockFutHogaUnit = record
    AskPrice  : array [0..9] of char;
    BidPrice  : array [0..9] of char;
    AskVolume : array [0..6] of char;
    BidVolume : array [0..6] of char;
  end;

  TWooStockFutHogaCntUnit = record
    Cnt    : array [0..3] of char;
  end;

  TWooStockFutHoga = record
    TrCode  : array [0..3] of char;                    // 옵션:F2H0
    Code    : array [0..7] of char;
    HogaTime: array [0..7] of char;
    Hoga    : array [0..9] of TWooStockFutHogaUnit;

    TotAskVol : array [0..7] of char;
    TotBidVol : array [0..7] of char;

    AskCnt    : array [0..9] of TWooStockFutHogaCntUnit;
    TotAskCnt : array [0..4] of char;
    BidCnt    : array [0..9] of TWooStockFutHogaCntUnit;
    TotBidCnt : array [0..4] of char;
  end;


  TWooFutExec = record
    TrCode  : array [0..3] of char;     // 선물 F1CO   SF : F
    Code    : array [0..31] of char;
    Time    : array [0..7] of char;
    Price   : array [0..9] of char;

    NearPrice : array [0..8] of char;
    FarPrice  : array [0..8] of char;
    Open      : array [0..9] of char;
    High      : array [0..9] of char;
    Low       : array [0..9] of char;

    DailyVolume : array [0..6] of char;
    DailyAmount : array [0..11] of char;      // 단위 천원

    NearVolume : array [0..6] of char;
    NearAmount : array [0..11] of char;      // 단위 천원

    FarVolums : array [0..6] of char;
    FarAmount : array [0..11] of char;      // 단위 천원

    ConsVolume : array [0..6] of char;       // 협의 대량체결수량
    ConsAmount : array [0..11] of char;      // 협의 대량체결대금

    ChangeSign  : char;
    Change      : array [0..8] of char;
    Volume      : array [0..5] of char;
    AskPrice    : array [0..9] of char;
    BidPrice    : array [0..9] of char;
    UpDownRate  : array [0..5] of char;

    Disparate   : array [0..6] of char;
    DisparateRate : array [0..5] of char;

    NearChangeSign  : char;
    NearChange      : array [0..8] of char;
    FarChangeSign  : char;
    FarChange      : array [0..8] of char;

    OpenInterest  : array [0..9] of char;
    TheoPrice     : array [0..9] of char;

    DynamicDiv  : char;           //  Y / N
    DynamicUpperLimit : array [0..9] of char;      // 동적가격 미적용시 일중상한가
    DynamicLowerLimit : array [0..9] of char;
  end;


  // 실시간 옵션 체결 Real_OptExec = 'SB_OPT_EXEC';
  TWooOptExec = record
    TrCode  : array [0..3] of char;     // 옵션:O1C0
    Code    : array [0..31] of char;
    Time    : array [0..7] of char;
    Price   : array [0..8] of char;

    Open      : array [0..8] of char;
    High      : array [0..8] of char;
    Low       : array [0..8] of char;

    DailyVolume : array [0..7] of char;
    DailyAmount : array [0..11] of char;      // 단위 천원

    ConsVolume : array [0..6] of char;       // 협의 대량체결수량
    ConsAmount : array [0..11] of char;      // 협의 대량체결대금

    ChangeSign  : char;
    Change      : array [0..8] of char;
    Volume      : array [0..5] of char;
    AskPrice    : array [0..8] of char;
    BidPrice    : array [0..8] of char;
    UpDownRate  : array [0..5] of char;

    Disparate   : array [0..6] of char;
    DisparateRate : array [0..5] of char;

    OpenInterest  : array [0..9] of char;
    TheoPrice     : array [0..8] of char;

    DynamicDiv  : char;           //  Y / N
    DynamicUpperLimit : array [0..9] of char;      // 동적가격 미적용시 일중상한가
    DynamicLowerLimit : array [0..9] of char;

  end;

  TWooFutOpen = record
    TrCode  : array [0..3] of char;    // F1M0
    OpenDiv : array [0..1] of char;   // M0 : 전일   M1 : 당일잠정  M2 : 당일확정
    Code    : array [0..31] of char;
    Date    : array [0..7] of char;
    Volume  : array [0..6] of char;
  end;

  TWooOptOpen = record
    TrCode  : array [0..3] of char;    // O1M0
    Date    : array [0..7] of char;
    Code    : array [0..31] of char;
    Volume  : array [0..6] of char;
    OpenDiv : array [0..1] of char;   // M0 : 전일   M1 : 당일잠정  M2 : 당일확정
  end;

  TWooPriceLimit = record
    TrCode  : array [0..3] of char;    // F1V1
    Key     : array [0..3] of char;    // 0101
    Code    : array [0..31] of char;
    Time    : array [0..7] of char;
    HighestLv : array [0..1] of char;
    LowestLv  : array [0..1] of char;
    Highest : array [0..9] of char;
    Lowest  : array [0..9] of char;
  end;


  PAutoInvestFutData = ^TAutoInvestFutData;
  TAutoInvestFutData = record
    DGubun        : array [0..3] of char;     // 데이타 구분
    MktCdFogb     : array [0..3] of char;     //
    MkDate          : array [0..7] of char;
    MkTime          : array [0..5] of char;
		InvstCode			: array [0..3] of char;

		SellQty				: array [0..9] of char;     //	/* 매도수량(계약)												*/
		SellAmt				: array [0..9] of char;     //	/* 매도대금(백만원)												*/
		BuyQty				: array [0..9] of char;     //	/* 매수수량(계약)												*/
		BuyAmt				: array [0..9] of char;     //	/* 매수대금(백만원)												*/

		SellQtyGap				: array [0..9] of char;     //	/* 매도수량(계약)												*/
		SellAmtGap				: array [0..9] of char;     //	/* 매도대금(백만원)												*/
		BuyQtyGap				: array [0..9] of char;     //	/* 매수수량(계약)												*/
		BuyAmtGap				: array [0..9] of char;     //	/* 매수대금(백만원)												*/


   {
		BuyRate				: array [0..9] of char;     //	/* 매수 비율(%)	Float											*/
		SellRate			: array [0..9] of char;     //	/* 매도 비율(%)	Float											*/

		PurityQty			: array [0..9] of char;     //	/* 순매수수량(계약)												*/
		PurityAmt			: array [0..9] of char;     //	/* 순매수대금(백만원)											*/

		Sp_BuyQty			: array [0..9] of char;     //	/* 스프레드매수수량(계약)										*/
		Sp_BuyAmt			: array [0..9] of char;     //	/* 스프레드매수대금(백만원)										*/
		Sp_BuyRate		: array [0..9] of char;     //	/* 매수 비율(%)	Float											*/
		Sp_SellQty		: array [0..9] of char;     //	/* 스프레드매도수량(계약)										*/
		Sp_SellAmt		: array [0..9] of char;     //	/* 스프레드매도대금(백만원)										*/
		Sp_SellRate		: array [0..9] of char;     //	/* 매도 비율(%)	Float											*/
		Sp_PurityQty	: array [0..9] of char;     //	/* 스프레드순매수수량(계약)										*/
		Sp_PurityAmt	: array [0..9] of char;     //	/* 스프레드순매수대금(백만원)									*/
    }
  end;


  PAutoInvestOptData = ^TAutoInvestOptData;
  TAutoInvestOptData = record
    DGubun        : array [0..3] of char;     // 데이타 구분
    MktCdFogb     : array [0..3] of char;     //
    MkDate          : array [0..7] of char;
    MkTime          : array [0..5] of char;
		InvstCode			: array [0..3] of char;

		SellQty				: array [0..9] of char;     //	/* 매도수량(계약)												*/
		SellAmt				: array [0..9] of char;     //	/* 매도대금(백만원)												*/
		BuyQty				: array [0..9] of char;     //	/* 매수수량(계약)												*/
		BuyAmt				: array [0..9] of char;     //	/* 매수대금(백만원)												*/

		SellQtyGap				: array [0..9] of char;     //	/* 매도수량(계약)												*/
		SellAmtGap				: array [0..9] of char;     //	/* 매도대금(백만원)												*/
		BuyQtyGap				: array [0..9] of char;     //	/* 매수수량(계약)												*/
		BuyAmtGap				: array [0..9] of char;     //	/* 매수대금(백만원)												*/
  end;


  // 주문가능수량  ATQ39105 / CTQ10061

  TInputOrderAbleQty = record
    AccountNo : array [0..5] of char;
    AcntPass: array [0..7] of char;
    Code    : array [0..31] of char;

    TradeCode : array [0..1] of char;       // 거래대상코드
    DerivCode : array [0..2] of char;
    Side      : char;                       // 1:매수, 2:매도
    OrderDiv  : char;                       // 1:지정가, 2:시장가, 3:조건부지정가, 4:최유리지정가
    Price     : array [0..8] of char;
  end;

  POutOrderAbleQty = ^TOutOrderAbleQty;
  TOutOrderAbleQty = record
    AbleQty : array [0..7] of char;
    LiquidQty : array [0..7] of char;
    TotAbleQty: array [0..7] of char;
  end;

  POutOrderResult = ^TOutOrderResult;
  TOutOrderResult = record
    Count   : array [0..2] of char;
    MsgCode : array [0..4] of char;
    OrderNo : array [0..6] of char;
    LocalNo : array [0..6] of char;
  end;

  // 주문 / 체결 내역  ATQ39120 / CTQ10024
  TInputOrderList = record
    TradeDate : array [0..7] of char;
    AccountNo : array [0..5] of char;
    AcntPass  : array [0..7] of char;

    Code      : array [0..31] of char;
    Side      : char;       //  ' ':전체  1:매수, 2:매도
    OrdForm   : char;       //  ' ':전체, 1:일반
    OrdState  : char;       //  ' ':전체, 4:체결, 5:미체결

    TradeCode : array [0..1] of char;       // 거래대상코드
    PrdtDiv   : char;       //  0:전체, 1:선물, 2:옵션, 3:Call옵션, 4:Put옵션, 5:정형복합
    MediaDiv  : char;       //  매체구분  ' '
    QeuryDiv  : char;       //  조회조건  1
    OrderNo   : array [0..6] of char;     // '9999999'
    MulitAcntDiv  : char;   //  'N'
    FundNo    : array [0..2] of char;     //  000:전
  end;

  //

  POutOrderList = ^TOutOrderList;
  TOutOrderList = record
    Count : array [0..2] of char;
    AccountNo : array [0..5] of char;
    Orderno   : array [0..6] of char;
  end;

  POutOrderListSub = ^TOutOrderListSub;
  TOutOrderListSub = record
    AccountNo : array [0..5] of char;
    AccountName : array [0..39] of char;
    BranchNo  : array [0..2] of char;
    OrderNo   : array [0..6] of char;
    OrgOrdNo  : array [0..6] of char;
    MoOrderNo : array [0..6] of char;
    xxxDiv    : char;
    TradeCode : array [0..1] of char;       // 거래대상코드
    DerivCode : array [0..2] of char;
    KrxCode   : array [0..31] of char;

    NHCode    : array [0..31] of char;
    EngCode   : array [0..31] of char;
    KorName   : array [0..79] of char;
    EngName   : array [0..79] of char;

    OrderDiv  : char;                     // 주문구분
    Side      : char;                     // 주문구분
    MediaDiv  : char;                     // 매체구분
    Qty       : array [0..7] of char;     // 주문수량
    Price     : array [0..11] of char;
    FillQty   : array [0..7] of char;
    FillPrice : array [0..11] of char;
    FillAmt   : array [0..14] of char;

    RemainQty : array [0..7] of char;
    ModifyQty : array [0..7] of char;
    CancelQty : array [0..7] of char;
    PriceType : char;                          // 주문유형

    FillQtyDiv: char;                         // 체결수량구분
    OrderForm : char;                         // 주문형태

    ProcState : char;                         // 처리상태
    ProcStateName : array [0..19] of char;    // 처리상태명

    AceptTime : array [0..7] of char;         // 접수시각
    IP        : array [0..14] of char;        // IP
    RjctCode  : array [0..9] of char;         //
    StgName   : array [0..29] of char;
    DealerNo  : array [0..2] of char;         // 딜러번호
    UserName  : array [0..19] of char;        // 사용자
  end;

  // 예수금 조회   ATQ39706 / CTQ10032

  TInputDeposit = record
    ReqDate : array [0..7] of char;       // space
    AccountNo : array [0..5] of char;
    AcntPass  : array [0..7] of char;
    MediaDiv  : char;                     //   'C'
  end;

  POutDeposit = ^TOutDeposit;
  TOutDeposit = record
    TotDeposit  : array [0..14] of char;          //    예탁금액총액
    DepositCash : array [0..14] of char;          //    예탁금액현금
    DepositSub  : array [0..14] of char;          //    예탁금액대용
    DepositFor  : array [0..14] of char;          //    예탁금액외화

    OrdAblTotAmt: array [0..14] of char;          //    주문가능금액총액
    OrdAbltCash : array [0..14] of char;          //    주문가능금액현금
    OrdAbleSub  : array [0..14] of char;          //    주문가능금액대용
    OrdAbleFor  : array [0..14] of char;          //    주문가능금액외화

    OutAbleTotAmt : array [0..14] of char;        //    인출가능금액총액
    OutAbleCash : array [0..14] of char;          //    인출가능금액현금
    OutAlbeSub  : array [0..14] of char;          //    인출가능금액대용
    OutAbleFor  : array [0..14] of char;          //    인출가능금액외화

    TrustMarginTotAmt : array [0..14] of char;          //    위탁증거금총액
    TrustMarginCash   : array [0..14] of char;          //    위탁증거금현금
    TrustMarginSub    : array [0..14] of char;          //    위탁증거금대용
    TrustMarginFor    : array [0..14] of char;          //    위탁증거금외화

    StayMarginTotAmt  : array [0..14] of char;          //    유지증거금총액
    StayMarginCash  : array [0..14] of char;          //    유지증거금현금
    StayMarginSub   : array [0..14] of char;          //    유지증거금대용
    StayMarginFor   : array [0..14] of char;          //    유지증거금외화

    AddMarginTotAmt : array [0..14] of char;          //    추가증거금총액
    AddMarginCash   : array [0..14] of char;          //    추가증거금현금
    AddMarginSub    : array [0..14] of char;          //    추가증거금대용
    AddMarginFor    : array [0..14] of char;          //    추가증거금외화

    AddMarginDesc   : array [0..39] of char;          //    추가증거금발생구분
    FutTradePL      : array [0..14] of char;          //    선물매매손익
    OptTradePL      : array [0..14] of char;          //    옵션매매손익
    FutSettleAmt    : array [0..14] of char;          //    선물정산차금
    OptSettleAmt    : array [0..14] of char;          //    옵션결제대금
    InSuAmt         : array [0..14] of char;          //    인수도대금
    Fee             : array [0..14] of char;          //    수수료
    Filler1         : array [0..59] of char;          //
    SubstAmt        : array [0..14] of char;          //    대용금액
    Filler2         : array [0..104] of char;         //
  end;


  // 미결제 잔고     ATQ39701 / CTQ10031

  TInputPosition = record
    AccountNo : array [0..5] of char;
    AcntPass  : array [0..7] of char;
    TradeCode : array [0..1] of char;
    PrdtDiv   : char;
    QryMediaDiv  : char ;
    QueryCon  : char;
    AccountNoKey : array [0..5] of char;
    SymbolCode: array [0..31] of char;
    TradeKey  : char;
  end;

  POutPosition = ^TOutPosition;
  TOutPosition = record
    Count : array [0..2] of char;
    AccountNo : array [0..5] of char;
    SymbolCode: array [0..31] of char;
    TradeKey  : char;
  end;

  POutPositionSub = ^TOutPositionSub;
  TOutPositionSub = record
    AccountNo : array [0..5] of char;
    AccountName : array [0..39] of char;
    TradeCode : array [0..1] of char;
    PrdtDiv   : array [0..2] of char;

    KrxCode   : array [0..31] of char;

    NHCode    : array [0..31] of char;
    EngCode   : array [0..31] of char;
    KorName   : array [0..79] of char;
    EngName   : array [0..79] of char;

    Side      : char;
    Qty       : array [0..9] of char;
    RemainQty : array [0..9] of char;
    LiquidQty : array [0..9] of char;
    AvgPrice  : array [0..11] of char;

    PositionAmt : array [0..14] of char;
    TradePL     : array [0..14] of char;
    OpenPL      : array [0..14] of char;
    OpenPLRate  : array [0..6] of char;       // 평가손익
    UnitAmt     : array [0..9] of char;       // 단위금액
    PrevClose   : array [0..11] of char;
    Last        : array [0..11] of char;
    AskPrice    : array [0..11] of char;
    BidPrice    : array [0..11] of char;
  end;

  POrderExec = ^TOrderExec;
  TOrderExec = record
    /////////////     공통부분
    UserID  : array [0..15] of char;
    OrderID : array [0..7] of char;
    UserName: array [0..19] of char;
    OrderIP : array [0..14] of char;
    RealDiv : char;       //    1;단말용, 2:단말외(팀, 관리, 계좌), 3:복수계좌, A:대외계
    AcntType  : char;     //    1:계좌주문체결, 2:그룹주문체결, 3:복수계좌주문(체결),
                          //    4:복수게좌주문(잔고), 5:STOP, 6:FIX주문, 7:FIX예약주문,
                          //    8:일반예약주문, A:업무용 메시지, B:은행계좌명 조회

    DspDiv1 : char;
    DspDiv2 : char;
    DspDiv3 : char;
    MediaDiv  : char;
    Filler    : array [0..1] of char;

    /////////////   주문체결
    DataDiv : array [0..1] of char;     //  12:거래소접수, 13:확인, 14:체결, 15:원주문데이타변경, 19:거부
    AcntNo  : array [0..5] of char;
    AcntName  : array [0..29] of char;
    xxxDiv    : char;
    BranchNo  : array [0..2] of char;
    OrderNo   : array [0..6] of char;
    OCOSeq    : array [0..7] of char;
    KrxCode   : array [0..9] of char;

    OrderDiv  : char;                  //     1:정상, 2:정정, 3:취소
    PriceType : char;                  //     1:지정가, 2:시장가, 3:시간외, 4:최유리지정가
    FillDiv   : char;                  //     1:FAS, 2:FOK, 3:FAK
    TradeType : char;                  //     1: 차익, 2:헤지, 3:기타
    Side      : char;                 //      1: 매수, 2:매도

    Price     : array [0..9] of char;
    Qty       : array [0..4] of char;
    FillPrice : array [0..9] of char;
    FillQty   : array [0..4] of char;
    FillAmt   : array [0..12] of char;

    CnlConfrimQty : array [0..4] of char;
    ModifyQty     : array [0..4] of char;
    CancelQty     : array [0..4] of char;
    RemainQty     : array [0..4] of char;

    MoOrderNo     : array [0..6] of char;
    OrgOrderNo    : array [0..6] of char;
    OrderType     : char;         //  1:일반주문, 2:STOP주문, 3:SCALE주문, 4:반복주문, 5:복수주문
                                  //  6:OCO주문, 7:대기주문
    GroupID       : array [0..2] of char;
    GroupName     : array [0..19] of char;
    RjctCode     : array [0..9] of char;     // 거부코드
    ProcCode      : char;                    // 1:접수전, 2:접수, 3:확인, 4:체결, 5:전량 미체결, 9:거부
    OrderStateNm  : array [0..13] of char;   //  접수전, 미체결, 일부체결, 체결, 전량미체결, 거부
    OrderInputTime  : array [0..7] of char;   // 주문 입력시간

    /////////////   주문체결

    FillNo  : array [0..8] of char;
    FillKrCode  : array [0..9] of char;
    FillSide  : char;     //   1:매수, 2:매도
    FillTime  : array [0..7] of char;
    FillPrice2 : array [0..9] of char;
    FillQty2   : array [0..7] of char;
    FillAmt2   : array [0..12] of char;

    /////////////   잔고 내역

    PosKrxCode  : array [0..9] of char;
    PosSide     : char;
    PosQty      : array [0..4] of char;
    LiqQty      : array [0..4] of char;
    PosAvgPrice : array [0..9] of char;
    PosAmt      : array [0..12] of char;
    TodayOrdQty : array [0..4] of char;
    UnitQty     : array [0..18] of char;
    CurrPrice   : array [0..9] of char;
    FundDealer  : array [0..2] of char;

  end;


implementation

end.
