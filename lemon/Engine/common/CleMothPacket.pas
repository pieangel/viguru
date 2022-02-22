unit CleMothPacket;

interface

const
  ARB_DATA = 'ARBD';
  ARB_SEQ = 'ARBS';


type
  PHeadData  = ^THeadData;
  THeadData = packed record
    Size          : array [0..3] of char;     //TotalSize
    TrCode        : array [0..3] of char;     //TrCode
  end;

  // Bull Set(BULL)
  PBullData  = ^TBullData;
  TBullData = packed record
    HeadData      : THeadData;
    StartStop     : char;                     //0 : start, 1 : Stop, 2 : Close
    ScreenNum     : char;                     //개별화면 property Tag값
    AccountCode   : array[0..2] of char;      //계좌번호 000999000XXX -> XXX
    MarketType    : char;                     //선물 : F, 옵션 : O
    SymbolSeq     : array[0..2] of char;
    L             : char;                     //0: 체크박스 X  , 1: 체크박스 O
    S             : char;                     //0: 체크박스 X  , 1: 체크박스 O
    TimeCx        : char;                     //0: 체크박스 X  , 1: 체크박스 O
    TimeCx_Value  : array[0..4] of char;      //99999->9999.9
    E1            : char;                     //0: 체크박스 X  , 1: 체크박스 O
    E1_Value1     : array[0..3] of char;      //9999 -> 999.9
    E1_Value2     : array[0..3] of char;      //9999 -> 999.9
    E1_Value3     : array[0..3] of char;      //9999 -> 999.9
    E1_Value4     : array[0..3] of char;      //9999 -> 999.9      w
    E1_Value5     : array[0..3] of char;      //9999 -> 999.9
    E1_Value6     : array[0..3] of char;      //9999 -> 999.9
    E2            : char;                     //0: 체크박스 X  , 1: 체크박스 O
    E2_Value1     : array[0..4] of char;
    NewOrder      : array[0..5] of char;
    MaxPostion    : array[0..5] of char;
    MaxQuoteQty   : array[0..5] of char;
    X1            : char;                     //0: 체크박스 X  , 1: 체크박스 O
    X1_Value1     : array[0..3] of char;      //9999 -> 999.9
    X1_Value2     : array[0..3] of char;      //9999 -> 999.9
    X2            : char;                     //0: 체크박스 X  , 1: 체크박스 O
    X2_Value1     : array[0..3] of char;      //9999 -> 999.9
    X2_Value2     : array[0..3] of char;      //9999 -> 999.9
    X3            : char;                     //0: 체크박스 X  , 1: 체크박스 O
    Buttons       : char;                     //0 : C1, 1 : C2, 2 : C3, 3 : C4, 4 : C5, 5 : C6, 6 : C7, 7 : C8
  end;

  // Simple catch
  PSimpleCatch = ^TSimpleCatch;
  TSimpleCatch = packed record
    HeadData      : THeadData;
    StartStop     : char;                     //0 : Stop, 1 : Start
    ScreenNum     : char;                     //개별화면 property Tag값
    AccountCode   : array[0..2] of char;      //계좌번호 000999000XXX -> XXX
    MarketType    : char;                     //선물 : F, 옵션 : O
    SymbolSeq     : array[0..2] of char;

    Nms           : array[0..5] of char;
    FillSum       : array[0..5] of char;
    FillCount     : array[0..5] of char;
    OrderQty      : array[0..5] of char;
    MaxQuoteQty   : array[0..5] of char;
    UseRmvVol     : char;
  end;

  // 주문관리(OMAN)
  POManData  = ^TOManData;
  TOManData = packed record
    HeadData      : THeadData;
    DataDiv       : char;                     //0 : 주문취소, 1 : 주문취소(POS), 2 : 잔량스탑, 3 : 전체취소
    StartStop     : char;                     //0 : Stop, 1 : Start
    ScreenNum     : char;                     //개별화면 property Tag값
    AccountCode   : array[0..2] of char;      //계좌번호 000999000XXX -> XXX
    MarketType    : char;                     //선물 : F, 옵션 : O
    SymbolSeq     : array[0..2] of char;
    Ask           : char;                     //매도 호가 단계
    Bid           : char;                     //매수 호가 단계
    AskPosQty     : array[0..5] of char;      //매도포지션
    BidPosQty     : array[0..5] of char;      //매수포지션
    Cnt           : array[0..4] of char;      //
    Interval      : array[0..4] of char;      //
    VolStop       : char;                     //잔량스탑
  end;

  // 잔량스탑 (VOLS)
  PVolumeStopOrder = ^TVolumeStopOrder;
  TVolumeStopOrder = packed record
    HeadData  : THeadData;
    DataDiv   : char;
    Account   : array [0..2] of char;
    MarketType: char;
    SymbolSeq : array [0..2] of char;
    ls        : char;
    Price     : array [0..5] of char;
    Qty       : array [0..4] of char;
    Vol       : array [0..4] of char;
    AccVol    : array [0..4] of char;
    UseOr     : char;
    Condiv    : char;
    AccCmpSec : array [0..4] of char;
  end;

  //프런트 쿼팅 (QUOT)
  PFrontData = ^TFrontData;
  TFrontData = packed record
    HeadData      : THeadData;
    DataDiv       : char;                     //0 : 매수, 1 : 매도
    StartStop     : char;                     //0 : Stop, 1 : Start
    ScreenNum     : char;                     //개별화면 property Tag값
    AccountCode   : array[0..2] of char;      //계좌번호 000999000XXX -> XXX
    MarketType    : char;                     //선물 : F, 옵션 : O
    SymbolSeq     : array[0..2] of char;
    Hoga          : char;                     //호가
    HogaVol       : array[0..5] of char;      //설정잔량
    OrdCnt        : array[0..5] of char;      //주문건수
    OrdQty        : array[0..5] of char;      //주문수량
    UseFront      : char;                     //
    UseOrdFull    : char;
    UseTime       : char;
    Time          : array[0..7] of char;
  end;


    //프런트 쿼팅 (QUOT_RECEIVE)
  PFrontRecvData = ^TFrontRecvData;
  TFrontRecvData = packed record
    HeadData      : THeadData;
    BidAsk        : char;                     //0 : Bid, 1 : Ask
    ScreenNum     : char;                     //개별화면 property Tag값
  end;


  // 쿼팅차익 LOG 데이터(ARBD)
  PArbData = ^TArbData;
  TArbData = packed record
    HeadData      : THeadData;
    Seq           : array[0..8] of char;     //Seq
    LogTime       : array[0..8] of char;     //Time
    BasketID      : array[0..8] of char;     //BasketID
    SymbolCode    : array[0..11] of char;    //종목풀코드
    AccountNo     : array[0..11] of char;    //계좌번호
    OrderNo       : array[0..6] of char;     //주문번호
    FillNo        : array[0..10] of char;    //거래소 체결번호
    LS            : char;                    //매도S 매수L
    FillQty       : array[0..9] of char;     //체결수량
    FillPrice     : array[0..10] of char;    //체결가격
    FillTime      : array[0..8] of char;     //체결시각
    ArbType       : char;                    // 0 : FCLR, 1 : FCP, 2 : BOX
    BasketEnd     : char;                    // 0 : 진행중, 1 : BasketEnd
  end;
  // 쿼팅차익 SEQ (ARBS)
  PArbSeq = ^TArbSeq;
  TArbSeq = packed record
    HeadData      : THeadData;
    Seq           : array[0..8] of char;     //Seq
  end;


const
  LenBullData   = sizeof( TBullData );
  LenOManData   = sizeof( TOManData );
  LenVSTPData   = sizeof( TVolumeStopOrder );
  LenFrontData  = sizeof( TFrontData );
  LenFrontRecvData = sizeof( TFrontRecvData );
  LenSCatch     = sizeof( TSimpleCatch );
  LenArb        = sizeof( TArbData );
  LenArbSeq     = sizeof( TArbSeq );      

implementation

end.
