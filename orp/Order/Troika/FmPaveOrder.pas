unit FmPaveOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,

  CleAccounts, CleSymbols, ClePaveOrderType,

  CleStorage
  ;

type
  TFramePaveOrder = class(TFrame)
    plFloor: TPanel;
    plTop: TPanel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    edtSymbol: TEdit;
    btnSymbol: TButton;
    cbL: TCheckBox;
    edtLCon: TLabeledEdit;
    edtLCnlCon: TLabeledEdit;
    btnLCnl: TButton;
    cbS: TCheckBox;
    edtSCon: TLabeledEdit;
    edtSCnlCon: TLabeledEdit;
    btnSCnl: TButton;
    GroupBox1: TGroupBox;
    edtOrdQty: TLabeledEdit;
    udOrdQty: TUpDown;
    edtInterval: TLabeledEdit;
    udInterval: TUpDown;
    edtCount: TLabeledEdit;
    udCount: TUpDown;
    Panel1: TPanel;
    lblInfo: TLabel;
    edtLossVol: TLabeledEdit;
    Button4: TButton;
    dtEndTime: TDateTimePicker;
    Panel2: TPanel;
    edtLossPer: TLabeledEdit;
    edtCnlHour: TEdit;
    edtCnlTick: TEdit;
    btnLDepsit: TButton;
    btnSDeposit: TButton;
    lbDeposit: TLabel;
    procedure cbStartClick(Sender: TObject);
    procedure edtSConKeyPress(Sender: TObject; var Key: Char);
    procedure edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
    procedure cbAccountChange(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnLCnlClick(Sender: TObject);
    procedure btnSCnlClick(Sender: TObject);
    procedure btnLDepsitClick(Sender: TObject);
    procedure btnSDepositClick(Sender: TObject);
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FNumber: integer;
    FOnStartClick: TNotifyEvent;
    FParam: TLayOrderParam;
    FOnApplyClick: TNotifyEvent;
    FOnLongCnlClick: TNotifyEvent;
    FOnShortCnlClick: TNotifyEvent;
    FOnLongDepositClick: TNotifyEvent;
    FOnShortDepositClick: TNotifyEvent;
    procedure SetControls(bAcnt, bSymbol: boolean);
    function integer: integer;
    function GetParam: TLayOrderParam;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(AOwner: TComponent); override;

    property Account : TAccount read FAccount;
    property Symbol  : TSymbol  read FSymbol;
    property Number  : integer read FNumber;

    property Param : TLayOrderParam read GetParam;

    property OnStartClick : TNotifyEvent read FOnStartClick write FOnStartClick;
    property OnApplyClick : TNotifyEvent read FOnApplyClick write FOnApplyClick;
    property OnLongCnlClick : TNotifyEvent read FOnLongCnlClick write FOnLongCnlClick;
    property OnShortCnlClick : TNotifyEvent read FOnShortCnlClick write FOnShortCnlClick;

    property OnLongDepositClick : TNotifyEvent read FOnLongDepositClick write FOnLongDepositClick;
    property OnShortDepositClick : TNotifyEvent read FOnShortDepositClick write FOnShortDepositClick;

    procedure init( index : integer );
    procedure Display( stData : string; bDeposit : boolean = false );
    procedure LoadEnv( aStorage : TStorage; idx : integer );
    procedure SaveEnv( aStorage : TStorage; idx : integer );

  end;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

procedure TFramePaveOrder.btnLCnlClick(Sender: TObject);
begin
  if Assigned( FOnLongCnlClick ) and ( cbStart.Checked )  then
    FOnLongCnlClick( Self );
end;

procedure TFramePaveOrder.btnLDepsitClick(Sender: TObject);
begin
  if Assigned( FOnLongDepositClick )   then
    FOnLongDepositClick( Self );
end;

procedure TFramePaveOrder.btnSDepositClick(Sender: TObject);
begin
  if Assigned( FOnShortDepositClick )   then
    FOnShortDepositClick( Self );
end;

procedure TFramePaveOrder.btnSCnlClick(Sender: TObject);
begin
  if Assigned( FOnShortCnlClick ) and ( cbStart.Checked )  then
    FOnShortCnlClick( Self );
end;



procedure TFramePaveOrder.btnSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin
        FSymbol := gSymbol.Selected;
        edtSymbol.Text  := FSymbol.ShortCode
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFramePaveOrder.Button4Click(Sender: TObject);
begin
  if Assigned( FOnApplyClick ) and ( cbStart.Checked )  then
    FOnApplyClick( Self );
end;

procedure TFramePaveOrder.cbAccountChange(Sender: TObject);

var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
end;

procedure TFramePaveOrder.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
  begin
    if ( FAccount = nil ) or ( FSymbol = nil ) then
    begin
      ShowMessage('???? or ?????? ???????? ????');
      cbStart.Checked := false;
    end
    else begin
      plTop.Color := clSkyblue;
      SetControls( false, false );
    end;
  end
  else begin
    plTop.Color := clBtnFace;
    SetControls( true, true );
  end;

  if Assigned( FOnStartClick ) and ( FAccount <> nil ) and ( FSymbol <> nil )  then
    FOnStartClick( Self );
end;

constructor TFramePaveOrder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;
end;

procedure TFramePaveOrder.Display(stData: string ; bDeposit : boolean);
begin
  if bDeposit then
    lbDeposit.Caption := stData
  else
    lblInfo.Caption   := stData;
end;

procedure TFramePaveOrder.edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFramePaveOrder.edtSConKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8,'.']) then
    Key := #0;
end;

