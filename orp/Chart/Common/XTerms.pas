unit XTerms;

interface

uses Classes, SysUtils, Math, DateUtils,
     //
     GleTypes,
     CleAccounts, CleOrders, CleFills,  GleConsts,  CleMarkets,
     CleSymbols, CleDistributor, CleStorage,
     Ticks, ChartData, ChartIF, CleMySQLConnector ;

type
  TXTermMode = (xmTick, xmTerm); // obsolete

  TXTermItem = class(TCollectionItem)
  public
    StartTime : TDateTime;
    LastTime : TDateTime;
    Count : Integer;
    MMIndex : Integer;
    O, H, L, C : Single;
    O2, H2, L2, C2 : Single;
    FillVol : Double;
    AccVol : Double;
    SideVol: Double;
    //
    Side : Integer; // (1:Long side, -1:Short side, 0:undefined) added on 2004.2.16.

    FutVol  : double;
    OptVol  : double;
    CallVol  : double;
    PutVol  : double;

    FutVol2  : double;
    OptVol2  : double;
    CallVol2  : double;
    PutVol2  : double;
    SAR : double;

    //
    LongFill : single;
    ShortFill: single;

    Fills : TList;

    Valid : Boolean;

    UVol, DVol : double;
    vMASpread, vSpread : double;
    AskCnt, BidCnt     : integer;

    procedure Assign(Source : TPersistent);override;
    //
    constructor Create(Collection : TCollection);override;
    destructor Destroy; override;

    procedure CalcAvgFill( iLS : integer );
  end;

  TXTerms = class(TCollection)
  protected
    // xterm definition
    FMode : TXTermMode; // obsolete
    FSymbol : TSymbol;
    FBase : TChartBase;
    FPeriod : Integer;
    FReqCount : Integer;
    // source data
    FChartData : TChartData;
    FTicks : TCollection;
    // status flags
    FReady : Boolean;
    FLastChangedOnUpdate : Boolean;
    // events
    FOnAdd : TNotifyEvent;
    FOnUpdate : TNotifyEvent;
    FOnRefresh : TNotifyEvent;

    // for fill records
    FAccount : TAccount;
    FLastData : TTickItem;
    FDataPast : integer;

    // data handlers
    procedure NewTick(aTick : TTickItem); // quote tick
    procedure NewFill(aFill : TFill;  aTerm : TXTermItem); // quote tick
    procedure AddTick(aTick : TTickItem); // tick chart data
    procedure AddTerm(aTerm : TTermItem); overload;// term chart data
    procedure AddTerm(aTerm : TSTermItem);overload;
    procedure Remake;
    // event handlers
    procedure TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure ReadyProc(Sender : TObject);
    procedure FillProc(Sender : TObject);
    // get/set
    function GetXTerm(i : Integer) : TXTermItem;
    procedure SetAccount(aAccount : TAccount);
    function SetPastTermData: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetPersistence(aBitStream : TMemoryStream);
    procedure GetPersistence(aBitStream : TMemoryStream);
    // define
    procedure Undefine;
    procedure Define(aSymbol : TSymbol; aBase : TChartBase;
                        iPeriod, iCount : Integer; bRefresh : boolean = false);
    //
    procedure GetMinMax(iStart, iEnd : Integer; var dMin, dMax : Double);
    procedure GetMinMax2(iStart, iEnd : Integer; var dMin, dMax : Double);
    function DateTimeDesc(iIndex : Integer) : String;
    //

    function FindTerm(dtTime: TDateTime; cbBase : TChartBase):TXTermItem;

    procedure LoadEnv(aStorage: TStorage; bMain : boolean = true);
    procedure SaveEnv(aStorage: TStorage; bMain : boolean = true);

    procedure AddFill(aFill : TFill);
    procedure Refill;
    // attributes
    property Symbol : TSymbol read FSymbol write FSymbol;
    // property Mode : TXTermMode read FMode;  // obsolete
    property Base : TChartBase read FBase write FBase;
    property Period : Integer read FPeriod write FPeriod;
    //
    property Account : TAccount read FAccount write SetAccount;
    // events
    property OnAdd : TNotifyEvent read FOnAdd write FOnAdd;
    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnRefresh : TNotifyEvent read FOnRefresh write FOnRefresh;
    //
    property Ready : Boolean read FReady;
    property LastChangedOnUpdate : Boolean read FLastChangedOnUpdate; // added by CHJ on 2003.3.26
    property XTerms[i:Integer] : TXTermItem read GetXTerm; default;
    property DataPast : integer read FDataPast write FDataPast;
  end;

implementation

uses GAppEnv, GleLib, ClePositions,
CleQuoteBroker, CleQuoteTimers;



//=================================================================//
                           { TXTermItem }
//=================================================================//

function FindXTermItem(aXTerms : TXTerms ; aXTermItem : TXTermItem ;
     cbBase : TChartBase):TXTermItem;
var
  i : Integer;
  wHour, wMin, wSec, wMSec : Word;
  wXHour, wXMin, wXSec, wXMSec : Word;
begin
  Result := nil;

  for i := aXTerms.Count-1 downto 0 do
    case cbBase of
      cbTick, cbQuote :
        begin
          DecodeTime(aXTermItem.StartTime, wHour, wMin, wSec, wMSec);
          DecodeTime(aXTerms[i].StartTime, wXHour, wXMin , wXSec, wXMSec);

          if (wHour = wXHour) and (wMin = wXHour) and (wSec = wXSec) then
          begin
            Result := aXTerms[i];
            break;
          end;

          if aXTerms[i].StartTime < aXTermItem.StartTime then break;

        end;
      cbMin :
        begin

          if (Floor(aXTerms[i].StartTime) = Floor(aXTermItem.StartTime)) and
            (Floor(aXTerms[i].MMIndex) = Floor(aXTermItem.MMIndex)) then
          begin
            Result := aXTerms[i];
            break;
          end;

          if aXTerms[i].StartTime < aXTermItem.StartTime then break;
        end;
      cbDaily, cbWeekly, cbMonthly :
        begin
          if Floor(aXTerms[i].StartTime) = Floor(aXTermItem.StartTime) then
          begin
            Result := aXTerms[i];
            break;
          end;
        end;
    end;
