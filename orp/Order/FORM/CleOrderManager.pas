unit CleOrderManager;

interface

uses
  Classes, SysUtils, Math,

  CleFrontOrderIF, CleQuoteBroker, CleSymbols, CleOrders,
  CleDistributor, CleQuoteTimers, CleKrxSymbols,
  GleLib, GleTypes, GleConsts

  ;

type

  TOrderManager = class( TFrontOrderIF )
  private
    FQuote  : TQuote;
    QuoteTime : TDateTime;
    FRun    : boolean;
    //FCheck  : boolean;
    FTimer  : TQuoteTimer;
    procedure DoCancel( aOrder : TOrder ); overload;
    procedure DoCancel( aOrder : TOrder; iOrdQty :integer ); overload;

    procedure AddOrder( bAsk : boolean ; aOrder : TOrder; var aList : TList );
    procedure AddAskOrder( aOrder : TOrder; var aList : TList );
    procedure AddBidOrder( aOrder : TOrder; var aList : TList );
  public
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function Start : boolean; virtual;
    procedure Stop; virtual;
    procedure Reset; virtual;
    procedure Observer; virtual;

    procedure DoTimer(Sender: TObject);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

  end;

implementation

uses
  GAppEnv, CleAccounts;

{ TJangJungManager }

procedure TOrderManager.AddAskOrder(aOrder: TOrder; var aList: TList);
var
  i, iCom : integer;
  bAdd : boolean;
  pOrder : TOrder;
  stSrc, stDsc : string;
begin

  bAdd := false;

  stSrc := Format('%*n',
    [ aOrder.Symbol.Spec.Precision,
      aOrder.Price
    ]
    );

  for i := aList.Count-1 downto 0 do
  begin
    pOrder := TOrder( aList.Items[i] );
    if pOrder = nil then
      Continue;

    stDsc := Format('%*n',
      [ pOrder.Symbol.Spec.Precision,
        pOrder.Price
      ] );
    // stSrc 가 크면 +
    iCom     := CompareStr( stSrc, stDsc );

    if iCom > 0 then
      break
    else if iCom = 0 then begin
      if aOrder.OrderNo > pOrder.OrderNo then
        break
      else begin
        bAdd := true;
        aList.Insert( i, aOrder);
        break;
      end;
    end;
  end;
  if not bAdd then
    aList.Add( aOrder );
end;

procedure TOrderManager.AddBidOrder(aOrder: TOrder; var aList: TList);
var
  i, iCom : integer;
  bAdd : boolean;
  pOrder : TOrder;
  stSrc, stDsc : string;
begin

  bAdd := false;

  stSrc := Format('%*n',
    [ aOrder.Symbol.Spec.Precision,
      aOrder.Price
    ]
    );

  for i := aList.Count-1 downto 0 do
  begin
    pOrder := TOrder( aList.Items[i] );
    if pOrder = nil then
      Continue;

    stDsc := Format('%*n',
      [ pOrder.Symbol.Spec.Precision,
        pOrder.Price
      ] );
    // stDsc 가 크면 +
    iCom     := CompareStr(stDsc, stSrc );

    if iCom > 0 then
      break
    else if iCom = 0 then begin
      if aOrder.OrderNo > pOrder.OrderNo then
        break
      else begin
        bAdd := true;
        aList.Insert( i, aOrder);
        break;
      end;
    end;
  end;
  if not bAdd then
    aList.Add( aOrder );

end;

procedure TOrderManager.AddOrder(bAsk: boolean; aOrder: TOrder;
  var aList: TList);
begin
  if bAsk then
    AddAskOrder( aOrder, aList )
  else
    AddBidOrder( aOrder, aList );

end;

constructor TOrderManager.Create(aColl: TCollection);
begin
  inherited;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;

  FTimer.Interval := 100;
  FTimer.OnTimer  := DoTimer;
  FTimer.Enabled  := false;

  FQuote  := nil;
  FRun    := false;
  //FCheck  := false;
end;

destructor TOrderManager.Destroy;
begin
  
  FTimer.Enabled := false;
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FTimer.Free;
  inherited;
end;      


procedure TOrderManager.DoCancel( aOrder : TOrder );
var
  aTicket : TOrderTicket;
  pOrder  : TOrder;
  stLog   : string;
