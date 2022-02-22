unit DONGBUAPILib_TLB;

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
// File generated on 2016-08-22 오후 2:02:41 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Guru\DongBuApi국내\DongbuAPI.ocx (1)
// LIBID: {018DA320-99C5-4BEE-B201-A049156D00C8}
// LCID: 0
// Helpfile: C:\Guru\DongBuApi국내\DongbuAPI.hlp
// HelpString: DongbuAPI ActiveX Control module
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
  DONGBUAPILibMajorVersion = 1;
  DONGBUAPILibMinorVersion = 0;

  LIBID_DONGBUAPILib: TGUID = '{018DA320-99C5-4BEE-B201-A049156D00C8}';

  DIID__DDongbuAPI: TGUID = '{63C4180E-728A-4E7E-9EEE-61D150371281}';
  DIID__DDongbuAPIEvents: TGUID = '{E85EDE65-E562-4751-A2EA-A6DF268B65B6}';
  CLASS_DongbuAPI: TGUID = '{57C10372-7EF1-4794-B88B-D05146F3A273}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DDongbuAPI = dispinterface;
  _DDongbuAPIEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  DongbuAPI = _DDongbuAPI;


// *********************************************************************//
// DispIntf:  _DDongbuAPI
// Flags:     (4112) Hidden Dispatchable
// GUID:      {63C4180E-728A-4E7E-9EEE-61D150371281}
// *********************************************************************//
  _DDongbuAPI = dispinterface
    ['{63C4180E-728A-4E7E-9EEE-61D150371281}']
    function CreateDongbuAPICtrl(const szUserName: WideString; lMultiConn: Integer; hWnd: Integer): WordBool; dispid 1;
    function InitCtrl(hDongbuApi: Integer; hWnd: Integer): WordBool; dispid 2;
    function Login(const szID: WideString; const szPW: WideString; const szCertPW: WideString; 
                   lShowLogInDlg: Integer): WordBool; dispid 3;
    function Logout: WordBool; dispid 4;
    function GetAccountList(lType: Integer): WideString; dispid 5;
    function SendFOrder(nClientKey: Integer; const szAcctNo: WideString; 
                        const szAcctPW: WideString; nOrdSect: Integer; 
                        const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                        nPrice: Integer; nOrgOrdNo: Integer): WordBool; dispid 6;
    function SendSOrder(nClientKey: Integer; const szAcctNo: WideString; 
                        const szAcctPW: WideString; nOrdSect: Integer; 
                        const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                        nPrice: Integer; nOrgOrdNo: Integer): WordBool; dispid 7;
    function ReqJango(const szAcctNo: WideString): WordBool; dispid 8;
    function ReqChegyul(const szAcctNo: WideString; const szAcctPW: WideString; 
                        const szSort: WideString): WordBool; dispid 9;
    function ReqEval(const szAcctNo: WideString; const szAcctPW: WideString; 
                     const szDate: WideString): WordBool; dispid 10;
    function ReqFeeNAbleMoney(const szAcctNo: WideString; const szAcctPW: WideString; 
                              const szDate: WideString): WordBool; dispid 11;
    function ReqAbleQty(const szAcctNo: WideString; const szAcctPW: WideString; 
                        const szItemCode: WideString; nGB: Integer; nPrice: Integer; 
                        const szOrdprcPtnCode: WideString): WordBool; dispid 12;
    function ReqDepositByOptionItem(const szItemCode: WideString; const szBaseAsset: WideString; 
                                    const szMonth: WideString; const szNextKey: WideString): WordBool; dispid 13;
    function ReqRealtimeData(nAdvice: Integer; const szID: WideString; const szData: WideString): WordBool; dispid 14;
    function ReqStockJango(const szAcctNo: WideString; const szNextKey: WideString): WordBool; dispid 15;
    function ReqStockChegyul(const szAcctNo: WideString; const szGB: WideString; 
                             const szNextKey: WideString): WordBool; dispid 16;
    function ReqStockEval(const szAcctNo: WideString; const szAcctPW: WideString): WordBool; dispid 17;
    function SendCmeOrder(nClientKey: Integer; const bstrAcctNo: WideString; 
                          const bstrAcctPW: WideString; nOrdSect: Integer; 
                          const bstrItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                          nPrice: Integer; nOrgOrdNo: Integer): WordBool; dispid 18;
    function ReqCmeJango(const bstrAcctNo: WideString): WordBool; dispid 19;
    function ReqCmeChegyul(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                           const bstrSort: WideString): WordBool; dispid 20;
    function ReqCmeMiche(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                         const bstrSort: WideString): WordBool; dispid 21;
    function ReqCmeEval(const bstrAcctNo: WideString; const bstrAcctPW: WideString): WordBool; dispid 22;
    function ReqCmeQty(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                       const bstrItemCode: WideString; nGB: Integer; nPrice: Integer; 
                       const bstrOrdprcPtnCode: WideString): WordBool; dispid 23;
    function ReqStockHoga(const szCode: WideString): WordBool; dispid 24;
    function SendSOrderCredit(nClientKey: Integer; const szAcctNo: WideString; 
                              const szAcctPW: WideString; nOrdSect: Integer; 
                              const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                              nPrice: Integer; nOrgOrdNo: Integer; const szLoanDate: WideString; 
                              const szCreditGb: WideString): WordBool; dispid 25;
    function ReqTodayInvestors(nMarketType: Integer; nInvestorType: Integer; 
                               const szItemCode: WideString; nSort: Integer; nNextGB: Integer; 
                               const szNextKey: WideString): WordBool; dispid 26;
    function ReqStockAbleQty(const szAcctNo: WideString; const szAcctPW: WideString; 
                             const szItemCode: WideString; nGB: Integer; nPrice: Integer): WordBool; dispid 27;
    procedure AboutBox; dispid -552;
  end;

