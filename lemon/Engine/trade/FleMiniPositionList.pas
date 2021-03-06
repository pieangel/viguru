unit FleMiniPositionList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,

  CleAccounts, CleSymbols, ClePositions, CleQuotebroker, CleDistributor,

  CleStorage, Menus
  ;

const
  Title_1 : array [0..3] of string = ('평가손익','실현손익','수수료','순손익');
  Title_2 : array [0..3] of string = ('코드',' ','평균가', '평가' );
  Title_2_1 : array [0..3] of string = ('코드',' ','평가', '총손익' );
  Title_3 : array [0..3] of string = ('계좌',' ','평가', '총손익' );

  Symbol_Col = 0;
  BG_Col     = 1;
  Color_Col  = 2;
  Color_Col2 = 3;

type

  TFrmMiniPosList = class(TForm)
    p1: TPanel;
    cbAccount: TComboBox;
    sgTop: TStringGrid;
    Panel1: TPanel;
    sgBottom: TStringGrid;
    RefreshTimer: TTimer;
    ShowStg: TCheckBox;
    ShowUnit: TCheckBox;
    btnQuery: TButton;
    PopupMenu1: TPopupMenu;
    mTotal: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgTopDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgBottomDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure Show0NetClick(Sender: TObject);
    procedure ShowUnitClick(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure ShowStgClick(Sender: TObject);
    procedure sgBottomDblClick(Sender: TObject);
    procedure sgBottomMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mTotalClick(Sender: TObject);

  private
    { Private declarations }
    FAccount  : TAccount;
    FIndex    : boolean;
    FRow      : integer;

    FUfColWidth  ,    FUfLastGap : integer;
    procedure initControls;
    procedure RefreshPosition;
    procedure RefreshBottom;
    procedure RefreshTop;

    procedure TradePrc( Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure UpdatePosition(aPosition: TPosition; bAdd: boolean);
    procedure UpdateRow(iRow: Integer; aPos: TPosition; bAdd : boolean); overload;
    procedure UpdateRow(iRow: Integer; aAcnt : TAccount); overload;
    procedure Clear(aGrid: TStringGrid);
    procedure OnAccount(aInvest: TInvestor; EventID: TDistributorID);
    procedure ResizeGrid;
    procedure RefreshTitle;
    procedure ChangeTitle;
  public
    { Public declarations }

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
  end;

var
  FrmMiniPosList: TFrmMiniPosList;

implementation

uses
  GAppEnv , GleLib , GleConsts, GleTypes, GAppForms,
  Math
  ;

{$R *.dfm}

procedure TFrmMiniPosList.btnQueryClick(Sender: TObject);
var
  aInvest : TInvestor;
  stLog   : string;
begin
//
  if FAccount = nil then Exit;

  aInvest := gEnv.Engine.TradeCore.Investors.Find( FAccount.InvestCode );
  if aInvest = nil  then Exit;
  if aInvest.PassWord = '' then
  begin
    stLog  := '계좌 비밀번호 미 입력';
    stLog  := stLog + #13+#10+#13+#10;
    stLog  := stLog + '비밀번호 입력화면으로 이동하시겠습니까?';
    if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
    begin
      gEnv.Engine.FormBroker.Open(ID_ACNT_PASSWORD, 0);
      Exit;
    end else
      Exit;
  end;
  gEnv.Engine.SendBroker.RequestAccountPos( aInvest );

end;

procedure TFrmMiniPosList.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount := TAccount( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
  if (aAccount <> nil ) and (FAccount <> aAccount) then
  begin
    FAccount := aAccount;
    FIndex   := FAccount is TInvestor;//  cbAccount.ItemIndex;
    Clear( sgBottom );
    if ( not FIndex ) and ( ShowStg.Checked ) then
      ShowStg.Checked := false;
    ChangeTitle;
    RefreshPosition;
  end;

  //btnQuery.Visible  := FIndex;
end;

procedure TFrmMiniPosList.Clear( aGrid : TStringGrid );
var
  I: Integer;
begin
  for I := 1 to aGrid.RowCount - 1 do
    aGrid.Rows[i].Clear;
  aGrid.RowCount  := 2;
end;

procedure TFrmMiniPosList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmMiniPosList.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  //
  initControls;

  if not gEnv.Beta then
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    cbAccount.AddItem( gEnv.Engine.TradeCore.Investors.Investor[i].Code+' '+gEnv.Engine.TradeCore.Investors.Investor[i].Name,
       gEnv.Engine.TradeCore.Investors.Investor[i] );

  gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items );

  FAccount  := nil;
  FIndex    := false;
  FRow      := -1;

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
    ComboBox_AutoWidth( cbAccount );
  end;

end;

procedure TFrmMiniPosList.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmMiniPosList.initControls;
var
  i : integer;
begin

  if gEnv.UserType = utStaff then
    ShowStg.Visible := true;

  with sgTop do
  begin
    for I := 0 to RowCount - 1 do
      Cells[0, i]  := Title_1[i];

    ColWidths[1]  := Width - DefaultColWidth - 4;

  end;

  with sgBottom do
  begin
    for I := 0 to ColCount - 1 do
      Cells[i,0]  := Title_2[i];
{
    ColWidths[0] := 77;
    ColWidths[1] := 40;
    ColWidths[2] := 70;
 }
    ColWidths[0] := 55;
    ColWidths[1] := 20;
    ColWidths[2] := 50;
    ColWidths[3] := sgBottom.Width - ColWidths[0] - ColWidths[1] -ColWidths[2] - 5;
    FUfColWidth  := ColWidths[3];
    FUfLastGap   := 2;//sgBottom.ClientWidth - sgBottom.ClientWidth ;
  end;


end;

procedure TFrmMiniPosList.LoadEnv(aStorage: TStorage);
var
  aAcnt : TAccount;
  stCode : string;
  aIndex : boolean;
begin
  //
  if aStorage = nil then Exit;

  ShowStg.Checked  := aStorage.FieldByName('ShowStg').AsBooleanDef( false ) ;
  ShowUnit.Checked  := aStorage.FieldByName('ShowUnit').AsBoolean ;

  aIndex:= aStorage.FieldByName('IsInvest').AsBoolean ;
  stCode:= aStorage.FieldByName('Acntcode').AsString;

  if aIndex then
    aAcnt :=  gEnv.Engine.TradeCore.Investors.Find( stCode) as TAccount
  else
    aAcnt :=  gEnv.Engine.TradeCore.Accounts.Find( stCode);

  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount, aAcnt );
    if cbAccount.ItemIndex >= 0 then
      cbAccountChange( nil );
  end;
end;


procedure TFrmMiniPosList.mTotalClick(Sender: TObject);
begin
  mTotal.Checked := not mTotal.Checked;
  Clear( sgBottom );
  ChangeTitle;
  RefreshBottom;
end;

procedure TFrmMiniPosList.ShowStgClick(Sender: TObject);
begin
  case ( Sender as TMenuItem ).Tag of
    0 :
      begin
        RefreshTitle;
        RefreshBottom;
      end;
  end;
end;

procedure TFrmMiniPosList.RefreshTimerTimer(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmMiniPosList.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('ShowStg').AsBoolean  := ShowStg.Checked;
  aStorage.FieldByName('ShowUnit').AsBoolean  := ShowUnit.Checked;

  aStorage.FieldByName('Acntcode').AsString  := FAccount.Code;
  aStorage.FieldByName('IsInvest').AsBoolean := FIndex;
end;

procedure TFrmMiniPosList.sgBottomDblClick(Sender: TObject);
var
  aAcnt : TAccount;
  aSymbol : TSymbol;
  aPos  : TPosition;
  i : integer;
begin
  if ( gEnv.Beta ) or ( gEnv.MainBoard = nil ) then Exit;

  try

    aAcnt := nil;
    aSymbol := nil;

    if ( FIndex ) and ( FAccount <> nil )  then
    begin

      if ( ShowStg.Checked ) then
      begin
          if FRow > 0 then
            aAcnt := TAccount( sgBottom.Objects[Symbol_Col, FRow]);
          // 계좌, 종목 순
          if aAcnt <> nil then
            PostMessage( gEnv.MainBoard.Handle , WM_SELECTPOSITION,
              integer(Pointer(aAcnt)), 0 );
      end else
      begin
          if FRow > 0 then
            aSymbol := TSymbol( sgBottom.Objects[Symbol_Col, FRow]);
          if aSymbol = nil then Exit;

          for i := 0 to gEnv.Engine.TradeCore.Positions.Count-1 do
          begin
            aPos := gEnv.Engine.TradeCore.Positions.Positions[i];
            if ( aPos <> nil ) and  ( aPos.Volume <> 0 ) and ( aPos.Symbol = aSymbol ) and  
               ( aPos.Account.InvestCode = FAccount.Code ) then
            begin
               aAcnt  := aPos.Account;
               break;
            end;            
          end;

          if aAcnt <> nil then
            PostMessage( gEnv.MainBoard.Handle , WM_SELECTPOSITION,
              integer(Pointer(aAcnt)), integer(Pointer(aSymbol)) );                
      end;     

    end else
    if ( not FIndex ) and ( FAccount <> nil ) then
    begin

      if FRow > 0 then
        aSymbol := TSymbol( sgBottom.Objects[Symbol_Col, FRow]);

      if aSymbol <> nil then
        PostMessage( gEnv.MainBoard.Handle , WM_SELECTPOSITION,
          integer(Pointer(FAccount)), integer(Pointer(aSymbol)) );
    end;

  except
  end;
end;

procedure TFrmMiniPosList.sgBottomDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgClr, ftClr : TColor;
    wFmt : word;
    rRect : TRect;
    aSymbol : TSymbol;
    aAcnt   : TAccount;
begin

  wFmt  := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  bgClr := clWhite;
  ftClr := clBlack;

  with sgBottom do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin

      if ACol <> 0 then
        wFmt  := DT_RIGHT or DT_VCENTER;

      if ARow = RowCount-1 then
        bgClr := clWhite;

      if ShowStg.Checked then
      begin
      
        aAcnt := TAccount( Objects[Symbol_Col, ARow]);
        if ( aAcnt <> nil ) and ( aAcnt.DefAcnt ) then
          bgClr := LONG_COLOR;

        case ACol of
          0           : wFmt  := DT_LEFT or DT_VCENTER;
          Color_Col   : ftClr := TColor( integer( Objects[Color_Col, ARow] ));
          Color_Col2  : ftClr := TColor( integer( Objects[Color_Col2, ARow] ));
        end;

      end else
      begin
          aSymbol := TSymbol( Objects[Symbol_Col, ARow]);
          if aSymbol <> nil then
            case aSymbol.ShortCode[1] of
              '1' : bgClr := clWhite;
              '2' : bgClr := LONG_COLOR;
              '3' : bgClr := SHORT_COLOR;
            end;

          case ACol of
            BG_Col      : ftClr := TColor( integer( Objects[BG_Col, ARow] ));
            Color_Col   :  if mTotal.Checked then
                            ftClr := TColor( integer( Objects[Color_Col, ARow] ));
            Color_Col2  : ftClr := TColor( integer( Objects[Color_Col2, ARow] ));
          end;

      end;

      if FRow = ARow then
        bgClr := GRID_SELECT_COLOR;

    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;

end;

procedure TFrmMiniPosList.sgBottomMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    aCol, aRow : integer;
    aPoint : TPoint;
begin
  //
  aRow := FRow;

  sgBottom.MouseToCell( X, Y, aCol, FRow);

  if aRow > 0 then InvalidateRow( sgBottom, aRow );
  if FRow > 0 then InvalidateRow( sgBottom, FRow );

  if (Button = mbRight) and ( not ShowStg.Checked ) then
  begin
    GetCursorPos(aPoint);
    PopupMenu1.Popup( aPoint.X, aPoint.Y);
  end;

end;

procedure TFrmMiniPosList.sgTopDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgClr, ftClr : TColor;
    wFmt : word;
    rRect : TRect;
begin

  wFmt  := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  bgClr := clWhite;
  ftClr := clBlack;

  with sgTop do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ACol = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      wFmt  := DT_RIGHT or DT_VCENTER;
      ftClr := TColor( integer( Objects[ACol, ARow] ));
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;
end;

procedure TFrmMiniPosList.ChangeTitle;
var
  i : integer;
begin
  with sgBottom do
  begin

    if ShowStg.Checked then
    begin
      for I := 0 to ColCount - 1 do
        Cells[i,0]  := Title_3[i];

      ColWidths[0] := 77;
      ColWidths[1] := -1;
      ColWidths[2] := 50;
      ColWidths[3] := sgBottom.Width - ColWidths[0] - ColWidths[1] -ColWidths[2] - 5;
    end
    else begin

      for I := 0 to ColCount - 1 do
        Cells[i,0]  := ifThenStr( mTotal.Checked, Title_2_1[i],  Title_2[i] );
  {
      ColWidths[0] := 77;
      ColWidths[1] := 40;
      ColWidths[2] := 70;
   }
      ColWidths[0] := 55;
      ColWidths[1] := 20;
      ColWidths[2] := 50;
      ColWidths[3] := sgBottom.Width - ColWidths[0] - ColWidths[1] -ColWidths[2] - 5;

    end;

    FUfColWidth  := ColWidths[3];
    FUfLastGap   := 2;//sgBottom.ClientWidth - sgBottom.ClientWidth ;
  end;
end;

procedure TFrmMiniPosList.Show0NetClick(Sender: TObject);
begin
  if gEnv.Beta then Exit;

  if (not FIndex) and ( ShowStg.Checked ) then
  begin
    ShowStg.Checked := false;
    ShowMessage('리얼 계좌 선택일때만 가능 ');
    Exit;
  end;

  Clear( sgBottom );
  ChangeTitle;
  RefreshPosition;
end;

procedure TFrmMiniPosList.ShowUnitClick(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmMiniPosList.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;


  case Integer(EventID) of

    ACCOUNT_NEW     ,
    ACCOUNT_DELETED ,
    ACCOUNT_UPDATED : OnAccount( DataObj as Tinvestor, EventID );
  end

end;

procedure TFrmMiniPosList.OnAccount(aInvest: TInvestor;
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

procedure TFrmMiniPosList.UpdatePosition( aPosition : TPosition; bAdd : boolean );
begin

end;



procedure TFrmMiniPosList.RefreshPosition;
begin
  if FAccount = nil then Exit;

  RefreshTop;
  RefreshBottom;
end;

procedure TFrmMiniPosList.RefreshTop;
var
  aInvestor : TInvestor;
  I: Integer;
  aAccount  : TAccount;
  aPos  : TPosition;
  dEntry, dPL, dFee, dTotPL : double;
  iDiv : integer;
begin

  dEntry  := 0;
  dPL  := 0;
  dFee := 0;
  dTotPL  := 0;

  iDiv := ifThen( ShowUnit.Checked, 1000, 1 );

  if FIndex then
  begin
    for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];
      if aPos.Account.Code = FAccount.Code then
      begin
        dEntry:= dEntry + aPos.EntryOTE;
        dPL   := dPL    + aPos.EntryPL;
        dTotPL:= dPL + dEntry;
      end;
    end;

    for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    begin
      aAccount  := gEnv.Engine.TradeCore.Investors.Investor[i];
      if aAccount = FAccount then
        dFee  := dFee + abs(aAccount.GetFee);
    end;
  end
  else begin
    gEnv.Engine.TradeCore.Positions.GetMarketTotPl( FAccount, dTotPL, dEntry, dPL );
    dFee  := abs(FAccount.GetFee);
  end;

  dPL := dPL + FAccount.FixedPL;
  dTotPL  := dTotPL + FAccount.FixedPL;
  //dFee:= dFee+ FAccount.GetFee;

  with sgTop do
  begin
    Cells[1, 0] := Format('%.*n', [ 0, dEntry / iDiv ] );
    Cells[1, 1] := Format('%.*n', [ 0, dPL  / iDiv ] );
    Cells[1, 2] := Format('%.*n', [ 0, dFee  / iDiv] );
    Cells[1, 3] := Format('%.*n', [ 0, (dTotPL - dFee) / iDiv ] );

    if (dEntry / iDiv )= 0 then
      Objects[ Color_Col -1 , 0] := Pointer( clBlack )
    else if (dEntry / iDiv )> 0 then
      Objects[ Color_Col -1, 0] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 0] := Pointer( clBlue );

    if (dPL  / iDiv )= 0 then
      Objects[ Color_Col -1 , 1] := Pointer( clBlack )
    else if (dPL  / iDiv )> 0 then
      Objects[ Color_Col -1, 1] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 1] := Pointer( clBlue );

    if ((dTotPL - dFee)  / iDiv )= 0 then
      Objects[ Color_Col -1 , 3] := Pointer( clBlack )
    else if ((dTotPL - dFee)  / iDiv )> 0 then
      Objects[ Color_Col -1, 3] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 3] := Pointer( clBlue );
  end;

