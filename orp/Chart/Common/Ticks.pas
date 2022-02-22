unit Ticks;

interface

uses
  Classes, SysUtils, GleTypes, Math,

  CleCircularQueue,

  CleSymbols;

type
  { Tick }
  TTickItem = class(TCollectionItem)
  public
    T : TDateTime;
    C : Single;
    FillVol : Double;
    AccVol : Double;
    OpenInterest : LongInt;
    Side  : integer;
    AskPrice  : double;
    BidPrice  : double;
  end;

  TFillTickItem = class(TTickItem)
  public
    PositionType : TPositionType;
  end;

  TTicks = class(TCollection)
  private
    function GetTick(i : Integer) : TTickItem;
  public
    constructor Create;
    //
    procedure Tick(aObj : TObject);
    procedure InsertTick(dtValue : TDateTime; sPrice : Single;
                         dFillVol, dAccVol : Double);
    //
    property Data[i:Integer] : TTickItem read GetTick; default;
  end;

  TSTermItem = class(TCollectionItem)
  public
    StartTime : TDateTime;
    LastTime  : TDateTime;
    Count : Integer;
    MMIndex : Integer;
    O, H, L, C : Single;
    O2, H2, L2, C2 : Single;



    AskPrice, BidPrice : Double;
    Ammount, DailyAmt : double;

    FillVol : Double;
    AccVol : Double;
    SideVol: Double;
    //
    Side : Integer; // (1:Long side, -1:Short side, 0:undefined) added on 2004.2.16.
    //
    Valid : Boolean;

    function IsPlus : boolean;
    procedure Assign(Source : TPersistent);override;
    //
    constructor Create(Collection : TCollection);override;
    destructor Destroy; override;
  end;

  TSTerms = class(TCollection)
  private
    FLastItem: TSTermItem;
    FCalcedATR: boolean;
    FPrevTerm: TSTermItem;
  protected
    FSymbol : TSymbol;
    FPeriod : Integer;
    FReqCount : Integer;
    // source data
    FTicks : TCollection;
    // status flags
    FReady : Boolean;
    FLastChangedOnUpdate : Boolean;
    // events
    FOnAdd : TNotifyEvent;
    FOnUpdate : TNotifyEvent;
    FOnRefresh : TNotifyEvent;
    // for fill records
    FLastData : TTickItem;
    // 0 : 1분    1 : 5분
    FtrQ  : array [0..1] of TCircularQueue;

    procedure AddTick(aTick : TTickItem); // tick chart data
    // get/set
    function GetXTerm(i : Integer) : TSTermItem;
  published

  public
    ATR : array [0..1] of double;
    constructor Create;
    destructor Destroy; override;

    procedure NewTick(aTick : TTickItem); // quote tick
    function New( dtTime : TDateTime ) : TSTermItem;
    //
    procedure GetMinMax(iStart, iEnd : Integer; var dMin, dMax : Double);
    procedure GetMinMax2(iStart, iEnd : Integer; var dMin, dMax : Double);
    function DateTimeDesc(iIndex : Integer) : String;

    procedure CalcePrevATR;
    procedure CalcRealATR( bRecover : boolean = false );

    // attributes
    property Symbol : TSymbol read FSymbol write FSymbol;
    // property Mode : TXTermMode read FMode;  // obsolete

    property Period : Integer read FPeriod write FPeriod;       //

    // events
    property OnAdd : TNotifyEvent read FOnAdd write FOnAdd;
    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnRefresh : TNotifyEvent read FOnRefresh write FOnRefresh;
    //
    property Ready : Boolean read FReady;
    property LastChangedOnUpdate : Boolean read FLastChangedOnUpdate; // added by CHJ on 2003.3.26
    property XTerms[i:Integer] : TSTermItem read GetXTerm; default;
    property LastTerm : TSTermItem read FLastItem write FLastItem;
    property PrevTerm : TSTermItem read FPrevTerm write FPrevTerm;


    property CalcedATR : boolean read FCalcedATR;

  end;

