unit FleHogaAnalysis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls,
  CleStorage,
  CInfoPainter, CleAnalPainter, CDistPainter, CleSymbols, CleQuoteBroker, CleDistributor;

type
  TFrmAnalysis = class(TForm)
    plTop: TPanel;
    plInfo: TPanel;
    plHoga: TPanel;
    plDist: TPanel;
    Label1: TLabel;
    cbCode: TComboBox;
    Button1: TButton;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Edit2: TEdit;
    upFilter: TUpDown;
    rdPrice: TRadioButton;
    rdHoga: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbCodeChange(Sender: TObject);
    procedure Edit2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rdHogaClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
  private
    FInfo: TInfoPainter;
    FAnal: TAnalPainter;
    FDist: TDistPainter;
    FSymbol: TSymbol;
    FQuote: TQuote;

    procedure SetSymbol( aSymbol : TSymbol );

    { Private declarations }
  public
    { Public declarations }
    InfoPaint : TPaintBox;
    AnalPaint : TPaintBox;
    DistPaint : TPaintBox;

    procedure SetControls;
    property Info : TInfoPainter read FInfo write FInfo;
    property Anal : TAnalPainter read FAnal write FAnal;
    property Dist : TDistPainter read FDist write FDist;
    //
    property Symbol : TSymbol read FSymbol;
    property Quote  : TQuote read FQuote;


    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure AnalMouseDown( Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    procedure Resize; overload;
    procedure Resize( bCreate : boolean ); overload;

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmAnalysis: TFrmAnalysis;

implementation

uses DleSymbolSelect, GAppEnv, GleLib, GleTypes;

{$R *.dfm}


procedure TFrmAnalysis.AnalMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
  dResult : double;
  iResult : integer;
  cLS : char;
begin
  if Button <> mbLeft then
    Exit;

  if rdPrice.Checked then begin
    FAnal.BPrice  := true;
    dResult := FAnal.GetPrice( X, Y );
    if dResult < 0 then
      Exit;
    FDist.Price := dResult;
  end;

  if rdHoga.Checked then begin
    FAnal.BPrice  := false;
    iResult := FAnal.GetHoga( X, Y, cLS);
    if iREsult < 0 then
      Exit;

    if cLS = 'S' then 
      FDist.Hoga := -1 * iResult
    else
      FDist.Hoga := iResult;
  end;

end;

procedure TFrmAnalysis.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, cbCode);
        // apply
      cbCodeChange(cbCode);
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmAnalysis.cbCodeChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  aSymbol := GetComboObject(cbCode) as TSymbol;
  if aSymbol = nil then Exit;

  if FSymbol = nil then
    FSymbol := aSymbol
  else begin
    if FSymbol = aSymbol then
      Exit;
  end;


  if FSymbol <> aSymbol then
  begin
    gEnv.Engine.QuoteBroker.Cancel(self, FSymbol);
    if FQuote <> nil then    
      FQuote.ForceDist := false;
  end;

  FQuote := gEnv.Engine.QuoteBroker.Subscribe(self, aSymbol,
                            QuoteBrokerEventHandler, spNormal);


  if FQuote <> nil then
  begin
    FQuote.ForceDist := true;
  end;

  //Resize;

  FInfo.Quote := FQuote;

  FAnal.Quote := FQuote;

  FDist.Quote := FQuote;

  if FQuote.EventCount > 0 then begin
    FInfo.Update;
    FAnal.Update;
  end;

  SetSymbol( aSymbol );

end;

procedure TFrmAnalysis.Edit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    FAnal.Filter  :=  StrToInt( Edit2.Text );
    FDist.Filter  :=  StrToInt( Edit2.Text );
    FAnal.Update;
    FDist.Update;
  end;
end;



procedure TFrmAnalysis.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  gEnv.Engine.QuoteBroker.Cancel( self );
  if FQuote <> nil then
    FQuote.ForceDist := false;