end;

procedure TFrmMiniPosList.RefreshTitle;
begin

end;

procedure TFrmMiniPosList.RefreshBottom;
var
  iRow, i : integer;
  aPos : TPosition;
  aAccount : TAccount;
  aInvest : TInvestor;
begin

  if FIndex then
  begin

    if ( ShowStg.Checked ) and  ( FAccount is TInvestor ) then
    begin
        aInvest := FAccount as TInvestor;
        for I := aInvest.Accounts.Count - 1 downto 0 do
        begin
          aAccount  := aInvest.Accounts.Accounts[i];
          if aAccount = nil then Continue;
          
          iRow  := sgBottom.Cols[Symbol_Col].IndexOfObject( aAccount );
          if iRow < 0 then begin
            iRow := 1;
            InsertLine( sgBottom, 1 );
          end;
          UpdateRow( iRow, aAccount );
        end;
    end
    else begin

        for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
        begin
          aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];

          if aPos.Account.Code = FAccount.Code then
          begin
            iRow  := sgBottom.Cols[Symbol_Col].IndexOfObject( aPos.Symbol );
            if iRow < 0 then begin
              if mTotal.Checked then begin
                if ( aPos.LastPL = 0 ) then continue;
              end else begin
                if ( aPos.Volume = 0 ) then Continue;
              end;

              iRow := InsertRow( sgBottom, aPos.Symbol, Symbol_Col );
              if iRow > 0 then
                InsertLine( sgBottom, iRow );
            end else
            begin
              if (aPos.Volume = 0) and ( not mTotal.Checked ) then begin
                DeleteLine( sgBottom, iRow );
                Continue;
              end else
              if (aPos.LastPL = 0 ) and ( mTotal.Checked ) then begin
                DeleteLine( sgBottom, iRow );
                Continue;
              end;
            end;
            UpdateRow( iRow, aPos, true );
          end;
        end;
    end;


  end
  else begin
    for I := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.Positions.Positions[i];
      if aPos.Account = FAccount then
      begin
        iRow  := sgBottom.Cols[0].IndexOfObject( aPos.Symbol );

        if iRow < 0 then begin
          if mTotal.Checked then begin
            if ( aPos.LastPL = 0 ) then continue;
          end else begin
            if ( aPos.Volume = 0 ) then Continue;
          end;
          iRow := InsertRow( sgBottom, aPos.Symbol, Symbol_Col );
          if iRow > 0 then
            InsertLine( sgBottom, iRow );
        end else
        begin

          if (aPos.Volume = 0) and ( not mTotal.Checked ) then begin
            DeleteLine( sgBottom, iRow );
            Continue;
          end else
          if (aPos.LastPL = 0 ) and ( mTotal.Checked ) then begin
            DeleteLine( sgBottom, iRow );
            Continue;
          end;
        end;

        UpdateRow( iRow, aPos, true );
      end;
    end;

  end;

  ResizeGrid;
