unit DDoubleOrderConfig ;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin, Dialogs, Math, ComCtrls, IdGlobal,  
  //
  HelpCentral, AppConsts, AppTypes, License, EFData, LogCentral, OrderTablet;

type
  TDoubleOrderConfig = record
    // data 
    OrderQtyRowCnt : Integer; // �ֹ����� ������

    // visible 
    VisibleUnder : Boolean;         // �����ڻ� ���� ǥ��
    VisibleOHL : Boolean;           // O/H/L/K200 ǥ��
    VisibleEvalPL : Boolean;        // ����/������ ǥ��
    VisibleOrderAmt : Boolean;      // �ֹ����ɱݾ� ǥ��
    VisibleQT : Boolean;            // �ִ� �����ܷ� ǥ��
    VisibleZapr : Boolean;          // �ɼ������� ǥ��
    // enable 
    EnableQtyClick : Boolean;       // ������ �������� ���� ����(����Ŭ��)
    EnableEscape : Boolean;         // [Esc] : �ֹ� ��ü ���
    EnableOneFive : Boolean;        // 1~5 Ű ���
    EnableClearOrder : Boolean;     // û�꿬��
    AutoScroll : Boolean;           // �ڵ� ��ũ��

    OrderRightButton : Boolean ;    // ���콺 ������ ��ư���� �ֹ�����
    MouseTrace : Boolean ;          // ���콺 ������ ��ġ ��簡�� ǥ���ϱ�
    ConfirmOrder: Boolean;          // �ֹ�Ȯ��

    // �¿� �г� 
    VisibleTicks : array[TSideType] of Boolean;   // ����ü�� ǥ��
    FillFilter : array[TSideType] of Boolean;     // ü������
    TickCnt : array[TSideType] of Integer;        // ü�� ��
    FillCnt : array[TSideType] of Integer;        // ���ͼ���

    // �¿�,  Tablet Config
    OrderLeft : array[TSideType] of TPositionType ;     // ���ݿ� ���ʿ� �ż���? �ŵ���?
    QtySide : array[TSideType] of TSideType ;           // ���տ� ��ġ
    VisibleOrder : array[TSideType] of Boolean ;        // �ֹ���
    QtyMerge : array[TSideType] of Boolean ;            // �ܷ� ����
    PriceOrderby : array[TSideType] of TPriceOrderbyType ;  // ���ݿ� ��������/��������

    // 2007.05.21 IV
    VisibleIV : Array[TSideType] of Boolean ; //  IV ��  

    // ����
    QtyFontColor : array[TPositionType] of String;
    QtyBgColor : array[TPositionType] of String;
    OrderFontColor : array[TPositionType] of String;
    OrderBgColor : array[TPositionType] of String;

  end;
  
  TDoubleOrderConfigDialog = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    BtnHelp: TButton;
    CheckShowTrace: TCheckBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label2: TLabel;
    Bevel3: TBevel;
    Label1: TLabel;
    Label3: TLabel;
    CheckConfirmOrder: TCheckBox;
    CheckQtyClick: TCheckBox;
    CheckQT: TCheckBox;
    CheckAutoScroll: TCheckBox;
    CheckOrderRightButton: TCheckBox;
    CheckMouseTrace: TCheckBox;
    GroupBox4: TGroupBox;
    Label5: TLabel;
    LabelTickCount: TLabel;
    CheckLeftQtyMerge: TCheckBox;
    CheckLeftVisibleOrder: TCheckBox;
    RadioGroupLeftQtySide: TRadioGroup;
    CheckLeftFillFilter: TCheckBox;
    CheckLeftTicks: TCheckBox;
    EditLeftTickCnt: TEdit;
    EditLeftFillCnt: TEdit;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    Label6: TLabel;
    CheckRightQtyMerge: TCheckBox;
    CheckRightVisibleOrder: TCheckBox;
    RadioGroupRightQtySide: TRadioGroup;
    CheckRightFillFilter: TCheckBox;
    CheckRightTicks: TCheckBox;
    EditRightTickCnt: TEdit;
    EditRightFillCnt: TEdit;
    CheckClearOrder: TCheckBox;
    CheckUnder: TCheckBox;
    CheckOrderAmt: TCheckBox;
    CheckZapr: TCheckBox;
    CheckOneFive: TCheckBox;
    CheckUseEscape: TCheckBox;
    EditShortQtyFont: TEdit;
    Label7: TLabel;
    Bevel2: TBevel;
    EditShortQtyBg: TEdit;
    Label8: TLabel;
    EditLongQtyFont: TEdit;
    EditLongQtyBg: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    EditShortOrderFont: TEdit;
    EditShortOrderBg: TEdit;
    Label18: TLabel;
    Label19: TLabel;
    EditLongOrderFont: TEdit;
    EditLongOrderBg: TEdit;
    Label20: TLabel;
    ColorDialog: TColorDialog;
    Bevel1: TBevel;
    CheckLeftVisibleIV: TCheckBox;
    CheckRightVisibleIV: TCheckBox;
    RadioGroupLeftPriceOrder: TRadioGroup;
    RadioGroupRightPriceOrder: TRadioGroup;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCntKeyPress(Sender: TObject; var Key: Char);
    procedure EditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditQytExit(Sender: TObject);
    procedure CheckColor( Sender : TObject );
    procedure EditQtyEnter(Sender: TObject);

  private
    FConfig : TDoubleOrderConfig ;
    procedure SetConfig(aConfig:  TDoubleOrderConfig);
    procedure SetColor( aEdit : TEdit ; stFontColor : String ; stBgColor : String ;
       aPosition : TPositionType  );
    function GetColorStr(aColor : TColor ) : String ;
  public
    property Config : TDoubleOrderConfig read FConfig write SetConfig;
  end;

