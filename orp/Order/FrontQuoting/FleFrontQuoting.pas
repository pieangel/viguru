unit FleFrontQuoting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons,
  GleTypes, GleConsts, CleAccounts, CleSymbols, CleDistributor,
  CleOrders, EnvFile, GAppConsts, CleMarkets, GAppEnv, CleFQN, GleLib,
  CleQuoteBroker, CleFrontQuotingTrade, CleStorage, ComCtrls, CleQuoteTimers,
  Mask
  ;

const
  BIDGRA = 0;
  ASKGRA = 1;
  BIDHOGA = 10;
  ASKHOGA = 11;
  BIDORDQTY = 20;
  ASKORDQTY = 21;
  BIDORDCNT = 30;
  ASKORDCNT = 31;

type
  TFrontQuotingForm = class(TForm)
    Panel1: TPanel;
    gbBid: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    cbBid: TComboBox;
    edtBidQty: TEdit;
    edtBidCnt: TEdit;
    Panel2: TPanel;
    listOrder: TListView;
    cbBidFront: TCheckBox;
    Panel3: TPanel;
    ComboAccount: TComboBox;
    ComboSymbol: TComboBox;
    SpeedButton1: TSpeedButton;
    ButtonSymbol: TSpeedButton;
    panAsk: TPanel;
    panBid: TPanel;
    btnLoad: TButton;
    btnClear: TButton;
    cbFillOrd: TCheckBox;
    Panel4: TPanel;
    Panel5: TPanel;
    edtStart: TEdit;
    dtStart: TDateTimePicker;
    udMs: TUpDown;
    cbStart: TCheckBox;
    cbVol: TComboBox;
    cbUseMoth: TCheckBox;
    btnStop: TButton;
    btnStart: TButton;
    cbVolStop: TCheckBox;
    edtVolStop: TEdit;
    edtVolStopFill: TEdit;
    cbVolStopOR: TCheckBox;
    cbQty: TCheckBox;
    cbFill: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbBidChange(Sender: TObject);
    procedure edtBidHogaChange(Sender: TObject);
    procedure cbBidFrontClick(Sender: TObject);
    procedure panBidClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure edtBidHogaKeyPress(Sender: TObject; var Key: Char);
    procedure cbUseMothClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  public
    FSymbol : TSymbol;
    FAccount : TAccount;
    FAccountGroup : TAccountGroup;
    FQuoteSet : TQuoteOderSets;
    FHogaMax : integer;
    FRun : array[BID..ASK] of boolean;
    procedure SetConfig(bCombo : boolean = false;iStartSide : integer = 0 );
    procedure OrderStop( iType : integer);
    procedure OrderStart( iType : integer );
    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
    procedure DrawListView;
    procedure UpdateListView;
    procedure RecvMoth( iBidAsk : integer );
    procedure CheckOrder( aOrder : TOrder );
    procedure OrderEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  end;

var
  FrontQuotingForm: TFrontQuotingForm;

implementation

{$R *.dfm}

procedure TFrontQuotingForm.btnClearClick(Sender: TObject);
begin
  listOrder.Clear;
end;

procedure TFrontQuotingForm.btnLoadClick(Sender: TObject);
begin
  listOrder.Clear;
  DrawListView;
end;

procedure TFrontQuotingForm.btnStartClick(Sender: TObject);
begin
  if not FRun[BID] then OrderStart(BID);
  if not FRun[ASK] then OrderStart(ASK);
end;

procedure TFrontQuotingForm.btnStopClick(Sender: TObject);
begin
  if FRun[BID] then OrderStop(BID);
  if FRun[ASK] then OrderStop(ASK);
end;

procedure TFrontQuotingForm.ButtonSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, ComboSymbol);
        // apply
      ComboSymbolChange(ComboSymbol);
    end;
  finally
    gSymbol.Hide
  end;
end;

procedure TFrontQuotingForm.cbBidChange(Sender: TObject);
begin
  OrderStop(BID);
  OrderStop(ASK);
  SetConfig( true );
end;

