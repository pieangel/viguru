unit FleYouNI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSymbols, CleAccounts, ClePositions, CleQuoteBroker,

  CleOrders, CleFills,

  CleDistributor, ComCtrls, ExtCtrls, StdCtrls

  ;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    edtAccount: TEdit;
    Button6: TButton;
    edtMine: TEdit;
    Button1: TButton;
    Button2: TButton;
    edtSymbol: TLabeledEdit;
    stTxt: TStatusBar;
    edtMultiple: TLabeledEdit;
    ed: TLabeledEdit;
    cbIgnore: TCheckBox;
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
  private
    { Private declarations }
    FMineAcnt , FTargetAcnt : TAccount;
    FMinePos  , FTargetPos  : TPositionList;
    FSymbol : TSymbol;

    procedure DoPosition(aPosition: TPosition; EventID: TDistributorID);
    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID);
  public
    { Public declarations }
    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  end;

var
  Form2: TForm2;

implementation

uses
  GAppEnv, GleLib , GleConsts
  ;

{$R *.dfm}

procedure TForm2.Button2Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbStart.Checked then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin
          if FSymbol <> nil then
            gEnv.Engine.QuoteBroker.Cancel( Self, FSymbol);
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.ShortCode;
          gEnv.Engine.QuoteBroker.Subscribe(Self, FSymbol, QuotePrc);
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end
end;

procedure TForm2.Button6Click(Sender: TObject);
begin
  if gAccount = nil then
    gEnv.CreateAccountSelect;

  try
    gAccount.Left := GetMousePoint.X+10;
    gAccount.Top  := GetMousePoint.Y;

    if gAccount.Open then
    begin

      if ( gAccount.Selected <> nil ) then
      begin
        case (Sender as TButton).Tag of
          0 :
            begin
              FTargetAcnt:= TAccount( gAccount.Selected );
              edtAccount.Text := FTargetAcnt.Name
            end;
          1 :
            begin
              FMineAcnt:= TAccount( gAccount.Selected );
              edtMine.Text := FMineAcnt.Name
            end;
        end;
      end;
    end;
  finally
    gAccount.Hide;
  end;
end;

procedure TForm2.cbStartClick(Sender: TObject);
begin

  if ( FTargetAcnt = nil ) or ( FMineAcnt = nil ) then
  begin
    cbStart.Checked := false;
    Exit;
  end;

  if (not cbIgnore.Checked ) and ( FSymbol = nil ) then
  begin
    cbStart.Checked := false;
    Exit;
  end;

  if cbStart.Checked then
  begin
    gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );
  end
  else begin
    gEnv.Engine.TradeBroker.Unsubscribe( Self );
  end;
end;

procedure TForm2.DoOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  // 타켓의 주문이 왔다.
  if aOrder.Account = FTargetAcnt  then
  begin
    // 정상적인 주문만 처리한다.
    case aOrder.State of
      osActive:
        begin
          

        end;
      osFilled: ;
      osCanceled: ;
      osConfirmed: ;
      osFailed: ;
      osRejected: ;
    end;

  end else
  // 내주문이 왔다.
  if aOrder.Account = FMineAcnt then
  begin

  end;
end;

procedure TForm2.DoPosition(aPosition: TPosition; EventID: TDistributorID);
begin
  if aPosition.Account = FTargetAcnt then
  begin
    if (not cbIgnore.Checked) and ( aPosition.Symbol = FSymbol ) then
      FTargetPos.Add( aPosition)
    else if ( cbIgnore.Checked ) then
      FTargetPos.Add( aPosition);
  end else
  if aPosition.Account = FMineAcnt then
  begin
    if (not cbIgnore.Checked) and ( aPosition.Symbol = FSymbol ) then
      FMinePos.Add( aPosition)
    else if ( cbIgnore.Checked ) then
      FMinePos.Add( aPosition);
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FMineAcnt := nil;
  FTargetAcnt := nil;
  FMinePos  := TPositionList.Create;
  FTargetPos:= TPositionList.Create;
  FSymbol     := nil;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FMinePos.Free;
  FTargetPos.Free;
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TForm2.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if not cbStart.Checked then Exit;

end;

procedure TForm2.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if not cbStart.Checked then Exit;

  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
      // fill events
    FILL_NEW: ;
      // position events
    POSITION_NEW,
    POSITION_UPDATE   : DoPosition(DataObj as TPosition, EventID);
  end;
  
end;

end.
