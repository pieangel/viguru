unit FSkew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, Menus,

    // Lemon
  LemonEngine, CleKrxSymbols,
    // App
  GAppEnv,
    // Skew
  CSkewConsts, CSkewStrategy, CSkewPoints, CSkewGraph;

type
  TSkewForm = class(TForm)
    Panel1: TPanel;
    ComboAccount: TComboBox;
    Label1: TLabel;
    ButtonRecovery: TSpeedButton;
    Bevel1: TBevel;
    RadioButton1: TRadioButton;
    StatusBar1: TStatusBar;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Panel3: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    PaintBoxSkew: TPaintBox;
    StringGridPoints: TStringGrid;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    EF1: TMenuItem;
    N4: TMenuItem;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxSkewPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FStrategy: TSkewStrategy;
    FGraph: TSkewGraph;
    procedure StrategyUpdate(Sender: TObject);
    procedure SetSkewPointTable;

    procedure InitSkewOptionTable;
    procedure InitSkewPointTable;
  public

  end;

var
  SkewForm: TSkewForm;

implementation

{$R *.dfm}

procedure TSkewForm.FormCreate(Sender: TObject);
begin
  FStrategy := TSkewStrategy.Create(gEnv.Engine);
  FGraph := TSkewGraph.Create;

  FStrategy.Engine := gEnv.Engine;
  FStrategy.OnUpdate := StrategyUpdate;

  FGraph.Points := FStrategy.Points;
  FGraph.PaintBox := PaintBoxSkew;

  InitSkewPointTable;
  InitSkewOptionTable;
end;

procedure TSkewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSkewForm.FormDestroy(Sender: TObject);
begin
  FGraph.Free;
  FStrategy.Free;
end;

procedure TSkewForm.PaintBoxSkewPaint(Sender: TObject);
begin
  FGraph.Refresh;
end;

//-------------------------------------------------------------------< Update >

procedure TSkewForm.StrategyUpdate(Sender: TObject);
begin
//  SetSkewPointTable;

//  FGraph.Refresh;
end;


procedure TSkewForm.Timer1Timer(Sender: TObject);
begin
  SetSkewPointTable;
  FGraph.Refresh;
end;

//---------------------------------------------------------------< Skew Point >

procedure TSkewForm.InitSkewPointTable;
var
  i: Integer;
begin
  with StringGridPoints do
  begin
    ColCount := 7;
    RowCount := FStrategy.Points.Count+1;

      // header
    Cells[1,0] := 'C/Ask';
    Cells[2,0] := 'C/Bid';
    Cells[3,0] := 'C/Last';
    Cells[4,0] := 'P/Ask';
    Cells[5,0] := 'P/Bid';
    Cells[6,0] := 'P/Last';
      //
    for i := 0 to FStrategy.Points.Count-1 do
      Cells[0,i+1] := Format('%.2f', [FStrategy.Points[i].X]);
  end;
end;

procedure TSkewForm.SetSkewPointTable;
var
  i: Integer;
  aPoint: TSkewPoint;
begin
  with StringGridPoints do
  begin
    for i := 0 to FStrategy.Points.Count-1 do
    begin
      aPoint := FStrategy.Points[i];

      Cells[1,i+1] := Format('%.4f', [aPoint.Values[IDX_CALL,IDX_ASK].IV]);
      Cells[2,i+1] := Format('%.4f', [aPoint.Values[IDX_CALL,IDX_BID].IV]);
      Cells[3,i+1] := Format('%.4f', [aPoint.Values[IDX_CALL,IDX_FILL].IV]);
      Cells[4,i+1] := Format('%.4f', [aPoint.Values[IDX_PUT,IDX_ASK].IV]);
      Cells[5,i+1] := Format('%.4f', [aPoint.Values[IDX_PUT,IDX_BID].IV]);
      Cells[6,i+1] := Format('%.4f', [aPoint.Values[IDX_PUT,IDX_FILL].IV]);
    end;
  end;
end;

//------------------------------------------------------------------< Options >

procedure TSkewForm.InitSkewOptionTable;
begin
{
  with DrawGridOptions do
  begin
    RowCount := 2;
    ColCount := FStrategy.Tree.Count;
  end;
  }
end;

end.
