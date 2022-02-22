unit DSignalAlias;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,

  CleSymbols
  ;

type
  TSignalAliasDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    EditAlias: TEdit;
    ButtonOK: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    Label3: TLabel;
    EditStrategy: TEdit;
    Label5: TLabel;
    EditDescription: TEdit;
    EditSymbol: TEdit;
    gEx: TGroupBox;
    ButtonSymbol: TSpeedButton;
    Label4: TLabel;
    cbLinkSymbolUpdate: TCheckBox;
    edtSymbol: TEdit;
    procedure ButtonOKClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure cbLinkSymbolUpdateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FLinkSymbol: TSymbol;
    FIsEdit: boolean;
    function GetAlias: String;
    function GetDescription: String;
    function GetStrategy: String;
    function GetSymbol: String;
    procedure SetAlias(const Value: String);
    procedure SetDescription(const Value: String);
    procedure SetStrategy(const Value: String);
    procedure SetSymbol(const Value: String);
    function GetLinkSymbolUpdate: boolean;
    procedure SetLinkSymbolUpdate(const Value: boolean);
    procedure SetEdit(const Value: boolean);
    { Private declarations }
  public
    property Alias : String read GetAlias write SetAlias;
    property Description : String read GetDescription write SetDescription;
    property Strategy : String read GetStrategy write SetStrategy;
    property Symbol : String read GetSymbol write SetSymbol;
    property UseLinkSymbolUpdate : boolean read GetLinkSymbolUpdate write SetLinkSymbolUpdate;

    property LinkSymbol : TSymbol read FLinkSymbol write FLinkSymbol;
    property IsEdit     : boolean read FIsEdit write SetEdit;
  end;

var
  SignalAliasDialog: TSignalAliasDialog;

implementation

uses
  GAppEnv, DleSymbolSelect
  ;

{$R *.DFM}

procedure TSignalAliasDialog.ButtonOKClick(Sender: TObject);
begin

  if cbLinkSymbolUpdate.Checked then
    if FLinkSymbol = nil then
    begin
      ShowMessage('연결설정 일괄수정할 종목을 선택하세요.');
      Exit;
    end;

  if EditAlias.Text = '' then
  begin
    ShowMessage('신호명을 입력하십시오.');
    EditAlias.SetFocus;
  end else
  if EditStrategy.Text = '' then
  begin
    ShowMessage('Strategy를 입력하십시오.');
    EditStrategy.SetFocus;
  end else
  if EditSymbol.Text = '' then
  begin
    ShowMessage('종목을 입력하십시오.');
    EditSymbol.SetFocus;
  end else
//  if EditInterval.Text = '' then
//  begin
//    ShowMessage('Interval을 입력하십시오.');
//    EditInterval.SetFocus;
//  end else
    ModalResult := mrOK;
end;

function TSignalAliasDialog.GetAlias: String;
begin
  Result := EditAlias.Text;
end;

function TSignalAliasDialog.GetDescription: String;
begin
  Result := EditDescription.Text;
end;

function TSignalAliasDialog.GetLinkSymbolUpdate: boolean;
begin
  Result := cbLinkSymbolUpdate.Checked;  
end;

function TSignalAliasDialog.GetStrategy: String;
begin
  Result := EditStrategy.Text;
end;

function TSignalAliasDialog.GetSymbol: String;
begin
  Result := EditSymbol.Text;
end;

procedure TSignalAliasDialog.SetAlias(const Value: String);
begin
  EditAlias.Text := Value;
end;

procedure TSignalAliasDialog.SetDescription(const Value: String);
begin
  EditDescription.Text := Value;
end;

procedure TSignalAliasDialog.SetEdit(const Value: boolean);
begin
  FIsEdit := Value;
  if FIsEdit then
  begin
    gEx.Visible := true;
    Height  := Height +  ( 271 - 206 );
  end;
end;

procedure TSignalAliasDialog.SetLinkSymbolUpdate(const Value: boolean);
begin
  cbLinkSymbolUpdate.Checked  := Value;
end;

procedure TSignalAliasDialog.SetStrategy(const Value: String);
begin
  EditStrategy.Text := Value;
end;

procedure TSignalAliasDialog.SetSymbol(const Value: String);
begin
  EditSymbol.Text := Value;
end;

procedure TSignalAliasDialog.ButtonSymbolClick(Sender: TObject);
var
  aSymbol : TSymbol;
  aDlg : TSymbolDialog;
begin
  //
  aDlg := TSymbolDialog.Create(Self);
  try
    aDlg.SymbolCore := gEnv.Engine.SymbolCore;
    if aDlg.Open then begin
      aSymbol := aDlg.Selected;
      if aSymbol <> nil then
      begin
        FLinkSymbol := aSymbol;
        edtSymbol.Text  := FLinkSymbol.ShortCode;
      end;
    end;
  finally
    aDlg.Free;
  end;

end;

procedure TSignalAliasDialog.cbLinkSymbolUpdateClick(Sender: TObject);
begin
  label4.Enabled    := cbLinkSymbolUpdate.Checked;
  edtSymbol.Enabled := cbLinkSymbolUpdate.Checked;
  ButtonSymbol.Enabled  := cbLinkSymbolUpdate.Checked;
end;

procedure TSignalAliasDialog.EditChange(Sender: TObject);
begin
  EditDescription.Text := '(' + EditSymbol.Text + ', ' + EditStrategy.Text + ')';
end;

procedure TSignalAliasDialog.FormCreate(Sender: TObject);
begin
  FLinkSymbol := nil;
  FIsEdit     := false;
  //  206;
end;

end.
