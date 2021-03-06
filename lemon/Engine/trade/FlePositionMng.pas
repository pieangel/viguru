unit FlePositionMng;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, StdCtrls, ExtCtrls, CommCtrl,

  CleAccounts, ClePositions, CleSymbols
  ;

const
  //Title_1 : array [0..3] of string = ('평가손익','실현손익','수수료','순손익');
  Title_1 : array [0..3] of string = ('','코드','','잔고' );

  CheckCol  = 0;
  SymbolCol = 1;
  PosCol    = 2;
  BGCol     = 3;

  CHKON  = 100;
  CHKOFF = -100;

type
  TFrmPositionMngr = class(TForm)
    Panel1: TPanel;
    ComboBoAccount: TComboBox;
    Button1: TButton;
    Panel2: TPanel;
    lvAcnt: TListView;
    sg1: TStringGrid;
    Panel3: TPanel;
    lvAcnt2: TListView;
    sg2: TStringGrid;
    Button2: TButton;
    Button3: TButton;
    lbAcntName: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoAccountChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvAcntData(Sender: TObject; Item: TListItem);
    procedure lvAcnt2DrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure lvAcntClick(Sender: TObject);
    procedure sg1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sg1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sg1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    FAccount, FAccount2 : TAccount;
    Positions : TPositions;
    FInvest  : TInvestor;
    FUnRow   : array [0..1] of integer;
    procedure DisPlayAccount;
    procedure UpdatePosition(iTag: integer);
    procedure ClearGrid(aGrid: TStringGrid);
    procedure UpdateRow(aGird: TStringGrid; iRow: Integer; aPos: TPosition;
      bAdd: boolean);
    procedure AssignPositions;
    procedure ReverseAssignPositions;
  public
    { Public declarations }
  end;

var
  FrmPositionMngr: TFrmPositionMngr;

implementation

uses
  GAppEnv, GleLib , GAppConsts,
  GleConsts
  ;

{$R *.dfm}

procedure TFrmPositionMngr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmPositionMngr.FormCreate(Sender: TObject);
var
  I: Integer;
begin

  FAccount  := nil;
  FAccount2 := nil;

  FUnRow[0]  := -1;
  FUnRow[1]  := -1;

  Positions := TPositions.Create;
  AssignPositions;

  gEnv.Engine.TradeCore.Investors.GetList2( ComboBoAccount.Items );
  if ComboBoAccount.Items.Count > 0 then
  begin
    ComboBoAccount.ItemIndex  := 0;
    ComboBoAccountChange( nil );
    ComboBox_AutoWidth( ComboBoAccount );
  end;

  for I := 0 to High( Title_1 ) do
  begin
    sg1.Cells[i,0]  := Title_1[i];
    sg2.Cells[i,0]  := Title_1[i];
  end;
end;

procedure TFrmPositionMngr.FormDestroy(Sender: TObject);
begin
  Positions.Free;
end;

procedure TFrmPositionMngr.AssignPositions;
var
  aSrc, aDsc : TPosition;
  I: Integer;
begin

  for I := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
  begin
    aSrc  := gEnv.Engine.TradeCore.Positions.Positions[i];
    aDsc  := Positions.New(  aSrc.Account, aSrc.Symbol, aSrc.Volume, aSrc.AvgPrice  );
    aDsc.Assign( aSrc );
  end;

end;

procedure TFrmPositionMngr.ReverseAssignPositions;
var
  aSrc, aDsc : TPosition;
  I: Integer;
begin

  gEnv.Engine.TradeCore.Positions.Clear;
  for I := 0 to Positions.Count - 1 do
  begin
    aSrc  := Positions.Positions[i];
    aDsc  := gEnv.Engine.TradeCore.Positions.New(  aSrc.Account, aSrc.Symbol, aSrc.Volume, aSrc.AvgPrice  );
    aDsc.Assign( aSrc );
  end;

end;

procedure TFrmPositionMngr.lvAcnt2DrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  ListView : TListView;
begin

  if (Item.Data = nil) then Exit;
  //
  Rect.Bottom := Rect.Bottom-1;       ;
  ListView := Sender as TListView;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clBlack;
    end else
    begin
      Font.Color := clBlack;
      if Item.Index mod 2 = 1 then
        Brush.Color := EVEN_COLOR
      else
        Brush.Color := ODD_COLOR;
    end;
    //-- background
    FillRect(Rect);
    //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    if (Item.ImageIndex >=0) and (ListView.SmallImages <> nil) then
    begin
      // aListView.SmallImages.BkColor := Brush.Color;
      ListView.SmallImages.Draw(ListView.Canvas, Rect.Left+1, Rect.Top,
                              Item.ImageIndex);
    end;
    //-- caption
    if Item.Caption <> '' then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption);
    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 2 - aSize.cx;
        else iX := iLeft + 2; // redundant coding
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;

