unit CleStrategyStore;

interface

uses
  Classes, SysUtils,
  ClePositions, CleAccounts, GleTypes, CleFills, CleSymbols, CleOrders, CleQuoteBroker
  ;

type

  TStrategyBase = class(TCollectionItem)
  private
    FStartTime : TDateTime;
    FEndTime : TDateTime;
    FPositions : TPositions;
    FPosition : TPosition;
    FOrderList : TList;
    FNumber : integer;                          //화면 넘버
    FAccount : TAccount;
    FOrderType : TOrderSpecies;                 //주문 종류
    FStrategyType : TStrategyType;              //전략 종류
    FTotPL : double;                            //총손익
    FFutQuote : boolean;                        //거래되는 종목중 선물이 없고 선물시세로 신호발생하는 전략
    FOnResult : TResultNotifyEvent;
    FOnText : TSsNotifyEvent;                   
    function FindPosition( aSymbol : TSymbol ) : TPosition;
    function GetRatio( dRatio : double ) : integer;
  public
    constructor Create(aColl : TCollection; opType : TOrderSpecies; stType : TStrategyType = stNormal; bFut : boolean = false );
    destructor Destroy; override;
    procedure AddFill(aFill : TFill);
    procedure AddOrder(aOrder : TOrder);
    procedure AddPosition( aCall, aPut : TSymbol ); overload;
    procedure Addposition(aSymbol : TSymbol); overload;
    procedure ChangeSymbol( aSrc, aDes : TSymbol );
    function SymbolSelect( dLow, dHigh: double) : boolean;
    procedure GetPosition(var aList : TList);
    function GetRatioSymbol(bCall: boolean; dLow, dHigh : double;
                  iRatio : integer; var aITM: TSymbol; var aOTM : TSymbol) : integer;
    procedure GetStrangleSymbol(dLow, dHigh : double; var aList : TList);

    function GetInvestSymbol(bCall: boolean; dLow, dHigh : double; var aITM: TSymbol; var aOTM : TSymbol) : boolean;
    function GetHighSymbol(bCall : boolean; dLow, dHigh : double; var aSymbol : TSymbol) : boolean;

    function GetRatioSBase(dLow, dHigh : double; var aCall, aPut : TSymbol; dGap : double) : boolean;

    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); virtual; abstract;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); virtual; abstract;

    property StartTime : TDateTime read FStartTime write FStartTime;
    property EndTime : TDateTime read FEndTime write FEndTime;
    property Positions : TPositions read FPositions;
    property OrderList : TList read FOrderList;
    property Number : integer read FNumber write FNumber;
    property Account : TAccount read FAccount write FAccount;
    property OrderType : TOrderSpecies read FOrderType write FOrderType;
    property TotPL : double read FTotPL;
    property Position : TPosition read FPosition;
    property FutQuote : boolean read FFutQuote write FFutQuote;
    property StrategyType : TStrategyType read FStrategyType write FStrategyType;
    property OnResult : TResultNotifyEvent read FOnResult write FOnResult;
    property OnText : TSsNotifyEvent read FOnText write FOnText;
  end;

  TStrategys = class(TCollection)
  private
    FNumber : integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdatePosition(aQuote : TQuote);
    procedure DoQuote(aQuote : TQuote; iDataID : integer);

    function Find( stType: TStrategyType; iNumber: integer; aSymbol : TSymbol) : TStrategyBase; overload;
    function Find( stType: TStrategyType; aAccount : TAccount) : TPosition; overload;
    property Number : integer read FNumber write FNumber;
  end;

  TStrategyStore = class
  private
    FStrategys : TStrategys;
    function GetDesc(stType: TStrategyType) : string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdatePosition(aQuote : TQuote);
    procedure DoQuote(aQuote : TQuote; iDataID : integer);
    procedure DoFill( aOrder : TOrder; aFill : TFill );
    procedure Report;
    function DoOrder(iID: integer; aOrder : TOrder): boolean;
    function GetStrategys : TStrategys;
    procedure Del(aBase : TStrategyBase);
    property Strategys : TStrategys read FStrategys;
  end;
implementation

uses
  GAppEnv, CleQuoteTimers, CleFQN;

{ TStrategyItem }

procedure TStrategyBase.AddFill(aFill: TFill);
var
  aPos : TPosition;
