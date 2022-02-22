unit Indicators2;

interface

uses
  Classes, Graphics, Forms, Math,
  //
  Charters, Indicator, Symbolers, XTerms, GleTypes, GleConsts;

type

  { Directional Movement Index }

  TDMI = class(TIndicator)
  protected
    function TrueHigh : Double;
    function TrueLow : Double;
    function TrueRange : TNumericSeries;
    function DMI(Key : String; Length : Integer) : TNumericSeries;
    function ADX(Key : String; Length : Integer) : TNumericSeries;
    function DMIPlus(Key : String; Length : Integer) : TNumericSeries;
    function DMIMinus(Key : String; Length : Integer) : TNumericSeries;

    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;


  { RSI }

  TRSI = class(TIndicator)
  protected
    function RSI(Key : String; Price : TNumericSeries; Length : Integer) : TNumericSeries;
    //
    function Price : String;
    function Length : Integer;
    function BuyZone : Double;
    function SellZone : Double;
    function SignalLen : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Stochastic }

  TStochastic = class(TIndicator)
  protected
    function SlowKClassic(Key : String; FastKLen, Length : Integer) : TNumericSeries;
    function SlowDClassic(Key : String; FastKLen, iLength : Integer) : TNumericSeries;
    function FastDClassic(Key : String; KLength : Integer) : TNumericSeries;
    function FastK(Key : String; Length : Integer) : TNumericSeries;
    //
    function Length : Integer;
    function KAdjust : Integer;
    function DAdjust : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Stochastic Slow }

  TStochasticSlow = class(TIndicator)
  protected
    function SlowKCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer ) : TNumericSeries;
    function SlowDCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer ) : TNumericSeries;
    function FastDCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer) : TNumericSeries;
    function FastKCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer) : TNUmericSeries;

    function HighValue : TNumericSeries;
    function LowValue : TNumericSeries;
    function CloseValue : TNumericSeries;
    function Length : Integer;
    function OverSold : Double;
    function OverBought : Double;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { On Balance Volume }

  TOBV = class(TIndicator)
  protected
    function OBV : TNumericSeries;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Bollinger Bands }

  TBollinger = class(TIndicator)
  protected
    function BollingerBand(Key : String; Price : TNumericSeries; Length : Integer;
            StandardDev : Double) : TNumericSeries;
    //
    function Price : TNumericSeries;
    function Length : Integer;
    function StdDevUp : Double;
    function StdDevDn : Double;
    function Displace : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Rate of Change }

  TRoc = class(TIndicator)
  protected
    function RateOfChange(Key : String; Price : TNumericSeries; Length : Integer ) : TNumericSeries;

    function Price : TNumericSeries;
    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Percent R }

  TPercentR = class(TIndicator)
  protected
    function PercentR(Key : String; Length : Integer ) : TNumericSeries;

    function Length : Integer;
    function BuyZone : Double;
    function SellZone : Double;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { TRIX }

  TTrix = class(TIndicator)
  protected
    function Log(Key : String; Price : TNumericSeries ) : TNumericSeries;
    function Trix(Key : String; Price : TNumericSeries; Length : Integer ) : TNumericSeries;

    function Price : TNumericSeries;
    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { 이격도  }

  TDisparity = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { MidPoint }

  TMidPoint = class(TIndicator)
  protected
    function Price : TNumericSeries;
    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

implementation



//====================================================================//
              { Directional Movement Index }
//====================================================================//

function TDMI.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TDMI.DoInit;
begin
  Title := 'DMI';
  //
  AddParam('Length', 14);
  //
  AddPlot('DMI+', psLine, clRed, 1);
  AddPlot('DMI-', psLine, clBlue, 1);
  AddPlot('ADX', psLine, clYellow, 1);
end;

procedure TDMI.DoPlot;
begin
  if CurrentBar > Length then
  begin
    Plot(0, DMIPlus('DMI', Length)[0]);
    Plot(1, DMIMinus('DMI', Length)[0]);
    Plot(2, ADX('DMI', Length)[0]);
  end else
  begin
    DMIPlus('DMI', Length);
    DMIMinus('DMI', Length);
    ADX('DMI', Length);
  end;
