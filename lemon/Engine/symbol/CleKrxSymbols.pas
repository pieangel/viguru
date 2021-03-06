unit CleKrxSymbols;

interface

uses
  SysUtils, Math,
    // lemon: common
  GleConsts,
    // lemon: data
  CleFQN, CleMarketSpecs, CleSymbols;


const
  KOSPI200_CODE = '01';
  KOSDAQ150_CODE   = '03';
  KRX300_CODE      = '08';
  MINI_KOSPI200_CODE = '105';
  WEEKLY_KOSPI200_CODE = '109';
  //
  BOND3_CODE = 'bond3';
  BOND5_CODE = 'bond5';
  BOND10_CODE = 'bond10';

  DOLLAR_CODE = 'dollarfut';
  YEN_CODE    = 'yenfut';

  KRX_PRICE_EPSILON = 1.0e-8;

  // 시장 코드 정의 
  FQN_KRX_INDEX = 'index.krx.kr';
  FQN_KRX_STOCK = 'stock.krx.kr';
  FQN_KRX_BOND = 'bond.krx.kr';
  FQN_KRX_ETF = 'etf.krx.kr';
  FQN_KRX_CURRENCY = 'currency.krx.kr';

  FQN_KOSPI200_FUTURES = 'kospi200.future.krx.kr'; // Vi Code : 101F
  FQN_KOSPI200_OPTION  = 'kospi200.option.krx.kr'; // Vi Code : 101O
  FQN_KOSPI200_FUTURES_SPREAD = 'kospi200.spread.krx.kr'; //
  FQN_KRX300_FUTURES = 'krx300.future.krx.kr';

  FQN_KOSDAQ150_FUTURES = 'kosdaq150.future.krx.kr';  // 106F

  FQN_KOSPI200_WEEKLY_FUTURES = 'weekly.kospi200.option.krx.kr';  // 109O
                                              {
  FQN_CURRENCY_FUTURES = 'currency.future.krx.kr';
  FQN_CURRENCY_OPTION  = 'currency.option.krx.kr';
  FQN_BOND_FUTURES     = 'bond.future.krx.kr';
                                               }
  // add by 20151123 mini
  FQN_MINI_KOSPI200_FUTURES = 'mini.kospi200.future.krx.kr';  // 105F
  FQN_MINI_KOSPI200_OPTION = 'mini.kospi200.option.krx.kr';  // 105O
  FQN_MINI_KOSPI200_FUTURES_SPREAD = 'mini.kospi200.spread.krx.kr';

  FQN_DOLLAR_FUTURES = 'dollar.future.krx.kr';  // 175F
  FQN_DOLLAR_OPTION  = 'dollar.option.krx.kr';  // 175O
  FQN_YEN_FUTURES    = 'yen.future.krx.kr';


  FQN_BOND3_FUTURES  = 'bond3.future.krx.kr';
  FQN_BOND5_FUTURES   = 'bond5.future.krx.kr';
  FQN_BOND10_FUTURES    = 'bond10.future.krx.kr';  // 167F


type
  TMarketSpecRec = record
    //VIFQN: String;
    FQN: String;
    Root: String;
    Desc: String;
    Sector: String;
    Currency: Integer;
    TickSize: Double;
    Frac: Integer;
    Prec: Integer;
    ContractSize: Integer;
    PriceQuote: Double;
  end;

