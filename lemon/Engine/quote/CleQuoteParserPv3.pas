unit CleQuoteParserPv3;

interface

uses Classes, SysUtils, Windows, Dialogs,

    // lemon:
  CleQuoteBroker, CleSymbols, CleQuoteParserIF,
    // Lemon: utilities
  CleParsers,  GleConsts,  UUdpPacketpv3,
  CleKrxSymbols, CleOtherData,
  CleFQn;

const
  MARKET_DEPTH_SIZE = 5;
  CloseSingle = '30';
  TradeSingle = '20';
  OpenSingle = '10';
  SisConnected  = '40';

type
  TQuoteParserPv3 = class( TIFQuoteParser )
  private
      // parse
    procedure ParseKOSPI200Index(stData : String);
    procedure ParseKOSPI200IndexExpect(stData : String);

    procedure ParseKOSPI200FuturesMarketDepth(stData : String);
    procedure ParseKOSPI200FuturesTimeNSale(stData : String);
    procedure ParseKOSPI200OptionMarketDepth(stData : String);
    procedure ParseKOSPI200OptionTimeNSale(stData : String);

    procedure ParseKRXStockMarketDepth(stData : String);
    procedure ParseKRXStockTimeNSale( stData : string );
    procedure ParseKRXELWMarketDepth(stData : String);
    procedure ParseElwGreeks( stData : string );

    procedure ParseKospiStockVolumeTotal(stData : String);

    procedure ParseStockFuturesMarketDepth( stData : string );
    procedure ParseStockFuturesTimeNSale( stData : string );

    // fill & price
    procedure ParseKOSPI200FuturesTimeNSaleNMarketDepth( stData : string );
    procedure ParseKOSPI200OptionsTimeNSaleNMarketDepth( stData : string );
    procedure ParseKOSPI200StockFuturesTimeNSaleNMarketDepth( stData : string );

    procedure ParserOptionGreeks(stData: string);
    procedure ParseVKOSPIIndex( stData : string );
    procedure ParseCPPPIIndex( stData : string );
    procedure ParseK200RiskIndex(stData: string);
    procedure ParseFKOSPIIndex(stData: string);
    procedure ParseFutOpenInterset( stData :string );
    procedure ParseOptOpenInterset( stData :string );
    procedure ParseOptRecovery( stData : string );
    procedure ParseInvestorData( stData : string );
    procedure ParseInvestorFutData( stData : string );

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(stData : String); override;
    procedure Parser( pData : PChar; iSize : Integer ); override;
  end;

implementation

uses GleTypes, GAppEnv, GleLib, CleQuoteTimers, CleInvestorData,
  Math;


{ TQuoteParserPv2 }

constructor TQuoteParserPv3.Create;
begin
  inherited;
end;

destructor TQuoteParserPv3.Destroy;
begin
  inherited;
end;

procedure TQuoteParserPv3.Parse(stData: String);
var
  stTR, stInfo, stSave, stUdp : String;
  pComm : PCommonHeader;
begin
  Inc(FParseCount);

  //stData:= Copy(stData, 14,Length(stData));  // VFEP???? ???? ???????? ????????.....
  pComm := PCommonHeader( stData );
  if Length( stData ) < 10 then Exit;

  try
    stSave  := stData;

    stTR := string( pComm.DataDiv );
    stInfo  := string( pComm.InfoDiv );
    stUdp := stTR + stInfo;

    if stTR <> TrK200expect then
      stData := Copy(stData, LenSymbolHeader + 1,  Length( stData ));

    if stTR = TrFill then
    begin

      if pComm.MarketDiv = StockNElw then
        ParseKRXStockTimeNSale( stData )
      else if pComm.MarketDiv = StockDer then
        ParseStockFuturesTimeNSale( stData )
      else if (pComm.MarketDiv = IndexDer) and ( stInfo = FutInfo) then
        ParseKOSPI200FuturesTimeNSale( stData )
      else if (pComm.MarketDiv = IndexDer) and ( stInfo = OptInfo) then
        ParseKOSPI200OptionTimeNSale( stData );

    end else
    if stTR = TrHoga then
    begin

      if pComm.MarketDiv = StockNElw then
        ParseKRXStockMarketDepth( stData )
      else if pComm.MarketDiv = StockDer then
        ParseStockFuturesMarketDepth( stData )
      else if (pComm.MarketDiv = IndexDer) and ( stInfo = FutInfo) then
        ParseKOSPI200FuturesMarketDepth( stData )
      else if (pComm.MarketDiv = IndexDer) and ( stInfo = OptInfo) then
        ParseKOSPI200OptionMarketDepth( stData );


    end else
    if stTR = TrFillNHoga then
    begin

      if pComm.MarketDiv = StockDer then
        ParseKOSPI200StockFuturesTimeNSaleNMarketDepth( stData )
      else if (pComm.MarketDiv = IndexDer) and ( stInfo = FutInfo) then
        ParseKOSPI200FuturesTimeNSaleNMarketDepth( stData )
      else if (pComm.MarketDiv = IndexDer) and ( stInfo = OptInfo) then
        ParseKOSPI200OptionsTimeNSaleNMarketDepth( stData );

    end else
    if stTR = TrElwHoga then
      ParseKRXELWMarketDepth(stData)
    else
    if stTR = TrK200 then
      ParseKOSPI200Index( stData )
    else
    if stTR = TrK200expect then
      ParseKOSPI200IndexExpect( stData)
    else
    if stTR = TrElwGreeks then
      ParseElwGreeks( stData)
    else
    if stTR = TrVKOSPI then
      ParseVKOSPIIndex( stData )
    else
    if stTR = TrFKOSPI then
      ParseFKOSPIIndex( stData )
    else
    if stTR = TrCPPP then
      ParseCPPPIIndex( stData )
    else
    if stTR = TrK200Risk  then
      ParseK200RiskIndex( stData )
    else
    if stTR = TrOpenInterest then
    begin
      if stInfo = FutInfo then
        ParseFutOpenInterset( stData )
      else if stInfo = OptInfo then
        ParseOptOpenInterset( stData );
    end
    else
    if stTR = TrRecovery then
      ParseOptRecovery( stData )
    else
    if stTR = TrInvestorData then
    begin
      if stInfo = FutInfo then
        ParseInvestorFutData(stData)
      else if stInfo = OptInfo then
        ParseInvestorData(stData)   ;
    end
    else
      Exit;

  except
    //gEnv.EnvLog( WIN_ERR, stData);
  end;

end;

