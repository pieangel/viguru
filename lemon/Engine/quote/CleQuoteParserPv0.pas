unit CleQuoteParserPv0;

interface

uses
  Classes, SysUtils, Windows,

    // lemon:
  CleQuoteBroker, CleSymbols, CleQuoteParserIf,
    // Lemon: utilities
  CleParsers,  GleConsts,  UUdpPacketPv0,
  CleKrxSymbols,
  CleFQn
  ;
type

  TQuoteParserPv0 = class( TIFQuoteParser )
  private
      // parse
    procedure ParseKOSPI200Index(stData : String);
    procedure ParseKOSPI200FuturesMarketDepth(stData : String);
    procedure ParseKOSPI200FuturesTimeNSale(stData : String);
    procedure ParseKOSPI200OptionMarketDepth(stData : String);
    procedure ParseKOSPI200OptionTimeNSale(stData : String);

    procedure ParseKRXStockMarketDepth(stData : String);
    procedure ParseKRXStockTimeNSale( stData : string );
    procedure ParseKRXELWMarketDepth(stData : String);
    procedure ParseKOSDAQStockMarketDepth(stData : String);

    procedure ParseElwGreeks( stData : string );

    procedure ParseKospiStockVolumeTotal(stData : String);
    procedure ParseKosdaqStockVolumeTotal(stData : String);

    procedure ParseStockFuturesMarketDepth( stData : string );
    procedure ParseStockFuturesTimeNSale( stData : string );

  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(stData : String);  override;
  end;

implementation

uses GleTypes, GAppEnv;


{ TQuoteParserPv0 }

constructor TQuoteParserPv0.Create;
begin
  inherited;
end;

destructor TQuoteParserPv0.Destroy;
begin

  inherited;
end;

procedure TQuoteParserPv0.Parse(stData: String);
var
  stTR, stCode, stPacket : String;
  stLog : string;
  iTmp , i, ires: integer;
begin


  Inc(FParseCount);
    // Header(11) = TR(2) + SerialNo(7) + Code(2)
  stTR := Copy(stData, 1, 2);

  if CompareStr(stTR, 'F1') = 0 then        // 지수선물
  begin
    stCode := Copy(stData, 09, 2);
    stPacket := Copy(stData, 11, Length(stData)-10);

    if CompareStr(stCode, 'H0') = 0 then
      ParseKOSPI200FuturesMarketDepth(stPacket)
    else
    if CompareStr(stCode, 'C0') = 0 then
      ParseKOSPI200FuturesTimeNSale(stPacket);
  end
  else if CompareStr( stTR, 'L1') = 0 then
  begin
    stCode := Copy(stData, 09, 2);
    stPacket := Copy(stData, 11, Length(stData)-10);

    if CompareStr(stCode, 'H0') = 0 then
      ParseStockFuturesMarketDepth(stPacket)
    else
    if CompareStr(stCode, 'C0') = 0 then
      ParseStockFuturesTimeNSale(stPacket) ;

  end
  else if CompareStr(stTR, 'O1') = 0 then      // 지수옵션
  begin
    stCode := Copy(stData, 10, 2);
    stPacket := Copy(stData, 12, Length(stData)-11);

    if CompareStr(stCode, 'H0') = 0 then
      ParseKOSPI200OptionMarketDepth(stPacket)
    else
    if CompareStr(stCode, 'C0') = 0 then
      ParseKOSPI200OptionTimeNSale(stPacket);
  end
  else if (CompareStr(stTR, 'I2') = 0) or (CompareStr(stTR, 'Y2') = 0) then
  begin
    ParseKOSPI200Index(stData);
  end
  else if CompareStr(stTR, 'H1') = 0 then
    ParseKRXStockMarketDepth(stData)
  else if CompareStr(stTR, 'h3') = 0 then    // LSY 2008-03-02
    ParseKRXELWMarketDepth(stData)
  else if CompareStr(stTR, 'HA') = 0 then
    ParseKosdaqStockMarketDepth(stData)
  else if (CompareStr(stTR, 'S3')=0) or (CompareStr(stTR, 's3')=0) then
    ParseKRXStockTimeNSale(stData)
  else if CompareStr(stTR, 'ES') = 0 then
    ParseElwGreeks(stData);

end;

procedure TQuoteParserPv0.ParseElwGreeks(stData: string);
var
  aQuote: TQuote;
  aElw  : TElw;
begin
  if FQuoteBroker = nil then Exit;

  if FParser.Parse(stData, [2, 6,12,10, 1,
                            7, 7, 1,12,12,
                            1,12, 5,1]) < 14 then

    Exit;

    // check subscription
  aQuote := FQuoteBroker.Find(Trim(FParser[2]));
  if aQuote = nil then Exit; // nobody subscribe for this futures

  aElw := aQuote.Symbol as TElw;

  if FParser[4] = '-' then
    aElw.Delta  := -StrToInt(FParser[5]) / 1000000
  else
    aElw.Delta  := StrToInt(FParser[5]) / 1000000;

  aElw.Gamma  := StrToInt(FParser[6]) / 1000000 ;

  if FParser[7] = '-' then
    aElw.Theta  := -StrToInt(FParser[8]) / 1000000
  else
    aElw.Delta  := StrToInt(FParser[8]) / 1000000;

  aElw.Vega := StrToInt(FParser[9]) / 1000000;

  if FParser[10] = '-' then
    aElw.Low  := -StrToInt(FParser[11]) / 1000000
  else
    aElw.Low  := StrToInt(FParser[11]) / 1000000;

  aElw.IV :=  StrToInt(FParser[12]) / 100;

