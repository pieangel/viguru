unit WRAXLib_TLB;

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
// File generated on 2022-01-20 오후 6:27:16 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\DelphiProject\NHApi국내\WRAX.ocx (1)
// LIBID: {9EA87740-604D-4E4E-A9BD-34A4D8A76156}
// LCID: 0
// Helpfile: D:\DelphiProject\NHApi국내\WRAX.hlp
// HelpString: WRAX ActiveX Control module
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
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

uses Windows, ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WRAXLibMajorVersion = 5;
  WRAXLibMinorVersion = 7;

  LIBID_WRAXLib: TGUID = '{9EA87740-604D-4E4E-A9BD-34A4D8A76156}';

  DIID__DWRAX: TGUID = '{1B1F1E20-1A9D-429C-AE91-B6ECCC786734}';
  DIID__DWRAXEvents: TGUID = '{17467A5C-AC04-4084-89D9-4DF14FC4E825}';
  CLASS_WRAX: TGUID = '{EC22F588-9228-43EA-8F8D-13C5FC2D5585}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DWRAX = dispinterface;
  _DWRAXEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  WRAX = _DWRAX;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PWordBool1 = ^WordBool; {*}
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// DispIntf:  _DWRAX
// Flags:     (4112) Hidden Dispatchable
// GUID:      {1B1F1E20-1A9D-429C-AE91-B6ECCC786734}
// *********************************************************************//
  _DWRAX = dispinterface
    ['{1B1F1E20-1A9D-429C-AE91-B6ECCC786734}']
    procedure OConnectHost(const szIP: WideString; const szPort: WideString); dispid 1;
    procedure OCloseHost; dispid 2;
    procedure OLogin(const szUserID: WideString; const szPWD: WideString; 
                     const szCertPWD: WideString); dispid 3;
    function ORequestData(const szTrName: WideString; nDataSize: Integer; const szData: WideString; 
                          bEncrypt: WordBool; bCompress: WordBool; nTimeOut: Smallint): Smallint; dispid 4;
    function ORegistRealData(const szTrName: WideString; const szKeyCode: WideString): Smallint; dispid 5;
    function OUnregistRealData(nRealID: Smallint): WordBool; dispid 6;
    procedure OGetMasterFile(const szFileName: WideString); dispid 7;
    function OSendNewOrder(const szAccNum: WideString; const szPassword: WideString; 
                           const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                           nFillType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                           nCustOrderKey: Smallint): WideString; dispid 8;
    function OSendModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                            const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                            nFillType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                            const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString; dispid 9;
    function OSendCancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                              const szCode: WideString; nBuySell: Smallint; nOrderQty: Smallint; 
                              const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString; dispid 10;
    function OGet2KoreanStr(const szData: WideString): WideString; dispid 11;
    function OSendCMENewOrder(const szAccNum: WideString; const szPassword: WideString; 
                              const szCode: WideString; nBuySell: Smallint; nFillType: Smallint; 
                              nOrderQty: Smallint; dOrderPx: Double; nCustOrderKey: Smallint): WideString; dispid 12;
    function OSendCMECancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                 const szCode: WideString; nBuySell: Smallint; 
                                 const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString; dispid 13;
    function OCopyToClipboard(const szInputData: WideString): WordBool; dispid 14;
    function OIsLogined: WordBool; dispid 15;
    function OSendCMEModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                               const szCode: WideString; nBuySell: Smallint; dOrderPx: Double; 
                               const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString; dispid 16;
    procedure OClearAllCount; dispid 17;
    function OGetJongMokInfo(nType: Smallint; const strItemCode: WideString): WideString; dispid 18;
    function OGetPLAmtByPx(const strItemCode: WideString; nTradeSect: Smallint; nQty: Smallint; 
                           dAvgPx: Double; dCurrentPx: Double): Double; dispid 19;
    function OGetPLAmtByAmt(const strItemCode: WideString; nTradeSect: Smallint; nQty: Smallint; 
                            dAvgAmt: Double; dCurrentPx: Double): Double; dispid 20;
    function ORegistRealDataToMainLib(const strRealTrCode: WideString; const strKeyCode: WideString): Smallint; dispid 21;
    function OUnregistRealDataToMainLib(nSBID: Smallint): WordBool; dispid 22;
    function OGetSiseDataFromMainLib(const strRealTrCode: WideString; const strKeyCode: WideString; 
                                     var bIsFirstGet: WordBool; var strOutData: WideString): Integer; dispid 23;
    function OGetAccountInfCount: Smallint; dispid 24;
    function OGetAccountInf(nIndex: Smallint; var pszAccountNo: WideString; 
                            var pszAccountName: WideString): Integer; dispid 25;
    function OGetCMEAccountInfCount: Smallint; dispid 26;
    function OGetCMEAccountInf(nIndex: Smallint; var pszAccountNo: WideString; 
                               var pszAccountName: WideString): Integer; dispid 27;
    function OSendEUREXNewOrder(const szAccNum: WideString; const szPassword: WideString; 
                                const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                                nOrderQty: Smallint; dOrderPx: Double; nCustOrderKey: Smallint): WideString; dispid 28;
    function OSendEUREXModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                                 const szCode: WideString; nBuySell: Smallint; 
                                 nOrderType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                                 const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString; dispid 29;
    function OSendEUREXCancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                   const szCode: WideString; nBuySell: Smallint; 
                                   nOrdeType: Smallint; nOrderQty: Smallint; 
                                   const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString; dispid 30;
    procedure AboutBox; dispid -552;
  end;

