unit BearConfig ;

interface

uses
  CleAccounts, CleSymbols;

type

  // 전체
  TBearSystemConfig = record
    // -- 계좌, 종목
    Account : TAccount ;        // 계좌
    CohesionSymbol : TSymbol ;  // 응집종목
    OrderSymbol : TSymbol ;     // 주문종목

    // -- 주문 종목
    OrderCollectionPeriod : Double ;  // 수집시간
    OrderQuoteLevel : Integer ;       // 호가레벨
    OrderFilter : Integer ;           //  수량필터
    
    OrderQuoteTimeUsed : Boolean ;  // 주문 가격정하는 방법
    OrderQuoteTime : Double ;       // 주문 호가 사용시간

    QuoteJamSkipUsed : Boolean ;    // 딜레이 자동 Skip 사용여부
    QuoteJamSkipTime : Double ;     // 자동 Skip되는 딜레이 시간

    // -- 파일 저장
    SaveOrdered : Boolean ;     // 응집 종목 원천 데이터 저장
    SaveCohesioned : Boolean ; // 응집 종목 응집 데이터 저장
    SaveCollectioned : Boolean ; // 주문 종목 데이터 저장
  end;

  // 설정창 마다 한개씩 
  TBearConfig = record

    // -- 주문 정보 
    LongOrdered : Boolean ;   // 매수주문?
    ShortOrdered : Boolean ;  // 매도주문?
    CancelOrdered : Boolean;  // 자동취소?
    CancelTime : Double ;     // 취소시간
    OrderQty : Integer ;      // 주문수량
    MaxPosition : Integer ;   // 주문한도 ( 포지션 )
    MaxQuoteQty : Integer ;   // 최대호가잔량 

    // -- 응집 종목
    CohesionFilter : Integer ;      // 수량필터
    CohesionPeriod : Double ;       // 연속시간
    CohesionTotQty : Integer ;      // 총수량
    CohesionCnt : Integer ;         // 건수
    CohesionQuoteLevel : Integer ;  // 호가 레벨
    CohesionAvgPrice  : Double ;    // 가격차 ( 평균단가 )

  end;
  
implementation

end.
