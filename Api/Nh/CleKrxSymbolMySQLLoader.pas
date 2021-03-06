unit CleKrxSymbolMySQLLoader;

interface

uses
  Classes, SysUtils, Dialogs, Math, ADODB,  Forms,  DateUtils,

    // lemon: common
  GleTypes,  GleConsts,
    // lemon: utils
  CleMySQLConnector, CleParsers,
    // lemon: data
  CleMarketSpecs, CleSymbols,
    // lemon: KRX
  CleKrxSymbols
    // simulation
  ;

const
  DBLoadCount = 400;

type
  TKRXSymbolMySQLLoader = class
  private
    FConnector: TMySQLConnector;

    FParser: TParser;
    FRecords: TStringList;
    FCodes: TStringList;

    FOnLog: TTextNotifyEvent;

    procedure DoLog(stLog: String);
    function GetUnderlying(stUnder: string): TSymbol;
    function GetUnderlyingByVi(stUnder: string): TSymbol;
    function GetMarketSpec(stUnder: string; bOpt : boolean): TMarketSpec;
    function GetMarketSpecByVi(stUnder: string; bOpt : boolean): TMarketSpec;
    procedure ImportMasterFromKrApi(stData: string);

  public
    constructor Create(aConnector: TMySQLConnector);
    destructor Destroy; override;

      // register fixed information
    procedure SetSpecs;
    procedure UpdateSpec;
    procedure AddFixedSymbols;

    // api
    procedure ImportMasterFromNHApi( aList : TStringList; iCnt : integer );
    procedure ImportMasterFromSymbolCode( stSymbolCode: string );
      // properties
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
  end;

implementation

uses GAppEnv, GleLib, CleMarkets, Ticks, CleFQN, GAppConsts,
CleQuoteBroker, ApiPacket, ApiConsts;

{ TKRXSymbolMySQLLoader }

constructor TKRXSymbolMySQLLoader.Create( aConnector: TMySQLConnector);
begin

  FConnector := aConnector;
     // create objects
  FParser := TParser.Create([',']);
  FRecords := TStringList.Create;
  FCodes := TStringList.Create;
  FCodes.Sorted := True;
end;

destructor TKRXSymbolMySQLLoader.Destroy;
begin

  FRecords.Free;
  FParser.Free;
  FCodes.Free;

  inherited;
end;

procedure TKRXSymbolMySQLLoader.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, 'KRX MySQL Symbol Loader: ' + stLog);
end;

//---------------------------------------------------------------< fixed info >

// register market specification using the information
// in the unit CleKRXSymbols
//



procedure TKRXSymbolMySQLLoader.SetSpecs;
var
  i: Integer;
begin
  if gEnv.Engine = nil then Exit;

  for i := Low(KRX_SPECS) to High(KRX_SPECS) do
    with gEnv.Engine.SymbolCore.Specs.New(KRX_SPECS[i].FQN) do
    begin
      RootCode := KRX_SPECS[i].Root;
      Description := KRX_SPECS[i].Desc;
      Sector := KRX_SPECS[i].Sector;
      Currency := KRX_SPECS[i].Currency;
      SetTick(KRX_SPECS[i].TickSize, KRX_SPECS[i].Frac, KRX_SPECS[i].Prec);
      SetPoint(KRX_SPECS[i].ContractSize, KRX_SPECS[i].PriceQuote);
    end;
end;

procedure TKRXSymbolMySQLLoader.UpdateSpec;

  procedure SetPointValue(aSpec : TMarketSpec; stResult : string);
  var
    stTmp : string;
    dUnit : double;
  begin
    if aSpec = nil then Exit;
    dUnit := StrToFloatDef( trim(stResult), 1 );
    if dUnit > 0 then  begin
      stTmp := Format('%s, %.0f', [ aSpec.FQN, aSpec.PointValue ]);
      aSpec.SetPoint( dUnit, 1);
      gEnv.EnvLog( WIN_TEST, Format( '???????? :  %s -> %.0f', [ stTmp, aSpec.PointValue])  );
    end;
  end;
var
  I: integer;
  aFutMarket : TFutureMarket;
