unit OmegaIF;

interface

uses
  Classes, Dialogs, SysUtils, Controls, Buttons,

  EnvFile, //LogCentral,

  StccDef, ORTCLib_TLB,
  SystemIF, DSignalAlias;

type
  TORSyncItem = class(TCollectionItem)
  public
    Strategy : String;
    Symbol : String;
    Interval : String;
    PositionNo : Integer; // primary key #1
    EntryID : Integer;    // primary key #2
    Qty : Integer;
  end;

  TORSignalItem = class(TSignalItem)
  public
    Strategy : String;
    Symbol : String;
    Interval : String;
  end;

  TOmegaIF = class(TSystemIF)
  private
    FStccBroker : TStccBroker;
    
    FSyncs : TCollection{TORSyncItem};
    FSignals : TCollection{TORSignalItem};

    //procedure PutLog(stLog : String);
    // synchronize to TradeStation(tm)
    procedure ORSynchronize;
    procedure UpdateAllPositions;
    procedure UpdatePosition(aSignal : TORSignalItem);
    function AddSync(aPosition : IOpenPosition) : TORSyncItem;
    function DeleteSync(aPosition : IOpenPosition) : Boolean;
    // process realtime event
    procedure OpenEvent(ekValue : TStccBrokerEventKind; aObj : IDispatch);
    procedure FillEvent(ekValue : TStccBrokerEventKind; aObj : IDispatch);
    // manage signals
    function FindSignal(stStrategy, stSymbol : String) : TORSignalItem; overload;
    function FindSignal(stAlias : String) : TORSignalItem; overload;
    function CheckSignal(stAlias : String) : Boolean; overload;
    function CheckSignal(stStrategy, stSymbol : String) : Boolean; overload;
    procedure LoadSignals;
    procedure SaveSignals;
    // property methods
    function GetCount : Integer;
    function GetSignal(i:Integer) : TORSignalItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize; override;
    procedure Synchronize; override;
    procedure Finalize; override;

    procedure GetSignals(aList : TList); override;

    procedure DumpSyncs;

    function AddSignal : Boolean;
    function EditSignal(aSignal : TORSignalItem) : Boolean;
    function RemoveSignal(aSignal : TORSignalItem) : Boolean;

    property SignalCount : Integer read GetCount;
    property Signals[i:Integer] : TORSignalItem read GetSignal;
  end;

implementation

uses GAppEnv;

const
  SIGNAL_FILE = 'sigalias.gsu';


{ TOmegaIF }

//--------------------------------< Start / Finish >-----------------------//

constructor TOmegaIF.Create;
begin
  inherited;
  
  FDescription := 'TradeStation';

  FStccBroker := TStccBroker.Create(nil);
  FStccBroker.OnOpenEvent := OpenEvent;
  FStccBroker.OnFilledEvent := FillEvent;

  FSyncs := TCollection.Create(TORSyncItem);
  FSignals := TCollection.Create(TORSignalItem);

  LoadSignals;
end;

destructor TOmegaIF.Destroy;
begin
  // SaveSignals;

  FSyncs.Free;
  FSignals.Free;

  FStccBroker.Free;

  inherited;
end;

procedure TOmegaIF.Initialize;
begin
  inherited;

  FStccBroker.Connect;

  if not FStccBroker.Connected then
    ShowMessage('TradeStation을 연결하지 못했습니다.')
  else
  begin
    FLastTime := Now;

    Synchronize;
  end;

end;

procedure TOmegaIF.Synchronize;
begin
  if FStccBroker.Connected then
  begin
    // synchronize open positions
    ORSynchronize;
    // update positions
    UpdateAllPositions;
  end;
end;

procedure TOmegaIF.Finalize;
begin
  inherited;

end;

//---------------------< Manage Syncronized items >-------------------//

//
// get position list from TradeStation
//
procedure TOmegaIF.ORSynchronize;
var
  i : Integer;
  aPosition : IOpenPosition;
begin
  //--1. Clear storage
  FSyncs.Clear;

  //--2. get position list
  try
    for i := FStccBroker.OpenPositions.Count downto 1 do
    try
      //aPosition := IOpenPosition( FStccBroker.OpenPositions.Item(i));// as IOpenPosition;
      //AddSync(aPosition);
    except
      // ignored
    end;
  except
    // ignored
  end;
end;

procedure TOmegaIF.DumpSyncs;
var
  i : Integer;
  aItem : TORSyncItem;
