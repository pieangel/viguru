unit DParamCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,

  Indicator;

type
  TParamConfig = class(TForm)
    LabelTitle: TLabel;
    ComboValue: TComboBox;
    ButtonOK: TButton;
    Button2: TButton;
    procedure ComboValueKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ParamQuery(aOwner : TForm; stCaption, stTitle : String;
  var stValue : String; bSelect : Boolean; const stValues : array of String) : Boolean;

function ParamQuery2(aOwner : TForm; stCaption, stTitle : String;
  var stValue : String; bSelect : Boolean; const stValues : array of String) : Boolean;

function ParamQuery3(aOwner : TForm; stCaption, stTitle : String;
  var stValue : String; bSelect : Boolean; const stValues : array of String) : Boolean;

function ShowMeQuery(aOwner : TForm; stCaption, stTitle : String; var stCode : string ) : boolean;

implementation

uses  GAppEnv;

{$R *.DFM}

function ShowMeQuery(aOwner : TForm; stCaption, stTitle : String; var stCode : string ) : boolean;
var
  aDlg : TParamConfig;
  i, iSelectIndex : Integer;
begin
  aDlg := TParamConfig.Create(aOwner);
  stCode := '';
  with aDlg do
  try
    Caption := stCaption;
    LabelTitle.Caption := stTitle;
    Caption := stCaption;
    LabelTitle.Caption := stTitle;

    ComboValue.Style := csOwnerDrawFixed;
    ComboValue.Items.Clear;
    gEnv.Engine.TradeCore.Accounts.GetList3( ComboValue.Items );

    if ComboValue.Items.Count > 0 then
      ComboValue.ItemIndex  := 0;

    Result := (ShowModal = mrOK);
    stCode := ComboValue.Text;
  finally
    aDlg.Free;
  end;

end;

function ParamQuery2(aOwner : TForm; stCaption, stTitle : String;
  var stValue : String; bSelect : Boolean; const stValues : array of String) : Boolean;
var
  aDlg : TParamConfig;
  i, iSelectIndex : Integer;
begin
  aDlg := TParamConfig.Create(aOwner);

  with aDlg do
  try
    Caption := stCaption;
    LabelTitle.Caption := stTitle;

    ComboValue.Style := csOwnerDrawFixed;
    ComboValue.Items.Clear;
    gEnv.Engine.TradeCore.Accounts.GetList3( ComboValue.Items );
    iSelectIndex := ComboValue.Items.IndexOf(stValue);
    if iSelectIndex >= 0 then
      ComboValue.ItemIndex := iSelectIndex
    else
      if ComboValue.Items.Count > 0 then
        ComboValue.ItemIndex  := 0;

    Result := (ShowModal = mrOK);
    stValue := ComboValue.Text;
  finally
    aDlg.Free;
  end;
end;


function ParamQuery3(aOwner : TForm; stCaption, stTitle : String;
  var stValue : String; bSelect : Boolean; const stValues : array of String) : Boolean;
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  Result := false;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      if gSymbol.Selected <> nil then
      begin
        stValue := gSymbol.Selected.Code;
        Result := true;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

function ParamQuery(aOwner : TForm; stCaption, stTitle : String;
  var stValue : String; bSelect : Boolean; const stValues : array of String) : Boolean;
var
  aDlg : TParamConfig;
  i, iSelectIndex : Integer;
begin
  aDlg := TParamConfig.Create(aOwner);

  with aDlg do
  try
    Caption := stCaption;
    LabelTitle.Caption := stTitle;

    if bSelect then
    begin
      ComboValue.Style := csOwnerDrawFixed;
      ComboValue.Items.Clear;
      for i:=Low(stValues) to High(stValues) do
        ComboValue.Items.Add(stValues[i]);
      iSelectIndex := ComboValue.Items.IndexOf(stValue);
      if iSelectIndex >= 0 then
        ComboValue.ItemIndex := iSelectIndex;
    end else
    begin
      ComboValue.Style := csSimple;
      ComboValue.Text := stValue;
    end;

    Result := (ShowModal = mrOK);
    stValue := ComboValue.Text;
  finally
    aDlg.Free;
  end;
end;


procedure TParamConfig.ComboValueKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    ModalResult := mrOK;
end;

end.
