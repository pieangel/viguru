unit ApiPacket;

interface

type
  // ---------------------  조회  --------------------------


  PCommonHeader = ^TCommonHeader;
  TCommonHeader = record
    WindowID  : array [0..9] of char;
    ReqKey    : char;
    ErrorCode : array [0..3] of char;         // 공백 or 0000  -> 정상
    NextKind  : char;                         // 0 : 다음 없음   1: 다음 있음
    Err_Kind  : char;
    filler    : array [0..13] of char;
  end;

  PErrorData = ^TErrorData;
  TErrorData = record
    Header : TCommonHeader;
    ErrorMsg  : array [0..99] of char;
  end;    

  POutAccountInfo = ^TOutAccountInfo;
  TOutAccountInfo = record
    Sub     : char;
    Code    : array [0..10] of char;
    Name    : array [0..19] of char;
  end;

  POutFutureInfo = ^TOutFutureInfo;
  TOutFutureInfo = record
    Name    : array [0..29] of char;
    Code    : array [0..7] of char;
    Remain  : array [0..2] of char;
  end;

  POutOptionInfo = ^TOutOptionInfo;
  TOutOptionInfo = record
    Name    : array [0..13] of char;
    Code    : array [0..7] of char;
    Remain  : array [0..21] of char;
  end;


  // -- 상품선물
  POutComFutureInfo = ^TOutComFutureInfo;
  TOutComFutureInfo = record
    UnderName    : array [0..19] of char;
    CommID       : array [0..2] of char;
    Count        : array [0..1] of char;
  end;

  POutComFutureInfoSub = ^TOutComFutureInfoSub;
  TOutComFutureInfoSub = record
    Name    : array [0..29] of char;
    Code    : array [0..7] of char;
  end;

  // -- 상품옵션
  POutComOptionInfo = ^TOutComOptionInfo;
  TOutComOptionInfo = record
    UnderName    : array [0..19] of char;
    TargetCode   : array [0..1] of char;  // TargetCode + master.dat  <---- 마스터파일.
    QueryStrike  : array [0..16] of char;
    CommID       : array [0..2] of char;
    Strike       : array [0..16] of char;
    HogaUnit     : array [0..4] of char;
    HogaAmt      : array [0..20] of char;
    Count        : array [0..1] of char;
  end;

  PUnionMaster = ^UnionMaster;
  UnionMaster = packed record
    case Integer of
      0: ( FutMaster        :       TOutFutureInfo; );
      1: ( OptMaster        :       TOutOptionInfo; );
      2: ( ComFutMaster     :       TOutComFutureInfo; );
      3: ( ComOptMaster     :       TOutComOptionInfo; );
  end;


  POutSymbolListInfo = ^TOutSymbolLIstInfo;
  TOutSymbolLIstInfo = record
		AssetsID		: array [0..2] of char;   //	/* 거래대상자산 												*/
		FullCode		: array [0..11] of char;
		ATM_Kind		: char;                   //  /* ATM 구분 ('Y', 'N')											*/
		ShortCode		: array [0..7] of char;   //	/* 단축코드														*/
		Index				: array [0..3] of char;
		JongName		: array [0..29] of char;  //	/* 한글 종목명													*/
		JongEName		: array [0..29] of char;  //	/* 영문 종목명													*/
		LastDate		: array [0..9] of char;   //	/* yyyy.mm														*/
		ExecPrice		: array [0..9] of char;   //	/* xxx.x														*/
		DecimalPrice: char;			              //  /* Declmal 정보													*/
		MarketGb		: char;	                  //	/* 1:선물 2:CALL 3:PUT 4:선물spread 5:콜spread 6:풋spread		*/
	 	TradeUnit		: array [0..12] of char;	//  /* 거래승수
  end;

  //  2003, 2004, 2007, 2022  종목기본정보, 종목마스터  , 종목현재가
  PReqSymbolMaster = ^TReqSymbolMaster;
  TReqSymbolMaster = record
    header : TCommonHeader;
    AssetsID  : array [0..2] of char;       // 거래대상자산
    FullCode  : array [0..11] of char;      // 종목코드
    Index     : array [0..3] of char;
  end;


  POutSymbolMaster = ^TOutSymbolMaster;
  TOutSymbolMaster = record
    Header    : TCommonHeader;
		FullCode			: array [0..11] of char;    //	/* 종목표준코드													*/
		StdPrice			: array [0..10] of char;    //	/* 기준가														*/
		HighLimitPrice: array [0..10] of char;    //	/* 상한가														*/
		LowLimitPrice	: array [0..10] of char;    //	/* 하한가														*/
		CBHighLimitPrice: array [0..10] of char;  //	/* CB적용상한가													*/
		CBLowLimitPrice	: array [0..10] of char;  //	/* CB적용하한가													*/
		PDVolume			  : array [0..7] of char;   //	/* 전일거래량													*/
		PDMoney				  : array [0..14] of char;  //	/* 전일거래대금													*/
		PDEndPrice			: array [0..7] of char;   //	/* 전일종가														*/
		RemainDays			: array [0..2] of char;   //	/* 잔존일수														*/
		LastTradeDate		: array [0..7] of char;   //	/* 최종거래일YYYYMMDD											*/
		ListedHighPrice	: array [0..10] of char;  //	/* 상장중최고가													*/
		ListedHighPriceDate: array [0..7] of char;//	/* 상장중최고일YYYYMMDD											*/
		ListedLowPrice		 : array [0..10] of char;//	/* 상장중최저가													*/
		ListedLowPriceDate : array [0..7] of char;//	/* 상장중최저일YYYYMMDD											*/
		ImpliedVolatility	: array [0..6] of char;	//  /* 내재변동성													*/
		CDInterest			  : array [0..6] of char;	//  /* CD금리(%)													*/
		DividendIndex		  : array [0..14] of char;//	/* 배당액지수미래가치											*/
		RTime_Hi			    : array [0..10] of char;//	/* 실시간상한가													*/
		RTime_Lo			    : array [0..10] of char;//	/* 실시간하한가													*/
		RTime_Clear			  : char;                 //	/* 0.비해당종목 1.해당종목 2.일시해제 3.미적용중				*/
  end;

    //최대 20개
  POutSymbolFilllListSub = ^TOutSymbolFillListSub;
  TOutSymbolFillListSub = record
	  Time				: array [0..7] of char;         //	/* 시간(HH:MM:SS)												*/
    CmpSign			: char;                         //	/* 대비부호
                                                //    0.보합 1.상한 2.하한 3.상승 4.하락
                                                //    5.기세상한 6.기세하한 7.기세상승 8.기세하락					*/
    CmpPrice		: array [0..10] of char;        //	/* 전일대비														*/
    CurrPrice		: array [0..10] of char;        //	/* 현재가														*/
    CmpRate			: array [0..7] of char;         //	/* 등락율														*/
    Volume			: array [0..7] of char;         //	/* 거래량														*/
    Money				: array [0..11] of char;        //	/* 거래대금(천원)												*/
    NowVol			: array [0..5] of char;         //	/* 체결수량														*/
    NonSettlQty	: array [0..7] of char;         //	/* 미결재약정수량												*/
    PDEndPrice	: array [0..10] of char;        //	/* 전일종가														*/
    MatchKind		: char;                         //	/* 현재가의 호가구분 (+:매수 -:매도)							*/
  end;

  POutSymbolFilllList = ^TOutSymbolFillList;
  TOutSymbolFillList = record
	  Header    : TCommonHeader;
    FullCode	: array [0..12] of char;        //	/* 종목표준코드													*/
    DataCnt		: array [0.. 2] of char;        //	/* Data Count
  end;

  POutSymbolMarkePrice = ^TOutSymbolMarkePrice;
  TOutSymbolMarkePrice = record
	  Header    : TCommonHeader;
		FullCode	: array [0..11] of char;          //	/* 종목표준코드													*/
		CurrPrice	: array [0..9] of char;           //	/* 현재가														*/
		CmpSign		: char;                           //	/* 대비부호
                                                //    0.보합 1.상한 2.하한 3.상승 4.하락
                                                //    5.기세상한 6.기세하한 7.기세상승 8.기세하락					*/
		CmpPrice	: array [0..9] of char;           //	/* 전일대비														*/
		CmpRate		: array [0..7] of char;           //	/* 등락율														*/
		StartPrice: array [0..9] of char;           //	/* 시가															*/
		HighPrice	: array [0..9] of char;           //	/* 고가															*/
		LowPrice	: array [0..9] of char;           //	/* 저가															*/
		SellPrice	: array [0..9] of char;           //	/* 매도호가														*/
		BuyPrice	: array [0..9] of char;           //	/* 매수호가														*/
		NowVol	  : array [0..5] of char;           //	/* 체결량														*/
		Volume	  : array [0..7] of char;           //	/* 거래량														*/
		Money			: array [0..11] of char;          //	/* 거래대금(천원)												*/
		PDEndPrice : array [0..7] of char;          //	/* 전일종가														*/
		MarketStat: array  [0..19] of char;         //	/* 장운영구분
                                                //    1.전체거래중단 2.전체거래재개 3.종목거래중단 4.종목거래재개
                                                //    5.CB중단  6.CB재개 7.장마감 9.가격급변(CB)중단예고
                                                //    A.주식CB중단예고 B.주식CB중간 C.주식CB재개
                                                //    D.종가 단일가 호가 접수개시(스프레드종목은 거래종료)		*/
		NonSettlQty		 : array [0..7] of char;      //	/* 미결제약정수량												*/
		CmpNonSettlQty : array [0..7] of char;      //	/* 전일증감														*/
		TheoryPrice		 : array [0..10] of char;     //	/* 이론가														*/
		TheoryBasis		 : array [0..7] of char;      //	/* 이론베이시스													*/
		MarketBasis		 : array [0..7] of char;      //	/* 시장베이시스													*/
		Disparate			 : array [0..8] of char;      //	/* 괴리율														*/
		DispaGap			 : array [0..7] of char;      //	/* 괴리폭														*/
		Delta				  : array [0..12] of char;      //	/* 델타															*/
		Gamma				: array [0..12] of char;        //	/* 감마															*/
		Rho					: array [0..12] of char;        //	/* 로															*/
		Theta				: array [0..12] of char;        //	/* 쎄타															*/
		Vega				: array [0..12] of char;        //	/* 베가															*/
		HistVolat			: array [0..7] of char;       //	/* 역사적변동성													*/
		UpCode				: array [0..3] of char;       //	/* kospi200업종코드												*/
		KospiTime			: array [0..7] of char;       //	/* kospi200지수시간												*/
		StartJisu			: array [0..6] of char;       //	/* kospi시가지수												*/
		HighJisu			: array [0..6] of char;       //	/* kospi고가지수												*/
		LowJisu				: array [0..6] of char;       //	/* kospi저가지수												*/
		LastJisu			: array [0..6] of char;       //	/* kospi종가지수												*/
		Dungrak				: char;                       //	/* 등락구분 (' '.보합 +.상승 -.하락)							*/
		Debi				  : array [0.. 6] of char;      //	/* 등락폭														*/
		DebiRate			: array [0.. 7] of char;      //	/* 등락율														*/
		JisuVolume		: array 	[0..9] of char;     //	/* 거래량(천주)													*/
		JisuMoney			: array [0..9] of char;       //	/* 거래대금(백만원)												*/
		Time				  : array [0..7] of char;       //	/* HH:MM:SS														*/
		ImpliedVolatility	: array [0..6] of char;   //	/* 내재변동성													*/
		CDInterest			: array [0..6] of char;     //	/* CD금리														*/
		RemainDays			: array [0..2] of char;     //	/* 잔존일수
  end;

  TSymbolHogaUnit = record
    SellPrice	: array [0..9] of char;      //	/* 매도호가														*/
    BuyPrice	: array [0..9] of char;      //	/* 매수호가														*/
    SellQty		: array [0..6] of char;      //	/* 매도잔량
    BuyQty		: array [0..6] of char;      // /* 매수잔량														*/
    SellCnt		: array [0..4] of char;      //	/* 매도건수														*/
    BuyCnt		: array [0..4] of char;      //	/* 매수건수														*/
  end;

  POutSymbolHoga = ^TOutSymbolHoga ;
  TOutSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..11] of char;    //	/* 종목표준코드													*/
		Time				: array [0..7] of char;     //	/* 시간(HH:MM:SS)												*/
		ClosePrice  : array [0..7] of char;     //	/* 전일종가									*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..6] of char;    //	/* 매도총호가수량9(6)											*/
		TotBuyQty		: array [0..6] of char;    //	/* 매수총호가수량9(6)											*/
		TotSellNo		: array [0..4] of char;    //	/* 매도총호가건수9(5)											*/
		TotBuyNo		: array [0..4] of char;    //	/* 매수총호가건수9(5)
    Equilibrium	: array [0..7] of char;     //	/* KOFEX 예상체결가(동시호가)									*/
		CurrPrice		: array [0..9] of char;     //	/* 현재가S9(6)V9(2)
  end;

  // 차트 데이타
  PReqChartData = ^TReqChartData;
  TReqChartData = record
	  Header    : TCommonHeader;
    JongUp    : char;                   //  /* 1.종목 2.업종 3.KOSPI200 선물/옵션 4.KOFEX 선물/옵션			*/
		DataGb		: char;                   //	/* 1.일 2.주 3.월 4.tick 5.분
		DiviGb		: char;                   //  /* 0.종목, 일별시 액면분할 반영X 1.종목, 일별시 액면분할 반영O
											                  //  ※ 항시 0으로 올려주시면 됩니다.								*/								*/
		AssetsID  : array [0..2] of char;   //	/* 거래대상자산
		FullCode	: array [0..11] of char;  //	/* 종목표준코드													*/
		Index			: array [0..3] of char;   //	/* 코드 index													*/
		InxDay		: array [0..7] of char;   //	/* 기준일자														*/    분,틱은 제외
		DayCnt		: array [0..2] of char;   //	/* 일자갯수														*/
		Summary		: array [0..2] of char;   //	/* tick, 분에서 모으는 단위										*/									*/
  end;

  POutChartDataSub = ^TOutChartDataSub;
  TOutChartDataSub = record
    Date				: array [0..7] of char;   //   /* YYYYMMDD														*/
    Time				: array [0..7] of char;   //  /* 시간(HH:MM:SS)												*/
    OpenPrice		: array [0..9] of char;  //   /* 시가 double													*/
    HighPrice		: array [0..9] of char;  //   /* 고가 double													*/
    LowPrice		: array [0..9] of char;  //   /* 저가 double													*/
    ClosePrice	: array [0..9] of char;  //   /* 종가 double													*/
    Volume			: array [0..9] of char;  //   /* 거래량 double

		Money				: array [0..19] of char; // 	/* 거래대금 (천원)												*/
		Kijunka			: array [0..9] of char;	 //   /* 기준가(원)													*/
		FacePrice		: array [0..9] of char;	 //   /* 액면가(원)													*/
		AvgPrice		: array [0..9] of char;	 //   /* 가중평균가(원) 보유주식수(천주)								*/
		Gwunbae			: char;	                  //    /* 락구분
  end;

  POutChartData = ^TOutChartData;
  TOutChartData = record
	  Header    : TCommonHeader;
    FullCode	: array [0..11] of char;    //    /* 종목표준코드													*/
    MaxDataCnt: array [0..2] of char;     //    /* 전체일자 갯수												*/
    DataCnt		: array [0..2] of char;     //    /* 현재송신일자 갯수											*/
    TickCnt		: array [0..2] of char;     //    /* 마지막봉의 tick 갯수											*/
    Today			: array [0..7] of char;     //    /* 당영업일(StockDate[0])										*/									*/
    PrevLast	: array [0..8] of char;     //    /* 전일종가														*/
  end;

  PSendAutoKey = ^TSendAutoKey ;
  TSendAutoKey = record
    header : TCommonHeader;
	  Auto_Kind	 : char;	                //  1.일반 시세, 2.CME 일반 시세 3.투자자 시세					*/
	  AutoKey		 : array [0..31] of char; //	/* 계좌의 경우 계좌번호, 시세 경우 종목표준코드					*/
  end;



  ////  시세 자동 업데이트  -----------------------------------------------------------------
  ///
{$REGION '시세 자동 업데이트....'}

  PAutoSymbolHoga = ^TAutoSymbolHoga ;
  TAutoSymbolHoga = record
    jmcode    : array [0..7] of char;   //      8        종목코드,
    jmcodeseq : array [0..1] of char;   //      2        종목SEQ,
    offerho1  : array [0..6] of char;   //      7        매도우선호가[9(4)v9(2)],
    bidho1    : array [0..6] of char;   //      7        매수우선호가[9(4)v9(2)],
    offerrem1 : array [0..5] of char;   //      6        매도잔량,
    bidrem1   : array [0..5] of char;   //      6        매수잔량,
    offerho2  : array [0..6] of char;   //      7        차선매도호가[9(3)v9(2)],
    bidho2    : array [0..6] of char;   //      7        차선매수호가[9(3)v9(2)],
    offerrem2 : array [0..5] of char;   //      6        차선매도호가잔량,
    bidrem2   : array [0..5] of char;   //      6        차선매수호가잔량,
    offerho3  : array [0..6] of char;   //      7        차차선매도호가[9(3)v9(2)],
    bidho3    : array [0..6] of char;   //      7        차차선매수호가[9(3)v9(2)],
    offerrem3 : array [0..5] of char;   //      6        차차선매도호가잔량,
    bidrem3    : array [0..5] of char;   //     6        차차선매수호가잔량,
    offertotrem : array [0..5] of char;   //    6        총매도호가잔량,
    bidtotrem   : array [0..5] of char;   //    6        총매수호가잔량,
    hotime      : array [0..5] of char;   //    6        호가접수시간,
    offerho4   : array [0..6] of char;   //     7        4차선매도호가,
    bidho4     : array [0..6] of char;   //     7        4차선매수호가,
    offerrem4  : array [0..5] of char;   //     6        4차선매도잔량,
    bidrem4    : array [0..5] of char;   //     6        4차선매수잔량,
    offerho5   : array [0..6] of char;   //     7        5차선매도호가,
    bidho5     : array [0..6] of char;   //     7        5차선매수호가,
    offerrem5  : array [0..5] of char;   //     6        5차선매도잔량,
    bidrem5    : array [0..5] of char;   //     6        5차선매수잔량,
    offercnt1  : array [0..3] of char;   //     4        우선매도건수,
    offercnt2  : array [0..3] of char;   //     4        차선매도건수,
    offercnt3  : array [0..3] of char;   //     4        차차선매도건수,
    offercnt4  : array [0..3] of char;   //     4        4차선매도건수,
    offercnt5  : array [0..3] of char;   //     4        5차선매도건수,
    offertotcnt: array [0..4] of char;   //     5        총매도건수,
    bidcnt1    : array [0..3] of char;   //     4        우선매수건수,
    bidcnt2    : array [0..3] of char;   //     4        차선매수건수,
    bidcnt3    : array [0..3] of char;   //     4        차차선매수건수,
    bidcnt4    : array [0..3] of char;   //     4        4차선매수건수,
    bidcnt5    : array [0..3] of char;   //     4        5차선매수건수,
    bidtotcnt  : array [0..4] of char;   //     5        총 매수 건수,

    offcnt1_chg : array [0..3] of char;   //    4        매도호가건수대비1,
    offcnt2_chg : array [0..3] of char;   //    4        매도호가건수대비2,
    offcnt3_chg : array [0..3] of char;   //    4        매도호가건수대비3,
    offcnt4_chg : array [0..3] of char;   //    4        매도호가건수대비4,
    offcnt5_chg : array [0..3] of char;   //    4        매도호가건수대비5,
    bidcnt1_chg : array [0..3] of char;   //    4        매수호가건수대비1,
    bidcnt2_chg : array [0..3] of char;   //    4        매수호가건수대비2,
    bidcnt3_chg : array [0..3] of char;   //    4        매수호가건수대비3,
    bidcnt4_chg : array [0..3] of char;   //    4        매수호가건수대비4,
    bidcnt5_chg : array [0..3] of char;   //    4        매수호가건수대비5,

    totrem_chg  : array [0..6] of char;   //    7        호가총잔량 차이,
  end;

  PAutoSymbolPrice = ^TAutoSymbolPrice;
  TAutoSymbolPrice = record
    jmcode    : array [0..7] of char;   //   8         종목코드,
    jmcodeseq : array [0..1] of char;   //   2         종목SEQ,
    time      : array [0..5] of char;   //   6         시간HH:MM:SS,
    price     : array [0..6] of char;   //   7         현재가[9(3)v99],
    open      : array [0..6] of char;   //   7         시가[9(3)v99],
    high      : array [0..6] of char;   //   7         고가[9(3)v99],
    low       : array [0..6] of char;   //   7         저가[9(3)v99],
    volume    : array [0..6] of char;   //   7         누적체결수량,
    bidvol    : array [0..6] of char;   //   7         누적매수체결량,
    value     : array [0..10] of char;  //  11         누적거래대금(천원->백만원),
    sign      : char;                   //   1       전일대비부호,
    change    : array [0..6] of char;   //   7         전일대비[9(3)v99],
    chgrate   : array [0..6] of char;   //   7         등락율,
    cvolume   : array [0..5] of char;   //     char,   6         체결수량,
    offerho1  : array [0..6] of char;   //    char,   7         매도우선호가[9(3)v9(2)],
    bidho1    : array [0..6] of char;   //      char,   7         매수우선호가[9(3)v9(2)],
    offerrem1 : array [0..5] of char;   //   char,   6         매도잔량,
    bidrem1   : array [0..5] of char;   //     char,   6         매수잔량,
    offerho2  : array [0..6] of char;   //    char,   7         차선매도호가[9(3)v9(2)],
    bidho2    : array [0..6] of char;   //      char,   7         차선매수호가[9(3)v9(2)],
    offerrem2 : array [0..5] of char;   //   char,   6         차선매도호가잔량,
    bidrem2   : array [0..5] of char;   //      char,   6         차선매수호가잔량,
    offerho3  : array [0..6] of char;   //    char,   7         차차선매도호가9(3)v9(2),
    bidho3    : array [0..6] of char;   //      char,   7         차차선매수호가9(3)v9(2),
    offerrem3 : array [0..5] of char;   //   char,   6         차차선매도호가잔량,
    bidrem3   : array [0..5] of char;   //     char,   6         차차선매수호가잔량,
    offertotrem : array [0..5] of char;   // char,   6         총매도호가잔량,
    bidtotrem : array [0..5] of char;   //   char,   6         총매수호가잔량,
    offerho4  : array [0..6] of char;   //    char,   7         4차선매도호가,
    bidho4    : array [0..6] of char;   //      char,   7         4차선매수호가,
    offerrem4 : array [0..5] of char;   //   char,   6         4차선매도잔량,
    bidrem4   : array [0..5] of char;   //     char,   6         4차선매수잔량,
    offerho5  : array [0..6] of char;   //    char,   7         5차선매도호가,
    bidho5    : array [0..6] of char;   //      char,   7         5차선매수호가,
    offerrem5 : array [0..5] of char;   //   char,   6         5차선매도잔량,
    bidrem5   : array [0..5] of char;   //     char,   6         5차선매수잔량,

    offercnt1 : array [0..3] of char;   //   char,   4         우선매도건수,
    offercnt2 : array [0..3] of char;   //   char,   4         차선매도건수,
    offercnt3 : array [0..3] of char;   //   char,   4         차차선매도건수,
    offercnt4 : array [0..3] of char;   //   char,   4         4차선매도건수,
    offercnt5 : array [0..3] of char;   //   char,   4         5차선매도건수,
    offertotcnt : array [0..4] of char;   // char,   5         총매도건수,

    bidcnt1 : array [0..3] of char;   //     char,   4         우선매수건수,
    bidcnt2 : array [0..3] of char;   //      char,   4         차선매수건수,
    bidcnt3 : array [0..3] of char;   //     char,   4         차차선매수건수,
    bidcnt4 : array [0..3] of char;   //     char,   4         4차선매수건수,
    bidcnt5 : array [0..3] of char;   //     char,   4         5차선매수건수,
    bidtotcnt : array [0..4] of char;   //   char,   5         총 매수 건수,

    theoryprice : array [0..6] of char;   // char,   7         이론가,

    openyak     : array [0..6] of char;   //     char,   7         미결제약정수량,
    openyakchg  : array [0..5] of char;   //  char,   6         미결제약정수량대비,
    gyurirate   : array [0..6] of char;   //   char,   7         괴리율,
    basis       : array [0..6] of char;   //       char,   7         시장베이시스,
    openchg     : array [0..6] of char;   //     char,   7         시가대비,
    highchg     : array [0..6] of char;   //     char,   7         고가대비,
    lowchg      : array [0..6] of char;   //      char,   7         저가대비,
    offcnt1_chg : array [0..3] of char;   // char,   4         매도호가건수대비1,
    offcnt2_chg : array [0..3] of char;   //  char,   4         매도호가건수대비2,
    offcnt3_chg : array [0..3] of char;   // char,   4         매도호가건수대비3,
    offcnt4_chg : array [0..3] of char;   // char,   4         매도호가건수대비4,
    offcnt5_chg : array [0..3] of char;   // char,   4         매도호가건수대비5,
    bidcnt1_chg : array [0..3] of char;   // char,   4         매수호가건수대비1,
    bidcnt2_chg : array [0..3] of char;   // char,   4         매수호가건수대비2,
    bidcnt3_chg : array [0..3] of char;   // char,   4         매수호가건수대비3,
    bidcnt4_chg : array [0..3] of char;   // char,   4         매수호가건수대비4,
    bidcnt5_chg : array [0..3] of char;   // char,   4         매수호가건수대비5,

    kospi200    : array [0..6] of char;   //    char,   7         kospi200,
    totrem_chg  : array [0..6] of char;   //  char,   7         호가총잔량 차이,
    tbasis      : array [0..6] of char;   //      char,   7         이론베이시스,
    volchange   : array [0..8] of char;   //   char,   9         거래량증감,
    valchange   : array [0..8] of char;   //   char,   9         거래대금증감,
    soonche     : array [0..8] of char;   //     char,   9         체결순매수,
    reallimit_gb: char;   //char,   1         실시간가격제한구분,
    real_hprice : array [0..6] of char;   // char,   7         실시간상한가[9(4)v99],
    real_lprice : array [0..6] of char;   // char,   7         실시간하한가[9(4)v99],
  end;


