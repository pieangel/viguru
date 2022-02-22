unit DBoardPrefs;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin, Dialogs, Math, ComCtrls, IdGlobal;

const
  IDX_LONG = 0;
  IDX_SHORT = 1;
  IDX_ORDER = 0;
  IDX_QUOTE = 1;
  IDX_FONT = 0;
  IDX_BACKGROUND = 1;

type

  TBoardKeyType = ( ktNone , ktSpace, ktCtrl, ktAlt, ktEsc );

  //TCtrlState = ( csCtrl, csShift, csAlt );

  TOrderBoardPrefs = record

    OrderKey  : TBoardKeyType;
    RangeKey  : TBoardKeyType;
      // generic
    BoardCount: Integer; // number of Order Board
      // order
    ConfirmOrder: Boolean;   // 주문확인
    EnableClearOrder: Boolean;   // EnableClearOrder: Boolean청산연동
    EnableEscKey: Boolean;  // EnableEscape : Boolean;         // [Esc] : 주문 전체 취소
      // board
    AutoScroll: Boolean;           // 자동 스크롤
    TraceMouse: Boolean;     // MouseTrace : Boolean;  // 마우스 포인터 위치 행사가에 표시하기

    DbClickOrder : boolean;
    MouseSelect : boolean;   // 마우스 선택
    LastOrdCnl: boolean;

    OrderByMouseRB: Boolean; // OrderRightButton : Boolean ;    // 마우스 오른쪽 버튼으로 주문내기

    ShowZapr: Boolean; // VisibleZapr : Boolean; // 옵션적정가 표시
    ShowQT: Boolean; // VisibleQT : Boolean; // 최대 선행잔량 표시
    UseKey1to5: Boolean; // EanbleOneFive       // 1~5 키 사용
    UseKeyOrder : boolean;
    UseStandBy  : boolean;
    UseKey7to0 : boolean;      //7,8,9,0 매수매도주문사용여부
    //UseCtrl     : TCtrlState;

    UseShiftCnl : boolean;
    FocusOff    : boolean;

    UseWithStop : boolean;  // ctrl 주문시 잔량스탑주문

    UseBullStop : boolean;  // Bull Stop 단축키 사용
    BullStopKey : integer;  // Bull Key

    PriceSort : boolean;    //가격정렬
    PriceType : integer;    //시간 :0,  호가:1
    PriceTime : integer;    //시간
    PriceHoga : integer;    //호가
          // colors
    NoUseQtySet : boolean;

    Colors: array[0..1,0..1,0..1] of TColor;

    BoardColor : TColor;
    SelectedBoardColor  : TColor;
  end;

  TBoardPrefDialog = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CheckBoxConfirmOrder: TCheckBox;
    CheckBoxAutoScroll: TCheckBox;
    CheckBoxEnableClearOrder: TCheckBox;
    CheckBoxTraceMouse: TCheckBox;
    CheckBoxOrderByMouseRB: TCheckBox;
    CheckBoxShowZapr: TCheckBox;
    CheckBoxEnableEscKey: TCheckBox;
    CheckBoxShowQT: TCheckBox;
    GroupBox4: TGroupBox;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Label19: TLabel;
    Label8: TLabel;
    Label20: TLabel;
    Label1: TLabel;
    SpinEditBoardCount: TSpinEdit;
    CheckBoxUseKey1to5: TCheckBox;
    ColorDialog: TColorDialog;
    StaticTextShortQuote: TStaticText;
    StaticTextShortOrder: TStaticText;
    StaticTextLongQuote: TStaticText;
    StaticTextLongOrder: TStaticText;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    cbKeyOrder: TCheckBox;
    cbStandBy: TCheckBox;
    cbUseShiftCnl: TCheckBox;
    cbFocusOff: TCheckBox;
    cbWithStop: TCheckBox;
    ckUseBullStop: TCheckBox;
    ckPriceSort: TCheckBox;
    rdoTime: TRadioButton;
    edtTime: TEdit;
    lbSec: TLabel;
    rdoHoga: TRadioButton;
    edtHoga: TEdit;
    lbOver: TLabel;
    gbPriceSort: TGroupBox;
    cbBidAskOrder: TCheckBox;
    ckQtySet: TCheckBox;
    rbMouseSelect: TRadioGroup;
    rbMouseOrder: TRadioGroup;
    rbLastOrdCnl: TRadioGroup;
    GroupBox5: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    cbOrderKey: TComboBox;
    cbRangeKey: TComboBox;
    GroupBox6: TGroupBox;
    Label3: TLabel;
    stsBoardColor: TStaticText;
    SpeedButton9: TSpeedButton;
    Label5: TLabel;
    stsSelectedBoardColor: TStaticText;
    SpeedButton10: TSpeedButton;
    Button1: TButton;
    procedure EditBGColorClick(Sender: TObject);
    procedure EditFontColorClick(Sender: TObject);
    procedure cbUseShiftCnlClick(Sender: TObject);
    procedure ckPriceSortClick(Sender: TObject);
    procedure edtTimeKeyPress(Sender: TObject; var Key: Char);
    procedure cbOrderKeyChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    procedure SetPrefs(Value: TOrderBoardPrefs);
    function GetPrefs: TOrderBoardPrefs;
    function IsUsedBoradKey(keyType: TBoardKeyType): boolean;
  public

    OrderKey  : TBoardKeyType;
    RangeKey  : TBoardKeyType;
    AbleBoardKey : array [TBoardKeyType] of boolean;

    property Prefs: TOrderBoardPrefs read GetPrefs write SetPrefs;
    function Open( bSingle : boolean ) : boolean;


  end;

