unit ApiPacket;

interface

type
  // ---------------------  ��ȸ  --------------------------


  PCommonHeader = ^TCommonHeader;
  TCommonHeader = record
    WindowID  : array [0..9] of char;
    ReqKey    : char;
    ErrorCode : array [0..3] of char;         // ���� or 0000  -> ����
    NextKind  : char;                         // 0 : ���� ����   1: ���� ����
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
    Code    : array [0..10] of char;
    Name    : array [0..29] of char;
    Pass    : array [0..7] of char;
  end;

  POutSymbolListInfo = ^TOutSymbolLIstInfo;
  TOutSymbolLIstInfo = record
		AssetsID		: array [0..2] of char;   //	/* �ŷ�����ڻ� 												*/
		FullCode		: array [0..11] of char;
		ATM_Kind		: char;                   //  /* ATM ���� ('Y', 'N')											*/
		ShortCode		: array [0..7] of char;   //	/* �����ڵ�														*/
		Index				: array [0..3] of char;
		JongName		: array [0..29] of char;  //	/* �ѱ� �����													*/
		JongEName		: array [0..29] of char;  //	/* ���� �����													*/
		LastDate		: array [0..9] of char;   //	/* yyyy.mm														*/
		ExecPrice		: array [0..9] of char;   //	/* xxx.x														*/
		DecimalPrice: char;			              //  /* Declmal ����													*/
		MarketGb		: char;	                  //	/* 1:���� 2:CALL 3:PUT 4:����spread 5:��spread 6:ǲspread		*/
	 	TradeUnit		: array [0..12] of char;	//  /* �ŷ��¼�
  end;

  //  2003, 2004, 2007, 2022  ����⺻����, ���񸶽���  , �������簡
  PReqSymbolMaster = ^TReqSymbolMaster;
  TReqSymbolMaster = record
    header : TCommonHeader;
    AssetsID  : array [0..2] of char;       // �ŷ�����ڻ�
    FullCode  : array [0..11] of char;      // �����ڵ�
    Index     : array [0..3] of char;
  end;


  POutSymbolMaster = ^TOutSymbolMaster;
  TOutSymbolMaster = record
    Header    : TCommonHeader;
		FullCode			: array [0..11] of char;    //	/* ����ǥ���ڵ�													*/
		StdPrice			: array [0..10] of char;    //	/* ���ذ�														*/
		HighLimitPrice: array [0..10] of char;    //	/* ���Ѱ�														*/
		LowLimitPrice	: array [0..10] of char;    //	/* ���Ѱ�														*/
		CBHighLimitPrice: array [0..10] of char;  //	/* CB������Ѱ�													*/
		CBLowLimitPrice	: array [0..10] of char;  //	/* CB�������Ѱ�													*/
		PDVolume			  : array [0..7] of char;   //	/* ���ϰŷ���													*/
		PDMoney				  : array [0..14] of char;  //	/* ���ϰŷ����													*/
		PDEndPrice			: array [0..7] of char;   //	/* ��������														*/
		RemainDays			: array [0..2] of char;   //	/* �����ϼ�														*/
		LastTradeDate		: array [0..7] of char;   //	/* �����ŷ���YYYYMMDD											*/
		ListedHighPrice	: array [0..10] of char;  //	/* �������ְ���													*/
		ListedHighPriceDate: array [0..7] of char;//	/* �������ְ���YYYYMMDD											*/
		ListedLowPrice		 : array [0..10] of char;//	/* ������������													*/
		ListedLowPriceDate : array [0..7] of char;//	/* ������������YYYYMMDD											*/
		ImpliedVolatility	: array [0..6] of char;	//  /* ���纯����													*/
		CDInterest			  : array [0..6] of char;	//  /* CD�ݸ�(%)													*/
		DividendIndex		  : array [0..14] of char;//	/* ���������̷���ġ											*/
		RTime_Hi			    : array [0..10] of char;//	/* �ǽð����Ѱ�													*/
		RTime_Lo			    : array [0..10] of char;//	/* �ǽð����Ѱ�													*/
		RTime_Clear			  : char;                 //	/* 0.���ش����� 1.�ش����� 2.�Ͻ����� 3.��������				*/
  end;

    //�ִ� 20��
  POutSymbolFilllListSub = ^TOutSymbolFillListSub;
  TOutSymbolFillListSub = record
	  Time				: array [0..7] of char;         //	/* �ð�(HH:MM:SS)												*/
    CmpSign			: char;                         //	/* ����ȣ
                                                //    0.���� 1.���� 2.���� 3.��� 4.�϶�
                                                //    5.�⼼���� 6.�⼼���� 7.�⼼��� 8.�⼼�϶�					*/
    CmpPrice		: array [0..10] of char;        //	/* ���ϴ��														*/
    CurrPrice		: array [0..10] of char;        //	/* ���簡														*/
    CmpRate			: array [0..7] of char;         //	/* �����														*/
    Volume			: array [0..7] of char;         //	/* �ŷ���														*/
    Money				: array [0..11] of char;        //	/* �ŷ����(õ��)												*/
    NowVol			: array [0..5] of char;         //	/* ü�����														*/
    NonSettlQty	: array [0..7] of char;         //	/* �̰����������												*/
    PDEndPrice	: array [0..10] of char;        //	/* ��������														*/
    MatchKind		: char;                         //	/* ���簡�� ȣ������ (+:�ż� -:�ŵ�)							*/
  end;

  POutSymbolFilllList = ^TOutSymbolFillList;
  TOutSymbolFillList = record
	  Header    : TCommonHeader;
    FullCode	: array [0..12] of char;        //	/* ����ǥ���ڵ�													*/
    DataCnt		: array [0.. 2] of char;        //	/* Data Count
  end;

  POutSymbolMarkePrice = ^TOutSymbolMarkePrice;
  TOutSymbolMarkePrice = record
	  Header    : TCommonHeader;
		FullCode	: array [0..11] of char;          //	/* ����ǥ���ڵ�													*/
		CurrPrice	: array [0..9] of char;           //	/* ���簡														*/
		CmpSign		: char;                           //	/* ����ȣ
                                                //    0.���� 1.���� 2.���� 3.��� 4.�϶�
                                                //    5.�⼼���� 6.�⼼���� 7.�⼼��� 8.�⼼�϶�					*/
		CmpPrice	: array [0..9] of char;           //	/* ���ϴ��														*/
		CmpRate		: array [0..7] of char;           //	/* �����														*/
		StartPrice: array [0..9] of char;           //	/* �ð�															*/
		HighPrice	: array [0..9] of char;           //	/* ����															*/
		LowPrice	: array [0..9] of char;           //	/* ����															*/
		SellPrice	: array [0..9] of char;           //	/* �ŵ�ȣ��														*/
		BuyPrice	: array [0..9] of char;           //	/* �ż�ȣ��														*/
		NowVol	  : array [0..5] of char;           //	/* ü�ᷮ														*/
		Volume	  : array [0..7] of char;           //	/* �ŷ���														*/
		Money			: array [0..11] of char;          //	/* �ŷ����(õ��)												*/
		PDEndPrice : array [0..7] of char;          //	/* ��������														*/
		MarketStat: array  [0..19] of char;         //	/* ������
                                                //    1.��ü�ŷ��ߴ� 2.��ü�ŷ��簳 3.����ŷ��ߴ� 4.����ŷ��簳
                                                //    5.CB�ߴ�  6.CB�簳 7.�帶�� 9.���ݱ޺�(CB)�ߴܿ���
                                                //    A.�ֽ�CB�ߴܿ��� B.�ֽ�CB�߰� C.�ֽ�CB�簳
                                                //    D.���� ���ϰ� ȣ�� ��������(�������������� �ŷ�����)		*/
		NonSettlQty		 : array [0..7] of char;      //	/* �̰�����������												*/
		CmpNonSettlQty : array [0..7] of char;      //	/* ��������														*/
		TheoryPrice		 : array [0..10] of char;     //	/* �̷а�														*/
		TheoryBasis		 : array [0..7] of char;      //	/* �̷к��̽ý�													*/
		MarketBasis		 : array [0..7] of char;      //	/* ���庣�̽ý�													*/
		Disparate			 : array [0..8] of char;      //	/* ������														*/
		DispaGap			 : array [0..7] of char;      //	/* ������														*/
		Delta				  : array [0..12] of char;      //	/* ��Ÿ															*/
		Gamma				: array [0..12] of char;        //	/* ����															*/
		Rho					: array [0..12] of char;        //	/* ��															*/
		Theta				: array [0..12] of char;        //	/* ��Ÿ															*/
		Vega				: array [0..12] of char;        //	/* ����															*/
		HistVolat			: array [0..7] of char;       //	/* ������������													*/
		UpCode				: array [0..3] of char;       //	/* kospi200�����ڵ�												*/
		KospiTime			: array [0..7] of char;       //	/* kospi200�����ð�												*/
		StartJisu			: array [0..6] of char;       //	/* kospi�ð�����												*/
		HighJisu			: array [0..6] of char;       //	/* kospi��������												*/
		LowJisu				: array [0..6] of char;       //	/* kospi��������												*/
		LastJisu			: array [0..6] of char;       //	/* kospi��������												*/
		Dungrak				: char;                       //	/* ������� (' '.���� +.��� -.�϶�)							*/
		Debi				  : array [0.. 6] of char;      //	/* �����														*/
		DebiRate			: array [0.. 7] of char;      //	/* �����														*/
		JisuVolume		: array 	[0..9] of char;     //	/* �ŷ���(õ��)													*/
		JisuMoney			: array [0..9] of char;       //	/* �ŷ����(�鸸��)												*/
		Time				  : array [0..7] of char;       //	/* HH:MM:SS														*/
		ImpliedVolatility	: array [0..6] of char;   //	/* ���纯����													*/
		CDInterest			: array [0..6] of char;     //	/* CD�ݸ�														*/
		RemainDays			: array [0..2] of char;     //	/* �����ϼ�
  end;

  TSymbolHogaUnit = record
    SellPrice	: array [0..9] of char;      //	/* �ŵ�ȣ��														*/
    BuyPrice	: array [0..9] of char;      //	/* �ż�ȣ��														*/
    SellQty		: array [0..6] of char;      //	/* �ŵ��ܷ�
    BuyQty		: array [0..6] of char;      // /* �ż��ܷ�														*/
    SellCnt		: array [0..4] of char;      //	/* �ŵ��Ǽ�														*/
    BuyCnt		: array [0..4] of char;      //	/* �ż��Ǽ�														*/
  end;

  POutSymbolHoga = ^TOutSymbolHoga ;
  TOutSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..11] of char;    //	/* ����ǥ���ڵ�													*/
		Time				: array [0..7] of char;     //	/* �ð�(HH:MM:SS)												*/
		ClosePrice  : array [0..7] of char;     //	/* ��������									*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..6] of char;    //	/* �ŵ���ȣ������9(6)											*/
		TotBuyQty		: array [0..6] of char;    //	/* �ż���ȣ������9(6)											*/
		TotSellNo		: array [0..4] of char;    //	/* �ŵ���ȣ���Ǽ�9(5)											*/
		TotBuyNo		: array [0..4] of char;    //	/* �ż���ȣ���Ǽ�9(5)
    Equilibrium	: array [0..7] of char;     //	/* KOFEX ����ü�ᰡ(����ȣ��)									*/
		CurrPrice		: array [0..9] of char;     //	/* ���簡S9(6)V9(2)
  end;

  // ��Ʈ ����Ÿ
  PReqChartData = ^TReqChartData;
  TReqChartData = record
	  Header    : TCommonHeader;
    JongUp    : char;                   //  /* 1.���� 2.���� 3.KOSPI200 ����/�ɼ� 4.KOFEX ����/�ɼ�			*/
		DataGb		: char;                   //	/* 1.�� 2.�� 3.�� 4.tick 5.��
		DiviGb		: char;                   //  /* 0.����, �Ϻ��� �׸���� �ݿ�X 1.����, �Ϻ��� �׸���� �ݿ�O
											                  //  �� �׽� 0���� �÷��ֽø� �˴ϴ�.								*/								*/
		AssetsID  : array [0..2] of char;   //	/* �ŷ�����ڻ�
		FullCode	: array [0..11] of char;  //	/* ����ǥ���ڵ�													*/
		Index			: array [0..3] of char;   //	/* �ڵ� index													*/
		InxDay		: array [0..7] of char;   //	/* ��������														*/    ��,ƽ�� ����
		DayCnt		: array [0..2] of char;   //	/* ���ڰ���														*/
		Summary		: array [0..2] of char;   //	/* tick, �п��� ������ ����										*/									*/
  end;

  POutChartDataSub = ^TOutChartDataSub;
  TOutChartDataSub = record
    Date				: array [0..7] of char;   //   /* YYYYMMDD														*/
    Time				: array [0..7] of char;   //  /* �ð�(HH:MM:SS)												*/
    OpenPrice		: array [0..9] of char;  //   /* �ð� double													*/
    HighPrice		: array [0..9] of char;  //   /* ���� double													*/
    LowPrice		: array [0..9] of char;  //   /* ���� double													*/
    ClosePrice	: array [0..9] of char;  //   /* ���� double													*/
    Volume			: array [0..9] of char;  //   /* �ŷ��� double

		Money				: array [0..19] of char; // 	/* �ŷ���� (õ��)												*/
		Kijunka			: array [0..9] of char;	 //   /* ���ذ�(��)													*/
		FacePrice		: array [0..9] of char;	 //   /* �׸鰡(��)													*/
		AvgPrice		: array [0..9] of char;	 //   /* ������հ�(��) �����ֽļ�(õ��)								*/
		Gwunbae			: char;	                  //    /* ������
  end;

  POutChartData = ^TOutChartData;
  TOutChartData = record
	  Header    : TCommonHeader;
    FullCode	: array [0..11] of char;    //    /* ����ǥ���ڵ�													*/
    MaxDataCnt: array [0..2] of char;     //    /* ��ü���� ����												*/
    DataCnt		: array [0..2] of char;     //    /* ����۽����� ����											*/
    TickCnt		: array [0..2] of char;     //    /* ���������� tick ����											*/
    Today			: array [0..7] of char;     //    /* �翵����(StockDate[0])										*/									*/
    PrevLast	: array [0..8] of char;     //    /* ��������														*/
  end;

  PSendAutoKey = ^TSendAutoKey ;
  TSendAutoKey = record
    header : TCommonHeader;
	  Auto_Kind	 : char;	                //  1.�Ϲ� �ü�, 2.CME �Ϲ� �ü� 3.������ �ü�					*/
	  AutoKey		 : array [0..31] of char; //	/* ������ ��� ���¹�ȣ, �ü� ��� ����ǥ���ڵ�					*/
  end;



  ////  �ü� �ڵ� ������Ʈ  -----------------------------------------------------------------
  ///
{$REGION '�ü� �ڵ� ������Ʈ....'}

  PAutoSymbolHoga = ^TAutoSymbolHoga ;
  TAutoSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..11] of char;    //	/* ����ǥ���ڵ�													*/
		DecimalPrice: char;                     //	/* �Ҽ��� ����			*/
		Time				: array [0..7] of char;     //	/* �ð�(HH:MM:SS)												*/
		ClosePrice  : array [0..7] of char;     //	/* ��������									*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..6] of char;    //	/* �ŵ���ȣ������9(6)											*/
		TotBuyQty		: array [0..6] of char;    //	/* �ż���ȣ������9(6)											*/
		TotSellNo		: array [0..4] of char;    //	/* �ŵ���ȣ���Ǽ�9(5)											*/
		TotBuyNo		: array [0..4] of char;    //	/* �ż���ȣ���Ǽ�9(5)
    Equilibrium	: array [0..7] of char;     //	/* KOFEX ����ü�ᰡ(����ȣ��)									*/
		CurrPrice		: array [0..9] of char;     //	/* ���簡S9(6)V9(2)
  end;


  PAutoSymbolPrice = ^TAutoSymbolPrice;
  TAutoSymbolPrice = record
    Header    : TCommonHeader;
		FullCode			: array [0..11] of char;    //	/* ����ǥ���ڵ� 												*/
		DecimalPrice	: char;                     //	/* Declmal ����													*/
		Time				  : array [0..7] of char;     //	/* �ð�(HH:MM:SS) 												*/
		CurrPrice			: array [0..9] of char;     //	/* ���簡S9(4)V9(2)												*/
		CmpSign				: char;                     //	/* ����ȣ
                                              //    0.���� 1.���� 2.���� 3.��� 4.�϶�
                                              //    5.�⼼���� 6.�⼼���� 7.�⼼��� 8.�⼼�϶�					*/
		CmpPrice			: array [0..9] of char;     //	/* ���ϴ��9(5)V9(2)											*/
		CmpRate				: array [ 0..7] of char;    //	/* �����9(5)V9(2) 												*/
		StartPrice		: array [0..9] of char;     //	/* �ð�S9(4)V9(2)												*/
		HighPrice			: array [0..9] of char;     //	/* ����S9(4)V9(2) 												*/
		LowPrice			: array [0..9] of char;     //	/* ����S9(4)V9(2) 												*/
		SellPrice			: array [0..9] of char;     //	/* �ŵ�ȣ��S9(4)V(2)											*/
		BuyPrice			: array [0..9] of char;     //	/* �ż�ȣ��S9(4)V(2)											*/
		NowVol				: array [0..5] of char;     //	/* ü�����9(6) 												*/
		Volume				: array [0..7] of char;     //	/* �ŷ���9(8) 													*/
		Money				  : array [0..11] of char;    //	/* �ŷ����(õ��)9(12)											*/
		PDEndPrice		: array	[0..7] of char;     //	/* ��������S9(4)V9(2)											*/
		MarketStat		: array	[0..19] of char;    //	/* ������
                                              //    1.��ü�ŷ��ߴ� 2.��ü�ŷ��簳 3.����ŷ��ߴ� 4.����ŷ��簳
                                              //    5.CB�ߴ�  6.CB�簳 7.�帶�� 9.���ݱ޺�(CB)�ߴܿ���
                                              //    A.�ֽ�CB�ߴܿ��� B.�ֽ�CB�߰� C.�ֽ�CB�簳
                                              //    D.���� ���ϰ� ȣ�� ��������(�������������� �ŷ�����)		*/
		NonSettlQty		: array	[0..7] of char;     //	/* �̰�����������9(8)											*/
		CmpNonSettlQty: array	[0..7] of char;     //	/* ��������9(8)													*/
		TheoryPrice		: array	[0..10] of char;    //	/* �̷а�9(4)V9(6) 												*/
		TheoryBasis		: array	[0..7] of char;     //	/* �̷к��̽ý�S9(4)V9(2)										*/
		MarketBasis		: array	[0..7] of char;     //	/* ���庣�̽ý�S9(4)V9(2)										*/
		Disparate			: array [0..8] of char;     //	/* ������9(5)V9(2)												*/
		DispaGap			: array [0..7] of char;     //	/* ������S9(4)V9(2)												*/
		Delta				  : array [0..12] of char;    //	/* ��ŸS9(5)V9(4)												*/
		Gamma				  : array [0..12] of char;    //	/* ����S9(5)V9(4)												*/
		Rho					  : array [0..12] of char;    //	/* ��  S9(5)V9(4)												*/
		Theta				  : array [0..12] of char;    //	/* ��ŸS9(5)V9(4)												*/
		Vega				  : array [0..12] of char;    //	/* ����S9(5)V9(4)												*/
		HistVolat			  : array [0..7] of char;   //	/* ������������S9(3)V9(4)										*/
		ListedHighPrice	: array	[0..9] of char;   //	/* �������ְ���S9(4)V9(2)										*/
		ListedHighPriceDate: array [0..7] of char;//	/* �������ְ���YYYYMMDD											*/
		ListedLowPrice		 : array [0..9] of char;//	/* ������������S9(4)V9(2)										*/
		ListedLowPriceDate : array [0..7] of char;//	/* ������������YYYYMMDD											*/
		ImpliedVolatility	 : array [0..6] of char;//	/* ���纯����9(3)V9(3)											*/
		RTime_Hi			    : array [0..9] of char;	//  /* �ǽð����Ѱ�													*/
		RTime_Lo			    : array [0..9] of char;	//  /* �ǽð����Ѱ�													*/
		RTime_Clear			  : char;                 //	/* 0.���ش�����	1.�ش����� 2.�Ͻ����� 3.��������				*/
		HighLimitPrice		: array [0..9] of char;	//  /* ���Ѱ�														*/
		LowLimitPrice		  : array [0..9] of char;	//  /* ���Ѱ�
  end;

    // �ִ� 5��
  PAutoSymbolTickSub = ^TAutoSymbolTickSub;
  TAutoSymbolTickSub = record
		Time				 : array [0.. 7] of char;   //	/* �ð�(HH:MM:SS)												*/
		CmpSign			 : char;                    //	/* ����ȣ
                                            //    0.���� 1.���� 2.���� 3.��� 4.�϶�
                                            //    5.�⼼���� 6.�⼼���� 7.�⼼��� 8.�⼼�϶�					*/
		CmpPrice		 : array [0..10] of char;   //	/* ���ϴ��9(5)V9(2)											*/
		CurrPrice		 : array [0..10] of char;   //	/* ���簡S9(4)V9(2)												*/
		CmpRate			 : array [0..7] of char;    //	/* �����9(5)V9(2)												*/
		Volume			 : array [0..7] of char;    //	/* �ŷ��� 														*/
		Money				 : array [0..11] of char;   //	/* �ŷ����(õ��)												*/
		NowVol			 : array [0..5] of char;    //	/* ü�����														*/
		NonSettlQty	 : array [0..5] of char;    //	/* �̰�����������												*/
		MatchKind		 : char;                    //	/* ���簡�� ȣ������ (+.�ż� -.�ŵ�)							*/
		LastJisu		 : array [0..10] of char;   //	/* KOSPI200���� ����9(4)V9(2)									*/
		Dungrak			 : char;                    //	/* �������	(' '.���� +.��� -.�϶�)							*/
		Debi				 : array [0..7] of char;    //	/* ����� 9(4)V9(2)												*/
		TheoryPrice	 : array [0..10] of char;   //	/* �̷а�9(4)V9(6)												*/
		TheoryDungrak: char;                    //	/* �������	(' '.���� +.��� -.�϶�)							*/
		TheoryDebi	 : array [0..7] of char;    //	/* �����9(4)V9(6)												*/
		TheoryBasis	 : array [0..7] of char;    //	/* �̷к��̽ý�S9(4)V9(2)										*/
		MarketBasis	 : array [0..7] of char;    //	/* ���庣�̽ý�S9(4)V9(2)										*/
  end;

  PAutoSymbolTick = ^TAutoSymbolTick;
  TAutoSymbolTick = record
	  Header      : TCommonHeader;
		FullCode		: array	[0..11] of char;    //	/* ����ǥ���ڵ�													*/
		DecimalPrice: char;                     //	/* Declmal ����													*/
		Count				: array [0..2] of char;     //	/* Sub Count													*/
  end;


