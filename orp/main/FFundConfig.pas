unit FFundConfig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ComCtrls, CommCtrl,Math,  GleConsts,

  //
  CleAccounts , CleFunds , StdCtrls, Buttons, ExtCtrls, ImgList
  ;

type
  TFrmFundConfig = class(TForm)
    ListViewUnRegDetails: TListView;
    ListViewRegDetails: TListView;
    ButtonConfirm: TButton;
    ButtonCancel: TButton;
    ButtonToRight: TSpeedButton;
    ButtonToRightAll: TSpeedButton;
    ButtonToLeft: TSpeedButton;
    ButtonToLeftAll: TSpeedButton;
    ButtonUpper: TSpeedButton;
    ButtonLower: TSpeedButton;
    Label5: TLabel;
    Label6: TLabel;
    Panel2: TPanel;
    EditFundName: TEdit;
    Label7: TLabel;
    PanelSummary: TPanel;
    Label8: TLabel;
    GroupBox1: TGroupBox;
    Label9: TLabel;
    EditMultiple: TEdit;
    Label15: TLabel;
    PanelSumMultiple: TPanel;
    PanelSumRatio: TPanel;
    PanelAccountNo: TPanel;
    Label1: TLabel;
    PanelEachRatio: TPanel;
    procedure ButtonToRightClick(Sender: TObject);
    procedure ButtonToRightAllClick(Sender: TObject);
    procedure ButtonToLeftClick(Sender: TObject);
    procedure ButtonToLeftAllClick(Sender: TObject);
    procedure ListViewRegDetailsKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewRegDetailsSelectItem(Sender: TObject;
      Item: TListItem; Selected: Boolean);
    procedure EditMultipleChange(Sender: TObject);
    procedure ButtonConfirmClick(Sender: TObject);
    procedure ListViewUnRegDetailsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ListViewRegDetailsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ButtonUpperClick(Sender: TObject);
    procedure ListViewUnRegDetailsDblClick(Sender: TObject);
    procedure ListViewRegDetailsDblClick(Sender: TObject);
    procedure EditMultipleClick(Sender: TObject);

  private
    { Private declarations }

    FGroup: TFund;
    procedure SetFormCaption;
    procedure RecalcMultipleRatio;

  public
    { Public declarations }
    property Group : TFund read FGroup write FGroup;

    function Open : Boolean;
    procedure RefreshRegDetails;
    procedure RefreshUnRegDetails;
    procedure MoveOtherListView(aSource , aTarget : TListView ; iMoveIndex : Integer);
  end;

var
  FrmFundConfig: TFrmFundConfig;

implementation

uses
  GAppEnv
  ;

{$R *.DFM}

{ TFundConfig }
procedure ListViewDrawItem(ListView: TListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState; Statusbar : TStatusBar);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;