end;

procedure TXTermItem.CalcAvgFill(iLS: integer);
var
  j : integer;
  aFill : TFill;
  iLCount, lVol, iSCount, sVol : integer;
  lAvgPrc, sAvgPrc : Double;
begin

  iLCount := 0; iSCount := 0;
  lVol  := 0; sVol  := 0;
  sAvgPrc := 0; lAvgPrc := 0;

  if Fills = nil then Exit;

  for j:=0 to Fills.Count-1 do
  begin
    aFill := TFill(Fills.Items[j]);

    if aFill.Volume > 0 then
    begin
      Inc(iLCount);
      inc( lVol, aFill.Volume );
      lAvgPrc := ( lAvgPrc * (lVol -  aFill.Volume ) +
            aFill.Price * aFill.Volume ) / lVol;
    end else
    if aFill.Volume < 0 then
    begin
      Inc(iSCount);
      inc( sVol, abs(aFill.Volume) );
      sAvgPrc := ( sAvgPrc * (sVol - abs( aFill.Volume ))  +
          aFill.Price * abs(aFill.Volume)) / sVol;
    end;
  end;

  LongFill  := lAvgPrc;
  ShortFill := sAvgPrc;

end;

constructor TXTermItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  Valid := True;
end;

procedure TXTermItem.Assign(Source: TPersistent);
var
  aSource : TXTermItem;
begin
  if Source = nil then Exit;

  if Source is TXTermItem then
  begin
    aSource := Source as TXTermItem;

    StartTime := aSource.StartTime;
    LastTime := aSource.LastTime;
    Count := aSource.Count;
    MMIndex := aSource.MMIndex;
    O := aSource.O;
    H := aSource.H;
    L := aSource.L;
    C := aSource.C;
    FillVol := aSource.FillVol;
    AccVol := aSource.AccVol;

    ShortFill := aSource.ShortFill;
    LongFill  := aSource.LongFill;
  end;
end;



destructor TXTermItem.Destroy;
begin
  if Fills = nil then
    Fills.Free;

  inherited;
end;

//=================================================================//
                           { TXTerms }
//=================================================================//

//---------------------------------------------------------//
//                    Create / Destroy                     //
//---------------------------------------------------------//

constructor TXTerms.Create;
begin
  inherited Create(TXTermItem);

  FSymbol := nil;
  // FMode := xmTerm; // obsolete
  FBase := cbMin;
  FPeriod := 1;

  //FReady := True;
  FReady := False;
  FTicks := TCollection.Create(TTickItem);
  FLastData := nil;
  FDataPast := 0;
end;

destructor TXTerms.Destroy;
begin

  gEnv.Engine.QuoteBroker.Cancel( self );

  if FChartData <> nil then
    FChartData.Derefer;
  FTicks.Free;
  inherited;
end;

procedure TXTerms.Undefine;
begin
  //-- unsubscribe quote
  if FSymbol <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel( Self, FSymbol );
    FSymbol := nil;
  end;
  //-- release chart data
  if FChartData <> nil then
    FChartData.Derefer;
  FChartData := nil;

  //-- clear data
  FTicks.Clear; // clear tick saves
  Clear;        // clear xterms
  //
  FReady := False;
end;

// change workging mode
procedure TXTerms.Define(aSymbol : TSymbol; aBase : TChartBase;
                        iPeriod, iCount : Integer;  bRefresh : boolean);
var
  aQuote : TQuote;
  i: Integer;
  aTick : TTickItem;
begin
  if aSymbol = nil then Exit;

  //-- Is it the same definition?


  if not bRefresh then
  begin
    if (FSymbol = aSymbol) and
      (FBase = aBase) and
      (FPeriod = iPeriod) and
      (Count = iCount) then Exit;
  end;


  //-- if symbol is differenct
    // cancel the old subscription
  if (FSymbol <> nil) and (FSymbol <> aSymbol) then
      gEnv.Engine.QuoteBroker.Cancel( Self, FSymbol );

  aQuote := nil;
    // subscribe the new symbol
  if FSymbol <> aSymbol then
  begin
    aQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, aSymbol, TickProc, spNormal );
    FSymbol := aSymbol;
  end;


  //-- clear data
  FTicks.Clear; // clear tick saves

  Clear;        // clear xterms

  FReady := False;

  if FSymbol <> nil then
    if Assigned(FOnRefresh) then
      FOnRefresh(Self);


  //-- set new environment
  FSymbol := aSymbol;
  FBase := aBase;
  FPeriod := iPeriod;
  FReqCount := iCount;

  //-- release chart data
  if FChartData <> nil then
    FChartData.Derefer;

  //-- get new chart data
  FChartData := gEnv.Engine.SymbolCore.GetChartData(FSymbol, FBase, FPeriod, FReqCount, ReadyProc);
end;

//---------------------------------------------------------//
//                    Persistence                          //
//---------------------------------------------------------//

procedure TXTerms.SetPersistence(aBitStream : TMemoryStream);
{
var
  szBuf : array[0..20] of Char;
  stSymbol : String;
  stUnder, stReplaceCode : String;
  aNearestOptionMonth : TOptionMonthlyItem;
  aStrike: TStrikePriceItem;
 }
begin
{
  aBitStream.Read(szBuf, 20);
  stSymbol := szBuf;
  stUnder := Copy(stSymbol, 2, 2);
  FSymbol := gPrice.SymbolStore.FindSymbol(stSymbol);

  aBitStream.Read(FMode, SizeOf(TXTermMode)); // obsolete
  aBitStream.Read(FBase, SizeOf(TChartBase));
  aBitStream.Read(FPeriod, SizeOf(FPeriod));
  aBitStream.Read(FReqCount, SizeOf(FReqCount));

  if (FSymbol = nil) and (Length(stSymbol) > 0) and (stUnder = '01') then
    case stSymbol[1] of
      '1' :
        FSymbol := gPrice.SymbolStore.NearestFuture[utKospi200];
      '2','3' :
        begin
          aNearestOptionMonth :=
            TOptionMonthlyItem(gPrice.SymbolStore.Months[utKospi200, dtOptions, 0]);
          aStrike := nil;
          if aNearestOptionMonth <> nil then
            aStrike := aNearestOptionMonth.StrikePrices[0];

          if aStrike <> nil then
          begin
            stReplaceCode := Copy(stSymbol, 1, 3) + Copy(aStrike.Symbols[otCall].Code, 4 , 2);
            //attach strike price
            stReplaceCode := stReplaceCode + Copy(stSymbol, 6, Length(stSymbol)-5);
            //re-find symbol
            FSymbol := gPrice.SymbolStore.FindSymbol(stReplaceCode);
          end;
        end;
    end;


  if FSymbol <> nil then
  begin
    FSymbol.Subscribe(PID_TICK, [btNew], Self, TickProc);

    FChartData := gPrice.GetChartData(FSymbol, FBase, FPeriod, FReqCount, ReadyProc);

    // clear data
    FTicks.Clear; // clear tick saves
    Clear;        // clear xterms

    //FReady := False;
    // ?????????? ???????????? ?????? ??????????.
    FReady:= True;
  end;
  }
