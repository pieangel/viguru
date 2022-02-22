unit HDFCommAgentLib_TLB;

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
// File generated on 2022-01-20 오후 6:23:17 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\HDTrader\SmTrader\Debug\HDFCommAgent.ocx (1)
// LIBID: {5DC20B9D-628D-43E5-9A32-DAC6FCE7F0A4}
// LCID: 0
// Helpfile: D:\HDTrader\SmTrader\Debug\HDFCommAgent.hlp
// HelpString: HDFCommAgent ActiveX 컨트롤 모듈
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
  HDFCommAgentLibMajorVersion = 1;
  HDFCommAgentLibMinorVersion = 0;

  LIBID_HDFCommAgentLib: TGUID = '{5DC20B9D-628D-43E5-9A32-DAC6FCE7F0A4}';

  DIID__DHDFCommAgent: TGUID = '{7FAA7994-1808-46C4-9F2B-ADE5CF84B8BF}';
  DIID__DHDFCommAgentEvents: TGUID = '{84018D6A-BEEE-4719-8826-89D23825892F}';
  CLASS_HDFCommAgent: TGUID = '{2A7B5BEF-49EE-4219-9833-DB04D07876CF}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DHDFCommAgent = dispinterface;
  _DHDFCommAgentEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  HDFCommAgent = _DHDFCommAgent;


// *********************************************************************//
// DispIntf:  _DHDFCommAgent
// Flags:     (4096) Dispatchable
// GUID:      {7FAA7994-1808-46C4-9F2B-ADE5CF84B8BF}
// *********************************************************************//
  _DHDFCommAgent = dispinterface
    ['{7FAA7994-1808-46C4-9F2B-ADE5CF84B8BF}']
    procedure AboutBox; dispid -552;
    function CommInit(nType: Integer): Integer; dispid 1;
    procedure CommTerminate(bSocketClose: Integer); dispid 2;
    function CommLogin(const sUserID: WideString; const sPwd: WideString; const sCertPwd: WideString): Integer; dispid 3;
    function CommLogout(const sUserID: WideString): Integer; dispid 4;
    function CommRqData(const sTrCode: WideString; const sInputData: WideString; nLength: Integer; 
                        const sPrevOrNext: WideString): Integer; dispid 5;
    function CommSetBroad(const sJongmokCode: WideString; nRealType: Integer): Integer; dispid 6;
    function CommRemoveBroad(const sJongmokCode: WideString; nRealType: Integer): Integer; dispid 7;
    function CommGetRepeatCnt(const sJongmokCode: WideString; nRealType: Integer; 
                              const sFieldName: WideString): Integer; dispid 8;
    function CommGetData(const sJongmokCode: WideString; nRealType: Integer; 
                         const sFieldName: WideString; nIndex: Integer; 
                         const sInnerFieldName: WideString): WideString; dispid 9;
    function CommGetDataDirect(const sJongmokCode: WideString; nRealType: Integer; 
                               nOffset: Integer; nLength: Integer; nPointLength: Integer; 
                               const sDataType: WideString): WideString; dispid 10;
    function CommGetConnectState: Integer; dispid 11;
    function CommFIDRqData(const sFidCode: WideString; const sInputData: WideString; 
                           const sReqFidList: WideString; nLength: Integer; 
                           const sPrevOrNext: WideString): Integer; dispid 12;
    function CommSetJumunChe(const sUserID: WideString; const sAccNo: WideString): Integer; dispid 13;
    function CommRemoveJumunChe(const sUserID: WideString; const sAccNo: WideString): Integer; dispid 14;
    function CommJumunSvr(const sTrCode: WideString; const sInputData: WideString): Integer; dispid 15;
    function CommAccInfo: Integer; dispid 16;
    function CommMiCheFoForAcc(const sAcctNo: WideString; const sAcctPw: WideString): Integer; dispid 17;
    function Transact(hWnd: Integer; nTRID: Integer; const sTrCode: WideString; 
                      const sInput: WideString; nInput: Integer; nHeadType: Integer; 
                      nAccountIndex: Integer): Integer; dispid 18;
    function Attach(hWnd: Integer; const szBCType: WideString; const szInput: WideString; 
                    nCodeLen: Integer; nInputLen: Integer): Integer; dispid 19;
    function Detach(hWnd: Integer; const szBCType: WideString; const szInput: WideString; 
                    nCodeLen: Integer; nInputLen: Integer): Integer; dispid 20;
    function CommGetDealNo(const sAcctNo: WideString): WideString; dispid 21;
    function CommGetHWOrdPrice(const sSeries: WideString; const sPrice: WideString; nType: Integer): WideString; dispid 22;
    procedure CommSetOCXPath(const szOCXPath: WideString); dispid 23;
    procedure CommReqMstInfo(const szExchCd: WideString); dispid 24;
    function CommGetHWInfo(const sSeries: WideString; nInfo: Integer): WideString; dispid 25;
    function CommGetAccInfo: WideString; dispid 26;
    procedure CommReqMakeCod(const strParam: WideString; nMstType: Integer); dispid 27;
    function CommGetNextKey(nRqId: Integer; const sReserved: WideString): WideString; dispid 28;
    function CommGetBusinessDay(nJangubun: Integer): WideString; dispid 29;
    function CommGetInfo(const sTag: WideString; const sParam: WideString): WideString; dispid 30;
    function CommGetDataBinary(const sJongmokCode: WideString; nRealType: Integer; 
                               nOffset: Integer; nLength: Integer; nPointLength: Integer; 
                               const sDataType: WideString): OleVariant; dispid 31;
  end;

