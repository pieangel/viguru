unit UUdpPacketPv0;

interface

type
  //선물 호가,체결 패킷 --------------------------------------------------------
  TFQtyItem = packed record
    SellSign: Char;                //Sell Sign부호
    Sell:     array[0..4] of Char; //9(3).99
    BuySign:  Char;                //Buy Sign부호
    Buy:      array[0..4] of Char; //9(3).99
    SellQty:  array[0..5] of Char; //매도호가 수량
    BuyQty:   array[0..5] of Char; //매수호가 수량
  end;

  TFCntItem = packed record
    Cnt1:   array[0..3] of Char; //매도/매수 1호가건수
    Cnt2:   array[0..3] of Char; //매도/매수 2호가건수
    Cnt3:   array[0..3] of Char; //매도/매수 3호가건수
    Cnt4:   array[0..3] of Char; //매도/매수 4호가건수
    Cnt5:   array[0..3] of Char; //매도/매수 5호가건수
    TotCnt: array[0..4] of Char; //매도/매수 총호가건수
  end;

  //선물 호가 - 'F1' + 일련번호(6) + 'H0'
  PFutureCall = ^TFutureCall;
  TFutureCall = packed record
    {
    Gubun:      array[0..1] of Char;        //시세-'F1'
    SeqNo:      array[0..5] of Char;        //전송일련번호
    //Data구분 - 접속호가 : "H0"  체결 : "C0"   기세 : "G0"  장운용 : "J0"  미결제 : "M0"  매매증거금 기준가 : "I0"  SPACE : "S0"  종료 : "SE"
    DataGu:     array[0..1] of Char;        //호가구분 - 'H0'
    }
    Code:        array[0..7] of Char;      //종목코드
    CodeSeq:     array[0..1] of Char;      //종목SEQ, 번호 (01,02,03,04)
    Qty1Item:    TFQtyItem;                //매도매수 최우선호가
    AcptTime:    array[0..7] of Char;      //호가접수시간
    Qty2To3Item: array[0..1] of TFQtyItem; //매도/매수 2~3호가
    SellQty:     array[0..5] of Char;      //매도 총호가 수량
    BuyQty:      array[0..5] of Char;      //매수 총호가 수량
    FQty4To5Item: array[0..1] of TFQtyItem; //매도/매수 4~5호가
    CntItem:     array[0..1] of TFCntItem; //매도/매수 1~5호가건수
    EndOfText:   Char;                     //END OF TEXT (%HFF)
  end;

  //선물 체결 - 'F1' + 일련번호(6) + 'C0'
  PFutureTick = ^TFutureTick;
  TFutureTick = packed record
    {
    Gubun:      array[0..1] of Char;        //시세-'F1'
    SeqNo:      array[0..5] of Char;        //전송일련번호
    //Data구분 - 접속호가 : "H0"  체결 : "C0"   기세 : "G0"  장운용 : "J0"  미결제 : "M0"  매매증거금 기준가 : "I0"  SPACE : "S0"  종료 : "SE"
    DataGu:     array[0..1] of Char;        //체결구분 - 'C0'
    }
    Code:           array[0..7] of Char;      //종목코드
    CodeSeq:        array[0..1] of Char;      //종목SEQ, 번호 (01,02,03,04)
    FillTime:       array[0..7] of Char;      //체결시간
    CurSign:        Char;                     //현재가 Sign부호
    Current:        array[0..4] of Char;      //9(3).99
    NearPrice:      array[0..4] of Char;      //최근월물 의제약정가격 - 9(3).99
    LongPrice:      array[0..4] of Char;      //원월물 의제약정가격 - 9(3).99
    OpenSign:       Char;                     //시가 Sign부호
    Open:           array[0..4] of Char;      //9(3).99
    HighSign:       Char;                     //고가 Sign부호
    High:           array[0..4] of Char;      //9(3).99
    LowSign:        Char;                     //저가 Sign부호
    Low:            array[0..4] of Char;      //9(3).99
    TotalQty:       array[0..6] of Char;      //누적체결수량
    TotalPrice:     array[0..10] of Char;     //누적거래대금 (※ 단위 : 천원)
    NearTotalQty:   array[0..6] of Char;      //근월물체결수량
    NearTotalPrice: array[0..10] of Char;     //근월물거래대금 (※ 단위 : 천원)
    LongTotalQty:   array[0..6] of Char;      //원월물체결수량
    LongTotalPrice: array[0..10] of Char;     //원월물거래대금 (※ 단위 : 천원)
    MarginSign:     Char;                     //전일대비 부호
    Margin:         array[0..4] of Char;      //9(3).99
    FillQty:        array[0..5] of Char;      //건별 체결수량
    FQty1To3Item:    array[0..2] of TFQtyItem; //매도/매수 1~3호가
    SellQty:        array[0..5] of Char;      //매도 총호가 수량
    BuyQty:         array[0..5] of Char;      //매수 총호가 수량
    FQty4To5Item:    array[0..1] of TFQtyItem; //매도/매수 4~5호가
    CntItem:        array[0..1] of TFCntItem; //매도/매수 1~5호가건수
    EndOfText:      Char;                     //END OF TEXT (%HFF)
  end;

  //옵션 호가,체결 패킷 --------------------------------------------------------
  TOQtyItem = packed record
    Sell:    array[0..4] of Char; //9(3).99
    Buy:     array[0..4] of Char; //9(3).99
    SellQty: array[0..6] of Char; //매도호가 수량     // by Nsh(20060807) => 옵션 호가잔량(6=>7자리로 변경)
    BuyQty:  array[0..6] of Char; //매수호가 수량     // by Nsh(20060807) => 옵션 호가잔량(6=>7자리로 변경)
  end;

  TOCntItem = packed record
    Cnt1:   array[0..3] of Char; //매도/매수 1호가건수
    Cnt2:   array[0..3] of Char; //매도/매수 2호가건수
    Cnt3:   array[0..3] of Char; //매도/매수 3호가건수
    Cnt4:   array[0..3] of Char; //매도/매수 4호가건수
    Cnt5:   array[0..3] of Char; //매도/매수 5호가건수
    TotCnt: array[0..4] of Char; //매도/매수 총호가건수
  end;

  //옵션 호가 - 'O1' + 일련번호(7) + 'H0'
  POptionCall = ^TOptionCall;
  TOptionCall = packed record
    {
    Gubun:      array[0..1] of Char;        //시세-'01'
    SeqNo:      array[0..6] of Char;        //전송일련번호
    //Data구분 -  호가   : "H0"   체결   : "C0"  기세   : "G0"  장운용 : "J0"  미결제 : "M0"  매매증거금 기준가 : "I0"  SPACE : "S0", 종료 : "OE"
    DataGu:     array[0..1] of Char;        //호가구분 - 'H0'
    }
    Code:        array[0..7] of Char;      //종목코드
    CodeSeq:     array[0..2] of Char;      //종목SEQ, 번호
    OQty1To3Item: array[0..2] of TOQtyItem; //매도/매수 1~3호가수량
    SellQty:     array[0..6] of Char;      //매도 총호가 수량      // by Nsh(20060807) => 옵션 호가잔량(6=>7자리로 변경)
    BuyQty:      array[0..6] of Char;      //매수 총호가 수량      // by Nsh(20060807) => 옵션 호가잔량(6=>7자리로 변경)
    AcptTime:    array[0..7] of Char;      //호가접수시간 - '00000000'
    OQty4To5Item: array[0..1] of TOQtyItem; //매도/매수 4~5호가수량
    CntItem:     array[0..1] of TOCntItem; //매도/매수 1~5호가건수
    EndOfText:   Char;                     //END OF TEXT (%HFF)
  end;

  //옵션 체결 - 'O1' + 일련번호(7) + 'C0'
  POptionTick = ^TOptionTick;
  TOptionTick = packed record
    {
    Gubun:      array[0..1] of Char;        //시세-'01'
    SeqNo:      array[0..6] of Char;        //전송일련번호
    //Data구분 -  호가   : "H0"   체결   : "C0"  기세   : "G0"  장운용 : "J0"  미결제 : "M0"  매매증거금 기준가 : "I0"  SPACE : "S0", 종료 : "OE"
    DataGu:     array[0..1] of Char;        //체결구분 - 'C0'
    }
    Code:        array[0..7] of Char;      //종목코드
    CodeSeq:     array[0..2] of Char;      //종목SEQ, 번호
    FillQty:     array[0..5] of Char;      //체결수량
    FillTime:    array[0..7] of Char;      //체결시간
    OQty1To3Item: array[0..2] of TOQtyItem; //매도/매수 1~3호가수량
    SellQty:     array[0..6] of Char;      //매도 총호가 수량       // by Nsh(20060807) => 옵션 호가잔량(6=>7자리로 변경)
    BuyQty:      array[0..6] of Char;      //매수 총호가 수량       // by Nsh(20060807) => 옵션 호가잔량(6=>7자리로 변경)
    Current:     array[0..4] of Char;      //현재가-9(3).99
    Open:        array[0..4] of Char;      //시가-9(3).99
    High:        array[0..4] of Char;      //고가-9(3).99
    Low:         array[0..4] of Char;      //저가-9(3).99
    TotalQty:    array[0..7] of Char;      //누적체결수량
    TotalPrice:  array[0..10] of Char;     //누적거래대금 (※ 단위 : 천원)
    OQty4To5Item: array[0..1] of TOQtyItem; //매도/매수 4~5호가수량
    CntItem:     array[0..1] of TOCntItem; //매도/매수 1~5호가건수
    EndOfText:   Char;                     //END OF TEXT (%HFF)
  end;

  //유가증권시장 호가,체결 패킷 ------------------------------------------------
  TSCallItem = packed record
    Sell:    array[0..8] of Char; //매도호가
    Buy:     array[0..8] of Char; //매수호가
    SellQty: array[0..9] of Char; //매도호가 잔량
    BuyQty:  array[0..9] of Char; //매수호가 잔량
  end;

  //유가증권시장 호가-'H1'
  PStockCall = ^TStockCall;
  TStockCall = packed record
    //DataGu: array[0..1] of Char; //Data구분-'H1'
    Code:         array[0..11] of Char;      //종목코드-표준코드
    TotalQty:     array[0..9] of Char;       //장구분 관계없이 모든 거래량을 합산(장개시전 포함)
    CallItem:     array[0..9] of TSCallItem; //호가 10단계:10*38=380
    SellTotalQty: array[0..9] of Char;
    BuyTotalQty:  array[0..9] of Char;
    PlaceGu:      Char;                      //장구분 - 0: 장중, 1: 장종료후시간외
    SameGu:       Char;                      //동시구분 - 0: 접속, 1: 동시, 2: 동시연장
    AnFillPrice:  array[0..8] of Char;       //예상체결가격(AnticipationFillPrice)
    AnFillQty:    array[0..9] of Char;       //예상체결수량(AnticipationFillQty)
    OverPlaceGu:  Char;                      //시간외단일가장구분(TimeOverUniPricePlaceGu) - 0:초기값 1:시간외단일가개시 2:시간외단일가마감
    EndOfText:    Char;                      //END OF TEXT (%HFF)
  end;
    
  //유가증권시장 체결-'S3'
  PStockTick = ^TStockTick;
  TStockTick = packed record
    //DataGu: array[0..1] of Char; //Data구분-'S3'
    Code:       array[0..11] of Char; //종목코드-표준코드
    Signal:     Char;                 //전일대비(기준가대비)구분 - 0:판단불가 1:상한 2:상승 3:보합 4:하한 5:하락
    Margin:     array[0..8] of Char;  //전일대비(기준가대비) ※ 신주인수권 증서/증권의 신규 상장 당일 : 0
    Current:    array[0..8] of Char;  //현재가
    Open:       array[0..8] of Char;  //시가
    High:       array[0..8] of Char;  //고가
    Low:        array[0..8] of Char;  //저가
    TotalQty:   array[0..9] of Char;  //누적거래량(총거래량) 단위:1주 ※매매구분별로 각각 누적됨
    TotalPrice: array[0..14] of Char; //누적거래대금(총거래대금) 단위:1원 ※매매구분별로 각각 누적됨
    {
    //매매구분
    01:보통 03:신고대량 05:장종료후시간외종가
    06:장종료후시간외대량 07:장종료후시간외바스켓
    08:장개시전시간외종가 09:장개시전시간외대량
    10:장개시전시간외바스켓
    11:장중대량 12:장중바스켓
    13:시간외단일가매매
    }
    SaleType:   array[0..1] of Char;
    PlaceGu:    Char;                 //장구분 - 0: 장중, 1: 장종료후시간외
    FillPrice:  array[0..8] of Char;  //체결가
    EndOfText:  Char;                 //END OF TEXT (%HFF)
  end;

  //유가증권시장 지수 ----------------------------------------------------------
  PStockIndex = ^TStockIndex;
  TStockIndex = packed record
    //DataGu: array[0..1] of Char; //Data구분-KOSPI200 : 'I2'
    Code:      array[0..1] of Char; //업종코드-01~06 -> '1201'~'1206'(종목코드로 변경시)
    Time:      array[0..5] of Char; //시간-장중:HHMMSS(시간:분:초), 장종료:JUNJJJ
    Index:     array[0..7] of Char; //지수-9(6).99
    Sign:      Char;                //부호-"+":상승 "-":하락 " ":보합
    Margin:    array[0..7] of Char; //대비-9(6).99
    Qty:       array[0..7] of Char; //거래량-단위:천주
    Price:     array[0..7] of Char; //거래대금-단위:백만원
    EndOfText: Char;                //END OF TEXT (%HFF)
  end;

