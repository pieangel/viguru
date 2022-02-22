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

  // 수신 처리 함수                                        }
  TApiReceiver = class
  private
    FChanelIdx: integer;
    function CheckError( stData : string ): boolean;
    function GetApiTime(stTime: string): TDateTime;
  public
    // 생성자
    constructor Create;
    // 소멸자 
    destructor Destroy; override;

    // 시장 가격 파싱
    procedure ParseMarketPrice( stData : string );
    // 호가 요청 파싱
    procedure ParseReqHoga( stData : string );
    // 심볼 정보 파싱
    procedure parseSymbolInfo2( stData : string );

    // 선물 시세 파싱
    procedure ParseFutPrice( stData : string );
    // 선물 호가 파싱 
    procedure ParseFutHoga( stData : string );
    // 옵션 가격 파싱
    procedure ParseOptPrice( stData : string );
    // 옵션 호가 파싱
    procedure ParseOptHoga( stData : string );

    // 주식 선물 시세 파싱
    procedure ParseStockFutPrice( stData : string );
    // 주식 선물 호가 파싱 
    procedure ParseStockFutHoga( stData : string );

    // 차트 데이터 파싱
    procedure ParseChartData( stData : string );

    // 투자자 옵션 데이터
    procedure ParseInvestOptData( stData : string );
    // 투자자 선물 데이터 
    procedure ParseInvestFutData( stData : string );

    // 활성 주문 파싱
    procedure ParseActiveOrder( stData : string );
    // 포지션 파싱 
    procedure ParsePosition(  stData : string );
    // 자산 파싱 
    procedure ParseDeposit(  stData : string);
    //
    procedure ParseAdjustMent( idx : integer; stData : string );
    // 주문 가능 금액 파싱
    procedure ParseAbleQty( stData : string );

    // 주문 접수확인 파싱
    procedure ParseOrderAck( iTrCode: integer; strData: string);
    // 주문 파싱 
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
  //vErr : PErrorData;
  stRjt: string;
begin
  Result := true;
  {
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
  }
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
  //vData : POutAbleQty;
  aInvest : TInvestor;
  aAcnt   : TAccount;
  aSymbol : TSymbol;
  aPosition, aTmpPos: TPosition;
  I: Integer;

begin
{
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
  }
end;

// 활성화 된 주문 파싱 
procedure TApiReceiver.ParseActiveOrder(stData : string );
var
  aMain : POutOrderList;
  i, iStart, iCnt : integer;
  aAccount : TAccount;
  aSymbol  : TSymbol;
  stTmp, stTime, stSub  : string;
  iOrderQty, iTmp , iLen, iSide : integer;
  iOrderNo, iOriginNo : int64;
  aTicket  : TorderTicket;
  dPrice   : Double;
  aOrder   : TOrder;
  pcValue  : TPriceControl;
  tmValue  : TTimeToMarket;
  bAsk : boolean;
  dtAcptTime : TDateTime;
  aSub : POutOrderListSub;
  aInvest : TInvestor;
begin

  if Length( stData ) < 100 then Exit;

  aMain := POutOrderList( stData );

  // 문자열을 숫자로 변환 
  iCnt  := StrToIntDef( trim(string( aMain.Count )),0);
  // 하위 주문 길이 
  iLen  := Sizeof( TOutOrderListSub );

  if iCnt > 0 then
    for I := 0 to iCnt - 1 do
    begin
      iStart  := i* iLen + ( Sizeof(TOutOrderList) + 1);
      // 문자열 추출 
      stSub := Copy( stData, iStart ,  iLen );
      aSub  := POutOrderListSub( stSub );

      aInvest := gEnv.Engine.TradeCore.Investors.Find( string(aSub.AccountNo));
      if (aInvest = nil) or ( aInvest.RceAccount = nil ) then Exit;
      aAccount  := aInvest.RceAccount;

      aInvest.ActOrdQueried := true;

      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string(aSub.KrxCode)));
      if aSymbol = nil then Continue;

      gEnv.EnvLog( WIN_PACKET, Format('ActiveOrder(%d:%d):%s', [ iCnt,i, stSub])  );

      iOrderNo  := StrToInt64( trim( string( aSub.OrderNo )));
      iOriginNo := StrToInt64( trim( string( aSub.OrgOrdNo )));

      aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);
      if aOrder = nil then
      begin
        case aSub.Side of
          '1' : iSide := 1;
          '2' : iSide := -1;
        end;

        iOrderQty := StrToInt( trim( string( aSub.RemainQty )));

        case aSub.PriceType of
         '1' : pcValue := pcLimit;
         '2' : pcValue := pcMarket;
         '3' : pcValue := pcLimitToMarket;
         '4' : pcValue := pcBestLimit;
        end;

        dPrice  := StrToFloat( trim( string( aSub.Price )));
        stTime  := string( aSub.AceptTime );
        dtAcptTime  := Date + EncodeTime( StrToInt( Copy( stTime, 1, 2 )),
                                          StrToInt( Copy( stTime, 3, 2 )),
                                          StrToInt( Copy( stTime, 5, 2 )),
                                          StrToInt( Copy( stTime, 7, 2 )));

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewRecoveryOrder( gEnv.ConConfig.UserID,
                                                                    aAccount,
                                                                    aSymbol,
                                                                    iSide,  iOrderQty,
                                                                    pcValue,
                                                                    dPrice,
                                                                    tmFAS,
                                                                    aTicket,
                                                                    iOrderNo
                                                                    );
        if aOrder <> nil then
          gEnv.Engine.TradeBroker.Accept( aOrder, true, '', dtAcptTime );

      end;
    end;

end;


procedure TApiReceiver.ParseAdjustMent(idx : integer; stData: string);
var
  pMain : POutDeposit;
  i : integer;
  stTmp : string;
  aInvest : TInvestor;
  aAcnt   : TAccount;
  dFee, dFixedPL, dOptOpen : double;
  aPos  : TPosition;
