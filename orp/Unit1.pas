unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function IsContains( str : string; ch : char) : boolean;
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

function RepeatString(ch: char; count : integer) : string;
var
  _temp : string;
  i : integer;
begin
	_temp := '';
	for i := 0 to  count-1 do
		_temp := _temp + ch;
  Result := _temp;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  stData, stBody, stTail, stPrice, makr : string;
  len, i, pos, imrk, iBody, itLen, iPre : integer;
  dRes, dTail, dexp1, dexp2, dResult : double;
  minus: boolean;
begin

  dexp1 := StrTofloat( edit3.Text );
  dexp2 := StrToFloat( edit4.Text );
  iPre  := StrToInt( edit5.Text );

  stData  := edit1.Text;
  len  := Length( stData );
  makr := '.''';
  pos  := 0;
  caption := makr;
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

  dexp1 := 2;

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


  edit2.Text  := FloatToStr( dResult );

end;

end.

