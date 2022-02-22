unit ChartHandler;

interface

uses
  Classes, Forms, Buttons, Controls, ComCtrls, ExtCtrls, SysUtils, StdCtrls,
  Graphics,

  ChartCentralBase, Stickers;

type
  TChartPointerMode = (
                pmNormal,
                pmCrossPrep{십자선모드}, pmCrossMoving{십자선 상태},
                //
                pmZoneResizing{Zone크기 변경},
                //
                pmChartMoving{그래프 위치변경},
                //
                pmTLinePrep{추세선준비} , pmTLineDrawing{추세선그리기},
                pmTLineMoving{추세선이동}, pmTLineStretching{추세선늘임},
                //
                pmHLinePrep{지지/저항선 그리기}, pmHLineMoving{지지/저항선 이동},
                //
                pmVLinePrep{수직선 그리기}, pmVLineMoving{수직선이동},
                //
                pmFormMoving{폼이동}, pmFormResizing{폼크기변경});

  TChartHandler = class
  private
    // chart references
    FChartForm : TForm;
    FChartCentral : TChartCentralBase;
    FPaintGraph : TPaintBox;
    FStatusBar : TStatusBar;

    // status
    FMode : TChartPointerMode;
    FScreenCursor : TCursor;
    FMouseDown : Boolean;
    FSZone, FEZone: Integer;
    FSX, FSY : Integer;
    FEX, FEY : Integer;
    // tool buttons
    FButtonZoomIn  : TSpeedButton;
    FButtonZoomOut : TSpeedButton;
    FButtonNormal  : TSpeedButton;
    FButtonTLine   : TSpeedButton;
    FButtonHLine   : TSpeedButton;
    FButtonVLine   : TSpeedButton;
    FButtonCross   : TSpeedButton;

    // events
    FOnStateChanged : TNotifyEvent;
    FStatusIndex: Integer;

    procedure SetMode(aMode : TChartPointerMode);
       // set buttons
    procedure SetButtonZoomIn(const Value: TSpeedButton);
    procedure SetButtonZoomOut(const Value: TSpeedButton);
    procedure SetButtonNormal(const Value: TSpeedButton);
    procedure SetButtonTLine(const Value: TSpeedButton);
    procedure SetButtonHLine(const Value: TSpeedButton);
    procedure SetButtonVLine(const Value: TSpeedButton);
    procedure SetButtonCross(const Value: TSpeedButton);
    procedure SetButton(var aButton : TSpeedButton;
                 Value : TSpeedButton; iTag : Integer);
       // ChartCentral event handler
    procedure ChartRefreshed(Sender : TObject);
      // Button Event handlers
    procedure ToolButtonClick(Sender : TObject);
      // PaintBox Event handlers
    procedure GraphPaint(Sender : TObject);
    procedure GraphMouseDown(Sender: TObject; Button: TMouseButton;
                 Shift: TShiftState; X, Y: Integer);
    procedure GraphMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GraphMouseUp(Sender: TObject; Button: TMouseButton;
                 Shift: TShiftState; X, Y: Integer);

    procedure UpdateButtonZoom(Sender : TObject);
  public
    constructor Create(aForm : TForm; aCentral : TChartCentralBase;
                    aPaintBox : TPaintBox; aStatusBar : TStatusBar);

    property ButtonZoomIn  : TSpeedButton read FButtonZoomIn write SetButtonZoomIn;
    property ButtonZoomOut : TSpeedButton read FButtonZoomOut write SetButtonZoomOut;
    property ButtonNormal  : TSpeedButton read FButtonNormal write SetButtonNormal;
    property ButtonTLine   : TSpeedButton read FButtonTLine write SetButtonTLine;
    property ButtonHLine   : TSpeedButton read FButtonHLine write SetButtonHLine;
    property ButtonVLine   : TSpeedButton read FButtonVLine write SetButtonVLine;
    property ButtonCross   : TSpeedButton read FButtonCross write SetButtonCross;

    property OnStateChanged : TNotifyEvent read FOnStateChanged write FOnStateChanged;
    property StatusIndex : Integer read FStatusIndex write FStatusIndex;
  end;

implementation

{ TChartHandler }


const
  //
  TAG_ZOOMIN  = 110;
  TAG_ZOOMOUT = 120;
  //
  TAG_NORMAL  = 200;
  TAG_TLINE   = 210;
  TAG_HLINE   = 220;
  TAG_VLINE   = 230;
  TAG_CROSS   = 240;


