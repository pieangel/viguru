unit TyIndicators;

interface

uses
  Sysutils, Graphics, Windows, Math,

  CleDistributor, CleSymbols, GleTypes, GleLib, CleQuoteBroker, ClePositions,
  ChartIF,  CleQuoteTimers, CleAccounts,  GleConsts,
  EtcSeries, Indicator, TyIndicator;

type

  TOpenPositions = class(TTyIndicator)
  private
    procedure RequestEtcData;override;

    function SpotData(iBarIndex : Integer) : String; override;

    procedure TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);override;
    procedure DoTicks(aSymbol : TSymbol);override;
    procedure UnTicks;override;
    procedure Update;override;
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TBasis = class(TTyIndicator)
  private
    FKospi, FFuture : TSymbol;
    procedure RequestEtcData;override;
    procedure TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);override;
    procedure DoTicks(aSymbol : TSymbol); override;
    procedure UnTicks;override;
    procedure Update;override;

  public
    procedure DoInit;override;
    procedure DoPlot;override;
  end;

  TProfitNLoss = class(TTyIndicator)
  private
    procedure RequestEtcData;override;

    function SpotData(iBarIndex : Integer) : String; override;

    procedure PositionProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure DoTicks( aSymbol : TSymbol ) ; override;
    procedure DoPosition; override;
    procedure UnPosition; override;

    procedure Update;override;
    procedure AddPL(aItem: TPosTraceItem);
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
    procedure SetObject; override;
  public
    Account : TAccount;
  end;


  TProfitNLoss2 = class(TTyIndicator)
  private
    procedure RequestEtcData;override;

    function SpotData(iBarIndex : Integer) : String; override;

    procedure PositionProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure DoTicks( aSymbol : TSymbol ) ; override;
    procedure DoPosition; override;
    procedure UnPosition; override;

    procedure Update;override;
    procedure AddPL(aItem: TPosTraceItem2);
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
    procedure SetObject; override;
  public
    Position : TPosition;
  end;



implementation

uses GAppEnv, CleFQN, CleKrxSymbols;

{ TOpenPositions }

procedure TOpenPositions.DoInit;
begin
  FChartType := 14;
  FPrecision := 0;

  Title := '미결제 약정';

  AddPlot('미결제 약정', psLine, clRed, 1);
end;

procedure TOpenPositions.DoPlot;
begin
  Plot(0, Etc[0]);
end;

procedure TOpenPositions.DoTicks(aSymbol : TSymbol);
begin
  //if FEtcSeries.Symbol = nil then Exit;
  if (aSymbol = nil) or (FEtcSeries.Symbol = aSymbol) then Exit;

  if FEtcSeries.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self, FEtcSeries.Symbol );

  FEtcSeries.Symbol := aSymbol;
  gEnv.Engine.QuoteBroker.Subscribe( Self, FEtcSeries.Symbol, TickProc, spNormal );
end;

procedure TOpenPositions.RequestEtcData;
var
  i : Integer;
  aSymbol : TSymbol;

begin
  aSymbol := FSymboler.XTerms.Symbol;
  if (aSymbol = nil) or not(FSymboler.XTerms.Ready) then Exit;



  if (aSymbol.spec.Market <> mtFutures) and
      (aSymbol.Spec.Market <> mtOption) then
  begin
    gLog.Add(lkWarning , '종합챠트' , '미결제 약정 추가',
      '죄송 합니다. 다음 종목('+ aSymbol.Code +
      ')은 미결제 약정을 지원하지 않습니다.');

    SetZero;

  end else if FSymboler.XTerms.Base in [cbWeekly, cbMonthly] then
  begin
    gLog.Add(lkWarning , '종합챠트' , '미결제 약정 추가',
      '죄송 합니다. 미결제 약정은 주봉, 월봉은 지원하지 않습니다.');

    SetZero;
  end else if FSymboler.XTerms.Base in [cbTick, cbMin] then
  begin
    FEtcSeries.ClearData;

    for i := 0 to FSymboler.XTerms.Count-1 do
      FEtcSeries.AddData;

    FEtcReady := True;
    Remake;

    DoTicks(aSymbol);
  end else
    inherited;
end;