begin
  Rect.Bottom := Rect.Bottom-1;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    begin
      Font.Color := clBlack;
      if Item.Index mod 2 = 1 then
        Brush.Color := FIXED_COLOR
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

      //if ListView.SmallImages = nil then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 2, iY, Item.Caption);
      {
      else
        TextRect(
            Classes.Rect(Rect.Left + ListView.SmallImages.Width,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + ListView.SmallImages.Width + 2, iY, Item.Caption);
      }
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
      end;
      TextRect(
          Classes.Rect(iLeft, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);

    end;

  end;

  // additional service
  if StatusBar <> nil then
  begin
    for i:=0 to StatusBar.Panels.Count-1 do
      if i < ListView.Columns.Count then
        StatusBar.Panels[i].Width := ListView_GetColumnWidth(ListView.Handle,i)
  end;


end;



procedure TFrmFundConfig.MoveOtherListView(aSource, aTarget: TListView;
  iMoveIndex: Integer);
var
  i : Integer;
  aSourceItem , aTargetItem : TListItem;
begin
  if (aSource = nil) or (aTarget = nil) then Exit;
  if aSource.Items.Count-1 >iMoveIndex then Exit;

  aTargetItem := aTarget.Items.Add;
  aSourceItem := aSource.Items[i];

end;

function TFrmFundConfig.Open: Boolean;
begin
  EditFundName.Text := FGroup.Name;
  SetFormCaption;
  RefreshRegDetails;
  RefreshUnRegDetails;

  if ShowModal=mrOK then
    Result := True
  else
    Result := False;

end;

procedure TFrmFundConfig.RefreshRegDetails;
var
  i : Integer;
  aListItem : TListItem;
  aAccount : TAccount;

begin
  if FGroup = nil then Exit;
  ListViewRegDetails.Items.Clear;

  for i := 0 to FGroup.FundItems.Count-1 do
  begin
    aAccount := FGroup.FundItems.FundItem[i].Account;
    aListItem := ListViewRegDetails.Items.Add;
    aListItem.Caption := aAccount.Code;
    aListItem.SubItems.Add(aAccount.Name);
    aListItem.SubItems.Add( Format('%d', [FGroup.FundItems[i].Multiple] ));
    aListItem.SubItems.Add('');
    aListITem.Data := aAccount;
  end;

  RecalcMultipleRatio;

end;

procedure TFrmFundConfig.RefreshUnRegDetails;
var
  i : Integer;
  aListItem : TListItem;
  aAccount : TAccount;
begin

  ListViewUnRegDetails.Items.Clear;

  for i := 0 to gEnv.Engine.TradeCore.Accounts.Count -1 do
  begin
    aAccount := gEnv.Engine.TradeCore.Accounts.Accounts[i];
    if FGroup.FundItems.Find2(aAccount) = -1 then
    begin
      aListItem := ListViewUnRegDetails.Items.Add;
      aListItem.Caption := aAccount.Code;
      aListItem.SubItems.Add(aAccount.Name);
      aListItem.Data := aAccount;
    end;
  end;

end;

procedure TFrmFundConfig.ButtonToRightClick(Sender: TObject);
var
  aListItem , aSelected : TListItem;
  aAccount : TAccount;
begin
  aSelected := ListViewUnRegDetails.Selected;
  if Assigned(aSelected) then
  begin
    aAccount := TAccount(aSelected.Data);
    aListItem := ListViewRegDetails.Items.Add;
    aListItem.Data := aAccount;
    aListItem.Caption := aAccount.Code;
    aListItem.SubItems.Add(aAccount.Name);
    aListItem.SubItems.Add('1');
    aListItem.SubItems.Add('');
    ListViewUnRegDetails.Items.Delete(aSelected.Index);
    RecalcMultipleRatio;

  end;
end;

procedure TFrmFundConfig.ButtonToRightAllClick(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to ListViewUnRegDetails.Items.Count-1 do
  begin
    ListViewUnRegDetails.Selected := ListViewUnRegDetails.Items[0];
    ButtonToRightClick(ButtonToRight);
  end;

end;

procedure TFrmFundConfig.ButtonToLeftClick(Sender: TObject);
var
  aSelected , aListItem : TListItem;
  aAccount : TAccount;
begin
  aSelected := ListViewRegDetails.Selected;
  if Assigned(aSelected) then
  begin
    aAccount := TAccount(aSelected.Data);
    aListItem := ListViewUnRegDetails.Items.Add;
    aListItem.Data := aAccount;
    aListItem.Caption := aAccount.Code;
    aListItem.SubItems.Add(aAccount.Name);
    ListViewRegDetails.Items.Delete(aSelected.Index);
    RecalcMultipleRatio;

  end;

end;

procedure TFrmFundConfig.ButtonToLeftAllClick(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to ListViewRegDetails.Items.Count-1 do
  begin
    ListViewRegDetails.Selected := ListViewRegDetails.Items[0];
    ButtonToLeftClick(ButtonToLeft);
  end;
end;

procedure TFrmFundConfig.ListViewRegDetailsKeyPress(Sender: TObject;
  var Key: Char);
begin
  {
  if ListViewRegDetails.Selected = nil then Exit;
  //if (('0'<=Key) and (Key<='9')) or (Key='.') then
  //gLog.Add(lkDebug , 'ListViewKeyPress' , '', '',nil);

  if Key in ['0'..'9','.'] then
  with EditMultiple do
  begin
    AutoSelect := False;
    SelectAll;
    SelText := Key;
    SetFocus;
    AutoSelect := True;
  end;
  }
end;

procedure TFrmFundConfig.ListViewRegDetailsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  aAccount : TAccount;
begin

  if not(Selected) or (Item = nil) or (Item.Data=nil) then
  begin
    PanelAccountNo.Caption := '';
    EditMultiple.Text := '';
    PanelEachRatio.Caption := '0% ';
  end else
  begin
    aAccount := TAccount(Item.Data);
    PanelAccountNo.Caption := aAccount.Code+ '  '+aAccount.Name + ' ';
    EditMultiple.Text := Item.SubItems[1];
    PanelEachRatio.Caption := Item.SubItems[2]+' ';
  end;

end;

procedure TFrmFundConfig.EditMultipleChange(Sender: TObject);
var
  iValue : Double;
  stTemp : String;
begin
  if EditMultiple.Text = '' then Exit;
  if ListViewRegDetails.Selected <> nil then
  begin
    try
      stTemp := EditMultiple.Text;
      if stTemp = '-' then Exit;

      iValue := StrToIntDef(EditMultiple.Text, 1);
      if (-1000 >= iValue) or (iValue >= 1000) then
      begin
        ShowMessage('범위를 벗어났습니다'
          + #13 + '-999 에서 999사이의 정수를 입력하세요');
        EditMultiple.Clear;
        Exit;
      end;
      ListViewRegDetails.Selected.SubItems[1] := EditMultiple.Text;
      RecalcMultipleRatio;
      PanelEachRatio.Caption := ListViewRegDetails.Selected.SubItems[2]+' ';
    except
      ShowMessage('잘못된 수를 입력하셨습니다');
      EditMultiple.Clear;
    end;
  end else
  begin
    EditMultiple.Text := '';
    ShowMessage('계좌를 선택하지 않으셨습니다' + #13 + ' 계좌를 선택하세요');
  end;


end;

procedure TFrmFundConfig.ButtonConfirmClick(Sender: TObject);
var
  i : Integer;
  aListItem : TListItem;
begin
  if EditFundName.Text <> FGroup.Name then
  begin
    if gEnv.Engine.TradeCore.Funds.Find(EditFundName.Text) <> nil then
    begin
      ShowMessage('중복된 이름의 펀드가 있습니다.'+#13+'펀드명을 수정하세요');
      EditFundName.SetFocus;
      Exit;
    end;
  end;

  FGroup.FundItems.Clear;
  for i := 0 to ListViewRegDetails.Items.Count-1 do
  begin
    aListItem := ListViewRegDetails.Items[i];
    with FGroup.FundItems.AddFundItem( TAccount( aListItem.Data) ) do
      Multiple  := StrToIntDef(aListItem.SubItems[1],1);

  end;
  if Length(EditFundName.Text) > 0 then
    FGroup.Name := EditFundName.Text;

  ModalResult := mrOk;

end;

procedure TFrmFundConfig.SetFormCaption;
begin
  Caption := '펀드설정창 : ' + FGroup.Name;
end;

procedure TFrmFundConfig.ListViewUnRegDetailsDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListViewDrawItem(Sender as TListView , Item , Rect , State, nil);
end;

procedure TFrmFundConfig.ListViewRegDetailsDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListViewDrawItem(Sender as TListView , Item , Rect , State, nil);
end;

procedure TFrmFundConfig.ButtonUpperClick(Sender: TObject);
var
  aSelected , aTarget : TListItem;
  iMove , iTarget: Integer;
  aAccount : TObject;
  stMultiple : String;
begin
  if ListViewRegDetails.Selected = nil then Exit;
  aSelected := ListViewRegDetails.Selected;
  case (Sender as TSpeedButton).Tag of
    100 :
      iMove := -1;
    200 :
      iMove := 1;
  end;

  iTarget := aSelected.Index + iMove;
  if (iTarget < 0) or (iTarget > ListViewRegDetails.Items.Count-1) then Exit;

  aTarget := ListViewRegDetails.Items[iTarget];
  aAccount := aTarget.Data;
  aTarget.Data := aSelected.Data;
  aSelected.Data := aAccount;
  stMultiple := aSelected.SubItems[1];

  with TAccount(aSelected.Data) do
  begin
    aSelected.Caption := Code;
    aSelected.SubItems[0] := Name;
    aSelected.SubItems[1] :=  aTarget.SubItems[1];
  end;

  with TAccount(aTarget.Data) do
  begin
    aTarget.Caption := Code;
    aTarget.SubItems[0] := Name;
    aTarget.SubItems[1] := stMultiple;
  end;
  ListViewRegDetails.Selected := aTarget;


end;

procedure TFrmFundConfig.ListViewUnRegDetailsDblClick(Sender: TObject);
begin
  ButtonToRightClick(ButtonToRight);
end;

procedure TFrmFundConfig.ListViewRegDetailsDblClick(Sender: TObject);
begin
  ButtonToLeftClick(ButtonToLeft);
end;

procedure TFrmFundConfig.RecalcMultipleRatio;
var
  i : Integer;
  aListItem : TListItem;
  iMultipleSum : integer;
  dRatio , dRatioTotal : Double;
begin
  iMultipleSum := 0;
  dRatioTotal := 0.0;
  for i := 0 to ListViewRegDetails.Items.Count-1 do
  begin
    aListItem := ListViewRegDetails.Items[i];
    iMultipleSum := iMultipleSum + StrToIntDef(aListItem.SubItems[1],1);
  end;

  for i := 0 to ListViewRegDetails.Items.Count-1 do
  begin
    aListItem := ListViewRegDetails.Items[i];
    if iMultipleSum = 0 then
      aListItem.SubItems[2] := '0%'
    else
    begin
      dRatio := StrToFloatDef(aListItem.SubItems[1],1) / iMultipleSum;
      dRatioTotal := dRatioTotal + dRatio*100;
      aListItem.SubItems[2] := IntToStr(round(dRatio*100))+'%';
    end;
  end;
  PanelSumMultiple.Caption := Format('%d', [iMultipleSum])+' ';
  PanelSumRatio.Caption := IntToStr(round(dRatioTotal))+'% ';

end;

procedure TFrmFundConfig.EditMultipleClick(Sender: TObject);
begin
  EditMultiple.SelectAll;
end;


end.
