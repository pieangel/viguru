unit KOrderConst;

interface

uses Messages, CleSymbols, CleQuoteBroker, Windows;


type
  TKActionType = (//신규주문
                  atNewLong1{신규매수:매도1},
                  atNewLong2{신규매수:매도2},
                  atNewLong3{신규매수:매수1},
                  atNewLong4{신규매수:매수1+1틱},
                  atNewLong5{신규매수:매수1+2틱},
                  atNewLong6{신규매수:현재가},
                  atNewShort1{신규매도:매수1},
                  atNewShort2{신규매도:매수2},
                  atNewShort3{신규매도:매도1},
                  atNewShort4{신규매도:매도1-1틱},
                  atNewShort5{신규매도:매도1-2틱},
                  atNewShort6{신규매도:현재가},
                  // 이익청산
                  atProfitExit1{이익청산:1틱},
                  atProfitExit2{이익청산:2틱},
                  // 청산
                  atClear1{청산:체결1호가},
                  atClear2{청산:체결2호가},
                  atClear3{청산:대기1호가},
                  atClear4{청산:평균단가},
                  //전매
                  atSellExit1,//전매도:매도1-1틱
                  atSellExit2,//전매도:매수1+1틱
                  atSellExit3,//전매도:매수1
                  //환매
                  atBuyExit1,//환매수:매수1+1틱
                  atBuyExit2,//환매수:매도1-1틱
                  atBuyExit3,//환매수:매도1
                  // 취소주문
                  atCancelAll{전체취소},
                  atCancelLast{최근주문취소},
                  atCancelNotLast{최근주문외 전부취소},
                  atCancelShort{매도주문전부취소},
                  atCancelLong{매수주문전부취소},
                  // 정정주문
                  atChangeLong1{매수정정:매도1},
                  atChangeLong2{매수정정:매도2},
                  atChangeLong3{매수정정:매수1},
                  atChangeLong4{매수정정:매수1+1틱},
                  atChangeLong5{매수정정:매수1+2틱},
                  atChangeLong6{매수정정:현재가},
                  atChangeLong7{매수정정:주문가+1틱},
                  atChangeLong8{매수정정:주문가+2틱},
                  atChangeShort1{매도정정:매수1},
                  atChangeShort2{매도정정:매수2},
                  atChangeShort3{매도정정:매도1},
                  atChangeShort4{매도정정:매도1-1틱},
                  atChangeShort5{매도정정:매도1-2틱},
                  atChangeShort6{매도정정:현재가},
                  atChangeShort7{매도정정:주문가-1틱},
                  atChangeShort8{매도정정:주문가-2틱},
                  //
                  atQtyDelta{옵션델타수량},
                  atQty1 {수량1},
                  atQty2 {수량2},
                  atQty3 {수량3},
                  atQty4 {수량4},
                  atQty5 {수량5},
                  atQty6 {수량6},
                  atQty7 {잔량/5},
                  atQty8 {잔량/4},
                  atQty9 {잔량/3},
                  atQty10{잔량/2},
                  atQty11{잔량전체},
                  atNull);
                  
  TSimpleSymbol = record
    Code : String;
    Quote : TQuoteUnit;
//    Price : TPriceRec;
    Precision : Integer; // 현재가를 표시하는 단위
    C : Double;
    RecvTime : TDateTime;
  end;