begin         

  with gEnv.Engine do
  begin
    {
    if SymbolCore.Future <> nil then
      SetPointValue( SymbolCore.Future.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.Future.Code ));
    if SymbolCore.MiniFuture <> nil then
      SetPointValue( SymbolCore.MiniFuture.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.MiniFuture.Code ));

    if SymbolCore.KrxFuture <> nil then
      SetPointValue( SymbolCore.KrxFuture.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.KrxFuture.Code ));

    if SymbolCore.UsFuture <> nil then
      SetPointValue( SymbolCore.UsFuture.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.UsFuture.Code ));
    if SymbolCore.JpyFuture <> nil then
      SetPointValue( SymbolCore.JpyFuture.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.JpyFuture.Code ));

    if SymbolCore.Bond3Future <> nil then
      SetPointValue( SymbolCore.Bond3Future.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.Bond3Future.Code ));
    if SymbolCore.Bond5Future <> nil then
      SetPointValue( SymbolCore.Bond5Future.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.Bond5Future.Code ));
    if SymbolCore.Bond10Future <> nil then
      SetPointValue( SymbolCore.Bond10Future.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.Bond10Future.Code ));
    if SymbolCore.KD150Future <> nil then
      SetPointValue( SymbolCore.KD150Future.Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.KD150Future.Code ));

    if SymbolCore.MonthlyItem.Symbols.Count > 0 then
      SetPointValue( SymbolCore.MonthlyItem.Options[0].Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.MonthlyItem.Options[0].Code ));

    if SymbolCore.MiniMonthlyItem.Symbols.Count > 0 then
      SetPointValue( SymbolCore.MiniMonthlyItem.Options[0].Spec, Api.Api.OGetJongMokInfo( 9, SymbolCore.MiniMonthlyItem.Options[0].Code ));

    // ??????????
    for I := 0 to SymbolCore.FutureMarkets.Count - 1 do
    begin
      aFutMarket := SymbolCore.FutureMarkets.FutureMarkets[ i ];
      if aFutMarket.FrontMonth <> nil then
        SetPointValue( aFutMarket.FrontMonth.Spec, Api.Api.OGetJongMokInfo( 9, aFutMarket.FrontMonth.Code ));
    end;
    }
  end;



end;

// rigister index symbols
// ?????? ???? ???? ?????? ????. 
procedure TKRXSymbolMySQLLoader.AddFixedSymbols;
var
  aIndex: TIndex;
  aCurr : TCurrency;
  aBond : TBond;
