unit lowgr;

{ low-level graphics stuff for hommx }

interface

type
  PGraphic = ^TGraphic;
  TGraphic = array [1..10] of string[10];

  PFont = ^TFont;
  TFont = array [32..127, 0..7] of byte;

const
  colBlack      = 0;
  colDarkRed    = 1;
  colRed        = 2;
  colTan        = 3;
  colDarkGreen  = 4;
  colGreen      = 5;
  colLightGreen = 6;
  colLightGray  = 7;
  colDarkGray   = 8;
  colDarkBlue   = 9;
  colBlue       = 10;
  colLightBlue  = 11;
  colBrown      = 12;
  colLightRed   = 13;
  colYellow     = 14;
  colWhite      = 15;

  colInvisible  = 16;

  colJungle     = 17;
  colSnow       = 18;
  colDesolate   = 19;
  colGreenRoad  = 20;
  colSnowRoad   = 21;
  colDesolateRoad = 22;
  colTemperate2 = 23;
  colDarkTan    = 24;
  colOrange     = 25;
  colJungleShadow   = 26;
  colSnowShadow     = 27;
  colDesolateShadow = 28;
  colDesolateShadow2 = 29;
  colDesolateShadow3 = 30;
  colTemperate2Road = 31;
  colJungleRoad = 32;
  colSnowRoad2 = 33;
  colCombatSnow = 34;

  colNewBlack = $28;
  colDarkDarkGray = $29;
  colNewDarkGray = $2A;
  colDarkDarkRed = $2B;
  colDarkDarkGreen = $2C;
  colDarkDarkBlue = $2D;

  colBlues = $2E;
  colPaleBlues = $34;
  colCyans = $3A;
  colGreens = $40;
  colPaleGreens = $46;
  colGrayGreens = $4C;
  colGrayCyans = $52;
  colYellows = $58;
  colPaleYellows = $5E;
  colGrayYellows = $64;
  colGrays = $6A;
  colOranges = $70;
  colPaleOranges = $76;
  colPinks = $7C;
  colLightMagentas = $82;
  colRedOranges = $88;
  colPaleReds = $8E;
  colPaleMagentas = $94;
  colViolets = $9A;
  colReds = $A0;
  colMaroons = $A6;
  colRedMagentas = $AC;
  colMagentas = $B2;

  colPaleMaroons = $B8;
  colRedGrays = $BB;
  colDarkPinks = $BE;
  colDarkGrayGreens = $C1;
  colYellowyGrayGreens = $C4;
  colFaintPinks = $C7;
  colFaintestPinks = $CA;
  colBurntOranges = $CD;
  colDarkRedOranges = $D0;
  colPaleBurntOranges = $D3;
  colTans = $D6;
  colGreenTans = $D9;
  colLightGreenTans = $DC;
  colLightBrowns = $DF;
  colDarkRedGrays = $E2;
  colGreenOranges = $E5;
  colNicePaleGreens = $E8;
  colDeepMaroons = $EB;
  colDeepOranges = $EE;
  colNewDarkRed = $F1;
  colNewDarkGreen = $F2;
  colNewDarkBlue = $F3;
  colLightReds = $F4;
  colLightGreens = $F7;
  colLightBlues = $FA;
  colLightYellows = $FD;

  colFriend = colPaleBlues + 5;
  colEnemy = colDeepMaroons + 1;

  InvBitTable: array [0..7] of byte = ($80, $40, $20, $10, 8, 4, 2, 1);
  ThreeBits: array [0..5] of byte = ($E0, $70, $38, $1C, $0E, $07);

  DrawBackground: boolean = false;
  BackgroundColor: integer = colGreen;

  ExitIcon: TGraphic =
  ('...****...', { exit }
   '..*    *..',
   '.*    ***.',
   '*    *** *',
   '*   ***  *',
   '*  ***   *',
   '* ***    *',
   '.***    *.',
   '..*    *..',
   '...****...');

  BlankIcon: TGraphic =
  ('..........', { blank }
   '..........',
   '..........',
   '..........',
   '..........',
   '..........',
   '..........',
   '..........',
   '..........',
   '..........');

  RightArrow: TGraphic =
  ('..........', { right arrow }
   '......*...',
   '......**..',
   '*********.',
   '**********',
   '*********.',
   '......**..',
   '......*...',
   '..........',
   '..........');

  LeftArrow: TGraphic =
  ('..........', { left arrow }
   '...*......',
   '..**......',
   '.*********',
   '**********',
   '.*********',
   '..**......',
   '...*......',
   '..........',
   '..........');

  DownArrow: TGraphic =
  ('....***...',
   '....***...',
   '....***...',
   '....***...',
   '....***...',
   '....***...',
   '..*******.',
   '...*****..',
   '....***...',
   '.....*....');

  UpArrow: TGraphic =
  ('.....*....',
   '....***...',
   '...*****..',
   '..*******.',
   '....***...',
   '....***...',
   '....***...',
   '....***...',
   '....***...',
   '....***...');

  Hourglass: TGraphic =
  ('..........',
   '.*******..',
   '.*.....*..',
   '..*...*...',
   '...*.*....',
   '....*.....',
   '...*.*....',
   '..*...*...',
   '.*.....*..',
   '.*******..');

  Computer: TGraphic =
  ('.********.',
   '.*......*.',
   '.*.****.*.',
   '.*.*..*.*.',
   '.*.*..*.*.',
   '.*.****.*.',
   '.*......*.',
   '.*..***.*.',
   '.*......*.',
   '.********.');

  Horsie: TGraphic =
  ('....**....',
   '....**....',
   '....*.....',
   '....**.***',
   '.*..*..***',
   '..********',
   '..******..',
   '..******..',
   '.*.*...*..',
   '.*..*...*.');

  Numerals: array [0..10] of TGraphic =
  (
    ('..........',
     '...****...',
     '..******..',
     '..**..**..',
     '..**..**..',
     '..**..**..',
     '..**..**..',
     '..**..**..',
     '..******..',
     '...****...'),
    ('..........',
     '.....*....',
     '....**....',
     '...***....',
     '...***....',
     '....**....',
     '....**....',
     '....**....',
     '..******..',
     '..******..'),
    ('..........',
     '...****...',
     '..******..',
     '..**..**..',
     '......**..',
     '.....**...',
     '....**....',
     '...**.....',
     '..******..',
     '..******..'),
    ('..........',
     '...****...',
     '..******..',
     '..**..**..',
     '......**..',
     '....***...',
     '......**..',
     '..**..**..',
     '..******..',
     '...****...'),
    ('..........',
     '.....**...',
     '....***...',
     '...****...',
     '..**.**...',
     '..******..',
     '..******..',
     '.....**...',
     '.....**...',
     '.....**...'),
    ('..........',
     '..******..',
     '..******..',
     '..**......',
     '..*****...',
     '...*****..',
     '......**..',
     '..**..**..',
     '..******..',
     '...****...'),
    ('..........',
     '...****...',
     '..******..',
     '..**......',
     '..*****...',
     '..******..',
     '..**..**..',
     '..**..**..',
     '..******..',
     '...****...'),
    ('..........',
     '..******..',
     '..******..',
     '..**..**..',
     '......**..',
     '......**..',
     '......**..',
     '......**..',
     '......**..',
     '......**..'),
    ('..........',
     '...****...',
     '..******..',
     '..**..**..',
     '...****...',
     '..******..',
     '..**..**..',
     '..**..**..',
     '..******..',
     '...****...'),
    ('..........',
     '...****...',
     '..******..',
     '..**..**..',
     '..******..',
     '...*****..',
     '......**..',
     '......**..',
     '..******..',
     '...****...'),
    ('..........',
     '..*..****.',
     '.**.******',
     '***.**..**',
     '***.**..**',
     '.**.**..**',
     '.**.**..**',
     '.**.**..**',
     '.**.******',
     '.**..****.')
  );