begin

  try

    if Length( stData ) < sizeof(TOutDeposit) then Exit;
    pMain := POutDeposit( stData );

    aInvest :=  gEnv.Engine.TradeCore.Investors.Find( gEnv.Engine.Api.FindAccountCode( idx ));

    if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
    aAcnt := aInvest.RceAccount;

    aInvest.Deposit     := StrToFloatDef(trim( string( pMain.TotDeposit )),0);    // 예탁총액

    dFixedPL  :=  StrToFloatDef(trim( string( pMain.FutTradePL )),0) +    // 선물실현
                  StrToFloatDef(trim( string( pMain.OptTradePL )),0);     // 옵션실현
    dFee      :=  StrToFloatDef(trim( string( pMain.Fee )),0);      // 수수료..

    dOptOpen  := 0;

    for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
    begin
      aPos := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];
      if (aPos.Account = aInvest) then
        dOptOpen  := dOptOpen + aPos.EntryOTE;
    end;



    aInvest.SetFixedPL( dFixedPL );
    aAcnt.SetFixedPL( dFixedPL);

    aInvest.RecoverFees := dFee;
    aAcnt.RecoverFees   := dFee;

    aInvest.OpenPL      := dOptOpen;
    aAcnt.OpenPL        := dOptOpen;

    aInvest.DepositOTE  := aInvest.Deposit + aInvest.LiquidPL +  dOptOpen - abs(dFee);    // 평가예탁

    aInvest.TrustMargin :=  StrToFloatDef(trim(string(pMain.TrustMarginTotAmt)),0); // 위탁증거금
    aInvest.HoldMargin  :=  StrToFloatDef(trim(string(pMain.StayMarginTotAmt)),0); // 유지증거금
    aInvest.AddMargin   :=  StrToFloatDef(trim(string(pMain.AddMarginTotAmt)),0);  // 추가증거금
    aInvest.EAbleAmt    :=  StrToFloatDef(trim(string(pMain.OrdAblTotAmt)),0);   // 주문가능

    gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );

  finally

  end;

end;

procedure TApiReceiver.ParseChartData(stData: string);
  var
   // pMain : POutChartData;
   // pSub  : POutChartDataSub;
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
  {

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

      end;
    end;

  end;

  aQuote.UpdateChart( iMin );

  except
  end;
  }
end;

// 포지션 파싱
procedure TApiReceiver.ParsePosition( stData : string );
  var
    pMain : POutPosition;
    pSub  : POutPositionSub;
    aInvest : TInvestor;
    aAcnt, tmpAcnt : TAccount;
    aSymbol : TSymbol;
    i, iLen, iSide, iCount, iStart, iVolume : integer;
    dOpenPL, dOpenAmt, dAvgPrice, dPrice, dTmp : double;
    stTmp, stSub : string;
    aInvestPos, aPos, tmpPos : TPosition;
    j: Integer;
    tmpList : TList;
    aFund : TFund;
    aFundPos : TFundPosition ;
begin

  if Length( stData ) < sizeof(TOutPosition)  then Exit;

  pMain :=  POutPosition( stData );

  iCount  := StrToIntDef( trim( string( pMain.Count )), 0);
  iLen    := Sizeof( TOutPositionSub );
  if iCount > 0 then
    for I := 0 to iCount - 1 do
    begin
      iStart  := i* iLen + (sizeof(TOutPosition)  + 1);
      stSub := Copy( stData, iStart ,  iLen );
      pSub  := POutPositionSub( stSub );
      gEnv.EnvLog( WIN_PACKET, Format('PosSub(%d):%s',[ i, stSub]));

      aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( pSub.AccountNo )));
      if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Continue;
      aAcnt := aInvest.RceAccount;
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( trim( string ( pSub.KrxCode )));
      if aSymbol = nil then Continue;

      if pSub.Side = '1' then
        iSide := 1
      else
        iSide := -1;

      iVolume   := StrToInt( trim( string( pSub.Qty )));
      dAvgPrice := StrToFloat( trim( string( pSub.AvgPrice ))) ;/// 100000;
      //stTmp  := Format('%.*f', [ aSymbol.Spec.Precision, dAvgPrice ]);
      //dAvgPrice := StrToFloatDef( stTmp , 0 );
      dOpenPL   := StrToFloat( trim( string( pSub.OpenPL )));
      dOpenAmt  := StrToFloat( trim( string( pSub.PositionAmt )));
      dPrice    := StrToFloat( trim( string( pSub.Last ))) ;/// 100;

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


end;

// 예탁금 파싱 
procedure TApiReceiver.ParseDeposit( stData : string );

  var
  //  pMain : ROutAccountDeposit;
    aInvest : TInvestor;
    aAcnt : TAccount;
    aSymbol : TSymbol;
    i : integer;
    dFee, dFixedPL : double;
    aInvestPos, aPos : TPosition;
