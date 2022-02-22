unit ESINApiExpLib_TLB;

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
// File generated on 2016-06-10 ¿ÀÀü 9:18:23 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\KrApi\_bin\ESINApiExp.ocx (1)
// LIBID: {7A8A3580-CBC9-497E-99F1-A017E5A67514}
// LCID: 0
// Helpfile: 
// HelpString: 
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
  ESINApiExpLibMajorVersion = 1;
  ESINApiExpLibMinorVersion = 0;

  LIBID_ESINApiExpLib: TGUID = '{7A8A3580-CBC9-497E-99F1-A017E5A67514}';

  DIID__DESINApiExp: TGUID = '{959D3682-5222-4487-935E-D288F2378FD3}';
  DIID__DESINApiExpEvents: TGUID = '{E0075B3E-4937-4A1C-A4D2-2FD0A538529F}';
  CLASS_ESINApiExp: TGUID = '{4A5E53B0-A8DD-495D-9816-808DC64761AC}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DESINApiExp = dispinterface;
  _DESINApiExpEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ESINApiExp = _DESINApiExp;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PByte1 = ^Byte; {*}


// *********************************************************************//
// DispIntf:  _DESINApiExp
// Flags:     (4096) Dispatchable
// GUID:      {959D3682-5222-4487-935E-D288F2378FD3}
// *********************************************************************//
  _DESINApiExp = dispinterface
    ['{959D3682-5222-4487-935E-D288F2378FD3}']
    function ESExpIsServerConnect: {??Shortint}OleVariant; dispid 1;
    procedure ESExpDisConnectServer; dispid 2;
    function ESExpConnectServer(const szUserID: WideString; const szPasswd: WideString; 
                                const szCertPasswd: WideString; nSvrKind: Smallint): Integer; dispid 3;
    function ESExpGetCommunicationType: WideString; dispid 4;
    function ESExpGetFullCode(const szShortCode: WideString): WideString; dispid 5;
    function ESExpGetCodeIndex(const szShortCode: WideString): WideString; dispid 6;
    function ESExpGetEncodePassword(const szAcct: WideString; const szSrcPass: WideString): WideString; dispid 7;
    function ESExpSendTrData(nTrCode: Smallint; const lpszData: WideString; nLen: Smallint): Integer; dispid 8;
    function ESExpSetAutoUpdate(bSet: {??Shortint}OleVariant; bAccount: {??Shortint}OleVariant; 
                                const szAutoKey: WideString): Integer; dispid 9;
    function ESExpGetShortCode(const szFullCode: WideString): WideString; dispid 10;
    function ESExpApiFilePath(const szFilePath: WideString): {??Shortint}OleVariant; dispid 11;
    function ESExpGetLocalIpAddress: WideString; dispid 12;
    function ESExpGetAssetsID(const szCode: WideString): WideString; dispid 13;
    function ESExpGetDecimalPrice(const szCode: WideString): WideString; dispid 14;
    function ESExpSetUseStaffMode(bValid: {??Shortint}OleVariant): {??Shortint}OleVariant; dispid 15;
    function ESExpGetCurrentDate: WideString; dispid 16;
  end;

// *********************************************************************//
// DispIntf:  _DESINApiExpEvents
// Flags:     (4096) Dispatchable
// GUID:      {E0075B3E-4937-4A1C-A4D2-2FD0A538529F}
// *********************************************************************//
  _DESINApiExpEvents = dispinterface
    ['{E0075B3E-4937-4A1C-A4D2-2FD0A538529F}']
    procedure ESExpServerConnect(nErrCode: Smallint; const strMessage: WideString); dispid 1;
    procedure ESExpServerDisConnect; dispid 2;
    procedure ESExpRecvData(nTrCode: Smallint; const szRecvData: WideString); dispid 3;
    procedure ESExpAcctList(nListCount: Smallint; const szAcctData: WideString); dispid 4;
    procedure ESExpCodeList(nListCount: Smallint; const szCodeData: WideString); dispid 5;
    procedure ESExpAcctListByte(nListCount: Smallint; var szAcctData: Byte); dispid 6;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TESINApiExp
