unit TyIndicator;

interface

uses
  Sysutils, Classes, Graphics, Windows, Math,

  //
  CleSymbols, CleDistributor,  CleQuoteTimers, GleTypes, ClePositions,

  Symbolers, EtcSeries, Indicator,
  ChartIF,
  GleLib
  ;

type

  TAsyncIndicator = class(TIndicator)
  protected

  public

  end;

  TTyIndicator = class(TAsyncIndicator)
  private
    procedure EtcDataReady(Sender : TObject);
    procedure MergeTicks;
    procedure DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                        var iLeft : Integer; bSelected : Boolean); override;
  protected
    FEtcReady : Boolean;
    FEtcRequesting : Boolean;
    FEtcSeries : TEtcSeries;
    FChartType : Integer;

    procedure Remake;
    procedure SetZero;
    procedure TickProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);virtual;abstract;
    procedure DoTicks(aSymbol : TSymbol); virtual; abstract;
    procedure UnTicks;virtual;abstract;

    procedure DoPosition; virtual; abstract;
    procedure UnPosition; virtual; abstract;

  public
    procedure RequestEtcData;virtual;
    procedure Reset;

    procedure Add;override;
    procedure Update;override;
    procedure Refresh(irmValue : TIndicatorRefreshMode); override;

    function Etc: TNumericSeries;
    function PL : TNumericSeries;
    function SymbolPL : TNumericSeries;

    constructor Create(aSymboler : TSymboler);override;
    destructor Destroy;override;
  end;

implementation

uses
  GAppEnv;

{ TTyIndicator }

//------------------------< Start / Finish >-----------------------------//

constructor TTyIndicator.Create(aSymboler: TSymboler);
begin
  inherited Create(aSymboler);

  FEtcSeries := TEtcSeries.Create(TEtcSeriesItem);
  FEtcReady := False;
  FEtcRequesting := False;
end;

destructor TTyIndicator.Destroy;
begin
  if BAccount then
    UnPosition
  else
    UnTicks;

  gChartIF.ReleaseChart(FEtcSeries);

  FEtcSeries.Free;

  inherited;
end;

//----------------------------< Manipulate Data >-----------------------//

procedure TTyIndicator.Add;
var
  aTerm1, aTerm2 : TEtcSeriesItem;
begin
  Inc(FCurrentBar);

  FNumericSeriesStore.Tick;

  //
  aTerm1 := nil;
  aTerm2 := nil;

  if FEtcSeries.Count > 0 then
    aTerm1 := FEtcSeries.Datas[FEtcSeries.Count-1] as TEtcSeriesItem
  else
    aTerm1 := nil;

  aTerm2 := FEtcSeries.AddData;
  aTerm2.T := FSymboler.XTerms[FSymboler.XTerms.Count-1].LastTime;

  if aTerm1 = nil then
    aTerm2.Value := 0.0
  else
    aTerm2.Value := aTerm1.Value;

  if BAccount then
    Update
  else
    DoPlot;
end;

procedure TTyIndicator.Update;
begin
  //
  Etc;
  DoPlot;
end;

procedure TTyIndicator.Refresh(irmValue : TIndicatorRefreshMode);
begin
  if (irmValue = irmHot) or ((irmValue <> irmHot) and not(FEtcReady)) then
  //if not(FEtcReady) then
  begin
    SetZero;

    RequestEtcData;
  end else
    Remake;
end;

//-------------------------< Get Data from the server >-----------------//

procedure TTyIndicator.Reset;
begin
  FEtcReady := False;
end;

procedure TTyIndicator.RequestEtcData;
var
  iMultiple, iMinPeriod, iDayCount, iMinCount : Integer;
  dtLastTime : TDateTime;
  wHH, wNN, wSS, wMS : Word;

