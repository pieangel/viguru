unit FForce;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  GleTypes, CleSymbols, CleQuoteBroker, Grids, StdCtrls,
  CleQuoteTimers, CleDistributor, CleCircularQueue , ClePositions,

  CleOrders, ExtCtrls, CleAccounts  , DateUtils  , math

  ;

const
  Stand_Time = 1000;

type

  TDeltaNeutralSymbol = class( TCollectionItem )
  public
    side : integer;
    stdQty : integer;
    Call, Put, other : TOption;
    callQty, putQty, otherQty : integer;
    callQty2, putQty2, otherQty2 : integer;
    constructor Create( aColl : TCollection ) ;override;
    procedure CalcQty( iDir : integer );
  end;

  TDeltaNeutralSymbols = class( TCollection )
  public
    Constructor Create;
    Destructor  Destroy; override;
    function New : TDeltaNeutralSymbol;
  end;

  TVOrder = class( TCollectionItem )
  public
    Side : integer;
    vSpread : double;
    No   : integer;
    Call, put : TOrder;
    Orders  : TOrderList;
    constructor Create( aColl : TCollection ) ;override;
    destructor Destroy; override;
  end;

  TVOrders  = class( TCollection )
  private
    function GetVOrder(i: integer): TVOrder;
  public
    Constructor Create;
    Destructor  Destroy; override;
    function New( iSide : integer) : TVOrder;

    property VOrder[ i : integer] : TVOrder read GetVOrder;
  end;

  TFrmPairsTest = class(TForm)
    sgSymbols: TStringGrid;
    Panel1: TPanel;
    cbAccount: TComboBox;
    edtHigh: TEdit;
    Label1: TLabel;
    edtLow: TEdit;
    Label2: TLabel;
    sgRes: TStringGrid;
    edtQtyR: TEdit;
    cbRun: TCheckBox;
    Button5: TButton;
    Button4: TButton;
    Button3: TButton;
    Button2: TButton;
    Button1: TButton;
    lbvol: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private

    { Private declarations }
    LongSymbols , ShortSymbols :  TDeltaNeutralSymbols;
    VOrders : TVOrders;

    FRun  : boolean;
    FTimer  : TQuoteTimer;
    FSign   : integer;
    FAccount: TAccount;
    FStartTime: TDateTime;
    FlastTime : TDateTime;

    procedure refreshGrid;
    procedure calcSpread;
    procedure DoSignal(iSign: integer);
    procedure DoLongOrder;
    procedure DoShortOrder;
    procedure DoOrder(aPos: TPosition); overload;
    procedure DoOrder( aDel : TDeltaNeutralSymbol ); overload;
    procedure AddRes(dValue : double; iSign: integer);
    procedure SetOrderQty;
    function DoLiquid(iSide: integer): boolean;
  public
    { Public declarations }
    Future, vKospi : TSymbol;
    DataSum : double;
    DataCnt : integer;
    DataVal : TCircularQueue;
    Positions : TPositions;
    procedure QuoteTimer( Sender : TObject );
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure MakeCommodity;
  end;

var
  FrmPairsTest: TFrmPairsTest;

implementation

uses
  GAppEnv, DleSymbolSelect, CleKrxSymbols, GleLib, GleConsts
  ;

{$R *.dfm}

procedure TFrmPairsTest.Button1Click(Sender: TObject);
var
  aSymbol : TOption;
  i : integer;
  aItem : TDeltaNeutralSymbol;
begin
  longSymbols.Clear;
  shortSymbols.Clear;
  makeCommodity;
end;

procedure TFrmPairsTest.cbAccountChange(Sender: TObject);
begin
  FAccount := GetComboObject(cbAccount) as TAccount;

end;

procedure TFrmPairsTest.cbRunClick(Sender: TObject);
begin

  FRun  := cbRun.Checked;

  if FRun then
  begin
    FlastTime := GetQuoteTime;
    Button1Click(nil );
  end;

  FTimer.Enabled  := FRun;
end;

procedure TFrmPairsTest.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree
end;

