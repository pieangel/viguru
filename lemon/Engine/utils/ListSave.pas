unit ListSave;

interface

uses Classes, SysUtils, Windows, WinSock, Grids, Graphics, ComCtrls, Controls,
     StdCtrls, Math, ShellAPI, Forms, CommCtrl,
     Dialogs;

type
  TSeparate = ( spTab, spSpace, spComma, spColon, spSemiColon );
  TSepatates = set of TSeparate;

  TListSave = class
  private
    FSeparate : String;
    FSaveD : TSaveDialog;
    FSaveFileName : String;
    procedure SetSeparate( spTmp : TSeparate );
  public
    constructor Create(aCom : TComponent) ;
    destructor Destroy ; override;

    function CreateCsvFile(spType : TSeparate ; stFileName : String ; aListView : TListView) : Boolean; overload;
    function CreateCsvFile(spType : TSeparate ; aListView : TListView) : Boolean; overload ;
  end;

  TDataSave = class
  private
    FFieldCount : Integer;
    FLine : String;
    FList : TStringList;
    FDelimiter : String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddField(stField : String);
    procedure AddLine(stLine : String);
    procedure NewLine;
    procedure ClearLine;

    procedure Init;
    procedure Save(stFile : String; bAsk : Boolean = False);

    property Delimiter : String read FDelimiter write FDelimiter;
  end;


implementation

{ TListSave }

constructor TListSave.Create(aCom : TComponent);
begin
  FSaveD := TSaveDialog.Create(aCom);
  FSaveD.Filter := '*.csv';
end;

function TListSave.CreateCsvFile(spType: TSeparate; stFileName: String;
  aListView: TListView): Boolean;
var
  i,j : Integer;
  stFile,stTmp : String;
  slFile : TStringList;
begin

  Result := False;

  

    FSaveD.FileName :=  stFileName ;
    
    if FSaveD.Execute then
    begin
      stFileName := FSaveD.FileName;

    try
    
    slFile := TStringList.Create;
    stFile := '';
    SetSeparate(spType);

    with aListView do
    for i:=0 to Items.Count-1 do
    begin
      if i=0 then
      begin
        for j:=0 to Columns.Count-1 do //컬럼 헤더 넣는 부분
        begin
          stTmp := '';

          stTmp := Columns.Items[j].Caption;

          while Pos(',',stTmp) > 0 do
            stTmp := Copy(stTmp,1,Pos(',',stTmp)-1)+Copy(stTmp,Pos(',',stTmp)+1,Length(stTmp));

          stFile := stFile+stTmp+FSeparate;
        end;
        stFile := stFile+#13#10;
      end;

      for j:=0 to Columns.Count-1 do
      begin
        stTmp := '';
        if j=0 then
          stTmp := Items[i].Caption
        else
          stTmp := Items[i].SubItems[j-1];

        while Pos(',',stTmp) > 0 do
          stTmp := Copy(stTmp,1,Pos(',',stTmp)-1)+Copy(stTmp,Pos(',',stTmp)+1,Length(stTmp));

        stFile := stFile+stTmp+FSeparate;
      end;
      stFile := stFile+#13#10;
    end;

    slFile.Add(stFile);

    if Pos('.csv',stFileName) <= 0 then
    begin
      stFileName := stFileName+'.csv';
      DeleteFile(pChar(stFileName));
      slFile.SaveToFile(stFileName);
    end
    else
    begin
      DeleteFile(pChar(stFileName));
      slFile.SaveToFile(stFileName);
    end;

    slFile.Free;
    Result := True;

    except
      slFile.Free;
      Result := False;
    end;

  end;
  
  
end;

function TListSave.CreateCsvFile(spType: TSeparate;
  aListView: TListView): Boolean;
var
  i,j : Integer;
  stFile,stTmp : String;
  slFile : TStringList;
  stFileName : String;
