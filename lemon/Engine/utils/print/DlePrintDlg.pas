unit DlePrintDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Printers,

    // lemon: printer
  ClePrinterTypes;

type
  TPrintDialogLe = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ComboPrinter: TComboBox;
    GroupBox2: TGroupBox;
    SpinCopies: TSpinEdit;
    GroupBox3: TGroupBox;
    RadioLandscape: TRadioButton;
    RadioPortrait: TRadioButton;
    GroupBox4: TGroupBox;
    CheckFitInPage: TCheckBox;
    GroupBox5: TGroupBox;
    PaintPreview: TPaintBox;
    Image: TImage;
    ButtonOK: TButton;
    Button3: TButton;
    EditTop: TEdit;
    EditBottom: TEdit;
    EditLeft: TEdit;
    EditRight: TEdit;
    CheckBoxGrayScale: TCheckBox;
    procedure PreviewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditMarginExit(Sender: TObject);
    procedure RadioOrientationClick(Sender: TObject);
    procedure ComboPrinterClick(Sender: TObject);
    procedure SpinCopiesChange(Sender: TObject);
    procedure EditMarginChange(Sender: TObject);
    procedure CheckFitInPageClick(Sender: TObject);
    procedure PaintPreviewPaint(Sender: TObject);
    procedure RadioColorClick(Sender: TObject);
  private
    FConfig : TPrinterConfig;
    FOnPreview : TNotifyEvent;

    FPaperRect : TRect;
    FPrintRect : TRect; // margin applied
    FImageRect : TRect; // area only for graph
    FTitleMargin : Double;

    procedure SetConfig(Value : TPrinterConfig);
    procedure RefreshPreview;
  public
    procedure DrawPage(mfPage : TMetafile);

    property OnPreview : TNotifyEvent read FOnPreview write FOnPreview;
    property Config : TPrinterConfig read FConfig write SetConfig;
  end;

var
  PrintDialogLe: TPrintDialogLe;

implementation

{$R *.DFM}

{ TXPrintDialog }

//------------------------< Init >-----------------------------------//

procedure TPrintDialogLe.FormCreate(Sender: TObject);
begin
  ComboPrinter.Items.Assign(Printer.Printers);
  ComboPrinter.ItemIndex := Printer.PrinterIndex;
  SpinCopies.Value := Printer.Copies;
  RadioPortrait.Checked := (Printer.Orientation = poPortrait);
  RadioLandscape.Checked := (Printer.Orientation = poLandscape);
end;

//---------------------< Public Methods >---------------------------//

procedure TPrintDialogLe.DrawPage(mfPage: TMetafile);
begin
  Image.Picture.Metafile.Assign(mfPage);
  Refresh;
end;

procedure TPrintDialogLe.SetConfig(Value : TPrinterConfig);
begin
  FConfig := Value;

  CheckBoxGrayScale.Checked := not Value.UseColor;
  CheckFitInPage.Checked := Value.FitInpage;
  EditLeft.Text   := Format('%.1f',[Value.LeftMargin]);
  EditTop.Text    := Format('%.1f',[Value.TopMargin]);
  EditRight.Text  := Format('%.1f',[Value.RightMargin]);
  EditBottom.Text := Format('%.1f',[Value.BottomMargin]);

  RefreshPreview;
end;

//-----------------------< Preview >----------------------------------//

// big preview
procedure TPrintDialogLe.PreviewClick(Sender: TObject);
begin
  if Assigned(FOnPreview) then
    FOnPreview(Self);
end;

procedure TPrintDialogLe.RefreshPreview;
const
  MIN_MARGIN = 20;
var
  dAspectRatio,
  dXRatio, dYRatio,
  dXZoom, dYZoom,
  dWR, dHR : Double;
  iMargin : Integer;
  rMargin : TRect;
  iPixelsX, iPixelsY : Integer;
