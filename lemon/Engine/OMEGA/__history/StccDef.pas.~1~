unit StccDef;

interface

uses
  Windows, Classes, ActiveX, ComObj, SysUtils, Dialogs, Forms, Variants,
  //
  EtcTypes, ORTCLib_TLB;

type 
  TStccBrokerEventKind = (ekAdd, ekModify, ekRemove, ekReset, ekCancel, ekFill);
  TStccBrokerEvent = procedure(ekValue : TStccBrokerEventKind; aObj : IDispatch) of object;
  TStccPeerEvent = procedure(Sender : TObject; iDispID : Integer; aObj : IDispatch) of object;

const
  KIND_DESC : array [TStccBrokerEventKind] of String =
                      ('New', 'Modify', 'Remove', 'Reset', 'Cancel', 'Fill');

type
  
  TStccPeer = class(TCollectionItem, IUnknown, IDispatch)
  protected
    // basic info.
    FServer : IDispatch;  // event source object
    FEventIID : TGUID; // event IID
    // connection info.
    FConnPoint : IConnectionPoint;
    FCookie : LongInt;
    // events
    FOnEvent : TStccPeerEvent;
    FOnLog : TMessageNotifyEvent;
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
    { TStccPeer }
    function Connect(aServer : IDispatch; aEventIID : TGUID) : Boolean;
    procedure DoLog(stMsg : String);
    //function MyInvoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
    //                  Flags: Word; var Params;
    //                  VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; virtual;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;
    
    property OnLog : TMessageNotifyEvent read FOnLog write FOnLog;
    property OnEvent : TStccPeerEvent read FOnEvent write FOnEvent;
  end;

  TStccBroker = class
  private
    FOwner : TForm;
    
    FPeers : TCollection{TStccPeer};

    FStccOrders : IStccOrders;
    FActiveOrders : IActiveOrders;
    FCanceledOrders : ICanceledOrders;
    FFilledOrders : IFilledOrders;
    FOpenPositions : IOpenPositions;
    FATCCAlerts : IATCCAlerts;
    FMessageLogMessages : IMessageLogMessages;

    FConnected : Boolean;

    FOnActiveEvent : TStccBrokerEvent;
    FOnCanceledEvent : TStccBrokerEvent;
    FOnFilledEvent : TStccBrokerEvent;
    FOnOpenEvent : TStccBrokerEvent;
    FOnAlertEvent : TStccBrokerEvent;
    FOnMessageLogEvent : TStccBrokerEvent;
    //
    FOnLog : TMessageNotifyEvent;
    //
    procedure DoLog(stLog : String);
    procedure DoPeerEvents(Sender : TObject; iDispID : Integer; aObj : IDispatch);
  public
    constructor Create(aOwner : TForm);
    destructor Destroy; override;
    function Connect : Boolean;

    procedure AddActiveOrder(stOrder : String);
    procedure AddCanceledOrder(stOrder, stCancel : String);
    procedure AddFilledOrder(stOrder : String);
    procedure AddOpenPosition(stOrder : String);

    property ActiveOrders : IActiveOrders read FActiveOrders;
    property CanceledOrders : ICanceledOrders read FCanceledOrders;
    property FilledOrders : IFilledOrders read FFilledOrders;
    property OpenPositions : IOpenPositions read FOpenPositions;

    property ATCCAlerts : IATCCAlerts read FAtccAlerts;
    property MessageLogMessages : IMessageLogMessages read FMessageLogMessages;

    property OnActiveEvent : TStccBrokerEvent read FOnActiveEvent write FOnActiveEvent;
    property OnCanceledEvent : TStccBrokerEvent read FOnCanceledEvent write FOnCanceledEvent;
    property OnFilledEvent : TStccBrokerEvent read FOnFilledEvent write FOnFilledEvent;
    property OnOpenEvent : TStccBrokerEvent read FOnOpenEvent write FOnOpenEvent;
    property OnAlertEvent : TStccBrokerEvent read FOnAlertEvent write FOnAlertEvent;
    property OnMessageLogEvent : TStccBrokerEvent read FOnMessageLogEvent write FOnMessageLogEvent;

    property OnLog : TMessageNotifyEvent read FOnLog write FOnLog;
    property Connected : Boolean read FConnected;
  end;

implementation

