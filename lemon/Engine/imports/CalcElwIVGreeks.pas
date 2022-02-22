unit CalcElwIVGreeks;

interface

uses
  Classes, SysUtils, Math, GleTypes;

const
  MAX_IV = 3.0;        // 300%
  MIN_IV = 0.001;       // 0.1%
  EPSILON = 1.0e-10;
  tol = 0.000001;      // 오차한계

type

  TElwUnderlyingType = ( eutIndex, eutStock );

  function N( x : Double ): Double;
  function N2( x : Double ): Double;

  // 변동성
  function ELW_Bisection_ImpVol(C_P : Double; Underlying : TElwUnderlyingType;
          S, S1, S2, S3, S4, X, r, T, MP, D, Tr : double) : double;
  function ELW_Bisection_ImpVol_1(C_P : Double; Underlying : TElwUnderlyingType;
          S, S1, S2, S3, S4, X, r, T, MP, D, Tr : Double) : Double;
  function ELW_Bisection_ImpVol_2
          (C_P, S, S1, S2, S3, S4, X, r, T, MP, D, Tr : Double ) : Double;

  // 민감도
  function ELW_Greeks_KIS(C_P : Double; Underlying : TElwUnderlyingType; Greeks : TGreeksType;
          S, S1,S2,S3,S4, X, r, T, vol, D,Tr : Double) : Double;
  function ELW_Greeks_KIS_1(C_P : Double; Underlying : TElwUnderlyingType; Greeks : TGreeksType;
          S, S1,S2,S3,S4, X, r, T, vol, D,Tr : Double) : Double;
  function ELW_Greeks_KIS_2(C_P : Double; Greeks : TGreeksType;
          S, S1,S2,S3,S4, X, r, T, vol, D,Tr : Double) : Double;

  // 배당금
  function Discrete_Dividend( ST, CT : integer; R, D : Double ) : Double;


implementation

function ELW_Bisection_ImpVol(C_P : Double; Underlying : TElwUnderlyingType;
          S, S1, S2, S3, S4, X, r, T, MP, D, Tr : double) : double;
begin
  Result := 0.0;

  case Underlying of
    eutIndex: Result := Elw_Bisection_ImpVol_1( C_P, eutIndex,  S, S1, S2, S3, S4, X, r, T, MP, D, Tr);
    eutStock: Result := ELW_Bisection_ImpVol_2 (C_P, S, S1, S2, S3, S4, X, r, T, MP, D, Tr);
  end;

end;

function ELW_Bisection_ImpVol_1(C_P : Double; Underlying : TElwUnderlyingType;
          S, S1, S2, S3, S4, X, r, T, MP, D, Tr : Double) : Double;
var
  p_low, p_high, vi : double;
  v_low, v_high : double;
begin
  Result := 0.0;
  v_low  := MIN_IV;
  v_high := MAX_IV;

  // 변동성 초기값 V_low일때 옵션가격계산
  P_low := ELW_Greeks_KIS_1(C_P, Underlying, gtPrice, S, S1, S2, S3, S4, X, r, T, V_low, D,Tr);

  // 변동성 초기값 V_high일때 옵션가격계산
  P_high := ELW_Greeks_KIS_1(C_P, Underlying, gtPrice, S, S1, S2, S3, S4, X, r, T, V_high, D,Tr);

  if (MP < p_low) or ( MP > p_high) then
    Exit
  else
    vi := V_low + ( MP - p_low ) * ( V_high - V_low ) / ( p_high - p_low );

  // Implied Volatility (Bisection), 시장가격과 차이가 오차한계 이하면 중지
  while abs(MP - ELW_Greeks_KIS_1(C_P, Underlying, gtPrice, S, S1, S2, S3, S4, X, r, T, vi, D,Tr)) > tol do
  begin
    if ELW_Greeks_KIS_1(C_P, Underlying, gtPrice, S, S1, S2, S3, S4, X, r, T, vi, D,Tr) < MP then
        v_low := vi
    else
        v_high := vi;

    P_low   := ELW_Greeks_KIS_1(C_P, Underlying, gtPrice, S, S1, S2, S3, S4, X, r, T, V_low, D,Tr);
    P_high  := ELW_Greeks_KIS_1(C_P, Underlying, gtPrice, S, S1, S2, S3, S4, X, r, T, V_high, D,Tr);
    vi := V_low + (MP - P_low) * (V_high - V_low)/(P_high - P_low);
  end;

  Result := vi;

end;

function ELW_Bisection_ImpVol_2
        (C_P, S, S1, S2, S3, S4, X, r, T, MP, D, Tr : Double ) : Double;
var
  Ss : array [0..3] of double;
  i, L : integer;
begin
  Result := 0.0;

  Ss[0] := S1;
  Ss[1] := S2;
  Ss[2] := S3;
  Ss[3] := S4;

  L := 0;
  for i := 0 to High(Ss) do
    if Ss[i] > EPSILON then
      inc( L );

  Tr  := ((5 - L ) / 5 ) * Tr;
  X   := (5*X-(S1 + S2 + S3 + S4))/(5-L);

  if X < 0 then
    Exit
  else
    result := ELW_Bisection_ImpVol_1(C_P, eutStock, S, S1, S2, S3, S4, X, r, T, MP, D, Tr);

end;

//----------------------------------------------------------------------------------------//

