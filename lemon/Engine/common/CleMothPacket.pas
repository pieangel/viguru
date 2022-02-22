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
    ScreenNum     : char;                     //����ȭ�� property Tag��
    AccountCode   : array[0..2] of char;      //���¹�ȣ 000999000XXX -> XXX
    MarketType    : char;                     //���� : F, �ɼ� : O
    SymbolSeq     : array[0..2] of char;
    L             : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    S             : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    TimeCx        : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    TimeCx_Value  : array[0..4] of char;      //99999->9999.9
    E1            : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    E1_Value1     : array[0..3] of char;      //9999 -> 999.9
    E1_Value2     : array[0..3] of char;      //9999 -> 999.9
    E1_Value3     : array[0..3] of char;      //9999 -> 999.9
    E1_Value4     : array[0..3] of char;      //9999 -> 999.9      w
    E1_Value5     : array[0..3] of char;      //9999 -> 999.9
    E1_Value6     : array[0..3] of char;      //9999 -> 999.9
    E2            : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    E2_Value1     : array[0..4] of char;
    NewOrder      : array[0..5] of char;
    MaxPostion    : array[0..5] of char;
    MaxQuoteQty   : array[0..5] of char;
    X1            : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    X1_Value1     : array[0..3] of char;      //9999 -> 999.9
    X1_Value2     : array[0..3] of char;      //9999 -> 999.9
    X2            : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    X2_Value1     : array[0..3] of char;      //9999 -> 999.9
    X2_Value2     : array[0..3] of char;      //9999 -> 999.9
    X3            : char;                     //0: üũ�ڽ� X  , 1: üũ�ڽ� O
    Buttons       : char;                     //0 : C1, 1 : C2, 2 : C3, 3 : C4, 4 : C5, 5 : C6, 6 : C7, 7 : C8
  end;

  // Simple catch
  PSimpleCatch = ^TSimpleCatch;
  TSimpleCatch = packed record
    HeadData      : THeadData;
    StartStop     : char;                     //0 : Stop, 1 : Start
    ScreenNum     : char;                     //����ȭ�� property Tag��
    AccountCode   : array[0..2] of char;      //���¹�ȣ 000999000XXX -> XXX
    MarketType    : char;                     //���� : F, �ɼ� : O
    SymbolSeq     : array[0..2] of char;

    Nms           : array[0..5] of char;
    FillSum       : array[0..5] of char;
    FillCount     : array[0..5] of char;
    OrderQty      : array[0..5] of char;
    MaxQuoteQty   : array[0..5] of char;
    UseRmvVol     : char;
  end;

  // �ֹ�����(OMAN)
  POManData  = ^TOManData;
  TOManData = packed record
    HeadData      : THeadData;
    DataDiv       : char;                     //0 : �ֹ����, 1 : �ֹ����(POS), 2 : �ܷ���ž, 3 : ��ü���
    StartStop     : char;                     //0 : Stop, 1 : Start
    ScreenNum     : char;                     //����ȭ�� property Tag��
    AccountCode   : array[0..2] of char;      //���¹�ȣ 000999000XXX -> XXX
    MarketType    : char;                     //���� : F, �ɼ� : O
    SymbolSeq     : array[0..2] of char;
    Ask           : char;                     //�ŵ� ȣ�� �ܰ�
    Bid           : char;                     //�ż� ȣ�� �ܰ�
    AskPosQty     : array[0..5] of char;      //�ŵ�������
    BidPosQty     : array[0..5] of char;      //�ż�������
    Cnt           : array[0..4] of char;      //
    Interval      : array[0..4] of char;      //
    VolStop       : char;                     //�ܷ���ž
  end;

  // �ܷ���ž (VOLS)
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

  //����Ʈ ���� (QUOT)
  PFrontData = ^TFrontData;
  TFrontData = packed record
    HeadData      : THeadData;
    DataDiv       : char;                     //0 : �ż�, 1 : �ŵ�
    StartStop     : char;                     //0 : Stop, 1 : Start
    ScreenNum     : char;                     //����ȭ�� property Tag��
    AccountCode   : array[0..2] of char;      //���¹�ȣ 000999000XXX -> XXX
    MarketType    : char;                     //���� : F, �ɼ� : O
    SymbolSeq     : array[0..2] of char;
    Hoga          : char;                     //ȣ��
    HogaVol       : array[0..5] of char;      //�����ܷ�
    OrdCnt        : array[0..5] of char;      //�ֹ��Ǽ�
    OrdQty        : array[0..5] of char;      //�ֹ�����
    UseFront      : char;                     //
    UseOrdFull    : char;
    UseTime       : char;
    Time          : array[0..7] of char;
  end;


    //����Ʈ ���� (QUOT_RECEIVE)
  PFrontRecvData = ^TFrontRecvData;
  TFrontRecvData = packed record
    HeadData      : THeadData;
    BidAsk        : char;                     //0 : Bid, 1 : Ask
    ScreenNum     : char;                     //����ȭ�� property Tag��
  end;


  // �������� LOG ������(ARBD)
  PArbData = ^TArbData;
  TArbData = packed record
    HeadData      : THeadData;
    Seq           : array[0..8] of char;     //Seq
    LogTime       : array[0..8] of char;     //Time
    BasketID      : array[0..8] of char;     //BasketID
    SymbolCode    : array[0..11] of char;    //����Ǯ�ڵ�
    AccountNo     : array[0..11] of char;    //���¹�ȣ
    OrderNo       : array[0..6] of char;     //�ֹ���ȣ
    FillNo        : array[0..10] of char;    //�ŷ��� ü���ȣ
    LS            : char;                    //�ŵ�S �ż�L
    FillQty       : array[0..9] of char;     //ü�����
    FillPrice     : array[0..10] of char;    //ü�ᰡ��
    FillTime      : array[0..8] of char;     //ü��ð�
    ArbType       : char;                    // 0 : FCLR, 1 : FCP, 2 : BOX
    BasketEnd     : char;                    // 0 : ������, 1 : BasketEnd
  end;
  // �������� SEQ (ARBS)
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
