// kospi200 Futures & Options & Stock Futures Udp Spec.
// Wertpapier ( stock ) & ELW Udp Spec.

unit UUDPPacket;

interface

const
  TrFill = 'A3';
  TrRecovery = 'B2';
  TrHoga = 'B6';
  TrElwHoga = 'B7';
  TrFillNHoga = 'G7';
  TrK200  = 'D2';
  TrK200expect = 'EX';
  TrElwGreeks = 'C7';
  TrOptionGreeks = 'N7';
  TrInvestorData = 'H1';

  //H2034 : �̰�����������

  TrVKospi = 'J3';
  TrCPPP = 'N0';
  TrK200Risk = 'O8';
  TrFKospi = 'K9';
  TrOpenInterest = 'H2';

  StockNElw = '1';
  IndexDer = '4';
  StockDer = '5';

  OptInfo  = '03';
  FutInfo  = '01';
  VInfo    = '04'; // ������ ����

  K200Indust = '029';

  K200Risk6Per  = '711';
  K200Risk8Per  = '712';
  K200Risk10Per = '713';
  K200Risk12Per = '714';  

type
  PCommonHeader = ^TCommonHeader;
  TCommonHeader = packed record
    DataDiv : array [0..1] of char;   // ����Ÿ����  AB6, A3, G7
    InfoDiv : array [0..1] of char;   // ��������  01 : ���� , 03 : �ɼ�
    MarketDiv : char;                 // ���屸��   5 : ���� ,  4 : ����
    //
    Code    : array [0..11] of char;  // �����ڵ�
  end;

  SFutPriceQtyItem = packed record
    Sign  : char;
    Price : array [0..6] of char;
    Volume: array [0..5] of char;
  end;

  FutPriceQtyItem = packed record
    Sign  : char;
    Price : array [0..4] of char;
    Volume: array [0..5] of char;
  end;

  OptPriceQtyItem = packed record
    Price : array [0..4] of char;
    Volume: array [0..6] of char;
  end;

  SFutCountItem = packed record
    Cnt1:   array[0..3] of Char;
    Cnt2:   array[0..3] of Char;
    Cnt3:   array[0..3] of Char;
    Cnt4:   array[0..3] of Char;
    Cnt5:   array[0..3] of Char;
    Cnt6:   array[0..3] of Char;
    Cnt7:   array[0..3] of Char;
    Cnt8:   array[0..3] of Char;
    Cnt9:   array[0..3] of Char;
    Cnt10:  array[0..3] of Char;
  end;

  DerCountItem = packed record
    Cnt1:   array[0..3] of Char;
    Cnt2:   array[0..3] of Char;
    Cnt3:   array[0..3] of Char;
    Cnt4:   array[0..3] of Char;
    Cnt5:   array[0..3] of Char;
  end;

  // Stock Futures Price & Fill & (price & fill )-------------------------------
  //

  PStockFutPrice = ^TStockFutPrice;
  TStockFutPrice = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..3] of char;
    MarketStat  : array [0..1] of char;
    //
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..9] of SFutPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..9] of SFutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: SFutCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems: SFutCountItem;
    AcptTime    : array [0..7] of char;
  end;

  PStockFutTick = ^TStockFutTick;
  TStockFutTick = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..3] of char;
    CurSign  : char;
    CurPrice  : array [0..6] of char;
    Volume    : array [0..5] of char;
    TickType  : array [0..1] of char;
    TickTime  : array [0..7] of char;
    NearPrice : array [0..6] of char;
    FarPrice  : array [0..6] of char;
    //
    OpenSign  : char;
    OpenPrice : array [0..6] of char;
    HighSign  : char;
    HighPrice : array [0..6] of char;
    LowSign   : char;
    LowPrice  : array [0..6] of char;
    PrevSign  : char;
    PrevPrice : array [0..6] of char;
    //
    DailyVolume : array [0..6] of char;
    DailyPrice  : array [0..14] of char;
  end;

  PStockFutTickPrice = ^TStockFutTickPrice;
  TStockFutTickPrice = packed record
    Tick  : TStockFutTick;
    //
    MarketStat  : array [0..1] of char;
    
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..9] of SFutPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..9] of SFutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: SFutCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems: SFutCountItem;
    //AcptTime    : array [0..7] of char;
  end;

  //
  // End Stock Futures Price & Fill & (price & fill )---------------------------

  // Kospi2200 Futures Price & Fill & (price & fill )---------------------------
  //

  PFutPrice = ^TFutPrice;
  TFutPrice = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..1]  of char;
    MarketStat  : array [0..1] of char;
    //
    BidTotVol  : array [0..5] of char;
    BidItems   : array [0..4] of FutPriceQtyItem;
    AskTotVol : array [0..5] of char;
    AskItems  : array [0..4] of FutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    AcptTime    : array [0..7] of char;
    ExpectSign  : char;                                 //2012.06.25 ����
    ExpectPrice  : array[0..4] of char;                 //2012.06.25 ����
  end;

  PFutTick  = ^TFutTick;
  TFutTick  = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..1]  of char;
    CurSign : char;
    CurPrice : array [0..4] of char;
    Volume  : array [0..5] of char;
    TickType: array [0..1] of char;
    TickTime: array [0..7] of char;
    NearPrice : array [0..4] of char;
    FarPrice  : array [0..4] of char;
    //
    OpenSign  : char;
    OpenPrice : array [0..4] of char;
    HighSign  : char;
    HighPrice : array [0..4] of char;
    LowSign   : char;
    LowPrice  : array [0..4] of char;
    PrevSign  : char;
    PrevPrice : array [0..4] of char;
    //
    DailyVolume : array [0..6] of char;
    DailyPrice  : array [0..11] of char;  //2011.05.23 11 -> 12byte ���� 
  end;

  PFutTickPrice = ^TFutTickPrice;
  TFutTickPrice = packed record
    Tick  : TFutTick;
    //
    MarketStat  : array [0..1] of char;
    //
    BidTotVol  : array [0..5] of char;
    BidItems   : array [0..4] of FutPriceQtyItem;
    AskTotVol : array [0..5] of char;
    AskItems  : array [0..4] of FutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    //AcptTime    : array [0..7] of char;
  end;

  //
  // End Kospi2200 Futures Price & Fill & (price & fill )-----------------------

  // Kospi2200 Options Price & Fill & (price & fill )---------------------------
  //

  POptPrice = ^TOptPrice;
  TOptPrice = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    MarketStat  : array [0..1] of char;
    //
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..4] of OptPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..4] of OptPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    AcptTime    : array [0..7] of char;
    ExpectPrice  : array[0..4] of char;                 //2012.06.25 ����
  end;

  POptTick  = ^TOptTick;
  TOptTick  = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    CurPrice : array [0..4] of char;
    Volume  : array [0..6] of char;
    TickType: array [0..1] of char;
    TickTime: array [0..7] of char;
    //
    OpenPrice : array [0..4] of char;
    HighPrice : array [0..4] of char;
    LowPrice  : array [0..4] of char;
    PrevPrice : array [0..4] of char;
    //
    DailyVolume : array [0..7] of char;
    DailyPrice  : array [0..10] of char;
  end;

  POptTickPrice = ^TOptTickPrice;
  TOptTickPrice = packed record
    Tick  : TOptTick;
    MarketStat  : array [0..1] of char;
    //
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..4] of OptPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..4] of OptPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    //AcptTime    : array [0..7] of char;
  end;

  //
  // End Kospi2200 Options Price & Fill & (price & fill )-----------------------

  TStockPricItem = packed record
    AskPrice  : array [0..8] of char;
    BidPrice   : array [0..8] of char;
    AskVolume : array [0..11] of char;
    BidVolume  : array [0..11] of char;
  end;

  TElwPriceItem = packed record
    PriceItem : TStockPricItem;
    LpAskVolume : array [0..11] of char;
    LpBidVolume  : array [0..11] of char;
  end;

  PStockPrice = ^TStockPrice;
  TStockPrice = packed record
    Code    : array [0..11] of char;
    Volume  : array [0..11] of char;
    PriceItems  : array [0..9] of TStockPricItem;
    AskTotVol : array [0..11] of char;
    BidTotVol  : array [0..11] of char;
    Fillter : array [0..23] of char;    // addy by l.c.s   2010.4.23
    MarketStat  : array [0..1] of char;
    MarketDiv   : char;
    ExpectPrice  : array [0..8] of char;
    ExpectVolume : array [0..11] of char;
  end;

  PElwPrice = ^TElwPrice;
  TElwPrice = packed record
    Code    : array [0..11] of char;
    Volume  : array [0..11] of char;
    PriceItems  : array [0..9] of TElwPriceItem;
    AskTotVol : array [0..11] of char;
    BidTotVol  : array [0..11] of char;
    Filler : array[0..23] of char;
    EndAskTotVol : array[0..11] of char;
    EndBidTotVol : array[0..11] of char;
    MarketStat  : array [0..1] of char;
    MarketDiv   : char;
    ExpectPrice  : array [0..8] of char;
    ExpectVolume : array [0..11] of char;
  end;


  PStockTick  = ^TStockTick;
  TStockTick  = packed record
    Code  : array [0..11] of char;
    MarketDiv : char;
    ChangeDiv : char;
    Change    : array [0..8] of char;

    Price   : array [0..8] of char;
    Volume  : array [0..9] of char;
    FillType : array [0..1] of char;

    //
    OpenPrice : array [0..8] of char;
    HighPrice : array [0..8] of char;
    LowPrice  : array [0..8] of char;

    //
    TotACumulVolume : array [0..11] of char;
    TotACumulPrice  : array [0..17] of char;

    Side  : char; // 1 : �ŵ� , 2 : �ż�
    FillSameDiv : char;   // 0 : �ǴܺҰ�, 1 :��ġ  2 : ����ġ
    FillTime  : array [0..5] of char;
    LpVolume  : array [0..14] of char;

    AskPrice  : array [0..8] of char;
    BidPrice  : array [0..8] of char;
  end;

  PElwGreeks = ^TElwGreeks;
  TElwGreeks = packed record
    Code  : array [0..11] of char;
    Time  : array [0..5] of char;
    Theory  : array [0..9] of char;   //  100
    DeltaSign : char;
    Delta : array [0..6] of char;     // 1000000
    GammanSign : char;
    Gamman  : array [0..6] of char;   // 1000000
    ThetaSign : char;
    Theta : array [0..11] of char;    // 1000000
    VegaSign : char;
    Vega  : array [0..11] of char;
    RhoSign : char;
    Rho : array [0..11] of char;
    IV  : array [0..4] of char;       // 100
    Cost : array [0..9] of char;
    Filler : array [0..5] of char;
    TextEnd : char;
  end;


  POptOpenInterest = ^TOptOpenInterest;   // H2034
  TOptOpenInterest = packed record
    Code  : array [0..11] of char;
    Seq         : array [0..2] of char;
    OIDiv       : array [0..1] of char;   // 'MO : ����Ȯ��  ���� 7��40�а�
    TradeDate   : array [0..7] of char;
    OIQty       : array [0..8] of char;
    TextEnd     : char;
  end;

  PFutOpenInterest = ^TFutOpenInterest;   // H2014
  TFutOpenInterest = packed record
    Code  : array [0..11] of char;
    Seq         : array [0..1] of char;
    OIDiv       : array [0..1] of char;   // MO : ����Ȯ��  ���� 7��40�а�     M1 : ���� ����
    TradeDate   : array [0..7] of char;   // M1 : ���� Ȯ�� �������� 1�ð���
    OIQty       : array [0..8] of char;
    TextEnd     : char;
  end;

  // Index Data ----------------------------------------------------------------
  //

  PIndexData  = ^TIndexData;
  TIndexData  = packed record
    IndustCode  : array [0..2] of char;
    Indextime   : array [0..5] of char;
    IndexPrice  : array [0..7] of char;  //6.2
    Sign        : char;
    Change      : array [0..7] of char;
    Volume      : array [0..7] of char; // õ��
    Amount      : array [0..7] of char; // �鸸
  end;

  // Ŀ������_������Ƽ��ǲ����
  PCP_PPIndexData = ^TCP_PPIndexData;
  TCP_PPIndexData = packed record
    IndustCode  : array [0..2] of char;
    Indextime   : array [0..5] of char;
    CPIndex     : array [0..7] of char;  //6.2
    CPSign      : char;
    CPChange    : array [0..7] of char;
    PPIndex     : array [0..7] of char;  //6.2
    PPSign      : char;
    PPChange    : array [0..7] of char;
  end;

  // Index Data Expect
  PIndexExpectData  = ^TIndexExpectData;
  TIndexExpectData  = packed record
    expectCode  : array [0..5] of char;
    expecttime  : array [0..10] of char;
    expectPrice : array [0..4] of char;  //3.2
  end;

  TOptHoga = packed record
    Price : array [0..4] of char;
    Volume: array [0..6] of char;
    Cnt   : array [0..3] of char;
  end;

  POptSisRecovery = ^TOptSisRecovery;
  TOptSisRecovery = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    CurPrice : array [0..4] of char;
    OpenPrice : array [0..4] of char;
    HighPrice : array [0..4] of char;
    LowPrice  : array [0..4] of char;
    OpenInterest : array [0..8] of char;

    DailyVolume : array [0..7] of char;
    DailyPrice  : array [0..10] of char;

    Ask1  : TOptHoga;
    Bid1  : TOptHoga;

    Ask2  : TOptHoga;
    Bid2  : TOptHoga;

    Ask3  : TOptHoga;
    Bid3  : TOptHoga;

    Ask4  : TOptHoga;
    Bid4  : TOptHoga;

    Ask5  : TOptHoga;
    Bid5  : TOptHoga;

    AskTotVolume : array [0..6] of char;
    AskTotCnt    : array [0..4] of char;
    BidTotVolume : array [0..6] of char;
    BidTotCnt    : array [0..4] of char;

    MarketStat  : array [0..1] of char;    // 40 ����
  end;


  POptionGreeks = ^TOptionGreeks;
  TOptionGreeks = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..6]  of char;
    Date  : array [0..7]  of char;
    Time  : array [0..7]  of char;
    cDiv  : char;         // 1: ����Ȯ��, 2: ���߻���, 3: ����Ȯ��, E: ���߿Ϸ�
    UnderID : array [0..2]  of char;    // K2I

    DeltaSign : char;
    Delta : array [0..17] of char;     // 100000000000.000000
    ThetaSign : char;
    Theta : array [0..17] of char;     // 100000000000.000000
    VegaSign  : char;
    Vega  : array [0..17] of char;     // 100000000000.000000
    GammaSign : char;
    Gamma  : array [0..17] of char;    // 100000000000.000000
    RhoSign : char;
    Rho : array [0..17] of char;
  end;

  PInvestorData = ^TInvestorData;
  TInvestorData = packed record
    Date  : array [0..7]  of char;
    Time  : array [0..5]  of char;
    DataType : array[0..1] of char;
    PrtID : array[0..9] of char;
    cCP : char;
    InvestType : array[0..3] of char;  // ���� : 8000, �ܱ��� : 9000, ����ȸ�� : 1000, ����ȸ�� : 1200, �ڻ���ȸ�� :3000, ���� : 4000, ���� : 5000, ��,��� : 6000
    BidQty : array[0..8] of char;
    AskQty : array[0..8] of char;
    BidAmount : array[0..17] of char;
    AskAmount : array[0..17] of char;
    EndText : char;
  end;


  ////////////////////////////�Ļ�������///////////////////////////////////
  PDerMaster = ^TDerMaster;
  TDerMaster =  record
     datatype : array[0..4] of char;                          //�����ͱ��� A0015 : �ֽļ���, A0014 : ��������, A0034 : �����ɼ�
     listingqty : array[0..4] of char;                        //�����
     calldate : array[0..7] of char;                          //��������
     code : array[0..11] of char;                             //�����ڵ�
     seq : array[0..5] of char;                               //���� SEQ
     prdID : array[0..9] of char;                             //�Ļ���ǰID(��ǰ�����ڵ�)
     shortcode : array[0..8] of char;                         //�������� �����ڵ�
     korname : array[0..79] of char;                          //�ѱ������
     shortdesc : array[0..39] of char;                        //�����ѱ۾��
     engname : array[0..79] of char;                          //���������
     shortengname : array[0..39] of char;                     //���񿵹����
     listingdate : array[0..7] of char;                       //������
     listclosedate : array[0..7] of char;                     //������������
     spreadcode : char;                                       //��������������񱸺��ڵ�   F:��������, N:�ٿ�����
     settlecode : char;                                       //������������ڵ�   C:���ݰ���, D:�ǹ��μ�������
     signhigh : char;                                         //Sign ��ȣ
     highlimit : array[0..11] of char;                        //���Ѱ�
     signlow : char;                                          //Sign ��ȣ
     lowlimit : array[0..11] of char;                         //���Ѱ�
     baseprice : array[0..11] of char;                        //���ذ�
     underlyID : array[0..2] of char;                         //�����ڻ�ID
     rightcode : char;                                        //�Ǹ���������ڵ�  A:�̱���,E:������,Z:��Ÿ
     spreadtypecode : array[0..1] of char;                    //�������������ڵ�
     spnareprdtID : array[0..11] of char;                     //�������� �ٿ��� ǥ���ڵ�
     spfarprdtID : array[0..11] of char;                      //�������� ������ ǥ���ڵ�
     lasttradedate : array[0..7] of char;                     //�����ŷ���
     lastsettledate : array[0..7] of char;                    //������������
     monthcode : char;                                        //���������ڵ� 1:�ֱٿ���,������������ 2:2°���� 3:3°���� 4:4°���� 5:5°���� 6:6°���� 7:7°����
     maturitydate : array[0..7] of char;                      //��������
     strikeprice : array[0..16] of char;                      //��簡��
     adjusttype : char;                                       //��������  C:�ŷ���������, N:��������, O:�̰�������
     priceunit : array[0..16] of char;                        //�ŷ�����   1��࿡ �ش��ϴ� �����ڻ���� (3�ⱹä����:1���, �޷�����:5���޷�, ������:5�鸸��)
     priceunits : array[0..20] of char;                       //�ŷ��¼�   ������� �� ������ ����ϴ� ���¼� (KOSPI200����:50��, KOSPI200�ɼ�:10��,  ��ä����:100��, CD����:125��)
     ismarketmakeissue : char;                                //�������������ڵ�
     listingcode : char;                                      //���������ڵ�
     atm : array[0..11] of char;                              //���
     adjustcode : array[0..1] of char;                        //���������ڵ�
     underlyingcode : array[0..11] of char;                   //�����ڻ������ڵ�
     underlyingclose : array[0..11] of char;                  //�����ڻ�����
     remdays : array[0..6] of char;                           //�����ϼ�
     adjustprice : array[0..16] of char;                      //�������ذ���
     basepricecode : array[0..1] of char;                     //���ذ��ݱ����ڵ�
     tradebasepricecode : char;                               //�Ÿſ���ذ��ݱ����ڵ�
     signclose : char;                                        //sign ��ȣ
     prevaclose : array[0..16] of char;                       //������������
     isblocktrade : char;                                     //���Ǵ뷮�ŸŴ�󿩺�
     prevdeposit : array[0..16] of char;                      //�������űݱ��ذ���
     prevdepositcode : array[0..1] of char;                   //�������űݱ��ذ��ݱ����ڵ�
     thprice : array[0..14] of char;                          //�̷а���(���갡)
     thpricebase : array[0..14] of char;                      //�̷а���(���ذ�)
     prevadjustprice : array[0..16] of char;                  //���� ���갡��
     istradestop : char;                                      //�ŷ���������
     cbhigh : array[0..11] of char;                           //C.B. ���� ���Ѱ�
     cblow : array[0..11] of char;                            //C.B. ���� ���Ѱ�
     sstrikeprice : array[0..16] of char;                     //��ȸ����簡��
     isatm : char;                                            //ATM����
     islasttradedate : char;                                  //�����ŷ��� ����
     prevdividendrate : array[0..14] of char;                 //�������갡�ݿ��簡ġ
     signprevclose : char;                                    //sign ��ȣ
     prevclose : array[0..11] of char;                        //���� ����
     prevcolsetype : char;                                    //���� ���� ����
     signprevopen : char;                                     //sign ��ȣ
     prevopen : array[0..11] of char;                         //���� �ð�
     signprevhigh : char;                                     //sign ��ȣ
     prevhigh : array[0..11] of char;                         //���� ����
     signprevlow : char;                                      //sign ��ȣ
     prevlow : array[0..11] of char;                          //���� ����
     settledate : array[0..7] of char;                        //����ü������
     prevsettletime : array[0..7] of char;                    //��������ü��ð�
     prevadjustpricetype : array[0..1] of char;               //���� ���갡�� ����
     signdisparateratio : char;                               //sign ��ȣ
     disparateratio : array[0..11] of char;                   //���갡���̷а��ݱ�����
     prevopenpositions : array[0..9] of char;                 //���� �̰�����������
     signbid : char;                                          //sign ��ȣ
     prevbidprice : array[0..11] of char;                     //���ϸŵ��켱ȣ������
     signask : char;                                          //sign ��ȣ
     prevaskprice : array[0..11] of char;                     //���ϸż��켱ȣ������
     previv : array[0..9] of char;                            //���纯����
     underlyivcode : char;                                    //�����ڻ��ִ뺯���������ڵ�
     underlyiv : array[0..5] of char;                         //�����ڻ��ִ뺯����
     signlisthigh : char;                                     //sing ��ȣ
     listhigh : array[0..11] of char;                         //������ �ְ���
     signlistlow : char;                                      //sing ��ȣ
     listlow : array[0..11] of char;                          //������ ������
     signyearhigh : char;                                     //sing ��ȣ
     yearhigh : array[0..11] of char;                         //�����ְ���
     signyearlow : char;                                      //sing ��ȣ
     yearlow : array[0..11] of char;                          //����������
     listhighdate : array[0..7] of char;                      //������ �ְ��� ����
     listlowdate : array[0..7] of char;                       //������ ������ ����
     yearhighdate : array[0..7] of char;                      //���� �ְ��� ����
     yearlowdate : array[0..7] of char;                       //���� ������ ����
     yearbaseday : array[0..7] of char;                       //���������ϼ�
     monthtradeday : array[0..7] of char;                     //�����ŷ��ϼ�
     yeartradeday : array[0..7] of char;                      //�����ŷ��ϼ�
     prevfillunit : array[0..15] of char;                     //����ü��Ǽ�
     prevfillqty : array[0..11] of char;                      //����ü�����
     prevamt : array[0..21] of char;                          //���ϰŷ����
     blocktradeqty : array[0..11] of char;                    //�������Ǵ뷮�Ÿ�ü�����
     blocktradeamt : array[0..21] of char;                    //�������Ǵ뷮�ŸŰŷ����
     cdrate : array[0..5] of char;                            //cd�ݸ�
     unsettledmaxcon : array[0..7] of char;                   //�̰��� �ѵ� ����
     attachedprdt : array[0..3] of char;                      //�Ҽ� ��ǰ��
     prdtoptrate : array[0..4] of char;                       //��ǰ�� �ɼ���
     hogatype : char;                                         //������ȣ�����Ǳ����ڵ�
     mhogatype : char;                                        //���尡ȣ�����Ǳ����ڵ�
     chogatype : char;                                        //���Ǻ�������ȣ�����Ǳ����ڵ�
     ahogatype : char;                                        //������������ȣ�����Ǳ����ڵ�
     filler : array[0..169] of char;
     endtext : char;
  end;

  pSTMaster = ^TStockMaster;
  TStockMaster = record
    datatype : array[0..4] of char;                           //�����ͱ���(A0)
    code : array[0..11] of char;                              //ǥ���ڵ�
    seqno : array[0..7] of char;                              //�Ϸù�ȣ
    shortcode : array[0..8] of char;                          //�����ڵ�
    korname : array[0..39] of char;                           //�����̸�
    engname : array[0..39] of char;                           //�����̸�(����)
    calldate : array[0..7] of char;                           //��������
    infoGroupNo : array[0..4] of char;                        //�����й�׷��ȣ
    groupID : array[0..1] of char;                            //���Ǳ׷�ID
    isunitfill : char;                                        //�����Ÿ�ü�Ῡ��
    rocktype : array[0..1] of char;                           //�ǹ�� ����
    facevaluechange : array[0..1] of char;                    //�׸鰡���汸���ڵ�
    isopenbase : char;                                        //�ð����ذ������񿩺�
    retryCode : array[0..1] of char;                          //������������ڵ�
    isbaseprice : char;                                       //���ذ��ݺ������񿩺�
    isEnd : char;                                             //�������ᰡ�ɿ���
    isWarn : char;                                            //����溸���迹������
    Warncode : array[0..1] of char;                           //����溸�����ڵ�
    isStruct : char;                                          //���豸���췮����
    isadmin : char;                                           //�������񿩺�
    isannounce : char;                                        //�Ҽ��ǰ�����������
    isbackdoorlist : char;                                    //��ȸ���忩��
    istradestop : char;                                       //�ŷ���������
    indexbigcode : array[0..2] of char;                       //����������з��ڵ�
    indexmidcode : array[0..2] of char;                       //���������ߺз��ڵ�
    indexsmallcode : array[0..2] of char;                     //���������Һз��ڵ�
    inducode : array[0..5] of char;                           //ǥ�ػ���ڵ�
    kospiindu : char;                                         //KOSPI200 ���ξ���
    AVOLSsizecode : char;                                     //�ð��ѾױԸ��ڵ�
    ismanufact : char;                                        //(����)����������
    isKrx100 : char;                                          //KRX100���񿩺�
    isindexissue : char;                                      //(����)����������񿩺�
    isstructissue : char;                                     //(����)���豸���������񿩺�
    investcode : array[0..1] of char;                         //���ڱⱸ�����ڵ�
    isKospi : char;                                           //(����)KOSPI����
    isKospi100 : char;                                        //(����)KOSPI100����
    isKospi50 : char;                                         //(����)KOSPI50����
    isKrxauto : char;                                         //KRX���������ڵ�������
    isKrxsemi :char;                                          //KRX���������ݵ�ü����
    isKrxbio : char;                                          //KRX�����������̿�����
    isKrxfin : char;                                          //KRX����������������
    isKrxinfo : char;                                         //KRX��������������ſ���
    isKrxenergy : char;                                       //KRX��������������ȭ�п���
    isKrxsteel : char;                                        //KRX��������ö������
    isKrxproduct : char;                                      //KRX���������ʼ��Һ��翩��
    isKrxmedia : char;                                        //KRX���������̵����ſ���
    isKrxcons : char;                                         //KRX���������Ǽ�����
    isKrxfinservice : char;                                   //KRX���������������񽺿���
    isKrxstock : char;                                        //KRX�����������ǿ���
    isKrxvess : char;                                         //KRX�����������ڿ���
    baseprice : array[0..8] of char;                          //���ذ�
    prevclosetype : char;                                     //�������������ڵ�
    prevclose : array[0..8] of char;                          //���� ����
    prevvol : array[0..11] of char;                           //���ϰŷ���
    prevamount : array[0..17] of char;                        //���ϰŷ����
    highlimit : array[0..8] of char;                          //���Ѱ�
    lowlimit : array[0..8] of char;                           //���Ѱ�
    subprice : array[0..8] of char;                           //��밡��
    facevalue : array[0..11] of char;                         //�׸鰡
    strikeprice : array[0..8] of char;                        //���డ
    listdate : array[0..7] of char;                           //������
    listshares : array[0..14] of char;                        //�����ֽļ�
    isclear : char;                                           //�����Ÿſ���
    epssign : char;                                           //�ִ������(EPS)��ȣ
    epsprofit : array[0..8] of char;                          //�ִ������(EPS)
    persign : char;                                           //�ְ�������(PER)��ȣ
    perprofit : array[0..5] of char;                          //�ְ�������(PER)
    epstype : char;                                           //�ִ�����ͻ������ܿ���
    bpssign : char;                                           //�ִ���ڻ갡ġ(BPS)��ȣ
    bpsvalue : array[0..8] of char;                           //�ִ���ڻ갡ġ(BPS)
    pbrratesign : char;                                       //�ִ���ڻ����(PBR)��ȣ
    pbrrate : array[0..5] of char;                            //�ִ���ڻ����(PBR)
    bpstype : char;                                           //�ִ���ڻ갡ġ�������ܿ���
    isloss : char;                                            //��տ���
    dividendprice : array[0..7] of char;                      //�ִ���ݾ�
    isdividend : char;                                        //�ִ���ݾ׻������ܿ���
    dividendrate : array[0..6] of char;                       //��������
    existsdate : array[0..7] of char;                         //������������
    existedate : array[0..7] of char;                         //������������
    strikesdate : array[0..7] of char;                        //���Ⱓ��������
    stirkeedate : array[0..7] of char;                        //���Ⱓ��������
    elwstrikeprice : array[0..11] of char;                    //ELW�����μ������� ��簡��
    capital : array[0..20] of char;                           //�ں���
    iscreditorder : char;                                     //�ſ��ֹ����ɿ���
    limitcode : char;                                         //������ȣ�����Ǳ����ڵ�
    marketcode : char;                                        //���尡ȣ�����Ǳ����ڵ�
    conditionlimitcode : char;                                //���Ǻ�������ȣ�����Ǳ���
    bestcode : char;                                          //������������ȣ�����Ǳ���
    firstcode : char;                                         //�ֿ켱������ȣ�����Ǳ���
    incapital : array[0..1] of char;                          //���ڱ����ڵ�
    firststockcode : char;                                    //�켱�ֱ����ڵ�
    ispeople : char;                                          //�����ֿ���
    estimateprice : array[0..8] of char;                      //�򰡰���
    lowhoga : array[0..8] of char;                            //����ȣ������
    highhoga : array[0..8] of char;                           //�ְ�ȣ������
    tradeunit : array[0..4] of char;                       //������Ÿż�������
    overtradeunit : array[0..4] of char;                      //�ð��ܸŸż�������
    ritscode : char;                                          //���������ڵ�
    objectrigthcode : array[0..11] of char;                   //�����ֱ��ڵ�
    etfmarketcode : char;                                     //ETF��������Ҽӽ��屸��
    etfupcode : array[0..2] of char;                          //ETF������������ڵ�
    etfhares : array[0..9] of char;                           //ETF�����ֽļ�
    etfdnetasset : array[0..14] of char;                      //ETF������ڻ��Ѿ�
    etfnetasset : array[0..14] of char;                       //ETF���ڻ��Ѿ�
    etflastnetasset : array[0..8] of char;                    //ETF�������ڻ갡ġ
    etfdnetassetf : array[0..14] of char;                     //ETF��ȭ������ڻ��Ѿ�(��ȭ)
    etfnetassetf : array[0..14] of char;                      //ETF��ȭ���ڻ��Ѿ�
    etflastnetassetf : array[0..8] of char;                   //ETF��ȭ�������ڻ갡ġ
    etftypecode : char;                                       //ETF�����ڵ�
    etfcuqty : array[0..7] of char;                           //ETF CU����
    etfissueqty : array[0..3] of char;                        //ETF���������
    etfindexchgrate : array[0..10] of char;                   //ETF��������������
    isocode : array[0..2] of char;                            //��ȭISO�ڵ�
    nationcode : array[0..2] of char;                         //�����ڵ�
    isLP : char;                                              //LP�ֹ����ɿ���
    isovertime : char;                                        //�ð��ܸŸŰ��ɿ���
    isovertimelast : char;                                    //�尳�����ð����������ɿ���
    isovertimelarge : char;                                   //�尳�����ð��ܴ뷮�ŸŰ���
    isovertimebasket : char;                                  //�尳�����ð��ܹٽ��ϰ���
    isestimatefill : char;                                    //����ü�ᰡ��������
    isshort : char;                                           //���ŵ����ɿ���
    filler : array[0..14] of char;                            //FILLER
    endtext : char;                                           //end
  end;


  /////////////////////////////ELW������///////////////////////////////////////
  pElwMaster = ^TElwMaster;
  TElwMaster = packed record
    datatype : array[0..4] of char;                           //�����ͱ���(A1)
    code : array[0..11] of char;                              //ǥ���ڵ�
    seqno : array[0..7] of char;                              //�Ϸù�ȣ
    elwlpkorname : array[0..79] of char;                      //ELW��������������ѱ۸�
    elwlpengname : array[0..79] of char;                      //ELW������������ڿ�����
    elwlpkorno : array[0..4] of char;                         //ELW������������ڹ�ȣ
    elwund1 : array[0..11] of char;                           //ELW�����ڻ�
    elwund2 : array[0..11] of char;                           //ELW�����ڻ�
    elwund3 : array[0..11] of char;                           //ELW�����ڻ�
    elwund4 : array[0..11] of char;                           //ELW�����ڻ�
    elwund5 : array[0..11] of char;                           //ELW�����ڻ�
    elwundrate1 : array[0..11] of char;                       //ELW�����ڻ걸����
    elwundrate2 : array[0..11] of char;                       //ELW�����ڻ걸����
    elwundrate3 : array[0..11] of char;                       //ELW�����ڻ걸����
    elwundrate4 : array[0..11] of char;                       //ELW�����ڻ걸����
    elwundrate5 : array[0..11] of char;                       //ELW�����ڻ걸����
    elwundmarket : char;                                      //ELW�����ڻ���屸���ڵ�
    elwindexcode : array[0..2] of char;                       //ELW���������ڵ�
    elwoptioncode : char;                                     //ELW�Ǹ������ڵ� C:�� E:��Ÿ P:ǲ
    elwoptiontypecode : char;                                 //ELW�Ǹ���������ڵ�
    elwsettletype : char;                                     //ELW������������ڵ�
    elwclosingdate : array[0..7] of char;                     //ELW�����ŷ���
    elwpayday : array[0..7] of char;                          //ELW������
    elwundprice : array[0..11] of char;                       //ELW�����ڻ���ʰ���
    elwoptioncontent : array[0..199] of char;                 //ELW�Ǹ���系��
    elwconvratio : array[0..11] of char;                      //ELW��ȯ����
    elwpriceup : array[0..7] of char;                         //ELW���ݻ��������
    elwindemnity : array[0..7] of char;                       //ELW������
    elwpayable : array[0..20] of char;                        //ELWȮ�����޾�
    elwpayagent : array[0..79] of char;                       //ELW���޴븮��
    elwestimateprice : array[0..199] of char;                 //ELW�����򰡰��ݹ��
    elwotypecode : char;                                      //ELW�̻��ɼǱ����ڵ�
    elwlpqty : array[0..14] of char;                          //ELWLP��������
    filler : array[0..8] of char;                             //FILLER
    endtext : char;                                           //end text
  end;


  /////////////////////////////LP������///////////////////////////////////////
  pLpMaster = ^TLpMaster;
  TLpMaster = packed record
    datatype : array[0..4] of char;                           //�����ͱ���(A1)
    code : array[0..11] of char;                              //ǥ���ڵ�
    seqno : array[0..7] of char;                              //�Ϸù�ȣ
    lpno : array[0..4] of char;                               //���������ڹ�ȣ
    lpsdate : array[0..7] of char;                            //LP��������
    lpedate : array[0..7] of char;                            //LP��������
    minqty : array[0..10] of char;                            //�ּ�ȣ���������
    maxqty : array[0..10] of char;                            //�ִ�ȣ���������
    limitcode : char;                                         //���Ѵ��������ڵ�
    spreadvalue : array[0..20] of char;                       //ȣ���������尪
    restspreadvalue : array[0..20] of char;                   //����ȣ���������尪
    dutyhoga : array[0..5] of char;                           //�ǹ�ȣ������ð�����
    filler : array[0..8] of char;                             //FILLER
    endtext : char;                                           //end text
  end;

  PSettleDayMaster = ^TSettleDayMaster;
  TSettleDayMaster = packed record
    datatype : array[0..4] of char;                           //�����ͱ���(A1)
    code : array[0..11] of char;                              //ǥ���ڵ�
    seqno : array[0..7] of char;                              //�Ϸù�ȣ
    settleday : array [0..3] of char;                         // 1231, 0630, 0331
  end;



