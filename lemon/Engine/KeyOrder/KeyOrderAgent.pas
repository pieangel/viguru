unit KeyOrderAgent;

interface

uses
  Classes, Sysutils, Windows, Forms, Messages, IniFiles, ComCtrls, Math,
  //
  CleSymbols, CleAccounts, KOrderConst, CleOrders, CleDistributor,
  CleQuoteBroker, ClePositions,
  {
  SymbolStore, AccountStore, TradeCentral, Manager, OrderHandler,
  LogCentral, , AppTypes, OrderStore, Broadcaster,
  PositionStore, AppUtils, PriceCentral, VolData, Globals, RpParams,
  }CalcGreeks,
  CircularList, ExtCtrls;

const
  ARRAY_SIZE = 20;
  PID_KEYORDER = 701;
  UNIT_TITLE = 'KeyOrderItem';


type
  TKeyDownEvent = procedure(Sender: TObject; var Key: Word; Shift: TShiftState) of object;
  TKeyLogEvent = procedure(Sender : TObject; Key: Word;  Shift: TShiftState; strAction : String) of object;

  TKeySymbolType = (ktSymbolA, ktSymbolB, ktSymbolAll, ktNone); // 선물관련키, 옵션관련키, 없음);

  // 키보드 메시지
  TKeyRec = record
    OrgKey  : String;
    CtrlKey : String;
    AltKey  : String;
  end;

  TKeyActionItem = class(TCollectionItem)
  public
    KeyDesc : String;
    Key : Word;
    Shift : TShiftState; // 복합키 여부
    KeySymbolType : TKeySymbolType;
    KActionType : TKActionType;
  end;


  TKeyOrderItem = class(TCollectionItem)
  private

    // 변경시작  06.10.09 jaebeom
    FActions : TCollection;

    //FKeyAction : array[TKActionType, TKeySymbolType] of Word;
    //FKeyShift  : array[TKActionType] of TShiftState;

    FQty : array[1..6, TKeySymbolType] of Integer;

    FMacroKey    : array[VK_F2..VK_F12] of String;
    FMacroSymbol : array[VK_F2..VK_F12] of String;

    FAccount : TAccount;

    //FOrderHandler : TOrderHandler;

    FOrderHistroy : TList;  // 취소주문을 하기위한 order Histroy

    FSymbolA: TSymbol;
    FSymbolAPrice : Single;
    FSymbolAQty : Integer;

    FSymbolB: TSymbol;
    FSymbolBPrice : Single;
    FSymbolBQty   : Integer;

    FKeyOrderMap: String;  // 이름   Key

    // 델타 수량을 구하기 위해서
    FUnderlying : TSymbol; // 기초자산
    FNearFuture : TSymbol; // 최근월물
    FMixRatio : Double;

    FOrderReq : TOrder;

    FOnLog : TKeyLogEvent;
    FOnChange: TNotifyEvent;

    FSymbolAQueue : TCircularList;
    FSymbolBQueue : TCircularList;
    FSymbolADelayTime: Integer;
    FSymbolBDelayTime: Integer;

    FTimer : TTimer;
    FMacroActionTokens : TStringList;
    FMacroSymbolTokens : TStringList;
    FMacroPlayIndex : Integer;
    FMacroDelayTime : Integer;
    FIsPlay : Boolean;
    FMacroActionCnt : Integer;

    FEnable : Boolean;  // 키보드 주문 비활성

    FDistributor: TDistributor;
    FOnSelect: TNotifyEvent;

    procedure LoadToFile;
    procedure SaveToFile;

    function AddOrderKey(wKey : Word; aShift : TShiftState;
                       aSymbolType : TkeySymbolType;
                       aKActionType : TKActionType) : Boolean;

    procedure StateChanged(aTarget : TObject);

    procedure OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    //Send Order
    procedure PutNewLongOrder(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType);
    procedure PutNewShortOrder(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType);
    procedure PutChangeLongOrder(aSymbol : TSimpleSymbol; aKActionType: TKActionType);
    procedure PutChangeShortOrder(aSymbol : TSimpleSymbol; aKActionType: TKActionType);
    procedure PutCancelOrder(aSymbol : TSimpleSymbol; aKActionType: TKActionType);
    procedure PutProfitExit(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType); // 청산
    procedure PutClear(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType); //
    procedure PutSellExit(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType); // 전매
    procedure PutBuyExit( aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType); // 환매
    //

    // 종목의 잔량
    function GetCurQty(aSymbol : TSymbol ):  Integer;
    function GetOptionDelteQty(aSymbol : TSymbol) : Integer;

    procedure KeyDownEvent(aKey: Word; aShift: TShiftState);
    function  DoAction(aAction : TKActionType; aKeySymbolType : TKeySymbolType) : Boolean;

    procedure MacroPlay(aKey : Word);
    procedure TimeProc(Sender : TObject);

    procedure SetOrderMap(const Value: String);
    function GetDelayedSymbol(aCircular : TCircularList; dCurrentTime : TDateTime; iDelay : Integer) : TSimpleSymbol;

    procedure Init;

    function GetQty(iIndex: Integer; aSymbolType: TKeySymbolType): Integer;
    procedure SetQty(iIndex: Integer; aSymbolType: TKeySymbolType;  const Value: Integer);
    procedure SetSymbolA(const Value: TSymbol);
    procedure SetSymbolB(const Value: TSymbol);
    procedure SetSymbolADelayTime(const Value: Integer);
    procedure SetSymbolBDelayTime(const Value: Integer);
    function GetMacro(iKey: Integer): String;
    procedure SetMacro(iKey: Integer; const Value: String);
    function GetMacroSymbol(iKey: Integer): String;
    procedure SetMacroSymbol(iKey: Integer; const Value: String);
    procedure SetKeyOrderMap(const Value: String);
    procedure SetSymbolDelayTime(aSymbolType: TKeySymbolType; const Value: Integer);
    function GetSymbolDelayTime(aSymbolType: TKeySymbolType): Integer;
    function GetActionDesc(aKActionType: TKActionType): String;
  public
    Sender : TObject; // 요청한 화면

    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    function GetActionByKey(aKey : Word) : TKActionType;
    function RemoveAction(aKeyAction : TKActionType) : Boolean;
    function RemoveKey(aKey : Word) : Boolean;

    function RemoveAll : Boolean;
    function Save : Boolean;
    function Load : Boolean;
    function GetKeyDesc(var  aRec : TKeyRec; aKey : Word) : Boolean;
    function GetKeyActionList(aList : TList) : Boolean;
    function GetActions(aList : TList) : Boolean;

    function NewKeyAction(aKey : Word; aShift : TShiftState;
                          aKeySymbolType : TKeySymbolType;
                          aKActionType : TKActionType) : TKeyActionItem;


    procedure Subscribe(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject;
      EventIDs: TDistributorIDs; aHandler: TDistributorEvent);

    procedure Unsubscribe(Receiver : TObject);

    procedure Active;

    // 사용중인키 ? 
    function IsUsed(aKey : Word; aShift : TShiftState) : Boolean;

    ////////////////////////// - property -  ///////////////////////////////////
    property KeyOrderMap : String  read FKeyOrderMap write SetOrderMap;
    property Account : TAccount read FAccount write FAccount;
    property MapName : String read FKeyOrderMap write SetKeyOrderMap;
    property KQty[iIndex : Integer; aSymbolType : TKeySymbolType] : Integer read GetQty write SetQty;

    property ActionDesc[aKActionType : TKActionType] : String read GetActionDesc;

    property OnLog : TKeyLogEvent read FOnLog write FOnLog;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;

    property SymbolA : TSymbol read FSymbolA write SetSymbolA;
    property SymbolB : TSymbol read FSymbolB write SetSymbolB;

    // 매크로 관련 기능
    property MacroKey[iKey : Integer] : String read GetMacro write SetMacro;
    property MacroSymbol[iKey : Integer] : String read GetMacroSymbol write SetMacroSymbol;

    property SymbolADelayTime : Integer read FSymbolADelayTime write SetSymbolADelayTime;
    property SymbolBDelayTime : Integer read FSymbolBDelayTime write SetSymbolBDelayTime;

    property SymbolDelayTime[aSymbolType : TKeySymbolType] : Integer read GetSymbolDelayTime write SetSymbolDelayTime;


    // 2006. 5. 26 추가
    property Enable : Boolean read  FEnable write FEnable;   // 키보드 주문 비활성

    // 2006. 6. 6 추가

    property SymbolAQty : Integer read FSymbolAQty write FSymbolAQty;
    property SymbolBQty : Integer read FSymbolBQty write FSymbolBQty;

    // 화면에 선택을 알리기 위하여 추가
    property OnSelect : TNotifyEvent read FOnSelect write FOnSelect;

  end;



  // key order를 내줄 agent
  TKeyOrderAgent = class
  private
    FKeyOrders : TCollection;
    FOnChange: TNotifyEvent;
    function FindItem(aObj : TObject) : TKeyOrderItem;
    procedure ItemChangeProc(Sender : TObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Remove(aObj : TObject);
    procedure SetSymbolA(aObj: TObject;  aSymbol: TSymbol);
    procedure SetSymbolB(aObj : TObject; aSymbol : TSymbol);
    procedure SetAccount(aObj : TObject; aAccount : TAccount);
    function SetMap(aObj : TObject; stMapName : String) : TKeyOrderItem;
    //
    function SetKeyOrder(aObj : TObject;
                         aSymbolA : TSymbol;
                         aSymbolB : TSymbol;
                         aAccount : TAccount) : TKeyOrderItem;  // if exists modify, not add form

    procedure RemoveKeyOrder(aObj : TObject);
    procedure KeyNotify(aObj: TObject; Key: Word; Shift: TShiftState);
    procedure Notify(aItem : TKeyOrderItem);
    procedure GetOpenList(aList : TList);
    function  GetMapName(aObj : TObject) : String;
    procedure Refresh;
    function NewItem(aObj : TObject; strName : String) : TKeyOrderItem;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
  end;

var
  gKeyOrderAgent : TKeyOrderAgent;

implementation

uses ControlObserver, KeyOrderUtils, GAppEnv, GleTypes, GleLib, GleConsts,
  CleKrxSymbols, CleFQN;

{ TKeyOrderAgent }

//
//-----------------------< Init / Final >------------------------------------//
//
constructor TKeyOrderAgent.Create;
begin
  FKeyOrders := TCollection.Create(TKeyOrderItem);
end;

destructor TKeyOrderAgent.Destroy;
begin
  FKeyOrders.Free;
  inherited;
end;


//
// Enable KeyOrder List Return
//
procedure TKeyOrderAgent.GetOpenList(aList: TList);
var
  i : Integer;
begin
  if aList = nil then Exit;

  aList.Clear;
  for i := 0 to FKeyOrders.Count-1 do
    aList.Add( FKeyOrders.Items[i]  );
end;


//
//
//
function TKeyOrderAgent.FindItem(aObj: TObject): TKeyOrderItem;
var
  i : Integer;
begin
  Result := nil;

  try
    for i:=0 to FKeyOrders.Count-1 do
    begin
      if (FKeyOrders.Items[i] as TKeyOrderItem).Sender = aObj then
      begin
        Result := FKeyOrders.Items[i] as TKeyOrderItem;
        Exit;
      end;
    end;

  except
    on E : Exception do
    begin
      gLog.Add(lkError, UNIT_TITLE, 'Find', E.Message);
    end;
  end;

end;


//
//  key Event toss KeyorderItems
//
procedure TKeyOrderAgent.KeyNotify(aObj: TObject; Key: Word; Shift: TShiftState);
var
  aItem : TKeyOrderItem;
begin

  if (Key = 0) or (Key = 32) then Exit;

  try
    aItem := FindItem(aObj);

    if aItem <> nil then aItem.KeyDownEvent(Key, Shift);
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'KeyNotify' , E.Message);
  end;

