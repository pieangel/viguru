unit ClePrinter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs,  ExtCtrls, StdCtrls, Buttons, Printers,

    // lemon: printer
  ClePrinterTypes, FlePreview, DlePrintDlg;

type
  TPrintingMode = (pmPrint, pmPreview, pmSetup);

  TPrinterLe = class
  private
    FConfig : TPrinterConfig;

    FMetafile : TMetafile;
    FMetafileCanvas : TMetafileCanvas;
    FCurrentPage : Integer;
    FTotalPage : Integer;

    FWidth : Integer;
    FHeight : Integer;

    FXRatio, FYRatio : Single;
    FTitle : String;
    FPreview : TPrintPreview;
    FPixelsPerInch : SmallInt;

    FMode : TPrintingMode;
    FPrinting : Boolean;

      // property methods
    function GetCanvas : TCanvas;
    procedure SetTitle(stTitle:String);
    function GetPage: Integer;
    procedure NewCanvas;

      // manage temporary metafiles
    procedure SaveToFile(iPage:Integer);
    procedure LoadFromFile(iPage:Integer);
    procedure WipeFiles(iPage:Integer);
    procedure ClearTmpFiles( Sender : TObject );

      // print & preview 
    procedure Print;
    procedure PreviewToScreen;
    procedure Preview;
    procedure SetPage(iPage : Integer);
    procedure Setup;

      // preview event handlers
    procedure PrintProc(Sender : TObject);
    procedure PreviewProc(Sender : TObject);
    procedure SaveProc(Sender : TObject);
    procedure FirstProc(Sender : TObject);
    procedure PriorProc(Sender : TObject);
    procedure NextProc(Sender : TObject);
    procedure LastProc(Sender : TObject);
  public
    constructor Create; virtual;
    destructor Destroy; override;

      //
    procedure PrintForm(aForm : TForm);

      // check
    function CanPrint : Boolean;
    procedure SetDimension(iWidth, iHeight : Integer);

      // Commands
    procedure BeginDoc;
    procedure EndDoc;
    procedure NewPage;
    procedure Abort;

      // environment
    property Canvas: TCanvas read GetCanvas;
    property Mode: TPrintingMode read  FMode write FMode;

      //
    property Title: String read FTitle write SetTitle;
    property Page: Integer read GetPage;
    property TotalPage: Integer read FTotalPage;
    property CurrentPage: Integer read FCurrentPage;
    property Printing: Boolean read FPrinting write FPrinting;
  end;

function PrinterLE : TPrinterLE;

procedure srDrawString( Canvas : TCanvas;
                  iX, iY, iWidth : Integer;
                  stText : String;
                  taValue : TAlignMent );
procedure srDrawBoxString( Canvas : TCanvas;
                  iX, iY, iWidth, iHeight : Integer;
                  stText : String;
                  taValue : TAlignMent );

implementation

function MakeNumStr( iNumber, iLen : Integer) : String; forward;

const
  TmpFileHead = 'FXXX' ;
  TmpFileTail = '.EMF' ;

  TextMargin = 5; // pixel

var
  NPrinter : TPrinterLe;

function PrinterLE : TPrinterLe;
begin
  if not Assigned(NPrinter) then
    NPrinter := TPrinterLe.Create;
  Result := NPrinter;
end;


procedure srDrawString( Canvas : TCanvas;
                  iX, iY, iWidth : Integer;
                  stText : String;
                  taValue : TAlignment );
var
  x : Integer;
begin
  if (not Assigned(Canvas)) then Exit;
  case taValue of
    taLeftJustify : x := iX+TextMargin;
    taCenter : x := iX + (iWidth-Canvas.TextWidth(stText)) div 2;
    taRightJustify : x := iX + iWidth - Canvas.TextWidth(stText)-TextMargin;
  end;
  Canvas.TextOut(x, iY, stText);
end;

procedure srDrawBoxString( Canvas : TCanvas;
                  iX, iY, iWidth, iHeight : Integer;
                  stText : String;
                  taValue : TAlignMent );
begin
  Canvas.Rectangle( iX, iY, iX+iWidth+1, iY+iHeight+1 );
  srDrawString(Canvas, iX, iY+TextMargin, iWidth, stText, taValue);
end;

//-------------------< Property routines >----------------------------//

function TPrinterLe.GetCanvas : TCanvas;
begin
  Result := FMetafileCanvas;
end;

procedure TPrinterLe.SetTitle(stTitle:String);
begin
  FTitle := stTitle;
end;

//-------------------< Create / Destroy >-----------------------------//

constructor TPrinterLe.Create;
var
  szDevice, szDriver, szPort : array[0..50] of char;
  DeviceMode: THandle;
  DevMode: PDeviceMode;
