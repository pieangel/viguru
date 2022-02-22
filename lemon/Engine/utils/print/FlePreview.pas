unit FlePreview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Printers,

    // lemon: printer
  ClePrinterTypes;

type
  TPreviewStyle = (psFitIn, psWidthFit, psOneOnOne);

  TPrintPreview = class(TForm)
    Panel1: TPanel;
    SpeedButtonFit: TSpeedButton;
    SpeedButtonFull: TSpeedButton;
    SpeedButtonWidth: TSpeedButton;
    ButtonFirst: TSpeedButton;
    ButtonPrior: TSpeedButton;
    LabelPage: TLabel;
    Bevel1: TBevel;
    ButtonNext: TSpeedButton;
    ButtonLast: TSpeedButton;
    SpeedButtonPrint: TSpeedButton;
    SpeedButtonSave: TSpeedButton;
    SpeedButton1: TSpeedButton;
    PrinterSetupDialog: TPrinterSetupDialog;
    PrintDialog: TPrintDialog;
    SpeedButton2: TSpeedButton;
    Image: TImage;
    PaintBG: TPaintBox;
    procedure SpeedButtonClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FConfig : TPrinterConfig;

    FPrintTitle : String;

    FMetafile : TMetafile;
    FXDisplayRatio,
    FYDisplayRatio : Double;

    FPaperRect : TRect;
    FPrintRect : TRect;
    FImageRect : TRect;
    
    FPreviewStyle : TPreviewStyle;
    
    FRatio : Single;
    FOnPrint, FOnSave : TNotifyEvent;
    FOnFirst, FOnPrior, FOnNext, FOnLast : TNotifyEvent;
      // Property Helpers
    procedure SetTitle(Value : String);
    procedure SetNavButtons(iCurrentPage, iTotalPage : Integer);
      // View Size
    procedure DrawFitInWindow;
    procedure DrawFullSize;
    procedure DrawPaperWidth;
      //
    procedure SetConfig(Value : TPrinterConfig);
    procedure RefreshPreview;
  public
      // Controlling Navigating Buttons
    procedure DrawPage(mfPage : TMetafile;
                       iCurrentPage, iTotalPage : Integer);
    procedure Display(Value : TPreviewStyle);

    property Title : String write SetTitle;
    property Ratio : Single read FRatio write FRatio;

    property Config : TPrinterConfig read FConfig write SetConfig;
    
    property OnPrint : TNotifyEvent read FOnPrint write FOnPrint;
    property OnSave  : TNotifyEvent read FOnSave  write FOnSave;

    property OnFirst : TNotifyEvent read FOnFirst write FOnFirst;
    property OnPrior : TNotifyEvent read FOnPrior write FOnPrior;
    property OnNext  : TNotifyEvent read FOnNext  write FOnNext;
    property OnLast  : TNotifyEvent read FOnLast  write FOnLast;
  end;

implementation

const
  V_MARGIN = 20;
  H_MARGIN = 20;


{$R *.DFM}


procedure TPrintPreview.SetNavButtons(iCurrentPage, iTotalPage : Integer);
begin
  ButtonFirst.Enabled := (iCurrentPage > 0);
  ButtonPrior.Enabled := (iCurrentPage > 0);
  ButtonLast.Enabled := (iCurrentPage < iTotalPage - 1);
  ButtonNext.Enabled := (iCurrentPage < iTotalPage - 1);
end;

//-------------------------< Property routines >-------------------------//

procedure TPrintPreview.SetTitle(Value : String);
begin
  Self.Caption := 'Preview : ' + Value;
  FPrintTitle := Value;
end;

procedure TPrintPreview.SetConfig(Value : TPrinterConfig);
begin
  FConfig := Value;
end;