// *********************************************************************//
// DispIntf:  _DWRAXEvents
// Flags:     (4096) Dispatchable
// GUID:      {17467A5C-AC04-4084-89D9-4DF14FC4E825}
// *********************************************************************//
  _DWRAXEvents = dispinterface
    ['{17467A5C-AC04-4084-89D9-4DF14FC4E825}']
    procedure RecvData(DataType: Smallint; const TrCode: WideString; nRqID: Smallint; 
                       nDataSize: Integer; var szData: WideString); dispid 1;
    procedure RecvRealData(const TrCode: WideString; const KeyValue: WideString; nRealID: Smallint; 
                           nDataSize: Integer; const szData: WideString); dispid 2;
    procedure NetConnected; dispid 3;
    procedure NetDisconnected; dispid 4;
    procedure ReplyLogin(nResult: Smallint; const Message: WideString); dispid 5;
    procedure ReplyFileDown(nResult: Smallint; const Message: WideString); dispid 6;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TWRAX
// Help String      : WRAX Control
// Default Interface: _DWRAX
// Def. Intf. DISP? : Yes
// Event   Interface: _DWRAXEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TWRAXRecvData = procedure(ASender: TObject; DataType: Smallint; const TrCode: WideString; 
                                              nRqID: Smallint; nDataSize: Integer; 
                                              var szData: WideString) of object;
  TWRAXRecvRealData = procedure(ASender: TObject; const TrCode: WideString; 
                                                  const KeyValue: WideString; nRealID: Smallint; 
                                                  nDataSize: Integer; const szData: WideString) of object;
  TWRAXReplyLogin = procedure(ASender: TObject; nResult: Smallint; const Message: WideString) of object;
  TWRAXReplyFileDown = procedure(ASender: TObject; nResult: Smallint; const Message: WideString) of object;

  TWRAX = class(TOleControl)
  private
    FOnRecvData: TWRAXRecvData;
    FOnRecvRealData: TWRAXRecvRealData;
    FOnNetConnected: TNotifyEvent;
    FOnNetDisconnected: TNotifyEvent;
    FOnReplyLogin: TWRAXReplyLogin;
    FOnReplyFileDown: TWRAXReplyFileDown;
    FIntf: _DWRAX;
    function  GetControlInterface: _DWRAX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure OConnectHost(const szIP: WideString; const szPort: WideString);
    procedure OCloseHost;
    procedure OLogin(const szUserID: WideString; const szPWD: WideString; 
                     const szCertPWD: WideString);
    function ORequestData(const szTrName: WideString; nDataSize: Integer; const szData: WideString; 
                          bEncrypt: WordBool; bCompress: WordBool; nTimeOut: Smallint): Smallint;
    function ORegistRealData(const szTrName: WideString; const szKeyCode: WideString): Smallint;
    function OUnregistRealData(nRealID: Smallint): WordBool;
    procedure OGetMasterFile(const szFileName: WideString);
    function OSendNewOrder(const szAccNum: WideString; const szPassword: WideString; 
                           const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                           nFillType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                           nCustOrderKey: Smallint): WideString;
    function OSendModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                            const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                            nFillType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                            const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
    function OSendCancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                              const szCode: WideString; nBuySell: Smallint; nOrderQty: Smallint; 
                              const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
    function OGet2KoreanStr(const szData: WideString): WideString;
    function OSendCMENewOrder(const szAccNum: WideString; const szPassword: WideString; 
                              const szCode: WideString; nBuySell: Smallint; nFillType: Smallint; 
                              nOrderQty: Smallint; dOrderPx: Double; nCustOrderKey: Smallint): WideString;
    function OSendCMECancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                 const szCode: WideString; nBuySell: Smallint; 
                                 const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
    function OCopyToClipboard(const szInputData: WideString): WordBool;
    function OIsLogined: WordBool;
    function OSendCMEModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                               const szCode: WideString; nBuySell: Smallint; dOrderPx: Double; 
                               const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
    procedure OClearAllCount;
    function OGetJongMokInfo(nType: Smallint; const strItemCode: WideString): WideString;
    function OGetPLAmtByPx(const strItemCode: WideString; nTradeSect: Smallint; nQty: Smallint; 
                           dAvgPx: Double; dCurrentPx: Double): Double;
    function OGetPLAmtByAmt(const strItemCode: WideString; nTradeSect: Smallint; nQty: Smallint; 
                            dAvgAmt: Double; dCurrentPx: Double): Double;
    function ORegistRealDataToMainLib(const strRealTrCode: WideString; const strKeyCode: WideString): Smallint;
    function OUnregistRealDataToMainLib(nSBID: Smallint): WordBool;
    function OGetSiseDataFromMainLib(const strRealTrCode: WideString; const strKeyCode: WideString; 
                                     var bIsFirstGet: WordBool; var strOutData: WideString): Integer;
    function OGetAccountInfCount: Smallint;
    function OGetAccountInf(nIndex: Smallint; var pszAccountNo: WideString; 
                            var pszAccountName: WideString): Integer;
    function OGetCMEAccountInfCount: Smallint;
    function OGetCMEAccountInf(nIndex: Smallint; var pszAccountNo: WideString; 
                               var pszAccountName: WideString): Integer;
    function OSendEUREXNewOrder(const szAccNum: WideString; const szPassword: WideString; 
                                const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                                nOrderQty: Smallint; dOrderPx: Double; nCustOrderKey: Smallint): WideString;
    function OSendEUREXModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                                 const szCode: WideString; nBuySell: Smallint; 
                                 nOrderType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                                 const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
    function OSendEUREXCancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                   const szCode: WideString; nBuySell: Smallint; 
                                   nOrdeType: Smallint; nOrderQty: Smallint; 
                                   const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
    procedure AboutBox;
    property  ControlInterface: _DWRAX read GetControlInterface;
    property  DefaultInterface: _DWRAX read GetControlInterface;
  published
    property Anchors;
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property OnRecvData: TWRAXRecvData read FOnRecvData write FOnRecvData;
    property OnRecvRealData: TWRAXRecvRealData read FOnRecvRealData write FOnRecvRealData;
    property OnNetConnected: TNotifyEvent read FOnNetConnected write FOnNetConnected;
    property OnNetDisconnected: TNotifyEvent read FOnNetDisconnected write FOnNetDisconnected;
    property OnReplyLogin: TWRAXReplyLogin read FOnReplyLogin write FOnReplyLogin;
    property OnReplyFileDown: TWRAXReplyFileDown read FOnReplyFileDown write FOnReplyFileDown;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TWRAX.InitControlData;