begin
  aPos := FindPosition(aFill.Symbol);
  if aPos = nil then
    aPos := FPositions.New(FAccount, aFill.Symbol);

  aPos.AddFill(aFill);
end;

procedure TStrategyBase.AddOrder(aOrder: TOrder);
begin
  FOrderList.Add(aOrder);
end;

procedure TStrategyBase.AddPosition(aSymbol: TSymbol);
var
  aPos : TPosition;
begin
  aPos := FindPosition(aSymbol);
  if aPos = nil then
    FPosition := FPositions.New(FAccount, aSymbol);
end;

procedure TStrategyBase.AddPosition(aCall, aPut: TSymbol);
var
  i : integer;
  aPos, aCallPos, aPutPos : TPosition;
begin
  aCallPos := FindPosition(aCall);
  aPutPos := FindPosition(aPut);
  if (aCallPos = nil) and (aPutPos = nil) then
  begin
    FPositions.New(FAccount, aCall);
    FPositions.New(FAccount, aPut);
  end;
end;

procedure TStrategyBase.ChangeSymbol( aSrc, aDes : TSymbol );
var
  aPos : TPosition;
begin
  aPos := FindPosition(aSrc);
  if aPos <> nil then
    aPos.Free;
  FPosition := FPositions.New(FAccount, aDes);

end;

constructor TStrategyBase.Create(aColl: TCollection; opType : TOrderSpecies; stType : TStrategyType; bFut : boolean);
begin
  inherited Create(aColl);
  FOrderList := TList.Create;
  FPositions := TPositions.Create;
  FStartTime := EnCodeTime(9,0,1,0);
  FEndTime := EnCodeTime(15,20,0,0);
  FOrderType := opType;
  FFutQuote := bFut;
  FStrategyType := stType;

  inc(TStrategys(Collection).FNumber);
  FNumber := TStrategys(Collection).FNumber;
end;

destructor TStrategyBase.Destroy;
begin
  FOrderList.Free;
  FPositions.Free;
  OnResult := nil;
  inherited;
end;

function TStrategyBase.FindPosition(aSymbol: TSymbol): TPosition;
var
  i : integer;
  aPos : TPosition;
begin
  Result := nil;
  for i := 0 to FPositions.Count - 1 do
  begin
    aPos := FPositions.Items[i] as TPosition;
    if (aPos.Symbol = aSymbol) and
        (aPos.Account = FAccount) then
    begin
      Result := aPos;
      break;
    end;
  end;
end;

function TStrategyBase.GetInvestSymbol(bCall: boolean; dLow, dHigh: double;
  var aITM, aOTM: TSymbol) : boolean;
var
  aCall, aPut : TList;
  stLog : string;
begin
  Result := false;
  aCall := TList.Create;
  aPut := TList.Create;
  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, false, aCall, aPut);  //현재가

  if bCall then           //콜 ITM일때       Call Index = 0  가격 높음,  Put Index = 0 가격낮음
  begin
    if aCall.Count > 0 then
      aITM := aCall.Items[0];
    if aPut.Count > 0 then
      aOTM := aPut.Items[0];
  end else
  begin
    if aCall.Count > 0 then
      aOTM := aCall.Items[aCall.Count-1];
    if aPut.Count > 0 then
      aITM := aPut.Items[aPut.Count-1];
  end;
  if (aOTM <> nil) and (aITM <> nil) then
  begin
    if (aOTM as TOption).DaysToExp = 1 then
      FEndTime := EnCodeTime(15, 20, 0 ,0)
    else
      FEndTime := EnCodeTime(15, 30, 0, 0);

    stLog := Format('GetInvestSymbol ITM = %s(%.2f), OTM = %s(%.2f), CallCnt = %d, PutCnt = %d',
                   [aITM.ShortCode, aITM.Last, aOTM.ShortCode, aOTM.Last, aCall.Count, aPut.Count]);
    gEnv.EnvLog(WIN_INV,stLog);
    Result := true;
  end;
  aCall.Free;
  aPut.Free;
end;

procedure TStrategyBase.GetPosition(var aList: TList);
var
  i : integer;
  aPos : TPosition;
begin
  for i := 0 to FPositions.Count - 1 do
  begin
    aPos := FPositions.Items[i] as TPosition;
    if aPos.Account = FAccount then
      aList.Add(aPos);
  end;
end;