procedure TPrintPreview.RefreshPreview;
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

  dWR := PaintBG.Width / Printer.PageWidth;
  dHR := PaintBG.Height / Printer.PageHeight;

  //-- set paper view 
  if dWR < dHR then
  begin
    FPaperRect.Left := PaintBG.ClientRect.Left + MIN_MARGIN;
    FPaperRect.Right := PaintBG.ClientRect.Right - MIN_MARGIN;
    iMargin :=  Round((PaintBG.Height -
                       (FPaperRect.Right - FPaperRect.Left) * dAspectRatio) / 2);
    FPaperRect.Top := PaintBG.ClientRect.Top + iMargin;
    FPaperRect.Bottom := PaintBG.ClientRect.Bottom - iMargin;
  end else
  begin
    FPaperRect.Top := PaintBG.ClientRect.Top + MIN_MARGIN;
    FPaperRect.Bottom := PaintBG.ClientRect.Bottom - MIN_MARGIN;
    iMargin :=  Round((PaintBG.Width -
                       (FPaperRect.Bottom - FPaperRect.Top) / dAspectRatio) / 2);
    FPaperRect.Left := PaintBG.ClientRect.Left + iMargin;
    FPaperRect.Right := PaintBG.ClientRect.Right - iMargin;
  end;

  //-- set ratio
  dXRatio := Printer.PageWidth / (FPaperRect.Right - FPaperRect.Left);
  dYRatio := Printer.PageHeight / (FPaperRect.Bottom - FPaperRect.Top);

  iPixelsX := GetDeviceCaps(Printer.Handle, LogPixelsX);
  iPixelsY := GetDeviceCaps(Printer.Handle, LogPixelsY);
  dXZoom :=  iPixelsX / Screen.PixelsPerInch;
  dYZoom :=  iPixelsY / Screen.PixelsPerInch;

  FXDisplayRatio :=  (FPaperRect.Right-FPaperRect.Left) * dXZoom / Printer.PageWidth;
  FYDisplayRatio :=  (FPaperRect.Bottom-FPaperRect.Top) * dYZoom / Printer.PageHeight;

  //-- set margin view
  rMargin.Left   := Round((FConfig.LeftMargin / 2.54) * iPixelsX / dXRatio);
  rMargin.Top    := Round((FConfig.TopMargin / 2.54) * iPixelsY / dYRatio);
  rMargin.Right  := Round((FConfig.RightMargin / 2.54) * iPixelsX / dXRatio);
  rMargin.Bottom := Round((FConfig.BottomMargin / 2.54) * iPixelsY / dYRatio);

  //-- set print view
  FPrintRect.Left := FPaperRect.Left + rMargin.Left;
  FPrintRect.Top := FPaperRect.Top + rMargin.Top;
  FPrintRect.Right := FPaperRect.Right - rMargin.Right;
  FPrintRect.Bottom := FPaperRect.Bottom - rMargin.Bottom;

  //-- set image view
  FImageRect := FPrintRect;
  FImageRect.Top := FImageRect.Top +
                     Round((FConfig.TitleMargin / 2.54) * iPixelsY / dYRatio);

  Image.Left := FImageRect.Left + PaintBG.Left;
  Image.Top := FImageRect.Top + PaintBG.Top;
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
end;

//-------------------------< Set View >-----------------------------------//

procedure TPrintPreview.DrawPage( mfPage : TMetafile;
                                 iCurrentPage, iTotalPage : Integer );
begin
  Image.Picture.Metafile.Assign(mfPage);

  LabelPage.Caption := IntToStr(iCurrentPage+1) + '/' + IntToStr(iTotalPage);
  SetNavButtons(iCurrentPage, iTotalPage);

  Refresh;
end;


{*********************************************
       Change View Mode
 *********************************************}

procedure TPrintPreview.FormPaint(Sender: TObject);
var
  stCopyRight : String;
  aSize : TSize;
  aTitleRect : TRect;
  aMetafileCanvas : TMetafileCanvas;