//===========================================================//
//                      { TStccPeer }                        //
//===========================================================//

constructor TStccPeer.Create(aColl : TCollection);
begin
  inherited Create(aColl);

  FServer := nil;
  FConnPoint := nil;
  FCookie := -1;
end;

destructor TStccPeer.Destroy;
var
  iResult : HRESULT;
begin
  if FConnPoint <> nil then
    FConnPoint.Unadvise(FCookie);

  inherited Destroy;
end;

function TStccPeer.Connect(aServer : IDispatch; aEventIID : TGUID) : Boolean;
var
  aContainer : IConnectionPointContainer;
begin
  Result := False;

  if aServer = nil then Exit;

  try
    aContainer := aServer as IConnectionPointContainer;
    aContainer.FindConnectionPoint(aEventIID, FConnPoint);
    if FConnPoint <> nil then
    begin
      FServer := aServer;
      FEventIID := aEventIID;
      
      FConnPoint.Advise(Self, FCookie);
      Result := True;
    end;
  except
    ShowMessage('Connection Failed!');
  end;
end;

function TStccPeer.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
//  with IID do
//  DoLog('Asking IID :' +
//     Format('{%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x}',
//         [D1,D2,D3,D4[0],D4[1],D4[2],D4[3],D4[4],D4[5],D4[6],D4[7]])
//    );

  // We need to return the two event interfaces when they're asked for
  Result := E_NOINTERFACE;

  if GetInterface(IID,Obj) then
    Result := S_OK;
  if IsEqualGUID(IID, FEventIID) and GetInterface(IDispatch, obj) then // query disp interface
    Result := S_OK;
end;

function TStccPeer._AddRef: Integer;
begin
  // ignored
  Result := 1;
end;

function TStccPeer._Release: Integer;
begin
  // ignored
  Result := 1;
end;

function TStccPeer.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
  // Skeleton implementation
  Count  := 0;
  Result := S_OK;
end;

function TStccPeer.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
begin
  // Skeleton implementation
  Result := E_NOTIMPL;
end;

function TStccPeer.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT;
begin
  // Skeleton implementation
  Result := E_NOTIMPL;
end;


//
// just extract first parameter if it is IDispatch pointer
//
function GetDispatchParam(aParams : TDispParams) : IDispatch;
var
  aArg : TVariantArg;
begin
  Result := nil;
  
  if (aParams.cArgs = 0) or
     (aParams.rgvArg = nil) then Exit;

  aArg := aParams.rgvArg^[0];
  if aArg.vt = VT_DISPATCH then
    Result := IDispatch(aArg.dispVal);
end;

function TStccPeer.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
begin
  if Assigned(FOnEvent) then
    FOnEvent(Self, DispID, GetDispatchParam(TDispParams(Params)));

//  //DoLog(Format('Event Ocurred[%d:%d]', [DispID, Flags]));
//  Result := MyInvoke(DispID, IID, LocaleID, Flags, Params,
//                   VarResult, ExcepInfo, ArgErr);
end;

procedure TStccPeer.DoLog(stMsg : String);
begin
  if Assigned(FOnLog) then
    FOnLog(stMsg);
end;

//===========================================================//
//                      { TStccBroker }                      //
//===========================================================//

constructor TStccBroker.Create(aOwner : TForm);
begin
  FConnected := False;
  FOwner := aOwner;

  FPeers := TCollection.Create(TStccPeer);
end;

destructor TStccBroker.Destroy;
begin
  FStccOrders := nil;
  FAtccAlerts := nil;
  FMessageLogMessages := nil;

  FPeers.Free;

  inherited Destroy;
end;


//---------------------< Connect / Receive events >-------------------//

function TStccBroker.Connect : Boolean;
var
  aPeer : TStccPeer;