const
  FHogaLenght = sizeof( TFutureCall );
  FFillLength = sizeof( TFutureTick );
  CHogaLenght = sizeof( TOptionCall );
  CFillLenght = sizeof( TOptionTick );


  FUT_CO_RANGE = 66;
  FUT_CO : array [0..FUT_CO_RANGE-1] of integer = (8,2,8,1,5,5,5,1,5,1,5,1,5,7,
          11,7,11,7,11,1,5,6,1,5,1,5,6,6,1,5,1,5,6,6,1,5,1,5,6,6,6,6,1,5,1,5,6,
          6,1,5,1,5,6,6,4,4,4,4,4,5,4,4,4,4,4,5);

  FUT_HO_RANGE = 47;
  FUT_HO : array [0..FUT_HO_RANGE-1] of integer = ( 8,2,1,5,1,5,6,6,8,1,5,1,5,6,
            6,1,5,1,5,6,6,6,6,1,5,1,5,6,6,1,5,1,5,6,6,4,4,4,4,4,5,4,4,4,4,4,5);

  STOCK_FUT_HO_RANGE = 87;
  STOCK_FUT_HO : array [0..STOCK_FUT_HO_RANGE-1] of integer = (8,4,8,1,7,1,7,6,
              6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,
              1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,4,4,4,4,4,4,4,4,4,4,4,
              4,4,4,4,4,4,4,4,4,7,7,5,5);

  STOCK_FUT_CO_RANGE = 106;
  STOCK_FUT_CO : array [0..STOCK_FUT_CO_RANGE-1] of integer = ( 8,4,8,1,7,7,7,1,
              7,1,7,1,7,7,15,7,15,7,15,1,7,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,
              6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,7,1,7,6,6,1,
              7,1,7,6,6,1,7,1,7,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7,7,5,5);

  STOCK_ORD_RANGE = 33;
  STOCK_ORD : array [0..STOCK_ORD_RANGE-1] of integer = (
    8,3,3,12,3,   3,5,5,12,8,
    9,2,2,2, 2,   4,3,2,6,3,
    2,8,2,2,2,    2,12,5,5,5,
    2,2,2);

  STOCK_CONFIRM_RANGE = 20;
  STOCK_CONFIRM : array [0..STOCK_CONFIRM_RANGE-1] of integer= (
    8,3,3,12,3,   3,3,5,5,12,
    6,8,9,8,9,    5,15,1,2,8);

implementation

end.