begin
 {
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
 // gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );


end;

// 선물 호가 파싱 
procedure TApiReceiver.ParseFutHoga(stData: string);
var
  vData  : ^TWooFutHoga;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  stTmp : string;
  dtQuote : TDateTime;
begin

  vData := @stData[1];



  aQuote  := gEnv.Engine.QuoteBroker.Find( Trim( vData.Code ));
  if aQuote = nil then Exit;

  aQuote.SavePrevMarketDepths;

  try
  stTmp := trim(string( vData.HogaTime ));

  if stTmp = ''  then
    dtQuote := now
  else
    dtQuote :=  GetApiTime( stTmp );

  aQuote.Asks.VolumeTotal := StrToInt( Trim( string( vData.TotAskVol )));
  aQuote.Asks.CntTotal    := StrToInt( Trim( string( vData.TotAskCnt )));

  aQuote.Bids.VolumeTotal := StrToInt( Trim( string( vData.TotBidVol )));
  aQuote.Bids.CntTotal    := StrToInt( Trim( string( vData.TotBidCnt )));

  aQuote.Asks[0].Price  := StrToFloat( Trim(string(vData.Hoga1.AskPrice)));
  aQuote.Asks[1].Price  := StrToFloat( Trim(string(vData.Hoga2.AskPrice)));
  aQuote.Asks[2].Price  := StrToFloat( Trim(string(vData.Hoga3.AskPrice)));
  aQuote.Asks[3].Price  := StrToFloat( Trim(string(vData.Hoga4.AskPrice)));
  aQuote.Asks[4].Price  := StrToFloat( Trim(string(vData.Hoga5.AskPrice)));

  aQuote.Bids[0].Price  := StrToFloat( Trim(string(vData.Hoga1.BidPrice)));
  aQuote.Bids[1].Price  := StrToFloat( Trim(string(vData.Hoga2.BidPrice)));
  aQuote.Bids[2].Price  := StrToFloat( Trim(string(vData.Hoga3.BidPrice)));
  aQuote.Bids[3].Price  := StrToFloat( Trim(string(vData.Hoga4.BidPrice)));
  aQuote.Bids[4].Price  := StrToFloat( Trim(string(vData.Hoga5.BidPrice)));

  aQuote.Asks[0].Volume  := StrToInt( Trim(string(vData.Hoga1.AskVolume)));
  aQuote.Asks[1].Volume  := StrToInt( Trim(string(vData.Hoga2.AskVolume)));
  aQuote.Asks[2].Volume  := StrToInt( Trim(string(vData.Hoga3.AskVolume)));
  aQuote.Asks[3].Volume  := StrToInt( Trim(string(vData.Hoga4.AskVolume)));
  aQuote.Asks[4].Volume  := StrToInt( Trim(string(vData.Hoga5.AskVolume)));

  aQuote.Bids[0].Volume  := StrToInt( Trim(string(vData.Hoga1.BidVolume)));
  aQuote.Bids[1].Volume  := StrToInt( Trim(string(vData.Hoga2.BidVolume)));
  aQuote.Bids[2].Volume  := StrToInt( Trim(string(vData.Hoga3.BidVolume)));
  aQuote.Bids[3].Volume  := StrToInt( Trim(string(vData.Hoga4.BidVolume)));
  aQuote.Bids[4].Volume  := StrToInt( Trim(string(vData.Hoga5.BidVolume)));

  aQuote.Asks[0].Cnt := StrToInt( Trim(string( vData.AskCnt1 )));
  aQuote.Asks[1].Cnt := StrToInt( Trim(string( vData.AskCnt2 )));
  aQuote.Asks[2].Cnt := StrToInt( Trim(string( vData.AskCnt3 )));
  aQuote.Asks[3].Cnt := StrToInt( Trim(string( vData.AskCnt4 )));
  aQuote.Asks[4].Cnt := StrToInt( Trim(string( vData.AskCnt5 )));

  aQuote.Bids[0].Cnt := StrToInt( Trim(string( vData.BidCnt1 )));
  aQuote.Bids[1].Cnt := StrToInt( Trim(string( vData.BidCnt2 )));
  aQuote.Bids[2].Cnt := StrToInt( Trim(string( vData.BidCnt3 )));
  aQuote.Bids[3].Cnt := StrToInt( Trim(string( vData.BidCnt4 )));
  aQuote.Bids[4].Cnt := StrToInt( Trim(string( vData.BidCnt5 )));

  aQuote.Update( dtQuote);
  except
  end;
end;

// 선물 가격 파싱
procedure TApiReceiver.ParseFutPrice(stData: string);
var
  vData  : ^TWooFutExec;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  stTmp : string;
  dtQuote : TDateTime;
  aSale: TTimeNSale;
  dTmp : double;
begin

  vData := @stData[1];

  aQuote  := gEnv.Engine.QuoteBroker.Find( Trim( vData.Code ));
  if aQuote = nil then Exit;

  try

  stTmp := string( vData.Time );

  aSale := aQuote.Sales.New;

  aSale.LocalTime := now;
  if stTmp = ''  then
    dtQuote := now
  else
    dtQuote :=  GetApiTime( stTmp );

  aSale.Time := dtQuote;
  aSale.DistTime    := stTmp;
  aQuote.QuoteTime  := stTmp;

  aSale.Volume  := StrToInt( Trim( string( vData.Volume )));
  aSale.Price   := StrToFloat( Trim( string( vData.Price )));

  aQuote.Asks[0].Price  := StrToFloat( Trim( string( vData.AskPrice )));
  aQuote.Bids[0].Price  := StrToFloat( Trim( string( vData.BidPrice )));

  if aSale.Price > aQuote.Asks[0].Price -  KRX_PRICE_EPSILON then
    aSale.Side  := 1
  else
    aSale.Side  := -1;

  aQuote.Open := StrToFloat( trim( string( vData.Open )));
  aQuote.High := StrToFloat( trim( string( vData.High )));
  aQuote.Low  := StrToFloat( trim( string( vData.Low )));
  aQuote.Last := aSale.Price;
  aQuote.Change :=  aSale.Price - aQuote.Symbol.PrevClose;

  aQuote.DailyVolume  := StrToInt( trim( string( vData.DailyVolume )));
  aQuote.DailyAmount  := StrToFloat( trim( string( vData.DailyAmount )));



  aQuote.Symbol.RealUpperLimit  := StrToFloatDef( trim( string( vData.DynamicUpperLimit )),0);
  aQuote.Symbol.RealLowerLimit  := StrToFloatDef( trim( string( vData.DynamicLowerLimit )),0);



//  if ( vData.DynamicDiv = 'Y')  or ( vData.DynamicDiv = '1'   ) then
//  begin

    if (( aQuote.Symbol.LimitHigh + PRICE_EPSILON ) <  aQuote.Symbol.RealUpperLimit ) and
    ( aQuote.Symbol.RealUpperLimit > PRICE_EPSILON ) then begin
      dTmp := aQuote.Symbol.LimitHigh;
      aQuote.Symbol.LimitHigh := aQuote.Symbol.RealUpperLimit;
      gEnv.EnvLog(WIN_TEST, format( '%s %s  %.*f -> %.*f ', [
       aQuote.Symbol.ShortCode, '상한가 변동 ',
       aQuote.Symbol.Spec.Precision, dTmp,  aQuote.Symbol.Spec.Precision, aQuote.Symbol.RealUpperLimit]));
    end;

    if ( aQuote.Symbol.LimitLow + PRICE_EPSILON  > ( aQuote.Symbol.RealLowerLimit + PRICE_EPSILON  )) and
       ( aQuote.Symbol.RealLowerLimit > PRICE_EPSILON ) then begin
      dTmp := aQuote.Symbol.LimitLow;
      aQuote.Symbol.LimitLow := aQuote.Symbol.RealLowerLimit;
      gEnv.EnvLog(WIN_TEST, format( '%s %s   %.*f -> %.*f ', [
       aQuote.Symbol.ShortCode, '하한가 변동 ',
       aQuote.Symbol.Spec.Precision, dTmp,  aQuote.Symbol.Spec.Precision, aQuote.Symbol.RealLowerLimit]  ));
    end;
//  end;

  aQuote.Update( aSale.Time );
  except
  end;

end;

procedure TApiReceiver.ParseReqHoga(stData: string);
var
  vData : ^TQuerySymbolHoga;
  aQuote: TQuote;
  aSymbol : TSymbol;

  stTime: string;
  i : integer;
  dtQuote : TDateTime;
begin

  if Length( stData ) < SizeOf( TQuerySymbolHoga) then Exit;

  vData := @stData[1];

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string( vData.KrxCode )));
  if aSymbol = nil then Exit;
  if aSymbol.Quote = nil then Exit;

  aQuote  := aSymbol.Quote as TQuote;
  stTime  := string( vData.HogaTime );
  try

    aSymbol.Last      := StrToFloat(Trim( vData.Last ));
    aSymbol.PrevClose := StrToFloat(Trim( vData.PrevClose ));

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Bids[i].Price  := StrToFloatDef( trim(string( vData.BidHoga[i].Price )),0 );
      aQuote.Bids[i].Volume := StrToIntDef( trim(string( vData.BidHoga[i].Volume )),0 );
      aQuote.Bids[i].Cnt    := StrToIntDef( trim(string( vData.BidHoga[i].Cnt )),0 );

      aQuote.Asks[aQuote.Asks.Size-1-i].Price  := StrToFloatDef( trim(string( vData.AskHoga[i].Price )),0);
      aQuote.Asks[aQuote.Asks.Size-1-i].Volume := StrToIntDef( trim(string( vData.AskHoga[i].Volume )),0);
      aQuote.Asks[aQuote.Asks.Size-1-i].Cnt    := StrToIntDef( trim(string( vData.AskHoga[i].Cnt )),0);

    end;

    aQuote.Asks.VolumeTotal := StrToInt( trim(string( vData.AskTotVolume  )));
    aQuote.Bids.VolumeTotal := StrToInt( trim(string( vData.BidTotVolume )));

    aQuote.Asks.CntTotal := StrToInt( trim(string( vData.AskTotCnt )) );
    aQuote.Bids.CntTotal := StrToInt( trim(string( vData.BidTotCnt )));
    dtQuote  := GetApiTime( stTime );

   aQuote.Update(dtQuote);
  except
  end;