procedure TQuoteParserPv3.ParseCPPPIIndex(stData: string);
var
  vData : PCP_PPIndexData;
  stTime : string;
  aTime  : TDateTime;
  dCP, dPP: double;
begin
  if Length( stData ) < LenCP_PPIndexData then
    Exit;

  vData := PCP_PPIndexData( stData );

  try
    if string(vData.IndustCode ) <> '   ' then Exit;

    stTime := string( vData.Indextime );
    aTime  := FQuoteDate
               + EncodeTime(
                            StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)),
                            0
                            ); // sec

    if vData.CPSign = '-' then
      dCP := -1* ( strtoint(string(vData.CPIndex)) / 100 )
    else
      dCP := ( strtoint(string(vData.CPIndex)) / 100 );

    if vData.PPSign = '-' then
      dPP := -1* ( strtoint(string(vData.PPIndex)) / 100 )
    else
      dPP := ( strtoint(string(vData.PPIndex)) / 100 );

    stTime  := Format('%s : CP-%.2f, PP-%.2f ', [
      FormatDateTime('hh:nn:ss', aTime ), dCP, dPP  ]);


    gEnv.EnvLog( WIN_SIS, stTime );


  except
  end;
end;

procedure TQuoteParserPv3.ParseElwGreeks(stData: string);
var
  vData : PElwGreeks;
  stCode  : string;
  aQuote  : TQuote;
  aSymbol : TElw;
begin
  if Length( stData ) < LenElwGreeks then
    Exit;

  vData := pElwGreeks( stData );

  try
    stCode  := Trim( string( vData.Code ));
    aQuote  := gEnv.Engine.QuoteBroker.Find( stCode );
    if aQuote = nil then Exit;

    aSymbol := aQuote.Symbol as TElw;

    aSymbol.Theory  := StrToInt( string( vData.Theory )) / 100;
    if vData.DeltaSign = '-' then
      aSymbol.Delta   := -StrToInt64( string( vData.Delta )) / 1000000
    else
      aSymbol.Delta   := StrToInt64( string( vData.Delta )) / 1000000;

    if vData.ThetaSign = '-' then
      aSymbol.Theta   := -StrToInt64( string( vData.Theta )) / 1000000
    else
      aSymbol.Theta   := StrToInt64( string( vData.Theta )) / 1000000;

    aSymbol.Vega    := StrToInt64( string( vData.Vega )) / 1000000;

    if vData.RhoSign = '-' then
      aSymbol.Low     := -StrToInt64( string( vData.Rho )) / 1000000
    else
      aSymbol.Low     := StrToInt64( string( vData.Rho )) / 1000000;

    aSymbol.IV      := StrToInt64( string( vData.IV )) / 100;

  except
  end;

end;

procedure TQuoteParserPv3.ParseFKOSPIIndex(stData: string);
var
  vData : PIndexData;
  stTime : string;
  aTime  : TDateTime;
begin
  if Length( stData ) < LenIndex then
    Exit;

  vData := PIndexData( stData );

  try
    if string(vData.IndustCode ) <> '   ' then Exit;

    stTime := string( vData.Indextime );
    aTime  := FQuoteDate
               + EncodeTime(
                            StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)),
                            0
                            ); // sec


    stTime  := Format('%s : FK %.2f, %s ', [
      FormatDateTime('hh:nn:ss', aTime ), strToint(string( vData.IndexPrice )) / 100,
      vData.Sign
      ]);


    gEnv.EnvLog( WIN_SIS, stTime );


  except
  end;
end;

procedure TQuoteParserPv3.ParseFutOpenInterset(stData: string);
var
  vData : PFutOpenInterest;
  aSymbol : TDerivative;
begin
  if Length( stData ) < LenFutOpenInterest then
    Exit;

  vData := PFutOpenInterest( stData );

  try
    aSymbol := gEnv.Engine.SymbolCore.Options.Find( string( vData.Code )) as TDerivative;
    if aSymbol = nil then
      Exit;

    if string(vData.OIDiv) = 'M0' then   // ????????
      aSymbol.PrevOI := StrToIntDef( string( vData.OIQty ), 0 )
    else
      aSymbol.OI := StrToIntDef( string( vData.OIQty ), 0 );
  except
  end;
end;

procedure TQuoteParserPv3.ParseK200RiskIndex(stData: string);
var
  vData : PIndexData;
  stDiv, stTime : string;
  aTime  : TDateTime;
begin
  if Length( stData ) < LenIndex then
    Exit;

  vData := PIndexData( stData );

  try

    if string(vData.IndustCode ) = K200Risk6Per then
      stDiv := '6%'
    else
    if string(vData.IndustCode ) = K200Risk8Per then
      stDiv := '8%'
    else
    if string(vData.IndustCode ) = K200Risk10Per then
      stDiv := '10%'
    else
    if string(vData.IndustCode ) = K200Risk12Per then
      stDiv := '12%'
    else
      Exit;

    stTime := string( vData.Indextime );
    aTime  := FQuoteDate
               + EncodeTime(
                            StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)),
                            0
                            ); // sec


    stTime  := Format('%s : %s %.2f, %s ', [
      FormatDateTime('hh:nn:ss', aTime ), stDiv, strToint(string( vData.IndexPrice )) / 100,
      vData.Sign
      ]);

    gEnv.EnvLog( WIN_SIS, stTime );


  except
  end;
end;

procedure TQuoteParserPv3.ParseKOSPI200FuturesMarketDepth(stData: String);
var
  aQuote: TQuote;
  dtQuote: TDateTime;
  vData : PFutPrice;
  stCode, stTime , stCon : string;
  i : integer;
  bUpdate : boolean;

