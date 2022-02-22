unit Indicators3;

interface

uses
  Classes, Graphics, Forms, Math,
  //
  Charters, Indicator, Symbolers, XTerms, GleTypes, GleConsts;

type
  { William's OverBought/Oversold Index }

  TWilliamR = class(TIndicator)
  protected
    function WilliamR(Key : String; Length : Integer) : TNumericSeries;

    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { SONAR Momentum Chart }

  TSonar = class(TIndicator)
  protected
    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { 일목균형표 }
  TIchimoku = class(TIndicator)
  protected
    function Standard : Integer;
    function Turning : Integer;
    function Span : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  { 투자심리선 }
  TPsychoLine = class(TIndicator)
  protected
    function Length : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  {RPL Relative Position from the Lowest} // for internal use

  TRPL = class(TIndicator)
  protected
    function RPL(Key : String; Length : Integer) : TNumericSeries;

    function Price : String;
    function Length : Integer;
    function AvgLength : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  {RPH Relative Position from the Highest} // for internal use

  TRPH = class(TIndicator)
  protected
    function RPH(Key : String; Length : Integer) : TNumericSeries;

    function Price : String;
    function Length : Integer;
    function AvgLength : Integer;

    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  {Color Tick Volume} // for internal use

  TTickVolume = class(TIndicator)
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  {Color Tick Line} // for internal use

  TColorTick = class(TIndicator)
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TTickSideVolume = class( TIndicator )
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TMarketTermFillSum = class( TIndicator )
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;  


implementation

{William's OverBought/Oversold Index}

function TWilliamR.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TWilliamR.DoInit;
begin
  Title := 'William''s %R';
  //
  AddParam('Length', 12);
  AddParam('OverBought', -20);
  AddParam('OverSold', -80);
  //
  AddPlot('%R', psLine, clYellow, 1);
  AddPlot('OverBought', psLine, clRed, 1);
  AddPlot('OverSold', psLine, clBlue, 1);
end;

procedure TWilliamR.DoPlot;
begin
  if CurrentBar > Length then
  begin
    Plot(0, WilliamR('DoPlot', Length)[0]);
    Plot(1, Params['OverBought'].AsFloat);
    Plot(2, Params['OverSold'].AsFloat);
  end;
end;

function TWilliamR.WilliamR(Key : String; Length : Integer) : TNumericSeries;
var
  Value1, Value2 : Double;
begin
  WilliamR := NumericSeries(Key + 'WilliamR');

  Value1 := Highest(High, Length);
  Value2 := Value1 - Lowest(Low, Length);

  if Value2 > ZERO then
          WilliamR[0] := (Value1-Close[0])/Value2 * -100.0
  else
          WilliamR[0] := 0;
end;


{SONAR Momentum Chart}


function TSonar.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TSonar.DoInit;
begin
  Title := 'Sonar';
  //
  AddParam('Length', 12);
  //
  AddPlot('SONAR', psLine, clRed, 1);
end;

procedure TSonar.DoPlot;
var
  Sonar : Double;
begin
  if Close[Length] > ZERO then
	Sonar := (Close[0]-Close[Length])/Close[Length]
  else
	Sonar := 0;

  if CurrentBar > Length then
    Plot(0, Sonar);
end;


{ 일목균형표 }

function TIchimoku.Standard : Integer;
begin
  Result := Params['Standard'].AsInteger;
end;

function TIchimoku.Turning : Integer;
begin
  Result := Params['Turning'].AsInteger;
end;

function TIchimoku.Span : Integer;
begin
  Result := Params['Span'].AsInteger;
end;

procedure TIchimoku.DoInit;
begin
  Title := '일목균형표';
  Position := cpMainGraph;
  ScaleType := stSymbol;
  //
  AddParam('Standard', 26);
  AddParam('Turning', 9);
  AddParam('Span', 52);
  AddParam('DelayColor', pcFuchsia);
  AddParam('ShowDelayLine', False);
  //
  AddPlot('StdLine', psLine, clRed, 1);
  AddPlot('TurnLine', psLine, clBlue, 1);
  AddPlot('DelayLine', psLine, clYellow, 1);
  AddPlot('Span1', psBarHigh, clAqua, 1);
  AddPlot('Span2', psBarLow, clBlue, 1);
end;

procedure TIchimoku.DoPlot;
var
  StdLine, TurnLine, DelayLine, Span1, Span2 : Double;
begin
  // calc. ichimoku lines
  StdLine := (Highest(High, Standard) + Lowest(Low, Standard)) / 2;
  TurnLine := (Highest(High, Turning) + Lowest(Low, Turning)) / 2;
  DelayLine := Close[Standard];
  // calc. ichimoku cloud
  Span1 := (StdLine + TurnLine) /2;
  Span2 := (Highest(High, Span) + Lowest(Low, Span))/2;

  // draw ichimoku lines
  if CurrentBar > Standard then
    Plot(0, StdLine);

  if CurrentBar > Turning then
  begin
    if Close[0] > DelayLine then
      Plot(1, TurnLine, 0) // pcBlue
    else
      Plot(1, TurnLine, 0, Params['DelayColor'].AsColor);
  end;

  if Params['ShowDelayLine'].AsBoolean then
    if CurrentBar > Standard then
      Plot(2, Close[0], Standard); // modified by CHJ on 2004.3.24
      //Plot(2, Close[0], Delayed);

  // draw ichimoku cloud
  if (CurrentBar > Standard) and
     (CurrentBar > Turning) and
     (CurrentBar > Span) then
  begin
    Plot(3, Span1, -Standard);
    Plot(4, Span2, -Standard);
  end;
end;

{ 투자심리선 }

function TPsychoLine.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

procedure TPsychoLine.DoInit;
begin
  Title := '투자심리선';
  //
  AddParam('Length', 12);
  AddParam('과열', 75);
  AddParam('침체', 25);
  //
  AddPlot('과열', psLine, clRed, 1);
  AddPlot('침체', psLine, clBlue, 1);
  AddPlot('투자심리선', psLine, clRed, 1);
end;

procedure TPsychoLine.DoPlot;
var
  i, iUpTicks : Integer;
begin
  if Length <= 0 then Exit;

  if CurrentBar > Length then
  begin
    iUpTicks := 0;
    for i:=0 to Length-1 do
      if Close[i] > Close[i+1] + EPSILON then
        Inc(iUpTicks);

    Plot(0, Params['과열'].AsInteger);
    Plot(1, Params['침체'].AsInteger);
    Plot(2, (iUpTicks/Length)*100);
  end;
end;

{ RPL }

function TRPL.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TRPL.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TRPL.AvgLength : Integer;
begin
  Result := Params['AvgLength'].AsInteger;
end;

procedure TRPL.DoInit;
begin
  Title := 'RPL';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('AvgLength', 9);
  //
  AddPlot('RPL', psLine, clRed, 1);
  AddPlot('MA', psLine, clBlue, 1);
end;

procedure TRPL.DoPlot;
var
  aRPL : TNumericSeries;
begin
  if CurrentBar > Length then
  begin
    aRPL := RPL('DoPlot', Length);

    Plot(0, aRPL[0]);
    Plot(1, Average('DoPlot', aRPL, AvgLength)[0]);
  end;
end;

function TRPL.RPL(Key : String; Length : Integer) : TNumericSeries;
var
  Value1, Value2 : Double;
begin
  RPL := NumericSeries(Key + 'RPL');

  RPL[0] := Max(Close[0] - Lowest(Expression(Price), Length), 0);
end;

{ RPH }

function TRPH.Price : String;
begin
  Result := Params['Price'].AsString;
end;

function TRPH.Length : Integer;
begin
  Result := Params['Length'].AsInteger;
end;

function TRPH.AvgLength : Integer;
begin
  Result := Params['AvgLength'].AsInteger;
end;

procedure TRPH.DoInit;
begin
  Title := 'RPH';
  //
  AddParam('Price', 'Close');
  AddParam('Length', 9);
  AddParam('AvgLength', 9);
  //
  AddPlot('RPH', psLine, clRed, 1);
  AddPlot('MA', psLine, clBlue, 1);
end;

procedure TRPH.DoPlot;
var
  aRPH : TNumericSeries;
begin
  if CurrentBar > Length then
  begin
    aRPH := RPH('DoPlot', Length);

    Plot(0, aRPH[0]);
    Plot(1, Average('DoPlot', aRPH, AvgLength)[0]);
  end;
end;

function TRPH.RPH(Key : String; Length : Integer) : TNumericSeries;
var
  Value1, Value2 : Double;
begin
  RPH := NumericSeries(Key + 'RPH');

  RPH[0] := Max(Highest(Expression(Price), Length) - Close[0], 0);
end;

//====================================================================//
                             { TTickVolume }
//====================================================================//


procedure TTickVolume.DoInit;
begin
  FPrecision := 0;

  Title := 'Tick Volume';
  //
  AddPlot('Tick Volume', psHistogram, clGreen, 1);
end;

procedure TTickVolume.DoPlot;
begin
  if Side[0] > 0 then
    Plot(0, Volume[0], 0, clRed)
  else
  if Side[0] < 0 then
    Plot(0, Volume[0], 0, clBlue)
  else
    Plot(0, Volume[0]);
end;

//====================================================================//
                             { TColorTick }
//====================================================================//

procedure TColorTick.DoInit;
begin
  FPrecision := 2;

  Title := 'Color Tick';
  //
  AddPlot('Color Tick', psLine, clGreen, 1);
end;

procedure TColorTick.DoPlot;
begin
  if Side[0] > 0 then
    Plot(0, Close[0], 0, clRed)
  else
  if Side[0] < 0 then
    Plot(0, Close[0], 0, clBlue)
  else
    Plot(0, Close[0]);
end;

{ TTickVolumeEx }

procedure TTickSideVolume.DoInit;
begin
  FPrecision := 0;

  Title := 'Side Tick Volume(F,O,C,P)';  //
  AddPlot('FutVol', psLine, clGreen, 1);
  AddPlot('OptVol', psLine, clYellow, 1);
  AddPlot('CallVol', psLine, clBlue, 1);
  AddPlot('PutVol', psLine, clRed, 1);
  //AddPlot('SymbolDelta', psHistogram, clGreen, 1);

end;

procedure TTickSideVolume.DoPlot;
begin
  //Plot( 0, SymbolDelta[0], 0, clWhite );
  //deltaed[0];
  Plot(0, FutVol[0]);
  Plot(1, OptVol[0]);
  Plot(2, CallVol[0]);
  Plot(3, PutVol[0]);


end;

{ TMarketTermFillSum }

procedure TMarketTermFillSum.DoInit;
begin
  FPrecision := 0;

  Title := 'DirectionVolume(F,O,C,P)';  //
  AddPlot('FutVol2', psLine, clGreen, 1);
  AddPlot('OptVol2', psLine, clYellow, 1);
  AddPlot('CallVol2', psLine, clBlue, 1);
  AddPlot('PutVol2', psLine, clRed, 1);

end;

procedure TMarketTermFillSum.DoPlot;
begin
  Plot(0, FutVol2[0]);
  Plot(1, OptVol2[0]);
  Plot(2, CallVol2[0]);
  Plot(3, PutVol2[0]);
end;

end.
