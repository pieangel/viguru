unit FleVirtualTradeService;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls, Grids,

    // lemon: trade
  CleOrders, CleVirtualTradeService,
    // lemon: utils
  CleStorage;

type
  TVirtualTradeServiceForm = class(TForm)
    GroupBox1: TGroupBox;
    SpeedButtonAbortAllOrders: TSpeedButton;
    Bevel1: TBevel;
    ListViewMarkets: TListView;
    Label1: TLabel;
    MemoLog: TMemo;
    Label5: TLabel;
    GroupBoxMarket: TGroupBox;
    StringGridMarketDepth: TStringGrid;
    Label2: TLabel;
    ListViewOrders: TListView;
    Label3: TLabel;
    SpeedButtonMarketAbortAllOrders: TSpeedButton;
    SpeedButtonMarketFillAllOrders: TSpeedButton;
    SpeedButtonFillAllOrders: TSpeedButton;
    SpeedButtonSaveLogs: TSpeedButton;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtOrder: TEdit;
    edtAccept: TEdit;
    edtFill: TEdit;
    udOrder: TUpDown;
    udAccept: TUpDown;
    udFill: TUpDown;
    udPartFillRatio: TUpDown;
    edtPartFillRatio: TEdit;
    edtPartFill: TEdit;
    udPartFill: TUpDown;
    Label9: TLabel;
    labelfill: TLabel;
    Label8: TLabel;
    edtearchFill: TEdit;
    udEarchFill: TUpDown;
    cbPartFill: TCheckBox;
    Bevel2: TBevel;
    cbTraining: TCheckBox;
    procedure SpeedButtonFillAllOrdersClick(Sender: TObject);
    procedure SpeedButtonAbortAllOrdersClick(Sender: TObject);
    procedure SpeedButtonMarketFillAllOrdersClick(Sender: TObject);
    procedure SpeedButtonMarketAbortAllOrdersClick(Sender: TObject);
    procedure ListViewOrdersData(Sender: TObject; Item: TListItem);
    procedure ListViewMarketsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewMarketsData(Sender: TObject; Item: TListItem);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtOrderKeyPress(Sender: TObject; var Key: Char);
    procedure udOrderClick(Sender: TObject; Button: TUDBtnType);
    procedure cbPartFillClick(Sender: TObject);
    procedure edtPartFillKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtOrderKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbTrainingClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FService: TVirtualTradeService;
    FSelected: TVirtualTradeMarket;
    
    procedure RefreshOrders;
    procedure MarketQuote(Sender: TObject);
    procedure SetMarketDepth;
    procedure ClearMarketDepth;
    procedure SetSelected;
    procedure DefaultInit;

    procedure RefreshMarkets;
    procedure MarketRefresh(Sender: TObject);
    procedure MarketUpdated(Sender: TObject);
    procedure DoServiceLog(Sender: TObject; stLog: String);
    procedure SetService(const Value: TVirtualTradeService);
  public
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    property Service: TVirtualTradeService read FService write SetService;
  end;

var
  VirtualTradeServiceForm: TVirtualTradeServiceForm;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TVirtualTradeServiceForm.FormCreate(Sender: TObject);
begin
  FSelected := nil;
end;

procedure TVirtualTradeServiceForm.FormDestroy(Sender: TObject);
begin
  FService.Free;
  gEnv.Engine.VirtualTradeService := nil;
  VirtualTradeServiceForm := nil;
end;

procedure TVirtualTradeServiceForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

//---------------------------------------------------------< work environment >

procedure TVirtualTradeServiceForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  FService.Enabled := true;
    // allow accept
  FService.AllowAccept := true;
  FService.RejectCode  := '99';

    // allow fill
  FService.AllowFill := true;

    // update selected
  SetSelected;

  udPartFill.Position   := aStorage.FieldByName('PartFill').AsInteger;
  udEarchFill.Position  := aStorage.FieldByName('RtFillDelay').AsInteger;
  udPartFillRatio.Position   := aStorage.FieldByName('PartFillRatio').AsInteger;
  cbPartFill.Checked    := aStorage.FieldByName('PartFillEnabled').AsBoolean;
  udAccept.Position     := aStorage.FieldByName('AceptDelay').AsInteger;
  udFill.Position       := aStorage.FieldByName('FillDelay').AsInteger;
  udOrder.Position      := aStorage.FieldByName('CommDelay').AsInteger;

  cbTraining.Checked    := aStorage.FieldByName('Training').AsBoolean;

  DefaultInit;

  {
    // load saved parameters
  CheckBoxServiceEnabled.Checked := aStorage.FieldByName('Enabled').AsBoolean;
  CheckBoxAllowAccept.Checked := aStorage.FieldByName('Accept').AsBoolean;
  CheckBoxAllowFill.Checked := aStorage.FieldByName('Fill').AsBoolean;
  ComboBoxFillMode.ItemIndex := aStorage.FieldByName('FillMode').AsInteger;

    // apply
  CheckBoxGlobalClick(nil);
  }