procedure TFrontQuotingForm.cbBidFrontClick(Sender: TObject);
begin
  OrderStop(BID);
  OrderStop(ASK);
  SetConfig( true );
end;

procedure TFrontQuotingForm.cbUseMothClick(Sender: TObject);
begin
  if FQuoteSet = nil then exit;

  if cbUseMoth.Checked then
  begin
    FQuoteSet.bRun := true;
    FQuoteSet.iOrdBidCnt := StrToIntDef(edtBidCnt.Text, 10);
    if FRun[0] then
    begin
      FQuoteSet.DataType := dtBid;
      gEnv.Engine.MothBroker.Send(self, mtFront, Tag, FSymbol, FAccount);
    end;

    if FRun[1] then
    begin
      FQuoteSet.DataType := dtAsk;
      gEnv.Engine.MothBroker.Send(self, mtFront, Tag, FSymbol, FAccount);
    end;

  end else
  begin
    FQuoteSet.bRun := false;
    if not FRun[0] then
      FQuoteSet.DataType := dtBid;
      gEnv.Engine.MothBroker.Send(self, mtFront, Tag, FSymbol, FAccount);

    if not FRun[1] then
    begin
      FQuoteSet.DataType := dtAsk;
      gEnv.Engine.MothBroker.Send(self, mtFront, Tag, FSymbol, FAccount);
    end;
  end;
end;

procedure TFrontQuotingForm.CheckOrder(aOrder: TOrder);
begin
  if FQuoteSet = nil then exit;

  FQuoteSet.New(aOrder.Price, 0, 0, aOrder.Side, aOrder.Symbol.ShortCode);
  UpdateListView;
  if aOrder.Side = 1 then
  begin
    FQuoteSet.iOrdBidCnt := FQuoteSet.iOrdBidCnt - 1;
    Panel4.Caption := 'BID : ' + IntToStr(FQuoteSet.iOrdBidCnt);
    if FQuoteSet.iOrdBidCnt = 0 then
    begin
      FRun[BID] := false;
      panBid.Tag := 0;
      panBid.Caption := 'BID START';
      panBid.Color := clBtnFace;
      panBid.BevelInner := bvRaised;
    end;
  end else
  begin
    FQuoteSet.iOrdAskCnt := FQuoteSet.iOrdAskCnt - 1;
    Panel5.Caption := 'ASK : ' + IntToStr(FQuoteSet.iOrdAskCnt);
    if FQuoteSet.iOrdAskCnt = 0 then
    begin
      FRun[ASK] := false;
      panAsk.Tag := 2;
      panAsk.Caption := 'ASK START';
      panAsk.Color := clBtnFace;
      panAsk.BevelInner := bvRaised;
    end;
  end;

     //잔량스탑...
   if aOrder.State = osActive then
     FQuoteSet.SendVolStop( aOrder.Price, aOrder.Side );

  if (not FRun[BID]) and (not FRun[ASK]) then
    gbBid.Color := clBtnFace;
end;

procedure TFrontQuotingForm.ComboAccountChange(Sender: TObject);
var
  aGroup  : TAccountGroup;
begin
  OrderStop(BID);
  OrderStop(ASK);
  aGroup  := GetComboObject( ComboAccount ) as TAccountGroup;
  if aGroup = nil then Exit;

  if aGroup = FAccountGroup then
    Exit;
  FAccountGroup := aGroup;
  if FAccountGroup = nil then Exit;
  FAccount  := FAccountGroup.Accounts.GetMarketAccount( atFO );
  SetConfig( true );
end;

procedure TFrontQuotingForm.ComboSymbolChange(Sender: TObject);
begin
  if ComboSymbol.ItemIndex = -1 then Exit;
    // get account object
  FSymbol := ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbol;
  gEnv.Engine.QuoteBroker.Subscribe(self, FSymbol ,QuoteBrokerEventHandler);
  OrderStop(BID);
  OrderStop(ASK);
  SetConfig;
end;