function TOpenPositions.SpotData(iBarIndex: Integer): String;
var
  i : Integer;
  aPlot : TPlotItem;
begin
  Result := '';
  if (iBarIndex >=0) and (iBarIndex < FSymboler.XTerms.Count) then
    for i:=0 to FPlots.Count-1 do
    begin
      aPlot := FPlots.Items[i] as TPlotItem;
      if aPlot.Data.Valids[iBarIndex] then
        Result := Result + ' ' + aPlot.Title+ ' :'
              + IntToStrComma(Floor(aPlot.Data.Values[iBarIndex]));
    end;
end;

procedure TOpenPositions.TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aSymbol : TSymbol;
  aQuote : TQuote;
  aTick, aData : TEtcSeriesItem;

begin
  if DataObj = nil then Exit;

  aQuote := DataObj as TQuote ;
  aSymbol := aQuote.Symbol;

  if aSymbol <> FEtcSeries.Symbol then Exit;

  if {(FSymboler.XTerms.Base = cbTick) and }
          (FEtcReady) and (FEtcSeries.Count >0) then
  begin

    aData := FEtcSeries.Datas[FEtcSeries.Count-1];

    if not(IsZero(aData.Value - aQuote.OpenInterest)) then
    begin
      aData.Value := aQuote.OpenInterest;
      Update;

      if Assigned(FOnAsyncUpdate) then
        FOnAsyncUpdate(Self);
    end;

  end;

  if not(FEtcReady) then
  begin
    aTick := FEtcSeries.AddTick;
    aTick.T := GetQuoteDate + aQuote.LastEventTime;
    aTick.Value := aQuote.OpenInterest;
  end;

end;

procedure TOpenPositions.UnTicks;
begin
  if FEtcSeries.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( self );

end;

procedure TOpenPositions.Update;
var
  aQuote : TQuote ;
begin
  if not(FEtcReady) or (FEtcSeries.Count < 1) then Exit;

  aQuote := FEtcSeries.Symbol.Quote as TQuote;

  if aQuote = nil then Exit;

  FEtcSeries[FEtcSeries.Count-1].Value := aQuote.OpenInterest;

  inherited;
end;


{ TBasis }

procedure TBasis.DoInit;
begin
  FChartType := 10;
  FPrecision := 2;

  Title := '베이시스';

  AddPlot('베이시스', psLine, clRed, 1);
end;

procedure TBasis.DoPlot;
begin
  Plot(0, Etc[0]);
end;

procedure TBasis.DoTicks(aSymbol: TSymbol);
var
  aFuture : TSymbol;
begin
  if (aSymbol = nil) or (aSymbol.Spec.Market <> mtFutures) then
  begin
    gLog.Add(lkError, 'TBasis', 'Wrong Symboler Symbol','');
    Exit;
  end;

  FKospi := gEnv.Engine.SymbolCore.Symbols.FindCode( KOSPI200_CODE );
  gEnv.Engine.QuoteBroker.Cancel( Self, FKospi );

  if FFuture <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self, FFuture );

  FFuture := aSymbol;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FKospi, TickProc, spNormal );
  gEnv.Engine.QuoteBroker.Subscribe( Self, FFuture, TickProc, spNormal );

end;

procedure TBasis.RequestEtcData;
var
  aSymbol : TSymbol;

begin

  aSymbol := FSymboler.XTerms.Symbol;
  if (aSymbol.Spec.Market <> mtFutures) then
  begin
    gLog.Add(lkWarning , '종합챠트' , '베이시스 추가',
      '죄송 합니다. 다음 종목은 베이시스를 지원하지 않습니다.');

    SetZero;
    //if Assigned(FOnDelete) then
    //  FOnDelete(Self);

    //Self.Free;
  end else
    inherited;
end;

procedure TBasis.TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aSymbol : TSymbol;
  aQuote  : TQuote;
  aData, aTick : TEtcSeriesItem;
  dValue : Double;
  bUpdate : Boolean;
begin
  if (DataObj = nil) then
  begin
{$ifdef Debug}
  gLog.Add(lkDebug, '이상' ,'','');

{$endif}
      Exit;
  end;
  if (FKospi = nil) or (FFuture = nil) then
    begin
{$ifdef Debug}
//  gLog.Add(lkDebug, '이상' ,'','');