begin
  FMode := pmPrint;

  FMetafile := TMetafile.Create;
  FMetafile.Enhanced := True;
  FTotalPage := 0;
  FPrinting := False;

  with FConfig do
  begin
    FitInPage := True;
    TitleMargin   := 1.0;
    LeftMargin    := 1.2; // in cm
    TopMargin     := 2.3;
    RightMargin   := 1.2;
    BottomMargin  := 1.2;

    {to get a current printer settings}
    try
      Printer.GetPrinter(szDevice+0, szDriver+0, szPort+0, DeviceMode);
    except
      Exit;
    end;

    DevMode := GlobalLock(DeviceMode);
    if DevMode^.dmColor = DMCOLOR_COLOR then
      UseColor := True
    else
      UseColor := False;
    GlobalUnlock(DeviceMode);
  end;
end;

destructor TPrinterLe.Destroy;
begin
  ClearTmpFiles( nil );
  FMetafile.Free;
end;

procedure TPrinterLe.PrintForm(aForm : TForm);
begin
  try
    if not CanPrint then
    begin
      ShowMessage('No printers installed.');
      Exit;
    end;

    Mode := pmSetup;
    Title := aForm.Caption;
    SetDimension(aForm.ClientWidth, aForm.ClientHeight);

    BeginDoc;
    Canvas.CopyRect(aForm.ClientRect, aForm.Canvas, aForm.ClientRect);
    EndDoc;
  except
    ShowMessage('Failed to print. Check the printers.');
  end;
end;

//----------------------< Public methods >---------------------------//

function TPrinterLe.CanPrint : Boolean;
begin
  Result := (Printer.Printers.Count > 0);
end;

procedure TPrinterLe.SetDimension(iWidth, iHeight : Integer);
begin
  FWidth := iWidth;
  FHeight := iHeight;

  FMetafile.Width := iWidth;
  FMetafile.Height := iHeight+50;
end;

procedure TPrinterLe.BeginDoc;
begin
  if (not CanPrint) or FPrinting then Exit;

  // Preview 화면 생성
  FPreview := TPrintPreview.Create(nil);
  with FPreview do
  begin
    FPixelsPerInch := PixelsPerInch;
    OnPrint := PrintProc;
    OnSave  := SaveProc;
    OnFirst := FirstProc;
    OnPrior := PriorProc;
    OnNext  := NextProc;
    OnLast  := LastProc;
    OnDestroy := ClearTmpFiles;
  end;

  FXRatio := ( GetDeviceCaps(Printer.Handle, LogPixelsX) /
               FPixelsPerInch );
  FYRatio := ( GetDeviceCaps(Printer.Handle, LogPixelsY) /
               FPixelsPerInch );

  with FMetafile do
  begin
//    Width  := Round( Printer.PageWidth / FXRatio ); // in pixels
//    Height := Round( Printer.PageHeight / FYRatio ); // in pixels
    FPreview.Ratio := Height/Width;
  end;

  ClearTmpFiles( nil );

  NewCanvas;
  FTotalPage := 1;
  FCurrentPage := 0;
  FPrinting := True;
end;

procedure TPrinterLe.EndDoc;
begin
  if (not CanPrint) or (not FPrinting) then Exit;

  FMetafileCanvas.Free;
  SaveToFile(FCurrentPage);
  FCurrentPage := 0;
  case FMode of
    pmPreview : begin
        FPreview.Config := FConfig;
        PreviewToScreen;
        Preview;
      end;
    pmPrint : Print;
    pmSetup : Setup;
  end;
  ClearTmpFiles(nil);
  FPreview.Free;
  FPrinting := False;
end;

procedure TPrinterLe.NewPage;
begin
  FMetafileCanvas.Free;
  SaveToFile(FCurrentPage);
  NewCanvas;
  FTotalPage := FTotalPage + 1;
  FCurrentPage := FCurrentPage + 1;
end;

procedure TPrinterLe.Abort;
begin
  if not FPrinting then Exit;

  FMetafileCanvas.Free;

  ClearTmpFiles( nil );
  FPreview.Free;
  FPrinting := False;

  FTotalPage := 0;
  FCurrentPage := -1;
end;

procedure TPrinterLe.NewCanvas;
begin
  FMetafileCanvas := TMetafileCanvas.Create(FMetafile,0);
  with FMetafileCanvas do
  begin
    FloodFill(1,1, clWhite, fsBorder);
  end;
end;

//-----------------------< Manage temporary files >---------------------//

procedure TPrinterLe.WipeFiles(iPage:Integer);
var
  i : Integer;
begin
  for i:=0 to iPage-1 do
  try
    DeleteFile( TmpFileHead + MakeNumStr(i,4) + TmpFileTail );
  except
    ;
  end;