procedure SetPalette;
procedure HLine(x1, y1, x2, c: integer);
procedure VLine(x1, y1, y2, c: integer);
procedure ClearArea(x1, y1, x2, y2: integer);
procedure ClearScr;

procedure XPutPixel(x, y: word; c: byte);
function XGetPixel(x, y: word): byte;
procedure XPut3x3Pixels(x, y: word; c: byte);
procedure XPut4x4Pixels(x, y: word; c: byte);
procedure HLine32(x, y: word; c: byte);
procedure VLine32(x, y: word; c: byte);

procedure XRectangle(x1, y1, x2, y2, c: integer);
procedure XFillArea(x1, y1, x2, y2, c: integer);
procedure CheckerArea(a1, b1, a2, b2, c: integer);

procedure DrawGraphic(x, y, c: integer; t: TGraphic; invert: boolean);
procedure DrawGraphic2c(x, y, c, cb: integer; t: TGraphic; invert: boolean);
procedure DrawGraphic256c(x, y: integer; t: TGraphic);
procedure DrawSmallGraphic2c(x, y, c, cb: integer; t: TGraphic);
procedure DrawSmallGraphic256c(x, y: integer; t: TGraphic);
procedure DrawHalfMedGraphic2c(x, y, c, cb, sx: integer; t: TGraphic);
procedure DrawSmallDigit(x, y, c, d: integer);
procedure DrawSmallNumber(x, y, c, d: integer);
procedure DrawSmallNumberStr(x, y, c: integer; s: string);
procedure DrawSmallNumberBox(x, y, c, d: integer);
procedure DrawIcon(i, j: integer; p: PGraphic);
procedure DrawIcon2c(i, j, cf, cb: integer; p: PGraphic);
procedure XDrawIcon2c(i, j, cf, cb: integer; p: PGraphic);
procedure DrawTallIconBox(i, j, bc: integer);