implementation

{$R *.DFM}

const
  MIN_ORDER_QTY_ROW_CNT = 6;
  BoardKeyDesc : array [TBoardKeyType] of string =
        ( '사용안함','Space bar','Ctrl','Alt','Esc' );

{ TBoardPrefDialog }

//---------------------------------------------------------------------< set >

procedure TBoardPrefDialog.SetPrefs(Value: TOrderBoardPrefs);
begin
  OrderKey  := Value.OrderKey;
  RangeKey  := Value.RangeKey;

  with Value do
  begin

    cbOrderKey.ItemIndex := integer( OrderKey );
    cbRangeKey.ItemIndex := integer( RangeKey );

    rbMouseOrder.ItemIndex  :=  ifThen( DbClickOrder, 0, 1 );
    rbMouseSelect.ItemIndex :=  ifThen( MouseSelect,  0, 1 );
    rbLastOrdCnl.ItemIndex  := ifThen( LastOrdCnl, 0, 1 );

    AbleBoardKey[ OrderKey ] := true;
    AbleBoardKey[ RangeKey ] := true;

      // generic
    SpinEditBoardCount.Value := BoardCount;
      // order
    CheckBoxConfirmOrder.Checked     := ConfirmOrder;
    CheckBoxEnableClearOrder.Checked := EnableClearOrder;
    CheckBoxEnableEscKey.Checked     := EnableEscKey;
      // board
    CheckBoxAutoScroll.Checked     := AutoScroll;
    CheckBoxTraceMouse.Checked     := TraceMouse;
    CheckBoxOrderByMouseRB.Checked := OrderByMouseRB;
    CheckBoxShowZapr.Checked       := ShowZapr;
    CheckBoxShowQT.Checked         := ShowQT;
    CheckBoxUseKey1to5.Checked     := UseKey1to5;
    cbKeyOrder.Checked             := UseKeyOrder;
    cbStandBy.Checked              := UseStandBy;
    cbBidAskOrder.Checked          := UseKey7to0;
    {
    if csShift = UseCtrl then
      rbShift.Checked := true
    else if csCtrl = UseCtrl then
      rbCtrl.Checked  := true
    else if csAlt = UseCtrl then
      rbAlt.Checked   := true;
    }

    cbUseShiftCnl.Checked := UseShiftCnl;
    cbFocusOff.Checked    := FocusOff;
    cbWithStop.Checked    := UseWithStop;

      // colors
    StaticTextShortQuote.Font.Color := Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT];
    StaticTextShortQuote.Color   := Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND];
    StaticTextShortOrder.Font.Color := Colors[IDX_SHORT, IDX_ORDER, IDX_FONT];
    StaticTextShortOrder.Color   := Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND];
    StaticTextLongQuote.Font.Color  := Colors[IDX_LONG, IDX_QUOTE, IDX_FONT];
    StaticTextLongQuote.Color    := Colors[IDX_LONG, IDX_QUOTE, IDX_BACKGROUND];
    StaticTextLongOrder.Font.Color  := Colors[IDX_LONG, IDX_ORDER, IDX_FONT];
    StaticTextLongOrder.Color    := Colors[IDX_LONG, IDX_ORDER, IDX_BACKGROUND];

    stsBoardColor.Color         := BoardColor;
    stsSelectedBoardColor.Color := SelectedBoardColor;

    ckUseBullStop.Checked := UseBullStop;

    // pricesort
    ckPriceSort.Checked := PriceSort;
    ckPriceSortClick(ckPriceSort);
    ckQtySet.Checked  := NoUseQtySet;

    if PriceType = 0 then
    begin
      rdoTime.Checked := true;
      rdoHoga.Checked := false;
    end else
    begin
      rdoTime.Checked := false;
      rdoHoga.Checked := true;
    end;

    edtTime.Text := IntToStr(PriceTime);
    edtHoga.Text := IntToStr(PriceHoga);
  end;