begin
  if gEnv.Engine = nil then Exit;

    // KOSPI200 index
  aIndex := gEnv.Engine.SymbolCore.Indexes.New(KOSPI200_CODE);
  aIndex.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_INDEX);
  aIndex.Name := 'K200 Index';
  aIndex.ShortCode  :=  KOSPI200_CODE;

  gEnv.Engine.SymbolCore.RegisterSymbol(aIndex);

    // KOSDAQ150 index
  aIndex := gEnv.Engine.SymbolCore.Indexes.New(KOSDAQ150_CODE);
  aIndex.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_INDEX);
  aIndex.Name := 'KD150 Index';
  aIndex.ShortCode  :=  KOSDAQ150_CODE;

  gEnv.Engine.SymbolCore.RegisterSymbol(aIndex);

  // KRX300 index
  aIndex := gEnv.Engine.SymbolCore.Indexes.New(KRX300_CODE);
  aIndex.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_INDEX);
  aIndex.Name := 'KRX300 Index';
  aIndex.ShortCode  :=  KRX300_CODE;
  gEnv.Engine.SymbolCore.RegisterSymbol(aIndex);


    // Mini KOSPI200 index
  aIndex := gEnv.Engine.SymbolCore.Indexes.New(MINI_KOSPI200_CODE);
  aIndex.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_INDEX);
  aIndex.Name := 'Mini K200 Index';
  aIndex.ShortCode  :=  MINI_KOSPI200_CODE;

  gEnv.Engine.SymbolCore.RegisterSymbol(aIndex);

    // ???? ???? ????
  aCurr := gEnv.Engine.SymbolCore.Currencies.New(DOLLAR_CODE);
  aCurr.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_CURRENCY);
  aCurr.Name := 'USA Dollar';
  aCurr.ShortCode  :=  DOLLAR_CODE;
  gEnv.Engine.SymbolCore.RegisterSymbol(aCurr);

    // ???? ?? ????
  aCurr := gEnv.Engine.SymbolCore.Currencies.New(YEN_CODE);
  aCurr.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_CURRENCY);
  aCurr.Name := 'JPY Yen';
  aCurr.ShortCode  :=  YEN_CODE;
  gEnv.Engine.SymbolCore.RegisterSymbol(aCurr);

    //  ???? ????   - 3?? ????
  aBond := gEnv.Engine.SymbolCore.Bonds.New(BOND3_CODE);
  aBond.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_BOND);
  aBond.Name := 'Bond 3Yesr';
  aBond.ShortCode  :=  BOND3_CODE;
  gEnv.Engine.SymbolCore.RegisterSymbol(aBond);


  aBond := gEnv.Engine.SymbolCore.Bonds.New(BOND5_CODE);
  aBond.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_BOND);
  aBond.Name := 'Bond 5Year';
  aBond.ShortCode  :=  BOND5_CODE;
  gEnv.Engine.SymbolCore.RegisterSymbol(aBond);



  aBond := gEnv.Engine.SymbolCore.Bonds.New(BOND10_CODE);
  aBond.Spec := gEnv.Engine.SymbolCore.Specs.Find(FQN_KRX_BOND);
  aBond.Name := 'BOnd 10Year';
  aBond.ShortCode  :=  BOND10_CODE;
  gEnv.Engine.SymbolCore.RegisterSymbol(aBond);


end;

//---------------------------------------------------------------------< load >
// ???????? ???? ????
// NH ?????? ???????? ???? ???? 
function TKRXSymbolMySQLLoader.GetUnderlying( stUnder : string ) : TSymbol;
var
  stCode : string;
begin
  stCode := '';

  if stUnder = K2I then   // Kospi 200 index
    stCode := KOSPI200_CODE
  else if stUnder = MKI then // Mini Kospi 200 Index
    stCode := MINI_KOSPI200_CODE
  else if stUnder = KSD then
    stCode := KOSDAQ150_CODE  // Kosdaq 150 Index
  else if stUnder = KX3 then
    stCode := KRX300_CODE   // Krx 300 Index
  else if stUnder = BM3 then
    stCode := BOND3_CODE    // Bond 3 Year
  else if stUnder = BM5 then
    stCode := BOND5_CODE   // Bond 5 Year
  else if stUnder = BMA then
    stCode := BOND10_CODE  // Bond 10 Year
  else if stUnder = JPY then
    stCode  := YEN_CODE  // Yen
  else if stUnder = USD then
    stCode :=  DOLLAR_CODE;  // Dollar

  Result := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode)
end;

function TKRXSymbolMySQLLoader.GetUnderlyingByVi( stUnder : string ) : TSymbol;
var
  stCode : string;
begin
  stCode := '';

  if stUnder = VI_KOSPI then   // Kospi 200 index
    stCode := KOSPI200_CODE
  else if stUnder = VI_MINI_KOSPI then // Mini Kospi 200 Index
    stCode := MINI_KOSPI200_CODE
  else if stUnder = VI_KOSDAQ then
    stCode := KOSDAQ150_CODE
  else if stUnder = KX3 then
    stCode := KRX300_CODE
  else if stUnder = BM3 then
    stCode := BOND3_CODE
  else if stUnder = BM5 then
    stCode := BOND5_CODE
  else if stUnder = VI_BOND_10YR then
    stCode := BOND10_CODE
  else if stUnder = JPY then
    stCode  := YEN_CODE
  else if stUnder = VI_USD then
    stCode :=  DOLLAR_CODE;

  Result := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode)
end;

// NH ?????? ???? ???? ???? ????
function TKRXSymbolMySQLLoader.GetMarketSpec( stUnder : string; bOpt : boolean ) : TMarketSpec;
var
  stCode : string;