end;

procedure TPrinterLe.ClearTmpFiles( Sender : TObject );
begin
  if FTotalPage > 0 then
    WipeFiles( FTotalPage );

  FTotalPage := 0;
end;

procedure TPrinterLe.SaveToFile(iPage:Integer);
begin
  FMetafile.SaveToFile(TmpFileHead +
                       MakeNumStr(iPage,4) +
                       TmpFileTail);
end;

procedure TPrinterLe.LoadFromFile(iPage:Integer);
begin
  FMetafile.LoadFromFile(TmpFileHead +
                         MakeNumStr(iPage,4) +
                         TmpFileTail);
end;

//----------------------------------------------------------< print & preview >

procedure TPrinterLe.Setup;
var
  aDlg : TPrintDialogLE;
begin
  if FTotalPage <= 0 then Exit;

  aDlg := TPrintDialogLE.Create(Application.MainForm);
  try
    LoadFromFile(FCurrentPage);

    aDlg.DrawPage(FMetaFile);
    aDlg.Config := FConfig;
    aDlg.OnPreview := PreviewProc;

    if aDlg.ShowModal = mrOK then
    begin
      FConfig := aDlg.Config;

      Print;
    end;
  finally
    aDlg.Free;
  end;
end;

procedure TPrinterLe.Print;
begin
  PrintProc( nil );
end;

procedure TPrinterLe.PreviewToScreen;
begin
  LoadFromFile(FCurrentPage);
  FPreview.DrawPage(FMetafile, FCurrentPage, FTotalPage);
end;

procedure TPrinterLe.Preview;
begin
  FPreview.Title := FTitle;
  FPreview.ShowModal;
end;

procedure TPrinterLe.PreviewProc(Sender: TObject);
begin
  PreviewToScreen;

  FPreview.Config := (Sender as TPrintDialogLE).Config;
  Preview;
end;

procedure SetColorPrinter(aConfig: TPrinterConfig);
var
  szDevice, szDriver, szPort : array[0..50] of char;
  DeviceMode: THandle;
  DevMode: PDeviceMode;
begin
  {to get a current printer settings}
  Printer.GetPrinter(szDevice+0, szDriver+0, szPort+0, DeviceMode);
  {lock a printer device}
  DevMode := GlobalLock(DeviceMode);

  if aConfig.UseColor then
    DevMode^.dmColor := DMCOLOR_COLOR
  else
    DevMode^.dmColor := DMCOLOR_MONOCHROME;

  (*
  {set a paper size as A4-Transverse}
  if ((DevMode^.dmFields and DM_PAPERSIZE) = DM_PAPERSIZE) then
  begin
    DevMode^.dmFields := DevMode^.dmFields or DM_PAPERSIZE;
    DevMode^.dmPaperSize := DMPAPER_A4_TRANSVERSE;
  end;

  {set a paper source as Tractor bin}
  if  ((DevMode^.dmFields and DM_DEFAULTSOURCE) = DM_DEFAULTSOURCE) then
  begin
    DevMode^.dmFields := DevMode^.dmFields or DM_DEFAULTSOURCE;
    DevMode^.dmDefaultSource := DMBIN_TRACTOR;
  end;

  {set a Landscape orientation}
  if  ((DevMode^.dmFields and DM_ORIENTATION) = DM_ORIENTATION) then
  begin
    DevMode^.dmFields := DevMode^.dmFields or DM_ORIENTATION;
    DevMode^.dmOrientation := DMORIENT_LANDSCAPE;
  end;
  *)
  {set a printer settings}
  Printer.SetPrinter(szDevice, szDriver, szPort, DeviceMode);

  {unlock a device}
  GlobalUnlock(DeviceMode);
end;


procedure TPrinterLe.PrintProc(Sender : TObject);
var
  i : Integer;
  iPixelsX, iPixelsY : Integer;
  dWR, dHR, dXZoom, dYZoom, dAspectRatio : Double;
  aPaperRect, aMarginRect, aPrintRect, aImageRect, aCopyRect : TRect;
  stCopyRight : String;
  aSize : TSize;