procedure TFrmPairsTest.FormCreate(Sender: TObject);
begin

  LongSymbols  := TDeltaNeutralSymbols.Create;
  ShortSymbols := TDeltaNeutralSymbols.Create;
  VOrders := TVOrders.Create;

  Future  := nil;
  vKospi  := nil;
  FRun    := false;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 1000;
  FTimer.OnTimer  := QuoteTimer;

  Future  := gEnv.Engine.SymbolCore.Futures[0];
  vKospi  := gEnv.Engine.SymbolCore.Symbols.FindCode( KOSPI200_VOL_CODE );

  if Future <> nil then
    gEnv.Engine.QuoteBroker.Subscribe( self, Future, QuotePrc );
  if vKospi <> nil then
    gEnv.Engine.QuoteBroker.Subscribe( self, vKospi, QuotePrc );

  DataSum := 0;
  DataCnt := 0;
  FSign   := 0;
  FStartTime  := GetQuoteTime;

  DataVal := TCircularQueue.Create(4);

  gEnv.Engine.TradeCore.Accounts.GetList(cbAccount.Items);
  gEnv.Engine.SymbolCore.SymbolCache.GetList(cbAccount.Items);

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( nil );
  end;

  Positions := TPositions.Create;
end;

procedure TFrmPairsTest.FormDestroy(Sender: TObject);
begin
  VOrders.Free;
  Positions.Free;
  gEnv.Engine.QuoteBroker.Cancel( self );
end;

procedure TFrmPairsTest.MakeCommodity;
var
  clist, plist : TList;
  I, j, imod, iCnt: Integer;
  aOpt, aOpt2, aOpt3, aTmp : TOption;
  dTmp , dLow : double;
  aItem :TDeltaNeutralSymbol;