end;

procedure TBoardPrefDialog.SpeedButton9Click(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TSpeedButton) then Exit;

  if ColorDialog.Execute then
  begin
    case (Sender as TSpeedButton).Tag of
      100: stsBoardColor.Color := ColorDialog.Color;
      200: stsSelectedBoardColor.Color := ColorDialog.Color;
    end;
  end;
end;

//---------------------------------------------------------------------< get >

procedure TBoardPrefDialog.EditFontColorClick(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TSpeedButton) then Exit;

  if ColorDialog.Execute then
  begin
    case (Sender as TSpeedButton).Tag of
      100: StaticTextShortQuote.Font.Color := ColorDialog.Color;
      200: StaticTextShortOrder.Font.Color := ColorDialog.Color;
      300: StaticTextLongQuote.Font.Color := ColorDialog.Color;
      400: StaticTextLongOrder.Font.Color := ColorDialog.Color;
    end;
  end;
end;

procedure TBoardPrefDialog.edtTimeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TBoardPrefDialog.FormCreate(Sender: TObject);
var
  i : TBoardKeyType;
begin
  for I := ktNone to High(TBoardKeyType) do
  begin
    cbOrderKey.AddItem( BoardKeyDesc[i], nil );
    cbRangeKey.AddItem( BoardKeyDesc[i], nil );

    AbleBoardKey[i] := false;
  end;
end;

function  TBoardPrefDialog.IsUsedBoradKey( keyType : TBoardKeyType ) : boolean;
begin
  Result := AbleBoardKey[ keyType ];
end;

procedure TBoardPrefDialog.Button1Click(Sender: TObject);
begin
  stsBoardColor.Color := clBtnFace;
  stsSelectedBoardColor.Color := clYellow;
end;

procedure TBoardPrefDialog.cbOrderKeyChange(Sender: TObject);
var
  idx : integer;
  kType : TBoardKeyType;
begin
  idx := TComboBox( Sender ).ItemIndex;

  // 값의 변화가 없으면 Exit;
  case TComboBox( Sender ).Tag of
    0 : if idx = integer( OrderKey ) then Exit;
    1 : if idx = integer( RangeKey ) then Exit;
    //2 : if idx = integer( AllCnlKey )then Exit;
  end;

  if idx = 0 then
    kType := ktNone
  else begin
    kType := TBoardKeyType( idx );
    if IsUsedBoradKey( kType ) then
    begin
      ShowMessage('중복 key 사용');
      case TComboBox( Sender ).Tag of
        0 : begin cbOrderKey.ItemIndex := integer( OrderKey );  cbOrderKeyChange( cbOrderKey ); end;
        1 : begin cbRangeKey.ItemIndex := integer( RangeKey );  cbOrderKeyChange( cbRangeKey ); end;
        //2 : begin cbAllCnlKey.ItemIndex:= integer( AllCnlKey ); cbOrderKeyChange( cbAllCnlKey ); end;
      end;
      Exit;
    end;
  end;

  // 이전사용했던 key 는 사용가능으로 해주고
  case TComboBox( Sender ).Tag of
    0 : begin AbleBoardKey[OrderKey ]:= false; OrderKey := kType; end;
    1 : begin AbleBoardKey[RangeKey ]:= false; RangeKey := kType; end;
    //2 : begin AbleBoardKey[AllCnlKey]:= false; AllCnlKey := kType; end;
  end;
  // 지금 선택한 key 사용중으로 셋
  AbleBoardKey[ kType ] := true;

end;

procedure TBoardPrefDialog.cbUseShiftCnlClick(Sender: TObject);
begin    {
  if (rbShift.Checked) and ( cbUseShiftCnl.Checked ) then
  begin
    ShowMessage('Shift key 중복');
    cbUseShiftCnl.Checked := false;
    Exit;
  end;    }