// *********************************************************************//
// DispIntf:  _DDongbuAPIEvents
// Flags:     (4096) Dispatchable
// GUID:      {E85EDE65-E562-4751-A2EA-A6DF268B65B6}
// *********************************************************************//
  _DDongbuAPIEvents = dispinterface
    ['{E85EDE65-E562-4751-A2EA-A6DF268B65B6}']
    procedure ReceiveData(nReqID: Integer; const szMsgCode: WideString; const szMsg: WideString; 
                          const szData: WideString); dispid 1;
    procedure ReceiveRTData(const szName: WideString; const szField: WideString; 
                            const szData: WideString); dispid 2;
    procedure Connected(hDongbuApi: Integer); dispid 3;
    procedure Disconnected; dispid 4;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TDongbuAPI
// Help String      : DongbuAPI Control
// Default Interface: _DDongbuAPI
// Def. Intf. DISP? : Yes
// Event   Interface: _DDongbuAPIEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TDongbuAPIReceiveData = procedure(ASender: TObject; nReqID: Integer; const szMsgCode: WideString; 
                                                      const szMsg: WideString; 
                                                      const szData: WideString) of object;
  TDongbuAPIReceiveRTData = procedure(ASender: TObject; const szName: WideString; 
                                                        const szField: WideString; 
                                                        const szData: WideString) of object;
  TDongbuAPIConnected = procedure(ASender: TObject; hDongbuApi: Integer) of object;

  TDongbuAPI = class(TOleControl)
  private
    FOnReceiveData: TDongbuAPIReceiveData;
    FOnReceiveRTData: TDongbuAPIReceiveRTData;
    FOnConnected: TDongbuAPIConnected;
    FOnDisconnected: TNotifyEvent;
    FIntf: _DDongbuAPI;
    function  GetControlInterface: _DDongbuAPI;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function CreateDongbuAPICtrl(const szUserName: WideString; lMultiConn: Integer; hWnd: Integer): WordBool;
    function InitCtrl(hDongbuApi: Integer; hWnd: Integer): WordBool;
    function Login(const szID: WideString; const szPW: WideString; const szCertPW: WideString; 
                   lShowLogInDlg: Integer): WordBool;
    function Logout: WordBool;
    function GetAccountList(lType: Integer): WideString;
    function SendFOrder(nClientKey: Integer; const szAcctNo: WideString; 
                        const szAcctPW: WideString; nOrdSect: Integer; 
                        const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                        nPrice: Integer; nOrgOrdNo: Integer): WordBool;
    function SendSOrder(nClientKey: Integer; const szAcctNo: WideString; 
                        const szAcctPW: WideString; nOrdSect: Integer; 
                        const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                        nPrice: Integer; nOrgOrdNo: Integer): WordBool;
    function ReqJango(const szAcctNo: WideString): WordBool;
    function ReqChegyul(const szAcctNo: WideString; const szAcctPW: WideString; 
                        const szSort: WideString): WordBool;
    function ReqEval(const szAcctNo: WideString; const szAcctPW: WideString; 
                     const szDate: WideString): WordBool;
    function ReqFeeNAbleMoney(const szAcctNo: WideString; const szAcctPW: WideString; 
                              const szDate: WideString): WordBool;
    function ReqAbleQty(const szAcctNo: WideString; const szAcctPW: WideString; 
                        const szItemCode: WideString; nGB: Integer; nPrice: Integer; 
                        const szOrdprcPtnCode: WideString): WordBool;
    function ReqDepositByOptionItem(const szItemCode: WideString; const szBaseAsset: WideString; 
                                    const szMonth: WideString; const szNextKey: WideString): WordBool;
    function ReqRealtimeData(nAdvice: Integer; const szID: WideString; const szData: WideString): WordBool;
    function ReqStockJango(const szAcctNo: WideString; const szNextKey: WideString): WordBool;
    function ReqStockChegyul(const szAcctNo: WideString; const szGB: WideString; 
                             const szNextKey: WideString): WordBool;
    function ReqStockEval(const szAcctNo: WideString; const szAcctPW: WideString): WordBool;
    function SendCmeOrder(nClientKey: Integer; const bstrAcctNo: WideString; 
                          const bstrAcctPW: WideString; nOrdSect: Integer; 
                          const bstrItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                          nPrice: Integer; nOrgOrdNo: Integer): WordBool;
    function ReqCmeJango(const bstrAcctNo: WideString): WordBool;
    function ReqCmeChegyul(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                           const bstrSort: WideString): WordBool;
    function ReqCmeMiche(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                         const bstrSort: WideString): WordBool;
    function ReqCmeEval(const bstrAcctNo: WideString; const bstrAcctPW: WideString): WordBool;
    function ReqCmeQty(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                       const bstrItemCode: WideString; nGB: Integer; nPrice: Integer; 
                       const bstrOrdprcPtnCode: WideString): WordBool;
    function ReqStockHoga(const szCode: WideString): WordBool;
    function SendSOrderCredit(nClientKey: Integer; const szAcctNo: WideString; 
                              const szAcctPW: WideString; nOrdSect: Integer; 
                              const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                              nPrice: Integer; nOrgOrdNo: Integer; const szLoanDate: WideString; 
                              const szCreditGb: WideString): WordBool;
    function ReqTodayInvestors(nMarketType: Integer; nInvestorType: Integer; 
                               const szItemCode: WideString; nSort: Integer; nNextGB: Integer; 
                               const szNextKey: WideString): WordBool;
    function ReqStockAbleQty(const szAcctNo: WideString; const szAcctPW: WideString; 
                             const szItemCode: WideString; nGB: Integer; nPrice: Integer): WordBool;
    procedure AboutBox;
    property  ControlInterface: _DDongbuAPI read GetControlInterface;
    property  DefaultInterface: _DDongbuAPI read GetControlInterface;
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
    property OnReceiveData: TDongbuAPIReceiveData read FOnReceiveData write FOnReceiveData;
    property OnReceiveRTData: TDongbuAPIReceiveRTData read FOnReceiveRTData write FOnReceiveRTData;
    property OnConnected: TDongbuAPIConnected read FOnConnected write FOnConnected;
    property OnDisconnected: TNotifyEvent read FOnDisconnected write FOnDisconnected;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TDongbuAPI.InitControlData;
