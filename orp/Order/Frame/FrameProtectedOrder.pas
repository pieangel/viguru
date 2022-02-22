unit FrameProtectedOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ComCtrls, Buttons, ExtCtrls, Grids,
  CleAccounts, CleProtectedStop, CleSymbols, CleStorage;
const
  H_PROTECTED_TOP = 118;
  H_PROTECTED_CENTER = 80;
  H_PROTECTED_CLIENT = 156;

type
  TFraProtectedOrder = class(TFrame)
    plLeft: TPanel;
    plRight: TPanel;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtAutoCnt: TEdit;
    edtAutoSec: TEdit;
    cbAuto: TCheckBox;
    sgLog: TStringGrid;
    plSide: TPanel;
    ButtonAuto: TSpeedButton;
    GroupBox1: TGroupBox;
    rdExecConDeposit: TRadioButton;
    rdExecConSame: TRadioButton;
    rdExecConCur: TRadioButton;
    edtExecConDeposit: TEdit;
    edtExecConSame: TEdit;
    edtExecConCur: TEdit;
    btnShow: TSpeedButton;
    plCenter: TPanel;
    GroupBox2: TGroupBox;
    rdClear: TRadioButton;
    rdFixClear: TRadioButton;
    edtClear: TEdit;
    edtFixClear: TEdit;
    udClear: TUpDown;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    lbTag: TLabel;
    rdDeposit: TRadioButton;
    rdSame: TRadioButton;
    udTick: TUpDown;
    edtTick: TEdit;
    btnExpand: TSpeedButton;
    procedure ButtonAutoClick(Sender: TObject);
    procedure rdExecConDepositClick(Sender: TObject);
    procedure edtExecConDepositChange(Sender: TObject);
    procedure edtExecConDepositKeyPress(Sender: TObject; var Key: Char);
    procedure rdClearClick(Sender: TObject);
    procedure rdFixClearClick(Sender: TObject);
    procedure rdDepositClick(Sender: TObject);
    procedure cbAutoClick(Sender: TObject);
    procedure sgLogDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure btnExpandClick(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
  private
    { Private declarations }
    FAccountGroup : TAccountGroup;
    FStopOrder: TProtectedStop;
    FHi : integer;
    SaveHi: integer;
    FFormID : integer;
    procedure SetEdtAble(btn: array of boolean);
    procedure SetEdtAble2(btn: array of boolean);
    procedure SetEdtAble3(btn: array of boolean);
    procedure initControls;
  public
    { Public declarations }
    Param : TProtectedStopParams;
    procedure FrameCreate(iTag, iFormID : integer);
    procedure FrameClose( bHide : boolean );
    procedure FrameSymbolChange( aObject : TObject );
    procedure FrameAccountChange( aObject : TObject );
    property StopOrder  : TProtectedStop read FStopOrder;
    procedure UpdateConfig;
    procedure SetConfig;
    procedure Stop;
    procedure Start;
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

implementation

uses
  GAppEnv, GleLib, CleFQN, GleTypes;
{$R *.dfm}

{ TFraProtectedOrder }

procedure TFraProtectedOrder.btnExpandClick(Sender: TObject);
begin
  if btnExpand.Down then
    btnExpand.Caption  :=  '▼'
  else
    btnExpand.Caption  :=  '▲';
end;

procedure TFraProtectedOrder.btnShowClick(Sender: TObject);
begin
  if btnShow.Down then
    btnShow.Caption  :=  '▼'
  else
    btnShow.Caption  :=  '▲';
end;

procedure TFraProtectedOrder.ButtonAutoClick(Sender: TObject);
begin
  if ButtonAuto.Down then
  begin
    Start;
  end
  else begin
    Stop;
  end;
end;

procedure TFraProtectedOrder.cbAutoClick(Sender: TObject);
begin
  edtAutoCnt.Enabled  := cbAuto.Checked;
  edtAutoSec.Enabled  := cbAuto.Checked;
  stop;
end;

procedure TFraProtectedOrder.edtExecConDepositChange(Sender: TObject);
begin
  stop;
end;

procedure TFraProtectedOrder.edtExecConDepositKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9',#13, '.', #8]) then
    Key := #0;
end;

procedure TFraProtectedOrder.FrameAccountChange(aObject: TObject);
var
  aAccount : TAccount;
  aMarkets  : TMarketTypes;
  aGroup  : TAccountGroup;
  bRet : boolean;
begin
  if aObject = nil then exit;

  // 선,옵 계좌를 구한다.
  aAccount  := aObject As TAccount;

  if aAccount <> nil then
  begin
    {
    if FStopOrder.Symbol <> nil then
    begin
      bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck
              (FStopOrder.Symbol, FStopOrder.Symbol, aAccount, FStopOrder.Account, self, rdtProtected);

      if not bRet then
      begin
        ComboAccount.ItemIndex := -1;
        gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(FStopOrder.Symbol, aAccount, rdtProtected);
        aAccount := nil;
      end;
    end;
    }
    FStopOrder.Account  := aAccount;
    stop;
  end;

end;

procedure TFraProtectedOrder.FrameClose( bHide : boolean );
begin
  gEnv.Engine.FormBroker.RedundancyChecks.Del(FStopOrder.Symbol, FStopOrder.Account, self, rdtProtected);
  stop;
  if bHide then
    FStopOrder.Symbol := nil
  else
  begin
    FStopOrder.Free;
    gEnv.Engine.FormBroker.FormTags.Del(FFormID, Tag);
  end;
end;

procedure TFraProtectedOrder.FrameCreate(iTag, iFormID: integer);
var
  stTag : string;
begin

  FHi   := GetSystemMetrics( SM_CYCAPTION ) ;
  SaveHi  := Height;
  FStopOrder:= TProtectedStop.Create( self );

  rdExecConDepositClick( rdExecConDeposit );
  rdClearClick( rdClear );
  rdDepositClick( rdDeposit );
  cbAutoClick( cbAuto );

  initControls;

  FFormID := iFormID;
  Tag := iTag;
  stTag := Format('%dth_Protected',[iTag]);
  lbTag.Caption := stTag;

end;

procedure TFraProtectedOrder.FrameSymbolChange(aObject: TObject);
var
  aSymbol : TSymbol;
  bRet : boolean;
begin
  aSymbol := aObject as TSymbol;
  FStopOrder.Symbol := aSymbol;
  stop;
end;

procedure TFraProtectedOrder.initControls;
begin
  with sgLog do
  begin
    Cells[0,0]  := 'Time';
    Cells[1,0]  := 'Contents';
    ColWidths[0] := 60;
    ColWidths[1] := Width - ColWidths[0];
  end;
end;

procedure TFraProtectedOrder.LoadEnv(aStorage: TStorage);
var
  bShow : boolean;
begin
  if aStorage = nil then Exit;

  with Param do
  begin

    ExecCondition := TStopExecCondition( aStorage.FieldByName('ExecCondition').AsInteger );
    ecDepositVal  := aStorage.FieldByName('ecDepositVal').AsFloat;
    ecSameSideVal := aStorage.FieldByName('ecSameSideVal').AsFloat;
    ecCurrentVal  := aStorage.FieldByName('ecCurrentVal').AsFloat;

    OrderQtyCondition := TStopQtyCondition( aStorage.FieldByName('OrderQtyCondition').AsInteger );
    ClearQtyDivN  := aStorage.FieldByName('ClearQtyDivN').AsInteger;
    FixedOrderQTy := aStorage.FieldByName('FixedOrderQTy').AsInteger;

    OrderPrice  := TStopOrderPrice( aStorage.FieldByName('OrderPrice').AsInteger );
    TickQty :=  aStorage.FieldByName('TickQty').AsInteger;

    OnAutoModify  := aStorage.FieldByName('OnAutoModify').AsBoolean;
    AutoModifyCnt := aStorage.FieldByName('AutoModifyCnt').AsInteger;
    AutoModifySec := aStorage.FieldByName('AutoModifySec').AsInteger;
    btnExpand.Down := aStorage.FieldByName('P_down').AsBoolean;
    btnExpandClick(btnExpand);

    // false 가 보여주는것
    bShow   := aStorage.FieldByName('ShowConfig').AsBoolean;

    // bNow
    if bShow then
    begin
      btnShow.Down := true;
      btnShow.Click;
    end;
    
  end;

  SetConfig;
end;

procedure TFraProtectedOrder.rdClearClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..1] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;
  btn[0]  := false;
  btn[1]  := false;
  btn[iTag] := true;
  SetEdtAble3(btn);
  stop;
