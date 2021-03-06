unit FleOrderList2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSymbols, CleOrders, CleAccounts, GleTypes, CleFilltering, CleDistributor,
  GleConsts, CleStorage,  ClePositions,

  Menus, StdCtrls, Grids,
  ComCtrls, ExtCtrls
  ;

Const
  MarketType : array[0..MARKET-1] of string =
    ('전체', '선물옵션', '선물', '옵션', 'Call', 'Put', '주식');
  OrderIndex  = 0;
  InsertRow  = 2;

  // update cell
  OrderName     = 1;
  UnFillQty     = 4;
  FillQty       = 5;
  AvgPrice      = 6;
  FilterName    = 7;
         {
  osReady,
                   // with server
                 osSent, osSrvAcpt, osSrvRjt,
                   // with exchange
                 osActive, osRejected, osFilled, osCanceled,
                 osConfirmed, osFailed);}
  StateName : array [TOrderState] of string = ('준비주문', '전송된주문','서버접수',
    '서버거부', '증전접수', '거부주문', '전량체결', '취소', '확인', '실패' );

type

  TOrderListType = ( olAdd, olDelete, olUpdate );

  TMyGrid = class( TStringGrid );

  TFrmOrderList2 = class(TForm)
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    sgList: TStringGrid;
    Label1: TLabel;
    cbAccount: TComboBox;
    edtAccount: TEdit;
    Label2: TLabel;
    cbMarketFilter: TComboBox;
    sttOrder: TStaticText;
    sttFill: TStaticText;
    mPop: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    sttCode: TStaticText;
    sttDiv: TStaticText;
    sttState: TStaticText;
    sttAcptTime: TStaticText;
    sttNo: TStaticText;
    sttOrgNo: TStaticText;
    btnState: TButton;
    cbCancel: TCheckBox;
    StaticText1: TStaticText;
    cbRealAcnt: TCheckBox;
    procedure N1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure cbAccountChange(Sender: TObject);
    procedure cbMarketFilterChange(Sender: TObject);
    procedure btnStateMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure mPopPopup(Sender: TObject);
    procedure cbCancelClick(Sender: TObject);
    procedure sgListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbRealAcntClick(Sender: TObject);
  private
    { Private declarations }
    FAccount  : TAccount;
    FInvest  : TInvestor;
    FMarketIndex  : integer;
    FStates : TOrderStates;
    FPopup  : boolean;
    FShowCn : boolean;
    FSelectRow : integer;

    procedure initControls;
    procedure init;
    procedure UpdateData;
    procedure Clear;
    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID);
    procedure RecoveryOrder( aOrder : TOrder );
    procedure AddOrder(aOrder: TOrder);
    procedure UpdateOrder(aOrder: TOrder; EventID: TDistributorID);
    procedure DeleteOrder(aOrder: TOrder);
    procedure RefreshData(aOrder: TOrder);
    procedure UpdateCellData(var ACol, ARow: integer; stValue: string);
    procedure OnAccount(aInvest: TInvestor; EventID: TDistributorID);
  public
    { Public declarations }
    Fillter : TFillter;
    procedure OrderEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure Reload;
    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
  end;

var
  FrmOrderList2: TFrmOrderList2;

implementation

uses GAppEnv, GleLib;


{$R *.dfm}





procedure TFrmOrderList2.btnStateMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt, pm : TPoint;
begin   {
  if  then
  begin
    FPopup := false;
    Exit;
  end;
   }

  pm.X :=btnState.Left ; pm.Y := btnState.Top + btnState.Height;
  pt := ClientToScreen( pm );
  mPop.Popup( pt.X, pt.Y);
end;

procedure TFrmOrderList2.cbAccountChange(Sender: TObject);
var
  aAcnt : TAccount;
  aInvest : TInvestor;