end;


// 주식 선물 호가 파싱
procedure TApiReceiver.ParseStockFutHoga(stData: string);
var
  vData : ^TWooStockFutHoga;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  stTmp : string;
  dtQuote : TDateTime;
  i : integer;
begin
  //gEnv.EnvLog(WIN_GI, 'H:'+stData);

  vData := @stData[1];
  aQuote  := gEnv.Engine.QuoteBroker.Find( Trim( vData.Code ));
  if aQuote = nil then Exit;

  aQuote.SavePrevMarketDepths;

  try
    stTmp := trim(string( vData.HogaTime ));

    if stTmp = ''  then
      dtQuote := now
    else
      dtQuote :=  GetApiTime( stTmp );

    aQuote.Asks.VolumeTotal := StrToInt( Trim( string( vData.TotAskVol )));
    aQuote.Asks.CntTotal    := StrToInt( Trim( string( vData.TotAskCnt )));

    aQuote.Bids.VolumeTotal := StrToInt( Trim( string( vData.TotBidVol )));
    aQuote.Bids.CntTotal    := StrToInt( Trim( string( vData.TotBidCnt )));

    for I := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToFloatDef( Trim(string(vData.Hoga[i].AskPrice)),0);
      aQuote.Asks[i].Volume := StrToIntDef( trim(string(vData.Hoga[i].AskVolume)),0);
      aQuote.Asks[i].Cnt    := StrToIntDef( trim(string(vData.AskCnt[i].Cnt)),0);

      aQuote.Bids[i].Price  := StrToFloatDef( Trim(string(vData.Hoga[i].BidPrice)),0);
      aQuote.Bids[i].Volume := StrToIntDef( trim(string(vData.Hoga[i].BidVolume)),0);
      aQuote.Bids[i].Cnt    := StrToIntDef( trim(string(vData.BidCnt[i].Cnt)),0);
    end;

    aQuote.Update(dtQuote);

  except
  end;

end;

procedure TApiReceiver.ParseStockFutPrice(stData: string);
begin
  //gEnv.EnvLog(WIN_GI, 'F:'+stData);
end;

{
  TQuerySymbolInfoUnit = record
    TradeDate : array [0..7] of char;
    Open: array [0..15] of char;
    High: array [0..15] of char;
    Low : array [0..15] of char;
    Last : array [0..15] of char;
    Volume  : array [0..15] of char;
  end;

  TQuerySymbolInfo2 = record
    filler : char;
    Code    : array [0..7] of char;
    info    : TQuerySymbolInfoUnit;
    info2   : TQuerySymbolInfoUnit;
    info3   : TQuerySymbolInfoUnit;
  end;
}