const
  CEventDispIDs: array [0..3] of DWORD = (
    $00000001, $00000002, $00000003, $00000004);
  CControlData: TControlData2 = (
    ClassID: '{57C10372-7EF1-4794-B88B-D05146F3A273}';
    EventIID: '{E85EDE65-E562-4751-A2EA-A6DF268B65B6}';
    EventCount: 4;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnReceiveData) - Cardinal(Self);
end;

procedure TDongbuAPI.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DDongbuAPI;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDongbuAPI.GetControlInterface: _DDongbuAPI;
begin
  CreateControl;
  Result := FIntf;
end;

function TDongbuAPI.CreateDongbuAPICtrl(const szUserName: WideString; lMultiConn: Integer; 
                                        hWnd: Integer): WordBool;
begin
  Result := DefaultInterface.CreateDongbuAPICtrl(szUserName, lMultiConn, hWnd);
end;

function TDongbuAPI.InitCtrl(hDongbuApi: Integer; hWnd: Integer): WordBool;
begin
  Result := DefaultInterface.InitCtrl(hDongbuApi, hWnd);
end;

function TDongbuAPI.Login(const szID: WideString; const szPW: WideString; 
                          const szCertPW: WideString; lShowLogInDlg: Integer): WordBool;
begin
  Result := DefaultInterface.Login(szID, szPW, szCertPW, lShowLogInDlg);
