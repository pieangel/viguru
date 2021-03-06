unit CleApiReceiver;

interface

uses
  Classes, SysUtils,

  CleQuoteBroker,  CleFunds,

  CleAccounts, CleOrders, CleSymbols, ClePositions,  CleInvestorData,

  ApiPacket, ApiConsts
  ;

type
                                             {
    ESID_5611 ,  // 실체결
    ESID_5612,	 // 실잔고
    ESID_5614,	 // 계좌별 주문체결현황
    ESID_5615 :  // 예탁자산및 증거금
                                             }
  TApiReceiver = class
  private
    FChanelIdx: integer;
    function CheckError( stData : string ): boolean;
    function GetApiTime(stTime: string): TDateTime;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ParseMarketPrice( stData : string );
    procedure ParsePrice( stData : string );
    procedure ParseReqHoga( stData : string );
    procedure ParseHoga( stData : string );
    procedure ParseChartData( stData : string );
    procedure ParseTickArray( stData : string );

    procedure ParseInvestOptData( stData : string );
    procedure ParseInvestFutData( stData : string );

    procedure ParseActiveOrder( stData : string );
    procedure ParsePosition(  stData : string );
    procedure ParseDeposit(  stData : string);
    procedure ParseAdjustMent( stData : string );
    procedure ParseAbleQty( stData : string );

    procedure ParseOrderAck( iTrCode: integer; strData: string);
    procedure ParseOrder( strData: string );
  end;

var
  gReceiver : TApiReceiver;

implementation

uses
  GAppEnv , GleLib, GleTypes, GleConsts, CleKrxSymbols, Ticks, CleFQN,
  Math, DateUtils

  ;

{ TApiReceiver }

function TApiReceiver.CheckError(stData: string): boolean;
var
  vErr : PErrorData;
  stRjt: string;
begin
  Result := true;

  vErr  :=  PErrorData( stData );
  stRjt := trim( string( vErr.Header.ErrorCode ));

  if ( stRjt = '' ) or ( stRjt = '0000') then
    Exit
  else begin
    //gEnv.ErrString  := Format('%s:%s', [ stRjt , trim(string( vErr.ErrorMsg )) ]);
    //gEnv.EnvLog( WIN_ERR, gEnv.ErrString );
    gLog.Add( lkError,'', stRjt, trim(string( vErr.ErrorMsg ))) ;
    //gEnv.SetAppStatus( asError );
    Result := false;
  end;
end;

constructor TApiReceiver.Create;
begin
  gReceiver := self;
end;

destructor TApiReceiver.Destroy;
begin
  gReceiver := nil;
  inherited;
end;



procedure TApiReceiver.ParseAbleQty(stData: string);
var
  vData : POutAbleQty;
  aInvest : TInvestor;
  aAcnt   : TAccount;
  aSymbol : TSymbol;
  aPosition, aTmpPos: TPosition;
  I: Integer;

begin
  if Length( stData ) < Len_OutAccountFillSub then Exit;
  if not CheckError( stData ) then
    Exit;

  vData := POutAbleQty( stData );
  aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( vData.Account)));
  if aInvest = nil then Exit;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( string( vData.FullCode )));
  if aSymbol = nil then Exit;

  aPosition := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvest, aSymbol );
  if aPosition = nil then
    aPosition := gEnv.Engine.TradeCore.InvestorPositions.New( aInvest, aSymbol );

  if vData.Mmgb = '1' then  // 매도
    aPosition.AbleQty[ptShort]  := StrToIntDef(trim(string(vData.Jmgqt1)),0)
  else
    aPosition.AbleQty[ptLong]   := StrToIntDef(trim(string(vData.Jmgqt1)),0);
  aPosition.LiqQty  := StrToInt(trim(string(vData.Jmgqt2)));

  gEnv.Engine.TradeBroker.PositionEvent( aPosition );
  // 가상계좌 포지션에도 주문가능수 셋팅
  for I := 0 to aInvest.Accounts.Count - 1 do
  begin
    aAcnt := aInvest.Accounts.Accounts[i];
    aTmpPos := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );
    if aTmpPos <> nil then
    begin
      //aTmpPos.ReqAbleQty  := true;
      aTmpPos.AbleQty     := aPosition.AbleQty;
      gEnv.Engine.TradeBroker.PositionEvent( aTmpPos );
    end;
  end;
  
end;

procedure TApiReceiver.ParseActiveOrder(stData : string );

var
  aMain : POutAccountFill;
  i, iStart, iCnt : integer;
  aAccount : TAccount;
  aSymbol  : TSymbol;
  stTmp, stTime, stSub  : string;
  iOrderQty, iTmp , iSide : integer;
  iOrderNo, iOriginNo : int64;
  aTicket  : TorderTicket;
  dPrice   : Double;
  aOrder   : TOrder;
  pcValue  : TPriceControl;
  tmValue  : TTimeToMarket;
  bAsk : boolean;
  dtAcptTime : TDateTime;
  aSub : POutAccountFillSub;
  aInvest : TInvestor;
