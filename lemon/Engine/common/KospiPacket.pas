unit KospiPacket;

interface

type
  PKospiHeader = ^TKospiHeader;
  TKospiHeader = packed record
    DataSeq     : array [0..7] of char;
    DataKind    : array [0..2] of char;   // 데이타종류 500 : 매수, 501 : 매도
    DataCls     : array [0..2] of char;   // * 데이타분류
    PrdtNo      : array [0..11] of char;  // 종목번호
    MemberNo    : array [0..2] of char;   // 회원번호
    BranchNo    : array [0..2] of char;   // 지점번호
  end;        

  PKospiOrder = ^TKospiOrder;
  TKospiOrder = packed record
    KospiHeader : TKospiHeader;
    OrderNo     : array [0..4] of char;   // 주문번호
    OriginNo    : array [0..4] of char;   // 원주문번호
    AccountNo   : array [0..11] of char;  // 계좌번호
    OrderQty    : array [0..7] of char;   // 주문수량
    OrdPrice    : array [0..8] of char;   // 주문가격
    OrderDiv    : array [0..1] of char;   // * 주문구분
    CreditDiv   : array [0..1] of char;   // * 신용구분
    Foreigner   : array [0..1] of char;   // 외국인투자자분류
    ExcuteCon   : array [0..1] of char;   // 집행조건
    InvestCode  : array [0..3] of char;   // * 투자가코드
    NotMemNo    : array [0..2] of char;   // 비회원번호  0: 회원
    Exemption   : array [0..1] of char;   // 비과세여부 0:과세, 1:비과세
    ForeigNo    : array [0..5] of char;   // 외국인고유번호;
    ForeigNo2   : array [0..2] of char;   // 외국인 국가번호
    TrustDiv    : array [0..1] of char;   // 위탁상품구분 1:위탁, 2:상품
    AceptTime   : array [0..7] of char;   // 증권사주문접수시각
    ProgramOrd  : array [0..1] of char;   // 프로그램호가여부
    RjctReason  : array [0..1] of char;   // * 거부사유
    OAskDiv     : array [0..1] of char;   // 공매도구분 0:정상, 1: 차입주식매도
    MediaDiv    : array [0..1] of char;   // 주문입력매체구분 1:영업점, 2:유선단말
    DealerInfo  : array [0..11] of char;  // 주문자식별정보
    FreeArea    : array [0..4] of char;
    LargeTrade  : array [0..9] of char;   // 대량거래
    OrderCon    : array [0..1] of char;   // 주문조건 0:없음 1:IOC 2:FOK
    LPHogaDiv   : array [0..1] of char;   // 유동성공급호가여부 0:정상 1: 유동공급자호가
    ForeigAcnt  : array [0..1] of char;
    Filler      : array [0..1] of char;   // Filler
  end;


  // 101:매수체결결과,  111:매도체결결과
  PKospiFill  = ^TKospiFill;
  TKospiFill  = packed record
    KospiHeader : TKospiHeader;
    NotMemNo    : array [0..2] of char;   // 비회원번호
    OrderNo     : array [0..4] of char;   // 주문번호
    OriginNo    : array [0..4] of char;   // 원주문번호
    AccountNo   : array [0..11] of char;  // 계좌번호
    ForeigNo    : array [0..5] of char;   // 외국인고유번호;

    FillNo      : array [0..6] of char;   // 체결번호
    FillQty     : array [0..7] of char;   // 체결수량
    FillPrice   : array [0..8] of char;   // 체결가격
    FillDate    : array [0..7] of char;   // 체결일
    FillTime    : array [0..7] of char;   // 체결시각
    FreeArea    : array [0..4] of char;   // 회원사사용필드
    FillType    : array [0..1] of char;   // * 체결유형
    Filler      : array [0..6] of char;
    SystemDiv   : char;                   // 시스템구분 0: 가동, 1: 대체
    GroupNo     : array [0..1] of char;   // 그룹번호
    GroupSeq    : array [0..7] of char;
  end;

  // 109:매수체결결과,  119:매도체결결과
  PKospiReject  = ^TKospiReject;
  TKospiReject  = packed record
    KospiHeader : TKospiHeader;
    NotMemNo    : array [0..2] of char;   // 비회원번호
    OrderNo     : array [0..4] of char;   // 주문번호
    OriginNo    : array [0..4] of char;   // 원주문번호
    AccountNo   : array [0..11] of char;  // 계좌번호
    ForeigNo    : array [0..5] of char;   // 외국인고유번호;

    RjtQty      : array [0..7] of char;   // 거부수량
    RjtPrice    : array [0..8] of char;   // 거부가격
    RjtReason   : array [0..1] of char;   // 거부사유
    RjtDate     : array [0..7] of char;   // 거부일
    RjtTime     : array [0..7] of char;   // 거부시간

    FreeArea    : array [0..4] of char;   // 회원사사용필드

    Filler      : array [0..13] of char;
    SystemDiv   : char;                   // 시스템구분 0: 가동, 1: 대체
    GroupNo     : array [0..1] of char;   // 그룹번호
    GroupSeq    : array [0..7] of char;
  end;

  //103:매수취소확인,  113:매도취소확인
  //104:매수조건주문취소확인(2004.01.26)
  //114:매도조건주문취소확인(2004.01.26)
  //PKospiCancel = ^TKospiConfirm;
  // 102:매수정정확인,  112:매도정정확인

  PKospiConfirm = ^TKospiConfirm;
  TKospiConfirm = packed record
    KospiHeader : TKospiHeader;
    NotMemNo    : array [0..2] of char;   // 비회원번호
    OrderNo     : array [0..4] of char;   // 주문번호
    OriginNo    : array [0..4] of char;   // 원주문번호
    AccountNo   : array [0..11] of char;  // 계좌번호
    ForeigNo    : array [0..5] of char;   // 외국인고유번호;

    OriginQty   : array [0..7] of char;   // 원주문수량
    OriginPrice : array [0..8] of char;   // 원주문가격
    CorectQty   : array [0..7] of char;   // 정정취소수량 : 정정주문수량중 정정된수량
    CorectPrice : array [0..8] of char;   // 정정취소가격 : 정정주문의 가격
    FreeArea    : array [0..4] of char;
    Filler      : array [0..14] of char;
    SystemDiv   : char;                   // 시스템구분 0: 가동, 1: 대체
    GroupNo     : array [0..1] of char;   // 그룹번호
    GroupSeq    : array [0..7] of char;
  end;

  // recovery data format
  PServerHeader = ^TServerHeader;
  TServerHeader = packed record
    DataDiv    : array [0..1] of char;
    DataSize   : array [0..3] of char;
    UserID     : array [0..2] of char;
  end;

  // postion          [SP]
  PRecovery = ^TRecovery;
  TRecovery = packed record
    SvrHeader   : TServerHeader;
    AccountNo   : array [0..11] of char;
    Market      : char;
    PrdtNo      : array [0..11] of char;  // 좌측 정렬

    PrevVol     : array [0..5] of char;
    PrevAmt     : array [0..14] of char;
    SellVol     : array [0..5] of char;
    BuyVol      : array [0..5] of char;
    SellAmt     : array [0..14] of char;
    BuyAmt      : array [0..14] of char;

    OpenVol     : array [0..5] of char;
    OpenAmt     : array [0..14] of char;
    OpenPrice   : array [0..5] of char;

    PrevFixedPL : array [0..14] of char;
    FixedPL     : array [0..14] of char;
    FixedToTalPL: array [0..14] of char;

    p_buyFee    : array [0..14] of char;
    p_sellFee   : array [0..14] of char;
    p_useFee    : array [0..14] of char;
    p_lendFee   : array [0..14] of char;
    p_makeProfit: array [0..14] of char;

    t_buyFee    : array [0..14] of char;
    t_sellFee   : array [0..14] of char;

    buyFee      : array [0..14] of char;
    sellFee     : array [0..14] of char;
    useFee      : array [0..14] of char;
    lendFee     : array [0..14] of char;
    maketProfit : array [0..14] of char;

  end;

  // activ order      [SO]
  PActiveOrder = ^TActiveOrder;
  TActiveOrder = packed record
    SvrHeader   : TServerHeader;
    Market      : char;
    AccountNo   : array [0..11] of char;
    PrdtNo      : array [0..11] of char;
    OrderKind   : char;
    Side        : char;
    Qty         : array [0..7] of char;
    Price       : array [0..8] of char;
    OrderDiv    : char;
    OrderNo     : array [0..6] of char;
    OriginNo    : array [0..6] of char;
	  lpDiv       : char;
		groupid     : array [0..5] of char;
    OAsk        : char;
  end;

  /////////////////////////////////////////////////////////////////////////////
  ///  선물, 옵션, 주식옵션
  ///

  PCommonData = ^TCommonData;
  TCommonData = record
    Size: Integer;
    Packet: array of Char;
  end;


  PCommonHead = ^TCommonHead;
  TCommonHead = packed record
    cSTX        : char;
    stCommsize  : array [0..3] of char;       // 전물길이
    stLastSN    : array [0..6] of char;       // 최종전문일련번호
    stApType    : array [0..1] of char;       // 업무식별코드
    stClientSN  : array [0..5] of char;       // 최종주문일련번호
    stDataCnt   : array [0..1] of char;       // 데이타카운트
    stResponse  : array [0..1] of char;       // 응답코드
    stUserID    : array [0..2] of char;       // 사용자아이디
    cOD         : char;
    stFiller    : array [0..12] of char;      // 필러
    cEnd        : char;                       // end text '>'
  end;

  // Message Server Header
  PMessageHead = ^TMessageHead;
  TMessageHead = packed record
    cSTX        : char;
    stCommsize  : array [0..3] of char;       // 전물길이
    stLastSN    : array [0..6] of char;       // 최종전문일련번호
    stApType    : array [0..1] of char;       // 업무식별코드
    stResponse  : array [0..1] of char;       // 응답코드
    stUserID    : array [0..2] of char;       // 클라이언트 IP 마지막 3자리
    stFiller    : array [0..3] of char;       // 필러
  end;



  PDataHead = ^TDataHead;
  TDataHead = packed record
    stAptype      : array [0..1] of char;
    stLength      : array [0..2] of char;
    {stLength2     : array [0..3] of char;
    cMarket       : char;
    stCurPrice    : Array [0..6] of char;       // 종목 현재가
    stFiller      : Array [0..27] of char; 			// 예비
    }
  end;

  //증전접수 'OR01' (40 + 158byte)---------------------------------------------------
  PSOrdKseAcpt = ^TSOrdKseAcpt;
  TSOrdKseAcpt = packed record
    //증전 I/F HEADER (40byte)---------------------------------------------------
    stSize:       array[0..3] of char; //4 전송길이
    stPID:        array[0..5] of Char; //6 해당단말 PID
    stIFTRCODE:   array[0..3] of Char; //4 TR-Code   지수선물:IF01, 지수옵션:IO01, 주식옵션:SO01
    cGb:          Char;                //1 SPACE
    stHeadSN:     array[0..8] of Char; //9 주문일련번호
    stNumber:     array[0..1] of Char; //2 주문입력건수
    stReject:     array[0..2] of Char; //3 주문거부코드
    stInTime:     array[0..7] of Char; //8 주문처리시간
    stFiller:     array[0..2] of Char; //3 처리안하는 구역
    //증전 I/F HEADER (40byte)--------------------------------------------------

    stSN:         array[0..8] of Char; //9 주문일련번호
    stCode:       array[0..7] of Char; //8 종목코드
    stBranch:     array[0..2] of Char; //3 지점번호
    stOrderNo:    array[0..6] of Char; //7 주문번호
    stGb:         array[0..1] of Char; //2 호가구분
    cLS:          Char;                //1 매도수구분
    cHogaType:    Char;                //1 호가유형  (L:지정가, M:시장가, C:조건부지정가, B:최유리
    stQty:        array[0..7] of Char; //8 호가수량
    cSign:        Char;                //1 가격부호
    stPrice:      array[0..8] of Char; //9 가격
    cPropri:      Char;                //1 자기구분
    stMarketHoga: array[0..8] of Char; //9 시장조성호가구분번호
    stNationCode: array[0..1] of Char; //2 국가코드
    stInvest:     array[0..1] of Char; //2 투자자코드
    cGiven:       Char;                //1 호가수탁방법
    cTradeType:   Char;                //1 거래 유형
    stOrginNo:    array[0..6] of Char; //7 원주문번호
    stAccNo:      array[0..8] of Char; //9 계좌번호

    /////////////////// 회원처리항목 - 30byte  /////////////////////////////////
    stCookie:     array[0..6] of char; //7 쿠키 처리
    stDummy:      array[0..11] of Char;//12 처리 안하는 회원처리항목 1
    stSysType:    array[0..1] of Char; //2 Su:Supra,  FR:FR의 데이타=> FR과 Supra의 병행처리시에 구분값
    stID:         array[0..4] of Char; //5 사용자 ID
    stSystem:     array[0..1] of Char; //2 시스템 구분  XT
    stGroupGb:    array[0..1] of Char; //2 그룹 구분값  01
    ////////////////////////////////////////////////////////////////////////////
    cFiller1:     array[0..11] of Char;//11 주식연결계좌번호
    stIP:         array[0..11] of Char;//11 사용자 IP
    ////////////////////////////////////////////////////////////////////////////
    // 추가 항목 200708 부터 적용
    stCondition:  char;                 // 주문조건
    stOrderDiv:   char;                 // 주문구분
    stCfMemNo:    array [0..2] of char;  // 협의대량거래 상대회원번호
    stCfAccNo:    array [0..8] of char;  // 협의대량거래 상대계좌번호
    stCfEndTime:  array [0..3] of char;  // 협의대량거래 협의완료시각
    cFiller  :    array [0..4] of Char; //1  처리안하는 구역
  end;

  //증전정정,취소 'HO01' ( 증전 I/F HEADER (40byte) + 증전메시지170byte)--------
  PSOrdKseConfirm = ^TSOrdKseConfirm;
  TSOrdKseConfirm = packed record
    //증전 I/F HEADER (40byte)---------------------------------------------------
    stSize:       array[0..3] of char; //4 전송길이
    stPID:        array[0..5] of Char; //6 해당단말 PID
    stIFTRCODE:   array[0..3] of Char; //4 TR-Code   지수선물:IF01, 지수옵션:IO01, 주식옵션:SO01
    cGb:          Char;                //1 SPACE
    stHeadSN:     array[0..8] of Char; //9 주문일련번호
    stNumber:     array[0..1] of Char; //2 주문입력건수
    stReject:     array[0..2] of Char; //3 주문거부코드
    stInTime:     array[0..7] of Char; //8 주문처리시간
    stFiller:     array[0..2] of Char; //3 처리안하는 구역
    //증전 I/F HEADER (40byte)---------------------------------------------------

    stTRCode:     array[0..3] of Char; //4 TR-CODE
    cContinue:    Char;                //1 연속구분
    stSN:         array[0..8] of Char; //9 체결통지번호
    stCode:       array[0..7] of Char; //8 종목코드
    stBranch:     array[0..2] of Char; //3 지점번호
    stOrderNo:    array[0..6] of Char; //7 주문번호
    stMember:     array[0..2] of Char; //3 회원번호
    stOrginNO:    array[0..6] of Char; //7 원주문번호
    stGb:         array[0..1] of Char; //2 호가구분
    cLS:          Char;                //1 매도수구분
    cType:        Char;                //1 호가유형  (L:지정가, M:시장가, C:조건부지정가, B:최유리
    cOrginSign:   Char;                //1 원주문가격부호(스프레드일때 '-'만 사용)
    stOrginPrice: array[0..8] of Char; //9 원주문가격
    cSign:        Char;                //1 주문가격부호(스프레드일때 '-'만 사용)
    stPrice:      array[0..8] of Char; //9 주문가격
    stQty:        array[0..7] of Char; //8 수량
    stOrginQty:   array[0..7] of Char; //8 정정/취소수량
    stTime:       array[0..7] of Char; //8 시간
    stReason:     array[0..2] of Char; //3 사유코드
    stAccNo:      array[0..8] of Char; //9 계좌번호
    /////////////////// 회원처리항목 - 30byte  /////////////////////////////////
    stCookie:     array[0..6] of char; //7 쿠키 처리
    stDummy:      array[0..13] of Char;//14 처리 안하는 회원처리항목 1
    stID:         array[0..4] of Char; //5 사용자 ID
    stSystem:     array[0..1] of Char; //2 시스템 구분
    stGroupGb:    array[0..1] of Char; //2 그룹 구분값
    ////////////////////////////////////////////////////////////////////////////
    stRjtTime:    array[0..7] of char; // 8 정정/취소/거부확인시각
    stFiller2:    array[0..29] of Char; //22 처리안하는 구역
  end;

  //증전체결 'CH01' (170byte)---------------------------------------------------
  PSOrdKseFill = ^TSOrdKseFill;
  TSOrdKseFill = packed record
    //증전 I/F HEADER (40byte)---------------------------------------------------
    stSize:       array[0..3] of char; //4 전송길이
    stPID:        array[0..5] of Char; //6 해당단말 PID
    stIFTRCODE:   array[0..3] of Char; //4 TR-Code   지수선물:IF01, 지수옵션:IO01, 주식옵션:SO01
    cGb:          Char;                //1 SPACE
    stHeadSN:     array[0..8] of Char; //9 주문일련번호
    stNumber:     array[0..1] of Char; //2 주문입력건수
    stReject:     array[0..2] of Char; //3 주문거부코드
    stInTime:     array[0..7] of Char; //8 주문처리시간
    stFiller:     array[0..2] of Char; //3 처리안하는 구역
    //증전 I/F HEADER (40byte)---------------------------------------------------

    stTRCode:     array[0..3] of Char; //4 TR-CODE
    cContinue:    Char;                //1 연속구분
    stSN:         array[0..8] of Char; //9 체결통지번호
    stCode:       array[0..7] of Char; //8 종목코드
    stBranch:     array[0..2] of Char; //3 지점번호
    stOrderNo:    array[0..6] of Char; //7 주문번호
    stMember:     array[0..2] of Char; //3 회원번호
    stFillNO:     array[0..8] of Char; //9 체결번호
    cLS:          Char;                //1 매도수구분
    cType:        Char;                //1 호가유형  (L:지정가, M:시장가, C:조건부지정가, B:최유리
    cSign:        Char;                //1 가격부호(스프레드일때 '-'만 사용)
    stPrice:      array[0..8] of Char; //9 가격

    stQty:        array[0..7] of Char; //8 수량
    stTime:       array[0..7] of Char; //8 시간
    stNear:       array[0..8] of Char; //9 촤근월물
    stLong:       array[0..8] of Char; //9 원근월물
    //stFiller1:    array[0..5]of Char;  //6 처리안하는 구역
    stAccNo:      array[0..8] of Char; //9 계좌번호
    /////////////////// 회원처리항목 - 30byte  /////////////////////////////////
    stCookie:     array[0..6] of char; //7 쿠키 처리
    stDummy:      array[0..13] of Char;//14 처리 안하는 회원처리항목 1
    stID:         array[0..4] of Char; //5 사용자 ID
    stSystem:     array[0..1] of Char; //2 시스템 구분
    stGroupGb:    array[0..1] of Char; //2 그룹 구분값
    ////////////////////////////////////////////////////////////////////////////
    stFiller2:    array[0..40] of Char;//25 처리안하는 구역
    {

    }
  end;


  PMarketOperation = ^TMarketOperation;
  TMarketOperation = packed record
    JGubu:        array [0..1] of char;
    TargetCode:   array [0..11] of char;
    TargetId:     array [0..1] of char;
    PrtdCode:     array [0..7] of char;
    JOTime:       array [0..7] of char;
    Filler:       char;
  end;

  // 거래소 접수 패킷
  UnionKSCPacket = packed record
    case Integer of
      0: ( StKseAcpt        :       TSOrdKseAcpt; );
      1: ( StKseConfirm     :       TSOrdKseConfirm; );
      2: ( StKseFill        :       TSOrdKseFill; );
  end;

  ///  거래소 접수 COMMAND 헤더
  PStReceptPacket = ^TStReceptPacket;
  TStReceptPacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
    stUnionPak   : UnionKSCPacket;
  end;

  ///  거래소 접수 COMMAND 헤더
  PTReceivePacket = ^TReceivePacket;
  TReceivePacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
  end;