{$endif}
      Exit;
  end;

  aQuote := DataObj as TQuote;
  aSymbol := aQuote.Symbol;

  if FEtcReady and (FEtcSeries.Count > 0) then
  begin
    bUpdate := False;
    if FSymboler.XTerms.Base = cbTick then bUpdate := True
    else if aSymbol = FKospi then bUpdate := True;

    if bUpdate then
    begin
      aData := FEtcSeries.Datas[FEtcSeries.Count-1];
      dValue := FFuture.Last - FKospi.Last;

      if not(IsZero(dValue-aData.Value)) then
      begin
        aData.Value := dValue;
        Update;

        if Assigned(FOnAsyncUpdate) then
          FOnAsyncUpdate(Self);
      end;
    end;
  end;


  if not(FEtcReady) then
  begin
    aTick := FEtcSeries.AddTick;
    aTick.T := GetQuoteDate + aQuote.LastEventTime;
    aTick.Value := FFuture.Last - FKospi.Last
  end;
end;

procedure TBasis.UnTicks;
begin
  if FKospi <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self, FKospi );

  if FFuture <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self, FFuture );
end;

procedure TBasis.Update;
begin
  if not(FEtcReady) or (FEtcSeries.Count < 1) or
          (FFuture = nil) or (FKospi = nil) then Exit;

  FEtcSeries[FEtcSeries.Count-1].Value := FFuture.Last - FKospi.Last;

  inherited;
end;

{ TProfitNLoss }

procedure TProfitNLoss.DoInit;
begin
  BAccount   := true;
  FChartType := 14;
  FPrecision := 0;
  Account    := nil;

  Title := 'PL';
  AddParam('Account', '', true);
  AddPlot('PL', psLine, clWhite, 1);
end;

procedure TProfitNLoss.DoPlot;
begin
  Plot(0, PL[0]);
end;

procedure TProfitNLoss.DoPosition;
begin
  gEnv.Engine.TradeBroker.Subscribe( Self, PositionProc);
end;

procedure TProfitNLoss.DoTicks(aSymbol: TSymbol);
begin
  DoPosition;
end;

procedure TProfitNLoss.UnPosition;
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;


procedure TProfitNLoss.RequestEtcData;
var
  i : Integer;
  aItem : TEtcSeriesItem;
begin
  if (Account = nil) or not(FSymboler.XTerms.Ready) then Exit;

  if FSymboler.XTerms.Base in [cbTick] then
  begin
    FEtcSeries.ClearData;

    for i := 0 to FSymboler.XTerms.Count-1 do
      FEtcSeries.AddData;

    FEtcReady := True;
    Remake;

    DoPosition;
  end else
  begin
    if FEtcRequesting then Exit;

    FEtcReady := False;
    FEtcSeries.Reset;

    for i := 0 to FSymboler.XTerms.Count-1 do
    begin
      aItem   := FEtcSeries.AddData;
      aItem.T := FSymboler.XTerms[i].LastTime;
    end;

    for i := 0 to Account.PosTrace.Count - 1 do
      AddPL( Account.PosTrace.PosTraceItems[i] );

    FEtcReady := True;
    Remake;

    DoPosition;
  end;

  FEtcReady := True;

end;

procedure TProfitNLoss.AddPL( aItem : TPosTraceItem );
var
  i :integer;
  aTime : TDateTime;
  //stTmp : String;
begin
  aTime := aItem.PositionHis.Time + GetQuoteDate;

  for I := 0 to FEtcSeries.Count-1 do
  begin;
    if FEtcSeries[i].T >= aTime then
    begin
      FEtcSeries[i].Value := aItem.PositionHis.TotPL - aItem.PositionHis.Fee;
      {                        
      stTmp := Format( '%d :  %s >= %s : %.0f', [ i,
        FormatDateTime('hh:nn:ss.zzz', FEtcSeries[i].T ),
        FormatDateTime('hh:nn:ss.zzz', aTime ),
        FEtcSeries[i].Value
        ]);
      gEnv.DoLog( WIN_TEST, stTmp );
      }
      break;
    end;
  end;
end;

procedure TProfitNLoss.SetObject;
var
  aParam : TParamItem;
  stCode : string;
  aAcnt : TAccount;