// �ڵ� Update : �����ں��Ÿ���Ȳ(KOSPI200���� ����)
  PAutoInvestFutDataSub = ^TAutoInvestFutDataSub;
  TAutoInvestFutDataSub = record
		InvstCode			: array [0..1] of char;	    //  /* ������ü�ڵ�
											                        //  00.��ü 01.�������� 02.����ȸ�� 03.���ڽ�Ź 04.����
											                        //  05.��Ÿ���� 06.����ݵ� 07.����� 08.��Ÿ���� 09.����
											                        //  10.�ܱ��� 11.���ֿܱ��� 12.������ü							*/
		BuyQty				: array [0..9] of char;     //	/* �ż�����(���)												*/
		BuyAmt				: array [0..9] of char;     //	/* �ż����(�鸸��)												*/
		BuyRate				: array [0..9] of char;     //	/* �ż� ����(%)	Float											*/
		SellQty				: array [0..9] of char;     //	/* �ŵ�����(���)												*/
		SellAmt				: array [0..9] of char;     //	/* �ŵ����(�鸸��)												*/
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
  end;

  PAutoInvestFutData = ^TAutoInvestFutData;
  TAutoInvestFutData = record
	  Header      : TCommonHeader;
		Time				: array [0..7] of char;       //	/* �ð�(HH:MM:SS)												*/
		DataCnt			: array [0..1] of char;       //	/* �Ǽ�															*/
	  Sub_Ary			: array [0..12] of TAutoInvestFutDataSub;
  end;