const
  // 마켓 스펙
  KRX_SPECS: array[0..16] of TMarketSpecRec = (
        // index
      (FQN:FQN_KRX_INDEX; Root:''; Desc: 'KRX Stock Index'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 1; PriceQuote: 1),
        // stock spec
      (FQN:FQN_KRX_STOCK; Root:''; Desc: 'KRX Stock'; Sector: 'Stock';
       Currency: CURRENCY_WON; TickSize: 1; Frac: 1; Prec: 0;
       ContractSize: 1; PriceQuote: 1),

      (FQN:FQN_KRX_CURRENCY; Root:''; Desc: 'KRX Currency'; Sector: 'Currency';
       Currency: CURRENCY_WON; TickSize: 0.1; Frac: 1; Prec: 2;
       ContractSize: 1; PriceQuote: 1),
        // stock spec
      (FQN:FQN_KRX_BOND; Root:''; Desc: 'KRX Bond'; Sector: 'Bond';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 0;
       ContractSize: 1; PriceQuote: 1),

        // KOSPI200 futures
      (FQN:FQN_KOSPI200_FUTURES; Root:KOSPI200_CODE;
       Desc: 'KOSPI200 Futures'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.05; Frac: 1; Prec: 2;
       ContractSize: 100000; PriceQuote: 1),

        // KRX futures
      (FQN:FQN_KRX300_FUTURES; Root:KRX300_CODE;
       Desc: 'KRX300 Futures'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.2; Frac: 1; Prec: 2;
       ContractSize: 50000; PriceQuote: 1),

        // KOSDAQ futures
      (FQN:FQN_KOSDAQ150_FUTURES; Root:KOSDAQ150_CODE;
       Desc: 'KOSDAQ150 Futures'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.1; Frac: 1; Prec: 2;
       ContractSize: 10000; PriceQuote: 1),

        // KOSPI200 option
      (FQN:FQN_KOSPI200_OPTION; Root:KOSPI200_CODE;
       Desc: 'KOSPI200 Option'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 100000; PriceQuote: 1),   // 2012.6.15 승수 변경

          // KOSPI200 weekly option
      (FQN:FQN_KOSPI200_WEEKLY_FUTURES; Root:WEEKLY_KOSPI200_CODE;
       Desc: 'KOSPI200 Weekly Option'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 100000; PriceQuote: 1),   

        // Mini KOSPI200 futures
      (FQN:FQN_MINI_KOSPI200_FUTURES; Root:MINI_KOSPI200_CODE;
       Desc: 'Mini KOSPI200 Futures'; Sector: 'Mini Index';
       Currency: CURRENCY_WON; TickSize: 0.02; Frac: 1; Prec: 2;
       ContractSize: 100000; PriceQuote: 1),   // 한틱 2,000 원
        // Mini KOSPI200 mini option
      (FQN:FQN_MINI_KOSPI200_OPTION; Root:MINI_KOSPI200_CODE;
       Desc: 'Mini KOSPI200 Option'; Sector: 'Mini Index';
       Currency: CURRENCY_WON; TickSize: 0.02; Frac: 1; Prec: 2;
       ContractSize: 100000; PriceQuote: 1),    // 한틱 2,000 원
       {
      (FQN:FQN_MINI_KOSPI200_FUTURES_SPREAD; Root:MINI_KOSPI200_CODE;
       Desc: 'Mini KOSPI200 Futures Spread'; Sector: 'Mini Index';
       Currency: CURRENCY_WON; TickSize: 0.02; Frac: 1; Prec: 2;
       ContractSize: 100000; PriceQuote: 1),   // 한틱 2,000 원
       }

       // 달러선물
      (FQN:FQN_DOLLAR_FUTURES; Root:DOLLAR_CODE;
       Desc: 'Dollar Futures'; Sector: 'Currency';
       Currency: CURRENCY_WON; TickSize: 0.1; Frac: 1; Prec: 2;
       ContractSize: 10000; PriceQuote: 1),     // 한틱 1,000 원

       // 엔선물
      (FQN:FQN_YEN_FUTURES; Root:YEN_CODE;
       Desc: 'Yen Futures'; Sector: 'Currency';
       Currency: CURRENCY_WON; TickSize: 0.1; Frac: 1; Prec: 2;
       ContractSize: 10000; PriceQuote: 1),     // 한틱 1,000 원

       // 달러옵션
      (FQN:FQN_DOLLAR_OPTION; Root:DOLLAR_CODE;
       Desc: 'Dollar Option'; Sector: 'Currency';
       Currency: CURRENCY_WON; TickSize: 0.1; Frac: 1; Prec: 2;
       ContractSize: 10000; PriceQuote: 1),     // 한틱 1,000 원

        //  3년국채 선물
      (FQN:FQN_BOND3_FUTURES; Root:BOND3_CODE;
       Desc: 'Bond 3Year Futures'; Sector: 'Bond';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 1000000; PriceQuote: 1),   // 한틱 10,000원
        //  5년국채
      (FQN:FQN_BOND5_FUTURES; Root:BOND5_CODE;
       Desc: 'Bond 5Year Futures'; Sector: 'Bond';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 1000000; PriceQuote: 1),    // 한틱 10,000원

        //  10년 국채
      (FQN:FQN_BOND10_FUTURES; Root:BOND10_CODE;
       Desc: 'Bond 10Year Futures'; Sector: 'Bond';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 1000000; PriceQuote: 1)    // 한틱 10,000원

    );

