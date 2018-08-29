unit misc;

{ misc low-level hommx stuff - mouse }

interface

uses Drivers;

procedure XGetMouseEvent(var E: TEvent);
procedure GetEvent(var E: TEvent);
procedure WaitForEvent(var E: TEvent);
procedure WaitForEventOrEdge(var E: TEvent);
function InIcon(x, y, x2, y2: integer): boolean;

implementation

uses CRT;

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
      mov b, bl
      mov x, cx
      mov y, dx
    end;
    E.Buttons := b;
    E.Where.X := x;
    E.Where.Y := y;
    E.Double := false;
{
    if (b = 0) and (LastButtons <> 0) then begin
      E.What := evMouseDown;
      E.Buttons := LastButtons;      button-up debouncing
    end;
}
    if (b <> 0) and (LastButtons = 0) then begin
      E.What := evMouseDown;
      E.Buttons := b;                { button down debouncing }
    end;
    LastButtons := b;
  end;

procedure GetKeyEvent(var E: TEvent);
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
      GetKeyEvent(E);
  end;

procedure WaitForEvent(var E: TEvent);
  begin
    ShowMouse;
    repeat
      GetEvent(E);
    until (E.What <> evNothing);
    HideMouse;
  end;

procedure WaitForEventOrEdge(var E: TEvent);
  begin
    ShowMouse;
    repeat
      GetKeyEvent(E);
      if E.What = evNothing then begin
        XGetMouseEvent(E);
        if (E.What = evNothing)
           and ((E.Where.X = 0) or (E.Where.Y = 0)
                or (E.Where.X = 639) or (E.Where.Y = 479)) then
          E.What := evMouse;
      end;
    until (E.What <> evNothing);
    HideMouse;
  end;

function InIcon(x, y, x2, y2: integer): boolean;
  begin
    InIcon := (x >= x2) and (x < x2 + 40) and (y >= y2) and (y < y2 + 40);
  end;

{ unit initialization }

end.
