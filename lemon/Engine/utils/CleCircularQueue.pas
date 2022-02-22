unit CleCircularQueue;

interface

uses
  Classes, SysUtils, DateUtils, Math

  ;


type

  TQueueItem = record //class( TCollectionItem )
  public
    ThisTime : TDateTime;
    Objects  : TObject;
    Data     : double;
  end;

  TCircularQueue = class
  private
    FQueue: array of TQueueItem;
    FAsiQueue : array of TQueueItem;
    FMaxCount: integer;
    FTmpColl : TCollection;

    FRear: integer;
    FFront: integer;
    FSumPrice: double;
    FFull: boolean;
    FAsiSum: double;
    FFirstData: double;
    function GetCount: integer;
    function GetValue(i: integer): double;
    function GetValue2(i: integer): double;

    function GetFirstData: double;


  public

    Constructor Create( iMax : integer ); overload;
    Destructor  Destroy; override;


    property MaxCount : integer read FMaxCount write FMaxCount;
    property Rear: integer read FRear write FRear;
    property Front: integer read FFront write FFront;
    property SumPrice : double read FSumPrice write FSumPrice;
    property AsiSum   : double read FAsiSum write FAsiSum;
    property Full : boolean read FFull write FFull;
    property Count : integer read GetCount;

    function PushItem(dtTime : TDateTime; dData : double) : TQueueItem;
    procedure PushItem2(dtTime : TDateTime; dData : double);
    function PopItem(idx : integer )  : TQueueItem;

    procedure reset;

    property Value[ i : integer] : double read GetValue;
    property Value2[i : integer] : double read GetValue2;
    property FirstData  : double read GetFirstData write FFirstData;

  end;


implementation

uses
  GAppEnv;

{ TCircularQueue }

constructor TCircularQueue.Create( iMax : integer );
begin
  if iMax <= 0 then
    Exit;
  MaxCount  := iMax;
  FRear := 0;
  FFront:= 0;
  FSumPrice := 0;
  SetLength( FQueue, MaxCount );
  SetLength( FAsiQueue, MaxCount );
  //FTmpColl  := TCollection.Create(TQueueItem);
  FFull := false;
end;

destructor TCircularQueue.Destroy;
begin
  //FTmpColl.Free;
  FAsiQueue := nil;
  FQueue := nil;
  inherited;
end;

function TCircularQueue.GetCount: integer;
begin
  if FFull then
    Result := MaxCount
  else  begin
    if FRear = 0 then
      Result := 1
    else
      Result := FRear;
  end;
end;

function TCircularQueue.GetFirstData: double;
begin
  Result := FFirstData;
end;

function TCircularQueue.GetValue(i: integer): double;
begin
  if ( i < 0 ) and ( i>=MaxCount ) then
    result := -1
  else begin
    i  := (FRear + 1 + I) mod MaxCount;
    result := FQueue[i].Data;
  end;
end;

function TCircularQueue.GetValue2(i: integer): double;
begin
  if ( i < 0 ) and ( i>=MaxCount ) then
    result := -1
  else begin
    i  := (FRear + 1 + I) mod MaxCount;
    result := FAsiQueue[i].Data;
  end;
end;

function TCircularQueue.PopItem(idx : integer): TQueueItem;
begin
  if (idx < 0) or ( idx >= MaxCount ) then
    Result := FQueue[0]
  else
    Result := FQueue[ idx ];
end;

function TCircularQueue.PushItem(dtTime: TDateTime; dData : double): TQueueItem;
var
  stLog : string;
begin
{
  Result := TQueueItem.Create( nil );
  Result.ThisTime := dtTime;
  Result.Data     := dData;
  }
  if (FRear + 1) = MaxCount then
  begin
    //FRear := 0;
    FFull := true;
  end;

  FRear := (FRear + 1) mod MaxCount;

  if FFull then
  begin
    FSumPrice := FSumPrice -FQueue[FRear].Data;
    if FSumPrice < 0 then
      FSumPrice := 0;
  end;

  FFirstData  := FQueue[FRear].Data;
  FQueue[FRear].ThisTime := dtTime;
  FQueue[FRear].Data := dData;

  FSumPrice := FSumPrice + dData;

  {
  stLog := Format('%d, %s',
  [
    FRear,
    FormatDateTime('hh:nn:ss.zzz', dtTime )
  ]);
  gEnv.EnvLog( WIN_TEST, stLog );
  }
end;



procedure TCircularQueue.PushItem2(dtTime: TDateTime; dData: double);
var
  stLog : string;
  iMid  : integer;
begin

  if (FRear + 1) = MaxCount then
  begin
    //FRear := 0;
    FFull := true;
  end;

  FRear := (FRear + 1) mod MaxCount;

  if FFull then
  begin
    FSumPrice := FSumPrice -FQueue[FRear].Data;
    if FSumPrice < 0 then
      FSumPrice := 0;
    FAsiSum   := FAsiSum - FAsiQueue[FRear].Data;
  end;

  FQueue[FRear].ThisTime := dtTime;
  FQueue[FRear].Data := dData;

  iMid  := abs(FRear -1 ) mod MaxCount;
  FAsiQueue[FRear].ThisTime := dtTime;
  FAsiQueue[FRear].Data     := dData - FQueue[iMid].Data  ;

  FSumPrice := FSumPrice + FQueue[FRear].Data;
  FAsiSum   := FAsiSum   + FAsiQueue[FRear].Data;

end;


procedure TCircularQueue.reset;
begin
  FRear := 0;
  FFront:= 0;
  FSumPrice := 0;
  FAsiSum   := 0;

  FFull := false;
end;

end.