function TStrategyBase.GetRatio(dRatio: double): integer;
begin
  Result := 1;
  dRatio := dRatio * 100;
  if (dRatio < 150) then
    Result := 1
  else if (dRatio >= 150) and (dRatio < 250) then
    Result := 2
  else if (dRatio >= 250) and (dRatio < 350) then
    Result := 3
  else if (dRatio >= 350) and (dRatio < 450) then
    Result := 4
  else if (dRatio >= 450) and (dRatio < 550) then
    Result := 5;
end;

function TStrategyBase.GetRatioSBase(dLow, dHigh: double; var aCall,
  aPut: TSymbol; dGap : double): boolean;
var
  aCList, aPList : TList;
  stLog : string;
  dtTime : TDateTime;
  dSum : double;
  i, j : integer;
begin
  Result := false;
  aCList := TList.Create;
  aPList := TList.Create;

  aCall := nil;
  aPut := nil;

  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, false, aCList, aPList);  //현재가

  if aCList.Count > 0 then
    aCall := aCList.Items[0];

  if aPList.Count > 0 then
    aPut := aPList.Items[aPList.Count-1];

  if (aCall <> nil) and (aPut <> nil) then
    Result := true;
 {
  for i := 0 to aCList.Count - 1 do
  begin
    aCall := aCList.Items[i];
    for j := aPList.Count-1 downto 0 do
    begin
      aPut := aPList.Items[j];

      dSum := aCall.Last - aPut.Last;
      if dSum < 0 then
        dSum := dSum * -1;

      if dSum <= dGap then
      begin
        Result := true;
        break;
      end;
    end;

    if Result then
      break;
    aCall := nil;
    aPut := nil;
  end;

  if (aCall = nil) or (aPut = nil) then
    Result := false;
    }
  aCList.Free;
  aPList.Free;
end;

function TStrategyBase.GetRatioSymbol(bCall: boolean; dLow, dHigh : double;
                  iRatio : integer; var aITM: TSymbol;  var aOTM : TSymbol) : integer;
var
  i, iTmp, iMod : integer;
  aCall, aPut : TList;
  aSymbol : TSymbol;
  dITM, dOTM, dRatio, dMin, dMax : double;
  stLog : string;
begin
  Result := 2;
  aCall := TList.Create;
  aPut := TList.Create;
  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, false, aCall, aPut);  //현재가

  if bCall then
  begin
    for i := 0 to aCall.Count - 1 do
    begin
      aSymbol := aCall.Items[i];
      if i = 0 then
      begin
        aITM := aSymbol;
        dITM := aSymbol.Last;
        dRatio := dITM * iRatio / 100;
        dMin := dITM - dRatio;
        dMax := dITM + dRatio;
      end else
      begin
        dOTM := aSymbol.Last;
        iTmp := GetRatio(dITM/dOTM);

        if iTmp > 1 then
        begin
          aOTM := aSymbol;
          Result := iTmp;
          stLog := Format('SetRatioSymbol Call ITM = %.2f, OTM = %.2f, Result = %.2f, %d',[dITM, dOTM, dITM/dOTM, iTmp]);
          gEnv.EnvLog(WIN_RATIO,stLog);
          break;
        end;

        if dOTM <= 0.02 then
        begin
          aOTM := aSymbol;
          Result := 2;
          stLog := Format('SetRatioSymbol 가격0.02 이하  Call ITM = %.2f, OTM = %.2f, Result = %.2f, %d',[dITM, dOTM, dITM/dOTM, iTmp]);
          gEnv.EnvLog(WIN_RATIO,stLog);
        end;


        if (i = aCall.Count - 1) and (aOTM = nil) then
        begin
          aOTM := aSymbol;
          Result := 2;
          stLog := Format('SetRatioSymbol 끝까지 찾다 Call ITM = %.2f, OTM = %.2f, Result = %.2f, %d',[dITM, dOTM, dITM/dOTM, iTmp]);
          gEnv.EnvLog(WIN_RATIO,stLog);
        end;
      end;
    end;

  end else
  begin
    for i := aPut.Count - 1 downto 0  do
    begin
      aSymbol := aPut.Items[i];
      if i = aPut.Count - 1 then
      begin
        aITM := aSymbol;
        dITM := aSymbol.Last;
        dRatio := dITM * iRatio / 100;
        dMin := dITM - dRatio;
        dMax := dITM + dRatio;
      end else
      begin
        dOTM := aSymbol.Last;
        iTmp := GetRatio(dITM/dOTM);
        if iTmp > 1 then
        begin
          aOTM := aSymbol;
          Result := iTmp;
          stLog := Format('SetRatioSymbol Put ITM = %.2f, OTM = %.2f, Result = %.2f, %d',[dITM, dOTM, dITM/dOTM, iTmp]);
          gEnv.EnvLog(WIN_RATIO,stLog);
          break;
        end;

        if dOTM <= 0.02 then
        begin
          aOTM := aSymbol;
          Result := 2;
          stLog := Format('SetRatioSymbol 가격0.02 이하  Put ITM = %.2f, OTM = %.2f, Result = %.2f, %d',[dITM, dOTM, dITM/dOTM, iTmp]);
          gEnv.EnvLog(WIN_RATIO,stLog);
        end;

        if (i = 0) and (aOTM = nil) then
        begin
          aOTM := aSymbol;
          Result := 2;
          stLog := Format('SetRatioSymbol 끝까지 찾다 Put ITM = %.2f, OTM = %.2f, Result = %.2f, %d',[dITM, dOTM, dITM/dOTM, iTmp]);
          gEnv.EnvLog(WIN_RATIO,stLog);
        end;

      end;
    end;
  end;
  if aOTM <> nil then
  begin
    if (aOTM as TOption).DaysToExp = 1 then
      FEndTime := EnCodeTime(15, 20, 0 ,0)
    else
      FEndTime := EnCodeTime(15, 30, 0, 0);

    stLog := Format('OTM Code = %s, Price = %.2f, %d',[aOTM.ShortCode, aOTM.Last, Result]);
    gEnv.EnvLog(WIN_RATIO, stLog);
  end;

