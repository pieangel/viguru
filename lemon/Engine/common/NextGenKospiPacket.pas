unit NextGenKospiPacket;


interface

Const
  NewHoga = 'TCHODR10001';
  CnlHoga = 'TCHODR10003';
  ModHoga = 'TCHODR10002';
  //
  ConfNormal  = 'TTRODP11301';
  ConfReject  = 'TTRODP11321';
  AutoCancel  = 'TTRODP11303';
  //
  OrderFill   = 'TTRTDP21301';

type
  POrderPacket = ^TOrderPacket;
  TOrderPacket = record
    Size: Integer;
    Packet: array of Char;
  end;

  PCommonHead = ^TCommonHead;

  TCommonHead = packed record
    wSize       : array [0..1] of char;
    TrCode      : array [0..3] of char;       // 'DATA' or 'RESN'
    SeqNo       : array [0..8] of char;
    FepCode     : array [0..1] of char;       // FEP 식별자
    FundNo      : array [0..5] of char;
    OrderNo     : array [0..9] of char;
    MarketDiv   : char;                       // 선물 'F' 옵션 'P'
    ClientIdx   : array [0..4] of char;
    Response    : array [0..3] of char;
    OrderFlag   : char;                       // '1' 주문체크적용
    AccountNo   : array [0..11] of char;
    Filler      : array [0..15] of char;
  end;

  //----------------------   FEP 업무헤더  (70byte)-----------------------------
  PDataHead = ^TDataHead;
  TDataHead = packed record
    stCurPrice  : Array [0..6] of char;       // 종목 현재가
		Reserve     : char; 		                  // 예약구분       0 : 정상, 1 : 예약
		OrderLine   : Array [0..9] of char;       // 주문회선ID
  	AccNo       : Array [0..9] of char; 			// 계좌번호
		Passwd      : Array [0..7] of char; 	    // 비밀번호

  	AccName     : Array [0..9] of char; 		// 계좌명
 		EmerGency   : Array [0..4] of char; 		// 비상주문

		FormNo      : Array [0..5] of char; 		  // 화면번호
    MsgCode     : Array [0..3] of char; 			// 메시지코드
    AcptTime    : Array [0..8] of char; 			// 예비
  end;

  PCommonData  = ^TCommonData;
  TCommonData = packed record
    MsgSqeNumber  : array [0..10] of char;
    TransacCode   : array [0..10] of char;    // TrCode
    TradingSesID  : char;
    MemberNumber  : array [0..4] of char;
    BranchNo      : array [0..4] of char;
    ClOrdID       : array [0..9] of char;     // 주문ID - 종목+회원+지점+주문ID
    OrigClOrdID   : array [0..9] of char;
    SymbolCode    : array [0..11] of char;
  end;
  //--------------------------------------------
  // * 인터페잉스명 - 호가입력
  // * TRCode ( TransacCode )
  // * 신규 : TCHODR10001  , 정정 : TCHODR10002  , 취소 : TCHODR10003
  // * Size : 300
  //--------------------------------------------



  TMemArea = packed record
    // Reserved
    Base21      : array [0..5] of char;   // 6
    BranchNo    : array [0..2] of char;   // 3
    AcntDiv     : array [0..1] of char;   // 2
    AcntByBase21: array [0..8] of char;   // 9
    //
    BaseSpace   : array [0..3] of char;   // 4 필히 스페이스로 채워줘야 한대나 모래나
    Dummy1      : array [0..3] of char;   // 4
    stID        : array [0..1] of Char;   // 2 사용자 ID
    GroupGb     : array [0..1] of char;   // 2 주문 매체 구분
    OrderDiv    : char;                   // 1 주문 구분  Market Maker  전략, 헷지 등
    {
    차익 모니터링을 위해...주석
    MaketDiv    : char;                   // F 선물, O 옵션
    SymbolSeq   : array [0..2] of char;   // 종목 SEQ
    Dummy2      : array [0..2] of char;
    }
    // update by seunge 20121102
    GroupID     : array [0..4] of char;
    Dummy2      : array [0..1] of char;
  end;

  PHogaInput  = ^THogaInput;
  THogaInput  = packed record
    CommonData    : TCommonData;

    Side          : char;
    ModifyType    : char;
    AccountNo     : array [0..11] of char;
    OrderQty      : array [0..9] of char;
    Price         : array [0..10] of char;
    OrderType     : char;
    TimeinForce   : char;
    MarketTypeNo  : array [0..10] of char;

    SelfStockID   : array [0..4] of char;
    SelfStockMethod : char;
    AskTypeCode   : array [0..1] of char;
    CreditTypeCode: array [0..1] of char;
    TrustTypeCode : array [0..1] of char;
    TructCompNo   : array [0..4] of char;

    PTTypeCode    : array [0..1] of char;
    SubstituteNo  : array [0..11] of char;
    AccountType   : array [0..1] of char;
    AccountMarginType : array [0..1] of char;
    CountryCode : array [0..2] of char;
    InvestCode  : array [0..3] of char;
    ForeignInvestCode : array [0..1] of char;
    MediaType   : char;
    OrderIDInfo : array [0..11] of char;
    OrderDate   : array [0..7] of char;
    MemberOrderTime : array [0..8] of char;
    MemArea     : TMemArea;
    Filler      : array [0..72] of char;
  end;

  //--------------------------------------------
  // * 인터페잉스명 - 회원처리호가
  // * TRCode ( TransacCode )
  // * 정상 : TTRODP11301  , 거부 :  TTRODP11321  , 자동취소 : TTRODP11303
  // * Size : 300
  //--------------------------------------------

  PHogaExec  = ^THogaExec;
  THogaExec  = packed record
    CommonData    : TCommonData;

    Side          : char;
    ModifyType    : char;
    AccountNo     : array [0..11] of char;
    OrderQty      : array [0..9] of char;
    Price         : array [0..10] of char;
    OrderType     : char;
    TimeinForce   : char;
    MarketTypeNo  : array [0..10] of char;

    SelfStockID   : array [0..4] of char;
    SelfStockMethod : char;
    AskTypeCode   : array [0..1] of char;
    CreditTypeCode: array [0..1] of char;
    TrustTypeCode : array [0..1] of char;
    TructCompNo   : array [0..4] of char;

    PTTypeCode    : array [0..1] of char;
    SubstituteNo  : array [0..11] of char;
    AccountType   : array [0..1] of char;
    AccountMarginType : array [0..1] of char;
    CountryCode : array [0..2] of char;
    InvestCode  : array [0..3] of char;
    ForeignInvestCode : array [0..1] of char;
    MediaType   : char;
    OrderIDInfo : array [0..11] of char;
    OrderDate   : array [0..7] of char;
    MemberOrderTime : array [0..8] of char;
    MemArea     : TMemArea;
    //
    RealConfQty : array [0..9] of char;
    AutoCnlCode : char;
    RejectCode  : array [0..3] of char;
    Filler      : array [0..57] of char;
  end;

  //--------------------------------------------
  // * 인터페잉스명 - 체결결과
  // * TRCode ( TransacCode )
  // * 정상 : TTRTDP21301
  // * Size : 300
  //--------------------------------------------

  PFillPacket = ^TFillPacket;
  TFillPacket = packed record
    CommonData    : TCommonData;

    FillNo        : array [0..10 ] of char;
    FillPrice     : array [0..10 ] of char;
    FillQty       : array [0..9 ]  of char;
    FillTypeCode  : array [0..1 ]  of char;
    FillDate      : array [0..7 ]  of char;
    FillTime      : array [0..8 ]  of char;

    NearFillPrice : array [0..10 ] of char;
    FarFillPrice  : array [0..10 ] of char;
    Side          : char;
    AccountNo     : array [0..11 ] of char;
    MMakerDivNo   : array [0..10 ] of char;
    TrustCompNo   : array [0..4 ]  of char;
    SubstitueNo   : array [0..11 ] of char;
    MemArea       : TMemArea;
    Filler        : array [0..80 ] of char;
  end;

  // 거래소 접수 패킷
  UnionKSCPacket = packed record
    case Integer of
      0: ( StKseAcpt        :       THogaInput; );
      1: ( StKseConfirm     :       THogaExec; );
      2: ( StKseFill        :       TFillPacket; );
  end;