end;

//
//
//
function TKeyOrderAgent.NewItem(aObj : TObject; strName : String) : TKeyOrderItem;
var
  aItem : TKeyOrderitem;
begin
  aItem := FKeyOrders.Add as TKeyOrderItem;

  try
    with aItem do
    begin
      MapName := strName;
      Sender := aObj;
      Account := nil;
      SymbolA := nil;
      SymbolB := nil;

      OnChange := ItemChangeProc;
    end;


    if FileExists(aItem.MapName) then
      aItem.Load
    else
    begin
      aItem.Init;
      aItem.Save;
    end;

    Result := aItem;
    if Assigned(FOnChange) then FOnChange(Result);
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, '', E.Message);
  end;
end;


//
//
procedure TKeyOrderAgent.Remove(aObj: TObject);
var
  i : Integer;
  aItem : TKeyOrderItem;
begin
  for i:=FKeyOrders.Count-1 downto 0 do
  begin
    aItem := FKeyOrders.Items[i] as TKeyOrderItem;
    if aItem.Sender = aObj then aItem.Free;
    aItem.OnChange := nil;
  end;

  FOnChange := nil;
  Refresh;
end;


//
//
procedure TKeyOrderAgent.SetAccount(aObj: TObject; aAccount: TAccount);
var
  aItem : TKeyOrderItem;
begin
  if aObj = nil then Exit;

  aItem := FindItem(aObj);

  if aItem <> nil then
    aItem.Account := aAccount;
end;


//  2006-06
//
procedure TKeyOrderAgent.SetSymbolA(aObj: TObject;  aSymbol: TSymbol);
var
  aItem : TKeyOrderItem;
begin
  try
    aItem := FindItem(aObj);

    if aItem <> nil then
      aItem.SymbolA := aSymbol;

    if Assigned(FOnChange) then FOnChange(aItem);
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'SetSymbolA', E.Message);
  end;
end;


//
// < set Symbol >
//
procedure TKeyOrderAgent.SetSymbolB(aObj: TObject; aSymbol: TSymbol);
var
  aItem : TKeyOrderItem;
begin
  try
    aItem := FindItem(aObj);
    if aItem <> nil then aItem.SymbolB := aSymbol;

    if Assigned(FOnChange) then FOnChange(aItem);
  except
    on E : Exception do
    begin
      gLog.Add(lkError, UNIT_TITLE, 'SetSymbolB', E.Message);
    end;
  end;

end;


//  Setting Keyorder item .   if Exists Add Item , not Exist Update
//
function TKeyOrderAgent.SetKeyOrder(aObj: TObject;
                    aSymbolA, aSymbolB: TSymbol;
                    aAccount: TAccount) : TKeyOrderItem;
var
  aItem : TKeyOrderItem;
begin

  if aObj = nil then Exit;

  try
    aItem := FindItem(aObj);

    if aItem = nil then
      aItem := FKeyOrders.Add as TKeyOrderItem;

    with aItem  do
    begin
      Sender := aObj;
      SymbolA := aSymbolA;
      SymbolB := aSymbolB;
      Account := aAccount;

      OnChange := ItemChangeProc;
    end;

    if Assigned(FOnChange) then FOnChange(aItem);
    aItem.Enable := False;
    Result := aItem;
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'SetKeyOrder', E.Message);
  end;
end;


//
//
//
function TKeyOrderAgent.SetMap(aObj: TObject; stMapName: String) : TKeyOrderItem;
var
  aItem : TKeyOrderItem;
begin
  aItem := FindItem(aObj);

  if aItem <> nil then aItem.MapName := stMapName;

  aItem.Load;  
  if Assigned(FOnChange) then FOnChange(aItem);

  Result := aItem;
end;


//
//
//
procedure TKeyOrderAgent.Refresh;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;


//
//
//
function TKeyOrderAgent.GetMapName(aObj: TObject): String;
var
  aItem : TKeyOrderItem;
begin
  Result := '';
  aItem := FindItem(aObj);

  if aItem <> nil then
    Result := aItem.MapName;
end;


//
//
//
procedure TKeyOrderAgent.RemoveKeyOrder(aObj: TObject);
var
  i : Integer;
begin
  for i:=FKeyOrders.Count-1 downto 0 do
    if (FKeyOrders.Items[i] as TKeyOrderItem).Sender = aObj then
      FKeyOrders.Delete(i);

  Refresh;
end;


