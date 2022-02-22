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
    procedure RequestFailSymbol(iTr: integer; stData: string);
    procedure RollBackRequest(stData: string);


  public
    constructor Create;
    destructor Destroy; override;

    function Send(aTicket: TOrderTicket): Integer;
    procedure init;

    procedure RequestAccountFill( aAccount : TAccount; bPush : boolean = false );
    procedure RequestAccountPos(  aAccount : TAccount; bPush : boolean = false) ;
    procedure RequestAccountDeposit( aAccount : TAccount; bPush : boolean = false );
    procedure RequestAccountAbleQty( aAccount : TAccount; aSymbol : TSymbol;
            iSide, iOrderType : integer;  stPrice : string );
    procedure RequestAccountAdjustMent( aAccount : TAccount; bPush : boolean = false );

    function RequestMarketPrice(stUnder, stCode: string; iIndex : integer; bPush : boolean = false) : boolean;
    function RequestMarketHoga(stUnder, stCode: string; iIndex : integer; bPush : boolean = false) : boolean;
    function RequestSymbolPriceNHoga( aSymbol : TSymbol ) : boolean;

    procedure ReqSub( aSymbol : TSymbol );
    procedure ReqInvestData( stCode : string; cDiv : char );

    procedure ReqChartData( aSymbol : TSymbol; dtBase : TDateTime; iDataCnt, iMin : integer ; cDiv : char);
    procedure ReqAbleQty( aAccount : TAccount; aSymbol : TSymbol; cLS : char = '1' );  // default 매수 조회

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

  gLog.Add(lkApplication,'','','구독취소 프로시저 할당');
end;

function TKRXOrderBroker.NewOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  pPacket : PNewOrderPacket;
  aInvest : TInvestor;
  stTmp, stip : string;
begin

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

  	// 통신주문구분
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  MovePacket( Format('%-2.2s', [ stTMp ]), pPacket.Order_Comm_Type );
  stTmp := gEnv.Engine.Api.OwnIP;
  MovePacket( Format('%-12.12s', [ stTMp ]), pPacket.IpAddr );

  stip  := Copy( stTmp, Length( sttmp) - 2 , 3 );
  MovePacket( stip, pPacket.User_div );
  MovePacket( Format('%7.7d', [ aOrder.LocalNo ]), pPacket.User_Field);
  pPacket.Order_Type  := '1';
  SetString( Result, PChar(@Buffer[0]), Len_NewOrderPacket );


end;

function TKRXOrderBroker.CancelOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  pPacket : PCancelOrderPacket;
  aInvest : TInvestor;
  stTmp, stIP : string;
begin
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

	// 통신주문구분
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  MovePacket( Format('%-2.2s', [ stTMp ]), pPacket.Order_Comm_Type );
  stTmp := gEnv.Engine.Api.OwnIP;
  MovePacket( Format('%-12.12s', [ stTMp ]), pPacket.IpAddr );
  //stip  := Copy( stTmp, 10, 3 );
  stip  := Copy( stTmp, Length( sttmp) - 2 , 3 );
  MovePacket( stip, pPacket.User_div );
  MovePacket( Format('%7.7d', [ aOrder.LocalNo ]), pPacket.User_Field);

  SetString( Result, PChar(@Buffer[0]), Len_CancelOrderPacket );
end;

function TKRXOrderBroker.ChangeOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  pPacket : PChangeOrderPacket;
  aInvest : TInvestor;
  stTmp , stIP: string;
begin
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

	// 통신주문구분
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  MovePacket( Format('%-2.2s', [ stTMp ]), pPacket.Order_Comm_Type );
  stTmp := gEnv.Engine.Api.OwnIP;
  MovePacket( Format('%-12.12s', [ stTMp ]), pPacket.IpAddr );
  //stip  := Copy( stTmp, 10, 3 );
  stip  := Copy( stTmp, Length( sttmp) - 2 , 3 );
  MovePacket( stip, pPacket.User_div );
  MovePacket( Format('%7.7d', [ aOrder.LocalNo ]), pPacket.User_Field);

  SetString( Result, PChar(@Buffer[0]), Len_ChangeOrderPacket );

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

      gEnv.EnvLog( WIN_TEST, Format('%d. 구독실패 종목 %s', [ i, aSymbol.ShortCode ])  );
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
  aData   : PReqAbleQty;
  stTmp, stData, stPW  : string;
  idx : integer;
begin

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

end;

procedure TKRXOrderBroker.RequestAccountAdjustMent(aAccount: TAccount;
  bPush: boolean);