end;

//--------------------------------------------< parsing: KOSPI200 index price >

procedure TQuoteParserPv0.ParseKOSPI200Index(stData : String);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  iDailyVolume: Integer;
begin
  if FQuoteBroker = nil then Exit;

  if FParser.Parse(stData, [2,2,6,8,1,8,8,8]) < 8 then
  begin
    // do log here
    Exit;
  end;

  try
      // compare code
    if CompareStr(FParser[1], KOSPI200_CODE) <> 0 then Exit;

    aQuote := FQuoteBroker.Find(FParser[1]);
    if aQuote = nil then Exit; // nobody subscribed

      // new time & sale
    aSale := aQuote.Sales.New;

    aSale.Price := StrToInt(FParser[3])/100;
    if FParser[2][1] in ['0'..'9'] then
      aSale.Time := FQuoteDate
                    + EncodeTime(StrToInt(Copy(FParser[2],1,2)), // hour
                                 StrToInt(Copy(FParser[2],3,2)), // min
                                 StrToInt(Copy(FParser[2],5,2)), // sec
                                 0); // msec
    iDailyVolume := StrToInt(FParser[6]);
    if aQuote.Sales.Prev <> nil then
      aSale.Volume := iDailyVolume - aQuote.DailyVolume
    else
      aSale.Volume  := 0;
    aSale.Side := 0;

    aSale.LocalTime := gEnv.Engine.QuoteBroker.Timers.Now;
      // price info
    //aQuote.Open := ;
    //aQuote.High := ;
    //aQuote.Low := ;
    aQuote.Last := aSale.Price;
    aQuote.Change := StrToInt(FParser[5]) / 100;
    if FParser[4][1] = '-' then
      aQuote.Change := -1 * aQuote.Change;

      // trading info
    aQuote.DailyVolume := iDailyVolume;
    aQuote.DailyAmount := StrToFloat(FParser[7]);
    aQuote.OpenInterest := 0;

      // apply
    aQuote.UpdatePv0(aSale.Time);
  except
    // do something here
  end;
end;

//----------------------------------< parsing: KOSPI200 futures market depth >

procedure TQuoteParserPv0.ParseKOSPI200FuturesMarketDepth(stData : String);
var
  aQuote: TQuote;
  dtQuote: TDateTime;
  vData : PFutureCall;
  stTime : string;
  I: Integer;
begin

  try
    if Length( stData ) < FHogaLenght then
      Exit;

    vData := PFutureCall( stData );

    aQuote  := FQuoteBroker.Find( Copy( string( vData.Code ), 1, 5));
    if aQuote = nil then Exit;

    aQuote.SavePrevMarketDepths;
    stTime  := string( vData.AcptTime );

    dtQuote := FQuoteDate
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                             StrToInt(Copy(stTime,3,2)), // min
                             StrToInt(Copy(stTime,5,2)), // sec
                             StrToInt(Copy(stTime,7,2))); // msec

    aQuote.Asks[0].Price  := StrToInt( string( vData.Qty1Item.Sell )) / 100;
    aQuote.Asks[0].Volume := StrToInt( string( vData.Qty1Item.SellQty ));
    if vData.Qty1Item.SellSign = '-' then
      aQuote.Asks[0].Price  := aQuote.Asks[0].Price * -1;

    aQuote.Bids[0].Price  := StrToInt( string( vData.Qty1Item.Buy )) / 100;
    aQuote.Bids[0].Volume := StrToInt( string( vData.Qty1Item.BuyQty ));
    if vData.Qty1Item.SellSign = '-' then
      aQuote.Bids[0].Price  := aQuote.Bids[0].Price * -1;

    for i := 1 to 2 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.Qty2To3Item[i-1].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.Qty2To3Item[i-1].SellQty ));
      if vData.Qty2To3Item[i-1].SellSign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;

      aQuote.Bids[i].Volume := StrToInt( string( vData.Qty2To3Item[i-1].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.Qty2To3Item[i-1].Buy )) / 100;
      if vData.Qty2To3Item[i-1].BuySign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
    end;

    for i := 3 to 4 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.FQty4To5Item[i-3].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.FQty4To5Item[i-3].SellQty ));
      if vData.FQty4To5Item[i-3].SellSign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;

      aQuote.Bids[i].Volume := StrToInt( string( vData.FQty4To5Item[i-3].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.FQty4To5Item[i-3].Buy )) / 100;
      if vData.FQty4To5Item[i-3].BuySign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
    end;

    aQuote.Asks[0].Cnt  := StrToInt( string( vData.CntItem[0].Cnt1 ));
    aQuote.Asks[1].Cnt  := StrToInt( string( vData.CntItem[0].Cnt2 ));
    aQuote.Asks[2].Cnt  := StrToInt( string( vData.CntItem[0].Cnt3 ));
    aQuote.Asks[3].Cnt  := StrToInt( string( vData.CntItem[0].Cnt4 ));
    aQuote.Asks[4].Cnt  := StrToInt( string( vData.CntItem[0].Cnt5 ));
    aQuote.Asks.CntTotal  := StrToInt( string( vdata.CntItem[0].TotCnt ));
    aQuote.Asks.VolumeTotal := StrToInt( string( vData.SellQty ));

    aQuote.Bids[0].Cnt  := StrToInt( string( vData.CntItem[1].Cnt1 ));
    aQuote.Bids[1].Cnt  := StrToInt( string( vData.CntItem[1].Cnt2 ));
    aQuote.Bids[2].Cnt  := StrToInt( string( vData.CntItem[1].Cnt3 ));
    aQuote.Bids[3].Cnt  := StrToInt( string( vData.CntItem[1].Cnt4 ));
    aQuote.Bids[4].Cnt  := StrToInt( string( vData.CntItem[1].Cnt5 ));
    aQuote.Bids.CntTotal  := StrToInt( string( vdata.CntItem[1].TotCnt ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BuyQty ));
    aQuote.UpdatePv0(dtQuote);    
  except
    // do something here
  end;