implementation

{$R *.DFM}

{ TDoubleOrderCfgDialog }

uses
  Globals;
 
//----------------------< Create/Destroy >----------------------------//

procedure TDoubleOrderConfigDialog.FormCreate(Sender: TObject);
begin
 
  if gLicenseInfo.Level in [LICENSE_DEVELOPER,
                            LICENSE_DX_FED,
                            LICENSE_DX_LSY,
                            LICENSE_DX_TC] then
  begin
    CheckZapr.Visible := True;
    CheckQT.Visible := True;
  end;

  { 
  EditShortQtyFont.Text := 'clBlack' ;
  EditShortQtyBg.Text := '$00EFD2B4'  ;
  EditLongQtyFont.Text := 'clBlack'  ;
  EditLongQtyBg.Text := '$00CBACF0'  ;
  //
  EditShortOrderFont.Text := 'clBlack'  ;
  EditShortOrderBg.Text := '$00EFD2B4' ;
  EditLongOrderFont.Text := 'clBlack'  ;
  EditLongOrderBg.Text := '$00CBACF0' ;
  }
  
end;

function TDoubleOrderConfigDialog.GetColorStr(aColor: TColor): String;
var
  stColor : String ; 
begin
  //
  if ColorToIdent(aColor, stColor) then
    FmtStr(stColor, '%s%.6x', [HexDisplayPrefix, aColor])
  else
    FmtStr(stColor, '%s%.6x', [HexDisplayPrefix, aColor]); 
  //
  Result := stColor ; 
end;

procedure TDoubleOrderConfigDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:= caFree;
end;

//-------------------< Get/Set >-------------------------------//

const
  MIN_ORDER_QTY_ROW_CNT = 6;

procedure TDoubleOrderConfigDialog.SetColor(aEdit: TEdit; stFontColor,
  stBgColor: String ; aPosition : TPositionType );
var
  stDefFont : STring ;
  stDefBg : String ;