begin
  try
    cList := TList.Create;
    pList := Tlist.Create;

    dLow := 0.3;
    gEnv.Engine.SymbolCore.GetCurCallList( 3.0, dLow, 10, cList);
    gEnv.Engine.SymbolCore.GetCurPutList(  3.0, dLow, 10, pList);


    // 양매도 + 콜매도
    for I := 0 to pList.Count - 1 do
    begin
      aOpt  := TOption( pList.Items[i] );
      aTmp  := nil;
      dLow  := 100;
      for j := 0 to pList.Count - 1 do
      begin
        aOpt2 := TOption( cList.Items[j] );
        if (dLow > abs(aOpt.Last - aOpt2.Last)) then
        begin
          dLow := abs(aOpt.Last - aOpt2.Last);
          aTmp := aOpt2;
        end;
      end;

      if aTmp = nil then continue;

      aOpt2 := aTmp;
      aOpt3 := aOpt2;//TOption( pList.Items[i-1] );
 //     gEnv.EnvLog( WIN_GI, Format('%d shotsymbols :  %s,%s,%s,%.2f, %.2f, %.2f',[
 //       ShortSymbols.Count, aOpt.ShortCode, aOpt2.ShortCode, aOpt3.ShortCode,
 //       aOpt.Last, aOpt2.Last, aOpt3.Last])      );

      aItem := ShortSymbols.New;
      aItem.side  := -1;
      aItem.Call  := aOpt2;
      aItem.Put   := aOpt;
      aItem.other := aOpt3;
      aItem.stdQty  := StrToIntDef(edtQtyR.Text, 1 );

      aItem.CalcQty( aItem.stdQty) ;
    end;

    {
    for I := 1 to pList.Count - 1 do
    begin
      aOpt  := TOption( pList.Items[i] );
      aTmp  := nil;
      dLow  := 100;
      for j := 0 to cList.Count - 1 do
      begin
        aOpt2 := TOption( cList.Items[j] );
        if (dLow > abs(aOpt.Last - aOpt2.Last)) then
        begin
          dLow := abs(aOpt.Last - aOpt2.Last);
          aTmp := aOpt2;
        end;
      end;

      if aTmp = nil then continue;
      aOpt2 := aTmp;
      aOpt3 := TOption( pList.Items[i-1] );
      gEnv.EnvLog( WIN_GI, Format('%d shotsymbols :  %s,%s,%s,%.2f, %.2f, %.2f',[
        ShortSymbols.Count, aOpt.ShortCode, aOpt2.ShortCode, aOpt3.ShortCode,
        aOpt.Last, aOpt2.Last, aOpt3.Last])      );

      aItem := ShortSymbols.New;
      aItem.side  := -1;
      aItem.Call  := aOpt2;
      aItem.Put   := aOpt;
      aItem.other := aOpt3;

      aItem.CalcQty( StrToIntDef(edtQtyR.Text, 1 )) ;
    end;
    }
    // 양매수 + 콜매수
    for I := 0 to cList.Count - 1 do
    begin
      aOpt  := TOption( cList.Items[i] );
      aTmp  := nil;
      dLow  := 100;
      for j := 0 to pList.Count - 1 do
      begin
        aOpt2 := TOption( pList.Items[j] );
        if (dLow > abs(aOpt.Last - aOpt2.Last)) then
        begin
          dLow := abs(aOpt.Last - aOpt2.Last);
          aTmp := aOpt2;
        end;
      end;

      if aTmp = nil then continue;
      aOpt2 := aTmp;
      aOpt3 := aOpt;
 //     gEnv.EnvLog( WIN_GI, Format('%d longsymbols : %s,%s,%s,%.2f, %.2f, %.2f',[
 //       Longsymbols.Count, aOpt.ShortCode, aOpt2.ShortCode, aOpt3.ShortCode,
 //       aOpt.Last, aOpt2.Last, aOpt3.Last])      );

      aItem := longSymbols.New;
      aItem.side  := 1;
      aItem.Call  := aOpt;
      aItem.Put   := aOpt2;
      aItem.other := aOpt3;
      aItem.stdQty  := StrToIntDef(edtQtyR.Text, 1 );
      aItem.CalcQty( aItem.stdQty) ;
    end;
    {
    for I := 0 to cList.Count - 2 do
    begin
      aOpt  := TOption( cList.Items[i] );
      aTmp  := nil;
      dLow  := 100;
      for j := 0 to pList.Count - 1 do
      begin
        aOpt2 := TOption( pList.Items[j] );
        if (dLow > abs(aOpt.Last - aOpt2.Last)) then
        begin
          dLow := abs(aOpt.Last - aOpt2.Last);
          aTmp := aOpt2;
        end;
      end;

      if aTmp = nil then continue;
      aOpt2 := aTmp;
      aOpt3 := TOption( cList.Items[i+1] );
      gEnv.EnvLog( WIN_GI, Format('%d longsymbols : %s,%s,%s,%.2f, %.2f, %.2f',[
        Longsymbols.Count, aOpt.ShortCode, aOpt2.ShortCode, aOpt3.ShortCode,
        aOpt.Last, aOpt2.Last, aOpt3.Last])      );

      aItem := longSymbols.New;
      aItem.side  := 1;
      aItem.Call  := aOpt;
      aItem.Put   := aOpt2;
      aItem.other := aOpt3;
      aItem.CalcQty( StrToIntDef(edtQtyR.Text, 1 ) );
    end;
    }

  finally
    cList.Free;
    pList.Free;
  end;

end;

procedure TFrmPairsTest.SetOrderQty;
begin

end;

procedure TFrmPairsTest.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aPos : TPosition;
    tOrd : TOrder;
  function GetPosition( aOrder : TOrder) : TPosition;
  begin
    Result  := Positions.Find( aOrder.Account, aOrder.Symbol );
    if Result = nil then
      Result := Positions.New(aOrder.Account, aOrder.Symbol );
  end;
begin
  if DataObj = nil then Exit;
 {
  case Integer(EventID) of
    ORDER_NEW,
    ORDER_ACCEPTED :
      begin
        tOrd  := DataObj as TOrder;
        aPos  := GetPosition( tOrd );
        if tOrd.OrderType = otNormal then
          aPos.DoOrder( tOrd.Side, tOrd.OrderQty);
      end;
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED:
      begin
        tOrd  := DataObj as TOrder;
        aPos  := GetPosition( tOrd );
        //aPos
      end;
    FILL_NEW :
  end;  }
