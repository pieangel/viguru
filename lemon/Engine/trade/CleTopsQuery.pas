unit CleTopsQuery;

interface

uses
  Classes, SysUtils,
  TOP2ServerPacket, SynthUtil, CleTradeIF,
  CleSymbols, CleOrders, CleFills, ClePositions, CleAccounts;

type
  TTopsQuery = class
  private
    FSocket : TSocketThread;
    TopsHeader  : TTopsHeader;
    QueryHeader : TQueryHeader;
    FGroupCnt : integer;
    FSuccess : boolean;
    FNextKey : int64;
    procedure Login(stID, stPass : string);
    procedure DoActive(stNextkey : string);
    procedure DoPos;
    function GetLoginResult( cR: char ) : string;
    function MakeQueryHead( iSize : integer; stTR : string) : TQueryHeader;
  public
    constructor Create;
    destructor Destroy; override;
    procedure initHeader;
    procedure ReceivePos(stPacket : string);
    procedure ReceiveActive(stPacket : string);
    procedure PosQuery(stID, stAcnt : string);
    procedure ActiveQuery(stID, stAcnt, stNextKey : string);
    procedure DoStart(aSocket : TSocketThread);
    function ReceiveLogin(stPacket : string) : char;
  end;
implementation
uses
  GAppEnv, GleLib, GleTypes;

{ TTopsQuery }
constructor TTopsQuery.Create;
begin
  FSuccess := false;
  FNextKey := 999999999999999999;

  //gEnv.ConConfig.SisAddr := GetLocalIP( gEnv.ConConfig.TradeAddr);
  initHeader;
end;

destructor TTopsQuery.Destroy;
begin

  inherited;
end;

procedure TTopsQuery.initHeader;
begin
  //FillChar( FHeader, Len_
  FillChar( TopsHeader, sizeof( TTopsHeader ) , ' ');
  FillChar( QueryHeader, sizeof( TQueryHeader ) , ' ');

  ////////////////////////////////////////
  ///  Tops header
  MovePacket( 'LIVE', TopsHeader.tr_code );
  MovePacket( format('%9.9d', [0]), TopsHeader.seq_no );
  MovePacket( gEnv.ConConfig.UserID, TopsHeader.emp_no );
  TopsHeader.mkt_l_cls  := 'K';
  TopsHeader.com_gb     := '1';

  /////////////////////////////////////
  ///  query header
  QueryHeader.trgb := '1';
  MovePacket('0001', QueryHeader.handle );
  QueryHeader.attr := '1';

  MovePacket( Format('%15.15s', [ gEnv.ConConfig.TradeAddr ]), QueryHeader.ip );
  MovePacket( Format('%10.10s', [ gEnv.ConConfig.UserID ]), QueryHeader.userid );

end;

procedure TTopsQuery.DoActive(stNextkey : string);
var
  i : integer;
  aInvestor : TInvestor;
begin

  for i := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvestor := gEnv.Engine.TradeCore.Investors.Investor[i];
    ActiveQuery(aInvestor.Name , aInvestor.ShortCode, stNextkey);
  end;

end;

procedure TTopsQuery.DoPos;
var
  i: integer;
  aInvestor : TInvestor;
begin

  for i := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvestor := gEnv.Engine.TradeCore.Investors.Investor[i];
    PosQuery( aInvestor.Name, aInvestor.ShortCode );
  end;
end;

procedure TTopsQuery.DoStart(aSocket : TSocketThread);
var
  i, iCnt : integer;
  aInvestor : TInvestor;
begin

  FSocket := aSocket;
  FGroupCnt := gEnv.Engine.TradeCore.Investors.Count;

  for i := 0 to FGroupCnt - 1 do
  begin
    aInvestor := gEnv.Engine.TradeCore.Investors.Investor[i];
    Login( aInvestor.Name, aInvestor.PassWord );
  end;
end;

function TTopsQuery.GetLoginResult(cR: char): string;
begin
  case cR of
    '1' : Result := '성공';
    '2' : Result := 'ID 실패';
    '3' : Result := 'PW 실패';
    '4' : Result := '미사용아이디';
    '9' : Result := 'DB Error';
  end;
end;

function TTopsQuery.MakeQueryHead(iSize: integer; stTR : string): TQueryHeader;
var
  i : integer;
begin
  // data, Tr, 펀드번호,
  Result := QueryHeader;
  MovePacket( Format('%4.4d', [iSize - LENGTH_SIZE ]), Result.length );
  MovePacket( stTR, Result.tr_code );

end;