begin
  Result := False;

  try
    //--1. Connect STCC.STCCOrders
    FStccOrders := CreateOLEObject('STCC.STCCOrders') as IStccOrders;

    if VarIsEmpty(FStccOrders) or VarIsNull(FStccOrders) then
    begin
      DoLog('StccObject: Couldn''t get the reference for STCCOrders!');
      Exit;
    end else
    begin
      FActiveOrders := FStccOrders.ActiveOrders as IActiveOrders;
      FCanceledOrders := FStccOrders.CanceledOrders as ICanceledOrders;
      FFilledOrders := FStccOrders.FilledOrders as IFilledOrders;
      FOpenPositions := FStccOrders.OpenPositions as IOpenPositions;

      //--1.1 connect ActiveOrders Collection
      aPeer := FPeers.Add as TStccPeer;
      aPeer.OnEvent := DoPeerEvents;
      aPeer.OnLog := DoLog;
      if not aPeer.Connect(FActiveOrders, IActiveEvents) then aPeer.Free;
      //--1.2 connect CanceledOrders Collection
      aPeer := FPeers.Add as TStccPeer;
      aPeer.OnEvent := DoPeerEvents;
      aPeer.OnLog := DoLog;
      if not aPeer.Connect(FCanceledOrders, ICanceledEvents) then aPeer.Free;
      //--1.3 connect FilledOrders Collection
      aPeer := FPeers.Add as TStccPeer;
      aPeer.OnEvent := DoPeerEvents;
      aPeer.OnLog := DoLog;
      if not aPeer.Connect(FFilledOrders, IFilledEvents) then aPeer.Free;
      //--1.4 connect OpenPositions Collection
      aPeer := FPeers.Add as TStccPeer;
      aPeer.OnEvent := DoPeerEvents;
      aPeer.OnLog := DoLog;
      if not aPeer.Connect(FOpenPositions, IOpenEvents) then aPeer.Free;
    end;

    //--2. Connect ATCCAlerts collection
    FAtccAlerts := CreateOLEObject('ATCC.ATCCAlerts') as IAtccAlerts;

    if VarIsEmpty(FAtccAlerts) or VarIsNull(FAtccAlerts) then
    begin
      DoLog('StccObject: Couldn''t get the reference for AtccAlerts!');
      Exit;
    end else
    begin
      aPeer := FPeers.Add as TStccPeer;
      aPeer.OnEvent := DoPeerEvents;
      aPeer.OnLog := DoLog;
      if not aPeer.Connect(FAtccAlerts, IAtccEvents) then aPeer.Free;
    end;

    //--3. Connect ATCCAlerts collection
    FMessageLogMessages := CreateOLEObject('MLog.MessageLogMessages') as IMessageLogMessages;

    if VarIsEmpty(FMessageLogMessages) or VarIsNull(FMessageLogMessages) then
    begin
      DoLog('StccObject: Couldn''t get the reference for MessageLogMessages!');
      Exit;
    end else
    begin
      aPeer := FPeers.Add as TStccPeer;
      aPeer.OnEvent := DoPeerEvents;
      aPeer.OnLog := DoLog;
      if not aPeer.Connect(FMessageLogMessages, IMessageLogEvents) then aPeer.Free;
    end;

    Result := True;
    FConnected := True;
  except
  end;
end;

procedure TStccBroker.DoPeerEvents(Sender : TObject; iDispID : Integer; aObj : IDispatch);
var
  aPeer : TStccPeer;
  aEventProc : TStccBrokerEvent;
begin
  if (Sender = nil) or (not (Sender is TStccPeer)) then Exit;

  aPeer := Sender as TStccPeer;

  case aPeer.Index of
    0 : aEventProc := FOnActiveEvent;
    1 : aEventProc := FOnCanceledEvent;
    2 : aEventProc := FOnFilledEvent;
    3 : aEventProc := FOnOpenEvent;
    4 : aEventProc := FOnAlertEvent;
    5 : aEventProc := FOnMessageLogEvent;
    else
      Exit;
  end;

  case aPeer.Index of
    0 : // ActiveOrders Events
      if Assigned(aEventProc) then
      case iDispID of
        1 : aEventProc(ekAdd, aObj);    // add
        2 : aEventProc(ekModify, aObj); // modify
        3 : aEventProc(ekFill, aObj);   // fill
        4 : aEventProc(ekCancel, aObj); // cancel
        5 : aEventProc(ekRemove, aObj); // remove
        6 : aEventProc(ekReset, nil);   // reset
      end;
    1,  // CanceledOrders Events
    2,  // FilledOrders Events
    3 : // OpenPositions Events
      if Assigned(aEventProc) then
      case iDispID of
        1 : aEventProc(ekAdd, aObj);    // add
        2 : aEventProc(ekModify, aObj); // modify
        3 : aEventProc(ekRemove, aObj); // remove
        4 : aEventProc(ekReset, nil);   // reset
      end;
    4,  // AtccAlerts Events
    5 : // MessageLogMessages Events
      if Assigned(aEventProc) then
      case iDispID of
        1 : aEventProc(ekAdd, aObj);    // add
        2 : aEventProc(ekReset, nil);   // reset
        3 : aEventProc(ekRemove, aObj); // remove
      end;
  end;
