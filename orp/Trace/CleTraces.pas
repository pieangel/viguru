unit CleTraces;

interface

uses
  Classes, SysUtils ,

  GleLib, GleTypes

  ;
type


  TPositionHis = record
    Time  : TDateTime;
    AccountNo : string;
    TotPL     : double;   // 총손익
    EvalPL    : double;   // 평간손익
    Fee       : double;   // 수수료
    Etc       : double;   // 기타
  end;


  TPosTraceItem  = class( TCollectionItem )
  public
    AccountNo : string;
    PositionHis : TPositionHis;
  end;


  TPosTraceItems  = class( TCollection )
  private
    function GetPosTraceItem(i: integer): TPosTraceItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( AcntNo : string ) : TPosTraceItem;

    property PosTraceItems[ i : integer] : TPosTraceItem read GetPosTraceItem;
  end;


implementation

{ TPosTraceItems }

constructor TPosTraceItems.Create;
begin
  inherited Create( TPosTraceItem );
end;

destructor TPosTraceItems.Destroy;
begin

  inherited;
end;

function TPosTraceItems.GetPosTraceItem(i: integer): TPosTraceItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TPosTraceItem;
end;

function TPosTraceItems.New(AcntNo: string): TPosTraceItem;
begin
  Result := Add as TPosTraceItem;
  Result.AccountNo  := AcntNo;
end;

end.
