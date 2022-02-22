unit CleTimers;

interface

uses
  Classes, SysUtils , GAppConsts, CleStorage, GleTypes,

  CleQuoteTimers

  ;

type

  TTimerItem  = class( TCollectionItem )
  public
    Title   : string;
    Time    : TDateTime;
    TimeDesc: string;
    Sound   : string;
    SoundOn : boolean;
    IsPlay  : boolean;
    //RepeatCnt : integer;
    Current   : integer;
    constructor Create(aColl: TCollection); override;
    procedure playSound;
    procedure CheckRepeat;
  end;


  TTimerItems = class( TCollection )
  private
    FTimer    : TQuoteTimer;
    FStorage  : TStorage;
    FEnable: boolean;
    function GetTimerItem(i: integer): TTimerItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( dtTime : TDateTime ) : TTimerItem;
    function Find( stTime : string ) : boolean;

    procedure DelTimer( aTimer : TTimerItem );
    procedure CheckSound( dtTime : TDateTime );

    property Timers[ i : integer] : TTimerItem read GetTimerItem;

    procedure LoadEnv;
    procedure SaveEnv;

    procedure TimerTimer(Sender: TObject);
    procedure init;
    property Enable : boolean read FEnable write FEnable;
  end;



implementation

uses
  GleLib , GAppEnv
  ;

{ TTimerItem }

procedure TTimerItem.CheckRepeat;
begin
  inc(Current);
  //if Current >= RepeatCnt  then
  //  IsPlay := true;
end;

constructor TTimerItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  Sound := '';
  SoundOn := false;
  IsPlay  := false;
  //RepeatCnt := 2;
  Current   := 0;
end;

procedure TTimerItem.playSound;
begin
  FillSoundPlay( Sound );
  CheckRepeat;
end;

{ TTimerItems }

procedure TTimerItems.CheckSound(dtTime: TDateTime);
var
  i, iRes: Integer;
  aItem : TTimerItem;
  sTime : string;
begin
  sTime := FormatDateTime('hhnnss', dtTime );
  for i := 0 to count - 1 do
  begin
    if ( aItem.IsPlay ) or ( not aItem.SoundOn ) then
      Continue;

    aItem := GetTimerItem(i);
    iRes := CompareStr( aItem.TimeDesc, sTime );

    if ( iRes = 0) then
      aItem.playSound;
  end;
end;

constructor TTimerItems.Create;
begin
  inherited Create( TTimerItem );
  FStorage  := TStorage.Create;
  LoadEnv;
end;


procedure TTimerItems.init;
begin
  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  with FTimer do
  begin
    Enabled := True;
    Interval := 300;
    OnTimer := TimerTimer;
  end;
end;
procedure TTimerItems.DelTimer(aTimer: TTimerItem);
var
  i : integer;
begin
  for i := 0 to Count - 1 do
    if GetTimerItem(i) = aTimer then
    begin
      Delete(i);
      break;
    end;
end;

destructor TTimerItems.Destroy;
begin
  //FTimer.Free;
  FStorage.New;
  SaveEnv;
  FStorage.Free;
  inherited;
end;

function TTimerItems.Find(stTime: string): boolean;
var
  i: Integer;
begin
  Result := false;

  for i := 0 to Count - 1 do
    if GetTimerItem(i).TimeDesc = stTime then
    begin
      Result := true;
      break;
    end;
    
end;

function TTimerItems.GetTimerItem(i: integer): TTimerItem;
begin
  if ( i<0 ) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as TTimerItem;
end;



function TTimerItems.New(dtTime: TDateTime): TTimerItem;
begin
  Result := Add as TTimerItem;
  Result.Time := dtTime;
  Result.TimeDesc := FormatDateTime('hhnnss', dtTime );
end;

procedure TTimerItems.SaveEnv;
var
  i: Integer;
  aTimer : TTimerItem;
begin

  FStorage.Clear;
  FStorage.New;

  FStorage.FieldByName('Count').AsInteger := Count;

  FStorage.FieldByName('AlramEnable').AsBoolean := FEnable;

  for i := 0 to Count - 1 do
  begin
    aTimer := GetTimerItem(i);
    if aTimer = nil then Continue;

    FStorage.FieldByName('Title_'+IntToStr(i)).AsString     := aTimer.Title;
    FStorage.FieldByName('Time_'+IntToStr(i)).AsFloat       := aTimer.Time;
    FStorage.FieldByName('TimeDesc_'+IntToStr(i)).AsString  := aTimer.TimeDesc;
    FStorage.FieldByName('Sound_'+IntToStr(i)).AsString     := aTimer.Sound;
    FStorage.FieldByName('SoundOn_'+IntToStr(i)).AsBoolean  := aTimer.SoundOn;
    FStorage.FieldByName('IsPlay_'+IntToStr(i)).AsBoolean   := aTimer.IsPlay;
  end;

  if Count > 0 then
    FStorage.Save( ComposeFilePath([gEnv.DataDir, TIMER_ITEM]) );

end;

procedure TTimerItems.TimerTimer(Sender: TObject);
begin
  if FEnable then
    CheckSound( GetQuoteTime );
end;

procedure TTimerItems.LoadEnv;
var
  i, iCount : integer;
  bRes : boolean;
  aTimer : TTimerItem;
begin

  bRes := FStorage.Load(ComposeFilePath([gEnv.DataDir, TIMER_ITEM]));
  if not bRes then Exit;
  FStorage.First;

  iCount := FStorage.FieldByName('Count').AsInteger;

  FEnable:= FStorage.FieldByName('AlramEnable').AsBoolean;

  for i := 0 to iCount - 1 do
  begin
    aTimer  := Add as TTimerItem;

    aTimer.Title  := FStorage.FieldByName('Title_'+IntToStr(i)).AsString;
    aTimer.Time   := FStorage.FieldByName('Time_'+IntToStr(i)).AsFloat;
    aTimer.TimeDesc := FStorage.FieldByName('TimeDesc_'+IntToStr(i)).AsString;
    aTimer.Sound    := FStorage.FieldByName('Sound_'+IntToStr(i)).AsString;
    aTimer.SoundOn  := FStorage.FieldByName('SoundOn_'+IntToStr(i)).AsBoolean;
    aTimer.IsPlay   := FStorage.FieldByName('IsPlay_'+IntToStr(i)).AsBoolean;
  end;

end;



end.