procedure TFrontQuotingForm.DrawListView;
var
  i, iCnt : integer;
  aItem : TQuoteOderSet;
  Item : TListItem;
  stTmp : string;
begin
  if FSymbol = nil then exit;
  iCnt := FQuoteSet.Count;
  for i := iCnt - 1 downto 0 do
  begin
    aItem := FQuoteSet.Items[i] as TQuoteOderSet;
    Item := listOrder.Items.Add;
    Item.Caption := IntToStr(aItem.TotCnt);
    Item.SubItems.Add(aItem.OrderTime);
    Item.SubItems.Add(aItem.SymbolCode);
    if aItem.iSide = 1 then
      stTmp := '매수 ' + IntToStr(aItem.iGrade)
    else
      stTmp := '매도 ' + IntToStr(aItem.iGrade);
    Item.SubItems.Add(stTmp);
    Item.SubItems.Add(IntToStr(aItem.iQty));
    //Item.SubItems.Add('');                              //상대호가잔량
    stTmp := Format('%.*n',[FSymbol.Spec.Precision, aItem.dPrice]);
    Item.SubItems.Add(stTmp);
  end;
end;

procedure TFrontQuotingForm.edtBidHogaChange(Sender: TObject);
begin
  OrderStop(BID);
  OrderStop(ASK);
  SetConfig( true );
end;

procedure TFrontQuotingForm.edtBidHogaKeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9',#13, #8]) then
     Key := #0;
end;

procedure TFrontQuotingForm.FormActivate(Sender: TObject);
begin
  if (Tag <=0 ) or ( 100 <= Tag ) then
    Exit
  else
    Caption := Format('%dth FrontQuoting', [ Tag ] );
end;

procedure TFrontQuotingForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrontQuotingForm.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
begin
  gEnv.Engine.TradeCore.AccountGroups.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption, mtSpread ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists( ComboSymbol.Items , aMarkets);


  if ComboSymbol.Items.Count > 0 then
  begin
    ComboSymbol.ItemIndex := 0;
    ComboSymbolChange(ComboSymbol);
  end;

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;



  SetConfig;
  gEnv.Engine.TradeBroker.Subscribe( Self, OrderEventHandler );
end;

procedure TFrontQuotingForm.FormDestroy(Sender: TObject);
begin
  btnStopClick(btnStop);
  FSymbol := nil;
  FAccount := nil;
  FAccountGroup := nil;
  FQuoteSet := nil;
  gEnv.Engine.QuoteBroker.Cancel(Self);
  gEnv.Engine.TradeBroker.Unsubscribe(Self);
end;

procedure TFrontQuotingForm.OrderEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aOrder : TOrder;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;
  if DataObj = nil then exit;

  case Integer(EventID) of
    ORDER_ACCEPTED,
    ORDER_REJECTED :
    begin
      aOrder := DataObj as TOrder;
      if (not cbUseMoth.Checked) or (aOrder.OrderSpecies <> opFrontQt )
      or ( aOrder.Symbol <> FSymbol) or( aOrder.Account <> FAccount)
      or (aOrder.OrderType <> otNormal) then exit;
      CheckOrder(aOrder);
    end
    else
      Exit;
  end;
end;

procedure TFrontQuotingForm.OrderStart(iType: integer);
begin
  if (FQuoteSet = nil) then exit;

  if (Length(cbVol.Text) > 6) or (Length(edtBidQty.Text) > 6)
  or (Length(edtBidCnt.Text) > 6)  then
  begin
    FRUN[iType] := false;
    ShowMessage('설정잔량 or 주문건수 or 주문수량 다시설정');
    exit;
  end;

  if FRun[iType] then
    exit;

  if iType = BID then
  begin
    SetConfig( true, 1 );
    FRun[BID] := true;
    panBid.Tag := 1;
    panBid.Caption := 'BID STOP';
    panBid.Color := BID_COLOR;
    panBid.BevelInner := bvLowered;
    FQuoteSet.DataType := dtBid;
  end else
  begin
    SetConfig( true, -1 );
    FRun[ASK] := true;
    panAsk.Tag := 3;
    panAsk.Caption := 'ASK STOP';
    panAsk.Color := ASK_COLOR;
    panAsk.BevelInner := bvLowered;
    FQuoteSet.DataType := dtAsk;
  end;

  if (FRun[BID]) or (FRun[ASK]) then
      gbBid.Color :=  $E5C5F5;

  FQuoteSet.bRun := FRun[iType];

  if cbUseMoth.Checked then
    gEnv.Engine.MothBroker.Send(self, mtFront, Tag, FSymbol, FAccount);

