unit CleKRXTradeReceiver;

interface

//{$define MzMemArea }
{$define SMMemArea }

uses
  Classes, SysUtils, Windows, IniFiles, mmsystem, Dialogs, math,
    // Lemon: Common
  GleLib, KrFutPacket,
    // lemon: data
  CleAccounts, CleSymbols, CleOrders, CleFills, ClePositions,
    // Lemon: Utils
  CleParsers, GleConsts, ExtCtrls, GleTypes,
    // App: common
  GAppEnv

  ;

const

  FILL_BUF_SIZE = 4096;
  SOCK_CNT  = 4;

type

  // TKRXTradeUDPReceiver received order execution result from a brokerage server
  // via UDP. It understands KRX packet format and tranlate the packets
  // and pump the traslated information to the trade engine in the Lemon server
  TSrvOrdeType = (	osUnknow ,
                    osAccept,
                    osFullyFilled,
                    osConfirmed,
                    osCanceled,
                    osReject);

  TKRXTradeReceiver = class
  private
    FTradeDate: TDateTime;
    function ConvertOrderNo(stOrderNo: string): int64;
  public

    FSocketCount: Integer;
    FTimer : TTimer;
    ConSock: integer;

      // receive data from the buffer
    procedure OnSrvAccept( iLocalNo : integer; iReject : integer ); overload;
    procedure OnSrvAccept( iLocalNo : integer; iOrdNo : int64; stRjt : string ); overload;

    procedure OnSrvReject( iOrdNo : int64; stRjt : string );

    procedure DataReceived(stPacket : string; stResCode : string = '0000');
      // translate
    procedure ParseKRXOrder(stData : String );
    procedure ParseOrderAck(stData : String; stResCode : string );
    procedure ParseKRXConfirm(stData : String);
    procedure ParseKRXFill(stData : String);

    constructor Create;
    destructor Destroy; override;

    procedure TimerProc(Sender: TObject);
    procedure SetTimer( bEnable : boolean );
    property TradeDate : TDateTime read FTradeDate write FTradeDate;
  end;

var gReceiver : TKRXTradeReceiver;

implementation

uses CleFQN,
  CleQuoteTimers;

//----------------------------------------------------------------< Init/Finl >

constructor TKRXTradeReceiver.Create;
var ivar : integer;
  i: Integer;
begin

  ConSock       := MAST_SOCK;
  FSocketCount  := ivar;
  gReceiver := self;

  FTimer  := TTimer.Create( nil );
  FTimer.Interval := 1000;
  FTimer.Enabled  := false;
  {
  if (gEnv.RunMode = rtRealTrading) and (not gEnv.ConConfig.RecoveryCheck) then
    FTimer.Enabled := True
  else
    FTimer.Enabled := false;
  }

  FTimer.OnTimer := TimerProc;
end;

destructor TKRXTradeReceiver.Destroy;
var ivar : integer;
begin
  
  FTimer.Enabled := false;
  FTimer.Free;


  gReceiver := nil;
  inherited;
end;





procedure TKRXTradeReceiver.OnSrvAccept(iLocalNo, iReject: integer);
var i:integer;
  aOrder : TOrder;
begin
  //** ???? ?????? ?????? ??????, ???? ?????? ?? ???????? ????
  //** NewOrder ???? ?????????? ??????.
  aOrder := nil;
  for i:=gEnv.Engine.TradeCore.Orders.NewOrders.Count-1 downto 0 do begin
    aOrder := TOrder( gEnv.Engine.TradeCore.Orders.NewOrders.Items[i] );
    if (aOrder.LocalNo = iLocalNo) and ( aOrder.State = osReady) then
      break;
  end;

  if aOrder = nil then
    Exit;
  gEnv.Engine.TradeBroker.SrvAccept( aOrder, iReject );

end;

procedure TKRXTradeReceiver.OnSrvAccept(iLocalNo : integer; iOrdNo: int64;
  stRjt: string);
var i:integer;
  aOrder : TOrder;
begin

  aOrder := nil;
  for i:=gEnv.Engine.TradeCore.Orders.NewOrders.Count-1 downto 0 do begin
    aOrder := TOrder( gEnv.Engine.TradeCore.Orders.NewOrders.Items[i] );
    if aOrder.Ticket.No = iLocalNo then
      break;
  end;

  if aOrder = nil then
  begin
    gEnv.EnvLog( WIN_ERR,
      Format( 'TKRXTradeReceiver.OnSrvAccept Order not find : %d, %d, %s',
        [  iLocalNo, iOrdNo, stRjt ] )
    );
    Exit;
  end;
  gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrdNo, stRjt );