end;

//--------------------------------------< parsing: KOSPI200 futures time&sale >

procedure TQuoteParserPv0.ParseKOSPI200FuturesTimeNSale(stData : String);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  vData : PFutureTick;
  stTime : string;
  I: Integer;
begin
  try

    if Length( stData ) < FFillLength then
      Exit;

    vData := PFutureTick( stData );

    aQuote := FQuoteBroker.Find(Copy( string( vData.Code ) ,1,5));
    if aQuote = nil then Exit; // no subscription for this symbol

    aSale := aQuote.Sales.New;
    aQuote.DailyVolume  :=  StrToIntDef( string( vdata.TotalQty ) , 0);
    aSale.DayVolume := aQuote.DailyVolume;
    stTime  := string( vData.FillTime );

    aSale.LocalTime := gEnv.Engine.QuoteBroker.Timers.Now;
    aSale.Time := FQuoteDate
                  + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                               StrToInt(Copy(stTime,3,2)), // min
                               StrToInt(Copy(stTime,5,2)), // sec
                               StrToInt(Copy(stTime,7,2))); // msec
    aSale.Volume := StrToInt( string( vData.FillQty ));

    aSale.Price := StrToInt( string( vData.Current ) ) / 100;
    if vdata.CurSign = '-' then
      aSale.Price := aSale.Price * -1;

    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

    aQuote.Last := aSale.Price;

    aQuote.Change := StrToInt( string( vData.Margin )) / 100;
    if vData.MarginSign = '-' then
      aQuote.Change := aQuote.Change * -1;

    aQuote.SavePrevMarketDepths;

    for I := 0 to 2 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.FQty1To3Item[i].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.FQty1To3Item[i].SellQty ));
      if vData.FQty1To3Item[i].SellSign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;

      aQuote.Bids[i].Volume := StrToInt( string( vData.FQty1To3Item[i].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.FQty1To3Item[i].Buy )) / 100;
      if vData.FQty1To3Item[i].BuySign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
    end;

      // O, H, L, C
    aQuote.Open := StrToInt( string( vData.Open )) / 100;
    if vData.OpenSign = '-' then
      aQuote.Open := aQuote.Open * -1;

    aQuote.High := StrToInt( string( vData.High )) / 100;
    if vdata.HighSign = '-' then
      aQuote.High := aQuote.High * -1;

    aQuote.Low := StrToInt( string( vData.Low )) / 100;
    if vdata.LowSign = '-' then
      aQuote.Low := aQuote.Low * -1;

    for i := 3 to 4 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.FQty4To5Item[i-3].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.FQty4To5Item[i-3].SellQty ));
      if vData.FQty4To5Item[i-3].SellSign = '-' then
        aQuote.Asks[i].Price  := aQuote.Asks[i].Price * -1;

      aQuote.Bids[i].Volume := StrToInt( string( vData.FQty4To5Item[i-3].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.FQty4To5Item[i-3].Buy )) / 100;
      if vData.FQty4To5Item[i-3].BuySign = '-' then
        aQuote.Bids[i].Price  := aQuote.Bids[i].Price * -1;
    end;

    aQuote.Asks[0].Cnt  := StrToInt( string( vData.CntItem[0].Cnt1 ));
    aQuote.Asks[1].Cnt  := StrToInt( string( vData.CntItem[0].Cnt2 ));
    aQuote.Asks[2].Cnt  := StrToInt( string( vData.CntItem[0].Cnt3 ));
    aQuote.Asks[3].Cnt  := StrToInt( string( vData.CntItem[0].Cnt4 ));
    aQuote.Asks[4].Cnt  := StrToInt( string( vData.CntItem[0].Cnt5 ));
    aQuote.Asks.CntTotal  := StrToInt( string( vdata.CntItem[0].TotCnt ));
    aQuote.Asks.VolumeTotal := StrToInt( string( vData.SellQty ));

    aQuote.Bids[0].Cnt  := StrToInt( string( vData.CntItem[1].Cnt1 ));
    aQuote.Bids[1].Cnt  := StrToInt( string( vData.CntItem[1].Cnt2 ));
    aQuote.Bids[2].Cnt  := StrToInt( string( vData.CntItem[1].Cnt3 ));
    aQuote.Bids[3].Cnt  := StrToInt( string( vData.CntItem[1].Cnt4 ));
    aQuote.Bids[4].Cnt  := StrToInt( string( vData.CntItem[1].Cnt5 ));
    aQuote.Bids.CntTotal  := StrToInt( string( vdata.CntItem[1].TotCnt ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BuyQty ));
      //
    aQuote.UpdatePv0(aSale.Time);
  except
    // do something here
  end;



