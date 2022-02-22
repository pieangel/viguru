unit DSymbolerCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  //
  GleTypes, GleLib, GleConsts,
  ChartIF,
  CleSymbols, Charters, Symbolers, XTerms

  ;

type

  TSymbolerConfig = class(TForm)
    Label1: TLabel;
    ComboSymbols: TComboBox;
    GroupCompression: TGroupBox;
    Label2: TLabel;
    RadioTick: TRadioButton;
    RadioMin: TRadioButton;
    LabelTerms: TLabel;
    RadioStyle: TRadioGroup;
    ButtonSymbol: TSpeedButton;
    EditPeriod: TEdit;
    ColorDialog: TColorDialog;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    PaintColor: TPaintBox;
    ButtonChangeColor: TSpeedButton;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    RadioDaily: TRadioButton;
    RadioWeekly: TRadioButton;
    RadioMonthly: TRadioButton;
    Bevel1: TBevel;
    Button1: TButton;
    GroupBox1: TGroupBox;
    RadioScaleScreen: TRadioButton;
    RadioScaleEntire: TRadioButton;
    RadioScaleSymbol: TRadioButton;
    GroupPosition: TGroupBox;
    RadioMainGraph: TRadioButton;
    RadioSubGraph: TRadioButton;
    CheckFill: TCheckBox;
    RadioQuote: TRadioButton;
    GroupBox3: TGroupBox;
    rdbData: TRadioButton;
    EditCount: TEdit;
    rdbPast: TRadioButton;
    cbPast: TComboBox;
    Label3: TLabel;
    RadioYRateType: TRadioGroup;
    GroupBox4: TGroupBox;
    ckHighLine: TCheckBox;
    ckLowLine: TCheckBox;
    ButtonGridColor: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ckRlHighLine: TCheckBox;
    ckRlLowLine: TCheckBox;
    SpeedButton3: TSpeedButton;
    ckCustom: TCheckBox;
    SpeedButton4: TSpeedButton;
    edtCustom: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RadioStyleClick(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure ButtonChangeColorClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure PaintColorPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboSymbolsChange(Sender: TObject);
    procedure RadioTickClick(Sender: TObject);
    procedure RadioMainGraphClick(Sender: TObject);
    procedure ButtonGridColorClick(Sender: TObject);
  private
    FChartColor : TColor;
    FBkColor : TColor;
    // add color;
    FHighColor : TColor;
    FLowColor  : TColor;
    FRlHighColor  : TColor;
    FRlLowColor   : TColor;
    FCustomColor  : TColor;
    //sms
    FSymboler : TSymboler;

    function GetScale: TScaleType;
    function GetStyle: TSymbolChartStyle;
    function GetPeriod : Integer;
    function GetSymbol : TSymbol;
    function GetBase : TChartBase;
    function GetCount : Integer;
    procedure SetScale(const Value: TScaleType);
    procedure SetStyle(const Value: TSymbolChartStyle);
    procedure SetPeriod(const Value: Integer);
    procedure SetSymbol(const Value: TSymbol);
    procedure SetBase(const Value : TChartBase);
    procedure SetCount(const Value : Integer);
    procedure SetPosition(const Value: TCharterPosition);
    function GetYRateType: TYRateType;
    procedure SetYRateType(const Value: TYRateType);

  public
    function Execute(aSymboler : TSymboler) : Boolean;
    //
    procedure AddUsedSymbol(aSymbol : TSymbol);
    //
    property Style : TSymbolChartStyle read GetStyle write SetStyle;
    property Scale : TScaleType read GetScale write SetScale;
    property Symbol : TSymbol read GetSymbol write SetSymbol;
    property Base : TChartBase read GetBase write SetBase;
    property Period : Integer read GetPeriod write SetPeriod;
    property Count : Integer read GetCount write SetCount;
    property YRateType : TYRateType read GetYRateType write SetYRateType;

  end;

implementation

uses GAppEnv, CleFQN;

{$R *.DFM}

//------------------< Public methods >----------------------------//

function TSymbolerConfig.Execute(aSymboler : TSymboler) : Boolean;
const
  DEF_COUNT = 300;
var
  i, iData : Integer;
  bRefresh : boolean;
begin
{$ifdef DEBUG}
  // gLog.Add(lkDebug, 'SymbolConfig', 'Execute', 'Enter');
{$endif}
  Result := False;

  FSymboler := aSymboler;

  //Set Enablity
  if aSymboler.SymbolerMode = smMain then
  begin
    GroupPosition.Enabled := False;
    RadioMainGraph.Enabled := False;
    RadioSubGraph.Enabled := False;
    RadioScaleSymbol.Enabled := False;
    RadioYRateType.Enabled := true;
  end else
  begin
    GroupCompression.Enabled := False;
    RadioTick.Enabled := False;
    RadioMin.Enabled := False;
    RadioDaily.Enabled := False;
    RadioWeekly.Enabled := False;
    RadioMonthly.Enabled := False;
    RadioQuote.Enabled   := false;
    EditPeriod.Enabled := False;
    EditCount.Enabled := False;
    RadioYRateType.Enabled := false;
  end;

  CheckFill.Checked := aSymboler.ShowFill;
  CheckFill.Enabled := not(aSymboler.SymbolerMode=smMain);

  for i := 0 to ComboSymbols.Items.Count-1 do
    if (ComboSymbols.Items.Objects[i] <> nil) and
      (ComboSymbols.Items.Objects[i] = FSymboler.DataXTerms.Symbol) then
    begin
      ComboSymbols.ItemIndex := i;
      break;
    end;

  //-- Set old
  FBkColor := aSymboler.BkColor;
  FChartColor := aSymboler.ChartColor;

  Scale := aSymboler.ScaleType;
  Style := aSymboler.ChartStyle;
  Symbol := aSymboler.XTerms.Symbol;
  YRateType := aSymboler.YRateType;

  FHighColor  := aSymboler.HighLineColor;
  FLowColor   := aSymboler.LowLineColor;
  FRlHighColor  := aSymboler.RlHighLineColor;
  FRlLowColor   := aSymboler.RlLowLineColor;
  FCustomColor  := aSymboler.CustomLIneColor;

  edtCustom.Text  := Format('%.2f',[aSymboler.CustomLineValue]);

  ckHighLine.Checked  := aSymboler.UseHighLine;
  ckLowLine.Checked   := aSymboler.UseLowLine;
  ckRlHighLine.Checked  := aSymboler.UseRlHighLine;
  ckRlLowLine.Checked   := aSymboler.UseRlLowLine;
  ckCustom.Checked      := aSymboler.UseCustomLine;
  //sms
  Base := aSymboler.MainSymboler.XTerms.Base;
  Period := aSymboler.MainSymboler.XTerms.Period;

  SetPosition(aSymboler.Position);

  if aSymboler.SymbolerMode = smMain then
  begin
    if aSymboler.XTerms.Count = 0 then
      Count := DEF_COUNT
    else
      Count := aSymboler.XTerms.Count;
  end else
    Count := aSymboler.MainSymboler.XTerms.Count;


  if aSymboler.DataXTerms.DataPast = -1 then
    rdbData.Checked := true
  else
  begin
    rdbPast.Checked := true;
    cbPast.ItemIndex := aSymboler.DataXTerms.DataPast;
  end;

  //--
  if ShowModal = mrOK then
  begin
    aSymboler.ChartStyle := Style;
    aSymboler.ScaleType := Scale;
    aSymboler.ChartColor := FChartColor;

    if aSymboler.SymbolerMode = smMain then
      aSymboler.YRateType  := YRateType;
    //sms
    if RadioMainGraph.Checked then
      aSymboler.Position := cpMainGraph
    else
      aSymboler.Position := cpSubGraph;

    iData := aSymboler.DataXTerms.DataPast;
    if rdbData.Checked then
      aSymboler.DataXTerms.DataPast := -1
    else if rdbPast.Checked then
      aSymboler.DataXTerms.DataPast := StrToInt(cbPast.Text);

    bRefresh := false;
    if iData <> aSymboler.DataXTerms.DataPast then
     bRefresh := true;

    aSymboler.DataXTerms.Define(Symbol, Base, Period, Count, bRefresh);

    aSymboler.XTerms.Symbol := Symbol;
    aSymboler.XTerms.Base := Base;
    aSymboler.XTerms.Period := Period;

    aSymboler.Precision := Symbol.Spec.Precision;
    aSymboler.ShowFill := CheckFill.Checked;

    aSymboler.HighLineColor := FHighColor;
    aSymboler.LowLineColor  := FLowColor;
    aSymboler.RlHighLineColor := FRlHighColor;
    aSymboler.RlLowLineColor  := FRlLowColor;
    aSymboler.CustomLIneColor := FCustomColor;

    aSymboler.UseHighLine := ckHighLine.Checked;
    aSymboler.UseLowLine  := ckLowLine.Checked;
    aSymboler.UseRlHighLine := ckRlHighLine.Checked;
    aSymboler.UseRlLowLine  := ckRlLowLine.Checked;
    aSymboler.UseCustomLine := ckCustom.Checked;
    aSymboler.CustomLineValue := StrToFloatDef(edtCustom.Text, 0);
    //
    Result := True;
  end;
{$ifdef DEBUG}
  // gLog.Add(lkDebug, 'SymbolConfig', 'Execute', 'Exit');
{$endif}
end;

procedure TSymbolerConfig.AddUsedSymbol(aSymbol: TSymbol);
begin
  if aSymbol <> nil then
    AddSymbolCombo(aSymbol, ComboSymbols);
end;


//------------------< UI Events : Forms >-------------------------//

procedure TSymbolerConfig.FormCreate(Sender: TObject);
begin
  RadioTick.Enabled := gChartIF.Enabled(cbTick);
  RadioMin.Enabled := gChartIF.Enabled(cbMin);
  RadioQuote.Enabled  := gChartIF.Enabled( cbQuote);
  RadioDaily.Enabled := gChartIF.Enabled(cbDaily);
  RadioWeekly.Enabled := gChartIF.Enabled(cbWeekly);
  RadioMonthly.Enabled := gChartIF.Enabled(cbMonthly);
  //
  gEnv.Engine.SymbolCore.SymbolCache.GetList( ComboSymbols.Items);

end;

procedure TSymbolerConfig.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
end;

//-----------------< UI Events : Selection >------------------------//

procedure TSymbolerConfig.ComboSymbolsChange(Sender: TObject);
begin
  //sms
  if FSymboler.SymbolerMode = smSub then Exit;

  if Symbol <> nil then
  begin
    RadioTick.Enabled := (Symbol.Spec.Market in [mtFutures, mtOption]);
    if not RadioTick.Enabled and RadioTick.Checked then
      RadioMin.Checked := True;

    RadioQuote.Enabled := (Symbol.Spec.Market in [mtFutures, mtOption]);
    if not RadioQuote.Enabled and RadioQuote.Checked then
      RadioMin.Checked := True;
  end;
end;

// 챠트형태 변경
procedure TSymbolerConfig.RadioStyleClick(Sender: TObject);
begin
  PaintColor.Refresh;
end;

// 종목변경
procedure TSymbolerConfig.ButtonSymbolClick(Sender: TObject);
begin

  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, ComboSymbols);
        // apply
      ComboSymbolsChange(ComboSymbols);
    end;
  finally
    gSymbol.Hide;
  end;

