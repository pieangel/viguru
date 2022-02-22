unit TOPServerPacket;

interface

const
  DATA_LENGTH  = 256;
  TR_ORDER  = 'sc801u';
  TR_ORDER_REJECT = 'sc801R';

  TR_SUC_ORDER  = 'TFRO00';
  TR_RJT_ORDER  = 'TFRO01';
  TR_FILL       = 'TFTT00';
  TR_CHANGE_CONFIRM = 'TFCM00';
  TR_CANCEL_CONFIRM = 'TFCC00';
  TR_LOGIN      = 'Q90001';
  TR_POS        = 'Q40014';
  TR_ACTIVE     = 'Q40001';
  TR_REGIST     = 'REGIST';

type

  PTopsHeader = ^TTopsHeader;
  TTopsHeader = packed record
    STX : char;
    Quotient : char;    //  DATA_LENGHT 으로 나눈 몫
    Remainder : char ;  //  DATA_LENGHT 으로 나눈 나머지
  end;

  PTopsOrderPacket = ^TTopsOrderPacket;
  TTopsOrderPacket = packed record
    header  : TTopsHeader;
    tr_code : array [0..5] of char;         // TR_ORDER
    the_date: array [0..7] of char;         // 20130422
    emp_no  : array [0..5] of char;         // 사원번호
    fund_no : array [0..5] of char;         // 펀드코드  right(6)
    bkt_cd  : array [0..8] of char;         // space
    wave_id : array [0..1] of char;         // space
    team  : array [0..5] of char;           // 'A15   '
    mkt_cls : char;                         // 시장구분  선물 : 'F'  옵션 'P'
    isu_cd  : array [0..14] of char;        // 종목코드    '201B2270       '
    expcode : array [0..11] of char;        // 표준종목코드
    tr_unt  : char;                         // 거래단위수량 구분 'space'
    ord_ty  : char;                         // 1: 시장가 2: 지정가  I:조건부지정 X:최유리
    tr_cls  : char;                         // 1:매도     2: 매수
    ord_cls : char;                         // 1:신규     2: 정정     3: 취소
    kq_ord_cls  : char;                     // 코스닥 주문 구분 'space'
    crctn_cls : char;
    befor_crctn_qty : array [0..4] of char; // 정정전수량 'space' --> 알고리즘계좌 구분으로 변경 2013.09.25
                                            // 41 : 일반    61 : 알고
    ord_qty : array [0..9] of char;         // 주문수량
    ord_prc : array [0..10] of char;
    trade_type : char;                        // 1:차입     2:헤지      3: 기타   '3'
    ord_no  : array [0..9] of char;          //주문번호
    org_ord_no  : array [0..9] of char;      // 원주문번호    '0000000000'
    mtr_ord_no  : array [0..9] of char;      // 모주문번호     '0000000000'
    rqst_no     : array [0..9] of char;      // 접수번호      '0000000000'
    org_rqst_no : array [0..9] of char;      // 원접수번호     '0000000000'
    ntc_no      : array [0..9] of char;      // 통지번호       '0000000000'
    ord_tm      : array [0..7] of char;      // 주문접수시간    'space'
    rjct_rsn    : array [0..11] of char;     // 거부사유       'space'
    setup_qty   : array [0..8] of char;      // 설정수량    '000000000'
    bkt_tr_cls  : char;                      // 바스켓 매매 구분 'space'
    cond        : char;                      // 상태 1:진행      2: 청산   'space'
    accnt_no    : array [0..11] of char;
    pswd_no     : array [0..7] of char;      // space
    term_no     : array [0..14] of char;     // ip  '120.110.001.001'
    org_tord_no : array [0..9] of char;      // '00000000000'
    isu_cls     : char;                      // space
    ord_cond    : char;                      // 0:일반     3:IOC       4:FOK
    limit_over_flag : char;                  // 한도초과 플래그 'Y:한도초과   N:한도미초과
    ETX : char;
  end;

  PTopsAcceptPacket = ^TTopsAcceptPacket;
  TTopsAcceptPacket = packed record
    tr_code : array [0..5] of char;         // TR_SUC_ORDER   or   TR_RJT_ORDER
    the_date: array [0..7] of char;         // 20130422
    fund_no : array [0..5] of char;         // 펀드코드  right(6)
    bkt_cd  : array [0..8] of char;         // space
    isu_cd  : array [0..14] of char;        // 종목코드    '201B2270       '

    tr_cls  : char;                         // 1:매도     2: 매수
    ord_cls : char;                         // 1:신규     2: 정정     3: 취소
    befor_crctn_qty : array [0..4] of char; // 정정전수량 'space'

    ord_qty : array [0..9] of char;         // 주문수량
    ord_prc : array [0..10] of char;
    ord_no  : array [0..9] of char;          //주문번호
    org_ord_no  : array [0..9] of char;      // 원주문번호    '0000000000'
    mtr_ord_no  : array [0..9] of char;      // 모주문번호     '         '
    rqst_no     : array [0..9] of char;      // 접수번호      '0000000000'
    org_rqst_no : array [0..9] of char;      // 원접수번호     '0000000000'
    ntc_no      : array [0..9] of char;      // 통지번호       '0000000000'
    ord_tm      : array [0..7] of char;      // 주문접수시간    'space'

    norm_flag   : char;                      // 정상여부      ' '
    rjct_rsn    : array [0..11] of char;     // 거부사유
    msg         : array [0..199]  of char ;
    tord_no     : array [0..9] of char;      // 업무계 주문번호
    org_tord_no : array [0..9] of char;       // 업무계 원주문번호

    accnt_no    : array [0..11] of char;      // 계좌번호
    term_no     : array [0..11] of char;     // ip  '120110001001'
    mkt_cls : char;                          // 시장구분  선물 : 'F'  옵션 'P'
    cli_index : array [0..4] of char;
    ord_cond  : char;                        // 0:일반     3:IOC       4:FOK
  end;

  PTopsFillPacket = ^TTopsFillPacket;
  TTopsFillPacket = packed record
    tr_code : array [0..5] of char;          // TR_FILL
    fund_no : array [0..5] of char;          // 펀드코드  right(6)
    ord_no  : array [0..9] of char;          //주문번호
    rqst_no : array [0..9] of char;          // 접수번호      '0000000000'
    conc_no : array [0..10] of char;          // 체결번호( 통지번호 )
    cntrt_no: array [0..10] of char;          // 약정번호
    revs_cls: char;                           // 코스닥만 사용
    tr_cls  : char;                           // 1:매도     2: 매수
    isu_cd  : array [0..14] of char;        // 종목코드    '201B2270       '
    ksdq_ord_cd : array [0..31] of char;      // 코스닥만 사용
    conc_prc    : array [0..10] of char;      // 체결가격
    conc_qty    : array [0..9] of char;       // 체결수량
    conc_tm     : array [0..8] of char;       // 체결시각     update by 2013.06.04
    frst_cmdt_ctrct_prc : array [0..10] of char;    // 최근월 약정가격
    scnd_cmdt_ctrct_prc : array [0..10] of char;     // 차근월물
    accnt_no    : array [0..11] of char;            // 계좌번호
  end;


  PTopsChangeConfrimPacket = ^TTopsChangeConfrimPacket;
  TTopsChangeConfrimPacket = packed record
    tr_code : array [0..5] of char;          // TR_CHANGE_CONFIRM
    fund_no : array [0..5] of char;          // 펀드코드  right(6)
    ord_no  : array [0..9] of char;          //주문번호
    rqst_no : array [0..9] of char;          // 접수번호      '0000000000'
    org_ord_no  : array [0..9] of char;       // 원주문번호
    org_rqst_no : array [0..9] of char;       // 원접수번호
    price   : array [0..10] of char;           // 정정가격
    qty     : array [0..9] of char;           // 호가수량
    crctn_qty : array [0..9] of char;         // 정정수량
    rjct_rsn  : array [0..11] of char;        // 거부코드
    cnfrm_dt  : array [0..7] of char;         // 확인시각
    isu_cd    : array [0..14] of char;        // 종목코드
    accnt_no  : array [0..11] of char;        // 계좌번호
    tr_cls    : char;
    tord_no   : array [0..9] of char;
    org_tord_no: array [0..9] of char;
    mkt_cls : char;
  end;

  PTopsCancelConfrimPacket = ^TTopsCancelConfrimPacket;
  TTopsCancelConfrimPacket = packed record
    tr_code : array [0..5] of char;          // TR_CANCEL_CONFIRM
    fund_no : array [0..5] of char;          // 펀드코드  right(6)
    ord_no  : array [0..9] of char;          //주문번호
    rqst_no : array [0..9] of char;          // 접수번호      '0000000000'
    org_ord_no  : array [0..9] of char;       // 원주문번호
    org_rqst_no : array [0..9] of char;       // 원접수번호
    price   : array [0..10] of char;           // 취소가격
    qty     : array [0..9] of char;           // 호가수량
    cnlt_qty : array [0..9] of char;         // 취소수량
    rjct_rsn  : array [0..11] of char;        // 거부코드
    cnfrm_dt  : array [0..7] of char;         // 확인시각
    isu_cd    : array [0..14] of char;        // 종목코드
    mtr_ord_no: array [0..9] of char;         // 모주문번호
    accnt_no  : array [0..11] of char;        // 계좌번호
    tr_cls    : char;
    tord_no   : array [0..9] of char;
    org_tord_no: array [0..9] of char;
    mkt_cls : char;
  end;

  ////////////////////////////////////////////////////////////////////////////////

  PTopsRegist = ^TTopsRegist;
  TTopsRegist = packed record
    header  : TTopsHeader;
    tr_code : array [0..5] of char;
    emp_no  : array [0..5] of char;         // 사번
    gubun   : char;                         // 1: 관리자     5 : 딜러
    cnt     : array [0..2] of char;         // 개수
  end;

  // 뒤에서 펀드코드 6자리를 계속 붙여 나감.