begin

  if Length( stData ) < Len_OutAccountFillSub then Exit;
  if not CheckError( stData ) then
    Exit;

  aMain := POutAccountFill( stData );
  aInvest := gEnv.Engine.TradeCore.Investors.Find( string(aMain.Account));
  if (aInvest = nil) or ( aInvest.RceAccount = nil ) then Exit;
  aAccount  := aInvest.RceAccount;

  aInvest.ActOrdQueried := true;

  iCnt  := StrToIntDef( trim(string( aMain.Dtno )),0);
  if iCnt > 0 then
    for I := 0 to iCnt - 1 do
    begin
      iStart  := i* Len_OutAccountFillSub + (Len_OutAccountFill + 1);
      stSub := Copy( stData, iStart ,  Len_OutAccountFillSub );
      aSub  := POutAccountFillSub( stSub );

      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( trim(string(aSub.FullCode)));
      if aSymbol = nil then Continue;

      gEnv.EnvLog( WIN_PACKET, Format('ActiveOrder(%d:%d):%s', [ iCnt,i, stSub])  );

      iOrderNo  := StrToInt64( trim( string( aSub.Jmno )));
      iOriginNo := StrToInt64( trim( string( aSub.Wjmno )));

      aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);
      if aOrder = nil then
      begin
        if ( aSub.Mmcd = '1' ) or ( aSub.Mmcd = '3' ) then
          iSide := 1
        else
          iSide := -1;

        iOrderQty := StrToInt( trim( string( aSub.Jmqt )));

        case aSub.Hogb of
         '1' : begin pcValue := pcLimit;        tmValue := tmGTC; end;
         '2' : begin pcValue := pcMarket;       tmValue := tmGTC; end;
         '3' : begin pcValue := pcLimitToMarket;tmValue := tmGTC; end;
         '4' : begin pcValue := pcBestLimit;    tmValue := tmGTC; end;
         '5' : begin pcValue := pcLimit;        tmValue := tmIOC; end;
         '6' : begin pcValue := pcLimit;        tmValue := tmFOK; end;
         '7' : begin pcValue := pcMarket;       tmValue := tmIOC; end;
         '8' : begin pcValue := pcMarket;       tmValue := tmFOK; end;
         '9' : begin pcValue := pcBestLimit;    tmValue := tmIOC; end;
         'A' : begin pcValue := pcBestLimit;    tmValue := tmFOK; end;
        end;

        dPrice  := StrToFloat( trim( string( aSub.Jmjs )));
        stTime  := string( aSub.Cgtm );
        dtAcptTime  := Date + EncodeTime( StrToInt( Copy( stTime, 1, 2 )),
                                          StrToInt( Copy( stTime, 3, 2 )),
                                          StrToInt( Copy( stTime, 5, 2 )), 0);

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewRecoveryOrder( gEnv.ConConfig.UserID,
                                                                    aAccount,
                                                                    aSymbol,
                                                                    iSide,  iOrderQty,
                                                                    pcValue,
                                                                    dPrice,
                                                                    tmValue,
                                                                    aTicket,
                                                                    iOrderNo
                                                                    );
        if aOrder <> nil then
          gEnv.Engine.TradeBroker.Accept( aOrder, true, '', dtAcptTime );

      end;
    end;

  if aMain.Header.NextKind <> '0' then
  begin
    gEnv.EnvLog( WIN_PACKET, Format('%s : Stand by Next Active Order ', [ aInvest.Code ])   );
  end;
end;


procedure TApiReceiver.ParseAdjustMent(stData: string);
var
  pMain : POutAccountAdjustMent;
  i,idx : integer;
  stTmp : string;
  aInvest : TInvestor;
  aAcnt   : TAccount;
  dFee, dFixedPL, dOpen, dOptOpen : double;
  aPos  : TPosition;
begin

  try
    if not CheckError( stData ) then
      Exit;

    if Length( stData ) < Len_OutAccountAdjustMent then Exit;
    pMain := POutAccountAdjustMent( stData );

    //Move( pMain.Header.ReqKey, idx, 1 );
    idx   := StrToIntDef(trim(string(pMain.Header.WindowID)), 0);
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[idx-1];
    if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
    aAcnt := aInvest.RceAccount;

    aInvest.Deposit     := StrToFloat( trim( string( pMain.Syttm )));
    aInvest.Deposit     := StrToFloatDef(trim( string( pMain.Syttm )),0);    // 예탁총액
    aInvest.DepositOTE  := StrToFloatDef(trim( string( pMain.FYttm )),0);     // 평가예탁

    dFixedPL  :=  StrToFloatDef(trim( string( pMain.Fcsgm )),0) +    // 선물실현
                  StrToFloatDef(trim( string( pMain.Ocsgm )),0);     // 옵션실현
    dFee      :=  StrToFloatDef(trim( string( pMain.Susu )),0);      // 수수료..

    dOptOpen  := 0;

    for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
    begin
      aPos := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];
      if (aPos.Account = aInvest) and ( aPos.Symbol.Spec.Market = mtOption ) then
        dOptOpen  := dOptOpen + aPos.EntryOTE;
    end;

    dOpen  :=  StrToFloatDef(trim( string( pMain.Ffagm )),0) +    // 선물평가손익
                  dOptOpen;   // 옵션평가손익

    aInvest.SetFixedPL( dFixedPL );
    aAcnt.SetFixedPL( dFixedPL);

    aInvest.RecoverFees := dFee;
    aAcnt.RecoverFees   := dFee;

    aInvest.OpenPL      := dOpen;
    aAcnt.OpenPL        := dOpen;

    aInvest.TrustMargin :=  StrToFloatDef(trim(string(pMain.Ytjm)),0); // 위탁증거금
    aInvest.HoldMargin  :=  StrToFloatDef(trim(string(pMain.Ytjy)),0); // 유지증거금
    aInvest.AddMargin   :=  StrToFloatDef(trim(string(pMain.Cjgtm)),0);  // 추가증거금
    aInvest.EAbleAmt    :=  StrToFloatDef(trim(string(pMain.Jmgtm)),0);   // 주문가능

    gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );

  finally

  end;

end;

procedure TApiReceiver.ParseChartData(stData: string);
  var
    pMain : POutChartData;
    pSub  : POutChartDataSub;
    aSymbol : TSymbol;
    iHour, i, iCount, iMMIndex, iNextMMIndex,iStart, iMin : integer;
    stSub, stTmp : string;
    bAddTerm  : boolean;
    aQuote : TQuote;
    dtDate, dtTime : TDateTime;
    aItem  : TSTermItem;
    wHH, wMM, wSS, wCC : word;
    dOpen, dHigh, dLow, dCur : double;

    dLTmp, dHTmp : double;