end;

// 색변경
procedure TSymbolerConfig.ButtonChangeColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FChartColor := ColorDialog.Color;
    PaintColor.Refresh;
  end;
end;

procedure TSymbolerConfig.ButtonGridColorClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := (Sender as TSpeedButton).Tag;

  case iTag of
    0 : ColorDialog.Color := FHighColor;
    1 : ColorDialog.Color := FLowColor;
    2 : ColorDialog.Color := FRlHighColor;
    3 : ColorDialog.Color := FRlLowColor;
    4 : ColorDialog.Color := FCustomColor;
  end;

  if ColorDialog.Execute then
  begin
    case iTag of
      0 : FHighColor := ColorDialog.Color;
      1 : FLowColor := ColorDialog.Color;
      2 : FRlHighColor := ColorDialog.Color;
      3 : FRlLowColor := ColorDialog.Color;
      4 : FCustomColor  := ColorDialog.Color;
    end;
  end;
end;

//-----------------------< UI Events : Buttons >------------------//

procedure TSymbolerConfig.ButtonOKClick(Sender: TObject);
var
  aEdit : TEdit;
begin
//  if RadioTick.Checked then
//    aEdit := EditTicks
//  else
//    aEdit := EditTerms;
  //
  if Symbol = nil then
  begin
    ShowMessage('종목을 선택하십시오');
    ComboSymbols.SetFocus;
  end else
  if not (StrToIntDef(EditPeriod.Text, 0) in [1..100]) then
  begin
    ShowMessage('1-100 사이의 숫자를 입력하십시오');
    EditPeriod.SetFocus;
  end else
  if (StrToIntDef(EditCount.Text, 0) = 0) and ( rdbData.Checked ) then
  begin
    ShowMessage('0 보다 큰 숫자를 입력하십시오');
   // EditCount.SetFocus;
  end else
    ModalResult := mrOK;