begin
  DoLog('=============================');
  for i:=0 to FSyncs.Count-1 do
  begin
    aItem := FSyncs.Items[i] as TORSyncItem;
    DoLog(Format('%s,%s,%s,Pos#%d,ID#%d,Q:%d',
                  [aItem.Strategy,
                   aItem.Symbol,
                   aItem.Interval,
                   aItem.PositionNo,
                   aItem.EntryID,
                   aItem.Qty]));
  end;
  DoLog('=============================');
end;

function TOmegaIF.DeleteSync(aPosition : IOpenPosition) : Boolean;
var
  i, iPosNo, iEntryID : Integer;
begin
  Result := False;
  if aPosition = nil then Exit;
  
  iPosNo := StrToIntDef(aPosition.PositionNumber, -1);
  if iPosNo < 0 then Exit;
  iEntryID := aPosition.EntryID;

  for i:=FSyncs.Count-1 to 0 do
  with FSyncs.Items[i] as TORSyncItem do
    if (PositionNo = iPosNo) and (EntryID = iEntryID) then
    begin
      FSyncs.Items[i].Free;

      Result := True;
      Break;
    end;
end;

function GetStrategyTitle(stStrategy : String) : String;
var
  iPos : Integer;
begin
  iPos := Pos('(', stStrategy);
  if iPos < 1 then
    Result := stStrategy
  else
    Result := Copy(stStrategy, 1, iPos-1);
end;

function TOmegaIF.AddSync(aPosition : IOpenPosition) : TORSyncItem;
var
  i, iPos, iLen : Integer;
  stAlert : String;
  stSignal : String;
begin
  Result := FSyncs.Add as TORSyncItem;

  Result.Strategy   := GetStrategyTitle(aPosition.System_);
  Result.Symbol     := aPosition.Symbol;
  Result.Interval   := aPosition.Interval; // meaningless
  Result.PositionNo := StrToIntDef(aPosition.PositionNumber, 0);
  Result.EntryID    := aPosition.EntryID;

  stAlert := aPosition.AlertString;
  iLen := Length(stAlert);

  if iLen > 5 then
    Result.Qty := StrToIntDef(Copy(stAlert,6, iLen-5), 0)
  else
    Result.Qty := 0;

  if Pos('Short', stAlert) > 0 then
    Result.Qty := -Result.Qty;
end;

//---------------------< Caculate positions quantity >-------------------//

// (private)
// <-- called from Synchronize() and OpenEvent()
// calculate position qunatity for all register signal aliases
//
procedure TOmegaIF.UpdateAllPositions;
var
  i : Integer;
begin
  for i:=0 to FSignals.Count-1 do
    UpdatePosition(FSignals.Items[i] as TORSignalItem);
end;

function UpperCompare(Str1, Str2 : String) : Integer;
begin
  Result := CompareStr(UpperCase(Str1), UpperCase(Str2));
end;

// (private)
// <-- called from UpdateAllPositions(), AddSignal(), UpdateSignal(), OpenEvent()
// calculate positions quantity of a signal alias from sync items
//
procedure TOmegaIF.UpdatePosition(aSignal : TORSignalItem);
var
  i, iOldSum, iSum : Integer;
  aItem : TORSyncItem;
begin
  if aSignal = nil then Exit;

  iOldSum := aSignal.Position;

  //-- get position sum
  iSum := 0;

  for i:=0 to FSyncs.Count-1 do
  begin
    aItem := FSyncs.Items[i] as TORSyncItem;
    if (UpperCompare(aSignal.Strategy, aItem.Strategy) = 0) and
       (UpperCompare(aSignal.Symbol, aItem.Symbol) = 0) then
      iSum := iSum + aItem.Qty;
  end;
  {
  //-- if position has changed, notify that to client
  if iOldSum <> iSum then
  begin
    aSignal.Position := iSum;
    aSignal.LastTime := Now;

    if Assigned(FOnPositionChange) then
      FOnPositionChange(Self, aSignal);
  end;  khw
  }
  aSignal.Position := iSum;
  aSignal.LastTime := Now;

  if Assigned(FOnPositionChange) then
    FOnPositionChange(Self, aSignal);
end;

//----------------------------< manage signal alias >----------------------//

// (private)
// Find signal alias by strategy and symbol
//
function TOmegaIF.FindSignal(stStrategy, stSymbol : String) : TORSignalItem;
var
  i : Integer;
  aSignal : TORSignalItem;
  stSignal : String;