// 자동 Update : 투자자별매매현황(KOSPI200지수 선물)
  PAutoInvestFutDataSub = ^TAutoInvestFutDataSub;
  TAutoInvestFutDataSub = record
		InvstCode			: array [0..1] of char;	    //  /* 투자주체코드
											                        //  00.전체 01.금융투자 02.보험회사 03.투자신탁 04.은행
											                        //  05.기타금융 06.연기금등 07.기관계 08.기타법인 09.개인
											                        //  10.외국인 11.거주외국인 12.국가단체							*/
		BuyQty				: array [0..9] of char;     //	/* 매수수량(계약)												*/
		BuyAmt				: array [0..9] of char;     //	/* 매수대금(백만원)												*/
		BuyRate				: array [0..9] of char;     //	/* 매수 비율(%)	Float											*/
		SellQty				: array [0..9] of char;     //	/* 매도수량(계약)												*/
		SellAmt				: array [0..9] of char;     //	/* 매도대금(백만원)												*/
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
  end;

  PAutoInvestFutData = ^TAutoInvestFutData;
  TAutoInvestFutData = record
	  Header      : TCommonHeader;
		Time				: array [0..7] of char;       //	/* 시간(HH:MM:SS)												*/
		DataCnt			: array [0..1] of char;       //	/* 건수															*/
	  Sub_Ary			: array [0..12] of TAutoInvestFutDataSub;
  end;