end;

function TDMI.TrueHigh : Double;
begin
  if Close[1] > High[0] then
    TrueHigh := Close[1]
  else
    TrueHigh := High[0];
end;

function TDMI.TrueLow : Double;
begin
  if Close[1] < Low[0] then
    TrueLow := CLose[1]
  else
    TrueLow := Low[0];
end;

function TDMI.TrueRange : TNumericSeries;
begin
  TrueRange := NumericSeries('TrueRange');
  //
  TrueRange[0] := TrueHigh - TrueLow;
end;

function TDMI.DMI(Key : String; Length : Integer) : TNumericSeries;
var
  DMIP, DMIM : Double;
begin
  DMI := NumericSeries(Key + 'DMI');
  //
  DMIP := DMIPlus(Key+'DMI', Length)[0];
  DMIM := DMIMinus(Key+'DMI', Length)[0];
  //
  if Abs(DMIP + DMIM) < ZERO then
    DMI[0] := 0
  else
    DMI[0] := 100 * Abs(DMIP - DMIM) / (DMIP + DMIM);
end;

function TDMI.ADX(Key : String; Length : Integer) : TNumericSeries;
var
  Counter : Integer;
  CummDMI, Return : Double;
begin
  ADX := NumericSeries(Key + 'ADX');
  //
  Return := 0;
  
  if (CurrentBar >= 1) and (Length > 0) then
  begin
    if CurrentBar < Length then
    begin
      CummDMI := 0;
      for Counter := 0 to CurrentBar - 1 do
        CummDMI := CummDMI + DMI(Key + 'ADX', Length)[Counter];
      Return := CummDMI / CurrentBar;
    end else
      Return := (Result[1] * (Length-1) + DMI(Key+'ADX', Length)[0]) / Length;
  end;
  //
  ADX[0] := Return;
end;

function TDMI.DMIPlus(Key : String; Length : Integer) : TNumericSeries;
var
  Counter, MyRange : Integer;
  PlusDM, MinusDM : Double;
  TRange, PlusDM14 : TNumericSeries;
begin
  DMIPlus := NumericSeries(Key + 'DMIPlus');
  TRange := NumericSeries(Key + 'DMIPlusTRange');
  PlusDM14 := NumericSeries(Key + 'DMIPlusPlusDM14');
  //
  MyRange := Length;
  //-- modification on TS logic
  if CurrentBar < Length+1 then
  begin
    TrueRange;
  end else
  //---------------------------
//  if CurrentBar = 1 then
  if CurrentBar = Length+1 then
  begin
    MyRange := Length;
    DMIPlus[0] := 0;
    PlusDM14[0] := 0;
    TRange[0] := 0;
    //
    for Counter :=0 to MyRange - 1 do
    begin
      if High[Counter] - High[Counter+1] < 0 then
        PlusDM := 0
      else
        PlusDM := High[Counter] - High[Counter+1];
      if Low[Counter+1] - Low[Counter] < 0 then
        MinusDM := 0
      else
        MinusDM := Low[Counter+1] - Low[Counter];
      if MinusDM >= PlusDM then
        PlusDM := 0;
      //
      TRange[0] := TRange[0] + TrueRange[Counter];
      PlusDM14[0] := PlusDM14[0] + PlusDM;
    end;
    if Abs(TRange[0]) > ZERO then
      DMIPlus[0] := 100 * PlusDM14[0] / TRange[0]
    else
      DMIPlus[0] := 0;
  end else
  if CurrentBar > Length+1 then
  //if CurrentBar > 1 then
  begin
    if High[0] - High[1] < 0 then
      PlusDM := 0
    else
      PlusDM := High[0] - High[1];
    if Low[1] - Low[0] < 0 then
      MinusDM := 0
    else
      MinusDM := Low[1] - Low[0];
    if MinusDM >= PlusDM then
      PlusDM := 0;
     //
    if MyRange > 0 then
    begin
      TRange[0] := TRange[1] - (TRange[1] / MyRange) + TrueRange[0];
      PlusDM14[0] := PlusDM14[1] - (PlusDM14[1] / MyRange) + PlusDM;
    end;
    if Abs(TRange[0]) > ZERO then
      DMIPlus[0] := 100 * PlusDM14[0] / TRange[0]
    else
      DMIPlus[0] := 0;
  end;
