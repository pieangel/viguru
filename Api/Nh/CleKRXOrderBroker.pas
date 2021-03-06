unit CleKRXOrderBroker;

interface

uses
  Classes, SysUtils,

    // lemon: common
  GleLib,Gletypes, GleConsts,
    // lemon: data
  CleFQN, CleSymbols, CleTradeCore, CleOrders,
    //
  cleAccounts,

  CleQuoteBroker,

  SynThUtil, ApiPacket ;


const

  ORDER_BUF_SIZE = 1024;

type

  TReqItem = class
  public
    Invest : TInvestor;
    Symbol : TSymbol;
    TrCode : integer;
    Seq    : integer;
    constructor Create;
  end;

  TKRXOrderBroker = class
  private

    FDebug: Boolean;
    FVerbose: Boolean;

    FOnFOTrade    : TSendPacketEvent;
    FChanelIdx: integer;

    FTmpList  : TStringList;

    function Packet(aOrder: TOrder; var Buffer : array of char): string;

    function NewOrderPacket(aOrder: TOrder;var Buffer : array of char): string;
    function ChangeOrderPacket(aOrder: TOrder;var Buffer : array of char): string;
    function CancelOrderPacket(aOrder: TOrder;var Buffer : array of char): string;

    function OnSub(aQuote: TQuote) : boolean;
    function OnUnSub(aQuote: TQuote) : boolean;
  //  procedure RequestFailSymbol(iTr: integer; stData: string);
  //  procedure RollBackRequest(stData: string);


  public
    constructor Create;
    destructor Destroy; override;

    function Send(aTicket: TOrderTicket): Integer;
    procedure init;

    // 20180915  add
    procedure RequestSymbolInfo2( aSymbol  : TSymbol;  bPush : boolean = false ); 
    procedure RequestAccountFill( aAccount : TAccount; bPush : boolean = false );
    procedure RequestAccountPos(  aAccount : TAccount; bPush : boolean = false) ;

    procedure RequestAccountAbleQty( aAccount : TAccount; aSymbol : TSymbol;
            iSide, iOrderType : integer;  stPrice : string );
    procedure RequestAccountAdjustMent( aAccount : TAccount; bPush : boolean = false );

    procedure ReqSub( aSymbol : TSymbol );
    procedure ReqInvestData( stCode : string; cDiv : char );

    procedure ReqChartData( aSymbol : TSymbol; dtBase : TDateTime; iDataCnt, iMin : integer ; cDiv : char);
    procedure ReqAbleQty( aAccount : TAccount; aSymbol : TSymbol; cLS : char = '1' );  // default ???? ????

    procedure RequestAccountData;
    procedure ReqAutQuote(aSymbol : TSymbol);

    procedure SubScribe(  bOn : boolean; aAccount : TAccount );
    procedure SubScribeAccount( bOn : boolean );
    function CheckQuoteSubscribe : integer ;
    function SubSribeOption : boolean;

    property  OnFOTrade : TSendPacketEvent read FOnFOTrade write FOnFOTrade;

    // only us stg
    property ChanelIdx : integer read FChanelIdx write FChanelIdx;   // key - '5'
  end;

implementation

uses
  GAppEnv,ApiConsts
  ;


constructor TKRXOrderBroker.Create;
begin
  FDebug := False;
  FVerbose := False;
  FTmpList  := TStringList.Create;
end;

destructor TKRXOrderBroker.Destroy;
begin
  FTmpList.Free;
end;


procedure TKRXOrderBroker.init;
begin
  gEnv.Engine.QuoteBroker.OnSubscribe := OnSub;
  gEnv.Engine.QuoteBroker.OnCancel    := OnUnSub;

  gLog.Add(lkApplication,'TKRXOrderBroker','init','???????? ???????? ????');
end;

function TKRXOrderBroker.NewOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  //pPacket : PNewOrderPacket;
  aInvest : TInvestor;
  stTmp, stip : string;
