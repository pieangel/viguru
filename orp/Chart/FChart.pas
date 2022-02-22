unit FChart;

//
// Multi-purposed Chart Window
//
//
//

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, Buttons, ImgList, Math, Grids,
  //
  CleSymbols, CleQuoteBroker, CleAccounts, ClePositions, Shows,
  GleTypes, GleLib, GleConsts, CleDistributor, CleFills, CleStorage,

  DChartCfg,
  ChartCentralBase, ChartCentral, ChartHandler,
  Symbolers, Indicator, Stickers,
  ListSave, ExtDlgs;

type
  TChartForm = class(TForm)
    PanelCom: TPanel;
    StatusBar: TStatusBar;
    ScrollBar: TScrollBar;
    PaintGraph: TPaintBox;
    PopupMenu1: TPopupMenu;
    NConfigSymbols: TMenuItem;
    NConfigIndicators: TMenuItem;
    NConfigScreen: TMenuItem;
    N4: TMenuItem;
    NInsertIndicator: TMenuItem;
    N6: TMenuItem;
    NFrame: TMenuItem;
    N7: TMenuItem;
    ButtonZoomIn: TSpeedButton;
    ButtonZoomOut: TSpeedButton;
    ButtonTLinePrep: TSpeedButton;
    ButtonRLine: TSpeedButton;
    ButtonCross: TSpeedButton;
    ButtonVLine: TSpeedButton;
    NConfig: TMenuItem;
    NSave: TMenuItem;
    N8: TMenuItem;
    NDelete: TMenuItem;
    NInsertSymbol: TMenuItem;
    N10: TMenuItem;
    ComboIndicator: TComboBox;
    Label1: TLabel;
    ButtonHelp: TSpeedButton;
    ButtonFix: TSpeedButton;
    ImageFills: TImageList;
    ButtonMini: TSpeedButton;
    N1: TMenuItem;
    MenuClose: TMenuItem;
    MenuTrans: TMenuItem;
    ButtonSave: TSpeedButton;
    ButtonPrint: TSpeedButton;
    SaveDialog: TSaveDialog;
    ButtonSync: TSpeedButton;
    ButtonNormal: TSpeedButton;
    ButtonOpenTemplate: TSpeedButton;
    ButtonSaveTemplate: TSpeedButton;
    ComboShowMe: TComboBox;
    ShowMe1: TMenuItem;
    dlgSave: TSaveDialog;
    procedure Label1DblClick(Sender: TObject);
    procedure PopMenuClick(Sender: TObject);
    procedure PopMenuPopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboIndicatorChange(Sender: TObject);
//    procedure ButtonAccountClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintGraphDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonMiniClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
    procedure ButtonSyncClick(Sender: TObject);
    procedure ButtonOpenTemplateClick(Sender: TObject);
    procedure ButtonSaveTemplateClick(Sender: TObject);
    procedure ComboShowMeChange(Sender: TObject);
    procedure PaintGraphDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintGraphDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    FChartCentral : TChartCentral;
    FChartHandler : TChartHandler;
    //
    FIsMini : Boolean;
    //
    FTemplate : String;

    procedure InitControls;
    procedure SetTitle;
    procedure FillProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure SetMini(bMini : Boolean; bResize : Boolean = True);
    procedure StateChanged(Sender : TObject);

    // called by WinCentral
    procedure SetData(Data : TObject);

    procedure SetDefault(Stream : TObject);
    procedure GetDefault(Stream : TObject);
    procedure CallWorkForm(Sender : TObject);
    procedure SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    procedure GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    //  Form Move
    procedure WMMove(var aMsg: TMsg); message WM_MOVE;
    procedure CreateProfitNLoss(aPos: TPosition);
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);    
  end;

//var
//  ChartForm: TChartForm;

implementation

uses
  GAppEnv, DParamCfg;

{$R *.DFM}


//========================< WinCentral Events >=========================//

procedure TChartForm.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('FIsMini').AsBoolean := FIsMini;
  FChartCentral.SaveEnv( aStorage );
end;

