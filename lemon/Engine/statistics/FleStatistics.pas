unit FleStatistics;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, CheckLst, Buttons, ComCtrls, Math,

  GleTypes, GleLib, ClePainter,
  CleStatistics;

type
  TStatTestCursorMode = (cmSelect, cmHair);

  TDistributionForm = class(TForm)
    Panel2: TPanel;
    Bevel1: TBevel;
    CheckListLegend: TCheckListBox;
    CheckBoxAll: TCheckBox;
    Panel5: TPanel;
    SpeedButtonExportDistribution: TSpeedButton;
    Panel3: TPanel;
    SaveDialog: TSaveDialog;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    PaintBoxChart: TPaintBox;
    SpeedButtonExportChiSqMap: TSpeedButton;
    Panel4: TPanel;
    SpeedButtonSelect: TSpeedButton;
    SpeedButtonHairs: TSpeedButton;
    RadioButtonPDF: TRadioButton;
    Bevel3: TBevel;
    RadioButtonCDF: TRadioButton;
    RadioButtonQuantile: TRadioButton;
    RadioButtonQQ: TRadioButton;
    RadioButtonChiSqMap: TRadioButton;
    TabSheet3: TTabSheet;
    MemoPercentiles: TMemo;
    TabSheet4: TTabSheet;
    PaintBoxParams: TPaintBox;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Bevel2: TBevel;
    CheckBoxMin: TCheckBox;
    CheckBoxMax: TCheckBox;
    CheckBoxMean: TCheckBox;
    CheckBoxStddev: TCheckBox;
    CheckBoxPcnt20: TCheckBox;
    CheckBoxPcnt40: TCheckBox;
    CheckBoxPcnt60: TCheckBox;
    CheckBoxPcnt80: TCheckBox;
    SpeedButton3: TSpeedButton;
    CheckBoxMS: TCheckBox;
    TabSheet5: TTabSheet;
    PaintBoxPTable: TPaintBox;
    Panel6: TPanel;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Bevel4: TBevel;
    SpeedButton6: TSpeedButton;
    RadioButtonMin: TRadioButton;
    RadioButtonMax: TRadioButton;
    RadioButtonMean: TRadioButton;
    RadioButtonStdDev: TRadioButton;
    RadioButton20: TRadioButton;
    RadioButton40: TRadioButton;
    RadioButton60: TRadioButton;
    RadioButton80: TRadioButton;
    RadioButtonMS: TRadioButton;
    procedure RadioButtonClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure CheckBoxParametersClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure SpeedButtonExportClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxChartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxChartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxChartPaint(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
    procedure CheckBoxAllClick(Sender: TObject);
  private
    FDFList: TDFSeriesCollection;

    FPainter: TPainter;

    FCursorMode: TStatTestCursorMode;

    FOnLog   : TTextNotifyEvent;
    procedure DrawParamTable;
    procedure DrawParameters;

    procedure ShowPercentiles;
    function GetDensityRange(var dMin, dMax: Double): Boolean;
    function GetPriceRange(var dMin, dMax: Double): Boolean;

    procedure DrawPDF;
    procedure DrawCDF;
    procedure DrawQ;
    procedure DrawQQ;
    procedure DrawChiSqMap;
    procedure Draw;

    procedure SelectSeries(X, Y: Integer);
  public
    procedure Reset;
    procedure Display;

    property DFList: TDFSeriesCollection read FDFList write FDFList;
    property OnLog : TTextNotifyEvent read FOnLog write FOnLog;
  end;

var
  DistributionForm: TDistributionForm;

implementation

{$R *.dfm}

{ TStatTestForm }

{$REGION ' Form Events '}

procedure TDistributionForm.FormCreate(Sender: TObject);
var
  aOwnerForm: TForm;
begin
  if (Owner <> nil) and (Owner is TForm) then
  begin
    aOwnerForm := Owner as TForm;

    Left := aOwnerForm.Left + aOwnerForm.Width;
    Top := aOwnerForm.Top;
  end;

  //FDFList := TDFSeriesCollection.Create;

    // painter
  FPainter := TPainter.Create;
  FPainter.SetMargin(50, 20, 50, 20);
  FPainter.XScaleSpacing := 60;
  FPainter.YScaleSpacing := 50;

  FPainter.SetDrawingArea(PaintBoxChart.ClientRect);
end;

procedure TDistributionForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TDistributionForm.FormDestroy(Sender: TObject);
begin
  FPainter.Free;
  //FDFList.Free;
end;

procedure TDistributionForm.FormResize(Sender: TObject);
begin
  Draw;
end;

procedure TDistributionForm.Reset;
begin
  if FDFList <> nil then
    FDFList.Reset;
  CheckListLegend.Items.Clear;
end;


procedure TDistributionForm.PaintBoxChartPaint(Sender: TObject);
begin
    //
  ShowPercentiles;
    //
  Draw;
end;

procedure TDistributionForm.CheckBoxParametersClick(Sender: TObject);
begin
  Draw;
end;

procedure TDistributionForm.RadioButtonClick(Sender: TObject);
begin
  Draw;
end;

procedure TDistributionForm.Display;
var
  i: Integer;
  aDF: TDFSeries;
begin
    // add legend
  CheckListLegend.Items.Clear;

  if FDFList = nil then Exit;

  for i := 0 to FDFList.Count - 1 do
  begin
    aDF := FDFList[i];
    CheckListLegend.Items.AddObject(aDF.Title, aDF);
    CheckListLegend.Checked[i] := True;
  end;

  CheckBoxAll.Checked := True;

    // chisq map
  //FDFList.MakeChiSqMap;

    //
  Draw;
    //
  ShowPercentiles;
    //
  Show;
end;

{$ENDREGION}

{$REGION ' Generate Data '}

procedure TDistributionForm.SpeedButton3Click(Sender: TObject);
var
//  aDF: TDFSeries;
  iRow, iCol, iQQ_Step: Integer;
  F: TextFile;
  stRecord: String;
begin
  if (FDFList = nil)
     or (FDFList.RowCount = 0)
     or (FDFList.ColCount = 0) then Exit;

  SaveDialog.Title := 'Export Parameters';
  SaveDialog.FileName := 'DF.Parameters.csv';
  SaveDialog.InitialDir := AppDir + '\output';

  if SaveDialog.Execute then
  begin
    AssignFile(F, SaveDialog.FileName);
    Rewrite(F);
    try
      iQQ_Step := QQ_SLOT_COUNT div 5;

        Writeln(F, '');
        Writeln(F, '');
      // Mean
        Writeln(F, '[Mean]');
          // column
        stRecord := '';
        for iCol := 0 to FDFList.ColCount-1 do
          stRecord := stRecord + ',' + FDFList.Table[iCol,0].ColTitle;
        Writeln(F, stRecord);
          // data
        for iRow := 0 to FDFList.RowCount - 1 do
        begin
          stRecord := FDFList.Table[0, iRow].RowTitle;
          for iCol := 0 to FDFList.ColCount - 1 do
            stRecord := stRecord
                     + Format(',%.6f',[FDFList.Table[iCol, iRow].Data.Mean]);
          Writeln(F, stRecord);
        end;

        Writeln(F, '');
        Writeln(F, '');
      // standard deviation
        Writeln(F, '[Standard Deviation]');
          // column
        stRecord := '';
        for iCol := 0 to FDFList.ColCount-1 do
          stRecord := stRecord + ',' + FDFList.Table[iCol,0].ColTitle;
        Writeln(F, stRecord);
          // data
        for iRow := 0 to FDFList.RowCount - 1 do
        begin
          stRecord := FDFList.Table[0, iRow].RowTitle;
          for iCol := 0 to FDFList.ColCount - 1 do
            stRecord := stRecord
                     + Format(',%.6f',[FDFList.Table[iCol, iRow].Data.StdDev]);
          Writeln(F, stRecord);
        end;

        Writeln(F, '');
        Writeln(F, '');
      // standard deviation
        Writeln(F, '[Mean + Standard Deviation(84.1%)]');
          // column
        stRecord := '';
        for iCol := 0 to FDFList.ColCount-1 do
          stRecord := stRecord + ',' + FDFList.Table[iCol,0].ColTitle;
        Writeln(F, stRecord);
          // data
        for iRow := 0 to FDFList.RowCount - 1 do
        begin
          stRecord := FDFList.Table[0, iRow].RowTitle;
          for iCol := 0 to FDFList.ColCount - 1 do
            stRecord := stRecord
                     + Format(',%.6f',[FDFList.Table[iCol, iRow].Data.Mean
                                      + FDFList.Table[iCol, iRow].Data.StdDev]);
          Writeln(F, stRecord);
        end;

        Writeln(F, '');
        Writeln(F, '');

      // 80%
        Writeln(F, '[80% Percentile]');
          // column
        stRecord := '';
        for iCol := 0 to FDFList.ColCount-1 do
          stRecord := stRecord + ',' + FDFList.Table[iCol,0].ColTitle;
        Writeln(F, stRecord);
          // data
        for iRow := 0 to FDFList.RowCount - 1 do
        begin
          stRecord := FDFList.Table[0, iRow].RowTitle;
          for iCol := 0 to FDFList.ColCount - 1 do
            stRecord := stRecord
                     + Format(',%.6f',[FDFList.Table[iCol, iRow].QQSlots[4*iQQ_Step-1]]);
          Writeln(F, stRecord);
        end;
    finally
      CloseFile(F);
    end;
  end;
end;

procedure TDistributionForm.SpeedButtonExportClick(Sender: TObject);
var
  aDF: TDFSeries;
  iTag: Integer;
begin
  if (CheckListLegend.ItemIndex < 0)
     or (FDFList = nil) then Exit;

  iTag := (Sender as TComponent).Tag;

  SaveDialog.Title := 'Export spread data';
  SaveDialog.InitialDir := AppDir + '\output';

  case iTag of
    200: // distribution
      begin
        aDF := FDFList[CheckListLegend.ItemIndex];
        if aDF <> nil then
        begin
          SaveDialog.FileName := 'DF.' + aDF.Title + '.csv';
          if SaveDialog.Execute then
            aDF.SaveToFile(SaveDialog.FileName);
        end;
      end;
    300: // Chi-Square Map
      begin
        SaveDialog.FileName := 'stat_chisq_map.csv';
        if SaveDialog.Execute then
          FDFList.SaveChiSqMapToFile(SaveDialog.FileName);
      end;
  end;
end;

procedure TDistributionForm.ShowPercentiles;
var
  aDF: TDFSeries;
  i: Integer;
begin
  MemoPercentiles.Lines.Clear;

  if (CheckListLegend.ItemIndex < 0)
     or (FDFList = nil) then Exit;

  aDF := FDFList[CheckListLegend.ItemIndex];
  MemoPercentiles.Lines.Add(Format('Min = %.4f', [aDF.Data.Min]));
  MemoPercentiles.Lines.Add(Format('Max = %.4f', [aDF.Data.Max]));
  MemoPercentiles.Lines.Add(Format('Mean = %.4f', [aDF.Data.Mean]));
  MemoPercentiles.Lines.Add(Format('StdDev = %.4f', [aDF.Data.StdDev]));
  for i := 0 to QQ_SLOT_COUNT div 4  - 1 do
    MemoPercentiles.Lines.Add(
      Format('QQ[%.2f],%.4f', [QQ_SLOT_STEP*((i+1)*4), aDF.QQSlots[(i+1)*4-1]]));
end;

{$ENDREGION}

{$REGION ' Draw '}
const

  COLOR_COUNT = 10;
  LINE_COLORS: array[0..COLOR_COUNT-1] of TColor = (
                                        clAqua, clFuchsia, clGreen, clLime,
                                        clMaroon, clMoneyGreen, clNavy, clOlive,
                                        clPurple, clTeal);


procedure TDistributionForm.PageControlChange(Sender: TObject);
begin
  Draw;
end;

procedure TDistributionForm.Draw;
begin
  if FDFList = nil then Exit;
  
    // set dimension
  case PageControl.TabIndex of
    0: FPainter.SetDrawingArea(PaintBoxChart.ClientRect);
    3: FPainter.SetDrawingArea(PaintBoxParams.ClientRect);
    4: FPainter.SetDrawingArea(PaintBoxPTable.ClientRect);
  end;

    // draw
  try
    FPainter.DrawBackground;

    case PageControl.TabIndex of
      0: // Stationarity
        if RadioButtonPDF.Checked then
          DrawPDF // PDF
        else if RadioButtonCDF.Checked then
          DrawCDF
        else if RadioButtonQuantile.Checked then
          DrawQ
        else if RadioButtonQQ.Checked then
          DrawQQ
        else if RadioButtonChiSqMap.Checked then
          DrawChiSqMap;
      3: // Statistical Parameters
        DrawParameters;
      4: // Statistical Parameters as table
        DrawParamTable;
    end;
  finally
    FPainter.DrawFrame;

    case PageControl.TabIndex of
      0: FPainter.Display(PaintBoxChart.Canvas);
      3: FPainter.Display(PaintBoxParams.Canvas);
      4: FPainter.Display(PaintBoxPTable.Canvas);
    end;
  end;
end;

procedure TDistributionForm.DrawPDF;
var
  i, j, iX, iY: Integer;
  dMin, dMax: Double;
  aDF: TDFSeries;
  aBin: TDFBin;
begin
  with FPainter do
  begin
    if not GetPriceRange(dMin, dMax) then
    begin
      FPainter.DrawMessage('No Data');
      Exit;
    end;

    SetXRatio(dMin, dMax);

    if not GetDensityRange(dMin, dMax) then
    begin
      FPainter.DrawMessage('No Data');
      Exit;
    end;

    SetYRatio(0, dMax);

    DrawAxis;

      // Draw Chart
    with DrawCanvas do
    begin
      for i := 0 to FDFList.Count - 1 do
      begin
        if (not CheckListLegend.Checked[i]) and
           (not CheckListLegend.Selected[i]) then Continue;

        aDF := FDFList[i];

        if CheckListLegend.Selected[i] then
        begin
          Pen.Color := clBlue;
          Pen.Width := 4;
        end else
        begin
          Pen.Color := LINE_COLORS[i mod COLOR_COUNT];
          Pen.Width := 1;
        end;

        for j := 0 to aDF.Bins.Count-1 do
        begin
          aBin := aDF.Bins[j];

          iX := GetXPos(aBin.Low+aDF.Bins.BinSize/2);
          iY := GetYPos(aBin.Density);

          if j = 0 then
            MoveTo(iX, iY)
          else
            LineTo(iX, iY);
        end;
      end;
    end;
  end;
end;

procedure TDistributionForm.DrawCDF;
var
  i, j, iX, iY: Integer;
  dMin, dMax: Double;
  aDF: TDFSeries;
  aBin: TDFBin;
begin
  with FPainter do
  begin
    if not GetPriceRange(dMin, dMax) then
    begin
      FPainter.DrawMessage('No Data');
      Exit;
    end;

    SetRatio(dMin, dMax, 0, 1.0);
    DrawAxis;

    with DrawCanvas do
    try
        // Draw Chart
      for i := 0 to FDFList.Count - 1 do
      begin
        if (not CheckListLegend.Checked[i]) and
           (not CheckListLegend.Selected[i]) then Continue;

        aDF := FDFList[i];

        if CheckListLegend.Selected[i] then
        begin
          Pen.Color := clBlue;
          Pen.Width := 4;
        end else
        begin
          Pen.Color := LINE_COLORS[i mod COLOR_COUNT];
          Pen.Width := 1;
        end;

        for j := 0 to aDF.Bins.Count-1 do
        begin
          aBin := aDF.Bins[j];

          iX := GetXPos(aBin.Low+aDF.Bins.BinSize/2);
          iY := GetYPos(aBin.Percentile);

          if j = 0 then
            MoveTo(iX, iY)
          else
            LineTo(iX, iY);
        end;
      end;
    finally

    end;
  end;
end;

procedure TDistributionForm.DrawQ;
var
  i, j, iX, iY: Integer;
  dMin, dMax: Double;
  aDF: TDFSeries;
  aBin: TDFBin;
begin
  with FPainter do
  begin
    SetXRatio(0, 1.0);

    if not GetPriceRange(dMin, dMax) then
    begin
      DrawMessage('No Data');
      Exit;
    end;

    SetYRatio(dMin, dMax);

    DrawAxis;

    with DrawCanvas do
    try
        // Draw Chart
      for i := 0 to FDFList.Count - 1 do
      begin
        if (not CheckListLegend.Checked[i]) and
           (not CheckListLegend.Selected[i]) then Continue;

        aDF := FDFList[i];

        if CheckListLegend.Selected[i] then
        begin
          Pen.Color := clBlue;
          Pen.Width := 4;
        end else
        begin
          Pen.Color := LINE_COLORS[i mod COLOR_COUNT];
          Pen.Width := 1;
        end;

        for j := 0 to aDF.Bins.Count-1 do
        begin
          aBin := aDF.Bins[j];

          iX := GetXPos(aBin.Percentile);
          iY := GetYPos(aBin.Low+aDF.Bins.BinSize/2);

          if j = 0 then
            MoveTo(iX, iY)
          else
            LineTo(iX, iY);
        end;
      end;
    finally

    end;
  end;
end;

procedure TDistributionForm.DrawQQ;
var
  i, j, iX, iY: Integer;
  dMin, dMax: Double;
  aDF, aDFRef: TDFSeries;
//  aBin: TDFBin;
begin
  with FPainter do
  begin
    if CheckListLegend.ItemIndex >= 0 then
      aDFRef := CheckListLegend.Items.Objects[CheckListLegend.ItemIndex] as TDFSeries
    else
    begin
      FPainter.DrawMessage('Not Selected');
      Exit;
    end;

    SetXRatio(aDFRef.Data.Min, aDFRef.Data.Max);

    if not GetPriceRange(dMin, dMax) then
    begin
      FPainter.DrawMessage('Nothing to compare');
      Exit;
    end;

    DrawXAxis;

    with DrawCanvas do
    try
      Pen.Width := 1;
      Pen.Color := clBlack;
      MoveTo(DrawRect.Left, DrawRect.Bottom);
      LineTo(DrawRect.Right, DrawRect.Top);

      for i := 0 to FDFList.Count - 1 do
      begin
        if (not CheckListLegend.Checked[i]) and
           (not CheckListLegend.Selected[i]) then Continue;

        aDF := FDFList[i];

        if aDF = aDFRef then Continue;

        SetYRatio(aDF.Data.Min, aDF.Data.Max);

        Pen.Color := LINE_COLORS[i mod COLOR_COUNT];
        Pen.Width := 1;

        for j := 0 to QQ_SLOT_COUNT - 2 do
        begin
          iX := GetXPos(aDFRef.QQSlots[j]);
          iY := GetYPos(aDF.QQSlots[j]);

          Rectangle(iX-1, iY-1, iX+1, iY+1);
          if j = 0 then
            MoveTo(iX, iY)
          else
            LineTo(iX, iY);
        end;
      end;
    finally

    end;
  end;
end;

procedure TDistributionForm.DrawChiSqMap;
var
  i, j, iX, iY, iCellWidth, iCellHeight: Integer;
//  dMin, dMax: Double;
//  aDF, aDFRef: TDFSeries;
//  aBin: TDFBin;
begin
  with FPainter do
  begin
    if FDFList.ChiSqCount <= 0 then
    begin
      FPainter.DrawMessage('No map to draw');
      Exit;
    end;

    SetRatio(0, FDFList.ChiSqCount, 0, FDFList.ChiSqCount);

    iCellWidth := (DrawRect.Right - DrawRect.Left-1) div FDFList.ChiSqCount;
    iCellHeight := (DrawRect.Bottom - DrawRect.Top-1) div FDFList.ChiSqCount;

    with DrawCanvas do
    for i := 0 to FDFList.ChiSqCount - 1 do
      for j := 0 to FDFList.ChiSqCount - 1 do
      begin
        iX := GetXPos(j);
        iY := GetYPos(i);
        //Brush.Color := Round($FF * (FChiSqMap[i,j]/FChiSqMax))*$10000;
        if FDFList.ChiSqMap[i,j] < 18.475 then
          Brush.Color := clGreen
        else
          Brush.Color := clBlue +
               (255-Round(FDFList.ChiSqMap[i,j]/FDFList.ChiSqMax*255)) * $0101;

        Pen.Color := Brush.Color;
        Rectangle(iX, iY, iX + iCellWidth + 1, iY - iCellHeight - 1);
      end;

    DrawAxis;
  end;
end;

procedure TDistributionForm.DrawParameters;
var
  i, iCount, iQQ_Step, iLineCount: Integer;
  aDF: TDFSeries;
  dMin, dMax: Double;

  procedure SetRange(dValue: Double);
  begin
    if iCount > 0 then
    begin
      dMin := Math.Min(dMin, dValue);
      dMax := Math.Max(dMax, dValue);
    end else
    begin
      dMin := dValue;
      dMax := dValue;
    end;
    
    Inc(iCount);
  end;
begin
  with FPainter do
  begin
      // check
    if FDFList.Count = 0 then
    begin
      FPainter.DrawMessage('No DF');
      Exit;
    end;

      // get range
    iCount := 0;
    dMin := 0.0;
    dMax := 0.0;
    iQQ_Step := QQ_SLOT_COUNT div 5;

    for i := 0 to FDFList.Count - 1 do
    begin
      aDF := FDFList[i];

      if CheckBoxMin.Checked then SetRange(aDF.Data.Min);
      if CheckBoxMax.Checked then SetRange(aDF.Data.Max);
      if CheckBoxMean.Checked then SetRange(aDF.Data.Mean);
      if CheckBoxStdDev.Checked then SetRange(aDF.Data.StdDev);
      if CheckBoxPcnt20.Checked then SetRange(aDF.QQSlots[iQQ_Step-1]);
      if CheckBoxPcnt40.Checked then SetRange(aDF.QQSlots[2*iQQ_Step-1]);
      if CheckBoxPcnt60.Checked then SetRange(aDF.QQSlots[3*iQQ_Step-1]);
      if CheckBoxPcnt80.Checked then SetRange(aDF.QQSlots[4*iQQ_Step-1]);
      if CheckBoxMS.Checked then SetRange(aDF.Data.Mean + aDF.Data.StdDev);
    end;

    if dMax - dMin < 1.0e-10 then Exit;

      // ratio
    SetRatio(0, FDFList.Count-1, dMin, dMax);

      // axis
    DrawAxis;

      // draw
    iLineCount := 0;

    with DrawCanvas do
    try
      Pen.Width := 1;

        // min
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxMin.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].Data.Min))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].Data.Min));
        // max
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxMax.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].Data.Max))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].Data.Max));

        // mean
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxMean.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].Data.Mean))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].Data.Mean));

        // stddev
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxStdDev.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].Data.StdDev))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].Data.StdDev));

        // 20%
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxPcnt20.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[iQQ_Step-1]))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[iQQ_Step-1]));
        // 40%
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxPcnt40.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[2*iQQ_Step-1]))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[2*iQQ_Step-1]));
        // 60%
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxPcnt60.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[3*iQQ_Step-1]))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[3*iQQ_Step-1]));
        // 80%
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxPcnt80.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[4*iQQ_Step-1]))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].QQSlots[4*iQQ_Step-1]));
        // Mean + stddev
      Inc(iLineCount);
      Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];
      if CheckBoxMS.Checked then
        for i := 0 to FDFList.Count - 1 do
          if i > 0 then
            LineTo(GetXPos(i), GetYPos(FDFList[i].Data.Mean + FDFList[i].Data.StdDev))
          else
            MoveTo(GetXPos(i), GetYPos(FDFList[i].Data.Mean + FDFList[i].Data.StdDev));
    finally

    end;
  end;