begin
              {
  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_NewOrderPacket, ' ' );
  pPacket := PNewOrderPacket( @Buffer);

  pPacket.Header.Err_Kind := 'Y';

  MovePacket( Format('%11.11s', [aInvest.Code]), pPacket.Account );
  stTmp := gEnv.Engine.Api.GetEncodePassword( aInvest );
  MovePacket( Format('%-8.8s    ', [ stTmp ]), pPacket.Pass );
  MovePacket( Format('%-12.12s', [ aOrder.Symbol.Code ] ), pPacket.FullCode );

  if aOrder.Price > 0 then
    pPacket.Order_Boho  := '+'
  else
    pPacket.Order_Boho  := '-';
  MovePacket( Format('%.10d', [ aOrder.OrderQty ] ), pPacket.Order_Volume );

  if aOrder.PriceControl = pcMarket then
  begin
    MovePacket( Format('%11.11d', [ 0 ]), pPacket.Order_Price );
    pPacket.Order_Boho  := '+';
  end
  else begin
    stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);
    MovePacket( Format('%-11.11s', [ stTMp ]), pPacket.Order_Price );
  end;

  if aOrder.Side > 0 then
    pPacket.BuySell_Type := '2'
  else
    pPacket.BuySell_Type := '1';

  case aOrder.TimeToMarket of
    tmGTC, tmFAS: pPacket.Trace_Type := '0' ;
    tmFOK: pPacket.Trace_Type := '2';
    tmIOC: pPacket.Trace_Type := '1';
  end;

  case aOrder.PriceControl of
    pcLimit : pPacket.Price_Type := '1';
    pcMarket: pPacket.Price_Type := '2' ;
    pcLimitToMarket : pPacket.Price_Type := '3';
    pcBestLimit     : pPacket.Price_Type := '4';
  end;

  	// ????????????
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  MovePacket( Format('%-2.2s', [ stTMp ]), pPacket.Order_Comm_Type );
  stTmp := gEnv.Engine.Api.OwnIP;
  MovePacket( Format('%-12.12s', [ stTMp ]), pPacket.IpAddr );

  stip  := Copy( stTmp, Length( sttmp) - 2 , 3 );
  MovePacket( stip, pPacket.User_div );
  MovePacket( Format('%7.7d', [ aOrder.LocalNo ]), pPacket.User_Field);
  pPacket.Order_Type  := '1';
  SetString( Result, PChar(@Buffer[0]), Len_NewOrderPacket );

                 }
end;

function TKRXOrderBroker.CancelOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
 // pPacket : PCancelOrderPacket;
  aInvest : TInvestor;
  stTmp, stIP : string;
begin
{
  if aOrder.Target = nil then Exit;

  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_CancelOrderPacket, ' ' );
  pPacket := PCancelOrderPacket( @Buffer);

  pPacket.Header.Err_Kind := 'Y';

  MovePacket( Format('%11.11s', [aInvest.Code]), pPacket.Account );
  stTmp := gEnv.Engine.Api.GetEncodePassword( aInvest );
  MovePacket( Format('%-8.8s    ', [ stTmp ]), pPacket.Pass );
  MovePacket( Format('%-12.12s', [ aOrder.Symbol.Code ] ), pPacket.FullCode );

  MovePacket( Format('%.10d', [ aOrder.OrderQty ] ), pPacket.Order_Volume );
  MovePacket( Format('%.10d', [ aOrder.Target.OrderNo]), pPacket.WOrderNo );

	// ????????????
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  MovePacket( Format('%-2.2s', [ stTMp ]), pPacket.Order_Comm_Type );
  stTmp := gEnv.Engine.Api.OwnIP;
  MovePacket( Format('%-12.12s', [ stTMp ]), pPacket.IpAddr );
  //stip  := Copy( stTmp, 10, 3 );
  stip  := Copy( stTmp, Length( sttmp) - 2 , 3 );
  MovePacket( stip, pPacket.User_div );
  MovePacket( Format('%7.7d', [ aOrder.LocalNo ]), pPacket.User_Field);

  SetString( Result, PChar(@Buffer[0]), Len_CancelOrderPacket );
  }
end;

function TKRXOrderBroker.ChangeOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  //pPacket : PChangeOrderPacket;
  aInvest : TInvestor;
  stTmp , stIP: string;