end;

procedure TSymbolerConfig.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

//-----------------------< Property Methods >----------------//


function TSymbolerConfig.GetScale: TScaleType;
begin
  {
  case RadioScale.ItemIndex of
    0 : Result := stScreen;
    1 : Result := stEntire;
  end;
  }
  if RadioScaleScreen.Checked then
    Result := stScreen
  else if RadioScaleEntire.Checked then
    Result := stEntire
  else if RadioScaleSymbol.Checked then
    Result := stSymbol;
end;


procedure TSymbolerConfig.SetScale(const Value: TScaleType);
begin
  {
  //Regacy
  case Value of
    stScreen : RadioScale.ItemIndex := 0;
    stEntire : RadioScale.ItemIndex := 1;
  end;
  }

  //New
  if Value = stScreen then
  begin
    RadioScaleScreen.Checked := True;
    RadioScaleEntire.Checked := False;
    RadioScaleSymbol.Checked := False;
  end else if Value = stEntire then
  begin
    RadioScaleScreen.Checked := False;
    RadioScaleEntire.Checked := True;
    RadioScaleSymbol.Checked := False;
  end else if Value = stSymbol then
  begin
    RadioScaleScreen.Checked := False;
    RadioScaleEntire.Checked := False;
    RadioScaleSymbol.Checked := True;
  end