end;

procedure TDistributionForm.DrawParamTable;
var
  iCol, iRow, iCount, iQQ_Step, iLineCount: Integer;
  aDF: TDFSeries;
  dMin, dMax, dValue: Double;

  procedure SetRange(dValue: Double);
  begin
    if iCount > 0 then
    begin
      dMin := Math.Min(dMin, dValue);
      dMax := Math.Max(dMax, dValue);
    end else
    begin
      dMin := dValue;
      dMax := dValue;
    end;

    Inc(iCount);
  end;
begin
  with FPainter do
  begin
      // check
    if FDFList.Count = 0 then
    begin
      FPainter.DrawMessage('No DF');
      Exit;
    end;

      // get range
    iCount := 0;
    dMin := 0.0;
    dMax := 0.0;
    iQQ_Step := QQ_SLOT_COUNT div 5;

    for iCol := 0 to FDFList.ColCount-1 do
      for iRow := 0 to FDFList.RowCount - 1 do
      begin
        aDF := FDFList.Table[iCol, iRow];

        if RadioButtonMin.Checked then SetRange(aDF.Data.Min)
        else if RadioButtonMax.Checked then SetRange(aDF.Data.Max)
        else if RadioButtonMean.Checked then SetRange(aDF.Data.Mean)
        else if RadioButtonStdDev.Checked then SetRange(aDF.Data.StdDev)
        else if RadioButton20.Checked then SetRange(aDF.QQSlots[iQQ_Step-1])
        else if RadioButton40.Checked then SetRange(aDF.QQSlots[2*iQQ_Step-1])
        else if RadioButton60.Checked then SetRange(aDF.QQSlots[3*iQQ_Step-1])
        else if RadioButton80.Checked then SetRange(aDF.QQSlots[4*iQQ_Step-1])
        else if RadioButtonMS.Checked then SetRange(aDF.Data.Mean + aDF.Data.StdDev);
      end;

    if dMax - dMin < 1.0e-10 then Exit;

      // ratio
    SetRatio(0, FDFList.RowCount-1, dMin, dMax);

      // axis
    DrawAxis;

      // draw
    iLineCount := 0;

    with DrawCanvas do
    try
      Pen.Width := 1;

      for iCol := 0 to FDFList.ColCount - 1 do
      begin
          // set color
        Inc(iLineCount);
        Pen.Color := LINE_COLORS[iLineCount mod COLOR_COUNT];

          // value
        for iRow := 0 to FDFList.RowCount - 1 do
        begin
          aDF := FDFList.Table[iCol, iRow];
          if RadioButtonMin.Checked then dValue := aDF.Data.Min
          else if RadioButtonMax.Checked then dValue := aDF.Data.Max
          else if RadioButtonMean.Checked then dValue := aDF.Data.Mean
          else if RadioButtonStdDev.Checked then dValue := aDF.Data.StdDev
          else if RadioButton20.Checked then dValue := aDF.QQSlots[iQQ_Step-1]
          else if RadioButton40.Checked then dValue := aDF.QQSlots[2*iQQ_Step-1]
          else if RadioButton60.Checked then dValue := aDF.QQSlots[3*iQQ_Step-1]
          else if RadioButton80.Checked then dValue := aDF.QQSlots[4*iQQ_Step-1]
          else if RadioButtonMS.Checked then dValue := aDF.Data.Mean + aDF.Data.StdDev
          else
            dValue := 0; // just to remove compiler warning

          if iRow > 0 then
            LineTo(GetXPos(iRow), GetYPos(dValue))
          else
            MoveTo(GetXPos(iRow), GetYPos(dValue));
        end;
      end;
    finally

    end;
  end;