// *********************************************************************//
// DispIntf:  _DHDFCommAgentEvents
// Flags:     (4096) Dispatchable
// GUID:      {84018D6A-BEEE-4719-8826-89D23825892F}
// *********************************************************************//
  _DHDFCommAgentEvents = dispinterface
    ['{84018D6A-BEEE-4719-8826-89D23825892F}']
    procedure OnGetData(nType: Integer; wParam: Integer; lParam: Integer); dispid 1;
    procedure OnRealData(nType: Integer; wParam: Integer; lParam: Integer); dispid 2;
    procedure OnDataRecv(const sTrCode: WideString; nRqId: Integer); dispid 3;
    procedure OnGetBroadData(const sJongmokCode: WideString; nRealType: Integer); dispid 4;
    procedure OnGetMsg(const sCode: WideString; const sMsg: WideString); dispid 5;
    procedure OnGetMsgWithRqId(nRqId: Integer; const sCode: WideString; const sMsg: WideString); dispid 6;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : THDFCommAgent
// Help String      : HDFCommAgent Control
// Default Interface: _DHDFCommAgent
// Def. Intf. DISP? : Yes
// Event   Interface: _DHDFCommAgentEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  THDFCommAgentOnGetData = procedure(ASender: TObject; nType: Integer; wParam: Integer; 
                                                       lParam: Integer) of object;
  THDFCommAgentOnRealData = procedure(ASender: TObject; nType: Integer; wParam: Integer; 
                                                        lParam: Integer) of object;
  THDFCommAgentOnDataRecv = procedure(ASender: TObject; const sTrCode: WideString; nRqId: Integer) of object;
  THDFCommAgentOnGetBroadData = procedure(ASender: TObject; const sJongmokCode: WideString; 
                                                            nRealType: Integer) of object;
  THDFCommAgentOnGetMsg = procedure(ASender: TObject; const sCode: WideString; 
                                                      const sMsg: WideString) of object;
  THDFCommAgentOnGetMsgWithRqId = procedure(ASender: TObject; nRqId: Integer; 
                                                              const sCode: WideString; 
                                                              const sMsg: WideString) of object;

  THDFCommAgent = class(TOleControl)
  private
    FOnGetData: THDFCommAgentOnGetData;
    FOnRealData: THDFCommAgentOnRealData;
    FOnDataRecv: THDFCommAgentOnDataRecv;
    FOnGetBroadData: THDFCommAgentOnGetBroadData;
    FOnGetMsg: THDFCommAgentOnGetMsg;
    FOnGetMsgWithRqId: THDFCommAgentOnGetMsgWithRqId;
    FIntf: _DHDFCommAgent;
    function  GetControlInterface: _DHDFCommAgent;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure AboutBox;
    function CommInit(nType: Integer): Integer;
    procedure CommTerminate(bSocketClose: Integer);
    function CommLogin(const sUserID: WideString; const sPwd: WideString; const sCertPwd: WideString): Integer;
    function CommLogout(const sUserID: WideString): Integer;
    function CommRqData(const sTrCode: WideString; const sInputData: WideString; nLength: Integer; 
                        const sPrevOrNext: WideString): Integer;
    function CommSetBroad(const sJongmokCode: WideString; nRealType: Integer): Integer;
    function CommRemoveBroad(const sJongmokCode: WideString; nRealType: Integer): Integer;
    function CommGetRepeatCnt(const sJongmokCode: WideString; nRealType: Integer; 
                              const sFieldName: WideString): Integer;
    function CommGetData(const sJongmokCode: WideString; nRealType: Integer; 
                         const sFieldName: WideString; nIndex: Integer; 
                         const sInnerFieldName: WideString): WideString;
    function CommGetDataDirect(const sJongmokCode: WideString; nRealType: Integer; 
                               nOffset: Integer; nLength: Integer; nPointLength: Integer; 
                               const sDataType: WideString): WideString;
    function CommGetConnectState: Integer;
    function CommFIDRqData(const sFidCode: WideString; const sInputData: WideString; 
                           const sReqFidList: WideString; nLength: Integer; 
                           const sPrevOrNext: WideString): Integer;
    function CommSetJumunChe(const sUserID: WideString; const sAccNo: WideString): Integer;
    function CommRemoveJumunChe(const sUserID: WideString; const sAccNo: WideString): Integer;
    function CommJumunSvr(const sTrCode: WideString; const sInputData: WideString): Integer;
    function CommAccInfo: Integer;
    function CommMiCheFoForAcc(const sAcctNo: WideString; const sAcctPw: WideString): Integer;
    function Transact(hWnd: Integer; nTRID: Integer; const sTrCode: WideString; 
                      const sInput: WideString; nInput: Integer; nHeadType: Integer; 
                      nAccountIndex: Integer): Integer;
    function Attach(hWnd: Integer; const szBCType: WideString; const szInput: WideString; 
                    nCodeLen: Integer; nInputLen: Integer): Integer;
    function Detach(hWnd: Integer; const szBCType: WideString; const szInput: WideString; 
                    nCodeLen: Integer; nInputLen: Integer): Integer;
    function CommGetDealNo(const sAcctNo: WideString): WideString;
    function CommGetHWOrdPrice(const sSeries: WideString; const sPrice: WideString; nType: Integer): WideString;
    procedure CommSetOCXPath(const szOCXPath: WideString);
    procedure CommReqMstInfo(const szExchCd: WideString);
    function CommGetHWInfo(const sSeries: WideString; nInfo: Integer): WideString;
    function CommGetAccInfo: WideString;
    procedure CommReqMakeCod(const strParam: WideString; nMstType: Integer);
    function CommGetNextKey(nRqId: Integer; const sReserved: WideString): WideString;
    function CommGetBusinessDay(nJangubun: Integer): WideString;
    function CommGetInfo(const sTag: WideString; const sParam: WideString): WideString;
    function CommGetDataBinary(const sJongmokCode: WideString; nRealType: Integer; 
                               nOffset: Integer; nLength: Integer; nPointLength: Integer; 
                               const sDataType: WideString): OleVariant;
    property  ControlInterface: _DHDFCommAgent read GetControlInterface;
    property  DefaultInterface: _DHDFCommAgent read GetControlInterface;
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
    property OnGetData: THDFCommAgentOnGetData read FOnGetData write FOnGetData;
    property OnRealData: THDFCommAgentOnRealData read FOnRealData write FOnRealData;
    property OnDataRecv: THDFCommAgentOnDataRecv read FOnDataRecv write FOnDataRecv;
    property OnGetBroadData: THDFCommAgentOnGetBroadData read FOnGetBroadData write FOnGetBroadData;
    property OnGetMsg: THDFCommAgentOnGetMsg read FOnGetMsg write FOnGetMsg;
    property OnGetMsgWithRqId: THDFCommAgentOnGetMsgWithRqId read FOnGetMsgWithRqId write FOnGetMsgWithRqId;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure THDFCommAgent.InitControlData;