end;

procedure TStrategyBase.GetStrangleSymbol(dLow, dHigh: double;
  var aList: TList);
var
  i, j : integer;
  aC, aP, aMinSymbol, aSelSymbol : TSymbol;
  dC, dP, dMin, dGap : double;
  stLog : string;
  aCall, aPut : TList;
begin
  aCall := TList.Create;
  aPut := TList.Create;
  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, false, aCall, aPut);  //현재가

  for i := 0 to aCall.Count - 1 do
  begin
    aC := aCall.Items[i];
    aMinSymbol := nil;
    dMin := 1000;
    dC := aC.Last;
    for j := aPut.Count - 1 downto 0 do
    begin
      aP := aPut.Items[j];
      if aP = aSelSymbol then continue;
      dP := aP.Last;

      dGap := dC - dP;
      if dGap < 0 then
        dGap := dGap * -1;
      stLog := Format('Code = %s, %.2f, Code = %s, %.2f, Gap = %.2f, Call = %d, Put = %d',
        [aC.ShortCode, dC, aP.ShortCode, dP, dGap, aCall.Count, aPut.Count]);
      gEnv.EnvLog(WIN_STR2, stLog);

      if dMin > dGap then
      begin
        dMin := dGap;
        aMinSymbol := aP;
      end;
    end;
    if aMinSymbol = nil then continue;
    aList.Add(aC);
    aList.Add(aMinSymbol);
    if (aC as TOption).DaysToExp = 1 then
      FEndTime := EnCodeTime(15, 20, 0 ,0)
    else
      FEndTime := EnCodeTime(15, 30, 0, 0);
    aSelSymbol := aMinSymbol;
    if aList.Count = 4 then break;
  end;
  aCall.Free;
  aPut.Free;
end;

function TStrategyBase.GetHighSymbol(bCall : boolean; dLow, dHigh : double; var aSymbol : TSymbol) : boolean;
var
  aCList, aPList : TList;
  stLog : string;
begin
  Result := false;
  aCList := TList.Create;
  aPList := TList.Create;
  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, false, aCList, aPList);  //현재가

  if bCall then           //콜 ITM일때       Call Index = 0  가격 높음,  Put Index = 0 가격낮음
  begin
    if aCList.Count > 0 then
      aSymbol := aCList.Items[0];
  end else
  begin
    if aPList.Count > 0 then
      aSymbol := aPList.Items[aPList.Count-1];
  end;
  if aSymbol <> nil then
  begin
    if (aSymbol as TOption).DaysToExp = 1 then
      FEndTime := EnCodeTime(15, 20, 0 ,0)
    else
      FEndTime := EnCodeTime(15, 30, 0, 0);

    stLog := Format('GetHighSymbol Symbol = %s(%.2f)',[aSymbol.ShortCode, aSymbol.Last]);
    gEnv.EnvLog(WIN_INV,stLog);
    Result := true;
  end;
  aCList.Free;
  aPList.Free;