begin

  if Length( stData ) < LenFutPrice  then
    Exit;

  vData := PFutPrice( stData );
  aQuote  := FQuoteBroker.Find( string(vData.Code) );
  if aQuote = nil then Exit;

  try
    stCon := string(vData.SessionID);

    if ( stCon = CloseSingle ) or ( stCon = TradeSingle ) then
    begin
      aQuote.SavePrevMarketDepths;
      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
      aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));
      gEnv.QuoteSpeed.DoFutDelay := false;
    end
    else begin
      gEnv.QuoteSpeed.DoFutDelay := true;
      aQuote.SavePrevMarketDepths;
      stTime  := string( vData.AcptTime );
      dtQuote := FQuoteDate
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,3,2)), // min
                              StrToInt(Copy(stTime,5,2)), // sec
                              StrToInt(Copy(stTime,7,2)) *10 ); // msec}
      aQuote.QuoteTime  := stTime;
      aQuote.MarketState  := string( vData.SessionID );


      for i := 0 to aQuote.Asks.Size - 1 do
      begin
        aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price )) / 100;
        if vData.AskItems[i].Sign = '-' then
          aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;
        aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

        aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price )) / 100;
        if vData.BidItems[i].Sign = '-' then
          aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
        aQuote.Bids[i].Volume := StrToInt( string( vData.BidItems[i].Volume ));
      end;

      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
      aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));

      aQuote.Asks[0].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
      aQuote.Asks[1].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
      aQuote.Asks[2].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
      aQuote.Asks[3].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
      aQuote.Asks[4].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
        // number of long orders

      aQuote.Bids[0].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
      aQuote.Bids[1].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
      aQuote.Bids[2].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
      aQuote.Bids[3].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
      aQuote.Bids[4].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));

    end;

    if (stCon = OpenSingle) or (stCon = TradeSingle) or (stCon = CloseSingle) then
    begin
      aQuote.Symbol.ExpectPrice := StrToInt(string(vData.ExpectPrice)) / 100;
      if vData.ExpectSign = '-' then
        aQuote.Symbol.ExpectPrice := aQuote.Symbol.ExpectPrice * -1;
    end;

    if stCon = OpenSingle then
      aQuote.Symbol.OpenSingle := aQuote.Symbol.ExpectPrice
    else if stCon = CloseSingle then
        aQuote.Symbol.CloseSingle := aQuote.Symbol.ExpectPrice
    else if stCon = TradeSingle then
        aQuote.Symbol.TradeSingle := aQuote.Symbol.ExpectPrice;
       
      // apply
    aQuote.Update(dtQuote);
  except
    // do something here
  end;

end;

procedure TQuoteParserPv3.ParseKOSPI200FuturesTimeNSale(stData: String);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  stCode, stTime : string;
  vData : PFutTick ;
  iDailyVol : integer;
begin

  if Length( stData ) < LenFutTick then
    Exit;

  vData := PFutTick( stData );

  aQuote  := FQuoteBroker.Find( string(vData.Code) );

  if aQuote = nil then Exit; // no subscription for this symbol

  stTime  := string( vData.TickTime );
    // translation
  try
      // new time&sale
    iDailyVol := StrToInt( string( vData.DailyVolume ));

    if gEnv.RunMode = rtRealTrading then
    begin
      if aQuote.DailyVolume >= iDailyVol then
        Exit;
    end;
    
    aSale := aQuote.Sales.New;

    aSale.LocalTime := GetQuoteTime;
    aSale.Time := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            StrToInt(Copy(stTime,7,2)) *10 ); // msec}
    aSale.DistTime    := stTime;
    aQuote.QuoteTime  := stTime;

    aSale.Volume := StrToInt( string( vData.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.CurPrice ) ) / 100;
    if vData.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    aSale.PrevPrice := StrToInt( string( vData.PrevPrice ) ) / 100;
    if vData.PrevSign = '-' then
      aSale.PrevPrice := aSale.PrevPrice * -1;
        // side
    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C
    aQuote.Open := StrToInt( string( vData.OpenPrice )) / 100;
    if vData.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.HighPrice )) / 100;
    if vData.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.LowPrice )) / 100;
    if vData.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    aQuote.Last := aSale.Price;
    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

    aQuote.DailyVolume  := iDailyVol;
    aQuote.DailyAmount  := StrToFloat( string( vData.DailyPrice ));

    aSale.DayVolume := aQuote.DailyVolume ;
    aSale.DayAmount := aQuote.DailyAmount ;

    aQuote.Symbol.RealUpperLimit := StrToInt( string( vData.RealUpperLimit )) / 100;
    if vData.RealUpperLimitSign = '-' then
      aQuote.Symbol.RealUpperLimit := aQuote.Symbol.RealUpperLimit * -1;

    aQuote.Symbol.RealLowerLimit := StrToInt( string( vData.RealLowerLimit )) / 100;
    if vData.RealLowerLimit = '-' then
      aQuote.Symbol.RealLowerLimit := aQuote.Symbol.RealLowerLimit * -1;
      //
    aQuote.Update(aSale.Time, 1);

  except
    // do something here
  end;

end;

procedure TQuoteParserPv3.ParseKOSPI200FuturesTimeNSaleNMarketDepth(
  stData: string);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  stCode, stTime : string;
  vData : PFutTickPrice ;
  iDailyVol, iSize, i : integer;
begin

  iSize := Length( stData );
  if iSize < LenFutTickPrice then
    Exit;

  vData := PFutTickPrice( stData );

  aQuote  := FQuoteBroker.Find( string(vData.Code) );
  if aQuote = nil then Exit;
  aQuote.SavePrevMarketDepths;

  stTime  := string( vData.TickTime );
    // translation
  try
      // new time&sale
    iDailyVol := StrToInt( string( vData.DailyVolume ));

    if gEnv.RunMode = rtRealTrading then
    begin
      if aQuote.DailyVolume >= iDailyVol then
        Exit;
    end;

    aSale := aQuote.Sales.New;

    aSale.LocalTime := GetQuoteTime;
    aSale.Time := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            StrToInt(Copy(stTime,7,2)) *10 ); // msec}
    aSale.DistTime    := stTime;
    aQuote.QuoteTime  := stTime;


    aSale.Volume := StrToInt( string( vData.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.CurPrice ) ) / 100;
    if vData.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    aSale.PrevPrice := StrToInt( string( vData.PrevPrice ) ) / 100;
    if vData.PrevSign = '-' then
      aSale.PrevPrice := aSale.PrevPrice * -1;
        // side
    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C

    aQuote.Open := StrToInt( string( vData.OpenPrice )) / 100;
    if vData.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.HighPrice )) / 100;
    if vData.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.LowPrice )) / 100;
    if vData.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    aQuote.Last := aSale.Price;
    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

    aQuote.DailyVolume  := iDailyVol;
    aQuote.DailyAmount  := StrToFloat( string( vData.DailyPrice ));
    aSale.DayVolume := aQuote.DailyVolume ;
    aSale.DayAmount := aQuote.DailyAmount ;
      //

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price )) / 100;
      if vData.AskItems[i].Sign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;
      aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

      aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price )) / 100;
      if vData.BidItems[i].Sign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
      aQuote.Bids[i].Volume := StrToInt( string( vData.BidItems[i].Volume ));
    end;

    aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

    aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
    aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));

    aQuote.Asks[0].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
    aQuote.Asks[1].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
    aQuote.Asks[2].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
    aQuote.Asks[3].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
    aQuote.Asks[4].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
      // number of long orders

    aQuote.Bids[0].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
    aQuote.Bids[1].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
    aQuote.Bids[2].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
    aQuote.Bids[3].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
    aQuote.Bids[4].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));

    aQuote.Symbol.RealUpperLimit := StrToInt( string( vData.RealUpperLimit )) / 100;
    if vData.RealUpperLimitSign = '-' then
      aQuote.Symbol.RealUpperLimit := aQuote.Symbol.RealUpperLimit * -1;

    aQuote.Symbol.RealLowerLimit := StrToInt( string( vData.RealLowerLimit )) / 100;
    if vData.RealLowerLimit = '-' then
      aQuote.Symbol.RealLowerLimit := aQuote.Symbol.RealLowerLimit * -1;
    aQuote.Update(aSale.Time);
  except
  end;
