unit ORTCLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 8291 $
// File generated on 2016-07-20 ¿ÀÈÄ 6:24:44 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files (x86)\Omega Research\Program\Ortc.exe (1)
// LIBID: {67104EC1-03F1-11D3-8E10-00C04F68F811}
// LCID: 0
// Helpfile: 
// HelpString: ORTC 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// Errors:
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
//   Hint: Symbol 'System' renamed to 'System_'
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ORTCLibMajorVersion = 1;
  ORTCLibMinorVersion = 0;

  LIBID_ORTCLib: TGUID = '{67104EC1-03F1-11D3-8E10-00C04F68F811}';

  DIID_IMessageLogEvents: TGUID = '{C51D9DE5-471F-11D1-BC9E-00805F05ADAC}';
  IID_IMessageLogMessage: TGUID = '{C51D9DE4-471F-11D1-BC9E-00805F05ADAC}';
  CLASS_MessageLogMessage: TGUID = '{C51D9DE6-471F-11D1-BC9E-00805F05ADAC}';
  IID_IMessageLogMessages: TGUID = '{C51D9DE2-471F-11D1-BC9E-00805F05ADAC}';
  IID_IMLogEventHelper: TGUID = '{12254BE1-00A6-11D2-BCEF-00805F05ADAC}';
  CLASS_MessageLogMessages: TGUID = '{C51D9DE7-471F-11D1-BC9E-00805F05ADAC}';
  DIID_IATCCEvents: TGUID = '{261859F0-4343-11D1-8280-000000000000}';
  IID_IATCCAlert: TGUID = '{8820F6B3-23C0-11D1-BC95-00805F05ADAC}';
  CLASS_ATCCAlert: TGUID = '{8820F6B4-23C0-11D1-BC95-00805F05ADAC}';
  IID_IATCCAlerts: TGUID = '{E712A120-4564-11D1-9451-00805F05FAB1}';
  IID_IATCCEventHelper: TGUID = '{9E9CA1B1-F570-11D1-BCEC-00805F05ADAC}';
  CLASS_ATCCAlerts: TGUID = '{362FC040-4565-11D1-9451-00805F05FAB1}';
  CLASS_WAATCCAlerts: TGUID = '{4F46CA90-A70F-11D2-B7A7-00C04F7CD214}';
  DIID_IActiveEvents: TGUID = '{91DB55BF-9661-11D1-BCCB-00805F05ADAC}';
  DIID_ICanceledEvents: TGUID = '{91DB55B3-9661-11D1-BCCB-00805F05ADAC}';
  DIID_IFilledEvents: TGUID = '{91DB55B4-9661-11D1-BCCB-00805F05ADAC}';
  DIID_IOpenEvents: TGUID = '{91DB55B5-9661-11D1-BCCB-00805F05ADAC}';
  IID_IActiveOrder: TGUID = '{47D1DFE6-351F-11D1-BC98-00805F05ADAC}';
  CLASS_ActiveOrder: TGUID = '{47D1DFE5-351F-11D1-BC98-00805F05ADAC}';
  IID_IFilledOrder: TGUID = '{47D1DFEC-351F-11D1-BC98-00805F05ADAC}';
  CLASS_FilledOrder: TGUID = '{47D1DFE4-351F-11D1-BC98-00805F05ADAC}';
  IID_ICanceledOrder: TGUID = '{47D1DFED-351F-11D1-BC98-00805F05ADAC}';
  CLASS_CanceledOrder: TGUID = '{47D1DFE3-351F-11D1-BC98-00805F05ADAC}';
  IID_IOpenPosition: TGUID = '{47D1DFF0-351F-11D1-BC98-00805F05ADAC}';
  CLASS_OpenPosition: TGUID = '{47D1DFE1-351F-11D1-BC98-00805F05ADAC}';
  IID_IActiveOrders: TGUID = '{91DB55BA-9661-11D1-BCCB-00805F05ADAC}';
  IID_IAOEventHelper: TGUID = '{804DECF2-0132-11D2-BCEF-00805F05ADAC}';
  CLASS_ActiveOrders: TGUID = '{91DB55B6-9661-11D1-BCCB-00805F05ADAC}';
  CLASS_WAActiveOrders: TGUID = '{23E29330-A9AD-11D2-B7A9-00C04F7CD214}';
  IID_IFilledOrders: TGUID = '{91DB55BC-9661-11D1-BCCB-00805F05ADAC}';
  IID_IFOEventHelper: TGUID = '{804DECF3-0132-11D2-BCEF-00805F05ADAC}';
  CLASS_WAFilledOrders: TGUID = '{23E29332-A9AD-11D2-B7A9-00C04F7CD214}';
  CLASS_FilledOrders: TGUID = '{91DB55B7-9661-11D1-BCCB-00805F05ADAC}';
  IID_ICanceledOrders: TGUID = '{91DB55BB-9661-11D1-BCCB-00805F05ADAC}';
  IID_ICOEventHelper: TGUID = '{804DECF4-0132-11D2-BCEF-00805F05ADAC}';
  CLASS_CanceledOrders: TGUID = '{91DB55B8-9661-11D1-BCCB-00805F05ADAC}';
  CLASS_WACanceledOrders: TGUID = '{23E29331-A9AD-11D2-B7A9-00C04F7CD214}';
  IID_IOpenPositions: TGUID = '{91DB55BD-9661-11D1-BCCB-00805F05ADAC}';
  IID_IOPEventHelper: TGUID = '{804DECF5-0132-11D2-BCEF-00805F05ADAC}';
  CLASS_OpenPositions: TGUID = '{91DB55B9-9661-11D1-BCCB-00805F05ADAC}';
  CLASS_WAOpenPositions: TGUID = '{01208CA1-A97E-11D2-B7A9-00C04F7CD214}';
  IID_ISTCCOrders: TGUID = '{91DB55BE-9661-11D1-BCCB-00805F05ADAC}';
  CLASS_STCCOrders: TGUID = '{47D1DFF3-351F-11D1-BC98-00805F05ADAC}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum tagATCCFIELDSIZE
type
  tagATCCFIELDSIZE = TOleEnum;
const
  ATCC_SYMBOL_SIZE = $00000010;
  ATCC_INTERVAL_SIZE = $00000010;
  ATCC_NAME_SIZE = $00000032;
  ATCC_WORKSPACE_SIZE = $000000FF;
  ATCC_ALERTSTRING_SIZE = $000000FF;

// Constants for enum tagATCCFIELDIDS
type
  tagATCCFIELDIDS = TOleEnum;
const
  ID_ATCC_UNUSED = $00000000;
  ID_ATCC_OCCURED = $0000000A;
  ID_ATCC_SYMBOL = $00000014;
  ID_ATCC_INTERVAL = $0000001E;
  ID_ATCC_NAME = $00000028;
  ID_ATCC_PRICE = $00000032;
  ID_ATCC_WORKSPACE = $0000003C;
  ID_ATCC_ALERTSTRING = $00000046;

// Constants for enum tagATCCALERTTYPE
type
  tagATCCALERTTYPE = TOleEnum;
const
  ORAT_DIALOG = $00000001;
  ORAT_PAGE = $00000002;
  ORAT_TRAYICON = $00000004;
  ORAT_WORKSPACE_ASSISTANT = $00001000;

// Constants for enum tagATCCOPTIONSVALUES
type
  tagATCCOPTIONSVALUES = TOleEnum;
const
  ATCC_NOTIFICATION_DIALOG_OFF = $00000000;
  ATCC_NOTIFICATION_DIALOG_ON = $00000001;
  ATCC_NOTIFICATION_INTRUSIVE = $00000010;
  ATCC_NOTIFICATION_NON_INTRUSIVE = $00000020;
  ATCC_SOUND_NO_SOUND = $00000000;
  ATCC_SOUND_DEFAULT_BEEP = $00000001;
  ATCC_SOUND_SYSTEM_SOUNDS = $00000002;

// Constants for enum tagSTCCOPTIONSVALUES
type
  tagSTCCOPTIONSVALUES = TOleEnum;
const
  STCC_NOTIFICATION_DIALOG_OFF = $00000000;
  STCC_NOTIFICATION_DIALOG_ON = $00000001;
  STCC_NOTIFICATION_INTRUSIVE = $00000010;
  STCC_NOTIFICATION_NON_INTRUSIVE = $00000020;
  STCC_SOUND_NO_SOUND = $00000000;
  STCC_SOUND_DEFAULT_BEEP = $00000001;
  STCC_SOUND_SYSTEM_SOUNDS = $00000002;

// Constants for enum tagSTCCORDERTYPE
type
  tagSTCCORDERTYPE = TOleEnum;
const
  ACTIVE_ORDERS = $00000000;
  FILLED_ORDERS = $00000001;
  CANCELED_ORDERS = $00000002;
  OPEN_ORDERS = $00000003;

// Constants for enum tagSTCCPAGINGERROR
type
  tagSTCCPAGINGERROR = TOleEnum;
const
  PERR_NOTINSTALLED = $00000000;
  PERR_NOTENABLED = $00000001;
  PERR_SUBSCRIBER = $00000002;
  PERR_NOTSEND = $00000003;

// Constants for enum tagSTCCMASK
type
  tagSTCCMASK = TOleEnum;
const
  STCCDF_ORDERNUMBER = $00000001;

// Constants for enum tagSTCCFIELDSIZE
type
  tagSTCCFIELDSIZE = TOleEnum;
const
  SYMBOL_SIZE = $00000010;
  DESCRIPTION_SIZE = $00000032;
  SYSTEM_SIZE = $000000FF;
  SIGNAL_SIZE = $00000014;
  INTERVAL_SIZE = $00000032;
  ORDERTYPE_SIZE = $00000032;
  ORDER_SIZE = $00000032;
  POSITIONNUMBER_SIZE = $00000010;
  ORDERNUMBER_SIZE = $00000010;
  CANCELEDNUMBER_SIZE = $00000010;
  WORKSPACE_SIZE = $000000FF;
  ALERTSTRING_SIZE = $000000FF;
  PRICE_SIZE = $0000001E;

// Constants for enum tagSTCCFIELDIDS
type
  tagSTCCFIELDIDS = TOleEnum;
const
  ID_STCC_SYMBOL = $00000000;
  ID_STCC_DESCRIPTION = $0000000A;
  ID_STCC_ORDERTYPE = $0000000F;
  ID_STCC_ORDER = $00000014;
  ID_STCC_LAST = $0000001E;
  ID_STCC_PROFIT = $00000028;
  ID_STCC_FILLPRICE = $00000032;
  ID_STCC_ENTRYPRICE = $0000003C;
  ID_STCC_SLIPPAGE = $00000046;
  ID_STCC_TIMEPLACED = $00000050;
  ID_STCC_TIMEFILLED = $0000005A;
  ID_STCC_TIMECANCELED = $00000064;
  ID_STCC_SYSTEM = $0000006E;
  ID_STCC_SIGNAL = $00000078;
  ID_STCC_WORKSPACE = $00000082;
  ID_STCC_INTERVAL = $0000008C;
  ID_STCC_POSITIONNUMBER = $00000096;
  ID_STCC_ORDERNUMBER = $000000A5;
  ID_STCC_CANCELEDNUMBER = $000000AA;
  ID_STCC_ALERTSTRING = $000000B4;
  ID_STCC_ENTRYTIME = $000000BE;

// Constants for enum tagSTCCALERTTYPE
type
  tagSTCCALERTTYPE = TOleEnum;
const
  ORST_DIALOG = $00000001;
  ORST_PAGE = $00000002;
  ORST_TRAYICON = $00000004;
  ORST_WORKSPACE_ASSISTANT = $00001000;