begin
{
  if aOrder.Target = nil then Exit;

  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_ChangeOrderPacket, ' ' );
  pPacket := PChangeOrderPacket( @Buffer);

  pPacket.Header.Err_Kind := 'Y';

  MovePacket( Format('%11.11s', [aInvest.Code]), pPacket.Account );
  stTmp := gEnv.Engine.Api.GetEncodePassword( aInvest );
  MovePacket( Format('%-8.8s    ', [ stTmp ]), pPacket.Pass );
  MovePacket( Format('%-12.12s', [ aOrder.Symbol.Code ] ), pPacket.FullCode );

  if aOrder.Price > 0 then
    pPacket.Order_Boho  := '+'
  else
    pPacket.Order_Boho  := '-';
  MovePacket( Format('%.10d', [ aOrder.OrderQty ] ), pPacket.Order_Volume );

  stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);
  MovePacket( Format('%-11.11s', [ stTMp ]), pPacket.Order_Price );

  case aOrder.TimeToMarket of
    tmGTC, tmFAS: pPacket.Trace_Type := '0' ;
    tmFOK: pPacket.Trace_Type := '2';
    tmIOC: pPacket.Trace_Type := '1';
  end;

  case aOrder.PriceControl of
    pcLimit : pPacket.Price_Type := '1';
    pcMarket: pPacket.Price_Type := '2' ;
    pcLimitToMarket : pPacket.Price_Type := '3';
    pcBestLimit     : pPacket.Price_Type := '4';
  end;

  MovePacket( Format('%.10d', [ aOrder.Target.OrderNo]), pPacket.WOrderNo );

	// ????????????
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  MovePacket( Format('%-2.2s', [ stTMp ]), pPacket.Order_Comm_Type );
  stTmp := gEnv.Engine.Api.OwnIP;
  MovePacket( Format('%-12.12s', [ stTMp ]), pPacket.IpAddr );
  //stip  := Copy( stTmp, 10, 3 );
  stip  := Copy( stTmp, Length( sttmp) - 2 , 3 );
  MovePacket( stip, pPacket.User_div );
  MovePacket( Format('%7.7d', [ aOrder.LocalNo ]), pPacket.User_Field);

  SetString( Result, PChar(@Buffer[0]), Len_ChangeOrderPacket );
 }
end;

function TKRXOrderBroker.CheckQuoteSubscribe : integer;
var
  aSymbol : Tsymbol;
  i : integer;
begin

  for i := 0 to FTmpList.Count - 1 do
  begin
    aSymbol := TSymbol( FTmpList.Objects[i] );
    if aSymbol <> nil then
    begin
      if aSymbol.Quote <> nil then
        gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, aSymbol )
      else
        aSymbol.DoSubscribe := false;

      gEnv.EnvLog( WIN_TEST, Format('%d. ???????? ???? %s', [ i, aSymbol.ShortCode ])  );
    end;
  end;

  Result := FTmpList.Count;
end;

function TKRXOrderBroker.SubSribeOption: boolean;
var
  I , iSent: Integer;
  aSymbol : TSymbol;
begin

  Result := false;

  iSent := 0;
  for I := FTmpList.Count - 1 downto 0 do
  begin

    aSymbol := TSymbol( FTmpList.Objects[i] );
    if aSymbol <> nil then
    begin
      if not aSymbol.DoSubscribe then
      begin
        gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
          aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler  );
      end else inc(iSent );
    end;
  end;

  Result := iSent = FTmpList.Count;


end;

function TKRXOrderBroker.Packet(aOrder: TOrder;  var Buffer : array of char): string;
begin

  if aOrder = nil then Exit;

  case aOrder.OrderType of
    otNormal: Result := NewOrderPacket( aORder, Buffer );
    otChange: Result := ChangeOrderPacket( aORder, Buffer );
    otCancel: Result := CancelOrderPacket( aORder, Buffer );
  end;

end;

procedure TKRXOrderBroker.RequestAccountAbleQty(aAccount: TAccount;
  aSymbol: TSymbol; iSide, iOrderType: integer; stPrice: string);
var
  Buffer  : array of char;
 // aData   : PReqAbleQty;
  stTmp, stData, stPW  : string;
  idx : integer;
begin
  {
  SetLength( Buffer , Len_ReqAbleQty);
  FillChar( Buffer[0], Len_ReqAbleQty, ' ' );

  aData := PReqAbleQty( Buffer );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW]), aData.Pass );

  if iSide < 0 then
    aData.Bysl_tp := '1'
  else
    aData.Bysl_tp := '2';

  stTmp := IntToStr( iOrderType );
  aData.Gggb  := stTmp[1];

  MovePacket( Format('%-12.12s', [ aSymbol.Code ] ), aData.FullCode );
  MovePacket( Format('%-9.9s', [ stPrice ] ), aData.Jmjs );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAbleQty );

  gEnv.Engine.Api.RequestData( ESID_5130, stData, Len_ReqAbleQty);
   }
end;

procedure TKRXOrderBroker.RequestAccountAdjustMent(aAccount: TAccount;
  bPush: boolean);
