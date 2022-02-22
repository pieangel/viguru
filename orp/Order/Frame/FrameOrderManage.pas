unit FrameOrderManage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  CleQuoteBroker, CleOrders, CleSymbols, CleAccounts,  CleDistributor,
  GleConsts, GleTypes, GleLib, CleOrderManager, CleVolStopmanager,  CleFORMOrderItems,
  CleFORMConst, CleFormManager, CleFrontOrderIF, Buttons, CleStorage;
const
  H_ORDER_TOP = 103;
  H_ORDER_CLIENT = 50;
type
  TFraOrderManage = class(TFrame)
    plLeft: TPanel;
    gbOrder: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    cbRun: TCheckBox;
    edtAsk2: TEdit;
    edtBid2: TEdit;
    Button2: TButton;
    udAsk2: TUpDown;
    udBid2: TUpDown;
    cbVolStop: TCheckBox;
    gbPos: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    chSavePosRun: TCheckBox;
    edtAsk: TEdit;
    edtBid: TEdit;
    edtAskPos: TEdit;
    Button1: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    edtBidPos: TEdit;
    udAsk: TUpDown;
    udBid: TUpDown;
    udAskPos: TUpDown;
    udBidPos: TUpDown;
    plRight: TPanel;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    edtAllCnlQty: TEdit;
    edtAllCnlInterval: TEdit;
    Button3: TButton;
    Button4: TButton;
    CnlTimer: TTimer;
    stBar: TStatusBar;
    cbUseMoth: TCheckBox;
    lbTag: TLabel;
    procedure cbUseMothClick(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure cbVolStopClick(Sender: TObject);
    procedure edtAsk2Change(Sender: TObject);
    procedure edtAsk2KeyPress(Sender: TObject; var Key: Char);
    procedure chSavePosRunClick(Sender: TObject);
    procedure CnlTimerTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure edtAskChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure edtAskPosKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FAccount  : TAccount;
    FSymbol   : TSymbol;
    FVolStopsList : TList;

    FOrderItem : TOrderItem;
    FCnt : integer;
    FJangJungIF : TFrontOrderIF;
    FOrderManIF : TFrontOrderIF;
    FFormID : integer;

    procedure CheckVolStop(bCheck: boolean);
    procedure SendMoth;
  public
    { Public declarations }
    FAccountGroup : TAccountGroup;
    FormManager :  TFrontManager;
    Param  : TFORMParam;
    IfList : TList;
    FDataDiv : integer;
    procedure FrameCreate(iTag, iFormID : integer);
    procedure FrameClose( bHide : boolean );
    procedure FrameSymbolChange( aObject : TObject );
    procedure FrameAccountChange( aObject : TObject );
    procedure ShowState(index: integer; value: string);
    procedure ParamChange(aIF : TFrontOrderIF);
    procedure Notify(Sender: TObject; value: boolean);

    procedure SetDefaultParam;
    procedure DoLog(Sender: TObject; Value: String);
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

implementation

uses
  GAppEnv, CleFQN, CleQuoteTimers, CleJangJungManager;
{$R *.dfm}

{ TFraOrderManage }

procedure TFraOrderManage.Button2Click(Sender: TObject);
var
  stName : string;
  iTag : integer;
begin
  // 로그 보기
  iTag := TButton( Sender ).Tag;
  case iTag of
    0 :   stName := Format( '%s/%s.log', [ WIN_JJUNG,
        FormatDateTime( 'yyyymmdd', GetQuoteDate)
        ]);
    1 :   stName := Format( '%s/%s.log', [ WIN_JPOS,
        FormatDateTime( 'yyyymmdd', GetQuoteDate)
        ]);
    2 :  stName := Format( '%s/%s.log', [ WIN_LOSS,
        FormatDateTime( 'yyyymmdd', GetQuoteDate)
        ]);

  end;

  ShowNotePad( Handle, stName );
end;

procedure TFraOrderManage.Button3Click(Sender: TObject);
var
  bOK : boolean;
  stLog : string;
  i : integer;
  aVols  : TJackPotItems;
begin
  if ( FAccount = nil ) or ( FSymbol = nil ) then
  begin
    ShowMessage( '계좌 or 종목설정이 잘못되었음' );
    Exit;
  end;

  FOrderItem := FormManager.OrderItems.Find( FAccount, FSymbol );
  if FOrderItem = nil then
  begin
    ShowMessage( '취소할 주문이 없음' );
    Exit;
  end;

  if ( edtAllCnlQty.Text  = '' )  or
    ( edtAllCnlInterval.Text = '' ) then
  begin
    ShowMessage( '조건 설정이 잘못됐음' );
    Exit;
  end;

  GroupBox1.Color := clRed;
  ShowState(0, '전체 취소 중');

  stLog := Format('전체취소 클릭 : %s(%s) : %s, %s',
    [
      FAccount.Code,
      FSymbol.ShortCode,
      edtAllCnlQty.Text ,
      edtAllCnlInterval.Text
    ]
    );
  gEnv.EnvLog( WIN_LOSS, stLog );

  // clear 잔량 스탑
  try

    FVolStopsList.Clear;
    gEnv.Engine.TradeCore.VolStops.FindBoard( FAccount, FSymbol, FVolStopsList );

    for I := 0 to FVolStopsList.Count - 1 do
    begin
      aVols := TjackPotItems( FVolStopsList.Items[i] );
      aVols.OrderBoard.ClearJackPotOrder;
    end;

  finally
    stLog := Format('잔량스탑 쉬소 : %s(%s) ',
      [
        FAccount.Code,
        FSymbol.ShortCode
      ]
      );
    gEnv.EnvLog( WIN_LOSS, stLog );
  end;



  FCnt  := StrToInt( edtAllCnlQty.Text ) ;
  if not cbUseMoth.Checked then
    bOK := FormManager.DoCancels( FOrderItem, 0, FCnt   );

  CnlTimer.Interval := StrToIntDef( edtAllCnlInterval.Text , 1000 );
  CnlTimer.Enabled  := bOK;
  Button3.Enabled := not bOK ;

  if not bOK then
  begin
    ShowState(0, '전체 취소 완료');
    GroupBox1.Color := clBtnFace;
    Button3.Enabled := true;
    stLog := '전체 취소 완료';
    gEnv.EnvLog( WIN_LOSS, stLog );
  end;

  Param.DataType := dtTotalCancel;
  Param.Cnt := StrToIntDef(edtAllCnlQty.Text, 10);
  Param.Interval := StrToIntDef(edtAllCnlInterval.Text, 300);
  SendMoth;
end;

procedure TFraOrderManage.cbRunClick(Sender: TObject);
var
  bCheck : boolean;
begin

  bCheck  := cbRun.Checked;
  if FJangJungIF = nil then Exit;
  ParamChange( FJangJungIF );

  if bCheck then
  begin
    bCheck  := TOrderManager(FJangJungIF).Start;
    if bCheck then begin
      ShowState(0, '주문관리중');
      gbOrder.Color := clSkyBlue;
    end
    else
      cbRun.Checked := false;
  end
  else begin
    TOrderManager(FJangJungIF).Stop;
    gbOrder.Color := clBtnFace;
    ShowState(0, '');
  end;


  if cbVolStop.Checked then
    CheckVolStop( bCheck );

  SendMoth;
end;

procedure TFraOrderManage.cbUseMothClick(Sender: TObject);
begin
  if cbUseMoth.Checked then
    Param.StartStop := 1
  else
    Param.StartStop := 0;

  if cbRun.Checked then
  begin
    Param.DataType := dtOrdCancel;
    gEnv.Engine.MothBroker.Send(self, mtOMan, Tag, FSymbol, FAccount);
  end;

  if chSavePosRun.Checked then
  begin
    Param.DataType := dtOrdPosCancel;
    gEnv.Engine.MothBroker.Send(self, mtOMan, Tag, FSymbol, FAccount);
  end;

  if FJangJungIF <> nil then
    FJangJungIF.UseMoth :=  cbUseMoth.Checked;

  if FOrderManIF <> nil then
    FOrderManIF.UseMoth :=  cbUseMoth.Checked;
end;

procedure TFraOrderManage.cbVolStopClick(Sender: TObject);
begin
  if cbRun.Checked then
  begin
    CheckVolStop( cbVolStop.Checked );
    if (cbUseMoth.Checked) then //and (cbVolStop.Checked ) then
    begin
      Param.DataType := dtOrdCancel;
      Param.StartStop := 1;
      if cbVolStop.Checked then
        Param.VolStop   := 1
      else
        Param.VolStop   := 0;
      SendMoth;
    end;
  end;
end;

procedure TFraOrderManage.CheckVolStop(bCheck: boolean);
var
  aParam : TManageParam;
  aVols  : TJackPotItems;
  I: Integer;
begin
  Param.DataType := dtOrdCancel;
  if cbVolStop.Checked then
    Param.VolStop := 1
  else
    Param.VolStop := 0;

  for I := 0 to FVolStopsList.Count - 1 do
  begin
    aVols := TjackPotItems( FVolStopsList.Items[i] );
    aVols.OrderBoard.JackPot.Manage := false;
    aVols.OrderBoard.JackPot.UseMoth:= false;//cbUseMoth.Checked;

    SendMoth;
  end;

  if (cbRun.Checked) and ( FVolStopsList.Count > 0) then
    ShowState(0, '주문관리중');


  if not bCheck then Exit;

  aParam.UseShift := false;
  aParam.AskHoga   :=  Param.Asks;
  aParam.BidHoga   :=  Param.Bids;

  if (FAccount = nil) or ( FSymbol = nil ) then
    Exit;

  FVolStopsList.Clear;
  gEnv.Engine.TradeCore.VolStops.FindBoard( FAccount, FSymbol, FVolStopsList );

  for I := 0 to FVolStopsList.Count - 1 do
  begin
    aVols := TjackPotItems( FVolStopsList.Items[i] );
    aVols.OrderBoard.JackPot.ManageParam  := aParam;
    aVols.OrderBoard.JackPot.Manage := bCheck;
    aVols.OrderBoard.JackPot.UseMoth:= cbUseMoth.Checked;
  end;

  if FVolStopsList.Count <= 0 then
  begin
    ShowState(0, '주문관리중(잔량스탑 오류)');
    cbVolStop.Checked := false;
  end
  else
    ShowState(0, '주문관리중(잔량스탑)');
end;

procedure TFraOrderManage.chSavePosRunClick(Sender: TObject);
var
  bCheck : boolean;
begin
  bCheck  := chSavePosRun.Checked;
  //aIf := FormManager.Find(ottOrdManager );
  if FOrderManIF = nil then Exit;
  ParamChange( FOrderManIF );

  if bCheck then
  begin
    bCheck  := TOrderManager(FOrderManIF).Start;
    if bCheck then begin
      ShowState(1, '포지션관리중');
      gbPos.Color := clSkyBlue;
    end
    else
      chSavePosRun.Checked := false;

  end
  else begin
    TOrderManager(FOrderManIF).Stop;
    gbPos.Color := clBtnFace;
    ShowState(1, '');
  end;

  SendMoth;
end;

procedure TFraOrderManage.CnlTimerTimer(Sender: TObject);
var
  bOK : boolean;
begin
  if FOrderItem = nil then
  begin
    CnlTimer.Enabled := false;
    Exit;
  end;

  bOK := FormManager.DoCancels( FOrderItem, 0, FCnt   );

  if not bOK then
  begin
    CnlTimer.Enabled := false;
    ShowState(0, '전체 취소 완료');
    GroupBox1.Color := clBtnFace;
    Button3.Enabled := true;
    gEnv.EnvLog( WIN_LOSS, '전체 취소 완료');
  end;
end;

procedure TFraOrderManage.DoLog(Sender: TObject; Value: String);
begin
  case TFrontOrderIF( Sender ).ManagerType of
    ottOrdManager : gEnv.EnvLog( WIN_JPOS, Value);
    ottJangJung   : gEnv.EnvLog( WIN_JJUNG, Value);
  end;
end;

procedure TFraOrderManage.edtAsk2Change(Sender: TObject);
begin
  cbRun.Checked := false;
  ShowState( 0 , '조건설정중');
end;

procedure TFraOrderManage.edtAsk2KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['1'..'9',#13, #8]) then
    Key := #0;
end;

procedure TFraOrderManage.edtAskChange(Sender: TObject);
begin
  chSavePosRun.Checked := false;
  ShowState( 1 , '조건설정중');
  Param.DataType := dtOrdPosCancel;
end;

procedure TFraOrderManage.edtAskPosKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13, #8]) then
    Key := #0;
end;

procedure TFraOrderManage.FrameAccountChange(aObject: TObject);
var
  aAccount : TAccount;
  aMarkets  : TMarketTypes;
  aGroup  : TAccountGroup;
  bRet : boolean;
  stLog : string;
begin
  if aObject = nil then exit;
  aAccount  := aObject As TAccount;
  if FAccount = aAccount then exit;
  {
  if FSymbol <> nil then
  begin
    bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck(FSymbol, FSymbol, aAccount, FAccount, self, rdtOrderMan);

    if not bRet then
    begin
      ComboAccount.ItemIndex := -1;
      gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(FSymbol, aAccount, rdtOrderMan);
      aAccount := nil;
    end;
  end;
   }

  FJangJungIF.Account := aAccount;
  FOrderManIF.Account := aAccount;

  FAccount := aAccount;
  edtAsk2Change( nil );
  edtAskChange( nil );
end;

procedure TFraOrderManage.FrameClose( bHide : boolean );
begin

  if bHide then
  begin
    cbRun.Checked := false;
    chSavePosRun.Checked := false;
    cbVolStop.Checked := false;
    cbRunClick(cbRun);
    chSavePosRunClick(chSavePosRun);
    gEnv.Engine.FormBroker.RedundancyChecks.Del(FSymbol, FAccount,self, rdtOrderMan);
    FSymbol := nil;
    FJangJungIF.Symbol := FSymbol;
    FOrderManIF.Symbol := FSymbol;
  end else
  begin
    CheckVolStop( false );
    FVolStopsList.Free;
    gEnv.Engine.FormManager.Del( FJangJungIF );
    Param.StartStop := 0;
    Param.DataType := dtOrdCancel;
    SendMoth;
    gEnv.Engine.FormManager.Del( FOrderManIF );
    Param.DataType := dtOrdPosCancel;
    SendMoth;
    gEnv.Engine.FormBroker.RedundancyChecks.Del(FSymbol, FAccount,self, rdtOrderMan);
    gEnv.Engine.FormBroker.FormTags.Del(FFormID, Tag);
  end;
end;

procedure TFraOrderManage.FrameCreate(iTag, iFormID: integer);
var
  stTag : string;
begin

  FAccount  := nil;
  FSymbol   := nil;

  FormManager :=  gEnv.Engine.FormManager;


  FOrderManIF :=  FormManager.New(ottOrdManager);
  FOrderManIF.OnLog := DoLog;
  FOrderManIF.OnEvent:= Notify;

  FJangJungIF := FormManager.New(ottJangJung);
  FJangJungIF.OnLog := DoLog;
  FJangJungIF.OnEvent:= Notify;

  FAccountGroup := nil;

  gbPos.Color := clBtnFace;
  gbOrder.Color := clBtnFace;

  FVolStopsList := TList.Create;
  FFormID := iFormID;
  Tag := iTag;
  stTag := Format('%dth_주문',[iTag]);
  lbTag.Caption := stTag;
end;

procedure TFraOrderManage.FrameSymbolChange(aObject: TObject);
var
  aSymbol : TSymbol;
  bRet : boolean;
  stLog : string;
begin
  aSymbol := aObject As TSymbol;
  if FSymbol = aSymbol then exit;

  FJangJungIF.Symbol := aSymbol;
  FOrderManIF.Symbol := aSymbol;
  FSymbol := aSymbol;
  edtAsk2Change( nil );
  edtAskChange( nil );
end;

procedure TFraOrderManage.LoadEnv(aStorage: TStorage);
var
  code : string;
  aSymbol : TSymbol;
begin
  if aStorage = nil then Exit;

  udAsk2.Position := aStorage.FieldByName('edtAsk2' ).AsInteger ;
  udBid2.Position := aStorage.FieldByName('edtBid2' ).AsInteger ;

  udAsk.Position :=   aStorage.FieldByName('edtAsk' ).AsInteger ;
  udBid.Position :=   aStorage.FieldByName('edtBid' ).AsInteger ;

  udAskPos.Position  := aStorage.FieldByName('edtAskPos').AsInteger;
  udBidPos.Position  := aStorage.FieldByName('edtBidPos').AsInteger;

  edtAllCnlQty.Text :=  aStorage.FieldByName('edtAllCnlQty').AsString;
  edtAllCnlInterval.Text  := aStorage.FieldByName('edtAllCnlInterval').AsString;

  cbUseMoth.Checked := aStorage.FieldByName('O_cbUseMoth').AsBoolean;
end;

procedure TFraOrderManage.Notify(Sender: TObject; value: boolean);
begin
  if Sender = nil then Exit;

  case TFrontOrderIF( Sender ).ManagerType of
    ottOrdManager   : chSavePosRun.Checked := Value;
    ottJangJung   : cbRun.Checked := Value;
  end;
end;

procedure TFraOrderManage.ParamChange(aIF: TFrontOrderIF);
begin

  if aIF = nil then Exit;

  case aIF.ManagerType of
    ottJangBefore: ;
    ottJangStart: ;
    otSimulEndJust: ;
    ottJangJung:
      begin
        Param.Asks  := StrToIntDef( edtAsk2.Text, 3 );
        Param.Bids  := StrToIntDef( edtBid2.Text, 3 );
        Param.OldVer     := false;
        Param.DataType := dtOrdCancel;
        Param.Cnt := StrToIntDef( edtAllCnlQty.Text, 10 );
        Param.Interval := StrToIntDef( edtAllCnlInterval.Text, 1000 );
        if cbRun.Checked then
          Param.StartStop := 1
        else
          Param.StartStop := 0;
        if cbVolStop.Checked then
          Param.VolStop := 1
        else
          Param.VolStop := 0;
      end;
    ottOrdManager:
      begin
        Param.Asks  := StrToIntDef( edtAsk.Text, 3 );
        Param.Bids  := StrToIntDef( edtBid.Text, 3 );
        Param.AskPos:= StrToIntDef( edtAskPos.Text, 30 );
        Param.BidPos:= StrToIntDef( edtBidPos.Text, 30 );
        Param.DataType := dtOrdPosCancel;
        Param.Cnt := StrToIntDef( edtAllCnlQty.Text, 10 );
        Param.Interval := StrToIntDef( edtAllCnlInterval.Text, 1000 );
        if chSavePosRun.Checked then
          Param.StartStop := 1
        else
          Param.StartStop := 0;
      end ;
  end;

  aIF.Param := Param;
end;

procedure TFraOrderManage.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FOrderManIF <> nil then
    if FOrderManIF.Symbol <> nil then
      aStorage.FieldByName('code' ).AsString := FOrderManIF.Symbol.Code
    else
      aStorage.FieldByName('code' ).AsString := '';


  aStorage.FieldByName('edtAsk2' ).AsString := edtAsk2.Text;
  aStorage.FieldByName('edtBid2' ).AsString := edtBid2.Text;

  aStorage.FieldByName('edtAsk' ).AsString := edtAsk.Text;
  aStorage.FieldByName('edtBid' ).AsString := edtBid.Text;

  aStorage.FieldByName('edtAskPos').AsString  := edtAskPos.Text;
  aStorage.FieldByName('edtBidPos').AsString  := edtBidPos.Text;

  aStorage.FieldByName('edtAllCnlQty').AsString := edtAllCnlQty.Text;
  aStorage.FieldByName('edtAllCnlInterval').AsString  := edtAllCnlInterval.Text;

  aStorage.FieldByName('O_cbUseMoth').AsBoolean := cbUseMoth.Checked;
end;

procedure TFraOrderManage.SendMoth;
begin
  if cbUseMoth.Checked then
    gEnv.Engine.MothBroker.Send(self, mtOMan, Tag, FSymbol, FAccount);
end;

procedure TFraOrderManage.SetDefaultParam;
begin

end;

procedure TFraOrderManage.ShowState(index: integer; value: string);
begin
  if not chSavePosRun.Checked then
    stBar.Panels[1].Text  := '';
  if not cbRun.Checked then
    stBar.Panels[0].Text  := '';
  stBar.Panels[index].Text  := value
end;

end.
