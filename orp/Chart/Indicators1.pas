unit Indicators1;

interface

uses
  Classes, Graphics, Forms, Math,
  //
  Charters, Indicator, Symbolers, XTerms, GleTypes, GleConsts;

type

  { Volume }

  TVolume = class(TIndicator)
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Volume Average}
  TVolumeMA = class(TIndicator)
  protected
    function AvgLength : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Moving Average }

  TMA = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    function Displace : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Moving Average 2 Lines }

  TMA2 = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    function Length2 : Integer;
    function Displace : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Moving Average 3 Lines }

  TMA3 = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    function Length2 : Integer;
    function Length3 : Integer;
    function Displace : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;


  { Moving Average Convergent & Divergence }

  TMACD = class(TIndicator)
  protected
    function FastMA : Integer;
    function SlowMA : Integer;
    function MacdMA : Integer;
    //
    function MACD(Key : String; Price : TNumericSeries;
                  FastMA, SlowMA : Integer) : TNumericSeries;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Moving Average Oscillator }

  TMAO = class(TIndicator)
  protected
    function FastMA : Integer;
    function SlowMA : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Momentum }

  TMomentum = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    function SignalLen : Integer;    //
    function Momentum(stKey : String; Price : TNumericSeries; Length : Integer) : TNumericSeries;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Commodity Channel Index }

  TCCI = class(TIndicator)
  protected
    function Length : Integer;
    function CCILong : Integer;
    function CCIShort : Integer;
    function SignalLen : Integer;
    function CCI(Key : String; Length : Integer) : TNumericSeries;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { WMA }

  TWMA = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    function Displace : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { EMA }

  TEMA = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    function Displace : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Parabolic }

  TParabolic = class(TIndicator)
  protected
    function AFValue : Double;
    function Parabolic(Key : String; AcclFact : Double{;
      iHistory : Integer}) : TNumericSeries;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TParabolic2 = class(TIndicator)
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { Standard Deviation }

  TStdDev = class(TIndicator)
  protected
    function Price : String;
    function Length : Integer;
    //
    procedure DoInit; override;
    procedure DoPlot; override;
  end;


implementation

//====================================================================//
                             { TVolume }
//====================================================================//


procedure TVolume.DoInit;
begin
  FPrecision := 0;

  Title := 'Volume';
  //
  AddPlot('Volume', psHistogram, clRed, 1);
end;

procedure TVolume.DoPlot;
begin
  Plot(0, Volume[0]);
end;

//====================================================================//
                             { TVolumeMA}
//====================================================================//

function TVolumeMA.AvgLength : Integer;
begin
  Result := Params['AvgLength'].AsInteger;
end;

procedure TVolumeMA.DoInit;
begin
  Title := 'Volume Avg';
  //
  AddParam('AvgLength', 9);
  // AddParam('UpVolColor', pcBlue);
  // AddParam('DownVolColor', pcRed);
  //
  AddPlot('Volume', psHistogram, clRed, 1);
  AddPlot('Volume Avg', psLine, clAqua, 1);
end;

procedure TVolumeMA.DoPlot;
begin
  if Close[0] >= Close[1] then
    Plot(0, Volume[0])
  else
    Plot(0, Volume[0], 0, pcBlue);

  if CurrentBar > Abs(AvgLength) then
    Plot(1, Average('Volume Avg', Volume, AvgLength)[0]);
end;

//====================================================================//
       { Moving Average }
//====================================================================//

function TMA.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TMA.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TMA.Displace : Integer;
begin
  Result := Params['Displace'].AsInteger;
end;

procedure TMA.DoInit;
begin
  Title := 'MA';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('Displace', 0);
  //
  AddPlot('MA', psLine, clRed, 1);
end;

procedure TMA.DoPlot;
begin
  if (Displace >= 0) or (CurrentBar > Abs(Displace)) then
    Plot(0, AverageFC('DoPlot', Expression(Price), Length)[0], Displace);
end;


//====================================================================//
       { Moving Average 2 Lines}
//====================================================================//

function TMA2.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TMA2.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TMA2.Length2 : Integer;
begin
  Result := Params['Length2'].AsInteger;
end;

function TMA2.Displace : Integer;
begin
  Result := Params['Displace'].AsInteger;
end;

