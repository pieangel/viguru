unit DInputKey;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls, ComCtrls, Commctrl, Buttons,
  KeyOrderAgent, KOrderConst,
  //AppConsts,
  GleConsts, GleLib,
  ImgList;

type
  TInputKeyDlg = class(TForm)
    Label1: TLabel;
    RadioSymbolType: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EditNewLong1: TEdit;
    EditNewLong2: TEdit;
    EditNewLong3: TEdit;
    EditNewLong4: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    EditNewLong5: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    EditNewShort1: TEdit;
    EditNewShort2: TEdit;
    EditNewShort3: TEdit;
    EditNewShort4: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    EditNewShort5: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    EditChangeLong1: TEdit;
    EditChangeLong2: TEdit;
    EditChangeLong3: TEdit;
    EditChangeLong4: TEdit;
    EditChangeLong5: TEdit;
    EditChangeLong6: TEdit;
    EditChangeLong7: TEdit;
    EditChangeLong8: TEdit;
    EditChangeShort2: TEdit;
    EditChangeShort1: TEdit;
    EditChangeShort3: TEdit;
    EditChangeShort4: TEdit;
    EditChangeShort5: TEdit;
    EditChangeShort6: TEdit;
    EditChangeShort7: TEdit;
    EditChangeShort8: TEdit;
    GridSymbolQty: TStringGrid;
    Bevel7: TBevel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    EditCancelAll: TEdit;
    EditCancelNotLast: TEdit;
    EditCancelLast: TEdit;
    EditCancelShort: TEdit;
    EditCancelLong: TEdit;
    Bevel8: TBevel;
    Label24: TLabel;
    EditQty1: TEdit;
    EditQty2: TEdit;
    EditQty3: TEdit;
    EditQty4: TEdit;
    EditQty5: TEdit;
    EditQty6: TEdit;
    EditQty7: TEdit;
    EditQty8: TEdit;
    Bevel9: TBevel;
    Label25: TLabel;
    Label26: TLabel;
    Bevel10: TBevel;
    Bevel11: TBevel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    EditSellOrder1: TEdit;
    EditSellOrder2: TEdit;
    EditSellOrder3: TEdit;
    EditBuyOrder1: TEdit;
    EditBuyOrder2: TEdit;
    EditBuyOrder3: TEdit;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    Label61: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    Label64: TLabel;
    Label65: TLabel;
    EditQty9: TEdit;
    EditQty10: TEdit;
    EditQty11: TEdit;
    EditQtyDelta: TEdit;
    BtnOk: TButton;
    BtnCancel: TButton;
    EditNewLong6: TEdit;
    EditNewShort6: TEdit;
    ListKey: TListView;
    Bevel12: TBevel;
    Bevel13: TBevel;
    Bevel14: TBevel;
    Label66: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    Label69: TLabel;
    Label70: TLabel;
    Label71: TLabel;
    Label72: TLabel;
    Label73: TLabel;
    EditStopLoss3: TEdit;
    EditStopLoss2: TEdit;
    EditStopLoss1: TEdit;
    EditTradingStop2: TEdit;
    EditTradingStop1: TEdit;
    EditStopLoss4: TEdit;
    ComboDelayTime: TComboBox;
    Label19: TLabel;
    BtnSave: TSpeedButton;
    CheckUserDef: TCheckBox;
    EditDelay: TEdit;
    Label20: TLabel;
    BtnDel: TSpeedButton;
    Label74: TLabel;
    ButtonRecord: TSpeedButton;
    ListMacro: TListView;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure InputKeyValue(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnOkClick(Sender: TObject);
    procedure ListKeyDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure RadioSymbolTypeClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure ComboDelayTimeChange(Sender: TObject);
    procedure CheckUserDefClick(Sender: TObject);
    procedure EditDelayKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnDelClick(Sender: TObject);
    procedure ListKeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure ListKeyColumnClick(Sender: TObject; Column: TListColumn);
    procedure ButtonRecordClick(Sender: TObject);


  private
    FSelectAllOK : array[0..10] of TEdit;
    FActionMap : array[TKActionType] of TEdit;

    FItemIndex : Integer;

    FColumns : TList;

    FMacroTokens : String;

    FKeyOrderItem: TKeyOrderItem;
    procedure SetKeyOrderItem(const Value: TKeyOrderItem);
    function GetOrderItem: TKeyOrderItem;

    procedure RefreshList;

    function ResetValue : Boolean;
    function DeleteAction(aEdit : TEdit) : Boolean;

    procedure ItemChange;
    function ChangeColor(aEdit : TEdit) : Boolean;
    function GetTextValue(aEdit : TEdit; atValue : TKActionType; aKeySymbolType : TKeySymbolType) : String;

    //
    function AddNewKey(aShift : TShiftState; aKey: Word; aEdit : TEdit; aSymbolType : TKeySymbolType) : Boolean;
    //

    function LoadMacroList : Boolean;

    function GetOrderKey(aSymbolType : TKeySymbolType) : Boolean;


  public
    property KeyOrderItem : TKeyOrderItem read GetOrderItem write SetKeyOrderItem;
  end;




var
  InputKeyDlg: TInputKeyDlg;

implementation

uses DMacro;//, AppUtils;



const
  SYMBOLA_COLOR = $00EFF9AC;
  SYMBOLB_COLOR = $00E6B4F5;
  TIME_GAP = 50;
  DEFAULT_TIMES : array[0..7] of Integer = (0, 100, 150, 200, 250, 300, 350, 400);


{$R *.dfm}


function EXIST_DEFAULTTIME(iValue : Integer) : Boolean;
var
  i : Integer;
begin
  Result := False;
  for i:= 0 to 7 do
    if DEFAULT_TIMES[i] = iValue then
    begin
      Result := True;
      Break;
    end;
end;

procedure TInputKeyDlg.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  //

  for i:= 0 to 5 do
    GridSymbolQty.Cells[0,i] := IntToStr(i + 1);

  FSelectAllOK[0] := EditCancelAll;
  FSelectAllOK[1] := EditCancelNotLast;
  FSelectAllOK[2] := EditCancelLast;
  FSelectAllOK[3] := EditCancelShort;
  FSelectAllOK[4] := EditCancelLong;
  FSelectAllOK[5] := EditStopLoss1;
  FSelectAllOK[6] := EditStopLoss2;
  FSelectAllOK[7] := EditStopLoss3;
  FSelectAllOK[8] := EditStopLoss4;
  FSelectAllOK[9] := EditTradingStop1;
  FSelectAllOK[10] := EditTradingStop2;

  FActionMap[atNewLong1] := EditNewLong1;
  FActionMap[atNewLong2] := EditNewLong2;
  FActionMap[atNewLong3] := EditNewLong3;
  FActionMap[atNewLong4] := EditNewLong4;
  FActionMap[atNewLong5] := EditNewLong5;
  FActionMap[atNewLong6] := EditNewLong6;
  FActionMap[atNewShort1] := EditNewShort1;
  FActionMap[atNewShort2] := EditNewShort2;
  FActionMap[atNewShort3] := EditNewShort3;
  FActionMap[atNewShort4] := EditNewShort4;
  FActionMap[atNewShort5] := EditNewShort5;
  FActionMap[atNewShort6] := EditNewShort6;
  FActionMap[atProfitExit1] := EditTradingStop1;
  FActionMap[atProfitExit2] := EditTradingStop2;
  FActionMap[atClear1] := EditStopLoss1;
  FActionMap[atClear2] := EditStopLoss2;
  FActionMap[atClear3] := EditStopLoss3;
  FActionMap[atClear4] := EditStopLoss4;
  FActionMap[atSellExit1] := EditSellOrder1;
  FActionMap[atSellExit2] := EditSellOrder2;
  FActionMap[atSellExit3] := EditSellOrder3;
  FActionMap[atBuyExit1] := EditBuyOrder1;
  FActionMap[atBuyExit2] := EditBuyOrder2;
  FActionMap[atBuyExit3] := EditBuyOrder3;
  FActionMap[atCancelAll] := EditCancelAll;
  FActionMap[atCancelLast] := EditCancelLast;
  FActionMap[atCancelNotLast] := EditCancelNotLast;
  FActionMap[atCancelShort] := EditCancelShort;
  FActionMap[atCancelLong] := EditCancelLong;
  FActionMap[atChangeLong1] := EditChangeLong1;
  FActionMap[atChangeLong2] := EditChangeLong2;
  FActionMap[atChangeLong3] := EditChangeLong3;
  FActionMap[atChangeLong4] := EditChangeLong4;
  FActionMap[atChangeLong5] := EditChangeLong5;
  FActionMap[atChangeLong6] := EditChangeLong6;
  FActionMap[atChangeLong7] := EditChangeLong7;
  FActionMap[atChangeLong8] := EditChangeLong8;
  FActionMap[atChangeShort1] := EditChangeShort1;
  FActionMap[atChangeShort2] := EditChangeShort2;
  FActionMap[atChangeShort3] := EditChangeShort3;
  FActionMap[atChangeShort4] := EditChangeShort4;
  FActionMap[atChangeShort5] := EditChangeShort5;
  FActionMap[atChangeShort6] := EditChangeShort6;
  FActionMap[atChangeShort7] := EditChangeShort7;
  FActionMap[atChangeShort8] := EditChangeShort8;
  FActionMap[atQty1 ] := EditQty1 ;
  FActionMap[atQty2 ] := EditQty2 ;
  FActionMap[atQty3 ] := EditQty3 ;
  FActionMap[atQty4 ] := EditQty4 ;
  FActionMap[atQty5 ] := EditQty5 ;
  FActionMap[atQty6 ] := EditQty6 ;
  FActionMap[atQty7 ] := EditQty7 ;
  FActionMap[atQty8 ] := EditQty8 ;
  FActionMap[atQty9 ] := EditQty9 ;
  FActionMap[atQty10] := EditQty10;
  FActionMap[atQty11] := EditQty11;
  FActionMap[atQtyDelta] := EditQtyDelta;

  ResetValue;

  FItemIndex:= RadioSymbolType.ItemIndex;

  FColumns := TList.Create;
end;

procedure TInputKeyDlg.InputKeyValue(Sender: TObject; var Key: Word;  Shift: TShiftState);

  function SymbolSelected : Boolean;
  begin
    Result := True;
    if RadioSymbolType.ItemIndex < 0 then
    begin
      ShowMessage(' 종목을 선택해주세요');
      Result := False;
    end;
  end;

  function AllSelected(aEdit : TEdit) : Boolean;
  var
    i : Integer;
  begin
    Result := False;
    for i:= 0 to 10 do
      if FSelectAllOK[i] = aEdit then
      begin
        Result := True;
        Exit;
      end;
  end;

var
  aEdit : TEdit;
  aSymbolType : TKeySymbolType;
begin
  if Sender = nil then Exit;

  if Key = VK_RETURN then Exit;  // Enter 처리

  if KEY in [VK_F1..VK_F24, VK_LEFT, VK_DOWN, VK_UP, VK_RIGHT] then Exit;

  aEdit := Sender as TEdit;
  aEdit.Text := '';

  if (Key = VK_DELETE) or (KEY = VK_BACK) then
  begin
    DeleteAction(aEdit);
    Exit;
  end;

  // num pad 에 있는 숫자를 사용할수 있도록 하는 함수..
  NUMPADtoNUM(Key);

  AscPressToDown(Key);

  case Key of
    Ord('0')..Ord('9'),
    Ord('A')..Ord('Z'),
    Ord('-'), Ord('='),
    Ord('\'), Ord('['),
    Ord(']'), Ord(';'),
    Ord(''''),Ord(','),
    Ord('.'), Ord('/'),
    VK_F1, VK_F2, VK_F3,
    VK_F4, VK_F5, VK_F6,
    VK_F7, VK_F8, VK_F9,
    VK_F10, VK_F11, VK_F12, VK_CAPITAL :
    begin

      if not SymbolSelected then
      begin
        Key := 0;
        Exit;
      end;

      // Key 가 있는지 검사

      case RadioSymbolType.ItemIndex of
       0 : aSymbolType := ktSymbolA;
       1 : aSymbolType := ktSymbolB;
       2 : aSymbolType := ktSymbolAll;
      end;

      if FKeyOrderItem.IsUsed(Key, Shift) then
      begin
        ShowMessage(Char(Key) + ' 는(은) 이미 지정한 키( Key )  입니다.  ' +
                                ' 기존 키를 삭제하고 다시 입력하세요');
        Key := 0;
        aEdit.Text := '';
        Exit;
      end;

      // 동일한 엑션이 있는 경우에는 Key만 변경

      if not AddNewKey(Shift, Key, aEdit, aSymbolType) then
      begin
        ShowMessage(' 이미정의된 Key입니다. 다시 입력하세요!');
        aEdit.Text := '';
        //aEdit.Color := clWhite;
        Exit;
      end;      

      if Key <> 0 then
      begin
        if ssCtrl in Shift then aEdit.Text := 'Ctrl + ' + Char(Key)
        else if ssAlt  in Shift then aEdit.Text := 'Alt + ' + Char(Key)
        else aEdit.Text := Char(Key);
      end;

      if RadioSymbolType.ItemIndex = 0 then
        aEdit.Color := SYMBOLA_COLOR
      else if RadioSymbolType.ItemIndex = 1 then
        aEdit.Color := SYMBOLB_COLOR
      else if RadiosymbolType.ItemIndex = 2 then
        aEdit.Color := $00FF80FF;

      {if (not AllSelected(aEdit)) and (RadioSymbolType.ItemIndex = 2) then
      begin
        ShowMessage(' 해당 Action 은 두종목을 동시에 할수 없는 Action 입니다. ');
        aEdit.Text := '';
        //aEdit.Color := clWhite;
        Exit;
      end;}

      {case RadioSymbolType.ItemIndex of
       0 : aSymbolType := ktSymbolA;
       1 : aSymbolType := ktSymbolB;
       2 : aSymbolType := ktSymbolAll;
      end;

      if not AddNewKey(Shift, Key, aEdit, aSymbolType) then
      begin
        ShowMessage(' 이미정의된 Key입니다. 다시 입력하세요!');
        aEdit.Text := '';
        //aEdit.Color := clWhite;
        Exit;
      end;}
    end;  //

    else  Key := 0;
  end;
end;

procedure TInputKeyDlg.SetKeyOrderItem(const Value: TKeyOrderItem);
var
  aSymbolType : TKeySymbolType;
begin

  if Value = nil then Exit;

  FKeyOrderItem := Value;
  FKeyOrderItem.GetKeyActionList(FColumns);

  if FColumns.Count < 0 then Exit;

  case FItemIndex of
    0 : aSymbolType := ktSymbolA;
    1 : aSymbolType := ktSymbolB;
    else aSymbolType := ktSymbolAll;
  end;

  GetOrderKey(aSymbolType);
end;

function TInputKeyDlg.GetOrderItem: TKeyOrderItem;
begin
  Result := FKeyOrderItem;
end;

function TInputKeyDlg.ResetValue: Boolean;
var
  aValue : TKActionType;
begin

  for aValue := atFirst to atLast do
  begin
    FActionMap[aValue].Text := '';
    FActionMap[aValue].Color := clWhite;
  end;

  GridSymbolQty.Cells[0,0] := '';
  GridSymbolQty.Cells[0,1] := '';
  GridSymbolQty.Cells[0,2] := '';
  GridSymbolQty.Cells[0,3] := '';
  GridSymbolQty.Cells[0,4] := '';
  GridSymbolQty.Cells[0,5] := '';

end;

procedure TInputKeyDlg.BtnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;


//
//
//
function TInputKeyDlg.AddNewKey(aShift: TShiftState; aKey: Word;  aEdit : TEdit; aSymbolType : TKeySymbolType): Boolean;
var
  i : Integer;
  aActionItem : TKeyActionItem;
  aActionType : TKActionType;
  aValue : TKActionType;
begin
  Result := False;

  // find action form  TEdit
  for aValue := atFirst to atLast do
    if FActionMap[aValue].Name = aEdit.Name then
    begin
      aActionType := aValue;
      Break;
    end;

  aActionItem := FKeyOrderItem.NewKeyAction(aKey, aShift, aSymbolType, aActionType);

  if aActionItem <> nil then
    FColumns.Add( aActionItem );

  RefreshList;

  Result := True;
end;

procedure TInputKeyDlg.ListKeyDrawItem(Sender: TCustomListView;
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

function TInputKeyDlg.DeleteAction(aEdit: TEdit): Boolean;
var
  aActionType, aValue : TKActionType;
  aSymbolType : TKeySymbolType;
begin
  Result := False;

  for aValue := atFirst to atLast do
    if FActionMap[aValue].Name = aEdit.Name then
    begin
      aActionType := aValue;
      Break;
    end;


  if RadioSymbolType.ItemIndex = 0 then
    aSymbolType := ktSymbolA
  else if RadioSymbolType.ItemIndex = 1 then
    aSymbolType := ktSymbolB;


  FKeyOrderItem.RemoveAction(aActionType);

  FKeyOrderItem.GetKeyActionList(FColumns);
  RefreshList;

  //aEdit.Color := clWhite;

  Result := True;
end;

procedure TInputKeyDlg.RadioSymbolTypeClick(Sender: TObject);
begin
  if FItemIndex <> RadioSymbolType.ItemIndex then
  begin
    FItemIndex := RadioSymbolType.ItemIndex;
    ItemChange;
  end;
end;

procedure TInputKeyDlg.ItemChange;
var
  aValue : TKActionType;
  i : Integer;
begin
  ResetValue;

  case FItemIndex of
    0 : GetOrderKey( ktSymbolA );
    1 : GetOrderKey( ktSymbolB );
  end;
end;



function TInputKeyDlg.ChangeColor(aEdit : TEdit) : Boolean;
begin
  Result := False;

  if aEdit.Text = '' then
  begin
    //aEdit.Color := clWhite;
    Exit;
  end;

  if RadioSymbolType.ItemIndex = 0 then
    aEdit.Color := SYMBOLA_COLOR
  else if RadioSymbolType.ItemIndex = 1 then
    aEdit.Color := SYMBOLB_COLOR
  else if RadiosymbolType.ItemIndex = 2 then
    aEdit.Color := $00FF80FF;

end;


function TInputKeyDlg.GetTextValue(aEdit : TEdit; atValue : TKActionType; aKeySymbolType : TKeySymbolType) : String;
begin
  Result := '';

  Result := FKeyOrderItem.ActionDesc[atValue];

  case aKeySymbolType of
    ktSymbolA : aEdit.Color := SYMBOLA_COLOR;
    ktSymbolB : aEdit.Color := SYMBOLB_COLOR;
  end;

end;


procedure TInputKeyDlg.BtnSaveClick(Sender: TObject);
var
  i : Integer;
begin


  case FItemIndex of
    0 :  // 종목 A
      for i:= 0 to 5 do
        FKeyOrderItem.KQty[i+1, ktSymbolA] := StrToIntDef( GridSymbolQty.Cells[0, i], 0);
    1 :
      for i:= 0 to 5 do
        FKeyOrderItem.KQty[i+1, ktSymbolB] := StrToIntDef( GridSymbolQty.Cells[0, i], 0);

  end;

end;

procedure TInputKeyDlg.ComboDelayTimeChange(Sender: TObject);
begin

  case FItemIndex of
    0 : //  종목 A
      FKeyOrderItem.SymbolADelayTime := ComboDelayTime.ItemIndex * TIME_GAP;
    1 : // 종목 B
      FKeyOrderItem.SymbolBDelayTime := ComboDelayTime.ItemIndex * TIME_GAP;
  end;

end;

procedure TInputKeyDlg.CheckUserDefClick(Sender: TObject);
var
  aBoolean : Boolean;
begin

  aBoolean := CheckUserDef.Checked;

  if aBoolean then
  begin
    EditDelay.Visible := aBoolean;
    ComboDelayTime.Visible := not aBoolean;
  end
  else
  begin
    EditDelay.Visible := aBoolean;
    ComboDelayTime.Visible := not aBoolean;
  end;

end;

procedure TInputKeyDlg.EditDelayKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    case FItemIndex of
      0 : //  종목 A
        FKeyOrderItem.SymbolADelayTime := StrToIntDef( EditDelay.Text, 0 );
      1 : // 종목 B
        FKeyOrderItem.SymbolBDelayTime := StrToIntDef( EditDelay.Text, 0 );
    end;
  end;
end;

procedure TInputKeyDlg.BtnDelClick(Sender: TObject);
begin
  if MessageDlg('설정된 키를 모두 지우시겠습니까?', mtWarning, [mbYes, mbNo], 0) = mrNo then Exit;

  FKeyOrderItem.RemoveAll;
  ResetValue;

  FKeyOrderItem.GetKeyActionList(FColumns);  
  RefreshList;

  SetKeyOrderItem(FKeyOrderItem);
end;

procedure TInputKeyDlg.ListKeyKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  aActionItem : TKeyActionItem;
begin
  if Key = VK_RETURN then
  begin
    if  ListKey.Selected = nil then Exit;

    aActionItem := TKeyActionItem(ListKey.Selected.Data);

    FKeyOrderItem.RemoveKey(aActionItem.Key);
    FKeyOrderItem.GetKeyActionList(FColumns);
    RefreshList;
  end;
end;

procedure TInputKeyDlg.FormDestroy(Sender: TObject);
begin
  FColumns.Free;
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




// 정렬하기
procedure TInputKeyDlg.ListKeyColumnClick(Sender: TObject; Column: TListColumn);
begin
  iSortColIndex := Column.Index;
  FColumns.Sort(ActionSortCompare);
  RefreshList;
end;

procedure TInputKeyDlg.RefreshList;
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

procedure TInputKeyDlg.ButtonRecordClick(Sender: TObject);
var
  aDlg : TMacroDlg;
begin
  aDlg := TMacroDlg.Create(nil);

  try
    aDlg.KeyOrderItem := FKeyOrderItem;

    if aDlg.ShowModal = mrOK then
    begin
      FKeyOrderItem := aDlg.KeyOrderItem;
    end;

  finally
    aDlg.Free;
    LoadMacroList;
  end;

end;

const
  KeyDesc : array[VK_F2..VK_F12] of String =
    ('F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12');


function TInputKeyDlg.LoadMacroList: Boolean;
var
  aKey : Integer;
  aItem : TListItem;
  iCount : Integer;
  aTokens : TStringList;
begin
  ListMacro.Items.Clear;


  aTokens := TStringList.Create;
  for aKey := VK_F2 to VK_F12 do
  begin
    if FKeyOrderItem.MacroKey[aKey] <> '' then
    begin
      aItem := ListMacro.Items.Add;
      aItem.Caption := KeyDesc[aKey];
      iCount := GetTokens(FKeyOrderItem.MacroKey[aKey], aTokens, ',');
      aItem.SubItems.Add(IntToStr(iCount));
      aItem.SubItems.Add( FKeyOrderItem.MacroKey[aKey] );
    end;
  end;

  aTokens.Free;



end;

{    aListItem:=  ListKey.Items.Add;
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
    aListItem.SubItems.Add(aActionItem.KeyDesc);}

function TInputKeyDlg.GetOrderKey(aSymbolType: TKeySymbolType): Boolean;
var
  i : Integer;
  aKeyActionItem : TKeyActionItem;
begin
  Result := False;

  // Active Count
  for i:= 0 to FColumns.Count-1 do
  begin
    aKeyActionItem := TKeyActionItem( FColumns[i] );

    with aKeyActionItem do
    if KeySymbolType = aSymbolType then
    begin
      if KActionType = atNull then Continue;
      FActionMap[ KActionType ].Color := clWhite;
      FActionMap[ KActionType ].Text :=
        GetTextValue( FActionMap[KActionType], KActionType, KeySymbolType) +
        Char( Key );
    end;

  end;

  for i:= 0 to 5 do
    GridSymbolQty.Cells[0,i] := IntToStr( FKeyOrderItem.KQty[i+1, aSymbolType] );


  if EXIST_DEFAULTTIME( FKeyOrderItem.SymbolDelayTime[aSymbolType] ) then  // 숫자에 있다면
  begin
    if FKeyOrderItem.SymbolDelayTime[aSymbolType] = 0 then ComboDelayTime.ItemIndex := 0
    else ComboDelayTime.ItemIndex := FKeyOrderItem.SymbolADelayTime div 50;

    CheckUserDef.Checked := False;
    CheckUserDefClick(Self);
  end else // 없다면
  begin
    CheckUserDef.Checked := True;
    CheckUserDefClick(Self);

    EditDelay.Text := IntToStr(FKeyOrderItem.SymbolDelayTime[aSymbolType]);
  end;

  // 오른쪽 상단에 리스트를 보여주기 위해서
  RefreshList;

  Caption := '[할당키 목록]' + 'A 종목 : ' + FKeyOrderItem.SymbolA.Name  + ' ' +
                               'B 종목 : ' + FKeyOrderItem.SymbolB.Name;

  RadioSymbolType.Items.Strings[0] := FKeyOrderItem.SymbolA.Name;
  RadioSymbolType.Items.Strings[1] := FKeyOrderItem.SymbolB.Name;

  LoadMacroList;
end;

end.