end;

function TSymbolerConfig.GetStyle: TSymbolChartStyle;
begin
  case RadioStyle.ItemIndex of
    0 : Result := ssOHLC;
    1 : Result := ssCandle;
    2 : Result := ssLine;
  end;
end;

procedure TSymbolerConfig.SetStyle(const Value: TSymbolChartStyle);
begin
  case Value of
    ssOHLC : RadioStyle.ItemIndex := 0;
    ssCandle : RadioStyle.ItemIndex := 1;
    ssLine : RadioStyle.ItemIndex := 2;
  end;
end;

function TSymbolerConfig.GetPeriod: Integer;
begin
  Result := StrToIntDef(EditPeriod.Text, 1);
end;

procedure TSymbolerConfig.SetPeriod(const Value: Integer);
begin
  EditPeriod.Text := IntToStr(Value);
end;

function TSymbolerConfig.GetSymbol: TSymbol;
begin
  if ComboSymbols.ItemIndex >= 0 then
    Result := ComboSymbols.Items.Objects[ComboSymbols.ItemIndex] as TSymbol
  else
    Result := nil;
end;

function TSymbolerConfig.GetYRateType: TYRateType;
begin
  case RadioYRateType.ItemIndex of
    0 : Result := yrDefault;
    1 : Result := yrSame;
  end
end;

procedure TSymbolerConfig.SetSymbol(const Value: TSymbol);
begin
  if Value <> nil then
  begin
    AddSymbolCombo(Value, ComboSymbols);
    ComboSymbolsChange(ComboSymbols);
  end;