procedure DrawChar(x, y, b, c: integer; ch: char);
procedure DrawText(x, y, b, c: integer; s: string);
function BoxTextLines(x1, x2: integer; s: string): integer;
procedure DrawBoxText(x1, y1, x2, b, c: integer; s: string);

function InIcon(x, y, x2, y2: integer): boolean;

implementation

uses XSVGA, Rez;

type
  TBankHalf = array [0..32767] of byte;
  PBankHalf = ^TBankHalf;

var
  TextFont: PFont;

procedure SetPalette;
  type
    rgb = record
      r, g, b: byte;
    end;
  const
    pal: array [0..39] of rgb =
    (
      (r: $00; g: $00; b: $00),  { black }
      (r: $28; g: $00; b: $00),  { dark red }
      (r: $38; g: $00; b: $00),  { red }
      (r: $30; g: $28; b: $14),  { light tan }
      (r: $00; g: $20; b: $00),  { dark green }
      (r: $00; g: $28; b: $00),  { green }
      (r: $00; g: $38; b: $00),  { light green }
      (r: $2A; g: $2A; b: $2A),  { light gray }
      (r: $15; g: $19; b: $19),  { dark gray }
      (r: $00; g: $00; b: $20),  { dark blue }
      (r: $00; g: $00; b: $3F),  { blue }
      (r: $28; g: $28; b: $3F),  { light blue }
      (r: $20; g: $18; b: $00),  { brown }
      (r: $3F; g: $20; b: $20),  { actual light red }
      (r: $3F; g: $3F; b: $20),  { yellow }
      (r: $3F; g: $3F; b: $3F),  { white }
      (r: $00; g: $00; b: $00),  { invisible! }
      (r: $14; g: $28; b: $14),  { jungle }
      (r: $2E; g: $36; b: $36),  { snow }
      (r: $24; g: $24; b: $1E),  { desolate }
      (r: $26; g: $28; b: $12),  { green road }
      (r: $2F; g: $2F; b: $25),  { snow road }
      (r: $2A; g: $26; b: $19),  { desolate road }
      (r: $00; g: $25; b: $00),  { temperate 2 }
      (r: $2C; g: $20; b: $10),  { dark tan }
      (r: $3F; g: $20; b: $10),  { orange }
      (r: $10; g: $20; b: $10),  { jungle shadow }
      (r: $1F; g: $2E; b: $2E),  { snow shadow }
      (r: $1E; g: $1E; b: $19),  { desolate shadow }
      (r: $18; g: $18; b: $14),  { desolate shadow 2 }
      (r: $12; g: $12; b: $0F),  { desolate shadow 3 }
      (r: $24; g: $26; b: $10),  { temperate 2 road }
      (r: $29; g: $28; b: $14),  { jungle road }
      (r: $2F; g: $32; b: $2D),  { snow road 2 }
      (r: $2D; g: $34; b: $34),  { combat snow }
      (r: $00; g: $00; b: $00),  { unused }
      (r: $00; g: $00; b: $00),  { unused }
      (r: $00; g: $00; b: $00),  { unused }
      (r: $00; g: $00; b: $00),  { unused }
      (r: $00; g: $00; b: $00)   { unused }
    );

  procedure SetSix(e, r, g, b: integer);
    const Nums: array [0..5] of byte = ($20, $26, $2C, $32, $38, $3F);
    var i: integer;
    begin
      for i := 0 to 5 do
        SetPalEntry(e + i, (r * Nums[i]) div 8,
                           (g * Nums[i]) div 8,
                           (b * Nums[i]) div 8);
    end;

  procedure SetThree(e, r, g, b: integer);
    const Nums: array [0..2] of byte = ($26, $32, $3F);
    var i: integer;
    begin
      for i := 0 to 2 do
        SetPalEntry(e + i, (r * Nums[i]) div 8,
                           (g * Nums[i]) div 8,
                           (b * Nums[i]) div 8);
    end;

  procedure ThreeGrays(e, r, g, b: integer);
    const Nums: array [0..2] of byte = ($1C, $27, $32);
    var i, r1, g1, b1: integer;
    begin
      for i := 0 to 2 do begin
        if r = $3F then r1 := r else r1 := Nums[i];
        if g = $3F then g1 := g else g1 := Nums[i];
        if b = $3F then b1 := b else b1 := Nums[i];
        SetPalEntry(e + i, r1, g1, b1);
      end;
    end;

  var
    i: integer;
  begin
    for i := 0 to 39 do
      SetPalEntry(i, pal[i].r, pal[i].g, pal[i].b);

    SetPalEntry(40, $00, $00, $00);
    SetPalEntry(41, $14, $14, $14);
    SetPalEntry(42, $18, $18, $18);
    SetPalEntry(43, $18, $00, $00);
    SetPalEntry(44, $00, $18, $00);
    SetPalEntry(45, $00, $00, $18);

    SetSix( 46, 0, 0, 8);
    SetSix( 52, 0, 5, 8);
    SetSix( 58, 0, 7, 8);

    SetSix( 64, 0, 8, 0);
    SetSix( 70, 0, 8, 4);
    SetSix( 76, 0, 8, 6);
    SetSix( 82, 0, 8, 8);

    SetSix( 88, 8, 8, 0);
    SetSix( 94, 8, 8, 4);
    SetSix(100, 8, 8, 6);
    SetSix(106, 8, 8, 8);
    SetSix(112, 8, 6, 0);
    SetSix(118, 8, 6, 4);
    SetSix(124, 8, 6, 6);
    SetSix(130, 8, 6, 8);
    SetSix(136, 8, 4, 0);
    SetSix(142, 8, 4, 4);
    SetSix(148, 8, 4, 6);
    SetSix(154, 8, 4, 8);
    SetSix(160, 8, 0, 0);
    SetSix(166, 8, 0, 4);
    SetSix(172, 8, 0, 6);
    SetSix(178, 8, 0, 8);

    SetThree(184, 8, 4, 5);
    SetThree(187, 8, 5, 5);
    SetThree(190, 8, 6, 5);
    SetThree(193, 8, 7, 5);
    SetThree(196, 8, 8, 5);
    SetThree(199, 8, 7, 6);
    SetThree(202, 8, 8, 7); {-}
    SetThree(205, 8, 5, 0);

    SetThree(208, 8, 4, 3);
    SetThree(211, 8, 5, 3);
    SetThree(214, 8, 6, 3);
    SetThree(217, 8, 7, 3);
    SetThree(220, 8, 8, 3);
    SetThree(223, 8, 7, 4);
    SetThree(226, 8, 5, 4);
    SetThree(229, 8, 7, 0);

    SetThree(232, 0, 8, 5);
    SetThree(235, 8, 0, 3);
    SetThree(238, 8, 3, 0);
    SetPalEntry(241, $1C, $00, $00);
    SetPalEntry(242, $00, $1C, $00);
    SetPalEntry(243, $00, $00, $1C);
    ThreeGrays(244, $3F, $00, $00);
    ThreeGrays(247, $00, $3F, $00);
    ThreeGrays(250, $00, $00, $3F);
    ThreeGrays(253, $3F, $3F, $00);
  end;

