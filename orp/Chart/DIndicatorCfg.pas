unit DIndicatorCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons,
  //
  Charters, Indicator, GleConsts;

type
  TIndicatorConfig = class(TForm)
    Label1: TLabel;
    ListParams: TListView;
    ButtonEdit: TButton;
    ButtonDef: TButton;
    RadioPosition: TRadioGroup;
    RadioScale: TRadioGroup;
    GroupBox1: TGroupBox;
    ListPlots: TListBox;
    Label4: TLabel;
    ComboWeight: TComboBox;
    Label5: TLabel;
    ColorDialog: TColorDialog;
    ShapeColor: TShape;
    ButtonColor: TSpeedButton;
    PaintPreview: TPaintBox;
    ButtonOK: TButton;
    Button2: TButton;
    Button1: TButton;
    Label2: TLabel;
    ComboStyle: TComboBox;
    CheckAutoWeight: TCheckBox;
    procedure ComboWeightDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintPreviewPaint(Sender: TObject);
    procedure ListParamsDblClick(Sender: TObject);
    procedure ButtonEditClick(Sender: TObject);
    procedure ButtonDefClick(Sender: TObject);
    procedure ListPlotsClick(Sender: TObject);
    procedure ButtonColorClick(Sender: TObject);
    procedure ComboWeightChange(Sender: TObject);
    procedure ComboStyleClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure CheckAutoWeightClick(Sender: TObject);
  private
    FIndicator : TIndicator;
    //
    FParams : TCollection;
    FPlots : TCollection;
  public
    function Open(aIndicator : TIndicator) : Boolean;
  end;

implementation

{$R *.DFM}

uses DParamCfg;

function TIndicatorConfig.Open(aIndicator : TIndicator) : Boolean;
var
  i : Integer;
  aParam : TParamItem;
  aPlot : TPlotItem;
begin
  Result := False;
  //
  if aIndicator = nil then Exit;
  //
  FIndicator := aIndicator;
  //-- copy
  FIndicator.CloneParams(FParams);
  FIndicator.ClonePlots(FPlots);
  //--
  Caption := '''' + FIndicator.Title + ''' 설정';
  //-- params
  for i:=0 to FParams.Count-1 do
  with ListParams.Items.Add do
  begin
    aParam := FParams.Items[i] as TParamItem;
    Data := aParam;
    Caption := aParam.Title;
    SubItems.Add(aParam.AsString);
  end;
  //-- plots
  for i:=0 to FPlots.Count-1 do
  begin
    aPlot := FPlots.Items[i] as TPlotItem;
    ListPlots.Items.AddObject(aPlot.Title, aPlot);
  end;
  if FPlots.Count > 0 then
  begin
    ListPlots.ItemIndex := 0;
    ListPlotsClick(ListPlots);
  end;
  //-- position
  case aIndicator.Position of
    cpMainGraph : RadioPosition.ItemIndex := 0;
    cpSubGraph : RadioPosition.ItemIndex := 1;
  end;
  //-- scale
  case aIndicator.ScaleType of
    stScreen : RadioScale.ItemIndex := 0;
    stEntire : RadioScale.ItemIndex := 1;
    stSymbol : RadioScale.ItemIndex := 2;
  end;
  //
  if ShowModal = mrOK then
  begin
    FIndicator.AssignParams(FParams);
    FIndicator.AssignPlots(FPlots);

    if FIndicator.BAccount then
      FIndicator.SetObject;


    //-- position
    case RadioPosition.ItemIndex of
      0: aIndicator.Position := cpMainGraph;
      1: aIndicator.Position := cpSubGraph;
    end;
    //-- scale
    case RadioScale.ItemIndex of
      0 : aIndicator.ScaleType := stScreen;
      1 : aIndicator.ScaleType := stEntire;
      2 : aIndicator.ScaleType := stSymbol;
    end;
    //
    FIndicator.Refresh(irmWarm);
    //
    Result := True;
  end;
end;

//----------------------< UI Events : Form >-------------------------//

procedure TIndicatorConfig.FormCreate(Sender: TObject);
begin
  FParams := TCollection.Create(TParamItem);
  FPlots := TCollection.Create(TPlotItem);
end;

procedure TIndicatorConfig.FormDestroy(Sender: TObject);
begin
  try
    FParams.Free;
    FPlots.Free;
  except
  end;