end;

procedure TFrmPairsTest.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if not FRun then Exit;

 // if (DataObj as TQuote).Symbol = vKospi then
    calcSpread;
end;

procedure TFrmPairsTest.Button2Click(Sender: TObject);
begin
  ShortSymbols.Clear;
  LongSymbols.Clear;
end;

procedure TFrmPairsTest.Button3Click(Sender: TObject);
var
  I: Integer;
  aPos   : TPosition;
begin
  //
end;

procedure TFrmPairsTest.Button4Click(Sender: TObject);
begin
  DoLongOrder;
end;

procedure TFrmPairsTest.Button5Click(Sender: TObject);
begin
  DoShortOrder;
end;

procedure TFrmPairsTest.calcSpread;
var
  dAvg, dData, dData2, dVal : double;
  stLog : string;
  I, iGap: Integer;
  dHigh, dLow : double;
begin

  dVal := gEnv.Engine.SymbolCore.ConsumerIndex.VIX.vMASpread;

  // index 0 이 젤 나중데이타.
  DataVal.PushItem( GetQuoteTime, dVal);

  if DataCnt < 30 then
  begin
    inc(DataCnt);
    Exit;
  end;

  iGap := SecondsBetween( GetQuoteTime, FLastTime );

  dData := DataVal.SumPrice / DataVal.Count;
  if ( DataVal.Value[0] < 0 ) and ( DataVal.Value[1] < 0 ) and ( DataVal.Value[2] <0 ) then
  begin
    dLow  := StrToFloatDef( edtLow.Text, 1 );
    if (DataVal.Value[3] < 0) and ( DataVal.Value[3] < dLow ) and  ( FSign <> 1 ) then //
    begin
     // if iGap >= 3 then begin
        DoSignal(1);// 상향예상   청산(매수) 신호
        AddRes( DataVal.Value[3], 1 );
    //  end;
    end;
  end
  else if ( DataVal.Value[0] > 0 ) and ( DataVal.Value[1] > 0 ) and ( DataVal.Value[2] > 0 ) then
  begin
    dHigh := StrToFloatDef( edtHigh.Text, 1.2);
    if (DataVal.Value[3] > 0)  and ( DataVal.Value[3] > dHigh ) and ( FSign <> -1 ) then //
    begin
  //    if iGap >= 3 then begin
        DoSignal(-1);// 하향예상   매도 신호
        AddRes( DataVal.Value[3], -1 );
  //    end;
    end;
  end;

  if iGap >= 3 then
    FlastTime := GetQuoteTime;

  lbvol.Caption := Format('%.2f', [ DataVal.Value[3]] );
 // refreshGrid;
  inc(DataCnt);
 {
  for I := 0 to DataVal.MaxCount - 1 do
    stLog := stLog + Format('%.3f, ', [ DataVal.Value[i] ]);
  gEnv.EnvLog( WIN_GI, stLog);
  }
end;

procedure TFrmPairsTest.AddRes( dValue : double; iSign: integer);
begin
  InsertLine( sgRes, 1 );

  with sgRes do
  begin
    Cells[0,1]  := FormatDateTime('hh:nn:ss', GetQuoteTime );
    Cells[1,1]  := IntToStr( iSign );
    Cells[2,1]  := Format('%.3f', [ dValue ] );
  end;
end;
function TFrmPairsTest.DoLiquid( iSide : integer ) : boolean;
var
  i : integer;
  aItem : TVOrder;

begin
  if iSide > 0 then
  begin

  end
  else begin

  end;
  result := true;
end;
procedure TFrmPairsTest.DoSignal( iSign : integer ) ;
begin

  //if FSign <> 0 then Exit;
  FSign := iSign;
  if iSign > 0 then // long sign
  begin
    DoLongOrder;
  end
  else if iSign < 0 then // short sign
  begin
    FSign := iSign;
    DoShortOrder;
  end
  else
    Exit;
end;

procedure TFrmPairsTest.DoLongOrder;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  aSymbol : TSymbol;
  aItem   : TDeltaNeutralSymbol;

  dDelta, dPrice  : double;
  iQty, I: Integer;