begin

  // -- font 
  try
    aEdit.Font.Color := StringToColor(stFontColor) ;
  except
    stDefFont := 'clBlack' ;

    gLog.Add(lkUser, '�����ֹ�', '�ŵ��ܷ� ����', 'Default Font : ' + stDefFont ) ;
    aEdit.Font.Color := StringToColor(stDefFont) ;
  end;

  // -- bg  
  try
    aEdit.Color := StringToColor(stBgColor) ;
  except
    if aPosition = ptLong then
      stDefBg := '$00EFD2B4' 
    else 
      stDefBg := '$00CBACF0'  ;

    gLog.Add(lkUser, '�����ֹ�', '�ŵ��ܷ� ����', 'Default Bg : ' + stDefBg ) ;
    aEdit.Color := StringToColor(stDefBg) ;
  end; 
end;


procedure TDoubleOrderConfigDialog.SetConfig(aConfig:  TDoubleOrderConfig);
begin
  FConfig := aConfig;
  
  with FConfig do
  begin

    // -- �ֹ�����
    // �ֹ�Ȯ��
    CheckConfirmOrder.Checked:= ConfirmOrder ;
    // �ֹ����� ������
    if OrderQtyRowCnt < MIN_ORDER_QTY_ROW_CNT then
      OrderQtyRowCnt := MIN_ORDER_QTY_ROW_CNT;
    
    // �ڵ� ��ũ��
    CheckAutoScroll.Checked := AutoScroll;
    // ���콺 ������ ��ġ ��簡�� ǥ���ϱ�
    CheckMouseTrace.Checked := MouseTrace ; 
    // ������ �������� ���� ����(����Ŭ��)
    CheckQtyClick.Checked := EnableQtyClick;
    // �ִ� �����ܷ� ǥ��
    CheckQT.Checked := VisibleQT ;
    // ���콺 ������ ��ư���� �ֹ����� 
    CheckOrderRightButton.Checked := OrderRightButton ; 

    // -- ��Ÿ���� 
    CheckUnder.Checked := VisibleUnder;           // �����ڻ� ���� ǥ��
    CheckOrderAmt.Checked := VisibleOrderAmt;     // �ֹ����ɱݾ� ǥ��
    CheckZapr.Checked := VisibleZapr;             // �ɼ������� ǥ��

    // 2007.03.11 Spin
    // SpinFillCnt.Value := FillCnt;                 // ���ͼ���
    CheckOneFive.Checked := EnableOneFive;        // 1~5 Ű ���
    CheckUseEscape.Checked := EnableEscape ;      // ESC 
    CheckClearOrder.Checked := EnableClearOrder;  // û�꿬��

    CheckLeftTicks.Checked := VisibleTicks[stLeft];  // ����ü�� ǥ��
    CheckLeftFillFilter.Checked := FillFilter[stLeft];       // ü������
    EditLeftFillCnt.Text := IntToStr(FillCnt[stLeft]) ;    // ���ͼ���
    EditLeftTickCnt.Text := IntToStr(TickCnt[stLeft]);     // ü���

    CheckRightTicks.Checked := VisibleTicks[stRight];  // ����ü�� ǥ��
    CheckRightFillFilter.Checked := FillFilter[stRight];       // ü������
    EditRightFillCnt.Text := IntToStr(FillCnt[stRight]) ;    // ���ͼ���
    EditRightTickCnt.Text := IntToStr(TickCnt[stRight]);     // ü���

    // Left Tablet
    CheckLeftVisibleOrder.Checked := VisibleOrder[stLeft] ;    // �ֹ���
    CheckLeftQtyMerge.Checked := QtyMerge[stLeft] ;             // �ܷ� ����
    CheckLeftVisibleIV.Checked := VisibleIV[stLeft] ;  //  IV

    // ���ݿ� ��������/��������
    if PriceOrderby[stLeft] = poAsc then
      RadioGroupLeftPriceOrder.ItemIndex := 0
    else if PriceOrderby[stLeft] = poDesc then
      RadioGroupLeftPriceOrder.ItemIndex := 1
    else if PriceOrderby[stLeft] = poAuto then
      RadioGroupLeftPriceOrder.ItemIndex := 2 ;
    //
    if QtySide[stLeft] = stLeft then
      RadioGroupLeftQtySide.ItemIndex := 0
    else
      RadioGroupLeftQtySide.ItemIndex := 1 ; 
    //

    // Right Tablet
    CheckRightVisibleOrder.Checked := VisibleOrder[stRight] ;    // �ֹ���
    CheckRightQtyMerge.Checked := QtyMerge[stRight] ;             // �ܷ� ����
    CheckRightVisibleIV.Checked := VisibleIV[stRight] ;    //  IV
    
    // ���ݿ� ��������/��������
    if PriceOrderby[stRight] = poAsc then
      RadioGroupRightPriceOrder.ItemIndex := 0
    else if PriceOrderby[stRight] = poDesc then
      RadioGroupRightPriceOrder.ItemIndex := 1
    else if PriceOrderby[stRight] = poAuto  then
      RadioGroupRightPriceOrder.ItemIndex := 2 ;
    //
    if QtySide[stRight] = stLeft then
      RadioGroupRightQtySide.ItemIndex := 0
    else
      RadioGroupRightQtySide.ItemIndex := 1 ;

    // -- Color 
    EditShortQtyFont.Text := QtyFontColor[ptShort] ; 
    EditShortQtyBg.Text := QtyBgColor[ptShort] ; 
    EditLongQtyFont.Text := QtyFontColor[ptLong] ; 
    EditLongQtyBg.Text := QtyBgColor[ptLong] ; 
    EditShortOrderFont.Text :=  OrderFontColor[ptShort] ; 
    EditShortOrderBg.Text := OrderBgColor[ptShort] ;
    EditLongOrderFont.Text := OrderFontColor[ptLong] ;
    EditLongOrderBg.Text := OrderBgColor[ptLong] ;
    // 
    SetColor(EditShortQtyFont, EditShortQtyFont.Text, EditShortQtyBg.Text, ptShort );
    SetColor(EditShortQtyBg, EditShortQtyFont.Text, EditShortQtyBg.Text, ptShort );
    SetColor(EditLongQtyFont, EditLongQtyFont.Text, EditLongQtyBg.Text, ptLong );
    SetColor(EditLongQtyBg, EditLongQtyFont.Text, EditLongQtyBg.Text, ptLong );
    SetColor(EditShortOrderFont, EditShortOrderFont.Text, EditShortOrderBg.Text, ptShort );
    SetColor(EditShortOrderBg, EditShortOrderFont.Text, EditShortOrderBg.Text, ptShort );
    SetColor(EditLongOrderFont, EditLongOrderFont.Text, EditLongOrderBg.Text, ptLong );
    SetColor(EditLongOrderBg, EditLongOrderFont.Text, EditLongOrderBg.Text, ptLong );
    
  end;