// 자동 Update : 투자자별매매현황(KOSPI200지수 옵션)
  PAutoInvestOptDataSub = ^TAutoInvestOptDataSub;
  TAutoInvestOptDataSub = record
		InvstCode			: array [0..1] of char;	    //  /* 투자주체코드
											                        //  00.전체 01.금융투자 02.보험회사 03.투자신탁 04.은행
											                        //  05.기타금융 06.연기금등 07.기관계 08.기타법인 09.개인
											                        //  10.외국인 11.거주외국인 12.국가단체							*/
		BuyQty				: array [0..9] of char;     //	/* 매수수량(계약)												*/
		BuyAmt				: array [0..9] of char;     //	/* 매수대금(백만원)												*/
		BuyRate				: array [0..9] of char;     //	/* 매수 비율(%)	Float											*/
		SellQty				: array [0..9] of char;     //	/* 매도수량(계약)												*/
		SellAmt				: array [0..9] of char;     //	/* 매도대금(백만원)												*/
		SellRate			: array [0..9] of char;     //	/* 매도 비율(%)	Float											*/
		PurityQty			: array [0..9] of char;     //	/* 순매수수량(계약)												*/
		PurityAmt			: array [0..9] of char;     //	/* 순매수대금(백만원)											*/

		c_BuyQty			: array [0..9] of char;     //	/* 콜옵션매수수량(계약)										*/
		c_BuyAmt			: array [0..9] of char;     //	/* 콜옵션매수대금(백만원)										*/
		c_BuyRate		  : array [0..9] of char;     //	/* 매수 비율(%)	Float											*/
		c_SellQty		  : array [0..9] of char;     //	/* 콜옵션매도수량(계약)										*/
		c_SellAmt		  : array [0..9] of char;     //	/* 콜옵션매도대금(백만원)										*/
		c_SellRate		: array [0..9] of char;     //	/* 매도 비율(%)	Float											*/
		c_PurityQty	  : array [0..9] of char;     //	/* 콜옵션순매수수량(계약)										*/
		c_PurityAmt	  : array [0..9] of char;     //	/* 콜옵션순매수대금(백만원)									*/

		p_BuyQty			: array [0..9] of char;     //	/* 풋옵션매수수량(계약)										*/
		p_BuyAmt			: array [0..9] of char;     //	/* 풋옵션매수대금(백만원)										*/
		p_BuyRate		  : array [0..9] of char;     //	/* 매수 비율(%)	Float											*/
		p_SellQty		  : array [0..9] of char;     //	/* 풋옵션매도수량(계약)										*/
		p_SellAmt		  : array [0..9] of char;     //	/* 풋옵션매도대금(백만원)										*/
		p_SellRate		: array [0..9] of char;     //	/* 매도 비율(%)	Float											*/
		p_PurityQty	  : array [0..9] of char;     //	/* 풋옵션순매수수량(계약)										*/
		p_PurityAmt	  : array [0..9] of char;     //	/* 풋옵션순매수대금(백만원)									*/
  end;

  PAutoInvestOptData = ^TAutoInvestOptData;
  TAutoInvestOptData = record
	  Header      : TCommonHeader;
		Time				: array [0..7] of char;       //	/* 시간(HH:MM:SS)												*/
		DataCnt			: array [0..1] of char;       //	/* 건수															*/
	  Sub_Ary			: array [0..12] of TAutoInvestOptDataSub;
  end;