// Constants for enum tagMLOGFIELDSIZE
type
  tagMLOGFIELDSIZE = TOleEnum;
const
  MLOG_CONTENT_SIZE = $000000FF;
  MLOG_ANALYSIS_SIZE = $000000FF;

// Constants for enum tagATCCOPTIONS
type
  tagATCCOPTIONS = TOleEnum;
const
  ATCC_NOTIFICATION = $0000000A;
  ATCC_SOUND = $00000014;

// Constants for enum tagSTCCOPTIONS
type
  tagSTCCOPTIONS = TOleEnum;
const
  STCC_NOTIFICATION = $0000000A;
  STCC_SOUND = $00000014;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IMessageLogEvents = dispinterface;
  IMessageLogMessage = interface;
  IMessageLogMessageDisp = dispinterface;
  IMessageLogMessages = interface;
  IMessageLogMessagesDisp = dispinterface;
  IMLogEventHelper = interface;
  IATCCEvents = dispinterface;
  IATCCAlert = interface;
  IATCCAlertDisp = dispinterface;
  IATCCAlerts = interface;
  IATCCAlertsDisp = dispinterface;
  IATCCEventHelper = interface;
  IActiveEvents = dispinterface;
  ICanceledEvents = dispinterface;
  IFilledEvents = dispinterface;
  IOpenEvents = dispinterface;
  IActiveOrder = interface;
  IActiveOrderDisp = dispinterface;
  IFilledOrder = interface;
  IFilledOrderDisp = dispinterface;
  ICanceledOrder = interface;
  ICanceledOrderDisp = dispinterface;
  IOpenPosition = interface;
  IOpenPositionDisp = dispinterface;
  IActiveOrders = interface;
  IActiveOrdersDisp = dispinterface;
  IAOEventHelper = interface;
  IFilledOrders = interface;
  IFilledOrdersDisp = dispinterface;
  IFOEventHelper = interface;
  ICanceledOrders = interface;
  ICanceledOrdersDisp = dispinterface;
  ICOEventHelper = interface;
  IOpenPositions = interface;
  IOpenPositionsDisp = dispinterface;
  IOPEventHelper = interface;
  ISTCCOrders = interface;
  ISTCCOrdersDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  MessageLogMessage = IMessageLogMessage;
  MessageLogMessages = IMessageLogMessages;
  ATCCAlert = IATCCAlert;
  ATCCAlerts = IATCCAlerts;
  WAATCCAlerts = IATCCAlerts;
  ActiveOrder = IActiveOrder;
  FilledOrder = IFilledOrder;
  CanceledOrder = ICanceledOrder;
  OpenPosition = IOpenPosition;
  ActiveOrders = IActiveOrders;
  WAActiveOrders = IActiveOrders;
  WAFilledOrders = IFilledOrders;
  FilledOrders = IFilledOrders;
  CanceledOrders = ICanceledOrders;
  WACanceledOrders = ICanceledOrders;
  OpenPositions = IOpenPositions;
  WAOpenPositions = IOpenPositions;
  STCCOrders = ISTCCOrders;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}


// *********************************************************************//
// DispIntf:  IMessageLogEvents
// Flags:     (4096) Dispatchable
// GUID:      {C51D9DE5-471F-11D1-BC9E-00805F05ADAC}
// *********************************************************************//
  IMessageLogEvents = dispinterface
    ['{C51D9DE5-471F-11D1-BC9E-00805F05ADAC}']
    procedure Add(const pDisp: IDispatch); dispid 1;
    procedure Reset; dispid 2;
    procedure Remove(const pDisp: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IMessageLogMessage
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C51D9DE4-471F-11D1-BC9E-00805F05ADAC}
// *********************************************************************//
  IMessageLogMessage = interface(IDispatch)
    ['{C51D9DE4-471F-11D1-BC9E-00805F05ADAC}']
    function Get_Content: WideString; safecall;
    function Get_Analysis: WideString; safecall;
    function Get_DateTime: TDateTime; safecall;
    function Get_IsValid: Integer; safecall;
    function Get_EntryID: Integer; safecall;
    property Content: WideString read Get_Content;
    property Analysis: WideString read Get_Analysis;
    property DateTime: TDateTime read Get_DateTime;
    property IsValid: Integer read Get_IsValid;
    property EntryID: Integer read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  IMessageLogMessageDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C51D9DE4-471F-11D1-BC9E-00805F05ADAC}
// *********************************************************************//
  IMessageLogMessageDisp = dispinterface
    ['{C51D9DE4-471F-11D1-BC9E-00805F05ADAC}']
    property Content: WideString readonly dispid 1;
    property Analysis: WideString readonly dispid 2;
    property DateTime: TDateTime readonly dispid 7;
    property IsValid: Integer readonly dispid 4;
    property EntryID: Integer readonly dispid 5;
  end;

// *********************************************************************//
// Interface: IMessageLogMessages
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C51D9DE2-471F-11D1-BC9E-00805F05ADAC}
// *********************************************************************//
  IMessageLogMessages = interface(IDispatch)
    ['{C51D9DE2-471F-11D1-BC9E-00805F05ADAC}']
    function Item(index: Integer): IDispatch; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Add(Occured: TDateTime; const Content: WideString; const Analysis: WideString): IDispatch; safecall;
    procedure Reset; safecall;
    procedure GetBufferSize(var pVal: Integer); safecall;
    procedure ChangeBufferSize(pVal: Integer); safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IMessageLogMessagesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C51D9DE2-471F-11D1-BC9E-00805F05ADAC}
// *********************************************************************//
  IMessageLogMessagesDisp = dispinterface
    ['{C51D9DE2-471F-11D1-BC9E-00805F05ADAC}']
    function Item(index: Integer): IDispatch; dispid 0;
    property _NewEnum: IUnknown readonly dispid -4;
    property Parent: IDispatch readonly dispid 10;
    property Count: Integer readonly dispid 20;
    function Add(Occured: TDateTime; const Content: WideString; const Analysis: WideString): IDispatch; dispid 30;
    procedure Reset; dispid 50;
    procedure GetBufferSize(var pVal: Integer); dispid 60;
    procedure ChangeBufferSize(pVal: Integer); dispid 70;
  end;

// *********************************************************************//
// Interface: IMLogEventHelper
// Flags:     (256) OleAutomation
// GUID:      {12254BE1-00A6-11D2-BCEF-00805F05ADAC}
// *********************************************************************//
  IMLogEventHelper = interface(IUnknown)
    ['{12254BE1-00A6-11D2-BCEF-00805F05ADAC}']
    function FireAddHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireResetHelper: HResult; stdcall;
    function FireRemoveHelper(const pDisp: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  IATCCEvents
// Flags:     (4096) Dispatchable
// GUID:      {261859F0-4343-11D1-8280-000000000000}
// *********************************************************************//
  IATCCEvents = dispinterface
    ['{261859F0-4343-11D1-8280-000000000000}']
    procedure Add(const pDisp: IDispatch); dispid 1;
    procedure Reset; dispid 2;
    procedure Remove(const pDisp: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IATCCAlert
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8820F6B3-23C0-11D1-BC95-00805F05ADAC}
// *********************************************************************//
  IATCCAlert = interface(IDispatch)
    ['{8820F6B3-23C0-11D1-BC95-00805F05ADAC}']
    function Get_Parent: IDispatch; safecall;
    function Get_Symbol: WideString; safecall;
    function Get_Interval: WideString; safecall;
    function Get_WorkSpace: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_Pieces: Integer; safecall;
    function Get_Code: Byte; safecall;
    function Get_DateTime: TDateTime; safecall;
    function Get_AlertString: WideString; safecall;
    function Get_WindowID: Integer; safecall;
    function Get_IsValid: Integer; safecall;
    function Get_EntryID: Integer; safecall;
    property Parent: IDispatch read Get_Parent;
    property Symbol: WideString read Get_Symbol;
    property Interval: WideString read Get_Interval;
    property WorkSpace: WideString read Get_WorkSpace;
    property Name: WideString read Get_Name;
    property Pieces: Integer read Get_Pieces;
    property Code: Byte read Get_Code;
    property DateTime: TDateTime read Get_DateTime;
    property AlertString: WideString read Get_AlertString;
    property WindowID: Integer read Get_WindowID;
    property IsValid: Integer read Get_IsValid;
    property EntryID: Integer read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  IATCCAlertDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8820F6B3-23C0-11D1-BC95-00805F05ADAC}
// *********************************************************************//
  IATCCAlertDisp = dispinterface
    ['{8820F6B3-23C0-11D1-BC95-00805F05ADAC}']
    property Parent: IDispatch readonly dispid 100;
    property Symbol: WideString readonly dispid 101;
    property Interval: WideString readonly dispid 102;
    property WorkSpace: WideString readonly dispid 103;
    property Name: WideString readonly dispid 104;
    property Pieces: Integer readonly dispid 105;
    property Code: Byte readonly dispid 106;
    property DateTime: TDateTime readonly dispid 107;
    property AlertString: WideString readonly dispid 108;
    property WindowID: Integer readonly dispid 109;
    property IsValid: Integer readonly dispid 110;
    property EntryID: Integer readonly dispid 120;
  end;

// *********************************************************************//
// Interface: IATCCAlerts
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E712A120-4564-11D1-9451-00805F05FAB1}
// *********************************************************************//
  IATCCAlerts = interface(IDispatch)
    ['{E712A120-4564-11D1-9451-00805F05FAB1}']
    function Item(index: Integer): IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Add(Occured: TDateTime; const Symbol: WideString; const Interval: WideString; 
                 const Name: WideString; Pieces: Integer; Piececode: Byte; 
                 const WorkSpace: WideString; const AlertString: WideString; WindowID: Integer; 
                 AlertType: Integer): IDispatch; safecall;
    procedure Reset; safecall;
    procedure GetBufferSize(var pVal: Integer); safecall;
    procedure ChangeBufferSize(pVal: Integer); safecall;
    procedure DumpToPager(const PageString: WideString); safecall;
    procedure DumpContentToPager; safecall;
    procedure SetOption(Option: tagATCCOPTIONS; Value: OleVariant); safecall;
    function GetOption(Option: tagATCCOPTIONS): OleVariant; safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IATCCAlertsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E712A120-4564-11D1-9451-00805F05FAB1}
// *********************************************************************//
  IATCCAlertsDisp = dispinterface
    ['{E712A120-4564-11D1-9451-00805F05FAB1}']
    function Item(index: Integer): IDispatch; dispid 0;
    property Parent: IDispatch readonly dispid 10;
    property Count: Integer readonly dispid 20;
    property _NewEnum: IUnknown readonly dispid -4;
    function Add(Occured: TDateTime; const Symbol: WideString; const Interval: WideString; 
                 const Name: WideString; Pieces: Integer; Piececode: Byte; 
                 const WorkSpace: WideString; const AlertString: WideString; WindowID: Integer; 
                 AlertType: Integer): IDispatch; dispid 30;
    procedure Reset; dispid 50;
    procedure GetBufferSize(var pVal: Integer); dispid 60;
    procedure ChangeBufferSize(pVal: Integer); dispid 70;
    procedure DumpToPager(const PageString: WideString); dispid 80;
    procedure DumpContentToPager; dispid 90;
    procedure SetOption(Option: tagATCCOPTIONS; Value: OleVariant); dispid 100;
    function GetOption(Option: tagATCCOPTIONS): OleVariant; dispid 110;
  end;

