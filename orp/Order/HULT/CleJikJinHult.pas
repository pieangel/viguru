unit CleJikJinHult;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,   CleStrategyAccounts,

  UPaveConfig, CleQuoteTimers  ,

  GleTypes
  ;

const
  Ent_ord = 100;
  Pav_Ord = 200;
  Los_ord = 400;

type

  TJikJinItem = record
    BasePrice : double;   // 기준점
    StartPrice: array [TPositionType] of double;   // 치는 가격
    HitPrice  : double;
    LossPrice : double;   // 손절 가격

    Count     : integer;  // 몇번째 인가 치면 +1  손절이면 -1
    OrdSide   : integer;  // 상승 하락 방향  1, 0, -1
    IsReady   : boolean;  // 기준점 셋
    Done      : boolean;  // 청산 주문을 냈는지...

    IsFirst   : boolean;  // 처음 시작할때 한번만..

    procedure reset;
    procedure update( aSymbol : TSymbol; iSide, iGap : integer );

  end;

  TJikJinHult = class
  private
    FParam: TJikJinHultData;
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;
    FSymbol: TSymbol;
    FParent: TObject;
    FOnNotify: TTextNotifyEvent;
    FRun: boolean;

    FFundPosition: TFundPosition;
    FPosition: TPosition;
    FJJItem: TJikJinItem;
    FLossCut: boolean;

    FSaveCur : double;

    FPavOrders : TOrderList; // 깔아논 주문
    FHitOrders : TOrderList; // 치는 주문..( 손절 은 제외 )

    procedure DoLog( stLog : string );

    function IsCheck: boolean;
    procedure QuotePrc(Sender, Receiver: TObject; DataID: Integer;
      DataObj: TObject; EventID: TDistributorID);
    procedure TradePrc(Sender, Receiver: TObject; DataID: Integer;
      DataObj: TObject; EventID: TDistributorID);

    procedure OnQuote(aQuote: TQuote);
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID );
    procedure OnFill(aOrder : TOrder);
    procedure SetParam(const Value: TJikJinHultData);

    procedure DoLossCut(aQuote: TQuote); overload;
    procedure DoLossCut; overload;
    procedure DoInit(aQuote: TQuote);
    procedure DoWork(aQuote: TQuote);

    procedure DoCancelOrder;
    function DoPutOrder( aQuote : TQuote; dPrice : double; iDiv : integer = Pav_ord  ) : boolean ;
    function DoOrder( aQuote : TQuote; dPrice : double;  iQty : integer; iDiv: integer ) : boolean ; overload;
    function DoOrder( aQuote : TQuote;  aAccount : TAccount; dPrice : double;
              iQty : integer; iDiv : integer ) : boolean ; overload;
    procedure IsDone;
    procedure CheckOrderState(aOrder: TOrder);
    procedure CheckLiskAmt(aQuote: TQuote);
    procedure CheckLiskAmt_Fund(aQuote: TQuote);

  public
    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;

    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean; overload;
    function init( aFund : TFund;    aSymbol : TSymbol ) : boolean; overload;

    function GetPosition : integer;
    function GetPL : double;

    property Param : TJikJinHultData read FParam write SetParam   ;
    property JJItem : TJikJinItem read FJJItem;

    property Run      : boolean read FRun;
    property LossCut  : boolean read FLossCut;

    property Parent : TObject read FParent;
    property Symbol : TSymbol read FSymbol;

    property Position : TPosition read FPosition;
    property FundPosition : TFundPosition read FFundPosition;

    property OnNotify  : TTextNotifyEvent read FOnNotify write FOnNotify;


  end;

implementation

uses
  GAppEnv , GleLib, GleConsts, Math ,
  FJikJinHult , CleFills,
  CleKrxSymbols
  ;

{ TJikJinHult }

constructor TJikJinHult.Create(aObj: TObject);
begin
  FSymbol   := nil;
  FAccount  := nil;
  FFund     := nil;
  FIsFund   := false;
  FRun      := false;
  FParent   := aObj;

  FJJItem.IsFirst := true;

  FPavOrders   := TOrderList.Create;
  FHitOrders   := TOrderList.Create;
end;

destructor TJikJinHult.Destroy;
begin

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  FHitOrders.Free;
  FPavOrders.Free;

  inherited;
end;

