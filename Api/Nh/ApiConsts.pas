unit ApiConsts;

interface

const
      {
     use kr
  BM3 = 'BM3';
  BM5 = 'BM5';
  BMA = 'BMA';
  USD = 'USD';
  K2I = 'K2I';
  MKI = 'MKI';
  JPY = 'JPY';
  KSD = 'KSD';
    }


  // nh ��ǰ ī�װ��� �ڵ� 
  BM3 = 'NKTB';
  BM5 = 'N5TB';
  BMA = '10KTB';
  USD = 'USD';
  K2I = 'KOSPI';
  MKI = 'MKOSPI';
  JPY = 'JPY';
  KSD = 'KOSDAQ';
  KX3 = 'KRX300';

  VI_KOSPI = '01';
  VI_MINI_KOSPI = '05';
  VI_KOSDAQ = '06';
  VI_WEEKLY = '09';
  VI_BOND_10YR = '67';
  VI_USD = '75';

  Kospi200F = '101F';
  Kospi200O = '101O';
  Kospi200WO = '109O';
  MiniKospiF = '105F';
  MiniKospiO = '105O';
  Kosdaq150F = '106F';
  Kosdaq150O = '106O';
  Bond10F = '167F';
  DollarF = '175F';

  Vi_Market_Cnt = 3;
  Vi_MarketSymbol  : array [0..Vi_Market_Cnt-1] of string = (
      Kospi200F,
      //Kospi200O,
      //Kospi200WO,
      //MiniKospiF ,
      //MiniKospiO ,
      //Kosdaq150F,
      //Kosdaq150O,
      Bond10F,
      DollarF
  );



  Acnt_No_Len = 11;
  Acnt_Name_Len = 30;
  Acnt_Gubun_Len = 1;


  // ��ȸ
  Qry_Cnt =  9;
  Qry_AbleOrdCnt  = 'ATQ39105';     // �ֹ����ɼ���
  Qry_OrdList     = 'ATQ39120';     //  �ֹ�ü�᳻��
  Qry_OrdDetList  = 'ATQ39130';     // �ֹ�ü�� ��
  Qry_OrdReject   = 'ATQ39133';     // �ֹ��ź�
  Qry_AcntPos     = 'ATQ39701';     // ���º� �ܰ�
  Qry_AcntState   = 'ATQ39706';     // ��Ź���� �Ѱ��ܰ�

  Qry_LastPrice   = 'FZQ12010';     // �������簡 �ü�
  Qry_LastHoga    = 'FZQ12011';     // ���� ȣ�� ��ȸ

  Qry_SymbolInfo2 = 'AHQ18010';     // ��,������ �ð����� ��

  Qry_TrCode  : array [0..Qry_Cnt-1] of string = (
      Qry_AbleOrdCnt ,
      Qry_OrdList,
      Qry_OrdDetList,
      Qry_OrdReject ,
      Qry_AcntPos ,
      Qry_AcntState,
      Qry_LastPrice,
      Qry_LastHoga,
      Qry_SymbolInfo2
  );

  Rsp_NewOrder = 'BTO31101';
  Rsp_ModOrder = 'BTO31102';
  Rsp_CnlOrder = 'BTO31103';

  // �ǽð�
  Real_FutHoga = 'SB_FUT_HOGA';
  Real_FutExec = 'SB_FUT_EXEC';
  //Real_FutOpen = 'SB_FUT_NONSETTL';

  Real_OptHoga = 'SB_OPT_HOGA';
  Real_OptExec = 'SB_OPT_EXEC';
  //Real_OptOpen = 'SB_OPT_NONSETTL';

  Real_Stock_FutHoga = 'SB_STOCK_FUT_HOGA';
  Real_Stock_FutExec = Real_FutExec;

  Real_PrcLimit = 'SB_FO_LIMIT';
  Real_Order    = 'SB_ORDER_EXEC';

  Real_FutInvest = 'SB_KP_FUT_INVEST_TIME';
  Real_OptInvest = 'SB_KP_OPT_INVEST_TIME';


  Vi_Qry_Cnt = 9;

  DefAccountList = 'g11004.AQ0101%';   // 0
  DefAcceptedHistory = 'g11002.DQ0104&'; // 1
  DefFilledHistory = 'g11002.DQ0107&';  // 2
  DefOutstandingHistory = 'g11002.DQ0110&'; // 3
  DefOutstanding = 'g11002.DQ1305&';         // 4
  DefCmeAcceptedHistory = 'g11002.DQ0116&';  // 5
  DefCmeFilledHistory = 'g11002.DQ0119&';   // 6
  DefCmeOutstandingHistory = 'g11002.DQ0122&'; // 7
  DefCmeOutstanding = 'g11002.DQ1306&';   // 8
  DefCmeAsset = 'g11002.DQ0125&';        // 9
  DefCmePureAsset = 'g11002.DQ1303&';    // 10
  DefAsset = 'g11002.DQ0217&';            // 11
  DefDeposit = 'g11002.DQ0242&';          // 12
  DefDailyProfitLoss = 'g11002.DQ0502&';  // 13
  DefFilledHistoryTable = 'g11002.DQ0509&'; // 14
  DefAccountProfitLoss = 'g11002.DQ0521&';  // 15
  DefSymbolCode = 'g11002.DQ0622&';           // 16
  DefTradableCodeTable = 'g11002.DQ1211&';      // 17
  DefApiCustomerProfitLoss = 'g11002.DQ1302&';  // 18
  DefChartData = 'v90003';                      // 19
  DefCurrentQuote = 'l41600';                   // 20
  DefDailyQuote = 'l41601';                     // 21
  DefTickQuote = 'l41602';                       //22
  DefSecondQutoe = 'l41603';                     // 24
  DefSymbolMaster = 's20001';                     // 25
  DefStockFutureSymbolMaster = 's31001';           // 26
  DefIndustryMaster = 's10001';                    // 27
  DefServerTime = 'o44011';                        // 28

  Vi_Qry_TrCode  : array [0..Vi_Qry_Cnt-1] of string = (
      DefSymbolCode ,
      DefSymbolMaster,
      DefAsset,
      DefDeposit ,
      DefOutstanding ,
      DefApiCustomerProfitLoss,
      DefAccountList,
      DefAcceptedHistory,
      DefFilledHistory

  );
type

  // ��� ���� Ÿ�� - ������
  TResultType = ( rtNone, rtAutokey, rtUserID, rtUserPass, rtCertPass, rtSvrSendData,
    rtSvrConnect, rtSvrNoConnect, rtCerTest, rtDllNoExist, rtTrCode );

  // Api ���� Ÿ�� ������
  TApiRealType = ( atFutHoga, atFutExec, atOptHoga, atOptExec, atOrder, atFutInvest, atOptInvest, atStockFutHoga, atStockFutExec );

  // Vi Api Request Type
  TApiReqType = (rtTr, rtFid);

implementation



end.