var
  Buffer  : array of char;
  aData   : PReqAccountDeposit;
  stData, stPW  : string;
  idx : integer;
begin
  SetLength( Buffer , Len_OutAccountAdjustMent);
  FillChar( Buffer[0], Len_OutAccountAdjustMent, ' ' );

  aData   := PReqAccountDeposit( Buffer );
  // - 를 붙여 앞으로 정렬
  idx  := gEnv.Engine.TradeCore.Investors.GetIndex( aAccount.InvestCode ) + 1;
  if idx < 1 then Exit;
  // 2016.06.08  ReqKey 서버사용으로 windowID 를 사용
  //Move( idx, aData.Header.ReqKey, 1 );
  MovePacket( Format('%10.10d', [ idx]), aData.Header.WindowID );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );
  // 계좌별 예수금
  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5124, stData, Len_OutAccountAdjustMent)
  else
    gEnv.Engine.Api.RequestData( ESID_5124, stData, Len_OutAccountAdjustMent);

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
    begin
      //RequestAccountDeposit( aInvest, true );
      RequestAccountAdjustMent( aInvest, true );
      RequestAccountPos( aInvest, true );
      RequestAccountFill( aInvest, true );
    end;
  end;
end;

procedure TKRXOrderBroker.RequestAccountDeposit(aAccount: TAccount; bPush : boolean );
var
  Buffer  : array of char;
  aData   : PReqAccountDeposit;
  stData, stPW  : string;
  idx : integer;
begin
  SetLength( Buffer , Len_ReqAccountDeposit);
  FillChar( Buffer[0], Len_ReqAccountDeposit, ' ' );

  aData   := PReqAccountDeposit( Buffer );
  // - 를 붙여 앞으로 정렬
  idx  := gEnv.Engine.TradeCore.Investors.GetIndex( aAccount.InvestCode );
  MovePacket( Format('%10.10d', [ idx+1]), aData.Header.WindowID );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );
  // 계좌별 예수금
  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5122, stData, Len_ReqAccountDeposit)
  else
    gEnv.Engine.Api.RequestData( ESID_5122, stData, Len_ReqAccountDeposit);

end;

procedure TKRXOrderBroker.RequestAccountFill( aAccount : TAccount; bPush : boolean );
var
  Buffer  : array of char;
  aData   : PReqAccountFill;
  stData, stPW  : string;

begin
  SetLength( Buffer , Len_ReqAccountFill);
  FillChar( Buffer[0], Len_ReqAccountFill, ' ' );

  aData   := PReqAccountFill( Buffer );
  // - 를 붙여 앞으로 정렬

  //aData.Header.NextKind := cNext;
  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( Format('%8.8s',  [ FormatDateTime('yyyymmdd', Date) ]), aData.Order_Date );

  aData.Trace_Kind  := '2';
  aData.Gubn    := '1';

  SetString( stData, PChar(@Buffer[0]),Len_ReqAccountFill );
  // 계좌별 실체결
  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5111, stData,  Len_ReqAccountFill)
  else
    gEnv.Engine.Api.RequestData( ESID_5111, stData,  Len_ReqAccountFill);

end;

procedure TKRXOrderBroker.RequestAccountPos(aAccount: TAccount; bPush : boolean);
var
  Buffer  : array of char;
  aData   : PReqAccountPos;
  stData, stPW  : string;

begin
  SetLength( Buffer , Len_ReqAccountPos);
  FillChar( Buffer[0], Len_ReqAccountPos, ' ' );

  aData   := PReqAccountPos( Buffer );
  // - 를 붙여 앞으로 정렬
  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  aData.Gubn  := '0';

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountPos );
  // 계좌별 실체결

  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5112, stData,  Len_ReqAccountPos)
  else
    gEnv.Engine.Api.RequestData( ESID_5112, stData,  Len_ReqAccountPos);

end;

function TKRXOrderBroker.RequestMarketHoga(stUnder, stCode: string; iIndex: integer;
  bPush: boolean) : boolean ;
var
  Buffer  : array of char;
  aData   : PReqSymbolMaster;
  stData  : string;
  iRes    : integer;