constructor TChartHandler.Create(aForm : TForm; aCentral: TChartCentralBase;
  aPaintBox: TPaintBox; aStatusBar : TStatusBar);
begin
    // set objects
  FChartForm := aForm;
  FChartCentral := aCentral;
  FPaintGraph := aPaintBox;
  FStatusBar := aStatusBar;
  FStatusIndex := -1;

    // link events
  if FChartCentral <> nil then
  begin
    FChartCentral.OnRefresh := ChartRefreshed;
    FChartCentral.OnBarWidthChanged := UpdateButtonZoom;
  end;

  if FPaintGraph <> nil then
  begin
    FPaintGraph.OnPaint     := GraphPaint;
    FPaintGraph.OnMouseDown := GraphMouseDown;
    FPaintGraph.OnMouseMove := GraphMouseMove;
    FPaintGraph.OnMouseUp   := GraphMouseUp;
  end;

    // initialize environment
  FMode := pmNormal;
end;

//=====================< ChartCentral Events >=======================//

procedure TChartHandler.ChartRefreshed(Sender : TObject);
begin
  FEX := -1;
end;

//========================< Set States >============================//

procedure TChartHandler.SetMode(aMode : TChartPointerMode);
begin
  if FMode = aMode then Exit;
  //
  FMode := aMode;
  //
  if aMode in [pmCrossPrep,
               pmTLinePrep, pmHLinePrep, pmVLinePrep] then
    FPaintGraph.Cursor := crCross
  else if aMode = pmNormal then
    FPaintGraph.Cursor := crArrow
  else
    FPaintGraph.Cursor := crNone;
  //
  case aMode of
    pmNormal    :  // 기본커서
         if not FButtonNormal.Down then
           FButtonNormal.Down := True;
    pmTLinePrep :  // 추세선 준비
         if not FButtonTLine.Down then
           FButtonTLine.Down := True;
    pmHLinePrep :  // 수평선 준비
         if not FButtonHLine.Down then
           FButtonHLine.Down := True;
    pmVLinePrep :  // 수직선 준비
         if not FButtonVLine.Down then
           FButtonVLine.Down := True;
    pmCrossPrep :  // 십자선 준비
         if not FButtonCross.Down then
           FButtonCross.Down := True;
  end;
  //
  FChartCentral.NoDraw := False;
  FChartCentral.Refresh;
end;


//========================< Tool Buttons Events >============================//

procedure TChartHandler.ToolButtonClick(Sender : TObject);
begin
  FChartCentral.Selected := nil;

  case (Sender as TSpeedButton).Tag of
    TAG_ZOOMIN  : // 간격넓게
         begin
           FChartCentral.Zoom(1);

           if Assigned(FOnStateChanged) then
             FOnStateChanged(Self);
         end;
    TAG_ZOOMOUT :
         begin
           FChartCentral.Zoom(-1);

           if Assigned(FOnStateChanged) then
             FOnStateChanged(Self);
         end;
    TAG_NORMAL  : SetMode(pmNormal);     // 마우스 커서
    TAG_TLINE   : SetMode(pmTLinePrep);  // 추세선 예비
    TAG_HLINE   : SetMode(pmHLinePrep);  // 수평선 예비
    TAG_VLINE   : SetMode(pmVLinePrep);  // 수직선 예비
    TAG_CROSS   : SetMode(pmCrossPrep);      // 십자선 조회
  end;
end;

//========================< Set Buttons >============================//


procedure TChartHandler.SetButton(var aButton : TSpeedButton;
  Value : TSpeedButton; iTag : Integer);
begin
  if Value = nil then Exit;

  aButton := Value;
  aButton.Tag := iTag;
  aButton.OnClick := ToolButtonClick;
end;

procedure TChartHandler.SetButtonZoomIn(const Value: TSpeedButton);
begin
  SetButton(FButtonZoomIn, Value, TAG_ZOOMIN);
  ButtonZoomIn.Enabled := FChartCentral.BarWidth < MAX_BAR_WIDTH;
end;

procedure TChartHandler.SetButtonZoomOut(const Value: TSpeedButton);
begin
  SetButton(FButtonZoomOut, Value, TAG_ZOOMOUT);
  ButtonZoomOut.Enabled := FChartCentral.BarWidth > MIN_BAR_WIDTH;
