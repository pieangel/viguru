unit FlePositionList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,
    // lemon: common
  LemonEngine,
    // lemon: trade
  CleTradeCore, ClePositions, GleConsts,
    // lemon: utils
  CleListViewPeer, CleDistributor;

type
  TPositionListForm = class(TForm)
    ListViewPositions: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListViewPositionsData(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewPositionsDblClick(Sender: TObject);
  private
    FListViewPeer: TListViewPeer;
    FEngine: TLemonEngine;
    procedure TradeBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure SetEngine(const Value: TLemonEngine);
  public
    property Engine: TLemonEngine read FEngine write SetEngine;
    procedure ReLoad;
  end;

var
  PositionListForm: TPositionListForm;

implementation

uses GAppEnv, FOrderBoard;

{$R *.dfm}

procedure TPositionListForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPositionListForm.FormCreate(Sender: TObject);
begin
  FListViewPeer := TListViewPeer.Create(ListViewPositions);
end;

procedure TPositionListForm.FormDestroy(Sender: TObject);
begin
  FListViewPeer.Free;

  if FEngine <> nil then
    FEngine.TradeBroker.Unsubscribe(Self);
end;

procedure TPositionListForm.SetEngine(const Value: TLemonEngine);
begin
  if Value = nil then Exit;

  FEngine := Value;
  FEngine.TradeBroker.Subscribe(Self, TradeBrokerEventHandler);

  FListViewPeer.Objects := FEngine.TradeCore.Positions;
  FListViewPeer.Map;
  FListViewPeer.Refresh;
end;

procedure TPositionListForm.TradeBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case EventID of
    POSITION_NEW: FListViewPeer.Map;
    POSITION_UPDATE: FListViewPeer.Refresh;
  end;
end;

procedure TPositionListForm.ListViewPositionsData(Sender: TObject;
  Item: TListItem);
var
  i: Integer;
  aPosition: TPosition;
  aPl : double;
  iPrec : integer;
begin
  if FEngine = nil then Exit;

    // reverse order
  aPosition := FEngine.TradeCore.Positions[Item.Index];
  if aPosition = nil then Exit;

  iPrec := aPosition.Symbol.Spec.Precision;
  Item.Caption := aPosition.Account.Name; // account
  Item.Data := aPosition;
  Item.SubItems.Clear;

  Item.SubItems.Add(aPosition.Symbol.Name); // symbol
  Item.SubItems.Add(IntToStr(aPosition.Volume)); // volume
  Item.SubItems.Add(Format('%.*n', [iPrec, aPosition.AvgPrice])); // avg price
  Item.SubItems.Add(IntToStr(aPosition.PrevVolume)); // prev volume
  Item.SubItems.Add(Format('%.*n', [iPrec, aPosition.PrevAvgPrice])); // avg price
  aPl := aPosition.EntryPL;
  if aPosition.Symbol.IsStockF then
    aPl := aPl * 10;
  Item.SubItems.Add(Format('%.0n', [aPl])); // P&L
end;

procedure TPositionListForm.ListViewPositionsDblClick(Sender: TObject);
var
  aItem : TListItem;
  aPos  : Tposition;
  aForm : TForm;
begin
  caption := IntToStr( ListViewPositions.ItemIndex );
  aItem := ListViewPositions.Items.Item[ ListViewPositions.ItemIndex ];
  aPos  := TPosition( aItem.Data );

  if aPos = nil then Exit;

  aForm := gEnv.Engine.FormBroker.Selected;

  if aForm <> nil then
  begin
    TOrderBoardForm( aForm ).SetSymbol2( aPos.Symbol, aPos.Symbol.Spec.Market );
  end;

end;

procedure TPositionListForm.ReLoad;
begin
  SetEngine( gEnv.Engine );
end;

end.