// �ڵ� Update : �����ں��Ÿ���Ȳ(KOSPI200���� �ɼ�)
  PAutoInvestOptDataSub = ^TAutoInvestOptDataSub;
  TAutoInvestOptDataSub = record
		InvstCode			: array [0..1] of char;	    //  /* ������ü�ڵ�
											                        //  00.��ü 01.�������� 02.����ȸ�� 03.���ڽ�Ź 04.����
											                        //  05.��Ÿ���� 06.����ݵ� 07.����� 08.��Ÿ���� 09.����
											                        //  10.�ܱ��� 11.���ֿܱ��� 12.������ü							*/
		BuyQty				: array [0..9] of char;     //	/* �ż�����(���)												*/
		BuyAmt				: array [0..9] of char;     //	/* �ż����(�鸸��)												*/
		BuyRate				: array [0..9] of char;     //	/* �ż� ����(%)	Float											*/
		SellQty				: array [0..9] of char;     //	/* �ŵ�����(���)												*/
		SellAmt				: array [0..9] of char;     //	/* �ŵ����(�鸸��)												*/
		SellRate			: array [0..9] of char;     //	/* �ŵ� ����(%)	Float											*/
		PurityQty			: array [0..9] of char;     //	/* ���ż�����(���)												*/
		PurityAmt			: array [0..9] of char;     //	/* ���ż����(�鸸��)											*/

		c_BuyQty			: array [0..9] of char;     //	/* �ݿɼǸż�����(���)										*/
		c_BuyAmt			: array [0..9] of char;     //	/* �ݿɼǸż����(�鸸��)										*/
		c_BuyRate		  : array [0..9] of char;     //	/* �ż� ����(%)	Float											*/
		c_SellQty		  : array [0..9] of char;     //	/* �ݿɼǸŵ�����(���)										*/
		c_SellAmt		  : array [0..9] of char;     //	/* �ݿɼǸŵ����(�鸸��)										*/
		c_SellRate		: array [0..9] of char;     //	/* �ŵ� ����(%)	Float											*/
		c_PurityQty	  : array [0..9] of char;     //	/* �ݿɼǼ��ż�����(���)										*/
		c_PurityAmt	  : array [0..9] of char;     //	/* �ݿɼǼ��ż����(�鸸��)									*/

		p_BuyQty			: array [0..9] of char;     //	/* ǲ�ɼǸż�����(���)										*/
		p_BuyAmt			: array [0..9] of char;     //	/* ǲ�ɼǸż����(�鸸��)										*/
		p_BuyRate		  : array [0..9] of char;     //	/* �ż� ����(%)	Float											*/
		p_SellQty		  : array [0..9] of char;     //	/* ǲ�ɼǸŵ�����(���)										*/
		p_SellAmt		  : array [0..9] of char;     //	/* ǲ�ɼǸŵ����(�鸸��)										*/
		p_SellRate		: array [0..9] of char;     //	/* �ŵ� ����(%)	Float											*/
		p_PurityQty	  : array [0..9] of char;     //	/* ǲ�ɼǼ��ż�����(���)										*/
		p_PurityAmt	  : array [0..9] of char;     //	/* ǲ�ɼǼ��ż����(�鸸��)									*/
  end;

  PAutoInvestOptData = ^TAutoInvestOptData;
  TAutoInvestOptData = record
	  Header      : TCommonHeader;
		Time				: array [0..7] of char;       //	/* �ð�(HH:MM:SS)												*/
		DataCnt			: array [0..1] of char;       //	/* �Ǽ�															*/
	  Sub_Ary			: array [0..12] of TAutoInvestOptDataSub;
  end;


