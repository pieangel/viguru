unit ViConsts;

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

  // 상품 카테고리 코드 
  BM3 = 'NKTB';
  BM5 = 'N5TB';
  BMA = '10KTB';
  USD = 'USD';
  K2I = 'KOSPI';
  MKI = 'MKOSPI';
  JPY = 'JPY';
  KSD = 'KOSDAQ';
  KX3 = 'KRX300';

  // 조회
  Qry_Cnt =  9;
  Qry_AbleOrdCnt  = 'ATQ39105';     // 주문가능수량
  Qry_OrdList     = 'ATQ39120';     //  주문체결내역
  Qry_OrdDetList  = 'ATQ39130';     // 주문체결 상세
  Qry_OrdReject   = 'ATQ39133';     // 주문거부
  Qry_AcntPos     = 'ATQ39701';     // 계좌별 잔고
  Qry_AcntState   = 'ATQ39706';     // 위탁계좌 총괄잔고

  Qry_LastPrice   = 'FZQ12010';     // 공통현재가 시세
  Qry_LastHoga    = 'FZQ12011';     // 공통 호가 조회

  Qry_SymbolInfo2 = 'AHQ18010';     // 전,전전일 시고저종 조

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

  // 실시간
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

implementation

end.