//
//
//
procedure TKeyOrderAgent.ItemChangeProc(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;


//
//
//
procedure TKeyOrderAgent.Notify(aItem : TKeyOrderItem);
begin
  if Assigned(FOnChange) then FOnChange(aItem);
end;



////////////////////////////////////////////////////////////////////////////////
/////////////////////////////< Key Order Item > ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


constructor TKeyOrderItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FActions := TCollection.Create(TKeyActionItem);

  Init;

  FOrderHistroy := TList.Create;
  FOrderHistroy.Clear;

  //체결수신을 받아서 주문 리스트에서 제거를 하기위함
  FDistributor := TDistributor.Create;
  gEnv.Engine.TradeBroker.Subscribe( self, OrderProc);

  // Set Default Value;
  FSymbolAPrice := 0.0;
  FSymbolAQty   := 1;
  FSymbolBPrice := 0.0;
  FSymbolBQty   := 1;

  FSymbolAQueue := TCircularList.Create(ARRAY_SIZE);
  FSymbolBQueue := TCircularList.Create(ARRAY_SIZE);

  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;  // 100ms
  FTimer.Enabled := False;
  FTimer.OnTimer := TimeProc;

  FMacroActionTokens := TStringList.Create;
  FMacroSymbolTokens := TStringList.Create;

  FEnable := False;
end;


destructor TKeyOrderItem.Destroy;
begin
  FTimer.Free;
  FMacroActionTokens.Free;
  FMacroSymbolTokens.Free;


  gEnv.Engine.QuoteBroker.Cancel( Self );

  FOrderHistroy.Free;


  FSymbolAQueue.Free;
  FSymbolBQueue.Free;

  FDistributor.Free;

  FActions.Free;

  inherited;
end;



//  KeyOrderAgent를 통해서 받은 이벤트를 소화하는 곳으로 이곳에서 키를 확인한 후
//  DoAction Procedure 를 호출하게 된다
//
procedure TKeyOrderItem.KeyDownEvent(aKey: Word;  aShift: TShiftState);

  // is macro key ?
  function IsMacro : Boolean;
  begin
    if aKey in [VK_F2..VK_F12] then  Result := True else Result := False;
  end;

var
  aAction : TKActionType;
  aKeySymbolType : TKeySymbolType;
  i : Integer;
begin
  if FEnable = False then Exit;

  aAction := atNull;
  aKeySymbolType := ktNone;

  if aKey = 0 then Exit;
  if (SymbolA = nil) or (SymbolB = nil) then Exit;

  if IsMacro then MacroPlay(aKey)
  else
  begin
    // 키보드 보정
    AscPressToDown(aKey);
    gLog.Add(lkError, UNIT_TITLE, 'UserAction PressKey  ' + MapName , Char(aKey));

    for i:= 0 to FActions.Count-1 do
    begin
      with FActions.Items[i] as TKeyActionItem do
        if (Key = aKey) and (Shift = aShift) then
        begin
          DoAction( KActionType, KeySymbolType );
          Break;
        end
    end;
    DoAction(aAction, aKeySymbolType);
  end;

end;



//
//
//
procedure TKeyOrderItem.SaveToFile;
var
  strRec : String;
  i : Integer;
  F : TextFile;

  function ConvertSymbolTypeToString(aSymbolType : TKeySymbolType) : String;
  begin
    case aSymbolType of
      ktSymbolA : Result := 'ktSymbolA';
      ktSymbolB : Result := 'ktSymbolB';
      ktSymbolAll : Result := 'ktSymbolAll';
      ktNone : Result := 'ktNone';
    end;
  end;

begin
  //-- file name
  //-- open or create
  AssignFile(F, FKeyOrderMap);
  try
    Rewrite(F);
    for i:= 0 to FActions.Count-1 do
      with FActions.Items[i] as TKeyActionItem do
      begin

        strRec := 'ORDER' + ',' +
                  KEY_DESC[KActionType] + ',' +
                  Char(Key) + ',' +
                  ConvertSymbolTypeToString(KeySymbolType) + ',' + // Symbol
                  ConvertShiftToString(Shift);

        Writeln(F, strRec);
      end;


    for i:= 1 to 6 do
      Writeln(F, 'QTY' + ',' +
                 'SYMBOLA'+ ',' +
                 IntToStr(i) + ',' +
                 IntToStr(FQty[i, ktSymbolA]));

    for i:= 1 to 6 do
      Writeln(F, 'QTY' + ',' +
                 'SYMBOLB'+ ',' +
                 IntToStr(i) + ',' +
                 IntToStr(FQty[i, ktSymbolB]));


    Writeln(F, 'DelayTimeA,', IntToStr(FSymbolADelayTime));
    Writeln(F, 'DelayTimeB,', IntToStr(FSymbolADelayTime));



    for i:= VK_F2 to VK_F12 do
    begin
      // Macro Key 에 할당하는 Action
      Writeln(F, ConvertVKToString(i, 1), FMacroKey[i]);
      // Macro Key 에 할당하는 Symbol
      Writeln(F, ConvertVKToString(i, 2), FMacroSymbol[i]);
    end;

  finally
    CloseFile(F);
  end;

end;


//
// Load Item from Text File
//
procedure TKeyOrderItem.LoadToFile;
var
  strRec : String;
  aAction : TKActionType;
  aSymbolType : TKeySymbolType;
  F : TextFile;
  strParse : TStringList;
  aShiftState : TShiftState;
  iIndex : Integer;


  //  in-line Function
  //  Input macro and Symbols
  //
  function InputMacro(iIndex : Integer; aStr : TStringList): Boolean;
  var
    i : Integer;
  begin
    FMacroKey[iIndex] :=  '';

    for i:=1 to aStr.Count-1 do
      FMacroKey[iIndex] := FMacroKey[iIndex] + aStr[i] + ',';

    Result := True;
  end;

  function InputSymbols(iIndex : Integer; aStr : TStringList) : Boolean;
  var
    i : Integer;
  begin
    FMacroSymbol[iIndex] := '';

    for i:=1 to aStr.Count-1 do
      FMacroSymbol[iIndex] := FMacroSymbol[iIndex] + aStr[i] + ',';
    Result := True;
  end;


begin
  strParse := TStringList.Create;

  FKeyOrderMap := Trim(FKeyOrderMap);
  if  FKeyOrderMap = '' then Exit;

  if not FileExists(FKeyOrderMap) then
  begin
    gLog.Add(lkDebug, UNIT_TITLE, 'LoadToFile' , 'File not Exists');
    Exit;
  end;

  try
    AssignFile(F, FKeyOrderMap);
    Reset(F);

    Readln(F, strRec);
    while not EOF(F) do
    begin

      if GetTokens(strRec, strParse, ',') > 0 then
      begin

        if CompareStr(strParse[0], 'ORDER') = 0 then  // 주문관련 Message
        begin
          aAction := KeyActionFindByDesc( strParse[1] );

          if CompareStr(strParse[4], 'Ctrl') = 0  then aShiftState := [ssCtrl]
          else if CompareStr(strParse[4], 'Alt') = 0  then aShiftState := [ssAlt]
          else aShiftState := [];

          if CompareStr(strParse[3], 'ktSymbolA') = 0 then
            aSymbolType := ktSymbolA
          else if CompareStr(strParse[3], 'ktSymbolB') = 0 then
            aSymbolType := ktSymbolB;

          AddOrderKey(Ord( strParse[2][1] ),  aShiftState,  aSymbolType, aAction);

        end
        else if CompareStr(strParse[0], 'QTY') = 0 then // 수량
        begin

          // 수량입력하기
          if CompareStr(strParse[1], 'SYMBOLA') = 0 then // 수량 A
          begin
            iIndex := StrToInt( strParse[2] );
            FQty[iIndex, ktSymbolA] := StrToInt( strParse[3] );
          end
          else if CompareStr(strParse[1], 'SYMBOLB') = 0 then // 수량 B
          begin
            iIndex := StrToInt( strParse[2] );
            FQty[iIndex, ktSymbolB] := StrToInt( strParse[3] );
          end;

        end
        else if CompareStr(strParse[0], 'DelayTimeA') = 0 then
          FSymbolADelayTime := StrToIntDef(strParse[1], 0)
        else if CompareStr(strParse[0], 'DelayTimeB') = 0 then
          FSymbolBDelayTime := StrToIntDef(strParse[1], 0)
        else
        begin
          InputMacro(ConvertStringToVK(strParse[0]), strParse);
          InputSymbols(ConvertStringToVK(strParse[0]), strParse);
        end;
      end;

      Readln(F, strRec);
   end;

    // Default Qty
    FSymbolAQty := FQty[1, ktSymbolA];
    FSymbolBQty := FQty[1, ktSymbolB];
  finally
    strParse.Free;
    CloseFile(F);
  end;

end;


//
//  Method point  procedure
//
procedure TKeyOrderItem.OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iP : Integer;
  aOrder : TOrder;
  stUnderlying : String;
begin

  if FEnable = False then Exit;

  if (FAccount = nil) or
     (DataObj = nil) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_SPAWN,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: aOrder := DataObj as TOrder;
    else
      Exit;
  end;

  try
    if aOrder = nil then Exit;

    stUnderlying := Copy( aOrder.Symbol.Code, 2, 2);
    if CompareStr(stUnderlying, '03') = 0 then Exit;

    // OrderHistory 관리
    if (aOrder.OrderType = otNormal) or
       (aOrder.OrderType = otChange) then
    begin      {
      case btValue of
        btNew :
          begin
            FOrderHistroy.Insert(0, aOrder);
          end;
        btUpdate :
          begin
            iP := FOrderHistroy.IndexOf(aOrder);
            if (iP >= 0) and ((aOrder.State = osDead) or (aOrder.State = osFullfill)) then
              FOrderHistroy.Delete(iP);
          end;
      end;   }
    end;

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'OrderProc', E.Message);
  end;