procedure TMA2.DoInit;
begin
  Title := 'MA2';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('Length2', 18);
  AddParam('Displace', 0);
  //
  AddPlot('MA', psLine, clRed, 1);
  AddPlot('MA2', psLine, clBlue, 1);
end;

procedure TMA2.DoPlot;
begin
  if (Displace >= 0) or (CurrentBar > Abs(Displace)) then
  begin
    Plot(0, AverageFC('DoPlot', Expression(Price), Length)[0]);
    Plot(1, AverageFC('DoPlot2', Expression(Price), Length2)[0]);
  end;
end;

//====================================================================//
       { Moving Average 3 Lines}
//====================================================================//

function TMA3.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TMA3.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TMA3.Length2 : Integer;
begin
  Result := Params['Length2'].AsInteger;
end;

function TMA3.Length3 : Integer;
begin
  Result := Params['Length3'].AsInteger;
end;

function TMA3.Displace : Integer;
begin
  Result := Params['Displace'].AsInteger;
end;

procedure TMA3.DoInit;
begin
  Title := 'MA3';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('Length2', 18);
  AddParam('Length3', 27);
  AddParam('Displace', 0);
  //
  AddPlot('MA', psLine, clRed, 1);
  AddPlot('MA2', psLine, clBlue, 1);
  AddPlot('MA3', psLine, clGreen, 1);
end;

procedure TMA3.DoPlot;
begin
  if (Displace >= 0) or (CurrentBar > Abs(Displace)) then
  begin
    Plot(0, AverageFC('DoPlot', Expression(Price), Length)[0]);
    Plot(1, AverageFC('DoPlot2', Expression(Price), Length2)[0]);
    Plot(2, AverageFC('DoPlot3', Expression(Price), Length3)[0]);
  end;
end;

//====================================================================//
      { Moving Average Oscillator }
//====================================================================//

function TMAO.FastMA : Integer;
begin
  Result := Params['FastMA'].AsInteger;
end;

function TMAO.SlowMA : Integer;
begin
  Result := Params['SlowMA'].AsInteger;
end;

procedure TMAO.DoInit;
begin
  Title := 'MAO';
  //
  AddParam('FastMA', 12);
  AddParam('SlowMA', 26);
  //
  AddPlot('MAO', psHistogram, clRed, 1);
  AddPlot('Zero', psLine, clGreen, 1);
end;

procedure TMAO.DoPlot;
begin
  Plot(0, AverageFC('DoPlot', Close, FastMA)[0]-AverageFC('DoPlot2', Close, SlowMA)[0]);
  Plot(1, 0); // MADiff
end;

//====================================================================//
      { Moving Average Convergent & Divergence }
//====================================================================//

function TMACD.FastMA : Integer;
begin
  Result := Params['FastMA'].AsInteger;
end;

function TMACD.SlowMA : Integer;
begin
  Result := Params['SlowMA'].AsInteger;
end;

function TMACD.MacdMA : Integer;
begin
  Result := Params['MacdMA'].AsInteger;
end;

procedure TMACD.DoInit;
begin
  Title := 'MACD';
  //
  AddParam('FastMA', 12);
  AddParam('SlowMA', 26);
  AddParam('MacdMA', 9);
  //
  AddPlot('MACD', psLine, clRed, 1);
  AddPlot('MACDAvg', psLine, clBlue, 1);
  AddPlot('MADiff', psHistogram, clYellow, 1);
end;

procedure TMACD.DoPlot;
begin
  Plot(0, MACD('DoPlot', Close, FastMA, SlowMA)[0]);
  Plot(1, XAverage('DoPlot', MACD('DoPlot', Close, FastMA, SlowMA), MacdMA)[0]); //????
  Plot(2, Plots[0][0] - Plots[1][0]); // MADiff
end;

function TMACD.MACD(Key : String; Price : TNumericSeries; FastMA, SlowMA : Integer) :
     TNumericSeries;
begin
  MACD := NumericSeries(Key + 'MACD');
  //
  MACD[0] := XAverage(Key+ 'MACD1', Price, FastMA)[0] -
             XAverage(Key+ 'MACD2', Price, SlowMA)[0];
end;


//====================================================================//
                   { Momentum }
//====================================================================//

function TMomentum.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TMomentum.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TMomentum.SignalLen : Integer;
begin
  Result := Params['SignalLen'].AsInteger;
end;