end;

function TDMI.DMIMinus(Key : String; Length : Integer) : TNumericSeries;
var
  Counter, MyRange : Integer;
  MinusDM, PlusDM : Double;
  TRange, MinusDM14 : TNumericSeries;
begin
  DMIMinus := NumericSeries(Key + 'DMIMinus');
  TRange := NumericSeries(Key + 'DMIMinusTRange');
  MinusDM14 := NumericSeries(Key + 'DMIMinusMinusDM14');
  //
  MyRange := Length;
  //-- modification on TS logic
  if CurrentBar < Length+1 then
  begin
    TrueRange;
  end else
  //---------------------------
  //
  if CurrentBar = Length+1 then
//  if CurrentBar = 1 then
  begin
    MyRange := Length;
    DMIMinus[0] := 0;
    MinusDM14[0] := 0;
    TRange[0] := 0;
    for Counter := 0 to MyRange-1 do
    begin
      if High[Counter] - High[Counter+1] < 0 then
        PlusDM := 0
      else
        PlusDM := High[Counter] - High[Counter + 1];
      if Low[Counter + 1] - Low[Counter] < 0 then
        MinusDM := 0
      else
        MinusDM := Low[Counter + 1] - Low[Counter];

      if PlusDM >= MinusDM then
        MinusDM := 0;
      //
      TRange[0] := TRange[0] + TrueRange[Counter];
      MinusDM14[0] := MinusDM14[0] + MinusDM;
    end;
    if Abs(TRange[0]) > ZERO then
      DMIMinus[0] := 100 * MinusDM14[0] / TRange[0]
    else
      DMIMinus[0] := 0;
  end else
  if CurrentBar > Length+1 then
//  if CurrentBar > 1 then
  begin
    if High[0] - High[1] < 0 then
      PlusDM := 0
    else
      PlusDM := High[0] - High[1];
    If Low[1] - Low [0] < 0 Then
      MinusDM := 0
    else
      MinusDM := Low[1] - Low[0];
    If PlusDM >= MinusDM Then
      MinusDM := 0 ;
    //
    if MyRange > 0 then
    begin
      TRange[0] := TRange[1] - (TRange[1] / MyRange) + TrueRange[0];
      MinusDM14[0] := MinusDM14[1] - (MinusDM14[1] / MyRange) + MinusDM;
    end;
    if Abs(TRange[0]) > ZERO Then
      DMIMinus[0] := 100 * MinusDM14[0] / TRange[0]
    else
      DMIMinus[0] := 0;
  end;
end;



//====================================================================//
     { Relative Strength Indicator }
//====================================================================//

function TRSI.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TRSI.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TRSI.BuyZone : Double;
begin
  Result := Params['BuyZone'].AsFloat;
end;

function TRSI.SellZone : Double;
begin
  Result := Params['SellZone'].AsFloat;
end;

function TRSI.SignalLen : Integer;
begin
  Result := Params['SignalLen'].AsInteger;
end;

procedure TRSI.DoInit;
begin
  Title := 'RSI';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 14);
  AddParam('SignalLen', 9);
  AddParam('BuyZone', 0, 30);
  AddParam('SellZone', 0, 70);
//  AddParam('BZColor', 'Green');
//  AddParam('SZColor', 'Magenta');
  //
  AddPlot('RSI', psLine, clYellow, 1);
  AddPlot('BuyZone', psLine, clRed, 1);
  AddPlot('SellZone', psLine, clBlue, 1);
  AddPlot('FiftyLine', psLine, clGray, 1);
  AddPlot('SignalLine', psLine, clGreen, 1);
end;