end;

procedure TVirtualTradeServiceForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('RtFillDelay').AsInteger := StrToIntDef( edtEarchFill.Text,0 );
  aStorage.FieldByName('PartFill').AsInteger := StrToIntDef( edtPartFill.Text ,0);
  aStorage.FieldByName('PartFillEnabled').AsBoolean := cbPartFill.Checked;
  aStorage.FieldByName('PartFillRatio').AsInteger := StrToIntDef( edtPartFillRatio.Text,0 );

  aStorage.FieldByName('AceptDelay').AsInteger := StrToIntDef( edtAccept.Text ,0);
  aStorage.FieldByName('FillDelay').AsInteger := StrToIntDef( edtFill.Text,0 );
  aStorage.FieldByName('CommDelay').AsInteger := StrToIntDef( edtorder.Text ,0);

  aStorage.FieldByName('Training').AsBoolean  := cbTraining.Checked;
end;

//----------------------------------------------------------------------< set >

procedure TVirtualTradeServiceForm.SetService(
  const Value: TVirtualTradeService);
begin
  if Value = nil then Exit;

  FService := Value;

  FService.Enabled := true;
    // allow accept
  FService.AllowAccept := true;
  FService.RejectCode  := '99';

    // allow fill
  FService.AllowFill := true;

  FService.OnAdd := MarketRefresh;
  FService.OnUpdate := MarketUpdated;
  FService.OnDelete := MarketRefresh;
  FService.OnRefresh := MarketRefresh;
  FService.OnQuote := MarketQuote;
  FService.OnLog := DoServiceLog;

  ListViewMarkets.Refresh;

  DefaultInit;
end;

procedure TVirtualTradeServiceForm.SpeedButtonAbortAllOrdersClick(
  Sender: TObject);
begin
  if FService = nil then Exit;

  FService.AbortAllOrders;
end;

procedure TVirtualTradeServiceForm.SpeedButtonFillAllOrdersClick(
  Sender: TObject);
begin
  if FService = nil then Exit;

  FService.FillAllOrders;
end;


//-----------------------------------------------------------< service events >

procedure TVirtualTradeServiceForm.MarketUpdated(Sender: TObject);
var
  aItem: TListItem;
begin
  aItem := ListViewMarkets.FindData(0, Sender, True, True);
  if aItem <> nil then
    aItem.Update;

  if FSelected = Sender then
    RefreshOrders;
end;

procedure TVirtualTradeServiceForm.MarketRefresh(Sender: TObject);
begin
  RefreshMarkets;
end;

procedure TVirtualTradeServiceForm.MarketQuote(Sender: TObject);
begin
  if Sender = FSelected then
    SetMarketDepth;
end;

procedure TVirtualTradeServiceForm.DefaultInit;
begin
  with FService do
  begin
    PartFillRatio   := udPartFillRatio.Position;
    RtFillDelay     := udEarchFill.Position;
    PartFill        := udPartFill.Position;
    PartFillEnabled := cbPartFill.Checked;
    AceptDelay      := udAccept.Position;
    FillDelay       := udFill.Position;
    CommDelay       := udOrder.Position;
  end;
end;

procedure TVirtualTradeServiceForm.DoServiceLog(Sender: TObject; stLog: String);
begin
  MemoLog.Lines.Insert(0, FormatDateTime('hh:nn:ss ', Now) + stLog);
end;

procedure TVirtualTradeServiceForm.edtOrderKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
  var
    iTag : integer;
begin

  if key = VK_RETURN then
  begin
    iTag  := TEdit( Sender ).Tag;

    case iTag of
      0 : FService.CommDelay  := StrToIntDef( edtOrder.Text, 15 ) ;
      1 : FService.AceptDelay := StrToIntDef( edtAccept.Text, 30 )          ;
      2 : FService.FillDelay  := StrToIntDef( edtFill.Text, 200 )          ;
      3 : FService.RtFillDelay:= StrToIntDef( edtEarchFill.Text, 200)          ;
      4 : FService.PartFillRatio:= StrToIntDef( edtPartFillRatio.Text, 50)   ;
      5 : FService.PartFill := StrToIntDef( edtPartFill.Text, 200 );
      else
        Exit;
    end;
  end;
end;

procedure TVirtualTradeServiceForm.edtOrderKeyPress(Sender: TObject;
  var Key: Char);
  var
    iTag : integer;
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;

end;

procedure TVirtualTradeServiceForm.edtPartFillKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin

end;

//----------------------------------------------------------< listview events >

procedure TVirtualTradeServiceForm.RefreshMarkets;
begin
  ListViewMarkets.Items.Count := FService.Count;
  ListViewMarkets.Refresh;
    //
  SetSelected;
end;

procedure TVirtualTradeServiceForm.ListViewMarketsData(Sender: TObject;
  Item: TListItem);