procedure HLine(x1, y1, x2, c: integer);
  var
    addrlo, addrhi, alofs: longint;
    alb, ahb: word;
  begin
    addrlo := x1 + longint(640) * y1;
    addrhi := x2 + longint(640) * y1;

    alb := addrlo div 32768;
    ahb := addrhi div 32768;

    if alb = ahb then begin
      WStore(ScreenBuf[alb]^[addrlo mod 32768], addrhi - addrlo + 1, c);
    end else begin
      WStore(ScreenBuf[alb]^[addrlo mod 32768], 32768 - (addrlo mod 32768), c);
      WStore(ScreenBuf[ahb]^[0], 1 + (addrhi mod 32768), c);
    end;
  end;

procedure VLine(x1, y1, y2, c: integer);
  var j: integer;
  begin
    for j := y1 to y2 do
      XPutPixel(x1, j, c);
  end;

procedure XFillArea(x1, y1, x2, y2, c: integer);
  var j: integer;
  begin
    for j := y1 to y2 do
      HLine(x1, j, x2, c);
  end;

procedure ClearArea(x1, y1, x2, y2: integer);
  var j: integer;
  begin
    XFillArea(x1, y1, x2, y2, colBlack);
  end;

procedure ClearScr;
  var b: integer;
  begin
    for b := 0 to 9 do
      WStore(ScreenBuf[b]^[0], sizeof(THalfBank), colBlack);
  end;