end;

procedure TChartHandler.SetButtonNormal(const Value: TSpeedButton);
begin
  SetButton(FButtonNormal, Value, TAG_NORMAL);
end;

procedure TChartHandler.SetButtonTLine(const Value: TSpeedButton);
begin
  SetButton(FButtonTLine, Value, TAG_TLINE);
end;

procedure TChartHandler.SetButtonHLine(const Value: TSpeedButton);
begin
  SetButton(FButtonHLine, Value, TAG_HLINE);
end;

procedure TChartHandler.SetButtonVLine(const Value: TSpeedButton);
begin
  SetButton(FButtonVLine, Value, TAG_VLINE);
end;

procedure TChartHandler.SetButtonCross(const Value: TSpeedButton);
begin
  SetButton(FButtonCross, Value, TAG_CROSS);
end;

//========================< Graph Mouse Events >=====================//

procedure TChartHandler.GraphPaint(Sender: TObject);
begin
  FChartCentral.Refresh;
end;

procedure TChartHandler.GraphMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx, iZone : Integer;
begin
{$ifdef DEBUG}
  // gLog.Add(lkDebug, 'Chart', 'MouseDown', 'MouseDown');
{$endif}
  FMouseDown := True;
  //
  case FMode of
    pmNormal :
             // in the boundary of zones?
         if FChartCentral.IndexOfBoundary(X,Y) >= 0 then
         begin
           FMode := pmZoneResizing;
           FChartCentral.NoDraw := True;
           FSZone := FChartCentral.IndexOfBoundary(X,Y);
           FEY := Y;
           //
           FChartCentral.MovingHLine(Y);
         end else
         begin
             // select?
           FChartCentral.Hit(X, Y);

             // not selected -> check for form resizing or moving for Mini-chart
           if FChartCentral.Selected = nil then
           begin
             if not FChartCentral.IsMini then Exit;

             if (X >= FPaintGraph.ClientRect.Right - 10) and
                (X <= FPaintGraph.ClientRect.Right) and
                (Y >= FPaintGraph.ClientRect.Bottom - 10) and
                (Y <= FPaintGraph.ClientRect.Bottom) then
             begin
               FMode := pmFormResizing;
               FSX := X; FSY := Y;
               FPaintGraph.Cursor := crSizeAll;
             end else
             begin
               FMode := pmFormMoving;
               FSX := X; FSY := Y;
               FPaintGraph.Cursor := crHandPoint;
             end;
           end else
             // selected
           // trend line
           if FChartCentral.Selected is TTrendLine then
           begin
             idx := FChartCentral.HitIndex(X);
             with FChartCentral.Selected as TTrendLine do
             if (X >= SPoint.x-2) and (X <= SPoint.x+2) and
                (Y >= SPoint.y-2) and (Y <= SPoint.y+2) then
             begin
               FMode := pmTLineStretching;
               FSX := EPoint.x; FSY := EPoint.y;
               FEX := SPoint.x; FEY := SPoint.y;
             end else
             if (X >= EPoint.x-2) and (X <= EPoint.x+2) and
                (Y >= EPoint.y-2) and (Y <= EPoint.y+2) then
             begin
               FMode := pmTLineStretching;
               FSX := SPoint.x; FSY := SPoint.y;
               FEX := EPoint.x; FEY := EPoint.y;
             end else
             begin
               FMode := pmTLineMoving;
               FSX := X; FSY := Y;
               FEX := X; FEY := Y;
             end;
             //
             FSZone := FChartCentral.IndexOfZone(X,Y);
             FChartCentral.NoDraw := True;
           end else
           // horizontal line
           if FChartCentral.Selected is THorizLine then
           begin
             FMode := pmHLineMoving;
             FChartCentral.NoDraw := True;
             FEY := Y;
             FSZone := FChartCentral.IndexOfZone(X,Y);
             FChartCentral.MovingHLine(Y);

             // Hint
             FChartCentral.ShowHint(FSZone, X, Y, HINT_SHOW_Y);
           end else
           // vertical line
           if FChartCentral.Selected is TVertLine then
           begin
             FMode := pmVLineMoving;
             FChartCentral.NoDraw := True;
             FEX := X;
             FSZone := FChartCentral.IndexOfZone(X,Y);
             FChartCentral.MovingVLine(X);

             // Hint
             FChartCentral.ShowHint(FSZone, X, Y, HINT_SHOW_X);
           end else
           // symboler, indicator
           begin
             FMode := pmChartMoving;
             FChartCentral.NoDraw := True;
             FScreenCursor := Screen.Cursor;
             FSZone := FChartCentral.IndexOfZone(X,Y);
           end;
         end;
    pmCrossPrep : // 십자선
         begin
           iZone := FChartCentral.IndexOfZone(X,Y);
           if iZone >= 0 then
           begin
             FMode := pmCrossMoving;
             FChartCentral.NoDraw := True;
             FScreenCursor := Screen.Cursor;
             FSX := X; FSY := Y;
             FEX := X; FEY := Y;
             FChartCentral.MovingHLine(FSY);
             FChartCentral.MovingVLine(FSX);
             Screen.Cursor := crNone;

             // hint
             FChartCentral.ShowHint(iZone, X, Y, HINT_DATA + HINT_KEY + HINT_SHOW_X + HINT_SHOW_Y);
           end;
         end;
    pmTLinePrep : // 추세선
         begin
           iZone := FChartCentral.IndexOfZone(X,Y);
           if iZone >= 0 then
           begin
             FMode := pmTLineDrawing;
             FChartCentral.NoDraw := True;
             FSX := X; FSY := Y;
             FEX := X; FEY := Y;
             FSZone := iZone;
           end;
         end;
    pmHLinePrep : // 지지/저항선
         begin
           iZone := FChartCentral.IndexOfZone(X,Y);
           if iZone >= 0 then
           begin
             FChartCentral.InsertRLine(iZone, Y);
             SetMode(pmNormal);
           end;
         end;
    pmVLinePrep : // 수직선
         begin
           iZone := FChartCentral.IndexOfZone(X,Y);
           if iZone >= 0 then
           begin
             FChartCentral.InsertVLine(iZone, X);
             SetMode(pmNormal);
           end;
         end;
  end;