begin
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-3.3s', [ stUnder ]), aData.AssetsID );
  MovePacket( Format('%-12.12s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ iIndex ]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );

  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_2004, stData,  Sizeof( TReqSymbolMaster ))
  else begin
    iRes := gEnv.Engine.Api.RequestData( ESID_2004, stData,  Sizeof( TReqSymbolMaster ));
    Result := iRes = 0;
    if not Result then
      RequestFailSymbol( ESID_2004, stData );

  end;

end;

function TKRXOrderBroker.RequestMarketPrice(stUnder, stCode: string; iIndex : integer; bPush : boolean) : boolean;
var
  Buffer  : array of char;
  aData   : PReqSymbolMaster;
  stData  : string;
  iRes    : integer;
begin
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-3.3s', [ stUnder ]), aData.AssetsID );
  MovePacket( Format('%-12.12s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ iIndex ]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );

  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_2003, stData,  Sizeof( TReqSymbolMaster ))
  else begin
    iRes := gEnv.Engine.Api.RequestData( ESID_2003, stData,  Sizeof( TReqSymbolMaster ));
    Result := iRes = 0;
    if not Result then
      RequestFailSymbol( ESID_2003, stData );
  end;
end;

function TKRXOrderBroker.RequestSymbolPriceNHoga(aSymbol: TSymbol): boolean;
var
  bRs1, bRs2 : boolean;
begin
  Result := false;
  bRs1   := RequestMarketPrice( ( aSymbol as TDerivative).UnderCode, aSymbol.Code, aSymbol.Seq );
  if not bRs1 then Exit;

  bRs2   := RequestMarketHoga( ( aSymbol as TDerivative).UnderCode,  aSymbol.Code, aSymbol.Seq );
  if not bRs2 then Exit;

  aSymbol.DoSubscribe := true;
  Result := true;
end;

procedure TKRXOrderBroker.RequestFailSymbol( iTr : integer; stData : string );
begin
  case iTr of
    // 현재가 요청
    ESID_2003 ,  // 호가 요청
    ESID_2004 : RollBackRequest( stData ) ;
  end;
end;

procedure TKRXOrderBroker.RollBackRequest( stData : string );
var
  pReq : PReqSymbolMaster;
  stCode : string;
  aSymbol: TSymbol;
begin
  pReq  := PReqSymbolMaster( stData );
  stCode:= string( pReq.FullCode );
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if (aSymbol <> nil) and ( FTmpList.IndexOfObject( aSymbol ) < 0 )  then
    FTmpList.AddObject( aSymbol.ShortCode, aSymbol );
end;


procedure TKRXOrderBroker.SubScribeAccount( bOn : boolean );
var
  I: Integer;
begin
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    SubScribe( bOn, gEnv.Engine.TradeCore.Investors.Investor[i] );
end;



procedure TKRXOrderBroker.ReqAbleQty(aAccount: TAccount; aSymbol: TSymbol;
  cLS: char);
var
  Buffer  : array of char;
  aData   : PReqAbleQty;
  stData, stPW  : string;
  aInvest : TInvestor;
begin
  SetLength( Buffer , Len_ReqAbleQty);
  FillChar( Buffer[0], Len_ReqAbleQty, ' ' );

  aData   := PReqAbleQty( Buffer );
  // - 를 붙여 앞으로 정렬
  // 종목 Seq 를 딸려 보낸다.. ( 결과값으로 종목코드를 안주니깐...ㅡㅡ)
  MovePacket( Format('%10.10d', [ aSymbol.Seq ]), aData.Header.WindowID );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount );

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( Format('%-12.12s',  [ aSymbol.ShortCode]), aData.FullCode );
  aData.Bysl_tp := cLS;
  aData.Gggb    := '2';

  SetString( stData, PChar(@Buffer[0]), Len_ReqAbleQty );
  // 계좌별 실체결
  gEnv.Engine.Api.PushRequest( ESID_5130, stData,  Len_ReqAbleQty);

end;

// 기준일자, 데이타개수, 몇분, 봉종류( 분, 일 주 ..)
procedure TKRXOrderBroker.ReqChartData(aSymbol: TSymbol; dtBase : TDateTime;
  iDataCnt, iMin: integer; cDiv : char);
var
  Buffer  : array of char;
  aData   : PReqChartData;
  stData, stTmp  : string;
begin

  SetLength( Buffer , Len_ReqChartData);
  FillChar( Buffer[0], Len_ReqChartData, ' ' );

  aData := PReqChartData( Buffer );
  stTmp := IntToStr( iMin );
  aData.Header.WindowID[0] := stTmp[1];

  aData.JongUp  := '3';     // 고정
  aData.DataGb  := cDiv;
  aData.DiviGb  := '0';    // 고정'

  MovePacket( Format('%-3s',    [ ( aSymbol as TDerivative).UnderCode ]), aData.AssetsID );
  MovePacket( Format('%-12.12s',[ aSymbol.Code ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ aSymbol.Seq ]), aData.Index );
  MovePacket( Format('%8.8s',   [ FormatDateTime('yyymmdd', dtBase)]), aData.InxDay );
  MovePacket( Format('%3.3d',   [ iDataCnt ]), aData.DayCnt );
  MovePacket( Format('%3.3d',   [ iMin ]), aData.Summary );       ///* tick, 분에서 모으는 단위										*/

  SetString( stData, PChar(@Buffer[0]), Len_ReqChartData );

  gEnv.Engine.Api.RequestData( ESID_1041, stData,  Len_ReqChartData);

end;

procedure TKRXOrderBroker.ReqInvestData(stCode: string; cDiv : char);
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
begin

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  aData.Auto_Kind := '3';
  MovePacket( Format('%-32.32s',[ stCode ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.ReqRealTimeQuote( True, stData );

end;

procedure TKRXOrderBroker.ReqAutQuote(aSymbol: TSymbol);
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
begin

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  aData.Auto_Kind := '1';
  MovePacket( Format('%-32.32s',[ aSymbol.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.PushRequest( AUTO_0923, stData, 0);
  //gEnv.Engine.Api. ReqRealTimeQuote( True, stData );
end;



procedure TKRXOrderBroker.ReqSub(aSymbol: TSymbol);
begin
  OnSub( aSymbol.Quote as TQuote );
end;

procedure TKRXOrderBroker.SubScribe( bOn : boolean; aAccount : TAccount );
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData, stPW  : string;
begin
  if aAccount = nil then Exit;

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  aData.Auto_Kind := '1';
  MovePacket( Format('%-32.32s',[ aAccount.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );
  // 계좌별 실체결
  gEnv.Engine.Api.ReqRealTimeOrder( bOn, stData );
end;

function TKRXOrderBroker.OnSub(aQuote: TQuote) : boolean;
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
  bNew, bRs1, bRs2 : boolean;
begin

  try
    if aQuote = nil then Exit;
    bNew := false;
    if not aQuote.Symbol.DoSubscribe then
    begin
      bRs1 := RequestMarketPrice( ( aQuote.Symbol as TDerivative).UnderCode, aQuote.Symbol.Code, aQuote.Symbol.Seq );
      if not bRs1 then Exit;
      bRs2 := RequestMarketHoga( ( aQuote.Symbol as TDerivative).UnderCode,  aQuote.Symbol.Code, aQuote.Symbol.Seq );
      if not bRs2 then Exit;
      aQuote.Symbol.DoSubscribe := true;
      bNew := true;
    end;

    SetLength( Buffer , Len_SendAutoKey);
    FillChar( Buffer[0], Len_SendAutoKey, ' ' );

    aData   := PSendAutoKey( Buffer );
    // - 를 붙여 앞으로 정렬
    aData.Auto_Kind := '1';
    MovePacket( Format('%-32.32s',[ aQuote.Symbol.Code ]), aData.AutoKey );
    SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

    gEnv.Engine.Api.ReqRealTimeQuote( True, stData );
    if bNew then
      gEnv.Engine.QuoteBroker.Subscribe(  gEnv.Engine.QuoteBroker,
        aQuote.Symbol, gEnv.Engine.QuoteBroker.DummyEventHandler );
  finally
    Result := bNew;
  end;

end;

function TKRXOrderBroker.OnUnSub(aQuote: TQuote) : boolean;
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
begin
  if aQuote = nil then Exit;

  aQuote.Symbol.DoSubscribe := false;
  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  aData.Auto_Kind := '1';
  MovePacket( Format('%-32.32s',[ aQuote.Symbol.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.ReqRealTimeQuote( false, stData );

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

        stPacket := Packet(aOrder, Buffer);

        if stPacket <> '' then
          try
            aOrder.Sent;

            case aOrder.OrderType of
              otNormal: begin iTrCode := ESID_5101; iSize := Len_NewOrderPacket; end;
              otChange: begin iTrCode := ESID_5102; iSize := Len_ChangeOrderPacket; end;
              otCancel: begin iTrCode := ESID_5103; iSize := Len_CancelOrderPacket; end;
            end;

            gEnv.Engine.Api.PushRequest( iTrCode, stPacket, iSize);
            gEnv.EnvLog( WIN_PACKET, format('Packet(%d/%d):%s',
              [i, gEnv.Engine.TradeCore.Orders.NewOrders.Count,stPacket]) );

            Inc(iCount);
          except
            gEnv.EnvLog( WIN_PACKET, format('%s, %d',[ stPacket, aOrder.LocalNo]) );
          end;

        if iCount >= MAX_PACKETS then Break;
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



