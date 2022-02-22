unit KospiPacket;

interface

type
  PKospiHeader = ^TKospiHeader;
  TKospiHeader = packed record
    DataSeq     : array [0..7] of char;
    DataKind    : array [0..2] of char;   // ����Ÿ���� 500 : �ż�, 501 : �ŵ�
    DataCls     : array [0..2] of char;   // * ����Ÿ�з�
    PrdtNo      : array [0..11] of char;  // �����ȣ
    MemberNo    : array [0..2] of char;   // ȸ����ȣ
    BranchNo    : array [0..2] of char;   // ������ȣ
  end;        

  PKospiOrder = ^TKospiOrder;
  TKospiOrder = packed record
    KospiHeader : TKospiHeader;
    OrderNo     : array [0..4] of char;   // �ֹ���ȣ
    OriginNo    : array [0..4] of char;   // ���ֹ���ȣ
    AccountNo   : array [0..11] of char;  // ���¹�ȣ
    OrderQty    : array [0..7] of char;   // �ֹ�����
    OrdPrice    : array [0..8] of char;   // �ֹ�����
    OrderDiv    : array [0..1] of char;   // * �ֹ�����
    CreditDiv   : array [0..1] of char;   // * �ſ뱸��
    Foreigner   : array [0..1] of char;   // �ܱ��������ںз�
    ExcuteCon   : array [0..1] of char;   // ��������
    InvestCode  : array [0..3] of char;   // * ���ڰ��ڵ�
    NotMemNo    : array [0..2] of char;   // ��ȸ����ȣ  0: ȸ��
    Exemption   : array [0..1] of char;   // ��������� 0:����, 1:�����
    ForeigNo    : array [0..5] of char;   // �ܱ��ΰ�����ȣ;
    ForeigNo2   : array [0..2] of char;   // �ܱ��� ������ȣ
    TrustDiv    : array [0..1] of char;   // ��Ź��ǰ���� 1:��Ź, 2:��ǰ
    AceptTime   : array [0..7] of char;   // ���ǻ��ֹ������ð�
    ProgramOrd  : array [0..1] of char;   // ���α׷�ȣ������
    RjctReason  : array [0..1] of char;   // * �źλ���
    OAskDiv     : array [0..1] of char;   // ���ŵ����� 0:����, 1: �����ֽĸŵ�
    MediaDiv    : array [0..1] of char;   // �ֹ��Է¸�ü���� 1:������, 2:�����ܸ�
    DealerInfo  : array [0..11] of char;  // �ֹ��ڽĺ�����
    FreeArea    : array [0..4] of char;
    LargeTrade  : array [0..9] of char;   // �뷮�ŷ�
    OrderCon    : array [0..1] of char;   // �ֹ����� 0:���� 1:IOC 2:FOK
    LPHogaDiv   : array [0..1] of char;   // ����������ȣ������ 0:���� 1: ����������ȣ��
    ForeigAcnt  : array [0..1] of char;
    Filler      : array [0..1] of char;   // Filler
  end;


  // 101:�ż�ü����,  111:�ŵ�ü����
  PKospiFill  = ^TKospiFill;
  TKospiFill  = packed record
    KospiHeader : TKospiHeader;
    NotMemNo    : array [0..2] of char;   // ��ȸ����ȣ
    OrderNo     : array [0..4] of char;   // �ֹ���ȣ
    OriginNo    : array [0..4] of char;   // ���ֹ���ȣ
    AccountNo   : array [0..11] of char;  // ���¹�ȣ
    ForeigNo    : array [0..5] of char;   // �ܱ��ΰ�����ȣ;

    FillNo      : array [0..6] of char;   // ü���ȣ
    FillQty     : array [0..7] of char;   // ü�����
    FillPrice   : array [0..8] of char;   // ü�ᰡ��
    FillDate    : array [0..7] of char;   // ü����
    FillTime    : array [0..7] of char;   // ü��ð�
    FreeArea    : array [0..4] of char;   // ȸ�������ʵ�
    FillType    : array [0..1] of char;   // * ü������
    Filler      : array [0..6] of char;
    SystemDiv   : char;                   // �ý��۱��� 0: ����, 1: ��ü
    GroupNo     : array [0..1] of char;   // �׷��ȣ
    GroupSeq    : array [0..7] of char;
  end;

  // 109:�ż�ü����,  119:�ŵ�ü����
  PKospiReject  = ^TKospiReject;
  TKospiReject  = packed record
    KospiHeader : TKospiHeader;
    NotMemNo    : array [0..2] of char;   // ��ȸ����ȣ
    OrderNo     : array [0..4] of char;   // �ֹ���ȣ
    OriginNo    : array [0..4] of char;   // ���ֹ���ȣ
    AccountNo   : array [0..11] of char;  // ���¹�ȣ
    ForeigNo    : array [0..5] of char;   // �ܱ��ΰ�����ȣ;

    RjtQty      : array [0..7] of char;   // �źμ���
    RjtPrice    : array [0..8] of char;   // �źΰ���
    RjtReason   : array [0..1] of char;   // �źλ���
    RjtDate     : array [0..7] of char;   // �ź���
    RjtTime     : array [0..7] of char;   // �źνð�

    FreeArea    : array [0..4] of char;   // ȸ�������ʵ�

    Filler      : array [0..13] of char;
    SystemDiv   : char;                   // �ý��۱��� 0: ����, 1: ��ü
    GroupNo     : array [0..1] of char;   // �׷��ȣ
    GroupSeq    : array [0..7] of char;
  end;

  //103:�ż����Ȯ��,  113:�ŵ����Ȯ��
  //104:�ż������ֹ����Ȯ��(2004.01.26)
  //114:�ŵ������ֹ����Ȯ��(2004.01.26)
  //PKospiCancel = ^TKospiConfirm;
  // 102:�ż�����Ȯ��,  112:�ŵ�����Ȯ��

  PKospiConfirm = ^TKospiConfirm;
  TKospiConfirm = packed record
    KospiHeader : TKospiHeader;
    NotMemNo    : array [0..2] of char;   // ��ȸ����ȣ
    OrderNo     : array [0..4] of char;   // �ֹ���ȣ
    OriginNo    : array [0..4] of char;   // ���ֹ���ȣ
    AccountNo   : array [0..11] of char;  // ���¹�ȣ
    ForeigNo    : array [0..5] of char;   // �ܱ��ΰ�����ȣ;

    OriginQty   : array [0..7] of char;   // ���ֹ�����
    OriginPrice : array [0..8] of char;   // ���ֹ�����
    CorectQty   : array [0..7] of char;   // ������Ҽ��� : �����ֹ������� �����ȼ���
    CorectPrice : array [0..8] of char;   // ������Ұ��� : �����ֹ��� ����
    FreeArea    : array [0..4] of char;
    Filler      : array [0..14] of char;
    SystemDiv   : char;                   // �ý��۱��� 0: ����, 1: ��ü
    GroupNo     : array [0..1] of char;   // �׷��ȣ
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
    PrdtNo      : array [0..11] of char;  // ���� ����

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
  ///  ����, �ɼ�, �ֽĿɼ�
  ///

  PCommonData = ^TCommonData;
  TCommonData = record
    Size: Integer;
    Packet: array of Char;
  end;


  PCommonHead = ^TCommonHead;
  TCommonHead = packed record
    cSTX        : char;
    stCommsize  : array [0..3] of char;       // ��������
    stLastSN    : array [0..6] of char;       // ���������Ϸù�ȣ
    stApType    : array [0..1] of char;       // �����ĺ��ڵ�
    stClientSN  : array [0..5] of char;       // �����ֹ��Ϸù�ȣ
    stDataCnt   : array [0..1] of char;       // ����Ÿī��Ʈ
    stResponse  : array [0..1] of char;       // �����ڵ�
    stUserID    : array [0..2] of char;       // ����ھ��̵�
    cOD         : char;
    stFiller    : array [0..12] of char;      // �ʷ�
    cEnd        : char;                       // end text '>'
  end;

  // Message Server Header
  PMessageHead = ^TMessageHead;
  TMessageHead = packed record
    cSTX        : char;
    stCommsize  : array [0..3] of char;       // ��������
    stLastSN    : array [0..6] of char;       // ���������Ϸù�ȣ
    stApType    : array [0..1] of char;       // �����ĺ��ڵ�
    stResponse  : array [0..1] of char;       // �����ڵ�
    stUserID    : array [0..2] of char;       // Ŭ���̾�Ʈ IP ������ 3�ڸ�
    stFiller    : array [0..3] of char;       // �ʷ�
  end;



  PDataHead = ^TDataHead;
  TDataHead = packed record
    stAptype      : array [0..1] of char;
    stLength      : array [0..2] of char;
    {stLength2     : array [0..3] of char;
    cMarket       : char;
    stCurPrice    : Array [0..6] of char;       // ���� ���簡
    stFiller      : Array [0..27] of char; 			// ����
    }
  end;

  //�������� 'OR01' (40 + 158byte)---------------------------------------------------
  PSOrdKseAcpt = ^TSOrdKseAcpt;
  TSOrdKseAcpt = packed record
    //���� I/F HEADER (40byte)---------------------------------------------------
    stSize:       array[0..3] of char; //4 ���۱���
    stPID:        array[0..5] of Char; //6 �ش�ܸ� PID
    stIFTRCODE:   array[0..3] of Char; //4 TR-Code   ��������:IF01, �����ɼ�:IO01, �ֽĿɼ�:SO01
    cGb:          Char;                //1 SPACE
    stHeadSN:     array[0..8] of Char; //9 �ֹ��Ϸù�ȣ
    stNumber:     array[0..1] of Char; //2 �ֹ��Է°Ǽ�
    stReject:     array[0..2] of Char; //3 �ֹ��ź��ڵ�
    stInTime:     array[0..7] of Char; //8 �ֹ�ó���ð�
    stFiller:     array[0..2] of Char; //3 ó�����ϴ� ����
    //���� I/F HEADER (40byte)--------------------------------------------------

    stSN:         array[0..8] of Char; //9 �ֹ��Ϸù�ȣ
    stCode:       array[0..7] of Char; //8 �����ڵ�
    stBranch:     array[0..2] of Char; //3 ������ȣ
    stOrderNo:    array[0..6] of Char; //7 �ֹ���ȣ
    stGb:         array[0..1] of Char; //2 ȣ������
    cLS:          Char;                //1 �ŵ�������
    cHogaType:    Char;                //1 ȣ������  (L:������, M:���尡, C:���Ǻ�������, B:������
    stQty:        array[0..7] of Char; //8 ȣ������
    cSign:        Char;                //1 ���ݺ�ȣ
    stPrice:      array[0..8] of Char; //9 ����
    cPropri:      Char;                //1 �ڱⱸ��
    stMarketHoga: array[0..8] of Char; //9 ��������ȣ�����й�ȣ
    stNationCode: array[0..1] of Char; //2 �����ڵ�
    stInvest:     array[0..1] of Char; //2 �������ڵ�
    cGiven:       Char;                //1 ȣ����Ź���
    cTradeType:   Char;                //1 �ŷ� ����
    stOrginNo:    array[0..6] of Char; //7 ���ֹ���ȣ
    stAccNo:      array[0..8] of Char; //9 ���¹�ȣ

    /////////////////// ȸ��ó���׸� - 30byte  /////////////////////////////////
    stCookie:     array[0..6] of char; //7 ��Ű ó��
    stDummy:      array[0..11] of Char;//12 ó�� ���ϴ� ȸ��ó���׸� 1
    stSysType:    array[0..1] of Char; //2 Su:Supra,  FR:FR�� ����Ÿ=> FR�� Supra�� ����ó���ÿ� ���а�
    stID:         array[0..4] of Char; //5 ����� ID
    stSystem:     array[0..1] of Char; //2 �ý��� ����  XT
    stGroupGb:    array[0..1] of Char; //2 �׷� ���а�  01
    ////////////////////////////////////////////////////////////////////////////
    cFiller1:     array[0..11] of Char;//11 �ֽĿ�����¹�ȣ
    stIP:         array[0..11] of Char;//11 ����� IP
    ////////////////////////////////////////////////////////////////////////////
    // �߰� �׸� 200708 ���� ����
    stCondition:  char;                 // �ֹ�����
    stOrderDiv:   char;                 // �ֹ�����
    stCfMemNo:    array [0..2] of char;  // ���Ǵ뷮�ŷ� ���ȸ����ȣ
    stCfAccNo:    array [0..8] of char;  // ���Ǵ뷮�ŷ� �����¹�ȣ
    stCfEndTime:  array [0..3] of char;  // ���Ǵ뷮�ŷ� ���ǿϷ�ð�
    cFiller  :    array [0..4] of Char; //1  ó�����ϴ� ����
  end;

  //��������,��� 'HO01' ( ���� I/F HEADER (40byte) + �����޽���170byte)--------
  PSOrdKseConfirm = ^TSOrdKseConfirm;
  TSOrdKseConfirm = packed record
    //���� I/F HEADER (40byte)---------------------------------------------------
    stSize:       array[0..3] of char; //4 ���۱���
    stPID:        array[0..5] of Char; //6 �ش�ܸ� PID
    stIFTRCODE:   array[0..3] of Char; //4 TR-Code   ��������:IF01, �����ɼ�:IO01, �ֽĿɼ�:SO01
    cGb:          Char;                //1 SPACE
    stHeadSN:     array[0..8] of Char; //9 �ֹ��Ϸù�ȣ
    stNumber:     array[0..1] of Char; //2 �ֹ��Է°Ǽ�
    stReject:     array[0..2] of Char; //3 �ֹ��ź��ڵ�
    stInTime:     array[0..7] of Char; //8 �ֹ�ó���ð�
    stFiller:     array[0..2] of Char; //3 ó�����ϴ� ����
    //���� I/F HEADER (40byte)---------------------------------------------------

    stTRCode:     array[0..3] of Char; //4 TR-CODE
    cContinue:    Char;                //1 ���ӱ���
    stSN:         array[0..8] of Char; //9 ü��������ȣ
    stCode:       array[0..7] of Char; //8 �����ڵ�
    stBranch:     array[0..2] of Char; //3 ������ȣ
    stOrderNo:    array[0..6] of Char; //7 �ֹ���ȣ
    stMember:     array[0..2] of Char; //3 ȸ����ȣ
    stOrginNO:    array[0..6] of Char; //7 ���ֹ���ȣ
    stGb:         array[0..1] of Char; //2 ȣ������
    cLS:          Char;                //1 �ŵ�������
    cType:        Char;                //1 ȣ������  (L:������, M:���尡, C:���Ǻ�������, B:������
    cOrginSign:   Char;                //1 ���ֹ����ݺ�ȣ(���������϶� '-'�� ���)
    stOrginPrice: array[0..8] of Char; //9 ���ֹ�����
    cSign:        Char;                //1 �ֹ����ݺ�ȣ(���������϶� '-'�� ���)
    stPrice:      array[0..8] of Char; //9 �ֹ�����
    stQty:        array[0..7] of Char; //8 ����
    stOrginQty:   array[0..7] of Char; //8 ����/��Ҽ���
    stTime:       array[0..7] of Char; //8 �ð�
    stReason:     array[0..2] of Char; //3 �����ڵ�
    stAccNo:      array[0..8] of Char; //9 ���¹�ȣ
    /////////////////// ȸ��ó���׸� - 30byte  /////////////////////////////////
    stCookie:     array[0..6] of char; //7 ��Ű ó��
    stDummy:      array[0..13] of Char;//14 ó�� ���ϴ� ȸ��ó���׸� 1
    stID:         array[0..4] of Char; //5 ����� ID
    stSystem:     array[0..1] of Char; //2 �ý��� ����
    stGroupGb:    array[0..1] of Char; //2 �׷� ���а�
    ////////////////////////////////////////////////////////////////////////////
    stRjtTime:    array[0..7] of char; // 8 ����/���/�ź�Ȯ�νð�
    stFiller2:    array[0..29] of Char; //22 ó�����ϴ� ����
  end;

  //����ü�� 'CH01' (170byte)---------------------------------------------------
  PSOrdKseFill = ^TSOrdKseFill;
  TSOrdKseFill = packed record
    //���� I/F HEADER (40byte)---------------------------------------------------
    stSize:       array[0..3] of char; //4 ���۱���
    stPID:        array[0..5] of Char; //6 �ش�ܸ� PID
    stIFTRCODE:   array[0..3] of Char; //4 TR-Code   ��������:IF01, �����ɼ�:IO01, �ֽĿɼ�:SO01
    cGb:          Char;                //1 SPACE
    stHeadSN:     array[0..8] of Char; //9 �ֹ��Ϸù�ȣ
    stNumber:     array[0..1] of Char; //2 �ֹ��Է°Ǽ�
    stReject:     array[0..2] of Char; //3 �ֹ��ź��ڵ�
    stInTime:     array[0..7] of Char; //8 �ֹ�ó���ð�
    stFiller:     array[0..2] of Char; //3 ó�����ϴ� ����
    //���� I/F HEADER (40byte)---------------------------------------------------

    stTRCode:     array[0..3] of Char; //4 TR-CODE
    cContinue:    Char;                //1 ���ӱ���
    stSN:         array[0..8] of Char; //9 ü��������ȣ
    stCode:       array[0..7] of Char; //8 �����ڵ�
    stBranch:     array[0..2] of Char; //3 ������ȣ
    stOrderNo:    array[0..6] of Char; //7 �ֹ���ȣ
    stMember:     array[0..2] of Char; //3 ȸ����ȣ
    stFillNO:     array[0..8] of Char; //9 ü���ȣ
    cLS:          Char;                //1 �ŵ�������
    cType:        Char;                //1 ȣ������  (L:������, M:���尡, C:���Ǻ�������, B:������
    cSign:        Char;                //1 ���ݺ�ȣ(���������϶� '-'�� ���)
    stPrice:      array[0..8] of Char; //9 ����

    stQty:        array[0..7] of Char; //8 ����
    stTime:       array[0..7] of Char; //8 �ð�
    stNear:       array[0..8] of Char; //9 �ұٿ���
    stLong:       array[0..8] of Char; //9 ���ٿ���
    //stFiller1:    array[0..5]of Char;  //6 ó�����ϴ� ����
    stAccNo:      array[0..8] of Char; //9 ���¹�ȣ
    /////////////////// ȸ��ó���׸� - 30byte  /////////////////////////////////
    stCookie:     array[0..6] of char; //7 ��Ű ó��
    stDummy:      array[0..13] of Char;//14 ó�� ���ϴ� ȸ��ó���׸� 1
    stID:         array[0..4] of Char; //5 ����� ID
    stSystem:     array[0..1] of Char; //2 �ý��� ����
    stGroupGb:    array[0..1] of Char; //2 �׷� ���а�
    ////////////////////////////////////////////////////////////////////////////
    stFiller2:    array[0..40] of Char;//25 ó�����ϴ� ����
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

  // �ŷ��� ���� ��Ŷ
  UnionKSCPacket = packed record
    case Integer of
      0: ( StKseAcpt        :       TSOrdKseAcpt; );
      1: ( StKseConfirm     :       TSOrdKseConfirm; );
      2: ( StKseFill        :       TSOrdKseFill; );
  end;

  ///  �ŷ��� ���� COMMAND ���
  PStReceptPacket = ^TStReceptPacket;
  TStReceptPacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
    stUnionPak   : UnionKSCPacket;
  end;

  ///  �ŷ��� ���� COMMAND ���
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