end;


// 취소주문
procedure TKeyOrderItem.PutCancelOrder(aSymbol : TSimpleSymbol; aKActionType: TKActionType);
var
  i : Integer;
  aOrderItem , aOrder: TOrder;
  bLastOrder : Boolean;
  aTicket : TOrderTicket;
begin

  try
    case aKActionType of
      atCancelAll, atCancelLast : // cancel all
        begin

          for i := 0 to FOrderHistroy.Count-1 do
          begin
            aOrderItem := TOrder(FOrderHistroy.Items[i]);
            if aOrderItem.Symbol.Code <>  aSymbol.Code then  Continue;  // 동일종목의


            aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
            aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aOrderItem, aOrderItem.ActiveQty, aTicket );
            if aOrder <> nil then
              gEnv.Engine.TradeBroker.Send( aTicket );
            if aKActionType = atCancelLast then break; // 맨 마지막 주문만 취소

          end; //
        end;
      atCancelNotLast : // 마지막 주문을 제외
        begin
          bLastOrder := True;
          for i:= 0 to FOrderHistroy.Count-1 do
          begin
            aOrderItem := TOrder(FOrderHistroy.Items[i]);
            if aOrderItem.Symbol.Code <>  aSymbol.Code then  Continue;
            if bLastOrder then
            begin
              bLastOrder := False;
              Continue;
            end;

            aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
            aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aOrderItem, aOrderItem.ActiveQty, aTicket );
            if aOrder <> nil then
              gEnv.Engine.TradeBroker.Send( aTicket );
          end;
        end;
      atCancelShort : // 매도 전부 취소
        begin
          for i := 0 to FOrderHistroy.Count-1 do
          begin
            aOrderItem := TOrder(FOrderHistroy.Items[i]);
            if (aOrderItem.Symbol.Code <> aSymbol.Code) or
               (aOrderItem.PositionType <> ptShort) then Continue;

            aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
            aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aOrderItem, aOrderItem.ActiveQty, aTicket );
            if aOrder <> nil then
              gEnv.Engine.TradeBroker.Send( aTicket );
          end;
        end;
      atCancelLong : // 매수 전부 취소
        begin
          for i:= 0 to FOrderHistroy.Count-1 do
          begin
            aOrderItem := TOrder(FOrderHistroy.Items[i]);

            if (aOrderItem.Symbol.Code <> aSymbol.Code) or
               (aOrderItem.PositionType <> ptLong) then Continue;

            aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
            aOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder( aOrderItem, aOrderItem.ActiveQty, aTicket );
            if aOrder <> nil then
              gEnv.Engine.TradeBroker.Send( aTicket );
          end;
        end;
    end;

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutCancelOrder', E.Message);
  end;
end;



// 매도 주문의 정정
procedure TKeyOrderItem.PutChangeShortOrder(aSymbol : TSimpleSymbol; aKActionType: TKActionType);
var
  i : Integer;
  aOrderItem, aOrder : TOrder;
  aSymbolItem : TSymbol;
  sPrice : double;
  aTicket : TOrderTicket;
  aQuote : TQuote;
begin

  try

    for i:=0 to FOrderHistroy.Count - 1 do
    begin
      aOrderItem := TOrder(FOrderHistroy.Items[i]);
      if aOrderItem.PositionType <> ptShort then Continue;
      aSymbolItem := aOrderItem.Symbol;

      aQuote := aSymbolItem.Quote as TQuote;

      with aSymbol, aSymbolItem do
      case aKActionType of
        atChangeShort1, atChangeLong1:
          sPrice := aQuote.Bids[0].Price;
        atChangeShort2, atChangeLong2:
          sPrice := aQuote.Bids[1].Price;
        atChangeShort3, atChangeLong3:
          sPrice := aQuote.Asks[0].Price;
        atChangeShort4, atChangeLong4:
          sPrice := TicksFromPrice( aSymbolItem, aQuote.Asks[0].Price , -1);
        atChangeShort5, atChangeLong5:
          sPrice := TicksFromPrice( aSymbolItem, aQuote.Asks[0].Price , -2);
        atChangeShort6, atChangeLong6:
          sPrice := C;
        atChangeShort7, atChangeLong7:
          sPrice := TicksFromPrice( aSymbolItem, aOrderItem.Price, -1);
        atChangeShort8, atChangeLong8:
          sPrice := TicksFromPrice( aSymbolItem, aOrderItem.Price, -2);
      end;

      // 정정가격=원주문가격
      if (aOrderItem.Price < sPrice+PRICE_EPSILON) and
         (aOrderItem.Price > sPrice-PRICE_EPSILON) then  Continue;

      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
      aOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrder( aOrderItem, aOrderItem.ActiveQty,
        pcLimit, sPrice, tmGTC, aTicket ) ;

      if aOrder <> nil then
        gEnv.Engine.TradeBroker.Send( aTicket );
    end;

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutChangeShortOrder', E.Message);
  end;
end;


//
//
// 매수 주문의 정정
procedure TKeyOrderItem.PutChangeLongOrder(aSymbol : TSimpleSymbol; aKActionType: TKActionType);
var
  i : Integer;
  aOrderItem, aOrder : TOrder;
  aSymbolItem : TSymbol;
  sPrice : double;
  aTicket : TOrderTicket;
  aQuote : TQuote;
begin

  try

    for i:=0 to FOrderHistroy.Count - 1 do
    begin
      aOrderItem := TOrder(FOrderHistroy.Items[i]);
      if aOrderItem.PositionType <> ptLong then Continue;
      aSymbolItem := aOrderItem.Symbol;
      aQuote := aSymbolItem.Quote as TQuote;
      with aSymbol, aSymbolItem do
      case aKActionType of
        atChangeLong1, atChangeShort1:
          sPrice := aQuote.Asks[0].Price;
        atChangeLong2, atChangeShort2:
          sPrice := aQuote.Asks[1].Price;
        atChangeLong3, atChangeShort3:
          sPrice := aQuote.Bids[0].Price;
        atChangeLong4, atChangeShort4:
          sPrice := TicksFromPrice( aSymbolItem, aQuote.Bids[0].Price, 1);
        atChangeLong5, atChangeShort5:
          sPrice := TicksFromPrice( aSymbolItem, aQuote.Bids[0].Price, 2);
        atChangeLong6, atChangeShort6:
          sPrice := C;
        atChangeLong7, atChangeShort7:
          sPrice := TicksFromPrice( aSymbolItem, aOrderItem.Price, 1);
        atChangeLong8, atChangeShort8:
          sPrice := TicksFromPrice( aSymbolItem, aOrderItem.Price, 2);
      end;

      gLog.Add(lkKeyOrder, UNIT_TITLE, 'PutChangeLongOrder', KEY_DESC[aKActionType] +
                               Format('%.*n Qty : %d',[aSymbol.Precision, sPrice, aOrderItem.OrderQty]));


      // 정정가격=원주문가격
      if (aOrderItem.Price < sPrice+PRICE_EPSILON) and
         (aOrderItem.Price > sPrice-PRICE_EPSILON) then
         Continue;

      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
      aOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrder( aOrderItem, aOrderItem.ActiveQty,
        pcLimit, sPrice, tmGTC, aTicket ) ;

      if aOrder <> nil then
        gEnv.Engine.TradeBroker.Send( aTicket );

    end;


  except
    on  E  : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutChangeLongOrder', E.Message);
  end;
end;


// 2006-03
// PutNewLongOrder : 신규 매수 주문 내기
//
procedure TKeyOrderItem.PutNewLongOrder(aSymbol : TSimpleSymbol;
                                     iQty: Integer; aKActionType: TKActionType);
var
  sPrice : double;
  aSymbolItem : TSymbol;
  aQuote  : TQuote;
  aTicket : TOrderTicket;
begin
  if (iQty <= 0)  then Exit;
  aSymbolItem := gEnv.Engine.SymbolCore.Symbols.FindCode( aSymbol.Code );
  if aSymbolItem = nil then Exit;

  try

    aQuote := aSymbolItem.Quote as TQuote;
    if aQuote = nil then Exit;

    with aSymbol, aSymbolItem do
    case aKActionType of
      atNewLong1 : sPrice := aQuote.Asks[0].Price;
      atNewLong2 : sPrice := aQuote.Asks[1].Price;
      atNewLong3 : sPrice := aQuote.Bids[0].Price;
      atNewLong4 : sPrice := TicksFromPrice( aSymbolItem, aQuote.Bids[0].Price, 1 );
      atNewLong5 : sPrice := TicksFromPrice( aSymbolItem, aQuote.Bids[0].Price, 2 );
      atNewLong6 : sPrice := Last;
    end;

    gLog.Add(lkKeyOrder, UNIT_TITLE, 'PutNewLongOrder', KEY_DESC[aKActionType] +
                                       Format('%.*n Qty : %d',[aSymbol.Precision, sPrice, iQty]));

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
    FOrderReq  := gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', Account, aSymbolItem,
      iQty, pcLimit, sPrice, tmFAS,aTicket  );
    if FOrderReq <> nil then
      gEnv.Engine.TradeBroker.Send( aTicket );

    gLog.Add(lkKeyOrder, UNIT_TITLE,
                         'PutNewLongOrder',
                         'A Queue : ' + FSymbolAQueue.Dump +
                         'B Queue : ' + FSymbolBQueue.Dump);
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutNewLongOrder', E.Message);
  end;

