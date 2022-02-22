unit CleSimulPLItems;

interface

uses
  Classes , Math
  ;

type
  TPLItem = record
    NowPL, MaxPL, MinPL : double;
    Run : boolean;
    PL  : array  of double;
    Count , StartAmt : integer;
    procedure Reset( iStartAmt, iCount : integer) ;
    procedure OnPL( dPL : double; bRun : boolean = false );
    procedure Fin;
  end;

implementation

{ TPLItem }

procedure TPLItem.Fin;
var
  i : integer;
begin

  for I := 0 to Count - 1 do
    if PL[i] = 0 then
      PL[i]  := NowPL;

  for I := 0 to Count - 1 do
    PL[i]  := PL[i] / 1000;
end;

procedure TPLItem.OnPL(dPL: double; bRun: boolean);
var
  i   : integer;
  dTmp  : double;
begin
  if not Run then Exit;
  NowPL := dPL ;
  MaxPL := Max( NowPL, MaxPL );
  MinPL := Min( NowPL, MinPL );

  // 손절
  for I := 0 to Count - 1 do
  begin
    dTmp  := StartAmt + ( 1000000 * i );
    if PL[i] = 0 then
      if dPL < -dTmp then PL[i] := dPL;
  end;

    {
  // 이익청산
  for j := 0 to 3 - 1 do
    for I := 0 to 6 - 1 do
    begin
      dTmp  := 4000000 + ( 1000000 * i );
      if PL[j][i] = 0 then
        if dPL > dTmp then PL[j][i] := dPL;
    end;
     }
end;

procedure TPLItem.Reset( iStartAmt, iCount : integer) ;
var
  j: Integer;
begin

  Run := false;
  NowPL := 0;
  MaxPL := 0;
  MinPL := 0;

  Count := iCount;
  StartAmt  := iStartAmt;

  SetLength( PL, Count );
  for j := 0 to Count - 1 do
    PL[j]  := 0;

end;

end.