begin
  try

  if not CheckError( stData ) then
    Exit;

  if Length( stData ) < Len_OutChartData then Exit;

  pMain :=  POutChartData( stData );
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( string( pMain.FullCode )));
  if (aSymbol = nil )  then  Exit;
  if aSymbol.Quote = nil then Exit;

  case pMain.Header.WindowID[0] of
    '0' : stTmp :='일봉';
    '2' : stTmp :='주봉';
    '3' : stTmp :='월봉';
    '4' : stTmp :='틱봉';
    '1' : stTmp :='분봉';
  end;
  
  iCount  := StrToIntDef( trim( string( pMain.DataCnt )), 0);
                    {
  gEnv.EnvLog( WIN_TEST, Format('%s : %s 전일종가 (%.*n) -> %d ',[
    trim(string( pMain.Today)),  stTmp,  aSymbol.Spec.Precision,
    StrToFloatDef( trim( string( pMain.PrevLast )),0),  icount]));
                     }
  aQuote  := aSymbol.Quote as TQuote;

  //bAddTerm := true;
  iMin := StrToInt( trim( string( pMain.Header.WindowID[0] ))) ;

  dLTmp := aQuote.Symbol.LimitHigh;
  dHTmp := 0;

  for I := 0 to iCount - 1 do
  begin
    iStart  := i* Len_OutChartDataSub + (Len_OutChartData + 1);
    stSub := Copy( stData, iStart ,  Len_OutChartDataSub );
    pSub  := POutChartDataSub( stSub );
    //gEnv.EnvLog( WIN_TEST, Format('PosSub(%d):%s',[ i, stSub]));

    stTmp   := trim(string( pSub.Date ));
    dtDate  := EncodeDate( StrToInt(Copy(stTmp,1,4)), // year
                            StrToInt(Copy(stTmp,5,2)), // mon
                            StrToInt(Copy(stTmp,7,2))); // day

    dOpen := StrToFloat( trim( string( pSub.OpenPrice )));
    dHigh := StrToFloat( trim( string( pSub.HighPrice )));
    dLow  := StrToFloat( trim( string( pSub.LowPrice )));
    dCur  := StrToFloat( trim( string( pSub.ClosePrice )));

    case pMain.Header.WindowID[0] of
       '1' :  // 원달러 전략중 5분데이타 채널
        begin
                     {
          if dLTmp > dLow then
            dLTmp := dLow;
          if dHtmp < dHigh then
            dHtmp := dHigh;

          if i = gEnv.Engine.SendBroker.ChanelIdx then
          begin
            aQuote.HighChl  := dHtmp;
            aQuote.LowChl   := dLtmp;

            gEnv.EnvLog( WIN_TEST,
              Format('%s Set Chanel H : %.2f,  L : %.2f', [ aQuote.Symbol.ShortCode,
                  aQuote.HighChl, aQuote.LowChl ])
            );
            break;
          end;
        end;
        '1' :
          begin     }

            stTmp   := trim(string( pSub.Time ));
            dtTime  := dtDate + Frac( GetApiTime( stTmp ) );

            aItem := aQuote.Terms.New( dtTime ) ;

            aItem.O := dOpen;
            aItem.H := dHigh ;
            aItem.L := dLow;
            aItem.C := dCur;

            DecodeTime(dtTime, wHH, wMM, wSS, wCC);
            iMMIndex := (wHH )*60 + wMM;
            aItem.MMIndex := (iMMIndex div iMin) * iMin;
            aItem.LastTime := IncMinute( dtTime, iMin );
            {
            gEnv.EnvLog( WIN_TEST, Format('Term(%d)%d: %s->%s , %.*n, %.*n, %.*n, %.*n',
              [ i, aItem.MMIndex,  FormatDateTime('yyyy:mm:dd hh-nn-ss', aItem.StartTime),
                  FormatDateTime('yyyy:mm:dd hh-nn-ss', aItem.LastTime ),
                aSymbol.Spec.Precision, aItem.O,  aSymbol.Spec.Precision, aItem.H,
                aSymbol.Spec.Precision, aItem.L,  aSymbol.Spec.Precision, aItem.C  ]));
            }
            aQuote.Terms.CalcRealATR( true );

          end;
      else begin
        // 일봉                               // 어제
        if ( pMain.Header.WindowID[0] = '0' ) and ( i = iCount-1 ) then
        begin
          // 전일 고저를 구하기 위한
          aSymbol.PrevHigh  := dHigh;
          aSymbol.PrevLow   := dLow;
        end;
            {
          gEnv.EnvLog( WIN_TEST, Format('Term(%d): %s , o:%s, h:%s, l:%s, c:%s',
            [ i, FormatDateTime('yyyy:mm:dd', dtDate ),
              aSymbol.PriceToStr( dOpen ),  aSymbol.PriceToStr( dHigh ),
              aSymbol.PriceToStr( dLow ),  aSymbol.PriceToStr( dCur ) ]));
              }
      end;
    end;

  end;

  aQuote.UpdateChart( iMin );

  except
  end;
end;

procedure TApiReceiver.ParsePosition( stData : string );
  var
    pMain : POutAccountPos;
    pSub  : POutAccountPosSub;
    aInvest : TInvestor;
    aAcnt, tmpAcnt : TAccount;
    aSymbol : TSymbol;
    i, iSide, iCount, iStart, iVolume : integer;
    dOpenPL, dOpenAmt, dAvgPrice, dPrice, dTmp : double;
    stTmp, stSub : string;
    aInvestPos, aPos, tmpPos : TPosition;
    j: Integer;
    tmpList : TList;
    aFund : TFund;
    aFundPos : TFundPosition ;
