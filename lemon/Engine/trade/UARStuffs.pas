unit UARStuffs;

interface

uses
  Classes, CleSymbols;
type

  TOrderUnit = class(TObject)
  public
    m_iGID:     integer;      // 주문그룹아이디
    m_bFromDB:  boolean;      // DB로부터 읽은 데이타인지 여부
    m_tDate:    TDateTime;    // 체결날짜시각
    m_oPrdt:    TSymbol;     // 종목
    m_stCode:   string;       // 종목코드(결제일지난종목일경우 메모리에 없으니까 코드라도..)
    m_stLS:     string;       // 'L'매수  'S':매도
    m_iNewQty:  integer;      // 신규수량
    m_iClearQty: integer;     // 청산수량
    m_fNewPrice: double;      // 신규체결가
    m_fClearPrice: double;    // 청산체결가
    m_fCurrent: double;       // 현재가

    m_fNewAmt: double;        // 신규체결금액
    m_fClearAmt: double;      // 청산체결금액

    m_oPartner: TOrderUnit;   // 박스일경우 동일행사가의 옵션Unit
 //   m_dOpenPL: double;       // 평가손익
    constructor Create();
    destructor  Destroy;


    function  GetActiveQty: integer;
    function  CalcOpenPL: double;
    function  CalcFixedPL: double;
    function  GetStrikePrice: double;
    function  GetRemainAmt: double;
    property m_iQty: Integer read GetActiveQty;
    property m_dOpenPL: double read CalcOpenPL;
    property m_dFixedPL: double read CalcFixedPL;
    property m_dStrike: double read GetStrikePrice;
    property m_dAmt: double read GetRemainAmt;
  end;

  TSetState = ( ssFail, ssSuccess, ssRollbacked, ssWait );
  TOrderSet = class(TObject)
  public
    m_bFromDB: boolean;       // DB로부터 읽은 데이타인지 여부
    m_stDiv:    string;       // 구분 'FCP' or 'BOX'
    m_tDate:    TDateTime;    // 날짜
    m_iGID:     integer;      // 그룹ID
    m_dFixedPL: double;       // 확정손익
    m_dOpenPL:  double;       // 평가손익
    m_state:    TSetState;    // 상태: 실패, 성공, 롤백됨, 처리대기
    m_oCallS: TOrderUnit;     // CALL 매도
    m_oCallL: TOrderUnit;     // PUT  매수
    m_iOptQty: Integer;

    m_oFut: TOrderUnit;       // FCP일때만 사용
    m_oCall: TOrderUnit;      // FCP일때만 사용
    m_oPut: TOrderUnit;       // FCP일때만 사용

    m_lstUnit:  TList;        // 주문유닛리스트

    constructor Create();
    destructor  Destroy;

    function  GetOptionQty: Integer;
    function  CalcOpenPL: double;
    function  CalcFixedPL: double;
    procedure MakePLInfra( oUnit: TOrderUnit );
    procedure ProcessState;
    procedure ClearUnits;
    function  FindUnit( stCode: string): TOrderUnit;

    function  IsFullyFilled(): boolean;    
    function  GetState(): string;
    function  isCON(): boolean;
    function  isREV(): boolean;

    property m_iQty: Integer read GetOptionQty;
    property m_stState: string read GetState;

  end;

  function utRound( dValue: double ): double;
  function utRound2( dValue: double ): double;

implementation
uses SysUtils, CleFQN;


function utRound( dValue: double ): double;
var iSign: Integer;
begin
  result := dValue;
  if dValue = 0 then exit;
  if dValue > 0 then
    iSign := 1
  else iSign := -1;

  dValue := abs(dValue);
  result := trunc(dValue/10 + 0.5) * 10;
  result := result * iSign;

end;


function utRound2( dValue: double ): double;
begin

  //dValue := abs(dValue);
  result := trunc((dValue + 0.005) * 100)/100;

end;

constructor TOrderUnit.Create();
begin
  m_iGID := 0;
  m_iNewQty := 0; m_iClearQty := 0;
  m_fNewPrice := 0.0; m_fCurrent := 0.0;
  m_fClearPrice := 0.0;
  m_bFromDB := false;
  m_fNewAmt := 0.0;
  m_fClearAmt := 0.0;
end;

destructor  TOrderUnit.Destroy;
begin
end;

function  TOrderUnit.GetActiveQty: integer;
begin
  result := m_iNewQty - m_iClearQty;
end;