end;

procedure TQuoteParserPv3.ParseKOSPI200Index(stData: String);
var
  aQuote: TQuote;
  dtQuote: TDateTime;
  vData : pIndexData;
  aSale: TTimeNSale;
  iDailyVolume: int64;
  stCode, stTime  : string;
  i : integer;
begin

  if Length( stData ) < LenIndex  then
    Exit;

  vData := pIndexData( stData );

  try
      // compare code
    if CompareStr( string( vData.IndustCode ), K200Indust ) <> 0 then Exit;

    aQuote := FQuoteBroker.Find(KOSPI200_CODE);
    if aQuote = nil then Exit; // nobody subscribed

      // new time & sale
    aSale := aQuote.Sales.New;

    aSale.Price := StrToInt( string( vData.IndexPrice )) / 100;
    stTime := string( vData.Indextime );
    aSale.LocalTime := GetQuoteTime;
    aSale.Time := FQuoteDate
                    + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                                 StrToInt(Copy(stTime,3,2)), // min
                                 StrToInt(Copy(stTime,5,2)), // sec
                                 0); // msec
    iDailyVolume := StrToInt64( string( vData.Volume ));
    if aQuote.Sales.Prev <> nil then
      aSale.Volume := iDailyVolume - aQuote.DailyVolume
    else
      aSale.Volume  := 0;
    aSale.Side := 0;

    aQuote.Last := aSale.Price;
    aQuote.Change := StrToInt( string( vData.Change )) / 100;
    if vData.Sign = '-' then
      aQuote.Change := -1 * aQuote.Change;

      // trading info
    aQuote.DailyVolume := iDailyVolume;
    aQuote.DailyAmount := StrToFloat( string( vData.Amount ));
    aQuote.OpenInterest := 0;

      // apply
    aQuote.Update(aSale.Time);
  except
    // do something here
  end;

end;

procedure TQuoteParserPv3.ParseKOSPI200IndexExpect(stData: String);
var
  aQuote: TQuote;
  dtQuote: TDateTime;
  vData : PIndexExpectData;
  aSale: TTimeNSale;
  iDailyVolume: int64;
  stCode, stTime  : string;
  i : integer;
begin
if Length( stData ) < LenExpectIndex  then
    Exit;

  vData := PIndexExpectData( stData );

  try
    aQuote := FQuoteBroker.Find(KOSPI200_CODE);
    if aQuote = nil then Exit; // nobody subscribed

      // new time & sale
    aSale := aQuote.Sales.New;

    aSale.Price := StrToIntDef( string( vData.expectPrice ),0) / 100;
    stTime := string( vData.expecttime );
    aSale.Time := FQuoteDate
                    + EncodeTime(StrToIntDef(Copy(stTime,1,2),0), // hour
                                 StrToIntDef(Copy(stTime,4,2),0), // min
                                 StrToIntDef(Copy(stTime,7,2),0), // sec
                                 0); // msec
    aQuote.Last := aSale.Price;

      // apply
    aQuote.Update(aSale.Time);
  except
    // do something here
  end;
end;

procedure TQuoteParserPv3.ParseKOSPI200OptionMarketDepth(stData: String);
var
  aQuote: TQuote;
  dtQuote: TDateTime;
  vData : POptPrice;
  stCode, stTime, stCon  : string;
  i : integer;
begin
  if Length( stData ) < LenOptPrice  then
    Exit;

  vData := POptPrice( stData );
  aQuote  := FQuoteBroker.Find( string(vData.Code) );

  if aQuote = nil then Exit;

  try
    stCon := string(vData.SessionID);

    if ( stCon = CloseSingle ) or ( stCon = TradeSingle ) then
    begin
      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
      aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));
      gEnv.QuoteSpeed.DoOptDelay := false;
    end
    else begin
      gEnv.QuoteSpeed.DoOptDelay := true;
      aQuote.SavePrevMarketDepths;
      stTime  := string( vData.AcptTime );
      // translate

      dtQuote := FQuoteDate
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,3,2)), // min
                              StrToInt(Copy(stTime,5,2)), // sec
                              StrToInt(Copy(stTime,7,2)) *10 ); // msec}
      aQuote.QuoteTime  := stTime;
      
      for i := 0 to aQuote.Asks.Size - 1 do
      begin
        aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price ) ) / 100;
        aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

        aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price )) / 100;
        aQuote.Bids[i].Volume := StrToint( string( vData.BidItems[i].Volume ));
      end;

      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
      aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));

      aQuote.Asks[0].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
      aQuote.Asks[1].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
      aQuote.Asks[2].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
      aQuote.Asks[3].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
      aQuote.Asks[4].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
        // number of long orders

      aQuote.Bids[0].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
      aQuote.Bids[1].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
      aQuote.Bids[2].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
      aQuote.Bids[3].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
      aQuote.Bids[4].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));
    end;

    if (stCon = OpenSingle) or (stCon = TradeSingle) or (stCon = CloseSingle) then
      aQuote.Symbol.ExpectPrice := StrToInt(string(vData.ExpectPrice)) / 100;

    if stCon = OpenSingle then
      aQuote.Symbol.OpenSingle := aQuote.Symbol.ExpectPrice
    else if stCon = CloseSingle then
        aQuote.Symbol.CloseSingle := aQuote.Symbol.ExpectPrice
    else if stCon = TradeSingle then
        aQuote.Symbol.TradeSingle := aQuote.Symbol.ExpectPrice;


    aQuote.Update(dtQuote);
  except
    // do something here
  end;

end;