procedure TJikJinHult.DoLog(stLog: string);
begin
  if FIsFund and (FFund <> nil) then
    gEnv.EnvLog( WIN_JIK_HULT, stLog, false, FFund.Name );

  if ( not FIsFund ) and (FAccount <> nil) then
    gEnv.EnvLog( WIN_JIK_HULT, stLog, false, FAccount.Code );

  if Assigned( FOnNotify ) then
    FOnNotify( Self, stLog );
  
end;

procedure TJikJinHult.DoLossCut(aQuote: TQuote);
var
  dPrice : double;
  i : integer;
  aPos : TPosition;
begin
  if FIsFund then
  begin

    for I := 0 to FFundPosition.Positions.Count-1 do
    begin
      aPos := FFundPosition.Positions.Positions[i];
      if aPos = nil then Continue;
      if Position.Volume = 0 then continue;

      if Position.Volume > 0 then
        dPrice  := aQuote.Bids[4].Price
      else
        dPrice  := aQuote.Asks[4].Price;

      DoOrder( aQuote, aPos.Account, dPrice, aPos.Volume * -1, Los_ord );
    end;

  end else begin
    if Position = nil then Exit;
    if Position.Volume = 0 then Exit;

    if Position.Volume > 0 then
      dPrice  := aQuote.Bids[4].Price
    else
      dPrice  := aQuote.Asks[4].Price;
    DoOrder( aQuote, FAccount, dPrice, Position.Volume * -1, Los_ord );
  end;
end;

procedure TJikJinHult.DoLossCut;
begin
  DoCancelOrder;
  DoLossCut( FSymbol.Quote as TQuote );
end;

function TJikJinHult.DoOrder(aQuote: TQuote; aAccount: TAccount; dPrice : double;
  iQty: integer;  iDiv : integer): boolean;
var
  stTxt  : string;
  aTicket: TOrderTicket;
  aOrder : TOrder;
begin
  Result := false;

  if ( aAccount = nil ) then
  begin
    DoLog( '주문 인자 이상 : account = nil ');
    Exit;
  end;

  if ( dPrice < 0.001 ) or ( iQty = 0 ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f ',  [ aAccount.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, aQuote.Symbol, iQty  , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    aOrder.OrderSpecies := opBHult;
    if iDiv = Pav_ord then
      FPavOrders.Add( aOrder );

    aOrder.OrderTag := iDiv;

    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( iDiv = Ent_ord, '진입',
          ifThenStr( iDiv = Los_ord, '손절', '깔기' )),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iQty > 0, '매수','매도'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));

    Result := true;
  end;

end;

function TJikJinHult.DoPutOrder(aQuote: TQuote; dPrice: double ;iDiv : integer): boolean;
var
  I, iCnt: Integer;
  aPos : TPosition;
  res : Boolean;
begin

  result := false;

  try
    if FIsFund then
    begin
      iCnt := 0;
      for I := 0 to FFundPosition.Positions.Count-1 do
      begin
        aPos := FFundPosition.Positions.Positions[i];
        res := false;
        res := DoOrder( aQuote, aPos.Account, dPrice, aPos.Volume * -1, iDiv );
        if res then  inc( iCnt );
      end;

      if iCnt = FFundPosition.Positions.Count then
        Result := true
      else
        DoLog( Format('Fund 청산 주문 깔기 실패 %d 중에 % 개만 주문 성공', [
          FFundPosition.Positions.Count, iCnt ]));
    end else
      result := DoOrder( aQuote, FAccount, dPrice, FPosition.Volume * -1, iDiv );

  except
  end;

end;

function TJikJinHult.DoOrder(aQuote: TQuote; dPrice : double; iQty: integer;
 iDiv : integer) : boolean;
var
  I, iCnt: Integer;
  aItem : TFundItem;
  res : Boolean;
begin
  result := false;
  try

    if FIsFund then
    begin

      iCnt := 0;
      for I := 0 to FFund.FundItems.Count - 1 do
      begin
        aItem := FFund.FundItems.FundItem[i];
        res := false;
        res := DoOrder( aQuote, aItem.Account, dPrice, iQty * aItem.Multiple, iDiv );
        if res then  inc( iCnt );
      end;

      if iCnt = FFund.FundItems.Count then
        Result := true
      else
        DoLog( Format('Fund 주문 실패 %d 중에 % 개만 주문 성공', [
          FFund.FundItems.Count, iCnt ]));

    end else
    begin
      result := DoOrder( aQuote, FAccount, dPrice, iQty, iDiv );
    end;

  except
  end;