����Ÿ�з�9(03)101:����ȣ��, 102:����ȣ��, 103:���ȣ��, 109:�ź�ȣ��

�ֹ�����9(02)1:����,  5:���尡, 6:���Ǻ�������, 9:�ڱ��ֽ�,
          10:s-option�ڱ��ֽ�, 11:������Ź�ڱ��ֽ�, 12:������������
          13:�ֿ켱������, 51:���ߴ뷮, 52:���߹ٽ���
          61:�����ð���, 62:�����ð��ܴ뷮, 63:�����ٽ���
          71:���Ľð���, 72:���Ľð��ܴ뷮, 77:������Ź�ڱ��ֽĽð��ܴ뷮,
          79:�ð��ܴ뷮�ڱ��ֽ�(970710) 80:�ٽ��ϸŸ�
          81:�ð��ܴ��ϰ��Ÿ� 67:�����뷮������Ź�ڻ��� 69:�����뷮�ڱ��ֽ�

�ſ뱸��9(02)10:����,
          21:�ڱ����ڸż�,  22:�ڱ����ڸŵ���ȯ
          23:�ڱ���ָŵ�,  24:�ڱ���ָż���ȯ,
          31:�������ڸż�,  32:�������ڸŵ���ȯ,
          33:������ָŵ�,  34:������ָż���ȯ

���ڰ��ڵ�9(04)1000:����ȸ��, 2000:����, 3000:����,4000:����, 5000:����,
          6000:���, 7000:����, 8000:����,
          9000:ID�ִ¿ܱ���, 9001:ID���¿ܱ���

�źλ���9(02) �ֹ��źλ����߻��� ���(���ӽý��� üũ)
          1:�ŵ������п���,  3:����Ÿ�з�����,      61:ȸ����ȣ����,
          31:�����ȣ����,   39:����Ÿ�����ƴ�,   48:�ð��ܰ�����,
          59:�ֹ���ο���,   98:ȣ������������,     99:�ð��ܸŸŽð�����

ü������9(02)1:�ð�, 2:����, 3:����, 4:���ߵ���, 51:���ߴ뷮, 52:���߹ٽ���,
        61:�尳�����ð�������,62:�尳�����ð��ܴ뷮,63:�尳�����ð��ܹٽ���,
        71:�������Ľð�������,72:�������Ľð��ܴ뷮,80:�������Ľð��ܹٽ���,
        81:�ð��ܴ��ϰ�

}