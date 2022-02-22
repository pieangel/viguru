unit TOP2ServerPacket;

interface

const
  DATA_LENGTH  = 256;
  LENGTH_SIZE  = 4;

  NewHoga = 'TCHODR10001';
  CnlHoga = 'TCHODR10003';
  ModHoga = 'TCHODR10002';
  //
  ConfNormal  = 'TTRODP11301';
  ConfReject  = 'TTRODP11321';
  AutoCancel  = 'TTRODP11303';
  //
  OrderFill   = 'TTRTDP21301';

  TR_LOGIN      = 'QS0008';
  TR_POS        = 'Q40001';
  TR_ACTIVEFILL = 'Q30003';

  TR_DATA  = 'DATA';
  TR_LIVE  = 'LIVE';
  TR_REGIST = 'REGIST';

  QRY_START = '1';
  QRY_DATA = '2';
  QRY_END = '3';
  NEXT_KEY = '999999999999999999';

type

  ///////////////////Query///////////////////////
  //    1. 조회 요청시
  //       (1) TOPS_HEAD + TR_HEAD + TR_INPUT
  //    2. 조회결과
  //       (1) START = TR_HEAD
  //       (2) DATA  = TR_HEAD + TR_OUTPUT + TR_OUPUT_SUB
  //       (3) END   = TR_HEAD
  ///////////////////////////////////////////////
  ///
  PTopsHeader = ^TTopsHeader;
  TTopsHeader = record
    length  : array[0..3] of char;
    tr_code : array [0..3] of char;
    // 데이타 구분
    // 주문 : ' ', 응답 :'A',  접수 : 'J', 체결 :'C', 확인:'H', 거부:'R'
    ack_gubu  : char;
    seq_no  : array [0..8] of char;               // 일련번호 "000000000"
    emp_no  : array [0..7] of char;
    func_no : array [0..5] of char;
    mkt_l_cls : char;                             // 지수 : K,  상품 : C
    com_gb    : char;
    res_code  : array [0..3] of char;             // "0000"
    org_ord_prc : array [0..10] of char;
    mysvr_gb  : char;                             // 타서버구분 " "
    mkt_kind  : char;                             // space
    mkt_offset  : char;                           // space
    filler      : array [0..11] of char;          // space
  end;

  //TR_HEAD
  PQueryHeader = ^TQueryHeader;
  TQueryHeader = packed record
    length                : array[0..3] of char;
    tr_code               : array[0..5] of char;
    trgb                  : char;                     // 1: Single 2.Multi 9.Error
    handle                : array[0..3] of char;
    attr                  : char;                     // 1:Start , 2:Data , 3:End
    ip                    : array[0..14] of char;     //172.0.0.1
    userid                : array[0..9] of char;
    dist                  : array[0..1] of char;
    svr                   : char;
    userarea              : array[0..9] of char;
  end;

  //TR_INPUT 체결내역     TR : Q30003
  PActiveFillIn = ^TActiveFillIn;
  TActiveFillIn = packed record
    Header                : TQueryHeader;
    login_id              : array[0..7] of char;      // 로그인ID
    fund_no               : array[0..5] of char;      // 펀드번호
    isu_gu                : char;      // 종목구분   0:전체, 1:선물, 2:옵션
    tr_gb                 : char;      // 매매구분   0:전체, 1:매도, 2:매수
    che_gb                : char;      // 체결구분   0:전체, 1:미체결, 2:체결
    next_key              : array[0..17] of char;      // next_key
  end;

  //TR_OUTPUT 체결내역   TR : Q30003
  PActiveFillOut = ^TActiveFillOut;
  TActiveFillOut = packed record
    rcnt        : array[0..2] of char;
    next_key    : array[0..17] of char;
  end;

  //TR_OUTPUT_SUB 체결내역  TR : Q30003
  PActiveFillOutSub = ^TActiveFillOutSub;
  TActiveFillOutSub = packed record
    fund_no               : array[0..5] of char;      // 펀드번호
    isu_cd                : array[0..7] of char;      // 종목코드
    isu_nm                : array[0..39] of char;     // 종목명
    tr_cls                : char;                     // 매매구분(1:매도, 2:매수)
    ord_qty               : array[0..6] of char;      // 주문수량
    ord_prc               : array[0..8] of char;      // 주문가격(9.2)
    conc_qty              : array[0..6] of char;      // 체결수량
    conc_prc              : array[0..8] of char;      // 체결단가(9.2)
    rem_qty               : array[0..6] of char;      // 잔량
    cert                  : array[0..3] of char;      // 확인
    crctn_qty             : array[0..6] of char;      // 정정수량
    cnlt_qty              : array[0..6] of char;      // 취소수량
    ord_no                : array[0..9] of char;      // 주문번호
    org_ord_no            : array[0..9] of char;      // 원주문번호
    rpt_qty               : array[0..6] of char;      // 통보수량
    ord_ty                : char;                     // 주문유형
    ord_cls               : char;                     // 주문구분
    rqst_no               : array[0..9] of char;      // 접수번호
    org_rqst_no           : array[0..9] of char;      // 원접수번호
    rjct_rsn              : array[0..11] of char;     // 거부사유
    conc_amt              : array[0..14] of char;     // 체결금액
    prvsdy_clng_prc       : array[0..4] of char;      // 전일가(5.2)
    stnd_price            : array[0..4] of char;      // 기준가(5.2)
    trade_type            : char;                     // 거래유형(1:차익, 2:헤지, 3:기타)
    accnt_no              : array[0..11] of char;     // 계좌번호
    isu_cls               : char;                     // 일반복합구분
    conc_tm               : array[0..7] of char;      // 체결시각
    acc_tm                : array[0..7] of char;      // 접수시각
    ord_cond              : char;                     // ''없음, I : IOC, F : FOK
    ord_tag               : char;                     // PC: ord tag
  end;

  PActiveFillData = ^TActiveFillData;
  TActiveFillData = packed record
    Header                : TQueryHeader;
    Output                : TActiveFillOut;
    SubOutPut             : TActiveFillOutSub;
  end;


  //TR_INPUT 잔고     TR : Q40001
  PPosIn = ^TPosIn;
  TPosIn = packed record
    Header                : TQueryHeader;
    fund_no               : array[0..5] of char;      // 펀드번호
    login_id              : array[0..7] of char;      // 로그인ID
    isu_gb                : char;      // 종목구분   0:전체, 1:선물, 2:옵션, 3 : 콥올션, 4 : 풋옵션
  end;

  //TR_OUTPUT 잔고     TR : Q40001
  PPosOut = ^TPosOut;
  TPosOut = packed record
    rcnt        : array[0..2] of char;
  end;

  //TR_OUTPUT_SUB 잔고  TR : Q40001
  PPosSub = ^TPosSub;
  TPosSub = packed record
    fund_no               : array[0..5] of char;      // 펀드번호
    fund_nm               : array[0..39] of char;     // 펀드명
    isu_cd                : array[0..7] of char;      // 종목코드
    isu_nm                : array[0..39] of char;     // 종목명
    tr_cls                : char;                     // 매매구분(1:매도, 2:매수)
    bk_qty                : array[0..8] of char;      // 장부수량
    bk_prc                : array[0..15] of char;     // 장부단가(16.6)
    bk_amt                : array[0..14] of char;     // 장부금액
    prsnt_prc             : array[0..5] of char;      // 현재가(6.2)
    tr_prft_ls            : array[0..14] of char;     // 매매손익
    ass_prft_ls           : array[0..14] of char;     // 평가손익
    man_prft_ls           : array[0..14] of char;     // 만기손익
    exer_prc              : array[0..5] of char;      // 행사가(6.2)
    bef_ass_prft_ls       : array[0..14] of char;     // 전일평가손익
    cmsn                  : array[0..14] of char;     // 수수료
    yak_qty               : array[0..8] of char;      // 약정수량
    yak_amt               : array[0..14] of char;     // 약정금액
  end;

  PPosData = ^TPosData;
  TPosData = packed record
    Header                : TQueryHeader;
    Output                : TPosOut;
    SubOutPut             : TPosSub;
  end;


  //TR_INPUT  로그인     TR : QS0008
  PLoginIn = ^TLoginIn;
  TLoginIn = packed record
    Header              : TQueryHeader;
    id                  : array[0..7] of char;      // ID
    passwd              : array[0..3] of char;      // 비밀번호
    flag                : char;                     // 로그인구분 1 : 자동, 0 : 비상(수동)
  end;


  //TR_OUTPUT 로그인     TR : QS0008
  PLoginOut = ^TLoginOut;
  TLoginOut = packed record
    Header              : TQueryHeader;
    result              : char;                     // 로그인결과 1:성공, 2:ID실패, 3:패스워드실패, 4:미사용아이디, 9:DB Error
    date                : array[0..7] of char;      // 영업일
    emp_no              : array[0..7] of char;      // 사원번호
    dept_cd             : array[0..2] of char;      // 부서코드
    team_cd             : array[0..2] of char;      // 팀코드
    auth                : char;                     // 권한 1:관리자, 2:리스크, 4:부서장, 5:팀장, 7:트레이더
    emp_nm              : array[0..39] of char;     // 로그인 사원명
    msg                 : array[0..127] of char;    // 로그인 실패사유
    server_cls          : char;                     // 주문서버 구분 1:tops 1호기, 2:tops 2호기
    ord_port            : char;                     // 주문포트
    ip                  : array[0..14] of char;     // PC ip
  end;

  PMemberArea = ^TMemberArea;
  TMemberArea = record
    media_gb  : array [0..1] of char;
    market_gb : char;
    accnt_gb  : char;
    deposit   : char;
    cncl_gb   : char;
    filler1   : array [0..15] of char;
    tops_bg   : array [0..1] of char;
    localNo   : array [0..4] of char; // 유일하게 사용가능한 공간
    filler2   : array [0..30] of char;
  end;

  PTopsCommonData  = ^TTopsCommonData;
  TTopsCommonData = packed record
    hseq        : array [0..10] of char;
    trans_code  : array [0..10] of char;
    board_id    : array [0..1] of char;
    memberno    : array [0..4] of char;           // 00017
    bpno        : array [0..4] of char;           // space
    ordno : array [0..9] of char;                 // space
    orgordno  : array [0..9] of  char;
    code  : array [0..11] of char;
  end;

  PTopsCommonData2  = ^TTopsCommonData;
  TTopsCommonData2 = packed record
    hseq        : array [0..10] of char;
    trans_code  : array [0..10] of char;
    me_grp_no   : array [0..1] of char;
    board_id    : array [0..1] of char;
    memberno    : array [0..4] of char;           // 00017
    bpno        : array [0..4] of char;           // space
    ordno : array [0..9] of char;                 // space
    orgordno  : array [0..9] of  char;
    code  : array [0..11] of char;
  end;



  // 주문 패킷
  PTopsOrderPacket = ^TTopsOrderPacket;
  TTopsOrderPacket = packed record
    CommonData    : TTopsCommonData;

    mmgubun : char;                               // 매도 : 1,  매수 : 2
    hogagb  : char;                               // 신규 : 1,  정정 : 2,  취소 : 3
    gyejwa  : array [0..11] of char;              // 계좌번호
    cnt     : array [0..9] of char;               // 호가수량
    price   : array [0..10] of char;              // 호가가격
    ord_type  : char;                             // 시장가 : 1, 지정가 : 2, 조건부 : I, 최유리 : X, 최우선 : Y( 현물만 )
    ord_cond  : char;                             // 일반(FASS) : 0, IOC(FAK) : 3, FOK : 4
    market_ord_num  : array [0..10] of char;      // 일반 : 0
    stock_state_id  : array [0..4] of char;       // 자사주신고서 ID - 해당없음 : 0
    stock_trade_code: char;                       // 자사주매매방법코드 - 해당없음 : 0
    medo_type_code  : array [0..1] of char;       // 매도유형코드 - 해당없음 : 00
    singb : array [0..1] of char;                 // 신용구분 - 보통일반 : 10
    witak : array [0..1] of char;                 // 위탁자기구분 - 위탁일반 : 11,  위탁주선 : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT구분 - 일반 : 00, 차익 : 10, 헤지 : 20
    sub_stock_gyejwa  : array [0..11] of char;    // 대용주권계좌번호

    gyejwa_type_code  : array [0..1] of char;     // 계좌구분코드 - 위탁일반 : 31, 자기일반 : 41
    gyejwa_margin_cod : array [0..1] of char;     // 계좌증거금유형코드 - 사후증거금 : 11,
    kukga : array  [0..2] of char;                // 국가코드
    tocode : array [0..3] of char;                // 투자자구분 - 증권회사 및 선물 : 1000
    foreign: array [0..1] of char;                // 외국인 투자자구분코드 - 00

    meache_bg : char;                             // 주문매체구분코드 -
    term_no : array [0..11] of char;              // 주문자식별정보
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // 회원사
    pgm_gongsi_gb : char;                         // 0
  end;

  PTopsDataPacket = ^TTopsDataPacket;
  TTopsDataPacket = packed record
    Header        : TTopsHeader;
    OrderPacket   : TTopsOrderPacket;
  end;

  PTopsFillPacket = ^TTopsFillPacket;
  TTopsFillPacket = packed record
    CommonData    : TTopsCommonData2;

    che_no      : array [0..10] of char;          // 체결번호
    che_price   : array [0..10] of char;          // 체결가격
    che_qty     : array [0..9] of char;
    session_id  : array [0..1] of char;

    che_date    : array [0..7] of char;
    che_time    : array [0..8] of char;
    pyakprice   : array [0..10] of char;
    nyakprice   : array [0..10] of char;

    mmgubun     : char;
    gyejwa      : array [0..11] of char;
    market_ord_num  : array [0..10] of char;
    witakcomp_num   : array [0..4] of char;
    sub_stock_gyejwa  : array [0..11] of char;
    hoiwon  : TMemberArea;
  end;

  PTopsConfirmPacket = ^TTopsConfirmPacket;
  TTopsConfirmPacket = packed record
    CommonData    : TTopsCommonData2;

    mmgubun     : char;                           // 매도 : 1, 매수 : 2
    hogagb      : char;                           // 신규 : 1, 정정 : 2, 취소 : 3;
    gyejwa      : array [0..11] of char;
    cnt         : array [0..9] of char;
    price       : array [0..10] of char;
    ord_type    : char;
    ord_cond    : char;
    market_ord_num  : array [0..10] of char;

    stock_state_id  : array [0..4] of char;       // 자사주신고서 ID - 해당없음 : 0
    stock_trade_code: char;                       // 자사주매매방법코드 - 해당없음 : 0
    medo_type_code  : array [0..1] of char;       // 매도유형코드 - 해당없음 : 00
    singb : array [0..1] of char;                 // 신용구분 - 보통일반 : 10
    witak : array [0..1] of char;                 // 위탁자기구분 - 위탁일반 : 11,  위탁주선 : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT구분 - 일반 : 00, 차익 : 10, 헤지 : 20
    sub_stock_gyejwa  : array [0..11] of char;    // 대용주권계좌번호

    gyejwa_type_code  : array [0..1] of char;     // 계좌구분코드 - 위탁일반 : 31, 자기일반 : 41
    gyejwa_margin_cod : array [0..1] of char;     // 계좌증거금유형코드 - 사후증거금 : 11,
    kukga : array  [0..2] of char;                // 국가코드
    tocode : array [0..3] of char;                // 투자자구분 - 증권회사 및 선물 : 1000
    foreign: array [0..1] of char;                // 외국인 투자자구분코드 - 00

    meache_bg : char;                             // 주문매체구분코드 -
    term_no : array [0..11] of char;              // 주문자식별정보
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // 회원사
    acpt_time : array [0..8] of char;
    jungcnt   : array [0..9] of char;
    auto_cancel_type  : char;
    rejcode   : array [0..3] of char;
    pgm_gongsi_gb : char;
  //  pgm_gongsi_gb : char;
  end;


  // 거래소 접수 패킷
  UnTopsPacket = packed record
    case Integer of
      0: ( TopsAck         :       TTopsOrderPacket; );
      1: ( TopsConfirm     :       TTopsConfirmPacket; );
      2: ( TopsFill        :       TTopsFillPacket; );
  end;

  ///  Tops order data
  PTopsReceptPacket = ^TTopsReceptPacket;
  TTopsReceptPacket = packed record
    TopsHead       : TTopsHeader;
    TopsUnionPak   : UnTopsPacket;
  end;

  PTopsRegist = ^TTopsRegist;
  TTopsRegist = packed record
    length  : array [0..3] of char;
    tr_code : array [0..5] of char;
    emp_no  : array [0..7] of char;         // 사번
    gubun   : char;                         // 1: 관리자     7 : 딜러
    com_gb  : char;                         // 1: tops,   A : 외부
    seq_no  : array [0..8] of char;
    cnt     : array [0..2] of char;         // 개수  001
  end;



