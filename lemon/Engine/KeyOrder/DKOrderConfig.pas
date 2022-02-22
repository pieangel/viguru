unit DKOrderConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, Menus, Commctrl, Buttons,
  //
  GleConsts,  KOrderConst, KeyOrderAgent, ComCtrls, ImgList,
  DInputKey  //, PriceCentral, RpParams;
  ;


type
  TKOrderConfigDlg = class(TForm)
    Panel1: TPanel;
    PanelF1: TPanel;
    PanelF2: TPanel;
    PanelF3: TPanel;
    PanelF4: TPanel;
    PanelF5: TPanel;
    PanelF6: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    PanelGrave: TPanel;
    PanelNum1: TPanel;
    PanelNum2: TPanel;
    PanelNum3: TPanel;
    PanelNum4: TPanel;
    PanelNum5: TPanel;
    PanelNum6: TPanel;
    PanelNum7: TPanel;
    PanelNum8: TPanel;
    PanelNum9: TPanel;
    PanelNum0: TPanel;
    PanelHyphen: TPanel;
    PanelEqual: TPanel;
    Panel31: TPanel;
    Panel32: TPanel;
    PanelQ: TPanel;
    PanelW: TPanel;
    PanelE: TPanel;
    PanelR: TPanel;
    PanelT: TPanel;
    PanelY: TPanel;
    PanelU: TPanel;
    PanelI: TPanel;
    PanelO: TPanel;
    PanelP: TPanel;
    PanelLeftBraket: TPanel;
    PanelRightBraket: TPanel;
    PanelBackSlash: TPanel;
    PanelA: TPanel;
    PanelS: TPanel;
    PanelD: TPanel;
    PanelF: TPanel;
    PanelG: TPanel;
    PanelH: TPanel;
    PanelJ: TPanel;
    PanelK: TPanel;
    PanelL: TPanel;
    PanelSemicolon: TPanel;
    PanelAposterophe: TPanel;
    Panel57: TPanel;
    PanelZ: TPanel;
    PanelX: TPanel;
    PanelC: TPanel;
    PanelV: TPanel;
    PanelB: TPanel;
    PanelN: TPanel;
    PanelM: TPanel;
    PenelComma: TPanel;
    PenelPeriod: TPanel;
    PenelSlash: TPanel;
    Panel69: TPanel;
    Panel72: TPanel;
    Panel73: TPanel;
    Panel58: TPanel;
    Panel70: TPanel;
    Panel71: TPanel;
    Panel74: TPanel;
    Panel75: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    GridSymbolAQty: TStringGrid;
    GridSymbolBQty: TStringGrid;
    OpenDialog: TOpenDialog;
    ListUsing: TListView;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    ListKey: TListView;
    Bevel1: TBevel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    EditOrg: TEdit;
    EditCtrl: TEdit;
    EditAlt: TEdit;
    BtnConfig: TBitBtn;
    BtnNew: TBitBtn;
    ButtonRp: TBitBtn;
    BtnRunStop: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure GridValueSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure BtnNewClick(Sender: TObject);
    procedure ListUsingDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListKeyDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListKeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListLogDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure KeyActionShow(Sender: TObject);
    procedure ListUsingSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure BtnConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonRpClick(Sender: TObject);
    procedure ListKeyColumnClick(Sender: TObject; Column: TListColumn);
    procedure BtnRunStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    SelectedRow, SelectedCol : Integer;

    FKeyOrderItem : TKeyOrderItem; // current item

    //FUnderlying : TSymbolItem;

    FKeyArray : array[0..46] of TPanel;
    FKeyRec : TKeyRec;

    FPrePenel : TPanel;

    //FRpParams : TRpParams;

    FColumns : TList;

    procedure RefreshList;

    procedure UpdateButton(Key : Char);

    procedure RefreshButton;

    //
    procedure ChangeProc(Sender : TObject);
    //
    procedure SetNewItem;
    procedure SetLoadItem;

    procedure OnSelect(Sender : TObject);

  public
    { Public declarations }
  end;

