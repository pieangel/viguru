unit CalcGreeks;

interface

uses
  Classes, SysUtils, Math;

const
  MAX_IV = 3.0;         // 300%
  MIN_IV = 0.001;       // 0.1%
  EPSILON = 1.0e-10;

type
  // 잔존일수계산방식  달력/날짜, 달력/시간, 거래/날짜, 거래/시간
  TRdCalcType = (rcCalDate, rcCalTime, rcTrdDate, rcTrdTime);

  function FutThPrice(U, R, dRemainDays, dAllotment: Double) : Double;
  function N( x : Double ): Double;
  function N2( x : Double ): Double;

  // Black sholes Model
  function OptionThPrice(U, E, R, V, T, TC, W: Double) : Double;
  function IV   (U, E, R,    T, TC, OptPrice, W: Double) : Double;
  function Delta(U, E, R, V, T, TC, W: Double) : Double;
  function Gamma(U, E, R, V, T, TC : Double) : Double;
  function Theta(U, E, R, V, T, TC, TradingDaysTotal, W: Double) : Double;
  function Vega (U, E, R, V, T, TC, W: Double) : Double;
  function Lamda(U, E, R, V, T, TC, OptPrice, W: Double) : Double;
  function IntrinsicValue(U, E, W:Double) : Double;     //내재가치
  function TimeValue(U, E, OptPrice, W:Double) : Double;  // 시간가치

  // Binomial Model
  function IVBinomial(U, E, R, T, OptPrice, W: Double; Steps:Integer ) : Double;
  function OptionThPriceBinomial(U, E, R, V, T, W:Double; Steps:Integer) : Double;

  // 역사적변동성계산
  function HistoricalVolatility(Prices : array of Double ; WorkingDaysInYear : Double) : Double;

  //
  function TH_IV(U,E,R,T,TC, OptPrice, W : Double) : Double;
  function TH_Vega(U, E, R, V, T, TC, W : Double) : Double;
  function TH_OptThPrice(U, E, R, V, T, TC, W : Double) : Double;

implementation

function HistoricalVolatility(Prices : array of Double ; WorkingDaysInYear : Double) : Double;
var
  X : array of Double;
  Sum, Average, SumDiff : Double;
  i, N : Integer;
begin
  N := High(Prices)-1;
  SetLength(X, N);

  Sum := 0;
  for i:=0 to N-1 do
  begin
    X[i] := Ln(Prices[i+1] / Prices[i]);
    Sum := Sum + X[i];
  end;
  Average := Sum / N;

  SumDiff := 0;
  for i := 0 to N-1 do
    SumDiff := SumDiff + (X[I] - Average) * (X[I] - Average);

  SetLength(X, 0);
  Result := Sqrt( SumDiff / N) * Sqrt( WorkingDaysInYear);
end;

// U: Kospi 200
// E: 행사가
// R: 금리
// T:잔존일수, TC:잔여일수(달력일기준)}
// W : Call=1, Put=-1
// OptPrice: 옵션 현재가
// dallotment: 배당수익률
// TradingDaysTotal : 년 거래일수
// ------------------------<  Function : >--------------------//


// 선물이론가격
function FutThPrice(U, R, dRemainDays, dAllotment: Double) : Double;
begin
  Result:= U * ( 1 + ( R * dRemainDays / 365.0 ) - dAllotment/100) ;
end;

function N2( x : Double ): Double;
begin
  Result:= 0.39894228 * exp( -x * x / 2.0 );
end;


function N( x : Double ): Double;
var
  k, l : Double;
begin

  try

    if ( x > 6.0 ) then
    begin
        Result:= 1.0;
        Exit;
    end
    else if ( x<-6.0 ) then
    begin
        Result := 0.0;
        Exit;
    end;

    k:= 1.0 / ( 1.0 + 0.2316419 * abs(x) );

    l:= 1.0 - N2(x) * k * ( 0.319381530 - 0.356563782 * k +
                                          1.781477937 * k * k -
                                          1.821255978 * k * k * k +
                                          1.330274429 * k * k * k * k );
    if x >= 0.0 then Result := l
    else Result := 1.0 - l;
  except
    Result:= 0.0;
  end;
end;