begin
    //
  DoLiquid(-1);

  for I := 0 to LongSymbols.Count - 1 do
  begin
    aItem  := TDeltaNeutralSymbol( LongSymbols.Items[i] );
    aSymbol := aItem.Call;


    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    dPrice  := (aItem.Call.Quote as TQuote).Asks[0].Price;
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aSymbol,
         aItem.callQty, pcLimit, dPrice, tmGTC, aTicket);


    gEnv.Engine.TradeBroker.Send( aTicket);

    aSymbol := aItem.Put;
    dPrice  := (aItem.Put.Quote as TQuote).Asks[0].Price;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aSymbol,
         aItem.putQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);
  end;

end;

procedure TFrmPairsTest.DoShortOrder;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  aSymbol : TSymbol;
  aItem   : TDeltaNeutralSymbol;

  dDelta, dPrice  : double;
  iQty, I: Integer;
  aVOrd : TVOrder;
begin

  DoLiquid(1);
        //
  for I := 0 to ShortSymbols.Count - 1 do
  begin
    aVOrd  := VOrders.New(-1);
    aItem  := TDeltaNeutralSymbol( ShortSymbols.Items[i] );
    aSymbol := aItem.Call;
    dPrice  := (aItem.Call.Quote as TQuote).Bids[0].Price;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aSymbol,
         -aItem.callQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);
    aVOrd.Call  := aOrder;

    aSymbol := aItem.Put;
    dPrice  := (aItem.Put.Quote as TQuote).Bids[0].Price;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aSymbol,
         -aItem.callQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);
    aVOrd.put := aOrder;
    aVOrd.vSpread := DataVal.Value[3];
  end;                  {
  dPrice  := (Future.Quote as TQuote).Bids[0].Price;
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, Future,
       -1, pcLimit, dPrice, tmGTC, aTicket);
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
   gEnv.Engine.TradeBroker.Send( aTicket);
                }
end;

procedure TFrmPairsTest.DoOrder( aPos : TPosition );
var
  aTicket : TOrderTicket;

  dPrice  : double;
  iQty: Integer;
  aOrder : TOrder;
begin

  iQty := aPos.Volume * -1;
  if iQty = 0 then Exit;

  if iQty > 0 then
    dPrice  := (aPos.Symbol.Quote as TQuote).AsKs[0].Price
  else
    dPrice  := (aPos.Symbol.Quote as TQuote).Bids[0].Price;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aPos.Symbol,
       iQty, pcLimit, dPrice, tmGTC, aTicket);
  gEnv.Engine.TradeBroker.Send( aTicket);
end;


procedure TFrmPairsTest.QuoteTimer(Sender: TObject);
var
  aDel : TDeltaNeutralSymbol;
  I, iCol, iRow: Integer;
  dPrice : double;
  aQuote  : TQuote;
  d1, d2 : double;
begin
//LongSymbols , ShortSymbols
  for I := 0 to sgSymbols.RowCount - 1 do
    sgSymbols.Rows[i].Clear;

  sgSymbols.RowCount  :=  LongSymbols.Count + ShortSymbols.Count;

  iRow := 0;

  for I := 0 to LongSymbols.Count - 1 do
  begin
    aDel  := LongSymbols.Items[i] as TDeltaNeutralSymbol;
    aDel.CalcQty( aDel.stdQty );

    iCol := 0 ;
    sgSymbols.Cells[iCol, iRow] := ifthenStr( aDel.side > 0, 'L', 'S');  inc( iCol);

    sgSymbols.Cells[iCol, iRow] := aDel.Call.ShortCode;                  inc( iCol);
    sgSymbols.Cells[iCol, iRow] := aDel.Put.ShortCode;                    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Call.Last ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Put.Last ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.callQty ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.putQty ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta ] );   inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Put.Delta ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta*aDel.callQty + aDel.Put.Delta* aDel.putQty ] );

    inc( iRow);

    DoOrder( aDel);
  end;

  for I := 0 to ShortSymbols.Count - 1 do
  begin
    aDel  := ShortSymbols.Items[i] as TDeltaNeutralSymbol;
    aDel.CalcQty( aDel.stdQty );

    iCol := 0 ;
    sgSymbols.Cells[iCol, iRow] := ifthenStr( aDel.side > 0, 'L', 'S');  inc( iCol);

    sgSymbols.Cells[iCol, iRow] := aDel.Call.ShortCode;                  inc( iCol);
    sgSymbols.Cells[iCol, iRow] := aDel.Put.ShortCode;                    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Call.Last ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.2f', [ aDel.Put.Last ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.callQty ] );    inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%d', [ aDel.putQty ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta ] );   inc( iCol);
    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Put.Delta ] );    inc( iCol);

    sgSymbols.Cells[iCol, iRow] := Format('%.4f', [ aDel.Call.Delta*aDel.callQty + aDel.Put.Delta* aDel.putQty ] );

    inc( iRow);

    DoOrder( aDel);
  end;