function TOrderUnit.CalcOpenPL: double;
var dAmount, dEval: double;
begin
  result := 0;
  if m_oPrdt = nil then exit;
  dAmount := m_iQty * m_fNewPrice;
  dEval := m_iQty * m_oPrdt.Last;
  if m_stLS = 'L' then
    result := (dEval - dAmount) * m_oPrdt.Spec.ContractSize
  else result := (dAmount - dEval) * m_oPrdt.Spec.ContractSize;

  result := utRound( result );
end;

function TOrderUnit.CalcFixedPL: double;
var dAmount, dClear, dValue: double;
begin
  result := 0;
  if m_iClearQty = 0 then
    exit;

  dValue := 500000;
  //if m_stCode[1] <> '1' then   // 2012.06.15  100000 -> 500000
    //dValue := 100000;

  if m_iQty = 0 then
  begin
    if m_stLS = 'L' then
      result := (m_fClearAmt - m_fNewAmt) * dValue
    else
      result := (m_fNewAmt - m_fClearAmt) * dValue;
  end else
  begin
    if m_stLS = 'L' then
      result := (m_fClearAmt - (m_fNewAmt/m_iNewQty*m_iClearQty)) * dValue
    else result := ((m_fNewAmt/m_iNewQty*m_iClearQty) - m_fClearAmt) * dValue;
  end;

  result := utRound( result );
end;

function TOrderUnit.GetStrikePrice: double;
var stTmp: string;
begin
  result := 0;
  if m_stCode[1] = '1' then exit;
  stTmp := Copy( m_stCode, 6, 3 );

  result := strToFloat( stTmp );
  if stTmp[3] in ['2','7'] then
  	result := result + 0.5;
end;

function TOrderUnit.GetRemainAmt: double;
begin
  result := m_fNewAmt - m_fClearAmt;
end;

constructor TOrderSet.Create();
begin
  m_iGID := 0;
  m_dFixedPL := 0.0; m_dOpenPL :=0;
  m_state := ssWait;

  m_bFromDB := false;
  m_lstUnit := TList.Create;
end;

destructor  TOrderSet.Destroy;
begin
  ClearUnits;
  m_lstUnit.Free;
end;

function  TOrderSet.IsFullyFilled(): boolean;
begin
  result := false;
  if m_stDiv = 'BOX' then
  begin
    if m_lstUnit.Count <> 4 then exit;
    if  ( TOrderUnit(m_lstUnit.Items[0]).m_iQty +
       TOrderUnit(m_lstUnit.Items[1]).m_iQty ) -
       ( TOrderUnit(m_lstUnit.Items[2]).m_iQty +
       TOrderUnit(m_lstUnit.Items[3]).m_iQty ) <> 0 then
       exit;
  end else
  if m_stDiv = 'FCP' then
  begin
    if m_lstUnit.Count <> 3 then exit;

    if (m_oFut = nil) or (m_oCall = nil) or (m_oPut = nil ) then
    begin
      m_stDiv := 'FCP';
    end;

    if m_oFut = nil then exit; //khw
    if m_oCall = nil then exit; //khw
    if m_oPut = nil then exit; //khw
    //if not ( ( m_oFut.m_iQty * 5  = m_oCall.m_iQty ) and ( m_oCall.m_iQty = m_oPut.m_iQty ) ) then
    if not ( ( m_oFut.m_iQty = m_oCall.m_iQty ) and ( m_oCall.m_iQty = m_oPut.m_iQty ) ) then  //2012/06/15
       exit;
  end;

  result := true;
end;

function  TOrderSet.FindUnit( stCode: string): TOrderUnit;
var i: Integer;
begin
  result := nil;
  for i:=0 to m_lstUnit.Count-1 do
  begin
    if TOrderUnit(m_lstUnit.Items[i]).m_stCode = stCode then
    begin
      result := TOrderUnit(m_lstUnit.Items[i]);
      exit;
    end;
  end;
end;