end;

function TXTerms.SetPastTermData: boolean;
var
  aConnector : TMySQLConnector;
  stQry, stTime, stNowTime : string;
  iCnt, iGap : integer;
  aXTerm : TXTermItem;
  wHH, wMM, wSS, wCC : Word;
  dtNowTime : TDateTime;
begin
  Result := false;
  Exit;

  aConnector := TMySQLConnector.Create;
  aConnector.Server := gEnv.ConConfig.Q_DbIP;
  aConnector.DB := gEnv.ConConfig.Q_DbSource;
  aConnector.User := gEnv.ConConfig.Q_DbID;
  aConnector.Password := gEnv.ConConfig.Q_DbPass;
  aConnector.SetConString( true );
  try
    aConnector.Connect;
    if not aConnector.Connected then Exit;
  except
    gEnv.DoLog(WIN_TEST,'Database connection failed');
    Exit;
  end;

  try
    // retrieve symbol information from database
    aConnector.DataSet.Close;
    aConnector.DataSet.SQL.Clear;

    if FDataPast = -1 then
    begin
      stQry := Format('Select Top %d * from tb_OneMin where code=:dtMaster order by Time desc',[FReqCount]);
      aConnector.DataSet.SQL.Add(stQry);
      aConnector.DataSet.Parameters.ParamValues['dtMaster']  :=  FSymbol.Code;
    end else
    begin
      stTime := FormatDateTime('yyyy-mm-dd',GetQuoteDate -  FDataPast);
      dtNowTime :=  IncDay(GetQuoteDate);
      stNowTime := FormatDateTime('yyyy-mm-dd', dtNowTime);


      stQry := 'Select * from tb_OneMin where code=:dtMaster and Time >= :dtTime and Time <= :dtNowTime order by Time desc';
      aConnector.DataSet.SQL.Add(stQry);
      aConnector.DataSet.Parameters.ParamValues['dtMaster']  :=  FSymbol.Code;
      aConnector.DataSet.Parameters.ParamValues['dtTime']  := stTime;
      aConnector.DataSet.Parameters.ParamValues['dtNowTime']  := stNowTime;
    end;

    try
      aConnector.DataSet.Open;
      if aConnector.DataSet.RecordCount = 0 then Exit;
    except
      gEnv.DoLog(WIN_TEST, 'Error while retrieving stock and ELW information from database');
      Exit;
    end;

    iCnt := 0;
      // load the information to the engine
    while not aConnector.DataSet.Recordset.EOF do
    with aConnector.DataSet do
    begin
      inc(iCnt);
      if iCnt > Count then
      begin
        aXTerm :=  self.Insert(0) as TXTermItem;
        aXTerm.StartTime := FieldByName('Time').AsDateTime;
        aXTerm.LastTime := FieldByName('Time').AsDateTime;
        stTime := FormatDateTime('yyyy-mm-dd hh:nn:ss',aXTerm.StartTime);
        DecodeTime(aXTerm.StartTime, wHH, wMM, wSS, wCC);
        aXTerm.MMIndex := (wHH - 9)*60 + wMM;
        aXTerm.Count := 1;
        aXTerm.O := FieldByName('Open').AsFloat;
        aXTerm.H := FieldByName('High').AsFloat;
        aXTerm.L := FieldByName('Low').AsFloat;
        aXTerm.C := FieldByName('Cur').AsFloat;
        aXTerm.FillVol := FieldByName('Volume').AsFloat;
      end;
      Next;
    end;
  finally
    aConnector.Disconnect;
  end;

end;

procedure TXTerms.GetPersistence(aBitStream : TMemoryStream);
var
  szBuf : array[0..20] of Char;