end;

//---------------------< UI Events : Draw  >---------------------//

// weight combobox
procedure TIndicatorConfig.ComboWeightDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  aCombo : TComboBox;
  iY, iWidth : Integer;
  aRect : TRect;
begin
  aCombo := Control as TComboBox;
  //
  with aCombo.Canvas do
  begin
    Brush.Color := clWhite;
    Pen.Mode := pmCopy;
    //-- background
    if odSelected in State then
    begin
      Pen.Color := clBlue;
      Rectangle(Rect);
    end else
      FillRect(Rect);
    //--
    iWidth := StrToIntDef(aCombo.Items.Strings[Index],1);
    Brush.Color := clBlack;
    Pen.Color := clBlack;
    //--
    iY := Rect.Top + (Rect.Bottom - Rect.Top - iWidth) div 2;
    aRect.Left := Rect.Left + 5;
    aRect.Top := iY;
    aRect.Bottom := iY+iWidth;
    aRect.Right := Rect.Right-5;
    //--
    Rectangle(aRect);
  end;
end;

// 미리보기
procedure TIndicatorConfig.PaintPreviewPaint(Sender: TObject);
const
  BAR_COUNT = 20;
var
  aRect : TRect;
  i, j, iStep, iX, iY, iY2, iY0 : Integer;
  dPiStep, dDisplace, dRY : Double;
  iBarHighCount, iBarLowCount, iBarLowIndex : Integer;
begin
  aRect := PaintPreview.ClientRect;
  //
  with PaintPreview.Canvas do
  begin
    Brush.Color := clBlack;
    //-- background
    FillRect(aRect);
    //--
    iStep := (aRect.Right - aRect.Left) div BAR_COUNT;
    dPiStep := Pi / BAR_COUNT;
    dRY := (aRect.Bottom - aRect.Top - 10) / 2;
    iY0 := aRect.Bottom - Round(dRY);

    //-- Get count/index of Bar High/Low style
    iBarHighCount := 0;
    iBarLowCount := 0;
    iBarLowIndex := -1;
    //--
    for i:=0 to FPlots.Count-1 do
      with FPlots.Items[i] as TPlotItem do
      begin
        case Style of
          psBarHigh : Inc(iBarHighCount);
          psBarLow : begin
                       Inc(iBarLowCount);
                       iBarLowIndex := i;
                     end;
        end;
      end;

    //-- draw preview
    for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
    begin
      dDisplace := i * dPiStep * 2;
      Pen.Color := Color;
      Pen.Width := Weight;
      //
      case Style of
        psLine :
          for j:=0 to BAR_COUNT+1 do
          begin
            iX := aRect.Left + j * iStep;
            iY := iY0 - Round(Sin(j*dPiStep + dDisplace) * dRY);
            if j > 0 then
              LineTo(iX, iY)
            else
              MoveTo(iX, iY);
          end;
        psHistogram :
          for j:=0 to BAR_COUNT+1 do
          begin
            iX := aRect.Left + j * iStep;
            iY := iY0 - Round(Sin(j*dPiStep + dDisplace) * dRY);
            MoveTo(iX, aRect.Bottom);
            LineTo(iX, iY);
          end;
        psDot :
          for j:=0 to BAR_COUNT+1 do
          begin
            iX := aRect.Left + j * iStep;
            iY := iY0 - Round(Sin(j*dPiStep + dDisplace) * dRY);
            Pixels[iX,iY] := Color;
          end;
        psBarHigh :
          if iBarLowIndex >= 0 then
          begin
            for j:=0 to BAR_COUNT+1 do
            begin
              iX := aRect.Left + j * iStep;
              iY := iY0 - Round(Sin(j*dPiStep + dDisplace) * dRY);
              iY2 := iY0 - Round(Sin(j*dPiStep + iBarLowIndex*dPiStep*2) * dRY);
              MoveTo(iX, iY);
              LineTo(iX, iY2);
            end;
          end else
          begin
            for j:=0 to BAR_COUNT+1 do
            begin
              iX := aRect.Left + j * iStep;
              iY := iY0 - Round(Sin(j*dPiStep + dDisplace) * dRY);
              MoveTo(iX, iY-2);
              LineTo(iX, iY+2);
            end;
          end;
        psBarLow :
          if iBarHighCount = 0 then
            for j:=0 to BAR_COUNT+1 do
            begin
              iX := aRect.Left + j * iStep;
              iY := iY0 - Round(Sin(j*dPiStep + dDisplace) * dRY);
              MoveTo(iX, iY-2);
              LineTo(iX, iY+2);
            end;
      end; //..case
    end; //..for i
  end; //..with canvas