const
  CEventDispIDs: array [0..5] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006);
  CControlData: TControlData2 = (
    ClassID: '{EC22F588-9228-43EA-8F8D-13C5FC2D5585}';
    EventIID: '{17467A5C-AC04-4084-89D9-4DF14FC4E825}';
    EventCount: 6;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnRecvData) - Cardinal(Self);
end;

procedure TWRAX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DWRAX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TWRAX.GetControlInterface: _DWRAX;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TWRAX.OConnectHost(const szIP: WideString; const szPort: WideString);
begin
  DefaultInterface.OConnectHost(szIP, szPort);
end;

procedure TWRAX.OCloseHost;
begin
  DefaultInterface.OCloseHost;
end;

procedure TWRAX.OLogin(const szUserID: WideString; const szPWD: WideString; 
                       const szCertPWD: WideString);
begin
  DefaultInterface.OLogin(szUserID, szPWD, szCertPWD);
end;

function TWRAX.ORequestData(const szTrName: WideString; nDataSize: Integer; 
                            const szData: WideString; bEncrypt: WordBool; bCompress: WordBool; 
                            nTimeOut: Smallint): Smallint;
begin
  Result := DefaultInterface.ORequestData(szTrName, nDataSize, szData, bEncrypt, bCompress, nTimeOut);