begin

  if Length( stData ) < Len_OutAccountPos then Exit;
  if not CheckError( stData ) then
    Exit;

  pMain :=  POutAccountPos( stData );
  aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( pMain.Account )));
  if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
  aAcnt := aInvest.RceAccount;
  iCount  := StrToIntDef( trim( string( pMain.Dtno )), 0);

  if iCount > 0 then
    for I := 0 to iCount - 1 do
    begin
      iStart  := i* Len_OutAccountPosSub + (Len_OutAccountPos + 1);
      stSub := Copy( stData, iStart ,  Len_OutAccountPosSub );
      pSub  := POutAccountPosSub( stSub );
      gEnv.EnvLog( WIN_PACKET, Format('PosSub(%d):%s',[ i, stSub]));
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( trim( string ( pSub.FullCode )));
      if aSymbol = nil then Continue;

      if pSub.Mmcd = '1' then
        iSide := -1
      else
        iSide := 1;

      iVolume   := StrToInt( trim( string( pSub.Jgqt )));
      dAvgPrice := StrToInt( trim( string( pSub.Avgt ))) / 100000;
      //stTmp  := Format('%.*f', [ aSymbol.Spec.Precision, dAvgPrice ]);
      //dAvgPrice := StrToFloatDef( stTmp , 0 );
      dOpenPL   := StrToFloat( trim( string( pSub.Sonic )));
      dOpenAmt  := StrToFloat( trim( string( pSub.Fagm )));
      dPrice    := StrToFloat( trim( string( pSub.Curr ))) / 100;

      aPos := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );
      if aPos = nil then
      begin
        aPos := gEnv.Engine.TradeCore.Positions.New(aAcnt, aSymbol);
        gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_NEW);
      end;

      aPos.SetPosition( iVolume * iSide, dAvgPrice, 0);
      aPos.TradeAmt := dOpenAmt;
      aPos.CaclOpePL( dPrice);

      gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
          aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler );

      aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvest, aSymbol);
      if aInvestPos = nil then
        aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.New( aInvest, aSymbol );

      if aInvestPos <> nil then
      begin
        aInvestPos.SetPosition(iVolume * iSide, dAvgPrice,0);
        aInvestPos.TradeAmt := dOpenAmt;
        aInvestPos.CaclOpePL( dPrice);
      end;
      gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_UPDATE);

      // fund poistion
      aFund := gEnv.Engine.TradeCore.Funds.Find( aAcnt );
      if aFund <> nil then
      begin
        aFundPos  := gEnv.Engine.TradeCore.FundPositions.Find( aFund, aSymbol  );
        if aFundPos = nil then begin
          aFundPos := gEnv.Engine.TradeCore.FundPositions.New( aFund, aSymbol);
          gEnv.Engine.TradeBroker.PositionEvent( aFundPos, FPOSITION_NEW );
        end;

        if not aFundPos.Positions.FindPosition( aPos ) then
          aFundPos.Positions.Add( aPos );
        aFundPos.RecoveryPos( aPos.Volume, aPos.AvgPrice);
        gEnv.Engine.TradeBroker.PositionEvent( aFundPos, FPOSITION_UPDATE );
      end ;
    end;

  if pMain.Header.NextKind <> '0' then
  begin
    //gEnv.Engine.SendBroker.RequestAccountPos( aInvest, pMain.Header.NextKind );
    gEnv.EnvLog( WIN_PACKET, Format('%s : Stand by Next 잔고', [ aInvest.Code ])   );
  end;

end;

procedure TApiReceiver.ParseDeposit( stData : string );

  var
    pMain : ROutAccountDeposit;
    aInvest : TInvestor;
    aAcnt : TAccount;
    aSymbol : TSymbol;
    i : integer;
    dFee, dFixedPL : double;
    aInvestPos, aPos : TPosition;
begin

  if Length( stData ) < Len_OutAccountDeposit then Exit;
  if not CheckError( stData ) then
    Exit;

  pMain :=  ROutAccountDeposit( stData  );

  i := StrToIntDef( trim( string( pMain.Header.WindowID )), 0) -1;
  if i < 0 then Exit;
  aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
  if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
  aAcnt := aInvest.RceAccount;

  aInvest.Deposit := StrToFloat( trim( string( pMain.Syttm )));
  aInvest.Deposit     := StrToFloatDef(trim( string( pMain.Syttm )),0);    // 예탁총액
  aInvest.DepositOTE  := StrToFloatDef(trim( string( pMain.Yttm )),0);     // 평가예탁


  aInvest.SetFixedPL(0);
  aAcnt.SetFixedPL(0);
  //aInvest.SetFixedPL(  StrToFloatDef(trim( string( pMain.SubData.Mmsi )),0) +    // 선물실현
  //                     StrToFloatDef(trim( string( pMain.SubData.Opgm )),0));    // 옵션실현
  aInvest.RecoverFees := StrToFloatDef(trim( string( pMain.Susu )),0);    // 수수료..
  aAcnt.RecoverFees   := aInvest.RecoverFees;

  aInvest.TrustMargin :=  StrToFloatDef(trim(string(pMain.Ytjm)),0); // 위탁증거금
  aInvest.HoldMargin  :=  StrToFloatDef(trim(string(pMain.Ytjy)),0); // 유지증거금
  aInvest.AddMargin   :=  StrToFloatDef(trim(string(pMain.Cjgtm)),0);  // 추가증거금
  aInvest.OrderMargin :=  StrToFloatDef(trim(string(pMain.SubData.Pfjm)),0);   // 가격증거금
  aInvest.MinMargin   :=  StrToFloatDef(trim(string(pMain.SubData.Gtjm)),0);   // 가격증거금

  aInvest.EAbleAmt    :=  StrToFloatDef(trim(string(pMain.Jgtm)),0);   // 주문가능

  {
  dFixedPL := StrToFloat( trim( string( pMain.Fut_rsrb_pl )));
  dFee     := StrToFloat( trim( string( pMain.Fut_trad_fee )));

  aInvest.RecoverFees[dtUSD]  := dFee;
  aInvest.SetFixedPL( dtUSD, dFixedPL );

  aAcnt.RecoverFees[dtUSD]    := dFee;
  aAcnt.FixedPL[dtUSD]        := dFixedPl;

   }
  gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );


end;