procedure TRSI.DoPlot;
begin
  Plot(0, RSI('RSI', Expression(Price), Length)[0]);
  Plot(1, BuyZone);
  Plot(2, SellZone);
  Plot(3, 50);
  Plot(4, AverageFC('RSI', RSI('RSI', Expression(Price), Length), SignalLen)[0]);

  {
  if Plot1 > SellZone then
    SetPlotColor(1, SZColor)
  else if Plot1 < BuyZone then
    SetPlotColor(1, BZColor);
  }
end;

function TRSI.RSI(Key : String; Price : TNumericSeries; Length : Integer) : TNumericSeries;
var
  Counter : Integer;
  DownAmt, UpAmt, UpSum, DownSum : Double;
  UpAvg, DownAvg : TNumericSeries;
begin
  RSI := NumericSeries(Key + 'RSI');
  UpAvg := NumericSeries(Key + 'RSIUpAvg');
  DownAvg := NumericSeries(Key + 'RSIDownAvg');
  //
  if (CurrentBar = 1) and (Length > 0) then
  begin
    UpSum := 0;
    DownSum := 0;
    for Counter := 0 to Length - 1 do
    begin
      UpAmt := Price[Counter] - Price[Counter + 1];
      if UpAmt >= 0 then
        DownAmt := 0
      else
      begin
        DownAmt := -UpAmt;
        UpAmt := 0;
      end;
      UpSum := UpSum + UpAmt;
      DownSum := DownSum + DownAmt;
    end;
    UpAvg[0] := UpSum / Length;
    DownAvg[0] := DownSum / Length;
  end else
  if (CurrentBar > 1) and (Length > 0) then
  begin
    UpAmt := Price[0] - Price[1];
    if UpAmt >= 0 then
      DownAmt := 0
    else
    begin
      DownAmt := -UpAmt;
      UpAmt := 0;
    end;
    UpAvg[0] := (UpAvg[1] * (Length-1) + UpAmt) / Length;
    DownAvg[0] := (DownAvg[1] * (Length-1) + DownAmt) / Length;
  end;
  //
  if UpAvg[0] + DownAvg[0] <> 0 then
    RSI[0] := 100 * UpAvg[0] / (UpAvg[0] + DownAvg[0])
  else
    RSI[0] := 0;
end;

//====================================================================//
          { Stochastic Classic}
//====================================================================//


function TStochastic.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TStochastic.KAdjust : Integer;
begin
  Result := Params['KAdjust'].AsInteger;
end;

function TStochastic.DAdjust : Integer;
begin
  Result := Params['DAdjust'].AsInteger;
end;

procedure TStochastic.DoInit;
begin
  Title := 'Stochastic Classic';
  //
  AddParam('Length', 5);
  AddParam('KAdjust', 3);
  AddParam('DAdjust', 3);
  AddParam('OverBought', 0, 80);
  AddParam('OverSold', 0, 20);
  //
  AddPlot('%K', psLine, clYellow, 1);
  AddPlot('%d', psLine, clGreen, 1);
  AddPlot('OverBought', psLine, clRed, 1);
  AddPlot('OverSold', psLine, clBlue, 1);
end;

procedure TStochastic.DoPlot;
begin
  if CurrentBar > Length then
  begin
    Plot(0, SlowKClassic('Stochastic', KAdjust, Length)[0]);
    Plot(1, SlowDClassic('Stochastic', DAdjust, Length)[0]);
  end;
  Plot(2, Params['OverBought'].AsFloat);
  Plot(3, Params['OverSold'].AsFloat);
end;

function TStochastic.SlowKClassic(Key : String; FastKLen, Length : Integer) : TNumericSeries;
begin
  SlowKClassic := NumericSeries(Key + 'SlowKClassic');
  //
  SlowKClassic[0] := Average(Key + 'SlowKClassic',
                             FastK(Key + 'SlowKClassic', FastKLen),
                             Length)[0];
end;

function TStochastic.SlowDClassic(Key : String; FastKLen, iLength : Integer) : TNumericSeries;
begin
  SlowDClassic := NumericSeries(Key + 'SlowDClassic');
  //
  SlowDClassic[0] := Average(Key + 'SlowKClassic',
                             FastDClassic(Key + 'SlowKClassic', FastKLen),
                             Length)[0];