procedure XPutPixel(x, y: word; c: byte);
  var addr: longint;
  begin
    addr := x + longint(640) * y;
    ScreenBuf[addr div 32768]^[addr mod 32768] := c;
  end;

function XGetPixel(x, y: word): byte;
  var addr: longint;
  begin
    addr := x + longint(640) * y;
    XGetPixel := ScreenBuf[addr div 32768]^[addr mod 32768];
  end;

procedure XPut3x3Pixels(x, y: word; c: byte);
  var
    j: integer;
    addr: longint;
    addrlo: word;

  procedure Fast9(var dest; dat: byte); assembler;
    asm
      les  di, dest
      mov  al, dat
      mov  ah, dat
      cld
      stosw
      stosb
      add  di, 640 - 3
      stosw
      stosb
      add  di, 640 - 3
      stosw
      stosb
    end;

  begin
    addr := x + longint(640) * y;
    addrlo := addr mod 32768;
    if addrlo < (32768 - 640 * 2 - 2) then begin
      Fast9(ScreenBuf[addr div 32768]^[addrlo], c);
    end else begin
      for j := 0 to 2 do
        HLine(x, y + j, x + 2, c);
    end;
  end;

procedure XPut4x4Pixels(x, y: word; c: byte);
  var
    j: integer;
    addr: longint;
    addrlo: word;

  procedure Fast16(var dest; dat: byte); assembler;
    asm
      les  di, dest
      mov  al, dat
      mov  ah, dat
      cld
      stosw
      stosw
      add  di, 640 - 4
      stosw
      stosw
      add  di, 640 - 4
      stosw
      stosw
      add  di, 640 - 4
      stosw
      stosw
    end;

  begin
    addr := x + longint(640) * y;
    addrlo := addr mod 32768;
    if addrlo < (32768 - 640 * 3 - 3) then begin
      Fast16(ScreenBuf[addr div 32768]^[addrlo], c);
    end else begin
      for j := 0 to 3 do
        HLine(x, y + j, x + 3, c);
    end;
  end;