// *********************************************************************//
// Interface: IATCCEventHelper
// Flags:     (256) OleAutomation
// GUID:      {9E9CA1B1-F570-11D1-BCEC-00805F05ADAC}
// *********************************************************************//
  IATCCEventHelper = interface(IUnknown)
    ['{9E9CA1B1-F570-11D1-BCEC-00805F05ADAC}']
    function FireAddHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireResetHelper: HResult; stdcall;
    function FireRemoveHelper(const pDisp: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  IActiveEvents
// Flags:     (4096) Dispatchable
// GUID:      {91DB55BF-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IActiveEvents = dispinterface
    ['{91DB55BF-9661-11D1-BCCB-00805F05ADAC}']
    procedure Add(const pDisp: IDispatch); dispid 1;
    procedure Modify(const pDisp: IDispatch); dispid 2;
    procedure Fill(const pDisp: IDispatch); dispid 3;
    procedure Cancel(const pDisp: IDispatch); dispid 4;
    procedure Remove(const pDisp: IDispatch); dispid 5;
    procedure Reset; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  ICanceledEvents
// Flags:     (4096) Dispatchable
// GUID:      {91DB55B3-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  ICanceledEvents = dispinterface
    ['{91DB55B3-9661-11D1-BCCB-00805F05ADAC}']
    procedure Add(const pDisp: IDispatch); dispid 1;
    procedure Modify(const pDisp: IDispatch); dispid 2;
    procedure Remove(const pDisp: IDispatch); dispid 3;
    procedure Reset; dispid 4;
  end;

// *********************************************************************//
// DispIntf:  IFilledEvents
// Flags:     (4096) Dispatchable
// GUID:      {91DB55B4-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IFilledEvents = dispinterface
    ['{91DB55B4-9661-11D1-BCCB-00805F05ADAC}']
    procedure Add(const pDisp: IDispatch); dispid 1;
    procedure Modify(const pDisp: IDispatch); dispid 2;
    procedure Remove(const pDisp: IDispatch); dispid 3;
    procedure Reset; dispid 4;
  end;

// *********************************************************************//
// DispIntf:  IOpenEvents
// Flags:     (4096) Dispatchable
// GUID:      {91DB55B5-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IOpenEvents = dispinterface
    ['{91DB55B5-9661-11D1-BCCB-00805F05ADAC}']
    procedure Add(const pDisp: IDispatch); dispid 1;
    procedure Modify(const pDisp: IDispatch); dispid 2;
    procedure Remove(const pDisp: IDispatch); dispid 3;
    procedure Reset; dispid 4;
  end;

// *********************************************************************//
// Interface: IActiveOrder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFE6-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  IActiveOrder = interface(IDispatch)
    ['{47D1DFE6-351F-11D1-BC98-00805F05ADAC}']
    function Get_Parent: IDispatch; safecall;
    function Get_Symbol: WideString; safecall;
    procedure Set_Symbol(const pVal: WideString); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const pVal: WideString); safecall;
    function Get_OrderType: WideString; safecall;
    procedure Set_OrderType(const pVal: WideString); safecall;
    function Get_Order: WideString; safecall;
    procedure Set_Order(const pVal: WideString); safecall;
    function Get_LastPrice: Integer; safecall;
    procedure Set_LastPrice(pVal: Integer); safecall;
    function Get_LastBaseCode: Byte; safecall;
    procedure Set_LastBaseCode(pVal: Byte); safecall;
    function Get_TimePlaced: TDateTime; safecall;
    procedure Set_TimePlaced(pVal: TDateTime); safecall;
    function Get_System_: WideString; safecall;
    procedure Set_System_(const pVal: WideString); safecall;
    function Get_Signal: WideString; safecall;
    procedure Set_Signal(const pVal: WideString); safecall;
    function Get_WorkSpace: WideString; safecall;
    procedure Set_WorkSpace(const pVal: WideString); safecall;
    function Get_Interval: WideString; safecall;
    procedure Set_Interval(const pVal: WideString); safecall;
    function Get_PositionNumber: WideString; safecall;
    procedure Set_PositionNumber(const pVal: WideString); safecall;
    function Get_OrderNumber: WideString; safecall;
    procedure Set_OrderNumber(const pVal: WideString); safecall;
    function Get_AlertString: WideString; safecall;
    procedure Set_AlertString(const pVal: WideString); safecall;
    function Get_WindowID: Integer; safecall;
    procedure Set_WindowID(pVal: Integer); safecall;
    function Fill(FillPrice: Integer; FillBaseCode: Byte; SlippagePrice: Integer; 
                  SlippageBaseCode: Byte; Filled: TDateTime; nFlags: Integer; 
                  const AlertString: WideString): IDispatch; safecall;
    function Cancel(Canceled: TDateTime; const CanceledNumber: WideString; nFlags: Integer; 
                    const AlertString: WideString): IDispatch; safecall;
    function Modify(Symbol: OleVariant; Description: OleVariant; OrderType: OleVariant; 
                    Order: OleVariant; LastPrice: OleVariant; LastBaseCode: OleVariant; 
                    TimePlaced: OleVariant; System: OleVariant; Signal: OleVariant; 
                    WorkSpace: OleVariant; Interval: OleVariant; PositionNumber: OleVariant; 
                    OrderNumber: OleVariant; WindowID: OleVariant; nFlags: OleVariant; 
                    AlertString: OleVariant): IDispatch; safecall;
    function Get_EntryID: Integer; safecall;
    property Parent: IDispatch read Get_Parent;
    property Symbol: WideString read Get_Symbol write Set_Symbol;
    property Description: WideString read Get_Description write Set_Description;
    property OrderType: WideString read Get_OrderType write Set_OrderType;
    property Order: WideString read Get_Order write Set_Order;
    property LastPrice: Integer read Get_LastPrice write Set_LastPrice;
    property LastBaseCode: Byte read Get_LastBaseCode write Set_LastBaseCode;
    property TimePlaced: TDateTime read Get_TimePlaced write Set_TimePlaced;
    property System_: WideString read Get_System_ write Set_System_;
    property Signal: WideString read Get_Signal write Set_Signal;
    property WorkSpace: WideString read Get_WorkSpace write Set_WorkSpace;
    property Interval: WideString read Get_Interval write Set_Interval;
    property PositionNumber: WideString read Get_PositionNumber write Set_PositionNumber;
    property OrderNumber: WideString read Get_OrderNumber write Set_OrderNumber;
    property AlertString: WideString read Get_AlertString write Set_AlertString;
    property WindowID: Integer read Get_WindowID write Set_WindowID;
    property EntryID: Integer read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  IActiveOrderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFE6-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  IActiveOrderDisp = dispinterface
    ['{47D1DFE6-351F-11D1-BC98-00805F05ADAC}']
    property Parent: IDispatch readonly dispid 1;
    property Symbol: WideString dispid 2;
    property Description: WideString dispid 3;
    property OrderType: WideString dispid 4;
    property Order: WideString dispid 5;
    property LastPrice: Integer dispid 6;
    property LastBaseCode: Byte dispid 7;
    property TimePlaced: TDateTime dispid 10;
    property System_: WideString dispid 11;
    property Signal: WideString dispid 12;
    property WorkSpace: WideString dispid 13;
    property Interval: WideString dispid 14;
    property PositionNumber: WideString dispid 15;
    property OrderNumber: WideString dispid 16;
    property AlertString: WideString dispid 17;
    property WindowID: Integer dispid 18;
    function Fill(FillPrice: Integer; FillBaseCode: Byte; SlippagePrice: Integer; 
                  SlippageBaseCode: Byte; Filled: TDateTime; nFlags: Integer; 
                  const AlertString: WideString): IDispatch; dispid 19;
    function Cancel(Canceled: TDateTime; const CanceledNumber: WideString; nFlags: Integer; 
                    const AlertString: WideString): IDispatch; dispid 20;
    function Modify(Symbol: OleVariant; Description: OleVariant; OrderType: OleVariant; 
                    Order: OleVariant; LastPrice: OleVariant; LastBaseCode: OleVariant; 
                    TimePlaced: OleVariant; System: OleVariant; Signal: OleVariant; 
                    WorkSpace: OleVariant; Interval: OleVariant; PositionNumber: OleVariant; 
                    OrderNumber: OleVariant; WindowID: OleVariant; nFlags: OleVariant; 
                    AlertString: OleVariant): IDispatch; dispid 21;
    property EntryID: Integer readonly dispid 22;
  end;

// *********************************************************************//
// Interface: IFilledOrder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFEC-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  IFilledOrder = interface(IDispatch)
    ['{47D1DFEC-351F-11D1-BC98-00805F05ADAC}']
    function Get_Parent: IDispatch; safecall;
    function Get_Symbol: WideString; safecall;
    procedure Set_Symbol(const pVal: WideString); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const pVal: WideString); safecall;
    function Get_OrderType: WideString; safecall;
    procedure Set_OrderType(const pVal: WideString); safecall;
    function Get_Order: WideString; safecall;
    procedure Set_Order(const pVal: WideString); safecall;
    function Get_FillPrice: Integer; safecall;
    procedure Set_FillPrice(pVal: Integer); safecall;
    function Get_FillBaseCode: Byte; safecall;
    procedure Set_FillBaseCode(pVal: Byte); safecall;
    function Get_SlippagePrice: Integer; safecall;
    procedure Set_SlippagePrice(pVal: Integer); safecall;
    function Get_SlippageBaseCode: Byte; safecall;
    procedure Set_SlippageBaseCode(pVal: Byte); safecall;
    function Get_TimePlaced: TDateTime; safecall;
    procedure Set_TimePlaced(pVal: TDateTime); safecall;
    function Get_TimeFilled: TDateTime; safecall;
    procedure Set_TimeFilled(pVal: TDateTime); safecall;
    function Get_System_: WideString; safecall;
    procedure Set_System_(const pVal: WideString); safecall;
    function Get_Signal: WideString; safecall;
    procedure Set_Signal(const pVal: WideString); safecall;
    function Get_WorkSpace: WideString; safecall;
    procedure Set_WorkSpace(const pVal: WideString); safecall;
    function Get_Interval: WideString; safecall;
    procedure Set_Interval(const pVal: WideString); safecall;
    function Get_PositionNumber: WideString; safecall;
    procedure Set_PositionNumber(const pVal: WideString); safecall;
    function Get_OrderNumber: WideString; safecall;
    procedure Set_OrderNumber(const pVal: WideString); safecall;
    function Get_AlertString: WideString; safecall;
    procedure Set_AlertString(const pVal: WideString); safecall;
    function Get_WindowID: Integer; safecall;
    procedure Set_WindowID(pVal: Integer); safecall;
    function Modify(Symbol: OleVariant; Description: OleVariant; OrderType: OleVariant; 
                    Order: OleVariant; FillPrice: OleVariant; FillBaseCode: OleVariant; 
                    ProfitPrice: OleVariant; ProfitBaseCode: OleVariant; TimePlaced: OleVariant; 
                    TimeFilled: OleVariant; System: OleVariant; Signal: OleVariant; 
                    WorkSpace: OleVariant; Interval: OleVariant; PositionNumber: OleVariant; 
                    OrderNumber: OleVariant; WindowID: OleVariant; nFlags: OleVariant; 
                    AlertString: OleVariant): IDispatch; safecall;
    function Get_EntryID: Integer; safecall;
    property Parent: IDispatch read Get_Parent;
    property Symbol: WideString read Get_Symbol write Set_Symbol;
    property Description: WideString read Get_Description write Set_Description;
    property OrderType: WideString read Get_OrderType write Set_OrderType;
    property Order: WideString read Get_Order write Set_Order;
    property FillPrice: Integer read Get_FillPrice write Set_FillPrice;
    property FillBaseCode: Byte read Get_FillBaseCode write Set_FillBaseCode;
    property SlippagePrice: Integer read Get_SlippagePrice write Set_SlippagePrice;
    property SlippageBaseCode: Byte read Get_SlippageBaseCode write Set_SlippageBaseCode;
    property TimePlaced: TDateTime read Get_TimePlaced write Set_TimePlaced;
    property TimeFilled: TDateTime read Get_TimeFilled write Set_TimeFilled;
    property System_: WideString read Get_System_ write Set_System_;
    property Signal: WideString read Get_Signal write Set_Signal;
    property WorkSpace: WideString read Get_WorkSpace write Set_WorkSpace;
    property Interval: WideString read Get_Interval write Set_Interval;
    property PositionNumber: WideString read Get_PositionNumber write Set_PositionNumber;
    property OrderNumber: WideString read Get_OrderNumber write Set_OrderNumber;
    property AlertString: WideString read Get_AlertString write Set_AlertString;
    property WindowID: Integer read Get_WindowID write Set_WindowID;
    property EntryID: Integer read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  IFilledOrderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFEC-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  IFilledOrderDisp = dispinterface
    ['{47D1DFEC-351F-11D1-BC98-00805F05ADAC}']
    property Parent: IDispatch readonly dispid 1;
    property Symbol: WideString dispid 2;
    property Description: WideString dispid 3;
    property OrderType: WideString dispid 4;
    property Order: WideString dispid 5;
    property FillPrice: Integer dispid 6;
    property FillBaseCode: Byte dispid 7;
    property SlippagePrice: Integer dispid 8;
    property SlippageBaseCode: Byte dispid 9;
    property TimePlaced: TDateTime dispid 10;
    property TimeFilled: TDateTime dispid 11;
    property System_: WideString dispid 12;
    property Signal: WideString dispid 13;
    property WorkSpace: WideString dispid 14;
    property Interval: WideString dispid 15;
    property PositionNumber: WideString dispid 16;
    property OrderNumber: WideString dispid 17;
    property AlertString: WideString dispid 18;
    property WindowID: Integer dispid 19;
    function Modify(Symbol: OleVariant; Description: OleVariant; OrderType: OleVariant; 
                    Order: OleVariant; FillPrice: OleVariant; FillBaseCode: OleVariant; 
                    ProfitPrice: OleVariant; ProfitBaseCode: OleVariant; TimePlaced: OleVariant; 
                    TimeFilled: OleVariant; System: OleVariant; Signal: OleVariant; 
                    WorkSpace: OleVariant; Interval: OleVariant; PositionNumber: OleVariant; 
                    OrderNumber: OleVariant; WindowID: OleVariant; nFlags: OleVariant; 
                    AlertString: OleVariant): IDispatch; dispid 20;
    property EntryID: Integer readonly dispid 21;
  end;