end;

procedure TSymbolerConfig.SetYRateType(const Value: TYRateType);
begin
  case Value of
    yrDefault : RadioYRateType.ItemIndex := 0;
    yrSame : RadioYRateType.ItemIndex := 1;
  end;
end;

function TSymbolerConfig.GetBase : TChartBase;
begin
  if RadioTick.Checked then
    Result := cbTick
  else if RadioMin.Checked then
    Result := cbMin
  else if RadioQuote.Checked then
    Result := cbQuote
  else if RadioDaily.Checked then
    Result := cbDaily
  else if RadioWeekly.Checked then
    Result := cbWeekly
  else if RadioMonthly.Checked then
    Result := cbMonthly;
end;

procedure TSymbolerConfig.SetBase(const Value : TChartBase);
begin
  case Value of
    cbTick :    RadioTick.Checked := True;
    cbMin :     RadioMin.Checked := True;
    cbQuote:    RadioQuote.Checked  := True;
    cbDaily :   RadioDaily.Checked := True;
    cbWeekly :  RadioWeekly.Checked := True;
    cbMonthly : RadioMonthly.Checked := True;
  end;
end;


function TSymbolerConfig.GetCount : Integer;
begin
  Result := StrToIntDef(EditCount.Text, 0);
end;

procedure TSymbolerConfig.SetCount(const Value : Integer);
begin
  EditCount.Text := IntToStr(Value);
end;

//------------------< UI Events : Draw >--------------------------//

// chart preview
procedure TSymbolerConfig.PaintColorPaint(Sender: TObject);
const
  X1 = 17;
  X2 = 34;
  R1 : TRect = (Left:13; Top:12; Right:22; Bottom:20);
  R2 : TRect = (Left:30; Top:15; Right:39; Bottom:18);
var
  aRect : TRect;
begin
  aRect := PaintColor.ClientRect;
  //
  with PaintColor.Canvas do
  begin
    Brush.Color := FBkColor;
    //-- background color
    FillRect(aRect);
//  //-- preview
    case RadioStyle.ItemIndex of
      0 : // OHLC
        begin
          Pen.Color := FChartColor;
          MoveTo(X1,5); LineTo(X1,25);
          MoveTo(R1.Left,R1.Bottom); LineTo(X1,R1.Bottom);
          MoveTo(X1,R1.Top); LineTo(R1.Right,R1.Top);
          MoveTo(X2,8); LineTo(X2,24);
          MoveTo(R2.Left,R2.Top); LineTo(X2,R2.Top);
          MoveTo(X2,R2.Bottom); LineTo(R2.Right,R2.Bottom);
        end;
      1 : // candle
        begin
          Brush.Color := clRed;
          Pen.Color := clGray;
          MoveTo(X1,5); LineTo(X1,25);
          FillRect(R1);
          MoveTo(X2,8); LineTo(X2,24);
          Brush.Color := FChartColor;
          FillRect(R2);
        end;
      2 : // line
        begin
          Pen.Color := FChartColor;
          MoveTo(0,30);
          LineTo(R1.Left,R1.Top);
          LineTo(X2,R2.Bottom);
          LineTo(aRect.Right,2);
        end;
    end;
  end;
end;


procedure TSymbolerConfig.RadioTickClick(Sender: TObject);
begin
  if TRadioButton( Sender ).Checked then
  begin
    RadioStyle.ItemIndex := 2;
    RadioStyleClick(RadioStyle);
  end;
end;

procedure TSymbolerConfig.SetPosition(const Value: TCharterPosition);
begin
  if Value = cpMainGraph then
  begin
    RadioMainGraph.Checked := True;
    RadioSubGraph.Checked := False;
  end else if Value = cpSubGraph then
  begin
    RadioMainGraph.Checked := False;
    RadioSubGraph.Checked := True;
  end;
end;

procedure TSymbolerConfig.RadioMainGraphClick(Sender: TObject);
begin
  if RadioMainGraph.Checked then
    RadioSubGraph.Checked := False
  else
    RadioSubGraph.Checked := True;
end;


end.
