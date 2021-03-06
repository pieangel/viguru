unit GleLib;

interface

uses
  Windows, Classes, Forms, SysUtils, Graphics, WinSock, Dialogs, Math, NB30,
  MMSystem,  DateUtils, Messages,
  CommCtrl, StdCtrls, ComCtrls, Grids, Menus,GleConsts,
  CleSymbols, ShellApi, iMM;

const
  Denominator  = 250 * 6 * 3600;
  DayToSec     = 6 * 60 * 60;
  HourToSec    = 60 * 60;
  MinToSec     = 60;

type
  TmpGrid = class( TCustomGrid );

//-----------------------------------------------------------------< file I/O >
function AppDir : String;
function ComposeFilePath(stDirs: array of String; cDelimiter: Char = '/'): String;
function ParseDirPath(stPath : String; stDirs : TStringList) : Integer;
function FileVersionToStr(FileName: String): String;
function CutFileExt(stFile: String): String;

function FileToStr(stFile: String): String;

function GetTokens(stText : String; Tokens : TStringList) : Integer; overload;
function GetTokens(stText : String; aTokens : TStringList; aSector : Char) : Integer; overload;


//---------------------------------------------------------------------< Time >

// this function uses 'MMSystem'
function GetMMTime: DWORD;
function GetSecNOneMilli( dtTime : TDateTime ) : string;
function GetSecNOneMilli2( dtTime : TDateTime ) : string;
function GetTimeByMMIndex(iMMIndex : Integer) : TDateTime;
function GetDayBetween( aNow , aThen : TDateTime ) : integer;
function GetMMIndex(dtValue : TDateTime) : Integer;
function GetRemainDayToSec( iDays : integer; dTime : double ) : Double;
function GetMSBetween( aNow , aThen : TDateTime ) : integer;
function IsSameTimeUnit( aTime, bTime : TDateTime; iDiv : integer ) : boolean;
function GetTimeStr( aNow : TDateTime; iMode : integer = 0 ) : string;

// -- Color Utils
procedure HSLToRGB(const Hue, Saturtion, Lightness : Double;
  var Red, Green, Blue : Byte); // HSL -> RGB
function EncodeRGB(const Red, Green, Blue : Byte) : TColor; //  RGB -> TColor

// -- Realtime ATM
function GetATM(const dClose : Double) : Double;

//------------------------------------------------------------------< Network >
function GetLocalIP( var iP : string) : String;
function GetLocalIP2 : String;

//-----------------------------------------------------------------< Controls >
  // TComboBox
procedure AddSymbolCombo(aSymbol : TSymbol; aCombo : TComboBox);
procedure AddAccountCombo(aObj   : TObject; aCombo : TComboBox);
procedure ClearComboBoxes(const Combos : array of TComboBox);
procedure SetComboIndex(aCombo : TComboBox; iIndex : Integer); overload;
procedure SetComboIndex(aCombo: TComboBox; aObj: TObject); overload;
function GetComboObject(aCombo : TComboBox) : TObject;
procedure ComboBox_AutoWidth(const theComboBox: TCombobox);
function GetMousePoint : TPoint;

  // TListView
function SaveListViewToCSV(aListView : TListView;
  stFile : String; aForm: TForm = nil) : Boolean;
procedure DefaultListViewDrawItem(ListView: TListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState;
  aSelectColor, aEvenColor, aOddColor: TColor);
procedure DefaultListViewDrawGridLines(ListView: TListView; ItemRect: TRect);
  // TStringGrid
function SaveStringGridToCSV(aGrid: TStringGrid; stFile: String;
  iColStart: Integer = 0; iRowStart: Integer = 0 ) : Boolean;
procedure DefaultGridDrawCell(Grid : TStringGrid; ACol, ARow: Integer;
                          Rect: TRect; State: TGridDrawState);

function InsertRow( aGrid : TStringGrid; aSymbol : TSymbol; aCol : integer ) : integer;

//---------------------------------------------------------------< conversion >
function StrToFrac(Value: String): Double;
function StrToDateMMDDYY(Value: String): TDateTime;
function IsZero(dZero : Double) : Boolean;
function IsPriceZero(dZero : Double) : Boolean;
function IntToStrComma(i:Integer) : String;

//-------------------------------------------------------------------< String >
function RegulateCode(stCode: String): String;    
function AcntToPacket( Value : string ) : string;
function PackettoAcnt( Value : string ) : string;
function GetPrecision( Value : string ) : integer; overload;
function GetPrecision( Value : double ) : integer; overload;


//------------------------------------------------------------------< Dialogs >
procedure ShowMessageLE(aForm: TForm; stMsg: String);
function MessageDlgLE(aForm: TForm; stMsg: String; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons): Integer;
function InputPass(const ACaption, APrompt: string; var Value: string): Boolean;
procedure ShowNotePad(  aHandle : HWND; stFileName : string );

//--------------------------------------------------------------------< draw >

procedure DrawRect(aCanvas : TCanvas; aRect: TRect; stText: String;
  aBkColor, aFontColor: TColor; aAlignment : TAlignment);

function TimeToStr( tTime: TDateTime; cDiv : Char = 'X' ): String;
procedure utPopupMenu(aPopupMenu:TPopupMenu; iValues : array of Integer);

//--------------------------------------------------------------------< Sound >

procedure FillSoundPlay( stSound : string );
function IfThenStr(AValue: Boolean; const ATrue,  AFalse: string): string;
function IfThenFloat( AValue : boolean ; const  ATrue, AFalse : double): double;
function IfThenBool( AValue : boolean ; const  ATrue, AFalse : boolean): boolean;
function ifThenColor( AValue : boolean ; const  ATrue, AFalse : TColor): TColor;
function BoolToChar(bBool : Boolean) : String;
function SideToStr( iSide : integer ) : string;

//--------------------------------------------------------------------< stringgrid >

procedure DeleteLine( aGrid : TStringGrid; iline: Integer);
procedure InsertLine( aGrid : TStringGrid; iline: Integer);
procedure InvalidateRow( aGrid : TStringGrid; iline : integer );

//--------------------------------------------------------< end >

function GetWeightAvgPrice( AskPrice, BidPrice : double; AskVol, BidVol : integer ) : double;
function GetWeightAvgPrice2( AskPrice, BidPrice : double; AskVol, BidVol : integer ) : double;
function Get5StepWeigthPrice( Asks, Bids : array of Double; AskVols, BidVols : array of integer ) : double;
function GetOrderPriceRound( Value : double; bAsk : boolean ) : double;