var
  aMarket: TVirtualTradeMarket;
begin
  if FService = nil then Exit;

  aMarket := FService[Item.Index];
  if aMarket = nil then Exit;

  Item.Caption := aMarket.StatusStr;
  Item.Data := aMarket;
  Item.SubItems.Clear;
  if aMarket.Symbol <> nil then
    Item.SubItems.Add(aMarket.Symbol.Code)
  else
    Item.SubItems.Add('n/a');
  Item.SubItems.Add(IntToStr(aMarket.Orders.Count));
end;

procedure TVirtualTradeServiceForm.ListViewMarketsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
    FSelected := TVirtualTradeMarket(Item.Data)
  else
    FSelected := nil;

  SetSelected;
end;


//------------------------------------------------------------------< market >

procedure TVirtualTradeServiceForm.SetSelected;
begin
  if FSelected = nil then
  begin
    ClearMarketDepth;
    ListViewOrders.Items.Count := 0;
    ListViewOrders.Refresh;
    GroupBoxMarket.Enabled := False;
  end else
  begin
    SetMarketDepth;
    RefreshOrders;
    GroupBoxMarket.Enabled := True;
  end;
end;

procedure TVirtualTradeServiceForm.cbPartFillClick(Sender: TObject);
begin
  FService.PartFillEnabled  := cbPartFill.Checked;
end;

procedure TVirtualTradeServiceForm.cbTrainingClick(Sender: TObject);
begin
  FService.Training := cbTraining.Checked;
end;

procedure TVirtualTradeServiceForm.ClearMarketDepth;
var
  iCol, iRow: Integer;
begin
  with StringGridMarketDepth do
    for iCol := 0 to ColCount - 1 do
      for iRow := 0 to RowCount - 1 do
        Cells[iCol,iRow] := '';
end;

procedure TVirtualTradeServiceForm.SetMarketDepth;
var
  i, iRow: Integer;
begin
  if (FSelected = nil) or (FSelected.Quote = nil) then Exit;

  with StringGridMarketDepth do
  begin
      // asks
    for i := 0 to FSelected.Quote.Asks.Count - 1 do
    begin
      iRow := 4-i;
      if iRow < 0 then Break;

      Cells[1,iRow] := Format('%.2f', [FSelected.Quote.Asks[i].Price]);
      Cells[0,iRow] := Format('%d', [FSelected.Quote.Asks[i].Volume]);
    end;
      // bids
    for i := 0 to FSelected.Quote.Asks.Count - 1 do
    begin
      iRow := 5+i;
      if iRow >= RowCount then Break;

      Cells[1,iRow] := Format('%.2f', [FSelected.Quote.Bids[i].Price]);
      Cells[2,iRow] := Format('%d', [FSelected.Quote.Bids[i].Volume]);
    end;
  end;
end;

procedure TVirtualTradeServiceForm.SpeedButtonMarketAbortAllOrdersClick(Sender: TObject);
begin
  if FSelected <> nil then
    FSelected.AbortAllOrders;
end;


procedure TVirtualTradeServiceForm.SpeedButtonMarketFillAllOrdersClick(
  Sender: TObject);
begin
  if FSelected <> nil then
    FSelected.FillAllOrders;
end;

procedure TVirtualTradeServiceForm.udOrderClick(Sender: TObject;
  Button: TUDBtnType);
var
  iTag  : integer;
begin

  iTag  := TUpDown( Sender ).Tag;
  case iTag of
    0 : FService.CommDelay  := TUpDown( Sender ).Position;
    1 : FService.AceptDelay := TUpDown( Sender ).Position;
    2 : FService.FillDelay  := TUpDown( Sender ).Position;
    3 : FService.RtFillDelay:= TUpDown( Sender ).Position;
    4 : FService.PartFillRatio:= TUpDown( Sender ).Position;
    5 : FService.PartFill := TUpDown( Sender ).Position;
    else
      Exit;
  end;

end;

//-------------------------------------------------------------------< orders >

procedure TVirtualTradeServiceForm.RefreshOrders;
begin
  if FSelected = nil then Exit;

  ListViewOrders.Items.Count := FSelected.Orders.Count;
  ListViewOrders.Refresh;
end;

procedure TVirtualTradeServiceForm.ListViewOrdersData(Sender: TObject;
  Item: TListItem);
var
  aOrder: TOrder;
begin
  if FSelected = nil then Exit;

  aOrder := FSelected.Orders[Item.Index];
  if aOrder = nil then Exit;

  Item.Caption := IntToStr(aOrder.OrderNo);
  Item.Data := aOrder;
  Item.SubItems.Clear;
  Item.SubItems.Add(aOrder.OrderTypeDesc);
  Item.SubItems.Add(aOrder.Account.Name);
  Item.SubItems.Add(IntToStr(aOrder.ActiveQty));
  Item.SubItems.Add(Format('%.2f',[aOrder.Price]));
end;


end.