// 심볼 파싱 
procedure TApiReceiver.parseSymbolInfo2(stData: string);
var
  vData : ^TQuerySymbolInfo2;
  aSymbol : TSymbol;
begin

  if Length( stData ) < 50 then Exit;
  vData := Pointer( @stData[1] );

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string( vData.Code )));
  if aSymbol = nil then Exit;
  //
  // 전일 시고저
  aSymbol.PrevHigh  := StrToFloat( trim(string( vData.info2.High )) );
  aSymbol.PrevLow   := StrToFloat( trim(string( vData.info2.Low )) );
  aSymbol.PrevLast  := StrToFloat(trim(string( vData.info2.Last )));

  // 전전일 시고저
  aSymbol.PPrevHigh := StrToFloat( trim(string( vData.info3.High )) );
  aSymbol.PPrevLow  := StrToFloat( trim(string( vData.info3.Low )) );
  aSymbol.PPrevLast := StrToFloat(trim(string( vData.info3.Last )));

  if aSymbol.Quote = nil then Exit;
  // nh 엔 차트 데이타가 없기에 대신 사용한다.
  (aSymbol.Quote as TQuote).UpdateChart(0);

end;

// 투자 선물 파싱
procedure TApiReceiver.ParseInvestFutData(stData: string);
var

  vData : PAutoInvestFutData;
  aItem, aItemc, aItemp : TInvestorData;
  iCnt  : integer;
  stSub : string;
  I : Integer;

  stLog, stID, stCP : string;

begin

  if Length( stData ) < 50 then Exit;

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


    if string(vData.InvstCode) = '9999' then Exit;

    stID := trim( string(vData.InvstCode ) );
    aItem := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.New(stID, 'F');
    if aItem <> nil then
    begin
      aItem.BidQty :=  StrToIntDef(string(vData.BuyQty), 0);
      aItem.AskQty := StrToIntDef(string(vData.SellQty), 0);
      aItem.BidAmount := StrToFloatDef(string(vData.BuyAmt), 0) / 100;
      aItem.AskAmount := StrToFloatDef(string(vData.SellAmt), 0) / 100;
      aItem.SumQty    := aItem.BidQty - aItem.AskQty;
      aItem.SumAmount := aItem.BidAmount - aItem.AskAmount;
      {
      if (stID = '9000')  then
      begin
        gEnv.EnvLog( WIN_GI, Format( '%s : 매수[ 수량 :%s, 금액 : %s ]  매도 [ 수량 : %s, 금액 : %s ]' , [
          '외국인', string( vData.BuyQty ), string( vData.BuyAmt ),
          string( vData.SellQty) , string( vData.SellAmt )
          ]  ) );
      end;
      }
    end;


end;

// 옵션 데이터 파싱 
procedure TApiReceiver.ParseInvestOptData( stData : string );
var

  vData : PAutoInvestOptData;
  aItem, aItemc, aItemp : TInvestorData;
  stLog, stID, stCP : string;

begin

  if Length( stData ) < 50 then Exit;

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


    if string(vData.InvstCode) = '9999' then exit;

    stID := trim( string(vData.InvstCode ) );
    stLog := trim( string(vData.MktCdFogb ));
    if stLog = '0102' then
      stCP := 'C'
    else if stLog = '0103' then
      stCP := 'P'
    else Exit;

    aItem := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.New(stID, stCP);
    if aItem <> nil then
    begin
      aItem.BidQty :=  StrToIntDef(string(vData.BuyQty), 0);
      aItem.AskQty := StrToIntDef(string(vData.SellQty), 0);
      aItem.BidAmount := StrToFloatDef(string(vData.BuyAmt), 0) / 100;
      aItem.AskAmount := StrToFloatDef(string(vData.SellAmt), 0) / 100;
      aItem.SumQty := aItem.BidQty - aItem.AskQty;
      aItem.SumAmount := aItem.BidAmount - aItem.AskAmount;
    {
      if (stID = '9000')  then
      begin
        gEnv.EnvLog( WIN_GI, Format( '%s %s : 매수[ 수량 :%s, 금액 : %s ]  매도 [ 수량 : %s, 금액 : %s ]', [
          '외국인', stCP, string( vData.BuyQty ), string( vData.BuyAmt ),
          string( vData.SellQty) , string( vData.SellAmt )
          ]  ) );
      end;
    }
    end;


end;

// 시장 가격 
procedure TApiReceiver.ParseMarketPrice(stData: string);
var
  vData : ^TQuerySymbolInfo;
  aSymbol : TSymbol;
begin
  vData :=  @stData[1] ;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( Trim( string(vData.KrxCode) ));
  if aSymbol = nil then Exit;

  try
    with aSymbol do
    begin
      Last      := StrToFloatDef(Trim( string(vData.Last) ),0);

      PrevClose := StrToFloatDef(Trim( string(vData.PrevLast) ),0);
      Base      := StrToFloatDef(Trim( string(vData.Base) ),0);
      DayOpen   := StrToFloatDef(Trim( string(vData.Open) ),0);
      DayHigh   := StrToFloatDef(Trim( string(vData.High) ),0);
      DayLow    := StrToFloatDef(Trim( string(vData.Low) ),0);
        // control
      Tradable := True;
      MarketStatus := msNormal;
    end;
  except
    gEnv.OnLog( self, vData.Last );
  end;

end;

// Api  시간 
function TApiReceiver.GetApiTime( stTime : string ) : TDateTime;
begin
  Result := Date +
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                          StrToInt(Copy(stTime,3,2)), // min
                          StrToInt(Copy(stTime,5,2)), // sec
                          StrToInt(Copy(stTime,7,2)) *10 ); // msec}

end;