const
  KOSPI_HEADER    = sizeof(TKospiHeader);
  KORDER_SIZE     = sizeof( TKospiOrder );    // 150 byte
  KCONFIRM_SIZE   = sizeof( TKospiConfirm ); // 128 byte;
  KFILL_SIZE      = sizeof( TKospiFill );     // 128 byte

implementation

end.

{

데이타분류9(03)101:정상호가, 102:정정호가, 103:취소호가, 109:거부호가

주문구분9(02)1:보통,  5:시장가, 6:조건부지정가, 9:자기주식,
          10:s-option자기주식, 11:금전신탁자기주식, 12:최유리지정가
          13:최우선지정가, 51:장중대량, 52:장중바스켓
          61:오전시간외, 62:오전시간외대량, 63:오전바스켓
          71:오후시간외, 72:오후시간외대량, 77:금전신탁자기주식시간외대량,
          79:시간외대량자기주식(970710) 80:바스켓매매
          81:시간외단일가매매 67:오전대량금전신탁자사주 69:오전대량자기주식

신용구분9(02)10:보통,
          21:자기융자매수,  22:자기융자매도상환
          23:자기대주매도,  24:자기대주매수상환,
          31:유통융자매수,  32:유통융자매도상환,
          33:유통대주매도,  34:유통대주매수상환

투자가코드9(04)1000:증권회사, 2000:보험, 3000:투신,4000:은행, 5000:종금,
          6000:기금, 7000:국가, 8000:개인,
          9000:ID있는외국인, 9001:ID없는외국인

거부사유9(02) 주문거부사유발생시 사용(접속시스템 체크)
          1:매도수구분오류,  3:데이타분류오류,      61:회원번호오류,
          31:종목번호오류,   39:전산매매종목아님,   48:시간외개시전,
          59:주문경로오류,   98:호가접수정지중,     99:시간외매매시간오류

체결유형9(02)1:시가, 2:접속, 3:종가, 4:장중동시, 51:장중대량, 52:장중바스켓,
        61:장개시전시간외종가,62:장개시전시간외대량,63:장개시전시간외바스켓,
        71:장종료후시간외종가,72:장종료후시간외대량,80:장종료후시간외바스켓,
        81:시간외단일가

}