end;

procedure TFrontQuotingForm.OrderStop( iType : integer);
begin
  if FQuoteSet = nil then exit;
  if not FRun[iType] then exit; 

  if iType = BID then
  begin
    FRun[BID] := false;
    panBid.Tag := 0;
    panBid.Caption := 'BID START';
    panBid.Color := clBtnFace;
    panBid.BevelInner := bvRaised;
    FQuoteSet.DataType := dtBid;
  end else
  begin
    FRun[ASK] := false;
    panAsk.Tag := 2;
    panAsk.Caption := 'ASK START';
    panAsk.Color := clBtnFace;
    panAsk.BevelInner := bvRaised;
    FQuoteSet.DataType := dtAsk;
  end;
  if (not FRun[BID]) and (not FRun[ASK]) then
    gbBid.Color := clBtnFace;

   FQuoteSet.bRun := FRun[iType];


   if cbUseMoth.Checked then
    gEnv.Engine.MothBroker.Send(self, mtFront, Tag, FSymbol, FAccount);
end;

procedure TFrontQuotingForm.panBidClick(Sender: TObject);
var
  iTag, iIndex, iVol, iCnt, iQty : integer;
begin
  iVol := StrToIntDef(cbVol.Text, 0);
  iCnt := StrToIntDef(edtBidCnt.Text, 0);
  iQty := StrToIntDef(edtBidQty.Text, 0);

  //0 : 매수 주문 START,  1 : 매수 주문 STOP
  //2 : 매도 주문 START,  3 : 매도 주문 STOP
  if (iVol = 0) or (iCnt = 0) or (iQty = 0)  then
  begin
    ShowMessage('설정이 잘못되었습니다.');
    exit;
  end;

  iTag := (Sender as TPanel).Tag;
  case iTag of
    0 : OrderStart(BID);
    1 : OrderStop(BID);
    2 : OrderStart(ASK);
    3 : OrderStop(ASK);
  end;

  iIndex := cbVol.Items.IndexOf(cbVol.Text);
  if iIndex = -1 then
  begin
    if cbVol.Items.Count = 10 then
      cbVol.Items.Delete(cbVol.Items.Count-1);
    cbVol.Items.Insert(0, cbVol.Text);
  end else
  begin
    cbVol.Items.Move(iIndex , 0);
    cbVol.ItemIndex := 0;
  end;
end;

procedure TFrontQuotingForm.QuoteBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iStart, i : integer;
  bCheck : boolean;
  aQuote : TQuote;
  bStop, bSent : boolean;
  dtTime, dtSetTime : TDateTime;
  stQuote, stQuote1 : string;