const
  LenSymbolHeader = 5;
  LenCommonHeader = sizeof( TCommonHeader );
  LenStockFutPrice  = sizeof( TStockFutPrice );
  LenStockFutTick   = sizeof( TStockFutTick );
  LenStockFutTickPrice  = sizeof( TStockFutTickPrice ) ;
  LenFutPrice = sizeof( TFutPrice );
  LenFutTick  = sizeof( TFutTick );
  LenFutTickPrice = sizeof( TFutTickPrice );
  LenOptPrice = sizeof( TOptPrice );
  LenOptTick = sizeof( TOptTick );
  LenOptTickPrice = sizeof( TOptTickPrice );
  LenStockPrice  = sizeof( TStockPrice );
  LenElwPrice = sizeof( TElwPrice );
  LenStockTick  = sizeof( TStockTick );
  LenIndex  = sizeof( TIndexData );
  LenExpectIndex = sizeof( TIndexExpectData );
  LenElwGreeks  = sizeof( TElwGreeks );
  LenCP_PPIndexData = sizeof( TCP_PPIndexData );
  LenFutOpenInterest = sizeof( TFutOpenInterest );
  LenOptOpenInterest = sizeof( TOptOpenInterest );
  LenOptRecovery     = sizeof( TOptSisRecovery );
  //
  LenOptionGreeks = sizeof( TOptionGreeks );
  LenInvestorData = sizeof( TInvestorData );
  LenDerMaster  = sizeof( TDerMaster );
  LenStockMaster= sizeof( TStockMaster );
  LenElwMaster  = sizeof( TElwMaster );


implementation


end.