end;

//  1 ---> 2
procedure TFrmPositionMngr.Button1Click(Sender: TObject);
begin
  UpdatePosition(0);
  UpdatePosition(1);
end;

procedure TFrmPositionMngr.Button2Click(Sender: TObject);
var
  aPos, aPos2   : TPosition;
  ivol, iRow , i: integer;
  bAll : boolean;

begin
  if ( FAccount = nil ) or ( FAccount2 = nil ) then Exit;
  if ( FAccount = FAccount2 ) then
  begin
    ShowMessage('포지션 변경 계좌가 같자너 !!!');
    Exit;
  end;

  try

    for I := 1 to sg1.RowCount - 1 do
    begin
      aPos  := TPosition( sg1.Objects[ PosCol, i] );
      if (aPos <> nil) and ( integer(sg1.Objects[CheckCol, i]) = CHKON)   then
      begin
        iVol  := StrToIntDef( sg1.Cells[2, i], 0 );
        if iVol = aPos.Volume then bAll := true
        else bAll := false;

        // 일단 복사할 계좌에 같은 포지션이 있는지 찾고
        iRow  := sg2.Cols[ SymbolCol].IndexOfObject( aPos.Symbol );
        if (iRow < 0) and ( iVol <> 0 ) then begin
          aPos2  := Positions.New( FAccount2, aPos.Symbol );
          aPos2.SetPosition( iVol, aPos.AvgPrice );
        end
        else begin
          aPos2 := TPosition( sg2.Objects[PosCol, iRow]);
          aPos2.CalcVolume( iVol);
        end;

        aPos2.CaclOpePL( aPos.Symbol.Last );
        aPos.CalcVolume( -iVol );
        if not bAll then aPos.CaclOpePL(  aPos.Symbol.Last )
        else
          aPos.Free;
      end;
    end;


  finally
    UpdatePosition(0);
    UpdatePosition(1);
  end;
  
end;

//  2 ---> 1
procedure TFrmPositionMngr.Button3Click(Sender: TObject);
var
  aPos, aPos2   : TPosition;
  ivol, iRow , i: integer;
  bAll : boolean;

begin
  if ( FAccount = nil ) or ( FAccount2 = nil ) then Exit;
  if ( FAccount = FAccount2 ) then
  begin
    ShowMessage('포지션 변경 계좌가 같자너 !!!');
    Exit;
  end;

  try

    for I := 1 to sg2.RowCount - 1 do
    begin
      aPos  := TPosition( sg2.Objects[ PosCol, i] );
      if (aPos <> nil) and ( integer(sg2.Objects[CheckCol, i]) = CHKON)   then
      begin
        iVol  := StrToIntDef( sg2.Cells[2, i], 0 );
        if iVol = aPos.Volume then bAll := true
        else bAll := false;

        // 일단 복사할 계좌에 같은 포지션이 있는지 찾고
        iRow  := sg1.Cols[ SymbolCol].IndexOfObject( aPos.Symbol );
        if (iRow < 0) and ( iVol <> 0 ) then begin
          aPos2  := Positions.New( FAccount, aPos.Symbol );
          aPos2.SetPosition( iVol, aPos.AvgPrice );
        end
        else begin
          aPos2 := TPosition( sg1.Objects[PosCol, iRow]);
          aPos2.CalcVolume( iVol);
        end;

        aPos2.CaclOpePL( aPos.Symbol.Last );
        aPos.CalcVolume( -iVol );
        if not bAll then aPos.CaclOpePL(  aPos.Symbol.Last )
        else
          aPos.Free;
      end;
    end;


  finally
    UpdatePosition(0);
    UpdatePosition(1);
  end;
end;

procedure TFrmPositionMngr.Button4Click(Sender: TObject);
begin
  Button6Click( nil );
  Button5Click( nil );
end;

procedure TFrmPositionMngr.Button5Click(Sender: TObject);
begin
  close;
end;

procedure TFrmPositionMngr.Button6Click(Sender: TObject);
begin
  gEnv.Engine.FormBroker.CloseWindow;
  ReverseAssignPositions;
  gEnv.Engine.FormBroker.Load(ComposeFilePath([gEnv.DataDir, FILE_ENV]));
