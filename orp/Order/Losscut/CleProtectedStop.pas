unit CleProtectedStop;

interface

uses
  Classes, SysUtils, Math,

  CleLossCut, CleOrders, GleTypes, DateUtils, GleConsts,

  ClePositions, CleQuoteBroker, CleSymbols , CleQuoteTimers

  ;
type

  TStopExecCondition = ( ecDeposit, ecSameSide, ecCurrent );
  TStopQtyCondition  = ( ocMinFixNClear, ocClearDivN );
  TStopOrderPrice    = ( opDeposit, opSameSide );


  TProtectedStopParams = record
    // 실행조건
    ExecCondition : TStopExecCondition;
    ecDepositVal  : double;
    ecSameSideVal : double;
    ecCurrentVal  : double;

    // 주문 수량 조건
    OrderQtyCondition : TStopQtyCondition;
    FixedOrderQTy     : integer;
    ClearQtyDivN      : integer;
    // 주문가격
    OrderPrice   : TStopOrderPrice;
    TickQty      : integer;

    // 주문정정
    OnAutoModify  : boolean;
    AutoModifyCnt : integer;
    AutoModifySec : integer;
  end;


  TProtecteOrder = class( TCollectionItem )
  public
    OrderItem : TOrder;
    Accepttime: TDateTime;
    IsChange  : Boolean;
    ChangeCnt : integer;
  end;


  TProtectedStop = class( TLossCut )
  private
    FProtectedParam: TProtectedStopParams;
    FStart: boolean;
    FOrderList: TList;
    FChangeList : TList;
    FTimer: TQuoteTimer;
    FRow  : integer;
    FGray : integer;
    FParent: TObject;
    procedure SetProtecteParam(const Value: TProtectedStopParams);
    procedure Log;
    procedure LossCutLog( stLog : string );
    function CheckExeCondition( var iRow : integer): boolean;
    procedure DoCheckOrder( irow : integer );
    procedure DoAutoChange( iRow : integer );
    function GetOrderPrice( iSide : integer; bFill : boolean = false ) : double;
    function GetOrderQuote( bLong : boolean ) : double;
    function FindOrder(aOrder: TOrder): TOrder;
    procedure DeleteOrder(aOrder: TOrder);
  public
    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;
    //
    procedure Run; virtual;
    procedure Stop; virtual;
    //
    procedure CheckLossCut;  virtual;
    procedure DoQuote( aQuote : TQuote );  override;
    procedure DoPosition( aPosition : TPosition ); override;
    procedure DoOrder( aOrder : TOrder ) ; override;
    procedure TimerTimer(Sender: TObject);


    property  Start : boolean read FStart write FStart;
    property  ProtecteParam : TProtectedStopParams read FProtectedParam write SetProtecteParam;
    property  OrderList : TList read FOrderList write FOrderList;
    property  Timer : TQuoteTimer read FTimer write FTimer;
    property  Parent: TObject read FParent;
  end;

implementation

uses
  GleLib, Dialogs, GAppEnv, DProtectedStop, CleKrxSymbols, Graphics;

{ TProtectedSto }

{
constructor TProtectedStop.Create;
begin
  inherited;
  FOrderList  := TList.Create;
  FChangeList := TList.Create;
  FStart  := false;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 200;
  FTimer.OnTimer  := TimerTimer;

  FRow  := 1;
  FGray := 0;
end;
 }
destructor TProtectedStop.Destroy;
begin
  FTimer.Free;
  FStart  := false;
  FOrderList.Free;
  FChangeList.Free;
  inherited;
end;

procedure TProtectedStop.DoPosition(aPosition: TPosition);
begin
  if aPosition.Symbol <> Symbol then Exit;
  if aPosition.Account <> Account then Exit;

  Position := aPosition;

  CheckLossCut;
end;

procedure TProtectedStop.DoQuote(aQuote: TQuote);
begin

  if aQuote.Symbol <> Symbol then Exit;

  CheckLossCut;
