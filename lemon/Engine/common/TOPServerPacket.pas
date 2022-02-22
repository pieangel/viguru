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
    Quotient : char;    //  DATA_LENGHT ���� ���� ��
    Remainder : char ;  //  DATA_LENGHT ���� ���� ������
  end;

  PTopsOrderPacket = ^TTopsOrderPacket;
  TTopsOrderPacket = packed record
    header  : TTopsHeader;
    tr_code : array [0..5] of char;         // TR_ORDER
    the_date: array [0..7] of char;         // 20130422
    emp_no  : array [0..5] of char;         // �����ȣ
    fund_no : array [0..5] of char;         // �ݵ��ڵ�  right(6)
    bkt_cd  : array [0..8] of char;         // space
    wave_id : array [0..1] of char;         // space
    team  : array [0..5] of char;           // 'A15   '
    mkt_cls : char;                         // ���屸��  ���� : 'F'  �ɼ� 'P'
    isu_cd  : array [0..14] of char;        // �����ڵ�    '201B2270       '
    expcode : array [0..11] of char;        // ǥ�������ڵ�
    tr_unt  : char;                         // �ŷ��������� ���� 'space'
    ord_ty  : char;                         // 1: ���尡 2: ������  I:���Ǻ����� X:������
    tr_cls  : char;                         // 1:�ŵ�     2: �ż�
    ord_cls : char;                         // 1:�ű�     2: ����     3: ���
    kq_ord_cls  : char;                     // �ڽ��� �ֹ� ���� 'space'
    crctn_cls : char;
    befor_crctn_qty : array [0..4] of char; // ���������� 'space' --> �˰������ �������� ���� 2013.09.25
                                            // 41 : �Ϲ�    61 : �˰�
    ord_qty : array [0..9] of char;         // �ֹ�����
    ord_prc : array [0..10] of char;
    trade_type : char;                        // 1:����     2:����      3: ��Ÿ   '3'
    ord_no  : array [0..9] of char;          //�ֹ���ȣ
    org_ord_no  : array [0..9] of char;      // ���ֹ���ȣ    '0000000000'
    mtr_ord_no  : array [0..9] of char;      // ���ֹ���ȣ     '0000000000'
    rqst_no     : array [0..9] of char;      // ������ȣ      '0000000000'
    org_rqst_no : array [0..9] of char;      // ��������ȣ     '0000000000'
    ntc_no      : array [0..9] of char;      // ������ȣ       '0000000000'
    ord_tm      : array [0..7] of char;      // �ֹ������ð�    'space'
    rjct_rsn    : array [0..11] of char;     // �źλ���       'space'
    setup_qty   : array [0..8] of char;      // ��������    '000000000'
    bkt_tr_cls  : char;                      // �ٽ��� �Ÿ� ���� 'space'
    cond        : char;                      // ���� 1:����      2: û��   'space'
    accnt_no    : array [0..11] of char;
    pswd_no     : array [0..7] of char;      // space
    term_no     : array [0..14] of char;     // ip  '120.110.001.001'
    org_tord_no : array [0..9] of char;      // '00000000000'
    isu_cls     : char;                      // space
    ord_cond    : char;                      // 0:�Ϲ�     3:IOC       4:FOK
    limit_over_flag : char;                  // �ѵ��ʰ� �÷��� 'Y:�ѵ��ʰ�   N:�ѵ����ʰ�
    ETX : char;
  end;

  PTopsAcceptPacket = ^TTopsAcceptPacket;
  TTopsAcceptPacket = packed record
    tr_code : array [0..5] of char;         // TR_SUC_ORDER   or   TR_RJT_ORDER
    the_date: array [0..7] of char;         // 20130422
    fund_no : array [0..5] of char;         // �ݵ��ڵ�  right(6)
    bkt_cd  : array [0..8] of char;         // space
    isu_cd  : array [0..14] of char;        // �����ڵ�    '201B2270       '

    tr_cls  : char;                         // 1:�ŵ�     2: �ż�
    ord_cls : char;                         // 1:�ű�     2: ����     3: ���
    befor_crctn_qty : array [0..4] of char; // ���������� 'space'

    ord_qty : array [0..9] of char;         // �ֹ�����
    ord_prc : array [0..10] of char;
    ord_no  : array [0..9] of char;          //�ֹ���ȣ
    org_ord_no  : array [0..9] of char;      // ���ֹ���ȣ    '0000000000'
    mtr_ord_no  : array [0..9] of char;      // ���ֹ���ȣ     '         '
    rqst_no     : array [0..9] of char;      // ������ȣ      '0000000000'
    org_rqst_no : array [0..9] of char;      // ��������ȣ     '0000000000'
    ntc_no      : array [0..9] of char;      // ������ȣ       '0000000000'
    ord_tm      : array [0..7] of char;      // �ֹ������ð�    'space'

    norm_flag   : char;                      // ���󿩺�      ' '
    rjct_rsn    : array [0..11] of char;     // �źλ���
    msg         : array [0..199]  of char ;
    tord_no     : array [0..9] of char;      // ������ �ֹ���ȣ
    org_tord_no : array [0..9] of char;       // ������ ���ֹ���ȣ

    accnt_no    : array [0..11] of char;      // ���¹�ȣ
    term_no     : array [0..11] of char;     // ip  '120110001001'
    mkt_cls : char;                          // ���屸��  ���� : 'F'  �ɼ� 'P'
    cli_index : array [0..4] of char;
    ord_cond  : char;                        // 0:�Ϲ�     3:IOC       4:FOK
  end;

  PTopsFillPacket = ^TTopsFillPacket;
  TTopsFillPacket = packed record
    tr_code : array [0..5] of char;          // TR_FILL
    fund_no : array [0..5] of char;          // �ݵ��ڵ�  right(6)
    ord_no  : array [0..9] of char;          //�ֹ���ȣ
    rqst_no : array [0..9] of char;          // ������ȣ      '0000000000'
    conc_no : array [0..10] of char;          // ü���ȣ( ������ȣ )
    cntrt_no: array [0..10] of char;          // ������ȣ
    revs_cls: char;                           // �ڽ��ڸ� ���
    tr_cls  : char;                           // 1:�ŵ�     2: �ż�
    isu_cd  : array [0..14] of char;        // �����ڵ�    '201B2270       '
    ksdq_ord_cd : array [0..31] of char;      // �ڽ��ڸ� ���
    conc_prc    : array [0..10] of char;      // ü�ᰡ��
    conc_qty    : array [0..9] of char;       // ü�����
    conc_tm     : array [0..8] of char;       // ü��ð�     update by 2013.06.04
    frst_cmdt_ctrct_prc : array [0..10] of char;    // �ֱٿ� ��������
    scnd_cmdt_ctrct_prc : array [0..10] of char;     // ���ٿ���
    accnt_no    : array [0..11] of char;            // ���¹�ȣ
  end;


  PTopsChangeConfrimPacket = ^TTopsChangeConfrimPacket;
  TTopsChangeConfrimPacket = packed record
    tr_code : array [0..5] of char;          // TR_CHANGE_CONFIRM
    fund_no : array [0..5] of char;          // �ݵ��ڵ�  right(6)
    ord_no  : array [0..9] of char;          //�ֹ���ȣ
    rqst_no : array [0..9] of char;          // ������ȣ      '0000000000'
    org_ord_no  : array [0..9] of char;       // ���ֹ���ȣ
    org_rqst_no : array [0..9] of char;       // ��������ȣ
    price   : array [0..10] of char;           // ��������
    qty     : array [0..9] of char;           // ȣ������
    crctn_qty : array [0..9] of char;         // ��������
    rjct_rsn  : array [0..11] of char;        // �ź��ڵ�
    cnfrm_dt  : array [0..7] of char;         // Ȯ�νð�
    isu_cd    : array [0..14] of char;        // �����ڵ�
    accnt_no  : array [0..11] of char;        // ���¹�ȣ
    tr_cls    : char;
    tord_no   : array [0..9] of char;
    org_tord_no: array [0..9] of char;
    mkt_cls : char;
  end;

  PTopsCancelConfrimPacket = ^TTopsCancelConfrimPacket;
  TTopsCancelConfrimPacket = packed record
    tr_code : array [0..5] of char;          // TR_CANCEL_CONFIRM
    fund_no : array [0..5] of char;          // �ݵ��ڵ�  right(6)
    ord_no  : array [0..9] of char;          //�ֹ���ȣ
    rqst_no : array [0..9] of char;          // ������ȣ      '0000000000'
    org_ord_no  : array [0..9] of char;       // ���ֹ���ȣ
    org_rqst_no : array [0..9] of char;       // ��������ȣ
    price   : array [0..10] of char;           // ��Ұ���
    qty     : array [0..9] of char;           // ȣ������
    cnlt_qty : array [0..9] of char;         // ��Ҽ���
    rjct_rsn  : array [0..11] of char;        // �ź��ڵ�
    cnfrm_dt  : array [0..7] of char;         // Ȯ�νð�
    isu_cd    : array [0..14] of char;        // �����ڵ�
    mtr_ord_no: array [0..9] of char;         // ���ֹ���ȣ
    accnt_no  : array [0..11] of char;        // ���¹�ȣ
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
    emp_no  : array [0..5] of char;         // ���
    gubun   : char;                         // 1: ������     5 : ����
    cnt     : array [0..2] of char;         // ����
  end;

  // �ڿ��� �ݵ��ڵ� 6�ڸ��� ��� �ٿ� ����.


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
    result                : char;                     // 1' ����, '2' ID ����, '3' PW ����, '4' ID�� IP ����ġ'9' DB Error
    date                  : array[0..7] of char;      // ������
    emp_no                : array[0..5] of char;      // �����ȣ
    dptmt                 : array[0..5] of char;      // �μ�
    athrty                : char;                     // ����
    emp_nm                : array[0..9] of char;      // �����
    msg                   : array[0..127] of char;    // ���л���
  end;

  PPosIn = ^TPosIn;                                   // Q40002
  TPosIn = packed record
    Query : TQuery;
    emp_no                : array[0..5] of char;      // �����ȣ
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    isu_gb                : char;                     // 0:��ü, 1:����, 2:�ɼ� 3:�ݿɼ�, 4:ǲ�ɼ�
  end;


  PActiveIn = ^TActiveIn;                                 // Q40001
  TActiveIn = packed record
    Query : TQuery;
    emp_no                : array[0..5] of char;      // �����ȣ
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    isu_gb                : char;                     // ���񱸺� (0:��ü, 1:����, 2:�ɼ�)
    tr_gb                 : char;                     // �Ÿű��� (0:��ü, 1:�ŵ�, 2:�ż�)
    che_gb                : char;                     // ü�ᱸ�� (0:��ü, 1:��ü��, 2:ü��)
    accnt_no              : array[0..11] of char;     // ���¹�ȣ
    gubun                 : char;                     // 1:��ǰ 0:��Ź
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

  //������
  PPosOutSub = ^TPosOutSub;                           // Q40014
  TPosOutSub = packed record
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    isu_cd                : array[0..8] of char;      // �����ȣ
    kor_isu_nm            : array[0..19] of char;     // �����
    tr_cls                : char;                     // �Ÿű��� (1 : �ŵ�, 2 : �ż�)
    bk_qty                : array[0..8] of char;      // ��μ���
    bk_prc                : array[0..11] of char;     // ��δܰ�
    bk_amt                : array[0..14] of char;     // ��αݾ�
    prsnt_prc             : array[0..5] of char;      // ���簡
    ass_prft_ls           : array[0..14] of char;     // �򰡼���
    man_prft_ls           : array[0..14] of char;     // �������
    bef_ass_prft_ls       : array[0..14] of char;     // �����򰡼���
    tr_prft_ls            : array[0..14] of char;     // �Ÿż���
    cmsn                  : array[0..14] of char;     // ������
  end;

   //ü��, ��ü��
  PActiveOutSub = ^TActiveOutSub;                           // Q40002
  TActiveOutSub = packed record
    fund_no               : array[0..5] of char;      // �ݵ��ȣ
    attr_fund_no          : char;                     // �ݵ��ȣ�� �Ӽ�
    isu_cd                : array[0..8] of char;      // �����ȣ
    attr_isu_cd           : char;                     // �����ȣ�� �Ӽ�
    kor_isu_nm            : array[0..19] of char;     // �����
    attr_kor_isu_nm       : char;                     //
    tr_cls                : char;                     // �Ÿű���
    attr_tr_cls           : char;                     //
    ord_qty               : array[0..6] of char;      // �ֹ�����
    attr_ord_qty          : char;                     //
    ord_prc               : array[0..8] of char;      // �ֹ�����(9.2)
    attr_ord_prc          : char;                     //
    conc_qty              : array[0..6] of char;      // ü�����
    attr_conc_qty         : char;                     //
    conc_prc              : array[0..8] of char;      // ü��ܰ�
    attr_conc_prc         : char;                     //
    rem_qty               : array[0..6] of char;      // �ܷ�
    attr_rem_qty          : char;                     //
    cert                  : array[0..3] of char;      // Ȯ��
    attr_cert             : char;                     //
    prsnt_prc             : array[0..4] of char;      // ���簡
    attr_prsnt_prc        : char;                     //
    buy_bdoff             : array[0..4] of char;      // �ż�ȣ��
    attr_buy_bdoff        : char;                     //
    sell_bdoff            : array[0..4] of char;      // �ŵ�ȣ��
    attr_sell_bdoff       : char;                     //
    hilmt_price           : array[0..4] of char;      // ���Ѱ�
    attr_hilmt_price      : char;                     //
    lolmt_price           : array[0..4] of char;      // ���Ѱ�
    attr_lolmt_price      : char;                     //
    crctn_qty             : array[0..6] of char;      // ��������
    attr_crctn_qty        : char;                     //
    cnlt_qty              : array[0..6] of char;      // ��Ҽ���
    attr_cnlt_qty         : char;                     //
    ord_no                : array[0..9] of char;      // �ֹ���ȣ
    attr_ord_no           : char;                     //
    mtr_ord_no            : array[0..9] of char;      // ���ֹ���ȣ
    attr_mtr_ord_no       : char;                     //
    org_ord_no            : array[0..9] of char;      // ���ֹ���ȣ
    attr_orf_ord_no       : char;                     //
    rpt_qty               : array[0..6] of char;      // �뺸����
    attr_rpt_qty          : char;                     //
    ord_ty                : char;                     // �ֹ�����
    attr_ord_ty           : char;                     //
    ord_cls               : char;                     // �ֹ�����
    attr_ord_cls          : char;                     //
    rqst_no               : array[0..9] of char;      // ������ȣ
    attr_rqst_no          : char;                     //
    org_rqst_no           : array[0..9] of char;      // ��������ȣ
    attr_org_rqst_no      : char;                     //
    rjct_rsn              : array[0..11] of char;     // �źλ���
    attr_rjct_rsn         : char;                     //
    conc_amt              : array[0..14] of char;     // ü��ݾ�
    attr_cont_amt         : char;                     //
    prvsdy_clng_prc       : array[0..4] of char;      // ���ϰ�
    attr_prvsdy_clng_prc  : char;                     //
    stnd_price            : array[0..4] of char;      // ���ذ�
    attr_stnd_price       : char;
    trade_type            : char;                     // �ŷ�����(1:����, 2:����, 3:��Ÿ)
    attr_trade_type       : char;                     //
    accnt_no              : array[0..11] of char;     // ���¹�ȣ
    attr_accnt_no         : char;                     //
    tord_no               : array[0..9] of char;      // �������ֹ���ȣ
    attr_tord_no          : char;                     //
    org_tord_no           : array[0..9] of char;      // ������ ���ֹ���ȣ
    attr_org_tord_no      : char;                     //
    errmsg                : array[0..91] of char;     // �źθ޽���
    attr_errmsg           : char;                     //
    isu_cls               : char;                     // �Ϲݺ��ձ���
    attr_isu_cls          : char;                     //
    conc_tm               : array[0..7] of char;      // ü��ð�
    acc_tm                : array[0..7] of char;      // �����ð�
    ord_cond              : char;                     // ' ':���� I:IOC F:FOK
    che_gb                : char;                     // ü�ᱸ��(0:��ü, 1:��ü��, 2:ü��)
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
