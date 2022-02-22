unit DDoubleOrderConfigQty;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Grids;

type
  TDoubleOrderConfigQtyDialog = class(TForm)
    BtnOk: TButton;
    GridQty: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure GridQtyKeyPress(Sender: TObject; var Key: Char);
    procedure GridQtyMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GridQtyMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    FRowCount: Integer;
    function GetQty(i,j : Integer): Integer;
    procedure SetQty(i,j : Integer; const Value: Integer);
    { Private declarations }
  public
    property Qty[i : Integer;j : Integer ] : Integer read GetQty write SetQty;
  end;

var
  DoubleOrderConfigQtyDialog: TDoubleOrderConfigQtyDialog;

implementation

{$R *.dfm}

procedure TDoubleOrderConfigQtyDialog.FormCreate(Sender: TObject);
begin
///
end;

procedure TDoubleOrderConfigQtyDialog.BtnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TDoubleOrderConfigQtyDialog.GridQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key < '0') or (Key > '9')) and (Key <> #13)  then Key:=#0;
end;

procedure TDoubleOrderConfigQtyDialog.GridQtyMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TDoubleOrderConfigQtyDialog.GridQtyMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

function TDoubleOrderConfigQtyDialog.GetQty(i, j: Integer): Integer;
begin
  Result := StrToInt( GridQty.Cells[i, j] );
end;

procedure TDoubleOrderConfigQtyDialog.SetQty(i, j: Integer;
  const Value: Integer);
begin
  GridQty.Cells[i, j] := IntToStr( Value ); 
end;

end.

