unit CleVolTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  CleSymbols, CleCircularQueue, CleAccounts, CleKrxSymbols, CleDistributor, CleQuoteBroker,
  GleTypes
  ;

const
  Q_CNT = 4;

type
  TVolSymbol = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FChangeQ : TCircularQueue;
    FGapData : array[0..4] of double;
  public
    function GetData(iIndex : integer) : double;
    property Symbol : TSymbol read FSymbol;
    property ChangeQ : TCircularQueue read FChangeQ;

    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

  end;

  TVolSymbols = class(TCollection)
  private
    FAccount : TAccount;
    FStart : Boolean;

    FCallList, FPutList : TList;
    FOnResult : TResultNotifyEvent;
    FQuote   : TQuote;
    FOnDoLog: TNotifyEvent;

    procedure VolIndexInit;
    procedure MakeData;
    function CalData( dLast, dPrev : double) : double;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SetSymbol;
    procedure SetAccount( aAcnt : TAccount );
    procedure StartStop(bStart : Boolean);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    function AddVol(aSymbol : TSymbol) : TVolSymbol;
    property Account : TAccount read FAccount;
    property OnResult : TResultNotifyEvent read FOnResult write FOnResult;
    property OnDoLog  : TNotifyEvent read FOnDoLog write FOnDoLog;

  end;

implementation
uses
  GAppEnv, CleQuoteTimers;

{ TVolSymbols }

function TVolSymbols.AddVol(aSymbol: TSymbol) : TVolSymbol;
begin
  Result := Add as TVolSymbol;
  Result.FSymbol := aSymbol;
end;

function TVolSymbols.CalData(dLast, dPrev: double): double;
begin
  Result := dLast - dPrev;
end;

constructor TVolSymbols.Create;
begin
  inherited Create(TVolSymbol);
  FAccount := nil;
  FStart := false;
  FCallList := TList.Create;
  FPutList := TList.Create;
  VolIndexInit;
end;

destructor TVolSymbols.Destroy;
begin
  FCallList.Free;
  FPutList.Free;
  inherited;
end;

procedure TVolSymbols.MakeData;
var
  i : integer;
  tItem, aItem : TVolSymbol;
  aQuote : TQuote;
begin
  tItem := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TVolSymbol;
    aQuote := aItem.FSymbol.Quote as TQuote;

    if aQuote = FQuote then
      tItem := aItem;

    aItem.ChangeQ.PushItem(GetQuoteTime, aQuote.Last);
    aItem.FGapData[0] := aQuote.Last;
    // 3초
    aItem.FGapData[1] :=  CalData(aItem.ChangeQ.Value[1], aItem.ChangeQ.Value[0]);
    // 2초
    aItem.FGapData[2] := CalData(aItem.FChangeQ.Value[2], aItem.FChangeQ.Value[1]);
    // 1초
    aItem.FGapData[3] := CalData(aItem.FChangeQ.Value[3], aItem.FChangeQ.Value[2]);
    // sum
    aItem.FGapData[4] := CalData(aItem.FChangeQ.Value[3], aItem.FChangeQ.Value[0]);
  end;

  if Assigned(FOnResult) then   //화면갱신
    FOnResult(self, true);

  if tItem <> nil then
    if ((tItem.GetData(4) > 0.01) and ( tItem.GetData(3) > 0 ) and ( tItem.GetData(2) >=0)) or
       ((tItem.GetData(4) < -0.01 ) and ( tItem.GetData(3) < 0 ) and ( tItem.GetData(2) <=0)) then
      FOnDoLog( self );
end;

procedure TVolSymbols.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  aQuote : TQuote;
begin
  if DataObj = nil then Exit;

  FQuote := DataObj as TQuote;
  MakeData;
end;

procedure TVolSymbols.SetAccount(aAcnt: TAccount);
begin
  FAccount := aAcnt;
end;

procedure TVolSymbols.SetSymbol;
var
  i : integer;
  aSymbol : TSymbol;
begin
  gEnv.Engine.SymbolCore.GetCurCallList(6, FCallList);
  gEnv.Engine.SymbolCore.GetCurPutList(6, FPutList );

  for i := FCallList.Count - 1 downto 0 do
  begin
    aSymbol := FCallList.Items[i];
    //if aSymbol.Last <= 2 then
      AddVol(aSymbol);
  end;

  for i := 0 to FPutList.Count - 1 do
  begin
    aSymbol := FPutList.Items[i];
    //if aSymbol.Last <= 2 then
      AddVol(aSymbol);
  end;

end;

procedure TVolSymbols.StartStop(bStart: Boolean);
begin
  FStart := bStart;
end;

procedure TVolSymbols.VolIndexInit;
var
  aSymbol : TSymbol;
begin
   aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(KOSPI200_VOL_CODE);
   if aSymbol = nil then exit;
   AddVol(aSymbol);

   aSymbol := gEnv.Engine.SymbolCore.Futures[0];
   AddVol(aSymbol);
   gEnv.Engine.QuoteBroker.Subscribe(self, KOSPI200_VOL_CODE, QuoteProc);
end;

{ TVolSymbol }

constructor TVolSymbol.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FChangeQ := TCircularQueue.Create(Q_CNT);
  FSymbol := nil;
end;

destructor TVolSymbol.Destroy;
begin
  FChangeQ.Free;
  inherited;
end;

function TVolSymbol.GetData(iIndex: integer): double;
begin
  Result := FGapData[iIndex];
end;

end.