procedure TQuoteParserPv3.ParseKOSPI200OptionsTimeNSaleNMarketDepth(
  stData: string);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  stCode, stTime : string;
  vData : POptTickPrice;
  iDailyVol, i : integer;
begin
  if Length( stData ) < LenOptTickPrice then
    Exit;

  vData := POptTickPrice( stData );

  aQuote  := FQuoteBroker.Find( string(vData.Code) );
  if aQuote = nil then Exit; // no subscription for this symbol
  aQuote.SavePrevMarketDepths;

  stTime  := string( vData.TickTime );
    // translation
  try
      // new time&sale
    iDailyVol := StrToInt( string( vData.DailyVolume ));

    if gEnv.RunMode = rtRealTrading then
    begin
      if aQuote.DailyVolume >= iDailyVol then
        Exit;
    end;

    aSale := aQuote.Sales.New;
    aSale.LocalTime := GetQuoteTime;
    aSale.Time := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            StrToInt(Copy(stTime,7,2)) *10 ); // msec}
    aSale.DistTime    := stTime;
    aQuote.QuoteTime  := stTime;

    aSale.Volume := StrToInt( string( vData.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.CurPrice ) ) / 100;
    aSale.PrevPrice := StrToInt( string( vData.PrevPrice ) ) / 100;
        // side
    if aQuote.Asks[0].Price > 0 then
    begin
      if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
        aSale.Side := 1
      else
        aSale.Side := -1;
    end
    else begin
      if  aSale.Price < aQuote.Bids[0].Price + KRX_PRICE_EPSILON then
        aSale.Side := -1
      else
        aSale.Side := 1;
    end;

    aQuote.Open := StrToInt( string( vData.OpenPrice )) / 100;
    aQuote.High := StrToInt( string( vData.HighPrice )) / 100;
    aQuote.Low := StrToInt( string( vData.LowPrice )) / 100;

    aQuote.Last := aSale.Price;
    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

    aQuote.DailyVolume  := iDailyVol;
    aQuote.DailyAmount  := StrToFloat( string( vData.DailyPrice ));

    aSale.DayVolume := aQuote.DailyVolume ;
    aSale.DayAmount := aQuote.DailyAmount ;


    for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price ) ) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

      aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price )) / 100;
      aQuote.Bids[i].Volume := StrToint( string( vData.BidItems[i].Volume ));
    end;

    aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

    aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
    aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));

    aQuote.Asks[0].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
    aQuote.Asks[1].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
    aQuote.Asks[2].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
    aQuote.Asks[3].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
    aQuote.Asks[4].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
      // number of long orders

    aQuote.Bids[0].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
    aQuote.Bids[1].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
    aQuote.Bids[2].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
    aQuote.Bids[3].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
    aQuote.Bids[4].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));

    aQuote.Symbol.RealUpperLimit := StrToInt( string( vData.RealUpperLimit )) / 100;
    aQuote.Symbol.RealLowerLimit := StrToInt( string( vData.RealLowerLimit )) / 100;
      //
    aQuote.Update(aSale.Time, 2);
  except
    // do something here
  end;
end;

procedure TQuoteParserPv3.ParseKOSPI200OptionTimeNSale(stData: String);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  stCode, stTime : string;
  vData : POptTick;
  iDailyVol : integer;
begin
  if Length( stData ) < LenOptTick then
    Exit;

  vData := POptTick( stData );
  aQuote  := FQuoteBroker.Find( string(vData.Code) );
  if aQuote = nil then Exit; // no subscription for this symbol

  stTime  := string( vData.TickTime );

  try
      // new time&sale
    iDailyVol := StrToInt( string( vData.DailyVolume ));

    if gEnv.RunMode = rtRealTrading then
    begin
      if aQuote.DailyVolume >= iDailyVol then
        Exit;
    end;
    
    aSale := aQuote.Sales.New;

    aSale.LocalTime := GetQuoteTime;
    aSale.Time := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            StrToInt(Copy(stTime,7,2)) *10 ); // msec}
    aSale.DistTime    := stTime;
    aQuote.QuoteTime  := stTime;

    aSale.Volume := StrToInt( string( vData.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.CurPrice ) ) / 100;
    aSale.PrevPrice := StrToInt( string( vData.PrevPrice ) ) / 100;
        // side
    if  aSale.Price > aQuote.Asks[0].Price- KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

    aQuote.Open := StrToInt( string( vData.OpenPrice )) / 100;
    aQuote.High := StrToInt( string( vData.HighPrice )) / 100;
    aQuote.Low := StrToInt( string( vData.LowPrice )) / 100;

    aQuote.Last := aSale.Price;
    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

    aQuote.DailyVolume  := iDailyVol;
    aQuote.DailyAmount  := StrToFloat( string( vData.DailyPrice ));

    aSale.DayVolume := aQuote.DailyVolume ;
    aSale.DayAmount := aQuote.DailyAmount ;

    aQuote.Symbol.RealUpperLimit := StrToInt( string( vData.RealUpperLimit )) / 100;
    aQuote.Symbol.RealLowerLimit := StrToInt( string( vData.RealLowerLimit )) / 100;

      //
    aQuote.Update(aSale.Time, 1);
  except
    // do something here
  end;
end;

procedure TQuoteParserPv3.ParseKOSPI200StockFuturesTimeNSaleNMarketDepth(
  stData: string);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  vData : PStockFutTickPrice;
  stCode, stTime  : string;
  i : integer;
