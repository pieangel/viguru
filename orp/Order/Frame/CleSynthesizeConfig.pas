unit CleSynthesizeConfig;

interface
uses
  classes, Forms, GleTypes, CleSymbols, CleAccounts;

const
  FRAME_CNT = 5;  
type
  TFrameCreateEvent = procedure( iTag, iFormID : integer ) of object;
  TFrameCloseEvent = procedure( bHide : boolean = false) of object;
  TFrameChangeEvent = procedure( aObject : TObject ) of object;

  TFrameConfig = class(TCollectionItem)
  private
    FFrame : TFrame;
    FFrameType : TFrameType;
    FShowHide : boolean;
    FOnFrameCreate : TFrameCreateEvent;
    FOnFrameClose : TFrameCloseEvent;
    FOnSymbolChange : TFrameChangeEvent;
    FOnAccountChange : TFrameChangeEvent;
  public
    procedure Change( aItem : TFrameConfig );
    procedure SetFrameEvent;
    property Frame : TFrame read FFrame;
    property FrameType : TFrameType read FFrameType;
    property ShowHide : boolean read FShowHide write FShowHide;
    property OnFrameCreate : TFrameCreateEvent read FOnFrameCreate write FOnFrameCreate;
    property OnFrameClose : TFrameCloseEvent read FOnFrameClose write FOnFrameClose;
    property OnSymbolChange : TFrameChangeEvent read FOnSymbolChange write FOnSymbolChange;
    property OnAccountChange : TFrameChangeEvent read FOnAccountChange write FOnAccountChange;
  end;

  TFrameConfigs = class(TCollection)
  private
    function IndexOf( aType : TFrameType ) : integer;


  public
    constructor Create;
    destructor Destroy;override;
    procedure New( aFrame : TFrame; iType : integer; bShow : boolean);
    procedure Exchange( iMoveIndex : integer; aType : TFrameType;  bShow : boolean);
    procedure SymbolChange( aSymbol : TSymbol );
    procedure AccountChange( aAcnt : TAccount );
    function Find( aType : TFrameType ) : TFrameConfig;
  end;

implementation

uses
  FrameFrontQuoting,
  FrameSCatchOrder, FrameOrderManage, FrameProtectedOrder, FrameBull, Dialogs, SysUtils,
  GAppForms, GAppEnv;

{ TFrameConfigs }

constructor TFrameConfigs.Create;
begin
  inherited Create(TFrameConfig);
end;

destructor TFrameConfigs.Destroy;
begin

  inherited;
end;


procedure TFrameConfigs.Exchange(iMoveIndex: integer; aType: TFrameType; bShow : boolean);
var
  iIndex, iDelIndex : integer;
  aItem, aTarget : TFrameConfig;
begin
  iIndex := IndexOf(aType);
  if iIndex = -1 then exit;
   aItem := Items[iIndex] as TFrameConfig;
  if aItem = nil then exit;
  aItem.ShowHide := bShow;
  aTarget := Insert(iMoveIndex) as TFrameConfig;
  aTarget.Change(aItem);
  if iIndex > iMoveIndex then
    iDelIndex := iIndex + 1
  else
    iDelIndex := iIndex;

  Delete(iDelIndex);
end;

function TFrameConfigs.Find(aType: TFrameType): TFrameConfig;
var
  i : integer;
  aItem : TFrameConfig;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TFrameConfig;
    if aItem.FFrameType = aType then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

function TFrameConfigs.IndexOf(aType: TFrameType): integer;
var
  i : integer;
  aItem : TFrameConfig;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TFrameConfig;
    if aItem.FFrameType = aType then
    begin
      Result := i;
      break;
    end;
   
  end;
end;

procedure TFrameConfigs.New(aFrame: TFrame; iType : integer; bShow: boolean);
var
  aItem : TFrameConfig;
begin
  aItem := Add as TFrameConfig;
  aItem.FFrame := aFrame;
  aItem.FFrameType := TFrameType(iType);
  aItem.FShowHide := bShow;
  aItem.SetFrameEvent;
end;
procedure TFrameConfigs.AccountChange( aAcnt : TAccount );
var
  i : integer;
  aItem : TFrameConfig;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TFrameConfig;
    if aItem.ShowHide then
    begin
      if Assigned(aItem.OnAccountChange) then
        aItem.OnAccountChange(aAcnt);
    end;
  end
end;

procedure TFrameConfigs.SymbolChange(aSymbol : TSymbol);
var
  i : integer;
  aItem : TFrameConfig;
begin
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TFrameConfig;
    if aItem.ShowHide then
    begin
      if Assigned(aItem.OnSymbolChange) then
        aItem.OnSymbolChange(aSymbol);
    end;
  end;
end;

{ TFrameConfig }

procedure TFrameConfig.Change(aItem: TFrameConfig);
begin
  FFrame := aItem.FFrame;
  FFrameType := aItem.FFrameType;
  FShowHide := aItem.FShowHide;
  FOnFrameCreate := aItem.FOnFrameCreate;
  FOnFrameClose := aItem.FOnFrameClose;
  FOnSymbolChange := aItem.FOnSymbolChange;
  FOnAccountChange := aItem.FOnAccountChange;
end;

procedure TFrameConfig.SetFrameEvent;
var
  iFormID, iTag : integer;
begin
  case FFrameType of
    ftBull:
    begin
      OnFrameCreate := TFraBull(FFrame).FrameCreate;
      OnFrameClose := TFraBull(FFrame).FrameClose;
      OnSymbolChange := TFraBull(FFrame).FrameSymbolChange;
      OnAccountChange := TFraBull(FFrame).FrameAccountChange;
      iFormID := ID_BULL;

    end;
    ftOrder:
    begin
      OnFrameCreate := TFraOrderManage(FFrame).FrameCreate;
      OnFrameClose := TFraOrderManage(FFrame).FrameClose;
      OnSymbolChange := TFraOrderManage(FFrame).FrameSymbolChange;
      OnAccountChange := TFraOrderManage(FFrame).FrameAccountChange;
      iFormID := ID_SAVEPOS;
    end;
    ftFront:
    begin
      OnFrameCreate := TFraFrontQuoting(FFrame).FrameCreate;
      OnFrameClose := TFraFrontQuoting(FFrame).FrameClose;
      OnSymbolChange := TFraFrontQuoting(FFrame).FrameSymbolChange;
      OnAccountChange := TFraFrontQuoting(FFrame).FrameAccountChange;
      iFormID := ID_FRONTQUOTING;
    end;
    ftSCatch:
    begin
      OnFrameCreate := TFraSCatchOrder(FFrame).FrameCreate;
      OnFrameClose := TFraSCatchOrder(FFrame).FrameClose;
      OnSymbolChange := TFraSCatchOrder(FFrame).FrameSymbolChange;
      OnAccountChange := TFraSCatchOrder(FFrame).FrameAccountChange;
      iFormID := ID_SIMPLE_CATCH;
    end;
    ftProtected:
    begin
      OnFrameCreate := TFraProtectedOrder(FFrame).FrameCreate;
      OnFrameClose := TFraProtectedOrder(FFrame).FrameClose;
      OnSymbolChange := TFraProtectedOrder(FFrame).FrameSymbolChange;
      OnAccountChange := TFraProtectedOrder(FFrame).FrameAccountChange;
      iFormID := ID_PROTECT;
    end;
  end;

  if Assigned(OnFrameCreate) and FShowHide then
  begin
    iTag := gEnv.Engine.FormBroker.FormTags.GetTag(iFormID);
    OnFrameCreate(iTag, iFormID);
  end;
end;

end.