end;

procedure TKRXTradeReceiver.OnSrvReject(iOrdNo: int64; stRjt: string);
var i:integer;
  aOrder : TOrder;
begin

  aOrder := nil;
  for i:=gEnv.Engine.TradeCore.Orders.NewOrders.Count-1 downto 0 do begin
    aOrder := TOrder( gEnv.Engine.TradeCore.Orders.NewOrders.Items[i] );
    if aOrder.LocalNo = iOrdNo then
      break;
  end;

  if aOrder = nil then
  begin
    gEnv.EnvLog( WIN_ERR,
      Format( 'TKRXTradeReceiver.OnSrvAccept Order not find : %d, %s',
        [  iOrdNo, stRjt ] )
    );
    Exit;
  end;
  gEnv.Engine.TradeBroker.SrvReject( aOrder, stRjt );

end;

//------------------------------------------------------------------< control >

procedure TKRXTradeReceiver.TimerProc(Sender: TObject);
begin

end;

//---------------------------------------------------------< data from socket >

procedure TKRXTradeReceiver.DataReceived(stPacket : string; stResCode : string );
var
  stIFID, stMsgID: String;
  vData : PCommonData;
begin
  vData := PCommonData( stPacket );
  try
    stIFID  := string( vData.trans_code );
    if ( CompareStr( stIFID, NewHoga ) = 0) or        // ???? ack.
       ( CompareStr( stIFID, CnlHoga ) = 0) or
       ( CompareStr( stIFID, ModHoga ) = 0) then
      ParseOrderAck(stPacket, stResCode )
    else if ( CompareStr( stIFID, ConfNormal ) = 0) or
       ( CompareStr( stIFID, ConfReject ) = 0) or
       ( CompareStr( stIFID, AutoCancel ) = 0) then
      // ?????? ???????? ???????? ?? ????..?????????? ????????(????????)
      ParseKRXConfirm(stPacket)
    else if ( CompareStr( stIFID, OrderFill ) = 0) then
      ParseKRXFill(stPacket);
  except
    On E:Exception do
    begin
      // log error: gEnv.OnLog(Self, '....');
    end;
  end;

end;

//
procedure TKRXTradeReceiver.ParseKRXOrder(stData : String );
{
var
  aAccount: TAccount;
  aSymbol: TSymbol;
  aOrder, aTarget, pOrder: TOrder;
  aTicket : TOrderTicket;
  aForward : TForwardAccept;
  iLocalNoi, iSide, iTarget, iOrderQty, i, iForwardCnt: Integer;
  dPrice  : double;
  iOrderNo : int64;
  bAccepted: Boolean;
  stCode, stTmp, stTime : String;
  dtAccepted: TDateTime;
  vData : PTopsConfirmPacket;
  stRjtCode : string;

  pcValue: TPriceControl;
  otValue: TOrderType;
  tmValue: TTimeToMarket;     }