begin
  if FEtcRequesting then Exit;

  FEtcReady := False;
  FEtcSeries.Reset;
  FEtcSeries.OnReady := EtcDataReady;

  DoTicks(FSymboler.XTerms.Symbol);
  FEtcSeries.Symbol := FSymboler.XTerms.Symbol;

  with FSymboler.XTerms do
  begin
    iMinPeriod := gChartIF.GetBase(Base, Period);
    iMultiple := Period div iMinPeriod;

    case Base of
      cbWeekly :  iDayCount := 5;
      cbMonthly : iDayCount := 25;
      cbTick :
        if Count > 0 then
        begin
          dtLastTime := GetQuotetime;
          DecodeTime(dtLastTime, wHH, wNN, wSS, wMS);
          iMinCount := (wHH - 9)*60 + wNN + 2;
        end;
      else
        begin
         iDayCount := 1;
         iMinCount := 1;
        end;
    end;

    FEtcRequesting := True;

    if Base <> cbTick then
      gChartIF.GetEtcChart(FEtcSeries, Symbol, Base, iMinPeriod{Period},
            Count * iMultiple * iDayCount{Count}, FChartType)
    else
      gChartIF.GetEtcChart(FEtcSeries, Symbol, Base, iMinPeriod{Period},
            iMinCount, FChartType);

  end;
end;



procedure TTyIndicator.EtcDataReady(Sender: TObject);
var
  i : Integer;
  aDataItem, aTermItem : TEtcSeriesItem;

begin
  //
  if (Sender <> FEtcSeries) or not(FEtcSeries.Ready) then
  begin
    gLog.Add(lkError, 'TyIndicator' , 'EtcDataReady','');
    Exit;
  end;

  //sync between XTerms to EtcSeries
  FEtcSeries.ClearData;
  for i := 0 to FSymboler.XTerms.Count-1 do
  begin
    aDataItem := FEtcSeries.AddData;
    aDataItem.T := FSymboler.XTerms[i].LastTime;

    aTermItem := FEtcSeries.FindTerm(aDataItem.T,
                              FSymboler.XTerms.Base, FSymboler.XTerms.Period);

    if aTermItem = nil then
    begin
      if i > 0 then
        aDataItem.Value := FEtcSeries.Datas[i-1].Value;
      Continue;
    end;
    aDataItem.Value := aTermItem.Value;
    FEtcSeries.DeleteTerm(aTermItem);
  end;
{$ifdef Debug}
//  if Title = '베이시스' then
//    for i := 0 to FEtcSeries.Count-1 do
//      gLog.Add(lkDebug, Format('%.2f',[FEtcSeries[i].Value]),'','');

{$endif}

  MergeTicks;
  FEtcSeries.ClearTicks;
  FEtcReady := True;
  FEtcRequesting := False;

  //Refresh(irmHot);

  Remake;

end;

procedure TTyIndicator.MergeTicks;
var
  i : Integer;
  aTick, aTerm : TEtcSeriesItem;

begin
  //gLog.Add(lkDebug,'tick count',IntToStr(FEtcSeries.TickCount),'');
  for i := 0 to FEtcSeries.TickCount-1 do
  begin
    aTick := FEtcSeries.Ticks[i];
    aTerm := FEtcSeries.FindData(aTick.T, FSymboler.XTerms.Base,
                                                  FSymboler.XTerms.Period);
    if aTerm <> nil then
      aTerm.Value := aTick.Value
    else
      //gLog.Add(lkDebug, 'not tick','','');
  end;

end;

//---------------------------< Refering Data >-----------------------//

function TTyIndicator.PL: TNumericSeries;
begin
  if FEtcSeries = nil then Exit;

  Result := NumericSeries('PL');
  if (FCurrentBar >= 1) and (FEtcSeries.Count >= FCurrentBar) then
    Result[0] := FEtcSeries.Datas[FCurrentBar-1].Value;
end;



function TTyIndicator.Etc: TNumericSeries;
begin
  if FEtcSeries = nil then Exit;

  Result := NumericSeries('Etc');
  if (FCurrentBar >= 1) and (FEtcSeries.Count >= FCurrentBar) then
    Result[0] := FEtcSeries.Datas[FCurrentBar-1].Value;