// 주문 승인 
procedure TApiReceiver.ParseOrderAck(iTrCode: integer; strData: string);
  var
    aOrder : TOrder;
    iOrderNo, iLocalNo : integer;
    aData : POutOrderResult;
    stRjt : string;
    bSucsess   : boolean;
begin

  try
    gEnv.EnvLog( WIN_PACKET, Format('Order_%d:%s', [  iTrCode, strData  ]) );

    aData := POutOrderResult( strData );
    stRjt :=  trim(string( aData.MsgCode ));

    iLocalNo := StrToIntDef( trim( string( aData.LocalNo )), 0);

    if ( stRjt = '' ) or ( stRjt = '00000' ) then begin
      bSucsess := true;
      stRjt    := '0000';
    end
    else
      bSucsess := false;
           
    aOrder    := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder2( iLocalNo );

    if aOrder = nil then begin
      gEnv.EnvLog( WIN_ORD, Format('%d : Not Found LocalNo(%d) order : %s, %s', [
        itrCode, iLocalNo, stRjt, strData  ]) );
      Exit;
    end;

    iOrderNo := StrToIntDef( trim( string( aData.OrderNo )), 0);
    if bSucsess then
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjt )
    else
      gEnv.Engine.TradeBroker.SrvReject( aOrder, stRjt, '' );

  except
  end;

end;

// 옵션 호가 파싱 
procedure TApiReceiver.ParseOptHoga(stData: string);
var
  vData  : ^TWooOptHoga;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  stTmp : string;
  dtQuote : TDateTime;
begin

  vData := @stData[1];

  aQuote  := gEnv.Engine.QuoteBroker.Find( Trim( vData.Code ));
  if aQuote = nil then Exit;

  try

  aQuote.SavePrevMarketDepths;
  stTmp := trim(string( vData.HogaTime ));

  if stTmp = ''  then
    dtQuote := now
  else
    dtQuote :=  GetApiTime( stTmp );

  aQuote.Asks.VolumeTotal := StrToInt( Trim( string( vData.TotAskVol )));
  aQuote.Asks.CntTotal    := StrToInt( Trim( string( vData.TotAskCnt )));

  aQuote.Bids.VolumeTotal := StrToInt( Trim( string( vData.TotBidVol )));
  aQuote.Bids.CntTotal    := StrToInt( Trim( string( vData.TotBidCnt )));

  aQuote.Asks[0].Price  := StrToFloat( Trim(string(vData.Hoga1.AskPrice)));
  aQuote.Asks[1].Price  := StrToFloat( Trim(string(vData.Hoga2.AskPrice)));
  aQuote.Asks[2].Price  := StrToFloat( Trim(string(vData.Hoga3.AskPrice)));
  aQuote.Asks[3].Price  := StrToFloat( Trim(string(vData.Hoga4.AskPrice)));
  aQuote.Asks[4].Price  := StrToFloat( Trim(string(vData.Hoga5.AskPrice)));

  aQuote.Bids[0].Price  := StrToFloat( Trim(string(vData.Hoga1.BidPrice)));
  aQuote.Bids[1].Price  := StrToFloat( Trim(string(vData.Hoga2.BidPrice)));
  aQuote.Bids[2].Price  := StrToFloat( Trim(string(vData.Hoga3.BidPrice)));
  aQuote.Bids[3].Price  := StrToFloat( Trim(string(vData.Hoga4.BidPrice)));
  aQuote.Bids[4].Price  := StrToFloat( Trim(string(vData.Hoga5.BidPrice)));

  aQuote.Asks[0].Volume  := StrToInt( Trim(string(vData.Hoga1.AskVolume)));
  aQuote.Asks[1].Volume  := StrToInt( Trim(string(vData.Hoga2.AskVolume)));
  aQuote.Asks[2].Volume  := StrToInt( Trim(string(vData.Hoga3.AskVolume)));
  aQuote.Asks[3].Volume  := StrToInt( Trim(string(vData.Hoga4.AskVolume)));
  aQuote.Asks[4].Volume  := StrToInt( Trim(string(vData.Hoga5.AskVolume)));

  aQuote.Bids[0].Volume  := StrToInt( Trim(string(vData.Hoga1.BidVolume)));
  aQuote.Bids[1].Volume  := StrToInt( Trim(string(vData.Hoga2.BidVolume)));
  aQuote.Bids[2].Volume  := StrToInt( Trim(string(vData.Hoga3.BidVolume)));
  aQuote.Bids[3].Volume  := StrToInt( Trim(string(vData.Hoga4.BidVolume)));
  aQuote.Bids[4].Volume  := StrToInt( Trim(string(vData.Hoga5.BidVolume)));

  aQuote.Asks[0].Cnt := StrToInt( Trim(string( vData.AskCnt1 )));
  aQuote.Asks[1].Cnt := StrToInt( Trim(string( vData.AskCnt2 )));
  aQuote.Asks[2].Cnt := StrToInt( Trim(string( vData.AskCnt3 )));
  aQuote.Asks[3].Cnt := StrToInt( Trim(string( vData.AskCnt4 )));
  aQuote.Asks[4].Cnt := StrToInt( Trim(string( vData.AskCnt5 )));

  aQuote.Bids[0].Cnt := StrToInt( Trim(string( vData.BidCnt1 )));
  aQuote.Bids[1].Cnt := StrToInt( Trim(string( vData.BidCnt2 )));
  aQuote.Bids[2].Cnt := StrToInt( Trim(string( vData.BidCnt3 )));
  aQuote.Bids[3].Cnt := StrToInt( Trim(string( vData.BidCnt4 )));
  aQuote.Bids[4].Cnt := StrToInt( Trim(string( vData.BidCnt5 )));

  aQuote.Update( dtQuote);
  except
  end;

end;

// 옵션 가격 파싱 
procedure TApiReceiver.ParseOptPrice(stData: string);
var
  vData  : ^TWooOptExec;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  stTmp : string;
  dtQuote : TDateTime;
  aSale: TTimeNSale;
  dTmp : double;