end;

function TDistributionForm.GetPriceRange(var dMin, dMax: Double): Boolean;
var
  i, iCount: Integer;
  aDF: TDFSeries;
begin
  Result := False;

  if FDFList.Count = 0 then Exit;

    // get min/max
  dMin := 0.0;
  dMax := 0.0;
  iCount := 0;

  for i := 0 to FDFList.Count - 1 do
  if (CheckListLegend.Checked[i]) or
     (CheckListLegend.Selected[i]) then
  begin
    Inc(iCount);

    aDF := FDFList[i];

    if iCount = 1 then
    begin
      dMin := aDF.Data.Min;
      dMax := aDF.Data.Max;
    end else
    begin
      dMin := Math.Min(dMin, aDF.Data.Min);
      dMax := Math.Max(dMax, aDF.Data.Max);
    end;
  end;

  if iCount = 0 then Exit;

  Result := True;
end;

function TDistributionForm.GetDensityRange(var dMin, dMax: Double): Boolean;
var
  i, iCount: Integer;
  aDF: TDFSeries;
begin
  Result := False;

  if FDFList.Count = 0 then Exit;

    // get min/max
  dMin := 0.0;
  dMax := 0.0;
  iCount := 0;

  for i := 0 to FDFList.Count - 1 do
  if (CheckListLegend.Checked[i]) or
     (CheckListLegend.Selected[i]) then
  begin
    Inc(iCount);

    aDF := FDFList[i];

    if iCount = 1 then
    begin
      dMin := aDF.Bins.MaxDensity;
      dMax := aDF.Bins.MaxDensity;
    end else
    begin
      dMin := Math.Min(dMin, aDF.Bins.MaxDensity);
      dMax := Math.Max(dMax, aDF.Bins.MaxDensity);
    end;
  end;

  if iCount = 0 then Exit;

  Result := True;