end;


//
// put New ShortOrder : 신규매도
//
procedure TKeyOrderItem.PutNewShortOrder(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType);
var
  sPrice : double;
  aSymbolItem : TSymbol;
  aQuote  : TQuote;
  aTicket : TOrderTicket;
begin
  if (iQty <= 0)  then Exit;
  aSymbolItem := gEnv.Engine.SymbolCore.Symbols.FindCode( aSymbol.Code );
    if aSymbolItem = nil then Exit;
  try
    iQty := iQty * -1;
    with aSymbol, aSymbolItem do
    case aKActionType of
      atNewLong1 : sPrice := aQuote.Bids[0].Price;
      atNewLong2 : sPrice := aQuote.Bids[1].Price;
      atNewLong3 : sPrice := aQuote.Asks[0].Price;
      atNewLong4 : sPrice := TicksFromPrice( aSymbolItem, aQuote.Asks[0].Price, -1 );
      atNewLong5 : sPrice := TicksFromPrice( aSymbolItem, aQuote.Asks[0].Price, -2 );
      atNewShort6: sPrice := Last;
    end;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
    FOrderReq  := gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', Account, aSymbolItem,
      iQty, pcLimit, sPrice, tmFAS,aTicket  );
    if FOrderReq <> nil then
      gEnv.Engine.TradeBroker.Send( aTicket );


    gLog.Add(lkKeyOrder, UNIT_TITLE, 'PutNewShortOrder', KEY_DESC[aKActionType] +
                                       Format('%.*n Qty : %d',[aSymbol.Precision, sPrice, iQty]));



    gLog.Add(lkDebug, UNIT_TITLE,
                         'PutNewShortOrder',
                         'A Queue : ' + FSymbolAQueue.Dump +
                         'B Queue : ' + FSymbolBQueue.Dump);
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutNewShortOrder', E.Message );
  end;
end;


//
//
//
procedure TKeyOrderItem.SetOrderMap(const Value: String);
begin
  FKeyOrderMap := Value;

  try
    Init;
    Load;
    if Assigned( FOnChange ) then FOnChange(Self);
  except
    on E: Exception do
      gLog.Add(lkError, UNIT_TITLE, 'SetOrderMap', E.Message);
  end;
end;



//------------------------------------------------------------------------------
//    << order state Change >>
//------------------------------------------------------------------------------
procedure TKeyOrderItem.StateChanged(aTarget: TObject);
var
  aReq : TOrder;
begin
  if not (aTarget is TOrder) then
  begin
    gLog.Add(lkError, UNIT_TITLE, 'StateChange', 'aTarget is not TOrderReqItem');
    Exit;
  end;

  aReq := aTarget as TOrder;
  // show current state of order request
  // if process is finished, unlock the form
  //if aReq.IsDone then
  //  FOrderHandler.Clear;
end;


//
//
//
procedure TKeyOrderItem.Init;
var
  i, aKey : Integer;
begin
  for i:= 1 to 6 do
    FQty[i, ktSymbolA] :=0;

  for aKey := VK_F2 to VK_F12 do
    FMacroKey[aKey] := '';
end;


//  청산 주문
procedure TKeyOrderItem.PutClear(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType);
var
  aPosition : TPosition;
  iCurQty, iOrderQty : Integer;
  sPrice : double;
  aPositionType : TPositionType;
  aSymbolItem : TSymbol;
  aTickValue : Double;
  aQuote : TQuote;
  aTicket : TOrderTicket;
begin
  if (iQty <= 0) then Exit;

  try
    // Find Symbol if not Exist, Exit Proc
    aSymbolItem := gEnv.Engine.SymbolCore.Symbols.FindCode( aSymbol.Code );
    //aSymbolItem := gPrice.SymbolStore.FindSymbol(aSymbol.Code);
    if aSymbolItem = nil then Exit;

    // Find Symbol if not Exist, Exit Proc
    aPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, aSymbolItem );
    //aPosition := gTrade.PositionStore.FindPosition(FAccount, aSymbolItem);
    if aPosition = nil then Exit;

    iCurQty := aPosition.Volume;
    if iCurQty = 0 then Exit;
    //
    // 2006-08-04 LSY 평균단가 버그 수정
    //
    if (aSymbolItem.Spec.Market = mtOption) and
       (aPosition.AvgPrice<3.0-PRICE_EPSILON) then
      aTickValue := 0.01
    else
      aTickValue := 0.05;
    //

    aQuote := aSymbolItem.Quote as TQuote;
    if aQuote = nil then Exit;

    iOrderQty := Min(iQty, Abs(iCurQty));
    if iCurQty < 0 then
    begin
      aPositionType := ptLong;    // 매수(환매수) 주문
      case aKActionType of
        atClear1: sPrice := aQuote.Asks[0].Price;
        atClear2:  sPrice:= aQuote.Asks[1].Price;
        atClear3: sPrice := aQuote.Bids[0].Price;
          // 2006-08-04 LSY 평균단가 버그 수정
        atClear4: sPrice := Round(aPosition.AvgPrice/aTickValue+epsilon)*aTickValue;   // 평균단가
      end;
    end
    else
    begin
      aPositionType := ptShort;  // 매도(전매도)주문
      case aKActionType of
        atClear1: sPrice := aQuote.Bids[0].Price;
        atClear2: sPrice := aQuote.Bids[1].Price;
        atClear3: sPrice := aQuote.Asks[0].Price;
        // 2006-08-04 LSY 평균단가 버그 수정
        atClear4: sPrice := Round(aPosition.AvgPrice/aTickValue+epsilon)*aTickValue;   // 평균단가
      end;

    end;


    if (aPositionType = ptShort) and ( iOrderQty > 0) then
      iOrderQty := iOrderQty * -1;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );

    FOrderReq :=  gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', Account,
      aSymbolItem, iOrderQty, pcLimit, sPrice, tmGTC, aTicket);

    if FOrderReq <> nil then gEnv.Engine.TradeBroker.Send( aTicket );
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutClear', E.Message);
  end;

end;



//------------------------------------------------------------------------------
//  Procedure: PutBuyExit    환매수
//  Author:    jaebom , jeon
//  Date:      20-4-2006
//  Arguments: aSymbol: TSimpleSymbol; iBuyLevel: Integer; var strAction: String
//  Result:    None
//------------------------------------------------------------------------------
procedure TKeyOrderItem.PutBuyExit( aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType);
var
  iCurQty, iOrderQty : Integer;
  sPrice : Single;
  aPositionType : TPositionType;
  aSymbolItem : TSymbol;
  aPosition : TPosition;
  aQuote : TQuote;
  aTicket : TOrderTicket;
begin
  if (iQty <= 0) then Exit;

  try

    aSymbolItem := gEnv.Engine.SymbolCore.Symbols.FindCode( aSymbol.Code );
    //aSymbolItem := gPrice.SymbolStore.FindSymbol(aSymbol.Code);
    if aSymbolItem = nil then Exit;

    //aPosition := gTrade.PositionStore.FindPosition(FAccount, aSymbolItem);
    aPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, aSymbolItem );
    if aPosition = nil then Exit;

    iCurQty := aPosition.Volume;
    if iCurQty >= 0 then Exit;

    aPositionType := ptLong;    // 매수(환매수) 주문

    aQuote := aSymbolItem.Quote as TQuote;
    if aQuote = nil then Exit;    

    case aKActionType of
      atBuyExit1: sPrice := TicksFromPrice( aSymbolItem, aSymbol.Quote.Bids[0].Price, 1);
      atBuyExit2: sPrice := TicksFromPrice( aSymbolItem, aSymbol.Quote.Asks[0].Price, -1);
      atBuyExit3: sPrice := aSymbol.Quote.Asks[0].Price;
    end;

    iOrderQty := Min(iQty, Abs(iCurQty));

    if (aPositionType = ptShort) and ( iOrderQty > 0) then
      iOrderQty := iOrderQty * -1;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );

    FOrderReq :=  gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', Account,
      aSymbolItem, iOrderQty, pcLimit, sPrice, tmGTC, aTicket);

    if FOrderReq <> nil then gEnv.Engine.TradeBroker.Send( aTicket );

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutBuyExit', E.Message);
  end;