// *********************************************************************//
// Interface: ICanceledOrder
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFED-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  ICanceledOrder = interface(IDispatch)
    ['{47D1DFED-351F-11D1-BC98-00805F05ADAC}']
    function Get_Parent: IDispatch; safecall;
    function Get_Symbol: WideString; safecall;
    procedure Set_Symbol(const pVal: WideString); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const pVal: WideString); safecall;
    function Get_OrderType: WideString; safecall;
    procedure Set_OrderType(const pVal: WideString); safecall;
    function Get_Order: WideString; safecall;
    procedure Set_Order(const pVal: WideString); safecall;
    function Get_TimePlaced: TDateTime; safecall;
    procedure Set_TimePlaced(pVal: TDateTime); safecall;
    function Get_TimeCanceled: TDateTime; safecall;
    procedure Set_TimeCanceled(pVal: TDateTime); safecall;
    function Get_System_: WideString; safecall;
    procedure Set_System_(const pVal: WideString); safecall;
    function Get_Signal: WideString; safecall;
    procedure Set_Signal(const pVal: WideString); safecall;
    function Get_WorkSpace: WideString; safecall;
    procedure Set_WorkSpace(const pVal: WideString); safecall;
    function Get_Interval: WideString; safecall;
    procedure Set_Interval(const pVal: WideString); safecall;
    function Get_PositionNumber: WideString; safecall;
    procedure Set_PositionNumber(const pVal: WideString); safecall;
    function Get_OrderNumber: WideString; safecall;
    procedure Set_OrderNumber(const pVal: WideString); safecall;
    function Get_CanceledNumber: WideString; safecall;
    procedure Set_CanceledNumber(const pVal: WideString); safecall;
    function Get_AlertString: WideString; safecall;
    procedure Set_AlertString(const pVal: WideString); safecall;
    function Get_WindowID: Integer; safecall;
    procedure Set_WindowID(pVal: Integer); safecall;
    function Modify(Symbol: OleVariant; Description: OleVariant; OrderType: OleVariant; 
                    Order: OleVariant; TimePlaced: OleVariant; TimeCanceled: OleVariant; 
                    System: OleVariant; Signal: OleVariant; WorkSpace: OleVariant; 
                    Interval: OleVariant; PositionNumber: OleVariant; OrderNumber: OleVariant; 
                    CanceledNumber: OleVariant; WindowID: OleVariant; nFlags: OleVariant; 
                    AlertString: OleVariant): IDispatch; safecall;
    function Get_EntryID: Integer; safecall;
    property Parent: IDispatch read Get_Parent;
    property Symbol: WideString read Get_Symbol write Set_Symbol;
    property Description: WideString read Get_Description write Set_Description;
    property OrderType: WideString read Get_OrderType write Set_OrderType;
    property Order: WideString read Get_Order write Set_Order;
    property TimePlaced: TDateTime read Get_TimePlaced write Set_TimePlaced;
    property TimeCanceled: TDateTime read Get_TimeCanceled write Set_TimeCanceled;
    property System_: WideString read Get_System_ write Set_System_;
    property Signal: WideString read Get_Signal write Set_Signal;
    property WorkSpace: WideString read Get_WorkSpace write Set_WorkSpace;
    property Interval: WideString read Get_Interval write Set_Interval;
    property PositionNumber: WideString read Get_PositionNumber write Set_PositionNumber;
    property OrderNumber: WideString read Get_OrderNumber write Set_OrderNumber;
    property CanceledNumber: WideString read Get_CanceledNumber write Set_CanceledNumber;
    property AlertString: WideString read Get_AlertString write Set_AlertString;
    property WindowID: Integer read Get_WindowID write Set_WindowID;
    property EntryID: Integer read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  ICanceledOrderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFED-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  ICanceledOrderDisp = dispinterface
    ['{47D1DFED-351F-11D1-BC98-00805F05ADAC}']
    property Parent: IDispatch readonly dispid 1;
    property Symbol: WideString dispid 2;
    property Description: WideString dispid 3;
    property OrderType: WideString dispid 4;
    property Order: WideString dispid 5;
    property TimePlaced: TDateTime dispid 6;
    property TimeCanceled: TDateTime dispid 7;
    property System_: WideString dispid 8;
    property Signal: WideString dispid 9;
    property WorkSpace: WideString dispid 10;
    property Interval: WideString dispid 11;
    property PositionNumber: WideString dispid 12;
    property OrderNumber: WideString dispid 13;
    property CanceledNumber: WideString dispid 14;
    property AlertString: WideString dispid 15;
    property WindowID: Integer dispid 16;
    function Modify(Symbol: OleVariant; Description: OleVariant; OrderType: OleVariant; 
                    Order: OleVariant; TimePlaced: OleVariant; TimeCanceled: OleVariant; 
                    System: OleVariant; Signal: OleVariant; WorkSpace: OleVariant; 
                    Interval: OleVariant; PositionNumber: OleVariant; OrderNumber: OleVariant; 
                    CanceledNumber: OleVariant; WindowID: OleVariant; nFlags: OleVariant; 
                    AlertString: OleVariant): IDispatch; dispid 17;
    property EntryID: Integer readonly dispid 18;
  end;

// *********************************************************************//
// Interface: IOpenPosition
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFF0-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  IOpenPosition = interface(IDispatch)
    ['{47D1DFF0-351F-11D1-BC98-00805F05ADAC}']
    function Get_Parent: IDispatch; safecall;
    function Get_Symbol: WideString; safecall;
    procedure Set_Symbol(const pVal: WideString); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const pVal: WideString); safecall;
    function Get_EntryPrice: Integer; safecall;
    procedure Set_EntryPrice(pVal: Integer); safecall;
    function Get_EntryBaseCode: Byte; safecall;
    procedure Set_EntryBaseCode(pVal: Byte); safecall;
    function Get_LastPrice: Integer; safecall;
    procedure Set_LastPrice(pVal: Integer); safecall;
    function Get_LastBaseCode: Byte; safecall;
    procedure Set_LastBaseCode(pVal: Byte); safecall;
    function Get_ProfitPrice: Integer; safecall;
    procedure Set_ProfitPrice(pVal: Integer); safecall;
    function Get_ProfitBaseCode: Byte; safecall;
    procedure Set_ProfitBaseCode(pVal: Byte); safecall;
    function Get_EntryTime: TDateTime; safecall;
    procedure Set_EntryTime(pVal: TDateTime); safecall;
    function Get_System_: WideString; safecall;
    procedure Set_System_(const pVal: WideString); safecall;
    function Get_Signal: WideString; safecall;
    procedure Set_Signal(const pVal: WideString); safecall;
    function Get_WorkSpace: WideString; safecall;
    procedure Set_WorkSpace(const pVal: WideString); safecall;
    function Get_Interval: WideString; safecall;
    procedure Set_Interval(const pVal: WideString); safecall;
    function Get_PositionNumber: WideString; safecall;
    procedure Set_PositionNumber(const pVal: WideString); safecall;
    function Get_OrderNumber: WideString; safecall;
    procedure Set_OrderNumber(const pVal: WideString); safecall;
    function Get_AlertString: WideString; safecall;
    procedure Set_AlertString(const pVal: WideString); safecall;
    function Get_WindowID: Integer; safecall;
    procedure Set_WindowID(pVal: Integer); safecall;
    function Modify(Symbol: OleVariant; Description: OleVariant; EntryPrice: OleVariant; 
                    EntryBaseCode: OleVariant; LastPrice: OleVariant; LastBaseCode: OleVariant; 
                    ProfitPrice: OleVariant; ProfitBaseCode: OleVariant; EntryTime: OleVariant; 
                    System: OleVariant; Signal: OleVariant; WorkSpace: OleVariant; 
                    Interval: OleVariant; PositionNumber: OleVariant; OrderNumber: OleVariant; 
                    WindowID: OleVariant; nFlags: OleVariant; AlertString: OleVariant): IDispatch; safecall;
    function Get_EntryID: Integer; safecall;
    property Parent: IDispatch read Get_Parent;
    property Symbol: WideString read Get_Symbol write Set_Symbol;
    property Description: WideString read Get_Description write Set_Description;
    property EntryPrice: Integer read Get_EntryPrice write Set_EntryPrice;
    property EntryBaseCode: Byte read Get_EntryBaseCode write Set_EntryBaseCode;
    property LastPrice: Integer read Get_LastPrice write Set_LastPrice;
    property LastBaseCode: Byte read Get_LastBaseCode write Set_LastBaseCode;
    property ProfitPrice: Integer read Get_ProfitPrice write Set_ProfitPrice;
    property ProfitBaseCode: Byte read Get_ProfitBaseCode write Set_ProfitBaseCode;
    property EntryTime: TDateTime read Get_EntryTime write Set_EntryTime;
    property System_: WideString read Get_System_ write Set_System_;
    property Signal: WideString read Get_Signal write Set_Signal;
    property WorkSpace: WideString read Get_WorkSpace write Set_WorkSpace;
    property Interval: WideString read Get_Interval write Set_Interval;
    property PositionNumber: WideString read Get_PositionNumber write Set_PositionNumber;
    property OrderNumber: WideString read Get_OrderNumber write Set_OrderNumber;
    property AlertString: WideString read Get_AlertString write Set_AlertString;
    property WindowID: Integer read Get_WindowID write Set_WindowID;
    property EntryID: Integer read Get_EntryID;
  end;