//-----------------------------------------------------------------<keyboard>
Procedure SetEnglishMode( handle : Thandle );

//-----------------------------------------------------------------<keyboard>
function ComparePrice( iPre: integer; dPrice1, dPrice2 : double ) : integer;
function GetMACAdress:String;
function GetSizeOfFile(const FilenName:string) : Longint;


implementation

uses
  CleAccounts, CleFunds
  ;

function GetTokens(stText : String; Tokens : TStringList) : Integer;
var
  i : Integer;
  stToken : String;
begin
  Tokens.Clear;
  stToken := '';

  for i:=1 to Length(stText) do
    case stText[i] of
      ',', #10 :
        begin
          Tokens.Add(stToken);
          stToken := '';
        end;
      else
        stToken := stToken + stText[i];
    end;

  if Length(stToken) <> 0 then
    Tokens.Add(stToken);

  Result := Tokens.Count;
end;

function GetTokens(stText : String; aTokens : TStringList; aSector : Char) : Integer;
var
  i, iLen : Integer;
  stToken : String;
begin
  //-- init
  Result := 0;
  aTokens.Clear;
  //--
  iLen := Length(stText);
  if iLen = 0 then Exit;
  // start parsing
  stToken := '';
  for i:= 1 to iLen do
    if stText[i] = aSector then
    begin
      aTokens.Add(stToken);
      stToken :=  '';
    end else
      stToken := stToken + stText[i];
    
  if stToken <> '' then
    aTokens.Add(stToken);
  //--
  Result := aTokens.Count;
end;


//--------------------------------------------------------< file I/O >

function AppDir : String;
begin
  Result := ExtractFileDir(Application.ExeName);
end;

function ComposeFilePath(stDirs: array of String; cDelimiter: Char = '/'): String;
var
  i, iCount: Integer;
