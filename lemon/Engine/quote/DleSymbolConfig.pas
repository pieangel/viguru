unit DleSymbolConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  CleSymbols
  ;

type
  TSymbolFillter = class(TForm)
    lbSrc: TListBox;
    lbDest: TListBox;
    btnMove: TButton;
    btnDel: TButton;
    btnClear: TButton;
    Button4: TButton;
    Button5: TButton;
    lbTitle: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbSrcDblClick(Sender: TObject);
    procedure btnMoveClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure lbDestDblClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure lbSrcKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbDestKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FDiv  : integer;
    FParent : TObject;
  public
    { Public declarations }

    procedure init( iDiv : integer; Obj : TObject );
    procedure AddList( index : integer );
  end;

var
  SymbolFillter: TSymbolFillter;

implementation

uses GAppEnv, DleSymbolSearch, CleMarkets;

{$R *.dfm}

procedure TSymbolFillter.btnMoveClick(Sender: TObject);
var
  iVar : integer;
begin
  for ivar := 0 to lbSrc.Count - 1 do
  begin
    if lbSrc.Selected[ ivar ] then
      AddList( ivar );
  end;

end;

procedure TSymbolFillter.Button4Click(Sender: TObject);
var
  i : integer;
  aDlg : TSymbolSearch;
  aSymbol : TSymbol;
begin
  if FDiv < 0 then Exit;

  aDlg  :=  TSymbolSearch( FParent );

  if FDiv = 1 then
  begin  // 기초자산
    gEnv.Engine.GiFillter.Underlyings.Clear;
    aDlg.listUnderlying.Clear;
    for i := 0 to lbDest.Count - 1 do begin
      aSymbol  := lbDest.Items.Objects[i] as TSymbol;
      gEnv.Engine.GiFillter.AddUnderlying(aSymbol  );
      aDlg.listUnderlying.AddItem( aSymbol.Name, aSymbol );
    end;
  end
  else begin
    gEnv.Engine.GiFillter.LPs.Clear;
    aDlg.listLP.Clear;
    for i := 0 to lbDest.Count - 1 do begin
      gEnv.Engine.GiFillter.AddLp( TLp(lbDest.Items.Objects[i]) );
      aDlg.listLP.AddItem( lbDest.Items[i], lbDest.Items.Objects[i]);
    end;
  end;

  close;

end;

procedure TSymbolFillter.Button5Click(Sender: TObject);
begin
  close;
end;

procedure TSymbolFillter.btnDelClick(Sender: TObject);
var
  iVar : integer;
  bContinue : boolean;
begin

  bContinue := false;
  for ivar := 0 to lbDest.Count - 1 do
  begin
    if lbDest.Selected[ ivar ] then
    begin
      lbDest.Items.Delete(ivar);
      bContinue := true;
      break;
    end;
  end;

  if bContinue then  
    btnDelClick( nil );
end;



procedure TSymbolFillter.btnClearClick(Sender: TObject);
begin
  lbDest.Clear;
end;

procedure TSymbolFillter.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSymbolFillter.FormCreate(Sender: TObject);
begin
  //
  FDiv  := -1;
  lbSrc.Clear;
  lbDest.Clear;
end;

procedure TSymbolFillter.init(iDiv: integer; Obj : TObject);
begin
  // 기초자산
  if iDiv > 0 then
  begin
    gEnv.Engine.SymbolCore.Underlyings.GetList(lbSrc.Items);
    gEnv.Engine.GiFillter.GetUnderlyingList( lbDest.Items);
  end
  else begin
  // LP
    gEnv.Engine.SymbolCore.LPs.GetLpList( lbSrc.Items);
    gEnv.Engine.GiFillter.GetLpList( lbDest.Items );
  end;
  FDiv := iDiv;
  FParent := Obj;
end;

procedure TSymbolFillter.lbDestDblClick(Sender: TObject);
  var
    index : integer;
begin
  index := lbDest.ItemIndex;

  if index < 0 then
    Exit;

  lbDest.Items.Delete(index);

end;

procedure TSymbolFillter.lbDestKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and ( Key = 65 )  then
    lbDest.SelectAll;

end;

procedure TSymbolFillter.lbSrcDblClick(Sender: TObject);
  var
    index : integer;
begin
  index := lbSrc.ItemIndex;

  if index < 0 then
    Exit;

  AddList( index ); 
end;

procedure TSymbolFillter.lbSrcKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and ( Key = 65 )  then
    lbSrc.SelectAll;

end;

procedure TSymbolFillter.AddList(index: integer);
var
  iRes : integer;
  aULGroup : TMarketGroup;
begin
  if FDiv = 1 then
  begin
    aULGroup := lbSrc.Items.Objects[index] as TMarketGroup;
    iRes := lbDest.Items.IndexOfObject( aULGroup.Ref );

    if iRes < 0 then
      lbDest.Items.AddObject(
         lbSrc.Items[index],
         aULGroup.Ref
        );
  end
  else begin
    iRes := lbDest.Items.IndexOfObject( lbSrc.Items.Objects[index] );

    if iRes < 0 then
      lbDest.Items.AddObject(
         lbSrc.Items[index],
         lbSrc.Items.Objects[index]
        );
  end;

end;

end.