end;


procedure TDoubleOrderConfigDialog.BtnOKClick(Sender: TObject);
begin

  if  ( RadioGroupLeftPriceOrder.ItemIndex = 2 ) and
    ( RadioGroupRightPriceOrder.ItemIndex = 2 ) then
  begin
    ShowMessage('���� ��� Auto ����!' ); 
    exit;
  end;

  EditQytExit(EditShortQtyBg);
  EditQytExit(EditLongQtyBg);
  EditQytExit(EditShortOrderBg);
  EditQytExit(EditLongOrderBg);

  with FConfig do
  begin
    // -- �ֹ�����
    ConfirmOrder := CheckConfirmOrder.Checked  ;    // �ֹ�Ȯ��
    AutoScroll := CheckAutoScroll.Checked  ;        // �ڵ� ��ũ��  
    MouseTrace := CheckMouseTrace.Checked ;         // ���콺 ������ ��ġ ��簡�� ǥ���ϱ�
    EnableQtyClick := CheckQtyClick.Checked ;       // ������ �������� ���� ����(����Ŭ��)  
    VisibleQT := CheckQT.Checked ;                  // �ִ� �����ܷ� ǥ��
    OrderRightButton := CheckOrderRightButton.Checked ;   // ���콺 ������ ��ư���� �ֹ����� 
    // -- ��Ÿ����
    VisibleUnder := CheckUnder.Checked;           // �����ڻ� ���� ǥ��
    VisibleOrderAmt := CheckOrderAmt.Checked;     // �ֹ����ɱݾ� ǥ��
    VisibleZapr := CheckZapr.Checked;             // �ɼ������� ǥ��

    EnableEscape := CheckUseEscape.Checked ;     // ESC
    EnableOneFive := CheckOneFive.Checked;        // 1~5 Ű ���
    EnableClearOrder := CheckClearOrder.Checked;  // û�꿬��

    VisibleTicks[stLeft] := CheckLeftTicks.Checked;       // ����ü�� ǥ��
    TickCnt[stLeft] := StrToInt( EditLeftTickCnt.Text) ;  // ü���
    FillFilter[stLeft] := CheckLeftFillFilter.Checked;    // ü������
    FillCnt[stLeft] := StrToInt( EditLeftFillCnt.Text) ;  // ���ͼ���

    VisibleTicks[stRight] := CheckRightTicks.Checked;       // ����ü�� ǥ��
    TickCnt[stRight] := StrToInt( EditRightTickCnt.Text) ;  // ü���
    FillFilter[stRight] := CheckRightFillFilter.Checked;    // ü������
    FillCnt[stRight] := StrToInt( EditRightFillCnt.Text) ;  // ���ͼ���

    // -- Left Tablet
    VisibleOrder[stLeft] := CheckLeftVisibleOrder.Checked ;    // �ֹ���
    QtyMerge[stLeft] := CheckLeftQtyMerge.Checked ;             // �ܷ� ����
    VisibleIV[stLeft] := CheckLeftVisibleIV.Checked ; //  IV 

    // ���ݿ� ��������(�Ϲ���)/��������
    // �������� : ���ݿ� ���ʿ� �ŵ�, �������� : ���ݿ� ���ʿ� �ż�
    if RadioGroupLeftPriceOrder.ItemIndex = 0 then
    begin
      PriceOrderby[stLeft] :=  poAsc ;
      OrderLeft[stLeft] := ptShort ; 
    end 
    else if RadioGroupLeftPriceOrder.ItemIndex = 1 then
    begin
      PriceOrderby[stLeft] := poDesc  ;
      OrderLeft[stLeft] := ptLong ;
    end
    else if RadioGroupLeftPriceOrder.ItemIndex = 2 then
    begin
      PriceOrderby[stLeft] := poAuto  ;
    end;
    //

    if RadioGroupLeftQtySide.ItemIndex = 0  then
      QtySide[stLeft] := stLeft
    else
      QtySide[stLeft] := stRight ;

    // -- Right Tablet
    VisibleOrder[stRight] := CheckRightVisibleOrder.Checked ;    // �ֹ���
    QtyMerge[stRight] := CheckRightQtyMerge.Checked ;             // �ܷ� ����
    VisibleIV[stRight] := CheckRightVisibleIV.Checked ; //  IV

    // ���ݿ� ��������(�Ϲ���)/��������
    // �������� : ���ݿ� ���ʿ� �ŵ�, �������� : ���ݿ� ���ʿ� �ż� 
    if RadioGroupRightPriceOrder.ItemIndex = 0 then
    begin
      PriceOrderby[stRight] :=  poAsc ;
      OrderLeft[stRight] := ptShort ; 
    end
    else if RadioGroupRightPriceOrder.ItemIndex = 1 then
    begin
      PriceOrderby[stRight] := poDesc  ;
      OrderLeft[stRight] := ptLong ;
    end
    else if RadioGroupRightPriceOrder.ItemIndex = 2 then
    begin
      PriceOrderby[stRight] := poAuto  ;
    end; 

    if RadioGroupRightQtySide.ItemIndex = 0  then
      QtySide[stRight] := stLeft
    else
      QtySide[stRight] := stRight ;

    // -- Color
    QtyFontColor[ptShort] := EditShortQtyFont.Text ;
    QtyBgColor[ptShort] := EditShortQtyBg.Text ;  
    QtyFontColor[ptLong] := EditLongQtyFont.Text ;
    QtyBgColor[ptLong] := EditLongQtyBg.Text ;
    OrderFontColor[ptShort] := EditShortOrderFont.Text;
    OrderBgColor[ptShort] := EditShortOrderBg.Text ;
    OrderFontColor[ptLong] := EditLongOrderFont.Text ;
    OrderBgColor[ptLong] := EditLongOrderBg.Text ;
    
  end;

  ModalResult:= mrOk;