begin
  if cbUseMoth.Checked then exit;
  
  aQuote := FSymbol.Quote As TQuote;
  if aQuote = nil then exit;
  if cbStart.Checked then
  begin
    dtTime := Frac(GetQuoteTime);
    dtSetTime := Frac(dtStart.Time) + EnCodeTime(0,0,0,udMs.Position*10);
    stQuote := FormatDateTime('hh:nn:ss.zzz', dtSetTime);
    stQuote1 := FormatDateTime('hh:nn:ss.zzz', dtTime);
    if dtSetTime > dtTime then exit;
  end;

  if FRun[BID]then
  begin
    bStop := false;
    iStart := FQuoteSet.iGrade;
    if cbBidFront.Checked then                                       //Front부터 체크
    begin
      for i := iStart to FHogaMax do
      begin

        bCheck := FQuoteSet.CheckHogaQty(aQuote.Bids[i - 1].Volume, aQuote.Bids[i - 1].Price, 1, cbFillOrd.Checked);
        if bCheck then
        begin
          FQuoteSet.iSide := 1;
          bSent := FQuoteSet.SendOrder(aQuote.Bids[i - 1].Price, aQuote.Bids[i - 1].Volume, i);
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
          Panel4.Caption := 'BID : ' + IntToStr(FQuoteSet.iOrdBidCnt);
          if bSent then UpdateListView;
          if FQuoteSet.iOrdBidCnt = 0 then bStop := true;
        end else
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
      end;
    end else
    begin
      for i := FHogaMax downto iStart do
      begin
        bCheck := FQuoteSet.CheckHogaQty(aQuote.Bids[i - 1].Volume, aQuote.Bids[i - 1].Price, 1, cbFillOrd.Checked);
        if bCheck then
        begin
          FQuoteSet.iSide := 1;
          bSent := FQuoteSet.SendOrder(aQuote.Bids[i - 1].Price, aQuote.Bids[i - 1].Volume, i);
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
          Panel4.Caption := 'BID : ' + IntToStr(FQuoteSet.iOrdBidCnt);
          if bSent then UpdateListView;
          if FQuoteSet.iOrdBidCnt = 0 then bStop := true;
        end else
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
      end;
    end;
    if bStop then OrderStop(BID);
  end;


  if FRun[ASK] then
  begin
    bStop := false;
    iStart := FQuoteSet.iGrade;
    if cbBidFront.Checked then                                         //Front부터 체크
    begin
      for i := iStart to FHogaMax do
      begin
        bCheck := FQuoteSet.CheckHogaQty(aQuote.Asks[i - 1].Volume, aQuote.Asks[i - 1].Price, -1, cbFillOrd.Checked);
        if bCheck then
        begin
          FQuoteSet.iSide := -1;
          bSent := FQuoteSet.SendOrder(aQuote.Asks[i - 1].Price, aQuote.Asks[i - 1].Volume, i);
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
          Panel5.Caption := 'ASK : ' + IntToStr(FQuoteSet.iOrdAskCnt);
          if bSent then UpdateListView;
          if FQuoteSet.iOrdAskCnt = 0 then bStop := true;
        end else
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
      end;
    end else
    begin
      for i := FHogaMax downto iStart do
      begin
        bCheck := FQuoteSet.CheckHogaQty(aQuote.Asks[i - 1].Volume, aQuote.Asks[i - 1].Price, -1, cbFillOrd.Checked);
        if bCheck then
        begin
          FQuoteSet.iSide := -1;
          bSent := FQuoteSet.SendOrder(aQuote.Asks[i - 1].Price, aQuote.Asks[i - 1].Volume, i);
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
          Panel5.Caption := 'ASK : ' + IntToStr(FQuoteSet.iOrdAskCnt);
          if bSent then UpdateListView;
          if FQuoteSet.iOrdAskCnt = 0 then bStop := true;
        end else
          FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);
      end;
    end;
    if bStop then OrderStop(ASK);
  end;
end;

procedure TFrontQuotingForm.RecvMoth(iBidAsk: integer);
begin
  if iBidAsk = 0 then
    OrderStop(BID)
  else
    OrderStop(ASK);
end;

procedure TFrontQuotingForm.SetConfig(bCombo : boolean = false; iStartSide : integer = 0);
var
  i, iMill, iPrevIndex : integer;
  stTime : string;