end;


function TTyIndicator.SymbolPL: TNumericSeries;
begin
  if FEtcSeries = nil then Exit;

  Result := NumericSeries('SymbolPL');
  if (FCurrentBar >= 1) and (FEtcSeries.Count >= FCurrentBar) then
    Result[0] := FEtcSeries.Datas[FCurrentBar-1].Value;
end;

//-------------------------< Draw >--------------------------------//

procedure TTyIndicator.DrawTitle(const aCanvas: TCanvas;
  const aRect: TRect; var iLeft: Integer; bSelected: Boolean);
var
  i : Integer;
  dValue : Double;
  stTmp, stText, stValue : String;
  aSize : TSize;
  aFontColor : TColor;
  aFontStyle : TFontStyles;
begin
  //
  aFontColor := aCanvas.Font.Color;
  aFontStyle := aCanvas.Font.Style;
  //
  if FPlots.Count > 0 then
    aCanvas.Font.Color := (FPlots.Items[0] as TPlotItem).Color;
  if bSelected then
    aCanvas.Font.Style := aCanvas.Font.Style + [fsBold];

  //
  stText := GetTitle;

  if stText = 'Symbol PL' then
    if FParams.Count > 0 then
    begin
      stText := stText + '( ';
      for i:=0 to FParams.Count-1 do
      begin
        if i > 0 then
          stText := stText + ', ';

        stTmp := (FParams.Items[i] as TParamItem).AsString;
        case (FParams.Items[i] as TParamItem).ParamType of
          ptAccount :
            if stTmp <> '' then
              stTmp := Copy( stTmp, Length( stTmp ) - 3, 4);
          ptSymbol :
            if stTmp <> '' then
              stTmp := Copy( stTmp, 4, Length( stTmp )- 4 );
        end;
        stText := stText + stTmp;
      end;
      stText := stText + ' )';
    end;

  if stText = 'PL' then
    if FParams.Count > 0 then
    begin
      stText := stText + '( ';
      for i:=0 to FParams.Count-1 do
      begin
        stTmp := (FParams.Items[i] as TParamItem).AsString;
        if stTmp <> '' then
          stTmp := Copy( stTmp, Length( stTmp ) - 3, 4);
        stText := stText + stTmp;
      end;
      stText := stText + ' )';
    end;
  //
  stValue := '';
  if FPlots.Count > 0 then
  begin
    dValue := (FPlots.Items[0] as TPlotItem).Data[0];
    if FPrecision = 0 then
      stValue := IntToStrComma(Floor(dValue))
    else
      stValue := Format('%.*f',[FPrecision, dValue]);
  end;
  stText := stText +'=' + stValue;

    //stText := stText + ' : ' + IntToStrComma(Floor((FPlots.Items[0] as TPlotItem).Data[0]));

  aSize := aCanvas.TextExtent(stText);
  aCanvas.TextOut(iLeft+5, aRect.Top - aSize.cy, stText);
//  aCanvas.TextRect(Rect(aRect.Left,aRect.Top-aSize.cy, aRect.Right, aRect.Top),
//                   iLeft+5, aRect.Top - aSize.cy, stTitle);
  //
  iLeft := iLeft + 5 + aSize.cx;
  //
  //
  aCanvas.Font.Color := aFontColor;
  aCanvas.Font.Style := aFontStyle;

end;

procedure TTyIndicator.SetZero;
begin
  FEtcSeries.ClearData;
  FEtcReady := True;
  //Refresh(irmHot);
  Remake;
end;



procedure TTyIndicator.Remake;
begin
  ClearPlotData;
  FNumericSeriesStore.Clear;
  FCurrentBar := 0;

  while FCurrentBar < FSymboler.XTerms.Count do
  begin
    Inc(FCurrentBar);

    FNumericSeriesStore.Tick;
    //
    Etc;

    DoPlot;
  end;

  if Assigned(FOnAsyncRefresh) then
    FOnAsyncRefresh(Self);
end;

end.

