unit CleRedundancyCheck;

interface
uses
  classes, dialogs, sysutils,
  GleTypes, GleConsts, CleSymbols, CleAccounts;


type
  TRedundancySymbolAcnt = class(TCollectionItem)
  private
    FSymbol : TSymbol;
    FAccount : TAccount;
    FRefCnt : integer;
    FFormList : TList;
    FRdtType : TRedundancyType;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;
  end;


  TRedundancySymbolAcnts = class(TCollection)
  private

    function New(aSymbol : TSymbol; aAcnt : TAccount; aForm : TObject;
                 aType : TRedundancyType) : TRedundancySymbolAcnt;
    procedure AddFormList(aItem : TRedundancySymbolAcnt; aForm : TObject);
    procedure DelFormList(aItem : TRedundancySymbolAcnt; aForm : TObject);
    function GetTypeString( aType : TRedundancyType ) : string;
  public
    constructor Create;
    destructor Destroy; override;
    function Find( aSymbol : TSymbol; aAcnt : TAccount;
                 aType: TRedundancyType) : TRedundancySymbolAcnt;
    function RedundancyCheck(aSymbol, aPreSymbol : TSymbol; aAcnt, aPreAcnt : TAccount;
             aForm : TObject; aType : TRedundancyType ) : boolean;
    procedure Del( aForm : TObject ); overload;
    procedure Del( aSymbol : TSymbol; aAcnt : TAccount; aForm : TObject; aType : TRedundancyType); overload;
    procedure AlramBox( aSymbol : TSymbol; aAcnt : TAccount; aType : TRedundancyType );
  end;

implementation
uses
  GAppEnv;

{ TRedundancySymbolAcnt }

constructor TRedundancySymbolAcnt.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FRefCnt := 0;
  FFormList := TList.Create;
end;

destructor TRedundancySymbolAcnt.Destroy;
begin
  FFormList.Free;
  inherited;
end;

{ TRedundancySymbolAcnts }

procedure TRedundancySymbolAcnts.AddFormList(aItem: TRedundancySymbolAcnt;
  aForm: TObject);
var
  i : integer;
begin
  for i := 0 to aItem.FFormList.Count - 1 do
  begin
    if aItem.FFormList.Items[i] = aForm then
      exit;
  end;
  aItem.FFormList.Add(aForm);
end;

procedure TRedundancySymbolAcnts.AlramBox(aSymbol: TSymbol; aAcnt: TAccount; aType : TRedundancyType);
var
  stLog : string;
begin
  stLog := Format('%s, %s, %s 동일종목이 있습니다', [GetTypeString(aType), aAcnt.Name, aSymbol.ShortCode]);
  ShowMessage(stLog);
end;

constructor TRedundancySymbolAcnts.Create;
begin
  inherited Create(TRedundancySymbolAcnt);

end;

procedure TRedundancySymbolAcnts.Del(aSymbol: TSymbol; aAcnt: TAccount;
  aForm: TObject; aType : TRedundancyType);
var
  aItem : TRedundancySymbolAcnt;
  i : integer;
  stLog : string;
  bFind : boolean;
begin
  bFind := false;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRedundancySymbolAcnt;
    if(aItem.FSymbol = aSymbol) and
       (aItem.FAccount = aAcnt) and
       (aItem.FRdtType = aType) then
    begin
      bFind := true;
      break;
    end;
  end;

  if not bFind then exit;
  if aItem = nil then exit;

  Dec(aItem.FRefCnt);
  if aItem.FRefCnt <= 0 then
  begin
    stLog := Format('Redundancy Del Symbol = %s, RefCnt = %d, %s',
          [ aSymbol.ShortCode, aItem.FRefCnt, GetTypeString(aType)]);
    gEnv.EnvLog(WIN_TEST, stLog);

    Delete(i);
  end else
    DelFormList(aItem, aForm);
  // RefCnt <= 0 삭제,   RefCnt >=1 FormList에서만 삭제
end;

procedure TRedundancySymbolAcnts.Del(aForm: TObject);
var
  aItem : TRedundancySymbolAcnt;
  i : integer;
  stLog : string;
  bFind : boolean;
begin
  bFind := false;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRedundancySymbolAcnt;
    if(aItem.FFormList.Items[0] = aForm) then
    begin
      bFind := true;
      break;
    end;
  end;

  if not bFind then exit;
  if aItem = nil then exit;

  Dec(aItem.FRefCnt);
  if aItem.FRefCnt <= 0 then
  begin
    stLog := 'Redundancy Del 종합주문';

    gEnv.EnvLog(WIN_TEST, stLog);

    Delete(i);
  end else
    DelFormList(aItem, aForm);
  // RefCnt <= 0 삭제,   RefCnt >=1 FormList에서만 삭제

end;

procedure TRedundancySymbolAcnts.DelFormList(aItem: TRedundancySymbolAcnt;
  aForm: TObject);
var
  i : integer;
begin
  for i := 0 to aItem.FFormList.Count - 1 do
  begin
    if aItem.FFormList.Items[i] = aForm then
    begin
     aItem.FFormList.Delete(i);
     break;
    end;
  end;
end;

destructor TRedundancySymbolAcnts.Destroy;
begin

  inherited;
end;

function TRedundancySymbolAcnts.Find(aSymbol: TSymbol;
  aAcnt: TAccount; aType : TRedundancyType): TRedundancySymbolAcnt;
var
  i : integer;
  aItem : TRedundancySymbolAcnt;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TRedundancySymbolAcnt;

    if(aItem.FSymbol = aSymbol) and
       (aItem.FAccount = aAcnt) and
       (aItem.FRdtType = aType) then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function TRedundancySymbolAcnts.GetTypeString(aType: TRedundancyType): string;
begin
  Result := '';
  case aType of
    rdtOrderMan: Result := '주문관리';
    rdtProtected: Result := 'Protected Order';
  end;

end;

function TRedundancySymbolAcnts.New(aSymbol: TSymbol; aAcnt: TAccount;
  aForm: TObject; aType: TRedundancyType): TRedundancySymbolAcnt;
var
  stLog : string;
begin
  Result := Add as TRedundancySymbolAcnt;
  Result.FSymbol := aSymbol;
  Result.FAccount := aAcnt;
  Result.FRdtType := aType;
  Result.FFormList.Add(aForm);
  inc(Result.FRefCnt);
  stLog := Format('Redundancy New Symbol = %s, RefCnt = %d, Count = %d, %s',
          [ aSymbol.ShortCode, Result.FRefCnt, Count, GetTypeString(aType)]);
  gEnv.EnvLog(WIN_TEST, stLog);

end;

function TRedundancySymbolAcnts.RedundancyCheck(aSymbol, aPreSymbol: TSymbol;
  aAcnt, aPreAcnt: TAccount; aForm: TObject; aType: TRedundancyType): boolean;
var
  aItem : TRedundancySymbolAcnt;
begin
  Result := false;

  if(aPreSymbol <> nil) and (aPreAcnt <> nil) then
    Del(aPreSymbol, aPreAcnt, aForm, aType);

  if (aSymbol = nil) or (aAcnt = nil) then exit;
  aItem := Find(aSymbol, aAcnt, aType);
  if aItem = nil then
  begin
    New(aSymbol,aAcnt, aForm, aType);
    Result := true;
  end else
  begin
    if aItem.FRefCnt < MAX_REFCNT then
    begin
      AddFormList( aItem, aForm );
      Result := true;
    end;
  end;
end;

end.
