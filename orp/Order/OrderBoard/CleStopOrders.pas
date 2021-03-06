unit CleStopOrders;

interface

uses
  Classes, SysUtils, Math,

  CleOrders, CleSymbols, CleAccounts, CleQuoteBroker, ClePositions,  CleFrontOrder,

  CleFunds,

  CBoardDistributor,  GleTypes , COBTypes
  ;

type

  // stopOrderItem type
  TStopOrderType = ( soNone, soNew, soCancel );
  //TStopOrderEventType = ( setNew, setOrder, set

  // stop order unit;
  TStopOrderItem = class( TCollectionItem )
  public
    Account : TAccount;
    Invest  : TInvestor;
    Symbol  : TSymbol;
    Side    : integer;
    OrdQty  : integer;
    soType  : TStopOrderType;
    Price   : double;
    TargetPrice : double;
    LastPrice   : double;
    Tick    : integer;
    Index   : integer;
    MustClear   : boolean;
    GroupID : integer;
    pcValue : TPriceControl;
    Constructor Create( aColl : TCollection ); override;
  end;

  TStopOrderEvent = procedure( Sender : TObject; aStop : TStopOrderItem; bOrder : boolean ) of object;

  // ask/ bid stop order list
  TStopOrder = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FInvest : TInvestor;
    FBidStopList: TList;
    FAskStopList: TList;

    FOnStopOrderEvent: TStopOrderEvent;
    FStopList: TList;

    FPrfStop: TStopOrderItem;
    FLosStop: TStopOrderItem;
    //FOnStopOrderEvent: TStopOrderEvent;
    function GetQuote: TQuote;
    // 현재가에서 먼곳이 인덱스 0
    procedure AddAskStop( aStop : TStopOrderItem );
    procedure AddBidStop( aStop : TStopOrderItem  );

    // 현재가에서 가까운곳이 인덱스 0
    procedure AddAskStop2( aStop : TStopOrderItem );
    procedure AddBidStop2( aStop : TStopOrderItem  );

    function FindAsk(aSymbol: TSymbol; dPrice: double;
      var iPos: integer): TStopOrderItem;
    function FindBid(aSymbol: TSymbol; dPrice: double;
      var iPos: integer): TStopOrderItem;

    procedure AllCancel(iSide: integer);
    function IsOrder(aStop: TStopOrderItem; aQuote: TQuote): boolean;
    procedure SendOrder(aStop: TStopOrderITem; aQuote:TQuote );

    procedure AddClearOrder(aOrder : TOrder; iQty : integer);


  public
    Constructor Create( aColl: TCollection ); override;
    Destructor  Destroy; override;

    function New( aAccount : TAccount; aSymbol : TSymbol; iSide : integer; iQty : integer;
      iTick : integer; dPrice : double ) : TStopOrderItem;
    function New2( aAccount : TAccount; aSymbol : TSymbol; iSide : integer; iQty : integer;
      iTick : integer; dPrice : double ) : TStopOrderItem;

    function FindStopOrder(aSymbol : TSymbol; dPrice: double; iSide : integer) : TStopOrderItem; overload;
    function FindStopOrder( aStop : TStopOrderItem ) : TStopOrderItem; overload;

    procedure DeleteLog(aStop: TStopOrderItem);

    procedure Cancel( aSymbol : TSymbol; dPrice: double; iSide : integer ); overload;
    procedure Cancel( iSide : integer ); overload;
    procedure Cancel( aStop : TStopOrderItem ); overload;
    procedure AutoStopCancel( aStop : TStopOrderItem );

    procedure LastStopCancel;

    procedure Change( aSymbol : TSymbol; dPrice1, dPrice2: double; index, iSide : integer );

    procedure DoQuote( aQuote : TQuote );
    procedure AddStop( aStop : TStopOrderItem );
    function  FindStop( aStop : TStopOrderItem ) : integer;
    procedure RemoveStop( aStop : TStopOrderItem );
    // event broadcast
    procedure BroadCast( eType: TEventType;  vType:TValueType; aData : TObject );

    property Symbol : TSymbol read FSymbol write FSymbol;
    property Account: TAccount read FAccount write FAccount;

    property Invest : TInvestor read FInvest write FInvest;
    property Quote  : TQuote read GetQuote ;

    property PrfStop : TStopOrderItem read FPrfStop write FPrfStop;
    property LosStop : TStopOrderItem read FLosStop write FLosStop;

    property AskStopList : TList read FAskStopList write FAskStopList;
    property BidStopList : TList read FBidStopList write FBidStopList;
    property StopList    : TList read FStopList write FStopList;
    property OnStopOrderEvent  : TStopOrderEvent read FOnStopOrderEvent write FOnStopOrderEvent;

  end;

  TStopOrders = class( TCollection )
  private
    FTBoardItems: TBoardEnvItems;
    FOnStopOrderEvent: TStopOrderEvent;
    function GetStopOrder(i: integer): TStopOrder;
  public
    Constructor Create ;
    Destructor  Destroy; override;
    function New( aAccount : TAccount ; aSymbol : TSymbol ) : TStopOrder;
    function Find(  aAccount : TAccount ; aSymbol : TSymbol ) : TStopOrder;

    procedure DoQuote( aQuote : TQuote );

    property StopOrder[ i : integer] : TStopOrder read GetStopOrder;
    property BoardItems : TBoardEnvItems read FTBoardItems;
  end;