begin

  vData := @stData[1];

  aQuote  := gEnv.Engine.QuoteBroker.Find( Trim( vData.Code ));
  if aQuote = nil then Exit;

  stTmp := string( vData.Time );

  try
  aSale := aQuote.Sales.New;

  aSale.LocalTime := now;
   if stTmp = ''  then
    dtQuote := now
  else
    dtQuote :=  GetApiTime( stTmp );
    
  aSale.Time := dtQuote;
  aSale.DistTime    := stTmp;
  aQuote.QuoteTime  := stTmp;

  aSale.Volume  := StrToInt( Trim( string( vData.Volume )));
  aSale.Price   := StrToFloat( Trim( string( vData.Price )));

  if aSale.Price > aQuote.Asks[0].Price -  KRX_PRICE_EPSILON then
    aSale.Side  := 1
  else
    aSale.Side  := -1;

  aQuote.Open := StrToFloat( trim( string( vData.Open )));
  aQuote.High := StrToFloat( trim( string( vData.High )));
  aQuote.Low  := StrToFloat( trim( string( vData.Low )));
  aQuote.Last := aSale.Price;
  aQuote.Change :=  aSale.Price - aQuote.Symbol.PrevClose;

  aQuote.DailyVolume  := StrToInt( trim( string( vData.DailyVolume )));
  aQuote.DailyAmount  := StrToFloat( trim( string( vData.DailyAmount )));

  aQuote.Symbol.RealUpperLimit  := StrToFloatDef( trim( string( vData.DynamicUpperLimit )),0);
  aQuote.Symbol.RealLowerLimit  := StrToFloatDef( trim( string( vData.DynamicLowerLimit )),0);

    if (( aQuote.Symbol.LimitHigh + PRICE_EPSILON ) <  aQuote.Symbol.RealUpperLimit ) and
      ( aQuote.Symbol.RealUpperLimit > PRICE_EPSILON ) then begin
      dTmp := aQuote.Symbol.LimitHigh;
      aQuote.Symbol.LimitHigh := aQuote.Symbol.RealUpperLimit;
      gEnv.EnvLog(WIN_TEST, format( '%s %s  %.*f -> %.*f ', [
       aQuote.Symbol.ShortCode, '상한가 변동 ',
       aQuote.Symbol.Spec.Precision, dTmp,  aQuote.Symbol.Spec.Precision, aQuote.Symbol.RealUpperLimit]));
    end;

    if ( aQuote.Symbol.LimitLow + PRICE_EPSILON  > ( aQuote.Symbol.RealLowerLimit + PRICE_EPSILON  )) and
       ( aQuote.Symbol.RealLowerLimit > PRICE_EPSILON ) then begin
      dTmp := aQuote.Symbol.LimitLow;
      aQuote.Symbol.LimitLow := aQuote.Symbol.RealLowerLimit;
      gEnv.EnvLog(WIN_TEST, format( '%s %s   %.*f -> %.*f ', [
       aQuote.Symbol.ShortCode, '하한가 변동 ',
       aQuote.Symbol.Spec.Precision, dTmp,  aQuote.Symbol.Spec.Precision, aQuote.Symbol.RealLowerLimit]  ));
    end;
    
  aQuote.Update( aSale.Time );


  except
  end;

end;