begin
  if FSymbol <> nil then
    StrPCopy(szBuf, FSymbol.Code)
  else
    StrPCopy(szBuf, #0);
  aBitStream.Write(szBuf, 20);

  aBitStream.Write(FMode, SizeOf(TXTermMode)); // obsolete
  aBitStream.Write(FBase, SizeOf(TChartBase));
  aBitStream.Write(FPeriod, SizeOf(FPeriod));
  aBitStream.Write(FReqCount, SizeOf(FReqCount));
end;

//---------------------------------------------------------//
//                    Data Arrived                         //
//---------------------------------------------------------//

// New tick data
procedure TXTerms.TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aTick : TTickItem;
  aQuote : TQuote;
  iCnt   : integer;
begin
  if (FSymbol <> nil) and ( DataObj <> nil )
  then
    aQuote := DataObj as TQuote;


    try

      if FBase = cbQuote then begin
        if FReady then
          NewTick( aTick );
      end
      else begin

        if aQuote.LastEvent <> qtTimeNSale then Exit;

        iCnt := aQuote.FTicks.Count;
        if iCnt <= 0 then Exit;
        aTick := TTickITem( aQuote.FTicks.Items[ iCnt-1 ] );

        if aTick = FLastData then
          Exit;

        if FReady then
          NewTick( aTick ) // last tick
        else
        begin
          aTick := DataObj as TTickItem;

          with FTicks.Add as TTickitem do
          begin
            T := aTick.T;
            C := aTick.C;
            FillVol := aTick.FillVol;
            AccVol := aTick.AccVol;
          end;
        end;
      end;

    finally
      FLastData := aTick;
    end;
end;

// chart data received
procedure TXTerms.ReadyProc(Sender : TObject);
begin
  Remake;
end;

//---------------------------------------------------------//
//                    Data Manipulation                    //
//---------------------------------------------------------//

//
// Merge quote data with chart data
//
procedure TXTerms.Remake;
var
  iStart, i, iGap : Integer;
  aQuote : TQuote;
begin
  if FSymbol = nil then Exit;
  Clear;
  //-- make data with save tick data
  aQuote  := FSymbol.Quote as TQuote;
  iStart := 0;

  case gEnv.RunMode of
    rtSimulUdp,
    rtRealTrading :
      begin
        if aQuote <> nil then
        begin
          {
          iStart := aQuote.FTicks.Count - FReqCount;
          if iStart < 0 then
            iStart := 0;
          for i := iStart to aQuote.FTicks.Count - 1 do
            NewTick(aQuote.FTicks.Items[i] as TTickItem) ;
          }

          //for i := iStart to aQuote.FTicks.Count - 1 do
          //  NewTick(aQuote.FTicks.Items[i] as TTickItem) ;

          for I := 0 to aQuote.Terms.Count - 1 do
            AddTerm( aQuote.Terms.Items[i] as TSTermItem );


          if FBase = cbMin then
          begin
            if FDataPast = -1 then
            begin
              iGap := FReqCount - Count;
              if iGap > 0 then SetPastTermData;
            end else
              SetPastTermData;
          end;
        end;
      end;
    else
      if aQuote <> nil then
        for i := 0 to aQuote.FTicks.Count - 1 do
          NewTick(aQuote.FTicks.Items[i] as TTickItem) ;
  end;


  FTicks.Clear;
  //-- get fill data
  Refill;
  //
  FReady := True;
  //
  if Assigned(FOnRefresh) then
    FOnRefresh(Self);
end;


//
//  New Tick
//
procedure TXTerms.NewFill(aFill: TFill; aTerm : TXTermItem);
begin

  if aTerm.Fills = nil then
    aTerm.Fills := TList.Create;
  aTerm.Fills.Add(aFill);
 {
  if FReady and Assigned(FOnUpdate) then
    FOnUpdate(Self);
    }
end;

procedure TXTerms.NewTick(aTick : TTickItem);
var
  aXTerm : TXTermItem;
  aQuote : TQuote;
  iMMIndex, iNextMMIndex : Integer;
  wYY1, wOO1, wDD1, wYY2, wOO2, wDD2,
  wHH, wMM, wSS, wCC : Word;
  aTime : TDateTime;
  iDayOfWeek : Integer;
  bNew : Boolean;
  dsGap, dlGap : double;
  stLog : string;
begin
  //-- get last item
  if Count = 0 then
  begin
    aXTerm := nil;
    aQuote := nil;
  end
  else
    aXTerm := Items[Count-1] as TXTermItem;


  //-- get MMIndex
  if FBase <> cbQuote then
  begin
    DecodeTime(aTick.T, wHH, wMM, wSS, wCC);
    iMMIndex := (wHH - 9)*60 + wMM;
    aTime:= Frac(aTick.T) + GetQuoteDate ; // combined with date
  end;

  aQuote  := FSymbol.Quote as TQuote;
  if aQuote = nil then Exit;
  //-- check new
  if aXTerm = nil then
    bNew := True
  else
  case FBase of
    cbTick : bNew := (aXTerm.Count >= FPeriod);
    cbMin : bNew := (Floor(aXTerm.LastTime) <> Floor(aTime)) or // date changed
                    (iMMIndex div FPeriod > aXTerm.MMIndex div FPeriod); // over a period
    cbDaily : bNew := (Floor(aXTerm.LastTime) <> Floor(aTime)) and // new day
                      (aXTerm.Count >= FPeriod);
    cbWeekly : begin
                 iDayOfWeek := DayOfWeek(aXTerm.LastTime);
                 bNew := (Floor(aXTerm.LastTime)+(7-iDayOfWeek) < Floor(aTime)) and // new week
                         (aXTerm.Count >= FPeriod);
               end;
    cbMonthly :begin
                 DecodeDate(aTime, wYY1, wOO1, wDD1);
                 DecodeDate(aXTerm.LastTime, wYY2, wOO2, wDD2);
                 bNew := ((wYY1 <> wYY2) or (wOO1 <> wOO2)) and // new month
                         (aXTerm.Count >= FPeriod);
               end;
    cbQuote : begin
                bNew  := false;


                with aQuote do
                begin
                  dSGap := abs( PrevAsks[0].Price - Asks[0].Price );
                  dLGap := abs( PrevBids[0].Price - Bids[0].Price );

                if ((dSGap > PRICE_EPSILON) or ( dLGap > PRICE_EPSILON)) then
                begin
                  bNew := true;
                  {
                  stLog := Format('s : %.2f( %.2f, %.2f)  , l : %.2f(%.2f, %.2f)',
                     [  dSGap,  PrevAsks[0].Price , Asks[0].Price,
                        dLGap,  PrevBids[0].Price , Bids[0].Price  ]
                     );
                  gEnv.EnvLog( WIN_SIS, stLog );
                  }
                end;
                end;
              end;
    else
      Exit;
  end;


  if FBase = cbQuote then
  begin
      if bNew then
      begin
        aXTerm := Add as TXTermItem;
        if aQuote = nil then
          aQuote  := FSymbol.Quote as TQuote;
        if aQuote = nil then Exit;

        aXTerm.StartTime := aQuote.LastQuoteTime;

        DecodeTime(aXTerm.StartTime, wHH, wMM, wSS, wCC);
        iMMIndex := (wHH - 9)*60 + wMM;
        aTime:= aXTerm.StartTime;

        aXTerm.MMIndex := iMMIndex;
        aXTerm.LastTime := aTime;

        aXTerm.Count := 1;
        aXTerm.O := aQuote.Asks[0].Price;
        aXTerm.H := aQuote.Asks[0].Price;
        aXTerm.L := aQuote.Bids[0].Price;
        aXTerm.C := aQuote.Asks[0].Price;

        aXTerm.O2 := aQuote.Bids[0].Price;
        aXTerm.H2 := aQuote.Bids[0].Price;
        aXTerm.L2 := aQuote.Bids[0].Price;
        aXTerm.C2 := aQuote.Bids[0].Price;

        if aQuote.LastEvent = qtTimeNSale then
        begin
          aXTerm.FillVol := aQuote.Sales.Last.Volume ;
          if aQuote.Sales.Last.Side = 1 then
          begin
            aXTerm.Side := 1;
            aXTerm.UVol  := aQuote.Sales.Last.Volume;
          end
          else if  aQuote.Sales.Last.Side = -1  then
          begin
            aXTerm.Side := -1;
            aXTerm.DVol  := aQuote.Sales.Last.Volume;
          end
          else
            aXTerm.Side := 0;
        end
        else begin
          aXTerm.FillVol := 0;
          aXTerm.UVol := 0;
          aXTerm.DVol := 0;
        end;

        if aQuote.Sales <> nil then
          if aQuote.Sales.Last <> nil then
            aXTerm.AccVol := aQuote.Sales.Last.DayVolume;

        aXTerm.Side := -1;

        aXTerm.FutVol := gEnv.Engine.SyncFuture.DerIndicator[2];
        aXTerm.OptVol := gEnv.Engine.SyncFuture.DerIndicator[0] + gEnv.Engine.SyncFuture.DerIndicator[1];
        aXTerm.CallVol := gEnv.Engine.SyncFuture.DerIndicator[0];
        aXTerm.PutVol := gEnv.Engine.SyncFuture.DerIndicator[1];

        gEnv.Engine.SyncFuture.DerIndicator2[2] := 0;
        gEnv.Engine.SyncFuture.DerIndicator2[1] := 0;
        gEnv.Engine.SyncFuture.DerIndicator2[0] := 0;
        gEnv.Engine.SyncFuture.DerIndicator2[1] := 0;

        aXTerm.FutVol2 := 0;
        aXTerm.OptVol2 := 0;
        aXTerm.CallVol2 :=0;
        aXTerm.PutVol2 := 0;

        aXTerm.SAR:= aQuote.SAR;

        if FReady and Assigned(FOnAdd) then
          FOnAdd(Self);
      end else
      begin
        if aQuote.LastEvent = qtTimeNSale then
        begin
          aXTerm.FillVol := aXTerm.FillVol + aQuote.Sales.Last.Volume;
          if aQuote.Sales.Last.Side > 0 then
            aXTerm.UVol := aXTerm.UVol + aQuote.Sales.Last.Volume
          else
            aXTerm.DVol := aXTerm.DVol + aQuote.Sales.Last.Volume;
        end;

        aXTerm.FutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[2];
        aXTerm.OptVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0] + gEnv.Engine.SyncFuture.DerIndicator2[1];
        aXTerm.CallVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0];
        aXTerm.PutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[1];

        aXTerm.SAR:= aQuote.SAR;

        if FReady and Assigned(FOnUpdate) then
          FOnUpdate(Self);
      end;
  end
  else begin

      // add up
      if bNew then
      begin
        aXTerm := Add as TXTermItem;
        //
        aXTerm.StartTime := aTime;
        if FBase = cbMin then // MMIndex needs to be accurate for Min chart
        begin
          aXTerm.MMIndex := (iMMIndex div FPeriod) * FPeriod;
          iNextMMIndex := aXTerm.MMIndex + FPeriod;
          aXTerm.LastTime := Floor(aTime) + EncodeTime(9 + iNextMMIndex div 60,
                                                       iNextMMIndex mod 60,
                                                       0, 0);
        end else
        begin
          aXTerm.MMIndex := iMMIndex;
          aXTerm.LastTime := aTime;
        end;
        aXTerm.Count := 1;
        aXTerm.O := aTick.C;
        aXTerm.H := aTick.C;
        aXTerm.L := aTick.C;
        aXTerm.C := aTick.C;
        aXTerm.FillVol := aTick.FillVol;
        aXTerm.AccVol := aTick.AccVol;

        if aTick.Side > 0 then
          aXTerm.UVol := aTick.FillVol
        else
          aXTerm.DVol := aTick.FillVol;

        //gEnv.Engine.SyncFuture.ReSetIndicator;

        aXTerm.FutVol := gEnv.Engine.SyncFuture.DerIndicator[2];
        aXTerm.OptVol := gEnv.Engine.SyncFuture.DerIndicator[0] + gEnv.Engine.SyncFuture.DerIndicator[1];
        aXTerm.CallVol := gEnv.Engine.SyncFuture.DerIndicator[0];
        aXTerm.PutVol := gEnv.Engine.SyncFuture.DerIndicator[1];

        gEnv.Engine.SyncFuture.DerIndicator2[2] := 0;
        gEnv.Engine.SyncFuture.DerIndicator2[1] := 0;
        gEnv.Engine.SyncFuture.DerIndicator2[0] := 0;
        gEnv.Engine.SyncFuture.DerIndicator2[1] := 0;

        aXTerm.FutVol2 := 0;
        aXTerm.OptVol2 := 0;
        aXTerm.CallVol2 :=0;
        aXTerm.PutVol2 := 0;

        aXTerm.SAR:= aQuote.SAR;

        aXTerm.vSpread  := gEnv.Engine.SymbolCore.ConsumerIndex.VIX.vSpread;
        aXTerm.vMASpread:= gEnv.Engine.SymbolCore.ConsumerIndex.VIX.vMASpread;

      {  if gEnv.Engine.SymbolCore.Future.Quote <> nil then begin
          aXTerm.AskCnt :=(gEnv.Engine.SymbolCore.Future.Quote as TQuote).Asks.CntTotal;
          aXTerm.BidCnt :=(gEnv.Engine.SymbolCore.Future.Quote as TQuote).Bids.CntTotal;
        end
        else begin
        }
          aXTerm.AskCnt := 0;
          aXTerm.BidCnt := 0;
       // end;

        aXTerm.SideVol:= aTick.FillVol * aTick.Side;
        //
        //-- added on 2004.2.16
        if (aTick is TFillTickItem) and (FBase = cbTick) and (FPeriod = 1) then
        begin
          case (aTick as TFillTickItem).PositionType of
            ptLong : aXTerm.Side := 1;
            ptShort : aXTerm.Side := -1;
            else
              aXTerm.Side := 0;
          end;
        end else
          aXTerm.Side := 0;
        //-- end of add

        if FReady and Assigned(FOnAdd) then
          FOnAdd(Self);

      end else
      begin
        if FBase = cbTick then
          aXTerm.Count := aXTerm.Count + 1;

        if FBase <> cbMin then
          aXTerm.LastTime := aTime;

        if FBase = cbDaily then
          if Floor(aXTerm.LastTime) = Floor(GetQuoteDate) then
            if aXTerm.FillVol = 0 then
            begin
              aXTerm.O := aTick.C;
              aXTerm.H := aTick.C;
              aXTerm.L := aTick.C;
    {$ifdef LogChart}
              gLog.Add(lkDebug ,'Invalid','','');
    {$endif}
            end;

        aXTerm.H := Max(aXTerm.H, aTick.C);
        aXTerm.L := Min(aXTerm.L, aTick.C);

        FLastChangedOnUpdate :=
            (Abs(aXTerm.C - aTick.C) > PRICE_EPSILON); // added by CHJ on 2003.3.26
        aXTerm.C := aTick.C;
        aXTerm.FillVol := aXTerm.FillVol + aTick.FillVol;
        aXTerm.AccVol := aTick.AccVol;
        if aTick.Side > 0 then begin
          aXTerm.SideVol := aXTerm.SideVol + aTick.FillVol;
          aXTerm.UVol := aXTerm.UVol + aTick.FillVol;
        end
        else begin
          aXTerm.SideVol := aXTerm.SideVol - aTick.FillVol;
          aXTerm.DVol    := aXTerm.DVol + aTick.FillVol;
        end;

        aXTerm.FutVol := gEnv.Engine.SyncFuture.DerIndicator[2];
        aXTerm.OptVol := gEnv.Engine.SyncFuture.DerIndicator[0] + gEnv.Engine.SyncFuture.DerIndicator[1];
        aXTerm.CallVol := gEnv.Engine.SyncFuture.DerIndicator[0];
        aXTerm.PutVol := gEnv.Engine.SyncFuture.DerIndicator[1];

        aXTerm.FutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[2];
        aXTerm.OptVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0] + gEnv.Engine.SyncFuture.DerIndicator2[1];
        aXTerm.CallVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0];
        aXTerm.PutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[1];

        aXTerm.SAR:= aQuote.SAR;

        aXTerm.vSpread  := gEnv.Engine.SymbolCore.ConsumerIndex.VIX.vSpread;
        aXTerm.vMASpread:= gEnv.Engine.SymbolCore.ConsumerIndex.VIX.vMASpread;

        aQuote  := gEnv.Engine.SymbolCore.Future.Quote as TQuote;
        if aQuote <> nil then begin
          aXTerm.AskCnt := aXTerm.AskCnt + (aQuote.Asks.CntTotal - aQuote.PrevAsks.CntTotal);
          aXTerm.BidCnt := aXTerm.BidCnt + (aQuote.Bids.CntTotal - aQuote.PrevBids.CntTotal);
        end;
        //
        if FReady and Assigned(FOnUpdate) then
          FOnUpdate(Self);
      end;
  end;
