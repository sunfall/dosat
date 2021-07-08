unit combgr;

{ combat graphics for hommx game }

interface

uses Combat;

const
  fxSword = 1;
  fxShield = 2;
  fxBolt = 3;
  fxDeath = 4;
  fxHeal = 5;
  fxCast = 6;

var
  XInDir, YInDir: array [1..(CombatXMax * CombatYMax), 1..6] of byte;

function FindAdjHex(n, x, y: integer; var i, j: integer): boolean;
function OnGrid(x, y: integer): boolean;
procedure PointToGrid(var x, y: integer);
function CombatHexX(x, y: integer): integer;
function CombatHexY(x, y: integer): integer;

procedure DrawCombatTerrain(x, y: integer; t: byte; shad: byte);
procedure DrawCombatHex(x, y: integer);
procedure DrawCombatScreen;
procedure Highlight(x, y: integer);
procedure Unhighlight(x, y: integer);
procedure DrawFX(x, y, fx: integer; wait: boolean);
procedure EraseStats(slot: integer);
procedure ShowStackStats(st, slot, sp: integer);
procedure ShowHeroStats(side, splev: integer);
procedure DrawCombatGrid;
procedure DrawCombatIcon(x, y, ic: integer; ghost: boolean);

procedure DebugText(x, y: integer; s: string);

implementation

uses Hexes, LowGr, Monsters, XStrings, Heroes, Spells, Map;

const
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
    ('***...***.',
     '*.*****.*.',
     '*.......*.',
     '*...*...*.',
     '*..***..*.',
     '*...*...*.',
     '.*.....*..',
     '..*...*...',
     '...*.*....',
     '....*.....'),
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

function FindAdjHex(n, x, y: integer; var i, j: integer): boolean;
  begin
    i := x;
    j := y;

    case n of
      1: dec(i);
      2: UpLeft(i, j);
      3: begin
           UpLeft(i, j);
           inc(i);
         end;
      4: inc(i);
      5: begin
           DownLeft(i, j);
           inc(i);
         end;
      6: DownLeft(i, j);
    end;

    FindAdjHex := OnGrid(i, j);
  end;

function OnGrid(x, y: integer): boolean;
  begin
    OnGrid := (x >= 1) and (x <= CombatXMax)
              and (y >= 1) and (y <= CombatYMax);
  end;

procedure PointToGrid(var x, y: integer);
  begin
    y := (y div 40) + 1;
    if y mod 2 = 1 then dec(x, 18);
    if x < 0 then
      x := 0
    else
      x := (x div 36) + 1;
  end;

function CombatHexX(x, y: integer): integer;
  var i: integer;
  begin
    i := (x - 1) * 36;
    if (y mod 2) = 1 then inc(i, 18);
    CombatHexX := i;
  end;

function CombatHexY(x, y: integer): integer;
  var i: integer;
  begin
    i := (y - 1) * 40;
    CombatHexY := i;
  end;

procedure DebugText(x, y: integer; s: string);
  begin
    DrawText(CombatHexX(x, y) + 2, CombatHexY(x, y) + 2, colBlack, colWhite, s);
  end;

