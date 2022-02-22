unit DMacro;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin, ComCtrls, Dialogs, Commctrl,
  //
  GleConsts,
  KeyOrderAgent, ImgList;

type
  TMacroDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    SpinEditTime: TSpinEdit;
    BtnDelay: TSpeedButton;
    ListKey: TListView;
    Label1: TLabel;
    ImageList1: TImageList;
    ButtonF2: TSpeedButton;
    ButtonF3: TSpeedButton;
    ButtonF4: TSpeedButton;
    ButtonF5: TSpeedButton;
    ButtonF6: TSpeedButton;
    ButtonF7: TSpeedButton;
    ButtonF8: TSpeedButton;
    ButtonF9: TSpeedButton;
    ButtonF10: TSpeedButton;
    ButtonF11: TSpeedButton;
    ButtonF12: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListKeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListKeyDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure BtnDelayClick(Sender: TObject);
    procedure ListKeySelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ButtonFunctionKeyClick(Sender: TObject);
  private
    FActionList : TList;

    FKeyOrderItem: TKeyOrderItem;
    FSelectItem  : TListItem;
    FFunctionKey : array[2..12] of TSpeedButton;
    FCurrentKey  : TSpeedButton;
    FMacroKey    : array[VK_F2..VK_F12] of String;
    FMacroSymbol : array[VK_F2..VK_F12] of String;

    FKeySave : Boolean;

    function FindAction : String;
    procedure SetKeyOrderItem(const Value: TKeyOrderItem);

    function InputCheck : Boolean;

    function InsertKey(aActionItem : TKeyActionItem) : Boolean;
    //function GetMacro(iKey: Integer): String;
    function GetMacroToken: String;
    function GetKeyOrderItem: TKeyOrderItem;

    procedure SaveKey;
    procedure LoadKeyList;

  public

    property KeyOrderItem : TKeyOrderItem read GetKeyOrderItem write SetKeyOrderItem;
  end;

var
  MacroDlg: TMacroDlg;

implementation

uses KOrderConst;//, AppConsts, AppUtils;


{$R *.dfm}

procedure TMacroDlg.FormCreate(Sender: TObject);
begin
  FActionList := TList.Create;

  FFunctionKey[2] := ButtonF2;
  FFunctionKey[2].Tag := VK_F2;
  FFunctionKey[3] := ButtonF3;
  FFunctionKey[3].Tag := VK_F3;
  FFunctionKey[4] := ButtonF4;
  FFunctionKey[4].Tag := VK_F4;
  FFunctionKey[5] := ButtonF5;
  FFunctionKey[5].Tag := VK_F5;
  FFunctionKey[6] := ButtonF6;
  FFunctionKey[6].Tag := VK_F6;
  FFunctionKey[7] := ButtonF7;
  FFunctionKey[7].Tag := VK_F7;
  FFunctionKey[8] := ButtonF8;
  FFunctionKey[8].Tag := VK_F8;
  FFunctionKey[9] := ButtonF9;
  FFunctionKey[9].Tag := VK_F9;
  FFunctionKey[10] := ButtonF10;
  FFunctionKey[10].Tag := VK_F10;
  FFunctionKey[11] := ButtonF11;
  FFunctionKey[11].Tag := VK_F11;
  FFunctionKey[12] := ButtonF12;
  FFunctionKey[12].Tag := VK_F12;

  FKeySave:= True;
end;

procedure TMacroDlg.OKBtnClick(Sender: TObject);
var
  aKey : Integer;
begin

  if not FKeySave then SaveKey;

  for aKey := VK_F2 to VK_F12 do
  begin
    FKeyOrderItem.MacroKey[aKey] := FMacroKey[aKey];
    FKeyOrderItem.MacroSymbol[aKey] := FMacroSymbol[aKey];
  end;

  ModalResult := mrOk;
end;

procedure TMacroDlg.FormDestroy(Sender: TObject);
begin
  FActionList.Free;
end;

function TMacroDlg.FindAction: String;
begin
end;

procedure TMacroDlg.SetKeyOrderItem(const Value: TKeyOrderItem);
var
  aKey : Integer;
begin
  FKeyOrderItem := Value;

  for aKey := VK_F2 to VK_F12 do
  begin
    FMacroKey[aKey] := FKeyOrderItem.MacroKey[aKey];
    FMacroSymbol[aKey] := FKeyOrderItem.MacroSymbol[aKey];
  end;

  FKeyOrderItem.GetKeyActionList(FActionList);
end;

procedure TMacroDlg.ListKeyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : Integer;
  aActionItem : TKeyActionItem;
  bFind : Boolean;
  aListItem : TListItem;
begin
  if Key = 0 then Exit;

  if not InputCheck then
  begin
    ShowMessage('Function Key를 선택하세요');
    Exit;
  end;

  if Key = VK_DELETE then
  begin
    if ListKey.Selected = nil then Exit;

    ListKey.Selected.Free;
  end;


  if FKeySave then FKeySave := False;   

  bFind := False;
  for i:= 0 to FActionList.Count - 1 do
  begin
    aActionItem := TKeyActionItem(FActionList.Items[i]);
    if (aActionItem.Key = Key) and
       (aActionItem.Shift = Shift) then
    begin
      bFind := True;
      Break;
    end;
  end;

  if not bFind then Exit;

  FKeySave := False;

  aListItem:=  ListKey.Items.Add;
  aListItem.Data := aActionItem;

  if ssCtrl in aActionItem.Shift  then
    aListItem.Caption := '^ ' + Char(aActionItem.Key)
  else if ssAlt in aActionItem.Shift then
    aListItem.Caption := '@ ' + Char(aActionItem.Key)
  else
    aListItem.Caption := Char(aActionItem.Key);

  aListItem.SubItems.Add(KEY_DESC[aActionItem.KActionType]);




