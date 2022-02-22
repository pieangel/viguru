unit ApiConsts;

interface

const

  BM3 = 'BM3';
  BM5 = 'BM5';
  BMA = 'BMA';
  USD = 'USD';
  K2I = 'K2I';
  MKI = 'MKI';
  JPY = 'JPY';

  COM = 'COM';

  REQ_FUT_ORDER = 1;   		//�����ֹ�
  REQ_FUT_JANGO = 2;   		//�����ܰ�
  REQ_FUT_JANGO2 = 3;   	//�����ܰ�2
  REQ_FUT_CHE = 4 ;   		//����ü�Ḯ��Ʈ
  REQ_FUT_EVAL = 5 ;   		//���� ����Ȳ
  REQ_FUT_FEE = 6 ;   		//������
  REQ_FUT_DEP_OPT = 7;   	//�ɼ����񺰸ŵ����ű�
  REQ_FUT_ORDER_QTY = 8;  //���� �ű�/û�갡�ɼ��� ��

  ID_ADVICE_RT   = -73;          //    '�ǽð� ����Ÿ ���
  ID_UNADVICE_RT = -74;          //    '�ǽð� ����Ÿ �������

//'�ǽð� ������ ��û ID

  R_SC0 = 'SC0';          //           '���� ���簡
  R_SH0 = 'SH0';          //           '���� ȣ��(5ȣ��)
  R_SH2 = 'SH2';          //           '���� ȣ��
  R_OC0 = 'OC0';          //           '�ɼ� ���簡
  R_OH0 = 'OH0';          //           '�ɼ� ȣ��(5ȣ��)
  R_OH2 = 'OH2';          //           '�ɼ� ȣ��

  R_XF2 = 'XF2';          //           '����ü��
  R_XF3 = 'XF3';          //           '�����ܰ�

 ESID_5101	 =			5101;	// �ű��ֹ�
 ESID_5102	 =			5102;	// �����ֹ�
 ESID_5103	 =			5103;	// ����ֹ�
 ESID_5111	 =			5111;	// ��ü��
 ESID_5112	 =			5112;	// ���ܰ�
 ESID_5122	 =			5122;	// ��Ź�ڻ�� ���ű�
 ESID_5130	 =			5130;	// �ű�/û�� �ֹ����ɼ�����ȸ
 ESID_5124	 =			5124;	// �������곻��

// �ü� ���� (���� / �ɼ�)

 ESID_2003	=			2003;	// ����/�ɼ� ���� �ü�
 ESID_2004	=			2004;	// ����/�ɼ� ���� ȣ��
 ESID_2007	=			2007;	// ����/�ɼ� ����Ÿ
 ESID_2022	=			2022;	// ����/�ɼ� ���� ü�᳻��
 ESID_1701	=			1701;	// �����ں� �ð��� ����
 ESID_1710	=			1710;	// �����ں��Ÿ� ������Ȳ

 ESID_1041	=			1041;	// ��Ʈ ����Ÿ

// �ü� ���� (CME ���� / �ɼ�)

 ESID_3003	 = 		3003;	// ����/�ɼ� ���� �ü�
 ESID_3004	 = 		3004;	// ����/�ɼ� ���� ȣ��
 ESID_3007	 = 		3007;	// ����/�ɼ� ����Ÿ
 ESID_3022	 = 		3022;	// ����/�ɼ� ���� ü�᳻��

// �ڵ�������Ʈ
 AUTO_0921	 =		 921;	// �ڵ� Update : ����/�ɼ� ���� ���簡
 AUTO_0932	 =		 932;	// �ڵ� Update : ����/�ɼ� TICK
 AUTO_0923	 =		 923;	// �ڵ� Update : ����/�ɼ� ����ȣ��
 AUTO_0988	 =		 988;	// �ڵ� Update : �ֹ�/ü��

// ������ ����
 AUTO_0908	 = 		 908;	// ������ü���Ÿ���Ȳ(KOSPI����, KOFEX�߰�)
 AUTO_0909	 = 		 909;	// ������ü���Ÿ���Ȳ(KOSPI�ɼ�, KOFEX�߰�)
// 908, 909 �ڵ�������Ʈ�� Ű���� (K2I.KOSPI, MKI.MKOSPI, BM3.KTB, USD.USD BM5.5TB, BMA.LKTB, JPY.JPY, EUR.EUR)
type

  TResultType = ( rtNone, rtAutokey, rtUserID, rtUserPass, rtCertPass, rtSvrSendData,
    rtSvrConnect, rtSvrNoConnect, rtCerTest, rtDllNoExist, rtTrCode );

implementation



end.
