unit CleHolidays;

interface

uses
  Classes, SysUtils, Math,

    // lemon: import
  CalcGreeks;

type
  THoliday = class(TCollectionItem)
  public
    aDay: TDateTime;
  end;

  THolidays = class(TCollection)
  private
    FWorkingDaysInYear : Integer;     

  public
    constructor Create;

      // load holiday file
    function Load(stFileName : String) : Boolean;

      // check if a certain data is a holiday
    function IsHoliday(aDate : TDateTime): Boolean;

      // calculate days(floating) left to expiration
    function CalcDaysToExp(DateFrom, DateTo: TDateTime; aType: TRdCalcType;
        bInYear: Boolean = True): Double;

    function CalcDaysToExp2(DateFrom, DateTo: TDateTime): Double;

    function CalcTimeToExp(DateFrom, DateTo: TDateTime): Double;

    function CalcDateTimeOfRemDays(dRemDays : Double; DateTo : TDateTime;
        aType : TRdCalcType): TDateTime;
    function CalcUnderRatio(MatureDate: Double; rcCalcDate: TRdCalcType): Double;

    function GetHoliDays(DateFrom, DateTo: TDateTime): Integer;
    function GetTrdRmDays(DateFrom, DateTo: TDateTime): Integer;
    function GetWorkingDaysInYear(iDateFrom: integer): integer;

      // business day in a year
    property WorkingDaysInYear : Integer read FWorkingDaysInYear;
  end;

implementation

uses GleLib;

//---------------------------------------------------------------------< init >

constructor THolidays.Create;
begin
  inherited Create(THoliday);

  FWorkingDaysInYear := 250;
end;

//---------------------------------------------------------------------< load >

//
// The file keeps holidays excluding the weekends
//
function THolidays.Load(stFileName: String): boolean;
var
  FH: TextFile;
  stRead: String;

  iDate, i   : Integer;
  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�
begin
  {$I-}
  try
    AssignFile(FH, stFileName);
    if not FileExists(stFileName) then
    begin
      Result := False;
      Exit;
    end;

    Reset(FH);
    Readln(FH, stRead);
    while not EOF(FH) do
    begin
      with Add as THoliday do
        aDay:= StrToDate(stRead);
      Readln(FH, stRead);
    end;
    CloseFile(FH);
  except
    Result := False;
    Exit;
  end;
  {$I+}

    //
  iCalRmDays := 365;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := Floor(Date) + iCalRmDays div 7 * 7 to Floor(Date)+365 do
  begin
    if (DayOfWeek(iDate) in [1,7]) then
        iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= Floor(Date) then
      begin
        if iDate > Floor(Date)+365 then
                break;
        iHolidays := iHolidays + 1;
      end;
  end;

  // �ŷ��ϼ��� �޷��ϼ����� �������� ���� ���Ѵ�.
  FWorkingDaysInYear := iCalRmDays - iHolidays;

  Result := True;
end;


function THolidays.IsHoliday(aDate : TDateTime) : Boolean;
var
  i, iDate, iHoliday : Integer;
begin
  Result := False;

  if DayOfWeek(aDate) in [1,7] then // Sunday, Saturday
    Result := True
  else
  begin
    iDate := Floor(aDate);

    for i:=0 to Count-1 do
    begin
      iHoliday := Floor((Items[i] as THoliday).aDay);
      if iHoliday >= iDate then
      begin
        Result := (iHoliday = iDate);
        Break
      end;
    end;
  end;
end;


function THolidays.CalcDaysToExp(DateFrom, DateTo: TDateTime;
  aType: TRdCalcType; bInYear : Boolean=True): double;
{
  CalcRmDays	: �����ϼ��� ����Ѵ�. 365�� �ŷ��ϼ�(243)���� ���� ���� ���ϵȴ�.
  DateFrom	: �����ϼ� �������
  DateTo		: ������ ������
  type		: �����ϼ� �����
                          rcCalDate :�޷���+��¥����
                          rcCalTime :�޷���+�ð�����
                          rcTrdDate :�ŷ���+��¥����
                          rcTrdTime :�ŷ���+�ð�����
}

var
  iDateFrom  : Integer;
  iDateTo    : Integer;
  iDate      : Integer;
  i          : Integer;

  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iTrdRmDays : Integer;	// �ŷ��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�
  dTimeAdd   : double;	// �ð��߰���

begin
  iDateFrom := Trunc(DateFrom);
  iDateTo := Trunc(DateTo);

  dTimeAdd := 15/24 - Frac(DateFrom);

  iCalRmDays := iDateTo-iDateFrom+1;
  if aType = rcCalDate then
  begin
    if bInYear then
      Result := iCalRmDays/365
    else
      Result := iCalRmDays;
    Exit;
  end
  else if aType = rcCalTime then
  begin
    if bInYear then
      Result := (iCalRmDays-1+dTimeAdd)/365
    else
      Result := iCalRmDays-1+dTimeAdd;
    Exit;
  end;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := iDateFrom + iCalRmDays div 7 * 7 to iDateTo do
  begin
    if (DayOfWeek(iDate) in [1,7]) then
        iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= iDateFrom then
      begin
        if iDate > iDateTo then
                break;
        iHolidays := iHolidays + 1;
      end;
  end;

  // �ŷ��ϼ��� �޷��ϼ����� �������� ���� ���Ѵ�.
  iTrdRmDays := iCalRmDays - iHolidays;

  if aType = rcTrdDate then
    if bInYear then
      Result := iTrdRmDays/FWorkingDaysInYear
    else
      Result := iTrdRmDays
  else
    if bInYear then
      Result := (iTrdRmDays-1+dTimeAdd)/FWorkingDaysInYear
    else
      Result := (iTrdRmDays-1+dTimeAdd);
end;




function THolidays.CalcDaysToExp2(DateFrom, DateTo: TDateTime): Double;
{
  CalcRmDays	: �����ϼ��� ����Ѵ�. 365�� �ŷ��ϼ�(243)���� ���� ���� ���ϵȴ�.
  DateFrom	: �����ϼ� �������
  DateTo		: ������ ������
  type		: �����ϼ� �����
                          rcCalDate :�޷���+��¥����
                          rcCalTime :�޷���+�ð�����
                          rcTrdDate :�ŷ���+��¥����
                          rcTrdTime :�ŷ���+�ð�����
}

var
  iDateFrom  : Integer;
  iDateTo    : Integer;
  iDate      : Integer;
  i          : Integer;

  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iTrdRmDays : Integer;	// �ŷ��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�
  dTimeAdd   : double;	// �ð��߰���

  aType :  TRdCalcType;
  bInYear : boolean;
begin
  bInYear := true;
  aType := rcTrdTime;
  iDateFrom := Trunc(DateFrom);
  iDateTo := Trunc(DateTo);

  dTimeAdd := 15/24 - Frac(DateFrom);

  iCalRmDays := iDateTo-iDateFrom+1;
  if aType = rcCalDate then
  begin
    if bInYear then
      Result := iCalRmDays/365
    else
      Result := iCalRmDays;
    Exit;
  end
  else if aType = rcCalTime then
  begin
    if bInYear then
      Result := (iCalRmDays-1+dTimeAdd)/365
    else
      Result := iCalRmDays-1+dTimeAdd;
    Exit;
  end;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := iDateFrom + iCalRmDays div 7 * 7 to iDateTo do
  begin
    if (DayOfWeek(iDate) in [1,7]) then
        iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= iDateFrom then
      begin
        if iDate > iDateTo then
                break;
        iHolidays := iHolidays + 1;
      end;
  end;

  // �ŷ��ϼ��� �޷��ϼ����� �������� ���� ���Ѵ�.
  iTrdRmDays := iCalRmDays - iHolidays;

  if aType = rcTrdDate then
    if bInYear then
      Result := iTrdRmDays/FWorkingDaysInYear
    else
      Result := iTrdRmDays
  else
    if bInYear then
      Result := (iTrdRmDays-1+dTimeAdd)/FWorkingDaysInYear
    else
      Result := (iTrdRmDays-1+dTimeAdd);

end;

function THolidays.CalcTimeToExp(DateFrom, DateTo: TDateTime ): Double;
var
  iDateFrom  : Integer;
  iDateTo    : Integer;
  iDate      : Integer;
  i          : Integer;

  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iTrdRmDays : Integer;	// �ŷ��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�
  dTimeAdd   : double;	// �ð��߰���

begin
  iDateFrom := Trunc(DateFrom);
  iDateTo := Trunc(DateTo);

  // 3�ÿ��� ����ð��� ���ش�.
  dTimeAdd := 15/24 - Frac(DateFrom);

  iCalRmDays := iDateTo-iDateFrom+1;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := iDateFrom + iCalRmDays div 7 * 7 to iDateTo do
  begin
    if (DayOfWeek(iDate) in [1,7]) then
      iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= iDateFrom then
      begin
        if iDate > iDateTo then
          break;
        iHolidays := iHolidays + 1;
      end;
  end;

  // �ŷ��ϼ��� �޷��ϼ����� �������� ���� ���Ѵ�.
  iTrdRmDays := iCalRmDays - iHolidays;

  Result := GetRemainDayToSec( iTrdRmDays, dTimeAdd );

end;

function THolidays.CalcUnderRatio(MatureDate: Double; rcCalcDate : TRdCalcType):Double;
begin
  Result := Min(1.0, CalcDaysToExp(Now, MatureDate, rcCalDate, False)/25);