// Help String      : 
// Default Interface: _DESINApiExp
// Def. Intf. DISP? : Yes
// Event   Interface: _DESINApiExpEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TESINApiExpESExpServerConnect = procedure(ASender: TObject; nErrCode: Smallint; 
                                                              const strMessage: WideString) of object;
  TESINApiExpESExpRecvData = procedure(ASender: TObject; nTrCode: Smallint; 
                                                         const szRecvData: WideString) of object;
  TESINApiExpESExpAcctList = procedure(ASender: TObject; nListCount: Smallint; 
                                                         const szAcctData: WideString) of object;
  TESINApiExpESExpCodeList = procedure(ASender: TObject; nListCount: Smallint; 
                                                         const szCodeData: WideString) of object;
  TESINApiExpESExpAcctListByte = procedure(ASender: TObject; nListCount: Smallint; 
                                                             var szAcctData: Byte) of object;

  TESINApiExp = class(TOleControl)
  private
    FOnESExpServerConnect: TESINApiExpESExpServerConnect;
    FOnESExpServerDisConnect: TNotifyEvent;
    FOnESExpRecvData: TESINApiExpESExpRecvData;
    FOnESExpAcctList: TESINApiExpESExpAcctList;
    FOnESExpCodeList: TESINApiExpESExpCodeList;
    FOnESExpAcctListByte: TESINApiExpESExpAcctListByte;
    FIntf: _DESINApiExp;
    function  GetControlInterface: _DESINApiExp;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function ESExpIsServerConnect: {??Shortint}OleVariant;
    procedure ESExpDisConnectServer;
    function ESExpConnectServer(const szUserID: WideString; const szPasswd: WideString; 
                                const szCertPasswd: WideString; nSvrKind: Smallint): Integer;
    function ESExpGetCommunicationType: WideString;
    function ESExpGetFullCode(const szShortCode: WideString): WideString;
    function ESExpGetCodeIndex(const szShortCode: WideString): WideString;
    function ESExpGetEncodePassword(const szAcct: WideString; const szSrcPass: WideString): WideString;
    function ESExpSendTrData(nTrCode: Smallint; const lpszData: WideString; nLen: Smallint): Integer;
    function ESExpSetAutoUpdate(bSet: {??Shortint}OleVariant; bAccount: {??Shortint}OleVariant; 
                                const szAutoKey: WideString): Integer;
    function ESExpGetShortCode(const szFullCode: WideString): WideString;
    function ESExpApiFilePath(const szFilePath: WideString): {??Shortint}OleVariant;
    function ESExpGetLocalIpAddress: WideString;
    function ESExpGetAssetsID(const szCode: WideString): WideString;
    function ESExpGetDecimalPrice(const szCode: WideString): WideString;
    function ESExpSetUseStaffMode(bValid: {??Shortint}OleVariant): {??Shortint}OleVariant;
    function ESExpGetCurrentDate: WideString;
    property  ControlInterface: _DESINApiExp read GetControlInterface;
    property  DefaultInterface: _DESINApiExp read GetControlInterface;
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
    property OnESExpServerConnect: TESINApiExpESExpServerConnect read FOnESExpServerConnect write FOnESExpServerConnect;
    property OnESExpServerDisConnect: TNotifyEvent read FOnESExpServerDisConnect write FOnESExpServerDisConnect;
    property OnESExpRecvData: TESINApiExpESExpRecvData read FOnESExpRecvData write FOnESExpRecvData;
    property OnESExpAcctList: TESINApiExpESExpAcctList read FOnESExpAcctList write FOnESExpAcctList;
    property OnESExpCodeList: TESINApiExpESExpCodeList read FOnESExpCodeList write FOnESExpCodeList;
    property OnESExpAcctListByte: TESINApiExpESExpAcctListByte read FOnESExpAcctListByte write FOnESExpAcctListByte;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TESINApiExp.InitControlData;
const
  CEventDispIDs: array [0..5] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006);
  CControlData: TControlData2 = (
    ClassID: '{4A5E53B0-A8DD-495D-9816-808DC64761AC}';
    EventIID: '{E0075B3E-4937-4A1C-A4D2-2FD0A538529F}';
    EventCount: 6;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnESExpServerConnect) - Cardinal(Self);
end;

procedure TESINApiExp.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DESINApiExp;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TESINApiExp.GetControlInterface: _DESINApiExp;
begin
  CreateControl;
  Result := FIntf;
end;

function TESINApiExp.ESExpIsServerConnect: {??Shortint}OleVariant;
begin
  Result := DefaultInterface.ESExpIsServerConnect;
end;

procedure TESINApiExp.ESExpDisConnectServer;
begin
  DefaultInterface.ESExpDisConnectServer;
end;

function TESINApiExp.ESExpConnectServer(const szUserID: WideString; const szPasswd: WideString; 
                                        const szCertPasswd: WideString; nSvrKind: Smallint): Integer;
begin
  Result := DefaultInterface.ESExpConnectServer(szUserID, szPasswd, szCertPasswd, nSvrKind);
end;

function TESINApiExp.ESExpGetCommunicationType: WideString;
begin
  Result := DefaultInterface.ESExpGetCommunicationType;
end;

function TESINApiExp.ESExpGetFullCode(const szShortCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetFullCode(szShortCode);
end;

function TESINApiExp.ESExpGetCodeIndex(const szShortCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetCodeIndex(szShortCode);
end;

function TESINApiExp.ESExpGetEncodePassword(const szAcct: WideString; const szSrcPass: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetEncodePassword(szAcct, szSrcPass);
end;

function TESINApiExp.ESExpSendTrData(nTrCode: Smallint; const lpszData: WideString; nLen: Smallint): Integer;
begin
  Result := DefaultInterface.ESExpSendTrData(nTrCode, lpszData, nLen);
end;

function TESINApiExp.ESExpSetAutoUpdate(bSet: {??Shortint}OleVariant; 
                                        bAccount: {??Shortint}OleVariant; 
                                        const szAutoKey: WideString): Integer;
begin
  Result := DefaultInterface.ESExpSetAutoUpdate(bSet, bAccount, szAutoKey);
end;

function TESINApiExp.ESExpGetShortCode(const szFullCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetShortCode(szFullCode);
end;

function TESINApiExp.ESExpApiFilePath(const szFilePath: WideString): {??Shortint}OleVariant;
begin
  Result := DefaultInterface.ESExpApiFilePath(szFilePath);
end;

function TESINApiExp.ESExpGetLocalIpAddress: WideString;
begin
  Result := DefaultInterface.ESExpGetLocalIpAddress;
end;

function TESINApiExp.ESExpGetAssetsID(const szCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetAssetsID(szCode);
end;

function TESINApiExp.ESExpGetDecimalPrice(const szCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetDecimalPrice(szCode);
end;

function TESINApiExp.ESExpSetUseStaffMode(bValid: {??Shortint}OleVariant): {??Shortint}OleVariant;
begin
  Result := DefaultInterface.ESExpSetUseStaffMode(bValid);
end;

function TESINApiExp.ESExpGetCurrentDate: WideString;
begin
  Result := DefaultInterface.ESExpGetCurrentDate;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TESINApiExp]);
end;

end.