begin
  Result := nil;

  //-- cut parameter from the strategy
  stSignal := GetStrategyTitle(stStrategy);

  //-- find 
  for i:=0 to FSignals.Count-1 do
  begin
    aSignal := FSignals.Items[i] as TORSignalItem;
    if (UpperCompare(aSignal.Strategy, stSignal) = 0) and
       (UpperCompare(aSignal.Symbol, stSymbol) = 0) then
    begin
      Result := aSignal;
      Break;
    end;
  end;
end;

// (private)
// find a signal alias by alias name
//
function TOmegaIF.FindSignal(stAlias : String) : TORSignalItem;
var
  i : Integer;
  aSignal : TORSignalItem;
begin
  Result := nil;

  for i:=0 to FSignals.Count-1 do
  begin
    aSignal := FSignals.Items[i] as TORSignalItem;
    if UpperCompare(aSignal.Title, stAlias) = 0 then
    begin
      Result := aSignal;
      Break;
    end;
  end;
end;

// (public)
// get signal list
//
procedure TOmegaIF.GetSignals(aList: TList);
var
  i : Integer;
begin
  if aList = nil then Exit;

  for i:=0 to FSignals.Count-1 do
    aList.Add(FSignals.Items[i]);
end;

// (private)
// check if a signal alias duplicate by the alias title
//
function TOmegaIF.CheckSignal(stAlias : String) : Boolean;
begin
  Result := (FindSignal(stAlias) = nil);

  if not Result then
    ShowMessage('해당 신호명은 이미 사용중입니다.');
end;

// (private)
// check if a signal alis duplicate by strategy and symbol
//
function TOmegaIF.CheckSignal(stStrategy, stSymbol : String) : Boolean;
begin
  Result := (FindSignal(stStrategy, stSymbol) = nil);

  if not Result then
    ShowMessage('해당 신호는 이미 정의되었습니다.');
end;

// (public)
// add a signal alias using dialog
//
function TOmegaIF.AddSignal : Boolean;
var
  aSignal : TORSignalItem;
  aDlg : TSignalAliasDialog;
begin
  aDlg := TSignalAliasDialog.Create(nil);
  try
    if aDlg.ShowModal <> mrOK then Exit;

    if CheckSignal(aDlg.Alias) and
       CheckSignal(aDlg.Strategy, aDlg.Symbol) then
    begin
      aSignal := FSignals.Add as TORSignalItem;
      aSignal.Source := FDescription;
      aSignal.Title := aDlg.Alias;
      aSignal.Description := aDlg.Description;

      aSignal.Strategy := aDlg.Strategy;
      aSignal.Symbol := aDlg.Symbol;
      // aSignal.Interval := aDlg.Interval;

      // notify for update of the signal list
      if Assigned(FOnSignalAdd) then
        FOnSignalAdd(Self, aSignal);

      // recalc the position quantity
      UpdatePosition(aSignal);

      // save
      SaveSignals; // added by CHJ on 2004.5.28
    end;
  finally
    aDlg.Free;
  end;
end;

// (public)
// edit a signal using a dialog
//
function TOmegaIF.EditSignal(aSignal : TORSignalItem) : Boolean;
var
  aDlg : TSignalAliasDialog;
begin
  if aSignal = nil then Exit;

  // check duplicity
  if (aSignal.RefCount > 0) and
     (MessageDlg('해당 신호는 주문에 사용되고 있습니다. '#13 +
                  '그래도 수정하시겠습니까?', mtConfirmation, 
                  [mbYes,mbCancel], 0) = mrCancel) then
      Exit;

  // show dialog
  aDlg := TSignalAliasDialog.Create(nil);
  try
    aDlg.Alias := aSignal.Title;
    aDlg.Description := aSignal.Description;
    aDlg.Strategy := aSignal.Strategy;
    aDlg.Symbol := aSignal.Symbol;
    //aDlg.Interval := aSignal.Interval;

    if aDlg.ShowModal <> mrOK then Exit;

    // check 1
    if (CompareStr(aDlg.Alias, aSignal.Title) <> 0) and
       (not CheckSignal(aDlg.Alias)) then
      Exit;
    // check 2
    if ((CompareStr(aDlg.Strategy, aSignal.Strategy) <> 0) or
        (CompareStr(aDlg.Symbol, aSignal.Symbol) <> 0)) and
       (not CheckSignal(aDlg.Strategy, aDlg.Symbol)) then
      Exit;
    //
    aSignal.Title := aDlg.Alias;
    aSignal.Description := aDlg.Description;
    aSignal.Strategy := aDlg.Strategy;
    aSignal.Symbol := aDlg.Symbol;
    //aSignal.Interval := aDlg.Interval;
    //
    if Assigned(FOnSignalUpdate) then
      FOnSignalUpdate(Self, aSignal);

    UpdatePosition(aSignal);

    // save
    SaveSignals; // added by CHJ on 2004.5.28
  finally
    aDlg.Free;
  end;