end;

// (public)- sms
//  calc start datetime with remain days and end datetime
//
function THolidays.CalcDateTimeOfRemDays(dRemDays: Double;
  DateTo: TDateTime; aType: TRdCalcType): TDateTime;
var
  i : Integer;

  iDateTo : Integer;  //
  iRemDays : Integer;

  iSearchDate : Integer;  //
  dSearchDateTime : Double;
begin

  iDateTo := Trunc(DateTo);
  iRemDays := Trunc(dRemDays);

  if aType = rcCalDate then
  begin
    Result := iDateTo-iRemDays+1;
    Exit;
  end
  else if aType = rcCalTime then
  begin
    Result := iDateTo - dRemDays + 15/24;
    Exit;
  end;

  if aType  = rcTrdDate then
  begin
    iSearchDate := iDateTo;
    for i := 1 to iRemDays do
    begin
      if i <> 1 then
        iSearchDate := iSearchDate - 1;

      while(IsHoliday(iSearchDate)) do
        iSearchDate := iSearchDate - 1;
    end;
    Result := iSearchDate;
    Exit;
  end;

  if aType = rcTrdTime then
  begin
    dSearchDateTime := DateTo;
    for i := 1 to iRemDays do
    begin
      //if i <> 1 then
      dSearchDateTime := dSearchDateTime -1;
      while(IsHoliday(dSearchDateTime)) do
        dSearchDateTime := dSearchDateTime-1;
    end;

    dSearchDateTime := dSearchDateTime - Frac(dRemDays);

    while(IsHoliday(dSearchDateTime)) do
      dSearchDateTime := dSearchDateTime-1;

    Result := dSearchDateTime;
    Exit;
  end;

end;


function THolidays.GetWorkingDaysInYear(  iDateFrom : integer): integer;
var

  iDate, i   : Integer;
  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�
begin
  iCalRmDays := 365;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := Floor(iDateFrom) + iCalRmDays div 7 * 7 to Floor(iDateFrom)+365 do
  begin
    if (DayOfWeek(iDateFrom) in [1,7]) then
        iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= Floor(iDateFrom) then
      begin
        if iDate > Floor(iDateFrom)+365 then
                break;
        iHolidays := iHolidays + 1;

      end;
  end;

  // �ŷ��ϼ��� �޷��ϼ����� �������� ���� ���Ѵ�.
  FWorkingDaysInYear := iCalRmDays - iHolidays;
  result :=  FWorkingDaysInYear;
end;

function THolidays.GetHoliDays(DateFrom, DateTo: TDateTime): Integer;
var
  iDateFrom  : Integer;
  iDateTo    : Integer;
  iDate      : Integer;
  i          : Integer;

  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�

begin

  iDateFrom := Trunc(DateFrom);
  iDateTo := Trunc(DateTo);

  iCalRmDays := iDateTo-iDateFrom+1;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := iDateFrom + iCalRmDays div 7 * 7 to iDateTo do
  begin
    if (DayOfWeek(iDate) in [1,7]) then
        iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= iDateFrom then
      begin
        if iDate > iDateTo then
                break;
        iHolidays := iHolidays + 1;
      end;
  end;

  Result := iHolidays;
end;

function THolidays.GetTrdRmDays(DateFrom, DateTo: TDateTime): Integer;
var
  iDateFrom  : Integer;
  iDateTo    : Integer;
  iDate      : Integer;
  i          : Integer;

  iCalRmDays : Integer;	// �޷��ϱ���+��¥���� �����ϼ�
  iHolidays  : Integer;	// �ܿ��Ⱓ������ �����ϼ�

begin

  iDateFrom := Trunc(DateFrom);
  iDateTo := Trunc(DateTo);

  iCalRmDays := iDateTo-iDateFrom+1;

  // �ִ� 2�Ͼ� �����ϼ��� ������Ų��.
  iHolidays := iCalRmDays div 7 * 2;

  // �������Ⱓ�� ������̳� �Ͽ����� ������ �����ϼ��� ������Ų��.
  for iDate := iDateFrom + iCalRmDays div 7 * 7 to iDateTo do
  begin
    if (DayOfWeek(iDate) in [1,7]) then
        iHolidays := iHolidays + 1;
  end;

  // ��,�� �̿��� ������������ �Ⱓ�߿� ������ �����ϼ��� ������Ų��.
  for i:=0 to Count-1 do
  begin
    iDate := Trunc((Items[i] as THoliday).aDay);
    if iDate >= iDateFrom then
      begin
        if iDate > iDateTo then
                break;
        iHolidays := iHolidays + 1;
      end;
  end;

  // �ŷ��ϼ��� �޷��ϼ����� �������� ���� ���Ѵ�.
  Result := iCalRmDays - iHolidays;

end;

end.
