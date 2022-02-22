unit CleSSpotPacket;

interface

const
  SSOPT_POLL = 'POLL';

  //TR
  SSOPT_ALLCLEAR  = '0001';
  SSOPT_SYMBOL    = '0002';
  SSOPT_QYT       = '0003';
  SSOPT_SLICE     = '0004';
  SSOPT_RESTRICT  = '0005';
  SSOPT_1HOGA_CNL = '0006';
  SSOPT_ADJUST    = '0007';
  SSOPT_PRE_QUOTE = '0008';
  SSOPT_DELAY     = '0009';
  SSOPT_ONOFF     = '0010';
  SSOPT_CLOSE     = '0011';

  SSOPT_SYMBOL_STATE        = 'NSSS';	// NS Symbol State
  SSOPT_TOTAL_STATE         = 'NSTS';  // NS Total State
  SSOPT_NS20_LAST_CONDITION = 'NSLC'; // NS Last Condition

type
  // ��� Index�� 0���� ����

  PHeadData  = ^THeadData;
  THeadData = packed record
    Size          : array [0..3] of char;     //TotalSize
    TrCode        : array [0..3] of char;     //TrCode
  end;

  PSsoptAllClear  = ^TSsoptAllClear;
  TSsoptAllClear = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    IsCheck       : char;         //0 : false, 1 : true
  end;

  PSsoptSymbol = ^TSsoptSymbol;
  TSsoptSymbol = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    SymbolCode    : array[0..8] of char;
  end;

  PSsoptQty = ^TSsoptQty;
  TSsoptQty = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    Qty           : array[0..4] of char;
  end;

  PSsoptSlice = ^TSsoptSlice;
  TSsoptSlice = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    Slice         : array[0..1] of char;
  end;

  PSsoptRestrict = ^TSsoptRestrict;
  TSsoptRestrict = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    IsCheck       : char;       // 0 : false, 1 : true
    LS            : char;       // L :  �ż�, S : �ŵ�
    Index         : char;       // 0 ���� ���� ex) 0 ~ 4 : 1ȣ�� ~ 5ȣ��
  end;

  PSsopt1hogacnl = ^TSsopt1hogacnl;
  TSsopt1hogacnl = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    LS            : char;       // L :  �ż�, S : �ŵ�
  end;

  PSsoptAdjust = ^TSsoptAdjust;
  TSsoptAdjust = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    LS            : char;       // L :  �ż�, S : �ŵ�
    Index         : char;       // 0 ���� ���� ex) 0 ~ 4 : 1ȣ�� ~ 5ȣ��
  end;

  PSsoptPrequote = ^TSsoptPrequote;
  TSsoptPrequote = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    LS            : char;       // L :  �ż�, S : �ŵ�
    Range         : array[0..2] of char;
  end;

  PSsoptDelay = ^TSsoptDelay;
  TSsoptDelay = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    DelayAfford   : array[0..3] of char;
  end;

  PSsoptOnOff = ^TSsoptOnOff;
  TSsoptOnOff = packed record
    HeadData      : THeadData;
    CodeIndex     : char;
    OnOff         : char;       // 0 : Off , 1 : On
  end;


  TSsoptSymbolStateItem = packed record
    Winrate1      : array[0..29] of char;    //�·�1
    Winrate2      : array[0..29] of char;    //�·�2
    SymbolState1  : array[0..19] of char;    //����1
    SymbolState2  : array[0..19] of char;    //����2
  end;

  PSsopSymbolState = ^TSsoptSymbolState;
  TSsoptSymbolState = packed record
    HeadData      : THeadData;
    SymbolState   : array[0..3] of TSsoptSymbolStateItem;
  end;

  PSsoptTotalState = ^TSsoptTotalState;
  TSsoptTotalState = packed record
    HeadData      : THeadData;
    SsoptCon      : array[0..49] of char;         //����
    OrdSess       : array[0..19] of char;         //�ֹ����ӻ���
    AcpSess       : array[0..19] of char;         //�������ӻ���
    filSess       : array[0..19] of char;         //ü�����ӻ���
    SymbolRev     : array[0..29] of char;         //�������
    QuoteTime     : array[0..19] of char;         //�ü��ð�
    QuoteDelay    : array[0..19] of char;         //�ü�����
  end;


  TSsoptLastStateItem = packed record
    IsAllClear    : char;
    SymbolCode    : array[0..8] of char;
    OrderQty      : array[0..4] of char;
    Slice         : array[0..1] of char;
    AskHogaIndex  : array[0..4] of char;
    BidHogaIndex  : array[0..4] of char;
    AskPre        : array[0..2] of char;
    BidPre        : array[0..2] of char;
    DelayAfford   : array[0..3] of char;
    OnOff         : char;
  end;

  PSsoptLastState = ^TSsoptLastState;
  TSsoptLastState = packed record
    HeadData      : THeadData;
    LastState       : array[0..3] of TSsoptLastStateItem;
  end;


const
  LenHeadData         = sizeof( THeadData );
  LenSsoptAllClear    = sizeof(TSsoptAllClear);
  LenSsoptSymbol      = sizeof(TSsoptSymbol);
  LenSsoptQty         = sizeof(TSsoptQty);
  LenSsoptSlice       = sizeof(TSsoptSlice);
  LenSsoptRestrict    = sizeof(TSsoptRestrict);
  LenSsopt1hogacnl    = sizeof(TSsopt1hogacnl);
  LenSsoptAdjust      = sizeof(TSsoptAdjust);
  LenSsoptPreQyote    = sizeof(TSsoptPrequote);
  LenSsoptDelay       = sizeof(TSsoptDelay);
  LenSsoptOnOff       = sizeof(TSsoptOnOff);
  LenSsoptSymbolState = sizeof(TSsoptSymbolState);
  LenSsoptTotalState  = sizeof(TSsoptTotalState);
  LenSsoptLastCon     = sizeof(TSsoptLastState);

implementation

end.
