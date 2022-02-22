unit DBoardVolumes;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Grids,

  COBTypes;

type
  TBoardVolumeDialog = class(TForm)
    ButtonOK: TButton;
    StringGridVolumes: TStringGrid;
    cbDefault: TCheckBox;
    ComboBoxItem: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGridVolumesKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridVolumesMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure StringGridVolumesMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxItemChange(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure cbDefaultClick(Sender: TObject);
  private
    FRowCount: Integer;
    FQtyItem: TQtyItem;
    FSubSet : boolean;

    function GetVolume(iCol, iRow: Integer): Integer;
    procedure SetVolume(iCol, iRow: Integer; const Value: Integer);
    procedure UpdateGridVolume;
    procedure SaveQtyItem;
  public

    property Volumes[iCol,iRow: Integer]: Integer read GetVolume write SetVolume;
    property QtyItem : TQtyItem read FQtyItem write FQtyItem;
    procedure ChangeGird( iRow, iCol : integer );
    procedure ChangeGrid( aItem : TQtyItem );
    procedure ChangeGrid2( aGrid : TStringGrid );
  end;

var
  BoardVolumeDialog: TBoardVolumeDialog;

implementation

uses GAppEnv;

{$R *.dfm}

procedure TBoardVolumeDialog.StringGridVolumesKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13]) then
    Key := #0;
end;

procedure TBoardVolumeDialog.StringGridVolumesMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TBoardVolumeDialog.StringGridVolumesMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TBoardVolumeDialog.ButtonOKClick(Sender: TObject);
begin
  if not FSubSet then  
    SaveQtyItem;
  //gBoardEnv.BroadCast.BroadCast( self, FQtyItem, etQty, vtUpdate );
  ModalResult := mrOK;
end;

procedure TBoardVolumeDialog.cbDefaultClick(Sender: TObject);
var
  i, j : integer;
begin

  if cbDefault.Checked then
  begin
    for i := 0 to ColCount - 1 do
      for j := 0 to RowCount - 1 do
        StringGridVolumes.Cells[i,j]  := IntToStr( DefSet[j,i] );
  end
  else
    UpdateGridVolume;
end;

procedure TBoardVolumeDialog.ChangeGird(iRow, iCol: integer);
begin
  StringGridVolumes.RowCount  := iRow;
  StringGridVolumes.ColCount  := iCol;
  if iRow > iCol then
  begin
    StringGridVolumes.Height:= 57 + 17;
    StringGridVolumes.Width := 231 - 55;
  end
  else begin
    StringGridVolumes.Height:= 57;
    StringGridVolumes.Width := 231;
  end;
end;

procedure TBoardVolumeDialog.ChangeGrid(aItem: TQtyItem);
var
  iIndex , i , j : integer;
begin
  if aItem = nil then Exit;

  //for i := 0 to ComboBoxItem.Items.Count - 1 do
  iIndex := ComboBoxItem.Items.IndexOfObject( aItem );

  if iIndex < 0 then Exit;

  ComboBoxItem.ItemIndex := iIndex;

  FQtyItem  := aItem;

  ComboBoxItemChange( nil );
end;

procedure TBoardVolumeDialog.ChangeGrid2(aGrid: TStringGrid);
var
  I: Integer;
  j: Integer;
begin
  StringGridVolumes.RowCount := aGrid.RowCount;
  StringGridVolumes.ColCount := aGrid.ColCount;

  for I := 0 to aGrid.RowCount - 1 do
    for j := 0 to aGrid.ColCount - 1 do
      StringGridVolumes.Cells[j, i] := aGrid.Cells[j, i];

  ComboBoxItem.Visible := false;
  cbDefault.Visible    := false;

  FSubSet := true;

end;

procedure TBoardVolumeDialog.ComboBoxItemChange(Sender: TObject);
var
  aItem : TQtyItem;
begin
  if ComboBoxItem.ItemIndex < 0 then Exit;
  aItem := TQtyItem( ComboBoxItem.Items.Objects[ ComboBoxItem.ItemIndex ] );

  FQtyItem := aItem;

  UpdateGridVolume;

end;

procedure TBoardVolumeDialog.UpdateGridVolume;
var
  i , j : integer;
begin
  if FQtyItem = nil then Exit;

  with StringGridVolumes do
    for i := 0 to ColCount - 1 do
      for j := 0 to  Rowcount- 1 do
        Cells[i,j] := IntToStr( FQtyItem.QtySet[j,i] );
end;


procedure TBoardVolumeDialog.SaveQtyItem;
var
  i , j : integer;
begin
  if FQtyItem = nil then Exit;

  with StringGridVolumes do
    for i := 0 to ColCount - 1 do
      for j := 0 to  Rowcount- 1 do
        FQtyItem.QtySet[j,i]  := StrToInt( Cells[i,j] );
end;

procedure TBoardVolumeDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TBoardVolumeDialog.FormCreate(Sender: TObject);
begin
  gBoardEnv.QtyItems.GetList( ComboBoxItem.Items );
  FSubSet := false;
end;

function TBoardVolumeDialog.GetVolume(iCol, iRow: Integer): Integer;
begin
  Result := StrToInt(StringGridVolumes.Cells[iCol,iRow]);
end;

procedure TBoardVolumeDialog.SetVolume(iCol, iRow: Integer;
  const Value: Integer);
begin
  StringGridVolumes.Cells[iCol,iRow] := IntToStr(Value);
end;

end.