end;

// (public)
// remove a signal
//
function TOmegaIF.RemoveSignal(aSignal : TORSignalItem) : Boolean;
begin
  if aSignal = nil then Exit;

  // check usage
  if (aSignal.RefCount > 0) and
     (MessageDlg('해당 신호는 주문에 사용되고 있습니다. '#13 +
                  '그래도 삭제하시겠습니까?', mtConfirmation,
                  [mbYes,mbCancel], 0) = mrCancel) then
      Exit;
  //
  if Assigned(FOnSignalRemoving) then
    FOnSignalRemoving(Self, aSignal);

  aSignal.Free;

  if Assigned(FOnSignalRemoved) then
    FOnSignalRemoved(Self, nil);

  // save
  SaveSignals; // added by CHJ on 2004.5.28
end;

//-----------------------< StccBroker Event >-------------------------//


// (private)
// an event of open position has arrived
// --> update position sync list
// --> update position quantity if there is a matched signal alias
//
procedure TOmegaIF.OpenEvent(ekValue: TStccBrokerEventKind;
  aObj: IDispatch);
var
  i, iPosNo : Integer;
  aSync : TORSyncItem;
  aSignal : TORSignalItem;
  aPosition : IOpenPosition;

  function DescribePosition(aPos : IOpenPosition) : String;
  begin
    if aPos = nil then
      Result := ''
    else
      Result := Format('%s/%s/%s/P#%s/E#%d', [aPos.System_,
                                              aPos.Symbol,
                                              aPos.Interval,
                                              aPos.PositionNumber,
                                              aPos.EntryID]);
  end;
begin
  FLastTime := Now;
  if Assigned(FOnLastTime) then
    FOnLastTime(Self);

  if ekValue = ekReset then
  begin
    FSyncs.Clear;
    UpdateAllPositions;
  end else
  if aObj <> nil then
  begin
    aPosition := aObj as IOpenPosition;

    //-- get position number
    iPosNo := StrToIntDef(aPosition.PositionNumber, -1);
    if iPosNo < 0 then Exit;

    //-- find the sync item
    aSync := nil;
    for i:=0 to FSyncs.Count-1 do
    begin
      if (FSyncs.Items[i] as TORSyncItem).PositionNo = iPosNo then
      begin
        aSync := FSyncs.Items[i] as TORSyncItem;
        Break;
      end;
    end;

    //-- process following the finding result
    case ekValue of
       ekAdd :
        begin
          if aSync = nil then
          begin
            aSync := AddSync(aPosition);
            aSignal := FindSignal(aSync.Strategy, aSync.Symbol);
            if aSignal = nil then exit;
            UpdatePosition(aSignal);
            aSync.EntryID := aPosition.EntryID;
          end;
        end;
        ekModify :
       begin
          if aSync = nil then
            aSync := AddSync(aPosition);
          aSignal := FindSignal(aSync.Strategy, aSync.Symbol);
          if aSignal = nil then exit;
          if aSync.Qty = aSignal.Position then exit;
          UpdatePosition(aSignal);
          aSync.EntryID := aPosition.EntryID;
        end;
      ekRemove :
        begin
          // only perfect match could be deleted
          if (aSync <> nil) and (aSync.EntryID = aPosition.EntryID) then
          begin
            aSignal := FindSignal(aSync.Strategy, aSync.Symbol);
            aSync.Free;
            if aSignal = nil then exit;
            UpdatePosition(aSignal);
          end else
          begin

          end;
        end; //.. ekRemove:
    end; // case ekValue of
  end; //.. if aObj <> nil then
end;

// (private)
// a new fill order event has arrived
// --> parse event message
// --> fire a new order if any matched signal alias
//
procedure TOmegaIF.FillEvent(ekValue: TStccBrokerEventKind; aObj: IDispatch);
var
  aFill : IFilledOrder;
  aSignal : TORSignalItem;
  aEvent : TSignalEventItem;
  i, iSign, iQty : Integer;
  stQty : String;

  function DescribeFill(aFill1 : IFilledOrder) : String;
  begin
    if aFill1 = nil then
      Result := ''
    else
      Result :=  Format('%s/%s/%s/%s/%s', [aFill1.System_,
                                            aFill1.Symbol,
                                            aFill1.Interval,
                                            aFill1.OrderType,
                                            aFill1.Order]);
  end;
