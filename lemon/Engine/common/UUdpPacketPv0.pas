unit UUdpPacketPv0;

interface

type
  //���� ȣ��,ü�� ��Ŷ --------------------------------------------------------
  TFQtyItem = packed record
    SellSign: Char;                //Sell Sign��ȣ
    Sell:     array[0..4] of Char; //9(3).99
    BuySign:  Char;                //Buy Sign��ȣ
    Buy:      array[0..4] of Char; //9(3).99
    SellQty:  array[0..5] of Char; //�ŵ�ȣ�� ����
    BuyQty:   array[0..5] of Char; //�ż�ȣ�� ����
  end;

  TFCntItem = packed record
    Cnt1:   array[0..3] of Char; //�ŵ�/�ż� 1ȣ���Ǽ�
    Cnt2:   array[0..3] of Char; //�ŵ�/�ż� 2ȣ���Ǽ�
    Cnt3:   array[0..3] of Char; //�ŵ�/�ż� 3ȣ���Ǽ�
    Cnt4:   array[0..3] of Char; //�ŵ�/�ż� 4ȣ���Ǽ�
    Cnt5:   array[0..3] of Char; //�ŵ�/�ż� 5ȣ���Ǽ�
    TotCnt: array[0..4] of Char; //�ŵ�/�ż� ��ȣ���Ǽ�
  end;

  //���� ȣ�� - 'F1' + �Ϸù�ȣ(6) + 'H0'
  PFutureCall = ^TFutureCall;
  TFutureCall = packed record
    {
    Gubun:      array[0..1] of Char;        //�ü�-'F1'
    SeqNo:      array[0..5] of Char;        //�����Ϸù�ȣ
    //Data���� - ����ȣ�� : "H0"  ü�� : "C0"   �⼼ : "G0"  ���� : "J0"  �̰��� : "M0"  �Ÿ����ű� ���ذ� : "I0"  SPACE : "S0"  ���� : "SE"
    DataGu:     array[0..1] of Char;        //ȣ������ - 'H0'
    }
    Code:        array[0..7] of Char;      //�����ڵ�
    CodeSeq:     array[0..1] of Char;      //����SEQ, ��ȣ (01,02,03,04)
    Qty1Item:    TFQtyItem;                //�ŵ��ż� �ֿ켱ȣ��
    AcptTime:    array[0..7] of Char;      //ȣ�������ð�
    Qty2To3Item: array[0..1] of TFQtyItem; //�ŵ�/�ż� 2~3ȣ��
    SellQty:     array[0..5] of Char;      //�ŵ� ��ȣ�� ����
    BuyQty:      array[0..5] of Char;      //�ż� ��ȣ�� ����
    FQty4To5Item: array[0..1] of TFQtyItem; //�ŵ�/�ż� 4~5ȣ��
    CntItem:     array[0..1] of TFCntItem; //�ŵ�/�ż� 1~5ȣ���Ǽ�
    EndOfText:   Char;                     //END OF TEXT (%HFF)
  end;

  //���� ü�� - 'F1' + �Ϸù�ȣ(6) + 'C0'
  PFutureTick = ^TFutureTick;
  TFutureTick = packed record
    {
    Gubun:      array[0..1] of Char;        //�ü�-'F1'
    SeqNo:      array[0..5] of Char;        //�����Ϸù�ȣ
    //Data���� - ����ȣ�� : "H0"  ü�� : "C0"   �⼼ : "G0"  ���� : "J0"  �̰��� : "M0"  �Ÿ����ű� ���ذ� : "I0"  SPACE : "S0"  ���� : "SE"
    DataGu:     array[0..1] of Char;        //ü�ᱸ�� - 'C0'
    }
    Code:           array[0..7] of Char;      //�����ڵ�
    CodeSeq:        array[0..1] of Char;      //����SEQ, ��ȣ (01,02,03,04)
    FillTime:       array[0..7] of Char;      //ü��ð�
    CurSign:        Char;                     //���簡 Sign��ȣ
    Current:        array[0..4] of Char;      //9(3).99
    NearPrice:      array[0..4] of Char;      //�ֱٿ��� ������������ - 9(3).99
    LongPrice:      array[0..4] of Char;      //������ ������������ - 9(3).99
    OpenSign:       Char;                     //�ð� Sign��ȣ
    Open:           array[0..4] of Char;      //9(3).99
    HighSign:       Char;                     //�� Sign��ȣ
    High:           array[0..4] of Char;      //9(3).99
    LowSign:        Char;                     //���� Sign��ȣ
    Low:            array[0..4] of Char;      //9(3).99
    TotalQty:       array[0..6] of Char;      //����ü�����
    TotalPrice:     array[0..10] of Char;     //�����ŷ���� (�� ���� : õ��)
    NearTotalQty:   array[0..6] of Char;      //�ٿ���ü�����
    NearTotalPrice: array[0..10] of Char;     //�ٿ����ŷ���� (�� ���� : õ��)
    LongTotalQty:   array[0..6] of Char;      //������ü�����
    LongTotalPrice: array[0..10] of Char;     //�������ŷ���� (�� ���� : õ��)
    MarginSign:     Char;                     //���ϴ�� ��ȣ
    Margin:         array[0..4] of Char;      //9(3).99
    FillQty:        array[0..5] of Char;      //�Ǻ� ü�����
    FQty1To3Item:    array[0..2] of TFQtyItem; //�ŵ�/�ż� 1~3ȣ��
    SellQty:        array[0..5] of Char;      //�ŵ� ��ȣ�� ����
    BuyQty:         array[0..5] of Char;      //�ż� ��ȣ�� ����
    FQty4To5Item:    array[0..1] of TFQtyItem; //�ŵ�/�ż� 4~5ȣ��
    CntItem:        array[0..1] of TFCntItem; //�ŵ�/�ż� 1~5ȣ���Ǽ�
    EndOfText:      Char;                     //END OF TEXT (%HFF)
  end;

  //�ɼ� ȣ��,ü�� ��Ŷ --------------------------------------------------------
  TOQtyItem = packed record
    Sell:    array[0..4] of Char; //9(3).99
    Buy:     array[0..4] of Char; //9(3).99
    SellQty: array[0..6] of Char; //�ŵ�ȣ�� ����     // by Nsh(20060807) => �ɼ� ȣ���ܷ�(6=>7�ڸ��� ����)
    BuyQty:  array[0..6] of Char; //�ż�ȣ�� ����     // by Nsh(20060807) => �ɼ� ȣ���ܷ�(6=>7�ڸ��� ����)
  end;

  TOCntItem = packed record
    Cnt1:   array[0..3] of Char; //�ŵ�/�ż� 1ȣ���Ǽ�
    Cnt2:   array[0..3] of Char; //�ŵ�/�ż� 2ȣ���Ǽ�
    Cnt3:   array[0..3] of Char; //�ŵ�/�ż� 3ȣ���Ǽ�
    Cnt4:   array[0..3] of Char; //�ŵ�/�ż� 4ȣ���Ǽ�
    Cnt5:   array[0..3] of Char; //�ŵ�/�ż� 5ȣ���Ǽ�
    TotCnt: array[0..4] of Char; //�ŵ�/�ż� ��ȣ���Ǽ�
  end;

  //�ɼ� ȣ�� - 'O1' + �Ϸù�ȣ(7) + 'H0'
  POptionCall = ^TOptionCall;
  TOptionCall = packed record
    {
    Gubun:      array[0..1] of Char;        //�ü�-'01'
    SeqNo:      array[0..6] of Char;        //�����Ϸù�ȣ
    //Data���� -  ȣ��   : "H0"   ü��   : "C0"  �⼼   : "G0"  ���� : "J0"  �̰��� : "M0"  �Ÿ����ű� ���ذ� : "I0"  SPACE : "S0", ���� : "OE"
    DataGu:     array[0..1] of Char;        //ȣ������ - 'H0'
    }
    Code:        array[0..7] of Char;      //�����ڵ�
    CodeSeq:     array[0..2] of Char;      //����SEQ, ��ȣ
    OQty1To3Item: array[0..2] of TOQtyItem; //�ŵ�/�ż� 1~3ȣ������
    SellQty:     array[0..6] of Char;      //�ŵ� ��ȣ�� ����      // by Nsh(20060807) => �ɼ� ȣ���ܷ�(6=>7�ڸ��� ����)
    BuyQty:      array[0..6] of Char;      //�ż� ��ȣ�� ����      // by Nsh(20060807) => �ɼ� ȣ���ܷ�(6=>7�ڸ��� ����)
    AcptTime:    array[0..7] of Char;      //ȣ�������ð� - '00000000'
    OQty4To5Item: array[0..1] of TOQtyItem; //�ŵ�/�ż� 4~5ȣ������
    CntItem:     array[0..1] of TOCntItem; //�ŵ�/�ż� 1~5ȣ���Ǽ�
    EndOfText:   Char;                     //END OF TEXT (%HFF)
  end;

  //�ɼ� ü�� - 'O1' + �Ϸù�ȣ(7) + 'C0'
  POptionTick = ^TOptionTick;
  TOptionTick = packed record
    {
    Gubun:      array[0..1] of Char;        //�ü�-'01'
    SeqNo:      array[0..6] of Char;        //�����Ϸù�ȣ
    //Data���� -  ȣ��   : "H0"   ü��   : "C0"  �⼼   : "G0"  ���� : "J0"  �̰��� : "M0"  �Ÿ����ű� ���ذ� : "I0"  SPACE : "S0", ���� : "OE"
    DataGu:     array[0..1] of Char;        //ü�ᱸ�� - 'C0'
    }
    Code:        array[0..7] of Char;      //�����ڵ�
    CodeSeq:     array[0..2] of Char;      //����SEQ, ��ȣ
    FillQty:     array[0..5] of Char;      //ü�����
    FillTime:    array[0..7] of Char;      //ü��ð�
    OQty1To3Item: array[0..2] of TOQtyItem; //�ŵ�/�ż� 1~3ȣ������
    SellQty:     array[0..6] of Char;      //�ŵ� ��ȣ�� ����       // by Nsh(20060807) => �ɼ� ȣ���ܷ�(6=>7�ڸ��� ����)
    BuyQty:      array[0..6] of Char;      //�ż� ��ȣ�� ����       // by Nsh(20060807) => �ɼ� ȣ���ܷ�(6=>7�ڸ��� ����)
    Current:     array[0..4] of Char;      //���簡-9(3).99
    Open:        array[0..4] of Char;      //�ð�-9(3).99
    High:        array[0..4] of Char;      //��-9(3).99
    Low:         array[0..4] of Char;      //����-9(3).99
    TotalQty:    array[0..7] of Char;      //����ü�����
    TotalPrice:  array[0..10] of Char;     //�����ŷ���� (�� ���� : õ��)
    OQty4To5Item: array[0..1] of TOQtyItem; //�ŵ�/�ż� 4~5ȣ������
    CntItem:     array[0..1] of TOCntItem; //�ŵ�/�ż� 1~5ȣ���Ǽ�
    EndOfText:   Char;                     //END OF TEXT (%HFF)
  end;

  //�������ǽ��� ȣ��,ü�� ��Ŷ ------------------------------------------------
  TSCallItem = packed record
    Sell:    array[0..8] of Char; //�ŵ�ȣ��
    Buy:     array[0..8] of Char; //�ż�ȣ��
    SellQty: array[0..9] of Char; //�ŵ�ȣ�� �ܷ�
    BuyQty:  array[0..9] of Char; //�ż�ȣ�� �ܷ�
  end;

  //�������ǽ��� ȣ��-'H1'
  PStockCall = ^TStockCall;
  TStockCall = packed record
    //DataGu: array[0..1] of Char; //Data����-'H1'
    Code:         array[0..11] of Char;      //�����ڵ�-ǥ���ڵ�
    TotalQty:     array[0..9] of Char;       //�屸�� ������� ��� �ŷ����� �ջ�(�尳���� ����)
    CallItem:     array[0..9] of TSCallItem; //ȣ�� 10�ܰ�:10*38=380
    SellTotalQty: array[0..9] of Char;
    BuyTotalQty:  array[0..9] of Char;
    PlaceGu:      Char;                      //�屸�� - 0: ����, 1: �������Ľð���
    SameGu:       Char;                      //���ñ��� - 0: ����, 1: ����, 2: ���ÿ���
    AnFillPrice:  array[0..8] of Char;       //����ü�ᰡ��(AnticipationFillPrice)
    AnFillQty:    array[0..9] of Char;       //����ü�����(AnticipationFillQty)
    OverPlaceGu:  Char;                      //�ð��ܴ��ϰ��屸��(TimeOverUniPricePlaceGu) - 0:�ʱⰪ 1:�ð��ܴ��ϰ����� 2:�ð��ܴ��ϰ�����
    EndOfText:    Char;                      //END OF TEXT (%HFF)
  end;
    
  //�������ǽ��� ü��-'S3'
  PStockTick = ^TStockTick;
  TStockTick = packed record
    //DataGu: array[0..1] of Char; //Data����-'S3'
    Code:       array[0..11] of Char; //�����ڵ�-ǥ���ڵ�
    Signal:     Char;                 //���ϴ��(���ذ����)���� - 0:�ǴܺҰ� 1:���� 2:��� 3:���� 4:���� 5:�϶�
    Margin:     array[0..8] of Char;  //���ϴ��(���ذ����) �� �����μ��� ����/������ �ű� ���� ���� : 0
    Current:    array[0..8] of Char;  //���簡
    Open:       array[0..8] of Char;  //�ð�
    High:       array[0..8] of Char;  //��
    Low:        array[0..8] of Char;  //����
    TotalQty:   array[0..9] of Char;  //�����ŷ���(�Ѱŷ���) ����:1�� �ظŸű��к��� ���� ������
    TotalPrice: array[0..14] of Char; //�����ŷ����(�Ѱŷ����) ����:1�� �ظŸű��к��� ���� ������
    {
    //�Ÿű���
    01:���� 03:�Ű�뷮 05:�������Ľð�������
    06:�������Ľð��ܴ뷮 07:�������Ľð��ܹٽ���
    08:�尳�����ð������� 09:�尳�����ð��ܴ뷮
    10:�尳�����ð��ܹٽ���
    11:���ߴ뷮 12:���߹ٽ���
    13:�ð��ܴ��ϰ��Ÿ�
    }
    SaleType:   array[0..1] of Char;
    PlaceGu:    Char;                 //�屸�� - 0: ����, 1: �������Ľð���
    FillPrice:  array[0..8] of Char;  //ü�ᰡ
    EndOfText:  Char;                 //END OF TEXT (%HFF)
  end;

  //�������ǽ��� ���� ----------------------------------------------------------
  PStockIndex = ^TStockIndex;
  TStockIndex = packed record
    //DataGu: array[0..1] of Char; //Data����-KOSPI200 : 'I2'
    Code:      array[0..1] of Char; //�����ڵ�-01~06 -> '1201'~'1206'(�����ڵ�� �����)
    Time:      array[0..5] of Char; //�ð�-����:HHMMSS(�ð�:��:��), ������:JUNJJJ
    Index:     array[0..7] of Char; //����-9(6).99
    Sign:      Char;                //��ȣ-"+":��� "-":�϶� " ":����
    Margin:    array[0..7] of Char; //���-9(6).99
    Qty:       array[0..7] of Char; //�ŷ���-����:õ��
    Price:     array[0..7] of Char; //�ŷ����-����:�鸸��
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