begin
  stCode := '';

  if bOpt then
  begin
    if stUnder = K2I then
      stCode := FQN_KOSPI200_OPTION // ?????? 200 ????
    else if stUnder = MKI then
      stCode := FQN_MINI_KOSPI200_OPTION // ?????? 200 ???? ????
    else if stUnder = USD then
      stCode := FQN_DOLLAR_OPTION; // ?????? ???? ????
  end else
  begin
    if stUnder = K2I then
      stCode := FQN_KOSPI200_FUTURES  // ?????? 200 ????
    else if stUnder = MKI then
      stCode := FQN_MINI_KOSPI200_FUTURES   // ?????? 200 ????????
    else if stUnder = KX3 then
      stCode := FQN_KRX300_FUTURES  // krx 300 ????
    else if stUnder = KSD then
      stCode := FQN_KOSDAQ150_FUTURES // ?????? 150 ????
    else if stUnder = BM3 then
      stCode := FQN_BOND3_FUTURES  // 3???? ???? ????
    else if stUnder = BM5 then
      stCode := FQN_BOND5_FUTURES  // 5???? ???? ????
    else if stUnder = BMA then
      stCode := FQN_BOND10_FUTURES // 10???? ???? ????
    else if stUnder = JPY then
      stCode := FQN_YEN_FUTURES   // ?? ????
    else if stUnder = USD then
      stCode := FQN_DOLLAR_FUTURES;   // ???? ????
  end;

  // ?????? ???? ?????? ????????.
  Result  := gEnv.Engine.SymbolCore.Specs.Find( stCode );
end;

function TKRXSymbolMySQLLoader.GetMarketSpecByVi( stUnder : string; bOpt : boolean ) : TMarketSpec;
var
  stCode : string;
begin
  stCode := '';

  if bOpt then
  begin
    if stUnder = VI_KOSPI then
      stCode := FQN_KOSPI200_OPTION // ?????? 200 ????
    else if stUnder = VI_MINI_KOSPI then
      stCode := FQN_MINI_KOSPI200_OPTION // ?????? 200 ???? ????
    else if stUnder = VI_USD then
      stCode := FQN_DOLLAR_OPTION; // ?????? ???? ????
  end else
  begin
    if stUnder = VI_KOSPI then
      stCode := FQN_KOSPI200_FUTURES  // ?????? 200 ????
    else if stUnder = VI_MINI_KOSPI then
      stCode := FQN_MINI_KOSPI200_FUTURES   // ?????? 200 ????????
    else if stUnder = KX3 then
      stCode := FQN_KRX300_FUTURES  // krx 300 ????
    else if stUnder = VI_KOSDAQ then
      stCode := FQN_KOSDAQ150_FUTURES // ?????? 150 ????
    else if stUnder = BM3 then
      stCode := FQN_BOND3_FUTURES  // 3???? ???? ????
    else if stUnder = BM5 then
      stCode := FQN_BOND5_FUTURES  // 5???? ???? ????
    else if stUnder = VI_BOND_10YR then
      stCode := FQN_BOND10_FUTURES // 10???? ???? ????
    else if stUnder = JPY then
      stCode := FQN_YEN_FUTURES   // ?? ????
    else if stUnder = VI_USD then
      stCode := FQN_DOLLAR_FUTURES;   // ???? ????
  end;

  // ?????? ???? ?????? ????????.
  Result  := gEnv.Engine.SymbolCore.Specs.Find( stCode );
end;


procedure TKRXSymbolMySQLLoader.ImportMasterFromSymbolCode(stSymbolCode: string);
var
  //
  bNew, bOpt : boolean;
  stTmp, stcode, stName, stUnder, stFQN : string;
  iLen, i : integer;
  aUnder, aSymbol : TSymbol;
  cDiv : char;
  aSpec : TMarketSpec;
  stStrike, lastChar, preCode : string;