begin
    SetColorPrinter(FConfig);
  //-- get dimension
    // get entire area
    aPaperRect.Left := 0;
    aPaperRect.Right := Printer.PageWidth-1;
    aPaperRect.Top := 0;
    aPaperRect.Bottom := Printer.PageHeight-1;
    // get Dots per inch
    iPixelsX := GetDeviceCaps(Printer.Handle, LogPixelsX);
    iPixelsY := GetDeviceCaps(Printer.Handle, LogPixelsY);
    // get zoom rates from screen to printer
    dXZoom :=  iPixelsX / Screen.PixelsPerInch;
    dYZoom :=  iPixelsY / Screen.PixelsPerInch;
    // get margin
    aMarginRect.Left   := Round((FConfig.LeftMargin / 2.54) * iPixelsX);
    aMarginRect.Top    := Round((FConfig.TopMargin / 2.54) * iPixelsY);
    aMarginRect.Right  := Round((FConfig.RightMargin / 2.54) * iPixelsX);
    aMarginRect.Bottom := Round((FConfig.BottomMargin / 2.54) * iPixelsY);
    // get printable area
    aPrintRect.Left := aPaperRect.Left + aMarginRect.Left;
    aPrintRect.Top := aPaperRect.Top + aMarginRect.Top;
    aPrintRect.Right := aPaperRect.Right - aMarginRect.Right;
    aPrintRect.Bottom := aPaperRect.Bottom - aMarginRect.Bottom;
    // get image-drawble area
    aImageRect := aPrintRect;
    aImageRect.Top := aImageRect.Top + Round((FConfig.TitleMargin / 2.54) * iPixelsY);

  //-- set title & begin
  Printer.Title := FTitle;
  Printer.BeginDoc;

  //-- load images and print out
  for i:=0 to FTotalPage - 1 do
  begin
    LoadFromFile(i);
      //---------- get image location  & size --------------//
        aCopyRect := aImageRect;
        if FConfig.FitInPage then
        begin
          dAspectRatio := FMetafile.Height / FMetafile.Width;
          dWR := (aImageRect.Right - aImageRect.Left) / FMetafile.Width;
          dHR := (aImageRect.Bottom - aImageRect.Top) / FMetafile.Height;
          if dWR < dHR then // fit to horizontal
          begin
            aCopyRect.Bottom := aCopyRect.Top +
                         Round((aCopyRect.Right-aCopyRect.Left)*dAspectRatio);
          end else          // fit to vertial
          begin
            aCopyRect.Right := aCopyRect.Left +
                         Round((aCopyRect.Bottom-aCopyRect.Top)/dAspectRatio);
          end;
        end else
        begin
          aCopyRect.Right := aCopyRect.Left + Round(FMetafile.Width * dXZoom);
          aCopyRect.Bottom := aCopyRect.Top + Round(FMetafile.Height * dYZoom);
        end;
      //---------- printing ----------------------//
        with Printer.Canvas do
        begin
          // title
          Font.Name := 'Tahoma';
          Font.Size := 8;
          Font.Color := clBlack;
          TextOut(aPrintRect.Left, aPrintRect.Top, FTitle);
          // copyright
          stCopyRight := 'Powered By Guru Engine (' +
                         FormatDateTime('mm/dd/yyyy hh:nn:ss', Now) + ')';
          aSize := TextExtent(stCopyRight);
          TextOut(aCopyRect.Right-aSize.cx-1, aCopyRect.Bottom+5, stCopyRight);
        end;

        // charts 
        Printer.Canvas.StretchDraw(aCopyRect, FMetafile);
    //-----------------------------------------//
    if i < FTotalPage-1 then
      Printer.NewPage;
  end;
  Printer.EndDoc;
end;

procedure TPrinterLe.SaveProc(Sender : TObject);
begin
  // To be implemented
end;

//---------------------------------------------------------------< navigation >

procedure TPrinterLe.SetPage(iPage : Integer);
begin
  if (iPage >= 0) and (iPage <= FTotalPage-1) then
  begin
    FCurrentPage := iPage;
    PreviewToScreen;
  end;
end;

procedure TPrinterLe.FirstProc(Sender : TObject);
begin
  SetPage(0);
end;

procedure TPrinterLe.PriorProc(Sender : TObject);
begin
  if FCurrentPage > 0 then
    SetPage(FCurrentPage - 1);
end;

procedure TPrinterLe.NextProc(Sender : TObject);
begin
  if FCurrentPage < FTotalPage - 1 then
    SetPage(FCurrentPage + 1);
end;

procedure TPrinterLe.LastProc(Sender : TObject);
begin
  SetPage(FTotalPage - 1);
end;

//-----------------------------------------------------------< miscellaneous >

function TPrinterLe.GetPage : Integer;
begin
  Result := FCurrentPage;
end;

function MakeNumStr( iNumber, iLen : Integer) : String;
var
  i, iDigit : Integer;
begin
  iDigit := 10;
  if iLen >= 2 then
  for i:=2 to iLen do
    iDigit := iDigit * 10;

  Result := '';
  for i:=1 to iLen do
  begin
    iNumber := iNumber mod iDigit;
    iDigit := iDigit  div 10;
    Result := Result + IntToStr( iNumber div iDigit );
  end;
end;


initialization

finalization

  if Assigned(NPrinter) then NPrinter.Free;

end.