end;


procedure TFrmPairsTest.DoOrder( aDel : TDeltaNeutralSymbol );
var
  iSide, iQty, iChange : integer;
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  dPrice  : double;
begin

  if not FRun then Exit;
  
  iChange := aDel.callQty - aDel.callQty2;

  if iChange <> 0 then
  begin

    if aDel.side < 0  then  // 양매도라면
    begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs( iChange );
        dPrice  := (aDel.Call.Quote as TQuote).Asks[0].Price;
      end
      else begin
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Call.Quote as TQuote).Bids[0].Price;
      end;
    end else begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Call.Quote as TQuote).Bids[0].Price;
      end
      else begin
        iQty  := abs(iChange);
        dPrice  := (aDel.Call.Quote as TQuote).Asks[0].Price;
      end;
    end;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aDel.Call as TSymbol,
         iQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);
  end;

  iChange := aDel.putQty - aDel.putQty2;

  if iChange <> 0 then
  begin
    if aDel.side < 0  then  // 양매도라면
    begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs( iChange );
        dPrice  := (aDel.Put.Quote as TQuote).Asks[0].Price;
      end
      else begin
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Put.Quote as TQuote).Bids[0].Price;
      end;
    end else begin
      if iChange < 0 then begin   // 수량이 줄었다면
        iQty  := abs(iChange) * -1;
        dPrice  := (aDel.Put.Quote as TQuote).Bids[0].Price;
      end
      else begin
        iQty  := abs(iChange);
        dPrice  := (aDel.Put.Quote as TQuote).Asks[0].Price;
      end;
    end;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, aDel.Put as TSymbol,
         iQty, pcLimit, dPrice, tmGTC, aTicket);

    gEnv.Engine.TradeBroker.Send( aTicket);

  end;

end;

procedure TFrmPairsTest.refreshGrid;
var
  j, I: integer;
  aItem : TDeltaNeutralSymbol;

begin         {
  with sgSymbols do
    for I := 0 to FDeltaSymbols.Count - 1 do
    begin
      aItem := FDeltaSymbols.Items[i] as TDeltaNeutralSymbol;
      Cells[0, 0] := aItem.Call.ShortCode;
      Cells[0, 1] := aItem.Put.ShortCode;

      for j := 0 to DataVal.MaxCount - 1 do
        Cells[j+1,0]  := Format('%.2f',[ DataVal.Value[j] ]);

      Cells[5,0] := Format('%.2f', [ DataVal.SumPrice / DataVal.Count ] );

      Cells[1,1]  := Format('%.2f',[ vKospi.Last ]);
      Cells[2,1]  := Format('%.2f',[Future.Last]);
      Cells[3,1]  := Format('%.2f',[aItem.Call.Last]);
      Cells[4,1]  := Format('%.2f',[aItem.Put.Last]);
    end;   }
end;

{ TDeltaNeutralSymbols }

constructor TDeltaNeutralSymbols.Create;
begin
  inherited Create( TDeltaNeutralSymbol );
end;

destructor TDeltaNeutralSymbols.Destroy;
begin

  inherited;
end;

function TDeltaNeutralSymbols.New: TDeltaNeutralSymbol;
begin
  Result := Add as TDeltaNeutralSymbol;