procedure TChartForm.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  FIsMini := aStorage.FieldByName('FIsMini').AsBoolean;
  FChartCentral.LoadEnv( aStorage );
  SetTitle;

  {
  if FChartCentral.Account <> nil then
    SetComboIndex(ComboAccount, FChartCentral.Account );
  }
  FChartCentral.Resize(PaintGraph.ClientRect);

end;

procedure TChartForm.SetData(Data : TObject);
var
  i : Integer;
begin       {
  if Data = nil then Exit;

  //-- set account
  if Data is TAccount then
    for i := 0 to ComboAccount.Items.Count-1 do
      if Data = ComboAccount.Items.Objects[i] then
      begin
        ComboAccount.ItemIndex := i;
        ComboAccountChange(ComboAccount);
      end;

  //-- set symbol
  if (Data is TSymbol) and (FChartCentral <> nil) then
  begin
    //-- added by sms -> fix 'TPopupList access violation'
    if FChartCentral.MainCharter <> nil then
      FChartCentral.MainCharter.SetSymbol(Data as TSymbol);
    //FChartCentral.SetMainSymboler(Data as TSymbolItem);
    SetTitle;
  end;   }
end;


procedure TChartForm.CallWorkForm(Sender : TObject);
begin
  if Sender = nil then Exit;

end;

procedure TChartForm.GetDefault(Stream: TObject);
begin
  FChartCentral.GetScreenPersistence(Stream as TMemoryStream);
end;

procedure TChartForm.SetDefault(Stream: TObject);
begin
  FChartCentral.SetScreenPersistence(Stream as TMemoryStream);
  //add by sms
  FChartCentral.Resize(PaintGraph.ClientRect);
end;

procedure TChartForm.GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  if CompareStr(stKey, TPKey_CHART) <> 0 then Exit;

  FChartCentral.GetTemplate(iVersion, stKey, Stream);
end;

procedure TChartForm.SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  if CompareStr(stKey, TPKey_CHART) <> 0 then Exit;

  FChartCentral.SetTemplate(iVersion, stKey, Stream);
end;

//==========================< TradeCentral Events >========================//

// 체결
procedure TChartForm.FillProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  i, j,  iP : Integer;
  aFill : TFill;
begin

  if DataObj = nil then Exit;
  if not (DataObj is TFill) then Exit;

  aFill := DataObj as TFill;
  FChartCentral.DoFill(aFill);
end;

//-----------------------< UI Events : Menu >----------------------//


procedure TChartForm.PaintGraphDblClick(Sender: TObject);
begin
{$ifdef DEBUG}
  // gLog.Add(lkDebug, 'Chart', 'MouseDblClick', 'Enter');
{$endif}

{
  with FChartCentral do
    if Selected <> nil then
    begin
      // Config(Selected);
    end else
      ConfigScreen;
}

{$ifdef DEBUG}
  // gLog.Add(lkDebug, 'Chart', 'MouseDblClick', 'Exit');
{$endif}
end;

procedure TChartForm.PaintGraphDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  aGrid : TStringGrid;
  i : integer;
  aPos : TPosition;
  stLog : string;
begin
  aPos := nil;
  aGrid := Source as TStringGrid;
  if aGrid.Row < 1 then exit;
  aPos := aGrid.Objects[0, aGrid.Row] as TPosition;
  if aPos <> nil then
    CreateProfitNLoss( aPos );
end;

procedure TChartForm.PaintGraphDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TStringGrid;
end;

//==========================< Popup Menu >==========================//

procedure TChartForm.PopMenuClick(Sender: TObject);
begin
  with FChartCentral do
  case (Sender as TMenuItem).Tag of
    110 : // 종목설정
         if ConfigSymbols then
         begin
           SetTitle;
         end;
    120 : // 지표설정
          ConfigIndicators ;

    130 : // 화면설정
         if ConfigScreen then
         begin
    //       gWin.SetFormDefault(Self);
    //       gWin.ModifyWorkspace;
         end;
    140 : // show me 설정
        begin
          ConfigShowMe;
          SetTitle;
        end;
    210 :  // 종목추가
         if InsertSymbol then
         begin
           SetTitle;
         end;
    220 :   // 지표추가
       InsertIndicator ;
    310 :  // 선택항목 설정
         if Config(Selected) then
         begin
           if Selected = FChartCentral.MainCharter then
             SetTitle;
         end;
    320 : // 선택항목 삭제
         begin
           Delete(Selected);
         end;
    410 : ; // 자료저장
       //FChartCentral.ExportData
    510 :  ; // Frame?
    610 : if FIsMini then   // 종합챠트로 전환
            SetMini(False);
    999 : Close;
  end;