procedure TApiReceiver.ParseReqHoga(stData: string);
var
  vData : POutSymbolHoga;
  aQuote: TQuote;
  aSymbol : TSymbol;

  stTime: string;
  i : integer;
  dtQuote : TDateTime;
begin
  if Length( stData ) < SizeOf( TOutSymbolHoga) then Exit;

  vData := POutSymbolHoga( stData );

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string( vData.FullCode )));
  if aSymbol = nil then Exit;

  if aSymbol.Quote = nil then Exit;

  aQuote  := aSymbol.Quote as TQuote;
  stTime  := string( vData.Time );
  try

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToFloatDef( trim(string( vData.Arr[i].SellPrice )),0 );
      aQuote.Asks[i].Volume := StrToIntDef( trim(string( vData.Arr[i].SellQty )),0 );
      aQuote.Asks[i].Cnt    := StrToIntDef( trim(string( vData.Arr[i].SellCnt )),0 );

      aQuote.Bids[i].Price  := StrToFloatDef( trim(string( vData.Arr[i].BuyPrice )),0);
      aQuote.Bids[i].Volume := StrToIntDef( trim(string( vData.Arr[i].BuyQty )),0);
      aQuote.Bids[i].Cnt    := StrToIntDef( trim(string( vData.Arr[i].BuyCnt )),0);

    end;

    aQuote.Asks.VolumeTotal := StrToInt( trim(string( vData.TotSellQty )));
    aQuote.Bids.VolumeTotal := StrToInt( trim(string( vData.TotBuyQty )));

    aQuote.Asks.CntTotal := StrToInt( trim(string( vData.TotSellNo )) );
    aQuote.Bids.CntTotal := StrToInt( trim(string( vData.TotBuyNo )));
    dtQuote  := GetApiTime( stTime );

   aQuote.Update(dtQuote);
  except
  end;

end;

procedure TApiReceiver.ParseTickArray(stData: string);
var
  vData : PAutoSymbolTick;
  vDataSub  : PAutoSymbolTickSub;
  i, iStart, iCnt : integer;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  stTime, stSub : string;
  dtQuote : TDateTime;
  aSale : TTimeNSale;

begin

  if Length( stData ) < SizeOf( TOutSymbolHoga) then Exit;

  vData := PAutoSymbolTick( stData );

  aQuote := gEnv.Engine.QuoteBroker.Find( trim(string( vData.FullCode )));
  if aQuote = nil then Exit;

  iCnt    := StrToIntDef( trim( string( vData.Count )), 0 );


  for I := 0 to iCnt - 1 do
  begin
    iStart  := i* Len_AutoSymbolTickSub + (Len_AutoSymbolTick + 1);
    stSub   := Copy( stData, iStart ,  Len_AutoSymbolTickSub );

    vDataSub:= PAutoSymbolTickSub( stSub );

    aSale := aQuote.Sales.New;
    stTime := trim( string( vDataSub.Time ));

    aSale.LocalTime := now;
    aSale.Time := GetApiTime( stTime );
    aSale.Price := StrToFloat( trim( string( vDataSub.CurrPrice )));
    aSale.Volume:= StrToInt( trim( string( vDataSub.NowVol )));
    aSale.DayVolume := StrToInt( trim( string( vDataSub.Volume )));

    if VDataSub.MatchKind = '+' then
      aSale.Side := 1
    else if VDataSub.MatchKind = '-' then
      aSale.Side := -1
    else
      aSale.Side := 0;

    aQuote.SaveAccumulVolume;

  end;

end;

procedure TApiReceiver.ParseHoga(stData: string);
var
  vData : PAutoSymbolHoga;
  aQuote: TQuote;
  stTime: string;
  i : integer;
  dtQuote : TDateTime;
begin
  if Length( stData ) < Len_AutoSymbolHoga then Exit;

  vData := PAutoSymbolHoga( stData );

  aQuote  := gEnv.Engine.QuoteBroker.Find( string(vData.FullCode) );
  if aQuote = nil then Exit;

  stTime  := string( vData.Time );

  try

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToFloat( trim(string( vData.Arr[i].SellPrice )));
      aQuote.Asks[i].Volume := StrToInt( trim(string( vData.Arr[i].SellQty )));
      aQuote.Asks[i].Cnt    := StrToInt( trim(string( vData.Arr[i].SellCnt )));

      aQuote.Bids[i].Price  := StrToFloat( trim(string( vData.Arr[i].BuyPrice )));
      aQuote.Bids[i].Volume := StrToInt( trim(string( vData.Arr[i].BuyQty )));
      aQuote.Bids[i].Cnt    := StrToInt( trim(string( vData.Arr[i].BuyCnt )));

    end;

    aQuote.Asks.VolumeTotal := StrToInt( trim(string( vData.TotSellQty )));
    aQuote.Bids.VolumeTotal := StrToInt( trim(string( vData.TotBuyQty )));

    aQuote.Asks.CntTotal := StrToInt( trim(string( vData.TotSellNo )) );
    aQuote.Bids.CntTotal := StrToInt( trim(string( vData.TotBuyNo )));
    dtQuote  := GetApiTime( stTime );

    aQuote.EstFillPrice := StrToFloatDef( trim(string( vData.Equilibrium )),0);
    aQuote.Symbol.ExpectPrice :=  aQuote.EstFillPrice;

    aQuote.Update(dtQuote);
  except
  end;
end;

procedure TApiReceiver.ParseInvestFutData(stData: string);
var
  vSub  : PAutoInvestFutDataSub;
  vData : PAutoInvestFutData;
  aItem, aItemc, aItemp : TInvestorData;
  iCnt  : integer;
  stSub : string;
  I : Integer;

  stLog, stID, stCP : string;