end;

function TProtectedStop.GetOrderPrice(iSide: integer; bFill : boolean): double;
begin
  Result := 0;
  with FProtectedParam do
    case OrderPrice of
      opDeposit:
        if iSide = 1 then
          Result  := Quote.Bids[0].Price
        else
          Result  := Quote.Asks[0].Price;
      opSameSide:
        if iSide = 1 then
          Result := TicksFromPrice(Symbol, Quote.Asks[0].Price, TickQty * -1 )
        else
          Result := TicksFromPrice(Symbol, Quote.Bids[0].Price, TickQty );
    end;

  if bFill then
  begin
    if iSide = 1 then
      Result  := Quote.Bids[0].Price
    else
      Result  := Quote.Asks[0].Price;
  end;

end;

function TProtectedStop.GetOrderQuote(bLong : boolean): double;
begin
  Result := 0;
  case FProtectedParam.ExecCondition of
    ecDeposit:
      begin
        if bLong then
        begin
          Result:= Quote.Bids[0].Price;
        end
        else begin
          Result:= Quote.Asks[0].Price;
        end;
      end;
    ecSameSide:
      begin
        if bLong then
        begin
          Result:= Quote.Asks[0].Price;
        end
        else begin
          Result:= Quote.Bids[0].Price;
        end;
      end;
    ecCurrent:
      begin
        Result:= Quote.Last;
      end;
  end;
end;

procedure TProtectedStop.Run;
var
  stLog : string;
begin
  if Symbol = nil then
  begin
    ShowMessage('종목설정을 하세용');
    Exit;
  end;

  if Account = nil then
  begin
    ShowMessage('계좌설정하세용');
    Exit;
  end;

  //if Position = nil then
  Position  := gEnv.Engine.TradeCore.Positions.Find( Account, Symbol );

  FStart  := true;
  FTimer.Enabled  := true;

  stLog := Format('Run : %s , %s ', [ Account.Code, Symbol.ShortCode ] );
  gLog.Add( lkLossCut, 'TProtectedStop', 'Run', stLog, nil, true);

  {
  ProtectStopOrder.sgLog.Cells[0,0] := Symbol.Code;
  ProtectStopOrder.sgLog.Cells[1,0] := Account.Code;
  }


end;

procedure TProtectedStop.SetProtecteParam(const Value: TProtectedStopParams);
begin
  FProtectedParam := Value;
end;

procedure TProtectedStop.Stop;
var
  i, j : Integer;
  stLog : string;
  aPso : TProtectStopOrder;

begin
  FStart := false;
  FTimer.Enabled  := false;

  if FParent = nil then
    Exit;

  if FParent is TProtectStopOrder then
  begin
    aPso := FParent as TProtectStopOrder;
    for i := 1 to aPso.sgLog.RowCount - 1 do
      for j := 0 to aPso.sgLog.ColCount - 1 do
        aPso.sgLog.Cells[j,i] := '';
  end;

  if (Account <> nil) and (Symbol <> nil) then
  begin
    stLog := Format('Stop : %s, %s', [ Account.Code, Symbol.ShortCode ] );
    gLog.Add( lkLossCut, 'TProtectedStop', 'Run', stLog, nil, true);
  end;
end;

procedure TProtectedStop.TimerTimer(Sender: TObject);
var
  i : integer;
  aOrder  : TOrder;
  sta, stLog : string;