var
  Buffer  : array of char;
  aData   : ^TInputDeposit;
  stData, stPW  : string;
  idx : integer;
begin

  SetLength( Buffer , sizeof(TInputDeposit));
  FillChar( Buffer[0], sizeof(TInputDeposit), ' ' );

  aData   := @Buffer[0] ;

  MovePacket( Format('%6.6s',[ aAccount.Code ]), aData.AccountNo );
  MovePacket( Format('%7.7s',  [ aAccount.PassWord ]), aData.AcntPass );

  SetString( stData, PChar(aData), sizeof(TInputDeposit) );

  gEnv.EnvLog( WIN_TEST, Format('DoRequest(%s) : %s', [ ifThenStr( bPush,'push','query'), stData]) );
  // ?????? ??????
  {
  if bPush then
    gEnv.Engine.Api.PushRequest( Qry_AcntState, stData)
  else
    gEnv.Engine.Api.DoRequest ( Qry_AcntState, stData);
    }

end;

procedure TKRXOrderBroker.RequestAccountData;
var
  I: Integer;
  aInvest : TInvestor;
begin

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    if (aInvest <> nil) and ( aInvest.PassWord <> '') then
      RequestAccountAdjustMent( aInvest, true );
  end;

  // ?????? ???? ????
  RequestAccountFill( nil, false );
  RequestAccountPos( nil, false );                 
end;


procedure TKRXOrderBroker.RequestAccountFill( aAccount : TAccount; bPush : boolean );
var
  Buffer  : array of char;
  aData   : ^TInputOrderList;
  stData, stPW  : string;
begin

  SetLength( Buffer , sizeof( TInputOrderList ) );
  FillChar( Buffer[0], sizeof( TInputOrderList ), ' ' );

  aData   := @Buffer[0] ;

  MovePacket( FormatDateTime('yyyymmdd', date), aData.TradeDate );
  MovePacket( '999999', aData.AccountNo );

  //
  //MovePacket( Format('%6.6s', [ aAccount.Code ]), aData.AccountNo );
  //MovePacket( Format('%8.8s', [ aAccount.PassWord ] ), aData.AcntPass );
  //

  aData.OrdState  := '5';

  aData.TradeCode[0]  := '0';
  aData.TradeCode[1]  := '0';

  aData.PrdtDiv := '0';
  // ????????
  aData.QeuryDiv:= '1';

  MovePacket('9999999', aData.OrderNo );
  aData.MulitAcntDiv := 'N';

  MovePacket( '000', aData.FundNo );

  SetString( stData, PChar(@Buffer[0]),sizeof( TInputOrderList ) );
  // ?????? ??????
  {
  if bPush then
    gEnv.Engine.Api.PushRequest( Qry_OrdList, stData)
  else
    gEnv.Engine.Api.DoRequest( Qry_OrdList, stData);
     }

end;

procedure TKRXOrderBroker.RequestAccountPos(aAccount: TAccount; bPush : boolean);
var
  Buffer  : array of char;
  aData   : ^TInputPosition;
  stData, stPW  : string;

begin

  SetLength( Buffer , sizeof( TInputPosition ));
  FillChar( Buffer[0], sizeof(TInputPosition), ' ' );

  aData   := @Buffer[0] ;
  // - ?? ???? ?????? ????      

  //MovePacket( Format('%6.6s',[ aAccount.Code ]), aData.AccountNo );
  //MovePacket( Format('%8.8s',  [ aAccount.PassWord ]), aData.AcntPass );
  MovePacket( '00', aData.TradeCode );
  
  aData.PrdtDiv     := '0';
  aData.QryMediaDiv := 'C';
  aData.QueryCon    := '1';

  SetString( stData, PChar(@Buffer[0]), sizeof( TInputPosition ) );
  // ?????? ??????
        {
  if bPush then
    gEnv.Engine.Api.PushRequest( Qry_AcntPos, stData)
  else
    gEnv.Engine.Api.DoRequest ( Qry_AcntPos, stData);
    }
end;



procedure TKRXOrderBroker.RequestSymbolInfo2(aSymbol: TSymbol; bPush: boolean);
begin
{
  if bPush then
    gEnv.Engine.Api.PushRequest( Qry_SymbolInfo2, aSymbol.ShortCode)
  else
    gEnv.Engine.Api.DoRequest ( Qry_SymbolInfo2, aSymbol.ShortCode);
    }
end;