function TFramePaveOrder.GetParam: TLayOrderParam;
begin
  Result.UseL := cbL.Checked;
  Result.LStartPrc  := StrToFloatDef( edtLCon.Text, 0.5 );
  Result.LCnlPrc    := StrToFloatDef( edtLCnlCon.Text, 0.45 );

  Result.UseSS:= cbS.Checked;
  Result.SStartPrc  := StrToFloatDef( edtSCon.Text, 0.5 );
  Result.SCnlPrc    := StrToFloatDef( edtSCnlCon.Text, 0.55 );

  Result.OrdQty     := StrToIntDef( edtOrdQty.Text,  5 );
  Result.OrdGap     := StrToIntDef( edtInterval.Text, 2 );
  Result.OrdCnt     := StrToIntDef( edtCount.Text, 20 );

  Result.LossVol    := StrToIntDef( edtLossVol.Text, 200 );
  Result.LossPer    := StrToIntDef( edtLossPer.Text, 70 );
  Result.EndTime    := Frac( dtEndTime.Time );
  Result.CnlHour    := StrToIntDef( edtCnlHour.Text, 8 );
  Result.CnlTick    := StrToIntDef( edtCnlTick.Text, 2 );
end;

procedure TFramePaveOrder.init(index: integer);
begin
  FNumber := index;
end;

function TFramePaveOrder.integer: integer;
begin

end;

procedure TFramePaveOrder.LoadEnv(aStorage: TStorage; idx : integer);
var
  stPre : string;
  aAcnt : TAccount;
  aSymbol : TSymbol;
begin
  if aStorage = nil then Exit;

  stPre := IntToStr(idx) + '_';

  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName( stPre +'Account' ).AsString );
  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount, aAcnt );
    cbAccountChange(cbAccount);
  end;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( aStorage.FieldByName( stPre +'Symbol' ).AsString );
  if aSymbol <> nil then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := aSymbol.ShortCode;
  end;

  cbL.Checked     := aStorage.FieldByName( stPre +'UseBuy').AsBoolean;
  edtLCon.Text    := aStorage.FieldByName( stPre +'LOrdcon').AsString;
  edtLCnlCon.Text := aStorage.FieldByName( stPre +'LCnlCon').AsString;

  cbS.Checked     := aStorage.FieldByName( stPre +'UseSell').AsBoolean;
  edtSCon.Text    := aStorage.FieldByName( stPre +'SOrdcon').AsString;
  edtSCnlCon.Text := aStorage.FieldByName( stPre +'SCnlCon').AsString;

  udOrdQty.Position := aStorage.FieldByName( stPre +'OrdQty').AsInteger;
  udInterval.Position :=  aStorage.FieldByName( stPre +'OrdInterval').AsInteger;
  udCount.Position  :=  aStorage.FieldByName( stPre +'OrdCount').AsInteger ;

  edtLossVol.Text := aStorage.FieldByName( stPre +'LossVol').AsString;
  edtLossPer.Text := aStorage.FieldByName( stPre +'LossPer').AsString;
  dtEndTime.Time   := TDateTime(aStorage.FieldByName( stPre +'EndTime').AsFloat );
  edtCnlHour.Text  := aStorage.FieldByName( stPre +'CnlHour').AsStringDef('8');
  edtCnlTick.Text  := aStorage.FieldByName( stPre +'CnlTick').AsStringDef('2');
end;

procedure TFramePaveOrder.SaveEnv(aStorage: TStorage; idx : integer);
var
  stPre : string;
begin
  if aStorage = nil then Exit;

  stPre := IntToStr(idx) + '_';

  if FAccount <> nil then
    aStorage.FieldByName( stPre +'Account' ).AsString := FAccount.Code
  else
    aStorage.FieldByName( stPre +'Account' ).AsString := '';

  if FSymbol <> nil then
    aStorage.FieldByName( stPre +'Symbol' ).AsString := FSymbol.Code
  else
    aStorage.FieldByName( stPre +'Symbol' ).AsString := '';

  aStorage.FieldByName( stPre +'UseBuy').AsBoolean := cbL.Checked;
  aStorage.FieldByName( stPre +'LOrdcon').AsString := edtLCon.Text;
  aStorage.FieldByName( stPre +'LCnlCon').AsString := edtLCnlCon.Text;

  aStorage.FieldByName( stPre +'UseSell').AsBoolean:= cbS.Checked;
  aStorage.FieldByName( stPre +'SOrdcon').AsString := edtSCon.Text;
  aStorage.FieldByName( stPre +'SCnlCon').AsString := edtSCnlCon.Text;

  aStorage.FieldByName( stPre +'OrdQty').AsInteger  := StrToInt( edtOrdQty.Text );
  aStorage.FieldByName( stPre +'OrdInterval').AsInteger := StrToInt( edtInterval.Text );
  aStorage.FieldByName( stPre +'OrdCount').AsInteger    := StrToint( edtCount.Text );

  aStorage.FieldByName( stPre +'LossVol').AsString  := edtLossVol.Text;
  aStorage.FieldByName( stPre +'LossPer').AsString  := edtLossPer.Text;
  aStorage.FieldByName( stPre +'EndTime').AsFloat   := double( dtEndTime.Time );
  aStorage.FieldByName( stPre +'CnlHour').AsString  := edtCnlHour.Text;
  aStorage.FieldByName( stPre +'CnlTick').AsString  := edtCnlTick.Text;

end;

procedure TFramePaveOrder.SetControls( bAcnt , bSymbol : boolean );
begin
  cbAccount.Enabled := bAcnt;
  btnSymbol.Enabled := bSymbol;
end;

end.
