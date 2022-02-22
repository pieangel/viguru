unit FCatchForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, ComCtrls, DateUtils,

  CleSymbols, CleAccounts,  CleStorage , CleDistributor, CleQuoteBroker ,
  CleQuoteChangeData, CleQuoteChange, CleOrders , ClePositions, CleFills
  ;

const
  TermSec = 1000;

type

  TCatchOrder = class( TCollectionItem )
  public
    CatchOrder  : TOrder;
  end;

  TCatchForm = class(TForm)
    Panel1: TPanel;
    ButtonAuto: TSpeedButton;
    ButtonSymbol: TSpeedButton;
    ComboAccount: TComboBox;
    ComboSymbol: TComboBox;
    pnlBack: TPanel;
    edtFillcnt: TEdit;
    edtFillSum: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtNms: TEdit;
    sgInfo: TStringGrid;
    Label4: TLabel;
    Bevel1: TBevel;
    Label5: TLabel;
    edtOrderQty: TEdit;
    cbUseVol: TCheckBox;
    UseMoth: TCheckBox;
    edtMaxQuoteQty: TEdit;
    Label3: TLabel;
    procedure ComboAccountChange(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure ButtonAutoClick(Sender: TObject);
    procedure edtFillSumChange(Sender: TObject);
    procedure cbUseVolClick(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtOrderQtyKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure UseMothClick(Sender: TObject);
  private
    { Private declarations }
    FAccount  : TAccount;
    FSymbol   : TSymbol;
    FQuote    : TQuote;
    FPosition : TPosition;
    FConfig   : TCatchConfig;
    FRow      : integer;
    FValue    : integer;
    FDisplay : Boolean;
    FCatchOrders  : TCollection;

    //
    FExeOneTime : boolean;

    procedure Stop;
    procedure UpdateConfig;
    procedure ApplyConfig;
    procedure DisplayConfig;
    procedure GetConfig;
    function CheckConfig : boolean;
    function SendOrder(aItem: TQuoteChangeItem): TOrder;
    procedure DoOrder(aOrder: TOrder; iID: integer);
    procedure DoPosition(aPosition: TPosition; iID: integer);
    procedure DoFill(aFill: TFill; iID: integer);
    procedure initLogVal;
    procedure SendMoth( cSS : char ; bSend : boolean = false);

  public
    { Public declarations }
    OrderCnt, FillCnt : integer;
    OrderQty, FillQty : integer;
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure TradeProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure OnCatchEvent( Sender : TObject );
    procedure OnStateEvent( const S: string);

    property Config   : TCatchConfig read FConfig;
  end;

var
  CatchForm: TCatchForm;

implementation

uses
  GAppEnv, GleLib, CleFQN, GleTypes, GleConsts
  ;

{$R *.dfm}

procedure TCatchForm.ButtonAutoClick(Sender: TObject);
var
  cSS : char;
begin
  if ButtonAuto.Down then
  begin

    if FSymbol = nil then
    begin
      ShowMessage('종목선택 하시오');
      ButtonAuto.Down := false;
      Exit;
    end;

    if FAccount = nil then
    begin
      ShowMessage('계좌선택 하시오');
      ButtonAuto.Down := false;
      Exit;
    end;

    if not CheckConfig then
    begin
      ShowMessage('입력사항을 확인하시오');
      ButtonAuto.Down := false;
      Exit;
    end;

    if FQuote <> nil then
      if FQuote.QuoteChange.Start then
      begin
        ShowMessage('이미 가동중인 종목');
        ButtonAuto.Down := false;
        Exit;
      end;


    ButtonAuto.Caption := 'Run';
    Panel1.Color       := clSkyBlue;
    pnlBack.Color      := clSkyBlue;
    cSS := CTCH_START;
  end
  else
  begin
    ButtonAuto.Caption := 'Stop';
    Panel1.Color       := clBtnFace;
    pnlBack.Color      := clBtnFace;
    cSS := CTCH_STOP;

  end;

  if FQuote <> nil then
  begin
    if  ButtonAuto.Down then
    begin
      UpdateConfig;
      FQuote.QuoteChange.OnCatchEvent := OnCatchEvent;
      FQuote.QuoteChange.OnStateEvent := OnStateEvent;
      gEnv.EnvLog( WIN_CATCH,
        Format('Start:%s,%s - S:%s, C:%s, V:%s, Nms:%s',
          [ Copy(FAccount.Code, 10, 3),
            FSymbol.ShortCode,
            edtFillSum.Text,
            edtFillCnt.Text,
            ifThenStr( cbUseVol.Checked,'True','false'),
            edtNms.Text
            ])
      , false, FSymbol.ShortCode);
    end;
    FQuote.QuoteChange.Start := ButtonAuto.Down;

    SendMoth( cSS );
  end;

end;

procedure TCatchForm.ButtonSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
      AddSymbolCombo(gSymbol.Selected, ComboSymbol);
      ComboSymbolChange(ComboSymbol);
    end;
  finally
    gSymbol.Hide
  end;
end;

procedure TCatchForm.cbUseVolClick(Sender: TObject);
begin
  //if FDisplay then Exit;
  UpdateConfig;
  SendMoth( CTCH_UPDATE );
end;

function TCatchForm.CheckConfig : boolean;
begin
  if ( edtNms.Text = '' ) or
    (edtFillSum.Text = '' ) or
    (edtFillCnt.Text = '' ) or
    (edtOrderQty.Text = '' ) or
    (edtMaxQuoteQty.Text = '' )  then
    Result := false
  else
    Result := true;
end;

procedure TCatchForm.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  Stop;
  initLogVal;
  FAccount := aAccount;

    // 자동매매 객체에 할당
  //FTrade.Account := FAccount;
end;
procedure TCatchForm.initLogVal;
begin
  OrderCnt := 0;
  FillCnt  := 0;
  OrderQty := 0;
  FillQty  := 0;
end;

procedure TCatchForm.ComboSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if ComboSymbol.ItemIndex = -1 then Exit;
  aSymbol := ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;
  if FSymbol = aSymbol then Exit;

  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );

  Stop;

  initLogVal;

  FSymbol := aSymbol;
  FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteProc, spIdle );