begin
  if cbRealAcnt.Checked then
  begin
    aInvest := TInvestor( cbAccount.Items.Objects[ cbAccount.ItemIndex ]);
    if FInvest <> aInvest then
    begin
      FInvest := aInvest;
      edtAccount.Text := FInvest.Name;
      UpdateData;
    end;
  end else
  begin
    aAcnt := TAccount( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
    if aAcnt = nil then Exit;
    if FAccount <> aAcnt then
    begin
      FAccount := aAcnt;
      edtAccount.Text := FAccount.Name;
      UpdateData;
    end;
  end;
end;

procedure TFrmOrderList2.cbMarketFilterChange(Sender: TObject);
var
  iIndex : integer;
begin
  iIndex  := cbMarketFilter.ItemIndex;
  if iIndex <> FMarketIndex then
  begin
    FMarketIndex := iIndex;
    UpdateData;
  end;
end;


procedure TFrmOrderList2.cbRealAcntClick(Sender: TObject);
begin
  cbAccount.Items.Clear;

  if cbRealAcnt.Checked then
    gEnv.Engine.TradeCore.Investors.GetList2( cbAccount.Items)
  else
    gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items );

  FInvest   := nil;
  FAccount  := nil;

  if cbAccount.Items.Count > 0 then
  begin
    ComboBox_AutoWidth(  cbAccount );
    cbAccount.ItemIndex := 0;
    cbAccountChange( nil );
  end;
end;

procedure TFrmOrderList2.cbCancelClick(Sender: TObject);
begin
  FShowCn := cbCancel.Checked;
end;

procedure TFrmOrderList2.Clear;
var
  i : integer;
begin
  with sgList do
  begin
    for i := 2 to RowCount - 1 do
      Rows[i].Clear;
    RowCount := 3;
    FixedRows  := 2;
  end;
end;

procedure TFrmOrderList2.FormCreate(Sender: TObject);
begin
  //
  init;
  initControls;
  FSelectRow  := -1;
  //
  gEnv.Engine.TradeBroker.Subscribe( Self, OrderEventHandler );

  if gEnv.UserType = utStaff then
    cbRealAcnt.Visible := true;
end;

procedure TFrmOrderList2.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  Fillter.Free;
end;

procedure TFrmOrderList2.init;
begin
  Fillter := TFillter.Create
  //Fillter.set
end;

procedure TFrmOrderList2.initControls;
var
  i : integer;
begin
  With sgList do
  begin
    Cells[ 2, 1] := '가 격';
    Cells[ 3, 1] := '수 량';
    Cells[ 4, 1] := '미체결';

    Cells[ 5, 1] := '수 량';
    Cells[ 6, 1] := '평균단가';
  end;

  for i := 0 to High( MarketType ) do
    cbMarketFilter.AddItem( MarketType[i], nil);
  gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items );

  FStates := [osActive, osFilled];

  // default 선옵
  if cbMarketFilter.Items.Count > 0 then
  begin
    cbMarketFilter.ItemIndex  := 1;
    cbMarketFilterChange( nil );

  end;

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex  := 0;
    cbAccountChange( nil );
    ComboBox_AutoWidth(  cbAccount );
  end;

  FPopup  := false;
  FShowCn := false;

  if gEnv.Beta then
    cbRealAcnt.Visible := false;

end;

procedure TFrmOrderList2.LoadEnv(aStorage: TStorage);
begin
  Exit;
  if aStorage = nil then Exit;

  if aStorage.FieldByName('osActive').AsString = 'osActive' then
    N1.Checked := true
  else
    N1.Checked := false;



  if aStorage.FieldByName('osFill').AsString = 'osFill' then
    N2.Checked := true
  else
    N2.Checked := false;



  if aStorage.FieldByName('osChange').AsString = 'osChange' then
    N3.Checked := true
  else
    N3.Checked := false;


  if aStorage.FieldByName('osCancel').AsString = 'osCancel' then
    N4.Checked := true
  else
    N4.Checked := false;


end;

procedure TFrmOrderList2.mPopPopup(Sender: TObject);
begin
  FPopup := true;
end;

procedure TFrmOrderList2.RecoveryOrder(aOrder: TOrder);
begin
  AddOrder( aOrder );
  if aOrder.State in [ osCanceled, osConfirmed] then
    UpdateOrder( aOrder, ORDER_CONFIRMED );
end;

procedure TFrmOrderList2.RefreshData(aOrder: TOrder);
begin

end;

procedure TFrmOrderList2.Reload;
begin
  //
end;