end;

function TDongbuAPI.Logout: WordBool;
begin
  Result := DefaultInterface.Logout;
end;

function TDongbuAPI.GetAccountList(lType: Integer): WideString;
begin
  Result := DefaultInterface.GetAccountList(lType);
end;

function TDongbuAPI.SendFOrder(nClientKey: Integer; const szAcctNo: WideString; 
                               const szAcctPW: WideString; nOrdSect: Integer; 
                               const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                               nPrice: Integer; nOrgOrdNo: Integer): WordBool;
begin
  Result := DefaultInterface.SendFOrder(nClientKey, szAcctNo, szAcctPW, nOrdSect, szItemCode, 
                                        nPriceType, nQty, nPrice, nOrgOrdNo);
end;

function TDongbuAPI.SendSOrder(nClientKey: Integer; const szAcctNo: WideString; 
                               const szAcctPW: WideString; nOrdSect: Integer; 
                               const szItemCode: WideString; nPriceType: Integer; nQty: Integer; 
                               nPrice: Integer; nOrgOrdNo: Integer): WordBool;
begin
  Result := DefaultInterface.SendSOrder(nClientKey, szAcctNo, szAcctPW, nOrdSect, szItemCode, 
                                        nPriceType, nQty, nPrice, nOrgOrdNo);
end;

function TDongbuAPI.ReqJango(const szAcctNo: WideString): WordBool;
begin
  Result := DefaultInterface.ReqJango(szAcctNo);
end;

function TDongbuAPI.ReqChegyul(const szAcctNo: WideString; const szAcctPW: WideString; 
                               const szSort: WideString): WordBool;
begin
  Result := DefaultInterface.ReqChegyul(szAcctNo, szAcctPW, szSort);
end;

function TDongbuAPI.ReqEval(const szAcctNo: WideString; const szAcctPW: WideString; 
                            const szDate: WideString): WordBool;
begin
  Result := DefaultInterface.ReqEval(szAcctNo, szAcctPW, szDate);
end;

function TDongbuAPI.ReqFeeNAbleMoney(const szAcctNo: WideString; const szAcctPW: WideString; 
                                     const szDate: WideString): WordBool;
begin
  Result := DefaultInterface.ReqFeeNAbleMoney(szAcctNo, szAcctPW, szDate);
end;

function TDongbuAPI.ReqAbleQty(const szAcctNo: WideString; const szAcctPW: WideString; 
                               const szItemCode: WideString; nGB: Integer; nPrice: Integer; 
                               const szOrdprcPtnCode: WideString): WordBool;
begin
  Result := DefaultInterface.ReqAbleQty(szAcctNo, szAcctPW, szItemCode, nGB, nPrice, szOrdprcPtnCode);
end;

function TDongbuAPI.ReqDepositByOptionItem(const szItemCode: WideString; 
                                           const szBaseAsset: WideString; 
                                           const szMonth: WideString; const szNextKey: WideString): WordBool;
begin
  Result := DefaultInterface.ReqDepositByOptionItem(szItemCode, szBaseAsset, szMonth, szNextKey);
end;

function TDongbuAPI.ReqRealtimeData(nAdvice: Integer; const szID: WideString; 
                                    const szData: WideString): WordBool;
begin
  Result := DefaultInterface.ReqRealtimeData(nAdvice, szID, szData);
end;

function TDongbuAPI.ReqStockJango(const szAcctNo: WideString; const szNextKey: WideString): WordBool;
begin
  Result := DefaultInterface.ReqStockJango(szAcctNo, szNextKey);