begin
  aParam := Params['Account'];

  stCode := aParam.AsAccount;

  if stCode <> '' then
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
    ACcount := aAcnt;
  end;

end;

function TProfitNLoss.SpotData(iBarIndex: Integer): String;
var
  i : Integer;
  aPlot : TPlotItem;
begin
  Result := '';
  if (iBarIndex >=0) and (iBarIndex < FSymboler.XTerms.Count) then
    for i:=0 to FPlots.Count-1 do
    begin
      aPlot := FPlots.Items[i] as TPlotItem;
      if aPlot.Data.Valids[iBarIndex] then
        Result := Result + ' ' + aPlot.Title+ ' :'
              + IntToStrComma(Floor(aPlot.Data.Values[iBarIndex]));
    end;
end;

procedure TProfitNLoss.PositionProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aSymbol : TSymbol;
  aQuote : TQuote;
  aTick, aData : TEtcSeriesItem;
  aPos : TPosition;
  dValue , dPL, df, dopt, ds : double;

begin
  if DataObj = nil then Exit;

  case EventID of
    POSITION_NEW,
    POSITION_UPDATE:;
    else Exit;
  end;

  aPos := DataObj as TPosition ;
  //if aPos.Symbol <> FEtcSeries.Symbol then Exit;
  if aPos.Account <> Account then Exit;

  df :=0; dopt:=0; ds:=0;
  dPL := gEnv.Engine.TradeCore.Positions.GetMarketPl( Account, df, dopt, ds );
  dValue := (dPL / 1000) - (Account.GetFee / 1000);

  if (FSymboler.XTerms.Base = cbTick) and
          (FEtcReady) and (FEtcSeries.Count >0) then
  begin
    aData := FEtcSeries.Datas[FEtcSeries.Count-1];
    if not(IsZero(aData.Value - dValue)) then
    begin
      aData.Value := dValue;
      Update;

      if Assigned(FOnAsyncUpdate) then
        FOnAsyncUpdate(Self);
    end;

  end;

  if not(FEtcReady) then
  begin
    aTick := FEtcSeries.AddTick;
    aTick.T := GetQuoteDate + aQuote.LastEventTime;
    aTick.Value := dPL / 1000;
  end;

end;


procedure TProfitNLoss.Update;
var
    dValue, dPL, df, dopt, ds : double;
begin
  if not(FEtcReady) or (FEtcSeries.Count < 1) then Exit;

  if Account = nil then Exit;

  df :=0; dopt:=0; ds:=0;
  dPL := gEnv.Engine.TradeCore.Positions.GetMarketPl( Account, df, dopt, ds );
  dValue := (dPL / 1000) - (Account.GetFee / 1000);

  FEtcSeries[FEtcSeries.Count-1].Value := dValue;

  inherited;
end;

{ TProfitNLoss2 }

procedure TProfitNLoss2.AddPL(aItem: TPosTraceItem2);
var
  i :integer;
  aTime : TDateTime;
  //stTmp : String;
begin
  aTime := aItem.PositionHis.Time + GetQuoteDate;

  for I := 0 to FEtcSeries.Count-1 do
  begin;
    if FEtcSeries[i].T >= aTime then
    begin
      FEtcSeries[i].Value := aItem.PositionHis.TotPL - aItem.PositionHis.Fee;
      {
      stTmp := Format( '%d :  %s >= %s : %.0f', [ i,
        FormatDateTime('hh:nn:ss.zzz', FEtcSeries[i].T ),
        FormatDateTime('hh:nn:ss.zzz', aTime ),
        FEtcSeries[i].Value
        ]);
      gEnv.DoLog( WIN_TEST, stTmp );
      }
      break;
    end;
  end;

end;

procedure TProfitNLoss2.DoInit;
begin
  BAccount   := true;
  FChartType := 14;
  FPrecision := 0;
  Position   := nil;

  Title := 'Symbol PL';
  AddParam('Account', '', true);
  AddParam('Symbol', '1', true);
  AddPlot('SymbolPL', psLine, clWhite, 1);
end;

procedure TProfitNLoss2.DoPlot;
begin
  Plot(0, SymbolPL[0]);
end;