begin

  if aOrder.ActiveQty <= 0 then Exit;

  if aOrder.Modify then Exit;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(
    aOrder, aOrder.ActiveQty, aTicket );

  if pOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket );
    gEnv.Engine.TradeCore.Orders.DoNotify( pOrder );
    stLog := Format( 'Cancel Order : %s, %.2f, %d, %d [%s, %d, %.2f|%.2f ]',
      [
        ifThenStr( pOrder.Side > 0 , 'L', 'S'),
        aOrder.Price,
        aOrder.ActiveQty,
        aOrder.OrderNo,

        ifthenStr( SelectedItem.Position.Volume > 0 , 'L',
          ifThenStr( SelectedItem.Position.Volume < 0, 'S', ' ')),
        abs( SelectedItem.Position.Volume ),
        FQuote.Asks[0].Price,
        FQuote.Bids[0].Price
      ]
      );
    EnvLog( stLog );
  end ;
end;


procedure TOrderManager.DoCancel(aOrder: TOrder; iOrdQty: integer);
var
  aTicket : TOrderTicket;
  pOrder  : TOrder;
  stLog   : string;
begin

  if aOrder.ActiveQty <= 0 then Exit;

  if aOrder.Modify then Exit;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
  pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(
    aOrder, Min(iOrdQty, aOrder.ActiveQty), aTicket );

  if pOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket );
    gEnv.Engine.TradeCore.Orders.DoNotify( pOrder );
    stLog := Format( 'Part Cancel Order : %s, %.2f, %d(%d), %d  [%s, %d, %.2f|%.2f ]',
      [
        ifThenStr( pOrder.Side > 0 , 'L', 'S'),
        aOrder.Price,
        iOrdQty,
        aOrder.ActiveQty,
        aOrder.OrderNo,

        ifthenStr( SelectedItem.Position.Volume > 0 , 'L',
          ifThenStr( SelectedItem.Position.Volume < 0, 'S', ' ')),
        abs( SelectedItem.Position.Volume ),
        FQuote.Asks[0].Price,
        FQuote.Bids[0].Price
      ]
      );
    EnvLog( stLog );
  end ;

end;

procedure TOrderManager.DoTimer(Sender: TObject);
begin
  if ( FQuote = nil) or ( Account = nil ) then Exit;
  Observer;

end;

procedure TOrderManager.Observer;
var
  i, iSu, iA, iB, iLv, iSv, iAsks, iBids : integer;
  aOrder, pOrder : TOrder;
  AskPrice, BidPrice : double;
  BidList, AskList   : TList;
  aExt, bExt : boolean;
  aAccount : TAccount;
  stLog : string;