begin
{
  if Length( stData ) < Len_TopsConfirmPacket then  Exit;

  vData := PTopsConfirmPacket( stData );
  stTmp :=  string( vData.gyejwa );
  aAccount  := gEnv.Engine.TradeCore.Accounts.Find( stTmp );

  stCode  := trim( string( vData.CommonData.code ) );
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
  if (aAccount = nil) or (aSymbol = nil) then Exit;

  try
    stTime  := string( vData.acpt_time );
    iOrderNo  := StrToInt( trim(string( vData.CommonData.ordno )));
    iTarget   := StrToIntDef( string( vData.CommonData.orgordno ), 0);
    stRjtCode := string(vData.rejcode);

    bAccepted := (iOrderNo > 0) and ( (stRjtCode = '0000') or (stRjtcode = ''))  ;

    if bAccepted then
      dtAccepted := FTradeDate +
                    EncodeTime(StrToIntDef(Copy(stTime,1,2),0),
                               StrToIntDef(Copy(stTime,3,2),0),
                               StrToIntDef(Copy(stTime,5,2),0),
                               StrToIntDef(Copy(stTime,7,2),0)*10)
    else
      dtAccepted := 0.0;

    aOrder := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iOrderNo);

    if aOrder = nil then
    begin
      case vData.hogagb of
        '1' : otValue := otNormal;
        '2' : otValue := otChange;
        '3' : otValue := otCancel;
        else Exit;
      end;

      // long or short
      if otValue = otNormal then
        case vData.mmgubun of
          '1' : iSide := -1;
          '2' : iSide := 1;
          else Exit;
        end;
        // price control
      pcValue := pcLimit;

      case vData.ord_cond of
        '0' : tmValue := tmGTC;
        '3' : tmValue := tmIOC;
        '4' : tmValue := tmFOK;
        else  tmValue := tmGTC;
      end;
      iOrderQty := StrToInt( string( vData.cnt ));
      dPrice := StrTofloat( string( vData.price )) ;

      if otValue in [otChange, otCancel] then
      begin
        aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iTarget);
        if aTarget = nil then
        begin
          gEnv.Engine.TradeBroker.ForwardAccepts.New(aAccount, aSymbol, iTarget, iOrderNo, iOrderQty,
                                                  dPrice, otValue, pcValue, bAccepted,
                                                  stRjtCode, Copy( stTime , 1, Length( stTime )-1 ), dtAccepted);

          Exit;
        end;
      end;

      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );

      case otValue of
        otNormal:
          begin
            aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                    gEnv.ConConfig.UserID, aAccount, aSymbol, iSide * iOrderQty, pcValue, dPrice,
                    tmValue, aTicket);
          end;
        otChange: aOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                    aTarget, iOrderQty, pcValue, dPrice, tmValue, aTicket);
        otCancel: aOrder := gEnv.Engine.TradeCore.Orders.NewCancelorder(
                    aTarget, iOrderQty, aTicket);
        else Exit;
      end;
      if aOrder = nil then Exit;

      aOrder.OwnOrder := false;
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);

      // ???????? ???? ???????????? ???? ???? ????
      if otValue = otNormal then
      begin
        iForwardCnt := 0;
        for i := gEnv.Engine.TradeBroker.ForwardAccepts.Count - 1  downto 0 do
        begin
          aForward := gEnv.Engine.TradeBroker.ForwardAccepts[i];
          if (aForward.TargetNo = aOrder.OrderNo)
            and (aForward.Accout = aAccount)
            and (aForward.Symbol = aSymbol) then
          begin
            pOrder := nil;
            aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
            case aForward.Value of
              otChange:  pOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                                      aOrder, aForward.OrderQty, aForward.PriceValue, aForward.Price, tmGTC, aTicket);
              otCancel: pOrder := gEnv.Engine.TradeCore.Orders.NewCancelorder(
                                      aOrder, aForward.OrderQty, aTicket);
            end;
            if pOrder = nil then break;
            pOrder.TradeTime := aForward.TradeTime;
            gEnv.Engine.TradeBroker.SrvAccept( aOrder, aForward.OrderNo, aForward.RjtCode);
            gEnv.Engine.TradeBroker.Accept(pOrder, aForward.Accepted,  aForward.RjtCode , aForward.AcceptTime);
            gEnv.EnvLog( WIN_ORD,Format('FORWARD ACCEPT: Code = %s, ??????(%s:%d),????(%s:%d)', [aSymbol.ShortCode,
                                     FormatDateTime('hh:nn:ss', dtAccepted),iOrderNo,
                                     FormatDateTime('hh:nn:ss', aForward.AcceptTime),aForward.OrderNo]));
            inc(iForwardCnt);
          end;
        end;

        for i := 0 to iForwardCnt - 1 do
          gEnv.Engine.TradeBroker.ForwardAccepts.Del(aOrder.OrderNo);

      end;

    end;

    // 9????  ???? ????????
    aOrder.TradeTime  := stTime;
    gEnv.Engine.TradeBroker.Accept(aOrder, bAccepted, stRjtCode, dtAccepted);

  finally
  end;     }
end;



procedure TKRXTradeReceiver.ParseOrderAck(stData, stResCode: string);
var
  aAccount: TAccount;
  aSymbol: TSymbol;
  aOrder : TOrder;
  iLocalNo : Integer;
  iOrderNo : int64;
  stCode, stTmp, stTime: String;
  vData : PKrOrderPacket;
  aInvestor : TInvestor;
begin

  if Length( stData ) < Len_Kr5OrderPacket then  Exit;

  vData := PKrOrderPacket( stData );
  stTmp :=  string( vData.gyejwa );
  //aAccount  := gEnv.Engine.TradeCore.Accounts.Find( stTmp );
  aInvestor := gEnv.Engine.TradeCore.Investors.Find( stTmp );

  stCode  := trim( string( vData.CommonData.code ) );
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
  if (aInvestor = nil) or (aSymbol = nil) then Exit;

  try
    stTime    := string( vData.ord_time );
    iOrderNo  := ConvertOrderNo( trim(string( vData.CommonData.ordno )));
    //?????????? ?????????????? ??????????..?????????? ????.
    //iLocalNo  := StrToIntDef( trim( string( vData.hoiwon.localNo )),0);
    //aOrder := gEnv.Engine.TradeCore.Orders.FindLocalNo(aAccount, aSymbol, iLocalNo);
    aOrder  := gEnv.Engine.TradeCore.Orders.FindInvestor( aInvestor, aSymbol, iOrderNo );

    if aOrder = nil then
    begin
      gEnv.EnvLog( WIN_ORD, Format('Not Found LocalNo order : %s, %s, %d, %d', [
        aInvestor.ShortCode, aSymbol.ShortCode, iOrderNo, iLocalNo
        ]) );
      Exit;
    end;
    gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stResCode);
  finally
  end;