// *********************************************************************//
// DispIntf:  IOpenPositionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {47D1DFF0-351F-11D1-BC98-00805F05ADAC}
// *********************************************************************//
  IOpenPositionDisp = dispinterface
    ['{47D1DFF0-351F-11D1-BC98-00805F05ADAC}']
    property Parent: IDispatch readonly dispid 1;
    property Symbol: WideString dispid 2;
    property Description: WideString dispid 3;
    property EntryPrice: Integer dispid 4;
    property EntryBaseCode: Byte dispid 5;
    property LastPrice: Integer dispid 6;
    property LastBaseCode: Byte dispid 7;
    property ProfitPrice: Integer dispid 8;
    property ProfitBaseCode: Byte dispid 9;
    property EntryTime: TDateTime dispid 10;
    property System_: WideString dispid 11;
    property Signal: WideString dispid 12;
    property WorkSpace: WideString dispid 13;
    property Interval: WideString dispid 14;
    property PositionNumber: WideString dispid 15;
    property OrderNumber: WideString dispid 16;
    property AlertString: WideString dispid 17;
    property WindowID: Integer dispid 18;
    function Modify(Symbol: OleVariant; Description: OleVariant; EntryPrice: OleVariant; 
                    EntryBaseCode: OleVariant; LastPrice: OleVariant; LastBaseCode: OleVariant; 
                    ProfitPrice: OleVariant; ProfitBaseCode: OleVariant; EntryTime: OleVariant; 
                    System: OleVariant; Signal: OleVariant; WorkSpace: OleVariant; 
                    Interval: OleVariant; PositionNumber: OleVariant; OrderNumber: OleVariant; 
                    WindowID: OleVariant; nFlags: OleVariant; AlertString: OleVariant): IDispatch; dispid 19;
    property EntryID: Integer readonly dispid 20;
  end;

// *********************************************************************//
// Interface: IActiveOrders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BA-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IActiveOrders = interface(IDispatch)
    ['{91DB55BA-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; 
                 const OrderType: WideString; const Order: WideString; LastPrice: Integer; 
                 LastBaseCode: Byte; TimePlaced: TDateTime; const System: WideString; 
                 const Signal: WideString; const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 WindowID: Integer; nFlags: Integer; const AlertString: WideString): IDispatch; safecall;
    function Fill(Item: OleVariant; FillPrice: Integer; FillBaseCode: Byte; SlippagePrice: Integer; 
                  SlippageBaseCode: Byte; Filled: TDateTime; nFlags: Integer; 
                  const AlertString: WideString): IDispatch; safecall;
    function Cancel(Item: OleVariant; Canceled: TDateTime; const CanceledNumber: WideString; 
                    nFlags: Integer; const AlertString: WideString): IDispatch; safecall;
    procedure Reset; safecall;
    function Item(index: Integer): IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Remove(Item: OleVariant); safecall;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); safecall;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IActiveOrdersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BA-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IActiveOrdersDisp = dispinterface
    ['{91DB55BA-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; 
                 const OrderType: WideString; const Order: WideString; LastPrice: Integer; 
                 LastBaseCode: Byte; TimePlaced: TDateTime; const System: WideString; 
                 const Signal: WideString; const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 WindowID: Integer; nFlags: Integer; const AlertString: WideString): IDispatch; dispid 1;
    function Fill(Item: OleVariant; FillPrice: Integer; FillBaseCode: Byte; SlippagePrice: Integer; 
                  SlippageBaseCode: Byte; Filled: TDateTime; nFlags: Integer; 
                  const AlertString: WideString): IDispatch; dispid 2;
    function Cancel(Item: OleVariant; Canceled: TDateTime; const CanceledNumber: WideString; 
                    nFlags: Integer; const AlertString: WideString): IDispatch; dispid 3;
    procedure Reset; dispid 4;
    function Item(index: Integer): IDispatch; dispid 5;
    property Parent: IDispatch readonly dispid 6;
    property Count: Integer readonly dispid 7;
    property _NewEnum: IUnknown readonly dispid 8;
    procedure Remove(Item: OleVariant); dispid 9;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); dispid 10;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; dispid 11;
  end;

// *********************************************************************//
// Interface: IAOEventHelper
// Flags:     (256) OleAutomation
// GUID:      {804DECF2-0132-11D2-BCEF-00805F05ADAC}
// *********************************************************************//
  IAOEventHelper = interface(IUnknown)
    ['{804DECF2-0132-11D2-BCEF-00805F05ADAC}']
    function FireAddHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireResetHelper: HResult; stdcall;
    function FireRemoveHelper(const pDisp: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IFilledOrders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BC-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IFilledOrders = interface(IDispatch)
    ['{91DB55BC-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; 
                 const OrderType: WideString; const Order: WideString; FillPrice: Integer; 
                 FillBaseCode: Byte; SlippagePrice: Integer; SlippageBaseCode: Byte; 
                 TimePlaced: TDateTime; TimeFilled: TDateTime; const System: WideString; 
                 const Signal: WideString; const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 WindowID: Integer; nFlags: Integer; const AlertString: WideString): IDispatch; safecall;
    procedure Reset; safecall;
    function Item(index: Integer): IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); safecall;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; safecall;
    procedure GetBufferSize(var plVal: Integer); safecall;
    procedure ChangeBufferSize(lVal: Integer); safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IFilledOrdersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BC-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IFilledOrdersDisp = dispinterface
    ['{91DB55BC-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; 
                 const OrderType: WideString; const Order: WideString; FillPrice: Integer; 
                 FillBaseCode: Byte; SlippagePrice: Integer; SlippageBaseCode: Byte; 
                 TimePlaced: TDateTime; TimeFilled: TDateTime; const System: WideString; 
                 const Signal: WideString; const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 WindowID: Integer; nFlags: Integer; const AlertString: WideString): IDispatch; dispid 1;
    procedure Reset; dispid 3;
    function Item(index: Integer): IDispatch; dispid 4;
    property Parent: IDispatch readonly dispid 5;
    property Count: Integer readonly dispid 6;
    property _NewEnum: IUnknown readonly dispid 7;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); dispid 10;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; dispid 11;
    procedure GetBufferSize(var plVal: Integer); dispid 12;
    procedure ChangeBufferSize(lVal: Integer); dispid 13;
  end;

// *********************************************************************//
// Interface: IFOEventHelper
// Flags:     (256) OleAutomation
// GUID:      {804DECF3-0132-11D2-BCEF-00805F05ADAC}
// *********************************************************************//
  IFOEventHelper = interface(IUnknown)
    ['{804DECF3-0132-11D2-BCEF-00805F05ADAC}']
    function FireAddHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireResetHelper: HResult; stdcall;
    function FireRemoveHelper(const pDisp: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ICanceledOrders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BB-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  ICanceledOrders = interface(IDispatch)
    ['{91DB55BB-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; 
                 const OrderType: WideString; const Order: WideString; TimePlaced: TDateTime; 
                 TimeCanceled: TDateTime; const System: WideString; const Signal: WideString; 
                 const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 const CanceledNumber: WideString; WindowID: Integer; nFlags: Integer; 
                 const AlertString: WideString): IDispatch; safecall;
    procedure Reset; safecall;
    function Item(index: Integer): IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); safecall;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; safecall;
    procedure GetBufferSize(var plVal: Integer); safecall;
    procedure ChangeBufferSize(lVal: Integer); safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  ICanceledOrdersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BB-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  ICanceledOrdersDisp = dispinterface
    ['{91DB55BB-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; 
                 const OrderType: WideString; const Order: WideString; TimePlaced: TDateTime; 
                 TimeCanceled: TDateTime; const System: WideString; const Signal: WideString; 
                 const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 const CanceledNumber: WideString; WindowID: Integer; nFlags: Integer; 
                 const AlertString: WideString): IDispatch; dispid 1;
    procedure Reset; dispid 3;
    function Item(index: Integer): IDispatch; dispid 4;
    property Parent: IDispatch readonly dispid 5;
    property Count: Integer readonly dispid 6;
    property _NewEnum: IUnknown readonly dispid 7;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); dispid 10;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; dispid 11;
    procedure GetBufferSize(var plVal: Integer); dispid 12;
    procedure ChangeBufferSize(lVal: Integer); dispid 13;
  end;

// *********************************************************************//
// Interface: ICOEventHelper
// Flags:     (256) OleAutomation
// GUID:      {804DECF4-0132-11D2-BCEF-00805F05ADAC}
// *********************************************************************//
  ICOEventHelper = interface(IUnknown)
    ['{804DECF4-0132-11D2-BCEF-00805F05ADAC}']
    function FireAddHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireResetHelper: HResult; stdcall;
    function FireRemoveHelper(const pDisp: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IOpenPositions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BD-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IOpenPositions = interface(IDispatch)
    ['{91DB55BD-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; EntryPrice: Integer; 
                 EntryBaseCode: Byte; LastPrice: Integer; LastBaseCode: Byte; ProfitPrice: Integer; 
                 ProfitBaseCode: Byte; EntryTime: TDateTime; const System: WideString; 
                 const Signal: WideString; const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 WindowID: Integer; nFlags: Integer; const AlertString: WideString): IDispatch; safecall;
    procedure Remove(Item: OleVariant); safecall;
    procedure Reset; safecall;
    function Item(index: Integer): IDispatch; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); safecall;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IOpenPositionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BD-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  IOpenPositionsDisp = dispinterface
    ['{91DB55BD-9661-11D1-BCCB-00805F05ADAC}']
    function Add(const Symbol: WideString; const Description: WideString; EntryPrice: Integer; 
                 EntryBaseCode: Byte; LastPrice: Integer; LastBaseCode: Byte; ProfitPrice: Integer; 
                 ProfitBaseCode: Byte; EntryTime: TDateTime; const System: WideString; 
                 const Signal: WideString; const WorkSpace: WideString; const Interval: WideString; 
                 const PositionNumber: WideString; const OrderNumber: WideString; 
                 WindowID: Integer; nFlags: Integer; const AlertString: WideString): IDispatch; dispid 1;
    procedure Remove(Item: OleVariant); dispid 2;
    procedure Reset; dispid 3;
    function Item(index: Integer): IDispatch; dispid 4;
    property Parent: IDispatch readonly dispid 5;
    property Count: Integer readonly dispid 6;
    property _NewEnum: IUnknown readonly dispid 7;
    procedure SetOption(Option: tagSTCCOPTIONS; Value: OleVariant); dispid 10;
    function GetOption(Option: tagSTCCOPTIONS): OleVariant; dispid 11;
  end;