// '2013C000'
procedure TOrderSet.MakePLInfra( oUnit: TOrderUnit );
var oTmp: TOrderUnit; i: Integer;
begin

  if m_stDiv = 'BOX' then
  begin
    for i:=0 to m_lstUnit.Count-1 do
    begin
      oTmp := TOrderUnit(m_lstUnit.Items[i]);
      if Copy(oTmp.m_oPrdt.ShortCode,7,3) = Copy(oUnit.m_oPrdt.ShortCode,7,3) then
      begin
        oTmp.m_oPartner := oUnit;
        oUnit.m_oPartner := oTmp;
        break;
      end
    end;

    if (oUnit.m_oPrdt.ShortCode[1] = '2') and
      ( oUnit.m_stLS[1] = 'L' ) then
      m_oCallL := oUnit
    else if ( oUnit.m_oPrdt.ShortCode[1] = '2' ) and
      ( oUnit.m_stLS[1] = 'S' ) then
      m_oCallS := oUnit;
  end else if m_stDiv = 'FCP' then
  begin
    {
    if oUnit.m_oPrdt.IsFuture() then
      m_oFut := oUnit
    else if oUnit.m_oPrdt.IsCALL then
      m_oCall := oUnit
    else if oUnit.m_oPrdt.IsPUT then
      m_oPut := oUnit;
    }

    if (oUnit.m_oPrdt.Spec.Market = mtFutures) and ( not oUnit.m_oPrdt.IsStockF) then
      m_oFut := oUnit
    else if oUnit.m_oPrdt.Spec.Market = mtOption then
    begin
      if (oUnit.m_oPrdt as TOption).CallPut = 'C' then
         m_oCall := oUnit
      else if (oUnit.m_oPrdt as TOption).CallPut = 'P' then
        m_oPut := oUnit;
    end;
  end;

end;

// 컨버젼인지 여부
function  TOrderSet.isCON: boolean;
begin
  result := false;

  if m_stDiv = 'FCP' then
  begin
    if (m_oFut <> nil) then begin
      if (m_oFut.m_stLS = 'L' ) then
        result := true;
    end else if (m_oPut <> nil) then begin
      if( m_oPut.m_stLS = 'L' ) then
        result := true;
    end else if (m_oCall <> nil) then begin
      if( m_oCall.m_stLS = 'S') then
        result := true;
    end
  end else if m_stDiv = 'BOX' then
  begin
    if (m_oCallL <> nil) then begin
      if( m_oCallL.m_stLS = 'L') then
      begin
        if (m_oCallS <> nil) and (m_oCallS.m_oPartner <> nil) then
        begin
          if( m_oCallL.m_dStrike < m_oCallS.m_oPartner.m_dStrike ) then
            result := true;
        end;
      end;
    end;
  end;

end;

// 리버졀인지 여부
function  TOrderSet.isREV: boolean;
begin
  result := not isCON;
end;


function  TOrderSet.GetOptionQty: Integer;
var oUnit: TOrderUnit;
begin

  if m_bFromDB then
  begin
    result := m_iOptQty;
    exit;
  end;

  if m_lstUnit.Count > 0 then
  begin
    oUnit := TOrderUnit(m_lstUnit.Items[0]);
    {
    if oUnit.m_stCode[1] = '1' then
      result := oUnit.m_iQty * 5
    else result := oUnit.m_iQty;
    }

    result := oUnit.m_iQty;
  end;
end;

function  TOrderSet.CalcOpenPL: double;
var i: Integer; oUnit: TOrderUnit; dTotPL : double;
begin
  dTotPL := 0;
  if m_state <> ssWait then
    exit;
  for i:=0 to m_lstUnit.Count-1 do
  begin
    oUnit := TOrderUnit(m_lstUnit.Items[i]);
    dTotPL := dTotPL + oUnit.CalcOpenPL;
  end;

  result := dTotPL;
end;

function  TOrderSet.CalcFixedPL: double;
var i: Integer; oUnit, oTmp: TOrderUnit; dTotPL, dClearPL: double;
    dLAmount, dSAmount, dSStrike, dLStrike: double;
begin
  result := 0;

  if m_bFromDB then
  begin
    result := m_dFixedPL;
    exit;
  end;

  dLAmount := 0; dSAmount := 0;

  {
  if m_iGID = 60068 then
  begin
    result := m_dFixedPL;
    dLAmount := 0;
    dSAmount := 0;
  end;
   }