end;




procedure TKRXTradeReceiver.SetTimer(bEnable: boolean);
begin
  if gEnv.RunMode = rtRealTrading then
    FTimer.Enabled := bEnable
  else
    FTimer.Enabled := false;
end;

procedure TKRXTradeReceiver.ParseKRXConfirm(stData : String);
var
  iOrderNo, iTarget : int64;
  iConfirmedQty: Integer;
  bConfirmed: Boolean;
  aAccount: TAccount;
  aSymbol: TSymbol;
  aResult: TOrderResult;
  dPrice : double;
  vData : PKrConfirmPacket;
  stTmp, stCode, stTime : string;
  stRjtCode : string;
  dtResultTime : TDateTime;
  aOrder  : TOrder;

  aTarget, pOrder: TOrder;
  aTicket : TOrderTicket;
  aForward : TForwardAccept;
  iLocalNo, iSide, iOrderQty, i, iForwardCnt: Integer;

  bAccepted: Boolean;
  dtAccepted: TDateTime;

  pcValue: TPriceControl;
  otValue: TOrderType;
  tmValue: TTimeToMarket;
  aInvestor : TInvestor;
begin

  if Length( stData ) < Len_KrConfirmPacket then
    Exit;

  try
    vData := PKrConfirmPacket( stData );

    stTmp :=  string( vData.gyejwa );

    aInvestor := gEnv.Engine.TradeCore.Investors.Find( stTmp );
    if aInvestor = nil then Exit;

    stCode := Trim(string( vData.CommonData.code ));
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode);

    if aSymbol = nil then Exit;

    iOrderNo      := ConvertOrderNo( string(vData.CommonData.ordno) );
    iTarget       := ConvertOrderNo( string(vData.CommonData.orgordno) );
    iOrderQty     := StrToIntDef( string( vData.cnt ), 0);
    iConfirmedQty := StrToIntDef( string( vData.jungcnt ), 0);
    stRjtCode     := trim( string( vData.rejcode ));
    if stRjtcode = '0000' then stRjtCode := '';
    bConfirmed    := (iOrderNo>0) and (stRjtCode = '') ;
      //
    dPrice := StrToIntDef( string( vData.Price ), 0) ;

    stTime  := trim( string( vData.acpt_time ));
    dtResultTime  :=  FTradeDate +
                    EncodeTime(StrToIntDef(Copy(stTime,1,2),0),
                               StrToIntDef(Copy(stTime,3,2),0),
                               StrToIntDef(Copy(stTime,5,2),0),
                               StrToIntDef(Copy(stTime,7,3),0));
    // find the order
    // ???????? ????????.
    //aOrder := gEnv.Engine.TradeCore.Orders.FindINvestorOrder(aInvestor, aSymbol, iOrderNo);
    // ???? ???? ????.
    aOrder := gEnv.Engine.TradeCore.Orders.FindInvestor(aInvestor, aSymbol, iOrderNo);

    if aOrder = nil then
    begin
      case vData.hogagb of
        '1' : otValue := otNormal;
        '2' : otValue := otChange;
        '3' : otValue := otCancel;
        else Exit;
      end;

      // long or short
      if otValue = otNormal then
        case vData.mmgubun of
          '1' : iSide := -1;
          '2' : iSide := 1;
          else Exit;
        end;
        // price control
      pcValue := pcLimit;

      case vData.ord_cond of
        '0' : tmValue := tmGTC;
        '3' : tmValue := tmIOC;
        '4' : tmValue := tmFOK;
        else  tmValue := tmGTC;
      end;

      iOrderQty := StrToInt( string( vData.cnt ));
      dPrice    := StrTofloat( string( vData.price )) ;

      if otValue in [otChange, otCancel] then
      begin
        //aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iTarget);
        aTarget := gEnv.Engine.TradeCore.Orders.FindINvestorOrder(aInvestor, aSymbol, iTarget);
        if aTarget = nil then begin
          gEnv.EnvLog( WIN_ORD, Format( 'Error : not found ?????? %s, %s, %d(%d)', [ aInvestor.ShortCode, aSymbol.ShortCode, iOrderNo, iTarget]  ) );
          Exit;
        end;
        // ?????? ?? ?????? ?????? ???? ????
        // ???????? ?????? ????
        aAccount  := aTarget.Account;
      end
      else
        // ?????????? ???????? ?????? ????
        aAccount  := aInvestor.RceAccount;

      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );

      case otValue of
        otNormal:
          begin
            aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                    gEnv.ConConfig.UserID, aAccount, aSymbol, iSide * iOrderQty, pcValue, dPrice,
                    tmValue, aTicket);
          end;
        otChange: aOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                    aTarget, iOrderQty, pcValue, dPrice, tmValue, aTicket);
        otCancel: aOrder := gEnv.Engine.TradeCore.Orders.NewCancelorder(
                    aTarget, iOrderQty, aTicket);
        else Exit;
      end;
      if aOrder = nil then Exit;

      aOrder.OwnOrder := false;

    end;

    // ???? ack ?? ???? ????..?????? ??????.
    gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo );

      // identify or create data objects
    aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aOrder.Account, aSymbol, iOrderNo,
                    orConfirmed, Now, 0, stRjtCode, iConfirmedQty, dPrice, dtResultTime);

    aOrder.TradeTime  := stTime;
    aOrder.Results.Add( aResult );

    gEnv.Engine.TradeBroker.Confirm(aOrder, Now);
  except
  end;
