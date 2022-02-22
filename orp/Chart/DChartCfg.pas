unit DChartCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Spin, StdCtrls, Buttons, ColorGrd, ExtCtrls,
  GleConsts, ComCtrls;

type
  TChartConfig = class(TForm)
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    GroupBox2: TGroupBox;
    CheckHLine: TCheckBox;
    CheckVLine: TCheckBox;
    GroupBox3: TGroupBox;
    CheckLeft: TCheckBox;
    CheckRight: TCheckBox;
    SpinCharCount: TSpinEdit;
    Label5: TLabel;
    Bevel1: TBevel;
    GroupBox4: TGroupBox;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    ButtonBkColor: TSpeedButton;
    ButtonFont: TSpeedButton;
    GroupBox1: TGroupBox;
    PaintPreview: TPaintBox;
    ButtonGridColor: TSpeedButton;
    ButtonAxisColor: TSpeedButton;
    Button1: TButton;
    GroupBox5: TGroupBox;
    EditMargin: TEdit;
    Label2: TLabel;
    UpDownMargin: TUpDown;
    GroupBox6: TGroupBox;
    CheckDrawSeparator: TCheckBox;
    Label1: TLabel;
    EditBarWidth: TEdit;
    UpDownBarWidth: TUpDown;
    CheckProgressMargin: TCheckBox;
    procedure PaintPreviewPaint(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonBkColorClick(Sender: TObject);
    procedure ButtonFontClick(Sender: TObject);
    procedure ButtonGridColorClick(Sender: TObject);
    procedure ButtonAxisColorClick(Sender: TObject);
    procedure CheckClick(Sender: TObject);
    procedure SpinCharCountChange(Sender: TObject);
    procedure CheckDrawSeparatorClick(Sender: TObject);
    procedure CheckProgressMarginClick(Sender: TObject);
  private
    FBkColor : TColor;     // 배경색
    FFontName : String;    // 폰트명
    FFontSize : Integer;   // 폰트크기
    FFontColor : TColor;   // 폰트색
    FGridColor : TColor;   // 격자색
    FAxisColor : TColor;   // 축색
    FCharCount : Integer;
    FMovingMode: Boolean;
    FBarWidth: Integer;
    FInsertSeparartor: Boolean;
    FRightMargin: Integer;
    function GetHLine: Boolean;
    function GetLeftYScale: Boolean;
    function GetRightYScale: Boolean;
    function GetVLine: Boolean;
    procedure SetCharCount(const Value: Integer);
    procedure SetHLine(const Value: Boolean);
    procedure SetLeftYScale(const Value: Boolean);
    procedure SetRightYScale(const Value: Boolean);
    procedure SetVLine(const Value: Boolean);
    procedure SetBarWidth(const Value: Integer);
    procedure SetInsertSeparator(const Value: Boolean);
    procedure SetMovingMode(const Value: Boolean);
    procedure SetRightMargin(const Value: Integer);  // 글자크기
  public
    property BkColor : TColor read FBkColor write FBkColor;
    property AxisColor : TColor read FAxisColor write FAxisColor;
    property FontName : String read FFontName write FFontName;
    property FontSize : Integer read FFontSize write FFontSize;
    property FontColor : TColor read FFontColor write FFontColor;
    property HLine : Boolean read GetHLine write SetHLine;
    property VLine : Boolean read GetVLine write SetVLine;
    property GridColor : TColor read FGridColor write FGridColor;
    property LeftYScale : Boolean read GetLeftYScale write SetLeftYScale;
    property RightYScale : Boolean read GetRightYScale write SetRightYScale;
    property CharCount : Integer read FCharCount write SetCharCount;

    property MovingMode : Boolean read FMovingMode write SetMovingMode;
    property BarWidth : Integer read FBarWidth write SetBarWidth;
    property RightMargin : Integer read FRightMargin write SetRightMargin;
    property InsertSeparator : Boolean read FInsertSeparartor write SetInsertSeparator;
  end;


implementation

{$R *.DFM}

//-----------------------< UI Events : Draw >----------------------//

// Preview
procedure TChartConfig.PaintPreviewPaint(Sender: TObject);
var
  aClientRect : TRect;
  aDrawRect : TRect;
  iCharWidth, iWidth : Integer;
  iX, iY, iXGrid, iYGrid : Integer;
  stText : String;
begin
  with PaintPreview.Canvas do
  begin
    // color & font
    Brush.Color := FBkColor;
    Font.Name := FFontName;
    Font.Size := FFontSize;
    Font.Color := FFontColor;
    // area
    iCharWidth := TextWidth('8');
    aClientRect := PaintPreview.ClientRect;
    aDrawRect := aClientRect;
    aDrawRect.Bottom := aClientRect.Bottom - 20;
    if LeftYScale then
      aDrawRect.Left := aClientRect.Left + FCharCount * iCharWidth + 5;
    if RightYScale then
      aDrawRect.Right := aClientRect.Right - FCharCount * iCharWidth - 5;
    //-- background
    FillRect(aClientRect);
    //-- grids
    Pen.Color := FGridColor;
    if VLine then
    begin
      iXGrid := (aDrawRect.Right - aDrawRect.Left) div 3;
      iX := aDrawRect.Left + iXGrid;
      MoveTo(iX, aDrawRect.Top); LineTo(iX, aDrawRect.Bottom);
      iX := aDrawRect.Left + iXGrid * 2;
      MoveTo(iX, aDrawRect.Top); LineTo(iX, aDrawRect.Bottom);
    end;
    if HLine then
    begin
      iYGrid := (aDrawRect.Bottom - aDrawRect.Top) div 3;
      iY := aDrawRect.Top + iYGrid;
      MoveTo(aDrawRect.Left, iY); LineTo(aDrawRect.Right, iY);
      iY := aDrawRect.Top + iYGrid * 2;
      MoveTo(aDrawRect.Left, iY); LineTo(aDrawRect.Right, iY);
    end;
    //-- x-axis
    Pen.Color := FAxisColor;
    MoveTo(aClientRect.Left, aDrawRect.Bottom);
    LineTo(aClientRect.Right, aDrawRect.Bottom);
    TextOut(aDrawRect.Left + 5, aDrawRect.Bottom + 5, '09:00');
    //-- y-axis
    if LeftYScale then
    begin
      MoveTo(aDrawRect.Left, aDrawRect.Top);
      LineTo(aDrawRect.Left, aDrawRect.Bottom);
      stText := Format('%*.*d',[FCharCount, FCharCount, FCharCount]);
      iWidth := TextWidth(stText);
      TextOut(aDrawRect.Left - 5 - iWidth, aDrawRect.Top + 5, stText);
    end;
    if RightYScale then
    begin
      MoveTo(aDrawRect.Right, aDrawRect.Top);
      LineTo(aDrawRect.Right, aDrawRect.Bottom);
      stText := Format('%*.*d',[FCharCount, FCharCount, FCharCount]);
      iWidth := TextWidth(stText);
      TextOut(aDrawRect.Right + 5, aDrawRect.Top + 5, stText);
    end;
    //-- scale
    TextOut(aDrawRect.Left + 5, aDrawRect.Top + 5,
             FFontName + ' Size : ' + IntToStr(FFontSize));
  end;
end;

//-----------------------< UI Events : Buttons >------------------//

procedure TChartConfig.ButtonOKClick(Sender: TObject);
var
  iTmpBarWidth : Integer;
  iTmpMargin : Integer;
begin
  try
    iTmpBarWidth := StrToInt(EditBarWidth.Text);
    if (iTmpBarWidth < 1) or (iTmpBarWidth > 21) then
    begin
      ShowMessage('봉간격은 1-21 사이가 되어야 합니다.' + #13 +
        '다시 입력하세요');
      EditBarWidth.Text := IntToStr(FBarWidth);
      EditBarWidth.SetFocus;
      Exit;
    end;
  except
    ShowMessage('봉간격에 값에 잘못된 값이 있습니다.' + #13 + '다시 입력하세요');
    EditBarWidth.Text := IntToStr(FBarWidth);
    EditBarWidth.SetFocus;
    Exit;
  end;
  FBarWidth := iTmpBarWidth;

  try
    iTmpMargin := StrToInt(EditMargin.Text);
    if (iTmpMargin < 0) or (iTmpMargin > 30) then
    begin
      ShowMessage('오른쪽 여백의 범위에 벗어났습니다.' + #13 + '범위는 0 - 30 까지 입니다.');
      EditMargin.Text := IntToStr(FRightMargin);
      EditMargin.SetFocus;
      Exit;
    end;
  except
    ShowMessage('오른쪽 여백에 잘못된 값을 입력하셨습니다'+#13+'다시 입력하세요');
    EditMargin.Text := IntToStr(FRightMargin);
    EditMargin.SetFocus;
    Exit;
  end;
  FRightMargin := iTmpMargin;

  ModalResult := mrOK;
end;

procedure TChartConfig.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

//-------------------< UI Events : Selection >--------------------//

// 배경색
procedure TChartConfig.ButtonBkColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FBkColor := ColorDialog.Color;
    PaintPreview.Refresh;
  end;
end;

// 폰트
procedure TChartConfig.ButtonFontClick(Sender: TObject);
begin
  FontDialog.Font.Name := FFontName;
  FontDialog.Font.Color := FFontColor;
  FontDialog.Font.Size := FFontSize;
  if FontDialog.Execute then
  begin
    FFontName := FontDialog.Font.Name;
    FFontSize := FontDialog.Font.Size;
    FFontColor := FontDialog.Font.Color;
    PaintPreview.Refresh;
  end;
end;

// 격자색
procedure TChartConfig.ButtonGridColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FGridColor := ColorDialog.Color;
    PaintPreview.Refresh;
  end;
end;

// 세로축
procedure TChartConfig.ButtonAxisColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FAxisColor := ColorDialog.Color;
    PaintPreview.Refresh;
  end;
end;

// Y축 너비
procedure TChartConfig.SpinCharCountChange(Sender: TObject);
begin
  FCharCount := SpinCharCount.Value;
  PaintPreview.Refresh;
end;

// 기타선택
procedure TChartConfig.CheckClick(Sender: TObject);
begin
  PaintPreview.Refresh;
end;

//-------------------< Private Methods : Property >---------------//

function TChartConfig.GetHLine: Boolean;
begin
  Result := CheckHLine.Checked;
end;

function TChartConfig.GetLeftYScale: Boolean;
begin
  Result := CheckLeft.Checked;
end;

function TChartConfig.GetRightYScale: Boolean;
begin
  Result := CheckRight.Checked;
end;

function TChartConfig.GetVLine: Boolean;
begin
  Result := CheckVLine.Checked;
end;

procedure TChartConfig.SetCharCount(const Value: Integer);
begin
  FCharCount := Value;
  SpinCharCount.Value := Value;
end;

procedure TChartConfig.SetHLine(const Value: Boolean);
begin
  CheckHLine.Checked := Value;
end;

procedure TChartConfig.SetLeftYScale(const Value: Boolean);
begin
  CheckLeft.Checked := Value;
end;

procedure TChartConfig.SetRightYScale(const Value: Boolean);
begin
  CheckRight.Checked := Value;
end;

procedure TChartConfig.SetVLine(const Value: Boolean);
begin
  CheckVLine.Checked := Value;
end;


procedure TChartConfig.CheckDrawSeparatorClick(Sender: TObject);
begin
  FInsertSeparartor := CheckDrawSeparator.Checked;
end;

procedure TChartConfig.SetBarWidth(const Value: Integer);
begin
  FBarWidth := Value;
  UpDownBarWidth.Position := Value;
  //EditBarWidth.Text := IntToStr(Value);
end;

procedure TChartConfig.SetInsertSeparator(const Value: Boolean);
begin
  FInsertSeparartor := Value;
  if Value then
    CheckDrawSeparator.Checked := True
  else
    CheckDrawSeparator.Checked := False;
end;

procedure TChartConfig.SetMovingMode(const Value: Boolean);
begin
  FMovingMode := Value;
  CheckProgressMargin.Checked := Value;
end;

procedure TChartConfig.SetRightMargin(const Value: Integer);
begin
  FRightMargin := Value;
  UpDownMargin.Position := Value;
  EditMargin.Text := IntToStr(Value);
end;

procedure TChartConfig.CheckProgressMarginClick(Sender: TObject);
begin
  FMovingMode := CheckProgressMargin.Checked;
  if FMovingMode then
  begin
    EditMargin.Enabled := False;
    UpDownMargin.Enabled := False;
  end else
  begin
    EditMargin.Enabled := True;
    UpDownMargin.Enabled := True;
  end;
end;

end.