end;


//
// Tick chart data
//
procedure TXTerms.AddTerm( aTerm: TSTermItem);
var
  aXTerm : TXTermItem;
  aSTerm : TSTermItem;
begin
  //-- get the last one
  if Count = 0 then
    aXTerm := nil
  else
    aXTerm := Items[Count-1] as TXTermItem;
  //
  if (aXTerm = nil)
     or
     ((FBase = cbMin) and
      ((Floor(aXTerm.LastTime) < Floor(aTerm.LastTime)) or // date changed
       (aXTerm.MMIndex div FPeriod < aTerm.MMIndex div FPeriod)))
     or
     ((FBase in [cbDaily, cbWeekly, cbMonthly]) and
      (aXTerm.Count >= FPeriod)) then
  begin
    aXTerm := Add as TXTermItem;
    //
    aXTerm.StartTime := aTerm.StartTime;
    aXTerm.LastTime := aTerm.LastTime;
    aXTerm.MMIndex := aTerm.MMIndex;  // for min term
    aXTerm.Count := 1;
    aXTerm.O := aTerm.O;
    aXTerm.H := aTerm.H;
    aXTerm.L := aTerm.L;
    aXTerm.C := aTerm.C;
    aXTerm.FillVol := aTerm.FillVol;
    aXTerm.AccVol := aTerm.AccVol;
  end else
  begin
    aXTerm.LastTime := aTerm.LastTime;
    aXTerm.Count := aXTerm.Count + 1;
    aXTerm.H := Max(aXTerm.H, aTerm.H);
    aXTerm.L := Min(aXTerm.L, aTerm.L);
    aXTerm.C := aTerm.C;
    aXTerm.FillVol := aXTerm.FillVol + aTerm.FillVol;
    aXTerm.AccVol := aTerm.AccVol;
  end;