end;

function TWRAX.ORegistRealData(const szTrName: WideString; const szKeyCode: WideString): Smallint;
begin
  Result := DefaultInterface.ORegistRealData(szTrName, szKeyCode);
end;

function TWRAX.OUnregistRealData(nRealID: Smallint): WordBool;
begin
  Result := DefaultInterface.OUnregistRealData(nRealID);
end;

procedure TWRAX.OGetMasterFile(const szFileName: WideString);
begin
  DefaultInterface.OGetMasterFile(szFileName);
end;

function TWRAX.OSendNewOrder(const szAccNum: WideString; const szPassword: WideString; 
                             const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                             nFillType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                             nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendNewOrder(szAccNum, szPassword, szCode, nBuySell, nOrderType, 
                                           nFillType, nOrderQty, dOrderPx, nCustOrderKey);
end;

function TWRAX.OSendModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                              const szCode: WideString; nBuySell: Smallint; nOrderType: Smallint; 
                              nFillType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                              const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendModiOrder(szAccNum, szPassword, szCode, nBuySell, nOrderType, 
                                            nFillType, nOrderQty, dOrderPx, szOriOrdNum, 
                                            nCustOrderKey);
end;

function TWRAX.OSendCancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                const szCode: WideString; nBuySell: Smallint; nOrderQty: Smallint; 
                                const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendCancelOrder(szAccNum, szPassword, szCode, nBuySell, nOrderQty, 
                                              szOriOrdNum, nCustOrderKey);
end;

function TWRAX.OGet2KoreanStr(const szData: WideString): WideString;
begin
  Result := DefaultInterface.OGet2KoreanStr(szData);
end;

function TWRAX.OSendCMENewOrder(const szAccNum: WideString; const szPassword: WideString; 
                                const szCode: WideString; nBuySell: Smallint; nFillType: Smallint; 
                                nOrderQty: Smallint; dOrderPx: Double; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendCMENewOrder(szAccNum, szPassword, szCode, nBuySell, nFillType, 
                                              nOrderQty, dOrderPx, nCustOrderKey);
end;

function TWRAX.OSendCMECancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                   const szCode: WideString; nBuySell: Smallint; 
                                   const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendCMECancelOrder(szAccNum, szPassword, szCode, nBuySell, 
                                                 szOriOrdNum, nCustOrderKey);
end;

function TWRAX.OCopyToClipboard(const szInputData: WideString): WordBool;
begin
  Result := DefaultInterface.OCopyToClipboard(szInputData);
end;

function TWRAX.OIsLogined: WordBool;
begin
  Result := DefaultInterface.OIsLogined;
end;

function TWRAX.OSendCMEModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                                 const szCode: WideString; nBuySell: Smallint; dOrderPx: Double; 
                                 const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendCMEModiOrder(szAccNum, szPassword, szCode, nBuySell, dOrderPx, 
                                               szOriOrdNum, nCustOrderKey);
end;

procedure TWRAX.OClearAllCount;
begin
  DefaultInterface.OClearAllCount;
end;

function TWRAX.OGetJongMokInfo(nType: Smallint; const strItemCode: WideString): WideString;
begin
  Result := DefaultInterface.OGetJongMokInfo(nType, strItemCode);
end;

function TWRAX.OGetPLAmtByPx(const strItemCode: WideString; nTradeSect: Smallint; nQty: Smallint; 
                             dAvgPx: Double; dCurrentPx: Double): Double;
begin
  Result := DefaultInterface.OGetPLAmtByPx(strItemCode, nTradeSect, nQty, dAvgPx, dCurrentPx);
end;

function TWRAX.OGetPLAmtByAmt(const strItemCode: WideString; nTradeSect: Smallint; nQty: Smallint; 
                              dAvgAmt: Double; dCurrentPx: Double): Double;
begin
  Result := DefaultInterface.OGetPLAmtByAmt(strItemCode, nTradeSect, nQty, dAvgAmt, dCurrentPx);
end;

function TWRAX.ORegistRealDataToMainLib(const strRealTrCode: WideString; 
                                        const strKeyCode: WideString): Smallint;
begin
  Result := DefaultInterface.ORegistRealDataToMainLib(strRealTrCode, strKeyCode);
end;

function TWRAX.OUnregistRealDataToMainLib(nSBID: Smallint): WordBool;
begin
  Result := DefaultInterface.OUnregistRealDataToMainLib(nSBID);
end;

function TWRAX.OGetSiseDataFromMainLib(const strRealTrCode: WideString; 
                                       const strKeyCode: WideString; var bIsFirstGet: WordBool; 
                                       var strOutData: WideString): Integer;
begin
  Result := DefaultInterface.OGetSiseDataFromMainLib(strRealTrCode, strKeyCode, bIsFirstGet, 
                                                     strOutData);
end;

function TWRAX.OGetAccountInfCount: Smallint;
begin
  Result := DefaultInterface.OGetAccountInfCount;
end;

function TWRAX.OGetAccountInf(nIndex: Smallint; var pszAccountNo: WideString; 
                              var pszAccountName: WideString): Integer;
begin
  Result := DefaultInterface.OGetAccountInf(nIndex, pszAccountNo, pszAccountName);
end;

function TWRAX.OGetCMEAccountInfCount: Smallint;
begin
  Result := DefaultInterface.OGetCMEAccountInfCount;
end;

function TWRAX.OGetCMEAccountInf(nIndex: Smallint; var pszAccountNo: WideString; 
                                 var pszAccountName: WideString): Integer;
begin
  Result := DefaultInterface.OGetCMEAccountInf(nIndex, pszAccountNo, pszAccountName);
end;

function TWRAX.OSendEUREXNewOrder(const szAccNum: WideString; const szPassword: WideString; 
                                  const szCode: WideString; nBuySell: Smallint; 
                                  nOrderType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                                  nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendEUREXNewOrder(szAccNum, szPassword, szCode, nBuySell, nOrderType, 
                                                nOrderQty, dOrderPx, nCustOrderKey);
end;

function TWRAX.OSendEUREXModiOrder(const szAccNum: WideString; const szPassword: WideString; 
                                   const szCode: WideString; nBuySell: Smallint; 
                                   nOrderType: Smallint; nOrderQty: Smallint; dOrderPx: Double; 
                                   const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendEUREXModiOrder(szAccNum, szPassword, szCode, nBuySell, 
                                                 nOrderType, nOrderQty, dOrderPx, szOriOrdNum, 
                                                 nCustOrderKey);
end;

function TWRAX.OSendEUREXCancelOrder(const szAccNum: WideString; const szPassword: WideString; 
                                     const szCode: WideString; nBuySell: Smallint; 
                                     nOrdeType: Smallint; nOrderQty: Smallint; 
                                     const szOriOrdNum: WideString; nCustOrderKey: Smallint): WideString;
begin
  Result := DefaultInterface.OSendEUREXCancelOrder(szAccNum, szPassword, szCode, nBuySell, 
                                                   nOrdeType, nOrderQty, szOriOrdNum, nCustOrderKey);
end;

procedure TWRAX.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TWRAX]);
end;

end.
