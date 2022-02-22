unit DDoubleOrderConfig ;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin, Dialogs, Math, ComCtrls, IdGlobal,  
  //
  HelpCentral, AppConsts, AppTypes, License, EFData, LogCentral, OrderTablet;

type
  TDoubleOrderConfig = record
    // data 
    OrderQtyRowCnt : Integer; // 주문수량 설정수

    // visible 
    VisibleUnder : Boolean;         // 기초자산 선택 표시
    VisibleOHL : Boolean;           // O/H/L/K200 표시
    VisibleEvalPL : Boolean;        // 손익/수수료 표시
    VisibleOrderAmt : Boolean;      // 주문가능금액 표시
    VisibleQT : Boolean;            // 최대 선행잔량 표시
    VisibleZapr : Boolean;          // 옵션적정가 표시
    // enable 
    EnableQtyClick : Boolean;       // 포지션 정보에서 수량 선택(더블클릭)
    EnableEscape : Boolean;         // [Esc] : 주문 전체 취소
    EnableOneFive : Boolean;        // 1~5 키 사용
    EnableClearOrder : Boolean;     // 청산연동
    AutoScroll : Boolean;           // 자동 스크롤

    OrderRightButton : Boolean ;    // 마우스 오른쪽 버튼으로 주문내기
    MouseTrace : Boolean ;          // 마우스 포인터 위치 행사가에 표시하기
    ConfirmOrder: Boolean;          // 주문확인

    // 좌우 패널 
    VisibleTicks : array[TSideType] of Boolean;   // 종목체결 표시
    FillFilter : array[TSideType] of Boolean;     // 체결필터
    TickCnt : array[TSideType] of Integer;        // 체결 수
    FillCnt : array[TSideType] of Integer;        // 필터수량

    // 좌우,  Tablet Config
    OrderLeft : array[TSideType] of TPositionType ;     // 가격열 왼쪽에 매수냐? 매도냐?
    QtySide : array[TSideType] of TSideType ;           // 통합열 위치
    VisibleOrder : array[TSideType] of Boolean ;        // 주문열
    QtyMerge : array[TSideType] of Boolean ;            // 잔량 통합
    PriceOrderby : array[TSideType] of TPriceOrderbyType ;  // 가격열 오름차순/내림차순

    // 2007.05.21 IV
    VisibleIV : Array[TSideType] of Boolean ; //  IV 열  

    // 색상
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

    gLog.Add(lkUser, '더블주문', '매도잔량 색상', 'Default Font : ' + stDefFont ) ;
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

    gLog.Add(lkUser, '더블주문', '매도잔량 색상', 'Default Bg : ' + stDefBg ) ;
    aEdit.Color := StringToColor(stDefBg) ;
  end; 
end;