// *********************************************************************//
// Interface: IOPEventHelper
// Flags:     (256) OleAutomation
// GUID:      {804DECF5-0132-11D2-BCEF-00805F05ADAC}
// *********************************************************************//
  IOPEventHelper = interface(IUnknown)
    ['{804DECF5-0132-11D2-BCEF-00805F05ADAC}']
    function FireAddHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireModifyHelper(const pDisp: IDispatch): HResult; stdcall;
    function FireResetHelper: HResult; stdcall;
    function FireRemoveHelper(const pDisp: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISTCCOrders
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BE-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  ISTCCOrders = interface(IDispatch)
    ['{91DB55BE-9661-11D1-BCCB-00805F05ADAC}']
    function Get_Parent: IDispatch; safecall;
    function Get_ActiveOrders: IDispatch; safecall;
    function Get_FilledOrders: IDispatch; safecall;
    function Get_CanceledOrders: IDispatch; safecall;
    function Get_OpenPositions: IDispatch; safecall;
    function Get_WAActiveOrders: IDispatch; safecall;
    function Get_WAFilledOrders: IDispatch; safecall;
    function Get_WACanceledOrders: IDispatch; safecall;
    function Get_WAOpenPositions: IDispatch; safecall;
    property Parent: IDispatch read Get_Parent;
    property ActiveOrders: IDispatch read Get_ActiveOrders;
    property FilledOrders: IDispatch read Get_FilledOrders;
    property CanceledOrders: IDispatch read Get_CanceledOrders;
    property OpenPositions: IDispatch read Get_OpenPositions;
    property WAActiveOrders: IDispatch read Get_WAActiveOrders;
    property WAFilledOrders: IDispatch read Get_WAFilledOrders;
    property WACanceledOrders: IDispatch read Get_WACanceledOrders;
    property WAOpenPositions: IDispatch read Get_WAOpenPositions;
  end;

// *********************************************************************//
// DispIntf:  ISTCCOrdersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {91DB55BE-9661-11D1-BCCB-00805F05ADAC}
// *********************************************************************//
  ISTCCOrdersDisp = dispinterface
    ['{91DB55BE-9661-11D1-BCCB-00805F05ADAC}']
    property Parent: IDispatch readonly dispid 1;
    property ActiveOrders: IDispatch readonly dispid 2;
    property FilledOrders: IDispatch readonly dispid 3;
    property CanceledOrders: IDispatch readonly dispid 4;
    property OpenPositions: IDispatch readonly dispid 5;
    property WAActiveOrders: IDispatch readonly dispid 6;
    property WAFilledOrders: IDispatch readonly dispid 7;
    property WACanceledOrders: IDispatch readonly dispid 8;
    property WAOpenPositions: IDispatch readonly dispid 9;
  end;

// *********************************************************************//
// The Class CoMessageLogMessage provides a Create and CreateRemote method to          
// create instances of the default interface IMessageLogMessage exposed by              
// the CoClass MessageLogMessage. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMessageLogMessage = class
    class function Create: IMessageLogMessage;
    class function CreateRemote(const MachineName: string): IMessageLogMessage;
  end;

// *********************************************************************//
// The Class CoMessageLogMessages provides a Create and CreateRemote method to          
// create instances of the default interface IMessageLogMessages exposed by              
// the CoClass MessageLogMessages. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMessageLogMessages = class
    class function Create: IMessageLogMessages;
    class function CreateRemote(const MachineName: string): IMessageLogMessages;
  end;

  TMessageLogMessagesAdd = procedure(ASender: TObject; const pDisp: IDispatch) of object;
  TMessageLogMessagesRemove = procedure(ASender: TObject; const pDisp: IDispatch) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TMessageLogMessages
// Help String      : MessageLogMessages Class
// Default Interface: IMessageLogMessages
// Def. Intf. DISP? : No
// Event   Interface: IMessageLogEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TMessageLogMessagesProperties= class;
{$ENDIF}
  TMessageLogMessages = class(TOleServer)
  private
    FOnAdd: TMessageLogMessagesAdd;
    FOnReset: TNotifyEvent;
    FOnRemove: TMessageLogMessagesRemove;
    FIntf: IMessageLogMessages;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TMessageLogMessagesProperties;
    function GetServerProperties: TMessageLogMessagesProperties;
{$ENDIF}
    function GetDefaultInterface: IMessageLogMessages;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get__NewEnum: IUnknown;
    function Get_Parent: IDispatch;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IMessageLogMessages);
    procedure Disconnect; override;
    function Item(index: Integer): IDispatch;
    function Add(Occured: TDateTime; const Content: WideString; const Analysis: WideString): IDispatch;
    procedure Reset;
    procedure GetBufferSize(var pVal: Integer);
    procedure ChangeBufferSize(pVal: Integer);
    property DefaultInterface: IMessageLogMessages read GetDefaultInterface;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TMessageLogMessagesProperties read GetServerProperties;
{$ENDIF}
    property OnAdd: TMessageLogMessagesAdd read FOnAdd write FOnAdd;
    property OnReset: TNotifyEvent read FOnReset write FOnReset;
    property OnRemove: TMessageLogMessagesRemove read FOnRemove write FOnRemove;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TMessageLogMessages
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TMessageLogMessagesProperties = class(TPersistent)
  private
    FServer:    TMessageLogMessages;
    function    GetDefaultInterface: IMessageLogMessages;
    constructor Create(AServer: TMessageLogMessages);
  protected
    function Get__NewEnum: IUnknown;
    function Get_Parent: IDispatch;
    function Get_Count: Integer;
  public
    property DefaultInterface: IMessageLogMessages read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoATCCAlert provides a Create and CreateRemote method to          
// create instances of the default interface IATCCAlert exposed by              
// the CoClass ATCCAlert. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoATCCAlert = class
    class function Create: IATCCAlert;
    class function CreateRemote(const MachineName: string): IATCCAlert;
  end;

// *********************************************************************//
// The Class CoATCCAlerts provides a Create and CreateRemote method to          
// create instances of the default interface IATCCAlerts exposed by              
// the CoClass ATCCAlerts. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoATCCAlerts = class
    class function Create: IATCCAlerts;
    class function CreateRemote(const MachineName: string): IATCCAlerts;
  end;

  TATCCAlertsAdd = procedure(ASender: TObject; const pDisp: IDispatch) of object;
  TATCCAlertsRemove = procedure(ASender: TObject; const pDisp: IDispatch) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TATCCAlerts
// Help String      : ATCCDataCollection Class
// Default Interface: IATCCAlerts
// Def. Intf. DISP? : No
// Event   Interface: IATCCEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TATCCAlertsProperties= class;
{$ENDIF}
  TATCCAlerts = class(TOleServer)
  private
    FOnAdd: TATCCAlertsAdd;
    FOnReset: TNotifyEvent;
    FOnRemove: TATCCAlertsRemove;
    FIntf: IATCCAlerts;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TATCCAlertsProperties;
    function GetServerProperties: TATCCAlertsProperties;
{$ENDIF}
    function GetDefaultInterface: IATCCAlerts;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_Parent: IDispatch;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IATCCAlerts);
    procedure Disconnect; override;
    function Item(index: Integer): IDispatch;
    function Add(Occured: TDateTime; const Symbol: WideString; const Interval: WideString; 
                 const Name: WideString; Pieces: Integer; Piececode: Byte; 
                 const WorkSpace: WideString; const AlertString: WideString; WindowID: Integer; 
                 AlertType: Integer): IDispatch;
    procedure Reset;
    procedure GetBufferSize(var pVal: Integer);
    procedure ChangeBufferSize(pVal: Integer);
    procedure DumpToPager(const PageString: WideString);
    procedure DumpContentToPager;
    procedure SetOption(Option: tagATCCOPTIONS; Value: OleVariant);
    function GetOption(Option: tagATCCOPTIONS): OleVariant;
    property DefaultInterface: IATCCAlerts read GetDefaultInterface;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TATCCAlertsProperties read GetServerProperties;
{$ENDIF}
    property OnAdd: TATCCAlertsAdd read FOnAdd write FOnAdd;
    property OnReset: TNotifyEvent read FOnReset write FOnReset;
    property OnRemove: TATCCAlertsRemove read FOnRemove write FOnRemove;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TATCCAlerts
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TATCCAlertsProperties = class(TPersistent)
  private
    FServer:    TATCCAlerts;
    function    GetDefaultInterface: IATCCAlerts;
    constructor Create(AServer: TATCCAlerts);
  protected
    function Get_Parent: IDispatch;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    property DefaultInterface: IATCCAlerts read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWAATCCAlerts provides a Create and CreateRemote method to          
// create instances of the default interface IATCCAlerts exposed by              
// the CoClass WAATCCAlerts. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWAATCCAlerts = class
    class function Create: IATCCAlerts;
    class function CreateRemote(const MachineName: string): IATCCAlerts;
  end;

  TWAATCCAlertsAdd = procedure(ASender: TObject; const pDisp: IDispatch) of object;
  TWAATCCAlertsRemove = procedure(ASender: TObject; const pDisp: IDispatch) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWAATCCAlerts
// Help String      : WAATCCDataCollection Class
// Default Interface: IATCCAlerts
// Def. Intf. DISP? : No
// Event   Interface: IATCCEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWAATCCAlertsProperties= class;
{$ENDIF}
  TWAATCCAlerts = class(TOleServer)
  private
    FOnAdd: TWAATCCAlertsAdd;
    FOnReset: TNotifyEvent;
    FOnRemove: TWAATCCAlertsRemove;
    FIntf: IATCCAlerts;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TWAATCCAlertsProperties;
    function GetServerProperties: TWAATCCAlertsProperties;
{$ENDIF}
    function GetDefaultInterface: IATCCAlerts;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_Parent: IDispatch;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IATCCAlerts);
    procedure Disconnect; override;
    function Item(index: Integer): IDispatch;
    function Add(Occured: TDateTime; const Symbol: WideString; const Interval: WideString; 
                 const Name: WideString; Pieces: Integer; Piececode: Byte; 
                 const WorkSpace: WideString; const AlertString: WideString; WindowID: Integer; 
                 AlertType: Integer): IDispatch;
    procedure Reset;
    procedure GetBufferSize(var pVal: Integer);
    procedure ChangeBufferSize(pVal: Integer);
    procedure DumpToPager(const PageString: WideString);
    procedure DumpContentToPager;
    procedure SetOption(Option: tagATCCOPTIONS; Value: OleVariant);
    function GetOption(Option: tagATCCOPTIONS): OleVariant;
    property DefaultInterface: IATCCAlerts read GetDefaultInterface;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWAATCCAlertsProperties read GetServerProperties;
{$ENDIF}
    property OnAdd: TWAATCCAlertsAdd read FOnAdd write FOnAdd;
    property OnReset: TNotifyEvent read FOnReset write FOnReset;
    property OnRemove: TWAATCCAlertsRemove read FOnRemove write FOnRemove;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWAATCCAlerts
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWAATCCAlertsProperties = class(TPersistent)
  private
    FServer:    TWAATCCAlerts;
    function    GetDefaultInterface: IATCCAlerts;
    constructor Create(AServer: TWAATCCAlerts);
  protected
    function Get_Parent: IDispatch;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    property DefaultInterface: IATCCAlerts read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoActiveOrder provides a Create and CreateRemote method to          
// create instances of the default interface IActiveOrder exposed by              
// the CoClass ActiveOrder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoActiveOrder = class
    class function Create: IActiveOrder;
    class function CreateRemote(const MachineName: string): IActiveOrder;
  end;

// *********************************************************************//
// The Class CoFilledOrder provides a Create and CreateRemote method to          
// create instances of the default interface IFilledOrder exposed by              
// the CoClass FilledOrder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFilledOrder = class
    class function Create: IFilledOrder;
    class function CreateRemote(const MachineName: string): IFilledOrder;
  end;