begin
  for I := FOrderList.Count - 1 downto 0 do
  begin
    aOrder  := TOrder( FOrderList.Items[i] );
    if aOrder.State in [osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then
      if (  aOrder.OrderType <> otChange ) and (aOrder.State <> osConfirmed) then
        FOrderList.Delete(i);
  end;
 {
  if FOrderList.Count > 0 then
  gLog.Add( lkLossCut, 'TProtectedStop', 'DoOrder', 'count : ' + inttostr( FOrderList.Count ), nil, true);
  }
end;

procedure TProtectedStop.Log;
var
  aPso : TProtectStopOrder;
begin
  if (Position <> nil) and ( FParent <> nil ) then
  begin
    if FParent is TProtectStopOrder then
    begin
      aPso := FParent as TProtectStopOrder;

      if Position.Volume = 0 then
        aPso.plSide.Color := clBtnFace
      else if Position.Volume > 0 then
        aPso.plSide.Color := clRed
      else
        aPso.plSide.Color := clBlue;
    end
  end;
end;


procedure TProtectedStop.LossCutLog(stLog: string);
var
  aPso : TProtectStopOrder;
begin

  if FParent = nil then
    Exit;

  aPso := FParent as TProtectStopOrder;

  aPso.sgLog.Objects[0,FRow]  := Pointer( FGray );
  aPso.sgLog.Cells[0,FRow]  := FormatDateTime( 'nn:ss.zzz', GetQuoteTime );
  aPso.sgLog.Cells[1,FRow]  := stLog;


  if (FRow + 1) > (aPso.sgLog.RowCount-1)  then
  begin
    FRow := 1;
    if FGray = 100 then
      FGray := 0
    else
      FGray:= 100;
  end
  else begin
    FRow := FRow + 1;
  end;

end;

procedure TProtectedStop.CheckLossCut;
var
  bRes : boolean;
  iRow : integer;
begin
  Log;

  if not FStart then Exit;
  // 실행조건 Check
  iRow := -1;
  bRes := CheckExeCondition( iRow );

  if bRes then
  begin
    DoCheckOrder( iRow );
  end;

  DoAutoChange( iRow );

end;

constructor TProtectedStop.Create(aObj: TObject);
begin
  inherited Create;
  FOrderList  := TList.Create;
  FChangeList := TList.Create;
  FStart  := false;
  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 200;
  FTimer.OnTimer  := TimerTimer;

  FRow  := 1;
  FGray := 0;

  FParent := aObj;
end;

function TProtectedStop.CheckExeCondition( var iRow : integer): boolean;
var
  bLong : boolean;
  dGap, dPrice, dCon  : double;
  //iRow : integer;
begin
  Result := false;

  if (Position = nil) or ( Quote = nil ) then Exit;

  if Position.Volume = 0 then Exit;

  if Position.Volume > 0 then
    bLong := true
  else
    bLong := false;

  dPrice  := 0;
  dGap    := 0;

  case FProtectedParam.ExecCondition of
    ecDeposit:
      begin
        dCon  := FProtectedParam.ecDepositVal;
        if bLong then
        begin
          dPrice:= Quote.Bids[0].Price;
          dGap  := Position.AvgPrice - dPrice;
          if dGap > dCon + PRICE_EPSILON then
            Result := true;
          iRow  := 1;
        end
        else begin
          dPrice:= Quote.Asks[0].Price;
          dGap  := dPrice - Position.AvgPrice;
          if dGap > dCon + PRICE_EPSILON then
            Result := true;
          iRow := 2;
        end;
      end;
    ecSameSide:
      begin
        dCon  := FProtectedParam.ecSameSideVal;
        if bLong then
        begin
          dPrice:= Quote.Asks[0].Price;
          dGap  := Position.AvgPrice - dPrice;
          if dGap > dCon+ PRICE_EPSILON then
            Result := true;
          iRow  := 3;
        end
        else begin
          dPrice:= Quote.Bids[0].Price;
          dGap  := dPrice - Position.AvgPrice;
          if dGap > dCon + PRICE_EPSILON then
            Result := true;
          iRow := 4;
        end;
      end;
    ecCurrent:
      begin
        dCon  := FProtectedParam.ecCurrentVal;
        dPrice:= Quote.Last;
        if bLong then
        begin
          dGap  := Position.AvgPrice - dPrice;
          if dGap > dCon + PRICE_EPSILON  then
            Result := true;
          iRow  := 5;
        end
        else begin
          dGap  := dPrice - Position.AvgPrice;
          if dGap > dCon + PRICE_EPSILON  then
            Result := true;
          iRow := 6;
        end;
      end;
  end;

end;

procedure TProtectedStop.DoCheckOrder( irow : integer );
var
  iGap, iSide, i, iLimit, iQty, iOrdQty : integer;
  dPrice  : double;
  aOrder  : TOrder;
  stTmp, stLog   : string;
  aTicket : TOrderTicket;
begin

  if Position.Volume > 0 then
    iSide := 1
  else
    iSide := -1;

  iQty := 0;
  stTmp := '';
  for i := 0 to FOrderList.Count - 1 do
  begin
    aOrder  := TOrder( FOrderList.Items[i] );
    if (aOrder.Symbol <> Position.Symbol) or ( aOrder.Account <> Position.Account) then
      Continue;

    if (iSide + aOrder.Side ) <> 0 then
      Continue;

    case aOrder.State of
      osActive : iQty := iQty + aOrder.ActiveQty;
      osSent, osReady, osSrvAcpt  :  iQty := iQty + aOrder.OrderQty;
      else begin
        if (aOrder.OrderType = otChange) and ( aOrder.State = osConfirmed ) then
          iQty  := iQty + aOrder.ConfirmedQty
        else
          Continue;
      end;
    end;
  end;

  iGap  := abs( Position.Volume ) - iQty ;

  if iGap <= 0 then
    Exit;

  iOrdQty := 0;

  with FProtectedParam do
    case OrderQtyCondition of
      ocMinFixNClear:
        begin
          if FixedOrderQTy > 0 then
            iLimit := Min( abs( Position.Volume ), FixedOrderQTy )
          else
            iLimit := abs( Position.Volume );
          iOrdQty := iLimit - iQty;
        end;

      ocClearDivN:
        begin
          if ClearQtyDivN <= 0 then
            iLimit  := abs( Position.Volume ) div 1
          else
            iLimit  := abs( Position.Volume ) div ClearQtyDivN;

          if iLimit = 0 then
            iLimit:= abs( Position.Volume );
          iOrdQty := iLimit - iQty;
        end;
    end;

  if iOrdQty <= 0 then
    Exit;

  iOrdQty := iOrdQty * iSide * -1;

  // 주문 가격 구하기...........................................................
  dPrice  := GetOrderPrice( iSide );
  if dPrice - PRICE_EPSILON <= 0 then Exit;

  stLog :=  Format('O:%s,%d,%.2f,%d|P:%.2f|L:%.2f,C:%.2f,S:%.2f ',[
    ifThenStr( iOrdQty > 0 , 'L','S'),
    iOrdQty, dPrice,
    Position.Volume,
    Position.AvgPrice,
    Quote.Bids[0].Price, Quote.Last, Quote.Asks[0].Price

    ]
    );


  aOrder := nil;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
    gEnv.ConConfig.UserID,
    Account, Symbol,
    iOrdQty, pcLimit, dPrice, tmFAS , aTicket
    ) ;

  aOrder.OrderSpecies := opProtecte;

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket);
    FOrderList.Add( aOrder );
    Beep;
    {
    ProtectStopOrder.sgLog.Cells[5, iRow]  :=  Format( '%.2f|%s|%d ', [ dPrice,
      ifThenStr( aOrder.Side = 1, 'L', 'S'), aOrder.OrderQty ]);
    }

    LossCutLog( stLog );
    gLog.Add( lkLossCut, 'TProtectedStop', 'DoCheckOrder', stLog, nil,  true);
  end;