end;

function TStrategyBase.SymbolSelect(dLow, dHigh: double): boolean;
var
  i, j : integer;
  aC, aP, aMinSymbol : TSymbol;
  dC, dP, dMin, dGap : double;
  stLog : string;
  aCall, aPut : TList;
  bExpect : boolean;

begin
  Result := false;
  aCall := TList.Create;
  aPut := TList.Create;

  if Frac(GetQuoteTime) < FStartTime then
    bExpect := true
  else
    bExpect := false;

  gEnv.Engine.SymbolCore.GetPriceSymbolList(dLow, dHigh, bExpect, aCall, aPut);  //현재가

    // 데이터 체크
  if not bExpect then
  begin
    for i := 0 to aCall.Count - 1 do
    begin
      aC := aCall.Items[i];
      if (aC.Quote = nil ) or ( (aC.Quote as TQuote).Sales.Count <= 2 ) then
        exit;
    end;

    for i := 0 to aPut.Count - 1 do
    begin
      aP := aPut.Items[i];
      if ( aC.Quote = nil ) or ((aP.Quote as TQuote).Sales.Count <= 2 ) then
        exit;
    end;
  end;


  for i := 0 to aCall.Count - 1 do
  begin
    aC := aCall.Items[i];
    aMinSymbol := nil;
    dMin := 1000;
    if bExpect then
      dC := aC.ExpectPrice
    else
      dC := aC.Last;

    for j := aPut.Count - 1 downto 0 do
    begin
      aP := aPut.Items[j];
      if bExpect then
        dP := aP.ExpectPrice
      else
        dP := aP.Last;

      dGap := dC - dP;
      if dGap < 0 then
        dGap := dGap * -1;


      stLog := Format('Code = %s, %.2f, Code = %s, %.2f, Gap = %.2f, Call = %d, Put = %d',
        [aC.ShortCode, dC, aP.ShortCode, dP, dGap, aCall.Count, aPut.Count]);
      gEnv.EnvLog(WIN_STR, stLog);

      if dMin > dGap then
      begin
        dMin := dGap;
        aMinSymbol := aP;
      end;
    end;
    if aMinSymbol = nil then continue;

    AddPosition(aC, aMinSymbol);

    if (aC as TOption).DaysToExp = 1 then
      FEndTime := EnCodeTime(15, 20, 0 ,0)
    else
      FEndTime := EnCodeTime(15, 30, 0, 0);
  end;

  if Positions.Count = 0 then
    Result := false
  else
    Result := true;

  aCall.Free;
  aPut.Free;
end;

{ TStrategys }

constructor TStrategys.Create;
begin
  inherited Create(TStrategyBase);
  FNumber := 0;
end;

destructor TStrategys.Destroy;
begin
//  inherited;
end;

procedure TStrategys.DoQuote(aQuote : TQuote; iDataID : integer);
var
  i, j : Integer;
  aItem : TStrategyBase;
  aPos : TPosition;
  dTot : double;
begin
  if iDataID = 300 then
  begin
    for i := 0 to Count - 1 do
    begin
      aItem := Items[i] as TStrategyBase;


      if aItem.Positions.Count > 0 then
        aPos := aItem.Positions.Items[0] as TPosition;


      aItem.QuoteProc(aQuote , iDataID);
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      aItem := Items[i] as TStrategyBase;
      for j := 0 to aItem.Positions.Count - 1 do
      begin
        aPos := aItem.Positions.Items[j] as TPosition;
        if aPos.Symbol = aQuote.Symbol then
          aItem.QuoteProc(aQuote, iDataID);
      end;

      if (aQuote.Symbol = gEnv.Engine.SymbolCore.Future ) and (aItem.FutQuote) then  // 선물은 거래되는 종목이 아닌 전략
        aItem.QuoteProc(aQuote, iDataID);
    end;
  end;
end;

// only 반옵2 참조용...
function TStrategys.Find(stType: TStrategyType;  aAccount: TAccount): TPosition;
var
  i : integer;
  aItem : TStrategyBase;
