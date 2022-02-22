unit CleKRXTradeUDPReceiver;

interface

uses
  Classes, SysUtils, Windows, IniFiles, mmsystem, Dialogs, IdGlobal,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer, IdSocketHandle,

    // Lemon: Common
  GleLib,
    // lemon: data
  CleAccounts, CleSymbols, CleOrders, CleFills, ClePositions,
    // Lemon: Utils
  CleParsers,
    // App: common
  GAppEnv;

const
  FILL_BUF_SIZE = 4096;

type

  // TKRXTradeUDPReceiver received order execution result from a brokerage server
  // via UDP. It understands KRX packet format and tranlate the packets
  // and pump the traslated information to the trade engine in the Lemon server

  TKRXTradeUDPReceiver = class
  private
    FSocketCount: Integer;
      // UDP Server
    FUDP : TIdUDPServer;
    FPort : Integer;
      // buffer
    FRecBuf : array[0..FILL_BUF_SIZE] of AnsiChar;
    FDataBuf : array[0..FILL_BUF_SIZE] of AnsiChar;
      // control
    FActive: Boolean;
      //
    FParser: TParser;
      //

      // reception control
    procedure SetActive(Value : Boolean);
      // receive data from the buffer
    procedure DataReceived(Sender: TObject; ABytes: TBytes; ABinding: TIdSocketHandle);
      // translate
    procedure ParseKRXOrder(stData : String);
    procedure ParseKRXConfirm(stData : String);
    procedure ParseKRXFill(stData : String);
  public
    constructor Create;
    destructor Destroy; override;

    property Active : Boolean read FActive write SetActive;
    property Port: Integer read FPort write FPort;
  end;

implementation

//----------------------------------------------------------------< Init/Finl >

constructor TKRXTradeUDPReceiver.Create;
begin
  FUDP := TIdUDPServer.Create(nil);
  FParser := TParser.Create([]);

    //
  FActive := False;
end;

destructor TKRXTradeUDPReceiver.Destroy;
begin
  FParser.Free;
  FUDP.Free;

  inherited;
end;

//------------------------------------------------------------------< control >

procedure TKRXTradeUDPReceiver.SetActive(Value : Boolean);
begin
  FActive := Value;

  if FActive then
  begin
    FUDP.OnUDPRead := DataReceived;
    FUDP.DefaultPort := FPort;
  end else
  begin
    FUDP.OnUDPRead := nil;
    FUDP.DefaultPort := -1;
  end;

  FUDP.Active := FActive;
end;

//---------------------------------------------------------< data from socket >

const
  DUMMY_HEADER = '1234567890123456789012345678901234567890';

procedure TKRXTradeUDPReceiver.DataReceived(Sender: TObject;
  ABytes: TBytes; ABinding: TIdSocketHandle);
var
  stPacket : String;
  stIFID, stMsgID: String;
begin
  try
    stPacket := BytesToString(ABytes);

    if (not Active) or (Length(stPacket) < 2) then Exit;

      // get Identification Codes
    stIFID := Copy(stPacket, 7, 4);
    stMsgID := Copy(stPacket, 1, 4);

      // call translate routines following the identification codes
      //   'IF01' or 'IO01': new order reception result
      //   'HO01': change or cancel order cofirmation
      //   'CH01': order fill information
    if (CompareStr(stIFID, 'IF01') = 0)
       or (CompareStr(stIFID, 'IO01') = 0)  then
      ParseKRXOrder(stPacket)
    else
    if CompareStr(stMsgID, 'HO01') = 0 then
      ParseKRXConfirm(DUMMY_HEADER + stPacket)
    else
    if CompareStr(stMsgID, 'CH01') = 0 then
      ParseKRXFill(DUMMY_HEADER + stPacket);
  except
    On E:Exception do
    begin
      // log error: gEnv.OnLog(Self, '....');
    end;
  end;
end;

// 'OR01' : parse order reception packet
//
procedure TKRXTradeUDPReceiver.ParseKRXOrder(stData : String);
var
  aAccount: TAccount;
  aSymbol: TSymbol;
  aOrder, aTarget: TOrder;
  iLocalNo, iRjtCode, iOrderNo, iSide, iOrderQty, iTarget: Integer;
  dPrice: Double;
  bAccepted: Boolean;
  pcValue: TPriceControl;
  otValue: TOrderType;
  stDealer: String;
  dtAccepted: TDateTime;