begin

  if Length( stData ) < 200 then Exit;

  vData := PAutoInvestFutData( stData );

  //  00.전체 01.금융투자 02.보험회사 03.투자신탁 04.은행
  //  05.기타금융 06.연기금등 07.기관계 08.기타법인 09.개인
  //  10.외국인 11.거주외국인 12.국가단체							*/

  //  원래 코드는 아래..
  { InvestorID
  1000								증권회사 및 선물회사
  1200								보험회사
  3000								"자산운용회사및 투자회사"
  4000								"은행(자산운용회사의신탁재산은자산운용회사로 분류)
  5000								종금, 저축은행
  6000								연, 기금
  7000								"국가, 지방자치단체및 국제기구"
  7100								기타법인
  8000								개인
  9000								비거주외국인
  9999								전체
}



  for I := 0 to High( vData.Sub_Ary) do
  begin
    if string(vData.Sub_Ary[i].InvstCode) = '00' then Continue;

    stID := trim( string(vData.Sub_Ary[i].InvstCode ) );
    aItem := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.New(stID, 'F');
    if aItem <> nil then
    begin
      aItem.BidQty :=  StrToIntDef(string(vData.Sub_Ary[i].BuyQty), 0);
      aItem.AskQty := StrToIntDef(string(vData.Sub_Ary[i].SellQty), 0);
      aItem.BidAmount := StrToFloatDef(string(vData.Sub_Ary[i].BuyAmt), 0) / 100;
      aItem.AskAmount := StrToFloatDef(string(vData.Sub_Ary[i].SellAmt), 0) / 100;
      aItem.SumQty    := aItem.BidQty - aItem.AskQty;
      aItem.SumAmount := aItem.BidAmount - aItem.AskAmount;
    end;

  end;

end;

procedure TApiReceiver.ParseInvestOptData( stData : string );
var
  vSub  : PAutoInvestOptDataSub;
  vData : PAutoInvestOptData;
  aItem, aItemc, aItemp : TInvestorData;
  iCnt  : integer;
  stSub : string;
  I : Integer;

  stLog, stID, stCP : string;

begin

  if Length( stData ) < 200 then Exit;

  vData := PAutoInvestOptData( stData );

  //  00.전체 01.금융투자 02.보험회사 03.투자신탁 04.은행
  //  05.기타금융 06.연기금등 07.기관계 08.기타법인 09.개인
  //  10.외국인 11.거주외국인 12.국가단체							*/

  //  원래 코드는 아래..
  { InvestorID
  1000								증권회사 및 선물회사
  1200								보험회사
  3000								"자산운용회사및 투자회사"
  4000								"은행(자산운용회사의신탁재산은자산운용회사로 분류)
  5000								종금, 저축은행
  6000								연, 기금
  7000								"국가, 지방자치단체및 국제기구"
  7100								기타법인
  8000								개인
  9000								비거주외국인
  9999								전체
}

  for I := 0 to High( vData.Sub_Ary) do
  begin
    if string(vData.Sub_Ary[i].InvstCode) = '00' then Continue;

    stID := trim( string(vData.Sub_Ary[i].InvstCode ) );
    aItem := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.New(stID, 'C');
    if aItem <> nil then
    begin
      aItem.BidQty :=  StrToIntDef(string(vData.Sub_Ary[i].c_BuyQty), 0);
      aItem.AskQty := StrToIntDef(string(vData.Sub_Ary[i].c_SellQty), 0);
      aItem.BidAmount := StrToFloatDef(string(vData.Sub_Ary[i].c_BuyAmt), 0) / 100;
      aItem.AskAmount := StrToFloatDef(string(vData.Sub_Ary[i].c_SellAmt), 0) / 100;
      aItem.SumQty := aItem.BidQty - aItem.AskQty;
      aItem.SumAmount := aItem.BidAmount - aItem.AskAmount;
    end;

    aItem := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.New(stID, 'P');
    if aItem <> nil then
    begin
      aItem.BidQty :=  StrToIntDef(string(vData.Sub_Ary[i].p_BuyQty), 0);
      aItem.AskQty := StrToIntDef(string(vData.Sub_Ary[i].p_SellQty), 0);
      aItem.BidAmount := StrToFloatDef(string(vData.Sub_Ary[i].p_BuyAmt), 0) / 100;
      aItem.AskAmount := StrToFloatDef(string(vData.Sub_Ary[i].p_SellAmt), 0) / 100;
      aItem.SumQty := aItem.BidQty - aItem.AskQty;
      aItem.SumAmount := aItem.BidAmount - aItem.AskAmount;
    end;
  end;

end;

procedure TApiReceiver.ParseMarketPrice(stData: string);
var
  vData : POutSymbolMarkePrice;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  iLen    : integer;
begin
  //iLen  := Length( stData );
  if iLen < 200 then Exit;

  try
    vData := POutSymbolMarkePrice( stData );
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string( vData.FullCode )));

    if aSymbol = nil then Exit;

 // if aSymbol.ShortCode = 'NGH6' then
  //  gEnv.OnLog( self, 'ngh6');

    aSymbol.Last  := StrToFloat( trim( string( vData.CurrPrice )));
    aSymbol.DayOpen := StrToFloat( trim( string( vData.StartPrice )));
    aSymbol.DayHigh := StrToFloat( trim( string( vData.HighPrice )));
    aSymbol.DayLow  := StrToFloat( trim( string( vData.LowPrice )));

    aSymbol.Change := StrToFloat( trim(string( vData.CmpPrice )));
    case vData.CmpSign of
      '2','4','6','8' : aSymbol.Change := aSymbol.Change * -1;
    end;

    if aSymbol.Quote <> nil then
      (aSymbol.Quote as TQuote).UpdateCustom( now );

  except
  end;

end;

function TApiReceiver.GetApiTime( stTime : string ) : TDateTime;
begin
  Result := Date +
                 + EncodeTime(StrToIntDef(Copy(stTime,1,2),0), // hour
                              StrToIntDef(Copy(stTime,4,2),0), // min
                              StrToIntDef(Copy(stTime,7,2),0), // sec
                              0 ); // msec};

end;

