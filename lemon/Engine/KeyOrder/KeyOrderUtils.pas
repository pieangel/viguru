unit KeyOrderUtils;

interface

uses
  Windows, Classes, SysUtils;


function ConvertVKToString(VK_Key : Integer; iIndex : Integer) : String; forward;
function ConvertStringToVk(strVK  : String) : Integer; forward;
function ConvertShiftToString(aShift : TShiftState) : String; forward;


implementation


// function ConvertShift
// 2006-10-10
// jaebeom
function ConvertShiftToString(aShift : TShiftState) : String;
begin
  if ssCtrl in aShift     then  Result := 'Ctrl'
  else if ssAlt in aShift then  Result := 'Alt'
  else Result := 'NO';
end;


// function VK Key to String Value
// 2006-10-09
// Jaebeom
function ConvertVKToString(VK_Key : Integer; iIndex : Integer) : String;
begin
  case VK_Key of
    VK_F2 : Result := 'F2';
    VK_F3 : Result := 'F3';
    VK_F4 : Result := 'F4';
    VK_F5 : Result := 'F5';
    VK_F6 : Result := 'F6';
    VK_F7 : Result := 'F7';
    VK_F8 : Result := 'F8';
    VK_F9 : Result := 'F9';
    VK_F10 : Result := 'F10';
    VK_F11 : Result := 'F11';
    VK_F12 : Result := 'F12';
    else Result := '';
  end;

  case iIndex of
    1 : Result := Result + '_A';
    2 : Result := Result + '_S';
  end; 
end;


// function  String Value to VK Key Value
// 2006-10-09
// jaeboem
function ConvertStringToVK(strVK  : String) : Integer;
begin
  if (CompareStr(strVK, 'F2_A') = 0) or (CompareStr(strVK, 'F2_S') = 0) then
    Result := VK_F2
  else if (CompareStr(strVK, 'F3_A') = 0) or (CompareStr(strVK, 'F3_S') = 0) then
    Result := VK_F3
  else if (CompareStr(strVK, 'F4_A') = 0) or (CompareStr(strVK, 'F4_S') = 0)  then
    Result := VK_F4
  else if (CompareStr(strVK, 'F5_A') = 0) or (CompareStr(strVK, 'F5_S') = 0)  then
    Result := VK_F5
  else if (CompareStr(strVK, 'F6_A') = 0) or (CompareStr(strVK, 'F6_S') = 0)  then
    Result := VK_F6
  else if (CompareStr(strVK, 'F7_A') = 0) or (CompareStr(strVK, 'F7_S') = 0)  then
    Result := VK_F7
  else if (CompareStr(strVK, 'F8_A') = 0) or (CompareStr(strVK, 'F8_S') = 0)  then
    Result := VK_F8
  else if (CompareStr(strVK, 'F9_A') = 0) or (CompareStr(strVK, 'F9_S') = 0)  then
    Result := VK_F9
  else if (CompareStr(strVK, 'F10_A') = 0) or (CompareStr(strVK, 'F10_S') = 0)  then
    Result := VK_F10
  else if (CompareStr(strVK, 'F11_A') = 0) or (CompareStr(strVK, 'F11_S') = 0)  then
    Result := VK_F11
  else if (CompareStr(strVK, 'F12_A') = 0) or (CompareStr(strVK, 'F12_S') = 0)  then
    Result := VK_F12;
end;


end.