procedure TMomentum.DoInit;
begin
  Title := 'Momentum';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 10);
  AddParam('SignalLen', 9);
  //
  AddPlot('Momentum', psHistogram, clRed, 1);
  AddPlot('SignalLine', psLine, clYellow, 1);
end;

procedure TMomentum.DoPlot;
begin
  Plot(0, Momentum('DoPlot', Expression(Price), Length)[0]);
  Plot(1, AverageFC('DoPlot', Momentum('DoPlot', Expression(Price), Length), SignalLen)[0]);
end;

function TMomentum.Momentum(stKey : String; Price : TNumericSeries;
  Length : Integer) : TNumericSeries;
begin
  Momentum := NumericSeries(stKey + 'Momentum');
  //
  Momentum[0] := Price[0] - Price[Length];
end;


//====================================================================//
          { Commodity Channel Index }
//====================================================================//

function TCCI.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TCCI.CCILong : Integer;
begin
  Result := Params['CCI Long'].AsInteger;
end;

function TCCI.CCIShort : Integer;
begin
  Result := Params['CCI Short'].AsInteger;
end;

function TCCI.SignalLen : Integer;
begin
  Result := Params['SignalLen'].AsInteger;
end;

procedure TCCI.DoInit;
begin
  Title := 'CCI';
  //
  AddParam('Length', 20);
  AddParam('SignalLen', 9);
  AddParam('CCI Long', 100);
  AddParam('CCI Short', -100);
  //
  AddPlot('CCI', psLine, clYellow, 1);
  AddPlot('SignalLine', psLine, clGreen, 1);
  AddPlot('CCILong', psLine, clRed, 1);
  AddPlot('CCIShort', psLine, clBlue, 1);
  AddPlot('ZeroLine', psLine, clGray, 1);
end;

procedure TCCI.DoPlot;
begin
  Plot(0, CCI('DoPlot', Length)[0]);
  Plot(1, AverageFC('DoPlot',CCI('DoPlot', Length), SignalLen)[0]);
  Plot(2, CCILong);
  Plot(3, CCIShort);
  Plot(4, 0);
end;

function TCCI.CCI(Key : String; Length : Integer) : TNumericSeries;
var
  MD, Avg : Double;
  HLCSeries : TNumericSeries;
  Counter : Integer;
begin
  CCI := NumericSeries(Key + 'CCI');
  HLCSeries := NumericSeries(Key + 'HLC');
  //
  if Length > 0 then
  begin
    HLCSeries[0] := High[0] + Low[0] + Close[0];
    Avg := Average('CCI', HLCSeries, Length)[0];
    MD := 0;
    for Counter := 0 to Length-1 do
      MD := MD + Abs(High[Counter] + Low[Counter] + Close[Counter] - Avg);
    MD := MD / Length;
    if Abs(MD) < ZERO then
      CCI[0] := 0
    else
      CCI[0] := (High[0] + Low[0] + Close[0] - Avg) / (0.015 * MD);
  end else
    CCI[0] := 0;
end;

//====================================================================//
            { Weighted Moving Average }
//====================================================================//

function TWMA.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TWMA.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TWMA.Displace : Integer;
begin
  Result := Params['Displace'].AsInteger;
end;

procedure TWMA.DoInit;
begin
  Title := 'WMA';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('Displace', 0);
  //
  AddPlot('WMA', psLine, clBlue, 1);
end;

procedure TWMA.DoPlot;
begin
  if CurrentBar > Abs(Displace) + Length then
    Plot(0, WAverage('WMA', Expression(Price), Length)[0], Displace)
  else
    WAverage('WMA', Expression(Price), Length);
end;

//====================================================================//
            { Exponentail Moving Average }
//====================================================================//

function TEMA.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TEMA.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TEMA.Displace : Integer;
begin
  Result := Params['Displace'].AsInteger;
end;

procedure TEMA.DoInit;
begin
  Title := 'EMA';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('Displace', 0);
  //
  AddPlot('EMA', psLine, clBlue, 1);
end;

procedure TEMA.DoPlot;
begin
  if (Displace >= 0) or (CurrentBar > Abs(Displace)) then
    Plot(0, XAverage('EMA', Expression(Price), Length)[0], Displace);
end;

//====================================================================//
                     { Parabolic }
//====================================================================//

function TParabolic.AFValue : Double;
begin
  Result := Params['AF'].AsFloat;
end;