procedure TKRXOrderBroker.SubScribeAccount( bOn : boolean );
begin
  if bOn then  
    gEnv.Engine.Api.Subscribe( Real_Order, '')
  else
    gEnv.Engine.Api.UnSubscribe( Real_Order, '');
end;



procedure TKRXOrderBroker.ReqAbleQty(aAccount: TAccount; aSymbol: TSymbol;
  cLS: char);
var
  Buffer  : array of char;
  //aData   : PReqAbleQty;
  stData, stPW  : string;
  aInvest : TInvestor;
begin
{
  SetLength( Buffer , Len_ReqAbleQty);
  FillChar( Buffer[0], Len_ReqAbleQty, ' ' );

  aData   := PReqAbleQty( Buffer );
  // - ?? ???? ?????? ????
  // ???? Seq ?? ???? ??????.. ( ?????????? ?????????? ????????...????)
  MovePacket( Format('%10.10d', [ aSymbol.Seq ]), aData.Header.WindowID );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount );

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( Format('%-12.12s',  [ aSymbol.ShortCode]), aData.FullCode );
  aData.Bysl_tp := cLS;
  aData.Gggb    := '2';

  SetString( stData, PChar(@Buffer[0]), Len_ReqAbleQty );
  // ?????? ??????
  gEnv.Engine.Api.PushRequest( ESID_5130, stData,  Len_ReqAbleQty);
    }
end;

// ????????, ??????????, ????, ??????( ??, ?? ?? ..)
procedure TKRXOrderBroker.ReqChartData(aSymbol: TSymbol; dtBase : TDateTime;
  iDataCnt, iMin: integer; cDiv : char);
var
  Buffer  : array of char;
 // aData   : PReqChartData;
  stData, stTmp  : string;
begin
  {
  SetLength( Buffer , Len_ReqChartData);
  FillChar( Buffer[0], Len_ReqChartData, ' ' );

  aData := PReqChartData( Buffer );
  stTmp := IntToStr( iMin );
  aData.Header.WindowID[0] := stTmp[1];

  aData.JongUp  := '3';     // ????
  aData.DataGb  := cDiv;
  aData.DiviGb  := '0';    // ????'

  MovePacket( Format('%-3s',    [ ( aSymbol as TDerivative).UnderCode ]), aData.AssetsID );
  MovePacket( Format('%-12.12s',[ aSymbol.Code ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ aSymbol.Seq ]), aData.Index );
  MovePacket( Format('%8.8s',   [ FormatDateTime('yyymmdd', dtBase)]), aData.InxDay );
  MovePacket( Format('%3.3d',   [ iDataCnt ]), aData.DayCnt );
  MovePacket( Format('%3.3d',   [ iMin ]), aData.Summary );       ///* tick, ?????? ?????? ????										*/

  SetString( stData, PChar(@Buffer[0]), Len_ReqChartData );

  gEnv.Engine.Api.RequestData( ESID_1041, stData,  Len_ReqChartData);
   }
end;

procedure TKRXOrderBroker.ReqInvestData(stCode: string; cDiv : char);
begin
  if cDiv = 'O' then
  begin
    gEnv.Engine.Api.Subscribe( 'SB_KP_OPT_INVEST_TIME', '0102' );
    gEnv.Engine.Api.Subscribe( 'SB_KP_OPT_INVEST_TIME', '0103' );
  end else
    gEnv.Engine.Api.Subscribe( Real_FutInvest, '0101' );
end;

procedure TKRXOrderBroker.ReqAutQuote(aSymbol: TSymbol);
var
  Buffer  : array of char;
 // aData   : PSendAutoKey;
  stData  : string;