procedure HLine32(x, y: word; c: byte);
  var i: integer;
  begin
    HLine(x, y, x + 31, c);
  end;

procedure VLine32(x, y: word; c: byte);
  var j: integer;
  begin
    VLine(x, y, y + 31, c);
  end;

procedure XRectangle(x1, y1, x2, y2, c: integer);
  var i: integer;
  begin
    HLine(x1, y1, x2, c);
    HLine(x1, y2, x2, c);
    if y1 <> y2 then begin
      VLine(x1, y1 + 1, y2 - 1, c);
      VLine(x2, y1 + 1, y2 - 1, c);
    end;
  end;

procedure CheckerArea(a1, b1, a2, b2, c: integer);
  var a, b: integer;
  begin
    for a := a1 to a2 do
      for b := b1 to b2 do
        if (a + b) mod 2 = 0 then XPutPixel(a, b, c);
  end;

procedure DrawGraphic(x, y, c: integer; t: TGraphic; invert: boolean);
  begin
    DrawGraphic2c(x, y, c, colBlack, t, invert);
  end;

procedure DrawGraphic2c(x, y, c, cb: integer; t: TGraphic; invert: boolean);
  var
    i, j, d: integer;
    ch: char;
  begin
    for i := 1 to 10 do
      for j := 1 to 10 do begin
        if invert then
          ch := t[j][11 - i]
        else
          ch := t[j][i];
        if ch = '*' then
          d := c
        else if ch = ' ' then
          d := cb
        else
          d := BackgroundColor;
        if DrawBackground or (ch <> '.') then
          XPut3x3Pixels(x + (i - 1) * 3, y + (j - 1) * 3, d);
      end;
  end;

procedure DrawGraphic256c(x, y: integer; t: TGraphic);
  var i, j, d: integer;
  begin
    for i := 1 to 10 do
      for j := 1 to 10 do begin
        d := ord(t[j][i]);
        if (d = colInvisible) and DrawBackground then
          d := BackgroundColor;
        if d <> colInvisible then
          XPut3x3Pixels(x + (i - 1) * 3, y + (j - 1) * 3, d);
      end;
  end;

procedure DrawSmallGraphic2c(x, y, c, cb: integer; t: TGraphic);
  var i, j, d: integer;
  begin
    for i := 1 to 10 do
      for j := 1 to 10 do begin
        if t[j][i] = '*' then
          d := c
        else
          d := cb;
        if t[j][i] <> '.' then
          XPutPixel(x + i - 1, y + j - 1, d);
      end;
  end;

procedure DrawSmallGraphic256c(x, y: integer; t: TGraphic);
  var i, j, d: integer;
  begin
    for i := 1 to 10 do
      for j := 1 to 10 do begin
        d := ord(t[j][i]);
        if (d = colInvisible) and DrawBackground then d := BackgroundColor;
        if d <> colInvisible then
          XPutPixel(x + i - 1, y + j - 1, d);
      end;
  end;