begin
  dAspectRatio := Printer.PageHeight / Printer.PageWidth;

  dWR := PaintPreview.Width / Printer.PageWidth;
  dHR := PaintPreview.Height / Printer.PageHeight;

  if dWR < dHR then
  begin
    FPaperRect.Left := PaintPreview.ClientRect.Left + MIN_MARGIN;
    FPaperRect.Right := PaintPreview.ClientRect.Right - MIN_MARGIN;
    iMargin :=  Round((PaintPreview.Height -
                       (FPaperRect.Right - FPaperRect.Left) * dAspectRatio) / 2);
    FPaperRect.Top := PaintPreview.ClientRect.Top + iMargin;
    FPaperRect.Bottom := PaintPreview.ClientRect.Bottom - iMargin;
  end else
  begin
    FPaperRect.Top := PaintPreview.ClientRect.Top + MIN_MARGIN;
    FPaperRect.Bottom := PaintPreview.ClientRect.Bottom - MIN_MARGIN;
    iMargin :=  Round((PaintPreview.Width -
                       (FPaperRect.Bottom - FPaperRect.Top) / dAspectRatio) / 2);
    FPaperRect.Left := PaintPreview.ClientRect.Left + iMargin;
    FPaperRect.Right := PaintPreview.ClientRect.Right - iMargin;
  end;

  dXRatio := Printer.PageWidth / (FPaperRect.Right - FPaperRect.Left);
  dYRatio := Printer.PageHeight / (FPaperRect.Bottom - FPaperRect.Top);

  iPixelsX := GetDeviceCaps(Printer.Handle, LogPixelsX);
  iPixelsY := GetDeviceCaps(Printer.Handle, LogPixelsY);
  dXZoom :=  iPixelsX / Screen.PixelsPerInch;
  dYZoom :=  iPixelsY / Screen.PixelsPerInch;

  rMargin.Left   := Round((FConfig.LeftMargin / 2.54) * iPixelsX / dXRatio);
  rMargin.Top    := Round((FConfig.TopMargin / 2.54) * iPixelsY / dYRatio);
  rMargin.Right  := Round((FConfig.RightMargin / 2.54) * iPixelsX / dXRatio);
  rMargin.Bottom := Round((FConfig.BottomMargin / 2.54) * iPixelsY / dYRatio);

  FPrintRect.Left := FPaperRect.Left + rMargin.Left;
  FPrintRect.Top := FPaperRect.Top + rMargin.Top;
  FPrintRect.Right := FPaperRect.Right - rMargin.Right;
  FPrintRect.Bottom := FPaperRect.Bottom - rMargin.Bottom;

  FImageRect := FPrintRect;
  FImageRect.Top := FImageRect.Top +
                      Round((FConfig.TitleMargin / 2.54) * iPixelsY / dYRatio);

  Image.Left := FImageRect.Left + PaintPreview.Left;
  Image.Top := FImageRect.Top + PaintPreview.Top;
  if FConfig.FitInPage then
  begin
    dWR := (FImageRect.Right - FImageRect.Left) / Image.Picture.Width;
    dHR := (FImageRect.Bottom - FImageRect.Top) / Image.Picture.Height;
    if dWR < dHR then // fit to horizontal
    begin
      Image.Width := (FImageRect.Right - FImageRect.Left);
      Image.Height := Round(Image.Width * (Image.Picture.Height /Image.Picture.Width));
    end else          // fit to vertial
    begin
      Image.Height := (FImageRect.Bottom - FImageRect.Top);
      Image.Width := Round(Image.Height * (Image.Picture.Width / Image.Picture.Height));
    end;
  end else
  begin
    Image.Width := Round(Image.Picture.Width * dXZoom / dXRatio);
    Image.Height := Round(Image.Picture.Height * dYZoom / dYRatio);
  end;

  PaintPreview.Refresh;
end;

procedure TPrintDialogLe.PaintPreviewPaint(Sender: TObject);
begin
  with PaintPreview.Canvas do
  begin
    // shadow
    Pen.Style := psSolid;
    Pen.Color := $888888;
    Brush.Color := $888888;
    Rectangle(Rect(FPaperRect.Left + 4,
                   FPaperRect.Top + 4,
                   FPaperRect.Right + 4,
                   FPaperRect.Bottom + 4));
    Pen.Color := clBlue;
    Brush.Color := clWhite;
    Rectangle(FPaperRect);
    // paper
    Pen.Style := psDot;
    Pen.Color := clBlack;
    Rectangle(FPrintRect);
  end;
end;

//------------------------< Setup Page >----------------------------//

procedure TPrintDialogLe.EditMarginExit(Sender: TObject);
begin
  if (Sender as TEdit).Text = '' then Exit;

  try
    StrToFloat((Sender as TEdit).Text);
  except
    ShowMessage('입력값이 부적절합니다.');
    (Sender as TEdit).SetFocus;
  end;
end;

procedure TPrintDialogLe.EditMarginChange(Sender: TObject);
  function GetEditValue(stText : String) : Double;
  begin
    if stText = '' then
      Result := 0.0
    else
    try
      Result := StrToFloat(stText);
    except
      Result := 0.0;
    end;
  end;
begin
  case (Sender as TComponent).Tag of
    100 : FConfig.TopMargin    := GetEditValue(EditTop.Text);
    200 : FConfig.BottomMargin := GetEditValue(EditBottom.Text);
    300 : FConfig.LeftMargin   := GetEditValue(EditLeft.Text);
    400 : FConfig.RightMargin  := GetEditValue(EditRight.Text);
  end;

  RefreshPreview;
end;

procedure TPrintDialogLe.CheckFitInPageClick(Sender: TObject);
begin
  FConfig.FitInPage := CheckFitInPage.Checked;

  RefreshPreview;
end;

//------------------------< Setup Printer >----------------------------//

procedure TPrintDialogLe.RadioOrientationClick(Sender: TObject);
begin
  if RadioPortrait.Checked then
    Printer.Orientation := poPortrait
  else
    Printer.Orientation := poLandscape;

  RefreshPreview;
end;

procedure TPrintDialogLe.ComboPrinterClick(Sender: TObject);
begin
  Printer.PrinterIndex := ComboPrinter.ItemIndex;

  RefreshPreview;
end;

procedure TPrintDialogLe.SpinCopiesChange(Sender: TObject);
begin
  Printer.Copies := SpinCopies.Value;
end;

procedure TPrintDialogLe.RadioColorClick(Sender: TObject);
begin
  FConfig.UseColor := not CheckBoxGrayScale.Checked;
end;

end.