{$ENDREGION}

/////////////////////////////////////////////////////?

{$REGION '������ȸ....'}

  // 5111   ���� ��ü�� ��ȸ

  PReqAccountFill = ^TREqAccountFill;
  TReqAccountFill = record
    Header    : TCommonHeader;
    Account	 : array [0..10] of char;   //	/* ���¹�ȣ														*/
    Pass		 : array [0..7] of char;    //	/* ��й�ȣ														*/
    Market_Kind: char;                  //	/* ���屸�� (0.��ü 1.KSE 2.KSE���� 3.KSE�ֽĿɼ� 4.KOFEX)		*/
    Trace_Kind	 : char;      			    //	/* ü�ᱸ�� (0:��ü 1:ü��2:��ü��)								*/
    Order_Date	 : array [0..7] of char;    //	/* �ֹ�����														*/
    Gubn		 : char;                    //  /* ��ȸ���� (1:���� 2:����)
  end;

  // �ִ� 20��
  POutAccountFillSub = ^TOutAccountFillSub;
  TOutAccountFillSub = record
//    Header    : TCommonHeader;
		Jmno			: array [0..9] of char;   //	/* �ֹ��ֹ�ȣ													*/
		Wjmno			: array	[0..9] of char;   //	/* ���ֹ��ι�ȣ													*/
		FullCode	: array	[0..11] of char;  //	/* �����ȣ														*/
		Jmhg			: array	[0..19] of char;  //	/* �����														*/
		Mmcd			: char;                   //	/* �Ÿű����ڵ�
                                        //    1.�ż� 2.�ŵ� 3.�ż����� 4.�ŵ�����
                                        //    5.�ż���� 6.�ŵ���� ' '.��Ÿ								*/
		Mmgb			: array [0..7] of char;   //	/* �Ÿű��� 													*/
		Jmqt			: array [0..6] of char;   //	/* �ֹ�����														*/
		Hogb			: char;                   //	/* ���ݱ���
                                        //    1:������ 2:���尡 3:���Ǻ������� 4:������������
                                        //    5:������IOC 6:������FOK 7:���尡IOC 8:���尡FOK
                                        //    9:������IOC A:������FOK										*/
		Jmjs			: array	[0..8] of char;   //	/* �ֹ�����														*/
		Mcgqt			: array	[0..6] of char;   //	/* ��ü����� 													*/
		Cgqt			: array	[0..6] of char;   //	/* ü�����														*/
		Cgjs			: array	[0..8] of char;   //	/* ü������														*/
		Cgtm			: array	[0..7] of char;   //	/* �����ð� 													*/
		Stat			: array	[0..7] of char;   //	/* �������� 													*/
		Grjn			: array	[0..10] of char;  //	/* ������ȣ														*/
		Susu			: array	[0..9] of char;   //	/* ������														*/
		Cggm			: array	[0..14] of char;  //	/* �����ݾ�														*/
		Sggm			: array	[0..14] of char;  //	/* ������������ݾ�												*/
		Plus			: char;                   //	/* 1:+															*/
		Account		: array	[0..10] of char;	//  /* ���¹�ȣ
  end;

  POutAccountFill = ^TOutAccountFill;
  TOutAccountFill = record
    Header    : TCommonHeader;
    Account		: array [0..10] of char;      //	/* ���¹�ȣ														*/
    AcctNm		: array [0..19] of char;      //	/* ���¸�														*/
    Dtno			: array [0..4] of char;       //	/* �ݺ�Ƚ��
  end;

  // 5112   ���� ���ܰ� ��ȸ

  PReqAccountPos = ^TReqAccountPos;
  TReqAccountPos = record
    Header    : TCommonHeader;
    Account		: array [0..10] of char;    //	/* ���¹�ȣ														*/
    Pass			: array [0..7] of char;     //	/* ��й�ȣ
    Gubn			: char;                     //	/* ���屸�� (0.������ü)
  end;

  // �ִ� 20��
  POutAccountPosSub = ^TOutAccountPosSub;
  TOutAccountPosSub = record
		FullCode	 : array [0..11] of char;   //	/* �����ڵ�														*/
		Jmhg			 : array [0..19] of char;   //	/* �����														*/
		Mmcd			 : char;                    //	/* �Ÿ��ڵ� (1.�ŵ� 2.�ż�)										*/
		Mmgb			 : array [0..3] of char;    //	/* �Ÿű��� 													*/
		Jgqt			 : array [0..5] of char;    //	/* �ܰ�����														*/
		Jmqt			 : array [0..5] of char;    //	/* �ֹ����ɼ���													*/
		Curr			 : array [0..8] of char;    //	/* ���簡		/ 100												*/
		Avgt			 : array [0..11] of char;   //	/* ��հ� 		/ 100000												*/
		Fagm			 : array [0..14] of char;   //	/* �򰡱ݾ�														*/
		Sonic			 : array [0..14] of char;   //	/* �򰡼��� 													*/
		Srate			 : array [0..6] of char;    //	/* ������ 														*/
		CAvgt			 : array [0..11] of char;   //	/* �������ذ��� 												*/
		CFagm			 : array [0..14] of char;   //	/* �򰡱ݾ�														*/
		CSonic		 : array [0..14] of char;   //	/* �򰡼��� 													*/
		CSrate		 : array [0..6] of char;    //	/* ������ 														*/
    Account	   : array [0..10] of char;   //  /* ���¹�ȣ														*/
  end;

  POutAccountPos = ^TOutAccountPos;
  TOutAccountPos = record
	  Header     : TCommonHeader;
		Account		 : array [0..10] of char;   //	/* ���¹�ȣ														*/
		Accont_Name: array [0..19] of char;   //	/* ���¸�														*/
		Yttm			 : array [0..14] of char;   //	/* ��Ź�Ѿ� 													*/
		Jscg			 : array [0..14] of char;   //	/* ��������														*/
		Opgm			 : array [0..14] of char;   //	/* �ɼǰ�������													*/
		Susu			 : array [0..14] of char;   //	/* ������														*/
		Cyttm			 : array [0..14] of char;   //	/* ��������������												*/
		Fyttm			 : array [0..14] of char;   //	/* �򰡿�Ź�Ѿ�													*/
		Dtno			 : array [0..4] of char;    //	/* �ݺ�Ƚ��
  end;

  // 5122  ��Ź�ڻ�� ���ű�

  PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountDeposit = record
	  Header     : TCommonHeader;
		Account		 : array [0..10] of char;	          //  /* ���¹�ȣ														*/
		Pass			 : array [0..7] of char;            //	/* ��й�ȣ														*/
  end;

    //�ִ� 5��
  ROutAccountDepositSub = ^TOutAccountDepositSub;
  TOutAccountDepositSub = record
		Fjamt				: array [0..14] of char;    //	/* �����ŵ��ż��ݾ�												*/
		Sjamt				: array [0..14] of char;    //	/* ��������ݾ�													*/
		Ojsm				: array [0..14] of char;    //	/* �ɼǸż��ݾ�													*/
		Ojdm				: array [0..14] of char;    //	/* �ɼǸŵ��ݾ�													*/
		Otjm				: array [0..14] of char;    //	/* �ɼǰ������ű�												*/
		Pfjm				: array [0..14] of char;    //	/* ���ݺ������ű�												*/
		Spgm				: array [0..14] of char;    //	/* �����������ű�												*/
		Insdm				: array [0..14] of char;    //	/* �ǹ��μ����ݾ�												*/
		Gtjm				: array [0..14] of char;    //	/* �ּ����ű�													*/
		Mmsi				: array [0..14] of char;    //	/* ���ϼ������սǾ�												*/
		Opgm				: array [0..14] of char;    //	/* ���ϿɼǼ��ż����
  end;

  ROutAccountDeposit = ^TOutAccountDeposit;
  TOutAccountDeposit = record
	  Header      : TCommonHeader;
		Syttm				: array [0..14] of char;    //	/* �尳������Ź�Ѿ�												*/
		Sythg				: array [0..14] of char;    //	/* �尳������Ź����												*/
		Sytdy				: array [0..14] of char;    //	/* �尳������Ź���												*/
		Yttm				: array [0..14] of char;    //	/* ���Ͽ�Ź�Ѿ�													*/
		Ythg				: array [0..14] of char;    //	/* ���Ͽ�Ź����													*/
		Ytdy				: array [0..14] of char;    //	/* ���Ͽ�Ź���													*/
		Ytjm				: array [0..14] of char;    //	/* ��Ź���ű��Ѿ�												*/
		Ycjm				: array [0..14] of char;    //	/* ��Ź�������ű�												*/
		Ydjm				: array [0..14] of char;    //	/* ��Ź������ű�												*/
		Cjgtm				: array [0..14] of char;    //	/* �߰����ű��Ѿ�												*/
		Cjghg				: array [0..14] of char;    //	/* �߰����ű����� 												*/
		Cjgdy				: array [0..14] of char;    //	/* �߰����űݴ��												*/
		Jgtm				: array [0..14] of char;    //	/* �ֹ����ű��Ѿ�												*/
		Jghg				: array [0..14] of char;    //	/* �ֹ����ű�����												*/
		Jgdy				: array [0..14] of char;    //	/* �ֹ����űݴ��												*/
		Ictm				: array [0..14] of char;    //	/* ���Ⱑ���Ѿ�													*/
		Ichg				: array [0..14] of char;    //	/* ���Ⱑ������													*/
		Icdy				: array [0..14] of char;    //	/* ���Ⱑ�ɴ��													*/
		Ytjy				: array [0..14] of char;    //	/* �������ű��Ѿ�												*/
		Ycjy				: array [0..14] of char;    //	/* �����������ű�												*/
		Ydjy				: array [0..14] of char;    //	/* ����������ű�												*/
		Jscg				: array [0..14] of char;    //	/* ��������(����)����											*/
		Susu				: array [0..14] of char;    //	/* ������
    SubData     : TOutAccountDepositSub;    //  0.��ü 1.������ǰ�� 2.��ä��ǰ��
											                      //    3.��ȭ��ǰ�� 4.COMMODITY��ǰ��
  end;

  POutAccountAdjustMent = ^TOutAccountAdjustMent;
  TOutAccountAdjustMent = record
	  Header      : TCommonHeader;
		Tyttm				: array [0..12] of char;    //	/* ��Ź�Ѿ�														*/
		Jscg				: array [0..12] of char;    //	/* ������������													*/
		Dicg				: array [0..12] of char;    //	/* ������������													*/
		Gscg				: array [0..12] of char;    //	/* ������������													*/
		Cjcg				: array [0..12] of char;    //	/* ����������������												*/
		Kjcg				: array [0..12] of char;    //	/* �ɼǰ�������													*/
		Mdgm				: array [0..12] of char;    //	/* �ɼǸŵ��ݾ�													*/
		Msgm				: array [0..12] of char;    //	/* �ɼǸż��ݾ�													*/
		Cpgm				: array [0..12] of char;    //	/* �ɼ���������													*/
		Susu				: array [0..12] of char;    //	/* �������հ�													*/
		Fsusu				: array [0..12] of char;    //	/* ����������													*/
		Osusu				: array [0..12] of char;    //	/* �ɼǼ�����													*/
		Cyttm				: array [0..12] of char;    //	/* ������Ź�Ѿ�													*/
		Fcsgm				: array [0..12] of char;    //	/* ����û�����													*/
		Ffagm				: array [0..12] of char;    //	/* �����򰡼���													*/
		Ocsgm				: array [0..12] of char;    //	/* �ɼ�û�����													*/
		Ofagm				: array [0..12] of char;    //	/* �ɼ��򰡼���													*/
		Fyttm				: array [0..12] of char;    //	/* �򰡿�Ź�Ѿ�													*/
		Yttm				: array [0..12] of char;    //	/* ��Ź�Ѿ�														*/
		Ythg				: array [0..12] of char;    //	/* ��Ź����														*/
		Ytdy				: array [0..12] of char;    //	/* ��Ź���														*/
		Jmgtm				: array [0..12] of char;    //	/* �ֹ������Ѿ�													*/
		Jmghg				: array [0..12] of char;    //	/* �ֹ���������													*/
		Jmgdy				: array [0..12] of char;    //	/* �ֹ����ɴ��													*/
		Ictm				: array [0..12] of char;    //	/* ���Ⱑ���Ѿ�													*/
		Ichg				: array [0..12] of char;    //	/* ���Ⱑ������													*/
		Icdy				: array [0..12] of char;    //	/* ���Ⱑ�ɴ��													*/
		Ictm_1			: array [0..12] of char;    //	/* ���Ⱑ���Ѿ� D+1												*/
		Ichg_1			: array [0..12] of char;    //	/* ���Ⱑ������ D+1												*/
		Icdy_1			: array [0..12] of char;    //	/* ���Ⱑ�ɴ�� D+1												*/
		Ytjm				: array [0..12] of char;    //	/* ��Ź���ű��Ѿ�												*/
		Ycjm				: array [0..12] of char;    //	/* ��Ź�������ű�												*/
		Ydjm				: array [0..12] of char;    //	/* ��Ź������ű�												*/
		Ytjm_1			: array [0..12] of char;    //	/* ��Ź���ű��Ѿ� D+1											*/
		Ycjm_1			: array [0..12] of char;    //	/* ��Ź���ű����� D+1											*/
		Ydjm_1			: array [0..12] of char;    //	/* ��Ź���űݴ�� D+1											*/
		Cjgtm				: array [0..12] of char;    //	/* �߰����ű��Ѿ�												*/
		Cjghg				: array [0..12] of char;    //	/* �߰����ű����� 												*/
		Cjgdy				: array [0..12] of char;    //	/* �߰����űݴ�� 												*/
		Cjgtm_1			: array [0..12] of char;    //	/* �ֹ������Ѿ�		D+1											*/
		Cjghg_1			: array [0..12] of char;    //	/* �ֹ���������		D+1											*/
		Cjgdy_1			: array [0..12] of char;    //	/* �ֹ����ɴ��		D+1											*/
		Ytjy				: array [0..12] of char;    //	/* �������ű��Ѿ�												*/
		Ycjy				: array [0..12] of char;    //	/* �����������ű�												*/
		Ydjy				: array [0..12] of char;    //	/* ����������ű�												*/
		Ogjgm				: array [0..12] of char;    //	/* �̼����ܾ�													*/
		Syttm				: array [0..12] of char;    //	/* ����ÿ�Ź�Ѿ�												*/
		Ipgm				: array [0..12] of char;    //	/* ��������ݾ�													*/
		Dgjgm				: array [0..12] of char;    //	/* ���ϰ��������ݾ�												*/
		Dyttm				: array [0..12] of char;    //	/* ���Ͽ�Ź�Ѿ�
  end;

  // �ֹ����ɼ���  5130

  PReqAbleQty = ^TReqAbleQty;
  TReqAbleQty = record
    Header      : TCommonHeader;
    Account			: array [0..10] of char;          //	/* ���¹�ȣ														*/
    Pass				: array [0..7] of char;           //	/* ��й�ȣ														*/
    Bysl_tp			: char;                           //	/* �Ÿű���	(1.�ŵ�	2.�ż�)										*/
    FullCode		: array [0..11] of char;          //	/* �����ڵ�														*/
    Gggb				: char;                           //	/* �ֹ���������
                                                  //    1.������ 2.���尡 3.���Ǻ������� 4.������������
                                                  //    5.������(IOC) 6.������(FOK)									*/
	  Jmjs				: array [0..8] of char;           //	/* �ֹ�����
  end;

  POutAbleQty = ^TOutAbleQty;
  TOutAbleQty = record
	  Header      : TCommonHeader;
	  Account			: array	[0..10] of char;    //	/* ���¹�ȣ														*/
		Pass				: array [0..7] of char;     //	/* ��й�ȣ														*/
		Mmgb				: char;                     //	/* �Ÿű��� (1.�ŵ� 2.�ż�)										*/
		FullCode		: array [0..11] of char;    //	/* �����ȣ														*/
		Gggb				: char;                     //	/* ��������	(1.������ 2.���尡 3.���Ǻ������� 4.������������)	*/
		Curr				: array [0..8] of char;     //	/* ���簡��														*/
		Jmjs				: array [0..8] of char;     //	/* �ֹ�����														*/
		Jmgqt1			: array [0..6] of char;     //	/* �ű��ֹ����ɼ���												*/
		Jmgqt2			: array [0..6] of char;     //	/* û���ֹ����ɼ���
  end;