// 주문 파싱 
procedure TApiReceiver.ParseOrder( strData: string);
  var
    bOutOrd : boolean;

    vData : POrderExec;
    stRjtCode, stTmp, stSub, stIP2, stIP : string;
    aInvest : TInvestor;
    aAccount: TAccount;
    aSymbol : TSymbol;
    iOrderNo, iOriginNo : int64;
    i, iLen, iSide, iStart, iLocalNo, iFillNo, iOrderQty, iCount, iConfirmedQty , iAbleQty: integer;
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
  iLen  := Sizeof( TOrderExec );
  //if Length(strData ) < iLen then Exit;
  gEnv.EnvLog( WIN_PACKET , format('RealOrdder(%d) : %s', [ Length(strData ),
    strData])  );

  try
      vData := POrderExec( strData );

      stTmp := 'RealDiv ';
      case vData.RealDiv of
        '1': stTmp := '1:단말용' ;
        '2': stTmp := '2:단말외' ;
        '3': stTmp := '3:복수계좌' ;
        '4': stTmp := '4:대외계' ;
      end;

      stTmp := stTmp + ' | DataDiv ';
      case vData.DataDiv[1] of
        '2' : stTmp := stTmp + ' 12:접수' ;
        '3' : stTmp := stTmp + ' 13:확인' ;
        '4' : stTmp := stTmp + ' 14:체결' ;
        '5' : stTmp := stTmp + ' 15:원주문데이타변경' ;
        '9' : stTmp := stTmp + ' 19:거부' ;
        else stTmp := stTmp + ' ' + string(vData.DataDiv)+ ':모지?';
      end;

      stTmp := stTmp + ' | ProcCode ';
      case vData.ProcCode of
       '1' : stTmp := stTmp + ' 1:접수전';
       '2' : stTmp := stTmp + ' 2:접수';
       '3' : stTmp := stTmp + ' 3:확인';
       '4' : stTmp := stTmp + ' 4:체결';
       '5' : stTmp := stTmp + ' 5:전량미체결';
       '9' : stTmp := stTmp + ' 9:거부';
       else stTmp := stTmp + ' ' + string(vData.ProcCode)+ ':모지?';
      end;
      case vData.OrderDiv of
        '1' : stSub := '신규';
        '2' : stSub := '정정';
        '3' : stSub := '취소';
        else stSub := 'None';
      end;
      gEnv.EnvLog( WIN_ORD,
        Format('%s, %s, %s, %s, %s, rjt:%s, %s', [ trim(vData.OrderStateNm),  stSub, stTmp,
          trim(string( vData.OrderNo)), trim(string(vData.OrgOrderNo)), trim(string(vData.RjctCode)),
          ifThenStr( vData.Side = '1', '매수','매도')
      ]));

      // 주문로그
      gEnv.EnvLog( WIN_ORD,
        Format('가격(%s) 주문(%s) 체결(%s) 취소확인(%s) 정정(%s) 취소(%s) 남은(%s)', [
          trim(string( vData.Price) ),trim(string( vData.Qty )), trim(string( vData.FillQty )),
          trim(string( vData.CnlConfrimQty )), trim(string( vData.ModifyQty)),
          trim(string( vData.CancelQty )),  trim(string( vData.RemainQty )) ])
        );

      aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( vData.AcntNo )) );
      if aInvest = nil then Exit;
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string(vData.KrxCode)));
      if aSymbol = nil then Exit;

      iOrderNo      := StrToInt64Def( trim(string(vData.OrderNo )),0);
      iOriginNo     := StrToInt64Def( trim(string(vData.OrgOrderNo)),0);

      iOrderQty     := StrToIntDef( trim(string( vData.Qty )), 0);
      // '2' 일때는 체결수량  '3,4,5,6' 일때는..확인수량..
      iConfirmedQty := StrToIntDef( trim(string( vData.CnlConfrimQty )), 0);

      stRjtCode := trim( string( vData.RjctCode ));
      //bAccepted := (iOrderNo > 0) and ( (stRjtCode = '0000000000') or (stRjtcode = ''))  ;

      case vData.ProcCode of
        '9' : bAccepted := false;
        else bAccepted := true;
      end;

      stTmp  := trim( string( vData.OrderInputTime ));
      dtTime :=  Date +
                      EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                                 StrToIntDef(Copy(stTmp,3,2),0),
                                 StrToIntDef(Copy(stTmp,5,2),0),
                                 StrToIntDef(Copy(stTmp,7,2),0)*10);

      aAccount  := aInvest.RceAccount;
      aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);


      if aOrder = nil then
      begin
        stIP      := trim(string( vData.OrderIP ));
        stIP2     := gEnv.Engine.Api.OwnIP;

        if stIP = stIP2 then
        begin
          iLocalNo  := iOrderNo;//StrToIntDef( trim( string( vData.User_Field )), 0);
          aOrder    := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder(
            aInvest.Code, aSymbol, iLocalNo );

          if aOrder <> nil then begin
            gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode );
            genv.EnvLog( WIN_ORD, Format('주문 ack 역전 - (%d)%s ',[ iOrderNo, aOrder.Represent3 ])  );
          end;
        end;

      end;



      bOutOrd := false;
      // 외부 주문이란 애기
      if (aOrder = nil) then
      begin
        bOutOrd := true;

        if vData.Side = '1' then
          iSide := 1
        else
          iSide := -1;

        iOrderQty := StrToInt( trim( string( vDAta.Qty )));
        dPrice    := StrToFloatDef( trim(string( vData.Price )), 0);

        case vDAta.PriceType of
          '1' : pcValue := pcLimit;
          '2' : pcValue := pcMarket;
          '3' : pcValue := pcLimitToMarket;
          '4' : pcValue := pcBestLimit;
        end;

        case vData.FillDiv of
          '1' : tmValue  := tmFAS;
          '3' : tmValue  := tmGTC;
          '2' : tmValue  := tmFOK;
        end;

        case vData.OrderDiv of
          '1' : otValue := otNormal;
          '2' : otValue := otChange;
          '3' : otValue := otCancel;
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
       {
신규  DataDiv  12:접수 | ProcCode  2:접수

취소  DataDiv  13:확인 | ProcCode  3:확인
      DataDiv  15:원주문데이타변경 | ProcCode  2:접수

정정  DataDiv  12:접수 | ProcCode  2:접수
      DataDiv  15:원주문데이타변경 | ProcCode  2:접수
      }

      if (( vData.OrderDiv = '1') and ( vData.ProcCode = '2') and ( vData.DataDiv[1] = '2' )) or 
         (  vData.ProcCode = '9') then
        // 신규 접수  & 거부
        gEnv.Engine.TradeBroker.Accept( aOrder, bAccepted, stRjtCode, dtTime )

      else if (( vData.ProcCode = '3') and ( vData.DataDiv[1] = '3' )) or       // 취소확인
              (( vData.ProcCode = '2') and ( vData.DataDiv[1] = '2' ))  then     // 정정학인
      begin
        // 취소 or 정정 확인
        if vData.OrderDiv = '2' then
          iConfirmedQty   := iOrderQty;
        
        aResult := gEnv.Engine.TradeCore.OrderResults.New(
                            aInvest, aSymbol, iOrderNo,
                            orConfirmed, Now, 0, stRjtCode, iConfirmedQty, dPrice, dtTime);
        gEnv.Engine.TradeBroker.Confirm(aResult, Now);        
      end
      else if ( vData.DataDiv[1] = '5' ) then      
        Exit
      else if vData.ProcCode = '4' then
      begin                
        dFilledPrice  := StrToFloat( trim( string( vData.FillPrice2 )));
        iFillNo       := StrToInt( trim(string(vData.FillNo )));
        iConfirmedQty := StrToInt( trim(string(vData.FillQty2 )));

        stTmp  := trim( string( vData.FillTime ));
        dtTime :=  Date +
                        EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                                   StrToIntDef(Copy(stTmp,3,2),0),
                                   StrToIntDef(Copy(stTmp,5,2),0),
                                   StrToIntDef(Copy(stTmp,7,2),0)*10);


        aResult := gEnv.Engine.TradeCore.OrderResults.New(
                  aInvest, aSymbol, iOrderNo, orFilled, now,
                  iFillNo , '',iConfirmedQty,
                  dFilledPrice, dtTime);
        gEnv.Engine.TradeBroker.Fill( aResult, dtTime);                
      end;    

  except
  end;

end;


end.