end;

//-----------------------------------< parsing: KOSPI200 options market depth >

procedure TQuoteParserPv0.ParseKOSPI200OptionMarketDepth(stData : String);
var
  aQuote: TQuote;
  dtQuote: TDateTime;
  i: Integer;
  vData : POptionCall;
  stTime : string;
begin
  try

    if Length(stData) < CHogaLenght  then
      Exit;

    vData := POptionCall( stData );
    aQuote  := FQuoteBroker.Find( string( vData.Code ));
    if aQuote = nil then
      Exit;
    stTime  := string( vData.AcptTime );
    dtQuote := FQuoteDate
                  + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                               StrToInt(Copy(stTime,3,2)), // min
                               StrToInt(Copy(stTime,5,2)), // sec
                               StrToInt(Copy(stTime,7,2))); // msec

    aQuote.SavePrevMarketDepths;

    for I := 0 to 2 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.OQty1To3Item[i].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.OQty1To3Item[i].SellQty ));

      aQuote.Bids[i].Volume := StrToInt( string( vData.OQty1To3Item[i].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.OQty1To3Item[i].Buy )) / 100;
    end;

    for i := 3 to 4 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.OQty4To5Item[i-3].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.OQty4To5Item[i-3].SellQty ));

      aQuote.Bids[i].Volume := StrToInt( string( vData.OQty4To5Item[i-3].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.OQty4To5Item[i-3].Buy )) / 100;
    end;

    aQuote.Asks[0].Cnt  := StrToInt( string( vData.CntItem[0].Cnt1 ));
    aQuote.Asks[1].Cnt  := StrToInt( string( vData.CntItem[0].Cnt2 ));
    aQuote.Asks[2].Cnt  := StrToInt( string( vData.CntItem[0].Cnt3 ));
    aQuote.Asks[3].Cnt  := StrToInt( string( vData.CntItem[0].Cnt4 ));
    aQuote.Asks[4].Cnt  := StrToInt( string( vData.CntItem[0].Cnt5 ));
    aQuote.Asks.CntTotal  := StrToInt( string( vdata.CntItem[0].TotCnt ));
    aQuote.Asks.VolumeTotal := StrToInt( string( vData.SellQty ));

    aQuote.Bids[0].Cnt  := StrToInt( string( vData.CntItem[1].Cnt1 ));
    aQuote.Bids[1].Cnt  := StrToInt( string( vData.CntItem[1].Cnt2 ));
    aQuote.Bids[2].Cnt  := StrToInt( string( vData.CntItem[1].Cnt3 ));
    aQuote.Bids[3].Cnt  := StrToInt( string( vData.CntItem[1].Cnt4 ));
    aQuote.Bids[4].Cnt  := StrToInt( string( vData.CntItem[1].Cnt5 ));
    aQuote.Bids.CntTotal  := StrToInt( string( vdata.CntItem[1].TotCnt ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BuyQty ));

    aQuote.UpdatePv0(dtQuote);

  except
    // do something here
    // ShowMessage( Format('(%d) %d : %s', [ iCheck, iLen, stData ]) );
  end;



end;

//-----------------------------------< parsing: KOSPI200 options time&sale >

procedure TQuoteParserPv0.ParseKOSPI200OptionTimeNSale(stData : String);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  i : Integer;
  vData : POptionTick;
  stTime : string;