procedure TApiReceiver.ParsePrice(stData: string);
var
  vData : PAutoSymbolPrice;
  aQuote: TQuote;
  aSale: TTimeNSale;
  dtQuote : TDAteTime;
  stTime  : string;
  askPrice : double;
begin
  if Length( stData ) < Len_AutoSymbolPrice then Exit;

  try
    vData := PAutoSymbolPrice( stData );

    aQuote  := gEnv.Engine.QuoteBroker.Find( string(vData.FullCode) );
    if aQuote = nil then Exit;

    stTime  := string( vData.Time );
    dtQuote := GetApiTime( stTime );

    aQuote.DailyVolume  := StrToInt64( trim(string(vData.Volume )));

    aQuote.Open := StrToFloat( trim(string( vData.StartPrice )));
    aQuote.High := StrToFloat( trim(string( vData.HighPrice ))) ;
    aQuote.Low  := StrToFloat( trim(string( vData.LowPrice )));
    aQuote.Last := StrToFloat( trim(string( vData.CurrPrice )));
    aQuote.Change := StrToFloat( trim(string( vData.CmpPrice )));

    case vData.CmpSign of
      '2','4','6','8' : aQuote.Change := aQuote.Change * -1;
    end;

    aQuote.Symbol.Change  := aQuote.Change;
    aQuote.Symbol.RealUpperLimit  := StrToFloat( trim( string( vData.RTime_Hi )));
    aQuote.Symbol.RealLowerLimit  := StrToFloat( trim( string( vData.RTime_Lo )));

    aQuote.Update(dtQuote);

  except
  end;

end;




procedure TApiReceiver.ParseOrderAck(iTrCode: integer; strData: string);
  var
    aOrder : TOrder;
    iLocalNo : integer;
    iOrderNo : integer;
    aData : PUnioKrPacket;
    aHead : PCommonHeader;
    stMsg,stRjt : string;
    aInvestor : TInvestor;
    aSymbol   : TSymbol;
    bSucsess   : boolean;
begin

  try
    gEnv.EnvLog( WIN_PACKET, Format('Order_%d:%s', [  iTrCode, strData  ]) );

    aHead := PCommonHeader( strData );
    stRjt :=  trim(string( aHead.ErrorCode ));

    aData := PUnioKrPacket( strData );

    iLocalNo  := 0;
    case iTrCode of
      ESID_5101 : iLocalNo := StrToIntDef( trim( string( aData.KrNew.User_Field )), 0);
      ESID_5102 : iLocalNo := StrToIntDef( trim( string( aData.KrChange.User_Field )), 0);
      ESID_5103 : iLocalNo := StrToIntDef( trim( string( aData.KrCancel.User_Field )), 0);
    end;

    if ( stRjt = '' ) or ( stRjt = '0000' ) then
      bSucsess := true
    else
      bSucsess := false;
           
    aOrder    := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder2( iLocalNo );

    if aOrder = nil then begin
      gEnv.EnvLog( WIN_ORD, Format('%d : Not Found LocalNo(%d) order : %s, %s', [
        itrCode, iLocalNo, stRjt, strData  ]) );
      Exit;
    end;

    if bSucsess then
    begin
      iOrderNo  := -1;
      case iTrCode of
        ESID_5101 : iOrderNo := StrToIntDef( trim( string( aData.KrNew.OrderNo )), 0);
        ESID_5102 : iOrderNo := StrToIntDef( trim( string( aData.KrChange.OrderNo )), 0);
        ESID_5103 : iOrderNo := StrToIntDef( trim( string( aData.KrCancel.OrderNo )), 0);
      end;
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjt );
    end
    else begin
      case iTrCode of
        ESID_5101 : stMsg :=  trim( string( aData.KrNew.ErrorMsg ));
        ESID_5102 : stMsg :=  trim( string( aData.KrChange.ErrorMsg ));
        ESID_5103 : stMsg :=  trim( string( aData.KrCancel.ErrorMsg ));
      end;

      gEnv.Engine.TradeBroker.SrvReject( aOrder, stRjt, stMsg );
    end;

  except
  end;

end;

procedure TApiReceiver.ParseOrder( strData: string);
  var
    bOutOrd : boolean;
    vMain : PAutoOrderPacket;
    vData : PAutoOrderPacketSub;
    stRjtCode, stTmp, stSub, stIP2, stIP : string;
    aInvest : TInvestor;
    aAccount: TAccount;
    aSymbol : TSymbol;
    iOrderNo, iOriginNo : int64;
    i, iSide, iStart, iLocalNo, iOrderQty, iCount, iConfirmedQty , iAbleQty: integer;
    dtTime : TDateTime;
    bConfirmed: Boolean;

    bAccepted : boolean;
    aOrder, aTarget  : TOrder;
    aTicket : TOrderTicket;
    aResult : TOrderResult;

    pcValue: TPriceControl;
    otValue: TOrderType;
    tmValue: TTimeToMarket;
    dPrice, dFilledPrice : double;

