unit CleLogPL;

interface

uses
  Classes, SysUtils
  ;
type

  TLogPL = class
  private
    FCount : integer;
    FStartPL  : double;
    FInc      : double;
    F2thCalc  : boolean;
    procedure OnPL2(dPL: double);
  public
    NowPL, MaxPL, MinPL : double;
    Run : boolean;
    PL  : array  of double;
    constructor Create( iCnt : integer; dStartPL : double ) ; overload;
    constructor Create( iCnt : integer; dStartPL, dGap : double ) ; overload;
    procedure Reset;
    procedure OnPL( dPL : double; bRun : boolean = false );
    procedure Fin;

    property Count : integer read FCount write FCount;
  end;

implementation

uses
  Math
  ;

{ TLogPL }

constructor TLogPL.Create(iCnt: integer; dStartPL: double);
begin

  FStartPL  := dStartPL * 10000;
  FCount    := iCnt;
  SetLength( PL, FCount );

  F2thCalc  := false;
end;

constructor TLogPL.Create(iCnt: integer; dStartPL, dGap : double);
begin

  FStartPL  := dStartPL * 10000;
  FCount    := iCnt;
  FInc      := dGap * 10000;
  SetLength( PL, FCount );

  F2thCalc  := true;
end;

procedure TLogPL.Fin;
var
  i : integer;
begin

  for I := 0 to FCount - 1 do
    if PL[i] = 0 then
      PL[i]  := NowPL;

  for I := 0 to FCount - 1 do
    PL[i]  := PL[i] / 1000;

end;

procedure TLogPL.OnPL(dPL: double; bRun: boolean);
var
  i   : integer;
  dTmp  : double;
begin
  if not Run then Exit;

  NowPL := dPL ;
  MaxPL := Max( NowPL, MaxPL );
  MinPL := Min( NowPL, MinPL );

  if F2thCalc then begin OnPL2( dPL ); Exit; end;

  // 손절
  for I := 0 to FCount - 1 do
  begin
    dTmp  := FStartPL + ( 1000000 * i );
    if PL[i] = 0 then
      if dPL < -dTmp then PL[i] := dPL;
  end;

end;

procedure TLogPL.OnPL2(dPL: double);
var
  i   : integer;
  dTmp  : double;
begin

  // 손절
  for I := 0 to FCount - 1 do
  begin
    dTmp  := FStartPL + ( FInc * i );
    if PL[i] = 0 then
      if dPL < -dTmp then PL[i] := dPL;
  end;

end;


procedure TLogPL.Reset;
var
  j: Integer;

begin
  Run := false;
  NowPL := 0;
  MaxPL := 0;
  MinPL := 0;

  for j := 0 to FCount - 1 do
    PL[j]  := 0;
end;

end.