begin

  if Length( stData ) < LenStockFutTickPrice then
    Exit;

  vData := PStockFutTickPrice( stData );

  aQuote  := FQuoteBroker.Find( string(vData.Code) );

  if aQuote = nil then Exit; // no subscription for this symbol

  stTime  := string( vData.TickTime );
    // translation
  try
      // new time&sale
    aSale := aQuote.Sales.New;

    aSale.Time := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            StrToInt(Copy(stTime,7,2)) *10 ); // msec}
    aQuote.QuoteTime  := stTime;

    aSale.Volume := StrToInt( string( vData.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.CurPrice ) ) ;
    if vData.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    aSale.PrevPrice := StrToInt( string( vData.PrevPrice ) );
    if vData.PrevSign = '-' then
      aSale.PrevPrice := aSale.PrevPrice * -1;
        // side
    if  aSale.Price > aSale.PrevPrice - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C
    aQuote.Open := StrToInt( string( vData.OpenPrice ));
    if vData.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.HighPrice )) ;
    if vData.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.LowPrice )) ;
    if vData.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    aQuote.Last := aSale.Price;

    aQuote.DailyVolume  := StrToInt( string( vData.DailyVolume ));
    aQuote.DailyAmount  := StrToFloat( string( vData.DailyPrice ));


    i := 0;
    while ( i < aQuote.Asks.Size ) do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price) );
      if vData.AskItems[i].Sign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;
      aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

      aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price) );
      if vData.BidItems[i].Sign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
      aQuote.Bids[i].Volume := StrToInt( string( vData.BidItems[i].Volume ));

      inc( i );

      aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price) );
      if vData.AskItems[i].Sign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;
      aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

      aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price) );
      if vData.BidItems[i].Sign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
      aQuote.Bids[i].Volume := StrToInt( string( vData.BidItems[i].Volume ));

      inc( i );
    end;

    aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

    aQuote.Asks.CntTotal    := StrToInt( string( vData.AskTotCnt ));
    aQuote.Bids.CntTotal    := StrToInt( string( vData.BidTotCnt ));

    aQuote.Asks[0].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
    aQuote.Asks[1].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
    aQuote.Asks[2].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
    aQuote.Asks[3].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
    aQuote.Asks[4].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
    aQuote.Asks[5].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
    aQuote.Asks[6].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
    aQuote.Asks[7].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
    aQuote.Asks[8].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
    aQuote.Asks[9].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
      // number of long orders
    aQuote.Bids[0].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
    aQuote.Bids[1].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
    aQuote.Bids[2].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
    aQuote.Bids[3].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
    aQuote.Bids[4].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));
    aQuote.Bids[5].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
    aQuote.Bids[6].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
    aQuote.Bids[7].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
    aQuote.Bids[8].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
    aQuote.Bids[9].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));

    aQuote.Symbol.RealUpperLimit := StrToInt( string( vData.RealUpperLimit )) / 100;
    if vData.RealUpperLimitSign = '-' then
      aQuote.Symbol.RealUpperLimit := aQuote.Symbol.RealUpperLimit * -1;

    aQuote.Symbol.RealLowerLimit := StrToInt( string( vData.RealLowerLimit )) / 100;
    if vData.RealLowerLimit = '-' then
      aQuote.Symbol.RealLowerLimit := aQuote.Symbol.RealLowerLimit * -1;
          //
    aQuote.Update(aSale.Time);

  except

  end;
end;

procedure TQuoteParserPv3.ParseKospiStockVolumeTotal(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
begin
  if FQuoteBroker = nil then Exit;

    // packet size = 407Byte
  if FParser.Parse(stData, [2,12,10,10,10,1]) < 6 then
  begin
    // do something here
    Exit;
  end;

    // check subscription
  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

  aQuote.Asks.VolumeTotal := StrToInt(FParser[3]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[4]);

  aQuote.Update(dtQuote);
end;

procedure TQuoteParserPv3.ParseKRXELWMarketDepth(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
  vData : PElwPrice;

begin

  if Length( stData ) < LenElwPrice then
    Exit;

  vData := PElwPrice( stData );

  aQuote := FQuoteBroker.Find( string( vData.Code ));
  if aQuote = nil then Exit;

  try

    dtQuote := gEnv.Engine.QuoteBroker.Timers.Now;

    i := 0;
    while ( i < aQuote.Asks.Size ) do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.PriceItems[i].PriceItem.AskPrice ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.PriceItems[i].PriceItem.BidPrice ));

      aQuote.Asks[i].Volume := StrToInt( string( vData.PriceItems[i].PriceItem.AskVolume ));
      aQuote.Bids[i].Volume := StrToint( string( vData.PriceItems[i].PriceItem.BidVolume ));

      aQuote.Asks[i].LpVolume := StrToInt( string( vData.PriceItems[i].LpAskVolume ));
      aQuote.Bids[i].LpVolume := StrToInt( string( vData.PriceItems[i].LpBidVolume ));


      inc( i );

      aQuote.Asks[i].Price  := StrToInt( string( vData.PriceItems[i].PriceItem.AskPrice ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.PriceItems[i].PriceItem.BidPrice ));

      aQuote.Asks[i].Volume := StrToInt( string( vData.PriceItems[i].PriceItem.AskVolume ));
      aQuote.Bids[i].Volume := StrToint( string( vData.PriceItems[i].PriceItem.BidVolume ));

      aQuote.Asks[i].LpVolume := StrToInt( string( vData.PriceItems[i].LpAskVolume ));
      aQuote.Bids[i].LpVolume := StrToInt( string( vData.PriceItems[i].LpBidVolume ));

      inc( i );
    end;

    aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
    aQuote.Bids.VolumeTotal := StrToint( string( vData.BidTotVol ));

    aQuote.EstFillPrice := StrToIntDef( string( vData.ExpectPrice), 0 );
    aQuote.EstFillQty := StrToIntDef( string( vData.ExpectVolume), 0 );

    aQuote.Update(dtQuote);

  except

  end;
end;

procedure TQuoteParserPv3.ParseKRXStockMarketDepth(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
  vData : PStockPrice;

begin

  if Length( stData ) < LenStockPrice then
    Exit;

  vData := PStockPrice( stData );

  aQuote := FQuoteBroker.Find( string( vData.Code ));
  if aQuote = nil then Exit;

  try

    dtQuote := gEnv.Engine.QuoteBroker.Timers.Now;

    i := 0;
    while ( i < aQuote.Asks.Size ) do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.PriceItems[i].AskPrice ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.PriceItems[i].BidPrice ));

      aQuote.Asks[i].Volume := StrToInt64( string( vData.PriceItems[i].AskVolume ));
      aQuote.Bids[i].Volume := StrToInt64( string( vData.PriceItems[i].BidVolume ));

      inc( i );

      aQuote.Asks[i].Price  := StrToInt( string( vData.PriceItems[i].AskPrice ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.PriceItems[i].BidPrice ));

      aQuote.Asks[i].Volume := StrToInt64( string( vData.PriceItems[i].AskVolume ));
      aQuote.Bids[i].Volume := StrToInt64( string( vData.PriceItems[i].BidVolume ));

      inc( i );
    end;

    aQuote.Asks.VolumeTotal := StrToInt64( string( vData.AskTotVol ));
    aQuote.Bids.VolumeTotal := StrToInt64( string( vData.BidTotVol ));

    aQuote.EstFillPrice := StrToInt( string( vData.ExpectPrice ));
    aQuote.EstFillQty := StrToInt( string( vData.ExpectVolume ));

    aQuote.Update(dtQuote);

  except

  end;