begin

  stTmp := '';
  bOpt := false;
  
  stTmp := Copy(stSymbolCode, 1, 1);
  if stTmp = '2' then
    cDiv := '2'
  else if  stTmp = '3' then
    cDiv := '3'
  else if stTmp = '1' then
    cDiv := '1'
  else Exit;

  // stTMp = '004' ???? aList[0] = '01' ---> ????????

  // ????
  case cDiv of
    '2','3' : bOpt := true;
  end;

  bNew := false;
  // ??????, ??????, ???? ??????, ???? ????
  stUnder := Copy(stSymbolCode, 2, 2);

  {
  preCode := Copy(stSymbolCode, 1, 3);
  if preCode = '101' then
    bNew := false;
  }

  // ???? ?????? ????????.
  aSpec   := GetMarketSpecByVi( stUnder, bOpt );
  // ???? ???? ?????? ????????.
  aUnder  := GetUnderlyingByVi( stUnder );

  // ???? ?????? ????????.
  stCode  := stSymbolCode;
  // ???? ?????? ?????? ???? ????. 
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
  {
  // 2017.03.27 ????????
  if aSpec <> nil then
  begin
    dUnit := StrToFloatDef( trim(string(pMaster.TradeUnit)), 1 );
    if dUnit > 0 then
      aSpec.SetPoint( dUnit, 1);
  end;
  }

  // ?????? ?????? ????
  if aSymbol = nil then
  begin
    bNew := true;
    case cDiv of
      '1' : aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
      '2' :
        begin
          aSymbol := gEnv.Engine.SymbolCore.Options.New(stCode);
          (aSymbol as TOption).CallPut := 'C';
          aSymbol.OptionType  := otCall;
        end ;
      '3' :
        begin
          aSymbol := gEnv.Engine.SymbolCore.Options.New(stCode);
          (aSymbol as TOption).CallPut := 'P';
          aSymbol.OptionType  := otPut;
        end ;
      '4' : // ????????
        begin
          aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
          stFQN   := stUnder+'.future.krx.kr';
          aSpec   := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
          aSymbol.IsStockF := true;
          if aSpec = nil then
          begin
            aSpec := gEnv.Engine.SymbolCore.Specs.New(stFQN);
            aSpec.RootCode := stUnder;
            aSpec.Description := aUnder.Name + ' Futures';
            {todo: }
            //aSpec.Sector := FieldByName('krx100section').AsString;
            aSpec.Currency := CURRENCY_WON;
            aSpec.SetTick(10, 1, 0);
            aSpec.SetPoint(1, 1);
            aSpec.SetSector(STOCK_FUT);
          end;
        end;
    end;
    // ?????? ???? ?????? ???? ????. 
    aSymbol.Spec  := aSpec;
  end   // if aSymbol = nil then
  else bNew := false;

  // ???? ?????? ???? ????.
  with aSymbol do
  begin
    // ????
    Name      := ''; //trim(aList[8]);
    // ???? ????
    EngName   := ''; //trim(aList[9]);
    // ???? ????
    ShortCode := stCode;
    // ??????
    Seq       := 0; //iCnt;

    // ?????? 
    LimitHigh := 0;//StrToFloat(trim(aList[15]));
    // ???? ??
    LimitLow  := 0; //StrToFloat(trim(aList[16]));
    // ???? ???? 
    Last      := 0; //StrToFloat(trim(aList[17]));
  end;


  with aSymbol as TDerivative do
  begin
    // ???? ???? ????
    Underlying := aUnder;
    // ??????, ??????, ???? ??????, ???? ????
    UnderCode  := stUnder;
    // ???????? ?????? 
    //DaysToExp := StrToInt( aList[12] );
    // ?????? 
    //ExpDate   := Date + DaysToExp - 1;
  end;

  // ?????? ????
  if aSymbol is TOption then
  with aSymbol as TOption do
  begin
    stStrike := Copy(stSymbolCode, 6, 3);

    gLog.Add( lkApplication, 'TKRXSymbolMySQLLoader','ImportMasterFromSymbolCode', Format('%s:%s', [ stSymbolCode, stStrike]) );

   
    
    // ??????
    StrikePrice := StrToFloat(stStrike);
    
    lastChar := Copy(stSymbolcode, 8, 1);
    // ???????? 2?? 7?? ?????? 0.5?? ???? ????.
    if (lastChar = '2') and (lastChar = '7') then
      StrikePrice := StrikePrice + 0.5;
    // ???? ????
    IsATM := false ; //trim( aList[14] ) = '1' ;

   
  end;

  if bNew then
  begin
    // ?????? ???????? ?????? ???? ???????? ?????? ????. 
    gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);
    // ???? ?????? ?????? ????.
    //gEnv.Engine.Api.PushRequest( Qry_LastHoga, aSymbol.Code  );
  end;