//------------------------------------------------------------< quote parsing >




//-----------------------------------------------------------< price routines >

function TicksFromPrice(aSymbol: TSymbol; dPrice: Double; iTicks: Integer): Double;
function CheckPrice(aSymbol: TSymbol; stPrice: String; var stError: String): Boolean;

implementation

function TicksFromPrice(aSymbol: TSymbol; dPrice: Double; iTicks: Integer): Double;
var
  i, iSign : Integer;
begin
  Result := dPrice;

  if (iTicks = 0)
     or (aSymbol = nil)
     or (aSymbol.Spec = nil) then Exit;

  case aSymbol.Spec.Market of
    mtNotAssigned: ;
    mtIndex: ; // no service
    mtBond: ;  // no service
    mtETF: ;   // no service
    mtFutures:
      with aSymbol as TFuture do
      begin
        if (Underlying <> nil)  and (Underlying.Spec <> nil)
           and (Underlying.Spec.Market = mtStock) then
        begin
          iSign := iTicks div Abs(iTicks);
          // 20180923 update
          for i:=1 to Abs(iTicks) do
          if iSign > 0 then
          begin
            if Result > 500000.0 - EPSILON then
              Result := Result + 1000
            else if Result > 100000 - EPSILON then
              Result := Result + 500
            else if Result > 50000 - EPSILON then
              Result := Result + 100
            else if Result > 10000 - EPSILON then
              Result := Result + 50
            else
              Result := Result + 10;
          end else
          begin
            if Result < 10000 + EPSILON then
              Result := Result - 10
            else if Result < 50000 + EPSILON then
              Result := Result - 50
            else if Result < 100000 + EPSILON then
              Result := Result - 100
            else if Result < 500000 + EPSILON then
              Result := Result - 500
            else
              Result := Result - 1000;
          end;
        end else
        begin
          Result := dPrice + iTicks * aSymbol.Spec.TickSize;
        end;
      end;
    mtOption:
    if CompareStr(aSymbol.Spec.FQN, FQN_KOSPI200_OPTION) = 0 then
      begin
        iSign := iTicks div Abs(iTicks);

        for i:=1 to Abs(iTicks) do
        if iSign > 0 then
          if Result > 10.0 - EPSILON then
            Result := Result + 0.05
          else
            Result := Result + 0.01
        else
          if Result < 10.0 + EPSILON then
            Result := Result - 0.01
          else
            Result := Result - 0.05;
      end else
      if CompareStr(aSymbol.Spec.FQN, FQN_MINI_KOSPI200_OPTION) = 0 then
      begin
        iSign := iTicks div Abs(iTicks);

        for i:=1 to Abs(iTicks) do
        if iSign > 0 then
          if Result > 10.0 - EPSILON then
            Result := Result + 0.05
          else if Result > 3.0 - EPSILON then
            Result := Result + 0.02
          else
            Result := Result + 0.01
        else
          if Result < 3.0 + EPSILON then
            Result := Result - 0.01
          else if Result < 10.0 + EPSILON then
            Result := Result - 0.02
          else
            Result := Result - 0.05;
      end else
      begin
         Result := dPrice + iTicks * aSymbol.Spec.TickSize;
      end;
    mtStock,
    mtELW:
      begin
        iSign := iTicks div Abs(iTicks);

        for i:=1 to Abs(iTicks) do
        if iSign > 0 then
        begin
          if Result > 500000.0 - EPSILON then
            Result := Result + 1000
          else if Result > 100000 - EPSILON then
            Result := Result + 500
          else if Result > 50000 - EPSILON then
            Result := Result + 100
          else if Result > 10000 - EPSILON then
            Result := Result + 50
          else if Result > 5000 - EPSILON then
            Result := Result + 10
          else
            Result := Result + 5;
        end else
        begin
          if Result < 5000 + EPSILON then
            Result := Result - 5
          else if Result < 10000 + EPSILON then
            Result := Result - 10
          else if Result < 50000 + EPSILON then
            Result := Result - 50
          else if Result < 100000 + EPSILON then
            Result := Result - 100
          else if Result < 500000 + EPSILON then
            Result := Result - 500
          else
            Result := Result - 1000;
        end;
      end;
    mtSpread: Result := dPrice + iTicks * aSymbol.Spec.TickSize;
  end;
