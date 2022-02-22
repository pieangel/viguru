unit DBoardEnv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CBoardEnv, COBTypes, CBoardDistributor, StdCtrls, Grids
  ;

type
  TBoardConfig = class(TForm)
    StringGridVolumes: TStringGrid;
    ComboBoxItem: TComboBox;
    cbDefault: TCheckBox;
    ButtonOK: TButton;
    edtAdd: TButton;
    edtDel: TButton;
    edtName: TEdit;
    Button3: TButton;
    Button2: TButton;
    Button1: TButton;
    procedure StringGridVolumesKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridVolumesMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGridVolumesMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ButtonOKClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtAddClick(Sender: TObject);
    procedure ComboBoxItemChange(Sender: TObject);
    procedure edtDelClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbDefaultClick(Sender: TObject);
  private
    { Private declarations }
    FQtyItem  : TQtyItem;
    procedure UpdateGridVolume;
  public
    { Public declarations }
  end;

var
  BoardConfig: TBoardConfig;

implementation

uses GAppEnv;

{$R *.dfm}

procedure TBoardConfig.Button1Click(Sender: TObject);
var
  i, j : integer;
begin
  if FQtyItem <> nil then
  begin
    for i := 0 to ColCount - 1 do
      for j := 0 to RowCount - 1 do
        FQtyItem.QtySet[j,i] := StrToIntDef( StringGridVolumes.Cells[i,j], 0 );
  end;

  gBoardEnv.BroadCast.BroadCast( self, FQtyItem, etQty, vtUpdate );
end;

procedure TBoardConfig.Button2Click(Sender: TObject);
var
  i, j : integer;
begin
  //
  edtName.Text := '';
  edtName.Enabled := true;

  for i := 0 to ColCount - 1 do
    for j := 0 to RowCount - 1 do
      StringGridVolumes.Cells[i,j]  := IntToStr( DefSet[j,i] );
end;

procedure TBoardConfig.Button3Click(Sender: TObject);
begin
  //
  close;
end;

procedure TBoardConfig.ButtonOKClick(Sender: TObject);
var
  i, j : integer;
begin
  if FQtyItem <> nil then
  begin
    for i := 0 to ColCount - 1 do
      for j := 0 to RowCount - 1 do
        FQtyItem.QtySet[j,i] := StrToIntDef( StringGridVolumes.Cells[i,j], 0 );
  end;

  gBoardEnv.BroadCast.BroadCast( self, FQtyItem, etQty, vtUpdate );

  close;
end;

procedure TBoardConfig.cbDefaultClick(Sender: TObject);
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

procedure TBoardConfig.ComboBoxItemChange(Sender: TObject);
var
  aItem : TQtyItem;
begin
  if ComboBoxItem.ItemIndex < 0 then Exit;
  aItem := TQtyItem( ComboBoxItem.Items.Objects[ ComboBoxItem.ItemIndex ] );

  FQtyItem := aItem;

  UpdateGridVolume;

end;

procedure TBoardConfig.UpdateGridVolume;
var
  i , j : integer;
begin
  if FQtyItem = nil then Exit;

  edtName.Text := FQtyItem.Name;

  with StringGridVolumes do
    for i := 0 to ColCount - 1 do
      for j := 0 to  Rowcount- 1 do
        Cells[i,j] := IntToStr( FQtyItem.QtySet[j,i] );
end;

procedure TBoardConfig.edtAddClick(Sender: TObject);
var
  aItem : TQtyItem;
  i: Integer;
  j: Integer;
begin
  //
  if edtName.Text = '' then
  begin
    ShowMessage('이름 입력');
    Exit;
  end;

  aItem := gBoardEnv.QtyItems.New( edtName.Text );

  for i := 0 to ColCount - 1 do
    for j := 0 to RowCount - 1 do
      aItem.QtySet[j,i] := StrToIntDef( StringGridVolumes.Cells[i,j], 0 );

  ComboBoxItem.Clear;

  gBoardEnv.QtyItems.GetList( ComboBoxItem.Items );

  i := ComboBoxItem.Items.IndexOfObject( aItem );

  if i >= 0 then
  begin
    ComboBoxItem.ItemIndex  := i;
    ComboBoxItemChange( nil );
  end;

  gBoardEnv.BroadCast.BroadCast( self, aItem, etQty, vtAdd);

end;

procedure TBoardConfig.edtDelClick(Sender: TObject);
begin
  if FQtyItem = nil then Exit;

  if FQtyItem.Name = 'Default' then
  begin
    ShowMessage('Default 수량셋은 지울수 없음');
    Exit;
  end;

  gBoardEnv.BroadCast.BroadCast( self, FQtyItem, etQty, vtDelete );

  gBoardEnv.QtyItems.Del( FQtyItem );

  ComboBoxItem.Clear;

  gBoardEnv.QtyItems.GetList( ComboBoxItem.Items );

  if ComboBoxItem.Items.Count > 0 then
  begin
    ComboBoxItem.ItemIndex  := 0;
    ComboBoxItemChange( nil );
  end;

  edtName.Enabled := false;

end;

procedure TBoardConfig.FormCreate(Sender: TObject);
begin
  gBoardEnv.QtyItems.GetList( ComboBoxItem.Items );

  if ComboBoxItem.Items.Count > 0 then
  begin
    ComboBoxItem.ItemIndex  := 0;
    ComboBoxItemChange( nil );
  end;

  edtName.Enabled := false;
end;

procedure TBoardConfig.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TBoardConfig.StringGridVolumesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9',#13]) then
    Key := #0;
end;

procedure TBoardConfig.StringGridVolumesMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TBoardConfig.StringGridVolumesMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

end.
