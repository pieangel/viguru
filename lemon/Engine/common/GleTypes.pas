unit GleTypes;

interface

uses
  Messages;

type
    // notify events
  TTextNotifyEvent = procedure(Sender: TObject; Value: String) of object;
  TDateNotifyEvent = procedure(Sender: TObject; Value: TDateTime) of object;
  TTimeNotifyEvent = procedure(Sender: TObject; Value: TDateTime) of object;
  TResultNotifyEvent  = procedure(Sender: TObject; Value : boolean ) of object;
  TDateTimeNotifyEvent = procedure(Sender: TObject; Value: TDateTime) of object;
  TObjectNotifyEvent = procedure(Sender: TObject; Value: TObject) of object;
  TOrderResetEvent  = procedure( Sender : TObject; bBack : boolean; Value : Integer ) of object;
  TOrderNoEvent = procedure of object;
  TArbEndEvent = procedure( Value : TObject ) of object;
  TDateQueryEvent = function(Sender: TObject; Value: TDateTime): Boolean of object;
  TTrendDataNotifyEvent = procedure( Sender : TObject; stData : string; iDiv : integer ) of Object;
  TStopEvent = procedure( Value : boolean ) of object;

  TAppStatus = ( asNone, asInit, asConMaster, asReqSymbolCode, asReqSymbolMaster, asConFut, asRecoveryStart, asRecoveryEnd, asStart, asLoad, asError, asSimul,
    asLogOut );

  TAsNotifyEvent  = procedure( asType : TAppStatus ) of object;
  TSsNotifyEvent  = procedure( value : string; idx : integer ) of object;

    // status
  TEditingStatus = (esNone, esNew, esModified, esDeleted);
  TSortDirection = (soAscending, soDescending);
  TSocketState = (ssClosed, ssConnectPend, ssConnected, ssLinkPend, ssRecovering, ssOpen);

    // domain related
  TPositionType = (ptLong, ptShort);
  TPositionTypes = set of TPositionType;
  TOrderListType = ( olAdd, olDelete, olUpdate );

  TSideType = ( stNone, stLong, stShort );


  TAccountType  = ( atStock, atFO );
  TDerivativeType = (dtFutures, dtOptions);
                   // 아침 동시호가 , 장시작직후, 아침동시호가종료직전,  장중..
  TGreeksType = (GtDelta, GtGamma, GtVega, GtTheta, GtRho, GtPrice );
  TOrderTimeType = ( ottJangBefore, ottJangStart, otSimulEndJust, ottJangJung2, ottJangJung,
    ottOrdManager );

  TCodeDivision = ( cdTops, cdFep, cdLimit );
  //*^^*
  TSendPacketEvent = function(  iSize, iLocalNo : integer; stPacket : string ): boolean of object;
  //TSendMothEvent = function ( iSize : integer; stPacket : string ) : boolean of object;
  TObjectCheckEvent = function ( Value : TObject ) : boolean of object;
  TGoodiSendPacketEvent = function(  iSize , iTr, iLocalNo : integer; stPacket : string ): boolean of object;
  TGiQuerySendEvent = function( iTrCode : integer; stInput : string ) : boolean of object;

  TRcvUdpEvent = procedure( Packet : string; iSzie : integer ) of object;
    // status
  TMarketManage = ( mmNormal, mmStopTrade, mmCBNotice, mmCB, mmReopen );
    // app status

  TSimulationStatus = ( tsNone, tsStart, tsNoFile, tsEnd, tsReStart, tsCompleteEnd,
     tsPreSuscribe, tsClear, tsClearEnd, tsPrint, tsPrintEnd );  



  //*^^*
  // 열거형 타입
  TLogKind = (lkApplication, lkError, lkDebug, lkWarning ,lkKeyOrder, lkLossCut, lkReject );

  TNavi = (Last, Prev);
  TBullEventKind = (beNone, beFuture, beOption, beTimer, beSync);

  TBatchCancelType = (bctAll, bctAskAll, bctBidAll, bctAskShift, bctBidShift );

  // 구독 우선선위
  TSubscribePriority = ( spHighest, spNormal, spLowest, spIdle );
  TQuotePosition  = ( qpAdd, qpDelete, qpFill, qpChange , qpCancel);

  TOrderSpecies = ( opNormal, opVolStop, opProtecte, opBull, opStrangle, opYH,
                    opRatio, opStrangle2, opStrangle3, opInvestor, opBondTrend,
                    opSheepBuy, opHULT, opHLT, opOs, opVols, opTrend, opOptHult, opTrend2, opBHult, opJarvis2,
                    opEvolBHult ,opEvolHult, opPDT, opShortHult, opJarvis, opPave );

  TStrategyType = ( stNormal, stStrangle, stYH, stRatio, stStrangle2, stStrangle3,
                    stInvestor, stTodarke, stSheepBuy, stHult,  stBondTrend,
                    stOS, stVolS, stTrend, stOptHult, stTrend2, stBHult, stJarvis2, stShortHult );

  TMothType = (mtBull, mtOMan, mtVolStop, mtFront, mtSCatch);
  TVolStopBeHavior = ( vsoAdd, vsoDel, vsoAllDel, vsoSideDel, vsoPartDel );

  TShapeType = ( sptCatch );

  TRedundancyType = ( rdtOrderMan, rdtProtected );

  TFrameType = ( ftBull,  ftOrder, ftFront, ftSCatch, ftProtected );

  TSSoptType = (sotClear, sotSymbol, sotQty, sotSlice, sotStrict, sotHogacnl,
                sotAdjust, sotPre, sotDelay, sotOnoff,sotClose, sotLast, sotPoll);

  TFormationType = ( ft10, ft32, ft64, ft128, ft8 );
  TOscillatorType = ( oscSAR, oscDMI );


const
  POSITIONTYPE_DESCS: array[TPositionType] of String = ('Long', 'Short');
  LogString : array [TLogKind] of string = ('Application', 'Error', 'Debug',
    'Warning', '잔량스탑','손절', '거부주문');
  LogTabName: array [TLogKind] of string = ('tsApp', 'tsErr', 'tsDebug',
    'tsWarn' , 'tsKey' , 'tsLossCut', 'tsRjt' );

  MothTypeName : array[TMothType] of string = ('BULL', 'OMAN', 'VSTP', 'QUOT','SCTH');
  FrameString : array[TFrameType] of string = ('Bull', '주문관리', 'FrontQuoting',
                                              'SCatch', 'Protected Order');    


  WM_LOGARRIVED     = WM_USER + $0002;
  WM_SYMBOLSELECTED = WM_USER + $0003;
  WM_SELECTPOSITION = WM_USER + $0004;
  WM_ENDMESSAGE     = WM_USER + $0005;


implementation

end.