{$ENDREGION}


{$REGION '�ֹ�....'}

  // 5101 �ű�

  PNewOrderPacket = ^TNewOrderPacket;
  TNewOrderPacket = record
	  Header        : TCommonHeader;
	  Account			: array [0..10] of char;    //	/* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;     //	/* ��й�ȣ														*/
		FullCode			: array [0..11] of char;    //	/* �����ڵ�														*/
		Order_Volume	: array	[0..9] of char;     //	/* �ֹ�����														*/
		Order_Boho		: char;                     //	/* ���ݺ�ȣ (+.��� -.����) 									*/
		Order_Price		: array	[0..10] of char;    //	/* �ֹ�����														*/
		BuySell_Type	: char;                     //	/* �Ÿű���	(1.�ŵ� 2:�ż�)										*/
		Price_Type		: char;                     //	/* �������� (1.������ 2.���尡 3.���Ǻ������� 4.������������)	*/
		Trace_Type		: char;                     //	/* ü������ (0.���� 1.IOC 2.FOK)								*/
		Order_Comm_Type: array [0..1] of char;    //	/* ��ű���														*/
		GroupCode			: array [0..5] of char;     //	/* �׷��ڵ�														*/
		IpAddr				: array [0..11] of char;    //	/* GetLocalIpAddress �Լ� ���									*/
		Order_Type		: char;                     //	/* �ֹ����� (1.�Ϲ��ֹ� 2.���Ǵ뷮�ֹ�)							*/
		Hbno				  : array [0..2] of char;     //	/* ���Ǵ뷮�ŷ� ���ȸ����ȣ									*/
		Hbgj				  : array [0..11] of char;    //	/* ���Ǵ뷮�ŷ� �����¹�ȣ									*/
		Hbtm				  : array [0..3] of char;     //	/* ���Ǵ뷮�ŷ� �ð�
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
  end;

  POutNewOrderPacket = ^TOutNewOrderPacket;
  TOutNewOrderPacket = record
    Header        : TCommonHeader;
	  Account				: array [0..10] of char;    //	/* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;     //	/* ��й�ȣ														*/
		OrderNo				: array [0..9] of char;     //	/* �ֹ���ȣ														*/
		FullCode			: array [0..11] of char;    //	/* �����ڵ�														*/
		Order_Volume	: array [0..9] of char;     //	/* �ֹ�����														*/
		Order_Boho		: char;                     //	/* ���ݺ�ȣ	(+.��� -.����) 									*/
		Order_Price		: array [0..10] of char;    //	/* �ֹ�����														*/
		BuySell_Type	: char;                     //	/* �Ÿű��� (1.�ŵ� 2.�ż�)										*/
		Price_Type		: char;                     //	/* �������� (1.������ 2.���尡 3.���Ǻ������� 4.������������)	*/
		Trace_Type		: char;                     //	/* ü������ (0.���� 1.IOC 2.FOK)								*/
		Order_Comm_Type: array [0..1] of char;    //	/* ��ű��� 													*/
		GroupCode			 : array [0..5] of char;    //	/* �׷��ڵ�
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
    // �����϶��� �����....�ʵ�
    ErrorMsg  : array [0..99] of char;
  end;

  // 5102 ����

  PChangeOrderPacket = ^TChangeOrderPacket;
  TChangeOrderPacket = record
    Header        : TCommonHeader;
		Account				: array [0..10] of char;    //	/* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;     //	/* ��й�ȣ														*/
		FullCode			: array [0..11] of char;    //	/* �����ڵ�														*/
		Order_Volume	: array [0..9] of char;     //	/* �ֹ�����														*/
		Order_Boho		: char;                     //	/* �ֹ����ݺ�ȣ	(+.��� -.����)									*/
		Order_Price		: array	[0..10] of char;    // 	/* �ֹ�����														*/
		Price_Type		: char;                     //	/* ��������	(1.������ 2.���尡 3.���Ǻ������� 4.������������)	*/
		Trace_Type		: char;                     //	/* ü������ (0.���� 1.IOC 2.FOK)								*/
		WOrderNo			: array [0..9] of char;     //	/* ���ֹ���ȣ													*/
		Order_Comm_Type: array 		[0..1] of char; //	/* ��ű���														*/
		GroupNo				: array [0..5] of char;     //  /* �׷��ڵ�														*/
		IpAddr				: array [0..11] of char;    //	/* GetLocalIpAddress �Լ� ���									*/
		Order_Type		: char;                     //	/* �ֹ����� (1.�Ϲ��ֹ� 2.���Ǵ뷮�ֹ�)							*/
		Hbno				  : array [0..2] of char;     //	/* ���Ǵ뷮�ŷ� ���ȸ����ȣ									*/
		Hbgj				  : array [0..11] of char;    //	/* ���Ǵ뷮�ŷ� �����¹�ȣ
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
  end;

  POutChangeOrderPacket = ^TOutChangeOrderPacket;
  TOutChangeOrderPacket = record
    Header        : TCommonHeader;
		Account				: array [0..10] of char;    //	/* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;     //	/* ��й�ȣ														*/
		OrderNo				: array [0..9] of char;     //	/* �ֹ���ȣ														*/
		WOrderNo			: array [0..9] of char;     //	/* ���ֹ���ȣ													*/
		FullCode			: array [0..11] of char;    //	/* �����ڵ�														*/
		Order_Volume	: array [0..9] of char;     //	/* �ֹ�����														*/
		Order_Boho		:char;                      //	/* �ֹ����ݺ�ȣ (+.��� -����)									*/
		Order_Price		: array	[0..10] of char;    //	/* �ֹ�����														*/
		Price_Type		:char;                      //	/* �������� (1.������ 2.���尡 3.���Ǻ������� 4.������������)	*/
		Trace_Type		:char;                      //	/* ü������ (0.���� 1.IOC 2.FOK)								*/
		Order_Comm_Type: array [0..1] of char;    //	/* ��ű��� 													*/
		GroupNo				: array [0..5] of char;     //	/* �׷��ڵ�
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
    // �����϶��� �����....�ʵ�
    ErrorMsg  : array [0..99] of char;
  end;

  // ��� 5103
  PCancelOrderPacket = ^TCancelOrderPacket;
  TCancelOrderPacket = record
	  Header        : TCommonHeader;
		Account				: array [0..10] of char;    //	/* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;     //	/* ��й�ȣ														*/
		FullCode			: array [0..11] of char;    //	/* �����ڵ�														*/
		Order_Volume	: array [0..9] of char;     //	/* �ֹ�����														*/
		WOrderNo			: array [0..9] of char;     //	/* ���ֹ���ȣ													*/
		Order_Comm_Type: array[0..1] of char;     //	/* ��ű���														*/
		GroupNo				: array [0..5] of char;     //	/* �׷��ڵ�														*/
		IpAddr				: array [0..11] of char;    //	/* GetLocalIpAddress �Լ� ���									*/
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
  end;

  POutCancelOrderPacket = ^TOutCancelOrderPacket;
  TOutCancelOrderPacket = record
	  Header        : TCommonHeader;
		Account				: array [0..10] of char;    //   /* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;     //	/* ��й�ȣ														*/
		OrderNo				: array [0..9] of char;     //	/* �ֹ���ȣ														*/
		WOrderNo			: array [0..9] of char;     //	/* ���ֹ���ȣ													*/
		FullCode			: array [0..11] of char;    //	/* �����ڵ�														*/
		Order_Volume	: array [0..9] of char;     //	/* �ֹ�����														*/
		Order_Comm_Type: array[0..1] of char;     //	/* ��ű��� 													*/
		GroupNo				: array [0..5] of char;     //	/* �׷��ڵ�
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
    // �����϶��� �����....�ʵ�
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
		trcode				: char;                       //	/* 1:�ֹ�����,2:ü��,3:����Ȯ��	4:���Ȯ��,5:�ֹ��ź�,6:�ڵ����*/
		trgb				  : char;                       //	/*	1:�ű԰ź�,2:�����ź�,3:��Ұź�
											                          //      4:�ű�����,5:��������,6:�������							*/
		spgb				  : char;                       //	/* Y:�Ϲ�, N:��������ü��										*/
		accno				  : array [0..10] of char;      //	/* ���� ��ȣ (����(3)+��ǰ(2)+���¹�ȣ(6))						*/
		jmcd			  	: array [0..11] of char;      //	/* �����ڵ�														*/
		mrkt				  : array [0..1] of char;       //	/* ���屸��
                                                //      �ڽ�������   -> 01 3�ⱹä����  -> 61 ������Ǳݸ� -> 62
                                                //      5�ⱹä����  -> 63 10�ⱹä���� -> 64 �̱��޷�     -> 75
                                                //      ���޷�       -> 76 ���δ޷�     -> 77						*/
		grjn				  : array [0..9] of char;       //	/* �ֹ���ȣ														*/
		wgrjn			    : array [0..9] of char;       //	/* ���ֹ���ȣ													*/
		jmgb				  : char ;                      //	/* �����Ǳ��� (1.�ŵ� 2.�ż�)									*/
		gggb				  : char;                       //	/* �ֹ����� (1:������)											*/
		jmtp				  : char;                       //	/* ü������ (0:�Ϲ�)											*/
		jmjs			  	: array [0..6] of char;       //	/* �ֹ�����														*/
		jmqt				  : array [0..7] of char;       //	/* �ֹ�����(�ֹ�����-(����+���))								*/
		cgjs				  : array [0..8] of char;       //	/* ü��ܰ�														*/
		cgqt				  : array [0..7] of char;       //	/* ü�����														*/
		jspm				  : array [0..7] of char;       //	/* �ֹ�Ȯ��,ü��,�ź� �ð�										*/
		jggb 				  : char;                       //	/* �ܰ�����(1:�ŵ�,2:�ż�,3:�ܰ� ZERO)							*/
		avgpr				  : array [0..7] of char;       //	/* ��մܰ�														*/
		gjqt 				  : array [0..7] of char;       //	/* �ܰ�����														*/
		miqt				  : array [0..7] of char;       //	/* �űԹ�ü���													*/
		bmiqt				  : array [0..7] of char;       //	/* ��ü��� (�ݴ� ��������)										*/
		gbsy				  : array [0..3] of char;       //	/* �źλ����ڵ�													*/
		pro_chk				: char;                       //	/* ü��flag(��������ü���̸�����)								*/
										                            //  /* default ' ' �ƴϸ� '1'										*/
		currprice			: array [0..8] of char;       //	/* ���簡														*/
		near_Jmcd			: array [0..11] of char;      //	/* �ֱٿ��� �����ڵ�(X)											*/
		next_Jmcd			: array [0..11] of char;      //	/* ���ٿ��� �����ڵ�(X)											*/
    User_div      : array [0..2] of char;     //  / IP ���ڸ�
    User_Field		: array [0..6] of char;     //	/* ����� ����													*/
  end;

  PAutoOrderPacket = ^TAutoOrderPacket;
  TAutoOrderPacket = record
    Header        : TCommonHeader;
    Count         : array [0..2] of char;
  end;
{$ENDREGION}