const
  KEY_COUNT = 46;


var
  KOrderConfigDlg: TKOrderConfigDlg;
  DefineKey :  array[TKActionType] of Char; //

implementation

uses Math;



{$R *.dfm}

// Create // Destory
// Set Panel Number
//
procedure TKOrderConfigDlg.FormCreate(Sender: TObject);

begin
  SelectedRow := 0;
  SelectedCol := 0;

  gKeyOrderAgent.OnChange := ChangeProc;

  ChangeProc(Sender);

  FKeyArray[0] := PanelNum0;
  FKeyArray[1] := PanelNum1;
  FKeyArray[2] := PanelNum2;
  FKeyArray[3] := PanelNum3;
  FKeyArray[4] := PanelNum4;
  FKeyArray[5] := PanelNum5;
  FKeyArray[6] := PanelNum6;
  FKeyArray[7] := PanelNum7;
  FKeyArray[8] := PanelNum8;
  FKeyArray[9] := PanelNum9;

  FKeyArray[10] := PanelA;
  FKeyArray[11] := PanelB;
  FKeyArray[12] := PanelC;
  FKeyArray[13] := PanelD;
  FKeyArray[14] := PanelE;
  FKeyArray[15] := PanelF;
  FKeyArray[16] := PanelG;
  FKeyArray[17] := PanelH;
  FKeyArray[18] := PanelI;
  FKeyArray[19] := PanelJ;
  FKeyArray[20] := PanelK;
  FKeyArray[21] := PanelL;
  FKeyArray[22] := PanelM;
  FKeyArray[23] := PanelN;
  FKeyArray[24] := PanelO;
  FKeyArray[25] := PanelP;
  FKeyArray[26] := PanelQ;
  FKeyArray[27] := PanelR;
  FKeyArray[28] := PanelS;
  FKeyArray[29] := PanelT;
  FKeyArray[30] := PanelU;
  FKeyArray[31] := PanelV;
  FKeyArray[32] := PanelW;
  FKeyArray[33] := PanelX;
  FKeyArray[34] := PanelY;
  FKeyArray[35] := PanelZ;
  // Append
  FKeyArray[36] := PanelGrave;
  FKeyArray[37] := PanelHyphen;
  FKeyArray[38] := PanelEqual;
  FKeyArray[39] := PanelBackSlash;
  FKeyArray[40] := PanelLeftBraket;
  FKeyArray[41] := PanelRightBraket;
  FKeyArray[42] := PanelSemicolon;
  FKeyArray[43] := PanelAposterophe;
  FKeyArray[44] := PenelSlash;
  FKeyArray[45] := PenelPeriod;
  FKeyArray[46] := PenelComma;

  FPrePenel := nil;

  FColumns := TList.Create;
end;

procedure TKOrderConfigDlg.GridValueSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  SelectedRow:= ARow;
  SelectedCol:= ACol;
end;

procedure TKOrderConfigDlg.UpdateButton(Key : Char);
var
  atValue : TKActionType;
  aPanel : TPanel;
begin

  aPanel := nil;
  aPanel:= TPanel( FindComponent('Panel' + Key) );

  if aPanel = nil then Exit;

end;


procedure TKOrderConfigDlg.BtnNewClick(Sender: TObject);
begin
  // 선택된 내용이 있어야 한다.

  //  선택된 자료가 없은면
  if FKeyOrderItem = nil then
  begin
    ShowMessage(' 대상화면을 여세요 ');
    Exit;
  end;

  if OpenDialog.Execute then
    FKeyOrderItem.KeyOrderMap := OpenDialog.FileName;

  if FileExists(OpenDialog.FileName) then
    SetLoadItem
  else
    SetNewItem;
end;