procedure TFrmOrderList2.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if N1.Checked then
    aStorage.FieldByName('osActive').AsString := 'osActive';

  if N2.Checked then
    aStorage.FieldByName('osFill').AsString := 'osFill';

  if N3.Checked then
    aStorage.FieldByName('osChange').AsString := 'osChange';

  if N4.Checked then
    aStorage.FieldByName('osCancel').AsString := 'osCancel';
end;



procedure TFrmOrderList2.N1Click(Sender: TObject);
var
  iTag : integer;
  aType: TOrderState;
  bCheck : boolean;
  stLog : string;
begin
  //
  iTag := TMenuItem( Sender ).Tag;
  bCheck  := not TMenuItem( Sender ).Checked;

  case iTag of
    0 :
      begin
        if bCheck then
          FStates := FStates + [ osActive ]
        else
          FStates := FStates - [ osActive ];
      end;
    1 :
      begin
        if bCheck then
          FStates := FStates + [ osFilled ]
        else
          FStates := FStates - [ osFilled ];
      end;
    2 :
      begin
        if bCheck then
          FStates := FStates + [ osConfirmed, osCanceled ]
        else
          FStates := FStates - [ osConfirmed, osCanceled ] ;
      end;
    3 :
      begin
        if bCheck then
          FStates := FStates + [ osRejected, osFailed ]
        else
          FStates := FStates - [ osRejected, osFailed ];
      end;
  end;

  TMenuItem( Sender ).Checked := bCheck;

  UpdateData;

end;


procedure TFrmOrderList2.OrderEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CHANGED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
    ACCOUNT_NEW     ,
    ACCOUNT_DELETED ,
    ACCOUNT_UPDATED : OnAccount( DataObj as Tinvestor, EventID );
    else
      Exit;
  end;
end;

procedure TFrmOrderList2.OnAccount(aInvest: TInvestor;
  EventID: TDistributorID);
begin
  cbAccount.Items.Clear;
  gEnv.Engine.TradeCore.Accounts.GetList3( cbAccount.Items );

  case integer( EventID ) of

    ACCOUNT_NEW , ACCOUNT_UPDATED  :
      begin
        if FAccount <> nil then
          SetComboIndex( cbAccount, FAccount )
        else
          if cbAccount.Items.Count > 0 then
          begin
            cbAccount.ItemIndex  := 0;
            cbAccountChange( nil );
          end;
      end;
    ACCOUNT_DELETED :
      if cbAccount.Items.Count > 0 then
      begin
        cbAccount.ItemIndex  := 0;
        cbAccountChange( nil );
      end
  end;
end;



procedure TFrmOrderList2.UpdateData;
var
  i, j : integer;
  aOrder : TOrder;
  bRes : boolean;
  aType : TOrderListType;
begin

  if cbRealAcnt.Checked then
  begin
    if ( FInvest = nil ) or ( FMarketIndex < 0 ) then Exit;
    Fillter.SetFillterData( '전체', FMarketIndex, FStates);
    Clear;

    for i := 0 to gEnv.Engine.TradeCore.Orders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.Orders[i];
      if aOrder.Account.InvestCode = FInvest.Code then
        bRes := Fillter.Fillter( aOrder )
      else
        bRes := false;

      if bRes then
      begin
        RecoveryOrder( aOrder );
      end;
    end;

  end else
  begin
    if (FAccount = nil) or (FMarketIndex < 0) then
      Exit;
    Fillter.SetFillterData( FAccount.Code, FMarketIndex, FStates);
    Clear;

    for i := 0 to gEnv.Engine.TradeCore.Orders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.Orders[i];
      bRes := Fillter.Fillter( aOrder ) ;
      if bRes then
      begin
        RecoveryOrder( aOrder );
      end;
    end;
  end;

end;


procedure TFrmOrderList2.DoOrder(aOrder: TOrder; EventID: TDistributorID);
var
  bRes  : Boolean;
  aType : TOrderListType;
  stTest : string;
