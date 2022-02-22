unit ApiPacket;

interface

type
  // �������簡 �ü�     Qry_LastPrice = 'FZQ12010'
  TQuerySymbolInfo = record
    ChnageSign  : char;
    KrxCode : array [0..31] of char;
    Code    : array [0..31] of char;
    EngCode : array [0..31] of char;

    KorName : array [0..29] of char;
    EngName : array [0..29] of char;

    Last    : array [0..15] of char;
    Base    : array [0..15] of char;  // ���ذ�
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

  // 20180915  �������� ��ȸ ( ���� ������ �ð��� - ��û ���� )
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

    AskHoga   : array [0..4] of TCommonAskUnit; // �ŵ��� 5 --> 1 ȣ�� ��
    BidHoga   : array [0..4] of TCommonBidUnit; // �ż��� 1 --> 5 ȣ�� ������

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

  //  ����/�������� ȣ�� �ü�   Real_FutHoga = 'SB_FUT_HOGA';
  TWooFutHoga = record
    TrCode  : array [0..3] of char;          //  ����:F1H0, ��������:F1H0
    Code    : array [0..31] of char;
    Hoga1   : TWooFutHogaUnit;
    HogaTime: array [0..7] of char;
    Hoga2   : TWooFutHogaUnit;
    Hoga3   : TWooFutHogaUnit;
    TotAskVol : array [0..5] of char;
    TotBidVol : array [0..5] of char;
    Hoga4   : TWooFutHogaUnit;
    Hoga5   : TWooFutHogaUnit;
    // �� �ܷ��̶� �Ǽ��� �и��س�������...�˼��� ����
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

  // �ǽð� �ɼ� ȣ�� Real_OptHoga = 'SB_OPT_HOGA';
  TWooOptHoga = record
    TrCode  : array [0..3] of char;                    // �ɼ�:O1H0
    Code    : array [0..31] of char;
    Hoga1   : TWooOptHogaUnit;
    HogaTime: array [0..7] of char;
    Hoga2   : TWooOptHogaUnit;
    Hoga3   : TWooOptHogaUnit;
    TotAskVol : array [0..6] of char;
    TotBidVol : array [0..6] of char;
    Hoga4   : TWooOptHogaUnit;
    Hoga5   : TWooOptHogaUnit;
    // �� �ܷ��̶� �Ǽ��� �и��س�������...�˼��� ����
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

  // �ǽð� �ֽļ��� ȣ��     SB_STOCK_FUT_HOGA
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
    TrCode  : array [0..3] of char;                    // �ɼ�:F2H0
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
    TrCode  : array [0..3] of char;     // ���� F1CO   SF : F
    Code    : array [0..31] of char;
    Time    : array [0..7] of char;
    Price   : array [0..9] of char;

    NearPrice : array [0..8] of char;
    FarPrice  : array [0..8] of char;
    Open      : array [0..9] of char;
    High      : array [0..9] of char;
    Low       : array [0..9] of char;

    DailyVolume : array [0..6] of char;
    DailyAmount : array [0..11] of char;      // ���� õ��

    NearVolume : array [0..6] of char;
    NearAmount : array [0..11] of char;      // ���� õ��

    FarVolums : array [0..6] of char;
    FarAmount : array [0..11] of char;      // ���� õ��

    ConsVolume : array [0..6] of char;       // ���� �뷮ü�����
    ConsAmount : array [0..11] of char;      // ���� �뷮ü����

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
    DynamicUpperLimit : array [0..9] of char;      // �������� ������� ���߻��Ѱ�
    DynamicLowerLimit : array [0..9] of char;
  end;


  // �ǽð� �ɼ� ü�� Real_OptExec = 'SB_OPT_EXEC';
  TWooOptExec = record
    TrCode  : array [0..3] of char;     // �ɼ�:O1C0
    Code    : array [0..31] of char;
    Time    : array [0..7] of char;
    Price   : array [0..8] of char;

    Open      : array [0..8] of char;
    High      : array [0..8] of char;
    Low       : array [0..8] of char;

    DailyVolume : array [0..7] of char;
    DailyAmount : array [0..11] of char;      // ���� õ��

    ConsVolume : array [0..6] of char;       // ���� �뷮ü�����
    ConsAmount : array [0..11] of char;      // ���� �뷮ü����

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
    DynamicUpperLimit : array [0..9] of char;      // �������� ������� ���߻��Ѱ�
    DynamicLowerLimit : array [0..9] of char;

  end;

  TWooFutOpen = record
    TrCode  : array [0..3] of char;    // F1M0
    OpenDiv : array [0..1] of char;   // M0 : ����   M1 : ��������  M2 : ����Ȯ��
    Code    : array [0..31] of char;
    Date    : array [0..7] of char;
    Volume  : array [0..6] of char;
  end;

  TWooOptOpen = record
    TrCode  : array [0..3] of char;    // O1M0
    Date    : array [0..7] of char;
    Code    : array [0..31] of char;
    Volume  : array [0..6] of char;
    OpenDiv : array [0..1] of char;   // M0 : ����   M1 : ��������  M2 : ����Ȯ��
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
    DGubun        : array [0..3] of char;     // ����Ÿ ����
    MktCdFogb     : array [0..3] of char;     //
    MkDate          : array [0..7] of char;
    MkTime          : array [0..5] of char;
		InvstCode			: array [0..3] of char;

		SellQty				: array [0..9] of char;     //	/* �ŵ�����(���)												*/
		SellAmt				: array [0..9] of char;     //	/* �ŵ����(�鸸��)												*/
		BuyQty				: array [0..9] of char;     //	/* �ż�����(���)												*/
		BuyAmt				: array [0..9] of char;     //	/* �ż����(�鸸��)												*/

		SellQtyGap				: array [0..9] of char;     //	/* �ŵ�����(���)												*/
		SellAmtGap				: array [0..9] of char;     //	/* �ŵ����(�鸸��)												*/
		BuyQtyGap				: array [0..9] of char;     //	/* �ż�����(���)												*/
		BuyAmtGap				: array [0..9] of char;     //	/* �ż����(�鸸��)												*/


   {
		BuyRate				: array [0..9] of char;     //	/* �ż� ����(%)	Float											*/
		SellRate			: array [0..9] of char;     //	/* �ŵ� ����(%)	Float											*/

		PurityQty			: array [0..9] of char;     //	/* ���ż�����(���)												*/
		PurityAmt			: array [0..9] of char;     //	/* ���ż����(�鸸��)											*/

		Sp_BuyQty			: array [0..9] of char;     //	/* ��������ż�����(���)										*/
		Sp_BuyAmt			: array [0..9] of char;     //	/* ��������ż����(�鸸��)										*/
		Sp_BuyRate		: array [0..9] of char;     //	/* �ż� ����(%)	Float											*/
		Sp_SellQty		: array [0..9] of char;     //	/* ��������ŵ�����(���)										*/
		Sp_SellAmt		: array [0..9] of char;     //	/* ��������ŵ����(�鸸��)										*/
		Sp_SellRate		: array [0..9] of char;     //	/* �ŵ� ����(%)	Float											*/
		Sp_PurityQty	: array [0..9] of char;     //	/* ����������ż�����(���)										*/
		Sp_PurityAmt	: array [0..9] of char;     //	/* ����������ż����(�鸸��)									*/
    }
  end;


  PAutoInvestOptData = ^TAutoInvestOptData;
  TAutoInvestOptData = record
    DGubun        : array [0..3] of char;     // ����Ÿ ����
    MktCdFogb     : array [0..3] of char;     //
    MkDate          : array [0..7] of char;
    MkTime          : array [0..5] of char;
		InvstCode			: array [0..3] of char;

		SellQty				: array [0..9] of char;     //	/* �ŵ�����(���)												*/
		SellAmt				: array [0..9] of char;     //	/* �ŵ����(�鸸��)												*/
		BuyQty				: array [0..9] of char;     //	/* �ż�����(���)												*/
		BuyAmt				: array [0..9] of char;     //	/* �ż����(�鸸��)												*/

		SellQtyGap				: array [0..9] of char;     //	/* �ŵ�����(���)												*/
		SellAmtGap				: array [0..9] of char;     //	/* �ŵ����(�鸸��)												*/
		BuyQtyGap				: array [0..9] of char;     //	/* �ż�����(���)												*/
		BuyAmtGap				: array [0..9] of char;     //	/* �ż����(�鸸��)												*/
  end;


  // �ֹ����ɼ���  ATQ39105 / CTQ10061

  TInputOrderAbleQty = record
    AccountNo : array [0..5] of char;
    AcntPass: array [0..7] of char;
    Code    : array [0..31] of char;

    TradeCode : array [0..1] of char;       // �ŷ�����ڵ�
    DerivCode : array [0..2] of char;
    Side      : char;                       // 1:�ż�, 2:�ŵ�
    OrderDiv  : char;                       // 1:������, 2:���尡, 3:���Ǻ�������, 4:������������
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

  // �ֹ� / ü�� ����  ATQ39120 / CTQ10024
  TInputOrderList = record
    TradeDate : array [0..7] of char;
    AccountNo : array [0..5] of char;
    AcntPass  : array [0..7] of char;

    Code      : array [0..31] of char;
    Side      : char;       //  ' ':��ü  1:�ż�, 2:�ŵ�
    OrdForm   : char;       //  ' ':��ü, 1:�Ϲ�
    OrdState  : char;       //  ' ':��ü, 4:ü��, 5:��ü��

    TradeCode : array [0..1] of char;       // �ŷ�����ڵ�
    PrdtDiv   : char;       //  0:��ü, 1:����, 2:�ɼ�, 3:Call�ɼ�, 4:Put�ɼ�, 5:��������
    MediaDiv  : char;       //  ��ü����  ' '
    QeuryDiv  : char;       //  ��ȸ����  1
    OrderNo   : array [0..6] of char;     // '9999999'
    MulitAcntDiv  : char;   //  'N'
    FundNo    : array [0..2] of char;     //  000:��
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
    TradeCode : array [0..1] of char;       // �ŷ�����ڵ�
    DerivCode : array [0..2] of char;
    KrxCode   : array [0..31] of char;

    NHCode    : array [0..31] of char;
    EngCode   : array [0..31] of char;
    KorName   : array [0..79] of char;
    EngName   : array [0..79] of char;

    OrderDiv  : char;                     // �ֹ�����
    Side      : char;                     // �ֹ�����
    MediaDiv  : char;                     // ��ü����
    Qty       : array [0..7] of char;     // �ֹ�����
    Price     : array [0..11] of char;
    FillQty   : array [0..7] of char;
    FillPrice : array [0..11] of char;
    FillAmt   : array [0..14] of char;

    RemainQty : array [0..7] of char;
    ModifyQty : array [0..7] of char;
    CancelQty : array [0..7] of char;
    PriceType : char;                          // �ֹ�����

    FillQtyDiv: char;                         // ü���������
    OrderForm : char;                         // �ֹ�����

    ProcState : char;                         // ó������
    ProcStateName : array [0..19] of char;    // ó�����¸�

    AceptTime : array [0..7] of char;         // �����ð�
    IP        : array [0..14] of char;        // IP
    RjctCode  : array [0..9] of char;         //
    StgName   : array [0..29] of char;
    DealerNo  : array [0..2] of char;         // ������ȣ
    UserName  : array [0..19] of char;        // �����
  end;

  // ������ ��ȸ   ATQ39706 / CTQ10032

  TInputDeposit = record
    ReqDate : array [0..7] of char;       // space
    AccountNo : array [0..5] of char;
    AcntPass  : array [0..7] of char;
    MediaDiv  : char;                     //   'C'
  end;

  POutDeposit = ^TOutDeposit;
  TOutDeposit = record
    TotDeposit  : array [0..14] of char;          //    ��Ź�ݾ��Ѿ�
    DepositCash : array [0..14] of char;          //    ��Ź�ݾ�����
    DepositSub  : array [0..14] of char;          //    ��Ź�ݾ״��
    DepositFor  : array [0..14] of char;          //    ��Ź�ݾ׿�ȭ

    OrdAblTotAmt: array [0..14] of char;          //    �ֹ����ɱݾ��Ѿ�
    OrdAbltCash : array [0..14] of char;          //    �ֹ����ɱݾ�����
    OrdAbleSub  : array [0..14] of char;          //    �ֹ����ɱݾ״��
    OrdAbleFor  : array [0..14] of char;          //    �ֹ����ɱݾ׿�ȭ

    OutAbleTotAmt : array [0..14] of char;        //    ���Ⱑ�ɱݾ��Ѿ�
    OutAbleCash : array [0..14] of char;          //    ���Ⱑ�ɱݾ�����
    OutAlbeSub  : array [0..14] of char;          //    ���Ⱑ�ɱݾ״��
    OutAbleFor  : array [0..14] of char;          //    ���Ⱑ�ɱݾ׿�ȭ

    TrustMarginTotAmt : array [0..14] of char;          //    ��Ź���ű��Ѿ�
    TrustMarginCash   : array [0..14] of char;          //    ��Ź���ű�����
    TrustMarginSub    : array [0..14] of char;          //    ��Ź���űݴ��
    TrustMarginFor    : array [0..14] of char;          //    ��Ź���űݿ�ȭ

    StayMarginTotAmt  : array [0..14] of char;          //    �������ű��Ѿ�
    StayMarginCash  : array [0..14] of char;          //    �������ű�����
    StayMarginSub   : array [0..14] of char;          //    �������űݴ��
    StayMarginFor   : array [0..14] of char;          //    �������űݿ�ȭ

    AddMarginTotAmt : array [0..14] of char;          //    �߰����ű��Ѿ�
    AddMarginCash   : array [0..14] of char;          //    �߰����ű�����
    AddMarginSub    : array [0..14] of char;          //    �߰����űݴ��
    AddMarginFor    : array [0..14] of char;          //    �߰����űݿ�ȭ

    AddMarginDesc   : array [0..39] of char;          //    �߰����űݹ߻�����
    FutTradePL      : array [0..14] of char;          //    �����Ÿż���
    OptTradePL      : array [0..14] of char;          //    �ɼǸŸż���
    FutSettleAmt    : array [0..14] of char;          //    ������������
    OptSettleAmt    : array [0..14] of char;          //    �ɼǰ������
    InSuAmt         : array [0..14] of char;          //    �μ������
    Fee             : array [0..14] of char;          //    ������
    Filler1         : array [0..59] of char;          //
    SubstAmt        : array [0..14] of char;          //    ���ݾ�
    Filler2         : array [0..104] of char;         //
  end;


  // �̰��� �ܰ�     ATQ39701 / CTQ10031

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
    OpenPLRate  : array [0..6] of char;       // �򰡼���
    UnitAmt     : array [0..9] of char;       // �����ݾ�
    PrevClose   : array [0..11] of char;
    Last        : array [0..11] of char;
    AskPrice    : array [0..11] of char;
    BidPrice    : array [0..11] of char;
  end;

  POrderExec = ^TOrderExec;
  TOrderExec = record
    /////////////     ����κ�
    UserID  : array [0..15] of char;
    OrderID : array [0..7] of char;
    UserName: array [0..19] of char;
    OrderIP : array [0..14] of char;
    RealDiv : char;       //    1;�ܸ���, 2:�ܸ���(��, ����, ����), 3:��������, A:��ܰ�
    AcntType  : char;     //    1:�����ֹ�ü��, 2:�׷��ֹ�ü��, 3:���������ֹ�(ü��),
                          //    4:���������ֹ�(�ܰ�), 5:STOP, 6:FIX�ֹ�, 7:FIX�����ֹ�,
                          //    8:�Ϲݿ����ֹ�, A:������ �޽���, B:������¸� ��ȸ

    DspDiv1 : char;
    DspDiv2 : char;
    DspDiv3 : char;
    MediaDiv  : char;
    Filler    : array [0..1] of char;

    /////////////   �ֹ�ü��
    DataDiv : array [0..1] of char;     //  12:�ŷ�������, 13:Ȯ��, 14:ü��, 15:���ֹ�����Ÿ����, 19:�ź�
    AcntNo  : array [0..5] of char;
    AcntName  : array [0..29] of char;
    xxxDiv    : char;
    BranchNo  : array [0..2] of char;
    OrderNo   : array [0..6] of char;
    OCOSeq    : array [0..7] of char;
    KrxCode   : array [0..9] of char;

    OrderDiv  : char;                  //     1:����, 2:����, 3:���
    PriceType : char;                  //     1:������, 2:���尡, 3:�ð���, 4:������������
    FillDiv   : char;                  //     1:FAS, 2:FOK, 3:FAK
    TradeType : char;                  //     1: ����, 2:����, 3:��Ÿ
    Side      : char;                 //      1: �ż�, 2:�ŵ�

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
    OrderType     : char;         //  1:�Ϲ��ֹ�, 2:STOP�ֹ�, 3:SCALE�ֹ�, 4:�ݺ��ֹ�, 5:�����ֹ�
                                  //  6:OCO�ֹ�, 7:����ֹ�
    GroupID       : array [0..2] of char;
    GroupName     : array [0..19] of char;
    RjctCode     : array [0..9] of char;     // �ź��ڵ�
    ProcCode      : char;                    // 1:������, 2:����, 3:Ȯ��, 4:ü��, 5:���� ��ü��, 9:�ź�
    OrderStateNm  : array [0..13] of char;   //  ������, ��ü��, �Ϻ�ü��, ü��, ������ü��, �ź�
    OrderInputTime  : array [0..7] of char;   // �ֹ� �Է½ð�

    /////////////   �ֹ�ü��

    FillNo  : array [0..8] of char;
    FillKrCode  : array [0..9] of char;
    FillSide  : char;     //   1:�ż�, 2:�ŵ�
    FillTime  : array [0..7] of char;
    FillPrice2 : array [0..9] of char;
    FillQty2   : array [0..7] of char;
    FillAmt2   : array [0..12] of char;

    /////////////   �ܰ� ����

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