{$ENDREGION}

/////////////////////////////////////////////////////?

{$REGION '계좌조회....'}

  // 5111   계좌 실체결 조회

  PReqAccountFill = ^TREqAccountFill;
  TReqAccountFill = record
    Header    : TCommonHeader;
    Account	 : array [0..10] of char;   //	/* 계좌번호														*/
    Pass		 : array [0..7] of char;    //	/* 비밀번호														*/
    Market_Kind: char;                  //	/* 시장구분 (0.전체 1.KSE 2.KSE지수 3.KSE주식옵션 4.KOFEX)		*/
    Trace_Kind	 : char;      			    //	/* 체결구분 (0:전체 1:체결2:미체결)								*/
    Order_Date	 : array [0..7] of char;    //	/* 주문일자														*/
    Gubn		 : char;                    //  /* 조회순서 (1:정순 2:역순)
  end;

  // 최대 20개
  POutAccountFillSub = ^TOutAccountFillSub;
  TOutAccountFillSub = record
//    Header    : TCommonHeader;
		Jmno			: array [0..9] of char;   //	/* 주문주번호													*/
		Wjmno			: array	[0..9] of char;   //	/* 원주문부번호													*/
		FullCode	: array	[0..11] of char;  //	/* 종목번호														*/
		Jmhg			: array	[0..19] of char;  //	/* 종목명														*/
		Mmcd			: char;                   //	/* 매매구분코드
                                        //    1.매수 2.매도 3.매수정정 4.매도정정
                                        //    5.매수취소 6.매도취소 ' '.기타								*/
		Mmgb			: array [0..7] of char;   //	/* 매매구분 													*/
		Jmqt			: array [0..6] of char;   //	/* 주문수량														*/
		Hogb			: char;                   //	/* 가격구분
                                        //    1:지정가 2:시장가 3:조건부지정가 4:최유리지정가
                                        //    5:지정가IOC 6:지정가FOK 7:시장가IOC 8:시장가FOK
                                        //    9:최유리IOC A:최유리FOK										*/
		Jmjs			: array	[0..8] of char;   //	/* 주문지수														*/
		Mcgqt			: array	[0..6] of char;   //	/* 미체결수량 													*/
		Cgqt			: array	[0..6] of char;   //	/* 체결수량														*/
		Cgjs			: array	[0..8] of char;   //	/* 체결지수														*/
		Cgtm			: array	[0..7] of char;   //	/* 접수시간 													*/
		Stat			: array	[0..7] of char;   //	/* 접수상태 													*/
		Grjn			: array	[0..10] of char;  //	/* 접수번호														*/
		Susu			: array	[0..9] of char;   //	/* 수수료														*/
		Cggm			: array	[0..14] of char;  //	/* 약정금액														*/
		Sggm			: array	[0..14] of char;  //	/* 스프레드약정금액												*/
		Plus			: char;                   //	/* 1:+															*/
		Account		: array	[0..10] of char;	//  /* 계좌번호
  end;

  POutAccountFill = ^TOutAccountFill;
  TOutAccountFill = record
    Header    : TCommonHeader;
    Account		: array [0..10] of char;      //	/* 계좌번호														*/
    AcctNm		: array [0..19] of char;      //	/* 계좌명														*/
    Dtno			: array [0..4] of char;       //	/* 반복횟수
  end;

  // 5112   계좌 실잔고 조회

  PReqAccountPos = ^TReqAccountPos;
  TReqAccountPos = record
    Header    : TCommonHeader;
    Account		: array [0..10] of char;    //	/* 계좌번호														*/
    Pass			: array [0..7] of char;     //	/* 비밀번호
    Gubn			: char;                     //	/* 시장구분 (0.시장전체)
  end;

  // 최대 20개
  POutAccountPosSub = ^TOutAccountPosSub;
  TOutAccountPosSub = record
		FullCode	 : array [0..11] of char;   //	/* 종목코드														*/
		Jmhg			 : array [0..19] of char;   //	/* 종목명														*/
		Mmcd			 : char;                    //	/* 매매코드 (1.매도 2.매수)										*/
		Mmgb			 : array [0..3] of char;    //	/* 매매구분 													*/
		Jgqt			 : array [0..5] of char;    //	/* 잔고수량														*/
		Jmqt			 : array [0..5] of char;    //	/* 주문가능수량													*/
		Curr			 : array [0..8] of char;    //	/* 현재가		/ 100												*/
		Avgt			 : array [0..11] of char;   //	/* 평균가 		/ 100000												*/
		Fagm			 : array [0..14] of char;   //	/* 평가금액														*/
		Sonic			 : array [0..14] of char;   //	/* 평가손익 													*/
		Srate			 : array [0..6] of char;    //	/* 손익율 														*/
		CAvgt			 : array [0..11] of char;   //	/* 종가기준가격 												*/
		CFagm			 : array [0..14] of char;   //	/* 평가금액														*/
		CSonic		 : array [0..14] of char;   //	/* 평가손익 													*/
		CSrate		 : array [0..6] of char;    //	/* 손익율 														*/
    Account	   : array [0..10] of char;   //  /* 계좌번호														*/
  end;

  POutAccountPos = ^TOutAccountPos;
  TOutAccountPos = record
	  Header     : TCommonHeader;
		Account		 : array [0..10] of char;   //	/* 계좌번호														*/
		Accont_Name: array [0..19] of char;   //	/* 계좌명														*/
		Yttm			 : array [0..14] of char;   //	/* 예탁총액 													*/
		Jscg			 : array [0..14] of char;   //	/* 정산차금														*/
		Opgm			 : array [0..14] of char;   //	/* 옵션결제차금													*/
		Susu			 : array [0..14] of char;   //	/* 수수료														*/
		Cyttm			 : array [0..14] of char;   //	/* 익일추정예수금												*/
		Fyttm			 : array [0..14] of char;   //	/* 평가예탁총액													*/
		Dtno			 : array [0..4] of char;    //	/* 반복횟수
  end;

  // 5122  예탁자산및 증거금

  PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountDeposit = record
	  Header     : TCommonHeader;
		Account		 : array [0..10] of char;	          //  /* 계좌번호														*/
		Pass			 : array [0..7] of char;            //	/* 비밀번호														*/
  end;

    //최대 5개
  ROutAccountDepositSub = ^TOutAccountDepositSub;
  TOutAccountDepositSub = record
		Fjamt				: array [0..14] of char;    //	/* 선물매도매수금액												*/
		Sjamt				: array [0..14] of char;    //	/* 스프레드금액													*/
		Ojsm				: array [0..14] of char;    //	/* 옵션매수금액													*/
		Ojdm				: array [0..14] of char;    //	/* 옵션매도금액													*/
		Otjm				: array [0..14] of char;    //	/* 옵션가겨증거금												*/
		Pfjm				: array [0..14] of char;    //	/* 가격변동증거금												*/
		Spgm				: array [0..14] of char;    //	/* 스프레드증거금												*/
		Insdm				: array [0..14] of char;    //	/* 실물인수도금액												*/
		Gtjm				: array [0..14] of char;    //	/* 최소증거금													*/
		Mmsi				: array [0..14] of char;    //	/* 당일선물순손실액												*/
		Opgm				: array [0..14] of char;    //	/* 당일옵션순매수대금
  end;

  ROutAccountDeposit = ^TOutAccountDeposit;
  TOutAccountDeposit = record
	  Header      : TCommonHeader;
		Syttm				: array [0..14] of char;    //	/* 장개시전예탁총액												*/
		Sythg				: array [0..14] of char;    //	/* 장개시전예탁현금												*/
		Sytdy				: array [0..14] of char;    //	/* 장개시전예탁대용												*/
		Yttm				: array [0..14] of char;    //	/* 익일예탁총액													*/
		Ythg				: array [0..14] of char;    //	/* 익일예탁현금													*/
		Ytdy				: array [0..14] of char;    //	/* 익일예탁대용													*/
		Ytjm				: array [0..14] of char;    //	/* 위탁증거금총액												*/
		Ycjm				: array [0..14] of char;    //	/* 위탁현금증거금												*/
		Ydjm				: array [0..14] of char;    //	/* 위탁대용증거금												*/
		Cjgtm				: array [0..14] of char;    //	/* 추가증거금총액												*/
		Cjghg				: array [0..14] of char;    //	/* 추가증거금현금 												*/
		Cjgdy				: array [0..14] of char;    //	/* 추가증거금대용												*/
		Jgtm				: array [0..14] of char;    //	/* 주문증거금총액												*/
		Jghg				: array [0..14] of char;    //	/* 주문증거금현금												*/
		Jgdy				: array [0..14] of char;    //	/* 주문증거금대용												*/
		Ictm				: array [0..14] of char;    //	/* 인출가능총액													*/
		Ichg				: array [0..14] of char;    //	/* 인출가능현금													*/
		Icdy				: array [0..14] of char;    //	/* 인출가능대용													*/
		Ytjy				: array [0..14] of char;    //	/* 유지증거금총액												*/
		Ycjy				: array [0..14] of char;    //	/* 유지현금증거금												*/
		Ydjy				: array [0..14] of char;    //	/* 유지대용증거금												*/
		Jscg				: array [0..14] of char;    //	/* 선물정산(결제)차금											*/
		Susu				: array [0..14] of char;    //	/* 수수료
    SubData     : TOutAccountDepositSub;    //  0.전체 1.지수상품군 2.국채상품군
											                      //    3.통화상품군 4.COMMODITY상품군
  end;

  POutAccountAdjustMent = ^TOutAccountAdjustMent;
  TOutAccountAdjustMent = record
	  Header      : TCommonHeader;
		Tyttm				: array [0..12] of char;    //	/* 예탁총액														*/
		Jscg				: array [0..12] of char;    //	/* 선물정산차금													*/
		Dicg				: array [0..12] of char;    //	/* 선물당일차금													*/
		Gscg				: array [0..12] of char;    //	/* 선물갱신차금													*/
		Cjcg				: array [0..12] of char;    //	/* 선물최종결제차금												*/
		Kjcg				: array [0..12] of char;    //	/* 옵션결제차금													*/
		Mdgm				: array [0..12] of char;    //	/* 옵션매도금액													*/
		Msgm				: array [0..12] of char;    //	/* 옵션매수금액													*/
		Cpgm				: array [0..12] of char;    //	/* 옵션최종차금													*/
		Susu				: array [0..12] of char;    //	/* 수수료합계													*/
		Fsusu				: array [0..12] of char;    //	/* 선물수수료													*/
		Osusu				: array [0..12] of char;    //	/* 옵션수수료													*/
		Cyttm				: array [0..12] of char;    //	/* 추정예탁총액													*/
		Fcsgm				: array [0..12] of char;    //	/* 선물청산손익													*/
		Ffagm				: array [0..12] of char;    //	/* 선물평가손익													*/
		Ocsgm				: array [0..12] of char;    //	/* 옵션청산손익													*/
		Ofagm				: array [0..12] of char;    //	/* 옵션평가손익													*/
		Fyttm				: array [0..12] of char;    //	/* 평가예탁총액													*/
		Yttm				: array [0..12] of char;    //	/* 예탁총액														*/
		Ythg				: array [0..12] of char;    //	/* 예탁현금														*/
		Ytdy				: array [0..12] of char;    //	/* 예탁대용														*/
		Jmgtm				: array [0..12] of char;    //	/* 주문가능총액													*/
		Jmghg				: array [0..12] of char;    //	/* 주문가능현금													*/
		Jmgdy				: array [0..12] of char;    //	/* 주문가능대용													*/
		Ictm				: array [0..12] of char;    //	/* 인출가능총액													*/
		Ichg				: array [0..12] of char;    //	/* 인출가능현금													*/
		Icdy				: array [0..12] of char;    //	/* 인출가능대용													*/
		Ictm_1			: array [0..12] of char;    //	/* 인출가능총액 D+1												*/
		Ichg_1			: array [0..12] of char;    //	/* 인출가능현금 D+1												*/
		Icdy_1			: array [0..12] of char;    //	/* 인출가능대용 D+1												*/
		Ytjm				: array [0..12] of char;    //	/* 위탁증거금총액												*/
		Ycjm				: array [0..12] of char;    //	/* 위탁현금증거금												*/
		Ydjm				: array [0..12] of char;    //	/* 위탁대용증거금												*/
		Ytjm_1			: array [0..12] of char;    //	/* 위탁증거금총액 D+1											*/
		Ycjm_1			: array [0..12] of char;    //	/* 위탁증거금현금 D+1											*/
		Ydjm_1			: array [0..12] of char;    //	/* 위탁증거금대용 D+1											*/
		Cjgtm				: array [0..12] of char;    //	/* 추가증거금총액												*/
		Cjghg				: array [0..12] of char;    //	/* 추가증거금현금 												*/
		Cjgdy				: array [0..12] of char;    //	/* 추가증거금대용 												*/
		Cjgtm_1			: array [0..12] of char;    //	/* 주문가능총액		D+1											*/
		Cjghg_1			: array [0..12] of char;    //	/* 주문가능현금		D+1											*/
		Cjgdy_1			: array [0..12] of char;    //	/* 주문가능대용		D+1											*/
		Ytjy				: array [0..12] of char;    //	/* 유지증거금총액												*/
		Ycjy				: array [0..12] of char;    //	/* 유지현금증거금												*/
		Ydjy				: array [0..12] of char;    //	/* 유지대용증거금												*/
		Ogjgm				: array [0..12] of char;    //	/* 미수금잔액													*/
		Syttm				: array [0..12] of char;    //	/* 개장시예탁총액												*/
		Ipgm				: array [0..12] of char;    //	/* 당일입출금액													*/
		Dgjgm				: array [0..12] of char;    //	/* 익일결제예정금액												*/
		Dyttm				: array [0..12] of char;    //	/* 익일예탁총액
  end;

  // 주문가능수량  5130

  PReqAbleQty = ^TReqAbleQty;
  TReqAbleQty = record
    Header      : TCommonHeader;
    Account			: array [0..10] of char;          //	/* 계좌번호														*/
    Pass				: array [0..7] of char;           //	/* 비밀번호														*/
    Bysl_tp			: char;                           //	/* 매매구분	(1.매도	2.매수)										*/
    FullCode		: array [0..11] of char;          //	/* 단축코드														*/
    Gggb				: char;                           //	/* 주문유형구분
                                                  //    1.지정가 2.시장가 3.조건부지정가 4.최유리지정가
                                                  //    5.지정가(IOC) 6.지정가(FOK)									*/
	  Jmjs				: array [0..8] of char;           //	/* 주문가격
  end;

  POutAbleQty = ^TOutAbleQty;
  TOutAbleQty = record
	  Header      : TCommonHeader;
	  Account			: array	[0..10] of char;    //	/* 계좌번호														*/
		Pass				: array [0..7] of char;     //	/* 비밀번호														*/
		Mmgb				: char;                     //	/* 매매구분 (1.매도 2.매수)										*/
		FullCode		: array [0..11] of char;    //	/* 종목번호														*/
		Gggb				: char;                     //	/* 가격조건	(1.지정가 2.시장가 3.조건부지정가 4.최유리지정가)	*/
		Curr				: array [0..8] of char;     //	/* 현재가격														*/
		Jmjs				: array [0..8] of char;     //	/* 주문가격														*/
		Jmgqt1			: array [0..6] of char;     //	/* 신규주문가능수량												*/
		Jmgqt2			: array [0..6] of char;     //	/* 청산주문가능수량
  end;