{$ifdef MzMemArea}
  ///  거래소 접수 COMMAND 헤더
  PStReceptPacket = ^TStReceptPacket;
  TStReceptPacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
    stUnionPak   : UnionKSCPacket;
  end;

  ///  거래소 접수 COMMAND 헤더
  PTReceivePacket = ^TReceivePacket;
  TReceivePacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
  end;
{$else}
  ///  거래소 접수 COMMAND 헤더
  PStReceptPacket = ^TStReceptPacket;
  TStReceptPacket = packed record
    stCommonHead : TCommonHead;
    stUnionPak   : UnionKSCPacket;
  end;

  ///  거래소 접수 COMMAND 헤더
  PTReceivePacket = ^TReceivePacket;
  TReceivePacket = packed record
    stCommonHead : TCommonHead;
  end;
{$endif}


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
    SvrHeader: TServerHeader;
    Market: char;
    AccountNo: array[0..11] of char;
    PrdtNo: array[0..11] of char;
    Qty: array[0..9] of char;           //수량
    AvgPrice: array[0..5] of char;      //평균단가
    FixedPL: array[0..14] of char;      //매매손익
    Fee: array[0..14] of char;          //선물수수료
    TradeAmt: array[0..14] of char;     //약정금액
  end;

  // activ order      [SO]
  PActiveOrder = ^TActiveOrder;
  TActiveOrder = packed record
    SvrHeader: TServerHeader;
    Market: char;
    AccountNo: array[0..11] of char;
    PrdtNo: array[0..11] of char;
    OrderKind: char;
    Side: char;
    Qty: array[0..9] of char;
    Price: array[0..10] of char;
    OrderDiv: char;
    OrderNo: array[0..9] of char;
    OriginNo: array[0..9] of char;
    lpDiv: char;
    groupid: array[0..5] of char;
    OAsk: char;
    AcptTime: array[0..8] of char;
  end;






const
  LenCommonHead = sizeof( TCommonHead );
  LenDataHead   = sizeof( TDataHead );
  LenHogaInput  = sizeof( THogaInput );
  LenHogaExec   = sizeof( THogaExec );
  LenFillPacket = sizeof( TFillPacket );


implementation

end.