end;



procedure TCatchForm.FormActivate(Sender: TObject);
begin
  if (Tag <=0 ) or ( 100 <= Tag ) then
    Exit
  else
    Caption := Format('%dth SCatch Form', [ Tag ] );
end;

procedure TCatchForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TCatchForm.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
begin
//
  FDisplay:= false;
  FQuote  := nil;
  FSymbol := nil;
  FAccount:= nil;
  FPosition := nil;

  FRow    := 0;
  FValue  := 0;

  aMarkets := [ mtFutures, mtOption ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists( ComboSymbol.Items , aMarkets);

  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

  gEnv.Engine.TradeBroker.Subscribe( Self, TradeProc );

  OrderCnt := 0;
  FillCnt  := 0;
  OrderQty := 0;
  FillQty  := 0;

  FCatchOrders  := TCollection.Create( TCatchOrder );



end;

procedure TCatchForm.FormDestroy(Sender: TObject);
begin
  //
  stop;
  FCatchOrders.Free;

  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
end;

procedure TCatchForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if aStorage.FieldByName('Nms').AsString = '' then
    edtNms.Text  := '100'
  else
    edtNms.Text  := aStorage.FieldByName('Nms').AsString ;


  edtFillSum.Text := aStorage.FieldByName('FillSum').AsString ;
  edtFillCnt.Text := aStorage.FieldByName('FillCnt').AsString ;

  edtOrderQty.Text := aStorage.FieldByName('OrderQty').AsString ;
  edtMaxQuoteQty.Text := aStorage.FieldByName('MaxQuoteQty').AsString ;
end;

procedure TCatchForm.OnCatchEvent(Sender: TObject);
var
  aItem : TQuoteChangeItem;
  aOrder: TOrder;
begin
  if Sender = nil then Exit;
  aItem := Sender as TQuoteChangeItem;
  aItem.Sent := true;

  if not UseMoth.Checked then
    aOrder  := SendOrder( aItem );

  with sgInfo do
  begin
    Cells[0,FRow] := FormatDateTime('nn:ss.zzz', aItem.LastTime );
    Cells[1,FRow] := Format('%.2f, %s', [aItem.Price, ifThenStr( aItem.Side > 0,'L', 'S') ] );
    Cells[2,FRow] := Format('S:%d,C:%d,V:%d', [aItem.RctSum, aItem.RctCnt, aItem.RmvVol ] );
    Objects[0,FRow] := Pointer(FValue );
  end;

  inc(FRow);

  if FRow > 3 then
  begin
    FRow := 0;

    if FValue = 0 then
      FValue := 100
    else
      FValue := 0;
  end;

end;

procedure TCatchForm.OnStateEvent(const S: string);
begin

end;

procedure TCatchForm.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  //
end;

procedure TCatchForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('Nms').AsString := edtNms.Text;

  aStorage.FieldByName('FillSum').AsString := edtFillSum.Text;
  aStorage.FieldByName('FillCnt').AsString := edtFillCnt.Text;

  aStorage.FieldByName('OrderQty').AsString  := edtOrderQty.Text;
  aStorage.FieldByName('MaxQuoteQty').AsString:= edtMaxQuoteQty.Text;
end;

procedure TCatchForm.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aBack : TColor;
    bGray : boolean;
    stTxt : string;
begin
  with sgInfo do
  begin
    stTxt := Cells[ACol, ARow];

    if integer( Objects[0, ARow] ) = 100 then
      aBack := clSkyBlue
    else
      aBack := clWhite;

    Canvas.Font.Color := clBlack;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect );
    Canvas.TextRect( Rect, Rect.Left + 2, Rect.Top + 1, stTxt );
  end;