end;

function TStochastic.FastDClassic(Key : String; KLength : Integer) : TNumericSeries;
begin
  FastDClassic := NumericSeries(Key + 'FastDClassic');
  //
  FastDClassic := Average(Key + 'FastDClassic',
                          FastK(Key + 'FastDClassic', KLength), 3);
end;

function TStochastic.FastK(Key : String; Length : Integer) : TNumericSeries;
var
  Value1, Value2, Value3 : Double;
begin
  FastK := NumericSeries(Key + 'FastK');
  //
  Value1 := Lowest(Low, Length);
  Value2 := Highest(High, Length) - Value1;
  Value3 := Close[0];

  if Value2 > 0 then
    FastK[0] := (Value3 - Value1) / Value2 * 100
  else
    FastK[0] := 0;
end;

//====================================================================//
          { Stochastic Slow}
//====================================================================//


function TStochasticSlow.HighValue : TNumericSeries;
begin
  Result := Expression(Params['HighValue'].AsString);
end;

function TStochasticSlow.LowValue : TNumericSeries;
begin
  Result := Expression(Params['LowValue'].AsString);
end;

function TStochasticSlow.CloseValue : TNumericSeries;
begin
  Result := Expression(Params['CloseValue'].AsString);
end;

function TStochasticSlow.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TStochasticSlow.OverSold : Double;
begin
  Result := Params['OverSold'].AsFloat;
end;

function TStochasticSlow.OverBought : Double;
begin
  Result := Params['OverBought'].AsFloat;
end;


procedure TStochasticSlow.DoInit;
begin
  Title := 'Stochastic Slow';
  //
  AddParam('HighValue', 'High');
  AddParam('LowValue', 'Low');
  AddParam('CloseValue', 'Close');
  AddParam('Length', 5);
  AddParam('OverBought', 0, 80);
  AddParam('OverSold', 0, 20);
  //
  AddPlot('SlowK', psLine, clYellow, 1);
  AddPlot('SlowD', psLine, clGreen, 1);
  AddPlot('OverBought', psLine, clRed, 1);
  AddPlot('OverSold', psLine, clBlue, 1);
end;

procedure TStochasticSlow.DoPlot;
begin
  Plot(0, SlowKCustom('StochasticSlow', HighValue, LowValue, CloseValue, Length)[0]);
  Plot(1, SlowDCustom('StochasticSlow', HighValue, LowValue, CloseValue, Length)[0]);
  Plot(2, OverBought );
  Plot(3, OverSold );
end;

function TStochasticSlow.SlowKCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer ) : TNumericSeries;
begin
  SlowKCustom := NumericSeries(Key + 'SlowKCustom');
  //
  SlowKCustom[0] := FastDCustom(Key + 'SlowKCustom', HighVal, LowVal, CloseVal, Length)[0];
end;

function TStochasticSlow.SlowDCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer ) : TNumericSeries;
begin
  SlowDCustom := NumericSeries(Key + 'SlowDCustom');

  if CurrentBar <= 1 then
    SlowDCustom[0] := FastDCustom(Key + 'SlowDCustom', HighVal, LowVal, CloseVal, Length)[0]
  else
    SlowDCustom[0] := (Result[1] * 2 + FastDCustom(Key + 'SlowDCustom', HighVal, LowVal, CloseVal, Length)[0]) / 3;
end;

function TStochasticSlow.FastDCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer) : TNumericSeries;
var
  Factor : Double;
begin
  FastDCustom := NumericSeries(Key + 'FastDCustom');

  Factor := 0.5;

  if CurrentBar <= 1 then
    FastDCustom[0] := FastKCustom(Key + 'FastDCustom', HighVal, LowVal, CloseVal, Length)[0]
  else
    FastDCustom[0] := Result[1] + Factor * (FastKCustom(Key + 'FastDCustom', HighVal, LowVal, CloseVal, Length)[0] - Result[1]);
end;

