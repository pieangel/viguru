unit FDerIndicator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,

  GleConsts , GleTypes, ExtCtrls

  ;

type
  TFrmFOSideVol = class(TForm)
    sgInfo: TStringGrid;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateData;
    procedure WMChangeData(var msg: TMessage); message WM_CHANGEDATA;
  end;

var
  FrmFOSideVol: TFrmFOSideVol;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TFrmFOSideVol.Button1Click(Sender: TObject);
begin
  gEnv.Engine.SyncFuture.ReSetIndicator;
  UpdateData;
end;

procedure TFrmFOSideVol.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmFOSideVol.FormCreate(Sender: TObject);
begin
  with sgInfo do
  begin
    Cells[0,0]  := '선물';
    Cells[0,1]  := '옵션';
    Cells[0,2]  := 'Call';
    Cells[0,3]  := 'Put';
  end;
end;

procedure TFrmFOSideVol.FormDestroy(Sender: TObject);
begin
  gEnv.FOFillVol := nil;
end;

procedure TFrmFOSideVol.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
  iX, iY : Integer;
  aSize : TSize;

begin
  with sgInfo do
  begin
    stTxt := Cells[ACol, ARow];

    aSize := Canvas.TextExtent(stTxt);
    iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;

    case ACol of
      0 :
        begin
          iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
          Canvas.Brush.Color := clBtnFace;
        end;
      else
        begin
          iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          Canvas.Brush.Color  := clWhite;
        end;
    end;

    Canvas.Font.Color := clBlack;
    Canvas.FillRect( Rect );

    Canvas.TextRect(Rect, iX, iY, stTxt);
  end;

end;

procedure TFrmFOSideVol.Timer1Timer(Sender: TObject);
begin
  UpdateData;
end;

procedure TFrmFOSideVol.UpdateData;
var
  stTmp : string;
begin

  with sgInfo, gEnv.Engine do
  begin

    Cells[1, 0]  := Format('%.0f', [ SyncFuture.DerIndicator[2] ]);
    Cells[1, 1]  := Format('%.0f', [ SyncFuture.DerIndicator[1] + SyncFuture.DerIndicator[0] ]);
    Cells[1, 2]  := Format('%.0f', [ SyncFuture.DerIndicator[0] ]);
    Cells[1, 3]  := Format('%.0f', [ SyncFuture.DerIndicator[1] ]);

  end;

end;

procedure TFrmFOSideVol.WMChangeData(var msg: TMessage);
begin
  UpdateData;
end;

end.