end;

procedure TXTerms.AddTick(aTick : TTickItem);
var
  aTime : TDateTime;
  aXTerm : TXTermItem;
begin
  //-- get the last one
  if Count = 0 then
    aXTerm := nil
  else
    aXTerm := Items[Count-1] as TXTermItem;
  //
  aTime := aTick.T + GetQuoteDate; // combined with date
  if (aXTerm = nil) or (aXTerm.Count >= FPeriod) then
  begin
    aXTerm := Add as TXTermItem;
    //
    aXTerm.StartTime := aTime;
    aXTerm.LastTime := aTime;
    aXTerm.Count := 1;
    aXTerm.O := aTick.C;
    aXTerm.H := aTick.C;
    aXTerm.L := aTick.C;
    aXTerm.C := aTick.C;
    aXTerm.FillVol := aTick.FillVol;
    aXTerm.AccVol := aTick.AccVol;
    aXTerm.SideVol:= aTick.Side * aTick.FillVol;

    aXTerm.FutVol := gEnv.Engine.SyncFuture.DerIndicator[2];
    aXTerm.OptVol := gEnv.Engine.SyncFuture.DerIndicator[0] + gEnv.Engine.SyncFuture.DerIndicator[1];
    aXTerm.CallVol := gEnv.Engine.SyncFuture.DerIndicator[0];
    aXTerm.PutVol := gEnv.Engine.SyncFuture.DerIndicator[1];

    aXTerm.FutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[2];
    aXTerm.OptVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0] + gEnv.Engine.SyncFuture.DerIndicator2[1];
    aXTerm.CallVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0];
    aXTerm.PutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[1];

  end else
  begin
    aXTerm.LastTime := aTime;
    aXTerm.Count := aXTerm.Count + 1;
    aXTerm.H := Max(aXTerm.H, aTime);
    aXTerm.L := Min(aXTerm.L, aTime);
    aXTerm.C := aTime;
    aXTerm.FillVol := aXTerm.FillVol + aTick.FillVol;
    aXTerm.AccVol := aTick.AccVol;
    if aTick.Side > 0 then
      aXTerm.SideVol  := aXTerm.SideVol + aTick.FillVol
    else
      aXTerm.SideVol  := aXTerm.SideVol - aTick.FillVol;

    aXTerm.FutVol := gEnv.Engine.SyncFuture.DerIndicator[2];
    aXTerm.OptVol := gEnv.Engine.SyncFuture.DerIndicator[0] + gEnv.Engine.SyncFuture.DerIndicator[1];
    aXTerm.CallVol := gEnv.Engine.SyncFuture.DerIndicator[0];
    aXTerm.PutVol := gEnv.Engine.SyncFuture.DerIndicator[1];

    aXTerm.FutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[2];
    aXTerm.OptVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0] + gEnv.Engine.SyncFuture.DerIndicator2[1];
    aXTerm.CallVol2 := gEnv.Engine.SyncFuture.DerIndicator2[0];
    aXTerm.PutVol2 := gEnv.Engine.SyncFuture.DerIndicator2[1];
  end;