end;

function TJikJinHult.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin

  if ( aACnt = nil ) or ( aSymbol = nil )  then
  begin
    result := false;
    exit;
  end;

  FAccount := aAcnt;
  FSymbol  := aSymbol;
  FIsFund  := false;

  FPosition := gEnv.Engine.TradeCore.Positions.Find( aAcnt, FSymbol );
  if FPosition = nil then
    FPosition := gEnv.Engine.TradeCore.Positions.New( aAcnt, FSymbol );

  result := true;

end;

function TJikJinHult.init(aFund: TFund; aSymbol: TSymbol): boolean;
begin

  if ( aFund = nil ) or ( aSymbol = nil )  then
  begin
    result := false;
    exit;
  end;

  FFund   := aFund;
  FIsFund := true;
  FSymbol := aSymbol;

  FFundPosition := gEnv.Engine.TradeCore.FundPositions.Find( aFund, FSymbol );
  if FFundPosition = nil then
    FFundPosition := gEnv.Engine.TradeCore.FundPositions.New( aFund, FSymbol );

  result := true;
end;

function TJikJinHult.IsCheck : boolean;
begin
  Result := false;

  if FSymbol = nil then Exit;
  if FIsFund and (FFund = nil) then Exit;
  if (not FIsFund) and (FAccount = nil) then Exit;

  Result := true;
end;


procedure TJikJinHult.SetParam(const Value: TJikJinHultData);
begin
  FParam := Value;
end;

function TJikJinHult.Start: boolean;
begin
  Result := false;
  if not IsCheck then Exit;


  FRun := true;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc);
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );

  DoLog( Format('%s Jikjin Hult Start', [ Symbol.Code]));

  FJJItem.reset;
  FLossCut  := false;
  FJJItem.IsFirst := true;

  Result := true;

  FSaveCur  := 0.0;

end;

procedure TJikJinHult.Stop;
begin
  if not FRun then Exit;
  
  FRun := false;
  if FParam.UseStopLiq then
    DoLossCut;
  DoLog( 'TJikJinHult  Stop' );
end;

procedure TJikJinHult.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: OnOrder(DataObj as TOrder, EventID);
      // position events
      {
    POSITION_NEW,
    POSITION_UPDATE   : OnPosition(DataObj as TPosition, EventID);
      }
  end;
end;

procedure TJikJinHult.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
  OnQuote( DataObj as TQuote );
end;

procedure TJikJinHult.OnFill(aOrder: TOrder);
var
  stSufix,stLog : string;
  aQuote : TQuote;
  aFill : TFill;

  dPrice : double;
  bDone : boolean;
begin

    aFill := Position.LastFill;
    bDone := false;
    stSufix := Format('%s %s ,%.2f, %d, %d ', [ SideToStr( aOrder.Side ),
              aOrder.Symbol.ShortCode, aOrder.FilledPrice, aOrder.FilledQty, aOrder.OrderNo ] );

    if aOrder.State = osFilled then
      case aOrder.OrderTag of
        0 :
          begin
            stLog := Format('사용자 임의 체결 -> %s ', [ stSufix ] );
            DoLog( stLog );
            if GetPosition = 0 then bDone := true;
          end;
        Ent_ord :
          begin
            stLog := Format('%d.th 진입 체결 -> %s ', [ FJJItem.Count, stSufix ] );
            if FJJItem.Done then
            begin
              DoPutOrder( aOrder.Symbol.Quote as TQuote, FJJItem.HitPrice );
              DoLog( '----------청산 주문 깔기-------------');
            end;
          end;
        Los_ord :
          begin
            stLog := Format('손절 주문 체결 -> %s ', [ stSufix ] );
            DoLog( stLog );
            if GetPosition = 0 then bDone := true;
          end;
        Pav_ord :
          begin
            stLog := Format('깔아놓은 주문 체결 -> %s ', [ stSufix ] );
            DoLog( stLog );
            if GetPosition = 0 then bDone := true;
          end;
      end;

  if bDone then
  begin
    FJJItem.reset;
    DoLog( ' 완료 후 리셋');
  end;     


end;

procedure TJikJinHult.OnOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  if not FRun then Exit;

  if FIsFund then begin
    if FFund.FundItems.Find2( aOrder.Account ) < 0 then Exit;
  end
  else begin
    if aOrder.Account <> FAccount then Exit;
  end;

  // normal 은 손으로 털었을경우를 대비해서
  if not (aOrder.OrderSpecies in [ opNormal, opBHult ]) then exit;

  if EventID in [ORDER_FILLED] then
    OnFill( aOrder );

  CheckOrderState( aOrder );