begin
  Result := '';

    // make path

  iCount := 0;

  for i := Low(stDirs) to High(stDirs) do
  begin
    if Length(stDirs[i]) = 0 then Continue;

    if iCount > 0 then
      Result := Result + cDelimiter + stDirs[i]
    else
      Result := Result + stDirs[i];

    Inc(iCount);
  end;

    // make sure only one type of delimter is used
  if cDelimiter <> '\' then
    Result := StringReplace(Result, '\', cDelimiter, [rfReplaceAll]);
  if cDelimiter <> '/' then
    Result := StringReplace(Result, '/', cDelimiter, [rfReplaceAll]);
    
    // remove double delimiters
  Result := StringReplace(Result, cDelimiter + cDelimiter, cDelimiter, [rfReplaceAll]);
end;

function ParseDirPath(stPath : String; stDirs : TStringList) : Integer;
var
  i : Integer;
  stDir : String;
begin
  stDir := '';

  for i := 1 to Length(stPath) do
    case stPath[i] of
      '/','\' :
          if Length(stDir) > 0 then
          begin
            stDirs.Add(stDir);
            stDir := '';
          end;
      else
        stDir := stDir + stPath[i];
    end;

  if Length(stDir) > 0 then
    stDirs.Add(stDir);

  Result := stDirs.Count;
end;

function FileVersionToStr(FileName: String): String;
var
  Size, Size2: DWord;
  pT, pT2: Pointer;
begin
  Result := '';
  Size := GetFileVersionInfoSize(PChar(FileName), Size2);
  if Size > 0 then
  begin
    GetMem(Pt, Size);
    try
      GetFileVersionInfo(PChar(FileName), 0, Size, Pt);
      VerQueryValue(Pt, '\', Pt2, Size2);
      with TVSFixedFileInfo(Pt2^) do
      begin
        Result := IntToStr(HiWord(dwFileVersionMS)) + '.' +//major version
                  IntToStr(LoWord(dwFileVersionMS)) + '.' +//minor version
                  IntToStr(HiWord(dwFileVersionLS)) + '.' +//release
                  IntToStr(LoWord(dwFileVersionLS));       //build
      end;
    finally
      FreeMem(Pt);
    end;//try
  end;//if

end;

function CutFileExt(stFile: String): String;
var
  iPos: Integer;
begin
  iPos := Pos('.', stFile);
  if iPos >= 1 then
    Result := Copy(stFile,1,iPos-1)
  else
    Result := stFile;
end;

function FileToStr(stFile: String): String;
var
  aList: TStringList;
begin
  Result := '';

  if not FileExists(stFile) then Exit;

  try
    aList := TStringList.Create;
    
    aList.LoadFromFile(stFile);
    Result := aList.Text;
  finally
    aList.Free;
  end;
end;

//---------------------------------------------------------------------< Time >

// uses 'MMSystem'
// This function is the wrapper for 'timeGetTime' Windows API.
// The resolution is said to be 5 ms or more. But I tried 1 ms here.
//   check 'initialization' and 'finalization' for resoluiton setting
function GetMMTime: DWORD;
begin
  Result := timeGetTime;
end;

function GetSecNOneMilli( dtTime : TDateTime ) : string;
var
  ss , sz : string;
begin
  sz := FormatDateTime( 'zzz', dtTime );
  ss := FormatDateTime( 'ss', dtTime );
  Result := ss + '.' + sz[1];
end;

function GetSecNOneMilli2( dtTime : TDateTime ) : string;
var
  ss , sz : string;
begin
  sz := FormatDateTime( 'ss', dtTime );
  ss := FormatDateTime( 'nn', dtTime );
  Result := ss + '.' + sz;
end;

{$REGION ' Network '}
//------------------------------------------------------------------< Network >

function GetLocalIP( var iP : string ): String;
type 
   TaPInAddr = array [0..255] of PInAddr; 
   PaPInAddr = ^TaPInAddr;
var
  i,wVersionRequested,
  a,b,c,d : Word;
  aWSAData : TWSAData;
  aHostEnt : PHostEnt;
  stIP, stLocalHost : String;
  pptr : PaPInAddr;


begin
  //--
  Result := '';
  //--
  wVersionRequested := MAKEWORD(2,0); // will use WinSock version 2
  if WSAStartup(wVersionRequested, aWSAData) <> 0 then
  begin
    // tell the user that we couldn't find a usable WinSock DLL
    Exit;
  end;
  //
  try
    // check version support
    if (LOBYTE(aWSAData.wVersion) <> 2) or
       (HIBYTE(aWSAData.wVersion) <> 0) then Exit;
    //-- get ip
    SetLength(stLocalHost, 255);
    if GetHostName(PChar(stLocalHost), 255) <> 0 then Exit;
    SetLength(stLocalHost, StrLen(PChar(stLocalHost)));
    aHostEnt := GetHostByName(PChar(stLocalHost));
    if aHostEnt = nil then
    begin
      Exit;
    end;

    pptr := PaPInAddr(aHostEnt^.h_addr_list);
    I := 0;
    a := 0; b:=1; c:=2; d:=3;

    while pptr^[I] <> nil do begin
      {
      Result := StrPas(inet_ntoa(pptr^[I]^));
      ip := Format('%.3d%.3d%.3d%.3d', [ Byte(aHostEnt^.h_addr^[a]),Byte(aHostEnt^.h_addr^[b]),
                                        Byte(aHostEnt^.h_addr^[c]),Byte(aHostEnt^.h_addr^[d])]);
      }

      stIP := Format('%.3d', [ Byte(aHostEnt^.h_addr^[a])]);
      {
      if (stIP = '172') or (stIP = '010') then
        ip := Format('%.3d%.3d%.3d%.3d', [ Byte(aHostEnt^.h_addr^[a]),Byte(aHostEnt^.h_addr^[b]),
                                        Byte(aHostEnt^.h_addr^[c]),Byte(aHostEnt^.h_addr^[d])])

      //else if stIP = '192' then
      }
      if i = 0 then
        Result := StrPas(inet_ntoa(pptr^[I]^))
      else if i= 1 then
        ip := Format('%.3d%.3d%.3d%.3d', [ Byte(aHostEnt^.h_addr^[a]),Byte(aHostEnt^.h_addr^[b]),
                                        Byte(aHostEnt^.h_addr^[c]),Byte(aHostEnt^.h_addr^[d])]);
        //iP  := StrPas(inet_ntoa(pptr^[I]^));

      inc( a, 4);
      inc( b, 4);
      inc( c, 4);
      inc( d, 4);

      Inc(I);
    end;
    {
    with aHostEnt^ do  begin
      Result := Format('%d.%d.%d.%d', [ Byte(h_addr^[0]),Byte(h_addr^[1]),
                                        Byte(h_addr^[2]),Byte(h_addr^[3])]);
      ip := Format('%.3d%.3d%.3d%.3d', [ Byte(h_addr^[0]),Byte(h_addr^[1]),
                                        Byte(h_addr^[2]),Byte(h_addr^[3])]);
    end;
    }
  finally
    WSACleanup;
  end;
end;


function GetLocalIP2 : String;
var
  wVersionRequested : Word;
  aWSAData : TWSAData;
  aHostEnt : PHostEnt;
  stLocalHost : String;
begin
  //--
  Result := '';

  //
  try
    // check version support
    if (LOBYTE(aWSAData.wVersion) <> 2) or
       (HIBYTE(aWSAData.wVersion) <> 0) then Exit;
    //-- get ip
    SetLength(stLocalHost, 255);
    if GetHostName(PChar(stLocalHost), 255) <> 0 then Exit;
    SetLength(stLocalHost, StrLen(PChar(stLocalHost)));
    aHostEnt := GetHostByName(PChar(stLocalHost));
    if aHostEnt = nil then Exit;
    with aHostEnt^ do
      Result := Format('%.3d%.3d%.3d%.3d', [ Byte(h_addr^[0]),Byte(h_addr^[1]),
                                        Byte(h_addr^[2]),Byte(h_addr^[3])]);
  finally
    WSACleanup;
  end;
end;
{$ENDREGION}

//--------------------------------------------------------< Controls >

// combo box

procedure AddSymbolCombo(aSymbol : TSymbol; aCombo : TComboBox);
var
  iP : Integer;
begin
  if (aSymbol = nil) or (aCombo = nil) then Exit;
  //
  iP := aCombo.Items.IndexOfObject(aSymbol);
  if iP > 0 then
    aCombo.Items.Move(iP, 0)
  else if iP < 0 then
    aCombo.Items.InsertObject(0, aSymbol.ShortCode, aSymbol);
  //
  aCombo.ItemIndex := 0;
end;

procedure AddAccountCombo(aObj   : TObject; aCombo : TComboBox);
var
  stName  : string;
  iP : integer;
begin
  if (aObj = nil) or (aCombo = nil) then Exit;

  iP := aCombo.Items.IndexOfObject(aObj);
  if iP > 0 then
    aCombo.Items.Move(iP, 0)
  else if iP < 0 then
  begin
    if aObj is TFund then
      stName := TFund( aObj ).Name
    else
      stName := TAccount( aObj ).Code + ' ' + TAccount( aObj ).Name;
    aCombo.Items.InsertObject(0, stName, aObj);
  end;
  //
  aCombo.ItemIndex := 0;
end;

procedure ClearComboBoxes(const Combos : array of TComboBox);
var
  i : Integer;
begin
  for i:=Low(Combos) to High(Combos) do
    Combos[i].Items.Clear;
end;

procedure SetComboIndex(aCombo : TComboBox; iIndex : Integer);
begin
  if (iIndex >= 0) and (iIndex <= aCombo.Items.Count-1) then
    aCombo.ItemIndex := iIndex;
end;

procedure SetComboIndex(aCombo: TComboBox; aObj: TObject);
var
  iPos: Integer;
begin
  iPos := aCombo.Items.IndexOfObject(aObj);
  if iPos < 0 then
    aCombo.ItemIndex := -1
  else
    aCombo.ItemIndex := iPos;
end;

function GetComboObject(aCombo : TComboBox) : TObject;
begin
  if aCombo.ItemIndex >= 0 then
    Result := aCombo.Items.Objects[aCombo.ItemIndex]
  else
    Result := nil;
end;

procedure ComboBox_AutoWidth(const theComboBox: TCombobox);
const
  HORIZONTAL_PADDING = 4;
var
  itemsFullWidth: integer;
  idx: integer;
  itemWidth: integer;
begin

  itemsFullWidth := 0;
  for idx := 0 to -1 + theComboBox.Items.Count do
  begin
    itemWidth := theComboBox.Canvas.TextWidth(theComboBox.Items[idx]);
    Inc(itemWidth, 2 * HORIZONTAL_PADDING);
    if (itemWidth > itemsFullWidth) then itemsFullWidth := itemWidth;
  end;

  if (itemsFullWidth > theComboBox.Width) then
  begin

    if theComboBox.DropDownCount < theComboBox.Items.Count then
      itemsFullWidth := itemsFullWidth + GetSystemMetrics(SM_CXVSCROLL);

    SendMessage(theComboBox.Handle, CB_SETDROPPEDWIDTH, itemsFullWidth, 0);
  end;
end;

function GetMousePoint : TPoint;
begin
  GetCursorPos(Result);
end;


function InsertRow( aGrid : TStringGrid; aSymbol : TSymbol; aCol : integer ) : integer;
var
  pSymbol : TSymbol;
  j : integer;
  bOK : boolean;
begin
  Result := -1;

  with aGrid do
    for j := 1 to RowCount - 1 do
    begin
      bOK := false;
      if j = RowCount-1 then
        bOK := true
      else begin
        pSymbol := TSymbol( Objects[aCol, j] );
        if pSymbol <> nil then
        case aSymbol.ShortCode[1] of
          '1' : if pSymbol.No > aSymbol.No then bOK := true;
          '2' : case pSymbol.ShortCode[1] of
                  '1' : if pSymbol.No > aSymbol.No then bOK := true;
                  '2' : if pSymbol.No < aSymbol.No then bOK := true;
                  '3' : bOK := true;
                end;
          '3' : case pSymbol.ShortCode[1] of
                  '1','2' : if pSymbol.No > aSymbol.No then bOK := true;
                  '3' : if pSymbol.No < aSymbol.No then bOK := true;
                end;
        end;
      end;

      if bOK  then
      begin
        Result := j;
        break;
      end;
    end;
end;

//=====================[ TListView ]==========================//

function SaveListViewToCSV(aListView: TListView; stFile: String;
  aForm: TForm) : Boolean;
var
  F: TextFile;
  i: Integer;
  aDlg: TSaveDialog;
begin
  Result := False;

  if aListView = nil then Exit;

  aDlg := TSaveDialog.Create(aForm);
  aDlg.Filter := 'CSV File(*.csv)|*.csv';
  aDlg.FileName := stFile;

  if aDlg.Execute then
  try
      // open file
    AssignFile(F, aDlg.FileName);
    ReWrite(F);

      // column headers
    for i := 0 to aListView.Columns.Count - 1 do
    begin
      if i > 0 then
        Write(F, ',');
      Write(F, aListView.Columns[i].Caption);
    end;
    Writeln(F, '');

      // data
    for i:=0 to aListView.Items.Count-1 do
      WriteLn(F, aListView.Items[i].Caption + ',' +
              aListView.Items[i].SubItems.CommaText);
      // close
    CloseFile(F);

    Result := True;
  finally
    aDlg.Free;
  end;
end;

procedure DefaultListViewDrawItem(ListView: TListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState;
  aSelectColor, aEvenColor, aOddColor: TColor);
var
  i, iX, iY, iLeft : Integer;
  aSize : TSize;
begin
  //
  Rect.Bottom := Rect.Bottom-1;
  //
  with ListView.Canvas do
  begin
    //-- color
    if (odSelected in State) {or (odFocused in State)} then
    begin
      Brush.Color := aSelectColor;
      Font.Color := clBlack;
    end else
    begin
      Font.Color := clBlack;
      if Item.Index mod 2 = 1 then
        Brush.Color := aEvenColor
      else
        Brush.Color := aOddColor;
    end;
      //-- background
    FillRect(Rect);
      // grid lines
    DefaultListViewDrawGridLines(ListView, Rect);

      //-- icon
    aSize := TextExtent('9');
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    if (Item.ImageIndex >=0) and (ListView.SmallImages <> nil) then
    begin
      // aListView.SmallImages.BkColor := Brush.Color;
      ListView.SmallImages.Draw(ListView.Canvas, Rect.Left+1, Rect.Top,
                              Item.ImageIndex);
    end;

      //-- caption
    if Item.Caption <> '' then
      if ListView.SmallImages = nil then
        TextRect(
            Classes.Rect(0,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + 5, iY, Item.Caption)
      else
        TextRect(
            Classes.Rect(Rect.Left + ListView.SmallImages.Width,
              Rect.Top, ListView_GetColumnWidth(ListView.Handle,0), Rect.Bottom),
            Rect.Left + ListView.SmallImages.Width + 5, iY, Item.Caption);
    //-- subitems
    iLeft := Rect.Left;
    for i:=0 to Item.SubItems.Count-1 do
    begin
      if i+1 >= ListView.Columns.Count then Break;
      iLeft := iLeft + ListView_GetColumnWidth(ListView.Handle,i);

      if Item.SubItems[i] = '' then Continue;
      aSize := TextExtent(Item.SubItems[i]);

      case ListView.Columns[i+1].Alignment of
        taLeftJustify :  iX := iLeft + 5;
        taCenter :       iX := iLeft +
             (ListView_GetColumnWidth(ListView.Handle,i+1)-aSize.cx) div 2;
        taRightJustify : iX := iLeft +
              ListView_GetColumnWidth(ListView.Handle,i+1) - 5 - aSize.cx;
        else iX := iLeft + 2; // redundant coding
      end;
      TextRect(
          Classes.Rect(iLeft+1, Rect.Top,
             iLeft + ListView_GetColumnWidth(ListView.Handle,i+1), Rect.Bottom),
          iX, iY, Item.SubItems[i]);
    end;
  end;
end;

procedure DefaultListViewDrawGridLines(ListView: TListView; ItemRect: TRect);
var
  i, iRight : Integer;
begin
  //
  with ListView.Canvas do
  begin
    iRight := ListView.ClientRect.Left;
    Pen.Color := clLtGray;
    Pen.Width := 1;
    
    for i:=0 to ListView.Columns.Count-1 do
    begin
      iRight := iRight + ListView_GetColumnWidth(ListView.Handle,i);
      MoveTo(iRight, ItemRect.Top);
      LineTo(iRight, ItemRect.Bottom);
    end;
  end;
end;

//-------------------------------------------------------------< TStringGrid >

function SaveStringGridToCSV(aGrid : TStringGrid; stFile : String;
  iColStart, iRowStart: Integer) : Boolean;
var
  F: TextFile;
  iCol, iRow: Integer;
begin
  Result := False;

  if aGrid = nil then Exit;

    // open file
  AssignFile(F, stFile);
  try
    ReWrite(F);
  except
    Exit;
  end;

    // save to file
  try
    for iRow := iRowStart to aGrid.RowCount - 1 do
    begin
      for iCol := iColStart to aGrid.ColCount - 1 do
      begin
         if iCol = iColStart then
           Write(F, aGrid.Cells[iCol, iRow])
         else
           Write(F, ',' + aGrid.Cells[iCol, iRow]);
      end;
      Writeln(F, '');
    end;

    Result := True;
  finally
    CloseFile(F);
  end;
end;


procedure DefaultGridDrawCell(Grid : TStringGrid; ACol, ARow: Integer;
                          Rect: TRect; State: TGridDrawState);
var
  aAlignment : TAlignment;
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
begin
  with Grid.Canvas do
  begin
    Font.Name := Grid.Font.Name;
    Font.Size := Grid.Font.Size;
    //
    stText := Grid.Cells[ACol, ARow];
    if gdFixed in State then
    begin
      Brush.Color := clLtGray;
      Font.Color := clBlack;
      aAlignment := taLeftJustify;
    end else
    begin
      if stText = '' then
       Brush.Color :=$EEEEEE
      else
        Brush.Color := clWhite;
      Font.Color := clBlack;
      aAlignment := taRightJustify;
    end;
    //-- background
    FillRect(Rect);
    //-- text
    if stText = '' then Exit;
    //-- calc position
    aSize := TextExtent(stText);
    iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    //-- put text
    case aAlignment of
      taLeftJustify :  iX := Rect.Left + 2;
      taCenter :       iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
      taRightJustify : iX := Rect.Left + Rect.Right-Rect.Left - 2 - aSize.cx;
    end;
    TextRect(Rect, iX, iY, stText);
  end;
end;



//---------------------------------------------------------------< conversion >

function StrToFrac(Value: String): Double;
var
  stLeading, stFraction,
  stNumerator, stDenominator : String;

  iPos, iPos2, iDenominator: Integer;
  dFractionFactor: Double;
begin
  Value := Trim(Value);

  try
    iPos := Pos(' ', Value);
    iPos2 := Pos('-', Value);
      // separate leading float and fraction
      // format: 10.30 1/16
    if iPos > 0 then
    begin
      stLeading := Trim(Copy(Value, 1, iPos-1));
      stFraction := Trim(Copy(Value, iPos+1, Length(Value)-iPos));
      iPos := Pos('.', stLeading);
      if iPos > 0 then
        dFractionFactor := Power(10, -(Length(stLeading)-iPos))
      else
        dFractionFactor := 1.0;
    end else
      // format: 118-08
    if (iPos2 > 0) and (iPos2 > 1) then
    begin
      stLeading := Trim(Copy(Value, 1, iPos2-1));
      stFraction := Trim(Copy(Value, iPos2+1, Length(Value)-iPos2)) + '/32';;
      iPos := Pos('.', stLeading);
      if iPos > 0 then
        dFractionFactor := Power(10, -(Length(stLeading)-iPos))
      else
        dFractionFactor := 1.0;
    end else
      // format: 1/16
    if Pos('/', Value) > 0 then
    begin
      stLeading := '';
      stFraction := Value;
      dFractionFactor := 1.0;
    end else
      // format: 10.30
    begin
      stLeading := Value;
      stFraction := '';
      dFractionFactor := 1.0;
    end;
      // interpret leading float
    if Length(stLeading) > 0 then
      Result := StrToFloatDef(stLeading, 0)
    else
      Result := 0.0;
      // interpret fraction
    if Length(stFraction) > 0 then
    begin
      iPos := Pos('/', stFraction);
      if iPos > 0 then
      begin
        stNumerator := Trim(Copy(stFraction, 1, iPos-1));
        stDenominator := Trim(Copy(stFraction, iPos+1, Length(stFraction)-iPos));
        iDenominator := StrToIntDef(stDenominator, 0);
        if iDenominator <> 0 then
          Result := Result + dFractionFactor * StrToIntDef(stNumerator, 0)/iDenominator;
      end;
    end;
  except
    Result := 0.0;
  end;
end;

function StrToDateMMDDYY(Value: String): TDateTime;
var
  stYear, stMonth, stDay: String;
  iPos: Integer;
begin
  Result := 0.0;

    // get month
  iPos := Pos('/', Value);
  if iPos <= 0 then Exit;

  stMonth := Copy(Value, 1, iPos-1);
  Value := Copy(Value, iPos+1, Length(Value)-iPos);

    // get day
  iPos := Pos('/', Value);
  if iPos <= 0 then Exit;
  stDay := Copy(Value, 1, iPos-1);
  stYear := Copy(Value, iPos+1, Length(Value)-iPos);

    // convert
  Result := EncodeDate(StrToIntDef(stYear, 0) + 2000,
                       StrToIntDef(stMonth, 1),
                       StrToIntDef(stDay, 1));
end;

//------------------------------------------------------------------< String >

function RegulateCode(stCode: String): String;
begin
  Result := UpperCase(Trim(stCode));
    // change double spaces into single spaces
  Result := (StringReplace(Result,'  ',' ',[rfReplaceAll]));
end;

//------------------------------------------------------------------< Dialog >

procedure ShowMessageLE(aForm: TForm; stMsg: String);
var
  aDlg: TForm;
begin
  aDlg := CreateMessageDialog(stMsg, mtInformation, [mbOK]);
  try
    if aForm <> nil then
    begin
      aDlg.Position := poOwnerFormCenter;
    end else
      aDlg.Position := poScreenCenter;
    aDlg.ShowModal;
  finally
    aDlg.Free;
  end;
end;

function MessageDlgLE(aForm: TForm; stMsg: String; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons): Integer;
var
  aDlg: TForm;
begin
  aDlg := CreateMessageDialog(stMsg, DlgType, Buttons);
  try
    if aForm <> nil then
    begin
      aDlg.Position := poOwnerFormCenter;
    end else
      aDlg.Position := poScreenCenter;
    Result := aDlg.ShowModal;
  finally
    aDlg.Free;
  end;
end;


function InputPass(const ACaption, APrompt: string; var Value: string): Boolean;

var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;

  function GetAveCharSize(Canvas: TCanvas): TPoint;
  var
    I: Integer;
    Buffer: array[0..51] of Char;
  begin
    for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
    for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
    GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
    Result.X := Result.X div 52;
  end;

  const

  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Cancel';
  mrOk       = idOk;
  mrCancel   = idCancel;

begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      with Prompt do
      begin
        Parent := Form;
        Caption := APrompt;
        Left := MulDiv(8, DialogUnits.X, 4);
        Top := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := True;
      end;
      Edit := TEdit.Create(Form);
      with Edit do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := Prompt.Top + Prompt.Height + 5;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 255;
        Text := Value;
        PasswordChar := '*';
        SelectAll;
      end;
      ButtonTop := Edit.Top + Edit.Height + 15;
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := SMsgDlgOK;
        ModalResult := mrOk;
        Default := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := SMsgDlgCancel;
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), Edit.Top + Edit.Height + 15,
          ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 13;          
      end;
      if ShowModal = mrOk then
      begin
        Value := Edit.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;

end;


//--------------------------------------------------------------------< draw >

//
// draw text in a rect
//
procedure DrawRect(aCanvas : TCanvas; aRect: TRect; stText: String;
  aBkColor, aFontColor: TColor; aAlignment : TAlignment);
var
  iX, iY : Integer;
  aSize : TSize;
begin
  if aCanvas = nil then Exit;
  
    // set color
  aCanvas.Brush.Color := aBkColor;
  aCanvas.Font.Color := aFontColor;

    // draw background
  aCanvas.FillRect(aRect);
  if stText = '' then Exit;

   // calculate position
  aSize := aCanvas.TextExtent(stText);
  iX := aRect.Left;
  iY := aRect.Top + (aRect.Bottom-aRect.Top-aSize.cy) div 2 + 1;
  case aAlignment of
    taLeftJustify :  iX := aRect.Left + 2;
    taCenter :       iX := aRect.Left + (aRect.Right-aRect.Left-aSize.cx) div 2;
    taRightJustify : iX := aRect.Left + aRect.Right-aRect.Left-aSize.cx - 2;
  end;

    // draw text
  aCanvas.TextRect(aRect, iX, iY, stText);
end;

function TimeToStr( tTime: TDateTime; cDiv : Char ): String;
var
  HH, MM, SS, MS, tHH: Word;
begin

  DecodeTime( tTime, HH, MM, SS, MS );
  if HH = 0 then
    HH := 9
  else begin
    tHH := HH + 9;
    if tHH > 24 then
      HH := tHH - 24;
  end;

  if cDiv = 'X' then  
    Result := Format( '%2s:%2s:%2s', [FormatFloat('00', HH),
  	  FormatFloat('00', MM), FormatFloat('00', SS)] )
  else if cDiv = 'H' then
    Result := Format( '%2s', [FormatFloat('00', HH)])
  else if cDiv = 'M' then
    Result := Format( '%2s', [FormatFloat('00', MM)])
  else if cDiv = 'S' then
    Result := Format( '%2s', [FormatFloat('00', SS)]);

end;

procedure utPopupMenu(aPopupMenu:TPopupMenu; iValues : array of Integer);
var
  i : Integer;
begin
  if aPopupMenu = nil then Exit;

  for i:=0 to aPopupMenu.Items.Count-1 do
    aPopupMenu.Items[i].Visible := False;

  for i:=0 to High(iValues) do
    aPopupMenu.Items[iValues[i]].Visible := True;
end;


procedure FillSoundPlay( stSound : string );
begin
  if stSound = '' then
    Exit;

  sndPlaySound( PChar( stSound), snd_Async);
end;


function IfThenStr(AValue: Boolean; const ATrue,
  AFalse: string): string;
begin
  if AValue then
    result := ATrue
  else
    result := AFalse;
end;

function SideToStr( iSide : integer ) : string;
begin
  if iSide = 0 then
    Result := ''
  else Result := IfThenStr( iSide > 0, '????','????');
end;

function IfThenFloat( AValue : boolean ; const  ATrue, AFalse : double): double;
begin
  if AValue then
    result := ATrue
  else
    result := AFalse;
end;

function ifThenColor( AValue : boolean ; const  ATrue, AFalse : TColor): TColor;
begin
  if AValue then
    result := ATrue
  else
    result := AFalse;
end;

function IfThenBool( AValue : boolean ; const  ATrue, AFalse : boolean): boolean;
begin
  if AValue then
    result := ATrue
  else
    result := AFalse;
end;

function BoolToChar(bBool : Boolean) : String;
begin
  if bBool then Result := '1' else Result := '0';
end;


procedure DeleteLine( aGrid : TStringGrid; iline: Integer);
begin
  with aGrid do begin
    TmpGrid(aGrid).DeleteRow(iline);
    Rows[rowcount].Clear;
  end;
end;
procedure InsertLine( aGrid : TStringGrid; iline: Integer);
begin
  with aGrid do begin
    RowCount := Succ( RowCount );
    TmpGrid( aGrid ).MoveRow( ( RowCount - 1 ), iline );
    Rows[iline].Clear;
  end;
end;

procedure InvalidateRow( aGrid : TStringGrid; iline : integer );
begin
  TmpGrid( aGrid ).InvalidateRow( iline );
end;


function GetWeightAvgPrice( AskPrice, BidPrice : double; AskVol, BidVol : integer ) : double;
var
  dGap : double;
  const PRICE_EPSILON = 0.001;
begin
  if AskVol = 0 then
    AskVol := 1;

  if BidVol = 0 then
    BidVol := 1;


  dGap  := AskPrice - BidPrice;
  if abs( dGap ) < 0.05 + PRICE_EPSILON then
    Result := dGap * BidVol / ( AskVol + BidVol ) + BidPrice
  else
    Result := (AskPrice + BidPrice ) / 2;
end;

function GetWeightAvgPrice2( AskPrice, BidPrice : double; AskVol, BidVol : integer ) : double;
var
  dGap : double;
  const PRICE_EPSILON = 0.001;
begin
  Result := 0;
  if AskVol = 0 then
    AskVol := 1;

  if BidVol = 0 then
    BidVol := 1;

  if ( AskVol + BidVol )  = 0 then
    Exit;

  dGap  := AskPrice - BidPrice;
  Result := dGap * BidVol / ( AskVol + BidVol ) + BidPrice;
end;

function Get5StepWeigthPrice( Asks, Bids : array of Double;
      AskVols, BidVols : array of integer ) : double;
var
  i, j : integer;
  dMo, dJa : double;
begin
  Result := 0;

  dMo := 0; dJa := 0;
  for i := 0 to High( Asks ) do
  begin
    dMo := dMo + (Asks[i] * BidVols[i]) + (Bids[i] * AskVols[i]);
    dJa := dJa + (AskVols[i] + BidVols[i]);
  end;

  if dJa <= 0 then
    Exit;

  Result := dMo / dJa;
end;

function GetMMIndex(dtValue : TDateTime) : Integer;
var
  wHH, wMM, wSS, wZZ : Word;
begin
  DecodeTime(dtValue, wHH, wMM, wSS, wZZ);
  Result := (wHH-9)*60 + wMM;
end;

function GetTimeByMMIndex(iMMIndex : Integer) : TDateTime;
var
  wHH, wMM, wSS, wZZ : Word;
begin
  wHH := (iMMIndex div 60) + 9;
  wMM := iMMIndex mod 60;
  wSS := 0;
  wZZ := 0;

  Result := EncodeTime(wHH, wMM, wSS, wZZ);
end;

function GetRemainDayToSec( iDays : integer; dTime : double ) : Double;
var
  H, M, S, MS : Word;
begin
{
  DecodeTime( dTime, H, M, S, MS );
  Result :=
    (( iDays * (DayToSec/MinToSec) ) +
    ( H * (HourToSec/MinToSec) ) +
    ( M * (MinToSec/MinToSec) ) +
    S )
    / (Denominator/MinToSec);
  }
  DecodeTime( dTime, H, M, S, MS );
  Result :=
    (( iDays * (DayToSec) ) +
    ( H * (HourToSec) ) +
    ( M * (MinToSec) ) +
    S )
    / (Denominator);
end;

function GetMSBetween( aNow , aThen : TDateTime ) : integer;
begin
  Result := MilliSecondsBetween( aNow, aThen );
end;

function GetDayBetween( aNow , aThen : TDateTime ) : integer;
begin
  Result := DaysBetween( aNow, aThen );
end;


function IsSameTimeUnit( aTime, bTime : TDateTime; iDiv : integer ) : boolean;
var
  iGap, iTo, iFrom, iSec, iSec2: integer;
begin

  // iDiv
  // 0 : 1 Min,  1 : 30 Sec,  2 : 20 Sec,  3 : 10 Sec

  iSec  := SecondOf( aTime );
  iSec2 := SecondOf( bTime );

  case iDiv of
    0 :
      begin
        if (HourOf( aTime )  = HourOf( bTime )) and
        (MinuteOf( aTime ) = MinuteOf( bTime )) then
          Result := true
        else
          Result := false;
      end;
    1 :
      begin
        if ((iSec2 >= 0) and ( iSec2 < 30 )) and
          (( iSec >= 0 ) and ( iSec < 30 )) then
          Result := true
        else if((iSec2 >= 30 ) and (iSec2 <= 59) ) and
          (( iSec >= 30 ) and (iSec2 <= 59)) then
          Result := true
        else
          Result := false;
      end;
    2 :
      begin
        if ((iSec2 >= 0) and ( iSec2 < 20 )) and
          (( iSec >= 0 ) and ( iSec < 20 )) then
          Result := true
        else if((iSec2 >= 20) and ( iSec2 < 40 )) and
          (( iSec >= 20 ) and ( iSec < 40 )) then
          Result := true
        else if(( iSec2 >= 40) and ( iSec2 <= 59) )  and
          (( iSec >= 40 ) and ( iSec <= 59) )  then
          Result := true
        else
          Result := false;
      end;
    3 :
      begin
        if ((iSec2 >= 0) and ( iSec2 < 10 )) and
          (( iSec >= 0 ) and ( iSec < 10 )) then
          Result := true
        else if((iSec2 >= 10) and ( iSec2 < 20 )) and
          (( iSec >= 10 ) and ( iSec < 20 )) then
          Result := true
        else if((iSec2 >= 20) and ( iSec2 < 30 )) and
          (( iSec >= 20 ) and ( iSec < 30 )) then
          Result := true
        else if((iSec2 >= 30) and ( iSec2 < 40 )) and
          (( iSec >= 30 ) and ( iSec < 40 )) then
          Result := true
        else if((iSec2 >= 40) and ( iSec2 < 50 )) and
          (( iSec >= 40 ) and ( iSec < 50 )) then
          Result := true
        else if( (iSec2 >= 50) and ( iSec2 <= 59))  and
          ((iSec >= 50)  and ( iSec <= 59 ))  then
          Result := true
        else
          Result := false;
      end;
  end;

  result := false;
end;

function GetTimeStr(  aNow : TDateTime; iMode : integer ) : string;
begin
  case iMode of
    0 : Result := FormatDateTime( 'hh:nn:ss.zzz', aNow );
    1 : Result := FormatDateTime( 'hh:nn:ss', aNow );
    2 : Result := FormatDateTime( 'hhnnsszzz', aNow );
    3 : Result := FormatDateTime( 'hhnnss', aNow );
  end;

end;

function IsPriceZero(dZero : Double) : Boolean;
begin
  dZero := Abs(dZero);
  Result := dZero < PRICE_EPSILON;
end;

function IsZero(dZero : Double) : Boolean;
begin
  dZero := Abs(dZero);
  Result := dZero < EPSILON;
end;

function IntToStrComma(i:Integer) : String;
begin
  Result := Format('%.0n',[i*1.0]);
end;

function AcntToPacket( Value : string ) : string;
begin
  if Copy( Value, 1, 3) = '999' then
    Result := '000000'+ Copy(Value, 4, Length(Value));
end;

function PackettoAcnt( Value : string ) : string;
begin
  Result := '999' + Copy(Value, 7, Length(Value));
end;


function GetPrecision( Value : string ) : integer;
var
  i : integer;
begin
  i :=  Pos('.', Value );
  if i = 0 then
    Result := 0
  else
    Result := Length( Value ) - i;
end;

function GetPrecision( Value : double ) : integer;
var
  iLen, i, j : integer;
  s : string;
begin
  // ?????? ???? 10???? ???? ???? ???????
  j := 0;
  s := Format('%.10f', [ Value ] );
  iLen  := Length( s );
  // ?????????? 0 ?? ???? ???????? ??????.
  for I := iLen downto 0 do
    if s[i] <> '0' then
    begin
      if s[i] = '.' then
        j := 0
      else
        // ???????? ?????? ????..
        j := i-2;
      Break;
    end;
  Result := Max(0, j);
end;

procedure ShowNotePad( aHandle : HWND; stFileName : string );
begin
  ShellExecute(aHandle, nil, 'notepad',
                 PChar(stFileName), nil, SW_SHOWNORMAL);
end;

function GetOrderPriceRound( Value : double; bAsk : boolean ) : double;
var
  stTmp : string;
  iLen  : integer;
begin
  // bAsc
  stTmp := Format('%.0f', [ Value * 100 ] );
  iLen  := Length( stTmp );

  if bAsk then

    case stTmp[5] of
      '3', '4', '5', '6', '7' :
      begin
        stTmp[5] := '5';
        Result := StrToFloatDef( stTmp , 0 ) / 100;
      end;
      else
        Result := RoundTo( Value, -1 );
    end
  else
    case stTmp[5] of
      '8', '9', '5', '6', '7' :
      begin
        stTmp[5] := '5';
        Result := StrToFloatDef( stTmp , 0 ) / 100;
      end;
      else
        Result := RoundTo( Value, -1 );
    end

end;

procedure HSLToRGB(const Hue, Saturtion, Lightness : Double;
  var Red, Green, Blue : Byte);

  function HueToRGB(v1, v2, vH : Double) : Double;
  begin
    if vH < 0 then vH := vH + 1;
    if vH > 1 then vH := vH - 1;

    if ((6*vH) < 1) then
      Result :=(v1 + (v2 - v1) * 6 * vH)
    else
    if ((2*vH) < 1) then
      Result := v2
    else
    if ((3*vH) < 2) then
      Result := (v1 + (v2-v1)*((2/3)-vH)*6)
    else  Result := v1;
  end;

var
  dTemp, dTemp2 : Double;
begin
  if IsZero(Saturtion) then
  begin
    Red := Round(Lightness * 255);
    Green := Round(Lightness * 255);
    Blue := Round(Lightness * 255);
  end else
  begin
    if Lightness < 0.5 then
      dTemp := Lightness * (1 + Saturtion)
    else
      dTemp := (Lightness + Saturtion) - (Saturtion * Lightness);

    dTemp2 := 2 * Lightness - dTemp;

    Red := Round( 255 * HueToRGB(dTemp2, dTemp, Hue + ( 1 / 3 )) );
    Green := Round( 255 * HueToRGB(dTemp2, dTemp, Hue) );
    Blue := Round( 255 * HueToRGB(dTemp2, dTemp, Hue - (1 / 3)) );
  end;
end;

function EncodeRGB(const Red, Green, Blue : Byte) : TColor;
begin
  Result := Red + (Green shl 8) + (Blue shl 16);
end;

//-- realtime ATM
function GetATM(const dClose : Double) : Double;
var
  dFloatPart : Double;
  iTemp, i10, i5 : Integer;
begin
  //
  i10 := Floor(dClose / 10);
  i5 := Floor((dClose - i10 *10) / 5);

  iTemp := i10 * 10 + i5 * 5;
  dFloatPart := dClose - iTemp;

  if dFloatPart < 10/8 then Result := iTemp
  else if dFloatPart < 30/8 then Result := iTemp + 2.5
  else Result := iTemp + 5;
end;


Procedure SetEnglishMode( handle : Thandle );
var
  bKr : boolean;
  tMode : HIMC;
  Conversion, Sentence: DWORD;
begin
  if handle <=0 then
    Exit;

  tMode := ImmGetContext(handle);
  ImmGetConversionStatus(tMode, Conversion, Sentence);
  if Conversion = IME_CMODE_HANGEUL then
    ImmSetConversionStatus(tMode, IME_CMODE_ALPHANUMERIC, 
                                  IME_CMODE_ALPHANUMERIC);

end;

// ?????????? ???? ??????...
{
function StandartToShortCode( Value : string ) : string;
var
  iLen : integer;
begin
  case Value[3] of
    '4' : iLen := 8;
    else
      iLen  := 6;
  end;
  Result := Copy( Value, 4, iLen );
end;
}


function ComparePrice( iPre: integer; dPrice1, dPrice2 : double ) : integer;
var
  stPrice1, stPrice2 : string;
begin
  stPrice1  := Format('%*n', [ iPre, dPrice1 ] );
  stPrice2  := Format('%*n', [ iPre, dPrice2 ] );

  Result := CompareStr( stPrice1, stPrice2 );

end;


function GetMACAdress:String;
var
  NCB : PNCB;
  Adapter :PAdapterStatus;
  URetCode :Pchar;
  RetCode :char;
  I : Integer;
  Lenum : PlanaEnum;
 _SystemID :String;
  TMPSTR :String;
begin
  Result:='';
  _SystemID:='';
  Getmem(NCB,sizeof(TNCB));
  Fillchar(NCB^,Sizeof(TNCB),0);

  Getmem(Lenum,sizeof(TLanaEnum));
  Fillchar(Lenum^,Sizeof(TLanaEnum),0);

  Getmem(Adapter,sizeof(TAdapterStatus));
  Fillchar(Adapter^,Sizeof(TAdapterStatus),0);

  Lenum.Length:=chr(0);
  NCB.ncb_command:=chr(NCBENUM);
  NCB.ncb_buffer:=pointer(Lenum);
  NCB.ncb_length:=sizeof(Lenum);
  RetCode:=Netbios(NCB);

  i:=0;
  Repeat
  Fillchar(NCB^,Sizeof(TNCB),0);
  Ncb.ncb_command:= chr(NCBRESET);
  Ncb.ncb_lana_num:=lenum.lana[I];
  RetCode:= Netbios(Ncb);

  Fillchar(NCB^,Sizeof(TNCB),0);
  Ncb.ncb_command:= chr(NCBASTAT);
  Ncb.ncb_lana_num:= lenum.lana[I];
  // Must be 16
  Ncb.ncb_callname:='* ';

  Ncb.ncb_buffer:=pointer(Adapter);

  Ncb.ncb_length:=sizeof(TAdapterStatus);
  RetCode:= Netbios(Ncb);
  //---- calc _systemId from mac-address[2-5] XOR mac-address[1]...
  if (RetCode=chr(0)) or (RetCode=chr(6)) then
  Begin
  _SystemId:=inttohex(ord(Adapter.adapter_address[0]),2)+
  inttohex(ord(Adapter.adapter_address[1]),2)+
  inttohex(ord(Adapter.adapter_address[2]),2)+
  inttohex(ord(Adapter.adapter_address[3]),2)+
  inttohex(ord(Adapter.adapter_address[4]),2)+
  inttohex(ord(Adapter.adapter_address[5]),2);

  end;
  inc(i);
  until (I>=ord(Lenum.length)) or (_SystemID<>'00-00-00-00-00-00');

  FreeMem(NCB);
  FreeMem(Adapter);
  FreeMem(Lenum);
  GetMacAdress:=_SystemID;
end;

function GetSizeOfFile(const FilenName:string) : Longint;
var
   FHandle : Integer;
begin
   if FileExists(FilenName) then begin
      FHandle := FileOpen(FilenName, fmOpenRead+fmShareDenyNone);
      Result  := GetFileSize(FHandle, nil); // GetFileSize?? Win32API
      FileClose(FHandle);
   end
   else Result  := 0;
end;


initialization

timeBeginPeriod(1);

finalization

timeEndPeriod(1);

end.