end;


//------------------------------------------------------------------------------
//  Procedure: PutSellExit  전매도
//  Author:    jaebeom, jeon
//  Date:      20-4-2006
//  Arguments: aSymbol: TSimpleSymbol; iSellLevel: Integer; var strAction: String
//  Result:    None
//------------------------------------------------------------------------------
procedure TKeyOrderItem.PutSellExit(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType); //
var
  iCurQty, iOrderQty : Integer;
  sPrice : Single;
  aPositionType : TPositionType;
  aSymbolItem : TSymbol;
  aPosition : TPosition;
  aQuote : TQuote;
  aTicket : TOrderTicket;
begin
  if (iQty <= 0) then Exit;
  try
    aSymbolItem := gEnv.Engine.SymbolCore.Symbols.FindCode( aSymbol.Code );
    //aSymbolItem := gPrice.SymbolStore.FindSymbol(aSymbol.Code);
    if aSymbolItem = nil then Exit;

    aPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, aSymbolItem );
    //aPosition := gTrade.PositionStore.FindPosition(FAccount, aSymbolItem);
    if aPosition = nil then Exit;

    iCurQty := aPosition.Volume;
    if iCurQty <= 0 then Exit;

    aQuote := aSymbolItem.Quote as TQuote;

    aPositionType := ptShort;    // 매도(전매도)주문

    case aKActionType of
      atSellExit1: sPrice := TicksFromPrice( aSymbolItem, aSymbol.Quote.Asks[0].Price, -1);
      atSellExit2: sPrice := TicksFromPrice( aSymbolItem, aSymbol.Quote.Bids[0].Price, 1);
      atSellExit3: sPrice := aSymbol.Quote.Bids[0].Price;
    end;

    iOrderQty := Min(iQty, Abs(iCurQty));

    if (aPositionType = ptShort) and ( iOrderQty > 0) then
      iOrderQty := iOrderQty * -1;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );

    FOrderReq :=  gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', Account,
      aSymbolItem, iOrderQty, pcLimit, sPrice, tmGTC, aTicket);

    if FOrderReq <> nil then gEnv.Engine.TradeBroker.Send( aTicket );

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutSellExit', E.Message);
  end;


end;


// 이익청산 주문
procedure TKeyOrderItem.PutProfitExit(aSymbol : TSimpleSymbol; iQty: Integer; aKActionType: TKActionType);
var
  dAvgPrice : Double;
  sPrice : Single;
  sSign : Integer;
  aPositionType : TPositionType;
  aSymbolItem : TSymbol;
  aPosition : TPosition;
  aTickValue : Double;
  aQuote : TQuote;
  aTicket : TOrderTicket;
begin

  try
    aSymbolItem := gEnv.Engine.SymbolCore.Symbols.FindCode( aSymbol.Code );
    //aSymbolItem := gPrice.SymbolStore.FindSymbol(aSymbol.Code);
    if aSymbolItem = nil then Exit;

    aPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, aSymbolItem );
    //aPosition := gTrade.PositionStore.FindPosition(FAccount, aSymbolItem);
    if aPosition = nil then Exit;


    if aPosition.Volume = 0then Exit;

    if aPosition.Volume < 0 then
    begin
      aPositionType := ptLong;    // 매수주문
      sSign := -1;
    end
    else
    begin
      aPositionType := ptShort;  // 매도주문
      sSign := 1;
    end;

    if (aSymbolItem.Spec.Market = mtOption) and
       (aPosition.AvgPrice<3.0-PRICE_EPSILON) then
      aTickValue := 0.01
    else
      aTickValue := 0.05;

    dAvgPrice := Round(aPosition.AvgPrice/aTickValue+epsilon)*aTickValue;

    case aKActionType of
      atProfitExit1 : sPrice := TicksFromPrice( aSymbolItem, dAvgPrice, sSign);
      atProfitExit2 : sPrice := TicksFromPrice( aSymbolItem, dAvgPrice, sSign*2);
    end;


    if (aPositionType = ptShort) and ( iQty > 0) then
      iQty := iQty * -1;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );

    FOrderReq :=  gEnv.Engine.TradeCore.Orders.NewNormalOrder( '', Account,
      aSymbolItem, iQty, pcLimit, sPrice, tmGTC, aTicket);

    if FOrderReq <> nil then gEnv.Engine.TradeBroker.Send( aTicket );

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'PutProfitExit', E.Message);
  end;
end;



//종목별 잔량
function TKeyOrderItem.GetCurQty(aSymbol: TSymbol): Integer;
var
  aPosition : TPosition;
begin
  Result := 0;
  if aSymbol = nil then Exit;
  aPosition := gEnv.Engine.TradeCore.Positions.Find(FAccount, aSymbol);

  if aPosition = nil then
  begin
    gLog.Add(lkDebug, UNIT_TITLE, 'GetCurQty', '종목별 잔량을 구했으나 포지션이 없음');
    Exit;
  end;

  Result := Abs(aPosition.Volume);
end;


function TKeyOrderItem.Save;
begin
  try
    SaveToFile;
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'Save', E.Message);
  end;
  
  Result := True;
end;

function TKeyOrderItem.Load;
begin
  try
    LoadToFile;
  except
    on E : Exception do
    begin
      gLog.Add(lkError, UNIT_TITLE, 'Load', E.Message);
      Result := False;
    end;
  end;
  Result := True;
end;




function TKeyOrderItem.GetOptionDelteQty(aSymbol: TSymbol): Integer;
const
  FUTURE_DELTE = 5;
var
  OptPrice, U , E , R , V , T , TC , W : Double;
  ExpireDateTime: TDateTime;
  aCalcType : TRdCalcType;
  //aRpParams : TRpParams;
  dCallVol, dPutVol : Double;
  dVolIVMounted : Boolean;
  dDelta : Double;
begin
  // 옵션만 가능
  {

  try

    if aSymbol.SymbolType <> stOption then Exit;

    if  FUnderlying = nil then
    FUnderlying:=  gPrice.SymbolStore.FindSymbol(KOSPI200_CODE);

    FNearFuture:= gPrice.SymbolStore.NearestFuture[utKospi200];
    ExpireDateTime := gServerInfo.StdDate + aSymbol.RemDays-1 + EncodeTime(15,15,0,0); //만기일시

    aRpParams := TRpParams.Create(TRpParamItem);
    aRpParams.CloneParams(gPrice.RpParams);

    with aRpParams.SParams[FUnderlying] do
    begin
      dCallVol := CallVol;
      dPutVol  := PutVol;
      aCalcType := RdCalcType;
      dVolIVMounted := VolIVMounted;
    end;

    OptPrice := aSymbol.C;

    //U := FMixedClose;
    if FUnderlying.UnderlyingType = utKospi200 then
      U := GetModifiedIndex(FUnderlying.C , FNearFuture.C, FMixRatio, aSymbol.DividendRate)
    else
      U := FUnderlying.C;

    E := aSymbol.StrikePrice;
    R := aSymbol.CDRate;

    ExpireDateTime := gServerInfo.StdDate + aSymbol.RemDays - 1 + EncodeTime(15, 15, 0, 0);
    T := gPrice.Holidays.CalcRemainDays(Now , ExpireDateTime , aCalcType);
    TC := aSymbol.RemDays / 365;
    if aSymbol.OptionType = otCall then
    begin
      V := dCallVol;
      W := 1;
    end else
    begin
      V := dPutVol;
      W := -1;
    end;

    //
    if dVolIVMounted then
      V := IV(U,E,R,T,TC,OptPrice,W);

    // 델타 수량을 구함
    dDelta := Delta(U, E, R, V, T, TC, W);

    Result :=  Trunc(FUTURE_DELTE / ABS(dDelta));

    aRpParams.Free;
  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'GetOptionDelteQty', E.Message);
  end;
  }
end;

//
//
function TKeyOrderItem.GetActionByKey(aKey: Word): TKActionType;
var
  i : Integer;
begin

  Result := atNull;

  for i:= 0 to FActions.Count-1 do
    with FActions.Items[i] as TKeyActionItem do
      if Key = aKey then
      begin
        Result :=  KActionType;
        Exit;
      end;

end;


//
//
//
function TKeyOrderItem.RemoveAction(aKeyAction : TKActionType): Boolean;
var
  i : Integer;
begin
  Result := False;
  for i:= 0 to FActions.Count-1 do
    with FActions.Items[i] as TKeyActionItem do
    if KActionType = aKeyAction then
    begin
      FActions.Delete(i);
      Result := True;
      Exit;
    end;