function ELW_Greeks_KIS(C_P : Double; Underlying : TElwUnderlyingType; Greeks : TGreeksType;
          S, S1,S2,S3,S4, X, r, T, vol, D,Tr : Double) : Double;
begin
  Result := 0.0;

  case Underlying of
    eutIndex: result := ELW_Greeks_KIS_1(C_P, Underlying, Greeks, S, S1, S2, S3, S4, X, r, T, vol, D,Tr);
    eutStock: result := ELW_Greeks_KIS_2(C_P, Greeks, S, S1,S2,S3,S4, X, r, T, vol, D,Tr);
  end;
end;

function ELW_Greeks_KIS_1(C_P : Double; Underlying : TElwUnderlyingType; Greeks : TGreeksType;
          S, S1,S2,S3,S4, X, r, T, vol, D,Tr : Double) : Double;
var
  Ss : array [0..3] of double;
  i, L : integer;
  xi, d1, d2 : double;
begin
  Result := 0.0;

  if (S < EPSILON) or (vol < EPSILON) or (T<EPSILON) or (X<EPSILON) then
    Exit;

  Ss[0] := S1;
  Ss[1] := S2;
  Ss[2] := S3;
  Ss[3] := S4;

  L := 0;
  for i := 0 to High(Ss) do
    if Ss[i] > EPSILON then
      inc( L );

  xi := 0;

  d1 := (LN((S- D)/X)+(r + Power(vol,2)/2)*T)/(vol*sqrt(T));
  d2 := d1-vol*sqrt(T);

  case Underlying of
    eutIndex: xi := 1;
    eutStock: xi := (5-L)/5 ;
  end;

  // normpdf = N2     Tr : 전환비율 D : 배당률

  if C_P = 1 then
  begin
    case Greeks of
      GtDelta:  result := xi * N(d1);
      GtGamma:  result := xi * N2(d1)/((S-D)*vol*sqrt(T));
      GtVega:   result := (Tr/100)*(S-D)*sqrt(T)*N2(d1);
      GtTheta:  result := (Tr/250)*((-(S-D)*N2(d1)*vol)/(2*sqrt(T))-r* X*exp(-r*T)*N(d2));
      GtRho:    result := (Tr/100)*N(d2)*X*T*exp(-r*T);
      GtPrice:  result := Tr * ((S-D)*N(d1)-X*exp(-r*T)*N(d2));
    end;
  end
  else begin
    case Greeks of
      GtDelta:  result := xi * (N(d1)-1);
      GtGamma:  result := xi * N2(d1)/((S-D)*vol*sqrt(T));
      GtVega:   result := (Tr/100)*(S-D)*sqrt(T)*N2(d1);

      GtTheta:  result := (Tr/250)*((-(S-D)*N2(d1)*vol)/(2*sqrt(T))+r*X*exp(-r*T)*N(-d2));
      GtRho:    result := (Tr/100)*N(-d2)*-(X*T*exp(-r*T));
      GtPrice:  result := Tr * (-(S-D)*N(-d1)+X*exp(-r*T)*N(-d2));
    end;
  end;

end;

function ELW_Greeks_KIS_2(C_P : Double; Greeks : TGreeksType;
         S, S1,S2,S3,S4, X, r, T, vol, D,Tr : Double) : Double;
var
  Ss : array [0..3] of double;
  i, L : integer;
  xi, d1, d2 : double;
begin
  Result := 0.0;

  if (S < EPSILON) or (vol < EPSILON) or (T<EPSILON) or (X<EPSILON) then
    Exit;

  Ss[0] := S1;
  Ss[1] := S2;
  Ss[2] := S3;
  Ss[3] := S4;

  L := 0;
  for i := 0 to High(Ss) do
    if Ss[i] > EPSILON then
      inc( L );

  xi := (5-L) / 5;
  Tr := ((5- L)/5)*Tr;
  X  := (5*X-(S1 + S2 + S3 + S4))/(5-L);

  d1 := (LN((S- D)/X)+(r + Power(vol,2)/2)*T)/(vol*sqrt(T));
  d2 := d1-vol*sqrt(T);

  if X < 0 then begin
    if C_P = 1 then
    begin
      case Greeks of
        GtDelta:  result := xi;
        GtGamma:  result := 0;
        GtVega:   result := 0;
        GtTheta:  result := -(Tr/250)*r*X*exp(-r*T);
        GtRho:    result := (Tr/100)*X*T*exp(-r*T);
        GtPrice:  result := Tr * ((S-D)*N(d1)-X*exp(-r*T)*N(d2));
      end;

    end
    else begin
      result := 0;
    end;
  end
  else
    result := ELW_Greeks_KIS_1(C_P, eutStock, Greeks, S, S1, S2, S3, S4, X, r, T, vol, D,Tr);

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

function N2( x : Double ): Double;
begin
  Result:= 0.39894228 * exp( -x * x / 2.0 );
end;


//  ST : 배당일까지 남은 날수
//  CT : 만기일까지 남은 날수
//  R  : 고정이자율
//  D  : 배당금
function Discrete_Dividend( ST, CT : integer; R, D : Double ) : Double;
var
  i : integer;
  dSum : double;
begin
  Result := 0.0;

  if ST > CT then
    Exit
  else begin
    i := 0;
    dSum := 0;

    while ( ST + 365 * i ) <= CT do
    begin
      dSum := dSum + D / ( power(( 1 + R ), i ) * ( 1 + (ST / 365 ) * R ));
      inc( i );
    end;

    Result := dSum;

  end;

end;


end.