// *********************************************************************//
// The Class CoCanceledOrder provides a Create and CreateRemote method to          
// create instances of the default interface ICanceledOrder exposed by              
// the CoClass CanceledOrder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCanceledOrder = class
    class function Create: ICanceledOrder;
    class function CreateRemote(const MachineName: string): ICanceledOrder;
  end;

// *********************************************************************//
// The Class CoOpenPosition provides a Create and CreateRemote method to          
// create instances of the default interface IOpenPosition exposed by              
// the CoClass OpenPosition. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOpenPosition = class
    class function Create: IOpenPosition;
    class function CreateRemote(const MachineName: string): IOpenPosition;
  end;

// *********************************************************************//
// The Class CoActiveOrders provides a Create and CreateRemote method to          
// create instances of the default interface IActiveOrders exposed by              
// the CoClass ActiveOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoActiveOrders = class
    class function Create: IActiveOrders;
    class function CreateRemote(const MachineName: string): IActiveOrders;
  end;

// *********************************************************************//
// The Class CoWAActiveOrders provides a Create and CreateRemote method to          
// create instances of the default interface IActiveOrders exposed by              
// the CoClass WAActiveOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWAActiveOrders = class
    class function Create: IActiveOrders;
    class function CreateRemote(const MachineName: string): IActiveOrders;
  end;

// *********************************************************************//
// The Class CoWAFilledOrders provides a Create and CreateRemote method to          
// create instances of the default interface IFilledOrders exposed by              
// the CoClass WAFilledOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWAFilledOrders = class
    class function Create: IFilledOrders;
    class function CreateRemote(const MachineName: string): IFilledOrders;
  end;

// *********************************************************************//
// The Class CoFilledOrders provides a Create and CreateRemote method to          
// create instances of the default interface IFilledOrders exposed by              
// the CoClass FilledOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFilledOrders = class
    class function Create: IFilledOrders;
    class function CreateRemote(const MachineName: string): IFilledOrders;
  end;

// *********************************************************************//
// The Class CoCanceledOrders provides a Create and CreateRemote method to          
// create instances of the default interface ICanceledOrders exposed by              
// the CoClass CanceledOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCanceledOrders = class
    class function Create: ICanceledOrders;
    class function CreateRemote(const MachineName: string): ICanceledOrders;
  end;

// *********************************************************************//
// The Class CoWACanceledOrders provides a Create and CreateRemote method to          
// create instances of the default interface ICanceledOrders exposed by              
// the CoClass WACanceledOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWACanceledOrders = class
    class function Create: ICanceledOrders;
    class function CreateRemote(const MachineName: string): ICanceledOrders;
  end;

// *********************************************************************//
// The Class CoOpenPositions provides a Create and CreateRemote method to          
// create instances of the default interface IOpenPositions exposed by              
// the CoClass OpenPositions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOpenPositions = class
    class function Create: IOpenPositions;
    class function CreateRemote(const MachineName: string): IOpenPositions;
  end;

// *********************************************************************//
// The Class CoWAOpenPositions provides a Create and CreateRemote method to          
// create instances of the default interface IOpenPositions exposed by              
// the CoClass WAOpenPositions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWAOpenPositions = class
    class function Create: IOpenPositions;
    class function CreateRemote(const MachineName: string): IOpenPositions;
  end;

// *********************************************************************//
// The Class CoSTCCOrders provides a Create and CreateRemote method to          
// create instances of the default interface ISTCCOrders exposed by              
// the CoClass STCCOrders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSTCCOrders = class
    class function Create: ISTCCOrders;
    class function CreateRemote(const MachineName: string): ISTCCOrders;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSTCCOrders
// Help String      : WASTCCOrders Class
// Default Interface: ISTCCOrders
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSTCCOrdersProperties= class;
{$ENDIF}
  TSTCCOrders = class(TOleServer)
  private
    FIntf: ISTCCOrders;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSTCCOrdersProperties;
    function GetServerProperties: TSTCCOrdersProperties;
{$ENDIF}
    function GetDefaultInterface: ISTCCOrders;
  protected
    procedure InitServerData; override;
    function Get_Parent: IDispatch;
    function Get_ActiveOrders: IDispatch;
    function Get_FilledOrders: IDispatch;
    function Get_CanceledOrders: IDispatch;
    function Get_OpenPositions: IDispatch;
    function Get_WAActiveOrders: IDispatch;
    function Get_WAFilledOrders: IDispatch;
    function Get_WACanceledOrders: IDispatch;
    function Get_WAOpenPositions: IDispatch;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISTCCOrders);
    procedure Disconnect; override;
    property DefaultInterface: ISTCCOrders read GetDefaultInterface;
    property Parent: IDispatch read Get_Parent;
    property ActiveOrders: IDispatch read Get_ActiveOrders;
    property FilledOrders: IDispatch read Get_FilledOrders;
    property CanceledOrders: IDispatch read Get_CanceledOrders;
    property OpenPositions: IDispatch read Get_OpenPositions;
    property WAActiveOrders: IDispatch read Get_WAActiveOrders;
    property WAFilledOrders: IDispatch read Get_WAFilledOrders;
    property WACanceledOrders: IDispatch read Get_WACanceledOrders;
    property WAOpenPositions: IDispatch read Get_WAOpenPositions;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSTCCOrdersProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSTCCOrders
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSTCCOrdersProperties = class(TPersistent)
  private
    FServer:    TSTCCOrders;
    function    GetDefaultInterface: ISTCCOrders;
    constructor Create(AServer: TSTCCOrders);
  protected
    function Get_Parent: IDispatch;
    function Get_ActiveOrders: IDispatch;
    function Get_FilledOrders: IDispatch;
    function Get_CanceledOrders: IDispatch;
    function Get_OpenPositions: IDispatch;
    function Get_WAActiveOrders: IDispatch;
    function Get_WAFilledOrders: IDispatch;
    function Get_WACanceledOrders: IDispatch;
    function Get_WAOpenPositions: IDispatch;
  public
    property DefaultInterface: ISTCCOrders read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoMessageLogMessage.Create: IMessageLogMessage;
begin
  Result := CreateComObject(CLASS_MessageLogMessage) as IMessageLogMessage;
end;

class function CoMessageLogMessage.CreateRemote(const MachineName: string): IMessageLogMessage;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MessageLogMessage) as IMessageLogMessage;
end;

class function CoMessageLogMessages.Create: IMessageLogMessages;
begin
  Result := CreateComObject(CLASS_MessageLogMessages) as IMessageLogMessages;
end;

class function CoMessageLogMessages.CreateRemote(const MachineName: string): IMessageLogMessages;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MessageLogMessages) as IMessageLogMessages;
end;

procedure TMessageLogMessages.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{C51D9DE7-471F-11D1-BC9E-00805F05ADAC}';
    IntfIID:   '{C51D9DE2-471F-11D1-BC9E-00805F05ADAC}';
    EventIID:  '{C51D9DE5-471F-11D1-BC9E-00805F05ADAC}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TMessageLogMessages.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IMessageLogMessages;
  end;
end;

procedure TMessageLogMessages.ConnectTo(svrIntf: IMessageLogMessages);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TMessageLogMessages.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TMessageLogMessages.GetDefaultInterface: IMessageLogMessages;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TMessageLogMessages.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TMessageLogMessagesProperties.Create(Self);
{$ENDIF}
end;

destructor TMessageLogMessages.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TMessageLogMessages.GetServerProperties: TMessageLogMessagesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TMessageLogMessages.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnAdd) then
         FOnAdd(Self, Params[0] {const IDispatch});
    2: if Assigned(FOnReset) then
         FOnReset(Self);
    3: if Assigned(FOnRemove) then
         FOnRemove(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function TMessageLogMessages.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TMessageLogMessages.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TMessageLogMessages.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TMessageLogMessages.Item(index: Integer): IDispatch;
begin
  Result := DefaultInterface.Item(index);
end;

function TMessageLogMessages.Add(Occured: TDateTime; const Content: WideString; 
                                 const Analysis: WideString): IDispatch;
begin
  Result := DefaultInterface.Add(Occured, Content, Analysis);
end;

procedure TMessageLogMessages.Reset;
begin
  DefaultInterface.Reset;
end;

procedure TMessageLogMessages.GetBufferSize(var pVal: Integer);
begin
  DefaultInterface.GetBufferSize(pVal);
end;

procedure TMessageLogMessages.ChangeBufferSize(pVal: Integer);
begin
  DefaultInterface.ChangeBufferSize(pVal);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TMessageLogMessagesProperties.Create(AServer: TMessageLogMessages);
begin
  inherited Create;
  FServer := AServer;
end;

function TMessageLogMessagesProperties.GetDefaultInterface: IMessageLogMessages;
begin
  Result := FServer.DefaultInterface;
end;

function TMessageLogMessagesProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TMessageLogMessagesProperties.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TMessageLogMessagesProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoATCCAlert.Create: IATCCAlert;
begin
  Result := CreateComObject(CLASS_ATCCAlert) as IATCCAlert;
end;

class function CoATCCAlert.CreateRemote(const MachineName: string): IATCCAlert;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ATCCAlert) as IATCCAlert;
end;

class function CoATCCAlerts.Create: IATCCAlerts;
begin
  Result := CreateComObject(CLASS_ATCCAlerts) as IATCCAlerts;
end;

class function CoATCCAlerts.CreateRemote(const MachineName: string): IATCCAlerts;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ATCCAlerts) as IATCCAlerts;
end;

procedure TATCCAlerts.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{362FC040-4565-11D1-9451-00805F05FAB1}';
    IntfIID:   '{E712A120-4564-11D1-9451-00805F05FAB1}';
    EventIID:  '{261859F0-4343-11D1-8280-000000000000}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TATCCAlerts.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IATCCAlerts;
  end;
end;

procedure TATCCAlerts.ConnectTo(svrIntf: IATCCAlerts);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TATCCAlerts.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TATCCAlerts.GetDefaultInterface: IATCCAlerts;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TATCCAlerts.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TATCCAlertsProperties.Create(Self);
{$ENDIF}
end;

destructor TATCCAlerts.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TATCCAlerts.GetServerProperties: TATCCAlertsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TATCCAlerts.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnAdd) then
         FOnAdd(Self, Params[0] {const IDispatch});
    2: if Assigned(FOnReset) then
         FOnReset(Self);
    3: if Assigned(FOnRemove) then
         FOnRemove(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function TATCCAlerts.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TATCCAlerts.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TATCCAlerts.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TATCCAlerts.Item(index: Integer): IDispatch;
begin
  Result := DefaultInterface.Item(index);
end;

function TATCCAlerts.Add(Occured: TDateTime; const Symbol: WideString; const Interval: WideString; 
                         const Name: WideString; Pieces: Integer; Piececode: Byte; 
                         const WorkSpace: WideString; const AlertString: WideString; 
                         WindowID: Integer; AlertType: Integer): IDispatch;
begin
  Result := DefaultInterface.Add(Occured, Symbol, Interval, Name, Pieces, Piececode, WorkSpace, 
                                 AlertString, WindowID, AlertType);
end;

procedure TATCCAlerts.Reset;
begin
  DefaultInterface.Reset;
end;

procedure TATCCAlerts.GetBufferSize(var pVal: Integer);
begin
  DefaultInterface.GetBufferSize(pVal);
end;

procedure TATCCAlerts.ChangeBufferSize(pVal: Integer);
begin
  DefaultInterface.ChangeBufferSize(pVal);
end;

procedure TATCCAlerts.DumpToPager(const PageString: WideString);
begin
  DefaultInterface.DumpToPager(PageString);
end;

procedure TATCCAlerts.DumpContentToPager;
begin
  DefaultInterface.DumpContentToPager;
end;

procedure TATCCAlerts.SetOption(Option: tagATCCOPTIONS; Value: OleVariant);
begin
  DefaultInterface.SetOption(Option, Value);
end;

function TATCCAlerts.GetOption(Option: tagATCCOPTIONS): OleVariant;
begin
  Result := DefaultInterface.GetOption(Option);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TATCCAlertsProperties.Create(AServer: TATCCAlerts);
begin
  inherited Create;
  FServer := AServer;
end;

function TATCCAlertsProperties.GetDefaultInterface: IATCCAlerts;
begin
  Result := FServer.DefaultInterface;
end;

function TATCCAlertsProperties.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TATCCAlertsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TATCCAlertsProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

{$ENDIF}

class function CoWAATCCAlerts.Create: IATCCAlerts;
begin
  Result := CreateComObject(CLASS_WAATCCAlerts) as IATCCAlerts;
end;

class function CoWAATCCAlerts.CreateRemote(const MachineName: string): IATCCAlerts;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WAATCCAlerts) as IATCCAlerts;
end;

