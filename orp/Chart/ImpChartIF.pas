unit ImpChartIF;

interface

uses
  Classes, SysUtils, Windows,
  //
  AppTypes, SynthUtil, AppUtils,
  LogCentral, ChartData, TrendData, EtcSeries,
  ChartIF, TyTCP, SymbolStore, AppConsts;

type
  TChartReqItem = class(TCollectionItem)
  public
    Receiver : TObject;
    Symbol : TSymbolItem;
    ChartBase : TChartBase;
    Period : Integer;
    ReqCount : Integer;
    RecCount : Integer;
    // feed back data
    RemCount : Integer;
    Start : Integer;
  end;

  TEtcChartReqItem = class(TChartReqItem)
  public
    ChartType : Integer;
    Validated : Boolean;
  end;

  TTrendReqItem = class(TCollectionItem)
  public
    Receiver : TObject;
    UType : TUnderlyingType;
    InstKind : TTrendInst;
    QtyAmt : TQtyAmt;
    TrendCode : String;
    Done : Boolean;
    Notify : Boolean;
    // next status
    Status : LongInt;
  end;

  TImpChartIF = class(TChartIF)
  private
    FChartReqs : TCollection;
    FTrendReqs : TCollection;
    FEtcChartReqs : TCollection;

    // sending part : Trend
    procedure RequestTrend;
    procedure ReqFuturesTrend(aReq : TTrendReqItem);
    procedure ReqOptionsTrend(aReq : TTrendReqItem);
    // receiving part : Trend
    procedure TrendProc(Sender, Receiver: TObject;
      szPacket: PChar; iSize: Integer; aToken : TPacketTokenRec);
    procedure ProcessFuturesTrend(aReq : TTrendReqItem;
      szBuf : PChar; iSize : Integer);
    procedure ProcessOptionsTrend(aReq : TTrendReqItem;
      szBuf : PChar; iSize : Integer);

    // sending part : EtcChart
    procedure RequestEtcChart;
    procedure RequestEtcTerms(aReq : TEtcChartReqItem);

    // receiving part
    procedure EtcChartProc(Sender, Receiver : TObject; szPacket : PChar;
                    iSize : Integer; aToken : TPacketTokenRec);
    procedure ProcessEtcData(aReq : TEtcChartReqItem; szBuf : PChar; iSize : Integer);

    // sending part
    procedure RequestChart;
    procedure RequestStockMin(aReq : TChartReqItem);
    procedure RequestStockDaily(aReq : TChartReqItem);
    procedure RequestStockLongTerms(aReq : TChartReqItem);
    procedure RequestTick(aReq : TChartReqItem);
    procedure RequestTerm(aReq : TChartReqItem);

    // receiving part
    procedure ResultProc(Sender, Receiver : TObject;
                     szPacket : PChar; iSize : Integer; aToken : TPacketTokenRec);
    procedure ProcessTerm(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
    procedure ProcessTick(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
    procedure ProcessStockMin(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
    procedure ProcessStockDaily(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
    procedure ProcessStockLongTerm(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear; override;
    procedure Initialize; override;
    procedure Finalize; override;

    function Enabled(cbValue : TChartBase) : Boolean; override;
    function GetBase(cbValue : TChartBase; iPeriod : Integer) : Integer; override;

    procedure ReleaseChart(aObj : TObject);override;

    function GetChart(Receiver : TObject; aSymbol : TSymbolItem;
      cbValue : TChartBase; iPeriod : Integer; iCount : Integer;
      dtStart : TDateTime) : Boolean; override;
    function GetTrend(Receiver : TObject) : Boolean; override;
    function GetEtcChart(Receiver: TObject; aSymbol: TSymbolItem;
      cbValue: TChartBase; iPeriod, iCount, iChartType: Integer):Boolean;override;
  end;

implementation

const
  MIN_STEPS : array[0..7] of Integer = (1,3,5,10,12,15,30,60);

//=================================================================//
//               Query on Capabilities                             //
//=================================================================//

//
// Query on which kind of data is available in the Quote server(HTS server).
//
function TImpChartIF.Enabled(cbValue: TChartBase): Boolean;
begin
  case cbValue of
    cbTick    : Result := True;
    cbMin     : Result := True;
    cbDaily   : Result := True;
    cbWeekly  : Result := True;
    cbMonthly : Result := True;
    else
      Result := False;
  end;
end;

//
// Query on available term on data of a kind.
//
function TImpChartIF.GetBase(cbValue: TChartBase;
  iPeriod: Integer): Integer;
var
  i : Integer;
begin
  case cbValue of
    cbTick,
    cbDaily,
    cbWeekly,
    cbMonthly : Result := 1;
    cbMin :
      if iPeriod > 0 then
      begin
        for i:=High(MIN_STEPS) downto 0 do
          if iPeriod mod MIN_STEPS[i] = 0 then
          begin
            Result := MIN_STEPS[i];
            Break;
          end;
      end else
        Result := 1;
    else
      Result := 1;
  end;
end;

procedure TImpChartIF.ReleaseChart(aObj: TObject);
var
  i : Integer;
  aChartReq : TEtcChartReqItem;
begin
  for i := 0 to FEtcChartReqs.Count-1 do
  begin
    aChartReq := FEtcChartReqs.Items[i] as TEtcChartReqItem;
    if aChartReq.Receiver = aObj then
      aChartReq.Validated := False;
  end;
end;


//=================================================================//
//               Init / Final                                      //
//=================================================================//

constructor TImpChartIF.Create;
begin
  inherited;

  FChartReqs := TCollection.Create(TChartReqItem);
  FEtcChartReqs := TCollection.Create(TEtcChartReqItem);
  FTrendReqs := TCollection.Create(TTrendReqItem);
end;

destructor TImpChartIF.Destroy;
begin
  FChartReqs.Free;
  FEtcChartReqs.Free;
  FTrendReqs.Free;

  inherited;
end;


procedure TImpChartIF.Clear;
begin
  FChartReqs.Clear;
  FEtcChartReqs.Clear;
  FTrendReqs.Clear;
end;

procedure TImpChartIF.Initialize;
begin
  // HW START

  // gTyTCP.StartService(409002);
  // gTyTCP.StartService(409510);
  gTyTCP.StartService(413000);

  // gTyTCP.StartService(409004);
  gTyTCP.StartService(410001);       // 일봉

  // gTyTCP.StartService(409010);
  gTyTCP.StartService(411000);        // 주봉

  // gTyTCP.StartService(409011);
  gTyTCP.StartService(411100);        // 월봉

  // gTyTCP.StartService(409001);
  gTyTCP.StartService(411200);        // 틱

  // Etc Chart Data
  gTyTCP.StartService(413006);        // 분
  gTyTCP.StartService(410008);        // 월
  //gTyTCP.StartService(411206);

  // HW END

  gTyTCP.StartService(210400);
  gTyTCP.StartService(210001);
  gTyTCP.StartService(210201);
  gTyTCP.StartService(210301);
  gTyTCP.StartService(610812);
  gTyTCP.StartService(610822);
end;

procedure TImpChartIF.Finalize;
begin

  // HW START

  // gTyTCP.EndService(409002);
  // gTyTCP.EndService(409510);
  gTyTCP.EndService(413000);

  // gTyTCP.EndService(409004);
  gTyTCP.EndService(410001);       // 일봉

  // gTyTCP.EndService(409010);
  gTyTCP.EndService(411000);        // 주봉

  // gTyTCP.EndService(409011);
  gTyTCP.EndService(411100);        // 월봉

  // gTyTCP.EndService(409001);
  gTyTCP.EndService(411200);        // 틱

  //Etc Chart Data
  gTyTCP.EndService(413006);        // 분
  gTyTCP.EndService(410008);        // 일
  //gTyTcp.EndService(411206);        //etc


  // HW END


  gTyTCP.EndService(210400);
  gTyTCP.EndService(210001);
  gTyTCP.EndService(210201);
  gTyTCP.EndService(210301);
  gTyTCP.EndService(610812);
  gTyTCP.EndService(610822);
end;

//=================================================================//
//               Sending Part : TrendData                                     //
//=================================================================//

function TImpChartIF.GetTrend(Receiver: TObject): Boolean;
  procedure AddReq(aUType : TUnderlyingType; aKind : TTrendInst;
    stCode : String; aQtyAmt : TQtyAmt; bNotify : Boolean = False);
  var
    aReq : TTrendReqItem;
  begin
    aReq := FTrendReqs.Add as TTrendReqItem;
    aReq.Receiver := Receiver;
    aReq.UType := aUType;
    aReq.InstKind := aKind;
    aReq.QtyAmt := aQtyAmt;
    aReq.TrendCode := stCode;
    aReq.Notify := bNotify;

    aReq.Done := False;

    aReq.Status := 0;
  end;
var
  iOldCount : Integer;
begin
  //--1. Redundant check
  if Receiver = nil then Exit;

  //--2. Add to Request List
  iOldCount := FTrendReqs.Count;
  // kospi200 futures
  AddReq(utKospi200, tkFutures, TrendSumCodes[ts8000], tdQty);
  AddReq(utKospi200, tkFutures, TrendSumCodes[ts8000], tdAmt);
  AddReq(utKospi200, tkFutures, TrendSumCodes[ts9000], tdQty);
  AddReq(utKospi200, tkFutures, TrendSumCodes[ts9000], tdAmt);
  AddReq(utKospi200, tkFutures, TrendSumCodes[ts9999], tdQty);
  AddReq(utKospi200, tkFutures, TrendSumCodes[ts9999], tdAmt);

  // kospi200 options
  AddReq(utKospi200, tkCall, TrendSumCodes[ts8000], tdQty);
  AddReq(utKospi200, tkCall, TrendSumCodes[ts8000], tdAmt);
  AddReq(utKospi200, tkCall, TrendSumCodes[ts9000], tdQty);
  AddReq(utKospi200, tkCall, TrendSumCodes[ts9000], tdAmt);
  AddReq(utKospi200, tkCall, TrendSumCodes[ts9999], tdQty);
  AddReq(utKospi200, tkCall, TrendSumCodes[ts9999], tdAmt);
  AddReq(utKospi200, tkPut, TrendSumCodes[ts8000], tdQty);
  AddReq(utKospi200, tkPut, TrendSumCodes[ts8000], tdAmt);
  AddReq(utKospi200, tkPut, TrendSumCodes[ts9000], tdQty);
  AddReq(utKospi200, tkPut, TrendSumCodes[ts9000], tdAmt);
  AddReq(utKospi200, tkPut, TrendSumCodes[ts9999], tdQty);
  AddReq(utKospi200, tkPut, TrendSumCodes[ts9999], tdAmt, True);

  // stock options
  {
  AddReq(utStock, tkCall, TrendSumCodes[ts8000], tdQty);
  AddReq(utStock, tkCall, TrendSumCodes[ts8000], tdAmt);
  AddReq(utStock, tkCall, TrendSumCodes[ts9000], tdQty);
  AddReq(utStock, tkCall, TrendSumCodes[ts9000], tdAmt);
  AddReq(utStock, tkCall, TrendSumCodes[ts9999], tdQty);
  AddReq(utStock, tkCall, TrendSumCodes[ts9999], tdAmt);
  AddReq(utStock, tkPut, TrendSumCodes[ts8000], tdQty);
  AddReq(utStock, tkPut, TrendSumCodes[ts8000], tdAmt);
  AddReq(utStock, tkPut, TrendSumCodes[ts9000], tdQty);
  AddReq(utStock, tkPut, TrendSumCodes[ts9000], tdAmt);
  AddReq(utStock, tkPut, TrendSumCodes[ts9999], tdQty);
  AddReq(utStock, tkPut, TrendSumCodes[ts9999], tdAmt, True);
  }
  //--3. Trigger request
  if iOldCount = 0 then
    RequestTrend;
end;

procedure TImpChartIF.RequestTrend;
var
  aReq : TTrendReqItem;
begin
  if FTrendReqs.Count = 0 then Exit;

  //--1. get request item
  aReq := FTrendReqs.Items[0] as TTrendReqItem;

  if aReq.Done then
  begin
    if aReq.Notify then
     (aReq.Receiver as TTrendData).AccReady;

    aReq.Free;
    // next one
    RequestTrend;
    Exit;
  end;

  //--2. request
  case aReq.InstKind of
    tkFutures :      ReqFuturesTrend(aReq);
    tkCall, tkPut :  ReqOptionsTrend(aReq);
  end;
end;

const
  QA_CODES : array[TQtyAmt] of Char = (#0, #1);
  CP_CODES : array[TTrendInst] of Char = (#0, #1, #2);

procedure TImpChartIF.ReqFuturesTrend(aReq : TTrendReqItem);
var
  iP : Integer;
  szBuf : array[0..100] of Char;
  iSubFunc : SmallInt;
begin
  if aReq = nil then Exit;

  //-- make packet and send to the server
  iP := 0;

  if aReq.Status = 0 then
    iSubFunc := 0
  else
    iSubFunc := 1;

  if //-- header
    ConvertLong(szBuf, iP, 0      ) and  // size : set later
    ConvertLong(szBuf, iP, 610810 ) and  // service id
    ConvertLong(szBuf, iP, 0      ) and  // window id : not used
    ConvertLong(szBuf, iP, 610812 ) and  // DSO id
    ConvertWord(szBuf, iP, iSubFunc  ) and  // sub func : not used
    //-- data
    ConvertString(szBuf, iP, aReq.TrendCode) and
    ConvertBytes(szBuf, iP, QA_CODES[aReq.QtyAmt]) and
    //-- status
    ConvertLong(szBuf, iP, aReq.Status)
  then
    gTyTCP.SendPacket(Self, TrendProc, szBuf, iP)
  else
    gLog.Add(lkError, 'ChartIF', 'Request K200 Futures Trend', 'Packet making failure');
end;

procedure TImpChartIF.ReqOptionsTrend(aReq : TTrendReqItem);
var
  iP : Integer;
  szBuf : array[0..100] of Char;
  iSubFunc : SmallInt;
begin
  if aReq = nil then Exit;

  //-- make packet and send to the server
  iP := 0;

  if aReq.Status = 0 then
    iSubFunc := 0
  else
    iSubFunc := 1;

  if aReq.UType = utKospi200 then
  begin
    if //-- header
      ConvertLong(szBuf, iP, 0      ) and  // size : set later
      ConvertLong(szBuf, iP, 610840 ) and  // service id
      ConvertLong(szBuf, iP, 0      ) and  // window id : not used
      ConvertLong(szBuf, iP, 610822 ) and  // DSO id
      ConvertWord(szBuf, iP, iSubFunc  ) and  // sub func : not used
       //-- data
       ConvertBytes(szBuf, iP, CP_CODES[aReq.InstKind]) and
       ConvertString(szBuf, iP, aReq.TrendCode) and
       ConvertBytes(szBuf, iP, QA_CODES[aReq.QtyAmt]) and
       //-- status
       ConvertLong(szBuf, iP, aReq.Status)
    then
      gTyTCP.SendPacket(Self, TrendProc, szBuf, iP)
    else
      gLog.Add(lkError, 'ChartIF', 'Request K200 Options Trend', 'Packet making failure');
  end else
  if aReq.UType = utStock then
  begin
    if //-- header
      ConvertLong(szBuf, iP, 0      ) and  // size : set later
      ConvertLong(szBuf, iP, 8080 ) and  // service id
      ConvertLong(szBuf, iP, 0      ) and  // window id : not used
      ConvertLong(szBuf, iP, 808001 ) and  // DSO id
      ConvertWord(szBuf, iP, iSubFunc  ) and  // sub func : not used
       //-- data
       ConvertBytes(szBuf, iP, CP_CODES[aReq.InstKind]) and // call/put
       ConvertString(szBuf, iP, '') and                     // target underlying
       ConvertString(szBuf, iP, aReq.TrendCode) and         // code
       ConvertBytes(szBuf, iP, QA_CODES[aReq.QtyAmt]) and   // qty/amt
       //-- status
       ConvertLong(szBuf, iP, aReq.Status)
    then
      gTyTCP.SendPacket(Self, TrendProc, szBuf, iP)
    else
      gLog.Add(lkError, 'ChartIF', 'Request Stock Options Trend', 'Packet making failure');
  end;
end;

//=================================================================//
//               Receving Part : Trend                             //
//=================================================================//

procedure TImpChartIF.TrendProc(Sender, Receiver: TObject;
  szPacket: PChar; iSize: Integer; aToken : TPacketTokenRec);
var
  i, iP, iService, iDSO, iError, iHLen : Integer;
  bSuccess : Boolean;
  stData : String;
  aReq : TTrendReqItem;
begin
  //--1. Check
  if Receiver <> Self then
  begin
    gLog.Add(lkDebug, 'Chart IF Implementation', 'Rx Packet',
      'Delivery mismatched');
    Exit;
  end;

  //--2. Decode Packet Header
  if not gTyTCP.DecodeHeader(szPacket, iSize, bSuccess,
     iService, iDSO, iError, stData, iHLen) then
    Exit;

  //--3. looking for sending packet
  if FTrendReqs.Count = 0 then
  begin
    gLog.Add(lkDebug, 'Chart IF Implementation', 'Rx Packet',
                      'Packt rx/tx has mismatched');
    Exit;
  end;
  aReq := FTrendReqs.Items[0] as TTrendReqItem;

  //--4. Process packet
  if not bSuccess then
  begin
    if Pos(MSG_REQUEST_TIMEOUT, stData) > 0 then  // if time-out, silent
    begin
      gLog.Add(lkDebug, 'Chart IF Implementation', '투자자동향자료 수신',
               Format('%s/rem:%d',[stData, FTrendReqs.Count]) );
    end else // if other error, show error
    begin
      gLog.Add(lkWarning, 'Chart IF Implementation', '투자자동향자료 수신',
               Format('%s/rem:%d',[stData, FTrendReqs.Count]) );
      aReq.Free; // give up getting this packet
    end;

    RequestTrend;
  end else
  begin
    if iDSO = 610812 then
      ProcessFuturesTrend(aReq, szPacket+iHLen, iSize - iHLen)
    else
    if (iDSO = 610822) or (iDSO = 808001) then
      ProcessOptionsTrend(aReq, szPacket+iHLen, iSize - iHLen);

    // notify proceeding
    (aReq.Receiver as TTrendData).NotifyStateMessage(
         Format('[%s/%s/%s/%s] %d',
             [UnderlyingTypeDescs[aReq.UType],
              TrendInstDescs[aReq.InstKind],
              TrendSumDescs[GetTrendSumCode(aReq.TrendCode)],
              QtyAmtDescs[aReq.QtyAmt],
              aReq.Status]));
  end;

  // next turn
  RequestTrend;
end;

procedure TImpChartIF.ProcessFuturesTrend(aReq : TTrendReqItem;
  szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  stValue : String;

  aTrendData : TTrendData;
  wRecCnt : SmallInt;

  iHH, iMM, iSS : Integer;

  aRec : TTrendRec;

  szCopy : array[0..10000] of Char;
begin
  CopyMemory(szCopy + 0, szBuf, iSize);

  aTrendData := aReq.Receiver as TTrendData;

  iP := 0;
  // data record count
  DeconvertWord(szBuf, iP, wRecCnt);   // data count
  // data
  for i:=0 to wRecCnt-1 do
  begin
    aRec.TrendCode :=  aReq.TrendCode;
    aRec.UType := aReq.UType;
    aRec.TrendInst := aReq.InstKind;
    aRec.QtyAmt := aReq.QtyAmt;

    DeconvertString(szBuf, iP, stValue);
    iHH := StrToInt(Copy(stValue,1,2));
    iMM := StrToInt(Copy(stValue,4,2));
    iSS := StrToInt(Copy(stValue,7,2));
    aRec.DataTime := EncodeTime(iHH, iMM, iSS, 0);
    aRec.TimeCode := iHH * 10000 + iMM * 100 + iSS;
    iP := iP + 8;
    DeconvertLong(szBuf, iP, aRec.Data[ttLong]);
    iP := iP + 8;
    DeconvertLong(szBuf, iP, aRec.Data[ttShort]);
    DeconvertString(szBuf, iP, stValue);
    DeconvertString(szBuf, iP, stValue);
    DeconvertString(szBuf, iP, stValue);
    iP := iP + 4;
    //
    aTrendData.InsertAcc(aRec);
{$ifdef DEBUG}
  gLog.Add(lkPacket, 'Acc Trend', '',
      Format('%d:%d-%d', [aRec.TimeCode, aRec.Data[ttLong], aRec.Data[ttShort]]));
{$endif}
  end;
  DeconvertBytes(szBuf, iP, stValue, 1);
  DeconvertLong(szBuf, iP, aReq.Status);
  aReq.Done := (aReq.Status = 0);
end;

procedure TImpChartIF.ProcessOptionsTrend(aReq : TTrendReqItem;
  szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  stValue : String;
  dValue : Double;

  aTrendData : TTrendData;
  wRecCnt : SmallInt;

  iHH, iMM, iSS : Integer;

  aRec : TTrendRec;
begin
  aTrendData := aReq.Receiver as TTrendData;

  iP := 0;
  // data record count
  DeconvertWord(szBuf, iP, wRecCnt);   // data count
  // data
  for i:=0 to wRecCnt-1 do
  begin
    aRec.TrendCode :=  aReq.TrendCode;
    aRec.UType := aReq.UType;
    aRec.TrendInst := aReq.InstKind;
    aRec.QtyAmt := aReq.QtyAmt;

    DeconvertString(szBuf, iP, stValue); // 시간
    iHH := StrToInt(Copy(stValue,1,2));
    iMM := StrToInt(Copy(stValue,4,2));
    iSS := StrToInt(Copy(stValue,7,2));
    aRec.DataTime := EncodeTime(iHH, iMM, iSS, 0);
    aRec.TimeCode := iHH * 10000 + iMM * 100 + iSS;
    DeconvertLong(szBuf, iP, aRec.Data[ttLong]); // 신규매수
    DeconvertLong(szBuf, iP, aRec.Data[ttShort]); // 신규매도
    DeconvertString(szBuf, iP, stValue);
    DeconvertString(szBuf, iP, stValue);
    iP := iP + 8;
    DeconvertString(szBuf, iP, stValue);
    DeconvertString(szBuf, iP, stValue);
    iP := iP + 4;
    //
    aTrendData.InsertAcc(aRec);
  end;
  DeconvertBytes(szBuf, iP, stValue, 1);
  DeconvertLong(szBuf, iP, aReq.Status);
  aReq.Done := (aReq.Status = 0);
end;

//=================================================================//
//               Sending Part : Etc Chart                        //
//=================================================================//
function TImpChartIF.GetEtcChart(Receiver: TObject; aSymbol: TSymbolItem;
  cbValue: TChartBase; iPeriod, iCount, iChartType: Integer): Boolean;
var
  aReq : TEtcChartReqItem;
begin
  if (Receiver = nil) or (aSymbol = nil) then Exit;

  aReq := FEtcChartReqs.Add as TEtcChartReqItem;
  aReq.Receiver := Receiver;
  aReq.Symbol := aSymbol;
  aReq.ChartBase := cbValue;
  aReq.Period := iPeriod;
  aReq.ReqCount := iCount;
  aReq.RecCount := 0;
  aReq.Validated := True;

  aReq.RemCount := iCount;
  aReq.Start := -1;
  aReq.ChartType := iChartType;

  if FEtcChartReqs.Count = 1 then
    RequestEtcChart;
end;

procedure TImpChartIF.RequestEtcChart;
var
  aReq : TEtcChartReqItem;
begin
  if FEtcChartReqs.Count = 0 then Exit;

  aReq := FEtcChartReqs.Items[0] as TEtcChartReqItem;

  if (aReq.RemCount = 0) or not(aReq.Validated) then
  begin
    if aReq.Validated then
      (aReq.Receiver as TEtcSeries).NotifyReady;

    aReq.Free;

    RequestEtcChart;
    Exit;
  end;

  RequestEtcTerms(aReq);

end;


procedure TImpChartIF.RequestEtcTerms(aReq: TEtcChartReqItem);
var
  iP, iChartType : Integer;
  iServiceID, iDsoID, iTerm : Integer;
  szBuf : array[0..100] of Char;
  cKind, cTimeKind : Char;
  stOption4 : String;
begin
  if (aReq = nil) or (aReq.Symbol = nil) then Exit;

  if aReq.Symbol.UnderlyingType = utKospi200 then
  case aReq.Symbol.SymbolType of
    stIndex :  cKind := #2;
    stFuture : cKind := #3;
    stOption : cKind := #4;
    else
  end else
  if aReq.Symbol.UnderlyingType = utStock then
  case aReq.Symbol.SymbolType of
    stOption : cKind := #5;
    else
  end else
  begin
    gLog.Add(lkWarning, 'TyChart I/F Impjavalementation', 'Request TyData',
      'Cannot provide chart data for ''' + aReq.Symbol.Desc + '''');
  end;

  iTerm := 0;
  iChartType := aReq.ChartType;
  cTimeKind := #0;

  case aReq.ChartBase of
    cbMin, cbTick :
      begin
        iTerm := aReq.Period;
        iDsoID := 413006;
        iServiceID := 4130;
        cTimeKind := #3;
      end;
    cbDaily, cbWeekly, cbMonthly :
      begin
        iDsoID := 410008;
        iServiceID := 4100;
        cTimeKind := #0;
      end;
  end;

  iP := 0;
  SetLength(stOption4, 8);

  if gTyTcp.MakePacket(szBuf, iP, iServiceID, iDsoID) and

      ConvertLong(szBuf, iP, iChartType) and
      ConvertBytes(szBuf, iP, cKind) and
      ConvertString(szBuf, iP, aReq.Symbol.Code) and
      ConvertBytes(szBuf, iP, cTimeKind) and                 //Time unit
      ConvertLong(szBuf, iP, iTerm) and               //min unit

      ConvertLong(szBuf, iP, aReq.Start) and          //start day
      ConvertLong(szBuf, iP, 0) and                   //last day
      ConvertLong(szBuf, iP, aReq.Start) and          //first time
      ConvertLong(szBuf, iP, 0) and                   //last time

      ConvertLong(szBuf, iP , 0) and                  //option1
      ConvertLong(szBuf, iP , 0) and                  //option2
      ConvertLong(szBuf, iP,  0) and                  //option3
      ConvertString(szBuf, iP , stOption4) and        //option4
      ConvertLong(szBuf, iP , aReq.RemCount) then     //remain count
  begin
    gTyTCP.SendPacket(Self, EtcChartProc, szBuf, iP)
  end else
    gLog.Add(lkError, 'ChartIF', 'Request Chart', 'Packet making failure');

end;


//=================================================================//
//               Receving Part : Etc Chart                         //
//=================================================================//
procedure TImpChartIF.EtcChartProc(Sender, Receiver: TObject;
  szPacket: PChar; iSize: Integer; aToken : TPacketTokenRec);
var
  i, iP, iService, iDSO, iError, iHLen : Integer;
  bSuccess : Boolean;
  stData : String;
  aReq : TEtcChartReqItem;
begin

  if Receiver <> Self then
  begin
    gLog.Add(lkDebug, 'TyChart IF Implementation', 'Rx Packet',
      'Delivery mismatched');
    Exit;
  end;

  //--2. Decode Packet Header
  if not gTyTCP.DecodeHeader(szPacket, iSize, bSuccess,
     iService, iDSO, iError, stData, iHLen) then
    Exit;

  //--3. looking for sending packet
  if FEtcChartReqs.Count = 0 then
  begin
    gLog.Add(lkDebug, 'TyChart IF Implementation', 'Rx Packet',
                      'Packt rx/tx has mismatched');
    Exit;
  end;
  aReq := FEtcChartReqs.Items[0] as TEtcChartReqItem;

  //--4. Process packet
  if not bSuccess then
  begin
    gLog.Add(lkError, 'Etc Chart IF Implementation', '챠트자료 수신',
             Format('%s/rem:%d',[stData, FEtcChartReqs.Count]) );
    // still notify
    (aReq.Receiver as TEtcSeries).NotifyReady;
    //(aReq.Receiver as TEtcSeries).NotifyReady;
    //
    aReq.Free;
  end else
    ProcessEtcData(aReq, szPacket+iHLen, iSize-iHLen);

  // next turn
  RequestEtcChart;
end;



procedure TImpChartIF.ProcessEtcData(aReq: TEtcChartReqItem; szBuf: PChar;
  iSize: Integer);
var
  i, iP : Integer;
  lValue : LongInt;
  wRecCnt : SmallInt;

  iTime, iYY, iMM, iDD : LongInt;
  dtValue : TDateTime;
  dOpen, dHigh, dLow, dClose : Double;
  dFillVol, dAccVol : Double;

  aEtcSeries : TEtcSeries;
  iDivider : Integer;
begin
  if not(aReq.Validated) then Exit;


  aEtcSeries := aReq.Receiver as TEtcSeries;

  iP := 0;

  DeconvertLong(szBuf, iP, aReq.RemCount);
  iP := iP + 12;
  DeconvertLong(szBuf, iP ,aReq.Start);
  iP := iP + 4;

  if aReq.ChartBase = cbDaily then
    iP := iP + 4
  else
    DeconvertLong(szBuf, iP, aReq.Start);

  iP := iP + 4;

  DeconvertWord(szBuf, iP, wRecCnt);

  try
    for i := 0 to wRecCnt-1 do
    begin
      DeconvertLong(szBuf, iP, iTime);

      if aReq.ChartBase in [cbDaily, cbWeekly, cbMonthly] then
      begin
        iYY := iTime div 10000;
        iTime := (iTime - iYY * 10000);
        iMM := iTime div 100;
        iDD := iTime mod 100;
        dtValue := EncodeDate(iYY, iMM, iDD);
      end else
      begin
        dtValue := (iTime div 86400) + DAY_OFFSET +
              (iTime mod 86400) / 86400.0 + HOUR_OFFSET;
      end;

      DeconvertLong(szBuf, iP, lValue);

      iDivider := 1;
      case aReq.ChartType of
        10 : iDivider := 100;
      end;

      aEtcSeries.InsertTerm(dtValue, lValue/iDivider);

    end;
  except

  end;
end;

//=================================================================//
//               Sending Part : Price Chart                        //
//=================================================================//

function TImpChartIF.GetChart(Receiver: TObject; aSymbol: TSymbolItem;
  cbValue: TChartBase; iPeriod, iCount: Integer;
  dtStart: TDateTime): Boolean;
var
  aReq : TChartReqItem;
  i : Integer;
begin
  //--1. Redundant check
  if (Receiver = nil) or (aSymbol = nil) or (iCount = 0) then Exit;

  //--2. Add to Request List
  aReq := FChartReqs.Add as TChartReqItem;
  aReq.Receiver := Receiver;
  aReq.Symbol := aSymbol;
  aReq.ChartBase := cbValue;
  aReq.Period := iPeriod;
  aReq.ReqCount := iCount;
  aReq.RecCount := 0;

  aReq.RemCount := iCount;
  aReq.Start := -1;
  // start date & start time
  // if get response then change ReqCount, and start date/time

  //--3. Trigger request
  if FChartReqs.Count = 1 then
    RequestChart;
end;

procedure TImpChartIF.RequestChart;
var
  aReq : TChartReqItem;
begin
  if FChartReqs.Count = 0 then Exit;

  //--1. get request item
  aReq := FChartReqs.Items[0] as TChartReqItem;

  // char data
  aReq.RemCount := 0;

  if aReq.RemCount = 0 then
  begin
    (aReq.Receiver as TChartData).NotifyReady;
    aReq.Free;
    // next one
    RequestChart;
    Exit;
  end;

  //--2. set symbol type
  if aReq.Symbol.SymbolType = stStock then
  case aReq.ChartBase of
    cbMin :     RequestStockMin(aReq);
    cbDaily :   RequestStockDaily(aReq);
    cbWeekly,
    cbMonthly : RequestStockLongTerms(aReq);
  end else
  if aReq.ChartBase = cbTick then
    RequestTick(aReq)
  else
    RequestTerm(aReq);
end;

procedure TImpChartIF.RequestStockMin(aReq : TChartReqItem);
var
  iP : Integer;
  szBuf : array[0..100] of Char;
begin
  if aReq = nil then Exit;

  //-- make packet and send to the server
  iP := 0;
  if //-- header
     gTyTCP.MakePacket(szBuf, iP, 1000, 210400) and
     //-- data
     ConvertBytes(szBuf, iP, #0) and // symbol kind
     ConvertString(szBuf, iP, aReq.Symbol.Code) and // symbol
     ConvertLong (szBuf, iP,  0) and // not used
     ConvertLong (szBuf, iP,  0) and // not used
     ConvertLong (szBuf, iP, aReq.Start) and // Start Time : from the most recent
     ConvertLong (szBuf, iP,  0) and // End Time : 0 = ignored
     ConvertLong (szBuf, iP, aReq.Period) and // term
     ConvertLong (szBuf, iP,  0) and // not used
     ConvertWord (szBuf, iP, aReq.RemCount)
  then
    gTyTCP.SendPacket(Self, ResultProc, szBuf, iP)
  else
    gLog.Add(lkError, 'ChartIF', 'Request Chart', 'Packet making failure');
end;

procedure TImpChartIF.RequestStockDaily(aReq : TChartReqItem);
var
  iP : Integer;
  szBuf : array[0..100] of Char;
begin
  if aReq = nil then Exit;

  //-- make packet and send to the server
  iP := 0;
  if //-- header
     gTyTCP.MakePacket(szBuf, iP, 4444, 210001) and
     //-- data
     ConvertBytes(szBuf, iP, #0) and // symbol kind
     ConvertString(szBuf, iP, aReq.Symbol.Code) and // symbol
     ConvertLong (szBuf, iP, aReq.Start) and // Start Date : from the most recent
     ConvertLong (szBuf, iP,  0) and // End Date : 0 = ignored
     ConvertLong (szBuf, iP,  0) and // trading history : 0 - no
     ConvertString(szBuf, iP, '' ) and
     ConvertWord (szBuf, iP, aReq.RemCount)
  then
    gTyTCP.SendPacket(Self, ResultProc, szBuf, iP)
  else
    gLog.Add(lkError, 'ChartIF', 'Request Chart', 'Packet making failure');
end;

procedure TImpChartIF.RequestStockLongTerms(aReq : TChartReqItem);
var
  iP : Integer;
  iService, iDso : Integer;
  szBuf : array[0..100] of Char;
begin
  if aReq = nil then Exit;

  if aReq.ChartBase = cbWeekly then
  begin
    iService := 3333;
    iDso := 210201;
  end else
  begin
    iService := 2222;
    iDso := 210301;
  end;

  //-- make packet and send to the server
  iP := 0;
  if //-- header
     gTyTCP.MakePacket(szBuf, iP, iService, iDso) and
     //-- data
     ConvertBytes(szBuf, iP, #0) and // symbol kind
     ConvertString(szBuf, iP, aReq.Symbol.Code) and // symbol
     ConvertLong (szBuf, iP, aReq.Start) and // Start Date : from the most recent
     ConvertLong (szBuf, iP,  0) and // End Date : 0 = ignored
     ConvertWord (szBuf, iP, aReq.RemCount)
  then
    gTyTCP.SendPacket(Self, ResultProc, szBuf, iP)
  else
    gLog.Add(lkError, 'ChartIF', 'Request Chart', 'Packet making failure');
end;

procedure TImpChartIF.RequestTick(aReq : TChartReqItem);
var
  iP : Integer;
  szBuf : array[0..100] of Char;
  cKind : Char;
begin
  if aReq = nil then Exit;

  if aReq.Symbol.UnderlyingType = utKospi200 then
  case aReq.Symbol.SymbolType of
    stFuture : cKind := #3;
    stOption : cKind := #4;
    else
  end else
  if aReq.Symbol.UnderlyingType = utStock then
  case aReq.Symbol.SymbolType of
    stOption : cKind := #5;
    else
  end else
  begin
    gLog.Add(lkWarning, 'Chart I/F Implementation', 'Request Chart',
      'Cannot provide chart data for ''' + aReq.Symbol.Desc + '''');
  end;

  //-- make packet and send to the server
  iP := 0;
  if //-- header
     gTyTCP.MakePacket(szBuf, iP, 4110, 411200) and
     //-- data

     ConvertLong (szBuf, iP, 0) and // not used - 분석챠트종류
     ConvertBytes(szBuf, iP, cKind) and // symbol type - 종목구분
     ConvertString(szBuf, iP, aReq.Symbol.Code) and   // symbol - 종목코드
     ConvertBytes(szBuf, iP, #0) and  // not used - 시간단위

     ConvertLong (szBuf, iP, 0 ) and // term   - 분단위
     
     ConvertLong (szBuf, iP, aReq.Start) and // Start Date : from the most recent - 시작일
     ConvertLong (szBuf, iP,  0) and // End Date : 0 = ignored - 마지막일
     ConvertLong (szBuf, iP, aReq.Start) and // Start Time : from the most recent - 시작시간
     ConvertLong (szBuf, iP,  0) and // End Time : 0 = ignored - 마지막시간
     //
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션1
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션2
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션3
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션4
     ConvertLong (szBuf, iP, aReq.RemCount)


  then
    gTyTCP.SendPacket(Self, ResultProc, szBuf, iP)
  else
    gLog.Add(lkError, 'ChartIF', 'Request Chart', 'Packet making failure');
end;

procedure TImpChartIF.RequestTerm(aReq : TChartReqItem);
var
  iP : Integer;
  iServiceID, iDsoID, iTerm : Integer;
  szBuf : array[0..100] of Char;
  cKind : Char;
begin
  if aReq = nil then Exit;

  if aReq.Symbol.UnderlyingType = utKospi200 then
  case aReq.Symbol.SymbolType of
    stIndex :  cKind := #2;
    stFuture : cKind := #3;
    stOption : cKind := #4;
    else
  end else
  if aReq.Symbol.UnderlyingType = utStock then
  case aReq.Symbol.SymbolType of
    stOption : cKind := #5;
    else
  end else
  begin
    gLog.Add(lkWarning, 'Chart I/F Impjavalementation', 'Request Chart',
      'Cannot provide chart data for ''' + aReq.Symbol.Desc + '''');
  end;

  //-- get ServiceID and DsoID
  
  iTerm := 0;
  case aReq.ChartBase of
    cbMin     :
        begin
          iServiceID := 4130;
          iDsoID := 413000 ;
          iTerm := aReq.Period;
        end;
    cbDaily   :
        begin
          iDsoID := 410001;
          iServiceID := 4100;
        end;
    cbWeekly  :
        begin
          iDsoID := 411000;
          iServiceID := 4110 ;
        end ;
    cbMonthly :
        begin
          iDsoID := 411100;
          iServiceID := 4110 ;
        end;
    else
      Exit;
  end;

  //-- make packet and send to the server
  iP := 0;
  if //-- header
     gTyTCP.MakePacket(szBuf, iP, iServiceID, iDsoID) and
     //-- data
     ConvertLong (szBuf, iP, 0) and // not used - 분석챠트종류
     ConvertBytes(szBuf, iP, cKind) and // symbol type - 종목구분
     ConvertString(szBuf, iP, aReq.Symbol.Code) and   // symbol - 종목코드
     ConvertBytes(szBuf, iP, #0) and  // not used - 시간단위
     ConvertLong (szBuf, iP, iTerm) and // term   - 분단위
     
     ConvertLong (szBuf, iP, aReq.Start) and // Start Date : from the most recent - 시작일
     ConvertLong (szBuf, iP,  0) and // End Date : 0 = ignored - 마지막일
     ConvertLong (szBuf, iP, aReq.Start) and // Start Time : from the most recent - 시작시간
     ConvertLong (szBuf, iP,  0) and // End Time : 0 = ignored - 마지막시간
     //
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션1
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션2
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션3
     ConvertLong (szBuf, iP,  0) and // not used  - 옵션4
     ConvertLong (szBuf, iP, aReq.RemCount)
  then
    begin
    
    gTyTCP.SendPacket(Self, ResultProc, szBuf, iP);
    end
  else
    gLog.Add(lkError, 'ChartIF', 'Request Chart', 'Packet making failure');
end;

//=================================================================//
//               Receiving Part                                    //
//=================================================================//

procedure TImpChartIF.ResultProc(Sender, Receiver: TObject;
  szPacket: PChar; iSize: Integer; aToken : TPacketTokenRec);
var
  i, iP, iService, iDSO, iError, iHLen : Integer;
  bSuccess : Boolean;
  stData : String;
  aReq : TChartReqItem;
begin
  //--1. Check
  if Receiver <> Self then
  begin
    gLog.Add(lkDebug, 'Chart IF Implementation', 'Rx Packet',
      'Delivery mismatched');
    Exit;
  end;

  //--2. Decode Packet Header
  if not gTyTCP.DecodeHeader(szPacket, iSize, bSuccess,
     iService, iDSO, iError, stData, iHLen) then
    Exit;

  //--3. looking for sending packet
  if FChartReqs.Count = 0 then
  begin
    gLog.Add(lkDebug, 'Chart IF Implementation', 'Rx Packet',
                      'Packt rx/tx has mismatched');
    Exit;
  end;
  aReq := FChartReqs.Items[0] as TChartReqItem;

  //--4. Process packet
  if not bSuccess then
  begin
    gLog.Add(lkError, 'Chart IF Implementation', '챠트자료 수신',
             Format('%s/rem:%d',[stData, FChartReqs.Count]) );
    // still notify
    (aReq.Receiver as TChartData).NotifyReady;
    //
    aReq.Free;
  end else
  begin
    if (iDSO = 413000) or (iDSO = 411100) or (iDSO = 411000) or (iDSO = 410001 ) then
      ProcessTerm(aReq, szPacket+iHLen, iSize - iHLen)
    else
    if iDSO = 411200 then
      ProcessTick(aReq, szPacket+iHLen, iSize - iHLen)
    else
    if iDSO = 210400 then
      ProcessStockMin(aReq, szPacket+iHLen, iSize - iHLen)
    else
    if iDSO = 210001 then
      ProcessStockDaily(aReq, szPacket + iHLen, iSize - iHLen)
    else
    if (iDSO = 210201) or (iDSO = 210301) then
      ProcessStockLongTerm(aReq, szPacket + iHLen, iSize - iHLen);
  end;

  // next turn
  RequestChart;
end;

procedure TImpChartIF.ProcessTerm(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  lValue : LongInt;
  aChartData : TChartData;
  wRecCnt : SmallInt;

  iTime, iYY, iMM, iDD :  LongInt;

  dtValue : TDateTime;
  dOpen, dHigh, dLow, dClose : Double;
  dFillVol, dAccVol : Double;
  
begin
  aChartData := aReq.Receiver as TChartData;

  iP := 0 ;

  DeconvertLong(szBuf, iP, aReq.RemCount);    // remain count
  iP := iP + 12 ;   // 옵션 1,2,3
  DeconvertLong(szBuf, iP, aReq.Start);      // 시작일
  iP := iP + 4 ;   // 마지막일

  if aReq.ChartBase = cbDaily then
    iP := iP + 4
  else
    DeconvertLong(szBuf, iP, aReq.Start);     // 시작시각

  iP := iP + 4 ;  // 마지막 시각

  DeconvertWord(szBuf , iP , wRecCnt );
  
  try
  
    for i:=0 to wRecCnt-1 do
    begin
      DeconvertLong(szBuf, iP, iTime) ; 
      //
      if aReq.ChartBase in [cbDaily, cbWeekly, cbMonthly] then
      begin

        iYY := iTime div 10000;
        iTime := (iTime - iYY * 10000);
        iMM := iTime div 100;
        iDD := iTime mod 100;
        dtValue := EncodeDate(iYY, iMM, iDD);

      end else
      begin
       dtValue := (iTime div 86400) {date} + DAY_OFFSET {1970yr-1900yr} +
              ( iTime mod 86400) / 86400.0 {time of a day} + HOUR_OFFSET;
     end;

      // o, h, l, c
      DeconvertLong(szBuf, iP, lValue); dOpen := lValue / 100.0;
      DeconvertLong(szBuf, iP, lValue); dHigh := lValue / 100.0;
      DeconvertLong(szBuf, iP, lValue); dLow := lValue / 100.0;
      DeconvertLong(szBuf, iP, lValue); dClose := lValue / 100.0;
      // volume
      DeconvertLong(szBuf, iP, lValue); dFillVol := lValue;
      iP := iP + 4;
      // add data

      aChartData.Terms.InsertTerm(
          dtValue, dOpen, dHigh, dLow, dClose, dFillVol, 0.0);
    end;

  except
    gLog.Add(lkWarning, 'ChartIF', 'ProcessTerm', 'Parsing ProcessTerm Error');
  end;
end;

procedure TImpChartIF.ProcessTick(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  lValue : LongInt;
  aChartData : TChartData;
  wRecCnt : SmallInt;

  iTime :  LongInt;
  wHH, wMM, wSS, wNN : Word;

  dtValue : TDateTime;
  dPrice, dFillVol : Double;

  bNonValue : Boolean;
begin
  aChartData := aReq.Receiver as TChartData;


  
  iP := 0 ;
  DeconvertLong(szBuf, iP, aReq.RemCount);    // remain count

  iP := iP + 12 ; // 옵션 1,2,3

  DeconvertLong(szBuf, iP, aReq.Start);      // 시작일
  iP := iP + 4 ;  // 마지막일
  DeconvertLong(szBuf, iP, aReq.Start);     // 시작시각
  iP := iP + 4 ;  // 마지막시각
 
  DeconvertWord(szBuf , iP , wRecCnt );

  try

    for i:=0 to wRecCnt-1 do
    begin
      //
      bNonValue := False;

      DeconvertLong(szBuf, iP, iTime) ;
      //
      wHH := iTime div 1000000;
      iTime := iTime - wHH * 1000000;
      wMM := iTime div 10000;
      iTime := iTime - wMM * 10000;
      wSS := iTime div 100;
      wNN := iTime mod 100;

      dtValue := EncodeTime(wHH, wMM, wSS, wNN);

      // o, h, l, c
      DeconvertLong(szBuf, iP, lValue);
      DeconvertLong(szBuf, iP, lValue);
      DeconvertLong(szBuf, iP, lValue);
      DeconvertLong(szBuf, iP, lValue); dPrice := lValue / 100.0;

      //
      if lValue = CHART_NA_VALUE then
        bNonValue := True;

      // volume
      DeconvertLong(szBuf, iP, lValue); dFillVol := lValue;
      iP := iP + 4;
      // add data

      if not bNonValue then
        aChartData.Ticks.InsertTick(dtValue, dPrice, dFillVol, 0.0);

    end;

  except
    //
  end;

  
end;

procedure TImpChartIF.ProcessStockMin(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  lValue : LongInt;
  aChartData : TChartData;
  wRecCnt : SmallInt;

  iTime :  LongInt;

  dtValue : TDateTime;
  dOpen, dHigh, dLow, dClose : Double;
  dFillVol, dAccVol : Double;
begin
  aChartData := aReq.Receiver as TChartData;

  iP := 12;
  // data status
  DeconvertLong(szBuf, iP, aReq.Start);  // start date
  DeconvertLong(szBuf, iP, aReq.RemCount);    // remain count
  // data record count
  DeconvertWord(szBuf, iP, wRecCnt);   // data count
  // data
  try
    for i:=0 to wRecCnt-1 do
    begin
      // time
      DeconvertLong(szBuf, iP, iTime);

        dtValue := (iTime div 86400) {date} + DAY_OFFSET {1970yr-1900yr} +
                   (iTime mod 86400) / 86400 {time of a day} + HOUR_OFFSET;

      // o, h, l, c
      DeconvertLong(szBuf, iP, lValue); dOpen := lValue;
      DeconvertLong(szBuf, iP, lValue); dHigh := lValue;
      DeconvertLong(szBuf, iP, lValue); dLow := lValue;
      DeconvertLong(szBuf, iP, lValue); dClose := lValue;
      // volume
      DeconvertLong(szBuf, iP, lValue); dFillVol := lValue;
      // add data
      aChartData.Terms.InsertTerm(
          dtValue, dOpen, dHigh, dLow, dClose, dFillVol, 0.0);
    end;
  except
    //
  end;
end;

procedure TImpChartIF.ProcessStockDaily(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  lValue : LongInt;
  aChartData : TChartData;
  wRecCnt : SmallInt;

  iTime, iYY, iMM, iDD :  LongInt;

  dtValue : TDateTime;
  dOpen, dHigh, dLow, dClose : Double;
  dFillVol, dAccVol : Double;
begin
  aChartData := aReq.Receiver as TChartData;

  iP := 4;
  // data status
  DeconvertLong(szBuf, iP, aReq.Start);  // start date
  DeconvertLong(szBuf, iP, aReq.RemCount);    // remain count
  iP := iP + 4;
  // data record count
  DeconvertWord(szBuf, iP, wRecCnt);   // data count
  // data
  try
    for i:=0 to wRecCnt-1 do
    begin
      // Date
      DeconvertLong(szBuf, iP, iTime);

      iYY := iTime div 10000;
      iTime := (iTime - iYY * 10000);
      iMM := iTime div 100;
      iDD := iTime mod 100;
      dtValue := EncodeDate(iYY, iMM, iDD);

      // o, h, l, c
      DeconvertLong(szBuf, iP, lValue); dOpen := lValue;
      DeconvertLong(szBuf, iP, lValue); dHigh := lValue;
      DeconvertLong(szBuf, iP, lValue); dLow := lValue;
      DeconvertLong(szBuf, iP, lValue); dClose := lValue;
      // volume
      DeconvertLong(szBuf, iP, lValue); dFillVol := lValue;
      iP := iP + 17;
      // add data
      aChartData.Terms.InsertTerm(
          dtValue, dOpen, dHigh, dLow, dClose, dFillVol, 0.0);
    end;
  except
    //
  end;
end;

procedure TImpChartIF.ProcessStockLongTerm(aReq : TChartReqItem; szBuf : PChar; iSize : Integer);
var
  i, iP : Integer;
  lValue : LongInt;
  aChartData : TChartData;
  wRecCnt : SmallInt;

  iTime, iYY, iMM, iDD :  LongInt;

  dtValue : TDateTime;
  dOpen, dHigh, dLow, dClose : Double;
  dFillVol, dAccVol : Double;
begin
  aChartData := aReq.Receiver as TChartData;

  iP := 4;
  // data status
  DeconvertLong(szBuf, iP, aReq.Start);  // start date
  DeconvertLong(szBuf, iP, aReq.RemCount);    // remain count
  // data record count
  DeconvertWord(szBuf, iP, wRecCnt);   // data count
  // data
  try
    for i:=0 to wRecCnt-1 do
    begin
      // Date
      DeconvertLong(szBuf, iP, iTime);

      iYY := iTime div 10000;
      iTime := (iTime - iYY * 10000);
      iMM := iTime div 100;
      iDD := iTime mod 100;
      dtValue := EncodeDate(iYY, iMM, iDD);

      // o, h, l, c
      DeconvertLong(szBuf, iP, lValue); dOpen := lValue;
      DeconvertLong(szBuf, iP, lValue); dHigh := lValue;
      DeconvertLong(szBuf, iP, lValue); dLow := lValue;
      DeconvertLong(szBuf, iP, lValue); dClose := lValue;
      // volume
      DeconvertLong(szBuf, iP, lValue); dFillVol := lValue;
      iP := iP + 5;
      // add data
      aChartData.Terms.InsertTerm(
          dtValue, dOpen, dHigh, dLow, dClose, dFillVol, 0.0);
    end;
  except
    //
  end;
end;

{
  // removed by jaebeom May, 13, 2003

initialization
  gChartIF := TImpChartIF.Create;

finalization
  gChartIF.Free;

}









end.