{$ENDREGION}


{$REGION '주문....'}

  // 5101 신규

  PNewOrderPacket = ^TNewOrderPacket;
  TNewOrderPacket = record
	  Header        : TCommonHeader;
	  Account			: array [0..10] of char;    //	/* 계좌번호														*/
		Pass				  : array [0..7] of char;     //	/* 비밀번호														*/
		FullCode			: array [0..11] of char;    //	/* 종목코드														*/
		Order_Volume	: array	[0..9] of char;     //	/* 주문수량														*/
		Order_Boho		: char;                     //	/* 가격부호 (+.양수 -.음수) 									*/
		Order_Price		: array	[0..10] of char;    //	/* 주문지수														*/
		BuySell_Type	: char;                     //	/* 매매구분	(1.매도 2:매수)										*/
		Price_Type		: char;                     //	/* 가격조건 (1.지정가 2.시장가 3.조건부지정가 4.최유리지정가)	*/
		Trace_Type		: char;                     //	/* 체결조건 (0.정상 1.IOC 2.FOK)								*/
		Order_Comm_Type: array [0..1] of char;    //	/* 통신구분														*/
		GroupCode			: array [0..5] of char;     //	/* 그룹코드														*/
		IpAddr				: array [0..11] of char;    //	/* GetLocalIpAddress 함수 사용									*/
		Order_Type		: char;                     //	/* 주문종류 (1.일반주문 2.협의대량주문)							*/
		Hbno				  : array [0..2] of char;     //	/* 협의대량거래 상대회원번호									*/
		Hbgj				  : array [0..11] of char;    //	/* 협의대량거래 상대계좌번호									*/
		Hbtm				  : array [0..3] of char;     //	/* 협의대량거래 시간
    User_Field		: array [0..9] of char;     //	/* 사용자 역역													*/
  end;

  POutNewOrderPacket = ^TOutNewOrderPacket;
  TOutNewOrderPacket = record
    Header        : TCommonHeader;
	  Account				: array [0..10] of char;    //	/* 계좌번호														*/
		Pass				  : array [0..7] of char;     //	/* 비밀번호														*/
		OrderNo				: array [0..9] of char;     //	/* 주문번호														*/
		FullCode			: array [0..11] of char;    //	/* 종목코드														*/
		Order_Volume	: array [0..9] of char;     //	/* 주문수량														*/
		Order_Boho		: char;                     //	/* 가격부호	(+.양수 -.음수) 									*/
		Order_Price		: array [0..10] of char;    //	/* 주문지수														*/
		BuySell_Type	: char;                     //	/* 매매구분 (1.매도 2.매수)										*/
		Price_Type		: char;                     //	/* 가격조건 (1.지정가 2.시장가 3.조건부지정가 4.최유리지정가)	*/
		Trace_Type		: char;                     //	/* 체결조건 (0.정상 1.IOC 2.FOK)								*/
		Order_Comm_Type: array [0..1] of char;    //	/* 통신구분 													*/
		GroupCode			 : array [0..5] of char;    //	/* 그룹코드
    User_Field		: array [0..9] of char;     //	/* 사용자 역역													*/
    // 오류일때만 생기는....필드
    ErrorMsg  : array [0..99] of char;
  end;

  // 5102 정정

  PChangeOrderPacket = ^TChangeOrderPacket;
  TChangeOrderPacket = record
    Header        : TCommonHeader;
		Account				: array [0..10] of char;    //	/* 계좌번호														*/
		Pass				  : array [0..7] of char;     //	/* 비밀번호														*/
		FullCode			: array [0..11] of char;    //	/* 종목코드														*/
		Order_Volume	: array [0..9] of char;     //	/* 주문수량														*/
		Order_Boho		: char;                     //	/* 주문가격부호	(+.양수 -.음수)									*/
		Order_Price		: array	[0..10] of char;    // 	/* 주문지수														*/
		Price_Type		: char;                     //	/* 가격조건	(1.지정가 2.시장가 3.조건부지정가 4.최유리지정가)	*/
		Trace_Type		: char;                     //	/* 체결조건 (0.정상 1.IOC 2.FOK)								*/
		WOrderNo			: array [0..9] of char;     //	/* 원주문번호													*/
		Order_Comm_Type: array 		[0..1] of char; //	/* 통신구분														*/
		GroupNo				: array [0..5] of char;     //  /* 그룹코드														*/
		IpAddr				: array [0..11] of char;    //	/* GetLocalIpAddress 함수 사용									*/
		Order_Type		: char;                     //	/* 주문구분 (1.일반주문 2.협의대량주문)							*/
		Hbno				  : array [0..2] of char;     //	/* 협의대량거래 상대회원번호									*/
		Hbgj				  : array [0..11] of char;    //	/* 협의대량거래 상대계좌번호
    User_Field		: array [0..9] of char;     //	/* 사용자 역역													*/
  end;

  POutChangeOrderPacket = ^TOutChangeOrderPacket;
  TOutChangeOrderPacket = record
    Header        : TCommonHeader;
		Account				: array [0..10] of char;    //	/* 계좌번호														*/
		Pass				  : array [0..7] of char;     //	/* 비밀번호														*/
		OrderNo				: array [0..9] of char;     //	/* 주문번호														*/
		WOrderNo			: array [0..9] of char;     //	/* 원주문번호													*/
		FullCode			: array [0..11] of char;    //	/* 종목코드														*/
		Order_Volume	: array [0..9] of char;     //	/* 주문수량														*/
		Order_Boho		:char;                      //	/* 주문가격부호 (+.양수 -음수)									*/
		Order_Price		: array	[0..10] of char;    //	/* 주문지수														*/
		Price_Type		:char;                      //	/* 가격조건 (1.지정가 2.시장가 3.조건부지정가 4.최유리지정가)	*/
		Trace_Type		:char;                      //	/* 체결조건 (0.정상 1.IOC 2.FOK)								*/
		Order_Comm_Type: array [0..1] of char;    //	/* 통신구분 													*/
		GroupNo				: array [0..5] of char;     //	/* 그룹코드
    User_Field		: array [0..9] of char;     //	/* 사용자 역역													*/
    // 오류일때만 생기는....필드
    ErrorMsg  : array [0..99] of char;
  end;

  // 취소 5103
  PCancelOrderPacket = ^TCancelOrderPacket;
  TCancelOrderPacket = record
	  Header        : TCommonHeader;
		Account				: array [0..10] of char;    //	/* 계좌번호														*/
		Pass				  : array [0..7] of char;     //	/* 비밀번호														*/
		FullCode			: array [0..11] of char;    //	/* 종목코드														*/
		Order_Volume	: array [0..9] of char;     //	/* 주문수량														*/
		WOrderNo			: array [0..9] of char;     //	/* 원주문번호													*/
		Order_Comm_Type: array[0..1] of char;     //	/* 통신구분														*/
		GroupNo				: array [0..5] of char;     //	/* 그룹코드														*/
		IpAddr				: array [0..11] of char;    //	/* GetLocalIpAddress 함수 사용									*/
    User_Field		: array [0..9] of char;     //	/* 사용자 역역													*/
  end;

  POutCancelOrderPacket = ^TOutCancelOrderPacket;
  TOutCancelOrderPacket = record
	  Header        : TCommonHeader;
		Account				: array [0..10] of char;    //   /* 계좌번호														*/
		Pass				  : array [0..7] of char;     //	/* 비밀번호														*/
		OrderNo				: array [0..9] of char;     //	/* 주문번호														*/
		WOrderNo			: array [0..9] of char;     //	/* 원주문번호													*/
		FullCode			: array [0..11] of char;    //	/* 종목코드														*/
		Order_Volume	: array [0..9] of char;     //	/* 주문수량														*/
		Order_Comm_Type: array[0..1] of char;     //	/* 통신구분 													*/
		GroupNo				: array [0..5] of char;     //	/* 그룹코드
    User_Field		: array [0..9] of char;     //	/* 사용자 역역													*/
    // 오류일때만 생기는....필드
    ErrorMsg  : array [0..99] of char;
  end;

  PUnioKrPacket = ^UnionKrPacket;
  UnionKrPacket = packed record
    case Integer of
      0: ( KrNew        :       TOutNewOrderPacket; );
      1: ( KrChange     :       TOutChangeOrderPacket; );
      2: ( KrCancel     :       TOutCancelOrderPacket; );
  end;

  PAutoOrderPacketSub = ^TAutoOrderPacketSub;
  TAutoOrderPacketSub = record
		trcode				: char;                       //	/* 1:주문접수,2:체결,3:정정확인	4:취소확인,5:주문거부,6:자동취소*/
		trgb				  : char;                       //	/*	1:신규거부,2:정정거부,3:취소거부
											                          //      4:신규접수,5:정정접수,6:취소접수							*/
		spgb				  : char;                       //	/* Y:일반, N:스프레드체결										*/
		accno				  : array [0..10] of char;      //	/* 계좌 번호 (지점(3)+상품(2)+계좌번호(6))						*/
		jmcd			  	: array [0..11] of char;      //	/* 종목코드														*/
		mrkt				  : array [0..1] of char;       //	/* 시장구분
                                                //      코스피지수   -> 01 3년국채선물  -> 61 통안증권금리 -> 62
                                                //      5년국채선물  -> 63 10년국채선물 -> 64 미국달러     -> 75
                                                //      엔달러       -> 76 유로달러     -> 77						*/
		grjn				  : array [0..9] of char;       //	/* 주문번호														*/
		wgrjn			    : array [0..9] of char;       //	/* 원주문번호													*/
		jmgb				  : char ;                      //	/* 포지션구분 (1.매도 2.매수)									*/
		gggb				  : char;                       //	/* 주문형태 (1:지정가)											*/
		jmtp				  : char;                       //	/* 체결조건 (0:일반)											*/
		jmjs			  	: array [0..6] of char;       //	/* 주문지수														*/
		jmqt				  : array [0..7] of char;       //	/* 주문수량(주문수량-(정정+취소))								*/
		cgjs				  : array [0..8] of char;       //	/* 체결단가														*/
		cgqt				  : array [0..7] of char;       //	/* 체결수량														*/
		jspm				  : array [0..7] of char;       //	/* 주문확인,체결,거부 시간										*/
		jggb 				  : char;                       //	/* 잔고구분(1:매도,2:매수,3:잔고 ZERO)							*/
		avgpr				  : array [0..7] of char;       //	/* 평균단가														*/
		gjqt 				  : array [0..7] of char;       //	/* 잔고수량														*/
		miqt				  : array [0..7] of char;       //	/* 신규미체결수													*/
		bmiqt				  : array [0..7] of char;       //	/* 미체결수 (반대 포지션의)										*/
		gbsy				  : array [0..3] of char;       //	/* 거부사유코드													*/
		pro_chk				: char;                       //	/* 체결flag(정정보다체결이먼저옴)								*/
										                            //  /* default ' ' 아니면 '1'										*/
		currprice			: array [0..8] of char;       //	/* 현재가														*/
		near_Jmcd			: array [0..11] of char;      //	/* 최근월물 종목코드(X)											*/
		next_Jmcd			: array [0..11] of char;      //	/* 차근월물 종목코드(X)											*/
    User_Field		: array [0..9] of char;       //	/* 사용자 역역													*/
  end;

  PAutoOrderPacket = ^TAutoOrderPacket;
  TAutoOrderPacket = record
    Header        : TCommonHeader;
    Count         : array [0..2] of char;
  end;
{$ENDREGION}