begin
  if aOrder = nil then Exit;
  bRes := Fillter.Fillter( aOrder );

  if (gEnv.UserType = utStaff) and (cbRealAcnt.Checked ) and ( FInvest <> nil ) then
    if aOrder.Account.InvestCode <> FInvest.Code then bRes := false;

  if not bRes  then
    aType := olDelete
  else begin
    if (aOrder.State = osActive) and
       (Integer(EventID) in [ORDER_ACCEPTED, ORDER_CHANGED ]) then
    begin
      aType := olAdd;
      if not FShowCn then
        if aOrder.OrderType = otCancel then
          Exit;
    end
    else begin
      aType := olUpdate;
      if aOrder.State <> osFilled then
      begin
        //if (not N3.Checked) and ( aOrder.OrderType = otChange ) then
        //  aType := olDelete;
        //if (not N4.Checked) and ( aOrder.OrderType = otCancel) then
        //  aType := olDelete;
      end;
    end;
  end;

  case aType of
    olAdd: AddOrder( aOrder );
    olDelete: DeleteOrder( aOrder );
    olUpdate: UpdateOrder( aOrder, EventID );
  end;
end;

procedure TFrmOrderList2.AddOrder(aOrder: TOrder);
var
  iRow , iCol : integer;
  stLog, stNo, stTmp : string;
  aPosition : TPosition;
  stAvgPrice : string;