end;

procedure TQuoteParserPv3.ParseKRXStockTimeNSale(stData: string);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
  aSale: TTimeNSale;
  vData : PStockTick;
  stTime  : string;
begin

  if Length( stData ) < LenStockTick then
    Exit;

  try
    vData := PStockTick( stData );
      // check subscription
    aQuote := FQuoteBroker.Find( string( vData.Code ));
    if aQuote = nil then Exit; // nobody subscribe for this futures

    stTime  := string( vData.FillTime );

    dtQuote := FQuoteDate
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,3,2)), // min
                              StrToInt(Copy(stTime,5,2)), // sec
                              00); // msec}

    aQuote.DailyVolume := StrToInt64( string( vData.TotACumulVolume ));

    aSale := aQuote.Sales.New;
    aSale.LocalTime := GetQuoteTime;
    aSale.Volume := StrToInt64( string( vData.Volume ));
    aSale.Price  := StrToInt( string( vData.Price ));
    aSale.DayVolume := aQuote.DailyVolume;
    aSale.Time   := dtQuote;
        // side
    if vData.Side = '1' then
      aSale.Side := -1
    else
      aSale.Side := 1;

    aQuote.Open := StrToInt( string( vData.OpenPrice ));
    aQuote.High := StrToInt( string( vData.HighPrice )) ;
    aQuote.Low  := StrToInt( string( vData.LowPrice ));
    aQuote.Last := aSale.Price;
    aQuote.Change := StrToInt( string( vData.Change ));

    aQuote.Update(dtQuote);
  Except
    on e : exception do
    begin
      gLog.Add(lkError,'TQuoteParserPv1','ParseKRXStockTimeNSale', e.Message + ' : ' +  string( vData.Code ));
    end;
  end;
end;

procedure TQuoteParserPv3.ParseOptOpenInterset(stData: string);
var
  vData : POptOpenInterest;
  aSymbol : TDerivative;
begin
  if Length( stData ) < LenOptOpenInterest then
    Exit;
  // ?????????? ???? : 8000
  vData := POptOpenInterest( stData );

  try
    aSymbol := gEnv.Engine.SymbolCore.Options.Find( string( vData.Code )) as TDerivative;
    if aSymbol = nil then
      Exit;

    if string(vData.OIDiv) = 'M0' then   // ????????
      aSymbol.PrevOI := StrToIntDef( string( vData.OIQty ), 0 )
    else
      aSymbol.OI := StrToIntDef( string( vData.OIQty ), 0 );
  except
  end;
end;

procedure TQuoteParserPv3.ParseOptRecovery(stData: string);
var
  vData : POptSisRecovery;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  idVol : int64;
begin
  if Length( stData ) < LenOptRecovery then
    Exit;

  vData := POptSisRecovery( stData );

  try
    if (string(vData.MarketStat) <> SisConnected ) then Exit;
    aQuote  := FQuoteBroker.Find( string(vData.Code) );
    if aQuote = nil then Exit;

    if (not aQuote.Recovered) and (aQuote.Sales.Count > 0 ) then
    begin
      aQuote.Recovered := true;
      Exit;
    end;

    if aQuote.Recovered then Exit;

    //idVol :=
    //if aQuote.DailyVolume >= idVol then Exit;

    aQuote.Last := StrtoInt( string(vData.CurPrice))/ 100;
    aQuote.Open := StrToInt( string(vData.OpenPrice))/100;
    aQuote.High := StrToInt( string(vData.HighPrice))/100;
    aQuote.Low  := StrToInt( string(vData.LowPrice))/100;

    aQuote.DailyVolume := StrToInt( string(vData.DailyVolume));
    aQuote.DailyAmount := StrToFloat( string( vData.DailyPrice ));

    aQuote.Asks[0].Price  := StrToInt( string(vData.Ask1.Price))/100;
    aQuote.Asks[0].Volume := StrToInt( string(vData.Ask1.Volume));
    aQuote.Asks[0].Cnt    := StrToInt( string(vData.Ask1.Cnt));

    aQuote.Bids[0].Price  := StrToInt( string(vData.Bid1.Price))/100;
    aQuote.Bids[0].Volume := StrToInt( string(vData.Bid1.Volume));
    aQuote.Bids[0].Cnt    := StrToInt( string(vData.Bid1.Cnt));

    aQuote.Symbol.Last := aQuote.Last;
    aQuote.Symbol.DayOpen := aQuote.Open;
    aQuote.Symbol.DayHigh := aQuote.High;
    aQuote.Symbol.DayLow  := aQuote.Low;

    aQuote.Recovered := true;

  except
  end;
end;

procedure TQuoteParserPv3.Parser(pData: PChar; iSize: Integer);
var
  pComm : PCommonHeader;
begin
  Inc(FParseCount);
  pComm := PCommonHeader( pData );
end;

procedure TQuoteParserPv3.ParserOptionGreeks(stData: string);
var
  vData : POptionGreeks;
  aSymbol :  TOption;
begin

  if Length( stData ) < LenOptionGreeks then
    Exit;

  vData := POptionGreeks( stData );
  aSymbol := gEnv.Engine.SymbolCore.Options.Find( string( vData.Code )) as TOption;

  if aSymbol = nil then
    Exit;

  try

    if vData.DeltaSign = '-' then
      aSymbol.KrxGreeks.Delta := -strtofloat(string(vData.Delta))/ 1000000.0
    else
      aSymbol.KrxGreeks.Delta := strtofloat(string(vData.Delta))/ 1000000.0;

    if vData.ThetaSign = '-' then
      aSymbol.KrxGreeks.Theta := -strtofloat(string(vData.Theta))/ 1000000.0
    else
      aSymbol.KrxGreeks.Theta := strtofloat(string(vData.Theta))/ 1000000.0;

    if vData.VegaSign = '-' then
      aSymbol.KrxGreeks.Vega := -strtofloat(string(vData.Vega))/ 1000000.0
    else
      aSymbol.KrxGreeks.Vega := strtofloat(string(vData.Vega))/ 1000000.0;

    if vData.GammaSign = '-' then
      aSymbol.KrxGreeks.Gamma := -strtofloat(string(vData.Gamma))/ 1000000.0
    else
      aSymbol.KrxGreeks.Gamma := strtofloat(string(vData.Gamma))/ 1000000.0;

    if vData.RhoSign = '-' then
      aSymbol.KrxGreeks.Rho := -strtofloat(string(vData.Rho))/ 1000000.0
    else
      aSymbol.KrxGreeks.Rho := strtofloat(string(vData.Rho))/ 1000000.0;

  except
  end;