end;


procedure TFrmPositionMngr.CheckBox2Click(Sender: TObject);
var
  i, iTag  : integer;
  aGrid : TStringGrid;
  bCheck: boolean;
begin

  iTag  := ( Sender as TCheckBox ).Tag;
  bCheck:= ( Sender as TCheckBox ).Checked;

  case iTag of
    0 : aGrid := sg1;
    1 : aGrid := sg2;  
  end;

  for I := 1 to aGrid.RowCount - 1 do
  begin
    if aGrid.Objects[ SymbolCol, i ] <> nil then
      if bCheck then
        aGrid.Objects[CheckCol, i] := Pointer(CHKON)
      else
        aGrid.Objects[CheckCol, i] := Pointer(CHKOFF);
  end;

  aGrid.Repaint;

end;

procedure TFrmPositionMngr.ClearGrid( aGrid : TStringGrid );
var
  I: Integer;
begin
  for I := 1 to aGrid.RowCount - 1 do
    aGrid.Rows[i].Clear;

  aGrid.RowCount  := 2;

end;

procedure TFrmPositionMngr.UpdateRow( aGird : TStringGrid; iRow : Integer; aPos : TPosition; bAdd : boolean );
var
  iVol, iDiv   : integer;
  dPrice : double;
begin
  with aGird do
  begin

    iVol   := aPos.Volume;
    dPrice := aPos.AvgPrice;

    Objects[ SymbolCol, iRow ] := aPos.Symbol;
    Objects[ PosCol, iRow ] := aPos;

    Cells[1, iRow] := aPos.Symbol.ShortCode;
    Cells[2, iRow] := IntToStr( iVol );
    Cells[3, iRow] := IntToStr( iVol );

  end;
end;


procedure TFrmPositionMngr.UpdatePosition( iTag : integer );
var
  aAcnt : TAccount;
  aPos  : Tposition;
  aGrid : TStringGrid;
  I, iRow: Integer;
begin

  case iTag of
    0 : begin aAcnt := FAccount;  aGrid  := sg1; end;
    1 : begin aAcnt := FAccount2; aGrid  := sg2; end;
  end;

  if aAcnt = nil then Exit;

  ClearGrid( aGrid );

  with aGrid do

  for I := 0 to Positions.Count - 1 do
  begin
    aPos  := Positions.Positions[i];
    if aPos.Account = aAcnt then
    begin

    /////////
        iRow  := Cols[SymbolCol].IndexOfObject( aPos.Symbol );

        if iRow < 0 then begin
          iRow := InsertRow( aGrid, aPos.Symbol, SymbolCol );
          if iRow > 0 then
          begin
            InsertLine( aGrid, iRow );
            Objects[CheckCol, iRow]  := Pointer( CHKOFF );
          end;
        end else
        begin
          if (aPos.Volume = 0)  then begin
            DeleteLine( aGrid, iRow );
            Continue;
          end;
        end;
        UpdateRow( aGrid, iRow, aPos, true );
    ////////
    end;

  end;

end;

procedure TFrmPositionMngr.lvAcntClick(Sender: TObject);
var
  i, iTag : integer;
  aAcnt : TAccount;
  aInvest : TInvestor;
  aItem : TListItem;
begin
  iTag  := ( Sender as TListView ).Tag;

  with ( Sender as TListView ) do
  begin
    aItem :=  Items.Item[ ItemIndex];
    if aItem = nil then Exit;

    aAcnt := TAccount( aItem.Data );
    if aAcnt = nil then Exit;

    case iTag of
      0 : if FAccount <> aACnt then  FAccount := aAcnt;
      1 : if FAccount2 <> aAcnt then FAccount2:= aAcnt;
    end;
    UpdatePosition( iTag );
  end;

end;

procedure TFrmPositionMngr.lvAcntData(Sender: TObject; Item: TListItem);
var
  aAcnt : TAccount;
  stTxt : string;
  i : Integer;
begin
  if FInvest = nil then Exit;

  aAcnt := FInvest.Accounts.Accounts[Item.Index];
  if aAcnt = nil then Exit;

  Item.Data := aAcnt;
  Item.Caption  := aAcnt.Code;

  with ITem do
  begin
    SubItems.Add( aAcnt.Name );
    //SubItems.Add(  ifThenStr( aAcnt.DefAcnt, '기본', ' ')  );
  end;