end;

procedure TCatchForm.Stop;
begin
  if ButtonAuto.Down then
  begin
    ButtonAuto.Down := False;
    ButtonAuto.Click;
  end;

end;

procedure TCatchForm.TradeProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_SPAWN,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
      // fill events
    FILL_NEW: DoFill( DataObj as TFill, EventID ) ;
      // position events
    POSITION_NEW,
    POSITION_UPDATE: DoPosition(DataObj as TPosition, EventID);
  end;

end;

procedure TCatchForm.DoOrder( aOrder : TOrder; iID : integer );
var
  stLog, stLog2 : string;
  aRes : TOrderResult;
  iGap : integer;
begin
  if ( aOrder.OrderSpecies <> opSCatch ) or ( aOrder.Symbol <> FSymbol) or ( aOrder.Account <> FAccount) then
    Exit;

  stLog := '';
  stLog2:= '';
  if iID = ORDER_ACCEPTED then
  begin
    inc(OrderCnt);
    if aOrder.OrderType = otNormal then
      inc(OrderQty, aOrder.ActiveQty);
    stLog := Format('Acpt : %s, %s, %s : %s, %.2f, %d [%d]',
      [
        Copy( FAccount.Code, 10 , 3),        FSymbol.ShortCode,
        FormatDateTime('hh:nn:ss.zzz', aOrder.AcptTime ),
        ifThenStr( aOrder.Side > 0, 'L','S'),
        aOrder.Price,
        aOrder.OrderQty,
        aOrder.OrderNo
      ]);

  end else
  if iID = ORDER_FILLED then
  begin
    aRes  :=  aOrder.Results.Results[ aOrder.Results.Count-1];
    if aRes = nil then Exit;

    iGap := GetMSBetween(aOrder.AcptTime, aRes.ResultTime);

    // 1초안에 전량 체결일때 카운트 증가.
    if (iGap < TermSec) and ( aOrder.State = osFilled ) then
      inc( FillCnt );

    if (iGap < TermSec) then
      inc( FillQty, aRes.Qty );

    stLog2:= Format('체결률 : %d%s OrdCnt : %d, FillCnt : %d ( OrdQty:%d, FillQty:%d )',
      [
        Round(  (FillCnt / OrderCnt ) * 100 ), '%',
        OrderCnt, FillCnt,
        OrderQty, FillQty
      ]);

    stLog := Format('Fill : %s, %s, %s : %s, %.2f, %d(%d) [%d:%d]',
      [
        Copy( FAccount.Code, 10 , 3),        FSymbol.ShortCode,
        FormatDateTime('hh:nn:ss.zzz', aRes.ResultTime  ),
        ifThenStr( aRes.Side > 0, 'L','S'),
        aRes.Price,
        aRes.Qty,aOrder.OrderQty,
        aRes.OrderNo,
        aREs.RefNo
      ]);
  end;

  if stLog <> '' then
    gEnv.EnvLog( WIN_CATCH, stLog, false, FSymbol.ShortCode);

  if stLog2 <> '' then
    gEnv.EnvLog( WIN_CATCH, stLog2, false, FSymbol.ShortCode);