implementation

uses
  GAppEnv, GleConsts, CleQuoteTimers 
  ;

//===============================================================//
                    { TTicks}
//===============================================================//

constructor TTicks.Create;
begin
  inherited Create(TTickItem);
end;

function TTicks.GetTick(i : Integer) : TTickItem;
begin
  if (i>=0) and (i<Count) then
    Result := Items[i] as TTickItem
  else
    Result := nil;
end;

// tick history
procedure TTicks.InsertTick(dtValue : TDateTime; sPrice : Single;
  dFillVol, dAccVol : Double);
var
  aTick : TTickItem;
begin
  //
  if Count = 0 then
    aTick := nil
  else
    aTick := Items[0] as TTickItem;
  //
  if (aTick = nil) or (dtValue < aTick.T) then
    with Insert(0) as TTickItem do
    begin
      T := dtValue;
      C := sPrice;
      FillVol := dFillVol;
      AccVol := dAccVol;
    end;
end;

{
// tick history
procedure TTicks.InsertTick(iTime : Integer; sPrice : Single;
  dFillVol, dAccVol : Double);
var
  aTick : TTickItem;
  wHH, wMM, wSS : Integer;
  aTime : TDateTime;
begin
  if iTime = 0 then Exit;
  //-- get time
  wHH := iTime div 10000;
  iTime := iTime - wHH * 10000;
  wMM := iTime div 100;
  wSS := iTime mod 100;
  aTime := EncodeTime(wHH, wMM, wSS, 0);
  //
  if Count = 0 then
    aTick := nil
  else
    aTick := Items[0] as TTickItem;
  //
  if (aTick = nil) or (aTime < aTick.T) then
    with Insert(0) as TTickItem do
    begin
      T := aTime;
      C := sPrice;
      FillVol := dFillVol;
      AccVol := dAccVol;
    end;
end;
}

// real time tick
procedure TTicks.Tick(aObj : TObject);
var
  aTick : TTickItem;
begin
  aTick := aObj as TTickItem;
  //
  with Add as TTickItem do
  begin
    T := aTick.T;
    C := aTick.C;
    FillVol := aTick.FillVol;
    AccVol := aTick.AccVol;
  end;
end;

{ TSTermItem }

procedure TSTermItem.Assign(Source: TPersistent);
var
  aSource : TSTermItem;
begin
  if Source = nil then Exit;

  if Source is TSTermItem then
  begin
    aSource := Source as TSTermItem;

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
  end;
end;

constructor TSTermItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  Valid := True;
end;

destructor TSTermItem.Destroy;
begin
  inherited;
end;

function TSTermItem.IsPlus: boolean;
begin
  Result := ( L - O ) > 0;  
end;

{ TSTerms }

procedure TSTerms.AddTick(aTick: TTickItem);
var
  aTime : TDateTime;
  aXTerm : TSTermItem;
begin
  //-- get the last one
  if Count = 0 then
    aXTerm := nil
  else
    aXTerm := Items[Count-1] as TSTermItem;
  //
  aTime := aTick.T + GetQuoteDate; // combined with date
  if (aXTerm = nil) or (aXTerm.Count >= FPeriod) then
  begin
    aXTerm := Add as TSTermItem;
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
  end;

end;

procedure TSTerms.CalcePrevATR;
var
  j,i,k, iCnt: integer;
  aItem , aPrvItem : TSTermItem;
  dtTime : TDateTime;
  a,b, c, r : double;