procedure TTopsQuery.Login(stID, stPass : string);
var
  aLogin : PLoginIn;
  aQuery : TQueryHeader;
  Buffer : array of char;
begin
  SetLength( Buffer, Len_LogIn );
  FillChar(Buffer[0], Len_LogIn, ' ');

  aLogin := PLoginIn(Buffer);
  aQuery := MakeQueryHead(Len_LogIn, TR_LOGIN);

  Move(aQuery, Buffer[0], Len_QueryHeader + LENGTH_SIZE  );
  MovePacket( Format('%-8s',[ gEnv.ConConfig.UserID ]) , aLogin.id );
  MovePacket( gEnv.ConConfig.Password , aLogin.passwd );
  aLogin.flag := '1';

  FSocket.PushQueue( TYPE_SEND, Len_LogIn, @Buffer[0]);
end;

procedure TTopsQuery.PosQuery(stID, stAcnt : string);
var
  aPos : PPosIn;
  aQuery : TQueryHeader;
  buffer : array of char;
  iSize : integer;
  stTmp : string;
begin
  SetLength( buffer, Len_PosIn );
  aPos := PPosIn(buffer);
  aQuery := MakeQueryHead(Len_PosIn, TR_POS);

  Move(aQuery, Buffer[0], Len_QueryHeader + LENGTH_SIZE);
  MovePacket( stAcnt , aPos.fund_no );
  MovePacket( Format('%-8s',[ gEnv.ConConfig.UserID ]), aPos.login_id);
  aPos.isu_gb := '0';
  FSocket.PushQueue( TYPE_SEND, Len_PosIn, @Buffer[0]);
end;

procedure TTopsQuery.ActiveQuery(stID, stAcnt, stNextKey : string);
var
  aActive : PActiveFillIn;
  aQuery : TQueryHeader;
  buffer : array of char;
  stTmp : string;
begin
  SetLength( Buffer, Len_ActiveIn );
  FillChar(Buffer[0], Len_ActiveIn, ' ');

  aActive := PActiveFillIn(Buffer);
  aQuery := MakeQueryHead(Len_ActiveIn, TR_ACTIVEFILL);

  Move(aQuery, Buffer[0], Len_QueryHeader + LENGTH_SIZE  );

  MovePacket( Format('%-8s',[ gEnv.ConConfig.UserID ]) , aActive.login_id );
  MovePacket( stAcnt , aActive.fund_no );
  aActive.isu_gu := '0';
  aActive.tr_gb := '0';
  aActive.che_gb := '1';
  MovePacket( Format('%18.18s', [stNextKey]),  aActive.next_key );
  FSocket.PushQueue( TYPE_SEND, Len_ActiveIn, @Buffer[0]);
end;


function TTopsQuery.ReceiveLogin(stPacket: string): char;
var
  i : integer;
  stLog : string;
  aLoginOut : PLoginOut;
begin
  aLoginOut := PLoginOut(stPacket);

  case aLoginOut.Header.attr of
    QRY_START : gEnv.EnvLog(WIN_REC, 'Login START' );
    QRY_DATA :
    begin
      Result := aLoginOut.result;
      if Result = '1' then
        FSuccess := true
      else
      begin
        FSuccess := false;
        stLog := Format('Login Failed ID = %s, %s',[string(aLoginOut.emp_no), GetLoginResult(Result)]);
        gEnv.EnvLog(WIN_REC, stLog);
      end;
    end;
    QRY_END :
    begin
      gEnv.EnvLog(WIN_REC, 'Login END' );
      if FSuccess then
        DoPos;
    end;
  end;
end;

procedure TTopsQuery.ReceiveActive(stPacket: string);
var
  aActive : PActiveFillData;
  i, iStart, iEnd, iCnt, iSize : integer;
  aAccount : TAccount;
  aSymbol  : TSymbol;
  stTmp, stTime, stLog, stGroupID, stData  : string;
  iOrderQty, iTmp , iSide: integer;
  iOrderNo, iOriginNo : int64;
  aTicket  : TorderTicket;
  dPrice   : Double;
  aTarget, aOrder   : TOrder;
  pcValue  : TPriceControl;
  tmValue  : TTimeToMarket;
  bAsk : boolean;
  dtAcptTime : TDateTime;
  aSub : PActiveFillOutSub;
  aInvestor : TInvestor;