procedure DrawHalfMedGraphic2c(x, y, c, cb, sx: integer; t: TGraphic);
  var i, j, m, n, d: integer;
  begin
    for i := 1 to 5 do
      for j := 1 to 10 do begin
        if t[j][i + sx - 1] = '*' then
          d := c
        else
          d := cb;
        if t[j][i + sx - 1] <> '.' then begin
          for m := x + (i - 1) * 2 to x + (i - 1) * 2 + 1 do
            for n := y + (j - 1) * 2 to y + (j - 1) * 2 + 1 do
              XPutPixel(m, n, d);
        end;
      end;
  end;

procedure DrawSmallDigit(x, y, c, d: integer);
  const
    digits: array [0..12] of array [1..5] of string[4] =
    (
      ('..*.',
       '.*.*',
       '.*.*',
       '.*.*',
       '..*.'),
      ('..*.',
       '.**.',
       '..*.',
       '..*.',
       '.***'),
      ('.**.',
       '...*',
       '...*',
       '..*.',
       '.***'),
      ('.***',
       '...*',
       '..**',
       '...*',
       '.***'),
      ('.*.*',
       '.*.*',
       '.***',
       '...*',
       '...*'),
      ('.***',
       '.*..',
       '.**.',
       '...*',
       '.**.'),
      ('..**',
       '.*..',
       '.**.',
       '.*.*',
       '..*.'),
      ('.***',
       '...*',
       '..*.',
       '..*.',
       '..*.'),
      ('.***',
       '.*.*',
       '.***',
       '.*.*',
       '.***'),
      ('..*.',
       '.*.*',
       '..**',
       '...*',
       '.**.'),
      ('.*..',
       '.*..',
       '.*.*',
       '.**.',
       '.*.*'),
      ('....',
       '....',
       '.***',
       '....',
       '....'),
      ('....',
       '..*.',
       '.***',
       '..*.',
       '....')
    );
  var
    i, j: integer;
  begin
    for i := 0 to 3 do
      for j := 0 to 4 do
        if digits[d][j + 1][i + 1] = '*' then
          XPutPixel(x + i, y + j, c);
  end;

procedure DrawSmallNumber(x, y, c, d: integer);
  begin
    inc(x, 12);
    repeat
      DrawSmallDigit(x, y, c, d mod 10);
      d := d div 10;
      dec(x, 4);
    until d = 0;
  end;

procedure DrawSmallNumberStr(x, y, c: integer; s: string);
  var i, d: integer;
  begin
    inc(x, 16 - 4 * length(s));
    for i := 1 to length(s) do begin
      case s[i] of
        '0'..'9': d := ord(s[i]) - ord('0');
        'k', 'K': d := 10;
        '-':      d := 11;
        '+':      d := 12;
      end;
      DrawSmallDigit(x + i * 4 - 4, y, c, d);
    end;
  end;

procedure DrawSmallNumberBox(x, y, c, d: integer);
  var x1: integer;
  begin
    x1 := x + 12;
    repeat
      d := d div 10;
      dec(x1, 4);
    until d = 0;
    XFillArea(x1 + 4 - 1 + 1, y - 1, x + 12 + 3 + 1, y + 4 + 1, c);
  end;

procedure DrawIcon(i, j: integer; p: PGraphic);
  var m: integer;
  begin
    XRectangle(i, j, i + 39, j + 39, colLightGray);
    XFillArea(i + 1, j + 1, i + 38, j + 38, colDarkGray);
    DrawGraphic(i + 5, j + 5, colWhite, p^, false);
  end;

procedure DrawIcon2c(i, j, cf, cb: integer; p: PGraphic);
  var m: integer;
  begin
    XRectangle(i, j, i + 39, j + 39, colLightGray);
    XFillArea(i + 1, j + 1, i + 38, j + 38, colDarkGray);
    DrawGraphic2c(i + 5, j + 5, cf, cb, p^, false);
  end;