procedure TDoubleOrderConfigDialog.SetConfig(aConfig:  TDoubleOrderConfig);
begin
  FConfig := aConfig;
  
  with FConfig do
  begin

    // -- 주문설정
    // 주문확인
    CheckConfirmOrder.Checked:= ConfirmOrder ;
    // 주문수량 설정수
    if OrderQtyRowCnt < MIN_ORDER_QTY_ROW_CNT then
      OrderQtyRowCnt := MIN_ORDER_QTY_ROW_CNT;
    
    // 자동 스크롤
    CheckAutoScroll.Checked := AutoScroll;
    // 마우스 포인터 위치 행사가에 표시하기
    CheckMouseTrace.Checked := MouseTrace ; 
    // 포지션 정보에서 수량 선택(더블클릭)
    CheckQtyClick.Checked := EnableQtyClick;
    // 최대 선행잔량 표시
    CheckQT.Checked := VisibleQT ;
    // 마우스 오른쪽 버튼으로 주문내기 
    CheckOrderRightButton.Checked := OrderRightButton ; 

    // -- 기타설정 
    CheckUnder.Checked := VisibleUnder;           // 기초자산 선택 표시
    CheckOrderAmt.Checked := VisibleOrderAmt;     // 주문가능금액 표시
    CheckZapr.Checked := VisibleZapr;             // 옵션적정가 표시

    // 2007.03.11 Spin
    // SpinFillCnt.Value := FillCnt;                 // 필터수량
    CheckOneFive.Checked := EnableOneFive;        // 1~5 키 사용
    CheckUseEscape.Checked := EnableEscape ;      // ESC 
    CheckClearOrder.Checked := EnableClearOrder;  // 청산연동

    CheckLeftTicks.Checked := VisibleTicks[stLeft];  // 종목체결 표시
    CheckLeftFillFilter.Checked := FillFilter[stLeft];       // 체결필터
    EditLeftFillCnt.Text := IntToStr(FillCnt[stLeft]) ;    // 필터수량
    EditLeftTickCnt.Text := IntToStr(TickCnt[stLeft]);     // 체결수

    CheckRightTicks.Checked := VisibleTicks[stRight];  // 종목체결 표시
    CheckRightFillFilter.Checked := FillFilter[stRight];       // 체결필터
    EditRightFillCnt.Text := IntToStr(FillCnt[stRight]) ;    // 필터수량
    EditRightTickCnt.Text := IntToStr(TickCnt[stRight]);     // 체결수

    // Left Tablet
    CheckLeftVisibleOrder.Checked := VisibleOrder[stLeft] ;    // 주문열
    CheckLeftQtyMerge.Checked := QtyMerge[stLeft] ;             // 잔량 통합
    CheckLeftVisibleIV.Checked := VisibleIV[stLeft] ;  //  IV

    // 가격열 오름차순/내림차순
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
    CheckRightVisibleOrder.Checked := VisibleOrder[stRight] ;    // 주문열
    CheckRightQtyMerge.Checked := QtyMerge[stRight] ;             // 잔량 통합
    CheckRightVisibleIV.Checked := VisibleIV[stRight] ;    //  IV
    
    // 가격열 오름차순/내림차순
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
    ShowMessage('양쪽 모두 Auto 금지!' ); 
    exit;
  end;

  EditQytExit(EditShortQtyBg);
  EditQytExit(EditLongQtyBg);
  EditQytExit(EditShortOrderBg);
  EditQytExit(EditLongOrderBg);

  with FConfig do
  begin
    // -- 주문설정
    ConfirmOrder := CheckConfirmOrder.Checked  ;    // 주문확인
    AutoScroll := CheckAutoScroll.Checked  ;        // 자동 스크롤  
    MouseTrace := CheckMouseTrace.Checked ;         // 마우스 포인터 위치 행사가에 표시하기
    EnableQtyClick := CheckQtyClick.Checked ;       // 포지션 정보에서 수량 선택(더블클릭)  
    VisibleQT := CheckQT.Checked ;                  // 최대 선행잔량 표시
    OrderRightButton := CheckOrderRightButton.Checked ;   // 마우스 오른쪽 버튼으로 주문내기 
    // -- 기타설정
    VisibleUnder := CheckUnder.Checked;           // 기초자산 선택 표시
    VisibleOrderAmt := CheckOrderAmt.Checked;     // 주문가능금액 표시
    VisibleZapr := CheckZapr.Checked;             // 옵션적정가 표시

    EnableEscape := CheckUseEscape.Checked ;     // ESC
    EnableOneFive := CheckOneFive.Checked;        // 1~5 키 사용
    EnableClearOrder := CheckClearOrder.Checked;  // 청산연동

    VisibleTicks[stLeft] := CheckLeftTicks.Checked;       // 종목체결 표시
    TickCnt[stLeft] := StrToInt( EditLeftTickCnt.Text) ;  // 체결수
    FillFilter[stLeft] := CheckLeftFillFilter.Checked;    // 체결필터
    FillCnt[stLeft] := StrToInt( EditLeftFillCnt.Text) ;  // 필터수량

    VisibleTicks[stRight] := CheckRightTicks.Checked;       // 종목체결 표시
    TickCnt[stRight] := StrToInt( EditRightTickCnt.Text) ;  // 체결수
    FillFilter[stRight] := CheckRightFillFilter.Checked;    // 체결필터
    FillCnt[stRight] := StrToInt( EditRightFillCnt.Text) ;  // 필터수량

    // -- Left Tablet
    VisibleOrder[stLeft] := CheckLeftVisibleOrder.Checked ;    // 주문열
    QtyMerge[stLeft] := CheckLeftQtyMerge.Checked ;             // 잔량 통합
    VisibleIV[stLeft] := CheckLeftVisibleIV.Checked ; //  IV 

    // 가격열 오름차순(일반적)/내림차순
    // 오름차순 : 가격열 왼쪽에 매도, 내림차순 : 가격열 왼쪽에 매수
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
    VisibleOrder[stRight] := CheckRightVisibleOrder.Checked ;    // 주문열
    QtyMerge[stRight] := CheckRightQtyMerge.Checked ;             // 잔량 통합
    VisibleIV[stRight] := CheckRightVisibleIV.Checked ; //  IV

    // 가격열 오름차순(일반적)/내림차순
    // 오름차순 : 가격열 왼쪽에 매도, 내림차순 : 가격열 왼쪽에 매수 
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
    gLog.Add(lkUser, '더블주문', 'CheckColor', 'exception' ) ; 
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
    showMessage('입력한 Color를  확인하세요' );
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