end;



procedure  TJikJinHult.CheckOrderState( aOrder : TOrder ) ;
begin
  if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
    FPavOrders.Remove( aOrder );
end;


procedure TJikJinHult.OnQuote( aQuote : TQuote );
var
  dtNow : TDateTime;
begin
  if not FRun then Exit;
  if FSymbol <> aQuote.Symbol then Exit;

  dtNow := Frac( GetQuoteTime );
  if dtNow < Frac(FParam.StartTime) then Exit;

  if dtNow > Frac(FParam.Endtime) then
  begin
    TFrmJikJinHult( FParent).cbStart.Checked := false;
    Exit;
  end;

  if FLossCut then Exit;

  if FIsFund then
    CheckLiskAmt_Fund( aQuote )
  else
    CheckLiskAmt( aQuote );

  if not FJJItem.IsReady then
    DoInit( aQuote )
  else begin
    DoWork( aQuote );
  end;

end;

procedure TJikJinHult.DoCancelOrder;
var
  I: Integer;
  aOrder : TOrder;
  pOrder  : TOrder;
  aTicket : TOrderTicket;
begin
  for I := 0 to FPavOrders.Count - 1 do
  begin
    aOrder := FPavOrders.Orders[i];
    if aOrder <> nil then
      if ( not aOrder.Modify ) and ( aOrder.ActiveQty > 0 ) and ( aOrder.State = osActive )  then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        pOrder := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aOrder, aOrder.ActiveQty, aTicket);

        if pOrder <> nil then
        begin

          gEnv.Engine.TradeBroker.Send( pOrder.Ticket );
          DoLog( Format( 'Cancel Order : %s, %s, %.2f, %d, %d ',
            [
              pOrder.Symbol.ShortCode,
              ifThenStr( pOrder.Side > 0 , 'L', 'S'),
              aOrder.Price,
              aOrder.ActiveQty,
              aOrder.OrderNo
            ]
            ));

        end ;
      end;
  end;

  FPavOrders.Clear;

end;

procedure TJikJinHult.DoInit( aQuote : TQuote );
var
  iSide : array [0..2] of integer;
  iTot, i, iSum : integer;
  dTmp, dUp, dDown : double;
  bSet : boolean;
