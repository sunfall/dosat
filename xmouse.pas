unit XMouse;

{ mouse routines, supporting SVGA }

interface

uses Drivers;

procedure ResetMouse;
procedure DrawMouse(x, y: integer);
procedure EraseMouse;
procedure ClearMouseDrawn;

procedure XGetMouseEvent(var E: TEvent);
procedure GetEvent(var E: TEvent);
procedure WaitForEvent(var E: TEvent);
procedure WaitForEventOrEdge(var E: TEvent);

implementation

uses CRT, XSVGA;

var
  MouseDrawnX, MouseDrawnY: integer;

procedure ResetMouse;
  begin
    asm
      mov  ax, 0
      int  33h     { reset mouse }
      mov  ax, 7
      mov  cx, 0
      mov  dx, 639
      int  33h     { set horizontal min/max }
      mov  ax, 8
      mov  cx, 0
      mov  dx, 479
      int  33h     { set vertical min/max }
      mov  ax, 4
      mov  cx, 320
      mov  dx, 240
      int  33h     { set mouse position to screen center }
    end;
    ClearMouseDrawn;
  end;

procedure DrawMouse(x, y: integer);
  const
    MouseGr: array [0..7, 0..7] of byte =
    (
      ($00, $00, $00, $00, $00, $00, $00, $FF),
      ($00, $0F, $0F, $0F, $0F, $0F, $00, $FF),
      ($00, $0F, $0F, $0F, $0F, $00, $00, $FF),
      ($00, $0F, $0F, $0F, $00, $00, $FF, $FF),
      ($00, $0F, $0F, $00, $0F, $00, $00, $FF),
      ($00, $0F, $00, $00, $00, $0F, $00, $00),
      ($00, $00, $00, $FF, $00, $00, $0F, $00),
      ($FF, $FF, $FF, $FF, $FF, $00, $00, $00)
    );
  var
    i, j: integer;
  begin
    for j := 0 to 7 do
      for i := 0 to 7 do
        if (MouseGr[i, j] <> 255) and (x + i < 640) and (y + j < 480) then
          SPutPixel(x + i, y + j, MouseGr[i, j]);
    MouseDrawnX := x;
    MouseDrawnY := y;
  end;

procedure EraseMouse;
  var
    i, j: integer;
    addr: longint;
  begin
    if MouseDrawnX <> -1 then begin
      for j := 0 to 7 do
        for i := 0 to 7 do
          if (MouseDrawnX + i < 640) and (MouseDrawnY + j < 480) then begin
            addr := MouseDrawnX + i + (MouseDrawnY + j) * longint(640);
            SPutPixel(MouseDrawnX + i, MouseDrawnY + j,
                      ScreenBuf[addr div 32768]^[addr mod 32768]);
          end;
    end;
  end;

procedure ClearMouseDrawn;
  begin
    MouseDrawnX := -1;
  end;

procedure XGetMouseEvent(var E: TEvent);
  const
    LastButtons: byte = 0;
  var
    b: byte;
    x, y: word;
  begin
    E.What := evNothing;
    asm
      mov  ax, 3
      int  33h
      mov  b, bl
      mov  x, cx
      mov  y, dx
    end;
    E.Buttons := b;
    E.Where.X := x;
    E.Where.Y := y;
    E.Double := false;

    if (b <> 0) and (LastButtons = 0) then begin
      E.What := evMouseDown;
      E.Buttons := b;                { button down debouncing }
    end;
    LastButtons := b;

    if (MouseDrawnX <> x) or (MouseDrawnY <> y) then begin
      EraseMouse;
      DrawMouse(x, y);
    end;
  end;

procedure XGetKeyEvent(var E: TEvent);
  begin
    if keypressed then begin
      E.What := evKeyDown;
      E.CharCode := readkey;
      if E.CharCode = #0 then
        E.KeyCode := Ord(E.CharCode) + (ord(readkey) shl 8);
    end else
      E.What := evNothing;
  end;

procedure GetEvent(var E: TEvent);
  begin
    XGetMouseEvent(E);
    if E.What = evNothing then
      XGetKeyEvent(E);
  end;

procedure WaitForEvent(var E: TEvent);
  begin
    RefreshScreen;
    repeat
      GetEvent(E);
    until (E.What <> evNothing);
    EraseMouse;
  end;

procedure WaitForEventOrEdge(var E: TEvent);
  begin
    RefreshScreen;
    repeat
      XGetKeyEvent(E);
      if E.What = evNothing then begin
        XGetMouseEvent(E);
        if (E.What = evNothing)
           and ((E.Where.X = 0) or (E.Where.Y = 0)
                or (E.Where.X = 639) or (E.Where.Y = 479)) then
          E.What := evMouse;
      end;
    until (E.What <> evNothing);
    EraseMouse;
  end;

{ unit initialization }

end.