begin
  //gEnv.OnLog(self, 'FillEvent Call');
  //
  FLastTime := Now;
  if Assigned(FOnLastTime) then
    FOnLastTime(Self);

  //
  if (ekValue <> ekAdd) or (aObj = nil) then Exit;

  //--1. find related signal
  aFill := aObj as IFilledOrder;

  // logging
  gEnv.DoLog(WIN_TS ,'TradeStation >> New Fill(' + DescribeFill(aFill) + ')');
  //aFill.

  aSignal := FindSignal(aFill.System_, aFill.Symbol);
  if aSignal = nil then Exit;

  //--2. get direction
  if Pos('Buy', aFill.Order) > 0 then
    iSign := 1
  else if Pos('Sell', aFill.Order) > 0 then
    iSign := -1
  else
    Exit;

  //--3. get quantity
  stQty := '';
  for i:=1 to Length(aFill.Order) do
    case aFill.Order[i] of
      '0'..'9' : stQty := stQty + aFill.Order[i];
      else if Length(stQty) > 0 then Break;
    end;
  iQty := StrToIntDef(Trim(stQty), 0);
  if iQty = 0 then
  begin
    //..logging
    gEnv.DoLog(WIN_TS, 'OmegaIF >> failed to parse order quantity');

    Exit;
  end;
  iQty := iSign * iQty;
  // logging
  gEnv.DoLog(WIN_TS, 'OmegaIF >> New Order(' + DescribeFill(aFill) + '/Q:' + IntToStr(iQty)+ ')');


  //--4. register fill event
  aEvent := AddEvent(aSignal, iQty, aFill.Order);


  //--6. fire event for order
  if Assigned(FOnOrder) then
  try
    FOnOrder(Self, aEvent);
  except
  end;
end;


//-----------------------------< Get/Set >---------------------------//

function TOmegaIF.GetCount : Integer;
begin
  Result := FSignals.Count;
end;

function TOmegaIF.GetSignal(i:Integer) : TORSignalItem;
begin
  if (i >= 0) and (i <= FSignals.Count-1) then
    Result := FSignals.Items[i] as TORSignalItem
  else
    Result := nil;
end;

//-----------------------------< Load / Save >---------------------------//

// (private)
//  <-- called by constructor
// load signal alias list to a single file
//
procedure TOmegaIF.LoadSignals;
const
  FIELD_COUNT = 5;
var
  i : Integer;
  aEnvFile : TEnvFile;
  aItem : TORSignalItem;
  iSignalCount : Integer;
begin
  aEnvFile := TEnvFile.Create;
  try
    if not aEnvFile.Exists(SIGNAL_FILE) then Exit;

    aEnvFile.LoadLines(SIGNAL_FILE);
    if aEnvFile.Lines.Count mod FIELD_COUNT <> 0 then
    begin
      gEnv.DoLog(WIN_TS, 'OmegaIF 신호표복구 시스템 신호표가 잘못되었습니다.');
      Exit;
    end;
    iSignalCount := aEnvFile.Lines.Count div FIELD_COUNT;

    for i:=0 to iSignalCount-1 do
    begin
      aItem := FSignals.Add as TORSignalItem;

      aItem.Title       := aEnvFile.Lines[i*FIELD_COUNT];
      aItem.Description := aEnvFile.Lines[i*FIELD_COUNT + 1];
      aItem.Strategy    := aEnvFile.Lines[i*FIELD_COUNT + 2];
      aItem.Symbol      := aEnvFile.Lines[i*FIELD_COUNT + 3];
      aItem.Interval    := aEnvFile.Lines[i*FIELD_COUNT + 4];

      aItem.Source      := FDescription;
      aItem.Position    := 0;
    end;
  finally
    aEnvFile.Free;
  end;
end;

// (private)
//  <-- called by destructor
// save signal alias list to a single file
//
procedure TOmegaIF.SaveSignals;
var
  i : Integer;
  aEnvFile : TEnvFile;
  aItem : TORSignalItem;
begin
  aEnvFile := TEnvFile.Create;
  try
    aEnvFile.Lines.Clear;
    for i:=0 to FSignals.Count-1 do
    begin
      aItem := FSignals.Items[i] as TORSignalItem;

      aEnvFile.Lines.Add(aItem.Title);
      aEnvFile.Lines.Add(aItem.Description);
      aEnvFile.Lines.Add(aItem.Strategy);
      aEnvFile.Lines.Add(aItem.Symbol);
      aEnvFile.Lines.Add(aItem.Interval);
    end;
    aEnvFile.SaveLines(SIGNAL_FILE);
  finally
    aEnvFile.Free;
  end;
end;


end.
