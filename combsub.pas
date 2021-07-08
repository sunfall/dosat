unit combsub;

{ overflow from combat module }

interface

uses LowGr, Hexes, Spells;

const
  MoveGhostDelay: integer = 10;
  HighlightDelay: integer = 20;
  BlowDelay: integer = 10;
  FXDelay: integer = 30;
  ScrollDelay: integer = 5;

  NumCombatDefs = 80;

  cFireDamage = 200;
  cBarbicanDamage = 100;
  cArcheryDamage = 50;
  cHealDamage = 15;
  cDarkArtsKills = 30;
  cGateStrength = 150;
  cSpikeDamage = 50;
  cPoisonDamage = 2;

type
  TCombatMap = array [1..CombatXMax, 1..CombatYMax] of byte;

  TCombatDef = record
    cmap: TCombatMap;
    startpos: array [1..2, 1..12] of record
      x, y: byte;
    end;
  end;

  TCombatDefs = array [1..NumCombatDefs] of TCombatDef;
  PCombatDefs = ^TCombatDefs;

  TSideVars = record
    Dude: integer;
    HWent: boolean;
    HSpeed: integer;
    HKills: integer;
    HRoundSP: integer;
    HSpell: integer;
    HSpellCost: integer;
    Courage: byte;
    FieryGloves: boolean;
    AI: boolean;
    DarkArts: integer;
    Archery: integer;
    FlyersHelm, ArchersHelm, WalkersHelm, HeartsHelm: byte;
  end;

  TStatHints = array [1..2, 0..5] of string;
  PStatHints = ^TStatHints;

var
  CombatDefs: PCombatDefs;

  StatHints: PStatHints;
  SlotTop: array [1..2] of integer;
  TopStatsStack, TopStatsSP: integer;

type
  TSFX = record
    sp: byte;
    dur: byte;
    v: integer;
    side: byte;
  end;

const
  cmGrass = 0;
  cmFire = 1;
  cmWater = 2;
  cmEmptyMax = 3;

  cmTwisty2 = 5;
  cmGreenMountain = 6;
  cmSnowyPineTree = 7;
  cmOakTree = 8;
  cmPineTree = 9;
  cmJungleTree = 10;
  cmMountain = 11;
  cmHill = 12;
  cmSnowyMountain = 13;
  cmTwistyTree = 14;
  cmWillowTree = 15;
  cmElmTree = 16;
  cmWall = 17;
  cmBarbican = 18;
  cmSpellTower = 19;
  cmGate1 = 20;
  cmGate8 = 27;
  cmFlooder = 28;
  cmFan = 29;
  cmOpeningGate = 30;

  cmBranchTree = 31;
  cmBush = 32;
  cmBirchTree = 33;
  cmSnowTreeMountain = 34;
  cmRocky = 35;
  cmFlower1 = 36;
  cmFlower2 = 37;
  cmFlower3 = 38;
  cmBigMountain1 = 39;
  cmBigMountain2 = 40;
  cmBigMountain3 = 41;
  cmChasm = 42;

  cmUnremovable = [0..cmEmptyMax, cmChasm, cmBigMountain1, cmBigMountain2,
                   cmBigMountain3];
  cmTrees = [cmOakTree, cmPineTree, cmJungleTree, cmTwistyTree,
             cmWillowTree, cmElmTree, cmTwisty2, cmSnowyPineTree,
             cmBranchTree, cmBush, cmBirchTree];

  clMonster1 = 128;
  clLastMonster1 = clMonster1 + 59;
  clHero1 = clMonster1 + 60;
  clBow1 = clMonster1 + 61;

  clMonster2 = clMonster1 + 62;
  clLastMonster2 = clMonster2 + 59;
  clHero2 = clMonster2 + 60;
  clBow2 = clMonster2 + 61;

  clMisc = 0;
  clDamage = clMisc;
  clHeal = clMisc + 1;
  clFire = clMisc + 2;
  clPoison = clMisc + 3;
  clSwarm = clMisc + 4;
  clArrowTower = clMisc + 5;
  clSpellTower = clMisc + 6;
  clGate = clMisc + 7;
  clOpenGate = clMisc + 8;
  clFlood = clMisc + 9;
  clFan = clMisc + 10;
  clWandofBless = clMisc + 11;
  clWandofCurse = clMisc + 12;
  clWandofPain = clMisc + 13;
  clWandofHealth = clMisc + 14;
  clScrollofMagicBow = clMisc + 15;
  clScrollofFireBolt = clMisc + 16;
  clScrollofRenew = clMisc + 17;
  clBowOfEvil = clMisc + 18;
  clSpikedShield = clMisc + 19;
  clScrollofZap = clMisc + 20;
  clScrollofTraitor = clMisc + 21;
  clScrollofVampire = clMisc + 22;
  clWandOfDesertion = clMisc + 23;
  clWandOfEndlessCurses = clMisc + 24;

  fxSword = 1;
  fxHourglass = 2;
  fxBolt = 3;
  fxDeath = 4;
  fxHeal = 5;
  fxCast = 6;

  CombatIcons: array [1..6] of TGraphic =
  (
    ('........**',
     '.......*.*',
     '......*.*.',
     '*....*.*..',
     '**..*.*...',
     '.***.*....',
     '..*.*.....',
     '.****.....',
     '***.**....',
     '**...**...'),
    ('..........',
     '.*******..',
     '.*.....*..',
     '..*...*...',
     '...*.*....',
     '....*.....',
     '...*.*....',
     '..*...*...',
     '.*.....*..',
     '.*******..'),
    ('......*...',
     '.....**...',
     '....**....',
     '...***....',
     '..******..',
     '..******..',
     '....***...',
     '....**....',
     '...**.....',
     '...*......'),
    ('..*****...',
     '.*******..',
     '**  *  **.',
     '*********.',
     '**** ****.',
     '.*** ***..',
     '..*****...',
     '..*   *...',
     '..*****...',
     '..........'),
    ('....*.....',
     '.*..*..*..',
     '..*****...',
     '..*****...',
     '*********.',
     '..*****...',
     '..*****...',
     '.*..*..*..',
     '....*.....',
     '..........'),
    ('....*....*',
     '.....*.*..',
     '...*.....*',
     '.......*..',
     '....**....',
     '....**..*.',
     '...*......',
     '..*.......',
     '.*........',
     '*.........')
  );

  IconTime: array [1..6] of integer =
  (
    32, 33, 28, 52, 37, 16
  );

