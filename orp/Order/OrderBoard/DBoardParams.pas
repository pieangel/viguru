unit DBoardParams ;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin, Dialogs, Math, ComCtrls, IdGlobal;

const
  clColor  = $0000FF;
  csColor  = $993333;
  clxColor = $FFFF33;
  cSxColor = $0066FF;

type
  TOrientationType = ( otAuto, otAsc, otDesc );

  TOrderBoardParams = record

    ShowTNS   : Boolean;      // TNS = Time & Sales,  ShowTNS: Boolean;   // 종목체결 표시
    TNSOnLeft : Boolean;      // Side
    TNSRowCount: Integer;     // TickCnt: Integer;        // 체결 수

    OrdHigh, OrdWid : integer;
    FontSize        : integer;

    MergeQuoteColumns: Boolean;              // 잔량 통합
    MergedQuoteOnLeft: Boolean;              // 통합열 위치
      // show
    ShowOrderColumn: Boolean;                // 주문열
    ShowCountColumn: Boolean;                  // 건수열
    ShowStopColumn  : boolean;               // STOP 열
      //
    HideBottom      : boolean;
  end;

  TBoardParamDialog = class(TForm)
    ButtonOK: TButton;
    BtnCancel: TButton;
    GroupBox1: TGroupBox;
    CheckBoxShowTNS: TCheckBox;
    EditTNSRowCount: TEdit;
    GroupBox2: TGroupBox;
    CheckBoxShowOrderColumn: TCheckBox;
    cbStopOrder: TCheckBox;
    CheckBoxMergeQuoteColumns: TCheckBox;
    RadioButtonTNSRight: TRadioButton;
    RadioButtonTNSLeft: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    RadioButtonMergedQuoteLeft: TRadioButton;
    RadioButtonMergedQuoteRight: TRadioButton;
    edtOrdH: TLabeledEdit;
    edtOrdW: TLabeledEdit;
    Label29: TLabel;
    cbCountColumn: TCheckBox;
    edtFontSize: TLabeledEdit;
    udFontsize: TUpDown;
    cbHideBottom: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditNumericKeyPress(Sender: TObject; var Key: Char);
    procedure edtOrderHogaKeyPress(Sender: TObject; var Key: Char);

  private
    procedure SetParams(Value: TOrderBoardParams);
    function GetParams: TOrderBoardParams;
  public
    property Params: TOrderBoardParams read GetParams write SetParams;

  end;

implementation

{$R *.DFM}

{ TBoardParamDialog }

procedure TBoardParamDialog.edtOrderHogaKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['1'..'5', #8,#13]) then
    Key := #0;
end;

procedure TBoardParamDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

//----------------------------------------------------------------------< set >

procedure TBoardParamDialog.SetParams(Value: TOrderBoardParams);
begin
  with Value do
  begin

    CheckBoxShowTNS.Checked := ShowTNS;
    RadioButtonTNSLeft.Checked := TNSOnLeft;
    RadioButtonTNSRight.Checked := not TNSOnLeft;
    EditTNSRowCount.Text := IntToStr(TNSRowCount);

    CheckBoxShowOrderColumn.Checked := ShowOrderColumn;
    cbCountColumn.Checked := ShowCountColumn;
    cbStopOrder.Checked := ShowStopColumn;
    CheckBoxMergeQuoteColumns.Checked := MergeQuoteColumns;
    RadioButtonMergedQuoteLeft.Checked := MergedQuoteOnLeft;
    RadioButtonMergedQuoteRight.Checked := not MergedQuoteOnLeft;
      // time & sale
    edtOrdH.Text  := IntToStr( OrdHigh );
    edtOrdW.Text  := IntToStr( OrdWid );
    udFontSize.Position := FontSize;

    cbHideBottom.Checked  := HideBottom;
  end;
end;

//----------------------------------------------------------------------< get >

function TBoardParamDialog.GetParams: TOrderBoardParams;
begin
  with Result do
  begin

    ShowTNS     := CheckBoxShowTNS.Checked;           // show time & sale data
    TNSOnLeft   := RadioButtonTNSLeft.Checked;   // the position of time & sale table
    TNSRowCount := StrToIntDef(EditTNSRowCount.Text, 20);  // number of time & sale data to show

    OrdHigh := StrToIntDef( edtOrdH.Text, 18 );
    OrdWid  := StrToIntDef( edtOrdW.Text, 58 );
    FontSize := StrToIntDef( edtFontSize.Text , 9 );

    ShowOrderColumn := CheckBoxShowOrderColumn.Checked;
    ShowCountColumn := cbCountColumn.Checked;
    ShowStopColumn  := cbStopOrder.Checked;
    MergeQuoteColumns := CheckBoxMergeQuoteColumns.Checked ;
    MergedQuoteOnLeft := RadioButtonMergedQuoteLeft.Checked ;

    HideBottom  := cbHideBottom.Checked;
  end;
end;


procedure TBoardParamDialog.EditNumericKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;




end.