begin
  try
    if Length( stData ) < CFillLenght then
      Exit;    

    vData := POptionTick( stData );       // find the quote
    aQuote := FQuoteBroker.Find( string( vData.Code ));
    if aQuote = nil then Exit; // no subscription for this symbol

      // new time&Sale
    aSale := aQuote.Sales.New;
    stTime  := string( vData.FillTime );

    aSale.LocalTime := gEnv.Engine.QuoteBroker.Timers.Now;
    aSale.Time := FQuoteDate
                  + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                               StrToInt(Copy(stTime,3,2)), // min
                               StrToInt(Copy(stTime,5,2)), // sec
                               StrToInt(Copy(stTime,7,2))); // msec
    aSale.Price   := StrToInt( string( vData.Current)) / 100;
    aSale.Volume  := StrToInt( string( vData.FillQty ));
    if aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // daily price info
    aQuote.Open := StrToInt( string( vData.Open )) / 100;
    aQuote.High := StrToInt( string( vData.High )) / 100;
    aQuote.Low  := StrToInt( string( vData.Low )) / 100;
    aQuote.Last := aSale.Price;
    // aQuote.Change := ;
      // daily trading info
    aQuote.DailyVolume  := StrToInt( string( vdata.TotalQty ));
    aQuote.DailyAmount  := StrToFloat( string( vData.TotalPrice ));
    //aQuote.OpenInterest := ;
    aSale.DayVolume := aQuote.DailyVolume;

    aQuote.SavePrevMarketDepths;

    aQuote.Change := aSale.Price - aQuote.Symbol.PrevClose;

      // ask prices
    for I := 0 to 2 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.OQty1To3Item[i].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.OQty1To3Item[i].SellQty ));

      aQuote.Bids[i].Volume := StrToInt( string( vData.OQty1To3Item[i].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.OQty1To3Item[i].Buy )) / 100;
    end;

    for i := 3 to 4 do
    begin
      aQuote.Asks[i].Price  := StrToInt( string( vData.OQty4To5Item[i-3].Sell )) / 100;
      aQuote.Asks[i].Volume := StrToInt( string( vData.OQty4To5Item[i-3].SellQty ));

      aQuote.Bids[i].Volume := StrToInt( string( vData.OQty4To5Item[i-3].BuyQty ));
      aQuote.Bids[i].Price  := StrToInt( string( vData.OQty4To5Item[i-3].Buy )) / 100;
    end;

    aQuote.Asks[0].Cnt  := StrToInt( string( vData.CntItem[0].Cnt1 ));
    aQuote.Asks[1].Cnt  := StrToInt( string( vData.CntItem[0].Cnt2 ));
    aQuote.Asks[2].Cnt  := StrToInt( string( vData.CntItem[0].Cnt3 ));
    aQuote.Asks[3].Cnt  := StrToInt( string( vData.CntItem[0].Cnt4 ));
    aQuote.Asks[4].Cnt  := StrToInt( string( vData.CntItem[0].Cnt5 ));
    aQuote.Asks.CntTotal  := StrToInt( string( vdata.CntItem[0].TotCnt ));
    aQuote.Asks.VolumeTotal := StrToInt( string( vData.SellQty ));

    aQuote.Bids[0].Cnt  := StrToInt( string( vData.CntItem[1].Cnt1 ));
    aQuote.Bids[1].Cnt  := StrToInt( string( vData.CntItem[1].Cnt2 ));
    aQuote.Bids[2].Cnt  := StrToInt( string( vData.CntItem[1].Cnt3 ));
    aQuote.Bids[3].Cnt  := StrToInt( string( vData.CntItem[1].Cnt4 ));
    aQuote.Bids[4].Cnt  := StrToInt( string( vData.CntItem[1].Cnt5 ));
    aQuote.Bids.CntTotal  := StrToInt( string( vdata.CntItem[1].TotCnt ));
    aQuote.Bids.VolumeTotal := StrToInt( string( vData.BuyQty ));
      //
    aQuote.UpdatePv0(aSale.Time);
  except
    // do something here
  end;


end;