begin

  Result := False;


  
    if FSaveD.Execute then
    begin
      stFileName := FSaveD.FileName;
    
     try
     
    slFile := TStringList.Create;
    stFile := '';
    SetSeparate(spType);

    with aListView do
    for i:=0 to Items.Count-1 do
    begin
      if i=0 then
      begin
        for j:=0 to Columns.Count-1 do //컬럼 헤더 넣는 부분
        begin
          stTmp := '';

          stTmp := Columns.Items[j].Caption;

          while Pos(',',stTmp) > 0 do
            stTmp := Copy(stTmp,1,Pos(',',stTmp)-1)+Copy(stTmp,Pos(',',stTmp)+1,Length(stTmp));

          stFile := stFile+stTmp+FSeparate;
        end;
        stFile := stFile+#13#10;
      end;

      for j:=0 to Columns.Count-1 do
      begin
        stTmp := '';
        if j=0 then
          stTmp := Items[i].Caption
        else
        begin
          if j-1 <= Items[i].SubItems.Count-1 then
            stTmp := Items[i].SubItems[j-1];
        end;

        while Pos(',',stTmp) > 0 do
          stTmp := Copy(stTmp,1,Pos(',',stTmp)-1)+Copy(stTmp,Pos(',',stTmp)+1,Length(stTmp));

        stFile := stFile+stTmp+FSeparate;
      end;
      stFile := stFile+#13#10;
    end;

    slFile.Add(stFile);

    if Pos('.csv',stFileName) <= 0 then
    begin
      stFileName := stFileName+'.csv';
      DeleteFile(pChar(stFileName));
      slFile.SaveToFile(stFileName);
    end
    else
    begin
      DeleteFile(pChar(stFileName));
      slFile.SaveToFile(stFileName);
    end;

    slFile.Free;
    Result := True;

  except
    slFile.Free;
    Result := False;
  end;

    end;
    
 

  
  
end;

destructor TListSave.Destroy;
begin
  FSaveD.Free;

  inherited;
end;

procedure TListSave.SetSeparate(spTmp: TSeparate);
begin
  if spTmp = spTab then
    FSeparate := #9
  else if spTmp = spSpace then
    FSeparate := ' '
  else if spTmp = spComma then
    FSeparate := ','
  else if spTmp = spColon then
    FSeparate := ':'
  else if spTmp = spSemiColon then
    FSeparate := ';';

end;

{ TDataSave }

constructor TDataSave.Create;
begin
  FList := TStringList.Create;

  FDelimiter := ' ';

  ClearLine;
end;

destructor TDataSave.Destroy;
begin
  FList.Free;

  inherited;
end;

//--------------------< init & save >------------------------//

procedure TDataSave.Init;
begin
  ClearLine;
  FList.Clear;
end;

procedure TDataSave.Save(stFile: String; bAsk: Boolean);
var
  aDlg : TSaveDialog;
begin
  if bAsk then
  begin
    aDlg := TSaveDialog.Create(Application.MainForm);
    aDlg.Filter := '*.csv';

    try
      if stFile <> '' then
        aDlg.FileName := stFile;
      if aDlg.Execute then
        stFile := aDlg.FileName
      else
        Exit;

      if Pos('.csv',stFile) <= 0 then
      begin
        stFile := stFile+'.csv';
        DeleteFile(pChar(stFile));
        FList.SaveToFile(stFile);
      end
      else
      begin
        DeleteFile(pChar(stFile));
        FList.SaveToFile(stFile);
      end;

    finally
      aDlg.Free;
    end;
  end;

  if stFile <> '' then
  try
    FList.SaveToFile(stFile);
    Init;
  except
    on E : Exception do
    ShowMessage('저장이 되지 않았습니다. 사유: ' + E.Message);
  end;
end;

//---------------< add fields & lines >------------------//

procedure TDataSave.AddField(stField: String);
begin
  if FFieldCount = 0 then
    FLine := stField
  else
    FLine := FLine + FDelimiter + stField;
  Inc(FFieldCount);
end;

procedure TDataSave.AddLine(stLine: String);
begin
  FList.Add(stLine);
  ClearLine;
end;

procedure TDataSave.NewLine;
begin
  FList.Add(FLine);
  ClearLine;
end;


procedure TDataSave.ClearLine;
begin
  FLine := '';
  FFieldCount := 0;
end;

end.