(* old routine
function IV(U, E, R, T, TC, OptPrice, W: Double ) : Double;
var
  dExprt, dSqrtt, dLnUE, dMax, dMin, dP, H, V: Double;
  i : Integer;

begin
  if (U < EPSILON) or (OptPrice < EPSILON) or (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  Result:= 0.0;
  try
    dMax:= 3.0;
    dMin:= 0.01;

    if ( OptPrice < OptionThPrice(U,E,R,dMin,T,TC,W)) then
    begin
      Result:= 0.0;
{$ifdef DEBUG}
//      gLog.Add(lkDebug, 'Calcgreeks', 'IV',
//         Format('OptionThPrice(U,E,R,%.2f,T,TC,W)=%.2f', [dMin, OptionThPrice(U,E,R,dMin,T,TC,W)]));
{$endif}
      Exit;
    end
    else if (OptPrice > OptionThPrice(U,E,R,dMax,T,TC,W)) then
    begin
        Result := dMax;
        Exit;
    end;

    dExprt:= Exp( -R * TC );
    dSqrtt:= Sqrt( T );
    dLnUE:= LN( U / E );

    for i := 0 to 15 do
    begin
      V:= ( dMax + dMin ) / 2.0;
      H := ( dLnUE + R * TC + V * V / 2.0 * T ) /( V * dSqrtt );
      dP := W * U * N( W * H ) - W * E * dExprt *
            N( W * H - W * V * dSqrtt );

      if ( abs( OptPrice - dP ) < 0.001 ) then
      begin
        Result:= V;
        Exit;
      end
      else if ( OptPrice < dP ) then dMax := V else dMin:= V;
    end;
  except
    Result:= 0.0;
  end;
end;
*)

function IV(U, E, R, T, TC, OptPrice, W: Double ) : Double;
var
  dSqrtt, dMax, dMin, dP, H, V: Double;
  i: Integer;
begin
  if (U < EPSILON) or (OptPrice < EPSILON) or (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  //Result := TH_IV(U,E,R,T,TC,OptPrice,W);
  //Exit;

  Result:= 0.0;
  try
    dMax:= MAX_IV;
    dMin:= MIN_IV;

      // extreme values
    if OptPrice < OptionThPrice(U,E,R,dMin,T,TC,W) then
    begin
      Result:= dMin;
      Exit;
    end else
    if OptPrice > OptionThPrice(U,E,R,dMax,T,TC,W) then
    begin
      Result := dMax;
      Exit;
    end;

      // calculate
    dSqrtt:= Sqrt( T );

    for i := 0 to 20 do
    begin
      V := (dMax + dMin) / 2.0;

      H := (LN(U/E) + R*TC + V*V/2.0*T) /(V*dSqrtt);
      dP := W*U*N(W*H) - W*E*Exp(-R*TC) * N(W*H - W*V*dSqrtt);

      if Abs(OptPrice - dP) < 0.0005 then
      begin
        Result:= V;
        Exit;
      end else
      if OptPrice < dP then
        dMax := V
      else
        dMin := V;
    end;
  except
    Result:= 0.0;
  end;
end;

function Delta(U, E, R, V, T, TC, W: Double) : Double;
var
  H : Double;

begin
  if (U < EPSILON) or (V < EPSILON) or (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  try
    H:= ( LN(U/E) + R * TC + V * V / 2.0 * T ) / (V * sqrt( T )) ;

    if W = 1 then       // Call
      Result := N(H)
    else                // Put
      Result := N(H) - 1;

  except
    Result:= 0.0;
  end;

end;

function Gamma(U, E, R, V, T, TC: Double) : Double;
var
  H: Double;
begin
  if (U < EPSILON) or (V < EPSILON) or (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  try
    H:= ( LN(U/E) + R * TC + V * V / 2.0 * T ) / (V * sqrt( T )) ;
    Result:= N2( H ) / ( U * V * sqrt( T ));

  except
    Result:= 0.0;
  end;

end;



function Theta(U, E, R, V, T, TC, TradingDaysTotal, W: Double) : Double;
var
  H : Double;
begin
  if (U < EPSILON) or (V < EPSILON) or (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  try
    H:= ( LN(U/E) + R * TC + V * V / 2.0 * T ) / (V * sqrt( T )) ;
    Result:= (-U*V*N2(H)/( 2.0*sqrt( T )) -
           W*R*E*exp(-R*TC)*N(W*H-W*V*sqrt(T)))/TradingDaysTotal;
  except
    Result:= 0.0;
  end;
end;


function Vega(U, E, R, V, T, TC, W: Double) : Double;
var
  H: Double;
begin
  if (U < EPSILON) or (V < EPSILON) or (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  try
    H:= ( LN(U/E) + R * TC + V * V / 2.0 * T ) / (V * sqrt( T )) ;
    Result:= U * N2( H ) * sqrt( T )/100.0;
  except
    Result:= 0.0;
  end;
end;

function Lamda(U, E, R, V, T, TC, OptPrice, W: Double) : Double;
var
  H : Double;

begin
  if (U < EPSILON) or (OptPrice < EPSILON) or (V < EPSILON) or
     (T<EPSILON) or (TC<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  try
    H:= ( LN(U/E) + R * TC + V * V / 2.0 * T ) / (V * sqrt( T )) ;

    if W = 1 then       // Call
      Result := U/OptPrice*N(H)
    else                // Put
      Result := U/OptPrice*(N(H)-1);

  except
    Result:= 0.0;
  end;

end;

function IntrinsicValue(U,E,W:Double) : Double;
begin
  Result := max(0, (U-E)*W);
end;

function TimeValue(U,E,OptPrice,W:Double) : Double;
Begin
  Result := OptPrice - max(0, (U-E)*W);
End;

function OptionThPrice(U, E, R, V, T, TC, W: Double) : Double;
var
  H: Double;
begin
  //
  if (U < EPSILON) or (V < EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  if T<EPSILON then
  begin
    Result := IntrinsicValue(U,E,W);
    Exit;
  end;

  try
    H:= ( LN(U/E) + R * TC + V * V / 2.0 * T ) / (V * sqrt( T )) ;
    Result:= W * U * N( W * H )
            - W * E * exp( -R * TC ) * N( W * H - W * V * sqrt( T ));

  except
    Result:= 0.0;
  end;

end;

/////////////////////////////////////////////////////////////////////////
// Binomial model

function IVBinomial(U, E, R, T, OptPrice, W: Double; Steps:Integer ) : Double;
var
  dMax, dMin, dP, V: Double;
  i : Integer;

begin
  if (U < EPSILON) or (OptPrice < EPSILON) or (T<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  Result:= 0.0;
  try
    dMax:= MAX_IV;
    dMin:= MIN_IV;

    if ( OptPrice < OptionThPriceBinomial(U,E,R,dMin,T,W,Steps)) then
    begin
      Result:= dMin;
      Exit;
    end
    else if (OptPrice > OptionThPriceBinomial(U,E,R,dMax,T,W,Steps)) then
    begin
        Result := dMax;
        Exit;
    end;

    for i := 0 to 20 do
    begin
      V:= ( dMax + dMin ) / 2.0;
      dP := OptionThPriceBinomial(U, E, R, V, T, W, Steps);

      if ( abs( OptPrice - dP ) < 0.0005 ) then
      begin
        Result:= V;
        Exit;
      end
      else if ( OptPrice < dP ) then dMax := V else dMin:= V;
    end;
  except
    Result:= 0.0;
  end;
end;

function OptionThPriceBinomial(U, E, R, V, T, W:Double; Steps:Integer) : Double;
var
  Rinv, UpRate, uu, DownRate, ProbUp, ProbDown : double;
  i, step : Integer;
  Prices, OptionValues : Array of double;

begin
  if (U < EPSILON) or (V < EPSILON) or (T<EPSILON) then
  begin
    Result:= 0.0;
    Exit;
  end;

  SetLength(Prices, steps+1);
  SetLength(OptionValues, steps+1);

  UpRate := Exp(V*sqrt(T/steps));                               // 주가지수상승률
  DownRate := 1.0/UpRate;                                       // 주가지수하락률
  probUp := (Exp(R*T/Steps)-DownRate)/(UpRate-DownRate);        // 주가지수상승확률
  ProbDown := 1.0-ProbUp;                                       // 주가지수하락확률

  uu := UpRate*UpRate;
  Rinv := 1.0/Exp(R*T/Steps);

  Prices[0] := U*Power(DownRate,Steps);
  for i := 1 to steps do
    Prices[i] := uu * Prices[i-1];

  for i := 0 to steps do
    OptionValues[i] := max(0.0, (Prices[i]-E)*W);

  for step := Steps-1 downto 0 do
    for i := 0 to step do
      OptionValues[i] := (ProbUp*OptionValues[i+1] + ProbDown*OptionValues[i])*Rinv;

  Result := OptionValues[0];

  SetLength(Prices, 0);
  SetLength(OptionValues, 0);

end;

function TH_OptThPrice(U, E, R, V, T, TC, W : Double) : Double;
var
  Q, d1, d2 : Double;
begin
  Q := 0.0;
  //tau = (t2-t1)/365;

  d1 := (ln(U/E) + (R - Q + V*V / 2.0) * T) / (V * sqrt(T));
  d2 := d1 - V * sqrt(T);

  Result := W * U * exp(-Q*T) * N(W*d1) - W * E * exp(-R*T) * N(W*d2);
end;

function TH_Vega(U, E, R, V, T, TC, W : Double) : Double;
var
  d1, Q : Double;
begin
  Q := 0.0;
  //tau := (t2 - t1) / 365;

  d1 := (ln(U / E) + (R - Q + V*V / 2.0) * T) / (V * sqrt(T));
  Result := U * sqrt(T) * exp(-d1*d1 / 2) / sqrt(2 * PI);
end;

function TH_IV(U,E,R,T,TC, OptPrice, W : Double) : Double;
var
  xl, xm, el, vg : Double;
begin
   xl := 1;
   el := 0.0001;
   xm := xl - (TH_OptThPrice(U, E, R, xl, T, TC, W) - OptPrice)
              / TH_Vega(U, E, R, xl, T, TC, W);

   while (Abs(xl - xm) >= el) do
   begin
     xl := xm;
     vg := TH_Vega(U, E, R, xl, T, TC, W);
     if abs(vg) < EPSILON then Break;

     xm := xl - (TH_OptThPrice(U, E, R, xl, T, TC, W) - OptPrice)
                / vg;

     if xl + xm < xl then
     begin
        xl := xl - 0.0001;
        xm := xl;
     end;
   end;

   Result := xm;
end;

(*
Option Explicit
'Black-Sholes Option Pring Model
Function BSOpm(S As Double, X As Double, R As Double, Q As Double, VOL As Double, t1 As Date, t2 As Date, CorP As String) As Double

    Dim d1 As Double
    Dim d2 As Double
    Dim tau As Double

    tau = (t2 - t1) / 365

    d1 = (Log(S / X) + (R - Q + VOL ^ 2 / 2) * tau) / (VOL * Sqr(tau))
    d2 = d1 - VOL * Sqr(tau)

    Select Case UCase(CorP)
    Case "C"
        BSOpm = S * Exp(-Q * tau) * Application.NormSDist(d1) - X * Exp(-R * tau) * Application.NormSDist(d2)

    Case "P"
        BSOpm = X * Exp(-R * tau) * Application.NormSDist(-d2) - S * Exp(-Q * tau) * Application.NormSDist(-d1)

    End Select

End Function

'Vega
Function Vega(S As Double, X As Double, R As Double, Q As Double, VOL As Double, _
t1 As Date, t2 As Date) As Double

    Dim d1 As Double
    Dim tau As Double
        
    tau = (t2 - t1) / 365
    
    d1 = (Log(S / X) + (R - Q + VOL ^ 2 / 2) * tau) / (VOL * Sqr(tau))
    Vega = S * Sqr(tau) * Exp(-d1 ^ 2 / 2) / Sqr(2 * Application.Pi())


End Function


 
Function ImpliedVol(S As Double, X As Double, R As Double, Q As Double, t1 As Date, t2 As Date, CorP As String, OptionPremium As Single) As Single
          
         Dim xl As Double
         Dim xm As Double
         Dim e As Double


         xl = 1
         e = 0.0001
         xm = xl - (BSOpm(S, X, R, Q, xl, t1, t2, CorP) - OptionPremium) / Vega(S, X, R, Q, xl, t1, t2)

         Do Until (Abs(xl - xm) < e)

         xl = xm
         xm = xl - (BSOpm(S, X, R, Q, xl, t1, t2, CorP) - OptionPremium) / Vega(S, X, R, Q, xl, t1, t2)

         If xl + xm < xl Then
            xl = xl - 0.0001
            xm = xl
         End If

         Loop

         ImpliedVol = xm

End Function

*)
end.
