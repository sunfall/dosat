unit mapscr;

{ adventure map for hommx }

interface

uses Objects, Rez, Map;

const
  MapScrSize = 15;
  WindowX = 508;
  WindowY = 312;
  WindowX2 = 638;

type
  PDangerMap = ^TDangerMap;
  TDangerMap = array [1..MapSize, 1..MapSize] of longint;

  PMapScr = ^TMapScr;
  TMapScr = object(TObject)
    MapGeos: PMapGeos;
    MapX, MapY: integer;
    ActiveHero: integer;
    MapBits, Fog: PMap;
    Drawn: array [1..MapScrSize, 1..MapScrSize] of word;
    DrawnBits, DrawnRoad, DrawnFog, DrawnClimate:
      array [1..MapScrSize, 1..MapScrSize] of byte;
    DrawnNum: array [1..MapScrSize, 1..MapScrSize] of word;
    Window, DrawnWindow: integer;
    GameOver: boolean;
    LastHuman: integer;
    CastleDangerMap: PDangerMap;
    HeroDangerMap: PMap;
    herogrid: array [1..MapScrSize, 1..MapScrSize] of byte;
    HeroGridCt: integer;
    BarType: (btHeroes, btCastles);
    BarPage: integer;
    TinyMapHeroes: boolean;
    constructor Init;
    destructor Done; virtual;
    function OnScreen(x, y: integer): boolean;
    procedure RevealArea(x, y, r: integer);
    procedure RevealHero(h: integer);
    procedure RevealEnemyHeroes;
    procedure MakeHeroGrid;
    procedure DrawMap;
    function TinyMapColor(i, j: integer): integer;
    procedure DrawTinyMap;
    procedure DrawBars;
    procedure DrawHeroWindow(h, kind: integer);
    procedure WindowBox;
    procedure DrawResources(i, j: integer);
    procedure DrawDay(i, j: integer);
    procedure ClearWindow(w: integer);
    procedure WDrawText(x, y, b, c: integer; s: string);
    procedure WDrawBoxText(x1, y1, x2, b, c: integer; s: string);
    procedure DrawTurnWindow;
    procedure DrawWindow;
    procedure Draw;
    procedure ClearDrawn;
    procedure SetCorner(x, y: integer);
    procedure CenterOn(x, y: integer);
    procedure ClearPath;
    procedure FindPathHex(dx, dy, t: integer; var newi, newj: integer);
    procedure FindNearAdjHex(i, j: integer; var x, y: integer);
    procedure HeroMakeMapDist(h, i, j: integer);
    function MakePath(i, j: integer): boolean;
    function MoveActiveHeroTo(x, y: integer): boolean;
    procedure WalkToDest(smell: boolean);
    function LowFight(x, y: integer; test: boolean; spread: integer): longint;
    function Fight(x, y: integer; test: boolean): longint;
    function Dialog(s: string; pic1, pic2, pic3, pic4: integer;
                    s1, s2, s3, s4: string): integer;
    procedure Message(s: string);
    procedure GiveHeroXP(h: integer; xp: longint);
    procedure VisitHero(h: integer);
    procedure VisitSpot(x, y: integer);
    procedure VisitCastle(x, y: integer);
    procedure HintText(x, y: integer);
    procedure Recover;
    procedure HeroScreen(h: integer);
    procedure StartTurn;
    procedure PrepTurn;
    procedure NewWeek;
    procedure NextTurn;
    procedure SelectHero(h: integer);
    procedure PlayerTurn;
    procedure MakeCastleDangerMap;
    procedure MakeHeroDangerMap;
    function SpotScore(h, x, y: integer): integer;
    procedure VisitAdjacent(fights: boolean);
    procedure AIHeroTurn(h, maxscore: integer);
    function AICastlesTurn: boolean;
    procedure AITurn;
    procedure CheckDeath(pl: integer);
    procedure CalcMonsterRanks;
    procedure Setup;
    procedure Handle;
    procedure SaveGame;
    procedure LoadGame;
  end;

implementation

uses CRT, Drivers, LowGr, XSVGA, XMouse, Players, Heroes, Castles, Monsters,
     Hexes, XStrings, Combat, Spells, Artifact, XFace, Combsub, Options;

const
  SuperSpyMode = {false;} true;

  winMessage = 0;
  winHero = 1;
  winResources = 2;
  winTurn = 3;
  winSkills = 4;
  winAI = 10;
  winArtSlot = 20;

  mbPathGreen = $0001;
  mbPathRed   = $0002;
  mbPathBlack = $0004;
  mbSword     = $0008;
  mbTalk      = $0010;

  mbAnyPath   = $001F;

  PathXGr: TGraphic =
  ('..........', { X marks the path }
   '..........',
   '.**...**..',
   '..**.**...',
   '...***....',
   '...***....',
   '..**.**...',
   '.**...**..',
   '..........',
   '..........');

  PathAttackGr: TGraphic =
  ('........**', { attack spot }
   '.......*.*',
   '......*.*.',
   '*....*.*..',
   '**..*.*...',
   '.***.*....',
   '..*.*.....',
   '.****.....',
   '***.**....',
   '**...**...');

  PathFriend: TGraphic =
  ('..........', { talk to hero }
   '..........',
   '..*....*..',
   '.**....**.',
   '**********',
   '.**....**.',
   '..*....*..',
   '..........',
   '..........',
   '..........');

  LibrarySkill: array [1..6] of byte =
  (
    skPower, skWizardry, skSpellcraft, skSorcery, skWitchcraft, skLore
  );

procedure GetMapHexXY(i, j: integer; var x, y: integer);
  begin
    x := (i - 1) * 32;
    y := (j - 1) * 32;
    if (j mod 2) = 1 then inc(x, 16);
  end;

