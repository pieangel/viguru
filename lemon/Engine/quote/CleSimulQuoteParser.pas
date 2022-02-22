unit CleSimulQuoteParser;

interface

uses Classes, SysUtils, Windows, Dialogs,

    // lemon:
  CleQuoteBroker, CleSymbols, CleQuoteParserIF,
    // Lemon: utilities
  CleParsers,  GleConsts,  UUdpPacket,
  CleKrxSymbols,
  CleFQn;

const
  MARKET_DEPTH_SIZE = 5;
  CloseSingle = '30';
  TradeSingle = '20';

type
  TSimulQuoteParser = class( TIFQuoteParser )
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

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(stData : String); override;
  end;

implementation

uses GleTypes, GAppEnv, GleLib, CleQuoteTimers;

//-----------------------------------------------------------------<init>

constructor TSimulQuoteParser.Create;
begin
  inherited;
end;

destructor TSimulQuoteParser.Destroy;
begin
  inherited;
end;

//-----------------------------------------------------------------< packet >

procedure TSimulQuoteParser.Parse(stData : String);
var
  stTR, stInfo : String;
  pComm : PCommonHeader;
begin
  Inc(FParseCount);

  pComm := PCommonHeader( stData );

  if Length( stData ) < 10 then Exit;
  

  try

    stTR := string( pComm.DataDiv );
    stInfo  := string( pComm.InfoDiv );
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
      Exit;

  except
    //gEnv.EnvLog( WIN_ERR, stData);
  end;

end;

procedure TSimulQuoteParser.ParseElwGreeks(stData: string);
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
      aSymbol.Delta   := -StrToInt( string( vData.Delta )) / 1000000
    else
      aSymbol.Delta   := StrToInt( string( vData.Delta )) / 1000000;

    if vData.ThetaSign = '-' then
      aSymbol.Theta   := -StrToInt( string( vData.Theta )) / 1000000
    else
      aSymbol.Theta   := StrToInt( string( vData.Theta )) / 1000000;

    aSymbol.Vega    := StrToInt( string( vData.Vega )) / 1000000;

    if vData.RhoSign = '-' then    
      aSymbol.Low     := -StrToInt( string( vData.Rho )) / 1000000
    else
      aSymbol.Low     := StrToInt( string( vData.Rho )) / 1000000;

    aSymbol.IV      := StrToInt( string( vData.IV )) / 100;

  except
  end;

end;

//--------------------------------------------< parsing: KOSPI200 index price >

procedure TSimulQuoteParser.ParseKOSPI200Index(stData : String);
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
    aQuote.UpdateCustom(aSale.Time, 0);
  except
    // do something here
  end;
end;

procedure TSimulQuoteParser.ParseKOSPI200IndexExpect(stData: String);
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
    aQuote.UpdateCustom(aSale.Time,0);
  except
    // do something here
  end;
end;

//----------------------------------< parsing: KOSPI200 futures market depth >

procedure TSimulQuoteParser.ParseKOSPI200FuturesMarketDepth(stData : String);
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

  dtQuote := 0;
  
  try
    stCon := string(vData.MarketStat);

    if ( stCon = CloseSingle ) or ( stCon = TradeSingle ) then
    begin

      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
      aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));
    end
    else begin

      aQuote.SavePrevMarketDepths;
      stTime  := string( vData.AcptTime );
      dtQuote := FQuoteDate
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,3,2)), // min
                              StrToInt(Copy(stTime,5,2)), // sec
                              StrToInt(Copy(stTime,7,2)) *10 ); // msec}
      aQuote.QuoteTime  := stTime;
      aQuote.MarketState  := string( vData.MarketStat );


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
      // apply
    aQuote.UpdateCustom(dtQuote,0);
  except
    // do something here
  end;
end;

//--------------------------------------< parsing: KOSPI200 futures time&sale >

procedure TSimulQuoteParser.ParseKOSPI200FuturesTimeNSale(stData : String);
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
    aQuote.UpdateCustom(aSale.Time, 1);
  except
    // do something here
  end;
end;

procedure TSimulQuoteParser.ParseKOSPI200FuturesTimeNSaleNMarketDepth(
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

  aQuote  := FQuoteBroker.Find( string(vData.Tick.Code) );
  if aQuote = nil then Exit;
  aQuote.SavePrevMarketDepths;

  stTime  := string( vData.Tick.TickTime );
    // translation
  try
      // new time&sale
    iDailyVol := StrToInt( string( vData.Tick.DailyVolume ));

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
    aQuote.QuoteTime  := stTime;

    aSale.Volume := StrToInt( string( vData.Tick.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.Tick.CurPrice ) ) / 100;
    if vData.Tick.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    aSale.PrevPrice := StrToInt( string( vData.Tick.PrevPrice ) ) / 100;
    if vData.Tick.PrevSign = '-' then
      aSale.PrevPrice := aSale.PrevPrice * -1;
        // side
    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C

    aQuote.Open := StrToInt( string( vData.Tick.OpenPrice )) / 100;
    if vData.Tick.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.Tick.HighPrice )) / 100;
    if vData.Tick.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.Tick.LowPrice )) / 100;
    if vData.Tick.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    aQuote.Last := aSale.Price;
    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

    aQuote.DailyVolume  := iDailyVol;
    aQuote.DailyAmount  := StrToFloat( string( vData.Tick.DailyPrice ));
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

    aQuote.UpdateCustom(aSale.Time, 0);

  except
  end;

end;

//-----------------------------------< parsing: KOSPI200 options market depth >

