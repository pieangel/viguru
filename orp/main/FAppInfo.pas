unit FAppInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,CommCtrl,

  CleStorage, ExtCtrls, GleTypes, CleAccounts,  CleFunds, CleDistributor,

  CleQuoteBroker, CleSymbols, CleFQN, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient, Menus, Buttons

  ;
type
  TFrmAppInfo = class(TForm)
    AppPage: TPageControl;
    sbInfo: TStatusBar;
    tsLog: TTabSheet;
    LogPage: TPageControl;
    tsAccount: TTabSheet;
    lvLog: TListView;
    lvAcnt: TListView;
    Panel1: TPanel;
    lvInvest: TListView;
    edtAcntCode: TLabeledEdit;
    edtAcntName: TLabeledEdit;
    Add: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    btnOK: TButton;
    edtUpdate: TButton;
    tsFund: TTabSheet;
    Panel2: TPanel;
    tvFund: TTreeView;
    Panel5: TPanel;
    Panel8: TPanel;
    btnNew: TButton;
    ListViewFundList: TListView;
    PanelFundTitle: TPanel;
    btnReName: TButton;
    btnRemove: TButton;
    ButtonFundCfg: TSpeedButton;
    PopupMenu1: TPopupMenu;
    delete1: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure AppPageChange(Sender: TObject);
    procedure LogPageChange(Sender: TObject);

    procedure lvLogData(Sender: TObject; Item: TListItem);
    procedure lvLogDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure lvAcntData(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);

    procedure AddClick(Sender: TObject);

    procedure delete1Click(Sender: TObject);
    procedure lvInvestData(Sender: TObject; Item: TListItem);
    procedure lvInvestClick(Sender: TObject);
    procedure lvAcntClick(Sender: TObject);
    procedure edtUpdateClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);

    procedure btnNewClick(Sender: TObject);
    procedure tvFundChange(Sender: TObject; Node: TTreeNode);

    procedure btnReNameClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure ButtonFundCfgClick(Sender: TObject);
    
    procedure ListViewFundListDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);

  private
    FSelectedNode : TTreeNode;
    FFund         : TFund;
    FComboIndex : integer;
    FMarketType : TMarketType;
    FSelected   : TQuote;
    FInvestor   : TInvestor;

    procedure initControls;
    procedure UpdateLog(iKind: integer; bNew : boolean = false);
    procedure UpdateData;
    procedure UpdateAccount;

    function GetVirAccount : TAccount;

    procedure LoadFund;
    procedure SelectedFundNode;

    procedure UpdateFund;
    procedure AddFund(stFundName: string);
    procedure ChangeFundName(stFundName: string);
    procedure DeleteFund(aFund : TFund);
    function FindTreeObj(aObj: TObject): TTreeNode;
    procedure SelectTreeOrg;
    procedure LoadAccountList;
    procedure SetTreeDisplay;
    { Private declarations }
  public
    { Public declarations }

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure WMALogArrived(var msg: TMessage); message WM_LOGARRIVED;

    procedure FundEvent( Sender, Receiver: TObject; DataID: Integer;
                      DataObj: TObject; EventID: TDistributorID);

  end;

var
  FrmAppInfo: TFrmAppInfo;

implementation

uses GAppEnv, FOrpMain, CleLog, GleConsts, FFundConfig, 
  GleLib, CleQuoteTimers;

{$R *.dfm}

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

// acnt db save
procedure TFrmAppInfo.btnApplyClick(Sender: TObject);
begin
  OrpMainForm.AcntLoader.SaveVirAccount;
end;

procedure TFrmAppInfo.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmAppInfo.btnNewClick(Sender: TObject);
var
  stFundName : string;
begin
  if InputQuery('?? ???? ??????', '???????? : ', stFundName) then
  begin
    if stFundName = '' then
    begin
      ShowMessage('???????? ???? ??????.');
      btnNewClick( btnNew );
    end else
    begin
      if gEnv.Engine.TradeCore.Funds.Find( stFundName) = nil then
        // ?????????? ??????..
        AddFund(stFundName)
      else
        ShowMessage('?????? ???? ??????. ???? ????????.');
    end;
  end