function TStochasticSlow.FastKCustom(Key : String; HighVal, LowVal, CloseVal : TNumericSeries; Length : Integer) : TNUmericSeries;
var
  Value1, Value2 : Double;
begin
  FastKCustom := NumericSeries(Key + 'FastKCustom');

  Value1 := Lowest(LowVal, Length );
  Value2 := Highest(HighVal, Length) - Value1;

  if Value2 > 0 then
    FastKCustom[0] := (CloseVal[0] - Value1) / Value2 * 100.0
  else
    FastKCustom[0] := 0;
end;

//====================================================================//
          { On Balance Volume }
//====================================================================//

procedure TOBV.DoInit;
begin
  Title := 'OBV';
  //
  AddPlot('OBV', psLine, clBlue, 1);
end;

procedure TOBV.DoPlot;
begin
  Plot(0, OBV[0]);
end;

function TOBV.OBV : TNumericSeries;
begin
  OBV := NumericSeries('OBV');
  //
  if CurrentBar > 0 then
  begin
    if Close[0] > Close[1] then
      OBV[0] := Result[1] + Volume[0]
    else
    if Close[0] < Close[1] then
      OBV[0] := Result[1] - Volume[0]
    else
      OBV[0] := Result[1];
  end else
    OBV[0] := 0;
end;

//====================================================================//
            { Bollinger Bands }
//====================================================================//

function TBollinger.Price : TNumericSeries;
begin
  Result := Expression(Params['Price'].AsString);
end;

function TBollinger.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TBollinger.StdDevUp : Double;
begin
  Result := Params['StdDevUp'].AsFloat;
end;

function TBollinger.StdDevDn : Double;
begin
  Result := Params['StdDevDn'].AsFloat;
end;

function TBollinger.Displace : Integer;
begin
  Result := Params['Displace'].AsInteger;
end;


procedure TBollinger.DoInit;
begin
  Title := 'Bollinger Band';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('StdDevUp', 0, 2);
  AddParam('StdDevDn', 0, -2);
  AddParam('Displace', 0);
  //
  AddPlot('BollTop', psLine, clBlue, 1);
  AddPlot('BollBot', psLine, clBlue, 1);
end;

procedure TBollinger.DoPlot;
var
  BBTop, BBBot : Double;
begin
  BBTop := BollingerBand('Bollinger', Price, Length, StdDevUp)[0];
  BBBot := BollingerBand('Bollinger', Price, Length, StdDevDn)[0];
  //
  if (Displace >= 0) or (CurrentBar > Abs(Displace)) then
  begin
    Plot(0, BBTop, Displace);
    Plot(1, BBBot, Displace);
  end;
end;

function TBollinger.BollingerBand(Key : String; Price : TNumericSeries; Length : Integer;
            StandardDev : Double) : TNumericSeries;
begin
  BollingerBand := NumericSeries(Key + 'BollingerBand');
  //
  BollingerBand[0] := Average(Key + 'Bollinger', Price, Length)[0] +
                      StandardDev * StdDev(Key + 'Bollinger', Price, Length)[0];
end;

//====================================================================//
            { Rate of Change }
//====================================================================//

function TRoc.Price : TNumericSeries;
begin
  Result := Expression(Params['Price'].AsString);
end;

function TRoc.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TRoc.DoInit;
begin
  Title := 'ROC';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 10);

  AddPlot('ROC', psLine, clBlue, 1);
  AddPlot('ZeroLine', psLine, clGray, 1);
end;

procedure TRoc.DoPlot;
begin
  Plot(0, RateOfChange('ROC', Price, Length)[0]);
  Plot(1, 0);
end;

function TRoc.RateOfChange(Key : String; Price : TNumericSeries; Length : Integer ) : TNumericSeries;
begin
  RateOfChange := NumericSeries( Key + 'RateOfChange');

  if Price[Length] <> 0 then
    RateOfChange[0] := (Price[0]/Price[Length]-1) * 100
  else
    RateOfChange[0] := 0;
end;

//====================================================================//
             { Percent R }
//====================================================================//