//
end;


// 키보드 action 을 가지고 온다.
function TKeyOrderItem.GetKeyDesc(var aRec: TKeyRec; aKey : Word): Boolean;
var
  i : Integer;

  function GetSymbolTypeDesc(aSymbolType1 : TKeySymbolType) : String;
  begin
    case aSymbolType1 of
      ktSymbolA : Result := ' [종목 A]';
      ktSymbolB : Result := ' [종목 B]';
      else
        Result := '';
    end;
  end;

begin
  Result := False;

  aRec.OrgKey := '';
  aRec.CtrlKey := '';
  aRec.AltKey := '';

  for i:= 0 to FActions.Count-1 do
  with FActions.Items[i] as TKeyActionItem do
    if Key = aKey then
    begin
      if ssCtrl in Shift then aRec.CtrlKey := KEY_DESC[KActionType] + GetSymbolTypeDesc(KeySymbolType)
      else if ssAlt in Shift  then  aRec.AltKey  := KEY_DESC[KActionType]+ GetSymbolTypeDesc(KeySymbolType)
      else aRec.OrgKey := KEY_DESC[KActionType]+ GetSymbolTypeDesc(KeySymbolType);
    end;
end;

//
//
//
function TKeyOrderItem.GetQty(iIndex: Integer;
  aSymbolType: TKeySymbolType): Integer;
begin
  Result := FQty[iIndex, aSymbolType];
end;

//
//
//
procedure TKeyOrderItem.SetQty(iIndex: Integer;
  aSymbolType: TKeySymbolType; const Value: Integer);
begin
  FQty[iIndex, aSymbolType] := Value;

  if Assigned( FOnChange ) then FOnChange(Self);
end;


//  Get Active Key List
//  2006-03
//
function TKeyOrderItem.GetKeyActionList(aList: TList): Boolean;
var
  i : Integer;
begin
  Result := False;

  if aList = nil then Exit;

  aList.Clear;

  for i:=0 to FActions.Count-1 do
    aList.Add( FActions.Items[i] as TKeyActionItem  );

  Result := True;
end;


//
//
//
function TKeyOrderItem.GetActions(aList: TList): Boolean;
var
  i : Integer;
begin
  Result := False;

  if aList = nil then Exit;

  aList.Clear;
  for i:= 0 to FActions.Count-1 do
    aList.Add( FActions.Items[i] as TKeyActionItem );

  Result := True;
end;

//
//
//
procedure TKeyOrderItem.QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aQuote : TQuote ;
begin
  if FEnable = False then Exit;

  try
    if (Receiver <> Self) or (DataObj = nil)  then Exit;

    aQuote := DataObj as TQuote;


    if aQuote.Symbol = FSymbolA then  FSymbolAQueue.Add(aQuote.Symbol);
    if aQuote.Symbol = FSymbolB then  FSymbolBQueue.Add(aQuote.Symbol);

  except
    on E : Exception do
      gLog.Add(lkError, UNIT_TITLE, 'QuoteProc' , E.Message);
  end;
end;


//
//
//
procedure TKeyOrderItem.SetSymbolA(const Value: TSymbol);
begin
  if FSymbolA <> nil then  gEnv.Engine.QuoteBroker.Cancel( self, FSymbolA);
  FSymbolA := Value;
  {
  FSymbolA.Subscribe(PID_Quote, [btUpdate], Self, QuoteProc);
  }
end;


//
//
//
procedure TKeyOrderItem.SetSymbolB(const Value: TSymbol);
begin     {
  if FSymbolB <> nil then FSymbolB.Unsubscribe(Self);
  FSymbolB := Value;

  FSymbolB.Subscribe(PID_Quote, [btUpdate], Self, QuoteProc);
  }
end;


//
//
//
procedure TKeyOrderItem.SetSymbolADelayTime(const Value: Integer);
begin
  FSymbolADelayTime := Value;
end;


//
//
//
procedure TKeyOrderItem.SetSymbolBDelayTime(const Value: Integer);
begin
  FSymbolBDelayTime := Value;
end;

//
//
//
function TKeyOrderItem.GetDelayedSymbol( aCircular: TCircularList; dCurrentTime : TDateTime; iDelay : Integer): TSimpleSymbol;
var
  i : Integer;
  dSeekTime : TDateTime;
begin
  if aCircular = nil then Exit;

  dSeekTime := dCurrentTime-iDelay*1.0/(24*3600*1000);

  for i := aCircular.Size-1 downto 0 do
  begin
    Result := aCircular[i];
    if aCircular[i].RecvTime < (dSeekTime + epsilon) then
      break;
  end;
end;


//
//
//
function TKeyOrderItem.RemoveAll: Boolean;
var
  i : Integer;
begin
  Result := False;

  try
    for i:= FActions.Count-1 downto 0 do
      FActions.Delete(i);
  except
    on E : Exception do
      gLog.Add(lkError, 'KeyOrderItem', 'RemoveAll' , E.Message);
  end;

  Result := True;
end;



function TKeyOrderItem.GetMacro(iKey: Integer): String;
begin
  Result := '';
  if (iKey < VK_F2) or (iKey > VK_F12) then Exit;

  Result := FMacroKey[iKey];
end;

procedure TKeyOrderItem.SetMacro(iKey: Integer; const Value: String);
begin
  if (iKey < VK_F2) or (iKey > VK_F12) then Exit;

  FMacroKey[iKey] := Value;
end;

function TKeyOrderItem.GetMacroSymbol(iKey: Integer): String;
begin
  Result := '';
  if (iKey < VK_F2) or (iKey > VK_F12) then Exit;

  Result := FMacroSymbol[iKey];
end;

procedure TKeyOrderItem.SetMacroSymbol(iKey: Integer; const Value: String);
begin
  if (iKey < VK_F2) or (iKey > VK_F12) then Exit;

  FMacroSymbol[iKey] := Value;

end;

function TKeyOrderItem.DoAction(aAction: TKActionType; aKeySymbolType: TKeySymbolType): Boolean;
var
  aSymbol : TSymbol;
  strAction : String;
  iQty :  Integer;
  aSimpleSymbol: TSimpleSymbol;
  stText : String;
begin

  strAction := '';

  case aKeySymbolType of
    ktSymbolA :
      begin
        iQty := FSymbolAQty;
        aSymbol := SymbolA;
        aSimpleSymbol := GetDelayedSymbol(FSymbolAQueue, Now, FSymbolADelayTime);
      end;
    ktSymbolB :
      begin
        iQty := FSymbolBQty;
        aSymbol := SymbolB;
        aSimpleSymbol := GetDelayedSymbol(FSymbolBQueue, Now, FSymbolBDelayTime);
      end;
    ktSymbolAll : iQty := 0;
    ktNone : iQty := 0;
  end;

  stText := Format('Delay=%d ms, Delayed=%s, Now=%s, Old=%s',
                          [FSymbolADelayTime,
                           FormatDateTime('ss.zzz', Now-aSimpleSymbol.RecvTime),
                           FormatDateTime('ss.zzz', Now),
                           FormatDateTime('ss.zzz', aSimpleSymbol.RecvTime)]);
  gLog.Add(lkDebug, UNIT_TITLE, 'DelayTime', stText);

  case aAction of
    atNewLong1..atNewLong6   :  PutNewLongOrder(aSimpleSymbol, iQty,  aAction); // 신규매수주문
    atNewShort1..atNewShort6 :  PutNewShortOrder(aSimpleSymbol, iQty, aAction); // 신규매도주문
    atProfitExit1..atProfitExit2 : PutProfitExit(aSimpleSymbol, iQty, aAction); // 이익청산
    atClear1..atClear4 :     PutClear(aSimpleSymbol, iQty, aAction); // 청산
    atSellExit1..atSellExit3 :   PutSellExit(aSimpleSymbol, iQty ,aAction); // 전매도
    atBuyExit1..atBuyExit3  :   PutBuyExit(aSimpleSymbol, iQty, aAction); //환매수
    // 취소
    atCancelAll..atCancelLong     : PutCancelOrder(aSimpleSymbol, aAction);

    // 2006-08-05 LSY 정정주문 기능변경 : 매수/매도 동시 정정으로 수정
    //
    // 정정주문
    atChangeLong1   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:매도1}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:매수1}
      end;
    atChangeLong2   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:매도2}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:매수2}
      end;
    atChangeLong3   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:매수1}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:매도1}
      end;
    atChangeLong4   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:매수1+1틱}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:매도1-1틱}
      end;
    atChangeLong5   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:매수1+2틱}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:매도1-2틱}
      end;
    atChangeLong6   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:현재가}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:현재가}
      end;
    atChangeLong7   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:주문가+1틱}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:주문가-1틱}
      end;
    atChangeLong8   :
      begin
        PutChangeLongOrder(aSimpleSymbol,    aAction);  {매수정정:주문가+2틱}
        PutChangeShortOrder(aSimpleSymbol,   aAction); {매도정정:주문가-2틱}
      end;
    //
    atChangeShort1..atChangeShort8  : PutChangeShortOrder(aSimpleSymbol,   aAction);
    //
    //aAction

    atQty1..atQty6 :
      begin
        case aKeySymbolType of
          ktSymbolA : FSymbolAQty := FQty[Ord(aAction) - Ord(atQty1) + 1,ktSymbolA];
          ktSymbolB : FSymbolBQty := FQty[Ord(aAction) - Ord(atQty1) + 1,ktSymbolB];
        end;
      end;
    atQty7..atQty11 :
      case aKeySymbolType of
        ktSymbolA : FSymbolAQty := GetCurQty(aSymbol) div (Ord(aAction) - Ord(atQty7) + 1) ;
        ktSymbolB : FSymbolBQty := GetCurQty(aSymbol) div (Ord(aAction) - Ord(atQty7) + 1) ;
      end;
    atQtyDelta :
      case aKeySymbolType of
        ktSymbolA : FSymbolAQty := GetOptionDelteQty(aSymbol);
        ktSymbolB : FSymbolBQty := GetOptionDelteQty(aSymbol);
      end;
  end;
  {
  if aAction in [atQty1..atQty11] then
    FBroadcaster.Broadcast(Self, Self, PID_KEYORDER, btNew);
  }

  if Assigned(FOnLog) then FOnLog(Self, 0 , [], strAction);