end;

procedure TFrmAppInfo.btnRemoveClick(Sender: TObject);
var
  aFund : TFund;
begin
  if FFund = nil then
  begin
    ShowMessage('?????? ?????? ??????????');
    Exit;
  end;

  if MessageDlg('???? "'+FFund.Name+'" ??(??) ???? ?????????????'
    ,mtWarning , mbOKCancel , 0)=mrOK then
    DeleteFund(FFund);
end;

procedure TFrmAppInfo.btnReNameClick(Sender: TObject);
var
  stFundName : string;
begin
  if FFund = nil then
  begin
    ShowMessage('?????? ?????? ??????????');
    Exit;
  end;

    if InputQuery('?????? ????????' , '???????? :', stFundName) then
    begin
      if stFundName = '' then
      begin
        ShowMessage('???????? ???? ??????');
        btnReNameClick(btnReName);
      end else
      begin
        if gEnv.Engine.TradeCore.Funds.Find(stFundName) = nil then
          ChangeFundName(stFundName)
        else
        begin
          ShowMessage('?????? ???? ??????. ???????? ??????????.');
          btnReNameClick(btnReName);
        end;
      end;
    end
end;

procedure TFrmAppInfo.ButtonFundCfgClick(Sender: TObject);
var
  aFundCfgDlg : TFrmFundConfig;
begin
  if FFund = nil then Exit;

  aFundCfgDlg := TFrmFundConfig.Create(Self);
  aFundCfgDlg.Group := FFund;

  if aFundCfgDlg.Open then
  begin
    // save;
    gEnv.Engine.TradeCore.SaveFunds;
    gEnv.Engine.TradeBroker.FundEvent( FFund, FUND_ACNT_UPDATE);
  end;
  aFundCfgDlg.Free;
end;

procedure TFrmAppInfo.AddFund( stFundName : string );
var
  aFund : TFund;
begin
  // ????????
  aFund := gEnv.Engine.TradeCore.Funds.New( stFundName );
  gEnv.Engine.TradeBroker.FundEvent( aFund, FUND_NEW);
  gEnv.Engine.TradeCore.SaveFunds;
end;

procedure TFrmAppInfo.ChangeFundName( stFundName : string );
begin
  if FFund = nil then Exit;
  FFund.Name  := stFundName;
  gEnv.Engine.TradeBroker.FundEvent( FFund, FUND_UPDATED);
end;

procedure TFrmAppInfo.DeleteFund(aFund : TFund);
begin
  //  ???? ????..???????? ??????..
  //gEnv.Engine.TradeCore.FundPositions.Create//
  gEnv.Engine.TradeBroker.FundEvent( aFund, FUND_DELETED );
  gEnv.Engine.TradeCore.FundPositions.DeleteFund( aFund );
  aFund.Free;
end;


