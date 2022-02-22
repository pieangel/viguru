unit FleSynConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CleSynthesizeConfig;

type
  TFrmSynConfig = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    listFrame: TListView;
    procedure listFrameDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure listFrameDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
    FFrameConfigs : TFrameConfigs;

    procedure SetConfigs( aConfigs : TFrameConfigs );
  public
    { Public declarations }
    procedure DrawListView;
    function GetConfigs: TFrameConfigs;
    property FrameConfigs : TFrameConfigs read FFrameConfigs  write SetConfigs;
  end;

var
  FrmSynConfig: TFrmSynConfig;

implementation

uses
 GleTypes;

{$R *.dfm}

{ TFrmSynConfig }
procedure TFrmSynConfig.Button1Click(Sender: TObject);
var
  i, iType : integer;
  aItem : TListItem;
begin
  for i := 0 to listFrame.Items.Count - 1 do
  begin
    aItem := listFrame.Items[i];
    iType := StrToIntDef(aItem.SubItems[1],0);
    FrameConfigs.Exchange(i, TFrameType(iType) ,  aItem.Checked);
  end;
end;

procedure TFrmSynConfig.DrawListView;
var
  i : integer;
  aItem: TListItem;
  aData : TFrameConfig;
begin
  for i := 0 to FFrameConfigs.Count - 1 do
  begin
    aData := FFrameConfigs.Items[i] as TFrameConfig;
    aItem := listFrame.Items.Add;

    aItem.Caption := '';
    aItem.Checked := aData.ShowHide;
     aItem.Data := aData.Frame;
    aItem.SubItems.Add(FrameString[aData.FrameType]);
    aItem.SubItems.Add(IntToStr(Integer(aData.FrameType)));
  end;
end;

function TFrmSynConfig.GetConfigs: TFrameConfigs;
begin
  Result := FFrameConfigs;
end;

procedure TFrmSynConfig.listFrameDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  iDrop, iSel, i  : integer;
  DropItem, aItem : TListItem;
  bShow : boolean;

begin
  if Sender = Source then
  begin
    if listFrame.Selected = nil then exit;
    iSel := listFrame.Selected.Index;
    DropItem := listFrame.GetItemAt(X,Y);
    if DropItem = nil then exit;
    iDrop := DropItem.Index;

    if iSel = iDrop then exit;

    if iSel > iDrop then
    begin
      DropItem := listFrame.Items.Insert(iDrop);
    end else
      DropItem := listFrame.Items.Insert(iDrop+1);

    DropItem.Assign(listFrame.Selected);
    listFrame.Selected.Delete;
  end;
end;

procedure TFrmSynConfig.listFrameDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = listFrame;
end;

procedure TFrmSynConfig.SetConfigs(aConfigs: TFrameConfigs);
begin
  FFrameConfigs := aConfigs;
  DrawListView;
end;

end.