end;

//--------------------< UI Events : Params >--------------------//

procedure TIndicatorConfig.ListParamsDblClick(Sender: TObject);
begin
  ButtonEditClick(ButtonEdit);
end;

procedure TIndicatorConfig.ButtonEditClick(Sender: TObject);
var
  aParam : TParamItem;
  stValue : String;
  bResult : Boolean;
begin
  if ListParams.Selected = nil then Exit;
  //-- target for editing
  aParam := TParamItem(ListParams.Selected.Data);
  //-- preparing for editing
  stValue := aParam.AsString;

  case aParam.ParamType of
    ptInteger :
          bResult := ParamQuery(Self,
                                '입력값 변경', aParam.Title + '(정수값 입력) : ',
                                stValue, False, []);
    ptFloat   :
          bResult:= ParamQuery(Self,
                               '입력값 변경', aParam.Title + '(실수값 입력) : ',
                               stValue, False, []);
    ptString  :
          bResult:= ParamQuery(Self,
                               '입력값 변경', aParam.Title + ' : ',
                               stValue, True, ['High','Low','Open','Close','Volume']);
    ptBoolean :
          bResult:= ParamQuery(Self,
                               '입력값 변경', aParam.Title + ' : ',
                               stValue, True, ['True','False']);
    ptColor   :
          bResult:= ParamQuery(Self,
                               '입력값 변경', aParam.Title + '(색 선택) : ',
                               stValue, True, PLOT_COLOR_NAMES);
    ptAccount  :
          bResult := ParamQuery2(Self,
                                '입력값 변경', aParam.Title + '(Code) : ',
                                stValue, False, []);
    ptSymbol  :
          bResult := ParamQuery3(Self,
                                '입력값 변경', aParam.Title + '(Code) : ',
                                stValue, False, []);

    else
      bResult := False;

  end;
  
  //-- edit
  if bResult and (Length(stValue) > 0) then
  try
    case aParam.ParamType of
      ptInteger : aParam.AsInteger := StrToInt(stValue);
      ptFloat   : aParam.AsFloat := StrToFloat(stValue);
      ptString  : aParam.AsString := stValue;
      ptBoolean : aParam.AsBoolean := (CompareStr('True',stValue) = 0);
      ptColor   : aParam.AsColor := PlotColor(stValue);
      ptAccount : aParam.AsAccount := stValue;
      ptSymbol  : aParam.AsSymbol  := stValue;
    end;

    //-- show
    with ListParams.Selected do
    begin
      SubItems.Clear;
      SubItems.Add(aParam.AsString);
    end;
  except
    ShowMessage('값이 올바르지 않습니다.(''' + stValue + ''')');
  end;
end;

procedure TIndicatorConfig.ButtonDefClick(Sender: TObject);
var
  aParam : TParamItem;
begin
  if ListParams.Selected = nil then Exit;
  //
  aParam := TParamItem(ListParams.Selected.Data);
  //
  case aParam.ParamType of
    ptInteger : aParam.AsInteger := FIndicator.Params[aParam.Title].AsInteger;
    ptFloat : aParam.AsFloat := FIndicator.Params[aParam.Title].AsFloat;
    ptString : aParam.AsString := FIndicator.Params[aParam.Title].AsString;
    ptAccount : aParam.AsAccount := FIndicator.Params[aParam.Title].AsAccount;
    ptSymbol  : aParam.AsSymbol := Findicator.Params[aParam.Title].AsSymbol;
  end;
  //
  with ListParams.Selected do
  begin
    SubItems.Clear;
    SubItems.Add(aParam.AsString);
  end;
end;

//--------------------< UI Events : Plots >--------------------//

// component selection
procedure TIndicatorConfig.ListPlotsClick(Sender: TObject);
var
  aPlot : TPlotItem;
begin
  if ListPlots.ItemIndex < 0 then Exit;
  //
  aPlot := TPlotItem(ListPlots.Items.Objects[ListPlots.ItemIndex]);
  //-- plot style
  case aPlot.Style of
    psLine :      ComboStyle.ItemIndex := 0;
    psHistogram : ComboStyle.ItemIndex := 1;
    psDot :       ComboStyle.ItemIndex := 2;
    psBarHigh :   ComboStyle.ItemIndex := 3;
    psBarLow :    ComboStyle.ItemIndex := 4;
  end;
  //-- color
  ShapeColor.Brush.Color := aPlot.Color;
  //-- weight
  ComboWeight.ItemIndex := aPlot.Weight-1;
  ComboWeight.Enabled := (aPlot.Style in [psLine, psHistogram, psBarHigh, psBarLow]);

  CheckAutoWeight.Enabled := (aPlot.Style = psHistogram);
  CheckAutoWeight.Checked := (aPlot.Weight = 0);
  //--
end;

// select graph style
procedure TIndicatorConfig.ComboStyleClick(Sender: TObject);
var
  aPlot : TPlotItem;
begin
  if ListPlots.ItemIndex < 0 then Exit;
  //
  aPlot := TPlotItem(ListPlots.Items.Objects[ListPlots.ItemIndex]);
  //-- plot style
  case ComboStyle.ItemIndex of
    0 : aPlot.Style := psLine;
    1 : aPlot.Style := psHistogram;
    2 : aPlot.Style := psDot;
    3 : aPlot.Style := psBarHigh;
    4 : aPlot.Style := psBarLow;
  end;
  // line width can applied only to psLine
  ComboWeight.Enabled := (ComboStyle.ItemIndex in [0,1,3,4]);

  CheckAutoWeight.Enabled := (aPlot.Style = psHistogram);
  CheckAutoWeight.Checked := False;
  //
  PaintPreview.Refresh;
end;

// select color

procedure TIndicatorConfig.ButtonColorClick(Sender: TObject);
var
  aPlot : TPlotItem;
begin
  if ListPlots.ItemIndex < 0 then Exit;
  //
  aPlot := TPlotItem(ListPlots.Items.Objects[ListPlots.ItemIndex]);
  //-- plot style
  if ColorDialog.Execute then
  begin
    ShapeColor.Brush.Color := ColorDialog.Color;
    aPlot.Color := ColorDialog.Color;
  end;
  //--
  PaintPreview.Refresh;
end;

// select weight
procedure TIndicatorConfig.ComboWeightChange(Sender: TObject);
var
  aPlot : TPlotItem;
begin
  if ListPlots.ItemIndex < 0 then Exit;
  //
  aPlot := TPlotItem(ListPlots.Items.Objects[ListPlots.ItemIndex]);
  //-- plot style
  aPlot.Weight := StrToInt(ComboWeight.Items.Strings[ComboWeight.ItemIndex]);
  //
  PaintPreview.Refresh;
end;

procedure TIndicatorConfig.CheckAutoWeightClick(Sender: TObject);
var
  aPlot : TPlotItem;
begin
  if ListPlots.ItemIndex < 0 then Exit;
  //
  aPlot := TPlotItem(ListPlots.Items.Objects[ListPlots.ItemIndex]);
  //-- plot style
  if CheckAutoWeight.Checked then
    aPlot.Weight := 0
  else
    aPlot.Weight := 1;
  //
  ComboWeight.ItemIndex := aPlot.Weight -1;
  //
  PaintPreview.Refresh;
end;

//--------------------< UI Events : Misc >--------------------//

procedure TIndicatorConfig.ButtonOKClick(Sender: TObject);
var
  i, iBarHighCount, iBarLowCount : Integer;
begin
  //-- Get count/index of Bar High/Low style
  iBarHighCount := 0;
  iBarLowCount := 0;
  //--
  for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
    begin
      case Style of
        psBarHigh : Inc(iBarHighCount);
        psBarLow  : Inc(iBarLowCount);
      end;
    end;
  //--
  if (iBarHighCount > 1) then
    ShowMessage('연결고점이 너무 많습니다.')
  else if (iBarLowCount > 1) then
    ShowMessage('연결저점이 너무 많습니다.')
  else if (iBarHighCount = 1) and (iBarLowCount = 0) then
    ShowMessage('연결저점이 없습니다.')
  else if (iBarLowCount = 1) and (iBarHighCount = 0) then
    ShowMessage('연결고점이 없습니다.')
  else
    ModalResult := mrOK;
end;


end.