end;

procedure TChartHandler.GraphMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  iZone : Integer;
  iDX, iDY, iDX2, iDY2 : Integer;
begin
  case FMode of
    pmNormal :
         if not FMouseDown then
           if FChartCentral.IndexOfBoundary(X,Y) >= 0 then
             FPaintGraph.Cursor := crVSplit
           else if not FChartCentral.IsMini then
           begin
             FPaintGraph.Cursor := crArrow;
             if FStatusBar <> nil then
             begin
               if FStatusIndex = -1 then
                 FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
               else if FStatusBar.Panels.Count > FStatusIndex then
                 FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
             end;
           end else
           if (X >= FPaintGraph.ClientRect.Right - 10) and
              (X <= FPaintGraph.ClientRect.Right) and
              (Y >= FPaintGraph.ClientRect.Bottom - 10) and
              (Y <= FPaintGraph.ClientRect.Bottom) then
           begin
             FPaintGraph.Cursor := crSizeAll;
           end else
           begin
             FPaintGraph.Cursor := crArrow;
           end;
    pmCrossPrep :
         begin
           if FStatusBar <> nil then
           begin
             if FStatusIndex = -1 then
               FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
             else if FStatusBar.Panels.Count > FStatusIndex then
               FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
           end;
         end;
    pmCrossMoving :
         begin
           if FStatusBar <> nil then
           begin
             if FStatusIndex = -1 then
               FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
             else if FStatusBar.Panels.Count > FStatusIndex then
               FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
           end;

           iZone := FChartCentral.IndexOfZone(X,Y);
           if iZone >= 0 then
           begin
               // delete old line
             FChartCentral.MovingHLine(FEY);
             FChartCentral.MovingVLine(FEX);
               // hint
             FChartCentral.ShowHint(iZone, X, Y, HINT_DATA + HINT_KEY + HINT_SHOW_X + HINT_SHOW_Y);
               // new line
             FChartCentral.MovingHLine(Y);
             FChartCentral.MovingVLine(X);
             FEY := Y;
             FEX := X;
           end;
         end;
    pmFormMoving :
         begin
           FPaintGraph.Cursor := crHandPoint;
           FChartForm.Left := FChartForm.Left + X - FSX;
           FChartForm.Top  := FChartForm.Top  + Y - FSY;
         end;
    pmFormResizing :
         begin
           FChartForm.Width  := FChartForm.Width  + X - FSX;
           FChartForm.Height := FChartForm.Height + Y - FSY;
           FSX := X;
           FSY := Y;
         end;
    pmZoneResizing :
         begin
           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone = FSZone) or (iZone = FSZone+1) then
           begin
             FChartCentral.MovingHLine(FEY);
             FChartCentral.MovingHLine(Y);
             FEY := Y;
           end;
         end;
    pmChartMoving :
         begin
           if FChartCentral.IndexOfZone(X,Y) >= 0 then
             if FChartCentral.IndexOfBoundary(X,Y) >= 0 then
             begin
               Screen.Cursor := crMultiDrag;
             end else
               Screen.Cursor := crDrag
           else
             Screen.Cursor := crNoDrop;
         end;
    pmTLineDrawing :
         begin
           if FStatusBar <> nil then
           begin
             if FStatusIndex = -1 then
               FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
             else if FStatusBar.Panels.Count > FStatusIndex then
               FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
           end;

           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone >= 0) and (FSZone = iZone) then
           begin
             FChartCentral.MovingTLine(FSX,FSY,FEX,FEY);
             FChartCentral.MovingTLine(FSX,FSY,X,Y);
             FEX := X;
             FEY := Y;
           end;
         end;
    pmTLineStretching :
         begin
           if FStatusBar <> nil then
           begin
             if FStatusIndex = -1 then
               FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
             else if FStatusBar.Panels.Count > FStatusIndex then
               FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
           end;

           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone >= 0) and (FSZone = iZone) then
           begin
             FChartCentral.MovingTLine(FSX,FSY,FEX,FEY);
             FChartCentral.MovingTLine(FSX,FSY,X,Y);
             FEX := X;
             FEY := Y;
           end;
         end;
    pmTLineMoving :
         begin
           iDX := X - FSX; iDY := Y - FSY;
           with FChartCentral.Selected as TTrendLine do
           begin
             iZone := FChartCentral.IndexOfZone(SPoint.x+iDX, SPoint.y+iDY);
             //if (FChartCentral.IndexOfZone(SPoint.x+iDX, SPoint.y+iDY) = 0) or
             //   (FChartCentral.IndexOfZone(EPoint.x+iDX, EPoint.y+iDY) = 0) then
             if (iZone >= 0) and (FSZone = iZone) then
             begin
               iDX2 := FEX - FSX; iDY2 := FEY - FSY;
               FChartCentral.MovingTLine(
                     SPoint.x+iDX2, SPoint.y+iDY2, EPoint.x+iDX2, EPoint.y+iDY2);
               FChartCentral.MovingTLine(
                     SPoint.x+iDX, SPoint.y+iDY, EPoint.x+iDX, EPoint.y+iDY);
               FEX := X;
               FEY := Y;
             end;
           end;
         end;
    pmHLineMoving :
         begin
           if FStatusBar <> nil then
           begin
             if FStatusIndex = -1 then
               FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
             else if FStatusBar.Panels.Count > FStatusIndex then
               FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
           end;

           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone >= 0) and (FSZone = iZone) then
           begin
             FChartCentral.MovingHLine(FEY);
             FChartCentral.ShowHint(iZone, X, Y, HINT_SHOW_Y);
             FChartCentral.MovingHLine(Y);
             FEY := Y;
           end;
         end;
    pmVLineMoving :
         begin
           if FStatusBar <> nil then
           begin
             if FStatusIndex = -1 then
               FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
             else if FStatusBar.Panels.Count > FStatusIndex then
               FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
           end;

           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone >= 0) and (FSZone = iZone) then
           begin
             FChartCentral.MovingVLine(FEX);
             FChartCentral.ShowHint(iZone, X, Y, HINT_SHOW_X);
             FChartCentral.MovingVLine(X);
             FEX := X;
           end;
         end;
    pmTLinePrep, pmHLinePrep, pmVLinePrep :
         if FStatusBar <> nil then
         begin
           if FStatusIndex = -1 then
             FStatusBar.SimpleText := FChartCentral.SpotData(X,Y)
           else if FStatusBar.Panels.Count > FStatusIndex then
             FStatusBar.Panels[FStatusIndex].Text := FChartCentral.SpotData(X,Y);
         end;
  end;