begin
  InsertLine( sgList, InsertRow );
  iCol  := OrderIndex;
  iRow  := InsertRow;

  sgList.Objects[ OrderIndex, iRow ] := aOrder;
  //
  UpdateCellData(iCol, iRow, aOrder.Symbol.ShortCode );
  UpdateCellData(iCol, iRow, aOrder.GetOrderName );
  UpdateCellData(iCol, iRow,
                Format( '%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]));
  UpdateCellData(iCol, iRow, IntToStr( aOrder.OrderQty ));
  UpdateCellData(iCol, iRow, IntToStr( aOrder.ActiveQty ));

  stAvgPrice  := Format('%.*n', [aOrder.Symbol.Spec.Precision, aOrder.AvgPrice ]);

  UpdateCellData(iCol, iRow, IntToStr( aOrder.FilledQty ));
  UpdateCellData(iCol, iRow, stAvgPrice);

  UpdateCellData(iCol, iRow, StateName[ aOrder.State ]);
  UpdateCellData(iCol, iRow, FormatDateTime( 'hh:nn:ss.zzz', aOrder.AcptTime ));
  UpdateCellData(iCol, iRow, IntToStr( aOrder.OrderNo ));

  if aOrder.Target = nil then
    stNo := '0'
  else
    stNo := IntToStr( aOrder.Target.OrderNo );
  UpdateCellData(iCol, iRow, stNo );

  UpdateCellData(iCol, iRow, aOrder.GetOrderSpecies );
  {
  stTmp := StateName[ aOrder.State ];
  if aOrder.State = osConfirmed then
  begin
    if aOrder.OrderType = otChange then
      stTmp := '정정확인'
    else if aOrder.OrderType = otCancel then
      stTmp := '취소확인';
  end;

  stLog := Format( 'add %d : %s, %s, %s, %d ', [   aOrder.OrderNo ,  stTmp,
    ifthenStr( aOrder.OrderType = otNormal, '신규',
      ifThenStr( aOrder.OrderType = otChange, '정정', '취소')),
    '0', iRow]);
  gEnv.OnLog( self, stLog );
  }
end;


procedure TFrmOrderList2.DeleteOrder(aOrder: TOrder);
var
  iRow : integer;
  stLog : string;
begin
  iRow := sgList.Cols[OrderIndex].IndexOfObject( aOrder );
  if iRow < 0 then
    Exit;
  DeleteLine( sgList, iRow );
  {
  stLog := Format( 'del %d : %s, %s, %s, %d ', [   aOrder.OrderNo ,  StateName[ aOrder.State ],
    ifthenStr( aOrder.OrderType = otNormal, '신규',
      ifThenStr( aOrder.OrderType = otChange, '정정', '취소')),
    '0', iRow]);
  gEnv.OnLog( self, stLog );
  }
end;

procedure TFrmOrderList2.UpdateOrder(aOrder: TOrder;  EventID: TDistributorID);
var
  iRow : integer;
  aPosition : TPosition;
  stLog, stAvgPrice, stNo, stTmp: string;
  oOrder : TOrder;
  dPrice : double;
begin

  iRow := sgList.Cols[OrderIndex].IndexOfObject( aOrder );
  if iRow < 0 then
  begin
    // 취소 주문 체크..
    if not FShowCn then
    begin
      if (aOrder.OrderType = otCancel) and ( aOrder.State = osConfirmed ) then
      begin
        AddOrder( aOrder );
        iRow := InsertRow;
      end
      else Exit;
    end
    else Exit;
  end;
  {
  aPosition := gEnv.Engine.TradeCore.Positions.Find( aOrder.Account, aOrder.Symbol );
  if aPosition <> nil then
    stAvgPrice  := Format( '%.*n', [ aOrder.Symbol.Spec.Precision, aPosition.AvgPrice])
  else
    stAvgPrice  := '';
  }
  with sgList do
    case integer( EVentID) of
      ORDER_CHANGED :
        begin
            Cells[ 2, iRow] := Format( '%.*n', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);
            Cells[ OrderName, iRow] := aOrder.GetOrderName;
            Cells[ UnFillQty, iRow] := IntToStr( aOrder.ActiveQty );
            Cells[ FillQty,   iRow] := IntToStr( aOrder.ConfirmedQty );
            Cells[ AvgPrice,  iRow] := '';//stAvgPrice;
            Cells[ FilterName,iRow] := '증전접수';
            Cells[ FilterName +2, iRow] := IntToStr( aOrder.OrderNo );
            stNo := '0';
            if aOrder.Target <> nil then
              stNo := IntTostr( aOrder.Target.OrderNo );
            Cells[ FilterName +3, iRow] := stNo;
        end;
      ORDER_REJECTED ,
      ORDER_CONFIRMFAILED ,
      ORDER_CONFIRMED :
        begin
          //if aOrder.OrderType = otCancel then
          if aOrder.Target <> nil then
            dPrice := aOrder.Target.Price
          else
            dPrice := aOrder.Price;
          Cells[ 2, iRow] := Format( '%.*n', [ aOrder.Symbol.Spec.Precision, dPrice ]);

          Cells[ OrderName, iRow] := aOrder.GetOrderName;
          Cells[ UnFillQty, iRow] := IntToStr( aOrder.ActiveQty );
          Cells[ FillQty,   iRow] := IntToStr( aOrder.ConfirmedQty );
          Cells[ AvgPrice,  iRow] := '';//stAvgPrice;
          Cells[ FilterName,iRow] := StateName[ aOrder.State ];//'죽은주문';//ifThenStr( aOrder.OrderType = otCancel, '취소확인', '정정확인');
          Cells[ FilterName +2, iRow] := IntToStr( aOrder.OrderNo );

          stNo := '0';
          if aOrder.Target <> nil then
            stNo := IntTostr( aOrder.Target.OrderNo );
          Cells[ FilterName +3, iRow] := stNo;
        end;
        // ORDER_CONFIRMED
      ORDER_CANCELED  :
        begin
          if aOrder.State = osFilled then
          begin
            oOrder := TOrder( Objects[ OrderIndex, iRow] );
            Cells[ OrderName, iRow] := aOrder.GetOrderName;
            Cells[ UnFillQty, iRow] := IntToStr( aOrder.ActiveQty );
            Cells[ FillQty,   iRow] := IntToStr( aOrder.FilledQty );
            Cells[ AvgPrice,  iRow] := Format('%.*n', [aOrder.Symbol.Spec.Precision, aOrder.AvgPrice ]);
            Cells[ FilterName,iRow] := StateName[ aOrder.State ];//'전량체결';//ifThenStr( oOrder.OrderType = otChange, '정정확인', '취소확인');
          end
          else if aOrder.State = osActive then begin
            oOrder := TOrder( Objects[ OrderIndex, iRow] );
            Cells[ OrderName, iRow] := aOrder.GetOrderName;
            Cells[ UnFillQty, iRow] := IntToStr( aOrder.ActiveQty );
            Cells[ FillQty,   iRow] := IntToStr( aOrder.FilledQty + aOrder.ConfirmedQty + aOrder.CanceledQty);
            Cells[ AvgPrice,  iRow] := '';//stAvgPrice;
            Cells[ FilterName,iRow] := StateName[ aOrder.State ];
          end
          else begin
            oOrder := TOrder( Objects[ OrderIndex, iRow] );
            Cells[ OrderName, iRow] := aOrder.GetOrderName;
            Cells[ UnFillQty, iRow] := IntToStr( aOrder.ActiveQty );
            Cells[ FillQty,   iRow] := IntToStr( aOrder.CanceledQty );
            Cells[ AvgPrice,  iRow] := '';//stAvgPrice;
            Cells[ FilterName,iRow] := StateName[ aOrder.State ];//'죽은주문';//ifThenStr( oOrder.OrderType = otCancel, '취소확인', '정정확인' );
          end;

        end;
        // ORDER_CANCELED
      ORDER_FILLED    :
        begin
          stAvgPrice  := Format('%.*n', [aOrder.Symbol.Spec.Precision, aOrder.AvgPrice ]);
          Cells[ UnFillQty, iRow] := IntToStr( aOrder.ActiveQty );
          Cells[ FillQty,   iRow] := IntToStr( aOrder.FilledQty );
          Cells[ AvgPrice,  iRow] := stAvgPrice;
            case aOrder.State of
            osFilled :
              begin
                Cells[ FilterName,iRow] := '전량체결';
              end;
            // 부분 체결
            osActive :
              begin
                Cells[ FilterName,iRow] := '부분체결';
              end;
            else
              Exit;
          end;

        end;
        // ORDER_FILLED
    end;
  {
  stTmp := StateName[ aOrder.State ];
  if aOrder.State = osActive then
    stTmp := '부분체결';

  if aOrder.State = osConfirmed then
  begin
    if aOrder.OrderType = otChange then
      stTmp := '정정확인'
    else if aOrder.OrderType = otCancel then
      stTmp := '취소확인';
  end;

  stLog := Format( 'Upd %d : %s, %s, %s, %d ', [   aOrder.OrderNo ,  stTmp,
    ifthenStr( aOrder.OrderType = otNormal, '신규',
      ifThenStr( aOrder.OrderType = otChange, '정정', '취소')),
    stNo, iRow]);
  gEnv.OnLog( self, stLog );
  }
end;

procedure TFrmOrderList2.UpdateCellData( var ACol, ARow : integer; stValue : string );
begin
  sgList.Cells[ ACol, ARow ] := stValue;
  inc( ACol );
end;


procedure TFrmOrderList2.sgListDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aFont, aBack : TColor;
    stTxt : string;
    dFormat : Word;
    aOrder : TOrder;
begin

  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_RIGHT;

  with sgList do
  begin

    stTxt := Cells[ ACol, ARow];

    if ARow < 2 then
    begin
      aBack   := clBtnFace;
      dFormat := DT_VCENTER or DT_CENTER;
    end
    else begin
      aOrder  := TOrder( Objects[ OrderIndex, ARow ] );

      if aOrder <> nil then
        case ACol of
         0, 11 : dFormat := DT_VCENTER or DT_CENTER;
         OrderName :
           begin
             dFormat := DT_VCENTER or DT_CENTER;
             case aOrder.Side of
               1 : aFont := clRed;
               -1: aFont := clBlue;
             end;
           end;
           // 주문종류
         FilterName :
           begin
             dFormat := DT_VCENTER or DT_CENTER;
             if aOrder.ActiveQty > 0 then
             begin
               case aOrder.Side of
                 1 : aBack := clRed;
                 -1: aBack := clBlue;
               end;
               aFont := clWhite;
             end;

           end;
         FilterName+1 :dFormat := DT_VCENTER or DT_CENTER;
        end;
    end;

    if ARow = FSelectRow then
    begin
      aBack := $00F2BEB9;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;


end;


procedure TFrmOrderList2.sgListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    ARow, ACol : integer;
begin
  ARow := FSelectRow;
  sgList.MouseToCell( X, Y, ACol, FSelectRow);
  sgList.Repaint;
  {
  if (ARow <> FSelectRow) and ((ARow > 1 ) and ( ARow < sgList.RowCount-1 )) then
    InvalidateRow( sgList, ARow );
  if (FSelectRow <> FSelectRow) and ((FSelectRow > 1 ) and ( FSelectRow < sgList.RowCount-1 )) then
    InvalidateRow( sgList, FSelectRow );
    }

end;

end.