begin
  if FParser.Parse(stData, [11,9,2,3,8, 7,9,8,3,7,
                            2,1,1,8,1,  9,1,2,2,1,
                            1,7,9,7]) <> 24 then Exit;

  aAccount := gEnv.Engine.TradeCore.Accounts.Find(FParser[22]);
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(Trim(FParser[7]));
  if (aAccount = nil) or (aSymbol = nil) then Exit;

  try
    iLocalNo := StrToIntDef(FParser[23], 0);
    iOrderNo := StrToIntDef(FParser[9], 0); // FParser[1] ?
    iRjtCode := StrToIntDef(FParser[3],0);
    bAccepted := (iRjtCode = 0) and (iOrderNo > 0);
    if bAccepted then
      dtAccepted := EncodeTime(StrToIntDef(Copy(FParser[4],1,2),0),
                               StrToIntDef(Copy(FParser[4],3,2),0),
                               StrToIntDef(Copy(FParser[4],5,2),0),
                               StrToIntDef(Copy(FParser[4],7,2),0))
    else
      dtAccepted := 0.0;

    aOrder := gEnv.Engine.TradeCore.Orders.FindLocalNo(aAccount, aSymbol, iLocalNo);

      // import foreign order
    if aOrder = nil then
    begin
        // long or short
      case FParser[11][1] of
        'S' : iSide := 1;
        'D' : iSide := -1;
        else Exit;
      end;
        // price control
      case FParser[12][1] of
        'L' : pcValue := pcLimit;
        'M' : pcValue := pcMarket;
        'C' : pcValue := pcLimitToMarket;
        'B' : pcValue := pcBestLimit;
        else Exit;
      end;
        // order volume and price
      stDealer := ''; // ....
      iOrderQty := StrToIntDef(FParser[13], 0); // sign?
      dPrice := StrToIntDef(FParser[15],0) / 100;
        // order type
      case FParser[10][2] of
        '1' : otValue := otNormal;
        '2' : otValue := otChange;
        '3' : otValue := otCancel;
        else Exit;
      end;
        // target
      if otValue in [otChange, otCancel] then
      begin
        // iTarget := ...
        aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iTarget);
      end;
        //
      case otValue of
        otNormal: aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                    stDealer, aAccount, aSymbol, iOrderQty, pcValue, dPrice,
                    tmGTC, nil);
        otChange: aOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                    aTarget, iOrderQty, pcValue, dPrice, tmGTC, nil);
        otCancel: aOrder := gEnv.Engine.TradeCore.Orders.NewCancelorder(
                    aTarget, iOrderQty, nil);
        else Exit;
      end;
        //
      gEnv.Engine.TradeBroker.Accept(aOrder, bAccepted, iOrderNo, iRjtCode, dtAccepted);
   end;

  finally

  end;
end;

// 'HO01': Parse order confirmation packet
//
procedure TKRXTradeUDPReceiver.ParseKRXConfirm(stData : String);
var
  iOrderNo, iConfirmedQty, iRjtCode: Integer;
  bConfirmed: Boolean;
  aAccount: TAccount;
  aSymbol: TSymbol;
  aResult: TOrderResult;
begin
    //***** NOTICE: check the protocol
  if FParser.Parse(stData, [40,4,1,9,8, 3,7,3,7,2,
                            1,1,1,1,9,  1,9,8,8,8,
                            2,2,1,1,3,  9,30,8]) < 28 then Exit;

    // check account & symbol
  aAccount := gEnv.Engine.TradeCore.Accounts.Find(FParser[25]);
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(Trim(FParser[4]));
  if (aAccount = nil) or (aSymbol = nil) then Exit;

  try
    iOrderNo := StrToInt(FParser[6]);
    iConfirmedQty := StrToInt(FParser[18]);
    iRjtCode := StrToInt(FParser[24]);
    bConfirmed := (iRjtCode = 0);
      //
    if iOrderNo < 0 then Exit;

      // identify or create data objects
    aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aAccount, aSymbol, iOrderNo,
                    orConfirmed, Now, iRjtCode, iConfirmedQty, 0.0);
      // process
    gEnv.Engine.TradeBroker.Confirm(aResult, Now);
  except
  end;
end;

// 'CH01' :  parse order fill packet
//
procedure TKRXTradeUDPReceiver.ParseKRXFill(stData : String);
var
  iOrderNo, iFillNo, iFilledQty: Integer;
  dFilledPrice: Double;
  dtFilled: TDateTime;
  aAccount: TAccount;
  aSymbol: TSymbol;
  aResult: TOrderResult;
begin
    //**** NOTICE: check the protocol
  if FParser.Parse(stData, [40,4,1,9,8,  3,7,3,9,1,
                            1,1,1,9,8,   8,9,9,2,2,
                            1,1,9,30]) < 24 then Exit;

    // check account & symbol
  aAccount := gEnv.Engine.TradeCore.Accounts.Find(FParser[22]);
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(Trim(FParser[4]));
  if (aAccount = nil) or (aSymbol = nil) then Exit;

    // data elements
  try
      // translate packet
    iOrderNo     := StrToInt(FParser[6]);   // order ID
    iFillNo      := StrToInt(FParser[8]);   // fill ID
    iFilledQty   := StrToInt(FParser[14]);
    dFilledPrice := StrToInt(FParser[13]) / 100;
    //dFrontPrice  := StrToInt(FParser[16]) / 100; // for spread
    //dBackPrice   := StrToInt(FParser[17]) / 100; // for spread
    dtFilled := EncodeTime(StrToInt(Copy(FParser[15],1,2)),
                           StrToInt(Copy(FParser[15],3,2)),
                           StrToInt(Copy(FParser[15],5,2)),
                           StrToInt(Copy(FParser[15],7,2)));

    if iOrderNo < 0 then Exit;

      // identify or create data objects
    aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aAccount, aSymbol, iOrderNo,
                    orFilled, dtFilled, iFillNo, iFilledQty, dFilledPrice);
      // process
    gEnv.Engine.TradeBroker.Fill(aResult, Now);
  except
  end;
end;

end.