begin

  if ( not FParam.UseCntRatio )
    and ( not FParam.UseVolRatio )
    and ( not FParam.UseDefTick ) then
    Exit;

  if aQuote.Sales.Count <= 0 then Exit;     

  bSet := false;

  if FJJItem.IsFirst then
    with FJJItem do
    begin
      for i:=0 to 2 do iSide[i] := 0;
      iTot  := 0;

      if FParam.UseCntRatio then
      begin
        inc( iTot );
        if (FParam.CntRatio > abs(aQuote.CntRatio)) and ( aQuote.CntRatio <> 0.0) then
          iSide[0] := ifThen( aQuote.CntRatio > 0, 1, -1 ) ;
      end;

      if FParam.UseVolRatio then
      begin
        inc( iTot );
        if (FParam.VolRatio > abs(aQuote.VolRatio)) and ( aQuote.VolRatio <> 0.0) then
          iSide[1] := ifThen( aQuote.VolRatio > 0, 1, -1 ) ;
      end;

      if FParam.UseDefTick then
      begin

        inc( iTot );

        if FParam.UseOpenPrc then
          dTmp := aQuote.Open
        else begin
          if FSaveCur < PRICE_EPSILON then
            FSaveCur := aQuote.Last;
          dTmp := FSaveCur;
        end;

        if dTmp > PRICE_EPSILON then
        begin
          dUp   := TicksFromPrice( FSymbol, aQuote.Open, FParam.DefTick );
          dDown := TicksFromPrice( FSymbol, aQuote.Open, -FParam.DefTick );
          if aQuote.Last > (dUp - PRICE_EPSILON )  then
            iSide[2] := 1;

          if aQuote.Last < ( dDown + PRICE_EPSILON )  then
            iSide[2] := -1;
        end;
      end;

      if ( iTot > 0 ) then
      begin
        iSum := 0;
        for i:=0 to 2 do iSum := iSum + iSide[i] ;
        if iSum = iTot then
          FJJItem.OrdSide := 1
        else if iSum = ( iTot * -1 ) then
          FJJItem.OrdSide := -1;
      end;

      if FJJItem.OrdSide <> 0 then
      begin
        bSet := true;
        FJJItem.BasePrice := aQuote.Last;
        FJJItem.StartPrice[ptLong]   := TicksFromPrice( FSymbol, aQuote.Last, FParam.OrdGap );
        FJJItem.StartPrice[ptShort]  := TicksFromPrice( FSymbol, aQuote.Last, -FParam.OrdGap );
      end;
    end;

  // 두번째 리셋일때는...현재가로만..
  if not FJJItem.IsFirst then
  begin
    bSet := true;
    FJJItem.BasePrice := aQuote.Last;
    FJJItem.StartPrice[ptLong]   := TicksFromPrice( FSymbol, aQuote.Last, FParam.OrdGap );
    FJJItem.StartPrice[ptShort]  := TicksFromPrice( FSymbol, aQuote.Last, -FParam.OrdGap );
  end;

  if bSet then

    if ( FJJItem.BasePrice > PRICE_EPSILON )
      and ( FJJItem.StartPrice[ptLong] > PRICE_EPSILON )
      and ( FJJItem.StartPrice[ptShort] > PRICE_EPSILON ) then
      begin
        DoLog( Format('Sucess %s Init %s base : %.2f,  %.2f : %.2f ( %.2f, %.2f, %.2f)  ',
         [  FSymbol.ShortCode,    ifThenStr( FJJItem.IsFirst,'First','later'),
          FJJItem.BasePrice, FJJItem.StartPrice[ptLong] , FJJItem.StartPrice[ptShort],
          aQuote.CntRatio, aQuote.VolRatio, aQuote.Open
           ]));
        FJJItem.IsReady := true;
        if FJJITem.IsFirst then
          FJJITem.IsFirst := false;
      end else
        DoLog( Format('Failed Init %s  base : %.2f,  %.2f : %.2f ',  [  FSymbol.ShortCode,
          FJJItem.BasePrice, FJJItem.StartPrice[ptLong] , FJJItem.StartPrice[ptShort] ]));

end;

procedure TJikJinHult.IsDone ;
begin
  if ( FJJItem.Count > 0 ) and (FJJItem.Count = FParam.LiqNum -1 ) and ( not FJJItem.Done ) then
  begin
    FJJItem.Done := true;
    DoLog( Format('%d.th(%d) 직진 완료 ', [ FJJItem.Count, FParam.LiqNum  ]));
  end;
end;

procedure TJikJinHult.DoWork( aQuote : TQuote ) ;
var
  iSide, iVol : integer;
  dPrice : double;