end;

procedure TMacroDlg.ListKeyDrawItem(Sender: TCustomListView;
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

    if Item.Data = nil then
    begin
      Brush.Color := ODD_COLOR;
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

procedure TMacroDlg.BtnDelayClick(Sender: TObject);
var
  aListItem : TListItem;
  aActionItem : TKeyActionItem;
begin
  //
end;

procedure TMacroDlg.ListKeySelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  FSelectItem := Item;
end;

const
  CH_TAB = #$09;

function TMacroDlg.GetMacroToken: String;
var
  i : Integer;
  aListItem : TListItem;
  aActionItem : TKeyActionItem;
begin

  Result := '';

  for i:=0 to ListKey.Items.Count - 1 do
  begin
    aListItem := ListKey.Items[i];
    aActionItem := TKeyActionItem(aListItem.Data);

    if aActionItem.KActionType <> atNull then
      Result := Result + aActionItem.KeyDesc + ','
    else
      Result := Result + KEY_TYPES[aActionItem.KActionType] + ',';
  end;

end;



function TMacroDlg.InputCheck: Boolean;
var
  i : Integer;
begin
  Result := False;
  
  for i:=2 to 12 do
    if FFunctionKey[i].Down then
    begin
      Result:= True;
      Exit;
    end;

end;



function TMacroDlg.GetKeyOrderItem: TKeyOrderItem;
var
  iKey : Integer;
begin

  for iKey := VK_F2 to VK_F12 do
  begin
    FKeyOrderItem.MacroKey[iKey] := FMacroKey[iKey];
    FKeyOrderItem.MacroSymbol[iKey] := FMacroSymbol[iKey];
  end;

  Result := FKeyOrderItem;
end;

procedure TMacroDlg.ButtonFunctionKeyClick(Sender: TObject);
var
  aBtn : TSpeedButton;
begin
  aBtn := Sender as TSpeedButton;

  if FCurrentKey = nil then
    FCurrentKey := aBtn;

  if (FCurrentKey <> aBtn) then  // 입력사항변경
  begin
    SaveKey;
    FCurrentKey := aBtn;
  end;

  LoadKeyList;
end;

function TMacroDlg.InsertKey(aActionItem: TKeyActionItem): Boolean;
begin
//
end;

// List에 있는 내용을 Key에 저장
procedure TMacroDlg.SaveKey;
var
  iRecCnt : Integer;
  aListItem : TListItem;
  aActionItem : TKeyActionItem;

  i : Integer;
begin

  // 1. clear action
  FMacroKey[FCurrentKey.Tag] := '';
  FMacroSymbol[FCurrentKey.Tag] := '';

  for i:=0 to ListKey.Items.Count - 1 do
  begin
    aListItem := ListKey.Items[i];
    aActionItem := TKeyActionItem(aListItem.Data);

    if aActionItem.KActionType = atNull then
    begin
      // delay time
      FMacroKey[FCurrentKey.Tag] :=  FMacroKey[FCurrentKey.Tag]  + aActionItem.KeyDesc + ',';
      FMacroSymbol[FCurrentKey.Tag] := FMacroSymbol[FCurrentKey.Tag] + ' ' + ',';
      
    end
    else
    begin
      // action
      FMacroKey[FCurrentKey.Tag] := FMacroKey[FCurrentKey.Tag] + KEY_TYPES[aActionItem.KActionType] + ',';


      case aActionItem.KeySymbolType of
        ktSymbolA :  FMacroSymbol[FCurrentKey.Tag] := FMacroSymbol[FCurrentKey.Tag] + 'A' + ',';
        ktSymbolB :  FMacroSymbol[FCurrentKey.Tag] := FMacroSymbol[FCurrentKey.Tag] + 'B' + ',';
      end;

    end
  end;

  FKeySave := True;

end;

// 변경된것 저장
procedure TMacroDlg.LoadKeyList;
var
  aToken, aTokenSymbol : TStringList;
  atAction : TKActionType;
  i, iRecCnt, iRecSymbol : Integer;
  aListItem  : TListItem;
  aActionItem : TKeyActionItem;
begin

  {aToken := TStringList.Create;
  aTokenSymbol := TStringList.Create;

  try
    ListKey.Items.Clear;
    iRecCnt:= GetTokens(FMacroKey[FCurrentKey.Tag], aToken, ',');

    GetTokens(FMacroSymbol[FCurrentKey.Tag], aTokenSymbol, ',');

    if iRecCnt > 0 then
    begin

      for i:=0 to iRecCnt-1 do
      begin
        aListItem:=  ListKey.Items.Add;

        aActionItem := TKeyActionItem.Create;
        aActionItem.Key := 0;

        atAction := KeyActionfindByTyesDesc(aToken[i]);
        aActionItem.KActionType := atAction;



        if atAction = atNull then
        begin
          aActionItem.KeyDesc := aToken[i];
          aListItem.Caption := 'Delay';
          aListItem.SubItems.Add(aToken[i]);
        end
        else
        begin

          // 종목
          if aTokenSymbol[i] = 'A' then
            aActionItem.KeySymbolType := ktSymbolA
          else if aTokenSymbol[i] = 'B' then
            aActionItem.KeySymbolType := ktSymbolB
          else aActionItem.KeySymbolType := ktNone;


          aListItem.SubItems.Add(KEY_DESC[aActionItem.KActionType]);
        end;

        aListItem.Data := aActionItem;
      end;

    end;
  finally
    aToken.Free;
    aTokenSymbol.Free;
  end;}
end;


end.