end;

procedure TBoardPrefDialog.ckPriceSortClick(Sender: TObject);
begin
  rdoTime.Enabled := ckPriceSort.Checked;
  rdoHoga.Enabled := ckPriceSort.Checked;
  edtTime.Enabled := ckPriceSort.Checked;
  edtHoga.Enabled := ckPriceSort.Checked;
  lbSec.Enabled := ckPriceSort.Checked;
  lbOver.Enabled := ckPriceSort.Checked;
end;

procedure TBoardPrefDialog.EditBGColorClick(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TSpeedButton) then Exit;

  if ColorDialog.Execute then
  begin
    case (Sender as TSpeedButton).Tag of
      100: StaticTextShortQuote.Color := ColorDialog.Color;
      200: StaticTextShortOrder.Color := ColorDialog.Color;
      300: StaticTextLongQuote.Color := ColorDialog.Color;
      400: StaticTextLongOrder.Color := ColorDialog.Color;
    end;
  end;
end;

function TBoardPrefDialog.GetPrefs: TOrderBoardPrefs;
begin
  with Result do
  begin
    OrderKey  := TBoardKeyType( cbOrderKey.ItemIndex );
    RangeKey  := TBoardKeyType( cbRangeKey.ItemIndex );

    LastOrdCnl    := rbLastOrdCnl.ItemIndex = 0;
    DbClickOrder  := rbMouseOrder.ItemIndex  = 0;
    MouseSelect   := rbMouseSelect.ItemIndex = 0;

      // generic
    BoardCount := SpinEditBoardCount.Value;
      // order
    ConfirmOrder     := CheckBoxConfirmOrder.Checked;
    EnableClearOrder := CheckBoxEnableClearOrder.Checked;
    EnableEscKey     := CheckBoxEnableEscKey.Checked;
      // board
    AutoScroll     := CheckBoxAutoScroll.Checked;
    TraceMouse     := CheckBoxTraceMouse.Checked;
    OrderByMouseRB := CheckBoxOrderByMouseRB.Checked;
    ShowZapr       := CheckBoxShowZapr.Checked;
    ShowQT         := CheckBoxShowQT.Checked;
    UseKey1to5     := CheckBoxUseKey1to5.Checked;
    UseKeyOrder    := cbKeyOrder.Checked;
    UseStandBy     := cbStandBy.Checked;
    UseKey7to0    := cbBidAskOrder.Checked;
    {
    if rbAlt.Checked then
      UseCtrl  := csAlt
    else if rbCtrl.Checked then
      UseCtrl  := csCtrl
    else if rbShift.Checked then
      UseCtrl  := csShift;
    }
    UseShiftCnl   := cbUseShiftCnl.Checked;
    FocusOff      := cbFocusOff.Checked;
    UseWithStop   := cbWithStop.Checked;

      // colors
    Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT]       := StaticTextShortQuote.Font.Color;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND] := StaticTextShortQuote.Color;
    Colors[IDX_SHORT, IDX_ORDER, IDX_FONT]       := StaticTextShortOrder.Font.Color;
    Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND] := StaticTextShortOrder.Color;
    Colors[IDX_LONG, IDX_QUOTE, IDX_FONT]        := StaticTextLongQuote.Font.Color;
    Colors[IDX_LONG, IDX_QUOTE, IDX_BACKGROUND]  := StaticTextLongQuote.Color;
    Colors[IDX_LONG, IDX_ORDER, IDX_FONT]        := StaticTextLongOrder.Font.Color;
    Colors[IDX_LONG, IDX_ORDER, IDX_BACKGROUND]  := StaticTextLongOrder.Color;

    BoardColor          := stsBoardColor.Color   ;
    SelectedBoardColor  := stsSelectedBoardColor.Color ;

    UseBullStop := ckUseBullStop.Checked ;

        // pricesort
    PriceSort := ckPriceSort.Checked;
    NoUseQtySet := ckQtySet.Checked;

    if rdoTime.Checked then
      PriceType := 0
    else if rdoHoga.Checked then
      PriceType := 1;

    PriceTime :=  StrToIntDef(edtTime.Text, 10);
    PriceHoga := StrToIntDef(edtHoga.Text, 10);
  end;
end;

function TBoardPrefDialog.Open(bSingle: boolean): boolean;
begin
  if bSingle  then
    GroupBox4.Visible := false;
  Result := (ShowModal = mrOK);
end;


//---------------------------------------------------------------------< misc >


end.