procedure TSimulQuoteParser.ParseKOSPI200OptionMarketDepth(stData : String);
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

  dtQuote := 0;

  try
    stCon := string(vData.MarketStat);

    if ( stCon = CloseSingle ) or ( stCon = TradeSingle ) then
    begin
      aQuote.Asks.VolumeTotal := StrToInt( string( vData.AskTotVol ));
      aQuote.Bids.VolumeTotal := StrToInt( string( vData.BidTotVol ));

      aQuote.Asks.CntTotal := StrToInt( string( vData.AskTotCnt ) );
      aQuote.Bids.CntTotal := StrToInt( string( vData.BidTotCnt ));
    end
    else begin
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
      //
    aQuote.UpdateCustom(dtQuote, 0);
  except
    // do something here
  end;
end;

procedure TSimulQuoteParser.ParseKOSPI200OptionsTimeNSaleNMarketDepth(
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

  aQuote  := FQuoteBroker.Find( string(vData.Tick.Code) );
  if aQuote = nil then Exit; // no subscription for this symbol
  aQuote.SavePrevMarketDepths;

  stTime  := string( vData.Tick.TickTime );
    // translation
  try
      // new time&sale
    iDailyVol := StrToInt( string( vData.Tick.DailyVolume ));

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
    aQuote.QuoteTime  := stTime;

    aSale.Volume := StrToInt( string( vData.Tick.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.Tick.CurPrice ) ) / 100;
    aSale.PrevPrice := StrToInt( string( vData.Tick.PrevPrice ) ) / 100;
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

    aQuote.Open := StrToInt( string( vData.Tick.OpenPrice )) / 100;
    aQuote.High := StrToInt( string( vData.Tick.HighPrice )) / 100;
    aQuote.Low := StrToInt( string( vData.Tick.LowPrice )) / 100;

    aQuote.Last := aSale.Price;
    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

    aQuote.DailyVolume  := iDailyVol;
    aQuote.DailyAmount  := StrToFloat( string( vData.Tick.DailyPrice ));

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

      //
    aQuote.UpdateCustom(aSale.Time, 2);
  except
    // do something here
  end;

end;

//-----------------------------------< parsing: KOSPI200 options time&sale >

procedure TSimulQuoteParser.ParseKOSPI200OptionTimeNSale(stData : String);
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
      //
    aQuote.UpdateCustom(aSale.Time, 1);
  except
    // do something here
  end;
end;

procedure TSimulQuoteParser.ParseKOSPI200StockFuturesTimeNSaleNMarketDepth(
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

  aQuote  := FQuoteBroker.Find( string(vData.Tick.Code) );

  if aQuote = nil then Exit; // no subscription for this symbol

  stTime  := string( vData.Tick.TickTime );
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

    aSale.Volume := StrToInt( string( vData.Tick.Volume ));
        // price
    aSale.Price := StrToInt( string( vData.Tick.CurPrice ) ) ;
    if vData.Tick.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    aSale.PrevPrice := StrToInt( string( vData.Tick.PrevPrice ) );
    if vData.Tick.PrevSign = '-' then
      aSale.PrevPrice := aSale.PrevPrice * -1;
        // side
    if  aSale.Price > aSale.PrevPrice - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C
    aQuote.Open := StrToInt( string( vData.Tick.OpenPrice ));
    if vData.Tick.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.Tick.HighPrice )) ;
    if vData.Tick.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.Tick.LowPrice )) ;
    if vData.Tick.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    aQuote.Last := aSale.Price;

    aQuote.DailyVolume  := StrToInt( string( vData.Tick.DailyVolume ));
    aQuote.DailyAmount  := StrToFloat( string( vData.Tick.DailyPrice ));


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

          //
    aQuote.UpdateCustom(aSale.Time, 0);

  except

  end;

end;

// H1/h1
procedure TSimulQuoteParser.ParseKRXStockMarketDepth(stData: String);
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

    aQuote.UpdateCustom(dtQuote, 0);

  except

  end;

end;

procedure TSimulQuoteParser.ParseKRXStockTimeNSale(stData: string);
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
    aSale.Volume := StrToInt64( string( vData.Volume ));
    aSale.Price  := StrToInt( string( vData.Price ));
    aSale.DayVolume := aQuote.DailyVolume;
    aSale.Time   := dtQuote;
        // side
    if vData.Side = '1' then
      aSale.Side := 1
    else
      aSale.Side := -1;

    aQuote.Open := StrToInt( string( vData.OpenPrice ));
    aQuote.High := StrToInt( string( vData.HighPrice )) ;
    aQuote.Low  := StrToInt( string( vData.LowPrice ));
    aQuote.Last := aSale.Price;
    aQuote.Change := StrToInt( string( vData.Change ));

    aQuote.UpdateCustom(dtQuote, 0);
  Except

  end;

end;

procedure TSimulQuoteParser.ParseStockFuturesMarketDepth(stData: string);
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

  dtQuote := 0;
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
    aQuote.UpdateCustom(dtQuote, 0);

  except

  end;

end;


procedure TSimulQuoteParser.ParseStockFuturesTimeNSale(stData: string);
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
      //
    aQuote.UpdateCustom(aSale.Time, 0);
  except

  end;
end;

// h3
procedure TSimulQuoteParser.ParseKRXELWMarketDepth(stData: String);
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

    aQuote.EstFillPrice := StrToInt( string( vData.ExpectPrice ));
    aQuote.EstFillQty := StrToInt( string( vData.ExpectVolume ));

    aQuote.UpdateCustom(dtQuote, 0);

  except

  end;
end;



procedure TSimulQuoteParser.ParseKospiStockVolumeTotal(stData: String);
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

  dtQuote := 0;
    // check subscription
  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

  aQuote.Asks.VolumeTotal := StrToInt(FParser[3]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[4]);

  aQuote.UpdateCustom(dtQuote, 0);
end;




end.