procedure TKOrderConfigDlg.ChangeProc(Sender: TObject);
var
  aList : TList;
  i : Integer;
  aItem : TKeyOrderItem;
  aListItem : TListItem;
begin
  aList := TList.Create;

  if ListUsing = nil then Exit;

  try
    gKeyOrderAgent.GetOpenList(aList);

    ListUsing.Items.Clear;

    if aList.Count <= 0 then Exit;

    for i:= 0 to aList.Count-1 do
    begin
      aItem := TKeyOrderItem( aList.Items[i] );

      aItem.OnSelect := OnSelect;

      aListItem := ListUsing.Items.Add;
      aListItem.Data := aItem;

      if aItem.Enable then
        aListItem.Caption := '▶'
      else
        aListItem.Caption := '■';

      aListItem.SubItems.Add( (aItem.Sender as TForm).Caption );
      aListItem.SubItems.Add(aItem.MapName); // 파일이름

      if aItem.Account = nil then  // 계좌
        aListItem.SubItems.Add('')
      else
        aListItem.SubItems.Add(aItem.Account.Name);

      if aItem.SymbolA = nil then  // 종목 A
        aListItem.SubItems.Add('')
      else
        aListItem.SubItems.Add(aItem.SymbolA.Code);

      if aItem.SymbolB = nil then  // 종목 B
        aListItem.SubItems.Add('')
      else
        aListItem.SubItems.Add(aItem.SymbolB.Code);
    end;


  finally
   aList.Free;
  end;  
end;

procedure TKOrderConfigDlg.ListUsingDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aListView : TListView;

  aItem : TKeyOrderItem;
begin
  //
  Rect.Bottom := Rect.Bottom-1;
  aListView := TListView(Sender);
  //
  with aListView.Canvas do
  begin
    //-- colors
    if State >= [odSelected, odFocused] then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end;
    //--
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iLeft := Rect.Left;
    //-- background
    FillRect(Rect);
    //-- caption
    aItem := TKeyOrderItem( Item.Data );
    // 화면에 실행상태인지 를 한눈에 볼수 있도록 여기에 추가하였음
    if i=0 then
    begin
      if aItem.Enable then
      begin
        Item.Caption := '▶';
        Font.Color := clBlue;
      end
      else
      begin
        Item.Caption := '■';
        Font.Color := clRed;
      end;
    end
    else
      Font.Color := clBlack;
    //

    TextRect(
        Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,0), Rect.Bottom),
        Rect.Left + 2, iY, Item.Caption);
    //

    Font.Color := clBlack;



    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= aListView.Columns.Count then Break;
      //