end;

function CheckPrice(aSymbol: TSymbol; stPrice: String; var stError: String): Boolean;
var
  dPrice: Double;
  stFloat: String;
  iLen, iPos, iEnd: Integer;
begin
  Result := False;

  stError := '';
    // check
  if (aSymbol = nil) or (aSymbol.Spec = nil) then Exit;

    // check I -- conversion
  stPrice := Trim(stPrice);
  try
    dPrice := StrToFloat(stPrice);
  except
    stError := '가격 입력이 잘못 되었습니다';
    Exit;
  end;

    // check II -- price range
  if aSymbol.Spec.Market in [mtFutures, mtOption, mtELW] then
    if (dPrice < aSymbol.LimitLow - EPSILON) or (dPrice > aSymbol.LimitHigh + EPSILON) then
  begin
    stError := Format('가격이 상하한가 범위(%.2f-%.2f) 밖입니다',
                        [aSymbol.LimitLow, aSymbol.LimitHigh]);
    Exit;
  end;

    // check III -- Price unit (호가단위)
  if (aSymbol.Spec.Market in [mtFutures, mtOption, mtELW]) and ( not aSymbol.IsStockF ) then
  begin
      // get floating part
    iPos := Pos('.', stPrice);
    if iPos <= 0 then
    begin
      Result := True;
      Exit; // no floating point
    end;
    stFloat := Copy(stPrice, iPos+1, Length(stPrice)-iPos);
      // longer or shorter than 2 float point?
    iLen := Length(stFloat);
    if (iLen > 2) and
       (StrToIntDef(Copy(stFloat,3,iLen-2),-1) <> 0) then
    begin
      stError := '가격은 소숫점 둘째자리까지 입력하십시오';
      Exit;
    end;

    if iLen < 2 then
    begin
      Result := True;
      Exit;
    end;

      // final check
    iEnd := StrToInt(stFloat[2]);
    if ( aSymbol.Spec.Market = mtOption) and (dPrice < 3.0 - EPSILON) then
      Result := true
    else if aSymbol.Spec.Market = mtFutures then
    begin
      if ( aSymbol.Spec.FQN = FQN_KOSPI200_FUTURES ) and(iEnd mod 5 = 0) then
        Result := true
      else if ( aSymbol.Spec.FQN = FQN_MINI_KOSPI200_FUTURES ) and (iEnd mod 2 = 0) then
        Result := true
      else
        Result := True;
    end
    else
      stError := format('가격이 호가단위(%.0n)에 맞지 않습니다',[aSymbol.Spec.TickSize]) ;
  end else
  if aSymbol.Spec.Market = mtStock then
  begin
    if aSymbol.Spec.TickSize < EPSILON then Exit;

    if Abs(Round(dPrice/aSymbol.Spec.TickSize) * aSymbol.Spec.TickSize - dPrice)
        < EPSILON then
      Result := True
    else
      stError := Format('호가단위(%.0n)가 맞지 않습니다', [aSymbol.Spec.TickSize]);
  end;
end;

end.