end;

//
// Term chart data
//
procedure TXTerms.AddTerm(aTerm : TTermItem);
var
  aXTerm : TXTermItem;
begin
  //-- get the last one
  if Count = 0 then
    aXTerm := nil
  else
    aXTerm := Items[Count-1] as TXTermItem;
  //
  if (aXTerm = nil)
     or
     ((FBase = cbMin) and
      ((Floor(aXTerm.LastTime) < Floor(aTerm.T)) or // date changed
       (aXTerm.MMIndex div FPeriod < aTerm.MMIndex div FPeriod)))
     or
     ((FBase in [cbDaily, cbWeekly, cbMonthly]) and
      (aXTerm.Count >= FPeriod)) then
  begin
    aXTerm := Add as TXTermItem;
    //
    aXTerm.StartTime := aTerm.T;
    aXTerm.LastTime := aTerm.T;
    aXTerm.MMIndex := aTerm.MMIndex;  // for min term
    aXTerm.Count := 1;
    aXTerm.O := aTerm.O;
    aXTerm.H := aTerm.H;
    aXTerm.L := aTerm.L;
    aXTerm.C := aTerm.C;
    aXTerm.FillVol := aTerm.FillVol;
    aXTerm.AccVol := aTerm.AccVol;
  end else
  begin
    aXTerm.LastTime := aTerm.T;
    aXTerm.Count := aXTerm.Count + 1;
    aXTerm.H := Max(aXTerm.H, aTerm.H);
    aXTerm.L := Min(aXTerm.L, aTerm.L);
    aXTerm.C := aTerm.C;
    aXTerm.FillVol := aXTerm.FillVol + aTerm.FillVol;
    aXTerm.AccVol := aTerm.AccVol;
  end;
end;

//---------------------------------------------------------//
//                    Fill                                 //
//---------------------------------------------------------//

procedure TXTerms.FillProc(Sender : TObject);
begin
  if (Sender <> nil) and (Sender is TFill) then
    AddFill(Sender as TFill);
end;

procedure TXTerms.AddFill(aFill : TFill);
var
  i : Integer;
  aTime : TDateTime;
  stTmp : string;
begin
  aTime := aFill.FillTime + GetQuoteDate; // assume today
  for i:=Count-1 downto 0 do
  with Items[i] as TXTermItem do
  begin
    if aTime >= StartTime then
    begin
      NewFill( aFill, Items[i] as TXTermItem );

      Break;
    end;
  end;
end;

procedure TXTerms.Refill;
var
  i : Integer;
  aPos : TPosition;
begin
  // clear
  for i:=0 to Count-1 do
  with TXTermItem(Items[i]) do
  begin
    if Fills <> nil then
    begin
      Fills.Free;
      Fills := nil;
    end;
  end;
  //
  if (FSymbol = nil) or ( FAccount = nil) then Exit;
  //
  aPos := gEnv.Engine.TradeCore.Positions.Find(FAccount, FSymbol );
  if aPos = nil then Exit;

  for i := 0 to aPos.Fills.Count - 1 do
    FillProc( aPos.Fills.Items[i] );

end;

//---------------------------------------------------------//
//                    Misc                                 //
//---------------------------------------------------------//

procedure TXTerms.GetMinMax(iStart, iEnd : Integer; var dMin, dMax : Double);
var
  i : Integer;
  dMn, dMx : Double;
begin
  dMn := 0.0;
  dMx := 0.0;
  //
  for i:=iStart to iEnd do
  begin
    if i > Count-1 then break;

    with Items[i] as TXTermItem do
    begin
      if not Valid then Continue;
      if i > iStart then
      begin
        dMn := Min(dMn, L);
        dMx := Max(dMx, H);
      end else
      begin
        dMn := L;
        dMx := H;
      end;
    end;
  end;
  //
  dMin := dMn;
  dMax := dMx;
end;

procedure TXTerms.GetMinMax2(iStart, iEnd: Integer; var dMin, dMax: Double);
var
  i : Integer;
  dMn, dMx : Double;
begin
  dMn := 0.0;
  dMx := 0.0;
  //
  for i:=iStart to iEnd do
  begin
    if i > Count-1 then break;

    with Items[i] as TXTermItem do
    begin
      if not Valid then Continue;
      if i > iStart then
      begin
        dMn := Min(dMn, L2);
        dMx := Max(dMx, H2);
      end else
      begin
        dMn := L2;
        dMx := H2;
      end;
    end;
  end;
  //
  dMin := dMn;
  dMax := dMx;