end;

procedure TFrmAnalysis.FormCreate(Sender: TObject);
begin
  SetControls;
end;

procedure TFrmAnalysis.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( self );
  if FQuote <> nil then
    FQuote.ForceDist := false;
  if FInfo <> nil then
    FInfo.Free;
  if FAnal <> nil then
    FAnal.Free;
  if FDist <> nil then
    FDist.Free;
end;

procedure TFrmAnalysis.FormResize(Sender: TObject);
begin
  Resize;
end;

procedure TFrmAnalysis.LoadEnv(aStorage: TStorage);
var
  aSymbol : TSymbol;
  iCnt : integer;
begin
  if aStorage = nil then Exit;

  iCnt := aStorage.FieldByName('FillterCnt').AsInteger;
  if iCnt <= 0 then
    upFilter.Position := 20
  else begin
    upFilter.Position := iCnt;
    FAnal.Filter  :=  iCnt;
    FDist.Filter  :=  iCnt;
  end;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(
      aStorage.FieldByName('Code').AsString);

  if aSymbol <> nil then
  begin
    AddSymbolCombo(aSymbol, cbCode);
        // apply
    cbCodeChange(cbCode);
  end;
end;

procedure TFrmAnalysis.QuoteBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  FInfo.Update;
  FAnal.Update;
  FDist.Update;
end;

procedure TFrmAnalysis.rdHogaClick(Sender: TObject);
begin
  if rdPrice.Checked then
  begin

  end
  else begin

  end;
end;

procedure TFrmAnalysis.Resize(bCreate: boolean);
begin
  if bCreate then
    Exit;
  FAnal.Width   := plHoga.Width;
end;

procedure TFrmAnalysis.Resize;
begin
  if FQuote = nil then Exit;

  if FQuote.Asks.Size = 5 then begin
    plHoga.Height := 340;
    Height := 499;
  end
  else begin
    plHoga.Height := 340 + 160;
    Height := 499 + 160;
  end;

  //FInfo.
  FInfo.Width   := plInfo.Width;
  FInfo.UpdateSize;
  FAnal.Height  := plHoga.Height;
  FAnal.Width   := plHoga.Width;
  FAnal.UpdateSize;
  FDist.Width   := plDist.Width;
  FDist.UpdateSize;
  //Finfo.Width   := plInfo.Width;
  FAnal.Update;
  FDist.Update;

end;

procedure TFrmAnalysis.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
    aStorage.FieldByName('Code').AsString := FSymbol.Code;
  aStorage.FieldByName('FillterCnt').AsInteger :=  StrToIntDef( Edit2.Text, 20 );

end;

procedure TFrmAnalysis.SetControls;
begin
  InfoPaint := TPaintBox.Create( plInfo );
  InfoPaint.Parent  := plInfo;
  InfoPaint.Align   := alClient;

  FInfo := TInfoPainter.Create( plInfo.Height, plInfo.width);
  FInfo.PaintBox  := InfoPaint;

  AnalPaint := TPaintBox.Create( plHoga );
  AnalPaint.Parent  := plHoga;
  AnalPaint.Align   := alClient;

  FAnal := TAnalPainter.Create( plHoga.Height, plHoga.Width);
  FAnal.PaintBox  := AnalPaint;
  FAnal.Filter  := StrToInt( Edit2.Text );

  DistPaint := TPaintBox.Create( plDist );
  DistPaint.Parent  := plDist;
  DistPaint.Align   := alClient;

  FDist := TDistPainter.Create( plDist.Height, plDist.Width);
  FDist.PaintBox  := DistPaint;
  FDist.Filter  := StrToInt( Edit2.Text );

  FAnal.PaintBox.OnMouseDown := AnalMouseDown;
end;

procedure TFrmAnalysis.SetSymbol( aSymbol : TSymbol );
begin
  FSymbol := aSymbol;
  Edit1.Text := FSymbol.ShortName;
end;

end.
