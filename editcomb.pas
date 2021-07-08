program editcomb;

{ program to edit combat screens for hommx }

uses Drivers, XSVGA, LowGr, XMouse, Hexes, XStrings, Combat, CombSub;

const
  MaxIke = 42;

var
  Def: integer;
  Choice: integer;
  Num: integer;
  Side: integer;

procedure BlankCombatDefs;
  var i: integer;
  begin
    for i := 1 to NumCombatDefs do
      with CombatDefs^[i] do begin
        fillchar(cmap, sizeof(cmap), chr(cmGrass));
        fillchar(startpos, sizeof(startpos), #0);
      end;
  end;

procedure SaveCombatDefs;
  var
    f: file;
    result: word;
  begin
    assign(f, 'COMBDEFS.DAT');
    rewrite(f, 1);
    BlockWrite(f, CombatDefs^, sizeof(CombatDefs^), result);
    close(f);
  end;

procedure DrawIcons;
  const sidecol: array [1..2] of byte = (colLightBlue, colDarkGray);
  var i, x, y, sc: integer;
  begin
    for i := 0 to MaxIke do
      if i in [0..2, 5..MaxIke] then begin
        x := 496 + 36 * (i mod 4);
        y := (i div 4) * 40;
        DrawCombatTerrain(x, y, i, 2, 0, colGreen);
        if choice = i then
          sc := colWhite
        else
          sc := colBlack;
        XRectangle(x, y, x + 35, y + 39, sc);
      end;

    if choice = 128 then
      sc := colWhite
    else
      sc := colLightGray;

    XRectangle(496, 440, 496 + 35, 440 + 39, sc);
    DrawText(496 + 10, 440 + 16, colBlack, sidecol[Side], IStr(Num, 2));

    XRectangle(568, 440, 568 + 35, 440 + 39, colLightGray);
    DrawText(568 + 14, 440 + 16, colBlack, colWhite, '+');
  end;

function DefWaterCode(m, cx, cy: integer): integer;
  var p, cn: integer;

  function DFindTerrain(wm, wx, wy: integer): boolean;
    begin
      DFindTerrain := (wx < 1) or (wy < 1)
                      or (wx > CombatXMax) or (wy > CombatYMax)
                      or (CombatDefs^[Def].cmap[wx, wy] = wm);
    end;

  begin
    p := 0;
    if cy mod 2 = 1 then cn := 0 else cn := -1;

    if DFindTerrain(m, cx - 1,      cy)     then inc(p, 1);
    if DFindTerrain(m, cx + cn,     cy - 1) then inc(p, 2);
    if DFindTerrain(m, cx + cn + 1, cy - 1) then inc(p, 4);
    if DFindTerrain(m, cx + 1,      cy)     then inc(p, 8);
    if DFindTerrain(m, cx + cn + 1, cy + 1) then inc(p, 16);
    if DFindTerrain(m, cx + cn,     cy + 1) then inc(p, 32);

    DefWaterCode := p;
  end;

procedure DrawDefHex(x, y: integer);
  var i, j, s, n, sc, md: integer;
  begin
    md := CombatDefs^[Def].cmap[x, y];
    GetCombatHexXY(x, y, i, j);
    if md > cmEmptyMax then
      XRectangle(i, j, i + 35, j + 39, colGreen);
    DrawCombatTerrain(i, j, md, 2, DefWaterCode(md, x, y), colGreen);

    for s := 1 to 2 do
      for n := 1 to 12 do
        if (CombatDefs^[Def].startpos[s, n].x = x)
           and (CombatDefs^[Def].startpos[s, n].y = y) then begin
          if s = 1 then sc := colLightBlue else sc := colDarkGray;
          DrawText(i + 10, j + 16, colGreen, sc, IStr(n, 0));
        end;

    if md <= cmEmptyMax then
      XRectangle(i, j, i + 35, j + 39, colLightGray);
  end;

procedure DrawDef;
  var i, j: integer;
  begin
    for j := 1 to CombatYMax do
      for i := 1 to CombatXMax do
        DrawDefHex(i, j);
    DrawText(464, 16, colBlack, colWhite, IStr(Def, 3));
  end;

procedure Draw;
  begin
    DrawIcons;
    DrawDef;
  end;

procedure IncStartPos;
  begin
    if Num < 12 then
      inc(Num)
    else begin
      Num := 1;
      Side := 3 - Side;
    end;
    DrawIcons;
  end;

procedure run;
  var
    over: boolean;
    E: TEvent;
    x, y, ike, i, j: integer;
  begin
    InitEvents;
    InitSVGA;
    SetSVGAMode;
    ClearScr;
    SetPalette;

{   BlankCombatDefs; }

    Def := 1;
    Num := 1;
    Side := 1;
    over := false;
    Choice := cmGrass;
    ACombat := New(PCombat, Init(true, 0, 0, 1, colGreen));

    Draw;

    repeat
      WaitForEvent(E);
      if E.What = evKeyDown then begin
        case E.charcode of
          #27: over := true;
        end;
        case E.keycode of
          kbLeft,
          kbUp:   Def := (((Def - 1) + NumCombatDefs - 1) mod NumCombatDefs) + 1;
          kbRight,
          kbDown: Def := (((Def - 1) + 1) mod NumCombatDefs) + 1;
          kbPgUp: Def := (((Def - 1) + NumCombatDefs - 10) mod NumCombatDefs) + 1;
          kbPgDn: Def := (((Def - 1) + 10) mod NumCombatDefs) + 1;
{         kbAltL: LoadCombatDefs; }
          kbAltS: SaveCombatDefs;
          kbAltB: CombatDefs^[Def].StartPos := CombatDefs^[1].StartPos;
        end;
        if not over then DrawDef;
      end;
      if E.What = evMouseDown then begin
        if E.Buttons = mbLeftButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if x >= 496 then begin
            x := (x - (496)) div 36;
            y := y div 40;
            ike := x + y * 4;
            if ike <= MaxIke then Choice := ike;
            if ike = 44 then Choice := 128;
            if ike = 46 then IncStartPos;
            DrawIcons;
          end else begin
            PointToGrid(x, y);
            if (x >= 1) and (y >= 1)
               and (x <= CombatXMax) and (y <= CombatYMax) then begin
              if choice = 128 then begin
                i := CombatDefs^[Def].startpos[side, num].x;
                j := CombatDefs^[Def].startpos[side, num].y;
                CombatDefs^[Def].startpos[side, num].x := x;
                CombatDefs^[Def].startpos[side, num].y := y;
                IncStartPos;
                if (i <> 0) and (j <> 0) then DrawDefHex(i, j);
              end else begin
                CombatDefs^[Def].cmap[x, y] := Choice;
              end;
              DrawDefHex(x, y);
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          x := E.Where.X;
          y := E.Where.Y;
          PointToGrid(x, y);
          if (x >= 1) and (y >= 1)
             and (x <= CombatXMax) and (y <= CombatYMax) then begin
            CombatDefs^[Def].cmap[x, y] := cmGrass;
            DrawDefHex(x, y);
          end;
        end;
      end;
    until over;

    Dispose(ACombat, Done);

    CloseGraphics;
    DoneSVGA;
    DoneEvents;
  end;

begin
  run;
end.