end;


//  MacroPlay 를  실행하기 위한것
//
//
procedure TKeyOrderItem.MacroPlay(aKey: Word);
begin
  FMacroActionCnt:= GetTokens(FMacroKey[aKey],  FMacroActionTokens, ',');
  if (FMacroActionCnt <=0) or
     (GetTokens(FMacroSymbol[aKey],  FMacroSymbolTokens, ',') <=0) then Exit;
  FMacroPlayIndex := 0;
  FMacroDelayTime :=0;
  FIsPlay := True;

  FTimer.Enabled := True;
end;


//  Macro Play를 위한 루틴
//
//
procedure TKeyOrderItem.TimeProc(Sender: TObject);
var
  aAction: TKActionType;
  aKeySymbolType: TKeySymbolType;

  //
  function IsAction(strAction : String) : Boolean;
  begin
    if StrToIntDef(strAction, 0) = 0 then
      Result := True
    else
      Result := False;
  end;
  //
  function FindAction(strAction : String) : TKActionType;
  var aAct : TKActionType;
  begin
    Result := atNull;

    for aAct := atFirst to atLast do
      if KEY_TYPES[aAct] = strAction then
      begin
        Result := aAct;
        Break;
      end;
  end;
  //
  function FindSymbol(strSymbol : String) : TKeySymbolType;
  begin
    if strSymbol = 'A' then Result := ktSymbolA
    else if strSymbol = 'B' then Result := ktSymbolB;
  end;

begin
  if FMacroActionTokens = nil then Exit;
  if FMacroSymbolTokens = nil then Exit;

  if IsAction(FMacroActionTokens[FMacroPlayIndex]) then
  begin
    aAction        := FindAction( FMacroActionTokens[FMacroPlayIndex] );
    aKeySymbolType := FindSymbol( FMacroSymbolTokens[FMacroPlayIndex] );

    DoAction(aAction, aKeySymbolType);
    Inc(FMacroPlayIndex)
  end
  else
  begin
    if FMacroDelayTime = 0 then
      FMacroDelayTime := StrToInt(FMacroActionTokens[FMacroPlayIndex]);

    Dec(FMacroDelayTime);
    if FMacroDelayTime <= 0 then Inc(FMacroPlayIndex);
  end;

  if FMacroActionCnt <= FMacroPlayIndex then
  begin
    FMacroActionCnt := 0;
    FMacroPlayIndex := 0;
    FMacroDelayTime := 0;
    FTimer.Enabled:= False;
    FIsPlay := False;
  end;

end;



//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------

procedure TKeyOrderItem.Subscribe(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject;
      EventIDs: TDistributorIDs; aHandler: TDistributorEvent);
begin
{
  //--1. create broadcaster if it hasn't been created
  if FBroadcaster = nil then
    FBroadcaster := TBroadcaster.Create;

  //--4. put to the broadcaster
  FBroadcaster.Subscribe(iKind, btValues, Receiver, aProc);
  }
end;

procedure TKeyOrderItem.Unsubscribe(Receiver: TObject);
begin
{
  if FBroadcaster = nil then Exit;

  //-- unsubscribe from the broadcaster
  FBroadcaster.Unsubscribe(Receiver);
  }
end;


//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------

procedure TKeyOrderItem.Active;
begin
  if Assigned(FOnSelect) then FOnSelect(Self);
end;

procedure TKeyOrderItem.SetKeyOrderMap(const Value: String);
begin
  try
    FKeyOrderMap := Value;

    if FileExists(FKeyOrderMap) then Load;
  except
    on E : Exception do
    begin
      gLog.Add(lkError, UNIT_TITLE, 'SetKeyOrderMap', E.Message);
    end;
  end;
end;


//
//  New KeyOrder Key Item
//
function TKeyOrderItem.AddOrderKey(wKey: Word; aShift: TShiftState;
  aSymbolType: TkeySymbolType; aKActionType: TKActionType): Boolean;
begin
  Result := False;
  if (wKey = 0) or (wKey = (Ord(' '))) then Exit;

  with FActions.Add as TKeyActionItem do
  begin
    KeyDesc := KEY_DESC[aKActionType];
    Key := wKey;
    Shift := aShift;
    KeySymbolType := aSymbolType;
    KActionType := aKActionType;
  end;

  Result := True;
end;

procedure TKeyOrderItem.SetSymbolDelayTime(aSymbolType: TKeySymbolType;
  const Value: Integer);
begin

  case aSymbolType of
    ktSymbolA : FSymbolADelayTime := Value;
    ktSymbolB : FSymbolBDelayTime := Value;
  end;

end;

function TKeyOrderItem.GetSymbolDelayTime(aSymbolType: TKeySymbolType): Integer;
begin
  case aSymbolType of
    ktSymbolA : Result := FSymbolADelayTime;
    ktSymbolB : Result := FSymbolBDelayTime;
  end;
end;

function TKeyOrderItem.NewKeyAction(aKey: Word; aShift: TShiftState;
  aKeySymbolType: TKeySymbolType; aKActionType: TKActionType): TKeyActionItem;

var
  i : Integer;
  bFind : Boolean;
begin
  // New 일때는 Result 에 Item 이 생성이 되고 기존 Action에 변경이 있으면
  // Result는 nil 이 들어간다.
  //  호출한 함수에서 이 Result를 Add를 하기 때문에 이렇게 구현하였음

  Result := nil;
  bFind := False;

  // find Action

  for i:=0 to FActions.Count-1 do
    with FActions.Items[i] as TKeyActionItem do
      if aKActionType = KActionType then
      begin
        //Result := FActions.Items[i] as TKeyActionItem;
        Key := aKey;
        Shift := aShift;
        KeySymbolType := aKeySymbolType;
        KeyDesc := KEY_DESC[aKActionType];
        bFind := True;
        Break;
      end;


  if not bFind then // not find
  begin
    Result := FActions.Add as TKeyActionItem;

    with Result do
    begin
      Key := aKey;
      Shift := aShift;
      KeySymbolType := aKeySymbolType;
      KActionType := aKActionType;
      KeyDesc := KEY_DESC[aKActionType];
    end;
  end;

end;

function TKeyOrderItem.IsUsed(aKey: Word; aShift: TShiftState): Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FActions.Count-1 do
    with FActions.Items[i] as TKeyActionItem do
    if (Key = aKey) and (Shift = aShift) then
    begin
      Result := True;
      Exit;
    end;
end;

function TKeyOrderItem.RemoveKey(aKey: Word): Boolean;
var
  i : Integer;
begin
  for i:= FActions.Count-1 downto 0 do
    with FActions.Items[i] as TKeyActionItem do
      if Key = aKey then FActions.Delete(i);

  Result := True;
end;

function TKeyOrderItem.GetActionDesc(aKActionType: TKActionType): String;
var
  i : Integer;
begin

  for i:= 0 to FActions.Count-1 do
  with FActions.Items[i] as TKeyActionItem do
  if KActionType = aKActionType then
  begin
    if ssCtrl in Shift then
      Result := 'Ctrl + '
    else if ssAlt in Shift then
      Result := 'Alt + ';

    Break;
  end;


end;



end.





