unit DSelectAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CleAccounts, ComCtrls;

type
  TFrmSelect = class(TForm)
    lvAcnt: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvAcntDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSelect: TFrmSelect;

implementation

uses FOrpMain, GleLib, CleFQN, GAppEnv;

{$R *.dfm}

procedure TFrmSelect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmSelect.FormCreate(Sender: TObject);
var
  i : integer;
  aAcnt : TAccount;
  aListItem : TListItem;
  stTmp : string;
begin
  if OrpMainForm = nil then Exit;  

  for i := 0 to OrpMainForm.AccountLoader.Accounts.Count - 1 do
  begin
    aAcnt := OrpMainForm.AccountLoader.Accounts.Accounts[i];

    if aAcnt = nil then Continue;

    aListItem := lvAcnt.Items.Add;
    aListItem.Data  := aAcnt;
    aListItem.Caption := aAcnt.Code;

    stTmp := ifThenStr( aAcnt.Market = mtStock, 'S', 'F' );

    if aAcnt.Business = nil then
    begin
      aAcnt.Business  := TBusiness.Create(nil);

      aAcnt.Business.Code := '999';
      aAcnt.Business.Division := '100';
    end;

    aListItem.SubItems.Add( stTmp );
    aListItem.SubItems.Add( aAcnt.Business.Code );
    aListItem.SubItems.Add( aAcnt.CountryCode );
  end;

end;

procedure TFrmSelect.lvAcntDblClick(Sender: TObject);
var
  aItem : TListItem;
begin
  aItem := lvAcnt.Selected;

  if aItem = nil then Exit;

  if aItem.Data = nil then
    Exit;

  gEnv.Info.GetAccount( aItem );
  
end;

end.
