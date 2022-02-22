unit UPaveConfig;

interface

uses
  SysUtils, CleAccounts
  ;

const
  RETRY_CNT = 60;
  Tot_Cnt = 3;

type

  TSAREvent = procedure( Sender : TObject; Value : integer ) of Object;
  TZPDTState = ( zsNone, zsOrder, zsPosOK, zsReEntryReady, zsReEntry );

  TPaveData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OrdCnt  : integer;      // �ֹ�����
    AskHoga : integer;      // ����ȣ��
    BidHoga : integer;      // ����ȣ��
    Profit  : integer;
    UseAutoLiquid : boolean;
    LiquidTime : TDateTime;
    // add by 20140425
    MaxNet  : integer;
    LCNet   : integer;
    LiqOTE  : integer;
  end;

  THultData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    RiskAmt : double;
    LiquidTime    : TDateTime;
    QuotingQty : integer;
    UseBetween : boolean;
    SPos : integer;         //���̻��� ���� ���� �����Ǽ���
    EPos : integer;         //���̻��� ���� ���� �����Ǽ���
    STick : integer;
    UsePause : boolean;
    UsePlatoon : boolean;   // �÷��� �ý��� add 2019.01.20
    StartTime : TDateTime;
  end;

  THultCompData = record
    OrdQty : integer;
    Period : integer;
    AFValue: double;
    Tick   : integer;
    UseLsCut : boolean;
    UseTime  : boolean;
    DivVal   : integer;
  end;

  TPrevHLParam = record
    Qty : integer;
    LossCutTick : integer;
    StartTime, EndTime : TDateTime;
    EntrySec : integer;
    LiqSec   : integer;
    Period   : integer;
    MoveTick : integer;
    ProfitTick : integer;
    function  GetDesc : string;
  end;


  THultOptData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    QuotingQty : integer;
    OptPrice : double;
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    RiskAmt : double;
    LiquidTime    : TDateTime;
    CallPut : integer;
  end;

  TBHultData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OrdCnt  : integer;      // �ֹ�ȸ��
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    LiquidTime    : TDateTime;
    RiskAmt : double;
    ProfitAmt : double;
    ClearPos : integer;
    // only ex use
    TargetPos : integer;
    AfValue   : double;
  end;

  TJarvisData = record
    // �⺻
    OrdQty  : integer;      // �ֹ�����
    OrdCnt  : integer;      // �ֹ�ȸ��
    UseStopLiq  : boolean;
    LiskAmt     : double;
    // ����
    MarketDiv : integer;      // 0 : ����   1 : �ɼ�
    SubMakDiv : integer;      // 0 : ����   1 : �̴�
    UseBuy    : boolean;
    BelowPrc  : double;
    // ����
    //EntUseAnd : boolean;
    UseEntCntRate , UseEntForeignQty, UseEntPoint : boolean;
    CntRate , Point1, Point2 : double;
    ForeignQty : integer;
    // û��
    LiqUseAnd : boolean;
    UseLiqCntRate , UseLiqForeignQty, UseLiqPoint : boolean;
    LiqCntRate , LiqForeignPer, LiqPoint : double;
    //
    StartTime, EndTime : TDateTime;
  end;

  TJarvisData2 = record
    // �⺻
    OrdQty  : integer;      // �ֹ�����
    ParaVal : double;

    // 20190323 ���� �߰�
    UseEntryCnt : boolean;
    UseEntryVol : boolean;
    UseEntryPara: boolean;
    //

    // ����
    EntryCnt  : double;
    EntryVol  : double;   // 20190323 �ܷ��� �߰�
    PrfPoint  : double;
    PrfPoint2 : double;   // 20190323 �߰�
    PrfCnt    : double;
    PrfCntRate: integer;
    // 20180406 j �� ��û���� ��Ż�� ����
    LimitNum  : integer; // �ֹ� ȸ�� ����
    //LimitNum  : array [0..1] of integer; // �ֹ� ȸ�� ����
    UseOne    : boolean;

    LosCnt    : double;
    LosCntRate: integer;
    //
    LiskAmt   : integer;
    PlusAmt   : integer;
    StartTime, EndTime : TDateTime;

    // 20190515 �߰� ����
    UseProfCnt, UseProfPara : boolean;
    UseLossCnt, UseLossPara : boolean;

    // 20191104 �߰�
    UseProfVol, UseLossVol : boolean;
    LosVol ,    PrfVol : double;
    LosVolRate, PrfVolRate : integer;
  end;

  TBHultOptData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OptPrice : double;
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    LiquidTime    : TDateTime;
    RiskAmt : double;
    ProfitAmt : double;
    Band : double;
    Term : integer;
    StartTime : TDateTime;
    HultAccount : TAccount;
    HultPL : double;
    AddEntry : double;
    AddEntryCnt : integer;
    QtyDiv : integer;
    HultGap : integer;
    HultCalS : boolean;
  end;

  TZombiPDT = record
    Below, Above : double;

    FstStartTime : TDateTime;
    FstLiquidTime: TDateTime;

    OrdReCount : integer;  // �ֹ� ȸ��
    AscIdx : integer; // 0 : ��������  , 1 : ��������

    EntryAmt : string;
    dEntryAmt: double;
    InitQty: integer;
    AddQty : integer;
    RiskAmt : double;
    DecAmt  : double;
    MarginAmt : double;
    PLAmt     : double;
    PLAbove   : double;
    LiqPer  : integer;

    ToVal : array of double;
    FromVal : array of double;
    EntVal : array of double;
    Ordered: array of boolean;
    TermCnt : integer;

    UseTargetQty : boolean;
    UseTerm      : boolean;
    UseFut       : boolean;
    UseOptSell   : boolean;
    UseVer2      : boolean;
    UseVer2R     : boolean;

    EntryMode     : integer;
    UseFixPL      : boolean;
    //

  end;

  TShortHultData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    LiquidTime    : TDateTime;
    RiskAmt : double;
    ProfitAmt : double;
    QtyLimit  : integer;
    ClearPos : integer;
    UseAPI : boolean;
    SPoint : double;
  end;

  TJikJinHultData = record
    StartTime, EndTime : TDateTime;

    OrdQty  ,
    OrdGap  ,
    LiqNum  : integer;

    UseCntRatio,
    UseVolRatio,
    UseDefTick : boolean;

    UseOpenPrc : boolean; // deftick �� �ð� ���� or start �������� �������� ����...

    UseStopLiq : boolean;

    CntRatio, VolRatio : double;
    DefTick : integer;

    RiskAmt : double;
    PlusAmt : double;

  end;


implementation

{ TPrevHLParam }

function TPrevHLParam.GetDesc: string;
begin
  Result := Format( 'Qty:%d, EntrySec:%d, LiqSec:%d, LossTick:%d, Cnt:%d, Period:%d ',
    [ Qty, EntrySec, LiqSec, LossCutTick, MoveTick, Period ]);
end;

end.