begin

  if Length(strData ) < Len_AutoOrderPacketSub then Exit;

  try

    vMain := PAutoOrderPacket( strData );
    iCount:= StrToIntDef( trim( string( vMain.Count )), 0 );

    for I := 0 to iCount - 1 do
    begin

      iStart  := i* Len_AutoOrderPacketSub + sizeof(TAutoOrderPacket) + 1;
      stSub := Copy( strData, iStart ,  Len_AutoOrderPacketSub );

      vData := PAutoOrderPacketSub( stSub );

      aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( vData.accno )) );
      if aInvest = nil then Exit;
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string(vData.jmcd)));
      if aSymbol = nil then Exit;

      iOrderNo      := StrToInt64Def( trim(string(vData.grjn )),0);
      iOriginNo     := StrToInt64Def( trim(string(vData.wgrjn)),0);

      iOrderQty     := StrToIntDef( trim(string( vData.jmqt )), 0);
      // '2' 일때는 체결수량  '3,4,5,6' 일때는..확인수량..
      iConfirmedQty := StrToIntDef( trim(string( vData.cgqt )), 0);

      stRjtCode := trim( string( vData.gbsy ));
      bAccepted := (iOrderNo > 0) and ( (stRjtCode = '0000') or (stRjtcode = ''))  ;

      case vData.trcode of
        '5','6' : bAccepted := false;
        else bAccepted := true;
      end;

      stTmp  := trim( string( vData.jspm ));
      dtTime :=  Date +
                      EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                                 StrToIntDef(Copy(stTmp,3,2),0),
                                 StrToIntDef(Copy(stTmp,5,2),0),
                                 StrToIntDef(Copy(stTmp,7,2),0)*10);

      aAccount  := aInvest.RceAccount;
      aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);


      if aOrder = nil then
      begin
        stIP      := string( vData.User_div );
        stIP2     := Copy( gEnv.Engine.Api.OwnIP, Length( gEnv.Engine.Api.OwnIP) - 2 , 3 );

        if stIP = stIP2 then
        begin
          iLocalNo  := StrToIntDef( trim( string( vData.User_Field )), 0);
          aOrder    := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder(
            aInvest.Code, aSymbol, iLocalNo );

          if aOrder <> nil then begin
            gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode );
            genv.EnvLog( WIN_ORD, Format('주문 ack 역전 - (%d)%s ',[ iOrderNo, aOrder.Represent3 ])  );
          end;
        end;

      end;

      // 주문로그
      gEnv.EnvLog( WIN_ORD,
        Format('%s(%s) : %s, 번호(%d,%d) 주문(%s) 체결(%s) 잔고(%s) New미체(%s) 미체(%s) 역전(%s)', [
          vData.trcode, vData.trgb,
          stRjtCode, iOrderNo, iOriginNo,
          trim(string( vData.jmqt) ),trim(string( vData.cgqt )),
          trim(string( vData.gjqt )), trim(string( vData.miqt)),
          trim(string( vData.bmiqt )),  trim(string( vData.pro_chk )) ])
        );

      bOutOrd := false;
      // 외부 주문이란 애기
      if (aOrder = nil) then
      begin
        bOutOrd := true;

        if vData.jmgb = '1' then
          iSide := -1
        else
          iSide := 1;

        iOrderQty := StrToInt( trim( string( vDAta.jmqt )));
        dPrice    := StrToFloatDef( trim(string( vData.jmjs )), 0);

        case vDAta.gggb of
          '1' : pcValue := pcLimit;
          '2' : pcValue := pcMarket;
          '3' : pcValue := pcLimitToMarket;
          '4' : pcValue := pcBestLimit;
        end;

        case vData.jmtp of
          '0' : tmValue  := tmGTC;
          '1' : tmValue  := tmIOC;
          '2' : tmValue  := tmFOK;
        end;

        case vData.trcode of
          '1' :
            case vData.trgb of
              '4' : otValue := otNormal;
              '5' : otValue := otChange;
              '6' : otValue := otCancel;
            end;
          '2' : otValue := otNormal;
          '3' : otValue := otChange;
          '4' : otValue := otCancel;
          '5','6' : // 주문거부, 자동취소
            case vData.trgb of
              '1' : otValue := otNormal;
              '2' : otValue := otChange;
              '3' : otValue := otCancel;
            end;
        end;

        aOrder  := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder( aInvest.Code, aSymbol,
          dPrice, iSide, iOrderQty );

        if aOrder = nil then
        begin
          gEnv.EnvLog( WIN_ORD, '외부주문..!!!');
          // 주문 생성...............
          if otValue in [otChange, otCancel] then
          begin
            aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iOriginNo);
            if aTarget = nil then
            begin
              gEnv.Engine.TradeBroker.ForwardAccepts.New(aAccount, aSymbol, iOriginNo, iOrderNo, iOrderQty,
                                                      dPrice, otValue, pcValue, bAccepted,
                                                      stRjtCode, dtTime);
              Exit;
            end;
          end;

          aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
          aOrder  := nil;
          case otValue of
            otNormal:
              begin
                aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                        gEnv.ConConfig.UserID, aAccount, aSymbol, iSide * iOrderQty, pcValue, dPrice,
                        tmValue, aTicket);
              end;
            otChange: aOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrderEx(
                        aTarget, iOrderQty, pcValue, dPrice, tmValue, aTicket);
            otCancel: aOrder := gEnv.Engine.TradeCore.Orders.NewCancelorderEx(
                        aTarget, iOrderQty, aTicket);
          end;
        end else
          genv.EnvLog( WIN_ORD, Format('주문역전 - (%d)%s ',[ iOrderNo, aOrder.Represent3 ])         );
        if aOrder = nil then
        begin
          gEnv.EnvLog( WIN_ORD, 'order is nil '  );          
          Exit;
        end;
        // 서버접수 처리.....................
        gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
      end;
      //.......
      case vData.trcode of
        '1','5' :
          begin
            case vData.trgb of
              '1','2','3',  // 거부..
              '4' :
                gEnv.Engine.TradeBroker.Accept( aOrder, bAccepted, stRjtCode, dtTime );
            end;
          end;
        '2'     :
          begin

            dFilledPrice  := StrToFloat( trim( string( vData.cgjs )));
            aResult := gEnv.Engine.TradeCore.OrderResults.New(
                      aInvest, aSymbol, iOrderNo, orFilled, now,
                      gEnv.Engine.TradeCore.OrderResults.Count , '',iConfirmedQty,
                      dFilledPrice, dtTime);
            gEnv.Engine.TradeBroker.Fill( aResult, dtTime);
          end;
        '3','4','6' :
          begin
            aResult := gEnv.Engine.TradeCore.OrderResults.New(
                            aInvest, aSymbol, iOrderNo,
                            orConfirmed, Now, 0, stRjtCode, iConfirmedQty, dPrice, dtTime);
            gEnv.Engine.TradeBroker.Confirm(aResult, Now);
          end;
      end;
    end;


  except
  end;

end;

end.