implementation

uses
  GAppEnv, GleLib, Gleconsts,CleKrxSymbols  ,
  CleFills

  ;

{ TStopOrderItem }

constructor TStopOrderItem.Create(aColl: TCollection);
begin
  Account := nil;
  Symbol  := nil;
  Invest  := nil;
  Side    := 0;
  OrdQty  := 0;
  soType  := soNone;
  Price   := 0;      // 호가.
  TargetPrice := 0;  // 목표가격( 주문나갈 가격 )
  LastPrice := 0;  // 해당종목의 현재가
  Tick    := 0;
  Index   := 0;
  MustClear := false;
  GroupID   := 0;
  pcValue   := pcLimit;
end;


{ TStopOrder }



{ TStopOrders }

constructor TStopOrders.Create;
begin
  inherited Create( TStopOrder );
  FTBoardItems:= TBoardEnvItems.Create;
end;

destructor TStopOrders.Destroy;
begin
  FTBoardItems.Free;
  inherited;
end;

procedure TStopOrders.DoQuote(aQuote: TQuote);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    GetStopOrder(i).DoQuote( aQuote);
end;

function TStopOrders.Find(aAccount: TAccount; aSymbol: TSymbol): TStopOrder;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    with GetStopOrder(i) do
      if (Symbol = aSymbol ) and ( Account = aAccount ) then
      begin
        Result := Items[i] as TStopOrder;
        Break;
      end;
end;

function TStopOrders.GetStopOrder(i: integer): TStopOrder;
begin
  if (i<0) or ( i>=Count) then
    Result := nil
  else
    Result := Items[i] as TStopOrder;
end;

function TStopOrders.New(aAccount: TAccount; aSymbol: TSymbol): TStopOrder;
begin
  Result := Add as TStopOrder;
  Result.Symbol   := aSymbol;
  Result.Account  := aAccount;
end;


{ TStopOrder }

procedure TStopOrder.AddAskStop(aStop : TStopOrderItem);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pItem : TStopOrderItem;
  stFindKey, stDesKey: String;