procedure DrawCombatTerrain(x, y: integer; t: byte; shad: byte);
  const
    TerrainColors: array [0..2] of byte =
    (
      colGreen, colRed, colBlue
    );
    DarkColors: array [0..2] of byte =
    (
      colDarkGreen, colDarkRed, colDarkBlue
    );
    Obstacles: array [8..16] of byte =
    (
      mgOakTree, mgPineTree, mgJungleTree, mgMountain,
      mgHill, mgSnowyMountain, mgTwistyTree, mgWillowTree,
      mgElmTree
    );
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
      ('..........', { arrow tower }
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
  var
    c, gr: integer;
  begin
    if shad = 0 then
      c := colBlack
    else if t > 3 then
      c := colGreen
    else begin
      if shad = 1 then
        c := DarkColors[t]
      else
        c := TerrainColors[t];
    end;

    XFillArea(x + 1, y + 1, x + 34, y + 38, c);

    if t >= 8 then begin
      if t <= high(Obstacles) then begin
        gr := Obstacles[t];
        DrawGraphic2c(x + 3, y + 5, MapForeColor[gr], MapBackColor[gr],
                      MapGraphics[gr], false);
      end else
        DrawGraphic2c(x + 3, y + 5, ForeColor[t], BackColor[t],
                      CombatGrs[t], false);
    end;
  end;

procedure DrawMonster(st, i, j: integer);
  var
    f, c, cd: integer;
    inv: boolean;
    a: TArmy;
    mine, yours: boolean;
  begin
    if ACombat^.Stacks[st].side = 1 then begin
      c := colLightBlue;
      inv := false;
    end else begin
      c := colDarkGray;
      inv := true;
    end;

    a.monster := ACombat^.Stacks[st].monster;
    a.qty := ACombat^.Stacks[st].qty;

    mine := false;
    yours := (ACombat^.Stacks[st].hexed > 0)
             or (ACombat^.Stacks[st].stunned <> 0)
             or (ACombat^.Stacks[st].poison > 0);
    for f := 1 to MaxSFX do
      with ACombat^.Stacks[st].sfx[f] do
        if sp > 0 then
          if side = ACombat^.Stacks[st].side then
            mine := true
          else
            yours := true;

    if mine and yours then
      cd := colYellow
    else if mine then
      cd := colLightGreen
    else if yours then
      cd := colDarkRed
    else
      cd := colWhite;

    if a.qty > 0 then DrawArmy(i, j, c, cd, a, inv);
  end;

procedure DrawCombatHex(x, y: integer);
  var
    i, j, st, n, sh: integer;
  begin
    i := CombatHexX(x, y);
    j := CombatHexY(x, y);

    with ACombat^ do begin
      st := StacksGrid[x, y];

      sh := -1;
      for n := 1 to 4 do
        if (ACombat^.SpellTargets[n].x = x)
           and (ACombat^.SpellTargets[n].y = y) then
          sh := 0;
      if sh = -1 then
        if (Shadow[x, y] > 0) and (st = 0) then
          sh := 1
        else
          sh := 2;

      DrawCombatTerrain(i, j, CombatMap[x, y], sh);
{     if Shadow[x, y] > 0 then DrawSmallNumber(i, j + 2, Shadow[x, y]); }

      if st <> 0 then begin
        if Stacks[st].illusion <> 0 then
          DrawMonster(Stacks[st].illusion, i, j)
        else
          DrawMonster(st, i, j);
        if EffFlag(st, 3, f3Illusionist) then begin
          for n := 1 to StackMax do
            if (Stacks[n].qty > 0)
               and (Stacks[n].illusion = st) then
              DrawCombatHex(Stacks[n].x, Stacks[n].y);
        end;
      end;
    end;
  end;

procedure DrawFX(x, y, fx: integer; wait: boolean);
  var i, j, w, k: integer;
  begin
    i := CombatHexX(x, y);
    j := CombatHexY(x, y);

    if wait then
      k := FXDelay div IconTime[fx]
    else
      k := 1;

    for w := 1 to k do
      DrawGraphic(i + 3, j - 1 + 3, colWhite, CombatIcons[fx], false);
  end;

procedure DrawCombatGridHex(i, j: integer);
  var x, y, c: integer;
  begin
    x := CombatHexX(i, j);
    y := CombatHexY(i, j);
    if (ACombat^.TrackedStack <> 0)
       and (ACombat^.TrackedShadow[i, j] > 0) then
      c := colDarkGray
    else
      c := colLightGray;
    XRectangle(x, y, x + 35, y + 39, c);
  end;

procedure DrawCombatGrid;
  var i, j: integer;
  begin
    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        DrawCombatGridHex(i, j);
  end;

procedure DrawIconBox(i, j, bc: integer);
  var m: integer;
  begin
    XRectangle(i, j, i + 35, j + 39, colLightGray);
    XFillArea(i + 1, j + 1, i + 34, j + 38, bc);
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
    i := CombatHexX(x, y);
    j := CombatHexY(x, y);
    DrawIconBox(i, j, colors[ghost, 1]);
    DrawGraphic(i + 3, j + 3, colors[ghost, 2], CombatIcons[ic], false);
  end;

procedure DrawCombatScreen;
  var i, j: integer;
  begin
    DrawCombatGrid;
    for j := 1 to CombatYMax do
      for i := 1 to CombatXMax do
        DrawCombatHex(i, j);
    DrawCombatIcon(14, 2, fxSword, false);
    DrawCombatIcon(15, 2, fxCast, true);
    DrawCombatIcon(16, 2, fxShield, false);
  end;

procedure Highlight(x, y: integer);
  const tog: integer = 0;
  var i, j, m, n, c: integer;
  begin
    tog := 1 - tog;
    m := CombatHexX(x, y);
    n := CombatHexY(x, y);

    for i := m to m + 35 do begin
      if i mod 2 = tog then c := colWhite else c := colLightGray;
      XPutPixel(i, n, c);
      XPutPixel(i, n + 39, c);
      if c = colWhite then c := colLightGray else c := colWhite;
      XPutPixel(i, n + 1, c);
      XPutPixel(i, n + 38, c);
    end;

    for j := n to n + 39 do begin
      if j mod 2 = tog then c := colWhite else c := colLightGray;
      XPutPixel(m, j, c);
      XPutPixel(m + 35, j, c);
      if c = colWhite then c := colLightGray else c := colWhite;
      XPutPixel(m + 1, j, c);
      XPutPixel(m + 34, j, c);
    end;
  end;

procedure Unhighlight(x, y: integer);
  var i, j: integer;
  begin
    DrawCombatGridHex(x, y);
  end;

procedure GetSlotXY(slot: integer; var x, y: integer);
  var i, j: integer;
  begin
    i := 14;
    if slot = 1 then j := 6 else j := 10;

    x := CombatHexX(i, j);
    y := CombatHexY(i, j);
  end;

procedure EraseStats(slot: integer);
  var x, y, y2: integer;
  begin
    GetSlotXY(slot, x, y);
    y2 := y + 5 * 13 + 43 + 8;
    if slot = 1 then inc(y2, 2 * 13);
    ClearArea(x - 1, y - 10, 639, y2);
  end;

procedure ShowStackStats(st, slot, sp: integer);
  var
    x, y, l, k, d1, d2, m, msp: integer;
    s: string;

  procedure AddLine(s2: string; c: integer);
    begin
      if l < 6 then begin
        DrawText(x, y + 43 + l * 13, colBlack, c, s2);
        inc(l);
      end;
    end;

  begin
    with ACombat^ do begin
      if Stacks[st].illusion <> 0 then
        st := Stacks[st].illusion;

      GetSlotXY(slot, x, y);
      EraseStats(slot);

      DrawIconBox(x, y, colGreen);
      DrawMonster(st, x, y);

      m := Stacks[st].monster;
      if Stacks[st].qty >= 2 then
        s := MonsterData[m].pname
      else
        s := MonsterData[m].name;
      DrawText(x, y - 10, colBlack, colLightGray, s);

      if sp = 0 then begin
        DrawText(x + 40, y + 3, colBlack, colLightGray,
                 'Hits  = ' + IStr(Stacks[st].tophp, 0) + '/'
                 + IStr(EffHp(st), 0));
        d1 := EffMinDmg(st);
        d2 := EffMaxDmg(st);
        if d2 < d1 then d2 := d1;
        if d1 = d2 then
          s := IStr(d1, 0)
        else
          s := IStr(d1, 0) + '-' + IStr(d2, 0);
        DrawText(x + 40, y + 16, colBlack, colLightGray, 'Dmg   = ' + s);
        DrawText(x + 40, y + 29, colBlack, colLightGray,
                 'Speed = ' + IStr(EffSpeed(st, false), 0));
      end else begin
        DrawText(x + 40, y +  9, colBlack,
                 SpellSlantColor[SpellData[sp].slant], SpellData[sp].name);
        DrawText(x + 40, y + 22, colBlack,
                 SpellSlantColor[SpellData[sp].slant], 'Choose Target');
      end;

      l := 0;
      for k := 1 to FlagMax do
        if EffFlag(st, FlagBytes[k], FlagBits[k]) then
          AddLine(FlagNames[k], colLightGray);

      if m = moBunny then AddLine('Multiplies', colLightGray);
      if m = moLookout then AddLine('Pathfinding', colLightGray);

      if (SV[Stacks[st].side].Animism > (MonsterLevel(m) - 1) div 2)
         and (Stacks[st].cast = 0) then begin
        msp := MonsterSpell[MonsterLevel(m)];
        AddLine('Casts ' + SpellData[msp].name + ' ('
                + IStr(MonsterSpellValue(m, Stacks[st].qty, msp), 0) + '%)',
                colLightGray);
      end;

      if Stacks[st].stunned > 0 then AddLine('Stunned', colLightGray);
      if Stacks[st].hexed > 0 then AddLine('Hexed', colLightGray);
      if Stacks[st].poison > 0 then AddLine('Poisoned', colLightGray);

      for k := 1 to MaxSFX do
        with Stacks[st].sfx[k] do
          if sp <> 0 then begin
            s := SpellData[sp].name;
            if s = 'Ice Bolt' then s := 'Freezing';
            if dur > 0 then
              s := s + ' (' + IStr(dur, 0) + ')';
            AddLine(s, SpellSlantColor[SpellData[sp].slant]);
          end;
    end;
  end;

procedure ShowHeroStats(side, splev: integer);
  var
    x, y, sx, sy, i, j, sp, fc, bc, v, sorc, esc, sc: integer;
    s: string;
  begin
    with ACombat^ do begin
      GetSlotXY(1, x, y);
      EraseStats(1);
      DrawIconBox(x, y, colDarkGray);
      DrawHero(x, y + 2, colDarkGray, SV[side].Dude);
      XRectangle(x, y, x + 35, y + 39, colLightGray);
      DrawText(x, y - 10, colBlack, colLightGray, Hero^[SV[side].Dude].name);

      if splev < 0 then begin
        DrawText(x + 40, y + 8, colBlack, colLightGray,
                 'Archery ' + IStr(-splev, 0));
        DrawText(x + 40, y + 24, colBlack, colLightGray,
                 IStr(-splev * cArcheryDamage, 0) + ' damage');
      end else if splev > 128 then begin
        DrawText(x + 40, y + 8, colDarkGray, colLightGray,
                 'Spells Page ' + IStr((splev - 128 - 1) div 8 + 1, 0));
        DrawText(x + 40, y + 24, colBlack, colWhite,
                 'SP: ' + IStr(SV[side].HRoundSP, 0) + ' / '
                 + IStr(Hero^[SV[side].Dude].SP, 0));
        for i := 1 to 8 do begin
          j := (splev - 128) + i - 1;
          if j <= NumSpells then
            sp := SpellList[j]
          else
            sp := 0;
          if sp <> 0 then begin
            sx := x;
            sy := y + 43 + (i - 1) * 13;
            fc := SpellSlantColor[SpellData[sp].slant];
            bc := colDarkGray;
            esc := EffSpellCost(SV[side].Dude, sp);
            DrawText(sx, sy, bc, fc, LSet(SpellData[sp].name, 12));
            if SV[side].HRoundSP < esc then
              sc := colLightGray
            else
              sc := colWhite;
            DrawText(sx + 13 * 8, sy, colBlack, sc, IStr(esc, 0));
            v := HeroSpellValue(SV[side].Dude, sp);
            s := SpellValueStr(sp, v);
            if s <> '' then
              DrawText(sx + 16 * 8, sy, colBlack, sc, s);
          end;
        end;
      end else if splev = 128 then begin
        DrawText(x + 40, y + 8, colBlack, colLightGray, 'Casting...');
      end else if splev = 127 then begin
        DrawText(x + 40, y + 8, colBlack, colLightGray, 'Pick Location');
      end else begin
        sc := SpellSlantColor[SpellData[splev].slant];
        DrawText(x + 40, y + 8, colBlack, sc, SpellData[splev].name);
        if SpellData[splev].targets then begin
          sorc := GetSkillLevel(SV[side].Dude, skSorcery);
          if sorc = 0 then
            DrawText(x + 40, y + 24, colBlack, sc, 'Choose Target')
          else
            DrawText(x + 40, y + 24, colBlack, sc,
                     'Choose ' + IStr(sorc + 1, 0) + ' Targets');
        end;
      end;
    end;
  end;

procedure InitHexTables;
  var idx, x, y, tx, ty, h: integer;
  begin
    for x := 1 to CombatXMax do
      for y := 1 to CombatYMax do begin
        idx := (x - 1) * CombatYMax + y;
        for h := 1 to 6 do begin
          if FindAdjHex(h, x, y, tx, ty) then begin
            XInDir[idx, h] := tx;
            YInDir[idx, h] := ty;
          end else begin
            XInDir[idx, h] := 0;
            YInDir[idx, h] := 0;
          end;
        end;
      end;
  end;

{ unit initialization }

begin
  InitHexTables;
end.