procedure GetSlotXY(slot: integer; var x, y: integer);
procedure DrawCombatIcon(x, y, ic: integer; ghost: boolean);
procedure DrawCombatTerrain(x, y, t, shad, wn, backcol: integer);
procedure Highlight(x, y: integer; ghost, isactual: boolean);
procedure HighlightAwhile(x, y: integer; isactual: boolean);
procedure GetSpellStrings(sfx: TSFX; var s, s2: string; var c: integer);

procedure ResetCombatLog;
procedure AddCombatLogLine(s: string);
procedure DrawCombatLog;

procedure FillSideVars(var SV: TSideVars);
procedure MakeSpellList(var SV: TSideVars; var SpellList: TSpellList);
procedure EraseStats(slot: integer);
procedure ActuallyShowHeroStats(SV: TSideVars; SL: TSpellList; splev: integer);

implementation

uses XSVGA, XStrings, Map, Monsters, Artifact, Heroes, Players;

procedure GetSlotXY(slot: integer; var x, y: integer);
  var j: integer;
  begin
    if slot = 1 then j := 6 else j := 10;
    GetCombatHexXY(14, j, x, y);
  end;

procedure DrawCombatIcon(x, y, ic: integer; ghost: boolean);
  const
    colors: array [boolean, 1..2] of byte =
    (
      (colDarkGray, colWhite), (colBlack, colDarkGray)
    );
  var
    i, j: integer;
  begin
    GetCombatHexXY(x, y, i, j);
    DrawTallIconBox(i, j, colors[ghost, 1]);
    DrawGraphic(i + 3, j + 3, colors[ghost, 2], CombatIcons[ic], false);
  end;

function DarkerShade(c: integer): integer;
  begin
    case c of
{     colBlue:       c := colDarkBlue; }
      colRed:        c := colDarkRed;
      colGreen:      c := colDarkGreen;
      colJungle:     c := colJungleShadow;
{     colSnow:       c := colSnowShadow; }
      colDesolate:   c := colDesolateShadow;
      colTemperate2: c := colDarkGreen;
      colDarkBlue:   c := colDarkDarkBlue;
      colCombatSnow: c := colSnowShadow;
    end;

    DarkerShade := c;
  end;

{ !X! largely redundant with Map unit, but no easy fix }

type
  TCombatWaterGrid = array [1..10, 1..10] of byte;
  PCombatWaterGrid = ^TCombatWaterGrid;

var
  CWG: TCombatWaterGrid;

const
  wgChasm = -1;
  wgWater = 0;

  WaterGridDef: TCombatWaterGrid =
  (
    ($02, $02, $02, $02,  $06,  $06, $04, $04, $04, $00),
    ($00, $02, $02, $06,  $0E,  $0E, $0C, $0C, $0C, $00),
    ($01, $03, $03, $47,  $7F,  $4E, $0E, $0C, $08, $00),
    ($01, $01, $47, $47,  $7F,  $4E, $4E, $0C, $08, $00),

    ($01, $01, $47, $47,  $7F,  $4E, $4E, $0C, $08, $00),
    ($01, $21, $71, $71,  $7F,  $78, $78, $08, $08, $00),

    ($01, $21, $71, $71,  $7F,  $78, $78, $08, $08, $00),
    ($01, $21, $31, $71,  $7F,  $78, $18, $18, $08, $00),
    ($21, $21, $21, $31,  $31,  $30, $10, $10, $00, $00),
    ($20, $20, $20, $30,  $30,  $10, $10, $10, $10, $00)
  );