begin

  stFindkey := Format('%.*n', [ FSymbol.Spec.Precision, aStop.Price  ] );

  iLow := 0;
  iHigh:= AskStopList.Count-1;

  iPos := -1;

  aStop.TargetPrice := TicksFromPrice( FSymbol, aStop.Price, -aStop.Tick );

  if AskStopList.Count = 0 then
  begin
    AskStopList.Add( aStop);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TStopOrderItem( AskStopList.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%.*n', [ FSymbol.Spec.Precision, pItem.Price ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

  if iPos >=0 then
    AskStopList.Insert(iPos, aStop);

  for i := AskStopList.Count-1 downto 0 do
  begin
    pItem := TStopOrderItem( AskStopList.Items[i] );
    stDesKey  := Format('AskStop : %.*n, %.*n, %d, %d',
      [
        FSymbol.Spec.Precision,
        pItem.Price,
        FSymbol.Spec.Precision,
        pItem.TargetPrice,
        pItem.Tick,
        pItem.OrdQty
      ]);
    gEnv.EnvLog( WIN_TEST, stDesKey );
  end;
  gEnv.EnvLog( WIN_TEST, '' );

end;

procedure TStopOrder.AddAskStop2(aStop: TStopOrderItem);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pItem : TStopOrderItem;
  stFindKey, stDesKey: String;
begin

  stFindkey := Format('%.*n', [ FSymbol.Spec.Precision, aStop.Price  ] );

  iLow := 0;
  iHigh:= AskStopList.Count-1;

  iPos := -1;

  aStop.TargetPrice := TicksFromPrice( FSymbol, aStop.Price, -aStop.Tick );

  if AskStopList.Count = 0 then
  begin
    AskStopList.Add( aStop);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TStopOrderItem( AskStopList.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%.*n', [ FSymbol.Spec.Precision, pItem.Price ] );
    iCom     := CompareStr( stDesKey, stFindKey );
    {
    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
    }
    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

  if iPos >=0 then
    AskStopList.Insert(iPos, aStop);

  for i := AskStopList.Count-1 downto 0 do
  begin
    pItem := TStopOrderItem( AskStopList.Items[i] );
    stDesKey  := Format('AskStop : %.*n, %.*n, %d, %d',
      [
        FSymbol.Spec.Precision,
        pItem.Price,
        FSymbol.Spec.Precision,
        pItem.TargetPrice,
        pItem.Tick,
        pItem.OrdQty
      ]);
    gEnv.EnvLog( WIN_TEST, stDesKey );
  end;
  gEnv.EnvLog( WIN_TEST, '' );


end;

procedure TStopOrder.AddBidStop(aStop : TStopOrderItem);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pItem : TStopOrderItem;
  stFindKey, stDesKey: String;
begin

  stFindkey := Format('%.*n',  [ FSymbol.Spec.Precision,  aStop.Price ] );

  iLow := 0;
  iHigh:= BidStopList.Count-1;

  iPos := -1;

  aStop.TargetPrice := TicksFromPrice( FSymbol, aStop.Price, aStop.Tick );

  if BidStopList.Count = 0 then
  begin
    BidStopList.Add( aStop);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TStopOrderItem( BidStopList.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%.*n', [ FSymbol.Spec.Precision,  pItem.Price ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;

    iPos := iLow;
  end;

  if iPos >=0 then
    BidStopList.Insert( iPos, aStop );

  for i := BidStopList.Count-1 downto 0 do
  begin
    pItem := TStopOrderItem( BidStopList.Items[i] );
    stDesKey  := Format('BidStop : %.*n, %.*n, %d, %d',
      [
        FSymbol.Spec.Precision,
        pItem.Price,
        FSymbol.Spec.Precision,
        pItem.TargetPrice,
        pItem.Tick,
        pItem.OrdQty
      ]);
    gEnv.EnvLog( WIN_TEST, stDesKey );
  end;
  gEnv.EnvLog( WIN_TEST, '' );

end;


procedure TStopOrder.AddBidStop2(aStop: TStopOrderItem);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pItem : TStopOrderItem;
  stFindKey, stDesKey: String;
begin

  stFindkey := Format('%.*n',  [ FSymbol.Spec.Precision,  aStop.Price ] );

  iLow := 0;
  iHigh:= BidStopList.Count-1;

  iPos := -1;

  aStop.TargetPrice := TicksFromPrice( FSymbol, aStop.Price, aStop.Tick );

  if BidStopList.Count = 0 then
  begin
    BidStopList.Add( aStop);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TStopOrderItem( BidStopList.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%.*n', [ FSymbol.Spec.Precision,  pItem.Price ] );
    iCom     := CompareStr( stDesKey, stFindKey );
    {
    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
    }
    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

  if iPos >=0 then
    BidStopList.Insert( iPos, aStop );

  for i := BidStopList.Count-1 downto 0 do
  begin
    pItem := TStopOrderItem( BidStopList.Items[i] );
    stDesKey  := Format('BidStop : %.*n, %.*n, %d, %d',
      [
        FSymbol.Spec.Precision,
        pItem.Price,
        FSymbol.Spec.Precision,
        pItem.TargetPrice,
        pItem.Tick,
        pItem.OrdQty
      ]);
    gEnv.EnvLog( WIN_TEST, stDesKey );
  end;
  gEnv.EnvLog( WIN_TEST, '' );

end;

procedure TStopOrder.AddClearOrder(aOrder : TOrder;  iQty: integer);
var
  aTicket : TOrderTicket;
  aNewOrder  : TOrder;
  dPrice : double;
  stLog   : string;
begin
  {
  if iQty = 0  then exit;

  dPrice := aOrder.Price;
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  aNewOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                gEnv.ConConfig.UserID, aOrder.Account, aOrder.Symbol,
                iQty * aORder.Side, pcLimit, dPrice, tmGTC, aTicket);

  if aNewOrder <> nil then
  begin
    aNewOrder.ClearOrder := true;
    if aNewOrder.Symbol.Spec.Exchange = SANG_EX then
      aNewOrder.OffsetFlag := cofCloseToday
    else
      aNewOrder.OffsetFlag := cofClose;



    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'StopOrder AddClearOrder : %s, %s, %s, %d ',
      [
        aNewOrder.Symbol.Code,
        ifThenStr( aNewORder.Side > 0 , 'L', 'S'),
        aNewOrder.Symbol.PriceToStr( dPrice ),
        iQty
      ]
      );
  end;
  }
end;

procedure TStopOrder.AddStop(aStop: TStopOrderItem);
begin
  if aStop = nil then Exit;
  
  if aStop.Side > 0 then
    AddBidStop2( aStop )
  else
    AddAskStop2( aStop );
end;

function TStopOrder.FindAsk(aSymbol: TSymbol; dPrice: double; var iPos : integer ): TStopOrderItem;
var

  pItem : TStopOrderItem;
  stFindKey, stDesKey: String;
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;

begin
  Result := nil;
  iPos := -1;

  if aSymbol = nil then
    Exit;

  stFindkey := Format('%.*n',[ aSymbol.Spec.Precision, dPrice ] );

  iLow := 0;
  iHigh:= AskStopList.Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TStopOrderItem( AskStopList.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%.*n', [ pItem.Symbol.Spec.Precision, pItem.Price ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := TStopOrderItem( AskStopList.Items[iMid] );
        iPos := iMid;
        break;;
      end;
    end;

  end;

end;

function TStopOrder.FindBid(aSymbol: TSymbol; dPrice: double; var iPos : integer): TStopOrderItem;
var
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;
  pItem : TStopOrderItem;
  stFindKey, stDesKey: String;
begin

  Result := nil;
  iPos := -1;

  if aSymbol = nil then
    Exit;

  stFindkey := Format('%.*n', [ aSymbol.Spec.Precision, dPrice ] );

  iLow := 0;
  iHigh:= BidStopList.Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TStopOrderItem( BidStopList.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%.*n', [ pItem.Symbol.Spec.Precision,  pItem.Price ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result  := TStopOrderItem( BidStopList.Items[iMid] );
        iPos := iMid;
        break;;
      end;
    end;

  end;

end;

function TStopOrder.FindStop(aStop: TStopOrderItem): integer;
var
  i : integer;
  oStop : TStopOrderItem;
begin
  Result := -1;

  if aStop.Side > 0  then
  begin
    for I := BidStopList.Count-1 downto 0 do
    begin
      oStop := BidStopList.Items[i] ;
      if oStop = aStop then begin
        Result := i;
        break;
      end;
    end;
  end else
  if aStop.Side < 0 then
  begin
    for I := AskStopList.Count-1 downto 0 do
    begin
      oStop := AskStopList.Items[i] ;
      if oStop = aStop then begin
        Result := i;
        break;
      end;
    end;
  end;

end;

function TStopOrder.FindStopOrder( aStop : TStopOrderItem ): TStopOrderItem;
var
  I: Integer;
  aItem : TStopOrderItem;
begin
  Result := nil;
  if aStop.Side > 0 then
  begin
    for I := 0 to FBidStopList.Count - 1 do
    begin
      aItem := TStopOrderItem( FBidStopList.Items[i] );
      if ( aItem.Symbol = aStop.Symbol ) and ( aItem.MustClear ) and ( aItem.soType = soNew ) and
         ( aItem.Side = aStop.Side ) and ( aItem.GroupID = aStop.GroupID ) and ( aItem.Index <> aStop.Index ) then
      begin
        Result := aItem;
        break;
      end;
    end;
  end else
  begin
    for I := 0 to FAskStopList.Count - 1 do
    begin
      aItem := TStopOrderItem( FAskStopList.Items[i] );
      if ( aItem.Symbol = aStop.Symbol ) and ( aItem.MustClear ) and ( aItem.soType = soNew ) and
         ( aItem.Side = aStop.Side ) and ( aItem.GroupID = aStop.GroupID ) and ( aItem.Index <> aStop.Index ) then
      begin
        Result := aItem;
        break;
      end;
    end;
  end;
end;

function TStopOrder.FindStopOrder(aSymbol: TSymbol; dPrice: double;
  iSide: integer): TStopOrderItem;
  var
    iPos : integer;
begin
  if iSide > 0 then
    FindBid( FSymbol, dPrice, iPos )
  else
    FindAsk( FSymbol, dPrice, iPos );

  if iPos >= 0 then
  begin
    if iSide > 0 then
      Result := TStopOrderItem( BidStopList.Items[iPos])
    else
      Result := TStopOrderItem( AskStopList.Items[iPos]);
  end;
end;

procedure TStopOrder.AllCancel( iSide : integer );
var
  I: Integer;
  aStop : TStopOrderItem;
begin
  case iSide of
    1 : begin
        for I := BidStopList.Count - 1 downto 0 do
        begin
          aStop := TStopOrderItem( BidStopList.Items[i] );
          aStop.soType := soCancel;
          DeleteLog( aStop );
          BroadCast( etStop, vtDelete, aStop );

          aStop.Free;
          BidStopList.Delete(i);
        end;
    end;
    -1: begin
        for I := AskStopList.Count - 1 downto 0 do
        begin
          aStop := TStopOrderItem( AskStopList.Items[i] );
          aStop.soType := soCancel;
          DeleteLog( aStop );
          BroadCast( etStop, vtDelete, aStop );

          aStop.Free;
          AskStopList.Delete(i);
        end;
    end;
  end;
end;


procedure TStopOrder.AutoStopCancel(aStop: TStopOrderItem);
begin
  if FPrfStop = aStop then FPrfStop := nil;
  if FLosStop = aStop then FLosStop := nil;
end;

procedure TStopOrder.BroadCast(eType: TEventType; vType: TValueType;
  aData: TObject);
  var
    aColl : TStopOrders;
begin
  if aData = nil then Exit;
  aColl := Collection as TStopOrders;
  aColl.BoardItems.BroadCast( self, aData, eType, vType);
end;

procedure TStopOrder.Cancel(iSide: integer);
begin
  case iSide of
    0 : begin
       AllCancel(1);
       AllCancel(-1);
      end;
    else
      AllCancel( iSide );
  end;
end;


// 생성 실패시 캔슬하는경우
procedure TStopOrder.Cancel(aStop: TStopOrderItem);
var
  i : integer;
  oStop : TStopOrderItem;
begin
  if aStop.Side > 0  then
  begin
    for I := BidStopList.Count-1 downto 0 do
    begin
      oStop := BidStopList.Items[i] ;
      if oStop = aStop then begin
        aStop.soType := soCancel;
        BroadCast( etStop, vtDelete, aStop );
        AutoStopCancel( aStop );
        DeleteLog( oStop );
        oStop.Free;
        BidStopList.Delete(i);
        break;
      end;
    end;
  end else
  if aStop.Side < 0 then
  begin
    for I := AskStopList.Count-1 downto 0 do
    begin
      oStop := AskStopList.Items[i] ;
      if oStop = aStop then begin
        aStop.soType := soCancel;
        BroadCast( etStop, vtDelete, aStop );
        AutoStopCancel( aStop );
        DeleteLog( oStop );
        oStop.Free;
        AskStopList.Delete(i);
        break;
      end;
    end;
  end;
end;

procedure TStopOrder.Change(aSymbol: TSymbol; dPrice1, dPrice2: double;
  index, iSide: integer);
var
  iPos : integer;
  pStop, aStop: TStopOrderItem;
begin
  if iSide > 0 then
    FindBid( FSymbol, dPrice1, iPos )
  else
    FindAsk( FSymbol, dPrice1, iPos );

  while iPos >= 0 do
  begin
    if iSide > 0 then
      aStop := TStopOrderItem( BidStopList.Items[iPos])
    else
      aStop := TStopOrderItem( AskStopList.Items[iPos]);

    pStop := nil;
    if aStop <> nil then begin
      //
      pStop := New2( aStop.Account, aStop.Symbol, aStop.Side, aStop.OrdQty, aStop.Tick, dPrice2 );
      pStop.MustClear := aStop.MustClear;
      pStop.GroupID   := aStop.GroupID;
      pStop.Index     := index;
      pStop.PcValue   := aStop.pcValue;
      //
      DeleteLog( aStop );
      aStop.soType := soCancel;
      BroadCast( etStop, vtDelete, aStop );
      aStop.Free;
    end;

    if iSide > 0 then
      BidStopList.Delete( iPos )
    else
      AskStopList.Delete( iPos );

    if pStop <> nil then begin
      if pStop.Side > 0 then
        AddBidStop( pStop )
      else
        AddAskStop( pStop);
      BroadCast( etStop, vtAdd, pStop);
    end;

    iPos := -1;
    if iSide > 0 then
      FindBid( FSymbol, dPrice1, iPos )
    else
      FindAsk( FSymbol, dPrice1, iPos );
  end;

end;

procedure TStopOrder.Cancel(aSymbol: TSymbol; dPrice: double; iSide: integer);
var
  iPos : integer;
  aStop: TStopOrderItem;
begin
  if iSide > 0 then
    FindBid( FSymbol, dPrice, iPos )
  else
    FindAsk( FSymbol, dPrice, iPos );

  while iPos >= 0 do
  begin
    if iSide > 0 then
      aStop := TStopOrderItem( BidStopList.Items[iPos])
    else
      aStop := TStopOrderItem( AskStopList.Items[iPos]);

    if aStop <> nil then begin
      DeleteLog( aStop );
      aStop.soType := soCancel;
      BroadCast( etStop, vtDelete, aStop );
      //if Assigned( FOnStopOrderEvent) then
      //  FOnStopOrderEvent( Self, aStop, false );
      aStop.Free;
    end;

    if iSide > 0 then
      BidStopList.Delete( iPos )
    else
      AskStopList.Delete( iPos );

    iPos := -1;
    if iSide > 0 then
      FindBid( FSymbol, dPrice, iPos )
    else
      FindAsk( FSymbol, dPrice, iPos );
  end;
end;

procedure TStopOrder.LastStopCancel;
var
  aStop : TStopOrderItem;
begin
  if FStopList.Count <= 0 then Exit;

  aStop := TStopOrderItem(FStopList.Items[ FStopList.Count-1]);
  if aStop <> nil then
    Cancel( aStop );
end;

procedure TStopOrder.DeleteLog(aStop: TStopOrderItem);
var
  stLog : string;
begin

  FStopList.Remove( aStop );
  stLog :=
  Format( 'Delete : %s, %s, %.2f, %d, %d, %s, (%s)',
  [

    aStop.Symbol.code,
    ifThenStr(  aStop.Side > 0, '매도', '매수' ),
    aStop.Price,
    aStop.OrdQty,
    aStop.Tick,
    ifThenStr( aStop.MustClear,'Auto',' '),
    ifThenStr( aStop.Side > 0,  IntToStr(BidStopList.Count-1)
      , IntToStr( AskStopList.Count-1) )

  ]);
  gLog.Add( lkKeyOrder,'TOrderBoard','DoStandBy', stLog );

end;



constructor TStopOrder.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FAskStopList  := TList.Create;
  FBidStopList  := TList.Create;
  FSymbol := nil;
  FAccount:= nil;
  FInvest := nil;

  FStopList:= TList.Create;

    FPrfStop:= nil;
    FLosStop:= nil;
end;

destructor TStopOrder.Destroy;
begin
  FAskStopList.Free;
  FBidStopList.Free;
  FStopList.Free;
  inherited;
end;

procedure TStopOrder.DoQuote(aQuote: TQuote);
var
  I: Integer;
  aCnlStop, aStop : TStopOrderItem;
  aList : TList;
begin
  if aQuote.Symbol <> FSymbol then Exit;

  aCnlStop  := nil;
  try

    aList := TList.Create;

    try
      // 매도 stop
      for I := AskStopList.Count-1  downto 0 do
      begin
        aStop  := TStopOrderItem( AskStopList.Items[i] );
        if aStop = nil then Continue;
        if aStop.soType = soNew then
        begin
          if IsOrder( aStop, aQuote ) then
          begin
            SendOrder( aStop, aQuote );
            if aStop.MustClear then begin
              aCnlStop  := FindStopOrder( aStop );
              if aCnlStop <> nil then aList.Add( aCnlStop );
            end;
            BroadCast( etStop, vtDelete, aStop );
            DeleteLog( aStop );
            aStop.Free;
            AskStopList.Delete(i);
          end;
        end;
      end;

      // 매수 stop
      for I := BidStopList.Count-1  downto 0 do
      begin
        aStop  := TStopOrderItem( BidStopList.Items[i] );
        if aStop = nil then Continue;
        if aStop.soType = soNew then
        begin
          if IsOrder( aStop, aQuote ) then
          begin
            SendOrder( aStop, aQuote );
            if aStop.MustClear then begin
              aCnlStop  := FindStopOrder( aStop );
              if aCnlStop <> nil then aList.Add( aCnlStop );
            end;
            BroadCast( etStop, vtDelete, aStop );
            DeleteLog( aStop );
            aStop.Free;
            BidStopList.Delete(i);
          end;
        end;
      end;
    Except
    end;

    for I := 0 to aList.Count - 1 do
    begin
      aCnlStop  := TStopOrderItem( aList.Items[i] );
      Cancel( aCnlStop );
    end;

  finally
    aList.Free;
  end;

end;

function TStopOrder.IsOrder( aStop : TStopOrderItem ; aQuote : TQuote ) : boolean;
var
  stPrc, stLast : string;
begin
  Result := false;

  if aQuote.Last < DOUBLE_EPSILON then Exit;

  stPrc := aStop.Symbol.PriceToStr( aStop.Price );
  stLast:= aStop.Symbol.PriceToStr( aQuote.Last );

  // stop 생성될때 현재가보다 높게  stop 을 걸어놈
  if aStop.Price > aStop.LastPrice then
  begin
    // 지금 현재가가 크거나 같으면 주문..ㄱㄱ
    if CompareStr( stLast, stPrc ) >= 0 then begin
      Result := true;
      Exit;
    end;
  end else
  // stop 생성될때 현재가보다 낲게  stop 을 걸어놈
  if aStop.Price < aStop.LastPrice then
  begin
    // 지금 현재가가 같거나 작을때 주문 ㄱㄱ
    if CompareStr( stLast, stPrc  ) <= 0 then begin
      Result := true;
      Exit;
    end;
  end else
  if aStop.Price = aStop.LastPrice then
  begin
    // 이럴수가..

  end;

end;




procedure TStopOrder.SendOrder( aStop : TStopOrderITem; aQuote : TQuote);
var
  aOrder : TOrder;
  aTicket: TOrderTicket;
  iVolume, iQty, iQty2 : integer;
  stLog : string;
  aPosition : TPosition;
  aInvest : TInvestor;
  dPrice  : double;
begin


  if ( FAccount = nil ) or ( FSymbol = nil ) or ( FInvest = nil ) then
  begin
    gLog.Add( lkKeyOrder, 'TStopOrder', 'SendOrder', 'Objects is nil');
    aStop.soType := soCancel;
    Exit;
  end;

  if FInvest.PassWord = '' then
  begin
    aStop.soType := soCancel;
    Exit;
  end;

  if (aStop.OrdQty > 0 ) and ( aStop.soType = soNew ) then
  begin

    if aStop.MustClear then
    begin
      if aStop.pcValue = pcMarket then
        dPrice := 0
      else begin
        dPrice  := aStop.TargetPrice;
        {
        dPrice := aQuote.GetHitPrice( aStop.Side, aStop.Tick );
        if dPrice < EPSILON then
          Exit;
          }
      end;
    end else
      dPrice  := aStop.TargetPrice;

    iVolume := ifThen( aStop.Side > 0,  aStop.OrdQty, -aStop.OrdQty );
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FAccount, FSymbol,
                iVolume, aStop.pcValue, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      gEnv.Engine.TradeBroker.Send(aTicket);
      gEnv.Engine.TradeCore.Orders.DoNotify( aOrder );
      aStop.soType := soCancel;
      stLog := Format('Send Stop Order : %s,%s,%s,prc:%s,cur:%s,last:%s, ordPrc:%s, %d, %d', [
          aStop.Symbol.Code,
          ifThenStr( aStop.MustClear,'Clear ','Normal'),
          ifThenStr( aStop.Side > 0 , 'L', 'S' ),
          aStop.Symbol.PriceToStr(  aStop.Price ),
          aStop.Symbol.PriceToStr(  aStop.Symbol.Last ),
          aStop.Symbol.PriceToStr(  aStop.LastPrice ),
          aStop.Symbol.PriceToStr(  dPrice ),
          aStop.Tick,
          aStop.OrdQty
        ]);
      gLog.Add( lkKeyOrder,'TStopOrder','SendOrder', stLog );
    end;
  end;

end;


function TStopOrder.GetQuote: TQuote;
begin
  if FSymbol = nil then
    Result := nil
  else
    if FSymbol.Quote = nil then
      Result := nil
    else
      Result := FSymbol.Quote as TQuote;
end;

function TStopOrder.New(aAccount: TAccount; aSymbol: TSymbol; iSide: integer;
  iQty : integer; iTick : integer; dPrice: double): TStopOrderItem;
begin
  Result := nil;

  if ( FSymbol <> aSymbol ) or ( FAccount <> aAccount ) then
    Exit;

  Result := TStopOrderItem.Create( nil );

  Result.Price  := dPrice;
  Result.Tick   := iTick;
  Result.OrdQty := iQty;
  Result.LastPrice  := FSymbol.Last;
  Result.Side       := iSide;
  Result.Symbol     := aSymbol;
  Result.Account    := aAccount;
  Result.Invest     := gEnv.Engine.TradeCore.Investors.Find( aAccount.InvestCode );

  if iSide > 0 then
    AddBidStop( Result )
  else
    AddAskStop( Result);

  Result.soType := soNew;
  FStopList.Add( Result );
end;



function TStopOrder.New2(aAccount: TAccount; aSymbol: TSymbol; iSide, iQty,
  iTick: integer; dPrice: double): TStopOrderItem;
begin
  Result := nil;

  if ( FSymbol <> aSymbol ) or ( FAccount <> aAccount ) then
    Exit;

  Result := TStopOrderItem.Create( nil );

  Result.Price  := dPrice;
  Result.Tick   := iTick;
  Result.OrdQty := iQty;
  Result.LastPrice  := FSymbol.Last;
  Result.Side       := iSide;
  Result.Symbol     := aSymbol;
  Result.Account    := aAccount;
  Result.Invest     := gEnv.Engine.TradeCore.Investors.Find( aAccount.InvestCode );

  Result.soType := soNew;
  FStopList.Add( Result );

end;


procedure TStopOrder.RemoveStop(aStop: TStopOrderItem);
var
  i : integer;
  oStop : TStopOrderItem;
begin
  if aStop.Side > 0  then
  begin
    for I := BidStopList.Count-1 downto 0 do
    begin
      oStop := BidStopList.Items[i] ;
      if oStop = aStop then begin
        BidStopList.Delete(i);
        break;
      end;
    end;
  end else
  if aStop.Side < 0 then
  begin
    for I := AskStopList.Count-1 downto 0 do
    begin
      oStop := AskStopList.Items[i] ;
      if oStop = aStop then begin
        AskStopList.Delete(i);
        break;
      end;
    end;
  end;
end;

end.
