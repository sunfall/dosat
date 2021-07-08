unit XSVGA;

{ SVGA 640x480x256 routines }

interface

type
  THalfBank = array [0..32767] of byte;
  PHalfBank = ^THalfBank;

var
  ScreenBuf: array [0..9] of PHalfBank;
  CurrentBank: integer;

procedure SetBank(b: integer);
procedure SetSVGAMode;
procedure SPutPixel(x, y: integer; c: byte);
procedure DMove(var source, dest; count: word);
procedure WStore(var dest; count: word; dat: byte);
procedure CloseGraphics;
procedure SetPalEntry(entry, R, G, B: byte);
procedure RefreshScreen;

procedure InitSVGA;
procedure DoneSVGA;

implementation

uses XMouse;

procedure SetSVGAMode;
  begin
    asm
      mov  ax, 4F02h
      mov  bx, 101h
      int  10h
    end;
    ResetMouse;
  end;

procedure CloseGraphics; assembler;
  asm
    mov ax, 3
    int 10h
  end;

procedure SetPalEntry(entry, R, G, B: byte); assembler;
  asm
    mov dx, 3c8h
    mov al, entry
    out dx, al
    inc dx
    mov al, R
    out dx, al
    mov al, G
    out dx, al
    mov al, B
    out dx, al
  end;

procedure SetBank(b: integer); assembler;
  asm
    mov ax, 4F05h
    xor bx, bx
    mov dx, b
    int 10h
  end;

procedure SPutPixel(x, y: integer; c: byte);
  var
    b: integer;
    addr: longint;
  begin
    addr := y * longint(640) + x;
    b := addr div 65536;
    if b <> CurrentBank then begin
      SetBank(b);
      CurrentBank := b;
    end;
    Mem[SegA000:addr mod 65536] := c;
  end;

procedure DMove(var source, dest; count: word); assembler;
  asm
    push ds
    lds  si, source
    les  di, dest
    mov  cx, count
    mov  ax, cx
    cld
    shr  cx, 2
    db   66h         { next instruction will really be rep movsd }
    rep  movsw       { thus this requires 80386 or better }
    mov  cl, al
    and  cl, 3
    rep  movsb
    pop  ds
  end;

procedure WStore(var dest; count: word; dat: byte); assembler;
  asm
    les  di, dest
    mov  cx, count
    mov  bx, cx
    mov  al, dat
    mov  ah, al
    cld
    shr  cx, 1
    rep  stosw
    mov  cl, bl
    and  cl, 1
    rep  stosb
  end;

procedure RefreshScreen;
  var
    b, numb, p, i, buf, bufn: word;
    bufp, scrp: PChar;
  begin
    for b := 0 to 4 do begin
      SetBank(b);
      for buf := 0 to 1 do begin
        bufn := b * 2 + buf;
        if bufn = 9 then numb := 12288 else numb := 32768;
        bufp := @ScreenBuf[bufn]^[0];
        scrp := Ptr(SegA000, buf * 32768);
        DMove(bufp^, scrp^, numb);
      end;
    end;
    CurrentBank := 9;
    ClearMouseDrawn;
  end;

procedure InitSVGA;
  var i: integer;
  begin
    for i := 0 to 9 do New(ScreenBuf[i]);
    CurrentBank := -1;
  end;

procedure DoneSVGA;
  var i: integer;
  begin
    for i := 0 to 9 do Dispose(ScreenBuf[i]);
  end;

{ unit initialization }

end.