end;


{

  ?????? ???? ????

      //0  ????????         -> 03
      //1  ????????????     -> 01 ??????????
      //2  ??????????????
      //3  ????????????     -> 001 : call,   002 : put,    004 : Fut,    119 : spread
      //4  ??/?? ????       -> 0 : ????   2 : call   3 : put
      //5  ????????( ?????? )
      //6  ????????( ???? )
      //7  ????????( ???? )
      //8  ??????( ???? )
      //9  ??????( ???? )
      //10 ??????  ( 4)
      //11 ??????  ( 2)
      //12 ????????  (3)
      //13 ??????
      //14 ATM ????     1 :atm
      //15 ??????
      //16 ??????
}

procedure TKRXSymbolMySQLLoader.ImportMasterFromNHApi(aList: TStringList;
  iCnt: integer);
var
  //
  bNew, bOpt : boolean;
  stTmp, stcode, stName, stUnder, stFQN : string;
  iLen, i : integer;
  aUnder, aSymbol : TSymbol;
  cDiv : char;
  aSpec : TMarketSpec;
begin

  stTmp := '';
  for I := 0 to aList.Count - 1 do
    stTmp := stTmp + ' , ' + aList[i];

  stTmp := trim( aList[3] );
  if stTmp = '001' then
    cDiv := '2'
  else if  stTmp = '002' then
    cDiv := '3'
  else if stTmp = '004' then
    cDiv := '1'
  else Exit;

  // stTMp = '004' ???? aList[0] = '01' ---> ????????

  // ????
  case cDiv of
    '2','3' : bOpt := true;
  end;

  bNew := false;
  // ??????, ??????, ???? ??????, ???? ????
  stUnder := trim( aList[2] );

  // ???? ?????? ????????.
  aSpec   := GetMarketSpec( stUnder, bOpt );
  // ???? ???? ?????? ????????.
  aUnder  := GetUnderlying( stUnder );

  // ???? ?????? ?????? ???? ???? ?????? ???? ?????? 
  if (aUnder = nil) or ( aSpec = nil ) then
  begin
    // ????????
    if (stTmp = '004' ) and ( aList[0] = '01') then  begin
      cDiv := '4' ;

      if not gEnv.ConConfig.UseSFut then
        exit;
      // ???????? ?????????? ??????????.
      stUnder := trim( aList[1] ) + '_' + trim( aList[2] );
      aUnder := gEnv.Engine.SymbolCore.Stocks.Find( stUnder);
      if aUnder = nil then
      begin
        // stUnder ?? ?????????? ??????????...( ???????? ?????? ?????? ?????? ???????? )
        aUnder  := gEnv.Engine.SymbolCore.Stocks.New( stUnder );
        aUnder.Spec := gEnv.Engine.SymbolCore.Specs.Find( FQN_KRX_STOCK );;

        stName := trim(aList[8]);
        iLen := Length( stName );

        for I := iLen downto 1 do
          if stName[i] = 'F' then
            break;

        aUnder.Name := trim(Copy(stName, 1, i-1 ));
        if aUnder.Name = '' then
          aUnder.Name := stUnder;
        gEnv.Engine.SymbolCore.RegisterSymbol(aUnder);
      end;
    end
    else
      Exit;
  end;

  // ???? ?????? ????????.
  stCode  := trim(aList[5]);
  // ???? ?????? ?????? ???? ????. 
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
  {
  // 2017.03.27 ????????
  if aSpec <> nil then
  begin
    dUnit := StrToFloatDef( trim(string(pMaster.TradeUnit)), 1 );
    if dUnit > 0 then
      aSpec.SetPoint( dUnit, 1);
  end;
  }

  // ?????? ?????? ????
  if aSymbol = nil then
  begin
    bNew := true;
    case cDiv of
      '1' : aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
      '2' :
        begin
          aSymbol := gEnv.Engine.SymbolCore.Options.New(stCode);
          (aSymbol as TOption).CallPut := 'C';
          aSymbol.OptionType  := otCall;
        end ;
      '3' :
        begin
          aSymbol := gEnv.Engine.SymbolCore.Options.New(stCode);
          (aSymbol as TOption).CallPut := 'P';
          aSymbol.OptionType  := otPut;
        end ;
      '4' : // ????????
        begin
          aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
          stFQN   := stUnder+'.future.krx.kr';
          aSpec   := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
          aSymbol.IsStockF := true;
          if aSpec = nil then
          begin
            aSpec := gEnv.Engine.SymbolCore.Specs.New(stFQN);
            aSpec.RootCode := stUnder;
            aSpec.Description := aUnder.Name + ' Futures';
            {todo: }
            //aSpec.Sector := FieldByName('krx100section').AsString;
            aSpec.Currency := CURRENCY_WON;
            aSpec.SetTick(10, 1, 0);
            aSpec.SetPoint(1, 1);
            aSpec.SetSector(STOCK_FUT);
          end;
        end;
    end;
    // ?????? ???? ?????? ???? ????. 
    aSymbol.Spec  := aSpec;
  end   // if aSymbol = nil then
  else bNew := false;

  // ???? ?????? ???? ????.
  with aSymbol do
  begin
    // ????
    Name      := trim(aList[8]);
    // ???? ???? 
    EngName   := trim(aList[9]);
    // ???? ???? 
    ShortCode := stCode;
    // ?????? 
    Seq       := iCnt;

    // ?????? 
    LimitHigh := StrToFloat(trim(aList[15]));
    // ???? ?? 
    LimitLow  := StrToFloat(trim(aList[16]));
    // ???? ?????? 
    Last      := StrToFloat(trim(aList[17]));
  end;


  with aSymbol as TDerivative do
  begin
    // ???? ???? ????
    Underlying := aUnder;
    // ??????, ??????, ???? ??????, ???? ????
    UnderCode  := stUnder;
    // ???????? ?????? 
    DaysToExp := StrToInt( aList[12] );
    // ?????? 
    ExpDate   := Date + DaysToExp - 1;
  end;

  // ?????? ????
  if aSymbol is TOption then
  with aSymbol as TOption do
  begin
    // ??????
    StrikePrice := StrToFloat( trim( aList[13] ));
    // ???? ???? 
    IsATM := trim( aList[14] ) = '1' ;
  end;

  if bNew then
  begin
    // ?????? ???????? ?????? ???? ???????? ?????? ????. 
    gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);
    // ???? ?????? ?????? ????. 
    //gEnv.Engine.Api.PushRequest( Qry_LastHoga, aSymbol.Code  );
  end;

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromKrApi(stData: string);
var
//  vData : POutSymbolMaster;
  stTmp, stFullCode: string;
  aSymbol : TSymbol;
  dTIckValue, dContractSize, dTickSize : double;
  yy, mm, dd , i, iPre: word;
begin
  {
  if Length( stData ) < Len_OutSymbolMaster then Exit;

  try

    vData := POutSymbolMaster( stData );
    stFullCode  := trim(string(vData.FullCode));

    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stFullCode);
    if aSymbol <> nil then
    begin

      with aSymbol do
      begin
        Base  := StrToFloatDef( trim( string( vData.StdPrice)), 0 );
        PrevClose := StrToFloatDef( trim(string( vData.PDEndPrice ) ) ,0) ;
        Last    := PrevClose; // updated during the day

        LimitHigh := StrToFloatDef( trim( string( vData.HighLimitPrice)), 0 );
        LimitLow  := StrToFloatDef( trim( string( vData.LowLimitPrice)), 0 );
      end;

      with aSymbol as TDerivative do
      begin
        DaysToExp := StrToInt( string(vData.RemainDays) );
        CDRate    := StrToFloat( trim( string( vData.CDInterest )));
      end;

    end;

  except

  end;
  }
end;



end.