begin
  if FSymbol = nil then exit;

  if FSymbol.Spec.Market in [mtStock,mtELW] then
    FHogaMax := 10
  else if FSymbol.Spec.Market in [mtFutures, mtOption, mtSpread] then
  begin
    if FSymbol.IsStockF then
      FHogaMax := 10
    else
      FHogaMax := 5;
  end;

  iPrevIndex := cbBid.ItemIndex;
  if not bCombo then
  begin
    cbBid.Clear;
    for i := 1 to FHogaMax do
      cbBid.Items.add(IntToStr(i));

    if FHogaMax > 0 then
    begin
      if cbBid.Items.Count < iPrevIndex then
        cbBid.ItemIndex := 2
      else
        cbBid.ItemIndex := iPrevIndex;
    end;
  end;

  if FQuoteSet = nil then
    FQuoteSet := TQuoteOderSets.Create;
  FQuoteSet.Account := FAccount;
  FQuoteSet.Symbol := FSymbol;

  FQuoteSet.iGrade := cbBid.ItemIndex + 1;
  FQuoteSet.iHoga := StrToIntDef(cbVol.Text,0);
  FQuoteSet.iOrdQty := StrToIntDef(edtBidQty.Text,0);

  case iStartSide of
    0 :
    begin
      FQuoteSet.iOrdBidCnt := StrToIntDef(edtBidCnt.Text,0);
      FQuoteSet.iOrdAskCnt := StrToIntDef(edtBidCnt.Text,0);
    end;
    1 : FQuoteSet.iOrdBidCnt := StrToIntDef(edtBidCnt.Text,0);
    -1 : FQuoteSet.iOrdAskCnt := StrToIntDef(edtBidCnt.Text,0);
  end;

  Panel4.Caption := 'BID : ' + IntToStr(FQuoteSet.iOrdBidCnt);
  Panel5.Caption := 'ASK : ' + IntToStr(FQuoteSet.iOrdAskCnt);
  FQuoteSet.bFront := cbBidFront.Checked;
  FQuoteSet.bOrdFull := cbFillOrd.Checked;
  FQuoteSet.bTimeUse := cbStart.Checked;
  stTime := FormatDateTime('hhnnss', dtStart.Time);
  iMill := StrToIntDef(edtStart.Text, 0);
  FQuoteSet.stStartTime := Format('%s%.2d',[stTime, iMill]);

  if (FAccount <> nil) and (FSymbol <> nil) and (cbVolStop.Checked) then
  begin
    FQuoteSet.Pot := gEnv.Engine.TradeCore.VolStops.GetBoard(FAccount, FSymbol);
    if FQuoteSet.Pot = nil then
      cbVolStop.Checked := false;
  end;

  FQuoteSet.VolStop := cbVolStop.Checked;
  FQuoteSet.VolStopOR := cbVolStopOR.Checked;
  FQuoteSet.VolStopIsQty := cbQty.Checked;
  FQuoteSet.VolStopQty := StrToIntDef(edtVolStop.Text, 10);
  FQuoteSet.VolStopIsFill := cbFill.Checked;
  FQuoteSet.VolStopFill := StrToIntDef(edtVolStopFill.Text, 10);

  if panBid.Tag = 0 then
     FRun[BID]:= false
  else
     FRun[BID] := true;

  if panAsk.Tag = 2 then
    FRun[ASK] := false
  else
    FRun[ASK] := true;
end;

procedure TFrontQuotingForm.UpdateListView;
var
  i, iCnt : integer;
  aItem : TQuoteOderSet;
  Item : TListItem;
  stTmp : string;
begin
  iCnt := FQuoteSet.Count;
  aItem := FQuoteSet.Items[iCnt - 1] as TQuoteOderSet;
  Item := listOrder.Items.Insert(0);
  Item.Caption := IntToStr(aItem.TotCnt);             //Count
  Item.SubItems.Add(aItem.OrderTime);                 //주문시간
  Item.SubItems.Add(aItem.SymbolCode);               //종목코드
  if aItem.iSide = 1 then                             //호가
    stTmp := '매수 ' + IntToStr(aItem.iGrade)
  else
    stTmp := '매도 ' + IntToStr(aItem.iGrade);
  Item.SubItems.Add(stTmp);
  Item.SubItems.Add(IntToStr(aItem.iQty));            //호가잔량
  //Item.SubItems.Add('');                              //상대호가잔량

  stTmp := Format('%.*n',[FSymbol.Spec.Precision, aItem.dPrice]); //가격
  Item.SubItems.Add(stTmp);
end;