end;

function TXTerms.DateTimeDesc(iIndex : Integer) : String;
var
  aItem : TXTermItem;
begin
  aItem := XTerms[iIndex];
  Result := '';

  if aItem <> nil then
  case FBase of
    cbTick, cbQuote    : Result := FormatDateTime('hh"??"nn"??"ss"??"', aItem.StartTime);
    cbMin     : Result := FormatDateTime('mm??dd??hh??nn??', aItem.StartTime);
    cbDaily,
    cbWeekly  : Result := FormatDateTime('mm"??"dd"??"', aItem.StartTime);
    cbMonthly : Result := FormatDateTime('yyyy"??"mm"??"', aItem.StartTime);
  end;
{ // 2004.1.12
  if aItem <> nil then
  case FBase of
    cbTick    : Result := FormatDateTime('hh"??"nn"??"ss"??"', aItem.LastTime);
    cbMin     : Result := FormatDateTime('hh"??"nn"??"', aItem.LastTime);
    cbDaily,
    cbWeekly  : Result := FormatDateTime('mm"??"dd"??"', aItem.LastTime);
    cbMonthly : Result := FormatDateTime('yyyy"??"mm"??"', aItem.LastTime);
  end;
}
end;

//---------------------------------------------------------//
//                    Property Methods                     //
//---------------------------------------------------------//

procedure TXTerms.SaveEnv(aStorage: TStorage; bMain : boolean);
begin
  if FSymbol <> nil then
    aStorage.FieldByName('TermsCode').AsString := FSymbol.Code ;

  aStorage.FieldByName('Mode').AsInteger := Integer( FMode );
  aStorage.FieldByName('Base').AsInteger := Integer( FBase );
  aStorage.FieldByName('Period').AsInteger := FPeriod;
  aStorage.FieldByName('ReqCount').AsInteger := FReqCount;

end;

procedure TXTerms.LoadEnv(aStorage: TStorage; bMain : boolean);
var
  stSymbol : String;
  stUnder, stReplaceCode : String;
  FOptionMarket : TOptionMarket;
  FFutureMarket : TFutureMarket;
  aStrike : TStrike;
  i : integer;
begin
  stSymbol := aStorage.FieldByName('TermsCode').AsString;
  stUnder := Copy(stSymbol, 2, 2);
  FSymbol  := gEnv.Engine.SymbolCore.Symbols.FindCode( stSymbol );

  FMode := TXTermMode( aStorage.FieldByName('Mode').AsInteger );
  FBase := TChartBase( aStorage.FieldByName('Base').AsInteger );
  FPeriod := aStorage.FieldByName('Period').AsInteger ;
  FReqCount := aStorage.FieldByName('ReqCount').AsInteger ;

  if ( FSymbol = nil ) and ( length( stSymbol) > 0) and ( stUnder = '01') then
    case stSymbol[1] of
      '1' :
        begin
          FFutureMarket  := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];
          FSymbol := FFutureMarket.FrontMonth;
        end;
      '2','3' :
        begin
          FOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
          aStrike := FOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
          if aStrike <> nil then
          begin
            stReplaceCode := Copy( stSymbol, 1, 3) + Copy( aStrike.Call.Code, 4, 2);
            stReplaceCode := stReplaceCode + Copy( stSymbol, 6, Length( stSymbol) - 5);
            FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stReplaceCode );
          end;
        end;
    end;

  if FSymbol <> nil then
  begin
    gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, TickProc, spNormal );
    FChartData :=
      genv.Engine.SymbolCore.GetChartData(FSymbol, FBase, FPeriod, FReqCount, ReadyProc);
 //   FTicks.Clear;
 //   Clear;
    FReady := true;

  end;
end;

procedure TXTerms.SetAccount(aAccount : TAccount);
begin
  if aAccount = FAccount then Exit;
  //
  FAccount := aAccount;
  Refill;
end;

function TXTerms.GetXTerm(i : Integer) : TXTermItem;
begin
  if (i>=0) and (i<Count) then
    Result := Items[i] as TXTermItem
  else
    Result := nil;
end;



function TXTerms.FindTerm(dtTime: TDateTime; cbBase: TChartBase): TXTermItem;
var
  i : Integer;
  wHour, wMin, wSec, wMSec : Word;
  wXHour, wXMin, wXSec, wXMSec : Word;
begin
  Result := nil;

  for i := Count-1 downto 0 do
    case cbBase of
      cbTick, cbQuote :
        begin
          DecodeTime(dtTime, wHour, wMin, wSec, wMSec);
          DecodeTime(XTerms[i].StartTime, wXHour, wXMin , wXSec, wXMSec);

          if (wHour = wXHour) and (wMin = wXHour) and (wSec = wXSec) then
          begin
            Result := XTerms[i];
            break;
          end;

          if XTerms[i].StartTime < dtTime then break;

        end;
      cbMin :
        begin

          if (Floor(XTerms[i].StartTime) = Floor(dtTime)) and
            (GetMMIndex(XTerms[i].StartTime) = GetMMIndex(dtTime)) then
          begin
            Result := XTerms[i];
            break;
          end;

          if XTerms[i].StartTime < dtTime then break;
        end;
      cbDaily :
        begin
          if (Floor(XTerms[i].StartTime) < Floor(dtTime)) and
            (Floor(dtTime) <= Floor(XTerms[i].LastTime)) then
          begin
            Result := XTerms[i];
            break;
          end;
        end;
      cbWeekly, cbMonthly :
        if Floor(XTerms[i].StartTime) = Floor(dtTime) then
          begin
            Result := XTerms[i];
            break;
          end;
        {
        if i = Count-1 then
        begin
          if Floor(XTerms[i].StartTime) = Floor(dtTime) then
          begin
            Result := XTerms[i];
            break;
          end;
        end else
        begin
          if (Floor(XTerms[i].StartTime) < Floor(dtTime)) and
            (Floor(dtTime) <= Floor(XTerms[i+1].StartTime)) then
          begin
            Result := XTerms[i];
            break;
          end;
        end;
        }
    end;

end;

end.