end;



procedure TDoubleOrderConfigDialog.EditCntKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ((Key < '0') or (Key > '9')) and (Key <> #13) then Key:=#0;
end;


procedure TDoubleOrderConfigDialog.BtnHelpClick(Sender: TObject);
begin
  gHelp.Show(ID_EF2Cfg);
end;



procedure TDoubleOrderConfigDialog.CheckColor(Sender: TObject);
var
  aEdit : TEdit ;
begin

  try

      if ( Sender = EditShortQtyFont ) or (  Sender = EditShortQtyBg ) then
      begin
        SetColor(EditShortQtyFont, EditShortQtyFont.Text, EditShortQtyBg.Text, ptShort );
        SetColor(EditShortQtyBg, EditShortQtyFont.Text, EditShortQtyBg.Text, ptShort ); 
      end
      else if ( Sender = EditLongQtyFont ) or (  Sender = EditLongQtyBg )   then
      begin
        SetColor(EditLongQtyFont, EditLongQtyFont.Text, EditLongQtyBg.Text, ptLong );
        SetColor(EditLongQtyBg, EditLongQtyFont.Text, EditLongQtyBg.Text, ptLong );
      end
      else if ( Sender = EditShortOrderFont ) or (  Sender = EditShortOrderBg )  then
      begin
        SetColor(EditShortOrderFont, EditShortOrderFont.Text, EditShortOrderBg.Text, ptShort );
        SetColor(EditShortOrderBg, EditShortOrderFont.Text, EditShortOrderBg.Text, ptShort );
      end
      else if ( Sender = EditLongOrderFont ) or (  Sender = EditLongOrderBg )  then
      begin
        SetColor(EditLongOrderFont, EditLongOrderFont.Text, EditLongOrderBg.Text, ptLong );
        SetColor(EditLongOrderBg, EditLongOrderFont.Text, EditLongOrderBg.Text, ptLong );
      end;

  except
    gLog.Add(lkUser, '�����ֹ�', 'CheckColor', 'exception' ) ; 
  end;
end;


procedure TDoubleOrderConfigDialog.EditQtyEnter(Sender: TObject);
begin
  //
  // showMessage(  (Sender as TEdit).Text ); 
end;

procedure TDoubleOrderConfigDialog.EditQytExit(Sender: TObject);
var
  aEdit : TEdit ;
  stColor : String ; 
begin

  if not (Sender is TEdit) then exit ;
  //
  aEdit := Sender as TEdit ;
  stColor := aEdit.Text ;

  try
    aEdit.Text :=  GetColorStr(StringToColor( stColor) );
    CheckColor(Sender); 
  except
    showMessage('�Է��� Color��  Ȯ���ϼ���' );
    aEdit.SetFocus ; 
    exit ; 
  end;

end;


procedure TDoubleOrderConfigDialog.EditMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  aEdit : TEdit ;
begin

  aEdit := Sender as TEdit ;
  //   
  if Button = mbRight then
  begin
    // -- ColorDialog
    if ColorDialog.Execute then
    begin
      aEdit.Text := GetColorStr(ColorDialog.Color);
      CheckColor(Sender); 
    end;

  end;

end;


end.
