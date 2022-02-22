unit CBoardEnv;

interface

uses
  Classes, SysUtils, Graphics,

  COBTypes, CBoardDistributor, CleStorage

  ;

type

      // 색상정보
  TColorInfo  = record
    ColorL,
    ColorLx,
    ColorLc,
    ColorS,
    ColorSx,
    ColorSc : TColor;
  end;

  TBoardEnv = class
  public
    QtyItems : TQtyItems;
    BroadCast: TBoardEnvItems;
    ColorInfo: TColorInfo;

    Constructor Create;
    Destructor  Destroy; override;

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;


implementation



{ TBoardEnv }

constructor TBoardEnv.Create;
begin
  QtyItems  := TQtyItems.Create;
  BroadCast := TBoardEnvItems.Create;

  with ColorInfo do
  begin
    ColorL  := $0000FF;
    ColorLx := $FFFF33;
    ColorLc := clBlack;
    ColorS  := $993333;
    ColorSx := $0066FF;
    ColorSc := clBlack;
  end;

end;

destructor TBoardEnv.Destroy;
begin

  BroadCast.Free;
  QtyItems.Free;
  inherited;
end;

procedure TBoardEnv.LoadEnv(aStorage: TStorage);
var
  iCount, i, j, k: integer;
  aItem : TQtyItem;
begin
  if aStorage = nil then Exit;

  iCount  := aStorage.FieldByName('QtySetCount').AsInteger;

  for i := 0 to iCount - 1 do
  begin
    aItem := QtyItems.New( aStorage.FieldByName( Format('QtyName[%d]', [i]) ).AsString );
    if aItem <> nil then
    begin
      for j := 0 to ColCount - 1 do
        for k := 0 to RowCount - 1 do
          aItem.QtySet[k, j] :=
          aStorage.FieldByName( Format('%s.QtySet[%d][%d] ',  [aItem.Name , k, j ]) ).AsInteger;

    end;
  end;

end;

procedure TBoardEnv.SaveEnv(aStorage: TStorage);
var
  i, j, k: integer;
  aItem : TQtyItem;
begin
  if aStorage = nil then Exit;

  if QtyItems = nil then Exit;

  aStorage.FieldByName('QtySetCount').AsInteger := QtyItems.Count;

  for i := 0 to QtyItems.Count - 1 do
  begin
    aItem := QtyItems.QtyItem[i];
    if aItem = nil then Continue;

    aStorage.FieldByName( Format('QtyName[%d]', [i]) ).AsString := aItem.Name;
    for j := 0 to ColCount - 1 do
      for k := 0 to RowCount - 1 do
        aStorage.FieldByName( Format('%s.QtySet[%d][%d] ',  [aItem.Name , k,j ]) ).AsInteger :=
          aItem.QtySet[k,j];

  end;

end;

end.