Const
  Len_AccountInfo   = SizeOf( TOutAccountInfo );
  Len_FutureInfo    = sizeof( TOutFutureInfo );
  Len_OptionInfo    = sizeof( TOutOptionInfo );

  Len_SymbolListInfo = SizeOf( TOutSymbolListInfo );
  Len_OutSymbolMaster = sizeof( TOutSymbolMaster );

  Len_OutSymbolMarkePrice  = sizeof(TOutSymbolMarkePrice);
  Len_ReqChartData = sizeof( TReqChartData );
  Len_OutChartData = sizeof( TOutChartData );
  Len_OutChartDataSub = sizeof( TOutChartDataSub );
  // 계좌
  // 주문리스트 요청
  Len_ReqAccountFill = sizeof( TReqAccountFill );
  Len_OutAccountFillSub = sizeof( TOutAccountFillSub );
  Len_OutAccountFill  = sizeof( TOutAccountFill );
  // 잔고
  Len_ReqAccountPos = sizeof( TReqAccountPos );
  Len_OutAccountPos = sizeof( TOutAccountPOs );
  Len_OutAccountPosSub = sizeof( TOutAccountPosSub );
  // 예수금
  Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  Len_OutAccountDepositSub = sizeof( TOutAccountDepositSub );
  Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
  // 정산내역
  Len_OutAccountAdjustMent = sizeof( TOutAccountAdjustMent );
  // 가능수량
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  // 실시간 요청
  Len_SendAutoKey = sizeof( TSendAutoKey );
      // 체결
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );

  // 주문
  Len_NewOrderPacket = sizeof(TNewOrderPacket);
  Len_OutNewOrderPacket  = sizeof(TOutNewOrderPacket);
  Len_ChangeOrderPacket  = sizeof(TChangeOrderPacket);
  Len_OutChangeOrderPacket = sizeof(TOutChangeOrderPacket);
  Len_CancelOrderPacket  = sizeof(TCancelOrderPacket);
  Len_OutCancelOrderPacket = sizeof(TOutCancelOrderPacket);
  //Len_AutoOrderPacket = sizeof(TAutoOrderPacket);
  Len_AutoOrderPacketSub = sizeof(TAutoOrderPacketSub);

implementation

end.