procedure MakeCombatWaterGrid(gx, gy, md, wn: integer; sh: boolean;
                              backcol: integer);

  procedure ApplyGrid(wgg: PCombatWaterGrid; pn, c: integer);
    var
      x, y: integer;
    begin
      for x := 1 to 9 do
        for y := 1 to 10 do
          if (wgg^[y, x] and pn) <> 0 then
            CWG[x, y] := c;

      if (pn and $03) = $03 then CWG[1, 2] := c;
      if (pn and $18) = $18 then CWG[9, 9] := c;
    end;

  procedure RandomConvertPixs(num, c1, c2: integer);
    var
      rs: longint;
      i, rx, ry: integer;
    begin
      rs := randseed;
      randseed := (gx * longint(256) * 13 + gy * 17) div 2;
      for i := 1 to num do begin
        rx := random(9) + 1;
        ry := random(10) + 1;
        if CWG[rx, ry] = c1 then CWG[rx, ry] := c2;
      end;
      randseed := rs;
    end;

  procedure RandomStar;
    var
      rs: longint;
      rx, ry, i, j, ct: integer;
    begin
      rs := randseed;
      randseed := (gx * longint(256) * 13 + gy * 17) div 2;
      rx := random(5) + 3;
      ry := random(6) + 3;
      ct := 0;
      for i := -2 to 2 do
        for j := -2 to 2 do
          if CWG[rx + i, ry + j] <> colBlack then inc(ct);
      if ct = 0 then begin
        if random(12) = 0 then begin
          CWG[rx, ry] := colLightGray;
          CWG[rx - 1, ry] := colDarkGray;
          CWG[rx + 1, ry] := colDarkGray;
          CWG[rx, ry - 1] := colDarkGray;
          CWG[rx, ry + 1] := colDarkGray;
        end else begin
          CWG[rx, ry] := colDarkGray;
        end;
      end;
      randseed := rs;
    end;

  procedure ReplaceColor(c1, c2: integer);
    var x, y: integer;
    begin
      for x := 1 to 9 do
        for y := 1 to 10 do
          if CWG[x, y] = c1 then
            CWG[x, y] := c2;
    end;

  procedure AddCliffs;

    procedure CliffLine(cx, cy: integer);
      begin
        CWG[cx, cy] := colDesolateShadow;
        if (cx < 9) and (cy < 10)
           and (CWG[cx + 1, cy + 1] = colBlack) then begin
          CWG[cx + 1, cy + 1] := colDesolateShadow2;
          if (cx < 8) and (cy < 9)
             and (CWG[cx + 2, cy + 2] = colBlack) then
            CWG[cx + 2, cy + 2] := colDesolateShadow3;
        end;
      end;

    var x, y: integer;
    begin
      for x := 1 to 8 do
        for y := 1 to 9 do
          if (CWG[x, y] = colGreen)
             and (CWG[x + 1, y + 1] = colBlack) then
            CliffLine(x + 1, y + 1);
      if (wn and $01) = 0 then
        for y := 1 to 10 do
          if CWG[1, y] = colBlack then
            CliffLine(1, y);
      if (wn and $06) = 0 then
        for x := 1 to 9 do
          if CWG[x, 1] = colBlack then
            CliffLine(x, 1);

      if ((wn and $04) <> 0) and ((wn and $02) = 0) then begin
        x := 1;
        while CWG[x, 1] = colGreen do inc(x);
        CWG[x, 1] := colDesolateShadow;
        CWG[x + 1, 1] := colDesolateShadow2;
        CWG[x + 1, 2] := colDesolateShadow2;
        CWG[x + 2, 1] := colDesolateShadow3;
        CWG[x + 2, 2] := colDesolateShadow3;
        CWG[x + 2, 3] := colDesolateShadow3;
        CWG[x + 3, 1] := colDesolateShadow3;
      end;

      if ((wn and $01) <> 0) and ((wn and $02) = 0) then begin
        y := 1;
        while CWG[1, y] = colGreen do inc(y);
        CWG[1, y] := colDesolateShadow2;
        CWG[1, y + 1] := colDesolateShadow3;
        CWG[2, y + 1] := colDesolateShadow3;
      end;
    end;

  procedure WaterBase(wm, wc: integer);
    begin
      ApplyGrid(@WaterGridDef, wn, wc);
    end;

  var sx, sy: integer;
  begin
    FillChar(CWG, sizeof(CWG), chr(colGreen));
    wn := wn or $40;

    case md of
      cmWater: WaterBase(cmWater, colDarkBlue);
      cmFire:  WaterBase(cmFire, colRed);
      cmChasm: begin
                 WaterBase(cmChasm, colBlack);
                 AddCliffs;
                 RandomStar;
               end;
    end;

    ReplaceColor(colGreen, backcol);

    if sh then begin
      for sx := 1 to 9 do
        for sy := 1 to 10 do
          CWG[sx, sy] := DarkerShade(CWG[sx, sy]);
    end;
  end;