end;

procedure TFrmPositionMngr.sg1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    arect : TRect;
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aPos : TPosition;


  procedure DrawCheck(DC:HDC;BBRect:TRect;bCheck:Boolean);
  begin
    if bCheck then
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK + DFCS_CHECKED)
    else
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK);
  end;
begin

  with ( Sender as TStringGrid ) do
  begin

    aFont   := clBlack;
    dFormat := DT_CENTER or DT_VCENTER;
    aRect   := Rect;

    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
      aBack := clBtnFace
    else begin
      if ( ARow mod 2 ) = 0 then
        aBack := GRID_REVER_COLOR
      else
        aBack  := clWhite;
        {
      case ACol of
        2 :  dFormat := DT_RIGHT or DT_VCENTER;
        3 :  dFormat := DT_LEFT  or DT_VCENTER;
      end;
        }
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 4;
    aRect.Right := aRect.Right - 2;
    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if (ARow > 0) and ( ACol = CheckCol ) then
    begin
      if Objects[PosCol, ARow] <> nil then
      begin
        arect := Rect;
        arect.Top := Rect.Top + 2;
        arect.Bottom := Rect.Bottom - 2;
        DrawCheck(Canvas.Handle, arect, integer(Objects[CheckCol,ARow]) = CHKON );
      end;
    end;

  end;
end;

procedure TFrmPositionMngr.sg1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    iTmp, ACol, iTag : integer;
begin

  iTag := ( Sender as TStringGrid ).Tag;
  ( Sender as TStringGrid).MouseToCell( X, Y, ACol, FUnRow[iTAg]);

  if (FUnRow[iTAg] > 0) and (ACol = CheckCol) then   //0번째 열
  begin

    iTmp := integer(  ( Sender as TStringGrid ).Objects[ CheckCol, FUnRow[iTag]] ) ;

    if iTmp = CHKON then
      iTmp := CHKOFF
    else
      iTmp:= CHKON;

    ( Sender as TStringGrid ).Objects[ CheckCol, FUnRow[iTag]] := Pointer(iTmp );
    ( Sender as TStringGrid ).Invalidate;
  end ;

  ( Sender as TStringGrid ).EditorMode := false;
  ( Sender as TStringGrid ).Options    := ( Sender as TStringGrid ).Options - [ goEditing ];

end;

procedure TFrmPositionMngr.sg1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    iTag, aCol : integer;
begin

  iTag := ( Sender as TStringGrid ).Tag;
  ( Sender as TStringGrid).MouseToCell( X, Y, ACol, FUnRow[iTAg]);

  with ( Sender as TStringGrid) do
    if ( aCol = 2) and ( FUnRow[iTag] > 0 ) then
    begin
      Options     := Options + [ goEditing ];
      EditorMode  := true;
    end else begin
      EditorMode  := false;
      Options     := Options - [ goEditing ];
    end;
end;

procedure TFrmPositionMngr.ComboBoAccountChange(Sender: TObject);
var
  aInvest : TInvestor;
  i : integer;
begin
  //
  aInvest  := GetComboObject( ComboBoAccount ) as TInvestor;
  if aInvest = nil then Exit;

  if FInvest <> aInvest then
  begin
    FInvest := aInvest;
    FAccount  := nil;
    FAccount2 := nil;
    lbAcntName.Caption  := FInvest.Name;
    DisPlayAccount;
  end;

end;

procedure TFrmPositionMngr.DisPlayAccount;
begin

  if FInvest = nil then Exit;

  lvAcnt.Items.Clear;
  lvAcnt.Items.Count  := FInvest.Accounts.Count; //  gEnv.Engine.TradeCore.Accounts.Count;
  lvAcnt.Invalidate;

  if lvAcnt.Items.Count > 0 then
  begin
    lvAcnt.Selected    := lvAcnt.Items[0];
    lvAcnt.ItemFocused := lvAcnt.Items[0];
    lvAcntClick( lvAcnt );
  end;

  lvAcnt2.Items.Clear;
  lvAcnt2.Items.Count  := FInvest.Accounts.Count; //  gEnv.Engine.TradeCore.Accounts.Count;
  lvAcnt2.Invalidate;

  if lvAcnt2.Items.Count > 0 then
  begin
    lvAcnt2.Selected    := lvAcnt2.Items[0];
    lvAcnt2.ItemFocused := lvAcnt2.Items[0];
    lvAcntClick( lvAcnt2 );
  end;

end;




end.
