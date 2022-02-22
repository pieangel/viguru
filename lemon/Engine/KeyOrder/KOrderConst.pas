unit KOrderConst;

interface

uses Messages, CleSymbols, CleQuoteBroker, Windows;


type
  TKActionType = (//�ű��ֹ�
                  atNewLong1{�űԸż�:�ŵ�1},
                  atNewLong2{�űԸż�:�ŵ�2},
                  atNewLong3{�űԸż�:�ż�1},
                  atNewLong4{�űԸż�:�ż�1+1ƽ},
                  atNewLong5{�űԸż�:�ż�1+2ƽ},
                  atNewLong6{�űԸż�:���簡},
                  atNewShort1{�űԸŵ�:�ż�1},
                  atNewShort2{�űԸŵ�:�ż�2},
                  atNewShort3{�űԸŵ�:�ŵ�1},
                  atNewShort4{�űԸŵ�:�ŵ�1-1ƽ},
                  atNewShort5{�űԸŵ�:�ŵ�1-2ƽ},
                  atNewShort6{�űԸŵ�:���簡},
                  // ����û��
                  atProfitExit1{����û��:1ƽ},
                  atProfitExit2{����û��:2ƽ},
                  // û��
                  atClear1{û��:ü��1ȣ��},
                  atClear2{û��:ü��2ȣ��},
                  atClear3{û��:���1ȣ��},
                  atClear4{û��:��մܰ�},
                  //����
                  atSellExit1,//���ŵ�:�ŵ�1-1ƽ
                  atSellExit2,//���ŵ�:�ż�1+1ƽ
                  atSellExit3,//���ŵ�:�ż�1
                  //ȯ��
                  atBuyExit1,//ȯ�ż�:�ż�1+1ƽ
                  atBuyExit2,//ȯ�ż�:�ŵ�1-1ƽ
                  atBuyExit3,//ȯ�ż�:�ŵ�1
                  // ����ֹ�
                  atCancelAll{��ü���},
                  atCancelLast{�ֱ��ֹ����},
                  atCancelNotLast{�ֱ��ֹ��� �������},
                  atCancelShort{�ŵ��ֹ��������},
                  atCancelLong{�ż��ֹ��������},
                  // �����ֹ�
                  atChangeLong1{�ż�����:�ŵ�1},
                  atChangeLong2{�ż�����:�ŵ�2},
                  atChangeLong3{�ż�����:�ż�1},
                  atChangeLong4{�ż�����:�ż�1+1ƽ},
                  atChangeLong5{�ż�����:�ż�1+2ƽ},
                  atChangeLong6{�ż�����:���簡},
                  atChangeLong7{�ż�����:�ֹ���+1ƽ},
                  atChangeLong8{�ż�����:�ֹ���+2ƽ},
                  atChangeShort1{�ŵ�����:�ż�1},
                  atChangeShort2{�ŵ�����:�ż�2},
                  atChangeShort3{�ŵ�����:�ŵ�1},
                  atChangeShort4{�ŵ�����:�ŵ�1-1ƽ},
                  atChangeShort5{�ŵ�����:�ŵ�1-2ƽ},
                  atChangeShort6{�ŵ�����:���簡},
                  atChangeShort7{�ŵ�����:�ֹ���-1ƽ},
                  atChangeShort8{�ŵ�����:�ֹ���-2ƽ},
                  //
                  atQtyDelta{�ɼǵ�Ÿ����},
                  atQty1 {����1},
                  atQty2 {����2},
                  atQty3 {����3},
                  atQty4 {����4},
                  atQty5 {����5},
                  atQty6 {����6},
                  atQty7 {�ܷ�/5},
                  atQty8 {�ܷ�/4},
                  atQty9 {�ܷ�/3},
                  atQty10{�ܷ�/2},
                  atQty11{�ܷ���ü},
                  atNull);
                  
  TSimpleSymbol = record
    Code : String;
    Quote : TQuoteUnit;
//    Price : TPriceRec;
    Precision : Integer; // ���簡�� ǥ���ϴ� ����
    C : Double;
    RecvTime : TDateTime;
  end;