end;

//---------------------------< Miscellaneous >------------------------//

procedure TStccBroker.DoLog(stLog : String);
begin
  if Assigned(FOnLog) then
    FOnLog(stLog);
end;



const
  ORDER_NUMBER = '1235';
  CANCEL_NUMBER = '1112';

procedure TStccBroker.AddActiveOrder(stOrder : String);
begin
  if not FConnected then Exit;

  FActiveOrders.Add(
    'Paxnet', // Symbol Name
    'Paxnet Ltd', // Description
    'Long Entry', // Order type
    'Buy at Market', //Order
    158, // last price,
    101, // Base Code e(101) = 1
    Now,
    'Wonder System', // System name
    'Wonder Signal', // Signal name
    'My Workspace', // workspace name
    '60 Minutes', // Interval
    '31', // Position Number
    stOrder, // Order number
    FOwner.Handle, //  Window handle
    1,
    'You have a active order in Paxnet'
  );
end;

procedure TStccBroker.AddCanceledOrder(stOrder, stCancel : String);
begin
  if not FConnected then Exit;

  FCanceledOrders.Add(
    'Paxnet', // Symbol Name
    'Paxnet Ltd', // Description
    'Long Entry', // Order type
    'Buy at Market', //Order
    Now,
    Now,
    'Wonder System', // System name
    'Wonder Signal', // Signal name
    'My Workspace', // workspace name
    '60 Minutes', // Interval
    '31', // Position Number
    stOrder, // Order number
    stCancel, // Canceled number
    FOwner.Handle, // Handle// Window handle
    1,
    'An Order was canceled in Paxnet' // cancel alert
    );
end;

procedure TStccBroker.AddFilledOrder(stOrder : String);
begin
  if not FConnected then Exit;

  FFilledOrders.Add(
    'Paxnet', // Symbol Name
    'Paxnet Ltd', // Description
    'Long Entry', // Order type
    'Buy at Market', //Order
    158, // filled price,
    101, // Base Code e(101) = 1
    10, // Slippage price
    101, // Base Code e(101) = 1
    Now,
    Now,
    'Wonder System', // System name
    'Wonder Signal', // Signal name
    'My Workspace', // workspace name
    '60 Minutes', // Interval
    '31', // Position Number
    stOrder, // Order number
    FOwner.Handle, // Handle// Window handle
    1,
    'An order was filled in Paxnet' // Alert string
  );
end;

procedure TStccBroker.AddOpenPosition(stOrder : String);
begin
  if not FConnected then Exit;

  FOpenPositions.Add(
    'Paxnet', // Symbol Name
    'Paxnet Ltd', // Description
    158, // Entry Price
    101,
    168, // Last Price
    101,
    10, // Profit price
    101, // Base Code e(101) = 1
    Now,
    'Wonder System', // System name
    'Wonder Signal', // Signal name
    'My Workspace', // workspace name
    '60 Minutes', // Interval
    '31', // Position Number
    stOrder, // Order number
    FOwner.Handle, // Handle// Window handle
    1,
    'Position Added in Paxnet'
  );
end;

end.



Dim StccObj As New STCCOrders
Dim WithEvents ActiveObj As ActiveOrders
Dim WithEvents OpenObj As OpenPositions
Dim WithEvents FilledObj As FilledOrders
Dim WithEvents CanceledObj As CanceledOrders

******************************************************
Private Sub UserControl_Initialize()

Set ActiveObj = StccObj.ActiveOrders
Set OpenObj = StccObj.OpenPositions
Set FilledObj = StccObj.FilledOrders
Set CanceledObj = StccObj.CanceledOrders

End Sub
*******************************************************
Private Sub SendOrders_Click()

  Select Case SSTab1.Tab

  Case 0
    AddActiveOrder

 Case 1
  AddOpenPosition

  Case 2
    AddFilledOrder

  Case 3
  AddCanceledOrder

  End Select