const
  Len_TopsHeader  = sizeof( TTopsHeader ) - LENGTH_SIZE;
  Len_DataPacket  = sizeof( TTopsDataPacket );
  Len_TopsOrderPacket  = sizeof( TTopsOrderPacket ); // 261
  Len_TopsFillPacket = sizeof( TTopsFillPacket );
  Len_TopsConfirmPacket = sizeof( TTopsConfirmPacket );
  Len_TopsRegist  = sizeof( TTopsRegist );


  Len_QueryHeader = sizeof( TQueryHeader ) - LENGTH_SIZE;  // 조회헤더사이즈에서..4바이트 뺀다
  //Len_Query       = sizeof( TQuery );
  Len_LogIn       = sizeof( TLoginIn );
  Len_PosIn       = sizeof( TPosIn );
  Len_ActiveIn    = sizeof(TActiveFillIn );

  Len_LoginOut    = sizeof( TLoginOut );
  Len_ActiveFillData = sizeof(TActiveFillData);
  Len_PosData     = sizeof(TPosData);

  Len_ActiveOut = sizeof(TActiveFillOut);
  Len_ActiveOutSub  = sizeof( TActiveFillOutSub );
  Len_PosOut = sizeof(TPosOut);
  Len_PosSub = sizeof(TPosSub);

implementation

end.