procedure TWAATCCAlerts.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{4F46CA90-A70F-11D2-B7A7-00C04F7CD214}';
    IntfIID:   '{E712A120-4564-11D1-9451-00805F05FAB1}';
    EventIID:  '{261859F0-4343-11D1-8280-000000000000}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWAATCCAlerts.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IATCCAlerts;
  end;
end;

procedure TWAATCCAlerts.ConnectTo(svrIntf: IATCCAlerts);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TWAATCCAlerts.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TWAATCCAlerts.GetDefaultInterface: IATCCAlerts;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TWAATCCAlerts.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWAATCCAlertsProperties.Create(Self);
{$ENDIF}
end;

destructor TWAATCCAlerts.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWAATCCAlerts.GetServerProperties: TWAATCCAlertsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TWAATCCAlerts.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnAdd) then
         FOnAdd(Self, Params[0] {const IDispatch});
    2: if Assigned(FOnReset) then
         FOnReset(Self);
    3: if Assigned(FOnRemove) then
         FOnRemove(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function TWAATCCAlerts.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TWAATCCAlerts.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TWAATCCAlerts.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TWAATCCAlerts.Item(index: Integer): IDispatch;
begin
  Result := DefaultInterface.Item(index);
end;

function TWAATCCAlerts.Add(Occured: TDateTime; const Symbol: WideString; 
                           const Interval: WideString; const Name: WideString; Pieces: Integer; 
                           Piececode: Byte; const WorkSpace: WideString; 
                           const AlertString: WideString; WindowID: Integer; AlertType: Integer): IDispatch;
begin
  Result := DefaultInterface.Add(Occured, Symbol, Interval, Name, Pieces, Piececode, WorkSpace, 
                                 AlertString, WindowID, AlertType);
end;

procedure TWAATCCAlerts.Reset;
begin
  DefaultInterface.Reset;
end;

procedure TWAATCCAlerts.GetBufferSize(var pVal: Integer);
begin
  DefaultInterface.GetBufferSize(pVal);
end;

procedure TWAATCCAlerts.ChangeBufferSize(pVal: Integer);
begin
  DefaultInterface.ChangeBufferSize(pVal);
end;

procedure TWAATCCAlerts.DumpToPager(const PageString: WideString);
begin
  DefaultInterface.DumpToPager(PageString);
end;

procedure TWAATCCAlerts.DumpContentToPager;
begin
  DefaultInterface.DumpContentToPager;
end;

procedure TWAATCCAlerts.SetOption(Option: tagATCCOPTIONS; Value: OleVariant);
begin
  DefaultInterface.SetOption(Option, Value);
end;

function TWAATCCAlerts.GetOption(Option: tagATCCOPTIONS): OleVariant;
begin
  Result := DefaultInterface.GetOption(Option);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWAATCCAlertsProperties.Create(AServer: TWAATCCAlerts);
begin
  inherited Create;
  FServer := AServer;
end;

function TWAATCCAlertsProperties.GetDefaultInterface: IATCCAlerts;
begin
  Result := FServer.DefaultInterface;
end;

function TWAATCCAlertsProperties.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TWAATCCAlertsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TWAATCCAlertsProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

{$ENDIF}

class function CoActiveOrder.Create: IActiveOrder;
begin
  Result := CreateComObject(CLASS_ActiveOrder) as IActiveOrder;
end;

class function CoActiveOrder.CreateRemote(const MachineName: string): IActiveOrder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ActiveOrder) as IActiveOrder;
end;

class function CoFilledOrder.Create: IFilledOrder;
begin
  Result := CreateComObject(CLASS_FilledOrder) as IFilledOrder;
end;

class function CoFilledOrder.CreateRemote(const MachineName: string): IFilledOrder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FilledOrder) as IFilledOrder;
end;

class function CoCanceledOrder.Create: ICanceledOrder;
begin
  Result := CreateComObject(CLASS_CanceledOrder) as ICanceledOrder;
end;

class function CoCanceledOrder.CreateRemote(const MachineName: string): ICanceledOrder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CanceledOrder) as ICanceledOrder;
end;

class function CoOpenPosition.Create: IOpenPosition;
begin
  Result := CreateComObject(CLASS_OpenPosition) as IOpenPosition;
end;

class function CoOpenPosition.CreateRemote(const MachineName: string): IOpenPosition;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OpenPosition) as IOpenPosition;
end;

class function CoActiveOrders.Create: IActiveOrders;
begin
  Result := CreateComObject(CLASS_ActiveOrders) as IActiveOrders;
end;

class function CoActiveOrders.CreateRemote(const MachineName: string): IActiveOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ActiveOrders) as IActiveOrders;
end;

class function CoWAActiveOrders.Create: IActiveOrders;
begin
  Result := CreateComObject(CLASS_WAActiveOrders) as IActiveOrders;
end;

class function CoWAActiveOrders.CreateRemote(const MachineName: string): IActiveOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WAActiveOrders) as IActiveOrders;
end;

class function CoWAFilledOrders.Create: IFilledOrders;
begin
  Result := CreateComObject(CLASS_WAFilledOrders) as IFilledOrders;
end;

class function CoWAFilledOrders.CreateRemote(const MachineName: string): IFilledOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WAFilledOrders) as IFilledOrders;
end;

class function CoFilledOrders.Create: IFilledOrders;
begin
  Result := CreateComObject(CLASS_FilledOrders) as IFilledOrders;
end;

class function CoFilledOrders.CreateRemote(const MachineName: string): IFilledOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FilledOrders) as IFilledOrders;
end;

class function CoCanceledOrders.Create: ICanceledOrders;
begin
  Result := CreateComObject(CLASS_CanceledOrders) as ICanceledOrders;
end;

class function CoCanceledOrders.CreateRemote(const MachineName: string): ICanceledOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CanceledOrders) as ICanceledOrders;
end;

class function CoWACanceledOrders.Create: ICanceledOrders;
begin
  Result := CreateComObject(CLASS_WACanceledOrders) as ICanceledOrders;
end;

class function CoWACanceledOrders.CreateRemote(const MachineName: string): ICanceledOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WACanceledOrders) as ICanceledOrders;
end;

class function CoOpenPositions.Create: IOpenPositions;
begin
  Result := CreateComObject(CLASS_OpenPositions) as IOpenPositions;
end;

class function CoOpenPositions.CreateRemote(const MachineName: string): IOpenPositions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OpenPositions) as IOpenPositions;
end;

class function CoWAOpenPositions.Create: IOpenPositions;
begin
  Result := CreateComObject(CLASS_WAOpenPositions) as IOpenPositions;
end;

class function CoWAOpenPositions.CreateRemote(const MachineName: string): IOpenPositions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WAOpenPositions) as IOpenPositions;
end;

class function CoSTCCOrders.Create: ISTCCOrders;
begin
  Result := CreateComObject(CLASS_STCCOrders) as ISTCCOrders;
end;

class function CoSTCCOrders.CreateRemote(const MachineName: string): ISTCCOrders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_STCCOrders) as ISTCCOrders;
end;

procedure TSTCCOrders.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{47D1DFF3-351F-11D1-BC98-00805F05ADAC}';
    IntfIID:   '{91DB55BE-9661-11D1-BCCB-00805F05ADAC}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSTCCOrders.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISTCCOrders;
  end;
end;

procedure TSTCCOrders.ConnectTo(svrIntf: ISTCCOrders);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSTCCOrders.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSTCCOrders.GetDefaultInterface: ISTCCOrders;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSTCCOrders.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSTCCOrdersProperties.Create(Self);
{$ENDIF}
end;

destructor TSTCCOrders.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSTCCOrders.GetServerProperties: TSTCCOrdersProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSTCCOrders.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TSTCCOrders.Get_ActiveOrders: IDispatch;
begin
    Result := DefaultInterface.ActiveOrders;
end;

function TSTCCOrders.Get_FilledOrders: IDispatch;
begin
    Result := DefaultInterface.FilledOrders;
end;

function TSTCCOrders.Get_CanceledOrders: IDispatch;
begin
    Result := DefaultInterface.CanceledOrders;
end;

function TSTCCOrders.Get_OpenPositions: IDispatch;
begin
    Result := DefaultInterface.OpenPositions;
end;

function TSTCCOrders.Get_WAActiveOrders: IDispatch;
begin
    Result := DefaultInterface.WAActiveOrders;
end;

function TSTCCOrders.Get_WAFilledOrders: IDispatch;
begin
    Result := DefaultInterface.WAFilledOrders;
end;

function TSTCCOrders.Get_WACanceledOrders: IDispatch;
begin
    Result := DefaultInterface.WACanceledOrders;
end;

function TSTCCOrders.Get_WAOpenPositions: IDispatch;
begin
    Result := DefaultInterface.WAOpenPositions;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSTCCOrdersProperties.Create(AServer: TSTCCOrders);
begin
  inherited Create;
  FServer := AServer;
end;

function TSTCCOrdersProperties.GetDefaultInterface: ISTCCOrders;
begin
  Result := FServer.DefaultInterface;
end;

function TSTCCOrdersProperties.Get_Parent: IDispatch;
begin
    Result := DefaultInterface.Parent;
end;

function TSTCCOrdersProperties.Get_ActiveOrders: IDispatch;
begin
    Result := DefaultInterface.ActiveOrders;
end;

function TSTCCOrdersProperties.Get_FilledOrders: IDispatch;
begin
    Result := DefaultInterface.FilledOrders;
end;

function TSTCCOrdersProperties.Get_CanceledOrders: IDispatch;
begin
    Result := DefaultInterface.CanceledOrders;
end;

function TSTCCOrdersProperties.Get_OpenPositions: IDispatch;
begin
    Result := DefaultInterface.OpenPositions;
end;

function TSTCCOrdersProperties.Get_WAActiveOrders: IDispatch;
begin
    Result := DefaultInterface.WAActiveOrders;
end;

function TSTCCOrdersProperties.Get_WAFilledOrders: IDispatch;
begin
    Result := DefaultInterface.WAFilledOrders;
end;

function TSTCCOrdersProperties.Get_WACanceledOrders: IDispatch;
begin
    Result := DefaultInterface.WACanceledOrders;
end;

function TSTCCOrdersProperties.Get_WAOpenPositions: IDispatch;
begin
    Result := DefaultInterface.WAOpenPositions;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TMessageLogMessages, TATCCAlerts, TWAATCCAlerts, TSTCCOrders]);
end;

end.