const
  ACTION_COUNT  = 59;
  atFirst  = atNewLong1;
  atLast   = atQty11;
  KEY_DESC : array[TKActionType] of String =
                ('신규매수:매도1',
                 '신규매수:매도2',
                 '신규매수:매수1',
                 '신규매수:매수1+1틱',
                 '신규매수:매수1+2틱',
                 '신규매수:현재가',
                 '신규매도:매수1',
                 '신규매도:매수2',
                 '신규매도:매도1',
                 '신규매도:매도1-1틱',
                 '신규매도:매도1-2틱',
                 '신규매도:현재가',
                 '이익청산:1틱',
                 '이익청산:2틱',
                 '청산:체결1호가',
                 '청산:체결2호가',
                 '청산:대기1호가',
                 '청산:평균단가',
                 '전매도:매도1-1틱',
                 '전매도:매수1+1틱',
                 '전매도:매수1',
                 '환매수:매수1+1틱',
                 '환매수:매도1-1틱',
                 '환매수:매도1',
                 '전체취소',
                 '최근주문취소',
                 '최근주문외전부취소',
                 '매도주문전부취소',
                 '매수주문전부취소',
                 '매수정정:매도1',
                 '매수정정:매도2',
                 '매수정정:매수1',
                 '매수정정:매수1+1틱',
                 '매수정정:매수1+2틱',
                 '매수정정:현재가',
                 '매수정정:주문가+1틱',
                 '매수정정:주문가+2틱',
                 '매도정정:매수1',
                 '매도정정:매수2',
                 '매도정정:매도1',
                 '매도정정:매도1-1틱',
                 '매도정정:매도1-2틱',
                 '매도정정:현재가',
                 '매도정정:주문가-1틱',
                 '매도정정:주문가-2틱',
                 '옵션델타수량',
                 '수량1',
                 '수량2',
                 '수량3',
                 '수량4',
                 '수량5',
                 '수량6',
                 '잔량전체',
                 '잔량/2',
                 '잔량/3',
                 '잔량/4',
                 '잔량/5',
                 '');
  KEY_TYPES : array[TKActionType] of String =
                 ('atNewLong1', {신규매수:매도1}
                  'atNewLong2',{신규매수:매도2}
                  'atNewLong3',{신규매수:매수1}
                  'atNewLong4',{신규매수:매수1+1틱}
                  'atNewLong5',{신규매수:매수1+2틱}
                  'atNewLong6',{신규매수:현재가}
                  'atNewShort1',{신규매도:매수1}
                  'atNewShort2',{신규매도:매수2}
                  'atNewShort3',{신규매도:매도1}
                  'atNewShort4',{신규매도:매도1-1틱}
                  'atNewShort5',{신규매도:매도1-2틱}
                  'atNewShort6',{신규매도:현재가}
                  // 이익청산
                  'atProfitExit1',{이익청산:1틱}
                  'atProfitExit2',{이익청산:2틱}
                  // 청산
                  'atClear1',{청산:체결1호가}
                  'atClear2',{청산:체결2호가}
                  'atClear3',{청산:대기1호가}
                  'atClear4',{청산:평균단가}
                  //전매
                  'atSellExit1',//전매도:매도1-1틱
                  'atSellExit2',//전매도:매수1+1틱
                  'atSellExit3',//전매도:매수1
                  //환매
                  'atBuyExit1',//환매수:매수1+1틱
                  'atBuyExit2',//환매수:매도1-1틱
                  'atBuyExit3',//환매수:매도1
                  // 취소주문
                  'atCancelAll',{전체취소}
                  'atCancelLast',{최근주문취소}
                  'atCancelNotLast',{최근주문외 전부취소}
                  'atCancelShort',{매도주문전부취소}
                  'atCancelLong',{매수주문전부취소}
                  // 정정주문
                  'atChangeLong1',{매수정정:매도1}
                  'atChangeLong2',{매수정정:매도2}
                  'atChangeLong3',{매수정정:매수1}
                  'atChangeLong4',{매수정정:매수1+1틱}
                  'atChangeLong5',{매수정정:매수1+2틱}
                  'atChangeLong6',{매수정정:현재가}
                  'atChangeLong7',{매수정정:주문가+1틱}
                  'atChangeLong8',{매수정정:주문가+2틱}
                  'atChangeShort1',{매도정정:매수1}
                  'atChangeShort2',{매도정정:매수2}
                  'atChangeShort3',{매도정정:매도1}
                  'atChangeShort4',{매도정정:매도1-1틱}
                  'atChangeShort5',{매도정정:매도1-2틱}
                  'atChangeShort6',{매도정정:현재가}
                  'atChangeShort7',{매도정정:주문가-1틱}
                  'atChangeShort8',{매도정정:주문가-2틱}
                  //
                  'atQtyDelta',{옵션델타수량}
                  'atQty1', {수량1}
                  'atQty2', {수량2}
                  'atQty3', {수량3}
                  'atQty4', {수량4}
                  'atQty5', {수량5}
                  'atQty6', {수량6}
                  'atQty7', {잔량전체}
                  'atQty8', {잔량/2}
                  'atQty9', {잔량/3}
                  'atQty10',{잔량/4}
                  'atQty11',{잔량/5}
                  'atNull');

function KeyActionfindByDesc(stDesc : String) : TKActionType; forward;
function KeyActionfindByAction(aAction : TKActionType) : String;  forward;
function KeyActionfindByTyesDesc(stDesc : String) : TKActionType; forward;


procedure NUMPADtoNUM(var Key : Word); forward;
procedure AscPressToDown(var Key: Word); forward;

implementation

uses SysUtils;



//
//  명칭으로 찾기
//
function KeyActionfindByDesc(stDesc : String) : TKActionType;
var
  aValue : TKActionType;
//  atFirst  = atNewLong1;
//  atLast   = atQtyOption11;
begin
  Result := atNull;

  for aValue := atFirst to atLast do
    if CompareStr(KEY_DESC[aValue], stDesc) = 0  then
    begin
      Result := aValue;
      Exit;
    end;

end;


function KeyActionfindByAction(aAction : TKActionType) : String;
begin
  Result := '';
end;

function KeyActionfindByTyesDesc(stDesc : String) : TKActionType;
var
  aValue : TKActionType;
begin
  Result := atNull;

  for aValue := atFirst to atLast do
    if CompareStr(KEY_TYPES[aValue], stDesc) = 0  then
    begin
      Result := aValue;
      Exit;
    end;
end;


procedure NUMPADtoNUM(var Key : Word);
begin
  if Key = VK_NUMPAD0 then Key := Ord('0');
  if Key = VK_NUMPAD1 then Key := Ord('1');
  if Key = VK_NUMPAD2 then Key := Ord('2');
  if Key = VK_NUMPAD3 then Key := Ord('3');
  if Key = VK_NUMPAD4 then Key := Ord('4');
  if Key = VK_NUMPAD5 then Key := Ord('5');
  if Key = VK_NUMPAD6 then Key := Ord('6');
  if Key = VK_NUMPAD7 then Key := Ord('7');
  if Key = VK_NUMPAD8 then Key := Ord('8');
  if Key = VK_NUMPAD9 then Key := Ord('9');
end;


const
  KeyPressValues : array[1..10] of Integer = ( 191,190,188,222,186,221,219,220,187,189 );
  KeyDownValues  : array[1..10] of Integer = ( 47,46,44,39,59,93,91,92,61,45);

procedure AscPressToDown(var Key: Word);
var
  i : Integer;
begin
{/ 191 , 47
.  190 , 46
,  188 , 44
'  222 , 39
;  186 , 59
]  221 , 93
[  219 , 91
\  220 , 92
=  187 , 61
-  189 , 45}

  for i:=1 to 10 do
    if Key = KeyPressValues[i] then
    begin
      Key := KeyDownValues[i];
      Break;
    end;

end;



end.

