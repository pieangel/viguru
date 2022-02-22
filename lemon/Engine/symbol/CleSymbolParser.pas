unit CleSymbolParser;

interface

uses
  Classes, SysUtils;

type
  TSymbolParser = class
  private
    function GetLongMonth: String;
    function GetShortMonth: String;
  protected
    FCode: String; // whole
    FPrefix: String;    // '' = no info
    FSuffix: String;    // '' = no info
    FRootCode: String;  // this field always required
    FMonth: Integer;    // 1~12, 0 = no info
    FYear: Integer;     // xxxx, 0 = no info
    FCategory: String;  // '' = unidentified, 'C' = call, 'P' = put, 'F' = futures, 'E' = Equity, ...
    FStrike: String;    // handled as string

    procedure Reset;
  public
    function ParseTradeStationSymbol(stSymbol: String): Boolean;
    function ParseESignalSymbol(stSymbol: String): Boolean;
    function ParseKRXSymbol(stSymbol: String): Boolean;

    function GetTradeStationSymbol: String;
    function GetESignalSymbol: String;
    function GetKRXSymbol: String;

      // whole
    property Code: String read FCode;
      // parsed
    property Prefix: String read FPrefix;
    property Suffix: String read FSuffix;
    property RootCode: String read FRootCode;
    property Month: Integer read FMonth;
    property Year: Integer read FYear;
    property Category: String read FCategory;
    property Strike: String read FStrike;
      // secondary
    property ShortMonth: String read GetShortMonth;
    property LongMonth: String read GetLongMonth;
  end;

implementation

const
  US_MONTH_CODES = 'FGHJKMNQUVXZ';
  US_SHORT_MONTHS: array[1..12] of String
         = ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');
  US_LONG_MONTHS: array[1..12] of String
         = ('January','February','March','April','May','June',
            'July','August','September','October','November','December');

{ TSymbolParser }

procedure TSymbolParser.Reset;
begin
  FPrefix := '';
  FSuffix := '';
  FRootCode := '';
  FMonth := 0;
  FYear := 0;
  FCategory := '';
  FStrike := '';
end;

function TSymbolParser.GetESignalSymbol: String;
begin
{
  #F : Continuous contract
  =1 : night session only
  =2 : day session only
}

    // root code
  Result := FRootCode + ' ';
    // month + year
  if (FMonth > 0) and (FYear > 0) then
  begin
    if FMonth in [1..12] then
      Result := Result + US_MONTH_CODES[FMonth];
    if FYear >= 2000 then
      Result := Result + Format('%d', [FYear mod 10])
    else
      Result := Result + Format('%.02d', [FYear mod 100]);
  end;
    // option?
  if Length(FCategory) > 0 then
    case FCategory[1] of
      'C','P': Result := Result + FCategory[1] + FStrike;
    end;
    // continuous?
  if CompareStr(FPrefix, '@') = 0 then
    Result := Result + ' #F';
    // suffix?
  if Length(FSuffix) > 0 then
    case FSuffix[1] of
      'P','D': Result := Result + '=2';
      'C': ;
    end;
end;

function TSymbolParser.GetKRXSymbol: String;
begin
  Result := '';
end;

function TSymbolParser.GetLongMonth: String;
begin
  if FMonth in [1..12] then
    Result := US_LONG_MONTHS[FMonth]
  else
    Result := '';
end;

function TSymbolParser.GetShortMonth: String;
begin
  if FMonth in [1..12] then
    Result := US_SHORT_MONTHS[FMonth]
  else
    Result := '';
end;

function TSymbolParser.GetTradeStationSymbol: String;
begin
  Result := '';
end;

//--------------------------------------------------------------------< parse >

function TSymbolParser.ParseESignalSymbol(stSymbol: String): Boolean;
begin
  Reset;

  FCode := Trim(stSymbol);

  Result := False;
end;

function TSymbolParser.ParseKRXSymbol(stSymbol: String): Boolean;
begin
  Reset;

    FCode := Trim(stSymbol);

  Result := False;
end;

function TSymbolParser.ParseTradeStationSymbol(stSymbol: String): Boolean;
var
  i, iLen, iPos: Integer;
begin
  Reset;

  Result := False;

  stSymbol := Trim(stSymbol);

  FCode := stSymbol;
  
  iLen := Length(stSymbol);

  if iLen = 0 then Exit;

  for i := 1 to Length(stSymbol) do
    case stSymbol[i] of
      '@':
        FPrefix := '@';
      '.':
        if iLen >= i+1 then
        begin
          FSuffix := stSymbol[i+1];
          Break;
        end else
          Exit;
      ' ': ; // skip
      'C','P':
        if (FMonth > 0) and (FYear > 0) then
        begin
          FCategory := stSymbol[i];
          FStrike := Trim(Copy(stSymbol, i+1, iLen - i));
          Break;
        end else
          FRootCode := FRootCode + stSymbol[i];
      '0'..'9':
        if (FMonth > 0) then
        begin
          if (stSymbol[i-1] in ['0'..'9']) then
          begin
            FYear := StrToIntDef(Copy(stSymbol, i-1, 2), -1);
            if FYear < 0 then
              Exit
            else if FYear > 70 then
              FYear := 1900 + FYear
            else
              FYear := 2000 + FYear;
          end;
          //else skip
        end else
          FRootCode := FRootCode + stSymbol[i];
      else
      begin
        iPos := Pos(stSymbol[i], US_MONTH_CODES);
        if (iPos > 0)
           and (Length(FRootCode) >= 1)
           and (iLen >= i+1)
           and (stSymbol[i+1] in ['0'..'9']) then
          FMonth := iPos
        else
          FRootCode := FRootCode + stSymbol[i];
      end;
    end;

  if Length(FCategory) = 0 then
    if (FMonth = 0) and (FYear = 0) then
      FCategory := 'E'
    else
      FCategory := 'F';

  Result := True;
end;


end.