procedure TProfitNLoss2.DoPosition;
begin
  gEnv.Engine.TradeBroker.Subscribe( Self, PositionProc);

end;

procedure TProfitNLoss2.DoTicks(aSymbol: TSymbol);
begin
  DoPosition;
end;

procedure TProfitNLoss2.PositionProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  aSymbol : TSymbol;
  aQuote : TQuote;
  aTick, aData : TEtcSeriesItem;
  aPos : TPosition;
  dValue , dPL, df, dopt, ds : double;

begin
  if DataObj = nil then Exit;

  case EventID of
    POSITION_NEW,
    POSITION_UPDATE:;
    else Exit;
  end;

  aPos := DataObj as TPosition ;

  if aPos = Position then Exit;

  dValue := (Position.LastPL / 1000) - (Position.GetFee / 1000);

  if (FSymboler.XTerms.Base = cbTick) and
          (FEtcReady) and (FEtcSeries.Count >0) then
  begin
    aData := FEtcSeries.Datas[FEtcSeries.Count-1];
    if not(IsZero(aData.Value - dValue)) then
    begin
      aData.Value := dValue;
      Update;

      if Assigned(FOnAsyncUpdate) then
        FOnAsyncUpdate(Self);
    end;

  end;

  if not(FEtcReady) then
  begin
    aTick := FEtcSeries.AddTick;
    aTick.T := GetQuoteDate + aQuote.LastEventTime;
    aTick.Value := dValue / 1000
  end;


end;

procedure TProfitNLoss2.RequestEtcData;
var
  i : Integer;
  aItem : TEtcSeriesItem;
begin
 // if Position = nil then
 //   Position := gEnv.
  if Position = nil then
    SetObject;

  if (Position = nil) or not(FSymboler.XTerms.Ready) then Exit;

  if FSymboler.XTerms.Base in [cbTick] then
  begin
    FEtcSeries.ClearData;

    for i := 0 to FSymboler.XTerms.Count-1 do
      FEtcSeries.AddData;

    FEtcReady := True;
    Remake;

    DoPosition;
  end else
  begin
    if FEtcRequesting then Exit;

    FEtcReady := False;
    FEtcSeries.Reset;

    for i := 0 to FSymboler.XTerms.Count-1 do
    begin
      aItem   := FEtcSeries.AddData;
      aItem.T := FSymboler.XTerms[i].LastTime;
    end;

    for i := 0 to Position.PosTrace.Count - 1 do
      AddPL( Position.PosTrace.PosTraceItems2[i] );

    FEtcReady := True;
    Remake;

    DoPosition;
  end;

  FEtcReady := True;
end;

procedure TProfitNLoss2.SetObject;
var
  aParam : TParamItem;
  stSymbol, stCode : string;
  aAcnt : TAccount;
  aSymbol : TSymbol;
begin

  aParam := Params['Account'];
  stCode := aParam.AsAccount;
  aParam := Params['Symbol'];
  stSymbol := aParam.AsSymbol;

  if stCode <> '' then
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stSymbol );
    Position := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );

    if (aAcnt <> nil)  and (aSymbol <> nil) and ( Position = nil) then
      Position := gEnv.Engine.TradeCore.Positions.New(aAcnt, aSymbol);
  end;

end;

function TProfitNLoss2.SpotData(iBarIndex: Integer): String;
var
  i : Integer;
  aPlot : TPlotItem;
begin
  Result := '';
  if (iBarIndex >=0) and (iBarIndex < FSymboler.XTerms.Count) then
    for i:=0 to FPlots.Count-1 do
    begin
      aPlot := FPlots.Items[i] as TPlotItem;
      if aPlot.Data.Valids[iBarIndex] then
        Result := Result + ' ' + aPlot.Title+ ' :'
              + IntToStrComma(Floor(aPlot.Data.Values[iBarIndex]));
    end;

end;

procedure TProfitNLoss2.UnPosition;
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TProfitNLoss2.Update;
var
    dValue : double;
begin
  if not(FEtcReady) or (FEtcSeries.Count < 1) then Exit;

  if Position = nil then Exit;

  dValue := (Position.LastPL / 1000) - (Position.GetFee / 1000);

  FEtcSeries[FEtcSeries.Count-1].Value := dValue;

  inherited;

end;

end.