function TPercentR.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TPercentR.BuyZone : Double;
begin
  Result := Params['BuyZone'].AsFloat;
end;

function TPercentR.SellZone : Double;
begin
  Result := Params['SellZone'].AsFloat;
end;

procedure TPercentR.DoInit;
begin
  Title := 'Percent R';
  //
  AddParam('Length', 10);
  AddParam('BuyZone', 0, 20);
  AddParam('SellZone', 0, 80);

  AddPlot('PercentR', psLine, clBlue, 1);
  AddPlot('BuyZone', psLine, clRed, 1);
  AddPlot('SellZone', psLine, clYellow, 1);
  AddPlot('FiftyLine', psLine, clGray, 1);
end;

procedure TPercentR.DoPlot;
begin
  Plot(0, PercentR('TPercentR', Length)[0] );
  Plot(1, BuyZone);
  Plot(2, SellZone);
  Plot(3, 50);
end;

function TPercentR.PercentR(Key : String; Length : Integer ) : TNumericSeries;
var
  HiLoDiff : Double;
begin
  PercentR := NumericSeries(Key + 'PercentR');

  HiLoDiff := Highest(High, Length) - Lowest(Low, Length);

  if HiLoDiff <> 0 then
    PercentR[0] := 100-((Highest(High, Length) - Close[0]) / HiLoDiff) * 100
  else
    PercentR[0] := 0;
end;


//====================================================================//
            { TRIX }
//====================================================================//

function TTRix.Price : TNumericSeries;
begin
  Result := Expression(Params['Price'].AsString);
end;

function TTrix.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TTrix.DoInit;
begin
  Title := 'TRIX';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 18);

  AddPlot('TRIX', psLine, clRed, 1);
  AddPlot('Zero', psLine, clGray, 1);
end;

procedure TTrix.DoPlot;
begin
  if CurrentBar > 1 then
    Plot(0, Trix('TTrix', Price, Length)[0]);

  Plot(1, 0);
end;

function TTrix.Log(Key : String; Price : TNumericSeries ) : TNumericSeries;
begin
  Log := NumericSeries(Key + 'Log');
  Log[0] := Ln(Price[0]);
end;

function TTrix.Trix(Key : String; Price : TNumericSeries; Length : Integer ) : TNumericSeries;
var
  TripleXAvg : TNumericSeries;
begin
  Trix := NumericSeries(Key + 'Trix');
  TripleXAvg := NumericSeries(Key + 'TripleXAvg');

  if Length <> 0 then
  begin
    TripleXAvg[0] := XAverage(Key+'Trix1', XAverage(Key+'Trix2', XAverage(Key+'Trix3', Log(Key+'Trix4', Price), Length), Length), Length)[0];
    Trix[0] := (TripleXAvg[0]-TripleXAvg[1]) * 10000;
  end
  else
    Trix[0] := 0;
end;

//====================================================================//
             { 이격도 }
//====================================================================//

function TDisparity.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TDisparity.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TDisparity.DoInit;
begin
  Title := '이격도';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  //
  AddPlot('이격도', psLine, clRed, 1);
  AddPlot('100%', psLine, clGray, 1);
end;

procedure TDisparity.DoPlot;
var
  MA : Double;
begin
  MA := AverageFC('DoPlot', Expression(Price), Length)[0];

  if (CurrentBar > Length) and
     ((MA > PRICE_EPSILON) or (MA < -PRICE_EPSILON))then
    Plot(0, Close[0]*100/MA);

  Plot(1, 100);
end;


//====================================================================//
            { MidPoint }
//====================================================================//

function TMidPoint.Price : TNumericSeries;
begin
  Result := Expression(Params['Price'].AsString);
end;

function TMidPoint.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TMidPoint.DoInit;
begin
  Title := 'MidPoint';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 10);

  AddPlot('MidPoint', psLine, clBlue, 1);
end;

procedure TMidPoint.DoPlot;
begin
  if CurrentBar > Length then
  begin
    Plot(0, (Highest(Price, Length)+Lowest(Price,Length))/2);
  end;
end;


end.