begin
  iVol := GetPosition;
  iSide:= 0;
  if (iVol = 0) and ( FJJItem.Count = 0 ) and ( not FJJItem.Done ) then
  begin
    // 기본적 체크
    if (aQuote.Last < PRICE_EPSILON )
      or ( FJJItem.StartPrice[ptLong] < PRICE_EPSILON )
      or ( FJJItem.StartPrice[ptShort] < PRICE_EPSILON ) then
      Exit;    

    // 같거나 클때
    if aQuote.Last > ( FJJItem.StartPrice[ptLong] - PRICE_EPSILON ) then begin
      iSide := 1;
      dPrice:= aQuote.Asks[4].Price;
    end
    else  if aQuote.Last < ( FJJItem.StartPrice[ptShort] + PRICE_EPSILON ) then begin
      iSide := -1;
      dPrice:= aQuote.Bids[4].Price;
    end;

    if iSide <> 0 then
      if DoOrder( aQuote , dPrice,  iSide * FParam.OrdQty, Ent_ord  ) then
      begin
        inc( FJJItem.Count );
        FJJItem.OrdSide   := iSide;
        FJJItem.LossPrice := FJJItem.BasePrice;
        if iSide > 0 then
          FJJItem.HitPrice  := TicksFromPrice( FSymbol, FJJItem.StartPrice[ptLong], FParam.OrdGap )
        else
          FJJItem.HitPrice  := TicksFromPrice( FSymbol, FJJItem.StartPrice[ptShort], -FParam.OrdGap );

        DoLog( Format('직진 시작 %s %s %.2f  next : %.2f  loss : %.2f', [ FSymbol.ShortCode,
          ifThenStr( iSide > 0, '매수', '매도'),
          FSymbol.Last,   FJJItem.HitPrice,   FJJItem.LossPrice]) );

        IsDone;

      end else
        DoLog( Format('직진 실패 %s %s %.2f, %.2f', [ FSymbol.ShortCode,
          ifThenStr( iSide > 0, '매수', '매도'), FSymbol.Last,
          ifThenFloat( iSide > 0,  FJJItem.StartPrice[ptLong], FJJItem.StartPrice[ptShort])]) );

  end
  else begin
    if (iVol > 0) and ( FJJItem.Count > 0 )  then
    begin
      // 계속 매수 진입
      if ( not FJJItem.Done ) and ( FJJItem.Count <  ( FParam.LiqNum - 1 ))
         and ( aQuote.Last > ( FJJItem.HitPrice - PRICE_EPSILON )) then
      begin
        iSide := 1;
        dPrice:= aQuote.Asks[4].Price;

        if DoOrder( aQuote , dPrice, FParam.OrdQty , Ent_ord ) then
        begin

          DoLog( Format('%d.th 매수 진입 %s %.2f, %.2f', [ FJJItem.Count+1 ,
             FSymbol.ShortCode, FSymbol.Last,  FJJItem.HitPrice]) );

          FJJItem.update( FSymbol, 1, FParam.OrdGap);

          DoLog( Format('상승%d Next Hit : %.2f  Los : %.2f', [ FJJItem.Count, FJJItem.HitPrice, FJJItem.LossPrice]));

          IsDone;

        end else
          DoLog( Format('%d.th 매수 진입 실패 %s %.2f, %.2f', [ FJJItem.Count +1,
             FSymbol.ShortCode, FSymbol.Last,   FJJItem.HitPrice]) );
      end else
      // 매수 청산
      if aQuote.Last < ( FJJItem.LossPrice + PRICE_EPSILON ) then
      begin
        iSide := -1;
        dPrice:= aQuote.Bids[4].Price;

        if DoOrder( aQuote , dPrice, -FParam.OrdQty, Los_ord  ) then
        begin

          DoLog( Format('%d.th 매수 청산 %s %.2f, %.2f', [ FJJItem.Count ,
             FSymbol.ShortCode, FSymbol.Last,  FJJItem.LossPrice]) );

          FJJItem.update( FSymbol, -1, -FParam.OrdGap);

          DoLog( Format('상승%d Next Hit : %.2f  Los : %.2f', [ FJJItem.Count, FJJItem.HitPrice, FJJItem.LossPrice]));

          // 청산 주문 대놨는데...밀려서 손절 나갔으면..
          if FJJItem.Done then
          begin
            DoCancelOrder;
            FJJItem.Done := false;
            DoLog( '깔아놓은 매수 청산 주문취소..' );
          end;

        end else
          DoLog( Format('%.th 매수 청산 실패 %s %.2f, %.2f', [ FJJItem.Count ,
             FSymbol.ShortCode, FSymbol.Last,  FJJItem.LossPrice]) );
      end;

    end else
    if (iVol < 0) and ( FJJItem.Count > 0 ) then
    begin
      // 계속 매도 진입
      if ( not FJJItem.Done ) and ( FJJItem.Count <  ( FParam.LiqNum - 1 ))
          and (aQuote.Last < ( FJJItem.HitPrice + PRICE_EPSILON )) then
      begin
        iSide := -1;
        dPrice:= aQuote.Bids[4].Price;

        if DoOrder( aQuote , dPrice, -FParam.OrdQty, Ent_ord  ) then
        begin
          DoLog( Format('%d.th 매도 진입 %s %.2f, %.2f', [ FJJItem.Count+1 ,
             FSymbol.ShortCode, FSymbol.Last,  FJJItem.HitPrice]) );

          FJJItem.update( FSymbol, 1, -FParam.OrdGap);

          DoLog( Format('하라 %d Next Hit : %.2f  Los : %.2f', [ FJJItem.Count, FJJItem.HitPrice, FJJItem.LossPrice]));

          IsDone;

        end else
          DoLog( Format('%d.th 매도 진입 실패 %s %.2f, %.2f', [ FJJItem.Count +1,
             FSymbol.ShortCode, FSymbol.Last,   FJJItem.HitPrice]) );
      end else
      // 매도 청산
      if aQuote.Last > ( FJJItem.LossPrice - PRICE_EPSILON ) then
      begin
        iSide := 1;
        dPrice:= aQuote.Asks[4].Price;

        if DoOrder( aQuote , dPrice, FParam.OrdQty, Los_ord  ) then
        begin

          DoLog( Format('%d.th 매도 청산 %s %.2f, %.2f', [ FJJItem.Count ,
             FSymbol.ShortCode, FSymbol.Last,  FJJItem.LossPrice]) );

          FJJItem.update( FSymbol, -1, FParam.OrdGap);

          DoLog( Format('하라%d Next Hit : %.2f  Los : %.2f', [ FJJItem.Count, FJJItem.HitPrice, FJJItem.LossPrice]));

          // 청산 주문 대놨는데...밀려서 손절 나갔으면..
          if FJJItem.Done then
          begin
            DoCancelOrder;
            FJJItem.Done := false;
            DoLog( '깔아놓은 매수 청산 주문취소..' );
          end;

        end else
          DoLog( Format('%d.th 매도 청산 실패 %s %.2f, %.2f', [ FJJItem.Count ,
             FSymbol.ShortCode, FSymbol.Last,  FJJItem.LossPrice]) );
      end;

    end;
  end;