procedure XDrawIcon2c(i, j, cf, cb: integer; p: PGraphic);
  var m: integer;
  begin
    XRectangle(i - 1, j - 1, i + 32, j + 32, colLightGray);
    XFillArea(i, j, i + 31, j + 31, colDarkGray);
    BackgroundColor := colDarkGray;
    DrawGraphic2c(i + 1, j + 1, cf, cb, p^, false);
    BackgroundColor := colGreen;
  end;

procedure DrawTallIconBox(i, j, bc: integer);
  var m: integer;
  begin
    XRectangle(i, j, i + 35, j + 39, colLightGray);
    XFillArea(i + 1, j + 1, i + 34, j + 38, bc);
  end;

procedure InitLowGr;
  var f: file;
  begin
    New(TextFont);
    assign(f, 'font.pic');
    reset(f, 1);
    blockread(f, TextFont^, sizeof(TextFont^));
    close(f);
  end;

procedure DrawChar(x, y, b, c: integer; ch: char);
  var i, j, n, pc: integer;
  begin
    n := ord(ch);
    if (n >= 16) and (n < 24) then begin
      DrawResourceGraphic(x - 5, y - 2, TResource(n - 16));

    end else begin
      if (n < 32) or (n > 127) then n := ord('X');

      for j := 0 to 7 do
        for i := 0 to 7 do begin
          if (TextFont^[n, j] and InvBitTable[i]) <> 0 then
            pc := c
          else
            pc := b;
          XPutPixel(x + i, y + j, pc);
        end;
    end;
  end;

procedure DrawText(x, y, b, c: integer; s: string);
  var i, x2: integer;
  begin
    x2 := x;
    for i := 1 to length(s) do begin
      if ord(s[i]) < 16 then
        c := ord(s[i])
      else if x2 <= 632 then begin
        DrawChar(x2, y, b, c, s[i]);
        inc(x2, 8);
      end;
    end;
  end;

procedure SplitBoxText(x1, x2: integer; var s, s1: string);
  var n: integer;
  begin
    n := (x2 - x1) div 8;
    if length(s) <= n then
      s1 := s
    else if (length(s) > n) and (s[n + 1] = ' ') then
      s1 := copy(s, 1, n)
    else begin
      s1 := copy(s, 1, n);
      while (length(s1) > 0) and (s1[length(s1)] <> ' ')
            and (s1[length(s1)] <> '-') do
        dec(s1[0]);
      if length(s1) = 0 then s1 := s;
    end;
  end;

function BoxTextLines(x1, x2: integer; s: string): integer;
  var
    s1: string;
    btl: integer;
  begin
    btl := 0;
    repeat
      SplitBoxText(x1, x2, s, s1);
      inc(btl);
      s := copy(s, length(s1) + 1, 255);
      if (length(s) > 0) and (s[1] = ' ') then delete(s, 1, 1);
    until s = '';
    BoxTextLines := btl;
  end;

procedure DrawBoxText(x1, y1, x2, b, c: integer; s: string);
  var
    s1: string;
    i, nc: integer;
  begin
    nc := c;
    repeat
      SplitBoxText(x1, x2, s, s1);
      for i := 1 to length(s1) do
        if s1[i] = '_' then
          s1[i] := ' '
        else if ord(s1[i]) <= 15 then nc := ord(s1[i]);
      DrawText(x1, y1, b, c, s1);
      c := nc;
      s := copy(s, length(s1) + 1, 255);
      if (length(s) > 0) and (s[1] = ' ') then delete(s, 1, 1);
      inc(y1, 12);
    until s = '';
  end;

function InIcon(x, y, x2, y2: integer): boolean;
  begin
    InIcon := (x >= x2) and (x < x2 + 40) and (y >= y2) and (y < y2 + 40);
  end;

{ unit initialization }

begin
  InitLowGr;
end.