Const
  Len_AccountInfo   = SizeOf( TOutAccountInfo );
  Len_SymbolListInfo = SizeOf( TOutSymbolListInfo );
  Len_OutSymbolMaster = sizeof( TOutSymbolMaster );
  Len_OutSymbolMarkePrice  = sizeof(TOutSymbolMarkePrice);


  Len_ReqChartData = sizeof( TReqChartData );
  Len_OutChartData = sizeof( TOutChartData );
  Len_OutChartDataSub = sizeof( TOutChartDataSub );
  // ����
  // �ֹ�����Ʈ ��û
  Len_ReqAccountFill = sizeof( TReqAccountFill );
  Len_OutAccountFillSub = sizeof( TOutAccountFillSub );
  Len_OutAccountFill  = sizeof( TOutAccountFill );
  // �ܰ�
  Len_ReqAccountPos = sizeof( TReqAccountPos );
  Len_OutAccountPos = sizeof( TOutAccountPOs );
  Len_OutAccountPosSub = sizeof( TOutAccountPosSub );
  // ������
  Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  Len_OutAccountDepositSub = sizeof( TOutAccountDepositSub );
  Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
  // ���곻��
  Len_OutAccountAdjustMent = sizeof( TOutAccountAdjustMent );
  // ���ɼ���
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  // �ǽð� ��û
  Len_SendAutoKey = sizeof( TSendAutoKey );
      // ü��
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );
  Len_AutoSymbolTick = sizeof( TAutoSymbolTick );
  Len_AutoSymbolTickSub = sizeof( TAutoSymbolTickSub );

  // �ֹ�
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