end;

function TDongbuAPI.ReqStockChegyul(const szAcctNo: WideString; const szGB: WideString; 
                                    const szNextKey: WideString): WordBool;
begin
  Result := DefaultInterface.ReqStockChegyul(szAcctNo, szGB, szNextKey);
end;

function TDongbuAPI.ReqStockEval(const szAcctNo: WideString; const szAcctPW: WideString): WordBool;
begin
  Result := DefaultInterface.ReqStockEval(szAcctNo, szAcctPW);
end;

function TDongbuAPI.SendCmeOrder(nClientKey: Integer; const bstrAcctNo: WideString; 
                                 const bstrAcctPW: WideString; nOrdSect: Integer; 
                                 const bstrItemCode: WideString; nPriceType: Integer; 
                                 nQty: Integer; nPrice: Integer; nOrgOrdNo: Integer): WordBool;
begin
  Result := DefaultInterface.SendCmeOrder(nClientKey, bstrAcctNo, bstrAcctPW, nOrdSect, 
                                          bstrItemCode, nPriceType, nQty, nPrice, nOrgOrdNo);
end;

function TDongbuAPI.ReqCmeJango(const bstrAcctNo: WideString): WordBool;
begin
  Result := DefaultInterface.ReqCmeJango(bstrAcctNo);
end;

function TDongbuAPI.ReqCmeChegyul(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                                  const bstrSort: WideString): WordBool;
begin
  Result := DefaultInterface.ReqCmeChegyul(bstrAcctNo, bstrAcctPW, bstrSort);
end;

function TDongbuAPI.ReqCmeMiche(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                                const bstrSort: WideString): WordBool;
begin
  Result := DefaultInterface.ReqCmeMiche(bstrAcctNo, bstrAcctPW, bstrSort);
end;

function TDongbuAPI.ReqCmeEval(const bstrAcctNo: WideString; const bstrAcctPW: WideString): WordBool;
begin
  Result := DefaultInterface.ReqCmeEval(bstrAcctNo, bstrAcctPW);
end;

function TDongbuAPI.ReqCmeQty(const bstrAcctNo: WideString; const bstrAcctPW: WideString; 
                              const bstrItemCode: WideString; nGB: Integer; nPrice: Integer; 
                              const bstrOrdprcPtnCode: WideString): WordBool;
begin
  Result := DefaultInterface.ReqCmeQty(bstrAcctNo, bstrAcctPW, bstrItemCode, nGB, nPrice, 
                                       bstrOrdprcPtnCode);
end;

function TDongbuAPI.ReqStockHoga(const szCode: WideString): WordBool;
begin
  Result := DefaultInterface.ReqStockHoga(szCode);
end;

function TDongbuAPI.SendSOrderCredit(nClientKey: Integer; const szAcctNo: WideString; 
                                     const szAcctPW: WideString; nOrdSect: Integer; 
                                     const szItemCode: WideString; nPriceType: Integer; 
                                     nQty: Integer; nPrice: Integer; nOrgOrdNo: Integer; 
                                     const szLoanDate: WideString; const szCreditGb: WideString): WordBool;
begin
  Result := DefaultInterface.SendSOrderCredit(nClientKey, szAcctNo, szAcctPW, nOrdSect, szItemCode, 
                                              nPriceType, nQty, nPrice, nOrgOrdNo, szLoanDate, 
                                              szCreditGb);
end;

function TDongbuAPI.ReqTodayInvestors(nMarketType: Integer; nInvestorType: Integer; 
                                      const szItemCode: WideString; nSort: Integer; 
                                      nNextGB: Integer; const szNextKey: WideString): WordBool;
begin
  Result := DefaultInterface.ReqTodayInvestors(nMarketType, nInvestorType, szItemCode, nSort, 
                                               nNextGB, szNextKey);
end;

function TDongbuAPI.ReqStockAbleQty(const szAcctNo: WideString; const szAcctPW: WideString; 
                                    const szItemCode: WideString; nGB: Integer; nPrice: Integer): WordBool;
begin
  Result := DefaultInterface.ReqStockAbleQty(szAcctNo, szAcctPW, szItemCode, nGB, nPrice);
end;

procedure TDongbuAPI.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TDongbuAPI]);
end;

end.