const
  ACTION_COUNT  = 59;
  atFirst  = atNewLong1;
  atLast   = atQty11;
  KEY_DESC : array[TKActionType] of String =
                ('�űԸż�:�ŵ�1',
                 '�űԸż�:�ŵ�2',
                 '�űԸż�:�ż�1',
                 '�űԸż�:�ż�1+1ƽ',
                 '�űԸż�:�ż�1+2ƽ',
                 '�űԸż�:���簡',
                 '�űԸŵ�:�ż�1',
                 '�űԸŵ�:�ż�2',
                 '�űԸŵ�:�ŵ�1',
                 '�űԸŵ�:�ŵ�1-1ƽ',
                 '�űԸŵ�:�ŵ�1-2ƽ',
                 '�űԸŵ�:���簡',
                 '����û��:1ƽ',
                 '����û��:2ƽ',
                 'û��:ü��1ȣ��',
                 'û��:ü��2ȣ��',
                 'û��:���1ȣ��',
                 'û��:��մܰ�',
                 '���ŵ�:�ŵ�1-1ƽ',
                 '���ŵ�:�ż�1+1ƽ',
                 '���ŵ�:�ż�1',
                 'ȯ�ż�:�ż�1+1ƽ',
                 'ȯ�ż�:�ŵ�1-1ƽ',
                 'ȯ�ż�:�ŵ�1',
                 '��ü���',
                 '�ֱ��ֹ����',
                 '�ֱ��ֹ����������',
                 '�ŵ��ֹ��������',
                 '�ż��ֹ��������',
                 '�ż�����:�ŵ�1',
                 '�ż�����:�ŵ�2',
                 '�ż�����:�ż�1',
                 '�ż�����:�ż�1+1ƽ',
                 '�ż�����:�ż�1+2ƽ',
                 '�ż�����:���簡',
                 '�ż�����:�ֹ���+1ƽ',
                 '�ż�����:�ֹ���+2ƽ',
                 '�ŵ�����:�ż�1',
                 '�ŵ�����:�ż�2',
                 '�ŵ�����:�ŵ�1',
                 '�ŵ�����:�ŵ�1-1ƽ',
                 '�ŵ�����:�ŵ�1-2ƽ',
                 '�ŵ�����:���簡',
                 '�ŵ�����:�ֹ���-1ƽ',
                 '�ŵ�����:�ֹ���-2ƽ',
                 '�ɼǵ�Ÿ����',
                 '����1',
                 '����2',
                 '����3',
                 '����4',
                 '����5',
                 '����6',
                 '�ܷ���ü',
                 '�ܷ�/2',
                 '�ܷ�/3',
                 '�ܷ�/4',
                 '�ܷ�/5',
                 '');
  KEY_TYPES : array[TKActionType] of String =
                 ('atNewLong1', {�űԸż�:�ŵ�1}
                  'atNewLong2',{�űԸż�:�ŵ�2}
                  'atNewLong3',{�űԸż�:�ż�1}
                  'atNewLong4',{�űԸż�:�ż�1+1ƽ}
                  'atNewLong5',{�űԸż�:�ż�1+2ƽ}
                  'atNewLong6',{�űԸż�:���簡}
                  'atNewShort1',{�űԸŵ�:�ż�1}
                  'atNewShort2',{�űԸŵ�:�ż�2}
                  'atNewShort3',{�űԸŵ�:�ŵ�1}
                  'atNewShort4',{�űԸŵ�:�ŵ�1-1ƽ}
                  'atNewShort5',{�űԸŵ�:�ŵ�1-2ƽ}
                  'atNewShort6',{�űԸŵ�:���簡}
                  // ����û��
                  'atProfitExit1',{����û��:1ƽ}
                  'atProfitExit2',{����û��:2ƽ}
                  // û��
                  'atClear1',{û��:ü��1ȣ��}
                  'atClear2',{û��:ü��2ȣ��}
                  'atClear3',{û��:���1ȣ��}
                  'atClear4',{û��:��մܰ�}
                  //����
                  'atSellExit1',//���ŵ�:�ŵ�1-1ƽ
                  'atSellExit2',//���ŵ�:�ż�1+1ƽ
                  'atSellExit3',//���ŵ�:�ż�1
                  //ȯ��
                  'atBuyExit1',//ȯ�ż�:�ż�1+1ƽ
                  'atBuyExit2',//ȯ�ż�:�ŵ�1-1ƽ
                  'atBuyExit3',//ȯ�ż�:�ŵ�1
                  // ����ֹ�
                  'atCancelAll',{��ü���}
                  'atCancelLast',{�ֱ��ֹ����}
                  'atCancelNotLast',{�ֱ��ֹ��� �������}
                  'atCancelShort',{�ŵ��ֹ��������}
                  'atCancelLong',{�ż��ֹ��������}
                  // �����ֹ�
                  'atChangeLong1',{�ż�����:�ŵ�1}
                  'atChangeLong2',{�ż�����:�ŵ�2}
                  'atChangeLong3',{�ż�����:�ż�1}
                  'atChangeLong4',{�ż�����:�ż�1+1ƽ}
                  'atChangeLong5',{�ż�����:�ż�1+2ƽ}
                  'atChangeLong6',{�ż�����:���簡}
                  'atChangeLong7',{�ż�����:�ֹ���+1ƽ}
                  'atChangeLong8',{�ż�����:�ֹ���+2ƽ}
                  'atChangeShort1',{�ŵ�����:�ż�1}
                  'atChangeShort2',{�ŵ�����:�ż�2}
                  'atChangeShort3',{�ŵ�����:�ŵ�1}
                  'atChangeShort4',{�ŵ�����:�ŵ�1-1ƽ}
                  'atChangeShort5',{�ŵ�����:�ŵ�1-2ƽ}
                  'atChangeShort6',{�ŵ�����:���簡}
                  'atChangeShort7',{�ŵ�����:�ֹ���-1ƽ}
                  'atChangeShort8',{�ŵ�����:�ֹ���-2ƽ}
                  //
                  'atQtyDelta',{�ɼǵ�Ÿ����}
                  'atQty1', {����1}
                  'atQty2', {����2}
                  'atQty3', {����3}
                  'atQty4', {����4}
                  'atQty5', {����5}
                  'atQty6', {����6}
                  'atQty7', {�ܷ���ü}
                  'atQty8', {�ܷ�/2}
                  'atQty9', {�ܷ�/3}
                  'atQty10',{�ܷ�/4}
                  'atQty11',{�ܷ�/5}
                  'atNull');

function KeyActionfindByDesc(stDesc : String) : TKActionType; forward;
function KeyActionfindByAction(aAction : TKActionType) : String;  forward;
function KeyActionfindByTyesDesc(stDesc : String) : TKActionType; forward;


procedure NUMPADtoNUM(var Key : Word); forward;
procedure AscPressToDown(var Key: Word); forward;

implementation

uses SysUtils;



//
//  ��Ī���� ã��
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