procedure DrawCombatWaterGrid(x, y: integer);
  var dwi, dwj, dx, dy: integer;
  begin
    for dwi := 1 to 9 do
      for dwj := 1 to 10 do begin
        dx := x + (dwi - 1) * 4;
        dy := y + (dwj - 1) * 4;
        XPut4x4Pixels(dx, dy, CWG[dwi, dwj]);
      end;
  end;

const
  CombatGrs: array [17..30] of TGraphic =
  (
    ('..........', { wall }
     '**********',
     '*  *  *  *',
     '**********',
     '* *  *  **',
     '**********',
     '*  *  *  *',
     '**********',
     '* *  *  **',
     '**********'),
    ('..........', { barbican }
     '..*.*.*...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...'),
    ('..........', { spell tower }
     '..*.*.*...',
     '..*****...',
     '..* ***...',
     '..* * *...',
     '..**  *...',
     '..*  **...',
     '..* * *...',
     '..*** *...',
     '..*****...'),
    ('..........', { gate 1 }
     '..........',
     '.......*..',
     '.*.....*..',
     '.***...**.',
     '...*...*..',
     '...**.***.',
     '.*.*.*.*..',
     '****.*.*..',
     '.*.*.*.*..'),
    ('..........', { gate 2 }
     '..........',
     '.......*..',
     '.*.....*..',
     '******.**.',
     '...*.*.*..',
     '...******.',
     '.*.*.*.*..',
     '****.*.*..',
     '.*.*.*.*..'),
    ('..........', { gate 3 }
     '.......*..',
     '**....**..',
     '.*...*.*..',
     '******.**.',
     '...*.*.*..',
     '...******.',
     '.*.*.*.*..',
     '****.*.*..',
     '.*.*.*.*..'),
    ('..........', { gate 4 }
     '.......*..',
     '**..****..',
     '.*...*.*..',
     '******.**.',
     '...*.*.*..',
     '.*.******.',
     '.*.*.*.*..',
     '****.*.**.',
     '.*.*.*.*..'),
    ('..........', { gate 5 }
     '.....*.*..',
     '***.*****.',
     '.*...*.*..',
     '******.**.',
     '...*.*.*..',
     '.*.******.',
     '.*.*.*.*..',
     '****.*.**.',
     '.*.*.*.*..'),
    ('..........', { gate 6 }
     '.*...*.*..',
     '***.*****.',
     '.*.*.*.*..',
     '******.**.',
     '...*.*.*..',
     '.********.',
     '.*.*.*.*..',
     '****.****.',
     '.*.*.*.*..'),
    ('..........', { gate 7 }
     '.*...*.*..',
     '*********.',
     '.*.*.*.*..',
     '******.**.',
     '.*.*.*.*..',
     '.********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..'),
    ('..........', { gate 8 }
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..'),
    ('..........', { flooder }
     '...*...*..',
     '..*.*.....',
     '....*.*...',
     '.*..**.*..',
     '....**....',
     '....**....',
     '...****...',
     '.********.',
     '**********'),
    ('.....*....', { fan }
     '....***...',
     '...*  **..',
     '...**  *..',
     '...*  **..',
     '...**  *..',
     '....***...',
     '.....*....',
     '....***...',
     '..******..'),
    ('..........', { opening gate }
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..',
     '*********.',
     '.*.*.*.*..')
  );
  ForeColor: array [17..30] of byte =
  (
    colLightGray, colWhite, colRed,
    colDarkGray, colDarkGray, colDarkGray, colDarkGray,
    colDarkGray, colDarkGray, colDarkGray, colDarkGray,
    colBlue, colLightGray, colBlack
  );
  BackColor: array [17..30] of byte =
  (
    colDarkGray, colBlack, colDarkRed,
    colBlack, colBlack, colBlack, colBlack,
    colBlack, colBlack, colBlack, colBlack,
    colBlack, colDarkGray, colBlack
  );

procedure DrawCombatTerrain(x, y, t, shad, wn, backcol: integer);
  const
    Obstacles: array [5..16] of byte =
    (
      mgTwisty2, mgGreenMountain, mgSnowyPineTree,
      mgOakTree, mgPineTree, mgJungleTree, mgMountain,
      mgHill, mgSnowyMountain, mgTwistyTree, mgWillowTree,
      mgElmTree
    );
    Obstacles2: array [31..41] of byte =
    (
      mgBranchTree, mgBush, mgBirchTree, mgSnowTreeMountain,
      mgRocky, mgFlower1, mgFlower2, mgFlower3,
      mgBigMountain1, mgBigMountain2, mgBigMountain3
    );
  var
    c, gr: integer;
  begin
    if (t in [cmWater, cmFire, cmChasm]) and (shad <> 0) then begin
      MakeCombatWaterGrid(x, y, t, wn, shad = 1, backcol);
      DrawCombatWaterGrid(x, y);
      if t <> cmChasm then
        XRectangle(x, y, x + 35, y + 39, colLightGray);
    end else begin
      if shad = 0 then
        c := colBlack
      else if shad <> 1 then
        c := backcol
      else
        c := DarkerShade(backcol);

      XFillArea(x + 1, y + 1, x + 34, y + 38, c);
      if t <> cmGrass then XRectangle(x, y, x + 35, y + 39, backcol);

      if (t in [cmBigMountain1, cmBigMountain2, cmBigMountain3])
         and (x < 496) then begin
        case t of
          cmBigMountain1: inc(y, 5);
          cmBigMountain2: begin inc(x, 3); dec(y, 5); end;
          cmBigMountain3: begin dec(x, 3); dec(y, 5); end;
        end;
        DrawGraphic256c(x + 3, y + 5, MapGraphics^[Obstacles2[t]]);
      end else if t >= low(Obstacles) then begin
        gr := 0;
        if t <= high(Obstacles) then
          gr := Obstacles[t]
        else if t >= low(Obstacles2) then
          gr := Obstacles2[t];
        if gr <> 0 then begin
          if t in [cmSnowyPineTree, cmBirchTree, cmSnowTreeMountain, cmOakTree,
                   cmBigMountain1, cmBigMountain2, cmBigMountain3,
                   cmFlower1, cmFlower2, cmFlower3, cmRocky] then
            DrawGraphic256c(x + 3, y + 5, MapGraphics^[gr])
          else
            DrawGraphic2c(x + 3, y + 5, MapForeColor[gr], MapBackColor[gr],
                          MapGraphics^[gr], false);
        end else
          DrawGraphic2c(x + 3, y + 5, ForeColor[t], BackColor[t],
                        CombatGrs[t], false);
      end;
    end;
  end;

procedure Highlight(x, y: integer; ghost, isactual: boolean);
  const
    colors: array [boolean] of byte = (colWhite, colLightGray);
    togct: integer = 0;
  var
    i, j, m, n, tog: integer;
    c: boolean;
    highlightbuf: array [0..35, 0..39] of byte;

  procedure HPutPixel(hx, hy, hc: integer);
    begin
      if ghost then
        highlightbuf[hx - m, hy - n] := hc
      else
        XPutPixel(hx, hy, hc);
    end;

  begin
    if isactual then begin
      togct := (togct + 1) mod 512;
      tog := togct div 128;
      GetCombatHexXY(x, y, m, n);
      fillchar(highlightbuf, sizeof(highlightbuf), colInvisible);

      for i := m to m + 35 do begin
        c := ((i + 4 - tog) div 2) mod 2 = 0;
        HPutPixel(i, n, colors[c]);
        c := ((i + tog) div 2) mod 2 = 0;
        HPutPixel(i, n + 39, colors[c]);
        if (i > m) and (i < m + 35) then begin
          c := ((i + 4 - tog) div 2) mod 2 = 0;
          HPutPixel(i, n + 1, colors[not c]);
          c := ((i + tog) div 2) mod 2 = 0;
          HPutPixel(i, n + 38, colors[not c]);
        end;
      end;

      for j := n + 1 to n + 38 do begin
        c := ((j + tog + 1) div 2) mod 2 = 0;
        HPutPixel(m, j, colors[c]);
        c := ((j + 4 - tog + 3) div 2) mod 2 = 0;
        HPutPixel(m + 35, j, colors[c]);
        if (j > n + 1) and (j < n + 38) then begin
          c := ((j + tog + 1) div 2) mod 2 = 0;
          HPutPixel(m + 1, j, colors[not c]);
          c := ((j + 4 - tog + 3) div 2) mod 2 = 0;
          HPutPixel(m + 34, j, colors[not c]);
        end;
      end;

      if ghost then begin
        for j := 0 to 39 do
          for i := 0 to 35 do
            if highlightbuf[i, j] <> colInvisible then
              SPutPixel(m + i, n + j, highlightbuf[i, j]);
        if ((m + 0) + (n + 0) * longint(640)) div 65536
           = ((m + 35) + (n + 39) * longint(640)) div 65536 then
          for i := 1 to 2 do
            SetBank(CurrentBank);
      end;
    end;
  end;

procedure HighlightAwhile(x, y: integer; isactual: boolean);
  var n: integer;
  begin
    if isactual then
      for n := 1 to HighlightDelay do begin
        Highlight(x, y, false, isactual);
        RefreshScreen;
      end;
  end;

procedure GetSpellStrings(sfx: TSFX; var s, s2: string; var c: integer);
  begin
    with sfx do
      if sp <> 0 then begin
        if sp = spIceBolt then begin
          s := 'Freezing';
          s2 := 'Stack has -2 speed for ';
          if dur = 1 then
            s2 := s2 + 'one round.'
          else
            s2 := s2 + IStr(dur, 0) + ' rounds.';
        end else begin
          s := SpellData[sp].name;
          s2 := SpellHint(sp, v, dur);
        end;
        if dur > 0 then begin
          s := s + ' (' + IStr(dur, 0) + ') ';
          case sp of
            spGrow, spFury, spAgility, spJoy:
              s := s + '(+' + IStr(v, 0) + '%)';
            spShrink, spWeakness, spFatigue, spWoe:
              s := s + '(-' + IStr(v, 0) + '%)';
            spSwarm:
              s := s + '(' + IStr(v, 0) + ' dmg)';
          end;
        end;
        c := SpellSlantColor[SpellData[sp].slant];
      end;
  end;

{ combat log routines }

{
  123456789012345678901

  < hits < for 10000#    [use tiny monster graphic, w/ color for side!]
  < hits <, kills 10000
  < hits <
  < casts ............
  < deals 100# to all

  monster special abilities
    smashes obstacle
    makes fire/water?
    throws/pushes/circles/bounces monster
    stuns/hexes/devolves/splits/poisons monster
    blinks/splits/feeds on dead
    removes flags
    copies flags
    raises dead
    morale attack
    regenerates/heals
    casts blessing
    improves w/ damage/rounds/spells
    makes mana

  bow of force
  fiery titan fire
  terrain shield
}

const
  CombatLogLines = 10;

var
  CombatLog: array [1..CombatLogLines] of string[21];
  CombatLogIdx: integer;

procedure ResetCombatLog;
  var i: integer;
  begin
    CombatLogIdx := 0;
    for i := 1 to CombatLogLines do
      CombatLog[i] := '';
  end;

procedure AddCombatLogLine(s: string);
  var i: integer;
  begin
    if CombatLogIdx < CombatLogLines then begin
      inc(CombatLogIdx);
      CombatLog[CombatLogIdx] := s;
    end else begin
      for i := 2 to CombatLogLines do
        CombatLog[i - 1] := CombatLog[i];
      CombatLog[CombatLogLines] := s;
    end;
  end;

const
  clColor = colDarkDarkGray; {colTans + 1}{colLightMagentas + 2}
  clText = colGrays + 3;

procedure DrawCombatLogLine(x, y: integer; s: string);
  var i, x2: integer;

  procedure DrawSmallArt(a: integer);
    begin
      DrawSmallGraphic2c(x2 - 1, y - 1, ArtData[a].fcol, ArtData[a].bcol,
                         ArtGraphics[ArtData[a].gr]);
    end;

  procedure DrawSmallCombatGr(cg: integer);
    begin
      DrawSmallGraphic2c(x2 - 1, y - 1, ForeColor[cg], BackColor[cg],
                         CombatGrs[cg]);
    end;

  begin
    for i := 1 to length(s) do begin
      x2 := x + (i - 1) * 8;
      if x2 <= 630 then begin
        if (ord(s[i]) >= 32) and (ord(s[i]) < 128) then begin
          if s[i] = ',' then
            DrawChar(x2 + 1, y + 1, clColor, clText, s[i])
          else if s[i] <> ' ' then
            DrawChar(x2, y, clColor, clText, s[i]);
        end else begin
          case ord(s[i]) of
            clMonster1..clLastMonster1:
              DrawSmallGraphic2c(x2 - 1, y - 1, colFriend, colBlack,
                                 MonsterGraphic(ord(s[i]) - clMonster1 + 1)^);
            clMonster2..clLastMonster2:
              DrawSmallGraphic2c(x2 - 1, y - 1, colEnemy, colBlack,
                                 MonsterGraphic(ord(s[i]) - clMonster2 + 1)^);
            clHero1: DrawSmallGraphic2c(x2 - 1, y - 1, colBrown, colFriend,
                                        MapGraphics^[mgHero]);
            clHero2: DrawSmallGraphic2c(x2 - 1, y - 1, colBrown, colEnemy,
                                        MapGraphics^[mgHero]);
            clBow1:  DrawSmallGraphic2c(x2 - 1, y - 1, colFriend, colBlack,
                                        ArtGraphics[agBow]);
            clBow2:  DrawSmallGraphic2c(x2 - 1, y - 1, colEnemy, colBlack,
                                        ArtGraphics[agBow]);
            clDamage: DrawSmallGraphic2c(x2 - 1, y - 1, colWhite, colBlack,
                                         CombatIcons[fxBolt]);
            clHeal:   DrawSmallGraphic2c(x2 - 1, y - 1, colWhite, colBlack,
                                         CombatIcons[fxHeal]);
            clFire:   XFillArea(x2 - 1, y - 1, x2 - 1 + 9, y - 1 + 9, colRed);
            clPoison: DrawSmallGraphic2c(x2 - 1, y - 1, colBlack, colBlack,
                                         MonsterGraphic(moScorpion)^);
            clSwarm:  DrawSmallGraphic2c(x2 - 1, y - 1, colBlack, colBlack,
                                         MonsterGraphic(moMosquitoCloud)^);
            clArrowTower: DrawSmallCombatGr(cmBarbican);
            clSpellTower: DrawSmallCombatGr(cmSpellTower);
            clGate:       DrawSmallCombatGr(cmGate8);
            clOpenGate:   DrawSmallCombatGr(cmOpeningGate);
            clFlood:      DrawSmallCombatGr(cmFlooder);
            clFan:        DrawSmallCombatGr(cmFan);
            clWandofBless: DrawSmallArt(anWandofBlessings);
            clWandofCurse: DrawSmallArt(anWandofCurses);
            clWandofPain:  DrawSmallArt(anWandofPain);
            clWandofHealth: DrawSmallArt(anWandofHealth);
            clScrollofMagicBow: DrawSmallArt(anScrollofMagicBow);
            clScrollofFireBolt: DrawSmallArt(anScrollofFireBolt);
            clScrollofRenew:    DrawSmallArt(anScrollofRenew);
            clScrollofZap:      DrawSmallArt(anScrollofZap);
            clScrollofTraitor:  DrawSmallArt(anScrollofTraitor);
            clScrollofVampire:  DrawSmallArt(anScrollofVampire);
            clBowOfEvil:    DrawSmallArt(anBowofEvil);
            clSpikedShield: DrawSmallArt(anSpikedShield);
            clWandOfDesertion:     DrawSmallArt(anWandOfDesertion);
            clWandOfEndlessCurses: DrawSmallArt(anWandOfEndlessCurses);
          end;
        end;
      end;
    end;
  end;

procedure DrawCombatLog;
  var
    x, y, i: integer;
  begin
    GetSlotXY(2, x, y);
    XFillArea(x - 1 - 1, y - 10 - 1, 639, y + 5 * 13 + 43 + 8 + 1, clColor);

    for i := 1 to CombatLogLines do
      DrawCombatLogLine(x, y - 9 + (i - 1) * 13, CombatLog[i]);
  end;

procedure FillSideVars(var SV: TSideVars);
  begin
    with SV do
      if Dude <> 0 then begin
        HSpeed := 50 + GetEffSkillLevel(Dude, skWizardry) * 20
                  + 10 * Player[Hero^[Dude].player].SpellMines[smShaman];
        HKills := 0;
        HSpell := 0;
        HSpellCost := 0;
        FieryGloves := HasArt(Dude, anGlovesOfTheFieryTitan, true);
        Courage := CountArt(Dude, anGlovesOfCourage, true);
        FlyersHelm := CountArt(Dude, anFlyersHelm, true);
        ArchersHelm := CountArt(Dude, anArchersHelm, true);
        WalkersHelm := CountArt(Dude, anWalkersHelm, true);
        HeartsHelm := CountArt(Dude, anHeartsHelm, true);
        DarkArts := GetEffSkillLevel(Dude, skDarkArts);
        Archery := GetEffSkillLevel(Dude, skArchery);
        AI := Player[Hero^[Dude].player].AI;
      end else begin
        FieryGloves := false;
        FlyersHelm := 0;
        ArchersHelm := 0;
        WalkersHelm := 0;
        HeartsHelm := 0;
        Courage := 0;
        DarkArts := 0;
        Archery := 0;
        AI := true;
      end;
  end;

procedure MakeSpellList(var SV: TSideVars; var SpellList: TSpellList);
  var i, n: integer;
  begin
    FillChar(SpellList, sizeof(SpellList), #0);

    n := 1;
    for i := 1 to NumSpells do
      if CheckForSpell(Hero^[SV.Dude].SS, i)
         and (Hero^[SV.Dude].SP >= EffSpellCost(SV.Dude, i)) then begin
        SpellList[n] := i;
        inc(n);
      end;
  end;

procedure EraseStats(slot: integer);
  var x, y, y2, i: integer;
  begin
    GetSlotXY(slot, x, y);
    y2 := y + 5 * 13 + 43 + 8;
    if slot = 1 then inc(y2, 2 * 13);
    ClearArea(x - 1 - 1, y - 10 - 1, 639, y2 + 1);

    for i := 0 to 5 do StatHints^[slot, i] := '';
    if slot = 1 then TopStatsStack := 0;
  end;

procedure ActuallyShowHeroStats(SV: TSideVars; SL: TSpellList; splev: integer);
  var
    x, y, sx, sy, i, j, sp, fc, bc, v, t, esc, sc: integer;
    s: string;

  procedure DrawStatTitle(s: string);
    begin
      DrawText(x + 40, y + 8, colBlack, colLightGray, s);
    end;

  begin
    TopStatsSP := splev;
    GetSlotXY(1, x, y);
    EraseStats(1);
    DrawTallIconBox(x, y, colDarkGray);
    DrawHero(x, y + 2, colDarkGray, SV.Dude);
    XRectangle(x, y, x + 35, y + 39, colLightGray);
    DrawText(x, y - 10, colBlack, colLightGray, Hero^[SV.Dude].name);

    if splev < 0 then begin
      DrawStatTitle('Archery ' + IStr(-splev, 0));
      DrawText(x + 40, y + 24, colBlack, colLightGray,
               IStr(-splev * cArcheryDamage, 0) + ' damage');
    end else if splev > 128 then begin
      DrawText(x + 40, y + 8, colDarkGray, colLightGray,
               'Spells Page ' + IStr((splev - 128 - 1) div 8 + 1, 0));
      DrawText(x + 40, y + 24, colBlack, colWhite,
               'SP: ' + IStr(SV.HRoundSP, 0) + ' / '
               + IStr(Hero^[SV.Dude].SP, 0));
      for i := 1 to 8 do begin
        j := (splev - 128) + i - 1;
        if j <= NumSpells then
          sp := SL[j]
        else
          sp := 0;
        if sp <> 0 then begin
          sx := x;
          sy := y + 43 + (i - 1) * 13;
          fc := SpellSlantColor[SpellData[sp].slant];
          bc := colDarkGray;
          esc := EffSpellCost(SV.Dude, sp);
          DrawText(sx, sy, bc, fc, LSet(SpellData[sp].name, 12));
          if SV.HRoundSP < esc then
            sc := colLightGray
          else
            sc := colWhite;
          DrawText(sx + 13 * 8, sy, colBlack, sc, IStr(esc, 0));
          v := HeroSpellValue(SV.Dude, sp);
          s := SpellValueStr(sp, v);
          if s <> '' then
            DrawText(sx + 16 * 8, sy, colBlack, sc, s);
        end;
      end;
    end else if splev = 128 then begin
      DrawStatTitle('Casting...');
    end else if splev = 127 then begin
      if SV.AI then s := 'Picking '  else s := 'Pick ';
      DrawStatTitle(s + 'Location');
    end else if splev = 126 then begin
      DrawStatTitle('Picking Spell...');
    end else begin
      sc := SpellSlantColor[SpellData[splev].slant];
      DrawText(x + 40, y + 8, colBlack, sc, SpellData[splev].name);
      if SpellData[splev].targets then begin
        if SV.AI then
          s := 'Choosing Targets'
        else begin
          t := SpellMaxTargets(splev, SV.Dude);
          if t = 1 then
            s := 'Choose Target'
          else
            s := 'Choose ' + IStr(t, 0) + ' Targets';
        end;
        DrawText(x + 40, y + 24, colBlack, sc, s);
      end;
    end;
  end;

{ init functions }

procedure LoadCombatDefs;
  var
    f: file;
    result: word;
  begin
    assign(f, 'COMBDEFS.DAT');
    reset(f, 1);
    BlockRead(f, CombatDefs^, sizeof(CombatDefs^), result);
    close(f);
  end;

procedure LoadConfig;
  var
    f: text;
    s: string;
    n: longint;
  begin
    assign(f, 'CONFIG.DAT');
    reset(f);
    readln(f, s);
    n := IVal(s);
    readln(f, s);
    ScrollDelay := IVal(s);
    close(f);

    MoveGhostDelay := (MoveGhostDelay * n) div 100;
    HighlightDelay := (HighlightDelay * n) div 100;
    BlowDelay := (BlowDelay * n) div 100;
    FXDelay := (FXDelay * n) div 100;
  end;

{ unit initialization }

begin
  New(CombatDefs);
  LoadCombatDefs;
  LoadConfig;
  New(StatHints);
end.