begin
 {
  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - ?? ???? ?????? ????
  aData.Auto_Kind := '1';
  MovePacket( Format('%-32.32s',[ aSymbol.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.PushRequest( AUTO_0923, stData, 0);
  //gEnv.Engine.Api. ReqRealTimeQuote( True, stData );
  }
end;



procedure TKRXOrderBroker.ReqSub(aSymbol: TSymbol);
begin
  OnSub( aSymbol.Quote as TQuote );
end;

procedure TKRXOrderBroker.SubScribe( bOn : boolean; aAccount : TAccount );
var
  Buffer  : array of char;
 // aData   : PSendAutoKey;
  stData, stPW  : string;
begin
{
  if aAccount = nil then Exit;

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - ?? ???? ?????? ????
  aData.Auto_Kind := '1';
  MovePacket( Format('%-32.32s',[ aAccount.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );
  // ?????? ??????
  gEnv.Engine.Api.ReqRealTimeOrder( bOn, stData );
  }
end;

function TKRXOrderBroker.OnSub(aQuote: TQuote) : boolean;
var
  stData  : string;
  bNew, bRs : boolean;
begin

  try
    if aQuote = nil then Exit;
    bNew := false;
    if not aQuote.Symbol.DoSubscribe then
    begin
        {
      if gEnv.Engine.Api.DoRequest( Qry_LastHoga, aQuote.Symbol.Code ) < 0 then
        Exit;
         }
      aQuote.Symbol.DoSubscribe := true;  
      bNew := true;
    end;

    if aQuote.Symbol.Spec.Market = mtFutures then begin
      if aQuote.Symbol.IsStockF then
      begin
        gEnv.Engine.Api.ReqRealTimeQuote( Real_Stock_FutHoga, aQuote.Symbol.Code );
        gEnv.Engine.Api.ReqRealTimeQuote( Real_Stock_FutExec, aQuote.Symbol.Code );
      end else
      begin
        gEnv.Engine.Api.ReqRealTimeQuote( Real_FutHoga, aQuote.Symbol.Code );
        gEnv.Engine.Api.ReqRealTimeQuote( Real_FutExec, aQuote.Symbol.Code );
      end;
    end
    else if aQuote.Symbol.Spec.Market = mtOption then begin
      gEnv.Engine.Api.ReqRealTimeQuote( Real_OptHoga, aQuote.Symbol.Code );
      gEnv.Engine.Api.ReqRealTimeQuote( Real_OptExec, aQuote.Symbol.Code );
    end else Exit;

    if bNew then
      gEnv.Engine.QuoteBroker.Subscribe(  gEnv.Engine.QuoteBroker,
        aQuote.Symbol, gEnv.Engine.QuoteBroker.DummyEventHandler );
  finally
    Result := bNew;
  end;

end;

function TKRXOrderBroker.OnUnSub(aQuote: TQuote) : boolean;
begin

  if aQuote = nil then Exit;

  aQuote.Symbol.DoSubscribe := false;

  if aQuote.Symbol.Spec.Market = mtFutures then begin
    gEnv.Engine.Api.ReqRealTimeQuote( Real_FutHoga, aQuote.Symbol.Code, false );
    gEnv.Engine.Api.ReqRealTimeQuote( Real_FutExec, aQuote.Symbol.Code, false );
  end
  else if aQuote.Symbol.Spec.Market = mtOption then begin
    gEnv.Engine.Api.ReqRealTimeQuote( Real_OptHoga, aQuote.Symbol.Code, false );
    gEnv.Engine.Api.ReqRealTimeQuote( Real_OptExec, aQuote.Symbol.Code, false );
  end else Exit;

end;

//
// (SEND ORDERS)
// 1. copy maximum 20 new orders to tmp list
// 2. make packets and send using API
// 3. change the order status of the sent orders
//
const
  MAX_PACKETS = 20;
  PACKET_SIZE = 176;

function TKRXOrderBroker.Send(aTicket: TOrderTicket): Integer;
var
  iTrCode , i, iCount ,iSize: Integer;
  aOrder: TOrder;
  stPacket: String;
  Buffer : array [0..ORDER_BUF_SIZE-1] of char;

begin

  iCount := 0;



    for i := 0 to gEnv.Engine.TradeCore.Orders.NewOrders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.NewOrders[i];
      if (aOrder <> nil) and (aOrder.State = osReady)
         and ((aTicket = nil) or (aOrder.Ticket = aTicket)) then
      begin


          try
            aOrder.Sent;
            gEnv.Engine.Api.DoSendOrder( aOrder ) ;
            //gEnv.Engine.Api.PushRequest( iTrCode, stPacket, iSize);
            //gEnv.EnvLog( WIN_PACKET, format('Packet(%d/%d):%s',
             // [i, gEnv.Engine.TradeCore.Orders.NewOrders.Count,stPacket]) );

            Inc(iCount);
          except
            gEnv.EnvLog( WIN_PACKET, format('%s, %d',[ stPacket, aOrder.LocalNo]) );
          end;

          if iCount >= MAX_PACKETS then sleep(1);
      end;
    end;
      //
    if iCount = 0 then
      exit;
    result := iCount;

end;    


{ TReqItem }

constructor TReqItem.Create;
begin
  Invest := nil;
  Symbol := nil;
  TrCode := 0;
  Seq    := -1;
end;

end.