begin
  aActive := PActiveFillData(stPacket);
  case aActive.Header.attr of
    QRY_START : gEnv.EnvLog(WIN_REC, 'Active START' );

    QRY_DATA :
    begin
      stLog := Format('ReceiveActive, %s',[stPacket]);
      gEnv.EnvLog(WIN_PACKET, stLog);

      FNextKey := StrToInt64Def(string(aActive.Output.next_key),0);
      iCnt := StrToIntDef(string(aActive.Output.rcnt), 0);

      iStart := 1;
      iEnd := Len_ActiveOutSub;
      iSize := Len_QueryHeader + Len_ActiveOut +LENGTH_SIZE + 1;      //쿼리헤더 + Out 사이즈
      stPacket := Copy(stPacket, iSize ,Length(stPacket)- iSize);     //OutSub만 남긴다.
      stLog := Format('ReceiveActive, %d, %d',[iCnt , FNextKey]);
      for i := 0 to iCnt - 1 do
      begin
        stData := Copy( stPacket, iStart, iEnd );
        aSub := PActiveFillOutSub(stData);
        iStart := iStart + Len_ActiveOutSub;
        iEnd := iEnd + Len_ActiveOutSub;

        stLog := Format('Active %s, %s, p = %s, LS = %s, Q = %s, No = %s',
        [string(aSub.fund_no), string(aSub.isu_cd), string(aSub.ord_prc),
        string(aSub.tr_cls), string(aSub.ord_qty), string(aSub.ord_no)]);
        gEnv.EnvLog(WIN_REC,stLog );

        stTmp := Trim(string(aSub.fund_no));
        aInvestor := gEnv.Engine.TradeCore.Investors.FindShort(stTmp);
        if aInvestor = nil then exit;
        aAccount := aInvestor.RceAccount;
        stTmp   := Trim(string( aSub.isu_cd ));
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( stTmp );
        if( aAccount = nil ) or ( aSymbol = nil ) then
          exit;

        iOrderQty := StrToInt( string( aSub.ord_qty ));

        case aSub.ord_ty of
          '1' : pcValue := pcLimit;
          '2' : pcValue := pcMarket;
          'X' : pcValue := pcBestLimit;
          'I' : pcValue := pcLimitToMarket;
        end;

        if aSub.tr_cls = '1' then
          iSide := -1
        else
          iSide := 1;

        dPrice  := StrToFloat( string( aSub.ord_prc )) / 100.0;
        pcValue := pcLimit;
        tmValue := tmGTC;
        iOrderNo := StrToInt64Def( string( aSub.ord_no ),0 );
        iOriginNo := StrToInt64Def( string( aSub.org_ord_no ), 0);

        stTime := string(aSub.acc_tm);
        dtAcptTime := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                   StrToInt(Copy(stTime,3,2)),
                                   StrToInt(Copy(stTime,5,2)),
                                   StrToInt(Copy(stTime,7,2)));
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        aOrder := gEnv.Engine.TradeCore.Orders.NewRecoveryOrder( gEnv.ConConfig.UserID,
                                                                aAccount,
                                                                aSymbol,
                                                                iSide,  iOrderQty,
                                                                pcValue,
                                                                dPrice,
                                                                tmValue,
                                                                aTicket,
                                                                iOrderNo,
                                                                stGroupID);
        if (aOrder <> nil) and ( iOrderQTy > 0) then
          aOrder.Accept(dtAcptTime);
      end;
    end;
    QRY_END :
    begin
      gEnv.EnvLog(WIN_REC, 'Active END' );
      if FNextKey <> 0 then
      begin
        DoActive(IntToStr(FNextKey));
        FNextKey := 0;
      end else
        gEnv.SetAppStatus( asRecoveryEnd );  // 리커버리 데이타
    end;
  end;
end;

procedure TTopsQuery.ReceivePos(stPacket: string);
var
  aPosData : PPosData;
  stTmp, stLog : string;
  iCnt : integer;
  stCode, stData : string;
  iTmp  : integer;
  aAccount : TAccount;
  aSymbol  : TSymbol;
  aOrder : TOrder;
  aInvestPos, aPos : TPosition;

  cM : char;
  Side, Qty, BuyQty, SelQty, PrevQty : integer;
  bResult : boolean;
  dAvgPrice : double;
  i, iStart, iEnd, iSize : integer;
  aSub : PPosSub;
  aInvestor : TInvestor;