begin
       {
  if FCalcedATR then Exit;

  // 과거 50개 봉의 이동평균 ATR 을 구한다.
  iCnt := 0;

  for I := 0 to Count - 1 do
  begin

    k := i-1;  if k < 0 then k := 0;

    aItem   := XTerms[i];
    aPrvItem:= XTerms[k];

    a := aItem.H - aItem.L;
    b := abs( aPrvItem.C - aItem.H );
    c := abs( aPrvItem.C - aItem.L );

    r:= max( max( a,b ), c );
    inc( iCnt );

    FtrQ.PushItem( now, r);
    if FtrQ.Full then
      aItem.ATR := FtrQ.SumPrice / FtrQ.MaxCount
    else
      aItem.ATR := FtrQ.SumPrice / iCnt ;

    gEnv.EnvLog( WIN_TEST, Format('%s, %s : %.2f, %.2f, %.2f, %.2f', [
      FormatDateTime('hh:nn:ss', aItem.StartTime),FormatDateTime('hh:nn:ss', aItem.LastTime),
      aItem.ATR, aItem.H, aItem.L, aItem.C ])
      );

    if LastTerm <> nil then
      LastTerm.ATR  :=aItem.ATR;
  end;
  FCalcedATR  := true;
  }

end;

procedure TSTerms.CalcRealATR( bRecover : boolean );
var
  iCnt, iNow, iPrev : integer;
  aItem , aPrvItem : TSTermItem;
  dh, dL, a,b, c, r, trSum : double;
  I: Integer;
begin
  // 인뎃스 계산이르모 -1 을 해줌..
  iCnt := Count-1;
  if iCnt < 2 then Exit;
  // 텀데이타 ADD Count-2 가 현재부터 5분전 데이타임.
  iNow := iCnt -1;
  iPrev:= iNow -1;

  aItem   := XTerms[iNow];
  aPrvItem:= XTerms[iPrev];

  a := aItem.H - aItem.L;
  b := abs( aPrvItem.C - aItem.H );
  c := abs( aPrvItem.C - aItem.L );

  r:= max( max( a,b ), c );

  FtrQ[0].PushItem( aItem.StartTime, r);
  ATR[0]  := FtrQ[0].SumPrice / FtrQ[0].Count;

  if ( LastTerm <> nil ) and (( LastTerm.MMIndex mod 5 ) = 0 ) then
  begin

    iPrev := iNow -4;
    if ( iNow < 0 ) or ( iPrev < 0 ) then Exit;
    aItem   := XTerms[iNow];
    aPrvItem:= XTerms[iPrev];

    dH := 0;   dL := 100000;
    for I := iPrev to iNow do
    begin
      aItem := XTerms[i];
      dH  := max( dH, aItem.H );
      dL  := min( dL, aItem.L );
    end;

    a := dH - dL;
    b := abs( PrevTerm.C - dH );
    c := abs( PrevTerm.C - dL );

    r:= max( max( a,b ), c );

    FtrQ[1].PushItem( aItem.StartTime, r);
    ATR[1]  := FtrQ[1].SumPrice / FtrQ[1].Count;

  {
    if FSymbol.ShortCode = '175M5000' then
    
    gEnv.EnvLog( WIN_TEST,  format('%s check 5min : %s, %s ~ %s', [
      FSymbol.ShortCode,
      FormatDateTime( 'hh:nn:ss', LastTerm.StartTime ),
      FormatDateTime( 'hh:nn:ss', aPrvItem.StartTime ),
      FormatDateTime( 'hh:nn:ss', PrevTerm.LastTime ) ])
         );
    }

  end;

end;

constructor TSTerms.Create;
begin
  inherited Create(TSTermItem);

  FSymbol := nil;
  FPeriod := 1;
  FReady := False;
  FTicks := TCollection.Create(TTickItem);
  FLastData := nil;
  FLastItem := nil;
  FPrevTerm := nil;
  FCalcedATR:= false;
  FtrQ[0]   := TCircularQueue.Create(30);
  FtrQ[1]   := TCircularQueue.Create(30);
end;

function TSTerms.DateTimeDesc(iIndex: Integer): String;
begin
  FtrQ[0].Free;
  FtrQ[1].Free;
end;

destructor TSTerms.Destroy;
begin
  FLastItem := nil;
  FTicks.Free;

  inherited;
end;

