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

 ESID_5101	 =			5101;	// 신규주문
 ESID_5102	 =			5102;	// 정정주문
 ESID_5103	 =			5103;	// 취소주문
 ESID_5111	 =			5111;	// 실체결
 ESID_5112	 =			5112;	// 실잔고
 ESID_5122	 =			5122;	// 예탁자산및 증거금
 ESID_5130	 =			5130;	// 신규/청산 주문가능수량조회
 ESID_5124	 =			5124;	// 일일정산내역

// 시세 관련 (선물 / 옵션)

 ESID_2003	=			2003;	// 선물/옵션 종목 시세
 ESID_2004	=			2004;	// 선물/옵션 종목 호가
 ESID_2007	=			2007;	// 선물/옵션 마스타
 ESID_2022	=			2022;	// 선물/옵션 종목 체결내역
 ESID_1701	=			1701;	// 투자자별 시간별 추이
 ESID_1710	=			1710;	// 투자자별매매 종합현황

 ESID_1041	=			1041;	// 차트 데이타

// 시세 관련 (CME 선물 / 옵션)

 ESID_3003	 = 		3003;	// 선물/옵션 종목 시세
 ESID_3004	 = 		3004;	// 선물/옵션 종목 호가
 ESID_3007	 = 		3007;	// 선물/옵션 마스타
 ESID_3022	 = 		3022;	// 선물/옵션 종목 체결내역

// 자동업데이트
 AUTO_0921	 =		 921;	// 자동 Update : 선물/옵션 종목 현재가
 AUTO_0932	 =		 932;	// 자동 Update : 선물/옵션 TICK
 AUTO_0923	 =		 923;	// 자동 Update : 선물/옵션 종목호가
 AUTO_0988	 =		 988;	// 자동 Update : 주문/체결

// 투자자 정보
 AUTO_0908	 = 		 908;	// 투자주체별매매현황(KOSPI선물, KOFEX추가)
 AUTO_0909	 = 		 909;	// 투자주체별매매현황(KOSPI옵션, KOFEX추가)
// 908, 909 자동업데이트시 키값들 (K2I.KOSPI, MKI.MKOSPI, BM3.KTB, USD.USD BM5.5TB, BMA.LKTB, JPY.JPY, EUR.EUR)
type

  TResultType = ( rtNone, rtAutokey, rtUserID, rtUserPass, rtCertPass, rtSvrSendData,
    rtSvrConnect, rtSvrNoConnect, rtCerTest, rtDllNoExist, rtTrCode );

implementation



end.