PQueryHeader = ^TQueryHeader;
  TQueryHeader = packed record
    tr_code               : array [0..5] of char;
    trgb                  : char;                     // 1: Single 2.Multi 9.Error
    handle                : array [0..3] of char;
    attr                  : char;                     // 1:Start , 2:Data , 3:End
  end;

  PQuery = ^TQuery;
  TQuery = packed record
    TopsHeader : TTopsHeader;
    QueryHeader : TQueryHeader;
  end;

  PLoginIn = ^TLoginIn;                               // Q90001
  TLoginIn = packed record
    Query : TQuery;
    id                    : array[0..7] of char;
    passwd                : array[0..3] of char;
  end;

  PLoginOut = ^TLoginOut;                             // Q90001
  TLoginOut = packed record
    Query : TQuery;
    result                : char;                     // 1' 성공, '2' ID 실패, '3' PW 실패, '4' ID와 IP 불일치'9' DB Error
    date                  : array[0..7] of char;      // 영업일
    emp_no                : array[0..5] of char;      // 사원번호
    dptmt                 : array[0..5] of char;      // 부서
    athrty                : char;                     // 권한
    emp_nm                : array[0..9] of char;      // 사원명
    msg                   : array[0..127] of char;    // 실패사유
  end;

  PPosIn = ^TPosIn;                                   // Q40002
  TPosIn = packed record
    Query : TQuery;
    emp_no                : array[0..5] of char;      // 사원번호
    fund_no               : array[0..5] of char;      // 펀드번호
    isu_gb                : char;                     // 0:전체, 1:선물, 2:옵션 3:콜옵션, 4:풋옵션
  end;


  PActiveIn = ^TActiveIn;                                 // Q40001
  TActiveIn = packed record
    Query : TQuery;
    emp_no                : array[0..5] of char;      // 사원번호
    fund_no               : array[0..5] of char;      // 펀드번호
    isu_gb                : char;                     // 종목구분 (0:전체, 1:선물, 2:옵션)
    tr_gb                 : char;                     // 매매구분 (0:전체, 1:매도, 2:매수)
    che_gb                : char;                     // 체결구분 (0:전체, 1:미체결, 2:체결)
    accnt_no              : array[0..11] of char;     // 계좌번호
    gubun                 : char;                     // 1:상품 0:위탁
  end;

  PQueryOut = ^TQueryOut;
  TQueryOut = packed record
    rcnt        : array[0..2] of char;
  end;

  PQuerySub = ^TQuerySub;
  TQuerySub = packed record
    Query : TQuery;
    QueryOut : TQueryOut;
  end;

  //포지션
  PPosOutSub = ^TPosOutSub;                           // Q40014
  TPosOutSub = packed record
    fund_no               : array[0..5] of char;      // 펀드번호
    isu_cd                : array[0..8] of char;      // 종목번호
    kor_isu_nm            : array[0..19] of char;     // 종목명
    tr_cls                : char;                     // 매매구분 (1 : 매도, 2 : 매수)
    bk_qty                : array[0..8] of char;      // 장부수량
    bk_prc                : array[0..11] of char;     // 장부단가
    bk_amt                : array[0..14] of char;     // 장부금액
    prsnt_prc             : array[0..5] of char;      // 현재가
    ass_prft_ls           : array[0..14] of char;     // 평가손익
    man_prft_ls           : array[0..14] of char;     // 만기손익
    bef_ass_prft_ls       : array[0..14] of char;     // 전일평가손익
    tr_prft_ls            : array[0..14] of char;     // 매매손익
    cmsn                  : array[0..14] of char;     // 수수료
  end;

   //체결, 미체결
  PActiveOutSub = ^TActiveOutSub;                           // Q40002
  TActiveOutSub = packed record
    fund_no               : array[0..5] of char;      // 펀드번호
    attr_fund_no          : char;                     // 펀드번호의 속성
    isu_cd                : array[0..8] of char;      // 종목번호
    attr_isu_cd           : char;                     // 종목번호의 속성
    kor_isu_nm            : array[0..19] of char;     // 종목명
    attr_kor_isu_nm       : char;                     //
    tr_cls                : char;                     // 매매구분
    attr_tr_cls           : char;                     //
    ord_qty               : array[0..6] of char;      // 주문수량
    attr_ord_qty          : char;                     //
    ord_prc               : array[0..8] of char;      // 주문가격(9.2)
    attr_ord_prc          : char;                     //
    conc_qty              : array[0..6] of char;      // 체결수량
    attr_conc_qty         : char;                     //
    conc_prc              : array[0..8] of char;      // 체결단가
    attr_conc_prc         : char;                     //
    rem_qty               : array[0..6] of char;      // 잔량
    attr_rem_qty          : char;                     //
    cert                  : array[0..3] of char;      // 확인
    attr_cert             : char;                     //
    prsnt_prc             : array[0..4] of char;      // 현재가
    attr_prsnt_prc        : char;                     //
    buy_bdoff             : array[0..4] of char;      // 매수호가
    attr_buy_bdoff        : char;                     //
    sell_bdoff            : array[0..4] of char;      // 매도호가
    attr_sell_bdoff       : char;                     //
    hilmt_price           : array[0..4] of char;      // 상한가
    attr_hilmt_price      : char;                     //
    lolmt_price           : array[0..4] of char;      // 하한가
    attr_lolmt_price      : char;                     //
    crctn_qty             : array[0..6] of char;      // 정정수량
    attr_crctn_qty        : char;                     //
    cnlt_qty              : array[0..6] of char;      // 취소수량
    attr_cnlt_qty         : char;                     //
    ord_no                : array[0..9] of char;      // 주문번호
    attr_ord_no           : char;                     //
    mtr_ord_no            : array[0..9] of char;      // 모주문번호
    attr_mtr_ord_no       : char;                     //
    org_ord_no            : array[0..9] of char;      // 원주문번호
    attr_orf_ord_no       : char;                     //
    rpt_qty               : array[0..6] of char;      // 통보수량
    attr_rpt_qty          : char;                     //
    ord_ty                : char;                     // 주문유형
    attr_ord_ty           : char;                     //
    ord_cls               : char;                     // 주문구분
    attr_ord_cls          : char;                     //
    rqst_no               : array[0..9] of char;      // 접수번호
    attr_rqst_no          : char;                     //
    org_rqst_no           : array[0..9] of char;      // 원접수번호
    attr_org_rqst_no      : char;                     //
    rjct_rsn              : array[0..11] of char;     // 거부사유
    attr_rjct_rsn         : char;                     //
    conc_amt              : array[0..14] of char;     // 체결금액
    attr_cont_amt         : char;                     //
    prvsdy_clng_prc       : array[0..4] of char;      // 전일가
    attr_prvsdy_clng_prc  : char;                     //
    stnd_price            : array[0..4] of char;      // 기준가
    attr_stnd_price       : char;
    trade_type            : char;                     // 거래유형(1:차익, 2:헤지, 3:기타)
    attr_trade_type       : char;                     //
    accnt_no              : array[0..11] of char;     // 계좌번호
    attr_accnt_no         : char;                     //
    tord_no               : array[0..9] of char;      // 업무계주문번호
    attr_tord_no          : char;                     //
    org_tord_no           : array[0..9] of char;      // 업무계 원주문번호
    attr_org_tord_no      : char;                     //
    errmsg                : array[0..91] of char;     // 거부메시지
    attr_errmsg           : char;                     //
    isu_cls               : char;                     // 일반복합구분
    attr_isu_cls          : char;                     //
    conc_tm               : array[0..7] of char;      // 체결시각
    acc_tm                : array[0..7] of char;      // 접수시각
    ord_cond              : char;                     // ' ':없음 I:IOC F:FOK
    che_gb                : char;                     // 체결구분(0:전체, 1:미체결, 2:체결)
  end;


const

  Len_TopsHeader    = sizeof(TTopsHeader);
  Len_TopsOrderPacket  = sizeof(TTopsOrderPacket);   // 243
  Len_TopsAcceptPacket = sizeof(TTopsAcceptPacket);  // 404
  Len_TopsFillPacket   = sizeof(TTopsFillPacket);    // 177
  Len_TopsChangeConfrimPacket = sizeof( TTopsChangeConfrimPacket ); // 152
  Len_TopsCancelConfrimPacket = sizeof( TTopsCancelConfrimPacket ); // 162

  LenQueryHead     = sizeof( TQueryHeader );         // 12
  LenLoginIn       = sizeof( TLoginIn );             // 12
  LenPosIn         = sizeof( TPosIn );               // 13
  LenActiveIn      = sizeof( TActiveIn );            // 28
  LenQuery         = sizeof( TQuery);                // 15
  LenLoginOutSub   = sizeof( TLoginOut );            // 160
  LenPosOutSub     = sizeof( TPosOutSub );           // 153
  LenActiveOutSub  = sizeof( TActiveOutSub );        // 393

implementation

end.