procedure TFrmAppInfo.FundEvent(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aFund : TFund;
    aNode, aChild : TTreeNode;
    aItem : TFundItem;
    bExpand : boolean;
    iIndex, I: Integer;
begin
  //
  if ( Receiver <> Self ) or ( DataID <> FUND_DATA ) then Exit;
  if DataObj = nil then Exit;

  aFund := DataObj as TFund;

  case integer( EventID ) of
    FUND_NEW         :
      begin
        aNode := tvFund.Items.Add( nil, aFund.Name ) ;
        aNode.Data  := aFund;
      end ;
    FUND_DELETED     :
      begin
        aNode := FindTreeObj(aFund);
        if aNode = nil then Exit;
        aNode.Free;
        SelectTreeOrg;
      end;
    FUND_UPDATED     :   // ???? ???? ????
      begin
        aNode := FindTreeObj(aFund);
        if aNode = nil then Exit;
        aNode.Text  := aFund.Name;
      end;
    FUND_ACNT_UPDATE :
      begin
        aNode := FindTreeObj(aFund);
        if aNode = nil then Exit;
        aNode.DeleteChildren;
        bExpand := aNode.Expanded;

        for I := 0 to aFund.FundItems.Count - 1 do
        begin
          aItem   := aFund.FundItems.FundItem[i];
          aChild  := tvFund.Items.AddChildObject( aNode, aItem.Account.Name, aItem );
        end;

      end;
  end;

  SetTreeDisplay;
end;

procedure TFrmAppInfo.SetTreeDisplay;
var
  i , j : Integer;
  aParentNode , aChildNode : TTreeNode;
begin
  for i := 0 to tvFund.Items.Count-1 do
  begin
    aParentNode := tvFund.Items[i];
    for j := 0 to aParentNode.Count-1 do
    begin
      aChildNode := aParentNode.Item[j];
      aChildNode.Text := TFundItem(aChildNode.Data).Account.Code + ' ' +
                         TFundItem(aChildNode.Data).Account.Name;

    end;
  end;

end;

function TFrmAppInfo.FindTreeObj(aObj: TObject): TTreeNode;
var
  i : Integer;
begin
  Result := nil;

  for i:=0 to tvFund.Items.Count-1 do
    if aObj = tvFund.Items[i].Data then
    begin
      Result := tvFund.Items[i];
      Break;
    end;
end;

procedure TFrmAppInfo.SelectTreeOrg;
begin
  if tvFund.Items.Count > 0 then
  begin
    tvFund.GetNodeAt(0,0).Selected := True;
    tvFundChange(tvFund,tvFund.GetNodeAt(0,0));
  end;
end;


procedure TFrmAppInfo.btnOKClick(Sender: TObject);
begin
  btnApplyClick( nil );
  Close;
end;



function TFrmAppInfo.GetVirAccount: TAccount;
var
  aItem : TListItem;
begin
  aItem :=  lvAcnt.Items.Item[ lvAcnt.ItemIndex];
  Result := TAccount( aItem.Data );
end;

procedure TFrmAppInfo.UpdateAccount;
begin
  lvInvest.Items.Count  := gEnv.Engine.TradeCore.Investors.Count;
  lvInvest.Invalidate;

  if (lvInvest.Items.Count > 0) then
  begin
    lvInvest.ItemIndex  := 0;
    lvInvestClick( lvInvest );
  end;

end;

procedure TFrmAppInfo.delete1Click(Sender: TObject);
var
  i : integer;
  aAcnt : TAccount ;
  dOpen : double;
  iOpen : integer;
begin
  if FInvestor = nil then Exit;

  aAcnt := TAccount( lvAcnt.Selected.Data );
  if (aAcnt <> nil) and ( FInvestor <> nil ) then
    if aAcnt.DefAcnt then
      ShowMessage('???? ?????? ?????? ????')
    else begin

      dOpen := gEnv.Engine.TradeCore.Positions.GetOpenPL( aAcnt, iOpen);

      if ( dOpen <> 0 ) or ( iOpen <> 0 ) then
      begin
        ShowMessage('???? ???? ?????? ???????? ???? ');
        Exit;
      end;

      if FInvestor.Accounts.DeleteAccount( aAcnt ) then
        lvAcnt.Selected.Free;

      lvAcnt.Items.Count  := FInvestor.Accounts.Count; //  gEnv.Engine.TradeCore.Accounts.Count;
      lvAcnt.Invalidate;
      //if MyAccount.DeleteAccount( aAcnt ) then
      //  lvAcnt.Selected.Free;
      gEnv.Engine.TradeBroker.AccountEvent( FInvestor, ACCOUNT_DELETED);
    end;
end;




procedure TFrmAppInfo.edtUpdateClick(Sender: TObject);
var
  stCode, stName : string;
  aAcnt : TAccount;
  aPos  : TPosition;
  iOpen : integer;
  dOpen : double;
begin
  //
  stCode  := edtAcntCode.Text;
  stName  := edtAcntName.Text;
  aAcnt   := GetVirAccount;
  //
  if ( stCode = '' ) or ( stName = '' ) or ( aAcnt = nil ) or ( FInvestor = nil ) then Exit;
  //
  if aAcnt.DefAcnt then
  begin
    ShowMessage('???? ?????????? ?????? ????');
    Exit;
  end;

  if ( aAcnt.Code <> stCode ) and  (FInvestor.Accounts.Find( stCode ) <> nil) then
  begin
    ShowMessage('???????? ??');
    Exit;
  end;

  dOpen := gEnv.Engine.TradeCore.Positions.GetOpenPL( aAcnt, iOpen);

  if ( dOpen <> 0 ) or ( iOpen <> 0 ) then
  begin
    ShowMessage('???? ???? ?????? ???????? ???? ');
    Exit;
  end;

  aAcnt.Update( stCode, stName );
  lvAcnt.Invalidate;

  gEnv.Engine.TradeBroker.AccountEvent( FInvestor, ACCOUNT_UPDATED);

end;

procedure TFrmAppInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmAppInfo.FormCreate(Sender: TObject);
begin
  initControls;
  FSelected   := nil;
  FComboIndex := 0;

  FInvestor := nil;

  UpdateAccount;
  LogPageChange( nil );


  FSelectedNode := nil;
  FFund         := nil;

  // ??????
  AppPage.Pages[0].TabVisible := false;

  if gEnv.Beta then
    AppPage.Pages[1].TabVisible := false;

  gEnv.Engine.TradeBroker.Subscribe( Self, FUND_DATA, FundEvent );


end;

procedure TFrmAppInfo.FormDestroy(Sender: TObject);
begin

  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;



procedure  TFrmAppInfo.initControls;
var
  i : integer;
  aTab  : TTabSheet;
begin

  // Log page init;
  for i := 0 to Integer(High( LogString)) do
  begin
    aTab  := TTabSheet.Create( self );
    aTab.Caption  := LogString[ TLogKind(i) ];
    aTab.Name     := LogTabName[ TLogKind(i) ];
    aTab.PageControl  := LogPage;
  end;

  LogPage.ActivePageIndex := 1;

end;


procedure TFrmAppInfo.LoadEnv(aStorage: TStorage);
begin

end;

procedure TFrmAppInfo.LogPageChange(Sender: TObject);
begin
  //lvLog.Clear;
  UpdateLog( 0, true );
end;


procedure TFrmAppInfo.lvAcntClick(Sender: TObject);
var
  i : integer;
  aAcnt : TAccount;
  aInvest : TInvestor;
  aItem : TListItem;
begin

  aItem :=  lvAcnt.Items.Item[ lvAcnt.ItemIndex];
  if aItem = nil then Exit;  

  aAcnt := TAccount( aItem.Data );
  if aAcnt = nil then Exit;

  edtAcntCode.Text  := aAcnt.Code;
  edtAcntName.Text  := aAcnt.Name;

end;

procedure TFrmAppInfo.lvAcntData(Sender: TObject; Item: TListItem);
var
  aAcnt : TAccount;
  stTxt : string;
  i : Integer;
begin
  if FInvestor = nil then Exit;

  aAcnt := FInvestor.Accounts.Accounts[Item.Index];
  if aAcnt = nil then Exit;

  Item.Data := aAcnt;
  Item.Caption  := aAcnt.Code;

  with ITem do
  begin
    SubItems.Add( aAcnt.Name );
    SubItems.Add(  ifThenStr( aAcnt.DefAcnt, '????', ' ')  );
  end;
end;     


procedure TFrmAppInfo.lvInvestClick(Sender: TObject);
var
  i : integer;
  aAcnt : TAccount;
  aInvest : TInvestor;
  aItem : TListItem;
begin

  aItem :=  lvInvest.Items.Item[ LvInvest.ItemIndex];
  if aItem = nil then Exit;
  
  aInvest := TInvestor( aItem.Data );
  if aInvest = nil then Exit;

  if FInvestor = aInvest then Exit;
  FInvestor := aInvest;

  lvAcnt.Items.Clear;
  lvAcnt.Items.Count  := aInvest.Accounts.Count; //  gEnv.Engine.TradeCore.Accounts.Count;
  lvAcnt.Invalidate;

  if lvAcnt.Items.Count > 0 then
  begin
    lvAcnt.Selected := lvAcnt.Items[0];
    lvAcnt.ItemFocused := lvAcnt.Items[0];
  end;

  aACnt := TAccount( lvAcnt.Selected.Data );
  if aAcnt <> nil then
  begin
    edtAcntCode.Text  := aACnt.Code;
    edtAcntname.Text  := aAcnt.Name;
  end;

end;

procedure TFrmAppInfo.lvInvestData(Sender: TObject; Item: TListItem);
var
  aInvest : TInvestor;
  stTxt : string;
  i : Integer;

begin
  if gEnv.Engine = nil then Exit;

  aInvest := gEnv.Engine.TradeCore.Investors.Investor[Item.Index];
  if aInvest = nil then Exit;

  Item.Data := aInvest;
  Item.Caption  := aInvest.Code;

  with ITem do
  begin
    SubItems.Add( aInvest.Name );
    //SubItems.Add( aInvest.Division );
  end;

end;

procedure TFrmAppInfo.lvLogData(Sender: TObject; Item: TListItem);
var
  aItem : TAppLogItem;
begin


  aItem := gAppLog.LogList[ TLogKind(LogPage.ActivePageIndex) ].LogItem[Item.index];
  if aItem = nil then Exit;

  Item.Data  := aItem;
  Item.Caption := FormatDateTime( 'nn:ss:zzz', aItem.LogTime );

  Item.SubItems.Add( aItem.LogSource );
  Item.SubItems.Add( aItem.LogTitle );
  Item.SubItems.Add( aItem.LogDesc );
end;

procedure TFrmAppInfo.lvLogDrawItem(Sender: TCustomListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState);
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

procedure TFrmAppInfo.AddClick(Sender: TObject);
var
  stCode, stName : string;
  aAcnt : TAccount;
begin
  //
  stCode  := edtAcntCode.Text;
  stName  := edtAcntName.Text;
  //
  if ( stCode = '' ) or ( stName = '' ) or ( FInvestor = nil ) then Exit;
  //
  if FInvestor.Accounts.Find( stCode ) <> nil then
  begin
    ShowMessage('???????? ??');
    Exit;
  end;

  aAcnt := FInvestor.Accounts.New( stCode, stName, mtFutures, gEnv.ConConfig.Password );
  aAcnt.InvestCode  := FInvestor.Code;
  aAcnt.LogIdx      := FInvestor.Accounts.Count-1;
  //
  //edtAcntCode.Text  := FInvestor.ShortCode + '-';
  //edtAcntName.Text  := FInvestor.Name + '-';

  lvAcnt.Items.Count  := FInvestor.Accounts.Count; //  gEnv.Engine.TradeCore.Accounts.Count;
  lvAcnt.Invalidate;

  gEnv.Engine.TradeBroker.AccountEvent( FInvestor, ACCOUNT_NEW);

end;

procedure TFrmAppInfo.AppPageChange(Sender: TObject);
begin
  //
  if AppPage.ActivePage = tsFund then
    UpdateFund;

end;

procedure TFrmAppInfo.SaveEnv(aStorage: TStorage);
begin

end;




procedure TFrmAppInfo.WMALogArrived(var msg: TMessage);
begin
  if AppPage.ActivePage <> tsLog then
    Exit;

  if LogPage.ActivePageIndex <> msg.WParam then
    Exit;

  //lvLog.Clear;
  UpdateLog( msg.WParam );
end;


procedure TFrmAppInfo.UpdateData;
begin
  lvAcnt.Refresh;
end;

procedure TFrmAppInfo.UpdateLog( iKind : integer; bNew : boolean);
var
  stLine : string;
  aColor : TColor;
  iLast, i : integer;
  aItem : TAppLogItem;
  aList : TListItem;
  aKind : TLogKind;
begin

  if gAppLog = nil then Exit;
  aKind := TLogKind( LogPage.ActivePageIndex );

  if aKind = lkDebug then
  begin
    lvLog.Items.Count := 0;
    lvLog.Invalidate;
    Exit;
  end;

  if bNew then
  begin
    //lvLog.Items.Clear;
    lvLog.Items.Count := gAppLog.LogList[ aKind ].Count;
    lvLog.Invalidate;
  end else
  begin
    aList := lvLog.Items.Add;
    aItem := gAppLog.LogList[ aKind ].LogItem[0];
    aList.Data  := aItem;
    aList.Caption := FormatDateTime( 'nn:ss:zzz', aItem.LogTime );

    aList.SubItems.Add( aItem.LogSource );
    aList.SubItems.Add( aItem.LogTitle );
    aList.SubItems.Add( aItem.LogDesc );
    lvLog.Refresh;
  end;

  if lvLog.Items.Count > 0 then
  begin
    lvLog.Selected := lvLog.Items[0];
    lvLog.ItemFocused := lvLog.Items[0];
  end;

end;

procedure TFrmAppInfo.UpdateFund;
begin
  LoadFund;
end;


procedure TFrmAppInfo.tvFundChange(Sender: TObject; Node: TTreeNode);
begin

  if Node = nil then
  begin
    ListViewFundList.Items.Clear;
    Exit;
  end;

  if FSelectedNode <> Node then
  begin
    FSelectedNode := Node;
    SelectedFundNode;
  end;
end;

procedure TFrmAppInfo.SelectedFundNode;
var
  aFund : TFund;
begin

  if FSelectedNode.Level = 0 then
  begin
    aFund := TFund( FSelectedNode.Data );
    if aFund = nil then Exit;
    FFund := aFund;
    LoadAccountList;
  end;
end;

procedure TFrmAppInfo.ListViewFundListDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  ListViewDrawItem(Sender as TListView , Item , Rect , State , nil);
end;

procedure TFrmAppInfo.LoadAccountList;
var
  i : integer;
  aListItem : TListItem;
begin
  ListViewFundList.Items.Clear;
  for i := 0 to FFund.FundItems.Count-1 do
  begin
    aListItem := ListViewFundList.Items.Add;
    aListItem.Caption := FFund.FundItems[i].Account.Code;
    aListItem.Data := FFund.FundItems[i].Account;
    aListItem.SubItems.Add( FFund.FundItems[i].Account.Name );
    aListItem.SubItems.Add( Format('%d',[ FFund.FundItems[i].Multiple]) );
  end;
end;

procedure TFrmAppInfo.LoadFund;
var
  i, j : integer;
  aFund : TFund;
  aFundItem : TFundItem;
  aFundTree : TTreeNode;

begin

  tvFund.Items.Clear;
  ListViewFundList.Items.Clear;

  for I := 0 to gEnv.Engine.TradeCore.Funds.Count - 1 do
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Funds[i];
    if aFund = nil then Continue;

    aFundTree := tvFund.Items.AddObject( nil, aFund.Name, aFund  );

    for j := 0 to aFund.FundItems.Count - 1 do
    begin
      aFundItem := aFund.FundItems.FundItem[j];
      tvFund.Items.AddChildObject(  aFundTree,
        aFundItem.Account.Code + ' '+aFundItem.Account.Name, aFundItem );
    end;
  end;

  if tvFund.Items.Count > 0 then
  begin
    tvFund.Items[0].Selected := true;
    tvFundChange( tvFund, tvFund.Items[0] );
  end;

end;



end.
