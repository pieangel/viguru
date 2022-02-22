unit ClePriceCrt;

interface

uses
  Classes, SysUtils , CleMarketSpecs
  ;

type
  TPriceCrt = class
  private
    FTailSize: integer;

    FValue: string;
    FStrFmt: string;
    FExp2: double;
    FExp1: double;
    procedure SetExpValue( dex1, dex2 : double; itail : integer; fmt : string ); overload;

    function IsContains(str: string; ch: char): boolean;
    function RepeatString(ch: char; count: integer): string;

  public
    Constructor Create;
    Destructor  Destroy; override;

    property Exp1 : double read FExp1;        // 동부에선 exp1
    property Exp2 : double read FExp2;        // 동부에선 exp2
    property TailSize : integer read FTailSize;

    property Value : string read FValue;
    property StrFmt: string read FStrFmt;

    procedure SetExpValue( aSpec : TMarketSpec ); overload;
    function GetString(value: double): string;
    function GetDouble(value: string): double;

  end;

implementation

{ TPriceCrt }

constructor TPriceCrt.Create;
begin

end;

destructor TPriceCrt.Destroy;
begin

  inherited;
end;

procedure TPriceCrt.SetExpValue(dex1, dex2: double; itail: integer;
  fmt: string);
begin
  FExp1 := dex1;
  FExp2 := dex2;
  FTailSize := itail;
  FStrFmt  := fmt;

  if fmt = '0' then
    FStrFmt := '%1.0f'
  else if fmt = '00' then
    FStrFmt := '%02.0f'
  else if fmt = '00.0' then
    FStrFmt := '%02.1f';
end;

procedure TPriceCrt.SetExpValue(aSpec: TMarketSpec);
var
  cF : char;
begin
  cF := Char( aSpec.Formation );
  case cF of
    '1': SetExpValue( 1, 1, 0, '') ;
    '2': SetExpValue( 1, 10, 1, '') ;
    '3': SetExpValue( 1, 100, 2, '') ;
    '4': SetExpValue( 1, 1000, 3, '');
    '5': SetExpValue( 1, 10000, 4, '');
    '6': SetExpValue( 1, 100000, 5, '');
    '7': SetExpValue( 1, 1000000, 6, '');
    '8': SetExpValue( 1, 10000000, 7, '');
    '9': SetExpValue( 1, 100000000, 8, '');

    'A': SetExpValue( 1, 2, 1, '0');
    'B': SetExpValue( 1, 4, 1, '0');
    'C': SetExpValue( 1, 8, 1, '0');
    'D': SetExpValue( 1, 16, 2, '00');
    'E': SetExpValue( 1, 32, 2, '00');
    'F': SetExpValue( 1, 64, 2, '00');
    'G': SetExpValue( 1, 128, 3, '000');
    'H': SetExpValue( 1, 256, 3, '000');
    'I': SetExpValue( 0.5, 32, 1, '00.0');
    'J': SetExpValue( 0.5, 64, 1, '00.0');
    'K': SetExpValue( 0.25, 32, 2, '00.0');
  end;
end;

function TPriceCrt.IsContains( str : string; ch : char) : boolean;
var
  I: Integer;
begin

  Result := false;
  for I := 0 to Length(str) - 1 do
		if (str[i+1] = ch) then
    begin
      Result := true;
      break;
    end;
end;

function TPriceCrt.RepeatString(ch: char; count : integer) : string;
var
  _temp : string;
  i : integer;
begin
	_temp := '';
	for i := 0 to  count-1 do
		_temp := _temp + ch;
  Result := _temp;
end;

function TPriceCrt.GetDouble( value : string ) : double;
var
  stData, stBody, stTail, stPrice, makr : string;
  len, i, pos, imrk, iBody, itLen, iPre : integer;
  dRes, dTail, dexp1, dexp2, dResult : double;
  minus: boolean;
begin
  Result := 0;

  dexp1 := FExp1;
  dexp2 := FExp2;
  iPre  := FTailSize;

  stData  := value;

  len  := Length( stData );
  makr := '.''';
  pos  := 0;

  i := 0;
  imrk := -1;
  dResult := 0;
  while ( i < len ) do
  begin
    if ( stData[i+1] = '.') or (( pos = 1) and ( stData[i+1] = ' ')) then
    begin
      inc(i);
      break;
    end;

    if ( stData[i+1] = '' ) then
      break;

    if IsContains(makr, stData[i+1])  then
    begin
      imrk  := 1;
      break;
    end;

    stBody := stBody + stData[i+1];
    inc(i);
    inc(pos);
  end;

  stTail := '';
  inc(i);
  pos := 0;

  if imrk = 1 then
    while ( i<len) do
    begin
      if IsContains(makr, stData[i+1])  then
      begin
        inc(i);
        Continue;
      end;

      if stData[i+1] = ' ' then
        break;

      stTail := stTail + stData[i+1];
      inc(i);
      inc(pos);
    end;

  if Length(stBody) > 0 then
  begin
    minus := stBody[1] = '-';
    iBody := StrToIntDef( stBody, 0 );
    dTail := 0;
    itLen := Length( stTail );
    if itLen > 0 then
    begin
      if itLen < iPre then
        stTail := stTail + RepeatString('0', iPre - itLen );

      if dexp1 = 0.25 then
      begin
        if IsContains('27', stTail[itLen-1]) then
          stTail := stTail + '5';
      end;

      dTail := StrToFloat(stTail);
      dTail := dTail / dexp2;
    end;
    /////////
    if minus then
      dResult := -dTail + ibody
    else
      dResult := dTail + ibody;
  end;


  Result := dResult;

end;

function TPriceCrt.GetString(value : double) : string;
var
  sTail, fmt, _temp : string;
  body  : integer;
  tail  : double;

begin
  Result := '';

	if FStrFmt <> '' then
  begin

    body := trunc(value );
    tail := Frac(value) * FExp2;

    if tail < 0 then
    begin
      tail  := tail + 0.01;
			sTail := Format(FStrFmt, [-tail]);

      if (body > -1) then
        result  := Format('-%d''%s', [body, sTail])
      else
				result  := Format('%d''%s', [body, sTail]);

    end else
    begin
			if (tail > 0) then
				tail := tail - 0.01;
			sTail := Format(FStrFmt, [tail]);
      result:= Format('%d''%s', [body, sTail]);
    end;
  end
  else begin
		fmt := Format('%%.%df', [FtailSize]);
    result  := Format(fmt, [value]);
  end;
end;



end.