procedure TParabolic.DoInit;
begin
  Title := 'Parabolic';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('AF', 2, 0.02);
  //
  AddPlot('Parabolic', psDot, clRed, 1);
end;

procedure TParabolic.DoPlot;
var
  Value : TNumericSeries;
begin
  Value := Parabolic('Parabolic', AFValue);
  
  if CurrentBar > 1 then
    Plot(0, Value[0])
  else
    Plot(0, Close[0]);
end;

function TParabolic.Parabolic(Key : String; AcclFact : Double{;
  iHistory : Integer}) : TNumericSeries;
var
  Pos, HighValue, LowValue, AF, SAR : TNumericSeries;
begin
  Parabolic := NumericSeries(Key + 'Parabolic');
  Pos := NumericSeries(Key + 'ParabolicPos');
  HighValue := NumericSeries(Key + 'ParabolciHighValue');
  LowValue := NumericSeries(Key + 'ParabolicLowValue');
  AF := NumericSeries(Key + 'ParabolicAF');
  SAR := NumericSeries(Key + 'ParabolicSAR');

//Variables: Pos(-1), SAR(Close), AF(.02), HighValue(High), LowValue(Low);


  if CurrentBar = 1 then
  begin
    Pos[0] := 1;
    // init values
    SAR[0] := Close[0];
    AF[0] := 0.02;
    HighValue[0] := High[0];
    LowValue[0] := Low[0];
  end else
  if CurrentBar > 1 then
  begin
    if High[0] > HighValue[0] + EPSILON then
      HighValue[0] := High[0];
    if Low[0] < LowValue[0] - EPSILON then
      LowValue[0] := Low[0];
    //
    if Pos[0] > 0 then  // Pos[0] = 1
    begin
      if Low[0] <= SAR[1] + EPSILON then // result = parabolic
        Pos[0] := -1;
    end else
    begin
      if High[0] >= SAR[1] - EPSILON then
        Pos[0] := 1;
    end;
  end;
  //
//  if CurrentBar > 1 then
  if Pos[0] > 0 then // Pos[0] = 1
  begin
    if Pos[1] < 0 then // Pos[1] = -1
    begin
      SAR[0] := LowValue[0];
      AF[0] := AcclFact;
      LowValue[0] := Low[0];
      HighValue[0] := High[0];
    end else
    begin
      SAR[0] := SAR[1] + AF[0] * (HighValue[0] - SAR[1]);
      if (HighValue[0] > HighValue[1] + EPSILON) and (AF[0] < 0.2) then
        AF[0] := AF[0] + Min(AcclFact, (0.2 -AF[0]));
    end;
    if SAR[0] > Low[0] + EPSILON then SAR[0] := Low[0];
    if SAR[0] > Low[1] + EPSILON then SAR[0] := Low[1];
  end else
  begin
    if Pos[1] > 0 then // Pos[1] = 1
    begin
      SAR[0] := HighValue[0];
      AF[0] := AcclFact;
      LowValue[0] := Low[0];
      HighValue[0] := High[0];
    end else
    begin
      SAR[0] := SAR[1] + AF[0] * (LowValue[0] - SAR[1]);
      if (LowValue[0] < LowValue[1] - EPSILON) and (AF[0] < 0.2) then
        AF[0] := AF[0] + Min(AcclFact, (0.2 - AF[0]));
    end;
    if SAR[0] < High[0] - EPSILON then SAR[0] := High[0];
    if SAR[0] < High[1] - EPSILON then SAR[0] := High[1];
  end;
  //
  Parabolic[0] := SAR[0];

end;

//====================================================================//
       { Standard Deviation }
//====================================================================//

function TStdDev.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TStdDev.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TStdDev.DoInit;
begin
  Title := 'StdDev';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  //
  AddPlot('StdDev', psLine, clRed, 1);
end;

procedure TStdDev.DoPlot;
begin
  If CurrentBar > Length then
    Plot(0, StdDev('DoPlot', Expression(Price), Length)[0])
  else
    StdDev('DoPlot', Expression(Price), Length);
end;

{ TParabolic2 }

procedure TParabolic2.DoInit;
begin
  Title := 'Parabolic2';

  ScaleType := stSymbol;
  //

  AddPlot('SAR', psDot, clYellow, 1);

end;

procedure TParabolic2.DoPlot;
begin
  Plot(0, SAR[0]);

end;

end.