end;

// 'CH01' :  parse order fill packet
//
procedure TKRXTradeReceiver.ParseKRXFill(stData : String);
var
  iFilledQty: Integer;
  iFillNo, iOrderNo : int64;
  dFilledPrice: Double;
  dtFilled: TDateTime;
  aAccount: TAccount;
  aSymbol: TSymbol;
  aResult: TOrderResult;
  vData : PKrFillPacket;
  stTmp, stCode, stTime : string;
  aInvestor : TInvestor ;
  aOrder  : TOrder;
begin

  if  Length( stData ) < Len_KrFillPacket then
    Exit;

  vData :=  PKrFillPacket( stData );
    // data elements
  try
      // check account & symbol
    stTmp := string( vData.gyejwa );
    //aAccount  := gEnv.Engine.TradeCore.Accounts.Find( stTmp );
    aInvestor := gEnv.Engine.TradeCore.Investors.Find( stTmp );
    if aInvestor = nil then Exit;

    stCode := Trim(string( vData.CommonData.code ));
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode);
    if (aSymbol = nil) then Exit;
      // translate packet
    iOrderNo     := ConvertOrderNo( string( vData.CommonData.ordno ));
    iFillNo      := StrToInt( string( vData.che_no ));
    iFilledQty   := StrToInt( string( vData.che_qty ));
    dFilledPrice := StrTofloat( string( vData.che_price ));
    stTime  := string( vData.che_time );

    dtFilled := FTradeDate + EncodeTime(StrToInt(Copy(stTime,1,2)),
                           StrToInt(Copy(stTime,3,2)),
                           StrToInt(Copy(stTime,5,2)),
                           StrToInt(Copy(stTime,7,3)));

    if iOrderNo < 0 then Exit;

    // ?????????? ?????? ????.
    aOrder  := gEnv.Engine.TradeCore.Orders.FindInvestor(aInvestor, aSymbol, iOrderNo );

    if aOrder = nil then
    begin
      gEnv.EnvLog( WIN_ORD, Format('???? ???????? ?????? ???? %s, %s, %d, %.2f, %d : ',
      [  aInvestor.ShortCode, aSymbol.ShortCode, iOrderNo, dFilledPrice, iFilledQty
      ]));
      //gEnv.Engine.TradeBroker.AddTurnOrder( aResult, GetQuoteTime );
      Exit;
    end;
      // identify or create data objects

    aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aOrder.Account, aSymbol, iOrderNo,
                    orFilled, dtFilled, iFillNo, '',iFilledQty, dFilledPrice, dtFilled);

    aResult.FillTime  := stTime;
    aOrder.Results.Add( aResult );
      // process
    gEnv.Engine.TradeBroker.Fill(aOrder, Now);

    //gEnv.EnvLog(WIN_PACKET, Format('Fill Code = %s, OrderNo = %d, Fillno = %d, Qty = %d, Price = %.2f, iSide = %s',
      //                            [aSymbol.ShortCode, iOrderNo, iFillNo, iFilledQty, dFilledPrice, string(vData.Side)]));

  except
  end;
end;


function TKRXTradeReceiver.ConvertOrderNo(stOrderNo :string ): int64;
begin
  Result := StrToInt64Def( stOrderNo, 0 );
end;
end.