end;

procedure TChartForm.PopMenuPopup(Sender: TObject);
var
  bSelected : Boolean;
begin
  bSelected := (FChartCentral.Selected <> nil);
  //
  NConfigSymbols.Visible := not bSelected;
  //NConfigSymbols.Visible := (FChartCentral.MainCharter <> nil) and not(bSelected)
  //      and FChartCentral.MainCharter.DataXTerms.Ready;

  NConfigIndicators.Visible := not bSelected;
  NConfigScreen.Visible := not bSelected;

  //sms
  //NInsertSymbol.Visible := not bSelected and (FChartCentral.MainCharter = nil);
  NInsertSymbol.Visible := (FChartCentral.MainCharter <> nil) and
                FChartCentral.CanInsertSymbol and not(bSelected) and
                FChartCentral.MainCharter.DataXTerms.Ready;

  NInsertIndicator.Visible := not bSelected;
  //
  NConfig.Visible := bSelected and
                   ((FChartCentral.Selected is TSymboler) or
                    (FChartCentral.Selected is TIndicator));
  if NConfig.Visible then
    NConfig.Caption := '''' + FChartCentral.Selected.Title + '''' + ' 설정(&C)';

  //NSave.Visible := bSelected;
  NSave.Visible := False;
  NDelete.Visible := bSelected;
  //
  NFrame.Visible := False;
end;

//=========================< Form Events >==========================//

procedure TChartForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin

  //-- create objects
  FChartCentral :=
          TChartCentral.Create(Self, PaintGraph.Canvas, PaintGraph.ClientRect,
                               ScrollBar);
  FChartCentral.ImageFills := ImageFills;

  FChartHandler := TChartHandler.Create(Self, FChartCentral, PaintGraph, StatusBar);
  FChartHandler.ButtonZoomIn  := ButtonZoomIn;
  FChartHandler.ButtonZoomOut := ButtonZoomOut;
  FChartHandler.ButtonNormal  := ButtonNormal;
  FChartHandler.ButtonTLine   := ButtonTLinePrep;
  FChartHandler.ButtonHLine   := ButtonRLine;
  FChartHandler.ButtonVLine   := ButtonVLine;
  FChartHandler.ButtonCross   := ButtonCross;
  FChartHandler.OnStateChanged := StateChanged;


  FIsMini := False;

  MenuClose.Visible := FIsMini;
  MenuTrans.Visible := FIsMini;

  //
  FTemplate := '';

  //-- subscribe fill data
  //gEnv.Engine.TradeBroker.
  gEnv.Engine.TradeBroker.Subscribe( Self, FillProc );

  //
  if FIsMini then
  begin
    StatusBar.Visible := True;
    ScrollBar.Visible := True;

    //move by sms
    Width := 300;
    Height := 200;

    SetMini(FIsMini);
  end;

  // 지표 콤보

  if gIndicatorList <> nil then
  begin
    for I := 0 to gIndicatorList.Count - 1 do
      with gIndicatorList.Items[i] as TIndicatorListItem do
        ComboIndicator.AddItem(ClassDesc,TIndicator(IndicatorClass) );
  end;

  for i := 0 to FChartCentral.ShowMe.Count - 1 do
    ComboShowMe.AddItem(FChartCentral.ShowMe.ShowMe[i].Name,
                        FChartCentral.ShowMe.ShowMe[i]);

  InitControls;
end;


procedure TChartForm.FormActivate(Sender: TObject);
begin
  if not FChartCentral.Initialized then
    if FChartCentral.InsertSymbol then
      SetTitle
    else
      Release;
end;


procedure TChartForm.FormDestroy(Sender: TObject);
begin
  //-- unsubscribe to fill
  gEnv.Engine.TradeBroker.Unsubscribe( Self );

  //-- release resources
  FChartHandler.Free;
  FChartCentral.Free;
end;

procedure TChartForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TChartForm.FormResize(Sender: TObject);
begin
  FChartCentral.Resize(PaintGraph.ClientRect);
