unit CleVolStopManager;

interface

uses
  classes,  SysUtils,

  COrderBoard, CleQuoteBroker, CleAccounts, CleSymbols,

  GleConsts , GleTypes
  ;

type

  TJackPotItems = class( TCollectionItem )
  public
    OrderBoard  : TOrderBoard;
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy ; override;
  end;

  TVolStopManager = class( TCollection )
  private
    function GetJackPotItems(i: Integer): TJackPotItems;
  public
    Constructor Creaete;
    Destructor  Destroy; override;

    procedure DeleteBoard( aBoard : TOrderBoard );
    procedure DoQuote( aQuote : TQuote );
    procedure DoManageVolStop( aAccount : TAccount; aQuote : TQuote; bManage : boolean;
      aParam : TManageParam; aType : TOrderTimeType = ottJangJung );

    function New( aBoard : TOrderBoard ) : TJackPotItems;

    function Find( aBoard :TOrderBoard ) : TJackPotItems; overload;
    function Find( aQuote :TQuote ) : TJackPotItems; overload;
    procedure FindBoard( aAccount : TAccount; aSymbol : TSymbol; var aList : TList );
    function GetBoard(aAccount : TAccount; aSymbol : TSymbol) : TJackPotItems;
    property JackPotItem[ i :Integer] : TJackPotItems read GetJackPotItems;
  end;

implementation

uses
  GAppEnv, GleLib;

{ TJackPotItems }

constructor TJackPotItems.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  OrderBoard  := nil;
end;

destructor TJackPotItems.Destroy;
begin
  inherited;
end;

{ TVolStopManager }

constructor TVolStopManager.Creaete;
begin
  inherited Create( TJackPotItems );
end;

procedure TVolStopManager.DeleteBoard(aBoard: TOrderBoard);
var
  i : integer;
  aPots : TJackPotItems;
begin

  for i := Count - 1 downto 0 do
  begin
    aPots := GetJackPotItems(i);
    if aPots = nil then
      Continue;
    if aPots.OrderBoard = aBoard then
    begin
      Delete(i);
      break;
    end;
  end;
end;

destructor TVolStopManager.Destroy;
begin

  inherited;
end;

procedure TVolStopManager.DoManageVolStop(aAccount: TAccount; aQuote: TQuote; bManage : boolean;
  aParam : TManageParam; aType : TOrderTimeType);
var
  i : integer;
  aPots : TJackPotItems;
  stLog : string;
begin

  for i := 0 to Count - 1 do
  begin
    GetJackPotItems(i).OrderBoard.JackPot.Manage := false;

    stLog :=
      Format( ' Manage off : %s, %s, (%s : %s)', [ GetJackPotItems(i).OrderBoard.Symbol.ShortCode,
        GetJackPotItems(i).OrderBoard.Account.Code,
        ifthenStr( aParam.UseShift, Format('%.2f', [ aParam.AskShift]), IntToStr( aParam.AskHoga )),
        ifthenStr( aParam.UseShift, Format('%.2f', [ aParam.BidShift]), IntToStr( aParam.BidHoga ))
        ]
      );
    gLog.Add( lkKeyOrder,'TVolStopManager','DoManageVolStop', stLog );
  end;

  //if bManage then
    for i := 0 to Count - 1 do
    begin
      aPots := GetJackPotItems(i);
      if (aPots <> nil) and
         ((aPots.OrderBoard.Quote = aQuote) and
         (aPots.OrderBoard.Account = aAccount ))then
         begin
           aPots.OrderBoard.JackPot.Manage := bManage;
           aPots.OrderBoard.JackPot.ManageParam  := aParam;

           stLog :=
            Format( ' Manage %s : %s, %s, (%s, %s)', [
              ifthenStr( bManage , 'On', 'Off'),
              aPots.OrderBoard.Symbol.ShortCode,
              aPots.OrderBoard.Account.Code,
              ifthenStr( aParam.UseShift, Format('%.2f', [ aParam.AskShift]), IntToStr( aParam.AskHoga )),
              ifthenStr( aParam.UseShift, Format('%.2f', [ aParam.BidShift]), IntToStr( aParam.BidHoga ))
              ]
            );
           gLog.Add( lkKeyOrder,'TVolStopManager','DoManageVolStop', stLog );
         end;
    end;
end;

procedure TVolStopManager.DoQuote(aQuote: TQuote);
var
  i : integer;
  aPots : TJackPotItems;
begin
  for i := 0 to Count - 1 do
  begin
    aPots := GetJackPotItems(i);
    if (aPots <> nil) and
       (aPots.OrderBoard.Quote = aQuote) then
      aPots.OrderBoard.JackPot.OnQuote( aQuote );
  end;
end;

function TVolStopManager.Find(aBoard: TOrderBoard): TJackPotItems;
var
  i : integer;
  aPots : TJackPotItems;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aPots := GetJackPotItems(i);
    if aPots = nil then
      Continue;
    if aPots.OrderBoard = aBoard then
    begin
      Result := aPots;
      break;
    end;
  end;
end;

function TVolStopManager.Find(aQuote: TQuote): TJackPotItems;
var
  i : integer;
  aPots : TJackPotItems;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aPots := GetJackPotItems(i);
    if aPots = nil then
      Continue;
    if aPots.OrderBoard.Quote = aQuote then
    begin
      Result := aPots;
      break;
    end;
  end;

end;


function TVolStopManager.GetJackPotItems(i: Integer): TJackPotItems;
begin
  if ( i<0 ) or ( i>=count ) then
    Result := nil
  else
    Result := Items[i] as TJackPotItems;
end;

function TVolStopManager.New(aBoard: TOrderBoard): TJackPotItems;
begin
  Result := Find( aBoard );
  if Result = nil then
  begin
    Result := Add as TJackPotItems;
    Result.OrderBoard := aBoard;
  end;
end;


procedure TVolStopManager.FindBoard(aAccount: TAccount; aSymbol: TSymbol;
  var aList: TList);
var
  i : integer;
  aPots : TJackPotItems;
begin
  for i := 0 to Count - 1 do
  begin
    aPots := GetJackPotItems(i);
    if aPots = nil then
      Continue;
    if (aPots.OrderBoard.Symbol = aSymbol) and ( aPots.OrderBoard.Account = aAccount) then
      aList.Add( aPots );
  end;

end;

function TVolStopManager.GetBoard(aAccount : TAccount; aSymbol : TSymbol) : TJackPotItems;
var
  i : integer;
  aPots : TJackPotItems;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aPots := GetJackPotItems(i);
    if aPots = nil then
      Continue;
    if (aPots.OrderBoard.Symbol = aSymbol) and ( aPots.OrderBoard.Account = aAccount) then
    begin
      Result := aPots;
      break;
    end;
  end;
end;


end.