begin

  if (FQuote.Asks[0].Price < PRICE_EPSILON) or
     (FQuote.Bids[0].Price < PRICE_EPSILON) then
  begin

    Exit;
  end;

  iAsks := Param.Asks;
  iBids := Param.Bids;


  if (iAsks >=1) and (iAsks <= 5) then
    AskPrice  := FQuote.Asks[iAsks-1].Price
  else if iAsks <= 0 then
    Exit
  else
    AskPrice  := TicksFromPrice( FQuote.Symbol, FQuote.Asks[0].Price, iAsks -1 );

  if (iBids >=1) and (iBids <= 5) then
    BidPrice  := FQuote.Bids[iBids-1].Price
  else if iBids <= 0 then
    Exit
  else
    BidPrice  := TicksFromPrice( FQuote.Symbol, FQuote.Bids[0].Price, -( iBids-1) );
  {
  EnvLog( Format('AskPrice : %.2f|%.2f  , BidPrice : %.2f|%.2f',
        [ FQuote.Asks[0].Price, AskPrice, FQuote.Bids[0].Price, BidPrice ])
  );
  }
  //aAccount := gEnv.Engine.FormManager.FAccount;

  try

    if SelectedItem = nil then Exit;

    BidList := TList.Create;
    AskList := TList.Create;

    iA := 0; iB := 0; i:=0;
    iSu:= ( SelectedItem.AskOrders.Count ) + ( SelectedItem.BidOrders.Count );
    aExt := false;  bExt := false;

    iSv := 0; iLv := 0;

    while i < iSu do
    begin
      if aExt and bExt then break;

      if iA < SelectedItem.AskOrders.Count then
      begin
        aOrder  := TOrder( SelectedItem.AskOrders.Items[iA]);
        if (aOrder.Price  < AskPrice + PRICE_EPSILON) and
          ( not aOrder.Modify ) and
          ( aOrder.OrderType = otNormal )  then
        begin
          if (aOrder.Symbol = FQuote.Symbol) and ( Account = aOrder.Account ) then
          begin
            //AskList.Add( aOrder );
            AddOrder( true, aOrder, AskList );
            inc( iSv, aOrder.ActiveQty );
          end;
          inc( iA );
        end
        else aExt := true;
      end
      else aExt := true;

      if iB < SelectedItem.BidOrders.Count then
      begin
        aOrder  := TOrder( SelectedItem.BidOrders.Items[iB]);
        if (aOrder.Price + PRICE_EPSILON > BidPrice) and
          ( not aOrder.Modify )  and
          ( aOrder.OrderType = otNormal ) then
        begin
          if (aOrder.Symbol = FQuote.Symbol) and ( Account = aOrder.Account ) then
          begin
            AddOrder( false, aOrder, BidList );
            //BidList.Add( aOrder );
            inc( iLv, aOrder.ActiveQty );
          end;
          inc( iB );
        end
        else bExt := true;
      end
      else bExt := true;

      inc( i );
    end;

    if SelectedItem.Position.Volume > 0 then
    begin
      iA  := (SelectedItem.Position.Volume + iLv) - Param.BidPos;
      iB  := iSv - (Param.AskPos + SelectedItem.Position.Volume );
      stLog := Format('Pos : L,%d | 매수 : Over :d, %d, %d | 매도 : Over :%d, %d, %d' ,
        [
          SelectedItem.Position.Volume,
          iA, iLv, Param.BidPos,
          iB, iSv, Param.AskPos
        ]);
    end
    else if SelectedItem.Position.Volume < 0 then
    begin
      iA  := iLv - (Param.BidPos - SelectedItem.Position.Volume);
      iB  := (abs(SelectedItem.Position.Volume) + iSv) - Param.AskPos;
      stLog := Format('Pos : S,%d | 매수 : Over :%d, %d, %d | 매도 : Over :%d, %d, %d' ,
        [
          abs(SelectedItem.Position.Volume),
          iA, iLv, Param.BidPos,
          iB, iSv, Param.AskPos
        ]);
    end
    else begin
      iA := iLv - Param.BidPos;
      iB := iSv - Param.AskPos;
      stLog := Format('Pos :     | 매수 : Over :%d, %d, %d | 매도 : Over :%d, %d, %d' ,
        [
          iA, iLv, Param.BidPos,
          iB, iSv, Param.AskPos
        ]);
    end;


    // 매수..
    // 뒤에 깔린 주문부터 취소...2020.03.03
    if iA > 0 then
    begin

      if BidList.Count > 0 then
        EnvLog( stLog );
      for i := BidList.Count - 1 downto 0 do
      begin
        aOrder  :=  TOrder( BidList.Items[i] );
        if (iA - aOrder.ActiveQty )>= 0 then
          DoCancel( aOrder )
        else if (iA - aOrder.ActiveQty )< 0 then
          DoCancel( aOrder, iA );
        iA := iA - aOrder.ActiveQty;
        if iA <= 0 then
          Break;
      end;
    end;

    // 매도..
    // 뒤에 깔린 주문부터 취소...2020.03.03
    if iB > 0 then
    begin

      if AskList.Count > 0  then
        EnvLog( stLog );
      for i := AskList.Count - 1 downto 0 do
      begin
        aOrder  :=  TOrder( AskList.Items[i] );
        if (iB - aOrder.ActiveQty )>= 0 then
          DoCancel( aOrder )
        else if (iB - aOrder.ActiveQty )< 0 then
          DoCancel( aOrder, iB );
        iB := iB - aOrder.ActiveQty;
        if iB <= 0 then
          Break;
      end;
    end;

  finally
    AskList.Free;
    BidList.Free;
  end;

  //FCheck  := false;

end;

procedure TOrderManager.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

  if Receiver <> Self then Exit;
  if DataObj = nil then Exit;

  if (DataObj as TQuote) <> FQuote then Exit;
  if Account = nil then Exit;

  Observer;

end;

procedure TOrderManager.Reset;
begin

end;


function TOrderManager.Start: boolean;
begin
  Result := false;

  if FRun  then
  begin
    EnvLog( '실행중 ');
    result := true;
    Exit;
  end;

  if (Symbol <> nil) and ( Account <> nil ) then
  begin
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, Symbol, QuoteProc );
    Result := true;
    FRun   := true;
    FTimer.Enabled  := true;
    EnvLog( '포지션 체크 시작 ');
    Observer;
  end
  else
    EnvLog( '종목 or 계좌 선택 ');

end;

procedure TOrderManager.Stop;
begin
  if Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  FQuote := nil;
  FRun   := false;
  FTimer.Enabled  := false;
  EnvLog( ' 중지 ');
end;

end.