constructor TMapScr.Init;
  begin
    TObject.Init;
    MapGeos := nil;
    MapX := 1;
    MapY := 1;
    Turn := 1;
    New(MapBits);
    New(Fog);
    New(CastleDangerMap);
    New(HeroDangerMap);
    FillChar(MapBits^, sizeof(MapBits^), #0);
    FillChar(Fog^, sizeof(Fog^), #0);
    GameOver := false;
    BarType := btHeroes;
    BarPage := 1;
    TinyMapHeroes := false;
  end;

destructor TMapScr.Done;
  begin
    Dispose(MapBits);
    Dispose(Fog);
    Dispose(CastleDangerMap);
    Dispose(HeroDangerMap);

    TObject.Done;
  end;

function TMapScr.OnScreen(x, y: integer): boolean;
  begin
    OnScreen := (x >= MapX) and (x < MapX + MapScrSize)
                and (y >= MapY) and (y < MapY + MapScrSize);
  end;

procedure TMapScr.RevealArea(x, y, r: integer);
  var i, j, r2: integer;
  begin
    r2 := sqr(r);

    for i := x - r to x + r do
      for j := y - r to y + r do
        if OnMap(i, j) and (Sqr(i - x) + Sqr(j - y) <= r2) then
          Fog^[i, j] := Fog^[i, j] or BitTable[Turn];
  end;

procedure TMapScr.RevealHero(h: integer);
  begin
    RevealArea(Hero^[h].MapX, Hero^[h].MapY,
               5 + GetEffSkillLevel(h, skPathfinding));
  end;

procedure TMapScr.RevealEnemyHeroes;
  var h: integer;
  begin
    for h := 1 to NumHeroes do
      if (Hero^[h].Player <> 0) and (Hero^[h].Player <> Turn)
         and (Hero^[h].MapX <> 0) then
        RevealArea(Hero^[h].MapX, Hero^[h].MapY, 2);
  end;

procedure TMapScr.MakeHeroGrid;
  var pl, h, hx, hy: integer;
  begin
    FillChar(herogrid, sizeof(herogrid), #0);
    HeroGridCt := 0;

    for pl := 1 to NumPlayers do
      for h := 1 to MaxDudes do
        if Player[pl].Dudes[h] <> 0 then begin
          hx := Hero^[Player[pl].Dudes[h]].MapX;
          hy := Hero^[Player[pl].Dudes[h]].MapY;
          if OnScreen(hx, hy) then begin
            herogrid[hx - MapX + 1, hy - MapY + 1] := Player[pl].Dudes[h];
            if Fog^[hx, hy] and BitTable[LastHuman] <> 0 then
              inc(HeroGridCt);
          end;
        end;
  end;

procedure TMapScr.DrawMap;
  const
    CachePic: array [1..NumCaches] of byte =
    (
      moCarnivorousPlant, moLaser, moAssassin, moBlob,
      moIllusionist, moMadTurtle, moMadScientist, moEvilFog,
      moRubberRat, moDancingSword, moTwoHeadedGiant, moWhirly
    );
  var
    i, j, mi, mj, x, y, m, m2, mgi, mgj, gx, gy, c, p: integer;
    w: word;

  procedure Blodget;
    begin
      DrawMapHexData(mi, mj, x, y, mGrass, 0, 0);
      XRectangle(x + 3, y + 3, x + 30, y + 30, colWhite);
      XRectangle(x + 5, y + 5, x + 28, y + 28, colWhite);
    end;

  procedure BlankHex;
    var zy: integer;
    begin
      for zy := 0 to 31 do
        HLine32(x, y + zy, colBlack);
    end;

  begin
    MakeHeroGrid;

    if VisibleTurn or (HeroGridCt > 0) then begin
      for i := 1 to MapScrSize do
        for j := 1 to MapScrSize do begin
          mi := MapX + i - 1;
          mj := MapY + j - 1;
          mgi := GeoX(mi);
          mgj := GeoY(mj);
          gx := ((mi - 1) mod GeoSize) + 1;
          gy := ((mj - 1) mod GeoSize) + 1;
          GetMapHexXY(i, j, x, y);
          if not OnMap(mi, mj) then begin
            BlankHex;
            Drawn[i, j] := $FFFF;
          end else begin
            w := TheMap^[mi, mj] + word(256) * MapInfo^[mi, mj];
            if (Drawn[i, j] <> w)
               or (DrawnBits[i, j] <> MapBits^[mi, mj])
               or (DrawnRoad[i, j] <> Roads^[mi, mj])
               or (DrawnNum[i, j] <> MapNum^[mi, mj])
               or (DrawnFog[i, j] <> Fog^[mi, mj])
               or (DrawnClimate[i, j] <> Climate^[mi, mj])
               or ((Climate^[mi, mj] and clBorder) <> 0)
               or (Roads^[mi, mj] <> 0)
               or ((TheMap^[mi, mj] = mWater) and (MapInfo^[mi, mj] <> $3F))
               or (TheMap^[mi, mj] = mChasm)
               or (herogrid[i, j] <> 0) then begin
              Drawn[i, j] := w;
              DrawnBits[i, j] := MapBits^[mi, mj];
              DrawnRoad[i, j] := Roads^[mi, mj];
              DrawnNum[i, j] := MapNum^[mi, mj];
              DrawnFog[i, j] := Fog^[mi, mj];
              DrawnClimate[i, j] := Climate^[mi, mj];
              m := TheMap^[mi, mj];

              if Fog^[mi, mj] and BitTable[LastHuman] = 0 then begin
                BlankHex;
              end else begin
                if m = mRightHalf then begin
                  m2 := MapInfo^[mi, mj];
                  if m2 = mSkillMine then
                    DrawMapHexData(mi, mj, x, y, m2, 1 + 16 * MapInfo^[mi - 1, mj], 0)
                  else if m2 = mFarmstead then
                    DrawMapHexData(mi, mj, x, y, m2, 1 + 16 * MapNum^[mi - 1, mj], 0)
                  else if (m2 >= mPreciousMine)
                          and (m2 <= mClayMine) then
                    DrawMapHexData(mi, mj, x, y, m2, 1 + 16 * MapNum^[mi, mj], 0)
                  else
                    Blodget;
                end else if (m >= mPreciousMine) and (m <= mClayMine) then begin
                  DrawMapHexData(mi, mj, x, y, m, 16 * MapNum^[mi, mj], 0);
                end else if m = mSkillMine then begin
                  DrawMapHexData(mi, mj, x, y, m, 16 * MapNum^[mi, mj], 0);
                end else if m = mCastlePart then begin
                  if MapInfo^[mi, mj] = 0 then
                    Blodget
                  else
                    DrawMapHexData(mi, mj, x, y, (MapInfo^[mi, mj] and $0F) + mCastle,
                                   (MapInfo^[mi, mj] div 16)
                                   + 16 * Castle[MapNum^[mi, mj]].Player, 0);
                end else if (m >= mCastle) and (m <= mLastCastle) then begin
                  DrawMapHexData(mi, mj, x, y, mGrass, 0, 0);
                end else if (m = mMonster) or (m = mHardMonster)
                            or (m = mDwelling) or (m = mCamp)
                            or (m = mHordeDwelling) then begin
                  if (m = mDwelling) or (m = mHordeDwelling) then begin
                    p := MapInfo^[mi, mj];
                    if MapNum^[mi, mj] > 0 then p := p or $100;
                    if m = mHordeDwelling then p := p or $01;
                  end else
                    p := MapInfo^[mi, mj] and $7F;
                  DrawMapHexData(mi, mj, x, y, m, p, Roads^[mi, mj]);
                end else if m = mCache then begin
                  if MapNum^[mi, mj] = 0 then
                    p := CachePic[MapInfo^[mi, mj]]
                  else
                    p := 0;
                  DrawMapHexData(mi, mj, x, y, m, p, 0);
                end else if (m = mShrine) or (m = mWater) or (m = mChasm)
                            or (m = mAltar) then begin
                  DrawMapHexData(mi, mj, x, y, m, MapInfo^[mi, mj], 0);
                end else if m = mBigMountain then begin
                  DrawMapHexData(mi, mj, x, y, m, MapNum^[mi, mj], 0);
                end else if m = mArtifact then begin
                  DrawMapHexData(mi, mj, x, y, m, MapInfo^[mi, mj], Roads^[mi, mj]);
                end else if m = mHero then begin
                  DrawMapHexData(mi, mj, x, y, mGrass, 0, Roads^[mi, mj]);
                end else if m = mMiningVillage then begin
                  DrawMapHexData(mi, mj, x, y, m,
                                 MapInfo^[mi, mj] + 16 * MapNum^[mi, mj], 0);
                end else if (m = mShamanHut) or (m = mMagicianHome)
                            or (m = mWizardHouse)
                            or (m = mHouseofHusbandry) then begin
                  DrawMapHexData(mi, mj, x, y, m, 16 * MapNum^[mi, mj], 0);
                end else if m = mSchool then begin
                  DrawMapHexData(mi, mj, x, y, m, MapInfo^[mi, mj], 0);
                end else begin
                  DrawMapHexData(mi, mj, x, y, m, 0, Roads^[mi, mj]);
                end;

                if herogrid[i, j] <> 0 then begin
                  DrawBackground := false;
                  DrawGraphic2c(x, y, colBrown,
                                PlColor[Hero^[herogrid[i, j]].player],
                                MapGraphics^[mgHero],
                                Hero^[herogrid[i, j]].FacingLeft);
                  DrawBackground := true;
                  Drawn[i, j] := $FFFF;
                end;

                if (MapBits^[mi, mj] and mbAnyPath) <> 0 then begin
                  DrawBackground := false;
                  if (MapBits^[mi, mj] and mbPathGreen) <> 0 then
                    c := {colPaleGreens + 3} colNicePaleGreens + 2
                  else if (MapBits^[mi, mj] and mbPathRed) <> 0 then
                    c := colRed
                  else
                    c := colBlack;
                  if (MapBits^[mi, mj] and mbSword) <> 0 then
                    DrawGraphic2c(x + 1, y + 1, c, colBlack, PathAttackGr, false)
                  else if (MapBits^[mi, mj] and mbTalk) <> 0 then
                    DrawGraphic2c(x + 1, y + 1, c, colBlack, PathFriend, false)
                  else
                    DrawGraphic2c(x + 2, y + 1, c, colBlack, PathXGr, false);
                  DrawBackground := true;
                end;
              end;
            end;
          end;
        end;
    end;
  end;

function TMapScr.TinyMapColor(i, j: integer): integer;
  var c, d, h: integer;
  begin
    if not OnMap(i, j) or (Fog^[i, j] and BitTable[LastHuman] = 0) then
      c := colBlack
    else if (Roads^[i, j] <> 0)
                and not (TheMap^[i, j] in [mCastle..mLastCastle]) then
      c := colTan
    else begin
      c := ClimateColor[Climate^[i, j] and $07];
      d := TheMap^[i, j];
      if (d >= mFirstObstacle) and (d < mRightHalf) then
        c := ObstacleColor(i, j);
      case d of
        mPreciousMine..mSkillMine, mRightHalf: c := colDarkGray;
        mFarmstead: c := colDarkGray;

        mDwelling, mHordeDwelling, mSchool..mWatchtower: c := colBrown;
        mCache: c := colBrown;

        mCastle..mLastCastle, mCastlePart: c := colBlack;
      end;
    end;

    TinyMapColor := c;
  end;

var
  tm: array [0..MapSize + 1, 0..MapSize + 1] of byte;

procedure TMapScr.DrawTinyMap;
  var
    i, j, c, n, cx, cy: integer;

  function SpotVisible: boolean;
    begin
      SpotVisible := OnMap(i, j) and (Fog^[i, j] and BitTable[LastHuman] <> 0);
    end;

  begin
    if VisibleTurn or (HeroGridCt > 0) then begin
      if TinyMapHeroes then begin
        for i := 1 to MapSize do begin
          for j := 1 to MapSize do begin
            if not SpotVisible then
              tm[i, j] := colBlack
            else if TheMap^[i, j] < mFirstObstacle then
              tm[i, j] := {colBlack}colGreen
            else
              tm[i, j] := colDarkGray;
          end;
        end;

        for n := 1 to NumHeroes do
          if (Hero^[n].player <> 0) and (Hero^[n].MapX <> 0) then begin
            i := Hero^[n].MapX;
            j := Hero^[n].MapY;
            if SpotVisible then begin
              c := PlColor[Hero^[n].player];
              tm[i, j] := colWhite;
              tm[i - 1, j] := c;
              tm[i + 1, j] := c;
              tm[i, j - 1] := c;
              tm[i, j + 1] := c;
            end;
          end;

        for n := 1 to NumCastles do begin
          i := Castle[n].MapX;
          j := Castle[n].MapY;
          if SpotVisible then begin
            c := PlColor[Castle[n].player];
            for cx := -1 to 1 do
              for cy := -1 to 1 do
                tm[i + cx, j + cy] := c;
            tm[i, j] := colWhite;
          end;
        end;
      end else begin
        for i := 1 to MapSize do
          for j := 1 to MapSize do
            tm[i, j] := TinyMapColor(i, j);
      end;

      for i := MapX - 1 to MapX + MapScrSize - 1 + 1 do
        for j := MapY - 1 to MapY + MapScrSize - 1 + 1 do
          if (((i = MapX) or (i = MapX + MapScrSize - 1))
              and (j >= MapY) and (j < MapY + MapScrSize))
             or (((j = MapY) or (j = MapY + MapScrSize - 1))
                 and (i >= MapX) and (i < MapX + MapScrSize))
             or (((i = MapX - 1) or (i = MapX + MapScrSize - 1 + 1))
                 and (j >= MapY - 1) and (j < MapY + MapScrSize + 1))
             or (((j = MapY - 1) or (j = MapY + MapScrSize - 1 + 1))
                 and (i >= MapX - 1) and (i < MapX + MapScrSize + 1)) then
            if (i >= 1) and (j >= 1) and (i <= MapSize) and (j <= MapSize) then
              if (i + j) mod 2 = 0 then
                tm[i, j] := colBlack
              else
                tm[i, j] := colWhite;

      for i := 1 to MapSize do
        for j := 1 to MapSize do
          XPutPixel(639 - MapSize + i, j - 1, tm[i, j]);
    end;
  end;

procedure TMapScr.DrawBars;
  const
    barx = 520;
    CastlePic: TGraphic =
    ('..........',
     '..........',
     '**..**..**',
     '**..**..**',
     '**********',
     '**********',
     '**********',
     '**********',
     '..........',
     '..........');
  var
    i, c, c2, bc, h, t, x, y, a, b, gx, gy: integer;
    gr: array [1..34, 1..34] of byte;
    m: TGraphic;

  procedure SetGrPix(px, py, c: integer);
    begin
      px := px * 2 + 5;
      py := py * 2 + 5;
      gr[px, py] := c;
      gr[px + 1, py] := c;
      gr[px, py + 1] := c;
      gr[px + 1, py + 1] := c;
    end;

  procedure DrawCorner(px, py, c2: integer; invx, invy: boolean);
    const
      CornerGr: array [1..4, 1..4] of byte =
      (
        (1, 1, 2, 0),
        (1, 1, 1, 2),
        (2, 1, 0, 0),
        (0, 2, 0, 0)
      );
    var
      dx, dy, cx, cy, c: integer;
    begin
      for dx := 1 to 4 do begin
        if invx then cx := 5 - dx else cx := dx;
        for dy := 1 to 4 do begin
          if invy then cy := 5 - dy else cy := dy;
          if CornerGr[cy, cx] <> 0 then begin
            if CornerGr[cy, cx] = 1 then c := colWhite else c := c2;
            XPutPixel(px + dx - 1, py + dy - 1, c);
          end;
        end;
      end;
    end;

  begin
    if VisibleTurn then begin
      for i := 0 to 11 do begin
        x := barx + 40 * (i mod 3);
        y := 140 + 40 * (i div 3);

        if i >= 8 then begin
          case i of
            8:  if (BarType = btCastles)
                   and ((BarPage <> 1) or (Player[Turn].Towns[9] <> 0)) then
                  XDrawIcon2c(x + 2, y + 2, colWhite, colDarkGray, @RightArrow)
                else
                  XFillArea(x, y, x + 34, y + 34, colBlack);
            9:  XDrawIcon2c(x + 2, y + 2, colWhite, colDarkGray, @Horsie);
            10: XDrawIcon2c(x + 2, y + 2, colWhite, colDarkGray, @CastlePic);
            11: XDrawIcon2c(x + 2, y + 2, colWhite, colDarkGray, @Hourglass);
          end;
        end else if BarType = btHeroes then begin
          h := Player[Turn].Dudes[i + 1];
          if h <> 0 then begin
            if Hero^[h].MP > 0 then
              c := colGreen
            else
              c := colRed;
            DrawHero(x, y, c, h);
            XRectangle(x + 1, y + 1, x + 34, y + 34, c);
            if h = ActiveHero then begin
              if c = colGreen then c := colLightGreen else c := colLightRed;
              DrawCorner(x, y, c, false, false);
              DrawCorner(x + 32, y, c, true, false);
              DrawCorner(x, y + 32, c, false, true);
              DrawCorner(x + 32, y + 32, c, true, true);
            end;
          end else begin
            XRectangle(x, y, x + 35, y + 35, colDarkGray);
            XFillArea(x + 1, y + 1, x + 34, y + 34, colBlack);
          end;
        end else begin
          if (BarPage - 1) * 8 + i + 1 > MaxTowns then
            t := 0
          else
            t := Player[Turn].Towns[(BarPage - 1) * 8 + i + 1];
          if t <> 0 then begin
            case CanBuildKind(t) of
              0: c := colRed;
              1: c := colDarkGreen;
              2: c := colGreen;
            end;
            XRectangle(x, y, x + 35, y + 35, c);
            XRectangle(x + 1, y + 1, x + 34, y + 34, c);
            for gx := 2 to 33 do
              for gy := 2 to 33 do
                gr[gx, gy] := TinyMapColor(Castle[t].MapX + gx - 17,
                                           Castle[t].MapY + gy - 17);
            if Castle[t].Outpost then
              m := MonsterGraphic(MonsterForLevel(Castle[t].CT, + 1))^
            else
              m := MonsterGraphic(MonsterForLevel(Castle[t].CT, + 6))^;
            if PlColor[Turn] = colBlack then
              bc := colDarkGray
            else
              bc := colBlack;
            for gx := 1 to 10 do
              for gy := 1 to 10 do begin
                if m[gy, gx] <> '.' then begin
                  SetGrPix(gx, gy, PlColor[Turn]);
                  for a := -1 to 1 do
                    for b := -1 to 1 do
                      if (gx + a < 1) or (gx + a > 10) or (gy + b < 1)
                         or (gy + b > 10) or (m[gy + b, gx + a] = '.') then
                        SetGrPix(gx + a, gy + b, bc);
                end;
              end;
            for gx := 2 to 33 do
              for gy := 2 to 33 do
                XPutPixel(x + gx, y + gy, gr[gx, gy]);
          end else begin
            XRectangle(x, y, x + 35, y + 35, colDarkGray);
            XFillArea(x + 1, y + 1, x + 34, y + 34, colBlack);
          end;
        end;
      end;
    end;
  end;

procedure TMapScr.DrawHeroWindow(h, kind: integer);
  const hwx = WindowX + 6;
  var i, j, k, x, y: integer;
  begin
    if h <> 0 then begin
      DrawHero(hwx, WindowY, colWhite, h);
      DrawSmallGraphic2c(hwx + 45 - 3, WindowY + 5 - 1,
                         colGreen, colBlack, Horsie);
      DrawText(hwx + 45 + 10, WindowY + 5, colBlack, colGreen,
               LSet(IStr(Hero^[h].MP, 0), 4));
      DrawSmallGraphic2c(hwx + 45 - 3, WindowY + 5 + 13 - 1,
                         colBlue, colBlue, ArtGraphics[agWand]);
      DrawText(hwx + 45 + 10, WindowY + 5 + 13, colBlack, colBlue,
               LSet(IStr(Hero^[h].SP, 0), 4));
      if kind = winHero then begin
        BackgroundColor := colDarkGray;
        for i := 1 to HeroSlots(h) do begin
          if i = 10 then begin
            x := hwx + 2 * 40;
            y := WindowY;
          end else begin
            x := hwx + ((i - 1) mod 3) * 40;
            y := WindowY + 42 + ((i - 1) div 3) * 42;
          end;
          DrawArmyBox(x, y, colLightGray, colFriend, colWhite,
                      Hero^[h].Army[i], false);
        end;
        BackgroundColor := colGreen;
      end else if kind = winSkills then begin
        y := WindowY + 40 + 8;
        for i := 1 to 10 do
          if Hero^[h].Skill[i] <> 0 then begin
            if i <= 5 then j := colLightBlue else j := colYellow;
            DrawText(hwx, y, colBlack, j,
                     LSet(SkillNames[Hero^[h].Skill[i]] + ' '
                          + IStr(Hero^[h].SkillLevel[i], 0), 14));
            inc(y, 11);
          end;
      end else if (kind >= winArtSlot) and (kind <= winArtSlot + 9) then begin
        BackgroundColor := colDarkGray;
        j := 1;
        for i := 1 to EquipSlots(h) do
          if EquipSlot[i] = kind - winArtSlot then begin
            x := hwx + ((j - 1) mod 3) * 40;
            y := WindowY + 42 + ((j - 1) div 3) * 42;
            DrawArt(x, y, Hero^[h].Equipped[i]);
            inc(j);
          end;
        BackgroundColor := colGreen;
      end;
    end;
  end;

procedure TMapScr.WindowBox;
  begin
    XRectangle(WindowX - 3, WindowY - 3, 639, 479, colDarkGray);
  end;

procedure TMapScr.DrawResources(i, j: integer);
  var
    x, y: integer;
    r: TResource;
  begin
    if VisibleTurn then begin
      for r := low(TResource) to high(TResource) do begin
        x := i;
        y := j;
        if r > rGold then begin
          if (ord(r) - ord(rRocks)) mod 2 = 1 then inc(x, 60);
          inc(y, ((ord(r) - ord(rRocks)) div 2 + 1) * 13);
        end;
        DrawResource(x, y, colBlack, r, Player[Turn].Resources[r]);
      end;
      WindowBox;
    end;
  end;

procedure TMapScr.DrawDay(i, j: integer);
  begin
    DrawText(i, j, colBlack, colLightGray,
             'Day ' + IStr((Date mod 7) + 1, 0));
    DrawText(i, j + 13, colBlack, colLightGray,
             'Week ' + IStr(((Date div 7) mod 4) + 1, 0));
    DrawText(i, j + 13 * 2, colBlack, colLightGray,
             'Month ' + IStr((Date div 28) + 1, 0));
  end;

procedure TMapScr.ClearWindow(w: integer);
  begin
    Window := w;
    if VisibleTurn or ((w >= winAI) and (w <= winAI + 8)) then begin
      ClearArea(WindowX, WindowY - 2, 639, 479);
      WindowBox;
    end;
  end;

procedure TMapScr.WDrawText(x, y, b, c: integer; s: string);
  begin
    if VisibleTurn then
      DrawText(x, y, b, c, s);
  end;

procedure TMapScr.WDrawBoxText(x1, y1, x2, b, c: integer; s: string);
  begin
    if VisibleTurn then
      DrawBoxText(x1, y1, x2, b, c, s);
  end;

procedure TMapScr.DrawTurnWindow;
  begin
    DrawBackground := false;
    XDrawIcon2c(528, WindowY + 32, colWhite, colDarkGray, @Hourglass);
    XDrawIcon2c(528, WindowY + 96, colWhite, colDarkGray, @Computer);
    DrawBoxText(528 + 40, WindowY + 32 + 6, 528 + 40 + 40, colBlack,
                colLightGray, 'End Turn');
    DrawBoxText(528 + 40, WindowY + 96 + 6 + 6, 528 + 40 + 40, colBlack,
                colLightGray, 'System');
    DrawBackground := true;
  end;

procedure TMapScr.DrawWindow;
  begin
    if VisibleTurn or ((Window >= winAI) and (Window <= winAI + 8)) then begin
      if (Window <> winMessage) and (Window <> DrawnWindow) then begin
        ClearWindow(Window);
        case Window of
          winHero:      DrawHeroWindow(ActiveHero, winHero);
          winResources: begin
                          DrawResources(WindowX, WindowY + 5);
                          DrawDay(WindowX, WindowY + 5 + 13 * 5);
                        end;
          winTurn:      DrawTurnWindow;
          winAI + 1
          ..winAI + 8:  begin
                          DrawBackground := false;
                          DrawGraphic2c(528, WindowY + 32, colBrown,
                                        PlColor[Turn], MapGraphics^[mgHero],
                                        false);
                          DrawBackground := true;
                          RefreshScreen;
                        end;
        end;
        DrawnWindow := window;
      end;
    end;
  end;

procedure TMapScr.Draw;
  begin
    DrawMap;
    DrawTinyMap;
    DrawBars;
    DrawWindow;
  end;

procedure TMapScr.ClearDrawn;
  begin
    FillChar(Drawn, sizeof(Drawn), #$FF);
    FillChar(DrawnBits, sizeof(DrawnBits), #$FF);
    FillChar(DrawnRoad, sizeof(DrawnRoad), #$FF);
    FillChar(DrawnNum, sizeof(DrawnNum), #$FF);
    FillChar(DrawnFog, sizeof(DrawnFog), #$FF);
    FillChar(DrawnClimate, sizeof(DrawnClimate), #$FF);
    DrawnWindow := -1;
  end;

procedure TMapScr.SetCorner(x, y: integer);
  var ox, oy: integer;
  begin
    ox := MapX;
    oy := MapY;
    MapX := x;
    MapY := y;
    if MapX mod 2 = 0 then dec(MapX);
    if MapY mod 2 = 0 then dec(MapY);
    if MapX < 1 then MapX := 1;
    if MapY < 1 then MapY := 1;
    if MapX > MapSize - MapScrSize + 2 then
      MapX := MapSize - MapScrSize + 2;
    if MapY > MapSize - MapScrSize + 2 then
      MapY := MapSize - MapScrSize + 2;
    if (ox <> MapX) or (oy <> MapY) then
      Draw;
  end;

procedure TMapScr.CenterOn(x, y: integer);
  begin
    SetCorner(x - MapScrSize div 2, y - MapScrSize div 2);
  end;

procedure TMapScr.ClearPath;
  var i, j, x, y: integer;
  begin
    if ActiveHero <> 0 then begin
      Hero^[ActiveHero].DestX := 0;
      Hero^[ActiveHero].DestY := 0;
    end;
    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if (MapBits^[i, j] and mbAnyPath) <> 0 then begin
          MapBits^[i, j] := MapBits^[i, j] and (not mbAnyPath);
          if OnScreen(i, j) then
            DrawnBits[i - MapX + 1, j - MapY + 1] := $FF;
        end;
  end;

procedure TMapScr.FindPathHex(dx, dy, t: integer; var newi, newj: integer);
  var n, i, j, h, ni, nj: integer;
  begin
    n := dist^[dx, dy] and $7F;
    if n <= t then begin
      newi := dx;
      newj := dy;
    end else begin
      i := dx;
      j := dy;
      repeat
        newi := 0;
        for h := 1 to 6 do
          if FindAdjMapHex(h, i, j, ni, nj) then
            if Dist^[ni, nj] = n - 1 then
              if (newi = 0) or (Roads^[ni, nj] <> 0) then begin
                newi := ni;
                newj := nj;
              end;
        if newi <> 0 then begin
          i := newi;
          j := newj;
        end;
        dec(n);
      until (newi = 0) or (n = t);
    end;
  end;

procedure TMapScr.FindNearAdjHex(i, j: integer; var x, y: integer);
  var h, d, ni, nj, has: integer;
  begin
    x := 0;
    d := 0;
    for h := 1 to 6 do
      if FindAdjMapHex(h, i, j, ni, nj) then
        if (dist^[ni, nj] <> 0)
           and ((d = 0) or (dist^[ni, nj] < d)) then begin
          has := HeroAtSpot(ni, nj);
          if (has = 0) or (has = ActiveHero) then begin
            x := ni;
            y := nj;
            d := dist^[ni, nj];
          end;
        end;
  end;

procedure TMapScr.HeroMakeMapDist(h, i, j: integer);

  procedure SetHeroMapCodes(c1, c2: integer);
    var n, h2: integer;
    begin
      for n := 1 to MaxDudes do begin
        h2 := Player[Hero^[h].player].Dudes[n];
        if (h2 <> 0) and (Hero^[h2].MapX <> 0)
           and (TheMap^[Hero^[h2].MapX, Hero^[h2].MapY] = c1) then
          TheMap^[Hero^[h2].MapX, Hero^[h2].MapY] := c2;
      end;
    end;

  begin
    SetHeroMapCodes(mHero, mGrass);
    MakeMapDist(TheMap, Dist, Hero^[h].MapX, Hero^[h].MapY, i, j, mmdWalk);
    SetHeroMapCodes(mGrass, mHero);
  end;

function TMapScr.MakePath(i, j: integer): boolean;
  var
    n, newi, newj, d, t, origi, origj, h, md, mi: integer;
    foggy: boolean;

  procedure SetBit(a, b, c: integer);
    begin
      if (a <> Hero^[ActiveHero].MapX)
         or (b <> Hero^[ActiveHero].MapY) then begin
        MapBits^[a, b] := MapBits^[a, b] or c;
        if OnScreen(a, b) then
          DrawnBits[a - MapX + 1, b - MapY + 1] := $FF;
      end;
    end;

  begin
    origi := i;
    origj := j;

    ClearPath;

    t := TheMap^[i, j];
    TheMap^[i, j] := mTarget;
    HeroMakeMapDist(ActiveHero, i, j);
    TheMap^[i, j] := t;
    if not (((t = mGrass) or ((t >= mCastle) and (t <= mLastCastle)))
            and not AdjToMonster(TheMap, i, j))
       or ((t >= mCastle) and (t <= mLastCastle)
           and (HeroAtSpot(i, j) <> 0)) then
      dist^[i, j] := 0;

    d := dist^[i, j];
    if d = 0 then begin
      FindNearAdjHex(i, j, newi, newj);
      if newi <> 0 then begin
        h := HeroAtSpot(i, j);
        if ((t = mGrass) and AdjToMonster(TheMap, i, j))
           or ((h <> 0) and (Hero^[h].player <> Turn)) then
          SetBit(i, j, mbSword)
        else if (h <> 0) and (Hero^[h].player = Turn) then
          SetBit(i, j, mbTalk)
        else
          SetBit(i, j, mbPathBlack);
        i := newi;
        j := newj;
        d := dist^[i, j];
      end;
    end;

    if d <> 0 then begin
      foggy := false;

      for n := 1 to d do begin
        FindPathHex(i, j, n, newi, newj);
        if dist^[newi, newj] <= Hero^[ActiveHero].MP + 1 then
          SetBit(newi, newj, mbPathGreen)
        else
          SetBit(newi, newj, mbPathRed);
        if not Player[Turn].AI
           and ((Fog^[newi, newj] and BitTable[Turn]) = 0) then
          foggy := true;
      end;

      if foggy then begin
        ClearPath;
        d := 0;
      end else begin
        Hero^[ActiveHero].DestX := origi;
        Hero^[ActiveHero].DestY := origj;

        md := TheMap^[origi, origj];
        mi := MapInfo^[origi, origj];
         if ((md >= mCastle) and (md <= mLastCastle)
            and (Castle[mi].player <> Turn))
           or (((md = mDwelling) or (md = mHordeDwelling))
               and ((mi and $80) <> 0))
           or ((md = mCache) and (MapNum^[origi, origj] = 0)) then
          MapBits^[origi, origj] := mbSword;

        Draw;
      end;
    end;

    MakePath := d <> 0;
  end;

function TMapScr.MoveActiveHeroTo(x, y: integer): boolean;
  const
    cmax = MapSize - MapScrSize div 2 + 2;
  var
    h: PHero;
    scrolled: boolean;

  function FriendlyHeroesAt(hx, hy: integer): integer;
    var fha, ph, phn: integer;
    begin
      fha := 0;

      for ph := 1 to MaxDudes do begin
        phn := Player[h^.player].Dudes[ph];
        if (phn <> 0) and (Hero^[phn].MapX = hx)
           and (Hero^[phn].MapY = hy) then
          inc(fha);
      end;

      FriendlyHeroesAt := fha;
    end;

  begin
    h := @Hero^[ActiveHero];

    if (TheMap^[h^.MapX, h^.MapY] = mHero)
       and (FriendlyHeroesAt(h^.MapX, h^.MapY) = 1) then
      TheMap^[h^.MapX, h^.MapY] := mGrass;

    if (y = h^.MapY) then
      if x = h^.MapX - 1 then
        h^.FacingLeft := true
      else if x = h^.MapX + 1 then
        h^.FacingLeft := false;

    if OnScreen(h^.MapX, h^.MapY) then
      Drawn[h^.MapX - MapX + 1, h^.MapY - MapY + 1] := $FFFF;

    h^.MapX := x;
    h^.MapY := y;

    if TheMap^[h^.MapX, h^.MapY] = mGrass then
      TheMap^[h^.MapX, h^.MapY] := mHero;

    scrolled := not (((h^.MapX >= MapX + 4) or (h^.MapX <= 4))
                     and ((h^.MapX < MapX + MapScrSize - 4)
                          or (h^.MapX >= cmax))
                     and ((h^.MapY >= MapY + 4) or (h^.MapY <= 4))
                     and ((h^.MapY < MapY + MapScrSize - 4)
                          or (h^.MapY >= cmax)));

    if scrolled then
      CenterOn(h^.MapX, h^.MapY);

    RevealHero(ActiveHero);

    MoveActiveHeroTo := scrolled;
  end;

procedure TMapScr.WalkToDest(smell: boolean);
  var
    n, d, stepx, stepy, dx, dy, nx, ny, origx, origy: integer;
    h, i, a, gp, m, k: integer;
    s: string;
    scrolled: boolean;
  begin
    origx := Hero^[ActiveHero].DestX;
    origy := Hero^[ActiveHero].DestY;
    dx := origx;
    dy := origy;
    ClearPath;

    d := dist^[dx, dy];

    if d = 0 then begin
      FindNearAdjHex(dx, dy, nx, ny);
      if nx <> 0 then begin
        dx := nx;
        dy := ny;
        d := dist^[dx, dy];
      end;
    end;

    if d > Hero^[ActiveHero].MP + 1 then begin
      d := Hero^[ActiveHero].MP + 1;
{}    if d > 1 then begin
        repeat
          FindPathHex(dx, dy, d, stepx, stepy);
          h := HeroAtSpot(stepx, stepy);
          if h <> 0 then dec(d);
        until (h = 0) or (d = 1);
        if (d <> Hero^[ActiveHero].MP + 1) and Player[Turn].AI then
          Hero^[ActiveHero].MP := d - 1;
      end; {}
    end;
    dec(Hero^[ActiveHero].MP, d - 1);

    for n := 1 to d do begin
      FindPathHex(dx, dy, n, stepx, stepy);
      if TheMap^[stepx, stepy] in [mResource..mBarrel, mPotion] then
        VisitSpot(stepx, stepy);  { !X! }
      scrolled := MoveActiveHeroTo(stepx, stepy);
      if smell and (n <> d) then VisitAdjacent(false);

      if VisibleTurn or (HeroGridCt > 0) then begin
        DrawMap;
        if scrolled then k := 10 else k := 12;
        for i := 1 to k do RefreshScreen;
      end;
    end;

    DrawnWindow := -1;
    Draw;

    if VisibleTurn or (HeroGridCt > 0) then
      RefreshScreen;

    if (Hero^[ActiveHero].MapX <> origx) or (Hero^[ActiveHero].MapY <> origy) then
      if HexIsAdjacent(Hero^[ActiveHero].MapX, Hero^[ActiveHero].MapY,
                       origx, origy) then
        VisitSpot(origx, origy)
      else
        MakePath(origx, origy);

    if ActiveHero <> 0 then
      for n := 1 to NumTreasureMaps do
        if (Hero^[ActiveHero].MapX = TreasureMap[n].x)
           and (Hero^[ActiveHero].MapY = TreasureMap[n].y)
           and HasArt(ActiveHero, anTreasureMap1 + n - 1, false) then begin
          LoseArt(ActiveHero, anTreasureMap1 + n - 1);
          s := 'You dig up the treasure the map has led you to! You find ';
          for i := 1 to 3 do begin
            a := RandomArtifact(3);
            if GainArt(ActiveHero, a) then
              s := s + 'a ' + ArtData[a].name + ', ';
          end;
          gp := 4000 + random(5) * 1000;
          Message(s + 'and ' + GoldStr(gp) + '!');
          inc(Player[Turn].Resources[rGold], gp);
          Draw;
        end;

    if ActiveHero <> 0 then begin
      m := TheMap^[Hero^[ActiveHero].MapX, Hero^[ActiveHero].MapY];
      if (m >= mJungleFort) and (m <= mLastCastle) then
        VisitCastle(Hero^[ActiveHero].MapX, Hero^[ActiveHero].MapY);
    end;

    if smell then VisitAdjacent(true);
  end;

function TMapScr.LowFight(x, y: integer; test: boolean; spread: integer): longint;
  var
    startarmy: array [1..2] of TArmySet;
    xp: array [1..2] of longint;
    startsp: array [1..2] of integer;
    def, town, winner: integer;
    persuasiongp: longint;
    persuasioncrs: integer;
    persuasionstr: string;
    persuasionbonus: boolean;

  function AddXPStack(x, y, side, monster, qty, slot,
                      illusion: integer): integer;
    var
      found, q: integer;

    function FindMonsterStack: boolean;
      var i: integer;
      begin
        found := 0;
        with ACombat^ do
          for i := 1 to LastStack do
            if (found = 0) and (Stacks[i].qty > 0) and (Stacks[i].side = 1)
               and (Stacks[i].realmonster = monster)
               and (Stacks[i].armyslot <> -1) then
              found := i;
        FindMonsterStack := found <> 0;
      end;

    procedure AddToPersuasionStr;
      begin
        if persuasionstr <> '' then
          persuasionstr := persuasionstr + ', ';
        persuasionstr := persuasionstr + IStr(q, 0) + '_';
        if q = 1 then
          persuasionstr := persuasionstr + MonsterData[monster].name
        else
          persuasionstr := persuasionstr + MonsterData[monster].pname;
      end;

    begin
      if (side = 2) and (persuasiongp >= MonsterData[monster].cost) then
        with ACombat^ do begin
          if FindMonsterStack then begin
            q := persuasiongp div MonsterData[monster].cost;
            if q > qty then q := qty;
            if q > 0 then begin
              inc(Stacks[found].qty, q);
              inc(Stacks[found].maxqty, q);
              if Stacks[found].armyslot > 0 then
                inc(startarmy[1][Stacks[found].armyslot].qty, q);
              dec(qty, q);
              dec(persuasiongp, q * longint(MonsterData[monster].cost));
              inc(persuasioncrs, q);
              AddtoPersuasionStr;
            end;
          end;
        end;

      if (side = 2) and persuasionbonus and (qty > 0) then begin
        with ACombat^ do
          if not FindMonsterStack then begin
            q := PersuasionAmt div MonsterData[monster].cost;
            if q > 0 then begin
              q := AddXPStack(CombatDefs^[Def].startpos[1, 12].x,
                              CombatDefs^[Def].startpos[1, 12].y,
                              1, monster, q, -1, 0);
              if q > 0 then begin
                dec(qty, q);
                persuasionbonus := false;
                inc(persuasioncrs, q);
                AddtoPersuasionStr;
              end;
            end;
          end;
      end;

      if qty > 0 then begin
        ACombat^.AddStack(x, y, side, monster, qty, slot, illusion);
        inc(xp[3 - side], MonsterData[monster].cost * longint(qty) div 5);
      end;

      AddXPStack := qty;
    end;

  procedure AddHeroStacks(h, side: integer);
    var
      i, an, ca, q, hm, hq, j: integer;
      got: boolean;

    procedure AddRingMonster(var amt: integer; art, mons, num: integer);
      begin
        inc(amt, num * CountArt(h, art, true));
        if amt > 0 then
          if GainMonster(@Hero^[h].army, HeroSlots(h), mons, amt) then
            amt := 0;
      end;

    begin
      with ACombat^, CombatDefs^[Def] do begin
        if not test then begin
          AddRingMonster(Hero^[h].RingWitches, anRingofWitches, moWitch, 2);
          AddRingMonster(Hero^[h].RingDjinns, anRingofDjinns, moDjinn, 1);
        end;

        for i := 1 to HeroSlots(h) do begin
          hq := Hero^[h].army[i].qty;
          if hq > 0 then begin
            hm := Hero^[h].army[i].monster;

            if HeroMonsterHasFlag(h, hm, 6, f6Recruit) then begin
              got := false;
              if i > 1 then
                for j := 1 to i - 1 do
                  if (Hero^[h].army[j].qty > 0)
                     and (Hero^[h].army[j].monster = hm) then
                    got := true;
              if not got then inc(hq, 3);
            end;

            q := AddXPStack(CombatDefs^[Def].startpos[side, i].x,
                            CombatDefs^[Def].startpos[side, i].y, side,
                            hm, hq, i, 0);
            startarmy[side][i].qty := q;
            if q > 0 then startarmy[side][i].monster := hm;
          end else
            startarmy[side][i] := NilArmy;
        end;

        i := GetEffSkillLevel(h, skConjuring);
        if i > 0 then begin
          hm := Hero^[h].SummonedCr;
          AddXPStack(startpos[side, 11].x, startpos[side, 11].y,
                     side, hm, (ConjuringGP * i) div MonsterData[hm].cost,
                     0, 0);
          if HeroHasExpertiseBonus(h, skConjuring) then
            AddXPStack(startpos[side, 12].x, startpos[side, 12].y,
                       side, hm, ConjuringGP div MonsterData[hm].cost, 0, 0);
        end;
      end;
    end;

  procedure AddGarrisonStacks;
    var i: integer;
    begin
      with ACombat^, CombatDefs^[Def] do begin
        for i := 1 to 6 do
          with Castle[town] do
            if Garrison[i].qty > 0 then
              AddXPStack(startpos[2, i].x, startpos[2, i].y, 2,
                         Garrison[i].monster, Garrison[i].qty, i, 0);
      end;
    end;

  procedure AddMapStacks;
    var i, r, qf, q, m, bm, piles, elders, pile1: integer;
    begin
      r := MapGeos^[GeoX(x), GeoY(y)].rand;
      qf := MapNum^[x, y];
      bm := MapInfo^[x, y] and $7F;
      piles := ((r + x + y) mod 6) + 1;
      if piles > qf then piles := qf;
      if piles >= 4 then elders := (r + x) mod 3 else elders := 0;
      if (piles = 1) and (bm in [moSoulThief, moRobot, moWobbler, moMummy]) then
        piles := 6;
      if piles = 1 then
        pile1 := 4
      else if piles <= 3 then
        pile1 := 3
      else if piles <= 5 then
        pile1 := 2
      else
        pile1 := 1;

      with ACombat^, CombatDefs^[Def] do
        for i := 1 to piles do begin
          q := (qf + i - 1) div piles;
          m := bm;
          if ((elders > 0) and (i = 2))
             or ((elders > 1) and (i = piles - 1)) then begin
            if (m mod 6) = 0 then
              dec(m, 5)
            else
              inc(m);
            q := (MonsterData[MapInfo^[x, y] and $7F].cost * longint(q)
                  + MonsterData[m].cost div 2)
                 div MonsterData[m].cost;
          end;
          AddXPStack(startpos[2, pile1 + i - 1].x,
                     startpos[2, pile1 + i - 1].y, 2, m, q, 1, 0);
        end;
    end;

  procedure AddTestStacks;
    const testgp = 9000;
    var i, m1, mn, mq, ovflw: integer;
    begin
      m1 := MapInfo^[x, y];
      ovflw := 0;
      with CombatDefs^[Def] do
        for i := 1 to 4 do begin
          if (i <= 3) or (m1 + 1 = moAssassin) then
            mn := m1
          else if MonsterLevel(m1) = 6 then
            mn := m1 - 5
          else
            mn := m1 + 1;
          mq := (testgp + ovflw) div MonsterData[mn].cost;
          ovflw := (testgp + ovflw) mod MonsterData[mn].cost;
          if MonsterHasFlag(mn, 4, f4Multiplies) then
            inc(mq, mq div 10);
          AddXPStack(startpos[2, i].x, startpos[2, i].y, 2, mn, mq, 0, 0);
        end;
    end;

  procedure AddCacheStacks;
    var
      c, i, j, n: integer;
    begin
      c := Def - cdCache + 1;
      with CombatDefs^[Def] do begin
        n := 1;
        for i := 1 to 3 do
          if CacheMonsters[c, i, 1] <> 0 then
            for j := 1 to CacheMonsters[c, i, 2] do begin
              AddXPStack(startpos[2, n].x, startpos[2, n].y, 2,
                         CacheMonsters[c, i, 1], CacheMonsters[c, i, 3],
                         0, 0);
              inc(n);
            end;
      end;
    end;

  procedure AddDwellingStacks(m, q: integer);
    var i, piles: integer;
    begin
      piles := 4 + 2 * random(3);
      if piles > q then piles := q;
      with CombatDefs^[Def] do
        for i := 1 to piles do
          AddXPStack(startpos[2, i].x, startpos[2, i].y, 2, m,
                     (q + i - 1) div piles, 0, 0);
    end;

  procedure AddBarbicans;
    const
      ay: array [1..12] of byte =
      (
        1, 12, 6, 3, 9, 4, 11, 2, 7, 5, 8, 10
      );
    var
      i, j, arr: integer;
    begin
      arr := 0;

      for i := 1 to 8 do
        for j := 1 to 8 do
          if Castle[town].Grid[i, j] = bBarbican then
            inc(arr);

      if arr > 12 then arr := 12;

      if arr > 0 then
        for i := 1 to arr do
          CombatDefs^[def].cmap[12, ay[i]] := cmBarbican;

      if arr < 12 then
        for i := arr + 1 to 12 do
          CombatDefs^[def].cmap[12, ay[i]] := cmGrass;
    end;

  procedure RecoverArmy(p: PArmySet; side, slots: integer);
    var
      i, st: integer;
      qh: array [1..MaxSlots] of integer;
    begin
      with ACombat^ do begin
        for i := 1 to MaxSlots do qh[i] := 0;

        for st := 1 to StackMax do
          if Stacks[st].qty > 0 then
            if (Stacks[st].side = side) and (Stacks[st].armyslot > 0) then
              inc(qh[Stacks[st].armyslot], Stacks[st].qty);

        for i := 1 to MaxSlots do
          p^[i].qty := qh[i];

        for st := 1 to StackMax do
          if (Stacks[st].qty > 0) and (Stacks[st].side = side)
             and (Stacks[st].armyslot = -1) then
            GainMonster(p, slots, Stacks[st].realmonster, Stacks[st].qty);
      end;
    end;

  procedure RecoverMap;
    var qf, st: integer;
    begin
      with ACombat^ do begin
        qf := 0;

        for st := 1 to StackMax do
          if (Stacks[st].qty > 0) and (Stacks[st].side = 2)
             and (Stacks[st].armyslot = 1) then
            inc(qf, Stacks[st].qty);

        if qf = 0 then
          TheMap^[x, y] := mGrass
        else
          MapNum^[x, y] := qf;
      end;
    end;

  procedure HealHero(h, side: integer);
    var
      c, gp, healgp, q: longint;
      i, bestgp, besti, mons, healtimes, j: integer;
      s: string;
    begin
      healgp := GetEffSkillLevel(h, skHealing) * HealingAmt
                + NumTroopsWithFlag(h, 6, f6Healing) * 35;
      if healgp > 0 then begin
        if HeroHasExpertiseBonus(h, skHealing) then
          healtimes := 2
        else
          healtimes := 1;
        for j := 1 to healtimes do begin
          besti := 0;
          bestgp := 0;
          for i := 1 to MaxSlots do
            if (Hero^[h].army[i].qty > 0)
               and (Hero^[h].army[i].qty < startarmy[side][i].qty)
               and (Hero^[h].army[i].monster
                    = startarmy[side][i].monster) then begin
              c := MonsterData[Hero^[h].army[i].monster].cost;
              gp := (startarmy[side][i].qty - Hero^[h].army[i].qty) * c;
              if gp > healgp then
                gp := (healgp div c) * c;
              if gp > bestgp then begin
                bestgp := gp;
                besti := i;
              end;
            end;
          if besti > 0 then begin
            mons := Hero^[h].army[besti].monster;
            q := bestgp div MonsterData[mons].cost;
            inc(Hero^[h].army[besti].qty, q);
            if q = 1 then
              s := MonsterData[mons].name
            else
              s := MonsterData[mons].pname;
            if not player[Hero^[h].player].AI then begin
              Dialog(dgcFace + chr(h) + Hero^[h].name + ' uses the power of '
                     + 'Healing to revive ' + IStr(q, 0) + ' ' + s + '!',
                     0, 0, 0, 0, '', '', '', '');
              DrawnWindow := -1;
              Window := winHero;
            end;
            dec(healgp, q * MonsterData[mons].cost);
          end;
        end;
      end;
    end;

  procedure FindWinner;
    var i: integer;
    begin
      winner := 2;

      with ACombat^ do
        for i := 1 to StackMax do
          if (Stacks[i].qty > 0) {and (Stacks[i].armyslot <> 0)}
             and (Stacks[i].side = 1) then
              winner := 1;
    end;

  procedure ShowResult(h, side: integer);
    var
      s: string;
      losses, gains: TArmySet;
      i, startm, endm, startq, endq, vm: integer;
    begin
      s := dgcFace + chr(h) + Hero^[h].Name + ' is triumphant! ('
           + IStr(xp[side], 0) + ' xp)';

      for i := 1 to MaxSlots do begin
        if i > HeroSlots(h) then begin
          losses[i] := NilArmy;
          gains[i] := NilArmy;
        end else begin
          startm := startarmy[side][i].monster;
          startq := startarmy[side][i].qty;
          endm := Hero^[h].army[i].monster;
          endq := Hero^[h].army[i].qty;
          if (startm = endm) or (endq = 0) then begin
            if startq > endq then begin
              losses[i].monster := startm;
              losses[i].qty := startq - endq;
              gains[i] := NilArmy;
            end else if startq < endq then begin
              losses[i] := NilArmy;
              gains[i].monster := startm;
              gains[i].qty := endq - startq;
            end else begin
              losses[i] := NilArmy;
              gains[i] := NilArmy;
            end;
          end else begin
            if startarmy[side][i].qty > 0 then begin
              losses[i] := startarmy[side][i];
            end else begin
              losses[i] := NilArmy;
            end;
            if Hero^[h].army[i].qty > 0 then begin
              gains[i] := Hero^[h].army[i];
            end else begin
              gains[i] := NilArmy;
            end;
          end;
        end;
      end;

      Window := winHero;
      DrawnWindow := -1;
      Draw;
      repeat
        vm := VictoryMessage(s, @losses, @gains, HeroSlots(h));
        ClearDrawn;
        if vm = -1 then begin
          DoHeroScreen(h, true);
          Draw;
        end;
      until vm <> -1;
    end;

  type
    TFight = (ftMap, ftDwelling, ftCache, ftHero, ftHeroCastle,
              ftGarrison, ftHordeDwelling);
  var
    fhero: array [1..2] of integer;
    side, md, g, pl, n: integer;
    ft: TFight;
    quick: boolean;
    s: string;
    startav, endav, xpamt: longint;
    testarmy, savearmy, savegarrison: TArmySet;
    DefenderAI: boolean;
  begin
    md := TheMap^[x, y];

    fHero[1] := ActiveHero;
    fHero[2] := HeroAtSpot(x, y);
    if fhero[2] = ActiveHero then fhero[2] := 0;

    if not test then
      for side := 1 to 2 do
        if fhero[side] <> 0 then begin
          inc(Hero^[fhero[side]].MP,
              CountArt(fhero[side], anSwordoftheWarrior, true));
          GiveMana(fhero[side],
                   3 * CountArt(fhero[side], anRingoftheWarlock, true));
          n := GetEffSkillLevel(fhero[side], skWarcraft);
          if n > 0 then
            GiveWarcraft(fhero[side], n);
        end;

    startsp[1] := Hero^[ActiveHero].SP;
    if fhero[2] <> 0 then startsp[2] := Hero^[fhero[2]].SP;
    startav := ArmySetGP(@Hero^[fhero[1]].army);
    if test and (fhero[2] <> 0) then begin
      DefenderAI := Player[Hero^[fhero[2]].player].AI;
      if not DefenderAI then Player[Hero^[fhero[2]].player].AI := true;
    end;

    if (fhero[2] <> 0) and (md >= mCastle) and (md <= mLastCastle) then
      ft := ftHeroCastle
    else if fhero[2] <> 0 then
      ft := ftHero
    else if (md >= mCastle) and (md <= mLastCastle) then
      ft := ftGarrison
    else if (md = mDwelling) then
      ft := ftDwelling
    else if (md = mHordeDwelling) then
      ft := ftHordeDwelling
    else if md = mCache then
      ft := ftCache
    else
      ft := ftMap;

    if ft in [ftGarrison, ftHeroCastle] then
      town := MapInfo^[x, y]
    else
      town := 0;

    case ft of
      ftMap,
      ftHero:          def := CombatDefFor(MapGeos, x, y);
      ftDwelling:      def := cdDwelling
                              + ((MapInfo^[x, y] and $7F) - 1) mod 6 - 2;
      ftHordeDwelling: def := cdDwelling;
      ftCache:         def := cdCache + MapInfo^[x, y] - 1;
      ftGarrison,
      ftHeroCastle:    def := cdCastle;
    end;

    if town <> 0 then AddBarbicans;

    ACombat := New(PCombat, Init(true, fhero[1], fhero[2], def,
                                 ClimateColor[Climate^[x, y] and $07]));

    for side := 1 to 2 do xp[side] := 0;
    persuasiongp := HeroPersuasionGP(fhero[1]);
    persuasioncrs := 0;
    persuasionstr := '';
    persuasionbonus := HeroHasExpertiseBonus(fhero[1], skPersuasion);

    if Player[Hero^[fhero[1]].player].AI then begin
      case spread of
        0: ConserveSlots(@Hero^[fhero[1]].army, HeroSlots(fhero[1]));
        1: SpreadOut(fhero[1], false);
        2: SpreadOut(fhero[1], true);
        3: ;
      end;
    end;
    AddHeroStacks(fhero[1], 1);

    case ft of
      ftMap:        if test and (x = 1) and (y = 1) then
                      AddTestStacks
                    else
                      AddMapStacks;
      ftDwelling:   begin
                      n := MapInfo^[x, y] and $7F;
                      AddDwellingStacks(n, DwellingGuardsQty(n));
                    end;
      ftHordeDwelling: AddDwellingStacks(MonsterForLevel(Hero^[fhero[1]].CT,
                                                         1), 80);
      ftCache:      AddCacheStacks;
      ftHero:       AddHeroStacks(fhero[2], 2);
      ftHeroCastle: begin
                      savearmy := Hero^[fhero[2]].army;
                      savegarrison := Castle[town].Garrison;
                      GarrisonToHero(@Castle[town], fhero[2]);
                      AddHeroStacks(fhero[2], 2);
                      if test then begin
                        Hero^[fhero[2]].army := savearmy;
                        Castle[town].Garrison := savegarrison;
                      end;
                    end;
      ftGarrison:   begin
                      AddGarrisonStacks;
                      if (Castle[town].player <> 0)
                         and not Player[Castle[town].player].AI then
                        ACombat^.SV[2].AI := false;
                    end;
    end;

    quick := ACombat^.SV[1].AI and ACombat^.SV[2].AI;

    if persuasioncrs > 0 then begin
      if persuasioncrs > 1 then s := 's' else s := '';
      if not quick then
        Dialog(dgcFace + chr(fhero[1]) + 'Through the power of persuasion, '
               + Hero^[fhero[1]].Name + ' gains control of '
               + IStr(persuasioncrs, 0) + ' creature' + s + '! '
               + chr(colLightGray) + '(' + persuasionstr + ')',
               0, 0, 0, 0, '', '', '', '');
    end;

    if quick then
      ACombat^.QuickCombat
    else
      ACombat^.HandleCombat;

    FindWinner;

    if test then begin
      testarmy := Hero^[fhero[1]].army;
      RecoverArmy(@testarmy, 1, HeroSlots(fhero[1]));
      endav := ArmySetGP(@testarmy);
    end else begin
      RecoverArmy(@Hero^[fhero[1]].army, 1, HeroSlots(fhero[1]));
      endav := ArmySetGP(@Hero^[fhero[1]].army);

      case ft of
        ftMap:        RecoverMap;
        ftDwelling,
        ftHordeDwelling,
        ftCache:      ; { respawn }
        ftHero,
        ftHeroCastle: RecoverArmy(@Hero^[fhero[2]].army, 2, HeroSlots(fhero[2]));
        ftGarrison:   RecoverArmy(@Castle[town].Garrison, 2, 6);
      end;
    end;

    Dispose(ACombat, Done);

    if not quick then Recover;

    if not test then begin
      for side := 1 to 2 do
        if fhero[side] <> 0 then begin
          if side = winner then begin
            if not Player[Hero^[fhero[side]].player].AI then
              ShowResult(fhero[side], side);
            xpamt := XPAfterCunning(fhero[side], xp[side]);
            inc(xpamt, xpamt
                       * (CountArt(fhero[side], anBowoftheRanger, true)
                          + 2 * CountArt(fhero[side], anRingoftheSage, true))
                       div 20);
            GiveHeroXP(fhero[side], xpamt);
            HealHero(fhero[side], side);
            if (side = 1) and (ft in [ftHeroCastle, ftGarrison]) then begin
              pl := Castle[town].player;
              GainCastle(Turn, town);
              for g := 1 to 6 do
                Castle[town].Garrison[g] := NilArmy;
              ClearDrawn;
              Draw;
              CheckDeath(pl);
            end;
            if ft in [ftHero, ftHeroCastle] then
              TakeArts(fhero[side], fhero[3 - side]);
          end else begin
            if not quick then
              Dialog(dgcFace + chr(fhero[side]) + Hero^[fhero[side]].name
                     + ' is defeated!', 0, 0, 0, 0, '', '', '', '');
            pl := Hero^[fhero[side]].player;
            KillHero(fhero[side]);
            if side = 1 then
              ActiveHero := 0;
            Draw;
            CheckDeath(pl);
          end;
        end;
    end;

    if test or ((winner = 1) and (Player[Hero^[fhero[1]].player].AI)) then
      ConserveSlots(@Hero^[fhero[1]].army, HeroSlots(fhero[1]));

    if test then begin
      Hero^[ActiveHero].SP := startsp[1];
      if fhero[2] <> 0 then begin
        Player[Hero^[fhero[2]].player].AI := DefenderAI;
        Hero^[fhero[2]].SP := startsp[2];
      end;
    end;

    LowFight := startav - endav;
  end;

function TMapScr.Fight(x, y: integer; test: boolean): longint;
  var
    spread, i: integer;
    f, bestf: longint;
  begin
    spread := 1;

    if not test and Player[Hero^[ActiveHero].player].AI
       and (HeroAtSpot(x, y) = 0) then begin
      for i := 0 to 2 do begin
        f := LowFight(x, y, true, i);
        if (i = 0) or (f < bestf) then begin
          spread := i;
          bestf := f;
        end;
      end;
    end;

    Fight := LowFight(x, y, test, spread);
  end;

function TMapScr.Dialog(s: string; pic1, pic2, pic3, pic4: integer;
                           s1, s2, s3, s4: string): integer;
  var choice: integer;
  begin
    repeat
      choice := BaseDialog(s, pic1, pic2, pic3, pic4, s1, s2, s3, s4);
      ClearDrawn;
      if choice = -1 then begin
        DoHeroScreen(ord(s[2]), true);
        Draw;
      end;
    until choice <> -1;
    Dialog := choice;
  end;

procedure TMapScr.Message(s: string);
  begin
    if not Player[Turn].AI then
      Dialog(s, 0, 0, 0, 0, '', '', '', '');
  end;

procedure TMapScr.GiveHeroXP(h: integer; xp: longint);
  const GivingAllXP: boolean = false;
  var
    d, lore, w, i, n, c1, c2: integer;
    skc: TSkillChoices;
    DA: TDialogArr;
  begin
    inc(Hero^[h].XP, xp);

    while Hero^[h].XP > XPForLevel(Hero^[h].level) do begin
      w := Window;

      if not Player[Hero^[h].player].AI then begin
        ClearWindow(winSkills);
        DrawHeroWindow(h, winSkills);
      end;


      inc(Hero^[h].level);
      GetSkillChoices(h, skc);

      if Player[Hero^[h].player].AI then
        d := AIPickSkill(h, skc)
      else begin
        for i := 1 to 5 do
          if skc[i] <> 0 then begin
            n := i;
            DA[i].pic := dgSkill + skc[i];
            DA[i].s := SkillStr(h, skc[i], 1);
{                      SkillNames[skc[i]] + ' '
                       + IStr(1 + GetSkillLevel(h, skc[i]), 0); }
          end;

        repeat
          d := BaseDialogN(dgcFace + chr(h) + Hero^[h].Name
                           + ' goes up a level and gains a skill!',
                           @DA, n, 1);
          if d = -1 then DoHeroScreen(h, true);
        until d <> -1;
      end;

      GainSkillLevel(h, skc[d]);

      lore := GetEffSkillLevel(h, skLore);
      if lore > 0 then begin
        if lore > 3 then lore := 3;
        c1 := RandomNewSpell(Hero^[h].SS, lore, 0, true);
        c2 := RandomNewSpell(Hero^[h].SS, lore + 1, c1, true);
        if Player[Hero^[h].player].AI then begin
          if (c1 = 0) or (c2 = 0) then begin
            if (c1 = 0) and (c2 = 0) then
              d := 0
            else if c1 = 0 then
              d := 2
            else
              d := 1;
          end else
            d := AIPickSpell(h, c1, c2);
        end else begin
          if (c1 = 0) or (c2 = 0) then begin
            if (c1 = 0) and (c2 = 0) then
              d := 0
            else begin
              if c1 = 0 then
                d := 2
              else
                d := 1;
              if d = 2 then c1 := c2;
              Message(dgcFace + chr(h) + 'Through studies of Lore, '
                      + Hero^[h].Name + ' learns ' + SpellData[c1].name + '!');
            end;
          end else
            d := Dialog(dgcFace + chr(h) + 'Through studies of Lore, '
                        + Hero^[h].Name + ' also learns a spell!', dgSpell,
                        dgSpell, 0, 0, SpellHintStr(c1, h, 0),
                        SpellHintStr(c2, h, 0), '', '');
        end;
        case d of
          1: AddSpell(Hero^[h].SS, c1);
          2: AddSpell(Hero^[h].SS, c2);
        end;
      end;

      if not Player[Hero^[h].player].AI then begin
        Window := w;
        DrawnWindow := -1;
        DrawWindow;
      end;
    end;

    if Twists[twAllGainXP] and not GivingAllXP
       and (Hero^[h].player <> 0) then begin
      GivingAllXP := true;

      for i := 1 to MaxDudes do begin
        n := Player[Hero^[h].player].Dudes[i];
        if (n <> 0) and (n <> h) then
          GiveHeroXP(n, xp);
      end;

      GivingAllXP := false;
    end;

    SortHeroes(Turn);
    if VisibleTurn then DrawBars;
  end;

procedure TMapScr.VisitHero(h: integer);
  var HTS: PHeroTalkScr;
  begin
    if HeroHasExpertiseBonus(ActiveHero, skSpellcraft)
       or HeroHasExpertiseBonus(h, skSpellcraft) then begin
      AddSpellSet(Hero^[ActiveHero].SS, Hero^[h].SS);
      AddSpellSet(Hero^[h].SS, Hero^[ActiveHero].SS);
    end;

    if Player[Turn].AI then
      AIHeroTalk(ActiveHero, h)
    else begin
      HTS := New(PHeroTalkScr, Init(ActiveHero, h));
      HTS^.Handle;
      Dispose(HTS, Done);
      Recover;
    end;
  end;

procedure TMapScr.VisitSpot(x, y: integer);
  var
    gi, gj, m, n, h, nx, ny, n1, n2, rand, diff, a, dv, pl: integer;
    r, r2: TResource;
    s: string;
    c, c1, c2, gp, xp: longint;
    AIP, gotone: boolean;
    hb: THermitBonus;

  procedure BuyFromDwelling(qty: integer);
    begin
      dec(Player[Turn].Resources[rGold], qty * MonsterData[n].cost);
      GainMonster(@Hero^[ActiveHero].army, HeroSlots(ActiveHero), n, qty);
      dec(MapNum^[x, y], qty);
    end;

  procedure UpgradeStack(sl: integer);
    begin
      Message('Your '
              + MonsterData[Hero^[ActiveHero].army[sl].monster].pname
              + ' become '
              + MonsterData[Hero^[ActiveHero].army[sl].monster + 1].pname
              + '!');
      inc(Hero^[ActiveHero].army[sl].monster);
    end;

  begin
    m := TheMap^[x, y];
    gi := GeoX(x);
    gj := GeoY(y);
    rand := MapGeos^[gi, gj].rand;
    diff := MapGeos^[gi, gj].diff - 1;
    pl := Hero^[ActiveHero].player;
    AIP := Player[pl].AI;

    if Window = winMessage then
      Window := winResources
    else
      DrawnWindow := -1;

    if (m >= mRezGold) and (m <= mRezClay) then begin
      r := TResource(m - mRezGold);
      n := RezAmt(r, rand + x);
      inc(Player[Turn].Resources[r], n);
      TheMap^[x, y] := mGrass;
      ClearWindow(winMessage);
      WDrawText(WindowX, WindowY, colBlack, colWhite,
                'Gained ' + IStr(n, 0) + ' ' + RezChr(r) + '.');
      DrawResources(WindowX, WindowY + 5 + 13);
    end else if (m = mArtifact) then begin
      ClearWindow(winMessage);
      WDrawBoxText(WindowX, WindowY + 12, WindowX2, colBlack, colLightBlue,
                   ArtData[MapInfo^[x, y]].name);
      if EquipArt(ActiveHero, MapInfo^[x, y]) then
        s := '(worn)'
      else if PackArt(ActiveHero, MapInfo^[x, y]) then
        s := '(pack)'
      else
        s := '';
      if s <> '' then begin
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Gained ' + s + ':');
        TheMap^[x, y] := mGrass;
      end else begin
        WDrawText(WindowX, WindowY, colBlack, colRed, 'Can''t Carry:');
      end;
    end else if (m = mSpellPavilion) then begin
      ClearWindow(winMessage);
      n := MapInfo^[x, y];
      if CheckForSpell(Hero^[ActiveHero].SS, n) then begin
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Already know:');
      end else begin
        AddSpell(Hero^[ActiveHero].SS, n);
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Learned:');
        if Twists[twOneUseBuildings] then TheMap^[x, y] := mRocky;
      end;
      WDrawText(WindowX, WindowY + 12, colBlack,
                SpellSlantColor[SpellData[n].slant], SpellData[n].name);
      MapNum^[x, y] := MapNum^[x, y] or BitTable[Turn];
    end else if (m >= mGoldMine) and (m <= mSkillMine) then begin
      ClearWindow(winMessage);
      if MapNum^[x, y] = pl then
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Already owned:')
      else begin
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Claimed:');
        if (m = mSkillMine) then begin
          if MapNum^[x, y] <> 0 then
            dec(Player[MapNum^[x, y]].SkillMines[MapInfo^[x, y]]);
          inc(Player[pl].SkillMines[MapInfo^[x, y]]);
        end;
        MapNum^[x, y] := pl;
        MapNum^[x + 1, y] := pl;
      end;
      if m = mSkillMine then
        c := colWhite
      else
        c := ResourceColors[TResource(m - mGoldMine)];
      WDrawBoxText(WindowX, WindowY + 12, WindowX2, colBlack, c, MineName(x, y));
      if (m = mSkillMine) and (MapInfo^[x, y] = skSpellCraft) then
        for n := 1 to NumHeroes do
          LimitMana(n);
    end else if m = mChest then begin
      if ((rand + x + y * 2) mod 50 = 0)
         and (FoundMaps < NumTreasureMaps)
         and GainArt(ActiveHero, anTreasureMap1 + FoundMaps) then begin
        n := 1000 + diff * 250;
        Message('The chest has ' + GoldStr(n) + ', plus a treasure map...');
        inc(Player[Turn].Resources[rGold], n);
        inc(FoundMaps);
      end else begin
        n := 500 + diff * 200;
        if (rand + x) mod 2 = 0 then inc(n, 500);
        xp := XPAfterCunning(ActiveHero, n);
        if AIP then begin
          if (Date >= 14) and ((n >= 1500)
                               or (Player[Turn].Resources[rGold] >= 10000)) then
            dv := 2
          else
            dv := 1;
        end else
          dv := Dialog(dgcFace + chr(ActiveHero)
                       + 'The chest is full of gold! You can keep it, or give '
                       + 'it to charity, for experience.', dgGold, dgXP, 0, 0,
                       GoldStr(n + 500), IStr(xp, 0) + ' XP '
                       + chr(colLightGray) + '(need '
                       + NeededXPStr(ActiveHero) + ')', '', '');
        case dv of
          1: inc(Player[Turn].Resources[rGold], n + 500);
          2: GiveHeroXP(ActiveHero, xp);
        end;
      end;
      if HeroHasExpertiseBonus(ActiveHero, skWarcraft) then
        inc(Hero^[ActiveHero].MP);
      TheMap^[x, y] := mGrass;
    end else if m = mBarrel then begin
      if ((rand + x * 2 + y) mod 8 = 0)
         and FindNeutralMine(nx, ny) then begin
        MapNum^[nx, ny] := pl;
        MapNum^[nx + 1, ny] := pl;
        if TheMap^[nx, ny] = mSkillMine then
          inc(Player[pl].SkillMines[MapInfo^[nx, ny]]);
        Message('The barrel has a deed to a ' + MineName(nx, ny) + '!');
        RevealArea(nx, ny, 4);
        CenterOn(nx, ny);
      end else begin
        r := TResource((rand + x) mod 6 + 1);
        r2 := TResource((rand + y) mod 6 + 1);
        if r = r2 then r2 := TResource(5 - (ord(r2) - 1) + 1);
        n1 := RezAmt(r, rand + x * 3 + y);
        n2 := RezAmt(r, rand + x + y * 3);
        n := 500 + diff * 250;
        inc(Player[Turn].Resources[r], n1);
        inc(Player[Turn].Resources[r2], n2);
        inc(Player[Turn].Resources[rGold], n);
        Message('The barrel is full of treasure! You find '
                + IStr(n1, 0) + '_' + RezChr(r) + ', '
                + IStr(n2, 0) + '_' + RezChr(r2) + ', and '
                + GoldStr(n) + '.');
      end;
      TheMap^[x, y] := mGrass;
    end else if m = mBag then begin
      if HasArt(ActiveHero, 0, false) then begin
        if (rand + x + 2 * y) mod 2 = 0 then begin
          if diff <= 4 then
            n := RandomArtifact(1)
          else if diff <= 8 then
            n := RandomArtifact(2)
          else
            n := RandomArtifact(3);
          xp := XPAfterCunning(ActiveHero, 500 + diff * 200);
          if AIP then begin
            if ((ArtData[n].level >= 2) or (Hero^[ActiveHero].level < 8))
               and not (n in [anGlovesOfTheFieryTitan, anGlovesOfCourage,
                              anWandOfBlessings, anWandOfCurses,
                              anPortableHole]) then
              dv := 1
            else
              dv := 2;
          end else begin
            ClearWindow(winArtSlot + ArtData[n].slot);
            DrawHeroWindow(ActiveHero, winArtSlot + ArtData[n].slot);
            dv := Dialog(dgcFace + chr(ActiveHero) + 'The bag has 1000 '
                         + crGold + ', plus ' + AnArtName(n)
                         + '! You keep the gold; you can keep the artifact, '
                         + 'or dismantle and study it, for experience.',
                         dgArtifact + n, dgXP, 0, 0,
                         ArtData[n].name + ' - ' + chr(colLightGray)
                         + ArtHelp^[n],
                         IStr(xp, 0) + ' XP ' + chr(colLightGray) + '(need '
                         + NeededXPStr(ActiveHero) + ')', '', '');
          end;
          case dv of
            1: GainArt(ActiveHero, n);
            2: GiveHeroXP(ActiveHero, xp);
          end;
        end else begin
          if diff < 4 then begin
            n := anBagOfJunk;
            s := 'junk';
          end else if diff < 8 then begin
            n := anBagOfBaubles;
            s := 'baubles';
          end else begin
            n := anBagOfJewelry;
            s := 'jewelry';
          end;
          Message('The bag is full of ' + s + '. You take it with you; '
                  + 'maybe you can sell it at a town.');
          GainArt(ActiveHero, n);
        end;
      end else begin
        Message('The bag has 1000 ' + crGold + ' and a bunch of junk. You can '
                + 'only carry so much stuff; you keep the gold and bury the '
                + 'rest of it.');
      end;
      inc(Player[Turn].Resources[rGold], 1000);
      TheMap^[x, y] := mGrass;
    end else if m = mPotion then begin
      n1 := 0;
      n2 := 0;
      c1 := 0;
      c2 := 0;
      for n := 1 to HeroSlots(ActiveHero) do
        if (Hero^[ActiveHero].army[n].qty > 0)
           and ((Hero^[ActiveHero].army[n].monster - 1) mod 6 <> 5) then begin
          c := Hero^[ActiveHero].army[n].qty;
          c := c * MonsterData[Hero^[ActiveHero].army[n].monster + 1].cost
               - c * MonsterData[Hero^[ActiveHero].army[n].monster].cost;
          if c <= 500 + diff * 500 then begin
            if c1 = 0 then begin
              c1 := c;
              n1 := n;
            end else if c2 = 0 then begin
              c2 := c;
              n2 := n;
            end else if c > c1 then begin
              c1 := c;
              n1 := n;
            end else if c > c2 then begin
              c2 := c;
              n2 := n;
            end;
          end;
        end;
      if ((rand + x) mod 4 = 0) and (n1 <> 0) and (n2 <> 0) then begin
        if AIP then begin
          if c1 >= c2 then n := 1
          else n := 2;
        end else
          n := Dialog('You give the potion to some of your troops...',
                      Hero^[ActiveHero].army[n1].monster,
                      Hero^[ActiveHero].army[n2].monster,
                      dgCancel, 0,
                      IStr(Hero^[ActiveHero].army[n1].qty, 0) + ' '
                      + MonsterData[Hero^[ActiveHero].army[n1].monster].pname,
                      IStr(Hero^[ActiveHero].army[n2].qty, 0) + ' '
                      + MonsterData[Hero^[ActiveHero].army[n2].monster].pname,
                      'Cancel', '');
        if n = 3 then
          Message('Your troops are fine the way they are.')
        else begin
          if n = 1 then n := n1 else n := n2;
          UpgradeStack(n);
        end;
      end else if ((rand + y) mod 2 = 0)
                  or (Hero^[ActiveHero].SkillLevel[1] = 0) then begin
        for n := 1 to MaxDudes do begin
          h := Player[pl].Dudes[n];
          if h <> 0 then begin
            inc(Hero^[h].MP, diff + 2);
            GiveMana(h, diff * 6 + 10);
          end;
        end;
        Message('You drink the potion... and feel a powerful connection to '
                + 'the astral plane! All of your heroes gain '
                + IStr(diff + 2, 0) + ' movement and '
                + IStr(diff * 3 + 5, 0) + ' spell points!');
      end else begin
        n := 5;
        while Hero^[ActiveHero].SkillLevel[n] = 0 do dec(n);
        n := ((rand + x * 7) mod n) + 1;
        inc(Hero^[ActiveHero].SkillLevel[n]);
        Message('You drink the potion... and gain a level of '
                + SkillNames[Hero^[ActiveHero].Skill[n]] + '!');
      end;
      TheMap^[x, y] := mGrass;
    end else if m = mCamp then begin
      s := IStr(MapNum^[x, y], 0) + ' ' + MonsterData[MapInfo^[x, y]].pname;
      if GainMonster(@Hero^[ActiveHero].army, HeroSlots(ActiveHero),
                     MapInfo^[x, y], MapNum^[x, y]) then begin
        Message(s + ' join you!');
        TheMap^[x, y] := mGrass;
      end else begin
        Message(s + ' would join you, but you have no room in your army.');
      end;
    end else if m = mMonument then begin
      if GetVisited(ActiveHero, gi, gj, hvMonument) then begin
        Message('You have already visited this Monument.');
      end else begin
        xp := XPAfterCunning(ActiveHero, 1000 + 250 * diff);
        SetVisited(ActiveHero, gi, gj, hvMonument);
        Message('You read the plaque on the Monument, and are enlightened '
                + '(' + IStr(xp, 0) + ' XP).');
        GiveHeroXP(ActiveHero, xp);
      end;
      if Twists[twOneUseBuildings] then TheMap^[x, y] := mRocky;
    end else if m = mSchool then begin
      if GetVisited(ActiveHero, gi, gj, hvSchool) then begin
        Message('You have already learned all that this school can teach you.');
      end else begin
        n := MapInfo^[x, y];
        if (n > NumNSkills) and (GetSkillLevel(ActiveHero, n) = 3) then begin
          Message('This school teaches lessons in ' + SkillNames[n]
                  + '. Sadly, you already know all there is to know about '
                  + 'that.');
        end else if CanGainSkillLevel(ActiveHero, n) then begin
          if n = Hero^[ActiveHero].Expertise then begin
            Message('At the school, you learn even more than usual about '
                    + SkillNames[n] + '.');
            GainSkillLevel(ActiveHero, n);
          end else
            Message('At the school, you learn much about '
                    + SkillNames[n] + '.');
          GainSkillLevel(ActiveHero, n);
          SetVisited(ActiveHero, gi, gj, hvSchool);
          if Twists[twOneUseBuildings] then TheMap^[x, y] := mRocky;
        end else begin
          Message('This school teaches lessons in ' + SkillNames[n]
                  + '. Sadly, you have no room in your life for such studies.');
        end;
        MapNum^[x, y] := MapNum^[x, y] or BitTable[Turn];
      end;
    end else if (m = mDwelling) or (m = mHordeDwelling) then begin
      Window := winResources;
      DrawWindow;
      n := MapInfo^[x, y];
      if m = mHordeDwelling then
        n := (n and $80) or MonsterForLevel(Hero^[ActiveHero].CT, 1);
      if (n and $80) <> 0 then begin
        Fight(x, y, false);
        if ActiveHero <> 0 then MapInfo^[x, y] := MapInfo^[x, y] and $7F;
      end;
      if ActiveHero <> 0 then begin
        n := n and $7F;
        n1 := MonsterData[n].cost;
        n2 := n1 * MapNum^[x, y];
        if n2 > Player[Turn].Resources[rGold] then
          n2 := (Player[Turn].Resources[rGold] div MonsterData[n].cost)
                * MonsterData[n].cost;
        if MapNum^[x, y] = 1 then
          s := 'is 1 ' + MonsterData[n].name
        else
          s := 'are ' + IStr(MapNum^[x, y], 0) + ' ' + MonsterData[n].pname;
        if MapNum^[x, y] = 0 then begin
          Message('Some ' + MonsterData[n].pname + ' live here, but there are '
                  + 'none at home right now.');
        end else if n2 = 0 then begin
          Message('There ' + s + ' living here, but you don''t have enough '
                  + 'gold to hire any.');
        end else if FindEmptyOrMonster(@Hero^[ActiveHero].army,
                                       HeroSlots(ActiveHero), n) = 0 then begin
          Message('There ' + s + ' living here, but you have no room in your '
                  + 'army for any.');
        end else if n1 = n2 then begin
          if AIP then
            dv := 1
          else
            dv := Dialog('There ' + s + ' living here. You have enough gold '
                         + 'to hire one.', dgBuy1, dgCancel, 0, 0,
                         'Buy one for ' + GoldStr(n1), 'Cancel', '', '');
          if dv = 1 then
            BuyFromDwelling(1);
        end else begin
          if AIP then
            dv := 2
          else
            dv := Dialog('There ' + s + ' living here. You can hire up to '
                         + IStr(n2 div MonsterData[n].cost, 0) + '.', dgBuy1,
                         dgBuyAll, dgCancel, 0,
                         'Buy one for ' + GoldStr(n1),
                         'Buy ' + IStr(n2 div MonsterData[n].cost, 0) + ' for '
                         + GoldStr(n2), 'Cancel', '');
          case dv of
            1: BuyFromDwelling(1);
            2: BuyFromDwelling(n2 div MonsterData[n].cost);
            3: ;
          end;
        end;
      end;
    end else if m = mFarmstead then begin
      if MapNum^[x, y] = 1 then begin
        MapNum^[x, y] := 0;
        MapNum^[x + 1, y] := 0;
        inc(Player[Turn].Resources[rGold], 1000);
        Message('You collect 1000 ' + crGold + ' for "protection" from the '
                + 'farmer.');
      end else begin
        Message('Someone has already collected "protection" from this '
                + 'farmer this week.');
      end;
    end else if m = mMiningVillage then begin
      if MapNum^[x, y] = 1 then begin
        MapNum^[x, y] := 0;
        r := TResource(MapInfo^[x, y]);
        inc(Player[Turn].Resources[r], 5);
        Message('You collect 5 ' + RezChr(r) + ' for "protection" from the '
                + 'miner.');
      end else begin
        Message('Someone has already collected "protection" from this '
                + 'miner this week.');
      end;
    end else if m = mAltar then begin
      n := MapInfo^[x, y];
      Hero^[ActiveHero].AltarBonus := n;
      Hero^[ActiveHero].AltarDays := 3;
      Message('You sacrifice a goat at the Altar of the ' + Altars[n].name
              + '. For 3 days, your troops gain "' + AltarAbilityStr(n)
              + '."');
      MapNum^[x, y] := MapNum^[x, y] or BitTable[Turn];
    end else if m = mShrine then begin
      n := MapInfo^[x, y];
      Hero^[ActiveHero].ShrineBonus := n;
      Hero^[ActiveHero].ShrineDays := 3;
      Message('You meditate in the Shrine of ' + SkillNames[n]
              + '. For 3 days, you gain +2 ' + SkillNames[n] + '.');
      MapNum^[x, y] := MapNum^[x, y] or BitTable[Turn];
      LimitMana(ActiveHero);
    end else if m = mWatchTower then begin
      RevealArea(x, y, 14);
      ClearWindow(winMessage);
      WDrawBoxText(WindowX, WindowY, WindowX2, colBlack, colWhite,
                   'From the top of the Watchtower, you can see for miles.');
    end else if m = mJunkMerchant then begin
      Window := winResources;
      DrawWindow;
      for n := 1 to BackpackSize do begin
        a := Hero^[ActiveHero].Backpack[n];
        if (a <> 0) and (ArtData[a].level = 1) then begin
          if AIP then
            dv := 1
          else
            dv := Dialog('"Looks like you''ve got ' + AnArtName(a) + ' you '
                         + 'aren''t using. I''ll give you 1500 ' + crGold
                         + ' for it."', dgGold, dgCancel, 0, 0,
                         'Sell for 1500 ' + crGold, 'Keep it', '', '');
          if dv = 1 then begin
            Hero^[ActiveHero].Backpack[n] := 0;
            inc(Player[Turn].Resources[rGold], 1500);
          end;
        end else if (a >= anBagOfJunk) and (a <= anBagOfJewelry) then begin
          c := (a - anBagOfJunk + 1) * 2000;
          if AIP then
            dv := 1
          else
            dv := Dialog('"I''ll give you ' + GoldStr(c)
                         + ' for that ' + ArtData[a].name + '. You won''t '
                         + 'find a better deal."', dgGold, dgCancel, 0, 0,
                         'Sell for ' + GoldStr(c), 'Keep it', '', '');
          if dv = 1 then begin
            Hero^[ActiveHero].Backpack[n] := 0;
            inc(Player[Turn].Resources[rGold], c);
          end;
        end;
      end;
      SortBackpack(ActiveHero);
      c := longint(1000) * MapNum^[x, y];
      if AIP then begin
        if Player[Turn].Resources[rGold] > 5 * c then
          dv := 1
        else
          dv := 2;
      end else
        dv := Dialog('"This week''s special: ' + ArtData[MapInfo^[x, y]].name
                     + '. ' + chr(colLightGray) + '(' + ArtHelp^[MapInfo^[x, y]]
                     + ')' + chr(colWhite) + ' Just ' + GoldStr(c) + '."',
                     dgArtifact + MapInfo^[x, y], dgCancel, 0, 0,
                     'Buy for ' + GoldStr(c), 'No thanks', '', '');
      if dv = 1 then begin
        if Player[Turn].Resources[rGold] < c then
          Message('"I''ll hold one for you for when you scrounge up the cash."')
        else if not GainArt(ActiveHero, MapInfo^[x, y]) then
          Message('"I''ll hold one for you; come back with a wheelbarrow to '
                  + 'put it in."')
        else begin
          dec(Player[Turn].Resources[rGold], c);
          inc(MapNum^[x, y], 2);
        end;
      end;
      Window := winResources;
      DrawnWindow := -1;
    end else if m = mLibrary then begin
      Window := winResources;
      DrawWindow;
      n1 := PsuedorandomSpell(1, ((Date div 7) + 1) * integer(rand));
      n2 := PsuedorandomSpell(2, ((Date div 7) + 1) * integer(rand));
      c := MapNum^[x, y] * longint(1000);

      if AIP then begin
        if CanGainSkillLevel(ActiveHero, LibrarySkill[MapInfo^[x, y]]) then
          dv := 1
        else
          dv := 2;
      end else
        dv := Dialog('This week the Library has a course in '
                     + SkillNames[LibrarySkill[MapInfo^[x, y]]]
                     + ', including two spells: ' + SpellData[n1].name
                     + ' and ' + SpellData[n2].name + '. The course costs '
                     + GoldStr(c) + '. Are you interested?',
                     dgXP, dgCancel, 0, 0,
                     'Take the course for ' + GoldStr(c), 'No', '', '');
      if dv = 1 then begin
        if Player[Turn].Resources[rGold] < c then
          Message('You lack the necessary tuition.')
        else begin
          dec(Player[Turn].Resources[rGold], c);
          inc(MapNum^[x, y], 4);
          GainSkillLevel(ActiveHero, LibrarySkill[MapInfo^[x, y]]);
          AddSpell(Hero^[ActiveHero].SS, n1);
          AddSpell(Hero^[ActiveHero].SS, n2);
          if Twists[twOneUseBuildings] then TheMap^[x, y] := mRocky;
        end;
      end;
    end else if m = mSageHut then begin
      if GetVisited(ActiveHero, gi, gj, hvSageHut) then begin
        Message('You have already learned all that this sage can teach you.');
      end else begin
        SetVisited(ActiveHero, gi, gj, hvSageHut);
        Message('The sage in the hut teaches you many things.');
        GiveHeroXP(ActiveHero, XPForLevel(Hero^[ActiveHero].level + 1)
                               - XPForLevel(Hero^[ActiveHero].level));
      end;
      if Twists[twOneUseBuildings] then TheMap^[x, y] := mRocky;
    end else if m = mHermitHut then begin
      if Hero^[ActiveHero].HermitBonus = hbNone then begin
        case rand mod 4 of
          0: begin
               hb := hbEye;
               s := 'the secret of far-seeing. "It''s all in the nose," '
                    + 'he tells you. "From this day forth, you will know '
                    + 'how many monsters you are facing, and will see '
                    + 'far off enemies." ';
               if not Player[Hero^[ActiveHero].player].AI then
                 RevealEnemyHeroes;
             end;
          1: begin
               hb := hbWrecker;
               s := 'the secrets of siege warfare. "It''s all attitude," '
                    + 'he says. "From this day forth, you will never more '
                    + 'fear a castle gate or barbican." ';
             end;
          2: begin
               hb := hbKiller;
               s := 'the ancient art of neck breaking. "It''s all in the '
                    + 'wrist," he says. "From this day on, your troops will '
                    + 'never strike a blow without a kill." ';
             end;
          3: begin
               hb := hbMystic;
               s := 'the secrets of proper worship. "It''s all in the '
                    + 'knees," he says. "From this day forth, you will '
                    + 'retain the blessings of Shrines and Altars, for '
                    + 'as long as you don''t visit another one." ';
             end;
        end;
        Message('The hermit in the cave teaches you ' + s + 'Then he '
                + 'vanishes.');
        Hero^[ActiveHero].HermitBonus := hb;
        TheMap^[x, y] := mMountain;
      end else begin
        Message('The hermit in the cave greets you politely, but you can '
                + 'tell he just wants you to leave. He has nothing to '
                + 'teach you.');
      end;
    end else if m = mUpgradeFort then begin
      Window := winResources;
      DrawWindow;
      gotone := false;
      n := MapInfo^[x, y];
      for a := 1 to HeroSlots(ActiveHero) do begin
        n1 := Hero^[ActiveHero].army[a].monster;
        if (Hero^[ActiveHero].army[a].qty > 0)
           and (MonsterLevel(n1) = n) then begin
          gotone := true;
          gp := (MonsterData[n1 + 1].cost - MonsterData[n1].cost)
                * longint(Hero^[ActiveHero].army[a].qty) * 2;
          if AIP then
            dv := 1
          else
            dv := Dialog('At the academy, you can upgrade your '
                         + MonsterData[n1].pname + ' to '
                         + MonsterData[n1 + 1].pname + ', for ' + GoldStr(gp)
                         + '.', n1, dgCancel, 0, 0,
                         'Upgrade for ' + GoldStr(gp), 'No', '', '');
          if dv = 1 then begin
            if Player[pl].Resources[rGold] >= gp then begin
              dec(Player[pl].Resources[rGold], gp);
              UpgradeStack(a);
            end else begin
              Message('You don''t have enough ' + crGold + '.');
            end;
          end;
        end;
      end;
      if not gotone then begin
        Message('This academy upgrades level ' + IStr(n, 0) + ' troops '
                + 'to level ' + IStr(n + 1, 0) + '. You don''t have any '
                + 'though.');
      end;
    end else if (m = mShamanHut) or (m = mMagicianHome)
                or (m = mWizardHouse) then begin
      case m of
        mShamanHut:        a := smShaman;
        mMagicianHome:     a := smMagician;
        mWizardHouse:      a := smWizard;
      end;
      ClearWindow(winMessage);
      if MapNum^[x, y] = pl then
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Already owned:')
      else begin
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Claimed:');
        if MapNum^[x, y] <> 0 then
          dec(Player[MapNum^[x, y]].SpellMines[a]);
        inc(Player[pl].SpellMines[a]);
        MapNum^[x, y] := pl;
      end;
      WDrawBoxText(WindowX, WindowY + 12, WindowX2, colBlack, colWhite,
                   SpellMineNames[a]);
    end else if m = mHouseofHusbandry then begin
      ClearWindow(winMessage);
      if MapNum^[x, y] = pl then
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Already owned:')
      else begin
        WDrawText(WindowX, WindowY, colBlack, colWhite, 'Claimed:');
        if MapNum^[x, y] <> 0 then
          dec(Player[MapNum^[x, y]].HusbandryMines[MapInfo^[x, y]]);
        inc(Player[pl].HusbandryMines[MapInfo^[x, y]]);
        MapNum^[x, y] := pl;
      end;
      WDrawBoxText(WindowX, WindowY + 12, WindowX2, colBlack, colWhite,
                   'House of Husbandry (level ' + IStr(MapInfo^[x, y], 0) + ')');
    end else if m = mGrass then begin
      for h := 1 to 6 do
        if FindAdjMapHex(h, x, y, nx, ny) then
          if (ActiveHero <> 0)
             and (TheMap^[nx, ny] in [mMonster, mHardMonster]) then
            Fight(nx, ny, false);
    end else if (m = mHero) or ((m >= mJungleFort)
                                and (m <= mLastCastle)) then begin
      n := HeroAtSpot(x, y);
      if n <> 0 then begin
        if Hero^[n].player = Turn then
          VisitHero(n)
        else begin
          Fight(x, y, false);
          if Player[Turn].AI then begin
            if ActiveHero <> 0 then MakeHeroDangerMap;
            MakeCastleDangerMap;
          end;
        end;
      end;
    end else if m = mCache then begin
      if MapNum^[x, y] <> 0 then
        Message('The fort is deserted.')
      else begin
        Fight(x, y, false);
        if ActiveHero <> 0 then begin
          MapNum^[x, y] := 1;
          n := 2500 * CacheLevel[MapInfo^[x, y]];
          a := RandomArtifact(CacheLevel[MapInfo^[x, y]]);
          if GainArt(ActiveHero, a) then
            Message('After defeating the monsters, you find ' + GoldStr(n)
                    + ' and ' + AnArtName(a) + '.')
          else
            Message('After defeating the monsters, you find ' + GoldStr(n)
                    + '.');
          inc(Player[Turn].Resources[rGold], n);
          Window := winResources;
          DrawnWindow := -1;
        end;
      end;
    end;

    Draw;

    if VisibleTurn or (HeroGridCt > 0) then
      RefreshScreen;
  end;

procedure TMapScr.VisitCastle(x, y: integer);
  var
    c, pl: integer;
    CS: PCastleScr;
    s: string;
    i, b1, b2, b3: integer;
    n: longint;
    defended: boolean;
  begin
    c := MapInfo^[x, y];
    pl := Castle[c].Player;

    if pl <> Turn then begin
      defended := false;
      for i := 1 to 6 do
        if Castle[c].Garrison[i].qty > 0 then
          defended := true;
      if defended then
        Fight(x, y, false)
      else begin
        GainCastle(Turn, c);
        ClearDrawn;
        Draw;
      end;
      CheckDeath(pl);
    end;

    if (Castle[c].player = Turn) and not GameOver then begin
      if (ActiveHero <> 0) and (Hero^[ActiveHero].MapX = x)
         and (Hero^[ActiveHero].MapY = y) then begin
        b1 := CountArt(ActiveHero, anBagOfJunk, false);
        b2 := CountArt(ActiveHero, anBagOfBaubles, false);
        b3 := CountArt(ActiveHero, anBagOfJewelry, false);

        if b1 + b2 + b3 > 0 then begin
          s := '';
          if b1 > 0 then
            s := 'junk';
          if b2 > 0 then
            if s <> '' then s := s + ' and baubles'
            else s := 'baubles';
          if b3 > 0 then
            if s <> '' then s := s + ' and jewelry'
            else s := 'jewelry';
          n := b1 * longint(3000) + b2 * longint(6000) + b3 * longint(9000);
          Message('You sell your ' + s + ' for a total of ' + GoldStr(n)
                  + '.');
          inc(Player[Turn].Resources[rGold], n);
          for i := 1 to BackpackSize do
            if Hero^[ActiveHero].Backpack[i]
               in [anBagOfJunk, anBagOfBaubles, anBagOfJewelry] then
              Hero^[ActiveHero].Backpack[i] := 0;
        end;
      end;

      if Player[Turn].AI then begin
        if ActiveHero <> 0 then AIVisitCastle(c, ActiveHero);
      end else begin
        CS := New(PCastleScr, Init);
        CS^.Handle(@Castle[c], c);
        Dispose(CS, Done);
        Recover;
      end;

      i := HeroAtSpot(x, y);
      if (i <> 0) and (i <> ActiveHero) then SelectHero(i);
    end;
  end;

procedure TMapScr.HintText(x, y: integer);
  var
    i, info, h: integer;
    s, adj: string;
    visited, eye, special: boolean;
    AS: TArmySet;
    r: TResource;
  begin
    ClearWindow(winMessage);
    s := MapHintText(ActiveHero, x, y);

    if s = 'SPECIAL' then
      ClearDrawn
    else begin
      if length(s) > 128 then
        Message(s)
      else
        DrawBoxText(WindowX, WindowY, WindowX2, colBlack, colWhite, s);
    end;

    Draw;
  end;

procedure TMapScr.Recover;
  begin
    DrawBackground := true;
    ClearScr;
    ClearDrawn;
    Draw;
  end;

procedure TMapScr.HeroScreen(h: integer);
  begin
    DoHeroScreen(h, false);
    Recover;
    if h = ActiveHero then
      SelectHero(ActiveHero);
  end;

procedure TMapScr.StartTurn;

  procedure GainMonstersByLevel(h, lev, qty: integer);
    var m, a: integer;
    begin
      for m := 1 to NumMonsters do
        if (lev = 0) or (MonsterLevel(m) = lev) then begin
          a := FindMonsterSlot(@Hero^[h].army, HeroSlots(h), m);
          if a <> 0 then
            GainMonster(@Hero^[h].army, HeroSlots(h), m, qty);
        end;
    end;

  procedure GainRez(r: TResource; amt: longint);
    begin
      inc(Player[Turn].Resources[r], amt);
      inc(RezProd[r], amt);
    end;

  const
    MiningResources: array [0..4] of TResource =
    (
      rApples, rEmeralds, rQuartz, rBeakers, rClay
    );
  var
    i, j, x, y, n, a, m, mines, dv, md, g, nx, ny, m2: integer;
    t, q, q2: integer;
    r: TResource;
    gotone: boolean;
    s: string;

  begin
    mines := 0;
    FillChar(RezProd, sizeof(RezProd), #0);

    for x := 1 to MapSize do
      for y := 1 to MapSize do begin
        md := TheMap^[x, y];
        if (md >= mGoldMine) and (md <= mClayMine)
           and (MapNum^[x, y] = Turn) then begin
          r := TResource(md - mGoldMine);
          GainRez(r, ResourceInc[r]);
          inc(mines);
        end;
      end;

    with Player[Turn] do begin
      for i := 1 to MaxDudes do begin
        if Dudes[i] <> 0 then
          with Hero^[Dudes[i]] do begin
            if AI then ConserveSlots(@army, HeroSlots(Dudes[i]));

            for j := 1 to BackpackSize do
              if Backpack[j] = anBoxOfClay then begin
                repeat
                  a := RandomArtifact(2);
                until a <> anBoxOfClay;
                if AI then
                  dv := 1
                else
                  dv := Dialog(dgcFace + chr(Dudes[i]) + 'Today, ' + Name
                               + ' may shape the magical Box of Clay into '
                               + AnArtName(a) + '...',
                               dgArtifact + a, dgCancel, 0, 0,
                               ArtData[a].name + ' - ' + chr(colLightGray)
                               + ArtHelp^[a], 'Keep The Box', '', '');
                case dv of
                  1: begin
                       Backpack[j] := 0;
                       GainArt(Dudes[i], a);
                     end;
                  2: ;
                end;
              end;

            { skills }

            GiveHeroDailyMPSP(Dudes[i]);

            s := HeroDailyAlchemy(Dudes[i]);
            if s <> '' then Message(s);

            HeroDailySummoning(Dudes[i]);
            HeroDailyGating(Dudes[i]);

            s := HeroDailyInsight(Dudes[i]);
            if s <> '' then Message(s);

            { necklaces }

            n := CountArt(Dudes[i], anNecklaceOfUpgrading, true);
            if n > 0 then
              HeroDailyUpgrading(Dudes[i], 1, 4 * n);

            n := CountArt(Dudes[i], anNecklaceOfUltraUpgrading, true);
            if n > 0 then
              HeroDailyUpgrading(Dudes[i], 2, 3 * n);

            n := CountArt(Dudes[i], anNecklaceofMassSummoning, true);
            if n > 0 then begin
              inc(MassSummonArtFraction, n);
              if MassSummonArtFraction >= 4 then begin
                dec(MassSummonArtFraction, 4);
                GainMonstersByLevel(Dudes[i], 0, n);
              end;
            end;

            n := CountArt(Dudes[i], anNecklaceoftheHordes, true);
            if n > 0 then begin
              GainMonstersByLevel(Dudes[i], 1, n * 2);
            end;

            n := CountArt(Dudes[i], anNecklaceofEvocation, true);
            if n > 0 then begin
              GainMonstersByLevel(Dudes[i], EvocationLevel + 1, n);
              EvocationLevel := (EvocationLevel + 1) mod 6;
            end;

            inc(LoreArtFraction, CountArt(Dudes[i], anNecklaceOfLore, true));
            if LoreArtFraction >= 4 then begin
              n := RandomNewSpell(SS, random(2) + 1, 0, true);
              if n <> 0 then begin
                AddSpell(SS, n);
                Message(dgcFace + chr(Dudes[i]) + 'Through the unfathomable '
                        + 'powers of the Necklace Of Lore, ' + Name
                        + ' learns ' + SpellData[n].Name + '!');
              end;
              dec(LoreArtFraction, 4);
            end;

            { boots }

            if HasArt(Dudes[i], anBootsOfExperience, true) then
              GiveHeroXP(Dudes[i], XPAfterCunning(Dudes[i], 200));

            if HasArt(Dudes[i], anBootsOfTheScout, true) then begin
              for j := 1 to MaxTowns do
                if Towns[j] <> 0 then
                  inc(Castle[Towns[j]].AvailableTroops[1], 10);
            end;

            if HasArt(Dudes[i], anBootsOfJourneying, true) then begin
              n := TheMap^[MapX, MapY];
              if (n >= mJungleFort) and (n <= mLastCastle) then
                inc(MP, 6);
            end;

            { pickaxes / wrenches }

            n := CountArt(Dudes[i], anPickaxeOfGoldMining, true);
            GainRez(rGold, n * 1000);

            n := CountArt(Dudes[i], anPickaxeOfRockMining, true);
            GainRez(rRocks, n);

            n := CountArt(Dudes[i], anPickaxeOfMining, true);
            if n > 0 then begin
              GainRez(MiningResources[MiningRez], n);
              MiningRez := (MiningRez + 1) mod (high(MiningResources) + 1);
            end;

            n := CountArt(Dudes[i], anToyPickaxe, true);
            if n > 0 then begin
              GainRez(rGold, n * 100);
              GiveHeroXP(Dudes[i], XPAfterCunning(Dudes[i], n * 50));
            end;

            n := 2 * CountArt(Dudes[i], anWrenchOfDeconstruction, true);
            if n > 0 then begin
              for j := 1 to MaxTowns do
                if Towns[j] <> 0 then
                  while (n > 0) and RemoveObstacle(Towns[j]) do
                    dec(n);
            end;

            n := 0;
            for j := 1 to HeroSlots(Dudes[i]) do
              inc(n, army[j].qty);
            inc(Resources[rGold], CountArt(Dudes[i], anLegionnairesPickaxe,
                                           true) * n * 2);

            n := CountArt(Dudes[i], anDwarvenPickaxe, true) * longint(100)
                 * mines;
            GainRez(rGold, n);

            inc(AlchemyArtFraction, CountArt(Dudes[i], anAlchemistsPickaxe,
                                             true));
            if AlchemyArtFraction >= 7 then begin
              a := RandomArtifact(1);
              if GainArt(Dudes[i], a) then begin
                dec(AlchemyArtFraction, 7);
                Message(dgcFace + chr(Dudes[i])
                        + 'Using the magical Alchemist''s Pickaxe, ' + Name
                        + ' whips up ' + AnArtName(a) + '!');
              end else begin
                AlchemyArtFraction := 6;
              end;
            end;

            inc(TransformArtFraction, CountArt(Dudes[i], anAlchemistsWrench,
                                               true));
            if TransformArtFraction >= 7 then begin
              for j := 1 to BackpackSize do
                if (TransformArtFraction >= 7) and (Backpack[j] > 0)
                   and (ArtData[Backpack[j]].level = 1) then begin
                  a := RandomArtifact(2);
                  Message(dgcFace + chr(Dudes[i])
                          + 'Using the magical Alchemist''s Wrench, ' + Name
                          + ' turns ' + AnArtName(Backpack[j]) + ' into '
                          + AnArtName(a) + '!');
                  Backpack[j] := a;
                  dec(TransformArtFraction, 7);
                end;
            end;

            if HasArt(Dudes[i], anWrenchofRezoning, true) then begin
              for j := 1 to 6 do
                if FindAdjMapHex(j, MapX, MapY, x, y) then
                  for a := 1 to 6 do
                    if FindAdjMapHex(a, x, y, nx, ny) then
                      if TheMap^[nx, ny] = mDwelling then begin
                        m := MapInfo^[nx, ny] and $7F;
                        if FindMonsterSlot(@Hero^[Dudes[i]].army,
                                           HeroSlots(Dudes[i]), m) = 0 then begin
                          n := MonsterLevel(m);
                          for g := 1 to HeroSlots(Dudes[i]) do begin
                            m2 := Hero^[Dudes[i]].army[g].monster;
                            if (Hero^[Dudes[i]].army[g].qty > 0)
                               and (MonsterLevel(m2) = n) then begin
                              m := m2;
                              MapInfo^[nx, ny] := (MapInfo^[nx, ny] and $80)
                                                  or m;
                            end;
                          end;
                        end;
                        MapNum^[nx, ny] := 1200 div MonsterData[m].cost;
                      end else if TheMap^[nx, ny] = mHordeDwelling then begin
                        MapNum^[nx, ny] := 40;
                      end;
            end;

            n := CountArt(Dudes[i], anWrenchoftheHordes, true);
            if n > 0 then
              for j := MaxTowns downto 1 do
                if Towns[j] <> 0 then
                  while (n > 0)
                        and TryToBuild(Towns[j], bCreature1, false, true) do
                    dec(n);

            { altar / shrine bonus }

            if (AltarDays > 0) and (HermitBonus <> hbMystic) then begin
              dec(AltarDays);
              if AltarDays = 0 then AltarBonus := 0;
            end;

            if (ShrineDays > 0) and (HermitBonus <> hbMystic) then begin
              dec(ShrineDays);
              if ShrineDays = 0 then begin
                ShrineBonus := 0;
              end;
            end;

            LimitMana(Dudes[i]);
          end;
      end;

      for i := 1 to MaxTowns do
        if Towns[i] <> 0 then
          CastleProduction(Towns[i]);
    end;
  end;

procedure TMapScr.PrepTurn;
  begin
    ClearDrawn;
    DrawnWindow := -1;

    with Player[Turn] do begin
      if Dudes[1] <> 0 then begin
        BarType := btHeroes;
        BarPage := 1;
        SelectHero(Dudes[1]);
      end else begin
        BarType := btCastles;
        BarPage := 1;
        ActiveHero := 0;
        Window := winResources;
        if Towns[1] <> 0 then
          CenterOn(Castle[Towns[1]].MapX, Castle[Towns[1]].MapY)
        else
          CenterOn(1, 1);
      end;
    end;

    Draw;
  end;

(*
procedure DebugArmyGrowth;
  var
    f: text;
    pl, i, x, y: integer;
    v, uv, gp: longint;
    s: string;
  begin
    assign(f, 'temp.dat');
    append(f);
    s := '';

    for pl := 1 to NumPlayers do begin
      v := 0;

      { hero armies }

      for i := 1 to MaxDudes do
        if Player[pl].Dudes[i] <> 0 then
          inc(v, ArmySetGp(@Hero^[Player[pl].Dudes[i]].army));

      { castle armies }

      for i := 1 to MaxTowns do
        if Player[pl].Towns[i] <> 0 then
          inc(v, ArmySetGP(@Castle[Player[pl].Towns[i]].garrison));

      { two weeks of unbought troops limited by two weeks of gp }

      uv := 0;

      for i := 1 to MaxTowns do
        if Player[pl].Towns[i] <> 0 then
          inc(uv, CastleProdValue(Player[pl].Towns[i]) * 14
                  + CastleTroopsGP(Player[pl].Towns[i], false));

      gp := Player[pl].Resources[rGold];

      for i := 1 to MaxTowns do
        if Player[pl].Towns[i] <> 0 then
          inc(gp, Castle[Player[pl].Towns[i]].Income[rGold]);

      for x := 1 to MapSize do
        for y := 1 to MapSize do
          if (TheMap^[x, y] = mGoldMine) and (MapNum^[x, y] = pl) then
            inc(gp, ResourceInc[rGold]);

      if uv > gp then uv := gp;
      inc(v, uv);

      s := s + LStr(v, 9);
    end;

    writeln(f, s);

    close(f);
  end;
*)

procedure TMapScr.NewWeek;
  var i, j, c, n, m: integer;
  begin
    for i := 1 to MapSize do
      for j := 1 to MapSize do
        case TheMap^[i, j] of
          mFarmstead:   begin
                          MapNum^[i, j] := 1;
                          MapNum^[i + 1, j] := 1;
                        end;
          mMiningVillage: begin
                            MapNum^[i, j] := 1;
                            MapInfo^[i, j] := random(6) + 1;
                          end;
          mDwelling:    begin
                          n := 1200
                               div MonsterData[MapInfo^[i, j] and $7F].cost;
                          MapNum^[i, j] := n;
                        end;
          mHordeDwelling: begin
                            MapNum^[i, j] := 40;
                            MapInfo^[i, j] := $80;
                          end;
          mMonster,
          mHardMonster: begin
                          n := MapNum^[i, j];
                          if n < 7 then
                            inc(n)
                          else
                            n := n + (n + 3) div 7;
                          if MonsterHasFlag(MapInfo^[i, j] and $7F, 4,
                                            f4Multiplies) then
                            n := n + (n + 5) div 10;
                          MapNum^[i, j] := n;
                        end;
          mJunkMerchant: MapInfo^[i, j] := RandomArtifact(2);
          mLibrary:     MapInfo^[i, j] := random(6) + 1;
          mCastle
          ..mLastCastle: begin
                           c := MapInfo^[i, j];
                           if Castle[c].player = 0 then begin
                             n := Date div 7;
                             if n < 1 then n := 1;
                             if n > 6 then n := 6;
                             m := MonsterForLevel(Castle[c].CT, random(n) + 1);
                             GainMonster(@Castle[c].Garrison, 6, m,
                                         7200 div MonsterData[m].cost);
                           end;
                         end;
        end;

    for i := 1 to NumHeroes do
      with Hero^[i] do
        if (player > 0) and not Dead then begin
          for j := 1 to HeroSlots(i) do
            if (army[j].qty > 0)
               and HeroMonsterHasFlag(i, army[j].monster, 4, f4Multiplies) then
              inc(army[j].qty, army[j].qty div 10);
        end;

    SetTaverns;

{   DebugArmyGrowth;  }
  end;

procedure TMapScr.NextTurn;
  const Flooded: boolean = false;
  var i, j, m, n, x, y, h, nx, ny, mons, qty, ct: integer;
  begin
    if Turn < NumPlayers then
      inc(Turn)
    else begin
      Turn := 1;
      inc(Date);
      if Date mod 7 = 0 then NewWeek;

      if Twists[twFlooding] then begin
        if (Flooded and (random(10) < 6))
           or (not Flooded and (random(10) < 3)) then begin
          if Flooded then ShrinkWater else GrowWater;
          Flooded := not Flooded;
        end;
      end;

      if Twists[twForestsDie] or Twists[twDwellingsAppear] then begin
        i := Random(GeoSize) + 1;
        j := Random(GeoSize) + 1;
        for m := 1 to MapGeoSize do
          for n := 1 to MapGeoSize do begin
            x := (m - 1) * GeoSize + i;
            y := (n - 1) * GeoSize + j;
            if Twists[twForestsDie] then begin
              if (TheMap^[x, y] in [mBranchTree, mBirchTree, mTwisty2,
                                    mOakTree, mPineTree, mJungleTree,
                                    mTwistyTree, mWillowTree, mElmTree,
                                    mSnowyPineTree])
                 and AdjToTerrain(x, y, mGrass) then begin
                TheMap^[x, y] := mGrass;
                for h := 1 to 6 do
                  if FindAdjMapHex(h, x, y, nx, ny) then
                    if TheMap^[nx, ny] = mDoodad then
                      TheMap^[nx, ny] := mGrass;
              end;
            end;
            if Twists[twDwellingsAppear] then begin
              if TheMap^[x, y] = mGrass then begin
                ct := 0;
                for h := 1 to 6 do
                  if FindAdjMapHex(h, x, y, nx, ny) then
                    if TheMap^[nx, ny] <> mGrass then
                      inc(ct);
                if ct <= 1 then begin
                  TheMap^[x, y] := mDwelling;
                  mons := Date div 14;
                  if mons > 5 then mons := 5;
                  mons := mons + 1 + 6 * random(8);
                  MapInfo^[x, y] := mons;
                  qty := 1200 div MonsterData[mons].cost;
                  if qty < 1 then qty := 1;
                  MapNum^[x, y] := qty;
                  if MonsterLevel(mons) >= 3 then
                    MapInfo^[x, y] := MapInfo^[x, y] or $80;
                end;
              end;
            end;
          end;
      end;

      if Twists[twCastleBuildingsDecay] then
        for i := 1 to NumCastles do
          HandleDecay(i);
    end;
    if not Player[Turn].AI then LastHuman := Turn;
  end;

procedure TMapScr.SelectHero(h: integer);
  var x, y: integer;
  begin
    ActiveHero := h;
    Window := winHero;
    DrawnWindow := -1;
    x := Hero^[ActiveHero].DestX;
    y := Hero^[ActiveHero].DestY;
    ClearPath;
    Hero^[ActiveHero].DestX := x;
    Hero^[ActiveHero].DestY := y;
    CenterOn(Hero^[ActiveHero].MapX, Hero^[ActiveHero].MapY);
    if Hero^[ActiveHero].DestX <> 0 then
      MakePath(Hero^[ActiveHero].DestX, Hero^[ActiveHero].DestY);
    DrawBars;
    DrawWindow;
  end;

procedure TMapScr.PlayerTurn;

  procedure PTSetCorner(x, y: integer);
    var i: integer;
    begin
      SetCorner(x, y);
      for i := 1 to ScrollDelay do RefreshScreen;
    end;

  const
    SystemOpts: TDialogArr =
    (
      (pic: dgComputer; s: 'Save Game'),
      (pic: dgComputer; s: 'Load Saved Game'),
      (pic: dgComputer; s: 'Quit'),
      (pic: dgComputer; s: 'Quit to Menu'),
      (pic: dgBuyAll; s: 'See Twists'),
      (pic: dgCancel; s: 'Cancel'),
      (pic: 0; s: ''),
      (pic: 0; s: '')
    );
  var
    E: TEvent;
    over: boolean;
    x, y, t, m, i, j, pn, n, scx, scy: integer;
  procedure XYToGrid;
    begin
      y := y div 32;
      if y mod 2 = 0 then dec(x, 16);
      x := (x div 32) + MapX;
      y := y + MapY;
    end;

  begin
    over := false;

    for i := 1 to MaxDudes do
      if (Player[Turn].Dudes[i] <> 0)
         and (Hero^[Player[Turn].Dudes[i]].HermitBonus = hbEye) then begin
        RevealEnemyHeroes;
        Draw;
      end;

    repeat
      WaitForEventOrEdge(E);

      if E.What = evKeyDown then begin
        if E.CharCode = #27 then GameOver := true;
        case E.KeyCode of
          kbUp:    PTSetCorner(MapX, MapY - 2);
          kbLeft:  PTSetCorner(MapX - 2, MapY);
          kbDown:  PTSetCorner(MapX, MapY + 2);
          kbRight: PTSetCorner(MapX + 2, MapY);
          kbAltF:  if SuperSpyMode then begin
                     SpyMode := true;
                     RevealArea(60, 60, 85);
                   end;
          kbAltQ:  GameOver := true;
        end;
      end;

      if E.What = evMouse then begin
        if E.Where.X = 0 then scx := -2
        else if E.Where.X = 639 then scx := 2
        else scx := 0;
        if E.Where.Y = 0 then scy := -2
        else if E.Where.Y = 479 then scy := 2
        else scy := 0;
        if (scx <> 0) or (scy <> 0) then
          PTSetCorner(MapX + scx, MapY + scy);
      end;

      if E.What = evMouseDown then begin
        x := E.Where.X;
        y := E.Where.Y;
        if E.Buttons = mbLeftButton then begin
          if (x >= 639 - MapSize) and (y < MapSize) then begin
            SetCorner(x - (639 - MapSize) + 1 - (MapScrSize div 2),
                      y + 1 - (MapScrSize div 2));
          end else if (x >= 520) and (x < 520 + 40 * 3)
                      and (y >= 140) and (y < 140 + 40 * 4) then begin
            n := ((x - 520) div 40) + ((y - 140) div 40) * 3 + 1;
            if (n >= 1) and (n <= 8) then begin
              if BarType = btHeroes then begin
                if Player[Turn].Dudes[n] <> 0 then begin
                  i := MapX;
                  j := MapY;
                  SelectHero(Player[Turn].Dudes[n]);
                  if (i = MapX) and (j = MapY) then
                    HeroScreen(ActiveHero);
                end;
              end else begin
                t := n + (BarPage - 1) * 8;
                if (t <= MaxTowns) and (Player[Turn].Towns[t] <> 0) then begin
                  t := Player[Turn].Towns[t];
                  i := MapX;
                  j := MapY;
                  CenterOn(Castle[t].MapX, Castle[t].MapY);
                  if (i = MapX) and (j = MapY) then
                    VisitCastle(Castle[t].MapX, Castle[t].MapY);
                end;
              end;
            end else if (n = 9) and (BarType = btCastles) then begin
              t := (BarPage - 1) * 8 + 1 + 8;
              if (t > MaxTowns) or (Player[Turn].Towns[t] = 0) then
                BarPage := 1
              else
                inc(BarPage);
            end else if n = 10 then begin
              BarType := btHeroes;
              BarPage := 1;
              Window := winHero;
              DrawnWindow := -1;
            end else if n = 11 then begin
              BarType := btCastles;
              BarPage := 1;
              Window := winResources;
              DrawnWindow := -1;
            end else if n = 12 then begin
              Window := winTurn;
              DrawnWindow := -1;
              BarType := btHeroes;
              BarPage := 1;
            end;
            DrawBars;
            DrawWindow;
          end else if (x <= 32 * 15 + 16) and (y <= 32 * 15) then begin
            XYToGrid;
            if OnMap(x, y) and ((Fog^[x, y] and BitTable[Turn]) <> 0) then begin
              m := TheMap^[x, y];
              if m = mCastlePart then begin
                if Castle[MapNum^[x, y]].player = Turn then
                  VisitCastle(Castle[MapNum^[x, y]].MapX,
                              Castle[MapNum^[x, y]].MapY);
              end else if ActiveHero <> 0 then begin
                if (Hero^[ActiveHero].DestX = x)
                   and (Hero^[ActiveHero].DestY = y) then begin
                  WalkToDest(false);
                end else if (Hero^[ActiveHero].MapX = x)
                            and (Hero^[ActiveHero].MapY = y) then begin
                  HeroScreen(ActiveHero);
                end else if not ((m = mGrass)
                                 or ((m >= mCastle) and (m <= mLastCastle)
                                     and (HeroAtSpot(x, y) = 0)))
                            and HexIsAdjacent(Hero^[ActiveHero].MapX,
                                              Hero^[ActiveHero].MapY,
                                              x, y) then begin
                  ClearPath;
                  VisitSpot(x, y);
                end else if not (((m >= mFirstObstacle) and (m <= mRightHalf))
                                 or (m = mMonster)
                                 or (m = mHardMonster)) then begin
                  MakePath(x, y);
                  Draw;
                end else begin
                  ClearPath;
                  if HexIsAdjacent(Hero^[ActiveHero].MapX,
                                   Hero^[ActiveHero].MapY, x, y) then
                    VisitSpot(x, y);
                  Draw;
                end;
              end;
            end;
          end else if Window = winTurn then begin
            if (x >= 528) and (x < 528 + 32)
               and (y >= WindowY + 32) and (y < WindowY + 64) then begin
              over := true;
            end else if (x >= 528) and (x < 528 + 32) and (y >= WindowY + 96)
                        and (y < WindowY + 128) then begin
              case BaseDialogN('Choose option...', @SystemOpts, 6, 2) of
                1: SaveGame;
                2: begin
                     GameOver := true;
                     LoadSavedGame := true;
                   end;
                3: GameOver := true;
                4: begin
                     GameOver := true;
                     QuitToMenu := true;
                   end;
                5: ShowTwists;
                6: ;
              end;
              ClearDrawn;
              Draw;
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          if (x >= WindowX) and (y >= WindowY) then begin
            if (Window = winMessage) or (Window = winResources) then
              Window := winTurn
            else if (Window = winTurn) and (ActiveHero <> 0) then
              Window := winHero
            else
              Window := winResources;
            Draw;
          end else if (x <= 32 * 15 + 16) and (y <= 32 * 15) then begin
            XYToGrid;
            if OnMap(x, y)
               and ((Fog^[x, y] and BitTable[Turn]) <> 0) then begin
              XlatMapXY(x, y);
              n := HeroAtSpot(x, y);
              if (TheMap^[x, y] >= mJungleFort)
                      and (TheMap^[x, y] <= mLastCastle)
                      and (Castle[MapInfo^[x, y]].player = Turn) then
                VisitCastle(Castle[MapInfo^[x, y]].MapX,
                            Castle[MapInfo^[x, y]].MapY)
              else if (n <> 0) and (Hero^[n].player = Turn) then
                HeroScreen(n)
              else
                HintText(x, y);
            end;
          end else if (x > 639 - MapSize) and (y < MapSize) then begin
            TinyMapHeroes := not TinyMapHeroes;
            DrawTinyMap;
          end;
        end;
      end;
    until GameOver or over;
  end;

procedure TMapScr.MakeCastleDangerMap;
  var
    h, x, y: integer;
    av: longint;
  begin
    fillchar(CastleDangerMap^, sizeof(CastleDangerMap^), #0);

    for h := 1 to NumHeroes do
      if (Hero^[h].MapX <> 0) and (Hero^[h].Player <> Turn) then begin
        av := HeroArmyValue(h);
        HeroMakeMapDist(h, -1, HeroMaxMP(h));
        for x := 1 to MapSize do
          for y := 1 to MapSize do
            if (Dist^[x, y] > 0) and (av > CastleDangerMap^[x, y]) then
              CastleDangerMap^[x, y] := av;
      end;
  end;

procedure TMapScr.MakeHeroDangerMap;
  var
    h, x, y: integer;
    av, avb, asg: longint;
  begin
    fillchar(HeroDangerMap^, sizeof(HeroDangerMap^), #0);
    avb := HeroArmyValue(ActiveHero);
    asg := ArmySetGP(@Hero^[ActiveHero].army);

    for h := 1 to NumHeroes do
      if (Hero^[h].MapX <> 0) and (Hero^[h].Player <> Turn) then begin
        av := HeroArmyValue(h);
        if (avb <= av * 3)
           and (Fight(Hero^[h].MapX, Hero^[h].MapY, true) >= asg) then begin
          HeroMakeMapDist(h, -1, HeroMaxMP(h));
          for x := 1 to MapSize do
            for y := 1 to MapSize do
              if Dist^[x, y] <> 0 then
                HeroDangerMap^[x, y] := 1;
        end;
      end;
  end;

function TMapScr.SpotScore(h, x, y: integer): integer;
  const
    WasteDist = 8;
  var
    ss, d, gi, gj, nx, ny, hex, mi, mn, h2, wt, m, i, j, md, h3: integer;
    av, av2, gp, maxgp: longint;
    goodfight: boolean;

  procedure CheckFight(cx, cy: integer);
    var rav: longint;
    { pre-calc: av2 = enemy gp; gp = victory gp; ss = value if fight ok }
    begin
      if av < av2 then
        ss := MaxInt
      else if av < av2 * 3 then begin
        rav := ArmySetGP(@Hero^[h].army);
        gp := gp div 2; { lost troops worth more than gold value }
        if gp >= rav then gp := rav - 1;
        if Fight(cx, cy, true) > gp then
          ss := MaxInt;
      end;
    end;

  function Distance(x1, y1, x2, y2: integer): integer;
    begin
      Distance := Sqr(x1 - x2) + Sqr(y1 - y2);
    end;

  begin
    ss := MaxInt;
    d := Dist^[x, y] and $7F;
    gi := GeoX(x);
    gj := GeoY(y);
    mi := MapInfo^[x, y];
    mn := MapNum^[x, y];

    av := HeroArmyValue(h);

    md := TheMap^[x, y];
    h2 := HeroAtSpot(x, y);
    if h2 <> 0 then begin
      md := mHero;
      if d <= 0 then d := Dist^[x, y];
    end;
    goodfight := false;

    case md of
      mGrass:        for hex := 1 to 6 do
                       if FindAdjMapHex(hex, x, y, nx, ny) then
                         if TheMap^[nx, ny] in [mMonster,
                                                mHardMonster] then begin
                           av2 := MonsterData[MapInfo^[nx, ny] and $7F].cost
                                  * longint(MapNum^[nx, ny]);
                           ss := d + 1;
                           gp := 2 * (1250 + (MapGeos^[GeoX(nx), GeoY(ny)]
                                              .diff - 1) * 200);
                           if TheMap^[nx, ny] = mHardMonster then
                             gp := gp * 2;
                           CheckFight(nx, ny);
                           if (ss <> MaxInt)
                              and ((MapInfo^[nx, ny] and $80) <> 0) then
                             goodfight := true;
                         end;
      mRezGold
      ..mRezClay:    ss := d;
      mBag,
      mChest,
      mBarrel,
      mPotion:       ss := d;
      mArtifact:     if Hero^[h].Backpack[BackpackSize] = 0 then
                       ss := d;
      mCamp:         if FindEmptyOrMonster(@Hero^[h].army, HeroSlots(h),
                                           mi) <> 0 then
                       ss := d;
      mHero:         begin
                       if h2 = 0 then
                         TheMap^[x, y] := mGrass
                       else begin
                         if Hero^[h2].player = Turn then begin
                           ss := WorthTalking(h, h2, d);
                           if (d < WasteDist)
                             {or (ArmySetGP(@Hero^[h].army) < 2400)} then begin
                             wt := WorthTalking(h2, h, d);
                             if wt < ss then ss := wt;
                           end;
                         end else begin
                           av2 := HeroArmyValue(h2);
                           if (av > av2 * 3)
                              or (Fight(x, y, true)
                                  < ArmySetGP(@Hero^[h].army)) then begin
                             ss := (d * 2) div 5;
                             goodfight := true;
                           end;
                         end;
                       end;
                     end;
      mGoldMine
      ..mSkillMine,
      mHouseofHusbandry,
      mShamanHut,
      mMagicianHome,
      mWizardHouse:  if mn <> Hero^[h].player then
                       ss := d - 2;
      mFarmstead,
      mMiningVillage: if mn = 1 then begin
                        if d < WasteDist then ss := d
                        else ss := d + 100;
                      end;
      mHordeDwelling,
      mDwelling:     begin
                       if md = mHordeDwelling then begin
                         i := MonsterForLevel(Hero^[h].CT, 1);
                         av2 := 80;
                       end else begin
                         i := mi and $7F;
                         av2 := DwellingGuardsQty(i);
                       end;
                       if (mi and $80) <> 0 then begin
                         av2 := longint(av2) * MonsterData[i].cost;
                         if d < WasteDist then
                           ss := d
                         else
                           ss := d + 100;
                         gp := 1200;
                         CheckFight(x, y);
                       end else begin
                         if (Player[Turn].Resources[rGold] >= 1200)
                            and (mn > 0)
                            and (FindEmptyOrMonster(@Hero^[h].army,
                                                    HeroSlots(h),
                                                    i) <> 0) then begin
                           if Date = 0 then
                             ss := d - 4
                           else if d < WasteDist then
                             ss := d
                           else
                             ss := d + 100;
                         end;
                       end;
                     end;
      mSchool:       if not GetVisited(h, gi, gj, hvSchool)
                        and CanGainSkillLevel(h, mi) then
                       ss := d;
      mSpellPavilion: if not CheckForSpell(Hero^[h].SS, mi) then begin
                        if d < WasteDist * 2 then
                          ss := d
                        else
                          ss := d + 100;
                      end;
      mMonument:     if not GetVisited(h, gi, gj, hvMonument) then
                       ss := d;
      mShrine:       if (Hero^[h].ShrineBonus = 0) and (d < WasteDist) then
                       ss := d;
      mAltar:        if (Hero^[h].AltarBonus = 0) and (d < WasteDist) then
                       ss := d;
      mSageHut:      if not GetVisited(h, gi, gj, hvSageHut) then
                       ss := d;
      mJungleFort
      ..mLastCastle: begin
                       if Castle[mi].player = Turn then begin
                         if h2 = 0 then begin
                           if CastleDangerMap^[x, y]
                              > ArmySetGP(@Castle[mi].Garrison) then begin
                             ss := d div 2;
                             goodfight := true;
                           end else begin
                             av2 := ArmySharingValue(@Hero^[h].army,
                                                     @Castle[mi].Garrison,
                                                     HeroSlots(h), 6);
                             if av2 >= 3600 then
                               ss := d
                             else if av2 >= 1200 then begin
                               if d < WasteDist then
                                 ss := d - 2
                               else
                                 ss := d + 100;
                             end else if CountArt(h, anBagOfJunk, false)
                                         + CountArt(h, anBagOfBaubles, false)
                                         + CountArt(h, anBagOfJewelry, false)
                                         > 0 then
                               ss := d
                             else if d < WasteDist then
                               ss := d + 4
                             else
                               ss := d * 2 + 100;
                           end;
                         end;
                       end else begin
                         if h2 <> 0 then
                           av2 := HeroArmyValue(h2)
                         else
                           av2 := ArmySetGP(@Castle[mi].Garrison);
                         for i := 1 to 8 do
                           for j := 1 to 8 do
                             if Castle[mi].Grid[i, j] = bBarbican then
                               inc(av2, cBarbicanDamage * 10);
                         if (d > Hero^[h].MP + 1)
                            and (Castle[mi].player <> 0) then
                           inc(av2, CastleProdValue(mi)
                                    + CastleTroopsGP(mi, true));
                         if av > av2 then begin
                           ss := (d * 2) div 5;
                           goodfight := true;
                         end;
                       end;
                     end;
      mJunkMerchant: begin
                       for i := 1 to BackpackSize do begin
                         j := Hero^[h].Backpack[i];
                         if ((j >= anBagOfJunk) and (j <= anBagOfJewelry))
                            or ((j <> 0) and (ArtData[j].level = 1)) then
                           ss := d;
                       end;
                     end;
      mLibrary:      if (Player[Turn].Resources[rGold] > longint(5000) * mn)
                        and CanGainSkillLevel(h, LibrarySkill[mi]) then
                       ss := d;
      mCache:        if (mn = 0) and (Hero^[h].Backpack[BackpackSize]
                                      = 0) then begin
                       av2 := CacheStrength(mi);
                       ss := d;
                       gp := 3750 * CacheLevel[MapInfo^[x, y]];
                       CheckFight(x, y);
                     end;
      mHermitHut:    if Hero^[h].HermitBonus = hbNone then
                       ss := d;
      mUpgradeFort:  begin
                       maxgp := 0;
                       for i := 1 to HeroSlots(h) do begin
                         m := Hero^[h].army[i].monster;
                         if (Hero^[h].army[i].qty > 0)
                            and (MonsterLevel(m) = mi) then begin
                           gp := (MonsterData[m + 1].cost - MonsterData[m].cost)
                                 * longint(Hero^[h].army[i].qty) * 2;
                           if (gp > maxgp)
                              and (gp < Player[Turn].Resources[rGold]) then
                             maxgp := gp;
                         end;
                       end;
                       if maxgp > 2400 then
                         ss := d;
                     end;
    end;

    if ss <> MaxInt then begin
      if (MapGeos^[gi, gj].cat = mgcCastle + Turn * 16)
         and (RezProd[rRocks] < 2)
         and not (md in [mJungleFort..mLastCastle]) then
        dec(ss, 8);

      if not ((TheMap^[x, y] >= mJungleFort)
              and (TheMap^[x, y] <= mLastCastle)
              and (Castle[MapInfo^[x, y]].Player = Turn)) then begin
        FindPathHex(x, y, Hero^[h].MP + 1, nx, ny);
        if ((HeroDangerMap^[x, y] = 1)
           or ((nx <> 0) and (HeroDangerMap^[nx, ny] = 1))) then
          inc(ss, 1000)
        else begin
          FindPathHex(x, y, Hero^[h].MP + 1 + HeroMaxMP(h), nx, ny);
          if ((HeroDangerMap^[x, y] = 1)
             or ((nx <> 0) and (HeroDangerMap^[nx, ny] = 1))) then
            inc(ss, 1000);
        end;
      end;

      if not goodfight and (av > ToughFight) and (d >= WasteDist)
         and (Player[Hero^[h].player].Dudes[1] = h) then
        inc(ss, 200);

      if md in [mRezGold..mRezClay, mBag, mChest, mBarrel, mPotion,
                mArtifact, mCamp, mGoldMine..mSkillMine, mFarmstead,
                mDwelling, mHordeDwelling, mHermitHut, mMiningVillage,
                mShamanHut, mMagicianHome, mWizardHouse,
                mHouseofHusbandry] then begin
        for i := 1 to MaxDudes do begin
          h3 := Player[Turn].Dudes[i];
          if (h3 <> 0) and (h3 <> h) then begin
            if ((Hero^[h3].DestX = x) and (Hero^[h3].DestY = y))
               or (Distance(x, y, Hero^[h3].MapX, Hero^[h3].MapY) < 10) then
              inc(ss, 400);
          end;
        end;
      end;

      nx := Hero^[h].MapX;
      ny := Hero^[h].MapY;
      m := TheMap^[nx, ny];
      if ((h2 = 0) or (d > Hero^[h].MP + 2)
          or (Hero^[h2].player = Turn))
         and (m >= mJungleFort) and (m <= mLastCastle)
         and (CastleDangerMap^[nx, ny]
              > ArmySetGP(@Castle[MapInfo^[nx, ny]].Garrison))
         and (d > Hero^[h].MP div 2) then
        ss := MaxInt;
    end;

    SpotScore := ss;
  end;

procedure TMapScr.VisitAdjacent(fights: boolean);
  var
    hex, nx, ny, md, mi: integer;
    pal, isdwell: boolean;
  begin
    with Hero^[ActiveHero] do
      for hex := 1 to 6 do
        if (ActiveHero <> 0) and not GameOver
           and FindAdjMapHex(hex, MapX, MapY, nx, ny) then begin
          md := TheMap^[nx, ny];
          mi := MapInfo^[nx, ny];
          pal := (md = mHero) and (Hero^[HeroAtSpot(nx, ny)].player = Turn);
          isdwell := (md = mDwelling) or (md = mHordeDwelling);
          if pal or isdwell or (SpotScore(ActiveHero, nx, ny)
                                <> MaxInt) then begin
            if not (md in [mJungleFort..mLastCastle])
               and (fights or (not (md in [mGrass, mCache])
                               and not ((md = mHero) and not pal)
                               and not (isdwell and ((mi and $80) <> 0)))) then
              VisitSpot(nx, ny);
          end;
        end;
  end;

procedure TMapScr.AIHeroTurn(h, maxscore: integer);
  var
    x, y, bestx, besty, score, bestscore, hex, nx, ny, has: integer;
    hdone: boolean;

  function AtCastle: boolean;
    var m: integer;
    begin
      m := TheMap^[Hero^[h].MapX, Hero^[h].MapY];
      AtCastle := (m >= mJungleFort) and (m <= mLastCastle);
    end;

  begin
    with Hero^[h] do begin
      ActiveHero := h;
      hdone := false;
      ConserveSlots(@army, HeroSlots(ActiveHero));

      if AtCastle then begin
        VisitCastle(MapX, MapY);
        if MP < 6 then hdone := true;
      end;

      MakeHeroDangerMap;

      while (ActiveHero <> 0) and (MP > 0) and not hdone
            and not GameOver do begin
        HeroMakeMapDist(h, -1, 120);
        bestx := 0;
        bestscore := MaxInt;
        for x := 1 to MapSize do
          for y := 1 to MapSize do begin
            if (Dist^[x, y] > 0) and (Dist^[x, y] < 128) then
              has := HeroAtSpot(x, y)
            else
              has := 0;
            if (Dist^[x, y] >= 128) or ((has > 0) and (has <> h)) then begin
              score := SpotScore(h, x, y);
              if score < bestscore then begin
                bestscore := score;
                bestx := x;
                besty := y;
              end;
            end;
          end;
        if (bestx <> 0) and (bestscore <= maxscore) then begin
          if MakePath(bestx, besty) then
            WalkToDest(true)
          else
            hdone := true;
          if (ActiveHero <> 0) and (MP < 6) and AtCastle then hdone := true;
        end else begin
          hdone := true;
          ClearPath;
        end;
      end;

      if ActiveHero <> 0 then
        SpreadOut(ActiveHero, false);
    end;
  end;

function TMapScr.AICastlesTurn: boolean;
  var
    did, wait, gotone: boolean;
    earnings, needs, cpv, prodcr, availcr, gp: longint;
    BestCrs, BestDefense, BestDeadXP: longint;
    i, t, j, jidx, BestHeroTown, BestDeadHero: integer;
    FutureRez, rs: TResourceSet;
    r: TResource;
    TownAvailCr, TownDefense: array [1..MaxTowns] of longint;
    GatingNeeds: array [TCastleType] of longint;
    ct: TCastleType;
    h, q, m, k, gating, availgate: integer;
  begin
    did := false;
    wait := false;
    earnings := RezProd[rGold]; { mines, artifacts, castles }
    needs := 0;
    prodcr := 0;
    availcr := 0;
    FutureRez := Player[Turn].Resources;
    for r := low(TResource) to high(TResource) do
      inc(FutureRez[r], RezProd[r] * 2);
    BestHeroTown := 0;
    BestDefense := 0;
    BestCrs := 0;

    for i := 1 to MaxTowns do begin
      TownAvailCr[i] := 0;
      TownDefense[i] := 0;
      t := Player[Turn].Towns[i];
      if t <> 0 then begin
        cpv := CastleProdValue(t);
        inc(needs, cpv);
        inc(prodcr, cpv);
        if Castle[t].FreeSquares > 6 then inc(needs, 1000);
        for j := 1 to 6 do
          if Castle[t].AvailableTroops[j] > 0 then begin
            gp := longint(Castle[t].AvailableTroops[j])
                  * MonsterData[MonsterForLevel(Castle[t].CT, j)].cost;
            inc(availcr, gp);
            inc(TownAvailCr[i], gp);
          end;
        for j := 1 to 6 do
          with Castle[t].Garrison[j] do
            if qty > 0 then
              inc(TownDefense[i], longint(qty) * MonsterData[monster].cost);
        if TownDefense[i] > BestDefense then
          BestDefense := TownDefense[i];
        gp := TownDefense[i] + TownAvailCr[i];
        if (gp >= BestCrs)
           and ((TownDefense[i] >= BestDefense) or (TownDefense[i] >= 6000))
           and (HeroAtSpot(Castle[t].MapX, Castle[t].MapY) = 0) then begin
          BestCrs := gp;
          BestHeroTown := t;
        end;
      end;
    end;

    BestDeadHero := 0;
    BestDeadXP := 0;
    for j := 1 to NumHeroes do
      if Hero^[j].Dead and (Hero^[j].player = Turn)
         and (Hero^[j].XP > BestDeadXP) then begin
        BestDeadXP := Hero^[j].XP;
        BestDeadHero := j;
      end;

    { if must defend a castle, do so, w/ creatures / barbican }

    for i := 1 to MaxTowns do begin
      t := Player[Turn].Towns[i];
      if t <> 0 then begin
        if CastleDangerMap^[Castle[t].MapX, Castle[t].MapY]
           > TownDefense[i] then begin
          for j := 6 downto 1 do
            BuyCastleTroops(t, j, Castle[t].AvailableTroops[j], true);
          j := HeroAtSpot(Castle[t].MapX, Castle[t].MapY);
          if (ArmySetGP(@Castle[t].Garrison) <> 0)
             or ((j <> 0) and (ArmySetGP(@Hero^[j].army) <> 0)) then
            TryToBuild(t, bBarbican, false, false);
        end;
      end;
    end;

    { if no hero / troops piling up / good dead hero, buy best hero }

    if ((Player[Turn].Dudes[1] = 0) or (BestDefense >= 6000)
        or (BestDeadXP >= 10000))
       and (BestHeroTown <> 0) and (Player[Turn].Dudes[MaxDudes] = 0)
       and ((RezProd[rRocks] < 2) or (RezProd[rGold] >= 1000)) then begin
      if Player[Turn].Resources[rGold] < 2500 then
        wait := true
      else begin
        j := BestDeadHero;
        if j = 0 then j := Taverns[Castle[BestHeroTown].CT, 1];
        if j <> 0 then begin
          BuyHeroAtCastle(BestHeroTown, j);
          ShareTroops(@Hero^[j].army, @Castle[BestHeroTown].Garrison,
                      HeroSlots(j), 6);
        end;
      end;
    end;

    { if not enough cash production, build bazaar/mint }

    if (Player[Turn].Towns[2] = 0) and (needs < 2500) then needs := 2500;

    if not wait and (needs > earnings) then begin
      for i := 1 to MaxTowns do
        if not did then begin
          t := Player[Turn].Towns[i];
          if t <> 0 then begin
            if ((needs > earnings + 1500)
                and TryToBuild(t, bBigMoney, true, false))
               or TryToBuild(t, bLittleMoney, true, false) then
              did := true;
          end;
        end;
      if not did and (Player[Turn].Resources[rGold] < 3000) then
        wait := true;
    end;

    { if too many stockpiled creatures vs. production, buy some }

    if not did and not wait
       and ((availcr > prodcr * 5)
            or (Player[Turn].Resources[rGold] > 20000)) then begin
      for i := 1 to MaxTowns do begin
        t := Player[Turn].Towns[i];
        if t <> 0 then
          for j := 6 downto 1 do
            BuyCastleTroops(t, j, Castle[t].AvailableTroops[j], false);
      end;
    end;

    { buy creatures for heroes with gating }

    FillChar(GatingNeeds, sizeof(GatingNeeds), #0);
    for i := 1 to MaxDudes do begin
      h := Player[Turn].Dudes[i];
      if h <> 0 then begin
        gating := GetEffSkillLevel(h, skGating);
        if gating > 0 then begin
          ct := Hero^[h].CT;
          inc(GatingNeeds[ct], GatingGP * gating);
          ConserveSlots(@Hero^[h].army, HeroSlots(h));
          availgate := 0;
          for j := 1 to MaxTowns do begin
            t := Player[Turn].Towns[j];
            if (t <> 0) and (Castle[t].ct = ct) then begin
              for k := 1 to 6 do begin
                q := Castle[t].Garrison[k].qty;
                m := Castle[t].Garrison[k].monster;
                if (q > 0) and (FindEmptyOrMonster(@Hero^[h].army, HeroSlots(h), m)
                                > 0) then
                  inc(availgate, longint(q) * MonsterData[m].cost);
              end;
            end;
          end;
          if availgate < GatingNeeds[ct] then begin
            gp := GatingNeeds[ct] - availgate;
            for j := 1 to MaxTowns do begin
              t := Player[Turn].Towns[j];
              if (t <> 0) and (Castle[t].ct = ct) then begin
                for k := 6 downto 1 do
                  if gp > 0 then begin
                    m := MonsterForLevel(ct, k);
                    if FindEmptyOrMonster(@Hero^[h].army, HeroSlots(h), m)
                       > 0 then begin
                      q := BuyCastleTroops(t, k, (gp div MonsterData[m].cost)
                                                 + 1, false);
                      dec(gp, longint(q) * MonsterData[m].cost);
                    end;
                  end;
              end;
            end;
          end;
        end;
      end;
    end;

    { build creature dwelling if possible, unless worth waiting }

    if not did and not wait then begin
      for jidx := 1 to 6 do begin
        for i := 1 to MaxTowns do
          if not did and not wait then begin
            t := Player[Turn].Towns[i];
            if t <> 0 then begin
              j := MonsterRanks[Castle[t].CT, jidx];
              if TryToBuild(t, j, true, false) then
                did := true
              else begin
                FindBuildCost(t, j, rs);
                if CanPay(FutureRez, rs)
                   and CanBuildSomewhere(t, BuildingFootprint(t, j)^) then
                  wait := true;
              end;
            end;
          end;
      end;
    end;

    { other - mage guild, silo, random barbicans }

    AICastlesTurn := did;
  end;

procedure TMapScr.AITurn;
  const maxscore: array [1..2] of integer = (8, MaxInt);
  var i, j, h: integer;
  begin
    if not VisibleTurn then begin
      Window := winAI + Turn;
      DrawWindow;
    end;

    MakeCastleDangerMap;

    for j := 1 to 2 do begin
      for i := MaxDudes downto 1 do begin
        h := Player[Turn].Dudes[i];
        if h <> 0 then
          AIHeroTurn(h, maxscore[j]);
      end;

      repeat until not AICastlesTurn;
    end;

    if SpyMode then begin
      Window := winTurn;
      ClearDrawn;
      Draw;
      Player[Turn].AI := false;
      PlayerTurn;
      Player[Turn].AI := true;
    end;
  end;

procedure TMapScr.CheckDeath(pl: integer);
  var i, j, humans, ais, winner: integer;
  begin
    if (pl <> 0) and not Player[pl].DeathNoted then
      if (Player[pl].Dudes[1] = 0) and (Player[pl].Towns[1] = 0) then begin
        Dialog(PlName[pl] + ' has lost!', 0, 0, 0, 0, '', '', '', '');

        humans := 0;
        ais := 0;

        for i := 1 to high(Player) do
          if (Player[i].Dudes[1] <> 0) or (Player[i].Towns[1] <> 0) then begin
            if Player[i].AI then
              inc(ais)
            else begin
              inc(humans);
              winner := i;
            end;
          end;

        if (humans = 0) or ((ais = 0) and (humans = 1)) then begin
          if humans = 0 then
            Dialog('The computer wins!', 0, 0, 0, 0, '', '', '', '')
          else
            Dialog(PlName[winner] + ' wins!', 0, 0, 0, 0, '', '', '', '');
          GameOver := true;
          QuitToMenu := true;
        end;

        for i := 1 to MapSize do
          for j := 1 to MapSize do
            if (TheMap^[i, j] >= mGoldMine) and (TheMap^[i, j] <= mSkillMine)
               and (MapNum^[i, j] = pl) then begin
              MapNum^[i, j] := 0;
              MapNum^[i + 1, j] := 0;
            end else if (TheMap^[i, j] in [mShamanHut, mMagicianHome,
                                           mWizardHouse, mHouseofHusbandry])
                        and (MapNum^[i, j] = pl) then
              MapNum^[i, j] := 0;

        Player[pl].DeathNoted := true;
      end;
  end;

procedure TMapScr.CalcMonsterRanks;
  const
    edgegp = 2 * 6000;
    testspermonster = 40;
    target: array [1..6] of integer = (16000, 13000, 11000, 9000, 7500, 6000);
  var
    Pl1AI: boolean;
    Hero4Pl, Hero4SP, MI11: integer;
    hm, i, mq, ovflw, basem, enm, j, bestj: integer;
    AS: TArmySet;
    fa, bestv: longint;
    f: text;
    ranks: array [1..NumMonsters] of longint;
    ct: TCastleType;
    savearmy: TArmySet;
    levavg: array [1..6] of longint;
    castleavg: array [TCastleType] of longint;
    avgcavg: longint;

  function CastleTotalStr(ct2: TCastleType): string;
    begin
      CastleTotalStr := LSet(LSet(CastleNames[ct2], 20) + '-> '
                             + LStr(castleavg[ct2] div testspermonster, 6)
                             + '  '
                             + LStr(castleavg[ct2] div testspermonster
                                    - avgcavg div testspermonster, 5), 39);
    end;

  function RankStr(rm: integer): string;
    begin
      RankStr := LSet(LSet(MonsterData[rm].name, 20) + '-> '
                      + LStr(ranks[rm] div testspermonster, 6) + '  '
                      + LStr(ranks[rm] div testspermonster
{                            - levavg[MonsterLevel(rm)]
                               div testspermonster, 5), 39) }
                             - target[MonsterLevel(rm)], 5), 39)
    end;

  begin
    Pl1AI := Player[1].AI;
    Player[1].AI := true;
    Hero4Pl := Hero^[4].player;
    Hero^[4].player := 1;
    Hero4SP := Hero^[4].SP;
    Hero^[4].SP := 10;
    AS := Hero^[4].army;
    MI11 := MapInfo^[1, 1];
    ActiveHero := 4;

    if SuperSpyMode then begin
      assign(f, 'temp.dat');
      rewrite(f);
    end;

    for j := 1 to NumMonsters do begin
      hm := ((j - 1) div 2) + ((j - 1) mod 2) * (NumMonsters div 2) + 1;
      ovflw := 0;
      basem := hm - ((hm - 1) mod 6);
      for i := 1 to 6 do begin
        Hero^[4].army[i].monster := hm;
        mq := (edgegp + ovflw) div MonsterData[hm].cost;
        ovflw := (edgegp + ovflw) mod MonsterData[hm].cost;
        if MonsterHasFlag(hm, 4, f4Multiplies) then
          inc(mq, mq div 10);
        if MonsterHasFlag(hm, 4, f4Pathfinding) then
          inc(mq, mq div 10);
        Hero^[4].army[i].qty := mq;
      end;
      if MonsterHasFlag(hm, 3, f3DeathMana) then
        Hero^[4].SP := 10 + 600 div MonsterData[hm].cost
      else
        Hero^[4].SP := 10;
      ranks[hm] := 0;
      for enm := 1 to NumMonsters do
        if MonsterLevel(enm) <= 4 then begin
          MapInfo^[1, 1] := enm;
          savearmy := Hero^[4].army;
          fa := LowFight(1, 1, true, 3);
          Hero^[4].army := savearmy;
{         writeln(f, LSet(MonsterData[hm].name, 20) + 'vs. '
                     + LSet(MonsterData[enm].name, 20) + '-> '
                     + LStr(fa, 0));  }
          inc(ranks[hm], fa);
        end;
    end;

    for j := 1 to 6 do begin
      levavg[j] := 0;
      for i := 1 to NumCastleTypes do
        inc(levavg[j], ranks[(i - 1) * 6 + j]);
      levavg[j] := levavg[j] div NumCastleTypes;
    end;

    if SuperSpyMode then begin
      for j := 1 to NumMonsters div 2 do begin
        writeln(f, RankStr(j) + RankStr(j + (NumMonsters div 2)));
        if j mod 6 = 0 then writeln(f, copy(Dash, 1, 79));
      end;
      writeln(f);
    end;

    avgcavg := 0;
    for ct := low(TCastleType) to high(TCastleType) do begin
      castleavg[ct] := 0;
      for i := 1 to 6 do
        inc(castleavg[ct], ranks[ord(ct) * 6 + i]);
      castleavg[ct] := castleavg[ct] div 6;
      inc(avgcavg, castleavg[ct]);
    end;
    avgcavg := avgcavg div NumCastleTypes;

    if SuperSpyMode then begin
      for j := 0 to 4 do
        writeln(f, CastleTotalStr(TCastleType(j))
                   + CastleTotalStr(TCastleType(j + 5)));
      close(f);
    end;

    MapInfo^[1, 1] := MI11;
    Hero^[4].army := AS;
    Hero^[4].SP := Hero4SP;
    Hero^[4].player := Hero4Pl;
    Player[1].AI := Pl1AI;

    for ct := low(TCastleType) to high(TCastleType) do begin
      for i := 1 to 6 do begin
        bestv := MaxLongInt;
        for j := 1 to 6 do begin
          hm := MonsterForLevel(ct, j);
          if ranks[hm] < bestv then begin
            bestv := ranks[hm];
            bestj := j;
          end;
        end;
        MonsterRanks[ct, i] := bestj;
        ranks[MonsterForLevel(ct, bestj)] := MaxLongInt;
      end;
    end;
  end;

procedure TMapScr.Setup;
  var j, t, n, h, q, i, ni, nj: integer;
  begin
    for Turn := 1 to NumPlayers do begin
      for j := 1 to MaxTowns do begin
        t := Player[Turn].Towns[j];
        if t <> 0 then
          RevealArea(Castle[t].MapX, Castle[t].MapY, 6);
      end;
      for j := 1 to MaxDudes do begin
        t := Player[Turn].Dudes[j];
        if t <> 0 then
          RevealHero(t);
      end;
      if not Player[Turn].AI then LastHuman := Turn;
    end;

    Turn := 1;
    if not Player[Turn].AI then LastHuman := Turn;

    if Twists[twStartWithArt] then begin
      repeat
        n := RandomArtifact(1);
      until ArtData[n].slot <> slNone;
      for h := 1 to NumHeroes do
        GainArt(h, n);
    end;

    if Twists[twStartWithStack] then begin
      n := random(NumMonsters) + 1;
      case random(3) of
        0: q := 1200;
        1: q := 2400;
        2: q := 4800;
      end;
      q := (q + (MonsterData[n].cost div 2)) div MonsterData[n].cost;
      if q < 1 then q := 1;
      for h := 1 to NumHeroes do
        if Hero^[h].player <> 0 then
          GainMonster(@Hero^[h].army, HeroSlots(h),
                      n, q);
    end;

    if Twists[twStartWithSkill] then begin
      n := random(NumSkills) + 1;
      for h := 1 to NumHeroes do
        GainSkillLevel(h, n);
    end;

    if Twists[twStartWithBuilding] then begin
      n := random(13) + 1;
      for t := 1 to NumCastles do
        TryToBuild(t, n, false, true);
    end;

    CalcMonsterRanks;

    if Twists[twMoreCastleObstacles] then begin
      for t := 1 to NumCastles do
        for n := 1 to 8 do begin
          i := random(8) + 1;
          j := random(8) + 1;
          if Castle[t].Grid[i, j] = bEmpty then begin
            Castle[t].Grid[i, j] := bObstacle;
            Castle[t].Center[i, j] := (i - 1) + (j - 1) * 8;
            dec(Castle[t].FreeSquares);
          end;
        end;
    end;

    if Twists[twAllSameResource] then begin
      n := mRezGold + random(mRezClay - mRezGold + 1);
      for i := 1 to MapSize do
        for j := 1 to MapSize do begin
          q := TheMap^[i, j];
          if (q >= mRezGold) and (q <= mRezClay) then
            TheMap^[i, j] := n;
        end;
    end;

    if Twists[twStartWithHero] then begin
      for n := 1 to NumPlayers do begin
        h := FindUnusedHero(Castle[Player[n].Towns[1]].CT, 0);
        if h <> 0 then begin
          i := Hero^[Player[n].Dudes[1]].MapX;
          j := Hero^[Player[n].Dudes[1]].MapY;
          for q := 1 to 6 do
            if (h <> 0) and FindAdjMapHex(q, i, j, ni, nj) then
              if TheMap^[ni, nj] = mGrass then begin
                GainHero(n, h, ni, nj);
                TheMap^[ni, nj] := mHero;
                h := 0;
              end;
        end;
      end;
    end;

    if Twists[twFlooding] then begin
      for i := 1 to MapSize do
        for j := 1 to MapSize do
          if (TheMap^[i, j] = mDoodad)
             and (TheMap^[i + 1, j] = mWater) then begin
            TheMap^[i, j] := mWater;
            MapInfo^[i, j] := $3F;
          end;
    end;

    SetTaverns;

    for n := 1 to NumPlayers do
      for i := 1 to MaxDudes do begin
        h := Player[n].Dudes[i];
        if h <> 0 then begin
          PickSpecialty(h);
          PickExpertise(h);
        end;
      end;
  end;

procedure TMapScr.Handle;
  begin
    repeat
      if (Player[Turn].Dudes[1] <> 0) or (Player[Turn].Towns[1] <> 0) then begin
        StartTurn;
        PrepTurn;
        if not Twists[twSkipWeekend] or (Date mod 7 < 5) then begin
          if Player[turn].AI then
            AITurn
          else
            PlayerTurn;
        end;
      end;
      if not GameOver then NextTurn;
    until GameOver;
  end;

procedure TMapScr.SaveGame;
  var f: file;
  begin
    assign(f, 'SAVEGAME.DAT');
    rewrite(f, 1);

    blockwrite(f, Player, sizeof(Player));
    blockwrite(f, NumPlayers, sizeof(NumPlayers));
    blockwrite(f, Turn, sizeof(Turn));
    blockwrite(f, Date, sizeof(Date));

    blockwrite(f, Hero^, sizeof(Hero^));

    blockwrite(f, NumCastles, sizeof(NumCastles));
    blockwrite(f, Castle, sizeof(Castle));
    blockwrite(f, Taverns, sizeof(Taverns));

    blockwrite(f, FoundMaps, sizeof(FoundMaps));
    blockwrite(f, TreasureMap, sizeof(TreasureMap));

    blockwrite(f, TheMap^, sizeof(TheMap^));
    blockwrite(f, MapInfo^, sizeof(MapInfo^));
    blockwrite(f, Dist^, sizeof(Dist^));
    blockwrite(f, Roads^, sizeof(Roads^));
    blockwrite(f, MapNum^, sizeof(MapNum^));
    blockwrite(f, Climate^, sizeof(Climate^));

    blockwrite(f, MapGeos^, sizeof(MapGeos^));
    blockwrite(f, MapBits^, sizeof(MapBits^));
    blockwrite(f, Fog^, sizeof(Fog^));
    blockwrite(f, RezProd, sizeof(RezProd));

    blockwrite(f, ToughFight, sizeof(ToughFight));
    blockwrite(f, Twists, sizeof(Twists));
    blockwrite(f, OneSquareDwelling, sizeof(OneSquareDwelling));
    blockwrite(f, MixedCreaturesOfs, sizeof(MixedCreaturesOfs));
    blockwrite(f, AllMonstersAbility, sizeof(AllMonstersAbility));
    blockwrite(f, MonsterRanks, sizeof(MonsterRanks));

    close(f);
{
    Message('Game saved.');
    ClearDrawn;
    Draw;
}
  end;

procedure TMapScr.LoadGame;
  var f: file;
  begin
    assign(f, 'SAVEGAME.DAT');
    reset(f, 1);

    blockread(f, Player, sizeof(Player));
    blockread(f, NumPlayers, sizeof(NumPlayers));
    blockread(f, Turn, sizeof(Turn));
    blockread(f, Date, sizeof(Date));

    blockread(f, Hero^, sizeof(Hero^));

    blockread(f, NumCastles, sizeof(NumCastles));
    blockread(f, Castle, sizeof(Castle));
    blockread(f, Taverns, sizeof(Taverns));

    blockread(f, FoundMaps, sizeof(FoundMaps));
    blockread(f, TreasureMap, sizeof(TreasureMap));

    blockread(f, TheMap^, sizeof(TheMap^));
    blockread(f, MapInfo^, sizeof(MapInfo^));
    blockread(f, Dist^, sizeof(Dist^));
    blockread(f, Roads^, sizeof(Roads^));
    blockread(f, MapNum^, sizeof(MapNum^));
    blockread(f, Climate^, sizeof(Climate^));

    blockread(f, MapGeos^, sizeof(MapGeos^));
    blockread(f, MapBits^, sizeof(MapBits^));
    blockread(f, Fog^, sizeof(Fog^));
    blockread(f, RezProd, sizeof(RezProd));

    blockread(f, ToughFight, sizeof(ToughFight));
    blockread(f, Twists, sizeof(Twists));
    blockread(f, OneSquareDwelling, sizeof(OneSquareDwelling));
    blockread(f, MixedCreaturesOfs, sizeof(MixedCreaturesOfs));
    blockread(f, AllMonstersAbility, sizeof(AllMonstersAbility));
    blockread(f, MonsterRanks, sizeof(MonsterRanks));

    close(f);

    ClearScr;
    DrawBackground := true;
    BackgroundColor := colGreen;
    LastHuman := Turn;
    PrepTurn;
    PlayerTurn;
    if not GameOver then NextTurn;
  end;

{ unit initialization }

end.