end;

procedure TFraProtectedOrder.rdDepositClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..1] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;
  btn[0]  := false;
  btn[1]  := false;
  btn[iTag] := true;
  SetEdtAble2(btn);
  stop;
end;

procedure TFraProtectedOrder.rdExecConDepositClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..2] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;

  btn[0]  := false;
  btn[1]  := false;
  btn[2]  := false;

  btn[iTag] := true;
  SetEdtAble( btn );
  stop;
end;

procedure TFraProtectedOrder.rdFixClearClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..1] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;
  btn[0]  := false;
  btn[1]  := false;
  btn[iTag] := true;
  SetEdtAble3(btn);
  stop;
end;

procedure TFraProtectedOrder.SaveEnv(aStorage: TStorage);
begin

  UpdateConfig;

  if aStorage = nil then Exit;

  with Param do
  begin
    aStorage.FieldByName('ExecCondition').AsInteger  := Integer( ExecCondition );
    aStorage.FieldByName('ecDepositVal').AsFloat  := ecDepositVal;
    aStorage.FieldByName('ecSameSideVal').AsFloat  := ecSameSideVal;
    aStorage.FieldByName('ecCurrentVal').AsFloat  := ecCurrentVal;


    aStorage.FieldByName('OrderQtyCondition').AsInteger  := Integer( OrderQtyCondition );
    aStorage.FieldByName('ClearQtyDivN').AsInteger   := ClearQtyDivN;
    aStorage.FieldByName('FixedOrderQTy').AsInteger   := FixedOrderQTy;

    aStorage.FieldByName('OrderPrice').AsInteger  := Integer( OrderPrice );
    aStorage.FieldByName('TickQty').AsInteger  := TickQty ;

    aStorage.FieldByName('OnAutoModify').AsBoolean  := OnAutoModify;
    aStorage.FieldByName('AutoModifyCnt').AsInteger  := AutoModifyCnt ;
    aStorage.FieldByName('AutoModifySec').AsInteger  := AutoModifySec ;
    aStorage.FieldByName('ShowConfig').AsBoolean  := btnShow.Down;
    aStorage.FieldByName('P_down').AsBoolean := btnExpand.Down;
  end;