begin
  aPosData := PPosData(stPacket);

  case aPosData.Header.attr of
    QRY_START : gEnv.EnvLog(WIN_REC, 'Postion START' );
    QRY_DATA :
    begin
      iCnt := StrToInt(string(aPosData.Output.rcnt));
      if iCnt = 0 then exit;
      stLog := Format('ReceivePos, %s',[stPacket]);
      gEnv.EnvLog(WIN_PACKET, stLog);
      iStart := 1;
      iEnd := Len_PosSub;
      iSize := Len_QueryHeader + Len_PosOut + LENGTH_SIZE + 1;      //쿼리헤더 + Out 사이즈
      stPacket := Copy(stPacket, iSize ,Length(stPacket)- iSize);   //Sub만 남긴다.
      for i := 0 to iCnt - 1 do
      begin
        stData := Copy( stPacket, iStart, iEnd );
        aSub := PPosSub(stData);
        iStart := iStart + Len_PosSub;
        iEnd := iEnd + Len_PosSub;

        stLog := Format('Pos %s, %s, %s, %s, %s', [string(aSub.fund_no), string(aSub.isu_cd), string(aSub.tr_cls),
              string(aSub.bk_qty), string(aSub.bk_prc)]);
        gEnv.EnvLog(WIN_REC,stLog );

        stTmp := Trim(string(aSub.fund_no));
        aInvestor := gEnv.Engine.TradeCore.Investors.FindShort(stTmp);

        if aInvestor = nil then exit;

        aAccount := aInvestor.RceAccount;
        stCode   := Trim(string( aSub.isu_cd ));
        if (stCode[1] = '1') or (stCode[1] = '4') then
          cM := 'F'
        else
          cM := 'O';
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( stCode );

        if( aAccount = nil ) or ( aSymbol = nil ) then
          exit;

        if cM = 'F' then
        begin
          aAccount.Fees[dtFutures] := aAccount.Fees[dtFutures] + StrToFloat(string(aSub.cmsn));
          aAccount.TradeAmt[dtFutures] := aAccount.TradeAmt[dtFutures] + (StrToFloatDef(string(aSub.bk_amt),0)/1000.0);
        end else if cM = 'O' then
        begin
          aAccount.Fees[dtOptions] := aAccount.Fees[dtOptions] + StrToFloat(string(aSub.cmsn));
          aAccount.TradeAmt[dtOptions] := aAccount.TradeAmt[dtOptions] + (StrToFloatDef(string(aSub.bk_amt),0)/1000.0);
        end;

        Qty  := StrToInt(string(aSub.bk_qty));
        if aSub.tr_cls = '1' then     // 1: 매도, 2 : 매수
          Side := -1
        else
          Side := 1;

        dAvgPrice  := StrToFloat( string(aSub.bk_prc)) / 100000000.0;
        aPos := gEnv.Engine.TradeBroker.AddPosition(aAccount, aSymbol, Side, Qty, dAvgPrice);
        if aPos <> nil then
        begin

          aPos.TradeAmt := aPos.TradeAmt + (StrToFloatDef(string(aSub.bk_amt),0)/1000.0);
          aPos.SetPosition(Qty * Side, dAvgPrice, StrToFloat(string(aSub.tr_prft_ls)));
          aPos.Fee := aPos.Fee + StrToFloat(string(aSub.cmsn));
          if dAvgPrice > 0 then
            aPos.PrevAvgPrice := 0
          else
            aPos.PrevAvgPrice := dAvgPrice;

          stLog := Format('Postion  Acnt = %s, Code = %s, Qty = %d, AvgPrice = %f, EntryPL = %f, futFee = %f, OptFee = %f, FutTardeAmt = %f, OptTardeAmt = %f',
                   [aAccount.Name, stCode, Qty, dAvgPrice, aPos.EntryPL,
                    aAccount.Fees[dtFutures], aAccount.Fees[dtOptions],
                    aAccount.TradeAmt[dtFutures], aAccount.TradeAmt[dtOptions] ]);
          gEnv.EnvLog(WIN_REC, stLog );
        end;


        aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvestor, aSymbol);
        if aInvestPos = nil then
          aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.New( aInvestor, aSymbol );

        if aInvestPos <> nil then
        begin
          aInvestPos.TradeAmt := aInvestPos.TradeAmt + (StrToFloatDef(string(aSub.bk_amt),0)/1000.0);
          aInvestPos.SetPosition(Qty * Side, dAvgPrice, StrToFloat(string(aSub.tr_prft_ls)));
          aInvestPos.Fee := aInvestPos.Fee + StrToFloat(string(aSub.cmsn));
          if dAvgPrice > 0 then
            aInvestPos.PrevAvgPrice := 0
          else
            aInvestPos.PrevAvgPrice := dAvgPrice;
        end;
      end;
    end;
    QRY_END :
    begin
      gEnv.EnvLog(WIN_REC, 'Postion END' );
      DoActive(NEXT_KEY);
    end;
  end;
end;

end.