end;

procedure TCatchForm.DoFill( aFill : TFill; iID : integer );
var
  dPrice : double;
  stLog  : string;
begin
  if FPosition = nil then Exit;
  if ( aFill.Account <> FAccount ) or ( aFill.Symbol <> FSymbol ) then
    Exit;

  dPrice := 0;
  if FQuote <> nil then
    dPrice := FQuote.Last;

  if (aFill.OrderSpecies = opSCatch)  then
  begin
    stLog := Format('Pos  : %s, %d, C:%.2f, A:%.2f, R:%s, %.0f',
      [
        ifThenStr( FPosition.Volume > 0 ,'L',
          ifThenStr( FPosition.Volume < 0 , 'S', 'N' ) ),
        FPosition.Volume,
        dPrice,
        FPosition.AvgPrice,
        Format('%.2n%s', [FPosition.ProfitChg,'%']) ,
        FPosition.EntryOTE + FPosition.EntryPL
      ]);
    gEnv.EnvLog( WIN_CATCH, stLog, false, FSymbol.ShortCode);
  end;

end;

procedure TCatchForm.DoPosition( aPosition : TPosition; iID : integer );
var
  stLog : string;
  dPrice: double;
begin
  if ( aPosition.Symbol <> FSymbol) or ( aPosition.Account <> FAccount) then
    Exit;

  if FPosition <> aPosition then
    FPosition := aPosition;

end;

procedure TCatchForm.UpdateConfig;
begin
  GetConfig;
  ApplyConfig;
end;

procedure TCatchForm.UseMothClick(Sender: TObject);
begin
  if ButtonAuto.Down then
  begin
    if UseMoth.Checked then
      SendMoth( CTCH_START)
    else
      SendMoth( CTCH_STOP, true);
  end;
end;

procedure TCatchForm.ApplyConfig;
begin
  FQuote.QuoteChange.Config := FConfig;
end;

procedure TCatchForm.DisplayConfig;
begin

end;

procedure TCatchForm.edtFillSumChange(Sender: TObject);
begin
  stop;
end;

procedure TCatchForm.edtOrderQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13, '.', #8]) then
    Key := #0;
end;

procedure TCatchForm.GetConfig;
begin
  FConfig.Nms := StrToIntDef( edtNms.Text, 100 );
  try
    FConfig.FillSum := StrToInt( edtFillSum.Text );
    FConfig.FillCnt := StrToInt( edtFillCnt.Text );

    FConfig.OrderQty:= StrToInt( edtOrderQty.Text );
    FConfig.MaxQuoteQty:= StrToInt( edtMaxQuoteQty.Text );
    FConfig.UseRemVol := cbUseVol.Checked;
  except
    ShowMessage('입력값이 올바르지 않음');
    stop;
  end;
end;

procedure TCatchForm.SendMoth(cSS: char; bSend : boolean);
begin

  if ( FSymbol = nil ) or ( FAccount = nil ) then
    Exit;

  FConfig.StartStop := cSS;
  if UseMoth.Checked then
    gEnv.Engine.MothBroker.Send(self, mtSCatch, Tag, FSymbol, FAccount)
  else if ( not UseMoth.Checked ) and ( bSend ) then
    gEnv.Engine.MothBroker.Send(self, mtSCatch, Tag, FSymbol, FAccount);

end;

function TCatchForm.SendOrder( aItem : TQuoteChangeItem ) : TOrder;
var
  aTicket: TOrderTicket;
  iRes, iQty : integer;
begin
    // issue an order ticket
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  iQty := StrToIntDef( edtOrderQty.Text, 0 );
  if iQty <= 0 then
    Exit;
    // create normal order
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FAccount, FSymbol,
                aItem.Side * iQty , pcLimit, aItem.Price, tmGTC, aTicket);  //

    // send the order
  if Result <> nil then
  begin
    Result.OrderSpecies := opSCatch;
    gEnv.Engine.TradeBroker.Send(aTicket);
  end;

end;

end.