end;

procedure TQuoteParserPv3.ParseStockFuturesMarketDepth(stData: string);
var
  aQuote : TQuote;
  i : integer;
  dtQuote : TDateTime;
  vData : PStockFutPrice;
  stCon, stCode, stTime : string;
begin

  if Length( stData ) < LenStockFutPrice then
    Exit;

  vData :=  PStockFutPrice( stData );
  aQuote  := FQuoteBroker.Find( string(vData.Code) );
  if aQuote =nil then
    Exit;

  try
    stCon := string(vData.MarketStat);
    if ( stCon = CloseSingle ) or ( stCon = TradeSingle ) then
    begin
      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal    := StrToInt( string( vData.AskTotCnt ));
      aQuote.Bids.CntTotal    := StrToInt( string( vData.BidTotCnt ));
    end
    else begin
      stTime := string( vData.AcptTime );

      dtQuote := FQuoteDate
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,3,2)), // min
                              StrToInt(Copy(stTime,5,2)), // sec
                              StrToInt(Copy(stTime,7,2)) *10 ); // msec}

      i := 0;
      while ( i < aQuote.Asks.Size ) do
      begin
        aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price) );
        if vData.AskItems[i].Sign = '-' then
          aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;
        aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

        aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price) );
        if vData.BidItems[i].Sign = '-' then
          aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
        aQuote.Bids[i].Volume := StrToInt( string( vData.BidItems[i].Volume ));

        inc( i );

        aQuote.Asks[i].Price  := StrToInt( string( vData.AskItems[i].Price) );
        if vData.AskItems[i].Sign = '-' then
          aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;
        aQuote.Asks[i].Volume := StrToInt( string( vData.AskItems[i].Volume ));

        aQuote.Bids[i].Price  := StrToInt( string( vData.BidItems[i].Price) );
        if vData.BidItems[i].Sign = '-' then
          aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
        aQuote.Bids[i].Volume := StrToInt( string( vData.BidItems[i].Volume ));

        inc( i );
      end;

      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal    := StrToInt( string( vData.AskTotCnt ));
      aQuote.Bids.CntTotal    := StrToInt( string( vData.BidTotCnt ));

      aQuote.Asks[0].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
      aQuote.Asks[1].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
      aQuote.Asks[2].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
      aQuote.Asks[3].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
      aQuote.Asks[4].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
      aQuote.Asks[5].Cnt := StrToInt( string( vData.AskCntItems.Cnt1 ));
      aQuote.Asks[6].Cnt := StrToInt( string( vData.AskCntItems.Cnt2 ));
      aQuote.Asks[7].Cnt := StrToInt( string( vData.AskCntItems.Cnt3 ));
      aQuote.Asks[8].Cnt := StrToInt( string( vData.AskCntItems.Cnt4 ));
      aQuote.Asks[9].Cnt := StrToInt( string( vData.AskCntItems.Cnt5 ));
        // number of long orders
      aQuote.Bids[0].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
      aQuote.Bids[1].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
      aQuote.Bids[2].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
      aQuote.Bids[3].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
      aQuote.Bids[4].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));
      aQuote.Bids[5].Cnt := StrToInt( string( vData.BidCntItems.Cnt1 ));
      aQuote.Bids[6].Cnt := StrToInt( string( vData.BidCntItems.Cnt2 ));
      aQuote.Bids[7].Cnt := StrToInt( string( vData.BidCntItems.Cnt3 ));
      aQuote.Bids[8].Cnt := StrToInt( string( vData.BidCntItems.Cnt4 ));
      aQuote.Bids[9].Cnt := StrToInt( string( vData.BidCntItems.Cnt5 ));

    end;
    aQuote.Update(dtQuote);

  except

  end;
end;

procedure TQuoteParserPv3.ParseStockFuturesTimeNSale(stData: string);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  vData : PStockFutTick;
  stCode, stTime  : string;
begin
  if Length( stData ) < LenStockFutTick then
    Exit;

  vData := PStockFutTick( stData );

  aQuote  := FQuoteBroker.Find( string(vData.Code) );

  if aQuote = nil then Exit; // no subscription for this symbol

  stTime  := string( vData.TickTime );
    // translation
  try
      // new time&sale
    aSale := aQuote.Sales.New;

    aSale.Time := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            StrToInt(Copy(stTime,7,2)) *10 ); // msec}

    aSale.Volume := StrToInt( string( vData.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.CurPrice ) ) ;
    if vData.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    aSale.PrevPrice := StrToInt( string( vData.PrevPrice ) );
    if vData.PrevSign = '-' then
      aSale.PrevPrice := aSale.PrevPrice * -1;
        // side
    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C
    aQuote.Open := StrToInt( string( vData.OpenPrice ));
    if vData.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.HighPrice )) ;
    if vData.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.LowPrice )) ;
    if vData.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    aQuote.Last := aSale.Price;

    aQuote.DailyVolume  := StrToInt( string( vData.DailyVolume ));
    aQuote.DailyAmount  := StrToFloat( string( vData.DailyPrice ));

    aQuote.Symbol.RealUpperLimit := StrToInt( string( vData.RealUpperLimit )) / 100;
    if vData.RealUpperLimitSign = '-' then
      aQuote.Symbol.RealUpperLimit := aQuote.Symbol.RealUpperLimit * -1;

    aQuote.Symbol.RealLowerLimit := StrToInt( string( vData.RealLowerLimit )) / 100;
    if vData.RealLowerLimit = '-' then
      aQuote.Symbol.RealLowerLimit := aQuote.Symbol.RealLowerLimit * -1;
      //
    aQuote.Update(aSale.Time);
  except

  end;
end;

procedure TQuoteParserPv3.ParseVKOSPIIndex(stData: string);
var
  vData : PIndexData;
  stTime : string;
  aTime  : TDateTime;
begin
  if Length( stData ) < LenIndex then
    Exit;

  vData := PIndexData( stData );

  try
    if string(vData.IndustCode ) <> '   ' then Exit;

    stTime := string( vData.Indextime );
    aTime  := FQuoteDate
               + EncodeTime(
                            StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)),
                            0
                            ); // sec


    stTime  := Format('%s : VK %.2f, %s ', [
      '', strToint(string( vData.IndexPrice )) / 100,
      vData.Sign
      ]);


    gEnv.EnvLog( WIN_SIS, stTime );


  except
  end;
end;

end.