end; 

function TJikJinHult.GetPL: double;
begin
  result := 0;
  if FIsFund then begin
    if FFundPosition <> nil then
      Result := FFundPosition.LastPL / 1000;
  end else
  begin
    if FPosition <> nil then
      result := FPosition.LastPL / 1000;
  end;
end;

function TJikJinHult.GetPosition: integer;
begin
  result := 0;
  if FIsFund then begin
    if FFundPosition <> nil then
      result := FFundPosition.Volume;
  end else
  begin
    if FPosition <> nil then
      result := FPosition.Volume;
  end;
end;

procedure TJikJinHult.CheckLiskAmt_Fund(aQuote: TQuote);
var
  I, iDiv: Integer;
  dPL : double;
  aPos: TPosition;
  aItem : TFundItem;
begin


  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aItem := FFund.FundItems.FundItem[i];
    aPos := FFundPosition.Positions.FindPosition( aItem.Account);
    if aPos = nil then continue;

    iDiv := Max( 1, aItem.Multiple );

    dPL := aPos.LastPL / 10000;

    if (dPL > 0) and ( dPL > FParam.PlusAmt * iDiv  ) and ( FParam.PlusAmt > 1 ) then
    begin
      FLossCut := true;
      DoLog( Format('Fund 중 %s 손익 이익달성 (%.0f)(%d) ',  [ aItem.Account.Code, dPL * 10, iDiv] ));
      break;
    end else
    if ( dPL < 0 ) and ( dPL <  -FParam.PlusAmt * iDiv  ) then
    begin
      FLossCut := true;
      DoLog( Format('Fund 중 %s 손익 한도초과로 (%.0f)(%d) ',  [ aItem.Account.Code, dPL * 10, iDiv] ));
      break;
    end;
  end;

  if FLossCut then
    Stop;

end;

procedure TJikJinHult.CheckLiskAmt( aQuote : TQuote );
var
  dPL: double;
begin

  if FPosition = nil then Exit;
  
  dPL := FPosition.LastPL / 10000;

  if dPL < 0 then
    if -FParam.RiskAmt > dPL then
    begin
      //Stop;
      FLossCut := true;
      DoLog( Format('손익 한도초과로 (%.0f) ',  [ dPL * 10] ));
    end;

  if (dPL > 0) and ( FParam.PlusAmt > 1 ) then
    if FParam.PlusAmt < dPL then
    begin
      FLossCut := true;
      DoLog( Format('손익 이익달성 (%.0f) ',  [ dPL * 10] ));
    end;

  if FLossCut then
    Stop;
end;

{ TJikJinItem }

procedure TJikJinItem.update(aSymbol: TSymbol; iSide, iGap: integer);
begin
   Count := Max(0, Count + iSide);
   LossPrice := TicksFromPrice( aSymbol, LossPrice, iGap );
   HitPrice  := TicksFromPrice( aSymbol, HitPrice,  iGap );
end;

procedure TJikJinItem.reset;
begin
    BasePrice := 0.0;
    HitPrice  := 0.0;
    LossPrice := 0.0;

    StartPrice[ptLong] := 0.0;
    StartPrice[ptShort] := 0.0;

    Count     := 0;
    OrdSide   := 0;
    IsReady   := false;
    Done      := false;
end;

end.