end;

procedure TFrmMiniPosList.ResizeGrid;
var
  iGap : integer;
begin
  with sgBottom do
  begin
    iGap := Width - ClientWidth ;

    if FUfLastGap > 0 then
      if (iGap > FUfLastGap) and ( FUfColWidth = ColWidths[Color_Col2] )  then
        ColWidths[Color_Col2] := ColWidths[Color_Col2] - iGap + 1
      else  if iGap < FUfLastGap then
        ColWidths[Color_Col2] := FUfColWidth;

    if (RowCount > 2)  then
      FixedRows := 1;
  end;

  FUfLastGap := iGap;
end;

procedure TFrmMiniPosList.UpdateRow( iRow : Integer; aPos : TPosition; bAdd : boolean );
var
  iVol, iDiv   : integer;
  dPrice : double;
begin
  with sgBottom do
  begin

    iVol   := aPos.Volume;
    dPrice := aPos.AvgPrice;

    Objects[ Symbol_Col, iRow ] := aPos.Symbol;


    Cells[0, iRow] := aPos.Symbol.ShortCode;
    Cells[1, iRow] := IntToStr( iVol );

    if iVol = 0 then
      Objects[ BG_Col, iRow] := Pointer( clBlack )
    else if aPos.Volume > 0 then
      Objects[ BG_Col, iRow] := Pointer( clRed )
    else
      Objects[ BG_Col, iRow] := Pointer( clBlue );

    iDiv :=  ifThen( ShowUnit.Checked, 1000, 1 );

    if mTotal.Checked then
    begin
      Cells[2, iRow] := Format('%.*n', [ 0, aPos.EntryOTE / iDiv ] );
      Cells[3, iRow] := Format('%.*n', [ 0, aPos.LastPL / iDiv ]);

      if (aPos.EntryOTE / iDiv )= 0 then
        Objects[ Color_Col , iRow] := Pointer( clBlack )
      else if (aPos.EntryOTE / iDiv )> 0 then
        Objects[ Color_Col , iRow] := Pointer( clRed )
      else
        Objects[ Color_Col , iRow] := Pointer( clBlue );

      if (aPos.LastPL / iDiv )= 0 then
        Objects[ Color_Col2 , iRow] := Pointer( clBlack )
      else if (aPos.LastPL / iDiv )> 0 then
        Objects[ Color_Col2 , iRow] := Pointer( clRed )
      else
        Objects[ Color_Col2 , iRow] := Pointer( clBlue );
    end
    else begin
      Cells[2, iRow] := Format('%.*f', [ aPos.Symbol.Spec.Precision, dPrice ] );
      Cells[3, iRow] := Format('%.*n', [ 0, aPos.EntryOTE / iDiv ] );

      if (aPos.EntryOTE / iDiv )= 0 then
        Objects[ Color_Col2 , iRow] := Pointer( clBlack )
      else if (aPos.EntryOTE / iDiv )> 0 then
        Objects[ Color_Col2 , iRow] := Pointer( clRed )
      else
        Objects[ Color_Col2 , iRow] := Pointer( clBlue );
    end;
  end;