end;

procedure TChartForm.WMMove(var aMsg: TMsg);
begin
//  gWin.ModifyWorkspace;
end;

//=========================< Utility Routines >=========================//

procedure TChartForm.InitControls;
begin

  ComboIndicator.Items.InsertObject(0, '<지표 선택>', nil);
  if ComboIndicator.Items.Count > 0 then
    ComboIndicator.ItemIndex := 0;

  ComboShowMe.Items.InsertObject( 0, '<Show Me>', nil );
  if ComboShowMe.Items.Count > 0 then  
    ComboShowMe.ItemIndex := 0;
end;

procedure TChartForm.Label1DblClick(Sender: TObject);
begin
  if not FChartCentral.Initialized then
    if FChartCentral.InsertSymbol then
      SetTitle
    else
      Release;
end;



procedure TChartForm.SetTitle;
var
  i : integer;
  stTmp : string;
  aItem : TShowMeItem;
begin

  if FChartCentral.MainCharter <> nil then
    Caption := '차트 : ' + FChartCentral.MainCharter.Title
  else
    Caption := '차트';
  // show me 내용도 caption 에....

  stTmp := Caption + ' ';
  for i := 0 to FChartCentral.ShowMe.Count - 1 do
  begin
    aItem := FChartCentral.ShowMe.ShowMe[i];
    if aItem.EnAbled then
    begin
      stTmp := stTmp + ' ' + aItem.Name + ' : ' + aItem.Param;
      stTmp := stTmp + '  ';
    end;
  end;

  Caption := stTmp;
end;


//============================< Key Input >===========================//

procedure TChartForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_DELETE, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_PRIOR, VK_NEXT] then
  begin
    FChartCentral.DoKey(Key);
    Key := 0;
  end else
  if Key = VK_ESCAPE then
  begin
    if FIsMini then
      SetMini(False);
  end;
end;

//=========================< Account Selection >=======================//

procedure TChartForm.ComboIndicatorChange(Sender: TObject);
var
  //aAccount : TAccount;
  idx : integer;
  aIndi : TIndicatorClass;
  bExsit  : boolean;
begin
  idx := ComboIndicator.ItemIndex;
  if idx < 1  then Exit;

  aIndi := TIndicatorClass( ComboIndicator.Items.Objects[ idx ]);

  bExsit := FChartCentral.CreateIndicator(  aIndi );

  if not bExsit then
  begin
    ShowMessage('이미 생성된 지표');
  end;

end;

procedure TChartForm.CreateProfitNLoss( aPos : TPosition );
var
  //aAccount : TAccount;
  idx : integer;
  aIndi : TIndicatorClass;
  bExsit  : boolean;
  I: Integer;
begin

  idx :=-1;

  for I := 0 to ComboIndicator.Items.Count - 1 do
    if ComboIndicator.Items[i] = 'TProfitNLoss2' then
    begin
      idx :=i;
      break;
    end;

  if idx < 0 then
    Exit;

  aIndi := TIndicatorClass( ComboIndicator.Items.Objects[ idx ]);

  bExsit := FChartCentral.CreateIndicator(  aPos, aIndi );

  if not bExsit then
  begin
    ShowMessage('이미 생성된 지표');
  end;

end;

procedure TChartForm.ComboShowMeChange(Sender: TObject);
var
  idx : Integer;
  stCode : string;
  bRes  : boolean;
  aItem : TShowMeItem;
begin
  //
  idx := ComboShowMe.ItemIndex;

  if idx < 1 then Exit;

  case idx of
  1 :
    begin
      aItem := TShowMeItem( ComboShowMe.Items.Objects[idx] );
      if aItem = nil then Exit;
      if aItem.EnAbled then Exit;
      FChartCentral.CreateShowMe( aItem );
    end;
  end;

  SetTitle;


end;

{
procedure TChartForm.ButtonAccountClick(Sender: TObject);
begin
  if SelectAccount(Self, ComboAccount) <> nil then
    ComboAccountChange(ComboAccount);
end;
}
procedure TChartForm.StateChanged(Sender : TObject);
begin
{
  gWin.SetFormDefault(Self);
  gWin.ModifyWorkspace;
  }
