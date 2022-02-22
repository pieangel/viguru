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
    FepCode     : array [0..1] of char;       // FEP �ĺ���
    FundNo      : array [0..5] of char;
    OrderNo     : array [0..9] of char;
    MarketDiv   : char;                       // ���� 'F' �ɼ� 'P'
    ClientIdx   : array [0..4] of char;
    Response    : array [0..3] of char;
    OrderFlag   : char;                       // '1' �ֹ�üũ����
    AccountNo   : array [0..11] of char;
    Filler      : array [0..15] of char;
  end;

  //----------------------   FEP �������  (70byte)-----------------------------
  PDataHead = ^TDataHead;
  TDataHead = packed record
    stCurPrice  : Array [0..6] of char;       // ���� ���簡
		Reserve     : char; 		                  // ���౸��       0 : ����, 1 : ����
		OrderLine   : Array [0..9] of char;       // �ֹ�ȸ��ID
  	AccNo       : Array [0..9] of char; 			// ���¹�ȣ
		Passwd      : Array [0..7] of char; 	    // ��й�ȣ

  	AccName     : Array [0..9] of char; 		// ���¸�
 		EmerGency   : Array [0..4] of char; 		// ����ֹ�

		FormNo      : Array [0..5] of char; 		  // ȭ���ȣ
    MsgCode     : Array [0..3] of char; 			// �޽����ڵ�
    AcptTime    : Array [0..8] of char; 			// ����
  end;

  PCommonData  = ^TCommonData;
  TCommonData = packed record
    MsgSqeNumber  : array [0..10] of char;
    TransacCode   : array [0..10] of char;    // TrCode
    TradingSesID  : char;
    MemberNumber  : array [0..4] of char;
    BranchNo      : array [0..4] of char;
    ClOrdID       : array [0..9] of char;     // �ֹ�ID - ����+ȸ��+����+�ֹ�ID
    OrigClOrdID   : array [0..9] of char;
    SymbolCode    : array [0..11] of char;
  end;
  //--------------------------------------------
  // * �������׽��� - ȣ���Է�
  // * TRCode ( TransacCode )
  // * �ű� : TCHODR10001  , ���� : TCHODR10002  , ��� : TCHODR10003
  // * Size : 300
  //--------------------------------------------



  TMemArea = packed record
    // Reserved
    Base21      : array [0..5] of char;   // 6
    BranchNo    : array [0..2] of char;   // 3
    AcntDiv     : array [0..1] of char;   // 2
    AcntByBase21: array [0..8] of char;   // 9
    //
    BaseSpace   : array [0..3] of char;   // 4 ���� �����̽��� ä����� �Ѵ볪 �𷡳�
    Dummy1      : array [0..3] of char;   // 4
    stID        : array [0..1] of Char;   // 2 ����� ID
    GroupGb     : array [0..1] of char;   // 2 �ֹ� ��ü ����
    OrderDiv    : char;                   // 1 �ֹ� ����  Market Maker  ����, ���� ��
    {
    ���� ����͸��� ����...�ּ�
    MaketDiv    : char;                   // F ����, O �ɼ�
    SymbolSeq   : array [0..2] of char;   // ���� SEQ
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
  // * �������׽��� - ȸ��ó��ȣ��
  // * TRCode ( TransacCode )
  // * ���� : TTRODP11301  , �ź� :  TTRODP11321  , �ڵ���� : TTRODP11303
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
  // * �������׽��� - ü����
  // * TRCode ( TransacCode )
  // * ���� : TTRTDP21301
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

  // �ŷ��� ���� ��Ŷ
  UnionKSCPacket = packed record
    case Integer of
      0: ( StKseAcpt        :       THogaInput; );
      1: ( StKseConfirm     :       THogaExec; );
      2: ( StKseFill        :       TFillPacket; );
  end;

{$ifdef MzMemArea}
  ///  �ŷ��� ���� COMMAND ���
  PStReceptPacket = ^TStReceptPacket;
  TStReceptPacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
    stUnionPak   : UnionKSCPacket;
  end;

  ///  �ŷ��� ���� COMMAND ���
  PTReceivePacket = ^TReceivePacket;
  TReceivePacket = packed record
    stCommonHead : TCommonHead;
    stDataHead   : TDataHead;
  end;
{$else}
  ///  �ŷ��� ���� COMMAND ���
  PStReceptPacket = ^TStReceptPacket;
  TStReceptPacket = packed record
    stCommonHead : TCommonHead;
    stUnionPak   : UnionKSCPacket;
  end;

  ///  �ŷ��� ���� COMMAND ���
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
    Qty: array[0..9] of char;           //����
    AvgPrice: array[0..5] of char;      //��մܰ�
    FixedPL: array[0..14] of char;      //�Ÿż���
    Fee: array[0..14] of char;          //����������
    TradeAmt: array[0..14] of char;     //�����ݾ�
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