//      iLeft := iLeft + aListView.Columns[i].Width;
      iLeft := iLeft + ListView_GetColumnWidth(aListView.Handle,i);
      //
      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);
      //
      case aListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft + (ListView_GetColumnWidth(aListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft + ListView_GetColumnWidth(aListView.Handle,i+1) - 2 - aSize.cx;
        else iX := iLeft + 2;
      end;
      TextRect(
          Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;

end;


procedure TKOrderConfigDlg.RefreshButton;
var
  i, iKey : Integer;
  aKeyRec : TKeyRec;
begin

  for i:= 0 to KEY_COUNT do
  begin
    iKey := FKeyArray[i].Tag;


    FKeyOrderItem.GetKeyDesc(aKeyRec, iKey);

    if (Trim(aKeyRec.OrgKey)  = '') and
       (Trim(aKeyRec.CtrlKey) = '') and
       (Trim(aKeyRec.AltKey)  = '') then
    begin
      FKeyArray[i].Font.Style := [];
      FKeyArray[i].Color := clBtnFace;
    end
    else
    begin
      FKeyArray[i].Font.Style := [fsBold];
      FKeyArray[i].Color := $00ACFFFF;
    end;

  end;


  //
  if FKeyOrderItem.Enable then BtnRunStop.Caption := 'Running'
  else BtnRunStop.Caption := 'Stopped';

  
end;


procedure TKOrderConfigDlg.ListKeyDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aListView : TListView;
  aActionItem : TKeyActionItem;
begin
  //
  Rect.Bottom := Rect.Bottom-1;
  aListView := TListView(Sender);
  //
  with aListView.Canvas do
  begin
    //-- colors
    aActionItem := TKeyActionItem(Item.Data);

    if State >= [odSelected, odFocused] then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clBlack;
    end else
    begin

      case aActionItem.KeySymbolType of
        ktSymbolA :
          begin
            Brush.Color := $00EFF9AC;
            Font.Color := clBlack;
          end;
        ktSymbolB :
          begin
            Brush.Color := $00E6B4F5;
            Font.Color := clBlack;
          end;
        else
          begin
          end;
      end;

    end;

    //--
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iLeft := Rect.Left;
    //-- background
    FillRect(Rect);
    //-- caption
    TextRect(
        Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,0), Rect.Bottom),
        Rect.Left + 2, iY, Item.Caption);
    //
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= aListView.Columns.Count then Break;
      //
//      iLeft := iLeft + aListView.Columns[i].Width;
      iLeft := iLeft + ListView_GetColumnWidth(aListView.Handle,i);
      //
      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);
      //
      case aListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft + (ListView_GetColumnWidth(aListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft + ListView_GetColumnWidth(aListView.Handle,i+1) - 2 - aSize.cx;
        else iX := iLeft + 2;
      end;
      TextRect(
          Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;
end;


procedure TKOrderConfigDlg.ListKeyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  aListItem : TListItem;
  aActionItem : TKeyActionItem;
begin
  case Key of
    VK_DELETE :
      begin

        if ListKey.Selected = nil then Exit;

        aListItem := ListKey.Selected;
        aActionItem := TKeyActionItem(aListItem.Data);
        FKeyOrderItem.RemoveKey(aActionItem.Key);

        aActionItem.Free;
        aListItem.Free;
      end;
  end;
end;


procedure TKOrderConfigDlg.ListLogDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
  aListView : TListView;
begin
  //
  Rect.Bottom := Rect.Bottom-1;
  aListView := TListView(Sender);
  //
  with aListView.Canvas do
  begin
    //-- colors
    if State >= [odSelected, odFocused] then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clBlack;
    end else
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end;
    //--
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iLeft := Rect.Left;
    //-- background
    FillRect(Rect);
    //-- caption
    TextRect(
        Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,0), Rect.Bottom),
        Rect.Left + 2, iY, Item.Caption);
    //
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= aListView.Columns.Count then Break;
      //
//      iLeft := iLeft + aListView.Columns[i].Width;
      iLeft := iLeft + ListView_GetColumnWidth(aListView.Handle,i);
      //
      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);
      //
      case aListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 2;
        taCenter :       iX := iLeft + (ListView_GetColumnWidth(aListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft + ListView_GetColumnWidth(aListView.Handle,i+1) - 2 - aSize.cx;
        else iX := iLeft + 2;
      end;
      TextRect(
          Classes.Rect(iLeft, iY,
             iLeft + ListView_GetColumnWidth(aListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;

end;

procedure TKOrderConfigDlg.KeyActionShow(Sender: TObject);
var
  iKey : Integer;
  aKeyRec : TKeyRec;
begin

  if FKeyOrderItem = nil then Exit;

  iKey := (Sender as TPanel).Tag;

  FKeyOrderItem.GetKeyDesc(aKeyRec, iKey);

  FKeyRec := aKeyRec;

  EditOrg.Text  := FKeyRec.OrgKey;
  EditCtrl.Text := FKeyRec.CtrlKey;
  EditAlt.Text  := FKeyRec.AltKey;


  (Sender as TPanel).BorderStyle := bsSingle;

  if FPrePenel <> nil then
  begin
    FPrePenel.BorderStyle :=  bsNone;
  end;
  FPrePenel := Sender as TPanel;
end;

procedure TKOrderConfigDlg.ListUsingSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  i : Integer;
begin

  try
    FKeyOrderItem := TKeyOrderItem(Item.Data);

    //
    FKeyOrderItem.GetKeyActionList(FColumns);
    RefreshList;

    for i:= 0 to 5 do
    begin
      GridSymbolAQty.Cells[0, i] := IntToStr( FKeyOrderItem.KQty[i+1, ktSymbolA] );
      GridSymbolBQty.Cells[0, i] := IntToStr( FKeyOrderItem.KQty[i+1, ktSymbolB] );
    end;

    RefreshButton;
  except
    //
  end;

end;

procedure TKOrderConfigDlg.SetNewItem;
var
  i : Integer;
begin
  for i:=0 to KEY_COUNT do
    FKeyArray[i].Color := clBtnFace;


  //FKeyOrderItem.GetKeyActionList(ListKey);
  FKeyOrderItem.GetKeyActionList(FColumns);
  RefreshList;


  for i:= 0 to 5 do
  begin
    GridSymbolAQty.Cells[0, i] := IntToStr( FKeyOrderItem.KQty[i+1, ktSymbolA] );
    GridSymbolBQty.Cells[0, i] := IntToStr( FKeyOrderItem.KQty[i+1, ktSymbolB] );
  end;

end;

procedure TKOrderConfigDlg.BtnConfigClick(Sender: TObject);
var
  aDlg: TInputKeyDlg;
begin

  if (FKeyOrderItem = nil) or
     (FKeyOrderItem.MapName = '')  then Exit;


  aDlg :=  TInputKeyDlg.Create(Self);

  try
    aDlg.KeyOrderItem:= FKeyOrderItem;
    if aDlg.ShowModal = mrOK then
    begin
      FKeyOrderItem := aDlg.KeyOrderItem;
      SetLoadItem;
      RefreshButton;
    end;

  finally
    aDlg.Free;
  end;


end;


// Load Item form KeyOrderItem
//
//
procedure TKOrderConfigDlg.SetLoadItem;
var
  aValue : TKActionType;
  i : Integer;
begin
  // 입력된 값을 저장한다.
  FKeyOrderItem.Save;

  // Get Active Key List
  FKeyOrderItem.GetKeyActionList(FColumns);
  RefreshList;

  for i:= 0 to 5 do
  begin
    GridSymbolAQty.Cells[0, i] := IntToStr( FKeyOrderItem.KQty[i+1, ktSymbolA] );
    GridSymbolBQty.Cells[0, i] := IntToStr( FKeyOrderItem.KQty[i+1, ktSymbolB] );
  end;

end;

procedure TKOrderConfigDlg.FormDestroy(Sender: TObject);
var
  i : Integer;
  aItem : TKeyOrderItem;
  aList : TList;
begin
  try
    aList := TList.Create;
    gKeyOrderAgent.GetOpenList(aList);

    for i := 0 to aList.Count-1 do
    begin
      aItem := TKeyOrderItem( aList.Items[i] );
      aItem.OnSelect := nil;
    end;
  finally
    aList.Free;
  end;
end;


// 민감도 설정
procedure TKOrderConfigDlg.ButtonRpClick(Sender: TObject);
var
  //aDlg : TRpParamDialog;
  i : Integer;
//  aVtPosition : TVtPositionItem;
  //aRpParam : TRpParamItem;
begin
  ShowMessage('변동성 설정은 아직안됨');
{  aRpParam := FRpParams.SParams[FUnderlying];
  if aRpParam = nil then Exit;

  aDlg := TRpParamDialog.Create(Self);
  try
    //
    for i := 0 to FPositions.Count-1 do
    with FPositions.Items[i] as TVtPositionItem do
      if Checked then
        aDlg.InsertPositionVol(Symbol , Qty);

    if aDlg.Open(aRpParam , True) then
    begin
      //
      ApplyRpParam(FRpParams , FUnderlying);

      try
        BeginUpdate;
        for i:=0 to FPositions.Count-1 do
          RecalcPosition2(FPositions.Items[i] as TVtPositionItem);
      finally
        EndUpdate(False);
      end;     //현재로서는 쓸데 없는 증거금 계산을 하고 있다.
    end;
  finally
    aDlg.Free;
  end;}
end;

var
  iSortColIndex : Integer;

// 종목 sort 함수
function ActionSortCompare(Item1, Item2: Pointer): Integer;
var
  ActionItem1 : TKeyActionItem absolute Item1;
  ActionItem2 : TKeyActionItem absolute Item2;
begin

  case iSortColIndex of
    0 : Result := ActionItem1.Key - ActionItem2.Key;   // key
    1 : Result := Ord(ActionItem1.KeySymbolType) - Ord(ActionItem2.KeySymbolType); // Action
    2 : Result := CompareStr(ActionItem1.KeyDesc, ActionItem2.KeyDesc); // 종목
    else Result := 0;
  end;
end;

procedure TKOrderConfigDlg.ListKeyColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  iSortColIndex := Column.Index;
  FColumns.Sort(ActionSortCompare);
  RefreshList;
end;



procedure TKOrderConfigDlg.RefreshList;
var
  i : integer;
  aActionItem : TKeyActionItem;
  aListItem : TListItem;
begin
  if FColumns = nil then Exit;

  ListKey.Clear;

  for i:=0 to FColumns.Count-1 do
  begin
    aActionItem := TKeyActionItem(FColumns.Items[i]);

    if aActionItem = nil then Continue;

    aListItem:=  ListKey.Items.Add;
    aListItem.Data := aActionItem;

    if ssCtrl in aActionItem.Shift  then
      aListItem.Caption := '^ ' + Char(aActionItem.Key)
    else if ssAlt in aActionItem.Shift then
      aListItem.Caption := '@ ' + Char(aActionItem.Key)
    else
      aListItem.Caption := Char(aActionItem.Key);

    case aActionItem.KeySymbolType of
      ktSymbolA : aListItem.SubItems.Add('종목A');
      ktSymbolB : aListItem.SubItems.Add('종목B');
      ktSymbolAll : aListItem.SubItems.Add('All');
      ktNone   : aListItem.SubItems.Add('None');
    end;
    aListItem.SubItems.Add(aActionItem.KeyDesc);
  end;
end;

procedure TKOrderConfigDlg.BtnRunStopClick(Sender: TObject);
begin

  if FKeyOrderItem = nil then Exit;

  if FKeyOrderItem.Enable then
  begin
    FKeyOrderItem.Enable := False;
    //ShowMessage(' 비활성으로 바꾸시면 해당 키주문은 시세를 받지 않고 주문도 낼수 없습니다.');
    BtnRunStop.Caption := 'Stopped';
  end
  else
  begin
    FKeyOrderItem.Enable := True;
    BtnRunStop.Caption := 'Running';
  end;

  ListUsing.Refresh;

end;

procedure TKOrderConfigDlg.OnSelect(Sender: TObject);
var
  i : Integer;
  aItem1, aItem2 : TKeyOrderItem;
begin

  for i:=0 to ListUsing.Items.Count-1 do
  begin
    aItem1 := TKeyOrderItem( ListUsing.Items[i].Data );
    aItem2 :=  Sender as TKeyOrderItem;
    if aItem1 = aItem2 then
    begin
      ListUsing.Selected:=  ListUsing.Items[i];
      ListUsing.Selected.Focused := True;
    end;
  end;

end;

procedure TKOrderConfigDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FColumns.Free;
  gKeyOrderAgent.OnChange := nil;
  Action := caFree;
end;

end.