procedure TSTerms.GetMinMax(iStart, iEnd: Integer; var dMin, dMax: Double);
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

    with Items[i] as TSTermItem do
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

procedure TSTerms.GetMinMax2(iStart, iEnd: Integer; var dMin, dMax: Double);
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

    with Items[i] as TSTermItem do
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

function TSTerms.GetXTerm(i: Integer): TSTermItem;
begin
  if (i>=0) and (i<Count) then
    Result := Items[i] as TSTermItem
  else
    Result := nil;
end;

function TSTerms.New(dtTime: TDateTime): TSTermItem;
begin
  Result := Add as TSTermItem;
  Result.StartTime := dtTime;
  PrevTerm  := LastTerm;
  LastTerm  := Result;
end;

procedure TSTerms.NewTick(aTick: TTickItem);
var
  aXTerm : TSTermItem;
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
  //  aQuote := nil;
  end
  else
    aXTerm := Items[Count-1] as TSTermItem;

  //-- get MMIndex
  DecodeTime(aTick.T, wHH, wMM, wSS, wCC);
  iMMIndex := (wHH )*60 + wMM;
  if iMMIndex < 0 then exit;

  aTime:= Frac(aTick.T) + GetQuoteDate; // combined with date

  //-- check new
  if aXTerm = nil then
    bNew := True
  else
    bNew := (Floor(aXTerm.LastTime) <> Floor(aTime)) or // date changed
                    (iMMIndex div FPeriod > aXTerm.MMIndex div FPeriod); // over a period
      // add up
//      gEnv.EnvLog( WIN_TEST, Format( '(%d = %d div %d) > (%d = %d div %d)',
//        [  iMMIndex div FPeriod, iMMIndex, FPeriod, aXTerm.MMIndex div FPeriod, aXTerm.MMIndex , FPeriod ] ));

      if bNew then
      begin
        aXTerm := Add as TSTermItem;
        //
        aXTerm.StartTime := aTime;

        aXTerm.MMIndex := (iMMIndex div FPeriod) * FPeriod;
        iNextMMIndex := aXTerm.MMIndex + FPeriod;

        try
          aXTerm.LastTime := Floor(aTime) + EncodeTime(iNextMMIndex div 60,
                                                     iNextMMIndex mod 60,
                                                     0, 0);
        except
          gEnv.EnvLog( WIN_ERR,
            Format(' %d, %d, %d, %d ', [ iNextMMIndex, iNextMMIndex , iMMIndex, FPeriod]  )
          );
        end;

        aXTerm.Count := 1;
        aXTerm.O := aTick.C;
        aXTerm.H := aTick.C;
        aXTerm.L := aTick.C;
        aXTerm.C := aTick.C;
        aXTerm.FillVol := aTick.FillVol;
        aXTerm.AccVol := aTick.AccVol;
        aXTerm.SideVol:= aTick.FillVol * aTick.Side;
        aXTerm.AskPrice := aTick.AskPrice;
        aXTerm.BidPrice := aTick.BidPrice;

        //
        aXTerm.Side := 0;
        PrevTerm  := LastTerm;
        LastTerm  := aXTerm;
        //-- end of add
        CalcRealATR;

        if Assigned(FOnAdd) then
          FOnAdd(Self);

      end else
      begin

        aXTerm.H := Max(aXTerm.H, aTick.C);
        aXTerm.L := Min(aXTerm.L, aTick.C);

        FLastChangedOnUpdate :=
            (Abs(aXTerm.C - aTick.C) > PRICE_EPSILON); // added by CHJ on 2003.3.26
        aXTerm.C := aTick.C;
        aXTerm.FillVol := aXTerm.FillVol + aTick.FillVol;
        aXTerm.AccVol := aTick.AccVol;

        aXTerm.AskPrice := aTick.AskPrice;
        aXTerm.BidPrice := aTick.BidPrice;        

        if FReady and Assigned(FOnUpdate) then
           FOnUpdate(Self);
      end;

end;

end.