const
  CEventDispIDs: array [0..5] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006);
  CControlData: TControlData2 = (
    ClassID: '{2A7B5BEF-49EE-4219-9833-DB04D07876CF}';
    EventIID: '{84018D6A-BEEE-4719-8826-89D23825892F}';
    EventCount: 6;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnGetData) - Cardinal(Self);
end;

procedure THDFCommAgent.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DHDFCommAgent;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function THDFCommAgent.GetControlInterface: _DHDFCommAgent;
begin
  CreateControl;
  Result := FIntf;
end;

procedure THDFCommAgent.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

function THDFCommAgent.CommInit(nType: Integer): Integer;
begin
  Result := DefaultInterface.CommInit(nType);
end;

procedure THDFCommAgent.CommTerminate(bSocketClose: Integer);
begin
  DefaultInterface.CommTerminate(bSocketClose);
end;

function THDFCommAgent.CommLogin(const sUserID: WideString; const sPwd: WideString; 
                                 const sCertPwd: WideString): Integer;
begin
  Result := DefaultInterface.CommLogin(sUserID, sPwd, sCertPwd);
end;

function THDFCommAgent.CommLogout(const sUserID: WideString): Integer;
begin
  Result := DefaultInterface.CommLogout(sUserID);
end;

function THDFCommAgent.CommRqData(const sTrCode: WideString; const sInputData: WideString; 
                                  nLength: Integer; const sPrevOrNext: WideString): Integer;