end;

//=======================< Handles Mini >=========================//

procedure TChartForm.ButtonMiniClick(Sender: TObject);
begin
  if FIsMini then Exit;

  SetMini(True);
end;

procedure TChartForm.SetMini(bMini : Boolean; bResize : Boolean);
begin
  FIsMini := bMini;

  if bMini then
  begin
    PanelCom.Visible := False;
    ScrollBar.Visible := False;
    StatusBar.Visible := False;

    ButtonFix.Down := True;
    if Assigned(ButtonFix.Onclick) then
      ButtonFix.OnClick(ButtonFix);

    BorderStyle := bsNone;
  end else
  begin
    PanelCom.Visible := True;
    StatusBar.Visible := True;
    ScrollBar.Visible := True;

    BorderStyle := bsSizeable;
  end;

  FChartCentral.IsMini := bMini;
  if bResize then
    FChartCentral.Resize(PaintGraph.ClientRect);

  MenuClose.Visible := FIsMini;
  MenuTrans.Visible := FIsMini;
end;

//=======================< Other Buttons >=========================//

procedure TChartForm.ButtonSyncClick(Sender: TObject);
begin
  //FChartCentral.SyncSymbol(ButtonSync.Down);
  FChartCentral.SymbolSynchronized := ButtonSync.Down;

 // gWin.ModifyWorkspace;
end;

procedure TChartForm.ButtonSaveClick(Sender: TObject);
var
  i : Integer;
  aSave : TDataSave;
begin
  if (FChartCentral.MainCharter <> nil)
     and (FChartCentral.MainCharter.XTerms.Symbol <> nil) then
  begin
    aSave := TDataSave.Create;
    aSave.Delimiter := ','; // csv file
    try
      aSave.AddLine('StartTime, LastTime, Open, High, Low, Close, Volume');
      with FChartCentral.MainCharter.XTerms do
      for i:=0 to Count-1 do
      begin
        aSave.AddField(FormatDateTime('yy/mm/dd hh:nn:ss', XTerms[i].StartTime));
        aSave.AddField(FormatDateTime('yy/mm/dd hh:nn:ss', XTerms[i].LastTime));
        aSave.AddField(Format('%.2f', [XTerms[i].O]));
        aSave.AddField(Format('%.2f', [XTerms[i].H]));
        aSave.AddField(Format('%.2f', [XTerms[i].L]));
        aSave.AddField(Format('%.2f', [XTerms[i].C]));
        aSave.AddField(IntToStr(Floor(XTerms[i].FillVol)));
        aSave.NewLine;
      end;
      aSave.Save(FChartCentral.MainCharter.Title + '.csv', True);
    finally
      aSave.Free;
    end;
  end;
end;

procedure TChartForm.ButtonPrintClick(Sender: TObject);
begin
  FChartCentral.Print(Self.Caption, PaintGraph.Width, PaintGraph.Height);
end;

procedure TChartForm.ButtonHelpClick(Sender: TObject);
begin
  //gHelp.Show(ID_CHART);
end;


procedure TChartForm.ButtonOpenTemplateClick(Sender: TObject);
var
  Pt  :TPoint;
  DC  :HDC;
  Bmp :TBitmap;
  xg, yg : integer;

begin

  Pt.x := 0;
  Pt.y := 0;
  Pt := ClientToScreen(Pt);

  xg := GetSystemMetrics(SM_CXSIZEFRAME) ;
  yg := GetSystemMetrics( SM_CYCAPTION ) + GetSystemMetrics(SM_CYSIZEFRAME) ;

  Bmp := TBitMap.Create;

  try
    Bmp.Width  := Width;
    Bmp.Height := Height;
    DC := GetDC(0);
    BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, DC, Pt.x - xg , Pt.y - yg -1, SRCCOPY);
    ReleaseDC(0,DC);

    if dlgSave.Execute then
    begin
      Bmp.SaveToFile( dlgSave.FileName  );
    end;

  finally
     Bmp.Free;
  end;
end;

procedure TChartForm.ButtonSaveTemplateClick(Sender: TObject);
begin
 // gWin.SaveTemplate(Self, TPKEY_CHART, '[챠트]지표설정', FTemplate);
end;

end.
