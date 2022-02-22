unit FArbPLMonitor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls,

  UARStuffs, CleSymbols, ClePositions, CleAccounts, CleQuotebroker, CleDistributor ,

  CleFills  , GleConsts , CleORders, CleStorage
  ;

const
  SetColCnt = 9;
  DetailColCnt = 11;
  SetTitle : array [0..SetColCnt-1] of string =
    ('구분','LS','일자','그룹','옵션수량','확정손익','평가손익','처리구분',' ');
  SetWidth : array [0..SetColCnt-1] of integer = (45 , 30 , 80, 50, 65, 65, 65, 65 , 30);
  DetailTitle : array [0..DetailColCnt-1] of string =
    ('일자','체결시각','종목코드','LS','체결수량','체결가','청산수량','청산가','현재가','평가손익','확정손익');
  DetailWidth : array [0..DetailColCnt-1] of integer = (90,60,60, 30, 65, 50, 65, 50, 50, 60, 60 );

  SetCol   = 0;
  OrderCol = 1;
  ExpandCol= 2;

  UnitCol  = 0;

type
  TFrmArbPLMonitor = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    lblFixedPL: TLabel;
    lblOpenPL: TLabel;
    lblTotGroup: TLabel;
    lblWinRate: TLabel;
    Button1: TButton;
    sgSet: TStringGrid;
    sgDetail: TStringGrid;
    Splitter1: TSplitter;
    cbAccount: TComboBox;
    lbAcntName: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgSetDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgSetMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure sgSetSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbAccountChange(Sender: TObject);
  private
    FAccount     : TAccount;
    FSelectedRow : integer;
    FSelectedCell: integer;
    FNoSound     : boolean;
    procedure initControls;
    procedure DoFill(oFill : TFill );
    function FindOrderSet(iGroupID: integer; var iRow : integer): TOrderSet;
    procedure UpdateDetail;
    procedure UpdateSet;
    procedure QueryDetailPLFromMemory(oSet: TOrderSet);
    procedure ClearDetail;
    procedure DrawDetail(aCanvas: TCanvas; ACol, ARow: integer);
    procedure DrawSet(aCanvas: TCanvas; ACol, ARow: integer);
    procedure GetOrderFill;
    procedure ClearSet;
    { Private declarations }
  public
    { Public declarations }

    procedure FillProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

  end;

var
  FrmArbPLMonitor: TFrmArbPLMonitor;

implementation

uses
  GAppEnv , GleLib
  ;

{$R *.dfm}