begin
  Result := nil;                               

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrategyBase;
    if (aItem.Account  = aAccount)
        and (aItem.StrategyType = stType) then
    begin
      if aItem.Positions.Count > 0 then
      begin
        Result := aItem.Positions.Positions[0];
        break;
      end;
    end;
  end;
end;


function TStrategys.Find(stType: TStrategyType; iNumber: integer;
  aSymbol: TSymbol): TStrategyBase;
var
  i : integer;
  aItem : TStrategyBase;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrategyBase;
    if (aItem.Number = iNumber)
        and (aItem.StrategyType = stType) then
    begin
      aItem.FPosition := aItem.FindPosition(aSymbol);
      Result := aItem;
      break;
    end;
  end;
end;

procedure TStrategys.UpdatePosition(aQuote: TQuote);
var
  i, j : Integer;
  aItem : TStrategyBase;
  aPos : TPosition;
  dTot : double;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TStrategyBase;
    for j := 0 to aItem.Positions.Count - 1 do
    begin
      aPos := aItem.Positions.Items[j] as TPosition;
      if aPos.Symbol = aQuote.Symbol then
        aPos.DoQuote(aQuote);
    end;
    aItem.FTotPL := aItem.FPositions.GetStrategyPL;
  end;
end;

{ TStrategyStore }

constructor TStrategyStore.Create;
begin
  FStrategys := TStrategys.Create;
end;

procedure TStrategyStore.Del(aBase : TStrategyBase);
var
  i : integer;
  aItem : TStrategyBase;
begin
  for i := 0 to FStrategys.Count - 1 do
  begin
    aItem := FStrategys.Items[i] as TStrategyBase;
    if aItem = aBase then
    begin
      FStrategys.Delete(i);
      break;
    end; 
  end;
    
end;

destructor TStrategyStore.Destroy;
begin
  FStrategys.Free;
  inherited;
end;

function TStrategyStore.GetDesc(stType: TStrategyType): string;
begin
  case stType of
    stNormal: Result := '';
    stStrangle: Result := '양매도';
    stYH: Result := '양합';
    stRatio: Result := '레이셔';
    stStrangle2: Result := '양매도2';
    stStrangle3: Result := '양매도3';
    stInvestor: Result := '투자자(개인)';
    stTodarke: Result := '토닥토닥';
    stHult : Result := '헐트';
    stOS : Result := 'OnlyShort';
    stVolS : Result := '변동성양매도';
    stOptHult : Result := '옵션헐트';
    stBHult : Result := '반헐트';
  end;
end;

function TStrategyStore.GetStrategys: TStrategys;
begin
  Result := FStrategys;
end;

procedure TStrategyStore.Report;
var
  i: Integer;
  aItem : TStrategyBase;
  stLog : string;
begin
  for i := 0 to FStrategys.Count - 1 do
  begin
    aItem := Fstrategys.Items[i] as TStrategyBase;
    stLog := Format('[%s] Num = %d, PL = %.0n', [ GetDesc(aItem.StrategyType), aItem.Number, aItem.TotPL]);
    gEnv.EnvLog(WIN_REPORT, stLog);
  end;
end;

procedure TStrategyStore.UpdatePosition(aQuote: TQuote);
begin
  if FStrategys = nil then exit;
  FStrategys.UpdatePosition(aQuote);
end;

function TStrategyStore.DoOrder(iID: integer; aOrder : TOrder): boolean;
var
  aItem : TStrategyBase;
  aPos : TPosition;
begin
  Result := false;
  if FStrategys = nil then exit;
  aItem := FStrategys.Find(aOrder.Ticket.StrategyType, aOrder.Ticket.ScreenNum, aOrder.Symbol);
  if aItem = nil then exit;
  aItem.TradeProc(aOrder, aItem.Position, iID);
end;

procedure TStrategyStore.DoQuote(aQuote : TQuote; iDataID : integer);
begin
  if FStrategys = nil then exit;
  FStrategys.DoQuote(aQuote, iDataID);
end;

procedure TStrategyStore.DoFill(aOrder : TOrder; aFill : TFill);
var
  aItem : TStrategyBase;
begin
  if FStrategys = nil then exit;
  aItem := FStrategys.Find(aOrder.Ticket.StrategyType, aOrder.Ticket.ScreenNum, aFill.Symbol);
  if aItem = nil then exit;
  aItem.AddFill( aFill );
end;

end.
