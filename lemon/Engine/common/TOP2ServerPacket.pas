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
  //    1. ��ȸ ��û��
  //       (1) TOPS_HEAD + TR_HEAD + TR_INPUT
  //    2. ��ȸ���
  //       (1) START = TR_HEAD
  //       (2) DATA  = TR_HEAD + TR_OUTPUT + TR_OUPUT_SUB
  //       (3) END   = TR_HEAD
  ///////////////////////////////////////////////
  ///
  PTopsHeader = ^TTopsHeader;
  TTopsHeader = record
    length  : array[0..3] of char;
    tr_code : array [0..3] of char;
    // ����Ÿ ����
    // �ֹ� : ' ', ���� :'A',  ���� : 'J', ü�� :'C', Ȯ��:'H', �ź�:'R'
    ack_gubu  : char;
    seq_no  : array [0..8] of char;               // �Ϸù�ȣ "000000000"
    emp_no  : array [0..7] of char;
    func_no : array [0..5] of char;
    mkt_l_cls : char;                             // ���� : K,  ��ǰ : C
    com_gb    : char;
    res_code  : array [0..3] of char;             // "0000"
    org_ord_prc : array [0..10] of char;
    mysvr_gb  : char;                             // Ÿ�������� " "
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

  //TR_INPUT ü�᳻��     TR : Q30003
  PActiveFillIn = ^TActiveFillIn;
  TActiveFillIn = packed record
    Header                : TQueryHeader;
    login_id              : array[0..7] of char;      // �α���ID
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    isu_gu                : char;      // ���񱸺�   0:��ü, 1:����, 2:�ɼ�
    tr_gb                 : char;      // �Ÿű���   0:��ü, 1:�ŵ�, 2:�ż�
    che_gb                : char;      // ü�ᱸ��   0:��ü, 1:��ü��, 2:ü��
    next_key              : array[0..17] of char;      // next_key
  end;

  //TR_OUTPUT ü�᳻��   TR : Q30003
  PActiveFillOut = ^TActiveFillOut;
  TActiveFillOut = packed record
    rcnt        : array[0..2] of char;
    next_key    : array[0..17] of char;
  end;

  //TR_OUTPUT_SUB ü�᳻��  TR : Q30003
  PActiveFillOutSub = ^TActiveFillOutSub;
  TActiveFillOutSub = packed record
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    isu_cd                : array[0..7] of char;      // �����ڵ�
    isu_nm                : array[0..39] of char;     // �����
    tr_cls                : char;                     // �Ÿű���(1:�ŵ�, 2:�ż�)
    ord_qty               : array[0..6] of char;      // �ֹ�����
    ord_prc               : array[0..8] of char;      // �ֹ�����(9.2)
    conc_qty              : array[0..6] of char;      // ü�����
    conc_prc              : array[0..8] of char;      // ü��ܰ�(9.2)
    rem_qty               : array[0..6] of char;      // �ܷ�
    cert                  : array[0..3] of char;      // Ȯ��
    crctn_qty             : array[0..6] of char;      // ��������
    cnlt_qty              : array[0..6] of char;      // ��Ҽ���
    ord_no                : array[0..9] of char;      // �ֹ���ȣ
    org_ord_no            : array[0..9] of char;      // ���ֹ���ȣ
    rpt_qty               : array[0..6] of char;      // �뺸����
    ord_ty                : char;                     // �ֹ�����
    ord_cls               : char;                     // �ֹ�����
    rqst_no               : array[0..9] of char;      // ������ȣ
    org_rqst_no           : array[0..9] of char;      // ��������ȣ
    rjct_rsn              : array[0..11] of char;     // �źλ���
    conc_amt              : array[0..14] of char;     // ü��ݾ�
    prvsdy_clng_prc       : array[0..4] of char;      // ���ϰ�(5.2)
    stnd_price            : array[0..4] of char;      // ���ذ�(5.2)
    trade_type            : char;                     // �ŷ�����(1:����, 2:����, 3:��Ÿ)
    accnt_no              : array[0..11] of char;     // ���¹�ȣ
    isu_cls               : char;                     // �Ϲݺ��ձ���
    conc_tm               : array[0..7] of char;      // ü��ð�
    acc_tm                : array[0..7] of char;      // �����ð�
    ord_cond              : char;                     // ''����, I : IOC, F : FOK
    ord_tag               : char;                     // PC: ord tag
  end;

  PActiveFillData = ^TActiveFillData;
  TActiveFillData = packed record
    Header                : TQueryHeader;
    Output                : TActiveFillOut;
    SubOutPut             : TActiveFillOutSub;
  end;


  //TR_INPUT �ܰ�     TR : Q40001
  PPosIn = ^TPosIn;
  TPosIn = packed record
    Header                : TQueryHeader;
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    login_id              : array[0..7] of char;      // �α���ID
    isu_gb                : char;      // ���񱸺�   0:��ü, 1:����, 2:�ɼ�, 3 : �߿ü�, 4 : ǲ�ɼ�
  end;

  //TR_OUTPUT �ܰ�     TR : Q40001
  PPosOut = ^TPosOut;
  TPosOut = packed record
    rcnt        : array[0..2] of char;
  end;

  //TR_OUTPUT_SUB �ܰ�  TR : Q40001
  PPosSub = ^TPosSub;
  TPosSub = packed record
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    fund_nm               : array[0..39] of char;     // �ݵ��
    isu_cd                : array[0..7] of char;      // �����ڵ�
    isu_nm                : array[0..39] of char;     // �����
    tr_cls                : char;                     // �Ÿű���(1:�ŵ�, 2:�ż�)
    bk_qty                : array[0..8] of char;      // ��μ���
    bk_prc                : array[0..15] of char;     // ��δܰ�(16.6)
    bk_amt                : array[0..14] of char;     // ��αݾ�
    prsnt_prc             : array[0..5] of char;      // ���簡(6.2)
    tr_prft_ls            : array[0..14] of char;     // �Ÿż���
    ass_prft_ls           : array[0..14] of char;     // �򰡼���
    man_prft_ls           : array[0..14] of char;     // �������
    exer_prc              : array[0..5] of char;      // ��簡(6.2)
    bef_ass_prft_ls       : array[0..14] of char;     // �����򰡼���
    cmsn                  : array[0..14] of char;     // ������
    yak_qty               : array[0..8] of char;      // ��������
    yak_amt               : array[0..14] of char;     // �����ݾ�
  end;

  PPosData = ^TPosData;
  TPosData = packed record
    Header                : TQueryHeader;
    Output                : TPosOut;
    SubOutPut             : TPosSub;
  end;


  //TR_INPUT  �α���     TR : QS0008
  PLoginIn = ^TLoginIn;
  TLoginIn = packed record
    Header              : TQueryHeader;
    id                  : array[0..7] of char;      // ID
    passwd              : array[0..3] of char;      // ��й�ȣ
    flag                : char;                     // �α��α��� 1 : �ڵ�, 0 : ���(����)
  end;


  //TR_OUTPUT �α���     TR : QS0008
  PLoginOut = ^TLoginOut;
  TLoginOut = packed record
    Header              : TQueryHeader;
    result              : char;                     // �α��ΰ�� 1:����, 2:ID����, 3:�н��������, 4:�̻����̵�, 9:DB Error
    date                : array[0..7] of char;      // ������
    emp_no              : array[0..7] of char;      // �����ȣ
    dept_cd             : array[0..2] of char;      // �μ��ڵ�
    team_cd             : array[0..2] of char;      // ���ڵ�
    auth                : char;                     // ���� 1:������, 2:����ũ, 4:�μ���, 5:����, 7:Ʈ���̴�
    emp_nm              : array[0..39] of char;     // �α��� �����
    msg                 : array[0..127] of char;    // �α��� ���л���
    server_cls          : char;                     // �ֹ����� ���� 1:tops 1ȣ��, 2:tops 2ȣ��
    ord_port            : char;                     // �ֹ���Ʈ
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
    localNo   : array [0..4] of char; // �����ϰ� ��밡���� ����
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



  // �ֹ� ��Ŷ
  PTopsOrderPacket = ^TTopsOrderPacket;
  TTopsOrderPacket = packed record
    CommonData    : TTopsCommonData;

    mmgubun : char;                               // �ŵ� : 1,  �ż� : 2
    hogagb  : char;                               // �ű� : 1,  ���� : 2,  ��� : 3
    gyejwa  : array [0..11] of char;              // ���¹�ȣ
    cnt     : array [0..9] of char;               // ȣ������
    price   : array [0..10] of char;              // ȣ������
    ord_type  : char;                             // ���尡 : 1, ������ : 2, ���Ǻ� : I, ������ : X, �ֿ켱 : Y( ������ )
    ord_cond  : char;                             // �Ϲ�(FASS) : 0, IOC(FAK) : 3, FOK : 4
    market_ord_num  : array [0..10] of char;      // �Ϲ� : 0
    stock_state_id  : array [0..4] of char;       // �ڻ��ֽŰ� ID - �ش���� : 0
    stock_trade_code: char;                       // �ڻ��ָŸŹ���ڵ� - �ش���� : 0
    medo_type_code  : array [0..1] of char;       // �ŵ������ڵ� - �ش���� : 00
    singb : array [0..1] of char;                 // �ſ뱸�� - �����Ϲ� : 10
    witak : array [0..1] of char;                 // ��Ź�ڱⱸ�� - ��Ź�Ϲ� : 11,  ��Ź�ּ� : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT���� - �Ϲ� : 00, ���� : 10, ���� : 20
    sub_stock_gyejwa  : array [0..11] of char;    // ����ֱǰ��¹�ȣ

    gyejwa_type_code  : array [0..1] of char;     // ���±����ڵ� - ��Ź�Ϲ� : 31, �ڱ��Ϲ� : 41
    gyejwa_margin_cod : array [0..1] of char;     // �������ű������ڵ� - �������ű� : 11,
    kukga : array  [0..2] of char;                // �����ڵ�
    tocode : array [0..3] of char;                // �����ڱ��� - ����ȸ�� �� ���� : 1000
    foreign: array [0..1] of char;                // �ܱ��� �����ڱ����ڵ� - 00

    meache_bg : char;                             // �ֹ���ü�����ڵ� -
    term_no : array [0..11] of char;              // �ֹ��ڽĺ�����
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // ȸ����
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

    che_no      : array [0..10] of char;          // ü���ȣ
    che_price   : array [0..10] of char;          // ü�ᰡ��
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

    mmgubun     : char;                           // �ŵ� : 1, �ż� : 2
    hogagb      : char;                           // �ű� : 1, ���� : 2, ��� : 3;
    gyejwa      : array [0..11] of char;
    cnt         : array [0..9] of char;
    price       : array [0..10] of char;
    ord_type    : char;
    ord_cond    : char;
    market_ord_num  : array [0..10] of char;

    stock_state_id  : array [0..4] of char;       // �ڻ��ֽŰ� ID - �ش���� : 0
    stock_trade_code: char;                       // �ڻ��ָŸŹ���ڵ� - �ش���� : 0
    medo_type_code  : array [0..1] of char;       // �ŵ������ڵ� - �ش���� : 00
    singb : array [0..1] of char;                 // �ſ뱸�� - �����Ϲ� : 10
    witak : array [0..1] of char;                 // ��Ź�ڱⱸ�� - ��Ź�Ϲ� : 11,  ��Ź�ּ� : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT���� - �Ϲ� : 00, ���� : 10, ���� : 20
    sub_stock_gyejwa  : array [0..11] of char;    // ����ֱǰ��¹�ȣ

    gyejwa_type_code  : array [0..1] of char;     // ���±����ڵ� - ��Ź�Ϲ� : 31, �ڱ��Ϲ� : 41
    gyejwa_margin_cod : array [0..1] of char;     // �������ű������ڵ� - �������ű� : 11,
    kukga : array  [0..2] of char;                // �����ڵ�
    tocode : array [0..3] of char;                // �����ڱ��� - ����ȸ�� �� ���� : 1000
    foreign: array [0..1] of char;                // �ܱ��� �����ڱ����ڵ� - 00

    meache_bg : char;                             // �ֹ���ü�����ڵ� -
    term_no : array [0..11] of char;              // �ֹ��ڽĺ�����
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // ȸ����
    acpt_time : array [0..8] of char;
    jungcnt   : array [0..9] of char;
    auto_cancel_type  : char;
    rejcode   : array [0..3] of char;
    pgm_gongsi_gb : char;
  //  pgm_gongsi_gb : char;
  end;


  // �ŷ��� ���� ��Ŷ
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
    emp_no  : array [0..7] of char;         // ���
    gubun   : char;                         // 1: ������     7 : ����
    com_gb  : char;                         // 1: tops,   A : �ܺ�
    seq_no  : array [0..8] of char;
    cnt     : array [0..2] of char;         // ����  001
  end;



const
  Len_TopsHeader  = sizeof( TTopsHeader ) - LENGTH_SIZE;
  Len_DataPacket  = sizeof( TTopsDataPacket );
  Len_TopsOrderPacket  = sizeof( TTopsOrderPacket ); // 261
  Len_TopsFillPacket = sizeof( TTopsFillPacket );
  Len_TopsConfirmPacket = sizeof( TTopsConfirmPacket );
  Len_TopsRegist  = sizeof( TTopsRegist );


  Len_QueryHeader = sizeof( TQueryHeader ) - LENGTH_SIZE;  // ��ȸ����������..4����Ʈ ����
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