End Sub
*******************************************************
Sub AddActiveOrder()

  ActiveObj.Add ASymbolText.Text,
  ADescriptionText.Text,
  AOrderTypeText.Text,
  AOrderText.Text,
  ALastPriceText.Text,
  101, 'Base Code e(101) = 1
  Now,
  ASystemText.Text,
  ASignalText.Text,
  AWorkspaceText.Text,
  AIntervalText.Text,
  APositionNumberText.Text,
  AOrderNumberText.Text,
  hWnd,
  1,
  AAlertStringText.Text

End Sub
***************************************************
Sub AddOpenPosition()

  OpenObj.Add OSymbolText.Text,
  ODescriptionText.Text,
  OEntryPriceText.Text,101,
  OLastPriceText.Text, 101,
  OProfitPriceText.Text,
  101, 'Base Code e(101) = 1
  Now,
  OSystemText.Text,
  OSignalText.Text,
  OWorkspaceText.Text,
  OIntervalText.Text,
  OPositionNumberText.Text,
  OOrderNumberText.Text,
  hWnd,
  1,
  OAlertStringText.Text

End Sub
************************************************
Sub AddFilledOrder()

    FilledObj.Add FSymbolText.Text,
  FDescriptionText.Text,
    FOrderTypeText.Text,
    FOrderText.Text,
    FFilledPriceText.Text,
    101, 'Base Code e(101) = 1
    FSlippagePriceText.Text,
    101, 'Base Code e(101) = 1
    Now,
    Now,
    FSystemText.Text,
    FSignalText.Text,
    FWorkspaceText.Text,
    FIntervalText.Text,
    FPositionNumberText.Text,
    FOrderNumberText.Text,
    hWnd,
    1,
    FAlertStringText.Text

End Sub
*****************************************************
Sub AddCanceledOrder()

    CanceledObj.Add CSymbolText.Text,
  CDescriptionText.Text,
  COrderTypeText.Text,
  COrderText.Text,
  Now,
  Now,
  CSystemText.Text,
  CSignalText.Text,
  CWorkspaceText.Text,
  CIntervalText.Text,
  CPositionNumberText.Text,
  COrderNumberText.Text,
  CCanceledNumberText.Text,
  hWnd,
  1,
  CAlertStringText.Text

End Sub
******************************************************************
Private Sub ActiveObj_Add(ByVal pDisp As Object)
 
  Dim ActOrder As ActiveOrder
  Set ActOrder = pDisp
 
  AEventList.AddItem "ActiveOrder Event -----"
  AEventList.AddItem ActOrder.Symbol
  AEventList.AddItem ActOrder.Description
  AEventList.AddItem ActOrder.System
  AEventList.AddItem ActOrder.Signal
  AEventList.AddItem ActOrder.OrderNumber
 
End Sub
******************************************************************
Private Sub OpenObj_Add(ByVal pDisp As Object)
 
  Dim OpenPos As OpenPosition
  Set OpenPos = pDisp

  OEventList.AddItem "OpenPosition Event -----"
  OEventList.AddItem OpenPos.Symbol
  OEventList.AddItem OpenPos.Description
  OEventList.AddItem OpenPos.System
  OEventList.AddItem OpenPos.Signal
  OEventList.AddItem OpenPos.OrderNumber

End Sub
********************************************************************
Private Sub FilledObj_Add(ByVal pDisp As Object)

  Dim FillOrd As FilledOrder
  Set FillOrd = pDisp

  FEventList.AddItem "FilledOrder Event -----"
  FEventList.AddItem FillOrd.Symbol
  FEventList.AddItem FillOrd.Description
  FEventList.AddItem FillOrd.System
  FEventList.AddItem FillOrd.Signal
  FEventList.AddItem FillOrd.OrderNumber

End Sub
***************************************************************************
Private Sub CanceledObj_Add(ByVal pDisp As Object)

  Dim CanOrd As CanceledOrder
  Set CanOrd = pDisp

  CEventList.AddItem "CancelOrder Event -----"
  CEventList.AddItem CanOrd.Symbol
  CEventList.AddItem CanOrd.Description
  CEventList.AddItem CanOrd.System
  CEventList.AddItem CanOrd.Signal
  CEventList.AddItem CanOrd.OrderNumber

End Sub
*********************
