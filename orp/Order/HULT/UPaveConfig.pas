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
    OrdQty  : integer;      // 주문수량
    OrdGap  : integer;      // 주문간격
    OrdCnt  : integer;      // 주문범위
    AskHoga : integer;      // 시작호가
    BidHoga : integer;      // 시작호가
    Profit  : integer;
    UseAutoLiquid : boolean;
    LiquidTime : TDateTime;
    // add by 20140425
    MaxNet  : integer;
    LCNet   : integer;
    LiqOTE  : integer;
  end;

  THultData = record
    OrdQty  : integer;      // 주문수량
    OrdGap  : integer;      // 주문간격
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    RiskAmt : double;
    LiquidTime    : TDateTime;
    QuotingQty : integer;
    UseBetween : boolean;
    SPos : integer;         //사이사이 쿼팅 시작 포지션수량
    EPos : integer;         //사이사이 쿼팅 빼기 포지션수량
    STick : integer;
    UsePause : boolean;
    UsePlatoon : boolean;   // 플래툰 시스템 add 2019.01.20
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
    OrdQty  : integer;      // 주문수량
    OrdGap  : integer;      // 주문간격
    QuotingQty : integer;
    OptPrice : double;
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    RiskAmt : double;
    LiquidTime    : TDateTime;
    CallPut : integer;
  end;

  TBHultData = record
    OrdQty  : integer;      // 주문수량
    OrdGap  : integer;      // 주문간격
    OrdCnt  : integer;      // 주문회수
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
    // 기본
    OrdQty  : integer;      // 주문수량
    OrdCnt  : integer;      // 주문회수
    UseStopLiq  : boolean;
    LiskAmt     : double;
    // 종목
    MarketDiv : integer;      // 0 : 선물   1 : 옵션
    SubMakDiv : integer;      // 0 : 지수   1 : 미니
    UseBuy    : boolean;
    BelowPrc  : double;
    // 진입
    //EntUseAnd : boolean;
    UseEntCntRate , UseEntForeignQty, UseEntPoint : boolean;
    CntRate , Point1, Point2 : double;
    ForeignQty : integer;
    // 청산
    LiqUseAnd : boolean;
    UseLiqCntRate , UseLiqForeignQty, UseLiqPoint : boolean;
    LiqCntRate , LiqForeignPer, LiqPoint : double;
    //
    StartTime, EndTime : TDateTime;
  end;

  TJarvisData2 = record
    // 기본
    OrdQty  : integer;      // 주문수량
    ParaVal : double;

    // 20190323 조건 추가
    UseEntryCnt : boolean;
    UseEntryVol : boolean;
    UseEntryPara: boolean;
    //

    // 조건
    EntryCnt  : double;
    EntryVol  : double;   // 20190323 잔량비 추가
    PrfPoint  : double;
    PrfPoint2 : double;   // 20190323 추가
    PrfCnt    : double;
    PrfCntRate: integer;
    // 20180406 j 의 요청으로 토탈로 수정
    LimitNum  : integer; // 주문 회수 제한
    //LimitNum  : array [0..1] of integer; // 주문 회수 제한
    UseOne    : boolean;

    LosCnt    : double;
    LosCntRate: integer;
    //
    LiskAmt   : integer;
    PlusAmt   : integer;
    StartTime, EndTime : TDateTime;

    // 20190515 추가 변수
    UseProfCnt, UseProfPara : boolean;
    UseLossCnt, UseLossPara : boolean;

    // 20191104 추가
    UseProfVol, UseLossVol : boolean;
    LosVol ,    PrfVol : double;
    LosVolRate, PrfVolRate : integer;
  end;

  TBHultOptData = record
    OrdQty  : integer;      // 주문수량
    OrdGap  : integer;      // 주문간격
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

    OrdReCount : integer;  // 주문 회수
    AscIdx : integer; // 0 : 오름차순  , 1 : 내림차순

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
    OrdQty  : integer;      // 주문수량
    OrdGap  : integer;      // 주문간격
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

    UseOpenPrc : boolean; // deftick 을 시가 기준 or start 눌렀을때 기준으로 할지...

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