end;


procedure TDistributionForm.PaintBoxChartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case FCursorMode of
    cmSelect: SelectSeries(X,Y);
    cmHair: FPainter.StartCursorTracking(PaintBoxChart.Canvas, X, Y);
  end;
end;

procedure TDistributionForm.PaintBoxChartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  case FCursorMode of
    cmSelect: ;
    cmHair: FPainter.DoCursorTracking(PaintBoxChart.Canvas, X, Y);
  end;
end;

procedure TDistributionForm.PaintBoxChartMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case FCursorMode of
    cmSelect: ;
    cmHair:
      begin
        FPainter.StopCursorTracking;
        Draw;
      end;
  end;
end;

procedure TDistributionForm.ToolButtonClick(Sender: TObject);
begin
  case (Sender as TSpeedButton).Tag of
    1: FCursorMode := cmSelect;// cursor
    2: FCursorMode := cmHair; // hair
  end;
end;


procedure TDistributionForm.SelectSeries(X, Y: Integer);
//var
//  dX, dValue, dMargin: Double;
//  i: Integer;
begin
{
  if FYRatio > 1e-10 then
  begin
    dX := GetXValue(X);
    dValue := GetYValue(Y);
    dMargin := 5.0/FYRatio;

    for i := 0 to CheckListLegend.Items.Count - 1 do
      if CheckListLegend.Checked[i] then
      begin
        aSeries := TRegDailySpreadSeries(CheckListLegend.Items.Objects[i]);
        if aSeries.Select(dX, dValue, dMargin) then
        begin
          CheckListLegend.Selected[i] := True;
          Draw;
          Break;
        end;
      end;
  end;
  }
end;

procedure TDistributionForm.CheckBoxAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to CheckListLegend.Items.Count - 1 do
    CheckListLegend.Checked[i] := CheckBoxAll.Checked;

  Draw;
end;


{$ENDREGION}

end.