// H1/h1
procedure TQuoteParserPv0.ParseKRXStockMarketDepth(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
begin
  if FQuoteBroker = nil then Exit;

    // packet size = 407Byte
  if FParser.Parse(stData, [2,12,10,9,9,   10,10,9,9,10,
                            10,9,9,10,10,  9,9,10,10,9,
                            9,10,10,9,9,   10,10,9,9,10,
                            10,9,9,10,10,  9,9,10,10,9,
                            9,10,10,10,10, 1,1,9,10,1,
                            1]) < 51 then
  begin
    // do something here
    Exit;
  end;

    // check subscription
  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

    // size
  aQuote.Asks.Size := 10;
  aQuote.Bids.Size := 10;

  for i := 0 to 9 do
  begin
    aQuote.Asks[i].Price := StrToFloat(FParser[4*i+3]);
    aQuote.Bids[i].Price := StrToFloat(FParser[4*i+4]);
    aQuote.Asks[i].Volume := StrToInt(FParser[4*i+5]);
    aQuote.Bids[i].Volume := StrToInt(FParser[4*i+6]);
  end;

  aQuote.Asks.VolumeTotal := StrToInt(FParser[43]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[44]);

  aQuote.EstFillPrice := StrToFloat(FParser[47]);
  aQuote.EstFillQty := StrToFloat(FParser[48]);

  //aQuote.MarketOper := StrToInt(FParser[45]);

  aQuote.UpdatePv0(dtQuote);

end;

procedure TQuoteParserPv0.ParseKRXStockTimeNSale(stData: string);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i, iVolume, iDailyVolume : Integer;
  aSale: TTimeNSale;
begin
  if FQuoteBroker = nil then Exit;

    // packet size = 407Byte
  if FParser.Parse(stData, [2,12,1,9,9,   9,9,9,10,15,
                            2,1,9,1
                            ]) < 14 then
  begin
    // do something here
    Exit;
  end;

    // check subscription
  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

  iDailyVolume := StrToInt(FParser[8]);
  iVolume := iDailyVolume - aQuote.DailyVolume;
  if iVolume <= 0 then
    Exit;

  aQuote.DailyVolume := iDailyVolume;

  aSale := aQuote.Sales.New;
  aSale.Volume := iVolume;
  aSale.Price  := StrToInt( FParser[4] );
  aSale.DayVolume := aQuote.DailyVolume;
  aSale.LocalTime := gEnv.Engine.QuoteBroker.Timers.Now;
      // side
  if aQuote.Asks.Count > 1 then
    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

  aQuote.Open := StrToInt(FParser[5]) ;
  aQuote.High := StrToInt(FParser[6]);
  aQuote.Low := StrToInt(FParser[7]);
  aQuote.Last := aSale.Price;
  aQuote.Change := StrToInt(FParser[3]) ;

    // 1, 장중  2:장개시전 시간외 3: 장종료휴 시간회, 4: 시간외 단일가
  //aQuote.MarketOper := StrToInt(FParser[11]);
    // size

  aQuote.UpdatePv0(dtQuote);


end;

procedure TQuoteParserPv0.ParseStockFuturesMarketDepth(stData: string);
var
  aQuote : TQuote;
  i : integer;
  dtQuote : TDateTime;
begin
// STOCK_FUT_HO
  if FQuoteBroker = nil then Exit;

  if FParser.Parse( stData, STOCK_FUT_HO ) < STOCK_FUT_HO_RANGE then
    Exit;

  aQuote := FQuoteBroker.Find( Copy(FParser[0],1,5));
  if aQuote =nil then
    Exit;

  aQuote.SavePrevMarketDepths;
  aQuote.Asks.Size := 10;
  aQuote.Bids.Size := 10;

  for i := 0 to aQuote.Asks.Size-1 do
  begin
    aQuote.Asks[i].Price  := StrToInt(FParser[6*i+4]);
    aQuote.Bids[i].Price  := StrToInt(FParser[6*i+6]);
    aQuote.Asks[i].Volume := StrToInt(FParser[6*i+7]);
    aQuote.Bids[i].Volume := StrToInt(FParser[6*i+8]);
    aQuote.Asks[i].Cnt    := StrToInt(FParser[2*i+63]);
    aQuote.Bids[i].Cnt    := StrToInt(FParser[2*i+64]);
  end;

  aQuote.Asks.VolumeTotal := StrToInt(FParser[83]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[84]);

  aQuote.UpdatePv0(dtQuote);

end;



procedure TQuoteParserPv0.ParseStockFuturesTimeNSale(stData: string);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
begin
  if FQuoteBroker = nil then Exit;
    // parse: packet size = 301 bytes
  if FParser.Parse( stData, STOCK_FUT_CO ) < STOCK_FUT_CO_RANGE then
  begin
    // do something here
    Exit;
  end;

    // find the quote
  aQuote := FQuoteBroker.Find(Copy(FParser[0],1,5));
  if aQuote = nil then Exit; // no subscription for this symbol

      // size
  aQuote.Asks.Size := 10;
  aQuote.Bids.Size := 10;

    // translation
  try
    aQuote.SavePrevMarketDepths;
      // new time&sale
    aSale := aQuote.Sales.New;

    aSale.LocalTime := gEnv.Engine.QuoteBroker.Timers.Now;
    aSale.Time := FQuoteDate
                  + EncodeTime(StrToInt(Copy(FParser[2],1,2)), // hour
                               StrToInt(Copy(FParser[2],3,2)), // min
                               StrToInt(Copy(FParser[2],5,2)), // sec
                               StrToInt(Copy(FParser[2],7,2))); // msec
    aSale.Volume := StrToInt(FParser[21]);
        // price
    if FParser[3] = '-' then
      aSale.Price := -StrToInt(FParser[4])
    else
      aSale.Price := StrToInt(FParser[4]);
        // side
    if  aSale.Price > aQuote.Asks[0].Price - KRX_PRICE_EPSILON then
      aSale.Side := 1
    else
      aSale.Side := -1;

      // O, H, L, C
    if FParser[7] = '-' then
      aQuote.Open := -StrToInt(FParser[8])
    else
      aQuote.Open := StrToInt(FParser[8]) ;
    if FParser[9] = '-' then
      aQuote.High := -StrToInt(FParser[10])
    else
      aQuote.High := StrToInt(FParser[10]) ;
    if FParser[11] = '-' then
      aQuote.Low := -StrToInt(FParser[12])
    else
      aQuote.Low := StrToInt(FParser[12]) ;
    aQuote.Last := aSale.Price;
    aQuote.Change := StrToInt(FParser[20]) ;
    if FParser[19][1] = '-' then
      aQuote.Change := aQuote.Change * -1;

    //aQuote.OpenInterest := 0;
    //aQuote.DailyVolume := StrToInt(FParser[13]);
    //aQuote.DailyAmount := StrToFloat(FParser[14])

      // ask prices 매도
    if FParser[22] = '-' then
      aQuote.Asks[0].Price := -StrToInt(FParser[23])
    else
      aQuote.Asks[0].Price := StrToInt(FParser[23]);
    if FParser[28] = '-' then
      aQuote.Asks[1].Price := -StrToInt(FParser[29])
    else
      aQuote.Asks[1].Price := StrToInt(FParser[29]);
    if FParser[34] = '-' then
      aQuote.Asks[2].Price := -StrToInt(FParser[35])
    else
      aQuote.Asks[2].Price :=  StrToInt(FParser[35]);
    if FParser[40] = '-' then
      aQuote.Asks[3].Price := -StrToInt(FParser[41])
    else
      aQuote.Asks[3].Price := StrToInt(FParser[41]);
    if FParser[46] = '-' then
      aQuote.Asks[4].Price := -StrToInt(FParser[47])
    else
      aQuote.Asks[4].Price := StrToInt(FParser[47]);
    // 6호가
    if FParser[52] = '-' then
      aQuote.Asks[5].Price := -StrToInt(FParser[53])
    else
      aQuote.Asks[5].Price := StrToInt(FParser[53]);
    if FParser[58] = '-' then
      aQuote.Asks[6].Price := -StrToInt(FParser[59])
    else
      aQuote.Asks[6].Price := StrToInt(FParser[59]);
    if FParser[64] = '-' then
      aQuote.Asks[7].Price := -StrToInt(FParser[65])
    else
      aQuote.Asks[7].Price := StrToInt(FParser[65]);
    if FParser[70] = '-' then
      aQuote.Asks[8].Price := -StrToInt(FParser[71])
    else
      aQuote.Asks[8].Price := StrToInt(FParser[71]);
    if FParser[76] = '-' then
      aQuote.Asks[9].Price := -StrToInt(FParser[77])
    else
      aQuote.Asks[9].Price := StrToInt(FParser[77]);

      // bid prices
    if FParser[24] = '-' then
      aQuote.Bids[0].Price := -StrToInt(FParser[25])
    else
      aQuote.Bids[0].Price := StrToInt(FParser[25]);
    if FParser[30] = '-' then
      aQuote.Bids[1].Price := -StrToInt(FParser[31])
    else
      aQuote.Bids[1].Price := StrToInt(FParser[31]);
    if FParser[36] = '-' then
      aQuote.Bids[2].Price := -StrToInt(FParser[37])
    else
      aQuote.Bids[2].Price := StrToInt(FParser[37]);
    if FParser[42] = '-' then
      aQuote.Bids[3].Price := -StrToInt(FParser[43])
    else
      aQuote.Bids[3].Price := StrToInt(FParser[43]);
    if FParser[48] = '-' then
      aQuote.Bids[4].Price := -StrToInt(FParser[49])
    else
      aQuote.Bids[4].Price := StrToInt(FParser[49]);

    if FParser[54] = '-' then
      aQuote.Bids[5].Price := -StrToInt(FParser[55])
    else
      aQuote.Bids[5].Price := StrToInt(FParser[55]);
    if FParser[30] = '-' then
      aQuote.Bids[6].Price := -StrToInt(FParser[61])
    else
      aQuote.Bids[6].Price := StrToInt(FParser[61]);
    if FParser[36] = '-' then
      aQuote.Bids[7].Price := -StrToInt(FParser[67])
    else
      aQuote.Bids[7].Price := StrToInt(FParser[67]);
    if FParser[44] = '-' then
      aQuote.Bids[8].Price := -StrToInt(FParser[73])
    else
      aQuote.Bids[8].Price := StrToInt(FParser[73]);
    if FParser[50] = '-' then
      aQuote.Bids[9].Price := -StrToInt(FParser[79])
    else
      aQuote.Bids[9].Price := StrToInt(FParser[79]);

      // ask volumes
    aQuote.Asks.VolumeTotal := StrToInt(FParser[102]);
    aQuote.Asks[0].Volume := StrToInt(FParser[26]);
    aQuote.Asks[1].Volume := StrToInt(FParser[32]);
    aQuote.Asks[2].Volume := StrToInt(FParser[38]);
    aQuote.Asks[3].Volume := StrToInt(FParser[44]);
    aQuote.Asks[4].Volume := StrToInt(FParser[50]);

    aQuote.Asks[5].Volume := StrToInt(FParser[56]);
    aQuote.Asks[6].Volume := StrToInt(FParser[62]);
    aQuote.Asks[7].Volume := StrToInt(FParser[68]);
    aQuote.Asks[8].Volume := StrToInt(FParser[74]);
    aQuote.Asks[9].Volume := StrToInt(FParser[80]);
      // bid volumes
    aQuote.Bids.VolumeTotal := StrToInt(FParser[103]);
    aQuote.Bids[0].Volume := StrToInt(FParser[27]);
    aQuote.Bids[1].Volume := StrToInt(FParser[33]);
    aQuote.Bids[2].Volume := StrToInt(FParser[39]);
    aQuote.Bids[3].Volume := StrToInt(FParser[45]);
    aQuote.Bids[4].Volume := StrToInt(FParser[51]);

    aQuote.Bids[5].Volume := StrToInt(FParser[57]);
    aQuote.Bids[6].Volume := StrToInt(FParser[63]);
    aQuote.Bids[7].Volume := StrToInt(FParser[69]);
    aQuote.Bids[8].Volume := StrToInt(FParser[75]);
    aQuote.Bids[9].Volume := StrToInt(FParser[81]);
      // number of short orders
    aQuote.Asks.CntTotal := StrToInt(FParser[104]);
    aQuote.Asks[0].Cnt := StrToInt(FParser[82]);
    aQuote.Asks[1].Cnt := StrToInt(FParser[84]);
    aQuote.Asks[2].Cnt := StrToInt(FParser[86]);
    aQuote.Asks[3].Cnt := StrToInt(FParser[88]);
    aQuote.Asks[4].Cnt := StrToInt(FParser[90]);

    aQuote.Asks[5].Cnt := StrToInt(FParser[92]);
    aQuote.Asks[6].Cnt := StrToInt(FParser[94]);
    aQuote.Asks[7].Cnt := StrToInt(FParser[96]);
    aQuote.Asks[8].Cnt := StrToInt(FParser[98]);
    aQuote.Asks[9].Cnt := StrToInt(FParser[100]);
      // number of long orders
    aQuote.Bids.CntTotal := StrToInt(FParser[105]);
    aQuote.Bids[0].Cnt := StrToInt(FParser[83]);
    aQuote.Bids[1].Cnt := StrToInt(FParser[85]);
    aQuote.Bids[2].Cnt := StrToInt(FParser[87]);
    aQuote.Bids[3].Cnt := StrToInt(FParser[89]);
    aQuote.Bids[4].Cnt := StrToInt(FParser[91]);

    aQuote.Bids[5].Cnt := StrToInt(FParser[93]);
    aQuote.Bids[6].Cnt := StrToInt(FParser[95]);
    aQuote.Bids[7].Cnt := StrToInt(FParser[97]);
    aQuote.Bids[8].Cnt := StrToInt(FParser[99]);
    aQuote.Bids[9].Cnt := StrToInt(FParser[101]);

      //
    aQuote.UpdatePv0(aSale.Time);
  except
    // do something here
  end;
end;

// h3
procedure TQuoteParserPv0.ParseKRXELWMarketDepth(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
begin
  if FQuoteBroker = nil then Exit;

    // packet size = 647Byte
  if FParser.Parse(stData, [2,12,10,9,9,    10,10,10,10,9,
                            9,10,10,10,10,  9,9,10,10,10,
                            10,9,9,10,10,   10,10,9,9,10,
                            10,10,10,9,9,   10,10,10,10,9,
                            9,10,10,10,10,  9,9,10,10,10,
                            10,9,9,10,10,   10,10,9,9,10,
                            10,10,10,10,10, 1,1,9,10,1,
                            1]) < 71 then
  begin
    // do something here
    Exit;
  end;

    // check subscription
  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

    // size
  aQuote.Asks.Size := 10;
  aQuote.Bids.Size := 10;

  for i := 0 to 9 do
  begin
    aQuote.Asks[i].Price := StrToFloat(FParser[6*i+3]);
    aQuote.Bids[i].Price := StrToFloat(FParser[6*i+4]);
    aQuote.Asks[i].Volume := StrToInt(FParser[6*i+5]);
    aQuote.Bids[i].Volume := StrToInt(FParser[6*i+6]);


    aQuote.Asks[i].LPVolume := StrToInt(FParser[6*i+7]);
    aQuote.Bids[i].LPVolume := StrToInt(FParser[6*i+8]);

  end;

  aQuote.Asks.VolumeTotal := StrToInt(FParser[63]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[64]);

  aQuote.EstFillPrice := StrToFloat(FParser[67]);
  aQuote.EstFillQty := StrToFloat(FParser[68]);

  aQuote.UpdatePv0(dtQuote);
end;

// HA
procedure TQuoteParserPv0.ParseKosdaqStockMarketDepth(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
begin
  if FQuoteBroker = nil then Exit;

    // packet size = 409Byte
  if FParser.Parse(stData, [2,12,12,7,7,   10,10,7,7,10,
                            10,7,7,10,10,  7,7,10,10,7,
                            7,10,10,7,7,   10,10,7,7,10,
                            10,7,7,10,10,  7,7,10,10,7,
                            7,10,10,10,10, 1,1,1,7,12,
                            1]) < 51 then
  begin
    // do something here
    Exit;
  end;

    // check subscription

  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

    // size
  aQuote.Asks.Size := 10;
  aQuote.Bids.Size := 10;

  for i := 0 to 9 do
  begin
    aQuote.Asks[i].Price := StrToFloat(FParser[4*i+3]);
    aQuote.Bids[i].Price := StrToFloat(FParser[4*i+4]);
    aQuote.Asks[i].Volume := StrToInt(FParser[4*i+5]);
    aQuote.Bids[i].Volume := StrToInt(FParser[4*i+6]);
  end;
  aQuote.Asks.VolumeTotal := StrToInt(FParser[43]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[44]);

  aQuote.EstFillPrice := StrToFloat(FParser[47]);
  aQuote.EstFillQty := StrToFloat(FParser[48]);

  aQuote.UpdatePv0(dtQuote);
end;

procedure TQuoteParserPv0.ParseKospiStockVolumeTotal(stData: String);
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

  aQuote.UpdatePv0(dtQuote);
end;

procedure TQuoteParserPv0.ParseKosdaqStockVolumeTotal(stData: String);
var
  aQuote : TQuote;
  dtQuote : TDateTime;
  i : Integer;
begin
  if FQuoteBroker = nil then Exit;

    // packet size = 407Byte
  if FParser.Parse(stData, [2,12,12,10,10,1]) < 6 then
  begin
    // do something here
    Exit;
  end;

    // check subscription
  aQuote := FQuoteBroker.Find(FParser[1]);
  if aQuote = nil then Exit; // nobody subscribe for this futures

  aQuote.Asks.VolumeTotal := StrToInt(FParser[3]);
  aQuote.Bids.VolumeTotal := StrToInt(FParser[4]);

  aQuote.UpdatePv0(dtQuote);
end;


end.