end;

procedure TFrmMiniPosList.UpdateRow(iRow: Integer; aAcnt: TAccount);
var
  dPrice : double;
  dEntry, dPL, dFee, dTotPL : double;
  iDiv : integer;
begin
  with sgBottom do
  begin
    iDiv := ifThen( ShowUnit.Checked, 1000, 1 );

    Objects[ Symbol_Col, iRow ] := aAcnt;

    Cells[0, iRow] := aAcnt.Name;
    Cells[1, iRow] := '';

    dEntry  := 0;   dPL := 0;    dTotPL := 0;
    gEnv.Engine.TradeCore.Positions.GetMarketTotPl( aAcnt, dTotPL, dEntry, dPL );
    if aAcnt.DefAcnt then    
      dTotPL  := dTotPL + FAccount.FixedPL;

    Cells[2, iRow] := Format('%.*n', [ 0, dEntry / iDiv ] );
    Cells[3, iRow] := Format('%.*n', [ 0, dTotPL / iDiv ] );

    if dEntry = 0 then
      Objects[ Color_Col , iRow] := Pointer( clBlack )
    else if dEntry > 0 then
      Objects[ Color_Col , iRow] := Pointer( clRed )
    else
      Objects[ Color_Col , iRow] := Pointer( clBlue );

    if dTotPL = 0 then
      Objects[ Color_Col2 , iRow] := Pointer( clBlack )
    else if dTotPL > 0 then
      Objects[ Color_Col2 , iRow] := Pointer( clRed )
    else
      Objects[ Color_Col2 , iRow] := Pointer( clBlue );
  end;

end;



end.