begin
  // draw background
  with PaintBG.Canvas do
  begin
    Brush.Color := clBtnFace;
    FillRect(ClientRect);
    // paper shadow
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
    // paper border
    Pen.Style := psDot;
    Pen.Color := clBlack;
    Rectangle(FPrintRect);
  end;

  // set dimension of image
  RefreshPreview;

  // draw title
  with PaintBG.Canvas do
  begin
    // title
    Font.Name := 'Tahoma';
    Font.Size := 8;
    Font.Color := clBlack;

    aSize := TextExtent(FPrintTitle);
    aTitleRect := Rect(FPrintRect.Left+1, FPrintRect.Top+1,
                       FPrintRect.Left + Round(aSize.cx * FXDisplayRatio) + 1,
                       FPrintRect.Top + Round(aSize.cy * FYDisplayRatio) + 1);

    FMetafile.Width := aSize.cx;
    FMetafile.Height := aSize.cy;

    aMetafileCanvas := TMetafileCanvas.Create(FMetafile, 0);
    with aMetafileCanvas do
    begin
      Font.Name := 'Tahoma';
      Font.Size := 8;
      Font.Color := clBlack;
      TextOut(0,0, FPrintTitle);
    end;
    aMetafileCanvas.Free;

    StretchDraw(aTitleRect, FMetafile);

    // copyright
    stCopyRight := 'Powered by Lemon Engine (' +
                   FormatDateTime('mm/dd/yyyy hh:nn:ss', Now) + ')';
    aSize := TextExtent(stCopyRight);
    aTitleRect.Right  := FImageRect.Left + Image.Width;
    aTitleRect.Left   := aTitleRect.Right - Round(aSize.cx * FXDisplayRatio);
    aTitleRect.Top    := FImageRect.Top + Image.Height + 5;
    aTitleRect.Bottom := aTitleRect.Top + Round(aSize.cy * FYDisplayRatio);

    FMetafile.Width := aSize.cx;
    FMetafile.Height := aSize.cy;

    aMetafileCanvas := TMetafileCanvas.Create(FMetafile, 0);
    with aMetafileCanvas do
    begin
      Font.Name := 'Tahoma';
      Font.Size := 8;
      Font.Color := clBlack;
      TextOut(0,0, stCopyRight);
    end;
    aMetafileCanvas.Free;

    StretchDraw(aTitleRect, FMetafile);
  end;
end;

procedure TPrintPreview.Display(Value : TPreviewStyle);
begin
  FPreviewStyle := Value;

  case FPreviewStyle of
    psFitIn : DrawFitInWindow;
    psWidthFit  : DrawPaperWidth;
    psOneOnOne  : DrawFullSize;
  end;
end;

procedure TPrintPreview.DrawFitInWindow;
var
  dViewRatio : Double;
  iWidth, iHeight : Integer;
begin // Fit in Window
  dViewRatio := ClientHeight / ClientWidth;
  if dViewRatio < FRatio then
  begin
    iHeight := (ClientHeight-100-V_MARGIN);
    iWidth := Round( iHeight / FRatio );
  end else
  begin
    iWidth := ClientWidth-100;
    iHeight := Round( iWidth * FRatio );
  end;
{
  if FRatio >= 1.0 then
  begin
    iHeight := (ClientHeight-100-TopMargin);
    iWidth := Round( iHeight / FRatio );
  end else
  begin
    iWidth := ClientWidth-100;
    iHeight := Round( iWidth * FRatio );
  end;
}

  with Image do
  begin
    AutoSize := False;
    Stretch := True;
    Left := (Self.ClientWidth-iWidth) div 2;
    Top := V_MARGIN + 50;
    Width := iWidth;
    Height := iHeight;
  end;
  Refresh;
end;

procedure TPrintPreview.DrawFullSize;
begin // 100% (Image.Width := Bitmap.Width
  with Image do
  begin
    AutoSize := True;
    Left := 0;
    Top := V_MARGIN;
  end;
  Refresh;
end;

procedure TPrintPreview.DrawPaperWidth;
begin // Preview Form.Width := Image.Width
  with Image do
  begin
    AutoSize := False;
    Left := H_MARGIN;
    Top := V_MARGIN;
    Width := Self.ClientWidth;
    Height := Round(Width * FRatio);
  end;
  Refresh;
end;

{************************************
      Command Buttons
 ************************************}

procedure TPrintPreview.SpeedButtonClick(Sender: TObject);
begin
  case (Sender as TSpeedButton).Tag of
    // Display Option
    101: Display(psFitIn);
    102: Display(psOneOnOne);
    103: Display(psWidthFit);
    // Navigation
    201: if Assigned(FOnFirst) then FOnFirst(Sender);
    202: if Assigned(FOnPrior) then FOnPrior(Sender);
    203: if Assigned(FOnNext) then FOnNext(Sender);
    204: if Assigned(FOnLast) then FOnLast(Sender);
    // Output
    301: if PrintDialog.Execute then
           if Assigned(FOnPrint) then FOnPrint(Sender);
    302: if Assigned(FOnSave) then FOnSave(Sender);
    303: if PrinterSetupDialog.Execute then
           Display(FPreviewStyle);
    // Exit
    900: Close;
  end;
end;

procedure TPrintPreview.FormCreate(Sender: TObject);
begin
  FMetafile := TMetafile.Create;
  FMetafile.Enhanced := True;
end;

procedure TPrintPreview.FormDestroy(Sender: TObject);
begin
  FMetafile.Free;
end;

end.
