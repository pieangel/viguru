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
    function GetMarketSpec(stUnder: string; bOpt : boolean): TMarketSpec;

  public
    constructor Create(aConnector: TMySQLConnector);
    destructor Destroy; override;

      // register fixed information
    procedure SetSpecs;
    procedure AddFixedSymbols;
    // pv4
    procedure ImportMasterFromFilepv4( stData : string; dtDate : TDateTime );
    procedure ImportMasterFromFileFOpv4( stData : string; dtDate : TDateTime );
    procedure ImportMasterFromFileCommodity( stData : string; dtDate : TDateTime );

    // api
    procedure ImportMasterFromKrApi( stData : string ); overload;
    procedure ImportSymbolListFromApi( iCount: integer; stData : string );



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

// rigister index symbols
//
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

    //  ???? ????
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

function TKRXSymbolMySQLLoader.GetUnderlying( stUnder : string ) : TSymbol;
var
  stCode : string;
begin
  stCode := '';

  if stUnder = K2I then
    stCode := KOSPI200_CODE
  else if stUnder = MKI then
    stCode := MINI_KOSPI200_CODE
  else if stUnder = BM3 then
    stCode := BOND3_CODE
  else if stUnder = BM5 then
    stCode := BOND5_CODE
  else if stUnder = BMA then
    stCode := BOND10_CODE
  else if stUnder = JPY then
    stCode  := YEN_CODE
  else if stUnder = USD then
    stCode :=  DOLLAR_CODE;

  Result := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode)
end;

function TKRXSymbolMySQLLoader.GetMarketSpec( stUnder : string; bOpt : boolean ) : TMarketSpec;
var
  stCode : string;
begin
  stCode := '';

  if bOpt then
  begin
    if stUnder = K2I then
      stCode := FQN_KOSPI200_OPTION
    else if stUnder = MKI then
      stCode := FQN_MINI_KOSPI200_OPTION
    else if stUnder = USD then
      stCode := FQN_DOLLAR_OPTION;
  end else
  begin
    if stUnder = K2I then
      stCode := FQN_KOSPI200_FUTURES
    else if stUnder = MKI then
      stCode := FQN_MINI_KOSPI200_FUTURES
    else if stUnder = BM3 then
      stCode := FQN_BOND3_FUTURES
    else if stUnder = BM5 then
      stCode := FQN_BOND5_FUTURES
    else if stUnder = BMA then
      stCode := FQN_BOND10_FUTURES
    else if stUnder = JPY then
      stCode := FQN_YEN_FUTURES
    else if stUnder = USD then
      stCode := FQN_DOLLAR_FUTURES;
  end;

  Result  := gEnv.Engine.SymbolCore.Specs.Find( stCode );
end;


procedure TKRXSymbolMySQLLoader.ImportSymbolListFromApi(iCount: integer;
  stData: string);
var
  pMaster : POutSymbolLIstInfo;
  stCode, stUnder, stShort, stSub, stTmp : string;
  aUnder, aSymbol : TSymbol;
  i, yy, mm, dd : integer;
  dUnit : double;
  bOpt, bNew : boolean;
  aSpec : TMarketSpec;

begin
  try
    for I := 0 to iCount - 1 do
    begin
      stSub := Copy( stData, i*Len_SymbolListInfo+1 , Len_SymbolListInfo );

      //gEnv.EnvLog( WIN_GI, Format('%d(%d):%s', [ i, iCount, stSub ]));
      pMaster := POutSymbolLIstInfo( stSub );

///////////////////////////////////////////////////////////////////////////////////
///
///
      case pMaster.MarketGb of
        '1' : bOpt := false;
        '2','3' : bOpt := true;
        else Continue;
      end;

      bNew := false;
      stUnder := trim( string(pMaster.AssetsID ));

      aSpec   := GetMarketSpec( stUnder, bOpt );
      aUnder  := GetUnderlying( stUnder );
      if (aUnder = nil) or ( aSpec = nil ) then Continue;

      stCode  := trim( string( pMaster.FullCode ));
      stShort := trim( string( pMaster.ShortCode ));

      // ???? ???????? ????..
      if stShort[1] = '7' then Continue;

      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);

      // 2017.03.27 ????????
      if aSpec <> nil then
      begin
        dUnit := StrToFloatDef( trim(string(pMaster.TradeUnit)), 1 );
        if dUnit > 0 then
          aSpec.SetPoint( dUnit, 1);
      end;

      if aSymbol = nil then
      begin
        bNew := true;
        case pMaster.MarketGb of
          '1' : aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
          '2' ,'3' :
            begin
              aSymbol := gEnv.Engine.SymbolCore.Options.New(stCode);
              case pMaster.MarketGb of
                '2' :
                  begin
                    (aSymbol as TOption).CallPut := 'C';
                    aSymbol.OptionType  := otCall;
                  end;
                '3' :
                  begin
                    (aSymbol as TOption).CallPut := 'P';
                    aSymbol.OptionType  := otPut;
                  end;
              end;
            end ;
        end;

        aSymbol.Spec  := aSpec;
      end   // if aSymbol = nil then
      else bNew := false;

      with aSymbol do
      begin
        Name      := trim( string( pMaster.JongName ));
        EngName   := trim( string( pMaster.JongEName ));
        ShortCode := trim( string( pMaster.ShortCode ));
        Seq       := StrToInt( trim( string( pMaster.Index )));
      end;

      with aSymbol as TDerivative do
      begin
        Underlying := aUnder;
        UnderCode  := stUnder;
        stTmp := trim( string( pMaster.LastDate ));
        yy := StrToINt( Copy( stTmp, 1, 4 ));
        mm := StrToINt( Copy( stTmp, 6, 2 ));
        dd := StrToINt( Copy( stTmp, 9, 2 ));
        ExpDate    :=  EnCodeDate( yy, mm, dd );
      end;

      if aSymbol is TOption then
      with aSymbol as TOption do
      begin
        IsATM :=  pMaster.ATM_Kind = 'Y';
        StrikePrice := StrToFloat( trim( string( pMaster.ExecPrice )));
      end;      

      if bNew then
        gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);

///////////////////////////////////////////////////////////////////////////////////
///
      gEnv.Engine.Api.RequestMaster(
        stUnder,
        stCode,
        trim(string(pMaster.Index))
        );
    end;
  except
  end;

  //gEnv.Engine.SymbolCore.OptionPrint;

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromFileCommodity(stData: string;
  dtDate: TDateTime);
begin


end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromFileFOpv4(stData: string;
  dtDate: TDateTime);

begin

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromFilepv4(stData: string;
  dtDate: TDateTime);
begin

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromKrApi(stData: string);
var
  vData : POutSymbolMaster;
  stTmp, stFullCode: string;
  aSymbol : TSymbol;
  dTIckValue, dContractSize, dTickSize : double;
  yy, mm, dd , i, iPre: word;
begin

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
end;



end.