procedure TFrmArbPLMonitor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmArbPLMonitor.FormCreate(Sender: TObject);
begin
  initControls;

  gEnv.Engine.TradeBroker.Subscribe( Self, FillProc );

  FNoSound := true;
  FNoSound := false;

  gEnv.Engine.TradeCore.Accounts.GetList3( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex  := 0;
    cbAccountChange( nil );
  end;
end;

procedure TFrmArbPLMonitor.FormDestroy(Sender: TObject);
begin
  //
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;


procedure TFrmArbPLMonitor.initControls;
var
  I: Integer;
begin

  sgSet.ColCount := SetColCnt;
  for I := 0 to SetColCnt - 1 do
  begin
    sgSet.Cells[i,0]  := SetTitle[i];
    sgSet.ColWidths[i]:= SetWidth[i];
  end;

  sgDetail.ColCount := DetailColCnt;
  for I := 0 to DetailColCnt - 1 do
  begin
    sgDetail.Cells[i,0]   := DetailTitle[i];
    sgDetail.ColWidths[i] := DetailWidth[i];
  end;

  FSelectedRow  := -1;
  FSelectedCell := -1;

end;


procedure TFrmArbPLMonitor.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then
    Exit;

end;

procedure TFrmArbPLMonitor.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then
    Exit;
end;

procedure TFrmArbPLMonitor.sgSetDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    clFont , clBack : TColor;
    stTxt : string;
    dFormat : Word;
    aRect : TRect;
begin
  //
  clBack := clWhite;
  clFont := clBlack;
  dFormat := DT_VCENTER or DT_RIGHT;
  with TStringGrid( Sender ) do
  begin

    aRect := Rect;
    aRect.Top   := aRect.Top + 1;

    stTxt := Cells[ACol, ARow];

    if ARow = 0 then
    begin
      clBack := clBtnFace;
      dFormat := DT_VCENTER or DT_CENTER;
    end
    else begin

      if TStringGrid( Sender ).Tag = 0 then begin
        DrawSet( Canvas, ACol, ARow ) ;
        if ARow = FSelectedRow then
          clBack := clGray;
      end
      else
        DrawDetail( Canvas, ACol, ARow );

      aRect.Right := aRect.Right -1;
    end;

    Canvas.Font.Color   := clFont;
    Canvas.Brush.Color  := clBack;

    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

  end;
end;

procedure TFrmArbPLMonitor.DrawSet( aCanvas : TCanvas; ACol, ARow : integer );
begin

end;

procedure TFrmArbPLMonitor.DrawDetail( aCanvas : TCanvas; ACol, ARow : integer );
begin

end;

procedure TFrmArbPLMonitor.Button1Click(Sender: TObject);
begin
  UpdateDetail;
  UpdateSet;
end;

procedure TFrmArbPLMonitor.cbAccountChange(Sender: TObject);
var
  aAcnt : TAccount;
begin
  aAcnt := TAccount( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
  if aAcnt = nil then Exit;
  if FAccount <> aAcnt then
  begin
    FAccount := aAcnt;
    lbAcntName.Caption := FAccount.Name;
    ClearSet;
    ClearDetail;
    GetOrderFill;
  end;
end;

procedure TFrmArbPLMonitor.ClearSet;
var
  I: Integer;
begin
  for I := 1 to sgSet.RowCount - 1 do
    sgSet.Rows[i].Clear;
  sgSet.RowCount := 1;
end;

procedure TFrmArbPLMonitor.GetOrderFill;
var
  I,j : Integer;
  aPos : TPosition;
  aFill : TFill;
begin
  FNoSound := true;
  for I := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
  begin
    aPos := gEnv.Engine.TradeCore.Positions.Positions[i];
    if aPos.Account = FAccount then
    begin
      for j := 0 to aPos.Fills.Count - 1 do
      begin
     // 임시로 주석 2013 04 17
     //   aFill := aPos.Fills.Fills[j];
     //   if aFill.Order.GroupID > 0 then
      //    DoFill( aFill );
      end;
    end;
  end;
  FNoSound := false;
end;

procedure TFrmArbPLMonitor.ClearDetail;
var
  I: Integer;
begin
  for I := 1 to sgDetail.RowCount - 1 do
    sgDetail.Rows[i].Clear;
  sgDetail.RowCount := 1;
end;

procedure TFrmArbPLMonitor.QueryDetailPLFromMemory( oSet : TOrderSet ) ;
var i, j: Integer;
begin
  ClearDetail;
  if oSet = nil then exit;
  for i:=0 to oSet.m_lstUnit.Count-1 do
  begin
    InsertLine( sgDetail , 1 );
    sgDetail.Objects[UnitCol, 1] :=oSet.m_lstUnit.Items[i];
  end;
  UpdateDetail;
end;



procedure TFrmArbPLMonitor.sgSetMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    aRow, aCol : integer;
begin
  aRow :=  FSelectedRow ;
  sgSet.MouseToCell( X, Y, aCol, FSelectedRow);
  InvalidateRow( sgSet, aRow );
  InvalidateRow( sgSet, FSelectedRow );

  if (FSelectedRow > 0) and (sgSet.Objects[SetCol, FSelectedRow] <> nil) then
    QueryDetailPLFromMemory( TOrderSet( sgSet.Objects[SetCol, FSelectedRow] ) )
end;

procedure TFrmArbPLMonitor.sgSetSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
  var
    tmp : integer;
begin
  tmp := FSelectedRow;

  if ( ARow = FSelectedRow ) then exit;

  FSelectedRow := ARow;
  InvalidateRow( sgSet, tmp );
  InvalidateRow( sgSet, FSelectedRow );

  if (FSelectedRow > 0) and (sgSet.Objects[SetCol, FSelectedRow] <> nil) then
    QueryDetailPLFromMemory( TOrderSet( sgSet.Objects[SetCol, FSelectedRow] ) )
end;

procedure TFrmArbPLMonitor.FillProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    FILL_NEW: DoFill(DataObj as TFill);
  end;
end;


procedure TFrmArbPLMonitor.DoFill( oFill : TFill );
var
  i, iFindRow: Integer;   stDebug: string;
  oSet: TOrderSet;   oNew, oOld: TOrderUnit;
  stLS: string;
  bNew: boolean;
begin               {
  if (FAccount <> oFill.Account) then Exit;
  if oFill.Order.GroupID = 0 then exit;

  bNew := false;
  iFindRow := -1;
  oSet := FindOrderSet( oFill.Order.GroupID , iFindRow );


  if oSet = nil then
  begin
    oSet := TOrderSet.Create;
    oSet.m_tDate := oFill.FillTime;
    oSet.m_iGID  := oFill.Order.GroupID ;
    oSet.m_stDiv := oFill.Order.StgName;

    oSet.CalcFixedPL;
    oSet.CalcOpenPL;

    InsertLine( sgSet, 1 );
    sgSet.Objects[ SetCol, 1 ]  := oSet;

    if sgSet.RowCount = 2 then
      FSelectedRow  := 1;

    if (not FNoSound ) then
      FillSoundPlay( 'fill.wav');

    if (sgSet.FixedRows < 1) and (sgSet.RowCount > 1)  then
      sgSet.FixedRows := 1;

    iFindRow := 1;

    if iFindRow = FSelectedRow then
      ClearDetail;
  end;

  oOld  := oSet.FindUnit( oFill.Symbol.ShortCode );
  stLS  := ifThenStr( oFill.Volume > 0 , 'L', 'S' );
  if( oOld <> nil ) and ( oOld.m_stLS <> stLS ) then
  begin
    // 평균단가 계산( 이동평균법 )

    oOld.m_fClearPrice := utRound2(((oOld.m_fClearPrice*oOld.m_iClearQty)+
      (oFill.Price * abs(oFill.Volume))) / ( oOld.m_iClearQty+abs(oFill.Volume) ));
      //(oFill.m_dPrice1*oFill.m_iQty)) / (oOld.m_iClearQty+oFill.m_iQty));
    oOld.m_iClearQty := oOld.m_iClearQty + abs(oFill.Volume);// oFill.m_iQty;
    oOld.m_fClearAmt := oOld.m_fClearAmt + (abs(oFill.Volume) * oFill.Price);// ( oFill.m_iQty * oFill.m_dPrice1 );
  end
  // LS방향이 같은 종목의 유닛 이미있다면.. 지금유닛은 잔고증가이다
  else if (oOld<>nil) and (oOld.m_stLS = stLS) then
  begin
    // 평균단가계산(이동평균법)
    oOld.m_fNewPrice := utRound2(((oOld.m_fNewPrice*oOld.m_iNewQty)+
      (oFill.Price*abs(oFill.Volume))) / (oOld.m_iNewQty+abs(oFill.Volume)));
    oOld.m_iNewQty := oOld.m_iNewQty + abs(oFill.Volume);
    oOld.m_fNewAmt := oOld.m_fNewAmt + ( abs(oFill.Volume) * oFill.Price );
  end;
  oSet.ProcessState;
  if oOld <> nil then begin
    UpdateDetail;
    UpdateSet;
    exit;
  end;

  oNew := TOrderUnit.Create;
  oNew.m_iGID := oSet.m_iGID;
  oNew.m_tDate := oFill.FillTime;
  oNew.m_oPrdt := oFill.Symbol;
  oNew.m_stCode := oFill.Symbol.ShortCode;
  oNew.m_stLS := stLS;
  oNew.m_iNewQty := abs(oFill.Volume);
  oNew.m_fNewPrice := utRound2(oFill.Price);
  oNew.m_fNewAmt := abs(oFill.Volume) * oFill.Price;
  oNew.m_fCurrent := oNew.m_oPrdt.Last;
  oSet.MakePLInfra( oNew );
  oSet.m_lstUnit.Add( oNew );
  oSet.ProcessState;
  UpdateSet;

  //
  if FSelectedRow < 1 then exit;

  if (iFindRow = FSelectedRow)  then
  begin
    InsertLine( sgDetail, 1 );
    sgDetail.Objects[ UnitCol, 1 ]  := oNew;
    UpdateDetail;
  end;     }
end;

function TFrmArbPLMonitor.FindOrderSet( iGroupID : integer; var iRow : integer ) : TOrderSet;
var
  I: Integer; oSet : TOrderSet;
begin
  result := nil;

  for I := 1 to sgSet.RowCount - 1 do
  begin
    oSet  := TOrderSet( sgSet.Objects[ SetCol, i] );
    if oSet = nil then Continue;

    if oSet.m_iGID = iGroupID then
    begin
      Result := oSet;
      iRow   := i;
      break;
    end;
  end;
end;


procedure TFrmArbPLMonitor.UpdateDetail;
var iCol,i: Integer; oUnit: TOrderUnit;
begin
  with sgDetail do

  for i := 1 to RowCount - 1 do
  begin
    oUnit := TOrderUnit( Objects[UnitCol, i] );
    if oUnit = nil then Continue;

    iCol := 0;

    Cells[ iCol,i] := FormatDateTime('yyyy-mm-dd', oUnit.m_tDate );  inc(iCol);
    Cells[ iCol,i] := FormatDateTime( 'hh:nn:ss', oUnit.m_tDate );   inc(iCol);
    Cells[ iCol,i] := oUnit.m_stCode;    inc(iCol);
    Cells[ iCol,i] := oUnit.m_stLS;     inc(iCol);
    Cells[ iCol,i] := IntToStr( oUnit.m_iNewQty );    inc(iCol);
    Cells[ iCol,i] := Format( '%.2f', [ oUnit.m_fNewPrice ] );    inc(iCol);
    Cells[ iCol,i] := IntToStr( oUnit.m_iClearQty );     inc(iCol);
    Cells[ iCol,i] := Format( '%.2f', [ oUnit.m_fClearPrice] );    inc(iCol);
    if oUnit.m_oPrdt <> nil then
      Cells[ iCol,i] := Format( '%.2f', [oUnit.m_oPrdt.Last] );
    inc(iCol);
    Cells[ iCol,i] := Format( '%.0f', [ oUnit.m_dOpenPL ] );      inc(iCol);
    Cells[ iCol,i] := Format( '%.0f', [ oUnit.m_dFixedPL ] );      inc(iCol);

  end;

  if sgDetail.RowCount > 1 then
    sgDetail.FixedRows := 1;

end;


procedure TFrmArbPLMonitor.UpdateSet;
var i, iCol: Integer;  oSet: TOrderSet;
    dTotFixedPL, dTotOpenPL, dTmp: double; iWin, iWinRate: Integer; stLS: string;
begin
  dTotFixedPL := 0.0; dTotOpenPL := 0.0;
  iWin := 0;
  with sgSet do
    for i:=1 to RowCount-1 do
    begin
      iCol := 0;
      oSet := TOrderSet( Objects[SetCol, i]);
      if oSet = nil then Continue;

      //if oSet.m_iGID = 0 then continue;
      Cells[iCol, i] := oSet.m_stDiv;          inc(iCol);
      if oSet.isCON then
        stLS := 'L'
      else stLS := 'S';
      Cells[iCol, i] := stLS;                  inc(iCol);
      Cells[iCol, i] := FormatDateTime( 'yyyy-mm-dd', oSet.m_tDate );    inc(iCol);
      Cells[iCol, i] := IntToStr(oSet.m_iGID);   inc(iCol);
      Cells[iCol, i] := IntToStr(oSet.m_iQty);   inc(iCol);
      dTmp := oSet.CalcFixedPL;
      Cells[iCol, i] := Format( '%m', [dTmp] );  inc(iCol);
      dTmp :=  oSet.CalcOpenPL;
      Cells[iCol, i] := Format( '%m', [dTmp] );   inc(iCol);
      Cells[iCol, i] := oSet.m_stState;//IntToStr( oSet.m_state );
      inc(iCol);
      dTotFixedPL := dTotFixedPL + oSet.CalcFixedPL;   // 확정손익누적
      dTotOpenPL := dTotOpenPL + oSet.CalcOpenPL;      // 평가손익누적
      if (oSet.m_state = ssSuccess)then
        Inc( iWin );

    end;

  lblFixedPL.Caption := Format( '확정손익: %12m 원', [dTotFixedPl] );
  lblOpenPL.Caption := Format( '평가손익: %12m 원', [dTotOpenPL] );
  lblTotGroup.Caption := Format( '총그룹수: %d', [sgSet.RowCount-1] );

  iWinRate := 0;
  if iWin <> 0 then
    iWinRate := Round(iWin/(sgSet.RowCount-1)*100);
  lblWinRate.Caption := Format( '승률: %d%% ( %d/%d )', [ iWinRate, iWin, sgSet.RowCount-1 ] );
end;
end.