end;



{ TDeltaNeutralSymbol }

procedure TDeltaNeutralSymbol.CalcQty( iDir : integer );
var
  aQuote  : TQuote;
  dS, d1, d2, d3, dTmp, dPrice  : double;

begin
  if (Call = nil ) or ( put = nil ) or ( other = nil ) then
    Exit;

  aQuote  := call.Quote as TQuote;
  dPrice  := ( aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;
  if dPrice <= 0 then
    dPrice:= call.Last;
  gEnv.Engine.SyncFuture.SymbolDelta( aQuote, dPrice );

  aQuote  := put.Quote as TQuote;
  dPrice  := ( aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;
  if dPrice <= 0 then
    dPrice:= put.Last;
  gEnv.Engine.SyncFuture.SymbolDelta( aQuote, dPrice );
      {
  aQuote  := other.Quote as TQuote;
  dPrice  := ( aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;
  if dPrice <= 0 then
    dPrice:= other.Last;
  gEnv.Engine.SyncFuture.SymbolDelta( aQuote, dPrice );
      }
  ds  := abs( put.Delta ) + abs( call.Delta );
  if ds = 0 then Exit;

  d1  := call.Delta / ds ;
  d2  := abs( put.Delta) / ds ;

  callqty2 := callQty;
  putQty2  := putQty;
  otherQty2:= otherQty2;

  if d1 > d2 then
  begin
    callQty := stdQty;
    dTmp := (d1 * stdQty) / d2;
    putQty  := Round(dTmp );
    if putQty < callQty then
      putQty := callQty
  end
  else begin
    putQty    := stdQty;
    dTmp := (d2 * stdQty ) / d1;
    callQty    := Round( dTmp );
    if callQty < callQty then
      callQty := putQty;
  end;

  ds  := put.Delta * putQty + call.Delta * callQty;

  if iDir < 0 then // 델타합을 - 로
  begin

  end
  else begin       // 델타합을 + 로

  end;
         {
  if d1 > d2 then
  begin
    putQty := iQ;
    dTmp := (d1 * iQ) / d2;
    callQty  := Round(dTmp );
    if callQty < putQty then
      callQty := putQty
  end
  else begin
    callQty    := iQ;
    dTmp := (d2 * iQ ) / d1;
    putQty    := Round( dTmp );
    if putQty < callQty then
      putQty := callQty;
  end;
          }
  {
  if Side > 0 then
  begin
    otherQty  := max(1, Round(call.Last / Other.Last ));
  end
  else
    otherQty  := max(1, floor( other.Last / put.Last) );
  }

  otherQty  := callQty;
 {
  gEnv.EnvLog( WIN_GI,
    Format( '%s : %.3f(%d), %.3f(%d), %.3f(%d)', [ ifthenStr( side > 0 , 'long',' shot'),
    call.Delta, callQty,    put.Delta, putQty,  other.Delta, otherQTy ])
  );
  }

end;

constructor TDeltaNeutralSymbol.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  Call := nil;
  Put  := nil;
  other:= nil;

  callQty := 0;
  putQty  := 0;
  otherQty:= 0;

end;

{ TVOrder }

constructor TVOrder.Create(aColl: TCollection);
begin
  inherited create( aColl );
  Call := nil;
  Put  := nil;
  Orders  := TOrderList.Create;
end;

destructor TVOrder.Destroy;
begin
  Orders.Free;
  inherited;
end;

{ TVOrders }

constructor TVOrders.Create;
begin
  inherited CReate( TVOrder );
end;

destructor TVOrders.Destroy;
begin

  inherited;
end;

function TVOrders.GetVOrder(i: integer): TVOrder;
begin
  if ( i<0 ) or ( i>= Count) then
    result := nil
  else
    result := Items[i] as TVOrder;
end;

function TVOrders.New( iSide : integer): TVOrder;
begin
  Result  := Add as TVOrder;
  Result.Side := iSide;
  Result.No   := Count;
end;

initialization
  RegisterClass( TFrmPairsTest );

Finalization
  UnRegisterClass( TFrmPairsTest )

end.