procedure TFrontQuotingForm.LoadEnv(aStorage: TStorage);
var
  i, iCnt : integer;
  stSec : string;
begin
  if aStorage = nil then Exit;
  cbBid.ItemIndex := aStorage.FieldByName('cbBid').AsInteger;

  iCnt := aStorage.FieldByName('cbVolCnt').AsInteger;
  if iCnt = 0 then
  begin
    cbVol.Items.Add('100');
  end else
  begin
    for i := 0 to iCnt - 1 do
    begin
      stSec := 'cbVol' + IntToStr(i);
      cbVol.Items.Add(aStorage.FieldByName(stSec).AsString);
    end;
  end;
  cbVol.ItemIndex := aStorage.FieldByName('cbVolIndex').AsInteger;

  edtBidQty.Text := aStorage.FieldByName('edtBidQty').AsString;
  edtBidCnt.Text := aStorage.FieldByName('edtBidCnt').AsString;
  cbBidFront.Checked := aStorage.FieldByName('cbBidFront').AsBoolean;
  cbFillOrd.Checked := aStorage.FieldByName('cbFillOrd').AsBoolean;
  udMs.Position := aStorage.FieldByName('udMs').AsInteger;
  dtStart.Time := aStorage.FieldByName('dtStart').AsFloat;
  cbStart.Checked := aStorage.FieldByName('cbStart').AsBoolean;
  cbUseMoth.Checked := aStorage.FieldByName('cbUseMoth').AsBoolean;

  cbVolStop.Checked := aStorage.FieldByName('cbVolStop').AsBoolean;
  cbVolStopOR.Checked := aStorage.FieldByName('cbVolStopOR').AsBoolean;
  cbQty.Checked := aStorage.FieldByName('cbQty').AsBoolean;
  edtVolStop.Text := aStorage.FieldByName('edtVolStop').AsString;
  if edtVolStop.Text = '' then edtVolStop.Text := '100';
  cbFill.Checked := aStorage.FieldByName('cbFill').AsBoolean;
  edtVolStopFill.Text := aStorage.FieldByName('edtVolStopFill').AsString;
  if edtVolStopFill.Text = '' then edtVolStopFill.Text := '100';
end;

procedure TFrontQuotingForm.SaveEnv(aStorage: TStorage);
var
  i : integer;
  stSec : string;
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('cbBid').AsInteger := cbBid.ItemIndex;

  aStorage.FieldByName('cbVolCnt').AsInteger := cbVol.Items.Count;
  aStorage.FieldByName('cbVolIndex').AsInteger := cbVol.ItemIndex;
  for i := 0 to cbVol.Items.Count - 1 do
  begin
    stSec := 'cbVol' + IntToStr(i);
    aStorage.FieldByName(stSec).AsString := cbVol.Items[i];
  end;

  aStorage.FieldByName('edtBidQty').AsString := edtBidQty.Text;
  aStorage.FieldByName('edtBidCnt').AsString := edtBidCnt.Text;
  aStorage.FieldByName('cbBidFront').AsBoolean := cbBidFront.Checked;
  aStorage.FieldByName('cbFillOrd').AsBoolean := cbFillOrd.Checked;
  aStorage.FieldByName('udMs').AsInteger := udMs.Position;
  aStorage.FieldByName('dtStart').AsFloat := dtStart.Time;
  aStorage.FieldByName('cbStart').AsBoolean := cbStart.Checked;
  aStorage.FieldByName('cbUseMoth').AsBoolean := cbUseMoth.Checked;

  aStorage.FieldByName('cbVolStop').AsBoolean := cbVolStop.Checked;
  aStorage.FieldByName('cbVolStopOR').AsBoolean := cbVolStopOR.Checked;
  aStorage.FieldByName('cbQty').AsBoolean := cbQty.Checked;
  aStorage.FieldByName('edtVolStop').AsString := edtVolStop.Text;
  aStorage.FieldByName('cbFill').AsBoolean := cbFill.Checked;
  aStorage.FieldByName('edtVolStopFill').AsString := edtVolStopFill.Text;
end;

end.