begin
  Result := DefaultInterface.CommRqData(sTrCode, sInputData, nLength, sPrevOrNext);
end;

function THDFCommAgent.CommSetBroad(const sJongmokCode: WideString; nRealType: Integer): Integer;
begin
  Result := DefaultInterface.CommSetBroad(sJongmokCode, nRealType);
end;

function THDFCommAgent.CommRemoveBroad(const sJongmokCode: WideString; nRealType: Integer): Integer;
begin
  Result := DefaultInterface.CommRemoveBroad(sJongmokCode, nRealType);
end;

function THDFCommAgent.CommGetRepeatCnt(const sJongmokCode: WideString; nRealType: Integer; 
                                        const sFieldName: WideString): Integer;
begin
  Result := DefaultInterface.CommGetRepeatCnt(sJongmokCode, nRealType, sFieldName);
end;

function THDFCommAgent.CommGetData(const sJongmokCode: WideString; nRealType: Integer; 
                                   const sFieldName: WideString; nIndex: Integer; 
                                   const sInnerFieldName: WideString): WideString;
begin
  Result := DefaultInterface.CommGetData(sJongmokCode, nRealType, sFieldName, nIndex, 
                                         sInnerFieldName);
end;

function THDFCommAgent.CommGetDataDirect(const sJongmokCode: WideString; nRealType: Integer; 
                                         nOffset: Integer; nLength: Integer; nPointLength: Integer; 
                                         const sDataType: WideString): WideString;
begin
  Result := DefaultInterface.CommGetDataDirect(sJongmokCode, nRealType, nOffset, nLength, 
                                               nPointLength, sDataType);
end;

function THDFCommAgent.CommGetConnectState: Integer;
begin
  Result := DefaultInterface.CommGetConnectState;
end;

function THDFCommAgent.CommFIDRqData(const sFidCode: WideString; const sInputData: WideString; 
                                     const sReqFidList: WideString; nLength: Integer; 
                                     const sPrevOrNext: WideString): Integer;
begin
  Result := DefaultInterface.CommFIDRqData(sFidCode, sInputData, sReqFidList, nLength, sPrevOrNext);
end;

function THDFCommAgent.CommSetJumunChe(const sUserID: WideString; const sAccNo: WideString): Integer;
begin
  Result := DefaultInterface.CommSetJumunChe(sUserID, sAccNo);
end;