// 박스일때는 4개의 체결이 완성되어 있어야 확정만기손익계산 가능
  if (m_stDiv = 'BOX') and ( m_lstUnit.Count = 4 )then
  begin
    if( m_oCallL <> nil ) and ( m_oCallS <> nil )  and
      ( m_oCallS.m_oPartner <> nil ) and ( m_oCallL.m_oPartner <> nil ) then
    begin
      dLStrike := m_oCallL.m_dStrike;
      dSStrike := m_oCallS.m_dStrike;
      if isCON then
        // (높은행사가-낮은행사가) - A콜매수 - B콜매수 + A풋매도 + B풋매도
        result := ((dSStrike-dLStrike)*m_oCallL.m_iQty) - m_oCallL.m_fNewAmt - m_oCallS.m_oPartner.m_fNewAmt + m_oCallS.m_fNewAmt + m_oCallL.m_oPartner.m_fNewAmt
      else
        result := ((dSStrike-dLStrike)*m_oCallL.m_iQty) - (m_oCallL.m_fNewAmt + m_oCallS.m_oPartner.m_fNewAmt - m_oCallS.m_fNewAmt - m_oCallL.m_oPartner.m_fNewAmt);
      result := result * 500000; // 2012.06.15  100000 -> 500000
    end;
    // 4개의옵션 종목의 체결수량이 일치하지 않으면 손익 초기화

    if not( (m_oCallL.m_iClearQty = m_oCallS.m_iClearQty) and  (m_oCallS.m_iClearQty = m_oCallS.m_oPartner.m_iClearQty) and
            (m_oCallL.m_iClearQty = m_oCallL.m_oPartner.m_iClearQty ) )then
            result := 0;
  end else

// 선옵차익일경우엔 3개의 체결이 완성되어 있어야 확정만기손익 계산 가능
  if(m_stDiv = 'FCP') and ( m_lstUnit.Count = 3 ) then
  begin
    if m_oFut = nil then exit;
    if m_oCall = nil then exit;
    if m_oPut = nil then exit;

  // 컨버젼일경우 행사가격 - ( 선물가 - 콜매도가격 + 풋매수가격 )
    if m_oFut.m_stLS[1] = 'L' then
    begin
      result := (m_oPut.m_dStrike*m_oCall.m_iQty) - ( (m_oFut.m_dAmt) - m_oCall.m_dAmt + m_oPut.m_dAmt );
      result := result * 500000; // 2012.06.15  100000 -> 500000
    end
  // 리버졀일경우 선물가격 - ( 행사가 - 풋매도가격 + 콜매수가격 )
    else begin
      result := (m_oFut.m_dAmt) - ( m_oPut.m_dStrike*m_oCall.m_iQty - m_oPut.m_dAmt + m_oCall.m_dAmt );
      result := result * 500000; // 2012.06.15  100000 -> 500000
    end;

    if (m_oFut.m_iQty = 0) or (m_oCall.m_iQty = 0) or (m_oPut.m_iQty = 0 ) then
      result := 0
  // 셋이 F:C:P = 1:1:1 수량비율로 체결되있지 않으면 만기속익 초기화
    else if( (m_oCall.m_iQty / m_oFut.m_iQty) <> 1) or ( (m_oPut.m_iQty / m_oFut.m_iQty) <> 1) then
      result := 0;

  end;

// 청산된 손익이 있으면 청산손익을 합산한다
  dClearPL := 0;
  for i:=0 to m_lstUnit.Count-1 do
  begin
    dClearPL := dClearPL + TOrderUnit(m_lstUnit.Items[i]).m_dFixedPL;
  end;

  result := result + dClearPL;

  result := utround( result )
end;

function  TOrderSet.GetState(): string;
begin
  case m_state of
    ssSuccess:  result := '성공';
    ssRollbacked:  result := '롤백됨';
    ssWait:  result := '처리중';
    ssFail:  result := '실패';
  end;
end;

procedure TOrderSet.ProcessState;
var i: Integer; bRemain: boolean;
begin
  if m_iGID = 0 then exit;

  if m_bFromDB then exit;
  bRemain := false;
  for i:=0 to m_lstUnit.Count-1 do
  begin
    if TOrderUnit(m_lstUnit.Items[i]).m_iQty > 0 then
    begin
      bRemain := true;
      break;
    end;
  end;

  if ( m_lstUnit.Count > 0 ) and not bRemain then
    m_state := ssRollbacked // 롤백됨
  else if (m_stDiv = 'BOX') and (m_lstUnit.Count=4) and IsFullyFilled() then
  begin
    if CalcFixedPL > 0 then
      m_state := ssSuccess
    else m_state := ssFail;
  end
  else if (m_stDiv = 'FCP') and (m_lstUnit.Count=3) and IsFullyFilled() then
  begin
    if CalcFixedPL > 0 then
      m_state := ssSuccess
    else m_state := ssFail;
  end else
    m_state := ssWait;
end;

// 메모리에서 주문유닛들을 지운다
procedure TOrderSet.ClearUnits;
var i: Integer;
begin
  for i:=0 to m_lstUnit.Count-1 do
    TOrderUnit(m_lstUnit.Items[i]).Free;
  m_lstUnit.Clear;
end;

end.
