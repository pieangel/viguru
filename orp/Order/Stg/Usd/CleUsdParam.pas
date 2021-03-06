unit CleUsdParam;

interface

type
  TUsdH1_1Min_Param = record
    OrdQty   : integer;
    EntryCnt   : integer;
    E_L, E_S : double;
    L1_L, L1_S : double;
    EntPer  : double;
    UseTrailingStop : boolean;
    StopMax, StopPer : integer;

    Endtime : TDateTime;
    EntTime   , EntEndtime : TDateTime;

    UseTotVol : boolean;
    UseStopLiq: boolean;
    StgIdx : integer;
    // add 20191127
    E_L2, E_S2 : double;
    L1_L2, L1_S2 : double;

    UseEntCnt, UseEntVol : boolean;
    UseLossCnt, UseLossVol : boolean;
  end;

  TUsdH2_5Min_Param = record
    OrdQty  : integer;
    E_1, E_2 : double;
    R_1      : double;
    L_1, L_2 : double;
    BongStart, BongEnd : integer;
    StartTime , Endtime : TDateTime;
    EntTime   , EntEndtime : TDateTime;
    LiqStTime , LiqEndTime : TDateTime;
    UseStopLiq: boolean;
    UseEntFillter : boolean;
  end;

  TUs_In_123_Param = record
    OrdQty   : integer;
    EntryCnt   : integer;
    UseEntFillter : boolean;
    UseEntFillter2: boolean;
    E_L, E_S : double;
    L1_L, L1_S : double;
    L2_L, L2_S : double;

    UseTrailingStop : boolean;
    UseSecondLiqCon : boolean;
    StopMax, StopPer : integer;

    Endtime : TDateTime;
    EntTime   , EntEndtime : TDateTime;
    UseStopLiq: boolean;

    // add by 20191125
    UseVolFillter : boolean;
    CntFillter : double;
    VolFillter : double;

    UseLossVolFillter : boolean;
    LossVolFillter    : double;
  end;

  TUs_I2_Param = record
    OrdQty     : integer;
    EntryCnt   : integer;
    ChanelIdx  : integer;

    Endtime : TDateTime;
    EntTime   , EntEndtime : TDateTime;
    // 장시작시간.
    MKStartTime : TDateTime;

    ATRLiqTime  : TDateTime;
    CalcCnt     : integer;
    ATRMulti    : integer;
    TermCnt     : integer;

    UseStopLiq: boolean;
    StgIndex  : integer;
  end;

  {
    dtEnd.Time      := aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time );
  dtEntStart.Time := aStorage.FieldByName('EntStartTime').AsTimeDef( dtEntStart.Time );
  dtEntEnd.Time   := aStorage.FieldByName('EntEndTime').AsTimeDef( dtEntEnd.Time );
  dtLiqStart.Time := aStorage.FieldByName('LiqStart').AsTimeDef( dtLiqStart.Time );

  edtOrdQty.Text  := aStorage.FieldByName('OrdQty').AsStringDef( edtOrdQty.Text );
  edtOrdQty.Text  := aStorage.FieldByName('EntryCnt').AsStringDef( edtOrdQty.Text );

  edtE_C.Text     := aStorage.FieldByName('E_C').AsStringDef( edtE_C.Text );
  edtE_S.Text     := aStorage.FieldByName('E_S').AsStringDef( edtE_S.Text );
  edtEntPer.Text  := aStorage.FieldByName('EntPer').AsStringDef( edtEntPer.Text );

  cbStopLiq.Checked := aStorage.FieldByName('UseStopLiq').AsBooleanDef( true );
  }

  TUs_Comp = record
    Endtime, LiqStartTime : TDateTime;
    EntStartTime   , EntEndtime : TDateTime;

    OrdQty     : integer;
    EntryCnt   : integer;

    E_C, E_S, EntPer : double;

    UseStopLiq: boolean;
  end;

implementation

end.