function THDFCommAgent.CommRemoveJumunChe(const sUserID: WideString; const sAccNo: WideString): Integer;
begin
  Result := DefaultInterface.CommRemoveJumunChe(sUserID, sAccNo);
end;

function THDFCommAgent.CommJumunSvr(const sTrCode: WideString; const sInputData: WideString): Integer;
begin
  Result := DefaultInterface.CommJumunSvr(sTrCode, sInputData);
end;

function THDFCommAgent.CommAccInfo: Integer;
begin
  Result := DefaultInterface.CommAccInfo;
end;

function THDFCommAgent.CommMiCheFoForAcc(const sAcctNo: WideString; const sAcctPw: WideString): Integer;
begin
  Result := DefaultInterface.CommMiCheFoForAcc(sAcctNo, sAcctPw);
end;

function THDFCommAgent.Transact(hWnd: Integer; nTRID: Integer; const sTrCode: WideString; 
                                const sInput: WideString; nInput: Integer; nHeadType: Integer; 
                                nAccountIndex: Integer): Integer;
begin
  Result := DefaultInterface.Transact(hWnd, nTRID, sTrCode, sInput, nInput, nHeadType, nAccountIndex);
end;

function THDFCommAgent.Attach(hWnd: Integer; const szBCType: WideString; const szInput: WideString; 
                              nCodeLen: Integer; nInputLen: Integer): Integer;
begin
  Result := DefaultInterface.Attach(hWnd, szBCType, szInput, nCodeLen, nInputLen);
end;

function THDFCommAgent.Detach(hWnd: Integer; const szBCType: WideString; const szInput: WideString; 
                              nCodeLen: Integer; nInputLen: Integer): Integer;
begin
  Result := DefaultInterface.Detach(hWnd, szBCType, szInput, nCodeLen, nInputLen);
end;

function THDFCommAgent.CommGetDealNo(const sAcctNo: WideString): WideString;
begin
  Result := DefaultInterface.CommGetDealNo(sAcctNo);
end;

function THDFCommAgent.CommGetHWOrdPrice(const sSeries: WideString; const sPrice: WideString; 
                                         nType: Integer): WideString;
begin
  Result := DefaultInterface.CommGetHWOrdPrice(sSeries, sPrice, nType);
end;

procedure THDFCommAgent.CommSetOCXPath(const szOCXPath: WideString);
begin
  DefaultInterface.CommSetOCXPath(szOCXPath);
end;

procedure THDFCommAgent.CommReqMstInfo(const szExchCd: WideString);
begin
  DefaultInterface.CommReqMstInfo(szExchCd);
end;

function THDFCommAgent.CommGetHWInfo(const sSeries: WideString; nInfo: Integer): WideString;
begin
  Result := DefaultInterface.CommGetHWInfo(sSeries, nInfo);
end;

function THDFCommAgent.CommGetAccInfo: WideString;
begin
  Result := DefaultInterface.CommGetAccInfo;
end;

procedure THDFCommAgent.CommReqMakeCod(const strParam: WideString; nMstType: Integer);
begin
  DefaultInterface.CommReqMakeCod(strParam, nMstType);
end;

function THDFCommAgent.CommGetNextKey(nRqId: Integer; const sReserved: WideString): WideString;
begin
  Result := DefaultInterface.CommGetNextKey(nRqId, sReserved);
end;

function THDFCommAgent.CommGetBusinessDay(nJangubun: Integer): WideString;
begin
  Result := DefaultInterface.CommGetBusinessDay(nJangubun);
end;

function THDFCommAgent.CommGetInfo(const sTag: WideString; const sParam: WideString): WideString;
begin
  Result := DefaultInterface.CommGetInfo(sTag, sParam);
end;

function THDFCommAgent.CommGetDataBinary(const sJongmokCode: WideString; nRealType: Integer; 
                                         nOffset: Integer; nLength: Integer; nPointLength: Integer; 
                                         const sDataType: WideString): OleVariant;
begin
  Result := DefaultInterface.CommGetDataBinary(sJongmokCode, nRealType, nOffset, nLength, 
                                               nPointLength, sDataType);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [THDFCommAgent]);
end;

end.