end;

procedure TProtectedStop.DoOrder(aOrder: TOrder);
var
  fOrder : TOrder;
  sta : string;
begin
  if (aOrder.Account <> Account) or (aOrder.Symbol <> Symbol) then Exit;

  gEnv.DoLog(WIN_TEST, sta);

  if (aOrder.State = osActive) and (aOrder.OrderType = otNormal)  then
  begin

  end else
  if aOrder.State in  [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
  begin
    DeleteOrder( aOrder );
  end;

end;

procedure TProtectedStop.DeleteOrder(aOrder : TOrder);
var
  i : integer;
begin
  for i := FOrderList.Count -1 downto 0 do
    if TOrder( FOrderList.Items[i] ) = aOrder then
    begin
      FOrderList.Delete(i);
      break;
    end;

end;

function TProtectedStop.FindOrder(aOrder : TOrder): TOrder;
var
  i : integer;
  oOrder : TOrder;
begin
  Result := nil;

  for i := FOrderList.Count -1 downto 0 do
  begin
    oOrder := TOrder( FOrderList.Items[i] );
    if oOrder = nil then Continue;

    if ( oOrder.LocalNo = aOrder.LocalNo ) then
    begin
      Result := oOrder;
      break;
    end;
  end;
end;

procedure TProtectedStop.DoAutoChange( iRow : integer );
var
  iSec : int64;
  dtNow : TDateTime;
  aOrder, nOrder : TOrder;
  iSide, i, iCom : integer;
  bMarketPrice, bOk : boolean;
  dPrice : double;
  aTicket : TOrderTicket;
  aPC : TPriceControl;
  stLog : string;
begin
  if not FProtectedParam.OnAutoModify then Exit;
  if Position = nil then Exit;
  if Position.Volume = 0 then Exit;
  

  dtNow := GetQuoteTime;

  for i := 0 to FOrderList.Count - 1 do
  begin
    aOrder := TOrder( FOrderList.Items[i] );

    if (aOrder.State = osActive) and ( aOrder.ActiveQty > 0) and ( aOrder.OrderType = otNormal)  then
    begin

    bOk  := false;
    iSec := MilliSecondsBetween( dtNow , aOrder.AcptTime );

    if (aOrder.ModifyCnt = 0 ) then
    begin
      if (iSec >= FProtectedParam.AutoModifySec ) then
        bOK := true;
    end
    else if (aOrder.ModifyCnt > 0) and  ( FProtectedParam.AutoModifyCnt >= aOrder.ModifyCnt) then
      bOK := true;

    if bOk then
    begin
      dPrice  := GetOrderPrice( aOrder.Side * -1 , FProtectedParam.AutoModifyCnt = aOrder.ModifyCnt );
      if dPrice - PRICE_EPSILON <= 0 then Continue;

        //가격비교
      iCom  := CompareStr( Format( '%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]),
        Format( '%.*n', [ aOrder.Symbol.Spec.Precision, dPrice ]));

      if iCom <> 0 then
      begin
        // 정정 주문 발주..
        if aOrder.Modify then
          Continue;

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        nOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrder( aOrder, aOrder.ActiveQty,
        pcLimit, dPrice, tmFAS , aTicket
        );
        nOrder.OrderSpecies := opProtecte;

        if nOrder <> nil then
        begin
          nOrder.ModifyCnt := aOrder.ModifyCnt + 1;
          FOrderList.Add( nOrder );
          gEnv.Engine.TradeBroker.Send( aTicket );

          //ProtectStopOrder.sgLog.Cells[6, iRow]  :=  Format( '%d ', [nOrder.ModifyCnt ]);

          stLog := Format('C:%d,%s,->%s,%d,%d|L:%.2f,C:%.2f,S:%.2f', [
            nOrder.ModifyCnt,
            Format( '%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price]),
            Format( '%.*n', [ aOrder.Symbol.Spec.Precision, dPrice ]),
            aOrder.ActiveQty,
            Position.Volume,
            Quote.Bids[0].Price, Quote.Last, Quote.Asks[0].Price

           ]);
          LossCutLog( stLog );
          gLog.Add( lkLossCut, 'TProtectedStop', 'DoAutoChange', stLog, nil, true);
        end;

      end;
    end;
    end;

  end;
end;



end.