end;

procedure TChartHandler.GraphMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iDX, iDY : Integer;
  iZone, iBoundZone : Integer;
begin
{$ifdef DEBUG}
  // gLog.Add(lkDebug, 'Chart', 'MouseUp', 'MouseUp');
{$endif}
  FMouseDown := False;
  //
  case FMode of
    pmFormMoving :
         begin
           SetMode(pmNormal);
         end;
    pmFormResizing :
         begin
           SetMode(pmNormal);
         end;
    pmZoneResizing :
         begin
           FChartCentral.ResizeZone(FSZone, FEY);
           SetMode(pmNormal);

           if Assigned(FOnStateChanged) then
             FOnStateChanged(Self);
         end;
    pmChartMoving :
         begin
           Screen.Cursor := FScreenCursor;
           //
           iZone := FChartCentral.IndexOfZone(X,Y);
           iBoundZone := FChartCentral.IndexOfBoundary(X,Y);
           // move graph or into new zone
           if not FChartCentral.LockMoved then
           begin
            if iBoundZone >= 0 then
               FChartCentral.Move(FChartCentral.Selected, FSZone, iBoundZone, True)
            else
               FChartCentral.Move(FChartCentral.Selected, FSZone, iZone, False);
           end;

           SetMode(pmNormal);

           if Assigned(FOnStateChanged) and not FChartCentral.LockMoved then
             FOnStateChanged(Self);
         end;
    pmCrossMoving :
         begin
           FChartCentral.HideHint;
           Screen.Cursor := FScreenCursor;
           SetMode(pmCrossPrep);
         end;
    pmTLineDrawing :
         begin
           iZone := FChartCentral.IndexOfZone(X,Y);

           if (iZone >= 0) and (FSZone = iZone) then
           begin
             FChartCentral.InsertTLine(iZone, FSX,FSY,X,Y);
             SetMode(pmNormal);
           end else
           begin
             FChartCentral.MovingTLine(FSX,FSY,FEX,FEY);
             SetMode(pmTLinePrep);
           end;
         end;
    pmTLineStretching :
         begin
           iZone := FChartCentral.IndexOfZone(X, Y);

           if (iZone >= 0) and (FSZone = iZone) then
             with FChartCentral.Selected as TTrendLine do
             begin
               SIndex := FChartCentral.HitIndex(FSX);
               EIndex := FChartCentral.HitIndex(FEX);
               SValue := FChartCentral.HitPrice(iZone, FSY);
               EValue := FChartCentral.HitPrice(iZone, FEY);
             end;

           //
           SetMode(pmNormal);
         end;
    pmTLineMoving :
         begin
           iDX := X - FSX; iDY := Y - FSY;
           with FChartCentral.Selected as TTrendLine do
           begin
             iZone := FChartCentral.IndexOfZone(SPoint.x+iDX, SPoint.y+iDY);
             if (iZone >= 0) and (FSZone = iZone) then
             //if (FChartCentral.IndexOfZone(SPoint.x+iDX, SPoint.y+iDY) = 0) or
             //   (FChartCentral.IndexOfZone(EPoint.x+iDX, EPoint.y+iDY) = 0) then
             begin
               SIndex := FChartCentral.HitIndex(SPoint.x + iDX);
               EIndex := FChartCentral.HitIndex(EPoint.x + iDX);
               SValue := FChartCentral.HitPrice(iZone, SPoint.y + iDY);
               EValue := FChartCentral.HitPrice(iZone, EPoint.y + iDY);
             end;
           end;

           SetMode(pmNormal);
         end;
    pmHLineMoving :
         begin
           FChartCentral.HideHint;
           
           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone >= 0) and (FSZone = iZone) then
             (FChartCentral.Selected as THorizLine).Value :=
                FChartCentral.HitPrice(iZone, Y);

           SetMode(pmNormal);
         end;
    pmVLineMoving :
         begin
           FChartCentral.HideHint;
           
           iZone := FChartCentral.IndexOfZone(X,Y);
           if (iZone >= 0) and (FSZone = iZone) then
             (FChartCentral.Selected as TVertLine).BarIndex :=
                FChartCentral.HitIndex(X);

           SetMode(pmNormal);
         end;
  end;
end;

procedure TChartHandler.UpdateButtonZoom(Sender: TObject);
begin
  //
  ButtonZoomIn.Enabled := FChartCentral.BarWidth < MAX_BAR_WIDTH;
  ButtonZoomOut.Enabled := FChartCentral.BarWidth > MIN_BAR_WIDTH;
end;

end.