end;

procedure TFraProtectedOrder.SetConfig;
begin
  with Param do
  begin
    edtExecConDeposit.Text  :=  FloatToStr( ecDepositVal );
    edtExecConSame.Text :=  FloatToStr( ecSameSideVal );
    edtExecConCur.Text  := FloatToStr( ecCurrentVal );
    case ExecCondition of
      ecDeposit:  rdExecConDeposit.Checked := true;
      ecSameSide: rdExecConSame.Checked := true;
      ecCurrent:  rdExecConCur.Checked := true;
    end;

    udClear.Position  := ClearQtyDivN;
    edtFixClear.Text  := IntToStr( FixedOrderQTy );
    case OrderQtyCondition of
      ocMinFixNClear: rdFixClear.Checked := true;
      ocClearDivN:  rdClear.Checked := true;
    end;

    udTick.Position := TickQty;
    case OrderPrice of
      opDeposit:  rdDeposit.Checked := true;
      opSameSide: rdSame.Checked  := true;
    end;

    edtAutoCnt.Text := IntToStr( AutoModifyCnt );
    edtAutoSec.Text := IntToStr( AutoModifySec );
    cbAuto.Checked  := OnAutoModify;
  end;
end;

procedure TFraProtectedOrder.SetEdtAble(btn: array of boolean);
begin
  edtExecConDeposit.Enabled := btn[0];
  edtExecConSame.Enabled    := btn[1];
  edtExecConCur.Enabled     := btn[2];
end;

procedure TFraProtectedOrder.SetEdtAble2(btn: array of boolean);
begin
  edtTick.Enabled := btn[1];
  udTick.Enabled  := btn[1];
end;

procedure TFraProtectedOrder.SetEdtAble3(btn: array of boolean);
begin
  edtClear.Enabled  := btn[0];
  udClear.Enabled   := btn[0];
  edtFixClear.Enabled := btn[1];
end;

procedure TFraProtectedOrder.sgLogDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
    aBack : TColor;
    bGray : boolean;
    stTxt : string;
begin
  with sgLog do
  begin
    stTxt := Cells[ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace
    else begin
      if integer( Objects[0, ARow] ) = 100 then
        aBack := clSkyBlue
      else
        aBack := clWhite;
    end;

    Canvas.Font.Color := clBlack;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect );
    Canvas.TextRect( Rect, Rect.Left + 2, Rect.Top + 1, stTxt );
  end;
end;

procedure TFraProtectedOrder.Start;
begin
  UpdateConfig;
  FStopOrder.ProtecteParam  := Param;
  FStopOrder.Run;

  if not FStopOrder.Start then
    Stop
  else begin
    ButtonAuto.Caption  := 'Start';
    plCenter.Color := clSkyBlue;
    GroupBox1.Color := clSkyBlue;
  end;
end;

procedure TFraProtectedOrder.Stop;
begin
  if FStopOrder = nil then
    Exit;
  FStopOrder.Stop;
  ButtonAuto.Down := false;
  ButtonAuto.Caption  := 'Stop';
  plCenter.Color := clbtnFace;
  GroupBox1.Color := clbtnFace;
end;

procedure TFraProtectedOrder.UpdateConfig;
begin
  with Param do
  begin
    if rdExecConDeposit.Checked then
      ExecCondition := ecDeposit
    else if rdExecConSame.Checked then
      ExecCondition := ecSameSide
    else if rdExecConCur.Checked then
      ExecCondition := ecCurrent;

    ecDepositVal  := StrTofloatDef( edtExecConDeposit.Text, 0 );
    ecSameSideVal := StrTofloatDef( edtExecConSame.Text, 0 );
    ecCurrentVal  := StrTofloatDef( edtExecConCur.Text, 0 );

    if rdClear.Checked then
      OrderQtyCondition := ocClearDivN
    else if rdFixClear.Checked then
      OrderQtyCondition := ocMinFixNClear;

    ClearQtyDivN   := StrToIntDef( edtClear.Text, 1 );
    FixedOrderQTy  := StrToIntDef( edtFixClear.Text, 1 );

    if rdDeposit.Checked then
      OrderPrice  := opDeposit
    else if rdSame.Checked then
      OrderPrice  := opSameSide;
    TickQty := strTointDef( edtTick.Text, 0 );


    OnAutoModify  := cbAuto.Checked;
    AutoModifyCnt := StrToIntDef( edtAutoCnt.Text, 1 );
    AutoModifySec := StrToIntDef( edtAutoSec.Text, 1 );
  end;
end;

end.
